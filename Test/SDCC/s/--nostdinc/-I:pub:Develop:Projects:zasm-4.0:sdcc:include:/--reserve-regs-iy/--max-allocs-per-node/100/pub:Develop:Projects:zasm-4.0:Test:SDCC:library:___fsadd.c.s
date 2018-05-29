;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:40 2017
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
	ld	hl,#-27
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:73: pfl2 = (long *)&a2;
	ld	hl,#0x0023
	add	hl,sp
	ex	de,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:74: exp2 = EXP (*pfl2);
	ld	hl, #0x0013
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	ld	c,-6 (ix)
	ld	b,-5 (ix)
	push	af
	ld	-12 (ix),e
	ld	-11 (ix),d
	ld	-10 (ix),c
	ld	-9 (ix),b
	pop	af
	ld	a,#0x17
00221$:
	srl	-9 (ix)
	rr	-10 (ix)
	rr	-11 (ix)
	rr	-12 (ix)
	dec	a
	jr	NZ,00221$
	ld	-11 (ix),#0x00
	ld	-10 (ix),#0x00
	ld	-9 (ix),#0x00
	ld	a,-12 (ix)
	ld	-26 (ix),a
	ld	a,-11 (ix)
	ld	-25 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:75: mant2 = MANT (*pfl2) << 4;
	ld	-12 (ix),e
	ld	-11 (ix),d
	ld	a,c
	and	a, #0x7F
	ld	-10 (ix),a
	ld	-9 (ix),#0x00
	set	7, -10 (ix)
	ld	a, -10 (ix)
	push	af
	ld	a,-12 (ix)
	ld	-20 (ix),a
	ld	a,-11 (ix)
	ld	-19 (ix),a
	ld	a,-10 (ix)
	ld	-18 (ix),a
	ld	a,-9 (ix)
	ld	-17 (ix),a
	pop	af
	ld	a,#0x04
00223$:
	sla	-20 (ix)
	rl	-19 (ix)
	rl	-18 (ix)
	rl	-17 (ix)
	dec	a
	jr	NZ,00223$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:76: if (SIGN (*pfl2))
	ld	a,b
	rlc	a
	and	a,#0x01
	jr	Z,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:77: mant2 = -mant2;
	xor	a, a
	sub	a, -20 (ix)
	ld	-20 (ix),a
	ld	a, #0x00
	sbc	a, -19 (ix)
	ld	-19 (ix),a
	ld	a, #0x00
	sbc	a, -18 (ix)
	ld	-18 (ix),a
	ld	a, #0x00
	sbc	a, -17 (ix)
	ld	-17 (ix),a
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:79: if (!*pfl2)
	ld	a,-5 (ix)
	or	a, -6 (ix)
	or	a, -7 (ix)
	or	a,-8 (ix)
	jr	NZ,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:80: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	jp	00137$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:82: pfl1 = (long *)&a1;
	ld	hl,#0x001F
	add	hl,sp
	ld	-12 (ix),l
	ld	-11 (ix),h
	ld	a,-12 (ix)
	ld	-22 (ix),a
	ld	a,-11 (ix)
	ld	-21 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:83: exp1 = EXP (*pfl1);
	ld	e,-22 (ix)
	ld	d,-21 (ix)
	ld	hl, #0x000F
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl, #19
	add	hl, sp
	ex	de, hl
	ld	hl, #15
	add	hl, sp
	ld	bc, #4
	ldir
	push	af
	ld	a,-8 (ix)
	ld	-16 (ix),a
	ld	a,-7 (ix)
	ld	-15 (ix),a
	ld	a,-6 (ix)
	ld	-14 (ix),a
	ld	a,-5 (ix)
	ld	-13 (ix),a
	pop	af
	ld	b,#0x17
00225$:
	srl	-13 (ix)
	rr	-14 (ix)
	rr	-15 (ix)
	rr	-16 (ix)
	djnz	00225$
	ld	-15 (ix),#0x00
	ld	-14 (ix),#0x00
	ld	-13 (ix),#0x00
	ld	a,-16 (ix)
	ld	-16 (ix),a
	ld	a,-15 (ix)
	ld	-15 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:84: mant1 = MANT (*pfl1) << 4;
	ld	a,-8 (ix)
	ld	-4 (ix),a
	ld	a,-7 (ix)
	ld	-3 (ix),a
	ld	a,-6 (ix)
	and	a, #0x7F
	ld	-2 (ix),a
	ld	-1 (ix),#0x00
	set	7, -2 (ix)
	ld	a, -2 (ix)
	push	af
	pop	af
	ld	b,#0x04
00227$:
	sla	-4 (ix)
	rl	-3 (ix)
	rl	-2 (ix)
	rl	-1 (ix)
	djnz	00227$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:85: if (SIGN(*pfl1))
	ld	a,-5 (ix)
	rlc	a
	and	a,#0x01
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:86: if (*pfl1 & 0x80000000)
	bit	7, -5 (ix)
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:87: mant1 = -mant1;
	xor	a, a
	sub	a, -4 (ix)
	ld	-4 (ix),a
	ld	a, #0x00
	sbc	a, -3 (ix)
	ld	-3 (ix),a
	ld	a, #0x00
	sbc	a, -2 (ix)
	ld	-2 (ix),a
	ld	a, #0x00
	sbc	a, -1 (ix)
	ld	-1 (ix),a
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:89: if (!*pfl1)
	ld	a,-9 (ix)
	or	a, -10 (ix)
	or	a, -11 (ix)
	or	a,-12 (ix)
	jr	NZ,00110$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:90: return (a2);
	ld	l,8 (ix)
	ld	h,9 (ix)
	ld	e,10 (ix)
	ld	d,11 (ix)
	jp	00137$
00110$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:92: expd = exp1 - exp2;
	ld	a,-16 (ix)
	sub	a, -26 (ix)
	ld	b,a
	ld	a,-15 (ix)
	sbc	a, -25 (ix)
	ld	h,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:93: if (expd > 25)
	ld	a,#0x19
	cp	a, b
	ld	a,#0x00
	sbc	a, h
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
	ld	a,b
	sub	a, #0xE7
	ld	a,h
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
	bit	7, h
	jr	Z,00116$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:100: expd = -expd;
	xor	a, a
	sub	a, b
	ld	l,a
	ld	a, #0x00
	sbc	a, h
	ld	h,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:101: exp1 += expd;
	ld	a,-16 (ix)
	add	a, l
	ld	-16 (ix),a
	ld	a,-15 (ix)
	adc	a, h
	ld	-15 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:102: mant1 >>= expd;
	push	af
	pop	af
	inc	l
	jr	00232$
00231$:
	sra	-1 (ix)
	rr	-2 (ix)
	rr	-3 (ix)
	rr	-4 (ix)
00232$:
	dec	l
	jr	NZ,00231$
	jr	00117$
00116$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:106: mant2 >>= expd;
	push	af
	pop	af
	inc	b
	jr	00234$
00233$:
	sra	-17 (ix)
	rr	-18 (ix)
	rr	-19 (ix)
	rr	-20 (ix)
00234$:
	djnz	00233$
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:108: mant1 += mant2;
	ld	a,-4 (ix)
	add	a, -20 (ix)
	ld	e,a
	ld	a,-3 (ix)
	adc	a, -19 (ix)
	ld	d,a
	ld	a,-2 (ix)
	adc	a, -18 (ix)
	ld	c,a
	ld	a,-1 (ix)
	adc	a, -17 (ix)
	ld	b,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:110: sign = false;
	ld	-27 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:112: if (mant1 < 0)
	bit	7, b
	jr	Z,00121$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:114: mant1 = -mant1;
	xor	a, a
	sub	a, e
	ld	e,a
	ld	a, #0x00
	sbc	a, d
	ld	d,a
	ld	a, #0x00
	sbc	a, c
	ld	c,a
	ld	a, #0x00
	sbc	a, b
	ld	b,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:115: sign = true;
	ld	-27 (ix),#0x01
	jr	00154$
00121$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:117: else if (!mant1)
	ld	a,b
	or	a, c
	or	a, d
	or	a,e
	jr	NZ,00154$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:118: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00137$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:121: while (mant1 < (HIDDEN<<4)) 
00154$:
	ld	a,-16 (ix)
	ld	-4 (ix),a
	ld	a,-15 (ix)
	ld	-3 (ix),a
00123$:
	ld	-16 (ix),e
	ld	-15 (ix),d
	ld	-14 (ix),c
	ld	-13 (ix), b
	ld	a, b
	sub	a, #0x08
	jr	NC,00157$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:123: mant1 <<= 1;
	sla	e
	rl	d
	rl	c
	rl	b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:124: exp1--;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	dec	hl
	ld	-4 (ix),l
	ld	-3 (ix),h
	jr	00123$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:128: while (mant1 & 0xf0000000) 
00157$:
	ld	a,-4 (ix)
	ld	-24 (ix),a
	ld	a,-3 (ix)
	ld	-23 (ix),a
00128$:
	ld	-4 (ix),e
	ld	-3 (ix),d
	ld	-2 (ix),c
	ld	-1 (ix), b
	ld	a, b
	and	a, #0xF0
	jr	Z,00163$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:130: if (mant1&1)
	bit	0, e
	jr	Z,00127$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:131: mant1 += 2;
	ld	a,e
	add	a, #0x02
	ld	e,a
	ld	a,d
	adc	a, #0x00
	ld	d,a
	ld	a,c
	adc	a, #0x00
	ld	c,a
	ld	a,b
	adc	a, #0x00
	ld	b,a
00127$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:132: mant1 >>= 1;
	sra	b
	rr	c
	rr	d
	rr	e
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:133: exp1++;
	inc	-24 (ix)
	jr	NZ,00128$
	inc	-23 (ix)
	jr	00128$
00163$:
	ld	a,-24 (ix)
	ld	-16 (ix),a
	ld	a,-23 (ix)
	ld	-15 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:137: mant1 &= ~(HIDDEN<<4);
	res	3, -1 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:140: if (exp1 >= 0x100)
	ld	a,-23 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00135$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:141: *pfl1 = (sign ? (SIGNBIT | __INFINITY) : __INFINITY);
	bit	0,-27 (ix)
	jr	Z,00139$
	ld	de,#0x0000
	ld	bc,#0xFF80
	jr	00140$
00139$:
	ld	de,#0x0000
	ld	bc,#0x7F80
00140$:
	ld	l,-22 (ix)
	ld	h,-21 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jp	00136$
00135$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:142: else if (exp1 < 0)
	bit	7, -23 (ix)
	jr	Z,00132$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:143: *pfl1 = 0;
	ld	l,-22 (ix)
	ld	h,-21 (ix)
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
	bit	0,-27 (ix)
	jr	Z,00141$
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x00
	ld	-10 (ix),#0x00
	ld	-9 (ix),#0x80
	jr	00142$
00141$:
	xor	a, a
	ld	-12 (ix),a
	ld	-11 (ix),a
	ld	-10 (ix),a
	ld	-9 (ix),a
00142$:
	ld	l,-16 (ix)
	ld	h,-15 (ix)
	ld	a,-15 (ix)
	rla
	sbc	a, a
	ld	e,a
	ld	d,a
	push	af
	ld	-16 (ix),l
	ld	-15 (ix),h
	ld	-14 (ix),e
	ld	-13 (ix),d
	pop	af
	ld	a,#0x17
00242$:
	sla	-16 (ix)
	rl	-15 (ix)
	rl	-14 (ix)
	rl	-13 (ix)
	dec	a
	jr	NZ,00242$
	ld	a,-16 (ix)
	or	a, -12 (ix)
	ld	-16 (ix),a
	ld	a,-15 (ix)
	or	a, -11 (ix)
	ld	-15 (ix),a
	ld	a,-14 (ix)
	or	a, -10 (ix)
	ld	-14 (ix),a
	ld	a,-13 (ix)
	or	a, -9 (ix)
	ld	-13 (ix),a
	push	af
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	e,-2 (ix)
	ld	d,-1 (ix)
	pop	af
	ld	b,#0x04
00244$:
	sra	d
	rr	e
	rr	h
	rr	l
	djnz	00244$
	ld	a,-16 (ix)
	or	a, l
	ld	c,a
	ld	a,-15 (ix)
	or	a, h
	ld	b,a
	ld	a,-14 (ix)
	or	a, e
	ld	e,a
	ld	a,-13 (ix)
	or	a, d
	ld	d,a
	ld	l,-22 (ix)
	ld	h,-21 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
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
