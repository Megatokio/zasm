;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:40 2017
;--------------------------------------------------------
	.module ___fslt
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fslt
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:61: char __fslt (float a1, float a2)
;	---------------------------------
; Function __fslt
; ---------------------------------
___fslt_start::
___fslt:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-14
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:65: fl1.f = a1;
	ld	hl,#0x0004
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0012
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:66: fl2.f = a2;
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0016
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:68: if (((fl1.l | fl2.l) & 0x7FFFFFFF) == 0)
	ld	hl,#0x0004
	add	hl,sp
	ld	-6 (ix),l
	ld	-5 (ix),h
	ex	de,hl
	ld	hl, #0x000A
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl,#0x0000
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
	ld	a,e
	or	a, -4 (ix)
	ld	e,a
	ld	a,d
	or	a, -3 (ix)
	ld	d,a
	ld	a,l
	or	a, -2 (ix)
	ld	l,a
	ld	a,h
	or	a, -1 (ix)
	ld	h,a
	ld	a,e
	or	a,a
	jr	NZ,00102$
	or	a,d
	jr	NZ,00102$
	cp	a, a
	adc	hl, hl
	jr	NZ,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:69: return (0);
	ld	l,#0x00
	jp	00110$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:71: if (fl1.l<0 && fl2.l<0) {
	ld	hl,#0x0004
	add	hl,sp
	ld	c,l
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	b,(hl)
	dec	hl
	ld	l,(hl)
	bit	7, b
	jr	Z,00106$
	ld	hl,#0x0000
	add	hl,sp
	ld	c,l
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	b,(hl)
	dec	hl
	ld	l,(hl)
	bit	7, b
	jr	Z,00106$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:72: if (fl2.l < fl1.l)
	ld	hl,#0x0000
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ex	de,hl
	ld	hl, #0x000A
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl,#0x0004
	add	hl,sp
	ld	c,l
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	b,(hl)
	dec	hl
	ld	l,(hl)
	ld	a,-4 (ix)
	sub	a, e
	ld	a,-3 (ix)
	sbc	a, d
	ld	a,-2 (ix)
	sbc	a, l
	ld	a,-1 (ix)
	sbc	a, b
	jp	PO, 00134$
	xor	a, #0x80
00134$:
	jp	P,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:73: return (1);
	ld	l,#0x01
	jr	00110$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:74: return (0);
	ld	l,#0x00
	jr	00110$
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:77: if (fl1.l < fl2.l)
	ld	hl,#0x0004
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ex	de,hl
	ld	hl, #0x000A
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl,#0x0000
	add	hl,sp
	ld	c,l
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	inc	hl
	ld	b,(hl)
	dec	hl
	ld	l,(hl)
	ld	a,-4 (ix)
	sub	a, e
	ld	a,-3 (ix)
	sbc	a, d
	ld	a,-2 (ix)
	sbc	a, l
	ld	a,-1 (ix)
	sbc	a, b
	jp	PO, 00135$
	xor	a, #0x80
00135$:
	jp	P,00109$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:78: return (1);
	ld	l,#0x01
	jr	00110$
00109$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fslt.c:79: return (0);
	ld	l,#0x00
00110$:
	ld	sp, ix
	pop	ix
	ret
___fslt_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
