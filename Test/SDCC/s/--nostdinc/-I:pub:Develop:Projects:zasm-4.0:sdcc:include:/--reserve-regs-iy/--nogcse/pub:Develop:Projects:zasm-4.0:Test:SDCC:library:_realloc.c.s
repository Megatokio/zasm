;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:07:39 2017
;--------------------------------------------------------
	.module _realloc
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _memmove
	.globl _free
	.globl _malloc
	.globl _realloc
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:75: void * realloc (void * p, size_t size)
;	---------------------------------
; Function realloc
; ---------------------------------
_realloc_start::
_realloc:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-8
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:82: if(p) 
	ld	a,5 (ix)
	or	a,4 (ix)
	jp	Z,00114$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:127: }
	ld	a,i
	di
	push	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:86: pthis = (MEMHEADER*) ((char*)p - HEADER_SIZE); 	// calc start of header
	ld	a, 4 (ix)
	ld	e, 5 (ix)
	add	a,#0xFA
	ld	c,a
	ld	a,e
	adc	a,#0xFF
	ld	b,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:87: prev_memheader = pthis->prev;
	ld	l, c
	ld	h, b
	inc	hl
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:89: if (size > (0xFFFF-HEADER_SIZE))
	ld	a,#0xF9
	cp	a, 6 (ix)
	ld	a,#0xFF
	sbc	a, 7 (ix)
	jr	NC,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:91: ret = (void *) NULL; 	// To prevent overflow in next line
	ld	de,#0x0000
	jp	00112$
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:95: size += HEADER_SIZE; 	// We need memory for header too
	ld	a,6 (ix)
	add	a, #0x06
	ld	6 (ix),a
	ld	a,7 (ix)
	adc	a, #0x00
	ld	7 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:97: if ((size_t)pthis->next - (size_t)pthis >= size)
	ld	l, c
	ld	h, b
	ld	a, (hl)
	inc	hl
	ld	l,(hl)
	ld	-2 (ix), a
	ld	-1 (ix),l
	ld	h,c
	ld	l,b
	ld	a,-2 (ix)
	sub	a, h
	ld	-4 (ix),a
	ld	a,-1 (ix)
	sbc	a, l
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:99: pthis->len = size;
	ld	hl,#0x0004
	add	hl,bc
	ld	-6 (ix),l
	ld	-5 (ix),h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:97: if ((size_t)pthis->next - (size_t)pthis >= size)
	ld	a,-4 (ix)
	sub	a, 6 (ix)
	ld	a,-3 (ix)
	sbc	a, 7 (ix)
	jr	C,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:99: pthis->len = size;
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a,6 (ix)
	ld	(hl),a
	inc	hl
	ld	a,7 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:100: ret = p;
	ld	e,4 (ix)
	ld	d,5 (ix)
	jp	00112$
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:104: if (prev_memheader &&
	ld	a,d
	or	a,e
	jp	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:105: (size_t)pthis->next - (size_t)prev_memheader - prev_memheader->len >= size)
	ld	h,e
	ld	l,d
	ld	a,-2 (ix)
	sub	a, h
	ld	-4 (ix),a
	ld	a,-1 (ix)
	sbc	a, l
	ld	-3 (ix),a
	ld	l, e
	ld	h, d
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-2 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-1 (ix),a
	ld	a,-4 (ix)
	sub	a, -2 (ix)
	ld	-4 (ix),a
	ld	a,-3 (ix)
	sbc	a, -1 (ix)
	ld	-3 (ix),a
	ld	a,-4 (ix)
	sub	a, 6 (ix)
	ld	a,-3 (ix)
	sbc	a, 7 (ix)
	jr	C,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:107: pnew = (MEMHEADER*) ((char*)prev_memheader + prev_memheader->len);
	ld	h,e
	ld	l,d
	ld	a,h
	add	a, -2 (ix)
	ld	h,a
	ld	a,l
	adc	a, -1 (ix)
	ld	-8 (ix), h
	ld	-7 (ix), a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:108: prev_memheader->next = pnew;
	ld	a,-8 (ix)
	ld	(de),a
	inc	de
	ld	a,-7 (ix)
	ld	(de),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:110: pthis->next->prev = pnew;
	ld	l, c
	ld	h, b
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
	inc	hl
	inc	hl
	ld	a,-8 (ix)
	ld	(hl),a
	inc	hl
	ld	a,-7 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:112: memmove(pnew, pthis, pthis->len);
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	de
	push	bc
	push	hl
	call	_memmove
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:113: pnew->len = size;
	ld	a,-8 (ix)
	add	a, #0x04
	ld	e,a
	ld	a,-7 (ix)
	adc	a, #0x00
	ld	d,a
	ld	a,6 (ix)
	ld	(de),a
	inc	de
	ld	a,7 (ix)
	ld	(de),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:114: ret = MEM(pnew);
	ld	a,-8 (ix)
	add	a, #0x06
	ld	e,a
	ld	a,-7 (ix)
	adc	a, #0x00
	ld	d,a
	jr	00112$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:118: ret = malloc(size - HEADER_SIZE);
	ld	a,6 (ix)
	add	a,#0xFA
	ld	e,a
	ld	a,7 (ix)
	adc	a,#0xFF
	ld	d,a
	push	bc
	push	de
	call	_malloc
	pop	af
	ex	de,hl
	pop	bc
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:119: if (ret)
	ld	a,d
	or	a,e
	jr	Z,00112$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:121: memcpy(ret, MEM(pthis), pthis->len - HEADER_SIZE);
	ld	hl,#0x0006
	add	hl,bc
	ld	c, l
	ld	b, h
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	add	a,#0xFA
	ld	l,a
	ld	a,h
	adc	a,#0xFF
	ld	h,a
	push	de
	push	hl
	push	bc
	push	de
	call	_memcpy
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	_free
	pop	af
	pop	de
00112$:
	pop	af
	jp	PO,00115$
	ei
	jr	00115$
00114$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:130: ret = malloc(size);
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	call	_malloc
	pop	af
	ex	de,hl
00115$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:132: return ret;
	ex	de,hl
	ld	sp, ix
	pop	ix
	ret
_realloc_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
