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
#include "Z80Registers.h"
#include "Source.h"


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
	TEST,						// ~ CODE, not written to file
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
extern bool isTest(SegmentType);



// ---- Base Class ---------------------

class Segment : public RCObject
{
public:
	SegmentType	type;			// DATA => no actual code storing allowed
	cstr		name;

	bool		is_data;		// DATA
	bool		is_code;		// CODE, TZX_STANDARD,TURBO,PURE_DATA,GENERALIZED
	bool		is_test;		// TEST
	bool		is_tzx;			// TzxSegment subclasses

	Value		dpos;			// code deposition index

public:
	bool	isData	() const			{ return is_data; }
	bool	isCode	() const			{ return is_code; }
	bool	isTest	() const			{ return is_test; }
	bool	isTzx	() const			{ return is_tzx; }
	virtual Validity validity () const	{ return Validity::valid; }

	cValue& currentPosition ()			{ return dpos; }		// offset in core

// store object code
	virtual void rewind () {}

	virtual void store		(int)				throws { throw_code_segment_required(); }
	virtual void storeBlock	(cptr, uint)		throws { throw_code_segment_required(); }
	virtual void storeSpace	(cValue&, int)		throws { throw_code_segment_required(); }
	virtual void storeSpace	(cValue&)			throws { throw_data_segment_required(); }

	void	store		(int a,int b)			throws { store(a); store(b); }
	void	store		(int a,int b,int c)		throws { store(a); store(b); store(c); }
	void	store		(int a,int b,int c,int d) throws { store(a); store(b); store(c); store(d); }
	void	storeWord	(cValue&)				throws;
	void	storeOffset (cValue&)				throws;
	void	storeByte	(cValue&)				throws;
	void	storeHexBytes (cptr data, uint sz)	throws;

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
	bool		relocatable;	// address has not been explicitely set => append to prev. segment
	bool		resizable;		// size has not been explicitely set    => shrink to fit
	Value		address;		// "physical" segment start address
	Value		size;			// segment size
	Value		lpos;			// logical position ('$') at dpos

public:
	DataSegment (cstr name);

	//bool	isAtStart	()						{ return dpos.is_valid() && dpos==0; }
	Value	physicalAddress	()					{ return address + dpos; }		// segment_address + dpos
	cValue& logicalAddress	()				{ return lpos; }				// org + dpos
	Value&	getAddress	()						{ return address; }

	Validity validity	() const				override;
	void	rewind		()						override;
	void	setAddress	(cValue&)			throws;
	void	setSize		(cValue&)			throws;
	void	setOrigin	(cValue&)			throws;

	void	store		(int)					throws override;
	void	storeBlock	(cptr data, uint sz)	throws override;
	void	storeSpace	(cValue& sz, int)	throws override;
	void	storeSpace	(cValue& sz)		throws override;

	void	storeSpaceUpToAddress(cValue&)	throws;
	void	storeSpaceUpToAddress(cValue&, int) throws;
	void	skipExistingData (uint sz)			throws;

protected:
	DataSegment (cstr name, SegmentType, bool relocatable, bool resizable);
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
	Value		fillbyte;		// $FF for ROM else $00
	bool		custom_fillbyte;
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

	CodeSegment (cstr name, SegmentType, uint8 fillbyte);

	uint8*	getData ()					{ return core.getData(); }
	uint	outputSize () const			{ return compressed ? ccore.count() : uint(size); }
	uint	outputSizeUpToDpos () const { return compressed ? ccore.count() : uint(dpos); }
	uint8 const* outputData () const	{ return compressed ? ccore.getData() : core.getData(); }
	Validity validity () const override;
	void	rewind() override;

	void	store		(int)					throws override;
	void	storeBlock	(cptr data, uint sz)	throws override;
	void	storeSpace	(cValue&, int)		throws override;
	void	storeSpace	(cValue&)			throws override;
	void	clearTrailingBytes ()				noexcept;

	uint8&	operator[]	(uint32 i)				{ return core[i]; }
	uint8	popLastByte	()						{ assert(dpos.value>0); --lpos.value; return core[--dpos.value]; }

	void	setFlag		(cValue&)			throws;
	void	setPause	(cValue&);
	void	setLastBits	(cValue&);
	void	setNoFlag ();
	void	setNoChecksum ();
	void	setFillByte	(cValue&);

	void	setNumPilotPulses (cValue&);
	void	addPilotSymbol (Values);
	void	addDataSymbol (Values);
	void	setPilot	(Values);

	void	check_pilot_symbol(uint idx) const;
	void	check_data_symbol(uint idx) const;
};



// ---- class TestSegment ---------------------

enum IoMode
{
	IoValues,		// data[count] = input values or to compare output values
	IoStdIn,		// stdin & stdout
	IoStdOut,		// stdin & stdout
	IoInFile,		// data = filename for sequential input or output
	IoOutFile,		// data = filename for sequential input or output
	IoAppendFile,	// data = filename for output, append mode
	IoCompareFile,	// data = filename for output, compare mode
	IoBlockDevice	// data = filename for block addressed input and output
};

struct IoSequence
{
	// a series of bytes with optional repetition

	uint8* data = nullptr;
	uint count  = 0;
	uint repetitions = 1;

	IoSequence() = default;
	IoSequence(const uint8* data, uint count, uint repetitions=1);
	~IoSequence() { delete[] data; }
	IoSequence(IoSequence&& q) noexcept;
	IoSequence& operator= (IoSequence&& q) noexcept;
	IoSequence(const IoSequence&) = delete;
	IoSequence& operator= (const IoSequence&) = delete;
};

using IoSequences = Array<IoSequence>;

struct IoList
{
	IoMode iomode = IoValues;
	uint32 filler = 0;

	union	// note: extra union for FD, because C++ doesn't allow complex type in anon struct
	{
		IoSequences* data;			// IoValues
		FD  fd;						// IoFile
	};

	union
	{
		struct	// IoValues
		{
			uint sequence_idx;		// during test run
			uint in_sequence_idx;	// during test run
			uint repetition; 		// during test run
			uint filler2;
		};
		struct	// IoFile*
		{
			uint blocksize;
			uint blockstate;		// during io
			uint memory_address;	// during io
			uint block_idx;			// during io
		};
	};

	IoList() = delete;
	IoList(IoSequence&&);			// ctor for iomode=Values with first IoSequence
	IoList(IoMode, cstr filename, uint blocksize=0); // ctor iomode=File etc.
	~IoList();
	IoList(IoList&&);
	IoList& operator=(IoList&&);
	IoList(const IoList&)=delete;
	IoList& operator=(const IoList&)=delete;

	void append(IoSequence&&);

	void openFile();					// befor test
	uint8 inputByte();					// during test
	void outputByte(uint8, uint8* core);// during test
	bool isAtEnd();						// after test
	void closeFile() noexcept;			// after test
};

struct Expectation
{
	cstr  name;		// not retained: register name, cc, cc_min or cc_max
	int32 value;	// validity is managed by a single Validity instance in TestSegment
	uint16 pc;		// ""
	int16 padding;
	RCPtr<SourceLine> sourceline;

	Expectation (cstr name, int32 v, int pc, SourceLine* q) : name(name), value(v), pc(uint16(pc)), sourceline(q) {}
	Expectation (Expectation&& q) = default;
	~Expectation () = default;
};

using Expectations = Array<Expectation>;

class TestSegment : public CodeSegment
{
public:
	HashMap<uint16,IoList> inputdata;		// <io_addr,data[]>
	HashMap<uint16,IoList> outputdata;		// <io_addr,data[]>

	mutable Value cpu_clock{-1,invalid};	static constexpr uint32 cpu_unlimited = 0;
	mutable Value int_per_sec{-1,invalid};	static constexpr uint   no_interrupts = 0;
	mutable Value int_ack_byte{-1,invalid};	static constexpr uint8  floating_bus_byte = 255;
	mutable Value timeout_ms{-1,invalid};	static constexpr uint32 no_timeout = 0;

	Expectations expectations;
	bool expectations_valid = yes;
	bool iodata_valid = yes;

public:
	TestSegment (cstr name, uint8 fillbyte);
	~TestSegment () override;

	Validity validity () const override;
	void rewind() override;

	void setCpuClock (Value frequency);
	void setIntPerSec (Value frequency);
	void setCcPerInt (Value cc);
	void setIntAckByte (Value byte);
	void setTimeoutMsec (Value msecs);
	void setExpectedCcMin (SourceLine* q, Value cc);
	void setExpectedCcMax (SourceLine* q, Value cc);
	void setExpectedCc (SourceLine* q, Value cc);
	void setExpectedRegisterValue (SourceLine* q, cstr reg, Value v);
	void setInputData (cValue& ioaddr, IoSequence&&);
	void setInputFile (cValue& ioaddr, cstr filename, IoMode=IoInFile);
	void setOutputData (cValue& ioaddr, IoSequence&&);
	void setOutputFile (cValue& ioaddr, cstr filename, IoMode);
	void setBlockDevice (cValue& ioaddr, cstr filename, cValue& blocksize);
	void setConsole (cValue& ioaddr);

	void openFiles();					// befor test
	uint8 inputByte(uint16 addr);		// during test
	void outputByte(uint16 addr, uint8, uint8* core);// during test
	void checkAllBytesRead();			// after test
	void checkAllBytesWritten();		// after test
	void closeFiles() noexcept;			// after test
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
	cstr	groupname;	// group name, Ascii, max. 30 char
	TzxGroupStartSegment(cstr groupname) :TzxSegment(TZX_GROUP_START),groupname(groupname){}
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
	uint32	sample_rate;		// may be read from file header
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
	void	setSampleRate(uint32);
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
		uint8 id; uint8 padding[7]; cstr text;
		ArchInfo(uint id, cstr text) :id(uint8(id)),text(text){}
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
	DataSegments (Segments const& segments);	// extract DataSegments and subclasses
};

class CodeSegments : public RCArray<CodeSegment>
{
public:
	CodeSegments (Segments const& segments);	// extract CodeSegments (CODE, TZX, no TEST) from source array
	void	checkNoFlagsSet () const throws;
	uint32	totalCodeSize() const;
};

class TzxSegments : public RCArray<TzxSegment>
{
public:
	TzxSegments (Segments const& segments);	// extract TzxSegments from source array
};

class TestSegments : public RCArray<TestSegment>
{
public:
	TestSegments (Segments const& segments);	// extract TestSegments from source array
};
































