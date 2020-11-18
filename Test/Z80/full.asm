#!/usr/local/bin/zasm --ixcbr2 -o original/

;  *************************************
;
;  Full set of instructions and aliases
;      for Zilog Z80 microprocessor
;
;      used by zmac cross-assembler
;
;  *************************************

Imm_Bte	.equ	$12
Imm_Wrd	.equ	$2345
Port	.equ	$34
Displ	.equ	$45

	.org	$1000

Space	.ds	$100

;  *************************************
;
;  Standard z80 instructions
;      (without prefix)
;
;  *************************************

	NOP			; 00
	LD	BC,Imm_Wrd	; 014523
	LD	(BC),A		; 02
	INC	BC		; 03
	INC	B		; 04
	DEC	B		; 05
	LD	B,Imm_Bte	; 0612
	RLCA			; 07
	EX	AF,AF'		; 08
	ADD	HL,BC		; 09
	LD	A,(BC)		; 0A
	DEC	BC		; 0B
	INC	C		; 0C
	DEC	C		; 0D
	LD	C,Imm_Bte	; 0E12
	RRCA			; 0F
L01:	DJNZ	L01		; 10FE
	LD	DE,Imm_Wrd	; 114523
	LD	(DE),A		; 12
	INC	DE		; 13
	INC	D		; 14
	DEC	D		; 15
	LD	D,Imm_Bte	; 1612
	RLA			; 17
L02:	JR	L02		; 18FE
	ADD	HL,DE		; 19
	LD	A,(DE)		; 1A
	DEC	DE		; 1B
	INC	E		; 1C
	DEC	E		; 1D
	LD	E,Imm_Bte	; 1E12
	RRA			; 1F
L03:	JR	NZ,L03		; 20FE
	LD	HL,Imm_Wrd	; 214523
	LD	(Space),HL	; 220010
	INC	HL		; 23
	INC	H		; 24
	DEC	H		; 25
	LD	H,Imm_Bte	; 2612
	DAA			; 27
L04:	JR	Z,L04		; 28FE
	ADD	HL,HL		; 29
	LD	HL,(Space)	; 2A0010
	DEC	HL		; 2B
	INC	L		; 2C
	DEC	L		; 2D
	LD	L,Imm_Bte	; 2E12
	CPL			; 2F
L05:	JR	NC,L05		; 30FE
	LD	SP,Imm_Wrd	; 314523
	LD	(Space),A	; 320010
	INC	SP		; 33
	INC	(HL)		; 34
	DEC	(HL)		; 35
	LD	(HL),Imm_Bte	; 3612
	SCF			; 37
L06:	JR	C,L06		; 38FE
	ADD	HL,SP		; 39
	LD	A,(Space)	; 3A0010
	DEC	SP		; 3B
	INC	A		; 3C
	DEC	A		; 3D
	LD	A,Imm_Bte	; 3E12
	CCF			; 3F
	LD	B,B		; 40
	LD	B,C		; 41
	LD	B,D		; 42
	LD	B,E		; 43
	LD	B,H		; 44
	LD	B,L		; 45
	LD	B,(HL)		; 46
	LD	B,A		; 47
	LD	C,B		; 48
	LD	C,C		; 49
	LD	C,D		; 4A
	LD	C,E		; 4B
	LD	C,H		; 4C
	LD	C,L		; 4D
	LD	C,(HL)		; 4E
	LD	C,A		; 4F
	LD	D,B		; 50
	LD	D,C		; 51
	LD	D,D		; 52
	LD	D,E		; 53
	LD	D,H		; 54
	LD	D,L		; 55
	LD	D,(HL)		; 56
	LD	D,A		; 57
	LD	E,B		; 58
	LD	E,C		; 59
	LD	E,D		; 5A
	LD	E,E		; 5B
	LD	E,H		; 5C
	LD	E,L		; 5D
	LD	E,(HL)		; 5E
	LD	E,A		; 5F
	LD	H,B		; 60
	LD	H,C		; 61
	LD	H,D		; 62
	LD	H,E		; 63
	LD	H,H		; 64
	LD	H,L		; 65
	LD	H,(HL)		; 66
	LD	H,A		; 67
	LD	L,B		; 68
	LD	L,C		; 69
	LD	L,D		; 6A
	LD	L,E		; 6B
	LD	L,H		; 6C
	LD	L,L		; 6D
	LD	L,(HL)		; 6E
	LD	L,A		; 6F
	LD	(HL),B		; 70
	LD	(HL),C		; 71
	LD	(HL),D		; 72
	LD	(HL),E		; 73
	LD	(HL),H		; 74
	LD	(HL),L		; 75
	HALT			; 76
	LD	(HL),A		; 77
	LD	A,B		; 78
	LD	A,C		; 79
	LD	A,D		; 7A
	LD	A,E		; 7B
	LD	A,H		; 7C
	LD	A,L		; 7D
	LD	A,(HL)		; 7E
	LD	A,A		; 7F
	ADD	A,B		; 80 --------- Official long style
	ADD	A,C		; 81 --------- Official long style
	ADD	A,D		; 82 --------- Official long style
	ADD	A,E		; 83 --------- Official long style
	ADD	A,H		; 84 --------- Official long style
	ADD	A,L		; 85 --------- Official long style
	ADD	A,(HL)		; 86 --------- Official long style
	ADD	A,A		; 87 --------- Official long style
	ADC	A,B		; 88 --------- Official long style
	ADC	A,C		; 89 --------- Official long style
	ADC	A,D		; 8A --------- Official long style
	ADC	A,E		; 8B --------- Official long style
	ADC	A,H		; 8C --------- Official long style
	ADC	A,L		; 8D --------- Official long style
	ADC	A,(HL)		; 8E --------- Official long style
	ADC	A,A		; 8F --------- Official long style
	SUB	B		; 90 --------- Official short style
	SUB	C		; 91 --------- Official short style
	SUB	D		; 92 --------- Official short style
	SUB	E		; 93 --------- Official short style
	SUB	H		; 94 --------- Official short style
	SUB	L		; 95 --------- Official short style
	SUB	(HL)		; 96 --------- Official short style
	SUB	A		; 97 --------- Official short style
	SBC	A,B		; 98 --------- Official long style
	SBC	A,C		; 99 --------- Official long style
	SBC	A,D		; 9A --------- Official long style
	SBC	A,E		; 9B --------- Official long style
	SBC	A,H		; 9C --------- Official long style
	SBC	A,L		; 9D --------- Official long style
	SBC	A,(HL)		; 9E --------- Official long style
	SBC	A,A		; 9F --------- Official long style
	AND	B		; A0 --------- Official short style
	AND	C		; A1 --------- Official short style
	AND	D		; A2 --------- Official short style
	AND	E		; A3 --------- Official short style
	AND	H		; A4 --------- Official short style
	AND	L		; A5 --------- Official short style
	AND	(HL)		; A6 --------- Official short style
	AND	A		; A7 --------- Official short style
	XOR	B		; A8 --------- Official short style
	XOR	C		; A9 --------- Official short style
	XOR	D		; AA --------- Official short style
	XOR	E		; AB --------- Official short style
	XOR	H		; AC --------- Official short style
	XOR	L		; AD --------- Official short style
	XOR	(HL)		; AE --------- Official short style
	XOR	A		; AF --------- Official short style
	OR	B		; B0 --------- Official short style
	OR	C		; B1 --------- Official short style
	OR	D		; B2 --------- Official short style
	OR	E		; B3 --------- Official short style
	OR	H		; B4 --------- Official short style
	OR	L		; B5 --------- Official short style
	OR	(HL)		; B6 --------- Official short style
	OR	A		; B7 --------- Official short style
	CP	B		; B8 --------- Official short style
	CP	C		; B9 --------- Official short style
	CP	D		; BA --------- Official short style
	CP	E		; BB --------- Official short style
	CP	H		; BC --------- Official short style
	CP	L		; BD --------- Official short style
	CP	(HL)		; BE --------- Official short style
	CP	A		; BF --------- Official short style
	RET	NZ		; C0
	POP	BC		; C1
L07:	JP	NZ,L07		; C2E011
L08:	JP	L08		; C3E311
L09:	CALL	NZ,L09		; C4E611
	PUSH	BC		; C5
	ADD	A,Imm_Bte	; C612 ------- Official long style
	RST	0x00		; C7
	RET	Z		; C8
	RET			; C9
L10:	JP	Z,L10		; CAEF11
				; ------------ Prefix
L11:	CALL	Z,L11		; CCF211
L12:	CALL	L12		; CDF511
	ADC	A,Imm_Bte	; CE12 ------- Official long style
	RST	0x08		; CF
	RET	NC		; D0
	POP	DE		; D1
L13:	JP	NC,13		; D20D00
	OUT	(Port),A	; D334
L14:	CALL	NC,L14		; D40212
	PUSH	DE		; D5
	SUB	Imm_Bte		; D612 ------- Official short style
	RST	0x10		; D7
	RET	C		; D8
	EXX			; D9
L15:	JP	C,L15		; DA0B12
	IN	A,(Port)	; DB34
L16:	CALL	C,L16		; DC1012
				; ------------ Prefix
	SBC	A,Imm_Bte	; DE12 ------- Official long style
	RST	0x18		; DF
	RET	PO		; E0
	POP	HL		; E1
L17:	JP	PO,L17		; E21812
	EX	(SP),HL		; E3
L18:	CALL	PO,L18		; E41C12
	PUSH	HL		; E5
	AND	Imm_Bte		; E612 ------- Official short style
	RST	0x20		; E7
	RET	PE		; E8
	JP	(HL)		; E9
L19:	JP	PE,L19		; EA2512
	EX	DE,HL		; EB
L20:	CALL	PE,L20		; EC2912
				; ------------ Prefix
	XOR	Imm_Bte		; EE12 ------- Official short style
	RST	0x28		; EF
	RET	P		; F0
	POP	AF		; F1
L21:	JP	P,L21		; F23112
	DI			; F3
L22:	CALL	P,L22		; F43512
	PUSH	AF		; F5
	OR	Imm_Bte		; F612 ------- Official short style
	RST	0x30		; F7
	RET	M		; F8
	LD	SP,HL		; F9
L23:	JP	M,L23		; FA3E12
	EI			; FB
L24:	CALL	M,L24		; FC4212
				; ------------ Prefix
	CP	Imm_Bte		; FE12 ------- Official short style
	RST	0x38		; FF

; **************************************
;
; #CB prefixed z80 instructions
;
; **************************************

	RLC	B		; CB00
	RLC	C		; CB01
	RLC	D		; CB02
	RLC	E		; CB03
	RLC	H		; CB04
	RLC	L		; CB05
	RLC	(HL)		; CB06
	RLC	A		; CB07
	RRC	B		; CB08
	RRC	C		; CB09
	RRC	D		; CB0A
	RRC	E		; CB0B
	RRC	H		; CB0C
	RRC	L		; CB0D
	RRC	(HL)		; CB0E
	RRC	A		; CB0F
	RL	B		; CB10
	RL	C		; CB11
	RL	D		; CB12
	RL	E		; CB13
	RL	H		; CB14
	RL	L		; CB15
	RL	(HL)		; CB16
	RL	A		; CB17
	RR	B		; CB18
	RR	C		; CB19
	RR	D		; CB1A
	RR	E		; CB1B
	RR	H		; CB1C
	RR	L		; CB1D
	RR	(HL)		; CB1E
	RR	A		; CB1F
	SLA	B		; CB20
	SLA	C		; CB21
	SLA	D		; CB22
	SLA	E		; CB23
	SLA	H		; CB24
	SLA	L		; CB25
	SLA	(HL)		; CB26
	SLA	A		; CB27
	SRA	B		; CB28
	SRA	C		; CB29
	SRA	D		; CB2A
	SRA	E		; CB2B
	SRA	H		; CB2C
	SRA	L		; CB2D
	SRA	(HL)		; CB2E
	SRA	A		; CB2F
	SLL	B		; CB30 ------- Unofficial but documented
	SLL	C		; CB31 ------- Unofficial but documented
	SLL	D		; CB32 ------- Unofficial but documented
	SLL	E		; CB33 ------- Unofficial but documented
	SLL	H		; CB34 ------- Unofficial but documented
	SLL	L		; CB35 ------- Unofficial but documented
	SLL	(HL)		; CB36 ------- Unofficial but documented
	SLL	A		; CB37 ------- Unofficial but documented
	SRL	B		; CB38
	SRL	C		; CB39
	SRL	D		; CB3A
	SRL	E		; CB3B
	SRL	H		; CB3C
	SRL	L		; CB3D
	SRL	(HL)		; CB3E
	SRL	A		; CB3F
	BIT	0,B		; CB40
	BIT	0,C		; CB41
	BIT	0,D		; CB42
	BIT	0,E		; CB43
	BIT	0,H		; CB44
	BIT	0,L		; CB45
	BIT	0,(HL)		; CB46
	BIT	0,A		; CB47
	BIT	1,B		; CB48
	BIT	1,C		; CB49
	BIT	1,D		; CB4A
	BIT	1,E		; CB4B
	BIT	1,H		; CB4C
	BIT	1,L		; CB4D
	BIT	1,(HL)		; CB4E
	BIT	1,A		; CB4F
	BIT	2,B		; CB50
	BIT	2,C		; CB51
	BIT	2,D		; CB52
	BIT	2,E		; CB53
	BIT	2,H		; CB54
	BIT	2,L		; CB55
	BIT	2,(HL)		; CB56
	BIT	2,A		; CB57
	BIT	3,B		; CB58
	BIT	3,C		; CB59
	BIT	3,D		; CB5A
	BIT	3,E		; CB5B
	BIT	3,H		; CB5C
	BIT	3,L		; CB5D
	BIT	3,(HL)		; CB5E
	BIT	3,A		; CB5F
	BIT	4,B		; CB60
	BIT	4,C		; CB61
	BIT	4,D		; CB62
	BIT	4,E		; CB63
	BIT	4,H		; CB64
	BIT	4,L		; CB65
	BIT	4,(HL)		; CB66
	BIT	4,A		; CB67
	BIT	5,B		; CB68
	BIT	5,C		; CB69
	BIT	5,D		; CB6A
	BIT	5,E		; CB6B
	BIT	5,H		; CB6C
	BIT	5,L		; CB6D
	BIT	5,(HL)		; CB6E
	BIT	5,A		; CB6F
	BIT	6,B		; CB70
	BIT	6,C		; CB71
	BIT	6,D		; CB72
	BIT	6,E		; CB73
	BIT	6,H		; CB74
	BIT	6,L		; CB75
	BIT	6,(HL)		; CB76
	BIT	6,A		; CB77
	BIT	7,B		; CB78
	BIT	7,C		; CB79
	BIT	7,D		; CB7A
	BIT	7,E		; CB7B
	BIT	7,H		; CB7C
	BIT	7,L		; CB7D
	BIT	7,(HL)		; CB7E
	BIT	7,A		; CB7F
	RES	0,B		; CB80
	RES	0,C		; CB81
	RES	0,D		; CB82
	RES	0,E		; CB83
	RES	0,H		; CB84
	RES	0,L		; CB85
	RES	0,(HL)		; CB86
	RES	0,A		; CB87
	RES	1,B		; CB88
	RES	1,C		; CB89
	RES	1,D		; CB8A
	RES	1,E		; CB8B
	RES	1,H		; CB8C
	RES	1,L		; CB8D
	RES	1,(HL)		; CB8E
	RES	1,A		; CB8F
	RES	2,B		; CB90
	RES	2,C		; CB91
	RES	2,D		; CB92
	RES	2,E		; CB93
	RES	2,H		; CB94
	RES	2,L		; CB95
	RES	2,(HL)		; CB96
	RES	2,A		; CB97
	RES	3,B		; CB98
	RES	3,C		; CB99
	RES	3,D		; CB9A
	RES	3,E		; CB9B
	RES	3,H		; CB9C
	RES	3,L		; CB9D
	RES	3,(HL)		; CB9E
	RES	3,A		; CB9F
	RES	4,B		; CBA0
	RES	4,C		; CBA1
	RES	4,D		; CBA2
	RES	4,E		; CBA3
	RES	4,H		; CBA4
	RES	4,L		; CBA5
	RES	4,(HL)		; CBA6
	RES	4,A		; CBA7
	RES	5,B		; CBA8
	RES	5,C		; CBA9
	RES	5,D		; CBAA
	RES	5,E		; CBAB
	RES	5,H		; CBAC
	RES	5,L		; CBAD
	RES	5,(HL)		; CBAE
	RES	5,A		; CBAF
	RES	6,B		; CBB0
	RES	6,C		; CBB1
	RES	6,D		; CBB2
	RES	6,E		; CBB3
	RES	6,H		; CBB4
	RES	6,L		; CBB5
	RES	6,(HL)		; CBB6
	RES	6,A		; CBB7
	RES	7,B		; CBB8
	RES	7,C		; CBB9
	RES	7,D		; CBBA
	RES	7,E		; CBBB
	RES	7,H		; CBBC
	RES	7,L		; CBBD
	RES	7,(HL)		; CBBE
	RES	7,A		; CBBF
	SET	0,B		; CBC0
	SET	0,C		; CBC1
	SET	0,D		; CBC2
	SET	0,E		; CBC3
	SET	0,H		; CBC4
	SET	0,L		; CBC5
	SET	0,(HL)		; CBC6
	SET	0,A		; CBC7
	SET	1,B		; CBC8
	SET	1,C		; CBC9
	SET	1,D		; CBCA
	SET	1,E		; CBCB
	SET	1,H		; CBCC
	SET	1,L		; CBCD
	SET	1,(HL)		; CBCE
	SET	1,A		; CBCF
	SET	2,B		; CBD0
	SET	2,C		; CBD1
	SET	2,D		; CBD2
	SET	2,E		; CBD3
	SET	2,H		; CBD4
	SET	2,L		; CBD5
	SET	2,(HL)		; CBD6
	SET	2,A		; CBD7
	SET	3,B		; CBD8
	SET	3,C		; CBD9
	SET	3,D		; CBDA
	SET	3,E		; CBDB
	SET	3,H		; CBDC
	SET	3,L		; CBDD
	SET	3,(HL)		; CBDE
	SET	3,A		; CBDF
	SET	4,B		; CBE0
	SET	4,C		; CBE1
	SET	4,D		; CBE2
	SET	4,E		; CBE3
	SET	4,H		; CBE4
	SET	4,L		; CBE5
	SET	4,(HL)		; CBE6
	SET	4,A		; CBE7
	SET	5,B		; CBE8
	SET	5,C		; CBE9
	SET	5,D		; CBEA
	SET	5,E		; CBEB
	SET	5,H		; CBEC
	SET	5,L		; CBED
	SET	5,(HL)		; CBEE
	SET	5,A		; CBEF
	SET	6,B		; CBF0
	SET	6,C		; CBF1
	SET	6,D		; CBF2
	SET	6,E		; CBF3
	SET	6,H		; CBF4
	SET	6,L		; CBF5
	SET	6,(HL)		; CBF6
	SET	6,A		; CBF7
	SET	7,B		; CBF8
	SET	7,C		; CBF9
	SET	7,D		; CBFA
	SET	7,E		; CBFB
	SET	7,H		; CBFC
	SET	7,L		; CBFD
	SET	7,(HL)		; CBFE
	SET	7,A		; CBFF

; **************************************
;
; #DD prefixed z80 instructions
;
; **************************************

				; DD00 ------- Undocumented
				; DD01 ------- Undocumented
				; DD02 ------- Undocumented
				; DD03 ------- Undocumented
				; DD04 ------- Undocumented
				; DD05 ------- Undocumented
				; DD06 ------- Undocumented
				; DD07 ------- Undocumented
				; DD08 ------- Undocumented
	ADD	IX,BC		; DD09
				; DD0A ------- Undocumented
				; DD0B ------- Undocumented
				; DD0C ------- Undocumented
				; DD0D ------- Undocumented
				; DD0E ------- Undocumented
				; DD0F ------- Undocumented
				; DD10 ------- Undocumented
				; DD11 ------- Undocumented
				; DD12 ------- Undocumented
				; DD13 ------- Undocumented
				; DD14 ------- Undocumented
				; DD15 ------- Undocumented
				; DD16 ------- Undocumented
				; DD17 ------- Undocumented
				; DD18 ------- Undocumented
	ADD	IX,DE		; DD19
				; DD1A ------- Undocumented
				; DD1B ------- Undocumented
				; DD1C ------- Undocumented
				; DD1D ------- Undocumented
				; DD1E ------- Undocumented
				; DD1F ------- Undocumented
				; DD20 ------- Undocumented
	LD	IX,Imm_Wrd	; DD214523
	LD	(Space),IX	; DD220010
	INC	IX		; DD23
	INC	IXH		; DD24 ------- Unofficial but documented
	DEC	IXH		; DD25 ------- Unofficial but documented
	LD	IXH,Imm_Bte	; DD2612 ----- Unofficial but documented
				; DD27 ------- Undocumented
				; DD28 ------- Undocumented
	ADD	IX,IX		; DD29
	LD	IX,(Space)	; DD2A0010
	DEC	IX		; DD2B
	INC	IXL		; DD2C ------- Unofficial but documented
	DEC	IXL		; DD2D ------- Unofficial but documented
	LD	IXL,Imm_Bte	; DD2E12 ----- Unofficial but documented
				; DD2F ------- Undocumented
				; DD30 ------- Undocumented
				; DD31 ------- Undocumented
				; DD32 ------- Undocumented
				; DD33 ------- Undocumented
	INC	(IX+Displ)	; DD3445
	DEC	(IX+Displ)	; DD3545
				; DD36 ------- Undocumented
				; DD37 ------- Undocumented
				; DD38 ------- Undocumented
	ADD	IX,SP		; DD39
				; DD3A ------- Undocumented
				; DD3B ------- Undocumented
				; DD3C ------- Undocumented
				; DD3D ------- Undocumented
				; DD3E ------- Undocumented
				; DD3F ------- Undocumented
				; DD40 ------- Undocumented
				; DD41 ------- Undocumented
				; DD42 ------- Undocumented
				; DD43 ------- Undocumented
	LD	B,IXH		; DD44 ------- Unofficial but documented
	LD	B,IXL		; DD45 ------- Unofficial but documented
	LD	B,(IX+Displ)	; DD4645
				; DD47 ------- Undocumented
				; DD48 ------- Undocumented
				; DD49 ------- Undocumented
				; DD4A ------- Undocumented
				; DD4B ------- Undocumented
	LD	C,IXH		; DD4C ------- Unofficial but documented
	LD	C,IXL		; DD4D ------- Unofficial but documented
	LD	C,(IX+Displ)	; DD4E45
				; DD4F ------- Undocumented
				; DD50 ------- Undocumented
				; DD51 ------- Undocumented
				; DD52 ------- Undocumented
				; DD53 ------- Undocumented
	LD	D,IXH		; DD54 ------- Unofficial but documented
	LD	D,IXL		; DD55 ------- Unofficial but documented
	LD	D,(IX+Displ)	; DD5645
				; DD57 ------- Undocumented
				; DD58 ------- Undocumented
				; DD59 ------- Undocumented
				; DD5A ------- Undocumented
				; DD5B ------- Undocumented
	LD	E,IXH		; DD5C ------- Unofficial but documented
	LD	E,IXL		; DD5D ------- Unofficial but documented
	LD	E,(IX+Displ)	; DD5E45
				; DD5F ------- Undocumented
	LD	IXH,B		; DD60 ------- Unofficial but documented
	LD	IXH,C		; DD61 ------- Unofficial but documented
	LD	IXH,D		; DD62 ------- Unofficial but documented
	LD	IXH,E		; DD63 ------- Unofficial but documented
	LD	IXH,IXH		; DD64 ------- Unofficial but documented
	LD	IXH,IXL		; DD65 ------- Unofficial but documented
	LD	H,(IX+Displ)	; DD6645
	LD	IXH,A		; DD67 ------- Unofficial but documented
	LD	IXL,B		; DD68 ------- Unofficial but documented
	LD	IXL,C		; DD69 ------- Unofficial but documented
	LD	IXL,D		; DD6A ------- Unofficial but documented
	LD	IXL,E		; DD6B ------- Unofficial but documented
	LD	IXL,IXH		; DD6C ------- Unofficial but documented
	LD	IXL,IXL		; DD6D ------- Unofficial but documented
	LD	L,(IX+Displ)	; DD6E45
	LD	IXL,A		; DD6F ------- Unofficial but documented
	LD	(IX+Displ),B	; DD7045
	LD	(IX+Displ),C	; DD7145
	LD	(IX+Displ),D	; DD7245
	LD	(IX+Displ),E	; DD7345
	LD	(IX+Displ),H	; DD7445
	LD	(IX+Displ),L	; DD7545
				; DD76 ------- Undocumented
	LD	(IX+Displ),A	; DD7745
				; DD78 ------- Undocumented
				; DD79 ------- Undocumented
				; DD7A ------- Undocumented
				; DD7B ------- Undocumented
	LD	A,IXH		; DD7C ------- Unofficial but documented
	LD	A,IXL		; DD7D ------- Unofficial but documented
	LD	A,(IX+Displ)	; DD7E45
				; DD7F ------- Undocumented
				; DD80 ------- Undocumented
				; DD81 ------- Undocumented
				; DD82 ------- Undocumented
				; DD83 ------- Undocumented
	ADD	A,IXH		; DD84 ------- Unofficial but documented, official long style
	ADD	A,IXL		; DD85 ------- Unofficial but documented, official long style
	ADD	A,(IX+Displ)	; DD8645
				; DD87 ------- Undocumented
				; DD88 ------- Undocumented
				; DD89 ------- Undocumented
				; DD8A ------- Undocumented
				; DD8B ------- Undocumented
	ADC	A,IXH		; DD8C ------- Unofficial but documented, official long style
	ADC	A,IXL		; DD8D ------- Unofficial but documented, official long style
	ADC	A,(IX+Displ)	; DD8E45
				; DD8F ------- Undocumented
				; DD90 ------- Undocumented
				; DD91 ------- Undocumented
				; DD92 ------- Undocumented
				; DD93 ------- Undocumented
	SUB	IXH		; DD94 ------- Unofficial but documented, official short style
	SUB	IXL		; DD95 ------- Unofficial but documented, official short style
	SUB	(IX+Displ)	; DD9645
				; DD97 ------- Undocumented
				; DD98 ------- Undocumented
				; DD99 ------- Undocumented
				; DD9A ------- Undocumented
				; DD9B ------- Undocumented
	SBC	A,IXH		; DD9C ------- Unofficial but documented, official long style
	SBC	A,IXL		; DD9D ------- Unofficial but documented, official long style
	SBC	(IX+Displ)	; DD9E45
				; DD9F ------- Undocumented
				; DDA0 ------- Undocumented
				; DDA1 ------- Undocumented
				; DDA2 ------- Undocumented
				; DDA3 ------- Undocumented
	AND	IXH		; DDA4 ------- Unofficial but documented, official short style
	AND	IXL		; DDA5 ------- Unofficial but documented, official short style
	AND	(IX+Displ)	; DDA645
				; DDA7 ------- Undocumented
				; DDA8 ------- Undocumented
				; DDA9 ------- Undocumented
				; DDAA ------- Undocumented
				; DDAB ------- Undocumented
	XOR	IXH		; DDAC ------- Unofficial but documented, official short style
	XOR	IXL		; DDAD ------- Unofficial but documented, official short style
	XOR	(IX+Displ)	; DDAE45
				; DDAF ------- Undocumented
				; DDB0 ------- Undocumented
				; DDB1 ------- Undocumented
				; DDB2 ------- Undocumented
				; DDB3 ------- Undocumented
	OR	IXH		; DDB4 ------- Unofficial but documented, official short style
	OR	IXL		; DDB5 ------- Unofficial but documented, official short style
	OR	(IX+Displ)	; DDB645
				; DDB7 ------- Undocumented
				; DDB8 ------- Undocumented
				; DDB9 ------- Undocumented
				; DDBA ------- Undocumented
				; DDBB ------- Undocumented
	CP	IXH		; DDBC ------- Unofficial but documented, official short style
	CP	IXL		; DDBD ------- Unofficial but documented, official short style
	CP	(IX+Displ)	; DDBE45
				; DDBF ------- Undocumented
				; DDC0 ------- Undocumented
				; DDC1 ------- Undocumented
				; DDC2 ------- Undocumented
				; DDC3 ------- Undocumented
				; DDC4 ------- Undocumented
				; DDC5 ------- Undocumented
				; DDC6 ------- Undocumented
				; DDC7 ------- Undocumented
				; DDC8 ------- Undocumented
				; DDC9 ------- Undocumented
				; DDCA ------- Undocumented
				; DDCB ------- Prefix
				; DDCC ------- Undocumented
				; DDCD ------- Undocumented
				; DDCE ------- Undocumented
				; DDCF ------- Undocumented
				; DDD0 ------- Undocumented
				; DDD1 ------- Undocumented
				; DDD2 ------- Undocumented
				; DDD3 ------- Undocumented
				; DDD4 ------- Undocumented
				; DDD5 ------- Undocumented
				; DDD6 ------- Undocumented
				; DDD7 ------- Undocumented
				; DDD8 ------- Undocumented
				; DDD9 ------- Undocumented
				; DDDA ------- Undocumented
				; DDDB ------- Undocumented
				; DDDC ------- Undocumented
				; DDDD ------- Undocumented
				; DDDE ------- Undocumented
				; DDDF ------- Undocumented
				; DDE0 ------- Undocumented
	POP	IX		; DDE1
				; DDE2 ------- Undocumented
	EX	(SP),IX		; DDE3
				; DDE4 ------- Undocumented
	PUSH	IX		; DDE5
				; DDE6 ------- Undocumented
				; DDE7 ------- Undocumented
				; DDE8 ------- Undocumented
	JP	(IX)		; DDE9
				; DDEA ------- Undocumented
				; DDEB ------- Undocumented
				; DDEC ------- Undocumented
				; DDED ------- Prefix
				; DDEE ------- Undocumented
				; DDEF ------- Undocumented
				; DDF0 ------- Undocumented
				; DDF1 ------- Undocumented
				; DDF2 ------- Undocumented
				; DDF3 ------- Undocumented
				; DDF4 ------- Undocumented
				; DDF5 ------- Undocumented
				; DDF6 ------- Undocumented
				; DDF7 ------- Undocumented
				; DDF8 ------- Undocumented
	LD	SP,IX		; DDF9
				; DDFA ------- Undocumented
				; DDFB ------- Undocumented
				; DDFC ------- Undocumented
				; DDFD ------- Undocumented
				; DDFE ------- Undocumented
				; DDFF ------- Undocumented

; **************************************
;
; #DDCB prefixed z80 instructions
;
; **************************************

	RLC	(IX+Displ),B	; DDCB4500 --- Unofficial but documented
	RLC	(IX+Displ),C	; DDCB4501 --- Unofficial but documented
	RLC	(IX+Displ),D	; DDCB4502 --- Unofficial but documented
	RLC	(IX+Displ),E	; DDCB4503 --- Unofficial but documented
	RLC	(IX+Displ),H	; DDCB4504 --- Unofficial but documented
	RLC	(IX+Displ),L	; DDCB4505 --- Unofficial but documented
	RLC	(IX+Displ)	; DDCB4506
	RLC	(IX+Displ),A	; DDCB4507 --- Unofficial but documented
	RRC	(IX+Displ),B	; DDCB4508 --- Unofficial but documented
	RRC	(IX+Displ),C	; DDCB4509 --- Unofficial but documented
	RRC	(IX+Displ),D	; DDCB450A --- Unofficial but documented
	RRC	(IX+Displ),E	; DDCB450B --- Unofficial but documented
	RRC	(IX+Displ),H	; DDCB450C --- Unofficial but documented
	RRC	(IX+Displ),L	; DDCB450D --- Unofficial but documented
	RRC	(IX+Displ)	; DDCB450E
	RRC	(IX+Displ),A	; DDCB450F --- Unofficial but documented
	RL	(IX+Displ),B	; DDCB4510 --- Unofficial but documented
	RL	(IX+Displ),C	; DDCB4511 --- Unofficial but documented
	RL	(IX+Displ),D	; DDCB4512 --- Unofficial but documented
	RL	(IX+Displ),E	; DDCB4513 --- Unofficial but documented
	RL	(IX+Displ),H	; DDCB4514 --- Unofficial but documented
	RL	(IX+Displ),L	; DDCB4515 --- Unofficial but documented
	RL	(IX+Displ)	; DDCB4516
	RL	(IX+Displ),A	; DDCB4517 --- Unofficial but documented
	RR	(IX+Displ),B	; DDCB4518 --- Unofficial but documented
	RR	(IX+Displ),C	; DDCB4519 --- Unofficial but documented
	RR	(IX+Displ),D	; DDCB451A --- Unofficial but documented
	RR	(IX+Displ),E	; DDCB451B --- Unofficial but documented
	RR	(IX+Displ),H	; DDCB451C --- Unofficial but documented
	RR	(IX+Displ),L	; DDCB451D --- Unofficial but documented
	RR	(IX+Displ)	; DDCB451E
	RR	(IX+Displ),A	; DDCB451F --- Unofficial but documented
	SLA	(IX+Displ),B	; DDCB4520 --- Unofficial but documented
	SLA	(IX+Displ),C	; DDCB4521 --- Unofficial but documented
	SLA	(IX+Displ),D	; DDCB4522 --- Unofficial but documented
	SLA	(IX+Displ),E	; DDCB4523 --- Unofficial but documented
	SLA	(IX+Displ),H	; DDCB4524 --- Unofficial but documented
	SLA	(IX+Displ),L	; DDCB4525 --- Unofficial but documented
	SLA	(IX+Displ)	; DDCB4526
	SLA	(IX+Displ),A	; DDCB4527 --- Unofficial but documented
	SRA	(IX+Displ),B	; DDCB4528 --- Unofficial but documented
	SRA	(IX+Displ),C	; DDCB4529 --- Unofficial but documented
	SRA	(IX+Displ),D	; DDCB452A --- Unofficial but documented
	SRA	(IX+Displ),E	; DDCB452B --- Unofficial but documented
	SRA	(IX+Displ),H	; DDCB452C --- Unofficial but documented
	SRA	(IX+Displ),L	; DDCB452D --- Unofficial but documented
	SRA	(IX+Displ)	; DDCB452E
	SRA	(IX+Displ),A	; DDCB452F --- Unofficial but documented
	SLL	(IX+Displ),B	; DDCB4530 --- Unofficial but documented
	SLL	(IX+Displ),C	; DDCB4531 --- Unofficial but documented
	SLL	(IX+Displ),D	; DDCB4532 --- Unofficial but documented
	SLL	(IX+Displ),E	; DDCB4533 --- Unofficial but documented
	SLL	(IX+Displ),H	; DDCB4534 --- Unofficial but documented
	SLL	(IX+Displ),L	; DDCB4535 --- Unofficial but documented
	SLL	(IX+Displ)	; DDCB4536 --- Unofficial but documented
	SLL	(IX+Displ),A	; DDCB4537 --- Unofficial but documented
	SRL	(IX+Displ),B	; DDCB4538 --- Unofficial but documented
	SRL	(IX+Displ),C	; DDCB4539 --- Unofficial but documented
	SRL	(IX+Displ),D	; DDCB453A --- Unofficial but documented
	SRL	(IX+Displ),E	; DDCB453B --- Unofficial but documented
	SRL	(IX+Displ),H	; DDCB453C --- Unofficial but documented
	SRL	(IX+Displ),L	; DDCB453D --- Unofficial but documented
	SRL	(IX+Displ)	; DDCB453E
	SRL	(IX+Displ),A	; DDCB453F --- Unofficial but documented
	BIT	0,(IX+Displ),B	; DDCB4540 --- Unofficial but documented
	BIT	0,(IX+Displ),C	; DDCB4541 --- Unofficial but documented
	BIT	0,(IX+Displ),D	; DDCB4542 --- Unofficial but documented
	BIT	0,(IX+Displ),E	; DDCB4543 --- Unofficial but documented
	BIT	0,(IX+Displ),H	; DDCB4544 --- Unofficial but documented
	BIT	0,(IX+Displ),L	; DDCB4545 --- Unofficial but documented
	BIT	0,(IX+Displ)	; DDCB4546
	BIT	0,(IX+Displ),A	; DDCB4547 --- Unofficial but documented
	BIT	1,(IX+Displ),B	; DDCB4548 --- Unofficial but documented
	BIT	1,(IX+Displ),C	; DDCB4549 --- Unofficial but documented
	BIT	1,(IX+Displ),D	; DDCB454A --- Unofficial but documented
	BIT	1,(IX+Displ),E	; DDCB454B --- Unofficial but documented
	BIT	1,(IX+Displ),H	; DDCB454C --- Unofficial but documented
	BIT	1,(IX+Displ),L	; DDCB454D --- Unofficial but documented
	BIT	1,(IX+Displ)	; DDCB454E
	BIT	1,(IX+Displ),A	; DDCB454F --- Unofficial but documented
	BIT	2,(IX+Displ),B	; DDCB4550 --- Unofficial but documented
	BIT	2,(IX+Displ),C	; DDCB4551 --- Unofficial but documented
	BIT	2,(IX+Displ),D	; DDCB4552 --- Unofficial but documented
	BIT	2,(IX+Displ),E	; DDCB4553 --- Unofficial but documented
	BIT	2,(IX+Displ),H	; DDCB4554 --- Unofficial but documented
	BIT	2,(IX+Displ),L	; DDCB4555 --- Unofficial but documented
	BIT	2,(IX+Displ)	; DDCB4556
	BIT	2,(IX+Displ),A	; DDCB4557 --- Unofficial but documented
	BIT	3,(IX+Displ),B	; DDCB4558 --- Unofficial but documented
	BIT	3,(IX+Displ),C	; DDCB4559 --- Unofficial but documented
	BIT	3,(IX+Displ),D	; DDCB455A --- Unofficial but documented
	BIT	3,(IX+Displ),E	; DDCB455B --- Unofficial but documented
	BIT	3,(IX+Displ),H	; DDCB455C --- Unofficial but documented
	BIT	3,(IX+Displ),L	; DDCB455D --- Unofficial but documented
	BIT	3,(IX+Displ)	; DDCB455E
	BIT	3,(IX+Displ),A	; DDCB455F --- Unofficial but documented
	BIT	4,(IX+Displ),B	; DDCB4560 --- Unofficial but documented
	BIT	4,(IX+Displ),C	; DDCB4561 --- Unofficial but documented
	BIT	4,(IX+Displ),D	; DDCB4562 --- Unofficial but documented
	BIT	4,(IX+Displ),E	; DDCB4563 --- Unofficial but documented
	BIT	4,(IX+Displ),H	; DDCB4564 --- Unofficial but documented
	BIT	4,(IX+Displ),L	; DDCB4565 --- Unofficial but documented
	BIT	4,(IX+Displ)	; DDCB4566
	BIT	4,(IX+Displ),A	; DDCB4567 --- Unofficial but documented
	BIT	5,(IX+Displ),B	; DDCB4568 --- Unofficial but documented
	BIT	5,(IX+Displ),C	; DDCB4569 --- Unofficial but documented
	BIT	5,(IX+Displ),D	; DDCB456A --- Unofficial but documented
	BIT	5,(IX+Displ),E	; DDCB456B --- Unofficial but documented
	BIT	5,(IX+Displ),H	; DDCB456C --- Unofficial but documented
	BIT	5,(IX+Displ),L	; DDCB456D --- Unofficial but documented
	BIT	5,(IX+Displ)	; DDCB456E
	BIT	5,(IX+Displ),A	; DDCB456F --- Unofficial but documented
	BIT	6,(IX+Displ),B	; DDCB4570 --- Unofficial but documented
	BIT	6,(IX+Displ),C	; DDCB4571 --- Unofficial but documented
	BIT	6,(IX+Displ),D	; DDCB4572 --- Unofficial but documented
	BIT	6,(IX+Displ),E	; DDCB4573 --- Unofficial but documented
	BIT	6,(IX+Displ),H	; DDCB4574 --- Unofficial but documented
	BIT	6,(IX+Displ),L	; DDCB4575 --- Unofficial but documented
	BIT	6,(IX+Displ)	; DDCB4576
	BIT	6,(IX+Displ),A	; DDCB4577 --- Unofficial but documented
	BIT	7,(IX+Displ),B	; DDCB4578 --- Unofficial but documented
	BIT	7,(IX+Displ),C	; DDCB4579 --- Unofficial but documented
	BIT	7,(IX+Displ),D	; DDCB457A --- Unofficial but documented
	BIT	7,(IX+Displ),E	; DDCB457B --- Unofficial but documented
	BIT	7,(IX+Displ),H	; DDCB457C --- Unofficial but documented
	BIT	7,(IX+Displ),L	; DDCB457D --- Unofficial but documented
	BIT	7,(IX+Displ)	; DDCB457E
	BIT	7,(IX+Displ),A	; DDCB457F --- Unofficial but documented
	RES	0,(IX+Displ),B	; DDCB4580 --- Unofficial but documented
	RES	0,(IX+Displ),C	; DDCB4581 --- Unofficial but documented
	RES	0,(IX+Displ),D	; DDCB4582 --- Unofficial but documented
	RES	0,(IX+Displ),E	; DDCB4583 --- Unofficial but documented
	RES	0,(IX+Displ),H	; DDCB4584 --- Unofficial but documented
	RES	0,(IX+Displ),L	; DDCB4585 --- Unofficial but documented
	RES	0,(IX+Displ)	; DDCB4586
	RES	0,(IX+Displ),A	; DDCB4587 --- Unofficial but documented
	RES	1,(IX+Displ),B	; DDCB4588 --- Unofficial but documented
	RES	1,(IX+Displ),C	; DDCB4589 --- Unofficial but documented
	RES	1,(IX+Displ),D	; DDCB458A --- Unofficial but documented
	RES	1,(IX+Displ),E	; DDCB458B --- Unofficial but documented
	RES	1,(IX+Displ),H	; DDCB458C --- Unofficial but documented
	RES	1,(IX+Displ),L	; DDCB458D --- Unofficial but documented
	RES	1,(IX+Displ)	; DDCB458E
	RES	1,(IX+Displ),A	; DDCB458F --- Unofficial but documented
	RES	2,(IX+Displ),B	; DDCB4590 --- Unofficial but documented
	RES	2,(IX+Displ),C	; DDCB4591 --- Unofficial but documented
	RES	2,(IX+Displ),D	; DDCB4592 --- Unofficial but documented
	RES	2,(IX+Displ),E	; DDCB4593 --- Unofficial but documented
	RES	2,(IX+Displ),H	; DDCB4594 --- Unofficial but documented
	RES	2,(IX+Displ),L	; DDCB4595 --- Unofficial but documented
	RES	2,(IX+Displ)	; DDCB4596
	RES	2,(IX+Displ),A	; DDCB4597 --- Unofficial but documented
	RES	3,(IX+Displ),B	; DDCB4598 --- Unofficial but documented
	RES	3,(IX+Displ),C	; DDCB4599 --- Unofficial but documented
	RES	3,(IX+Displ),D	; DDCB459A --- Unofficial but documented
	RES	3,(IX+Displ),E	; DDCB459B --- Unofficial but documented
	RES	3,(IX+Displ),H	; DDCB459C --- Unofficial but documented
	RES	3,(IX+Displ),L	; DDCB459D --- Unofficial but documented
	RES	3,(IX+Displ)	; DDCB459E
	RES	3,(IX+Displ),A	; DDCB459F --- Unofficial but documented
	RES	4,(IX+Displ),B	; DDCB45A0 --- Unofficial but documented
	RES	4,(IX+Displ),C	; DDCB45A1 --- Unofficial but documented
	RES	4,(IX+Displ),D	; DDCB45A2 --- Unofficial but documented
	RES	4,(IX+Displ),E	; DDCB45A3 --- Unofficial but documented
	RES	4,(IX+Displ),H	; DDCB45A4 --- Unofficial but documented
	RES	4,(IX+Displ),L	; DDCB45A5 --- Unofficial but documented
	RES	4,(IX+Displ)	; DDCB45A6
	RES	4,(IX+Displ),A	; DDCB45A7 --- Unofficial but documented
	RES	5,(IX+Displ),B	; DDCB45A8 --- Unofficial but documented
	RES	5,(IX+Displ),C	; DDCB45A9 --- Unofficial but documented
	RES	5,(IX+Displ),D	; DDCB45AA --- Unofficial but documented
	RES	5,(IX+Displ),E	; DDCB45AB --- Unofficial but documented
	RES	5,(IX+Displ),H	; DDCB45AC --- Unofficial but documented
	RES	5,(IX+Displ),L	; DDCB45AD --- Unofficial but documented
	RES	5,(IX+Displ)	; DDCB45AE
	RES	5,(IX+Displ),A	; DDCB45AF --- Unofficial but documented
	RES	6,(IX+Displ),B	; DDCB45B0 --- Unofficial but documented
	RES	6,(IX+Displ),C	; DDCB45B1 --- Unofficial but documented
	RES	6,(IX+Displ),D	; DDCB45B2 --- Unofficial but documented
	RES	6,(IX+Displ),E	; DDCB45B3 --- Unofficial but documented
	RES	6,(IX+Displ),H	; DDCB45B4 --- Unofficial but documented
	RES	6,(IX+Displ),L	; DDCB45B5 --- Unofficial but documented
	RES	6,(IX+Displ)	; DDCB45B6
	RES	6,(IX+Displ),A	; DDCB45B7 --- Unofficial but documented
	RES	7,(IX+Displ),B	; DDCB45B8 --- Unofficial but documented
	RES	7,(IX+Displ),C	; DDCB45B9 --- Unofficial but documented
	RES	7,(IX+Displ),D	; DDCB45BA --- Unofficial but documented
	RES	7,(IX+Displ),E	; DDCB45BB --- Unofficial but documented
	RES	7,(IX+Displ),H	; DDCB45BC --- Unofficial but documented
	RES	7,(IX+Displ),L	; DDCB45BD --- Unofficial but documented
	RES	7,(IX+Displ)	; DDCB45BE
	RES	7,(IX+Displ),A	; DDCB45BF --- Unofficial but documented
	SET	0,(IX+Displ),B	; DDCB45C0 --- Unofficial but documented
	SET	0,(IX+Displ),C	; DDCB45C1 --- Unofficial but documented
	SET	0,(IX+Displ),D	; DDCB45C2 --- Unofficial but documented
	SET	0,(IX+Displ),E	; DDCB45C3 --- Unofficial but documented
	SET	0,(IX+Displ),H	; DDCB45C4 --- Unofficial but documented
	SET	0,(IX+Displ),L	; DDCB45C5 --- Unofficial but documented
	SET	0,(IX+Displ)	; DDCB45C6
	SET	0,(IX+Displ),A	; DDCB45C7 --- Unofficial but documented
	SET	1,(IX+Displ),B	; DDCB45C8 --- Unofficial but documented
	SET	1,(IX+Displ),C	; DDCB45C9 --- Unofficial but documented
	SET	1,(IX+Displ),D	; DDCB45CA --- Unofficial but documented
	SET	1,(IX+Displ),E	; DDCB45CB --- Unofficial but documented
	SET	1,(IX+Displ),H	; DDCB45CC --- Unofficial but documented
	SET	1,(IX+Displ),L	; DDCB45CD --- Unofficial but documented
	SET	1,(IX+Displ)	; DDCB45CE
	SET	1,(IX+Displ),A	; DDCB45CF --- Unofficial but documented
	SET	2,(IX+Displ),B	; DDCB45D0 --- Unofficial but documented
	SET	2,(IX+Displ),C	; DDCB45D1 --- Unofficial but documented
	SET	2,(IX+Displ),D	; DDCB45D2 --- Unofficial but documented
	SET	2,(IX+Displ),E	; DDCB45D3 --- Unofficial but documented
	SET	2,(IX+Displ),H	; DDCB45D4 --- Unofficial but documented
	SET	2,(IX+Displ),L	; DDCB45D5 --- Unofficial but documented
	SET	2,(IX+Displ)	; DDCB45D6
	SET	2,(IX+Displ),A	; DDCB45D7 --- Unofficial but documented
	SET	3,(IX+Displ),B	; DDCB45D8 --- Unofficial but documented
	SET	3,(IX+Displ),C	; DDCB45D9 --- Unofficial but documented
	SET	3,(IX+Displ),D	; DDCB45DA --- Unofficial but documented
	SET	3,(IX+Displ),E	; DDCB45DB --- Unofficial but documented
	SET	3,(IX+Displ),H	; DDCB45DC --- Unofficial but documented
	SET	3,(IX+Displ),L	; DDCB45DD --- Unofficial but documented
	SET	3,(IX+Displ)	; DDCB45DE
	SET	3,(IX+Displ),A	; DDCB45DF --- Unofficial but documented
	SET	4,(IX+Displ),B	; DDCB45E0 --- Unofficial but documented
	SET	4,(IX+Displ),C	; DDCB45E1 --- Unofficial but documented
	SET	4,(IX+Displ),D	; DDCB45E2 --- Unofficial but documented
	SET	4,(IX+Displ),E	; DDCB45E3 --- Unofficial but documented
	SET	4,(IX+Displ),H	; DDCB45E4 --- Unofficial but documented
	SET	4,(IX+Displ),L	; DDCB45E5 --- Unofficial but documented
	SET	4,(IX+Displ)	; DDCB45E6
	SET	4,(IX+Displ),A	; DDCB45E7 --- Unofficial but documented
	SET	5,(IX+Displ),B	; DDCB45E8 --- Unofficial but documented
	SET	5,(IX+Displ),C	; DDCB45E9 --- Unofficial but documented
	SET	5,(IX+Displ),D	; DDCB45EA --- Unofficial but documented
	SET	5,(IX+Displ),E	; DDCB45EB --- Unofficial but documented
	SET	5,(IX+Displ),H	; DDCB45EC --- Unofficial but documented
	SET	5,(IX+Displ),L	; DDCB45ED --- Unofficial but documented
	SET	5,(IX+Displ)	; DDCB45EE
	SET	5,(IX+Displ),A	; DDCB45EF --- Unofficial but documented
	SET	6,(IX+Displ),B	; DDCB45F0 --- Unofficial but documented
	SET	6,(IX+Displ),C	; DDCB45F1 --- Unofficial but documented
	SET	6,(IX+Displ),D	; DDCB45F2 --- Unofficial but documented
	SET	6,(IX+Displ),E	; DDCB45F3 --- Unofficial but documented
	SET	6,(IX+Displ),H	; DDCB45F4 --- Unofficial but documented
	SET	6,(IX+Displ),L	; DDCB45F5 --- Unofficial but documented
	SET	6,(IX+Displ)	; DDCB45F6
	SET	6,(IX+Displ),A	; DDCB45F7 --- Unofficial but documented
	SET	7,(IX+Displ),B	; DDCB45F8 --- Unofficial but documented
	SET	7,(IX+Displ),C	; DDCB45F9 --- Unofficial but documented
	SET	7,(IX+Displ),D	; DDCB45FA --- Unofficial but documented
	SET	7,(IX+Displ),E	; DDCB45FB --- Unofficial but documented
	SET	7,(IX+Displ),H	; DDCB45FC --- Unofficial but documented
	SET	7,(IX+Displ),L	; DDCB45FD --- Unofficial but documented
	SET	7,(IX+Displ)	; DDCB45FE
	SET	7,(IX+Displ),A	; DDCB45FF --- Unofficial but documented

; **************************************
;
; #ED prefixed z80 instructions
;
; **************************************

				; ED00 ------- Undocumented
				; ED01 ------- Undocumented
				; ED02 ------- Undocumented
				; ED03 ------- Undocumented
				; ED04 ------- Undocumented
				; ED05 ------- Undocumented
				; ED06 ------- Undocumented
				; ED07 ------- Undocumented
				; ED08 ------- Undocumented
				; ED09 ------- Undocumented
				; ED0A ------- Undocumented
				; ED0B ------- Undocumented
				; ED0C ------- Undocumented
				; ED0D ------- Undocumented
				; ED0E ------- Undocumented
				; ED0F ------- Undocumented
				; ED10 ------- Undocumented
				; ED11 ------- Undocumented
				; ED12 ------- Undocumented
				; ED13 ------- Undocumented
				; ED14 ------- Undocumented
				; ED15 ------- Undocumented
				; ED16 ------- Undocumented
				; ED17 ------- Undocumented
				; ED18 ------- Undocumented
				; ED19 ------- Undocumented
				; ED1A ------- Undocumented
				; ED1B ------- Undocumented
				; ED1C ------- Undocumented
				; ED1D ------- Undocumented
				; ED1E ------- Undocumented
				; ED1F ------- Undocumented
				; ED20 ------- Undocumented
				; ED21 ------- Undocumented
				; ED22 ------- Undocumented
				; ED23 ------- Undocumented
				; ED24 ------- Undocumented
				; ED25 ------- Undocumented
				; ED26 ------- Undocumented
				; ED27 ------- Undocumented
				; ED28 ------- Undocumented
				; ED29 ------- Undocumented
				; ED2A ------- Undocumented
				; ED2B ------- Undocumented
				; ED2C ------- Undocumented
				; ED2D ------- Undocumented
				; ED2E ------- Undocumented
				; ED2F ------- Undocumented
				; ED30 ------- Undocumented
				; ED31 ------- Undocumented
				; ED32 ------- Undocumented
				; ED33 ------- Undocumented
				; ED34 ------- Undocumented
				; ED35 ------- Undocumented
				; ED36 ------- Undocumented
				; ED37 ------- Undocumented
				; ED38 ------- Undocumented
				; ED39 ------- Undocumented
				; ED3A ------- Undocumented
				; ED3B ------- Undocumented
				; ED3C ------- Undocumented
				; ED3D ------- Undocumented
				; ED3E ------- Undocumented
				; ED3F ------- Undocumented
	IN	B,(C)		; ED40
	OUT	(C),B		; ED41
	SBC	HL,BC		; ED42
	LD	(Space),BC	; ED430010
	NEG			; ED44
	RETN			; ED45
	IM	0		; ED46
	LD	I,A		; ED47
	IN	C,(C)		; ED48
	OUT	(C),C		; ED49
	ADC	HL,BC		; ED4A
	LD	BC,(Space)	; ED4B0010
				; ED4C ------- Undocumented
	RETI			; ED4D
				; ED4E ------- Undocumented
	LD	R,A		; ED4F
	IN	D,(C)		; ED50
	OUT	(C),D		; ED51
	SBC	HL,DE		; ED52
	LD	(Space),DE	; ED530010
				; ED54 ------- Undocumented
				; ED55 ------- Undocumented
	IM	1		; ED56
	LD	A,I		; ED57
	IN	E,(C)		; ED58
	OUT	(C),E		; ED59
	ADC	HL,DE		; ED5A
	LD	DE,(Space)	; ED5B0010
				; ED5C ------- Undocumented
				; ED5D ------- Undocumented
	IM	2		; ED5E
	LD	A,R		; ED5F
	IN	H,(C)		; ED60
	OUT	(C),H		; ED61
	SBC	HL,HL		; ED62
				; ED63 ------- Undocumented
				; ED64 ------- Undocumented
				; ED65 ------- Undocumented
				; ED66 ------- Undocumented
	RRD			; ED67
	IN	L,(C)		; ED68
	OUT	(C),L		; ED69
	ADC	HL,HL		; ED6A
				; ED6B ------- Undocumented
				; ED6C ------- Undocumented
				; ED6D ------- Undocumented
				; ED6E ------- Undocumented
	RLD			; ED6F
	IN	(C)		; ED70 ------- Unofficial but documented
	OUT	(C),0		; ED71 ------- Unofficial but documented - zasm CRASHES!
	SBC	HL,SP		; ED72
	LD	(Space),SP	; ED730010
				; ED74 ------- Undocumented
				; ED75 ------- Undocumented
				; ED76 ------- Undocumented
				; ED77 ------- Undocumented
	IN	A,(C)		; ED78
	OUT	(C),A		; ED79
	ADC	HL,SP		; ED7A
	LD	SP,(Space)	; ED7B0010
				; ED7C ------- Undocumented
				; ED7D ------- Undocumented
				; ED7E ------- Undocumented
				; ED7F ------- Undocumented
				; ED80 ------- Undocumented
				; ED81 ------- Undocumented
				; ED82 ------- Undocumented
				; ED83 ------- Undocumented
				; ED84 ------- Undocumented
				; ED85 ------- Undocumented
				; ED86 ------- Undocumented
				; ED87 ------- Undocumented
				; ED88 ------- Undocumented
				; ED89 ------- Undocumented
				; ED8A ------- Undocumented
				; ED8B ------- Undocumented
				; ED8C ------- Undocumented
				; ED8D ------- Undocumented
				; ED8E ------- Undocumented
				; ED8F ------- Undocumented
				; ED90 ------- Undocumented
				; ED91 ------- Undocumented
				; ED92 ------- Undocumented
				; ED93 ------- Undocumented
				; ED94 ------- Undocumented
				; ED95 ------- Undocumented
				; ED96 ------- Undocumented
				; ED97 ------- Undocumented
				; ED98 ------- Undocumented
				; ED99 ------- Undocumented
				; ED9A ------- Undocumented
				; ED9B ------- Undocumented
				; ED9C ------- Undocumented
				; ED9D ------- Undocumented
				; ED9E ------- Undocumented
				; ED9F ------- Undocumented
	LDI			; EDA0
	CPI			; EDA1
	INI			; EDA2
	OUTI			; EDA3
				; EDA4 ------- Undocumented
				; EDA5 ------- Undocumented
				; EDA6 ------- Undocumented
				; EDA7 ------- Undocumented
	LDD			; EDA8
	CPD			; EDA9
	IND			; EDAA
	OUTD			; EDAB
				; EDAC ------- Undocumented
				; EDAD ------- Undocumented
				; EDAE ------- Undocumented
				; EDAF ------- Undocumented
	LDIR			; EDB0
	CPIR			; EDB1
	INIR			; EDB2
	OTIR			; EDB3
				; EDB4 ------- Undocumented
				; EDB5 ------- Undocumented
				; EDB6 ------- Undocumented
				; EDB7 ------- Undocumented
	LDDR			; EDB8
	CPDR			; EDB9
	INDR			; EDBA
	OTDR			; EDBB
				; EDBC ------- Undocumented
				; EDBD ------- Undocumented
				; EDBE ------- Undocumented
				; EDBF ------- Undocumented
				; EDC0 ------- Undocumented
				; EDC1 ------- Undocumented
				; EDC2 ------- Undocumented
				; EDC3 ------- Undocumented
				; EDC4 ------- Undocumented
				; EDC5 ------- Undocumented
				; EDC6 ------- Undocumented
				; EDC7 ------- Undocumented
				; EDC8 ------- Undocumented
				; EDC9 ------- Undocumented
				; EDCA ------- Undocumented
				; EDCB ------- Undocumented
				; EDCC ------- Undocumented
				; EDCD ------- Undocumented
				; EDCE ------- Undocumented
				; EDCF ------- Undocumented
				; EDD0 ------- Undocumented
				; EDD1 ------- Undocumented
				; EDD2 ------- Undocumented
				; EDD3 ------- Undocumented
				; EDD4 ------- Undocumented
				; EDD5 ------- Undocumented
				; EDD6 ------- Undocumented
				; EDD7 ------- Undocumented
				; EDD8 ------- Undocumented
				; EDD9 ------- Undocumented
				; EDDA ------- Undocumented
				; EDDB ------- Undocumented
				; EDDC ------- Undocumented
				; EDDD ------- Undocumented
				; EDDE ------- Undocumented
				; EDDF ------- Undocumented
				; EDE0 ------- Undocumented
				; EDE1 ------- Undocumented
				; EDE2 ------- Undocumented
				; EDE3 ------- Undocumented
				; EDE4 ------- Undocumented
				; EDE5 ------- Undocumented
				; EDE6 ------- Undocumented
				; EDE7 ------- Undocumented
				; EDE8 ------- Undocumented
				; EDE9 ------- Undocumented
				; EDEA ------- Undocumented
				; EDEB ------- Undocumented
				; EDEC ------- Undocumented
				; EDED ------- Undocumented
				; EDEE ------- Undocumented
				; EDEF ------- Undocumented
				; EDF0 ------- Undocumented
				; EDF1 ------- Undocumented
				; EDF2 ------- Undocumented
				; EDF3 ------- Undocumented
				; EDF4 ------- Undocumented
				; EDF5 ------- Undocumented
				; EDF6 ------- Undocumented
				; EDF7 ------- Undocumented
				; EDF8 ------- Undocumented
				; EDF9 ------- Undocumented
				; EDFA ------- Undocumented
				; EDFB ------- Undocumented
				; EDFC ------- Undocumented
				; EDFD ------- Undocumented
				; EDFE ------- Undocumented
				; EDFF ------- Undocumented

; **************************************
;
; #FD prefixed z80 instructions
;
; **************************************

				; FD00 ------- Undocumented
				; FD01 ------- Undocumented
				; FD02 ------- Undocumented
				; FD03 ------- Undocumented
				; FD04 ------- Undocumented
				; FD05 ------- Undocumented
				; FD06 ------- Undocumented
				; FD07 ------- Undocumented
				; FD08 ------- Undocumented
	ADD	IY,BC		; FD09
				; FD0A ------- Undocumented
				; FD0B ------- Undocumented
				; FD0C ------- Undocumented
				; FD0D ------- Undocumented
				; FD0E ------- Undocumented
				; FD0F ------- Undocumented
				; FD10 ------- Undocumented
				; FD11 ------- Undocumented
				; FD12 ------- Undocumented
				; FD13 ------- Undocumented
				; FD14 ------- Undocumented
				; FD15 ------- Undocumented
				; FD16 ------- Undocumented
				; FD17 ------- Undocumented
				; FD18 ------- Undocumented
	ADD	IY,DE		; FD19
				; FD1A ------- Undocumented
				; FD1B ------- Undocumented
				; FD1C ------- Undocumented
				; FD1D ------- Undocumented
				; FD1E ------- Undocumented
				; FD1F ------- Undocumented
				; FD20 ------- Undocumented
	LD	IY,Imm_Wrd	; FD214523
	LD	(Space),IY	; FD220010
	INC	IY		; FD23
	INC	IYH		; FD24 ------- Unofficial but documented
	DEC	IYH		; FD25 ------- Unofficial but documented
	LD	IYH,Imm_Bte	; FD2612 ----- Unofficial but documented
				; FD27 ------- Undocumented
				; FD28 ------- Undocumented
	ADD	IY,IY		; FD29
	LD	IY,(Space)	; FD2A0010
	DEC	IY		; FD2B
	INC	IYL		; FD2C ------- Unofficial but documented
	DEC	IYL		; FD2D ------- Unofficial but documented
	LD	IYL,Imm_Bte	; FD2E12 ----- Unofficial but documented
				; FD2F ------- Undocumented
				; FD30 ------- Undocumented
				; FD31 ------- Undocumented
				; FD32 ------- Undocumented
				; FD33 ------- Undocumented
	INC	(IY+Displ)	; FD3445
	DEC	(IY+Displ)	; FD3545
				; FD36 ------- Undocumented
				; FD37 ------- Undocumented
				; FD38 ------- Undocumented
	ADD	IY,SP		; FD39
				; FD3A ------- Undocumented
				; FD3B ------- Undocumented
				; FD3C ------- Undocumented
				; FD3D ------- Undocumented
				; FD3E ------- Undocumented
				; FD3F ------- Undocumented
				; FD40 ------- Undocumented
				; FD41 ------- Undocumented
				; FD42 ------- Undocumented
				; FD43 ------- Undocumented
	LD	B,IYH		; FD44 ------- Unofficial but documented
	LD	B,IYL		; FD45 ------- Unofficial but documented
	LD	B,(IY+Displ)	; FD4645
				; FD47 ------- Undocumented
				; FD48 ------- Undocumented
				; FD49 ------- Undocumented
				; FD4A ------- Undocumented
				; FD4B ------- Undocumented
	LD	C,IYH		; FD4C ------- Unofficial but documented
	LD	C,IYL		; FD4D ------- Unofficial but documented
	LD	C,(IY+Displ)	; FD4E45
				; FD4F ------- Undocumented
				; FD50 ------- Undocumented
				; FD51 ------- Undocumented
				; FD52 ------- Undocumented
				; FD53 ------- Undocumented
	LD	D,IYH		; FD54 ------- Unofficial but documented
	LD	D,IYL		; FD55 ------- Unofficial but documented
	LD	D,(IY+Displ)	; FD5645
				; FD57 ------- Undocumented
				; FD58 ------- Undocumented
				; FD59 ------- Undocumented
				; FD5A ------- Undocumented
				; FD5B ------- Undocumented
	LD	E,IYH		; FD5C ------- Unofficial but documented
	LD	E,IYL		; FD5D ------- Unofficial but documented
	LD	E,(IY+Displ)	; FD5E45
				; FD5F ------- Undocumented
	LD	IYH,B		; FD60 ------- Unofficial but documented
	LD	IYH,C		; FD61 ------- Unofficial but documented
	LD	IYH,D		; FD62 ------- Unofficial but documented
	LD	IYH,E		; FD63 ------- Unofficial but documented
	LD	IYH,IYH		; FD64 ------- Unofficial but documented
	LD	IYH,IYL		; FD65 ------- Unofficial but documented
	LD	H,(IY+Displ)	; FD6645
	LD	IYH,A		; FD67 ------- Unofficial but documented
	LD	IYL,B		; FD68 ------- Unofficial but documented
	LD	IYL,C		; FD69 ------- Unofficial but documented
	LD	IYL,D		; FD6A ------- Unofficial but documented
	LD	IYL,E		; FD6B ------- Unofficial but documented
	LD	IYL,IYH		; FD6C ------- Unofficial but documented
	LD	IYL,IYL		; FD6D ------- Unofficial but documented
	LD	L,(IY+Displ)	; FD6E45
	LD	IYL,A		; FD6F ------- Unofficial but documented
	LD	(IY+Displ),B	; FD7045
	LD	(IY+Displ),C	; FD7145
	LD	(IY+Displ),D	; FD7245
	LD	(IY+Displ),E	; FD7345
	LD	(IY+Displ),H	; FD7445
	LD	(IY+Displ),L	; FD7545
				; FD76 ------- Undocumented
	LD	(IY+Displ),A	; FD7745
				; FD78 ------- Undocumented
				; FD79 ------- Undocumented
				; FD7A ------- Undocumented
				; FD7B ------- Undocumented
	LD	A,IYH		; FD7C ------- Unofficial but documented
	LD	A,IYL		; FD7D ------- Unofficial but documented
	LD	A,(IY+Displ)	; FD7E45
				; FD7F ------- Undocumented
				; FD80 ------- Undocumented
				; FD81 ------- Undocumented
				; FD82 ------- Undocumented
				; FD83 ------- Undocumented
	ADD	A,IYH		; FD84 ------- Unofficial but documented, official long style
	ADD	A,IYL		; FD85 ------- Unofficial but documented, official long style
	ADD	A,(IY+Displ)	; FD8645
				; FD87 ------- Undocumented
				; FD88 ------- Undocumented
				; FD89 ------- Undocumented
				; FD8A ------- Undocumented
				; FD8B ------- Undocumented
	ADC	A,IYH		; FD8C ------- Unofficial but documented, official long style
	ADC	A,IYL		; FD8D ------- Unofficial but documented, official long style
	ADC	A,(IY+Displ)	; FD8E45
				; FD8F ------- Undocumented
				; FD90 ------- Undocumented
				; FD91 ------- Undocumented
				; FD92 ------- Undocumented
				; FD93 ------- Undocumented
	SUB	IYH		; FD94 ------- Unofficial but documented, official short style
	SUB	IYL		; FD95 ------- Unofficial but documented, official short style
	SUB	(IY+Displ)	; FD9645
				; FD97 ------- Undocumented
				; FD98 ------- Undocumented
				; FD99 ------- Undocumented
				; FD9A ------- Undocumented
				; FD9B ------- Undocumented
	SBC	A,IYH		; FD9C ------- Unofficial but documented, official long style
	SBC	A,IYL		; FD9D ------- Unofficial but documented, official long style
	SBC	(IY+Displ)	; FD9E45
				; FD9F ------- Undocumented
				; FDA0 ------- Undocumented
				; FDA1 ------- Undocumented
				; FDA2 ------- Undocumented
				; FDA3 ------- Undocumented
	AND	IYH		; FDA4 ------- Unofficial but documented, official short style
	AND	IYL		; FDA5 ------- Unofficial but documented, official short style
	AND	(IY+Displ)	; FDA645
				; FDA7 ------- Undocumented
				; FDA8 ------- Undocumented
				; FDA9 ------- Undocumented
				; FDAA ------- Undocumented
				; FDAB ------- Undocumented
	XOR	IYH		; FDAC ------- Unofficial but documented, official short style
	XOR	IYL		; FDAD ------- Unofficial but documented, official short style
	XOR	(IY+Displ)	; FDAE45
				; FDAF ------- Undocumented
				; FDB0 ------- Undocumented
				; FDB1 ------- Undocumented
				; FDB2 ------- Undocumented
				; FDB3 ------- Undocumented
	OR	IYH		; FDB4 ------- Unofficial but documented, official short style
	OR	IYL		; FDB5 ------- Unofficial but documented, official short style
	OR	(IY+Displ)	; FDB645
				; FDB7 ------- Undocumented
				; FDB8 ------- Undocumented
				; FDB9 ------- Undocumented
				; FDBA ------- Undocumented
				; FDBB ------- Undocumented
	CP	IYH		; FDBC ------- Unofficial but documented, official short style
	CP	IYL		; FDBD ------- Unofficial but documented, official short style
	CP	(IY+Displ)	; FDBE45
				; FDBF ------- Undocumented
				; FDC0 ------- Undocumented
				; FDC1 ------- Undocumented
				; FDC2 ------- Undocumented
				; FDC3 ------- Undocumented
				; FDC4 ------- Undocumented
				; FDC5 ------- Undocumented
				; FDC6 ------- Undocumented
				; FDC7 ------- Undocumented
				; FDC8 ------- Undocumented
				; FDC9 ------- Undocumented
				; FDCA ------- Undocumented
				; FDCB ------- Prefix
				; FDCC ------- Undocumented
				; FDCD ------- Undocumented
				; FDCE ------- Undocumented
				; FDCF ------- Undocumented
				; FDD0 ------- Undocumented
				; FDD1 ------- Undocumented
				; FDD2 ------- Undocumented
				; FDD3 ------- Undocumented
				; FDD4 ------- Undocumented
				; FDD5 ------- Undocumented
				; FDD6 ------- Undocumented
				; FDD7 ------- Undocumented
				; FDD8 ------- Undocumented
				; FDD9 ------- Undocumented
				; FDDA ------- Undocumented
				; FDDB ------- Undocumented
				; FDDC ------- Undocumented
				; FDDD ------- Undocumented
				; FDDE ------- Undocumented
				; FDDF ------- Undocumented
				; FDE0 ------- Undocumented
	POP	IY		; FDE1
				; FDE2 ------- Undocumented
	EX	(SP),IY		; FDE3
				; FDE4 ------- Undocumented
	PUSH	IY		; FDE5
				; FDE6 ------- Undocumented
				; FDE7 ------- Undocumented
				; FDE8 ------- Undocumented
	JP	(IY)		; FDE9
				; FDEA ------- Undocumented
				; FDEB ------- Undocumented
				; FDEC ------- Undocumented
				; FDED ------- Prefix
				; FDEE ------- Undocumented
				; FDEF ------- Undocumented
				; FDF0 ------- Undocumented
				; FDF1 ------- Undocumented
				; FDF2 ------- Undocumented
				; FDF3 ------- Undocumented
				; FDF4 ------- Undocumented
				; FDF5 ------- Undocumented
				; FDF6 ------- Undocumented
				; FDF7 ------- Undocumented
				; FDF8 ------- Undocumented
	LD	SP,IY		; FDF9
				; FDFA ------- Undocumented
				; FDFB ------- Undocumented
				; FDFC ------- Undocumented
				; FDFD ------- Undocumented
				; FDFE ------- Undocumented
				; FDFF ------- Undocumented

; **************************************
;
; #FDCB prefixed z80 instructions
;
; **************************************

	RLC	(IY+Displ),B	; FDCB4500 --- Unofficial but documented
	RLC	(IY+Displ),C	; FDCB4501 --- Unofficial but documented
	RLC	(IY+Displ),D	; FDCB4502 --- Unofficial but documented
	RLC	(IY+Displ),E	; FDCB4503 --- Unofficial but documented
	RLC	(IY+Displ),H	; FDCB4504 --- Unofficial but documented
	RLC	(IY+Displ),L	; FDCB4505 --- Unofficial but documented
	RLC	(IY+Displ)	; FDCB4506
	RLC	(IY+Displ),A	; FDCB4507 --- Unofficial but documented
	RRC	(IY+Displ),B	; FDCB4508 --- Unofficial but documented
	RRC	(IY+Displ),C	; FDCB4509 --- Unofficial but documented
	RRC	(IY+Displ),D	; FDCB450A --- Unofficial but documented
	RRC	(IY+Displ),E	; FDCB450B --- Unofficial but documented
	RRC	(IY+Displ),H	; FDCB450C --- Unofficial but documented
	RRC	(IY+Displ),L	; FDCB450D --- Unofficial but documented
	RRC	(IY+Displ)	; FDCB450E
	RRC	(IY+Displ),A	; FDCB450F --- Unofficial but documented
	RL	(IY+Displ),B	; FDCB4510 --- Unofficial but documented
	RL	(IY+Displ),C	; FDCB4511 --- Unofficial but documented
	RL	(IY+Displ),D	; FDCB4512 --- Unofficial but documented
	RL	(IY+Displ),E	; FDCB4513 --- Unofficial but documented
	RL	(IY+Displ),H	; FDCB4514 --- Unofficial but documented
	RL	(IY+Displ),L	; FDCB4515 --- Unofficial but documented
	RL	(IY+Displ)	; FDCB4516
	RL	(IY+Displ),A	; FDCB4517 --- Unofficial but documented
	RR	(IY+Displ),B	; FDCB4518 --- Unofficial but documented
	RR	(IY+Displ),C	; FDCB4519 --- Unofficial but documented
	RR	(IY+Displ),D	; FDCB451A --- Unofficial but documented
	RR	(IY+Displ),E	; FDCB451B --- Unofficial but documented
	RR	(IY+Displ),H	; FDCB451C --- Unofficial but documented
	RR	(IY+Displ),L	; FDCB451D --- Unofficial but documented
	RR	(IY+Displ)	; FDCB451E
	RR	(IY+Displ),A	; FDCB451F --- Unofficial but documented
	SLA	(IY+Displ),B	; FDCB4520 --- Unofficial but documented
	SLA	(IY+Displ),C	; FDCB4521 --- Unofficial but documented
	SLA	(IY+Displ),D	; FDCB4522 --- Unofficial but documented
	SLA	(IY+Displ),E	; FDCB4523 --- Unofficial but documented
	SLA	(IY+Displ),H	; FDCB4524 --- Unofficial but documented
	SLA	(IY+Displ),L	; FDCB4525 --- Unofficial but documented
	SLA	(IY+Displ)	; FDCB4526
	SLA	(IY+Displ),A	; FDCB4527 --- Unofficial but documented
	SRA	(IY+Displ),B	; FDCB4528 --- Unofficial but documented
	SRA	(IY+Displ),C	; FDCB4529 --- Unofficial but documented
	SRA	(IY+Displ),D	; FDCB452A --- Unofficial but documented
	SRA	(IY+Displ),E	; FDCB452B --- Unofficial but documented
	SRA	(IY+Displ),H	; FDCB452C --- Unofficial but documented
	SRA	(IY+Displ),L	; FDCB452D --- Unofficial but documented
	SRA	(IY+Displ)	; FDCB452E
	SRA	(IY+Displ),A	; FDCB452F --- Unofficial but documented
	SLL	(IY+Displ),B	; FDCB4530 --- Unofficial but documented
	SLL	(IY+Displ),C	; FDCB4531 --- Unofficial but documented
	SLL	(IY+Displ),D	; FDCB4532 --- Unofficial but documented
	SLL	(IY+Displ),E	; FDCB4533 --- Unofficial but documented
	SLL	(IY+Displ),H	; FDCB4534 --- Unofficial but documented
	SLL	(IY+Displ),L	; FDCB4535 --- Unofficial but documented
	SLL	(IY+Displ)	; FDCB4536 --- Unofficial but documented
	SLL	(IY+Displ),A	; FDCB4537 --- Unofficial but documented
	SRL	(IY+Displ),B	; FDCB4538 --- Unofficial but documented
	SRL	(IY+Displ),C	; FDCB4539 --- Unofficial but documented
	SRL	(IY+Displ),D	; FDCB453A --- Unofficial but documented
	SRL	(IY+Displ),E	; FDCB453B --- Unofficial but documented
	SRL	(IY+Displ),H	; FDCB453C --- Unofficial but documented
	SRL	(IY+Displ),L	; FDCB453D --- Unofficial but documented
	SRL	(IY+Displ)	; FDCB453E
	SRL	(IY+Displ),A	; FDCB453F --- Unofficial but documented
	BIT	0,(IY+Displ),B	; FDCB4540 --- Unofficial but documented
	BIT	0,(IY+Displ),C	; FDCB4541 --- Unofficial but documented
	BIT	0,(IY+Displ),D	; FDCB4542 --- Unofficial but documented
	BIT	0,(IY+Displ),E	; FDCB4543 --- Unofficial but documented
	BIT	0,(IY+Displ),H	; FDCB4544 --- Unofficial but documented
	BIT	0,(IY+Displ),L	; FDCB4545 --- Unofficial but documented
	BIT	0,(IY+Displ)	; FDCB4546
	BIT	0,(IY+Displ),A	; FDCB4547 --- Unofficial but documented
	BIT	1,(IY+Displ),B	; FDCB4548 --- Unofficial but documented
	BIT	1,(IY+Displ),C	; FDCB4549 --- Unofficial but documented
	BIT	1,(IY+Displ),D	; FDCB454A --- Unofficial but documented
	BIT	1,(IY+Displ),E	; FDCB454B --- Unofficial but documented
	BIT	1,(IY+Displ),H	; FDCB454C --- Unofficial but documented
	BIT	1,(IY+Displ),L	; FDCB454D --- Unofficial but documented
	BIT	1,(IY+Displ)	; FDCB454E
	BIT	1,(IY+Displ),A	; FDCB454F --- Unofficial but documented
	BIT	2,(IY+Displ),B	; FDCB4550 --- Unofficial but documented
	BIT	2,(IY+Displ),C	; FDCB4551 --- Unofficial but documented
	BIT	2,(IY+Displ),D	; FDCB4552 --- Unofficial but documented
	BIT	2,(IY+Displ),E	; FDCB4553 --- Unofficial but documented
	BIT	2,(IY+Displ),H	; FDCB4554 --- Unofficial but documented
	BIT	2,(IY+Displ),L	; FDCB4555 --- Unofficial but documented
	BIT	2,(IY+Displ)	; FDCB4556
	BIT	2,(IY+Displ),A	; FDCB4557 --- Unofficial but documented
	BIT	3,(IY+Displ),B	; FDCB4558 --- Unofficial but documented
	BIT	3,(IY+Displ),C	; FDCB4559 --- Unofficial but documented
	BIT	3,(IY+Displ),D	; FDCB455A --- Unofficial but documented
	BIT	3,(IY+Displ),E	; FDCB455B --- Unofficial but documented
	BIT	3,(IY+Displ),H	; FDCB455C --- Unofficial but documented
	BIT	3,(IY+Displ),L	; FDCB455D --- Unofficial but documented
	BIT	3,(IY+Displ)	; FDCB455E
	BIT	3,(IY+Displ),A	; FDCB455F --- Unofficial but documented
	BIT	4,(IY+Displ),B	; FDCB4560 --- Unofficial but documented
	BIT	4,(IY+Displ),C	; FDCB4561 --- Unofficial but documented
	BIT	4,(IY+Displ),D	; FDCB4562 --- Unofficial but documented
	BIT	4,(IY+Displ),E	; FDCB4563 --- Unofficial but documented
	BIT	4,(IY+Displ),H	; FDCB4564 --- Unofficial but documented
	BIT	4,(IY+Displ),L	; FDCB4565 --- Unofficial but documented
	BIT	4,(IY+Displ)	; FDCB4566
	BIT	4,(IY+Displ),A	; FDCB4567 --- Unofficial but documented
	BIT	5,(IY+Displ),B	; FDCB4568 --- Unofficial but documented
	BIT	5,(IY+Displ),C	; FDCB4569 --- Unofficial but documented
	BIT	5,(IY+Displ),D	; FDCB456A --- Unofficial but documented
	BIT	5,(IY+Displ),E	; FDCB456B --- Unofficial but documented
	BIT	5,(IY+Displ),H	; FDCB456C --- Unofficial but documented
	BIT	5,(IY+Displ),L	; FDCB456D --- Unofficial but documented
	BIT	5,(IY+Displ)	; FDCB456E
	BIT	5,(IY+Displ),A	; FDCB456F --- Unofficial but documented
	BIT	6,(IY+Displ),B	; FDCB4570 --- Unofficial but documented
	BIT	6,(IY+Displ),C	; FDCB4571 --- Unofficial but documented
	BIT	6,(IY+Displ),D	; FDCB4572 --- Unofficial but documented
	BIT	6,(IY+Displ),E	; FDCB4573 --- Unofficial but documented
	BIT	6,(IY+Displ),H	; FDCB4574 --- Unofficial but documented
	BIT	6,(IY+Displ),L	; FDCB4575 --- Unofficial but documented
	BIT	6,(IY+Displ)	; FDCB4576
	BIT	6,(IY+Displ),A	; FDCB4577 --- Unofficial but documented
	BIT	7,(IY+Displ),B	; FDCB4578 --- Unofficial but documented
	BIT	7,(IY+Displ),C	; FDCB4579 --- Unofficial but documented
	BIT	7,(IY+Displ),D	; FDCB457A --- Unofficial but documented
	BIT	7,(IY+Displ),E	; FDCB457B --- Unofficial but documented
	BIT	7,(IY+Displ),H	; FDCB457C --- Unofficial but documented
	BIT	7,(IY+Displ),L	; FDCB457D --- Unofficial but documented
	BIT	7,(IY+Displ)	; FDCB457E
	BIT	7,(IY+Displ),A	; FDCB457F --- Unofficial but documented
	RES	0,(IY+Displ),B	; FDCB4580 --- Unofficial but documented
	RES	0,(IY+Displ),C	; FDCB4581 --- Unofficial but documented
	RES	0,(IY+Displ),D	; FDCB4582 --- Unofficial but documented
	RES	0,(IY+Displ),E	; FDCB4583 --- Unofficial but documented
	RES	0,(IY+Displ),H	; FDCB4584 --- Unofficial but documented
	RES	0,(IY+Displ),L	; FDCB4585 --- Unofficial but documented
	RES	0,(IY+Displ)	; FDCB4586
	RES	0,(IY+Displ),A	; FDCB4587 --- Unofficial but documented
	RES	1,(IY+Displ),B	; FDCB4588 --- Unofficial but documented
	RES	1,(IY+Displ),C	; FDCB4589 --- Unofficial but documented
	RES	1,(IY+Displ),D	; FDCB458A --- Unofficial but documented
	RES	1,(IY+Displ),E	; FDCB458B --- Unofficial but documented
	RES	1,(IY+Displ),H	; FDCB458C --- Unofficial but documented
	RES	1,(IY+Displ),L	; FDCB458D --- Unofficial but documented
	RES	1,(IY+Displ)	; FDCB458E
	RES	1,(IY+Displ),A	; FDCB458F --- Unofficial but documented
	RES	2,(IY+Displ),B	; FDCB4590 --- Unofficial but documented
	RES	2,(IY+Displ),C	; FDCB4591 --- Unofficial but documented
	RES	2,(IY+Displ),D	; FDCB4592 --- Unofficial but documented
	RES	2,(IY+Displ),E	; FDCB4593 --- Unofficial but documented
	RES	2,(IY+Displ),H	; FDCB4594 --- Unofficial but documented
	RES	2,(IY+Displ),L	; FDCB4595 --- Unofficial but documented
	RES	2,(IY+Displ)	; FDCB4596
	RES	2,(IY+Displ),A	; FDCB4597 --- Unofficial but documented
	RES	3,(IY+Displ),B	; FDCB4598 --- Unofficial but documented
	RES	3,(IY+Displ),C	; FDCB4599 --- Unofficial but documented
	RES	3,(IY+Displ),D	; FDCB459A --- Unofficial but documented
	RES	3,(IY+Displ),E	; FDCB459B --- Unofficial but documented
	RES	3,(IY+Displ),H	; FDCB459C --- Unofficial but documented
	RES	3,(IY+Displ),L	; FDCB459D --- Unofficial but documented
	RES	3,(IY+Displ)	; FDCB459E
	RES	3,(IY+Displ),A	; FDCB459F --- Unofficial but documented
	RES	4,(IY+Displ),B	; FDCB45A0 --- Unofficial but documented
	RES	4,(IY+Displ),C	; FDCB45A1 --- Unofficial but documented
	RES	4,(IY+Displ),D	; FDCB45A2 --- Unofficial but documented
	RES	4,(IY+Displ),E	; FDCB45A3 --- Unofficial but documented
	RES	4,(IY+Displ),H	; FDCB45A4 --- Unofficial but documented
	RES	4,(IY+Displ),L	; FDCB45A5 --- Unofficial but documented
	RES	4,(IY+Displ)	; FDCB45A6
	RES	4,(IY+Displ),A	; FDCB45A7 --- Unofficial but documented
	RES	5,(IY+Displ),B	; FDCB45A8 --- Unofficial but documented
	RES	5,(IY+Displ),C	; FDCB45A9 --- Unofficial but documented
	RES	5,(IY+Displ),D	; FDCB45AA --- Unofficial but documented
	RES	5,(IY+Displ),E	; FDCB45AB --- Unofficial but documented
	RES	5,(IY+Displ),H	; FDCB45AC --- Unofficial but documented
	RES	5,(IY+Displ),L	; FDCB45AD --- Unofficial but documented
	RES	5,(IY+Displ)	; FDCB45AE
	RES	5,(IY+Displ),A	; FDCB45AF --- Unofficial but documented
	RES	6,(IY+Displ),B	; FDCB45B0 --- Unofficial but documented
	RES	6,(IY+Displ),C	; FDCB45B1 --- Unofficial but documented
	RES	6,(IY+Displ),D	; FDCB45B2 --- Unofficial but documented
	RES	6,(IY+Displ),E	; FDCB45B3 --- Unofficial but documented
	RES	6,(IY+Displ),H	; FDCB45B4 --- Unofficial but documented
	RES	6,(IY+Displ),L	; FDCB45B5 --- Unofficial but documented
	RES	6,(IY+Displ)	; FDCB45B6
	RES	6,(IY+Displ),A	; FDCB45B7 --- Unofficial but documented
	RES	7,(IY+Displ),B	; FDCB45B8 --- Unofficial but documented
	RES	7,(IY+Displ),C	; FDCB45B9 --- Unofficial but documented
	RES	7,(IY+Displ),D	; FDCB45BA --- Unofficial but documented
	RES	7,(IY+Displ),E	; FDCB45BB --- Unofficial but documented
	RES	7,(IY+Displ),H	; FDCB45BC --- Unofficial but documented
	RES	7,(IY+Displ),L	; FDCB45BD --- Unofficial but documented
	RES	7,(IY+Displ)	; FDCB45BE
	RES	7,(IY+Displ),A	; FDCB45BF --- Unofficial but documented
	SET	0,(IY+Displ),B	; FDCB45C0 --- Unofficial but documented
	SET	0,(IY+Displ),C	; FDCB45C1 --- Unofficial but documented
	SET	0,(IY+Displ),D	; FDCB45C2 --- Unofficial but documented
	SET	0,(IY+Displ),E	; FDCB45C3 --- Unofficial but documented
	SET	0,(IY+Displ),H	; FDCB45C4 --- Unofficial but documented
	SET	0,(IY+Displ),L	; FDCB45C5 --- Unofficial but documented
	SET	0,(IY+Displ)	; FDCB45C6
	SET	0,(IY+Displ),A	; FDCB45C7 --- Unofficial but documented
	SET	1,(IY+Displ),B	; FDCB45C8 --- Unofficial but documented
	SET	1,(IY+Displ),C	; FDCB45C9 --- Unofficial but documented
	SET	1,(IY+Displ),D	; FDCB45CA --- Unofficial but documented
	SET	1,(IY+Displ),E	; FDCB45CB --- Unofficial but documented
	SET	1,(IY+Displ),H	; FDCB45CC --- Unofficial but documented
	SET	1,(IY+Displ),L	; FDCB45CD --- Unofficial but documented
	SET	1,(IY+Displ)	; FDCB45CE
	SET	1,(IY+Displ),A	; FDCB45CF --- Unofficial but documented
	SET	2,(IY+Displ),B	; FDCB45D0 --- Unofficial but documented
	SET	2,(IY+Displ),C	; FDCB45D1 --- Unofficial but documented
	SET	2,(IY+Displ),D	; FDCB45D2 --- Unofficial but documented
	SET	2,(IY+Displ),E	; FDCB45D3 --- Unofficial but documented
	SET	2,(IY+Displ),H	; FDCB45D4 --- Unofficial but documented
	SET	2,(IY+Displ),L	; FDCB45D5 --- Unofficial but documented
	SET	2,(IY+Displ)	; FDCB45D6
	SET	2,(IY+Displ),A	; FDCB45D7 --- Unofficial but documented
	SET	3,(IY+Displ),B	; FDCB45D8 --- Unofficial but documented
	SET	3,(IY+Displ),C	; FDCB45D9 --- Unofficial but documented
	SET	3,(IY+Displ),D	; FDCB45DA --- Unofficial but documented
	SET	3,(IY+Displ),E	; FDCB45DB --- Unofficial but documented
	SET	3,(IY+Displ),H	; FDCB45DC --- Unofficial but documented
	SET	3,(IY+Displ),L	; FDCB45DD --- Unofficial but documented
	SET	3,(IY+Displ)	; FDCB45DE
	SET	3,(IY+Displ),A	; FDCB45DF --- Unofficial but documented
	SET	4,(IY+Displ),B	; FDCB45E0 --- Unofficial but documented
	SET	4,(IY+Displ),C	; FDCB45E1 --- Unofficial but documented
	SET	4,(IY+Displ),D	; FDCB45E2 --- Unofficial but documented
	SET	4,(IY+Displ),E	; FDCB45E3 --- Unofficial but documented
	SET	4,(IY+Displ),H	; FDCB45E4 --- Unofficial but documented
	SET	4,(IY+Displ),L	; FDCB45E5 --- Unofficial but documented
	SET	4,(IY+Displ)	; FDCB45E6
	SET	4,(IY+Displ),A	; FDCB45E7 --- Unofficial but documented
	SET	5,(IY+Displ),B	; FDCB45E8 --- Unofficial but documented
	SET	5,(IY+Displ),C	; FDCB45E9 --- Unofficial but documented
	SET	5,(IY+Displ),D	; FDCB45EA --- Unofficial but documented
	SET	5,(IY+Displ),E	; FDCB45EB --- Unofficial but documented
	SET	5,(IY+Displ),H	; FDCB45EC --- Unofficial but documented
	SET	5,(IY+Displ),L	; FDCB45ED --- Unofficial but documented
	SET	5,(IY+Displ)	; FDCB45EE
	SET	5,(IY+Displ),A	; FDCB45EF --- Unofficial but documented
	SET	6,(IY+Displ),B	; FDCB45F0 --- Unofficial but documented
	SET	6,(IY+Displ),C	; FDCB45F1 --- Unofficial but documented
	SET	6,(IY+Displ),D	; FDCB45F2 --- Unofficial but documented
	SET	6,(IY+Displ),E	; FDCB45F3 --- Unofficial but documented
	SET	6,(IY+Displ),H	; FDCB45F4 --- Unofficial but documented
	SET	6,(IY+Displ),L	; FDCB45F5 --- Unofficial but documented
	SET	6,(IY+Displ)	; FDCB45F6
	SET	6,(IY+Displ),A	; FDCB45F7 --- Unofficial but documented
	SET	7,(IY+Displ),B	; FDCB45F8 --- Unofficial but documented
	SET	7,(IY+Displ),C	; FDCB45F9 --- Unofficial but documented
	SET	7,(IY+Displ),D	; FDCB45FA --- Unofficial but documented
	SET	7,(IY+Displ),E	; FDCB45FB --- Unofficial but documented
	SET	7,(IY+Displ),H	; FDCB45FC --- Unofficial but documented
	SET	7,(IY+Displ),L	; FDCB45FD --- Unofficial but documented
	SET	7,(IY+Displ)	; FDCB45FE
	SET	7,(IY+Displ),A	; FDCB45FF --- Unofficial but documented

; **************************************
;
; Various aliases and synonyms
;                   recognised by zmac
;
; **************************************

; ===== STANDARD ALIASES ===============

	ADD	B		; 80 --------- Unofficial short style
	ADD	C		; 81 --------- Unofficial short style
	ADD	D		; 82 --------- Unofficial short style
	ADD	E		; 83 --------- Unofficial short style
	ADD	H		; 84 --------- Unofficial short style
	ADD	L		; 85 --------- Unofficial short style
	ADD	(HL)		; 86 --------- Unofficial short style
	ADD	A		; 87 --------- Unofficial short style

	ADC	B		; 88 --------- Unofficial short style
	ADC	C		; 89 --------- Unofficial short style
	ADC	D		; 8A --------- Unofficial short style
	ADC	E		; 8B --------- Unofficial short style
	ADC	H		; 8C --------- Unofficial short style
	ADC	L		; 8D --------- Unofficial short style
	ADC	(HL)		; 8E --------- Unofficial short style
	ADC	A		; 8F --------- Unofficial short style

	SUB	A,B		; 90 --------- Unofficial long style
	SUB	A,C		; 91 --------- Unofficial long style
	SUB	A,D		; 92 --------- Unofficial long style
	SUB	A,E		; 93 --------- Unofficial long style
	SUB	A,H		; 94 --------- Unofficial long style
	SUB	A,L		; 95 --------- Unofficial long style
	SUB	A,(HL)		; 96 --------- Unofficial long style
	SUB	A,A		; 97 --------- Unofficial long style

	SBC	B		; 98 --------- Unofficial short style
	SBC	C		; 99 --------- Unofficial short style
	SBC	D		; 9A --------- Unofficial short style
	SBC	E		; 9B --------- Unofficial short style
	SBC	H		; 9C --------- Unofficial short style
	SBC	L		; 9D --------- Unofficial short style
	SBC	(HL)		; 9E --------- Unofficial short style
	SBC	A		; 9F --------- Unofficial short style

	AND	A,B		; A0 --------- Unofficial long style
	AND	A,C		; A1 --------- Unofficial long style
	AND	A,D		; A2 --------- Unofficial long style
	AND	A,E		; A3 --------- Unofficial long style
	AND	A,H		; A4 --------- Unofficial long style
	AND	A,L		; A5 --------- Unofficial long style
	AND	A,(HL)		; A6 --------- Unofficial long style
	AND	A,A		; A7 --------- Unofficial long style

	XOR	A,B		; A8 --------- Unofficial long style
	XOR	A,C		; A9 --------- Unofficial long style
	XOR	A,D		; AA --------- Unofficial long style
	XOR	A,E		; AB --------- Unofficial long style
	XOR	A,H		; AC --------- Unofficial long style
	XOR	A,L		; AD --------- Unofficial long style
	XOR	A,(HL)		; AE --------- Unofficial long style
	XOR	A,A		; AF --------- Unofficial long style

	OR	A,B		; B0 --------- Unofficial long style
	OR	A,C		; B1 --------- Unofficial long style
	OR	A,D		; B2 --------- Unofficial long style
	OR	A,E		; B3 --------- Unofficial long style
	OR	A,H		; B4 --------- Unofficial long style
	OR	A,L		; B5 --------- Unofficial long style
	OR	A,(HL)		; B6 --------- Unofficial long style
	OR	A,A		; B7 --------- Unofficial long style

	CP	A,B		; B8 --------- Unofficial long style
	CP	A,C		; B9 --------- Unofficial long style
	CP	A,D		; BA --------- Unofficial long style
	CP	A,E		; BB --------- Unofficial long style
	CP	A,H		; BC --------- Unofficial long style
	CP	A,L		; BD --------- Unofficial long style
	CP	A,(HL)		; BE --------- Unofficial long style
	CP	A,A		; BF --------- Unofficial long style

	ADD	Imm_Bte		; C612 ------- Unofficial short style
	ADC	Imm_Bte		; CE12 ------- Unofficial short style
	SUB	A,Imm_Bte	; D612 ------- Unofficial long style
	SBC	Imm_Bte		; DE12 ------- Unofficial short style
	AND	A,Imm_Bte	; E612 ------- Unofficial long style
	XOR	A,Imm_Bte	; EE12 ------- Unofficial long style
	OR	A,Imm_Bte	; F612 ------- Unofficial long style
	CP	A,Imm_Bte	; FE12 ------- Unofficial long style

; ===== IX, IY ALIASES =================

	ADD	IXH		; DD84 ------- Unofficial but documented, unofficial short style
	ADD	IXL		; DD85 ------- Unofficial but documented, unofficial short style

	ADD	IYH		; FD84 ------- Unofficial but documented, unofficial short style
	ADD	IYL		; FD85 ------- Unofficial but documented, unofficial short style

	ADC	IXH		; DD8C ------- Unofficial but documented, unofficial short style
	ADC	IXL		; DD8D ------- Unofficial but documented, unofficial short style

	ADC	IYH		; FD8C ------- Unofficial but documented, unofficial short style
	ADC	IYL		; FD8D ------- Unofficial but documented, unofficial short style

	SUB	A,IXH		; DD94 ------- Unofficial but documented, unofficial long style
	SUB	A,IXL		; DD95 ------- Unofficial but documented, unofficial long style

	SUB	A,IYH		; FD94 ------- Unofficial but documented, unofficial long style
	SUB	A,IYL		; FD95 ------- Unofficial but documented, unofficial long style

	SBC	IXH		; DD9C ------- Unofficial but documented, unofficial short style
	SBC	IXL		; DD9D ------- Unofficial but documented, unofficial short style

	SBC	IYH		; FD9C ------- Unofficial but documented, unofficial short style
	SBC	IYL		; FD9D ------- Unofficial but documented, unofficial short style

	AND	A,IXH		; DDA4 ------- Unofficial but documented, unofficial long style
	AND	A,IXL		; DDA5 ------- Unofficial but documented, unofficial long style

	AND	A,IYH		; FDA4 ------- Unofficial but documented, unofficial long style
	AND	A,IYL		; FDA5 ------- Unofficial but documented, unofficial long style

	XOR	A,IXH		; DDAC ------- Unofficial but documented, unofficial long style
	XOR	A,IXL		; DDAD ------- Unofficial but documented, unofficial long style

	XOR	A,IYH		; FDAC ------- Unofficial but documented, unofficial long style
	XOR	A,IYL		; FDAD ------- Unofficial but documented, unofficial long style

	OR	A,IXH		; DDB4 ------- Unofficial but documented, unofficial long style
	OR	A,IXL		; DDB5 ------- Unofficial but documented, unofficial long style

	OR	A,IYH		; FDB4 ------- Unofficial but documented, unofficial long style
	OR	A,IYL		; FDB5 ------- Unofficial but documented, unofficial long style

	CP	A,IXH		; DDBC ------- Unofficial but documented, unofficial long style
	CP	A,IXL		; DDBD ------- Unofficial but documented, unofficial long style

	CP	A,IYH		; FDBC ------- Unofficial but documented, unofficial long style
	CP	A,IYL		; FDBD ------- Unofficial but documented, unofficial long style

	.end