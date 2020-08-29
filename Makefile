#############################################################################
# 	Makefile for building zasm
#############################################################################


TARGET      = zasm

CC          = gcc
CXX         = g++
LINK        = g++
#CC          = clang
#CXX         = clang++
#LINK        = clang++
STRIP       = strip

DEFINES     = -DNDEBUG -DRELEASE

CFLAGS      = -pipe -Os -Wall -W -fPIE $(DEFINES)
CXXFLAGS    = $(CFLAGS) -Wno-multichar -std=c++11
INCPATH     = -I. -ISource -ILibraries
LFLAGS      =
LIBS        = -lpthread -lz

SRCS := $(wildcard Source/*.cpp)
OBJS := $(SRCS:Source/%.cpp=tmp/%.o)


OBJECTS = \
		tmp/cstrings.o \
		tmp/exceptions.o \
		tmp/FD.o \
		tmp/tempmem.o \
		tmp/files.o \
		tmp/z180_clock_cycles.o \
		tmp/z80_clock_cycles.o \
		tmp/z80_major_opcode.o \
		tmp/z80_opcode_length.o \
		tmp/kio.o \
		tmp/WavFile.o \
		tmp/audio.o \
		$(OBJS)


.PHONY:	all clean test

all: 	$(TARGET)

clean:
		rm tmp/*.o $(TARGET)

test:	$(TARGET)
		$(TARGET) -T

$(TARGET):  tmp/ Makefile $(OBJECTS)
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(LIBS)
	$(STRIP) $(TARGET)

tmp/:
	mkdir -p tmp


####### Compile

tmp/%.o : Source/%.cpp
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o $@ $<

tmp/cstrings.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/cstrings.o Libraries/cstrings/cstrings.cpp

tmp/exceptions.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/exceptions.o Libraries/kio/exceptions.cpp

tmp/FD.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/FD.o Libraries/unix/FD.cpp

tmp/tempmem.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/tempmem.o Libraries/cstrings/tempmem.cpp

tmp/files.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/files.o Libraries/unix/files.cpp

tmp/z180_clock_cycles.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/z180_clock_cycles.o Libraries/Z80/goodies/z180_clock_cycles.cpp

tmp/z80_clock_cycles.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/z80_clock_cycles.o Libraries/Z80/goodies/z80_clock_cycles.cpp

tmp/z80_major_opcode.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/z80_major_opcode.o Libraries/Z80/goodies/z80_major_opcode.cpp

tmp/z80_opcode_length.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/z80_opcode_length.o Libraries/Z80/goodies/z80_opcode_length.cpp

tmp/kio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/kio.o Libraries/kio/kio.cpp

tmp/WavFile.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/WavFile.o Libraries/audio/WavFile.cpp

tmp/audio.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tmp/audio.o Libraries/audio/audio.cpp


