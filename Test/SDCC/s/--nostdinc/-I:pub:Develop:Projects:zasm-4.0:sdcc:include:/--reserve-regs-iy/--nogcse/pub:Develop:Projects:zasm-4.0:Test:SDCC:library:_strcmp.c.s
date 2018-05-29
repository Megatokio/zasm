;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:07:39 2017
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
	dec	sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:42: const char * src = asrc;
	ld	c,4 (ix)
	ld	b,5 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:43: const char * dst = adst;
	ld	e,6 (ix)
	ld	d,7 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:45: while( ! (*src - *dst) && *dst)
00102$:
	ld	a,(bc)
	ld	-2 (ix),a
	rla
	sbc	a, a
	ld	-1 (ix),a
	ld	a,(de)
	ld	-3 (ix), a
	ld	l, a
	ld	a,-3 (ix)
	rla
	sbc	a, a
	ld	h,a
	ld	a,-2 (ix)
	sub	a, l
	ld	l,a
	ld	a,-1 (ix)
	sbc	a, h
	ld	h,a
	or	a,l
	jr	NZ,00104$
	ld	a,-3 (ix)
	or	a, a
	jr	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:46: ++src, ++dst;
	inc	bc
	inc	de
	jr	00102$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_strcmp.c:48: return *src - *dst;
	ld	sp, ix
	pop	ix
	ret
_strcmp_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
