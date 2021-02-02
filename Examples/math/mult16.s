

; this file provides 16 bit multiplication:
;
; hl = hl * de
; hl = hl * a


#code CODE


#if required(mul_hl_de)
; ––––––––––––––––––––––––––
; mult (HL DE -- HL)
;
; 	in:   hl de
;	out:  hl
;   mod:  a=0
;	pres: bc de
;   ret z

mul_hl_de::
	xor a
	cp	a,d
	jr	z,mul_exhl	; d=0 => e*hl
	cp	a,h
	;jr	z,mul_lxde	; h=0 => l*de
	jr	nz,mul_hlxde; h!0 => hl*de
; ––––––––––––––––––––––––––
#endif



; ––––––––––––––––––––––––––
; mult (HL A -- HL)
;
; 	in:   a hl
;	out:  hl
;   mod:  a=0 de
;	pres: bc
;   ret z

mul_lxde:  ex  hl,de	; HL = DE * L	variant: pres: bc
mul_exhl:  ld  a,e		; HL = HL * E	variant: pres: bc de
mul_hl_a::
mul_axhl:  ex  hl,de	; HL = HL * A	variant: pres: bc
mul_axde:: ld  l,0		; HL = DE * A	variant: pres: bc de

 ; HL = L<<8 + A * DE
mul_axdel::
	scf				; -> stopper
	adc	a			; -> cy=bit7
	jr	c,3$

; bit=0:
1$:	add	hl,hl
2$:	add	a			; -> cy=bit7
	jr	nc,1$
	ret	z			; this was the stopper

; bit=1:
3$:	add	hl,hl
	add	hl,de
	jr	2$


; HL≥256 && DE≥256:
; => full 16x16bit multiplication
; => lot of overflow

#if required(mul_hlxde)
mul_hlxde:
	ld	a,l
	push af			; l
	ld	a,h
	call mul_axdel	; hl = h*de, de=pres
	pop	af			; a=l
	jr	mul_axdel	; hl = (h*de)<<8 + l*de
#endif



; ----------------------------------
; automated tests:

#test TEST_MULT16, TEST


.macro test_mul_hl_a &op1, &op2
	ld	hl, &op1
	ld  a,	&op2
	call mul_hl_a
	.expect hl = 0xffff & (&op1 * &op2)
.endm
	ld bc, 65430
	test_mul_hl_a 12, 23
	test_mul_hl_a -333, 23
	test_mul_hl_a 257, 255
	test_mul_hl_a 12345,3
	test_mul_hl_a 0xffff,0
	test_mul_hl_a 23456,1
	.expect a=0
	.expect bc=65430


#if defined(mul_hl_de)
.macro test_mul_hl_de &op1, &op2
	ld	hl, &op1
	ld  de,	&op2
	call mul_hl_de
	.expect hl = 0xffff & (&op1 * &op2)
.endm
	ld bc, 65430
	test_mul_hl_de 116, 23
	test_mul_hl_de 116, -23
	test_mul_hl_de -116, 23
	test_mul_hl_de -116, -23
	test_mul_hl_de 256, 256
	test_mul_hl_de 257, 255
	test_mul_hl_de 12345,3
	test_mul_hl_de 5,23456
	test_mul_hl_de 0,0
	test_mul_hl_de 23456,1
	test_mul_hl_de 1,56789
	test_mul_hl_de 255, 255
	test_mul_hl_de -1, -1
	test_mul_hl_de 23456,-1
	test_mul_hl_de -1,56789
	.expect a=0
	.expect bc=65430
#endif









