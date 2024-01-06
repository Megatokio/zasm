// Copyright (c) 2014 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "kio/kio.h"
class CodeSegment;
class FD;


enum S19Type // type ids for S-Records:
{
	S19_InfoHeader	= '0', // 0 .. 64 bytes arbitrary ascii text
	S19_Data		= '1', // 0 .. 64 bytes data stored at address
	S19_RecordCount = '5', // address = number of s-records transmitted (~ written to file)
	S19_BlockEnd	= '9'  // block end marker; address = 0 or program start address
};


extern uint32 compressed_page_size_z80(const uint8* data, uint size);
extern void	  write_compressed_page_z80(FD&, int page_id, const uint8* data, uint32 size);
extern void	  write_intel_hex(FD&, uint32 address, const uint8* data, uint32 size);
extern uint	  write_motorola_s19(FD&, uint32 address, const uint8* data, uint32 size);
extern void	  write_srecord(FD&, S19Type, uint32 address, const uint8* data, uint size);
extern void	  write_compressed_page_ace(FD&, const uint8* data, uint size);
extern void	  write_segment(FD&, const CodeSegment&);
