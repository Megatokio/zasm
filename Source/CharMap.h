#pragma once
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
