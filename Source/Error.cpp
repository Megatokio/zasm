// Copyright (c) 2014 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#include "Error.h"

Error::Error(cstr text, SourceLine* sourceline) : text(dupstr(text)), sourceline(sourceline) {}

Error::Error(cstr text, SourceLine* sourceline, va_list va) : text(usingstr(text, va)), sourceline(sourceline) {}
