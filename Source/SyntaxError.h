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


#ifndef SYNTAXERROR_H
#define SYNTAXERROR_H

#include "kio/kio.h"


// ----	Error classes: ----

class syntax_error : public any_error
{
public:
	syntax_error (cstr s, ...)		noexcept __printflike(2,3);
	syntax_error (cstr s, va_list va) noexcept __printflike(2,0) : any_error(s,va){}
	syntax_error (int err)			noexcept : any_error(err){}
	syntax_error (int err, cstr t)	noexcept : any_error(err,t){}
};

class fatal_error : public any_error
{
public:
	fatal_error	(cstr s, ...)		noexcept __printflike(2,3);
	fatal_error (cstr s, va_list va) noexcept  __printflike(2,0) : any_error(s,va){}
	fatal_error	(int err)			noexcept : any_error(err){}
	fatal_error	(int err, cstr t)	noexcept : any_error(err,t){}
};


#endif // SYNTAXERROR_H

















