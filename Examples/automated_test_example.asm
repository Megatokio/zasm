; –––––––––––––––––––––––––––––––––––––––––
; Examples for using #TEST segments in zasm
;
; This file contains some multiplication and division routines.
; They will be tested using tests in #test segments.
;
; Finally the emulation speed is measured and printed using
; the multiplication and division routines.
; –––––––––––––––––––––––––––––––––––––––––


; hint: assemble with "-uvwy"


#target ram

#code CODE, 0x100

; ––––––––––––––––––––––––––
; mult (A DE -- HL)
;
;   mod B
;   ret z

A_times_DE:
        ld hl,0
        or a
        ret z
        ld b,9
3$:     rlca
        dec b
        jr nc,3$
1$:     add hl,de
2$:     dec b
        ret z
        add hl,hl
        rlca
        jp c,1$
        jp 2$

; ––––––––––––––––––––––––––
; div (DEHL C -- DEHL rem A)
;
;   mod B=0
;
; function originally from z80-heaven.wikidot.com
; was broken --> corrected!

DEHL_div_C:
    ld b,32
    xor a
1$: add hl,hl
    rl e
    rl d
    rla
    jr c,3$
    cp c
    jr c,2$
3$: inc l
    sub c
2$: djnz 1$
    ret

; ––––––––––––––––––––––––––
; mult (DEHL A -- ADEHL)
;
; --> z80-heaven.wikidot.com
;     ***broken!***

DEHL_times_A_broken:
    push hl
    or a
    sbc hl,hl
    exx
    pop de
    sbc hl,hl
    ld b,8
mul32loop:
    add hl,hl
    rl e
    rl d
    add a,a
    jr nc,$+8
        add hl,de
        exx
        adc hl,de
        inc a
        exx
    djnz mul32loop
    push hl
    exx
    pop de
    ex hl,de
    ret

; ––––––––––––––––––––––––––
; mult (DE A -- AHL)
;
;   mod BC=0
;   --> wikiti.brandonw.net

DE_times_A:
    ld bc,$0800
    ld h,c
    ld l,c
1$: add hl,hl
    rla         ; Check most-significant bit of accumulator
    jr nc,2$    ; If zero, skip addition
    add hl,de
    adc a,c
2$: djnz 1$
    ret

; mult (DEHL A -- ADEHL)
;
;   mod BC=0 DE' HL'
;   --> kio@little-bat.de

DEHL_times_A:

    push hl
    ld hl,0
    exx
    pop de      ; de = low word, de' = high word

    ld  bc,$0800      ; b=8
    ld  h,c \ ld l,c  ; c=0, hl=0, hl'=0

1$: add hl,hl
    exx
    adc hl,hl
    exx
    rla         ; get most-significant bit of accumulator
    jr nc,2$    ; If zero, skip addition
    add hl,de
    exx
    adc hl,de
    exx
    adc a,c
2$: djnz 1$

    push hl
    exx
    pop de
    ex hl,de
    ret

; ––––––––––––––––––––––––––
; div10 (HL -- HL rem A)
;
; Speed Optimised HL_div_10
;
;   mod BC=10

HL_div_10:
    ld  bc,$0D0A
    xor a
    add hl,hl \ rla
    add hl,hl \ rla
    add hl,hl \ rla
2$: add hl,hl \ rla
    cp  c
    jr  c,1$
    sub c
    inc l
1$: djnz 2$
    ret

; ––––––––––––––––––––––––––
; print_hex (A)
;
;   mod A

print_hex_byte:
    push af
    rrca \ rrca \ rrca \ rrca
    call print_hex_char
    pop  af
    ;jp  print_hex_char

; ––––––––––––––––––––––––––
; print_hex_nibble (A)
;
;   mod A

print_hex_char:
    and 0x0f
    cp  10
    jr  c,1$
    add 'A' - ('9'+1)

1$: add '0'
    rst stdout
    ret

; ––––––––––––––––––––––––––
; print_number (HL)
;
;   mod A BC HL

; print HL as a decimal number:
print_hl:
    call HL_div_10      ; -> HL rem A
    push af
    ld  a,h
    or  l
    call nz,print_hl
    pop af

print_decimal_digit:
    add  a,'0'
    rst stdout
    ret


; -------------------------------------------
#code RST, 0
; interrupt handler for testing interrupt handling test

CON_IO  equ 0xfe        ; a port address

reset:  db  0xed,0x66   ; this is an illegal opcode
        di \ halt \ jp reset

        .org 8
stdin:  in a,(CON_IO)
        and a           ; Z if a=0 (no char available); NZ if char returned
        ret

        .org 16
stdout: out (CON_IO),a
        ret

        .org 24
puts:   ld  a,(hl++)
        and a
        ret z
        out (CON_IO),a
        jr  puts

        .org 32
        .org 40

        .org 48
        jp  0000        ; aux. interrupt entry for special test

        .org 56
int38h: push af         ; --- default interrupt handler $FF = RST 38h ---
        push hl

        ld  hl,(systime)    ; increment a system time
        inc hl
        ld  (systime),hl

        rst stdin
        jr z,1$         ; $00 => no char available

        cp  13
        jr  nz,2$
        ld  a,10        ; replace cr with nl

2$:     rst stdout      ; echo

1$:     pop af
        pop hl
        ei
        ret

systime dw  0



; -------------------------------------------
; test A_times_DE:
; -------------------------------------------

#test TEST1, 0x1000
#local
    .test-timeout 100 ms
min = 207
max = 382

    ld  sp,0
    ld  a,3
    ld  de,7
    call A_times_DE

    .expect a' = 0
    .expect a = 3
    .expect de = 7
    .expect hl = 3*7
    .expect cc > 44+min
    .expect cc < 44+max

1$: xor a
    ld  de,0x0101
    call A_times_DE

    .expect a = 0
    .expect de = 0x0101
    .expect hl = 0
    .expect cc < 31+min

2$: ld  a,1
    call A_times_DE

    .expect a = 1
    .expect de = 0x0101
    .expect hl = 0x0101
    .expect cc = 24+min

3$: ld  a,0xff
    call A_times_DE

    .expect a = 0xff
    .expect de = 0x0101
    .expect hl = 0xFFFF
    .expect cc <= 24+max



Lxx = 4

.macro test_AxDE &A,&DE

Lxx = Lxx+1
{Lxx}$:
    ld    a,&A
    ld    de,&DE
    call  A_times_DE

    .expect a = &A
    .expect de = &DE
    .expect hl = &A * &DE
    .expect cc >= 34+207
    .expect cc <= 34+382

.endm

    test_AxDE 4,5
    test_AxDE 44,55
    test_AxDE 114,115



;   .expect f=0     ; will fail

#endlocal


; -------------------------------------------
; test DEHL_div_C:
; -------------------------------------------

#test TEST1B, 0x1000
#local
    .test-timeout 100 ms

.macro DEHL_div_C &N, &D
    ld  dehl,&N
    ld  c,&D
    call DEHL_div_C
    .expect de = (&N/&D) >> 16
    .expect hl = (&N/&D) & 0xffff
    .expect dehl = &N/&D
    .expect a  = (&N%&D)
    .expect b  = 0
    .expect c  = &D
.endm

    DEHL_div_C 12345,17
    DEHL_div_C 12345678,17
    DEHL_div_C 6474678,123
    DEHL_div_C 37901,149
    DEHL_div_C 65535,127
    DEHL_div_C 65536,127
    DEHL_div_C 65536,128
    DEHL_div_C 65536,255
    DEHL_div_C 65535,255
    DEHL_div_C 0,55
    DEHL_div_C 1,155
    DEHL_div_C 2048876234,1

; test division by zero:
    ld  dehl,123
    ld  c,0
    call DEHL_div_C
    .expect de = 0xffff
    .expect hl = 0xffff
    .expect dehl = 0xffffffff
    .expect a  = 123
    .expect b  = 0
    .expect c  = 0

#endlocal


; -------------------------------------------
; test DEHL_times_A
; -------------------------------------------

#test TEST1C, 0x1000
#local
    .test-timeout 100 ms

    ld  bc,47111
    ld  dehl,45678
    ld  a,123
    call DEHL_times_A
    .expect de = (45678*123) >> 16
    .expect hl = (45678*123) & 0xffff
    .expect dehl = 45678*123
    .expect a  = 0
    .expect bc = 47111


.macro DEHL_times_A &N, &D
    ld  bc,4711
    ld  dehl,&N
    ld  a,&D
    call DEHL_times_A
    .expect de = (&N*&D) >> 16
    .expect hl = (&N*&D) & 0xffff
    .expect dehl = &N * &D
    .expect a  = 0          ; zasm can't calculate 40 bit ints => take care for max result!
    .expect bc = 4711
.endm

    DEHL_times_A 12345,17
    DEHL_times_A 12345678,17
    DEHL_times_A 6474678,123

#endlocal


; -------------------------------------------
; test .expect itself
; -------------------------------------------
#test TEST2, 0x1000
#local
    di
    im 2
    ld  a,3
    ld  i,a
    ld  a,0x80
    ld  r,a

    ld  sp,$1011
    ld  hl,$1213 \ push hl \ pop af
    ld  bc,$1415
    ld  de,$1617
    ld  hl,$1819
    ld  ix,$2021
    ex  af,af'
    exx
    ld  hl,$2223 \ push hl \ pop af
    ld  bc,$2425
    ld  de,$2627
    ld  hl,$2829
    ld  iy,$3031

    .expect pc = $
    .expect im = 2
    .expect i = 3
    .expect r = 0x80 + 19
    .expect iff1 = 0        ; di
    .expect iff2 = 0        ; di

    .expect sp = $1011
    .expect af' = $1213
    .expect bc' = $1415
    .expect de' = $1617
    .expect HL' = 1819h
    .expect af2 = $1213
    .expect BC2 = $1415
    .expect de2 = $1617
    .expect hl2 = 1819h
    .expect IX  = $2021
    .expect af = $2223
    .expect bc = $2425
    .expect de = $2627
    .expect HL = 2829h
    .expect iy = $3031
    .expect sph = $10
    .expect spl = $11
    .expect a' = $12
    .expect f' = $13
    .expect b' = $14
    .expect C' = $15
    .expect D' = $16
    .expect e' = $17
    .expect h' = $18
    .expect l' = $19
    .expect a2 = $12
    .expect f2 = $13
    .expect b2 = $14
    .expect C2 = $15
    .expect D2 = $16
    .expect e2 = $17
    .expect h2 = $18
    .expect l2 = $19
    .expect ixh = $20
    .expect ixl = $21
    .expect xh = $20
    .expect xl = $21
    .expect a = $22
    .expect f = $23
    .expect b = $24
    .expect C = $25
    .expect D = $26
    .expect e = $27
    .expect h = $28
    .expect l = $29
    .expect iyh = $30
    .expect iyl = $31
    .expect yh = $30
    .expect yl = $31

    ld  a,10
    ld  r,a
    ei

    .expect iff1 = 1        ; ei
    .expect iff2 = 1        ; ei
    .expect r = 10 + 1      ; ei

    ld  a,0
    ld  iy,0
    ld  bcde, 0xe0b0c0df
    ld  ixhl, 0x23456789

    .expect bc = 0xe0b0
    .expect ix = 0x2345
    .expect de = 0xc0df
    .expect hl = 0x6789
    .expect bcde = 0xe0b0c0df
    .expect ixhl = 0x23456789
    .expect a=0
    .expect iy=0

    ld  a,0
    ld  hl,0
    ld  ixbc, 0xcdef2345
    ld  iyde, 0x98765432

    .expect ix = 0xcdef
    .expect iy = 0x9876
    .expect bc = 0x2345
    .expect de = 0x5432
    .expect ixbc = 0xcdef2345
    .expect iyde = 0x98765432
    .expect a=0
    .expect hl=0

#endlocal


; -------------------------------------------
; test running with cc limiter and no interrupts
; -------------------------------------------

#test TEST3, 0x1000
#local
    .test-clock 4 MHz           ; set speed
    .test-timeout 1 s

    ld  bc,0
1$: djnz 1$
    dec c
    jr  nz,1$

duration = 10 + 13*$ff00 + 24*$100 - 5  ; 854789

    .expect cc = duration
    .expect cc < 4000000
    .expect cc > $10000 * 13    ; ~ 850000
    .expect bc = 0
#endlocal


; -------------------------------------------
; test running with cc limiter and interrupts
; test output to console
; -------------------------------------------

#test TEST4, 0x1000
#local
    .test-clock   4 MHz         ; set speed
    .test-int     100 Hz        ; set interrupt frequency
    .test-console CON_IO        ; read from / dump to console
    .test-timeout 1 s

    im  1       ; rst $38
    ei

    ld  bc,0
1$: djnz 1$
    dec c
    jr  nz,1$

duration = 10 + 13*$ff00 + 24*$100 - 5  ; 854789
dur_int  = 13 + 83 + 34 + 25            ; cc per interrupt

    .expect cc = 12 + duration + 21 * dur_int   ; 858056
    .expect bc = 0

    ld  hl,(systime)
    .expect hl = 21     ; irpt 100 Hz => cc/int = 40000 => 858056/40000 = 21

    ld  hl,msg
2$: ld  a,(hl++)
    and a
    jr  z,msg_end
    rst stdout
    jr  2$

msg: dm "--> Hello World, this is Test #4 speaking!",10,0
msg_end:

#endlocal


; -------------------------------------------
; test running with cc limiter and interrupts
; test input from list
; test compare output with data from list
; -------------------------------------------

#test TEST5, 0x1000
#local
in_addr  equ 1
out_addr equ 2

    .test-clock   4 MHz             ; set speed
    .test-int     10000 cc          ; set interrupt using cpu cycles (=> 400 Hz)
    .test-intack  opcode(RST 48)    ; set opcode read from bus during int ack cycle
    .test-timeout 100 ms

    ; set input data:
    .test-in    in_addr,  {'y'}*10, "abcde", 0, "DEFGH", {0}*10       ; 31 bytes

    ; set output compare data:
    .test-out   out_addr, "yyyyyyyyyy", "abcde", "DEFGH"


    ; make rst 48 point to my handler
    ld  hl,int_handler
    ld  (48+1),hl

    im  0               ; -> read instruction from bus
    ld  b,31            ; 31 bytes to read
3$: ei
    halt
    djnz 3$
    jr  resume

int_handler:
    in  a,(in_addr)
    and a
    ret z               ; $00 => no char available
    out (out_addr),a    ; echo
    ret

resume:
    nop

    .expect cc > 31 * 10000
    .expect cc < 31 * 10000 + 200
    .expect cc = 310074             ; lt. zasm

#endlocal


; -------------------------------------------
; test running without cc limiter and with interrupts
; read input from list
; output to console
; -------------------------------------------

#test TEST6, 0x1000
#local
in_addr  equ 1
out_addr equ 2

    .test-int     10000 cc      ; set interrupt using cpu cycles
    .test-timeout 100 ms

    .test-in  in_addr,  "--> ", {"Hello, "}*2, "this is Test #6 queeking", 10, {0}*
    .test-console out_addr


    ; setup interrupt table:
    im  2                           ; -> jump via table
    ld  a,hi(int_table) \ ld i,a    ; hi byte in i
    .test-intack  lo(int_table)     ; lo byte from bus in int ack cycle


    ld  b,48            ; 48 bytes to read
3$: ei
    halt
    djnz 3$
    jr  resume


int_table:
    dw  int_handler

int_handler:
    in  a,(in_addr)
    and a
    ret z               ; $00 => no char available
    out (out_addr),a    ; echo
    ret

resume:
    nop

    .expect cc > 48 * 10000
    .expect cc < 48 * 10000 + 200
    .expect cc = 480071             ; lt. zasm

#endlocal


; -------------------------------------------
; run without cc limiter and with interrupts
; calculate emulation speed
; -------------------------------------------

#test TEST7, 0x1000
#local

    .test-int     1000 Hz       ; fastest allowed for tests
    ;.test-clock  100 MHz       ; used for reference measurement
    .test-console CON_IO        ; output to console
    .test-timeout 105 ms


    ; setup interrupt table:
    im  2                           ; -> jump via table
    ld  a,hi(int_table) \ ld i,a    ; hi byte in i
    .test-intack  lo(int_table)     ; lo byte from bus in int ack cycle

    ld  sp,0
    ei

    xor a
    ld  de,0
    jr  2$

1$: pop de
    pop af
    inc a
    dec de \ dec de \ dec de
2$: push af
    push de

    call A_times_DE

    ld  hl,counter
3$: inc (hl++)
    jr  z,3$

    ld  a,(systime)
    cp  a,100
    jr  nz,1$

    jr  resume

counter:
    dw  0,0

systime:
    db  0

int_table:
    dw  int_handler

int_handler:
    ex  af,af'
    ld  a,(systime)
    inc a
    ld  (systime),a
    ex  af,af'
    ei
    ret


; divide DEHL by 199.8
div1998:
    ld  a,5
    call DEHL_times_A
    ld  c,9
    call DEHL_div_C
    ld  c,111
    jp  DEHL_div_C

msg_loops_done: dm "--> loops done in 100 ms: 0x",0
msg_mhz1:       dm "--> Z80 running at ",0
msg_mhz2:       dm " MHz",10,0

resume:
    ld  hl,msg_loops_done
    rst puts
    ld  hl,counter+4
    ld  a,(--hl)
    call print_hex_byte
    ld  a,(--hl)
    call print_hex_byte
    ld  a,(--hl)
    call print_hex_byte
    ld  a,(--hl)
    call print_hex_byte
    ld  a,10
    rst stdout

    ld  hl,msg_mhz1
    rst puts
    ld  dehl,(counter)
    call div1998            ; divide dehl by 199.8 --> hl = MHz
    call print_hl
    ld  hl,msg_mhz2
    rst puts

    ; used during reference measurement:
    ;.expect cc > 100000 * 100
    ;.expect cc < 100000 * 100 + 10000
    ;.expect hl=0   ; --> print
    ;.expect de=0   ; --> print

; 20 MHz:    $0F93  = 3987   loops  -> 199.35  loops/MHz
; 40 MHz:    $1F2F  = 7983   loops  -> 199.575 loops/MHz
; 100 MHz:   $4DFB  = 19963  loops  -> 199.63  loops/MHz

; AMD Ryzen 5 2400G @ 3.2GHz:
;  clang: max. 1818 MHz
;  gcc:   max. 2648 MHz --> almost 50% faster!

#endlocal

#end


























