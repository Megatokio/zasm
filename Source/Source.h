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


#ifndef ZASMSOURCELINE_H
#define ZASMSOURCELINE_H


#include "kio/kio.h"
#include "Templates/Array.h"
#include "SyntaxError.h"
#include "Templates/RCObject.h"
#include "Templates/RCPtr.h"

class Label;
class Segment;


inline bool is_idf	 (char c)	{ return is_letter(c) || is_dec_digit(c) || c=='_'; }
inline char lc       (char c)	{ return c|0x20; }



class SourceLine
{
	template<class T> friend class RCPtr;
	mutable uint cnt = 0;
	void	retain () const 		noexcept { ++cnt; }
	void	release () const		noexcept { if (--cnt == 0) delete this; }

public:
	cstr	text;				// tempmem / shared
	cstr	sourcefile;			// tempmem / shared between all sourcelines of this file
	uint	sourcelinenumber;	// line number in source file; 0-based

	Segment* segment;			// of object code
	uint	byteptr;			// byte position (index in segment) of object code at start of line
	uint	bytecount;			// of bytes[]

	Label*	label;				// if a label is defined in this line
	bool	is_data;			// if generated data is no executable code

	cptr	p;					// current position of source parser

public:
	SourceLine (cstr sourcefile, uint linenumber, cstr text);

	char		operator*	()		{ return *p; }
	char		operator[]	(uint i){ return text[i]; }
	SourceLine&	operator++	()		{ assert(*p);     ++p; return *this; }	// prefix
	SourceLine&	operator--	()		{ assert(p>text); --p; return *this; }	// prefix
	SourceLine&	operator+=	(int n)	{ assert(n>0?p+n<=strchr(p,0):p+n>=text); p+=n; return *this; }
	SourceLine&	operator-=	(int n)	{ assert(n<0?p-n<=strchr(p,0):p-n>=text); p-=n; return *this; }

	void	rewind		()			{ p = text; }
	void	skip_spaces	()			{ while(is_space(*p)) p++; }
	void	skip_char	(char c)	{ if(*p==c) p++; }
	void	skip_to_eol	()			{ p = strchr(p,0); }
	bool	test_char	(char c)	{ if(*p==c) { p++; return true; } else return false; }

	// these automatically skip white space:
	char	peekChar	();
	bool	testChar	(char);
	bool	testWord	(cstr);
	bool	testDotWord	(cstr);
	bool	testComma	()			{ return testChar(','); }
	bool	testEol		();

	void	expect		(char)		throws ;
	void	expectComma	()			throws 		{ expect(','); }
	void	expectOpen	()			throws 		{ expect('('); }
	void	expectClose	()			throws 		{ expect(')'); }
	void	expectEol	()			throws ;

	cstr	nextWord	();

	uint	column		()			{ return p-text; }		// 0-based
	cstr	whitestr	();			// whitestr() up to error column
};


class Source : public RCArray<SourceLine>
{
public:
	void	includeFile	(cstr filename_fqn, uint zeilen_index)	throws; /*fatal_error*/
};





#endif // ZASMSOURCELINE_H





























