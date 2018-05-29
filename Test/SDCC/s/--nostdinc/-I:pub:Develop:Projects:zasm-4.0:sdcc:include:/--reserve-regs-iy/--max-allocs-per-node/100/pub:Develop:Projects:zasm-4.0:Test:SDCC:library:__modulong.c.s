;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:41 2017
;--------------------------------------------------------
	.module __modulong
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl __modulong
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:36: unsigned long _modulong (unsigned long a, unsigned long b)
;	---------------------------------
; Function _modulong
; ---------------------------------
__modulong_start::
__modulong:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:38: unsigned char count = 0;
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:40: while (!MSB_SET(b))
	ld	de,#0x0000
00103$:
	ld	a,11 (ix)
	rlc	a
	and	a,#0x01
	jr	NZ,00117$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:42: b <<= 1;
	push	af
	pop	af
	sla	8 (ix)
	rl	9 (ix)
	rl	10 (ix)
	rl	11 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:43: if (b > a)
	ld	a,4 (ix)
	sub	a, 8 (ix)
	ld	a,5 (ix)
	sbc	a, 9 (ix)
	ld	a,6 (ix)
	sbc	a, 10 (ix)
	ld	a,7 (ix)
	sbc	a, 11 (ix)
	jr	NC,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:45: b >>=1;
	push	af
	pop	af
	srl	11 (ix)
	rr	10 (ix)
	rr	9 (ix)
	rr	8 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:46: break;
	jr	00117$
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:48: count++;
	inc	e
	ld	d,e
	jr	00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:51: do
00117$:
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:53: if (a >= b)
	ld	a,4 (ix)
	sub	a, 8 (ix)
	ld	a,5 (ix)
	sbc	a, 9 (ix)
	ld	a,6 (ix)
	sbc	a, 10 (ix)
	ld	a,7 (ix)
	sbc	a, 11 (ix)
	jr	C,00107$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:54: a -= b;
	ld	a,4 (ix)
	sub	a, 8 (ix)
	ld	4 (ix),a
	ld	a,5 (ix)
	sbc	a, 9 (ix)
	ld	5 (ix),a
	ld	a,6 (ix)
	sbc	a, 10 (ix)
	ld	6 (ix),a
	ld	a,7 (ix)
	sbc	a, 11 (ix)
	ld	7 (ix),a
00107$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:55: b >>= 1;
	push	af
	pop	af
	srl	11 (ix)
	rr	10 (ix)
	rr	9 (ix)
	rr	8 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:57: while (count--);
	ld	h,d
	dec	d
	ld	a,h
	or	a, a
	jr	NZ,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__modulong.c:59: return a;
	ld	l,4 (ix)
	ld	h,5 (ix)
	ld	e,6 (ix)
	ld	d,7 (ix)
	pop	ix
	ret
__modulong_end::
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
