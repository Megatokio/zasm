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

	8080, Z80 and Z180 Emulator
	initially based on fMSX; Copyright (C) Marat Fayzullin 1994,1995
*/

#include "kio/kio.h"
#include "Z80/goodies/z80_goodies.h"
#include "Z80/goodies/z80_opcodes.h"
#include "Z80.h"
#include "z80macros.h"

const uint8 Z80::zlog_flags[256] =
{
	// conversion table: A -> Z80-flags with S, Z, V=parity and C=0
	// 2013-06-12:		 A -> Z80-flags with S, Z, V=parity and C=0, bits 3 and 5 verbatim from A
	#define FLAGS0(A)	(A&0xA8) + ((A==0)<<6) + (((~A+(A>>1)+(A>>2)+(A>>3)+(A>>4)+(A>>5)+(A>>6)+(A>>7))&1) << 2)
	#define FLAGS2(A)	FLAGS0(A), FLAGS0((A+1 )), FLAGS0((A+2 )), FLAGS0((A+3))
	#define FLAGS4(A)	FLAGS2(A), FLAGS2((A+4 )), FLAGS2((A+8 )), FLAGS2((A+12))
	#define FLAGS6(A)	FLAGS4(A), FLAGS4((A+16)), FLAGS4((A+32)), FLAGS4((A+48))
	FLAGS6(0), FLAGS6(64), FLAGS6(128), FLAGS6(192)
};


Z80::Z80 (CpuID cpu_type, CoreByte* core, InputHandler input, OutputHandler output)
:
	core(core),
	input(input),
	output(output),
	cpu_type(cpu_type?cpu_type:CpuZ80)
{
	reset();
}

void Z80::reset() noexcept
{
	registers.reset();
	cc   = 0;
	halt = no;
	int_off = yes;	// startup with no interrupt pending (used in automatic switch-off mode only)
	int_start = 0;	// start cc for interrupts
	int_end = 0;	// end cc for interrupts; start==end = automatic switch-off mode
}


// read byte from memory
#define	PEEK(DEST,ADDR)	do{ cc+=3; DEST = peek(ADDR); }while(0)

// write byte into memory
#define	POKE(ADDR,BYTE)	do{ cc+=3; poke(ADDR,BYTE); }while(0)

// read instruction byte at PC (M1 cycle)
#define	GET_INSTR(R)	do{ cc+=4; r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after 0xCB opcode
#define	GET_CB_OP(R)	do{ cc+=4; r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after 0xED opcode
#define	GET_ED_OP(R)	do{ cc+=4; r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after IX or IY opcode prefix
#define	GET_XY_OP(R)	do{ cc+=4; r+=1; R = peek(pc++); }while(0)

// read 3rd instruction byte after IX or IY prefix and 0xCB opcode
#define	GET_XYCB_OP(R)	do{ cc+=5; R = peek(pc++); }while(0)

// read byte at PC
#define	GET_N(R)		do{ cc+=3; R = peek(pc++); }while(0)

// dummy read byte at PC
#define	SKIP_N()		do{ cc+=3; peek(pc++); }while(0)

// output byte to address
#define	OUTPUT(A,B)		do{ cc+=4; output(cc-2,A,B); }while(0)

// input byte from address
#define	INPUT(A,B)		do{ cc+=4; B = input(cc-2,A); }while(0)


Z80::RVal Z80::run (CpuCycle ccx)
{
	if (cpu_type == CpuZ180) return runZ180(ccx);
	//bool isa_8080 = cpu_type == Cpu8080;
	#define isa_8080 (cpu_type == Cpu8080)

	CpuCycle cc;			// cpu cycle counter
	CpuCycle ccx0 = ccx;

	uint16	pc;				// z80 program counter
	uint8	ra;				// z80 a register
	uint8	rf;				// z80 flags
	uint8	r;				// z80 r register bit 0...6

	#define	LOAD_REGISTERS do{ 						\
	r	= registers.r;	/* refresh counter R	*/	\
	cc	= this->cc;		/* cpu cycle counter	*/	\
	pc	= registers.pc;	/* program counter PC	*/	\
	ra	= registers.a;	/* register A			*/	\
	rf	= registers.f;	/* register F			*/	\
	}while(0)

	#define	SAVE_REGISTERS do{						\
	registers.r	 = (registers.r&0x80)|(r&0x7f);		\
	this->cc	 = cc;	/* cpu cycle counter	*/	\
	registers.pc = pc;	/* program counter PC	*/	\
	registers.a	 = ra;	/* register A			*/	\
	registers.f	 = rf;	/* register F			*/	\
	}while(0)

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
	#define EXIT(RESULT)		do{ w=RESULT; goto x; }while(0)

// load local variables from data members:
	LOAD_REGISTERS;

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
	//		 the /INT signal is sampled once per instruction at the end of instruction.
	//		 if the /INT signal goes away before it is accepted then it is lost!

	ccx = ccx0;						// restore cc for fast exit test
	if (cc < int_start) { ccx = min(int_start,ccx); LOOP; } // interrupt not yet asserted
	if (IFF1 == disabled) LOOP;		// int disabled in cpu

	if (int_start == int_end) 		// automatic switch-off mode?
	{
		if (int_off) LOOP;			// interrupts off or already processed
		else int_off = yes;			// switch off interrupt in int ack cycle
	}
	else							// interrupt with duration
	{
		if (cc >= int_end) LOOP;	// interrupt no longer asserted
	}

	if (halt) { assert(peek(pc)==HALT); halt=no; pc++; }

	IFF1 = IFF2 = disabled;			// disable interrupt
	r += 1;
	cc += 7;
	PUSH(pc>>8);
	PUSH(pc);

	switch (registers.im)
	{
	case 0:  // mode 0: read instruction from bus
		if ((int_ack_byte&0xC7)!=RST00) exit(UnsupportedIntAckByte);
		pc = Address(int_ack_byte - RST00);
		LOOP;

	case 1:  // Mode 1:	RST38
		pc = 0x0038;
		LOOP;

	case 2:  // Mode 2:	jump via table
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

poke_and_nxtcmd:
	POKE(w,c);						// cc+=3, poke(w,c)

nxtcmnd:
	while (cc < ccx)				// fast loop exit test
	{
		GET_INSTR(c);

		switch (c)
		{

		// ########	4 T cycle Instructions #########################

		// LD R,R
		{
		case LD_B_B:			LOOP; // 4 T
		case LD_C_B:	RC=RB;	LOOP;
		case LD_D_B:	RD=RB;	LOOP;
		case LD_E_B:	RE=RB;	LOOP;
		case LD_H_B:	RH=RB;	LOOP;
		case LD_L_B:	RL=RB;	LOOP;
		case LD_A_B:	ra=RB;	LOOP;

		case LD_B_C:	RB=RC;	LOOP;
		case LD_C_C:			LOOP;
		case LD_D_C:	RD=RC;	LOOP;
		case LD_E_C:	RE=RC;	LOOP;
		case LD_H_C:	RH=RC;	LOOP;
		case LD_L_C:	RL=RC;	LOOP;
		case LD_A_C:	ra=RC;	LOOP;

		case LD_B_D:	RB=RD;	LOOP;
		case LD_C_D:	RC=RD;	LOOP;
		case LD_D_D:			LOOP;
		case LD_E_D:	RE=RD;	LOOP;
		case LD_H_D:	RH=RD;	LOOP;
		case LD_L_D:	RL=RD;	LOOP;
		case LD_A_D:	ra=RD;	LOOP;

		case LD_B_E:	RB=RE;	LOOP;
		case LD_C_E:	RC=RE;	LOOP;
		case LD_D_E:	RD=RE;	LOOP;
		case LD_E_E:			LOOP;
		case LD_H_E:	RH=RE;	LOOP;
		case LD_L_E:	RL=RE;	LOOP;
		case LD_A_E:	ra=RE;	LOOP;

		case LD_B_H:	RB=RH;	LOOP;
		case LD_C_H:	RC=RH;	LOOP;
		case LD_D_H:	RD=RH;	LOOP;
		case LD_E_H:	RE=RH;	LOOP;
		case LD_H_H:			LOOP;
		case LD_L_H:	RL=RH;	LOOP;
		case LD_A_H:	ra=RH;	LOOP;

		case LD_B_L:	RB=RL;	LOOP;
		case LD_C_L:	RC=RL;	LOOP;
		case LD_D_L:	RD=RL;	LOOP;
		case LD_E_L:	RE=RL;	LOOP;
		case LD_H_L:	RH=RL;	LOOP;
		case LD_L_L:			LOOP;
		case LD_A_L:	ra=RL;	LOOP;

		case LD_B_A:	RB=ra;	LOOP;
		case LD_C_A:	RC=ra;	LOOP;
		case LD_D_A:	RD=ra;	LOOP;
		case LD_E_A:	RE=ra;	LOOP;
		case LD_H_A:	RH=ra;	LOOP;
		case LD_L_A:	RL=ra;	LOOP;
		case LD_A_A:			LOOP;
		}

		// ARI R,R
		{
		case ADD_B:		M_ADD(RB); LOOP; // 4 T
		case ADD_C:		M_ADD(RC); LOOP;
		case ADD_D:		M_ADD(RD); LOOP;
		case ADD_E:		M_ADD(RE); LOOP;
		case ADD_H:		M_ADD(RH); LOOP;
		case ADD_L:		M_ADD(RL); LOOP;
		case ADD_A:		M_ADD(ra); LOOP;

		case SUB_B:		M_SUB(RB); LOOP;
		case SUB_C:		M_SUB(RC); LOOP;
		case SUB_D:		M_SUB(RD); LOOP;
		case SUB_E:		M_SUB(RE); LOOP;
		case SUB_H:		M_SUB(RH); LOOP;
		case SUB_L:		M_SUB(RL); LOOP;
		case SUB_A:		M_SUB(ra); LOOP;

		case ADC_B:		M_ADC(RB); LOOP;
		case ADC_C:		M_ADC(RC); LOOP;
		case ADC_D:		M_ADC(RD); LOOP;
		case ADC_E:		M_ADC(RE); LOOP;
		case ADC_H:		M_ADC(RH); LOOP;
		case ADC_L:		M_ADC(RL); LOOP;
		case ADC_A:		M_ADC(ra); LOOP;

		case SBC_B:		M_SBC(RB); LOOP;
		case SBC_C:		M_SBC(RC); LOOP;
		case SBC_D:		M_SBC(RD); LOOP;
		case SBC_E:		M_SBC(RE); LOOP;
		case SBC_H:		M_SBC(RH); LOOP;
		case SBC_L:		M_SBC(RL); LOOP;
		case SBC_A:		M_SBC(ra); LOOP;

		case CP_B:		M_CP(RB); LOOP;
		case CP_C:		M_CP(RC); LOOP;
		case CP_D:		M_CP(RD); LOOP;
		case CP_E:		M_CP(RE); LOOP;
		case CP_H:		M_CP(RH); LOOP;
		case CP_L:		M_CP(RL); LOOP;
		case CP_A:		M_CP(ra); LOOP;

		case AND_B:		M_AND(RB);LOOP;
		case AND_C:		M_AND(RC);LOOP;
		case AND_D:		M_AND(RD);LOOP;
		case AND_E:		M_AND(RE);LOOP;
		case AND_H:		M_AND(RH);LOOP;
		case AND_L:		M_AND(RL);LOOP;
		case AND_A:		M_AND(ra);LOOP;

		case OR_B:		M_OR(RB); LOOP;
		case OR_C:		M_OR(RC); LOOP;
		case OR_D:		M_OR(RD); LOOP;
		case OR_E:		M_OR(RE); LOOP;
		case OR_H:		M_OR(RH); LOOP;
		case OR_L:		M_OR(RL); LOOP;
		case OR_A:		M_OR(ra); LOOP;

		case XOR_B:		M_XOR(RB);LOOP;
		case XOR_C:		M_XOR(RC);LOOP;
		case XOR_D:		M_XOR(RD);LOOP;
		case XOR_E:		M_XOR(RE);LOOP;
		case XOR_H:		M_XOR(RH);LOOP;
		case XOR_L:		M_XOR(RL);LOOP;
		case XOR_A:		M_XOR(ra);LOOP;
		}

		// INC R \ DEC R
		{
		case DEC_B:		M_DEC(RB);LOOP; // 4 T
		case DEC_C:		M_DEC(RC);LOOP;
		case DEC_D:		M_DEC(RD);LOOP;
		case DEC_E:		M_DEC(RE);LOOP;
		case DEC_H:		M_DEC(RH);LOOP;
		case DEC_L:		M_DEC(RL);LOOP;
		case DEC_A:		M_DEC(ra);LOOP;

		case INC_B:		M_INC(RB);LOOP;
		case INC_C:		M_INC(RC);LOOP;
		case INC_D:		M_INC(RD);LOOP;
		case INC_E:		M_INC(RE);LOOP;
		case INC_H:		M_INC(RH);LOOP;
		case INC_L:		M_INC(RL);LOOP;
		case INC_A:		M_INC(ra);LOOP;
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
			if (isa_8080) goto ill_op1;
			c=ra;ra=RA2;RA2=c;
			c=rf;rf=RF2;RF2=c;
			LOOP;

		case EXX:
			if (isa_8080) goto ill_op1;
			w=BC;BC=BC2;BC2=w;			// 4 T
			w=DE;DE=DE2;DE2=w;
			w=HL;HL=HL2;HL2=w;
			LOOP;

		case HALT:						// 4 T  ((executes NOPs until interrupt))
			pc--;
			if (halt) LOOP;
			if (pc == breakpoint) { cc-=4; r--; EXIT(BreakPoint); }
			halt = true;
			LOOP;

		case NOP:						// 4 T
			LOOP;

		case DI:						// 4 T
			IFF1=IFF2=disabled;
			LOOP;

		case EI:						// 4 T
			IFF1=IFF2=enabled;
			ccx = cc+1;			// exit the fast loop after next cmd -> reload ccx & goto slow_loop
			LOOP;				// der nächste Befehl wird auf jeden Fall noch ausgeführt.

		case SCF:						// 4 T
			rf |= C_FLAG;
			rf &= ~(N_FLAG+H_FLAG);
			LOOP;

		case CCF:						// 4 T
			rf ^= C_FLAG;
			rf &= ~N_FLAG;
			LOOP;

		case CPL:						// 4 T
			ra = ~ra;
			rf |= N_FLAG+H_FLAG;
			LOOP;

		case RLCA:
			ra = uint8(ra<<1) + (ra>>7);		// 4 T
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra&C_FLAG);
			LOOP;

		case RRCA:
			ra = (ra>>1) + uint8(ra<<7);		// 4 T
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra>>7);
			LOOP;

		case RLA:
			c  = ra>>7;							// 4 T
			ra = uint8(ra<<1) + (rf&C_FLAG);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
			LOOP;

		case RRA:
			c  = ra&C_FLAG;						// 4 T
			ra = (ra>>1) + uint8(rf<<7);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
			LOOP;

		case DAA:
			if (rf&N_FLAG)						// 4 T
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
		case DEC_BC:	cc += 2; BC--;	LOOP;		// cc = 6
		case DEC_DE:	cc += 2; DE--;	LOOP;
		case DEC_HL:	cc += 2; HL--;	LOOP;
		case DEC_SP:	cc += 2; SP--;	LOOP;
		case INC_BC:	cc += 2; BC++;	LOOP;
		case INC_DE:	cc += 2; DE++;	LOOP;
		case INC_HL:	cc += 2; HL++;	LOOP;
		case INC_SP:	cc += 2; SP++;	LOOP;

		case LD_SP_HL:	cc += 2; SP = HL; LOOP;		// cc = 6

		case ADD_HL_BC:	cc += 7; M_ADDW(HL,BC); LOOP;	// cc = 47
		case ADD_HL_DE:	cc += 7; M_ADDW(HL,DE); LOOP;
		case ADD_HL_HL:	cc += 7; M_ADDW(HL,HL); LOOP;
		case ADD_HL_SP:	cc += 7; M_ADDW(HL,SP); LOOP;
		}

		// ########	Read-only-from-memory Instructions #########################
		{
		case LD_B_xHL:	uint8* p;
						p=&RB; goto ld_xhl;		// cc = 43
		case LD_C_xHL:	p=&RC; goto ld_xhl;
		case LD_D_xHL:	p=&RD; goto ld_xhl;
		case LD_E_xHL:	p=&RE; goto ld_xhl;
		case LD_H_xHL:	p=&RH; goto ld_xhl;
		case LD_L_xHL:	p=&RL; goto ld_xhl;
		ld_xhl:
			PEEK(*p,HL);
			LOOP;

		case LD_B_N:	p=&RB; goto ld_n;		// cc = 43
		case LD_C_N:	p=&RC; goto ld_n;
		case LD_D_N:	p=&RD; goto ld_n;
		case LD_E_N:	p=&RE; goto ld_n;
		case LD_H_N:	p=&RH; goto ld_n;
		case LD_L_N:	p=&RL; goto ld_n;
		ld_n:
			GET_N(*p);
			LOOP;
		}

		case LD_A_N:	GET_N(ra); LOOP;		// cc = 43

		case ADD_xHL:	PEEK(c,HL);   M_ADD(c); LOOP;	// cc = 43
		case SUB_xHL:	PEEK(c,HL);   M_SUB(c); LOOP;
		case ADC_xHL:	PEEK(c,HL);   M_ADC(c); LOOP;
		case SBC_xHL:	PEEK(c,HL);   M_SBC(c); LOOP;
		case CP_xHL:	PEEK(c,HL);   M_CP(c);  LOOP;
		case OR_xHL:	PEEK(c,HL);   M_OR(c);  LOOP;
		case XOR_xHL:	PEEK(c,HL);   M_XOR(c); LOOP;
		case AND_xHL:	PEEK(c,HL);   M_AND(c); LOOP;

		case ADD_N:		GET_N(c);   M_ADD(c); LOOP;		// cc = 43
		case ADC_N:		GET_N(c);   M_ADC(c); LOOP;
		case SUB_N:		GET_N(c);   M_SUB(c); LOOP;
		case SBC_N:		GET_N(c);   M_SBC(c); LOOP;
		case CP_N:		GET_N(c);   M_CP(c);  LOOP;
		case OR_N:		GET_N(c);   M_OR(c);  LOOP;
		case XOR_N:		GET_N(c);   M_XOR(c); LOOP;
		case AND_N:		GET_N(c);   M_AND(c); LOOP;

		case LD_SP_NN: 	rzp=&registers.sp; goto ld_nn;	// cc = 433
		case LD_BC_NN: 	rzp=&registers.bc; goto ld_nn;
		case LD_DE_NN: 	rzp=&registers.de; goto ld_nn;
		case LD_HL_NN: 	rzp=&registers.hl; goto ld_nn;
		ld_nn:
			GET_N(rzl); GET_N(rzh);
			LOOP;

		case JP_NZ:		if (rf&Z_FLAG) goto njp; else goto jp;	// cc = 433
		case JP_NC:		if (rf&C_FLAG) goto njp; else goto jp;
		case JP_PO:		if (rf&P_FLAG) goto njp; else goto jp;
		case JP_P:		if (rf&S_FLAG) goto njp; else goto jp;
		case JP_C:		if (rf&C_FLAG) goto jp; else goto njp;
		case JP_PE:		if (rf&P_FLAG) goto jp; else goto njp;
		case JP_M:		if (rf&S_FLAG) goto jp; else goto njp;
		case JP_Z:		if (rf&Z_FLAG) goto jp; else goto njp;
		njp:SKIP_N(); SKIP_N();
			LOOP;

		case JP:					// cc = 433
		jp:	GET_NN(w);
			pc = w;
			LOOP;

		case JR:					// cc = 435
			if (isa_8080) goto ill_op1;
		jr:	GET_N(c);
			cc += 5;
			pc += int8(c);
			LOOP;

		case JR_Z:					// cc = 43[5]
			if (isa_8080) goto ill_op1;
			if (rf&Z_FLAG) goto jr; else goto njr;
		njr:SKIP_N();
			LOOP;

		case JR_C:					// cc = 43[5]
			if (isa_8080) goto ill_op1;
			if (rf&C_FLAG) goto jr; else goto njr;

		case JR_NZ:					// cc = 43[5]
			if (isa_8080) goto ill_op1;
			if (rf&Z_FLAG) goto njr; else goto jr;

		case JR_NC:					// cc = 43[5]
			if (isa_8080) goto ill_op1;
			if (rf&C_FLAG) goto njr; else goto jr;

		case DJNZ:					// pc:5, pc+1:3,[5*1]
			if (isa_8080) goto ill_op1;
			cc += 1;
			if (--RB) goto jr; else goto njr;

		case RET:					// timing: pc:4, sp:3, sp+1:3
		ret:POP(PCL); POP(PCH);
			pc = PC;
			LOOP;

		case RET_NZ:	cc += 1; if(rf&Z_FLAG) LOOP; else goto ret;	// cc = 5[33]
		case RET_NC:	cc += 1; if(rf&C_FLAG) LOOP; else goto ret;
		case RET_PO:	cc += 1; if(rf&P_FLAG) LOOP; else goto ret;
		case RET_P:		cc += 1; if(rf&S_FLAG) LOOP; else goto ret;
		case RET_Z:		cc += 1; if(rf&Z_FLAG) goto ret; else LOOP;
		case RET_C:		cc += 1; if(rf&C_FLAG) goto ret; else LOOP;
		case RET_PE:	cc += 1; if(rf&P_FLAG) goto ret; else LOOP;
		case RET_M:		cc += 1; if(rf&S_FLAG) goto ret; else LOOP;

		case LD_A_xNN:	GET_NN(w); goto ld_a_xw;	// cc = 4333
		case LD_A_xBC:	w=BC;      goto ld_a_xw;	// cc = 43
		case LD_A_xDE:	w=DE;	   goto ld_a_xw;	// cc = 43
		case LD_A_xHL:	w=HL;	   goto ld_a_xw;	// cc = 43
		ld_a_xw:
			PEEK(ra,w);
			LOOP;

		case LD_HL_xNN:				// cc = 43333
			GET_NN(w);
			PEEK(RL,w); PEEK(RH,w+1);
			LOOP;

		case POP_BC:	rzp=&registers.bc; goto pop_rr;
		case POP_DE:	rzp=&registers.de; goto pop_rr;
		case POP_HL:	rzp=&registers.hl; goto pop_rr;
		pop_rr:
			POP(rzl); POP(rzh);		// cc = 433
			LOOP;

		case POP_AF:
			POP(rf); POP(ra);		// cc = 433
			LOOP;

		case OUTA:					// cc = 43o
			GET_N(c);
			OUTPUT ( ra*256 + c, ra );
			LOOP;

		case INA:					// cc = 43i
			GET_N(c);
			INPUT ( ra*256 + c, ra );
			LOOP;


		// ########	Write-to-memory Instructions #####################
		case CALL_NC: 	if (rf&C_FLAG) goto nocall; else goto call;	// cc = 433[133]
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

		case CALL:			// cc = 433133
		call:
			GET_NN(w);
		rst:cc += 1;
			PUSH(pc>>8);
			PUSH(pc);
			pc = w;
			LOOP;

		case RST00:	w=0x0000; goto rst;	// cc = 533
		case RST08: w=0x0008; goto rst;
		case RST10: w=0x0010; goto rst;
		case RST18: w=0x0018; goto rst;
		case RST20: w=0x0020; goto rst;
		case RST28: w=0x0028; goto rst;
		case RST30: w=0x0030; goto rst;
		case RST38: w=0x0038; goto rst;

		case DEC_xHL:				// cc = 4313
			w = HL;
			PEEK(c,w); cc += 1; M_DEC(c);
			POKE_AND_LOOP(w,c);

		case INC_xHL:				// cc = 4313
			w = HL;
			PEEK(c,w); cc += 1; M_INC(c);
			POKE_AND_LOOP(w,c);

		case LD_xHL_B:	POKE_AND_LOOP(HL,RB);	// cc = 43
		case LD_xHL_C:	POKE_AND_LOOP(HL,RC);
		case LD_xHL_D:	POKE_AND_LOOP(HL,RD);
		case LD_xHL_E:	POKE_AND_LOOP(HL,RE);
		case LD_xHL_H:	POKE_AND_LOOP(HL,RH);
		case LD_xHL_L:	POKE_AND_LOOP(HL,RL);
		case LD_xHL_A:	POKE_AND_LOOP(HL,ra);
		case LD_xBC_A:	POKE_AND_LOOP(BC,ra);
		case LD_xDE_A:	POKE_AND_LOOP(DE,ra);

		case LD_xHL_N:	GET_N(c);  POKE_AND_LOOP(HL,c);					// cc = 433
		case LD_xNN_A:	GET_NN(w); POKE_AND_LOOP(w,ra);					// cc = 4333
		case LD_xNN_HL:	GET_NN(w); POKE(w,RL); POKE_AND_LOOP(w+1,RH);	// cc = 43333

		case PUSH_BC:	w=BC; goto push_w;
		case PUSH_DE:	w=DE; goto push_w;
		case PUSH_HL:	w=HL; goto push_w;
				push_w:	cc += 1; PUSH(wh); PUSH(wl); LOOP;	// cc = 533
		case PUSH_AF:	cc += 1; PUSH(ra); PUSH(rf); LOOP;	// cc = 533

		case EX_HL_xSP:										// cc = 4331332
			w = HL;
			PEEK(RL,SP); PEEK(RH,SP+1); cc += 1;
			POKE(SP+1,wh); POKE(SP,wl); cc += 2;
			LOOP;


		// ==========================================================================
		//	PREFIX IX / IY COMMANDS
		// ==========================================================================

		case PFX_IY: rzp = &registers.iy; goto XY;
		case PFX_IX: rzp = &registers.ix; goto XY;
		{
		XY:	if (isa_8080) goto ill_op1;
			GET_XY_OP(c);

			switch (c)
			{

			// illegals with XH, XL:
			{
			case LD_H_B:	rzh=RB; LOOP;
			case LD_L_B:   	rzl=RB; LOOP;
			case LD_H_C:	rzh=RC; LOOP;
			case LD_L_C:	rzl=RC; LOOP;
			case LD_H_D:	rzh=RD; LOOP;
			case LD_L_D:	rzl=RD; LOOP;
			case LD_H_E:	rzh=RE; LOOP;
			case LD_L_E:	rzl=RE; LOOP;
			case LD_B_H:	RB=rzh; LOOP;
			case LD_C_H:	RC=rzh; LOOP;
			case LD_D_H:	RD=rzh; LOOP;
			case LD_E_H:	RE=rzh; LOOP;
			case LD_A_H:	ra=rzh; LOOP;
			case LD_B_L:	RB=rzl; LOOP;
			case LD_C_L:	RC=rzl; LOOP;
			case LD_D_L:	RD=rzl; LOOP;
			case LD_E_L:	RE=rzl; LOOP;
			case LD_A_L:	ra=rzl; LOOP;
			case LD_H_A:	rzh=ra; LOOP;
			case LD_L_A:	rzl=ra; LOOP;
			case LD_H_N:	GET_N(rzh); LOOP;
			case LD_L_N:	GET_N(rzl); LOOP;
			case DEC_H:		M_DEC(rzh); LOOP;
			case DEC_L:		M_DEC(rzl); LOOP;
			case INC_H:		M_INC(rzh); LOOP;
			case INC_L:		M_INC(rzl); LOOP;
			case ADD_H:		M_ADD(rzh); LOOP;
			case ADD_L:		M_ADD(rzl); LOOP;
			case SUB_H:		M_SUB(rzh); LOOP;
			case SUB_L:		M_SUB(rzl); LOOP;
			case ADC_H:		M_ADC(rzh); LOOP;
			case ADC_L:		M_ADC(rzl); LOOP;
			case SBC_H:		M_SBC(rzh); LOOP;
			case SBC_L:		M_SBC(rzl); LOOP;
			case CP_H:		M_CP(rzh);	LOOP;
			case CP_L:		M_CP(rzl);	LOOP;
			case AND_H:		M_AND(rzh); LOOP;
			case AND_L:		M_AND(rzl); LOOP;
			case OR_H:		M_OR(rzh);	LOOP;
			case OR_L:		M_OR(rzl);	LOOP;
			case XOR_H:		M_XOR(rzh); LOOP;
			case XOR_L:		M_XOR(rzl); LOOP;
			case LD_H_H:				LOOP;
			case LD_L_H:	rzl = rzh;	LOOP;
			case LD_H_L:	rzh = rzl;	LOOP;
			case LD_L_L:				LOOP;
			}

			// legal opcodes with dreg IX/IY:
			{
			case JP_HL:					// 4+ 4 T
				pc = rz;
				LOOP;

			case LD_SP_HL:				// 4+ 6 T
				cc += 2;
				SP = rz;
				LOOP;

			case DEC_HL:   				// 4+ 6 T
				cc += 2;
				rz--;
				LOOP;

			case INC_HL:				// 4+ 6 T
				cc += 2;
				rz++;
				LOOP;

			case ADD_HL_BC:				// 4+ pc:4 +11
				cc += 7;
				M_ADDW(rz,BC);
				LOOP;

			case ADD_HL_DE:				// 4+ pc:4 +11
				cc += 7;
				M_ADDW(rz,DE);
				LOOP;

			case ADD_HL_HL:				// 4+ pc:4 +11
				cc += 7;
				M_ADDW(rz,rz);
				LOOP;

			case ADD_HL_SP:				// 4+ pc:4 +11
				cc += 7;
				M_ADDW(rz,SP);
				LOOP;

			case PUSH_HL:				// 4+ pc:5, sp-1:3, sp-2:3
				cc += 1;
				PUSH(rzh); PUSH(rzl);
				LOOP;

			case POP_HL:				// 4+ pc:4, sp:3, sp+1:3
				POP(rzl);  POP(rzh);
				LOOP;

			case LD_HL_NN:				// 4+ pc:4, pc+1:3, pc+2:3
				GET_NN(rz);
				LOOP;

			case LD_xNN_HL:				// 4+ pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3
				GET_NN(w);
				POKE(w,rzl);
				POKE_AND_LOOP(w+1,rzh);

			case LD_HL_xNN:				// 4+ pc:4, pc+1:3, pc+2:3, nn:3, nn+1:3
				GET_NN(w);
				PEEK(rzl,w);
				PEEK(rzh,w+1);	LOOP;

			case EX_HL_xSP:				// pc:4, pc+1:4, sp:3, sp+1:3,1, sp+1:3, sp:3,2x1
				w = rz;					// ((total:4+19; seq.: m1,m1,r,r,w,w))
				PEEK(rzl,SP); PEEK(rzh,SP+1); cc += 1;
				POKE(SP+1,wh); POKE(SP,wl); cc += 2; // kio tested 2005-01-15
				LOOP;
			}

			// IXIY opcodes with IX+dis:
			{
			uint8 dis; // attn: unsigned!

			case LD_xHL_B:	c=RB; goto ld_x_c;		// cc = 44353
			case LD_xHL_C:	c=RC; goto ld_x_c;
			case LD_xHL_D:	c=RD; goto ld_x_c;
			case LD_xHL_E:	c=RE; goto ld_x_c;
			case LD_xHL_H:	c=RH; goto ld_x_c;
			case LD_xHL_L:	c=RL; goto ld_x_c;
			case LD_xHL_A:	c=ra; goto ld_x_c;
			ld_x_c:
				GET_N(dis);
				cc += 5;
				POKE_AND_LOOP(rz+uint16(int8(dis)),c);

			{ uint8* p;
			case LD_B_xHL:	p=&RB; goto ld_p_x;		// cc = 44353
			case LD_C_xHL:	p=&RC; goto ld_p_x;
			case LD_D_xHL:	p=&RD; goto ld_p_x;
			case LD_E_xHL:	p=&RE; goto ld_p_x;
			case LD_H_xHL:	p=&RH; goto ld_p_x;
			case LD_L_xHL:	p=&RL; goto ld_p_x;
			ld_p_x:
				GET_N(dis);
				cc += 5;
				w = rz+uint16(int8(dis));
				PEEK(*p,w);
				LOOP;
			}
			case LD_A_xHL:
				GET_N(dis);
				cc += 5;
				w = rz+uint16(int8(dis));
				PEEK(ra,w);
				LOOP;

			case LD_xHL_N:		// cc = 443323
				GET_N(dis);
				GET_N(c);
				cc += 2;
				POKE_AND_LOOP(rz+uint16(int8(dis)),c);

			case DEC_xHL:		// cc = 4435313
				GET_N(dis);
				cc += 5;
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				cc += 1;
				M_DEC(c);
				POKE_AND_LOOP(w,c);

			case INC_xHL:
				GET_N(dis);
				cc += 5;
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				cc += 1;
				M_INC(c);
				POKE_AND_LOOP(w,c);

			case ADD_xHL:		// cc = 44353
				GET_N(dis);
				cc += 5;
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				M_ADD(c);
				LOOP;

			case SUB_xHL: GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_SUB(c); LOOP;
			case ADC_xHL: GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_ADC(c); LOOP;
			case SBC_xHL: GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_SBC(c); LOOP;
			case CP_xHL:  GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_CP(c);	 LOOP;
			case AND_xHL: GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_AND(c); LOOP;
			case OR_xHL:  GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_OR(c);	 LOOP;
			case XOR_xHL: GET_N(dis); cc += 5; w=rz+uint16(int8(dis)); PEEK(c,w); M_XOR(c); LOOP;
			}

			// IXIY + 0xCB:
			case PFX_CB:
			{
				uint8 o;
				uint8 dis;	// attn: unsigned!

				GET_N(dis);
				GET_XYCB_OP(o);					// major opcode op3

				if ((o&0x06)==4 && ixcbxh_enabled)
				{
					// use register XH or XL
					c = o&1 ? rzl : rzh;		// TODO TIMING UNKNOWN
					w = 0; // wg. warning
				}
				else
				{
					w = rz+uint16(int8(dis));	// target address
					PEEK(c,w); cc += 1;			// target
				}

				// perform instruction:
				switch (o>>3)
				{
				case BIT0_xHL>>3: M_BIT(0x01,c); break;	// cc = 443531
				case BIT1_xHL>>3: M_BIT(0x02,c); break;
				case BIT2_xHL>>3: M_BIT(0x04,c); break;
				case BIT3_xHL>>3: M_BIT(0x08,c); break;
				case BIT4_xHL>>3: M_BIT(0x10,c); break;
				case BIT5_xHL>>3: M_BIT(0x20,c); break;
				case BIT6_xHL>>3: M_BIT(0x40,c); break;
				case BIT7_xHL>>3: M_BIT(0x80,c); break;

				case RLC_xHL>>3:  M_RLC(c);	 	break;	// cc = 4435313
				case RRC_xHL>>3:  M_RRC(c);	 	break;
				case RL_xHL>>3:	  M_RL(c); 	 	break;
				case RR_xHL>>3:	  M_RR(c); 	 	break;
				case SLA_xHL>>3:  M_SLA(c);	 	break;
				case SRA_xHL>>3:  M_SRA(c);	 	break;
				case SLL_xHL>>3:  M_SLL(c);		break;	// ill.
				case SRL_xHL>>3:  M_SRL(c);	 	break;

				case RES0_xHL>>3: c &= ~0x01; 	break;	// cc = 4435313
				case RES1_xHL>>3: c &= ~0x02; 	break;
				case RES2_xHL>>3: c &= ~0x04; 	break;
				case RES3_xHL>>3: c &= ~0x08; 	break;
				case RES4_xHL>>3: c &= ~0x10; 	break;
				case RES5_xHL>>3: c &= ~0x20; 	break;
				case RES6_xHL>>3: c &= ~0x40; 	break;
				case RES7_xHL>>3: c &= ~0x80; 	break;

				case SET0_xHL>>3: c |= 0x01;  	break;	// cc = 4435313
				case SET1_xHL>>3: c |= 0x02;  	break;
				case SET2_xHL>>3: c |= 0x04;  	break;
				case SET3_xHL>>3: c |= 0x08;  	break;
				case SET4_xHL>>3: c |= 0x10;  	break;
				case SET5_xHL>>3: c |= 0x20;  	break;
				case SET6_xHL>>3: c |= 0x40;  	break;
				case SET7_xHL>>3: c |= 0x80;  	break;
				}

				// copy result to register (illegals only)
				switch(o&0x07)
				{
				case 0:	RB=c; goto ixcbra;
				case 1:	RC=c; goto ixcbra;
				case 2:	RD=c; goto ixcbra;
				case 3:	RE=c; goto ixcbra;
				case 4:	if (ixcbxh_enabled) { rzh = c; LOOP; } // TODO TIMING UNKNOWN
						RH=c; goto ixcbra;
				case 5:	if (ixcbxh_enabled) { rzl = c; LOOP; } // TODO TIMING UNKNOWN
						RL=c; goto ixcbra;
				case 6: break;				// (HL): legal register
				case 7:	ra=c; goto ixcbra;
				ixcbra:	if (!ixcbr2_enabled) goto ill_op3;
						break;
				}

				if ((o&0xc0)==0x40) LOOP;	// BIT
				else POKE_AND_LOOP(w,c);	// SET, RES or SHIFT
			}

			default:				// ix/iy prefix has no effect on operation:
				goto ill_op2;		// => prefix worked like a NOP
			}
		}

		// ==========================================================================
		//	PREFIX CB COMMANDS
		// ==========================================================================

		case PFX_CB:
		{
			if (isa_8080) goto ill_op1;

			GET_CB_OP(w);	// fetch opcode

			// read source: b,c,d,e,h,l,(hl),a
			switch (w & 0x07)
			{
			case 0: c=RB; break;
			case 1: c=RC; break;
			case 2: c=RD; break;
			case 3: c=RE; break;
			case 4: c=RH; break;
			case 5: c=RL; break;
			case 6: PEEK(c,HL); cc += 1; break;
			case 7: c=ra; break;
			}

			// perform operation: shift/bit/res/set
			switch (w >> 3)
			{
			case RLC_B>>3:	M_RLC(c); break;
			case RRC_B>>3:	M_RRC(c); break;
			case RL_B>>3:	M_RL(c);  break;
			case RR_B>>3:	M_RR(c);  break;
			case SLA_B>>3:	M_SLA(c); break;
			case SRA_B>>3:	M_SRA(c); break;
			case SLL_B>>3:	M_SLL(c); break; // ill.
			case SRL_B>>3:	M_SRL(c); break;

			case BIT0_B>>3:	M_BIT(0x01,c); LOOP;
			case BIT1_B>>3:	M_BIT(0x02,c); LOOP;
			case BIT2_B>>3:	M_BIT(0x04,c); LOOP;
			case BIT3_B>>3:	M_BIT(0x08,c); LOOP;
			case BIT4_B>>3:	M_BIT(0x10,c); LOOP;
			case BIT5_B>>3:	M_BIT(0x20,c); LOOP;
			case BIT6_B>>3:	M_BIT(0x40,c); LOOP;
			case BIT7_B>>3:	M_BIT(0x80,c); LOOP;

			case RES0_B>>3:	c&=~0x01; break;
			case RES1_B>>3:	c&=~0x02; break;
			case RES2_B>>3:	c&=~0x04; break;
			case RES3_B>>3:	c&=~0x08; break;
			case RES4_B>>3:	c&=~0x10; break;
			case RES5_B>>3:	c&=~0x20; break;
			case RES6_B>>3:	c&=~0x40; break;
			case RES7_B>>3:	c&=~0x80; break;

			case SET0_B>>3:	c|=0x01; break;
			case SET1_B>>3:	c|=0x02; break;
			case SET2_B>>3:	c|=0x04; break;
			case SET3_B>>3:	c|=0x08; break;
			case SET4_B>>3:	c|=0x10; break;
			case SET5_B>>3:	c|=0x20; break;
			case SET6_B>>3:	c|=0x40; break;
			case SET7_B>>3:	c|=0x80; break;
			}

			// store back result:
			switch (w & 0x07)
			{
			case 0: RB=c; LOOP;
			case 1: RC=c; LOOP;
			case 2: RD=c; LOOP;
			case 3: RE=c; LOOP;
			case 4: RH=c; LOOP;
			case 5: RL=c; LOOP;
			case 6: POKE_AND_LOOP(HL,c);
			case 7: ra=c; LOOP;
			}

			IERR(); // dead code
		}

		// ==========================================================================
		//	PREFIX ED COMMANDS
		// ==========================================================================

		case PFX_ED:
		{
			if (isa_8080) goto ill_op1;

			GET_ED_OP(c);

			switch(c)
			{
			case ADC_HL_BC: rzp=&registers.bc; goto adc_hl_rr; // cc = 447
			case ADC_HL_DE: rzp=&registers.de; goto adc_hl_rr;
			case ADC_HL_HL: rzp=&registers.hl; goto adc_hl_rr;
			case ADC_HL_SP: rzp=&registers.sp; goto adc_hl_rr;
			adc_hl_rr: cc += 7; M_ADCW(rz); LOOP;

			case SBC_HL_BC: rzp=&registers.bc; goto sbc_hl_rr; // cc = 447
			case SBC_HL_DE: rzp=&registers.de; goto sbc_hl_rr;
			case SBC_HL_HL: rzp=&registers.hl; goto sbc_hl_rr;
			case SBC_HL_SP: rzp=&registers.sp; goto sbc_hl_rr;
			sbc_hl_rr: cc += 7; M_SBCW(rz); LOOP;

			case LD_xNN_BC:	rzp = &registers.bc; goto ld_xnn_rr; // cc = 443333
			case LD_xNN_DE:	rzp = &registers.de; goto ld_xnn_rr;
			case ED_xNN_HL:	rzp = &registers.hl; goto ld_xnn_rr;
			case LD_xNN_SP:	rzp = &registers.sp; goto ld_xnn_rr;
			ld_xnn_rr: GET_NN(w); POKE(w,rzl); POKE_AND_LOOP(w+1,rzh);

			case LD_BC_xNN:	GET_NN(w); PEEK(RC,w);  PEEK(RB,w+1); LOOP;	// cc = 443333
			case LD_DE_xNN:	GET_NN(w); PEEK(RE,w);  PEEK(RD,w+1); LOOP;
			case ED_HL_xNN:	GET_NN(w); PEEK(RL,w);  PEEK(RH,w+1); LOOP;
			case LD_SP_xNN:	GET_NN(w); PEEK(SPL,w); PEEK(SPH,w+1);LOOP;

			{
			case IN_F_xC:	uint8 z; uint8* p;
							p=&z;  goto in_r_xc; // cc = 44i
			case IN_B_xC:	p=&RB; goto in_r_xc;
			case IN_C_xC:	p=&RC; goto in_r_xc;
			case IN_D_xC:	p=&RD; goto in_r_xc;
			case IN_E_xC:	p=&RE; goto in_r_xc;
			case IN_H_xC:	p=&RH; goto in_r_xc;
			case IN_L_xC: 	p=&RL; goto in_r_xc;
				 in_r_xc:	M_IN(*p); LOOP;
			case IN_A_xC:	M_IN(ra); LOOP;
			}

			case OUT_xC_B:	c=RB; goto out_xc_r; // cc = 44o
			case OUT_xC_C: 	c=RC; goto out_xc_r;
			case OUT_xC_D: 	c=RD; goto out_xc_r;
			case OUT_xC_E: 	c=RE; goto out_xc_r;
			case OUT_xC_H: 	c=RH; goto out_xc_r;
			case OUT_xC_L: 	c=RL; goto out_xc_r;
			case OUT_xC_A: 	c=ra; goto out_xc_r;
				 out_xc_r:	OUTPUT(BC,c); LOOP;
			case OUT_xC_0: 	c=0;  goto out_xc_r;  // ill.   TODO: CMOS/NMOS option!

			case IM_0:		registers.im=0; LOOP;
			case IM_1:		registers.im=1; LOOP;
			case IM_2:		registers.im=2; LOOP;
			case NEG:   	c=ra; ra=0; M_SUB(c); LOOP;

			case LD_I_A:						// cc = 45
				cc += 1;
				RI = ra;
				LOOP;

			case LD_R_A:						// cc = 45
				cc += 1;
				registers.r = r = ra;
				LOOP;

			case LD_A_I:						// cc = 45
				cc += 1;
				ra = RI;
				rf = (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
				LOOP;

			case LD_A_R:						// cc = 45
				cc += 1;
				ra = (registers.r&0x80) + (r&0x7F);
				rf = (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
				LOOP;

			case RETI:							// cc = 4433
			case RETN:							// cc = 4433
				IFF1=IFF2;
				goto ret;

			case RRD:							// cc = 44343
			{	uint8 o;
				w = HL; PEEK(o,w);
				c = uint8((o>>4) + (ra<<4));
				ra = (ra&0xF0) + (o&0x0F);
			}	goto rld;
			case RLD:							// cc = 44343
			{	uint8 o;
				w = HL; PEEK(o,w);
				c = uint8((o<<4) + (ra&0x0F));
				ra = (ra&0xF0) + (o>>4);
			}	goto rld;
			rld:rf	= (rf&C_FLAG) + zlog_flags[ra];
				cc += 4;
				POKE_AND_LOOP(w,c);

			// ########	Block Instructions ###############################

			case LDDR:	w = uint16(-1); goto ldir;			// Load, decrement and repeat
			case LDIR:	w = 1;								// Load, increment and repeat
			ldir:		PEEK(c,HL);							// cc = 44332[5]
						POKE(DE,c);
						rf &= ~(N_FLAG+H_FLAG+P_FLAG);
						if (--BC) { rf |= P_FLAG; pc-=2; cc+=7; } else { cc+=2; }
						DE+=w; HL+=w;
						LOOP;

			case LDD:	w = uint16(-1); goto ldi;			// Load and decrement
			case LDI:	w = 1;								// Load and increment
			ldi:		PEEK(c,HL); HL += w;				// cc = 44332
						POKE(DE,c);
						cc += 2;
						DE += w;
						rf &= ~(N_FLAG+H_FLAG+P_FLAG);
						if (--BC) rf |= P_FLAG;
						LOOP;

			case CPDR:	w = HL--; goto cpir;				// Compare, decrement and repeat
			case CPIR:	w = HL++;							// Compare, increment and repeat
			cpir:		PEEK(c,w); c = ra - c;				// cc = 4435[5]
						cc += 5;
						BC -= 1;
						rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
						if (BC&&c) { pc -= 2; cc += 5; }	// LOOP not yet finished
						LOOP;

			case CPD:	w = HL--; goto cpi;					// Compare and decrement
			case CPI:	w = HL++;							// Compare and increment
			cpi:		PEEK(c,w); c = ra - c;				// cc = 4435
						cc += 5;
						BC -= 1;
						rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
						LOOP;

			case INDR:	w = HL--; goto inir;				// input, decrement and repeat
			case INIR:	w = HL++;							// input, increment and repeat
			inir:		cc += 1;							// cc = 45i3[5]
						INPUT(BC,c);
						POKE(w,c);
						if (--RB) { pc -= 2; cc += 5; }		// LOOP not yet finished
						rf = N_FLAG + (RB?0:Z_FLAG);		// TODO: INIR etc.: flags checken
						LOOP;

			case IND:	w = HL--; goto ini;					// input and decrement
			case INI:	w = HL++;							// input and increment
			ini:		cc += 1;							// cc = 45i3
						INPUT(BC,c);
						rf = N_FLAG + (--RB?0:Z_FLAG);
						POKE_AND_LOOP(w,c);

			case OTDR:	w = HL--; goto otir;				// output, decrement and repeat
			case OTIR:	w = HL++;							// output, increment and repeat
			otir:		cc += 1;							// cc = 453o[5]
						PEEK(c,w);
						--RB;
						OUTPUT(BC,c);
						if (RB) { pc -= 2; cc += 5; }
						rf = N_FLAG + (RB?0:Z_FLAG);
						LOOP;

			case OUTD:	w = HL--; goto outi;				// output and decrement
			case OUTI:	w = HL++;							// output and increment
			outi:		cc += 1;							// cc = 453o
						PEEK(c,w);
						--RB;
						OUTPUT(BC,c);
						rf = N_FLAG + (RB?0:Z_FLAG);
						LOOP;

			default:	goto ill_op2; // all other 0xED opcodes are illegal aliases of NOP, NEG, RETN or IM x
			}

			IERR();	// dead code
		}

		} // opcode op1 dispatcher

		// all opcodes decoded!
		IERR();

		ill_op3:
		cc -= 12; pc -= 2;		// undo dis and op3 fetch
		ill_op2:
		cc -= 4; pc--; r--;		// undo op2 fetch
		ill_op1:
		cc -= 4; pc--; r--;		// undo op1 fetch
		EXIT(IllegalInstruction);

	}  // while(cc<cc_exit)

	if (cc < ccx0) goto slow_loop; // not yet timed out
	EXIT(TimeOut);


x:	SAVE_REGISTERS;
	return RVal(w); // result;
}





























