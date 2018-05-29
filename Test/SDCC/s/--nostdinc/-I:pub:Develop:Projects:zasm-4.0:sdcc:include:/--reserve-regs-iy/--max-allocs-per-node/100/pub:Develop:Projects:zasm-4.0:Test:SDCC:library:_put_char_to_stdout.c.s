;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:13:41 2017
;--------------------------------------------------------
	.module _put_char_to_stdout
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _put_char_to_stdout
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_put_char_to_stdout.c:41: void put_char_to_stdout (char c, void* p) 
;	---------------------------------
; Function put_char_to_stdout
; ---------------------------------
_put_char_to_stdout_start::
_put_char_to_stdout:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_put_char_to_stdout.c:44: putchar (c);
	ld	a,4 (ix)
	push	af
	inc	sp
	call	_putchar
	inc	sp
	pop	ix
	ret
_put_char_to_stdout_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
