;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:27 2017
;--------------------------------------------------------
	.module _printf
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _put_char_to_stdout
	.globl __print_format
	.globl _printf
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_printf.c:43: int printf (const char *format, ...)
;	---------------------------------
; Function printf
; ---------------------------------
_printf_start::
_printf:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_printf.c:48: va_start (arg, format);
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_printf.c:49: i = _print_format (put_char_to_stdout, NULL, format, arg);
	ld	hl,#0x0004+1+1
	add	hl,sp
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	hl,#_put_char_to_stdout
	push	hl
	call	__print_format
	pop	af
	pop	af
	pop	af
	pop	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/_printf.c:52: return i;
	pop	ix
	ret
_printf_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
