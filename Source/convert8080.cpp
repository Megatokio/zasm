/*	Copyright  (c)	Günter Woigk 2020 - 2021
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



static inline void skip_space (cptr& p) noexcept
{
	while (*p && *p <= ' ') p++;
}

static inline void skip_idf (cptr& p, bool dot) noexcept
{
	// skip identifiers (names) and numbers
	// allow '$'
	// allow names starting with '.' if dot=true

	skip_space(p);
	if (*p=='$') { p++; return; }
	if (*p=='.' && dot) p++;
	while(is_idf(*p)) p++;
}

static inline bool skip_char (cptr& p, char c) noexcept
{
	// test for and skip char c

	skip_space(p);
	bool r = *p == c;
	p += r;
	return r;
}

static inline bool skip_oper (cptr& p, cstr ops="~!+-*/\\&^|%=><") noexcept
{
	// test for and skip operator
	// allowed operators can be passed in as optional argument 'ops'
	// only 1-char operators supported here.

	skip_space(p);
	bool r = *p && strchr(ops,*p);
	p += r;
	return r;
}

static inline void skip_arg(cptr& p, bool dot) noexcept
{
	// skip numeric argument
	// allow label names starting with '.' if dot=true

	skip_oper(p,"+-!~");
	skip_idf(p,dot);

	cptr e=p;
	while(skip_oper(p))
	{
		while(skip_oper(p)){} // skip 2-char operators and monadic operators before next idf
		skip_idf(p,dot);
		e=p;
	}
	p=e; // back to last identifier end before skip_space
}

static inline cstr skip_r (cptr& p) noexcept
{
	// test for and skip byte register name and return z80 register name

	static const char r8080[] = "bcdehlma";
	static const cstr rz80[] = {"b","c","d","e","h","l","(hl)","a"};

	skip_space(p);

	cptr r = strchr(r8080, *p|0x20);
	if (r!=nullptr && !is_idf(*(p+1)))
	{
		p++;
		return rz80[r-r8080];
	}

	return nullptr;
}

static inline cstr skip_rr(cptr& p) noexcept
{
	// test for and skip word register name and return z80 register name

	static const char r8080[] = "bdh";
	static const cstr rz80[] = {"bc","de","hl"};

	skip_space(p);

	cptr rr = strchr(r8080, *p|0x20);
	if (rr!=nullptr && !is_idf(*(p+1)))
	{
		p++;
		return rz80[rr-r8080];
	}

	if ((p[0]|0x20)=='s' && (p[1]|0x20)=='p' && !is_idf(p[2]))
	{
		p += 2;
		return "sp";
	}

	if ((p[0]|0x20)=='p' && (p[1]|0x20)=='s' && (p[2]|0x20)=='w' && !is_idf(p[3]))
	{
		p += 3;
		return "af";
	}

	return nullptr;
}

void Z80Assembler::convert8080toZ80(cstr source, cstr dest)
{
	// convert 8080 assembler file to z80 assembler file
	// the conversion is not bullet-proof but "garbage in garbage out"
	// converts only the original 8080 mnemonics (no z80 extensions)

	TempMemPool z;
	Array<cstr> zsource;

	// read source:

	FD fdq(source,'r');
	fdq.read_file(zsource,10000000);
	fdq.close_file();

	if (zsource.count())
	{
		// remove BOM:

		static const char bom[] = {char(0xef),char(0xbb),char(0xbf),0};
		if (startswith(zsource[0],bom)) zsource[0] = zsource[0]+3;

		// modify shebang:

		if (startswith(zsource[0],"#!"))
		{
			Array<cstr> z1; split(z1,zsource[0],' ');
			z1.removeitem("--asm8080");
			z1.removeitem("--convert8080");
			z1.insertat(1,"--8080 --casefold");
			zsource[0] = join(z1,' ');
		}
	}

	// convert source:

	for (uint si=0; si<zsource.count(); si++)
	{
		cstr q = zsource[si];
		char z[500] = "";
		cptr qp = q;
		ptr  zp = z;

		// skip label:

		if (require_colon)
		{
			skip_idf(qp,allow_dotnames);
			if (skip_char(qp,':')) {}	// label definition
			else qp = q;				// no label => undo progress
		}
		else if (*qp > ' ')
		{
			skip_idf(qp,allow_dotnames);
			if (qp != q) { skip_char(qp,':'); }	// label definition
			else qp = q;						// no label => undo progress
		}

		skip_space(qp);
		memcpy(zp,q,size_t(qp-q)); zp += qp-q; q=qp;

		// convert instruction:

		cstr op = nullptr;
		uint32 instr = 0;
		cstr r,np,n;

		skip_idf(qp=q,true);
		switch(qp-q)
		{
		default:	break;
		case 2:		instr = peek2X(q); break;
		case 3:		instr = peek3X(q); break;
		case 4:		instr = peek4X(q); break;
		}

		switch(instr|0x20202020)
		{
		default:	break;		// not an 8080 opcode -> copy verbatim

		case '  rz': op = "ret z";		goto o;	// 8080: rz => ret z
		case '  rc': op = "ret c";		goto o;	// 8080: rc => ret c
		case '  rp': op = "ret p";		goto o;	// 8080: rp => ret p
		case '  rm': op = "ret m";		goto o;	// 8080: rm => ret m
		case ' ret': op = "ret";		goto o;	// 8080: ret => ret  ; no cc
		case ' rnz': op = "ret nz";		goto o;	// 8080: rnz => ret nz
		case ' rnc': op = "ret nc";		goto o;	// 8080: rnc => ret nc
		case ' rpo': op = "ret po";		goto o;	// 8080: rpo => ret po
		case ' rpe': op = "ret pe";		goto o;	// 8080: rpe => ret pe
		case ' stc': op = "scf";		goto o;	// 8080: stc => scf
		case ' cmc': op = "ccf";		goto o;	// 8080: cmc => ccf
		case ' cma': op = "cpl";		goto o;	// 8080: cma => cpl
		case ' rar': op = "rra";		goto o;	// 8080: rar => rra
		case ' ral': op = "rla";		goto o;	// 8080: ral => rla
		case ' rlc': op = "rlca";		goto o;	// 8080: rlc => rlca
		case ' rrc': op = "rrca";		goto o;	// 8080: rrc => rrca
		case ' hlt': op = "halt";		goto o;	// 8080: hlt => halt
		case 'pchl': op = "jp (hl)";	goto o;	// 8080: pchl => jp (hl)
		case 'xthl': op = "ex hl,(sp)"; goto o;	// 8080: xthl => ex (sp),hl
		case 'sphl': op = "ld sp,hl";	goto o;	// 8080: sphl => ld sp,hl
		case 'xchg': op = "ex de,hl";	goto o;	// 8080: xchg => ex de,hl
		case ' daa': op = "daa";		goto o;	// 8080: same as z80
		case ' nop': op = "nop";		goto o;	// 8080: same as z80
		case '  ei': op = "ei";			goto o;	// 8080: same as z80
		case '  di': op = "di";			goto o;	// 8080: same as z80

		case 'call': op = "call N";		goto n;	// 8080: call NN => call NN  ; no cc
		case '  cz': op = "call z,N";	goto n;	// 8080: cz NN => call z,NN
		case '  cc': op = "call c,N";	goto n;	// 8080: cc NN => call c,NN
		case '  cp': op = "call p,N";	goto n;	// 8080: cp NN => call p,NN
		case '  cm': op = "call m,N";	goto n;	// 8080: cm NN => call m,NN
		case ' cnz': op = "call nz,N";	goto n;	// 8080: cnz NN => call nz,NN
		case ' cnc': op = "call nc,N";	goto n;	// 8080: cnc NN => call nc,NN
		case ' cpo': op = "call po,N";	goto n;	// 8080: cpo NN => call po,NN
		case ' cpe': op = "call pe,N";	goto n;	// 8080: cpe NN => call pe,NN
		case '  jz': op = "jp z,N";		goto n;	// 8080: jz NN => jp z,NN
		case '  jc': op = "jp c,N";		goto n;	// 8080: jc NN => jp c,NN
		case '  jm': op = "jp m,N";		goto n;	// 8080: jm NN => jp m,NN
		case '  jp': op = "jp p,N";		goto n;	// 8080: jp NN => jp p,NN
		case ' jnz': op = "jp nz,N";	goto n;	// 8080: jnz NN => jp nz,NN
		case ' jnc': op = "jp nc,N";	goto n;	// 8080: jnc NN => jp nc,NN
		case ' jpo': op = "jp po,N";	goto n;	// 8080: jpo NN => jp po,NN
		case ' jpe': op = "jp pe,N";	goto n;	// 8080: jpe NN => jp pe,NN
		case ' jmp': op =" jp N";		goto n;	// 8080: jmp NN => jp NN
		case 'lhld': op = "ld hl,(N)";	goto n;	// 8080: lhld NN => ld hl,(NN)
		case ' lda': op = "ld a,(N)";	goto n;	// 8080: lda NN  => ld a,(NN)
		case 'shld': op = "ld (N),hl";	goto n;	// 8080: shld NN => ld (NN),hl
		case ' sta': op = "ld (N),a";	goto n;	// 8080: sta NN  => ld (NN),a
		case ' out': op = "out (N),a";	goto n;	// 8080: out N => out (N),a
		case '  in': op = "in a,(N)";	goto n;	// 8080: in  N => in a,(N)
		case ' aci': op = "adc a,N";	goto n;	// 8080: aci N => adc a,N
		case ' adi': op = "add a,N";	goto n;	// 8080: adi N => add a,N
		case ' sui': op = "sub a,N";	goto n;	// 8080: sui N => sub a,N
		case ' sbi': op = "sbc a,N";	goto n;	// 8080: sbi N => sbc a,N
		case ' ani': op = "and a,N";	goto n;	// 8080: ani N => and a,N
		case ' ori': op = "or a,N";		goto n;	// 8080: ori N => or a,N
		case ' xri': op = "xor a,N";	goto n;	// 8080: xri N => xor a,N
		case ' cpi': op = "cp a,N";		goto n;	// 8080: cpi N => cp a,N
		case ' rst': op = "rst N";		goto n;	// 8080: rst n

		case ' add': op = "add a,R";	goto r;	// 8080: add r => add a,r		b c d e h l m a
		case ' adc': op = "adc a,R";	goto r;	// 8080: adc r => adc a,r		b c d e h l m a
		case ' sub': op = "sub a,R";	goto r;	// 8080: sub r => sub a,r		b c d e h l m a
		case ' sbb': op = "sbc a,R";	goto r;	// 8080: sbb r => sbc a,r		b c d e h l m a
		case ' ana': op = "and a,R";	goto r;	// 8080: ana r => and a,r		b c d e h l m a
		case ' ora': op = "or a,R";		goto r;	// 8080: ora r => or  a,r		b c d e h l m a
		case ' xra': op = "xor a,R";	goto r;	// 8080: xra r => xor a,r		b c d e h l m a
		case ' cmp': op = "cp a,R";		goto r;	// 8080: cmp r => cp  a,r		b c d e h l m a
		case ' inr': op = "inc R";		goto r;	// 8080: inr r => inc r			b c d e h l m a
		case ' dcr': op = "dec R";		goto r;	// 8080: dcr r => dec r			b c d e h l m a

		case 'ldax': op = "ld a,(R)";	goto d; // 8080: ldax r => ld a,(rr)	b=bc d=de
		case 'stax': op = "ld (R),a";	goto d; // 8080: stax r => ld (rr),a	b=bc d=de
		case ' dcx': op = "dec R";		goto d; // 8080: dcx r => dec rr		b, d, h, sp
		case ' inx': op = "inc R";		goto d; // 8080: inx r => inc rr		b, d, h, sp
		case ' dad': op = "add hl,R";	goto d; // 8080: dad r => add hl,rr		b, d, h, sp
		case 'push': op = "push R";		goto d; // 8080: push r => push rr		b d h psw
		case ' pop': op = "pop R";		goto d; // 8080: pop r => pop  rr		b d h psw

		o:	// no arg
			strcpy(zp,op); zp += strlen(op); q = qp;
			break;

		n:  // N or NN arg
			skip_space(qp); q=qp;
			skip_arg(qp,allow_dotnames);

			np = strchr(op,'N'); assert(np);
			memcpy(zp,op,size_t(np-op)); zp += np-op; 			// 1st part of op
			if (*q=='(') *zp++ = '+';							// arg must not look like "(arg)"
			memcpy(zp,q,size_t(qp-q));   zp += qp-q;  q = qp;	// arg
			strcpy(zp,np+1);             zp += strlen(np+1);	// 2nd part of op
			break;

		d:	r = skip_rr(qp); goto x;	// RR arg
		r:	r = skip_r(qp);	 goto x;	// R arg

		x:	if (r==nullptr) break;		// expect register
			else q = qp;
			np = strchr(op,'R'); assert(np);
			memcpy(zp,op,size_t(np-op)); zp += np-op;			// 1st part of op
			strcpy(zp,r);				 zp += strlen(r);		// register
			strcpy(zp,np+1);             zp += strlen(np+1);	// 2nd part of op
			break;

		case ' mov':					// 8080: mov r,r => ld r,r		b c d e h l m a
			r = skip_r(qp);
			if (r==nullptr) break;

			if (!skip_char(qp,',')) break;

			n = skip_r(qp);
			if (n==nullptr) break;

			strcpy(zp,"ld "); zp += 3;
			strcpy(zp,r);	  zp += strlen(r);
			*zp++=',';
			strcpy(zp,n);	  zp += strlen(n);
			q = qp;
			break;

		case ' lxi': r = skip_rr(qp); goto y;	// 8080: lxi r,NN => ld rr,NN	b, d, h, sp
		case ' mvi': r = skip_r(qp);  goto y;	// 8080: mvi r,N => ld r,N		b c d e h l m a

		y:	if (r==nullptr) break;
			if (!skip_char(qp,',')) break;
			skip_space(qp);

			strcpy(zp,"ld "); zp+=3;			// opcode
			strcpy(zp,r); zp+=strlen(r);		// register
			*zp++=',';							// comma
			if (*qp=='(') *zp++ = '+';			// arg must not look like "(arg)"
			q = qp;								// arg will be appended verbatim
			break;
		}

		// append remainder of line and store back in array:

		*zp = 0;
		zsource[si] = catstr(z,q);
	}

	// write source:

	FD fdz(dest,'w');
	fdz.write_file(zsource);
}


