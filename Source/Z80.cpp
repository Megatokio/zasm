/*	Copyright  (c)	Günter Woigk 1996 - 2020
					mailto:kio@little-bat.de

	This file is free software.

	Permission to use, copy, modify, distribute, and sell this software
	and its documentation for any purpose is hereby granted without fee,
	provided that the above copyright notice appears in all copies and
	that both that copyright notice, this permission notice and the
	following disclaimer appear in supporting documentation.

	THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, NOT EVEN THE
	IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE
	AND IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY DAMAGES
	ARISING FROM THE USE OF THIS SOFTWARE,
	TO THE EXTENT PERMITTED BY APPLICABLE LAW.


	Z80 Emulator	version 2.2.5
					initially based on fMSX; Copyright (C) Marat Fayzullin 1994,1995
*/

#include "kio/kio.h"
#include "Z80/goodies/z80_goodies.h"
#include "Z80/goodies/z80_opcodes.h"
#include "Z80.h"

#define	OUTPUT(A,B)		do{ INCR_CC(4); output(cc-2,A,B); }while(0)
#define	INPUT(A,B)		do{ INCR_CC(4); B = input(cc-2,A); }while(0)

#include "z80macros.h"

static const uint8 zlog_flags[256] =
{
	// conversion table: A -> Z80-flags with S, Z, V=parity and C=0
	// 2013-06-12:		 A -> Z80-flags with S, Z, V=parity and C=0, bits 3 and 5 verbatim from A
	#define FLAGS0(A)	(A&0xA8) + ((A==0)<<6) + (((~A+(A>>1)+(A>>2)+(A>>3)+(A>>4)+(A>>5)+(A>>6)+(A>>7))&1) << 2)
	#define FLAGS2(A)	FLAGS0(A), FLAGS0((A+1 )), FLAGS0((A+2 )), FLAGS0((A+3))
	#define FLAGS4(A)	FLAGS2(A), FLAGS2((A+4 )), FLAGS2((A+8 )), FLAGS2((A+12))
	#define FLAGS6(A)	FLAGS4(A), FLAGS4((A+16)), FLAGS4((A+32)), FLAGS4((A+48))
	FLAGS6(0), FLAGS6(64), FLAGS6(128), FLAGS6(192)
};

Z80::Word Z80::peek2 (Address addr) const noexcept
{
	return Word(peek(addr) + (peek(addr+1)<<8));
}

void Z80::poke2 (Address addr, Word n) noexcept
{
	poke( addr,   Byte(n) );
	poke( addr+1, Byte(n>>8) );
}

Z80::Word Z80::pop2() noexcept
{
	registers.sp += 2;
	return peek2(registers.sp - 2);
}

void Z80::push2 (Word n) noexcept
{
	registers.sp -= 2;
	poke2(registers.sp, n);
}

Z80::Z80 (CpuID cpu_type, CoreByte* core, InputHandler input, OutputHandler output)
:
	core(core),
	input(input),
	output(output),
	cpu_type(cpu_type),
	ixcbr2_enabled(no),
	ixcbxh_enabled(no),
	int_ack_byte(RST38),
	breakpoint(0)
{
	reset();
}

void Z80::reset() noexcept
{
	registers.reset();
	cc   = 0;
	halt = 0;
	int_start = 0;
	int_end = 0;
}


Z80::RVal Z80::run (CpuCycle ccx)
{
	CpuCycle cc;			// cpu cycle counter
	CpuCycle ccx0 = ccx;

	RVal result = TimeOut;	// reset: T cycle count expired

	uint16	pc;				// z80 program counter
	uint8	ra;				// z80 a register
	uint8	rf;				// z80 flags
	uint8	r;				// z80 r register bit 0...6

	uint8	c;				// general purpose byte register
	uint16	w;				// general purpose word register
	#define	wl	uint8(w)	// access low byte of w
	#define	wh	(w>>8)		// access high byte of w

	uint16*	rzp;			// pointer to double register, mostly IX or IY
	#define	rz	(*rzp)				// IX or IY
	#ifdef _BIG_ENDIAN
	#define	rzh	((u8ptr(rzp))[0])	// XH or YH
	#define	rzl	((u8ptr(rzp))[1])	// XL or YL
	#else
	#define	rzh	((u8ptr(rzp))[1])	// XH or YH
	#define	rzl	((u8ptr(rzp))[0])	// XL or YL
	#endif

	uint16	wm;					// scratch for macro internal use
	#define	wml	uint8(wm)		// access low byte of wm
	#define	wmh (wm>>8)			// access high byte of wm

// looping & jumping:
	#define	LOOP				goto nxtcmnd						// LOOP to next instruction
	#define POKE_AND_LOOP(W,C)	do{ w=W; c=C; goto poke_and_nxtcmd; }while(0) // POKE(w,c) and goto next instr.
	#define EXIT				goto x

// load local variables from data members:
	LOAD_REGISTERS;

	try
	{

slow_loop:

// ----	Update all Items and Poll Interrupts ----

//	we come here
//	- because run() was just entered
//	- because cc >= cc_next_update --> an item requires an internal update, irpt may toggle
//	- EI was executed and we need to re-check interrupts

// ---- NMI TEST ---------------

// test non-maskable interrupt:
// the NMI is edge-triggered and automatically cleared
// ***NMI not supported***

// ---- INTERRUPT TEST -----------------

// test maskable interrupt:
// note: the /INT signal is not cleared by int ack
//		 the /INT signal is sampled once per instruction at the end of instruction, during refresh cycle
//		 if the interrupt is not started until the /INT signal goes away then it is lost!

	ccx = ccx0;						// restore cc for fast exit test
	if (cc >= int_end) LOOP;		// interrupt no longer asserted
	if (cc < int_start) { ccx = min(int_start,ccx); LOOP; } // interrupt not yet asserted
	if (IFF1 == disabled) LOOP;		// irpt disabled

	if (halt) { assert(peek(pc)==HALT); halt=no; pc++; }
	IFF1 = IFF2 = disabled;			// disable interrupt
	INCR_R();						// M1: 2 cc + standard opcode timing (min. 4 cc)
	INCR_CC(6);						// /HALT test and busbyte read in cc+4
	Z80_INFO_IRPT;

	switch (registers.im)
	{
	case 0:  // mode 0: read instruction from bus
		switch(int_ack_byte)
		{
		case RST00: case RST08:
		case RST10: case RST18:
		case RST20: case RST28:
		case RST30: case RST38:
			INCR_CC(1);
			PUSH(pc>>8);
			PUSH(pc);
			pc = Address(int_ack_byte - RST00);
			LOOP;
		default:
			throw AnyError("interrupt in im0 with unsupported instruction on bus");
		}

	case 1:  // Mode 1:	RST38
		INCR_CC(1);
		PUSH(pc>>8);
		PUSH(pc);
		pc = 0x0038;
		LOOP;

	case 2:  // Mode 2:	jump via table
		INCR_CC(1);
		PUSH(pc>>8);
		PUSH(pc);
		pc = Address(registers.i*256 + int_ack_byte);
		PEEK(PCL,pc);
		PEEK(PCH,pc+1);
		pc = PC;
		LOOP;

	default:
		IERR();  // bogus irpt mode
	}


// ==========================================================================
// MAIN INSTRUCTION DISPATCHER
// ==========================================================================

ill_8080_nop:						// deprecated 8080 opcode which is handled like a NOP
	Z80_INFO_ILLEGAL(4,1,1);
	LOOP;

poke_and_nxtcmd:
	POKE(w,c);						// --> CPU_WAITCYCLES, CPU_READSCREEN, cc+=3, Poke(w,c)

nxtcmnd:
	while (cc < ccx)				// fast loop exit test
	{

loop_ei:							// LOOP without loop exit test: after EI
		GET_INSTR(c);

		switch (c)
		{

		// ########	4 T cycle Instructions #########################

		// LD R,R
		{
		case LD_B_B:	RB=RB;	LOOP;				// 4 T
		case LD_C_B:	RC=RB;	LOOP;				// 4 T
		case LD_D_B:	RD=RB;	LOOP;				// 4 T
		case LD_E_B:	RE=RB;	LOOP;				// 4 T
		case LD_H_B:	RH=RB;	LOOP;				// 4 T
		case LD_L_B:	RL=RB;	LOOP;				// 4 T
		case LD_A_B:	ra=RB;	LOOP;				// 4 T

		case LD_B_C:	RB=RC;	LOOP;				// 4 T
		case LD_C_C:	RC=RC;	LOOP;				// 4 T
		case LD_D_C:	RD=RC;	LOOP;				// 4 T
		case LD_E_C:	RE=RC;	LOOP;				// 4 T
		case LD_H_C:	RH=RC;	LOOP;				// 4 T
		case LD_L_C:	RL=RC;	LOOP;				// 4 T
		case LD_A_C:	ra=RC;	LOOP;				// 4 T

		case LD_B_D:	RB=RD;	LOOP;				// 4 T
		case LD_C_D:	RC=RD;	LOOP;				// 4 T
		case LD_D_D:	RD=RD;	LOOP;				// 4 T
		case LD_E_D:	RE=RD;	LOOP;				// 4 T
		case LD_H_D:	RH=RD;	LOOP;				// 4 T
		case LD_L_D:	RL=RD;	LOOP;				// 4 T
		case LD_A_D:	ra=RD;	LOOP;				// 4 T

		case LD_B_E:	RB=RE;	LOOP;				// 4 T
		case LD_C_E:	RC=RE;	LOOP;				// 4 T
		case LD_D_E:	RD=RE;	LOOP;				// 4 T
		case LD_E_E:	RE=RE;	LOOP;				// 4 T
		case LD_H_E:	RH=RE;	LOOP;				// 4 T
		case LD_L_E:	RL=RE;	LOOP;				// 4 T
		case LD_A_E:	ra=RE;	LOOP;				// 4 T

		case LD_B_H:	RB=RH;	LOOP;				// 4 T
		case LD_C_H:	RC=RH;	LOOP;				// 4 T
		case LD_D_H:	RD=RH;	LOOP;				// 4 T
		case LD_E_H:	RE=RH;	LOOP;				// 4 T
		case LD_H_H:	RH=RH;	LOOP;				// 4 T
		case LD_L_H:	RL=RH;	LOOP;				// 4 T
		case LD_A_H:	ra=RH;	LOOP;				// 4 T

		case LD_B_L:	RB=RL;	LOOP;				// 4 T
		case LD_C_L:	RC=RL;	LOOP;				// 4 T
		case LD_D_L:	RD=RL;	LOOP;				// 4 T
		case LD_E_L:	RE=RL;	LOOP;				// 4 T
		case LD_H_L:	RH=RL;	LOOP;				// 4 T
		case LD_L_L:	RL=RL;	LOOP;				// 4 T
		case LD_A_L:	ra=RL;	LOOP;				// 4 T

		case LD_B_A:	RB=ra;	LOOP;				// 4 T
		case LD_C_A:	RC=ra;	LOOP;				// 4 T
		case LD_D_A:	RD=ra;	LOOP;				// 4 T
		case LD_E_A:	RE=ra;	LOOP;				// 4 T
		case LD_H_A:	RH=ra;	LOOP;				// 4 T
		case LD_L_A:	RL=ra;	LOOP;				// 4 T
		case LD_A_A:  /*ra=ra;*/LOOP;				// 4 T
		}

		// ARI R,R
		{
		case ADD_B:		M_ADD(RB); LOOP;			// 4 T
		case ADD_C:		M_ADD(RC); LOOP;			// 4 T
		case ADD_D:		M_ADD(RD); LOOP;			// 4 T
		case ADD_E:		M_ADD(RE); LOOP;			// 4 T
		case ADD_H:		M_ADD(RH); LOOP;			// 4 T
		case ADD_L:		M_ADD(RL); LOOP;			// 4 T
		case ADD_A:		M_ADD(ra); LOOP;			// 4 T

		case SUB_B:		M_SUB(RB); LOOP;			// 4 T
		case SUB_C:		M_SUB(RC); LOOP;			// 4 T
		case SUB_D:		M_SUB(RD); LOOP;			// 4 T
		case SUB_E:		M_SUB(RE); LOOP;			// 4 T
		case SUB_H:		M_SUB(RH); LOOP;			// 4 T
		case SUB_L:		M_SUB(RL); LOOP;			// 4 T
		case SUB_A:		M_SUB(ra); LOOP;			// 4 T

		case ADC_B:		M_ADC(RB); LOOP;			// 4 T
		case ADC_C:		M_ADC(RC); LOOP;			// 4 T
		case ADC_D:		M_ADC(RD); LOOP;			// 4 T
		case ADC_E:		M_ADC(RE); LOOP;			// 4 T
		case ADC_H:		M_ADC(RH); LOOP;			// 4 T
		case ADC_L:		M_ADC(RL); LOOP;			// 4 T
		case ADC_A:		M_ADC(ra); LOOP;			// 4 T

		case SBC_B:		M_SBC(RB); LOOP;			// 4 T
		case SBC_C:		M_SBC(RC); LOOP;			// 4 T
		case SBC_D:		M_SBC(RD); LOOP;			// 4 T
		case SBC_E:		M_SBC(RE); LOOP;			// 4 T
		case SBC_H:		M_SBC(RH); LOOP;			// 4 T
		case SBC_L:		M_SBC(RL); LOOP;			// 4 T
		case SBC_A:		M_SBC(ra); LOOP;			// 4 T

		case CP_B:		M_CP(RB); LOOP;				// 4 T
		case CP_C:		M_CP(RC); LOOP;				// 4 T
		case CP_D:		M_CP(RD); LOOP;				// 4 T
		case CP_E:		M_CP(RE); LOOP;				// 4 T
		case CP_H:		M_CP(RH); LOOP;				// 4 T
		case CP_L:		M_CP(RL); LOOP;				// 4 T
		case CP_A:		M_CP(ra); LOOP;				// 4 T

		case AND_B:		M_AND(RB);LOOP;				// 4 T
		case AND_C:		M_AND(RC);LOOP;				// 4 T
		case AND_D:		M_AND(RD);LOOP;				// 4 T
		case AND_E:		M_AND(RE);LOOP;				// 4 T
		case AND_H:		M_AND(RH);LOOP;				// 4 T
		case AND_L:		M_AND(RL);LOOP;				// 4 T
		case AND_A:		M_AND(ra);LOOP;				// 4 T

		case OR_B:		M_OR(RB); LOOP;				// 4 T
		case OR_C:		M_OR(RC); LOOP;				// 4 T
		case OR_D:		M_OR(RD); LOOP;				// 4 T
		case OR_E:		M_OR(RE); LOOP;				// 4 T
		case OR_H:		M_OR(RH); LOOP;				// 4 T
		case OR_L:		M_OR(RL); LOOP;				// 4 T
		case OR_A:		M_OR(ra); LOOP;				// 4 T

		case XOR_B:		M_XOR(RB);LOOP;				// 4 T
		case XOR_C:		M_XOR(RC);LOOP;				// 4 T
		case XOR_D:		M_XOR(RD);LOOP;				// 4 T
		case XOR_E:		M_XOR(RE);LOOP;				// 4 T
		case XOR_H:		M_XOR(RH);LOOP;				// 4 T
		case XOR_L:		M_XOR(RL);LOOP;				// 4 T
		case XOR_A:		M_XOR(ra);LOOP;				// 4 T
		}

		// INC R \ DEC R
		{
		case DEC_B:		M_DEC(RB);LOOP;				// 4 T
		case DEC_C:		M_DEC(RC);LOOP;				// 4 T
		case DEC_D:		M_DEC(RD);LOOP;				// 4 T
		case DEC_E:		M_DEC(RE);LOOP;				// 4 T
		case DEC_H:		M_DEC(RH);LOOP;				// 4 T
		case DEC_L:		M_DEC(RL);LOOP;				// 4 T
		case DEC_A:		M_DEC(ra);LOOP;				// 4 T

		case INC_B:		M_INC(RB);LOOP;				// 4 T
		case INC_C:		M_INC(RC);LOOP;				// 4 T
		case INC_D:		M_INC(RD);LOOP;				// 4 T
		case INC_E:		M_INC(RE);LOOP;				// 4 T
		case INC_H:		M_INC(RH);LOOP;				// 4 T
		case INC_L:		M_INC(RL);LOOP;				// 4 T
		case INC_A:		M_INC(ra);LOOP;				// 4 T
		}

		// other 4T opcodes:
		{
		case JP_HL:						// 4 T
			pc = HL;
			LOOP;

		case EX_DE_HL:					// 4 T
			w=DE;DE=HL;HL=w;
			LOOP;

		case EX_AF_AF:					// 4 T
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			c=ra;ra=RA2;RA2=c;
			c=rf;rf=RF2;RF2=c;
			LOOP;

		case EXX:
			if (cpu_type == Cpu8080) goto ill_8080_ret;
			w=BC;BC=BC2;BC2=w;			// 4 T
			w=DE;DE=DE2;DE2=w;
			w=HL;HL=HL2;HL2=w;
			LOOP;

		case HALT:						// 4 T  ((executes NOPs until interrupt))
			pc--;
			if (halt) LOOP;
			halt = true;
			Z80_INFO_HALT;
			LOOP;

		case NOP:						// 4 T
			LOOP;

		case DI:						// 4 T
			IFF1=IFF2=disabled;
			Z80_INFO_DI;
			LOOP;

		case EI:						// 4 T
			//if (IFF1==enabled) LOOP;	// z80-documented.pdf: nach EI niemals Irpt Ackn
			IFF1=IFF2=enabled;
			Z80_INFO_EI;
			ccx = cc+1;	// exit the fast loop after next cmd -> reload ccx & goto slow_loop
			LOOP;		// der nächste Befehl wird auf jeden Fall noch ausgeführt.

		case SCF:		rf|=C_FLAG; rf&=~(N_FLAG+H_FLAG);	LOOP;		// 4 T
		case CCF:		rf^=C_FLAG; rf&=~N_FLAG;			LOOP;		// 4 T
		case CPL:		ra=~ra; rf|=N_FLAG+H_FLAG;			LOOP;		// 4 T

		case RLCA:		ra = uint8(ra<<1) + (ra>>7);		// 4 T
						rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra&C_FLAG);
						LOOP;
		case RRCA:		ra = (ra>>1) + uint8(ra<<7);		// 4 T
						rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra>>7);
						LOOP;
		case RLA:		c  = ra>>7;							// 4 T
						ra = uint8(ra<<1) + (rf&C_FLAG);
						rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
						LOOP;
		case RRA:		c  = ra&C_FLAG;						// 4 T
						ra = (ra>>1) + uint8(rf<<7);
						rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
						LOOP;

		case DAA:		if (rf&N_FLAG)						// 4 T
						{	// previous instruction was SUB
							if (rf&H_FLAG) 		ra -= 0x06;
							if (rf&C_FLAG) 		ra -= 0x60;
						}
						else
						{	// previous instruction was ADD
							if ((ra&0x0F)>0x09)	rf |= H_FLAG;
							if (rf&H_FLAG) 		ra += 0x06;
							if (ra>0x99) 		rf |= C_FLAG;
							if (rf&C_FLAG)		ra += 0x60;
						}
						rf &= C_FLAG+N_FLAG;
						rf |= zlog_flags[ra];
						LOOP;
		}

		// ########	Other no-memory-access Instructions #########################

		{
		case DEC_BC:	INCR_CC(2); BC--;	LOOP;		// T 6
		case DEC_DE:	INCR_CC(2); DE--;	LOOP;		// T 6
		case DEC_HL:	INCR_CC(2); HL--;	LOOP;		// T 6
		case DEC_SP:	INCR_CC(2); SP--;	LOOP;		// T 6
		case INC_BC:	INCR_CC(2); BC++;	LOOP;		// T 6
		case INC_DE:	INCR_CC(2); DE++;	LOOP;		// T 6
		case INC_HL:	INCR_CC(2); HL++;	LOOP;		// T 6
		case INC_SP:	INCR_CC(2); SP++;	LOOP;		// T 6

		case LD_SP_HL:	INCR_CC(2); SP = HL;	LOOP;		// T 6

		case ADD_HL_BC:	INCR_CC(7); M_ADDW(HL,BC); LOOP;	// T 11
		case ADD_HL_DE:	INCR_CC(7); M_ADDW(HL,DE); LOOP;	// T 11
		case ADD_HL_HL:	INCR_CC(7); M_ADDW(HL,HL); LOOP;	// T 11
		case ADD_HL_SP:	INCR_CC(7); M_ADDW(HL,SP); LOOP;	// T 11
		}

		// ########	Read-only-from-memory Instructions #########################


		{ uint8* p;
		case LD_B_xHL:	p=&RB; goto ld_xhl;
		case LD_C_xHL:	p=&RC; goto ld_xhl;
		case LD_D_xHL:	p=&RD; goto ld_xhl;
		case LD_E_xHL:	p=&RE; goto ld_xhl;
		case LD_H_xHL:	p=&RH; goto ld_xhl;
		case LD_L_xHL:	p=&RL; goto ld_xhl;
				ld_xhl:	PEEK(*p,HL); LOOP;		// timing: pc:4, hl:3
		}


		{ uint8* p;
		case LD_B_N:	p=&RB; goto ld_n;
		case LD_C_N:	p=&RC; goto ld_n;
		case LD_D_N:	p=&RD; goto ld_n;
		case LD_E_N:	p=&RE; goto ld_n;
		case LD_H_N:	p=&RH; goto ld_n;
		case LD_L_N:	p=&RL; goto ld_n;
				ld_n:	GET_N(*p); LOOP;		// timing: pc:4, pc+1:3
		}
		case LD_A_N:	GET_N(ra); LOOP;		// timing: pc:4, pc+1:3

		case ADD_xHL:	PEEK(c,HL);   M_ADD(c); LOOP;	// timing: pc:4, hl:3
		case SUB_xHL:	PEEK(c,HL);   M_SUB(c); LOOP;	// timing: pc:4, hl:3
		case ADC_xHL:	PEEK(c,HL);   M_ADC(c); LOOP;	// timing: pc:4, hl:3
		case SBC_xHL:	PEEK(c,HL);   M_SBC(c); LOOP;	// timing: pc:4, hl:3
		case CP_xHL:	PEEK(c,HL);   M_CP(c);  LOOP;	// timing: pc:4, hl:3
		case OR_xHL:	PEEK(c,HL);   M_OR(c);  LOOP;	// timing: pc:4, hl:3
		case XOR_xHL:	PEEK(c,HL);   M_XOR(c); LOOP;	// timing: pc:4, hl:3
		case AND_xHL:	PEEK(c,HL);   M_AND(c); LOOP;	// timing: pc:4, hl:3

		case ADD_N:		GET_N(c);   M_ADD(c); LOOP;		// timing: pc:4, pc+1:3
		case ADC_N:		GET_N(c);   M_ADC(c); LOOP;		// timing: pc:4, pc+1:3
		case SUB_N:		GET_N(c);   M_SUB(c); LOOP;		// timing: pc:4, pc+1:3
		case SBC_N:		GET_N(c);   M_SBC(c); LOOP;		// timing: pc:4, pc+1:3
		case CP_N:		GET_N(c);   M_CP(c);  LOOP;		// timing: pc:4, pc+1:3
		case OR_N:		GET_N(c);   M_OR(c);  LOOP;		// timing: pc:4, pc+1:3
		case XOR_N:		GET_N(c);   M_XOR(c); LOOP;		// timing: pc:4, pc+1:3
		case AND_N:		GET_N(c);   M_AND(c); LOOP;		// timing: pc:4, pc+1:3

		case LD_SP_NN: 	rzp=&registers.sp; goto ld_nn;	// timing: pc:4,pc+1:3,pc+2:3
		case LD_BC_NN: 	rzp=&registers.bc; goto ld_nn;
		case LD_DE_NN: 	rzp=&registers.de; goto ld_nn;
		case LD_HL_NN: 	rzp=&registers.hl; goto ld_nn;

			ld_nn:
			GET_N(rzl); GET_N(rzh);
			LOOP;

		case JP_NZ:		if (rf&Z_FLAG) goto njp; else goto jp;	// timing: pc:4,pc+1:3,pc+2:3
		case JP_NC:		if (rf&C_FLAG) goto njp; else goto jp;
		case JP_PO:		if (rf&P_FLAG) goto njp; else goto jp;
		case JP_P:		if (rf&S_FLAG) goto njp; else goto jp;
		case JP_C:		if (rf&C_FLAG) goto jp; else goto njp;
		case JP_PE:		if (rf&P_FLAG) goto jp; else goto njp;
		case JP_M:		if (rf&S_FLAG) goto jp; else goto njp;
		case JP_Z:		if (rf&Z_FLAG) goto jp; else goto njp;

			njp:
			SKIP_N(); SKIP_N();
			LOOP;

			ill_8080_jp:
			Z80_INFO_ILLEGAL(4,1,1);
			goto jp;

		case JP:					// timing: pc:4,pc+1:3,pc+2:3
			jp:	GET_NN(w);
			pc = w;
			LOOP;

		case JR:					// timing: pc:4, pc+1:3,5*1
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			jr:	GET_N(c);
			SKIP_5X1CC(pc);
			pc += int8(c);
			LOOP;

		case JR_Z:					// timing: pc:4, pc+1:3,[5*1]
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			if (rf&Z_FLAG) goto jr; else goto njr;
			njr: SKIP_N();
			LOOP;

		case JR_C:					// timing: pc:4, pc+1:3,[5*1]
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			if (rf&C_FLAG) goto jr; else goto njr;

		case JR_NZ:					// timing: pc:4, pc+1:3,[5*1]
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			if (rf&Z_FLAG) goto njr; else goto jr;

		case JR_NC:					// timing: pc:4, pc+1:3,[5*1]
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			if (rf&C_FLAG) goto njr; else goto jr;

		case DJNZ:					// timing: pc:5, pc+1:3,[5*1]
			if (cpu_type == Cpu8080) goto ill_8080_nop;
			INCR_CC(1);
			if (--RB) goto jr; else goto njr;

			ill_8080_ret:
			Z80_INFO_ILLEGAL(4,1,1);
			goto ret;

		case RET:					// timing: pc:4, sp:3, sp+1:3
			ret:
			POP(PCL); POP(PCH);
			pc = PC;
			Z80_INFO_RET;
			LOOP;

		case RET_NZ:	INCR_CC(1); if(rf&Z_FLAG) LOOP; else goto ret;	// timing: pc:5, [sp:3, sp+1:3]
		case RET_NC:	INCR_CC(1); if(rf&C_FLAG) LOOP; else goto ret;
		case RET_PO:	INCR_CC(1); if(rf&P_FLAG) LOOP; else goto ret;
		case RET_P:		INCR_CC(1); if(rf&S_FLAG) LOOP; else goto ret;
		case RET_Z:		INCR_CC(1); if(rf&Z_FLAG) goto ret; else LOOP;
		case RET_C:		INCR_CC(1); if(rf&C_FLAG) goto ret; else LOOP;
		case RET_PE:	INCR_CC(1); if(rf&P_FLAG) goto ret; else LOOP;
		case RET_M:		INCR_CC(1); if(rf&S_FLAG) goto ret; else LOOP;

		case LD_A_xNN:	GET_NN(w); goto ld_a_xw;	// timing: pc:4, pc+1:3, pc+2:3, nn:3
		case LD_A_xBC:	w=BC;      goto ld_a_xw;	// timing: pc:4, bc:3
		case LD_A_xDE:	w=DE;	   goto ld_a_xw;	// timing: pc:4, de:3
		case LD_A_xHL:	w=HL;	   goto ld_a_xw;	// timing: pc:4, hl:3
			  ld_a_xw:	PEEK(ra,w); LOOP;

		case LD_HL_xNN:	GET_NN(w); PEEK(RL,w); PEEK(RH,w+1); LOOP;	// timing: pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3

		case POP_BC:	rzp=&registers.bc; goto pop_rr;
		case POP_DE:	rzp=&registers.de; goto pop_rr;
		case POP_HL:	rzp=&registers.hl; goto pop_rr;
				pop_rr:	POP(rzl); POP(rzh);							// timing: pc:4, sp:3, sp+1:3
						goto pop_af;
		case POP_AF:	POP(rf); POP(ra);							// timing: pc:4, sp:3, sp+1:3
				pop_af:	Z80_INFO_POP;
						LOOP;

		case OUTA:		GET_N(c); OUTPUT ( ra*256 + c, ra ); LOOP;	// timing: pc:4, pc+1:3, IO
		case INA:		GET_N(c); INPUT ( ra*256 + c, ra ); LOOP;	// timing: pc:4, pc+1:3, IO


		// ########	Write-to-memory Instructions #####################
		case CALL_NC: 	if (rf&C_FLAG) goto nocall; else goto call;		// pc:4, pc+1:3, pc+2:3, [pc+2:1, sp-1:3, sp-2:3]
		case CALL_PO:	if (rf&P_FLAG) goto nocall; else goto call;
		case CALL_P: 	if (rf&S_FLAG) goto nocall; else goto call;
		case CALL_NZ: 	if (rf&Z_FLAG) goto nocall; else goto call;
		case CALL_C: 	if (rf&C_FLAG) goto call; else goto nocall;
		case CALL_PE:	if (rf&P_FLAG) goto call; else goto nocall;
		case CALL_M: 	if (rf&S_FLAG) goto call; else goto nocall;
		case CALL_Z: 	if (rf&Z_FLAG) goto call; else goto nocall;

			nocall:
			SKIP_N();
			SKIP_N();
			LOOP;

			ill_8080_call:
			Z80_INFO_ILLEGAL(4,1,1);
			goto call;

		case CALL:			// pc:4, pc+1:3, pc+2:3,1, sp-1:3, sp-2:3
			call:
			GET_NN(w);
			SKIP_1CC(pc-1);
			goto rst;

			rst:
			PUSH(pc>>8);
			PUSH(pc);
			pc = w;
			LOOP;

		case RST00:		w=0x0000; INCR_CC(1); Z80_INFO_RST00; goto rst;	// pc:5, sp-1:3, sp-2:3
		case RST08:  	w=0x0008; INCR_CC(1); Z80_INFO_RST08; goto rst;
		case RST10:  	w=0x0010; INCR_CC(1); Z80_INFO_RST10; goto rst;
		case RST18:  	w=0x0018; INCR_CC(1); Z80_INFO_RST18; goto rst;
		case RST20:  	w=0x0020; INCR_CC(1); Z80_INFO_RST20; goto rst;
		case RST28:  	w=0x0028; INCR_CC(1); Z80_INFO_RST28; goto rst;
		case RST30:  	w=0x0030; INCR_CC(1); Z80_INFO_RST30; goto rst;
		case RST38:  	w=0x0038; INCR_CC(1); Z80_INFO_RST38; goto rst;

		case DEC_xHL:	w=HL; PEEK(c,w); SKIP_1CC(w); M_DEC(c); POKE_AND_LOOP(w,c);		// pc:4, hl:3,1, hl:3
		case INC_xHL:	w=HL; PEEK(c,w); SKIP_1CC(w); M_INC(c); POKE_AND_LOOP(w,c);		// pc:4, hl:3,1, hl:3

		case LD_xHL_B:	POKE_AND_LOOP(HL,RB);							// timing: pc:4, hl:3
		case LD_xHL_C:	POKE_AND_LOOP(HL,RC);
		case LD_xHL_D:	POKE_AND_LOOP(HL,RD);
		case LD_xHL_E:	POKE_AND_LOOP(HL,RE);
		case LD_xHL_H:	POKE_AND_LOOP(HL,RH);
		case LD_xHL_L:	POKE_AND_LOOP(HL,RL);

		case LD_xHL_A:	POKE_AND_LOOP(HL,ra);
		case LD_xBC_A:	POKE_AND_LOOP(BC,ra);							// pc:4, bc:3
		case LD_xDE_A:	POKE_AND_LOOP(DE,ra);							// pc:4, de:3

		case LD_xHL_N:	GET_N(c); POKE_AND_LOOP(HL,c);					// pc:4, pc+1:3, hl:3

		case LD_xNN_A:	GET_NN(w); POKE_AND_LOOP(w,ra);					// pc:4, pc+1:3, pc+2:3, nn:3

		case LD_xNN_HL:	GET_NN(w); POKE(w,RL); POKE_AND_LOOP(w+1,RH);	// pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3

		case PUSH_BC:	w=BC; goto push_w;
		case PUSH_DE:	w=DE; goto push_w;
		case PUSH_HL:	w=HL; goto push_w;
				push_w:	INCR_CC(1); PUSH(wh); PUSH(wl);	LOOP;			// pc:5, sp-1:3, sp-2:3
		case PUSH_AF:	INCR_CC(1); PUSH(ra); PUSH(rf);	LOOP;			// pc:5, sp-1:3, sp-2:3

		case EX_HL_xSP:									// pc:4, sp:3, sp+1:3,1, sp+1:3, sp:3,2x1
			w = HL;										// (kio tested 2005-01-15)
			PEEK(RL,SP); PEEK(RH,SP+1); SKIP_1CC(SP+1);
			POKE(SP+1,wh); POKE(SP,wl); SKIP_2X1CC(SP);
			Z80_INFO_EX_HL_xSP;
			LOOP;


	// ==========================================================================
	//	PREFIX IX / IY COMMANDS
	// ==========================================================================

		case PFX_IY:
			if (cpu_type == Cpu8080) goto ill_8080_call;
			rzp = &registers.iy; 	// 4 T
			goto XY;

		case PFX_IX:
			if (cpu_type == Cpu8080) goto ill_8080_call;
			rzp = &registers.ix; 	// 4 T
			goto XY;

		XY: GET_XY_OP(c);

		switch ( c )
		{
		case LD_H_B:	rzh=RB; goto info_ill2;
		case LD_L_B:   	rzl=RB; goto info_ill2;
		case LD_H_C:	rzh=RC; goto info_ill2;
		case LD_L_C:	rzl=RC; goto info_ill2;
		case LD_H_D:	rzh=RD; goto info_ill2;
		case LD_L_D:	rzl=RD; goto info_ill2;
		case LD_H_E:	rzh=RE; goto info_ill2;
		case LD_L_E:	rzl=RE; goto info_ill2;
		case LD_B_H:	RB=rzh; goto info_ill2;
		case LD_C_H:	RC=rzh; goto info_ill2;
		case LD_D_H:	RD=rzh; goto info_ill2;
		case LD_E_H:	RE=rzh; goto info_ill2;
		case LD_A_H:	ra=rzh; goto info_ill2;
		case LD_B_L:	RB=rzl; goto info_ill2;
		case LD_C_L:	RC=rzl; goto info_ill2;
		case LD_D_L:	RD=rzl; goto info_ill2;
		case LD_E_L:	RE=rzl; goto info_ill2;
		case LD_A_L:	ra=rzl; goto info_ill2;
		info_ill2:		Z80_INFO_ILLEGAL(8,2,2); LOOP;
		case LD_H_A:	rzh=ra; goto info_ill2;
		case LD_L_A:	rzl=ra; goto info_ill2;
		case LD_H_N:	GET_N(rzh); goto info_ill2;
		case LD_L_N:	GET_N(rzl); goto info_ill2;
		case DEC_H:		M_DEC(rzh); goto info_ill2;
		case DEC_L:		M_DEC(rzl); goto info_ill2;
		case INC_H:		M_INC(rzh); goto info_ill2;
		case INC_L:		M_INC(rzl); goto info_ill2;
		case ADD_H:		M_ADD(rzh); goto info_ill2;
		case ADD_L:		M_ADD(rzl); goto info_ill2;
		case SUB_H:		M_SUB(rzh); goto info_ill2;
		case SUB_L:		M_SUB(rzl); goto info_ill2;
		case ADC_H:		M_ADC(rzh); goto info_ill2;
		case ADC_L:		M_ADC(rzl); goto info_ill2;
		case SBC_H:		M_SBC(rzh); goto info_ill2;
		case SBC_L:		M_SBC(rzl); goto info_ill2;
		case CP_H:		M_CP(rzh); goto info_ill2;
		case CP_L:		M_CP(rzl); goto info_ill2;
		case AND_H:		M_AND(rzh); goto info_ill2;
		case AND_L:		M_AND(rzl); goto info_ill2;
		case OR_H:		M_OR(rzh); goto info_ill2;
		case OR_L:		M_OR(rzl); goto info_ill2;
		case XOR_H:		M_XOR(rzh); goto info_ill2;
		case XOR_L:		M_XOR(rzl); goto info_ill2;
		case LD_H_H:	rzh=rzh; goto info_ill2;		// weird
		case LD_L_H:	rzl=rzh; goto info_ill2;		// weird
		case LD_H_L:	rzh=rzl; goto info_ill2;		// weird
		case LD_L_L:	rzl=rzl; goto info_ill2;		// weird

		case JP_HL:					pc=rz;			LOOP;	// 4+ 4 T
		case LD_SP_HL:	INCR_CC(2);	SP=rz;			LOOP;	// 4+ 6 T
		case DEC_HL:   	INCR_CC(2);	rz--;			LOOP;	// 4+ 6 T
		case INC_HL:	INCR_CC(2);	rz++;			LOOP;	// 4+ 6 T

		case ADD_HL_BC:	INCR_CC(7); M_ADDW(rz,BC);	LOOP;	// 4+ pc:4 +11
		case ADD_HL_DE:	INCR_CC(7); M_ADDW(rz,DE);	LOOP;
		case ADD_HL_HL:	INCR_CC(7); M_ADDW(rz,rz);	LOOP;
		case ADD_HL_SP:	INCR_CC(7); M_ADDW(rz,SP);	LOOP;

		case PUSH_HL:	INCR_CC(1);
						PUSH(rzh); PUSH(rzl);	LOOP;	// 4+ pc:5, sp-1:3, sp-2:3
		case POP_HL:	POP(rzl);  POP(rzh);	LOOP;	// 4+ pc:4, sp:3, sp+1:3

		case LD_HL_NN:	GET_NN(rz);				LOOP;	// 4+ pc:4, pc+1:3, pc+2:3

		case LD_xNN_HL:	GET_NN(w); POKE(w,rzl); POKE_AND_LOOP(w+1,rzh);	// 4+ pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3
		case LD_HL_xNN:	GET_NN(w); PEEK(rzl,w); PEEK(rzh,w+1);	LOOP;	// 4+ pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3

		case EX_HL_xSP:											// pc:4, pc+1:4, sp:3, sp+1:3,1, sp+1:3, sp:3,2x1
				w=rz;											// ((total:4+19; seq.: m1,m1,r,r,w,w))
				PEEK(rzl,SP); PEEK(rzh,SP+1); SKIP_1CC(SP+1);
				POKE(SP+1,w>>8); POKE(SP,w);  SKIP_2X1CC(SP);	// kio tested 2005-01-15
				Z80_INFO_EX_HL_xSP;
				LOOP;

		// ######## IXIY opcodes with dis ############################

		{ /* signed */ int8 dis;
		case LD_xHL_B:	c=RB; goto ld_x_c;			// pc:4, pc+1:4, pc+2:3, pc+2:1x5, ix+n:3
		case LD_xHL_C:	c=RC; goto ld_x_c;
		case LD_xHL_D:	c=RD; goto ld_x_c;
		case LD_xHL_E:	c=RE; goto ld_x_c;
		case LD_xHL_H:	c=RH; goto ld_x_c;
		case LD_xHL_L:	c=RL; goto ld_x_c;
		case LD_xHL_A:	c=ra; goto ld_x_c;
			   ld_x_c:	GET_N(dis); SKIP_5X1CC(pc-1); POKE_AND_LOOP(rz+dis,c);

		{ uint8* p;
		case LD_B_xHL:	p=&RB; goto ld_p_x;			// pc:4, pc+1:4, pc+2:3, pc+2:1x5, ix+n:3
		case LD_C_xHL:	p=&RC; goto ld_p_x;
		case LD_D_xHL:	p=&RD; goto ld_p_x;
		case LD_E_xHL:	p=&RE; goto ld_p_x;
		case LD_H_xHL:	p=&RH; goto ld_p_x;
		case LD_L_xHL:	p=&RL; goto ld_p_x;
				ld_p_x:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(*p,w);	LOOP;
		}
		case LD_A_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(ra,w);	LOOP;

		case LD_xHL_N:	GET_N(dis); GET_N(c); SKIP_2X1CC(pc-1);		// timing:	pc:4, pc+1:4, pc+2:3, pc+3:3,2x1, ix+n:3 (korr kio 2005-01-15)
						POKE_AND_LOOP(rz+dis,c);
		case DEC_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis;		// timing:	pc:4, pc+1:4, pc+2:3, pc+2:1x5, ix+n:3,1, ix+n:3
						PEEK(c,w);  SKIP_1CC(w); M_DEC(c); POKE_AND_LOOP(w,c);
		case INC_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis;
						PEEK(c,w);  SKIP_1CC(w); M_INC(c); POKE_AND_LOOP(w,c);

		case ADD_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_ADD(c); LOOP;	// pc:4, pc+1:4, pc+2:3, pc+2:1x5, ix+n:3
		case SUB_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_SUB(c); LOOP;
		case ADC_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_ADC(c); LOOP;
		case SBC_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_SBC(c); LOOP;
		case CP_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_CP(c);	 LOOP;
		case AND_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_AND(c); LOOP;
		case OR_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_OR(c);	 LOOP;
		case XOR_xHL:	GET_N(dis); SKIP_5X1CC(pc-1); w=rz+dis; PEEK(c,w); M_XOR(c); LOOP;
		}	// IXIY opcodes with dis

		// ######## IXIY opcodes + CB ############################

		case PFX_CB:
		//	Within an 8-instruction block, every illegal DD CB instruction works as
		//	the official one, but also copies the result to the specified register.
		//	((The information about the inofficial CB instructions was given to   ))
		//	((Gerton Lunter by Arnt Gulbrandsen, and originated from David Librik.))
		{	uint8 o; /*signed*/ int8 dis;

		// SHIFT, SET, and RES: 23 T cycles; BIT: 20 T cycles

		GET_N(dis);	w = rz+dis;		// target address
		GET_XYCB_OP(o);				// xycb opcode. does not increment r register!
		PEEK(c,w); SKIP_1CC(w);		// target

		switch (o>>3)				// instruction
		{
		case BIT0_xHL>>3: M_BIT(0x01,c); break;
		case BIT1_xHL>>3: M_BIT(0x02,c); break;	// timing:	pc:4, pc+1:4, pc+2:3, pc+3:3,2, ix+n:3,1
		case BIT2_xHL>>3: M_BIT(0x04,c); break;
		case BIT3_xHL>>3: M_BIT(0x08,c); break;
		case BIT4_xHL>>3: M_BIT(0x10,c); break;
		case BIT5_xHL>>3: M_BIT(0x20,c); break;
		case BIT6_xHL>>3: M_BIT(0x40,c); break;
		case BIT7_xHL>>3: M_BIT(0x80,c); break;

		case RLC_xHL>>3:  M_RLC(c);	 	break;
		case RRC_xHL>>3:  M_RRC(c);	 	break;	// timing:	pc:4, pc+1:4, pc+2:3, pc+3:3,2, ix+n:3,1, ix+n:3
		case RL_xHL>>3:	  M_RL(c); 	 	break;	// note: ergebnis wird noch via POKE_AND_LOOP geschrieben
		case RR_xHL>>3:	  M_RR(c); 	 	break;
		case SLA_xHL>>3:  M_SLA(c);	 	break;
		case SRA_xHL>>3:  M_SRA(c);	 	break;
		case SLL_xHL>>3:  M_SLL(c);	 	break;
		case SRL_xHL>>3:  M_SRL(c);	 	break;

		case RES0_xHL>>3: c &= ~0x01; 	break;	// timing:	pc:4, pc+1:4, pc+2:3, pc+3:3,2, ix+n:3,1, ix+n:3
		case RES1_xHL>>3: c &= ~0x02; 	break;	// note: ergebnis wird noch via POKE_AND_LOOP geschrieben
		case RES2_xHL>>3: c &= ~0x04; 	break;
		case RES3_xHL>>3: c &= ~0x08; 	break;
		case RES4_xHL>>3: c &= ~0x10; 	break;
		case RES5_xHL>>3: c &= ~0x20; 	break;
		case RES6_xHL>>3: c &= ~0x40; 	break;
		case RES7_xHL>>3: c &= ~0x80; 	break;

		case SET0_xHL>>3: c |= 0x01;  	break;	// timing:	pc:4, pc+1:4, pc+2:3, pc+3:3,2, ix+n:3,1, ix+n:3
		case SET1_xHL>>3: c |= 0x02;  	break;	// note: ergebnis wird noch via POKE_AND_LOOP geschrieben
		case SET2_xHL>>3: c |= 0x04;  	break;
		case SET3_xHL>>3: c |= 0x08;  	break;
		case SET4_xHL>>3: c |= 0x10;  	break;
		case SET5_xHL>>3: c |= 0x20;  	break;
		case SET6_xHL>>3: c |= 0x40;  	break;
		case SET7_xHL>>3: c |= 0x80;  	break;
		}

		switch(o&0x07)	// copy result to register (illegal opcodes only)
		{
		case 0:	RB=c; 	break;
		case 1:	RC=c; 	break;
		case 2:	RD=c; 	break;
		case 3:	RE=c; 	break;
		case 4:	RH=c; 	break;
		case 5:	RL=c; 	break;
		case 6:	if ( (o&0xc0)==0x40 ) LOOP;			// BIT
				if ((o>>3)==(SLL_xHL>>3)) { Z80_INFO_ILLEGAL(20,4,2); }	// SLL
				POKE_AND_LOOP(w,c);					// SET, RES or SHIFT
		case 7:	ra=c; 	break;
		}

		Z80_INFO_ILLEGAL(20,4,2);
		if ((o&0xc0)==0x40) LOOP;					// BIT
		POKE_AND_LOOP(w,c);							// SET, RES or SHIFT

		}	// IXIY + CB

		default:			// ix/iy prefix has no effect on operation:
							// => prefix worked like a NOP:
		Z80_INFO_ILLEGAL(8,2,2);		// weird illegal
		INCR_CC(-4);					// undo cc+=4
		r--;							// undo r++
		pc--;							// undo pc++	=> execute instruction without prefix
		goto loop_ei;	// no interrupt between prefix and next opcode possible  (source: z80-documented.pdf)

		}


	// ==========================================================================
	//	PREFIX CB COMMANDS
	// ==========================================================================

		case PFX_CB:					// 4 T: Timing berücksichtigt im CB-Dispatcher

		if (cpu_type == Cpu8080) goto ill_8080_jp;

		GET_CB_OP(w);					// fetch opcode

		// read source: b,c,d,e,h,l,(hl),a
		switch ( w&0x07 )
		{
		case 0:			c=RB;				break;
		case 1:			c=RC;				break;
		case 2:			c=RD;				break;
		case 3:			c=RE;				break;
		case 4:			c=RH;				break;
		case 5:			c=RL;				break;
		case 6:			PEEK(c,HL); SKIP_1CC(HL); break;
		case 7:			c=ra;				break;
		};

		// perform operation: shift/bit/res/set
		switch ( w>>3 )
		{
		case RLC_B>>3:	M_RLC(c);			break;
		case RRC_B>>3:	M_RRC(c);			break;
		case RL_B>>3:	M_RL(c);			break;
		case RR_B>>3:	M_RR(c);			break;
		case SLA_B>>3:	M_SLA(c);			break;
		case SRA_B>>3:	M_SRA(c);			break;
		case SLL_B>>3:	Z80_INFO_ILLEGAL(8,2,2);	M_SLL(c); break;
		case SRL_B>>3:	M_SRL(c);			break;

		case BIT0_B>>3:	M_BIT(0x01,c);		LOOP;	// bit tests have no store-back
		case BIT1_B>>3:	M_BIT(0x02,c);		LOOP;
		case BIT2_B>>3:	M_BIT(0x04,c);		LOOP;
		case BIT3_B>>3:	M_BIT(0x08,c);		LOOP;
		case BIT4_B>>3:	M_BIT(0x10,c);		LOOP;
		case BIT5_B>>3:	M_BIT(0x20,c);		LOOP;
		case BIT6_B>>3:	M_BIT(0x40,c);		LOOP;
		case BIT7_B>>3:	M_BIT(0x80,c);		LOOP;

		case RES0_B>>3:	c&=~0x01;			break;
		case RES1_B>>3:	c&=~0x02;			break;
		case RES2_B>>3:	c&=~0x04;			break;
		case RES3_B>>3:	c&=~0x08;			break;
		case RES4_B>>3:	c&=~0x10;			break;
		case RES5_B>>3:	c&=~0x20;			break;
		case RES6_B>>3:	c&=~0x40;			break;
		case RES7_B>>3:	c&=~0x80;			break;

		case SET0_B>>3:	c|=0x01;			break;
		case SET1_B>>3:	c|=0x02;			break;
		case SET2_B>>3:	c|=0x04;			break;
		case SET3_B>>3:	c|=0x08;			break;
		case SET4_B>>3:	c|=0x10;			break;
		case SET5_B>>3:	c|=0x20;			break;
		case SET6_B>>3:	c|=0x40;			break;
		case SET7_B>>3:	c|=0x80;			break;
		}

		// store back result:
		switch ( w&0x07 )
		{
		case 0:			RB=c;				LOOP;
		case 1:			RC=c;				LOOP;
		case 2:			RD=c;				LOOP;
		case 3:			RE=c;				LOOP;
		case 4:			RH=c;				LOOP;
		case 5:			RL=c;				LOOP;
		case 6:			POKE_AND_LOOP(HL,c);
		case 7:			ra=c;				LOOP;
		}
		IERR(); // unreachable


	// ==========================================================================
	//	PREFIX ED COMMANDS
	// ==========================================================================

		case PFX_ED:					// 4 T: Timing berücksichtigt im ED-Dispatcher

		if (cpu_type == Cpu8080) goto ill_8080_call;

		GET_ED_OP(c);

		switch(c)
		{
		case ADC_HL_BC: rzp=&registers.bc; goto adc_hl_rr;		// timing: pc:4, pc+1:11
		case ADC_HL_DE: rzp=&registers.de; goto adc_hl_rr;
		case ADC_HL_HL: rzp=&registers.hl; goto adc_hl_rr;
		case ADC_HL_SP: rzp=&registers.sp; goto adc_hl_rr;
			 adc_hl_rr:	INCR_CC(7); M_ADCW(rz); LOOP;

		case SBC_HL_BC: rzp=&registers.bc; goto sbc_hl_rr;		// timing: pc:4, pc+1:1
		case SBC_HL_DE: rzp=&registers.de; goto sbc_hl_rr;
		case SBC_HL_HL: rzp=&registers.hl; goto sbc_hl_rr;
		case SBC_HL_SP: rzp=&registers.sp; goto sbc_hl_rr;
			 sbc_hl_rr:	INCR_CC(7); M_SBCW(rz); LOOP;

		case LD_xNN_BC:	rzp = &registers.bc; goto ld_xnn_rr;		// timing: pc:4, pc+1:4, pc+2:3, pc+3:3, nn:3, nn+1:3
		case LD_xNN_DE:	rzp = &registers.de; goto ld_xnn_rr;
		case ED_xNN_HL:	rzp = &registers.hl; goto ld_xnn_rr;
		case LD_xNN_SP:	rzp = &registers.sp; goto ld_xnn_rr;
			 ld_xnn_rr:	GET_NN(w); POKE(w,rzl); POKE_AND_LOOP(w+1,rzh);

		case LD_BC_xNN:	GET_NN(w); PEEK(RC,w);  PEEK(RB,w+1); LOOP;	// timing: pc:4, pc+1:4, pc+2:3, pc+3:3, nn:3, nn+1:3
		case LD_DE_xNN:	GET_NN(w); PEEK(RE,w);  PEEK(RD,w+1); LOOP;
		case ED_HL_xNN:	GET_NN(w); PEEK(RL,w);  PEEK(RH,w+1); LOOP;
		case LD_SP_xNN:	GET_NN(w); PEEK(SPL,w); PEEK(SPH,w+1);LOOP;

		{ uint8* p;
		  uint8 z;
		case IN_F_xC:	p=&z;  goto in_r_xc;		// timing: pc:4, pc+1:4, IO
		case IN_B_xC:	p=&RB; goto in_r_xc;
		case IN_C_xC:	p=&RC; goto in_r_xc;
		case IN_D_xC:	p=&RD; goto in_r_xc;
		case IN_E_xC:	p=&RE; goto in_r_xc;
		case IN_H_xC:	p=&RH; goto in_r_xc;
		case IN_L_xC: 	p=&RL; goto in_r_xc;
			 in_r_xc:	M_IN(*p); LOOP;
		case IN_A_xC:	M_IN(ra); LOOP;
		}

		case OUT_xC_B:	c=RB; goto out_xc_r;		// timing: pc:4, pc+1:4, IO
		case OUT_xC_C: 	c=RC; goto out_xc_r;
		case OUT_xC_D: 	c=RD; goto out_xc_r;
		case OUT_xC_E: 	c=RE; goto out_xc_r;
		case OUT_xC_H: 	c=RH; goto out_xc_r;
		case OUT_xC_L: 	c=RL; goto out_xc_r;
		case OUT_xC_A: 	c=ra; goto out_xc_r;
			 out_xc_r:	OUTPUT(BC,c); LOOP;
		case OUT_xC_0: 	c=0; Z80_INFO_ILLEGAL(8,2,2); goto out_xc_r;

		case ED4E:		// illegal: im0
		case ED66:
		case ED6E:		Z80_INFO_ILLEGAL(8,2,2);
						FALLTHROUGH
		case IM_0:		registers.im=0; LOOP;
		case ED76:		Z80_INFO_ILLEGAL(8,2,2);	// illegal: im1
						FALLTHROUGH
		case IM_1:		registers.im=1; LOOP;
		case ED7E:		Z80_INFO_ILLEGAL(8,2,2);	// illegal: im2
						FALLTHROUGH
		case IM_2:		registers.im=2; LOOP;

		case ED4C:		// illegal NEG
		case ED54:
		case ED5C:
		case ED64:
		case ED6C:
		case ED74:
		case ED7C:		Z80_INFO_ILLEGAL(8,2,2);
						FALLTHROUGH
		case NEG:   	c=ra; ra=0; M_SUB(c); LOOP;

		case LD_I_A:   	INCR_CC(1);						// timing: pc:4, pc+1:5
						RI = ra;
						Z80_INFO_LD_I_A;
						LOOP;

		case LD_R_A:   	INCR_CC(1);						// timing: pc:4, pc+1:5
						registers.r = r = ra;
						Z80_INFO_LD_R_A;
						LOOP;

		case LD_A_I:	INCR_CC(1);						// timing: pc:4, pc+1:5
						ra	= RI;
						rf	= (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
						LOOP;

		case LD_A_R:	INCR_CC(1);						// timing: pc:4, pc+1:5
						ra = (registers.r&0x80) + (r&0x7F);
						rf	= (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
						LOOP;

		/*	RETI, RETN and illegal variants:
			They all copy iff2 -> iff1, like documented for RETN (source: z80-documented.pdf)
			Whether any of these opcodes is recognized as RETI solely depends on the peripherial IC (namely the Z80 PIO)
			whether it decodes that opcode as 'RETI'.
		*/
		case RETI:	Z80_INFO_RETI;						// timing: pc:4, pc+1:4, sp:3, sp+1:3
					IFF1=IFF2;							// lt. z80-documented.pdf: all RETN _and_ all RETI copy iff2 -> iff1
					goto ret;

		case ED5D:	// illegal: retn
		case ED6D:
		case ED7D:
		case ED55:
		case ED65:
		case ED75:	Z80_INFO_ILLEGAL(8,2,2);		// timing: pc:4, pc+1:4, sp:3, sp+1:3
					FALLTHROUGH
		case RETN:	Z80_INFO_RETN;
					IFF1=IFF2;
					goto ret;

		{ uint8 o;
		case RRD:	w=HL; PEEK(o,w);					// timing: pc:4, pc+1:4, hl:3,4*1, hl:3
					c	= (o>>4) + (ra<<4);
					ra	= (ra&0xF0) + (o&0x0F);
					goto rld;

		case RLD:	w=HL; PEEK(o,w);					// timing: pc:4, pc+1:4, hl:3,4*1, hl:3
					c 	= (o<<4) + (ra&0x0F);
					ra	= (ra&0xF0)+(o>>4);
			 rld:	rf	= (rf&C_FLAG) + zlog_flags[ra];
					SKIP_4X1CC(w);						// HL (kio-tested-2005-01-09)
					POKE_AND_LOOP(w,c);
		}


		// ########	Block Instructions ###############################

		//			kio 2000-06-26: LDIR etc. _are_ interruptable!
		//			block commands are implemented as the z80 do them:
		//			do the instruction once and decrement the pc if not yet finished
		//			so that the next M1 cycle will fetch the same block instruction again.
		//			=>	interruptable
		//				proper T cycle timing and r register emulation
		//				proper malbehavior when block commands start overwriting itself

		case LDDR:	w = uint16(-1); goto ldir;			// Load, decrement and repeat
		case LDIR:	w = 1;								// Load, increment and repeat
		ldir:		PEEK(c,HL);							// timing:  pc:4, pc+1:4, hl:3, de:3,2x1 [de:5x1] (kio tested 2005-01-15)
					POKE(DE,c);
					rf &= ~(N_FLAG+H_FLAG+P_FLAG);
					if (--BC) { rf |= P_FLAG; pc-=2; SKIP_7X1CC(DE); } else { SKIP_2X1CC(DE); } 	// DE before ++/--
					DE+=w; HL+=w;
					LOOP;

		case LDD:	w = uint16(-1); goto ldi;			// Load and decrement
		case LDI:	w = 1;								// Load and increment
		ldi:		PEEK(c,HL); HL+=w;					// timing:  pc:4, pc+1:4, hl:3, de:3,2x1  (kio tested 2005-01-15)
					POKE(DE,c);
					SKIP_2X1CC(DE);						// DE before incremented (kio-tested-2005-01-09)
					DE+=w;
					rf &= ~(N_FLAG+H_FLAG+P_FLAG);
					if (--BC) rf |= P_FLAG;
					LOOP;


		case CPDR:	w = HL--; goto cpir;				// Compare, decrement and repeat
		case CPIR:	w = HL++;							// Compare, increment and repeat
		cpir:		PEEK(c,w); c = ra - c;				// timing: pc:4, pc+1:4, hl:3,5*1,[5*1]  (kio verified 2005-01-10)
					SKIP_5X1CC(w);
					BC -= 1;
					rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
					if (BC&&c) { pc-=2; SKIP_5X1CC(w); }	// LOOP not yet finished
					LOOP;

		case CPD:	w = HL--; goto cpi;					// Compare and decrement
		case CPI:	w = HL++;							// Compare and increment
		cpi:		PEEK(c,w); c = ra - c;				// timing: pc:4, pc+1:4, hl:3,5*1
					SKIP_5X1CC(w);
					BC -= 1;
					rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
					LOOP;


		case INDR:	w = HL--; goto inir;				// input, decrement and repeat
		case INIR:	w = HL++;							// input, increment and repeat
		inir:		INCR_CC(1);							// timing: pc:4, pc+1:5, IO, hl:3,[5*1]
					INPUT(BC,c);
					POKE(w,c);
					if (--RB) { pc-=2; SKIP_5X1CC(w); }	// LOOP not yet finished
					rf = N_FLAG + (RB?0:Z_FLAG);		// TODO: INIR etc.: flags checken
					LOOP;

		case IND:	w = HL--; goto ini;					// input and decrement
		case INI:	w = HL++;							// input and increment
		ini:		INCR_CC(1);							// timing: pc:4, pc+1:5, IO, hl:3
					INPUT(BC,c);
					rf = N_FLAG + (--RB?0:Z_FLAG);
					POKE_AND_LOOP(w,c);


		case OTDR:	w = HL--; goto otir;				// output, decrement and repeat
		case OTIR:	w = HL++;							// output, increment and repeat
		otir:		INCR_CC(1);							// timing:  pc:4, pc+1:5, hl:3, IO, [hl:5*1]
					PEEK(c,w);
					--RB;								// kio 2005-11-18: OUTI: decr B before putting it on the bus
					OUTPUT(BC,c);						// [post on css by Alvin Albrecht]
					if (RB) { pc-=2; SKIP_5X1CC(w); }
					rf = N_FLAG + (RB?0:Z_FLAG);
					LOOP;

		case OUTD:	w = HL--; goto outi;				// output and decrement
		case OUTI:	w = HL++;							// output and increment
		outi:		INCR_CC(1);							// timing: pc:4, pc+1:5, hl:3, IO
					PEEK(c,w);
					--RB;								// kio 2005-11-18: OUTI: decr B before putting it on the bus
					OUTPUT(BC,c);						// [post on css by Alvin Albrecht]
					rf = N_FLAG + (RB?0:Z_FLAG);
					LOOP;


		// ---------------------------------------------

		default:	// ED77, ED7F, ED00-ED3F and ED80-EDFF except block instr
					Z80_INFO_ILLEGAL(8,2,2);
					LOOP;
		}

		//default:	break;

		}  // opcode dispatcher

		IERR();						// all opcodes decoded!

	}  // while(cc<cc_exit)

	if (result == TimeOut && cc < ccx0) goto slow_loop; // not yet timed out

x:	SAVE_REGISTERS;
	return result;

	}
	catch(...)
	{
		SAVE_REGISTERS;
		throw;
	}
}





























