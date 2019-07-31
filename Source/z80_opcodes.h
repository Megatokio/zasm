/*	Copyright  (c)	Günter Woigk 1996 - 2019
					mailto:kio@little-bat.de

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	Permission to use, copy, modify, distribute, and sell this software and
	its documentation for any purpose is hereby granted without fee, provided
	that the above copyright notice appear in all copies and that both that
	copyright notice and this permission notice appear in supporting
	documentation, and that the name of the copyright holder not be used
	in advertising or publicity pertaining to distribution of the software
	without specific, written prior permission.  The copyright holder makes no
	representations about the suitability of this software for any purpose.
	It is provided "as is" without express or implied warranty.

	THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
	INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
	EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
	CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
	DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
	PERFORMANCE OF THIS SOFTWARE.


	z80 opcode enumerations
	-----------------------

	used in kio's z80 engine
	used in kio's z80 assembler
*/


/* bit masks for z80 flag register:
*/
#define		S_FLAG	0x80
#define		Z_FLAG	0x40
#define		H_FLAG	0x10
#define		P_FLAG	0x04
#define		V_FLAG	0x04
#define		N_FLAG	0x02
#define		C_FLAG	0x01



enum Codes
{
	NOP,		LD_BC_NN,	LD_xBC_A,	INC_BC,		INC_B,		DEC_B,		LD_B_N,		RLCA,
	EX_AF_AF,	ADD_HL_BC,	LD_A_xBC,	DEC_BC,		INC_C,		DEC_C,		LD_C_N,		RRCA,
	DJNZ,		LD_DE_NN,	LD_xDE_A,	INC_DE,		INC_D,		DEC_D,		LD_D_N,		RLA,
	JR, 		ADD_HL_DE,	LD_A_xDE,	DEC_DE,		INC_E,		DEC_E,		LD_E_N,		RRA,
	JR_NZ,		LD_HL_NN,	LD_xNN_HL,	INC_HL,		INC_H,		DEC_H,		LD_H_N,		DAA,
	JR_Z,		ADD_HL_HL,	LD_HL_xNN,	DEC_HL,		INC_L,		DEC_L,		LD_L_N,		CPL,
	JR_NC,		LD_SP_NN,	LD_xNN_A,	INC_SP,		INC_xHL,	DEC_xHL,	LD_xHL_N,	SCF,
	JR_C,		ADD_HL_SP,	LD_A_xNN,	DEC_SP,		INC_A,		DEC_A,		LD_A_N,		CCF,

	LD_B_B,		LD_B_C,		LD_B_D,		LD_B_E,		LD_B_H,		LD_B_L,		LD_B_xHL,	LD_B_A,
	LD_C_B,		LD_C_C,		LD_C_D,		LD_C_E,		LD_C_H,		LD_C_L,		LD_C_xHL,	LD_C_A,
	LD_D_B,		LD_D_C,		LD_D_D,		LD_D_E,		LD_D_H,		LD_D_L,		LD_D_xHL,	LD_D_A,
	LD_E_B,		LD_E_C,		LD_E_D,		LD_E_E,		LD_E_H,		LD_E_L,		LD_E_xHL,	LD_E_A,
	LD_H_B,		LD_H_C,		LD_H_D,		LD_H_E,		LD_H_H,		LD_H_L,		LD_H_xHL,	LD_H_A,
	LD_L_B,		LD_L_C,		LD_L_D,		LD_L_E,		LD_L_H,		LD_L_L,		LD_L_xHL,	LD_L_A,
	LD_xHL_B,	LD_xHL_C,	LD_xHL_D,	LD_xHL_E,	LD_xHL_H,	LD_xHL_L,	HALT,		LD_xHL_A,
	LD_A_B,		LD_A_C,		LD_A_D,		LD_A_E,		LD_A_H,		LD_A_L,		LD_A_xHL,	LD_A_A,

	ADD_B,		ADD_C,		ADD_D,		ADD_E,		ADD_H,		ADD_L,		ADD_xHL,	ADD_A,
	ADC_B,		ADC_C,		ADC_D,		ADC_E,		ADC_H,		ADC_L,		ADC_xHL,	ADC_A,
	SUB_B,		SUB_C,		SUB_D,		SUB_E,		SUB_H,		SUB_L,		SUB_xHL,	SUB_A,
	SBC_B,		SBC_C,		SBC_D,		SBC_E,		SBC_H,		SBC_L,		SBC_xHL,	SBC_A,
	AND_B,		AND_C,		AND_D,		AND_E,		AND_H,		AND_L,		AND_xHL,	AND_A,
	XOR_B,		XOR_C,		XOR_D,		XOR_E,		XOR_H,		XOR_L,		XOR_xHL,	XOR_A,
	OR_B,		OR_C,		OR_D,		OR_E,		OR_H,		OR_L,		OR_xHL,		OR_A,
	CP_B,		CP_C,		CP_D,		CP_E,		CP_H,		CP_L,		CP_xHL,		CP_A,

	RET_NZ,		POP_BC,		JP_NZ,		JP,			CALL_NZ,	PUSH_BC,	ADD_N,		RST00,
	RET_Z,		RET,		JP_Z,		PFX_CB,		CALL_Z,		CALL,		ADC_N,		RST08,
	RET_NC,		POP_DE,		JP_NC,		OUTA,		CALL_NC,	PUSH_DE,	SUB_N,		RST10,
	RET_C,		EXX,		JP_C,		INA,		CALL_C,		PFX_IX,		SBC_N,		RST18,
	RET_PO,		POP_HL,		JP_PO,		EX_HL_xSP,	CALL_PO,	PUSH_HL,	AND_N,		RST20,
	RET_PE,		JP_HL,		JP_PE,		EX_DE_HL,	CALL_PE,	PFX_ED,		XOR_N,		RST28,
	RET_P,		POP_AF,		JP_P,		DI,			CALL_P,		PUSH_AF,	OR_N,		RST30,
	RET_M,		LD_SP_HL,	JP_M,		EI,			CALL_M,		PFX_IY,		CP_N,		RST38
};


enum CodesCB
{
	RLC_B,		RLC_C,		RLC_D,		RLC_E,		RLC_H,		RLC_L,		RLC_xHL,	RLC_A,
	RRC_B,		RRC_C,		RRC_D,		RRC_E,		RRC_H,		RRC_L,		RRC_xHL,	RRC_A,
	RL_B,		RL_C,		RL_D,		RL_E,		RL_H,		RL_L,		RL_xHL,		RL_A,
	RR_B,		RR_C,		RR_D,		RR_E,		RR_H,		RR_L,		RR_xHL,		RR_A,
	SLA_B,		SLA_C,		SLA_D,		SLA_E,		SLA_H,		SLA_L,		SLA_xHL,	SLA_A,
	SRA_B,		SRA_C,		SRA_D,		SRA_E,		SRA_H,		SRA_L,		SRA_xHL,	SRA_A,
	SLL_B,		SLL_C,		SLL_D,		SLL_E,		SLL_H,		SLL_L,		SLL_xHL,	SLL_A,
	SRL_B,		SRL_C,		SRL_D,		SRL_E,		SRL_H,		SRL_L,		SRL_xHL,	SRL_A,

	BIT0_B,		BIT0_C,		BIT0_D,		BIT0_E,		BIT0_H,		BIT0_L,		BIT0_xHL,	BIT0_A,
	BIT1_B,		BIT1_C,		BIT1_D,		BIT1_E,		BIT1_H,		BIT1_L,		BIT1_xHL,	BIT1_A,
	BIT2_B,		BIT2_C,		BIT2_D,		BIT2_E,		BIT2_H,		BIT2_L,		BIT2_xHL,	BIT2_A,
	BIT3_B,		BIT3_C,		BIT3_D,		BIT3_E,		BIT3_H,		BIT3_L,		BIT3_xHL,	BIT3_A,
	BIT4_B,		BIT4_C,		BIT4_D,		BIT4_E,		BIT4_H,		BIT4_L,		BIT4_xHL,	BIT4_A,
	BIT5_B,		BIT5_C,		BIT5_D,		BIT5_E,		BIT5_H,		BIT5_L,		BIT5_xHL,	BIT5_A,
	BIT6_B,		BIT6_C,		BIT6_D,		BIT6_E,		BIT6_H,		BIT6_L,		BIT6_xHL,	BIT6_A,
	BIT7_B,		BIT7_C,		BIT7_D,		BIT7_E,		BIT7_H,		BIT7_L,		BIT7_xHL,	BIT7_A,

	RES0_B,		RES0_C,		RES0_D,		RES0_E,		RES0_H,		RES0_L,		RES0_xHL,	RES0_A,
	RES1_B,		RES1_C,		RES1_D,		RES1_E,		RES1_H,		RES1_L,		RES1_xHL,	RES1_A,
	RES2_B,		RES2_C,		RES2_D,		RES2_E,		RES2_H,		RES2_L,		RES2_xHL,	RES2_A,
	RES3_B,		RES3_C,		RES3_D,		RES3_E,		RES3_H,		RES3_L,		RES3_xHL,	RES3_A,
	RES4_B,		RES4_C,		RES4_D,		RES4_E,		RES4_H,		RES4_L,		RES4_xHL,	RES4_A,
	RES5_B,		RES5_C,		RES5_D,		RES5_E,		RES5_H,		RES5_L,		RES5_xHL,	RES5_A,
	RES6_B,		RES6_C,		RES6_D,		RES6_E,		RES6_H,		RES6_L,		RES6_xHL,	RES6_A,
	RES7_B,		RES7_C,		RES7_D,		RES7_E,		RES7_H,		RES7_L,		RES7_xHL,	RES7_A,

	SET0_B,		SET0_C,		SET0_D,		SET0_E,		SET0_H,		SET0_L,		SET0_xHL,	SET0_A,
	SET1_B,		SET1_C,		SET1_D,		SET1_E,		SET1_H,		SET1_L,		SET1_xHL,	SET1_A,
	SET2_B,		SET2_C,		SET2_D,		SET2_E,		SET2_H,		SET2_L,		SET2_xHL,	SET2_A,
	SET3_B,		SET3_C,		SET3_D,		SET3_E,		SET3_H,		SET3_L,		SET3_xHL,	SET3_A,
	SET4_B,		SET4_C,		SET4_D,		SET4_E,		SET4_H,		SET4_L,		SET4_xHL,	SET4_A,
	SET5_B,		SET5_C,		SET5_D,		SET5_E,		SET5_H,		SET5_L,		SET5_xHL,	SET5_A,
	SET6_B,		SET6_C,		SET6_D,		SET6_E,		SET6_H,		SET6_L,		SET6_xHL,	SET6_A,
	SET7_B,		SET7_C,		SET7_D,		SET7_E,		SET7_H,		SET7_L,		SET7_xHL,	SET7_A
};


enum CodesED
{
	ED00,		ED01,		ED02,		ED03,		ED04,		ED05,		ED06,		ED07,
	ED08,		ED09,		ED0A,		ED0B,		ED0C,		ED0D,		ED0E,		ED0F,
	ED10,		ED11,		ED12,		ED13,		ED14,		ED15,		ED16,		ED17,
	ED18,		ED19,		ED1A,		ED1B,		ED1C,		ED1D,		ED1E,		ED1F,
	ED20,		ED21,		ED22,		ED23,		ED24,		ED25,		ED26,		ED27,
	ED28,		ED29,		ED2A,		ED2B,		ED2C,		ED2D,		ED2E,		ED2F,
	ED30,		ED31,		ED32,		ED33,		ED34,		ED35,		ED36,		ED37,
	ED38,		ED39,		ED3A,		ED3B,		ED3C,		ED3D,		ED3E,		ED3F,

	IN_B_xC,	OUT_xC_B,	SBC_HL_BC,	LD_xNN_BC,	NEG,		RETN,		IM_0,		LD_I_A,
	IN_C_xC,	OUT_xC_C,	ADC_HL_BC,	LD_BC_xNN,	ED4C,		RETI,		ED4E,		LD_R_A,
	IN_D_xC,	OUT_xC_D,	SBC_HL_DE,	LD_xNN_DE,	ED54,		ED55,		IM_1,		LD_A_I,
	IN_E_xC,	OUT_xC_E,	ADC_HL_DE,	LD_DE_xNN,	ED5C,		ED5D,		IM_2,		LD_A_R,
	IN_H_xC,	OUT_xC_H,	SBC_HL_HL,	ED_xNN_HL,	ED64,		ED65,		ED66,		RRD,
	IN_L_xC,	OUT_xC_L,	ADC_HL_HL,	ED_HL_xNN,	ED6C,		ED6D,		ED6E,		RLD,
	IN_F_xC,	OUT_xC_0,	SBC_HL_SP,	LD_xNN_SP,	ED74,		ED75,		ED76,		ED77,
	IN_A_xC,	OUT_xC_A,	ADC_HL_SP,	LD_SP_xNN,	ED7C,		ED7D,		ED7E,		ED7F,

	ED80,		ED81,		ED82,		ED83,		ED84,		ED85,		ED86,		ED87,
	ED88,		ED89,		ED8A,		ED8B,		ED8C,		ED8D,		ED8E,		ED8F,
	ED90,		ED91,		ED92,		ED93,		ED94,		ED95,		ED96,		ED97,
	ED98,		ED99,		ED9A,		ED9B,		ED9C,		ED9D,		ED9E,		ED9F,
	LDI,		CPI,		INI,		OUTI,		EDA4,		EDA5,		EDA6,		EDA7,
	LDD,		CPD,		IND,		OUTD,		EDAC,		EDAD,		EDAE,		EDAF,
	LDIR,		CPIR,		INIR,		OTIR,		EDB4,		EDB5,		EDB6,		EDB7,
	LDDR,		CPDR,		INDR,		OTDR,		EDBC,		EDBD,		EDBE,		EDBF,

	EDC0,		EDC1,		EDC2,		EDC3,		EDC4,		EDC5,		EDC6,		EDC7,
	EDC8,		EDC9,		EDCA,		EDCB,		EDCC,		EDCD,		EDCE,		EDCF,
	EDD0,		EDD1,		EDD2,		EDD3,		EDD4,		EDD5,		EDD6,		EDD7,
	EDD8,		EDD9,		EDDA,		EDDB,		EDDC,		EDDD,		EDDE,		EDDF,
	EDE0,		EDE1,		EDE2,		EDE3,		EDE4,		EDE5,		EDE6,		EDE7,
	EDE8,		EDE9,		EDEA,		EDEB,		EDEC,		EDED,		EDEE,		EDEF,
	EDF0,		EDF1,		EDF2,		EDF3,		EDF4,		EDF5,		EDF6,		EDF7,
	EDF8,		EDF9,		EDFA,		EDFB,		EDFC,		EDFD,		EDFE,		EDFF
};






