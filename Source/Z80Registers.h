/*	Copyright  (c)	Günter Woigk 1996 - 2020
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

#pragma once
#include "kio/kio.h"

// -Wno-nested-anon-types
// -Wno-gnu-anonymous-struct

union Z80Registers
{
	struct { uint16 af,bc,de,hl, af2,bc2,de2,hl2, ix,iy,pc,sp, iff, ir; };

	#if BYTE_ORDER == BIG_ENDIAN
	struct { uint8 a,f,b,c,d,e,h,l, a2,f2,b2,c2,d2,e2,h2,l2, xh,xl,yh,yl,pch,pcl,sph,spl, iff1,iff2, i,r, im,xxx; };
	#endif

	#if BYTE_ORDER == LITTLE_ENDIAN
	struct { uint8 f,a,c,b,e,d,l,h, f2,a2,c2,b2,e2,d2,l2,h2, xl,xh,yl,yh,pcl,pch,spl,sph, iff1,iff2, r,i, im,xxx; };
	#endif

	Z80Registers(){}
	~Z80Registers(){}

	void reset() noexcept;
	int getValue (cstr name) const noexcept;	// returns -1 for invalid names

	static bool isaRegisterName(cstr) noexcept;
	static bool isa8bitRegister(cstr) noexcept;
	static bool isa16bitRegister(cstr) noexcept;
	static bool getLimits(cstr,int&,int&) noexcept;
};

