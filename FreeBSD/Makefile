#############################################################################
# 	Makefile for building zasm
#############################################################################

CC            = clang
CXX           = clang++
DEFINES       = -DNDEBUG -DQT_NO_DEBUG
CFLAGS        = -pipe -O2 -Wall -W -D_REENTRANT -fPIE $(DEFINES)
CXXFLAGS      = -pipe -Wno-multichar -O2 -std=c++0x -Wall -W -D_REENTRANT -fPIE $(DEFINES)
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
		cstrings.o \
		exceptions.o \
		errors.o \
		log.o \
		FD.o \
		tempmem.o \
		files.o \
		z80_clock_cycles.o \
		z80_major_opcode.o \
		z80_opcode_length.o


TARGET        = zasm

first: 	all
all: 	Makefile $(TARGET)

$(TARGET):  $(OBJECTS)  
	$(LINK) $(LFLAGS) -o $(TARGET) $(OBJECTS) $(OBJCOMP) $(LIBS)

	
####### Compile

Error.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Error.o ../Source/Error.cpp

Label.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Label.o ../Source/Label.cpp

main.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o main.o ../Source/main.cpp

Segment.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Segment.o ../Source/Segment.cpp

Source.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Source.o ../Source/Source.cpp

Z80Assembler.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Z80Assembler.o ../Source/Z80Assembler.cpp

CharMap.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o CharMap.o ../Source/CharMap.cpp

helpers.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o helpers.o ../Source/helpers.cpp

outputfile.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o outputfile.o ../Source/outputfile.cpp

listfile.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o listfile.o ../Source/listfile.cpp

Z80Header.o:
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Z80Header.o ../Source/Z80Header.cpp

Macro.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o Macro.o ../Source/Macro.cpp

cstrings.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o cstrings.o ../Libraries/cstrings/cstrings.cpp

exceptions.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o exceptions.o ../Libraries/kio/exceptions.cpp

errors.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o errors.o ../Libraries/kio/errors.cpp

log.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o log.o ../Libraries/unix/log.cpp

FD.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o FD.o ../Libraries/unix/FD.cpp

tempmem.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o tempmem.o ../Libraries/cstrings/tempmem.cpp

files.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o files.o ../Libraries/unix/files.cpp

z80_clock_cycles.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_clock_cycles.o ../Libraries/Z80/goodies/z80_clock_cycles.cpp

z80_major_opcode.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_major_opcode.o ../Libraries/Z80/goodies/z80_major_opcode.cpp

z80_opcode_length.o: 
	$(CXX) -c $(CXXFLAGS) $(INCPATH) -o z80_opcode_length.o ../Libraries/Z80/goodies/z80_opcode_length.cpp



