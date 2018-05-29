; ================================================================
;	Example source with target 'o' or '80'
;	ZX80 tape file / snapshot
;	Copyright  (c)	Günter Woigk 1994 - 2015
;					mailto:kio@little-bat.de
; ================================================================


; "o" and "80" files are the same and used for saving ZX80 programs.
; The file consists of the raw ram data as saved by the ZX80 tape saving routine.
; The data is save from and loaded back to address $4000++.
; The file can only store one program, not a whole tape with multiple programs.
;
; ---------------------------------------------------------------
; Notes:
; 	ZX80 files do not have filenames
; 	ZX80 files cannot be autostarted.
; 	The data is loaded to address $4000++
; 	The data contains the whole system area, Basic program, and VARS.
; 	Video memory is NOT included in ZX80 files.
; 	the last byte of a (clean) file should be $80 (the last byte of VARS)
; 	The system area should contain proper data.
; 	$400A       (2 bytes) defines the data end address (used to calculate the file length).
; 	$4028++     may be misused for whatever purpose.
;
; 	While loading, the data at address $400A/400B is overwritten. After this they contain
; 	the real data end address of the data loaded and define when loading will stop. :-)
;
; 	Files should usually not exceed 16 kBytes.
; 	The memory detection procedure in both ZX80 and ZX81 stops after 16 kBytes (at $8000),
;
;
; ---------------------------------------------------------------
; 					The Character Set
; ---------------------------------------------------------------
;
; $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F
; spc  "  gra gra gra gra gra gra gra gra gra gra  £   $   :   ?
;
; $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F
;  (   )   -   +   *   /   =   >   <   ;   ,   .   0   1   2   3
;
; $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F
;  4   5   6   7   8   9   A   B   C   D   E   F   G   H   I   J
;
; $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F
;  K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z
;
; ---------------------------------------------------------------




#target o			; output file is saved with filename extension ".o"
;#target 80			; output file is saved with filename extension ".80"

#charset ZX80		; enable character set translation for strings and character literals



; ---------------------------------------------------------------
; 					THE SYSTEM VARIABLES
; ---------------------------------------------------------------
;
; Note: the names of the system variables are taken from the original Nine Tiles Assembly Listing.
; Example values are taken AS AN EXAMPLE ONLY from Breakout (Macronics, 1980)
;
#code SYSVARS, 0x4000, 0x28

ERR_NR	db	$FF		;  1  16384 $4000 IY+$00	One less than report code.
FLAGS	db	$04		; X1  16385 $4001 IY+$01	Various Flags to control BASIC System:
					;								7  1-Syntax off        0-Syntax on
					;								6  1-Numeric result    0-String result
					;								5  1-Evaluating function (not used)
					;								3  1-K cursor          0-L cursor
					;								2  1-K mode            0-L mode.
					;								0  1-No leading space  0-Leading space.
PPC		dw	$FFFE	;  2  16386 $4002 IY+$02	Line number of current line.
P_PTR	dw	$434A	; N2  16388 $4004 IY+$04	Position in RAM of [K] or [L] cursor.
E_PPC	dw	0		;  2  16390 $4006 IY+$06	Number of current line with [>] cursor.
VARS	dw	_VARS				; $4349	; X2  16392 $4008 IY+$08	Address of start of variables area.
E_LINE	dw	end_of_file			; $434A	; X2  16394 $400A IY+$0A	Address of start of Edit Line.
D_FILE	dw	end_of_file+2		; $434C	; X2  16396 $400C IY+$0C	Start of Display File.
DF_EA	dw	end_of_file+$242	; $458C	; X2  16398 $400E IY+$0E	Address of the start of lower screen.
DF_END	dw	end_of_file+$245	; $458F	; X2  16400 $4010 IY+$10	Display File End.

DF_SZ	db	2		; X1  16402 $4012 IY+$12	Number of lines in lower screen.
S_TOP	dw	0		;  2  16403 $4013 IY+$13	The number of first line on screen.
X_PTR	dw	0		;  2  16405 $4015 IY+$15	Address of the character preceding the [S] marker.
OLDPPC	dw	0		;  2  16407 $4017 IY+$17	Line number to which continue jumps.
FLAGX	db	0		; N1  16409 $4019 IY+$19	More flags:
					;								7  1-K mode            0-L mode.
					;								6  1-Numeric result    0-String result
					;								5  1-Inputting         0-Editing
T_ADDR	 dw	$07A2	; N2  16410 $401A IY+$1A	Address of next item in syntax table.
SEED	 dw	0		; U2  16412 $401C IY+$1C	The seed for the random number.
FRAMES	 dw	$7484	; U2  16414 $401E IY+$1E	Count of frames shown since start-up.
DEST	 dw	$4733	; N2  16416 $4020 IY+$20	Address of variable in statement.
RESULT	 dw	$3800	; N2  16418 $4022 IY+$22	Value of the last expression.
S_POSN_X db	$21		; X1  16420 $4024 IY+$24	Column number for print position.
S_POSN_Y db	$17		; X1  16421 $4025 IY+$25	Line number for print position.
CH_ADD	 dw	$FFFF	; X2  16422 $4026 IY+$26	Address of next character to be interpreted.

#assert $ == $4028


; --------------------------------------
; BASIC code and variables, Machine code
; --------------------------------------
;
#code _BASIC
#code _VARS
;#code _DFILE
; The ZX80 stopped writing to tape at E_LINE (the edit line).
; So neither the edit line nor the display file are stored in the tape file.


#code _BASIC

; add code for Basic starter here
; add basic program and/or machine code here
; The machine code must be hidden somehow in the basic program or in the variables


#code _VARS

; add basic variables and/or machine code here

	db	0x80		; end marker for basic variables
	
end_of_file:

#end




