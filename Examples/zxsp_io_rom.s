; ================================================================
;   getchar() and putchar() for ZX Spectrum using the BASIC rom
;   Copyright  (c)  Günter Woigk 1994 - 2015
;                   mailto:kio@little-bat.de
; ================================================================


; using this file requires that the the system variables and the IY register
; are preserved for the BASIC rom



; ================================================================
; globals and statics initialization:
; ================================================================

#code _GSINIT

; set print channel to Screen:

        ld      a,2
        call    $1601


; ================================================================
;   Input & Output:
; ================================================================

#code _HOME


; ----------------------------------------------------------------
; extern char getchar(void);
;
; note:
;
; char getchar(void) { return inchar; }
; -->   ld      hl,#_inchar
;       ld      l,(hl)
;       ret


; TODO: to be tested!


gc1:    halt                    ; wait for next interrupt -> next key press detect

_getchar::
        LD      HL,$5C3B        ; FLAGS
        RES     6,(HL)          ; signal string result.
;       BIT     7,(HL)          ; checking syntax ?
;       JR      Z,L2665         ; forward to S-INK$-EN if so

        CALL    $028E           ; routine KEY-SCAN key in E, shift in D.
;       LD      C,$00           ; the length of an empty string
;       JR      NZ,L2660        ; to S-IK$-STK to store empty string if no key returned.
        jr      nz,gc1          ; no key available

        CALL    $031E           ; routine K-TEST get main code in A
;       JR      NC,L2660        ; to S-IK$-STK to stack null string if invalid
        jr      nc,gc1          ; key is invalid

        DEC     D               ; D is expected to be FLAGS so set bit 3 $FF
                                ; 'L' Mode so no keywords.
        LD      E,A             ; main key to A
                                ; C is MODE 0 'KLC' from above still.
        CALL    $0333           ; routine K-DECODE
;       PUSH    AF              ; save the code

        ld      l,a             ; load key into return value
        ret


; ----------------------------------------------------------------
; extern void putchar(char);
;
; note:
;
; void putchar(char c) { outchar = c; }
; -->   push    ix
;       ld      ix,#0
;       add     ix,sp
;       ld      a, 4 (ix)
;       ld      (#_outchar),a
;       pop     ix
;       ret

_putchar::
        ld      hl,2
        add     hl,sp
        ld      a,(hl)          ; a = char
        cp      a,10            ; '\n' ?
        jr      nz,1$
        ld      a,13            ; replace 10 with 13
1$:     rst     2
        ret



