#!/usr/local/bin/zasm --asm8080 -o original/

.org 0



.macro MACRO1
	.dm "Test1",0
.endm

MACRO2 .macro
.dm "Test2",0
.endm

MACRO3 .macro
.dm "Test3",0
.endm

Macro4 .macro
	.dm "Test4",0
.endm

Macro5 Macro
	dm "Test5",0
	endm

	.macro test6
	.dm "Test6",0
	.endm

	macro Test7
	dm "Test7",0
	endm

.align 16
	MACRO1
	macro1

.align 16
	MACRO2
	Macro2

.align 16
	MACRO3
	macro3

.align 16
	MACRO4
	macro4

.align 16
	MACRO5
	macro5

.align 16
	TEST6
	test6

.align 16
	TEST7
	Test7

; -----------------------------------

.align 16
.rept 2
.dm "Rept2"
.db 0
.endm

.align 16
	.rept 3
	.dm "Rept3"
	.db 0
	.endm

.align 16
	rept 4
	.dm "Rept4"
	.db 0
	endm

.align 16
	dm "Rept8:",0
v   defl    0
	rept    8
	lda     regs2 + v/2
v   defl    v+2
	cpi     v
	jnz     0
	endm
regs2:
	.db "regs2",0

; -------------------------------------

	macro TEST8 %A
	db	%a, %a
	endm

.align 16
	test8 '8'
	test8 '8'

counter defl 0
COUNT	.macro
counter defl counter + 1
		.endm

	count
	count
	count
	count
#assert counter == 4

test9: macro A,B
	db &a,&b,0
	db &a,&b,0
	endm

.align 16
	test9 'a','b'
	test9 'c','d'

.macro test10 A, B, C, D
	db \A,\B,0
	db \D,\C,0
.endm

.align 16
	test10 '1','3','5','7'

test11: macro &A,&b
	db &a,&B,0
	db &a,&B,0
	endm

.align 16
	test11 'A','a'
	test11 'B','b'


test12: macro #aa, #BB, #Cc
	dw #aa
	dw #bb
	dw #CC, 0
	endm

.align 16
	test12 $1234, 0x3456, 5678h

; -----------------------

.macro foo1 %a, %b, %c
	.db %a,%b,%c,0
.endm

.align 16
	foo1 1,2,3
	foo1 ',', ';', '"'
	foo1 <'>, <X>, <'>
	foo1 <">, <XYZ",'$',"ABC>, <">

.macro foo2 %a
	%a
.endm

.align 16
	foo2 <.db "foo2",0>
	foo2 <.db "foo2",0>


.ALIGN 16
	DB "--- ende ---",0

.end













