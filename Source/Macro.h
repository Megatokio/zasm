// Copyright (c) 2014 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#ifndef MACRO_H
#define MACRO_H

#include "Templates/HashMap.h"

class Macro
{
public:
	Array<cstr> args;		  // argument names, without tag
	uint32		mdef;		  // line with '.macro'
	uint32		endm;		  // line with '.endm'
	char		tag;		  // the tag character, e.g. '&'
	bool		tag_required; // tag char is required (else optional)

public:
	Macro(Array<cstr> args, uint32 a, uint32 e, char tag, bool required) :
		args(std::move(args)),
		mdef(a),
		endm(e),
		tag(tag),
		tag_required(required)
	{}
};

typedef HashMap<cstr, Macro> Macros;


#endif // MACRO_H
