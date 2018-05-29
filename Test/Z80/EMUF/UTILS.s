


; ------------------------------------------------------------
; print word as 4 hex chars + 1 space
; in:  hl = word to print
; out: --
; mod: af, hl
; ------------------------------------------------------------
printhex4s  call  printhex4
;           jp    printspace


; ------------------------------------------------------------
; print single  and  print newline routines:
; ------------------------------------------------------------

printspace  ld    a,' '
            jr    printchar

printnl     ld    a,13
            call  printchar
            ld    a,10
            jp    printchar
            

; ------------------------------------------------------------
; print word as 4 hex chars
; in:  hl = word to print
; out: --
; mod: af, hl
; ------------------------------------------------------------

printhex4   push  hl
            ld    a,h
            call  printhex2
            pop   hl
            ld    a,l
;           jr    printhex2   


; ------------------------------------------------------------
; print byte as 2 hex chars
; in:  a = word to print
; out: --
; mod: af, hl
; ------------------------------------------------------------

printhex2   push  af
            rra
            rra
            rra
            rra
            call  printhex1
            pop   af          
;           jr    printhex1


; ------------------------------------------------------------
; print hex char
; in:  a = nibble to print
; out: --
; mod: af, hl
; ------------------------------------------------------------

printhex1   and   $0f
            cp    10
            jr    c,ph1
            add   7
ph1:        add   '0'
            jp    printchar


; ------------------------------------------------------------
; print word as 16 binary chars
; in:  hl = word to print
; out: --
; mod: af, hl
; ------------------------------------------------------------

printbin16  push  hl
            ld    a,h
            call  printbin8
            pop   hl
            ld    a,l
;           jr    printbin8   


; ------------------------------------------------------------
; print byte as 8 binary chars
; in:  a = word to print
; out: --
; mod: af, hl
; ------------------------------------------------------------

printbin8   ld    l,a
            ld    h,8
pb1         ld    a,'0'/2
            rl    l
            adc   a,a
            rst   printchar
            dec   h
            jr    nz,pb1
            ret


; ------------------------------------------------------------
; multiply hl*de -> dehl
; ex'ing my way through the routine ... really no beauty ...
; ------------------------------------------------------------

mult        ld    a,16
            ld    bc,de       ; bc will be added to hlde depending on bits in hl
            ld    de,0        ; hlde := 0       (ok, hl isn't already 0 ...)
mult1       ex    hl,de
            add   hl,hl       ; de*2
            ex    hl,de
            adc   hl,hl       ; hlde*2
            jr    nc,mult2
            ex    hl,de
            add   hl,bc
            jr    nc,mult3
            inc   de
mult3       ex    hl,de
mult2       dec   a
            jr    nz,mult1
            ex    hl,de
            ret


; ------------------------------------------------------------
; divide unsigned hl/de -> hl rem de
; ------------------------------------------------------------

divide      ld    a,16
            ld    bc,hl
            ld    hl,0        ; hlbc := hl

div2        sll   c           ; c := 2*c+1
            rl    b           ; bc := 2*bc+1
            adc   hl,hl       ; hlbc := 2*hlbc+1
            
            sbc   hl,de       ; subtract (test)
            jr    nc,div1     ; worked!
            dec   c           ; else clear bit 0 of result
            add   hl,de       ; and undo sub
div1        dec   a
            jr    nz,div2
            
            ex    hl,de       ; de := rem
            ld    hl,bc       ; hl := quot
            ret


; ------------------------------------------------------------
; print decimal number unsigned
; in:  hl = number
; out: --
; mod: hl,de,af
; ------------------------------------------------------------

printdec    ld    de,10000          ; print auto-sized 1-5 characters
            and   a
            sbc   hl,de
            add   hl,de
            jr    nc,printdec5
            ld    de,1000
            and   a
            sbc   hl,de
            add   hl,de
            jr    nc,printdec4
            ld    de,100
            and   a
            sbc   hl,de
            add   hl,de
            jr    nc,printdec3
            ld    de,10
            and   a
            sbc   hl,de
            add   hl,de
            jr    nc,printdec2
            jr    printdec1

printdec5   ld    de,10000          ; print 5 characters wide
            call  pdx
printdec4   ld    de,1000           ; print 4 characters wide
            call  pdx
printdec3   ld    de,100            ; print 3 characters wide
            call  pdx
printdec2   ld    de,10             ; print 2 characters wide
            call  pdx
printdec1   ld    de,1              ; print 1 character wide

pdx         ld    a,'0'
            and   a
pdx1        inc   a
            sbc   hl,de
            jr    nc,pdx1
            add   hl,de
            dec   a
            jp    printchar
            
; ------------------------------------------------------------
; calculate cpu speed
; interrupts must be enabled
; in:  --
; out: cpu clock = hl*1,000,000 + de*1,000
; mod: af,bc,de,hl
; ------------------------------------------------------------

calcspeed:  
#if 0
; this straight-forward routine fails @ z80 clocks > 65.535 MHz
; my PowerMac runs the z80 unlimited @ 80 MHz... 
; so i use a slightly modified routine instead. see #else.
            ld    de,5        ; pre-adjust
            ld    hl,tickercell
            halt
            ld    a,(hl)
            add   a,6
cs1         ld    b,5         ; 7
cs2         dec   b           ; 5*4
            jp    nz,cs2      ; 5*10
            inc   de          ; 6
            cp    a,(hl)      ; 7
            jp    nz,cs1      ; 10
            ex    hl,de
; this took hl*100 ticks for 6/60 sec
; == hl*1,000 ticks for 1 sec
            ld    de,1000
            call  divide
; == hl*1,000,000 + de*1,000 ticks
            ret
#else
            ld    de,2        ; pre-adjust
            ld    hl,tickercell
            halt
            ld    a,(hl)
            add   a,3
cs1         ld    b,5         ; 7
cs2         dec   b           ; 5*4
            jp    nz,cs2      ; 5*10
            inc   de          ; 6
            cp    a,(hl)      ; 7
            jp    nz,cs1      ; 10
            ex    hl,de
; this took hl*100 ticks for 3/60 sec
; == hl*2,000 ticks for 1 sec
            ld    de,500
            call  divide
; == hl*1,000,000 + de*500 ticks
            ex    hl,de
            add   hl,hl
            ex    hl,de
; == hl*1,000,000 + de*1,000 ticks
            ret
#endif

            
; ------------------------------------------------------------
; ram test
; starts with $4000
; returns ram end in hl
; ------------------------------------------------------------

ramtest:    pop   ix
; clear 48 kB ram
            ld    hl,ramstart
            ld    c,0+($10000-ramstart)/$100/4
            ld    b,0
r22         ld    a,$ff
r2          ld    (hl),a
            inc   hl
            ld    (hl),a
            inc   hl
            ld    (hl),a
            inc   hl
            ld    (hl),a
            inc   hl
            djnz  r2
            ld    a,'o'
            pop   de                ; preserve bytes scrambled by return address !!
            rst   printchar
            push  de
            dec   c
            jr    nz,r22

            pop   de
            pop   bc
            rst   printmsg
            defm  $0d,"testing ram ",$00
            push  bc
            push  de

; test ram for defect bits (always 0) and for mirrored pages (if less than 48k ram)
            ld    hl,ramstart
            ld    c,0+($10000-ramstart)/$100/4
            ld    b,0
r3          inc   (hl)
            jr    nz,r4
            inc   hl          
            inc   (hl)
            jr    nz,r4
            inc   hl          
            inc   (hl)
            jr    nz,r4
            inc   hl          
            inc   (hl)
            jr    nz,r4
            inc   hl          
            djnz  r3
            ld    a,'*'
            pop   de
            rst   printchar
            push  de
            dec   c
            jr    nz,r3

r4          pop   de
            pop   bc
            rst   printmsg
            defm  $0d,"testing ram ",$00
            push  bc
            push  de

; test ram up to hl (excl.) for defect bits (always 1) 
            ld    a,h               ; possibly neglecting a few bytes of a defect ram
            ld    hl,ramstart
            sub   a,h
            rra
            rra
            and   a,$3f
            ld    c,a
            ld    b,0
r55         ld    a,0
r5          cp    a,(hl)
            jr    nz,r6
            inc   hl          
            cp    a,(hl)
            jr    nz,r6
            inc   hl          
            cp    a,(hl)
            jr    nz,r6
            inc   hl          
            cp    a,(hl)
            jr    nz,r6
            inc   hl          
            djnz  r5
            ld    a,'='
            pop   de
            rst   printchar
            push  de
            dec   c
            jr    nz,r55

; hl contains ram end
r6          jp    (ix)        ; return




            
            

            

