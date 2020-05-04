#!/usr/local/bin/zasm --8080 --casefold -o original/
; –––––––––––––––––––––––––––––––––––––––––––––––––
; 				zasm test file
; –––––––––––––––––––––––––––––––––––––––––––––––––
;
; 2014-12-31 kio
; tests selector:
test_expressions 		equ 1
test_fails 				equ 1	; include the "must fail" tests
	org 0
; –––––––––––––––––––––––––––––––––––––––––––––––––
; 				test expressions
; –––––––––––––––––––––––––––––––––––––––––––––––––
#if test_expressions
n5 			= 		5
n20			equ		20
n20			equ 	20
#if test_fails
!anton		equ		20 30		; operator missing
!n20		equ 	30			; label redefined
!foo		equ					; value missing
#endif
	db		10
	db		$10
	db		%10
	db		10h
	db		10b
	db		0x10
	db		'A'
	db		-123
	db		+123
	db		0
	db		2
	db		0b
	db		1b
	db		8h
	db		0b1010
	db		0b10
#Assert		0 == 0
#assert		-1 == -1
#assert		33 == 33
#assert		5 > 3
#assert		3 < 5
#assert		5 != 3
#assert		3 >= 3
#assert		3 <= 3
#assert		5 >= 3
#assert		3 <= 5
#assert		-n20 == -20
#assert		~0 == -1
#assert		~-1 == 0
#assert		!0 == 1
#assert		!77 == 0
#assert		!-33 == 0
#assert		!-0 == 1
#assert		3|5 == 7
#assert		3&5 == 1
#assert		3^5 == 6
#assert		3<<2 == 3*4
#assert		0xff00<<4 == 0xff000
#assert		7>>1 == 3
#assert		0xff00>>4 == 0x0ff0
#assert		3 + 5 == 8
#assert		3 + -5 == -2
#assert		3-5==-2
#assert		3- -5==8
#assert		3*5==15
#assert		3*-5==-15
#assert		3/5==0
#assert		55/3==18
#assert		-55/3==-18
#assert		55/-3==-18
#assert		-55/-3==18
#assert		6/3==2
#assert		3%5==3
#assert		55%3==1
#assert		-55%3==-1
#assert		55%-3==1
#assert		-55%-3==-1
#assert		6%3==0
#assert		3 == 3/5*5 + 3%5
#assert		55 == 55/3*3 + 55%3
#assert		-55 == -55/3*3 + -55%3
#assert		55 == 55/-3*-3 + 55%-3
#assert		-55 == -55/-3*-3 + -55%-3
#assert		6 == 6/3*3 + 6%3
#assert		n5+n20 == 25
#assert		n5+n20*2 == 45
#assert		n20*2+n5 == 45
#assert		2+4-1*7 == -1
#assert		-(20) == 20 * -1
#assert		n20/7 == 2
#assert		(n20+1)/7 == 3
#assert		1 + 2*3<<4 == 97
#endif ; test_expressions
nn	equ	0100h
adr	equ	nn
d16	equ nn
n	equ	01h
d8	equ n
	nop			;	0x00 	1
	ld bc,D16	;	0x01 	3				B <- byte 3, C <- byte 2
	ld (bc),a		;	0x02 	1				(BC) <- A
	inc bc		;	0x03 	1				BC <- BC+1
	inc b		;	0x04 	1	Z, S, P, AC	B <- B+1
	dec b		;	0x05 	1	Z, S, P, AC	B <- B-1
	ld b,D8	;	0x06 	2				B <- byte 2
	rlca			;	0x07 	1	CY			A = A << 1; bit 0 = prev bit 7; CY = prev bit 7
	db 8		;	0x08
	add hl,bc		;	0x09 	1	CY	HL = HL + BC
	ld a,(bc)		;	0x0a 	1				A <- (BC)
	dec bc		;	0x0b 	1				BC = BC-1
	inc c		;	0x0c 	1	Z, S, P, AC	C <- C+1
	dec c		;	0x0d 	1	Z, S, P, AC	C <-C-1
	ld c,D8	;	0x0e 	2				C <- byte 2
	rrca			;	0x0f 	1	CY			A = A >> 1; bit 7 = prev bit 0; CY = prev bit 0
	db 10h		;	0x10
	ld de,D16	;	0x11 	3				D <- byte 3, E <- byte 2
	ld (de),a		;	0x12 	1				(DE) <- A
	inc de		;	0x13 	1				DE <- DE + 1
	inc d		;	0x14 	1	Z, S, P, AC	D <- D+1
	dec d		;	0x15 	1	Z, S, P, AC	D <- D-1
	ld d,D8	;	0x16 	2				D <- byte 2
	rla			;	0x17 	1	CY			A = A << 1; bit 0 = prev CY; CY = prev bit 7
	db 18h		;	0x18
	add hl,de		;	0x19 	1	CY			HL = HL + DE
	ld a,(de)		;	0x1a 	1				A <- (DE)
	dec de		;	0x1b 	1				DE = DE-1
	inc e		;	0x1c 	1	Z, S, P, AC	E <-E+1
	dec e		;	0x1d 	1	Z, S, P, AC	E <- E-1
	ld e,D8	;	0x1e 	2				E <- byte 2
	rra			;	0x1f 	1	CY			A = A >> 1; bit 7 = prev bit 7; CY = prev bit 0
	db 20h		;	0x20
	ld hl,D16	;	0x21 	3				H <- byte 3, L <- byte 2
	ld (adr),hl	;	0x22 	3				(adr) <-L; (adr+1)<-H
	inc hl		;	0x23 	1				HL <- HL + 1
	inc h		;	0x24 	1	Z, S, P, AC	H <- H+1
	dec h		;	0x25 	1	Z, S, P, AC	H <- H-1
	ld h,D8	;	0x26 	2				L <- byte 2
	daa			;	0x27 	1				decimal adjust prev. arith. op.
	db  28h		;	0x28
	add hl,hl		;	0x29 	1	CY			HL = HL + HI
	ld hl,(adr)	;	0x2a 	3				L <- (adr); H<-(adr+1)
	dec hl		;	0x2b 	1				HL = HL-1
	inc l		;	0x2c 	1	Z, S, P, AC	L <- L+1
	dec l		;	0x2d 	1	Z, S, P, AC	L <- L-1
	ld l,D8	;	0x2e 	2				L <- byte 2
	cpl			;	0x2f 	1				A <- ~A
	db  30h		;	0x30
	ld sp,D16	;	0x31 	3				SP.hi <- byte 3, SP.lo <- byte 2
	ld (adr),a		;	0x32 	3				(adr) <- A
	inc sp		;	0x33 	1				SP = SP + 1
	inc (hl)		;	0x34 	1	Z, S, P, AC	(HL) <- (HL)+1
	dec (hl)		;	0x35 	1	Z, S, P, AC	(HL) <- (HL)-1
	ld (hl),D8	;	0x36 	2				(HL) <- byte 2
	scf			;	0x37 	1	CY			CY = 1
	db  38h		;	0x38
	add hl,sp		;	0x39 	1	CY			HL = HL + SP
	ld a,(adr)		;	0x3a 	3				A <- (adr)
	dec sp		;	0x3b 	1				SP = SP-1
	inc a		;	0x3c 	1	Z, S, P, AC	A <- A+1
	dec a		;	0x3d 	1	Z, S, P, AC	A <- A-1
	ld a,D8	;	0x3e 	2				A <- byte 2
	ccf			;	0x3f 	1	CY			CY=!CY
	ld b,b		;	0x40 	1				B <- B
	ld b,c		;	0x41 	1				B <- C
	ld b,d		;	0x42 	1				B <- D
	ld b,e		;	0x43 	1				B <- E
	ld b,h		;	0x44 	1				B <- H
	ld b,l		;	0x45 	1				B <- L
	ld b,(hl)		;	0x46 	1				B <- (HL)
	ld b,a		;	0x47 	1				B <- A
	ld c,b		;	0x48 	1				C <- B
	ld c,c		;	0x49 	1				C <- C
	ld c,d		;	0x4a 	1				C <- D
	ld c,e		;	0x4b 	1				C <- E
	ld c,h		;	0x4c 	1				C <- H
	ld c,l		;	0x4d 	1				C <- L
	ld c,(hl)		;	0x4e 	1				C <- (HL)
	ld c,a		;	0x4f 	1				C <- A
	ld d,b		;	0x50 	1				D <- B
	ld d,c		;	0x51 	1				D <- C
	ld d,d		;	0x52 	1				D <- D
	ld d,e		;	0x53 	1				D <- E
	ld d,h		;	0x54 	1				D <- H
	ld d,l		;	0x55 	1				D <- L
	ld d,(hl)		;	0x56 	1				D <- (HL)
	ld d,a		;	0x57 	1				D <- A
	ld e,b		;	0x58 	1				E <- B
	ld e,c		;	0x59 	1				E <- C
	ld e,d		;	0x5a 	1				E <- D
	ld e,e		;	0x5b 	1				E <- E
	ld e,h		;	0x5c 	1				E <- H
	ld e,l		;	0x5d 	1				E <- L
	ld e,(hl)		;	0x5e 	1				E <- (HL)
	ld e,a		;	0x5f 	1				E <- A
	ld h,b		;	0x60 	1				H <- B
	ld h,c		;	0x61 	1				H <- C
	ld h,d		;	0x62 	1				H <- D
	ld h,e		;	0x63 	1				H <- E
	ld h,h		;	0x64 	1				H <- H
	ld h,l		;	0x65 	1				H <- L
	ld h,(hl)		;	0x66 	1				H <- (HL)
	ld h,a		;	0x67 	1				H <- A
	ld l,b		;	0x68 	1				L <- B
	ld l,c		;	0x69 	1				L <- C
	ld l,d		;	0x6a 	1				L <- D
	ld l,e		;	0x6b 	1				L <- E
	ld l,h		;	0x6c 	1				L <- H
	ld l,l		;	0x6d 	1				L <- L
	ld l,(hl)		;	0x6e 	1				L <- (HL)
	ld l,a		;	0x6f 	1				L <- A
	ld (hl),b		;	0x70 	1				(HL) <- B
	ld (hl),c		;	0x71 	1				(HL) <- C
	ld (hl),d		;	0x72 	1				(HL) <- D
	ld (hl),e		;	0x73 	1				(HL) <- E
	ld (hl),h		;	0x74 	1				(HL) <- H
	ld (hl),l		;	0x75 	1				(HL) <- L
	halt			;	0x76 	1				halt cpu and wait for interrupt
	ld (hl),a		;	0x77 	1				(HL) <- C
	ld a,b		;	0x78 	1				A <- B
	ld a,c		;	0x79 	1				A <- C
	ld a,d		;	0x7a 	1				A <- D
	ld a,e		;	0x7b 	1				A <- E
	ld a,h		;	0x7c 	1				A <- H
	ld a,l		;	0x7d 	1				A <- L
	ld a,(hl)		;	0x7e 	1				A <- (HL)
	ld a,a		;	0x7f 	1				A <- A
	add a,b		;	0x80 	1	Z, S, P, CY, AC	A <- A + B
	add a,c		;	0x81 	1	Z, S, P, CY, AC	A <- A + C
	add a,d		;	0x82 	1	Z, S, P, CY, AC	A <- A + D
	add a,e		;	0x83 	1	Z, S, P, CY, AC	A <- A + E
	add a,h		;	0x84 	1	Z, S, P, CY, AC	A <- A + H
	add a,l		;	0x85 	1	Z, S, P, CY, AC	A <- A + L
	add a,(hl)		;	0x86 	1	Z, S, P, CY, AC	A <- A + (HL)
	add a,a		;	0x87 	1	Z, S, P, CY, AC	A <- A + A
	adc a,b		;	0x88 	1	Z, S, P, CY, AC	A <- A + B + CY
	adc a,c		;	0x89 	1	Z, S, P, CY, AC	A <- A + C + CY
	adc a,d		;	0x8a 	1	Z, S, P, CY, AC	A <- A + D + CY
	adc a,e		;	0x8b 	1	Z, S, P, CY, AC	A <- A + E + CY
	adc a,h		;	0x8c 	1	Z, S, P, CY, AC	A <- A + H + CY
	adc a,l		;	0x8d 	1	Z, S, P, CY, AC	A <- A + L + CY
	adc a,(hl)		;	0x8e 	1	Z, S, P, CY, AC	A <- A + (HL) + CY
	adc a,a		;	0x8f 	1	Z, S, P, CY, AC	A <- A + A + CY
	sub a,b		;	0x90 	1	Z, S, P, CY, AC	A <- A - B
	sub a,c		;	0x91 	1	Z, S, P, CY, AC	A <- A - C
	sub a,d		;	0x92 	1	Z, S, P, CY, AC	A <- A + D
	sub a,e		;	0x93 	1	Z, S, P, CY, AC	A <- A - E
	sub a,h		;	0x94 	1	Z, S, P, CY, AC	A <- A + H
	sub a,l		;	0x95 	1	Z, S, P, CY, AC	A <- A - L
	sub a,(hl)		;	0x96 	1	Z, S, P, CY, AC	A <- A + (HL)
	sub a,a		;	0x97 	1	Z, S, P, CY, AC	A <- A - A
	sbc a,b		;	0x98 	1	Z, S, P, CY, AC	A <- A - B - CY
	sbc a,c		;	0x99 	1	Z, S, P, CY, AC	A <- A - C - CY
	sbc a,d		;	0x9a 	1	Z, S, P, CY, AC	A <- A - D - CY
	sbc a,e		;	0x9b 	1	Z, S, P, CY, AC	A <- A - E - CY
	sbc a,h		;	0x9c 	1	Z, S, P, CY, AC	A <- A - H - CY
	sbc a,l		;	0x9d 	1	Z, S, P, CY, AC	A <- A - L - CY
	sbc a,(hl)		;	0x9e 	1	Z, S, P, CY, AC	A <- A - (HL) - CY
	sbc a,a		;	0x9f 	1	Z, S, P, CY, AC	A <- A - A - CY
	and a,b		;	0xa0 	1	Z, S, P, CY, AC	A <- A & B
	and a,c		;	0xa1 	1	Z, S, P, CY, AC	A <- A & C
	and a,d		;	0xa2 	1	Z, S, P, CY, AC	A <- A & D
	and a,e		;	0xa3 	1	Z, S, P, CY, AC	A <- A & E
	and a,h		;	0xa4 	1	Z, S, P, CY, AC	A <- A & H
	and a,l		;	0xa5 	1	Z, S, P, CY, AC	A <- A & L
	and a,(hl)		;	0xa6 	1	Z, S, P, CY, AC	A <- A & (HL)
	and a,a		;	0xa7 	1	Z, S, P, CY, AC	A <- A & A
	xor a,b		;	0xa8 	1	Z, S, P, CY, AC	A <- A ^ B
	xor a,c		;	0xa9 	1	Z, S, P, CY, AC	A <- A ^ C
	xor a,d		;	0xaa 	1	Z, S, P, CY, AC	A <- A ^ D
	xor a,e		;	0xab 	1	Z, S, P, CY, AC	A <- A ^ E
	xor a,h		;	0xac 	1	Z, S, P, CY, AC	A <- A ^ H
	xor a,l		;	0xad 	1	Z, S, P, CY, AC	A <- A ^ L
	xor a,(hl)		;	0xae 	1	Z, S, P, CY, AC	A <- A ^ (HL)
	xor a,a		;	0xaf 	1	Z, S, P, CY, AC	A <- A ^ A
	or a,b		;	0xb0 	1	Z, S, P, CY, AC	A <- A | B
	or a,c		;	0xb1 	1	Z, S, P, CY, AC	A <- A | C
	or a,d		;	0xb2 	1	Z, S, P, CY, AC	A <- A | D
	or a,e		;	0xb3 	1	Z, S, P, CY, AC	A <- A | E
	or a,h		;	0xb4 	1	Z, S, P, CY, AC	A <- A | H
	or a,l		;	0xb5 	1	Z, S, P, CY, AC	A <- A | L
	or a,(hl)		;	0xb6 	1	Z, S, P, CY, AC	A <- A | (HL)
	or a,a		;	0xb7 	1	Z, S, P, CY, AC	A <- A | A
	cp a,b		;	0xb8 	1	Z, S, P, CY, AC	A - B
	cp a,c		;	0xb9 	1	Z, S, P, CY, AC	A - C
	cp a,d		;	0xba 	1	Z, S, P, CY, AC	A - D
	cp a,e		;	0xbb 	1	Z, S, P, CY, AC	A - E
	cp a,h		;	0xbc 	1	Z, S, P, CY, AC	A - H
	cp a,l		;	0xbd 	1	Z, S, P, CY, AC	A - L
	cp a,(hl)		;	0xbe 	1	Z, S, P, CY, AC	A - (HL)
	cp a,a		;	0xbf 	1	Z, S, P, CY, AC	A - A
	ret nz			;	0xc0 	1				if NZ, RET
	pop bc		;	0xc1 	1				C <- (sp); B <- (sp+1); sp <- sp+2
	jp nz,adr		;	0xc2 	3				if NZ, PC <- adr
	 jp adr		;	0xc3 	3				PC <= adr
	call nz,adr		;	0xc4 	3				if NZ, CALL adr
	push bc		;	0xc5 	1				(sp-2)<-C; (sp-1)<-B; sp <- sp - 2
	add a,D8		;	0xc6 	2	Z, S, P, CY, AC	A <- A + byte
	rst 0		;	0xc7 	1				CALL $0
	ret z			;	0xc8 	1				if Z, RET
	ret			;	0xc9 	1				PC.lo <- (sp); PC.hi<-(sp+1); SP <- SP+2
	jp z,adr		;	0xca 	3				if Z, PC <- adr
	db 0cbh		;	0xcb
	call z,adr		;	0xcc 	3				if Z, CALL adr
	call adr	;	0xcd 	3				(SP-1)<-PC.hi;(SP-2)<-PC.lo;SP<-SP+2;PC=adr
	adc a,D8		;	0xce 	2	Z, S, P, CY, AC	A <- A + data + CY
	rst 1		;	0xcf 	1				CALL $8
	ret nc			;	0xd0 	1				if NCY, RET
	pop de		;	0xd1 	1				E <- (sp); D <- (sp+1); sp <- sp+2
	jp nc,adr		;	0xd2 	3				if NCY, PC<-adr
	out (D8),a		;	0xd3 	2				output byte to peripheral ic
	call nc,adr		;	0xd4 	3				if NCY, CALL adr
	push de		;	0xd5 	1				(sp-2)<-E; (sp-1)<-D; sp <- sp - 2
	sub a,D8		;	0xd6 	2	Z, S, P, CY, AC	A <- A - data
	rst 2		;	0xd7 	1				CALL $10
	ret c			;	0xd8 	1				if CY, RET
	db  0d9h	;	0xd9
	jp c,adr		;	0xda 	3				if CY, PC<-adr
	in a,(D8)		;	0xdb 	2				input byte from peripheral ic
	call c,adr		;	0xdc 	3				if CY, CALL adr
	db 0ddh		;	0xdd
	sbc a,D8		;	0xde 	2	Z, S, P, CY, AC	A <- A - data - CY
	rst 3		;	0xdf 	1				CALL $18
	ret po			;	0xe0 	1				if PO, RET
	pop hl		;	0xe1 	1				L <- (sp); H <- (sp+1); sp <- sp+2
	jp po,adr		;	0xe2 	3				if PO, PC <- adr
	ex hl,(sp)		;	0xe3 	1				L <-> (SP); H <-> (SP+1)
	call po,adr		;	0xe4 	3				if PO, CALL adr
	push hl		;	0xe5 	1				(sp-2)<-L; (sp-1)<-H; sp <- sp - 2
	and a,D8		;	0xe6 	2	Z, S, P, CY, AC	A <- A & data
	rst 4		;	0xe7 	1				CALL $20
	ret pe			;	0xe8 	1				if PE, RET
	jp (hl)		;	0xe9 	1				PC.hi <- H; PC.lo <- L
	jp pe,adr		;	0xea 	3				if PE, PC <- adr
	ex de,hl		;	0xeb 	1				H <-> D; L <-> E
	call pe,adr		;	0xec 	3				if PE, CALL adr
	db 0edh		;	0xed
	xor a,D8		;	0xee 	2	Z, S, P, CY, AC	A <- A ^ data
	rst 5		;	0xef 	1				CALL $28
	ret p			;	0xf0 	1				if P, RET
	pop af		;	0xf1 	1	ALL			flags <- (sp); A <- (sp+1); sp <- sp+2
	jp p,adr		;	0xf2 	3				if P=1 PC <- adr
	di			;	0xf3 	1				disable interrupts
	call p,adr		;	0xf4 	3				if P, PC <- adr
	push af	;	0xf5 	1				(sp-2)<-flags; (sp-1)<-A; sp <- sp - 2
	or a,D8		;	0xf6 	2	Z, S, P, CY, AC	A <- A | data
	rst 6		;	0xf7 	1				CALL $30
	ret m			;	0xf8 	1				if M, RET
	ld sp,hl		;	0xf9 	1				SP=HL
	jp m,adr		;	0xfa 	3				if M, PC <- adr
	ei			;	0xfb 	1				enable interrupts
	call m,adr		;	0xfc 	3				if M, CALL adr
	db 0fdh		;	0xfd
	cp a,D8		;	0xfe 	2				Z, S, P, CY, AC	A - data
	rst 7		;	0xff 	1				CALL $38
