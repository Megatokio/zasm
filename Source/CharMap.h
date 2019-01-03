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


#ifndef CHARMAP_H
#define CHARMAP_H

#include "Templates/HashMap.h"
#include "SyntaxError.h"

typedef uint16		UCS2Char;
typedef uint32		UCS4Char;
typedef	char*		UTF8Str;	// c-style string
typedef char const* cUTF8Str;	// c-style string literals in utf-8 encoded source files
typedef uchar*		pstr;		// length prefixed string


class CharMap : private HashMap<UCS2Char,uchar>
{
	uchar	charmap[128];	// quick translation of ascii range

public:
	enum CharSet { NONE, ASCII, ZX80, ZX81, ZXSP, JUPITER, ZX80_INVERTED, ZX81_INVERTED, JUPITER_INVERTED };
	static CharSet charsetFromName (cstr name);

			CharMap		();
			CharMap		(CharSet charset);
	void	purge		();
	bool	contains	(UCS2Char) const;
	void	add			(UCS2Char, uchar);
	void	addMappings	(cUTF8Str map, uint first_char_in_map) throws /*data_error*/;
	void	remove		(UCS2Char);
	void	removeMappings (cUTF8Str) throws /*data_error*/;
	uchar	get			(UCS2Char, uchar dflt) const;
	uchar	get			(UCS2Char) const throws ;
	uchar	operator[]	(UCS2Char) const noexcept;
	pstr	translate	(cUTF8Str) throws /*data_error*/;
};

#endif // CHARMAP_H
