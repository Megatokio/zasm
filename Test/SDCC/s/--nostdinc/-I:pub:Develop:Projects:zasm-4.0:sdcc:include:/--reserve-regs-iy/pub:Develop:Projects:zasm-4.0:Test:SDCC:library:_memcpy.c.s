;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:45 2017
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
	ld	a,4 (ix)
	ld	-4 (ix),a
	ld	a,5 (ix)
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:43: char * d = dst;
	ld	a,4 (ix)
	ld	-2 (ix),a
	ld	a,5 (ix)
	ld	-1 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:44: const char * s = src;
	ld	e,6 (ix)
	ld	d,7 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:47: while (acount--) 
	ld	c,8 (ix)
	ld	b,9 (ix)
00101$:
	ld	h,c
	ld	l,b
	dec	bc
	ld	a,l
	or	a,h
	jr	Z,00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:49: *d++ = *s++;
	ld	a,(de)
	inc	de
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	(hl),a
	inc	-2 (ix)
	jr	NZ,00101$
	inc	-1 (ix)
	jr	00101$
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_memcpy.c:52: return ret;
	pop	hl
	push	hl
	ld	sp, ix
	pop	ix
	ret
_memcpy_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
