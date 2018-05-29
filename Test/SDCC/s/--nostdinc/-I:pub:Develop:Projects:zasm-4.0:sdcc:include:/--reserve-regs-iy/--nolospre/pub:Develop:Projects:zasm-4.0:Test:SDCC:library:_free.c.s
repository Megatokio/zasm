;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:12:04 2017
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
	ld	e, 5 (ix)
	add	a,#0xFA
	ld	c,a
	ld	a,e
	adc	a,#0xFF
	ld	b,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:67: if ( pthis->prev ) // For the regular header
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,d
	or	a,e
	jr	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:69: prev_header = pthis->prev;
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:70: prev_header->next = pthis->next;
	ld	a,(bc)
	ld	-2 (ix),a
	inc	bc
	ld	a,(bc)
	ld	-1 (ix),a
	dec	bc
	ld	l, e
	ld	h, d
	ld	a,-2 (ix)
	ld	(hl),a
	inc	hl
	ld	a,-1 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:71: if (pthis->next)
	ld	l, c
	ld	h, b
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,b
	or	a,c
	jr	Z,00105$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:73: pthis->next->prev = prev_header;
	ld	l,c
	ld	h,b
	inc	hl
	inc	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	jr	00105$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_free.c:78: pthis->len = 0; //For the first header
	ld	hl,#0x0004
	add	hl,bc
	xor	a, a
	ld	(hl), a
	inc	hl
	ld	(hl), a
00105$:
	pop	af
	jp	PO,00120$
	ei
00120$:
00108$:
	ld	sp, ix
	pop	ix
	ret
_free_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
