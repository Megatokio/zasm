#-------------------------------------------------
#
# Project created by QtCreator 2014-10-06T16:47:38
#
#-------------------------------------------------

TARGET	= zasm
TEMPLATE = app
QT       -= core
QT       -= gui

CONFIG += console
CONFIG -= app_bundle
CONFIG += c++11
CONFIG += precompiled_header
CONFIG(release,debug|release) { DEFINES += NDEBUG RELEASE } # ATTN: curly brace must start in same line!
CONFIG(debug,debug|release) { DEFINES += DEBUG } # ATTN: curly brace must start in same line!
#QMAKE_CXXFLAGS += -Wno-four-char-constants
QMAKE_CXXFLAGS += -Wno-multichar -Wno-gnu-anonymous-struct -Wno-nested-anon-types
QMAKE_CXXFLAGS_RELEASE += -Os

LIBS += -lz

INCLUDEPATH +=          \
	./                  \
	Source              \
	Libraries           \

SOURCES += \
	Libraries/Z80/goodies/z80_disass.cpp \
	Source/Error.cpp \
	Source/Label.cpp \
	Source/Z80.cpp \
	Source/Z80Registers.cpp \
	Source/assemble8080.cpp \
	Source/assembleZ80.cpp \
	Source/convert8080.cpp \
	Source/main.cpp \
	Source/Segment.cpp \
	Source/Source.cpp \
	Source/Z80Assembler.cpp \
	Source/CharMap.cpp \
	Source/helpers.cpp \
	Source/outputfile.cpp \
	Source/listfile.cpp \
	Source/Z80Header.cpp \
	Source/Macro.cpp \
	Source/SyntaxError.cpp \
	Source/runTestcode.cpp \
	Source/zx7.cpp \
	Libraries/cstrings/cstrings.cpp \
	Libraries/kio/exceptions.cpp \
	Libraries/kio/kio.cpp \
	Libraries/unix/FD.cpp \
	Libraries/cstrings/tempmem.cpp \
	Libraries/unix/files.cpp \
	Libraries/Z80/goodies/z180_clock_cycles.cpp \
	Libraries/Z80/goodies/z80_clock_cycles.cpp \
	Libraries/Z80/goodies/z80_major_opcode.cpp \
	Libraries/Z80/goodies/z80_opcode_length.cpp \
	Libraries/audio/audio.cpp \
	Libraries/audio/WavFile.cpp \

HEADERS += \
	Libraries/Templates/RCArray.h \
	Libraries/Templates/RCObject.h \
	Libraries/Templates/RCPtr.h \
	Libraries/Templates/relational_operators.h \
	Libraries/Templates/sort.h \
	Libraries/Templates/template_helpers.h \
	Libraries/Z80/goodies/z80_disass.h \
	Libraries/kio/auto_config.h \
	Source/Error.h \
	Source/Label.h \
	Source/Segment.h \
	Source/Z80.h \
	Source/Z80Registers.h \
	Source/settings.h \
	Source/Source.h \
	Source/Value.h \
	Source/z80macros.h \
	Source/zx7.h \
	Source/SyntaxError.h \
	Source/Z80Assembler.h \
	Source/settings.h \
	Source/CharMap.h \
	Source/helpers.h \
	Source/Z80Header.h \
	Source/Macro.h \
	Source/SyntaxError.h \
	Libraries/cstrings/base85.h \
	Libraries/cstrings/cstrings.h \
	Libraries/kio/errors.h \
	Libraries/kio/kio.h \
	Libraries/kio/detect_configuration.h \
	Libraries/unix/log.h \
	Libraries/unix/FD.h \
	Libraries/cstrings/tempmem.h \
	Libraries/unix/files.h \
	Libraries/kio/standard_types.h \
	Libraries/kio/peekpoke.h \
	Libraries/kio/exceptions.h \
	Libraries/Templates/Array.h \
	Libraries/Templates/HashMap.h \
	Libraries/Z80/goodies/z80_major_opcode_tables.h \
	Libraries/Z80/goodies/z80_opcodes.h \
	Libraries/Z80/goodies/z80_goodies.h \
	Libraries/hash/sdbm_hash.h \
	Libraries/audio/audio.h \
	Libraries/audio/WavFile.h \

OTHER_FILES += \
	.gitignore \
	sdcc/lib/___setjmp.s \
	sdcc/lib/__divsint.s \
	sdcc/lib/__divsuchar.s \
	sdcc/lib/__divuint.s \
	sdcc/lib/__divuschar.s \
	sdcc/lib/__modsint.s \
	sdcc/lib/__modsuchar.s \
	sdcc/lib/__moduint.s \
	sdcc/lib/__mulint.s \
	sdcc/lib/__mulschar.s \
	sdcc/lib/__sdcc_call_hl.s \
	sdcc/lib/_localtime.s \
	sdcc/lib/_memmove.s \
	sdcc/lib/_putchar.s \
	sdcc/lib/_strcpy.s \
	sdcc/lib/_strlen.s \
	sdcc/lib/crt0 .s \
	sdcc/lib/heap .s \
	sdcc/lib/___fs2schar.c \
	sdcc/lib/___fs2sint.c \
	sdcc/lib/___fs2slong.c \
	sdcc/lib/___fs2uchar.c \
	sdcc/lib/___fs2uint.c \
	sdcc/lib/___fs2ulong.c \
	sdcc/lib/___fsadd.c \
	sdcc/lib/___fsdiv.c \
	sdcc/lib/___fseq.c \
	sdcc/lib/___fsgt.c \
	sdcc/lib/___fslt.c \
	sdcc/lib/___fsmul.c \
	sdcc/lib/___fsneq.c \
	sdcc/lib/___fssub.c \
	sdcc/lib/___schar2fs.c \
	sdcc/lib/___sint2fs.c \
	sdcc/lib/___slong2fs.c \
	sdcc/lib/___uchar2fs.c \
	sdcc/lib/___uint2fs.c \
	sdcc/lib/___ulong2fs.c \
	sdcc/lib/__assert.c \
	sdcc/lib/__divslong.c \
	sdcc/lib/__divslonglong.c \
	sdcc/lib/__divulong.c \
	sdcc/lib/__divulonglong.c \
	sdcc/lib/__itoa.c \
	sdcc/lib/__modslong.c \
	sdcc/lib/__modulong.c \
	sdcc/lib/__mullong.c \
	sdcc/lib/__mullonglong.c \
	sdcc/lib/__print_format.c \
	sdcc/lib/__rlslonglong.c \
	sdcc/lib/__rlulonglong.c \
	sdcc/lib/__rrslonglong.c \
	sdcc/lib/__rrulonglong.c \
	sdcc/lib/__uitoa.c \
	sdcc/lib/_abs.c \
	sdcc/lib/_acosf.c \
	sdcc/lib/_asctime.c \
	sdcc/lib/_asincosf.c \
	sdcc/lib/_asinf.c \
	sdcc/lib/_atan2f.c \
	sdcc/lib/_atanf.c \
	sdcc/lib/_atof.c \
	sdcc/lib/_atoi.c \
	sdcc/lib/_atol.c \
	sdcc/lib/_calloc.c \
	sdcc/lib/_ceilf.c \
	sdcc/lib/_check_struct_tm.c \
	sdcc/lib/_cosf.c \
	sdcc/lib/_coshf.c \
	sdcc/lib/_cotf.c \
	sdcc/lib/_ctime.c \
	sdcc/lib/_days_per_month.c \
	sdcc/lib/_errno.c \
	sdcc/lib/_expf.c \
	sdcc/lib/_fabsf.c \
	sdcc/lib/_floorf.c \
	sdcc/lib/_free.c \
	sdcc/lib/_frexpf.c \
	sdcc/lib/_gets.c \
	sdcc/lib/_gmtime.c \
	sdcc/lib/_heap.c \
	sdcc/lib/_isalnum.c \
	sdcc/lib/_isalpha.c \
	sdcc/lib/_isblank.c \
	sdcc/lib/_iscntrl.c \
	sdcc/lib/_isdigit.c \
	sdcc/lib/_isgraph.c \
	sdcc/lib/_islower.c \
	sdcc/lib/_isprint.c \
	sdcc/lib/_ispunct.c \
	sdcc/lib/_isspace.c \
	sdcc/lib/_isupper.c \
	sdcc/lib/_isxdigit.c \
	sdcc/lib/_labs.c \
	sdcc/lib/_ldexpf.c \
	sdcc/lib/_log10f.c \
	sdcc/lib/_logf.c \
	sdcc/lib/_ltoa.c \
	sdcc/lib/_malloc.c \
	sdcc/lib/_memchr.c \
	sdcc/lib/_memcmp.c \
	sdcc/lib/_memcpy.c \
	sdcc/lib/_memset.c \
	sdcc/lib/_mktime.c \
	sdcc/lib/_modff.c \
	sdcc/lib/_powf.c \
	sdcc/lib/_printf_small.c \
	sdcc/lib/_printf.c \
	sdcc/lib/_put_char_to_stdout.c \
	sdcc/lib/_put_char_to_string.c \
	sdcc/lib/_puts.c \
	sdcc/lib/_rand.c \
	sdcc/lib/_realloc.c \
	sdcc/lib/_sincosf.c \
	sdcc/lib/_sincoshf.c \
	sdcc/lib/_sinf.c \
	sdcc/lib/_sinhf.c \
	sdcc/lib/_sprintf.c \
	sdcc/lib/_sqrtf.c \
	sdcc/lib/_strcat.c \
	sdcc/lib/_strchr.c \
	sdcc/lib/_strcmp.c \
	sdcc/lib/_strcspn.c \
	sdcc/lib/_strncat.c \
	sdcc/lib/_strncmp.c \
	sdcc/lib/_strncpy.c \
	sdcc/lib/_strpbrk.c \
	sdcc/lib/_strrchr.c \
	sdcc/lib/_strspn.c \
	sdcc/lib/_strstr.c \
	sdcc/lib/_strtok.c \
	sdcc/lib/_strxfrm.c \
	sdcc/lib/_tancotf.c \
	sdcc/lib/_tanf.c \
	sdcc/lib/_tanhf.c \
	sdcc/lib/_time.c \
	sdcc/lib/_tolower.c \
	sdcc/lib/_toupper.c \
	sdcc/lib/_vprintf.c \
	sdcc/lib/_vsprintf.c \
	sdcc/lib/_log_table.h \
	\
	sdcc/include/asm/default/features.h \
	sdcc/include/asm/z80/features.h \
	sdcc/include/assert.h \
	sdcc/include/ctype.h \
	sdcc/include/errno.h \
	sdcc/include/float.h \
	sdcc/include/iso646.h \
	sdcc/include/limits.h \
	sdcc/include/malloc.h \
	sdcc/include/math.h \
	sdcc/include/sdcc-lib.h \
	sdcc/include/setjmp.h \
	sdcc/include/stdalign.h \
	sdcc/include/stdarg.h \
	sdcc/include/stdbool.h \
	sdcc/include/stddef.h \
	sdcc/include/stdint.h \
	sdcc/include/stdio.h \
	sdcc/include/stdlib.h \
	sdcc/include/stdnoreturn.h \
	sdcc/include/string.h \
	sdcc/include/time.h \
	sdcc/include/tinibios.h \
	sdcc/include/typeof.h \
	\
	sdcc/sdcc_info.txt \
	\
	Examples/main.c \
	Examples/globls.s \
	Examples/jupiter_ace_character_ram.s \
	Examples/jupiter_ace_sysvars.s \
	Examples/zx80_sysvars.s \
	Examples/zx81_sysvars.s \
	Examples/zx_spectrum_basic_tokens.s \
	Examples/zx_spectrum_sysvars.s \
	Examples/zx_spectrum_io_rom.s \
	\
	Examples/template_bin.asm \
	Examples/template_minimal_rom.asm \
	Examples/template_rom_with_c_code.asm \
	Examples/template_o.asm \
	Examples/template_p.asm \
	Examples/template_rom.asm \
	Examples/template_sna.asm \
	Examples/template_tap.asm \
	Examples/template_z80.asm \
	Examples/template_ace.asm \

DISTFILES += \
	"Documentation/ README.txt" \
	"Documentation/zasm.toc" \
	"Documentation/8080 Assembler.txt" \
	"Documentation/8080 assembler Z80 instructions.txt" \
	"Documentation/8080 assembler instructions.txt" \
	"Documentation/8080 instructions.txt" \
	"Documentation/Command Line Options.txt" \
	"Documentation/Compound instructions.txt" \
	Documentation/Illegals.txt \
	"Documentation/Including C Sources.txt" \
	"Documentation/Label definition.txt" \
	"Documentation/Legal Notes.txt" \
	"Documentation/List File.txt" \
	"Documentation/Numeric expressions.txt" \
	"Documentation/Quick Overview.txt" \
	"Documentation/String expressions.txt" \
	"Documentation/Syntax variants.txt" \
	"Documentation/Target files - Overview.txt" \
	"Documentation/Version History.txt" \
	Documentation/_!.txt \
	Documentation/__casefold.txt \
	Documentation/__dotnames.txt \
	Documentation/__flatops.txt \
	Documentation/__ixcbr2.txt \
	Documentation/__reqcolon.txt \
	Documentation/__test.txt \
	Documentation/_assert.txt \
	Documentation/_cflags.txt \
	Documentation/_charset.txt \
	Documentation/_code.txt \
	Documentation/_compress.txt \
	Documentation/_cpath.txt \
	Documentation/_data.txt \
	Documentation/_define.txt \
	Documentation/_end.txt \
	Documentation/_if.txt \
	Documentation/_include.txt \
	Documentation/_insert.txt \
	Documentation/_local.txt \
	Documentation/_target.txt \
	Documentation/_test.txt \
	Documentation/align.txt \
	Documentation/area.txt \
	Documentation/asciz.txt \
	Documentation/automate.vs \
	"Documentation/command line options for c compiler.txt" \
	"Documentation/defb db.txt" \
	"Documentation/defl set.txt" \
	"Documentation/defm dm.txt" \
	"Documentation/defs ds.txt" \
	"Documentation/defw dw.txt" \
	"Documentation/dotnames reqcolon etc.txt" \
	"Documentation/dup edup.txt" \
	Documentation/end.txt \
	Documentation/equ.txt \
	Documentation/globl.txt \
	Documentation/if.txt \
	Documentation/incbin.txt \
	Documentation/include.txt \
	Documentation/long.txt \
	"Documentation/macro endm.txt" \
	Documentation/org.txt \
	"Documentation/phase dephase.txt" \
	"Documentation/rept endm.txt" \
	"Documentation/target ace.txt" \
	"Documentation/target bin rom.txt" \
	"Documentation/target o 80.txt" \
	"Documentation/target p 81 p81.txt" \
	"Documentation/target sna.txt" \
	"Documentation/target tap.txt" \
	"Documentation/target tzx.txt" \
	"Documentation/target z80.txt" \
	"Documentation/z180 instructions.txt" \
	"Documentation/z80 instructions.txt" \
	"Documentation/z80 z180 8080.txt" \
	Documentation/test.asm.txt \
	Documentation/test.lst.txt \
	Test/8080/8080EX1.asm \
	Test/8080/8080EXER.asm \
	Test/8080/8080PRE.asm \
	Test/8080/Altair8800_Monitor.asm \
	Test/8080/Z_ZAPPLEASM.asm \
	Test/8080/Z_ZAPPLEASM.original.asm \
	Test/8080/test_macros.asm \
	Test/SDCC/sdcc \
	Test/SDCC/sdcpp \
	Test/SDCC/test-tap.asm \
	Test/SDCC/test1.asm \
	Test/Z180/185macro.lib \
	Test/Z180/counter master.asm \
	Test/Z180/first.asm \
	Test/Z80/5bsort018.asm \
	Test/ZXSP/decompress_zx7_standard.s \
	Test/ZXSP/jupiter_ace_character_ram.bin \
	Test/ZXSP/mouse.asm \
	Test/ZXSP/template_80.asm \
	Test/ZXSP/template_ace.asm \
	Test/ZXSP/template_o.asm \
	Test/ZXSP/template_p.asm \
	Test/ZXSP/template_rom_with_c_code.asm \
	Test/ZXSP/template_sna.asm \
	Test/ZXSP/template_tap.asm \
	Test/ZXSP/template_tap_with_zx7.asm \
	Test/ZXSP/template_z80.asm \
	Test/ZXSP/test-float@11kx1.wav \
	Test/ZXSP/test-int16@11kx1.wav \
	Test/ZXSP/test-int16x2@44k1.wav \
	Test/ZXSP/tzx.asm \
	Test/ZXSP/main.c \
	Test/Z80/CPM22.asm \
	Test/Z80/Ex1.asm \
	Test/Z80/Hello World.asm \
	Test/Z80/MS-Basic.asm \
	Test/Z80/READID.MAC \
	Test/Z80/SE Basic 094v018.asm \
	Test/Z80/Serial I:O test.asm \
	Test/Z80/Z80FloatA.asm \
	Test/Z80/ZX81_dual_edited.txt \
	Test/Z80/Zx81zasm.asm \
	Test/Z80/allsrc.asm \
	Test/Z80/assembler.asm \
	Test/Z80/basic.asm \
	Test/Z80/beforespeedup.asm \
	Test/Z80/boot.asm \
	Test/Z80/callstack.asm \
	Test/Z80/ce2.asm \
	Test/Z80/chrismas.asm \
	Test/Z80/m80b.asm \
	Test/Z80/monitor.asm \
	Test/Z80/monitor_32k.asm \
	Test/Z80/mybios4_mod.asm \
	Test/Z80/mybios4_mod2.asm \
	Test/Z80/pc_do_ca.s \
	Test/Z80/print.asm \
	Test/Z80/qsort.asm \
	Test/Z80/rept.asm \
	Test/Z80/s.asm \
	Test/Z80/ss.asm \
	Test/Z80/target_ram_s.asm \
	Test/Z80/target_ram_x.asm \
	Test/Z80/target_rom_s.asm \
	Test/Z80/target_rom_x.asm \
	Test/Z80/test z80 cpu - prelim.asm \
	Test/Z80/thrashbarg.asm \
	Test/Z80/z.asm.asm \
	Test/Z80/z80mon.asm \
	Test/Z80/z80sourc.asm \
	Test/Z80/zasm-test-flatops.asm \
	Test/Z80/zasm-test-opcodes.asm \
	Test/Z80/zx81_newvsync.asm \
	Test/Z80/zx81v2.asm \
	Test/SDCC/crc.c \
	Test/SDCC/main.c \
	Test/SDCC/rem.c \
	Test/8080/zasm-test-opcodes-8080.asm \
	Test/Z180/zasm-test-opcodes-180.asm \
	Test/Z80/G007_MON_source_recreation.asm \
	Test/Z80/ryan.asm







