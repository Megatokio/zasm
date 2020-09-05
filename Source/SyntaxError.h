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

class SyntaxError : public AnyError
{
public:
	SyntaxError (cstr s, ...)		noexcept __printflike(2,3);
	SyntaxError (cstr s, va_list va) noexcept __printflike(2,0) : AnyError(s,va){}
	SyntaxError (int error)			noexcept : AnyError(error){}
	SyntaxError (int error, cstr t)	noexcept : AnyError(error,t){}
};

class FatalError : public AnyError
{
public:
	FatalError (cstr s, ...)		noexcept __printflike(2,3);
	FatalError (cstr s, va_list va) noexcept  __printflike(2,0) : AnyError(s,va){}
	FatalError (int error)			noexcept : AnyError(error){}
	FatalError (int error, cstr t)	noexcept : AnyError(error,t){}
};


















