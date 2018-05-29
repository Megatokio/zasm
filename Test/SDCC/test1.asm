;
;			Example C project for use with zasm
; 			(c) 2014 - 2017	kio@little-bat.de
;
; NOTE:
; this file is not included in the zasm self test
; because SDCC generates different code every time.
;


; declare target:
;
#target rom


; setup SDCC:
;
#cpath "sdcc"
#cflags $CFLAGS --nostdinc -Iinclude --reserve-regs-iy


; define rom and ram size and address:
;
_rom_start::		equ	0
_rom_end::			equ	0x4000
_ram_start::		equ	0x4000
_ram_end::			equ	0x10000
_min_heap_size::	equ	0x1000	; for malloc


; ________________________________________________________________
; Define order of code segments in rom:
; these segments produce code in the output file!
;
#code 	_HEADER, _rom_start		; RST vectors et.al.
#code 	_HOME					; code that must not be put in a bank switched part of memory.
#code 	_CODE					; most code and const data go here
#code 	_GSINIT					; init code: the compiler adds some code here and there as required
								; note: the final ret from _GSINIT is at the end of this file.
#code 	_INITIALIZER			; initializer for initialized data in ram
#code	_ROM_PADDING
		defs	_rom_end-$		; pad rom file up to rom end


; ________________________________________________________________
; Define order of data segments in ram:
; these segments define addresses: no code is stored in the output file!
;
#data 	_DATA, _ram_start		; uninitialized data
#data 	_INITIALIZED			; initialized with data from code segment _INITIALIZER

#data 	_HEAP					; heap
__sdcc_heap_start:: 			; --> sdcc _malloc.c
		ds	_min_heap_size		; minimum required size for malloc/free
		ds	_ram_end-$-1		; add all unused memory to the heap
__sdcc_heap_end:: 				; --> sdcc _malloc.c
		ds 	1


; ________________________________________________________________
; Declare segments which are referenced by sdcc
; but never (?) used:
;
#data	_DABS,*,0				; used by sdcc: .area _DABS (ABS): absolute external ram data?
#code 	_CABS,*,0				; used by sdcc: .area _CABS (ABS): ?
#code 	_GSFINAL,*,0			; used by sdcc: .area _GSFINAL: ?
#data	_RSEG,*,0				; used by kcc:  .area _RSEG (ABS)



; ================================================================
; 	Actual Code
; 	Rom starts at 0x0000
; ================================================================


;	reset vector
;	RST vectors
;	INT vector (IM 1)
;	NMI vector
;
#code _HEADER

; RST 0: reset 
	di
	ld		sp,0x0000	; Set stack pointer directly above top of memory.
	jp		_GSINIT		; Initialize global variables, call main() and exit

; RST 1: 
	org 8
	reti

; RST 2:
	org 16
	reti

; RST 3:
	org 24
	reti

; RST 4:
	org 32
	reti

; RST 5:
	org 40
	reti

; RST 6:
	org 48
	reti

; ________________________________________________________________
; RST 7: maskable interrupt handler in IM 1:
	org 56
	reti

; ________________________________________________________________
; non-maskable interrupt handler:
; must return with RETN

	org	0x66
	rst	0
	;retn

; ________________________________________________________________
; globals and statics initialization
; copy flat initializer data: 
;
#code _GSINIT
		ld	bc,_INITIALIZER_len	; length of segment _INITIALIZER
		ld	a,b
		or	c
		jr	z,1$+2
		ld	de,_INITIALIZED		; start of segment _INITIALIZED
		ld	hl,_INITIALIZER		; start of segment _INITIALIZER
1$:		ldir

; ________________________________________________________________
; putchar()
; target system dependent:
;
#code _CODE
_putchar::
        ld      hl,2
        add     hl,sp
        ld      l,(hl)
        ld      a,1
        rst     8				; whatever
        ret

; ________________________________________________________________
; SDCC does not generate a .globl statement for these labels:
; they must be declared before they are used,
; else they are not marked 'used' and #include library won't load them
;
	.globl	__mulint
	.globl	__divsint
	.globl	__divuint
	.globl	__modsint
	.globl	__moduint
	.globl	__muluchar
	.globl	__mulschar
	.globl	__divuchar
	.globl	__divschar
	.globl	__mullong
	.globl	__divulong
	.globl	__divslong
	.globl	__rrulong
	.globl	__rrslong
	.globl	__rlulong
	.globl	__rlslong

; ________________________________________________________________
; The Program:
;
#include "main.c"				
#include "rem.c"				
#include library "library"		; resolved missing labels from library

; ________________________________________________________________
; calculate length of initializer data:
;
#code _INITIALIZER
_INITIALIZER_len:: equ $ - _INITIALIZER

; ________________________________________________________________
; start system
; after all initialization in _GSINIT is done
;
#code 	_GSINIT
		call	_main		; execute main()
_exit::	di					; system shut down
		halt				; may resume after NMI
		rst		0			; then reboot


#end










