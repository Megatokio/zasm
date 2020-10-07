#!/usr/local/bin/zasm -o original/
#target TAP

CUR_LINK        equ     $3C49           ; <- Set LINK here!!!
;
startadr        equ     $3C51           ; Start address for dict files
;                org     startadr - 30   ; Make room for the file header

blktype         equ     $00             ; 0x00 for DICT file or 0x20 for BIN file
headerlength    equ     25              ; no CRC byte included

headerflag      equ     $00
dataflag        equ     $FF

;------------------
; Default values of system variables
;------------------
v_current       equ     $3C4C
v_context       equ     $3C4C
v_voclink       equ     $3C4F

;------------------
; ROM routines
;------------------
CLS             equ     $0A24         ; Clear Screen
PR_STRING2      equ     $097F         ; Print String. DE=String Address, BC=String Lenght

#code DICT_HEADER, 0, headerlength-1, FLAG=NONE

                defb    "hello     "    ; the block name, 10 bytes long
;                       |----------|     <<< Keep it exactly 10 chars long!
                defw    DICT_HEADER_end - DICT_DATA         ; length of block = length of basic program plus variables
                defw    startadr
                defw    CUR_LINK
                defw    v_current
                defw    v_context
                defw    v_voclink
                defw    word2_end

datablk

; DICT word here
#code DICT_DATA, 0, *, none
;------------------------------
; FORTH dictionary WORD header

word1_name      defb    "TEXT1" + $80 ; Word Name (last letter inverse)
                defw    word2_lnk - word1_lnk         ; Word Lenght Field
                defw    CUR_LINK               ; Link Field
word1_lnk       defb    $ - word1_name - 4    ; Name Lenght Field
                defw    $ + 2                ; Code Field Address

;------------------------------
; --- WORD code ---

                call    CLS                   ; call 'CLS' from ROM
                ld      de,text1
                ld      bc,Ltext1
                call    PR_STRING2            ; call "PRINT STRING"

                jp      (iy)                    ; return to FORTH

text1           defb    "Text",13,13
                defb    "1 . . ."
Ltext1          equ     $-text1

word1_end

word2_name      defb    "TEXT2" + $80 ; Word Name (last letter inverse)
                defw    word2_end - $         ; Word Lenght Field
                defw    word1_lnk                ; Link Field
word2_lnk       defb    $ - word2_name - 4    ; Name Lenght Field
                defw    $ + 2                ; Code Field Address

;------------------------------
; --- WORD code ---

                call    CLS                   ; call 'CLS' from ROM
                ld      de,text1
                ld      bc,Ltext1
                call    PR_STRING2            ; call "PRINT STRING"

                jp      (iy)                    ; return to FORTH

text2           defb    "Text",13,13
                defb    "2 . . ."
Ltext2          equ     $-text2

word2_end

code_end
