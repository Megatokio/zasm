#!/usr/local/bin/zasm -c ../../sdcc/bin/sdcc -o original/
; ================================================================
;	Example rom with c code for a Z80 system
;	Copyright  (c)	Günter Woigk 1994 - 2015
;					mailto:kio@little-bat.de
; ================================================================

#target rom

_rom_start::		equ	0
_rom_end::			equ	0x4000
_ram_start::		equ	0x4000
_ram_end::			equ	0x10000
_min_heap_size::	equ	0x1000


; ================================================================
; Define ordering of code segments in ram:
; these segments produce code in the output file!
; ================================================================

#code 	_HEADER,_rom_start
#code 	_GSINIT				; init code: the compiler adds some code here and there as required
#code 	_HOME				; code that must not be put in a bank switched part of memory.
#code 	_CODE				; most code and const data go here
#code 	_CABS,*,0			; referenced but never (?) actually used by sdcc
#code 	_GSFINAL,*,0		; referenced but never (?) actually used by sdcc
#code 	_INITIALIZER		; initializer for initialized data in ram
#code	_ROM_PADDING		; pad rom file up to rom end
		defs  _rom_end-$$


; ================================================================
; Define variables in ram:
; note: data segments do not produce actual code
; ================================================================

#data 	_DATA, _ram_start	; uninitialized data
#data 	_INITIALIZED		; data initialized from _INITIALIZER
#data	_DABS,*,0			; referenced but never (?) actually used by sdcc
#data	_RSEG,*,0			; referenced but never (?) actually used by kcc

#data 	_HEAP				; heap:
__sdcc_heap_start:	 		; --> sdcc _malloc.c
		ds	_min_heap_size	; minimum required size
		ds	_ram_end-$-1		; add all unused memory to the heap
__sdcc_heap_end: 			; --> sdcc _malloc.c
		ds 	1


; ================================================================
; 	_HEADER segment:
; 	starts at 0x0000
; ================================================================

;	reset vector
;	RST vectors
;	INT vector (IM 1)
;	NMI vector

#CODE _HEADER

; reset vector
RST0::	di
		ld		sp,_ram_end & 0xffff
		jp		init
		defs	0x08-$

RST1::	reti
		defs	0x10-$

RST2::	reti
		defs	0x18-$

RST3::	reti
		defs	0x20-$

RST4::	reti
		defs	0x28-$

RST5::	reti
		defs	0x30-$

RST6::	reti
		defs	0x38-$

; maskable interrupt handler in interrupt mode 1:
RST7::	RETI						; add INT handler here


; init:
; globals and statics initialization
; starts with copying the fixed data:

init:	ld	bc,_INITIALIZER_len		; length of segment _INITIALIZER
		ld	de,_INITIALIZED			; start of segment _INITIALIZED
		ld	hl,_INITIALIZER			; start of segment _INITIALIZER
		ld	a,b
		or	c
		jr	z,$+4
		ldir

		call    _GSINIT				; Initialise global variables
		call	_main				; execute main()

; shut down:
; if main() returns then something went wrong.
; call debugger and on exit restart system.

_exit::	di
		call 	NMI
		rst		0

; non maskable interrupt:
; e.g. call debugger and on exit resume.

		defs   	0x66-$
NMI::	RETN						; add NMI handler here


; ================================================================
; the payload:
; ================================================================


#CFLAGS  $CFLAGS --nostdinc -I../../sdcc/include	; add some flags for sdcc
#INCLUDE "main.c"									; compile & include file "main.c"
#INCLUDE LIBRARY "../../sdcc/lib/"					; resolve missing global labels

#if !defined(__mulint)	; fix for old sdcc 3.4.x:
				defs	0,__mulint		; make __mulint missing
__mulint_rrx_s	equ 	__mulint		; define what we need to be what we have
#INCLUDE LIBRARY "../../sdcc/lib/"					; resolve missing global labels
#endif


; ================================================================
; calculate some last labels:
; ================================================================

#CODE _GSINIT

		ret							; final ret from initialization code


#CODE _INITIALIZER

_INITIALIZER_len = $ - _INITIALIZER	; calc size of initializer data for ldir in init code














