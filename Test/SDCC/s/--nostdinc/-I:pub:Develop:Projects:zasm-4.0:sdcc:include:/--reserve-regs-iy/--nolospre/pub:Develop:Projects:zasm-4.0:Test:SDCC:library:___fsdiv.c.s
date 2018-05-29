;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:12:17 2017
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
	ld	hl,#-35
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:71: fl1.f = a1;
	ld	hl,#0x0017
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0027
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:72: fl2.f = a2;
	ld	hl,#0x0013
	add	hl,sp
	ex	de,hl
	ld	hl, #0x002B
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:75: exp = EXP (fl1.l) ;
	ld	hl,#0x0017
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x17
00154$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00154$
	ld	-34 (ix), e
	ld	-33 (ix), #0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:76: exp -= EXP (fl2.l);
	ld	hl,#0x0013
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x17
00156$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00156$
	ld	-8 (ix),e
	ld	-7 (ix),#0x00
	ld	-6 (ix),#0x00
	ld	-5 (ix),#0x00
	ld	e,-34 (ix)
	ld	d,-33 (ix)
	ld	a,-33 (ix)
	rla
	sbc	a, a
	ld	c,a
	ld	b,a
	ld	a,e
	sub	a, -8 (ix)
	ld	h,a
	ld	a,d
	sbc	a, -7 (ix)
	ld	l,a
	ld	a,c
	sbc	a, -6 (ix)
	ld	a,b
	sbc	a, -5 (ix)
	ld	e,a
	ld	-34 (ix),h
	ld	-33 (ix),l
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:77: exp += EXCESS;
	ld	a,-34 (ix)
	add	a, #0x7E
	ld	-34 (ix),a
	ld	a,-33 (ix)
	adc	a, #0x00
	ld	-33 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:80: sign = SIGN (fl1.l) ^ SIGN (fl2.l);
	ld	hl,#0x0017
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	a, (hl)
	rlc	a
	and	a,#0x01
	ld	-8 (ix),a
	ld	hl,#0x0013
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	a, (hl)
	rlc	a
	and	a,#0x01
	xor	a, -8 (ix)
	ld	-35 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:83: if (!fl2.l)
	ld	hl,#0x0013
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	a, (hl)
	or	a, e
	or	a, b
	or	a,c
	jr	NZ,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:85: fl2.l = 0x7FC00000;
	ld	hl,#0x0013
	add	hl,sp
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	ld	(hl),#0xC0
	inc	hl
	ld	(hl),#0x7F
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:86: return (fl2.f);
	ld	hl,#0x0013
	add	hl,sp
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,b
	ld	h,c
	jp	00118$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:90: if (!fl1.l)
	ld	hl,#0x0017
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	a, (hl)
	or	a, c
	or	a, e
	or	a,d
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
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	res	7, c
	ld	b,#0x00
	ld	-28 (ix),e
	ld	-27 (ix),d
	ld	a,c
	set	7, a
	ld	-26 (ix),a
	ld	-25 (ix),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:95: mant2 = MANT (fl2.l);
	ld	hl,#0x0013
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	res	7, c
	ld	b,#0x00
	ld	-32 (ix),e
	ld	-31 (ix),d
	ld	a,c
	set	7, a
	ld	-30 (ix),a
	ld	-29 (ix),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:98: if (mant1 < mant2)
	ld	a,-28 (ix)
	sub	a, -32 (ix)
	ld	a,-27 (ix)
	sbc	a, -31 (ix)
	ld	a,-26 (ix)
	sbc	a, -30 (ix)
	ld	a,-25 (ix)
	sbc	a, -29 (ix)
	jp	PO, 00158$
	xor	a, #0x80
00158$:
	jp	P,00106$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:100: mant1 <<= 1;
	push	af
	pop	af
	ld	b,#0x01
	sla	-28 (ix)
	rl	-27 (ix)
	rl	-26 (ix)
	rl	-25 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:101: exp--;
	ld	l,-34 (ix)
	ld	h,-33 (ix)
	dec	hl
	ld	-34 (ix),l
	ld	-33 (ix),h
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:105: mask = 0x1000000;
	ld	-24 (ix),#0x00
	ld	-23 (ix),#0x00
	ld	-22 (ix),#0x00
	ld	-21 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:106: result = 0;
	xor	a, a
	ld	-20 (ix),a
	ld	-19 (ix),a
	ld	-18 (ix),a
	ld	-17 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:107: while (mask)
00109$:
	ld	a,-21 (ix)
	or	a, -22 (ix)
	or	a, -23 (ix)
	or	a,-24 (ix)
	jp	Z,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:109: if (mant1 >= mant2)
	ld	a,-28 (ix)
	sub	a, -32 (ix)
	ld	a,-27 (ix)
	sbc	a, -31 (ix)
	ld	a,-26 (ix)
	sbc	a, -30 (ix)
	ld	a,-25 (ix)
	sbc	a, -29 (ix)
	jp	PO, 00161$
	xor	a, #0x80
00161$:
	jp	M,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:111: result |= mask;
	ld	e,-20 (ix)
	ld	d,-19 (ix)
	ld	c,-18 (ix)
	ld	b,-17 (ix)
	ld	a,e
	or	a, -24 (ix)
	ld	e,a
	ld	a,d
	or	a, -23 (ix)
	ld	d,a
	ld	a,c
	or	a, -22 (ix)
	ld	c,a
	ld	a,b
	or	a, -21 (ix)
	ld	b,a
	ld	-20 (ix),e
	ld	-19 (ix),d
	ld	-18 (ix),c
	ld	-17 (ix),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:112: mant1 -= mant2;
	ld	a,-28 (ix)
	sub	a, -32 (ix)
	ld	-28 (ix),a
	ld	a,-27 (ix)
	sbc	a, -31 (ix)
	ld	-27 (ix),a
	ld	a,-26 (ix)
	sbc	a, -30 (ix)
	ld	-26 (ix),a
	ld	a,-25 (ix)
	sbc	a, -29 (ix)
	ld	-25 (ix),a
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:114: mant1 <<= 1;
	push	af
	pop	af
	sla	-28 (ix)
	rl	-27 (ix)
	rl	-26 (ix)
	rl	-25 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:115: mask >>= 1;
	push	af
	pop	af
	ld	b,#0x01
	srl	-21 (ix)
	rr	-22 (ix)
	rr	-23 (ix)
	rr	-24 (ix)
	jp	00109$
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:119: result += 1;
	inc	-20 (ix)
	jr	NZ,00166$
	inc	-19 (ix)
	jr	NZ,00166$
	inc	-18 (ix)
	jr	NZ,00166$
	inc	-17 (ix)
00166$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:122: exp++;
	inc	-34 (ix)
	jr	NZ,00167$
	inc	-33 (ix)
00167$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:123: result >>= 1;
	push	af
	pop	af
	sra	-17 (ix)
	rr	-18 (ix)
	rr	-19 (ix)
	rr	-20 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:125: result &= ~HIDDEN;
	ld	d,-20 (ix)
	ld	e,-19 (ix)
	ld	b,-18 (ix)
	ld	c,-17 (ix)
	ld	-20 (ix),d
	ld	-19 (ix),e
	ld	a,b
	and	a, #0x7F
	ld	-18 (ix),a
	ld	-17 (ix),c
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:128: if (exp >= 0x100)
	ld	a,-33 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00116$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:129: fl1.l = (sign ? SIGNBIT : 0) | __INFINITY;
	ld	hl,#0x0017
	add	hl,sp
	ld	-8 (ix),l
	ld	-7 (ix),h
	ld	a,-35 (ix)
	or	a, a
	jr	Z,00120$
	ld	bc,#0x0000
	ld	hl,#0x0080
	jr	00121$
00120$:
	ld	bc,#0x0000
	ld	hl,#0x0000
00121$:
	ld	a,h
	set	7, a
	ld	d,a
	ld	a,l
	or	a, #0x7F
	ld	e,a
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),e
	jp	00117$
00116$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:130: else if (exp < 0)
	bit	7, -33 (ix)
	jr	Z,00113$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:131: fl1.l = 0;
	ld	hl,#0x0017
	add	hl,sp
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	jp	00117$
00113$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:133: fl1.l = PACK (sign ? SIGNBIT : 0 , exp, result);
	ld	hl,#0x0017
	add	hl,sp
	ld	-8 (ix),l
	ld	-7 (ix),h
	ld	a,-35 (ix)
	or	a, a
	jr	Z,00122$
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	-1 (ix),#0x80
	jr	00123$
00122$:
	xor	a, a
	ld	-4 (ix),a
	ld	-3 (ix),a
	ld	-2 (ix),a
	ld	-1 (ix),a
00123$:
	ld	b,-34 (ix)
	ld	c,-33 (ix)
	ld	a,-33 (ix)
	rla
	sbc	a, a
	ld	e,a
	ld	d,a
	ld	l,b
	ld	h,c
	ld	a,#0x17
00170$:
	add	hl, hl
	rl	e
	rl	d
	dec	a
	jr	NZ,00170$
	ld	a,-4 (ix)
	or	a, l
	ld	-4 (ix),a
	ld	a,-3 (ix)
	or	a, h
	ld	-3 (ix),a
	ld	a,-2 (ix)
	or	a, e
	ld	-2 (ix),a
	ld	a,-1 (ix)
	or	a, d
	ld	-1 (ix),a
	ld	e,-20 (ix)
	ld	d,-19 (ix)
	ld	b,-18 (ix)
	ld	c,-17 (ix)
	ld	a,e
	or	a, -4 (ix)
	ld	e,a
	ld	a,d
	or	a, -3 (ix)
	ld	d,a
	ld	a,b
	or	a, -2 (ix)
	ld	b,a
	ld	a,c
	or	a, -1 (ix)
	ld	c,a
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),b
	inc	hl
	ld	(hl),c
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsdiv.c:134: return (fl1.f);
	ld	hl,#0x0017
	add	hl,sp
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,b
	ld	h,c
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
