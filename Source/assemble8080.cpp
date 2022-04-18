/*	Copyright  (c)	Günter Woigk 2014 - 2021
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


int Z80Assembler::get8080Register (SourceLine& q) throws
{
	// get 8080 register
	// returns register offset 0…7: b,c,d,e,h,l,m,a
	// target_z80 => n(X) and n(Y) returns PFX_XY<<8 + offset (offset checked)

	q.skip_spaces();
	cstr p0 = q.p;
	cstr w = q.nextWord();
	char c = *w; if (c==0) throw SyntaxError("unexpected end of line");

	if (*++w==0)	// strlen=1
	{
		switch (c|0x20)
		{
		case 'b':	return 0;
		case 'c':	return 1;
		case 'd':	return 2;
		case 'e':	return 3;
		case 'h':	return 4;
		case 'l':	return 5;
		case 'm':	return 6; // XHL
		case 'a':	return 7;
		}
	}

	if (target_z80_or_z180)	// n(X) or n(Y)
	{
		q.p = p0;
		Value n = value(q); if(n.is_valid() && n.value != int8(n.value)) throw SyntaxError("offset out of range");
		q.expect('(');
		w = q.nextWord();
		if ((*w|0x20)=='x') n.value = (PFX_IX<<8) + (n.value & 0xff); else
		if ((*w|0x20)=='y') n.value = (PFX_IY<<8) + (n.value & 0xff); else throw SyntaxError("register X or Y exepcted");
		q.expectClose();
		return n.value;
	}

	throw SyntaxError("register A to L or memory M expected");
}

enum { BD, BDHSP,BDHAF };

int Z80Assembler::get8080WordRegister (SourceLine& q, uint what) throws
{
	// get 8080 word register
	// what -> which register set
	// target_z80 => X and Y returns index register prefix byte

	cstr w = q.nextWord();

	char c1 = *w++ | 0x20;	if (c1==0) throw SyntaxError("unexpected end of line");
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen=1
	{
		if (c1=='b') return 0;				// BC
		if (c1=='d') return 16;				// DE
		if (what>BD)
		{
			if (c1=='h') return 32;			// HL
			if (target_z80_or_z180)
			{
				if (c1=='x') return PFX_IX;	// IX
				if (c1=='y') return PFX_IY;	// IY
			}
		}
	}
	else if (what==BDHSP && c1=='s' && c2=='p' && *w==0) return 48;
	else if (what==BDHAF && c1=='p' && c2=='s' && (*w++|0x20)=='w' && *w==0) return 48;

	throw SyntaxError("word register %s expected", what==0 ? "B or D" : what==1 ? "B, D, H or SP" : "B, D, H or PSW");
}

void Z80Assembler::asm8080Instr (SourceLine& q, cstr w) throws
{
	// assemble z80 or 8080 opcode: 8080 assembler syntax
	// no illegals.

	// remmeber: *ALWAYS* evaluate _all_ values _before_ storing the first opcode byte: wg. '$'

	Value  n;
	int   r,r2;
	int32 instr;

	assert(current_segment_ptr);

	switch (strlen(w))
	{
	default:	goto misc;
	case 0:		return;						// end of line
	case 2:		instr = peek2X(w); break;
	case 3:		instr = int32(peek3X(w)); break;
	case 4:		instr = int32(peek4X(w)); break;
	}

	// opcode len = 2, 3, or 4:

	switch(instr|0x20202020)
	{
	case '  rz': return store(RET_Z);		// 8080: rz => ret z
	case '  rc': return store(RET_C);		// 8080: rc => ret c
	case '  rp': return store(RET_P);		// 8080: rp => ret p
	case '  rm': return store(RET_M);		// 8080: rm => ret m
	case ' ret': return store(RET);			// 8080: ret => ret  ; no cc
	case ' rnz': return store(RET_NZ);		// 8080: rnz => ret nz
	case ' rnc': return store(RET_NC);		// 8080: rnc => ret nc
	case ' rpo': return store(RET_PO);		// 8080: rpo => ret po
	case ' rpe': return store(RET_PE);		// 8080: rpe => ret pe
	case ' stc': return store(SCF);			// 8080: stc => scf
	case ' cmc': return store(CCF);			// 8080: cmc => ccf
	case ' cma': return store(CPL);			// 8080: cma => cpl
	case ' rar': return store(RRA);			// 8080: rar => rra
	case ' ral': return store(RLA);			// 8080: ral => rla
	case ' rlc': return store(RLCA);		// 8080: rlc => rlca
	case ' rrc': return store(RRCA);		// 8080: rrc => rrca
	case ' hlt': return store(HALT);		// 8080: hlt => halt
	case 'pchl': return store(JP_HL);		// 8080: pchl => jp (hl)
	case 'xthl': return store(EX_HL_xSP);	// 8080: xthl => ex (sp),hl
	case 'sphl': return store(LD_SP_HL);	// 8080: sphl => ld sp,hl
	case 'xchg': return store(EX_DE_HL);	// 8080: xchg => ex de,hl
	case ' daa': return store(DAA);			// 8080: same as z80
	case ' nop': return store(NOP);			// 8080: same as z80
	case '  ei': return store(EI);			// 8080: same as z80
	case '  di': return store(DI);			// 8080: same as z80

	case 'call': instr = CALL;		goto iw; 	// 8080: call NN => call NN  ; no cc
	case '  cz': instr = CALL_Z;	goto iw;	// 8080: cz NN => call z,NN
	case '  cc': instr = CALL_C;	goto iw;	// 8080: cc NN => call c,NN
	case '  cp': instr = CALL_P;	goto iw;	// 8080: cp NN => call p,NN
	case '  cm': instr = CALL_M;	goto iw;	// 8080: cm NN => call m,NN
	case ' cnz': instr = CALL_NZ;	goto iw;	// 8080: cnz NN => call nz,NN
	case ' cnc': instr = CALL_NC;	goto iw;	// 8080: cnc NN => call nc,NN
	case ' cpo': instr = CALL_PO;	goto iw;	// 8080: cpo NN => call po,NN
	case ' cpe': instr = CALL_PE;	goto iw;	// 8080: cpe NN => call pe,NN
	case '  jz': instr = JP_Z;		goto iw;	// 8080: jz NN => jp z,NN
	case '  jc': instr = JP_C;		goto iw;	// 8080: jc NN => jp c,NN
	case '  jm': instr = JP_M;		goto iw;	// 8080: jm NN => jp m,NN
	case '  jp': instr = JP_P;		goto iw; 	// 8080: jp NN => jp p,NN
	case ' jnz': instr = JP_NZ;		goto iw;	// 8080: jnz NN => jp nz,NN
	case ' jnc': instr = JP_NC;		goto iw;	// 8080: jnc NN => jp nc,NN
	case ' jpo': instr = JP_PO;		goto iw;	// 8080: jpo NN => jp po,NN
	case ' jpe': instr = JP_PE;		goto iw;	// 8080: jpe NN => jp pe,NN
	case ' jmp': instr = JP;		goto iw;	// 8080: jmp NN => jp NN
	case 'lhld': instr = LD_HL_xNN;	goto iw;	// 8080: lhld NN => ld hl,(NN)
	case ' lda': instr = LD_A_xNN;  goto iw; 	// 8080: lda NN  => ld a,(NN)
	case 'shld': instr = LD_xNN_HL; goto iw;	// 8080: shld NN => ld (NN),hl
	case ' sta': instr = LD_xNN_A;  goto iw;	// 8080: sta NN  => ld (NN),a

iw:		n = value(q);							// before store wg. '$'
		store(instr); storeWord(n);
		return;

	case ' out': instr = OUTA;		goto ib;	// 8080: out N => out (N),a
	case '  in': instr = INA;		goto ib;	// 8080: in  N => in a,(N)
	case ' aci': instr = ADC_N;		goto ib;	// 8080: aci N => adc a,N
	case ' adi': instr = ADD_N;		goto ib;	// 8080: adi N => add a,N
	case ' sui': instr = SUB_N;		goto ib;	// 8080: sui N => sub a,N
	case ' sbi': instr = SBC_N;		goto ib;	// 8080: sbi N => sbc a,N
	case ' ani': instr = AND_N;		goto ib;	// 8080: ani N => and a,N
	case ' ori': instr = OR_N;		goto ib;	// 8080: ori N => or a,N
	case ' xri': instr = XOR_N;		goto ib;	// 8080: xri N => xor a,N
	case ' cpi': instr = CP_N;		goto ib; 	// 8080: cpi N => cp a,N

ib:		n = value(q);							// before store wg. '$'
		store(instr);
		return storeByte(n);

	case ' add': instr = ADD_B;		goto cmp; 	// 8080: add r => add a,r		b c d e h l m a
	case ' adc': instr = ADC_B;		goto cmp; 	// 8080: adc r => adc a,r		b c d e h l m a
	case ' sub': instr = SUB_B;		goto cmp; 	// 8080: sub r => sub a,r
	case ' sbb': instr = SBC_B;		goto cmp;	// 8080: sbb r => sbc a,r		b c d e h l m a
	case ' ana': instr = AND_B;		goto cmp;	// 8080: ana r => and a,r		b c d e h l m a
	case ' ora': instr = OR_B;		goto cmp;	// 8080: ora r => or  a,r		b c d e h l m a
	case ' xra': instr = XOR_B;		goto cmp;	// 8080: xra r => xor a,r		b c d e h l m a
	case ' cmp': instr = CP_B;		goto cmp;	// 8080: cmp r => cp  a,r		b c d e h l m a

cmp:	r = get8080Register(q);
		if (r<8) return store(instr + r);		// cmp r
		else return store(r>>8, instr + 6, r);	// cmp d(x)		Z80

	case ' inr': instr = INC_B;		goto dcr;	// 8080: inr r => inc r			b c d e h l m a
	case ' dcr': instr = DEC_B;		goto dcr;	// 8080: dcr r => dec r			b c d e h l m a

dcr:	r = get8080Register(q);
		if (r<8) return store(instr + r*8);		// dcr r
		return store(r>>8, instr + 6*8, r);		// dcr d(x)		Z80

	case ' mvi':								// 8080: mvi r,N => ld r,N		b c d e h l m a

		r = get8080Register(q);
		q.expectComma();
		n = value(q);
		if (r<8) store(LD_B_N + r*8);			// mvi r,N
		else store(r>>8, LD_xHL_N, r);			// mvi d(x),N		Z80
		return storeByte(n);

	case ' mov':								// 8080: mov r,r => ld r,r		b c d e h l m a

		r  = get8080Register(q);
		q.expectComma();
		r2 = get8080Register(q);

		if (r<8)		// mov r,…
		{
			if (r2<8)	// mov r,r
			{
				instr = LD_B_B + r*8 + r2;
				if (instr!=HALT) return store(instr);
			}
			else	// mov r,d(x)		Z80
			{
				instr = LD_B_xHL + r*8;
				if (instr!=HALT) return store(r2>>8, instr, r2);	// PFX, LD_R_xHL, OFFS
			}
		}
		else		// mov d(x),r		Z80
		{
			if (r2<8 && r2!=6) return store(r>>8, LD_xHL_B+r2, r);	// PFX, LD_xHL_R, OFFS
		}
		// ld (hl),(hl)
		// ld (hl),(ix+d)
		// ld (ix+d),(hl)
		// ld (ix+d),(ix+d)
		// ld (ix+d),(iy+d)
		goto ill_source;


ill_source:	throw SyntaxError("illegal source");
ill_8080:	throw SyntaxError("no 8080 opcode (use option --asm8080 and --z80)");


	case 'ldax':	instr = LD_A_xBC;	goto stax;		// 8080: ldax r => ld a,(rr)	b=bc d=de
	case 'stax':	instr = LD_xBC_A;	goto stax;		// 8080: stax r => ld (rr),a	b=bc d=de

stax:	r = get8080WordRegister(q,BD);
		return store(instr + r);

	case ' dcx':	instr = DEC_BC;		goto inx;		// 8080: dcx r => dec rr		b, d, h, sp
	case ' inx':	instr = INC_BC;		goto inx;		// 8080: inx r => inc rr		b, d, h, sp

inx:	r = get8080WordRegister(q,BDHSP);
		if (r<64) return store(instr + r);				// inc rr
		else	  return store(r,instr+32);				// inc ix		Z80

	case 'push':	instr = PUSH_BC;	goto pop;		// push r => push rr			b d h psw
	case ' pop':	instr = POP_BC;		goto pop;		// pop  r => pop  rr			b d h psw

pop:	r = get8080WordRegister(q, BDHAF);
		if (r<64) return store(instr + r);				// pop r
		else	  return store(r,instr+32);				// pop x		Z80

	case ' lxi':										// 8080: lxi r,NN => ld rr,NN		b, d, h, sp

		r = get8080WordRegister(q,BDHSP);
		q.expectComma();
		n = value(q);

		if (r<64) { store(LD_BC_NN + r); storeWord(n); return; }	// lxi r,NN
		else      { store(r, LD_HL_NN);  storeWord(n); return; }	// lxi x,NN		Z80

	case ' dad':										// 8080: dad r => add hl,rr			b, d, h, sp

		r = get8080WordRegister(q,BDHSP);
		if (r<64) return store(ADD_HL_BC + r);			// add hl,rr
		else	  goto ill_source;						// add hl,ix

	case ' rst':										// rst n		0 .. 7  or  0*8 .. 7*8
		n = value(q);
		if (n.value%8 == 0) n.value>>=3;
		if (n.is_valid() && n.value>>3) throw SyntaxError( "illegal vector number" );
		else return store(RST00+n.value*8);

// ---- Z80 opcodes ----

/*	syntax used by CDL's Z80 Macro Assembler (as far as seen in code)
	which seems to be similar to CROSS macro assembler

	Most mnemonics are taken from the CROSS manual except the following:
	I doubt these were ever used…

	RLCR r		CROSS-Doc: RLC: already used for RLCA, also deviation from naming methodology
	RRCR r		CROSS-Doc: RRC: already used for RRCA, also deviation from naming methodology
	OTDR		CROSS-Doc: OUTDR: 5 letter word
	OTIR		CROSS-Doc: OUTIR: 5 letter word
	DADX rr		CROSS-Doc: definition missing	ADD IX,rr
	DADY rr		CROSS-Doc: definition missing	ADD IY,rr
	PCIX		CROSS-Doc: definition missing	JP IX
	PCIY		CROSS-Doc: definition missing	JP IY
	INC  r		CROSS-Doc: definition missing	IN r,(c)
	OUTC r		CROSS-Doc: definition missing	OUT (c),r
	STAR		CROSS-Doc: definition missing	LD R,A
	LDAI		CROSS-Doc: definition missing	LD A,I
	LDAR		CROSS-Doc: definition missing	LD A,R
*/

	case 'djnz':	instr = DJNZ;  goto jr;
	case ' jrz':	instr = JR_Z;  goto jr;
	case 'jrnz':	instr = JR_NZ; goto jr;
	case ' jrc':	instr = JR_C;  goto jr;
	case 'jrnc':	instr = JR_NC; goto jr;
	case 'jmpr':	instr = JR;    goto jr;

jr:		if (target_8080) goto ill_8080;
		n = value(q);
		store(instr);
		return storeOffset(n - dollar() - Value(2));

	case ' exx':	if (target_8080) goto ill_8080; return store(EXX);
	case 'exaf':	if (target_8080) goto ill_8080; return store(EX_AF_AF);

	case 'xtix':	return storeIXopcode(EX_HL_xSP);
	case 'xtiy':	return storeIYopcode(EX_HL_xSP);
	case 'pcix':	return storeIXopcode(JP_HL);		// kio added
	case 'pciy':	return storeIYopcode(JP_HL);		// kio added

	case ' ccd':	return storeEDopcode(CPD);
	case 'ccdr':	return storeEDopcode(CPDR);
	case ' cci':	return storeEDopcode(CPI);
	case 'ccir':	return storeEDopcode(CPIR);

	case ' ldi':	return storeEDopcode(LDI);
	case 'ldir':	return storeEDopcode(LDIR);
	case ' ldd':	return storeEDopcode(LDD);
	case 'lddr':	return storeEDopcode(LDDR);

	case ' ind':	return storeEDopcode(IND);
	case 'indr':	return storeEDopcode(INDR);
	case ' ini':	return storeEDopcode(INI);
	case 'inir':	return storeEDopcode(INIR);

	case 'outd':	return storeEDopcode(OUTD);
	case 'outi':	return storeEDopcode(OUTI);
	case 'otdr':	return storeEDopcode(OTDR);			// org. CROSS: 'OUTDR' which is a 5 letter word
	case 'otir':	return storeEDopcode(OTIR);			// org. CROSS: 'OUTIR' which is a 5 letter word

	case 'stai':	return storeEDopcode(LD_I_A);
	case 'star':	return storeEDopcode(LD_R_A);		// kio added
	case 'ldai':	return storeEDopcode(LD_A_I);		// kio added
	case 'ldar':	return storeEDopcode(LD_A_R);		// kio added

	case ' im0':	return storeEDopcode(IM_0);
	case ' im1':	return storeEDopcode(IM_1);
	case ' im2':	return storeEDopcode(IM_2);
	case 'retn':	return storeEDopcode(RETN);
	case 'reti':	return storeEDopcode(RETI);
	case ' rld':	return storeEDopcode(RLD);
	case ' rrd':	return storeEDopcode(RRD);
	case ' neg':	return storeEDopcode(NEG);

	case 'spix':	return storeIXopcode(LD_SP_HL);		// 8080: sphl => ld sp,hl
	case 'spiy':	return storeIYopcode(LD_SP_HL);		// 8080: sphl => ld sp,hl

	case 'sbcd':	instr = LD_xNN_BC; goto lspd;		// named acc. to SHLD  X-]
	case 'sded':	instr = LD_xNN_DE; goto lspd;
	case 'sspd':	instr = LD_xNN_SP; goto lspd;
	case 'lbcd':	instr = LD_BC_xNN; goto lspd;		// named after LHLD  X-]
	case 'lded':	instr = LD_DE_xNN; goto lspd;
	case 'lspd':	instr = LD_SP_xNN; goto lspd;

lspd:	n = value(q);
		storeEDopcode(instr);
		return storeWord(n);

	case ' inp':										//				kio added to match OUTP
	case ' inc':	instr = IN_B_xC;  goto outc;		// in r,(c)		kio added
	case 'outp':										//				kio added seen in M80 (?)
	case 'outc':	instr = OUT_xC_B; goto outc;		// out (c),r	kio added

outc:	r = get8080Register(q);
		if (r<8 && r!=6) return storeEDopcode(instr+r*8);
		throw SyntaxError("register A to L expected");

	case 'sixd':	instr = LD_xNN_HL; goto lixd;
	case 'lixd':	instr = LD_HL_xNN; goto lixd;

lixd:	n = value(q);
		storeIXopcode(instr);
		return storeWord(n);

	case 'siyd':	instr = LD_xNN_HL; goto liyd;
	case 'liyd':	instr = LD_HL_xNN; goto liyd;

liyd:	n = value(q);
		storeIXopcode(instr);
		return storeWord(n);

	case 'dadc':	instr = ADC_HL_BC; goto dsbc;
	case 'dsbc':	instr = SBC_HL_BC; goto dsbc;

dsbc:	r = get8080WordRegister(q,BDHSP);
		if (r<64) return storeEDopcode(instr+r);
		throw SyntaxError("illegal register");		// X or Y

	case 'dadx':	// DADX: add ix,bc,de,ix,sp		kio added; note: DAD = add hl,rr

		r = get8080WordRegister(q,BDHSP);
		if (r<64 && r!=32) return storeIXopcode(ADD_HL_BC+r);
		if (r==PFX_IX)	   return storeIXopcode(ADD_HL_HL);
		goto ill_source;							// add ix,hl or add ix,iy

	case 'dady':	// DADY: add iy,bc,de,iy,sp		kio added; note: DAD = add hl,rr

		r = get8080WordRegister(q,BDHSP);
		if (r<64 && r!=32) return storeIYopcode(ADD_HL_BC+r);
		if (r==PFX_IY)	   return storeIYopcode(ADD_HL_HL);
		goto ill_source;							// add iy,hl or add iy,ix

	case ' res':	instr = RES0_B;		goto bit;	// RES b,r
	case ' set':	instr = SET0_B;		goto bit;	// SET b,r
	case ' bit':	instr = BIT0_B;		goto bit;	// BIT b,r

	// BIT b,r		  BIT b,%r
	// BIT b,(IX+d)   BIT b,d(X)
	// BIT b,(IY+d)   BIT b,d(Y)

bit:	if (target_8080) goto ill_8080;
		n = value(q);
		if (uint(n)>7) throw SyntaxError("illegal bit number");
		instr += 8*n.value;
		q.expectComma();
		goto rlcr;

	case 'slar':	instr = SLA_B;		goto rlcr;	// SLA r
	case 'srlr':	instr = SRL_B;		goto rlcr;	// SRL r
	case 'srar':	instr = SRA_B;		goto rlcr;	// SRA r
	case 'ralr':	instr = RL_B;		goto rlcr;	// RL  r
	case 'rarr':	instr = RR_B;		goto rlcr;	// RR  r
	case 'rrcr':	instr = RRC_B;		goto rlcr;	// RRC r		CROSS doc: RRC
	case 'rlcr':	instr = RLC_B;		goto rlcr;	// RLC r		CROSS doc: RLC

rlcr:	if (target_8080) goto ill_8080;
		r = get8080Register(q);
		if (r<8) return store(PFX_CB, instr + r);
		else     return store(r>>8, PFX_CB, r, instr+6);	// PFX_IX, PFX_CB, OFFS, RLC_xHL

	default:	goto misc;
	}

// try macro expansion and pseudo instructions:
misc:	return asmPseudoInstr(q,w);
}


