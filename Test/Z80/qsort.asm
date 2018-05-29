; qsort for z80
; read the README


#define strlen 7


.org 0000


; main

        ld      hl,list
        call    _puts
        ld      b,strlen
        ld      hl,list

rand:
        ld      a,r
        ld      c,a
        add     a,a
        add     a,a
        add     a,c
        and     %00011111
        add     a,65
        ld      (hl),a
        inc     hl
        djnz    rand

        ld      hl,list
        call    _puts
        call    _newline

        ld      bc,list
        ld      de,list+strlen
        call    qsort

        ld      hl,list
        call    _puts
        halt

list:
        .db "QWERTYUI",0


; implement some lib functions
;
; prints string pointed to by hl
; clobbers ahl
_puts:
        ld      a,(hl)
        cp      0
        jp      z,pend
        out     (123),a
        inc     hl
        jp      _puts
pend:
        ret


; qsort function
; usage: bc->first, de->last,
;        call qsort
; clobbers: abcdefhl
qsort:
        ld      hl,0
        push    hl
qsloop:
        ld      h,b
        ld      l,c
        or      a
        sbc     hl,de
        jp      c,next1 ;loop until lo<hi
        pop     bc
        ld      a,b
        or      c
        ret     z       ;bottom of stack
        pop     de
        jp      qsloop
next1:
        push    de      ;save hi,lo
        push    bc
        ld      a,(bc)  ;pivot
        ld      h,a
        dec     bc
        inc     de
fleft:
        inc     bc      ;do i++ while cur<piv
        ld      a,(bc)
        cp      h
        jp      c,fleft
fright:
        dec     de      ;do i-- while cur>piv
        ld      a,(de)
        ld      l,a
        ld      a,h
        cp      l
        jp      c,fright
        push    hl      ;save pivot
        ld      h,d     ;exit if lo>hi
        ld      l,e
        or      a
        sbc     hl,bc
        jp      c,next2
        ld      a,(bc)  ;swap (bc),(de)
        ld      h,a
        ld      a,(de)
        ld      (bc),a
        ld      a,h
        ld      (de),a
        pop     hl      ;restore pivot
        jp      fleft
next2:
        pop     hl      ;restore pivot
        pop     hl      ;pop lo
        push    bc      ;stack=left-hi
        ld      b,h
        ld      c,l     ;bc=lo,de=right
        jp      qsloop
