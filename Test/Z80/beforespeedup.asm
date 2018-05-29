; Disassembly of the file "E:\WellMate\WM FW 2.5\beforespeedup.rom"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.0
; 
; on Thursday, 24 of June 2004 at 01:44 PM
; 
#target rom
#code rom,0,65536

l0000:  jp      l0100

    defs    66h - $

    retn    

    defs    80h - $

;	Interrupt Vector Table for mode 2 interrupts

    defw    IntRoutine_7
    defw    IntRoutine_1
    defw    IntRoutine_6
    defw    IntRoutine_5
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_4
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_3
    defw    IntRoutine_2
    defw    IntRoutine_1

    defs    100h - $

l0100:
    ld      a,3fh
    out     (00h),a
    ld      a,00h
    out     (01h),a
    ld      a,3fh
    out     (02h),a
    ld      a,00h
    out     (03h),a
    ld      a,33h
    out     (04h),a
    ld      a,13h
    out     (05h),a
    ld      a,3fh
    out     (06h),a
    ld      a,0f0h
    out     (07h),a
    ld      sp,0fffeh
    ld      a,00h
    out     (1ah),a
    ld      a,00h
    out     (1bh),a
    ld      a,00h
    out     (1ch),a
    ld      a,9bh
    out     (1dh),a
    ld      a,00h
    out     (1eh),a
    ld      a,00h
    ld      (001fh),a
    ld      hl,0d000h
l013f:
    xor     a
    ld      (hl),a
    inc     hl
    ld      a,h
    cp      0ffh
    jp      nz,l013f
    ld      a,l
    cp      0ffh
    jp      nz,l013f
    call    l8000
    ld      a,00h
    ld      i,a
    im      2
    ld      a,60h
    out     (35h),a
    ld      a,09h
    out     (34h),a
    ld      a,80h
    out     (37h),a
    ld      a,01h
    out     (35h),a
    ld      a,04h
    out     (34h),a
    ld      a,0deh
    out     (37h),a
    ld      a,0f2h
    out     (36h),a
    ld      a,0c0h
    out     (13h),a
    ld      a,3ah
    out     (2bh),a
    ld      a,01h
    out     (28h),a
    ld      a,0e5h
    out     (2bh),a
    call    l0648
    ld      a,3ah
    out     (2fh),a
    ld      a,01h
    out     (2ch),a
    ld      a,0e5h
    out     (2fh),a
    call    l065a
    ld      a,04h
    out     (23h),a
    ld      a,04h
    out     (21h),a
    in      a,(21h)
    ld      hl,1680h
    ld      a,l
    out     (20h),a
    ld      a,h
    out     (20h),a
    ld      a,06h
    out     (27h),a
    in      a,(27h)
    ld      hl,0062h
    ld      a,l
    out     (26h),a
    ld      a,h
    out     (26h),a
    ld      a,05h
    out     (25h),a
    in      a,(25h)
    ld      hl,0266h
    ld      a,l
    out     (24h),a
    ld      a,h
    out     (24h),a
    ld      a,00h
    ld      (0d500h),a
    out     (38h),a
    ld      a,0ffh
    out     (3bh),a
    ld      a,00h
    ld      (0d501h),a
    out     (3ah),a
    ld      a,00h
    out     (3dh),a
    ld      a,97h
    out     (3fh),a
    ld      a,00h
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ffh
    ld      (0d509h),a
    out     (8ah),a
    ld      hl,0695h
    ld      (0d570h),hl
    ld      hl,4000h
    ld      (0d572h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,01ech
    ld      (0d580h),hl
    ld      hl,024dh
    ld      (0d582h),hl
    ld      hl,03d7h
    ld      (0d584h),hl
    ld      hl,(0d580h)
    ld      (0d586h),hl
    ld      hl,0003h
    ld      (0d52eh),hl
    ld      a,00h
    ld      (0d54bh),a
    ld      hl,000dh
    ld      (0d52bh),hl
    ld      hl,07d0h
    ld      (0d54ch),hl
    ld      hl,0002h
    ld      (0d54eh),hl
    ld      hl,l0000
    ld      (0d535h),hl
    ld      hl,000ah
    ld      (0d537h),hl
    ld      hl,0064h
    ld      (0d552h),hl
    ld      hl,0064h
    ld      (0d554h),hl
    ld      a,00h
    ld      (0d52dh),a
    ld      (0d532h),a
    ld      (0d588h),a
    ld      hl,l0000
    ld      (0dde3h),hl
    ld      a,00h
    ld      (0de5ch),a
    ld      (0de5ah),a
    ld      (0de5bh),a
    ld      a,(0d000h)
    cp      0aah
    call    nz,l2335
    ei      
    in      a,(3ch)
    cp      03h
    jp      z,l29cc
    in      a,(3ch)
    cp      80h
    jp      z,l0283
    jp      l028c
l0283:
    in      a,(3eh)
    and     08h
    cp      08h
    jp      z,l2b04
l028c:  in      a,(3ch)
    cp      60h
    jp      z,l2bf9
    in      a,(80h)
    and     0f0h
    cp      80h
    jp      z,l2ecc
    call    l24fe
    jp      l0500

    defs    500h - $

l0500:  ld      a,0f8h
    out     (81h),a
    ld      a,0eeh
    out     (80h),a
    ld      a,0b6h
    out     (80h),a
    ld      a,0edh
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      hl,03e8h
    ld      (0d562h),hl
    call    l26c3
l0531:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l055d
    ld      a,(0d001h)
    cp      00h
    jp      z,l18cc
    cp      01h
    jp      z,l1ab3
    cp      02h
    jp      z,l1bff
    cp      03h
    jp      z,l18cc
    cp      04h
    jp      z,l1ab3
    cp      05h
    jp      z,l1bff
l055d:  call    l103c
l0560:  ld      a,(0d001h)
    cp      00h
    jp      z,l13b6
    cp      01h
    jp      z,l15c8
    cp      02h
    jp      z,l1749
    cp      03h
    jp      z,l13b6
    cp      04h
    jp      z,l15c8
    cp      05h
    jp      z,l1749
    ld      a,00h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    set     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0f8h
    out     (81h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
l05d1:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    call    l2599
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l060f
    cp      52h
    jp      z,l0612
    cp      43h
    jp      z,l0618
    cp      55h
    jp      z,l061b
    cp      44h
    jp      z,l061e
    cp      47h
    jp      z,l0621
    cp      53h
    jp      z,l063f
    cp      46h
    jp      z,l0642
    cp      42h
    jp      z,l0645
    jp      l05d1
l060f:  jp      l05d1
l0612:  call    l103c
    jp      l05d1
l0618:  jp      l05d1
l061b:  jp      l05d1
l061e:  jp      l05d1
l0621:  call    l1183
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    call    l112c
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    jp      l0621
    jp      l05d1
l063f:  jp      l05d1
l0642:  jp      l05d1
l0645:  jp      l05d1
l0648:  ld      a,40h
    out     (2bh),a
    ld      a,3ah
    out     (2bh),a
    ld      a,25h
    out     (2bh),a
    ret     

    ld      a,00h
    out     (2bh),a
    ret     

l065a:  ld      a,40h
    out     (2fh),a
    ld      a,3ah
    out     (2fh),a
    ld      a,25h
    out     (2fh),a
    ret     

    ld      a,00h
    out     (2fh),a
    ret     

l066c:  ld      a,(0d500h)
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,0f8h
    out     (81h),a
    ld      a,84h
    out     (80h),a
    ld      a,0eeh
    out     (80h),a
    ld      a,0cbh
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
l06aa:  ld      a,(0d550h)
    and     a
    jp      z,l06bd
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
l06bd:  ld      a,(0dddfh)
    and     a
    jp      nz,l06ca
    call    l24fe
    jp      l06de
l06ca:  ld      a,03h
    ld      (0d5b0h),a
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     bc
    ld      a,(0d514h)
    xor     b
    call    nz,l26fb
l06de:  ld      a,(0de5ah)
    and     a
    call    nz,l22b5
    ld      a,(0dddfh)
    and     a
    jp      z,l06aa
    call    l078a
    jp      l06aa
l06f2:  ld      hl,0d9dfh
    ld      de,(0de4ch)
    add     hl,de
    ld      a,(hl)
    inc     de
    ld      (0de4ch),de
    cp      4fh
    jp      nz,l0711
    call    l0725
    ld      a,01h
    ld      (0de5ch),a
    pop     af
    jp      l066c
l0711:  ld      hl,8683h
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    l0d3c
    ld      a,00h
    ld      (0dddfh),a
    ret     

l0725:  ld      ix,0dde8h
    ld      de,l0000
    add     ix,de
    call    l12b6
    ld      a,2ch
    ld      (0ddebh),a
    ld      ix,0dde8h
    ld      de,0004h
    add     ix,de
    call    l12c2
    ld      a,2ch
    ld      (0ddeeh),a
    ld      ix,0dde8h
    ld      de,0007h
    add     ix,de
    call    l12e3
    ld      a,2ch
    ld      (0ddf1h),a
    ld      ix,0dde8h
    ld      de,000ah
    add     ix,de
    call    l1304
    ld      a,2ch
    ld      (0ddf4h),a
    ld      ix,0dde8h
    ld      de,000dh
    add     ix,de
    call    l1325
    ld      a,2ch
    ld      (0ddf7h),a
    ld      ix,0dde8h
    ld      de,0010h
    add     ix,de
    call    l1346
    call    l0d3c
    ret     

l078a:  ld      a,00h
    ld      (0d529h),a
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,l079d
    jp      l07a2
l079d:  ld      a,01h
    ld      (0d529h),a
l07a2:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    push    af
    ld      a,(0d550h)
    and     a
    jp      nz,l07f7
    pop     af
    cp      4fh
    jp      z,l080a
    cp      43h
    jp      z,l080e
    cp      52h
    jp      z,l081f
    cp      58h
    jp      z,l0838
    cp      50h
    jp      z,l0a31
    cp      53h
    jp      z,l0be8
    cp      41h
    jp      z,l0bee
    cp      51h
    jp      z,l0bf4
    cp      57h
    jp      z,l0c59
    cp      4ch
    jp      z,l0cb1
    cp      03h
    jp      z,l0d1f
    jp      l0d28
l07f7:  pop     af
    cp      50h
    jp      z,l0a31
    cp      57h
    jp      z,l0c59
    cp      03h
    jp      z,l0d1f
    jp      l0d28
l080a:  call    l0725
    ret     

l080e:  ld      a,00h
    ld      (0de5ch),a
    call    l0dc8
    ld      a,00h
    ld      (0dddfh),a
    pop     af
    jp      l0560
l081f:  ld      a,(0d529h)
    and     a
    jp      nz,l082c
    call    l103c
    jp      l082f
l082c:  jp      l082f
l082f:  ld      a,00h
    ld      (0dddfh),a
    call    l0ded
    ret     

l0838:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      53h
    jp      z,l0866
    cp      30h
    jp      z,l08c6
    cp      31h
    jp      z,l08d2
    cp      32h
    jp      z,l08de
    cp      57h
    jp      z,l08ea
    jp      l0d28
l0866:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    l82a9
    ld      hl,(0d59eh)
    ld      hl,018fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,l0d28
    ld      hl,4e20h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      a,(0d529h)
    and     a
    jp      nz,l08c5
    ld      hl,(0d59eh)
    ld      (0d565h),hl
    ret     

l08c5:  ret     

l08c6:  ld      a,(0d529h)
    and     a
    jp      nz,l08d1
    call    l103c
    ret     

l08d1:  ret     

l08d2:  ld      a,(0d529h)
    and     a
    jp      nz,l08dd
    call    l1183
    ret     

l08dd:  ret     

l08de:  ld      a,(0d529h)
    and     a
    jp      nz,l08e9
    call    l11da
    ret     

l08e9:  ret     

l08ea:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d599h),a
    ld      a,(ix+01h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59ah),a
    ld      (0d59bh),a
    ld      (0d59ch),a
    call    l82a9
    ld      hl,(0d59eh)
    ld      hl,l0000
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,l0d28
    jp      z,l0d28
    in      a,(8ch)
    bit     3,a
    jp      z,l093b
    ld      hl,000ch
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
l093b:  ld      hl,0018h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0de50h),hl
    ld      a,(ix+02h)
    cp      2bh
    jp      z,l0968
    cp      2dh
    jp      z,l09c8
    jp      l095e
l095e:  ld      hl,l0000
    ld      (0de52h),hl
    call    l0f59
    ret     

l0968:  ld      de,(0de4ch)
    inc     de
    ld      (0de4ch),de
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      a,30h
    ld      (0d59ch),a
    call    l82a9
    ld      hl,(0d59eh)
    ld      hl,0ffffh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,l0d28
    ld      hl,00f0h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0de52h),hl
    call    l0f59
    ret     

l09c8:  ld      de,(0de4ch)
    inc     de
    ld      (0de4ch),de
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      a,30h
    ld      (0d59ch),a
    call    l82a9
    ld      de,(0d59eh)
    ld      hl,l0000
    and     a
    sbc     hl,de
    ld      (0d59eh),hl
    ld      hl,00f0h
    ld      de,(0d59eh)
    and     a
    add     hl,de
    jp      m,l0d28
    ld      hl,l0000
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0de52h),hl
    call    l0f59
    ret     

l0a31:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    push    af
    ld      a,(0d550h)
    and     a
    jp      nz,l0a6f
    pop     af
    cp      53h
    jp      z,l0a78
    cp      30h
    jp      z,l0ad5
    cp      31h
    jp      z,l0ade
    cp      32h
    jp      z,l0af1
    cp      33h
    jp      z,l0b04
    cp      2bh
    jp      z,l0b14
    cp      2dh
    jp      z,l0b7e
l0a6f:  pop     af
    cp      33h
    jp      z,l0b04
    jp      l0d28
l0a78:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz

    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    l82a9
    ld      hl,(0d59eh)
    ld      hl,018fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,l0d28
    ld      hl,4e20h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0d586h),hl
    ret     

l0ad5:  ld      a,(0d550h)
    and     a
    ret     nz

    call    l1286
    ret     

l0ade:  ld      a,(0d550h)
    and     a
    ret     nz

    ld      a,00h
    ld      (0d578h),a
    call    l1250
    ld      a,01h
    ld      (0d550h),a
    ret     

l0af1:  ld      a,(0d550h)
    and     a
    ret     nz

    ld      a,01h
    ld      (0d578h),a
    call    l1250
    ld      a,01h
    ld      (0d550h),a
    ret     

l0b04:  ld      a,(0d550h)
    and     a
    ret     z

    ld      a,00h
    ld      (0d577h),a
    ld      a,00h
    ld      (0d550h),a
    ret     

l0b14:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz

    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    l82a9
    ld      a,(0d5a0h)
    sub     02h
    jp      p,l0d28
    ld      hl,869fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    ld      a,(0d5a0h)
    ld      e,a
    ld      a,01h
    sbc     a,e
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0d579h),hl
    ld      a,(0d5a0h)
    ld      (0d57bh),a
    ld      a,00h
    ld      (0d578h),a
    call    l11eb
    ret     

l0b7e:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz

    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    l82a9
    ld      a,(0d5a0h)
    sub     02h
    jp      p,l0d28
    ld      hl,869fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    ld      a,(0d5a0h)
    ld      e,a
    ld      a,01h
    sbc     a,e
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      (0d579h),hl
    ld      a,(0d5a0h)
    ld      (0d57bh),a
    ld      a,01h
    ld      (0d578h),a
    call    l11eb
    ret     

l0be8:  ld      a,01h
    ld      (0d588h),a
    ret     

l0bee:  ld      a,00h
    ld      (0d588h),a
    ret     

l0bf4:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      41h
    jp      z,l0c22
    cp      42h
    jp      z,l0c2d
    cp      43h
    jp      z,l0c38
    cp      44h
    jp      z,l0c43
    cp      58h
    jp      z,l0c4e
    jp      l0d28
l0c22:  ld      ix,0dde8h
    call    l12c2
    call    l0d3c
    ret     

l0c2d:  ld      ix,0dde8h
    call    l12e3
    call    l0d3c
    ret     

l0c38:  ld      ix,0dde8h
    call    l1304
    call    l0d3c
    ret     

l0c43:  ld      ix,0dde8h
    call    l1325
    call    l0d3c
    ret     

l0c4e:  ld      ix,0dde8h
    call    l1346
    call    l0d3c
    ret     

l0c59:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      (0d59ch),a
    call    l82a9
    ld      hl,0ffffh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,l0d28
    ld      hl,03e7h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,l0d28
    ld      hl,(0d59eh)
    ld      de,000ah
    call    l831a
    ld      (0d562h),hl
    call    l26c3
    ret     

l0cb1:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      50h
    jp      z,l0cd5
    cp      4ch
    jp      z,l0cf9
    cp      55h
    jp      z,l0d0c
    jp      l0d28
l0cd5:  ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,4ch
    ld      (0dde8h),a
    ld      a,50h
    ld      (0dde9h),a
    ld      a,40h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l0cf9:  ld      a,4ch
    ld      (0dde8h),a
    ld      a,4ch
    ld      (0dde9h),a
    ld      a,40h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l0d0c:  ld      a,4ch
    ld      (0dde8h),a
    ld      a,55h
    ld      (0dde9h),a
    ld      a,40h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l0d1f:  call    l0dc8
    ld      a,00h
    ld      (0dddfh),a
    ret     

l0d28:  ld      hl,8683h
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    l0d3c
    ld      a,00h
    ld      (0dddfh),a
    ret     

l0d3c:  ld      a,00h
    ld      (0dde7h),a
l0d41:  ld      hl,l0000
    ld      (0dde5h),hl
    call    l0e03
    ld      a,02h
    out     (2ah),a
l0d4e:  ld      hl,0dde8h
    ld      de,(0dde5h)
    add     hl,de
    ld      a,(hl)
    inc     de
    ld      (0dde5h),de
    cp      40h
    jp      z,l0d69
    call    l0e03
    out     (2ah),a
    jp      l0d4e
l0d69:  call    l0e03
    ld      a,03h
    out     (2ah),a
    ld      hl,07d0h
    ld      (0d562h),hl
    call    l26ef
l0d79:  ld      a,(0d550h)
    and     a
    jp      z,l0d8c
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
l0d8c:  ld      hl,(0d562h)
    ld      a,h
    or      l
    jp      z,l0da3
    ld      a,(0d5dbh)
    and     a
    jp      z,l0d79
    ld      a,(0d5dch)
    cp      06h
    jp      z,l0dba
l0da3:  ld      a,00h
    ld      (0d5dbh),a
    ld      (0d561h),a
    ld      a,(0dde7h)
    cp      02h
    jp      z,l0dc1
    inc     a
    ld      (0dde7h),a
    jp      l0d41
l0dba:  ld      a,00h
    ld      (0d5dbh),a
    and     a
    ret     

l0dc1:  ld      a,00h
    ld      (0dddfh),a
    scf     
    ret     

l0dc8:  ld      hl,8680h
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    l0d3c
    ret     

l0dd7:  call    l0e03
    ld      a,02h
    out     (2ah),a
    call    l0e03
    ld      a,06h
    out     (2ah),a
    call    l0e03
    ld      a,03h
    out     (2ah),a
    ret     

l0ded:  call    l0e03
    ld      a,02h
    out     (2ah),a
    call    l0e03
    ld      a,52h
    out     (2ah),a
    call    l0e03
    ld      a,03h
    out     (2ah),a
    ret     

l0e03:  push    af
l0e04:  in      a,(2bh)
    and     01h
    jp      z,l0e04
    pop     af
    ret     

    call    l103c
    ret     

l0e11:  ld      hl,(0de58h)
    in      a,(27h)
    ld      a,l
    out     (26h),a
    ld      a,h
    out     (26h),a
    ret     

l0e1d:  ld      hl,(0de4eh)
    ld      hl,(0de4eh)
    ld      de,(0dde0h)
    and     a
    sbc     hl,de
    jp      z,l0e33
    jp      p,l0e35
    jp      l0e4e
l0e33:  scf     
    ret     

l0e35:  ld      a,00h
    ld      (0d567h),a
    ld      hl,(0de4eh)
    push    hl
    ld      de,(0dde0h)
    and     a
    sbc     hl,de
    ld      (0d568h),hl
    pop     hl
    ld      (0dde0h),hl
    and     a
    ret     

l0e4e:  ld      a,01h
    ld      (0d567h),a
    ld      hl,(0dde0h)
    ld      de,(0de4eh)
    and     a
    sbc     hl,de
    ld      (0d568h),hl
    ld      (0dde0h),de
    and     a
    ret     

l0e66:  ld      a,(0d567h)
    and     a
    jp      nz,l0e7a
    ld      a,(0d509h)
    res     1,a
    ld      (0d509h),a
    out     (8ah),a
    jp      l0e84
l0e7a:  ld      a,(0d509h)
    set     1,a
    ld      (0d509h),a
    out     (8ah),a
l0e84:  ld      a,(0d574h)
    and     a
    jp      nz,l0ea2
l0e8b:  ld      a,00h
    ld      (0d574h),a
    ld      hl,(0d565h)
    ld      (0de58h),hl
    call    l0e11
    ld      hl,l0000
    ld      (0d575h),hl
    jp      l0eca
l0ea2:  ld      hl,(0d565h)
    ld      de,(8691h)
    and     a
    sbc     hl,de
    jp      p,l0e8b
    jp      z,l0e8b
    ld      (0de58h),de
    call    l0e11
    ld      hl,0001h
    ld      (0d575h),hl
    ld      hl,(0d568h)
    srl     h
    rr      l
    inc     hl
    ld      (0d56ah),hl
l0eca:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d564h),a
l0ed8:  ld      hl,(0d568h)
    ld      a,h
    or      l
    jp      nz,l0ed8
    ld      a,00h
    ld      (0d564h),a
    ret     

l0ee6:  ld      a,(0d567h)
    and     a
    jp      nz,l0efa
    ld      a,(0d509h)
    res     1,a
    ld      (0d509h),a
    out     (8ah),a
    jp      l0f04
l0efa:  ld      a,(0d509h)
    set     1,a
    ld      (0d509h),a
    out     (8ah),a
l0f04:  ld      a,(0d574h)
    and     a
    jp      nz,l0f22
l0f0b:  ld      a,00h
    ld      (0d574h),a
    ld      hl,(0d565h)
    ld      (0de58h),hl
    call    l0e11
    ld      hl,l0000
    ld      (0d575h),hl
    jp      l0f4a
l0f22:  ld      hl,(0d565h)
    ld      de,(8691h)
    and     a
    sbc     hl,de
    jp      p,l0f0b
    jp      z,l0f0b
    ld      (0de58h),de
    call    l0e11
    ld      hl,0001h
    ld      (0d575h),hl
    ld      hl,(0d568h)
    srl     h
    rr      l
    inc     hl
    ld      (0d56ah),hl
l0f4a:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d564h),a
    ret     

l0f59:  in      a,(8ch)
    bit     3,a
    jp      z,l0fcf
    ld      hl,l0000
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     p

    ret     z

    ld      hl,000ch
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     m

    in      a,(82h)
    push    af
    and     7fh
    ld      de,l0000
    ld      e,a
    ld      (0de54h),de
    pop     af
    bit     7,a
    jp      z,l0f97
    ld      hl,l0000
    ld      de,(0de54h)
    and     a
    sbc     hl,de
    ld      (0de54h),hl
l0f97:  ld      ix,8691h
    ld      hl,(0de50h)
    ld      (0dde3h),hl
    add     hl,hl
    push    hl
    pop     de
    add     ix,de
    ld      l,(ix+00h)
    ld      h,(ix+01h)
    ld      de,(0de54h)
    add     hl,de
    ld      de,(0d005h)
    add     hl,de
    ld      de,(0de52h)
    add     hl,de
    ld      (0de4eh),hl
    call    l0e1d
    jp      c,l103b
    ld      a,00h
    ld      (0d574h),a
    call    l0e66
    jp      l103b
l0fcf:  ld      hl,l0000
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     p

    ret     z

    ld      hl,0018h
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     m

    in      a,(84h)
    push    af
    and     7fh
    ld      de,l0000
    ld      e,a
    ld      (0de56h),de
    pop     af
    bit     7,a
    jp      z,l1006
    ld      hl,l0000
    ld      de,(0de56h)
    and     a
    sbc     hl,de
    ld      (0de56h),hl
l1006:  ld      ix,86abh
    ld      hl,(0de50h)
    ld      (0dde3h),hl
    add     hl,hl
    push    hl
    pop     de
    add     ix,de
    ld      l,(ix+00h)
    ld      h,(ix+01h)
    ld      de,(0de56h)
    add     hl,de
    ld      de,(0d007h)
    add     hl,de
    ld      de,(0de52h)
    add     hl,de
    ld      (0de4eh),hl
    call    l0e1d
    jp      c,l103b
    ld      a,00h
    ld      (0d574h),a
    call    l0e66
l103b:  ret     

l103c:  ld      a,01h
    ld      (0d52dh),a
    ld      hl,(0d565h)
    push    hl
    ld      hl,(0d52eh)
    ld      (0d530h),hl
    ld      a,01h
    ld      (0d52dh),a
    in      a,(8ch)
    bit     0,a
    jp      z,l1092
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l1070:  ld      a,01h
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,l26fb
    in      a,(8ch)
    bit     0,a
    jp      nz,l1070
    ld      a,00h
    ld      (0d564h),a
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
l1092:  ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l10a5:  in      a,(8ch)
    bit     0,a
    jp      z,l10a5
    ld      a,00h
    ld      (0d564h),a
    ld      hl,0032h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l10cd:  in      a,(8ch)
    bit     0,a
    jp      nz,l10cd
    ld      a,00h
    ld      (0d564h),a
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      hl,(0d52bh)
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l10f2:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l10f2
    ld      a,00h
    ld      (0d564h),a
    ld      hl,l0000
    ld      (0dde0h),hl
    ld      a,00h
    ld      (0dde2h),a
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    pop     hl
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d52dh),a
    ld      hl,l0000
    ld      (0dde3h),hl
    ld      (0de52h),hl
    ret     

l112c:  in      a,(8ch)
    bit     0,a
    ret     z

    ld      a,01h
    ld      (0d567h),a
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l1144:  ld      a,01h
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,l26fb
    in      a,(8ch)
    bit     0,a
    jp      nz,l1144
    di      
    ld      a,00h
    ld      (0d564h),a
    ei      
    ld      hl,15b8h
    ld      de,(0d568h)
    and     a
    sbc     hl,de
    push    hl
    pop     de
    ld      hl,(0dde0h)
    and     a
    sbc     hl,de
    ld      (0dde0h),hl
    ld      a,00h
    ld      (0dde2h),a
    ld      hl,l0000
    ld      (0dde3h),hl
    ld      (0de52h),hl
    ret     

l1183:  in      a,(8ch)
    bit     1,a
    ret     z

    ld      a,00h
    ld      (0d567h),a
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
l119b:  ld      a,02h
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,l26fb
    in      a,(8ch)
    bit     1,a
    jp      nz,l119b
    di      
    ld      a,00h
    ld      (0d564h),a
    ei      
    ld      hl,15b8h
    ld      de,(0d568h)
    and     a
    sbc     hl,de
    ld      de,(0dde0h)
    add     hl,de
    ld      (0dde0h),hl
    ld      a,01h
    ld      (0dde2h),a
    ld      hl,0019h
    ld      (0dde3h),hl
    ld      hl,l0000
    ld      (0de52h),hl
    ret     

l11da:  call    l112c
    ld      hl,001ah
    ld      (0dde3h),hl
    ld      hl,l0000
    ld      (0de52h),hl
    ret     

    ret     

l11eb:  ld      hl,(0d586h)
    ld      (0de58h),hl
    call    l0e11
    ld      a,(0d578h)
    and     a
    jp      nz,l1208
    ld      a,(0d509h)
    res     3,a
    ld      (0d509h),a
    out     (8ah),a
    jp      l1212
l1208:  ld      a,(0d509h)
    set     3,a
    ld      (0d509h),a
    out     (8ah),a
l1212:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d577h),a
l1220:  ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
    ld      hl,(0d579h)
    ld      a,h
    or      l
    jp      nz,l1220
    ld      a,(0d57bh)
    and     a
    jp      z,l124a
    dec     a
    ld      (0d57bh),a
l123f:  ld      hl,(0d579h)
    ld      a,h
    or      l
    jp      z,l123f
    jp      l1220
l124a:  ld      a,00h
    ld      (0d577h),a
    ret     

l1250:  ld      hl,(0d586h)
    ld      (0de58h),hl
    call    l0e11
    ld      a,(0d578h)
    and     a
    jp      nz,l126d
    ld      a,(0d509h)
    res     3,a
    ld      (0d509h),a
    out     (8ah),a
    jp      l1277
l126d:  ld      a,(0d509h)
    set     3,a
    ld      (0d509h),a
    out     (8ah),a
l1277:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d577h),a
    ret     

l1286:  in      a,(8ch)
    bit     2,a
    jp      z,l129b
    ld      a,00h
    ld      (0d578h),a
    ld      hl,0032h
    ld      (0d579h),hl
    call    l11eb
l129b:  ld      a,00h
    ld      (0d578h),a
    ld      hl,07d0h
    ld      (0d579h),hl
    call    l1250
l12a9:  in      a,(8ch)
    bit     2,a
    jp      z,l12a9
    ld      a,00h
    ld      (0d577h),a
    ret     

l12b6:  push    ix
    pop     de
    ld      hl,868dh
    ld      bc,0004h
    ldir    
    ret     

l12c2:  in      a,(8ch)
    bit     0,a
    jp      z,l12d6
    ld      (ix+00h),41h
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     

l12d6:  ld      (ix+00h),41h
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

l12e3:  in      a,(8ch)
    bit     1,a
    jp      z,l12f7
    ld      (ix+00h),42h
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     

l12f7:  ld      (ix+00h),42h
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

l1304:  in      a,(8ch)
    bit     3,a
    jp      z,l1318
    ld      (ix+00h),43h
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     

l1318:  ld      (ix+00h),43h
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

l1325:  in      a,(8ch)
    bit     4,a
    jp      z,l1339
    ld      (ix+00h),44h
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     

l1339:  ld      (ix+00h),44h
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

l1346:  ld      (ix+00h),58h
    ld      (ix+01h),57h
    push    ix
    ld      hl,(0dde3h)
    ld      (0d598h),hl
    ld      a,00h
    ld      (0d59ah),a
    call    l8167
    pop     ix
    ld      a,(0d59fh)
    ld      (ix+02h),a
    ld      a,(0d59eh)
    ld      (ix+03h),a
    ld      hl,(0de52h)
    ld      a,h
    bit     7,a
    jp      z,l1387
    ld      a,2dh
    ld      (ix+04h),a
    ld      hl,l0000
    ld      de,(0de52h)
    and     a
    sbc     hl,de
    jp      l138f
l1387:  ld      a,2bh
    ld      (ix+04h),a
    ld      hl,(0de52h)
l138f:  push    ix
    ld      (0d598h),hl
    ld      a,00h
    ld      (0d59ah),a
    call    l8167
    pop     ix
    ld      a,(0d5a0h)
    ld      (ix+05h),a
    ld      a,(0d59fh)
    ld      (ix+06h),a
    ld      a,(0d59eh)
    ld      (ix+07h),a
    ld      a,40h
    ld      (ix+08h),a
    ret     

l13b6:  ld      a,00h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    set     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
l13de:  call    l159e
l13e1:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,l18cc
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     bc
    ld      a,(0d514h)
    xor     b
    jp      nz,l13de
    in      a,(3ch)
    bit     3,a
    jp      nz,l1432
    bit     4,a
    jp      nz,l1495
    bit     7,a
    jp      nz,l14f8
    in      a,(3eh)
    bit     3,a
    jp      nz,l150a
    call    l2639
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l151c
    cp      52h
    jp      z,l152b
    cp      47h
    jp      z,l157d
    jp      l13e1
l1432:  ld      hl,l0000
    ld      (0d51eh),hl
    call    l2680
l143b:  ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54ch)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l1467
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      m,l1460
    inc     hl
    inc     hl
    inc     hl
    inc     hl
l1460:  inc     hl
    ld      (0d040h),hl
    jp      l1470
l1467:  ld      hl,(0d54eh)
    ld      (0d040h),hl
    call    l159e
l1470:  call    l159e
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl
    ld      hl,0032h
    ld      (0d522h),hl
    call    l265f
    in      a,(3ch)
    bit     3,a
    jp      nz,l143b
    call    l24d9
    jp      l13de
l1495:  ld      hl,l0000
    ld      (0d51eh),hl
    call    l2680
l149e:  ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54eh)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l14cd
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l14c6
    jp      m,l14c6
    dec     hl
    dec     hl
    dec     hl
    dec     hl
l14c6:  dec     hl
    ld      (0d040h),hl
    jp      l14d3
l14cd:  ld      hl,(0d54ch)
    ld      (0d040h),hl
l14d3:  call    l159e
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl
    ld      hl,0032h
    ld      (0d522h),hl
    call    l265f
    in      a,(3ch)
    bit     4,a
    jp      nz,l149e
    call    l24d9
    jp      l13de
l14f8:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l212a
    jp      l13e1
l150a:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l2169
    jp      l13e1
l151c:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l15c8
l152b:  call    l2680
    ld      de,(0d040h)
    ld      hl,(0d54ch)
    and     a
    sbc     hl,de
    jp      z,l1565
    ld      hl,(0d54ch)
l153e:  ld      bc,00c8h
    and     a
    sbc     hl,bc
    jp      z,l1558
    jp      m,l1558
    and     a
    push    hl
    sbc     hl,de
    pop     hl
    jp      z,l155b
    jp      m,l155b
    jp      l153e
l1558:  ld      hl,l0000
l155b:  ld      de,00c8h
    add     hl,de
    ld      (0d040h),hl
    jp      l156b
l1565:  ld      hl,(0d54eh)
    ld      (0d040h),hl
l156b:  call    l24d9
    call    l159e
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l13de
l157d:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    l1e9c
    ld      a,00h
    ld      (0d54bh),a
    jp      l13de
l159e:  ld      hl,(0d040h)
    ld      a,h
    ld      (0d599h),a
    ld      a,l
    ld      (0d598h),a
    call    l8120
    ld      a,(0d5a1h)
    ld      (0d510h),a
    ld      a,(0d5a0h)
    ld      (0d511h),a
    ld      a,(0d59fh)
    ld      (0d512h),a
    ld      a,(0d59eh)
    ld      (0d513h),a
    call    l245b
    ret     

l15c8:  ld      a,01h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    res     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      hl,l0000
    ld      (0d50ch),hl
l15f6:  call    l1713
l15f9:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,l1ab3
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l15c8
    in      a,(3ch)
    bit     3,a
    jp      nz,l16bd
    bit     4,a
    jp      nz,l16e8
    bit     7,a
    jp      nz,l164b
    in      a,(3eh)
    bit     3,a
    jp      nz,l165d
    call    l2639
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l166f
    cp      43h
    jp      z,l169f
    cp      47h
    jp      z,l167e
    jp      l15f9
l164b:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l212a
    jp      l15f6
l165d:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l2169
    jp      l15f6
l166f:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1749
l167e:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    l1e9c
    ld      a,00h
    ld      (0d54bh),a
    jp      l15f6
l169f:  call    l2680
    ld      hl,0032h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    xor     01h
    ld      (hl),a
    call    l24d9
    jp      l15f6
l16bd:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50ch)
    ld      bc,(0d517h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l16df
    inc     hl
    ld      (0d50ch),hl
    jp      l15f6
l16df:  ld      hl,(0d515h)
    ld      (0d50ch),hl
    jp      l15f6
l16e8:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50ch)
    ld      bc,(0d515h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l170a
    dec     hl
    ld      (0d50ch),hl
    jp      l15f6
l170a:  ld      hl,(0d517h)
    ld      (0d50ch),hl
    jp      l15f6
l1713:  ld      bc,(0d50ch)
    inc     bc
    ld      (0d598h),bc
    call    l8120
    ld      a,(0d59fh)
    ld      (0d510h),a
    ld      a,(0d59eh)
    ld      (0d511h),a
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    ld      (0d598h),a
    call    l8120
    ld      a,(0d59eh)
    ld      (0d513h),a
    ld      a,0ah
    ld      (0d512h),a
    call    l245b
    ret     

l1749:  ld      a,02h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ah
    ld      (0d510h),a
    ld      (0d511h),a
    ld      (0d512h),a
    ld      (0d513h),a
    call    l245b
l1782:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,l1749
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    cp      b
    jp      nz,l13b6
    call    l2599
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l17bc
    cp      55h
    jp      z,l17cb
    cp      44h
    jp      z,l17e0
    jp      l1782
l17bc:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l13b6
l17cb:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      l17f5
l17e0:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      l17f5
l17f5:  call    l18ab
l17f8:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,l1bff
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l13b6
    call    l2599
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l1837
    cp      43h
    jp      z,l1846
    cp      55h
    jp      z,l1855
    cp      44h
    jp      z,l1880
    jp      l17f8
l1837:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l13b6
l1846:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1d61
l1855:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50eh)
    ld      bc,(0d51bh)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l1877
    inc     hl
    ld      (0d50eh),hl
    jp      l17f5
l1877:  ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      l17f5
l1880:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50eh)
    ld      bc,(0d519h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l18a2
    dec     hl
    ld      (0d50eh),hl
    jp      l17f5
l18a2:  ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      l17f5
l18ab:  ld      hl,(0d50eh)
    ld      (0d598h),hl
    call    l8120
    ld      a,(0d59fh)
    ld      (0d511h),a
    ld      a,(0d59eh)
    ld      (0d512h),a
    ld      a,0fh
    ld      (0d510h),a
    ld      (0d513h),a
    call    l245b
    ret     

l18cc:  ld      a,03h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    set     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a
l18f4:  call    l159e
l18f7:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l13b6
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l18f4
    in      a,(3ch)
    bit     3,a
    jp      nz,l1949
    bit     4,a
    jp      nz,l19a9
    bit     7,a
    jp      nz,l1a0c
    in      a,(3eh)
    bit     3,a
    jp      nz,l1a20
    call    l2639
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l1a34
    cp      52h
    jp      z,l1a43
    cp      47h
    jp      z,l1a95
    jp      l18f7
l1949:  ld      hl,l0000
    ld      (0d51eh),hl
    call    l2680
l1952:  ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54ch)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l197e
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      m,l1977
    inc     hl
    inc     hl
    inc     hl
    inc     hl
l1977:  inc     hl
    ld      (0d040h),hl
    jp      l1984
l197e:  ld      hl,(0d54eh)
    ld      (0d040h),hl
l1984:  call    l159e
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl
    ld      hl,0032h
    ld      (0d522h),hl
    call    l265f
    in      a,(3ch)
    bit     3,a
    jp      nz,l1952
    call    l24d9
    jp      l18f4
l19a9:  ld      hl,l0000
    ld      (0d51eh),hl
    call    l2680
l19b2:  ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54eh)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l19e1
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,l19da
    jp      m,l19da
    dec     hl
    dec     hl
    dec     hl
    dec     hl
l19da:  dec     hl
    ld      (0d040h),hl
    jp      l19e7
l19e1:  ld      hl,(0d54ch)
    ld      (0d040h),hl
l19e7:  call    l159e
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl
    ld      hl,0032h
    ld      (0d522h),hl
    call    l265f
    in      a,(3ch)
    bit     4,a
    jp      nz,l19b2
    call    l24d9
    jp      l18f4
l1a0c:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d560h),a
    jp      l18f7
l1a20:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d560h),a
    jp      l18f7
l1a34:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1ab3
l1a43:  call    l2680
    ld      de,(0d040h)
    ld      hl,(0d54ch)
    and     a
    sbc     hl,de
    jp      z,l1a7d
    ld      hl,(0d54ch)
l1a56:  ld      bc,00c8h
    and     a
    sbc     hl,bc
    jp      z,l1a70
    jp      m,l1a70
    and     a
    push    hl
    sbc     hl,de
    pop     hl
    jp      z,l1a73
    jp      m,l1a73
    jp      l1a56
l1a70:  ld      hl,l0000
l1a73:  ld      de,00c8h
    add     hl,de
    ld      (0d040h),hl
    jp      l1a83
l1a7d:  ld      hl,0002h
    ld      (0d040h),hl
l1a83:  call    l24d9
    call    l159e
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l18f4
l1a95:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d551h),a
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d54bh),a
    jp      l18f4
l1ab3:  ld      a,04h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    res     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      hl,l0000
    ld      (0d50ch),hl
l1ae1:  call    l1713
l1ae4:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l15c8
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l1ab3
    in      a,(3ch)
    bit     3,a
    jp      nz,l1ba9
    bit     4,a
    jp      nz,l1bd4
    bit     7,a
    jp      nz,l1b36
    in      a,(3eh)
    bit     3,a
    jp      nz,l1b4a
    call    l2639
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l1b5e
    cp      43h
    jp      z,l1b8b
    cp      47h
    jp      z,l1b6d
    jp      l1ae4
l1b36:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d560h),a
    jp      l1ae1
l1b4a:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d560h),a
    jp      l1ae1
l1b5e:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1bff
l1b6d:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d551h),a
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d54bh),a
    jp      l1ae1
l1b8b:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    xor     01h
    ld      (hl),a
    call    l24d9
    jp      l1ae1
l1ba9:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50ch)
    ld      bc,(0d517h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l1bcb
    inc     hl
    ld      (0d50ch),hl
    jp      l1bd1
l1bcb:  ld      hl,(0d515h)
    ld      (0d50ch),hl
l1bd1:  jp      l1ae1
l1bd4:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50ch)
    ld      bc,(0d515h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l1bf6
    dec     hl
    ld      (0d50ch),hl
    jp      l1bfc
l1bf6:  ld      hl,(0d517h)
    ld      (0d50ch),hl
l1bfc:  jp      l1ae1
l1bff:  ld      a,05h
    ld      (0d001h),a
    call    l80b9
    ld      a,(0d500h)
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ah
    ld      (0d510h),a
    ld      (0d511h),a
    ld      (0d512h),a
    ld      (0d513h),a
    call    l245b
l1c38:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1749
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    cp      b
    jp      nz,l18cc
    call    l2599
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l1c72
    cp      55h
    jp      z,l1c81
    cp      44h
    jp      z,l1c96
    jp      l1c38
l1c72:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l18cc
l1c81:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      l1cab
l1c96:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      l1cab
l1cab:  call    l18ab
l1cae:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1749
    ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l18cc
    call    l2599
    ld      a,(0d51dh)
    cp      4dh
    jp      z,l1ced
    cp      43h
    jp      z,l1cfc
    cp      55h
    jp      z,l1d0b
    cp      44h
    jp      z,l1d36
    jp      l1cae
l1ced:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l18cc
l1cfc:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1d61
l1d0b:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50eh)
    ld      bc,(0d51bh)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l1d2d
    inc     hl
    ld      (0d50eh),hl
    jp      l1cab
l1d2d:  ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      l1cab
l1d36:  call    l2680
    ld      hl,00c8h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d50eh)
    ld      bc,(0d519h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,l1d58
    dec     hl
    ld      (0d50eh),hl
    jp      l1cab
l1d58:  ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      l1cab
l1d61:  ld      a,0bh
    ld      (0d510h),a
    ld      a,1dh
    ld      (0d511h),a
    ld      a,7eh
    ld      (0d512h),a
    ld      a,3dh
    ld      (0d513h),a
    call    l249a
l1d78:  ld      a,(0d001h)
    cp      05h
    jp      z,l1d8b
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1d96
l1d8b:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1749
l1d96:  ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l13b6
    call    l2599
    ld      a,(0d51dh)
    cp      43h
    jp      z,l1dc0
    cp      47h
    jp      z,l1dcf
    jp      l1d78
l1dc0:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    jp      l1df8
l1dcf:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,0d05ah
    ld      de,001ah
    ld      bc,(0d50eh)
    ld      a,c
    ld      b,a
l1de7:  add     hl,de
    djnz    l1de7
    ld      de,0d040h
    ld      bc,001ah
    ldir    
    call    l24d9
    jp      l13b6
l1df8:  ld      a,57h
    ld      (0d510h),a
    ld      a,7eh
    ld      (0d511h),a
    ld      a,3bh
    ld      (0d512h),a
    ld      a,4fh
    ld      (0d513h),a
    call    l249a
l1e0f:  ld      a,(0d001h)
    cp      05h
    jp      z,l1e22
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1e2d
l1e22:  ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,l1749
l1e2d:  ld      a,(0dddfh)
    and     a
    call    nz,l06f2
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,l13b6
    call    l2599
    ld      a,(0d51dh)
    cp      43h
    jp      z,l1e57
    cp      47h
    jp      z,l1e71
    jp      l1e0f
l1e57:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,(0d001h)
    cp      05h
    jp      z,l1e6e
    jp      l17f5
l1e6e:  jp      l1cab
l1e71:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,0d05ah
    ld      de,001ah
    ld      a,(0d50eh)
    ld      b,a
l1e87:  add     hl,de
    djnz    l1e87
    ld      a,l
    ld      e,a
    ld      a,h
    ld      d,a
    ld      hl,0d040h
    ld      bc,001ah
    ldir    
    call    l803d
    jp      l13b6
l1e9c:  ld      a,(0d588h)
    and     a
    call    nz,l21a8
    ld      a,03h
    ld      (0d5b0h),a
    ld      a,(0d514h)
    push    af
    call    l24fe
    pop     bc
    ld      a,(0d514h)
    xor     b
    jp      nz,l26fb
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
    ld      a,(0d532h)
    cp      00h
    jp      z,l1f17
    cp      01h
    jp      z,l1f2e
    cp      02h
    jp      z,l1f3f
    cp      03h
    jp      z,l1f8d
    cp      04h
    jp      z,l1f9b
    cp      05h
    jp      z,l1fc0
    cp      06h
    jp      z,l1fde
    cp      07h
    jp      z,l2018
    cp      08h
    jp      z,l2055
    cp      09h
    jp      z,l206f
    cp      0ah
    jp      z,l207d
    cp      0bh
    jp      z,l20a2
    cp      0ch
    jp      z,l20c0
    cp      0dh
    jp      z,l20d1
    cp      0eh
    jp      z,l20ff
    cp      0fh
    jp      z,l2110
    ret     

l1f17:  call    l1f24
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1f24:  ld      hl,l0000
    ld      (0d533h),hl
    call    l80f6
    ret     

l1f2e:  call    l1f3b
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1f3b:  call    l103c
    ret     

l1f3f:  call    l1f4c
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1f4c:  ld      hl,(0d003h)
    ld      (0d586h),hl
    call    l1286
    ld      a,00h
    ld      (0d578h),a
    ld      hl,(0d003h)
    ld      (0d586h),hl
    ld      hl,0190h
    ld      (0d579h),hl
    ld      a,00h
    ld      (0d57bh),a
    call    l1250
l1f6e:  ld      hl,(0d579h)
    ld      a,l
    or      h
    jp      z,l1f79
    jp      l1f6e
l1f79:  ld      a,(0d57bh)
    and     a
    jp      z,l1f87
    dec     a
    ld      (0d57bh),a
    jp      l1f6e
l1f87:  ld      a,00h
    ld      (0d577h),a
    ret     

l1f8d:  call    l1f9a
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1f9a:  ret     

l1f9b:  call    l1fb3
    jp      c,l1fab
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1fab:  ld      a,07h
    ld      (0d532h),a
    jp      l1e9c
l1fb3:  ld      hl,0d042h
    ld      bc,(0d533h)
    add     hl,bc
    ld      a,(hl)
    and     a
    ret     nz

    scf     
    ret     

l1fc0:  call    l1fcd
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1fcd:  ld      hl,(0d533h)
    inc     hl
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    l0f59
    ret     

l1fde:  call    l1feb
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l1feb:  ld      hl,(0d535h)
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d003h)
    ld      (0d586h),hl
    ld      hl,(0d589h)
    ld      (0d579h),hl
    ld      a,(0d58bh)
    ld      (0d57bh),a
    call    l11eb
    ld      hl,(0d537h)
    ld      (0d562h),hl
    call    l26c3
    ret     

l2018:  call    l203f
    jp      c,l2026
    ld      a,04h
    ld      (0d532h),a
    jp      l1e9c
l2026:  ld      a,(0d514h)
    and     a
    jp      nz,l2035
    ld      a,0eh
    ld      (0d532h),a
    jp      l1e9c
l2035:  ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l203f:  ld      hl,(0d517h)
    ld      bc,(0d533h)
    and     a
    sbc     hl,bc
    jp      z,l2053
    inc     bc
    ld      (0d533h),bc
    and     a
    ret     

l2053:  scf     
    ret     

l2055:  call    l2062
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l2062:  call    l1183
    ld      hl,00fah
    ld      (0d562h),hl
    call    l26c3
    ret     

l206f:  call    l207c
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l207c:  ret     

l207d:  call    l2095
    jp      c,l208d
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l208d:  ld      a,0dh
    ld      (0d532h),a
    jp      l1e9c
l2095:  ld      hl,0d042h
    ld      bc,(0d533h)
    add     hl,bc
    ld      a,(hl)
    and     a
    ret     nz

    scf     
    ret     

l20a2:  call    l20af
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l20af:  ld      hl,(0d533h)
    inc     hl
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    l0f59
    ret     

l20c0:  call    l20cd
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l20cd:  call    l1feb
    ret     

l20d1:  call    l20e9
    jp      c,l20df
    ld      a,0ah
    ld      (0d532h),a
    jp      l1e9c
l20df:  ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l20e9:  ld      hl,(0d515h)
    ld      bc,(0d533h)
    and     a
    sbc     hl,bc
    jp      z,l20fd
    dec     bc
    ld      (0d533h),bc
    and     a
    ret     

l20fd:  scf     
    ret     

l20ff:  call    l210c
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      l1e9c
l210c:  call    l103c
    ret     

l2110:  ld      a,(0d5dah)
    and     a
    ret     z

    ld      a,(0d001h)
    cp      00h
    call    z,l159e
    cp      01h
    call    z,l1713
    ld      a,00h
    ld      (0d532h),a
    jp      l1e9c
l212a:  ld      a,04h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     0,a
    jp      nz,l26fb
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
l2142:  ld      a,00h
    ld      (0d578h),a
    ld      hl,(0d580h)
    ld      (0d586h),hl
    call    l1250
l2150:  ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
    in      a,(3ch)
    bit     7,a
    jp      nz,l2150
    ld      a,00h
    ld      (0d577h),a
    ret     

l2169:  ld      a,04h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     0,a
    jp      nz,l26fb
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
l2181:  ld      a,01h
    ld      (0d578h),a
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    call    l1250
l218f:  ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
    in      a,(3eh)
    bit     3,a
    jp      nz,l218f
    ld      a,00h
    ld      (0d577h),a
    ret     

l21a8:  push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    l26ad
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
l21ca:  ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
l21d2:  ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
l21da:  ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    l21da
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    l21d2
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    l21ca
    call    l26b8
l21fd:  call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      z,l2210
    cp      52h
    jp      z,l221d
    jp      l21fd
l2210:  call    l2680
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

l221d:  call    l2680
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    call    l103c
    pop     af
    ret     

    push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    l26ad
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
l2250:  ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
l2258:  ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
l2260:  ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    l2260
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    l2258
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    l2250
    call    l26b8
l2283:  call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      z,l2296
    cp      52h
    jp      z,l22a3
    jp      l2283
l2296:  call    l2680
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

l22a3:  call    l2680
    ld      a,10h
    ld      (0d551h),a
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

l22b5:  push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    l26ad
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
l22d7:  ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
l22df:  ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
l22e7:  ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    l22e7
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    l22df
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    l22d7
    call    l26b8
l230a:  ld      a,(0de5ah)
    and     a
    jp      z,l231b
    ld      a,(0de5bh)
    and     a
    jp      nz,l2320
    jp      l230a
l231b:  pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

l2320:  ld      a,00h
    ld      (0de5bh),a
    ld      (0de5ah),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    call    l103c
    ld      a,00h
    ld      (0dddfh),a
    ret     

l2335:  ld      hl,0d000h
    ld      de,0d4ffh
l233b:  ld      a,00h
    ld      (hl),a
    and     a
    inc     hl
    push    hl
    sbc     hl,de
    pop     hl
    jp      nz,l233b
    ld      a,0aah
    ld      (0d000h),a
    ld      a,00h
    ld      (0d001h),a
    ld      hl,0005h
    ld      (0d040h),hl
    ld      a,18h
    ld      b,a
    ld      a,01h
    ld      ix,0d042h
l2360:  ld      (ix+00h),a
    inc     ix
    djnz    l2360
    ld      hl,0d040h
    ld      de,0d05ah
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d074h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d08eh
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d0a8h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d0c2h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d0dch
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d0f6h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d110h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d12ah
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d144h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d15eh
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d178h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d192h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d1ach
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d1c6h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d1e0h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d1fah
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d214h
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d22eh
    ld      bc,001ah
    ldir    
    ld      hl,0d040h
    ld      de,0d248h
    ld      bc,001ah
    ldir    
    ld      a,01h
    ld      (0d002h),a
    ld      hl,(0d580h)
    ld      (0d003h),hl
    ld      hl,l0000
    ld      (0d005h),hl
    ld      (0d007h),hl
    call    l803d
    ret     

l245b:  ld      a,98h
    out     (81h),a
    ld      a,(0d510h)
    or      80h
    out     (80h),a
    ld      a,(0d511h)
    or      80h
    out     (80h),a
    ld      a,(0d512h)
    or      80h
    out     (80h),a
    ld      a,(0d513h)
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ret     

l249a:  ld      a,0b8h
    out     (81h),a
    ld      a,(0d510h)
    or      80h
    out     (80h),a
    ld      a,(0d511h)
    or      80h
    out     (80h),a
    ld      a,(0d512h)
    or      80h
    out     (80h),a
    ld      a,(0d513h)
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ret     

l24d9:  ld      a,(0d514h)
    and     a
    jp      nz,l24ef
    ld      hl,0d040h
    ld      de,0d05ah
    ld      bc,001ah
    ldir    
    call    l803d
    ret     

l24ef:  ld      hl,0d040h
    ld      de,0d15eh
    ld      bc,001ah
    ldir    
    call    l803d
    ret     

l24fe:  call    l2572
    in      a,(8ch)
    bit     3,a
    jp      nz,l253d
    ld      a,01h
    ld      (0d514h),a
    ld      hl,l0000
    ld      (0d515h),hl
    ld      hl,0017h
    ld      (0d517h),hl
    ld      hl,000bh
    ld      (0d519h),hl
    ld      hl,0013h
    ld      (0d51bh),hl
    ld      a,(0d501h)
    res     4,a
    set     5,a
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,0d15eh
    ld      de,0d040h
    ld      bc,001ah
    ldir    
    ret     

l253d:  ld      a,00h
    ld      (0d514h),a
    ld      hl,l0000
    ld      (0d515h),hl
    ld      hl,000bh
    ld      (0d517h),hl
    ld      hl,0001h
    ld      (0d519h),hl
    ld      hl,0009h
    ld      (0d51bh),hl
    ld      a,(0d501h)
    set     4,a
    res     5,a
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,0d05ah
    ld      de,0d040h
    ld      bc,001ah
    ldir    
    ret     

l2572:  ld      a,(0d514h)
    and     a
    jp      nz,l2584
    jp      l257c
l257c:  in      a,(8ch)
    bit     3,a
    ret     nz

    jp      l258c
l2584:  in      a,(8ch)
    bit     3,a
    ret     z

    jp      l258c
l258c:  ld      hl,0063h
    ld      (0dde3h),hl
    ld      hl,l0000
    ld      (0de52h),hl
    ret     

l2599:  ld      a,00h
    ld      (0d51dh),a
    in      a,(3ch)
    bit     0,a
    jp      nz,l25f1
    bit     1,a
    jp      nz,l25f9
    bit     2,a
    jp      nz,l2601
    bit     3,a
    jp      nz,l2609
    bit     4,a
    jp      nz,l2611
    bit     5,a
    jp      nz,l2619
    bit     6,a
    jp      nz,l2621
    bit     7,a
    jp      nz,l2629
    in      a,(3eh)
    bit     3,a
    jp      nz,l2631
    ret     

l25d0:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    in      a,(3ch)
    and     a
    jp      nz,l25d0
    ret     

l25e0:  ld      hl,0001h
    ld      (0d562h),hl
    call    l26c3
    in      a,(3eh)
    bit     3,a
    jp      nz,l25e0
    ret     

l25f1:  ld      a,4dh
    ld      (0d51dh),a
    jp      l25d0
l25f9:  ld      a,52h
    ld      (0d51dh),a
    jp      l25d0
l2601:  ld      a,43h
    ld      (0d51dh),a
    jp      l25d0
l2609:  ld      a,55h
    ld      (0d51dh),a
    jp      l25d0
l2611:  ld      a,44h
    ld      (0d51dh),a
    jp      l25d0
l2619:  ld      a,47h
    ld      (0d51dh),a
    jp      l25d0
l2621:  ld      a,53h
    ld      (0d51dh),a
    jp      l25d0
l2629:  ld      a,46h
    ld      (0d51dh),a
    jp      l25d0
l2631:  ld      a,42h
    ld      (0d51dh),a
    jp      l25e0
l2639:  ld      a,00h
    ld      (0d51dh),a
    in      a,(3ch)
    bit     0,a
    jp      nz,l25f1
    bit     1,a
    jp      nz,l25f9
    bit     2,a
    jp      nz,l2601
    bit     5,a
    jp      nz,l2619
    bit     6,a
    jp      nz,l2621
    bit     7,a
    jp      nz,l2629
    ret     

l265f:  ld      hl,(0d51eh)
    ld      bc,(0d520h)
    and     a
    sbc     hl,bc
    jp      p,l2676
    ld      hl,(0d524h)
    ld      (0d562h),hl
    call    l26c3
    ret     

l2676:  ld      hl,(0d522h)
    ld      (0d562h),hl
    call    l26c3
    ret     

l2680:  call    l26ad
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      b,a
l268c:  ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
l2694:  ld      a,b
    ld      (0d527h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    l2694
    ld      a,0fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    l268c
    call    l26b8
    ret     

l26ad:  ld      a,(0d503h)
    set     1,a
    ld      (0d503h),a
    out     (3eh),a
    ret     

l26b8:  ld      a,(0d503h)
    res     1,a
    ld      (0d503h),a
    out     (3eh),a
    ret     

l26c3:  ld      hl,(0d562h)
    ld      a,l
    or      h
    ret     z

    ld      a,01h
    ld      (0d561h),a
l26ce:  ld      a,(0d550h)
    and     a
    jp      z,l26e1
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,l26fb
l26e1:  ld      hl,(0d562h)
    ld      a,l
    or      h
    jp      nz,l26ce
    ld      a,00h
    ld      (0d561h),a
    ret     

l26ef:  ld      hl,(0d562h)
    ld      a,l
    or      h
    ret     z

    ld      a,01h
    ld      (0d561h),a
    ret     

l26fb:  ld      a,(0de5ch)
    and     a
    jp      nz,l292c
    ld      a,01h
    ld      (0d52dh),a
    ld      a,(0d5b0h)
    cp      01h
    jp      z,l272b
    cp      02h
    jp      z,l272b
    cp      03h
    jp      z,l272b
    cp      04h
    jp      z,l279b
    cp      05h
    jp      z,l272b
    cp      06h
    jp      z,l2755
l2728:  jp      l2728
l272b:  ld      a,00h
    ld      (0d564h),a
    ld      (0d577h),a
    ld      a,00h
    ld      (0d550h),a
    call    l27fc
    call    l26ad
    call    l2812
    call    l2782
    call    l278d
    ld      hl,0064h
    ld      (0d562h),hl
    call    l26c3
    di      
    nop     
    jp      l0000
l2755:  call    l27fc
    call    l26ad
    ld      a,4fh
    ld      (0d510h),a
    ld      a,7bh
    ld      (0d511h),a
    ld      a,7bh
    ld      (0d512h),a
    ld      a,57h
    ld      (0d513h),a
    call    l249a
    call    l2782
    call    l278d
    ld      hl,0064h
    ld      (0d562h),hl
    call    l26c3
    ret     

l2782:  in      a,(3ch)
    and     40h
    jp      z,l2782
    call    l26b8
    ret     

l278d:  in      a,(3ch)
    and     02h
    jp      z,l278d
    call    l2680
    call    l2807
    ret     

l279b:  call    l27fc
    call    l26ad
    ld      a,4bh
    ld      (0d510h),a
    ld      a,7bh
    ld      (0d511h),a
    ld      a,7bh
    ld      (0d512h),a
    ld      a,30h
    ld      (0d513h),a
    call    l249a
    call    l27be
    jp      l27c9
l27be:  in      a,(3ch)
    and     40h
    jp      z,l27be
    call    l26b8
    ret     

l27c9:  in      a,(3ch)
    bit     1,a
    jp      nz,l27df
    bit     7,a
    jp      nz,l27ea
    in      a,(3eh)
    bit     3,a
    jp      nz,l27f3
    jp      l27c9
l27df:  call    l2680
    call    l2807
    di      
    nop     
    jp      l0000
l27ea:  call    l2680
    call    l2807
    jp      l2142
l27f3:  call    l2680
    call    l2807
    jp      l2181
l27fc:  ld      a,(0d501h)
    set     6,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

l2807:  ld      a,(0d501h)
    res     6,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

l2812:  ld      a,0bh
    ld      (0d510h),a
    ld      a,00h
    ld      (0d511h),a
    ld      hl,l0000
    ld      a,(0d5b0h)
    ld      l,a
    ld      (0d598h),hl
    call    l8120
    ld      a,(0d59fh)
    ld      (0d512h),a
    ld      a,(0d59eh)
    ld      (0d513h),a
    call    l245b
    ret     

    ld      a,01h
    ld      (0d52dh),a
    ld      a,(0d5b1h)
    cp      01h
    jp      z,l2847
    ret     

l2847:  call    l287c
    call    l26ad
    call    l2892
    call    l285a
    call    l2865
    di      
    jp      l0000
l285a:  in      a,(3ch)
    and     40h
    jp      z,l285a
    call    l26b8
    ret     

l2865:  in      a,(3ch)
    and     02h
    jp      z,l2865
    call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l2887
    ret     

l287c:  ld      a,(0d501h)
    set     7,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

l2887:  ld      a,(0d501h)
    res     7,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

l2892:  ld      a,68h
    out     (81h),a
    ret     

    ld      a,00h
    ld      (0d5b2h),a
    ld      a,01h
    ld      (0d52dh),a
    ld      hl,0005h
    ld      (0d562h),hl
    call    l26c3
    in      a,(2ah)
    cp      31h
    jp      z,l28d5
    cp      32h
    jp      z,l28d5
    cp      33h
    jp      z,l28d5
    cp      34h
    jp      z,l28d5
    cp      35h
    jp      z,l28d5
    cp      36h
    jp      z,l28d5
    cp      37h
    jp      z,l28f2
    cp      38h
    jp      z,l28d5
    ret     

l28d5:  call    l27fc
    call    l26ad
    call    l2916
    call    l28fd
    call    l2908
    ld      hl,0064h
    ld      (0d562h),hl
    call    l26c3
    di      
    nop     
    jp      l0000
l28f2:  ld      a,00h
    ld      (0d52dh),a
    ld      a,01h
    ld      (0d5b3h),a
    ret     

l28fd:  in      a,(3ch)
    and     40h
    jp      z,l28fd
    call    l26b8
    ret     

l2908:  in      a,(3ch)
    and     02h
    jp      z,l2908
    call    l2680
    call    l2807
    ret     

l2916:  ld      a,0bh
    ld      (0d510h),a
    ld      a,01h
    ld      (0d511h),a
    ld      a,00h
    ld      (0d512h),a
    ld      (0d513h),a
    call    l245b
    ret     

l292c:  ld      a,(0d5b0h)
    cp      01h
    jp      z,l2950
    cp      02h
    jp      z,l2950
    cp      03h
    jp      z,l2950
    cp      04h
    jp      z,l2950
    cp      05h
    jp      z,l2950
    cp      06h
    jp      z,l2950
l294d:  jp      l294d
l2950:  ld      a,00h
    ld      (0d564h),a
    ld      (0d577h),a
    call    l2963
    ld      a,00h
    ld      (0dddfh),a
    jp      l06aa
l2963:  ld      a,45h
    ld      (0dde8h),a
    ld      a,30h
    ld      (0dde9h),a
    ld      a,40h
    ld      (0ddebh),a
    ld      a,(0d5b0h)
    cp      01h
    jp      z,l2996
    cp      02h
    jp      z,l299f
    cp      03h
    jp      z,l29a8
    cp      04h
    jp      z,l29b1
    cp      05h
    jp      z,l29ba
    cp      06h
    jp      z,l29c3
l2993:  jp      l2993
l2996:  ld      a,31h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l299f:  ld      a,32h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l29a8:  ld      a,33h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l29b1:  ld      a,34h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l29ba:  ld      a,35h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l29c3:  ld      a,36h
    ld      (0ddeah),a
    call    l0d3c
    ret     

l29cc:  call    l2335
    ld      a,0bh
    ld      (0d510h),a
    ld      a,0ah
    ld      (0d511h),a
    ld      a,4eh
    ld      (0d512h),a
    ld      a,4fh
    ld      (0d513h),a
    call    l249a
l29e6:  call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      z,l29f9
    cp      43h
    jp      z,l2a10
    jp      l29e6
l29f9:  call    l2680
    call    l24fe
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d5dah),a
    jp      l0531
l2a10:  call    l2680
    jp      l2a16
l2a16:  ld      a,00h
    ld      (0d510h),a
    ld      a,0ch
    ld      (0d511h),a
    ld      a,19h
    ld      (0d512h),a
    ld      a,1ch
    ld      (0d513h),a
    call    l249a
l2a2d:  call    l2599
    ld      a,(0d51dh)
    cp      43h
    jp      z,l2afe
    cp      47h
    call    z,l2a40
    jp      l2a2d
l2a40:  call    l2680
    ld      hl,03e8h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d52ah),a
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,01h
    ld      (0d54bh),a
l2a5f:  ld      a,(0d588h)
    and     a
    call    nz,l21a8
    call    l159e
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d56ch),hl
    ld      hl,0ffffh
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d564h),a
    ld      a,00h
    ld      (0d578h),a
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    ld      hl,0ffffh
    ld      (0d579h),hl
    call    l1250
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d577h),a
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d56ch),hl
    ld      hl,0ffffh
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a
    call    l0ee6
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d564h),a
    ld      a,01h
    ld      (0d578h),a
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    ld      hl,0ffffh
    ld      (0d579h),hl
    call    l1250
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d577h),a
    jp      l2a5f
l2afe:  call    l2680
    jp      l29cc
l2b04:  ld      a,(0d002h)
    cp      01h
    jp      z,l2b16
    cp      02h
    jp      z,l2b41
    cp      03h
    jp      z,l2b6c
l2b16:  ld      a,0f8h
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0b0h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      l2b97
l2b41:  ld      a,0f8h
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0edh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      l2b97
l2b6c:  ld      a,0f8h
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0f5h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      l2b97
l2b97:  in      a,(3ch)
    cp      04h
    jp      nz,l2b97
    jp      l2ba1
l2ba1:  call    l2680
l2ba4:  ld      hl,0032h
    ld      (0d562h),hl
    call    l26c3
    in      a,(3ch)
    and     04h
    jp      nz,l2ba4
    ld      a,(0d002h)
    cp      01h
    jp      z,l2bc6
    cp      02h
    jp      z,l2bd7
    cp      03h
    jp      z,l2be8
l2bc6:  ld      a,02h
    ld      (0d002h),a
    ld      hl,(0d582h)
    ld      (0d003h),hl
    call    l80b9
    jp      l2b04
l2bd7:  ld      a,03h
    ld      (0d002h),a
    ld      hl,(0d584h)
    ld      (0d003h),hl
    call    l80b9
    jp      l2b04
l2be8:  ld      a,01h
    ld      (0d002h),a
    ld      hl,(0d580h)
    ld      (0d003h),hl
    call    l80b9
    jp      l2b04
l2bf9:  ld      a,0f8h
    out     (81h),a
    ld      a,80h
    out     (80h),a
    ld      a,0eeh
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      hl,03e8h
    ld      (0d562h),hl
    call    l26c3
l2c2a:  call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      nz,l2c2a
    call    l2680
l2c38:  call    l103c
    ld      a,0f8h
    out     (81h),a
    ld      a,80h
    out     (80h),a
    ld      a,80h
    out     (80h),a
    ld      a,0f7h
    out     (80h),a
    ld      a,0dfh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
l2c63:  call    l24fe
    call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      nz,l2c63
    call    l2680
    call    l24fe
    ld      a,(0d514h)
    and     a
    jp      nz,l2c38
    ld      a,06h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      nz,l2c90
    call    l26fb
    jp      l2c38
l2c90:  call    l1f24
    ld      hl,0007h
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    l0f59
l2ca2:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      bc,(0d005h)
    ld      a,b
    and     80h
    jp      nz,l2cc1
    ld      a,0fh
    ld      (0d510h),a
    ld      hl,l0000
    add     hl,bc
    jp      l2ccc
l2cc1:  ld      a,0ah
    ld      (0d510h),a
    ld      hl,l0000
    and     a
    sbc     hl,bc
l2ccc:  ld      de,0064h
    call    l830d
    ld      a,c
    ld      (0d511h),a
    ld      de,000ah
    call    l830d
    ld      a,c
    ld      (0d512h),a
    ld      a,l
    ld      (0d513h),a
    call    l245b
    call    l2639
    ld      a,(0d51dh)
    cp      52h
    jp      z,l2d01
    in      a,(3ch)
    bit     3,a
    call    nz,l2ddc
    bit     4,a
    call    nz,l2e18
    jp      l2ca2
l2d01:  call    l2680
    call    l80b9
l2d07:  call    l103c
    ld      a,0f8h
    out     (81h),a
    ld      a,80h
    out     (80h),a
    ld      a,0f5h
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0b6h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
l2d32:  call    l24fe
    call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      nz,l2d32
    call    l2680
    call    l24fe
    ld      a,(0d514h)
    and     a
    jp      z,l2d07
    ld      a,06h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      nz,l2d5f
    call    l26fb
    jp      l2d07
l2d5f:  call    l1f24
    ld      hl,000dh
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    l0f59
l2d71:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      bc,(0d007h)
    ld      a,b
    and     80h
    jp      nz,l2d90
    ld      a,0fh
    ld      (0d510h),a
    ld      hl,l0000
    add     hl,bc
    jp      l2d9b
l2d90:  ld      a,0ah
    ld      (0d510h),a
    ld      hl,l0000
    and     a
    sbc     hl,bc
l2d9b:  ld      de,0064h
    call    l830d
    ld      a,c
    ld      (0d511h),a
    ld      de,000ah
    call    l830d
    ld      a,c
    ld      (0d512h),a
    ld      a,l
    ld      (0d513h),a
    call    l245b
    call    l2639
    ld      a,(0d51dh)
    cp      52h
    jp      z,l2dd0
    in      a,(3ch)
    bit     3,a
    call    nz,l2e54
    bit     4,a
    call    nz,l2e90
    jp      l2d71
l2dd0:  call    l2680
    call    l80b9
    call    l103c
    jp      l2bf9
l2ddc:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d005h)
    ld      bc,012ch
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d005h)
    inc     hl
    ld      (0d005h),hl
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    l0ee6
l2e0a:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l2e0a
    ld      a,00h
    ld      (0d564h),a
    ret     

l2e18:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d005h)
    ld      bc,0fed4h
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d005h)
    dec     hl
    ld      (0d005h),hl
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    l0ee6
l2e46:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l2e46
    ld      a,00h
    ld      (0d564h),a
    ret     

l2e54:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d007h)
    ld      bc,012ch
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d007h)
    inc     hl
    ld      (0d007h),hl
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    l0ee6
l2e82:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l2e82
    ld      a,00h
    ld      (0d564h),a
    ret     

l2e90:  ld      hl,0014h
    ld      (0d562h),hl
    call    l26c3
    ld      hl,(0d007h)
    ld      bc,0fed4h
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d007h)
    dec     hl
    ld      (0d007h),hl
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    l0ee6
l2ebe:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l2ebe
    ld      a,00h
    ld      (0d564h),a
    ret     

l2ecc:  ld      a,9eh
    out     (37h),a
    ld      a,0f2h
    out     (36h),a
    ld      a,04h
    out     (23h),a
    ld      hl,l0100
    ld      a,l
    out     (22h),a
    ld      a,h
    out     (22h),a
    ld      a,0f8h
    out     (81h),a
    ld      a,0feh
    out     (80h),a
    ld      a,8bh
    out     (80h),a
    ld      a,0ceh
    out     (80h),a
    ld      a,0feh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    call    l2680
    ld      hl,01f4h
    ld      (0d562h),hl
    call    l26c3
    call    l2335
    call    l24fe
l2f1b:  call    l2599
    ld      a,(0d51dh)
    cp      47h
    jp      z,l2f33
    cp      46h
    jp      z,l2f57
    cp      52h
    jp      z,l2f95
    jp      l2f1b
l2f33:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l24fe
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    l1e9c
    ld      a,00h
    ld      (0d54bh),a
    jp      l2f1b
l2f57:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0f43h
    ld      (0d568h),hl
    call    l0ee6
l2f77:  ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,l2f77
    ld      a,00h
    ld      (0d564h),a
l2f84:  call    l2599
    ld      a,(0d51dh)
    cp      52h
    jp      nz,l2f84
    call    l103c
    jp      l2f1b
l2f95:  call    l2680
    ld      hl,0096h
    ld      (0d562h),hl
    call    l26c3
    call    l103c
    jp      l2f1b
l2fa7:  jp      l2fa7

    defs    8000h - $

l8000:  ld      a,00h
    out     (13h),a
    ld      hl,l0000
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,04h
    out     (10h),a
    ld      hl,l0000
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,02h
    out     (11h),a
    ld      hl,0400h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,00h
    out     (13h),a
    ld      a,0a0h
    out     (13h),a
l802f:  in      a,(13h)
    and     01h
    in      a,(13h)
    jp      nz,l802f
    ld      a,80h
    out     (13h),a
    ret     

l803d:  di      
    ld      a,00h
    out     (13h),a
    ld      hl,l0000
    ld      (0d58ch),hl
    ld      a,02h
    ld      (0d58eh),a
    ld      hl,l0000
    ld      (0d58fh),hl
    ld      a,04h
    ld      (0d591h),a
    ld      a,02h
    out     (13h),a
    ld      hl,0040h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,10h
    ld      b,a
l8068:  push    bc
    ld      hl,(0d58ch)
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,(0d58eh)
    out     (10h),a
    ld      hl,(0d58fh)
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,(0d591h)
    out     (11h),a
    ld      a,0a0h
    out     (13h),a
    in      a,(10h)
    ld      (0d58ch),a
    in      a,(10h)
    ld      (0d58dh),a
    in      a,(10h)
    ld      (0d58eh),a
    in      a,(11h)
    ld      (0d58fh),a
    in      a,(11h)
    ld      (0d590h),a
    in      a,(11h)
    ld      (0d591h),a
    ld      hl,1964h
l80aa:  dec     hl
    ld      a,l
    or      h
    jp      nz,l80aa
    pop     bc
    djnz    l8068
    ld      a,80h
    out     (13h),a
    ei      
    ret     

l80b9:  ld      a,00h
    out     (13h),a
    ld      hl,l0000
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,02h
    out     (10h),a
    ld      hl,l0000
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,04h
    out     (11h),a
    ld      a,00h
    out     (13h),a
    ld      hl,0040h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,0a0h
    out     (13h),a
l80e8:  in      a,(13h)
    and     01h
    in      a,(13h)
    jp      nz,l80e8
    ld      a,80h
    out     (13h),a
    ret     

l80f6:  ld      a,00h
    ld      (0d589h),a
    ld      (0d58ah),a
    ld      (0d58bh),a
    ld      bc,0028h
    and     a
l8105:  ld      hl,(0d589h)
    ld      de,(0d040h)
    add     hl,de
    ld      (0d589h),hl
    ld      a,(0d58bh)
    ld      e,00h
    adc     a,e
    ld      (0d58bh),a
    dec     bc
    ld      a,c
    or      b
    jp      nz,l8105
    ret     

l8120:  ld      hl,(0d598h)
    ld      de,03e8h
    ld      bc,l0000
l8129:  and     a
    sbc     hl,de
    jp      m,l8133
    inc     bc
    jp      l8129
l8133:  ld      a,c
    ld      (0d5a1h),a
    add     hl,de
    ld      de,0064h
    ld      bc,l0000
l813e:  and     a
    sbc     hl,de
    jp      m,l8148
    inc     bc
    jp      l813e
l8148:  ld      a,c
    ld      (0d5a0h),a
    add     hl,de
    ld      de,000ah
    ld      bc,l0000
l8153:  and     a
    sbc     hl,de
    jp      m,l815d
    inc     bc
    jp      l8153
l815d:  ld      a,c
    ld      (0d59fh),a
    add     hl,de
    ld      a,l
    ld      (0d59eh),a
    ret     

l8167:  ld      a,00h
    ld      (0d59eh),a
    ld      (0d59fh),a
    ld      (0d5a0h),a
    ld      (0d5a1h),a
    ld      (0d5a2h),a
    ld      a,(0d598h)
    ld      (0d5a4h),a
    ld      a,(0d599h)
    ld      (0d5a5h),a
    ld      a,(0d59ah)
    ld      (0d5a6h),a
    ld      de,2710h
    ld      (0d5a7h),de
    ld      a,00h
    ld      (0d5a9h),a
    ld      e,00h
l8198:  push    de
    call    l834b
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,l81b6
    inc     e
    jp      l8198
l81b6:  ld      a,e
    ld      (0d5a2h),a
    call    l8332
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,03e8h
    ld      (0d5a7h),de
    ld      e,00h
l81d8:  push    de
    call    l834b
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,l81f6
    inc     e
    jp      l81d8
l81f6:  ld      a,e
    ld      (0d5a1h),a
    call    l8332
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,0064h
    ld      (0d5a7h),de
    ld      e,00h
l8218:  push    de
    call    l834b
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,l8236
    inc     e
    jp      l8218
l8236:  ld      a,e
    ld      (0d5a0h),a
    call    l8332
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,000ah
    ld      (0d5a7h),de
    ld      e,00h
l8258:  push    de
    call    l834b
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,l8276
    inc     e
    jp      l8258
l8276:  ld      a,e
    ld      (0d59fh),a
    call    l8332
    ld      a,(0d5aah)
    ld      (0d59eh),a
    ld      e,30h
    ld      a,(0d59eh)
    add     a,e
    ld      (0d59eh),a
    ld      a,(0d59fh)
    add     a,e
    ld      (0d59fh),a
    ld      a,(0d5a0h)
    add     a,e
    ld      (0d5a0h),a
    ld      a,(0d5a1h)
    add     a,e
    ld      (0d5a1h),a
    ld      a,(0d5a2h)
    add     a,e
    ld      (0d5a2h),a
    ret     

l82a9:  ld      a,00h
    ld      (0d59eh),a
    ld      (0d59fh),a
    ld      (0d5a0h),a
    ld      hl,l0000
    ld      de,0001h
    ld      a,(0d598h)
    sub     30h
    jp      z,l82c6
    ld      b,a
l82c3:  add     hl,de
    djnz    l82c3
l82c6:  ld      de,000ah
    ld      a,(0d599h)
    sub     30h
    jp      z,l82d5
    ld      b,a
l82d2:  add     hl,de
    djnz    l82d2
l82d5:  ld      de,0064h
    ld      a,(0d59ah)
    sub     30h
    jp      z,l82e4
    ld      b,a
l82e1:  add     hl,de
    djnz    l82e1
l82e4:  ld      de,03e8h
    ld      a,(0d59bh)
    sub     30h
    jp      z,l82f3
    ld      b,a
l82f0:  add     hl,de
    djnz    l82f0
l82f3:  ld      de,2710h
    ld      a,(0d59ch)
    sub     30h
    jp      z,l8309
    ld      b,a
    ld      a,00h
l8301:  add     hl,de
    adc     a,00h
    djnz    l8301
    ld      (0d5a0h),a
l8309:  ld      (0d59eh),hl
    ret     

l830d:  ld      bc,l0000
    or      a
l8311:  sbc     hl,de
    jr      c,l8318
    inc     bc
    jr      l8311
l8318:  add     hl,de
    ret     

l831a:  push    hl
    pop     bc
    ld      hl,l0000
    ld      a,10h
l8321:  srl     d
    rr      e
    jp      nc,l8329
    add     hl,bc
l8329:  sla     c
    rl      b
    dec     a
    jp      nz,l8321
    ret     

l8332:  ld      de,0d5a4h
    ld      hl,0d5a7h
    ld      ix,0d5aah
    and     a
    ld      b,03h
l833f:  ld      a,(de)
    adc     a,(hl)
    ld      (ix+00h),a
    inc     de
    inc     hl
    inc     ix
    djnz    l833f
    ret     

l834b:  ld      de,0d5a4h
    ld      hl,0d5a7h
    ld      ix,0d5aah
    and     a
    ld      b,03h
l8358:  ld      a,(de)
    sbc     a,(hl)
    ld      (ix+00h),a
    inc     de
    inc     hl
    inc     ix
    djnz    l8358
    ret     

    push    de
    bit     7,a
    jp      z,l836e
    ld      e,a
    ld      a,00h
    sub     e
l836e:  pop     de
    ret     

    push    af
    push    de
    bit     7,h
    jp      z,l837f
    push    hl
    pop     de
    ld      hl,l0000
    and     a
    sbc     hl,de
l837f:  pop     de
    pop     af
    ret     

;	Interrupt Routine 1

IntRoutine_1:

    di      
    nop     
    ei      
    nop     
    reti    

;	Interrupt Routine 2

IntRoutine_2:

    di      
    push    af
    push    bc
    push    de
    push    hl
    in      a,(8ch)
    bit     0,a
    jp      nz,l839e
    ld      a,(0d501h)
    set     4,a
    set     5,a
    jp      l83a5
l839e:  ld      a,(0d501h)
    res     4,a
    res     5,a
l83a5:  ld      (0d501h),a
    out     (3ah),a
    in      a,(8ch)
    bit     1,a
    jp      nz,l83bb
    ld      a,(0d501h)
    set     6,a
    set     7,a
    jp      l83c2
l83bb:  ld      a,(0d501h)
    res     6,a
    res     7,a
l83c2:  ld      (0d501h),a
    out     (3ah),a
    in      a,(8ch)
    bit     2,a
    jp      nz,l83d6
    ld      a,(0d500h)
    set     0,a
    jp      l83db
l83d6:  ld      a,(0d500h)
    res     0,a
l83db:  ld      (0d500h),a
    out     (38h),a
    in      a,(8ch)
    bit     3,a
    jp      nz,l83ef
    ld      a,(0d500h)
    set     1,a
    jp      l83f4
l83ef:  ld      a,(0d500h)
    res     1,a
l83f4:  ld      (0d500h),a
    out     (38h),a
    in      a,(8ch)
    bit     4,a
    jp      nz,l8408
    ld      a,(0d501h)
    set     0,a
    jp      l840d
l8408:  ld      a,(0d501h)
    res     0,a
l840d:  ld      (0d501h),a
    out     (3ah),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 3

IntRoutine_3:

    di      
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d54bh)
    and     a
    jp      z,l843c
    ld      a,(0d588h)
    and     a
    jp      nz,l843c
    in      a,(3ch)
    bit     6,a
    jp      z,l843c
    ld      a,01h
    ld      (0d588h),a
    ld      (0d52dh),a
l843c:  ld      a,(0d52dh)
    and     a
    jp      z,l8465
    ld      hl,(0d530h)
    ld      a,l
    or      h
    jp      z,l8452
    dec     hl
    ld      (0d530h),hl
    jp      l8465
l8452:  ld      a,(0d501h)
    xor     02h
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,(0d52eh)
    ld      (0d530h),hl
    jp      l8465
l8465:  pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 4 - serial port

IntRoutine_4:

    di      
    push    af
    push    bc
    push    de
    push    hl
    in      a,(2bh)
    and     38h
    jp      z,l847c
    jp      l8509
l847c:  ld      a,(0d9dch)
    and     a
    jp      nz,l849a
    in      a,(2ah)
    and     7fh
    cp      02h
    jp      nz,l8531
    ld      a,01h
    ld      (0d9dch),a
    ld      hl,l0000
    ld      (0d9ddh),hl
    jp      l8531
l849a:  in      a,(2ah)
    and     7fh
    ld      hl,0d5dch
    ld      de,(0d9ddh)
    add     hl,de
    ld      (hl),a
    inc     de
    ld      (0d9ddh),de
    ld      hl,0400h
    ld      de,(0d9ddh)
    and     a
    sbc     hl,de
    jp      m,l8509
    cp      03h
    jp      z,l84c1
    jp      l8531
l84c1:  ld      a,01h
    ld      (0d5dbh),a
    ld      a,00h
    ld      (0d9dch),a
    ld      a,(0d5dch)
    cp      53h
    jp      z,l8517
    cp      41h
    jp      z,l8522
    ld      a,(0dddfh)
    and     a
    jp      nz,l8531
    ld      hl,0d5dch
    ld      de,(0d9ddh)
    add     hl,de
    ld      (hl),a
    ld      hl,0d5dch
    ld      de,0d9dfh
    ld      bc,0400h
    ldir    
    ld      a,01h
    ld      (0dddfh),a
    ld      a,00h
    ld      (0d5dbh),a
    ld      hl,l0000
    ld      (0de4ch),hl
    call    l0dd7
    jp      l8531
l8509:  in      a,(2ah)
    ld      a,15h
    out     (2bh),a
    ld      a,00h
    ld      (0d9dch),a
    jp      l8531
l8517:  ld      a,(0de5ah)
    xor     01h
    ld      (0de5ah),a
    jp      l8531
l8522:  ld      a,(0de5ah)
    and     a
    jp      z,l8531
    ld      a,01h
    ld      (0de5bh),a
    jp      l8531
l8531:  pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 5 - Runs the pump for some volume in some direction

IntRoutine_5:

    di      
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d564h)
    and     a
    jp      z,l8620

    ld      a,(0d509h)
    res     0,a
    out     (8ah),a
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    set     0,a
    out     (8ah),a
    ld      hl,(0d568h)
    dec     hl
    ld      (0d568h),hl
    ld      a,(0d574h)
    cp      01h
    jp      z,l857b
    cp      02h
    jp      z,l85ff
    jp      l85c3

l857b:
    ld      hl,(0d568h)
    ld      de,(0d56ah)
    and     a
    sbc     hl,de
    jp      nz,l8590
    ld      a,00h
    ld      (0d574h),a
    jp      l8650
l8590:
    ld      ix,8691h
    ld      de,(0d575h)
    add     ix,de
    add     ix,de
    inc     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      hl,(0d565h)
    and     a
    sbc     hl,de
    jp      m,l85b9
    ld      a,00h
    ld      (0d574h),a
    ld      de,(0d565h)
l85b9:
    ld      (0de58h),de
    call    l0e11
    jp      l8650
l85c3:
    ld      hl,(0d568h)
    ld      de,(0d575h)
    and     a
    sbc     hl,de
    jp      nz,l85fc
    ld      hl,(0d568h)
    ld      a,h
    or      l
    jp      z,l8650
    ld      a,02h
    ld      (0d574h),a
    ld      ix,8691h
    ld      de,(0d575h)
    dec     de
    add     ix,de
    add     ix,de
    dec     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      (0de58h),de
    call    l0e11
l85fc:
    jp      l8650

l85ff:
    ld      ix,8691h
    ld      de,(0d575h)
    add     ix,de
    add     ix,de
    dec     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      (0de58h),de
    call    l0e11
    jp      l8650

l8620:  ld      a,(0d577h)
    and     a
    jp      z,l8650
    ld      a,(0d509h)
    res     2,a
    out     (8ah),a
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    set     2,a
    out     (8ah),a
    ld      hl,(0d579h)
    dec     hl
    ld      (0d579h),hl
    jp      l8650
l8650:
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 6

IntRoutine_6:
    di      
    push    af
    push    bc
    push    de
    push    hl
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 7 - Timer interrupt, each tick = 1us?

IntRoutine_7:
    di      
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d561h)
    and     a
    jp      z,l8678
    ld      hl,(0d562h)
    dec     hl
    ld      (0d562h),hl
l8678:  pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

Msg_ok:
    defm    "OK@"
Msg_e99:
    defm    "E99@"
Msg_error:
    defm    "ERROR@"
Msg_4_2:
    defm    "4.2@"

;	12-column plate data

AccData:
Table_12:
    defw    0000h
    defw    035ch
    defw    044ch
    defw    053ch
    defw    062ch
    defw    071dh
    defw    080dh
    defw    08fdh
    defw    09edh
    defw    0addh
    defw    0bceh
    defw    0cbeh
    defw    0daeh

;	24-column plate data

Table_24:
    defw    0000h
    defw    0320h
    defw    0398h
    defw    0410h
    defw    0488h
    defw    0501h
    defw    0579h
    defw    05f1h
    defw    0669h
    defw    06e1h
    defw    075ah
    defw    07d2h
    defw    084ah
    defw    08c2h
    defw    093ah
    defw    09b3h
    defw    0a2bh
    defw    0aa3h
    defw    0b1bh
    defw    0b93h
    defw    0c0ch
    defw    0c84h
    defw    0cfch
    defw    0d74h
    defw    0dech

;	Looks like a 12-column table of some sort

    defw    0000h
    defw    046ah
    defw    055ah
    defw    064ah
    defw    073ah
    defw    082bh
    defw    091bh
    defw    0a0bh
    defw    0afbh
    defw    0bebh
    defw    0cdch
    defw    0dcch
    defw    0ebch

;	Looks like a 24-column table of some sort

    defw    0000h
    defw    0424h
    defw    049ch
    defw    0514h
    defw    058ch
    defw    0605h
    defw    067dh
    defw    06f5h
    defw    076dh
    defw    07e5h
    defw    085eh
    defw    08d6h
    defw    094eh
    defw    09c6h
    defw    0a3eh
    defw    0ab7h
    defw    0b2fh
    defw    0ba7h
    defw    0c1fh
    defw    0c97h
    defw    0d10h
    defw    0d88h
    defw    0e00h
    defw    0e78h
    defw    0ef0h

    defs    10000h - $

#end

