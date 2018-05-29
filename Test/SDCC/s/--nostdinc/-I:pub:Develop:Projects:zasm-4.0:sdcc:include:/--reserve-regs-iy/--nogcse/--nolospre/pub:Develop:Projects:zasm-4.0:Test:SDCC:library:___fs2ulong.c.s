;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:11:20 2017
;--------------------------------------------------------
	.module ___fs2ulong
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fs2ulong
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:63: __fs2ulong (float a1)
;	---------------------------------
; Function __fs2ulong
; ---------------------------------
___fs2ulong_start::
___fs2ulong:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-10
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:69: fl1.f = a1;
	ld	hl,#0x0006
	add	hl,sp
	ex	de,hl
	ld	hl, #0x000E
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:71: if (!fl1.l || SIGN(fl1.l))
	ld	hl,#0x0006
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	a, (hl)
	or	a, c
	or	a, d
	or	a,e
	jr	Z,00101$
	ld	hl,#0x0006
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
	jr	Z,00102$
00101$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:72: return (0);
	ld	hl,#0x0000
	ld	e,l
	ld	d,h
	jp	00104$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:74: exp = EXP (fl1.l) - EXCESS - 24;
	ld	hl,#0x0006
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,#0x17
00109$:
	srl	b
	rr	c
	rr	d
	rr	e
	dec	a
	jr	NZ,00109$
	ld	d,#0x00
	ld	bc,#0x0000
	ld	a,e
	add	a,#0x6A
	ld	l,a
	ld	a,d
	adc	a,#0xFF
	ld	h,a
	ld	a,c
	adc	a,#0xFF
	ld	a,b
	adc	a,#0xFF
	ld	-6 (ix),l
	ld	-5 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:75: l = MANT (fl1.l);
	ld	hl,#0x0006
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
	ld	-10 (ix),e
	ld	-9 (ix),d
	ld	a,c
	set	7, a
	ld	-8 (ix),a
	ld	-7 (ix),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:77: l >>= -exp;
	xor	a, a
	sub	a, -6 (ix)
	ld	b,a
	ld	a, #0x00
	sbc	a, -5 (ix)
	push	af
	pop	af
	inc	b
	jr	00112$
00111$:
	sra	-7 (ix)
	rr	-8 (ix)
	rr	-9 (ix)
	rr	-10 (ix)
00112$:
	djnz	00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fs2ulong.c:79: return l;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	e,-8 (ix)
	ld	d,-7 (ix)
00104$:
	ld	sp, ix
	pop	ix
	ret
___fs2ulong_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
