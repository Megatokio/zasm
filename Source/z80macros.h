/*	Copyright  (c)	Günter Woigk 1996 - 2021
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


// =====================================
// call-backs at some intersting points:
// =====================================



// --------------------------------------------------------------------
// ----	INSTRUCTION MACROS --------------------------------------------
//		no user serviceable parts inside.
// --------------------------------------------------------------------

#define	GET_NN(RR)		do{ GET_N(RR); GET_N(wm); RR += 256*wm; }while(0)
#define	POP(R)			do{ PEEK(R,SP); SP++; }while(0)
#define	PUSH(R)			do{ --SP; POKE(SP,Byte(R)); }while(0)


/*	RLC ... SRL:	set/clr C, Z, P, S;
			clear	N=0, H=0
			pres.	none
*/
#define M_RLC(R)      				\
	rf  = R>>7;						\
	R   = uint8((R<<1)+rf); 		\
	rf |= zlog_flags[R]

#define M_RRC(R)      				\
	rf  = R&0x01;					\
	R   = uint8((R>>1)+(rf<<7));	\
	rf |= zlog_flags[R]

#define M_RL(R)						\
	do{								\
	if (R&0x80)						\
	{	R 	= uint8((R<<1)+(rf&0x01));\
		rf	= zlog_flags[R]+C_FLAG;	\
	} else							\
	{	R 	= uint8((R<<1)+(rf&0x01));\
		rf	= zlog_flags[R];		\
	}}while(0)

#define M_RR(R)						\
	do{								\
	if (R&0x01)						\
	{	R 	= uint8((R>>1)+(rf<<7));\
		rf	= zlog_flags[R]+C_FLAG;	\
	} else							\
	{	R 	= uint8((R>>1)+(rf<<7));\
		rf	= zlog_flags[R];		\
	}}while(0)

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
	R	= uint8((R<<1)+1);			\
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
#define M_ADD_old(R)								\
	wm	= ra+R;									\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			 + (~(ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml
#define M_ADD(R)								\
	wm	= ra+R;									\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			 + ((~(ra^R)&(wml^ra))>>5 & V_FLAG)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml

#define M_SUB_old(R)								\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml
#define M_SUB(R)								\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + (((ra^R)&(wml^ra))>>5 & V_FLAG)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml

#define M_ADC_old(R)								\
	wm	= ra+R+(rf&C_FLAG);						\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			 + (~(ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml
#define M_ADC(R)								\
	wm	= ra+R+(rf&C_FLAG);						\
	rf	= wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			+ ((~(ra^R)&(wml^ra))>>5 & V_FLAG)	\
			 + ((ra^R^wml)&H_FLAG);				\
	ra	= wml

#define M_SBC_old(R)								\
	wm	= ra-R-(rf&C_FLAG);						\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml
#define M_SBC(R)								\
	wm	= ra-R-(rf&C_FLAG);						\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + (((ra^R)&(wml^ra))>>5 & V_FLAG)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG;	\
	ra	= wml

#define M_CP_old(R)									\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + ((ra^R)&(wml^ra)&0x80?V_FLAG:0)	\
			  + ((ra^R^wml)&H_FLAG) + N_FLAG
#define M_CP(R)									\
	wm	= ra-R;									\
	rf	= -wmh + (wml?0:Z_FLAG) + (wml&S_FLAG)	\
			  + (((ra^R)&(wml^ra))>>5 & V_FLAG)	\
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

// Z180:
#define M_TST(A,N)								\
	rf = H_FLAG|zlog_flags[A & N]


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
	rf	= uint8((uint32(HL)+uint32(R)+(rf&C_FLAG))>>16)\
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


/* Z180:
	IN0	set/clr	Z, P, S, H
		clear	N=0
		pres	C
*/
#define M_IN0(PORT,R)							\
	INPUT(PORT,R);								\
	rf	= (rf&C_FLAG) + zlog_flags[R]









