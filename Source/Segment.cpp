/*	Copyright  (c)	Günter Woigk 2014 - 2019
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


bool isData(SegmentType t)
{
	return t==DATA;
}

bool isCode(SegmentType t)
{
	return t==CODE || t==TZX_STANDARD || t==TZX_TURBO || t==TZX_PURE_DATA || t==TZX_GENERALIZED;
}


// -------------------------------------------------------
//			Segments[]
// -------------------------------------------------------

DataSegments::DataSegments (Segments const& segments)
{
	// extract Code- and DataSegments from source

	for (uint i=0; i<segments.count(); i++)
	{
		if (auto s = dynamic_cast<DataSegment*>(segments[i].ptr()))
			append(s);
	}
}

CodeSegments::CodeSegments (Segments const& segments)
{
	// extract CodeSegments from source

	for (uint i=0; i<segments.count(); i++)
	{
		if (auto s = dynamic_cast<CodeSegment*>(segments[i].ptr()))
			append(s);
	}
}

void CodeSegments::checkNoFlagsSet () const throws
{
	for (uint i=0; i<count(); i++)
	{
		auto s = data[i];
		if (s->has_flag) throw syntax_error("segment %s must not have flag set", s->name);
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
//			Segment
// -------------------------------------------------------

// protected:
Segment::Segment (SegmentType type, cstr name)
:
	type(type),
	name(name),
	is_data(no),
	is_code(no),
	is_tzx(no),
	dpos()
{}

// protected:
DataSegment::DataSegment (cstr name, SegmentType type, uint8 fillbyte , bool relocatable, bool resizable)
:
	Segment(type,name),
	fillbyte(fillbyte),
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
DataSegment::DataSegment (cstr name, uint8 fillbyte, bool relocatable, bool resizable)
:
	Segment(DATA,name),
	fillbyte(fillbyte),
	relocatable(relocatable),
	resizable(resizable),
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
CodeSegment::CodeSegment (cstr name, SegmentType type, uint8 fillbyte , bool relocatable, bool resizable)
:
	DataSegment(name,type,fillbyte,relocatable,resizable),
	flag(),
	pause(),
	lastbits(),
	has_flag(no),
	has_pause(no),
	has_lastbits(no),
	no_flagbyte(no),
	no_checksum(no),
	no_pilot(type==TZX_PURE_DATA),
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

void Segment::throw_data_segment_required () throws { throw syntax_error("#data segment required"); }
void Segment::throw_code_segment_required () throws { throw syntax_error("#code or #data segment required"); }

void DataSegment::rewind ()
{
	// rewind dpos to offset 0
	// used at start of next assembly pass
	// => rewinds dpos
	// => sets logical address to physical address
	// => preserves size
	// => preserves segment address

	assert(!resizable || size==dpos || dpos==0 || !dpos.is_valid() || !size.is_valid());

	dpos = 0;
	lpos = address;
}

void CodeSegment::rewind ()
{
	pilotsym_idx = datasym_idx = 0;
	DataSegment::rewind();
}

void DataSegment::setAddress (Value const& new_address) throws
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
			throw syntax_error("segment %s address redefined", name);
		}

		if (uint32(new_address) > 0x10000)
		{
			throw syntax_error("segment %s address out of range: %i", name, int(new_address));
		}

		if (size.is_valid() && size + new_address > 0x10000)
		{
			throw syntax_error(	"segment %s: address+size out of range: %i + %i = %i",
								name, int(new_address), int(size), int(size+new_address) );
		}
	}

	if (new_address.validity < address.validity)
		throw syntax_error("segment %s address decayed", name);

	lpos = address = new_address;
	dpos = 0;
}

void DataSegment::setSize (Value const& newsize) throws
{
	// set segment size
	// should be set between assembly passes
	// does not clear the 'resizable' flag
	// rewinds the segment

	if (newsize.is_valid())
	{
		if (size.is_valid() && size != newsize)
			throw syntax_error("segment %s size redefined",name);

		if (uint32(newsize) > 0x10000)
			throw syntax_error("segment %s size out of range: %i",name,int(size));

		if (dpos.is_valid() && dpos > newsize)
			throw syntax_error("segment %s overflow",name);

		if (address.is_valid() && address + newsize > 0x10000 )
			throw syntax_error( "segment %s: address+size out of range: %i + %i = %i",
								name, int(address), int(newsize), int(address+newsize) );
	}

	if (newsize.validity < size.validity)
		throw syntax_error("segment %s size decayed",name);

	size = newsize;
	dpos = 0;
	lpos = address;
}

void DataSegment::setOrigin (Value const& address) throws
{
	// set "logical" code address
	// valid range: -0x8000 … +0xFFFF
	// does not move dpos
	// validity may degrade e.g. after .dephase

	if (address.is_valid())
	{
		if (address < -0x8000 || address > 0xFFFF)
			throw syntax_error("address out of range");
	}

	lpos.set(address);
}



// -------------------------------------------------------
//			Store Code
// -------------------------------------------------------

void CodeSegment::store (int byte) throws
{
	if (dpos<0x10000) core[dpos] = byte;

	dpos.value++;
	lpos.value++;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw fatal_error("segment overflow");
}

void Segment::storeOffset (Value const& offset) throws
{
	if (offset.is_valid())
	{
		if (int16(offset) != int8(offset))
			throw syntax_error("offset value out of range");
	}
	store(offset);
}

void Segment::storeByte (Value const& byte) throws
{
	// store signed or unsigned byte
	// validates byte
	// only check int16 range, so that $FF00 + $1xx works

	if (byte.is_valid())
	{
		if (int16(byte) < -0x80 || int16(byte) > 0xFF)
			throw syntax_error("byte value out of range");
	}
	store(byte);
}

void Segment::storeWord (int n) throws
{
	// store 2 bytes (z80 byte order: lsb first)

	store(n);
	store(n>>8);
}

void CodeSegment::storeBlock (cptr data, uint n) throws
{
	// store block of raw bytes

	if (n>0x10000) throw syntax_error("size > 0x10000");

	if (dpos<0x10000) memcpy(&core[dpos], data, min(n,0x10000u-dpos));

	lpos += n;
	dpos += n;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw syntax_error("segment overflow");
}

void DataSegment::skipExistingData (int n) throws
{
	// skip over existing data in pass 2++:
	// in case of an error

	if (n < 0) throw syntax_error("size < 0");
	if (n > 0x10000) throw syntax_error("size > 0x10000");

	lpos += n;
	dpos += n;

	if (dpos.value > size.value && dpos.is_valid() && size.is_valid())
		throw syntax_error("segment overflow");
}

void Segment::storeHexBytes (cptr data, uint n) throws
{
	// store block of bytes
	// source bytes are stuffed as hex
	// n = bytes to stuff   ( => 2*n hex digits )

	if (n > 0x10000) throw syntax_error("size > 0x10000");

	while (n--)
	{
		char c = *data++;
		if (!is_hex_digit(c)) throw syntax_error("only hex characters allowed: '%c'",c);
		char d = *data++;
		if (!is_hex_digit(d)) throw syntax_error("only hex characters allowed: '%c'",d);

		store((hex_digit_value(c)<<4) + hex_digit_value(d));
	}
}

void DataSegment::storeSpace (Value const& sz, int c) throws
{
	// store space

	if (sz.is_valid())
	{
		if (sz<0) throw syntax_error("gap size < 0");
		if (sz>0x10000) throw syntax_error("gap size > 0x10000");
	}

	//if (uint8(c)!=fillbyte && is_data) throw syntax_error("illegal fillbyte in data segment");

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

	if (auto s = dynamic_cast<CodeSegment*>(this))
		if (dpos<0x10000) memset(&s->core[dpos], c, min(sz.value, 0x10000-dpos));

	lpos += sz;
	dpos += sz;

	if (dpos > size && dpos.is_valid() && size.is_valid())
		throw syntax_error("segment overflow");
}

void DataSegment::storeSpace (Value const& sz) throws
{
	// store space with default fillbyte

	storeSpace(sz,fillbyte);
}

void DataSegment::storeSpaceUpToAddress (Value const& addr) throws
{
	storeSpace(addr-lpos);
}

Validity DataSegment::validity () const
{
	// test whether all segment variables are valid
	// = address, size, flag
	// not checked: dpos, lpos, core[]

	Validity rval = min(address.validity, size.validity);
	return rval;
}

void DataSegment::store (int c) throws
{
	if (c != fillbyte) throw_code_segment_required();
	else storeSpace(Value(1));
}

void DataSegment::storeBlock (cptr bu, uint n) throws
{
	for (cptr p = bu; p<bu+n; p++)
	{
		if (*p++ != fillbyte) throw_code_segment_required();
	}
	storeSpace(Value(n));
}

void CodeSegment::setFlag (Value const& v) throws
{
	// Set segment flag
	// used for .z80 and .tap files
	// may be set any time
	// should be set from the #code directive

	if (no_flagbyte)
		throw syntax_error("flag is already set to 'NONE'");

	if (v.is_valid())
	{
		if (v != uint8(v))
			throw syntax_error("value out of range");

		if (flag.is_valid() && v != flag)
			throw syntax_error("segment %s flag redefined",name);
	}
	else
	{
		if (v.validity < flag.validity)
			throw syntax_error("segment %s flag decayed",name);
	}

	has_flag = yes;
	flag.set(v);
}

void CodeSegment::setNoFlag()
{
	if (has_flag && !no_flagbyte)
		throw syntax_error("flag is already set");

	has_flag = yes;
	no_flagbyte = yes;
}

void CodeSegment::NoChecksum()
{
	no_checksum = yes;
}

void CodeSegment::setPause(Value const& v)
{
	if (v.is_valid())
	{
		if (v != uint16(v))
			throw syntax_error("value out of range");

		if (pause.is_valid() && v != pause)
			throw syntax_error("pause redefined");
	}
	else
	{
		if (v.validity < pause.validity)
			throw syntax_error("value for pause decayed");
	}

	has_pause = yes;
	pause = v;
}

void CodeSegment::setLastBits(Value const& v)
{
	assert(type!=TZX_STANDARD && type!=TZX_GENERALIZED);

	if (v.is_valid())
	{
		if (v < 1 || v > 8)
			throw syntax_error("value must be in range 1 .. 8");

		if (lastbits.is_valid() && v != lastbits)
			throw syntax_error("lastbits redefined");
	}
	else
	{
		if (v.validity < lastbits.validity)
			throw syntax_error("value for lastbits decayed");
	}

	has_lastbits = yes;
	lastbits = v;
}

Validity CodeSegment::validity () const
{
	// test whether all segment variables are valid
	// = address, size, flag
	// not checked: dpos, lpos, core[]

	Validity v = min(address.validity, size.validity);
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
			throw syntax_error("too many pilot symbols: exactly 2 symbols required for TZX turbo blocks");

		if (idx == 0 && symbol.count() != 2)
			throw syntax_error("tzx-pilot-sym[0]: 2 values required: toggle type + pulse length");

		if (idx == 1 && symbol.count() != 3)
			throw syntax_error("tzx-pilot-sym[1]: 3 values required: toggle type + 2 pulses");

		if (symbol[0].is_valid() && symbol[0] != 0)
			throw syntax_error("tzx-pilot-sym[%u][0]: toggle type must be 0", idx);
	}
	else // GENERALIZED:
	{
		if (symbol.count() < 2)
			throw syntax_error("tzx-pilot-sym[%u]: at least 2 values required: toggle type + pulse length", idx);

		if (symbol[0].is_valid() && symbol[0] > 3)
			throw syntax_error("tzx-pilot-sym[%u][0]: toggle type must be in range 0 .. 3", idx);
	}

	for (uint i=1; i<symbol.count(); i++)
	{
		Value const& v = symbol[i];
		if (v.is_valid() && v<100)
			throw syntax_error("tzx-pilot-sym[%u][%u]: pulse too short", idx, i);
		if (v.is_valid() && v>0xffff)
			throw syntax_error("tzx-pilot-sym[%u][%u]: pulse too long", idx, i);
	}
}

void CodeSegment::check_data_symbol(uint idx) const
{
	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED || type==TZX_PURE_DATA);

	Array<Value> const& symbol = datasym[idx];

	if (type==TZX_TURBO || type==TZX_PURE_DATA)
	{
		if (idx >= 2)
			throw syntax_error("too many data symbols: exactly 2 symbols required for TZX turbo and pure data blocks");

		if (symbol.count() != 3)
			throw syntax_error("tzx-data-sym[%u]: 3 values required: toggle type + 2 pulses", idx);

		if (symbol[0].is_valid() && symbol[0] != 0)
			throw syntax_error("tzx-data-sym[%u][0]: toggle type must be 0", idx);

		Value equal = symbol[1] == symbol[2];
		if (!equal && equal.is_valid())
			throw syntax_error("tzx-data-sym[%u][1,2]: both pulses must be same length", idx);
	}
	else // GENERALIZED:
	{
		if (symbol.count() < 2)
			throw syntax_error("tzx-data-sym[%u]: at least 2 values required: toggle type + pulse length", idx);

		if (symbol[0].is_valid() && uint(symbol[0]) > 3)
			throw syntax_error("tzx-data-sym[%u][0]: toggle type must be in range 0 .. 3", idx);
	}

	for (uint i=1; i<symbol.count(); i++)
	{
		Value const& v = symbol[i];
		if (v.is_valid() && v<100)
			throw syntax_error("tzx-data-sym[%u][%u]: pulse too short", idx, i);
		if (v.is_valid() && v>0xffff)
			throw syntax_error("tzx-data-sym[%u][%u]: pulse too long", idx, i);
	}
}

void CodeSegment::addPilotSymbol(Values symbol)
{
	// add a pilot symbol
	// for .tzx-pilot-sym

	if (type==TZX_PURE_DATA) throw syntax_error("TZX pure data block has no pilot");
	if (type==TZX_STANDARD) throw syntax_error("TZX standard data block cannot define custom pilot");
	if (no_pilot) throw syntax_error("pilot=none was defined for this block");
	if (!has_flag) throw syntax_error("TZX timing must be set on the first segment of the tape block");

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

	if (type==TZX_STANDARD) throw syntax_error("TZX standard block cannot define custom pilot");
	if (!has_flag) throw syntax_error("TZX timing must be set on the first segment of the tape block");

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

	if (type==TZX_PURE_DATA) throw syntax_error("TZX pure data block has no pilot");
	if (type==TZX_STANDARD) throw syntax_error("TZX standard block cannot define custom pilot");
	if (!has_flag) throw syntax_error("TZX timing must be set on the first segment of the tape block");

	assert(type==CODE || type==TZX_TURBO || type==TZX_GENERALIZED);

	if (type==TZX_TURBO)
	{
		if (symbol.count() != 4 ||
			(symbol[0] != 0 && symbol[0].is_valid()) ||
			(symbol[2] != 1 && symbol[2].is_valid()) ||
			(symbol[3] != 1 && symbol[3].is_valid()))
			throw syntax_error("TZX turbo block: exactly 4 values required: 0, pilot_count, 1, 1");
	}
	else // GENERALIZED
	{
		if (symbol.count() & 1)
			throw syntax_error("pilot symbols must be defined in pairs: symbol_index + repetitions");
	}

	if (pilot.count())	// compare to old:
	{
		if (symbol.count() != pilot.count())
			throw syntax_error("pilot redefined");

		for (uint i=0; i<pilot.count(); i++)
		{
			Value v(symbol[i]), p(pilot[i]);
			if (p != v && p.is_valid() && v.is_valid())
				throw syntax_error("pilot redefined");
			if (v.validity < p.validity)
				throw syntax_error("tzx-pilot[%u]: value decayed", i);
		}
	}

	for (uint i=0; i<symbol.count(); )	// validate values:
	{
		Value v(symbol[i++]);
		Value w(symbol[i++]);

		if (v.is_valid() && uint(v) >= max(pilotsym.count(),2u))
			throw syntax_error("tzx-pilot[%u]: reference beyond pilotsym table", i-2);

		if (w.is_valid() && uint(w) > 0xffffu)
			throw syntax_error("tzx-pilot[%u]: pulse length out of range", i-1);
	}

	pilot = std::move(symbol);
}

void CodeSegment::setNumPilotPulses(Value const& v)
{
	// set number of pilot pulses
	// called from Segment definition

	assert (no_pilot==false);

	if (v<0  && v.is_valid()) throw syntax_error("number of pilot pulses negative");
	if (v==0 && v.is_valid()) throw syntax_error(type==CODE || type==TZX_GENERALIZED ?
			"pilot=0 not allowed: use pilot=none, TZX pure data block or .tzx-pilot-sym and .tzx-pilot" :
			"pilot=0 not allowed: use TZX pure data or generalized block");

	Values symbol;
	symbol << Value(0) << v << Value(1) << Value(1);
	setPilot(symbol);
}

static void check_validity(Value old, Value nju, cstr name) // helper
{
	if (old.is_valid() && nju.is_valid() && old!=nju)
		throw syntax_error("%s: value redefined",name);
	if (nju.validity < old.validity)
		throw syntax_error("%s: value decayed",name);
}
static void check_value(Value old, Value nju, cstr name, int min, int max) // helper
{
	check_validity(old,nju,name);
	if (nju.is_valid() && (nju<min || nju>max))
		throw syntax_error("%s: value not in range[%i .. %i]",name,min,max);
}
static void check_uint16_value(Value old, Value nju, cstr name) // helper
{
	check_validity(old,nju,name);
	if (nju.is_valid() && nju!=uint16(nju))
		throw syntax_error("%s: value not in range[0 .. $ffff]",name);
}

void TzxMessageSegment::setDuration (Value v)
{
	check_value(duration,v,"duration",1,255);
	duration = v;
}

void TzxPolaritySegment::setPolarity (Value v)
{
	check_validity(polarity,v,"polarity");
	if (v.is_valid() && v&~1) throw syntax_error("polarity: value must be 0 (low) or 1 (high)");
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

	if (count==255) throw syntax_error("too many pulses (max. 255)");
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
	if(!raw) throw syntax_error("set header size: raw audio file required");
	check_validity(header_size,v,"header size");
	if (v.is_valid() && v<0) throw syntax_error("header size is negative");
	header_size = v;
}

void TzxCswRecording::setFirstFrame(Value v)
{
	check_validity(first_frame,v,"first frame");
	if (v.is_valid() && v<0) throw syntax_error("first frame is negative");
	if (first_frame.is_valid() && last_frame.is_valid() && first_frame > last_frame)
		throw syntax_error("first frame > last frame");
	first_frame = v;
}

void TzxCswRecording::setLastFrame(Value v)
{
	check_validity(last_frame,v,"last frame");
	if (v.is_valid() && v<0) throw syntax_error("last frame is negative");
	if (first_frame.is_valid() && last_frame.is_valid() && first_frame>last_frame)
		throw syntax_error("first frame > last frame");
	last_frame = v;
}

void TzxCswRecording::setSampleRate(int32 v)
{
	if(!raw) throw syntax_error("set sample rate: raw audio file required");
	if (v < 8000 || v > 200000) throw syntax_error("sample rate out of range");
	if (sample_rate && sample_rate != v) throw syntax_error("sample rate redefined");
	sample_rate = v;
}

void TzxCswRecording::setNumChannels(uint v)
{
	if(!raw) throw syntax_error("set num channels: raw audio file required");
	if (v < 1 || v > 2) throw syntax_error("number of channels must be 1 or 2");
	if (num_channels && num_channels != v) throw syntax_error("number of channels redefined");
	num_channels = v;
}

void TzxCswRecording::setSampleFormat(uint bytes_per_sample, bool signed_samples, bool little_endian)
{
	// set from #TZX as a format string:
	if(!raw) throw syntax_error("set sample format: raw audio file required");
	sample_size = bytes_per_sample;
	this->signed_samples = signed_samples;
	this->little_endian = little_endian;
}

Validity TzxCswRecording::validity () const
{
	return (pause+first_frame+last_frame+header_size).validity;
}

void TzxHardwareInfo::addInfo(uint8 type, uint8 id, uint8 support)
{
	if (hwinfo.count()==255) throw syntax_error("too many hardware infos (max. 255)");
	if (type > 0x20) throw syntax_error("hardware type out of range [0..16]");	// 0..16 used
	if (id > 0x80) throw syntax_error("hardware ID out of range [0..45]");	// 0..2D used (type=0 computers)
	if (support > 3) throw syntax_error("hardware info out of range [0..3]");

	hwinfo.append(HwInfo(type,id,support));
}

void TzxArchiveInfo::addArchiveInfo(uint8 id, cstr text)
{
	if (archinfo.count()==255) throw syntax_error("too many archive infos (max. 255)");
	if (id>16 && id!=255) throw syntax_error("archive ID out of range [0…16|255]");

	for (cptr p=text; *p; p++)
	{
		if (*p<32 || *p>=127) throw syntax_error("archive text must be ASCII");
	}

	archinfo.append(ArchInfo(id,text));
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























