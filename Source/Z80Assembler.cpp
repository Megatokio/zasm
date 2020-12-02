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
#include "Z80/goodies/z80_goodies.h"
#include "zx7.h"
#include "Templates/StrArray.h"
#include "kio/peekpoke.h"
#include "Z80Registers.h"

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
static cValue N0(0);
static cValue N1(1);
static cValue N2(2);



// --------------------------------------------------
//					Helper
// --------------------------------------------------

void Z80Assembler::setError (const AnyError& e)
{
	// set error for current file, line & column

	SourceLine* sourceline = current_sourceline_index < source.count() ? &current_sourceline() : nullptr;

	errors.append(Error(e.what(), sourceline));
	if (verbose >= 2) logline("%s",errors.last().text);
}

void Z80Assembler::setError (cstr format, ...)
{
	// set error for current file, line & column

	SourceLine* sourceline = current_sourceline_index < source.count() ? &current_sourceline() : nullptr;

	va_list va;
	va_start(va,format);
	errors.append( Error(format, sourceline, va) );
	if (verbose >= 2) logline("%s",errors.last().text);
	va_end(va);
}

void Z80Assembler::setError (SourceLine* sourceline, cstr format, ...)
{
	// set error for file, line & column

	va_list va;
	va_start(va,format);
	errors.append( Error(format, sourceline, va) );
	if (verbose >= 2) logline("%s",errors.last().text);
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
		throw SyntaxError(dir ? "quoted directory name expected" : "quoted filename expected");
	fqn = unquotedstr(fqn);
	if (dir && lastchar(fqn)!='/') fqn = catstr(fqn,"/");

	if (cgi_mode) // && q.sourcelinenumber)
	{
		if (fqn[0]=='/' || startswith(fqn,"~/") || startswith(fqn,"../") || contains(fqn,"/../"))
			throw FatalError("Escape from Darthmoore Castle");
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

inline bool utf8_is_ucs4 (char c) { return uchar(c)> 0xf0; }	// 2015-01-02 doesn't fit in ucs2?
#define     RMASK(n)	 (~(0xFFFFFFFF<<(n)))					// mask to select n bits from the right

uint8 Z80Assembler::charcode_from_utf8 (cptr& s) throws
{
	// read next character
	// decode UTF-8 char
	// convert to charset
	// on error try to fallback to ucs1 or throw
	// char(0) is a valid character
	// note: accepts only UCS2 because CharMap is UCS2 only

	uint8 c = uint8(*s++);
	if (is_ascii(char(c)))
	{
		return charset ? charset->get(c) : c; // 7-bit ascii char
	}

	cptr s0 = s;
	if (is_utf8_fup(char(c)) || utf8_is_ucs4(char(c))) // error: unexpected fup or code exceeds UCS2
	{
err:	s = s0;
		// for charset conversion we need to know the character, not only the code:
		if (charset) throw SyntaxError("invalid utf-8 character! please convert source to UTF8.");
		// else print warning. TODO: wtore warnings like errors
		if (verbose && pass == 1)
			logline("invalid utf-8 character: using UCS1 instead. please convert source to UTF8.");
		return c;
	}

	// longish character:
	uint n = c;							// char code akku
	uint i = 0;							// UTF-8 character size
	while (int8(c<<(++i)) < 0)			// loop over fup bytes
	{
		char c1 = *s++;
		if (!is_utf8_fup(c1)) goto err;	// error: expected fup
		n = (n<<6) + (c1&0x3F);
	}

	// look-ahead error checking:
	if (is_utf8_fup(*s)) goto err;		// error: more unexpected fups follows

	// now: i = total number of digits
	//      n = char code with some of the '1' bits from c0
	n &= RMASK(2+i*5);

	// ok => return code

	if (charset) return charset->get(UCS2Char(n));
	else if (n>0xFF) throw SyntaxError("character code exceeds byte limit");
	else return uint8(n);
}

void Z80Assembler::checkCpuOptions() throws
{
	if (convert_8080) syntax_8080 = yes;	// implied
	if (syntax_8080)  casefold = yes; 		// implied

	if (cpu == CpuDefault)
	{
		target_8080 = syntax_8080;
		target_z80  = !syntax_8080;			// default = Z80 except if asm8080 is set
		target_z180 = no;
	}
	else
	{
		target_z80  = cpu == CpuZ80;
		target_z180 = cpu == CpuZ180;
		target_8080 = cpu == Cpu8080;
	}

	target_z80_or_z180 = target_z80 || target_z180;

	if (target_z80)
	{
		if (ixcbr2_enabled && ixcbxh_enabled)
			throw FatalError("options ixcbr2 and ixcbxh are mutually exclusive.");
	}

	if (target_z180)
	{
		if (syntax_8080)
			throw FatalError("8080 syntax: Z180 opcodes not supported.");
		if (ixcbr2_enabled || ixcbxh_enabled)
			throw FatalError("ixcbr2 and ixcbxh not allowed: the Z180 traps illegal instructions");
	}

	if (target_8080)
	{
		if (ixcbr2_enabled || ixcbxh_enabled)
			throw FatalError("ixcbr2 and ixcbxh not allowed: i8080 has no index registers.");
	}
}



// --------------------------------------------------
//					c'tor & d'tor
// --------------------------------------------------


Z80Assembler::Z80Assembler ()
:
	target_z180(no),
	target_8080(no),
	target_z80(yes),
	target_z80_or_z180(yes),
	starttime(0.0),
	source_directory(nullptr),
	source_filename(nullptr),
	temp_directory(nullptr),
	target_ext(nullptr),
	target_filepath(nullptr),
	target(TARGET_UNSET),
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
	pass(0),
	end(0),
	validity(invalid),
	labels_changed(0),
	labels_resolved(0),
	is_sdcc(no),
	is_vcc(no),
	c_tempdir(nullptr),
	c_qi(-1),
	c_zi(-1),
	asmInstr(&Z80Assembler::asmPseudoInstr)
{}

Z80Assembler::~Z80Assembler ()
{
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

	starttime = now();

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

	temp_directory = temppath ? temppath : dest_directory;
	assert(is_dir(temp_directory));
	if (clean && is_dir(catstr(temp_directory,"s/"))) delete_dir(catstr(temp_directory,"s/"),yes);

	if (convert_8080)
	{
		cstr z80_file = destpath;
		if(endswith(z80_file,"/")) z80_file = catstr(destpath, basename, ".z80"); // modifying the extension only simplifies usage in zasm.cgi

		// convert:
		convert8080toZ80(sourcefile,z80_file);

		// assemble original source:
		convert_8080 = false;
		assembleFile(sourcefile, temppath/*output*/, listpath, temppath, liststyle, deststyle, clean);
		if (errors.count()) return;

		// assemble and compare converted source:
		syntax_8080 = false;
		compare_to_old = true;
		assembleFile(z80_file, target_filepath/*prev.output*/, listpath, temppath, liststyle, deststyle, clean);
		return;
	}

	try
	{
		if (c_compiler) init_c_compiler(c_compiler);

		StrArray source;
		FD fd(sourcefile, 'r');
		if (fd.file_size() > 10000000) throw AnyError("source file exceeds 10,000,000 bytes");	// sanity
		fd.skip_utf8_bom();
		fd.read_file(source);
		while(source.count() && source.last()[0]==0x1A) source.drop(); // remove CP/M file padding

		// include options after shebang in line 1:
		// note: this my come as a surprise to the user
		if (source.count() && startswith(source[0],"#!"))
		{
			cstr s = source[0];
			cstr m = nullptr;

			// override cpu only if not set on command line:
			if (cpu == CpuDefault && find(s,"--z80"))  { cpu = CpuZ80;  m = " --z80";  }
			if (cpu == CpuDefault && find(s,"--8080")) { cpu = Cpu8080; m = " --8080"; }
			if (cpu == CpuDefault && find(s,"--z180")) { cpu = CpuZ180; m = " --z180"; }

			// add options not yet set:
			if (!ixcbr2_enabled && !ixcbxh_enabled && find(s,"--ixcbr2")) { ixcbr2_enabled = yes; m = catstr(m," --ixcbr2"); }
			if (!ixcbr2_enabled && !ixcbxh_enabled && find(s,"--ixcbxh")) { ixcbxh_enabled = yes; m = catstr(m," --ixcbxh"); }
			if (!syntax_8080 && find(s,"--asm8080"))	{ syntax_8080 = yes;    m = catstr(m," --asm8080");  }
			if (!allow_dotnames && find(s,"--dotnames")){ allow_dotnames = yes; m = catstr(m," --dotnames"); }
			if (!require_colon && find(s,"--reqcolon")) { require_colon = yes;  m = catstr(m," --reqcolon"); }
			if (!casefold && find(s,"--casefold"))		{ casefold = yes;	    m = catstr(m," --casefold"); }
			if (!flat_operators && find(s,"--flatops")) { flat_operators = yes; m = catstr(m," --flatops");  }

			if (m && verbose) log("options added from line 1:%s\n", m);
		}

		checkCpuOptions();
		assemble(source,sourcefile);
		if (errors.count()==0) checkTargetfile();
		if (errors.count()==0) runTestcode();

		if (errors.count()==0 && deststyle)
		{
			destpath = endswith(destpath,"/") ? catstr(destpath, basename, ".$") : destpath;
			if (compare_to_old)
			{
				cstr zdir = catstr(tempdirpath(), "/zasm/", tostr(getuid()), "/test/");
				create_dir(zdir,0770,yes);
				cstr zpath = catstr(zdir,basename,".$");
				writeTargetfile(zpath,deststyle);
				if (endswith(destpath,".$"))
					destpath = catstr(leftstr(destpath,int(strlen(destpath))-2), extension_from_path(zpath));
				FD old(destpath);	// may throw if n.ex.
				FD nju(zpath);
				long ofsz = old.file_size();
				long nfsz = nju.file_size();

				if (ofsz!=nfsz) setError("file size mismatch: old=%li, new=%li", ofsz, nfsz);
				uint32 bsize = uint32(min(ofsz,nfsz));
				std::unique_ptr<uint8[]> obu(new uint8[bsize]);
				std::unique_ptr<uint8[]> nbu(new uint8[bsize]);
				old.read_data(&obu[0],bsize);
				nju.read_data(&nbu[0],bsize);
				for (uint32 i=0; i<bsize && errors.count()<max_errors; i++)
				{
					if (obu[i]==nbu[i]) continue;
					setError("mismatch at $%04lX: old=$%02X, new=$%02X",ulong(i),obu[i],nbu[i]);
				}

				if (errors.count()==0)
				{
					// test generation of listfile:
					if (!liststyle) liststyle = 2+4+8;
					if (!listpath) listpath = zdir;
				}
			}
			else
			{
				writeTargetfile(destpath,deststyle);
			}
		}
	}
	catch (AnyError& e) { setError("%s",e.what()); }

	if (liststyle)
	{
		try
		{
			if (!listpath) listpath = directory_from_path(destpath);
			listpath = quick_fullpath(listpath);
			listpath = endswith(listpath,"/") ? catstr(listpath, basename, ".lst") : listpath;
			writeListfile(listpath, liststyle);
		}
		catch (AnyError& e) { setError("%s",e.what()); }
	}
}

void Z80Assembler::setLabelValue (Label* label, cValue& value) throws
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
			if (value == label->value.value) return;
			else throw SyntaxError("label redefined (use 'defl' or '=' for redefinable labels)");
		}
	}

	if (validity > label->value.validity)
		labels_resolved++;

	if (validity < label->value.validity)
	{
		if (pass==1) throw SyntaxError("label redefined (use 'defl' or '=' for redefinable labels)");
		else throw SyntaxError("label %s value decayed",label->name);
	}

	if (value != label->value.value) labels_changed++;

x:	label->value = Value(value,validity);
	label->is_defined = yes;
}

void Z80Assembler::assemble (StrArray& sourcelines, cstr sourcepath) noexcept
{
	// assemble source[]
	// output will be in
	//   source[];
	//   labels[];
	//   segments[];
	//   errors[];

	source.purge();
	for (uint i=0;i<sourcelines.count();i++) { source.append(new SourceLine(sourcepath, i, dupstr(sourcelines[i]))); }
	current_sourceline_index = 0;

	//target_str = NULL;
	target = TARGET_UNSET;

	// setup labels:
	labels.purge();
	labels.append(Labels(Labels::GLOBALS));		// global_labels must exist

	// setup segments:
	segments.purge();

	// add labels for options:
	if (cpu==CpuZ80)	global_labels().add(new Label("_z80_",		nullptr,0,1,valid,yes,yes,no));
	if (cpu==CpuZ180)	global_labels().add(new Label("_z180_",		nullptr,0,1,valid,yes,yes,no));
	if (cpu==Cpu8080)	global_labels().add(new Label("_8080_",		nullptr,0,1,valid,yes,yes,no));
	//if (syntax_8080)	global_labels().add(new Label("_asm8080_",	nullptr,0,1,valid,yes,yes,no));
	if (ixcbr2_enabled)	global_labels().add(new Label("_ixcbr2_",	nullptr,0,1,valid,yes,yes,no));
	if (ixcbxh_enabled)	global_labels().add(new Label("_ixcbxh_",	nullptr,0,1,valid,yes,yes,no));
	//if (allow_dotnames)	global_labels().add(new Label("_dotnames_",	nullptr,0,1,valid,yes,yes,no));
	//if (require_colon)	global_labels().add(new Label("_reqcolon_",	nullptr,0,1,valid,yes,yes,no));
	//if (casefold) 		global_labels().add(new Label("_casefold_",	nullptr,0,1,valid,yes,yes,no));
	//if (flat_operators)	global_labels().add(new Label("_flatops_",	nullptr,0,1,valid,yes,yes,no));

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
				//if (!(i>0 && l->is_global))	// because .globl labels encountered twice!
				if (l->value.is_valid())    	// because .globl labels encountered twice!
					labels_resolved--;
				l->value.validity = invalid;
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
		catch(FatalError& e)
		{
			setError(e);
			return;
		}
		catch(AnyError& e)
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
		Value test_address(0,valid);	// for test segments (dummy sink)

		for (uint i=0; i<segments.count(); i++)
		{
			DataSegment* s = dynamic_cast<DataSegment*>(segments[i].ptr()); if (!s) continue;
			Value& seg_address = s->isData() ? data_address : s->isCode() ? code_address : test_address;

			if (s->resizable) s->setSize(s->dpos);
			else if (auto d = dynamic_cast<CodeSegment*>(s)) { d->clearTrailingBytes(); }

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
	catch(AnyError& e)
	{
		setError("%s",e.what());
		return;
	}
}

void Z80Assembler::replaceCurlyBraces (SourceLine& q) throws
{
	assert(pass==1);
	assert(!cond_off);

	q.rewind();

	if (!strchr(q.text,'{')) return;

	// some test commands have arguments with "{…}"
	// TODO: replace "{…}" with "[…]"
	if (current_segment_ptr && current_segment().isTest())
	{
		if (find(q.text, ".test-in")) return;
		if (find(q.text, ".test-out")) return;
	}

	// search for '{' using nextWord():
	// => do not search in chars and strings and stop at ';'

	for(;;)
	{
		cstr w = q.nextWord();
		if (*w==0) break;					// ';' or EOL
		if (*w!='{') continue;

		cstr p = q.p-1;						// p -> '{'
		Value v = value(q, pAny);			// evaluate value
		q.expect('}');
		if (!v.is_valid()) throw SyntaxError("value in braces must be valid in pass 1");
		cstr rpl = numstr(v.value);			// textual replacement

		cstr z = catstr(substr(q.text,p), rpl, q.p);

		ssize_t d = q.p - p;				// length '{' … '}'
		d = ssize_t(strlen(rpl)) - d;		// d = newlen - oldlen
		q.p += (z-q.text) + d;				// point q.p behind rpl in new string
		q.text = z;
	}
	q.rewind();
}

void Z80Assembler::assembleLine (SourceLine& q) throws
{
	// Assemble SourceLine

	if (pass==1) q.segment = current_segment_ptr;	// for Temp Label Resolver
	q.byteptr = current_segment_ptr ? uint(currentPosition()) : 0; // for Temp Label Resolver & Logfile
	//if (pass==1) q.bytecount = 0;		// for Logfile and skip over error in pass 2++
	if (current_segment_ptr) cmd_dpos = currentPosition();
	if (pass==1 && !cond_off) replaceCurlyBraces(q);
	q.rewind();

	if (q.test_char('#'))		// #directive ?
	{
		asmDirect(q);
		q.expectEol();			// expect end of line
	}
	else if (cond_off)			// assembling conditionally off ?
	{
		if (!require_colon && uchar(*q) > ' ' && (*q != '.' || allow_dotnames)) return; // even 'IF' etc. is a label
		if (q.testDotWord("endif")) { if (!q.testChar(':')) { asmEndif(q); q.expectEol(); } return; }
		if (q.testDotWord("if"))    { if (!q.testChar(':')) { asmIf(q);    q.expectEol(); } return; }
		if (q.testDotWord("elif"))  { if (!q.testChar(':')) { asmElif(q);  q.expectEol(); } return; }
		if (q.testDotWord("else"))  { if (!q.testChar(':')) { asmElse(q);  q.expectEol(); } return; }
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
		catch (AnyError&)		// we expect to come here:
		{
			assert(q.segment==current_segment_ptr);		// zunächst: wir nehmen mal an,
			//assert(currentPosition() == q.byteptr);	// dass dann auch kein Code erzeugt wurde

			if (current_segment_ptr)
			{
				if (q.segment==current_segment_ptr)
					q.bytecount = uint(currentPosition()) - q.byteptr;
				else
				{
					q.segment = current_segment_ptr;	// .area instruction
					q.byteptr = uint(currentPosition());// Für Temp Label Resolver & Logfile
					assert(q.bytecount==0);
				}
			}

			return;
		}
		throw SyntaxError("instruction did not fail!");
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
					q.bytecount = uint(currentPosition()) - q.byteptr;
				else
				{
					q.segment = current_segment_ptr;	// .area instruction
					q.byteptr = uint(currentPosition());// Für Temp Label Resolver & Logfile
					assert(q.bytecount==0);
				}
			}
		}
		catch (SyntaxError& e)
		{
			if (pass>1)
				if (auto s = dynamic_cast<DataSegment*>(q.segment))
					s->skipExistingData(uint(q.byteptr + q.bytecount) - uint(currentPosition()));
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
	sourcelines.append(catstr(" ",instruction));		// the instruction to assemble
	assemble(sourcelines,"");

	CodeSegment& segment = dynamic_cast<CodeSegment&>(current_segment());

	if (segment.size.value > 4) setError("resulting code size exceeds size of z80 opcodes");	// defs etc.
	if (errors.count()) return 0;
	memcpy(buffer,segment.getData(),uint(segment.size));
	return uint(segment.size);
}

void Z80Assembler::skip_expression (SourceLine& q, int prio) throws
{
	cstr w = q.nextWord();				// get next word
	if (w[0]==0)						// end of line
eol:	throw SyntaxError("unexpected end of line");

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
		if (w[0]=='$' || w[0]=='%' || w[0]=='\'' || w[0]=='&') goto op;	// hex number or $$, binary, hex, or ascii number
	}

	if (is_dec_digit(w[0])) { q.test_char('$'); goto op; }	// decimal number or reusable label
	if (!is_letter(*w) && *w!='_' && *w!='.') throw SyntaxError("syntax error");	// last chance: plain idf

	if (q.testChar('('))				// test for built-in function
	{
		if (eq(w,"defined") || eq(w,"hi") || eq(w,"lo") || eq(w,"min") || eq(w,"max") ||
			eq(w,"opcode") || eq(w,"target") || eq(w,"segment") || eq(w,"required") ||
			eq(w,"sin") || eq(w,"cos"))
		{
			for (uint nkl = 1; nkl; )
			{
				w = q.nextWord();
				if (w[0]==0) throw SyntaxError("')' missing");	// EOL
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
	// any reference to unknown or not-yet-valid label sets argument 'validity' and 'this.validity' to invalid

	Value n = N0;					// value of expression, valid

// ---- expect term ----
w:	cstr w = q.nextWord();			// get next word
	if (w[0]==0) goto syntax_error;	// empty word

	if (w[1]==0)					// 1 char word
	{
		switch (w[0])
		{
		case '#':	if (prio==pAny) goto w; else goto syntax_error;	// SDASZ80: immediate value prefix
		case ';':	throw SyntaxError("value expected");	// comment  =>  unexpected end of line
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
		else if (w[0]=='&')			// hex number
		{
			w++;
			goto hex_number;
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
			uint slen = uint(strlen(w));
			if (slen<3||w[slen-1]!=w[0]) goto syntax_error;
			w = unquotedstr(w);
			n.value = charcode_from_utf8(w);
			if (*w) throw SyntaxError("only one character allowed");
			goto op;
		}
		else if (is_dec_digit(w[0]))	// decimal number
		{
			if (w[0]=='0')
			{
				if (to_lower(w[1])=='x' && w[2]) { w+=2; goto hex_number; }	// 0xABCD
				if (to_lower(w[1])=='b' && w[2] && is_bin_digit(lastchar(w))) // caveat e.g.: 0B0h
												{ w+=2; goto bin_number; }	// 0b0101
			}
			c = to_lower(lastchar(w));
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
		n = int(q.sourcelinenumber); /* valid = valid && yes; */ goto op;
	}

	if (q.test_char('('))		// test for built-in function
	{
		if (eq(w,"defined"))	// defined(NAME)  or  defined(NAME::)
		{						// note: label value is not neccessarily valid
								// value of 'defined()' is always valid
			w = q.nextWord();
			if (!is_letter(*w) && *w!='_') throw FatalError("label name expected");
			bool global = q.testChar(':')&&q.testChar(':');

			if (pass == 1)
			{
				for (uint i=global?0:local_labels_index;;i=labels[i].outer_index)
				{
					Label* label = labels[i].find(w);
					if (label!=nullptr && label->is_defined) { n=1; break; }
					if (i==0) { n=0; break; }
				}
				if_values.append(n.value);
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
			if (!(is_letter(*w) || *w=='_' || (allow_dotnames&&*w=='.'))) throw FatalError("label name expected");
			bool global = q.testChar(':')&&q.testChar(':');

			if (pass==1)
			{
				for (uint i=global?0:local_labels_index;;i=labels[i].outer_index)
				{
					Label* label = labels[i].find(w);
					if (label!=nullptr) { n = label->is_used && !label->is_defined; break; }
					if (i==0) { n=0; break; }
				}
				if_values.append(n.value);
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
			if (abs(b.value) < 4) { if (b.is_valid()) throw SyntaxError("value for full circle must be ≥ 4"); b.value = 360; }
			q.expectComma();
			n = value(q);			// scale value for result (==1.0)
			if (n.value == 0) { if (n.is_valid()) throw SyntaxError("scale value for result must be ≥ 1"); n.value = 128; }

			n.validity = min(n.validity,min(a.validity,b.validity));
			double r = a.value * 6.2831853071796 / b.value;
			n.value  = int32(round((eq(w,"sin") ? sin(r) : cos(r)) * n.value));
			goto kzop;
		}
		else if (eq(w,"opcode"))	// opcode(ld a,N)  or  opcode(bit 7,(hl))  etc.
		{
			cptr a = q.p;
			uint nkl = 1;
			while (nkl)
			{
				w = q.nextWord();
				if (w[0]==0) throw SyntaxError("')' missing");	// EOL
				if (w[0]=='(') { nkl++; continue; }
				if (w[0]==')') { nkl--; continue; }
				if (lceq(w,"af") && *q=='\'') q+=1;
			}
			n = syntax_8080 ? major_opcode_8080(substr(a,q.p-1)) : major_opcode(substr(a,q.p-1));
			goto op;
		}
		else if (eq(w,"target"))
		{
			if (!target && current_segment_ptr==nullptr) throw SyntaxError("#target not yet defined");
			n = q.testWord(target ? target_ext : "ROM");
			if (!n && !is_name(q.nextWord())) throw SyntaxError("target name expected");
			goto kzop;
		}
		else if (eq(w,"segment"))
		{
			if (current_segment_ptr==nullptr) throw SyntaxError("#code or #data segment not yet defined");
			n = q.testWord(current_segment_ptr->name);
			if (!n && !is_name(q.nextWord())) throw SyntaxError("segment name expected");
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
					throw SyntaxError("label \"%s\" not found",w);
				}
				if (l->was_redefined && l->is_invalid() && l->sourceline > current_sourceline_index)
					throw SyntaxError("redefinable label \"%s\" not yet defined here",w);

				n = l->value;
				assert(l->is_used);
				goto op;
			}
		}
	}

// if we come here we are out of clues:
syntax_error:
	throw SyntaxError("syntax error");

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
	cc:	if (c1 >= 'a')
		{
			if (c1=='n' && c2=='e')  { n.ne(value(q+=2,pCmp)); goto op; }
			if (c1=='e' && c2=='q')  { n.eq(value(q+=2,pCmp)); goto op; }
			if (c1=='g' && c2=='e')  { n.ge(value(q+=2,pCmp)); goto op; }
			if (c1=='g' && c2=='t')  { n.gt(value(q+=2,pCmp)); goto op; }
			if (c1=='l' && c2=='e')  { n.le(value(q+=2,pCmp)); goto op; }
			if (c1=='l' && c2=='t')  { n.lt(value(q+=2,pCmp)); goto op; }
		}
		else
		{
			if (c1 == '=') { q+=c2-c1?1:2; n.eq(value(q,pCmp)); goto op; }	// equal: = ==
			if (c1 == '!' && c2=='=') { n.ne(value(q+=2,pCmp)); goto op; }	// not equal: !=
			if (c1 == '<')
			{
				if (c2 == '>')	{ n.ne(value(q+=2,pCmp)); goto op; }		// not equal:   "<>"
				if (c2 == '=')	{ n.le(value(q+=2,pCmp)); goto op; }		// less or equ:	"<="
				if (c2 != '<')	{ n.lt(value(q+=1,pCmp)); goto op; }		// less than:	"<"
			}
			if (c1=='>')
			{
				if (c2 == '=')	{ n.ge(value(q+=2,pCmp)); goto op; }		// greater or equ:	">="
				if (c2 != '>')	{ n.gt(value(q+=1,pCmp)); goto op; }		// greater than:	">"
			}
		}
		goto dd;

	case pAdd:	// + -
	dd:	if (c1 == '+') { n += value(++q,pAdd); goto op; }
		if (c1 == '-') { n -= value(++q,pAdd); goto op; }
		goto ee;

	case pMul:	// * / %
	ee:	if (c1 == '*') { n *= value(++q,pMul); goto op; }
		if (c1 == '/')
		{
			Value m = value(++q,pMul);
			if (m.value == 0) { if (!m.is_valid()) { m = N1; } else throw SyntaxError("division by zero"); }
			n /= m;
			goto op;
		}
		if (c1 == '%')
		{
			Value m = value(++q,pMul);
			if (m.value == 0) { if (!m.is_valid()) { m = N1; } else throw SyntaxError("division by zero"); }
			n %= m;
			goto op;
		}
		goto ff;

	case pBits:	// & | ^
	ff:	if (c1=='^')					  { n ^= value(++q, pBits); goto op; }
		if (c1=='&' && c2!='&')			  { n &= value(++q, pBits); goto op; }
		if (c1=='|' && c2!='|')			  { n |= value(++q, pBits); goto op; }
		if (c1=='a' && q.testWord("and")) { n &= value(q,   pBits); goto op; }
		if (c1=='o' && c2=='r')			  { n |= value(q+=2,pBits); goto op; }
		if (c1=='x' && q.testWord("xor")) { n ^= value(q,   pBits); goto op; }
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
			throw SyntaxError(*name=='.' ? "illegal label name (use option --dotnames)" : "illegal label name");
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
			if (q.testWord(".macro")) { asmMacro(q,".macro", name, '&'); return; }
			if (q.testWord( "macro")) { asmMacro(q, "macro", name, '&'); return; }
		}

		if (require_colon && !f) { q.p = p; return; }	// must be a [pseudo] instruction

		if (!current_segment_ptr)
		{
			if (lceq(name,"org"))
				throw FatalError("'org' in column 1: option '--reqcolon' may help");
			else
				throw SyntaxError("org not yet set (use instruction 'org' or directive '#code')");
		}
		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		n = static_cast<DataSegment*>(current_segment_ptr)->lpos;
		if (!is_reusable) reusable_label_basename = name;
	}

a:	Labels& labels = is_global ? global_labels() : local_labels();
	Label* l = labels.find(name);

	if (l)
	{
		if (pass==1)
		{
			if (is_redefinable != l->is_redefinable)
			{
				if (!l->is_defined)
					l->is_redefinable = is_redefinable;
				else
					throw SyntaxError(is_redefinable ? "normal label redefined as redefinable label"
													  : "redefinable label redefined as normal label");
			}

			if (l->is_defined && !is_redefinable)
				throw SyntaxError("label redefined (use 'defl' or '=' for redefinable labels)");
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
				if (strchr(names,name[0])) throw SyntaxError("'%s' is the name of a register",name);
			}
			else if (name[2]==0)	// strlen == 2
			{
				cstr names = target_z180 ? "bc de hl sp af" : "ix iy xh xl yh yl bc de hl sp af";
				if (find(names,name)) throw SyntaxError("'%s' is the name of a register",name);
			}
			else if (name[3]==0 && !target_z180)	// strlen == 3
			{
				cstr names = "ixh iyh ixl iyl";
				if (find(names,name)) throw SyntaxError("'%s' is the name of a register",name);
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
		if (lceq(w,"test"))		asmSegment(q,TEST);	else
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
		if (lceq(w,"!"))		asmShebang(q);		else throw FatalError("unknown assembler directive");
	}
	catch (FatalError& e) { throw e; }
	catch (AnyError& e)   { throw FatalError("%s",e.what()); }
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
	if (!name) throw SyntaxError("segment name expected");
	if (casefold) name = lowerstr(name);
	Label* l1 = global_labels().find(name);
	if (!l1) throw SyntaxError("label not found");

	if (!l1->segment || !l1->segment->isCode()) throw SyntaxError("code segment required");
	CodeSegment* s1 = dynamic_cast<CodeSegment*>(l1->segment); assert(s1);
	if (ne(s1->name,name)) throw SyntaxError("segment name expected");

	Value size = s1->size;
	bool multiple = q.testWord("to");

	if (multiple)	// compress range of segments
	{
		cstr name2 = q.nextWord();
		if (!name2) throw SyntaxError("segment name expected");
		if (casefold) name2 = lowerstr(name2);
		Label* l2 = global_labels().find(name2);
		if (!l2) throw SyntaxError("label not found");

		if (!l2->segment || !l2->segment->isCode()) throw SyntaxError("code segment required");
		CodeSegment* s2 = dynamic_cast<CodeSegment*>(l2->segment); assert(s2);
		if (ne(s2->name,name2)) throw SyntaxError("segment name expected");

		if (s1==s2) goto a; // first == end segment

		CodeSegments segments(this->segments);

		uint a; for (a=0; ne(segments[a]->name,name); a++) {}		//must exist
		uint e; for (e=0; ne(segments[e]->name,name2); e++) {}		//must exist
		if (e<a) throw SyntaxError("2nd segment before 1st segment");

		if (s1->compressed || s2->compressed)	// check for duplicate directive
		{
			if (s1->compressed==first_cseg && s2->compressed==last_cseg)
			{
				while (++a<e)
				{
					if (segments[a]->compressed != middle_cseg) break;
				}
			}
			if (a<e) throw SyntaxError("segments overlap with other compressed segments");
			else return;	// duplicate
		}
		else	// mark segments for compression
		{
			assert(segments[a]->ccore.count()==0);
			assert(segments[a]->ucore.count()==0);
			segments[a]->compressed = first_cseg;
			while (++a<e)
			{
				if (segments[a]->compressed) throw SyntaxError("segments overlap with other compressed segments");
				if (!segments[a]->relocatable) break;
				assert(segments[a]->ccore.count()==0);
				assert(segments[a]->ucore.count()==0);
				segments[a]->compressed = middle_cseg;
				size += segments[a]->size;
			}
			if (!segments[a]->relocatable) throw SyntaxError("segments 2++ must have no start address");
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
		if (s1->compressed) throw SyntaxError("segment is already part of other compressed segments");
		assert(s1->ccore.count()==0);
		assert(s1->ucore.count()==0);
		s1->compressed = single_cseg;
	}

	static const cstr ext[] = { "_size", "_csize", "_cgain", "_cdelta" };
	for (uint i=1-multiple; i<4; i++)
	{
		cstr n1 = catstr(name,ext[i]);
		Label* l = global_labels().find(n1); if (l&&l->is_defined) throw SyntaxError("label %s redefined",n1);
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

		Array<uint8> ucore(s1->getData(),uint32(s1->size));
		Value usize(s1->size);
		Array<uint8> ccore;

		CodeSegment* s2 = s1;
		while (!(s2->compressed & last_cseg_mask))
		{
			assert(i<segments.count());
			s2 = segments[i++];
			assert(s2->compressed);

			ucore.append(s2->getData(),uint32(s2->size));
			usize += s2->size;
		}

		bool multiple = s1 != s2;
		cstr name = multiple ? catstr(s1->name,"_to_",s2->name) : s1->name;

		if (usize.value > 0x10000 && usize.is_valid())
			throw FatalError("%s_size exceeds $10000 bytes (size=%u)",name,int32(usize));

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
		setLabelValue( global_labels().find(catstr(name,"_csize")), int32(ccore.count()), preliminary);
		setLabelValue( global_labels().find(catstr(name,"_cgain")), usize.value - int32(ccore.count()), preliminary);
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

	if (q.testChar('(')) throw FatalError("preprocessor functions are not supported: use macros.");

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
		throw FatalError("unknown instruction");
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
	if (!is_name(w)) throw SyntaxError("name expected");
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
				if (strchr(names,w[0])) throw SyntaxError("'%s' is the name of a register",w);
			}
			else if (w[2]==0)	// strlen == 2
			{
				cstr names = target_z180 ? "bc de hl sp af" : "ix iy xh xl yh yl bc de hl sp af";
				if (find(names,w)) throw SyntaxError("'%s' is the name of a register",w);
			}
			else if (w[3]==0 && !target_z180)	// strlen == 3			2016-10-01
			{
				cstr names = "ixh iyh ixl iyl";
				if (find(names,w)) throw SyntaxError("'%s' is the name of a register",w);
			}
		}

		l = new Label(w, current_segment_ptr, current_sourceline_index, n, yes, yes, no);
		global_labels().add(l);
	}

	q.label = l;				// this source line defines a label
}

uint Z80Assembler::skipMacroBlock (uint idx, cstr macro, cstr endm) throws
{
	/*	must be called with line of 'macro', 'rept' or 'dup'
		returns line with 'endm' or 'edup' or throws

		.rept - .endm
		.dup - .edup
		.macro - .endm
		rept - endm
		dup - edup
		macro - endm

		may be nested
	*/

	// copy leading dot from 'macro' to 'endm':
	if ((*macro=='.') != (*endm=='.'))
	{
		if (*endm=='.') endm++;
		else endm = catstr(".",endm);
	}

	for (idx+=1; idx < source.count(); idx+=1)
	{
		SourceLine& s = source[idx];
		//if (s[0]=='#')
		//{
		//	current_sourceline_index = idx;
		//	throw FatalError("unexpected assembler directive in '%s' block", macro);
		//}

		s.rewind();
		if (!require_colon && uchar(*s) > ' ' && (*s != '.' || allow_dotnames))  // even 'ENDM' etc. is a label
		{
			s.test_char('.');		// skip dot
			s.nextWord();			// skip label
			s.testChar(':');
	L:		s.test_char(':');
		}

		cstr w = s.nextWord();
		if (s.testChar(':')) goto L;

		// test for expected block end marker:
		if (lceq(w,endm)) return idx;

		// test for unexpected block end marker:
		if (doteq(w,"endm") || doteq(w,"edup"))
		{
			current_sourceline_index = idx;
			throw FatalError("nesting error: expected '%s'", endm);
		}

		// test for nested block starter:
		if (doteq(w,"rept")) { idx = skipMacroBlock(idx, w, ".endm"); } else
		if (doteq(w,"dup"))  { idx = skipMacroBlock(idx, w, ".edup"); } else
		if (doteq(w,"macro")){ idx = skipMacroBlock(idx, w, ".endm"); }
	}

	throw FatalError("end of '%s' block (instruction '%s') not found", macro, endm);
}

void Z80Assembler::asmRept (SourceLine& q, cstr rept, cstr endm) throws
{
	/*  rept N
		;
		; some instructions
		;
		endm
	*/

	Value n;
	if (pass==1)
	{
		if (q.testEol()) { n=N1; setError("number of repetitions missing"); }
		else
		{
			if_pending = yes;		// => global labels can be used
			try { n = value(q); } catch (AnyError& e) { n=N1; setError(e); }
			if_pending = no;
			if (!n.is_valid())		   { n=N1; setError("count must evaluate in pass 1"); }
			else if (n.value > 0x8000) { n=N1; setError("number of repetitions too high"); }
			else if (n.value < 0)      { n=N1; setError("number of repetitions negative"); }
		}
	}
	else
	{
		q.skip_to_eol();			// just skip the rept macro
	}

	// skip over contained instructions:
	uint32 a = current_sourceline_index;
	uint32 e = current_sourceline_index = skipMacroBlock(a,rept,endm);

	if (pass > 1) return;

	if (source.count() + uint32(n)*(e-a-1) > 1000000)
		throw FatalError("total source exceeds 1,000,000 lines");

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

void Z80Assembler::asmMacro (SourceLine& q, cstr macro, cstr name, char tag) throws
{
	/*	NAME macro
		NAME macro ARG,ARG…
		;
		; some instructions
		;	&ARG may refer to ARG
		;	#ARG may refer to #ARG
		;
			endm
		;
		; invocation:
		;
			NAME ARG,…

		tag = potential tag character, e.g. '&'
		seen syntax:
		NAME macro ARG	; def
			NAME &ARG	; substitution in call
		NAME macro #ARG	; def
			NAME #ARG	; substitution in call
		.macro NAME ARG	; def
			NAME \ARG	; substitution in call

		the good thing is, they all _have_ a tag befor the argument reference…
	*/

	assert(doteq(macro,"macro"));
	name = lowerstr(name);

	if (pass>1)	// => skip the macro definition
	{
		q.skip_to_eol();
		current_sourceline_index = macros[name].endm;
		source[current_sourceline_index]->skip_to_eol();
		return;
	}

	if (macros.contains(name)) throw FatalError("macro redefined");

	// parse argument list:
	Array<cstr> args;
	if (!q.testEol())
	{
		if (strchr("!#$%&.:?@\\^_|~",*q)) tag = *q;	// test whether args in def specify some kind of tag
		do											// else use the supplied (if any)
		{
			if (tag) q.testChar(tag);
			cstr w = q.nextWord();
			if (!is_name(w)) throw SyntaxError("argument name expected");
			if (casefold) w = lowerstr(w);
			args.append(w);
		}
		while (q.testChar(','));
		q.expectEol();
	}

	// skip over contained instructions:
	uint32 a = current_sourceline_index;
	uint32 e = current_sourceline_index = skipMacroBlock(a,macro,".endm");

	macros.add(name,Macro(std::move(args),a,e,tag)); // note: args[] & name are unprotected cstr in tempmem!
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
				while (*q && *q!='>') { ++q; } if (*q==0) throw SyntaxError("closing '>' missing");
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
				if (n<2||w[n-1]!=c) throw SyntaxError("closing '%c' missing",c);
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
	if (rpl.count()<args.count()) throw SyntaxError("not enough arguments: required=%i",args.count());
	if (rpl.count()>args.count()) throw SyntaxError("too many arguments: required=%i",args.count());

	// get text of macro definition:
	uint32 i = m.mdef;
	uint32 e = m.endm;
	RCArray<SourceLine> zsource;
	while (++i < e)
	{
		// add line with text from macro but use line of invocation for source reference
		// => errors will be printed at the position of the macro call
		zsource.append(new SourceLine(q.sourcefile, q.sourcelinenumber, source[i]->text));
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
			if (a == ~0u)						// no exact match
			{
				// test whether the word starts with a macro argument:
				// used to compose label names, e.g. L_&Foo_&Bar => find argument Foo in Foo_
				// NOTE: if not found by the exact match then shorter names may hide longer names
				// e.g. macro &N, &NN --> L_&NNxx --> will never find &NN because argument &N already matched
				for (a=0; a<args.count(); a++)
				{
					if (startswith(w,args[a]))	// found argument at start of word
					{
						s.p -= strlen(w)-strlen(args[a]);
						break;
					}
				}
				if (a == args.count()) continue;	// argument name not found
			}

			// w is the name of argument #a
			// it was found starting at p+1 in s.text  (p points to the '&')

			j = p - s.text;						// index of '&'
			j += strlen(rpl[a]) -1;				// index of last char of rpl after replacement
			s.text = catstr(substr(s.text,p), rpl[a], s.p);
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
		if (w[0]!='"') throw SyntaxError("string with source character(s) expected");
		if (!q.testChar('=') && !q.testChar(',') && !q.testWord("to")) throw SyntaxError("keyword 'to' expected");
		n = value(q);
		if (n.is_valid() && (n.value < -0x80 || n.value > 0xff)) throw SyntaxError("destination char code out of range");
		if (!charset) charset = new CharMap();
		charset->addMappings(unquotedstr(w),uint(n)); // throws on illegal utf-8 chars
	}
	else if (lceq(w,"unmap") || lceq(w,"remove"))	// remove mapping
	{
		if (!charset) throw SyntaxError("no charset in place");
		w = q.nextWord();
		if (w[0]!='"') throw SyntaxError("string with source character(s) for removal expected");
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
		if (cs==CharMap::NONE) throw SyntaxError("map, unmap, none or charset name expected");
		delete charset;
		charset = new CharMap(cs);
	}
}

void Z80Assembler::asmAssert (SourceLine& q) throws
{
	Value n = value(q);

	//if (!v) throw fatal_error("the expression was not evaluatable in pass 1");
	if (n.is_valid() && !n) throw FatalError("assertion failed");
}

void Z80Assembler::init_c_compiler (cstr cc) throws
{
	// init c_compiler, c_tempdir and c_flags
	// cc: NULL, "vcc", "sdcc", "fullpath/vcc" or "fullpath/sdcc"

	if (!cc) // #CFLAGS without #CPATH => assume command line argument "-c sdcc"
	{
		cc = sdcc_compiler_path ? sdcc_compiler_path : find_executable("sdcc");
		if (!cc) throw FatalError("can't find c-compiler sdcc (use cmd line option -c or directive '#cpath')");
	}
	else if (eq(cc,"sdcc")) cc = sdcc_compiler_path ? sdcc_compiler_path : find_executable(cc);
	else if (eq(cc,"vcc")) cc = vcc_compiler_path ? vcc_compiler_path : find_executable(cc);

	cc = fullpath(cc);
	if (errno) throw FatalError("%s: %s", cc, strerror(errno));
	if (!is_file(cc)) throw FatalError("%s: not a regular file", cc);
	if (!is_executable(cc)) throw FatalError("%s: not executable", cc);

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

	if (cgi_mode) throw FatalError("#CPATH not allowed in CGI mode");
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
				if (c_qi >= 0) throw FatalError("$SOURCE redefined");
				c_qi = int(c_flags.count());
			}

			if (eq(s,"$DEST"))
			{
				if (c_zi >= 0) throw FatalError("$DEST redefined");
				c_zi = int(c_flags.count());
			}

			if (eq(s,"$CFLAGS"))
			{
				if (old_c_qi >= 0 && c_qi >= 0) throw FatalError("$SOURCE redefined");
				if (old_c_zi >= 0 && c_zi >= 0) throw FatalError("$DEST redefined");
				if (old_c_qi >= 0) c_qi = old_c_qi + int(c_flags.count());
				if (old_c_zi >= 0) c_zi = old_c_zi + int(c_flags.count());
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

			if (s[1]=='o') throw FatalError("option '-o' not allowed in CGI mode"); // set output file
			if (s[1]=='I') throw FatalError("option '-I' not allowed in CGI mode"); // set dir for include files
		}

		if (s[0]=='-' && s[1]=='I')	// -I/full/path/to/include/dir
		{							// -Ior/path/rel/to/source/dir	=> path in #cflags is relative to source file!
			cstr path = s+2;
			if (path[0]!='/') path = catstr(source_directory,path);
			path = fullpath(path); if (errno) throw FatalError(errno);
			if(lastchar(path)!='/') throw FatalError(ENOTDIR);
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
	if (*w && !global_labels().find(w)) throw SyntaxError("end of line or label name expected");

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

	if (cond[NELEM(cond)-1] != no_cond) throw FatalError("too many conditions nested");

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
		if (!f.is_valid()) throw FatalError("condition not evaluatable in pass1");
		if (pass==1) if_values.append(f.value);
		else if (if_values[if_values_idx++] != f.value) throw FatalError("condition changed in pass%i",pass);
	}

	memmove( cond+1, cond, sizeof(cond)-sizeof(*cond) );
	cond[0] = cond_if + !!f.value;
	cond_off = (cond_off<<1) + !f.value;
}

void Z80Assembler::asmElif (SourceLine& q) throws
{
	// #elif <condition>
	// condition must be evaluatable in pass 1

	switch (cond[0])			// state of innermost condition
	{
	default:			IERR();
	case no_cond:		throw SyntaxError("#elif without #if");
	case cond_else:		throw SyntaxError("#elif after #else");

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
			if (!f.is_valid()) throw FatalError("condition must be evaluatable in pass1");
			if (pass==1) if_values.append(f.value);
			else if (if_values[if_values_idx++] != f.value) throw FatalError("condition changed in pass%i",pass);
		}

		cond_off -= !!f.value;	// if f==1 then clear bit 0 => enable #elif clause
		cond[0]  += !!f.value;	// and switch state to cond_if_dis => disable further elif evaluation
		break;
	}
}

void Z80Assembler::asmElse (SourceLine&) throws
{
	// #else

	switch (cond[0])
	{
	default:			IERR();
	case no_cond:		throw SyntaxError("#else without #if");
	case cond_else:		throw SyntaxError("multiple #else clause");

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

	if (cond[0]==no_cond) throw SyntaxError("no #if pending");

	memmove(cond, cond+1, sizeof(cond)-sizeof(*cond));
	cond[NELEM(cond)-1] = no_cond;
	cond_off = cond_off>>1;
}

void Z80Assembler::asmTarget (SourceLine& q) throws
{
	if (pass > 1) { q.skip_to_eol(); return; }
	if (target != TARGET_UNSET) throw FatalError("#target redefined");
	assert(!current_segment_ptr);

	static HashMap<cstr,Target> targets;
	if (targets.count() == 0)
	{
		targets.add("rom",ROM);	// for eprom burner: hex files start addresses at 0
		targets.add("bin",BIN);	// for ram loaders:  hex files start addresses at .org
		targets.add("ram",BIN);	// 4.2.7
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
	if (target == TARGET_UNSET) throw SyntaxError("target name expected");
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
	if (is_stdlib && !is_library) throw SyntaxError("keyword 'library' expected");

	if (is_library)
	{
		cstr fqn;
		if (is_stdlib)
		{
			if (!stdlib_dir)		// try to guess missing libdir:
			{
				if (c_includes && endswith(c_includes,"/include/"))
				{
					cstr dir = catstr(leftstr(c_includes,int(strlen(c_includes))-9),"/lib/");
					if (is_dir(dir)) stdlib_dir = dir;
				}
			}
			if (!stdlib_dir)		// try to use hint:
			{
				if (is_sdcc && sdcc_library_path) stdlib_dir = sdcc_library_path;
				if (is_vcc && vcc_library_path)   stdlib_dir = vcc_library_path;
			}
			if (!stdlib_dir) throw SyntaxError("standard library path is not set (use command line option -L)");

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
			if (w[0]!='_' && !is_letter(w[0])) throw SyntaxError("label name expected");

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
		if (names.count()) throw FatalError("source file for label %s not found",names[0]);
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
				throw FatalError("c compiler not set (use cmd line option -c or directive '#cpath')");
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
	if (pipe(pipout)) throw FatalError(errno);

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

		typedef char **cpp;
		execve(c_compiler, cpp(c_flags.getData()), environ);	// exec cmd
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
			if (errno!=EINTR) throw FatalError("waitpid: %s",strerror(errno));
		}

		if (WIFEXITED(status))				// child process exited normally
		{
			if (WEXITSTATUS(status)!=0)		// child process returned error code
			{
				log("%s",bu);
				throw FatalError("\"%s %s\" returned exit code %i\n- - - - - -\n%s- - - - - -\n",
					filename_from_path(c_compiler), filename_from_path(fqn_q), int(WEXITSTATUS(status)), bu);
			}
			else if (verbose)
				log("%s",bu);
		}
		else if (WIFSIGNALED(status))		// child process terminated by signal
		{
			log("%s",bu);
			throw FatalError("\"%s %s\" terminated by signal %i",
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

	if (!current_segment_ptr) throw SyntaxError("org not yet set (use instruction 'org' or directive '#code')");

	q.is_data = yes;	// even if it isn't, but we don't know. else listfile() will bummer

	cstr fqn = get_filename(q);

	FD fd(fqn,'r');
	off_t sz = fd.file_size();			// file size
	if (sz>0x10000) throw FatalError("file is larger than $10000 bytes");	// max. possible size in any case

	std::unique_ptr<char[]> bu(new char[sz]);
	fd.read_bytes(bu.get(), uint32(sz));
	storeBlock(bu.get(),uint(sz));
}

void Z80Assembler::asmTzx (SourceLine& q) throws
{
	if (target!=TZX) throw FatalError("#target TZX required");
	if (q.peekChar() == 0) throw FatalError("block type expected");

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
		if (!v.is_valid()) throw SyntaxError("block type must be valid in pass 1");
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
			if (!exists_node(filename)) throw SyntaxError("file not found");
			if (!is_file((filename))) throw SyntaxError("not a regular file");

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
				if(seen & PAUSE) throw SyntaxError("multiple definitions for pause");
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
				if(!v.is_valid()) throw SyntaxError("number of channels must be valid in pass 1");
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
				if(!v.is_valid()) throw SyntaxError("sample-rate must be valid in pass 1");
				segment->setSampleRate(uint32(v));
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
				else throw SyntaxError("illegal format. known formats = [s1|u1|s2|u2|s2x|u2x]");
			}
			else if (q.testWord("header"))
			{
				if(seen & HEADER) throw SyntaxError("multiple definitions for HEADER");
				q.expect(('='));
				segment->setHeaderSize(value(q));
				seen |= HEADER;
			}
			else if (q.testWord("start"))
			{
				if(seen & START) throw SyntaxError("multiple definitions for START");
				q.expect(('='));
				segment->setFirstFrame(value(q));
				seen |= START;
			}
			else if (q.testWord("end"))
			{
				if(seen & END) throw SyntaxError("multiple definitions for END or COUNT");
				q.expect(('='));
				segment->setLastFrame(value(q));
				seen |= END;
			}
			else if (q.testWord("count"))
			{
				if(seen & END) throw SyntaxError("multiple definitions for END or COUNT");
				q.expect(('='));
				segment->setLastFrame(segment->first_frame + value(q));
				seen |= END;
			}
			else throw SyntaxError("unknown setting name");
		}

		if (segment->raw && (~seen & ALL_THREE))
			throw SyntaxError("raw audio: setting sample-rate, sample-format and channels required");

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
			if (*name==0) throw SyntaxError("name must not be empty");
			if (strlen(name)>32) throw SyntaxError("name too long. (max. ~30 char)");
			for (cptr p=name; *p; p++)
			{
				if (!isascii(*p)) throw SyntaxError("name must only contain ASCII characters");
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
			if (text[0]!='"' && text[0]!='\'') throw SyntaxError("quoted text expected");
			text = croppedstr(unquotedstr(text));
			if (*text==0) throw SyntaxError("text must not be empty");
			if (strlen(text)>255) throw SyntaxError("text too long. (max. 255, pls. ~30 char)");
			for (cptr p=text; *p; p++)
			{
				if (!isascii(*p)) throw SyntaxError("text must only contain ASCII characters");
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
				if (text.count()==8) throw SyntaxError("too many lines. (max. 8 lines)");
				cstr  s = q.nextWord();
				if (s[0]!='"' && s[0]!='\'') throw SyntaxError("quoted text expected");
				s = unquotedstr(s);
				if (strlen(s)>31) throw SyntaxError("text too long. (max. ~30 char)");
				for (cptr p=s; *p; p++)
				{
					if (!isascii(*p)) throw SyntaxError("text must only contain ASCII characters");
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

	throw SyntaxError("invalid or unsupported block type");
}

void Z80Assembler::asmSegment (SourceLine& q, SegmentType segment_type) throws
{
	assert(isData(segment_type)||isCode(segment_type)||isTest(segment_type));

	// #DATA name, [start], [size]
	// #CODE name, [start], [size]						most targets
	// #CODE name, [start], [size], [[FLAG=]value]		z80
	// #CODE name, [start], [size], [[FLAG=]value|NONE]	tap
	// #CODE name, [start], [size], <flags>				tzx
	// #TZX TURBO, name, start, size, <flags>
	// #TZX STANDARD, name, start, size, <flags>
	// #TZX PURE-DATA, name, start, size, <flags>
	// #TZX GENERALIZED, name, start, size, <flags>
	// #TEST name, start, [size]

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
	if (target==TARGET_UNSET) throw FatalError("#target declaration missing");

	cstr name = q.nextWord();
	if (!is_name(name)) throw FatalError("segment name expected");
	if (casefold) name = lowerstr(name);

	DataSegment* segment = segments.find(name);
	if (segment)		// segment definition in pass 2++ or re-enter segment in any pass
	{
		assert(eq(segment->name,name));

		if (pass==1)	// re-enter segment
		{
			if (q.testComma())
				throw FatalError("segment %s redefined", name);

			if (segment->type != segment_type)
			{
				if (segment_type == CODE && isCode(segment->type)) {}	// OK: #tzx code block re-opened with #code
				else throw FatalError("segment type mismatch");
			}
		}
	}

	else // if (!segment)	// create segment in pass 1
	{
		assert(pass==1);

		if (isData(segment_type))
			segment = new DataSegment(name);
		else
		{
			assert(isCode(segment_type)||isTest(segment_type));
			uint8 fillbyte = target==ROM || target==TARGET_UNSET ? 0xFF : 0x00;
			if (isTest(segment_type)) segment = new TestSegment(name,fillbyte);
			else segment = new CodeSegment(name,segment_type,fillbyte);
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
	q.segment = current_segment_ptr;		// Für Temp Label Resolver
	q.byteptr = uint(currentPosition());	// Für Temp Label Resolver & Logfile
	assert(q.bytecount==0);

	if (q.testComma())	// address
	{
		segment->relocatable = q.testChar('*');
		if (!segment->relocatable) segment->setAddress(value(q));		// throws
	}
	if (segment->relocatable && segment->isTest()) setError("segment start address required");

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
	if (segment->isTest()) return;
	if (!q.testComma()) return;

	// more values follow:

	CodeSegment* cseg = dynamic_cast<CodeSegment*>(segment);
	assert(cseg);

	// flag without keyword "flag" must be first and only value:
	// flag without keyword should be deprecated!
	cptr p = q.p;
	if (!(q.testWord("flag") && q.testChar('=')))  // test both => label named 'flag' can be used
	{
		q.p = p;
		if (target!=Z80 && target!=TAP && target!=TZX) throw SyntaxError("target Z80, TAP or TZX required");

		if (target!=Z80 && q.testWord("none")) cseg->setNoFlag();
		else cseg->setFlag(value(q));
		return;
	}
	q.p = p;

	// now only key=value pairs expected:

	// all:			SPACE=value
	// Z80:			FLAG=value
	// TAP:			FLAG=(value|NONE)
	// TZX:
	// standard:    FLAG=(value|NONE), [CHECKSUM=NONE|ACE], [PAUSE=value]
	// code, turbo:	FLAG=(value|NONE), [CHECKSUM=NONE|ACE], [PAUSE=value], [LASTBITS=value], [PILOT=count]
	// pure-data:	FLAG=(value|NONE), [CHECKSUM=NONE|ACE], [PAUSE=value], [LASTBITS=value], [PILOT=NONE]
	// generalized:	FLAG=(value|NONE), [CHECKSUM=NONE|ACE], [PAUSE=value], [LASTBITS=value], [PILOT=(NONE|count)]

	uint seen = 0;
	constexpr uint FLAG=1, CHECKSUM=2, PAUSE=4, PILOT=8, LASTBITS=16, SPACE=32;

	do
	{
		if (q.testWord("flag"))
		{
			if (seen & FLAG) throw SyntaxError("multiple definitions for flag");
			if (target!=Z80 && target!=TAP && target!=TZX) throw SyntaxError("target Z80, TAP or TZX required");

			// if FLAG=NONE then no flagbyte is stored in the tape block
			// and the checksum does not incorporate the flagbyte.
			// => this is suitable for Jupiter Ace tape files.

			q.expect(('='));
			if (target!=Z80 && q.testWord("none")) cseg->setNoFlag();
			else cseg->setFlag(value(q));
			seen |= FLAG;
		}
		else if (q.testWord("space"))
		{
			if (seen & SPACE) throw SyntaxError("multiple definitions for space");
			q.expect(('='));
			cseg->setFillByte(value(q));
			seen |= SPACE;
		}
		else if (q.testWord("checksum"))
		{
			if (seen & CHECKSUM) throw SyntaxError("multiple definitions for checksum");
			if (target != TZX) throw SyntaxError("target TZX required");

			q.expect(('='));
			if (q.testWord("none")) cseg->setNoChecksum();
			else if (q.testWord("ace")) { cseg->checksum_ace = true; cseg->has_flag = true; }
			else throw SyntaxError("keyword 'none' or 'ace' expected");
			seen |= CHECKSUM;
		}
		else if (q.testWord("pause"))
		{
			if (seen & PAUSE) throw SyntaxError("multiple definitions for pause");
			if (target != TZX) throw SyntaxError("target TZX required");

			q.expect(('='));
			cseg->setPause(q.testWord("none") ? Value(0) : value(q));
			seen |= PAUSE;
		}
		else if (q.testWord("pilot"))
		{
			if (seen & PILOT) throw SyntaxError("multiple definitions for pilot count");
			if (target != TZX) throw SyntaxError("target TZX required");

			q.expect(('='));
			if (q.testWord("none"))
			{
				if (segment_type!=CODE && segment_type!=TZX_PURE_DATA && segment_type!=TZX_GENERALIZED)
					throw SyntaxError("TZX pure data or generalized block required");

				cseg->no_pilot = true;
				seen |= PILOT;
			}
			else
			{
				if (segment_type!=CODE && segment_type!=TZX_TURBO && segment_type!=TZX_GENERALIZED)
					throw SyntaxError("TZX turbo or generalized block required");

				cseg->setNumPilotPulses(value(q));
				seen |= PILOT;
			}
		}
		else if (q.testWord("lastbits"))
		{
			if (seen & LASTBITS) throw SyntaxError("multiple definitions for lastbits");
			if (target != TZX) throw SyntaxError("target TZX required");
			if (segment_type == TZX_STANDARD)
				throw SyntaxError("TZX pure data, turbo or generalized block required");

			q.expect(('='));
			cseg->setLastBits(value(q));
			seen |= LASTBITS;
		}
		else throw SyntaxError("key expected");
	}
	while (q.testComma());

	if (target==TZX && (~seen & FLAG)) throw SyntaxError("definition for 'flag' missing");
	if (target==Z80) return;	// Z80: no required values
	if (target==TAP) return;	// TAP: no required values
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
		if (target!=TARGET_UNSET) throw FatalError("#code segment definition expected after #target");

		s = new CodeSegment(name,CODE,0xff);
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
	s->relocatable = no;
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

	if (local_labels_index==0) throw SyntaxError("#endlocal without #local");

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
		if (!type.is_valid()) throw SyntaxError("hardware type must evaluate in pass 1");
		if (uint(type) > 0x20) throw SyntaxError("hardware type out of range [0..16]");

		q.expectComma();
		Value id = value(q);
		if (!id.is_valid()) throw SyntaxError("hardware ID must evaluate in pass 1");
		if (uint(id) > 0x40) throw SyntaxError("hardware type out of range [0..45]");

		q.expectComma();
		Value support = value(q);
		if (!support.is_valid()) throw SyntaxError("hardware support flag must evaluate in pass 1");
		if (uint(support) > 3) throw SyntaxError("hardware support flag out of range [0..3]");

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
		if (!id.is_valid()) throw SyntaxError("archive info: ID must evaluate in pass 1");
		if (uint(id) > 0x10 && id.value != 0xff) throw SyntaxError("archive info: ID out of range [0..0F]");

		q.expectComma();
		w = q.nextWord();
		if (w[0]!='"' && w[0]!='\'') throw SyntaxError("archive info: text must be quoted");
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
		cstr name = q.nextWord();
		if(!is_name(name)) throw SyntaxError("name expected");
		asmMacro(q,w,name,'\\');
		return;
	}
	if (lceq(w,".area"))		// .area NAME  or  .area NAME (ABS)    => (ABS) is ignored
	{
		// select segment for following code

		w = q.nextWord();	// name
		if (!is_letter(*w) && *w!='_'  && !(allow_dotnames&&*w=='.')) throw FatalError("segment name expected");
		if (casefold) w=lowerstr(w);
		Segment* segment = segments.find(w);
		if (!segment) throw FatalError(current_segment_ptr?"segment not found":"no #code or #data segment defined");

		current_segment_ptr = segment;
		q.segment = current_segment_ptr;
		q.byteptr = uint(currentPosition());
		assert(q.bytecount==0);

		if (q.testChar('('))
		{
			if (!q.testWord("ABS")) throw SyntaxError("'ABS' expected");
			q.expect(')');
		}
		return;
	}
	if (lceq(w,".optsdcc"))		// .optsdcc -mz80
	{
		if (!q.testChar('-') )		 throw SyntaxError("-mz80 expected");
		if (ne(q.nextWord(),"mz80")) throw SyntaxError("-mz80 expected");
		return;
	}
	if (lceq(w,".phase"))		// M80: set logical code position
	{
		DataSegment* s = dynamic_cast<DataSegment*>(current_segment_ptr);
		if (s) { s->setOrigin(value(q)); return; }
		else throw SyntaxError("#data or #code segment required");
	}
	if (lceq(w,".dephase"))		// M80: restore logical code position to real address
	{
		DataSegment* s = dynamic_cast<DataSegment*>(current_segment_ptr);
		if (s) { s->setOrigin(s->physicalAddress()); return; }
		else throw SyntaxError("#data or #code segment required");
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
		throw SyntaxError("'.endme' missing");
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
		throw SyntaxError("'.endro' missing");
	}
	if (lceq(w,".endme"))	throw SyntaxError("'.endme' without '.memorymap'");
	if (lceq(w,".endro"))	throw SyntaxError("'.endro' without '.rombankmap'");
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
	if (doteq(w,"rept"))	return asmRept(q, w, ".endm");
	if (doteq(w,"dup"))		return asmRept(q, w, ".edup");	// dzx7_lom "Life on Mars" by zxintrospec
	if (doteq(w,"if"))		return asmIf(q);
	if (doteq(w,"elif"))	return asmElif(q);
	if (doteq(w,"else"))	return asmElse(q);
	if (doteq(w,"endif"))	return asmEndif(q);
	if (lceq(w,".local"))	return asmLocal(q);
	if (lceq(w,".endlocal"))return asmEndLocal(q);
	if (lceq(w,".assert"))	return asmAssert(q);
	if (lceq (w,"aseg"))	goto warn;
	if (doteq(w,"list"))	goto ignore;
	if (doteq(w,"end"))		return asmEnd(q);
	if (doteq(w,"endm"))	throw SyntaxError("no REPT or macro definition pending");
	if (doteq(w,"edup"))	throw SyntaxError("no DUP pending");
	if (lceq(w,".z80"))
	{
		// MACRO80: selects target cpu and Z80 syntax
		// zasm: can't easily disable 8080 syntax, but this must have been actively enabled, so let it go.

		if (cpu == CpuZ80) return;
		if (cpu != CpuDefault)   throw FatalError("can't redefine target cpu: already set");
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		cpu = CpuZ80;
		global_labels().add(new Label("_z80_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		checkCpuOptions();
		return;
	}
	if (lceq(w,".z180"))
	{
		if (cpu == CpuZ180) return;
		if (cpu != CpuDefault)   throw FatalError("can't redefine target cpu: already set");
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		cpu = CpuZ180;
		global_labels().add(new Label("_z180_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		checkCpuOptions();
		return;
	}
	if (lceq(w,".8080"))
	{
		// MACRO80: selects target cpu and 8080 syntax

		if (cpu == Cpu8080 && syntax_8080) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		if (cpu == CpuDefault)
		{
			cpu = Cpu8080;
			global_labels().add(new Label("_8080_",nullptr,current_sourceline_index,1,valid,yes,yes,no));
		}
		else if (cpu != Cpu8080) throw FatalError("can't redefine target cpu: already set");

		syntax_8080 = yes;
		checkCpuOptions();
		return;
	}
	if (lceq(w,".asm8080"))
	{
		// select 8080 assembler syntax
		// this will also change the default cpu.

		if (syntax_8080) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		syntax_8080 = yes;
		checkCpuOptions();
		return;
	}
	if (lceq(w,".ixcbr2"))
	{
		if (ixcbr2_enabled) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		ixcbr2_enabled = yes;
		global_labels().add(new Label("_ixcbr2_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		checkCpuOptions();
		return;
	}
	if (lceq(w,".ixcbxh"))
	{
		if (ixcbxh_enabled) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		ixcbxh_enabled = yes;
		global_labels().add(new Label("_ixcbxh_",  nullptr,current_sourceline_index,1,valid,yes,yes,no));
		checkCpuOptions();
		return;
	}
	if (lceq(w,".dotnames"))
	{
		if (allow_dotnames) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		// if .dotnames is set too late then there may be already errors

		allow_dotnames = yes;
		return;
	}
	if (lceq(w,".reqcolon"))	// wenn das zu spät steht, kann es schon Fehler gegeben haben
	{
		if (require_colon) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		// if .reqcolon is set too late then there may be already errors

		require_colon = yes;
		return;
	}
	if (lceq(w,".casefold"))	// wenn das nach Label-Definitionen steht, kann es zu spät sein
	{
		if (casefold) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		// if .casefold is set after some first label definitions then these may be not found later

		casefold = yes;
		return;
	}
	if (lceq(w,".flatops"))
	{
		if (flat_operators) return;
		if (current_segment_ptr) throw FatalError("this statement must occur before ORG, #CODE or #DATA");

		// if .flatops is set after some first equations have been evaluated, then these may differ in pass 2++

		flat_operators = yes;
		return;
	}
	if (lceq(w,"*"))
	{
		if (q.testWord("list")) goto ignore;					// "*LIST ON"  or  "*LIST OFF"
		if (q.testWord("include")) { asmInclude(q); return; }	// CAMEL80: fname follows without '"'
	}

// throw error "instruction expected":

	if (!is_letter(*w) && *w!='_' && *w!='.') throw SyntaxError("instruction expected");	// no identifier

	if (q.testDotWord("equ") || q.test_char(':') || q.test_char('=') || q.testWord("defl"))
	{
		if (q[0]<=' ' && !require_colon) throw SyntaxError("indented label definition (use option --reqcolon)");
		if (*w=='.' && !allow_dotnames) throw SyntaxError("label starts with a dot (use option --dotnames)");
		throw SyntaxError("label not recognized (why?)");
	}

	if (!current_segment_ptr) throw SyntaxError("org not yet set (use instruction 'org' or directive '#code')");
	throw SyntaxError("unknown instruction");

// print warning & ignore:
ignore:	if (pass>1 || verbose<2) return q.skip_to_eol();
		if (0)
warn:	if (pass>1 || verbose<1) return q.skip_to_eol();

		while (!q.testEol()) q.nextWord();	// skip to end of line but not behind a comment!
		cstr linenumber = tostr(q.sourcelinenumber+1);
		log("%s: %s\n", linenumber, q.text);
		log("%s%s^ warning: instruction '%s' ignored\n", spacestr(int(strlen(linenumber))+2), q.whitestr(), w);
}

void Z80Assembler::asmRawDataInstr (SourceLine& q, cstr w) throws
{
	// assemble segment which must only contain raw bytes
	// e.g. some TZX blocks
	// segment must exist and must be a special raw data segment TODO
	// text is always stored in ASCII (no charset translation)

	// clear charset translation and prepare for return or exceptions:
	struct Fin { CharMap* &p,*v; Fin(CharMap*& p):p(p),v(p){p=nullptr;} ~Fin(){p=v;} } fin(charset);

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
			uint n = uint(strlen(w));

			if (w[0]=='"' || w[0]=='\'')	// Text string:
			{
				if (n<3 || w[n-1]!=w[0]) throw SyntaxError("closing quotes expected");
				w = unquotedstr(w);
				if (*w==0) throw SyntaxError("closing quotes expected");	// broken '\' etc.

				cptr depp = w;
				charcode_from_utf8(depp);	// skip over 1 char

				if (*depp==0) goto sv;		// single char => numeric expression

				// multi-char string:
				while(*w) store(charcode_from_utf8(w));
			}

			else if (n>3 && w[0]=='$')		// Stuffed Hex?
			{								// stored in order of occurance: in $ABCD byte $AB is stored first!
				w += 1; n -= 1;
	sh:			if (n&1) throw SyntaxError("even number of hex characters expected");
				storeHexbytes(w,n/2);
			}
			else if (n>4 && is_dec_digit(w[0]) && tolower(w[n-1])=='h')
			{
				w = leftstr(w,int(n)-1); n -= 1;
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
		if (w[0]!='"' && w[0]!='\'') throw SyntaxError("quoted string expected");

		int n = int(strlen(w));
		if (n<3 || w[n-1]!=w[0]) throw SyntaxError("closing quotes expected");
		w = unquotedstr(w);
		if (*w==0) throw SyntaxError("closing quotes expected");	// broken '\' etc.

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
		// org <value>			 ; add space up to address
		// org <value>, fillbyte ; add space up to address
		q.is_data = yes;
		{
			Value n = value(q);
			assert(dynamic_cast<DataSegment*>(current_segment_ptr));
			if (q.testComma()) static_cast<DataSegment*>(current_segment_ptr)->storeSpaceUpToAddress(n,value(q).value);
			else static_cast<DataSegment*>(current_segment_ptr)->storeSpaceUpToAddress(n);
		}
		return;

	case 'data':
		if (current_segment_ptr->isData()) goto ds;
		else throw SyntaxError("only allowed in data segments (use defs)");

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
			if (q.testComma()) static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n,value(q).value);
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
		do { int32 n = value(q).value; store(n,n>>8,n>>16,n>>24); } while (q.testComma());
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
			if (w[0]==0) throw SyntaxError("value expected");

			// Text string:
			if (w[0]=='"' || w[0]=='\'')
			{
				n = uint(strlen(w));
				if (n<3 || w[n-1]!=w[0]) throw SyntaxError("closing quotes expected");
				w = unquotedstr(w);
				if (*w==0) throw SyntaxError("closing quotes expected");	// broken '\' etc.

				depp = w;
				charcode_from_utf8(depp);	// skip over 1 char

				if (*depp==0)				// single char => numeric expression
				{
					q -= n;
					storeByte(value(q));
				}
				else						// multi-char string
				{
cb:					while(*w) store(charcode_from_utf8(w));

					// test for operation on the final char:
					assert(dynamic_cast<CodeSegment*>(current_segment_ptr));
					CodeSegment* s = static_cast<CodeSegment*>(current_segment_ptr);
					if (q.testChar ('+'))	{ storeByte(Value(s->popLastByte()) + value(q)); } else
					if (q.test_char('-'))	{ storeByte(Value(s->popLastByte()) - value(q)); } else
					if (q.test_char('|'))	{ storeByte(Value(s->popLastByte()) | value(q)); } else
					if (q.test_char('&'))	{ storeByte(Value(s->popLastByte()) & value(q)); } else
					if (q.test_char('^'))	{ storeByte(Value(s->popLastByte()) ^ value(q)); }
				}
				if (q.testComma()) goto dm; else return;
			}

			// Stuffed Hex:
			// bytes are stored in order of occurance: in $ABCD byte $AB is stored first!
			n = uint(strlen(w));
			if (n>3 && w[0]=='$')
			{
sx:				w = midstr(w,1); n-=1;
sh:				if (n&1) throw SyntaxError("even number of hex characters expected");
				storeHexbytes(w,n/2);
				if (q.testComma()) goto dm; else return;
			}

			if (n>4 && is_dec_digit(w[0]) && tolower(w[n-1])=='h')
			{
				w = leftstr(w,int(n)-1); n-=1;
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
		q -= off_t(strlen(w));	// put back opcode
		storeByte(value(q));
		if (q.testComma()) goto dm; else return;

	case '.tzx':
		if (target!=TZX) throw SyntaxError("#target TZX required");
		if (!current_segment_ptr->isCode()) throw SyntaxError("code segment required");
		assert(dynamic_cast<CodeSegment*>(current_segment_ptr) != nullptr);
		if (currentPosition().value != 0) throw SyntaxError(".tzx pseudo instructions must appear before any code");

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

		throw SyntaxError("unknown .tzx instruction");

	default:
		return asmNoSegmentInstr(q,w);
	}

longer:
	// instructions which require a valid segment:
	// names must be longer than 4 characters:

	if (lceq(w,".test"))	// Test Segment: setup test
	{
		TestSegment* segment = dynamic_cast<TestSegment*>(current_segment_ptr);
		if (segment == nullptr) throw SyntaxError("test segment required");
		//if (currentPosition() != 0) throw SyntaxError(".test pseudo instructions must appear before the test code");

		q.expect('-');

		if (q.testWord("clock"))	// .test-clock value [k|M]
		{
			Value freq = value(q);
			int32 z = freq.value; if(z<0) throw SyntaxError("negative clock not supported. try again yesterday.");
			if (q.testWord("k") || q.testWord("kHz"))      z = z > 0x7fffffff/1000     ? 0x7fffffff : z * 1000;
			else if (q.testWord("M") || q.testWord("MHz")) z = z > 0x7fffffff/1000000  ? 0x7fffffff : z * 1000000;
			else q.testWord("Hz");
			freq.value = z;
			segment->setCpuClock(freq);
			return;
		}
		else if (q.testWord("int"))	// .test-int value
		{
			Value v = value(q);			// frequency or cc
			bool hz = q.testWord("Hz") || (!q.testWord("cc") && v.value <= 1000); // Hz or cc ?
			if (hz) segment->setIntPerSec(v); else segment->setCcPerInt(v);
			if (q.testComma()) { segment->setIntDuration(value(q)); q.testWord("cc"); }
			return;
		}
		else if (q.testWord("intack"))	// .test-intack value
		{
			Value n = value(q);
			segment->setIntAckByte(n);
			return;
		}
		else if (q.testWord("timeout"))	// .test-timeout value [ms|s|m]
		{
			Value timeout = value(q);
			int32 z = timeout.value; if (z<0) z = 0;
			if (q.testWord("s"))      z = z > 0x7fffffff/1000  ? 0x7fffffff : z * 1000;
			else if (q.testWord("m")) z = z > 0x7fffffff/60000 ? 0x7fffffff : z * 60000;
			else q.testWord("ms");
			timeout.value = z;
			segment->setTimeoutMsec(timeout);
			return;
		}
		else if (q.testWord("in"))		// .test-in addr = xxxxxxx
		{
			Value addr = value(q);
			while(q.testComma())
			{
				segment->setInputData(addr,parseIoSequence(q));
			}
			return;
		}
		else if (q.testWord("out"))		// .test-out addr = xxxxxxx
		{
			Value addr = value(q);
			while(q.testComma())
			{
				segment->setOutputData(addr,parseIoSequence(q));
			}
			return;
		}
		else if (q.testWord("infile"))	// .test-infile addr = "filename"
		{
			Value addr = value(q);
			q.expectComma();
			cstr fqn = get_filename(q);
			segment->setInputFile(addr,fqn,IoInFile);
			return;
		}
		else if (q.testWord("outfile"))	// .test-outfile addr = "filename" [ , append ] [ , compare ]
		{
			Value addr = value(q);
			q.expectComma();
			cstr fqn = get_filename(q);
			auto mode = IoOutFile;
			if (q.testComma())
			{
				if (q.testWord("append")) mode = IoAppendFile;
				else if (q.testWord("compare")) mode = IoCompareFile;
				else throw SyntaxError("'append' or 'compare' expected");
			}
			segment->setOutputFile(addr,fqn,mode);
			return;
		}
		else if (q.testWord("console"))	// .test-console addr
		{
			Value addr = value(q);
			segment->setConsole(addr);
			return;
		}
		else if (q.testWord("blockdev")) // .test-blockdev addr, "filename", blocksize
		{
			Value addr = value(q);
			q.expectComma();
			cstr fqn = get_filename(q);
			q.expectComma();
			Value blksz = value(q);
			segment->setBlockDevice(addr,fqn,blksz);
			return;
		}
	}

	if (lceq(w,".expect"))	// Test Segment: set expected values
	{
		TestSegment* segment = dynamic_cast<TestSegment*>(current_segment_ptr);
		if (segment == nullptr) throw SyntaxError("test segment required");
		if (currentPosition().value == 0) throw SyntaxError(".expect pseudo instructions must appear after the test code");

		if (q.testWord("cc"))	// cycle counter: cc [=,<=,>=] nnnnn
		{
			q.skip_spaces();
			bool lt = q.testChar('<');
			bool gt = !lt && q.testChar('>');
			bool eq = q.testChar('=');
			if (!(lt||gt||eq)) q.expect('=');	// throw

			Value cc = value(q);
			if (lt)
			{
				if (!eq) cc.value -= 1;
				segment->setExpectedCcMax(&q,cc);
			}
			else if (gt)
			{
				if (!eq) cc.value += 1;
				segment->setExpectedCcMin(&q,cc);
			}
			else
			{
				segment->setExpectedCc(&q,cc);
			}
		}
		else // expect register = value
		{
			cstr reg = q.nextWord();
			if (*q.p == '\'') { reg = catstr(reg,"'"); q.p++; }
			if (!Z80Registers::isaRegisterName(reg,yes)) throw SyntaxError("register name expected");
			q.expect('=');
			Value v = value(q);
			segment->setExpectedRegisterValue(&q,reg,v);
		}
		return;
	}

	if (doteq(w,"align"))			// align <value> [,<filler>]
	{								// note: current address is evaluated as uint
		q.is_data = yes;
		Value n = value(q);
		if (n.is_valid() && n.value < 1)	  throw SyntaxError("alignment value must be ≥ 1");
		if (n.is_valid() && n.value > 0x4000) throw SyntaxError("alignment value must be ≤ $4000");

		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		Value a = static_cast<DataSegment*>(current_segment_ptr)->lpos;
		a.value &= 0xffff;
		//if(a.is_valid() && a<0 && n.is_valid() && (1<<(msbit(n)))!=n)
		//	throw syntax_error("alignment value must be 2^N if $ < 0");

		n = n-N1 - (a+n-N1) % n;

		assert(dynamic_cast<DataSegment*>(current_segment_ptr));
		if (q.testComma()) static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n,value(q).value);
		else static_cast<DataSegment*>(current_segment_ptr)->storeSpace(n);
		return;
	}

	if (lceq(w,".asciz"))			// store 0-terminated string:
	{
		if (charset && charset->get(' ',' ')==0) // ZX80/81: the only conversion i know where 0x00 is a printable char
			throw SyntaxError("this won't work because in the target charset 0x00 is a printable char");

		q.is_data = yes;
		w = q.nextWord();
		if (w[0]!='"' && w[0]!='\'') throw SyntaxError("quoted string expected");

		int n = int(strlen(w));
		if (n<3 || w[n-1]!=w[0]) throw SyntaxError("closing quotes expected");
		w = unquotedstr(w);
		if (*w==0) throw SyntaxError("closing quotes expected");	// broken '\' etc.

		while (*w) store(charcode_from_utf8(w));
		store(0);
		return;
	}

	if (lceq(w,".globl"))			// declare global label for linker: mark label for #include library "libdir"
	{								// das Label wird in mehrere Labels[] eingehängt!
		w = q.nextWord();
		if (!is_letter(*w) && *w!='_') throw SyntaxError("label name expected");

		if (local_labels_index)		// local context?
		{
			Label* g = global_labels().find(w);
			Label* l = local_labels().find(w);
			if (l && !l->is_global) throw SyntaxError("label already defined local");
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

IoSequence Z80Assembler::parseIoSequence (SourceLine& q) throws
{
	// "...", value, ...
	// { values } * reps
	// { values } *
	// *
	// if the source line contains multiple blocks then only the next block is parsed and returned.
	// --> the caller must check for ','

	if (q.testChar('*')) { q.expectEol(); return IoSequence(nullptr,0,0); }	// any output

	bool block = q.testChar('{');

	Array<uint8> data;
	do
	{
		parseBytes(q,data);
	}
	while(q.testCommaNoGKauf());

	if (block)
	{
		q.expect('}');
		q.expect('*');
		if (q.testEol()) return IoSequence(&data[0], data.count(), 0); // unlimited repetition of input block

		Value reps = value(q);
		if (reps.is_invalid()) throw SyntaxError("repetitions must be valid in pass 1"); // TODO: support validity
		if (reps.value < 0) throw SyntaxError("repetitions < 0");
		return IoSequence(&data[0], data.count(), uint(reps.value));
	}

	return IoSequence(&data[0], data.count(), 1);
}

static uint8 validatedByte (cValue& byte)
{
	if (byte.value >= -0x80 && byte.value <= 0xFF) return uint8(byte);
	if (byte.is_invalid()) return 0;
	throw SyntaxError("byte value out of range");
}

void Z80Assembler::parseBytes (SourceLine& q, Array<uint8>& dest) throws
{
	// store bytes:
	// 'xy' and "xy" are both text strings
	// literal, label, "text", 'c' Char, $abcdef stuffed hex, usw.
	// "…", "…"+n, '…', '…'+n, 0xABCDEF…, __date__, __time__, __file__, …
	// bytes are stuffed in order of occurance: in $ABCD byte $AB is stored first!

	q.is_data = yes;

	cstr w = q.nextWord();
	size_t n = strlen(w);
	if (n == 0) throw SyntaxError("value expected");

	// text string:
	if (w[0]=='"' || w[0]=='\'')
	{
		if (n<3 || w[n-1] != w[0]) throw SyntaxError("closing quotes expected");
		w = substr(w+1, w+n-1);

cb:		while (*w) dest.append(charcode_from_utf8(w));

		// test for operation on the final char:
		if (q.testChar ('+'))	{ dest.append(validatedByte(Value(dest.pop()) + value(q))); } else
		if (q.test_char('-'))	{ dest.append(validatedByte(Value(dest.pop()) - value(q))); } else
		if (q.test_char('|'))	{ dest.append(validatedByte(Value(dest.pop()) | value(q))); } else
		if (q.test_char('&'))	{ dest.append(validatedByte(Value(dest.pop()) & value(q))); } else
		if (q.test_char('^'))	{ dest.append(validatedByte(Value(dest.pop()) ^ value(q))); }
		return;
	}

	// Stuffed Hex:
	if (n>4 && is_dec_digit(w[0]) && tolower(w[n-1])=='h')
	{
		n -= 1;
		if (n&1 && w[0]=='0') goto sx; else goto sh;
	}
	if (n>3 && w[0]=='$')
	{
sx:		w += 1; n -= 1;
sh:		if (n&1) throw SyntaxError("even number of hex characters expected");
		n = n/2;

		while (n--)
		{
			char c = *w++;
			if (!is_hex_digit(c)) throw SyntaxError("only hex characters allowed: '%c'",c);
			char d = *w++;
			if (!is_hex_digit(d)) throw SyntaxError("only hex characters allowed: '%c'",d);

			dest.append(uint8((hex_digit_value(c)<<4) + hex_digit_value(d)));
		}
		return;
	}

	// pre-defined special words:
	if (w[0] == '_')
	{
		if (eq(w,"__date__")) { w = datestr(timestamp); goto cb; }
		if (eq(w,"__time__")) { w = timestr(timestamp); goto cb; }
		if (eq(w,"__file__")) { w = q.sourcefile; goto cb; }
		if (eq(w,"__line__")) { w = tostr(q.sourcelinenumber); goto cb; }
	}

	// anything else:
	q -= off_t(n);				// put back word
	dest.append(validatedByte(value(q)));
}






















