#-------------------------------------------------
#
# Project created by QtCreator 2014-10-06T16:47:38
#
#-------------------------------------------------

TEMPLATE = app

QT       -= core
QT       -= gui

TARGET	= zasm
CONFIG += console
CONFIG -= app_bundle
CONFIG += c++11
CONFIG += precompiled_header
CONFIG(release,debug|release) { DEFINES += NDEBUG }
QMAKE_CXXFLAGS += -Wno-four-char-constants
QMAKE_CXXFLAGS += -Wno-multichar

LIBS += -lz

INCLUDEPATH +=          \
	./                  \
	Source              \
	Libraries           \

SOURCES += \
	Source/Error.cpp \
	Source/Label.cpp \
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
	Source/zx7.cpp \
	Libraries/cstrings/cstrings.cpp \
	Libraries/kio/exceptions.cpp \
	Libraries/kio/kio.cpp \
	Libraries/unix/FD.cpp \
	Libraries/cstrings/tempmem.cpp \
	Libraries/unix/files.cpp \
	Libraries/Z80/goodies/z80_clock_cycles.cpp \
	Libraries/Z80/goodies/z80_major_opcode.cpp \
	Libraries/Z80/goodies/z80_opcode_length.cpp \
	Libraries/audio/audio.cpp \
	Libraries/audio/WavFile.cpp

HEADERS += \
	Libraries/Templates/RCArray.h \
	Libraries/Templates/RCObject.h \
	Libraries/Templates/RCPtr.h \
	Libraries/Templates/relational_operators.h \
	Libraries/Templates/sort.h \
	Libraries/Templates/template_helpers.h \
	Source/Error.h \
	Source/Label.h \
	Source/Segment.h \
	Source/settings.h \
	Source/Source.h \
	Source/Value.h \
	Source/zx7.h \
	Source/SyntaxError.h \
	Source/Z80Assembler.h \
	Source/settings.h \
	Source/CharMap.h \
	Source/helpers.h \
	Source/Z80Header.h \
	Source/Macro.h \
	Source/SyntaxError.h \
	config.h \
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
	Libraries/Z80/goodies/z80_clock_cycles.h \
	Libraries/Z80/goodies/z80_major_opcode.h \
	Libraries/Z80/goodies/z80_major_opcode_tables.h \
	Libraries/Z80/goodies/z80_opcode_length.h \
	Libraries/Z80/goodies/z80_opcodes.h \
	Libraries/hash/sdbm_hash.h \
	Libraries/audio/audio.h \
	Libraries/audio/WavFile.h

OTHER_FILES += \
	../.gitignore \
	../sdcc/lib/___setjmp.s \
	../sdcc/lib/__divsint.s \
	../sdcc/lib/__divsuchar.s \
	../sdcc/lib/__divuint.s \
	../sdcc/lib/__divuschar.s \
	../sdcc/lib/__modsint.s \
	../sdcc/lib/__modsuchar.s \
	../sdcc/lib/__moduint.s \
	../sdcc/lib/__mulint.s \
	../sdcc/lib/__mulschar.s \
	../sdcc/lib/__sdcc_call_hl.s \
	../sdcc/lib/_localtime.s \
	../sdcc/lib/_memmove.s \
	../sdcc/lib/_putchar.s \
	../sdcc/lib/_strcpy.s \
	../sdcc/lib/_strlen.s \
	../sdcc/lib/crt0 .s \
	../sdcc/lib/heap .s \
	../sdcc/lib/___fs2schar.c \
	../sdcc/lib/___fs2sint.c \
	../sdcc/lib/___fs2slong.c \
	../sdcc/lib/___fs2uchar.c \
	../sdcc/lib/___fs2uint.c \
	../sdcc/lib/___fs2ulong.c \
	../sdcc/lib/___fsadd.c \
	../sdcc/lib/___fsdiv.c \
	../sdcc/lib/___fseq.c \
	../sdcc/lib/___fsgt.c \
	../sdcc/lib/___fslt.c \
	../sdcc/lib/___fsmul.c \
	../sdcc/lib/___fsneq.c \
	../sdcc/lib/___fssub.c \
	../sdcc/lib/___schar2fs.c \
	../sdcc/lib/___sint2fs.c \
	../sdcc/lib/___slong2fs.c \
	../sdcc/lib/___uchar2fs.c \
	../sdcc/lib/___uint2fs.c \
	../sdcc/lib/___ulong2fs.c \
	../sdcc/lib/__assert.c \
	../sdcc/lib/__divslong.c \
	../sdcc/lib/__divslonglong.c \
	../sdcc/lib/__divulong.c \
	../sdcc/lib/__divulonglong.c \
	../sdcc/lib/__itoa.c \
	../sdcc/lib/__modslong.c \
	../sdcc/lib/__modulong.c \
	../sdcc/lib/__mullong.c \
	../sdcc/lib/__mullonglong.c \
	../sdcc/lib/__print_format.c \
	../sdcc/lib/__rlslonglong.c \
	../sdcc/lib/__rlulonglong.c \
	../sdcc/lib/__rrslonglong.c \
	../sdcc/lib/__rrulonglong.c \
	../sdcc/lib/__uitoa.c \
	../sdcc/lib/_abs.c \
	../sdcc/lib/_acosf.c \
	../sdcc/lib/_asctime.c \
	../sdcc/lib/_asincosf.c \
	../sdcc/lib/_asinf.c \
	../sdcc/lib/_atan2f.c \
	../sdcc/lib/_atanf.c \
	../sdcc/lib/_atof.c \
	../sdcc/lib/_atoi.c \
	../sdcc/lib/_atol.c \
	../sdcc/lib/_calloc.c \
	../sdcc/lib/_ceilf.c \
	../sdcc/lib/_check_struct_tm.c \
	../sdcc/lib/_cosf.c \
	../sdcc/lib/_coshf.c \
	../sdcc/lib/_cotf.c \
	../sdcc/lib/_ctime.c \
	../sdcc/lib/_days_per_month.c \
	../sdcc/lib/_errno.c \
	../sdcc/lib/_expf.c \
	../sdcc/lib/_fabsf.c \
	../sdcc/lib/_floorf.c \
	../sdcc/lib/_free.c \
	../sdcc/lib/_frexpf.c \
	../sdcc/lib/_gets.c \
	../sdcc/lib/_gmtime.c \
	../sdcc/lib/_heap.c \
	../sdcc/lib/_isalnum.c \
	../sdcc/lib/_isalpha.c \
	../sdcc/lib/_isblank.c \
	../sdcc/lib/_iscntrl.c \
	../sdcc/lib/_isdigit.c \
	../sdcc/lib/_isgraph.c \
	../sdcc/lib/_islower.c \
	../sdcc/lib/_isprint.c \
	../sdcc/lib/_ispunct.c \
	../sdcc/lib/_isspace.c \
	../sdcc/lib/_isupper.c \
	../sdcc/lib/_isxdigit.c \
	../sdcc/lib/_labs.c \
	../sdcc/lib/_ldexpf.c \
	../sdcc/lib/_log10f.c \
	../sdcc/lib/_logf.c \
	../sdcc/lib/_ltoa.c \
	../sdcc/lib/_malloc.c \
	../sdcc/lib/_memchr.c \
	../sdcc/lib/_memcmp.c \
	../sdcc/lib/_memcpy.c \
	../sdcc/lib/_memset.c \
	../sdcc/lib/_mktime.c \
	../sdcc/lib/_modff.c \
	../sdcc/lib/_powf.c \
	../sdcc/lib/_printf_small.c \
	../sdcc/lib/_printf.c \
	../sdcc/lib/_put_char_to_stdout.c \
	../sdcc/lib/_put_char_to_string.c \
	../sdcc/lib/_puts.c \
	../sdcc/lib/_rand.c \
	../sdcc/lib/_realloc.c \
	../sdcc/lib/_sincosf.c \
	../sdcc/lib/_sincoshf.c \
	../sdcc/lib/_sinf.c \
	../sdcc/lib/_sinhf.c \
	../sdcc/lib/_sprintf.c \
	../sdcc/lib/_sqrtf.c \
	../sdcc/lib/_strcat.c \
	../sdcc/lib/_strchr.c \
	../sdcc/lib/_strcmp.c \
	../sdcc/lib/_strcspn.c \
	../sdcc/lib/_strncat.c \
	../sdcc/lib/_strncmp.c \
	../sdcc/lib/_strncpy.c \
	../sdcc/lib/_strpbrk.c \
	../sdcc/lib/_strrchr.c \
	../sdcc/lib/_strspn.c \
	../sdcc/lib/_strstr.c \
	../sdcc/lib/_strtok.c \
	../sdcc/lib/_strxfrm.c \
	../sdcc/lib/_tancotf.c \
	../sdcc/lib/_tanf.c \
	../sdcc/lib/_tanhf.c \
	../sdcc/lib/_time.c \
	../sdcc/lib/_tolower.c \
	../sdcc/lib/_toupper.c \
	../sdcc/lib/_vprintf.c \
	../sdcc/lib/_vsprintf.c \
	../sdcc/lib/_log_table.h \
	\
	../sdcc/include/asm/default/features.h \
	../sdcc/include/asm/z80/features.h \
	../sdcc/include/assert.h \
	../sdcc/include/ctype.h \
	../sdcc/include/errno.h \
	../sdcc/include/float.h \
	../sdcc/include/iso646.h \
	../sdcc/include/limits.h \
	../sdcc/include/malloc.h \
	../sdcc/include/math.h \
	../sdcc/include/sdcc-lib.h \
	../sdcc/include/setjmp.h \
	../sdcc/include/stdalign.h \
	../sdcc/include/stdarg.h \
	../sdcc/include/stdbool.h \
	../sdcc/include/stddef.h \
	../sdcc/include/stdint.h \
	../sdcc/include/stdio.h \
	../sdcc/include/stdlib.h \
	../sdcc/include/stdnoreturn.h \
	../sdcc/include/string.h \
	../sdcc/include/time.h \
	../sdcc/include/tinibios.h \
	../sdcc/include/typeof.h \
	\
	../sdcc/sdcc_info.txt \
	\
	../Examples/main.c \
	../Examples/globls.s \
	../Examples/jupiter_ace_character_ram.s \
	../Examples/jupiter_ace_sysvars.s \
	../Examples/zx80_sysvars.s \
	../Examples/zx81_sysvars.s \
	../Examples/zx_spectrum_basic_tokens.s \
	../Examples/zx_spectrum_sysvars.s \
	../Examples/zx_spectrum_io_rom.s \
	\
	../Examples/template_bin.asm \
	../Examples/template_minimal_rom.asm \
	../Examples/template_rom_with_c_code.asm \
	../Examples/template_o.asm \
	../Examples/template_p.asm \
	../Examples/template_rom.asm \
	../Examples/template_sna.asm \
	../Examples/template_tap.asm \
	../Examples/template_z80.asm \
	../Examples/template_ace.asm \
	\
	../Test/main.c \
	../Test/main.s \
	../Test/test-cc.asm \
	../Test/test-cc.lst \
	../Test/test.asm \
	../Test/test.lst \
	../Test/test-opcodes/test-opcodes.asm \
	../Test/test-opcodes/test-opcodes.lst \
	../Test/test-opcodes/test-opcodes-8080.asm \
	../Test/test-opcodes/test-opcodes-8080.lst \
	../Test/test-zx82rom/zx82rom.asm \
	../Test/test-zx82rom/zx82rom.lst \
	../Test/test-tap.asm \
	../Test/test-tap.lst \
	../Test/zx82_rom.asm \
	../Test/zx82_rom.lst \
	../Test/8080/Altair8800_Monitor.lst \
	../Test/8080/Altair8800_Monitor.asm \
	../Test/Z80/rept.asm \








