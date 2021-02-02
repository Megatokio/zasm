/*	Copyright  (c)	Günter Woigk 2014 - 2021
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


#include "CharMap.h"


#define NC 0xff		// mark unset char in this.charmap[]

// from kio/c_defines.h:
#define	RMASK(n)	(~(0xFFFFFFFF<<(n)))	// mask to select n bits from the right


static UCS2Char ucs2_from_utf8 (cptr s) throws
{
	// Helper:
	// convert UTF-8 char to UCS-2
	// throws on error
	// from Unicode/UTF-8.h

	assert(s);

	if (is_ascii(*s)) return UCS2Char(*s);	// 7-bit ascii char
	if (is_utf8_fup(*s)) throw DataError("broken character in map (unexpected UTF-8 fup character)");
	UCS4Char n = uchar(*s);					// UCS-4 char code akku
											// 0x80 … 0xBF: unexpected fups
// multi-byte character:
	uint i = 0;								// UTF-8 character size
	int8 c = int8(n & ~0x02u);				// force stop at i=6
	while (int8(c<<(++i)) < 0)				// loop over fup bytes
	{
		char c1 = *(++s);
		if (!is_utf8_fup(c1)) throw DataError("broken character in map (truncated UTF-8 character)");
		n = (n<<6) + (c1&0x3F);
	}

// now: i = total number of bytes
//      n = UCS4 char code with some of the '1' bits from c0
	n &= RMASK(2+i*5);
	if (n!=UCS2Char(n)) throw DataError("UTF-8 character outside the UCS2 code range in map");

// ill. overlong encodings:
	if (n < 1u<<(i*5-4)) throw DataError("illegal character in map (illegal overlong UTF-8 encoding)");

// ok => return code
	return UCS2Char(n);
}

CharMap::CharMap ()
:
	HashMap(8)
{
	// Create Character Map with no mappings
	// Mappings must be added with add() or addMappings()

	memset(charmap,NC,128);
}

CharMap::CharMap (CharSet charset)
:
	HashMap(32)
{
	// Create Character Map for target charset

	memset(charmap,NC,128);
	switch (charset)
	{
	case ZX80:  addMappings(" \"▌▄▘▝▖▗▞...£$:?()-+*/=><;,.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",0);
				addMappings("abcdefghijklmnopqrstuvwxyz",0x80+0x40-26);
				addMappings("█",128);
				addMappings("▐▀▟▙▜▛▚",130);
				break;
	case ZX80_INVERTED:
				addMappings(" \"▌▄▘▝▖▗▞...£$:?()-+*/=><;,.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",0x80);
				addMappings("abcdefghijklmnopqrstuvwxyz",0x40-26);
				addMappings("█",128^0x80);
				addMappings("▐▀▟▙▜▛▚",130^0x80);
				break;
	case ZX81:	addMappings(" ▘▝▀▖▌▞▛...\"£$:?()><=+-*/;,.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",0);
				addMappings("abcdefghijklmnopqrstuvwxyz",0x80+0x40-26);
				addMappings("█▟▙▄▜▐▚▗",128);
				break;
	case ZX81_INVERTED:
				addMappings(" ▘▝▀▖▌▞▛...\"£$:?()><=+-*/;,.0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ",0x80);
				addMappings("abcdefghijklmnopqrstuvwxyz",0x40-26);
				addMappings("█▟▙▄▜▐▚▗",128^0x80);
				break;
	case ZXSP:	for (int c=32;c<127;c++) charmap[c] = uchar(c);
			//	charmap[9]  = 6;		// tab
			//	charmap[10] = 13;		// nl
			//	charmap[8]  = 8;		// cursor left
			//	charmap[12] = 9;		// cursor right
				addMappings("£",96);
				addMappings("©\u00A0▝▘▀▗▐▚▜▖▞▌▛▄▟▙█",127);	// \u00A0 = nbsp
				break;										// note: Qt Creator silently replaces nbsp with space :-(
	case JUPITER:
				for (int c=32;c<127;c++) charmap[c] = uchar(c);
			//	charmap[10] = 13;		// nl
				addMappings("█▙▟▄▛▌▞▖",16);
				addMappings("£",96);
				addMappings("©",127);
				addMappings("\u00A0▝▘▀▗▐▚▜",144);	// \u00A0 = nbsp
				break;								// note: Qt Creator silently replaces nbsp with space :-(
	case JUPITER_INVERTED:
				for (int c=32;c<127;c++) charmap[c] = uchar(c|0x80);
			//	charmap[10] = 13;		// nl
				addMappings("█▙▟▄▛▌▞▖",16^0x80);
				addMappings("£",96^0x80);
				addMappings("©",127^0x80);
				addMappings("\u00A0▝▘▀▗▐▚▜",144^0x80);	// \u00A0 = nbsp
				break;									// note: Qt Creator silently replaces nbsp with space :-(
//	case ASCII:
//	case NONE:
	default:	for (int c=0;c<127;c++) charmap[c] = uchar(c);
				break;
	}
}

CharMap::CharSet CharMap::charsetFromName (cstr w)
{
	// static
	// helper

	w = lowerstr(w);

	return  eq(w,"zx80") ? ZX80 : eq(w,"zx81") ? ZX81 :
			eq(w,"ascii") ? ASCII : startswith(w,"zxsp") ? ZXSP :
			startswith(w,"jup") || endswith(w,"ace") ? JUPITER :
			startswith(w,"jup") && ::find(w,"inv") ? JUPITER_INVERTED :
			startswith(w,"zx80_i") ? ZX80_INVERTED :
			startswith(w,"zx81_i") ? ZX81_INVERTED :
			NONE;
}

void CharMap::purge ()
{
	memset(charmap,NC,128);
	HashMap::purge();
}

bool CharMap::contains (UCS2Char key) const
{
	if (key<128 && charmap[key]!=NC) return true;
	return HashMap::contains(key);
}

void CharMap::add (UCS2Char key, uchar item)
{
	if (key<128) { charmap[key] = item; if (item!=NC) return; }
	HashMap::add(key,item);
}

void CharMap::remove (UCS2Char key)
{
	HashMap::remove(key);
	if (key<128) charmap[key] = NC;
}

void CharMap::addMappings (cUTF8Str map, uint first_char_in_map) throws
{
	uint c = first_char_in_map;
	cptr p = map;

	while (*p)
	{
		add(ucs2_from_utf8(p),uchar(c++));
		while (is_utf8_fup(*++p)) {}
	}
}

void CharMap::removeMappings (cUTF8Str s) throws
{
	while (*s)
	{
		remove(ucs2_from_utf8(s));
		while (is_utf8_fup(*++s)) {}
	}
}

uchar CharMap::get (UCS2Char key, uchar dflt) const
{
	if (key<128 && charmap[key]!=NC) return charmap[key];
	return HashMap::get(key,dflt);
}

uchar CharMap::get (UCS2Char key) const throws
{
	if (key<128 && charmap[key]!=NC) return charmap[key];
	uchar c = HashMap::get(key,0); if(c) return c;
	static_assert(NC!=0,"const NC must be non-zero here");

	if (key>=' ' && key<=0x7F) throw SyntaxError("Character '%c' is not in the target character set",key);
	else					   throw SyntaxError("Character 0x%04X is not in the target character set",key);
}

uchar CharMap::operator[] (UCS2Char key) const noexcept
{
	if (key<128 && charmap[key]!=NC) return charmap[key];
	return HashMap::operator[](key);
}

pstr CharMap::translate (cptr q) throws
{
	pstr zstr = pstr(tempstr(strlen(q)));
	uint len = 0;

	while (*q)
	{
		cptr q0 = q;
		UCS2Char key = ucs2_from_utf8(q);
		while (is_utf8_fup(*++q)) {}

		if (key<128 && charmap[key]!=NC)
		{
			zstr[++len] = charmap[key];
		}
		else
		{
			if (!HashMap::contains(key))
				throw DataError("target character set does not contain '%s'",substr(q0,q));
			zstr[++len] = HashMap::get(key);
		}
	}

	if (len > 255) throw DataError("text string too long");
	zstr[0] = uchar(len);
	return zstr;
}














