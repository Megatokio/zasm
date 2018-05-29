;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:40 2017
;--------------------------------------------------------
	.module ___fsdiv
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fsdiv
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:62: float __fsdiv (float a1, float a2)
;	---------------------------------
; Function __fsdiv
; ---------------------------------
___fsdiv_start::
___fsdiv:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-39
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:71: fl1.f = a1;
	ld	hl,#0x0017
	add	hl,sp
	ex	de,hl
	ld	hl, #0x002B
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:72: fl2.f = a2;
	ld	hl,#0x0013
	add	hl,sp
	ex	de,hl
	ld	hl, #0x002F
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:75: exp = EXP (fl1.l) ;
	ld	hl,#0x0017
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	e,c
	ld	d,b
	ld	c,l
	ld	b,h
	ld	a,#0x17
00164$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00164$
	ld	-38 (ix), e
	ld	-37 (ix), #0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:76: exp -= EXP (fl2.l);
	ld	hl,#0x0013
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	e,c
	ld	d,b
	ld	c,l
	ld	b,h
	ld	a,#0x17
00166$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00166$
	ld	d,#0x00
	ld	bc,#0x0000
	ld	a,-38 (ix)
	ld	-12 (ix),a
	ld	a,-37 (ix)
	ld	-11 (ix),a
	ld	a,-37 (ix)
	rla
	sbc	a, a
	ld	-10 (ix),a
	ld	-9 (ix),a
	ld	a,-12 (ix)
	sub	a, e
	ld	l,a
	ld	a,-11 (ix)
	sbc	a, d
	ld	h,a
	ld	a,-10 (ix)
	sbc	a, c
	ld	a,-9 (ix)
	sbc	a, b
	ld	e,a
	ld	-38 (ix),l
	ld	-37 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:77: exp += EXCESS;
	ld	a,-38 (ix)
	add	a, #0x7E
	ld	-38 (ix),a
	ld	a,-37 (ix)
	adc	a, #0x00
	ld	-37 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:80: sign = SIGN (fl1.l) ^ SIGN (fl2.l);
	ld	hl,#0x0017
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	rlc	a
	and	a,#0x01
	ld	e,a
	ld	hl,#0x0013
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	-12 (ix),c
	ld	-11 (ix),b
	ld	-10 (ix),l
	ld	-9 (ix), h
	ld	a, h
	rlc	a
	and	a,#0x01
	xor	a, e
	ld	-39 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:83: if (!fl2.l)
	ld	hl,#0x0013
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ex	de,hl
	ld	hl, #0x001B
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-9 (ix)
	or	a, -10 (ix)
	or	a, -11 (ix)
	or	a,-12 (ix)
	jr	NZ,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:85: fl2.l = 0x7FC00000;
	ld	hl,#0x0013
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	ld	(hl),#0x00
	inc	hl
	ld	(hl),#0x00
	inc	hl
	ld	(hl),#0xC0
	inc	hl
	ld	(hl),#0x7F
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:86: return (fl2.f);
	ld	hl,#0x0013
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ex	de,hl
	ld	hl, #0x001B
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	ld	e,-10 (ix)
	ld	d,-9 (ix)
	jp	00118$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:90: if (!fl1.l)
	ld	hl,#0x0017
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ex	de,hl
	ld	hl, #0x001B
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-9 (ix)
	or	a, -10 (ix)
	or	a, -11 (ix)
	or	a,-12 (ix)
	jr	NZ,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:91: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00118$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:94: mant1 = MANT (fl1.l);
	ld	hl,#0x0017
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ex	de,hl
	ld	hl, #0x001B
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	res	7, -10 (ix)
	ld	-9 (ix),#0x00
	ld	a,-12 (ix)
	ld	-32 (ix),a
	ld	a,-11 (ix)
	ld	-31 (ix),a
	ld	a,-10 (ix)
	set	7, a
	ld	-30 (ix),a
	ld	a,-9 (ix)
	ld	-29 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:95: mant2 = MANT (fl2.l);
	ld	hl,#0x0013
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ex	de,hl
	ld	hl, #0x001B
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	res	7, -10 (ix)
	ld	-9 (ix),#0x00
	ld	a,-12 (ix)
	ld	-36 (ix),a
	ld	a,-11 (ix)
	ld	-35 (ix),a
	ld	a,-10 (ix)
	set	7, a
	ld	-34 (ix),a
	ld	a,-9 (ix)
	ld	-33 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:98: if (mant1 < mant2)
	ld	a,-32 (ix)
	sub	a, -36 (ix)
	ld	a,-31 (ix)
	sbc	a, -35 (ix)
	ld	a,-30 (ix)
	sbc	a, -34 (ix)
	ld	a,-29 (ix)
	sbc	a, -33 (ix)
	jp	PO, 00168$
	xor	a, #0x80
00168$:
	jp	P,00106$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:100: mant1 <<= 1;
	push	af
	pop	af
	ld	b,#0x01
	sla	-32 (ix)
	rl	-31 (ix)
	rl	-30 (ix)
	rl	-29 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:101: exp--;
	ld	l,-38 (ix)
	ld	h,-37 (ix)
	dec	hl
	ld	-38 (ix),l
	ld	-37 (ix),h
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:105: mask = 0x1000000;
	ld	-28 (ix),#0x00
	ld	-27 (ix),#0x00
	ld	-26 (ix),#0x00
	ld	-25 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:106: result = 0;
	xor	a, a
	ld	-24 (ix),a
	ld	-23 (ix),a
	ld	-22 (ix),a
	ld	-21 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:107: while (mask)
00109$:
	ld	a,-25 (ix)
	or	a, -26 (ix)
	or	a, -27 (ix)
	or	a,-28 (ix)
	jp	Z,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:109: if (mant1 >= mant2)
	ld	a,-32 (ix)
	sub	a, -36 (ix)
	ld	a,-31 (ix)
	sbc	a, -35 (ix)
	ld	a,-30 (ix)
	sbc	a, -34 (ix)
	ld	a,-29 (ix)
	sbc	a, -33 (ix)
	jp	PO, 00171$
	xor	a, #0x80
00171$:
	jp	M,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:111: result |= mask;
	ld	hl, #27
	add	hl, sp
	ex	de, hl
	ld	hl, #15
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-12 (ix)
	or	a, -28 (ix)
	ld	-12 (ix),a
	ld	a,-11 (ix)
	or	a, -27 (ix)
	ld	-11 (ix),a
	ld	a,-10 (ix)
	or	a, -26 (ix)
	ld	-10 (ix),a
	ld	a,-9 (ix)
	or	a, -25 (ix)
	ld	-9 (ix),a
	ld	hl, #15
	add	hl, sp
	ex	de, hl
	ld	hl, #27
	add	hl, sp
	ld	bc, #4
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:112: mant1 -= mant2;
	ld	a,-32 (ix)
	sub	a, -36 (ix)
	ld	-32 (ix),a
	ld	a,-31 (ix)
	sbc	a, -35 (ix)
	ld	-31 (ix),a
	ld	a,-30 (ix)
	sbc	a, -34 (ix)
	ld	-30 (ix),a
	ld	a,-29 (ix)
	sbc	a, -33 (ix)
	ld	-29 (ix),a
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:114: mant1 <<= 1;
	push	af
	pop	af
	sla	-32 (ix)
	rl	-31 (ix)
	rl	-30 (ix)
	rl	-29 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:115: mask >>= 1;
	push	af
	pop	af
	ld	b,#0x01
	srl	-25 (ix)
	rr	-26 (ix)
	rr	-27 (ix)
	rr	-28 (ix)
	jp	00109$
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:119: result += 1;
	inc	-24 (ix)
	jr	NZ,00176$
	inc	-23 (ix)
	jr	NZ,00176$
	inc	-22 (ix)
	jr	NZ,00176$
	inc	-21 (ix)
00176$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:122: exp++;
	inc	-38 (ix)
	jr	NZ,00177$
	inc	-37 (ix)
00177$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:123: result >>= 1;
	push	af
	pop	af
	ld	b,#0x01
	sra	-21 (ix)
	rr	-22 (ix)
	rr	-23 (ix)
	rr	-24 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:125: result &= ~HIDDEN;
	ld	hl, #27
	add	hl, sp
	ex	de, hl
	ld	hl, #15
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-12 (ix)
	ld	-24 (ix),a
	ld	a,-11 (ix)
	ld	-23 (ix),a
	ld	a,-10 (ix)
	and	a, #0x7F
	ld	-22 (ix),a
	ld	a,-9 (ix)
	ld	-21 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:128: if (exp >= 0x100)
	ld	a,-37 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00116$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:129: fl1.l = (sign ? SIGNBIT : 0) | __INFINITY;
	ld	hl,#0x0017
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ld	a,-39 (ix)
	or	a, a
	jr	Z,00120$
	ld	-8 (ix),#0x00
	ld	-7 (ix),#0x00
	ld	-6 (ix),#0x00
	ld	-5 (ix),#0x80
	jr	00121$
00120$:
	xor	a, a
	ld	-8 (ix),a
	ld	-7 (ix),a
	ld	-6 (ix),a
	ld	-5 (ix),a
00121$:
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	ld	a,-6 (ix)
	set	7, a
	ld	c,a
	ld	a,-5 (ix)
	or	a, #0x7F
	ld	b,a
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jp	00117$
00116$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:130: else if (exp < 0)
	bit	7, -37 (ix)
	jr	Z,00113$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:131: fl1.l = 0;
	ld	hl,#0x0017
	add	hl,sp
	ld	b,h
	ld	(hl),#0x00
	inc	hl
	ld	(hl),#0x00
	inc	hl
	ld	(hl),#0x00
	inc	hl
	ld	(hl),#0x00
	jp	00117$
00113$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:133: fl1.l = PACK (sign ? SIGNBIT : 0 , exp, result);
	ld	hl,#0x0017
	add	hl,sp
	ld	-8 (ix),l
	ld	-7 (ix),h
	ld	a,-39 (ix)
	or	a, a
	jr	Z,00122$
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x00
	ld	-10 (ix),#0x00
	ld	-9 (ix),#0x80
	jr	00123$
00122$:
	xor	a, a
	ld	-12 (ix),a
	ld	-11 (ix),a
	ld	-10 (ix),a
	ld	-9 (ix),a
00123$:
	ld	a,-38 (ix)
	ld	-4 (ix),a
	ld	a,-37 (ix)
	ld	-3 (ix),a
	ld	a,-37 (ix)
	rla
	sbc	a, a
	ld	-2 (ix),a
	ld	-1 (ix),a
	push	af
	pop	af
	ld	b,#0x17
00180$:
	sla	-4 (ix)
	rl	-3 (ix)
	rl	-2 (ix)
	rl	-1 (ix)
	djnz	00180$
	ld	a,-4 (ix)
	or	a, -12 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	or	a, -11 (ix)
	ld	-3 (ix),a
	ld	a,-2 (ix)
	or	a, -10 (ix)
	ld	-2 (ix),a
	ld	a,-1 (ix)
	or	a, -9 (ix)
	ld	-1 (ix),a
	ld	hl, #27
	add	hl, sp
	ex	de, hl
	ld	hl, #15
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-4 (ix)
	or	a, -12 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	or	a, -11 (ix)
	ld	-3 (ix),a
	ld	a,-2 (ix)
	or	a, -10 (ix)
	ld	-2 (ix),a
	ld	a,-1 (ix)
	or	a, -9 (ix)
	ld	-1 (ix),a
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	ld	hl, #0x0023
	add	hl, sp
	ld	bc, #0x0004
	ldir
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:134: return (fl1.f);
	ld	hl,#0x0017
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ex	de,hl
	ld	hl, #0x0023
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	e,-2 (ix)
	ld	d,-1 (ix)
00118$:
	ld	sp, ix
	pop	ix
	ret
___fsdiv_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
