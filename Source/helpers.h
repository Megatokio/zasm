#pragma once
/*	Copyright  (c)	Günter Woigk 2014 - 2019
					mailto:kio@little-bat.de

	This file is free software.

	Permission to use, copy, modify, distribute, and sell this software
	and its documentation for any purpose is hereby granted without fee,
	provided that the above copyright notice appears in all copies and
	that both that copyright notice, this permission notice and the
	following disclaimer appear in supporting documentation.

	THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY WARRANTY,
	NOT EVEN THE IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR
	A PARTICULAR PURPOSE, AND IN NO EVENT SHALL THE COPYRIGHT HOLDER
	BE LIABLE FOR ANY DAMAGES ARISING FROM THE USE OF THIS SOFTWARE,
	TO THE EXTENT PERMITTED BY APPLICABLE LAW.
*/

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


extern uint32 compressed_page_size_z80	( uint8 const* data, uint size );
extern void write_compressed_page_z80	( FD&, int page_id, uint8 const* data, uint32 size ) throws;
extern void write_intel_hex 			( FD&, uint32 address, uint8 const* data, uint32 size ) throws;
extern uint write_motorola_s19			( FD&, uint32 address, uint8 const* data, uint32 size ) throws;
extern void write_srecord				( FD&, S19Type, uint32 address, uint8 const* data, uint size ) throws;
extern void write_compressed_page_ace	( FD&, uint8 const* data, uint size ) throws;
extern void write_segment				( FD&, const CodeSegment& ) throws;





























