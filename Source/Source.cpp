/*	Copyright  (c)	Günter Woigk 2014 - 2020
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

#include "Source.h"



// ----------------------------------------------
//			Source = Array<SourceLine>
// ----------------------------------------------

void Source::includeFile (cstr filename_fqn, uint sourceAE_index) throws
{
	// include another assembler source file at sourceAE_index into this.source[]
	// die Text-Pointer der SourceLines zeigen alle in tempmem!
	// die Sourcefile-Pointer zeigen alle auf filename_fqn!

	try
	{
		FD fd(filename_fqn,'r');
		if (fd.file_size() > 10000000) throw AnyError("source file exceeds 10,000,000 bytes");	// sanity
		fd.skip_utf8_bom();

		RCArray<SourceLine> zsource;
		for (;;)
		{
			cstr s = fd.read_str();
			if (s==nullptr) break;		// file end
			if (*s==0x1A) break;		// CP/M file padding
			zsource.append(new SourceLine(filename_fqn, zsource.count(), s));
		}

		insertat(sourceAE_index,zsource);
		if (count()>1000000) throw AnyError("total source exceeds 1,000,000 lines");	// sanity
	}
	catch (AnyError& e)
	{
		throw FatalError("file \"%s\" could not be read: %s", filename_fqn, e.what());
	}
}



// ----------------------------------------------
//				  SourceLine
// ----------------------------------------------

SourceLine::SourceLine (cstr sourcefile, uint linenumber, cstr text)
:
	text(text),						// 2nd ptr
	sourcefile(sourcefile),			// 2nd ptr
	sourcelinenumber(linenumber),	// 0-based
	segment(nullptr),
	byteptr(0),
	bytecount(0),
	label(nullptr),
	is_data(no),
	p(text)
{}

char SourceLine::peekChar ()
{
	// skip spaces and peek next char
	// returns 0 at end of line

	skip_spaces();
	return *p;
}

bool SourceLine::testChar (char c)
{
	// skip spaces and test for and skip next char
	// returns true if the expected char was found

	skip_spaces();
	return test_char(c);
}

bool SourceLine::testWord (cstr z)
{
	// test for and skip next word
	// test is case insensitive

	skip_spaces();
	cptr q = p;
	while (*z && to_lower(*z)==to_lower(*q)) { z++; q++; }
	if (*z) return no;				// character mismatch
	if (is_idf(*q)) return no;		// word in this.text longer than tested word
	p = q; return yes;				// hit! => skip word and return true
}

bool SourceLine::testDotWord (cstr z)
{
	// test for and skip next word
	// test is case insensitive
	// the word may optionally start with a dot

	skip_spaces();
	cptr q = p;
	q += *q=='.';
	while (*z && to_lower(*z)==to_lower(*q)) { z++; q++; }
	if (*z) return no;				// character mismatch
	if (is_idf(*q)) return no;		// word in this.text longer than tested word
	p = q; return yes;				// hit! => skip word and return true
}

bool SourceLine::testEol()
{
	// test for logical end of line
	// which may be physical end of line or start of a comment or start of another command after '\'

	skip_spaces();
	char c = *p;
	return c==';' || c==0 || c=='\\';
}

void SourceLine::expect (char c) throws
{
	// skip spaces and test for and skip char
	// throw error if char does not match

	if (!testChar(c)) throw SyntaxError("'%c'", c);
}

void SourceLine::expectEol () throws
{
	// test for logical end of line
	// which may be physical end of line or start of a comment
	// throw error if not at eol

	skip_spaces();
	char c = *p;
	if (c==';' || c==0) return;
	else throw SyntaxError("end of line expected");
}

cstr SourceLine::nextWord ()
{
	// get next word from source line
	// returns word is const or temp
	// returns "" at eol
	// this function is not used for operators!

	skip_spaces();
	if (*p==';') return "";
	if (*p==0)   return "";					// endofline

	cstr word = p;
	char c    = *p++;

	switch (c)
	{
	case '!':	return "!";
	case '~':	return "~";
	case '+':	return "+";
	case '-':	return "-";
	case '*':	return "*";
	case '/':	return "/";
	case '\\':	return "\\";
	case '(':	return "(";
	case ')':	return ")";
	case ',':	return ",";
	case '=':	return "=";
	case '{':	return "{";
	case '}':	return "}";
	case '<':	return "<";
	case '>':	return ">";

	case '\'':							// 'abcd' ''' or ''
		if (*p==c) { p++; if (*p!=c) return "''"; p++; return "'''"; }	// special test for '''
		goto a;

	case '"':							// "abcd" or ""
	a:	while (*p!=c && *p) p++;
		if (*p==c) p++;
		break;

	case '$':							// $, $$ or hex number
		if (*p=='$') p++;
		else while (is_hex_digit(*p)) p++;
		break;

	case '&':							// hex number
		while (is_hex_digit(*p)) p++;
		break;

	case '%':							// binary number
		while (is_bin_digit(*p)) p++;
		break;

	default:						// name, decimal number, garbage
		if (is_idf(c) || c=='.')
		{
			while (is_idf(*p) || *p=='.') p++;
		}
		break;
	}

	return substr(word, p);
}

cstr SourceLine::whitestr ()
{
	// whitestr() up to error column
	// error column is expected to be the current parsing position p

	// Wenn der Fehler erst nach Untersuchung des nachfolgenden Tokens festgestellt wurde,
	// wurde p über den dazwischen liegenden Leerraum weitergestellt.
	// Dann ist es unschön, wenn die Fehlerposition erst nach so viele Leerzeichen oder Tabs
	// angezeigt wird, da dann auch die Fehlermeldung entsprechend weiter nach rechts raussteht.
	// Deshalb wird p zuerst wieder über den Leerraum links von p zurückgestellt.

	while (p>text && *(p-1)<=' ') p--;
	return ::whitestr(substr(text,p));
}

























