// Copyright (c) 2014 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "kio/kio.h"


// ----	Error classes: ----

class SyntaxError : public AnyError
{
public:
	SyntaxError(cstr s, ...) noexcept __printflike(2, 3);
	SyntaxError(cstr s, va_list va) noexcept __printflike(2, 0) : AnyError(s, va) {}
	SyntaxError(int error) noexcept : AnyError(error) {}
	SyntaxError(int error, cstr t) noexcept : AnyError(error, t) {}
};

class FatalError : public AnyError
{
public:
	FatalError(cstr s, ...) noexcept __printflike(2, 3);
	FatalError(cstr s, va_list va) noexcept __printflike(2, 0) : AnyError(s, va) {}
	FatalError(int error) noexcept : AnyError(error) {}
	FatalError(int error, cstr t) noexcept : AnyError(error, t) {}
};
