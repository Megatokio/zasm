;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.8.0 #10562 (Linux)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _l
	.globl _u
	.globl _n
	.globl _d
	.globl _c
	.globl _z
	.globl _s
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_c::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_d::
	.ds 2
_n::
	.ds 2
_u::
	.ds 2
_l::
	.ds 2
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
;/home/kio/pub/Develop/Projects/zasm/Test/ZXSP/main.c:9: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main::
;/home/kio/pub/Develop/Projects/zasm/Test/ZXSP/main.c:16: c=a*b + (c+1)*c;
	ld	bc, (_c)
	inc	bc
	ld	hl, (_c)
	push	hl
	push	bc
	call	__mulint
	pop	af
	pop	af
	ld	c, l
	ld	b, h
	ld	hl, #0x4e20
	add	hl, bc
	ld	(_c), hl
;/home/kio/pub/Develop/Projects/zasm/Test/ZXSP/main.c:17: }
	ret
_s:
	.dw __str_0
_z:
	.dw #0x029a
__str_0:
	.ascii "ABCDE"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
__xinit__d:
	.dw #0x007b
__xinit__n:
	.dw #0x0000
__xinit__u:
	.dw #0x0000
__xinit__l:
	.dw #0x0000
	.area _CABS (ABS)
