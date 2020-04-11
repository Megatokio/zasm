#pragma once
/*	Copyright  (c)	Günter Woigk 2014 - 2020
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

#include "kio/kio.h"
#include "Templates/Array.h"
#include "Source.h"


class Error
{
public:
	cstr		text;
	SourceLine*	sourceline;			// reference to source line or NULL

public:
	Error (cstr text, SourceLine* sourceline);
	Error (cstr text, SourceLine* sourceline, va_list va) __printflike(2,0);
};


typedef Array<Error> Errors;

































