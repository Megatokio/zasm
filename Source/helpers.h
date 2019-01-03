/*	Copyright  (c)	Günter Woigk 2014 - 2019
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


#ifndef HELPERS_H
#define HELPERS_H

#include "kio/kio.h"
class CodeSegment;
class FD;


enum S19Type				// type ids for S-Records:
{
	S19_InfoHeader	= '0',	// 0 .. 64 bytes arbitrary ascii text
	S19_Data        = '1',	// 0 .. 64 bytes data stored at address
	S19_RecordCount = '5',	// address = number of s-records transmitted (~ written to file)
	S19_BlockEnd    = '9'	// block end marker; address = 0 or program start address
};


EXT uint32 compressed_page_size_z80	( uint8 const* data, uint size );
EXT void write_compressed_page_z80	( FD&, int page_id, uint8 const* data, uint32 size ) throws;
EXT void write_intel_hex			( FD&, uint32 address, uint8 const* data, uint32 size ) throws;
EXT uint write_motorola_s19			( FD&, uint32 address, uint8 const* data, uint32 size ) throws;
EXT void write_srecord				( FD&, S19Type, uint32 address, uint8 const* data, uint size ) throws;
EXT void write_compressed_page_ace	( FD&, uint8 const* data, uint size ) throws;
EXT void write_segment				( FD&, const CodeSegment& ) throws;


#endif // helpers_h


























