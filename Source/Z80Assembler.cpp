/*	Copyright  (c)	Günter Woigk 1994 - 2020
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

#include "kio/kio.h"
#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif
#include <cmath>
#include <unistd.h>
#include "unix/FD.h"
#include "unix/files.h"
#include "unix/MyFileInfo.h"
#include "Z80Assembler.h"
#include "Segment.h"
#include "Z80/goodies/z80_opcodes.h"
#include "Templates/HashMap.h"
#include "helpers.h"
#include "CharMap.h"
#include "Z80/goodies/z80_major_opcode.h"
#include "zx7.h"
#include "Templates/StrArray.h"
#include "kio/peekpoke.h"


extern char** environ;


// hints may be set by caller:
//
cstr sdcc_compiler_path = nullptr;
cstr sdcc_include_path = nullptr;
cstr sdcc_library_path = nullptr;
cstr vcc_compiler_path = nullptr;
cstr vcc_include_path = nullptr;
cstr vcc_library_path = nullptr;


// Priorities for Z80Assembler::value(…)
//
enum
{ 	pAny = 0,		// whole expression: up to ')' or ','
	pTriadic,		// ?:
	pBoolean,		// && ||
	pCmp, 			// comparisions:	 lowest priority
	pAdd, 			// add, sub
	pMul, 			// mul, div, rem
	pBits, 			// bool/masks:		 higher than add/mult
	pRot, 			// rot/shift
	pUna			// unary operator:	 highest priority
};


// name for default code segment, if no #target is given:
//
const char DEFAULT_CODE_SEGMENT[] = "";  // "(DEFAULT)";


// some const values
//
static const Value N0(0);
static const Value N1(1);
static const Value N2(2);



// --------------------------------------------------
//					Helper
// --------------------------------------------------

void Z80Assembler::setError (const any_error& e)
{
	// set error for current file, line & column

	SourceLine* sourceline = current_sourceline_index < source.count() ? &current_sourceline() : nullptr;

	errors.append(Error(e.what(), sourceline));
}

void Z80Assembler::setError (cstr format, ...)
{
	// set error for current file, line & column

	SourceLine* sourceline = current_sourceline_index < source.count() ? &current_sourceline() : nullptr;

	va_list va;
	va_start(va,format);
	errors.append( Error(format, sourceline, va) );
	va_end(va);
}

static bool doteq (cptr w, cptr s)
{
	// compare word w with string literal s
	// s must be lower case
	// w may be mixed case
	// w may have a dot '.' prepended

	assert(s&&w);
	if (*w=='.') w++;
	while (*s) { if ((*w++|0x20) != *s++) return false; }
	return *w==0;
}

static bool lceq (cptr w, cptr s)
{
	// compare word w with string literal s
	// s must be lower case
	// w may be mixed case

	assert(s&&w);
	while (*s) { if ((*w++|0x20) != *s++) return false; }
	return *w==0;
}

cstr Z80Assembler::unquotedstr (cstr s0)
{
	// just unquote a string
	// Z80 assemblers did not use the c-style escapes ...

	if (!s0||!*s0) return emptystr;

	str  s = dupstr(s0);
	int  n = int(strlen(s));
	char c = s[0];

	if (n>=2 && (c=='"'||c=='\'') && s[n-1]==c)
	{
		s[n-1] = 0;
		s++;
	}

	return s;
}

cstr Z80Assembler::get_filename (SourceLine& q, bool dir) throws
{
	// read quoted filename from sourceline
	// in cgi_mode check for attempt to escape from source directory
	// note: it is still possible to use symlinks to other directories!
	// used by:
	//   asmInclude, asmInsert, asmCPath (not im cgi_mode),
	//   asmInclude library (dir) and TZX_CSW_RECORDING

	cstr fqn = q.nextWord();
	if (fqn[0]!='"' && fqn[0]!='\'')
		throw syntax_error(dir ? "quoted directory name expected" : "quoted filename expected");
	fqn = unquotedstr(fqn);
	if (dir && lastchar(fqn)!='/') fqn = catstr(fqn,"/");

	if (cgi_mode && q.sourcelinenumber)
	{
		if (fqn[0]=='/' || startswith(fqn,"~/") || startswith(fqn,"../") || contains(fqn,"/../"))
			throw fatal_error("Escape from Darthmoore Castle");
	}

	if (fqn[0]!='/') fqn = catstr(directory_from_path(q.sourcefile),fqn);
	return fqn;
}

void Z80Assembler::init_c_flags ()
{
	// initialize c_flags[]

	is_sdcc = c_compiler && eq(filename_from_path(c_compiler),"sdcc");
	is_vcc  = c_compiler && eq(filename_from_path(c_compiler),"vcc");

	c_flags.purge();
	c_qi = c_zi = -1;

	if (!c_includes && is_sdcc && sdcc_include_path) c_includes = sdcc_include_path;
	if (!c_includes && is_vcc && vcc_include_path) c_includes = vcc_include_path;

	if (c_includes)	// from command line
	{
		if (is_sdcc) c_flags.append("--nostdinc");
		c_flags.append(catstr("-I",c_includes));
	}
}

void Z80Assembler::init_c_tempdir () throws
{
	// initialize c_tempdir:
	// c_tempdir = subdir in temp_directory for the c_compiler .s output files
	// create directory

	assert(lastchar(temp_directory)=='/');

	c_tempdir = catstr(temp_directory, "s/");

	if (is_sdcc)
	{
		for (uint i=0; i<c_flags.count(); i++)
		{
			//if(eq(c_flags[i],"--nostdinc")) continue;
			c_tempdir = catstr(c_tempdir, replacedstr(c_flags[i],'/',':'), "/");
		}
	}

	if (is_vcc){}	// just happy with s/

	if (!exists_node(c_tempdir)) create_dir(c_tempdir,0774,yes);
}

inline bool utf8_is_null (char c) { return c==0; }
inline bool utf8_is_7bit (char c) { return c>=0; }				// %0xxxxxxx = ascii
inline bool utf8_no_7bit (char c) { return c<0;  }
inline bool utf8_is_fup	 (char c) { return c< char(0xc0);  }	// %10xxxxxx = fup
inline bool utf8_no_fup	 (char c) { return c>=char(0xc0);  }
inline bool utf8_is_c1	 (char c) { return c>=0; }				// == utf8_is_7bit
inline bool utf8_is_c2	 (char c) { return (c&0xe0)==0xc0; }	// %110xxxxx
inline bool utf8_is_c3	 (char c) { return (c&0xf0)==0xe0; }	// %1110xxxx
inline bool utf8_is_c4	 (char c) { return (c&0xf8)==0xf0; }	// %11110xxx
inline bool utf8_is_c5	 (char c) { return (c&0xfc)==0xf8; }	// %111110xx
inline bool utf8_is_c6	 (char c) { return uchar(c)>=0xfc; }	// %1111110x  2005-06-11: full 32 bit
inline bool utf8_is_ucs4 (char c) { return uchar(c)> 0xf0; }	// 2015-01-02 doesn't fit in ucs2?
inline bool utf8_req_c4	 (char c) { return uchar(c)>=0xf0; }	// 2015-01-02 requires processing of c4/c5/c6?
#define     RMASK(n)	 (~(0xFFFFFFFF<<(n)))					// mask to select n bits from the right

static uint charcode_from_utf8 (cptr& s) throws
{
	// convert UTF-8 char to UCS-2
	// stops at next non-fup
	// throws on error
	// char(0) is a valid character
	// note: only doing UCS2 because class charmap is UCS2 only

	uint n; uint i; char c;

	n = uchar(*s++);						// char code akku
	if (utf8_is_7bit(n)) return n;			// 7-bit ascii char
	if (utf8_is_fup(n))  throw syntax_error("broken utf-8 character!");	// unexpected fup
	if (utf8_is_ucs4(n)) throw syntax_error("broken utf-8 character!");	// code exceeds UCS-2

	// longish character:
	i = 0;									// UTF-8 character size
	c = n;
	//c = n & ~0x02;						// force stop at i=6
	while (char(c<<(++i)) < 0)				// loop over fup bytes
	{
		uchar c1 = *s++;
		if (utf8_no_fup(c1)) throw syntax_error("broken utf-8 character!");
		n = (n<<6) + (c1&0x3F);
	}

	// simplify error checking for caller:
	if (utf8_is_fup(*s)) throw syntax_error("broken utf-8 character!"); // more unexpected fups follows

	// now: i = total number of digits
	//      n = char code with some of the '1' bits from c0
	n &= RMASK(2+i*5);

	// ok => return code
	return n;
}



// --------------------------------------------------
//					Creator
// --------------------------------------------------


Z80Assembler::Z80Assembler ()
:
	timestamp(now()),
	source_directory(nullptr),
	source_filename(nullptr),
	temp_directory(nullptr),
	target(TARGET_UNSET),
	target_ext(nullptr),
	target_filepath(nullptr),
	current_sourceline_index(0),
	current_segment_ptr(nullptr),
	local_labels_index(0),
	local_blocks_count(0),
	reusable_label_basename(nullptr),
	cond_off(0),
	if_pending(false),
	if_values_idx(0),
	charset(nullptr),
	cmd_dpos(),			// := invalid
	max_errors(30),
	pass(0),
	end(0),
	verbose(1),
	validity(invalid),
	labels_changed(0),
	labels_resolved(0),
	c_compiler(nullptr),
	is_sdcc(no),
	is_vcc(no),
	c_includes(nullptr),
	stdlib_dir(nullptr),
	c_tempdir(nullptr),
	c_qi(-1),
	c_zi(-1),
	ixcbr2_enabled(no),	// 	e.g. set b,(ix+d),r2
	ixcbxh_enabled(no),	// 	e.g. set b,xh
	target_z180(no),
	target_8080(no),
	syntax_8080(no),
	target_z80(yes),
	allow_dotnames(no),
	require_colon(no),
	casefold(no),
	flat_operators(no),
	compare_to_old(no),
	cgi_mode(no),
	asmInstr(&Z80Assembler::asmPseudoInstr)
{}

Z80Assembler::~Z80Assembler ()
{
	//ALT: wg. Doppelreferenzierung auf .globl-Label müssen erst die lokalen Labels[] gelöscht werden:
	//ALT: while(labels.count()>1) labels.drop();

	delete charset;
}



/* ==========================================================
				Assemble source
========================================================== */

void Z80Assembler::assembleFile (cstr sourcefile, cstr destpath, cstr listpath, cstr temppath,
								 int liststyle, int deststyle , bool clean) noexcept
{
	// assemble source file
	//   sname = fqn sourcefile
	//   dname = fqn outputfile; end on ".$" => extension fixed by #target; NULL => only pass 1
	//   lname = fqn listfile or NULL
	//   v = verbose output: include object code in list file
	//   w = include label listing in list file
	// output will be in
	//   source[];
	//   labels[];
	//   segments[];		// code and data segments
	//   errors[];

	timestamp = now();

	if (target_z180) { target_z80 = yes; }					// implied
	if (target_z80)  { target_8080 = no; }					// sanity

	if (syntax_8080) { if (!target_z80)  target_8080 = yes; }	// default to 8080
	else			 { if (!target_8080) target_z80  = yes; }	// default to Z80

	if (syntax_8080) { casefold = yes; }
	if (syntax_8080 || target_z180 || target_8080) { ixcbr2_enabled = ixcbxh_enabled = no; }

	asmInstr = &Z80Assembler::asmPseudoInstr;

	if (deststyle==0 && compare_to_old) deststyle = 'b';

	assert(!c_includes || (eq(c_includes,fullpath(c_includes)) && lastchar(c_includes)=='/' && !errno));
	assert(!stdlib_dir || (eq(stdlib_dir,fullpath(stdlib_dir)) && lastchar(stdlib_dir)=='/' && !errno));
	assert(!c_compiler || (eq(c_compiler,fullpath(c_compiler)) && lastchar(c_compiler)!='/' && !errno));

	sourcefile = fullpath(sourcefile, no);		   assert(errno==ok && is_file(sourcefile));
	if (destpath) { destpath = fullpath(destpath); assert(errno==ok || errno==ENOENT); }
	if (listpath) { listpath = fullpath(listpath); assert(errno==ok || errno==ENOENT); }
	if (temppath) { temppath = fullpath(temppath); assert(errno==ok && is_dir(temppath)); }

	assert(liststyle>=0 && liststyle<=15);
	assert(deststyle==0 || deststyle=='b' || deststyle=='x' || deststyle=='s');
	if (liststyle&8) liststyle |= 2;			// "with clock cycles" implies "with opcodes"

	source_directory = directory_from_path(sourcefile);
	source_filename  = filename_from_path(sourcefile);
	cstr basename    = basename_from_path(source_filename);

	cstr dest_directory = destpath ? directory_from_path(destpath) : destpath=source_directory;
	assert(is_dir(dest_directory));

	IFDEBUG( cstr list_directory = ) listpath ? directory_from_path(listpath) : listpath=dest_directory;
	assert(is_dir(list_directory));

	temp_directory = temppath ? temppath : dest_directory;
	assert(is_dir(temp_directory));
	if (clean && is_dir(catstr(temp_directory,"s/"))) delete_dir(catstr(temp_directory,"s/"),yes);

	try
	{
		if (c_compiler) init_c_compiler(c_compiler);

		StrArray source;
		source.append( catstr("#include ", quotedstr(sourcefile)) );
		assemble(source);

		if (errors.count()==0) checkTargetfile();

		if (errors.count()==0 && deststyle)
		{
			destpath = endswith(destpath,"/") ? catstr(destpath, basename, ".$") : destpath;
			if (compare_to_old)
			{
				cstr zpath = catstr("/tmp/zasm/test/",basename,".$");
				create_dir("/tmp/zasm/test/",0700,yes);
				writeTargetfile(zpath,deststyle);
				if (endswith(destpath,".$"))
					destpath = catstr(leftstr(destpath,strlen(destpath)-2), extension_from_path(zpath));
				FD old(destpath);	// may throw if n.ex.
				FD nju(zpath);
				long ofsz = old.file_size();
				long nfsz = nju.file_size();

				if (ofsz!=nfsz) setError("file size mismatch: old=%li, new=%li", ofsz, nfsz);
				uint32 bsize = uint32(min(ofsz,nfsz));
				uint8 obu[bsize]; old.read_data(obu,bsize);
				uint8 nbu[bsize]; nju.read_data(nbu,bsize);
				for (uint32 i=0; i<bsize && errors.count()<max_errors; i++)
				{
					if (obu[i]==nbu[i]) continue;
					setError("mismatch at $%04lX: old=$%02X, new=$%02X",ulong(i),obu[i],nbu[i]);
				}
				if (errors.count()) liststyle |= 2; else liststyle = 0;
			}
			else
			{
				writeTargetfile(destpath,deststyle);
			}
		}
	}
	catch (any_error& e) { setError("%s",e.what()); }

	if (errors.count() && compare_to_old) liststyle |= 6;	// opcodes, labels

	if (liststyle)
	{
		try
		{
			listpath = endswith(listpath,"/") ? catstr(listpath, basename, ".lst") : listpath;
			writeListfile(listpath, liststyle);
		}
		catch (any_error& e) { setError("%s",e.what()); }
	}
}

void Z80Assembler::setLabelValue (Label* label, Value const& value) throws
{
	setLabelValue(label,value.value,value.validity);
}

void Z80Assembler::setLabelValue (Label* label, int32 value, Validity validity) throws
{
	if (label->segment==nullptr)							// .globl or defined before ORG
	{
		label->segment = current_segment_ptr;			// mit '.globl' deklarierte Label haben noch kein Segment
		label->sourceline = current_sourceline_index;	// und keine Source-Zeilennummer
		if (!label->is_redefinable) current_sourceline().label = label;
	}

	if (label->is_redefinable)
	{
		if (label->is_valid()) labels_resolved--;
		if (validity==valid)   labels_resolved++;

		if (current_sourceline_index > label->sourceline)
			label->was_redefined = yes;
		goto x;
	}

	if (validity == valid)
	{
		if (label->is_valid())
		{
			if (value == label->value) return;
			else throw syntax_error("label redefined (use 'defl' or '=')");
		}
	}

	if (validity > label->value.validity)
		labels_resolved++;

	if (validity < label->value.validity)
		throw syntax_error("label %s value decayed",label->name);

	if (value!=label->value) labels_changed++;

x:	label->value.set(value,validity);
	label->is_defined = yes;
}

void Z80Assembler::assemble (StrArray& sourcelines) noexcept
{
	// assemble source[]
	// output will be in
	//   source[];
	//   labels[];
	//   segments[];
	//   errors[];

	source.purge();
	for (uint i=0;i<sourcelines.count();i++) { source.append(new SourceLine("", i, dupstr(sourcelines[i]))); }
	current_sourceline_index = 0;

	//target_str = NULL;
	target = TARGET_UNSET;

	// setup labels:
	labels.purge();
	labels.append(Labels(Labels::GLOBALS));		// global_labels must exist

	// setup segments:
	segments.purge();

	// add labels for options:
	if (syntax_8080)			global_labels().add(new Label("_asm8080_",	nullptr,0,1,valid,yes,yes,no));
	if (target_z80 && syntax_8080) global_labels().add(new Label("_z80_",	nullptr,0,1,valid,yes,yes,no));
	if (target_z180)			global_labels().add(new Label("_z180_",		nullptr,0,1,valid,yes,yes,no));
	if (target_8080)			global_labels().add(new Label("_8080_",		nullptr,0,1,valid,yes,yes,no));
	if (ixcbr2_enabled)			global_labels().add(new Label("_ixcbr2_",	nullptr,0,1,valid,yes,yes,no));
	if (ixcbxh_enabled)			global_labels().add(new Label("_ixcbxh_",	nullptr,0,1,valid,yes,yes,no));
	if (allow_dotnames)			global_labels().add(new Label("_dotnames_",	nullptr,0,1,valid,yes,yes,no));
	if (require_colon)			global_labels().add(new Label("_reqcolon_",	nullptr,0,1,valid,yes,yes,no));
	if (casefold)				global_labels().add(new Label("_casefold_",	nullptr,0,1,valid,yes,yes,no));
	if (flat_operators)			global_labels().add(new Label("_flatops_",	nullptr,0,1,valid,yes,yes,no));

	// setup errors:
	errors.purge();
	if (max_errors==0) max_errors = 30;

	// setup conditional assembly:
	cond_off = 0x00;
	static_assert(sizeof(cond[0])==1,"type of cond[] must be byte");
	memset(cond,no_cond,sizeof(cond));
	if_pending = false;
	if_values.purge();
	if_values_idx = 0;

	// Pass 1:
	// neue Label werden definiert
	// noch nicht definierte Label werden referenziert
	// benutzte, nicht definierte lokale Label werden in #endlocal 'nach außen' migriert.
	// #if, #include etc.

	pass = 1;
	assembleOnePass(pass);
	if (validity==valid || errors.count()) return;

	// Pass 2:
	// benutzte, aber nicht definierte Label werden in value() erkannt.
	// viele noch invaliden Label werden valide. (in einfachen Sourcen: alle)
	// viele Values werden jetzt valide.         (in einfachen Sourcen: alle)

	// Pass 3++:
	// alle benutzten Label sind auch definiert, evtl. aber noch invalid.
	// Einige Values waren noch nicht valide:
	// - kaskadierende Vorwärtsreferenzen
	// - (Bezugnahme auf) dynamische Segmentgrößen
	// --> weitermachen, solange Label valide werden

	do
	{
		if (pass>99) break;
		assembleOnePass(pass+1);
		if (verbose>1) log( "pass %u: %u labels resolved\n",pass,labels_resolved);
		if (validity==valid || errors.count()) return;
	}
	while (labels_resolved>0);

	if (pass>99) { setError("internal error: pass > 99"); return; } // 'labels_resolved' not properly updated
	if (validity==invalid) { setError("some labels failed to resolve"); return; }

	// Pass 4++
	// Es gibt immer noch Values, die preliminary sind,
	// aber es gibt keine Label mehr, die valide werden.
	// Wir versuchen einen Zustand zu erreichen, bei dem sich kein preliminary Label mehr ändert.
	// Den nehmen wir dann.

	if (verbose>1) log( "pass %u: some labels are still preliminary\n",pass);

	for (int i=0; i<25 && labels_changed>0; i++)
	{
		assembleOnePass(pass+1);
		if (verbose>1) log( "pass %u: %u labels changed value\n",pass,labels_changed);
		if (validity==valid || errors.count()) return;
	}

	if (labels_changed>0) { setError("some labels failed to settle"); return; }

	// Label values have settled.
	// jetzt müssen wir alles nochmal mit alle Labels = valid laufen lassen,
	// damit alle Tests durchgeführt werden.

	if (verbose>1) log( "pass %u: PRELIMINARY VALUES HAVE SETTLED\n",pass);

	Array<Validity> flags(0u,1000);
	for (uint j=0; j<labels.count(); j++ )
	{
		Array<RCPtr<Label>>& lbls = labels[j].getItems();
		for (uint i=0; i<lbls.count(); i++)
		{
			Label* l = lbls[i];
			if (l->is_used) { flags.append(l->value.validity); l->value.validity = valid; }
		}
	}
	DataSegments segments(this->segments);
	for (uint i=0; i<segments.count(); i++)
	{
		DataSegment& s = segments[i];
		flags.append(s.address.validity); s.address.validity = valid;
		flags.append(s.size.validity);    s.size.validity = valid;
		//s.flag.validity = valid;
		//s.csize.validity = valid;
		//s.dpos.validity = valid;
		//s.lpos.validity = valid;
	}

	assembleOnePass(pass+1);
	if (verbose>1) log( "pass %u: %u labels changed value\n",pass,labels_changed);
	if (errors.count() || validity!=valid)
	{
		uint fi = 0;
		for (uint j=0; j<labels.count(); j++ )
		{
			Array<RCPtr<Label>>& lbls = labels[j].getItems();
			for (uint i=0; i<lbls.count(); i++)
			{
				Label* l = lbls[i];
				if (l->is_used) l->value.validity = flags[fi++];
			}
		}
		for (uint i=0; i<segments.count(); i++)
		{
			DataSegment& s = segments[i];
			s.address.validity = flags[fi++];
			s.size.validity    = flags[fi++];
			//s.flag.validity = valid;
			//s.csize.validity = valid;
			//s.dpos.validity = valid;
			//s.lpos.validity = valid;
		}

		if (errors.count()) return;
		setError("source did not become valid. :-(");
		return;
	}

	if (verbose>1) log( "pass %u: SOURCE IS VALID :-)\n",pass);
}

void Z80Assembler::assembleOnePass (uint pass) noexcept
{
	this->pass = pass;

	// setup conditional assembly:
	//cond_off = 0x00;
	//if_pending = false;
	if_values_idx = 0;

	// reset charset conversion:
	delete charset;
	charset = nullptr;

	// final: true = this may be the last pass.
	// wird gelöscht, wenn:
	//	 label nicht in den locals gefunden wurde (wohl aber evtl. in den globals)
	//	 gefundenes label noch nicht valid ist
	//	 auf $ zugegriffen wird wenn !dptr_valid
	// we are finished if it is still set after this assembly pass
	validity = valid;
	labels_changed = 0;
	labels_resolved = 0;

	// set by #end -> source end before last line
	end = false;

	// init segments:
	asmInstr = &Z80Assembler::asmPseudoInstr;
	current_segment_ptr = nullptr;
	cmd_dpos = Value();			// invalidate dpos_at_start_of line for '$' and '$$': no segment!
	for (uint i=0;i<segments.count();i++) { segments[i]->rewind(); }

	// init labels:
	local_labels_index = 0;
	local_blocks_count = 1;
	reusable_label_basename = "";//DEFAULT_CODE_SEGMENT;

	// reset redefined redefinable labels to invalid:
	for (uint i=0;i<labels.count();i++)
	{
		Array<RCPtr<Label>>& labels = this->labels[i].getItems();
		for (uint j=0;j<labels.count();j++)
		{
			Label* l = labels[j];
			if (!l->is_redefinable) continue;
			if (l->was_redefined)
			{
				l->value.validity = invalid;
				labels_resolved--;
			}
			else
			{
				l->is_redefinable = no;
				assert(source[l->sourceline]->label == nullptr);
				source[l->sourceline]->label = l;
			}
		}
	}

	// assemble source:
	for (uint i=0; i<source.count() && !end; i++)
	{
		try
		{
			current_sourceline_index = i;	// req. for errors and labels
			assembleLine(source[i]);
			i = current_sourceline_index;	// some pseudo instr. skip some lines
		}
		catch(fatal_error& e)
		{
			setError(e);
			return;
		}
		catch(any_error& e)
		{
			setError(e);
			if (errors.count()>=max_errors) return;
		}
	}

	// stop on errors:
	if (errors.count()) return;
	if (cond[0]!=no_cond) { setError("#endif missing"); return; } // TODO: set error marker in '#if/#elif/#else' line
	assert(!cond_off);
	if (local_labels_index!=0) { setError("#endlocal missing"); return; } // TODO: set error marker in '#local' line

	try
	{
		// concatenate segments:
		// => set segment address for relocatable segments
		// => set segment size for resizable segments

		Value data_address(0,valid);	// for data segments
		Value code_address(0,valid);	// for code segments

		for (uint i=0; i<segments.count(); i++)
		{
			DataSegment* s = dynamic_cast<DataSegment*>(segments[i].ptr()); if (!s) continue;
			Value& seg_address = s->isData() ? data_address : code_address;

			if (s->resizable) s->setSize(s->dpos);
			else s->storeSpace(s->size-s->dpos);

			if (s->relocatable) s->setAddress(seg_address);

			Label* l;
			l = global_labels().find(s->name);
			setLabelValue(l, s->address);

			l = global_labels().find(catstr(s->name,"_size"));
			setLabelValue(l, s->size);

			l = global_labels().find(catstr(s->name,"_end"));
			setLabelValue(l, s->address+s->size);

			validity = min(validity,s->validity());

			seg_address = s->address + s->size;
		}

		compressSegments();
	}
	catch(any_error& e)
	{
		setError("%s",e.what());
		return;
	}
}

void Z80Assembler::assembleLine (SourceLine& q) throws
{
	// Assemble SourceLine

	q.rewind();							// if pass 2++
	if(pass==1) q.segment = current_segment_ptr;	// for Temp Label Resolver
	q.byteptr = current_segment_ptr ? currentPosition() : 0; // for Temp Label Resolver & Logfile
	//if (pass==1) q.bytecount = 0;		// for Logfile and skip over error in pass 2++
	if (current_segment_ptr) cmd_dpos = currentPosition();

	if (q.test_char('#'))		// #directive ?
	{
		asmDirect(q);
		q.expectEol();			// expect end of line
	}
	else if (cond_off)			// assembling conditionally off ?
	{
		if (q.testWord("endif")) { if (!q.testChar(':')) { asmEndif(q); q.expectEol(); } return; }
		if (q.testWord("if"))    { if (!q.testChar(':')) { asmIf(q);    q.expectEol(); } return; }
		//if (q.testWord("elif"))  { if (!q.testChar(':')) { asmElif(q);  q.expectEol(); } return; }
		//if (q.testWord("else"))  { if (!q.testChar(':')) { asmElse(q);  q.expectEol(); } return; }
		return;
	}
	else if (q.test_char('!'))	// test suite: this line must fail:
	{
		try
		{
			if (q[1]!=';')
			{
				if ((uint8(q[1]) > ' ' || require_colon) && (q[1]!='.' || allow_dotnames))
					asmLabel(q);						// label definition
				(this->*asmInstr)(q,q.nextWord());		// opcode or pseudo opcode
				while (q.testChar('\\') && current_segment_ptr)
				{
					cmd_dpos = currentPosition();
					(this->*asmInstr)(q,q.nextWord());	// opcode or pseudo opcode
				}
				q.expectEol();							// expect end of line
			}
		}
		catch (any_error&)		// we expect to come here:
		{
			assert(q.segment==current_segment_ptr);		// zunächst: wir nehmen mal an,
			//assert(currentPosition() == q.byteptr);	// dass dann auch kein Code erzeugt wurde

			if (current_segment_ptr)
			{
				if (q.segment==current_segment_ptr)
					q.bytecount = currentPosition() - q.byteptr;
				else
				{
					q.segment = current_segment_ptr;	// .area instruction
					q.byteptr = currentPosition();		// Für Temp Label Resolver & Logfile
					assert(q.bytecount==0);
				}
			}

			return;
		}
		throw syntax_error("instruction did not fail!");
	}
	else						// [label:] + opcode
	{
		try
		{
			if (q[0]!=';')
			{
				if ((uint8(q[0]) > ' ' || require_colon) && (q[0]!='.' || allow_dotnames))
					asmLabel(q);						// label definition
				(this->*asmInstr)(q,q.nextWord());		// opcode or pseudo opcode
				while (q.testChar('\\') && current_segment_ptr)
				{
					cmd_dpos = currentPosition();
					(this->*asmInstr)(q,q.nextWord());	// opcode or pseudo opcode
				}
				q.expectEol();							// expect end of line or '\'
			}

			if(current_segment_ptr)
			{
				if (q.segment==current_segment_ptr)
					q.bytecount = currentPosition() - q.byteptr;
				else
				{
					q.segment = current_segment_ptr;	// .area instruction
					q.byteptr = currentPosition();		// Für Temp Label Resolver & Logfile
					assert(q.bytecount==0);
				}
			}
		}
		catch (syntax_error& e)
		{
			if (pass>1)
				if (auto s = dynamic_cast<DataSegment*>(q.segment))
					s->skipExistingData(q.byteptr + q.bytecount - currentPosition());
			throw e;
		}
	}
}

uint Z80Assembler::assembleSingleLine (uint address, cstr instruction, char buffer[])
{
	// Minimalistic single line assembler for use with zxsp:
	// instruction will be prepended with a space
	// => only instructions, no labels, directives, etc.
	// returns size of assembled instruction or 0 for error

	StrArray sourcelines;
	sourcelines.append(catstr(" org ",tostr(address)));	// set the destination address (allow use of '$')
	sourcelines.append(catstr(" ",instruction));			// the instruction to assemble
	assemble(sourcelines);

	CodeSegment& segment = dynamic_cast<CodeSegment&>(current_segment());

	if (segment.size>4) setError("resulting code size exceeds size of z80 opcodes");	// defs etc.
	if (errors.count()) return 0;
	memcpy(buffer,segment.getData(),segment.size);
	return segment.size;
}

void Z80Assembler::skip_expression (SourceLine& q, int prio) throws
{
	cstr w = q.nextWord();				// get next word
	if (w[0]==0)						// end of line
eol:	throw syntax_error("unexpected end of line");

	if (w[1]==0)						// 1 char word
	{
		switch (w[0])
		{
		//case '#':	SDASZ80: immediate value prefix: only at start of expression
		//case '<':	SDASZ80: low byte of word	SDCC does not generate pruning operators
		//case '>':	SDASZ80: high byte of word	SDCC does not generate pruning operators
		case ';':	goto eol;			// comment  =>  unexpected end of line
		case '+':
		case '-':
		case '~':
		case '!':	skip_expression(q,pUna); goto op;
		case '(':	skip_expression(q,pAny); q.expect(')'); goto op;	// brackets
		case '.':
		case '$':	goto op; // $ = "logical" address at current code position
		}
	}
	else
	{
		// multi-char word:
		if (w[0]=='$' || w[0]=='%' || w[0]=='\'') goto op;	// hex number or $$, binary number or ascii number
	}

	if (is_dec_digit(w[0])) { q.test_char('$'); goto op; }	// decimal number or reusable label
	if (!is_letter(*w) && *w!='_' && *w!='.') throw syntax_error("syntax error");	// last chance: plain idf

	if (q.testChar('('))				// test for built-in function
	{
		if (eq(w,"defined") || eq(w,"hi") || eq(w,"lo") || eq(w,"min") || eq(w,"max") ||
			eq(w,"opcode") || eq(w,"target") || eq(w,"segment") || eq(w,"required") ||
			eq(w,"sin") || eq(w,"cos"))
		{
			for (uint nkl = 1; nkl; )
			{
				w = q.nextWord();
				if (w[0]==0) throw syntax_error("')' missing");	// EOL
				if (w[0]=='(') { nkl++; continue; }
				if (w[0]==')') { nkl--; continue; }
			}
		}
		else --q;	/* put back '(' */
	}

op:
	if (q.testEol()) return;			// end of line
	if (flat_operators) prio = pAny;

	switch (q.peekChar())				// peek next character
	{
	// TODO: and or xor eq ne gt ge lt le
	case '+':
	case '-':	if (pAdd<=prio) break; skip_expression(++q,pAdd); goto op;

	case '*':
	case '/':
	case '%':	if (pMul<=prio) break; skip_expression(++q,pMul); goto op;

	case '|':
	case '&':	if (q.p[1]==q.p[0]) { if (pBoolean<=prio) break; skip_expression(q+=2,pBoolean); goto op; }
				goto aa; aa:
	case '^':	if (pBits<=prio) break; skip_expression(++q,pBits); goto op;

	case '?':	if (pTriadic<=prio) break;
				skip_expression(++q,pTriadic-1); q.expect(':'); skip_expression(q,pTriadic-1); goto op;

	case '=':	if (pCmp<=prio) break;
				++q; q.skip_char('='); skip_expression(q,pCmp); goto op;			// equal: '=' or '=='

	case '!':	if (q[1]=='=') { if(pCmp<=prio) break; skip_expression(q+=2,pCmp); goto op; }	// !=
				break;// error

	case '<':
	case '>':	if (q.p[1]==q.p[0]) { if (pRot<=prio) break; skip_expression(q+=2,pRot); goto op; }	// >> <<
				// > < >= <= <>
				if (pCmp<=prio)	break;
				if (q.p[1]=='>' || q.p[1]=='=') ++q;
				skip_expression(++q,pCmp); goto op;
	}
}

Value Z80Assembler::value (SourceLine& q, int prio) throws
{
	// evaluate expression
	// stops if end of expression reached or
	// stops if operator with priority equal or less is encountered
	// any reference to unknown or not-yet-valid label sets argument 'valid' and 'this.final' to false

	Value n = N0;					// value of expression, valid

// ---- expect term ----
w:	cstr w = q.nextWord();			// get next word
	if (w[0]==0) goto syntax_error;	// empty word

	if (w[1]==0)						// 1 char word
	{
		switch (w[0])
		{
		case '#':	if (prio==pAny) goto w; else goto syntax_error;	// SDASZ80: immediate value prefix
		case ';':	throw syntax_error("value expected");	// comment  =>  unexpected end of line
		case '+':	n = +value(q,pUna); goto op;			// plus sign
		case '-':	n = -value(q,pUna); goto op;			// minus sign
		case '~':	n = ~value(q,pUna); goto op;			// complement
		case '!':	n = !value(q,pUna); goto op;			// negation
		case '(':	n =  value(q,pAny); q.expect(')'); goto op;	// brackets
		case '.':
		case '$':	n = dollar();  goto op;
		case '<':	q.expect('('); goto lo;		// SDASZ80: low byte of word
		case '>':	q.expect('('); goto hi;		// SDASZ80: high byte of word
		}
	}
	else							// multi-char word:
	{
		char c = 0;

		if (w[0]=='$')				// hex number or $$
		{
			w++;
			if (*w=='$')			// $$ = "physical" address of current code position  (segment.address+dpos)
			{
				w++;
				assert(*w==0);
				n = dollarDollar();
				goto op;
			}
			else					// hex number
			{
hex_number:		while (is_hex_digit(*w)) { n.value = (n.value<<4)+(*w&0x0f); if (*w>'9') n.value+=9; w++; }
				if (w[c!=0]==0) goto op; else goto syntax_error;
			}
		}
		else if (w[0]=='%')			// binary number
		{
			w++;
bin_number:	while (is_bin_digit(*w)) { n.value += n.value + (*w&1); w++; }
			if (w[c!=0]==0) goto op; else goto syntax_error;
		}
		else if (*w=='\'' || *w=='"')// ascii number: due to ambiguity of num vs. str only ONE CHARACTER ALLOWED!
		{							 // uses utf-8 or charset translation
									 // also allow "c" as a numeric value (seen in sources!)
			uint slen = strlen(w);
			if (slen<3||w[slen-1]!=w[0]) goto syntax_error;
			w = unquotedstr(w);
			n.value = charcode_from_utf8(w);
			if (charset) n.value = charset->get(n.value);
			if (*w) throw syntax_error("only one character allowed");
			goto op;
		}
		else if (is_dec_digit(w[0]))	// decimal number
		{
			if (w[0]=='0')
			{
				if (tolower(w[1])=='x' && w[2]) { w+=2; goto hex_number; }	// 0xABCD
				if (tolower(w[1])=='b' && w[2] && is_bin_digit(lastchar(w))) // caveat e.g.: 0B0h
												{ w+=2; goto bin_number; }	// 0b0101
			}
			c = tolower(lastchar(w));
			if (c=='h') goto hex_number;	// hex number     indicated by suffix
			if (c=='b') goto bin_number;	// binary number  indicated by suffix
		}
	}

	if (is_dec_digit(w[0]))			// decimal number or reusable label
	{
		if (q.test_char('$'))		// reusable label (SDASZ80)
		{
			w = catstr(reusable_label_basename,"$",w);
			goto label;
		}
		else						// decimal number
		{
			while (is_dec_digit(*w)) { n.value = n.value*10 + *w-'0'; w++; }
			if (*w==0) goto op;
			if ((*w|0x20)=='d' && *++w==0) goto op; // decimal number indicated by suffix --> source seen ...
			goto syntax_error;
		}
	}

	if (*w=='_' && eq(w,"__line__"))
	{
		n = q.sourcelinenumber; /* valid = valid && yes; */ goto op;
	}

	if (q.test_char('('))		// test for built-in function
	{
		if (eq(w,"defined"))	// defined(NAME)  or  defined(NAME::)
		{						// note: label value is not neccessarily valid
								// value of 'defined()' is always valid
			w = q.nextWord();
			if (!is_letter(*w) && *w!='_') throw fatal_error("label name expected");
			bool global = q.testChar(':')&&q.testChar(':');

			if (pass == 1)
			{
				for (uint i=global?0:local_labels_index;;i=labels[i].outer_index)
				{
					Label* label = labels[i].find(w);
					if (label!=nullptr && label->is_defined) { n=1; break; }
					if (i==0) { n=0; break; }
				}
				if_values.append(n);
			}
			else
			{
				n = if_values[if_values_idx++];
			}
			goto kzop;
		}
		if (eq(w,"required"))	// required(NAME)  or  required(NAME::)
		{						// note: label value is not neccessarily valid
								// value of 'required()' is always valid
			w = q.nextWord();
			if (!(is_letter(*w) || *w=='_' || (allow_dotnames&&*w=='.'))) throw fatal_error("label name expected");
			bool global = q.testChar(':')&&q.testChar(':');

			if (pass==1)
			{
				for (uint i=global?0:local_labels_index;;i=labels[i].outer_index)
				{
					Label* label = labels[i].find(w);
					if (label!=nullptr) { n = label->is_used && !label->is_defined; break; }
					if (i==0) { n=0; break; }
				}
				if_values.append(n);
			}
			else
			{
				n = if_values[if_values_idx++];
			}
			goto kzop;
		}
		else if (eq(w,"lo"))
		{
lo:			n = value(q);
			n.value = uint8(n.value);
			goto kzop;
		}
		else if (eq(w,"hi"))
		{
hi:			n = value(q);
			n.value = uint8(n.value>>8);
			goto kzop;
		}
		else if (eq(w,"min"))
		{
			Value m = value(q);
			q.expectComma();
			do { n = min(m,value(q)); } while (q.testComma());
			goto kzop;
		}
		else if (eq(w,"max"))
		{
			Value m = value(q);
			q.expectComma();
			do { n = max(m,value(q)); } while (q.testComma());
			goto kzop;
		}
		else if (eq(w,"sin")||eq(w,"cos"))		// sin(rot,fullrot,maxval)
		{
			Value a = value(q);		// angle
			q.expectComma();
			Value b = value(q);		// value for full rotation (==360°)
			if (abs(b)<4) { if (b.is_valid()) throw syntax_error("value for full circle must be ≥ 4"); b.value = 360; }
			q.expectComma();
			n = value(q);			// scale value for result (==1.0)
			if (n==0) { if (n.is_valid()) throw syntax_error("scale value for result must be ≥ 1"); n.value = 128; }

			n.validity = min(n.validity,min(a.validity,b.validity));
			float32 r  = a.value * 6.2831853f / b.value;
			n.value    = int32(roundf((eq(w,"sin") ? sinf(r) : cosf(r)) * n.value));
			goto kzop;
		}
		else if (eq(w,"opcode"))	// opcode(ld a,N)  or  opcode(bit 7,(hl))  etc.
		{
			cptr a = q.p;
			uint nkl = 1;
			while (nkl)
			{
				w = q.nextWord();
				if (w[0]==0) throw syntax_error("')' missing");	// EOL
				if (w[0]=='(') { nkl++; continue; }
				if (w[0]==')') { nkl--; continue; }
			}
			n = z80_major_opcode(substr(a,q.p-1));
			goto op;
		}
		else if (eq(w,"target"))
		{
			if (!target && current_segment_ptr==nullptr) throw syntax_error("#target not yet defined");
			n = q.testWord(target ? target_ext : "ROM");
			if (!n && !is_name(q.nextWord())) throw syntax_error("target name expected");
			goto kzop;
		}
		else if (eq(w,"segment"))
		{
			if (current_segment_ptr==nullptr) throw syntax_error("#code or #data segment not yet defined");
			n = q.testWord(current_segment_ptr->name);
			if (!n && !is_name(q.nextWord())) throw syntax_error("segment name expected");
			goto kzop;
		}
		else --q;	// put back '('
	}

	if (is_letter(*w) || *w=='_' || *w=='.')		// name: Label mit '.' auch erkennen wenn !allow_dotnames
	{
label:	if (casefold) w = lowerstr(w);

		if (pass==1)
		{
			/*
			In Pass 1 können auch gefundene, definierte globale Label noch durch lokalere Label,
			die im Source weiter hinten definiert werden, ersetzt werden.

			Label lokal nicht gefunden?
			=> ACTION: Label als referenziert & nicht definiert eintragen
			   dadurch kann das Label im Labellisting ausgegeben werden
			   context==lokal?
			   => wenn das Label bis #endlocal nicht definiert wurde,
				  wird es von #endlocal in den umgebenden Context verschoben
				  (oder evtl. gelöscht, wenn es das dort schon gibt)
				  Dadurch wandern nicht definierte Label in Richtung globaler Context
			   context==global?
			   => dadurch kann das Label von #include library definiert werden

			Label lokal gefunden?
			=> Label definiert?
			   => ACTION: dieses Label nehmen
			   Label noch nicht definiert?
			   => context==lokal?
				  => lokales Label?
					 => Label wurde schon einmal referenziert und dabei eingetragen
						ACTION: no action
					 globales label?
					 => Label wurde mit .globl deklariert
						es ist *auch* in globals[] eingetragen.
						wenn es später mit #include library definiert wird, wird es auch hier definiert sein.
						ACTION: no action
			   => context==global?
				  => lokales Label?
					 => can't happen (Internal Error)
					 globales Label?
					 => Label wurde schon einmal referenziert und dabei eingetragen
						oder Label wurde mit .globl deklariert
						ACTION: no action
			*/
			Label* l = local_labels().find(w);
			if (!l && if_pending)
			{
				for (uint i=local_labels_index; !l && i!=0; )
				{
					i = labels[i].outer_index;
					l = labels[i].find(w);
				}
			}
			if (!l)	// => ACTION: Label als referenziert & nicht definiert eintragen
			{
				l = new Label(w,nullptr,0,0,invalid,local_labels_index==0,no,yes);
				local_labels().add(l);
				n.validity = invalid;
			}
			n = l->value;
			l->is_used = true;
			goto op;
		}
		else
		{
			// Pass 2++:
			// Für das Label existiert ein Label-Eintrag in this.labels[][] weil in Pass 1 für alle
			// referenzierten Label ein Labeleintrag erzeugt wird. Dieser wird gesucht.
			// Ist er nicht als definiert markiert, wurde in Pass1 die Definition nicht gefunden. => Error

			for (uint i=local_labels_index; ; i=labels[i].outer_index)
			{
				Label* l = labels[i].find(w);
				if (!l) continue;
				if (!l->is_defined)
				{
					// Dies muss ein globales Label sein, da alle undeklarierten Label von #endlocal in den
					// umgebenden Kontext geschoben werden.
					// es kann aber evtl. schon in einem lokalen Kontext gefunden werden,
					// wenn es dort mit .globl deklariert wurde:
					assert(l->is_global);
					throw syntax_error("label \"%s\" not found",w);
				}
				if (l->was_redefined && l->is_invalid() && l->sourceline > current_sourceline_index)
					throw syntax_error("redefinable label \"%s\" not yet defined here",w);

				n = l->value;
				assert(l->is_used);
				goto op;
			}
		}
	}

// if we come here we are out of clues:
syntax_error:
	throw syntax_error("syntax error");

// expect ')' and goto op:
kzop:
	q.expect(')');
	goto op;

// ---- expect operator ----

op:	char c1,c2;
	if (q.testEol()) goto x;
	c1 = q.p[0]; if (is_uppercase(c1)) c1 |= 0x20;
	c2 = q.p[1]; if (is_uppercase(c2)) c2 |= 0x20;

	// flatops: the initial call to value() must handle all operators,
	//			recursive calls must immediately return:
	if (flat_operators && prio!=pAny) goto x;

	switch (prio+1)
	{
	//case pAny:
	case pTriadic:	// ?:
		if (c1=='?')
		{
			/*	note on pruning with invalid pruning selector:
				normal expressions just remain invalid.
				if not yet defined labels are referenced, they must be marked as 'referenced',
				even if the reference later is actually pruned.
			*/
			q+=1;
			if (n.validity == valid)
			{
				if (n) { n = value(q,pTriadic-1); q.expect(':'); skip_expression(q,pTriadic-1); }
				else   { skip_expression(q,pTriadic-1); q.expect(':'); n = value(q,pTriadic-1); }
			}
			else if (n.validity == preliminary)
			{
				Value a = value(q,pTriadic-1); q.expect(':'); Value b = value(q,pTriadic-1);
				n.value = n.value ? a.value : b.value;
				n.validity = min(n.validity,min(a.validity,b.validity));
			}
			else
			{
				Value a = value(q,pTriadic-1); q.expect(':'); Value b = value(q,pTriadic-1);
				n.value = min(a.value,b.value);
				//n.validity = invalid;
			}
		}
		goto bb;

	case pBoolean:	// && ||
	bb:	if (c1==c2)
		{
			if (c1=='&')	// '&&' --> boolean and
			{
				q+=2;
				if (n.is_valid())
				{
					if (n) n = value(q,pBoolean); else skip_expression(q,pBoolean);
					n.value = n.value != 0;
				}
				else if (n.is_preliminary())
				{

					Value m = value(q,pBoolean);
					n.value = n.value && m.value;
					n.validity = min(n.validity, m.validity);
				}
				else // invalid
				{
					value(q,pBoolean);
					n.value = 0;
					//n.validity = invalid;
				}
				goto op;
			}
			if (c1=='|')	// '||' --> boolean or
			{
				q += 2;
				if (n.is_valid())
				{
					if (n) skip_expression(q,pBoolean); else n = value(q,pBoolean);
					n.value = n.value != 0;
				}
				else if (n.is_preliminary())
				{
					Value m = value(q,pBoolean);
					n.value = n.value || m.value;
					n.validity = min(n.validity, m.validity);
				}
				else // invalid
				{
					value(q,pBoolean);
					n.value = 1;
					//n.validity = invalid;
				}
				goto op;
			}
		}
		goto cc;

	case pCmp:	// > < == >= <= !=
	cc:	if (c1>='a')
		{
			if (c1=='n' && c2=='e')  { n = n != value(q+=2,pCmp); goto op; }
			if (c1=='e' && c2=='q')  { n = n == value(q+=2,pCmp); goto op; }
			if (c1=='g' && c2=='e')  { n = n >= value(q+=2,pCmp); goto op; }
			if (c1=='g' && c2=='t')  { n = n >  value(q+=2,pCmp); goto op; }
			if (c1=='l' && c2=='e')  { n = n <= value(q+=2,pCmp); goto op; }
			if (c1=='l' && c2=='t')  { n = n <  value(q+=2,pCmp); goto op; }
		}
		else
		{
			if (c1=='=') { q+=c2-c1?1:2; n = n==value(q,pCmp); goto op; }	// equal: = ==
			if (c1=='!' && c2=='=') { n = n!=value(q+=2,pCmp); goto op; }	// not equal: !=
			if (c1=='<')
			{
				if (c2=='>')	{ n = n != value(q+=2,pCmp); goto op; }			// not equal:   "<>"
				if (c2=='=')	{ n = n <= value(q+=2,pCmp); goto op; }			// less or equ:	"<="
				if (c2!='<') { n = n <  value(q+=1,pCmp); goto op; }			// less than:	"<"
			}
			if (c1=='>')
			{
				if (c2=='=')	{ n = n >= value(q+=2,pCmp); goto op; }			// greater or equ:	">="
				if (c2!='>') { n = n >  value(q+=1,pCmp); goto op; }			// greater than:	">"
			}
		}
		goto dd;

	case pAdd:	// + -
	dd:	if (c1=='+') { n = n + value(++q,pAdd); goto op; }
		if (c1=='-') { n = n - value(++q,pAdd); goto op; }
		goto ee;

	case pMul:	// * / %
	ee:	if (c1=='*') { n = n * value(++q,pMul); goto op; }
		if (c1=='/')
		{
			Value m = value(++q,pMul);
			if (m==0) { if (m.validity!=valid) { m = 1; } else throw syntax_error("division by zero"); }
			n = n / m;
			goto op;
		}
		if (c1=='%')
		{
			Value m = value(++q,pMul);
			if (m==0) { if (validity==invalid) { m = 1; } else throw syntax_error("division by zero"); }
			n = n % m;
			goto op;
		}
		goto ff;

	case pBits:	// & | ^
	ff:	if (c1=='^')					  { n = n ^ value(++q, pBits); goto op; }
		if (c1=='&' && c2!='&')			  { n = n & value(++q, pBits); goto op; }
		if (c1=='|' && c2!='|')			  { n = n | value(++q, pBits); goto op; }
		if (c1=='a' && q.testWord("and")) { n = n & value(q,   pBits); goto op; }
		if (c1=='o' && c2=='r')			  { n = n | value(q+=2,pBits); goto op; }
		if (c1=='x' && q.testWord("xor")) { n = n ^ value(q,   pBits); goto op; }
		goto gg;

	case pRot:	// >> <<
	gg:	if (c1==c2)
		{
			if (c1=='<') { n = n << value(q+=2,pRot); goto op; }
			if (c1=='>') { n = n >> value(q+=2,pRot); goto op; }
		}

	//default:	// prio >= pUna
	//	break;
	}

// no operator or operator of same or lower priority followed
// =>  return value; caller will check the reason of returning anyway
x:	this->validity = min(n.validity, this->validity);
	return n;
}

void Z80Assembler::asmLabel (SourceLine& q) throws
{
	// Handle potential Label Definition

	cptr p = q.p;
	cstr name = q.nextWord();
	if (name[0]==0) return;			// end of line

	bool is_reusable = is_dec_digit(name[0]) && q.test_char('$');	// SDASZ80

	if (!is_reusable && !is_name(name))					// must be a pseudo instruction or broken code
	{													// or a label name with '.' and no --dotnames
		if (q.testChar(':'))
			throw syntax_error(*name=='.' ? "illegal label name (use option --dotnames)" : "illegal label name");
		q.p = p; return;
	}

	if (casefold) name = lowerstr(name);
	if (is_reusable) name = catstr(reusable_label_basename,"$",name);

	bool f = q.test_char(':');
	bool is_global = !is_reusable && ((f && q.test_char(':')) || local_labels().is_global);
	bool is_redefinable = no;
	Value n;

	if (q.testDotWord("equ"))
	{													// defined label:
		n = value(q);									// calc assigned value
	}
	else if (q.testWord("defl") || q.test_char('='))	// M80: redefinable label; e.g. used this way in CAMEL80
	{
		is_redefinable = yes;
		n = value(q);									// calc assigned value
	}
	else					// program label, SET or MACRO or no label
	{
		if (!is_reusable)	// SET and MACRO don't require ':'
		{
			// test for SET:							// this is really really bad:
			cptr z = q.p;								// there is a Z80 instruction SET
			if (q.testDotWord("set"))					// and the M80 pseudo instruction SET
			{											// and we'll have to figure out which it is…
				n = value(q);
				is_redefinable = q.testEol();
				if (is_redefinable) goto a;				// heureka! it's the pseudo instruction!
			}
			q.p = z;

			// test for MACRO:
			if (q.testDotWord("macro")) { asmMacro(q,name,'&'); return; }
		}

		if (require_colon && !f) { q.p = p; return; }	// must be a [pseudo] instruction

		if (!current_segment_ptr) throw syntax_error("org not yet set (use instruction 'org' or directive '#code')");
		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		n = static_cast<DataSegment*>(current_segment_ptr)->lpos;
		if (!is_reusable) reusable_label_basename = name;
	}

a:	Labels& labels = is_global ? global_labels() : local_labels();
	Label* l = labels.find(name);

	if (l)
	{
		if (pass==1 && is_redefinable != l->is_redefinable)
		{
			if (!l->is_defined)
				l->is_redefinable = is_redefinable;
			else
				throw syntax_error(is_redefinable ? "normal label redefined as redefinable label"
												  : "redefinable label redefined as normal label");
		}

		setLabelValue(l,n);
	}
	else
	{
		if (pass==1 && !syntax_8080) // 8080 all names allowed: mnenonic decides which arg is a register and which is a value
		{
			if (name[1]==0)	// strlen(name) == 1
			{
				cstr names = "irbcdehla";
				if (strchr(names,name[0])) throw syntax_error("'%s' is the name of a register",name);
			}
			else if (name[2]==0)	// strlen == 2
			{
				cstr names = target_z180 ? "bc de hl sp af" : "ix iy xh xl yh yl bc de hl sp af";
				if (find(names,name)) throw syntax_error("'%s' is the name of a register",name);
			}
			else if (name[3]==0 && !target_z180)	// strlen == 3
			{
				cstr names = "ixh iyh ixl iyl";
				if (find(names,name)) throw syntax_error("'%s' is the name of a register",name);
			}
		}

		l = new Label(name, &current_segment(), current_sourceline_index, n, is_global, yes, no);
		l->is_redefinable = is_redefinable;
		labels.add(l);
	}

	if (!is_redefinable)			// SET => value is void when writing the list file => don't list it
		q.label = l;				// this source line defines a label

	l->is_reusable = is_reusable;
}

void Z80Assembler::asmDirect (SourceLine& q) throws /*fatal_error*/
{
	// handle #directive
	// all errors are fatal
	// '#' must already be skipped
	// all errors are fatal

	try
	{
		cstr w = q.nextWord();

		if (lceq(w,"if"))		asmIf(q);			else
		if (lceq(w,"elif"))		asmElif(q);			else
		if (lceq(w,"else"))		asmElse(q);			else
		if (lceq(w,"endif"))	asmEndif(q);		else

		if (cond_off)			q.skip_to_eol();	else

		if (lceq(w,"target"))	asmTarget(q);		else
		if (lceq(w,"code"))		asmSegment(q,CODE);	else
		if (lceq(w,"data"))		asmSegment(q,DATA);	else
		if (lceq(w,"include"))	asmInclude(q);		else
		if (lceq(w,"insert"))	asmInsert(q);		else
		if (lceq(w,"cflags"))	asmCFlags(q);		else
		if (lceq(w,"cpath")) 	asmCPath(q);		else
		if (lceq(w,"local"))	asmLocal(q);		else
		if (lceq(w,"endlocal")) asmEndLocal(q);		else
		if (lceq(w,"assert"))	asmAssert(q);		else
		if (lceq(w,"charset"))	asmCharset(q);		else
		if (lceq(w,"define"))	asmDefine(q);		else
		if (lceq(w,"tzx"))		asmTzx(q);			else
		if (lceq(w,"compress"))	asmCompress(q);		else
		if (lceq(w,"end"))		asmEnd(q);			else
		if (lceq(w,"!"))		asmShebang(q);		else throw fatal_error("unknown assembler directive");
	}
	catch (fatal_error& e) { throw e; }
	catch (any_error& e)   { throw fatal_error("%s",e.what()); }
}

void Z80Assembler::asmShebang (SourceLine& q) throws
{
	// skip over "#!/path/to/zasm" in line 1

	//if(q.sourcelinenumber > 1) throw syntax_error("unexpected '#!': not in first line");
	q.skip_to_eol();
}

void Z80Assembler::asmCompress (SourceLine& q) throws
{
	// #compress NAME
	// #compress NAME1 to NAME2
	// -->
	// NAME1_to_NAME2_csize		compressed size
	// NAME1_to_NAME2_size		uncompressed size
	// NAME1_to_NAME2_cgain		size - csize
	// NAME1_to_NAME2_cdelta	minimum value for compressed_data.end - uncompressed_data.end in zx7uncompress

	if (pass>1) { q.skip_to_eol(); return; }

	cstr name = q.nextWord();
	if (!name) throw syntax_error("segment name expected");
	if (casefold) name = lowerstr(name);
	Label* l1 = global_labels().find(name);
	if (!l1) throw syntax_error("label not found");

	if (!l1->segment || !l1->segment->isCode()) throw syntax_error("code segment required");
	CodeSegment* s1 = dynamic_cast<CodeSegment*>(l1->segment); assert(s1);
	if (ne(s1->name,name)) throw syntax_error("segment name expected");

	Value size = s1->size;
	bool multiple = q.testWord("to");

	if (multiple)	// compress range of segments
	{
		cstr name2 = q.nextWord();
		if (!name2) throw syntax_error("segment name expected");
		if (casefold) name2 = lowerstr(name2);
		Label* l2 = global_labels().find(name2);
		if (!l2) throw syntax_error("label not found");

		if (!l2->segment || !l2->segment->isCode()) throw syntax_error("code segment required");
		CodeSegment* s2 = dynamic_cast<CodeSegment*>(l2->segment); assert(s2);
		if (ne(s2->name,name2)) throw syntax_error("segment name expected");

		if (s1==s2) goto a; // first == end segment

		CodeSegments segments(this->segments);

		uint a; for (a=0; ne(segments[a]->name,name); a++) {}		//must exist
		uint e; for (e=0; ne(segments[e]->name,name2); e++) {}		//must exist
		if (e<a) throw syntax_error("2nd segment before 1st segment");

		if (s1->compressed || s2->compressed)	// check for duplicate directive
		{
			if (s1->compressed==first_cseg && s2->compressed==last_cseg)
			{
				while (++a<e)
				{
					if (segments[a]->compressed != middle_cseg) break;
				}
			}
			if (a<e) throw syntax_error("segments overlap with other compressed segments");
			else return;	// duplicate
		}
		else	// mark segments for compression
		{
			assert(segments[a]->ccore.count()==0);
			assert(segments[a]->ucore.count()==0);
			segments[a]->compressed = first_cseg;
			while (++a<e)
			{
				if (segments[a]->compressed) throw syntax_error("segments overlap with other compressed segments");
				if (!segments[a]->relocatable) break;
				assert(segments[a]->ccore.count()==0);
				assert(segments[a]->ucore.count()==0);
				segments[a]->compressed = middle_cseg;
				size += segments[a]->size;
			}
			if (!segments[a]->relocatable) throw syntax_error("segments 2++ must have no start address");
			assert(segments[a]->ccore.count()==0);
			assert(segments[a]->ucore.count()==0);
			segments[a]->compressed = last_cseg;
			size += segments[a]->size;
		}

		name = catstr(name,"_to_",name2);
	}
	else	// compress single segment
	{
a:		if (s1->compressed == single_cseg) return;	// duplicate directive
		if (s1->compressed) throw syntax_error("segment is already part of other compressed segments");
		assert(s1->ccore.count()==0);
		assert(s1->ucore.count()==0);
		s1->compressed = single_cseg;
	}

	static const cstr ext[] = { "_size", "_csize", "_cgain", "_cdelta" };
	for (uint i=1-multiple; i<4; i++)
	{
		cstr n1 = catstr(name,ext[i]);
		Label* l = global_labels().find(n1); if (l&&l->is_defined) throw syntax_error("label %s redefined",n1);
		if (!l) global_labels().add(new Label(n1,current_segment_ptr,current_sourceline_index,0,invalid,yes,yes,no));
		else { l->is_defined = yes; l->segment = current_segment_ptr; l->sourceline = current_sourceline_index; }
	}
}

void Z80Assembler::compressSegments ()
{
	// compress segment or segments marked with data member 'compressed'
	// stores compressed data in seg.ccore
	// note: ccore validity = core.validity
	// 	  csize validity = size validity
	// sets labels
	// -->
	// NAME1_to_NAME2_csize		compressed size
	// NAME1_to_NAME2_size		uncompressed size
	// NAME1_to_NAME2_cgain		size - csize
	// NAME1_to_NAME2_cdelta	minimum offset for compressed_data.end - uncompressed_data.end

	// quick exit:
	bool compr = no;
	for (uint i=0; !compr && i<segments.count(); i++)
		if (auto s = dynamic_cast<CodeSegment*>(segments[i].ptr()))
			compr = s->compressed;
	if (!compr) return;

	// do it:
	CodeSegments segments(this->segments);

	for (uint i=0; i<segments.count(); )
	{
		CodeSegment* s1 = segments[i++];
		if (!s1->compressed) continue;
		assert(s1->compressed & first_cseg_mask);

		Array<uint8> ucore(s1->getData(),s1->size);
		Value usize(s1->size);
		Array<uint8> ccore;

		CodeSegment* s2 = s1;
		while (!(s2->compressed & last_cseg_mask))
		{
			assert(i<segments.count());
			s2 = segments[i++];
			assert(s2->compressed);

			ucore.append(s2->getData(),s2->size);
			usize += s2->size;
		}

		bool multiple = s1 != s2;
		cstr name = multiple ? catstr(s1->name,"_to_",s2->name) : s1->name;

		if (usize>0x10000 && usize.is_valid())
			throw fatal_error("%s_size exceeds $10000 bytes (size=%u)",name,int32(usize));

		if (ucore.count()==s1->ucore.count() && memcmp(ucore.getData(),s1->ucore.getData(),ucore.count()) == 0)
		{
			if (verbose>1) log("pass %u: compress %s: cache hit :-)\n",uint(pass),name);
			return;
		}

		// compress data:
		const uint32 skip = 0;
		int32 delta = 0;
		ucore.shrink(0x10000);	// just in case
		ccore = compress(ucore, skip, &delta);

		// set labels:
		if(multiple)
		setLabelValue( global_labels().find(catstr(name,"_size")),  usize);
		setLabelValue( global_labels().find(catstr(name,"_csize")), ccore.count(), preliminary);
		setLabelValue( global_labels().find(catstr(name,"_cgain")), usize - ccore.count(), preliminary);
		setLabelValue( global_labels().find(catstr(name,"_cdelta")), delta, preliminary);

		s1->ccore = ccore;
		s1->ucore = ucore;
	}
}

void Z80Assembler::asmDefine (SourceLine& q) throws
{
	// #define <macro> <replacement>
	// define some kind of replacement
	//
	// #define	NAME,NAME			rename instruction
	// #define NAME,EXPRESSION		macro for expression
	// #define NAME(ARGS,…) STUFF	macro which may expand to multiple lines by means of a simple '\'
	//								Aufruf mit NAME(ARGS,…)   (wie im C Preprozessor)

	// Test for: preprocessor function:
	//	#define note(l1,l2,r1,r2,time) .dw l1+(l2*256)\.dw r1+(r2*256)\.dw time

	if (q.testChar('(')) throw fatal_error("preprocessor functions are not supported: use macros.");

	// Test for: renamed instruction:
	//	#define DEFB .BYTE
	//	#define DEFW .WORD
	//	#define DEFM .TEXT
	//	#define ORG  .ORG
	//	#define EQU  .EQU
	//	#define equ  .EQU

	if (q.testDotWord("equ"))
	{
		if (q.testDotWord("equ")) return;
		else goto unknown_instr;
unknown_instr:
		throw fatal_error("unknown instruction");
	}

	if (q.testDotWord("org"))
	{
		if (q.testDotWord("org")) return;
		else goto unknown_instr;
	}

	if (q.testWord("defw") || q.testWord(".word") || q.testDotWord("dw"))
	{
		if (q.testWord("defw") || q.testWord(".word") || q.testDotWord("dw")) return;
		else goto unknown_instr;
	}

	if (q.testWord("defb") || q.testWord(".byte") || q.testDotWord("db"))
	{
		if (q.testWord("defb") || q.testWord(".byte") || q.testDotWord("db")) return;
		else goto unknown_instr;
	}

	if (q.testWord(".text") || q.testWord(".ascii") || q.testDotWord("dm") || q.testWord("defm"))
	{
		if (q.testWord(".text") || q.testWord(".ascii") || q.testDotWord("dm") || q.testWord("defm")) return;
		else goto unknown_instr;
	}

	if (q.testWord(".block") || q.testDotWord("ds") || q.testWord("defs"))
	{
		if (q.testWord(".block") || q.testDotWord("ds") || q.testWord("defs")) return;
		else goto unknown_instr;
	}

	// Test for: const aka label definition:
	//	#define strlen 7
	//	#define	progStart	06900h
	//	#define	LF		0Ah
	//	#define	CR		0Dh
	//	#define	BDOS	00005h
	//	#define	BUFTOP	04000h
	//	#define	CALSLT	0001Ch

	cstr w = q.nextWord();
	if (!is_name(w)) throw syntax_error("name expected");
	if( casefold) w = lowerstr(w);

	Value n = value(q);
	Label* l = global_labels().find(w);

	if (l)
	{
		setLabelValue(l,n);
	}
	else
	{
		if (pass==1 && !syntax_8080) // 8080 all names allowed: mnenonic decides which arg is a register and which is a n
		{
			if (w[1]==0)	// strlen(name) == 1
			{
				cstr names = "irbcdehla";
				if (strchr(names,w[0])) throw syntax_error("'%s' is the name of a register",w);
			}
			else if (w[2]==0)	// strlen == 2
			{
				cstr names = target_z180 ? "bc de hl sp af" : "ix iy xh xl yh yl bc de hl sp af";
				if (find(names,w)) throw syntax_error("'%s' is the name of a register",w);
			}
			else if (w[3]==0 && !target_z180)	// strlen == 3			2016-10-01
			{
				cstr names = "ixh iyh ixl iyl";
				if (find(names,w)) throw syntax_error("'%s' is the name of a register",w);
			}
		}

		l = new Label(w, current_segment_ptr, current_sourceline_index, n, yes, yes, no);
		global_labels().add(l);
	}

	q.label = l;				// this source line defines a label
}

void Z80Assembler::asmRept (SourceLine& q, cstr endm) throws
{
	//  rept	N
	//  ;
	//  ; some instructions
	//  ;
	//  endm

	uint32& e = current_sourceline_index;
	uint32  a = e;

	Value n;
	if (pass==1)
	{
		if (q.testEol()) { n=1; setError("number of repetitions missing"); }
		else
		{
			if_pending = yes;		// => global labels can be used
			try {n = value(q);} catch (any_error& e) { n=1; setError(e); }
			if_pending = no;
			if (!n.is_valid()){ n=1; setError("count must be evaluatable in pass 1"); }
			if (n>0x8000)     { n=1; setError("number of repetitions too high"); }
			if (n<0)          { n=1; setError("number of repetitions negative"); }
		}
	}

	// skip over contained instructions:
	// does not check for interleaved macro def or similar.
	for (;;)
	{
		if (++e>=source.count()) throw fatal_error("end of repetition (instruction '%s') missing", endm);
		SourceLine& s = source[e];
		if (s[0]=='#') throw fatal_error("unexpected assembler directive inside macro");
		s.rewind();
		if (s.testDotWord(endm)) break;
		//if (s.testDotWord("endm")) throw fatal_error("");
		//if (s.testDotWord("edup")) throw fatal_error("");
		if (s.testDotWord("rept")) throw fatal_error("nested repetition macro");
		if (s.testDotWord("dup")) throw fatal_error("nested repetition macro");
		//if (s.testDotWord("macro")) throw fatal_error("");
	}

	if (pass==1)
	{
		if (source.count() + n*(e-a-1) > 1000000)
			throw fatal_error("total source exceeds 1,000,000 lines");
	}
	else // if (pass>1)	// => just skip the rept macro
	{
		q.skip_to_eol();
		return;
	}

	RCArray<SourceLine> zsource;
	while (n.value--)
	{
		for (uint32 i=a+1; i<e; i++)
		{
			zsource.append(new SourceLine(source[i]));
		}
	}
	source.insertat(e+1,zsource);
}

void Z80Assembler::asmMacro (SourceLine& q, cstr name, char tag) throws
{
	//	NAME macro
	//	NAME macro ARG,ARG…
	//	;
	//	; some instructions
	//	;	&ARG may refer to ARG
	//	;	#ARG may refer to #ARG
	//	;
	//		endm
	//	;
	//	; invocation:
	//	;
	//		NAME ARG,…
	//
	//	tag = potential tag character, e.g. '&'
	//	seen syntax:
	//	NAME macro ARG	; def
	//		NAME &ARG	; substitution in call
	//	NAME macro #ARG	; def
	//		NAME #ARG	; substitution in call
	//	.macro NAME ARG	; def
	//		NAME \ARG	; substitution in call
	//
	//	the good thing is, they all _have_ a tag befor the argument reference…

	name = lowerstr(name);

	if (pass>1)	// => skip the macro definition
	{
		q.skip_to_eol();
		current_sourceline_index = macros[name].endm;
		source[current_sourceline_index]->skip_to_eol();
		return;
	}

	if (macros.contains(name)) throw fatal_error("macro redefined");

	// parse argument list:
	Array<cstr> args;
	if (!q.testEol())
	{
		if (strchr("!#$%&.:?@\\^_|~",*q)) tag = *q;		// test whether args in def specify some kind of tag
		do												// else use the supplied (if any)
		{
			if (tag) q.testChar(tag);
			cstr w = q.nextWord();
			if (!is_name(w)) throw syntax_error("argument name expected");
			else args.append(w);
		}
		while (q.testChar(','));
		q.expectEol();
	}

	uint32& e = current_sourceline_index;
	uint a = e;

	// skip over contained instructions:
	// does not check for interleaved macro def or similar.
	while (++e<source.count())
	{
		SourceLine& s = source[e];
		s.rewind();
		if (s[0]=='#')
		{
			if (tag=='#' && is_name(++s.p) && args.contains(s.nextWord())) continue;
			throw fatal_error("unexpected assembler directive inside macro");
		}
		if (s.testDotWord("endm"))
		{
			s.skip_to_eol();	// problem: eof error would be reported on line with macro definition
			macros.add(name,Macro(std::move(args),a,e,tag)); // note: args[] & name are unprotected cstr in tempmem!
			return;
		}
	}
	throw fatal_error("endm missing");
}

void Z80Assembler::asmMacroCall (SourceLine& q, Macro& m) throws
{
	// Expand macro in pass1:

	if (pass>1) { q.skip_to_eol(); return; }

	int32 n;
	cstr w;

	// read arguments in macro call:
	Array<cstr> rpl;
	if (!q.testEol()) do
	{
		if (q.testChar('<'))		// extended argument: < ... " ... ' ... , ... ; ... > [,;\n]
		{
			cptr aa = q.p;
			cptr ae;
			do
			{
				while (*q && *q!='>') { ++q; } if (*q==0) throw syntax_error("closing '>' missing");
				ae = q.p;
				++q;			// skip '>'
			}
			while (!q.testEol() && *q!=',');

			// closing '>' found and skipped

			rpl.append(substr(aa,ae));
		}
		else					// simple argument: '"' and ''' must be balanced,
								// ',' and ';' can't occur in argument (except in char/string literal)
		{						// '(' or ')' may be unbalanced
			cptr  aa = q.p;
			char  c;
			while ((c=*q.p) && c!=',' && c!=';')
			{
				if (c!='"'&&c!='\'') { q.p++; continue; }
				w = q.nextWord();
				n = int32(strlen(w));
				if (n<2||w[n-1]!=c) throw syntax_error("closing '%c' missing",c);
			}
			while (q.p>aa && *(q.p-1)<=' ') { q.p--; }
			//if (aa==q.p) throw syntax_error("empty argument (use <>");		denk…
			rpl.append(substr(aa,q.p));
		}
	}
	while (q.testComma());

	assert(q.testEol());

	// get arguments in macro definition:
	Array<cstr>& args = m.args;
	if (rpl.count()<args.count()) throw syntax_error("not enough arguments: required=%i",args.count());
	if (rpl.count()>args.count()) throw syntax_error("too many arguments: required=%i",args.count());

	// get text of macro definition:
	uint32 i = m.mdef;
	uint32 e = m.endm;
	RCArray<SourceLine> zsource;
	while (++i < e)
	{
		zsource.append(new SourceLine(source[i]));
		// das übernehmen wir:
		//	text;						// tempmem / shared
		//	sourcefile;					// tempmem / shared between all sourcelines of this file
		//	sourcelinenumber;			// line number in source file; 0-based
		// die sollten alle noch leer sein, da die Zeilen in der mdef selbst nie assembliert werden:
		//	s->segment = NULL;			// of object code
		//	s->byteptr = 0;				// index of object code in segment
		//	s->bytecount = 0;			// of bytes[]
		//	s->label = NULL;			// if a label is defined in this line
		//	s->is_data = 0;				// if generated data is no executable code
		//	s->p = s->text;				// current position of source parser
	}

	// replace arguments:
	for (i=0; i<zsource.count(); i++)	// loop over lines
	{
		SourceLine& s = zsource[i];

		for (ssize_t j=0;;j++)			// loop over occurance of '&'
		{
			cptr p = strchr(s.text+j,m.tag);	// at next '&'
			if (!p) break;						// no more '&'
			if (!is_name(p+1)) continue;		// not an argument

			s.p = p+1; w = s.nextWord();		// get potential argument name
			if (casefold) w = lowerstr(w);

			uint a = args.indexof(w);			// get index of argument in argument list
			if (a == ~0u) continue;				// not an argument

			// w is the name of argument #a
			// it was found starting at p+1 in s.text  (p points to the '&')

			j = p + strlen(rpl[a]) - s.text;				// calculate index j after text replacement
			s.text = catstr(substr(s.text,p), rpl[a], s.p);	// … because this reallocates s.text!
		}

		// calculate and replace values between '{' and '}' with plain text:
		// e.g. for calculated label names in macros.
		for (ssize_t j=0;;j++)			// loop over occurrences of '{'
		{
			cptr p = strchr(s.text+j,'{');	    // at next '{'
			if (!p) break;						// no more '{'
			s.p = p+1;							// set the parser position behind '{'
			Value v = value(s, pAny);			// get the value
			s.expect('}');
			if (!v.is_valid()) throw syntax_error("value must be valid in pass 1"); // because replacement is done in pass 1
			cstr rpl = numstr(v.value);			// textual replacement
			j = p + strlen(rpl) - s.text;					// calculate index j after text replacement
			s.text = catstr(substr(s.text,p), rpl, s.p);	// … because this reallocates s.text!
		}

		s.rewind();	// superflux. but makes s.p valid
	}

	// insert text of macro definition into source:
	source.insertat(current_sourceline_index+1,zsource);
}

void Z80Assembler::asmCharset (SourceLine& q) throws
{
	//  #charset zxspectrum			; zx80, zx81, zxspectrum, jupiterace, ascii
	//  #charset none				;			 reset to no mapping
	//  #charset map "ABC" = 65		; or add:	 add mapping(s)
	//  #charset unmap "£"			; or remove: remove mapping(s)

	cstr w = q.nextWord();
	Value n;

	if (lceq(w,"map") || lceq(w,"add"))				// add mapping
	{
		w = q.nextWord();
		if (w[0]!='"') throw syntax_error("string with source character(s) expected");
		if (!q.testChar('=') && !q.testChar(',') && !q.testWord("to")) throw syntax_error("keyword 'to' expected");
		n = value(q);
		if (n.is_valid() && (n < -0x80 || n > 0xff)) throw syntax_error("destination char code out of range");
		if (!charset) charset = new CharMap();
		charset->addMappings(unquotedstr(w),n);		// throws on illegal utf-8 chars
	}
	else if (lceq(w,"unmap") || lceq(w,"remove"))	// remove mapping
	{
		if (!charset) throw syntax_error("no charset in place");
		w = q.nextWord();
		if (w[0]!='"') throw syntax_error("string with source character(s) for removal expected");
		charset->removeMappings(unquotedstr(w));	// throws on illegal utf-8 chars
	}
	else if (lceq(w,"none"))						// reset mapping to no mapping at all
	{
		delete charset;
		charset = nullptr;
	}
	else											// select charset
	{
		CharMap::CharSet cs = CharMap::charsetFromName(w);
		if (cs==CharMap::NONE) throw syntax_error("map, unmap, none or charset name expected");
		delete charset;
		charset = new CharMap(cs);
	}
}

void Z80Assembler::asmAssert (SourceLine& q) throws
{
	Value n = value(q);

	//if (!v) throw fatal_error("the expression was not evaluatable in pass 1");
	if (n.is_valid() && !n) throw fatal_error("assertion failed");
}

void Z80Assembler::init_c_compiler (cstr cc) throws
{
	// init c_compiler, c_tempdir and c_flags
	// cc: NULL, "vcc", "sdcc", "fullpath/vcc" or "fullpath/sdcc"

	if (!cc) // #CFLAGS without #CPATH => assume command line argument "-c sdcc"
	{
		cc = sdcc_compiler_path ? sdcc_compiler_path : find_executable("sdcc");
		if (!cc) throw fatal_error("can't find c-compiler sdcc (use cmd line option -c or directive '#cpath')");
	}
	else if (eq(cc,"sdcc")) cc = sdcc_compiler_path ? sdcc_compiler_path : find_executable(cc);
	else if (eq(cc,"vcc")) cc = vcc_compiler_path ? vcc_compiler_path : find_executable(cc);

	cc = fullpath(cc);
	if (errno) throw fatal_error("%s: %s", cc, strerror(errno));
	if (!is_file(cc)) throw fatal_error("%s: not a regular file", cc);
	if (!is_executable(cc)) throw fatal_error("%s: not executable", cc);

	c_compiler = cc;
	init_c_flags();
	init_c_tempdir();
}

void Z80Assembler::asmCPath (SourceLine& q) throws
{
	// #CPATH "/path/to/c-compiler"
	// Set path to c compiler executable
	// - not allowed in cgi-mode
	// - set c_compiler only if not yet set (NULL)
	//   => command line argument overrides #CPATH
	// this directive should occur very early and at most once in the source.

	if (cgi_mode) throw fatal_error("#CPATH not allowed in CGI mode");
	if (c_compiler) { q.skip_to_eol(); return; }		// pass 2++ or set on command line

	cstr cc = get_filename(q);	// fqn
	init_c_compiler(cc);
}

void Z80Assembler::asmCFlags (SourceLine& q) throws
{
	// #CFLAGS -opt1 -opt2 …
	// arguments may be quoted
	// detects special arguments $SOURCE, $DEST and $CFLAGS
	// validates path in -Ipath
	// setup for sdcc if c_compiler is not yet set
	// notes:
	// argv[0] (the executable's path) is not included in c_flags[].
	// $SOURCE and $DEST may be present or missing: then c_qi or c_zi = -1
	// $CFLAGS adds the old cflags.
	// in #include: default argv[] =
	//   sdcc:  { "/…/sdcc", "-S", "-mz80", [ "--nostdinc", "-Ipath", ] "-o", outfile, sourcefile }
	//   vcc:   { "/…/vcc", [ "-Ipath", ] "-o=outfile", sourcefile }

	if (pass>1) { q.skip_to_eol(); return; }	// c-source was compiled in pass 1!

	if (!c_compiler) init_c_compiler();		// find SDCC as with command line argument "-c sdcc"

	assert(c_qi<int(c_flags.count()) && c_zi<int(c_flags.count()));

	Array<cstr> old_cflags(std::move(c_flags));			// moves contents
	int old_c_qi = c_qi; c_qi = -1;
	int old_c_zi = c_zi; c_zi = -1;

	if (c_includes)		// preserve c_includes from command line:
	{
		if (is_sdcc)
		{
			assert(old_cflags.count() && eq(old_cflags[0],"--nostdinc"));
			c_flags.append(old_cflags[0]);
			old_cflags.removeat(0); old_c_qi--; old_c_zi--;
		}
		assert(old_cflags.count() && eq(catstr("-I",c_includes),old_cflags[0]));
		c_flags.append(old_cflags[0]);
		old_cflags.removeat(0); old_c_qi--; old_c_zi--;
	}

	while (!q.testEol())
	{
		cstr s;
		cptr a = q.p;
		if (*a == '"' || *a == '\'')			// quoted?
		{
			while (*++q && *q != *a) {}
			s = substr(a+1,q.p);
			if (*q) ++q;
		}
		else
		{
			while (uint8(*q)>' ') ++q;
			s = substr(a,q.p);
		}

		if (s[0]=='$')
		{
			if (eq(s,"$SOURCE"))
			{
				if (c_qi >= 0) throw fatal_error("$SOURCE redefined");
				c_qi = c_flags.count();
			}

			if (eq(s,"$DEST"))
			{
				if (c_zi >= 0) throw fatal_error("$DEST redefined");
				c_zi = c_flags.count();
			}

			if (eq(s,"$CFLAGS"))
			{
				if (old_c_qi >= 0 && c_qi >= 0) throw fatal_error("$SOURCE redefined");
				if (old_c_zi >= 0 && c_zi >= 0) throw fatal_error("$DEST redefined");
				if (old_c_qi >= 0) c_qi = old_c_qi + c_flags.count();
				if (old_c_zi >= 0) c_zi = old_c_zi + c_flags.count();
				c_flags.append(old_cflags);	// moves contents
				continue;
			}
		}

		if (cgi_mode && s[0]=='-')
		{
			// gefährliche Optionen im CGI-Mode verbieten:
			//	eigentlich sollte man eine whitelist verwenden,
			//	aber für den 'sdcc' ohne Linker sollten es diese beiden sein.
			//	'vcc' kann nicht vorkommen, weil das cgi-script fest den sdcc vorgibt.
			//	((dann würde hierdurch auch das Einstellen der Optimierung -o0 … -o3 verboten.))

			if (s[1]=='o') throw fatal_error("option '-o' not allowed in CGI mode"); // set output file
			if (s[1]=='I') throw fatal_error("option '-I' not allowed in CGI mode"); // set dir for include files
		}

		if (s[0]=='-' && s[1]=='I')	// -I/full/path/to/include/dir
		{							// -Ior/path/rel/to/source/dir	=> path in #cflags is relative to source file!
			cstr path = s+2;
			if (path[0]!='/') path = catstr(source_directory,path);
			path = fullpath(path); if (errno) throw fatal_error(errno);
			if(lastchar(path)!='/') throw fatal_error(ENOTDIR);
			s = catstr("-I",path);
		}

		c_flags.appendifnew(s);
	}

	init_c_tempdir();
}

void Z80Assembler::asmEnd (SourceLine& q) throws
{
	// #end
	// force end of assembler source
	// must not be within #if …

	end = true;

	cstr w = q.nextWord();		// seen in some source: "  end <label>"
	if (*w && !global_labels().find(w)) throw syntax_error("end of line or label name expected");

//	// assign default segment to all remaining source lines
//	// to keep writeListfile() happy:
//	if(pass>1) return;
//	for(uint i=current_sourceline_index+1; i<source.count();i++) { source[i].segment = &segments[0]; }
}

void Z80Assembler::asmIf (SourceLine& q) throws
{
	// #if <condition>
	// start block of source which is only assembled if value==true
	// condition must be evaluatable in pass 1
	// any number of #elif may follow
	// then a single #else may follow
	// then final #endif must follow
	// while assembling is disabled, only #if, #else, #elif and #endif are recognized
	// and #include is also skipped if conditional assembly is off.

	if (cond[NELEM(cond)-1] != no_cond) throw fatal_error("too many conditions nested");

	Value f(false);
	if (cond_off)
	{
		q.skip_to_eol();
	}
	else
	{
		if_pending = yes;
		f = value(q);
		if_pending = no;
		if (!f.is_valid()) throw fatal_error("condition not evaluatable in pass1");
		if (pass==1) if_values.append(f);
		else if (if_values[if_values_idx++] != f) throw fatal_error("condition changed in pass%i",pass);
	}

	memmove( cond+1, cond, sizeof(cond)-sizeof(*cond) );
	cond[0] = cond_if + !!f;
	cond_off = (cond_off<<1) + !f;
}

void Z80Assembler::asmElif (SourceLine& q) throws
{
	// #elif <condition>
	// condition must be evaluatable in pass 1

	switch (cond[0])			// state of innermost condition
	{
	default:			IERR();
	case no_cond:		throw syntax_error("#elif without #if");
	case cond_else:		throw syntax_error("#elif after #else");

	case cond_if_dis:			// we are in an if or elif clause and there was already a true condition
		cond_off |= 1;			// disable #elif clause
		q.skip_to_eol();		// just skip expression
		break;

	case cond_if:				// we are in an if or elif clause and up to now no condition was true
		assert(cond_off&1);

		Value f(cond_off>>1);	// outer nesting level
		if (f) q.skip_to_eol();	// outer nesting level off => just skip expression; value is irrelevant
		else
		{
			if_pending = yes;
			f = value(q);		// else evaluate value
			if_pending = no;
			if (!f.is_valid()) throw fatal_error("condition must be evaluatable in pass1");
			if (pass==1) if_values.append(f);
			else if (if_values[if_values_idx++] != f) throw fatal_error("condition changed in pass%i",pass);
		}

		cond_off -= !!f;		// if f==1 then clear bit 0 => enable #elif clause
		cond[0]  += !!f;		// and switch state to cond_if_dis => disable further elif evaluation
		break;
	}
}

void Z80Assembler::asmElse (SourceLine&) throws
{
	// #else

	switch (cond[0])
	{
	default:			IERR();
	case no_cond:		throw syntax_error("#else without #if");
	case cond_else:		throw syntax_error("multiple #else clause");

	case cond_if_dis:			// we are in an if or elif clause and there was already a true condition
		cond[0] = cond_else;
		cond_off |=  1;			// disable #else clause
		break;

	case cond_if:				// we are in an if or elif clause and up to now no condition was true
		cond[0] = cond_else;
		cond_off &= ~1u;		// enable #else clause
		break;
	}
}

void Z80Assembler::asmEndif (SourceLine&) throws
{
	// #endif

	if (cond[0]==no_cond) throw syntax_error("no #if pending");

	memmove(cond, cond+1, sizeof(cond)-sizeof(*cond));
	cond[NELEM(cond)-1] = no_cond;
	cond_off = cond_off>>1;
}

void Z80Assembler::asmTarget (SourceLine& q) throws
{
	if (pass>1) { q.skip_to_eol(); return; }
	if (target) throw fatal_error("#target redefined");
	assert(!current_segment_ptr);

	static HashMap<cstr,Target> targets;
	if (targets.count() == 0)
	{
		targets.add("rom",ROM);
		targets.add("bin",BIN);
		targets.add("z80",Z80);
		targets.add("sna",SNA);
		targets.add("tap",TAP);
		targets.add("tape",TAP);
		targets.add("80",ZX80);
		targets.add("o",ZX80);
		targets.add("81",ZX81);
		targets.add("p",ZX81);
		targets.add("p81",ZX81P);
		targets.add("ace",ACE);
		targets.add("tzx",TZX);
	}

	target_ext = q.nextWord();
	target = targets.get(lowerstr(target_ext), TARGET_UNSET);
	if (!target) throw syntax_error("target name expected");
}

void Z80Assembler::asmInclude (SourceLine& q) throws
{
	// #INCLUDE "sourcefile"
	// the file is included in pass 1
	// filenames ending on ".c" are compiled with sdcc (or the compiler set on the cmd line) into the temp directory
	//
	// #INCLUDE LIBRARY "libdir" [ RESOLVE label1, label2 … ]
	// #INCLUDE STANDARD LIBRARY [ RESOLVE label1, label2 … ]
	// all source files for not-yet-defined labels which were declared with .globl and found in libdir are included
	// if keyword RESOLVE is also present,
	//   then only labels from this list are included.
	//   labels already defined or not declared with .globl or not yet used are silently ignored
	//   labels not found in libdir abort assembler
	// c source files are compiled into "temp_directory/lib/"
	// does not include recursively required definitions!

	if (pass>1) { q.skip_to_eol(); return; }

	assert(lastchar(temp_directory)=='/');

	bool is_stdlib = q.testWord("standard") || q.testWord("default") || q.testWord("system");
	bool is_library = q.testWord("library");
	if (is_stdlib && !is_library) throw syntax_error("keyword 'library' expected");

	if (is_library)
	{
		cstr fqn;
		if (is_stdlib)
		{
			if (!stdlib_dir)		// try to guess missing libdir:
			{
				if (c_includes && endswith(c_includes,"/include/"))
				{
					cstr dir = catstr(leftstr(c_includes,strlen(c_includes)-9),"/lib/");
					if (is_dir(dir)) stdlib_dir = dir;
				}
			}
			if (!stdlib_dir)		// try to use hint:
			{
				if (is_sdcc && sdcc_library_path) stdlib_dir = sdcc_library_path;
				if (is_vcc && vcc_library_path)   stdlib_dir = vcc_library_path;
			}
			if (!stdlib_dir) throw syntax_error("standard library path is not set (use command line option -L)");

			assert(eq(stdlib_dir,fullpath(stdlib_dir)) && lastchar(stdlib_dir)=='/' && !errno);
			fqn = stdlib_dir;
		}
		else
		{
			fqn = get_directory(q);
		}

		Array<cstr> names;
		if (q.testWord("resolve") && !q.testChar('*')) for(;;)
		{
			cstr w = q.nextWord();
			if (w[0]!='_' && !is_letter(w[0])) throw syntax_error("label name expected");

			Label* l = global_labels().find(w);
			if (l && !l->is_defined && l->is_used) { names.append(w); }
			else if(verbose>2)
			{
				if (!l) log( "resolve: %s never used defined or declared\n",w);
				else if (l->is_defined) log( "resolve: %s already defined\n",w);
				else if (!l->is_used) log("resolve: %s not used: must be used before resolving it!\n",w);
			}

			if (q.testComma()) continue;	// optional
			if (q.testEol()) break;
		}

		MyFileInfoArray files;
		read_dir(fqn, files, yes);
		files.sort();					// make loading of library files predictable

		for (uint i=0;i<files.count();i++)
		{
			cstr fname = files[i].fname();
			cstr name  = basename_from_path(fname);

			if (names.count() && !names.contains(name)) continue;	// not in explicit list

			Label* l = global_labels().find(name);
			if (!l) continue;			// never used, defined or declared
			if (l->is_defined) continue;	// already defined
			if (!l->is_used) continue;	// not used: must have been used before position of #include library!

			if (endswith(fname,".c") || endswith(fname,".cc") ||
				endswith(fname,".s") || endswith(fname,".ass") || endswith(fname,".asm") )
			{
				//	#include library "path"			; <-- current_sourceline
				//	#include "path/fname"			; <-- generated
				//	; contents of file will go here	; <-- inserted when #include "path/fname" is assembled
				//	#assert defined(fname::)		; <-- generated: prevent infinite recursion in case of error
				//	#include library "path"			; <-- copy of current_sourceline: include more files from library

				cstr s1 = usingstr("#include \"%s%s\"",fqn,fname);
				cstr s2 = usingstr("#assert defined(%s::)",name);
				cstr s3 = q.text;
				source.insertat(current_sourceline_index+1, new SourceLine(q.sourcefile,q.sourcelinenumber,s1));
				source.insertat(current_sourceline_index+2, new SourceLine(q.sourcefile,q.sourcelinenumber,s2));
				source.insertat(current_sourceline_index+3, new SourceLine(q.sourcefile,q.sourcelinenumber,s3));
				return;
			}
			else continue;			// skip any unknown files: e.g. list files etc.
		}

		// if we come here, not a single label was resolved
		if (names.count()) throw fatal_error("source file for label %s not found",names[0]);
		// else we are done.
	}
	else
	{
		cstr fqn = get_filename(q);

		if (endswith(fqn,".c") || endswith(fqn,".cc"))	// c or vcc source
		{
			if (!c_compiler) init_c_compiler();

			if (is_sdcc)
			{
				//	#include "path/fname"			; <-- current_sourceline
				//	#local							; <-- generated
				//	; contents of file will go here	; <-- inserted by includeFile()
				//	#endlocal						; <-- generated

				fqn = compileFile(fqn);
				source.insertat(current_sourceline_index+1, new SourceLine(q.sourcefile,q.sourcelinenumber,"#local"));
				source.insertat(current_sourceline_index+2, new SourceLine(q.sourcefile,q.sourcelinenumber,"#endlocal"));
				source.includeFile(fqn, current_sourceline_index+2);
			}
			else if (is_vcc)
			{
				//	#include "path/fname"			; <-- current_sourceline
				//	; contents of file will go here	; <-- inserted by includeFile()

				fqn = compileFile(fqn);
				source.includeFile(fqn, current_sourceline_index+1);
			}
			else
			{
				throw fatal_error("c compiler not set (use cmd line option -c or directive '#cpath')");
			}
		}
		else
		{
			source.includeFile(fqn, current_sourceline_index+1);
		}
	}
}

cstr Z80Assembler::compileFile (cstr fqn) throws
{
	assert(c_compiler);

	cstr fqn_q = fqn;
	//cstr fqn_z = catstr(c_tempdir, basename_from_path(fqn), ".s");
	cstr fqn_z = catstr(c_tempdir, replacedstr(fqn+1,'/',':'), ".s");

	if (is_sdcc)
	{
		// if the .s file exists and is newer than the .c file, then don't compile again:
		// note: this does not handle modified header files or modified CFLAGS or upgraded SDCC itself!
		if (exists_node(fqn_z) && file_mtime(fqn_z) > file_mtime(fqn_q))
			return fqn_z;
	}
	if (is_vcc){}	// Vcc does proper caching:
					// Vcc _does_ handle modified header files or modified CFLAGS or upgraded Vcc itself!

	// create pipe:
	const int R=0,W=1;
	int pipout[2];
	if (pipe(pipout)) throw fatal_error(errno);

	// compile source file:

	pid_t child_id = fork();	// fork a child process
	assert(child_id!=-1);		// fork failed: can't happen

	if (child_id==0)			// child process:
	{
		close(pipout[R]);		// close unused fd
		close(1);				// close stdout
		close(2);				// close stderr
		int r1 = dup(pipout[W]);// becomes lowest unused fileid: stdout
		int r2 = dup(pipout[W]);// becomes lowest unused fileid: stderr
		(void)r1; (void)r2;
		assert(r1==1);
		assert(r2==2);
		close(pipout[W]);		// close unused fd

		int result = chdir(source_directory);	// => partial paths passed to sdcc will start in source dir
		if (result) exit(errno);

		if (c_zi >= 0)	  { c_flags[c_zi] = fqn_z; }
		else if (is_sdcc) { c_flags.append("-o"); c_flags.append(fqn_z); }
		else if (is_vcc)  { c_flags.append(catstr("-o=",fqn_z)); }

		if (c_qi >= 0)	 { c_flags[c_qi] = fqn_q; }
		else			 { c_flags.append(fqn_q); }

		c_flags.insertat(0,c_compiler);			// argv[0] = command
		c_flags.append(nullptr);				// list end marker

		// add standard options:
		if (is_sdcc)
		{
			c_flags.insertat(1,"-mz80");		// cpu = Z80
			c_flags.insertat(2,"-S");			// compile only, don't link
		}

		execve(c_compiler, (char**)c_flags.getData(), environ);	// exec cmd
		exit(errno);			// exec failed: return errno: will be printed in error msg,
								//				but is ambiguous with cc exit code
	}
	else						// parent process:
	{
		close(pipout[W]);		// close unused fd
		FD fd(pipout[R],"PIPE");

		int status;
		const uint SIZE = 0x7fff;	// if we get more output there is probably something going wrong
		char bu[SIZE+1];			// collector
		uint32 size = fd.read_bytes(bu,SIZE,0);
		while (size==SIZE)
		{
			bu[size] = 0;
			if (verbose) log("%s",bu);
			size = fd.read_bytes(bu,SIZE,0);
		}
		bu[size] = 0;

		/*	Output in case of NO ERROR:
			0 bytes

			Sample output in case of ERROR:
			/pub/Develop/Projects/zasm-4.0/Test/main.c:63: warning 112: function 'strcmp' implicit declaration
			/pub/Develop/Projects/zasm-4.0/Test/main.c:64: warning 112: function 'memcpy' implicit declaration
			/pub/Develop/Projects/zasm-4.0/Test/main.c:65: warning 112: function 'strcpy' implicit declaration
			/pub/Develop/Projects/zasm-4.0/Test/main.c:63: error 101: too many parameters
			/pub/Develop/Projects/zasm-4.0/Test/main.c:64: error 101: too many parameters
			/pub/Develop/Projects/zasm-4.0/Test/main.c:65: error 101: too many parameters
		*/

		for (int err; (err = waitpid(child_id,&status,0)) != child_id; )
		{
			assert(err==-1);
			if (errno!=EINTR) throw fatal_error("waitpid: %s",strerror(errno));
		}

		if (WIFEXITED(status))				// child process exited normally
		{
			if (WEXITSTATUS(status)!=0)		// child process returned error code
			{
				log("%s",bu);
				throw fatal_error("\"%s %s\" returned exit code %i\n- - - - - -\n%s- - - - - -\n",
					filename_from_path(c_compiler), filename_from_path(fqn_q), int(WEXITSTATUS(status)), bu);
			}
			else if (verbose)
				log("%s",bu);
		}
		else if (WIFSIGNALED(status))		// child process terminated by signal
		{
			log("%s",bu);
			throw fatal_error("\"%s %s\" terminated by signal %i",
					filename_from_path(c_compiler), filename_from_path(fqn_q), int(WTERMSIG(status)));
		}
		else IERR();
	}

	return fqn_z;
}

void Z80Assembler::asmInsert (SourceLine& q) throws
{
	// #insert <"path/filename">
	// insert file's contents into code

	if (!current_segment_ptr) throw syntax_error("org not yet set (use instruction 'org' or directive '#code')");

	q.is_data = yes;	// even if it isn't, but we don't know. else listfile() will bummer

	cstr fqn = get_filename(q);

	FD fd(fqn,'r');
	off_t sz = fd.file_size();			// file size
	if (sz>0x10000) throw fatal_error("file is larger than $10000 bytes");	// max. possible size in any case

	char bu[sz];
	fd.read_bytes(bu, uint32(sz));
	storeBlock(bu,uint32(sz));
}

void Z80Assembler::asmTzx (SourceLine& q) throws
{
	if (target!=TZX) throw fatal_error("#target TZX required");
	if (q.peekChar() == 0) throw fatal_error("block type expected");

	/*
	0x10: #TZX STANDARD,	name, address, length, ...
	0x11: #TZX TURBO,		name, address, length, ...
	0x14: #TZX PURE-DATA,	name, address, length, ...
	0x19: #TZX GENERALIZED,	name, address, length, ...

	0x12: #tzx PURE-TONE, [COUNT=]num_pulses, [PULSE=]cc_per_pulse
	0x13: #tzx PULSES
	0x18: #tzx CSW-RECORDING, [SAMPLE=cc_per_sample] [FREQ=samples_per_second] ...
	0x20: #tzx PAUSE, [DURATION=]pause
	0x21: #tzx GROUP-START, [NAME=]name
	0x22: #tzx GROUP-END
	0x24: #tzx LOOP-START, [COUNT=]repetitions
	0x25: #tzx LOOP-END
	0x2A: #tzx STOP-48K
	0x2B: #tzx POLARITY, [POLARITY=]polarity
	0x30: #tzx INFO, [TEXT=]text
	0x31: #tzx MESSAGE, [DURATION=]duration, [TEXT=]text
	0x32: #tzx ARCHIVE-INFO
	0x33: #tzx HARDWARE-INFO
	*/

	SegmentType segment_type = DATA;	// void

	cptr q0 = q.p;
	cstr blocktype = q.nextWord();
		if (q.testChar('-')) blocktype = catstr(blocktype,"-",q.nextWord());
		//blocktype = upperstr(blocktype);

	static const SegmentType tzx_id[] =
	{
		TZX_STANDARD, TZX_TURBO, TZX_PURE_DATA, TZX_GENERALIZED,
		TZX_PULSES, TZX_CSW_RECORDING, TZX_CSW_RECORDING, TZX_ARCHIVE_INFO, TZX_HARDWARE_INFO,
		TZX_PURE_TONE, TZX_PAUSE, TZX_GROUP_START, TZX_GROUP_END, TZX_LOOP_START, TZX_LOOP_END,
		TZX_STOP_48K, TZX_POLARITY, TZX_INFO, TZX_MESSAGE
	};
	static const cstr tzx_idf[] =
	{
		"standard", "turbo", "pure-data", "generalized",
		"pulses", "csw", "csw-recording", "archive-info", "hardware-info",
		"pure-tone", "pause", "group-start", "group-end", "loop-start", "loop-end",
		"stop-48k", "polarity", "info", "message",
	};
	static_assert(NELEM(tzx_id) == NELEM(tzx_idf), "TZX static arrays mismatch");

	for (uint i=0; i<NELEM(tzx_idf); i++)
	{
		if (lceq(blocktype,tzx_idf[i])) { segment_type = tzx_id[i]; break; }
	}

	if (segment_type == DATA)
	{
		q.p = q0;
		Value v = value(q);
		if (!v.is_valid()) throw syntax_error("block type must be valid in pass 1");
		segment_type = SegmentType(int(v));	// will be checked in switch()
	}

	switch (segment_type)
	{
	case TZX_STANDARD:		// #TZX STANDARD,	 name, address, length, ...
	case TZX_TURBO:			// #TZX TURBO,		 name, address, length, ...
	case TZX_PURE_DATA:		// #TZX PURE-DATA,	 name, address, length, ...
	case TZX_GENERALIZED:	// #TZX GENERALIZED, name, address, length, ...
	{
		q.expectComma();
		asmSegment(q,segment_type);
		return;
	}
	case TZX_PULSES:		// #tzx PULSES
	{						//      dw ...	; max. 255 pulses
		if (pass==1)
		{
			q.segment = new TzxPulses();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmTzxPulses;
		cmd_dpos = Value();
		return;
	}
	case TZX_CSW_RECORDING:	// #tzx CSW, [FILE=]"audio.wav", [COMPRESSED], [PAUSE=pause]
	{				//			[SAMPLE_RATE=value], [CHANNELS=1|2], [MONO], [STEREO],
					//			[SAMPLE_FORMAT=s1|u1|s2|u2|s2x|u2x]
					//			[HEADER=bytes], [START=frame], [END=frame], [COUNT=frames]

		q.testComma();
		if (q.testWord("file")) q.expect('=');
		cstr filename = get_filename(q);

		if (pass==1)
		{
			if (!exists_node(filename)) throw syntax_error("file not found");
			if (!is_file((filename))) throw syntax_error("not a regular file");

			q.segment = new TzxCswRecording(filename);
			segments.append(q.segment);
		}

		TzxCswRecording* segment = dynamic_cast<TzxCswRecording*>(q.segment);

		uint seen = 0;
		static const uint PAUSE=1,SAMPLE_RATE=4,CHANNELS=8,SAMPLE_FMT=16,START=32,END=64,HEADER=128,
						  ALL_THREE = SAMPLE_RATE|SAMPLE_FMT|CHANNELS;

		while (q.testComma())
		{
			if (q.testWord("pause"))
			{
				if(seen & PAUSE) throw syntax_error("multiple definitions for pause");
				q.expect(('='));
				segment->setPause(value(q));
				seen |= PAUSE;
			}
			else if (q.testWord("compressed"))
			{
				segment->setCompression(true);
			}
			else if (q.testWord("channels"))
			{
				q.expect(('='));
				Value v = value(q);
				if(!v.is_valid()) throw syntax_error("number of channels must be valid in pass 1");
				segment->setNumChannels(uint(v));
				seen |= CHANNELS;
			}
			else if (q.testWord("mono"))
			{
				segment->setNumChannels(1);
				seen |= CHANNELS;
			}
			else if (q.testWord("stereo"))
			{
				segment->setNumChannels(2);
				seen |= CHANNELS;
			}
			else if (q.testWord("sample-rate"))
			{
				q.expect(('='));
				Value v = value(q);
				if(!v.is_valid()) throw syntax_error("sample-rate must be valid in pass 1");
				segment->setSampleRate(v);
				seen |= SAMPLE_RATE;
			}
			else if (q.testWord("sample-format"))		// s1|u1|s2|u2|s2x|u2x
			{
				q.expect(('='));
				q.skip_spaces();
				char c1 = *q.p++;
				char c2 = c1 ? *q.p++ : 0;
				char c3 = c2=='2' && *q.p=='x' ? *q.p++ : 0;

				if ((c1=='s' || c1=='u') && (c2=='1' || c2=='2') && (q.peekChar()==',' || q.testEol()))
				{
					segment->setSampleFormat(uint(c2-'0'), c1=='s', c3=='x');
					seen |= SAMPLE_FMT;
				}
				else throw syntax_error("illegal format. known formats = [s1|u1|s2|u2|s2x|u2x]");
			}
			else if (q.testWord("header"))
			{
				if(seen & HEADER) throw syntax_error("multiple definitions for HEADER");
				q.expect(('='));
				segment->setHeaderSize(value(q));
				seen |= HEADER;
			}
			else if (q.testWord("start"))
			{
				if(seen & START) throw syntax_error("multiple definitions for START");
				q.expect(('='));
				segment->setFirstFrame(value(q));
				seen |= START;
			}
			else if (q.testWord("end"))
			{
				if(seen & END) throw syntax_error("multiple definitions for END or COUNT");
				q.expect(('='));
				segment->setLastFrame(value(q));
				seen |= END;
			}
			else if (q.testWord("count"))
			{
				if(seen & END) throw syntax_error("multiple definitions for END or COUNT");
				q.expect(('='));
				segment->setLastFrame(segment->first_frame + value(q));
				seen |= END;
			}
			else throw syntax_error("unknown setting name");
		}

		if (segment->raw && (~seen & ALL_THREE))
			throw syntax_error("raw audio: setting sample-rate, sample-format and channels required");

		if (~seen & PAUSE) segment->pause = 0;					// default = no gap of silence
		if (~seen & START) segment->first_frame = 0;			// default = first sample
		if (~seen & END) segment->last_frame = 1<<30;			// default = last sample
		if (~seen & HEADER) segment->header_size = 0;			// default = 0 bytes (or wav)

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_ARCHIVE_INFO:	// #tzx ARCHIVE-INFO
	{						//		db  type, length, text, ...
		if (pass==1)
		{
			q.segment = new TzxArchiveInfo();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmTzxArchiveInfo;
		cmd_dpos = Value();
		return;
	}
	case TZX_HARDWARE_INFO:	// #tzx HARDWARE-INFO
	{						//		db  type, id, state, ...
		if (pass==1)
		{
			q.segment = new TzxHardwareInfo();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmTzxHardwareInfo;
		cmd_dpos = Value();
		return;
	}
	case TZX_PURE_TONE:		// #tzx PURE-TONE, [COUNT=]num_pulses, [PULSE=]cc_per_pulse
	{
		if (pass==1)
		{
			q.segment = new TzxPureToneSegment();
			segments.append(q.segment);
		}

		TzxPureToneSegment* segment = dynamic_cast<TzxPureToneSegment*>(q.segment);

		q.testComma();
		if (q.testWord("count")) q.expect('=');
		segment->setNumPulses(value(q));

		q.expectComma();
		if (q.testWord("pulse")) q.expect('=');
		segment->setPulseLength(value(q));

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_PAUSE:			// #tzx PAUSE, [DURATION=]pause
	{
		if (pass==1)
		{
			q.segment = new TzxPauseSegment();
			segments.append(q.segment);
		}

		q.testComma(); if (q.testWord("duration")) q.expect('=');
		dynamic_cast<TzxPauseSegment*>(q.segment)->setDuration(value(q));

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_GROUP_START:	// #tzx GROUP-START, [NAME=]name
	{
		if (pass>1)
		{
			q.skip_to_eol();
		}
		else
		{
			q.testComma(); if (q.testWord("name")) q.expect('=');
			cstr name = q.nextWord();
			if (name[0]=='"' || name[0]=='\'') name = unquotedstr(name);	// quotes optional
			name = croppedstr(name);
			if (*name==0) throw syntax_error("name must not be empty");
			if (strlen(name)>32) throw syntax_error("name too long. (max. ~30 char)");
			for (cptr p=name; *p; p++)
			{
				if (!isascii(*p)) throw syntax_error("name must only contain ASCII characters");
			}
			q.segment = new TzxGroupStartSegment(name);
			segments.append(q.segment);
		}
		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_GROUP_END:		// #tzx GROUP-END
	{
		if (pass==1)
		{
			q.segment = new TzxGroupEndSegment();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_LOOP_START:	// #tzx LOOP-START, [REPETITIONS=]repetitions
	{
		if (pass==1)
		{
			q.segment = new TzxLoopStartSegment();
			segments.append(q.segment);
		}

		q.testComma(); if (q.testWord("repetitions")) q.expect('=');
		dynamic_cast<TzxLoopStartSegment*>(q.segment)->setRepetitions(value(q));

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_LOOP_END:		// #tzx LOOP-END
	{
		if (pass==1)
		{
			q.segment = new TzxLoopEndSegment();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_STOP_48K:		// #tzx STOP-48K
	{
		if (pass==1)
		{
			q.segment = new TzxStop48kSegment();
			segments.append(q.segment);
		}

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_POLARITY:		// #tzx POLARITY, [POLARITY=]polarity
	{
		if (pass==1)
		{
			q.segment = new TzxPolaritySegment();
			segments.append(q.segment);
		}

		q.testComma(); if (q.testWord("polarity")) q.expect('=');
		dynamic_cast<TzxPolaritySegment*>(q.segment)->setPolarity(value(q));

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_INFO:			// #tzx INFO, [TEXT=]text
	{
		if (pass>1)
		{
			q.skip_to_eol();
		}
		else
		{
			q.testComma(); if (q.testWord("text")) q.expect('=');
			cstr text = q.nextWord();
			if (text[0]!='"' && text[0]!='\'') throw syntax_error("quoted text expected");
			text = croppedstr(unquotedstr(text));
			if (*text==0) throw syntax_error("text must not be empty");
			if (strlen(text)>255) throw syntax_error("text too long. (max. 255, pls. ~30 char)");
			for (cptr p=text; *p; p++)
			{
				if (!isascii(*p)) throw syntax_error("text must only contain ASCII characters");
			}
			q.segment = new TzxInfoSegment(text);
			segments.append(q.segment);
		}
		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	case TZX_MESSAGE:		// #tzx MESSAGE, [DURATION=]duration, [TEXT=]text
	{			// up to 8 lines à ~30 char, separated by \x0d

		q.expectComma(); if (q.testWord("duration")) q.expect('=');
		Value v = value(q);

		if (pass>1)
		{
			q.skip_to_eol();
		}
		else
		{
			q.testComma(); if (q.testWord("text")) q.expect('=');
			Array<cstr> text;
			do
			{
				if (text.count()==8) throw syntax_error("too many lines. (max. 8 lines)");
				cstr  s = q.nextWord();
				if (s[0]!='"' && s[0]!='\'') throw syntax_error("quoted text expected");
				s = unquotedstr(s);
				if (strlen(s)>31) throw syntax_error("text too long. (max. ~30 char)");
				for (cptr p=s; *p; p++)
				{
					if (!isascii(*p)) throw syntax_error("text must only contain ASCII characters");
				}
				text.append(s);
			}
			while(q.testComma());

			q.segment = new TzxMessageSegment(std::move(text));
			segments.append(q.segment);
		}

		dynamic_cast<TzxMessageSegment*>(q.segment)->setDuration(v);

		current_segment_ptr = q.segment;
		asmInstr = &Z80Assembler::asmNoSegmentInstr;
		cmd_dpos = Value();
		return;
	}
	default: break;
	}//switch

	throw syntax_error("invalid or unsupported block type");
}

void Z80Assembler::asmSegment (SourceLine& q, SegmentType segment_type) throws
{
	assert(isData(segment_type)||isCode(segment_type));

	// #DATA name, [start], [size]
	// #CODE name, [start], [size]						most targets
	// #CODE name, [start], [size], [[FLAG=]value]		z80
	// #CODE name, [start], [size], [[FLAG=]value|ACE]	tap
	// #CODE name, [start], [size], <flags>				tzx
	// #TZX TURBO, name, start, size, <flags>
	// #TZX STANDARD, name, start, size, <flags>
	// #TZX PURE-DATA, name, start, size, <flags>
	// #TZX GENERALIZED, name, start, size, <flags>

	// <flags>:		( <nothing> | <value> | <dict> )
	// <dict>:
	// standard:    FLAG=(flag|NONE), [CHECKSUM=NONE], [PAUSE=pause]
	// code, turbo:	FLAG=(flag|NONE), [CHECKSUM=NONE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=count]
	// pure-data:	FLAG=(flag|NONE), [CHECKSUM=NONE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=NONE]
	// generalized:	FLAG=(flag|NONE), [CHECKSUM=NONE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=(NONE|count)]

	// on first occurance start, size and flags may be defined
	// <start> may be '*' for relocatable (append to prev. segment)
	// <size>  may be '*' for resizable   (shrink to fit)
	// on subsequent re-opening of segment no arguments are allowed

	// wenn #code oder #data benutzt werden, muss #target gesetzt worden sein:
	if (target==TARGET_UNSET) throw fatal_error("#target declaration missing");

	cstr name = q.nextWord();
	if (!is_name(name)) throw fatal_error("segment name expected");
	if (casefold) name = lowerstr(name);

	DataSegment* segment = segments.find(name);
	if (segment)		// segment definition in pass 2++ or re-enter segment in any pass
	{
		assert(eq(segment->name,name));

		if (pass==1)	// re-enter segment
		{
			if (q.testComma())
				throw fatal_error("segment %s redefined", name);

			if (segment->type != segment_type)
			{
				if (segment_type == CODE && isCode(segment->type)) {}	// OK: #tzx code block re-opened with #code
				else throw fatal_error("#code/#data mismatch");
			}
		}
	}

	else // if (!segment)	// create segment in pass 1
	{
		assert(pass==1);

		if (isData(segment_type))
			segment = new DataSegment(name,0x00/*fillbyte*/,1/*relocatable*/,1/*resizable*/);
		else
		{
			assert(isCode(segment_type));
			uint8 fillbyte = target==ROM ? 0xFF : 0x00;
			segment = new CodeSegment(name,segment_type,fillbyte,1/*relocatable*/,1/*resizable*/);
		}
		segments.append(segment);

		Label* l = global_labels().find(name);
		if (l && l->is_defined) setError("label %s redefined",name);
		q.label = new Label(name,segment,q.sourcelinenumber,0/*address*/,invalid,yes/*global*/,yes/*defined*/,l!=nullptr);
		global_labels().add(q.label);

		cstr lname = catstr(name,"_end");
		l = global_labels().find(lname);
		if (l && l->is_defined) setError("label %s redefined",lname);
		global_labels().add( new Label(lname, segment, q.sourcelinenumber,
							 0/*address+size*/, invalid, yes/*global*/, yes/*defined*/, l!=nullptr/*used*/) );

		lname = catstr(name,"_size");
		l = global_labels().find(lname);
		if (l && l->is_defined) setError("label %s redefined",lname);
		global_labels().add( new Label(lname, segment, q.sourcelinenumber,
							 0/*size*/, invalid, yes/*global*/, yes/*defined*/, l!=nullptr/*used*/) );
	}

	if (q.label) reusable_label_basename = name;
	asmInstr = syntax_8080 ? &Z80Assembler::asm8080Instr : &Z80Assembler::asmZ80Instr;	// TODO
	current_segment_ptr = segment;
	q.segment = current_segment_ptr;	// Für Temp Label Resolver
	q.byteptr = currentPosition();		// Für Temp Label Resolver & Logfile
	assert(q.bytecount==0);

	if (q.testComma())	// address
	{
		segment->relocatable = q.testChar('*');
		if (!segment->relocatable) segment->setAddress(value(q));		// throws
	}

	Label* l = global_labels().find(name);
	setLabelValue(l,segment->address);

	if (q.testComma())	// size
	{
		segment->resizable = q.testChar('*');
		if (!segment->resizable) segment->setSize(value(q));			// throws
	}

	l = global_labels().find(catstr(name,"_size"));
	setLabelValue(l, segment->size);
	l = global_labels().find(catstr(name,"_end"));
	setLabelValue(l, segment->address+segment->size);

	if (segment->isData()) return;
	if (!q.testComma()) return;
	CodeSegment* cseg = dynamic_cast<CodeSegment*>(segment);
	assert(cseg);

	if (target == Z80)
	{
		// #code name, address, length, [FLAG=]value

		cptr p = q.p; if (!(q.testWord("flag") && q.testChar('='))) q.p = p;
		cseg->setFlag(value(q));
	}

	else if (target == TAP)
	{
		// #code name, address, length, [FLAG=]value|NONE

		// if FLAG=NONE then no flagbyte is stored in the tape block
		// and the checksum does not incorporate the flagbyte.
		// => this is suitable for Jupiter Ace tape files.

		cptr p = q.p; if (!(q.testWord("flag") && q.testChar('='))) q.p = p;
		if (q.testWord("none")) cseg->setNoFlag();
		else cseg->setFlag(value(q));
	}

	else if (target == TZX)
	{
		// CodeSegment: parse flag and dict:

		// <flag>:		( <nothing> | <value> | <dict> )
		// <dict>:
		// standard:    FLAG=(flag|NONE), [CHECKSUM=NONE|ACE], [PAUSE=pause]
		// code, turbo:	FLAG=(flag|NONE), [CHECKSUM=NONE|ACE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=count]
		// pure-data:	FLAG=(flag|NONE), [CHECKSUM=NONE|ACE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=NONE]
		// generalized:	FLAG=(flag|NONE), [CHECKSUM=NONE|ACE], [PAUSE=pause], [LASTBITS=lastbits], [PILOT=(NONE|count)]

		// flag must be first value:
		// if flag is not introduced with keyword 'FLAG' then only a flag can follow:
		cptr p = q.p;
		if (!(q.testWord("flag") && q.testChar('=')))
		{
			q.p = p;
			cseg->setFlag(value(q));
			return;
		}
		q.p = p;

		uint seen = 0;
		static const uint FLAG=1,CHECKSUM=2,PAUSE=4,PILOT=8,LASTBITS=16;

		do
		{
			if (q.testWord("flag"))
			{
				if (seen & FLAG) throw syntax_error("multiple definitions for flag");
				q.expect(('='));

				if (q.testWord("none")) cseg->setNoFlag();
				else cseg->setFlag(value(q));
				seen |= FLAG;
			}
			else if (q.testWord("checksum"))
			{
				if (seen & CHECKSUM) throw syntax_error("multiple definitions for checksum");
				q.expect(('='));

				if (q.testWord("none")) cseg->NoChecksum();
				else if (q.testWord("ace")) { cseg->checksum_ace = true; cseg->has_flag = true; }
				else throw syntax_error("keyword 'none' or 'ace' expected");
				seen |= CHECKSUM;
			}
			else if (q.testWord("pause"))
			{
				if (seen & PAUSE) throw syntax_error("multiple definitions for pause");
				q.expect(('='));

				cseg->setPause(q.testWord("none") ? Value(0) : value(q));
				seen |= PAUSE;
			}
			else if (q.testWord("pilot"))
			{
				if (seen & PILOT) throw syntax_error("multiple definitions for pilot count");
				q.expect(('='));

				if (q.testWord("none"))
				{
					if (segment_type!=CODE && segment_type!=TZX_PURE_DATA && segment_type!=TZX_GENERALIZED)
						throw syntax_error("TZX pure data or generalized block required");

					cseg->no_pilot = true;
					seen |= PILOT;
				}
				else
				{
					if (segment_type!=CODE && segment_type!=TZX_TURBO && segment_type!=TZX_GENERALIZED)
						throw syntax_error("TZX turbo or generalized block required");

					cseg->setNumPilotPulses(value(q));
					seen |= PILOT;
				}
			}
			else if (q.testWord("lastbits"))
			{
				if (seen & LASTBITS) throw syntax_error("multiple definitions for lastbits");
				if (segment_type == TZX_STANDARD)
					throw syntax_error("TZX pure data, turbo or generalized block required");
				q.expect(('='));

				cseg->setLastBits(value(q));
				seen |= LASTBITS;
			}
		}
		while (q.testComma());

		if (~seen & FLAG) throw syntax_error("definition for 'flag' missing");
	}

	else
	{
		throw syntax_error("too many arguments");
	}
}

void Z80Assembler::asmFirstOrg (SourceLine& q) throws
{
	// Handle FIRST occurance of pseudo instruction ORG
	// ORG is handled differently for first occurance or later occurances:
	// the first ORG sets the start address of the default code segment
	// while later ORGs insert space.
	// note: #CODE or #DATA implicitely set an ORG so any ORG thereafter inserts space.
	//
	// Source either uses #TARGET and #CODE to set a target and to define code segments
	// or source does not use #TARGET/#CODE and simply sets ORG for a single default code segment.
	//
	// This is handled here:
	//   ORG sets the target to ROM,
	//   creates a default segment
	//   and sets it's start address.
	//
	// Thereafter code can be inserted into this segment.
	// Before ORG or #CODE no code can be stored and trying to do so results in an error.

	assert(!current_segment_ptr);

	CodeSegment* s;
	cstr name = DEFAULT_CODE_SEGMENT;

	if (pass==1)
	{
		// ORG after #TARGET and no #CODE:
		if (target!=TARGET_UNSET) throw fatal_error("#code segment definition expected after #target");

		s = new CodeSegment(name,CODE,0xff,no,yes);
		segments.append(s);

		Label* l = global_labels().find(name);
		if (l && l->is_defined) setError("label %s redefined",name);
		l = new Label(name,s,current_sourceline_index,0,invalid,yes,yes,l!=nullptr);
		global_labels().add(l);
		q.label = l;

		cstr lname = catstr(name,"_end");
		l = global_labels().find(lname);
		if (l && l->is_defined) setError("label %s redefined",lname);
		global_labels().add( new Label(lname, s, q.sourcelinenumber,0,invalid,yes,yes,l!=nullptr) );

		lname = catstr(name,"_size");
		l = global_labels().find(lname);
		if (l && l->is_defined) setError("label %s redefined",lname);
		global_labels().add( new Label(lname, s, q.sourcelinenumber,0,invalid,yes,yes,l!=nullptr) );
	}
	else
	{
		assert(segments.count() && dynamic_cast<CodeSegment*>(segments[0].ptr()));
		s = static_cast<CodeSegment*>(segments[0].ptr());
		assert(q.label!=nullptr);
	}

	asmInstr = syntax_8080 ? &Z80Assembler::asm8080Instr : &Z80Assembler::asmZ80Instr;
	current_segment_ptr = s;			// => from now on code deposition is possible
	//target				= "ROM";		bleibt ungesetzt => #code will bummer
	//reusable_label_basename = DEFAULT_CODE_SEGMENT;

	Value n = value(q);
	setLabelValue(q.label,n);
	s->setAddress(n);
}

void Z80Assembler::asmLocal (SourceLine&) throws
{
	// #local
	// startet einen lokalen Codeblock
	// Neue Label, die nicht als global deklariert sind, werden in die aktuellen local_labels gelegt.

	// local_labels_index = Index des aktuellen local_labels Blocks in labels[]
	// local_blocks_count = Anzahl local_labels Blocks in labels[] bisher (in pass1: == labels.count)

	if (pass==1)
	{
		assert(local_blocks_count == labels.count());
		labels.append(Labels(local_labels_index));	// neuen Block mit Rückbezug auf aktuellen (umgebenden) Block
	}
	else
	{
		assert(labels[local_blocks_count].outer_index==local_labels_index);
	}

	local_labels_index = local_blocks_count++;
}

void Z80Assembler::asmEndLocal (SourceLine&) throws
{
	// #endlocal
	// beendet lokalen Codeblock

	if (local_labels_index==0) throw syntax_error("#endlocal without #local");

	if (pass==1)	// Pass 1: verschiebe undefinierte lokale Label in den umgebenden Kontext
	{
		Labels& local_labels = this->local_labels();
		Array<RCPtr<Label>>& local_labels_array = local_labels.getItems();
		Array<Label*> undef_labels_array;
		uint outer_index = local_labels.outer_index;
		Labels& outer_labels = labels[outer_index];
		bool is_global = outer_labels.is_global;

		// Suche lokal undefinierte Labels,
		// die nicht mit .globl als global deklariert wurden:
		for (uint lli = local_labels_array.count(); lli--; )
		{
			Label* label = local_labels_array[lli];
			if (!label->is_defined && !label->is_global)
				undef_labels_array.append(label);
		}

		// Verschiebe diese Labels in den umgebenden Kontext:
		for (uint uli = undef_labels_array.count(); uli--; )
		{
			Label* ql = undef_labels_array[uli];		assert(!ql->is_global);
			Label* zl = outer_labels.find(ql->name);

			if (zl==nullptr) { zl = new Label(*ql); outer_labels.add(zl); zl->is_global = is_global; }
			else zl->is_used = yes;
			local_labels.remove(ql->name);
		}
	}

	local_labels_index = local_labels().outer_index;
}



// --------------------------------------------------
//				Assemble Opcode
// --------------------------------------------------

void Z80Assembler::storeEDopcode (int n) throws
{
	if (target_z80) return store(PFX_ED,n);
	throw syntax_error(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}

void Z80Assembler::storeIXopcode (int n) throws
{
	if (target_z80) return store(PFX_IX,n);
	throw syntax_error(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}

void Z80Assembler::storeIYopcode (int n) throws
{
	if (target_z80) return store(PFX_IY,n);
	throw syntax_error(syntax_8080 ?
		  "no i8080 opcode (use option --asm8080 and --z80)"
		: "no i8080 opcode (option --8080)");
}

void Z80Assembler::asmTzxPulses (SourceLine& q, cstr w) throws
{
	// assemble source lines after #TZX PULSES
	//
	// up to 255 pulse widths (words)

	if (doteq(w,"dw") || lceq(w,"defw") || lceq(w,".word"))
	{
		do
		{
			dynamic_cast<TzxPulses*>(current_segment_ptr)->appendPulse(value(q));
		}
		while(q.testComma());
	}
	else
	{
		asmNoSegmentInstr(q,w);
	}
}

void Z80Assembler::asmTzxHardwareInfo (SourceLine& q, cstr w) throws
{
	// assemble source lines after #TZX HARDWARE-INFO
	//
	// up to 255 entries:
	//		db <type>, <id>, <support>

	if (doteq(w,"db") || lceq(w,"defb") || lceq(w,".byte"))
	{
		if (pass>1) { q.skip_to_eol(); return; }

		Value type = value(q);
		if (!type.is_valid()) throw syntax_error("hardware type must evaluate in pass 1");
		if (uint(type) > 0x20) throw syntax_error("hardware type out of range [0..16]");

		q.expectComma();
		Value id = value(q);
		if (!id.is_valid()) throw syntax_error("hardware ID must evaluate in pass 1");
		if (uint(id) > 0x40) throw syntax_error("hardware type out of range [0..45]");

		q.expectComma();
		Value support = value(q);
		if (!support.is_valid()) throw syntax_error("hardware support flag must evaluate in pass 1");
		if (uint(support) > 3) throw syntax_error("hardware support flag out of range [0..3]");

		dynamic_cast<TzxHardwareInfo*>(current_segment_ptr)->addInfo(uint8(type),uint8(id),uint8(support));
	}
	else
	{
		asmNoSegmentInstr(q,w);
	}
}

void Z80Assembler::asmTzxArchiveInfo (SourceLine& q, cstr w) throws
{
	// assemble source lines after #TZX ARCHIVE-INFO
	//
	// up to 255 entries:
	//		dm <id>, <p-string>

	if (doteq(w,"db") || lceq(w,"defb") || lceq(w,".byte") || doteq(w,"dm") || lceq(w,"defm"))
	{
		if (pass>1) { q.skip_to_eol(); return; }

		Value id = value(q);
		if (!id.is_valid()) throw syntax_error("archive info: ID must evaluate in pass 1");
		if (uint(id) > 0x10 && id!=0xff) throw syntax_error("archive info: ID out of range [0..0F]");

		q.expectComma();
		w = q.nextWord();
		if (w[0]!='"' && w[0]!='\'') throw syntax_error("archive info: text must be quoted");
		w = unquotedstr(w);

		dynamic_cast<TzxArchiveInfo*>(current_segment_ptr)->addArchiveInfo(uint8(id),w);
	}
	else
	{
		asmNoSegmentInstr(q,w);
	}
}

void Z80Assembler::asmNoSegmentInstr (SourceLine& q, cstr w) throws
{
	// Assemble instructions which need no segment
	// e.g. before first .org

	// Hinweis zum Macro-Aufruf:
	// Wenn ein Macro-Name eine Pseudo-Instruction verdeckt,
	// und diese in Pass 1 aber vor der Macro-Definition schon einmal ausgeführt wurde,
	// dann wird in Pass 2 dann statt dessen das Macro ausgeführt.
	// => Code-Abweichung zw. Pass 1 und Pass 2.
	// Deshalb: nur solche Macro-Aufrufe erkennen, die hinter der Macro-Definition liegen.

	if (*w==0) return;		// end of line
	w = lowerstr(w);

	if (macros.contains(w))
	{
		Macro& m = macros[w];
		if (current_sourceline_index > m.mdef) { asmMacroCall(q,m); return; }
	}

	if (!current_segment_ptr)
	{
		// #CODE or ORG not yet set:
		// allowed: ORG, misc. ignored proprietary words and list options
		// allowed: EQU label definitions (handled in asmLabel())
		// allowed: #directives, except #insert (handled there)

		if (doteq(w,"org")||lceq(w,".loc"))	{ asmFirstOrg(q); return; }
	}

	if (doteq(w,"macro"))		// define macro:	".macro NAME ARG"		"binutils style macros"
	{							//					"	instr \ARG"			seen in: OpenSE
		w = q.nextWord();
		if(!is_name(w)) throw syntax_error("name expected");
		asmMacro(q,w,'\\');
		return;
	}
	if (lceq(w,".area"))		// .area NAME  or  .area NAME (ABS)    => (ABS) is ignored
	{
		// select segment for following code

		w = q.nextWord();	// name
		if (!is_letter(*w) && *w!='_'  && !(allow_dotnames&&*w=='.')) throw fatal_error("segment name expected");
		if (casefold) w=lowerstr(w);
		Segment* segment = segments.find(w);
		if (!segment) throw fatal_error(current_segment_ptr?"segment not found":"no #code or #data segment defined");

		current_segment_ptr = segment;
		q.segment = current_segment_ptr;
		q.byteptr = currentPosition();
		assert(q.bytecount==0);

		if (q.testChar('('))
		{
			if (!q.testWord("ABS")) throw syntax_error("'ABS' expected");
			q.expect(')');
		}
		return;
	}
	if (lceq(w,".optsdcc"))		// .optsdcc -mz80
	{
		if (!q.testChar('-') )		 throw syntax_error("-mz80 expected");
		if (ne(q.nextWord(),"mz80")) throw syntax_error("-mz80 expected");
		return;
	}
	if (lceq(w,".phase"))		// M80: set logical code position
	{
		DataSegment* s = dynamic_cast<DataSegment*>(current_segment_ptr);
		if (s) { s->setOrigin(value(q)); return; }
		else throw syntax_error("#data or #code segment required");
	}
	if (lceq(w,".dephase"))		// M80: restore logical code position to real address
	{
		DataSegment* s = dynamic_cast<DataSegment*>(current_segment_ptr);
		if (s) { s->setOrigin(s->physicalAddress()); return; }
		else throw syntax_error("#data or #code segment required");
	}
	if (doteq(w,"include"))	return asmInclude(q);
	if (doteq(w,"incbin"))	return asmInsert(q);
	if (lceq(w,".module"))		// for listing
	{
		q.skip_to_eol();
		return;
	}
	if (lceq(w,".memorymap"))	// skip up to ".endme" and print warning
	{							// TODO: testen, ob das Verstellen der aktuellen Zeile Probleme bereitet
		uint n = current_sourceline_index;
		uint e = min(n+20u,source.count());
		while (++n<e)
		{
			SourceLine& z = source[n]; z.rewind();
			if (z.testWord(".endme")) { z.skip_to_eol(); current_sourceline_index=n; goto warn; }
		}
		throw syntax_error("'.endme' missing");
	}
	if (lceq(w,".rombankmap"))	// skip up to ".endro" and print warning
	{
		uint n = current_sourceline_index;
		uint e = min(n+20u,source.count());
		while (++n<e)
		{
			SourceLine& z = source[n]; z.rewind();
			if (z.testWord(".endro")) { z.skip_to_eol(); current_sourceline_index=n; goto warn; }
		}
		throw syntax_error("'.endro' missing");
	}
	if (lceq(w,".endme"))	throw syntax_error("'.endme' without '.memorymap'");
	if (lceq(w,".endro"))	throw syntax_error("'.endro' without '.rombankmap'");
	if (doteq(w,"title"))	goto ignore;
	if (lceq(w,".xlist"))	goto ignore;
	if (lceq(w,".nolist"))	goto ignore;
	if (lceq(w,"subttl"))	goto ignore;
	if (lceq(w,".sdsctag"))	goto ignore;
	if (doteq(w,"section"))	goto ignore;
	if (lceq(w,".bank"))	goto warn;
	if (lceq(w,".section"))	goto warn;
	if (lceq(w,"globals"))	goto warn;
	if (lceq(w,".pabs"))	goto warn;
	if (doteq(w,"rept"))	return asmRept(q,"endm");
	if (doteq(w,"dup"))		return asmRept(q,"edup");	// dzx7_lom "Life on Mars" by zxintrospec
	if (doteq(w,"if"))		return asmIf(q);
	if (doteq(w,"endif"))	return asmEndif(q);
	if (lceq (w,"aseg"))	goto warn;
	if (doteq(w,"list"))	goto ignore;
	if (doteq(w,"end"))		return asmEnd(q);
	if (doteq(w,"endm"))	throw syntax_error("no REPT or macro definition pending");
	if (doteq(w,"edup"))	throw syntax_error("no DUP pending");
	if (lceq(w,".z80"))
	{
		// MACRO80: selects Z80 syntax and target Z80 cpu
		// only check cpu setting: changing cpu requires undef of label _8080_
		// if asm8080 is selected, then the user has actively choosen --asm8080
		// does not unset the Z180 option

		if (target_z80) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		else if(syntax_8080)	 throw fatal_error("wrong target cpu (use --z80 or remove --asm8080)");
		else					 throw fatal_error("wrong target cpu (option --8080)");
	}
	if (lceq(w,".z180"))
	{
		// only upgrade from z80 to z180

		if (target_z180) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		if( !target_z80)		 throw fatal_error("wrong target cpu (%s)",
											syntax_8080 ? "use --z80 or remove --asm8080" : "option --8080");
		target_z180 = yes;
		if (ixcbr2_enabled) throw fatal_error("incompatible option --ixcbr2 is set: the Z180 traps illegal opcodes");
		if (ixcbxh_enabled) throw fatal_error("incompatible option --ixcbxh is set: the Z180 traps illegal opcodes");
		global_labels().add(new Label("_z180_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".8080"))
	{
		// MACRO80: selects 8080 syntax and target 8080 cpu
		// auf 8080 cpu umschalten
		// auf 8080 assembler syntax umschalten

		if (target_8080 && syntax_8080) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");

		// prüfe, ob --z80 beim Aufruf angegeben wurde:
		if (target_z80 && syntax_8080) throw fatal_error("wrong target cpu (option --z80)");
		assert(!global_labels().contains("_z80_"));

		// prüfe, ob --z180 beim Aufruf angegeben wurde:
		if (target_z180) throw fatal_error("wrong target cpu (option --z180)");
		assert(!global_labels().contains("_z180_"));

		// ixcb-optionen:
		if (ixcbr2_enabled) throw fatal_error("incompatible option --ixcbr2 is set: the 8080 has no index registers");
		if (ixcbxh_enabled) throw fatal_error("incompatible option --ixcbxh is set: the 8080 has no index registers");

		target_z180 = target_z80 = no;
		target_8080 = syntax_8080 = casefold = yes;
		global_labels().add(new Label("_8080_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		global_labels().add(new Label("_asm8080_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".asm8080"))
	{
		// just select the 8080 assembler
		// does not enforce 8080 cpu, keeps z80 cpu if set
		// silently removes _ixcbr2_ and _ixcbxh_
		// silently unsets _z180_

		if (syntax_8080) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");

		if (ixcbr2_enabled) { ixcbr2_enabled = no; global_labels().remove("_ixcbr2_"); }
		if (ixcbxh_enabled) { ixcbxh_enabled = no; global_labels().remove("_ixcbxh_"); }
		if (target_z180)    { target_z180    = no; global_labels().remove("_z180_");   }

		syntax_8080 = casefold = yes;

		if (target_z80) global_labels().add(new Label("_z80_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		global_labels().add(new Label("_asm8080_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".ixcbr2"))
	{
		if (ixcbr2_enabled) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		if (ixcbxh_enabled)		 throw fatal_error("incompatible option --ixcbxh is set");

		ixcbr2_enabled = yes;
		global_labels().add(new Label("_ixcbr2_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".ixcbxh"))
	{
		if (ixcbxh_enabled) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		if (ixcbr2_enabled)		throw fatal_error("incompatible option --ixcbr2 is set");

		ixcbxh_enabled = yes;
		global_labels().add(new Label("_ixcbxh_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".dotnames"))	// wenn das zu spät steht, kann es schon Fehler gegeben haben
	{
		if (allow_dotnames) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		allow_dotnames = yes;
		global_labels().add(new Label("_dotnames_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".reqcolon"))	// wenn das zu spät steht, kann es schon Fehler gegeben haben
	{
		if (require_colon) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		require_colon = yes;
		global_labels().add(new Label("_reqcolon_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".casefold"))	// wenn das nach Label-Definitionen steht, kann es zu spät sein
	{
		if (casefold) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		casefold = yes;
		global_labels().add(new Label("_casefold_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,".flatops"))		// wenn das nach Expressions z.B. in Label-Definitionen steht, kann es zu spät sein
	{
		if (flat_operators) return;
		if (current_segment_ptr) throw fatal_error("this statement must occur before ORG, #CODE or #DATA");
		flat_operators = yes;
		global_labels().add(new Label("_flatops_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		return;
	}
	if (lceq(w,"*"))
	{
		if (q.testWord("list")) goto ignore;					// "*LIST ON"  or  "*LIST OFF"
		if (q.testWord("include")) { asmInclude(q); return; }	// CAMEL80: fname follows without '"'
	}

// throw error "instruction expected":

	if (!is_letter(*w) && *w!='_' && *w!='.') throw syntax_error("instruction expected");	// no identifier

	if (q.testDotWord("equ") || q.test_char(':') || q.test_char('=') || q.testWord("defl"))
	{
		if (q[0]<=' ' && !require_colon) throw syntax_error("indented label definition (use option --reqcolon)");
		if (*w=='.' && !allow_dotnames) throw syntax_error("label starts with a dot (use option --dotnames)");
		throw syntax_error("label not recognized (why?)");
	}

	if (!current_segment_ptr) throw syntax_error("org not yet set (use instruction 'org' or directive '#code')");
	throw syntax_error("unknown instruction");

// print warning & ignore:
ignore:	if (pass>1 || verbose<2) return q.skip_to_eol();
		if (0)
warn:	if (pass>1 || verbose<1) return q.skip_to_eol();

		while (!q.testEol()) q.nextWord();	// skip to end of line but not behind a comment!
		cstr linenumber = tostr(q.sourcelinenumber+1);
		log("%s: %s\n", linenumber, q.text);
		log("%s%s^ warning: instruction '%s' ignored\n", spacestr(strlen(linenumber)+2), q.whitestr(), w);
}

void Z80Assembler::asmRawDataInstr (SourceLine& q, cstr w) throws
{
	// assemble segment which must only contain raw bytes
	// e.g. some TZX blocks
	// segment must exist and must be a special raw data segment TODO
	// text is always stored in ASCII (no charset translation)

	w = lowerstr(w);
	if (macros.contains(w))
	{
		Macro& m = macros[w];
		if (current_sourceline_index > m.mdef) { asmMacroCall(q,m); return; }
	}

	assert(current_segment_ptr);

	if (doteq(w,"dw") || lceq(w,"defw") || lceq(w,".word"))
	{
		q.is_data = yes;
		do
		{
			storeWord(value(q)); 		// TODO: store raw data ((and below...))
		}
		while (q.testComma());
		return;
	}

	if (doteq(w,"db") || lceq(w,"defb") || doteq(w,"dm") || lceq(w,".byte") || lceq(w,".ascii") || lceq(w,".text"))
	{
		// store bytes: 'xy' and "xy" are both handled as strings!
		// erlaubt jede Mixtur von literal, label, "text", 'c' Char, $abcdef stuffed hex, usw.

		q.is_data = yes;
		do
		{
			w = q.nextWord();
			uint n = strlen(w);

			if (w[0]=='"' || w[0]=='\'')	// Text string:
			{
				if (n<3 || w[n-1]!=w[0]) throw syntax_error("closing quotes expected");
				w = unquotedstr(w);
				if (*w==0) throw syntax_error("closing quotes expected");	// broken '\' etc.

				cptr depp = w;
				charcode_from_utf8(depp);	// skip over 1 char; throws on ill. utf8

				if (*depp==0) goto sv;		// single char => numeric expression

				// multi-char string:
				while(*w) store(charcode_from_utf8(w));
			}

			else if (n>3 && w[0]=='$')		// Stuffed Hex?
			{								// stored in order of occurance: in $ABCD byte $AB is stored first!
				w += 1; n -= 1;
	sh:			if (n&1) throw syntax_error("even number of hex characters expected");
				storeHexbytes(w,n/2);
			}
			else if (n>4 && is_dec_digit(w[0]) && tolower(w[n-1])=='h')
			{
				w = leftstr(w,n-1); n -= 1;
				goto sh;
			}
			else							// anything else:
			{
	sv:			q -= n;						// put back word
				storeByte(value(q));
			}
		}
		while(q.testComma());
		return;
	}

	if (lceq(w,".asciz"))
	{
		// store 0-terminated string:

		q.is_data = yes;
		w = q.nextWord();
		if (w[0]!='"' && w[0]!='\'') throw syntax_error("quoted string expected");

		uint n = strlen(w);
		if (n<3 || w[n-1]!=w[0]) throw syntax_error("closing quotes expected");
		w = unquotedstr(w);
		if (*w==0) throw syntax_error("closing quotes expected");	// broken '\' etc.

		while(*w) store(charcode_from_utf8(w));
		store(0);
		return;
	}

	return asmNoSegmentInstr(q,w);
}

void Z80Assembler::asmPseudoInstr (SourceLine& q, cstr w) throws
{
	// Assemble pseudo instruction

	// Hinweis zum Macro-Aufruf:
	// Wenn ein Macro-Name eine Pseudo-Instruction verdeckt,
	// und diese in Pass 1 aber vor der Macro-Definition schon einmal ausgeführt wurde,
	// dann wird in Pass 2 dann statt dessen das Macro ausgeführt.
	// => Code-Abweichung zw. Pass 1 und Pass 2.
	// Deshalb: nur solche Macro-Aufrufe erkennen, die hinter der Macro-Definition liegen.

	w = lowerstr(w);
	if (macros.contains(w))
	{
		Macro& m = macros[w];
		if (current_sourceline_index>m.mdef) { asmMacroCall(q,m); return; }
	}

	if (!current_segment_ptr) return asmNoSegmentInstr(q,w);	// #CODE or ORG not yet set

	cptr  depp;
	uint32 instr;

	switch (strlen(w))
	{
	case 0:		return;				// end of line
	case 2:		instr = peek2X(w); break;
	case 3:		instr = peek3X(w); break;
	case 4:		instr = peek4X(w); break;
	default:	goto longer;
	}

	switch (instr|0x20202020)
	{
	case '.loc':
	case '.org':
	case ' org':
		// org <value>	; add space up to address
		q.is_data = yes;
		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		static_cast<DataSegment*>(current_segment_ptr)->storeSpaceUpToAddress(value(q));
		return;

	case 'data':
		if (current_segment_ptr->isData()) goto ds;
		else throw syntax_error("only allowed in data segments (use defs)");

	case '  ds':
	case ' .ds':
	case 'defs':
		// store space: (gap)
		// defs cnt
		// defs cnt, fillbyte

ds:		q.is_data = yes;
		{
			Value n = value(q);
			assert(dynamic_cast<DataSegment*>(current_segment_ptr));
			if (q.testComma()) static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n,value(q));
			else static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n);
		}
		return;

	case '  dw':
	case ' .dw':
	case 'defw':
		// store words:
		// defw nn [,nn ..]
dw:		q.is_data = yes;
		do { storeWord(value(q)); } while (q.testComma());
		return;

	case '  dl':
		// store long words:
		// .long nn [,nn ..]
dl:		q.is_data = yes;
		do { Value n = value(q); storeWord(n); storeWord(n>>16); } while (q.testComma());
		return;

	case '  db':
	case ' .db':	// SDASZ80: truncates value to byte (not implemented, done if used this way by SDCC)
	case 'defb':
	case '  dm':
	case ' .dm':
	case 'defm':
		// store bytes:
		// due to wide use of DB for strings DB and DM are handled the same
		// => 'xy' and "xy" are both understood as  "string"!
		// erlaubt jede Mixtur von literal, label, "text", 'c' Char, $abcdef stuffed hex, usw.
		// ACHTUNG: '…' wird als String behandelt! Das wird z.B. im Source  des ZXSP-Roms so verwendet.
		// defb expression, "…", "…"+n, '…', '…'+n, 0xABCDEF…, __date__, __time__, __file__, …
		{
			uint n;
db:dm:		q.is_data = yes;
			w = q.nextWord();
			if (w[0]==0) throw syntax_error("value expected");

			// Text string:
			if (w[0]=='"' || w[0]=='\'')
			{
				n = strlen(w);
				if (n<3 || w[n-1]!=w[0]) throw syntax_error("closing quotes expected");
				w = unquotedstr(w);
				if (*w==0) throw syntax_error("closing quotes expected");	// broken '\' etc.

				depp = w;
				charcode_from_utf8(depp);	// skip over 1 char; throws on ill. utf8

				if (*depp==0)				// single char => numeric expression
				{
					q -= n;
					storeByte(value(q));
				}
				else						// multi-char string
				{
cb:					if (charset) while(*w) store(charset->get(charcode_from_utf8(w)));
					else		 while(*w) store(charcode_from_utf8(w));

					// test for operation on the final char:
					assert(dynamic_cast<CodeSegment*>(current_segment_ptr));
					CodeSegment* s = static_cast<CodeSegment*>(current_segment_ptr);
					if (q.testChar ('+'))	{ storeByte(Value(s->popLastByte() + value(q))); } else
					if (q.test_char('-'))	{ storeByte(Value(s->popLastByte() - value(q))); } else
					if (q.test_char('|'))	{ storeByte(Value(s->popLastByte() | value(q))); } else
					if (q.test_char('&'))	{ storeByte(Value(s->popLastByte() & value(q))); } else
					if (q.test_char('^'))	{ storeByte(Value(s->popLastByte() ^ value(q))); }
				}
				if (q.testComma()) goto dm; else return;
			}

			// Stuffed Hex:
			// bytes are stored in order of occurance: in $ABCD byte $AB is stored first!
			n = strlen(w);
			if (n>3 && w[0]=='$')
			{
sx:				w = midstr(w,1); n-=1;
sh:				if (n&1) throw syntax_error("even number of hex characters expected");
				storeHexbytes(w,n/2);
				if (q.testComma()) goto dm; else return;
			}

			if (n>4 && is_dec_digit(w[0]) && tolower(w[n-1])=='h')
			{
				w = leftstr(w,n-1); n-=1;
				if (n&1 && w[0]=='0') goto sx; else goto sh;
			}
		}//scope for 'n'

		// pre-defined special words:
		if (w[0]=='_')
		{
			if (eq(w,"__date__")) { w = datestr(timestamp); w += *w==' ';  goto cb; }
			if (eq(w,"__time__")) { w = timestr(timestamp); w += *w==' ';  goto cb; }
			if (eq(w,"__file__")) { w = q.sourcefile; goto cb; }
			if (eq(w,"__line__")) { w = tostr(q.sourcelinenumber); goto cb; }
		}

		// anything else:
		q -= strlen(w);	// put back opcode
		storeByte(value(q));
		if (q.testComma()) goto dm; else return;

	case '.tzx':
		if (target!=TZX) throw syntax_error("#target TZX required");
		if (!current_segment_ptr->isCode()) throw syntax_error("code segment required");
		assert(dynamic_cast<CodeSegment*>(current_segment_ptr) != nullptr);
		if (currentPosition() != 0) throw syntax_error(".tzx pseudo instructions must appear before any code");

		q.expect('-');

		// note: error checking is done in CodeSegment::addPilotSymbol() etc.

		if (q.testWord("pilot"))
		{
			if (q.testChar('-'))
			{
				if (q.testWord("sym"))	// .tzx-pilot-sym
				{
					Values symbol;
					do { symbol << value(q); } while(q.testComma());
					static_cast<CodeSegment*>(current_segment_ptr)->addPilotSymbol(symbol);
					return;
				}
				// else throw
			}
			else	// .tzx-pilot
			{
				Values symbol;
				do { symbol << value(q); } while(q.testComma());
				static_cast<CodeSegment*>(current_segment_ptr)->setPilot(symbol);
				return;
			}
		}

		else if (q.testWord("data"))
		{
			q.expect('-');
			if (q.testWord("sym"))	// .tzx-data-sym
			{
				Values symbol;
				do { symbol << value(q); } while(q.testComma());
				static_cast<CodeSegment*>(current_segment_ptr)->addDataSymbol(symbol);
				return;
			}
			// else throw
		}

		throw syntax_error("unknown .tzx instruction");

	default:
		return asmNoSegmentInstr(q,w);
	}

longer:
	// instructions which require a valid segment:
	// names must be longer than 4 characters:

	if (doteq(w,"align"))			// align <value> [,<filler>]
	{								// note: current address is evaluated as uint
		q.is_data = yes;
		Value n = value(q);
		if (n.is_valid() && n<1)	  throw syntax_error("alignment value must be ≥ 1");
		if (n.is_valid() && n>0x4000) throw syntax_error("alignment value must be ≤ $4000");

		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		Value a = static_cast<DataSegment*>(current_segment_ptr)->lpos;
		a.value &= 0xffff;
		//if(a.is_valid() && a<0 && n.is_valid() && (1<<(msbit(n)))!=n)
		//	throw syntax_error("alignment value must be 2^N if $ < 0");

		n = n-N1 - (a+n-N1) % n;

		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		if (q.testComma()) static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n,value(q));
		else static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n);
		return;
	}

	if (lceq(w,".asciz"))			// store 0-terminated string:
	{
		if (charset && charset->get(' ',' ')==0) // ZX80/81: the only conversion i know where 0x00 is a printable char
			throw syntax_error("this won't work because in the target charset 0x00 is a printable char");

		q.is_data = yes;
		w = q.nextWord();
		if (w[0]!='"' && w[0]!='\'') throw syntax_error("quoted string expected");

		uint n = strlen(w);
		if (n<3 || w[n-1]!=w[0]) throw syntax_error("closing quotes expected");
		w = unquotedstr(w);
		if (*w==0) throw syntax_error("closing quotes expected");	// broken '\' etc.

		if (charset) while(*w) store(charset->get(charcode_from_utf8(w)));
		else		 while(*w) store(charcode_from_utf8(w));
		store(0);
		return;
	}

	if (lceq(w,".globl"))			// declare global label for linker: mark label for #include library "libdir"
	{								// das Label wird in mehrere Labels[] eingehängt!
		w = q.nextWord();
		if (!is_letter(*w) && *w!='_') throw syntax_error("label name expected");

		if (local_labels_index)		// local context?
		{
			Label* g = global_labels().find(w);
			Label* l = local_labels().find(w);
			if (l && !l->is_global) throw syntax_error("label already defined local");
			assert(!g||!l||g==l);

			Label* label = l ? l : g ? g : new Label(w,nullptr,current_sourceline_index,0,invalid,yes,no,no);
			if (!l) local_labels().add(label);
			if (!g) global_labels().add(label);
		}
		else						// global context
		{
			Label* g = global_labels().find(w);
			Label* label = g ? g : new Label(w,nullptr,current_sourceline_index,0,invalid,yes,no,no);
			if (!g) global_labels().add(label);
		}
		return;
	}

	if(lceq(w,".byte"))	 goto db;	// TASM
	if(lceq(w,".word"))	 goto dw;	// TASM
	if(lceq(w,".long"))	 goto dl;
	if(lceq(w,".ascii")) goto dm;
	if(lceq(w,".text"))	 goto dm;	// TASM
	if(lceq(w,".block")) goto ds;	// TASM
	if(lceq(w,".blkb"))	 goto ds;

	//	if(lceq(w,".zxfloat"))	// floating point number in ZX Spectrum format
	//	{
	//		//	0 .. 65535:		00, 00, LO, HI, 00
	//		//	-65535 .. -1:	00, FF, LO, HI, 00	with LOHI = 0 - N
	//		//	other:			EE, HI, .., .., LO
	//		//					EE=80 => 0.5 ≤ N < 1
	//		//					HI.bit7 = VZ
	//		//					range: ±1e38 .. 4e-39
	//		//
	//		// TODO: we need float value() here…
	//	}

	//	if(lceq(w,".float"))	// floating point number in sdcc format
	//	{
	//	}

	return asmNoSegmentInstr(q,w);
}

enum // enumeration of Z80 identifiers
{
	NIX,	// end of line

	// conditions:
	NZ,		Z,		NC,		CY,		PO,		PE,		P,		M,	// <-- DO NOT REORDER!

	// 8-bit registers:
	RB,		RC,		RD,		RE,		RH,		RL,		XHL,	RA,	// <-- DO NOT REORDER!
	XH,		XL,		YH,		YL,									// <-- DO NOT REORDER!
	RI,		RR,

	// 16-bit registers:
	BC,		DE,		HL,		SP,			// <-- DO NOT REORDER!
	IX,		IY,		AF,

	// others:
	XBC,	XDE,	XC,		XSP,	XIX,	XIY,
	XNN,	NN,
	XMMBC, XMMDE, XMMHL, XBCPP, XDEPP, XHLPP,	// (hl++) etc. for compound opcodes
};

int Z80Assembler::getCondition (SourceLine& q, bool expect_comma) throws
{
	// test and skip over condition
	// returns NIX or enum [Z, NZ .. P]
	// expect_comma
	//   must be set if cond must be followed by a comma --> jr, jp and call
	//   and must be cleared for --> ret

	cptr p = q.p;
	cstr w = q.nextWord();	if (w[0]==0) return NIX;
	if (expect_comma && !q.testComma()) { q.p = p; return NIX; }

	char c1 = *w++ | 0x20;
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen = 1
	{
		if (c1=='z') return Z;	if (c1=='c') return CY;
		if (c1=='p') return P;	if (c1=='m') return M;
		if (c1=='s') return M;	// source seen ...
	}
	else if (*w==0)	// strlen = 2
	{
		if (c1=='n') { if (c2=='z') return NZ; if (c2=='c') return NC; }
		if (c1=='p') { if (c2=='o') return PO; if (c2=='e') return PE; }
	}
	throw syntax_error("illegal condition");
}

int Z80Assembler::getRegister (SourceLine& q, Value& n) throws
{
	// test and skip over register or value
	// returns register enum:
	//   normal register:     n and v are void (not modified)
	//   NN, XNN, XIX or XIY: n and v are set
	//   does not return i, r, (c), ix, iy or related if target_8080
	// throws on error
	// throws at end of line

	cptr p = q.p;
	cstr w = q.nextWord();

	char c1 = *w++ | 0x20;	if (c1==0x20) throw syntax_error("unexpected end of line");
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen=1
	{
		switch (c1)
		{
		case 'a':	return RA;
		case 'b':	return RB;
		case 'c':	return RC;
		case 'd':	return RD;
		case 'e':	return RE;
		case 'h':	return RH;
		case 'l':	return RL;
		case 'i':	if(target_z80) return RI; else goto no_8080;
		case 'r':	if(target_z80) return RR;

	no_8080:		throw syntax_error("no 8080 register");

		case '(':
			{
				int r;
				if (q.testWord("hl")) { r=XHL; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XHLPP; } q.expect(')'); return r; }
				if (q.testWord("de")) { r=XDE; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XDEPP; } q.expect(')'); return r; }
				if (q.testWord("bc")) { r=XBC; if (*q=='+'&&*(q.p+1)=='+'){ q+=2; r=XBCPP; } q.expect(')'); return r; }
				if (q.testWord("sp")) { q.expect(')'); return XSP; }

				if (*q=='-'&&*(q.p+1)=='-')
				{
					p = q.p;
					q.p += 2;
					if (q.testWord("hl")) { q.expect(')'); return XMMHL; }
					if (q.testWord("de")) { q.expect(')'); return XMMDE; }
					if (q.testWord("bc")) { q.expect(')'); return XMMBC; }
					q.p = p;
				}

				r = XNN; n=0;

				if (q.testWord("ix")) { if (target_8080) goto no_8080; r = XIX; if (q.testChar(')')) return r; }
				if (q.testWord("iy")) { if (target_8080) goto no_8080; r = XIY; if (q.testChar(')')) return r; }
				if (q.testWord("c"))  { if (target_8080) goto no_8080; q.expect(')'); return XC; }

				n = value(q); if (r!=XNN && n!=int8(n) && n.is_valid()) throw syntax_error("offset out of range");
				q.expectClose();
				return r;
			}
		}
	}
	else if (*w==0)	// strlen=2
	{
		switch(c1)
		{
		case 'a': if (c2=='f') return AF; else break;
		case 'b': if (c2=='c') return BC; else break;
		case 'd': if (c2=='e') return DE; else break;
		case 'h': if (c2=='l') return HL; else break;
		case 's': if (c2=='p') return SP; else break;
		case 'i': if (c2=='x') { if (target_z80) return IX; else goto no_8080; }
				  if (c2=='y') { if (target_z80) return IY; else goto no_8080; } else break;
		case 'x': if (c2=='h') { if (target_z180) goto no_z180; if (target_z80) return XH; goto no_8080; }
				  if (c2=='l') { if (target_z180) goto no_z180; if (target_z80) return XL; goto no_8080; } else break;
		case 'y': if (c2=='h') { if (target_z180) goto no_z180; if (target_z80) return YH; goto no_8080; }
				  if (c2=='l') { if (target_z180) goto no_z180; if (target_z80) return YL; goto no_8080; } else break;
		}
	}
	else	// ≥3 letters
	{
		// target_z80:  test for ixh, ixl, iyh, iyl:					2016-10-01
		// target_8080: no test: ixh, ixl, iyh, iyl are valid label names (not rejected in asmLabel())
		// target_z180: no test: ixh, ixl, iyh, iyl are valid label names (not rejected in asmLabel())
		if (target_z80 && c1=='i' && !target_z180)
		{
			char c3 = *w++ | 0x20;
			if (*w==0)	// 3 letters
			{
				uint rval = c2=='x' ? c3=='h'?XH:c3=='l'?XL:0 :
							c2=='y' ? c3=='h'?YH:c3=='l'?YL:0 : 0;
				if (rval) { if (target_z180) goto no_z180; return rval; }
			}
		}
	}

	// not a register: evaluate expression:
	q.p = p;
	n = value(q);
	if (target_8080 || !q.testChar('(')) return NN;

	// SDASZ80 syntax: n(IX)
	if (n!=int8(n) && n.is_valid()) throw syntax_error("offset out of range");
	if (q.testWord("ix")) { q.expectClose(); return XIX; }
	if (q.testWord("iy")) { q.expectClose(); return XIY; }
	throw syntax_error("syntax error");
no_z180:
	throw syntax_error("illegal register: the Z180 traps illegal instructions");
}

void Z80Assembler::asmZ80Instr (SourceLine& q, cstr w) throws
{
	// Assemble Z80 opcode

	// remember: *ALWAYS* evaluate _all_ values _before_ storing the first opcode byte: wg. '$'

	int    r,r2;
	Value  n,n2;
	uint32 instr;
	cptr   depp = nullptr;				// dest error position ptr: for instructions where
										// source is parsed before dest can be checked
	assert(current_segment_ptr);

	// strlen-Verteiler:

	switch (strlen(w))
	{
	case 0:		return;					// end of line
	case 1:		goto misc;
	case 2:		instr = peek2X(w); break;
	case 3:		instr = peek3X(w); break;
	case 4:		instr = peek4X(w); break;
	case 5:		goto wlen5;
	default:	goto misc;
	}

	switch (instr|0x20202020)
	{
	case ' jmp':
	case ' mov':	throw syntax_error("no Z80 assembler opcode (use option --asm8080)");

	case ' nop':	return store(NOP);
	case '  ei':	return store(EI);
	case '  di':	return store(DI);
	case ' scf':	return store(SCF);
	case ' ccf':	return store(CCF);
	case ' cpl':	return store(CPL);
	case ' daa':	return store(DAA);
	case ' rra':	return store(RRA);
	case ' rla':	return store(RLA);
	case 'rlca':	return store(RLCA);
	case 'rrca':	return store(RRCA);
	case 'halt':	return store(HALT);
	case ' exx':	if (target_8080) goto ill_8080;
					return store(EXX);

	case 'djnz':
		// djnz nn
		if (target_8080) goto ill_8080;
		instr = DJNZ; goto jr;

	case '  jr':
		// jr nn
		// jr cc,nn
		if (target_8080) goto ill_8080;
		r2 = getCondition(q,yes); if (r2>CY) throw syntax_error("illegal condition");
		instr = r2==NIX ? JR : JR_NZ+(r2-NZ)*8; goto jr;

	jr:	r = getRegister(q,n); if (r!=NN) goto ill_dest;
		store(instr);
		return storeOffset(n - dollar() - N2);

	case '  jp':
		// jp NN
		// jp rr	hl ix iy
		// jp (rr)	hl ix iy
		r2 = getCondition(q,yes);
		r  = getRegister(q,n);
		if (r==NN)				  return store(r2==NIX ? JP : JP_NZ+(r2-NZ)*8, n, n>>8);
		if (r==HL||r==XHL)		  return store(JP_HL);
		if (r==IX||(r==XIX&&n==0)) return store(PFX_IX,JP_HL);
		if (r==IY||(r==XIY&&n==0)) return store(PFX_IY,JP_HL);
		goto ill_dest;

	case ' ret':
		// ret
		// ret cc
		r = getCondition(q,no);
		return store(r==NIX ? RET : RET_NZ+(r-NZ)*8);

	case 'call':
		// call nn
		// call cc,nn
		r2 = getCondition(q,yes);
		r  = getRegister(q,n);
		if (r==NN) return store(r2==NIX ? CALL : CALL_NZ+(r2-NZ)*8, n, n>>8);
		goto ill_dest;

	case ' rst':
		// rst n		0 .. 7  or  0*8 .. 7*8
		n = value(q);
		if (n%8==0) n.value>>=3;
		if (n.is_valid() && n>>3) throw syntax_error( "illegal vector number" );
		else return store(RST00+n*8);

	case 'push':	instr = PUSH_HL; goto pop;
	case ' pop':	instr = POP_HL;  goto pop;

		// pop rr		bc de hl af ix iy
pop:
		r = getRegister(q,n);
		if (r>=BC && r<=HL) return store(instr+(r-HL)*16);
		if (r==AF) return store(instr+16);
		if (r==IX) return store(PFX_IX,instr);
		if (r==IY) return store(PFX_IY,instr);
		if (instr==POP_HL) goto ill_target; else goto ill_source;

	case ' dec':	n2 = 1;	goto inc;
	case ' inc':	n2 = 0;	goto inc;

		// inc r	a b c d e h l (hl) (ix+d)
		// inc xh
		// inc rr	bc de hl sp ix iy
inc:
		r = getRegister(q,n);

		instr = INC_xHL + n2;	// inc (hl)  or  dec (hl)
		if (r<=RA)   return store(        instr+(r-XHL)*8);
		if (r==XIX)  return store(PFX_IX, instr, n);
		if (r==XIY)  return store(PFX_IY, instr, n);
		if (r<=XL)   return store(PFX_IX, instr+(r+RH-XH-XHL)*8);
		if (r<=YL)   return store(PFX_IY, instr+(r+RH-YH-XHL)*8);

		if (r==XMMHL)return store(DEC_HL, instr);
		if (r==XHLPP)return store(instr, INC_HL);

		instr = INC_HL + n2*8;	// inc hl or dec hl
		if (r>=BC && r<=SP) return store(instr+(r-HL)*16);
		if (r==IX) return store(PFX_IX, instr);
		if (r==IY) return store(PFX_IY, instr);
		goto ill_target;

	case '  ex':
		// ex af,af'
		// ex hl,de		(or vice versa)
		// ex hl,(sp)
		// ex ix,(sp)	valid illegal. 2006-09-13 kio
		// ex ix,de		does not work: swaps de and hl only. 2006-09-13 kio
		r = getRegister(q,n);
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r==AF) { if (target_8080) goto ill_8080; q.test_char('\'');
					 if (r2==AF)  return store(EX_AF_AF); goto ill_source; }
		if (r==HL) { if (r2==DE)  return store(EX_DE_HL); if (r2==XSP) return store(EX_HL_xSP); goto ill_source; }
		if (r==DE) { if (r2==HL)  return store(EX_DE_HL); goto ill_source; }
		if (r==IX) { if (r2==XSP) return store(PFX_IX, EX_HL_xSP); goto ill_source; }
		if (r==IY) { if (r2==XSP) return store(PFX_IY, EX_HL_xSP); goto ill_source; }
		if (r==XSP){ if (r2==HL)  return store(EX_HL_xSP); if (r2==IX) return store(PFX_IX, EX_HL_xSP);
					 if (r2==IY)  return store(PFX_IY, EX_HL_xSP); goto ill_source; }
		goto ill_target;

	case ' add':
		//	add	a,xxx
		//	add hl,rr	bc de hl sp
		//	add ix,rr	bc de ix sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = ADD_B; goto cp_a; }
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r2<BC || (r2>SP && r2!=r)) goto ill_source;
		if (r==HL) { addhl: return store(ADD_HL_BC+(r2-BC)*16); }
		if (r==IX) { if (r2==HL) goto ill_source; if (r2==r) r2=HL; store(PFX_IX); goto addhl; }
		if (r==IY) { if (r2==HL) goto ill_source; if (r2==r) r2=HL; store(PFX_IY); goto addhl; }
		goto ill_target;

	case ' sbc':
		//	sbc	a,xxx
		//	sbc hl,rr	bc de hl sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = SBC_B; goto cp_a; }
		instr = SBC_HL_BC; goto adc;

	case ' adc':
		//	adc	a,xxx
		//	adc hl,rr	bc de hl sp
		r = getRegister(q,n); if (r==RA || q.testEol()) { instr = ADC_B; goto cp_a; }
		instr = ADC_HL_BC; goto adc;

adc:	if (r!=HL) goto ill_target;
		q.expectComma();
		r2 = getRegister(q,n2);
		if (r2>=BC && r2<=SP) return storeEDopcode(instr+(r2-BC)*16);
		goto ill_source;

	case ' and':	instr = AND_B; goto cp;
	case ' xor':	instr = XOR_B; goto cp;
	case ' sub':	instr = SUB_B; goto cp;
	case '  or':	instr = OR_B;  goto cp;
	case '  cp':	instr = CP_B;  goto cp;

		// cp a,N			first argument (the 'a' register) may be omitted
		// cp a,r			a b c d e h l (hl)
		// cp a,xh
		// cp a,(ix+dis)

		// common handler for
		// add adc sub sbc and or xor cp

cp:		r = getRegister(q,n);
cp_a:	depp=q.p; if (q.testComma()) { if (r!=RA) goto ill_target; else r = getRegister(q,n); }

		if (r<=RA)    { store(instr+r-RB); return; }
		if (r==NN)    { store(instr+CP_N-CP_B); storeByte(n); return; }
		if (r==XIX)   { store(PFX_IX, instr+XHL-RB, n); return; }
		if (r==XIY)   { store(PFX_IY, instr+XHL-RB, n); return; }
		if (r<=XL)    { store(PFX_IX, instr+r+RH-XH-RB); return; }
		if (r<=YL)    { store(PFX_IY, instr+r+RH-YH-RB); return; }
		if (r==XHLPP) { store(instr+XHL-RB, INC_HL); return; }
		if (r==XMMHL) { store(DEC_HL, instr+XHL-RB); return; }
		goto ill_source;

	case '  ld':
		r = getRegister(q,n);
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);
		assert(r>=RB);
		assert(r2>=RB);

		switch(r)
		{
		case RI:
			// ld i,a
			if (r2==RA) return storeEDopcode(LD_I_A);
			goto ill_source;

		case RR:
			// ld r,a
			if (r2==RA) return storeEDopcode(LD_R_A);
			goto ill_source;

		case IX:
			// ld ix,rr		bc de			Goodie
			// ld ix,(NN)
			// ld ix,NN
			instr = PFX_IX;
			goto ld_iy;

		case IY:
			// ld iy,rr		bc de			Goodie
			// ld iy,(NN)
			// ld iy,NN
			instr = PFX_IY;
ld_iy:		if (r2==NN)  return store(instr, LD_HL_NN,  n2, n2>>8);
			if (r2==XNN) return store(instr, LD_HL_xNN, n2, n2>>8);
			if (r2==BC)  { if (target_z180) goto ill_opcode; return store(instr, LD_H_B, instr, LD_L_C); }
			if (r2==DE)  { if (target_z180) goto ill_opcode; return store(instr, LD_H_D, instr, LD_L_E); }
			goto ill_source;

		case HL:
			// ld hl,rr		bc de			Goodie
			// ld hl,(ix+d)					Goodie
			// ld hl,(NN)
			// ld hl,NN
			if (r2==BC)  { store(LD_H_B, LD_L_C); return; }
			if (r2==DE)  { store(LD_H_D, LD_L_E); return; }
			if (r2==NN)  { store(LD_HL_NN,  n2, n2>>8); return; }
			if (r2==XNN) { store(LD_HL_xNN, n2, n2>>8); return; }
			if (r2==XIX) { store(PFX_IX, LD_L_xHL, n2); store(PFX_IX, LD_H_xHL, n2+1); return; }
			if (r2==XIY) { store(PFX_IY, LD_L_xHL, n2); store(PFX_IY, LD_H_xHL, n2+1); return; }
			goto ill_source;

		case BC:
			// ld bc,NN
			// ld bc,(NN)
			// ld bc,rr		de hl ix iy		Goodie
			// ld bc,(hl)					Goodie
			// ld bc,(ix+d)					Goodie
			// ld bc,(hl++)					Goodie
			if (r2==NN)  { store(LD_BC_NN, n2, n2>>8); return; }
			if (r2==XNN) { storeEDopcode(LD_BC_xNN); storeWord(n2); return; }
			if (r2==DE)  { store(LD_B_D, LD_C_E); return; }
			if (r2==HL)  { store(LD_B_H, LD_C_L); return; }
			if (r2==IX)  { if (target_z180) goto ill_opcode; store(PFX_IX, LD_B_H, PFX_IX, LD_C_L); return; }
			if (r2==IY)  { if (target_z180) goto ill_opcode; store(PFX_IY, LD_B_H, PFX_IY, LD_C_L); return; }
			if (r2==XHL) { store(LD_C_xHL, INC_HL, LD_B_xHL, DEC_HL); return; }
			if (r2==XIX) { store(PFX_IX, LD_C_xHL, n2); store(PFX_IX, LD_B_xHL, n2+1); return; }
			if (r2==XIY) { store(PFX_IY, LD_C_xHL, n2); store(PFX_IY, LD_B_xHL, n2+1); return; }
			if (r2==XHLPP) { store(LD_C_xHL, INC_HL, LD_B_xHL, INC_HL); return; }
			if (r2==XMMHL) { store(DEC_HL, LD_B_xHL, DEC_HL, LD_C_xHL); return; }
			goto ill_source;

		case DE:
			// ld de,NN
			// ld de,(NN)
			// ld de,rr		bc hl ix iy		Goodie
			// ld de,(hl)					Goodie
			// ld de,(ix+d)					Goodie
			// ld de,(hl++)					Goodie
			if (r2==NN)    { store(LD_DE_NN, n2, n2>>8); return; }
			if (r2==XNN)   { storeEDopcode(LD_DE_xNN); storeWord(n2); return; }
			if (r2==BC)    { store(LD_D_B, LD_E_C); return; }
			if (r2==HL)    { store(LD_D_H, LD_E_L); return; }
			if (r2==IX)    { if (target_z180) goto ill_opcode; store(PFX_IX, LD_D_H, PFX_IX, LD_E_L); return; }
			if (r2==IY)    { if (target_z180) goto ill_opcode; store(PFX_IY, LD_D_H, PFX_IY, LD_E_L); return; }
			if (r2==XHL)   { store(LD_E_xHL, INC_HL, LD_D_xHL, DEC_HL); return; }
			if (r2==XIX)   { store(PFX_IX, LD_E_xHL, n2); store(PFX_IX, LD_D_xHL, n2+1); return; }
			if (r2==XIY)   { store(PFX_IY, LD_E_xHL, n2); store(PFX_IY, LD_D_xHL, n2+1); return; }
			if (r2==XHLPP) { store(LD_E_xHL,INC_HL,LD_D_xHL,INC_HL); return; }
			if (r2==XMMHL) { store(DEC_HL, LD_D_xHL, DEC_HL, LD_E_xHL); return; }
			goto ill_source;

		case SP:
			// ld sp,rr		hl ix iy
			// ld sp,NN
			// ld sp,(NN)
			if (r2==HL)  { store(LD_SP_HL); return; }
			if (r2==IX)  { store(PFX_IX, LD_SP_HL); return; }
			if (r2==IY)  { store(PFX_IY, LD_SP_HL); return; }
			if (r2==NN)  { store(LD_SP_NN, n2, n2>>8); return; }
			if (r2==XNN) { storeEDopcode(LD_SP_xNN); storeWord(n2); return; }
			goto ill_source;

		case XIX:
			// ld (ix+d),r		a b c d e h l a
			// ld (ix+d),n
			// ld (ix+d),rr		bc de hl		Goodie
			instr = PFX_IX;
			goto ld_xiy;

		case XIY:
			// ld (iy+d),r		a b c d e h l a
			// ld (iy+d),n
			// ld (iy+d),rr		bc de hl		Goodie
			instr = PFX_IY;
ld_xiy:		if (r2<=RA && r2!=XHL) { store(instr, LD_xHL_B+r2-RB, n); return; }
			if (r2==NN) { store(instr, LD_xHL_N, n); storeByte(n2); return; }
			if (r2==HL) { store(instr, LD_xHL_L, n); store(instr, LD_xHL_H, n+1); return; }
			if (r2==DE) { store(instr, LD_xHL_E, n); store(instr, LD_xHL_D, n+1); return; }
			if (r2==BC) { store(instr, LD_xHL_C, n); store(instr, LD_xHL_B, n+1); return; }
			goto ill_source;

		case XHL:
			// ld (hl),r		a b c d e h l a
			// ld (hl),n
			// ld (hl),rr		bc de			Goodie
			if (r2<=RA && r2!=XHL) { store(LD_xHL_B+r2-RB); return; }
			if (r2==NN) { store(LD_xHL_N); storeByte(n2); return; }
			if (r2==BC) { store(LD_xHL_C, INC_HL, LD_xHL_B, DEC_HL); return; }
			if (r2==DE) { store(LD_xHL_E, INC_HL, LD_xHL_D, DEC_HL); return; }
			goto ill_source;

		case XNN:
			// ld (NN),a
			// ld (NN),hl	hl ix iy
			// ld (NN),rr	bc de sp
			if (r2==RA) { store(		LD_xNN_A,  n, n>>8 ); return; }
			if (r2==HL) { store(		LD_xNN_HL, n, n>>8 ); return; }
			if (r2==IX) { store(PFX_IX, LD_xNN_HL, n, n>>8 ); return; }
			if (r2==IY) { store(PFX_IY, LD_xNN_HL, n, n>>8 ); return; }
			if (r2==BC) { storeEDopcode(LD_xNN_BC); storeWord(n); return; }
			if (r2==DE) { storeEDopcode(LD_xNN_DE); storeWord(n); return; }
			if (r2==SP) { storeEDopcode(LD_xNN_SP); storeWord(n); return; }
			goto ill_source;

		case XBC:
			// ld (bc),a
			if (r2==RA) return store(LD_xBC_A);
			goto ill_source;

		case XDE:
			// ld (de),a
			if (r2==RA) return store(LD_xDE_A);
			goto ill_source;

		case XMMBC:
			// ld (--bc),a
			if (r2==RA) return store(DEC_BC, LD_xBC_A);
			goto ill_source;

		case XMMDE:
			// ld (--de),a
			if (r2==RA) return store(DEC_DE, LD_xDE_A);
			goto ill_source;

		case XMMHL:
			// ld (--hl),r
			// ld (--hl),rr
			// ld (--hl),N
			if (r2<=RA && r2!=XHL) { store(DEC_HL, LD_xHL_B + (r2-RB)); return; }
			if (r2==BC) { store(DEC_HL,LD_xHL_B,DEC_HL,LD_xHL_C); return; }
			if (r2==DE) { store(DEC_HL,LD_xHL_D,DEC_HL,LD_xHL_E); return; }
			if (r2==NN) { store(DEC_HL,LD_xHL_N); storeByte(n2); return; }
			goto ill_source;

		case XBCPP:
			// ld (bc++),a
			if (r2==RA) return store(LD_xBC_A, INC_BC);
			goto ill_source;

		case XDEPP:
			// ld (de++),a
			if (r2==RA) return store(LD_xDE_A, INC_DE);
			goto ill_source;

		case XHLPP:
			// ld (hl++),r
			// ld (hl++),rr
			// ld (hl++),N
			if (r2<=RA && r2!=XHL) { store(LD_xHL_B + (r2-RB), INC_HL); return; }
			if (r2==BC) { store(LD_xHL_C,INC_HL,LD_xHL_B,INC_HL); return; }
			if (r2==DE) { store(LD_xHL_E,INC_HL,LD_xHL_D,INC_HL); return; }
			if (r2==NN) { store(LD_xHL_N); storeByte(n2); store(INC_HL); return; }
			goto ill_source;

		case XH:
		case XL:
			// ld xh,r		a b c d e xh xl N
			// ld xl,r		a b c d e xh xl N
			r += RH-XH;
			if (r2<=RE || r2==RA || r2==NN) { store(PFX_IX); goto ld_r; }
			if (r2==XH || r2==XL) { r2 += RH-XH; store(PFX_IX); goto ld_r; }
			goto ill_source;

		case YH:
		case YL:
			// ld yh,r		a b c d e yh yl N
			// ld yl,r		a b c d e yh yl N
			r += RH-YH;
			if (r2<=RE || r2==RA || r2==NN) { store(PFX_IY); goto ld_r; }
			if (r2==YH || r2==YL) { r2 += RH-YH; store(PFX_IY); goto ld_r; }
			goto ill_source;

		case RA:
			// ld a,i
			// ld i,a
			// ld a,(rr)	bc de
			// ld a,(NN)
			if (r2==XBC)   return store(LD_A_xBC);
			if (r2==XDE)   return store(LD_A_xDE);
			if (r2==XNN)   return store(LD_A_xNN, n2, n2>>8);
			if (r2==RI)    return storeEDopcode(LD_A_I);
			if (r2==RR)    return storeEDopcode(LD_A_R);
			if (r2==XBCPP) return store(LD_A_xBC, INC_BC);
			if (r2==XDEPP) return store(LD_A_xDE, INC_DE);
			if (r2==XMMBC) return store(DEC_BC, LD_A_xBC);
			if (r2==XMMDE) return store(DEC_DE, LD_A_xDE);
			goto ld_r;

		case RH:
		case RL:
			if (r2>=XH && r2<=YL) goto ill_source;
			goto ld_r;

		case RB:
		case RC:
		case RD:
		case RE:
			// ld r,r		a b c d e h l (hl)
			// ld r,(ix+d)
			// ld r,N
			// ld r,xh		a b c d e xh xl
			// ld r,yh		a b c d e yh yl
ld_r:		assert(r<=RA && r!=XHL);
			if (r2<=RA)		    { store(LD_B_B + (r-RB)*8 + (r2-RB)); return; }
			if (r2==NN)		    { store(LD_B_N + (r-RB)*8); storeByte(n2); return; }
			if (r2==XIX)	    { store(PFX_IX, LD_B_xHL+(r-RB)*8, n2); return; }
			if (r2==XIY)	    { store(PFX_IY, LD_B_xHL+(r-RB)*8, n2); return; }
			if (r2==XH||r2==XL) { store(PFX_IX,LD_B_H+(r2-XH)+(r-RB)*8); return; }
			if (r2==YH||r2==YL) { store(PFX_IY,LD_B_H+(r2-YH)+(r-RB)*8); return; }
			if (r2==XHLPP)	    { store(LD_B_xHL + (r-RB)*8, INC_HL); return; }
			if (r2==XMMHL)	    { store(DEC_HL, LD_B_xHL + (r-RB)*8); return; }
			goto ill_source;

		case NN:
			goto ill_dest;

		default:
			//IERR();
			goto ill_dest;
		}


// ---- 0xED opcodes ----

	case ' neg':	return storeEDopcode(NEG);
	case ' rrd':	return storeEDopcode(RRD);
	case ' rld':	return storeEDopcode(RLD);
	case ' ldi':	return storeEDopcode(LDI);
	case ' cpi':	return storeEDopcode(CPI);
	case ' ini':	return storeEDopcode(INI);
	case ' ldd':	return storeEDopcode(LDD);
	case ' cpd':	return storeEDopcode(CPD);
	case ' ind':	return storeEDopcode(IND);
	case 'outi':	return storeEDopcode(OUTI);
	case 'outd':	return storeEDopcode(OUTD);
	case 'ldir':	return storeEDopcode(LDIR);
	case 'cpir':	return storeEDopcode(CPIR);
	case 'inir':	return storeEDopcode(INIR);
	case 'otir':	return storeEDopcode(OTIR);
	case 'lddr':	return storeEDopcode(LDDR);
	case 'cpdr':	return storeEDopcode(CPDR);
	case 'indr':	return storeEDopcode(INDR);
	case 'otdr':	return storeEDopcode(OTDR);
	case 'reti':	return storeEDopcode(RETI);
	case 'retn':	return storeEDopcode(RETN);

	case '  im':
		// im n		0 1 2
		r = getRegister(q,n);
		if (r==NN && uint(n)<=2) return storeEDopcode( n==0 ? IM_0 : n==1 ? IM_1 : IM_2);
		throw syntax_error("illegal interrupt mode");

	case '  in':
		// in a,(N)
		// in a,N		(seen in sources)
		// in r,(c)		a f b c d e h l
		// in r,(bc)	a f b c d e h l
		// in (c)		same as "in f,(c)"

		if (q.testWord("f")) r = XHL;
		else { r = getRegister(q,n); if (r==XHL) goto ill_dest; }
		depp = q.p;

		if ((r==XC || r==XBC) && q.peekChar() != ',') return storeEDopcode(IN_F_xC);

		q.expectComma();
		r2 = getRegister(q,n2);

		if(r2==XC || r2==XBC)
		{
			if (r<=RA) return storeEDopcode(IN_B_xC+(r-RB)*8);
			goto ill_dest;
		}
		if (r2==XNN || r2==NN)
		{
			if (r==RA) { store(INA); storeByte(n2); return; }
			goto ill_dest;
		}
		goto ill_source;

	case ' out':
		// out (c),r	a b c d e h l
		// out (c),0	NMOS
		// out (c),255	CMOS
		// out (bc),r	--> out (c),r
		// out (bc),0	--> out (c),0
		// out (bc),255	--> out (c),255
		// out (n),a	--> outa n
		// out n,a      --> outa n		(seen in sources)

		r = getRegister(q,n);
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);

		if (r==XC || r==XBC)
		{
			if (r2<=RA && r2!=XHL) return storeEDopcode(OUT_xC_B+(r2-RB)*8);
			if (r2==NN && (n2==0||n2==255)) return storeEDopcode(OUT_xC_0);
			goto ill_source;
		}
		if (r==XNN || r==NN)
		{
			if (r2!=RA) goto ill_source;
			if (n<-128||n>255) q.p=depp; 	// storeByte() will throw
			store(OUTA); storeByte(n); return;
		}
		goto ill_dest;


// ---- 0xCB opcodes ----

	case ' res':	instr = RES0_B;	goto bit;
	case ' set':	instr = SET0_B;	goto bit;	// note: M80 pseudo instruction SET is handled by asmLabel()
	case ' bit':	instr = BIT0_B;	goto bit;

bit:	n = value(q);
		if (uint(n)>7) throw syntax_error("illegal bit number");
		instr += 8*n;
		q.expectComma();
		goto rr;

	case ' rlc':	instr = RLC_B;	goto rr;
	case ' rrc':	instr = RRC_B;	goto rr;
	case ' sla':	instr = SLA_B;	goto rr;
	case ' sra':	instr = SRA_B;	goto rr;
	case ' sll':	if(target_z180) goto ill_opcode;
					instr = SLL_B;	goto rr;
	case ' srl':	instr = SRL_B;	goto rr;
	case '  rl':	instr = RL_B;	goto rr;
	case '  rr':	instr = RR_B;	goto rr;

		// bit n,r			0..7  a b c d e h l (hl)
		// bit n,(ix+d)
		// bit n,xh			ILLEGAL ***NOT ALL Z80 CPUs!***
		// bit n,(ix+d),r	ILLEGAL ***NOT ALL Z80 CPUs!***

		// common handler for:
		// bit, set, res

		// rr r			a b c d e h l (hl)
		// rr xh		xh xl yh yl		// ILLEGAL: ***NOT ALL Z80 CPUs!***
		// rr (ix+n)	ix iy
		// rr (ix+n),r	a b c d e h l	// ILLEGAL: ***NOT ALL Z80 CPUs!***

		// common handler for:
		// rr rrc rl rlc sla sra sll srl

rr:		if (target_8080) goto ill_8080;
		r2 = getRegister(q,n2);

		if (r2<=RA) return store(PFX_CB, instr + r2-RB);

		if (r2<=YL)
		{
			if (!ixcbxh_enabled) throw syntax_error("illegal instruction (use --ixcbxh)");
			if (r2>=YH) return store(PFX_IY, PFX_CB, 0, instr+r2+RH-YH-RB);
			else	    return store(PFX_IX, PFX_CB, 0, instr+r2+RH-XH-RB);
		}

		if (r2==XIX || r2==XIY)
		{
			r = XHL;
			if (q.testComma())
			{
				if (!ixcbr2_enabled) throw syntax_error("illegal instruction (use --ixcbr2)");
				r = getRegister(q,n);
				if (r>RA || r==XHL) throw syntax_error("illegal secondary destination");
			}
			return store(r2==XIX?PFX_IX:PFX_IY, PFX_CB, n2, instr+r-RB);
		}

		if (r2==XHLPP) return store(PFX_CB, instr + XHL-RB, INC_HL);
		if (r2==XMMHL) return store(DEC_HL, PFX_CB, instr + XHL-RB);

		if ((instr&0xc0)==BIT0_B) goto ill_source; else goto ill_target;


// ---- Z180 opcodes: ----

	case ' slp':	if (target_z180) return store(PFX_ED,0x76); goto ill_z180;
	case 'otim':	if (target_z180) return store(PFX_ED,0x83); goto ill_z180;
	case 'otdm':	if (target_z180) return store(PFX_ED,0x8b); goto ill_z180;

	case ' in0':
		// in0 r,(n)		a b c d e h l f
		if (!target_z180) goto ill_z180;
		if (q.testWord("f")) r = XHL;
		else { r = getRegister(q,n); if (r>RA||r==XHL) goto ill_dest; }
		q.expectComma();
		r2 = getRegister(q,n2);
		if (r2==XNN) { storeEDopcode(0x00+8*(r-RB)); storeByte(n2); return; }
		goto ill_source;

	case ' tst':
		// tst r		b c d e h l (hl) a
		// tst n
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r==NN) { storeEDopcode(0x64); storeByte(n); return; }
		if (r<=RA) { storeEDopcode(0x04+8*(r-RB)); return; }
		goto ill_source;

	case 'mult':
		// mult rr		bc de hl sp
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r>=BC && r<=SP) return store(PFX_ED,0x4c+16*(r-BC));
		goto ill_source;

	case 'out0':
		// out0 (n),r		b c d e h l a
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n); if (r!=XNN) goto ill_dest;
		depp=q.p; q.expectComma();
		r2 = getRegister(q,n2);
		if (r2<=RA && r2!=XHL)
		{
			if (n<-128||n>255) q.p=depp;		// storeByte() will throw
			store(PFX_ED, 0x01+8*(r2-RB)); storeByte(n);
			return;
		}
		goto ill_source;

	default:
		goto misc;
	}

wlen5:
	if ((*w|0x20)=='o')
	{
		if (lceq(w,"otimr"))
		{
			if (target_z180) return store(PFX_ED,0x93);
			goto ill_z180;
		}
		if (lceq(w,"otdmr"))
		{
			if (target_z180) return store(PFX_ED,0x9b);
			goto ill_z180;
		}
		// try macro and pseudo instructions
		goto misc;
	}
	else if ((*w|0x20)=='t' && lceq(w,"tstio"))
	{
		// tstio n
		if (!target_z180) goto ill_z180;
		r = getRegister(q,n);
		if (r==NN) { store(PFX_ED,0x74); storeByte(n); return; }
		goto ill_source;
	}
	else
	{
		// try macro and pseudo instructions
		goto misc;
	}

// generate error
ill_target:		if (depp) q.p=depp; throw syntax_error("illegal target");		// 1st arg
ill_source:		throw syntax_error("illegal source");							// 2nd arg
ill_dest:		if (depp) q.p=depp; throw syntax_error("illegal destination");	// jp etc., ld, in, out: destination
ill_z180:		throw syntax_error("z180 opcode (use option --z180)");
ill_8080:		throw syntax_error("no 8080 opcode (option --8080)");
ill_opcode:		throw syntax_error("illegal opcode (option --z180)");

// try macro and pseudo instructions
misc:	asmPseudoInstr(q,w);
}

uint Z80Assembler::get8080Register (SourceLine& q) throws
{
	// get 8080 register
	// returns register offset 0…7: b,c,d,e,h,l,m,a
	// target_z80 => n(X) and n(Y) returns PFX_XY<<8 + offset (offset checked)

	cstr w = q.nextWord();
	char c = *w; if (c==0) throw syntax_error("unexpected end of line");

	if (*++w==0)	// strlen=1
	{
		switch (c|0x20)
		{
		case 'b':	return 0;
		case 'c':	return 1;
		case 'd':	return 2;
		case 'e':	return 3;
		case 'h':	return 4;
		case 'l':	return 5;
		case 'm':	return 6; // XHL
		case 'a':	return 7;
		}
		if (target_z80)	// n(X) or n(Y)
		{
			Value n = value(q); if(n.is_valid() && n!=(int8)n) throw syntax_error("offset out of range");
			q.expect('(');
			w = q.nextWord();
			if ((*w|0x20)=='x') n = (PFX_IX<<8) + (n&0xff); else
			if ((*w|0x20)=='y') n = (PFX_IY<<8) + (n&0xff); else throw syntax_error("register X or Y exepcted");
			q.expectClose();
			return n;
		}
	}
	throw syntax_error("register A to L or memory M expected");
}

enum { BD, BDHSP,BDHAF };

uint Z80Assembler::get8080WordRegister (SourceLine& q, uint what) throws
{
	// get 8080 word register
	// what -> which register set
	// target_z80 => X and Y returns index register prefix byte

	cstr w = q.nextWord();

	char c1 = *w++ | 0x20;	if (c1==0) throw syntax_error("unexpected end of line");
	char c2 = *w++ | 0x20;

	if (c2==0x20)	// strlen=1
	{
		if (c1=='b') return 0;				// BC
		if (c1=='d') return 16;				// DE
		if (what>BD)
		{
			if (c1=='h') return 32;			// HL
			if (target_z80)
			{
				if (c1=='x') return PFX_IX;	// IX
				if (c1=='y') return PFX_IY;	// IY
			}
		}
	}
	else if (what==BDHSP && c1=='s' && c2=='p' && *w==0) return 48;
	else if (what==BDHAF && c1=='p' && c2=='s' && (*w++|0x20)=='w' && *w==0) return 48;

	throw syntax_error("word register %s expected", what==0 ? "B or D" : what==1 ? "B, D, H or SP" : "B, D, H or PSW");
}

void Z80Assembler::asm8080Instr (SourceLine& q, cstr w) throws
{
	// assemble z80 or 8080 opcode: 8080 assembler syntax
	// no illegals.

	// remmeber: *ALWAYS* evaluate _all_ values _before_ storing the first opcode byte: wg. '$'

	Value  n;
	uint   r,r2;
	uint32 instr;

	assert(current_segment_ptr);

	switch (strlen(w))
	{
	default:	goto misc;
	case 0:		return;						// end of line
	case 2:		instr = peek2X(w); break;
	case 3:		instr = peek3X(w); break;
	case 4:		instr = peek4X(w); break;
	}

	// opcode len = 2, 3, or 4:

	switch(instr|0x20202020)
	{
	case '  rz': return store(RET_Z);		// 8080: rz => ret z
	case '  rc': return store(RET_C);		// 8080: rc => ret c
	case '  rp': return store(RET_P);		// 8080: rp => ret p
	case '  rm': return store(RET_M);		// 8080: rm => ret m
	case ' ret': return store(RET);			// 8080: ret => ret  ; no cc
	case ' rnz': return store(RET_NZ);		// 8080: rnz => ret nz
	case ' rnc': return store(RET_NC);		// 8080: rnc => ret nc
	case ' rpo': return store(RET_PO);		// 8080: rpo => ret po
	case ' rpe': return store(RET_PE);		// 8080: rpe => ret pe
	case ' stc': return store(SCF);			// 8080: stc => scf
	case ' cmc': return store(CCF);			// 8080: cmc => ccf
	case ' cma': return store(CPL);			// 8080: cma => cpl
	case ' rar': return store(RRA);			// 8080: rar => rra
	case ' ral': return store(RLA);			// 8080: ral => rla
	case ' rlc': return store(RLCA);		// 8080: rlc => rlca
	case ' rrc': return store(RRCA);		// 8080: rrc => rrca
	case ' hlt': return store(HALT);		// 8080: hlt => halt
	case 'pchl': return store(JP_HL);		// 8080: pchl => jp (hl)
	case 'xthl': return store(EX_HL_xSP);	// 8080: xthl => ex (sp),hl
	case 'sphl': return store(LD_SP_HL);	// 8080: sphl => ld sp,hl
	case 'xchg': return store(EX_DE_HL);	// 8080: xchg => ex de,hl
	case ' daa': return store(DAA);			// 8080: same as z80
	case ' nop': return store(NOP);			// 8080: same as z80
	case '  ei': return store(EI);			// 8080: same as z80
	case '  di': return store(DI);			// 8080: same as z80

	case 'call': instr = CALL;		goto iw; 	// 8080: call NN => call NN  ; no cc
	case '  cz': instr = CALL_Z;	goto iw;	// 8080: cz NN => call z,NN
	case '  cc': instr = CALL_C;	goto iw;	// 8080: cc NN => call c,NN
	case '  cp': instr = CALL_P;	goto iw;	// 8080: cp NN => call p,NN
	case '  cm': instr = CALL_M;	goto iw;	// 8080: cm NN => call m,NN
	case ' cnz': instr = CALL_NZ;	goto iw;	// 8080: cnz NN => call nz,NN
	case ' cnc': instr = CALL_NC;	goto iw;	// 8080: cnc NN => call nc,NN
	case ' cpo': instr = CALL_PO;	goto iw;	// 8080: cpo NN => call po,NN
	case ' cpe': instr = CALL_PE;	goto iw;	// 8080: cpe NN => call pe,NN
	case '  jz': instr = JP_Z;		goto iw;	// 8080: jz NN => jp z,NN
	case '  jc': instr = JP_C;		goto iw;	// 8080: jc NN => jp c,NN
	case '  jm': instr = JP_M;		goto iw;	// 8080: jm NN => jp m,NN
	case '  jp': instr = JP_P;		goto iw; 	// 8080: jp NN => jp p,NN
	case ' jnz': instr = JP_NZ;		goto iw;	// 8080: jnz NN => jp nz,NN
	case ' jnc': instr = JP_NC;		goto iw;	// 8080: jnc NN => jp nc,NN
	case ' jpo': instr = JP_PO;		goto iw;	// 8080: jpo NN => jp po,NN
	case ' jpe': instr = JP_PE;		goto iw;	// 8080: jpe NN => jp pe,NN
	case ' jmp': instr = JP;		goto iw;	// 8080: jmp NN => jp NN
	case 'lhld': instr = LD_HL_xNN;	goto iw;	// 8080: lhld NN => ld hl,(NN)
	case ' lda': instr = LD_A_xNN;  goto iw; 	// 8080: lda NN  => ld a,(NN)
	case 'shld': instr = LD_xNN_HL; goto iw;	// 8080: shld NN => ld (NN),hl
	case ' sta': instr = LD_xNN_A;  goto iw;	// 8080: sta NN  => ld (NN),a

iw:		n = value(q);							// before store wg. '$'
		return store(instr, n, n>>8);

	case ' out': instr = OUTA;		goto ib;	// 8080: out N => out (N),a
	case '  in': instr = INA;		goto ib;	// 8080: in  N => in a,(N)
	case ' aci': instr = ADC_N;		goto ib;	// 8080: aci N => adc a,N
	case ' adi': instr = ADD_N;		goto ib;	// 8080: adi N => add a,N
	case ' sui': instr = SUB_N;		goto ib;	// 8080: sui N => sub a,N
	case ' sbi': instr = SBC_N;		goto ib;	// 8080: sbi N => sbc a,N
	case ' ani': instr = AND_N;		goto ib;	// 8080: ani N => and a,N
	case ' ori': instr = OR_N;		goto ib;	// 8080: ori N => or a,N
	case ' xri': instr = XOR_N;		goto ib;	// 8080: xri N => xor a,N
	case ' cpi': instr = CP_N;		goto ib; 	// 8080: cpi N => cp a,N

ib:		n = value(q);							// before store wg. '$'
		store(instr);
		return storeByte(n);

	case ' add': instr = ADD_B;		goto cmp; 	// 8080: add r => add a,r		b c d e h l m a
	case ' adc': instr = ADC_B;		goto cmp; 	// 8080: adc r => adc a,r		b c d e h l m a
	case ' sub': instr = SUB_B;		goto cmp; 	// 8080: sub r => sub a,r
	case ' sbb': instr = SBC_B;		goto cmp;	// 8080: sbb r => sbc a,r		b c d e h l m a
	case ' ana': instr = AND_B;		goto cmp;	// 8080: ana r => and a,r		b c d e h l m a
	case ' ora': instr = OR_B;		goto cmp;	// 8080: ora r => or  a,r		b c d e h l m a
	case ' xra': instr = XOR_B;		goto cmp;	// 8080: xra r => xor a,r		b c d e h l m a
	case ' cmp': instr = CP_B;		goto cmp;	// 8080: cmp r => cp  a,r		b c d e h l m a

cmp:	r = get8080Register(q);
		if (r<8) return store(instr + r);		// cmp r
		else return store(r>>8, instr + 6, r);	// cmp d(x)		Z80

	case ' inr': instr = INC_B;		goto dcr;	// 8080: inr r => inc r			b c d e h l m a
	case ' dcr': instr = DEC_B;		goto dcr;	// 8080: dcr r => dec r			b c d e h l m a

dcr:	r = get8080Register(q);
		if (r<8) return store(instr + r*8);		// dcr r
		return store(r>>8, instr + 6*8, r);		// dcr d(x)		Z80

	case ' mvi':								// 8080: mvi r,N => ld r,N		b c d e h l m a

		r = get8080Register(q);
		q.expectComma();
		n = value(q);
		if (r<8) store(LD_B_N + r*8);			// mvi r,N
		else store(r>>8, LD_xHL_N, r);			// mvi d(x),N		Z80
		return storeByte(n);

	case ' mov':								// 8080: mov r,r => ld r,r		b c d e h l m a

		r  = get8080Register(q);
		q.expectComma();
		r2 = get8080Register(q);

		if (r<8)		// mov r,…
		{
			if (r2<8)	// mov r,r
			{
				instr = LD_B_B + r*8 + r2;
				if (instr!=HALT) return store(instr);
			}
			else	// mov r,d(x)		Z80
			{
				instr = LD_B_xHL + r*8;
				if (instr!=HALT) return store(r2>>8, instr, r2);	// PFX, LD_R_xHL, OFFS
			}
		}
		else		// mov d(x),r		Z80
		{
			if (r2<7 && r2!=6) return store(r>>8, LD_xHL_B+r2, r);	// PFX, LD_xHL_R, OFFS
		}
		// ld (hl),(hl)
		// ld (hl),(ix+d)
		// ld (ix+d),(hl)
		// ld (ix+d),(ix+d)
		// ld (ix+d),(iy+d)
		goto ill_source;


ill_source:	throw syntax_error("illegal source");
ill_8080:	throw syntax_error("no 8080 opcode (use option --asm8080 and --z80)");


	case 'ldax':	instr = LD_A_xBC;	goto stax;		// 8080: ldax r => ld a,(rr)	b=bc d=de
	case 'stax':	instr = LD_xBC_A;	goto stax;		// 8080: stax r => ld (rr),a	b=bc d=de

stax:	r = get8080WordRegister(q,BD);
		return store(instr + r);

	case ' dcx':	instr = DEC_BC;		goto inx;		// 8080: dcx r => dec rr		b, d, h, sp
	case ' inx':	instr = INC_BC;		goto inx;		// 8080: inx r => inc rr		b, d, h, sp

inx:	r = get8080WordRegister(q,BDHSP);
		if (r<64) return store(instr + r);				// inc rr
		else	  return store(r,instr+32);				// inc ix		Z80

	case 'push':	instr = PUSH_BC;	goto pop;		// push r => push rr			b d h psw
	case ' pop':	instr = POP_BC;		goto pop;		// pop  r => pop  rr			b d h psw

pop:	r = get8080WordRegister(q, BDHAF);
		if (r<64) return store(instr + r);				// pop r
		else	  return store(r,instr+32);				// pop x		Z80

	case ' lxi':										// 8080: lxi r,NN => ld rr,NN		b, d, h, sp

		r = get8080WordRegister(q,BDHSP);
		q.expectComma();
		n = value(q);

		if (r<64) return store(LD_BC_NN + r, n, n>>8);	// lxi r,NN
		else      return store(r, LD_HL_NN, n, n>>8);	// lxi x,NN		Z80

	case ' dad':										// 8080: dad r => add hl,rr			b, d, h, sp

		r = get8080WordRegister(q,BDHSP);
		if (r<64) return store(ADD_HL_BC + r);			// add hl,rr
		else	  goto ill_source;						// add hl,ix

	case ' rst':										// rst n		0 .. 7  or  0*8 .. 7*8
		n = value(q);
		if (n%8==0) n.value>>=3;
		if (n.is_valid() && n>>3) throw syntax_error( "illegal vector number" );
		else return store(RST00+n*8);

// ---- Z80 opcodes ----

/*	syntax used by CDL's Z80 Macro Assembler (as far as seen in code)
	which seems to be similar to CROSS macro assembler

	Most mnemonics are taken from the CROSS manual except the following:
	I doubt these were ever used…

	RLCR r		CROSS-Doc: RLC: already used for RLCA, also deviation from naming methodology
	RRCR r		CROSS-Doc: RRC: already used for RRCA, also deviation from naming methodology
	OTDR		CROSS-Doc: OUTDR: 5 letter word
	OTIR		CROSS-Doc: OUTIR: 5 letter word
	DADX rr		CROSS-Doc: definition missing	ADD IX,rr
	DADY rr		CROSS-Doc: definition missing	ADD IY,rr
	PCIX		CROSS-Doc: definition missing	JP IX
	PCIY		CROSS-Doc: definition missing	JP IY
	INC  r		CROSS-Doc: definition missing	IN r,(c)
	OUTC r		CROSS-Doc: definition missing	OUT (c),r
	STAR		CROSS-Doc: definition missing	LD R,A
	LDAI		CROSS-Doc: definition missing	LD A,I
	LDAR		CROSS-Doc: definition missing	LD A,R
*/

	case 'djnz':	instr = DJNZ;  goto jr;
	case ' jrz':	instr = JR_Z;  goto jr;
	case 'jrnz':	instr = JR_NZ; goto jr;
	case ' jrc':	instr = JR_C;  goto jr;
	case 'jrnc':	instr = JR_NC; goto jr;
	case 'jmpr':	instr = JR;    goto jr;

jr:		if (target_8080) goto ill_8080;
		n = value(q);
		store(instr);
		return storeOffset(n - dollar() - N2);

	case ' exx':	if (target_8080) goto ill_8080; return store(EXX);
	case 'exaf':	if (target_8080) goto ill_8080; return store(EX_AF_AF);

	case 'xtix':	return storeIXopcode(EX_HL_xSP);
	case 'xtiy':	return storeIYopcode(EX_HL_xSP);
	case 'pcix':	return storeIXopcode(JP_HL);		// kio added
	case 'pciy':	return storeIYopcode(JP_HL);		// kio added

	case ' ccd':	return storeEDopcode(CPD);
	case 'ccdr':	return storeEDopcode(CPDR);
	case ' cci':	return storeEDopcode(CPI);
	case 'ccir':	return storeEDopcode(CPIR);

	case ' ldi':	return storeEDopcode(LDI);
	case 'ldir':	return storeEDopcode(LDIR);
	case ' ldd':	return storeEDopcode(LDD);
	case 'lddr':	return storeEDopcode(LDDR);

	case ' ind':	return storeEDopcode(IND);
	case 'indr':	return storeEDopcode(INDR);
	case ' ini':	return storeEDopcode(INI);
	case 'inir':	return storeEDopcode(INIR);

	case 'outd':	return storeEDopcode(OUTD);
	case 'outi':	return storeEDopcode(OUTI);
	case 'otdr':	return storeEDopcode(OTDR);			// org. CROSS: 'OUTDR' which is a 5 letter word
	case 'otir':	return storeEDopcode(OTIR);			// org. CROSS: 'OUTIR' which is a 5 letter word

	case 'stai':	return storeEDopcode(LD_I_A);
	case 'star':	return storeEDopcode(LD_R_A);		// kio added
	case 'ldai':	return storeEDopcode(LD_A_I);		// kio added
	case 'ldar':	return storeEDopcode(LD_A_R);		// kio added

	case ' im0':	return storeEDopcode(IM_0);
	case ' im1':	return storeEDopcode(IM_1);
	case ' im2':	return storeEDopcode(IM_2);
	case 'retn':	return storeEDopcode(RETN);
	case 'reti':	return storeEDopcode(RETI);
	case ' rld':	return storeEDopcode(RLD);
	case ' rrd':	return storeEDopcode(RRD);
	case ' neg':	return storeEDopcode(NEG);

	case 'spix':	return storeIXopcode(LD_SP_HL);		// 8080: sphl => ld sp,hl
	case 'spiy':	return storeIYopcode(LD_SP_HL);		// 8080: sphl => ld sp,hl

	case 'sbcd':	instr = LD_xNN_BC; goto lspd;		// named acc. to SHLD  X-]
	case 'sded':	instr = LD_xNN_DE; goto lspd;
	case 'sspd':	instr = LD_xNN_SP; goto lspd;
	case 'lbcd':	instr = LD_BC_xNN; goto lspd;		// named after LHLD  X-]
	case 'lded':	instr = LD_DE_xNN; goto lspd;
	case 'lspd':	instr = LD_SP_xNN; goto lspd;

lspd:	n = value(q);
		storeEDopcode(instr);
		return storeWord(n);

	case ' inc':	instr = IN_B_xC;  goto outc;		// in r,(c)				kio added
	case 'outc':	instr = OUT_xC_B; goto outc;		// out (c),r			kio added

outc:	r = get8080Register(q);
		if (r<8 && r!=6) return storeEDopcode(instr+r*8);
		throw syntax_error("register A to L expected");

	case 'sixd':	instr = LD_xNN_HL; goto lixd;
	case 'lixd':	instr = LD_HL_xNN; goto lixd;

lixd:	n = value(q);
		storeIXopcode(instr);
		return storeWord(n);

	case 'siyd':	instr = LD_xNN_HL; goto liyd;
	case 'liyd':	instr = LD_HL_xNN; goto liyd;

liyd:	n = value(q);
		storeIXopcode(instr);
		return storeWord(n);

	case 'dadc':	instr = ADC_HL_BC; goto dsbc;
	case 'dsbc':	instr = SBC_HL_BC; goto dsbc;

dsbc:	r = get8080WordRegister(q,BDHSP);
		if (r<64) return storeEDopcode(instr+r);
		throw syntax_error("illegal register");		// X or Y

	case 'dadx':	// DADX: add ix,bc,de,ix,sp		kio added; note: DAD = add hl,rr

		r = get8080WordRegister(q,BDHSP);
		if (r<64 && r!=32) return storeIXopcode(ADD_HL_BC+r);
		if (r==PFX_IX)	   return storeIXopcode(ADD_HL_HL);
		goto ill_source;							// add ix,hl or add ix,iy

	case 'dady':	// DADY: add iy,bc,de,iy,sp		kio added; note: DAD = add hl,rr

		r = get8080WordRegister(q,BDHSP);
		if (r<64 && r!=32) return storeIYopcode(ADD_HL_BC+r);
		if (r==PFX_IY)	   return storeIYopcode(ADD_HL_HL);
		goto ill_source;							// add iy,hl or add iy,ix

	case ' res':	instr = RES0_B;		goto bit;	// RES b,r
	case ' set':	instr = SET0_B;		goto bit;	// SET b,r
	case ' bit':	instr = BIT0_B;		goto bit;	// BIT b,r

	// BIT b,r		  BIT b,%r
	// BIT b,(IX+d)   BIT b,d(X)
	// BIT b,(IY+d)   BIT b,d(Y)

bit:	if (target_8080) goto ill_8080;
		n = value(q);
		if (uint(n)>7) throw syntax_error("illegal bit number");
		instr += 8*n;
		q.expectComma();
		goto rlcr;

	case 'slar':	instr = SLA_B;		goto rlcr;	// SLA r
	case 'srlr':	instr = SRL_B;		goto rlcr;	// SRL r
	case 'srar':	instr = SRA_B;		goto rlcr;	// SRA r
	case 'ralr':	instr = RL_B;		goto rlcr;	// RL  r
	case 'rarr':	instr = RR_B;		goto rlcr;	// RR  r
	case 'rrcr':	instr = RRC_B;		goto rlcr;	// RRC r		CROSS doc: RRC
	case 'rlcr':	instr = RLC_B;		goto rlcr;	// RLC r		CROSS doc: RLC

rlcr:	if (target_8080) goto ill_8080;
		r = get8080Register(q);
		if (r<8) return store(PFX_CB, instr + r);
		else     return store(r>>8, PFX_CB, r, instr+6);	// PFX_IX, PFX_CB, OFFS, RLC_xHL

	default:	goto misc;
	}

// try macro expansion and pseudo instructions:
misc:	return asmPseudoInstr(q,w);
}



























