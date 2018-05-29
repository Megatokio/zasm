;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:12:19 2017
;--------------------------------------------------------
	.module __divulong
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl __divulong
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:41: unsigned long _divulong (unsigned long x, unsigned long y)
;	---------------------------------
; Function _divulong
; ---------------------------------
__divulong_start::
__divulong:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:43: unsigned long reste = 0L;
	ld	bc,#0x0000
	ld	de,#0x0000
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:44: unsigned char count = 32;
	ld	-1 (ix),#0x20
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:47: do
00105$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:50: c = MSB_SET(x);
	ld	a,7 (ix)
	rlc	a
	and	a,#0x01
	ld	-2 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:51: x <<= 1;
	push	af
	pop	af
	sla	4 (ix)
	rl	5 (ix)
	rl	6 (ix)
	rl	7 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:52: reste <<= 1;
	sla	b
	rl	c
	rl	e
	rl	d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:53: if (c)
	ld	a,-2 (ix)
	or	a, a
	jr	Z,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:54: reste |= 1L;
	set	0, b
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:56: if (reste >= y)
	ld	a,b
	sub	a, 8 (ix)
	ld	a,c
	sbc	a, 9 (ix)
	ld	a,e
	sbc	a, 10 (ix)
	ld	a,d
	sbc	a, 11 (ix)
	jr	C,00106$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:58: reste -= y;
	ld	a,b
	sub	a, 8 (ix)
	ld	b,a
	ld	a,c
	sbc	a, 9 (ix)
	ld	c,a
	ld	a,e
	sbc	a, 10 (ix)
	ld	e,a
	ld	a,d
	sbc	a, 11 (ix)
	ld	d,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:60: x |= 1L;
	set	0, 4 (ix)
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:63: while (--count);
	ld	a,-1 (ix)
	add	a,#0xFF
	ld	-1 (ix),a
	or	a, a
	jr	NZ,00105$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__divulong.c:64: return x;
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	ld	sp, ix
	pop	ix
	ret
__divulong_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
