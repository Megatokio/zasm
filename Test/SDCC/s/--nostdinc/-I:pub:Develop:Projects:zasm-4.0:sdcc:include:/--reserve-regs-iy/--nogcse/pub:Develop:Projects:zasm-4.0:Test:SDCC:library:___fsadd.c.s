;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:07:34 2017
;--------------------------------------------------------
	.module ___fsadd
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fsadd
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:65: float __fsadd (float a1, float a2)
;	---------------------------------
; Function __fsadd
; ---------------------------------
___fsadd_start::
___fsadd:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-35
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:73: pfl2 = (long *)&a2;
	ld	hl,#0x002B
	add	hl,sp
	ld	-10 (ix),l
	ld	-9 (ix),h
	ld	a,-10 (ix)
	ld	-30 (ix),a
	ld	a,-9 (ix)
	ld	-29 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:74: exp2 = EXP (*pfl2);
	ld	e,-30 (ix)
	ld	d,-29 (ix)
	ld	hl, #0x0015
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl, #17
	add	hl, sp
	ex	de, hl
	ld	hl, #21
	add	hl, sp
	ld	bc, #4
	ldir
	push	af
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	ld	d,-16 (ix)
	ld	c,-15 (ix)
	pop	af
	ld	b,#0x17
00221$:
	srl	c
	rr	d
	rr	h
	rr	l
	djnz	00221$
	ld	-32 (ix), l
	ld	-31 (ix), #0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:75: mant2 = MANT (*pfl2) << 4;
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	ld	c,-16 (ix)
	res	7, c
	ld	b,#0x00
	ld	a,c
	set	7, a
	ld	d,a
	push	af
	ld	-26 (ix),l
	ld	-25 (ix),h
	ld	-24 (ix),d
	ld	-23 (ix),b
	pop	af
	ld	a,#0x04
00223$:
	sla	-26 (ix)
	rl	-25 (ix)
	rl	-24 (ix)
	rl	-23 (ix)
	dec	a
	jr	NZ,00223$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:76: if (SIGN (*pfl2))
	ld	a,-15 (ix)
	rlc	a
	and	a,#0x01
	jr	Z,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:77: mant2 = -mant2;
	xor	a, a
	sub	a, -26 (ix)
	ld	-26 (ix),a
	ld	a, #0x00
	sbc	a, -25 (ix)
	ld	-25 (ix),a
	ld	a, #0x00
	sbc	a, -24 (ix)
	ld	-24 (ix),a
	ld	a, #0x00
	sbc	a, -23 (ix)
	ld	-23 (ix),a
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:79: if (!*pfl2)
	ld	a,-11 (ix)
	or	a, -12 (ix)
	or	a, -13 (ix)
	or	a,-14 (ix)
	jr	NZ,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:80: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	jp	00137$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:82: pfl1 = (long *)&a1;
	ld	hl,#0x0027
	add	hl,sp
	ld	-18 (ix),l
	ld	-17 (ix),h
	ld	a,-18 (ix)
	ld	-28 (ix),a
	ld	a,-17 (ix)
	ld	-27 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:83: exp1 = EXP (*pfl1);
	ld	e,-28 (ix)
	ld	d,-27 (ix)
	ld	hl, #0x0011
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl, #21
	add	hl, sp
	ex	de, hl
	ld	hl, #17
	add	hl, sp
	ld	bc, #4
	ldir
	push	af
	ld	a,-14 (ix)
	ld	-4 (ix),a
	ld	a,-13 (ix)
	ld	-3 (ix),a
	ld	a,-12 (ix)
	ld	-2 (ix),a
	ld	a,-11 (ix)
	ld	-1 (ix),a
	pop	af
	ld	b,#0x17
00225$:
	srl	-1 (ix)
	rr	-2 (ix)
	rr	-3 (ix)
	rr	-4 (ix)
	djnz	00225$
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	-1 (ix),#0x00
	ld	a,-4 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:84: mant1 = MANT (*pfl1) << 4;
	ld	a,-14 (ix)
	ld	-8 (ix),a
	ld	a,-13 (ix)
	ld	-7 (ix),a
	ld	a,-12 (ix)
	and	a, #0x7F
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	set	7, -6 (ix)
	ld	a, -6 (ix)
	push	af
	pop	af
	ld	b,#0x04
00227$:
	sla	-8 (ix)
	rl	-7 (ix)
	rl	-6 (ix)
	rl	-5 (ix)
	djnz	00227$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:85: if (SIGN(*pfl1))
	ld	a,-11 (ix)
	rlc	a
	and	a,#0x01
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:86: if (*pfl1 & 0x80000000)
	bit	7, -11 (ix)
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:87: mant1 = -mant1;
	xor	a, a
	sub	a, -8 (ix)
	ld	-8 (ix),a
	ld	a, #0x00
	sbc	a, -7 (ix)
	ld	-7 (ix),a
	ld	a, #0x00
	sbc	a, -6 (ix)
	ld	-6 (ix),a
	ld	a, #0x00
	sbc	a, -5 (ix)
	ld	-5 (ix),a
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:89: if (!*pfl1)
	ld	a,-15 (ix)
	or	a, -16 (ix)
	or	a, -17 (ix)
	or	a,-18 (ix)
	jr	NZ,00110$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:90: return (a2);
	ld	l,8 (ix)
	ld	h,9 (ix)
	ld	e,10 (ix)
	ld	d,11 (ix)
	jp	00137$
00110$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:92: expd = exp1 - exp2;
	ld	a,-4 (ix)
	sub	a, -32 (ix)
	ld	-18 (ix),a
	ld	a,-3 (ix)
	sbc	a, -31 (ix)
	ld	-17 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:93: if (expd > 25)
	ld	a,#0x19
	cp	a, -18 (ix)
	ld	a,#0x00
	sbc	a, -17 (ix)
	jp	PO, 00230$
	xor	a, #0x80
00230$:
	jp	P,00112$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:94: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	jp	00137$
00112$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:95: if (expd < -25)
	ld	a,-18 (ix)
	sub	a, #0xE7
	ld	a,-17 (ix)
	rla
	ccf
	rra
	sbc	a, #0x7F
	jr	NC,00114$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:96: return (a2);
	ld	l,8 (ix)
	ld	h,9 (ix)
	ld	e,10 (ix)
	ld	d,11 (ix)
	jp	00137$
00114$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:98: if (expd < 0)
	bit	7, -17 (ix)
	jr	Z,00116$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:100: expd = -expd;
	xor	a, a
	sub	a, -18 (ix)
	ld	-14 (ix),a
	ld	a, #0x00
	sbc	a, -17 (ix)
	ld	-13 (ix),a
	ld	a,-14 (ix)
	ld	-34 (ix),a
	ld	a,-13 (ix)
	ld	-33 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:101: exp1 += expd;
	ld	a,-4 (ix)
	add	a, -34 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	adc	a, -33 (ix)
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:102: mant1 >>= expd;
	ld	b,-34 (ix)
	push	af
	pop	af
	inc	b
	jr	00232$
00231$:
	sra	-5 (ix)
	rr	-6 (ix)
	rr	-7 (ix)
	rr	-8 (ix)
00232$:
	djnz	00231$
	jr	00117$
00116$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:106: mant2 >>= expd;
	ld	b,-18 (ix)
	push	af
	pop	af
	inc	b
	jr	00234$
00233$:
	sra	-23 (ix)
	rr	-24 (ix)
	rr	-25 (ix)
	rr	-26 (ix)
00234$:
	djnz	00233$
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:108: mant1 += mant2;
	ld	a,-8 (ix)
	add	a, -26 (ix)
	ld	h,a
	ld	a,-7 (ix)
	adc	a, -25 (ix)
	ld	l,a
	ld	a,-6 (ix)
	adc	a, -24 (ix)
	ld	d,a
	ld	a,-5 (ix)
	adc	a, -23 (ix)
	ld	e,a
	ld	-22 (ix),h
	ld	-21 (ix),l
	ld	-20 (ix),d
	ld	-19 (ix),e
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:110: sign = false;
	ld	-35 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:112: if (mant1 < 0)
	bit	7, -19 (ix)
	jr	Z,00121$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:114: mant1 = -mant1;
	xor	a, a
	sub	a, -22 (ix)
	ld	-22 (ix),a
	ld	a, #0x00
	sbc	a, -21 (ix)
	ld	-21 (ix),a
	ld	a, #0x00
	sbc	a, -20 (ix)
	ld	-20 (ix),a
	ld	a, #0x00
	sbc	a, -19 (ix)
	ld	-19 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:115: sign = true;
	ld	-35 (ix),#0x01
	jr	00154$
00121$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:117: else if (!mant1)
	ld	a,-19 (ix)
	or	a, -20 (ix)
	or	a, -21 (ix)
	or	a,-22 (ix)
	jr	NZ,00154$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:118: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00137$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:121: while (mant1 < (HIDDEN<<4)) 
00154$:
	ld	a,-4 (ix)
	ld	-8 (ix),a
	ld	a,-3 (ix)
	ld	-7 (ix),a
00123$:
	ld	hl, #31
	add	hl, sp
	ex	de, hl
	ld	hl, #13
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-1 (ix)
	sub	a, #0x08
	jr	NC,00162$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:123: mant1 <<= 1;
	push	af
	pop	af
	ld	b,#0x01
	sla	-22 (ix)
	rl	-21 (ix)
	rl	-20 (ix)
	rl	-19 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:124: exp1--;
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	dec	hl
	ld	-8 (ix),l
	ld	-7 (ix),h
	jr	00123$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:128: while (mant1 & 0xf0000000) 
00162$:
	ld	a,-8 (ix)
	ld	-8 (ix),a
	ld	a,-7 (ix)
	ld	-7 (ix),a
00128$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:121: while (mant1 < (HIDDEN<<4)) 
	ld	hl, #31
	add	hl, sp
	ex	de, hl
	ld	hl, #13
	add	hl, sp
	ld	bc, #4
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:128: while (mant1 & 0xf0000000) 
	ld	a,-1 (ix)
	and	a, #0xF0
	jr	Z,00163$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:130: if (mant1&1)
	bit	0, -22 (ix)
	jr	Z,00127$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:131: mant1 += 2;
	ld	a,-22 (ix)
	add	a, #0x02
	ld	-22 (ix),a
	ld	a,-21 (ix)
	adc	a, #0x00
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, #0x00
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, #0x00
	ld	-19 (ix),a
00127$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:132: mant1 >>= 1;
	push	af
	pop	af
	ld	b,#0x01
	sra	-19 (ix)
	rr	-20 (ix)
	rr	-21 (ix)
	rr	-22 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:133: exp1++;
	inc	-8 (ix)
	jr	NZ,00128$
	inc	-7 (ix)
	jr	00128$
00163$:
	ld	a,-8 (ix)
	ld	-8 (ix),a
	ld	a,-7 (ix)
	ld	-7 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:137: mant1 &= ~(HIDDEN<<4);
	res	3, -1 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:140: if (exp1 >= 0x100)
	ld	a,-7 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00135$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:141: *pfl1 = (sign ? (SIGNBIT | __INFINITY) : __INFINITY);
	ld	a,-28 (ix)
	ld	-18 (ix),a
	ld	a,-27 (ix)
	ld	-17 (ix),a
	bit	0,-35 (ix)
	jr	Z,00139$
	ld	-14 (ix),#0x00
	ld	-13 (ix),#0x00
	ld	-12 (ix),#0x80
	ld	-11 (ix),#0xFF
	jr	00140$
00139$:
	ld	-14 (ix),#0x00
	ld	-13 (ix),#0x00
	ld	-12 (ix),#0x80
	ld	-11 (ix),#0x7F
00140$:
	ld	e,-18 (ix)
	ld	d,-17 (ix)
	ld	hl, #0x0015
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jp	00136$
00135$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:142: else if (exp1 < 0)
	bit	7, -7 (ix)
	jr	Z,00132$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:143: *pfl1 = 0;
	ld	l,-28 (ix)
	ld	h,-27 (ix)
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	jp	00136$
00132$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:145: *pfl1 = PACK (sign ? SIGNBIT : 0 , exp1, mant1>>4);
	ld	l,-28 (ix)
	ld	h,-27 (ix)
	bit	0,-35 (ix)
	jr	Z,00141$
	ld	-18 (ix),#0x00
	ld	-17 (ix),#0x00
	ld	-16 (ix),#0x00
	ld	-15 (ix),#0x80
	jr	00142$
00141$:
	xor	a, a
	ld	-18 (ix),a
	ld	-17 (ix),a
	ld	-16 (ix),a
	ld	-15 (ix),a
00142$:
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	ld	a,-7 (ix)
	rla
	sbc	a, a
	ld	c,a
	ld	b,a
	ld	a,#0x17
00242$:
	sla	e
	rl	d
	rl	c
	rl	b
	dec	a
	jr	NZ,00242$
	ld	a,-18 (ix)
	or	a, e
	ld	-8 (ix),a
	ld	a,-17 (ix)
	or	a, d
	ld	-7 (ix),a
	ld	a,-16 (ix)
	or	a, c
	ld	-6 (ix),a
	ld	a,-15 (ix)
	or	a, b
	ld	-5 (ix),a
	push	af
	ld	e,-4 (ix)
	ld	d,-3 (ix)
	ld	c,-2 (ix)
	ld	b,-1 (ix)
	pop	af
	ld	a,#0x04
00244$:
	sra	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00244$
	ld	a,e
	or	a, -8 (ix)
	ld	e,a
	ld	a,d
	or	a, -7 (ix)
	ld	d,a
	ld	a,c
	or	a, -6 (ix)
	ld	c,a
	ld	a,b
	or	a, -5 (ix)
	ld	b,a
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
00136$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:146: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
00137$:
	ld	sp, ix
	pop	ix
	ret
___fsadd_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
