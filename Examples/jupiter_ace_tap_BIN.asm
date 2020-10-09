; ================================================================
;   Source for target 'tap'
;   ZASM Tape file for Jupiter ACE - BINARY files
;
;   Based on TAP file template for ZX Spectrum by kio@little-bat.de
;
;   Copyright (c) McKlaud 2020
;
;   Change log:
;
;   v.0.++ 2020-10-07  naming, comments (kio)
;   v.0.2  2020-10-07  spelling corrections and housekeeping
;   v.0.1  2020-10-01  first release
;
; ================================================================
;
; #CODE has an additional argument: the block type (flag byte) for the block.
; The flag byte in #CODE must be set to NONE for Jupiter ACE tape files.
; Default fill byte in 'defs' is 0x00.
;
; ================================================================
;
; Load with:
;   0 0 bload binary
;
; Run the code with:
;   16000 call
;
; ================================================================

startadr        equ     $3E80           ; Start address for BIN files; e.g. 16000

;------------------
; BIN file definition
;------------------
headerlength    equ     25              ; neither block type (flag byte) nor CRC byte included
BIN_type        equ     $20             ; 0x20 = BINARY file type

;------------------
; Default values of system variables
;------------------
v_c_link        equ     $2020
v_current       equ     $2020
v_context       equ     $2020
v_voclink       equ     $2020
v_stkbot        equ     $2020

;------------------
; ROM routines
;------------------
CLS             equ     $0A24           ; Clear Screen



#target TAP

; ----------------------------------------------------------------------
; TAP Header Block:

#code HEADER_BLOCK, 0, headerlength, flag=NONE

                defb    BIN_type        ; 1 byte:  File Type
                defb    "binary    "    ; 10 bytes: the file name
                ;       |----------|     <<< Keep it exactly 10 chars long!
                defw    CODE_BLOCK_size ; 2 bytes: File Length
                defw    startadr        ; 2 bytes: Start Address
                defw    v_c_link        ; 2 bytes: current word link (NOT USED)
                defw    v_current       ; 2 bytes: CURRENT (NOT USED)
                defw    v_context       ; 2 bytes: CONTEXT (NOT USED)
                defw    v_voclink       ; 2 bytes: VOCLINK (NOT USED)
                defw    v_stkbot        ; 2 bytes: STKBOT (NOT USED)


; ----------------------------------------------------------------------
; TAP Data Block:

#code CODE_BLOCK, startadr, *, flag=NONE

;--------------------------------------
; Z80 asm code starting at 'startadr':

                call    CLS            ; call 'CLS' in ROM
                call    s_print        ; call 's_print' - print a string
                defb    13             ; print CR to screen
                defb    "Hello ..."    ; start message
                defb    13,0           ; print CR to screen + end marker
                jp      (iy)           ; return to forth

;--------------------------------------
; s_print - procedure
;
; Print string message by SPT (2006)
; text message must be placed after the call to 's_print',
; and end with a 0 byte marker.
;
; entry: none
; exit: none

s_print         pop     hl             ; retrieve return address
                ld      a,(hl)         ; into hl
                inc     hl             ; increase by 1
                push    hl             ; store address
                and     a              ; does hold 0
                ret     z              ; if so, z flag set and return
                rst     $08            ; print contents in A reg
                jr      s_print        ; repeat until end marker 0 is found
                ret                    ; return

;--------------------------------------
endadr          equ     $

#end


