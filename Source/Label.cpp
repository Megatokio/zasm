// Copyright (c) 2014 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#include "Label.h"


// --------------------------------------------
//				Label
// --------------------------------------------


Label::Label(
	cstr name, Segment* segment, uint sourceline, int32 value, Validity validity, bool is_global, bool is_defined,
	bool is_used) :
	name(name),
	segment(segment),
	sourceline(sourceline),
	value(value, validity),
	is_global(is_global),
	is_defined(is_defined),
	is_used(is_used),
	is_redefinable(no),
	was_redefined(no),
	is_reusable(no)
{}

Label::Label(
	cstr name, Segment* segment, uint sourceline, cValue& value, bool is_global, bool is_defined, bool is_used) :
	name(name),
	segment(segment),
	sourceline(sourceline),
	value(value),
	is_global(is_global),
	is_defined(is_defined),
	is_used(is_used),
	is_redefinable(no),
	was_redefined(no),
	is_reusable(no)
{}

Label::Label(const Label& q) :
	name(q.name),
	segment(q.segment),
	sourceline(q.sourceline),
	value(q.value),
	is_global(q.is_global),
	is_defined(q.is_defined),
	is_used(q.is_used),
	is_redefinable(q.is_redefinable),
	was_redefined(q.was_redefined),
	is_reusable(q.is_reusable)
{}
