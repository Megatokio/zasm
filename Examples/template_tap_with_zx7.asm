

; Example for a ZX Spectrum .tap file
; which uses Einar Sauka's ZX7 compression


#target tap

; tape block sync bytes:
headerflag:     equ     0
dataflag:       equ     0xff

; some Basic tokens:
tCLEAR          equ     $FD             ; token CLEAR
tLOAD           equ     $EF             ; token LOAD
tCODE           equ     $AF             ; token CODE
tRANDOMIZE      equ     $F9             ; token RANDOMIZE
tUSR            equ     $C0             ; token USR

; memory layout:
load_address    equ     $7700           ; load code block here
code_address    equ     $8000           ; where it is decompressed/moved to
code_size       equ     CODE_csize+ZX7_size  ; size of code block on tape
start_address   equ     decompress      ; mcode start address



; ---------------------------------------------------
;       a Basic Loader:
; ---------------------------------------------------

#code PROG_HEADER,0,17,headerflag
        db      0                       ; Indicates a Basic program
        db      "mloader   "            ; the block name, 10 bytes long
        dw      variables_end-0         ; length of block = length of basic program plus variables
        dw      10                      ; line number for auto-start, 0x8000 if none
        dw      program_end-0           ; length of the basic program without variables

#code PROG_DATA,0,*,dataflag

  ; 10 CLEAR load_address-1
        db      0,10                    ; line number
        db      end10-($+1)             ; line length
        db      0                       ; statement number
        db      tCLEAR                  ; token CLEAR
        db      "0", $0e0000 \ dw load_address-1 \ db 0   ; number: ascii & internal format
end10:  db      $0d                     ; line end marker

  ; 20 LOAD "" CODE
        db      0,20                    ; line number
        db      end20-($+1)             ; line length
        db      0                       ; statement number
        db      tLOAD, '""', tCODE      ; token LOAD, 2 quotes, token CODE
end20:  db      $0d                     ; line end marker

  ; 30 RANDOMIZE USR start_address
        db      0,30                    ; line number
        db      end30-($+1)             ; line length
        db      0                       ; statement number
        db      tRANDOMIZE, tUSR        ; token RANDOMIZE, token USR
        db      "0", $0e0000 \ dw start_address \ db 0   ; number: ascii & internal format
end30:  db      $0d                     ; line end marker

program_end:

        ; ZX Spectrum Basic variables

variables_end:



; ---------------------------------------------------
;       The machine code block:
; ---------------------------------------------------

#code CODE_HEADER, 0, 17, headerflag
        db      3                       ; Indicates binary data
        db      "mcode     "            ; the block name, 10 bytes long
        dw      code_size               ; length of data block which follows
        dw      load_address            ; loading location for the data
        dw      0                       ; unused

#code CODE_DATA, 0, 0, dataflag

; Machine Code and Data:
; note: all following #code blocks are appended to #code CODE_DATA

; ________________________________
; memory layout:

#code   CODE, code_address              ; loaded at load_address, but we assemble for code_address
#code   ZX7,  load_address+CODE_csize   ; assembled for load_address
#compress CODE

; note:
; #code CODE, …         => zasm defines labels CODE (start address), CODE_size and CODE_end
; #code ZX7, …          => zasm defines labels ZX7 (start address), ZX7_size and ZX7_end
; #compress CODE        => zasm defines labels CODE_csize, CODE_cgain and CODE_cdelta

; ________________________________
; boot code:

#code ZX7
decompress:
        ld      hl, start               ; set return address for decompress
        push    hl
        ld      hl, load_address        ; source
        ld      de, code_address        ; dest
#include "decompress_zx7_standard.s"    ; include decompressor

; ________________________________
; our program:

#code CODE
start:
; set print channel to Screen:
        ld      a,2
        call    $1601

; print a message:
        ld      hl,msg
1$      ld      a,(hl)
        and     a
        ret     z
        inc     hl
        rst     2
        jr      1$

.rept 50        ;1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2
        dm      $39459456285624875646587AFFE4101545974619594506195665192365719234 ; 32
        dm      $7343526521234134867955453123534578287471134279908153565513143805 ; 64
        dm      $37276453624F0094576287645676a67d66f786786f5f45f4575f45c454a4a54c ; 96
        dm      $7a3d4f3e5b2c6a522e1a2C0DEe34a86c795a545b3123a5344567889287561734 ; 128
.endm

msg:    dm      13, "Hello World!"
        dm      13
        dm      13, "This is a message from the"
        dm      13, "compressed world of ZX7"
        dm      13
        dm      13, "creation date: ",__date__,0



; size of tape blocks in .tap file:
BLK1SZ     equ  4 + PROG_HEADER_size
BLK2SZ     equ  4 + PROG_DATA_size
BLK3SZ     equ  4 + CODE_HEADER_size
BLK4SZ     equ  4 + code_size
tape_size  equ  BLK1SZ + BLK2SZ + BLK3SZ + BLK4SZ




