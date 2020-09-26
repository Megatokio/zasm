/*	Copyright  (c)	Günter Woigk 2020 - 2020
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

#pragma once
#include "kio/kio.h"
#include "Z80/goodies/z80_goodies.h"
#include <functional>
#include "Z80Registers.h"



class Z80
{
	typedef uint8  CoreByte;
	typedef int32  CpuCycle;		// cpu clock cycle
	typedef uint16 Address;
	typedef uint8  Byte;
	typedef uint16 Word;

public:
	Z80Registers registers;
	CoreByte* core = nullptr;
	std::function<uint8(CpuCycle,uint16)> input;
	std::function<void(CpuCycle,uint16,uint8)> output;

	CpuID cpu_type;
	bool ixcbr2_enabled;	// if std. Z80
	bool ixcbxh_enabled;	// if std. Z80

	CpuCycle cc;
	int int_ack_byte = 255;  // RST 7
	bool halt;
	CpuCycle int_start = 0;
	CpuCycle int_end = 0;


	Address breakpoint;
	enum RVal { TimeOut=0, BreakPoint, IllegalInstruction };


	Z80 (CpuID cpu_type,
		 CoreByte* core,
		 std::function<uint8(CpuCycle,uint16)> input,
		 std::function<void(CpuCycle,uint16,uint8)> output);
	~Z80(){}

	void reset() noexcept;
	RVal run (CpuCycle cc_exit);

	Byte peek  (Address a) const noexcept	{ return core[a]; }
	void poke  (Address a, Byte c) noexcept	{ core[a] = c; }
	Word peek2 (Address a) const noexcept;
	void poke2 (Address, Word n) noexcept;
	Word pop2  () noexcept;
	void push2 (Word n) noexcept;
};




