#!/usr/local/bin/zasm -o original/
; ================================================================
;	Example source with target 'p' or '81'
;	ZX81 tape file / snapshot
;	Copyright  (c)	Günter Woigk 1994 - 2015
;					mailto:kio@little-bat.de
; ================================================================



; #target p  /  #target 81
;
; "p" and "81" files are the same and used when saving ZX81 programs.
; The file consist of the raw ram data as saved by the ZX81 tape saving routine WITHOUT the filename.
; The file can only store one program, not a whole tape with multiple programs.
; The data is save from and loaded back to address $4009++.
;
; #target p81
;
; ".p81" files consist of the raw data as saved by the ZX81 tape saving routine INCLUDING the filename.
; This format can store multiple programs.
; "p81" files are like "p" and "81" files preceded with the program's name.
; The file start with the 1..127 bytes filename, last byte ORed with $80,
; which is exactly what is actually saved by the ZX81 tape saving routine.
;
; --------------------------------------------------------------------
; A ZX81 program is stored like this on a real audio tape:
;
; 	x seconds    video noise
; 	5 seconds    silence
; 	1-127 bytes  filename (bit 7 set in last char)
; 	LEN bytes    data, loaded to address $4009, LEN = ($4014)-$4009.
; 	1 pulse      video retrace signal if display was enabled
; 	x seconds    silence / video noise
;
; --------------------------------------------------------------------
; Notes:
; 	The data contains system area, basic program, video memory, VARS.
; 	the last byte of a (clean) file should be $80 (the last byte of VARS)
;
; 	$4014	defines the end address (used to calculate the file length)
; 	$4029	points to the next executed (autostarted) BASIC line
; 	$403B	indicates if program runs in SLOW or FAST mode (bit 6)
; 	$403C++	may be misused for whatever purpose,
; 	video memory must contain 25 HALT opcodes if the file was saved in SLOW mode.
;
; 	While loading, the data at address $4014/4015 (E_LINE) is overwritten. After this they contain
; 	the real data end address of the data loaded and define when loading will stop. :-)
;
; 	Files should usually not exceed 16 kBytes.
; 	The memory detection procedure in both ZX80 and ZX81 stops after 16 kBytes (at $8000)
;
;
; ---------------------------------------------------------------
; 					Character Set
; ---------------------------------------------------------------
;
; $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F
; spc gra gra gra gra gra gra gra gra gra gra  "   £   $   :   ?
;
; $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F
;  (   )   >   <   =   +   -   *   /   ;   ,   .   0   1   2   3
;
; $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F
;  4   5   6   7   8   9   A   B   C   D   E   F   G   H   I   J
;
; $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F
;  K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z
;
;
; ---------------------------------------------------------------
; 					Memory Map
; ---------------------------------------------------------------
;
; 16509 - (D_FILE)		Basic Program
; (D_FILE) - (VARS)		Display File (Screen)
; (VARS) - (E_LINE)		Basic Variables; last byte at (E_LINE)-1 = $80
; (E_LINE) - (STKBOT)	Line being typed and work space
; (STKBOT) - (STKEND)	Calculator Stack
; (STKEND) - (ERR_SP)	Spare space and Z80 Machine Stack (sp)
; (ERR_SP) - (RAMTOP)	Gosub Stack
; (RAMTOP)				End of memory (address of last byte (incl.))
;
; value of RAMTOP:
;	$43FF = 17407 For 1k internal ram (ZX81)
;	$47FF = 18431 For 2k internal ram (TS1000)
;	$7fff = 32767 for 16k Ram Pack
;	$bfff = 49151 for 32k Ram Pack
;	$ffff = 65535 for 64k Ram Pack




;#target p
;#target 81
#target p81
#charset ZX81


; only if target p81:
#if target(p81)
#code	_PROGNAME
	dm	"PROGNAME" | $80	; this will be translated by zasm into the ZX81 character set!
#endif


; ---------------------------------------------------------------
; 					THE SYSTEM VARIABLES
; Source: ZX81 BASIC Programming by Steven Vickers, (c) Sinclair Research Limited
; ---------------------------------------------------------------
;
; SYSVARS $4000 - $4008 which are not saved to tape by the ZX81:
;
#data SYSVARS_NOT_SAVED, $4000, 9
;
ERR_NR 	db	0		; 4000		1 less than the report code. Starts off at 255 (for -1), so PEEK 16384, if it works at all, gives 255.
 					; 		 	POKE 16384,n can be used to force an error halt: 0 … 14 gives one of the usual reports,
 					; 		 	15 … 34 or 99 … 127 gives a nonstandard report, and 35 … 98 is likely to mess up the display file.
FLAGS	db	0		; 4001	X	Various flags to control the BASIC system.
ERR_SP	dw	0		; 4002	X	Address of first item on machine stack (after GOSUB returns).
RAMTOP	dw	0		; 4004		Address of first byte above BASIC system area. You can poke this to make NEW reserve space above that area
 					; 			(see Chapter 26) or to fool CLS into setting up a minimal display file.
					; 			Poking RAMTOP has no effect until one of these two is executed.
MODE	db	0		; 4006	N	Specifies K, L, F or G cursor.
PPC 	dw	0		; 4007	N	Line number of statement currently being executed.
 					; 			Poking this has no lasting effect except in the last line of the program.


; SYSVARS $4009 - $403B which are saved in the tape file:
;
#code SYSVARS, $4009, $407D-$4009
;
VERSN	db	0		; 4009		0 identifies 8K ZX81 Basic in saved programs.
E_PPC	dw	0		; 400A		Number of current line (with program cursor).
D_FILE	dw	_DFILE	; 400C	X	Address of Display File (screen data) in memory.
DF_CC	dw	0		; 400E		Address of PRINT position in display file. Can be poked so that PRINT output is sent elsewhere.
VARS	dw	_VARS	; 4010	X	Address of user program variables in memory.
DEST	dw	0		; 4012	N	Address of variable in assignment.
E_LINE	dw	_E_LINE	; 4014	X	Address of line being edited in memory.
CH_ADD	dw	0		; 4016	X	Address of the next character to be interpreted: the character after the argument of PEEK,
					; 			or the ENTER/NEWLINE at the end of a POKE statement.
X_PTR	dw	0		; 4018		Address of the character preceding the [S] marker.
STKBOT	dw	0		; 401A	X	Address of the Calculator stack in memory. This is where Basic does the math calculations.
STKEND	dw	0		; 401C	X	End of the Calculator stack.
BREG	db	0		; 401E	N	Calculator’s b register.
MEM		dw	0		; 401F	N	Address of area used for calculator’s memory. (Usually MEMBOT but not always.)
		db	0		; 4021		not used
DF_SZ	db	0		; 4022	X	The number of lines (including one blank line) in the lower part of the screen.
S_TOP	dw	0		; 4023		The number of the top program line in automatic listings.
LAST_K	dw	0		; 4025	N	Shows which keys pressed
		db	0		; 4027	N	Debounce status of keyboard.
MARGIN	db	0		; 4028	N	Number of blank lines above or below picture: 55 in Britain (50Hz), 31 in America (60Hz).
NXTLIN	dw	0		; 4029	X	Address of next program line to be executed.
OLDPPC	dw	0		; 402B		Line number to which CONT jumps.
FLAGX	db	0		; 402D	N	Various flags.
STRLEN	dw	0		; 402E	N	Length of string type designation in assignment.
T_ADDR	dw	0		; 4030	N	Address of next item in syntax table.
SEED	dw	0		; 4032		The seed for RND. This is the variable that is set by RAND.
FRAMES	dw	$8000	; 4034		Counts the frames displayed on the television. Bit 15 is 1. Bits 0 to 14 are decremented for each frame
					; 			sent to the television. This can be used for timing, but PAUSE also uses it. PAUSE resets bit 15 to 0 and
					; 			puts in bits 0 to 14 the length of the pause. When these have been counted down to zero, the pause stops.
					; 			If the pause stops because of a key depression, bit 15 is set to 1 again.
COORDS	db	0		; 4036		x-coordinate of last pointed PLOTted.
		db	0		; 4037		y-coordinate of last pointed PLOTted.
PR_CC	db	0		; 4038		Less significant byte of address of next position for LPRINT to print at (in PRBUFF).
S_POSN	db	0		; 4039	X	Column number for PRINT position.
		db	0		; 403A	X	Line number for PRINT position.
CDFLAG	db	$80		; 403B		Various flags. Bit 7 is set during compute and display (SLOW) mode.
PRBUFF	ds	33		; 403C		Printer buffer (33rd character is ENTER/NEWLINE).
MEMBOT	ds	30		; 405D	N	Calculator’s memory area; used to store numbers that cannot conveniently be put on the calculator stack.
		dw	0		; 407B		not used

					;		X = The variable should not be poked because the system might crash. 
					;		N = Poking the variable will have no lasting effect. 
					
#assert $ == $407D		


; --------------------------------------
; BASIC code and variables, Machine code
; --------------------------------------

#code _BASIC

	; add code for Basic starter here
	; add basic program and/or machine code here
	; The machine code must be hidden somehow in the basic program or in the variables


#code _DFILE

	; if saved in slow mode (CDFLAG bit 7 set) the display file must contain valid data

#if 0
	; collapsed dfile:
		ds	25, opcode(halt)

#else
	; inflated dfile:
		db	opcode(halt)
		rept 24
			ds	32,' '			; note: or use $00: ' ' is charset translated to $00 by zasm
			db	opcode(halt)
		endm
#endif


#code _VARS

	; add basic variables and/or machine code here
	; if less than 16k are installed then the variables will be moved up and down
	; as text is printed to the screen!

		db	$80		; end-of-variables indicator


_E_LINE:

	; unsaved areas:
	; (E_LINE) - (STKBOT)	Line being typed and work space
	; (STKBOT) - (STKEND)	Calculator Stack
	; (STKEND) - (ERR_SP)	Spare space and Z80 Machine Stack (sp)
	; (ERR_SP) - (RAMTOP)	Gosub Stack
	; (RAMTOP)				End of memory (address of last byte (incl.))

#end










