// Copyright (c) 2014 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#pragma once
#include "Templates/HashMap.h"
#include "Templates/RCObject.h"
#include "Templates/RCPtr.h"
#include "Value.h"
#include "cstrings/cstrings.h"


class Segment;


class Label
{
	template<class T>
	friend class RCPtr;
	mutable uint cnt = 0;
	void		 retain() const noexcept { ++cnt; }
	void		 release() const noexcept
	{
		if (--cnt == 0) delete this;
	}

public:
	cstr	 name;
	Segment* segment;
	uint	 sourceline; // of DEFINITION
	Value	 value;
	bool	 is_global;	 // global label: item in Z80Assembler.labels[0]
	bool	 is_defined; // label is defined (value may be still in_valid) not only declared
	bool	 is_used;	 // label is actually used
	bool	 is_redefinable;
	bool	 was_redefined;
	bool	 is_reusable; // sdcc reusable label

public:
	Label(cstr name, Segment*, uint sourceline, int32 value, Validity, bool is_global, bool is_defined, bool is_used);
	Label(cstr name, Segment*, uint sourceline, cValue&, bool is_global, bool is_defined, bool is_used);
	Label(const Label&);
	~Label() noexcept { assert(cnt == 0); }

	int32 get_value() { return value.value; }
	bool  is_invalid() { return value.is_invalid(); }
	bool  is_preliminary() { return value.is_preliminary(); }
	bool  is_valid() { return value.is_valid(); }
};


class Labels : public RCHashMap<cstr, Label>
{
public:
	uint outer_index; // index of surrounding Labels block in list of all Labels blocks
	bool is_global;	  // this is the global Labels[]

	enum GFlag { GLOBALS };

public:
	Labels(GFlag) : outer_index(0), is_global(yes) {}
	Labels(uint outer_index) : outer_index(outer_index), is_global(no) {}
	void		 add(Label* l) { RCHashMap::add(l->name, l); }
	Label*		 find(cstr name) { return contains(name) ? RCHashMap::get(name).ptr() : nullptr; }
	const Label* find(cstr name) const { return contains(name) ? RCHashMap::get(name).ptr() : nullptr; }
};
