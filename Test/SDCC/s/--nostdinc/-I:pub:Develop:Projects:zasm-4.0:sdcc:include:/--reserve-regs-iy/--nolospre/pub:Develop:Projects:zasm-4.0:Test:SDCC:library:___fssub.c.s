;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:12:19 2017
;--------------------------------------------------------
	.module ___fssub
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl ___fssub
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fssub.c:55: float __fssub (float a1, float a2)
;	---------------------------------
; Function __fssub
; ---------------------------------
___fssub_start::
___fssub:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fssub.c:57: float neg = -a1;
	ld	a,7 (ix)
	xor	a,#0x80
	ld	b,a
	ld	e,4 (ix)
	ld	d,5 (ix)
	ld	c,6 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/___fssub.c:58: return -(neg + a2);
	ld	l,10 (ix)
	ld	h,11 (ix)
	push	hl
	ld	l,8 (ix)
	ld	h,9 (ix)
	push	hl
	push	bc
	push	de
	call	___fsadd
	pop	af
	pop	af
	pop	af
	pop	af
	ld	b,l
	ld	c,h
	ld	a,d
	xor	a,#0x80
	ld	d,a
	ld	l,b
	ld	h,c
	pop	ix
	ret
___fssub_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
