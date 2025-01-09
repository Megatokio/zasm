// Copyright (c) 2017 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause


#include "SyntaxError.h"
#include "kio/kio.h"

SyntaxError::SyntaxError(cstr s, ...) noexcept : AnyError(customerror)
{
	va_list va;
	va_start(va, s);
	msg = newcopy(usingstr(s, va));
	va_end(va);
}

FatalError::FatalError(cstr s, ...) noexcept : AnyError(customerror)
{
	va_list va;
	va_start(va, s);
	msg = newcopy(usingstr(s, va));
	va_end(va);
}
