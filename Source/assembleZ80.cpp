/*	Copyright  (c)	Günter Woigk 1994 - 2020
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
#include "Z80/goodies/z80_opcodes.h"


static cValue N2(2);

static bool lceq (cptr w, cptr s)
{
	// compare word w with string literal s
	// s must be lower case
	// w may be mixed case

	assert(s&&w);
	while (*s) { if ((*w++|0x20) != *s++) return false; }
	return *w==0;
}


void Z80Assembler::storeEDopcode (int n) throws
{
	if (target_z80_or_z180) return store(PFX_ED,n);
	throw SyntaxError(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}

void Z80Assembler::storeIXopcode (int n) throws
{
	if (target_z80_or_z180) return store(PFX_IX,n);
	throw SyntaxError(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}

void Z80Assembler::storeIYopcode (int n) throws
{
	if (target_z80_or_z180) return store(PFX_IY,n);
	throw SyntaxError(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}


enum // enumeration of Z80 identifiers
{
	NIX,	// end of line

	// conditions:
	NZ,		Z,		NC,		CY,		PO,		PE,		P,		M,	// <-- DO NOT REORDER!

	// 8-bit registers:
	RB,		RC,		RD,		RE,		RH,		RL,		XHL,	RA,	// <-- DO NOT REORDER!
	XH,		XL,		YH,		YL,									// <-- DO NOT REORDER!
	RI,		RR,

	// 16-bit registers:
	BC,		DE,		HL,		SP,			// <-- DO NOT REORDER!
	IX,		IY,		AF,					// <-- DO NOT REORDER!

	// others:
	XBC,	XDE,	XC,		XSP,	XIX,	XIY,
	XNN,	NN,
	XMMBC, XMMDE, XMMHL, XBCPP, XDEPP, XHLPP,	// (hl++) etc. for compound opcodes
};

int Z80Assembler::getCondition (SourceLine& q, bool expect_comma) throws
{
	// test and skip over condition
	// returns NIX or enum [Z, NZ .. P]
	// expect_comma
	//   must be set if cond must be followed by a comma --> jr, jp and call
	//   and must be cleared for --> ret

	cptr p = q.p;
	cstr w = q.nextWord();	if (w[0]==0) return NIX;
	if (expect_comma && !q.testComma()) { q.p = p; return NIX; }

	char c1 = *w++ | 0x20;
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen = 1
	{
		if (c1=='z') return Z;
		if (c1=='c') return CY;
		if (c1=='p') return P;
		if (c1=='m') return M;
		if (c1=='s') return M;	// source seen ...
	}
	else if (*w==0)	// strlen = 2
	{
		if (c1=='n') { if (c2=='z') return NZ; if (c2=='c') return NC; }
		if (c1=='p') { if (c2=='o') return PO; if (c2=='e') return PE; }
	}
	throw SyntaxError("illegal condition");
}

int Z80Assembler::getRegister (SourceLine& q, Value& n, bool with_qreg) throws
{
	// test and skip over register or value
	// returns register enum:
	//   normal register:     n and v are void (not modified)
	//   NN, XNN, XIX or XIY: n and v are set
	//   does not return i, r, (c), ix, iy or related if target_8080
	// throws on error
	// throws at end of line

	cptr p = q.p;
	cstr w = q.nextWord();

	char c1 = *w++ | 0x20;	if (c1==0x20) throw SyntaxError("unexpected end of line");
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen=1
	{
		switch (c1)
		{
		case 'a':	return RA;
		case 'b':	return RB;
		case 'c':	return RC;
		case 'd':	return RD;
		case 'e':	return RE;
		case 'h':	return RH;
		case 'l':	return RL;
		case 'i':	if(target_z80_or_z180) return RI; else goto no_8080;
		case 'r':	if(target_z80_or_z180) return RR; else goto no_8080;

		case '(':
			{
				int r;
				if (q.testWord("hl")) { r=XHL; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XHLPP; } q.expect(')'); return r; }
				if (q.testWord("de")) { r=XDE; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XDEPP; } q.expect(')'); return r; }
				if (q.testWord("bc")) { r=XBC; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XBCPP; } q.expect(')'); return r; }
				if (q.testWord("sp")) { q.expect(')'); return XSP; }

				if (*q=='-'&&*(q.p+1)=='-')
				{
					p = q.p;
					q.p += 2;
					if (q.testWord("hl")) { q.expect(')'); return XMMHL; }
					if (q.testWord("de")) { q.expect(')'); return XMMDE; }
					if (q.testWord("bc")) { q.expect(')'); return XMMBC; }
					q.p = p;
				}

				r = XNN; n=0;

				if (q.testWord("ix")) { if (target_8080) goto no_8080; r = XIX; if (q.testChar(')')) return r; }
				if (q.testWord("iy")) { if (target_8080) goto no_8080; r = XIY; if (q.testChar(')')) return r; }
				if (q.testWord("c"))  { if (target_8080) goto no_8080; q.expect(')'); return XC; }

				n = value(q); if (r!=XNN && n.value!=int8(n) && n.is_valid()) throw SyntaxError("offset out of range");
				q.expectClose();
				return r;
			}
		}
	}
	else if (*w==0)	// strlen=2
	{
		switch(c1)
		{
		case 'a': if (c2=='f') return AF; else break;
		case 'b': if (c2=='c') return BC; else break;
		case 'd': if (c2=='e') return DE; else break;
		case 'h': if (c2=='l') return HL; else break;
		case 's': if (c2=='p') return SP; else break;
		case 'i': if (c2=='x') { if (target_z80_or_z180) return IX; else goto no_8080; }
				  if (c2=='y') { if (target_z80_or_z180) return IY; else goto no_8080; } else break;
		case 'x': if (c2=='h') { if (target_z80) return XH; else goto z80_only; }
				  if (c2=='l') { if (target_z80) return XL; else goto z80_only; } else break;
		case 'y': if (c2=='h') { if (target_z80) return YH; else goto z80_only; }
				  if (c2=='l') { if (target_z80) return YL; else goto z80_only; } else break;
		}
	}
	else	// ≥3 letters
	{
		char c3 = *w++ | 0x20;
		char c4 = *w++ | 0x20;

		if (c4==0x20)	// strlen=3
		{
			// target_z80:  test for ixh, ixl, iyh, iyl:					2016-10-01
			// target_8080: no test: ixh, ixl, iyh, iyl are valid label names (not rejected in asmLabel())
			// target_z180: no test: ixh, ixl, iyh, iyl are valid label names (not rejected in asmLabel())
			if (target_z80 && c1=='i')
			{
				int rval = c2=='x' ? c3=='h'?XH:c3=='l'?XL:0 :
						   c2=='y' ? c3=='h'?YH:c3=='l'?YL:0 : 0;
				if (rval) return rval;
			}
		}
		else if (*w==0)	// strlen=4
		{
			if (with_qreg && c2 != c4)	// detect quad_regs, e.g. 'DEHL', but not 2x same reg, e.g. 'HLHL'
			{
				static const char hi[]="bdhsii";
				static const char lo[]="celpxy";
				cptr p2 = strchr(lo,c2);
				cptr p4 = strchr(lo,c4);
				if (p2 && p4 && c1==hi[p2-lo] && c3==hi[p4-lo])
				{
					if (target_8080 && (c1=='i' || c3=='i')) goto no_8080;	// IX, IY
					return 256 * (BC + int(p2-lo)) + BC + int(p4-lo);		// "DEHL" -> DE*256 + HL
				}
			}
		}
	}

	// not a register: evaluate expression:
	q.p = p;
	n = value(q);
	if (target_8080 || !q.testChar('(')) return NN;

	// SDASZ80 syntax: n(IX)
	if (n.value!=int8(n) && n.is_valid()) throw SyntaxError("offset out of range");
	if (q.testWord("ix")) { q.expectClose(); return XIX; }
	if (q.testWord("iy")) { q.expectClose(); return XIY; }
	throw SyntaxError("syntax error");

z80_only:
	if (target_z180) throw SyntaxError("illegal register: the Z180 traps illegal instructions");
no_8080:
	throw SyntaxError("no 8080 register");
}

void Z80Assembler::asmZ80Instr (SourceLine& q, cstr w) throws
{
	// Assemble Z80 opcode

	// remember: *ALWAYS* evaluate _all_ values _before_ storing the first opcode byte: wg. '$'

	int    r,r2;
	Value  n,n2;
	int32  instr;
	cptr   depp = nullptr;				// dest error position ptr: for instructions where
										// source is parsed before dest can be checked
	assert(current_segment_ptr);

	// strlen-Verteiler:

	switch (strlen(w))
	{
	case 0:		return;					// end of line
	case 1:		goto misc;
	case 2:		instr = peek2X(w); break;
	case 3:		instr = int32(peek3X(w)); break;
	case 4:		instr = int32(peek4X(w)); break;
	case 5:		goto wlen5;
	default:	goto misc;
	}

	switch (instr|0x20202020)
	{
	case ' jmp':
	case ' mov':	throw SyntaxError("no Z80 assembler opcode (use option --asm8080)");

	case ' nop':	return store(NOP);
	case '  ei':	return store(EI);
	case '  di':	return store(DI);
	case ' scf':	return store(SCF);
	case ' ccf':	return store(CCF);
	case ' cpl':	return store(CPL);
	case ' daa':	return store(DAA);
	case ' rra':	return store(RRA);
	case ' rla':	return store(RLA);
	case 'rlca':	return store(RLCA);
	case 'rrca':	return store(RRCA);
	case 'halt':	return store(HALT);
	case ' exx':	if (target_8080) goto ill_8080;
					return store(EXX);

	case 'djnz':
		// djnz nn
		if (target_8080) goto ill_8080;
		instr = DJNZ; goto jr;

	case '  jr':
		// jr nn
		// jr cc,nn
		if (target_8080) goto ill_8080;
		r2 = getCondition(q,yes); if (r2>CY) throw SyntaxError("illegal condition");
		instr = r2==NIX ? JR : JR_NZ+(r2-NZ)*8; goto jr;

	jr:	r = getRegister(q,n); if (r!=NN) goto ill_dest;
		store(instr);
		return storeOffset(n - dollar() - N2);

	case '  jp':
		// jp NN
		// jp rr	hl ix iy
		// jp (rr)	hl ix iy
		r2 = getCondition(q,yes);
		r  = getRegister(q,n);
		if (r==NN)				{ store(r2==NIX ? JP : JP_NZ+(r2-NZ)*8); storeWord(n); return; }
		if (r==HL || r==XHL)	{ store(JP_HL); return; }
		// note: getRegister() returns XIX|XIY and n=0 for jp (ix|iy):
		// validity test not required: 'jp (ix+dis) will fail when 'dis' becomes valid.
		if (r==IX || (r==XIX && n.value==0)) { store(PFX_IX,JP_HL); return; }
		if (r==IY || (r==XIY && n.value==0)) { store(PFX_IY,JP_HL); return; }
		goto ill_dest;

	case ' ret':
		// ret
		// ret cc
		r = getCondition(q,no);
		return store(r==NIX ? RET : RET_NZ+(r-NZ)*8);

	case 'call':
		// call nn
		// call cc,nn
		r2 = getCondition(q,yes);
		r  = getRegister(q,n);
		if (r==NN) { store(r2==NIX ? CALL : CALL_NZ+(r2-NZ)*8); storeWord(n); return; }
		goto ill_dest;

	case ' rst':
		// rst n		0 .. 7  or  0*8 .. 7*8
		n = value(q);
		if (n.value%8 == 0) n.value>>=3;
		if (n.is_valid() && n.value>>3) throw SyntaxError( "illegal vector number" );
		else return store(RST00+n.value*8);

	case 'push':	instr = PUSH_HL; goto pop;
	case ' pop':	instr = POP_HL;  goto pop;

		// pop rr		bc de hl af ix iy
pop:
		r = getRegister(q,n);
		if (r>=BC && r<=HL) return store(instr+(r-HL)*16);
		if (r==AF) return store(instr+16);
		if (r==IX) return store(PFX_IX,instr);
		if (r==IY) return store(PFX_IY,instr);
		if (instr==POP_HL) goto ill_target; else goto ill_source;

	case ' dec':	r2 = 1;	goto inc;
	case ' inc':	r2 = 0;	goto inc;

		// inc r	a b c d e h l (hl) (ix+d)
		// inc xh
		// inc rr	bc de hl sp ix iy
inc:
		r = getRegister(q,n);

		instr = INC_xHL + r2;	// inc (hl)  or  dec (hl)
		if (r<=RA)   { store(instr+(r-XHL)*8); return; }
		if (r==XIX)  { store(PFX_IX, instr, n.value); return; }	// note: offset tested by getRegister()
		if (r==XIY)  { store(PFX_IY, instr, n.value); return; }	// ""
		if (r<=XL)   { store(PFX_IX, instr+(r+RH-XH-XHL)*8); return; }
		if (r<=YL)   { store(PFX_IY, instr+(r+RH-YH-XHL)*8); return; }

		if (r==XMMHL)return store(DEC_HL, instr);
		if (r==XHLPP)return store(instr, INC_HL);

		instr = INC_HL + r2*8;	// inc hl or dec hl
		if (r>=BC && r<=SP) return store(instr+(r-HL)*16);
		if (r==IX) return store(PFX_IX, instr);
		if (r==IY) return store(PFX_IY, instr);
		goto ill_target;

	case '  ex':
		// ex af,af'
		// ex hl,de		(or vice versa)
		// ex hl,(sp)
		// ex ix,(sp)	valid illegal. 2006-09-13 kio
		// ex ix,de		does not work: swaps de and hl only. 2006-09-13 kio
		r = getRegister(q,n);
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r==AF) { if (target_8080) goto ill_8080; q.test_char('\'');
					 if (r2==AF)  return store(EX_AF_AF); else goto ill_source; }
		if (r==HL) { if (r2==DE)  return store(EX_DE_HL); if (r2==XSP) return store(EX_HL_xSP); goto ill_source; }
		if (r==DE) { if (r2==HL)  return store(EX_DE_HL); goto ill_source; }
		if (r==IX) { if (r2==XSP) return store(PFX_IX, EX_HL_xSP); goto ill_source; }
		if (r==IY) { if (r2==XSP) return store(PFX_IY, EX_HL_xSP); goto ill_source; }
		if (r==XSP){ if (r2==HL)  return store(EX_HL_xSP); if (r2==IX) return store(PFX_IX, EX_HL_xSP);
					 if (r2==IY)  return store(PFX_IY, EX_HL_xSP); else goto ill_source; }
		goto ill_target;

	case ' add':
		//	add	a,xxx
		//	add hl,rr	bc de hl sp
		//	add ix,rr	bc de ix sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = ADD_B; goto cp_a; }
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r2<BC || (r2>SP && r2!=r)) goto ill_source;
		if (r==HL) { addhl: return store(ADD_HL_BC+(r2-BC)*16); }
		if (r==IX) { if (r2==HL) goto ill_source; if (r2==r) r2=HL; store(PFX_IX); goto addhl; }
		if (r==IY) { if (r2==HL) goto ill_source; if (r2==r) r2=HL; store(PFX_IY); goto addhl; }
		goto ill_target;

	case ' sbc':
		//	sbc	a,xxx
		//	sbc hl,rr	bc de hl sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = SBC_B; goto cp_a; }
		instr = SBC_HL_BC; goto adc;

	case ' adc':
		//	adc	a,xxx
		//	adc hl,rr	bc de hl sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = ADC_B; goto cp_a; }
		instr = ADC_HL_BC; goto adc;

adc:	if (r!=HL) goto ill_target;
		q.expectComma();
		r2 = getRegister(q,n2);
		if (r2>=BC && r2<=SP) return storeEDopcode(instr+(r2-BC)*16);
		goto ill_source;

	case ' and':	instr = AND_B; goto cp;
	case ' xor':	instr = XOR_B; goto cp;
	case ' sub':	instr = SUB_B; goto cp;
	case '  or':	instr = OR_B;  goto cp;
	case '  cp':	instr = CP_B;  goto cp;

		// cp a,N			first argument (the 'a' register) may be omitted
		// cp a,r			a b c d e h l (hl)
		// cp a,xh
		// cp a,(ix+dis)

		// common handler for
		// add adc sub sbc and or xor cp

cp:		r = getRegister(q,n);
cp_a:	depp=q.p; if (q.testComma()) { if (r!=RA) goto ill_target; else r = getRegister(q,n); }

		if (r<=RA)    { store(instr+r-RB); return; }
		if (r==NN)    { store(instr+CP_N-CP_B); storeByte(n); return; }
		if (r==XIX)   { store(PFX_IX, instr+XHL-RB, n.value); return; }
		if (r==XIY)   { store(PFX_IY, instr+XHL-RB, n.value); return; }
		if (r<=XL)    { store(PFX_IX, instr+r+RH-XH-RB); return; }
		if (r<=YL)    { store(PFX_IY, instr+r+RH-YH-RB); return; }
		if (r==XHLPP) { store(instr+XHL-RB, INC_HL); return; }
		if (r==XMMHL) { store(DEC_HL, instr+XHL-RB); return; }
		goto ill_source;

	case '  ld':
		r = getRegister(q,n,yes);		// allow quad reg
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2,r==XNN);	// allow quad reg if dest = '(NN)'
		assert(r>=RB);
		assert(r2>=RB);

		switch(r)
		{
		case RI:
			// ld i,a
			if (r2==RA) return storeEDopcode(LD_I_A);
			goto ill_source;

		case RR:
			// ld r,a
			if (r2==RA) return storeEDopcode(LD_R_A);
			goto ill_source;

		case IX:
			// ld ix,rr		bc de			Goodie
			// ld ix,(NN)
			// ld ix,NN
			instr = PFX_IX;
			goto ld_iy;

		case IY:
			// ld iy,rr		bc de			Goodie
			// ld iy,(NN)
			// ld iy,NN
			instr = PFX_IY;
ld_iy:		if (r2==NN)  { store(instr, LD_HL_NN);  storeWord(n2); return; }
			if (r2==XNN) { store(instr, LD_HL_xNN); storeWord(n2); return; }
			if (r2==BC)  { if (target_z180) goto ill_opcode; return store(instr, LD_H_B, instr, LD_L_C); }
			if (r2==DE)  { if (target_z180) goto ill_opcode; return store(instr, LD_H_D, instr, LD_L_E); }
			goto ill_source;

		case HL:
			// ld hl,rr		bc de			Goodie
			// ld hl,(ix+d)					Goodie
			// ld hl,(NN)
			// ld hl,NN
			if (r2==BC)  { store(LD_H_B, LD_L_C); return; }
			if (r2==DE)  { store(LD_H_D, LD_L_E); return; }
			if (r2==NN)  { store(LD_HL_NN);  storeWord(n2); return; }
			if (r2==XNN) { store(LD_HL_xNN); storeWord(n2); return; }
			if (r2==XIX) { store(PFX_IX, LD_L_xHL, n2.value); store(PFX_IX, LD_H_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			if (r2==XIY) { store(PFX_IY, LD_L_xHL, n2.value); store(PFX_IY, LD_H_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			goto ill_source;

		case BC:
			// ld bc,NN
			// ld bc,(NN)
			// ld bc,rr		de hl ix iy		Goodie
			// ld bc,(hl)					Goodie
			// ld bc,(ix+d)					Goodie
			// ld bc,(hl++)					Goodie
			if (r2==NN)  { store(LD_BC_NN); storeWord(n2); return; }
			if (r2==XNN) { storeEDopcode(LD_BC_xNN); storeWord(n2); return; }
			if (r2==DE)  { store(LD_B_D, LD_C_E); return; }
			if (r2==HL)  { store(LD_B_H, LD_C_L); return; }
			if (r2==IX)  { if (target_z180) goto ill_opcode; store(PFX_IX, LD_B_H, PFX_IX, LD_C_L); return; }
			if (r2==IY)  { if (target_z180) goto ill_opcode; store(PFX_IY, LD_B_H, PFX_IY, LD_C_L); return; }
			if (r2==XHL) { store(LD_C_xHL, INC_HL, LD_B_xHL, DEC_HL); return; }
			if (r2==XIX) { store(PFX_IX, LD_C_xHL, n2.value); store(PFX_IX, LD_B_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			if (r2==XIY) { store(PFX_IY, LD_C_xHL, n2.value); store(PFX_IY, LD_B_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			if (r2==XHLPP) { store(LD_C_xHL, INC_HL, LD_B_xHL, INC_HL); return; }
			if (r2==XMMHL) { store(DEC_HL, LD_B_xHL, DEC_HL, LD_C_xHL); return; }
			goto ill_source;

		case DE:
			// ld de,NN
			// ld de,(NN)
			// ld de,rr		bc hl ix iy		Goodie
			// ld de,(hl)					Goodie
			// ld de,(ix+d)					Goodie
			// ld de,(hl++)					Goodie
			if (r2==NN)    { store(LD_DE_NN); storeWord(n2); return; }
			if (r2==XNN)   { storeEDopcode(LD_DE_xNN); storeWord(n2); return; }
			if (r2==BC)    { store(LD_D_B, LD_E_C); return; }
			if (r2==HL)    { store(LD_D_H, LD_E_L); return; }
			if (r2==IX)    { if (target_z180) goto ill_opcode; store(PFX_IX, LD_D_H, PFX_IX, LD_E_L); return; }
			if (r2==IY)    { if (target_z180) goto ill_opcode; store(PFX_IY, LD_D_H, PFX_IY, LD_E_L); return; }
			if (r2==XHL)   { store(LD_E_xHL, INC_HL, LD_D_xHL, DEC_HL); return; }
			if (r2==XIX)   { store(PFX_IX, LD_E_xHL, n2.value); store(PFX_IX, LD_D_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			if (r2==XIY)   { store(PFX_IY, LD_E_xHL, n2.value); store(PFX_IY, LD_D_xHL, n2.value+1); return; } // ignored: n2+1 may wrap!
			if (r2==XHLPP) { store(LD_E_xHL,INC_HL,LD_D_xHL,INC_HL); return; }
			if (r2==XMMHL) { store(DEC_HL, LD_D_xHL, DEC_HL, LD_E_xHL); return; }
			goto ill_source;

		case SP:
			// ld sp,rr		hl ix iy
			// ld sp,NN
			// ld sp,(NN)
			if (r2==HL)  { store(LD_SP_HL); return; }
			if (r2==IX)  { store(PFX_IX, LD_SP_HL); return; }
			if (r2==IY)  { store(PFX_IY, LD_SP_HL); return; }
			if (r2==NN)  { store(LD_SP_NN); storeWord(n2); return; }
			if (r2==XNN) { storeEDopcode(LD_SP_xNN); storeWord(n2); return; }
			goto ill_source;

		case XIX:
			// ld (ix+d),r		a b c d e h l a
			// ld (ix+d),n
			// ld (ix+d),rr		bc de hl		Goodie
			instr = PFX_IX;
			goto ld_xiy;

		case XIY:
			// ld (iy+d),r		a b c d e h l a
			// ld (iy+d),n
			// ld (iy+d),rr		bc de hl		Goodie
			instr = PFX_IY;
ld_xiy:		if (r2<=RA && r2!=XHL) { store(instr, LD_xHL_B+r2-RB, n.value); return; }
			if (r2==NN) { store(instr, LD_xHL_N, n.value); storeByte(n2); return; }
			if (r2==HL) { store(instr, LD_xHL_L, n.value); store(instr, LD_xHL_H, n.value+1); return; } // ignored: n+1 may wrap!
			if (r2==DE) { store(instr, LD_xHL_E, n.value); store(instr, LD_xHL_D, n.value+1); return; } // ignored: n+1 may wrap!
			if (r2==BC) { store(instr, LD_xHL_C, n.value); store(instr, LD_xHL_B, n.value+1); return; } // ignored: n+1 may wrap!
			goto ill_source;

		case XHL:
			// ld (hl),r		a b c d e h l a
			// ld (hl),n
			// ld (hl),rr		bc de			Goodie
			if (r2<=RA && r2!=XHL) { store(LD_xHL_B+r2-RB); return; }
			if (r2==NN) { store(LD_xHL_N); storeByte(n2); return; }
			if (r2==BC) { store(LD_xHL_C, INC_HL, LD_xHL_B, DEC_HL); return; }
			if (r2==DE) { store(LD_xHL_E, INC_HL, LD_xHL_D, DEC_HL); return; }
			goto ill_source;

		case XNN:
			// ld (NN),a
			// ld (NN),hl	hl ix iy
			// ld (NN),rr	bc de sp
			// ld (NN),rrrr	dehl, ...			Goodie

			for(;;)
			{
				if (int8(r2) == RA) { store(		LD_xNN_A ); } else
				if (int8(r2) == HL) { store(        LD_xNN_HL); } else
				if (int8(r2) == IX) { store(PFX_IX, LD_xNN_HL); } else
				if (int8(r2) == IY) { store(PFX_IY, LD_xNN_HL); } else
				if (int8(r2) == BC) { storeEDopcode(LD_xNN_BC); } else
				if (int8(r2) == DE) { storeEDopcode(LD_xNN_DE); } else
				if (int8(r2) == SP) { storeEDopcode(LD_xNN_SP); } else goto ill_source;
				storeWord(n);
				if (r2 <= 255) return;
				// quad register:		// 1st loop stored low register
				n.value += 2;			// 2nd loop for high word:
				r2 = r2 >> 8;			// increment address and fetch high register id
			}

		case XBC:
			// ld (bc),a
			if (r2==RA) return store(LD_xBC_A);
			goto ill_source;

		case XDE:
			// ld (de),a
			if (r2==RA) return store(LD_xDE_A);
			goto ill_source;

		case XMMBC:
			// ld (--bc),a
			if (r2==RA) return store(DEC_BC, LD_xBC_A);
			goto ill_source;

		case XMMDE:
			// ld (--de),a
			if (r2==RA) return store(DEC_DE, LD_xDE_A);
			goto ill_source;

		case XMMHL:
			// ld (--hl),r
			// ld (--hl),rr
			// ld (--hl),N
			if (r2<=RA && r2!=XHL) { store(DEC_HL, LD_xHL_B + (r2-RB)); return; }
			if (r2==BC) { store(DEC_HL,LD_xHL_B,DEC_HL,LD_xHL_C); return; }
			if (r2==DE) { store(DEC_HL,LD_xHL_D,DEC_HL,LD_xHL_E); return; }
			if (r2==NN) { store(DEC_HL,LD_xHL_N); storeByte(n2); return; }
			goto ill_source;

		case XBCPP:
			// ld (bc++),a
			if (r2==RA) return store(LD_xBC_A, INC_BC);
			goto ill_source;

		case XDEPP:
			// ld (de++),a
			if (r2==RA) return store(LD_xDE_A, INC_DE);
			goto ill_source;

		case XHLPP:
			// ld (hl++),r
			// ld (hl++),rr
			// ld (hl++),N
			if (r2<=RA && r2!=XHL) { store(LD_xHL_B + (r2-RB), INC_HL); return; }
			if (r2==BC) { store(LD_xHL_C,INC_HL,LD_xHL_B,INC_HL); return; }
			if (r2==DE) { store(LD_xHL_E,INC_HL,LD_xHL_D,INC_HL); return; }
			if (r2==NN) { store(LD_xHL_N); storeByte(n2); store(INC_HL); return; }
			goto ill_source;

		case XH:
		case XL:
			// ld xh,r		a b c d e xh xl N
			// ld xl,r		a b c d e xh xl N
			r += RH-XH;
			if (r2<=RE || r2==RA || r2==NN) { store(PFX_IX); goto ld_r; }
			if (r2==XH || r2==XL) { r2 += RH-XH; store(PFX_IX); goto ld_r; }
			goto ill_source;

		case YH:
		case YL:
			// ld yh,r		a b c d e yh yl N
			// ld yl,r		a b c d e yh yl N
			r += RH-YH;
			if (r2<=RE || r2==RA || r2==NN) { store(PFX_IY); goto ld_r; }
			if (r2==YH || r2==YL) { r2 += RH-YH; store(PFX_IY); goto ld_r; }
			goto ill_source;

		case RA:
			// ld a,i
			// ld i,a
			// ld a,(rr)	bc de
			// ld a,(NN)
			if (r2==XBC)   { store(LD_A_xBC); return; }
			if (r2==XDE)   { store(LD_A_xDE); return; }
			if (r2==XNN)   { store(LD_A_xNN); storeWord(n2); return; }
			if (r2==RI)    { storeEDopcode(LD_A_I);	  return; }
			if (r2==RR)    { storeEDopcode(LD_A_R);	  return; }
			if (r2==XBCPP) { store(LD_A_xBC, INC_BC); return; }
			if (r2==XDEPP) { store(LD_A_xDE, INC_DE); return; }
			if (r2==XMMBC) { store(DEC_BC, LD_A_xBC); return; }
			if (r2==XMMDE) { store(DEC_DE, LD_A_xDE); return; }
			goto ld_r;

		case RH:
		case RL:
			if (r2>=XH && r2<=YL) goto ill_source;
			goto ld_r;

		case RB:
		case RC:
		case RD:
		case RE:
			// ld r,r		a b c d e h l (hl)
			// ld r,(ix+d)
			// ld r,N
			// ld r,xh		a b c d e xh xl
			// ld r,yh		a b c d e yh yl
ld_r:		assert(r<=RA && r!=XHL);
			if (r2<=RA)		    { store(LD_B_B + (r-RB)*8 + (r2-RB)); return; }
			if (r2==NN)		    { store(LD_B_N + (r-RB)*8); storeByte(n2); return; }
			if (r2==XIX)	    { store(PFX_IX, LD_B_xHL+(r-RB)*8, n2.value); return; }
			if (r2==XIY)	    { store(PFX_IY, LD_B_xHL+(r-RB)*8, n2.value); return; }
			if (r2==XH||r2==XL) { store(PFX_IX,LD_B_H+(r2-XH)+(r-RB)*8); return; }
			if (r2==YH||r2==YL) { store(PFX_IY,LD_B_H+(r2-YH)+(r-RB)*8); return; }
			if (r2==XHLPP)	    { store(LD_B_xHL + (r-RB)*8, INC_HL); return; }
			if (r2==XMMHL)	    { store(DEC_HL, LD_B_xHL + (r-RB)*8); return; }
			goto ill_source;

		case NN:
			goto ill_dest;

		default:
			if (r >= 256)		// goodie:  ld rrrr,NNNN  or  ld rrrr,(NN)
			{
				if (r2==XNN)
				{
					do
					{
						// loop 1: load lo word
						// loop 2: load hi word
						if (int8(r) == HL) { store(        LD_HL_xNN); } else
						if (int8(r) == BC) { storeEDopcode(LD_BC_xNN); } else
						if (int8(r) == DE) { storeEDopcode(LD_DE_xNN); } else
						if (int8(r) == IX) { storeIXopcode(LD_HL_xNN); } else
						if (int8(r) == IY) { storeIYopcode(LD_HL_xNN); } else
						if (int8(r) == SP) { storeEDopcode(LD_SP_xNN); } else goto ill_dest;
						storeWord(n2);	// store address
						n2.value += 2;	// incr address for high registers
						r = r >> 8;		// move spec for high registers into low byte
					}
					while (r != 0);
					return;
				}
				if (r2==NN)
				{
					do
					{
						// loop 1: load lo word
						// loop 2: load hi word
						if (int8(r) == HL) { store(LD_HL_NN); } else
						if (int8(r) == BC) { store(LD_BC_NN); } else
						if (int8(r) == DE) { store(LD_DE_NN); } else
						if (int8(r) == IX) { storeIXopcode(LD_HL_NN); } else
						if (int8(r) == IY) { storeIYopcode(LD_HL_NN); } else
						if (int8(r) == SP) { store(LD_SP_NN); } else goto ill_dest;
						storeWord(n2 & 0xffff);	// store value
						n2 = n2 >> 16;	// move high part of value into low word
						r = r >> 8;		// move spec for high registers into low byte
					}
					while (r != 0);
					return;
				}
			}
			goto ill_dest;
		}


// ---- 0xED opcodes ----

	case ' neg':	return storeEDopcode(NEG);
	case ' rrd':	return storeEDopcode(RRD);
	case ' rld':	return storeEDopcode(RLD);
	case ' ldi':	return storeEDopcode(LDI);
	case ' cpi':	return storeEDopcode(CPI);
	case ' ini':	return storeEDopcode(INI);
	case ' ldd':	return storeEDopcode(LDD);
	case ' cpd':	return storeEDopcode(CPD);
	case ' ind':	return storeEDopcode(IND);
	case 'outi':	return storeEDopcode(OUTI);
	case 'outd':	return storeEDopcode(OUTD);
	case 'ldir':	return storeEDopcode(LDIR);
	case 'cpir':	return storeEDopcode(CPIR);
	case 'inir':	return storeEDopcode(INIR);
	case 'otir':	return storeEDopcode(OTIR);
	case 'lddr':	return storeEDopcode(LDDR);
	case 'cpdr':	return storeEDopcode(CPDR);
	case 'indr':	return storeEDopcode(INDR);
	case 'otdr':	return storeEDopcode(OTDR);
	case 'reti':	return storeEDopcode(RETI);
	case 'retn':	return storeEDopcode(RETN);

	case '  im':
		// im n		0 1 2
		r = getRegister(q,n);
		if (r==NN && uint(n)<=2) return storeEDopcode( n.value==0 ? IM_0 : n.value==1 ? IM_1 : IM_2);
		throw SyntaxError("illegal interrupt mode");

	case '  in':
		// in a,(N)
		// in a,N		(seen in sources)
		// in r,(c)		a f b c d e h l
		// in r,(bc)	a f b c d e h l
		// in (c)		same as "in f,(c)"

		if (q.testWord("f")) r = XHL;
		else { r = getRegister(q,n); if (r==XHL) goto ill_dest; }
		depp = q.p;

		if ((r==XC || r==XBC) && q.peekChar() != ',') return storeEDopcode(IN_F_xC);

		q.expectComma();
		r2 = getRegister(q,n2);

		if(r2==XC || r2==XBC)
		{
			if (r<=RA) return storeEDopcode(IN_B_xC+(r-RB)*8);
			goto ill_dest;
		}
		if (r2==XNN || r2==NN)
		{
			if (r==RA) { store(INA); storeByte(n2); return; }
			goto ill_dest;
		}
		goto ill_source;

	case ' out':
		// out (c),r	a b c d e h l
		// out (c),0	NMOS
		// out (c),255	CMOS
		// out (bc),r	--> out (c),r
		// out (bc),0	--> out (c),0
		// out (bc),255	--> out (c),255
		// out (n),a	--> outa n
		// out n,a      --> outa n		(seen in sources)

		r = getRegister(q,n);
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r==XC || r==XBC)
		{
			if (r2<=RA && r2!=XHL) return storeEDopcode(OUT_xC_B+(r2-RB)*8);
			if (r2==NN && (n2.value==0||n2.value==255||n2.is_invalid())) return storeEDopcode(OUT_xC_0);
			goto ill_source;
		}
		if (r==XNN || r==NN)
		{
			if (r2!=RA) goto ill_source;
			if ((n.value<-128 || n.value>255) && n.is_valid()) q.p=depp; 	// storeByte() will throw
			store(OUTA); storeByte(n); return;
		}
		goto ill_dest;


// ---- 0xCB opcodes ----

	case ' res':	instr = RES0_B;	goto bit;
	case ' set':	instr = SET0_B;	goto bit;	// note: M80 pseudo instruction SET is handled by asmLabel()
	case ' bit':	instr = BIT0_B;	goto bit;

bit:	n = value(q);
		if (uint(n)>7) throw SyntaxError("illegal bit number");
		instr += 8*n.value;
		q.expectComma();
		goto rr;

	case ' rlc':	instr = RLC_B;	goto rr;
	case ' rrc':	instr = RRC_B;	goto rr;
	case ' sla':	instr = SLA_B;	goto rr;
	case ' sra':	instr = SRA_B;	goto rr;
	case ' sll':	if(target_z180) {goto ill_opcode;}
					instr = SLL_B;	goto rr;
	case ' srl':	instr = SRL_B;	goto rr;
	case '  rl':	instr = RL_B;	goto rr;
	case '  rr':	instr = RR_B;	goto rr;

		// bit n,r			0..7  a b c d e h l (hl)
		// bit n,(ix+d)
		// bit n,xh			ILLEGAL ***NOT ALL Z80 CPUs!***
		// bit n,(ix+d),r	ILLEGAL ***NOT ALL Z80 CPUs!***

		// common handler for:
		// bit, set, res

		// rr r			a b c d e h l (hl)
		// rr xh		xh xl yh yl		// ILLEGAL: ***NOT ALL Z80 CPUs!***
		// rr (ix+n)	ix iy
		// rr (ix+n),r	a b c d e h l	// ILLEGAL: ***NOT ALL Z80 CPUs!***

		// common handler for:
		// rr rrc rl rlc sla sra sll srl

rr:		if (target_8080) goto ill_8080;
		r2 = getRegister(q,n2);

		if (r2<=RA) return store(PFX_CB, instr + r2-RB);

		if (r2<=YL)
		{
			if (!ixcbxh_enabled) throw SyntaxError("illegal instruction (use --ixcbxh)");
			if (r2>=YH) return store(PFX_IY, PFX_CB, 0, instr+r2+RH-YH-RB);
			else	    return store(PFX_IX, PFX_CB, 0, instr+r2+RH-XH-RB);
		}

		if (r2==XIX || r2==XIY)
		{
			r = XHL;
			if (q.testComma())
			{
				if (!ixcbr2_enabled) throw SyntaxError("illegal instruction (use --ixcbr2)");
				r = getRegister(q,n);
				if (r>RA || r==XHL) throw SyntaxError("illegal secondary destination");
			}
			return store(r2==XIX?PFX_IX:PFX_IY, PFX_CB, n2.value, instr+r-RB);
		}

		if (r2==XHLPP) return store(PFX_CB, instr + XHL-RB, INC_HL);
		if (r2==XMMHL) return store(DEC_HL, PFX_CB, instr + XHL-RB);

		if ((instr&0xc0)==BIT0_B) goto ill_source; else goto ill_target;


// ---- Z180 opcodes: ----

	case ' slp':	if (target_z180) return store(PFX_ED,0x76); goto ill_z180;
	case 'otim':	if (target_z180) return store(PFX_ED,0x83); goto ill_z180;
	case 'otdm':	if (target_z180) return store(PFX_ED,0x8b); goto ill_z180;

	case ' in0':
		// in0 r,(n)		a b c d e h l f
		if (!target_z180) goto ill_z180;
		if (q.testWord("f")) r = XHL;
		else { r = getRegister(q,n); if (r>RA||r==XHL) goto ill_dest; }
		q.expectComma();
		r2 = getRegister(q,n2);
		if (r2==XNN) { storeEDopcode(0x00+8*(r-RB)); storeByte(n2); return; }
		goto ill_source;

	case ' tst':
		// tst r		b c d e h l (hl) a
		// tst n
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r==NN) { storeEDopcode(0x64); storeByte(n); return; }
		if (r<=RA) { storeEDopcode(0x04+8*(r-RB)); return; }
		goto ill_source;

	case 'mult':		// <-- TODO: remove?
	case ' mlt':		// Zilog manual: operation name = MULT, mnemonic = MLT
		// mlt rr		bc de hl sp
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r>=BC && r<=SP) return store(PFX_ED,0x4c+16*(r-BC));
		goto ill_source;

	case 'out0':
		// out0 (n),r		b c d e h l a
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n); if (r!=XNN) goto ill_dest;
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);
		if (r2<=RA && r2!=XHL)
		{
			if ((n.value<-128 || n.value>255)&&n.is_valid()) q.p=depp;		// storeByte() will throw
			store(PFX_ED, 0x01+8*(r2-RB)); storeByte(n);
			return;
		}
		goto ill_source;

	default:
		goto misc;
	}

wlen5:
	if ((*w|0x20)=='o')
	{
		if (lceq(w,"otimr"))
		{
			if (target_z180) return store(PFX_ED,0x93);
			goto ill_z180;
		}
		if (lceq(w,"otdmr"))
		{
			if (target_z180) return store(PFX_ED,0x9b);
			goto ill_z180;
		}
		// try macro and pseudo instructions
		goto misc;
	}
	else if ((*w|0x20)=='t' && lceq(w,"tstio"))
	{
		// tstio n
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r==NN) { store(PFX_ED,0x74); storeByte(n); return; }
		goto ill_source;
	}
	else
	{
		// try macro and pseudo instructions
		goto misc;
	}

// generate error
ill_target:		if (depp) q.p=depp; throw SyntaxError("illegal target");		// 1st arg
ill_source:		throw SyntaxError("illegal source");							// 2nd arg
ill_dest:		if (depp) q.p=depp; throw SyntaxError("illegal destination");	// jp etc., ld, in, out: destination
ill_z180:		throw SyntaxError("z180 opcode (use option --z180)");
ill_8080:		throw SyntaxError("no 8080 opcode (option --8080)");
ill_opcode:		throw SyntaxError("illegal opcode (option --z180)");

// try macro and pseudo instructions
misc:	asmPseudoInstr(q,w);
}




















