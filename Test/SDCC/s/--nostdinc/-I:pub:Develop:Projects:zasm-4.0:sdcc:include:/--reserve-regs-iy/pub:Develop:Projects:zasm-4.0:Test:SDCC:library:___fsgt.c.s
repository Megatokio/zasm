;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:41 2017
;--------------------------------------------------------
	.module ___fsgt
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fsgt
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:61: char __fsgt (float a1, float a2)
;	---------------------------------
; Function __fsgt
; ---------------------------------
___fsgt_start::
___fsgt:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-12
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:65: fl1.f = a1;
	ld	hl,#0x0004
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0010
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:66: fl2.f = a2;
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0014
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:68: if (((fl1.l | fl2.l) & 0x7FFFFFFF) == 0)
	ld	hl,#0x0004
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0008
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
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,-4 (ix)
	or	a, e
	ld	e,a
	ld	a,-3 (ix)
	or	a, d
	ld	d,a
	ld	a,-2 (ix)
	or	a, c
	ld	l,a
	ld	a,-1 (ix)
	or	a, b
	ld	h,a
	ld	a,e
	or	a,a
	jr	NZ,00102$
	or	a,d
	jr	NZ,00102$
	cp	a, a
	adc	hl, hl
	jr	NZ,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:69: return (0);
	ld	l,#0x00
	jp	00110$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:71: if (fl1.l<0 && fl2.l<0) {
	ld	hl,#0x0004
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	bit	7, h
	jr	Z,00106$
	ld	hl,#0x0000
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	bit	7, h
	jr	Z,00106$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:72: if (fl2.l > fl1.l)
	ld	hl,#0x0000
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0008
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl,#0x0004
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	ld	a,d
	sub	a, -4 (ix)
	ld	a,e
	sbc	a, -3 (ix)
	ld	a,c
	sbc	a, -2 (ix)
	ld	a,h
	sbc	a, -1 (ix)
	jp	PO, 00134$
	xor	a, #0x80
00134$:
	jp	P,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:73: return (1);
	ld	l,#0x01
	jr	00110$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:74: return (0);
	ld	l,#0x00
	jr	00110$
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:77: if (fl1.l > fl2.l)
	ld	hl,#0x0004
	add	hl,sp
	ex	de,hl
	ld	hl, #0x0008
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	hl,#0x0000
	add	hl,sp
	ld	d,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	h,(hl)
	ld	a,d
	sub	a, -4 (ix)
	ld	a,e
	sbc	a, -3 (ix)
	ld	a,c
	sbc	a, -2 (ix)
	ld	a,h
	sbc	a, -1 (ix)
	jp	PO, 00135$
	xor	a, #0x80
00135$:
	jp	P,00109$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:78: return (1);
	ld	l,#0x01
	jr	00110$
00109$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fsgt.c:79: return (0);
	ld	l,#0x00
00110$:
	ld	sp, ix
	pop	ix
	ret
___fsgt_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
