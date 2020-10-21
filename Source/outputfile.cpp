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

#include "Z80Assembler.h"
#include "Z80Header.h"
#include "helpers.h"
#include "unix/files.h"
#include "zx7.h"
#include "audio/WavFile.h"
#include "audio/audio.h"
#include "kio/peekpoke.h"
#include <zlib.h>


/* ==============================================================
		write segments[] to output file
		no error checking
		if name ends with ".$" then the caller's dname is updated
			to the actually used name (unprotected tempstr)
============================================================== */

void Z80Assembler::writeTargetfile (cstr& dname, int style) throws
{
	assert(errors.count()==0);
	assert(dname != nullptr);
	assert(style=='b' || style=='x' || style=='s'); // bin/hex/s19

	if (target == TARGET_UNSET)
	{
		target = ROM;
		target_ext = "rom";
	}

	if (style == 'x' && (target==ROM || target==BIN)) target_ext = "hex";
	if (style == 's' && (target==ROM || target==BIN)) target_ext = "s19";

	if (endswith(dname,".$")) dname = catstr(leftstr(dname,int(strlen(dname))-1),target_ext);
	target_filepath = dname;
	FD fd(dname,'w');	// create & open file for writing

	switch(target)
	{
	case TARGET_UNSET:
	case ROM:
	case BIN:	if (style=='x') { writeHexFile(fd); return; }
				if (style=='s') { writeS19File(fd); return; }
				return writeBinFile(fd);
	case SNA:	return writeSnaFile(fd);
	case Z80:	return writeZ80File(fd);
	case ACE:	return writeAceFile(fd);
	case TZX:	return writeTzxFile(fd);
	case TAP:	return writeTapFile(fd);
	case ZX80:	return writeZX80File(fd);
	case ZX81:
	case ZX81P:	return writeZX81File(fd);
	}
	throw SyntaxError("internal error: writeTargetfile: unknown target");
}

void Z80Assembler::writeBinFile (FD& fd) throws
{
	// no error checking!
	// just concatenate everything

	CodeSegments segments(this->segments);

	for (uint i=0; i<segments.count(); i++)
	{
		write_segment(fd,segments[i]);
	}
}

void Z80Assembler::writeSnaFile (FD& fd) throws
{
	// no error checking!
	// just concatenate everything

	writeBinFile(fd);
}

void Z80Assembler::writeZX80File (FD& fd) throws
{
	// no error checking!
	// just concatenate everything

	writeBinFile(fd);
}

void Z80Assembler::writeZX81File (FD& fd) throws
{
	// no error checking!
	// just concatenate everything

	writeBinFile(fd);
}

void Z80Assembler::writeHexFile (FD& fd) throws
{
	// store data from segments into hex file
	// no error checking!

	// BIN: use segment origin for addresses.

	// ROM: ignore segment addresses.
	//	 start file at address 0 and concatenate all segments with no gaps.
	//	 unset bytes at the end of fixed-size segments are not written
	//	 but accounted for the address of the following segment.
	//	 this is just to save space in the file and may be used
	//	 to skip over areas of not yet erased contents in eproms

	CodeSegments segments(this->segments); // extract code segments

	uint32 address = 0;
	for (uint i=0; i<segments.count(); i++)
	{
		CodeSegment& s = segments[i];
		if (target == BIN) address = uint(s.address);

		uint8 const* data = s.outputData();
		uint32 size = s.outputSizeUpToDpos();
		write_intel_hex(fd, address, data, size);
		address += s.outputSize(); // ROM only
	}

	// eof marker:
	fd.write_str(":00000001FF\r\n");
}

void Z80Assembler::writeS19File (FD& fd) throws
{
	// store data from segments into hex file
	// no error checking!

	// BIN: use segment origin for addresses.

	// ROM: ignore segment addresses.
	//	 start file at address 0 and concatenate all segments with no gaps.
	//	 unset bytes at the end of fixed-size segments are not written
	//	 but accounted for the address of the following segment.

	// S0 record:
	// VERSAdos: modulename[10],version[1],revision[1],description[0..18]
	// Motorola: "The code/data field may contain any descriptive information identifying the following block of S-records."
	cstr info = catstr(basename_from_path(source_filename)," ",datestr(timestamp));
	write_srecord(fd,S19_InfoHeader,0,cuptr(info),min(uint(strlen(info)),64u));

	CodeSegments segments(this->segments); // extract code segments

	uint32 address = 0;
	uint   srcount = 0;
	for (uint i=0; i<segments.count(); i++)
	{
		CodeSegment& s = segments[i];
		if (target == BIN) address = uint(s.address);

		uint8 const* data = s.outputData();
		uint32 size = s.outputSizeUpToDpos();
		srcount += write_motorola_s19(fd, address, data, size);
		address += s.outputSize(); // ROM only
	}

	// eof marker:
	write_srecord(fd,S19_RecordCount,srcount,nullptr,0);
	write_srecord(fd,S19_BlockEnd,0,nullptr,0);
}

void Z80Assembler::writeTapFile (FD& fd) throws
{
	// no error checking!

	// tape data blocks are written like this:
	//		dw	len				; number of bytes that follow
	//		db	flag			; except if no_flagbyte: Jupiter ACE!
	//		ds	data			; from segment(s)
	//		db	checksum		; simple xor of blocktype + data bytes

	CodeSegments segments(this->segments);
	while (!segments[0]->has_flag) { assert(segments[0]->size==0); segments.remove(0u); }

	// OLD until 4.1.6:
	// Jupiter Ace tape files were detected by analyzing the blocks:
	// 1st block must be header: type=$00 and size=25
	// 2nd block must be data:   type=$FF
	// if more blocks: must alternate between header and data
	// then the flag was not stored and not accounted for the checksum
	// NEW since 4.2.0:
	// User must set FLAG=NONE in #CODE declaration
	// then the flag is not stored and not accounted for the checksum

	// write tape blocks
	// each block may consist of multiple segmentes
	// where the first segment has the flag byte defined and
	// following segments without flag byte are appended to this block.
	//
	for (uint i0=0,i=0; i<segments.count(); i0=i)
	{
		CodeSegment* s = segments[i];
		assert(s->has_flag);

		uint8 flag = uint8(s->flag);
		bool writeflagbyte = !s->no_flagbyte;
		bool writechecksum = !s->no_checksum;

		// calc. size of tape block:
		uint32 size = 0;
		do { size += s->outputSize(); }
		while (++i<segments.count() && !(s=segments[i])->has_flag);

		// write block size and block type:
		fd.write_uint16_z(uint16(writeflagbyte+size+writechecksum));	// length of following data
		if (writeflagbyte) fd.write_uint8(flag);	// block type

		// write data and calc checksum
		uint8 checksum = writeflagbyte ? flag : 0;
		i = i0; s = segments[i];
		do
		{
			uint8 const* qa = s->outputData();
			uint32 size = s->outputSize();
			fd.write_bytes(qa,size);
			for (uint8 const* q = qa+size; q>qa; ) { checksum ^= *--q; }
		}
		while (++i<segments.count() && !(s=segments[i])->has_flag);

		//write checksum
		if (writechecksum) fd.write_uint8(checksum);
	}
}

void Z80Assembler::writeZ80File (FD& fd) throws
{
	// no error checking!

	CodeSegments segments(this->segments);

	const uint i0 = 0;

	// first segment is the z80 file header and written as-is
	// subsequent segments are written as compressed memory pages
	// except if v1.45 is detected and the compressed data bit is not set
	CodeSegment& hs = segments[i0];
	fd.write_bytes(hs.getData(), uint32(hs.size));

	if (hs.size == z80v1len)		// write v1.45 single page:
	{
		CodeSegment& s = segments[i0+1];
		if (hs.core[12]!=255 && hs.core[12] & 0x20)	// head.data.bit5
			 write_compressed_page_z80( fd, -1, s.getData(), uint32(s.size) );
		else fd.write_bytes( s.getData(), uint32(s.size) );
	}
	else // write v2.0++ pages:
	{
		for (uint i=i0+1; i<segments.count(); i++)
		{
			CodeSegment& s = segments[i];
			write_compressed_page_z80( fd, s.flag, s.getData(), uint32(s.size));
		}
	}
}

void Z80Assembler::writeAceFile (FD& fd) throws
{
	// no error checking!
	// just compress & concatenate everything

	CodeSegments segments(this->segments);

	for (uint i=0; i<segments.count() && segments[i]->isCode(); i++)
	{
		CodeSegment& s = segments[i];
		write_compressed_page_ace(fd, s.outputData(), s.outputSize());
	}

	// eof marker:
	fd.write_uint8(0xED);
	fd.write_uint8(0);
}

void Z80Assembler::writeTzxFile (FD& fd) throws
{
	// no error checking!

	// write TZX header:
	// 0x00  "ZXTape!"	ASCII[7]	TZX signature
	// 0x07  0x1A		BYTE		End of text file marker
	// 0x08  1			BYTE		TZX major revision number
	// 0x09  20			BYTE		TZX minor revision number

	fd.write_str("ZXTape!");
	uint8 hdr[] = {0x1a,1,20};
	fd.write_bytes(hdr,3);

	// write segments:

	uint i = 0;
	while (!segments[i]->is_code && !segments[i]->is_tzx) { i++; }

	for (uint a=i; i<segments.count(); a=i)
	{
		xlogline("TZX fpos = 0x%04llX",fd.file_position());
		switch (segments[i]->type)
		{
		case TEST:
		case DATA:
		{
			continue;
		}
		case TZX_PURE_TONE:
		{
			if (verbose>=2) logline("write TZX PURE TONE");
			TzxPureToneSegment* s = dynamic_cast<TzxPureToneSegment*>(segments[i].ptr());
			fd.write_uint8(TZX_PURE_TONE);
			fd.write_uint16_z(uint16(s->pulse_length));
			fd.write_uint16_z(uint16(s->num_pulses));
			i++; continue;
		}
		case TZX_PULSES:
		{
			if (verbose>=2) logline("write TZX PULSES");
			TzxPulses* s = dynamic_cast<TzxPulses*>(segments[i].ptr());
			fd.write_uint8(TZX_PULSES);
			fd.write_uint8(uint8(s->count));
			for (uint i=0; i<s->count; i++)
				fd.write_uint16_z(uint16(s->pulses[i]));
			i++; continue;
		}
		case TZX_CSW_RECORDING: // TODO
		{
			if (verbose>=2) logline("write TZX CSW RECORDING");
			TzxCswRecording* s = dynamic_cast<TzxCswRecording*>(segments[i].ptr());

			Array<int8> samples;	// signed int8 samples, mono

			cstr ext = lowerstr(extension_from_path(s->filename));
			if(eq(ext,".wav"))
			{
				WavFile wf(s->filename);
				assert(wf.is_valid);
				wf.seekFramePosition(uint32(s->first_frame));
				wf.readFrames(samples, uint32(s->last_frame) - uint32(s->first_frame), WavFile::FrameFormat::MONO);
			}
			else
			{
				FD fd(s->filename);
				fd.seek_fpos(uint32(s->header_size) + uint32(s->first_frame) * s->sample_size * s->num_channels);

				uint32 num_samples = uint32(s->last_frame - s->first_frame) * s->num_channels;

				if(s->sample_size == 1)
				{
					samples.grow(num_samples);
					fd.read_bytes(samples.getData(),num_samples);
					if(!s->signed_samples)
					{
						int8* z = samples.getData();
						const uint8* q = reinterpret_cast<const uint8*>(z);
						convert_audio(q, z, samples.count());
					}
				}
				else
				{
					assert(s->sample_size == 2);

					Array<int16> words(num_samples);
					if(s->little_endian) fd.read_data_z(words.getData(),num_samples);
					else				 fd.read_data_x(words.getData(),num_samples);
					if(!s->signed_samples) convert_audio(reinterpret_cast<Array<uint16>&>(words),words);
					convert_audio(words,samples);
				}

				if(s->num_channels == 2)
				{
					Array<int8> z(std::move(samples));
					stereo_to_mono(z,samples);
				}
			}

			uint32 num_pulses = samples.count();
			Array<uint8> csw(0u,num_pulses/8);

			for(uint32 j=0; j<num_pulses;)
			{
				uint32 j0 = j++;
				int8 s0 = samples[j0];
				while(j<num_pulses && (s0^samples[j]) >= 0) { j++; }

				uint32 n = j - j0;
				if(n<=255) { csw.append(uint8(n)); }
				else { csw.append(0u); uint8 bu[4]; poke4Z(bu,n); csw.append(bu,4); }
			}

			if(s->compressed)
			{
				Array<uint8> zbu(csw.count());
				ulong zlen = zbu.count();
				int err = compress(zbu.getData(), &zlen, csw.getData(), csw.count());
				if(err == Z_OK) { assert(zlen<=zbu.count()); zbu.shrink(uint(zlen)); std::swap(csw,zbu); }
				else
				{
					s->compressed = no;
					if(verbose) xlogline("#TZX CSW \"%s\": not compressed. compression increased size", s->filename);
				}
			}

			// Note: we do not know what the 'current pulse' is
			// => the CSW audio may be loaded inverted.
			//    therefore we write a TZX_SET_POLARITY first:

			fd.write_uint8(TZX_POLARITY);
			fd.write_uint32_z(1);					// block length
			fd.write_uint8(samples[0] >= 0);		// 1 = high = sample>=0

			fd.write_uint8(TZX_CSW_RECORDING);
			fd.write_uint32_z(10 + csw.count());	// blen
			fd.write_uint16_z(uint16(s->pause));	// pause
			fd.write_uint24_z(s->sample_rate);		// samples per second
			fd.write_char(s->compressed?2:1);		// 1:RLE, 2:Z-RLE
			fd.write_uint32_z(num_pulses);			// num. pulses after decompression
			fd.write_bytes(csw.getData(),csw.count());	// data[]

			i++; continue;
		}
		case TZX_PAUSE:
		{
			if (verbose>=2) logline("write TZX PAUSE");
			TzxPauseSegment* s = dynamic_cast<TzxPauseSegment*>(segments[i].ptr());
			fd.write_uint8(TZX_PAUSE);
			fd.write_uint16_z(uint16(s->duration));
			i++; continue;
		}
		case TZX_GROUP_START:
		{
			if (verbose>=2) logline("write TZX GROUP START");
			TzxGroupStartSegment* s = dynamic_cast<TzxGroupStartSegment*>(segments[i].ptr());
			fd.write_uint8(TZX_GROUP_START);
			uint8 len = uint8(strlen(s->groupname));
			fd.write_uint8(len);
			fd.write_bytes(s->groupname,len);
			i++; continue;
		}
		case TZX_GROUP_END:
		{
			if (verbose>=2) logline("write TZX GROUP END");
			fd.write_uint8(TZX_GROUP_END);
			i++; continue;
		}
		case TZX_LOOP_START:
		{
			if (verbose>=2) logline("write TZX LOOP START");
			TzxLoopStartSegment* s = dynamic_cast<TzxLoopStartSegment*>(segments[i].ptr());
			fd.write_uint8(TZX_LOOP_START);
			fd.write_uint16_z(uint16(s->repetitions));
			i++; continue;
		}
		case TZX_LOOP_END:
		{
			if (verbose>=2) logline("write TZX LOOP END");
			fd.write_uint8(TZX_LOOP_END);
			i++; continue;
		}
		case TZX_STOP_48K:
		{
			if (verbose>=2) logline("write TZX STOP 48K");
			fd.write_uint8(TZX_STOP_48K);
			fd.write_uint32_z(0);		// block length
			i++; continue;
		}
		case TZX_POLARITY:
		{
			if (verbose>=2) logline("write TZX POLARITY");
			TzxPolaritySegment* s = dynamic_cast<TzxPolaritySegment*>(segments[i].ptr());
			fd.write_uint8(TZX_POLARITY);
			fd.write_uint32_z(1);		// block length
			fd.write_uint8(uint8(s->polarity));
			i++; continue;
		}
		case TZX_INFO:
		{
			if (verbose>=2) logline("write TZX INFO");
			fd.write_uint8(TZX_INFO);
			TzxInfoSegment* s = dynamic_cast<TzxInfoSegment*>(segments[i].ptr());
			uint8 len = uint8(strlen(s->text));
			fd.write_uint8(len);
			fd.write_bytes(s->text,len);
			i++; continue;
		}
		case TZX_MESSAGE:
		{
			if (verbose>=2) logline("write TZX MESSAGE");
			fd.write_uint8(TZX_MESSAGE);
			TzxMessageSegment* s = dynamic_cast<TzxMessageSegment*>(segments[i].ptr());
			fd.write_uint8(uint8(s->duration));
			cstr msg = join(s->text,0x0D);
			uint8 len = uint8(strlen(msg));
			fd.write_uint8(len);
			fd.write_bytes(msg,len);
			i++; continue;
		}
		case TZX_ARCHIVE_INFO:
		{
			if (verbose>=2) logline("write TZX ARCHIVE INFO");
			fd.write_uint8(TZX_ARCHIVE_INFO);
			TzxArchiveInfo* s = dynamic_cast<TzxArchiveInfo*>(segments[i].ptr());
			uint8 cnt = uint8(s->archinfo.count());
			uint16 totl = 1 + 2*cnt;
			for (uint i=0; i<s->archinfo.count(); i++) { totl += strlen(s->archinfo[i].text); }
			fd.write_uint16_z(totl);
			fd.write_uint8(cnt);
			for (uint i=0; i<s->archinfo.count(); i++)
			{
				TzxArchiveInfo::ArchInfo& info = s->archinfo[i];
				fd.write_uint8(info.id);
				cnt = uint8(strlen(info.text));
				fd.write_uint8(cnt);
				fd.write_bytes(info.text,cnt);
			}
			i++; continue;
		}
		case TZX_HARDWARE_INFO:
		{
			if (verbose>=2) logline("write TZX HARDWARE INFO");
			fd.write_uint8(TZX_HARDWARE_INFO);
			TzxHardwareInfo* s = dynamic_cast<TzxHardwareInfo*>(segments[i].ptr());
			fd.write_uint8(uint8(s->hwinfo.count()));
			for (uint i=0; i<s->hwinfo.count(); i++)
			{
				fd.write_bytes(&s->hwinfo,3);
			}
			i++; continue;
		}

		case CODE:
		case TZX_STANDARD:
		case TZX_TURBO:
		case TZX_PURE_DATA:
		case TZX_GENERALIZED: break;
		}

		CodeSegment* s = dynamic_cast<CodeSegment*>(segments[i].ptr());
		assert(s->has_flag);
		uint8 flagbyte = uint8(s->flag);
		uint16 pause = uint16(s->pause);
		bool no_checksum = s->no_checksum;
		bool no_flagbyte = s->no_flagbyte;
		bool checksum_ace = s->checksum_ace;

		// calc. size of tape block:
		uint32 size = 0;
		do { size += s->outputSize(); }
		while (++i<segments.count() && segments[i]->isCode() &&
			   !(s=dynamic_cast<CodeSegment*>(segments[i].ptr()))->has_flag);
		s = dynamic_cast<CodeSegment*>(segments[a].ptr());
		uint32 sizepp = size + !no_flagbyte + !no_checksum;	// size incl. flag and checksum byte

		switch(s->type)
		{
		default: IERR();

		case TZX_STANDARD:
			if (verbose>=2) logline("write TZX STANDARD block %s",s->name);
			//	dw	Pause after this block (ms.) {1000}
			//	dw	Length of data that follow
			//	dm	BYTE[N]	Data as in .TAP files
			fd.write_uint8(0x10);
			fd.write_uint16_z(pause);
			fd.write_uint16_z(uint16(sizepp));
			break;

		case TZX_TURBO:
			if (verbose>=2) logline("write TZX TURBO block %s",s->name);
			// WORD	Length of PILOT pulse {2168}
			// WORD	Length of SYNC first pulse {667}
			// WORD	Length of SYNC second pulse {735}
			// WORD	Length of ZERO bit pulse {855}
			// WORD	Length of ONE bit pulse {1710}
			// WORD	Length of PILOT tone (number of pulses) {8063 header (flag<128), 3223 data (flag>=128)}
			// BYTE	Used bits in the last byte (other bits should be 0) {8}
			//		(e.g. if this is 6, then the bits used (x) in the last byte are: xxxxxx00, where MSb is the leftmost bit, LSb is the rightmost bit)
			// WORD		Pause after this block (ms.) {1000}
			// BYTE[3]	Length of data that follow
			// BYTE[N]	Data as in .TAP files
			fd.write_uint8(0x11);
			fd.write_uint16_z(uint16(s->pilotsym[0][1]));	// length of pilote pulse
			fd.write_uint16_z(uint16(s->pilotsym[1][1]));	// length of sync1 pulse
			fd.write_uint16_z(uint16(s->pilotsym[1][2]));	// length of sync2 pulse
			fd.write_uint16_z(uint16(s->datasym[0][1]));	// length of data bit0 pulse
			fd.write_uint16_z(uint16(s->datasym[1][1]));	// length of data bit1 pulse
			fd.write_uint16_z(uint16(s->pilot[1]));			// pilot pulse count
			fd.write_uint8(uint8(s->lastbits));				// used bits in last byte
			fd.write_uint16_z(pause);
			fd.write_uint24_z(sizepp);
			break;

		case TZX_PURE_DATA:
			if (verbose>=2) logline("write TZX PURE DATA block %s",s->name);
			// WORD	Length of ZERO bit pulse
			// WORD	Length of ONE bit pulse
			// BYTE	Used bits in last byte (other bits should be 0)
			//		(e.g. if this is 6, then the bits used (x) in the last byte are: xxxxxx00, where MSb is the leftmost bit, LSb is the rightmost bit)
			// WORD		Pause after this block (ms.)
			// BYTE[3]	Length of data that follow
			// BYTE[N]	Data as in .TAP files
			fd.write_uint8(0x14);
			fd.write_uint16_z(uint16(s->datasym[0][1]));	// length of data bit0 pulse
			fd.write_uint16_z(uint16(s->datasym[1][1]));	// length of data bit1 pulse
			fd.write_uint8(uint8(s->lastbits));				// used bits in last byte
			fd.write_uint16_z(pause);
			fd.write_uint24_z(sizepp);
			break;

		case TZX_GENERALIZED:
			if (verbose>=2) logline("write TZX GENERALIZED block %s",s->name);
			// DWORD	TOTL = Block length (without these four bytes)
			// WORD		pause = Pause after this block (ms)
			// DWORD	TOTP = Number of symbols in pilot[] (can be 0)
			// BYTE		NPP = Maximum number of pulses per pilot symbol
			// BYTE		ASP = Number of symbols in pilotsym[] table (0=256)
			// DWORD	TOTD = Number of symbols in data[] (can be 0)
			// BYTE		NPD = Maximum number of pulses per data symbol
			// BYTE		ASD	= Number of symbols in datasym[] table (0=256)
			// SYMDEF[ASP]	Pilot and sync symbols definition table	(only if TOTP>0)
			// PRLE[TOTP]	Pilot and sync data stream				(only if TOTP>0)
			// SYMDEF[ASD]	Data symbols definition table			(only if TOTD>0)
			// DATA[size]	Data stream								(only if TOTD>0)

			uint	asp  = s->pilotsym.count();
			uint	asd	 = s->datasym.count();
			uint	npp  = 0; for (uint i=0; i<asp; i++) { npp = max(npp,s->pilotsym[i].count()-1); }
			uint	npd  = 0; for (uint i=0; i<asd; i++) { npd = max(npd,s->datasym[i].count()-1); }

			uint32	totp = s->pilot.count() / 2;
			uint32	totd = asd==2 ? sizepp<<3 : asd==4 ? sizepp<<2 : asd==16 ? sizepp<<1 : sizepp;
			uint32	totl = 14 + (totp ? totp*3 + asp*(1+2*npp) : 0) + (totd ? sizepp + asd*(1+2*npd) : 0);

			fd.write_uint8(0x19);
			fd.write_uint32_z(totl);
			fd.write_uint16_z(pause);
			fd.write_uint32_z(totp);
			fd.write_uint8(uint8(npp));
			fd.write_uint8(uint8(asp));
			fd.write_uint32_z(totd);
			fd.write_uint8(uint8(npd));
			fd.write_uint8(uint8(asd));

			if (totp)	// SYMDEF[] and PRLE[]
			{
				for (uint i=0; i<asp; i++)
				{
					Values& symbol = s->pilotsym[i];
					uint j=0;
					fd.write_uint8(uint8(symbol[j++]));
					while (j < symbol.count()) { fd.write_uint16_z(uint16(symbol[j++])); }
					while (j < npp+1) { fd.write_uint16(0); j++; }
				}
				for (uint i=0; i<s->pilot.count(); i+=2)
				{
					fd.write_uint8(uint8(s->pilot[i]));
					fd.write_uint16_z(uint16(s->pilot[i+1]));
				}
			}

			if (totd)	// SYMDEF[] and DATA[]
			{
				for (uint i=0; i<asd; i++)
				{
					Values& symbol = s->datasym[i];
					uint j=0;
					fd.write_uint8(uint8(symbol[j++]));
					while (j < symbol.count()) { fd.write_uint16_z(uint16(symbol[j++])); }
					while (j < npd+1) { fd.write_uint16(0); j++; }
				}
			}

			break;
		}

		// write flagbyte
		if (!no_flagbyte) fd.write_uint8(flagbyte);
		uint8 checksum = no_flagbyte || checksum_ace ? 0 : flagbyte;

		// write data and calc checksum
		i=a; s = dynamic_cast<CodeSegment*>(segments[i].ptr());
		do
		{
			uint8 const* qa = s->outputData();
			uint32 size = s->outputSize();
			fd.write_bytes(qa,size);
			for (uint8 const* q = qa+size; q>qa; ) checksum ^= *--q;
		}
		while (++i<segments.count() && segments[i]->isCode() &&
			   !(s=dynamic_cast<CodeSegment*>(segments[i].ptr()))->has_flag);

		//write checksum
		if (!no_checksum) fd.write_uint8(checksum);
	}
}


/* ==============================================================
		check segments[] for #target
============================================================== */

void Z80Assembler::checkTargetfile () throws
{
	// Prevent empty output:
	if (CodeSegments(segments).totalCodeSize()==0) throw SyntaxError("code size = 0");

	switch(target)
	{
	case TARGET_UNSET:
	case ROM:
	case BIN: return checkBinFile();
	case SNA: return checkSnaFile();
	case Z80: return checkZ80File();
	case ACE: return checkAceFile();
	case TZX: return checkTzxFile();
	case TAP: return checkTapFile();
	case ZX80: return checkZX80File();
	case ZX81P:
	case ZX81: return checkZX81File();
	}
	throw SyntaxError("internal error: checkTargetfile: unknown target");
}

void Z80Assembler::checkTapFile () throws
{
	// Check segments[] for target "TAP":
	// Segments are either a tape block on their own and have their tape block flag defined
	//   or they are a sequence of multiple segments which are to be joined into a single tape block.
	// Then only the first segment has a flag.
	// The following segments without flag byte are appended to the preceding tape block
	//   regardless of their physical address.
	// It is assumed that the program will move them to the declared physical address.
	// This is similar to concatenating segments with non-consecutive physical address in bin and rom files.

	CodeSegments segments(this->segments);
	while (segments[0]->size==0 && !segments[0]->has_flag) { segments.remove(0u); }

	if (!segments[0]->has_flag)
		throw SyntaxError("tape block %s: flag byte missing (argument #4)", segments[0]->name);

	uint32 size = 0;
	for (uint i=segments.count(); i--; )
	{
		CodeSegment* s = segments[i];
		size += s->outputSize();
		if (!s->has_flag) continue;	// not first segment

		if (!s->no_flagbyte && (s->flag > 255 || s->flag < -128))
			throw SyntaxError("tape block %s: flag byte out of range", s->name);

		if (size == 0) throw SyntaxError("tape block %s: size = 0", s->name);
		if (size > 0xfeff) throw SyntaxError("tape block %s: size = %u (max = 0xfeff)", s->name, size);
		size = 0;
	}
}

// Helpers for TZX:
static cValue v0(0), v1(1);
static const Values zxsp_pilot0(std::move(Values()<<v0<<Value(2168)));				// standard zxsp pilot pulses
static const Values zxsp_pilot1(std::move(Values()<<v0<<Value(667)<<Value(735)));	// standard zxsp syn pulses
static const Values zxsp_data0(std::move(Values()<<v0<<Value(855)<<Value(855)));
static const Values zxsp_data1(std::move(Values()<<v0<<Value(1710)<<Value(1710)));

static Values simple_pilot(int num_pulses)
{
	return Values() << v0 << Value(num_pulses) << v1 << v1;
}

static bool is_simple_data_symbol(Values const& symbol)
{
	return symbol.count() == 3 && symbol[0] == 0 && symbol[1] == symbol[2];
}
static bool is_simple_data_symbols(Array<Values> const& symbols)
{
	return symbols.count() == 0 ||
		(symbols.count() == 2 && is_simple_data_symbol(symbols[0]) && is_simple_data_symbol(symbols[1]));
}
static bool is_simple_pilot(Values const& pilot)
{
	return pilot.count() == 0 || (pilot.count() == 4 && pilot == simple_pilot(pilot[1]));
}
static bool is_simple_pilot_symbols(Array<Values> const& symbols)
{
	return symbols.count() == 0 ||
		(symbols.count() == 2 &&
		(symbols[0].count() == 2 && symbols[0][0] == 0) &&	// pilot pulse
		(symbols[1].count() == 3 && symbols[1][0] == 0));	// sync pulses
}
static bool is_simple_pilot_scheme(Values const& pilot, Array<Values> const& symbols)
{
	return is_simple_pilot_symbols(symbols) && is_simple_pilot(pilot);
}
static bool is_zxsp_pilot_scheme(Values const& pilot, Array<Values> const& symbols, int flag)
{
	static const Array<Values> zxsp_pilot_symbols(std::move(Array<Values>() << zxsp_pilot0 << zxsp_pilot1));
	return (symbols.count() == 0 || symbols == zxsp_pilot_symbols) &&
		   (pilot.count() == 0 || (pilot.count() == 4 && pilot == simple_pilot(flag&0x80?3223:8063)));
}
static bool is_zxsp_data_symbols(Array<Values> const& symbols)
{
	static const Array<Values> zxsp_data_symbols(std::move(Array<Values>() << zxsp_data0 << zxsp_data1));
	return symbols.count() == 0 || symbols == zxsp_data_symbols;
}

static void	set_default_pilot(CodeSegment* s)
{
	if (s->checksum_ace)
	{
		static const Values pilot0(std::move(Values()<<v0<<Value(2011)));				// pilot pulse
		static const Values pilot1(std::move(Values()<<v0<<Value(601)<<Value(793)));	// sync pulses

		if (s->pilot.count() == 0) s->pilot = simple_pilot(s->flag&0x80 ? 1024 : 8192);
		if (s->pilotsym.count() == 0) s->pilotsym << pilot0;
		if (s->pilotsym.count() == 1) s->pilotsym << pilot1;
	}
	else	// zx spectrum
	{
		if (s->pilot.count() == 0) s->pilot = simple_pilot(s->flag&0x80 ? 3223 : 8063);
		if (s->pilotsym.count() == 0) s->pilotsym << zxsp_pilot0;
		if (s->pilotsym.count() == 1) s->pilotsym << zxsp_pilot1;
	}
}
static void set_default_data_symbols(CodeSegment* s)
{
	if (s->datasym.count() == 0)
	{
		if (s->checksum_ace)
		{
			static const Values data0(std::move(Values()<<v0<<Value(795)<<Value(801)));
			static const Values data1(std::move(Values()<<v0<<Value(1585)<<Value(1591)));
			s->datasym << data0 << data1;
		}
		else	// zx spectrum
		{
			s->datasym << zxsp_data0 << zxsp_data1;
		}
	}
}

void Z80Assembler::checkTzxFile () throws
{
	// Check segments[] for target "TZX":

	// move archive info and hardware info to start of file.
	// check for redefinition

	for (uint i=1; i<segments.count(); i++)
	{
		if (segments[i]->type == TZX_HARDWARE_INFO) segments.ror(0,i+1);
	}
	for(uint i=1; i<segments.count(); i++)
	{
		if (segments[i]->type==TZX_ARCHIVE_INFO) segments.ror(0,i+1);
	}
	if (segments.count() >= 2)
	{
		bool f1 = segments[0]->type == TZX_ARCHIVE_INFO;
		bool f2 = segments[1]->type == TZX_ARCHIVE_INFO;
		if (f1 && f2) throw SyntaxError("multiple TZX archive info blocks");

		if (segments.count() >= 2u+f1)
		{
			bool f3 = segments[0+f1]->type == TZX_HARDWARE_INFO;
			bool f4 = segments[1+f1]->type == TZX_HARDWARE_INFO;
			if (f3 && f4) throw SyntaxError("multiple TZX hardware info blocks");
		}
	}

	// move all non-code and non-tzx segments to start for easy skipping

	for (uint i=segments.count(); --i; )
	{
		if (segments[i]->isData()) segments.ror(0,i+1);
	}

	// check non-code TZX segments:

	Array<cstr> blocks;
	TzxSegments tzxsegments(segments);
	for (uint i=0; i<tzxsegments.count(); i++)
	{
		TzxSegment* tzxseg = tzxsegments[i];

		switch(tzxseg->type)
		{
		case TZX_PURE_TONE:
		{
			TzxPureToneSegment* s = dynamic_cast<TzxPureToneSegment*>(tzxseg);
			if (s->num_pulses <= 0 || s->num_pulses > 0xffff )
				throw SyntaxError("TZX pure tone: invalid num pulses");
			if (s->pulse_length <= 0 || s->pulse_length > 0xffff )
				throw SyntaxError("TZX pure tone: invalid pulse length");
			break;
		}
		case TZX_PULSES:
		{
			TzxPulses* s = dynamic_cast<TzxPulses*>(tzxseg);
			if (s->count == 0 || s->count > 255)
				throw SyntaxError("TZX pulses: invalid num pulses");
			for (uint i=0; i<s->count; i++)
				if (s->pulses[i] <= 0 || s->pulses[i] > 0xffff)
					throw SyntaxError("TZX pulses: invalid pulse");
			break;
		}
		case TZX_CSW_RECORDING:	// TODO
		{
			// cstr	 filename;
			// Value pause;
			// bool	 compressed;
			// Value start_offset;		0 = default
			// Value end_offset;		0 = default
			// uint	 sample_rate;		or from .wav header
			// uint	 num_channels;		or from .wav header
			// uint	 sample_size;		or from .wav header
			// bool	 signed_samples;	or from .wav header
			// bool	 little_endian;		or from .wav header

			TzxCswRecording* s = dynamic_cast<TzxCswRecording*>(tzxseg);

			cstr filename = basename_from_path(s->filename);
			cstr ext = lowerstr(extension_from_path(s->filename));

			int32 total_frames;
			off_t filesize = file_size(s->filename);

			if (filesize > (1<<30))
				throw SyntaxError("TZX CSW \"%s\": file too long", filename);

			if (eq(ext,".wav"))
			{
				WavFile wf(s->filename);
				if (!wf.is_valid) throw SyntaxError("TZX CSW \"%s\": unknown wav format: rename file and "
													 "set sample-rate, sample-format and channels", filename);
				if (s->sample_rate || s->sample_size || s->num_channels)
					throw SyntaxError("TZX CSW \"%s\": sample-rate, sample-format or channels set", filename);

				s->header_size = int32(wf.data_start);
				s->sample_rate = wf.frames_per_second;
				s->sample_size = wf.bits_per_sample / 8;
				s->num_channels = wf.num_channels;
				total_frames = int32(wf.total_frames);
			}
			else	// raw
			{
				assert(s->raw);

				if (!s->sample_rate || !s->sample_size || !s->num_channels)
					throw SyntaxError("TZX CSW %s: sample rate, size or num channels not set", filename);

				if (s->sample_rate<8000 || s->sample_rate>200000)
					throw SyntaxError("TZX CSW %s: sample rate out of range", filename);

				if (s->sample_size!=1 && s->sample_size!=2)
					throw SyntaxError("TZX CSW %s: illegal sample size", filename);

				if (s->num_channels!=1 && s->num_channels!=2)
					throw SyntaxError("TZX CSW %s: illegal number of channels", filename);

				if (s->header_size < 0 || s->header_size > (1<<30))
					throw SyntaxError("TZX CSW %s: header size out of range", filename);

				total_frames = int32(filesize - s->header_size) / int32(s->sample_size * s->num_channels);
				if(total_frames < 0) throw SyntaxError("TZX CSW %s: file too short", filename);
			}

			s->last_frame.value = min(total_frames, s->last_frame.value);

			if(s->pause < 0 || s->pause > 0xffff) throw SyntaxError("TZX CSW %s: pause out of range", filename);
			if (s->first_frame < 0) throw SyntaxError("TZX CSW %s: start < 0", filename);
			if (s->first_frame >= total_frames) throw SyntaxError("TZX CSW %s: start ≥ file end", filename);
			if (s->first_frame >= s->last_frame) throw SyntaxError("TZX CSW %s: start ≥ end", filename);

			break;
		}
		case TZX_PAUSE:
		{
			TzxPauseSegment* s = dynamic_cast<TzxPauseSegment*>(tzxseg);
			if (s->duration < 0 || s->duration > 0xffff)
				throw SyntaxError("TZX pause: illegal duration");
			break;
		}
		case TZX_GROUP_START:
		{
			TzxGroupStartSegment* s = dynamic_cast<TzxGroupStartSegment*>(tzxseg);
			if (!s->groupname || !*s->groupname) throw SyntaxError("TZX group start: no name");
			blocks.append(s->groupname);
			break;
		}
		case TZX_GROUP_END:
		{
			if (blocks.count()==0) throw SyntaxError("TZX group end: not in TZX group");
			if (blocks.pop() == nullptr) throw SyntaxError("TZX group end: in TZX loop");
			break;
		}
		case TZX_LOOP_START:
		{
			TzxLoopStartSegment* s = dynamic_cast<TzxLoopStartSegment*>(tzxseg);
			if (s->repetitions<2 || s->repetitions>0xffff) throw SyntaxError("TZX loop start: illegal repetitions");
			blocks.append(s->name);
			break;
		}
		case TZX_LOOP_END:
		{
			if (blocks.count()==0) throw SyntaxError("TZX loop end: not in TZX loop");
			if (blocks.pop() != nullptr) throw SyntaxError("TZX loop end: in TZX group");
			break;
		}
		case TZX_STOP_48K:
		{
			break;
		}
		case TZX_POLARITY:
		{
			TzxPolaritySegment* s = dynamic_cast<TzxPolaritySegment*>(tzxseg);
			if (s->polarity != 0 && s->polarity != 1) throw SyntaxError("TZX polarity: illegal value");
			break;
		}
		case TZX_INFO:
		{
			TzxInfoSegment* s = dynamic_cast<TzxInfoSegment*>(tzxseg);
			if (!s->text || !*s->text) throw SyntaxError("TZX info: no text");
			if (strlen(s->text) > 32) throw SyntaxError("TZX info: text too long");
			// test for ASCII: verified when created
			break;
		}
		case TZX_MESSAGE:
		{
			TzxMessageSegment* s = dynamic_cast<TzxMessageSegment*>(tzxseg);
			if (s->text.count()==0 || s->text.count()>8) throw SyntaxError("TZX message: too many lines");
			if (strlen(join(s->text,' '))>255) throw SyntaxError("TZX message: total text length too long");
			// test for ASCII: verified when created
			break;
		}
		case TZX_ARCHIVE_INFO:
		{
			TzxArchiveInfo* s = dynamic_cast<TzxArchiveInfo*>(tzxseg);
			if (s->archinfo.count()==0) throw SyntaxError("TZX archive info: empty");
			if (s->archinfo.count()>255) throw SyntaxError("TZX archive info: to many entries");
			for (uint i=0; i<s->archinfo.count(); i++)
			{
				auto& info = s->archinfo[i];
				if (info.id>0x10 && info.id!=255) throw SyntaxError("TZX archive info: illegal ID");
				if (eq(info.text,"")) throw SyntaxError("TZX archive info: empty text");
				if (strlen(info.text)>255) throw SyntaxError("TZX archive info: text too long");
			}
			break;
		}
		case TZX_HARDWARE_INFO:
		{
			TzxHardwareInfo* s = dynamic_cast<TzxHardwareInfo*>(tzxseg);
			Array<TzxHardwareInfo::HwInfo>& hwinfo = s->hwinfo;
			if (hwinfo.count()==0) throw SyntaxError("TZX hardware info: empty");
			if (hwinfo.count()>255) throw SyntaxError("TZX hardware info: to many entries");

			for (uint i=0; i<hwinfo.count(); i++)
			{
				auto& info = hwinfo[i];
				if (info.type>0x20 || info.id>0x80 || info.support>3)
					throw SyntaxError("TZX hardware info: illegal value");
			}

			// test for redefined entries:
			hwinfo.sort();
			for (uint i=1; i<hwinfo.count(); i++)
			{
				auto& a = hwinfo[i];
				auto& b = hwinfo[i-1];
				if (a.type == b.type && a.id == b.id)
				{
					if (a.support != b.support)
						throw SyntaxError("TZX hardware info: entry %u,%u redefined", a.type, a.id);
					if (verbose) logline("TZX hardware info: multiple definitions for %u,%u", a.type, a.id);
				}
			}
			break;
		}
		default: IERR();
		}
	}

	// check code and tzx segment mix:
	// there must be no tzx blocks between code blocks which are concatenated for one tape block:

	cstr cs0_name = nullptr;
	for (uint i=1; i<segments.count(); i++ )
	{
		if (auto cs = dynamic_cast<CodeSegment*>(segments[i].ptr()))
		{
			if (cs->has_flag)
				cs0_name = cs->name;
			else if(segments[i-1]->is_tzx)
				if (cs0_name) throw SyntaxError("non-code TZX block in tape block %s",cs0_name);
		}
	}

	// Check code segments:

	CodeSegments segments(this->segments);
	while (segments[0]->size==0 && !segments[0]->has_flag) { segments.remove(0u); }

	if (!segments[0]->has_flag)
		throw SyntaxError("tape block %s: flag byte missing (argument #4)", segments[0]->name);

	uint32 size = 0;
	for (uint i=segments.count(); i--; )
	{
		CodeSegment* s = segments[i];
		size += s->outputSize();
		if (!s->has_flag) continue;	// not first segment

		if (!s->has_lastbits) s->lastbits = 8;
		if (s->no_flagbyte) s->flag = s->core[0];
		if (!s->has_pause) s->setPause(Value(s->flag & 0x80 ? 2000 :		// data block
											 s->checksum_ace ? 2 : 1000));	// header

		// choose best TZX block for CODE segments:
		if (s->type == CODE)
		{
			if (is_simple_data_symbols(s->datasym) &&
				is_simple_pilot_scheme(s->pilot,s->pilotsym))
			{
				if (s->no_pilot)
					s->type = TZX_PURE_DATA;
				else if (s->checksum_ace)	// note: if Jupiter Ace is indicated,
					s->type = TZX_TURBO;	// then TZX_TURBO uses an approximation of the Jupiter ACE timing
				else
					s->type = is_zxsp_data_symbols(s->datasym) &&
							  is_zxsp_pilot_scheme(s->pilot,s->pilotsym,s->flag) ?
						TZX_STANDARD : TZX_TURBO;
			}
			else
			{
				s->type = TZX_GENERALIZED;
			}
		}

		try
		{
			uint minsz = s->no_checksum + s->no_flagbyte;
			if (size <= minsz) throw SyntaxError("size = 0");
			if (size > minsz+0xfeff) throw SyntaxError("size = %u (max = 0xfeff)", size-minsz);
			size = 0;

			assert(s->lastbits>=1 && s->lastbits<=8);
			if (s->flag > 255 || s->flag < -128) throw SyntaxError("flag byte out of range");
			if (uint(s->pause) > 0xffff) throw SyntaxError("pause out of range");

			// check pilot and data pulses:
			if (s->type == TZX_STANDARD)
			{
				if (s->no_pilot) throw SyntaxError("invalid pilot=none");
				if (s->lastbits != 8) throw SyntaxError("invalid lastbits=%i",int(s->lastbits));
				if (!is_zxsp_data_symbols(s->datasym)) throw SyntaxError("invalid data pulses");
				if (!is_zxsp_pilot_scheme(s->pilot,s->pilotsym,s->flag)) throw SyntaxError("invalid pilot pulses");
			}
			else if (s->type == TZX_TURBO)
			{
				if (s->no_pilot) throw SyntaxError("invalid pilot=none");
				if (!is_simple_data_symbols(s->datasym)) throw SyntaxError("invalid data pulses");
				if (!is_simple_pilot_scheme(s->pilot,s->pilotsym)) throw SyntaxError("invalid pilot pulses");

				set_default_data_symbols(s);
				set_default_pilot(s);
			}
			else if (s->type == TZX_PURE_DATA)
			{
				assert(s->no_pilot);
				if (!is_simple_data_symbols(s->datasym)) throw SyntaxError("invalid data pulses");

				set_default_data_symbols(s);
			}
			else if (s->type == TZX_GENERALIZED)
			{
				uint n = s->datasym.count();
				if (n!=0 && n!=2 && n!=4 && n!=16 && n!=256)
					throw SyntaxError("invalid number of data symbols = %u", n);

				if (n==0 && !(size==0 && s->no_flagbyte && s->no_checksum))
					set_default_data_symbols(s);

				if (n > 2 && s->lastbits % (n==4 ? 2 : n==16 ? 4 : 8))
					throw SyntaxError("invalid lastbits=%u for %u data symbols", uint(s->lastbits), n);

				// check data symbols:
				for (uint i=0; i<s->datasym.count(); i++)
				{
					Values& ds = s->datasym[i];
					if (ds.count() > 256) throw SyntaxError("data symbol #%u: too many pulses", i);
					if (uint(ds[0]) > 3) throw SyntaxError("data symbol #%u: invalid toggle mode", i);
					for (uint j=1; j<ds.count(); j++)
						if (uint(ds[j]) > 0xffff)
							throw SyntaxError("data symbol #%u: invalid pulse length %i", i, int(ds[j]));
				}

				if (s->no_pilot)
				{
					assert(s->pilot.count() == 0);
					assert(s->pilotsym.count() == 0);
				}
				else
				{
					if (is_simple_pilot(s->pilot))
						set_default_pilot(s);

					// check pilot definition and collect pilot symbol usage:
					Array<bool> used(s->pilotsym.count());
					for (uint i=0; i<s->pilot.count(); i+=2)	// note: up to 2*0xffff entries allowed
					{
						uint idx = uint(s->pilot[i]);			// symbol idx
						if (idx < s->pilotsym.count()) used[idx] = true;
						else throw SyntaxError("pilot symbol #%u used but not defined", idx);

						int rep = s->pilot[i+1];				// repetitions
						if (uint(rep) > 0xffff) throw SyntaxError("pilot #%u: too many repetitions %i", i/2, rep);
					}

					// check pilot symbol definitions and pilot symbol usage:
					for (uint i=0; i<s->pilotsym.count(); i++)
					{
						if (!used[i]) throw SyntaxError("pilot symbol #%u not used", i);
						Values& ps = s->pilotsym[i];
						if (ps.count() > 256) throw SyntaxError("pilot symbol #%u: too many pulses", i);
						if (uint(ps[0]) > 3) throw SyntaxError("pilot symbol #%u: invalid toggle mode", i);
						for (uint j=1; j<ps.count(); j++)
							if (uint(ps[j]) > 0xffff)
								throw SyntaxError("pilot symbol #%u: invalid pulse length %i", i, int(ps[j]));
					}
				}
			}
			else
			{
				IERR();
			}
		}
		catch (SyntaxError& e)
		{
			throw SyntaxError("tape block %s: %s", s->name, e.what());
		}
	}
}

void Z80Assembler::checkBinFile () throws
{
	CodeSegments(segments).checkNoFlagsSet();
}

void Z80Assembler::checkSnaFile () throws
{
	// Check target SNA
	// 48k version only (there is also a rarely used 128k variant)
	// Check header segments are not compressed
	// Addresses of code segments are not checked

	struct SnaHead
	{
		uint8	i;						// $3f
		uint8	l2,h2,e2,d2,c2,b2,a2,f2;
		uint8	j,h,e,d,c,b,yl,yh,xl,xh;
		uint8	iff2;					// bit 2 = iff2 (iff1 before nmi) 0=di, 1=ei
		uint8	r,f,a;
		uint8	spl,sph;
		uint8	int_mode;				// 1
		uint8	border;					// 7	border color: 0=black ... 7=white
	};
	static_assert(sizeof(SnaHead)==27,"sizeof(SnaHead) wrong!");
	typedef SnaHead *SnaHeadPtr;

	const uint i0 = 0;

	CodeSegments segments(this->segments);
	segments.checkNoFlagsSet();

	// verify that first block is the header:
	CodeSegment& hs = segments[i0];
	if (hs.compressed) throw SyntaxError(
		"target SNA: header segment %s cannot be compressed",hs.name);
	if (hs.size!=27) throw SyntaxError(
		"target SNA: header segment %s must be 27 bytes (size=%u)", hs.name, uint(hs.size));
	SnaHead* head = SnaHeadPtr(hs.getData());

	// verify some values from header:
	if ((head->i>>6)==1) setError(
		"segment %s: i register must not be in range [0x40 .. 0x7F] (i=0x%02X)", hs.name, head->i);
	if (head->iff2&~4) setError(
		"segment %s: iff2 byte must be 0 or 4 (iff2=0x%02X)", hs.name, head->iff2);
	uint16 sp = head->spl + 256*head->sph;
	if (sp>0 && sp<0x4002) setError(
		"segment %s: sp register must not be in range [0x0001 .. 0x4001] (sp=0x%04X)", hs.name, sp);
	if (head->int_mode>2) setError(
		"segment %s: interrupt mode must be in range 0 .. 2 (im=%u)", hs.name, head->int_mode);
	if (head->border>7) setError(
		"segment %s: border color byte must not be in range 0 .. 7 (brdr=%u)", hs.name, head->border);
	if (errors.count()) return;

	// verify ram segments:
	uint32 addr = 0x4000;
	for (uint i=i0+1; i<segments.count(); i++)
	{
		CodeSegment& s = segments[i];
		addr += s.outputSize();
		if (addr>0x10000) { setError(
			"segment %s extends beyond ram end (end=0x%05X)", s.name, uint(addr)); break; }
	}
	if (addr<0x10000) setError(
		"target SNA: total ram size must be 0xC000 bytes (size=0x%04X)", uint(addr-0x4000));
}

void Z80Assembler::checkAceFile () throws
{
	// Check target ACE
	// Checks for presence of all the empty pages
	// Checks registers
	// Checks "physical" addresses of header segments
	// Addresses of code segments are not checked
	// Check header segments are not compressed

	struct AceHead
	{
		uint32	flag_8001, z1[0x20-1];
		uint32	ramtop, dda, dba, frame_skip_rate, frames_per_tv_tick, fdfd, time_running, color_mode, z2[0x20-8];
		uint32	af,bc,de,hl,ix,iy,sp,pc,af2,bc2,de2,hl2,im,iff1,iff2,i,r,flag_80, z3[0xC0-18];
	};
	static_assert(sizeof(AceHead)==0x400,"sizeof(AceHead) wrong!");
	typedef AceHead *AceHeadPtr;

	CodeSegments segments(this->segments);
	segments.checkNoFlagsSet();
	uint32 ramsize = segments.totalCodeSize();

	bool ramsize_valid = ramsize==0x2000 || ramsize==0x6000 || ramsize==0xA000;
	if (!ramsize_valid) setError(
		"total ram size must be 0x2000 (3k), 0x6000 (+16k) or 0xA000 (+32k) (size=%u)",uint(ramsize));

	// #code VRAM_COPY,   $2000, $400
	// #code VRAM,        $2400, $400
	// #code CRAM_COPY,   $2800, $400
	// #code CRAM,        $2C00, $400
	// #code RAM_COPIES,  $3000, $C00
	// #code SYSVARS,     $3C00, $40
	// #code RAM,         $3C40, ramsize - $840

	int32 addr = 0x2000;			// current address := ram start
	for (uint i=0; addr<0x3C00; i++)
	{
		CodeSegment& s = segments[i];
		if (s.size==0) continue;		// skip & don't check address

		if (s.address.value!=addr) setError(
			"segment %s must start at 0x%04X (address=0x%04X)", s.name, uint(addr), uint(s.address));
		if (s.compressed) throw SyntaxError(
			"segment %s cannot be compressed",s.name);
		if (s.size&0x3ff) throw SyntaxError(
			"segment %s size must be a multiple of 0x400 (size=0x%04X)", s.name, uint(s.size));

		for (uint32 offs=0; offs<uint32(s.size) && addr<0x3C00; offs+=0x400, addr+=0x400)
		{
			switch (addr)
			{
			case 0x2000:	// VRAM mirror with Z80 registers
			{
				// check empty:
				uint16 zbu[0x200]; memcpy(zbu,&s[offs],0x400);
				for (uint i=0; i<8;  i++) zbu[0x40+2*i]=0;	// clear settings
				for (uint i=0; i<18; i++) zbu[0x80+2*i]=0;	// clear registers
				bool empty=yes; for (int i=1; i<0x200 && empty; i++) { empty = zbu[i]==0; }
				if (!empty) setError("segment %s must be empty except for settings and registers", s.name);

				// check registers:
				void* vp = &s[offs];
				assert(size_t(vp) % sizeof(uint32) == 0);	// to be really really sure, mr. compiler.
				AceHead* head = AceHeadPtr(vp);
				if (peek2Z(&head->flag_8001) != 0x8001) setError("segment %s: segment[0].flag must be 0x8001", s.name);
				uint ramtop = peek2Z(&head->ramtop);
				if (ramsize_valid && ramtop!=0x2000+ramsize) setError(
					"segment %s: settings[0].ramtop != ram end address 0x%04X (ramtop=0x%04X)",
					s.name, 0x2000+uint(ramsize), ramtop);

				uint sp = peek2Z(&head->sp);
				if (sp<0x2002) setError(
					"segment %s: z80_regs[6].sp must not be in range [0x0000 .. 0x2001] (sp=0x%04X)", s.name, sp);
				if (sp>ramtop) setError(
					"segment %s: z80_regs[6].sp points behind settings[0].ramtop (sp=0x%04X, ramtop=0x%04X)",
					s.name, sp, ramtop);
				if (peek2Z(&head->im)>2) setError(
					"segment %s: z80_regs[12].int_mode must be in range 0 .. 2 (im=%u)", s.name, head->im);
				if (peek2Z(&head->iff1)>1) setError(
					"segment %s: z80_regs[13].iff1 must be 0 or 1 (iff1=%u)", s.name, head->iff1);
				if (peek2Z(&head->iff2)>1) setError(
					"segment %s: z80_regs[14].iff2 must be 0 or 1 (iff2=%u)", s.name, head->iff2);
				if (peek2Z(&head->i)>255) setError(
					"segment %s: z80_regs[15].reg_i must be in range 0 .. 0xff (i=%u)", s.name, head->i);
				if (peek2Z(&head->r)>255) setError(
					"segment %s: z80_regs[16].reg_r must be in range 0 .. 0xff (r=%u)", s.name, head->r);
				if (peek2Z(&head->flag_80) != 0x80) setError(
					"segment %s: z80_regs[17].flag must be 0x80", s.name);
				break;
			}

			case 0x2400:	// VRAM
			case 0x2C00:	// CRAM
				break;

			case 0x2800:	// CRAM mirror
			case 0x3000:	// Prog RAM 1st mirror
			case 0x3400:	// Prog RAM 2nd mirror
			case 0x3800:	// Prog RAM 3rd mirror
			{
				void* vp = &s[offs];
				assert(size_t(vp) % sizeof(uint32) == 0);	// to be really really sure, mr. compiler.
				uint32* bu = u32ptr(vp); bool empty=yes;
				for (int i=0; i<0x100 && empty; i++) { empty = bu[i]==0; }
				if (!empty) setError(
					"segment %s: page 0x%04X-0x%04X must be empty", s.name, uint(addr), uint(addr+0x3ff));
				break;
			}
			default:		// Prog RAM
				IERR();
			}
		}
	}
}

void Z80Assembler::checkZX80File () throws
{
	// Check segments for ZX80 targets: O or 80:
	// Checks min. and max. size
	// Checks value of E_LINE
	// Check address of header segment
	// Check header segment is not compressed
	// Segment addresses are not checked
	// Warn if last byte != $80

	struct ZX80Head
	{
	uint8	ERR_NR;		//	db	$FF		;  1  16384 $4000 IY+$00 One less than report code.
	uint8	FLAGS;		//	db	$04		; X1  16385 $4001 IY+$01 Various Flags to control BASIC System:
	uint16	PPC;		//	dw	$FFFE	;  2  16386 $4002 IY+$02 Line number of current line.
	uint16	P_PTR;		//	dw	$434A	; N2  16388 $4004 IY+$04 Position in RAM of [K] or [L] cursor.
	uint16	E_PPC;		//	dw	0		;  2  16390 $4006 IY+$06 Number of current line with [>] cursor.
	uint16	VARS;		//	dw	$4349	; X2  16392 $4008 IY+$08 Address of start of variables area.
	uint16	E_LINE;		//	dw	$434A	; X2  16394 $400A IY+$0A Address of start of Edit Line.
	uint16	D_FILE;		//	dw	$434C	; X2  16396 $400C IY+$0C Start of Display File.
	uint16	DF_EA;		//	dw	$458C	; X2  16398 $400E IY+$0E Address of the start of lower screen.
	uint16	DF_END;		//	dw	$458F	; X2  16400 $4010 IY+$10 Display File End.
	uint8	DF_SZ;		//	db	2		; X1  16402 $4012 IY+$12 Number of lines in lower screen.
	uint8	S_TOPlo, S_TOPhi;	// dw 0	;  2  16403 $4013 IY+$13 The number of first line on screen.
	uint8	X_PTRlo, X_PTRhi;	// dw 0	;  2  16405 $4015 IY+$15 Address of the character preceding the [S] marker.
	uint8	OLDPPClo, OLDPPChi;	// dw 0	;  2  16407 $4017 IY+$17 Line number to which continue jumps.
	uint8	FLAGX;		//	db	0		; N1  16409 $4019 IY+$19 More flags:
	uint16	T_ADDR;		//	dw	$07A2	; N2  16410 $401A IY+$1A Address of next item in syntax table.
	uint16	SEED;		//	dw	0		; U2  16412 $401C IY+$1C The seed for the random number.
	uint16	FRAMES;		//	dw	$7484	; U2  16414 $401E IY+$1E Count of frames shown since start-up.
	uint16	DEST;		//	dw	$4733	; N2  16416 $4020 IY+$20 Address of variable in statement.
	uint16	RESULT;		//	dw	$3800	; N2  16418 $4022 IY+$22 Value of the last expression.
	uint8	S_POSN_X;	//	db	$21		; X1  16420 $4024 IY+$24 Column number for print position.
	uint8	S_POSN_Y;	//	db	$17		; X1  16421 $4025 IY+$25 Line number for print position.
	uint16	CH_ADD;		//	dw	$FFFF	; X2  16422 $4026 IY+$26 Address of next character to be interpreted.
	};
	static_assert(sizeof(ZX80Head)==0x28,"sizeof(ZX80Head) wrong!");
	typedef ZX80Head *ZX80HeadPtr;

	const uint i0 = 0;

	CodeSegments segments(this->segments);
	segments.checkNoFlagsSet();
	uint32 ramsize = segments.totalCodeSize();

	// valid ram size: 1k, 2k, 3k, 4k, 16k
	bool ramsize_valid = ramsize>=sizeof(ZX80Head)+1 && ramsize<=16 kB;
	if (!ramsize_valid) setError(
		"total ram size out of range: must be ≥40+1 ($28+1) and ≤16k (size=$%04X",ramsize);
	if (ramsize<sizeof(ZX80Head)) return;

	CodeSegment& hs = segments[i0];
	if (hs.address != 0x4000) throw SyntaxError(
		"segment %s: first segment must start at $4000",hs.name);
	if (hs.compressed) throw SyntaxError(
		"segment %s: system variables cannot be compressed",hs.name);
	if (hs.size<int(sizeof(ZX80Head))) throw SyntaxError(
		"segment %s: system variables must be at least 40 ($28) bytes (size=%u)",hs.name,uint(hs.size));

	void* vp = hs.getData();
	ZX80Head* head = ZX80HeadPtr(vp);
	uint16 E_LINE = peek2Z(&head->E_LINE);
	if (ramsize_valid && E_LINE != 0x4000+ramsize) setError(
		"segment %s: E_LINE ($400A) must match ram end address $%04X (E_LINE=$%04X)",
		hs.name, 0x4000+uint(hs.size), E_LINE);

	if (verbose)	// last byte of a (clean) file must be 0x80 (last byte of VARS):
	{
		uint i=0;
		while (i<segments.count()) { i++; }
		while (segments[--i]->size==0) {}
		CodeSegment& ls = segments[i];
		if (ls.compressed) logline("segment %s: last byte (last byte of VARS) is not $80", ls.name);
		else if (ls[uint(ls.size)-1] != 0x80) logline("segment %s: last byte (last byte of VARS) is not $80",ls.name);
	}
}

void Z80Assembler::checkZX81File () throws
{
	// Check segments for ZX81 targets: P, 81 or P81:
	// Checks min. and max. size
	// Checks value of E_LINE
	// Currently only one program per file supported, even for P81
	// Check address of header segment
	// Check header segment is not compressed
	// Segment addresses are not checked – may be relocated code!
	// Warn if last byte != $80

	CodeSegments segments(this->segments);

	struct ZX81Head		// SYSVARs $4009++
	{
	uint8 VERSN;			//	0 identifies 8K ZX81 Basic in saved programs.
	uint8 E_PPC,E_PPChi;	//	Number of current line (with program cursor).
	uint8 D_FILE,D_FILEhi;	//	Address of Display File (screen data) in memory.
	uint8 DF_CC,DF_CChi;	//	Address of PRINT position in display file.
	uint8 VARS,VARShi;		//	Address of user program variables in memory.
	uint8 DEST,DESThi;		//	Address of variable in assignment.
	uint8 E_LINE,E_LINEhi;	//	Address of line being editted in memory.
	uint8 CH_ADD,CH_ADDhi;	//	Address of the next character to be interpreted
	uint8 X_PTR,X_PTRhi;	//	Address of the character preceding the [S] marker.
	uint8 STKBOT,STKBOThi;	//	Address of the Calculator stack in memory.
	uint8 STKEND,STKENDhi;	//	End of the Calculator stack.
	uint8 BREG;				//	Calculator’s b register.
	uint8 MEM,MEMhi;		//	Address of area used for calculator’s memory. (Usually MEMBOT but not always.)
	uint8 x1;				//	not used
	uint8 DF_SZ;			//	The number of lines (including one blank line) in the lower part of the screen.
	uint8 S_TOP,S_TOPhi;	//	The number of the top program line in automatic listings.
	uint8 LAST_K,LAST_Khi;	//	Shows which keys pressed
	uint8 x2;				//	Debounce status of keyboard.
	uint8 MARGIN;			//	Number of blank lines above or below picture
	uint8 NXTLIN,NXTLINhi;	//	Address of next program line to be executed.
	uint8 OLDPPC,OLDPPChi;	//	Line number to which CONT jumps.
	uint8 FLAGX;			//	Various flags.
	uint8 STRLEN,STRLENhi;	//	Length of string type designation in assignment.
	uint8 T_ADDR,T_ADDRhi;	//	Address of next item in syntax table (very unlikely to be useful).
	uint8 SEED,SEEHhi;		//	The seed for RND. This is the variable that is set by RAND.
	uint8 FRAMES,FRAMEShi;	//	Counts the frames displayed on the television.
	uint8 CORD_X;			//	x-coordinate of last point PLOTed.
	uint8 CORD_Y;			//	y-coordinate of last point PLOTed.
	uint8 PR_CC;			//	Less significant byte of address of next position for LPRINT to print at.
	uint8 S_POSN_X;			//	Column number for PRINT position.
	uint8 S_POSN_Y;			//	Line number for PRINT position.
	uint8 CDFLAG;			//	Various flags. Bit 7 is on (1) during compute and display (SLOW) mode.
	//PRBUFF ds	33	; Printer buffer (33rd character is ENTER/NEWLINE).
	//MEMBOT ds	30	; Calculator’s memory area; used to store numbers that cannot be put on the calculator stack.
	//		 dw	0	; not used
	};
	static_assert(sizeof(ZX81Head)==125 -9 -65, "sizeof(ZX81Head) wrong!");		// 125 == 0x7D
	typedef ZX81Head *ZX81HeadPtr;

	const uint i0 = 0;
	uint hi = i0;

	segments.checkNoFlagsSet();
	uint32 ramsize = segments.totalCodeSize() +9;

	if (target==ZX81P)
	{
		// first segment must contain the program name only:
		// character set translation must already been done by assembler
		// => prog name: only characters in range 0..63; last char +$80

a:		CodeSegment& s = segments[hi++];
		if (s.compressed) throw SyntaxError("segment %s: program name cannot be compressed",s.name);
		if (s.size==0) goto a;
		if (s.size>128) throw SyntaxError(
			"segment %s: program name too long: max=128 bytes (size=%u)",s.name,uint(s.size));

		uint i = 0;
		while (i<uint(s.size) && s[i]<0x40) i++;
		if (i==uint(s.size)) throw SyntaxError("segment %s: prog name delimiter on last char missing",s.name);
		if (s[i]&0x40) throw SyntaxError("segment %s: ill. character in prog name: (bit6=1)",s.name);
		ramsize -= i+1;
	}

	// valid ram size: sizeof(sysvars)-9+1 .. 16k-9
	bool ramsize_valid = ramsize >= 125+1 && ramsize <= 16 kB;
	if (!ramsize_valid) setError(
		"total ram size out of range: must be ≥125+1 ($7D+1) and ≤16k (size=$%04X)",ramsize);

	CodeSegment& hs = segments[hi];
	if (hs.address != 0x4009) throw SyntaxError(
		"segment %s: first segment must start at $4009",hs.name);
	if (hs.compressed)
		throw SyntaxError("segment %s: system variables cannot be compressed",hs.name);
	if (hs.size < 125-9) throw SyntaxError(
		"segment %s must be at least 125-9 ($7D-9) bytes (size=%u)",hs.name,uint(hs.size));

	void* vp = hs.getData();
	ZX81Head* head = ZX81HeadPtr(vp);
	uint16 E_LINE = peek2Z(&head->E_LINE);
	if (ramsize_valid && E_LINE != 0x4000+ramsize) setError(
		"segment %s: E_LINE must match ram end address $%04X (E_LINE=$%04X)", hs.name, 0x4000+uint(hs.size), E_LINE);

	if (verbose)	// last byte of a (clean) file must be 0x80 (last byte of VARS):
	{
		uint i=0;
		while (i<segments.count()) { i++; }
		while (segments[--i]->size==0) {}
		CodeSegment& ls = segments[i];
		if (ls.compressed) logline("segment %s: last byte (last byte of VARS) is not $80", ls.name);
		else if (ls[uint(ls.size)-1]!=0x80) logline("segment %s: last byte (last byte of VARS) is not $80",ls.name);
	}
}

void Z80Assembler::checkZ80File () throws
{
	// Check segments[] for target Z80

	CodeSegments segments(this->segments);

	// assert header and at least one ram page:
	if (segments.count()<2) throw SyntaxError("no ram pages found");

	const uint i0 = 0;

	// verify that first block is the header:
	CodeSegment& hs = segments[i0];
	if (hs.has_flag) throw SyntaxError("first code segment must be the z80 file header (no flag!)");
	if (hs.compressed) throw SyntaxError("the z80 file header (first code segment) cannot be compressed");

	for (uint i=0; i<segments.count(); i++)
	{
		if (segments[i]->compressed) throw SyntaxError("zx7 compressed data in z80 files not yet supported. TODO!");
	}

	void* vp = hs.getData();
	Z80Header& head = *Z80HeaderPtr(vp);

	// handle version 1.45:
	if (hs.size == z80v1len)
	{
		// check header:
		if (!head.pch && !head.pcl) setError("header v1.45: PC at offset 6 must not be 0");

		// check segments:
		if (segments.count()>2) setError("v1.45: only one ram page allowed");
		CodeSegment& s = segments[i0+1];
		if (s.size!=0xc000) setError("segment %s: v1.45: page size must be 0xC000",s.name);
		if (s.has_flag) setError("segment %s: v1.45: no page ID allowed",s.name);

		// comfort: clear compression flag if size increases:
		if (head.data!=255 && head.data&0x20 && compressed_page_size_z80(s.getData(),0xc000)>0xc000) head.data -= 0x20;
		return;
	}

	// v2.0++
	// check header:

	if (hs.size < z80v3len && hs.size!=z80v2len)
		throw SyntaxError("header: length must be 30 (v1.45), 55 (v2.01) or 86++ (v3++)");
	if (head.pch || head.pcl) throw SyntaxError("header v2++: PC at offset 6 must be 0");

	int n = head.h2lenl + 256 * head.h2lenh;	// length of header extension
	if (32+n != hs.size) throw SyntaxError(
		"header v2++: wrong header extension length at offset 30: %u + 32 != %u", n, hs.size.value);

	Model model = head.getZxspModel();
	if (model==unknown_model) throw SyntaxError("header: illegal model");
	if (model>=zxplus3 && model<=zxplus2a_span && hs.size<z80v3len+1)
		throw SyntaxError("header: size must be ≥ 87 for +3/+2A for port_1ffd byte (warajewo/xzx extension)");

	//uint32 cc = head.getCpuCycle(model_info->cpu_cycles_per_frame);
	//if(cc>70000) {}

	bool spectra_used = head.isVersion300() && (head.rldiremu & 0x08);
	if (spectra_used && model>inves)
		throw SyntaxError("header: SPECTRA extension can only be attached to ZX Spectrum 16/48k (rldiremu&8)");
	if (spectra_used && hs.size<89)
		throw SyntaxError("header: size must be ≥ 89 bytes for SPECTRA extension (rldiremu&8)");

	// v2.0++
	// check pages:
	// verify that all pages have a flag and proper size

	//bool ay_used	= head.rldiremu & 0x04;
	//bool fuller_ay	= head.rldiremu & 0x40;				// only if ay_used
	//bool if1_used	= head.model==1 || head.model==5;
	//bool mgt_used	= head.model==3 || head.model==6;
	bool paged_mem	= (model>=zx128 && model<=zxplus2a_span) || (model>=pentagon128 && model<=samcoupe);
	bool varying_pagesize = model>=zx80;

	static uint sz[num_models] = {16,48,48,48,48,48,128,128,128,128,128,128,128,128,128,
								  48,48,48,48,48,48,128,256,256,1,1,2,16,16,3};
	uint32 ramsize = (varying_pagesize && head.spectator ? head.spectator : sz[model]) * 1024;

	uint32 addr = 0;	// for varying_pagesize
	uint32 loaded = 0;

	for (uint i=i0+1; i<segments.count(); i++)
	{
		CodeSegment& s = segments[i];
		if (!s.has_flag) { setError("segment %s: page ID missing",s.name); continue; }
		uint page_id = uint(s.flag);

		switch (page_id)
		{
		case 2:	// rom at address 0x4000
				if(!paged_mem) setError(
					"segment %s: invalid page ID: this model does not have 32 kB of rom",s.name);
				goto anypage;
		case 0:	// rom at address 0x0000
				goto anypage;
		case 1:	// IF1, Disciple or Plus D Rom
				goto anypage;		// TODO: b&w machines may have different rom size (not yet supported in zxsp)
		case 11: // Multiface Rom or ram page if ram size > 128k
				if (ramsize>128 kB) goto rampage; else goto anypage;
		case 12: // SPECTRA Rom
		case 13: // SPECTRA Ram
		case 14: // SPECTRA Ram
				if (spectra_used) goto anypage; else goto rampage;
		case 8:	// convert page number 48k -> 128k
				if (!paged_mem && !varying_pagesize) page_id = 3;
				goto rampage;
		default:
rampage:	page_id -= 3;
			if (varying_pagesize)	// b&w machines:
			{
				if (page_id>7) { setError("segment %s: page ID out of range",s.name); continue; }
				if (loaded & (1<<page_id)) { setError("segment %s: page ID occured twice",s.name); continue; }
				loaded |= 1<<page_id;
				int32 size = 1024 << page_id;
				if (size != s.size) { setError("segment %s: page size does not match page ID",s.name); continue; }
				if (int(addr)+size > s.size) {setError("segment %s: sum of page sizes exceeds ram size",s.name);continue;}
				addr += uint(size);
			}
			else	// std. 16k page:
			{
				if (page_id >= ramsize>>14) { setError("segment %s: page ID out of range",s.name); continue; }
				if (loaded & (1<<page_id)) { setError("segment %s: page ID occured twice",s.name); continue; }
				loaded |= 1<<page_id;
				addr += 16 kB;
anypage:		if (s.size!=16 kB) { setError("segment %s: page size must be 16 kB",s.name); continue; }
			}
			continue;
		}
	}

	if (errors.count()) return;
	if (addr<ramsize)
	{
		uint32 needed = varying_pagesize ? (ramsize/0x400) : ~((0xffffffff << (ramsize/0x4000)));
		uint32 missing = needed &= ~loaded;
		for (int i=0; i<32; i++)
		{
			if ((missing>>i)&1) setError("code segment for page ID %i is missing",i+3);
		}
	}
}





























