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

#include "cstrings/cstrings.h"
#include "Templates/HashMap.h"
#include "Templates/RCObject.h"
#include "Templates/RCPtr.h"
#include "Value.h"



class Segment;


class Label
{
	template<class T> friend class RCPtr;
	mutable uint cnt = 0;
	void	retain () const 		noexcept { ++cnt; }
	void	release () const		noexcept { if (--cnt == 0) delete this; }

public:
	cstr	name;
	Segment* segment;
	uint	sourceline;			// of DEFINITION
	Value	value;
	bool	is_global;			// global label: item in Z80Assembler.labels[0]
	bool	is_defined;			// label is defined (value may be still in_valid) not only declared
	bool	is_used;			// label is actually used
	bool	is_redefinable;
	bool	was_redefined;
	bool	is_reusable;		// sdcc reusable label

public:
	Label (cstr name, Segment*, uint sourceline, int32 value, Validity, bool is_global, bool is_defined, bool is_used);
	Label (cstr name, Segment*, uint sourceline, Value const&, bool is_global, bool is_defined, bool is_used);
	Label (Label const&);
	~Label ()				noexcept { assert(cnt==0); }

	int32	get_value()		{ return value.value; }
	bool	is_invalid()	{ return value.validity == invalid; }
	bool	is_preliminary(){ return value.validity == preliminary; }
	bool	is_valid()		{ return value.validity == valid;   }
};



class Labels : public RCHashMap<cstr,Label>
{
public:
	uint	outer_index;		// index of surrounding Labels block in list of all Labels blocks
	bool	is_global;			// this is the global Labels[]

	enum GFlag { GLOBALS };

public:
	Labels (GFlag)						:outer_index(0),is_global(yes){}
	Labels (uint outer_index)			:outer_index(outer_index),is_global(no){}
	void	add (Label* l)				{ RCHashMap::add(l->name,l); }
	Label*	find (cstr name)			{ return contains(name) ? RCHashMap::get(name).ptr() : nullptr; }
	Label const* find (cstr name) const	{ return contains(name) ? RCHashMap::get(name).ptr() : nullptr; }
};






















