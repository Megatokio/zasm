// Copyright (c) 2014 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "SyntaxError.h"
#include "Templates/Array.h"
#include "Templates/RCObject.h"
#include "Templates/RCPtr.h"

class Label;
class Segment;


inline bool is_idf(char c) { return is_letter(c) || is_dec_digit(c) || c == '_'; }
inline char lc(char c) { return c | 0x20; }


class SourceLine
{
	template<class T>
	friend class RCPtr;
	mutable uint cnt = 0;
	void		 retain() const noexcept { ++cnt; }
	void		 release() const noexcept
	{
		if (--cnt == 0) delete this;
	}

public:
	cstr text;			   // tempmem / shared
	cstr sourcefile;	   // tempmem / shared between all sourcelines of this file
	uint sourcelinenumber; // line number in source file; 0-based

	Segment* segment;	// of object code
	uint	 byteptr;	// byte position (index in segment) of object code at start of line
	uint	 bytecount; // of bytes[]

	Label* label;	// if a label is defined in this line
	bool   is_data; // if generated data is no executable code

	cptr p; // current position of source parser

public:
	SourceLine(cstr sourcefile, uint linenumber, cstr text);

	char		operator*() { return *p; }
	char		operator[](uint i) { return text[i]; }
	SourceLine& operator++()
	{
		assert(*p);
		++p;
		return *this;
	} // prefix
	SourceLine& operator--()
	{
		assert(p > text);
		--p;
		return *this;
	} // prefix
	SourceLine& operator+=(off_t n)
	{
		assert(n > 0 ? p + n <= strchr(p, 0) : p + n >= text);
		p += n;
		return *this;
	}
	SourceLine& operator-=(off_t n)
	{
		assert(n < 0 ? p - n <= strchr(p, 0) : p - n >= text);
		p -= n;
		return *this;
	}

	void rewind() { p = text; }
	void skip_spaces()
	{
		while (is_space(*p)) p++;
	}
	void skip_char(char c)
	{
		if (*p == c) p++;
	}
	void skip_to_eol() { p = strchr(p, 0); }
	bool test_char(char c)
	{
		if (*p == c)
		{
			p++;
			return true;
		}
		else return false;
	}

	// these automatically skip white space:
	char peekChar();
	bool testChar(char);
	bool testWord(cstr);
	bool testDotWord(cstr);
	bool testComma() { return testChar(','); }
	bool testEol();
	bool testCommaNoGKauf()
	{
		cptr a = p;
		if (testComma() && peekChar() != '{') return yes;
		p = a;
		return no;
	}

	void expect(char);
	void expectComma() { expect(','); }
	void expectOpen() { expect('('); }
	void expectClose() { expect(')'); }
	void expectEol();

	cstr nextWord() noexcept;
	cstr nextName(bool dot = no);

	uint column() { return p - text; } // 0-based
	cstr whitestr();				   // whitestr() up to error column
};


class Source : public RCArray<SourceLine>
{
public:
	void includeFile(cstr filename_fqn, uint zeilen_index) throws; /*fatal_error*/
};
