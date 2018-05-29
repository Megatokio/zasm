;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:45 2017
;--------------------------------------------------------
	.module __mullong
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl __mullong
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:96: long _mullong (long a, long b)
;	---------------------------------
; Function _mullong
; ---------------------------------
__mullong_start::
__mullong:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-8
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:100: bcast(a)->i.hi *= bcast(b)->i.lo;
	ld	hl,#0x000C
	add	hl,sp
	ld	c,l
	ld	b,h
	inc	hl
	inc	hl
	ld	-2 (ix),l
	ld	-1 (ix),h
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,#0x0010
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	push	bc
	push	hl
	push	de
	call	__mulint
	pop	af
	pop	af
	ld	d,l
	ld	e,h
	pop	bc
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),d
	inc	hl
	ld	(hl),e
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:101: bcast(a)->i.hi += bcast(b)->i.hi * bcast(a)->i.lo;
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	-2 (ix),l
	ld	-1 (ix),h
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-6 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-5 (ix),a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	push	bc
	push	hl
	push	de
	call	__mulint
	pop	af
	pop	af
	ld	d,l
	ld	e,h
	pop	bc
	ld	a,-6 (ix)
	add	a, d
	ld	d,a
	ld	a,-5 (ix)
	adc	a, e
	ld	e,a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),d
	inc	hl
	ld	(hl),e
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:104: bcast(a)->i.hi += bcast(a)->b.b1 * bcast(b)->b.b1;
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	-6 (ix),l
	ld	-5 (ix),h
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l, c
	ld	h, b
	inc	hl
	ld	a,(hl)
	ld	-2 (ix),a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	ld	h,(hl)
	push	de
	push	bc
	ld	e,-2 (ix)
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00103$:
	add	hl,hl
	jr	NC,00104$
	add	hl,de
00104$:
	djnz	00103$
	pop	bc
	pop	de
	add	hl,de
	ex	de,hl
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:106: i12 = bcast(b)->b.b0 * bcast(a)->b.b1;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	e,(hl)
	ld	l, c
	ld	h, b
	inc	hl
	ld	h,(hl)
	push	bc
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00105$:
	add	hl,hl
	jr	NC,00106$
	add	hl,de
00106$:
	djnz	00105$
	pop	bc
	ex	de,hl
	inc	sp
	inc	sp
	push	de
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:107: bcast(b)->bi.i12 = bcast(a)->b.b0 * bcast(b)->b.b1;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	ld	-6 (ix),l
	ld	-5 (ix),h
	ld	l, c
	ld	h, b
	ld	e,(hl)
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	ld	h,(hl)
	push	bc
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00107$:
	add	hl,hl
	jr	NC,00108$
	add	hl,de
00108$:
	djnz	00107$
	pop	bc
	ex	de,hl
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:110: bcast(b)->b.b3 = ((bcast(b)->bi.i12 += i12) < i12);
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	inc	hl
	inc	hl
	ld	-6 (ix),l
	ld	-5 (ix),h
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	ld	-2 (ix),l
	ld	-1 (ix),h
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,e
	add	a, -8 (ix)
	ld	e,a
	ld	a,d
	adc	a, -7 (ix)
	ld	d,a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	a,e
	sub	a, -8 (ix)
	ld	a,d
	sbc	a, -7 (ix)
	ld	a,#0x00
	rla
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:112: bcast(a)->i.lo  = bcast(a)->b.b0 * bcast(b)->b.b0;
	ld	e, c
	ld	d, b
	ld	a,(bc)
	ld	b,a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	h,(hl)
	push	de
	ld	e,b
	ld	l, #0x00
	ld	d, l
	ld	b, #0x08
00109$:
	add	hl,hl
	jr	NC,00110$
	add	hl,de
00110$:
	djnz	00109$
	pop	de
	ld	c,l
	ld	b,h
	ld	a,c
	ld	(de),a
	inc	de
	ld	a,b
	ld	(de),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:114: bcast(b)->bi.b0 = 0;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	(hl),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__mullong.c:116: return a + b;
	ld	a,4 (ix)
	add	a, 8 (ix)
	ld	b,a
	ld	a,5 (ix)
	adc	a, 9 (ix)
	ld	c,a
	ld	a,6 (ix)
	adc	a, 10 (ix)
	ld	e,a
	ld	a,7 (ix)
	adc	a, 11 (ix)
	ld	d,a
	ld	l,b
	ld	h,c
	ld	sp, ix
	pop	ix
	ret
__mullong_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
