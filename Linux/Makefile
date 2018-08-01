#############################################################################
# 	Makefile for building zasm
#############################################################################

# MACHINE: -m32 or -m64 or empty:
MACHINE		  = -m64

CC            = gcc
CXX           = g++
DEFINES       = -DNDEBUG -DQT_NO_DEBUG
CFLAGS        = -pipe -O2 -Wall -W -D_REENTRANT -fPIE $(DEFINES)
CXXFLAGS      = $(MACHINE) -pipe -Wno-multichar -O2 -std=c++11 -Wall -W -Wno-deprecated-declarations -D_REENTRANT -fPIE $(DEFINES)
INCPATH       = -I. -I.. -I../Source -I../Libraries
LINK          = g++
LFLAGS        = $(MACHINE) 
LIBS          = -lpthread -lz

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
		z80_clock_cycles.o \
		z80_major_opcode.o \
		z80_opcode_length.o \
		kio.o \
		WavFile.o \
		audio.o


TARGET        = zasm

first: 	all
all: 	Makefile $(TARGET)
clean:  
		rm *.o $(TARGET)

$(TARGET):  $(OBJECTS)
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(LIBS)


####### Compile

%.o : ../Source/%.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<
	
cstrings.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o cstrings.o ../Libraries/cstrings/cstrings.cpp

exceptions.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o exceptions.o ../Libraries/kio/exceptions.cpp

FD.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o FD.o ../Libraries/unix/FD.cpp

tempmem.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tempmem.o ../Libraries/unix/tempmem.cpp

files.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o files.o ../Libraries/unix/files.cpp

z80_clock_cycles.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_clock_cycles.o ../Libraries/Z80/goodies/z80_clock_cycles.cpp

z80_major_opcode.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_major_opcode.o ../Libraries/Z80/goodies/z80_major_opcode.cpp

z80_opcode_length.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_opcode_length.o ../Libraries/Z80/goodies/z80_opcode_length.cpp

kio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o kio.o ../Libraries/kio/kio.cpp

WavFile.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o WavFile.o ../Libraries/audio/WavFile.cpp

audio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o audio.o ../Libraries/audio/audio.cpp


