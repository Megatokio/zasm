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

#include "kio/kio.h"
#include "Z80Assembler.h"
#include "Z80.h"
#include "Z80/goodies/z80_goodies.h"
#include "Z80/goodies/z80_opcodes.h"


void handleOutput(Z80::CpuCycle,uint16,uint8)
{}

uint8 handleInput(Z80::CpuCycle,uint16)
{
	return 0;
}


void Z80Assembler::runTestcode()
{
	// collection:
	TestSegments tests{segments};
	if (tests.count() == 0) return;

	// collection:
	CodeSegments code_segments{segments};

	// allocate ram:
	std::unique_ptr<Z80::CoreByte[]> memory{new uint8[0x10000]};
	Z80::CoreByte* ram = memory.get();

	for (uint i=0; i<tests.count(); i++)
	{
		TestSegment& test_segment = tests[i];

		try
		{
			// reproducible initialization:
			memset(ram,0x1F,0x10000);

			// load target code, ignore overwrite:
			for (uint i=0; i<code_segments.count(); i++)
			{
				CodeSegment& code_segment = code_segments[i];
				int address = code_segment.getAddress().value;
				int size =  code_segment.size.value;
				assert(address<0x10000);
				assert(size<=0x10000);
				if (address+size > 0x10000) throw SyntaxError("segment %s extends beyond address space", code_segment.name);
				memcpy(ram+address,code_segment.getData(),uint(size));
			}

			// load test code, may overwrite:
			int address = test_segment.getAddress().value;
			int size =  test_segment.size.value;
			assert(address<0x10000);
			assert(size<=0x10000);
			if (address+size > 0x10000) throw SyntaxError("segment %s extends beyond address space",test_segment.name);
			memcpy(ram+address,test_segment.getData(),uint(size));

			// open io files:
			test_segment.openFiles();

			// input handler:
			Z80::InputHandler input = [&test_segment](Z80::CpuCycle, uint16 addr) -> uint8
			{
				try
				{
					return test_segment.inputByte(addr);
				}
				catch (AnyError& e)
				{
					// add io address to error message:
					throw AnyError(e.error(), usingstr("in($%04x): %s", addr, e.what()));
				}
			};

			// output handler:
			Z80::OutputHandler output = [&test_segment, ram](Z80::CpuCycle, uint16 addr, uint8 byte)
			{
				try
				{
					test_segment.outputByte(addr,byte,ram);
				}
				catch (AnyError& e)
				{
					// add io address to error message:
					throw AnyError(e.error(), usingstr("out($%04x,$%02x): %s", addr, byte, e.what()));
				}
			};

			// z80 instance:
			class Z80 cpu{this->cpu,ram,input,output};

			// run test:
			runTestcode(test_segment, cpu);

			// check all bytes read:
			test_segment.checkAllBytesRead();
			test_segment.checkAllBytesWritten();
		}
		catch (AnyError& e)
		{
			setError(e);
		}

		// close test data files:
		test_segment.closeFiles();
	}

	if (verbose >= 2) logNl();
}


void Z80Assembler::runTestcode (TestSegment& test_segment, class Z80& cpu)
{
	if (verbose) logline("\n+++++ running %s +++++", test_segment.name);

	int32 cpu_clock = test_segment.cpu_clock.value;		// cpu clock
	int32 cc_per_int  = test_segment.int_per_sec.value;	// if cc_per_int  >  1000
	int32 int_per_sec = test_segment.int_per_sec.value;	// if int_per_sec <= 1000
	double timeout = test_segment.timeout_ms.value/1e3;	// seconds

	bool with_timeout = timeout > 0.0;
	bool with_interrupts = int_per_sec > 0;
	if (!with_interrupts) int_per_sec = 50;			// Hz

	cpu.int_start = 0;
	cpu.int_end   = with_interrupts ? test_segment.int_duration.value : -1;
	cpu.int_ack_byte = uint8(test_segment.int_ack_byte);
	cpu.registers.pc = uint16(test_segment.address);

	const Expectations& expectations = test_segment.expectations;
	uint expectation_index = 0;
	uint16 end_pc = uint16(test_segment.address + test_segment.dpos);	// attn: might be 0x0000

	if (verbose >= 2)
	{
		if (cpu_clock == 0) logline("  speed: unlimited");
		else				logline("  speed: %i cc/s", cpu_clock);
		if (with_timeout)	logline("  timeout: %.3f sec", timeout);
		else				logline("  timeout: none");
		if (with_interrupts)
		{
			if (cc_per_int > 1000) logline("  interrupts: after %i cc", cc_per_int);
			else                   logline("  interrupts: %i Hz", int_per_sec);
			if (cpu.int_end > 0)   logline("  interrupt active for %i cc", cpu.int_end);
		}
	}

	const int clock_id = cpu_clock > 0 ? CLOCK_MONOTONIC			// use real world time
									   : CLOCK_THREAD_CPUTIME_ID;	// use thread execution time for timeout
	double current_time = now(clock_id);
	double start_time = current_time;

	while (cpu.registers.pc != end_pc)
	{
		// set breakpoint:
		uint16 stop_pc = expectation_index<expectations.count() ? expectations[expectation_index].pc : end_pc;
		assert(stop_pc >= cpu.registers.pc || stop_pc==0);
		assert(stop_pc <= end_pc || end_pc==0);
		uint8 orig_byte = cpu.core[stop_pc];
		cpu.core[stop_pc] = HALT;
		cpu.breakpoint = stop_pc;
		cpu.halt = 0;					// from last run
		int32 total_cc = -cpu.cc;		// for cc test

		if (verbose>=2) logline("  running from pc=$%04x to $%04x", cpu.registers.pc, stop_pc);

		try
		{
			Z80::RVal rval = Z80::TimeOut; // TimeOut, BreakPoint or IllegalInstruction

			if (cpu_clock > 0)
			{
				// run in real time
				// int freq. in cc/int or int/sec

				if (int_per_sec <= 1000) cc_per_int = (cpu_clock+int_per_sec/2) / int_per_sec;
				double time_per_int = double(cc_per_int) / cpu_clock;

				for(;;)
				{
					rval = cpu.run(cc_per_int);
					if (rval != Z80::TimeOut) break;
					total_cc += cc_per_int;
					cpu.cc -= cc_per_int;
					cpu.int_off = no;
					current_time += time_per_int;
					waitUntil(current_time, clock_id);

					if (with_timeout && current_time > start_time + timeout) throw AnyError("timeout");
				}
			}
			else if (cc_per_int > 1000)
			{
				// run unlimited
				// int freq. in cc/int (cc controlled)

				for(;;)
				{
					rval = cpu.run(cc_per_int);
					if (rval != Z80::TimeOut) break;
					total_cc += cc_per_int;
					cpu.cc -= cc_per_int;
					cpu.int_off = no;

					if (with_timeout && (current_time=now(clock_id)) > start_time + timeout) throw AnyError("timeout");
				}
			}
			else
			{
				// run unlimited
				// int freq. in int/sec (realtime time controlled)

				int32 cc_per_run = 20*1000000 / int_per_sec;	// assuming emulation is much faster than 20MHz
				double time_per_int = 1.0 / int_per_sec;

				for(;;)
				{
					rval = cpu.run(cpu.cc + cc_per_run);
					if (rval != Z80::TimeOut) break;

					if (now(clock_id) >= current_time + time_per_int)
					{
						total_cc += cpu.cc; cpu.cc = 0;
						cpu.int_off = no;
						current_time += time_per_int;
						if (with_timeout && current_time > start_time + timeout) throw AnyError("timeout");
					}
				}
			}

			// check return code
			if (rval == Z80::IllegalInstruction)
			{
				ushort pc = cpu.registers.pc;
				CpuID cpuid = cpu.cpu_type;
				if (cpuid==Cpu8080) throw AnyError("%s", disassemble_8080(cpu.core, pc, syntax_8080));
				if (ixcbr2_enabled) cpuid = CpuZ80_ixcbr2;
				if (ixcbxh_enabled) cpuid = CpuZ80_ixcbxh;
				throw AnyError("%s", disassemble(cpuid, cpu.core, pc));
			}
			else
				assert(rval == Z80::BreakPoint);
		}
		catch (AnyError& e) // input, output or int_ack_byte:
		{
			throw AnyError("[cc=%i] at pc=$%04x: %s", total_cc+cpu.cc, cpu.registers.pc, e.what());
		}

		// reset breakpoint:
		assert(cpu.registers.pc == stop_pc);
		cpu.core[stop_pc] = orig_byte;

		if (verbose >= 2) logline("          cc = %u", total_cc+cpu.cc);

		// test expectations:
		while (expectation_index < expectations.count() && expectations[expectation_index].pc == stop_pc)
		{
			const Expectation& e = expectations[expectation_index++];

			int32 regvalue = cpu.registers.getValue(e.name);
			if (regvalue >= 0) // e.name is a register name?
			{
				if (int16(regvalue) != int16(e.value))
					setError(e.sourceline, "register %s = %i ≠ expected %i", e.name, regvalue, e.value);
			}
			else if (eq(e.name,"cc_min"))
			{
				if (total_cc+cpu.cc < e.value)
					setError(e.sourceline, "cpu cycles %u < min %u", total_cc+cpu.cc, e.value);
			}
			else if (eq(e.name,"cc_max"))
			{
				if (total_cc+cpu.cc > e.value)
					setError(e.sourceline, "cpu cycles %u > max %u", total_cc+cpu.cc, e.value);
			}
			else if (eq(e.name,"cc"))
			{
				if (total_cc+cpu.cc != e.value)
					setError(e.sourceline, "cpu cycles %u != %u", total_cc+cpu.cc, e.value);
			}
			else if (Z80Registers::isaQuadRegister(e.name))	// e.name is a quad register name?
			{
				regvalue = cpu.registers.getValue(e.name,yes);
				if (regvalue != e.value)
					setError(e.sourceline, "register %s = %i ≠ expected %i", e.name, regvalue, e.value);
			}
			else IERR();
		}
	}

	// print time:
	if (verbose >= 2 && with_timeout)
	{
		logline("  total time: %.6f sec", current_time - start_time);
		logline("  time left:  %.6f sec", start_time + timeout - current_time);
	}
}

























