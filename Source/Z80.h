// Copyright (c) 2020 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "Z80/goodies/z80_goodies.h"
#include "Z80Registers.h"
#include <functional>

namespace zasm
{

class Z80
{
public:
	using CoreByte		= uint8;
	using CpuCycle		= int32; // cpu clock cycle
	using Address		= uint16;
	using Byte			= uint8;
	using Word			= uint16;
	using InputHandler	= std::function<uint8(CpuCycle, uint16)>;
	using OutputHandler = std::function<void(CpuCycle, uint16, uint8)>;

	static const uint8 zlog_flags[256];

	Z80Registers  registers;
	CoreByte*	  core = nullptr;
	InputHandler  input;
	OutputHandler output;

	CpuID cpu_type;
	bool  ixcbr2_enabled = no; // Z80
	bool  ixcbxh_enabled = no; // Z80

	CpuCycle cc			  = 0;
	uint	 int_ack_byte = 255; // RST 0x38
	bool	 halt		  = no;
	bool	 int_off	  = yes; // interrupt was automatically switched off in int ack cycle
	CpuCycle int_start	  = 0;
	CpuCycle int_end	  = 0; // interrupt duration: -1 = no interrupts, 0 =
							   // automatic switch-off mode, else cc
	Address breakpoint = 0;

	enum RVal { TimeOut = 0, BreakPoint, IllegalInstruction, UnsupportedIntAckByte };

	Z80(CpuID, CoreByte[0x10000], InputHandler, OutputHandler);

	~Z80() {}

	void reset() noexcept;
	RVal run(CpuCycle cc_exit);
	RVal runZ180(CpuCycle);

	Byte peek(Address a) const noexcept { return core[a]; }

	void poke(Address a, Byte c) noexcept { core[a] = c; }
};

} // namespace zasm
