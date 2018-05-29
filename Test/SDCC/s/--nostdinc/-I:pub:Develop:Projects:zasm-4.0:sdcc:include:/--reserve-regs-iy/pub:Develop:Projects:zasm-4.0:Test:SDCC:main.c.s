;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Thu Jul  6 13:27:26 2017
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _NMI_Intr
	.globl _Intr
	.globl _strcmp
	.globl _puts
	.globl _printf
	.globl _free
	.globl _realloc
	.globl _malloc
	.globl _a_counter
	.globl _str3
	.globl _f
	.globl _bu2
	.globl _bu1
	.globl _so_many_days_per_month
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_bu1::
	.ds 10
_bu2::
	.ds 10
_f::
	.ds 1
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_str3::
	.ds 10
_a_counter::
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
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:25: void Intr(void) __naked __interrupt 0
;	---------------------------------
; Function Intr
; ---------------------------------
_Intr_start::
_Intr:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:27: __asm__(" exx\n ex af,af'\n");
	exx
	ex af,af'
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:28: a_counter++;
	ld	hl,#_a_counter
	inc	(hl)
	jr	NZ,00103$
	inc	hl
	inc	(hl)
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:29: __asm__(" exx\n ex af,af'\n reti\n");
	exx
	ex af,af'
	reti
_Intr_end::
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:32: void NMI_Intr(void) __critical __interrupt
;	---------------------------------
; Function NMI_Intr
; ---------------------------------
_NMI_Intr_start::
_NMI_Intr:
	push	af
	push	bc
	push	de
	push	hl
	push	iy
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:34: a_counter++;
	ld	hl,#_a_counter
	inc	(hl)
	jr	NZ,00103$
	inc	hl
	inc	(hl)
00103$:
	pop	iy
	pop	hl
	pop	de
	pop	bc
	pop	af
	retn
_NMI_Intr_end::
_so_many_days_per_month:
	.db #0x1F	;  31
	.db #0x1C	;  28
	.db #0x1F	;  31
	.db #0x1E	;  30
	.db #0x1F	;  31
	.db #0x1E	;  30
	.db #0x1F	;  31
	.db #0x1F	;  31
	.db #0x1E	;  30
	.db #0x1F	;  31
	.db #0x1E	;  30
	.db #0x1F	;  31
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:37: void main()
;	---------------------------------
; Function main
; ---------------------------------
_main_start::
_main:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:43: puts("Hello C World!");
	ld	hl,#___str_0
	push	hl
	call	_puts
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:44: puts("Say 'Hi' to Kio");
	ld	hl, #___str_1
	ex	(sp),hl
	call	_puts
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:45: puts("");
	ld	hl, #___str_2
	ex	(sp),hl
	call	_puts
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:47: array = malloc(44);
	ld	hl, #0x002C
	ex	(sp),hl
	call	_malloc
	pop	af
	ex	de,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:48: array = realloc(array,88);
	ld	hl,#0x0058
	push	hl
	push	de
	call	_realloc
	pop	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:49: free(array);
	ex	(sp),hl
	call	_free
	pop	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:51: bu1[0]='A';	// sdcc doesn't genate code which exhibits the character, just the number :-(
	ld	hl,#_bu1
	ld	(hl),#0x41
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:53: if(c==bu1[0]) bu1[1]=c;
	ld	a, (#_bu1 + 0)
	sub	a, #0x61
	jr	NZ,00102$
	inc	hl
	ld	(hl),#0x61
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:60: puts("__STDC_VERSION__ undef (c89)");
	ld	hl,#___str_3
	push	hl
	call	_puts
	pop	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:63: if(strcmp("aa","aa")) printf("");		// --> _strcmp.c
	ld	de,#___str_4+0
	ld	l, e
	ld	h, d
	push	hl
	push	de
	call	_strcmp
	pop	af
	pop	af
	ld	e,l
	ld	a, h
	or	a,e
	jr	Z,00104$
	ld	hl,#___str_2
	push	hl
	call	_printf
	pop	af
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:64: memcpy(bu1,bu2,10);						// --> __builtin_memcpy ((inline))
	ld	de,#_bu2+0
	ld	l, e
	ld	h, d
	push	de
	ld	de,#_bu1
	ld	bc,#0x000A
	ldir
	pop	de
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:65: strcpy(bu2,str3);						// --> __builtin_strcpy ((inline))
	ld	hl,#_str3
	xor	a, a
00125$:
	cp	a, (hl)
	ldi
	jr	NZ, 00125$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:71: printf("__SDCC isdef\n");
	ld	hl,#___str_5
	push	hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:77: printf("__SDCC_z80 isdef\n");
	ld	hl, #___str_6
	ex	(sp),hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:83: printf("__SDCC_STACK_AUTO isdef\n");			// default = defined
	ld	hl, #___str_7
	ex	(sp),hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:91: printf("__SDCC_CHAR_UNSIGNED isndef\n");		// default = signed char
	ld	hl, #___str_8
	ex	(sp),hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:97: printf("__SDCC_ALL_CALLEE_SAVES isndef\n");		// default = undefined
	ld	hl, #___str_9
	ex	(sp),hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:103: printf("__SDCC_FLOAT_REENTRANT ISNDEF\n");		// default = undefined
	ld	hl, #___str_10
	ex	(sp),hl
	call	_printf
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:107: printf("__SDCC_INT_LONG_REENT isdef\n");		// default = defined
	ld	hl, #___str_11
	ex	(sp),hl
	call	_printf
	pop	af
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:127: for(i=0;i<10;i++)
	ld	de,#0x0000
00106$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:129: printf("%i * %i = %i\n", i,i,i*i);
	push	de
	push	de
	push	de
	call	__mulint
	pop	af
	pop	af
	ld	c,l
	ld	b,h
	pop	de
	ld	hl,#___str_12
	push	de
	push	bc
	push	de
	push	de
	push	hl
	call	_printf
	ld	hl,#8
	add	hl,sp
	ld	sp,hl
	pop	de
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/main.c:127: for(i=0;i<10;i++)
	inc	de
	ld	a,e
	sub	a, #0x0A
	ld	a,d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C,00106$
	ret
_main_end::
___str_0:
	.ascii "Hello C World!"
	.db 0x00
___str_1:
	.ascii "Say 'Hi' to Kio"
	.db 0x00
___str_2:
	.db 0x00
___str_3:
	.ascii "__STDC_VERSION__ undef (c89)"
	.db 0x00
___str_4:
	.ascii "aa"
	.db 0x00
___str_5:
	.ascii "__SDCC isdef"
	.db 0x0A
	.db 0x00
___str_6:
	.ascii "__SDCC_z80 isdef"
	.db 0x0A
	.db 0x00
___str_7:
	.ascii "__SDCC_STACK_AUTO isdef"
	.db 0x0A
	.db 0x00
___str_8:
	.ascii "__SDCC_CHAR_UNSIGNED isndef"
	.db 0x0A
	.db 0x00
___str_9:
	.ascii "__SDCC_ALL_CALLEE_SAVES isndef"
	.db 0x0A
	.db 0x00
___str_10:
	.ascii "__SDCC_FLOAT_REENTRANT ISNDEF"
	.db 0x0A
	.db 0x00
___str_11:
	.ascii "__SDCC_INT_LONG_REENT isdef"
	.db 0x0A
	.db 0x00
___str_12:
	.ascii "%i * %i = %i"
	.db 0x0A
	.db 0x00
	.area _CODE
___str_13:
	.ascii "123456789"
	.db 0x00
	.area _INITIALIZER
__xinit__str3:
	.ascii "123456789"
	.db 0x00
__xinit__a_counter:
	.dw #0x0000
	.area _CABS (ABS)
