#############################################################################
# 	Makefile for building zasm
#############################################################################

TARGET        = zasm

CC            = clang
CXX           = clang++
DEFINES       = -DNDEBUG -DRELEASE
CFLAGS        = -pipe -O2 -Wall -W -fPIE $(DEFINES)
CXXFLAGS      = -pipe -Wno-multichar -O2 -std=c++0x -Wall -W -fPIE $(DEFINES)
INCPATH       = -I. -I.. -I../Source -I../Libraries
LINK          = clang++
LFLAGS        =
LIBS          = $(SUBLIBS) -lpthread

OBJECTS       = \
		Error.o \
		Label.o \
		main.o \
		Segment.o \
		Source.o \
		Z80Assembler.o \
		CharMap.o \
		helpers.o \
		outputfile.o \
		listfile.o \
		Z80Header.o \
		Macro.o \
		Value.o \
		zx7.o \
		SyntaxError.o \
		cstrings.o \
		exceptions.o \
		FD.o \
		tempmem.o \
		files.o \
		z180_clock_cycles.o \
		z80_clock_cycles.o \
		z80_major_opcode.o \
		z80_opcode_length.o \
		kio.o \
		WavFile.o \
		audio.o \
		convert8080.o


.PHONY:	all clean

all: 	$(TARGET)

clean:
		rm *.o $(TARGET)

$(TARGET):  $(OBJECTS)
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(OBJCOMP) $(LIBS)


####### Compile

%.o : Source/%.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

cstrings.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o cstrings.o Libraries/cstrings/cstrings.cpp

exceptions.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o exceptions.o Libraries/kio/exceptions.cpp

FD.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o FD.o Libraries/unix/FD.cpp

tempmem.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tempmem.o Libraries/cstrings/tempmem.cpp

files.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o files.o Libraries/unix/files.cpp

z180_clock_cycles.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z180_clock_cycles.o Libraries/Z80/goodies/z180_clock_cycles.cpp

z80_clock_cycles.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_clock_cycles.o Libraries/Z80/goodies/z80_clock_cycles.cpp

z80_major_opcode.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_major_opcode.o Libraries/Z80/goodies/z80_major_opcode.cpp

z80_opcode_length.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_opcode_length.o Libraries/Z80/goodies/z80_opcode_length.cpp

kio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o kio.o Libraries/kio/kio.cpp

WavFile.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o WavFile.o Libraries/audio/WavFile.cpp

audio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o audio.o Libraries/audio/audio.cpp
