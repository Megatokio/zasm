// Copyright (c) 2014 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "SyntaxError.h"
#include "Templates/HashMap.h"

using UCS2Char = uint16;
using UCS4Char = uint32;
using UTF8Str  = char*;		  // c-style string
using cUTF8Str = const char*; // c-style string literals in utf-8 encoded source files
using pstr	   = uchar*;	  // length prefixed string


class CharMap : private HashMap<UCS2Char, uchar>
{
	uchar charmap[128]; // quick translation of ascii range

public:
	enum CharSet { NONE, ASCII, ZX80, ZX81, ZXSP, JUPITER, ZX80_INVERTED, ZX81_INVERTED, JUPITER_INVERTED };
	static CharSet charsetFromName(cstr name);

	CharMap();
	CharMap(CharSet charset);
	void  purge();
	bool  contains(UCS2Char) const;
	void  add(UCS2Char, uchar);
	void  addMappings(cUTF8Str map, uint first_char_in_map);
	void  remove(UCS2Char);
	void  removeMappings(cUTF8Str);
	uchar get(UCS2Char, uchar dflt) const;
	uchar get(UCS2Char) const;
	uchar operator[](UCS2Char) const noexcept;
	pstr  translate(cUTF8Str);
};
