/*	Copyright  (c)	Günter Woigk 2020 - 2020
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
#include "Z80Registers.h"


void Z80Registers::reset() noexcept
{
	// reset registers
	// disable interrupts
	// set interrupt mode = 0

	af=bc=de=hl=ix=iy=pc=sp=af2=bc2=de2=hl2=ir=iff=im=0;
}

int32 Z80Registers::getValue (cstr name, bool with_quadregs) const noexcept
{
	// get value of register, flag, 8 bit or 16 bit:
	// returns -1 for invalid names
	// if with_quadregs is true, then also return value of dreg register tuple.
	// attn: -1 is a valid value for quad_regs!

	char z[8]={0};
	strncpy(z,name,5);
	switch(peek4X(z) | 0x20202020)
	{
	case 'af  ': return af;
	case 'bc  ': return bc;
	case 'de  ': return de;
	case 'hl  ': return hl;
	case 'af\' ':
	case 'af2 ': return af2;
	case 'bc\' ':
	case 'bc2 ': return bc2;
	case 'de\' ':
	case 'de2 ': return de2;
	case 'hl\' ':
	case 'hl2 ': return hl2;
	case 'ix  ': return ix;
	case 'iy  ': return iy;
	case 'pc  ': return pc;
	case 'sp  ': return sp;
	//case 'iff ': return iff;		don't expose as a dbl reg
	//case 'ir  ': return ir;		""

	case 'a   ': return a;
	case 'f   ': return f;
	case 'b   ': return b;
	case 'c   ': return c;
	case 'd   ': return d;
	case 'e   ': return e;
	case 'h   ': return h;
	case 'l   ': return l;
	case 'a\'  ':
	case 'a2  ': return a2;
	case 'f\'  ':
	case 'f2  ': return f2;
	case 'b\'  ':
	case 'b2  ': return b2;
	case 'c\'  ':
	case 'c2  ': return c2;
	case 'd\'  ':
	case 'd2  ': return d2;
	case 'e\'  ':
	case 'e2  ': return e2;
	case 'h\'  ':
	case 'h2  ': return h2;
	case 'l\'  ':
	case 'l2  ': return l2;
	case 'ixh ':
	case 'xh  ': return xh;
	case 'ixl ':
	case 'xl  ': return xl;
	case 'iyh ':
	case 'yh  ': return yh;
	case 'iyl ':
	case 'yl  ': return yl;
	case 'pch ': return pch;
	case 'pcl ': return pcl;
	case 'sph ': return sph;
	case 'spl ': return spl;
	case 'iff1': return iff1;
	case 'iff2': return iff2;
	case 'i   ': return i;
	case 'r   ': return r;
	case 'im  ': return im;

	default:
		if (!with_quadregs || strlen(name)!=4) return -1;  // not a register name
		// try to return quad register value:
		return getValue(leftstr(name,2)) * 0x10000 + uint16(getValue(name+2));
	}
}

static const char reg8names[] =
	" a f b c d e h l a2 f2 b2 c2 d2 e2 h2 l2 a' f' b' c' d' e' h' l' "
	"xh xl yh yl ixh ixl iyh iyl pch pcl sph spl i r ";
static const char reg16names[] =
	" af bc de hl af2 bc2 de2 hl2 af' bc' de' hl' ix iy pc sp ";


bool Z80Registers::isaRegisterName (cstr name, bool with_quadregs) noexcept
{
	// test whether the name is recognized as a 8 or 16 bit register, im or iff.
	// if with_quadregs is true, then also test for quad register names like dehl.

	cstr name_w_guards = catstr(" ",lowerstr(name), " ");
	return find(reg8names,name_w_guards) || find(reg16names,name_w_guards) ||
			(with_quadregs && isaQuadRegister(name)) ||
			eq(name,"im") || eq(name,"iff1") || eq(name,"iff2");
}

bool Z80Registers::isa8bitRegister (cstr name) noexcept
{
	name = catstr(" ",lowerstr(name), " ");
	return find(reg8names,name);
}

bool Z80Registers::isa16bitRegister (cstr name) noexcept
{
	name = catstr(" ",lowerstr(name), " ");
	return find(reg16names,name);
}

bool Z80Registers::isaQuadRegister (cstr name) noexcept
{
	// test for names formed from 2 dreg names like DEHL:
	// allowed dregs: BC DE HL SP IX IY
	// pairs of the same dreg are not allowed

	char c1,c2,c3,c4;
	if (name && (c1=*name++) && (c2=*name++) && (c3=*name++) && (c4=*name++) && *name==0)
	{
		static const char hi[]="bdhsii";
		static const char lo[]="celpxy";

		cptr p2 = strchr(lo, c2|0x20);
		cptr p4 = strchr(lo, c4|0x20);

		return p2 && p4 && (p2!=p4) && (c1|0x20) == hi[p2-lo] && (c3|0x20) == hi[p4-lo];
	}
	return no;
}

bool Z80Registers::getLimits (cstr name, int32& min, int32& max, bool with_quadregs) noexcept
{
	// return lower and upper limit for the named register.
	// reg = 8 bit register, 16 bit register, quad (two 16 bit registers), im or iff.
	// returns true if ok
	// returns false and sets max=min=0 if no such register.

	cstr name_w_guards = catstr(" ",lowerstr(name), " ");
	if (find(reg8names,name_w_guards))
	{
		min = -0x100;
		max = 0xFF;
		return true;
	}
	else if (find(reg16names,name_w_guards))
	{
		min = -0x10000;
		max = 0xFFFF;
		return true;
	}
	else if (with_quadregs && isaQuadRegister(name))
	{
		min = int32(0x80000000);
		max = 0x7fffffff;
		return true;
	}
	else if (eq(name, "im"))
	{
		min = 0;
		max = 2;
		return true;
	}
	else if (eq(name, "iff1") || eq(name, "iff2"))
	{
		min = 0;
		max = 1;
		return true;
	}
	else
	{
		min = max = 0;
		return false;
	}
}






















