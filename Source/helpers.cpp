/*	Copyright  (c)	Günter Woigk 2014 - 2020
					mailto:kio@little-bat.de

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	Permission to use, copy, modify, distribute, and sell this software and
	its documentation for any purpose is hereby granted without fee, provided
	that the above copyright notice appear in all copies and that both that
	copyright notice and this permission notice appear in supporting
	documentation, and that the name of the copyright holder not be used
	in advertising or publicity pertaining to distribution of the software
	without specific, written prior permission.  The copyright holder makes no
	representations about the suitability of this software for any purpose.
	It is provided "as is" without express or implied warranty.

	THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
	INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
	EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
	CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
	DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
	PERFORMANCE OF THIS SOFTWARE.
*/


#include "helpers.h"
#include "Segment.h"
#include <sys/time.h>


uint32 compressed_page_size_z80 (uint8 const* q, uint qsize)
{
	// calculate size of compressed data in .z80 format

	xlogIn("compressed_page_size_z80");

	uint8 const* qe = q + qsize;
	uint32 sz = 0;

	while (q < qe)
	{
		uint8 c = *q++;
		if (q==qe || *q!=c)				// single byte
		{
			sz++;
			// special care for compressible sequence after single 0xed:
			if (c==0xed && q+2<=qe && *q==*(q+1)) { sz++; q++; }
		}
		else							// sequence of same bytes
		{
			int n=1; while (n<255 && q<qe && *q==c) { n++; q++; }
			if (n>=4 || c==0xed)	sz+=4; 	// compress ?
			else					sz+=n; 	// don't compress
		}
	}

	return sz;
}

void write_compressed_page_z80 (FD& fd, int page_id , uint8 const* q, uint32 qsize) throws
{
	// write compressed data in .z80 format
	//
	// 	page_id<0:	=> v1.45 format without page header
	// 				compressed or uncompressed data is stored without header.
	// 				compression is indicated by bit head.data&0x20
	// 				note: calculate compressed size with compressed_page_size_z80()
	// 					  to decide whether to compress the page or not!
	// 	page_id≥0:	=> z80 v2.0++ with page header
	// 				all pages are compressed
	// 				pages are preceded by a 3-byte header:
	// 					dw	length of data (without this header; low byte first)
	// 					db	page number of block
	//
	// 	compression scheme:
	// 		dc.b $ed, $ed, count, char

	xlogIn("write_compressed_page_z80 %i",page_id);

	assert(qsize>=1 kB && qsize<=64 kB);
	assert(page_id>=0 || qsize==0xC000);		// v1.45 must be 48k

	uint8 const* qe = q + qsize;
	uint8 zbu[qsize*5/3+9];					// worst case size: 5/3*qsize
	uint8* z = zbu;

	while (q < qe)
	{
		uint8 c = *q++;
		if (q==qe || *q!=c)					// single byte: next byte is different
		{
			*z++ = c;
			// special care for compressible sequence after single 0xed:
			// prevent triple 0xed
			if (c==0xed && q+2<=qe && *q==*(q+1)) { *z++ = *q++; }
		}
		else								// sequence of same bytes
		{
			int n=1; while (n<255 && q<qe && *q==c) { n++; q++; }
			if (n>=4 || c==0xed) { *z++ = 0xed; *z++ = 0xed; *z++ = n; *z++ = c; }	// compress ?
			else				 { while (n--) *z++ = c; }							// don't compress
		}
	}

	uint zsize = z-zbu;

	if (page_id>=0)	// v2.0++
	{
		fd.write_uint16_z(zsize);
		fd.write_char(page_id);
	}
	fd.write_bytes(zbu,zsize);
}

void write_intel_hex( FD& fd, uint32 addr, uint8 const* bu, uint32 sz ) throws
{
	// write block of data in intel hex file format
	// format of one line:
	//	 :llaaaattddd…cc\r\n
	// where
	// 	 :    = each line starts with a colon
	// 	 ll   = number of data bytes stored in this line
	// 	 aaaa = address of data
	// 	 tt   = type of line: 0 -> data, 1 -> oef, 4 -> upper 16 bit of address (if > 64k)
	// 	 ddd… = data
	// 	 cc   = 2's complement of checksum of ll, aaaa, tt and data
	// 	 \r\n = dos line end

	if (sz==0) return;

	// do we cross a 16 bit boundary?

	while ((addr>>16) != ((addr+sz-1)>>16))
	{
		uint16 n = /*0x10000*/-addr;		// bytes left in current 16-bit address block

		write_intel_hex(fd, addr, bu, n);

		addr += n;
		bu   += n;
		sz   -= n;
	}

	// do we need an extended address block?
	// note: we do not test for addr&0xFFFF==0 as well because
	// caller might have skipped some bytes at start of block.
	// therefore this block may be written unneccessarily multiple times.

	if (addr>>16)
	{
		uint8 checksum = - 2 - 0 - 0 - 4 - (addr>>24) - (addr>>16);
		fd.write_fmt(":02000004%04X%02X\r\n", uint(addr>>16), uint(checksum));
	}

	// store data:

	while (sz)
	{
		uint n = min(sz,32u);									// bytes dumped in this line

		fd.write_fmt(":%02X%04X00", n, uint(uint16(addr)));		// ":", len, address, type
		uint8 checksum = - n - addr - (addr>>8) - 0;			// checksum

		addr += n;
		sz   -= n;

		while (n--)												// write data bytes
		{
			fd.write_fmt("%02X", uint(*bu));
			checksum -= *bu++;
		}

		fd.write_fmt("%02X\r\n", uint(checksum));				// write 2's complement of checksum
	}
}

uint write_motorola_s19( FD& fd, uint32 address, uint8 const* data, uint32 count ) throws
{
	// write block of data in motorola s-record file format
	// format of one line:
	// 	 ttllaaaaddd…cc\r\n
	// where
	// 	 tt = 'S0' -> data = module_name + version + revision + comment  (recommended)
	// 	 tt = 'S1' -> 2-byte address + data
	// 	 tt = 'S2' -> 3-byte address + data
	// 	 tt = 'S3' -> 4-byte address + data
	// 	 tt = 'S5' -> 2-byte address = number of S1/2/3 lines transmitted before this record
	// 	 tt = 'S6' -> 3-byte address = number of S1/2/3 lines transmitted before this record (inofficial?)
	// 	 tt = 'S7' -> end of block marker: 4-byte address = 0 or program entry address
	// 	 tt = 'S8' -> end of block marker: 3-byte address = 0 or program entry address
	// 	 tt = 'S9' -> end of block marker: 2-byte address = 0 or program entry address
	//
	// 	 ll = number of bytes following (address + data + checksum)
	// 	 	 note: number of hexchars following = ll*2
	//
	// 	 aa = 2, 3 or 4 byte address (4, 6 or 8 hexchars) acc. to type tt
	// 	 dd = data, at most 64 bytes (128 hexchars)
	// 	 cc = 1 byte (2 chars) checksum = 0xFF ^ SUM(llaaaaddd…)
	// 	 \r\n line end
	//
	// return: the number of s-records written: required by caller for the final S5-record

	uint cnt = 0;

	while (count)
	{
		uint n = min(count,64u);
		write_srecord(fd,S19_Data,address,data,n);
		data    += n;
		address += n;
		count   -= n;
		cnt     += 1;
	}

	return cnt;
}

void write_srecord( FD& fd, S19Type type, uint32 address, uint8 const* data, uint count ) throws
{
	// write one line into a s-record file:
	// type = S19_InfoHeader  = 0 -> info header: S0 record
	// type = S19_Data        = 1 -> data block: S1 or S2 record
	// type = S19_RecordCount = 5 -> records written: S5 record
	// type = S19_BlockEnd    = 9 -> block end: S9 or S8 record

	assert(type==S19_InfoHeader || type==S19_Data || type==S19_RecordCount || type==S19_BlockEnd);
	assert(address<=0xffffff);
	assert(type<=S19_Data ? count<=64 : count==0);

	uint checksum = 0;

	if (address > 0xffff)
	{
		char c = type==S19_BlockEnd ? type-1 : type+1;
		fd.write_fmt("S%c%02X%06X", c, count+4, address);
		checksum = count+4 + address + (address>>8) + (address>>16);
	}
	else
	{
		fd.write_fmt("S%c%02X%04X", type, count+3, address);
		checksum = count+3 + address + (address>>8);
	}

	uint8 bu[128], *z = bu;
	uint8 const *q = data, *e = data+count;
	while (q<e) { *z++ = hexchar(*q/16); *z++ = hexchar(*q); checksum += *q++; }
	fd.write_bytes(bu,count*2);
	fd.write_fmt("%02X\r\n", ~checksum & 0xff);		// write 1's complement of checksum
}

void write_compressed_page_ace (FD& fd, uint8 const* q, uint qsize) throws
{
	// write compressed data in .ace format
	//
	// compression scheme:
	// 	  dc.b $ed, count, char

	if (qsize == 0) return;
	assert(/*qsize>=1 kB &&*/ qsize<=64 kB);

	uint8 zbu[qsize*2+8];				// worst case size: 2*qsize
	uint8* z = zbu;						// dest. ptr
	uint8 const* qe = q + qsize;		// source end ptr

	while (q < qe)
	{
		uint8 c = *q++;
		uint  n = 1; while (q<qe && *q==c && n<240) { q++; n++; }

		if (c==0xed || n>3)
		{
			*z++ = 0xed;
			*z++ = n;
			*z++ = c;
		}
		else
		{
			while (n--) *z++ = c;
		}
	}

	fd.write_bytes(zbu,z-zbu);
}

void write_segment (FD& fd, const CodeSegment& s) throws
{
	// write segment to file
	// depending on flag s.compressed write compressed or uncompressed data

	fd.write_bytes(s.outputData(),s.outputSize());
}








































