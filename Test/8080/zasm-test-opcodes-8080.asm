#!/usr/local/bin/zasm --convert8080 --asm8080 -o original/
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


	NOP			;	0x00 	1
	LXI B,D16	;	0x01 	3				B <- byte 3, C <- byte 2
	STAX B		;	0x02 	1				(BC) <- A
	INX B		;	0x03 	1				BC <- BC+1
	INR B		;	0x04 	1	Z, S, P, AC	B <- B+1
	DCR B		;	0x05 	1	Z, S, P, AC	B <- B-1
	MVI B, D8	;	0x06 	2				B <- byte 2
	RLC			;	0x07 	1	CY			A = A << 1; bit 0 = prev bit 7; CY = prev bit 7
	db 8		;	0x08
	DAD B		;	0x09 	1	CY	HL = HL + BC
	LDAX B		;	0x0a 	1				A <- (BC)
	DCX B		;	0x0b 	1				BC = BC-1
	INR C		;	0x0c 	1	Z, S, P, AC	C <- C+1
	DCR C		;	0x0d 	1	Z, S, P, AC	C <-C-1
	MVI C,D8	;	0x0e 	2				C <- byte 2
	RRC			;	0x0f 	1	CY			A = A >> 1; bit 7 = prev bit 0; CY = prev bit 0
	db 10h		;	0x10
	LXI D,D16	;	0x11 	3				D <- byte 3, E <- byte 2
	STAX D		;	0x12 	1				(DE) <- A
	INX D		;	0x13 	1				DE <- DE + 1
	INR D		;	0x14 	1	Z, S, P, AC	D <- D+1
	DCR D		;	0x15 	1	Z, S, P, AC	D <- D-1
	MVI D, D8	;	0x16 	2				D <- byte 2
	RAL			;	0x17 	1	CY			A = A << 1; bit 0 = prev CY; CY = prev bit 7
	db 18h		;	0x18
	DAD D		;	0x19 	1	CY			HL = HL + DE
	LDAX D		;	0x1a 	1				A <- (DE)
	DCX D		;	0x1b 	1				DE = DE-1
	INR E		;	0x1c 	1	Z, S, P, AC	E <-E+1
	DCR E		;	0x1d 	1	Z, S, P, AC	E <- E-1
	MVI E,D8	;	0x1e 	2				E <- byte 2
	RAR			;	0x1f 	1	CY			A = A >> 1; bit 7 = prev bit 7; CY = prev bit 0
	db 20h		;	0x20
	LXI H,D16	;	0x21 	3				H <- byte 3, L <- byte 2
	SHLD adr	;	0x22 	3				(adr) <-L; (adr+1)<-H
	INX H		;	0x23 	1				HL <- HL + 1
	INR H		;	0x24 	1	Z, S, P, AC	H <- H+1
	DCR H		;	0x25 	1	Z, S, P, AC	H <- H-1
	MVI H,D8	;	0x26 	2				L <- byte 2
	DAA			;	0x27 	1				decimal adjust prev. arith. op.
	db  28h		;	0x28
	DAD H		;	0x29 	1	CY			HL = HL + HI
	LHLD adr	;	0x2a 	3				L <- (adr); H<-(adr+1)
	DCX H		;	0x2b 	1				HL = HL-1
	INR L		;	0x2c 	1	Z, S, P, AC	L <- L+1
	DCR L		;	0x2d 	1	Z, S, P, AC	L <- L-1
	MVI L, D8	;	0x2e 	2				L <- byte 2
	CMA			;	0x2f 	1				A <- ~A
	db  30h		;	0x30
	LXI SP, D16	;	0x31 	3				SP.hi <- byte 3, SP.lo <- byte 2
	STA adr		;	0x32 	3				(adr) <- A
	INX SP		;	0x33 	1				SP = SP + 1
	INR M		;	0x34 	1	Z, S, P, AC	(HL) <- (HL)+1
	DCR M		;	0x35 	1	Z, S, P, AC	(HL) <- (HL)-1
	MVI M,D8	;	0x36 	2				(HL) <- byte 2
	STC			;	0x37 	1	CY			CY = 1
	db  38h		;	0x38
	DAD SP		;	0x39 	1	CY			HL = HL + SP
	LDA adr		;	0x3a 	3				A <- (adr)
	DCX SP		;	0x3b 	1				SP = SP-1
	INR A		;	0x3c 	1	Z, S, P, AC	A <- A+1
	DCR A		;	0x3d 	1	Z, S, P, AC	A <- A-1
	MVI A,D8	;	0x3e 	2				A <- byte 2
	CMC			;	0x3f 	1	CY			CY=!CY
	MOV B,B		;	0x40 	1				B <- B
	MOV B,C		;	0x41 	1				B <- C
	MOV B,D		;	0x42 	1				B <- D
	MOV B,E		;	0x43 	1				B <- E
	MOV B,H		;	0x44 	1				B <- H
	MOV B,L		;	0x45 	1				B <- L
	MOV B,M		;	0x46 	1				B <- (HL)
	MOV B,A		;	0x47 	1				B <- A
	MOV C,B		;	0x48 	1				C <- B
	MOV C,C		;	0x49 	1				C <- C
	MOV C,D		;	0x4a 	1				C <- D
	MOV C,E		;	0x4b 	1				C <- E
	MOV C,H		;	0x4c 	1				C <- H
	MOV C,L		;	0x4d 	1				C <- L
	MOV C,M		;	0x4e 	1				C <- (HL)
	MOV C,A		;	0x4f 	1				C <- A
	MOV D,B		;	0x50 	1				D <- B
	MOV D,C		;	0x51 	1				D <- C
	MOV D,D		;	0x52 	1				D <- D
	MOV D,E		;	0x53 	1				D <- E
	MOV D,H		;	0x54 	1				D <- H
	MOV D,L		;	0x55 	1				D <- L
	MOV D,M		;	0x56 	1				D <- (HL)
	MOV D,A		;	0x57 	1				D <- A
	MOV E,B		;	0x58 	1				E <- B
	MOV E,C		;	0x59 	1				E <- C
	MOV E,D		;	0x5a 	1				E <- D
	MOV E,E		;	0x5b 	1				E <- E
	MOV E,H		;	0x5c 	1				E <- H
	MOV E,L		;	0x5d 	1				E <- L
	MOV E,M		;	0x5e 	1				E <- (HL)
	MOV E,A		;	0x5f 	1				E <- A
	MOV H,B		;	0x60 	1				H <- B
	MOV H,C		;	0x61 	1				H <- C
	MOV H,D		;	0x62 	1				H <- D
	MOV H,E		;	0x63 	1				H <- E
	MOV H,H		;	0x64 	1				H <- H
	MOV H,L		;	0x65 	1				H <- L
	MOV H,M		;	0x66 	1				H <- (HL)
	MOV H,A		;	0x67 	1				H <- A
	MOV L,B		;	0x68 	1				L <- B
	MOV L,C		;	0x69 	1				L <- C
	MOV L,D		;	0x6a 	1				L <- D
	MOV L,E		;	0x6b 	1				L <- E
	MOV L,H		;	0x6c 	1				L <- H
	MOV L,L		;	0x6d 	1				L <- L
	MOV L,M		;	0x6e 	1				L <- (HL)
	MOV L,A		;	0x6f 	1				L <- A
	MOV M,B		;	0x70 	1				(HL) <- B
	MOV M,C		;	0x71 	1				(HL) <- C
	MOV M,D		;	0x72 	1				(HL) <- D
	MOV M,E		;	0x73 	1				(HL) <- E
	MOV M,H		;	0x74 	1				(HL) <- H
	MOV M,L		;	0x75 	1				(HL) <- L
	HLT			;	0x76 	1				halt cpu and wait for interrupt
	MOV M,A		;	0x77 	1				(HL) <- C
	MOV A,B		;	0x78 	1				A <- B
	MOV A,C		;	0x79 	1				A <- C
	MOV A,D		;	0x7a 	1				A <- D
	MOV A,E		;	0x7b 	1				A <- E
	MOV A,H		;	0x7c 	1				A <- H
	MOV A,L		;	0x7d 	1				A <- L
	MOV A,M		;	0x7e 	1				A <- (HL)
	MOV A,A		;	0x7f 	1				A <- A
	ADD B		;	0x80 	1	Z, S, P, CY, AC	A <- A + B
	ADD C		;	0x81 	1	Z, S, P, CY, AC	A <- A + C
	ADD D		;	0x82 	1	Z, S, P, CY, AC	A <- A + D
	ADD E		;	0x83 	1	Z, S, P, CY, AC	A <- A + E
	ADD H		;	0x84 	1	Z, S, P, CY, AC	A <- A + H
	ADD L		;	0x85 	1	Z, S, P, CY, AC	A <- A + L
	ADD M		;	0x86 	1	Z, S, P, CY, AC	A <- A + (HL)
	ADD A		;	0x87 	1	Z, S, P, CY, AC	A <- A + A
	ADC B		;	0x88 	1	Z, S, P, CY, AC	A <- A + B + CY
	ADC C		;	0x89 	1	Z, S, P, CY, AC	A <- A + C + CY
	ADC D		;	0x8a 	1	Z, S, P, CY, AC	A <- A + D + CY
	ADC E		;	0x8b 	1	Z, S, P, CY, AC	A <- A + E + CY
	ADC H		;	0x8c 	1	Z, S, P, CY, AC	A <- A + H + CY
	ADC L		;	0x8d 	1	Z, S, P, CY, AC	A <- A + L + CY
	ADC M		;	0x8e 	1	Z, S, P, CY, AC	A <- A + (HL) + CY
	ADC A		;	0x8f 	1	Z, S, P, CY, AC	A <- A + A + CY
	SUB B		;	0x90 	1	Z, S, P, CY, AC	A <- A - B
	SUB C		;	0x91 	1	Z, S, P, CY, AC	A <- A - C
	SUB D		;	0x92 	1	Z, S, P, CY, AC	A <- A + D
	SUB E		;	0x93 	1	Z, S, P, CY, AC	A <- A - E
	SUB H		;	0x94 	1	Z, S, P, CY, AC	A <- A + H
	SUB L		;	0x95 	1	Z, S, P, CY, AC	A <- A - L
	SUB M		;	0x96 	1	Z, S, P, CY, AC	A <- A + (HL)
	SUB A		;	0x97 	1	Z, S, P, CY, AC	A <- A - A
	SBB B		;	0x98 	1	Z, S, P, CY, AC	A <- A - B - CY
	SBB C		;	0x99 	1	Z, S, P, CY, AC	A <- A - C - CY
	SBB D		;	0x9a 	1	Z, S, P, CY, AC	A <- A - D - CY
	SBB E		;	0x9b 	1	Z, S, P, CY, AC	A <- A - E - CY
	SBB H		;	0x9c 	1	Z, S, P, CY, AC	A <- A - H - CY
	SBB L		;	0x9d 	1	Z, S, P, CY, AC	A <- A - L - CY
	SBB M		;	0x9e 	1	Z, S, P, CY, AC	A <- A - (HL) - CY
	SBB A		;	0x9f 	1	Z, S, P, CY, AC	A <- A - A - CY
	ANA B		;	0xa0 	1	Z, S, P, CY, AC	A <- A & B
	ANA C		;	0xa1 	1	Z, S, P, CY, AC	A <- A & C
	ANA D		;	0xa2 	1	Z, S, P, CY, AC	A <- A & D
	ANA E		;	0xa3 	1	Z, S, P, CY, AC	A <- A & E
	ANA H		;	0xa4 	1	Z, S, P, CY, AC	A <- A & H
	ANA L		;	0xa5 	1	Z, S, P, CY, AC	A <- A & L
	ANA M		;	0xa6 	1	Z, S, P, CY, AC	A <- A & (HL)
	ANA A		;	0xa7 	1	Z, S, P, CY, AC	A <- A & A
	XRA B		;	0xa8 	1	Z, S, P, CY, AC	A <- A ^ B
	XRA C		;	0xa9 	1	Z, S, P, CY, AC	A <- A ^ C
	XRA D		;	0xaa 	1	Z, S, P, CY, AC	A <- A ^ D
	XRA E		;	0xab 	1	Z, S, P, CY, AC	A <- A ^ E
	XRA H		;	0xac 	1	Z, S, P, CY, AC	A <- A ^ H
	XRA L		;	0xad 	1	Z, S, P, CY, AC	A <- A ^ L
	XRA M		;	0xae 	1	Z, S, P, CY, AC	A <- A ^ (HL)
	XRA A		;	0xaf 	1	Z, S, P, CY, AC	A <- A ^ A
	ORA B		;	0xb0 	1	Z, S, P, CY, AC	A <- A | B
	ORA C		;	0xb1 	1	Z, S, P, CY, AC	A <- A | C
	ORA D		;	0xb2 	1	Z, S, P, CY, AC	A <- A | D
	ORA E		;	0xb3 	1	Z, S, P, CY, AC	A <- A | E
	ORA H		;	0xb4 	1	Z, S, P, CY, AC	A <- A | H
	ORA L		;	0xb5 	1	Z, S, P, CY, AC	A <- A | L
	ORA M		;	0xb6 	1	Z, S, P, CY, AC	A <- A | (HL)
	ORA A		;	0xb7 	1	Z, S, P, CY, AC	A <- A | A
	CMP B		;	0xb8 	1	Z, S, P, CY, AC	A - B
	CMP C		;	0xb9 	1	Z, S, P, CY, AC	A - C
	CMP D		;	0xba 	1	Z, S, P, CY, AC	A - D
	CMP E		;	0xbb 	1	Z, S, P, CY, AC	A - E
	CMP H		;	0xbc 	1	Z, S, P, CY, AC	A - H
	CMP L		;	0xbd 	1	Z, S, P, CY, AC	A - L
	CMP M		;	0xbe 	1	Z, S, P, CY, AC	A - (HL)
	CMP A		;	0xbf 	1	Z, S, P, CY, AC	A - A
	RNZ			;	0xc0 	1				if NZ, RET
	POP B		;	0xc1 	1				C <- (sp); B <- (sp+1); sp <- sp+2
	JNZ adr		;	0xc2 	3				if NZ, PC <- adr
	JMP adr		;	0xc3 	3				PC <= adr
	CNZ adr		;	0xc4 	3				if NZ, CALL adr
	PUSH B		;	0xc5 	1				(sp-2)<-C; (sp-1)<-B; sp <- sp - 2
	ADI D8		;	0xc6 	2	Z, S, P, CY, AC	A <- A + byte
	RST 0		;	0xc7 	1				CALL $0
	RZ			;	0xc8 	1				if Z, RET
	RET			;	0xc9 	1				PC.lo <- (sp); PC.hi<-(sp+1); SP <- SP+2
	JZ adr		;	0xca 	3				if Z, PC <- adr
	db 0cbh		;	0xcb
	CZ adr		;	0xcc 	3				if Z, CALL adr
	CALL adr	;	0xcd 	3				(SP-1)<-PC.hi;(SP-2)<-PC.lo;SP<-SP+2;PC=adr
	ACI D8		;	0xce 	2	Z, S, P, CY, AC	A <- A + data + CY
	RST 1		;	0xcf 	1				CALL $8
	RNC			;	0xd0 	1				if NCY, RET
	POP D		;	0xd1 	1				E <- (sp); D <- (sp+1); sp <- sp+2
	JNC adr		;	0xd2 	3				if NCY, PC<-adr
	OUT D8		;	0xd3 	2				output byte to peripheral ic
	CNC adr		;	0xd4 	3				if NCY, CALL adr
	PUSH D		;	0xd5 	1				(sp-2)<-E; (sp-1)<-D; sp <- sp - 2
	SUI D8		;	0xd6 	2	Z, S, P, CY, AC	A <- A - data
	RST 2		;	0xd7 	1				CALL $10
	RC			;	0xd8 	1				if CY, RET
	db  0d9h	;	0xd9
	JC adr		;	0xda 	3				if CY, PC<-adr
	IN D8		;	0xdb 	2				input byte from peripheral ic
	CC adr		;	0xdc 	3				if CY, CALL adr
	db 0ddh		;	0xdd
	SBI D8		;	0xde 	2	Z, S, P, CY, AC	A <- A - data - CY
	RST 3		;	0xdf 	1				CALL $18
	RPO			;	0xe0 	1				if PO, RET
	POP H		;	0xe1 	1				L <- (sp); H <- (sp+1); sp <- sp+2
	JPO adr		;	0xe2 	3				if PO, PC <- adr
	XTHL		;	0xe3 	1				L <-> (SP); H <-> (SP+1)
	CPO adr		;	0xe4 	3				if PO, CALL adr
	PUSH H		;	0xe5 	1				(sp-2)<-L; (sp-1)<-H; sp <- sp - 2
	ANI D8		;	0xe6 	2	Z, S, P, CY, AC	A <- A & data
	RST 4		;	0xe7 	1				CALL $20
	RPE			;	0xe8 	1				if PE, RET
	PCHL		;	0xe9 	1				PC.hi <- H; PC.lo <- L
	JPE adr		;	0xea 	3				if PE, PC <- adr
	XCHG		;	0xeb 	1				H <-> D; L <-> E
	CPE adr		;	0xec 	3				if PE, CALL adr
	db 0edh		;	0xed
	XRI D8		;	0xee 	2	Z, S, P, CY, AC	A <- A ^ data
	RST 5		;	0xef 	1				CALL $28
	RP			;	0xf0 	1				if P, RET
	POP PSW		;	0xf1 	1	ALL			flags <- (sp); A <- (sp+1); sp <- sp+2
	JP adr		;	0xf2 	3				if P=1 PC <- adr
	DI			;	0xf3 	1				disable interrupts
	CP adr		;	0xf4 	3				if P, PC <- adr
	PUSH PSW	;	0xf5 	1				(sp-2)<-flags; (sp-1)<-A; sp <- sp - 2
	ORI D8		;	0xf6 	2	Z, S, P, CY, AC	A <- A | data
	RST 6		;	0xf7 	1				CALL $30
	RM			;	0xf8 	1				if M, RET
	SPHL		;	0xf9 	1				SP=HL
	JM adr		;	0xfa 	3				if M, PC <- adr
	EI			;	0xfb 	1				enable interrupts
	CM adr		;	0xfc 	3				if M, CALL adr
	db 0fdh		;	0xfd
	CPI D8		;	0xfe 	2				Z, S, P, CY, AC	A - data
	RST 7		;	0xff 	1				CALL $38



























