;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:40 2017
;--------------------------------------------------------
	.module ___fsmul
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fsmul
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:62: float __fsmul (float a1, float a2) 
;	---------------------------------
; Function __fsmul
; ---------------------------------
___fsmul_start::
___fsmul:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-29
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:69: fl1.f = a1;
	ld	hl,#0x000B
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0021
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:70: fl2.f = a2;
	ld	hl,#0x0007
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0025
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:72: if (!fl1.l || !fl2.l)
	ld	hl,#0x000B
	add	hl,sp
	ld	-2 (ix),l
	ld	-1 (ix),h
	ex	de,hl
	ld	hl, #0x000F
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-11 (ix)
	or	a, -12 (ix)
	or	a, -13 (ix)
	or	a,-14 (ix)
	jr	Z,00101$
	ld	hl,#0x0007
	add	hl,sp
	ld	-14 (ix),l
	ld	-13 (ix),h
	ex	de,hl
	ld	hl, #0x000F
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-11 (ix)
	or	a, -12 (ix)
	or	a, -13 (ix)
	or	a,-14 (ix)
	jr	NZ,00102$
00101$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:73: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00113$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:76: sign = SIGN (fl1.l) ^ SIGN (fl2.l);
	ld	hl,#0x000B
	add	hl,sp
	ld	-14 (ix),l
	ld	-13 (ix),h
	ex	de,hl
	ld	hl, #0x000F
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-11 (ix)
	rlc	a
	and	a,#0x01
	ld	c,a
	ld	hl,#0x0007
	add	hl,sp
	ex	de,hl
	push	bc
	ld	hl, #0x0011
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	ld	a,-11 (ix)
	rlc	a
	and	a,#0x01
	xor	a, c
	ld	-29 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:77: exp = EXP (fl1.l) - EXCESS;
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	b,#0x17
00143$:
	srl	h
	rr	l
	rr	d
	rr	e
	djnz	00143$
	ld	d,#0x00
	ld	bc,#0x0000
	ld	a,e
	add	a,#0x82
	ld	l,a
	ld	a,d
	adc	a,#0xFF
	ld	h,a
	ld	a,c
	adc	a,#0xFF
	ld	a,b
	adc	a,#0xFF
	ld	-28 (ix),l
	ld	-27 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:78: exp += EXP (fl2.l);
	ld	hl,#0x0007
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	ld	a,#0x17
00145$:
	srl	h
	rr	l
	rr	b
	rr	c
	dec	a
	jr	NZ,00145$
	ld	b,#0x00
	ld	de,#0x0000
	ld	a,-28 (ix)
	ld	-14 (ix),a
	ld	a,-27 (ix)
	ld	-13 (ix),a
	ld	a,-27 (ix)
	rla
	sbc	a, a
	ld	-12 (ix),a
	ld	-11 (ix),a
	ld	a,-14 (ix)
	add	a, c
	ld	l,a
	ld	a,-13 (ix)
	adc	a, b
	ld	h,a
	ld	a,-12 (ix)
	adc	a, e
	ld	a,-11 (ix)
	adc	a, d
	ld	-28 (ix),l
	ld	-27 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:80: fl1.l = MANT (fl1.l);
	ld	hl,#0x000B
	add	hl,sp
	ex	de,hl
	ld	hl,#0x000B
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	res	7, l
	ld	h,#0x00
	ld	-14 (ix),c
	ld	-13 (ix),b
	ld	a,l
	set	7, a
	ld	-12 (ix),a
	ld	-11 (ix),h
	ld	hl, #0x000F
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:81: fl2.l = MANT (fl2.l);
	ld	hl,#0x0007
	add	hl,sp
	ex	de,hl
	ld	hl,#0x0007
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	res	7, l
	ld	h,#0x00
	ld	-14 (ix),c
	ld	-13 (ix),b
	ld	a,l
	set	7, a
	ld	-12 (ix),a
	ld	-11 (ix),h
	ld	hl, #0x000F
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:84: result = (fl1.l >> 8) * (fl2.l >> 8);
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ld	c,l
	ld	b,h
	ld	a,#0x08
00147$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00147$
	ld	hl,#0x0007
	add	hl,sp
	ld	-14 (ix),l
	ld	-13 (ix),h
	push	de
	push	bc
	ld	e,-14 (ix)
	ld	d,-13 (ix)
	ld	hl, #0x0013
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	pop	bc
	pop	de
	push	af
	pop	af
	ld	a,#0x08
00149$:
	srl	-11 (ix)
	rr	-12 (ix)
	rr	-13 (ix)
	rr	-14 (ix)
	dec	a
	jr	NZ,00149$
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	push	hl
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	push	hl
	push	bc
	push	de
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-26 (ix), l
	ld	-25 (ix), h
	ld	-24 (ix),e
	ld	-23 (ix),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:85: result += ((fl1.l & (unsigned long) 0xFF) * (fl2.l >> 8)) >> 8;
	ld	hl,#0x000B
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	-14 (ix),c
	ld	-13 (ix),#0x00
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x00
	ld	hl,#0x0007
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0013
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	push	af
	ld	e,-10 (ix)
	ld	d,-9 (ix)
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	pop	af
	ld	b,#0x08
00151$:
	srl	h
	rr	l
	rr	d
	rr	e
	djnz	00151$
	push	hl
	push	de
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	push	hl
	ld	l,-14 (ix)
	ld	h,-13 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
	ld	a,#0x08
00153$:
	srl	d
	rr	e
	rr	b
	rr	c
	dec	a
	jr	NZ,00153$
	ld	a,-26 (ix)
	add	a, c
	ld	-26 (ix),a
	ld	a,-25 (ix)
	adc	a, b
	ld	-25 (ix),a
	ld	a,-24 (ix)
	adc	a, e
	ld	-24 (ix),a
	ld	a,-23 (ix)
	adc	a, d
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:86: result += ((fl2.l & (unsigned long) 0xFF) * (fl1.l >> 8)) >> 8;
	ld	hl,#0x0007
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	-10 (ix),c
	ld	-9 (ix),#0x00
	ld	-8 (ix),#0x00
	ld	-7 (ix),#0x00
	ld	hl,#0x000B
	add	hl,sp
	ex	de,hl
	ld	hl, #0x000F
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	push	af
	ld	e,-14 (ix)
	ld	d,-13 (ix)
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	pop	af
	ld	b,#0x08
00155$:
	srl	h
	rr	l
	rr	d
	rr	e
	djnz	00155$
	push	hl
	push	de
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
	ld	a,#0x08
00157$:
	srl	d
	rr	e
	rr	b
	rr	c
	dec	a
	jr	NZ,00157$
	ld	a,-26 (ix)
	add	a, c
	ld	-26 (ix),a
	ld	a,-25 (ix)
	adc	a, b
	ld	-25 (ix),a
	ld	a,-24 (ix)
	adc	a, e
	ld	-24 (ix),a
	ld	a,-23 (ix)
	adc	a, d
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:89: result += 0x40;
	ld	a,-26 (ix)
	add	a, #0x40
	ld	-26 (ix),a
	ld	a,-25 (ix)
	adc	a, #0x00
	ld	-25 (ix),a
	ld	a,-24 (ix)
	adc	a, #0x00
	ld	-24 (ix),a
	ld	a,-23 (ix)
	adc	a, #0x00
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:91: if (result & SIGNBIT)
	bit	7, -23 (ix)
	jr	Z,00105$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:94: result += 0x40;
	ld	a,-26 (ix)
	add	a, #0x40
	ld	-26 (ix),a
	ld	a,-25 (ix)
	adc	a, #0x00
	ld	-25 (ix),a
	ld	a,-24 (ix)
	adc	a, #0x00
	ld	-24 (ix),a
	ld	a,-23 (ix)
	adc	a, #0x00
	ld	-23 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:95: result >>= 8;
	push	af
	pop	af
	ld	b,#0x08
00160$:
	srl	-23 (ix)
	rr	-24 (ix)
	rr	-25 (ix)
	rr	-26 (ix)
	djnz	00160$
	jr	00106$
00105$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:99: result >>= 7;
	push	af
	pop	af
	ld	b,#0x07
00162$:
	srl	-23 (ix)
	rr	-24 (ix)
	rr	-25 (ix)
	rr	-26 (ix)
	djnz	00162$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:100: exp--;
	ld	l,-28 (ix)
	ld	h,-27 (ix)
	dec	hl
	ld	-28 (ix),l
	ld	-27 (ix),h
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:103: result &= ~HIDDEN;
	res	7, -24 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:106: if (exp >= 0x100)
	ld	a,-27 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:107: fl1.l = (sign ? SIGNBIT : 0) | __INFINITY;
	ld	hl,#0x000B
	add	hl,sp
	ld	-10 (ix),l
	ld	-9 (ix),h
	ld	a,-29 (ix)
	or	a, a
	jr	Z,00115$
	ld	-14 (ix),#0x00
	ld	-13 (ix),#0x00
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x80
	jr	00116$
00115$:
	xor	a, a
	ld	-14 (ix),a
	ld	-13 (ix),a
	ld	-12 (ix),a
	ld	-11 (ix),a
00116$:
	ld	e,-14 (ix)
	ld	d,-13 (ix)
	ld	a,-12 (ix)
	set	7, a
	ld	c,a
	ld	a,-11 (ix)
	or	a, #0x7F
	ld	b,a
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
	jp	00112$
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:108: else if (exp < 0)
	bit	7, -27 (ix)
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:109: fl1.l = 0;
	ld	hl,#0x000B
	add	hl,sp
	ld	b,h
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	inc	hl
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
	jp	00112$
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:111: fl1.l = PACK (sign ? SIGNBIT : 0 , exp, result);
	ld	hl,#0x000B
	add	hl,sp
	ld	-10 (ix),l
	ld	-9 (ix),h
	ld	a,-29 (ix)
	or	a, a
	jr	Z,00117$
	ld	-14 (ix),#0x00
	ld	-13 (ix),#0x00
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x80
	jr	00118$
00117$:
	xor	a, a
	ld	-14 (ix),a
	ld	-13 (ix),a
	ld	-12 (ix),a
	ld	-11 (ix),a
00118$:
	ld	a,-28 (ix)
	ld	-6 (ix),a
	ld	a,-27 (ix)
	ld	-5 (ix),a
	ld	a,-27 (ix)
	rla
	sbc	a, a
	ld	-4 (ix),a
	ld	-3 (ix),a
	push	af
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	e,-4 (ix)
	ld	d,-3 (ix)
	pop	af
	ld	b,#0x17
00164$:
	add	hl, hl
	rl	e
	rl	d
	djnz	00164$
	ld	a,-14 (ix)
	or	a, l
	ld	-6 (ix),a
	ld	a,-13 (ix)
	or	a, h
	ld	-5 (ix),a
	ld	a,-12 (ix)
	or	a, e
	ld	-4 (ix),a
	ld	a,-11 (ix)
	or	a, d
	ld	-3 (ix),a
	ld	a,-6 (ix)
	or	a, -26 (ix)
	ld	-6 (ix),a
	ld	a,-5 (ix)
	or	a, -25 (ix)
	ld	-5 (ix),a
	ld	a,-4 (ix)
	or	a, -24 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	or	a, -23 (ix)
	ld	-3 (ix),a
	ld	e,-10 (ix)
	ld	d,-9 (ix)
	ld	hl, #0x0017
	add	hl, sp
	ld	bc, #0x0004
	ldir
00112$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:112: return (fl1.f);
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ex	de, hl
00113$:
	ld	sp, ix
	pop	ix
	ret
___fsmul_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
