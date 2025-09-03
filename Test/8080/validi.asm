#!/usr/local/bin/zasm --asm8080 -o original/

;	This file is the validation sweep for the 8080 assembler

	org	3000h

byte:	equ	0fdh		;Byte for byte op-codes

begin:

;	Move Group

	mov	b,b
	mov	b,c
	mov	b,d
	mov	b,e
	mov	b,h
	mov	b,l
	mov	b,m
	mov	b,a

	mov	c,b
	mov	c,c
	mov	c,d
	mov	c,e
	mov	c,h
	mov	c,l
	mov	c,m
	mov	c,a

	mov	d,b
	mov	d,c
	mov	d,d
	mov	d,e
	mov	d,h
	mov	d,l
	mov	d,m
	mov	d,a

	mov	e,b
	mov	e,c
	mov	e,d
	mov	e,e
	mov	e,h
	mov	e,l
	mov	e,m
	mov	e,a

	mov	h,b
	mov	h,c
	mov	h,d
	mov	h,e
	mov	h,h
	mov	h,l
	mov	h,m
	mov	h,a

	mov	l,b
	mov	l,c
	mov	l,d
	mov	l,e
	mov	l,h
	mov	l,l
	mov	l,m
	mov	l,a

	mov	m,b
	mov	m,c
	mov	m,d
	mov	m,e
	mov	m,h
	mov	m,l
	mov	m,a

	mov	a,b
	mov	a,c
	mov	a,d
	mov	a,e
	mov	a,h
	mov	a,l
	mov	a,m
	mov	a,a

;	Move Immediate

	mvi	b,byte
	mvi	c,byte
	mvi	d,byte
	mvi	e,byte
	mvi	h,byte
	mvi	l,byte
	mvi	m,byte
	mvi	a,byte

;	Load Immediate

	lxi	b,word
	lxi	d,word
	lxi	h,word
	lxi	sp,word

;	Load/Store

	ldax	b
	ldax	d
	lhld	address
	lda	address

	stax	b
	stax	d
	shld	address
	sta	address

;	Exchange

	xchg

;	Add

	add	b
	add	c
	add	d
	add	e
	add	h
	add	l
	add	m
	add	a

;	Add with Carry

	adc	b
	adc	c
	adc	d
	adc	e
	adc	h
	adc	l
	adc	m
	adc	a

;	Subtract

	sub	b
	sub	c
	sub	d
	sub	e
	sub	h
	sub	l
	sub	m
	sub	a

;	Subtract with Borrow

	sbb	b
	sbb	c
	sbb	d
	sbb	e
	sbb	h
	sbb	l
	sbb	m
	sbb	a

;	Increment Byte

	inr	b
	inr	c
	inr	d
	inr	e
	inr	h
	inr	l
	inr	m
	inr	a

;	Increment Word

	inx	b
	inx	d
	inx	h
	inx	sp

;	Decrement Byte

	dcr	b
	dcr	c
	dcr	d
	dcr	e
	dcr	h
	dcr	l
	dcr	m
	dcr	a

;	Decrement Word

	dcx	b
	dcx	d
	dcx	h
	dcx	sp

;	Double Add

	dad	b
	dad	d
	dad	h
	dad	sp

;	Specials

	daa
	cma
	stc
	cmc

;	Rotate

	rlc
	rrc
	ral
	rar

;	Logical

	ana	b
	ana	c
	ana	d
	ana	e
	ana	h
	ana	l
	ana	m
	ana	a

	xra	b
	xra	c
	xra	d
	xra	e
	xra	h
	xra	l
	xra	m
	xra	a

	ora	b
	ora	c
	ora	d
	ora	e
	ora	h
	ora	l
	ora	m
	ora	a

	cmp	b
	cmp	c
	cmp	d
	cmp	e
	cmp	h
	cmp	l
	cmp	m
	cmp	a

;	Arith and Logical immediate

address:			;Address for test
	adi	byte
	aci	byte
	sui	byte
	sbi	byte
	ani	byte
	xri	byte
	ori	byte
	cpi	byte

;	Jumps

	jmp	address
	jnz	address
	jz	address
	jnc	address
	jc	address
	jpo	address
	jpe	address
	jp	address
	jm	address
	pchl

;	Calls

	call	address
	cnz	address
	cz	address
	cnc	address
	cc	address
	cpo	address
	cpe	address
	cp	address
	cm	address

;	Return

	ret
	rnz
	rz
	rnc
	rc
	rpo
	rpe
	rp
	rm

;	Restart

	rst	0
	rst	1
	rst	2
	rst	3
	rst	4
	rst	5
	rst	6
	rst	7

;	Stack Operations

	push	b
	push	d
	push	h
	push	psw

	pop	b
	pop	d
	pop	h
	pop	psw

	xthl
	sphl

;	Input/Output

	out	byte
	in	byte

;	Control

	di
	ei
	nop
	hlt

word:	defw	56h+7800h

	end	begin
