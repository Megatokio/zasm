#!/usr/local/bin/zasm -o original/
; -----------------------------------------------------------------------------
; 64#4 - 4x8 FONT DRIVER FOR 64 COLUMNS (c) 2007, 2011
;
; Original by Andrew Owen (657 bytes)
; Optimized by Crisis (602 bytes)
; Reimplemented by Einar Saukas (494 bytes)

; pasmo -1 -v --tapbas 64#4+016.asm  64#4+016.tap 64#4+016.symbol
; -----------------------------------------------------------------------------

        org     16384            ; Screen invoked channel
	 	           	 ;[CHANGE HERE TO CHOOSE ANOTHER ADDRESS]

STR_NUM EQU     4               ; stream #4 [CHANGE HERE TO CHOOSE ANOTHER
                                ;   STREAM NUMBER]
leng	EQU	last - CH_DATA  ; length of 64#4 routine itself
leg	equ	leng-5
; -----------------------------------------------------------------------------
; CREATE CHANNEL AND ATTACH STREAM
; Based on code by Ian Beardsmore from Your Spectrum issue 7, September 1984.

        ld      hl, (0x5c53)    ; store system variable PROG in DE
        dec     hl
;ld de,CH_DATA
;ld (de),h
;inc de
;ld (de),l
;ex de,hl ; store PROG-1 into HL
        ld      bc, leng    ; allocate 5+leng bytes for channel below BASIC area
        push    bc
        call    0x1655          ; call the MAKE-ROOM routine
        pop     bc

        ld      hl, CH_DATA+leng-1
        lddr                    ; copy CH_DATA to new channel space
        ld      hl, (0x5c4f)    ; store system variable CHANS in HL
        ex      de, hl
        inc     hl
        inc     hl              ; now HL = allocated address + 1
        sbc     hl, de          ; calculate offset between start of channels
                                ;   area and start of the new channel space
                                ;   (notice the carry flag was already cleared
                                ;   from executing CALL 0x1655 earlier)
        ld      (STR_OFF), hl   ; attach stream by storing channel address
                                ;   offset in streams table
        ret

STR_OFF EQU 0x5c10+((STR_NUM+3)*2) ; address of channel offset in streams table
CH_DATA:
        defw    CH_ADDR         ; (dummy?) address of the PRINT # routine
        defw    0x15c4          ; address of the INPUT # routine
        defb    'S'             ; channel type 'S'
inbet  equ $
; -----------------------------------------------------------------------------
; CHANNEL WRAPPER FOR THE 64-COLUMN DISPLAY DRIVER
; Based on code by Tony Samuels from Your Spectrum issue 20, November 1985.

;org CH_ADDR	; <-- kio 2015-01-06: replaced with label definition
CH_ADDR:	; <-- not shure about this

;dump inbet
        ld      b, 0            ; save a few bytes later using B instead of 0
        ld      hl, AT_FLAG     ; initial address of local variables
        dec     (hl)            ; check AT_FLAG value by decrementing it
;---Changed by C.Born august 2014
        jr      z, GET_COL      ; expecting the AT column?
	bit 7,(hl)
	jr  nz, CHK_AT		; expecting a regular character?
;---- end change by C.Born august 2014

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE STANDARD INVERSE (use INVERSE 1 for inversed characters)
;
; #ifdef _STANDARD_INVERSE
;        dec     (hl)            ; check AT_FLAG value by decrementing it again
;        jr      nz, GET_ROW     ; expecting the AT row?
;        and     a               ; check INVERSE parameter
;        jr      z, SET_INV      ; specified INVERSE zero?
;        ld      a, 0x2f         ; opcode for 'CPL'
;SET_INV:
;        ld      (INV_C), a      ; either 'NOP' or 'CPL'
;        ret
; #endif _STANDARD_INVERSE
; -----------------------------------------------------------------------------

GET_ROW:
        cp      24              ; specified row greater than 23?
        jr      nc, ERROR_B     ; error if so
        inc     hl              ; dirty trick to store new row into AT_ROW
GET_COL:
        cp      64              ; specified column greater than 63?
        jr      nc, ERROR_B     ; error if so
        inc     hl
        ld      (hl), a         ; store new column into AT_COL
        ret

ERROR_B:
        ld      (hl), b         ; reset AT_FLAG
        rst     8               ; error "B Integer out of range"
        defb    10

CHK_AT:
        cp      0x16            ; specified keyword 'AT'?

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE STANDARD INVERSE (use INVERSE 1 for inversed characters)
;
; #ifdef _STANDARD_INVERSE
;        jr      nz, CHK_INV     ; continue otherwise
;        ld      (hl), 3         ; change AT_FLAG to expect row value next time
;        ret
;CHK_INV:
;        cp      0x14            ; specified keyword 'INVERSE'?
; #endif _STANDARD_INVERSE
; -----------------------------------------------------------------------------

        jr      nz, CHK_CR      ; continue otherwise
        ld      (hl), 2         ; change AT_FLAG to expect row value next time
        ret                     ;   (or to expect INVERSE parameter next time)

CHK_CR:
        inc     (hl)            ; increment AT_FLAG to restore previous value
        inc     hl              ; now HL references AT_COL address
        cp      0x0d            ; specified carriage return?
        jr      z, NEXT_ROW     ; change row if so

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE FAST COMMA (jump directly to next column multiple of 16)
;
; #ifdef _FAST_COMMA
;        cp      0x06            ; specified comma?
;        jr      nz, DRIVER      ; continue otherwise
;        ld      a, (hl)
;        or      0x0f            ; change column to destination minus 1
;        ld      (hl),a
;        jr      END_LOOP + 1    ; increment column and row if needed
; #endif _FAST_COMMA
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE STANDARD COMMA (print spaces until column multiple of 16)
;
; #ifdef _STANDARD_COMMA
;        cp      0x06            ; specified comma?
;        jr      nz, DRIVER      ; continue otherwise
;LOOP:   ld      a, 32           ; print space
;        call    DRIVER
;        ret     c               ; stop if row changed (reached column zero)
;        ld      a, (hl)
;        and     0x0f
;        ret     z               ; stop if reached column 16, 32 or 48
;        jr      LOOP            ; repeat otherwise
; #endif _STANDARD_COMMA
; -----------------------------------------------------------------------------

; -----------------------------------------------------------------------------
; 64-COLUMN DISPLAY DRIVER

DRIVER:

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE ZX81 INVERSE (add 128 to get inversed characters)
;
; #ifdef _ZX81_INVERSE
;        push    hl              ; save AT_COL address for later
;        ld      hl, INV_C
;        ld      (hl), b         ; opcode for 'NOP'
;        rla                     ; highest bit indicating inversed character?
;        jr      nc, SKIP_INV    ; skip otherwise
;        ld      (hl), 0x2f      ; opcode for 'CPL'
;SKIP_INV:
;        rrca                    ; restore character value without highest bit
;        pop     hl              ; restore AT_COL address
; #endif _ZX81_INVERSE
; -----------------------------------------------------------------------------

        push    hl              ; save AT_COL address for later
        ld      e, a            ; store character value in E
        ld      c, (hl)         ; store current column in BC

; Check if character font must be rotated, self-modifying the code accordingly

        xor     c               ; compare BIT 0 from character value and column
        rra
        ld      a, 256-(END_LOOP-SKIP_RLC) ; instruction DJNZ skipping rotation
        jr      nc, NOT_RLC             ; decide based on BIT 0 comparison
        ld      a, 256-(END_LOOP-INIT_RLC) ; instruction DJNZ using rotation
NOT_RLC:
        ld      (END_LOOP - 1), a       ; modify DJNZ instruction directly

; Check the half screen byte to be changed, self-modifying the code accordingly

        srl     c               ; check BIT 0 from current column
        ld      a, %00001111    ; mask to change left half of the screen byte
        jr      nc, SCR_LEFT    ; decide based on odd or even column
        cpl                     ; mask to change right half of the screen byte
SCR_LEFT:
        ld      (SCR_MASK + 1), a   ; modify screen mask value directly
        cpl
        ld      (FONT_MASK + 1), a  ; modify font mask value directly

; Calculate location of the first byte to be changed on screen
; The row value is a 5 bits value (0-23), here represented as %000RRrrr
; The column value is a 6 bits value (0-63), here represented as %00CCCCCc
; Formula: 0x4000 + ((row & 0x18) << 8) + ((row & 0x07) << 5) + (col >> 1)

        inc     hl              ; now HL references AT_ROW address
        ld      a, (hl)         ; now A = %000RRrrr
        call    0x0e9e          ; now HL = %010RR000rrr00000
        add     hl, bc          ; now HL = %010RR000rrrCCCCC
        ex      de, hl          ; now DE = %010RR000rrrCCCCC

; Calculate location of the character font data in FONT_ADDR
; Formula: FONT_ADDR + 7 * INT ((char-32)/2) - 1

        ld      h, b            ; now HL = char
        srl     l               ; now HL = INT (char/2)
        ld      c, l            ; now BC = INT (char/2)
        add     hl, hl          ; now HL = 2 * INT (char/2)
        add     hl, hl          ; now HL = 4 * INT (char/2)
        add     hl, hl          ; now HL = 8 * INT (char/2)
        sbc     hl, bc          ; now HL = 7 * INT (char/2)
        ld      bc, FONT_ADDR - 0x71
        add     hl, bc          ; now HL = FONT_ADDR + 7 * INT (char/2) - 0x71

; Main loop to copy 8 font bytes into screen (1 blank + 7 from font data)

        xor     a               ; first font byte is always blank
        ld      b, 8            ; execute loop 8 times
INIT_RLC:
        rlca                    ; switch position between bits 0-3 and bits 4-7
        rlca
        rlca
        rlca
SKIP_RLC:

; -----------------------------------------------------------------------------
; UNCOMMENT TO ENABLE EITHER STANDARD OR ZX81 INVERSE
;
; #ifdef _STANDARD_INVERSE || _ZX81_INVERSE
;INV_C:  nop                     ; either 'NOP' or 'CPL'
; #endif _STANDARD_INVERSE || _ZX81_INVERSE
; -----------------------------------------------------------------------------

FONT_MASK:
        and     %11110000       ; mask half of the font byte
        ld      c, a            ; store half of the font byte in C
        ld      a, (de)         ; get screen byte
SCR_MASK:
        and     %00001111       ; mask half of the screen byte
        or      c               ; combine half screen and half font
        ld      (de), a         ; write result back to screen
        inc     d               ; next screen location
        inc     hl              ; next font data location
        ld      a, (hl)         ; store next font byte in A
        djnz    INIT_RLC        ; repeat loop 8 times
END_LOOP:

        pop     hl              ; restore AT_COL address
        inc     (hl)            ; next column
        bit     6, (hl)         ; column lower than 64?
        ret     z               ; return if so
NEXT_ROW:
        ld      (hl), b         ; reset AT_COL
        inc     hl              ; store AT_ROW address in HL
        inc     (hl)            ; next row
        ld      a, (hl)
        cp      24              ; row lower than 23?
        ret     c               ; return if so
        ld      (hl), b         ; reset AT_ROW
        ret                     ; done!

; -----------------------------------------------------------------------------
; LOCAL VARIABLES

AT_FLAG:
        defb    0               ; flag to control processing keyword 'AT'
                                ;   value 2 if received 'AT', expecting row
                                ;   value 1 if received row, expecting column
                                ;   value 0 if expecting regular character
AT_COL:
        defb    0               ; current column position (0-31)
AT_ROW:
        defb    0               ; current row position (0-23)

; -----------------------------------------------------------------------------
; HALF WIDTH 4x8 FONT designed by Andrew Owen
; Top row is always zero and not stored (96 chars x 7 / 2 = 336 bytes)

FONT_ADDR:
        defb    0x02, 0x02, 0x02, 0x02, 0x00, 0x02, 0x00        ; !
        defb    0x52, 0x57, 0x02, 0x02, 0x07, 0x02, 0x00        ;"#
        defb    0x25, 0x71, 0x62, 0x32, 0x74, 0x25, 0x00        ;$%
        defb    0x22, 0x42, 0x20, 0x40, 0x50, 0x30, 0x00        ;&'
        defb    0x14, 0x22, 0x41, 0x41, 0x41, 0x22, 0x14        ;()
        defb    0x20, 0x70, 0x22, 0x57, 0x02, 0x00, 0x00        ;*+
        defb    0x00, 0x00, 0x00, 0x07, 0x00, 0x20, 0x20        ;,-
        defb    0x01, 0x01, 0x02, 0x02, 0x04, 0x24, 0x00        ;./
        defb    0x22, 0x56, 0x52, 0x52, 0x52, 0x27, 0x00        ;01
        defb    0x27, 0x51, 0x12, 0x21, 0x45, 0x72, 0x00        ;23
        defb    0x57, 0x54, 0x56, 0x71, 0x15, 0x12, 0x00        ;45
        defb    0x17, 0x21, 0x61, 0x52, 0x52, 0x22, 0x00        ;67
        defb    0x22, 0x55, 0x25, 0x53, 0x52, 0x24, 0x00        ;89
        defb    0x00, 0x00, 0x22, 0x00, 0x00, 0x22, 0x02        ;:;
        defb    0x00, 0x10, 0x27, 0x40, 0x27, 0x10, 0x00        ;<=
        defb    0x02, 0x45, 0x21, 0x12, 0x20, 0x42, 0x00        ;>?
        defb    0x23, 0x55, 0x75, 0x77, 0x45, 0x35, 0x00        ;@A
        defb    0x63, 0x54, 0x64, 0x54, 0x54, 0x63, 0x00        ;BC
        defb    0x67, 0x54, 0x56, 0x54, 0x54, 0x67, 0x00        ;DE
        defb    0x73, 0x44, 0x64, 0x45, 0x45, 0x43, 0x00        ;FG
        defb    0x57, 0x52, 0x72, 0x52, 0x52, 0x57, 0x00        ;HI
        defb    0x35, 0x15, 0x16, 0x55, 0x55, 0x25, 0x00        ;JK
        defb    0x45, 0x47, 0x45, 0x45, 0x45, 0x75, 0x00        ;LM
        defb    0x62, 0x55, 0x55, 0x55, 0x55, 0x52, 0x00        ;NO
        defb    0x62, 0x55, 0x55, 0x65, 0x45, 0x43, 0x00        ;PQ
        defb    0x63, 0x54, 0x52, 0x61, 0x55, 0x52, 0x00        ;RS
        defb    0x75, 0x25, 0x25, 0x25, 0x25, 0x22, 0x00        ;TU
        defb    0x55, 0x55, 0x55, 0x55, 0x27, 0x25, 0x00        ;VW
        defb    0x55, 0x55, 0x25, 0x22, 0x52, 0x52, 0x00        ;XY
        defb    0x73, 0x12, 0x22, 0x22, 0x42, 0x72, 0x03        ;Z[
        defb    0x46, 0x42, 0x22, 0x22, 0x12, 0x12, 0x06        ;\]
        defb    0x20, 0x50, 0x00, 0x00, 0x00, 0x00, 0x0f        ;^_
        defb    0x20, 0x10, 0x03, 0x05, 0x05, 0x03, 0x00        ;£a
        defb    0x40, 0x40, 0x63, 0x54, 0x54, 0x63, 0x00        ;bc
        defb    0x10, 0x10, 0x32, 0x55, 0x56, 0x33, 0x00        ;de
        defb    0x10, 0x20, 0x73, 0x25, 0x25, 0x43, 0x06        ;fg
        defb    0x42, 0x40, 0x66, 0x52, 0x52, 0x57, 0x00        ;hi
        defb    0x14, 0x04, 0x35, 0x16, 0x15, 0x55, 0x20        ;jk
        defb    0x60, 0x20, 0x25, 0x27, 0x25, 0x75, 0x00        ;lm
        defb    0x00, 0x00, 0x62, 0x55, 0x55, 0x52, 0x00        ;no
        defb    0x00, 0x00, 0x63, 0x55, 0x55, 0x63, 0x41        ;pq
        defb    0x00, 0x00, 0x53, 0x66, 0x43, 0x46, 0x00        ;rs
        defb    0x00, 0x20, 0x75, 0x25, 0x25, 0x12, 0x00        ;tu
        defb    0x00, 0x00, 0x55, 0x55, 0x27, 0x25, 0x00        ;vw
        defb    0x00, 0x00, 0x55, 0x25, 0x25, 0x53, 0x06        ;xy
        defb    0x01, 0x02, 0x72, 0x34, 0x62, 0x72, 0x01        ;z{
        defb    0x24, 0x22, 0x22, 0x21, 0x22, 0x22, 0x04        ;|}
        defb    0x56, 0xa9, 0x06, 0x04, 0x06, 0x09, 0x06        ;~©
last equ $
; -----------------------------------------------------------------------------
; NOTE: Other choices for 4x8 fonts designed by Einar Saukas available on tape!
; -----------------------------------------------------------------------------
