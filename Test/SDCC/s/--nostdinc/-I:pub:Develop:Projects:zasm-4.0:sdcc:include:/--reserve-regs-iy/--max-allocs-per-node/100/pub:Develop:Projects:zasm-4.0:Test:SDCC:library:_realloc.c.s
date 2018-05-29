;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:41 2017
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
	ld	hl,#-10
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
	ld	d, 5 (ix)
	add	a,#0xFA
	ld	l,a
	ld	a,d
	adc	a,#0xFF
	ld	-6 (ix), l
	ld	-5 (ix), a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:87: prev_memheader = pthis->prev;
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	inc	hl
	inc	hl
	ld	a,(hl)
	ld	-10 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-9 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:89: if (size > (0xFFFF-HEADER_SIZE))
	ld	a,#0xF9
	cp	a, 6 (ix)
	ld	a,#0xFF
	sbc	a, 7 (ix)
	jr	NC,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:91: ret = (void *) NULL; 	// To prevent overflow in next line
	ld	-8 (ix),#0x00
	ld	-7 (ix),#0x00
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
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a,(hl)
	ld	-2 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-1 (ix),a
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	ld	e,-6 (ix)
	ld	d,-5 (ix)
	ld	a,l
	sub	a, e
	ld	e,a
	ld	a,h
	sbc	a, d
	ld	d,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:99: pthis->len = size;
	ld	a,-6 (ix)
	add	a, #0x04
	ld	-4 (ix),a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	-3 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:97: if ((size_t)pthis->next - (size_t)pthis >= size)
	ld	a,e
	sub	a, 6 (ix)
	ld	a,d
	sbc	a, 7 (ix)
	jr	C,00108$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:99: pthis->len = size;
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a,6 (ix)
	ld	(hl),a
	inc	hl
	ld	a,7 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:100: ret = p;
	ld	a,4 (ix)
	ld	-8 (ix),a
	ld	a,5 (ix)
	ld	-7 (ix),a
	jp	00112$
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:104: if (prev_memheader &&
	ld	a,-9 (ix)
	or	a,-10 (ix)
	jp	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:105: (size_t)pthis->next - (size_t)prev_memheader - prev_memheader->len >= size)
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	pop	bc
	pop	de
	push	de
	push	bc
	ld	a,l
	sub	a, e
	ld	c,a
	ld	a,h
	sbc	a, d
	ld	b,a
	pop	de
	pop	hl
	push	hl
	push	de
	ld	de, #0x0004
	add	hl, de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,c
	sub	a, e
	ld	c,a
	ld	a,b
	sbc	a, d
	ld	b,a
	ld	a,c
	sub	a, 6 (ix)
	ld	a,b
	sbc	a, 7 (ix)
	jr	C,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:107: pnew = (MEMHEADER*) ((char*)prev_memheader + prev_memheader->len);
	pop	bc
	pop	hl
	push	hl
	push	bc
	add	hl,de
	ld	c,l
	ld	b,h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:108: prev_memheader->next = pnew;
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	ld	(hl),c
	inc	hl
	ld	(hl),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:110: pthis->next->prev = pnew;
	ld	l,-6 (ix)
	ld	h,-5 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	inc	hl
	inc	hl
	ld	(hl),c
	inc	hl
	ld	(hl),b
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:112: memmove(pnew, pthis, pthis->len);
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a, (hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	e,-6 (ix)
	ld	d,-5 (ix)
	ld	-2 (ix),c
	ld	-1 (ix),b
	push	bc
	push	hl
	push	de
	ld	l,-2 (ix)
	ld	h,-1 (ix)
	push	hl
	call	_memmove
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	bc
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:113: pnew->len = size;
	ld	hl,#0x0004
	add	hl,bc
	ex	de,hl
	ld	a,6 (ix)
	ld	(de),a
	inc	de
	ld	a,7 (ix)
	ld	(de),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:114: ret = MEM(pnew);
	ld	hl,#0x0006
	add	hl,bc
	ld	-8 (ix),l
	ld	-7 (ix),h
	jr	00112$
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:118: ret = malloc(size - HEADER_SIZE);
	ld	a,6 (ix)
	add	a,#0xFA
	ld	e,a
	ld	a,7 (ix)
	adc	a,#0xFF
	ld	d,a
	push	de
	call	_malloc
	pop	af
	ld	-8 (ix), l
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:119: if (ret)
	ld	-7 (ix), h
	ld	a, h
	or	a,-8 (ix)
	jr	Z,00112$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:121: memcpy(ret, MEM(pthis), pthis->len - HEADER_SIZE);
	ld	a,-6 (ix)
	add	a, #0x06
	ld	e,a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	d,a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,c
	add	a,#0xFA
	ld	l,a
	ld	a,b
	adc	a,#0xFF
	ld	h,a
	push	hl
	push	de
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	push	hl
	call	_memcpy
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:122: free(p);
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	_free
	pop	af
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
	ld	-8 (ix), l
	ld	-7 (ix), h
00115$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_realloc.c:132: return ret;
	pop	bc
	pop	hl
	push	hl
	push	bc
	ld	sp, ix
	pop	ix
	ret
_realloc_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
