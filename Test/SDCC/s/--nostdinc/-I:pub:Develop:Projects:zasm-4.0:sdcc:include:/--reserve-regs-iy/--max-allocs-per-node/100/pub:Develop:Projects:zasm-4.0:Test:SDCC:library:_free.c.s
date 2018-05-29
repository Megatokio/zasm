;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:35 2017
;--------------------------------------------------------
	.module _free
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _free
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:59: void free (void *p)
;	---------------------------------
; Function free
; ---------------------------------
_free_start::
_free:
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:63: if ( p ) //For allocated pointers only!
	ld	a,5 (ix)
	or	a,4 (ix)
	jr	Z,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:80: }
	ld	a,i
	di
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:66: pthis = (MEMHEADER * )((char *)  p - HEADER_SIZE); //to start of header
	ld	a, 4 (ix)
	ld	d, 5 (ix)
	add	a,#0xFA
	ld	l,a
	ld	a,d
	adc	a,#0xFF
	ld	-4 (ix), l
	ld	-3 (ix), a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:67: if ( pthis->prev ) // For the regular header
	pop	bc
	pop	hl
	push	hl
	push	bc
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-2 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-1 (ix), a
	or	a,-2 (ix)
	jr	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:69: prev_header = pthis->prev;
	ld	e,-2 (ix)
	ld	d,-1 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:70: prev_header->next = pthis->next;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	l, e
	ld	h, d
	ld	(hl),c
	inc	hl
	ld	(hl),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:71: if (pthis->next)
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	or	a,h
	jr	Z,00105$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:73: pthis->next->prev = prev_header;
	inc	hl
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jr	00105$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:78: pthis->len = 0; //For the first header
	ld	a,-4 (ix)
	add	a, #0x04
	ld	-2 (ix),a
	ld	a,-3 (ix)
	adc	a, #0x00
	ld	-1 (ix),a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
00105$:
	pop	af
	jp	PO,00123$
	ei
00123$:
00108$:
	ld	sp, ix
	pop	ix
	ret
_free_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
