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

#include "Z80Assembler.h"
#include "unix/files.h"
#include "helpers.h"
#include "Z80/goodies/z80_goodies.h"
#include "kio/peekpoke.h"

static cstr oo_str(uint n)
{
	static constexpr char ns[5][9] = {"        ","00      ","0000    ","000000  ","00000000"};
	return n<4 ? ns[n] : ns[4];
	static_assert(ns[4][7]=='0',"");
}

static uint write_line_with_objcode
			(FD& fd, uint address, uint8* bytes, uint count, uint offset, bool is_data, cstr text, CpuID variant)
{
	// Helper: write one line with address, code and text to log file
	// address	= base address of opcode
	// bytes	= pointer to start of opcode
	// count	= size of opcode (num. bytes)
	// offset	= offset in bytes[]
	// text	= source line etc.
	//
	// returns:  bytes printed. (may be faked to 'all' for longish fillers)
	//
	// if multiple lines must be printed for an opcode (a 'defs' or similar)
	// then address, bytes and count must not be incremented by the caller
	// instead the caller only increments offset
	//
	// format:
	// 1234: 12345678	sourceline

	if(bytes==nullptr)
	{
		assert(is_data || count==0);
		assert(offset==0);

		fd.write_fmt("%04X: %s\t%s\n", address, oo_str(count), text);
		if(count>4)
			if(count>8) fd.write_fmt("%04X: 00...   \t%s\n", address+4, text);
			else        fd.write_fmt("%04X: %s\t%s\n", address+4, oo_str(count-4), text);
		else{}
		return count;
	}

	address += offset;
	bytes   += offset;
	count   -= offset;

	// special handling for compound opcodes:
	// limit number of bytes to 4; break on opcode boundary
	if (count>4 && !is_data)
	{
		for (count=0;;)
		{
			uint n = cpu_opcode_length(variant,bytes+count);
			if (count+n>4) break;
			count += n;
		}
	}

	switch (count)
	{
	case 0:	fd.write_fmt("%04X:         \t%s\n",  address&0xffff,		  text); return 0;
	case 1:	fd.write_fmt("%04X: %02X      \t%s\n",address, peek1X(bytes), text); return 1;
	case 2: fd.write_fmt("%04X: %04X    \t%s\n",  address, peek2X(bytes), text); return 2;
	case 3: fd.write_fmt("%04X: %06X  \t%s\n",    address, peek3X(bytes), text); return 3;
	case 4:
	default:
		// wenn zuletzt 4 gleiche Bytes geloggt wurden
		// und noch mehr als 4 Bytes folgen
		// und nur noch diese Bytes folgen
		// dann verkürze die ausgegebenen Datenbytes mit "...":
		if (offset>=4 && count>4)
		{
			uint8* p = bytes-4;
			uint8* e = bytes+count;
			uint8  c = *p++;
			while (p<e && *p==c) ++p;
			if (p==e)
			{
				fd.write_fmt("%04X: %02X...   \t%s\n", address, peek1X(bytes), text);
				return count;
			}
		}

		fd.write_fmt("%04X: %08X\t%s\n", address, peek4X(bytes), text);
		return 4;
	}
}

static cstr cc_str(uint8* bytes, uint count, uint32& cc, bool is_data, CpuID variant)
{
	// calculate string with accumulated cpu clock cycles for z80 instruction
	// the returned string has in most cases 9 characters.
	// for very long code threads without any labels this string may be longer.
	//
	// the cycle couter cc is accumulated.
	// cc should be reset at every label. this must be done by the caller.
	//
	// format:
	//   "[123|123]" for branching opcodes
	//   "[123]    " for all other opcodes

	if (is_data) return "         ";		// spacestr(9)

	assert(count>=1 && count<=4);

	// TODO: verify opcode length

	uint8 op1 = bytes[0];
	uint8 op2 = count>=2 ? bytes[1] : 0;

	bool can_branch = cpu_opcode_can_branch(variant,op1,op2);
	if (can_branch)
	{
		uint a = cc + cpu_clock_cycles(variant,op1,op2,0);			// print accumulated time after instruction
		uint b = op1==0xed ? cpu_clock_cycles_on_branch(variant,op1,op2) : // for ldir etc. print loop time
				 cc + cpu_clock_cycles_on_branch(variant,op1,op2);	// for other instructions print accum. time as for a
		cc = a;

		str s = usingstr("[%2u|%2u]  ", a, b);
		if (strlen(s)>9) s[9] = 0;
		return s;
	}
	else
	{
		uint8 op4 = count>=4 ? bytes[3] : 0;
		cc += cpu_clock_cycles(variant,op1,op2,op4);

		str s = usingstr("[%2u]     ", cc);
		s[9] = 0;
		return s;
	}
}

static cstr compound_cc_str (uint8* bytes, uint count, uint32& cc, CpuID variant)
{
	// calculate string with accumulated cpu clock cycles for compound instruction
	// same as cc_str() but for compound instructions
	// assumes no branching opcodes (and no LDIR etc.)

	while (count)
	{
		uint8 op1 = bytes[0];
		uint8 op2 = count>=2 ? bytes[1] : 0;
		uint8 op4 = count>=4 ? bytes[3] : 0;

		cc += cpu_clock_cycles(variant,op1,op2,op4);
		uint len = cpu_opcode_length(variant,bytes);
		assert(len<=count);
		bytes += len;
		count -= len;
	}

	str s = usingstr("[%2u]     ", cc);
	s[9] = 0;
	return s;
}

static uint write_line_with_objcode_and_cycles
			(FD& fd, uint address, uint8* bytes, uint count, uint offset, uint32& cc, bool is_data, cstr text, CpuID variant)
{
	// format:
	// 1234: 12345678 [234|235]sourceline

	if(bytes==nullptr)
	{
		assert(is_data || count==0);
		assert(offset==0);

		fd.write_fmt("%04X: %s          %s\n", address, oo_str(count), text);
		if(count>4)
			if(count>8) fd.write_fmt("%04X: 00...             %s\n", address+4, text);
			else        fd.write_fmt("%04X: %s          %s\n", address+4, oo_str(count-4), text);
		else{}
		return count;
	}

	address += offset;
	bytes   += offset;
	count   -= offset;

	// special handling for compound opcodes:
	if (count>1 && !is_data && count>cpu_opcode_length(variant,bytes))
	{
		if (count>4)	// limit number of accounted bytes to 4; break on opcode boundary:
		{
			for (count=0;;)
			{
				uint n = cpu_opcode_length(variant,bytes+count);
				if (count+n>4) break;
				count += n;
				//if (n>=2 && z80_opcode_can_branch(bytes[0],bytes[1])) break;			denk...
			}
		}

		switch (count)
		{
		case 2:
			fd.write_fmt("%04X: %04X     %s%s\n", address, peek2X(bytes), compound_cc_str(bytes,count,cc,variant), text);
			return 2;
		case 3:
			fd.write_fmt("%04X: %06X   %s%s\n",   address, peek3X(bytes), compound_cc_str(bytes,count,cc,variant), text);
			return 3;
		case 4:
			fd.write_fmt("%04X: %08X %s%s\n",     address, peek4X(bytes), compound_cc_str(bytes,count,cc,variant), text);
			return 4;
		}
		IERR();
	}

	// normal opcodes or data:
	switch (count)
	{
	case 0:
		fd.write_fmt("%04X:                   %s\n",  address&0xffff, text);
		return 0;
	case 1:
		fd.write_fmt("%04X: %02X       %s%s\n", address, peek1X(bytes), cc_str(bytes,count,cc,is_data,variant), text);
		return 1;
	case 2:
		fd.write_fmt("%04X: %04X     %s%s\n",  address, peek2X(bytes), cc_str(bytes,count,cc,is_data,variant), text);
		return 2;
	case 3:
		fd.write_fmt("%04X: %06X   %s%s\n",    address, peek3X(bytes), cc_str(bytes,count,cc,is_data,variant), text);
		return 3;
	case 4:
		fd.write_fmt("%04X: %08X %s%s\n",    address, peek4X(bytes), cc_str(bytes,count,cc,is_data,variant), text);
		return 4;
	default:
		assert(is_data);
		// wenn zuletzt 4 gleiche Bytes geloggt wurden
		// und noch mehr als 4 Bytes folgen
		// und nur noch diese Bytes folgen
		// dann verkürze die ausgegebenen Datenbytes mit "...":
		if (offset>=4 && count>4)
		{
			uint8* p = bytes-4;
			uint8* e = bytes+count;
			uint8  c = *p++;
			while (p<e && *p==c) ++p;
			if (p==e)
			{
				fd.write_fmt("%04X: %02X...             %s\n", address, peek1X(bytes), text);
				return count;
			}
		}

		fd.write_fmt("%04X: %08X          %s\n", address, peek4X(bytes), text);
		return 4;
	}
}

static bool gt_by_name (RCPtr<Label> const& a, RCPtr<Label> const& b)
{
	// compare two labels by name
	// for sort()

	return gt(a->name,b->name);
	//return gt_tolower(a->name,b->name);
}

static cstr calc_padding (Array<uint32>& lens)
{
	// calculate a padding string for names
	// padding string is used to make all names align properly
	// if some labels are excessively long, then these may extend beyond the common length
	// the returned string can be used like this:
	//
	// printf("%s%s",name,padding+strlen(name))

	if (lens.count()==0) return "";

	lens.sort();
	uint32 maxlen = max(7u,lens.last());
	str padding = spacestr(maxlen);
	if (maxlen<=19) return padding;

	uint32 bestlen = lens[lens.count()*95/100];
	memset(padding+bestlen,0,sizeof(char)*(maxlen-bestlen));
	return padding;
}

static cstr calc_padding (DataSegments& segments)
{
	// convenience

	Array<uint32> lens(segments.count());
	for (uint i=0; i<segments.count(); i++) { lens[i] = uint32(strlen(segments[i]->name)); }
	return calc_padding(lens);
}

static cstr calc_padding (Array<RCPtr<Label>>& labels)
{
	// convenience

	Array<uint32> lens(labels.count());
	for (uint j=0; j<labels.count(); j++) { lens[j] = uint(strlen(labels[j]->name)); }
	return calc_padding(lens);
}

inline cstr calc_padding (Labels& labels)
{
	// convenience

	return calc_padding(labels.getItems());
}

static cstr u5str (Value const& n)
{
	if (n.is_invalid()) return "VOID ";
	str s = spacestr(5);
	sprintf(s,"%u",n&0xffff); if (n<10000) *strchr(s,0)=' ';
	return s;
}

static cstr h4u5str (Value const& n)
{
	if (n.is_valid())		return usingstr("= $%04X =%6u", n&0xffff, int(n));
	if (n.is_preliminary())	return usingstr("~ $%04X =%6u", n&0xffff, int(n));
	else					return "=  ***VOID***  ";
}


/* ==============================================================
		Write List File
============================================================== */


void Z80Assembler::writeListfile(cstr listpath, int style) throws /*AnyError*/
{
	// style: 0=none, 1=plain, 2=w/ocode, 4=w/labels, 8=w/clkcycles

	assert(listpath && *listpath);
	assert(source.count()); 	// da muss zumindest das selbst erzeugte #include in Zeile 0 drin sein

	FD fd(listpath,'w');
	TempMemPool tempmempool;	// be nice in case zasm is included in another project
	uint si=0,ei=0;				// source[] index, errors[] index
	if (source.count() && eq(source[0]->sourcefile,"") && startswith(lowerstr(source[0]->text),"#include")) si=1;

	if (style&8) style |= 2;

	// indentation string for lines without opcodes:
	cstr indentstr = style&8 ? "                        " :	// format: 1234: 12345678 [234|235]sourceline
					 style&2 ? "              \t" : "";		// format: 1234: 12345678\tsourceline

	if (style>1)
	{
		fd.write_fmt("%s; --------------------------------------\n",	indentstr);
		fd.write_fmt("%s; zasm: assemble \"%s\"\n",						indentstr, source_filename);

		if(	syntax_8080 || target_z180 ||  target_8080 ||
			flat_operators || casefold || allow_dotnames ||
			require_colon || ixcbr2_enabled || ixcbxh_enabled )
		{
			fd.write_fmt("%s; opts:%s%s%s%s%s%s%s%s%s%s\n", indentstr,
				syntax_8080					? " --asm8080"  : "",
				cpu==CpuZ180				? " --z180"     : "",
				cpu==CpuZ80 && syntax_8080  ? " --z80"		: "",
				cpu==Cpu8080 && !syntax_8080 ? " --8080"	: "",
				flat_operators				? " --flatops"  : "",
				casefold && !syntax_8080	? " --casefold" : "",
				allow_dotnames				? " --dotnames" : "",
				require_colon				? " --reqcolon" : "",
				ixcbr2_enabled				? " --ixcbr2"   : "",
				ixcbxh_enabled				? " --ixcbxh"   : "" );
		}

		fd.write_fmt("%s; date: %s\n",									indentstr, datetimestr(timestamp));
		fd.write_fmt("%s; --------------------------------------\n\n\n",indentstr);
	}

	// Listing with object code:

	if (style&2)	// with opcodes:
	{
		uint32 cc = 0;
		CpuID variant = target_z180 ? CpuZ180 : target_8080 ? Cpu8080 : CpuZ80;

		while (si<source.count())
		{
			SourceLine& sourceline = source[si++];

			DataSegment* segment = dynamic_cast<DataSegment*>(sourceline.segment);
			CodeSegment* codesegment = dynamic_cast<CodeSegment*>(segment);
			//if(segment==NULL) break;		// after #END or final error or before ORG or not #code and not #data

			assert(!segment || !segment->size.is_valid() || sourceline.bytecount<=0x10000);
			assert(!segment || !segment->size.is_valid()
					  || sourceline.byteptr+sourceline.bytecount <= uint32(segment->size)
					  || sourceline.bytecount==0);

			uint count   = sourceline.bytecount;			// bytes to print
			uint offset  = sourceline.byteptr;				// offset from segment start
			uint8* bytes = codesegment ? codesegment->core.getData() + offset : nullptr;	// ptr -> opcode
			uint address = segment ? segment->address + offset : 0;				// "physical" address of opcode
			bool is_data = sourceline.is_data;
			Label* label = sourceline.label;

			bool is_defl = label && !count && uint16(label->value) != uint16(address) && !label->is_invalid();

			// line contains a label?
			if (label)
			{
				if (is_defl)							// for labels defined with EQU
					address=sourceline.label->value;	// print label value instead of address
				else									// at program labels
					cc = 0;								// reset cc
			}

			if (!count && !label)
			{
				// no code generated and no label defined?
				offset = 0;
				fd.write_fmt("%s%s\n", indentstr, sourceline.text);
			}
			else
			{
				// print line with address, up to 4 opcode bytes and source line:
				// note: real z80 opcodes have max. 4 bytes
				offset = style&8 ?
					write_line_with_objcode_and_cycles(fd, address, bytes, count, 0, cc, is_data, sourceline.text, variant)
				  : write_line_with_objcode(fd, address, bytes, count, 0, is_data, sourceline.text, variant);
			}


			// print errors and suppress printing of further opcode bytes:
			while (ei<errors.count() && errors[ei].sourceline == &sourceline)
			{
				if (style&8)
					fd.write_fmt("***ERROR***             %s^ %s\n", sourceline.whitestr(), errors[ei++].text);
				else
					fd.write_fmt("***ERROR***   \t%s^ %s\n", sourceline.whitestr(), errors[ei++].text);
				offset = count;
			}

			// print remaining opcode bytes
			// note: real z80 opcodes have max. 4 bytes
			// but some compound opcodes and pseudo opcodes like 'defm' or 'defs' may have more:
			while (offset<count)
			{
				offset += style&8 ?
					write_line_with_objcode_and_cycles(fd, address, bytes, count, offset, cc, is_data, "", variant)
				  : write_line_with_objcode(fd, address, bytes, count, offset, is_data, "", variant);
			}
		}
	}

	// Plain listing without object code:
	// all lines are included in the list file
	//
	else	// without opcodes:
	{
		while (si<source.count())
		{
			SourceLine& sourceline = source[si++];

			// print source line
			fd.write_str(sourceline.text); fd.write_char('\n');

			// print errors and suppress printing of further opcode bytes:
			while (ei<errors.count() && errors[ei].sourceline == &sourceline)
			{
				fd.write_fmt("%s^ ***ERROR*** %s\n", sourceline.whitestr(), errors[ei++].text);
			}
		}
	}

	// List remaining errors:
	// without associated source line
	//
	while (ei<errors.count())
	{
		fd.write_fmt("***ERROR*** %s\n",errors[ei++].text);
	}

	// List Labels:
	// labels are listed in groups by locality, globals first
	// within each group they are sorted by name
	// TODO: option sort by
	//		 Segment + Adresse
	//		 Segment + Name
	//		 File
	//
	if (style&4)	// with label listing:
	{
		DataSegments segments(this->segments);

		cstr spadding = calc_padding(segments);

		// list segments
		// "#CODE|#DATA name: start=n, len=n, flag=n"

		fd.write_str("\n\n; +++ segments +++\n\n");
		for (uint i=0; i<segments.count(); i++)
		{
			DataSegment& s = segments[i];
			if (i==0 && s.size==0 && segments.count()>1) continue;
			if (s.isCode() && static_cast<CodeSegment&>(s).has_flag)
				fd.write_fmt("#CODE %s %s %s,  size %s,  flag = %s\n",
					s.name,spadding+strlen(s.name),
					h4u5str(s.address), h4u5str(s.size), u5str(static_cast<CodeSegment&>(s).flag));
			else
				fd.write_fmt("#%s %s %s %s,  size %s\n",
					s.isCode()?"CODE":"DATA",
					s.name,spadding+strlen(s.name),
					h4u5str(s.address), h4u5str(s.size));
		}

		// list labels:
		// "name = $1234 = 12345  segment  sourcefile:linenumber (unused)"
		// don't list invalid _and_ unused labels
		// don't list sdcc-reusable labels except if verbose ≥ 2

		for (uint i=0; i<labels.count(); i++)
		{
			fd.write_str(i?"\n; +++ local symbols +++\n\n":"\n; +++ global symbols +++\n\n");

			Array<RCPtr<Label>> labels(this->labels[i].getItems()); // copy
			labels.sort(&gt_by_name);							// sort by name
			cstr lpadding = calc_padding(labels);

			for (uint j=0; j<labels.count(); j++)
			{
				Label* l = labels[j];
				if (i && l->is_global) continue;		// don't list .globl labels in locals[]
				if (l->is_invalid() && !l->is_used) continue;
				if (l->is_reusable && verbose<2) continue;

				cstr		name = l->name; if(name==DEFAULT_CODE_SEGMENT) continue; // Vergleich der Adresse!
				DataSegment* segment = dynamic_cast<DataSegment*>(l->segment); // may be NULL or no data/code segment
				SourceLine&	sourceline = source[l->sourceline];
				cstr		sourcefile = filename_from_path(sourceline.sourcefile);
				uint		linenumber = sourceline.sourcelinenumber;
				cstr		segmentname = segment ? segment->name : "";

				if (!l->is_defined)
					fd.write_fmt("%s%s = ***UNDEFINED***",
						name, lpadding+strlen(name));
				else
					fd.write_fmt("%s%s %s  %s%s %s:%u",
						name, lpadding+strlen(name), h4u5str(l->value),
						segmentname, spadding+strlen(segmentname), sourcefile, linenumber+1);

				fd.write_str(l->is_used?"\n":" (unused)\n");
			}
		}

		// list unresolved labels:
		// list all undefined labels
		// list all invalid labels
		// list preliminary labels except sdcc-reusable labels except if verbose ≥ 2

		if (pass>1 && errors.count())
		{
			Array<RCPtr<Label>> unresolved_labels;

			for (uint i=0;i<labels.count();i++)
			{
				Array<RCPtr<Label>>& labels = this->labels[i].getItems();
				for (uint j=0;j<labels.count();j++)
				{
					Label* l = labels[j];
					if (l->is_valid() || !l->is_used) continue;
					else if (verbose<2 && l->is_preliminary() && l->is_reusable) continue;
					else unresolved_labels.append(l);
				}
			}

			if (unresolved_labels.count())
			{
				fd.write_str("\n\n; +++ used but undefined or unresolved labels +++\n\n");

				cstr lpadding = calc_padding(unresolved_labels);

				for (uint i=0;i<unresolved_labels.count(); i++)
				{
					Label* l = unresolved_labels[i];
					fd.write_fmt("%s%s = %s\n",
						l->name,lpadding+strlen(l->name),
						l->is_preliminary() ? "***preliminary***" :
						l->is_defined ? "***unresolved***" : "***undefined***");
				}
			}
		}
	}

	// list elapsed time and errors:
	fd.write_fmt("\n\ntotal time: %3.4f sec.\n", now()-starttime);
	fd.write_fmt("%s error%s\n", errors.count()?tostr(errors.count()):"no", errors.count()==1?"":"s");
	fd.close_file();
}




























