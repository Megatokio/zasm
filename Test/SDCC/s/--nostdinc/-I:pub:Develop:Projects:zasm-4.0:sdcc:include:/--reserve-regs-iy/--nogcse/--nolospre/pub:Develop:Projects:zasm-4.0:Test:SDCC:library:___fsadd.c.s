;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:11:22 2017
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
	ld	hl,#-25
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:73: pfl2 = (long *)&a2;
	ld	hl,#0x0021
	add	hl,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:74: exp2 = EXP (*pfl2);
	ld	e,l
	ld	d,h
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	-4 (ix),c
	ld	-3 (ix),b
	ld	-2 (ix),l
	ld	-1 (ix),h
	push	af
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	c,-2 (ix)
	ld	b,-1 (ix)
	pop	af
	ld	a,#0x17
00202$:
	srl	b
	rr	c
	rr	h
	rr	l
	dec	a
	jr	NZ,00202$
	ld	-22 (ix), l
	ld	-21 (ix), #0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:75: mant2 = MANT (*pfl2) << 4;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	c,-2 (ix)
	res	7, c
	ld	b,#0x00
	set	7, c
	ld	a, c
	push	af
	ld	-16 (ix),l
	ld	-15 (ix),h
	ld	-14 (ix),c
	ld	-13 (ix),b
	pop	af
	ld	a,#0x04
00204$:
	sla	-16 (ix)
	rl	-15 (ix)
	rl	-14 (ix)
	rl	-13 (ix)
	dec	a
	jr	NZ,00204$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:76: if (SIGN (*pfl2))
	ld	a,-1 (ix)
	rlc	a
	and	a,#0x01
	jr	Z,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:77: mant2 = -mant2;
	xor	a, a
	sub	a, -16 (ix)
	ld	-16 (ix),a
	ld	a, #0x00
	sbc	a, -15 (ix)
	ld	-15 (ix),a
	ld	a, #0x00
	sbc	a, -14 (ix)
	ld	-14 (ix),a
	ld	a, #0x00
	sbc	a, -13 (ix)
	ld	-13 (ix),a
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:79: if (!*pfl2)
	ld	hl, #0x0015
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-1 (ix)
	or	a, -2 (ix)
	or	a, -3 (ix)
	or	a,-4 (ix)
	jr	NZ,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:80: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	jp	00137$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:82: pfl1 = (long *)&a1;
	ld	hl,#0x001D
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ld	a,-4 (ix)
	ld	-18 (ix),a
	ld	a,-3 (ix)
	ld	-17 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:83: exp1 = EXP (*pfl1);
	ld	e,-18 (ix)
	ld	d,-17 (ix)
	ld	hl, #0x0015
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	push	af
	ld	a,-4 (ix)
	ld	-8 (ix),a
	ld	a,-3 (ix)
	ld	-7 (ix),a
	ld	a,-2 (ix)
	ld	-6 (ix),a
	ld	a,-1 (ix)
	ld	-5 (ix),a
	pop	af
	ld	b,#0x17
00206$:
	srl	-5 (ix)
	rr	-6 (ix)
	rr	-7 (ix)
	rr	-8 (ix)
	djnz	00206$
	ld	-7 (ix),#0x00
	ld	-6 (ix),#0x00
	ld	-5 (ix),#0x00
	ld	a,-8 (ix)
	ld	-20 (ix),a
	ld	a,-7 (ix)
	ld	-19 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:84: mant1 = MANT (*pfl1) << 4;
	ld	a,-4 (ix)
	ld	-8 (ix),a
	ld	a,-3 (ix)
	ld	-7 (ix),a
	ld	a,-2 (ix)
	and	a, #0x7F
	ld	-6 (ix),a
	ld	-5 (ix),#0x00
	set	7, -6 (ix)
	ld	a, -6 (ix)
	push	af
	ld	a,-8 (ix)
	ld	-12 (ix),a
	ld	a,-7 (ix)
	ld	-11 (ix),a
	ld	a,-6 (ix)
	ld	-10 (ix),a
	ld	a,-5 (ix)
	ld	-9 (ix),a
	pop	af
	ld	b,#0x04
00208$:
	sla	-12 (ix)
	rl	-11 (ix)
	rl	-10 (ix)
	rl	-9 (ix)
	djnz	00208$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:85: if (SIGN(*pfl1))
	ld	a,-1 (ix)
	rlc	a
	and	a,#0x01
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:86: if (*pfl1 & 0x80000000)
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,c
	add	hl, hl
	jr	NC,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:87: mant1 = -mant1;
	xor	a, a
	sub	a, -12 (ix)
	ld	-12 (ix),a
	ld	a, #0x00
	sbc	a, -11 (ix)
	ld	-11 (ix),a
	ld	a, #0x00
	sbc	a, -10 (ix)
	ld	-10 (ix),a
	ld	a, #0x00
	sbc	a, -9 (ix)
	ld	-9 (ix),a
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:89: if (!*pfl1)
	ld	l,-18 (ix)
	ld	h,-17 (ix)
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	h,(hl)
	ld	a,h
	or	a, b
	or	a, e
	or	a,d
	jr	NZ,00110$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:90: return (a2);
	ld	l,8 (ix)
	ld	h,9 (ix)
	ld	e,10 (ix)
	ld	d,11 (ix)
	jp	00137$
00110$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:92: expd = exp1 - exp2;
	ld	a,-20 (ix)
	sub	a, -22 (ix)
	ld	-24 (ix),a
	ld	a,-19 (ix)
	sbc	a, -21 (ix)
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:93: if (expd > 25)
	ld	a,#0x19
	cp	a, -24 (ix)
	ld	a,#0x00
	sbc	a, -23 (ix)
	jp	PO, 00211$
	xor	a, #0x80
00211$:
	jp	P,00112$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:94: return (a1);
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	jp	00137$
00112$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:95: if (expd < -25)
	ld	a,-24 (ix)
	sub	a, #0xE7
	ld	a,-23 (ix)
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
	bit	7, -23 (ix)
	jr	Z,00116$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:100: expd = -expd;
	xor	a, a
	sub	a, -24 (ix)
	ld	-24 (ix),a
	ld	a, #0x00
	sbc	a, -23 (ix)
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:101: exp1 += expd;
	ld	a,-20 (ix)
	add	a, -24 (ix)
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, -23 (ix)
	ld	-19 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:102: mant1 >>= expd;
	ld	b,-24 (ix)
	push	af
	pop	af
	inc	b
	jr	00213$
00212$:
	sra	-9 (ix)
	rr	-10 (ix)
	rr	-11 (ix)
	rr	-12 (ix)
00213$:
	djnz	00212$
	jr	00117$
00116$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:106: mant2 >>= expd;
	ld	b,-24 (ix)
	push	af
	pop	af
	inc	b
	jr	00215$
00214$:
	sra	-13 (ix)
	rr	-14 (ix)
	rr	-15 (ix)
	rr	-16 (ix)
00215$:
	djnz	00214$
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:108: mant1 += mant2;
	ld	a,-12 (ix)
	add	a, -16 (ix)
	ld	-12 (ix),a
	ld	a,-11 (ix)
	adc	a, -15 (ix)
	ld	-11 (ix),a
	ld	a,-10 (ix)
	adc	a, -14 (ix)
	ld	-10 (ix),a
	ld	a,-9 (ix)
	adc	a, -13 (ix)
	ld	-9 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:110: sign = false;
	ld	-25 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:112: if (mant1 < 0)
	bit	7, -9 (ix)
	jr	Z,00121$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:114: mant1 = -mant1;
	xor	a, a
	sub	a, -12 (ix)
	ld	-12 (ix),a
	ld	a, #0x00
	sbc	a, -11 (ix)
	ld	-11 (ix),a
	ld	a, #0x00
	sbc	a, -10 (ix)
	ld	-10 (ix),a
	ld	a, #0x00
	sbc	a, -9 (ix)
	ld	-9 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:115: sign = true;
	ld	-25 (ix),#0x01
	jr	00154$
00121$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:117: else if (!mant1)
	ld	a,-9 (ix)
	or	a, -10 (ix)
	or	a, -11 (ix)
	or	a,-12 (ix)
	jr	NZ,00154$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:118: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00137$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:121: while (mant1 < (HIDDEN<<4)) 
00154$:
	ld	a,-20 (ix)
	ld	-8 (ix),a
	ld	a,-19 (ix)
	ld	-7 (ix),a
00123$:
	ld	hl, #21
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
	sla	-12 (ix)
	rl	-11 (ix)
	rl	-10 (ix)
	rl	-9 (ix)
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
	ld	-20 (ix),a
	ld	a,-7 (ix)
	ld	-19 (ix),a
	ld	a,-20 (ix)
	ld	-8 (ix),a
	ld	a,-19 (ix)
	ld	-7 (ix),a
00128$:
	ld	hl, #21
	add	hl, sp
	ex	de, hl
	ld	hl, #13
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-1 (ix)
	and	a, #0xF0
	jr	Z,00163$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:130: if (mant1&1)
	bit	0, -12 (ix)
	jr	Z,00127$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:131: mant1 += 2;
	ld	a,-12 (ix)
	add	a, #0x02
	ld	-12 (ix),a
	ld	a,-11 (ix)
	adc	a, #0x00
	ld	-11 (ix),a
	ld	a,-10 (ix)
	adc	a, #0x00
	ld	-10 (ix),a
	ld	a,-9 (ix)
	adc	a, #0x00
	ld	-9 (ix),a
00127$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:132: mant1 >>= 1;
	push	af
	pop	af
	ld	b,#0x01
	sra	-9 (ix)
	rr	-10 (ix)
	rr	-11 (ix)
	rr	-12 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:133: exp1++;
	inc	-8 (ix)
	jr	NZ,00128$
	inc	-7 (ix)
	jr	00128$
00163$:
	ld	a,-8 (ix)
	ld	-20 (ix),a
	ld	a,-7 (ix)
	ld	-19 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:137: mant1 &= ~(HIDDEN<<4);
	ld	hl, #17
	add	hl, sp
	ex	de, hl
	ld	hl, #13
	add	hl, sp
	ld	bc, #4
	ldir
	ld	a,-8 (ix)
	ld	-12 (ix),a
	ld	a,-7 (ix)
	ld	-11 (ix),a
	ld	a,-6 (ix)
	ld	-10 (ix),a
	ld	a,-5 (ix)
	and	a, #0xF7
	ld	-9 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:140: if (exp1 >= 0x100)
	ld	a,-19 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00135$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:141: *pfl1 = (sign ? (SIGNBIT | __INFINITY) : __INFINITY);
	ld	a,-18 (ix)
	ld	-8 (ix),a
	ld	a,-17 (ix)
	ld	-7 (ix),a
	bit	0,-25 (ix)
	jr	Z,00139$
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x80
	ld	-1 (ix),#0xFF
	jr	00140$
00139$:
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x80
	ld	-1 (ix),#0x7F
00140$:
	ld	e,-8 (ix)
	ld	d,-7 (ix)
	ld	hl, #0x0015
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jp	00136$
00135$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:142: else if (exp1 < 0)
	bit	7, -19 (ix)
	jr	Z,00132$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsadd.c:143: *pfl1 = 0;
	ld	l,-18 (ix)
	ld	h,-17 (ix)
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
	ld	a,-18 (ix)
	ld	-8 (ix),a
	ld	a,-17 (ix)
	ld	-7 (ix),a
	bit	0,-25 (ix)
	jr	Z,00141$
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	-1 (ix),#0x80
	jr	00142$
00141$:
	xor	a, a
	ld	-4 (ix),a
	ld	-3 (ix),a
	ld	-2 (ix),a
	ld	-1 (ix),a
00142$:
	ld	l,-20 (ix)
	ld	h,-19 (ix)
	ld	a,-19 (ix)
	rla
	sbc	a, a
	ld	e,a
	ld	d,a
	ld	b,#0x17
00223$:
	add	hl, hl
	rl	e
	rl	d
	djnz	00223$
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
	push	af
	ld	e,-12 (ix)
	ld	d,-11 (ix)
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	pop	af
	ld	b,#0x04
00225$:
	sra	h
	rr	l
	rr	d
	rr	e
	djnz	00225$
	ld	a,-4 (ix)
	or	a, e
	ld	e,a
	ld	a,-3 (ix)
	or	a, d
	ld	d,a
	ld	a,-2 (ix)
	or	a, l
	ld	b,a
	ld	a,-1 (ix)
	or	a, h
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
