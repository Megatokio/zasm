

; ---------------------------------------------------------------
;                   THE SYSTEM VARIABLES
; Source: ZX81 BASIC Programming by Steven Vickers, (c) Sinclair Research Limited
; ---------------------------------------------------------------


; #target p, 81 or p81:
; The first 9 bytes are actually not stored in the tape file.
; Copy&paste them in a #data segment starting at $4000 to define names for them so you can easily refer to them.
; The following sysvar bytes are actually stored in the tape file.
; Copy&paste them into a #code segment starting at $4009 and fill in proper values.
;
; #target z80:
; All sysvar bytes are actually stored in the snapshot file.
; Copy&paste the sysvar definitions into a #code segment starting at $4000 and fill in proper values.


; Memory Map
; ----------
; $407D - (D_FILE)      Basic Program
; (D_FILE) - (VARS)     Display File (Screen)
; (VARS) - (E_LINE)     Basic Variables; last byte at (E_LINE)-1 = $80
; (E_LINE) - (STKBOT)   Line being typed and work space
; (STKBOT) - (STKEND)   Calculator Stack
; (STKEND) - (ERR_SP)   Spare space and Z80 Machine Stack (sp)
; (ERR_SP) - (RAMTOP)   Gosub Stack
; (RAMTOP)              End of memory (address of last byte (incl.))



; SYSVARS $4000 - $4008 (not saved in a tape file)
;
;#data SYSVARS_NOT_SAVED, $4000, 9
;#code SYSVARS_NOT_SAVED, $4000, 9

ERR_NR  db  0   ; 1 less than the report code. Starts off at 255 (for -1), so PEEK 16384, if it works at all, gives 255.
                ; POKE 16384,n can be used to force an error halt: 0 … 14 gives one of the usual reports,
                ; 15 … 34 or 99 … 127 gives a nonstandard report, and 35 … 98 is likely to mess up the display file.
FLAGS   db  0   ; Various flags to control the BASIC system.
ERR_SP  dw  0   ; Address of first item on machine stack (after GOSUB returns).
RAMTOP  dw  0   ; Address of first byte above BASIC system area. You can poke this to make NEW reserve space above that area
                ; (see Chapter 26) or to fool CLS into setting up a minimal display file.
                ; Poking RAMTOP has no effect until one of these two is executed.
MODE    db  0   ; Specifies K, L, F or G cursor.
PPC     dw  0   ; Line number of statement currently being executed.
                ; Poking this has no lasting effect except in the last line of the program.



; SYSVARS $4009 - $403B
;
;#code SYSVARS, $4009, $407D-$4009

VERSN:  db  0   ; 0 identifies 8K ZX81 Basic in saved programs.
E_PPC:  dw  0   ; Number of current line (with program cursor).
D_FILE: dw  0   ; Address of Display File (screen data) in memory.
DF_CC:  dw  0   ; Address of PRINT position in display file. Can be poked so that PRINT output is sent elsewhere.
VARS:   dw  0   ; Address of user program variables in memory.
DEST:   dw  0   ; Address of variable in assignment.
E_LINE: dw  0   ; Address of line being editted in memory.
CH_ADD: dw  0   ; Address of the next character to be interpreted: the character after the argument of PEEK,
                ; or the ENTER/NEWLINE at the end of a POKE statement.
X_PTR:  dw  0   ; Address of the character preceding the [S] marker.
STKBOT: dw  0   ; Address of the Calculator stack in memory. This is where Basic does the math calculations.
STKEND: dw  0   ; End of the Calculator stack.
BREG:   db  0   ; Calculator’s b register.
MEM:    dw  0   ; Address of area used for calculator’s memory. (Usually MEMBOT but not always.)
        db  0   ; not used
DF_SZ:  db  0   ; The number of lines (including one blank line) in the lower part of the screen.
S_TOP:  dw  0   ; The number of the top program line in automatic listings.
LAST_K: dw  0   ; Shows which keys pressed
        db  0   ; Debounce status of keyboard.
MARGIN: db  0   ; Number of blank lines above or below picture: 55 in Britain (50Hz), 31 in America (60Hz).
NXTLIN: dw  0   ; Address of next program line to be executed.
OLDPPC: dw  0   ; Line number to which CONT jumps.
FLAGX:  db  0   ; Various flags.
STRLEN: dw  0   ; Length of string type designation in assignment.
T_ADDR: dw  0   ; Address of next item in syntax table (very unlikely to be useful).
SEED:   dw  0   ; The seed for RND. This is the variable that is set by RAND.
FRAMES: dw  0   ; Counts the frames displayed on the television. Bit 15 is 1. Bits 0 to 14 are decremented for each frame
                ; sent to the television. This can be used for timing, but PAUSE also uses it. PAUSE resets bit 15 to 0 and
                ; puts in bits 0 to 14 the length of the pause. When these have been counted down to zero, the pause stops.
                ; If the pause stops because of a key depression, bit 15 is set to 1 again.
COORDS: db  0   ; x-coordinate of last pointed PLOTted.
        db  0   ; y-coordinate of last pointed PLOTted.
PR_CC:  db  0   ; Less significant byte of address of next position for LPRINT to print at (in PRBUFF).
S_POSN: db  0   ; Column number for PRINT position.
        db  0   ; Line number for PRINT position.
CDFLAG: db  0   ; Various flags. Bit 7 is on (1) during compute and display (SLOW) mode.
PRBUFF: ds  33  ; Printer buffer (33rd character is ENTER/NEWLINE).
MEMBOT: ds  30  ; Calculator’s memory area; used to store numbers that cannot conveniently be put on the calculator stack.
        dw  0   ; not used
















