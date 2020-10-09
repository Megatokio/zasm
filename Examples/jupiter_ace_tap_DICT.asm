; ================================================================
;   Source for target 'tap'
;   ZASM Tape file for Jupiter ACE - DICTIONARY files
;
;   Based on TAP file template for ZX Spectrum by kio@little-bat.de
;
;   Copyright (c) McKlaud 2020
;
;   Change log:
;
;   v.0.++ 2020-10-07 - naming, comments (kio)
;   v.0.2  2020-10-07 - spelling corrections and housekeeping
;   v.0.1  2020-10-01 - first release
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
;   load filename
;
; ================================================================

startadr        equ     $3C51           ; Start address for DICT files

CUR_LINK        equ     $3C49           ; Current WORD link (0x3C49 default value)

;------------------
; DICT file definition
;------------------
headerlength    equ     25              ; neither block type (flag byte) nor checksum byte included
DICT_type       equ     $00             ; 0x00 = DICT file type

;------------------
; Default values of system variables
;------------------
v_current       equ     $3C4C
v_context       equ     $3C4C
v_voclink       equ     $3C4F

;------------------
; Jupiter ACE ROM routines
;------------------
CLS             equ     $0A24           ; Clear Screen
PR_STRING2      equ     $097F           ; Print String. DE=String Address, BC=String Lenght

CF_DOCOLON      equ     $0EC3           ; DoColon
F_STK_WORD      equ     $1011           ; Stack next word
F_BASE          equ     $048A           ; BASE
F_CSTORE        equ     $08A5           ; C!
F_FORTHEND      equ     $04B6           ; End a FORTH word definition


#target TAP

; ----------------------------------------------------------------------
; TAP Header Block:

#code TAP_HEADER, 0, headerlength, flag=NONE

                defb    DICT_type       ; 1 byte:  File Type
                defb    "dict      "    ; 10 bytes: the file name
                ;       |----------|     <<< Keep it exactly 10 chars long!
                defw    DICT_DATA_size  ; 2 bytes: File Length
                defw    DICT_DATA       ; 2 bytes: Start Address
                defw    hex_lnk         ; 2 bytes: last WORD link field address
                defw    v_current       ; 2 bytes: CURRENT
                defw    v_context       ; 2 bytes: CONTEXT
                defw    v_voclink       ; 2 bytes: VOCLINK
                defw    DICT_DATA_end   ; 2 bytes: STKBOT


; ----------------------------------------------------------------------
; Data Block with DICT words:

#code DICT_DATA, startadr, *, flag=NONE

;------------------------------
; Word "HELLO"

; Forth Header:
hello_name      defb    "HELLO" + $80           ; WORD Name (last letter in inverse)
                defw    hex_lnk - hello_lnk   ; Word Length Field
                defw    CUR_LINK                ; Link Field
hello_lnk       defb    $ - hello_name - 4      ; Name Length Field
                defw    $ + 2                   ; Code Field Address

; Z80 asm code:
                call    CLS                     ; call 'CLS' from ROM
                ld      de,text1
                ld      bc,Ltext1
                call    PR_STRING2              ; call "PRINT STRING"
                jp      (iy)                    ; return to FORTH

text1           defb    "H E L L O",13,13       ; message to be printed
Ltext1          equ     $-text1
hello_end       equ     $

;------------------------------
; Word "HEX"

; Forth Header:
hex_name        defb    "HEX" + $80           ; WORD Name (last letter inverse)
                defw    hex_end - $           ; Word Length Field
                defw    hello_lnk             ; Link Field
hex_lnk         defb    $ - hex_name - 4      ; Name Lenght Field
                defw    CF_DOCOLON            ; Code Field Address

; OCT code is listable and editable in FORTH:
                defw    F_STK_WORD            ; Push next word (2 bytes) on the stack
                defw    16                    ;
                defw    F_BASE                ; BASE
                defw    F_CSTORE              ; C!
                defw    F_FORTHEND            ; End of new word definition
hex_end         equ     $

; -----------------------------
; Next word header & code ...


; -----------------------------
endadr          equ     $

#end

