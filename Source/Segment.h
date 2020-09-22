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

#include "Templates/RCObject.h"
#include "Templates/RCPtr.h"
#include "SyntaxError.h"
typedef Array<uint8> Core;
#include "Label.h"



class Z80Assembler;
enum // compression flags
{
	middle_cseg=1,
	first_cseg_mask=2,
	last_cseg_mask=4,
	first_cseg=3,
	last_cseg=5,
	single_cseg=7
};


enum SegmentType
{
	DATA,						// #data
	CODE,						// #code
	TZX_STANDARD = 0x10,		// ~ CODE
	TZX_TURBO = 0x11,			// ~ CODE with changed pulse settings
	TZX_PURE_TONE = 0x12,		// empty body
	TZX_PULSES = 0x13,			// only DW in body
	TZX_PURE_DATA = 0x14,		// ~ CODE
	//TZX_DIRECT_RECORDING = 0x15,// only DB or raw audio binary data
	TZX_CSW_RECORDING = 0x18,	// only DB or raw audio binary data
	TZX_GENERALIZED = 0x19,		// ~ CODE
	TZX_PAUSE = 0x20,			// empty body
	TZX_GROUP_START = 0x21,		// empty body
	TZX_GROUP_END = 0x22,		// empty body
	TZX_LOOP_START = 0x24,		// empty body
	TZX_LOOP_END = 0x25,		// empty body
	TZX_STOP_48K = 0x2A,		// empty body
	TZX_POLARITY = 0x2B,		// empty body
	TZX_INFO = 0x30,			// empty body
	TZX_MESSAGE = 0x31,			// empty body
	TZX_ARCHIVE_INFO = 0x32,	// only DB in body
	TZX_HARDWARE_INFO = 0x33,	// only DB in body
};

extern bool isData(SegmentType);
extern bool isCode(SegmentType);



// ---- Base Class ---------------------

class Segment : public RCObject
{
public:
	SegmentType	type;			// DATA => no actual code storing allowed
	cstr		name;
	bool		is_data;
	bool		is_code;
	bool		is_tzx;
	Value		dpos;			// code deposition index

public:
	bool	isData	() const			{ return is_data; }
	bool	isCode	() const			{ return is_code; }
	bool	isTzx	() const			{ return is_tzx; }
	virtual Validity validity () const	{ return Validity::valid; }

	Value const& currentPosition ()		{ return dpos; }		// offset in core

// store object code
	virtual void rewind		()						{}
	virtual void store		(int)					throws { throw_code_segment_required(); }
	virtual void storeBlock	(cptr, uint)			throws { throw_code_segment_required(); }
	void	store		(int a,int b)				throws { store(a); store(b); }
	void	store		(int a,int b,int c)			throws { store(a); store(b); store(c); }
	void	store		(int a,int b,int c,int d)	throws { store(a); store(b); store(c); store(d); }
	void	storeWord	(int n)						throws;
	void	storeOffset (Value const&)				throws;
	void	storeByte	(Value const&)				throws;
	void	storeHexBytes (cptr data, uint sz)		throws;

protected:
	Segment (SegmentType, cstr name = nullptr);
	static void throw_data_segment_required () throws __attribute__((noreturn));
	static void throw_code_segment_required () throws __attribute__((noreturn));
};



// ---- class DataSegment ---------------------

class DataSegment : public Segment
{
	// Segment without core[] not to be written to file
	// Segment has address, size, deposition pointer like a CodeSegment

public:
	uint8		fillbyte;		// $FF for ROM else $00
	bool		relocatable;	// address has not been explicitely set => append to prev. segment
	bool		resizable;		// size has not been explicitely set    => shrink to fit
	Value		address;		// "physical" segment start address
	Value		size;			// segment size
	Value		lpos;			// logical position ('$') at dpos

public:
	DataSegment (cstr name, uint8 fillbyte, bool relocatable, bool resizable);

	//bool	isAtStart	()						{ return dpos.is_valid() && dpos==0; }
	Value	physicalAddress	()					{ return address + dpos; }		// segment_address + dpos
	Value const& logicalAddress	()				{ return lpos; }				// org + dpos
	Value&	getAddress	()						{ return address; }

	Validity validity	() const				override;
	void	rewind		()						override;
	void	setAddress	(Value const&)			throws;
	void	setSize		(Value const&)			throws;
	void	setOrigin	(Value const&)			throws;

	void	storeSpace	(Value const&, int)		throws;
	void	storeSpace	(Value const&)			throws;
	void	storeSpaceUpToAddress(Value const&)	throws;
	void	clearTrailingBytes ()				noexcept;

	void	skipExistingData (int sz)			throws;

	void	store		(int)					throws override;
	void	storeBlock	(cptr data, uint sz)	throws override;

protected:
	DataSegment (cstr name, SegmentType, uint8 fillbyte, bool relocatable, bool resizable);
};



// ---- class CodeSegment ---------------------

class CodeSegment : public DataSegment
{
	// Segment with core[] to be written to file
	// Segment has address, size, deposition pointer etc.

public:
	Value		flag;			// flag for .z80 and tape code segments
	Value		pause;			// TZX: pause after block [ms]
	Value		lastbits;		// TZX: used bits in last byte [1..8]
	bool		has_flag;		// this is a first segment of a block
	bool		has_pause;		// TZX: pause was set
	bool		has_lastbits;	// TZX: lastbits was set
	bool		no_flagbyte;	// TZX, TAP: don't write flagbyte to tape
	bool		no_checksum;	// TZX: don't write checksum to tape
	bool		no_pilot;		// TZX:
	bool		checksum_ace;	// TZX: calculate checksum for Jupiter Ace and write ACE-style tape block
	uint		compressed;		// ZX7 compression flags
	Core		core;
	Core		ccore;			// ZX7: if this is compressed & first_cseg_mask: compressed data of compressed range
	Core		ucore;			// ZX7: if this is compressed & first_cseg_mask: uncompressed data of compressed range

	Array<Values> pilotsym;		// TZX: custom pulse timing and encoding
	Values pilot;				// TZX
	Array<Values> datasym;		// TZX
	uint		pilotsym_idx;	// TZX
	uint		datasym_idx;	// TZX

	CodeSegment (cstr name, SegmentType, uint8 fillbyte, bool relocatable, bool resizable);

	bool	isEmpty			()			{ bool empty=yes; for(int i=0; i<size.value && empty; i++)
										  { empty = core[i]==fillbyte; } return empty; }
	uint8*	getData ()					{ return core.getData(); }
	uint	outputSize () const			{ return compressed ? ccore.count() : uint(size); }
	uint	outputSizeUpToDpos () const { return compressed ? ccore.count() : uint(dpos); }
	uint8 const* outputData () const	{ return compressed ? ccore.getData() : core.getData(); }
	Validity validity () const override;
	void	rewind() override;
	void	store		(int)					throws override;
	void	storeBlock	(cptr data, uint sz)	throws override;
	uint8&	operator[]	(uint32 i)				{ return core[i]; }
	uint8	popLastByte	()						{ assert(dpos>0); --lpos.value; return core[--dpos.value]; }

	void	setFlag		(Value const&)			throws;
	void	setPause	(Value const&);
	void	setLastBits	(Value const&);
	void	setNoFlag ();
	void	NoChecksum ();

	void	setNumPilotPulses (Value const&);
	void	addPilotSymbol (Values);
	void	addDataSymbol (Values);
	void	setPilot	(Values);

	void	check_pilot_symbol(uint idx) const;
	void	check_data_symbol(uint idx) const;
};



// ---- TZX segments except CodeSegments ---------

class TzxSegment : public Segment
{
protected:
	TzxSegment (SegmentType s)		:Segment(s){ is_tzx=yes; }
};


// ---- TZX segments without body: --------------

class TzxPureToneSegment : public TzxSegment
{
public:
	Value pulse_length;		// T-states
	Value num_pulses;
	TzxPureToneSegment()	:TzxSegment(TZX_PURE_TONE){}
	void setPulseLength(Value);
	void setNumPulses(Value);
	Validity validity () const override;
	//void rewind() override;
};

class TzxPauseSegment : public TzxSegment
{
public:
	Value duration;
	TzxPauseSegment() :TzxSegment(TZX_PAUSE){}
	void setDuration(Value);
	Validity validity () const override		{ return duration.validity; }
	//void rewind() override;	nothing to do
};

class TzxGroupStartSegment : public TzxSegment
{
public:
	cstr	name;	// group name, Ascii, max. 30 char
	TzxGroupStartSegment(cstr name) :TzxSegment(TZX_GROUP_START),name(name){}
	//Validity validity () const override;
	//void rewind() override;	nothing to do
};

class TzxGroupEndSegment : public TzxSegment
{
public:
	TzxGroupEndSegment() :TzxSegment(TZX_GROUP_END){}
	//Validity validity () const override;		no data members to check => return valid
	//void rewind() override;	nothing to do
};

class TzxLoopStartSegment : public TzxSegment
{
public:
	Value repetitions;
	TzxLoopStartSegment() :TzxSegment(TZX_LOOP_START){}
	void setRepetitions(Value);
	Validity validity () const override		{ return repetitions.validity; }
	//void rewind() override;	nothing to do
};

class TzxLoopEndSegment : public TzxSegment
{
public:
	TzxLoopEndSegment() :TzxSegment(TZX_LOOP_END){}
	//Validity validity () const override;		no data members to check => return valid
	//void rewind() override;	nothing to do
};

class TzxStop48kSegment : public TzxSegment
{
public:
	TzxStop48kSegment() :TzxSegment(TZX_STOP_48K){}
	//Validity validity () const override;		no data members to check => return valid
	//void rewind() override;	nothing to do
};

class TzxPolaritySegment : public TzxSegment
{
public:
	Value polarity;		// 0 or 1
	TzxPolaritySegment() :TzxSegment(TZX_POLARITY){}
	void setPolarity(Value);
	Validity validity () const override		{ return polarity.validity; }
	//void rewind() override;	nothing to do
};

class TzxInfoSegment : public TzxSegment
{
public:
	cstr text;	// Ascii, max. 255, pls. ~30 char
	TzxInfoSegment (cstr text) : TzxSegment(TZX_INFO),text(text){}
	//Validity validity () const override;
	//void rewind() override;	nothing to do
};

class TzxMessageSegment : public TzxSegment
{
public:
	Value duration;		// seconds
	Array<cstr> text;	// max. 8 line à 30 char; delim = 0x0D
	TzxMessageSegment(Array<cstr> text) :TzxSegment(TZX_MESSAGE),text(text){}
	void setDuration(Value);
	Validity validity () const override		{ return duration.validity; }
	//void rewind() override;
};

class TzxCswRecording : public TzxSegment
{
public:
	cstr	filename;
	bool	compressed;
	bool	raw;
	Value	pause;
	Value	header_size;		// may be read from file header
	Value	first_frame;		// may be read from file header
	Value	last_frame;			// may be read from file header
	int32	sample_rate;		// may be read from file header
	uint	num_channels;		// may be read from file header
	uint	sample_size;		// may be read from file header
	bool	signed_samples;		// may be read from file header
	bool	little_endian;		// may be read from file header

	TzxCswRecording(cstr filename);
	void	setCompression(bool);
	void	setPause(Value);		// ms
	void	setHeaderSize(Value);
	void	setFirstFrame(Value);
	void	setLastFrame(Value);
	void	setSampleRate(int32);
	void	setNumChannels(uint);
	void	setSampleFormat(uint,bool,bool);

	Validity validity () const override;
	//void rewind() override;
};



// ---- TZX non-code segments with body: ----------

class TzxPulses : public TzxSegment
{
public:
	Values pulses;
	uint count;
	TzxPulses()					:TzxSegment(TZX_PULSES),count(0){pulses.grow(255);}
	void appendPulse(Value);
	Validity validity () const override;
	void rewind() override;
};

class TzxArchiveInfo : public TzxSegment
{
	// store up to 255 arch-infos of 1 byte + p-string
public:
	struct ArchInfo
	{
		uint8 id; cstr text;
		ArchInfo(uint id, cstr text) :id(id),text(text){}
	};
	Array<ArchInfo> archinfo;

	TzxArchiveInfo()			:TzxSegment (TZX_ARCHIVE_INFO){}
	void addArchiveInfo(uint8 id, cstr text);
	//Validity validity () const override;
	//void rewind() override;
};

class TzxHardwareInfo : public TzxSegment
{
	// store up to 255 hw-infos of 3 bytes each
public:
	struct HwInfo
	{
		uint8 type; uint8 id; uint8 support;
		HwInfo(uint8 a,uint8 b,uint8 c) :type(a),id(b),support(c){}
		bool operator > (HwInfo const& b) const noexcept
			{ return (type<<11)+(id<<3)+support > (b.type<<11)+(b.id<<3)+b.support; }
	};
	Array<HwInfo> hwinfo;

	TzxHardwareInfo()				:TzxSegment (TZX_HARDWARE_INFO){}
	void addInfo(uint8 type, uint8 id, uint8 support);
	//Validity validity () const override;
	//void rewind() override;
};


// ----  Array<Segment> --------

class Segments : public RCArray<Segment>
{
public:
	DataSegment*	find(cstr name) const;
};

class DataSegments : public RCArray<DataSegment>
{
public:
	DataSegments (Segments const& segments);	// extract DataSegments and subclasses from source
};

class CodeSegments : public RCArray<CodeSegment>
{
public:
	CodeSegments (Segments const& segments);	// extract CodeSegments from source
	void	checkNoFlagsSet () const throws;
	uint32	totalCodeSize() const;
};

class TzxSegments : public RCArray<TzxSegment>
{
public:
	TzxSegments (Segments const& segments);	// extract TzxSegments from source
};
































