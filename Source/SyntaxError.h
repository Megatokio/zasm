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


















