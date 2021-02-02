

; this file provides 32 bit multiplication:
;
; HLDE = HLDE * A
; H'L'HL = H'L'HL * D'E'DE
; H'L'HL = H'L'HL * DE
; H'L'HL = H'L'HL * A


#code CODE


#if required(mul_hlde_a)
; ----------------------------
; HLDE = HLDE * A
;
; hlde is signed or unsigned
; a is unsigned

mul_hlde_a::
	ex	hl,de	; de = i32.lo
	push hl
	ld	hl,0	; hl = 0
	exx
	pop	de		; de' = i32.hi
	ld	l,0		; hl' = 0  (h will be shifted out)
	exx

	call mul_axdedel	; H'L'HL = result

	push hl
	exx
	pop	de
	ret
#endif



#if required(mul_hlhl_dede)
; ----------------------------
; H'L'HL = H'L'HL * D'E'DE
;
; hlhl is signed or unsigned
; dede is signed or unsigned

mul_hlhl_dede::
	ld	 a,e
	push af			; i32.lo.lo
	push de			; i32.lo.hi

	exx
	ld	 a,e
	push af			; i32.hi.lo
	ld	 a,d		; i32.hi.hi
	exx

	call mul_hlhl_a
	pop	af
	call mul_axdedel
	pop	af
	call mul_axdedel
	pop	af
	jr 	mul_axdedel
#endif


#if required(mul_hlhl_de)
; ----------------------------
; H'L'HL = H'L'HL * DE
;
; hlhl is signed or unsigned
; de is unsigned

mul_hlhl_de::
	ld	a,e
	push af
	ld	a,d
	call mul_hlhl_a
	pop	af
	jr	mul_axdedel
#endif


; ----------------------------
; H'L'HL = H'L'HL * A
;
; hlhl is signed or unsigned
; a is unsigned
;
; in:   HL'HL  A
; out:  HL'HL
; mod:  DE'DE = HL'HL  A=0
; pres: BC' BC A'
; ret z

#if required(mul_hlhl_a)
mul_hlhl_a::
	ex	hl,de		; de=i32.lo
	ld	hl,0		; hl=0
	exx
	ex	hl,de		; de'=i32.hi
	ld	l,0			; hl'=0  (h will be shifted out)
	exx
	;jr	mul_axdedel
#endif



#if required(mul_hlhl_a) || required(mul_axdedel)
; ----------------------------
; H'L'HL = H'L'HL<<8 + A * D'E'DE

mul_axdedel::
	scf			; -> stopper
	adc	a		; -> cy=bit7
	jr	c,3$

; 0 --> don't add de:
1$:	add	hl,hl	; lo
	exx
	adc	hl,hl	; hi
	exx
2$:	add	a		; -> cy=bit7, z=!a
	jr	nc,1$
	ret	z		; this was the stopper

; 1 --> add de:
3$:	add	hl,hl	; lo
	exx
	adc	hl,hl	; hi
	exx
	add	hl,de	; lo
	exx
	adc	hl,de	; hi
	exx
	jr	2$
#endif



; ----------------------------
; automated tests:

#test TEST_MULT32, TEST


; test mul_axdedel
; test mul_hlhl_dede
; test mul_hlde_a


#if defined(mul_hlhl_a)
.macro test_mul_hlhl_a &op1, &op2
	ld	hl,&op1>>16
	exx
	ld	hl,&op1&$ffff
	ld	a,&op2
	call mul_hlhl_a
	push hl \ exx \ pop de
	.expect hlde = &op1 * &op2
.endm
	test_mul_hlhl_a 17, 15			; 711 cc
	test_mul_hlhl_a 17345, 123		; 803 cc
	test_mul_hlhl_a 97345345, 123	; 803 cc
	test_mul_hlhl_a -97345345, 33	; 619 cc
	;test_mul_hlhl_a 97345345, -123	 <-- a = u8
#endif


#if defined(mul_hlhl_de)
.macro test_mul_hlhl_de &op1, &op2
	ld	hl,&op1>>16
	exx
	ld	hl,&op1&$ffff
	ld	de,&op2
	call mul_hlhl_de
	push hl \ exx \ pop de
	.expect hlde = &op1 * &op2
.endm

	test_mul_hlhl_de 17, 15			; 1193
	test_mul_hlhl_de 17345, 123		; 1285
	test_mul_hlhl_de 97345345, 123	; 1285
	test_mul_hlhl_de -97345345, 33	; 1101
	test_mul_hlhl_de 345345, 14423	; 1377
	test_mul_hlhl_de -5345, 65423	; 1617
	;test_mul_hlhl_de 97345345, -123 <-- de = u16
#endif
















