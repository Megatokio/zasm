;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:11:27 2017
;--------------------------------------------------------
	.module _strcmp
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _strcmp
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
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:37: int strcmp ( const char * asrc, const char * adst )
;	---------------------------------
; Function strcmp
; ---------------------------------
_strcmp_start::
_strcmp:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:42: const char * src = asrc;
	ld	e,4 (ix)
	ld	d,5 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:43: const char * dst = adst;
	ld	a,6 (ix)
	ld	-2 (ix),a
	ld	a,7 (ix)
	ld	-1 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:45: while( ! (*src - *dst) && *dst)
00102$:
	ld	a,(de)
	ld	c,a
	rla
	sbc	a, a
	ld	b,a
	pop	hl
	push	hl
	ld	a,(hl)
	ld	l,a
	rla
	sbc	a, a
	ld	h,a
	ld	a,c
	sub	a, l
	ld	l,a
	ld	a,b
	sbc	a, h
	or	a,l
	jr	NZ,00104$
	pop	hl
	push	hl
	ld	a,(hl)
	or	a, a
	jr	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:46: ++src, ++dst;
	inc	de
	inc	-2 (ix)
	jr	NZ,00102$
	inc	-1 (ix)
	jr	00102$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:48: return *src - *dst;
	ld	a,(de)
	ld	d,a
	rla
	sbc	a, a
	ld	e,a
	pop	hl
	push	hl
	ld	a,(hl)
	ld	l,a
	rla
	sbc	a, a
	ld	h,a
	ld	a,d
	sub	a, l
	ld	l,a
	ld	a,e
	sbc	a, h
	ld	h,a
	ld	sp, ix
	pop	ix
	ret
_strcmp_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
