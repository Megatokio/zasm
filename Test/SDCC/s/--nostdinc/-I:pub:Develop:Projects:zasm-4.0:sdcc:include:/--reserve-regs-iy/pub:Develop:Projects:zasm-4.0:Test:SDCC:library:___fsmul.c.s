;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:43 2017
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
	ld	hl,#-24
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:69: fl1.f = a1;
	ld	hl,#0x000B
	add	hl,sp
	ex	de,hl
	ld	hl, #0x001C
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:70: fl2.f = a2;
	ld	hl,#0x0007
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0020
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:72: if (!fl1.l || !fl2.l)
	ld	hl,#0x000B
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
	jr	Z,00101$
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a, (hl)
	or	a, b
	or	a, d
	or	a,e
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
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	a, (hl)
	rlc	a
	and	a,#0x01
	ld	-1 (ix),a
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a, (hl)
	rlc	a
	and	a,#0x01
	xor	a, -1 (ix)
	ld	-24 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:77: exp = EXP (fl1.l) - EXCESS;
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x17
00143$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00143$
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
	ld	-23 (ix),l
	ld	-22 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:78: exp += EXP (fl2.l);
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x17
00145$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00145$
	ld	-5 (ix),e
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	e,-23 (ix)
	ld	d,-22 (ix)
	ld	a,-22 (ix)
	rla
	sbc	a, a
	ld	b,a
	ld	c,a
	ld	a,e
	add	a, -5 (ix)
	ld	h,a
	ld	a,d
	adc	a, -4 (ix)
	ld	l,a
	ld	a,b
	adc	a, -3 (ix)
	ld	a,c
	adc	a, -2 (ix)
	ld	-23 (ix),h
	ld	-22 (ix),l
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:80: fl1.l = MANT (fl1.l);
	ld	hl,#0x000B
	add	hl,sp
	ld	-5 (ix),l
	ld	-4 (ix),h
	ld	hl,#0x000B
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
	set	7, c
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:81: fl2.l = MANT (fl2.l);
	ld	hl,#0x0007
	add	hl,sp
	ld	-5 (ix),l
	ld	-4 (ix),h
	ld	hl,#0x0007
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
	set	7, c
	ld	a, c
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:84: result = (fl1.l >> 8) * (fl2.l >> 8);
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	push	af
	ld	-5 (ix),e
	ld	-4 (ix),d
	ld	-3 (ix),c
	ld	-2 (ix),b
	pop	af
	ld	a,#0x08
00147$:
	srl	-2 (ix)
	rr	-3 (ix)
	rr	-4 (ix)
	rr	-5 (ix)
	dec	a
	jr	NZ,00147$
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x08
00149$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00149$
	push	bc
	push	de
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	push	hl
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	push	hl
	call	__mullong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-21 (ix), l
	ld	-20 (ix), h
	ld	-19 (ix),e
	ld	-18 (ix),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:85: result += ((fl1.l & (unsigned long) 0xFF) * (fl2.l >> 8)) >> 8;
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-5 (ix),e
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x08
00151$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00151$
	push	bc
	push	de
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	push	hl
	ld	l,-5 (ix)
	ld	h,-4 (ix)
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
	ld	a,-21 (ix)
	add	a, c
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, b
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, e
	ld	-19 (ix),a
	ld	a,-18 (ix)
	adc	a, d
	ld	-18 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:86: result += ((fl2.l & (unsigned long) 0xFF) * (fl1.l >> 8)) >> 8;
	ld	hl,#0x0007
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	-5 (ix),e
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x00
	ld	hl,#0x000B
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x08
00155$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00155$
	push	bc
	push	de
	ld	l,-3 (ix)
	ld	h,-2 (ix)
	push	hl
	ld	l,-5 (ix)
	ld	h,-4 (ix)
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
	ld	a,-21 (ix)
	add	a, c
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, b
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, e
	ld	-19 (ix),a
	ld	a,-18 (ix)
	adc	a, d
	ld	-18 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:89: result += 0x40;
	ld	a,-21 (ix)
	add	a, #0x40
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, #0x00
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, #0x00
	ld	-19 (ix),a
	ld	a,-18 (ix)
	adc	a, #0x00
	ld	-18 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:91: if (result & SIGNBIT)
	bit	7, -18 (ix)
	jr	Z,00105$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:94: result += 0x40;
	ld	a,-21 (ix)
	add	a, #0x40
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, #0x00
	ld	-20 (ix),a
	ld	a,-19 (ix)
	adc	a, #0x00
	ld	-19 (ix),a
	ld	a,-18 (ix)
	adc	a, #0x00
	ld	-18 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:95: result >>= 8;
	push	af
	pop	af
	ld	b,#0x08
00160$:
	srl	-18 (ix)
	rr	-19 (ix)
	rr	-20 (ix)
	rr	-21 (ix)
	djnz	00160$
	jr	00106$
00105$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:99: result >>= 7;
	push	af
	pop	af
	ld	b,#0x07
00162$:
	srl	-18 (ix)
	rr	-19 (ix)
	rr	-20 (ix)
	rr	-21 (ix)
	djnz	00162$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:100: exp--;
	ld	l,-23 (ix)
	ld	h,-22 (ix)
	dec	hl
	ld	-23 (ix),l
	ld	-22 (ix),h
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:103: result &= ~HIDDEN;
	res	7, -19 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:106: if (exp >= 0x100)
	ld	a,-22 (ix)
	xor	a, #0x80
	sub	a, #0x81
	jr	C,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:107: fl1.l = (sign ? SIGNBIT : 0) | __INFINITY;
	ld	hl,#0x000B
	add	hl,sp
	ld	-5 (ix),l
	ld	-4 (ix),h
	ld	a,-24 (ix)
	or	a, a
	jr	Z,00115$
	ld	bc,#0x0000
	ld	hl,#0x0080
	jr	00116$
00115$:
	ld	bc,#0x0000
	ld	hl,#0x0000
00116$:
	ld	a,h
	set	7, a
	ld	d,a
	ld	a,l
	or	a, #0x7F
	ld	e,a
	ld	l,-5 (ix)
	ld	h,-4 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
	inc	hl
	ld	(hl),d
	inc	hl
	ld	(hl),e
	jp	00112$
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:108: else if (exp < 0)
	bit	7, -22 (ix)
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:109: fl1.l = 0;
	ld	hl,#0x000B
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
	jp	00112$
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:111: fl1.l = PACK (sign ? SIGNBIT : 0 , exp, result);
	ld	hl,#0x000B
	add	hl,sp
	ld	c,l
	ld	b,h
	ld	a,-24 (ix)
	or	a, a
	jr	Z,00117$
	ld	-5 (ix),#0x00
	ld	-4 (ix),#0x00
	ld	-3 (ix),#0x00
	ld	-2 (ix),#0x80
	jr	00118$
00117$:
	xor	a, a
	ld	-5 (ix),a
	ld	-4 (ix),a
	ld	-3 (ix),a
	ld	-2 (ix),a
00118$:
	ld	a,-23 (ix)
	ld	-9 (ix),a
	ld	a,-22 (ix)
	ld	-8 (ix),a
	ld	a,-22 (ix)
	rla
	sbc	a, a
	ld	-7 (ix),a
	ld	-6 (ix),a
	push	af
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	ld	d,-7 (ix)
	ld	e,-6 (ix)
	pop	af
	ld	a,#0x17
00164$:
	add	hl, hl
	rl	d
	rl	e
	dec	a
	jr	NZ,00164$
	ld	a,-5 (ix)
	or	a, l
	ld	-9 (ix),a
	ld	a,-4 (ix)
	or	a, h
	ld	-8 (ix),a
	ld	a,-3 (ix)
	or	a, d
	ld	-7 (ix),a
	ld	a,-2 (ix)
	or	a, e
	ld	-6 (ix),a
	ld	a,-9 (ix)
	or	a, -21 (ix)
	ld	-9 (ix),a
	ld	a,-8 (ix)
	or	a, -20 (ix)
	ld	-8 (ix),a
	ld	a,-7 (ix)
	or	a, -19 (ix)
	ld	-7 (ix),a
	ld	a,-6 (ix)
	or	a, -18 (ix)
	ld	-6 (ix),a
	ld	e, c
	ld	d, b
	ld	hl, #0x000F
	add	hl, sp
	ld	bc, #0x0004
	ldir
00112$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsmul.c:112: return (fl1.f);
	ld	hl,#0x000B
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
