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


	Z80 Emulator
	originally based on fMSX; Copyright (C) Marat Fayzullin 1994,1995

	macro definitions
*/


// access z80 registers:

#define	IFF1	registers.iff1		// actually used irpt flip flop
#define	IFF2	registers.iff2		// copy of iff1 during nmi processing
#define	RR		registers.r			// 7 bit DRAM refresh counter
#define	RI		registers.i			// hi byte of interrupt vector: i register

#define	RA		registers.a
#define	RF		registers.f
#define	RB		registers.b
#define	RC		registers.c
#define	RD		registers.d
#define	RE		registers.e
#define	RH		registers.h
#define	RL		registers.l

#define	RA2		registers.a2
#define	RF2		registers.f2

#define	XH		registers.xh
#define	XL		registers.xl
#define	YH		registers.yh
#define	YL		registers.yl
#define	PCH		registers.pch
#define	PCL		registers.pcl
#define	SPH		registers.sph
#define	SPL		registers.spl

#define	BC		registers.bc
#define	DE		registers.de
#define	HL		registers.hl

#define	BC2		registers.bc2
#define	DE2		registers.de2
#define	HL2		registers.hl2

#define	IX		registers.ix
#define	IY		registers.iy
#define	PC		registers.pc
#define	SP		registers.sp


// ===================================
// default implementations for macros:
// ===================================

// read/write data:

// increment cpu cycle counter
#ifndef INCR_CC
#define INCR_CC(N)		cc += (N)
#endif

// increment refresh register
#ifndef INCR_R
#define INCR_R()		r += 1
#endif

// read byte from memory
#ifndef	PEEK
#define	PEEK(DEST,ADDR)	do{ INCR_CC(3); DEST = peek(ADDR); }while(0)
#endif

// write byte into memory
#ifndef	POKE
#define	POKE(ADDR,BYTE)	do{ INCR_CC(3); poke(ADDR,BYTE); }while(0)
#endif

// read instruction byte at PC (M1 cycle)
#ifndef	GET_INSTR
#define	GET_INSTR(R)	do{ INCR_CC(4); INCR_R(); R = peek(pc++); }while(0)
#endif

// read 2nd instruction byte after 0xCB opcode
#ifndef	GET_CB_OP
#define	GET_CB_OP(R)	do{ INCR_CC(4); INCR_R(); R = peek(pc++); }while(0)
#endif

// read 2nd instruction byte after 0xED opcode
#ifndef	GET_ED_OP
#define	GET_ED_OP(R)	do{ INCR_CC(4); INCR_R(); R = peek(pc++); }while(0)
#endif

// read 2nd instruction byte after IX or IY opcode prefix
#ifndef	GET_XY_OP
#define	GET_XY_OP(R)	do{ INCR_CC(4); INCR_R(); R = peek(pc++); }while(0)
#endif

// read 3rd instruction byte after IX or IY prefix and 0xCB opcode
#ifndef	GET_XYCB_OP
#define	GET_XYCB_OP(R)	do{ INCR_CC(5); R = peek(pc++); }while(0)
#endif

// read byte at PC
#ifndef	GET_N
#define	GET_N(R)		do{ INCR_CC(3); R = peek(pc++); }while(0)
#endif

// dummy read byte at PC
#ifndef	SKIP_N
#define	SKIP_N()		do{ INCR_CC(3); peek(pc++); }while(0)
#endif

// increment cpu cycle counter
#ifndef SKIP_1CC
#define SKIP_1CC(RR)	INCR_CC(1)
#endif
#ifndef SKIP_2X1CC
#define SKIP_2X1CC(RR)	INCR_CC(2)
#endif
#ifndef SKIP_4X1CC
#define SKIP_4X1CC(RR)	INCR_CC(4)
#endif
#ifndef SKIP_5X1CC
#define SKIP_5X1CC(RR)	INCR_CC(5)
#endif
#ifndef SKIP_7X1CC
#define SKIP_7X1CC(RR)	INCR_CC(7)
#endif

// output byte to address
#ifndef OUTPUT
#define	OUTPUT(ADDR,BYTE) do{ INCR_CC(4); this->handle_output(cc-2,ADDR,BYTE); }while(0)
#endif

// input byte from address
#ifndef INPUT
#define	INPUT(ADDR,DEST) do{ INCR_CC(4); DEST = this->handle_input(cc-2,ADDR); }while(0)
#endif


// =====================================
// call-backs at some intersting points:
// =====================================

// processing interrupt:
#ifndef Z80_INFO_IRPT			/* cpu cycle of irpt ack is cc-2 */
#define Z80_INFO_IRPT			/* nop */
#endif

// processing NMI:
#ifndef Z80_INFO_NMI			/* cpu cycle of nmi ack is cc-2 */
#define	Z80_INFO_NMI			/* nop */
#endif

// execute RETI
#ifndef Z80_INFO_RETI
#define	Z80_INFO_RETI			/* nop */
#endif

// execute RETN
#ifndef Z80_INFO_RETN
#define	Z80_INFO_RETN			/* nop */
#endif

// execute HALT
#ifndef Z80_INFO_HALT
#define	Z80_INFO_HALT do{if(pc==breakpoint){cc-=4;r--;ccx=cc;result=BreakPoint;LOOP;}}while(0)
#endif

// executing an illegal instruction:
#ifndef Z80_INFO_ILLEGAL
#define Z80_INFO_ILLEGAL(dCC,dPC,dR) do{cc-=dCC;pc-=dPC;r-=dR;result=IllegalInstruction;EXIT;}while(0)
#endif

// pop value from stack
// probably needed for a single stepper / debugger
#ifndef Z80_INFO_POP
#define Z80_INFO_POP			/* nop */
#endif

// execute return opcode
// probably needed for a single stepper / debugger
#ifndef Z80_INFO_RET
#define Z80_INFO_RET			/* nop */
#endif

// excute EX HL,(SP)
// probably needed for a single stepper / debugger
#ifndef Z80_INFO_EX_HL_xSP
#define Z80_INFO_EX_HL_xSP		/* nop */
#endif

// execute RST 0 opdode
#ifndef Z80_INFO_RST00
#define Z80_INFO_RST00			/* nop */
#endif

// execute RST 8 opdode
#ifndef Z80_INFO_RST08
#define Z80_INFO_RST08			/* nop */
#endif

// execute RST 0x10 opdode
#ifndef Z80_INFO_RST10
#define Z80_INFO_RST10			/* nop */
#endif

// execute RST 0x18 opdode
#ifndef Z80_INFO_RST18
#define Z80_INFO_RST18			/* nop */
#endif

// execute RST 0x20 opdode
#ifndef Z80_INFO_RST20
#define Z80_INFO_RST20			/* nop */
#endif

// execute RST 0x28 opdode
#ifndef Z80_INFO_RST28
#define Z80_INFO_RST28			/* nop */
#endif

// execute RST 0x30 opdode
#ifndef Z80_INFO_RST30
#define Z80_INFO_RST30			/* nop */
#endif

// execute RST 0x38 opdode
#ifndef Z80_INFO_RST38
#define Z80_INFO_RST38			/* nop */
#endif

// execute DI opcode
#ifndef Z80_INFO_DI
#define Z80_INFO_DI				/* nop */
#endif

// execute EI opcode
#ifndef Z80_INFO_EI
#define Z80_INFO_EI				/* nop */
#endif

// execute LD R,A opcode
#ifndef Z80_INFO_LD_R_A
#define Z80_INFO_LD_R_A			/* nop */
#endif

// execute LD I,A opcode
#ifndef Z80_INFO_LD_I_A
#define Z80_INFO_LD_I_A			/* nop */
#endif




// --------------------------------------------------------------------
// ----	INSTRUCTION MACROS --------------------------------------------
//		no user serviceable parts inside.
// --------------------------------------------------------------------

#define	GET_NN(RR)		do{ GET_N(RR); GET_N(wm); RR += 256*wm; }while(0)
#define	POP(R)			do{ PEEK(R,SP); SP++; }while(0)
#define	PUSH(R)			do{ --SP; POKE(SP,Byte(R)); }while(0)


#define	LOAD_REGISTERS do{ 									\
	r		= registers.r;	/* refresh counter R		*/	\
	cc		= this->cc;		/* cpu cycle counter		*/	\
	pc		= registers.pc;	/* program counter PC		*/	\
	ra		= registers.a;	/* register A				*/	\
	rf		= registers.f;	/* register F				*/	\
	}while(0)

#define	SAVE_REGISTERS do{														\
	registers.r		= (registers.r&0x80)|(r&0x7f);	/* refresh counter R	*/	\
	this->cc		= cc;							/* cpu cycle counter	*/	\
	registers.pc	= pc;							/* program counter PC	*/	\
	registers.a		= ra;							/* register A			*/	\
	registers.f		= rf;							/* register F			*/	\
	}while(0)


/*	RLC ... SRL:	set/clr C, Z, P, S;
			clear	N=0, H=0
			pres.	none
*/
#define M_RLC(R)      				\
	rf  = R>>7;						\
	R   = (R<<1)+rf; 				\
	rf |= zlog_flags[R]

#define M_RRC(R)      				\
	rf  = R&0x01;					\
	R   = (R>>1)+(rf<<7);		 	\
	rf |= zlog_flags[R]

#define M_RL(R)						\
	if (R&0x80)						\
	{	R 	= (R<<1)+(rf&0x01);		\
		rf	= zlog_flags[R]+C_FLAG;	\
	} else							\
	{	R 	= (R<<1)+(rf&0x01);		\
		rf	= zlog_flags[R];		\
	}

#define M_RR(R)						\
	if (R&0x01)						\
	{	R 	= (R>>1)+(rf<<7);		\
		rf	= zlog_flags[R]+C_FLAG;	\
	} else							\
	{	R 	= (R>>1)+(rf<<7);		\
		rf	= zlog_flags[R];		\
	}

#define M_SLA(R)					\
	rf	= R>>7;						\
	R <<= 1;						\
	rf |= zlog_flags[R]

#define M_SRA(R)					\
	rf	= R&0x01;					\
	R	= (R&0x80)+(R>>1);			\
	rf |= zlog_flags[R]

#define M_SLL(R)					\
	rf	= R>>7;						\
	R	= (R<<1)+1;					\
	rf |= zlog_flags[R]

#define M_SRL(R)					\
	rf	= R&0x01;					\
	R >>= 1;						\
	rf |= zlog_flags[R]


/*	BIT:	set/clr	Z
			clear	N=0, H=1
			pres	C
			takes other flags from corresponding bits in tested byte!
*/
#define M_BIT(N,R)								\
	rf	= (rf&C_FLAG) + 						\
		  (R&(S_FLAG+P_FLAG)) + 				\
		   H_FLAG + 							\
		  ((R&N)?0:Z_FLAG)


/*	ADD ... CP:	set/clr	Z, S, V, C, N, H
				pres	none
*/
#define M_ADD(R)								\
	wm	= ra+R;									\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			 + (~(ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml

#define M_SUB(R)								\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml

#define M_ADC(R)								\
	wm	= ra+R+(rf&C_FLAG);						\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			 + (~(ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml

#define M_SBC(R)								\
	wm	= ra-R-(rf&C_FLAG);						\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml

#define M_CP(R)									\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG


/*	AND ... XOR:	set/clr	Z, P, S
					clear	C=0, N=0, H=0/1 (OR,XOR/AND)
					pres	none
*/
#define M_AND(R)								\
	ra &= R;									\
	rf	= H_FLAG|zlog_flags[ra]

#define M_OR(R)									\
	ra |= R;									\
	rf	= zlog_flags[ra]

#define M_XOR(R)								\
	ra ^= R;									\
	rf	= zlog_flags[ra]


/*	INC ... DEC:	set/clr	Z,P,S,H
					clear	N=0/1 (INC/DEC)
					pres	C
*/
#define M_INC(R)								\
	R++;										\
	rf	= (rf&C_FLAG) + 						\
		  (R?0:Z_FLAG) + 						\
		  (R&S_FLAG) + 							\
		  (R==0x80?V_FLAG:0) + 					\
		  (R&0x0F?0:H_FLAG)

#define M_DEC(R)								\
	R--;										\
	rf	= (rf&C_FLAG) + 						\
		  (R?0:Z_FLAG) + 						\
		  (R&S_FLAG) + 							\
		  (R==0x7F?V_FLAG:0) + 					\
		  (((R+1)&0x0F)?0:H_FLAG) +				\
		   N_FLAG


/*	ADDW:	set/clr	C
			clear	N=0
			pres	Z, P, S
			unkn	H
*/
#define M_ADDW(R1,R2)							\
	rf &= ~(N_FLAG+C_FLAG);						\
	rf |= (uint32(R1)+uint32(R2))>>16;			\
	R1 += R2


/*	ADCW, SBCW:	set/clr	C,Z,V,S
			clear	N=0/1 (ADC/SBC)
			unkn	H
			pres	none
*/
#define M_ADCW(R)								\
	wm	= HL+R+(rf&C_FLAG);						\
	rf	= ((uint32(HL)+uint32(R)+(rf&C_FLAG))>>16)\
			+ (wm?0:Z_FLAG) + (wmh&S_FLAG)		\
			+ (~(HL^R)&(wm^HL)&0x8000?V_FLAG:0);\
	HL	= wm

#define M_SBCW(R)								\
	wm	= HL-R-(rf&C_FLAG);						\
	rf	= ((uint32(HL)-uint32(R)-(rf&C_FLAG))>>31)\
			+ (wm?0:Z_FLAG) + (wmh&S_FLAG)		\
			+ ((HL^R)&(wm^HL)&0x8000?V_FLAG:0)	\
			+ N_FLAG;							\
	HL	= wm


/*	IN	set/clr	Z, P, S, H
		clear	N=0
		pres	C
*/
#define M_IN(R)									\
	INPUT(BC,R);								\
	rf	= (rf&C_FLAG) + zlog_flags[R]










