

#code CODE


; ----------------------------
; multiply i32 * i32 = i32
; ca. 3500 cc
; 44 bytes

; multiply  h'l'hl = h'l'hl * d'e'de
; http://www.andreadrian.de/oldcpu/Z80_number_cruncher.html#mozTocId229810

#code CODE

mul32_hlhl_dede:
	push bc			; save BC
	ld	 bc,hl

	xor  a          ; reset carry flag
	ld   h,a        ; lower result = 0
	ld	 l,a
	exx
	push bc			; save BC'
	ld	 bc,hl
	ld	 h,a        ; higher result = 0
	ld	 l,a

	ld   a,b        ; mpr is ac'bc
	ld   b,32       ; initialize loop counter

2$:	sra  a          ; right shift mpr
	rr   c
	exx
	rr   b
	rr   c          ; lowest bit into carry
	jr   nc,1$

	add  hl,de      ; result += mpd
	exx
	adc  hl,de
	exx

1$:	sla	 e         	; left shift mpd
	rl   d
	exx
	rl   e
	rl   d
	djnz 2$

	pop  bc			; restore BC'
	exx				; result = H'L'HL

	pop	 bc			; restore BC
	ret


#test TEST

.macro test_mul32_hlhl_dede &op1, &op2
	ld	de,&op1>>16
	ld	hl,&op2>>16
	exx
	ld	de,&op1&$ffff
	ld	hl,&op2&$ffff
	call mul32_hlhl_dede
	push hl \ exx \ pop de
	.expect hlde = &op1 * &op2
.endm

	ld	bc, 43657
	test_mul32_hlhl_dede 17,15		 ; 3383 cc
	test_mul32_hlhl_dede 17234,61500 ; 3524 cc
	test_mul32_hlhl_dede 12398652,89 ; 3408 cc
	test_mul32_hlhl_dede 45,232523143; 3698 cc
	.expect bc = 43657



