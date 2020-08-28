/*	Copyright  (c)	Günter Woigk 1994 - 2020
					mailto:kio@little-bat.de

	This file is free software

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

	2002-01-20	kio	port to unix started
	2002-01-28	kio	3.0.0 released
	2014-05-21	kio work on 4.0.0 started
*/

#include <stdlib.h>
#include <sys/stat.h>
#include <dirent.h>
#include <fcntl.h>
#include <unistd.h>
#include "unix/FD.h"
#include "unix/files.h"
#include "kio/kio.h"
#include "Z80Assembler.h"
#include "helpers.h"


//static const char appl_name[] = "zasm";
#define VERSION "4.3.3"

// Help text:
// optimized for 80 characters / column
//
static const char version[] =
"–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n"
"  zasm - 8080/z80/z180 assembler (c) 1994 - 2020 Günter Woigk.\n"
"  version " VERSION ", %s, for " _PLATFORM ".\n"						// version, date, platform
"  homepage: https://k1.spdns.de/zasm/\n"
"  git repo: https://github.com/Megatokio/zasm\n\n";

static const char syntax[] =
"syntax:\n"
"  zasm [options] [-i] inputfile [[-l] listfile|dir] [[-o] outfile|dir]\n"
"  zasm [--version|--help]\n\n"

"  default output dir = source dir\n"
"  default list dir   = output dir\n\n";

static const char examples[] =
"examples:\n"
"  zasm speccirom.asm\n"
"  zasm -uwy emuf_rom.asm rom_v2.0.1.rom\n\n";

static const char options[] =
"options:\n"
"  -u  --opcodes   include object code in list file\n"
"  -w  --labels    append label listing to list file\n"
"  -y  --cycles    include cpu clock cycles in list file\n"
"  -b  --bin       write output to binary file (default)\n"
"  -x  --hex       write output in intel hex format\n"
"  -s  --s19       write output in motorola s-record format\n"
"  -z  --clean     clear intermediate files, e.g. compiled c files\n"
"  -e  --compare   compare own output to existing output file\n"
"  -T  --test      run self test (requires test directory with test sources)\n"
"  -g  --cgi       prevent access to files outside the source dir\n"
"  --maxerrors=NN  set maximum for reported errors (default=30, max=999)\n"
"  --date=DATETIME for reproducible __date__ and __time__\n"
"  -o0             don't write output file\n"
"  -l0             don't write list file\n"
"  --8080          target Intel 8080 (default if --asm8080)\n"
"  --z80           target Zilog Z80  (default except if --asm8080)\n"
"  --z180          target Zilog Z180 / Hitachi HD64180\n"
"  --asm8080       use 8080 assembler syntax\n"
"  --convert8080   convert 8080 assembler source to Z80\n"
"  -v[0,1,2]       verbosity of messages to stderr (0=off, 1=default, 2=more)\n"
"  --ixcbr2        enable illegal instructions like 'set b,(ix+d),r'\n"
"  --ixcbxh        enable illegal instructions like 'set b,xh'\n"
"  --dotnames      allow label names starting with a dot '.'\n"
"  --reqcolon      require colon ':' after program label definitions\n"
"                  => label definitions and instructions may start in any column\n"
"  --casefold      label names are case insensitive (implied if --asm8080)\n"
"  --flatops       no operator precedence: evaluate strictly from left to right\n"
"  -c [path/to/]cc declare or set path to c compiler (search in $PATH)\n"
"  -t path/to/dir  set path to temp dir for c compiler (default: output dir)\n"
"  -I path/to/dir  set path to c system header dir (default: compiler default)\n"
"  -L path/to/dir  set path to standard library dir (default: none)\n"
"–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n\n"
"";

static cstr compiledatestr ()
{
	// helper: get the compile date in preferred format "yyyy-mm-dd":

	static const char ansidate[] = __DATE__;		// "Jan  1 2014"
	static const char months[] = "JanFebMarAprMayJunJulAugSepOctNovDec";

	uint m=0; while (strncmp(ansidate, months+3*m++, 3)) {}
	uint d = uint(strtol(ansidate+4,nullptr,10));
	cptr y = ansidate+7;
	return usingstr("%s-%02u-%02u",y,m,d);
}

static cstr help()
{
	return catstr(usingstr(version,compiledatestr()),syntax,examples,options);
}

static void read_testdir (cstr path, Array<cstr>& filepaths)
{
	// recursively read test directory
	// skips symlinks (files and folders)
	// skips "original/", "ALT/" and "s/"
	// adds all ".asm" files which start with "#!"

	assert(eq(path,fullpath(path,no)));

	DIR* dir = opendir(path);
	if (!dir) return;								// error

	for (;;)
	{
		dirent* direntry = readdir(dir);
		if (!direntry) break;

		cstr filename = direntry->d_name;
		if (filename[0]=='.') continue;				// "." or ".." or hidden file or folder
		cstr filepath = catstr(path,filename);

		struct stat filestat;
		if (lstat(filepath,&filestat)) continue; 	// error
		if (S_ISDIR(filestat.st_mode) && ne(filename,"original") && ne(filename,"ALT") && ne(filename,"s"))
			read_testdir(catstr(filepath,"/"), filepaths);
		//if(S_ISLNK(filestat.st_mode)) continue;  	// skip all symlinks, files or folders
		if (!S_ISREG(filestat.st_mode)) continue;	// not a file
		if (!endswith(filename,".asm")) continue;	// no assembler source file

		int fd = open(filepath,O_RDONLY,0664);		// test for Shebang:
		if (fd<0) continue;							// failed to open file
		char bu[3] = "aa";
r:		int n = int(read(fd,bu,2));					// read "#!"
		if (n<0 && errno==EINTR) goto r;
		if (n<0 && errno==EAGAIN) { usleep(5000); goto r; }
		close(fd);
		//if (n!=2) continue;
		if (ne(bu,"#!")) continue;					// does not start with #!/usr/local/zasm …

		filepaths.append(filepath);
	}

	closedir(dir);
}

static void split_command_line (cstr s, Array<cstr>& args)
{
	// split command line into words
	// split at white space
	// keep ".." and '..'
	// unescape escaped char except inside '..'
	// other bash syntax is ignored – this function is only used to parse our "#!…" in line 1 only
	// see: http://wiki.bash-hackers.org/syntax/quoting
	// see: https://www.gnu.org/software/bash/manual/html_node/Double-Quotes.html
	// inside double quotes (weak quotes):
	//   The backslash retains its special meaning only when followed by one of the following characters:
	//   ‘$’, ‘`’, ‘"’, ‘\’, or newline. Within double quotes, backslashes that are followed by one of these
	//   characters are removed. Backslashes preceding characters without a special meaning are left unmodified.

	char zbu[256];
	for (;;)
	{
		// skip gap:
		while (*s && uchar(*s)<=' ') { s++; }
		if (*s==0) break;

		// copy word:
		ptr z = zbu;
		while (uchar(*s) > ' ')
		{
			if (*s == '\'')		// strong quote
			{
				s++;
				while (*s && *s!='\'') { *z++ = *s++; }
				if (*s) s++;
				continue;
			}

			if (*s=='"')		// weak quote
			{
				s++;
				while (*s && *s!='"')
				{
					if (*s == '\\')
					{
						char c = *(s+1);
						if (c=='$' || c=='`' || c=='"' || c=='\\') s++;	// skip over '\'
					}
					*z++ = *s++;
				}
				if (*s) s++;
				continue;
			}

			// plain char
			if (*s == '\\' && *(s+1)) s++;	// skip over '\'
			*z++ = *s++;
		}

		// store word:
		args.append(substr(zbu,z));
	}
}

static int doit( Array<cstr> argv )
{
	// PROGRAM ENTRY POINT!

	double start = now();

// options:
	int  verbose     = 1;	// 0=off, 1=default, 2=verbose
	int  outputstyle = 'b';	// 0=none, 'b'=binary, 'x'=intel hex, 's'=motorola s-records
	int  liststyle   = 1;	// 0=none, 1=plain, 2=with objcode, 4=with label listing, 6=both, 8=clock cycles
	bool clean		 = no;
	bool ixcbr2		 = no;
	bool ixcbxh		 = no;
	bool targetZ80	 = no;
	bool target8080	 = no;
	bool targetZ180  = no;
	bool syntax8080  = no;
	bool dotnames    = no;
	bool reqcolon    = no;
	bool casefold    = no;
	bool flatops	 = no;
	bool compare     = no;
	bool selftest    = no;
	bool cgi_mode	 = no;
	bool convert8080 = no;
	uint maxerrors   = 30;
	double timestamp = start; // __date__ and __time__ and S0 record

// filepaths:
	cstr inputfile  = nullptr;
	cstr outputfile = nullptr;	// or dir
	cstr listfile   = nullptr;	// or dir
	cstr tempdir    = nullptr;
	cstr c_compiler = nullptr;
	cstr c_includes	= nullptr;
	cstr stdlib_dir	= nullptr; // for #include standard library

//	eval arguments:
	for (uint i=1; i<argv.count(); )
	{
		cptr s = argv[i++];

		if (s[0] != '-')
		{
			if (!inputfile)  { inputfile = s; continue; }
			// if outfile is not prefixed with -o then it must be the last argument:
			if (!outputfile && i==argv.count()) { outputfile = s; continue; }
			if (!listfile)   { listfile = s; continue; }
			goto h;
		}

		if (s[1]=='-')
		{
			if (eq(s,"--clean"))    { clean = yes;     continue; }
			if (eq(s,"--bin"))	   { outputstyle='b'; continue; }
			if (eq(s,"--hex"))	   { outputstyle='x'; continue; }
			if (eq(s,"--s19"))	   { outputstyle='s'; continue; }
			if (eq(s,"--opcodes"))  { liststyle |= 2;  continue; }
			if (eq(s,"--labels"))   { liststyle |= 4;  continue; }
			if (eq(s,"--cycles"))   { liststyle |= 8;  continue; }
			if (eq(s,"--ixcbr2"))   { ixcbr2 = 1;      continue; }
			if (eq(s,"--ixcbxh"))   { ixcbxh = 1;      continue; }
			if (eq(s,"--z80"))      { targetZ80 = 1;   continue; }
			if (eq(s,"--8080"))     { target8080 = 1;  continue; }
			if (eq(s,"--asm8080"))  { syntax8080 = 1;  continue; }
			if (eq(s,"--z180"))     { targetZ180 = 1;  continue; }
			if (eq(s,"--dotnames")) { dotnames = 1;    continue; }
			if (eq(s,"--reqcolon")) { reqcolon = 1;    continue; }
			if (eq(s,"--casefold")) { casefold = 1;    continue; }
			if (eq(s,"--flatops"))  { flatops = 1;     continue; }
			if (eq(s,"--compare"))  { compare = 1;     continue; }
			if (eq(s,"--test"))     { selftest = 1;    continue; }
			if (eq(s,"--cgi"))      { cgi_mode = 1;    continue; }
			if (eq(s,"--convert8080")) { convert8080 = 1; continue; }
			if (startswith(s,"--maxerrors="))
				{
					char* ep; ulong n = strtoul(s+12,&ep,10);
					if (*ep||n==0||n>999) goto h;
					maxerrors = uint(n); continue;
				}
			if (startswith(s,"--date="))
				{
					timestamp = dateval(s);
					continue;
				}
			goto h;
		}

		while (char c = *++s)
		{
			switch (c)
			{
			case 'e': compare = 1; continue;
			case 'T': selftest = 1; continue;
			case 'u': liststyle |= 2; continue;
			case 'w': liststyle |= 4; continue;
			case 'y': liststyle |= 8; continue;
			case 's': outputstyle=c; continue;
			case 'x': outputstyle=c; continue;
			case 'b': outputstyle=c; continue;
			case 'z': clean=yes; continue;
			case 'g': cgi_mode=yes; continue;

			case 'v': if (*(s+1)>='0' && *(s+1)<='3') verbose = *++s - '0'; else ++verbose; continue;

			case 'i': if (inputfile  || i==argv.count()) goto h; else inputfile  = argv[i++]; continue;
			case 'o': if (*(s+1)=='0') { outputstyle = 0; ++s; continue; }
					  if (outputfile || i==argv.count()) goto h; else outputfile = argv[i++]; continue;
			case 'l': if (*(s+1)=='0') { liststyle = 0; ++s; continue; }
					  if (listfile   || i==argv.count()) goto h; else listfile   = argv[i++]; continue;

			case 'c': if (c_compiler || i==argv.count()) goto h; else c_compiler = argv[i++]; continue;
			case 'I': if (c_includes || i==argv.count()) goto h; else c_includes = argv[i++]; continue;
			case 'L': if (stdlib_dir || i==argv.count()) goto h; else stdlib_dir = argv[i++]; continue;
			case 't': if (tempdir    || i==argv.count()) goto h; else tempdir    = argv[i++]; continue;
			default:  goto h;
			}
		}
	}

	if (selftest && !compare)
	{
		// assemble a bunch of sources from a test directory
		// and compare them to old versions found in the original/ subdirectories.
		if (verbose) logline("zasm: +++ Regression Test +++");

		// if no path to the $TESTDIR directory is given, then the current working directory is used.
		// ".asm" source files which start with "#!" will be assembled and compared to the original output file.
		cstr testdir = fullpath( inputfile ? inputfile : outputfile ? outputfile : "./" );
		if (errno==ok && lastchar(testdir)!='/') errno = ENOTDIR;
		if (errno)
		{
			if (verbose) log( "--> %s: %s\nzasm: 1 error\n", testdir, strerror(errno));
			return 1;
		}

		// collect all test sources:
		Array<cstr> testfiles;
		if (verbose) logline("zasm: scanning directory for test sources ... ");
		read_testdir(testdir,testfiles);
		if (verbose) logline("zasm: found %u test source files\n",testfiles.count());

		// assemble & compare all test sources:
		int errors = 0;
		for (uint i=0; i<testfiles.count(); i++)
		{
			cstr testfile = testfiles[i];
			if (verbose) logline("assemble file: %s",testfile);
			// read line 1:
			int fd = open(testfile,O_RDONLY,0664);
			if (fd<0) { errors++; logline("%s",strerror(errno)); continue; }	// error
			char bu[256];
	r:		int n = int(read(fd,bu,255));				// read line 1
			if (n<0)
			{
				if (errno==EINTR) goto r;
				if (errno==EAGAIN) { usleep(5000); goto r; }
				errors++; logline("%s",strerror(errno)); close(fd); continue;
			}
			close(fd);
			bu[n] = '\n';
			*strchr(bu,'\n') = 0;

			// split args[] and combine argument lists for recursive call:
			Array<cstr> args;
			split_command_line(bu,args);
			assert(args.count()>0);
			args[0] = argv[0];							// path/to/zasm
			args.append("-l0");
			args.append("-i");
			args.append(testfile);
			args.append("--compare");
			for (uint j=1; j<argv.count(); j++) { args.append(argv[j]); }

			// recursively call self:
			change_working_dir(directory_from_path(testfile));	// to find output dir
			errors += doit(std::move(args));
		}

		if (verbose)
		{
			log( "\ntotal time: %3.4f sec.\n", now()-start);
			if (errors>1) log( "\nzasm: %u errors\n\n", errors);
			else log( errors ? "\nzasm: 1 error\n\n" : "zasm: no errors\n");
		}
		return errors>0;
	}

// check options:
	if (convert8080)			  syntax8080 = yes;
	if (targetZ180)				  targetZ80  = yes;	// implied
	if (syntax8080 && !targetZ80) target8080 = yes;	// only implied   if not --Z80 set
	if (!target8080)			  targetZ80  = yes;	// default to Z80 if not --8080 or --asm8080 set

	if (syntax8080 && targetZ180)
	{
		log("--> %s\nzasm: 1 error\n", "the 8080 assembler does not support Z180 opcodes.");
		return 1;
	}

	if (target8080 && targetZ80)
	{
		log("--> %s\nzasm: 1 error\n", "--8080 and --z80|--z180 are mutually exclusive.");
		return 1;
	}

	if (ixcbr2 || ixcbxh)
	{
		if (target8080)
		{
			log("--> %s\nzasm: 1 error\n", "i8080 has no index registers and no prefix 0xCB instructions.");
			return 1;
		}

		if (targetZ180)
		{
			log("--> %s\nzasm: 1 error\n", "no --ixcb… allowed: the Z180 traps illegal instructions");
			return 1;
		}

		if (syntax8080)
		{
			log("--> %s\nzasm: 1 error\n", "the 8080 assembler does not support illegal opcodes.");
			return 1;
		}

		if (ixcbr2 && ixcbxh)
		{
			log("--> %s\nzasm: 1 error\n", "--ixcbr2 and --ixcbxh are mutually exclusive.");
			return 1;
		}
	}


// check source file:
	if (!inputfile)
	{
		h: log("%s",help());
		return 1;
	}
	inputfile = fullpath(inputfile,no);
	if (errno)
	{
		if (verbose) log( "--> %s: %s\nzasm: 1 error\n", inputfile, strerror(errno));
		return 1;
	}
	if (!is_file(inputfile))
	{
		if (verbose) log( "--> %s: not a regular file\nzasm: 1 error\n", inputfile);
		return 1;
	}

// check output file or dir:
	if (!outputfile) outputfile = directory_from_path(inputfile);
	outputfile = fullpath(outputfile);
	if (errno && errno!=ENOENT)
	{
		if (verbose) log( "--> %s: %s\nzasm: 1 error\n", outputfile, strerror(errno));
		return 1;
	}
	if (convert8080 && lastchar(outputfile)!='/')
	{
		// output file must be a text file. reject at least the most common binary files:
		cstr ext = lowerstr(extension_from_path(outputfile));
		if (eq(ext,".bin") || eq(ext,".rom") || eq(ext,".hex") || eq(ext,".s19"))
		{
			if (verbose) log( "--> output file must specify a z80 source file name\nzasm: 1 error\n");
			return 1;
		}
	}

// check list file or dir:
	if (!listfile) listfile = directory_from_path(outputfile);
	listfile = fullpath(listfile);
	if (errno && errno!=ENOENT)
	{
		if (verbose) log( "--> %s: %s\nzasm: 1 error\n", listfile, strerror(errno));
		return 1;
	}

// check temp dir:
	if (!tempdir) tempdir = directory_from_path(outputfile);
	tempdir = fullpath(tempdir);
	if (errno && errno!=ENOENT)
	{
		if (verbose) log( "--> %s: %s\nzasm: 1 error\n", tempdir, strerror(errno));
		return 1;
	}
	if (lastchar(tempdir)!='/')
	{
		if (verbose) log( "--> %s: %s\nzasm: 1 error\n", tempdir, strerror(ENOTDIR));
		return 1;
	}

// check c_includes path:
	if (c_includes)
	{
		c_includes = fullpath(c_includes);
		if (errno==ok && lastchar(c_includes)!='/') errno = ENOTDIR;
		if (errno)
		{
			if (verbose) log( "--> %s: %s\nzasm: 1 error\n", c_includes, strerror(errno));
			return 1;
		}
	}

// check standard library directory path:
	if (stdlib_dir)
	{
		stdlib_dir = fullpath(stdlib_dir);
		if (errno==ok && lastchar(stdlib_dir)!='/') errno = ENOTDIR;
		if (errno)
		{
			if (verbose) log( "--> %s: %s\nzasm: 1 error\n", stdlib_dir, strerror(errno));
			return 1;
		}
	}

// check c_compiler path:
	if (c_compiler)
	{
		if (c_compiler[0]!='/')
		{
			cstr s = find_executable(c_compiler);
			if (s) c_compiler = s;
		}

		c_compiler = fullpath(c_compiler);
		if (errno)
		{
			if (verbose) log( "--> %s: %s\nzasm: 1 error\n", c_compiler, strerror(errno));
			return 1;
		}
		if (!is_file(c_compiler))
		{
			if (verbose) log( "--> %s: not a regular file\nzasm: 1 error\n", c_compiler);
			return 1;
		}
		if (!is_executable(c_compiler))
		{
			if (verbose) log( "--> %s: not executable\nzasm: 1 error\n", c_compiler);
			return 1;
		}
	}

// DO IT!
	Z80Assembler ass;
	ass.timestamp      = timestamp;
	ass.verbose		   = verbose;
	ass.ixcbr2_enabled = ixcbr2;
	ass.ixcbxh_enabled = ixcbxh;
	ass.target_8080    = target8080;
	ass.target_z80     = targetZ80;
	ass.target_z180    = targetZ180;
	ass.syntax_8080	   = syntax8080;
	ass.convert_8080   = convert8080;
	ass.require_colon  = reqcolon;
	ass.allow_dotnames = dotnames;
	ass.casefold	   = casefold;
	ass.flat_operators = flatops;
	ass.max_errors     = maxerrors;
	ass.compare_to_old = compare;
	ass.cgi_mode	   = cgi_mode;
	ass.c_compiler     = c_compiler;
	ass.c_includes     = c_includes;
	ass.stdlib_dir     = stdlib_dir;
	ass.assembleFile( inputfile, outputfile, listfile, tempdir, liststyle, outputstyle, clean );

	uint errors = ass.errors.count();

	if (verbose)		// show errors on stderr:
	{
		cstr current_file = nullptr;
		for (uint i=0; i<errors; i++)
		{
			Error const& e = ass.errors[i];
			SourceLine* sourceline = e.sourceline;
			if (!sourceline)
			{
				if (current_file) log("\n");
				current_file = nullptr;
				log("--> %s\n",e.text);
				continue;
			}

			cstr filename = sourceline->sourcefile;
			if (filename!=current_file)				// note: compare pointers!
			{
				current_file = filename;
				log( "\nin file %s:\n", filename_from_path(filename));
			}

			cstr linenumber = tostr(sourceline->sourcelinenumber+1);
			log( "%s: %s\n", linenumber, sourceline->text);
			log( "%s%s^ %s\n", spacestr(int(strlen(linenumber))+2), sourceline->whitestr(), e.text);
		}

		log( "assembled file: %s\n    %u lines, %u pass%s, %3.4f sec.\n",
			filename_from_path(ass.source_filename), ass.source.count(), ass.pass, ass.pass==1?"":"es", now()-start);
		if (errors>1) log( "    %u errors\n\n", errors);
		else		  log( errors ? "    1 error\n\n" : "    no errors\n\n");
	}

	return errors>0;	// 0=ok, 1=errors
}

int main (int argc, cstr argv[])
{
	if (argc==2)
	{
		if (eq(argv[1], "--version")) { printf(version,compiledatestr()); return 0; }
		if (eq(argv[1], "--help"))    { printf("%s", help()); return 0; }
	}
	return doit(Array<cstr>(argv,uint(argc)));
}








































