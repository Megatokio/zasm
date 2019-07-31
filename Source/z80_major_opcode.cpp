/*	Copyright  (c)	Günter Woigk 2014 - 2019
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
*/

#include "kio/kio.h"
#include "z80_major_opcode.h"


namespace Z80	// there are some name colissions with the enum below
{
#include "z80_opcodes.h"
}


// enumeration of identifiers:
//
enum
{
	NIX,

// opcodes:
	NOP,	LD,		INC,	DEC,	RLCA,	EX,		RET,	POP,	JP,
	RRCA,	DJNZ,	RLA,	JR,		RRA,	DAA,	CPL,	HALT,
	SCF,	CCF,	IN,		OUT,	NEG,	RETN,	IM,		RETI,
	RRD,	RLD,	CALL,	PUSH,	RST,	EXX,	DI,		EI,
	ADD,	ADC,	SUB,	SBC,	AND,	XOR,	OR,		CP,		// <-- DO NOT REORDER!
	RLC,	RRC,	RL,		RR,		SLA,	SRA,	SLL,	SRL,	// <-- DO NOT REORDER!
	LDI,	CPI,	INI,	OUTI,	LDD,	CPD,	IND,	OUTD,	// <-- DO NOT REORDER!
	LDIR,	CPIR,	INIR,	OTIR,	LDDR,	CPDR,	INDR,	OTDR,	// <-- DO NOT REORDER!
	BIT,	RES,	SET,											// <-- DO NOT REORDER!

// arguments:
	BC,		DE,		HL,		IX,		IY,		SP,		AF,		PC,
	B,		C,		D,		E,		H,		L,		XHL,	A,		// <-- DO NOT REORDER!
	N0,		N1,		N2,		N3,		N4,		N5,		N6,		N7,		// <-- DO NOT REORDER!
	Z,		NZ,		NC,		PO,		PE,		M,		P,		F,
	XBC,	XDE,	XC,		XSP,	R,		I,		AF2,
	XN,		N,
	XH=H,	XL=L,	YH=H,	YL=L,	XIX=XHL,XIY=XHL,
};


// names and argument spcifiers:
//
static const cstr op_idf[] =
{
#define O(A,B) B
#include "z80_major_opcode_tables.h"
};

static const uint8 op_num[] =
{
#define O(A,B) A
#include "z80_major_opcode_tables.h"
};

static const cstr arg_idf[] =
{
#define A(A,B) B
#include "z80_major_opcode_tables.h"
};

static const uint8 arg_num[] =
{
#define A(A,B) A
#include "z80_major_opcode_tables.h"
};


static const uchar cmd_00[64][3] =
{
	{NOP,0,0},	{LD,BC,N},	{LD,XBC,A},	{INC,BC,0},	{INC,B,0},	{DEC,B,0},	{LD,B,N},	{RLCA,0,0},
	{EX,AF,AF2},{ADD,HL,BC},{LD,A,XBC},	{DEC,BC,0},	{INC,C,0},	{DEC,C,0},	{LD,C,N},	{RRCA,0,0},
	{DJNZ,N,0},	{LD,DE,N},	{LD,XDE,A},	{INC,DE,0},	{INC,D,0},	{DEC,D,0},	{LD,D,N},	{RLA,0,0},
	{JR,N,0},	{ADD,HL,DE},{LD,A,XDE},	{DEC,DE,0},	{INC,E,0},	{DEC,E,0},	{LD,E,N},	{RRA,0,0},
	{JR,NZ,N},	{LD,HL,N},	{LD,XN,HL},	{INC,HL,0},	{INC,H,0},	{DEC,H,0},	{LD,H,N},	{DAA,0,0},
	{JR,Z,N},	{ADD,HL,HL},{LD,HL,XN},	{DEC,HL,0},	{INC,L,0}, 	{DEC,L,0}, 	{LD,L,N},	{CPL,0,0},
	{JR,NC,N},	{LD,SP,N},	{LD,XN,A},	{INC,SP,0},	{INC,XHL,0},{DEC,XHL,0},{LD,XHL,N},	{SCF,0,0},
	{JR,C,N},	{ADD,HL,SP},{LD,A,XN},	{DEC,SP,0},	{INC,A,0},	{DEC,A,0},	{LD,A,N},	{CCF,0,0}
};

static const uchar cmd_C0[64][3] =
{
	{RET,NZ,0},	{POP,BC,0},	{JP,NZ,N},	{JP,N,0},	{CALL,NZ,N},{PUSH,BC,0},{ADD,A,N},	{RST,N0,0},
	{RET,Z,0},	{RET,0,0},	{JP,Z,N},	{NIX,0,0},	{CALL,Z,N},	{CALL,N,0},	{ADC,A,N},	{RST,N1,0},
	{RET,NC,0},	{POP,DE,0},	{JP,NC,N},	{OUT,XN,A},	{CALL,NC,N},{PUSH,DE,0},{SUB,A,N},	{RST,N2,0},
	{RET,C,0},	{EXX,0,0},	{JP,C,N},	{IN,A,XN},	{CALL,C,N},	{NIX,0,0},	{SBC,A,N},	{RST,N3,0},
	{RET,PO,0},	{POP,HL,0},	{JP,PO,N},	{EX,HL,XSP},{CALL,PO,N},{PUSH,HL,0},{AND,A,N},	{RST,N4,0},
	{RET,PE,0},	{JP,HL,0},	{JP,PE,N},	{EX,DE,HL},	{CALL,PE,N},{NIX,0,0},	{XOR,A,N},	{RST,N5,0},
	{RET,P,0},	{POP,AF,0},	{JP,P,N},	{DI,0,0},	{CALL,P,N},	{PUSH,AF,0},{OR,A,N},	{RST,N6,0},
	{RET,M,0},	{LD,SP,HL},	{JP,M,N},	{EI,0,0},	{CALL,M,N},	{NIX,0,0},	{CP,A,N},	{RST,N7,0}
};

static const uchar cmd_ED40[64][3] =
{	{IN,B,XC}, {OUT,XC,B}, {SBC,HL,BC}, {LD,XN,BC}, {NEG,0,0}, {RETN,0,0}, {IM,N0,0}, {LD,I,A},
	{IN,C,XC}, {OUT,XC,C}, {ADC,HL,BC}, {LD,BC,XN}, {NIX,0,0}, {RETI,0,0}, {NIX,0,0}, {LD,R,A},
	{IN,D,XC}, {OUT,XC,D}, {SBC,HL,DE}, {LD,XN,DE}, {NIX,0,0}, {NIX ,0,0}, {IM,N1,0}, {LD,A,I},
	{IN,E,XC}, {OUT,XC,E}, {ADC,HL,DE}, {LD,DE,XN}, {NIX,0,0}, {NIX ,0,0}, {IM,N2,0}, {LD,A,R},
	{IN,H,XC}, {OUT,XC,H}, {SBC,HL,HL}, {LD,XN,HL}, {NIX,0,0}, {NIX ,0,0}, {NIX,0,0}, {RRD,0,0},
	{IN,L,XC}, {OUT,XC,L}, {ADC,HL,HL}, {LD,HL,XN}, {NIX,0,0}, {NIX ,0,0}, {NIX,0,0}, {RLD,0,0},
	{IN,F,XC}, {OUT,XC,N0},{SBC,HL,SP}, {LD,XN,SP}, {NIX,0,0}, {NIX ,0,0}, {NIX,0,0}, {NIX,0,0},
	{IN,A,XC}, {OUT,XC,A}, {ADC,HL,SP}, {LD,SP,XN}, {NIX,0,0}, {NIX ,0,0}, {NIX,0,0}, {NIX,0,0}
};




/*	helper: skip opcode if name matches
*/
static cptr skip_word(cptr q, cstr name)
{
	while(*q && *name) if((*q++|0x20) != *name++) return nullptr;
	return *name==0 && !is_letter(*q) ? q : nullptr;
}



/*	calculate the "major" opcode of the instruction mnemonic in q
	this is
	• byte 1 of simple instructions
	• byte 2 of instructions prefixed with ED, CB, IX or IY
	• byte 4 of instructions with prefix CB+IX or CB+IY
	note:
	• prefix ED instruction "ld hl,(NN)" is never returned,
	  because the non-prefix version is returned instead
*/
uint8 z80_major_opcode(cstr q) noexcept(false) // any_error
{
	uint op   = NIX;
	uint arg1 = NIX;
	uint arg2 = NIX;
	cptr q0;

	// get opcode:
	while(is_space(*q)) q++;
	q0 = q;
	for(op=0; op<NELEM(op_idf); op++)
	{
		q = skip_word(q0,op_idf[op]);
		if(q) break;
	}
	if(q==nullptr) throw any_error("unknown opcode");
	op = op_num[op];

	// get 1st argument:
	while(is_space(*q)) q++;
	if(*q)
	{
		q0 = q;
		for(arg1=0; arg1<NELEM(arg_idf); arg1++)
		{
			q = skip_word(q0,arg_idf[arg1]);
			if(q) break;
		}
		if(q==nullptr) throw any_error("unknown first argument");
		arg1 = arg_num[arg1];
	}

	// get 2nd argument:
	while(is_space(*q)) q++;
	if(*q==',')
	{
		q++;
		while(is_space(*q)) q++;

		q0 = q;
		for(arg2=0; arg2<NELEM(arg_idf); arg2++)
		{
			q = skip_word(q0,arg_idf[arg2]);
			if(q) break;
		}
		if(q==nullptr) throw any_error("unknown second argument");
		arg2 = arg_num[arg2];
	}

	// test for end of opcode specifier:
	while(is_space(*q)) q++;
	if(*q) throw any_error("end of opcode expected");


	// now calculate the major opcode byte of the z80 instruction:
	// this is the opcode byte for opcodes without prefix
	// the 2nd byte after CB, ED, IX and IY instructions
	// or the 4th byte after IXCB or IYCB instructions:


	// 0x40++
	if( op==LD && arg1>=B && arg1<=A && arg2>=B && arg2<=A )
	{
		if(arg1!=XHL || arg2!=XHL) return Z80::LD_B_B + (arg1-B)*8 + (arg2-B);
	}

	// 0x80++
	if( op>=ADD && op<=CP && arg1==A && arg2>=B && arg2<=A )
	{
		return Z80::ADD_B + (op-ADD)*8 + (arg1-B);
	}

	// 0x80++	(alternate form)
	if( op>=ADD && op<=CP && arg1>=B && arg1<=A && arg2==NIX )
	{
		return Z80::ADD_B + (op-ADD)*8 + (arg2-B);
	}

	// 0x00++
	for(uint n = 0; n<0x40; n++)
	{
		const uchar* spec = cmd_00[n];
		if(op  !=spec[0]) continue;
		if(arg1!=spec[1]) continue;
		if(arg2!=spec[2]) continue;
		return n;
	}

	// 0xC0++
	for(uint n = 0; n<0x40; n++)
	{
		const uchar* spec = cmd_C0[n];
		if(op  !=spec[0]) continue;
		if(arg1!=spec[1]) continue;
		if(arg2!=spec[2]) continue;
		return 0xC0 + n;
	}

	// halt (at position of impossible opcode "ld (hl),(hl)"):
	if(op==HALT && arg1==NIX) return Z80::HALT;

	// official mnemo for "jp hl":
	if(op==JP && arg1==XHL && arg2==NIX) return Z80::JP_HL;

	// 0xCB00++
	if(op>=RLC && op<=SRL && arg1>=B && arg1<=A && arg2==NIX)
	{
		return Z80::RLC_B + (op-RLC)*8 + (arg1-B);
	}

	// 0xCB40++
	if(op>=BIT && op<=SET && arg1>=N0 && arg1<=N7 && arg2>=B && arg2<=A)
	{
		return Z80::BIT0_B + (op-BIT)*64 + (arg1-N0)*8 + (arg2-B);
	}

	// 0xED40++
	for(uint n = 0; n<0x40; n++)
	{
		const uchar* spec = cmd_ED40[n];
		if(op  !=spec[0]) continue;
		if(arg1!=spec[1]) continue;
		if(arg2!=spec[2]) continue;
		return 0x40 + n;
	}

	// 0xED80++
	if(op>=LDI && op<=OTDR)
	{
		uint r = op-LDI;		// 0 .. 15
		r = (r&3) + (r&0x0c)*2;
		return Z80::LDI + r;
	}

	// error:
	throw any_error("unsuitable arguments for opcode");
}













