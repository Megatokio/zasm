// Copyright (c) 1996 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "kio/kio.h"

// -Wno-nested-anon-types
// -Wno-gnu-anonymous-struct

union Z80Registers
{
	struct
	{
		uint16 af, bc, de, hl, af2, bc2, de2, hl2, ix, iy, pc, sp, iff, ir;
	};

#ifdef __BIG_ENDIAN__
	struct
	{
		uint8 a, f, b, c, d, e, h, l, a2, f2, b2, c2, d2, e2, h2, l2, xh, xl, yh, yl, pch, pcl, sph, spl, iff1, iff2, i,
			r, im, xxx;
	};
#endif

#ifdef __LITTLE_ENDIAN__
	struct
	{
		uint8 f, a, c, b, e, d, l, h, f2, a2, c2, b2, e2, d2, l2, h2, xl, xh, yl, yh, pcl, pch, spl, sph, iff1, iff2, r,
			i, im, xxx;
	};
#endif

	Z80Registers() {}
	~Z80Registers() {}

	void  reset() noexcept;
	int32 getValue(cstr name, bool with_quadregs = no)
		const noexcept; // returns -1 for invalid names (ATTN: -1 is a legal value for QuadRegisters!)

	static bool isaRegisterName(cstr name, bool with_quadregs = no) noexcept;
	static bool isa8bitRegister(cstr name) noexcept;
	static bool isa16bitRegister(cstr name) noexcept;
	static bool isaQuadRegister(cstr name) noexcept;
	static bool getLimits(cstr name, int32& min, int32& max, bool with_quadregs = no) noexcept;
};
