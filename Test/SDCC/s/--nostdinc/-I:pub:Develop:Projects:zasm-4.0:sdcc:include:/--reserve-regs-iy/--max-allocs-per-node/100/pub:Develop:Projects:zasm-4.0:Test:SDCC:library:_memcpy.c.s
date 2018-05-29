;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:41 2017
;--------------------------------------------------------
	.module _memcpy
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _memcpy
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:40: void * memcpy (void * dst, const void * src, size_t acount)
;	---------------------------------
; Function memcpy
; ---------------------------------
_memcpy_start::
_memcpy:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:42: void * ret = dst;
	ld	c,4 (ix)
	ld	b,5 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:43: char * d = dst;
	ld	e,4 (ix)
	ld	d,5 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:44: const char * s = src;
	ld	a,6 (ix)
	ld	-4 (ix),a
	ld	a,7 (ix)
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:47: while (acount--) 
	ld	a,8 (ix)
	ld	-2 (ix),a
	ld	a,9 (ix)
	ld	-1 (ix),a
00101$:
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	a,-2 (ix)
	add	a,#0xFF
	ld	-2 (ix),a
	ld	a,-1 (ix)
	adc	a,#0xFF
	ld	-1 (ix),a
	ld	a,h
	or	a,l
	jr	Z,00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:49: *d++ = *s++;
	pop	hl
	push	hl
	ld	a,(hl)
	inc	-4 (ix)
	jr	NZ,00115$
	inc	-3 (ix)
00115$:
	ld	(de),a
	inc	de
	jr	00101$
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:52: return ret;
	ld	l, c
	ld	h, b
	ld	sp, ix
	pop	ix
	ret
_memcpy_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
