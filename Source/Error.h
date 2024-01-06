// Copyright (c) 2014 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "Source.h"
#include "Templates/Array.h"
#include "kio/kio.h"


class Error
{
public:
	cstr		text;
	SourceLine* sourceline; // reference to source line or NULL

public:
	Error(cstr text, SourceLine* sourceline);
	Error(cstr text, SourceLine* sourceline, va_list va) __printflike(2, 0);
};


using Errors = Array<Error>;
