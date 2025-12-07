#!/usr/local/bin/zasm --z80n -o original/

; Z80N test file
; See:
;  * https://table.specnext.dev/
;  * https://wiki.specnext.dev/Extended_Z80_instruction_set
;  * https://wiki.specnext.dev/Z80:Examples
;  *

        org 32768

l1        swapnib        ; ed 23  =8 clock
l2        mirror a        ; ed 24  =8 clock

l3        test $EE         ; ed 27 EE =11 clock
l4        bsla de,b       ; ed 28 =8 clock
l5        bsra de,b       ; ed 29 =8 clock
l6        bsrl de,b       ; ed 2a =8 clock
l7        bsrf de,b       ; ed 2b =8 clock
l8        brlc de,b       ; ed 2c =8 clock

m1        mul d,e         ; ed 30 =8 clock
m2        add hl,a        ; ed 31 =8 clock
m3        add de,a        ; ed 32 =8 clock
m4        add bc,a        ; ed 33 =8 clock
m5        add hl,$30EE    ; ed 34 EE 30 =16 clock
m6        add de,$1234    ; ed 35 34 12 =16 clock
m7        add bc,$8899    ; ed 36 99 88=16 clock

        ; The encoding of the operand of the PUSH $im16 is unique:
        ; it is the only operand encoded as big-endian.
n1        push $5678       ; ed 8a 56 78 =23 clock

o1        outinb          ; ed 90 =16 clock
o2        nextreg $13,$FF ; ed 91 13 FF =20 clock
o3        nextreg $13,a   ; ed 92 13 =17 clock
o4        pixeldn         ; ed 93 =8 clock
o5        pixelad         ; ed 94 =8 clock
o6        setae           ; ed 95 =8 clock

aa        jp (c)          ; ed 98 =13 clock

bb        ldix            ; ed a4 =16 clock
cc        ldws            ; ed a5 =14 clock
dd        lddx            ; ed ac =16 clock
ee        ldirx           ; ed b4 =21/16 clock
ff        ldpirx          ; ed b7 =21/16 clock
gg        lddrx           ; ed bc =21/16 clock

