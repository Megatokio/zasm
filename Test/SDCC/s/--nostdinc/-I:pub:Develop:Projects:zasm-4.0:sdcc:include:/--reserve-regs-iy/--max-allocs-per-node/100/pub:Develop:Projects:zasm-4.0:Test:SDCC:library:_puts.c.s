;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:41 2017
;--------------------------------------------------------
	.module _puts
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _puts
	.globl _putchar
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:31: int puts (char *s)
;	---------------------------------
; Function puts
; ---------------------------------
_puts_start::
_puts:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:34: while (*s){
	ld	c,4 (ix)
	ld	b,5 (ix)
	ld	de,#0x0000
00101$:
	ld	a,(bc)
	ld	l,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:36: i++;
	inc	de
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:34: while (*s){
	ld	a,l
	or	a, a
	jr	Z,00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:35: putchar(*s++);
	ld	h,l
	inc	bc
	push	bc
	push	de
	push	hl
	inc	sp
	call	_putchar
	inc	sp
	pop	de
	pop	bc
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:36: i++;
	jr	00101$
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:38: putchar('\n');
	push	de
	ld	a,#0x0A
	push	af
	inc	sp
	call	_putchar
	inc	sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_puts.c:39: return i+1;
	pop	hl
	pop	ix
	ret
_puts_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
