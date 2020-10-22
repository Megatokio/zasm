/*	Copyright  (c)	Günter Woigk 2014 - 2020
					mailto:kio@little-bat.de

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	Permission to use, copy, modify, distribute, and sell this software and
	its documentation for any purpose is hereby granted without fee, provided
	that the above copyright notice appear in all copies and that both that
	copyright notice and this permission notice appear in supporting
	documentation, and that the name of the copyright holder not be used
	in advertising or publicity pertaining to distribution of the software
	without specific, written prior permission.  The copyright holder makes no
	representations about the suitability of this software for any purpose.
	It is provided "as is" without express or implied warranty.

	THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
	INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
	EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
	CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
	DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
	PERFORMANCE OF THIS SOFTWARE.
*/

#include "Segment.h"
#include "Z80Assembler.h"
#include "Libraries/unix/files.h"
#include "Z80Registers.h"
#include <fcntl.h>


bool isData(SegmentType t)
{
	return t==DATA;
}

bool isCode(SegmentType t)
{
	return t==CODE || t==TZX_STANDARD || t==TZX_TURBO || t==TZX_PURE_DATA || t==TZX_GENERALIZED;
}

bool isTest(SegmentType t)
{
	return t==TEST;
}

static void check_validity (cValue& old, cValue& nju, cstr name) // helper
{
	if (old.is_valid() && nju.is_valid() && old != nju)
		throw SyntaxError("%s: value redefined",name);
	if (nju.validity < old.validity)
		throw SyntaxError("%s: value decayed",name);
}

static void check_value (cValue& v, cstr name, int min, int max) // helper
{
	if (v.is_valid() && (v<min || v>max))
		throw SyntaxError("%s: value not in range[%i .. %i]",name,min,max);
}

static void check_value (cValue& old, cValue& nju, cstr name, int min, int max) // helper
{
	check_validity(old,nju,name);
	check_value(nju,name,min,max);
}

static void check_uint16_value (cValue& old, cValue& nju, cstr name) // helper
{
	check_validity(old,nju,name);
	if (nju.is_valid() && nju!=uint16(nju))
		throw SyntaxError("%s: value not in range[0 .. $ffff]",name);
}



// -------------------------------------------------------
//			Segment
// -------------------------------------------------------

// protected:
Segment::Segment (SegmentType type, cstr name)
:
	type(type),
	name(name),
	is_data(no),
	is_code(no),
	is_test(no),
	is_tzx(no),
	dpos()
{}

// protected:
DataSegment::DataSegment (cstr _name, SegmentType _type, bool relocatable, bool resizable)
:
	Segment(_type,_name),
	relocatable(relocatable),
	resizable(resizable),
	address(),
	size(),
	lpos()
{}

/*	#data constructor
	address, size and flag should be set immediately after this call
	or at the end of an assembler pass.
*/
DataSegment::DataSegment (cstr _name)
:
	Segment(DATA,_name),
	relocatable(yes),
	resizable(yes),
	address(),
	size(),
	lpos()
{
	is_data = yes;
}

/*	#code constructor
	core[] is always set to 0x10000 bytes
	address, size and flag should be set immediately after this call
	or at the end of an assembler pass.
*/
CodeSegment::CodeSegment (cstr _name, SegmentType _type, uint8 _fillbyte)
:
	DataSegment(_name,_type,1,1),
	flag(),
	pause(),
	lastbits(),
	fillbyte(_fillbyte),
	custom_fillbyte(no),
	has_flag(no),
	has_pause(no),
	has_lastbits(no),
	no_flagbyte(no),
	no_checksum(no),
	no_pilot(_type==TZX_PURE_DATA),
	checksum_ace(no),
	compressed(0),
	core(0x10000),
	ccore(0),
	ucore(0),
	pilotsym(),
	pilot(),
	datasym(),
	pilotsym_idx(0),
	datasym_idx(0)
{
	is_code = yes;
}

void Segment::throw_data_segment_required () throws { throw SyntaxError("#data segment required"); }
void Segment::throw_code_segment_required () throws { throw SyntaxError("#code or #data segment required"); }

void DataSegment::rewind ()
{
	// rewind dpos to offset 0
	// used at start of next assembly pass
	// => rewinds dpos
	// => sets logical address to physical address
	// => preserves size
	// => preserves segment address

	assert(!resizable || size.value==dpos.value || dpos.value==0 || !dpos.is_valid() || !size.is_valid());

	dpos = 0;
	lpos = address;
}

void CodeSegment::rewind ()
{
	pilotsym_idx = datasym_idx = 0;
	DataSegment::rewind();
}

void DataSegment::setAddress (cValue& new_address) throws
{
	// set "physical" and "logical" segment start address
	// should be set between assembly passes
	// valid address: 0 … 0x10000-size
	// does not clear the 'relocatable' flag
	// rewinds the segment

	if (new_address.is_valid())
	{
		if (address.is_valid() && address != new_address)
		{
			throw SyntaxError("segment %s address redefined", name);
		}

		if (uint32(new_address) > 0x10000)
		{
			throw SyntaxError("segment %s address out of range: %i", name, int(new_address));
		}

		if (size.is_valid() && size + new_address > 0x10000)
		{
			throw SyntaxError(	"segment %s: address+size out of range: %i + %i = %i",
								name, int(new_address), int(size), int(size+new_address) );
		}
	}

	if (new_address.validity < address.validity)
		throw SyntaxError("segment %s address decayed", name);

	lpos = address = new_address;
	dpos = 0;
}

void DataSegment::setSize (cValue& newsize) throws
{
	// set segment size
	// should be set between assembly passes
	// does not clear the 'resizable' flag
	// does not rewind the segment! => preserve dpos for writeHexFile(() and writeS19File()

	if (newsize.is_valid())
	{
		if (size.is_valid() && size != newsize)
			throw SyntaxError("segment %s size redefined",name);

		if (uint32(newsize) > 0x10000)
			throw SyntaxError("segment %s size out of range: %i",name,int(size));

		if (dpos.is_valid() && dpos > newsize)
			throw SyntaxError("segment %s overflow",name);

		if (address.is_valid() && address + newsize > 0x10000 )
			throw SyntaxError( "segment %s: address+size out of range: %i + %i = %i",
								name, int(address), int(newsize), int(address+newsize) );
	}

	if (newsize.validity < size.validity)
		throw SyntaxError("segment %s size decayed",name);

	size = newsize;
}

void DataSegment::setOrigin (cValue& address) throws
{
	// set "logical" code address
	// valid range: -0x8000 … +0xFFFF
	// does not move dpos
	// validity may degrade e.g. after .dephase

	if (address.is_valid())
	{
		if (address < -0x8000 || address > 0xFFFF)
			throw SyntaxError("address out of range");
	}

	lpos.set(address);
}


// -------------------------------------------------------
//			Store Code
// -------------------------------------------------------

void Segment::storeOffset (cValue& offset) throws
{
	if (offset.is_valid())
	{
		if (int16(offset) != int8(offset))
			throw SyntaxError("offset value out of range");
	}
	store(offset.value);
}

void Segment::storeByte (cValue& byte) throws
{
	// store signed or unsigned byte
	// validates byte
	// only check int16 range, so that $FF00 + $1xx works

	if (byte.is_valid())
	{
		if (int16(byte) < -0x80 || int16(byte) > 0xFF)
			throw SyntaxError("byte value out of range");
	}
	store(byte.value);
}

void Segment::storeWord (cValue& word) throws
{
	// store 2 bytes (z80 byte order: lsb first)
	// validates word

	if (word.is_valid())
	{
		if (word < -0x8000 || word > 0xFFFF)
			throw SyntaxError("word value out of range");
	}
	store(word);
	store(word>>8);
}

void Segment::storeHexBytes (cptr data, uint n) throws
{
	// store block of bytes
	// source bytes are stuffed as hex
	// n = bytes to stuff   ( => 2*n hex digits )

	if (n > 0x10000) throw SyntaxError("size > 0x10000");

	while (n--)
	{
		char c = *data++;
		if (!is_hex_digit(c)) throw SyntaxError("only hex characters allowed: '%c'",c);
		char d = *data++;
		if (!is_hex_digit(d)) throw SyntaxError("only hex characters allowed: '%c'",d);

		store(int(hex_digit_value(c)<<4) + int(hex_digit_value(d)));
	}
}



void DataSegment::skipExistingData (uint n) throws
{
	// skip over existing data in pass 2++:
	// in case of an error

	if (n > 0x10000) throw SyntaxError(int(n)<0 ? "size < 0" : "size > 0x10000");

	lpos.value += n;
	dpos.value += n;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw SyntaxError("segment overflow");
}

void DataSegment::store (int byte) throws
{
	// store byte
	// byte must be zero

	if (byte != 0) throw_data_segment_required();

	dpos.value++;
	lpos.value++;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw FatalError("segment overflow");
}

void DataSegment::storeBlock (cptr data, uint n) throws
{
	// store block of raw bytes which must be all zero
	// implemented for completeness

	while (n--) DataSegment::store(*data++);
}

void DataSegment::storeSpace (cValue& sz) throws
{
	// store space

	check_value(sz,"size",0,0x10000);

	// sz		dpos
	// inval	inval	store 0		dpos=inval	lpos=inval
	// inval	preli	store 0		dpos=preli	lpos=preli
	// inval	valid	store 0		dpos=preli	lpos=preli

	// preli	inval	store sz	dpos=inval	lpos=min(lpos,sz)
	// preli	preli	store sz	dpos=preli	lpos=min(lpos,sz)
	// preli	valid	store sz	dpos=preli	lpos=min(lpos,sz)
	// valid	inval	store sz	dpos=inval	lpos=min(lpos,sz)
	// valid	preli	store sz	dpos=preli	lpos=min(lpos,sz)
	// valid	valid	store sz	dpos=valid	lpos=min(lpos,sz)

	if (sz.is_invalid())
	{
		if (dpos.is_valid()) dpos.validity = preliminary;
		if (lpos.is_valid()) lpos.validity = preliminary;
		return;
	}

	lpos += sz;
	dpos += sz;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw SyntaxError("segment overflow");
}

void DataSegment::storeSpace (cValue& sz, int c) throws
{
	// store space filled with byte
	// byte must be zero

	if (c != 0) throw_code_segment_required();
	DataSegment::storeSpace(sz);
}


void CodeSegment::store (int byte) throws
{
	if (dpos<0x10000) core[dpos] = uint8(byte);

	dpos.value++;
	lpos.value++;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw FatalError("segment overflow");
}

void CodeSegment::storeBlock (cptr data, uint n) throws
{
	// store block of raw bytes

	if (n>0x10000) throw SyntaxError("size > 0x10000");

	if (dpos.value < 0x10000) memcpy(&core[dpos.value], data, min(n,0x10000u-uint(dpos)));

	lpos.value += n;
	dpos.value += n;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw SyntaxError("segment overflow");
}

void CodeSegment::storeSpace (cValue& sz, int c) throws
{
	// store space

	check_value(sz,"size",0,0x10000);

	// sz		dpos
	// inval	inval	store 0		dpos=inval	lpos=inval
	// inval	preli	store 0		dpos=preli	lpos=preli
	// inval	valid	store 0		dpos=preli	lpos=preli

	// preli	inval	store sz	dpos=inval	lpos=min(lpos,sz)
	// preli	preli	store sz	dpos=preli	lpos=min(lpos,sz)
	// preli	valid	store sz	dpos=preli	lpos=min(lpos,sz)
	// valid	inval	store sz	dpos=inval	lpos=min(lpos,sz)
	// valid	preli	store sz	dpos=preli	lpos=min(lpos,sz)
	// valid	valid	store sz	dpos=valid	lpos=min(lpos,sz)

	if (sz.is_invalid())
	{
		if (dpos.is_valid()) dpos.validity = preliminary;
		if (lpos.is_valid()) lpos.validity = preliminary;
		return;
	}

	if (dpos.value < 0x10000) memset(&core[dpos.value], c, uint32(min(sz.value, 0x10000-dpos.value)));

	lpos += sz;
	dpos += sz;

	if (dpos > size && dpos.is_valid() && size.is_valid())
		throw SyntaxError("segment overflow");
}

void CodeSegment::storeSpace (cValue& sz) throws
{
	// store space with default fillbyte

	CodeSegment::storeSpace(sz,fillbyte.value);
}

void DataSegment::storeSpaceUpToAddress (cValue& addr) throws
{
	storeSpace(addr-lpos);
	lpos = addr;	// set value and validity
}

void DataSegment::storeSpaceUpToAddress(cValue& addr, int c) throws
{
	storeSpace(addr-lpos, c);
	lpos = addr;	// set value and validity
}

void CodeSegment::clearTrailingBytes () noexcept
{
	// clear remaining bytes after current write index 'dpos' without moving dpos.
	// used to clear unused trailing bytes at the end of a fixed-size CodeSegment.
	// writeHexFile() and writeS19File actually write data up to dpos only
	// whereas all binary output formats write the whole segment, so it must be cleared.

	Value sz = size - dpos;
	if (sz.is_invalid()) return;

	assert(dpos.value <= size.value);

	if (sz.value) memset(&core[dpos.value], fillbyte.value, uint32(sz.value));
}

Validity DataSegment::validity () const
{
	// test whether all segment variables are valid
	// = address, size, flag
	// not checked: dpos, lpos, core[]

	Validity rval = min(address.validity, size.validity);
	return rval;
}

void CodeSegment::setFillByte (cValue& v)
{
	if (!custom_fillbyte) fillbyte.validity = invalid;
	check_value(fillbyte,v,"space",-0x80,0xff);
	fillbyte = v;
	custom_fillbyte = yes;
}

void CodeSegment::setFlag (cValue& v) throws
{
	// Set segment flag
	// used for .z80 and .tap files
	// may be set any time
	// should be set from the #code directive

	if (no_flagbyte)
		throw SyntaxError("flag is already set to 'NONE'");

	if (v.is_valid())
	{
		if (v != uint8(v))
			throw SyntaxError("value out of range");

		if (flag.is_valid() && v != flag)
			throw SyntaxError("segment %s flag redefined",name);
	}
	else
	{
		if (v.validity < flag.validity)
			throw SyntaxError("segment %s flag decayed",name);
	}

	has_flag = yes;
	flag.set(v);
}

void CodeSegment::setNoFlag()
{
	if (has_flag && !no_flagbyte)
		throw SyntaxError("flag is already set");

	has_flag = yes;
	no_flagbyte = yes;
}

// -------------------------------------------------------
//			TZX
// -------------------------------------------------------

void CodeSegment::setNoChecksum()
{
	no_checksum = yes;
}

void CodeSegment::setPause(cValue& v)
{
	if (v.is_valid())
	{
		if (v != uint16(v))
			throw SyntaxError("value out of range");

		if (pause.is_valid() && v != pause)
			throw SyntaxError("pause redefined");
	}
	else
	{
		if (v.validity < pause.validity)
			throw SyntaxError("value for pause decayed");
	}

	has_pause = yes;
	pause = v;
}

void CodeSegment::setLastBits(cValue& v)
{
	assert(type!=TZX_STANDARD && type!=TZX_GENERALIZED);

	if (v.is_valid())
	{
		if (v < 1 || v > 8)
			throw SyntaxError("value must be in range 1 .. 8");

		if (lastbits.is_valid() && v != lastbits)
			throw SyntaxError("lastbits redefined");
	}
	else
	{
		if (v.validity < lastbits.validity)
			throw SyntaxError("value for lastbits decayed");
	}

	has_lastbits = yes;
	lastbits = v;
}

Validity CodeSegment::validity () const
{
	// test whether all segment variables are valid
	// = address, size, flag
	// not checked: dpos, lpos, core[]

	Validity v = min(min(address.validity, size.validity),fillbyte.validity);
	if (has_flag && !no_flagbyte && !checksum_ace) v = min(v,flag.validity);

	if (has_flag && v!=invalid)
	{
		if (has_pause)    v = min(v,pause.validity);
		if (has_lastbits) v = min(v,lastbits.validity);

		v = min(v,pilot.validity());

		for (uint i=0; i<pilotsym.count() && v!=invalid; i++)
			v = min(v,pilotsym[i].validity());

		for (uint i=0; i<datasym.count() && v!=invalid; i++)
			v = min(v,datasym[i].validity());
	}

	return v;
}

void CodeSegment::check_pilot_symbol(uint idx) const
{
	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED);

	Array<Value> const& symbol = pilotsym[idx];

	if (type==TZX_TURBO)
	{
		if (idx >= 2)
			throw SyntaxError("too many pilot symbols: exactly 2 symbols required for TZX turbo blocks");

		if (idx == 0 && symbol.count() != 2)
			throw SyntaxError("tzx-pilot-sym[0]: 2 values required: toggle type + pulse length");

		if (idx == 1 && symbol.count() != 3)
			throw SyntaxError("tzx-pilot-sym[1]: 3 values required: toggle type + 2 pulses");

		if (symbol[0].is_valid() && symbol[0] != 0)
			throw SyntaxError("tzx-pilot-sym[%u][0]: toggle type must be 0", idx);
	}
	else // GENERALIZED:
	{
		if (symbol.count() < 2)
			throw SyntaxError("tzx-pilot-sym[%u]: at least 2 values required: toggle type + pulse length", idx);

		if (symbol[0].is_valid() && symbol[0] > 3)
			throw SyntaxError("tzx-pilot-sym[%u][0]: toggle type must be in range 0 .. 3", idx);
	}

	for (uint i=1; i<symbol.count(); i++)
	{
		cValue& v = symbol[i];
		if (v.is_valid() && v<100)
			throw SyntaxError("tzx-pilot-sym[%u][%u]: pulse too short", idx, i);
		if (v.is_valid() && v>0xffff)
			throw SyntaxError("tzx-pilot-sym[%u][%u]: pulse too long", idx, i);
	}
}

void CodeSegment::check_data_symbol(uint idx) const
{
	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED || type==TZX_PURE_DATA);

	Array<Value> const& symbol = datasym[idx];

	if (type==TZX_TURBO || type==TZX_PURE_DATA)
	{
		if (idx >= 2)
			throw SyntaxError("too many data symbols: exactly 2 symbols required for TZX turbo and pure data blocks");

		if (symbol.count() != 3)
			throw SyntaxError("tzx-data-sym[%u]: 3 values required: toggle type + 2 pulses", idx);

		if (symbol[0].is_valid() && symbol[0] != 0)
			throw SyntaxError("tzx-data-sym[%u][0]: toggle type must be 0", idx);

		Value equal = symbol[1] == symbol[2];
		if (!equal && equal.is_valid())
			throw SyntaxError("tzx-data-sym[%u][1,2]: both pulses must be same length", idx);
	}
	else // GENERALIZED:
	{
		if (symbol.count() < 2)
			throw SyntaxError("tzx-data-sym[%u]: at least 2 values required: toggle type + pulse length", idx);

		if (symbol[0].is_valid() && uint(symbol[0]) > 3)
			throw SyntaxError("tzx-data-sym[%u][0]: toggle type must be in range 0 .. 3", idx);
	}

	for (uint i=1; i<symbol.count(); i++)
	{
		cValue& v = symbol[i];
		if (v.is_valid() && v<100)
			throw SyntaxError("tzx-data-sym[%u][%u]: pulse too short", idx, i);
		if (v.is_valid() && v>0xffff)
			throw SyntaxError("tzx-data-sym[%u][%u]: pulse too long", idx, i);
	}
}

void CodeSegment::addPilotSymbol(Values symbol)
{
	// add a pilot symbol
	// for .tzx-pilot-sym

	if (type==TZX_PURE_DATA) throw SyntaxError("TZX pure data block has no pilot");
	if (type==TZX_STANDARD) throw SyntaxError("TZX standard data block cannot define custom pilot");
	if (no_pilot) throw SyntaxError("pilot=none was defined for this block");
	if (!has_flag) throw SyntaxError("TZX timing must be set on the first segment of the tape block");

	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED);

	if (pilotsym_idx == pilotsym.count())
		pilotsym.append(std::move(symbol));
	else
		pilotsym[pilotsym_idx] = std::move(symbol);

	check_pilot_symbol(pilotsym_idx++);
}

void CodeSegment::addDataSymbol(Values symbol)
{
	// add a data symbol
	// for .tzx-data-sym

	if (type==TZX_STANDARD) throw SyntaxError("TZX standard block cannot define custom pilot");
	if (!has_flag) throw SyntaxError("TZX timing must be set on the first segment of the tape block");

	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED || type==TZX_PURE_DATA);

	if (datasym_idx == datasym.count())
		datasym.append(std::move(symbol));
	else
		datasym[datasym_idx] = std::move(symbol);

	check_data_symbol(datasym_idx++);
}

void CodeSegment::setPilot(Values symbol)
{
	// define pilot and sync
	// for .tzx-pilot

	if (type==TZX_PURE_DATA) throw SyntaxError("TZX pure data block has no pilot");
	if (type==TZX_STANDARD) throw SyntaxError("TZX standard block cannot define custom pilot");
	if (!has_flag) throw SyntaxError("TZX timing must be set on the first segment of the tape block");

	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED);

	if (type==TZX_TURBO)
	{
		if (symbol.count() != 4 ||
			(symbol[0] != 0 && symbol[0].is_valid()) ||
			(symbol[2] != 1 && symbol[2].is_valid()) ||
			(symbol[3] != 1 && symbol[3].is_valid()))
			throw SyntaxError("TZX turbo block: exactly 4 values required: 0, pilot_count, 1, 1");
	}
	else // GENERALIZED
	{
		if (symbol.count() & 1)
			throw SyntaxError("pilot symbols must be defined in pairs: symbol_index + repetitions");
	}

	if (pilot.count())	// compare to old:
	{
		if (symbol.count() != pilot.count())
			throw SyntaxError("pilot redefined");

		for (uint i=0; i<pilot.count(); i++)
		{
			Value v(symbol[i]), p(pilot[i]);
			if (p != v && p.is_valid() && v.is_valid())
				throw SyntaxError("pilot redefined");
			if (v.validity < p.validity)
				throw SyntaxError("tzx-pilot[%u]: value decayed", i);
		}
	}

	for (uint i=0; i<symbol.count(); )	// validate values:
	{
		Value v(symbol[i++]);
		Value w(symbol[i++]);

		if (v.is_valid() && uint(v) >= max(pilotsym.count(),2u))
			throw SyntaxError("tzx-pilot[%u]: reference beyond pilotsym table", i-2);

		if (w.is_valid() && uint(w) > 0xffffu)
			throw SyntaxError("tzx-pilot[%u]: pulse length out of range", i-1);
	}

	pilot = std::move(symbol);
}

void CodeSegment::setNumPilotPulses(cValue& v)
{
	// set number of pilot pulses
	// called from Segment definition

	assert (no_pilot==false);

	if (v<0  && v.is_valid()) throw SyntaxError("number of pilot pulses negative");
	if (v==0 && v.is_valid()) throw SyntaxError(type==CODE || type==TZX_GENERALIZED ?
			"pilot=0 not allowed: use pilot=none, TZX pure data block or .tzx-pilot-sym and .tzx-pilot" :
			"pilot=0 not allowed: use TZX pure data or generalized block");

	Values symbol;
	symbol << Value(0) << v << Value(1) << Value(1);
	setPilot(symbol);
}

void TzxMessageSegment::setDuration (Value v)
{
	check_value(duration,v,"duration",1,255);
	duration = v;
}

void TzxPolaritySegment::setPolarity (Value v)
{
	check_validity(polarity,v,"polarity");
	if (v.is_valid() && v&~1) throw SyntaxError("polarity: value must be 0 (low) or 1 (high)");
	polarity = v;
}

void TzxLoopStartSegment::setRepetitions (Value v)
{
	check_value(repetitions,v,"repetitions",2,0xffff);
	repetitions = v;
}

void TzxPauseSegment::setDuration (Value v)
{
	check_uint16_value(duration,v,"duration");
	duration = v;
}

void TzxPureToneSegment::setPulseLength (Value v)
{
	check_value(pulse_length,v,"pulse length",1,0xffff);
	pulse_length = v;
}

void TzxPureToneSegment::setNumPulses (Value v)
{
	check_value(num_pulses,v,"count",1,0xffff);
	num_pulses = v;
}

Validity TzxPureToneSegment::validity () const
{
	return min(num_pulses.validity,pulse_length.validity);
}

void TzxPulses::appendPulse (Value v)
{
	// up to 255 uint16 pulses can be stored

	if (count==255) throw SyntaxError("too many pulses (max. 255)");
	check_value(pulses[count],v,"pulse",1,0xffff);
	pulses[count++] = v;
}

Validity TzxPulses::validity () const
{
	uint i = count;
	while (i-- && pulses[i].validity == Validity::valid) {}
	i++;
	while (i-- && pulses[i].validity >= Validity::preliminary) {}
	return pulses[i].validity;
}

void TzxPulses::rewind()
{
	count = 0;
}

TzxCswRecording::TzxCswRecording(cstr filename)
:
	TzxSegment(TZX_CSW_RECORDING),
	filename(filename),
	compressed(no),
	raw(no),
	pause(),
	header_size(),
	first_frame(),
	last_frame(),
	sample_rate(0),
	num_channels(0),
	sample_size(0),
	signed_samples(no),
	little_endian(no)
{
	cstr ext = lowerstr(extension_from_path(filename));
	raw = ne(ext,".wav");
}

void TzxCswRecording::setCompression(bool f)
{
	// syntactically compression can only be enabled:
	compressed = f;
}

void TzxCswRecording::setPause(Value v)
{
	check_uint16_value(pause,v,"pause");
	pause = v;
}

void TzxCswRecording::setHeaderSize(Value v)
{
	if(!raw) throw SyntaxError("set header size: raw audio file required");
	check_validity(header_size,v,"header size");
	if (v.is_valid() && v<0) throw SyntaxError("header size is negative");
	header_size = v;
}

void TzxCswRecording::setFirstFrame(Value v)
{
	check_validity(first_frame,v,"first frame");
	if (v.is_valid() && v<0) throw SyntaxError("first frame is negative");
	if (first_frame.is_valid() && last_frame.is_valid() && first_frame > last_frame)
		throw SyntaxError("first frame > last frame");
	first_frame = v;
}

void TzxCswRecording::setLastFrame(Value v)
{
	check_validity(last_frame,v,"last frame");
	if (v.is_valid() && v<0) throw SyntaxError("last frame is negative");
	if (first_frame.is_valid() && last_frame.is_valid() && first_frame>last_frame)
		throw SyntaxError("first frame > last frame");
	last_frame = v;
}

void TzxCswRecording::setSampleRate(uint32 v)
{
	if(!raw) throw SyntaxError("set sample rate: raw audio file required");
	if (v < 8000 || v > 200000) throw SyntaxError("sample rate out of range");
	if (sample_rate && sample_rate != v) throw SyntaxError("sample rate redefined");
	sample_rate = v;
}

void TzxCswRecording::setNumChannels(uint v)
{
	if(!raw) throw SyntaxError("set num channels: raw audio file required");
	if (v < 1 || v > 2) throw SyntaxError("number of channels must be 1 or 2");
	if (num_channels && num_channels != v) throw SyntaxError("number of channels redefined");
	num_channels = v;
}

void TzxCswRecording::setSampleFormat(uint bytes_per_sample, bool signed_samples, bool little_endian)
{
	// set from #TZX as a format string:
	if(!raw) throw SyntaxError("set sample format: raw audio file required");
	sample_size = bytes_per_sample;
	this->signed_samples = signed_samples;
	this->little_endian = little_endian;
}

Validity TzxCswRecording::validity () const
{
	return (pause+first_frame+last_frame+header_size).validity;
}

void TzxHardwareInfo::addInfo(uint8 hwtype, uint8 id, uint8 support)
{
	if (hwinfo.count()==255) throw SyntaxError("too many hardware infos (max. 255)");
	if (hwtype > 0x20) throw SyntaxError("hardware type out of range [0..16]");	// 0..16 used
	if (id > 0x80) throw SyntaxError("hardware ID out of range [0..45]");	// 0..2D used (type=0 computers)
	if (support > 3) throw SyntaxError("hardware info out of range [0..3]");

	hwinfo.append(HwInfo(hwtype,id,support));
}

void TzxArchiveInfo::addArchiveInfo(uint8 id, cstr text)
{
	if (archinfo.count()==255) throw SyntaxError("too many archive infos (max. 255)");
	if (id>16 && id!=255) throw SyntaxError("archive ID out of range [0…16|255]");

	for (cptr p=text; *p; p++)
	{
		if (*p<32 || *p>=127) throw SyntaxError("archive text must be ASCII");
	}

	archinfo.append(ArchInfo(id,text));
}


// -------------------------------------------------------
//			Test Code
// -------------------------------------------------------

IoSequence::IoSequence (const uint8* data, uint count, uint repetitions)
:
	data(nullptr),
	count(count),
	repetitions(repetitions)
{
	this->data = new uint8[count];
	memcpy(this->data,data,count);
}

IoSequence::IoSequence (IoSequence&& q) noexcept
:
	data(q.data),
	count(q.count),
	repetitions(q.repetitions)
{
	new(&q) IoSequence();
}

IoSequence& IoSequence::operator= (IoSequence&& q) noexcept
{
	std::swap(*this,q);
	return *this;
}

IoList::IoList (IoSequence&& q)
:
	iomode(IoValues),
	data(nullptr),
	sequence_idx(0),		// not strictly required: reset in TestSegment.openFile()
	in_sequence_idx(0),		// ""
	repetition(0)			// ""
{
	data = new IoSequences;
	data->append(std::move(q));
}

IoList::IoList (IoMode iomode, cstr filename, uint blocksize)
:
	iomode(iomode),
	fd(-1,filename),
	blocksize(blocksize)
{
	assert(iomode != IoValues);
}

IoList::~IoList()
{
	if (iomode==IoValues) delete data;
	else fd.~FD();
}

IoList::IoList (IoList&& q)
:
	iomode(q.iomode)
{
	if (iomode == IoValues)
	{
		data = q.data; q.data = nullptr;
		sequence_idx = q.sequence_idx;
		in_sequence_idx = q.in_sequence_idx;
		repetition = q.repetition;
	}
	else
	{
		new(&fd) FD(std::move(q.fd));
		blocksize = q.blocksize;
		blockstate = q.blockstate;
		memory_address = q.memory_address;
		block_idx = q.block_idx;
	}
}

IoList& IoList::operator= (IoList&&)
{
	TODO();
	//std::swap(*this,q);		// <-- may not work. tbd.
	//return *this;
}

void IoList::append (IoSequence&& q)
{
	assert(iomode==IoValues);

	data->append(std::move(q));
}

void IoList::openFile()		// befor test
{
	switch(iomode)
	{
	case IoStdIn:
		fd = FD::stdin;
		break;
	case IoStdOut:
		fd = FD::stdout;
		break;
	case IoValues:
		sequence_idx = 0;
		in_sequence_idx = 0;
		repetition = 0;
		break;
	case IoInFile:
	case IoCompareFile:
		fd.open_file_r(fd.filepath());
		break;
	case IoOutFile:
		fd.open_file_w(fd.filepath());
		break;
	case IoAppendFile:
		fd.open_file_a(fd.filepath());
		break;
	case IoBlockDevice:
		fd.open_file_m(fd.filepath());
		blockstate = 0;
		break;
	}
}

void IoList::closeFile() noexcept // after test
{
	switch(iomode)
	{
	case IoStdIn:
	case IoStdOut:
	case IoValues:
		break;
	default:
		fd.close_file(no); // don't throw
		break;
	}
}

bool IoList::isAtEnd()		// after test
{
	switch(iomode)
	{
	default:
		return yes;
	case IoInFile:
	case IoCompareFile:
		return fd.is_at_eof();
	case IoValues:
		while (sequence_idx < data->count())
		{
			IoSequence& seq = (*data)[sequence_idx];

			if (in_sequence_idx >= seq.count)
			{
				in_sequence_idx = 0;
				if (seq.count == 0) { sequence_idx++; continue; }	// empty sequence!
				if (seq.repetitions == 0) return yes;				// 0 = '*' = unlimited
				if (++repetition >= seq.repetitions) { repetition=0; sequence_idx++; continue; }
			}
			return no;	// some data left to read
		}
		return yes;		// no data left
	}
}

uint8 IoList::inputByte()	// during test
{
	switch (iomode)
	{
	case IoStdOut:
	case IoBlockDevice:
	case IoOutFile:
	case IoAppendFile:
	case IoCompareFile:
		IERR();
	case IoStdIn:
		return fd.data_available() ? fd.read_uchar() : 0;
	case IoInFile:
		return fd.read_uchar();
	case IoValues:
		while (sequence_idx < data->count())
		{
			IoSequence& seq = (*data)[sequence_idx];

			if (in_sequence_idx >= seq.count)
			{
				in_sequence_idx = 0;
				if (seq.count == 0) { sequence_idx++; continue; } // handle empty sequence!
				if (seq.repetitions != 0) // 0 = '*' = unlimited
				{
					if (++repetition >= seq.repetitions) { repetition=0; sequence_idx++; continue; }
				}
			}

			return seq.data[in_sequence_idx++];
		}
		throw AnyError("end of input data");
	}
	IERR();
}

void IoList::outputByte (uint8 c, uint8* core) // during test
{
	switch(iomode)
	{
	case IoStdIn:
	case IoInFile:
		IERR();
	case IoOutFile:
	case IoAppendFile:
	case IoStdOut:
		fd.write_uchar(c);
		return;
	case IoCompareFile:
	{
		uint8 c2 = fd.read_uchar();
		if (c == c2) return;
		throw AnyError("compare failed: expected 0x%02x",c2);
	}
	case IoBlockDevice:
	{
		switch(blockstate++)
		{
		case 0:	block_idx = c; return;
		case 1: block_idx += uint(c) << 8; return;
		case 2: memory_address = c; return;
		case 3: memory_address += uint(c) << 8; return;
		default:
			if (c==0xE5) // read
			{
				if (memory_address+blocksize > 0x10000)
					throw AnyError("block end beyond ram end");
				fd.seek_fpos(block_idx * blocksize);
				fd.read_bytes(core+memory_address,blocksize);
				return;
			}
			if (c==0xEE) // write
			{
				if (memory_address+blocksize > 0x10000)
					throw AnyError("block end beyond ram end");
				fd.seek_fpos(block_idx * blocksize);
				fd.write_bytes(core+memory_address,blocksize);
				return;
			}
			throw AnyError("expected direction flag $E5 or $EE");
		}
	}
	case IoValues:
		while (sequence_idx < data->count())
		{
			IoSequence& seq = (*data)[sequence_idx];

			if (in_sequence_idx >= seq.count)
			{
				in_sequence_idx = 0;
				if (seq.count == 0)
				{
					if (seq.repetitions == 0) return;	// '*' at end -> accept any data
					sequence_idx++; continue;			// empty sequence
				}
				if (seq.repetitions != 0) // 0 = '*'
				{
					if (++repetition >= seq.repetitions) { repetition=0; sequence_idx++; continue; }
				}
			}

			uchar c2 = seq.data[in_sequence_idx++];
			if (c == c2) return;
			throw AnyError("compare failed: expected 0x%02x",c2);
		}
		throw AnyError("end of output compare data");
	}
}

TestSegment::TestSegment (cstr _name, uint8 _fillbyte)
:
	CodeSegment(_name,TEST,_fillbyte)
{
	is_code = false;
	is_test = true;
}

TestSegment::~TestSegment ()
{}

Validity TestSegment::validity () const
{
	// check this segment for validity.
	// must be called before rewind(), because after rewind() the lists all become valid.

	// we also replace some values with their default values if they were not set be the source.
	// these values are therefore mutable because validity() is a const method.
	// this will only happen after pass 1.

	// overwrite (invalid) unset values with (valid) defaults: (pass 1 only)
	if (cpu_clock.value == -1) cpu_clock = cpu_unlimited;
	if (int_per_sec.value == -1) int_per_sec = no_interrupts;
	if (int_ack_byte.value == -1) int_ack_byte = floating_bus_byte;
	if (timeout_ms.value == -1) timeout_ms = no_timeout;

	if (!expectations_valid) return invalid;
	if (!iodata_valid) return invalid;
	Validity v = CodeSegment::validity();
	if (v==invalid) return v;

	v = min(v, cpu_clock.validity);
	v = min(v, int_per_sec.validity);
	v = min(v, int_ack_byte.validity);
	v = min(v, timeout_ms.validity);

	return v;
}

void TestSegment::rewind()
{
	CodeSegment::rewind();

	// rewind the segment for the next compilation pass.
	// we purge our lists, entries will be added again as in pass 1.

	iodata_valid = yes;
	inputdata.purge();
	outputdata.purge();

	expectations_valid = yes;
	expectations.shrink(0);		// instead of purge: avoid reallocation
}

void TestSegment::setCpuClock (Value v)
{
	// set the cpu clock for the test run.
	// cpu_clock = 0 means run at unlimited speed, which is the default.

	check_value(cpu_clock, v, ".test-clock", 0, 1000000000);
	cpu_clock = v;
}

void TestSegment::setIntPerSec (Value v)
{
	// set the timer interrupt frequency during test run.
	// int_frequ = 0 means no interrupts, which is the default.
	// int_per_sec stores in_per sec (1..1000) or cc_per_int (1001++)

	check_value(int_per_sec, v, ".test-int", 0, 1000);
	int_per_sec = v;
}

void TestSegment::setCcPerInt (Value v)
{
	// set the timer interrupt frequency during test run.
	// int_per_sec stores in_per sec (1..1000) or cc_per_int (1001++)

	check_value(int_per_sec, v, ".test-int", 1001, 99999999);
	int_per_sec = v;
}

void TestSegment::setIntAckByte (Value v)
{
	// set the bus byte during an interrupt acknowledge cycle
	// the default value is 255.

	check_value(int_ack_byte, v, ".test-int-ack", 0, 255);
	int_ack_byte = v;
}

void TestSegment::setTimeoutMsec (Value v)
{
	// set a timeout for the test in milli seconds
	// if the test is preempted by the timeout an error is set.
	// timeout = 0 means no timeout, which is the default.

	check_value(timeout_ms, v, ".test-timeout", 0, 1*60*60*1000);	// 1h
	timeout_ms = v;
}

void TestSegment::setExpectedCcMin (SourceLine* q, Value v)
{
	// set minimum value for the cpu cycle counter.
	// after running the test code the cc must higher than or equal or an error is set.
	// cc = 0 indicates no limit, which is the default.

	expectations_valid = expectations_valid && v.is_valid() && address.is_valid() && dpos.is_valid();
	check_value(v, "cc", 0, 0x7fffffff);
	expectations << Expectation("cc_min",v,address+dpos,q);
}

void TestSegment::setExpectedCcMax (SourceLine* q, Value v)
{
	// set maximum value for the cpu cycle counter.
	// after running the test code the cc must less than or equal or an error is set.
	// cc = 0 indicates no limit, which is the default.

	expectations_valid = expectations_valid && v.is_valid() && address.is_valid() && dpos.is_valid();
	check_value(v, "cc", 0, 0x7fffffff);
	expectations << Expectation("cc_max",v,address+dpos,q);
}

void TestSegment::setExpectedCc (SourceLine* q, Value v)
{
	// set the expected value for the cpu cycle counter.
	// after running the test code the cc must match exactly or an error is set.
	// cc = 0 indicates no limit, which is the default.

	expectations_valid = expectations_valid && v.is_valid() && address.is_valid() && dpos.is_valid();
	check_value(v, "cc", 0, 0x7fffffff);
	expectations << Expectation("cc",v,address+dpos,q);
}

void TestSegment::setExpectedRegisterValue (SourceLine* q, cstr regname, Value v)
{
	// set the expected value for register to the current set of expectations.
	// after running the test code the register value will be compared against
	// the expected value and an error is added if the value does not match.

	regname = lowerstr(regname);

	int min,max;
	Z80Registers::getLimits(regname,min,max);

	if (max == 0)
		throw SyntaxError("%s: not a register name", regname);

	if (v.is_valid() && (v.value<min || v.value>max))
		throw SyntaxError("%s: value is not in range[%i .. %i]", regname, min, max);

	expectations_valid = expectations_valid && v.is_valid() && address.is_valid() && dpos.is_valid();
	expectations << Expectation(regname,v,address+dpos,q);
}

static const cstr ioModeNames[] = {
	"list of values", "stdin", "stdout", "input file", "output file",
	"output file (append)", "output file (compare)", "block device"};

static uint16 validated_io_address (cValue& addr) // helper
{
	if (addr != uint16(addr))
		throw SyntaxError("address not in range[0 .. $ffff]");
	return uint16(addr);
}

void TestSegment::setInputData (cValue& ioaddr, IoSequence&& iodata)
{
	// set or add input data for input from ioaddr.
	// while running the test code input data for this port is read from this data.
	// the data has some control characters for repetitions. see documentation.

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (inputdata.contains(addr))
	{
		IoList& list = inputdata[addr];

		if (list.iomode != IoValues)
			throw SyntaxError("in($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		if (list.data->count()!=0 && (*list.data)[0].repetitions == 0)
			throw SyntaxError("unexpected data after unlimited repetitions set on previous block");

		list.append(std::move(iodata));
	}
	else
	{
		inputdata.add(addr,std::move(iodata));
	}
}

void TestSegment::setOutputData (cValue& ioaddr, IoSequence&& iodata)
{
	// set or add output compare data for output to ioaddr
	// while running the test code output to ioaddr will be compared with this data.
	// the test is aborted and an error is added if a value does not match.
	// the data has some control characters for repetitions. see documentation.

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (outputdata.contains(addr))
	{
		IoList& list = outputdata[addr];

		if (list.iomode != IoValues)
			throw SyntaxError("out($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		if (list.data->count()!=0 && (*list.data)[0].repetitions == 0)
			throw SyntaxError("unexpected data after unlimited repetitions set on previous block");

		list.append(std::move(iodata));
	}
	else
	{
		outputdata.add(addr,std::move(iodata));
	}
}

void TestSegment::setConsole (cValue& ioaddr)
{
	// assign io address to console
	// in() inputs from stdin
	// out() writes to stdout

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (inputdata.contains(addr))
	{
		IoList& list = inputdata[addr];
		if (list.iomode != IoStdIn)
			throw SyntaxError("in($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		return;
	}
	if (outputdata.contains(addr))
	{
		IoList& list = inputdata[addr];
		assert(list.iomode != IoStdOut);
		throw SyntaxError("out($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
	}

	inputdata.add(addr,IoList(IoStdIn,nullptr));
	outputdata.add(addr,IoList(IoStdOut,nullptr));
}

void TestSegment::setBlockDevice (cValue& ioaddr, cstr filename, cValue& blocksize)
{
	// assign io address to file for block i/o

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (!blocksize.is_valid())
		throw SyntaxError("blocksize must be valid in pass 1");
	if (blocksize < 1 || blocksize > 0x8000)
		throw SyntaxError("invalid block size");

	if (outputdata.contains(addr))
	{
		IoList& list = outputdata[addr];
		if (list.iomode != IoBlockDevice)
			throw SyntaxError("out($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		if (ne(list.fd.filename(),filename))
			throw SyntaxError("in($%04x): block file redefined", addr);
		if (uint(blocksize) != list.blocksize)
			throw SyntaxError("in($%04x): block size redefined", addr);
		return;
	}

	outputdata.add(addr,IoList(IoBlockDevice,filename,uint(blocksize)));
}

void TestSegment::setInputFile (cValue& ioaddr, cstr filename, IoMode mode)
{
	// assign in() address to data file
	// mode may be File only.

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (inputdata.contains(addr))
	{
		IoList& list = inputdata[addr];
		if (list.iomode != mode)
			throw SyntaxError("in($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		if (ne(list.fd.filename(),filename))
			throw SyntaxError("in($%04x): input file redefined", addr);
		return;
	}

	inputdata.add(addr,IoList(mode,filename));
}

void TestSegment::setOutputFile (cValue& ioaddr, cstr filename, IoMode mode)
{
	// assign out() address to data file
	// mode may be File, AppendFile or CompareFile.

	if (!ioaddr.is_valid()) { iodata_valid=no; return; }
	uint16 addr = validated_io_address(ioaddr);

	if (outputdata.contains(addr))
	{
		IoList& list = outputdata[addr];
		if (list.iomode != mode)
			throw SyntaxError("out($%04x): mode is already set to %s", addr, ioModeNames[list.iomode]);
		if (ne(list.fd.filename(),filename))
			throw SyntaxError("out($%04x): output file redefined", addr);
		return;
	}

	outputdata.add(addr,IoList(mode,filename));
}

void TestSegment::openFiles()	// before test
{
	for (uint i = 0; i < inputdata.count(); i++)
	{
		try
		{
			inputdata.getItems()[i].openFile();
		}
		catch (AnyError& e)
		{
			throw AnyError(e.error(), usingstr("in($%04x): %s",inputdata.getKeys()[i],e.what()));
		}
	}
	for (uint i = 0; i < outputdata.count(); i++)
	{
		try
		{
			outputdata.getItems()[i].openFile();
		}
		catch (AnyError& e)
		{
			throw AnyError(e.error(), usingstr("out($%04x): %s",outputdata.getKeys()[i],e.what()));
		}
	}
}

void TestSegment::closeFiles() noexcept // after test
{
	for (uint i = 0; i < inputdata.count(); i++)
	{
		inputdata.getItems()[i].closeFile();
	}
	for (uint i = 0; i < outputdata.count(); i++)
	{
		outputdata.getItems()[i].closeFile();
	}
}

void TestSegment::checkAllBytesRead()	// after test
{
	cstr e = nullptr;

	for (uint i = 0; i < inputdata.count(); i++)
	{
		if (!inputdata.getItems()[i].isAtEnd())
			e = catstr(e,usingstr(",$%04x",inputdata.getKeys()[i]));
	}
	if (!e) return; // ok
	throw AnyError("in(%s): not all bytes read",e+1);
}

void TestSegment::checkAllBytesWritten()	// after test
{
	cstr e = nullptr;

	for (uint i = 0; i < outputdata.count(); i++)
	{
		if (!outputdata.getItems()[i].isAtEnd())
			e = catstr(e,usingstr(",$%04x",outputdata.getKeys()[i]));
	}
	if (!e) return; // ok
	throw AnyError("out(%s): not all bytes written",e+1);
}

uint8 TestSegment::inputByte (uint16 addr)	// during test
{
	IoList* iolist = inputdata.find(uint8(addr));
	if (iolist) return iolist->inputByte();
	iolist = inputdata.find(addr);
	if (iolist) return iolist->inputByte();
	else throw AnyError("unexpected io address (no .test-in data)");
}

void TestSegment::outputByte (uint16 addr, uint8 byte, uint8* memory)	// during test
{
	IoList* iolist = outputdata.find(uint8(addr));
	if (iolist) { iolist->outputByte(byte,memory); return; }
	iolist = outputdata.find(addr);
	if (iolist) iolist->outputByte(byte,memory);
	else throw AnyError("unexpected io address (no .test-out data)");
}



// -------------------------------------------------------
//			Segments[]
// -------------------------------------------------------

DataSegment* Segments::find (cstr name) const
{
	for (uint i=0; i<count(); i++)
	{
		if (auto s = dynamic_cast<DataSegment*>(data[i].ptr()))
			if (eq(s->name,name)) return s;
	}
	return nullptr;
}


// -------------------------------------------------------
//			Collections
// -------------------------------------------------------

DataSegments::DataSegments (Segments const& segments)
{
	// extract Code- and DataSegments from source

	for (uint i=0; i<segments.count(); i++)
	{
		if (auto s = dynamic_cast<DataSegment*>(segments[i].ptr()))
		{
			append(s);
		}
	}
}

CodeSegments::CodeSegments (Segments const& segments)
{
	// extract CODE Segments from source
	// incl. TZX segments, but excl. TEST

	for (uint i=0; i<segments.count(); i++)
	{
		if (auto s = dynamic_cast<CodeSegment*>(segments[i].ptr()))
		{
			if (s->isCode()) append(s);
		}
	}
}

void CodeSegments::checkNoFlagsSet () const throws
{
	for (uint i=0; i<count(); i++)
	{
		auto s = data[i];
		if (s->has_flag) throw SyntaxError("segment %s must not have flag set", s->name);
	}
}

uint32 CodeSegments::totalCodeSize() const
{
	uint32 sz = 0;
	for (uint i=0; i<count(); i++)
	{
		sz += data[i]->outputSize();
	}
	return sz;
}

TzxSegments::TzxSegments (Segments const& segments)
{
	for (uint i=0; i<segments.count(); i++)
	{
		if( auto s = dynamic_cast<TzxSegment*>(segments[i].ptr()))
		{
			append(s);
		}
	}
}

TestSegments::TestSegments (Segments const& segments)
{
	for (uint i=0; i<segments.count(); i++)
	{
		if( auto s = dynamic_cast<TestSegment*>(segments[i].ptr()))
		{
			append(s);
		}
	}
}



























