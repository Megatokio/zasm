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


// read byte from memory
#define	PEEK(DEST,ADDR)	do{ DEST = peek(ADDR); }while(0)

// write byte into memory
#define	POKE(ADDR,BYTE)	do{ poke(ADDR,BYTE); }while(0)

// read instruction byte at PC (M1 cycle)
#define	GET_INSTR(R)	do{ r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after 0xCB opcode
#define	GET_CB_OP(R)	do{ r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after 0xED opcode
#define	GET_ED_OP(R)	do{ r+=1; R = peek(pc++); }while(0)

// read 2nd instruction byte after IX or IY opcode prefix
#define	GET_XY_OP(R)	do{ r+=1; R = peek(pc++); }while(0)

// read 3rd instruction byte after IX or IY prefix and 0xCB opcode
#define	GET_XYCB_OP(R)	do{ R = peek(pc++); }while(0)

// read byte at PC
#define	GET_N(R)		do{ R = peek(pc++); }while(0)

// dummy read byte at PC
#define	SKIP_N()		do{ peek(pc++); }while(0)

// output byte to address
#define	OUTPUT(A,B)		do{ output(cc-2,A,B); }while(0)

// input byte from address
#define	INPUT(A,B)		do{ B = input(cc-2,A); }while(0)


// total opcode times for op1 opcodes
// Prefix opcodes are set to 0.
//	this table is similar to cc_z180[] in z180_clock_tables.cpp
//	but has not the 'combined' time stored for branching opcodes
static const uint8 cc_z180[256] =
{
	// only store branch time for branching opcodes: a=no-branch, b=branch
	#define Z(a,b)	b

	// NOP, 		LD_BC_NN,	LD_xBC_A,	INC_BC,		INC_B,		DEC_B,		LD_B_N,		RLCA,
	// EX_AF_AF,	ADD_HL_BC,	LD_A_xBC,	DEC_BC,		INC_C,		DEC_C,		LD_C_N,		RRCA,
	// DJNZ,		LD_DE_NN,	LD_xDE_A,	INC_DE,		INC_D,		DEC_D,		LD_D_N,		RLA,
	// JR,  		ADD_HL_DE,	LD_A_xDE,	DEC_DE,		INC_E,		DEC_E,		LD_E_N,		RRA,
	// JR_NZ,		LD_HL_NN,	LD_xNN_HL,	INC_HL,		INC_H,		DEC_H,		LD_H_N,		DAA,
	// JR_Z,		ADD_HL_HL,	LD_HL_xNN,	DEC_HL,		INC_L,		DEC_L,		LD_L_N,		CPL,
	// JR_NC,		LD_SP_NN,	LD_xNN_A,	INC_SP,		INC_xHL,	DEC_xHL,	LD_xHL_N,	SCF,
	// JR_C,		ADD_HL_SP,	LD_A_xNN,	DEC_SP,		INC_A,		DEC_A,		LD_A_N,		CCF,
		3u,			9u,			7u,			4u,			4u,			4u,			6u,			3u,
		4u,			7u,			6u,			4u,			4u,			4u,			6u,			3u,
		Z(7u,9u),	9u,			7u,			4u,			4u,			4u,			6u,			3u,
		8u,			7u,			6u,			4u,			4u,			4u,			6u,			3u,
		Z(6u,8u),	9u,			16u, 		4u,			4u,			4u,			6u,			4u,
		Z(6u,8u),	7u,			15u, 		4u,			4u,			4u,			6u,			3u,
		Z(6u,8u),	9u,			13u, 		4u,			10u, 		10u, 		9u,			3u,
		Z(6u,8u),	7u,			12u, 		4u,			4u,			4u,			6u,			3u,

	// LD_B_B,		LD_B_C,		LD_B_D,		LD_B_E,		LD_B_H,		LD_B_L,		LD_B_xHL,	LD_B_A,
	// LD_C_B,		LD_C_C,		LD_C_D,		LD_C_E,		LD_C_H,		LD_C_L,		LD_C_xHL,	LD_C_A,
	// LD_D_B,		LD_D_C,		LD_D_D,		LD_D_E,		LD_D_H,		LD_D_L,		LD_D_xHL,	LD_D_A,
	// LD_E_B,		LD_E_C,		LD_E_D,		LD_E_E,		LD_E_H,		LD_E_L,		LD_E_xHL,	LD_E_A,
	// LD_H_B,		LD_H_C,		LD_H_D,		LD_H_E,		LD_H_H,		LD_H_L,		LD_H_xHL,	LD_H_A,
	// LD_L_B,		LD_L_C,		LD_L_D,		LD_L_E,		LD_L_H,		LD_L_L,		LD_L_xHL,	LD_L_A,
	// LD_xHL_B,	LD_xHL_C,	LD_xHL_D,	LD_xHL_E,	LD_xHL_H,	LD_xHL_L,	HALT,		LD_xHL_A,
	// LD_A_B,		LD_A_C,		LD_A_D,		LD_A_E,		LD_A_H,		LD_A_L,		LD_A_xHL,	LD_A_A,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		7u,			7u,			7u,			7u,			7u,			7u,			3u,			7u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,

	// ADD_B,		ADD_C,		ADD_D,		ADD_E,		ADD_H,		ADD_L,		ADD_xHL,	ADD_A,
	// ADC_B,		ADC_C,		ADC_D,		ADC_E,		ADC_H,		ADC_L,		ADC_xHL,	ADC_A,
	// SUB_B,		SUB_C,		SUB_D,		SUB_E,		SUB_H,		SUB_L,		SUB_xHL,	SUB_A,
	// SBC_B,		SBC_C,		SBC_D,		SBC_E,		SBC_H,		SBC_L,		SBC_xHL,	SBC_A,
	// AND_B,		AND_C,		AND_D,		AND_E,		AND_H,		AND_L,		AND_xHL,	AND_A,
	// XOR_B,		XOR_C,		XOR_D,		XOR_E,		XOR_H,		XOR_L,		XOR_xHL,	XOR_A,
	// OR_B,		OR_C,		OR_D,		OR_E,		OR_H,		OR_L,		OR_xHL,		OR_A,
	// CP_B,		CP_C,		CP_D,		CP_E,		CP_H,		CP_L,		CP_xHL,		CP_A,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,
		4u,			4u,			4u,			4u,			4u,			4u,			6u,			4u,

	// RET_NZ,		POP_BC,		JP_NZ,		JP,			CALL_NZ,	PUSH_BC,	ADD_N,		RST00,
	// RET_Z,		RET,		JP_Z,		PFX_CB,		CALL_Z,		CALL,		ADC_N,		RST08,
	// RET_NC,		POP_DE,		JP_NC,		OUTA,		CALL_NC,	PUSH_DE,	SUB_N,		RST10,
	// RET_C,		EXX,		JP_C,		INA,		CALL_C,		PFX_IX,		SBC_N,		RST18,
	// RET_PO,		POP_HL,		JP_PO,		EX_HL_xSP,	CALL_PO,	PUSH_HL,	AND_N,		RST20,
	// RET_PE,		JP_HL,		JP_PE,		EX_DE_HL,	CALL_PE,	PFX_ED,		XOR_N,		RST28,
	// RET_P,		POP_AF,		JP_P,		DI,			CALL_P,		PUSH_AF,	OR_N,		RST30,
	// RET_M,		LD_SP_HL,	JP_M,		EI,			CALL_M,		PFX_IY,		CP_N,		RST38,
		Z(5u,10u),	9u,			Z(6u,9u),	9u,			Z(6u,16u),	11u, 		6u,			11u,
		Z(5u,10u),	9u,			Z(6u,9u),	0u,			Z(6u,16u),	16u, 		6u,			11u,
		Z(5u,10u),	9u,			Z(6u,9u),	10u, 		Z(6u,16u),	11u, 		6u,			11u,
		Z(5u,10u),	3u,			Z(6u,9u),	9u,			Z(6u,16u),	0u,			6u,			11u,
		Z(5u,10u),	9u,			Z(6u,9u),	16u, 		Z(6u,16u),	11u, 		6u,			11u,
		Z(5u,10u),	3u,			Z(6u,9u),	3u,			Z(6u,16u),	0u,			6u,			11u,
		Z(5u,10u),	9u,			Z(6u,9u),	3u,			Z(6u,16u),	11u, 		6u,			11u,
		Z(5u,10u),	4u,			Z(6u,9u),	3u,			Z(6u,16u),	0u,			6u,			11u,
};

static const uint8 cc_z180_XY[256] =
{
	// Opcodes with prefix DD and FD use the IX resp. IY register instead of HL.
	// Times are given for the entire opcode incl. DD/FD.
	// time for illegal opcodes is 0.

	// NOP, 		LD_BC_NN,	LD_xBC_A,	INC_BC,		INC_B,		DEC_B,		LD_B_N,		RLCA,
	// EX_AF_AF,	ADD_HL_BC,	LD_A_xBC,	DEC_BC,		INC_C,		DEC_C,		LD_C_N,		RRCA,
	// DJNZ,		LD_DE_NN,	LD_xDE_A,	INC_DE,		INC_D,		DEC_D,		LD_D_N,		RLA,
	// JR,  		ADD_HL_DE,	LD_A_xDE,	DEC_DE,		INC_E,		DEC_E,		LD_E_N,		RRA,
	// JR_NZ,		LD_HL_NN,	LD_xNN_HL,	INC_HL,		INC_H,		DEC_H,		LD_H_N,		DAA,
	// JR_Z,		ADD_HL_HL,	LD_HL_xNN,	DEC_HL,		INC_L,		DEC_L,		LD_L_N,		CPL,
	// JR_NC,		LD_SP_NN,	LD_xNN_A,	INC_SP,		INC_xHL,	DEC_xHL,	LD_xHL_N,	SCF,
	// JR_C,		ADD_HL_SP,	LD_A_xNN,	DEC_SP,		INC_A,		DEC_A,		LD_A_N,		CCF,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			10u, 		0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			10u, 		0,			0,			0,			0,			0,			0,
		0,			12u,		19u, 		7u,			0,			0,			0,			0,
		0,			10u, 		18u, 		7u,			0,			0,			0,			0,
		0,			0,			0,			0,			18u, 		18u, 		15u, 		0,
		0,			10u, 		0,			0,			0,			0,			0,			0,

	// LD_B_B,		LD_B_C,		LD_B_D,		LD_B_E,		LD_B_H,		LD_B_L,		LD_B_xHL,	LD_B_A,
	// LD_C_B,		LD_C_C,		LD_C_D,		LD_C_E,		LD_C_H,		LD_C_L,		LD_C_xHL,	LD_C_A,
	// LD_D_B,		LD_D_C,		LD_D_D,		LD_D_E,		LD_D_H,		LD_D_L,		LD_D_xHL,	LD_D_A,
	// LD_E_B,		LD_E_C,		LD_E_D,		LD_E_E,		LD_E_H,		LD_E_L,		LD_E_xHL,	LD_E_A,
	// LD_H_B,		LD_H_C,		LD_H_D,		LD_H_E,		LD_H_H,		LD_H_L,		LD_H_xHL,	LD_H_A,
	// LD_L_B,		LD_L_C,		LD_L_D,		LD_L_E,		LD_L_H,		LD_L_L,		LD_L_xHL,	LD_L_A,
	// LD_xHL_B,	LD_xHL_C,	LD_xHL_D,	LD_xHL_E,	LD_xHL_H,	LD_xHL_L,	HALT,		LD_xHL_A,
	// LD_A_B,		LD_A_C,		LD_A_D,		LD_A_E,		LD_A_H,		LD_A_L,		LD_A_xHL,	LD_A_A,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		15u, 		15u, 		15u, 		15u, 		15u, 		15u, 		0,			15u,
		0,			0,			0,			0,			0,			0,			14u, 		0,

	// ADD_B,		ADD_C,		ADD_D,		ADD_E,		ADD_H,		ADD_L,		ADD_xHL,	ADD_A,
	// ADC_B,		ADC_C,		ADC_D,		ADC_E,		ADC_H,		ADC_L,		ADC_xHL,	ADC_A,
	// SUB_B,		SUB_C,		SUB_D,		SUB_E,		SUB_H,		SUB_L,		SUB_xHL,	SUB_A,
	// SBC_B,		SBC_C,		SBC_D,		SBC_E,		SBC_H,		SBC_L,		SBC_xHL,	SBC_A,
	// AND_B,		AND_C,		AND_D,		AND_E,		AND_H,		AND_L,		AND_xHL,	AND_A,
	// XOR_B,		XOR_C,		XOR_D,		XOR_E,		XOR_H,		XOR_L,		XOR_xHL,	XOR_A,
	// OR_B,		OR_C,		OR_D,		OR_E,		OR_H,		OR_L,		OR_xHL,		OR_A,
	// CP_B,		CP_C,		CP_D,		CP_E,		CP_H,		CP_L,		CP_xHL,		CP_A,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,
		0,			0,			0,			0,			0,			0,			14u, 		0,

	// RET_NZ,		POP_BC,		JP_NZ,		JP,			CALL_NZ,	PUSH_BC,	ADD_N,		RST00,
	// RET_Z,		RET,		JP_Z,		PFX_CB,		CALL_Z,		CALL,		ADC_N,		RST08,
	// RET_NC,		POP_DE,		JP_NC,		OUTA,		CALL_NC,	PUSH_DE,	SUB_N,		RST10,
	// RET_C,		EXX,		JP_C,		INA,		CALL_C,		PFX_IX,		SBC_N,		RST18,
	// RET_PO,		POP_HL,		JP_PO,		EX_HL_xSP,	CALL_PO,	PUSH_HL,	AND_N,		RST20,
	// RET_PE,		JP_HL,		JP_PE,		EX_DE_HL,	CALL_PE,	PFX_ED,		XOR_N,		RST28,
	// RET_P,		POP_AF,		JP_P,		DI,			CALL_P,		PUSH_AF,	OR_N,		RST30,
	// RET_M,		LD_SP_HL,	JP_M,		EI,			CALL_M,		PFX_IY,		CP_N,		RST38
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			12u, 		0,			19u, 		0,			14u, 		0,			0,
		0,			6u,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			7u,			0,			0,			0,			0,			0,			0,
};

static const uint8 cc_z180_ED[256] =
{
	// Table for EDxx opcodes:
	// times are for the entire opcode incl. ED
	// illegal opcodes are trapped by the Z80180

	// IN0_B_xN, 	OUT0_B_xN, 	ED02,		ED03,		TST_B,		ED05,		ED06,		ED07,
	// IN0_C_xN, 	OUT0_C_xN, 	ED0A,		ED0B,		TST_C,		ED0D,		ED0E,		ED0F,
	// IN0_D_xN, 	OUT0_D_xN, 	ED12,		ED13,		TST_D,		ED15,		ED16,		ED17,
	// IN0_E_xN, 	OUT0_E_xN, 	ED1A,		ED1B,		TST_E,		ED1D,		ED1E,		ED1F,
	// IN0_H_xN, 	OUT0_H_xN, 	ED22,		ED23,		TST_H,		ED25,		ED26,		ED27,
	// IN0_L_xN, 	OUT0_L_xN, 	ED2A,		ED2B,		TST_L,		ED2D,		ED2E,		ED2F,
	// IN0_F_xN, 	ED31,		ED32,		ED33,		TST_xHL,	ED35,		ED36,		ED37,
	// IN0_A_xN, 	OUT0_A_xN,	ED3A,		ED3B,		TST_A,		ED3D,		ED3E,		ED3F,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,
		12u, 		0,			0,			0,			10u, 		0,			0,			0,
		12u, 		13u,		0,			0,			7u,			0,			0,			0,

	// IN_B_xC, 	OUT_xC_B,	SBC_HL_BC,	LD_xNN_BC,	NEG,		RETN,		IM_0,		LD_I_A,
	// IN_C_xC, 	OUT_xC_C,	ADC_HL_BC,	LD_BC_xNN,	MLT_BC,		RETI,		ED4E,		LD_R_A,
	// IN_D_xC, 	OUT_xC_D,	SBC_HL_DE,	LD_xNN_DE,	ED54,		ED55,		IM_1,		LD_A_I,
	// IN_E_xC, 	OUT_xC_E,	ADC_HL_DE,	LD_DE_xNN,	MLT_DE,		ED5D,		IM_2,		LD_A_R,
	// IN_H_xC, 	OUT_xC_H,	SBC_HL_HL,	LD_xNN_HL,	TST_N,		ED65,		ED66,		RRD,
	// IN_L_xC, 	OUT_xC_L,	ADC_HL_HL,	LD_HL_xNN,	MLT_HL,		ED6D,		ED6E,		RLD,
	// IN_F_xC, 	ED71,		SBC_HL_SP,	LD_xNN_SP,	TSTIO,		ED75,		SLP,		ED77,	note: in f,(c) is legal
	// IN_A_xC, 	OUT_xC_A,	ADC_HL_SP,	LD_SP_xNN,	MLT_SP,		ED7D,		ED7E,		ED7F,
		9u,			10u, 		10u, 		19u, 		6u,			12u, 		6u,			6u,
		9u,			10u, 		10u, 		18u, 		17u, 		12u, 		0,			6u,
		9u,			10u, 		10u, 		19u, 		0,			0,			6u,			6u,
		9u,			10u, 		10u, 		18u, 		17u, 		0,			6u,			6u,
		9u,			10u, 		10u, 		19u, 		9u,			0,			0,			16u,
		9u,			10u, 		10u, 		18u, 		17u, 		0,			0,			16u,
		9u,			12, 		10u, 		19u, 		12u, 		0,			8u,			0,
		9u,			10u, 		10u, 		18u, 		17u, 		0,			0,			0,

	// ED80,		ED81,		ED82,		OTIM,		ED84,		ED85,		ED86,		ED87,
	// ED88,		ED89,		ED8A,		OTDM,		ED8C,		ED8D,		ED8E,		ED8F,
	// ED90,		ED91,		ED92,		OTIMR,		ED94,		ED95,		ED96,		ED97,
	// ED98,		ED99,		ED9A,		OTDMR,		ED9C,		ED9D,		ED9E,		ED9F,
	// LDI, 		CPI,		INI,		OUTI,		EDA4,		EDA5,		EDA6,		EDA7,
	// LDD, 		CPD,		IND,		OUTD,		EDAC,		EDAD,		EDAE,		EDAF,
	// LDIR,		CPIR,		INIR,		OTIR,		EDB4,		EDB5,		EDB6,		EDB7,
	// LDDR,		CPDR,		INDR,		OTDR,		EDBC,		EDBD,		EDBE,		EDBF,
		0,			0,			0,			14u, 		0,			0,			0,			0,
		0,			0,			0,			14u, 		0,			0,			0,			0,
		0,			0,			0,			Z(14u,16u),	0,			0,			0,			0,
		0,			0,			0,			Z(14u,16u),	0,			0,			0,			0,
		12u, 		12u, 		12u, 		12u, 		0,			0,			0,			0,
		12u, 		12u, 		12u, 		12u, 		0,			0,			0,			0,
		Z(12u,14u),	Z(12u,14u),	Z(12u,14u),	Z(12u,14u),	0,			0,			0,			0,
		Z(12u,14u),	Z(12u,14u),	Z(12u,14u),	Z(12u,14u),	0,			0,			0,			0,

	// EDC0,		EDC1,		EDC2,		EDC3,		EDC4,		EDC5,		EDC6,		EDC7,
	// EDC8,		EDC9,		EDCA,		EDCB,		EDCC,		EDCD,		EDCE,		EDCF,
	// EDD0,		EDD1,		EDD2,		EDD3,		EDD4,		EDD5,		EDD6,		EDD7,
	// EDD8,		EDD9,		EDDA,		EDDB,		EDDC,		EDDD,		EDDE,		EDDF,
	// EDE0,		EDE1,		EDE2,		EDE3,		EDE4,		EDE5,		EDE6,		EDE7,
	// EDE8,		EDE9,		EDEA,		EDEB,		EDEC,		EDED,		EDEE,		EDEF,
	// EDF0,		EDF1,		EDF2,		EDF3,		EDF4,		EDF5,		EDF6,		EDF7,
	// EDF8,		EDF9,		EDFA,		EDFB,		EDFC,		EDFD,		EDFE,		EDFF
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
		0,			0,			0,			0,			0,			0,			0,			0,
};





Z80::RVal Z80::runZ180 (CpuCycle ccx)
{
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
	POKE(w,c);

nxtcmnd:
	while (cc < ccx)				// fast loop exit test
	{
		GET_INSTR(c);
		cc += cc_z180[c];

		switch (c)
		{

		// ########	4 T cycle Instructions #########################

		// LD R,R
		{
		case LD_B_B:			LOOP;
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
		case ADD_B:		M_ADD(RB); LOOP;
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
		case DEC_B:		M_DEC(RB);LOOP;
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
		case JP_HL:
			pc = HL;
			LOOP;

		case EX_DE_HL:
			w=DE;DE=HL;HL=w;
			LOOP;

		case EX_AF_AF:
			c=ra;ra=RA2;RA2=c;
			c=rf;rf=RF2;RF2=c;
			LOOP;

		case EXX:
			w=BC;BC=BC2;BC2=w;
			w=DE;DE=DE2;DE2=w;
			w=HL;HL=HL2;HL2=w;
			LOOP;

		case HALT:						// ((executes NOPs until interrupt))
			pc--;
			if (halt) LOOP;
			if (pc == breakpoint) { cc -= 3; r--; EXIT(BreakPoint); }
			halt = true;
			LOOP;

		case NOP:
			LOOP;

		case DI:
			IFF1=IFF2=disabled;
			LOOP;

		case EI:
			IFF1=IFF2=enabled;
			ccx = cc+1;	// exit the fast loop after next cmd -> reload ccx & goto slow_loop
			LOOP;		// der nächste Befehl wird auf jeden Fall noch ausgeführt.

		case SCF:
			rf |= C_FLAG;
			rf &= ~(N_FLAG+H_FLAG);
			LOOP;

		case CCF:
			rf ^= C_FLAG;
			rf &= ~N_FLAG;
			LOOP;

		case CPL:
			ra = ~ra;
			rf |= N_FLAG+H_FLAG;
			LOOP;

		case RLCA:
			ra = uint8(ra<<1) + (ra>>7);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra&C_FLAG);
			cc--;
			LOOP;

		case RRCA:
			ra = (ra>>1) + uint8(ra<<7);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + (ra>>7);
			cc--;
			LOOP;

		case RLA:
			c  = ra>>7;
			ra = uint8(ra<<1) + (rf&C_FLAG);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
			cc--;
			LOOP;

		case RRA:
			c  = ra&C_FLAG;
			ra = (ra>>1) + uint8(rf<<7);
			rf = (rf&~(C_FLAG+N_FLAG+H_FLAG)) + c;
			cc--;
			LOOP;

		case DAA:
			if (rf&N_FLAG)
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
		case DEC_BC:	BC--;	LOOP;
		case DEC_DE:	DE--;	LOOP;
		case DEC_HL:	HL--;	LOOP;
		case DEC_SP:	SP--;	LOOP;
		case INC_BC:	BC++;	LOOP;
		case INC_DE:	DE++;	LOOP;
		case INC_HL:	HL++;	LOOP;
		case INC_SP:	SP++;	LOOP;

		case LD_SP_HL:	SP = HL; LOOP;

		case ADD_HL_BC:	M_ADDW(HL,BC); LOOP;
		case ADD_HL_DE:	M_ADDW(HL,DE); LOOP;
		case ADD_HL_HL:	M_ADDW(HL,HL); LOOP;
		case ADD_HL_SP:	M_ADDW(HL,SP); LOOP;
		}

		// ########	Read-only-from-memory Instructions #########################
		{
		uint8* p;
		case LD_B_xHL:	p=&RB; goto ld_xhl;
		case LD_C_xHL:	p=&RC; goto ld_xhl;
		case LD_D_xHL:	p=&RD; goto ld_xhl;
		case LD_E_xHL:	p=&RE; goto ld_xhl;
		case LD_H_xHL:	p=&RH; goto ld_xhl;
		case LD_L_xHL:	p=&RL; goto ld_xhl;
		ld_xhl:
			PEEK(*p,HL);
			LOOP;

		case LD_B_N:	p=&RB; goto ld_n;
		case LD_C_N:	p=&RC; goto ld_n;
		case LD_D_N:	p=&RD; goto ld_n;
		case LD_E_N:	p=&RE; goto ld_n;
		case LD_H_N:	p=&RH; goto ld_n;
		case LD_L_N:	p=&RL; goto ld_n;
		ld_n:
			GET_N(*p);
			LOOP;
		}
		case LD_A_N:
			GET_N(ra);
			LOOP;

		case ADD_xHL:	PEEK(c,HL);   M_ADD(c); LOOP;
		case SUB_xHL:	PEEK(c,HL);   M_SUB(c); LOOP;
		case ADC_xHL:	PEEK(c,HL);   M_ADC(c); LOOP;
		case SBC_xHL:	PEEK(c,HL);   M_SBC(c); LOOP;
		case CP_xHL:	PEEK(c,HL);   M_CP(c);  LOOP;
		case OR_xHL:	PEEK(c,HL);   M_OR(c);  LOOP;
		case XOR_xHL:	PEEK(c,HL);   M_XOR(c); LOOP;
		case AND_xHL:	PEEK(c,HL);   M_AND(c); LOOP;

		case ADD_N:		GET_N(c);   M_ADD(c); LOOP;
		case ADC_N:		GET_N(c);   M_ADC(c); LOOP;
		case SUB_N:		GET_N(c);   M_SUB(c); LOOP;
		case SBC_N:		GET_N(c);   M_SBC(c); LOOP;
		case CP_N:		GET_N(c);   M_CP(c);  LOOP;
		case OR_N:		GET_N(c);   M_OR(c);  LOOP;
		case XOR_N:		GET_N(c);   M_XOR(c); LOOP;
		case AND_N:		GET_N(c);   M_AND(c); LOOP;

		case LD_SP_NN: 	rzp=&registers.sp; goto ld_nn;
		case LD_BC_NN: 	rzp=&registers.bc; goto ld_nn;
		case LD_DE_NN: 	rzp=&registers.de; goto ld_nn;
		case LD_HL_NN: 	rzp=&registers.hl; goto ld_nn;
		ld_nn:
			GET_N(rzl); GET_N(rzh);
			LOOP;

		case JP_NZ:		if (rf&Z_FLAG) goto njp; else goto jp;
		case JP_NC:		if (rf&C_FLAG) goto njp; else goto jp;
		case JP_PO:		if (rf&P_FLAG) goto njp; else goto jp;
		case JP_P:		if (rf&S_FLAG) goto njp; else goto jp;
		case JP_C:		if (rf&C_FLAG) goto jp; else goto njp;
		case JP_PE:		if (rf&P_FLAG) goto jp; else goto njp;
		case JP_M:		if (rf&S_FLAG) goto jp; else goto njp;
		case JP_Z:		if (rf&Z_FLAG) goto jp; else goto njp;
		njp:
			SKIP_N(); SKIP_N();
			cc -= 3;				// jp = 9cc -> njp = 6cc
			LOOP;

		case JP:
		jp:
			GET_NN(w);
			pc = w;
			LOOP;

		case JR:
		jr:
			GET_N(c);
			cc += 5;
			pc += int8(c);
			LOOP;

		case JR_Z:
			if (rf&Z_FLAG) goto jr; else goto njr;
		njr:SKIP_N();
			cc -= 2;				// jr = 8cc -> njr = 6cc   (djnz: 9->7)
			LOOP;

		case JR_C:
			if (rf&C_FLAG) goto jr; else goto njr;

		case JR_NZ:
			if (rf&Z_FLAG) goto njr; else goto jr;

		case JR_NC:
			if (rf&C_FLAG) goto njr; else goto jr;

		case DJNZ:
			cc += 1;
			if (--RB) goto jr; else goto njr;

		case RET:
		ret:
			POP(PCL); POP(PCH);
			pc = PC;
			LOOP;

		case RET_NZ:	if (rf&Z_FLAG) goto nret; else goto ret;
		case RET_NC:	if (rf&C_FLAG) goto nret; else goto ret;
		case RET_PO:	if (rf&P_FLAG) goto nret; else goto ret;
		case RET_P:		if (rf&S_FLAG) goto nret; else goto ret;
		case RET_Z:		if (rf&Z_FLAG) goto ret; else goto nret; { nret: cc -= 5; LOOP; }
		case RET_C:		if (rf&C_FLAG) goto ret; else goto nret;
		case RET_PE:	if (rf&P_FLAG) goto ret; else goto nret;
		case RET_M:		if (rf&S_FLAG) goto ret; else goto nret;

		case LD_A_xNN:	GET_NN(w); goto ld_a_xw;
		case LD_A_xBC:	w=BC;      goto ld_a_xw;
		case LD_A_xDE:	w=DE;	   goto ld_a_xw;
		case LD_A_xHL:	w=HL;	   goto ld_a_xw;

		ld_a_xw:
			PEEK(ra,w);
			LOOP;

		case LD_HL_xNN:
			GET_NN(w);
			PEEK(RL,w); PEEK(RH,w+1);
			LOOP;

		case POP_BC:	rzp=&registers.bc; goto pop_rr;
		case POP_DE:	rzp=&registers.de; goto pop_rr;
		case POP_HL:	rzp=&registers.hl; goto pop_rr;
		pop_rr:
			POP(rzl); POP(rzh);
			LOOP;

		case POP_AF:
			POP(rf); POP(ra);
			LOOP;

		case OUTA:
			GET_N(c);
			OUTPUT ( ra*256 + c, ra );
			LOOP;

		case INA:
			GET_N(c);
			INPUT ( ra*256 + c, ra );
			LOOP;


		// ########	Write-to-memory Instructions #####################
		case CALL_NC: 	if (rf&C_FLAG) goto nocall; else goto call;
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
			cc -= 10;		// call = 16cc -> nocall = 6cc
			LOOP;

		case CALL:
		call:
			GET_NN(w);
		rst:PUSH(pc>>8);
			PUSH(pc);
			pc = w;
			LOOP;

		case RST00:	w=0x0000; goto rst;
		case RST08: w=0x0008; goto rst;
		case RST10: w=0x0010; goto rst;
		case RST18: w=0x0018; goto rst;
		case RST20: w=0x0020; goto rst;
		case RST28: w=0x0028; goto rst;
		case RST30: w=0x0030; goto rst;
		case RST38: w=0x0038; goto rst;

		case DEC_xHL:
			w = HL;
			PEEK(c,w); M_DEC(c);
			POKE_AND_LOOP(w,c);

		case INC_xHL:
			w = HL;
			PEEK(c,w); M_INC(c);
			POKE_AND_LOOP(w,c);

		case LD_xHL_B:	POKE_AND_LOOP(HL,RB);
		case LD_xHL_C:	POKE_AND_LOOP(HL,RC);
		case LD_xHL_D:	POKE_AND_LOOP(HL,RD);
		case LD_xHL_E:	POKE_AND_LOOP(HL,RE);
		case LD_xHL_H:	POKE_AND_LOOP(HL,RH);
		case LD_xHL_L:	POKE_AND_LOOP(HL,RL);

		case LD_xHL_A:	POKE_AND_LOOP(HL,ra);
		case LD_xBC_A:	POKE_AND_LOOP(BC,ra);
		case LD_xDE_A:	POKE_AND_LOOP(DE,ra);

		case LD_xHL_N:	GET_N(c); POKE_AND_LOOP(HL,c);

		case LD_xNN_A:	GET_NN(w); POKE_AND_LOOP(w,ra);

		case LD_xNN_HL:	GET_NN(w); POKE(w,RL); POKE_AND_LOOP(w+1,RH);

		case PUSH_BC:	w=BC; goto push_w;
		case PUSH_DE:	w=DE; goto push_w;
		case PUSH_HL:	w=HL; goto push_w;
				push_w:	PUSH(wh); PUSH(wl); LOOP;
		case PUSH_AF:	PUSH(ra); PUSH(rf); LOOP;

		case EX_HL_xSP:
			w = HL;
			PEEK(RL,SP); PEEK(RH,SP+1);
			POKE(SP+1,wh); POKE(SP,wl);
			LOOP;


	// ==========================================================================
	//	PREFIX IX / IY COMMANDS
	// ==========================================================================

		case PFX_IY: rzp = &registers.iy; goto XY;
		case PFX_IX: rzp = &registers.ix; goto XY;
		{
		XY: GET_XY_OP(c);
			cc += cc_z180_XY[c];

			switch(c)
			{
			// opcodes using dreg IY or IY:
			{
			case JP_HL:
				pc = rz;
				LOOP;

			case LD_SP_HL:
				SP = rz;
				LOOP;

			case DEC_HL:
				rz--;
				LOOP;

			case INC_HL:
				rz++;
				LOOP;

			case ADD_HL_BC:
				M_ADDW(rz,BC);
				LOOP;

			case ADD_HL_DE:
				M_ADDW(rz,DE);
				LOOP;

			case ADD_HL_HL:
				M_ADDW(rz,rz);
				LOOP;

			case ADD_HL_SP:
				M_ADDW(rz,SP);
				LOOP;

			case PUSH_HL:
				PUSH(rzh); PUSH(rzl);
				LOOP;

			case POP_HL:
				POP(rzl);  POP(rzh);
				LOOP;

			case LD_HL_NN:
				GET_NN(rz);
				LOOP;

			case LD_xNN_HL:
				GET_NN(w);
				POKE(w,rzl);
				POKE_AND_LOOP(w+1,rzh);

			case LD_HL_xNN:
				GET_NN(w);
				PEEK(rzl,w);
				PEEK(rzh,w+1);
				LOOP;

			case EX_HL_xSP:
				w = rz;
				PEEK(rzl,SP); PEEK(rzh,SP+1);
				POKE(SP+1,wh); POKE(SP,wl);
				LOOP;
			}

			// IXIY opcodes with IX+dis:
			{
			uint8 dis; // attn: unsigned!

			case LD_xHL_B:	c=RB; goto ld_x_c;
			case LD_xHL_C:	c=RC; goto ld_x_c;
			case LD_xHL_D:	c=RD; goto ld_x_c;
			case LD_xHL_E:	c=RE; goto ld_x_c;
			case LD_xHL_H:	c=RH; goto ld_x_c;
			case LD_xHL_L:	c=RL; goto ld_x_c;
			case LD_xHL_A:	c=ra; goto ld_x_c;
			ld_x_c:
				GET_N(dis);
				POKE_AND_LOOP(rz+uint16(int8(dis)),c);

			{ uint8* p;
			case LD_B_xHL:	p=&RB; goto ld_p_x;
			case LD_C_xHL:	p=&RC; goto ld_p_x;
			case LD_D_xHL:	p=&RD; goto ld_p_x;
			case LD_E_xHL:	p=&RE; goto ld_p_x;
			case LD_H_xHL:	p=&RH; goto ld_p_x;
			case LD_L_xHL:	p=&RL; goto ld_p_x;
			ld_p_x:
				GET_N(dis);
				w = rz+uint16(int8(dis));
				PEEK(*p,w);
				LOOP;
			}
			case LD_A_xHL:
				GET_N(dis);
				w = rz+uint16(int8(dis));
				PEEK(ra,w);
				LOOP;

			case LD_xHL_N:
				GET_N(dis);
				GET_N(c);
				POKE_AND_LOOP(rz+uint16(int8(dis)),c);

			case DEC_xHL:
				GET_N(dis);
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				M_DEC(c);
				POKE_AND_LOOP(w,c);

			case INC_xHL:
				GET_N(dis);
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				M_INC(c);
				POKE_AND_LOOP(w,c);

			case ADD_xHL:
				GET_N(dis);
				w = rz+uint16(int8(dis));
				PEEK(c,w);
				M_ADD(c);
				LOOP;

			case SUB_xHL: GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_SUB(c); LOOP;
			case ADC_xHL: GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_ADC(c); LOOP;
			case SBC_xHL: GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_SBC(c); LOOP;
			case CP_xHL:  GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_CP(c);	 LOOP;
			case AND_xHL: GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_AND(c); LOOP;
			case OR_xHL:  GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_OR(c);	 LOOP;
			case XOR_xHL: GET_N(dis); w=rz+uint16(int8(dis)); PEEK(c,w); M_XOR(c); LOOP;
			}

			// IXIY + 0xCB:
			case PFX_CB:
			{
				uint8 o;
				uint8 dis;	// attn: unsigned!

				GET_N(dis);
				w = rz+uint16(int8(dis));	// target address
				PEEK(c,w);					// target

				GET_XYCB_OP(o);
				if ((o&0x07) != 6) goto ill_ixcb;

				cc += 15;					// time for BIT opcodes = 15

				// perform instruction:
				switch (o>>3)
				{
				case BIT0_xHL>>3: M_BIT(0x01,c); LOOP;
				case BIT1_xHL>>3: M_BIT(0x02,c); LOOP;
				case BIT2_xHL>>3: M_BIT(0x04,c); LOOP;
				case BIT3_xHL>>3: M_BIT(0x08,c); LOOP;
				case BIT4_xHL>>3: M_BIT(0x10,c); LOOP;
				case BIT5_xHL>>3: M_BIT(0x20,c); LOOP;
				case BIT6_xHL>>3: M_BIT(0x40,c); LOOP;
				case BIT7_xHL>>3: M_BIT(0x80,c); LOOP;

				case RLC_xHL>>3:  M_RLC(c);	 	break;
				case RRC_xHL>>3:  M_RRC(c);	 	break;
				case RL_xHL>>3:	  M_RL(c); 	 	break;
				case RR_xHL>>3:	  M_RR(c); 	 	break;
				case SLA_xHL>>3:  M_SLA(c);	 	break;
				case SRA_xHL>>3:  M_SRA(c);	 	break;
				case SLL_xHL>>3:				cc -= 15; goto ill_ixcb;
				case SRL_xHL>>3:  M_SRL(c);	 	break;

				case RES0_xHL>>3: c &= ~0x01; 	break;
				case RES1_xHL>>3: c &= ~0x02; 	break;
				case RES2_xHL>>3: c &= ~0x04; 	break;
				case RES3_xHL>>3: c &= ~0x08; 	break;
				case RES4_xHL>>3: c &= ~0x10; 	break;
				case RES5_xHL>>3: c &= ~0x20; 	break;
				case RES6_xHL>>3: c &= ~0x40; 	break;
				case RES7_xHL>>3: c &= ~0x80; 	break;

				case SET0_xHL>>3: c |= 0x01;  	break;
				case SET1_xHL>>3: c |= 0x02;  	break;
				case SET2_xHL>>3: c |= 0x04;  	break;
				case SET3_xHL>>3: c |= 0x08;  	break;
				case SET4_xHL>>3: c |= 0x10;  	break;
				case SET5_xHL>>3: c |= 0x20;  	break;
				case SET6_xHL>>3: c |= 0x40;  	break;
				case SET7_xHL>>3: c |= 0x80;  	break;
				}

				cc += 4;			// time for SET, RES or SHIFT opcodes = 19

				POKE_AND_LOOP(w,c);	// SET, RES or SHIFT
			}

			default:
				goto ill_ix;
			}
		}

	// ==========================================================================
	//	PREFIX CB COMMANDS
	// ==========================================================================

		case PFX_CB:
		{
			GET_CB_OP(w);	// fetch opcode

			cc += (w&7)==6 ? (w&0xc0)==0x40 ? 9 : 13	// bit x,(hl) = 9cc,  set/res/shift = 13cc
						   : (w&0xc0)==0x00 ? 7 : 6;	// shift r    = 7cc,  bit/set/res   = 6cc

			// read source: b,c,d,e,h,l,(hl),a
			switch (w & 0x07)
			{
			case 0: c=RB; break;
			case 1: c=RC; break;
			case 2: c=RD; break;
			case 3: c=RE; break;
			case 4: c=RH; break;
			case 5: c=RL; break;
			case 6: PEEK(c,HL); break;
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
			case SLL_B>>3:	cc -= (w&7)==6 ? 13 : 9; goto ill_cb;
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

		case PFX_ED:	// 4 T: Timing berücksichtigt im ED-Dispatcher

		GET_ED_OP(c);
		cc += cc_z180_ED[c];

		switch(c)
		{
		case ADC_HL_BC: rzp=&registers.bc; goto adc_hl_rr;
		case ADC_HL_DE: rzp=&registers.de; goto adc_hl_rr;
		case ADC_HL_HL: rzp=&registers.hl; goto adc_hl_rr;
		case ADC_HL_SP: rzp=&registers.sp; goto adc_hl_rr;
		adc_hl_rr:
			M_ADCW(rz);
			LOOP;

		case SBC_HL_BC: rzp=&registers.bc; goto sbc_hl_rr;
		case SBC_HL_DE: rzp=&registers.de; goto sbc_hl_rr;
		case SBC_HL_HL: rzp=&registers.hl; goto sbc_hl_rr;
		case SBC_HL_SP: rzp=&registers.sp; goto sbc_hl_rr;
		sbc_hl_rr:
			M_SBCW(rz);
			LOOP;

		case LD_xNN_BC:	rzp = &registers.bc; goto ld_xnn_rr;
		case LD_xNN_DE:	rzp = &registers.de; goto ld_xnn_rr;
		case ED_xNN_HL:	rzp = &registers.hl; goto ld_xnn_rr;
		case LD_xNN_SP:	rzp = &registers.sp; goto ld_xnn_rr;
		ld_xnn_rr:
			GET_NN(w);
			POKE(w,rzl);
			POKE_AND_LOOP(w+1,rzh);

		case LD_BC_xNN:	GET_NN(w); PEEK(RC,w);  PEEK(RB,w+1); LOOP;
		case LD_DE_xNN:	GET_NN(w); PEEK(RE,w);  PEEK(RD,w+1); LOOP;
		case ED_HL_xNN:	GET_NN(w); PEEK(RL,w);  PEEK(RH,w+1); LOOP;
		case LD_SP_xNN:	GET_NN(w); PEEK(SPL,w); PEEK(SPH,w+1);LOOP;

		{ uint8* p;
		  uint8 z;
		case IN_F_xC:	p=&z;  goto in_r_xc;
		case IN_B_xC:	p=&RB; goto in_r_xc;
		case IN_C_xC:	p=&RC; goto in_r_xc;
		case IN_D_xC:	p=&RD; goto in_r_xc;
		case IN_E_xC:	p=&RE; goto in_r_xc;
		case IN_H_xC:	p=&RH; goto in_r_xc;
		case IN_L_xC: 	p=&RL; goto in_r_xc;
			 in_r_xc:	M_IN(*p); LOOP;
		case IN_A_xC:	M_IN(ra); LOOP;
		}

		case OUT_xC_B:	c=RB; goto out_xc_r;
		case OUT_xC_C: 	c=RC; goto out_xc_r;
		case OUT_xC_D: 	c=RD; goto out_xc_r;
		case OUT_xC_E: 	c=RE; goto out_xc_r;
		case OUT_xC_H: 	c=RH; goto out_xc_r;
		case OUT_xC_L: 	c=RL; goto out_xc_r;
		case OUT_xC_A: 	c=ra; goto out_xc_r;
			 out_xc_r:	OUTPUT(BC,c); LOOP;
		case OUT_xC_0: 	c=0;  goto out_xc_r;	// unclear whether this is illegal

		case LD_I_A:
			RI = ra;
			LOOP;

		case LD_R_A:
			registers.r = r = ra;
			LOOP;

		case LD_A_I:
			ra = RI;
			rf = (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
			LOOP;

		case LD_A_R:
			ra = (registers.r&0x80) + (r&0x7F);
			rf = (rf&C_FLAG) + (IFF2?P_FLAG:0) + (ra?0:Z_FLAG) + (ra&S_FLAG);
			LOOP;

		case RRD:
		{	uint8 o;
			w = HL; PEEK(o,w);
			c = uint8((o>>4) + (ra<<4));
			ra = (ra&0xF0) + (o&0x0F);
			goto rld;
		case RLD:
			w = HL; PEEK(o,w);
			c = uint8((o<<4) + (ra&0x0F));
			ra = (ra&0xF0) + (o>>4);
		rld:rf	= (rf&C_FLAG) + zlog_flags[ra];
			cc += 4;
		}	POKE_AND_LOOP(w,c);

		case IM_0:	registers.im=0; LOOP;
		case IM_1:	registers.im=1; LOOP;
		case IM_2:	registers.im=2; LOOP;

		case SLP:
			// Z180: note: SLP = 0xED + HALT
			// timing diagram seems to have no alignment
			// but timing seems to be 4+3 + 2+sleeping+2	TODO

			// TODO: SLEEP resumes even when DI ?  !!!

			cc = ccx;
			pc--;			// pc -> opcode HALT
			assert(!halt);	// -> HALT opcode
			halt = true;
			LOOP;

		case MLT_BC:		// Z180: 8-bit multiply with 16-bit result
			BC = RB * RC;	// flags not affected
			LOOP;

		case MLT_DE:
			DE = RD * RE;
			LOOP;

		case MLT_HL:
			HL = RH * RL;
			LOOP;

		case MLT_SP:
			SP = SPH * SPL;	// this is funny, to say the least
			LOOP;

		// Z180: INO g,(m): Input register from immediate I/O address:
		{ uint8* p;
		  uint8 z;
		case IN0_F_xN:	p=&z;  goto in0_r_xn;
		case IN0_B_xN:	p=&RB; goto in0_r_xn;
		case IN0_C_xN:	p=&RC; goto in0_r_xn;
		case IN0_D_xN:	p=&RD; goto in0_r_xn;
		case IN0_E_xN:	p=&RE; goto in0_r_xn;
		case IN0_H_xN:	p=&RH; goto in0_r_xn;
		case IN0_L_xN: 	p=&RL; goto in0_r_xn;
		in0_r_xn:
			GET_N(c);
			M_IN0(c,*p);
			LOOP;
		case IN0_A_xN:
			GET_N(c);
			M_IN0(c,ra);
			LOOP;
		}

		// Z180: OUT0 (m),g: Output register to immediate I/O address:
		case OUT0_xN_B: c=RB; goto out0_r_xN;
		case OUT0_xN_C: c=RC; goto out0_r_xN;
		case OUT0_xN_D: c=RD; goto out0_r_xN;
		case OUT0_xN_E: c=RE; goto out0_r_xN;
		case OUT0_xN_H: c=RH; goto out0_r_xN;
		case OUT0_xN_L: c=RL; goto out0_r_xN;
		case OUT0_xN_A: c=ra; goto out0_r_xN;
		out0_r_xN:
		{	uint8 n;
			GET_N(n);
			OUTPUT(n,c);
		}	LOOP;

		case TST_N:			// TST N: ra & N
			GET_N(c);		// N
			M_TST(ra,c);
			LOOP;

		case TSTIO:			// TSTIO m: io(C) & N
		{	uint8 n;
			GET_N(n);		// N
			M_IN0(RC,c);	// io
			M_TST(c,n);
		}	LOOP;

		// Z180: TST (hl):  ra & (hl)
		case TST_xHL: PEEK(c,HL); goto tst_r;

		// Z180: TST r:  ra & r
		case TST_B:	c = RB; goto tst_r;
		case TST_C:	c = RC; goto tst_r;
		case TST_D:	c = RD; goto tst_r;
		case TST_E:	c = RE; goto tst_r;
		case TST_H:	c = RH; goto tst_r;
		case TST_L:	c = RL; goto tst_r;
		case TST_A:	c = ra; goto tst_r;
		tst_r:
			M_TST(ra,c);
			LOOP;

		case NEG:
			c=ra; ra=0;
			M_SUB(c);
			LOOP;

		case RETI:
		case RETN:
			IFF1=IFF2;
			goto ret;


		// ########	Block Instructions ###############################

		case LDDR:	w = uint16(-1); goto ldir;			// Load, decrement and repeat
		case LDIR:	w = 1;								// Load, increment and repeat
		ldir:		PEEK(c,HL);
					POKE(DE,c);
					rf &= ~(N_FLAG+H_FLAG+P_FLAG);
					if (--BC) { rf |= P_FLAG; pc-=2; } else { cc -= 2; }
					DE += w;
					HL += w;
					LOOP;

		case LDD:	w = uint16(-1); goto ldi;			// Load and decrement
		case LDI:	w = 1;								// Load and increment
		ldi:		PEEK(c,HL);
					POKE(DE,c);
					HL += w;
					DE += w;
					rf &= ~(N_FLAG+H_FLAG+P_FLAG);
					if (--BC) rf |= P_FLAG;
					LOOP;

		case CPDR:	w = HL--; goto cpir;				// Compare, decrement and repeat
		case CPIR:	w = HL++;							// Compare, increment and repeat
		cpir:		PEEK(c,w); c = ra - c;
					BC -= 1;
					rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
					if (BC && c) { pc -= 2; } else { cc -= 2; }
					LOOP;

		case CPD:	w = HL--; goto cpi;					// Compare and decrement
		case CPI:	w = HL++;							// Compare and increment
		cpi:		PEEK(c,w); c = ra - c;
					BC -= 1;
					rf	= (rf&C_FLAG) + (c&S_FLAG) + (c?0:Z_FLAG) + N_FLAG + (BC?P_FLAG:0) + ((ra^(ra-c)^c)&H_FLAG);
					LOOP;

		case INDR:	w = HL--; goto inir;				// input, decrement and repeat
		case INIR:	w = HL++;							// input, increment and repeat
		inir:		INPUT(BC,c);						// TODO: timestamp cc for io is too late
					POKE(w,c);
					if (--RB) { pc -= 2; } else { cc -= 2; }
					rf = N_FLAG + (RB?0:Z_FLAG);		// TODO: INIR etc.: flags checken
					LOOP;

		case IND:	w = HL--; goto ini;					// input and decrement
		case INI:	w = HL++;							// input and increment
		ini:		INPUT(BC,c);						// TODO: timestamp cc for io is too late
					rf = N_FLAG + (--RB?0:Z_FLAG);
					POKE_AND_LOOP(w,c);

		case OTDR:	w = HL--; goto otir;				// output, decrement and repeat
		case OTIR:	w = HL++;							// output, increment and repeat
		otir:		PEEK(c,w);
					--RB;
					OUTPUT(BC,c);
					if (RB) { pc -= 2; } else { cc -= 2; }
					rf = N_FLAG + (RB?0:Z_FLAG);
					LOOP;

		case OUTD:	w = HL--; goto outi;				// output and decrement
		case OUTI:	w = HL++;							// output and increment
		outi:		PEEK(c,w);
					--RB;
					OUTPUT(BC,c);
					rf = N_FLAG + (RB?0:Z_FLAG);
					LOOP;

		// Z180:
		case OTDM:	// (HL) -> io(RC); HL-=1; C-=1; B-=1; S,Z,H,P,C set from B, N=Data.bit7; 14 cc
		case OTDMR:	// (HL) -> io(RC); HL-=1; C-=1; B-=1; S=0,Z=1,H=0,P=1,C=0 set from B, N=Data.bit7; 16/14 cc
		case OTIM:	// (HL) -> io(RC); HL+=1; C+=1; B-=1; S,Z,H,P,C set from B, N=Data.bit7; 14 cc
		case OTIMR:	// (HL) -> io(RC); HL+=1; C+=1; B-=1; S=0,Z=1,H=0,P=1,C=0 set from B, N=Data.bit7; 16/14 cc
			w = c;	// op2
			PEEK(c,HL);
			OUTPUT(RC,c);
			if (w & 0x08) { HL--; RC--; } else { HL++; RC++; }
			if (--RB != 0 && w & 0x10) { pc -= 2; } else { cc -= 2; }

			rf = (zlog_flags[RB]) |			// S, Z, P
				 ((RB^(RB+1)) & H_FLAG) |	// H
				 (RB == 0xff) |				// C
				 (c&0x80 ? N_FLAG : 0);		// N = MSB of data
			LOOP;

		default:	goto ill_ed;
		}

		}  // opcode dispatcher

		// all opcodes decoded!
		IERR();

	ill_ixcb:
		pc-=2;						// undo dis and op3 fetch
	ill_ix:
	ill_ed:
	ill_cb:
		pc-=2; r-=2;				// undo op1 & op2 fetch
		EXIT(IllegalInstruction);

	}  // while(cc<cc_exit)

	if (cc < ccx0) goto slow_loop; // not yet timed out
	EXIT(TimeOut);


x:	SAVE_REGISTERS;
	return RVal(w);
}





























