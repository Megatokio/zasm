#!/usr/local/bin/zasm -o original/
	.title	'Preliminary Z80 tests'

; prelim.z80 - Preliminary Z80 tests
; Copyright (C) 1994  Frank D. Cringle
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


; These tests have two goals.  To start with, we assume the worst and
; successively test the instructions needed to continue testing.
; Then we try to test all instructions which cannot be handled by
; zexlax - the crc-based instruction exerciser.

; Initially errors are 'reported' by jumping to 0.  This should reboot
; cp/m, so if the program terminates without any output one of the
; early tests failed.  Later errors are reported by outputting an
; address via the bdos conout routine.  The address can be located in
; a listing of this program.

; If the program runs to completion it displays a suitable message.

	aseg
	org	100h

start:	ld	a,1		; test simple compares and z/nz jumps
	cp	2
	jp	z,0
	cp	1
	jp	nz,0
	jp	lab0
	halt			; emergency exit
	db	0ffh
	
lab0:	call	lab2		; does a simple call work?
lab1:	jp	0		; fail
	
lab2:	pop	hl		; check return address
	ld	a,h
	cp	hi(lab1)
	jp	z,lab3
	jp	0
lab3:	ld	a,l
	cp	lo(lab1)
	jp	z,lab4
	jp	0

; test presence and uniqueness of all machine registers
; (except ir)
lab4:	ld	sp,regs1
	pop	af
	pop	bc
	pop	de
	pop	hl
	ex	af,af'
	exx
	pop	af
	pop	bc
	pop	de
	pop	hl
	pop	ix
	pop	iy
	ld	sp,regs2+20
	push	iy
	push	ix
	push	hl
	push	de
	push	bc
	push	af
	ex	af,af'
	exx
	push	hl
	push	de
	push	bc
	push	af

v:	set	0
	rept	20
	ld	a,(regs2+v/2)
v:	set	v+2
	cp	v
	jp	nz,0
	endm

; test access to memory via (hl)
	ld	hl,hlval
	ld	a,(hl)
	cp	0a5h
	jp	nz,0
	ld	hl,hlval+1
	ld	a,(hl)
	cp	03ch
	jp	nz,0

; test unconditional return
	ld	sp,stack
	ld	hl,reta
	push	hl
	ret
	jp	0

; test instructions needed for hex output
reta:	ld	a,255
	and	a,15
	cp	15
	jp	nz,0
	ld	a,05ah
	and	15
	cp	00ah
	jp	nz,0
	rrca
	cp	005h
	jp	nz,0
	rrca
	cp	082h
	jp	nz,0
	rrca
	cp	041h
	jp	nz,0
	rrca
	cp	0a0h
	jp	nz,0
	ld	hl,01234h
	push	hl
	pop	bc
	ld	a,b
	cp	012h
	jp	nz,0
	ld	a,c
	cp	034h
	jp	nz,0
	
; from now on we can report errors by displaying an address

; test conditional call, ret, jp, jr
tcond:	macro	flag,pcond,ncond,rel
	ld	hl,&flag
	push	hl
	pop	af
	call	&pcond,lab1&pcond
	jp	error
lab1&pcond:	pop	hl
	ld	hl,0d7h xor &flag
	push	hl
	pop	af
	call	&ncond,lab2&pcond
	jp	error
lab2&pcond:	pop	hl
	ld	hl,lab3&pcond
	push	hl
	ld	hl,&flag
	push	hl
	pop	af
	ret	&pcond
	call	error
lab3&pcond:	ld	hl,lab4&pcond
	push	hl
	ld	hl,0d7h xor &flag
	push	hl
	pop	af
	ret	&ncond
	call	error
lab4&pcond:	ld	hl,&flag
	push	hl
	pop	af
	jp	&pcond,lab5&pcond
	call	error
lab5&pcond:	ld	hl,0d7h xor &flag
	push	hl
	pop	af
	jp	&ncond,lab6&pcond
	call	error
lab6&pcond:	
      if	&rel
	ld	hl,&flag
	push	hl
	pop	af
	jr	&pcond,lab7&pcond
	call	error
lab7&pcond:	ld	hl,0d7h xor &flag
	push	hl
	pop	af
	jr	&ncond,lab8&pcond
	call	error
lab8&pcond:
      endif
	endm

	tcond	1,c,nc,1
	tcond	4,pe,po,0
	tcond	040h,z,nz,1
	tcond	080h,m,p,0

; test indirect jumps
	ld	hl,lab5
	jp	(hl)
	call	error
lab5:	ld	hl,lab6
	push	hl
	pop	ix
	jp	(ix)
	call	error
lab6:	ld	hl,lab7
	push	hl
	pop	iy
	jp	(iy)
	call	error

; djnz (and (partially) inc a, inc hl)
lab7:	ld	a,0a5h
	ld	b,4
lab8:	rrca
	djnz	lab8
	cp	05ah
	call	nz,error
	ld	b,16
lab9:	inc	a
	djnz	lab9
	cp	06ah
	call	nz,error
	ld	b,0
	ld	hl,0
lab10:	inc	hl
	djnz	lab10
	ld	a,h
	cp	1
	call	nz,error
	ld	a,l
	cp	0
	call	nz,error
	
; relative addressing
reladr:	macro	r
	ld	&r,hlval
	ld	a,(&r)
	cp	0a5h
	call	nz,error
	ld	a,(&r+1)
	cp	03ch
	call	nz,error
	inc	&r
	ld	a,(&r-1)
	cp	0a5h
	call	nz,error
	ld	&r,hlval-126
	ld	a,(&r+127)
	cp	03ch
	call	nz,error
	ld	&r,hlval+128
	ld	a,(&r-128)
	cp	0a5h
	call	nz,error
	endm

	reladr	ix
	reladr	iy
	
allok:	ld	de,okmsg
	ld	c,9
	call	5
	jp	0

okmsg:	db	'Preliminary tests complete$'

	
; display address at top of stack and exit
error:	pop	bc
	ld	h,hi(hextab)
	ld	a,b
	rrca
	rrca
	rrca
	rrca
	and	15
	ld	l,a
	ld	a,(hl)
	call	conout
	ld	a,b
	and	15
	ld	l,a
	ld	a,(hl)
	call	conout
	ld	a,c
	rrca
	rrca
	rrca
	rrca
	and	15
	ld	l,a
	ld	a,(hl)
	call	conout
	ld	a,c
	and	15
	ld	l,a
	ld	a,(hl)
	call	conout
	ld	a,13
	call	conout
	ld	a,10
	call	conout
	jp	0

conout:	push	af
	push	bc
	push	de
	push	hl
	ld	c,2
	ld	e,a
	call	5
	pop	hl
	pop	de
	pop	bc
	pop	af
	ret
	
v:	set	0
regs1:	rept	20
v:	set	v+2
	db	v
	endm

regs2:	ds	20,0

hlval:	db	0a5h,03ch

; skip to next page boundary
	org	(($+255)/256)*256
hextab:	db	'0123456789abcdef'
	ds	240
stack:	equ	$

	end
