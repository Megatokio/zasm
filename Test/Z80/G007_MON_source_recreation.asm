#!/usr/local/bin/zasm -o original/
; 
;
;


#target	rom		; declare target file format
#code	ROM,$3800,$0800	; declare code segment name, start and size	


#if 1
;
; ZX81 ROM addresses
;
NEW		equ	$03C3
CLS		equ	$0A2A	
SET_FIELD	equ	$090B
PR_STR_4	equ	$0B6B
SCROLL		equ	$0C0E		
DECODE		equ	$07BD
;
; ZX81 variables
;
RAMTOP		equ	$4004		; The top of available RAM, or as specified.
UNUSED_8	equ	$4021
LAST_K		equ	$4025		; Last Key pressed
UNUSED_16	equ	$407B
;
; Monitor variables
;
VAR_7D16	equ	$3D16		; okay if in RAM

#endif

HERE				equ	$3800	;
THERE				equ	$7800	;
SIZE				equ	$0800	;

;
; Copy 2K block from ROM to RAM
;
m3800:	LD	HL,HERE			; 210038
m3803:	LD	DE,THERE		; 110078
m3806:	LD	BC,SIZE			; 010008
m3809:	LDIR				; EDB0

m380B:	LD	A,$74			; 3E74
m380D:	LD	(RAMTOP+1),A		; 320540
m3810:	CALL	NEW			; CDC303
;
function_10:
;
m3813:	LD	A,1			; 3E01
m3815:	LD	BC,data_for_input_prompt_messages
					; 01937B
m3818:	CALL	Get_A_addresses		; CD0279
m381B:	CALL	CLS			; CD2A0A
m381E:
#if 0
	LD	HL,(next_address_for_routine)	; ED6BF87F
	NOP	; because assembler will choose the shorter form
#else
	; force assembler to use the longer option
	DEFB     $ED, $6B, $F8, $7F ;   ld  hl,Next_Address

m3822:	JP	(HL)			; E9
;
; Routine 0 the disassembler
Disassemble:
;
m3823:	CALL	L38FD			; CDFD78
m3826:	CALL	Check_printer		; CD0979
m3829:	JR	L3830			; 1805
;
L382B:	LD	D,$13			; 1613
m382D:	CALL	Print_String		; CD537B
;
L3830:	CALL	Check_Finish		; CD817B
;
L3833:	JR	NC,L383A		; 3005
;
m3835:	XOR	A			; AF
m3836:	LD	(UNUSED_8),A		; 322140
m3839:	RET				; C9
;
L383A:	LD	HL,UNUSED_16		; 217B40
m383D:	LD	(HL),L3830 & $FF	; 3630
m383F:	INC	HL			; 23
m3840:	LD	(HL),L3830 >> 8		; 3678
m3842:	CALL	Initial			; CD2E7A
m3845:	CALL	Next_Byte			; CD727A
m3848:	LD	A,B			; 78
m3849:	CP	$76			; FE76
m384B:	JR	NZ,L3855		; 2008
;
L384D:	LD	HL,L3CF5		; 21F57C
m3850:	CALL	L3BA4			; CDA47B
m3853:	JR	L382B			; 18D6
;
L3855:	CP	$CB			; FECB
m3857:	JR	Z,L388B			; 2832
;
m3859:	CP	$ED			; FEED
m385B:	JR	Z,L3895			; 2838
;
m385D:	CP	$DD			; FEDD
m385F:	JR	Z,L38A5			; 2844
;
m3861:	CP	$FD			; FEFD
m3863:	JR	Z,L38A9			; 2844
;
m3865:	CALL	Octal			; CD4F7A
L3868:	LD	L,$24			; 2E24
m386A:	CP	0			; FE00
m386C:	JR	Z,L387F			; 2811
;
m386E:	LD	L,$2C			; 2E2C
m3870:	CP	1			; FE01
m3872:	JR	Z,L3882			; 280E
;
m3874:	INC	L			; 2C
m3875:	CP	2			; FE02
m3877:	JR	Z,L3882			; 2809
;
m3879:	LD	A,$5E			; 3E5E
m387B:	LD	(L3D42),A		; 32427D
m387E:	INC	L			; 2C
;
L387F:	LD	A,L			; 7D
m3880:	ADD	A,C			; 81
;
L3881:	LD	L,A			; 6F
;
L3882:	LD	H,$7D			; 267D
m3884:	LD	L,(HL)			; 6E
m3885:	EX	DE,HL			; EB
m3886:	CALL	Control			; CDD47A
m3889:	JR	L382B			; 18A0
;
L388B:	CALL	Next_Byte			; CD727A
m388E:	CALL	Octal			; CD4F7A
m3891:	ADD	A,$36			; C636
m3893:	JR	L3881			; 18EC
;
L3895:	CALL	Next_Byte			; CD727A
m3898:	CALL	Octal			; CD4F7A
m389B:	LD	L,$18			; 2E18
m389D:	CP	1			; FE01
m389F:	JR	Z,L387F			; 28DE
;
m38A1:	LD	L,$20			; 2E20
m38A3:	JR	L387F			; 18DA
;
L38A5:	LD	A,$0B			; 3E0B
m38A7:	JR	L38AB			; 1802
;
L38A9:	LD	A,$0D			; 3E0D
;
L38AB:	LD	(pointer_3D40+1),A	; 32417D
m38AE:	LD	A,$12			; 3E12
;
m38B0:	LD	(pointer_3D40),A	; 32407D
m38B3:	LD	HL,(next_address_for_routine)		; 2AF87F
m38B6:	INC	HL			; 23
m38B7:	LD	A,(HL)			; 7E
m38B8:	LD	HL,VAR_7D16		; 21167D
m38BB:	CALL	L3A89			; CD897A
m38BE:	INC	HL			; 23
m38BF:	RES	7,(HL)			; CBBE
m38C1:	CALL	Next_Byte			; CD727A
m38C4:	LD	A,B			; 78
m38C5:	CP	$CB			; FECB
m38C7:	JR	NZ,L38CE		; 2005
;
m38C9:	CALL	Next_Byte			; CD727A
m38CC:	JR	L388B			; 18BD
;
L38CE:	CALL	Octal			; CD4F7A
m38D1:	CP	3			; FE03
m38D3:	JR	Z,L3868			; 2893
;
m38D5:	PUSH	AF			; F5
m38D6:	PUSH	BC			; C5
m38D7:	CP	0			; FE00
m38D9:	JR	NZ,L38E0		; 2005
;
m38DB:	LD	A,6			; 3E06
m38DD:	CP	B			; B8
m38DE:	JR	NZ,L38E3		; 2003
;
L38E0:	CALL	Next_Byte			; CD727A
L38E3:	POP	BC			; C1
m38E4:	POP	AF			; F1
m38E5:	JR	L3868			; 1881
;
; Spare bytes
;
mark_38E7:	DEFB	 $00
mark_38E8:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_38F0:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_38F8:	DEFB	 $00, $00, $00, $00, $00
;
; Start/Finish Addresses
; prints request for input then calls input address routine
;
L38FD:	LD	BC,data_for_input_prompt_messages		; 01937B
;
L3900:	LD	A,2			; 3E02
;
Get_A_addresses:
;
m3902:	LD	DE,next_address_for_routine		; 11F87F
m3905:	CALL	Input_Address			; CD147A
m3908:	RET				; C9
;
Check_printer:
;
m3909:	LD	DE,$10E1		; 11E110
m390C:	CALL	L3B3B			; CD3B7B
m390F:	DEC	HL			; 2B
m3910:	LD	A,(HL)			; 7E
m3911:	LD	HL,UNUSED_8		; 212140
m3914:	LD	(HL),$83		; 3683
m3916:	SET	1,(IY+1)		; FDCB01CE
m391A:	CP	$1D			; FE1D
m391C:	CALL	NZ,CLS			; C42A0A
m391F:	RET				; C9
;
; routine 1:	DEFB	 hex dump
hex_dump:
;
m3920:	CALL	L38FD			; CDFD78
m3923:	CALL	Check_printer		; CD0979
m3926:	LD	HL,data_and_pointers_for_disassembler		; 21F97C
;
L3929:	CALL	Add_String		; CD9F7B
m392C:	LD	HL,UNUSED_16		; 217B40
m392F:	LD	(HL),$33		; 3633
m3931:	INC	HL			; 23
m3932:	LD	(HL),$79		; 3679
;
L3934:	CALL	Check_Finish		; CD817B
m3937:	RET	M			; F8
m3938:	CALL	Next_Address		; CD3D7A
m393B:	LD	C,$08			; 0E08
;
L393D:	CALL	Next_Byte		; CD727A
m3940:	DEC	C			; 0D
m3941:	JR	Z,L394E			; 280B
;
L3943:	CALL	Check_Finish		; CD817B
m3946:	JR	NC,L393D		; 30F5
;
L3948:	LD	D,$0B			; 160B
m394A:	CALL	Print_String		; CD537B
m394D:	RET				; C9
;
; routine 2:	DEFB	 write
;
write:
L394E:	CALL	L3948			; CD4879
m3951:	JR	L3934			; 18E1
;
function_03:
;
L3953:	LD	A,$01			; 3E01
m3955:	LD	BC,data_for_input_prompt_messages
					; 01937B
m3958:	CALL	Get_A_addresses		; CD0279
m395B:	CALL	CLS			; CD2A0A
;
L395E:	CALL	SCROLL			; CD0E0C
m3961:	CALL	Next_Address			; CD3D7A
m3964:	LD	DE,$1CE8		; 11E81C
m3967:	CALL	Input_String			; CDA57F
;
L396A:	BIT	0,L			; CB45
m396C:	JR	Z,L3973			; 2805
;


m396E:	CALL	L3FAD			; CDAD7F
m3971:	JR	L396A			; 18F7
;
L3973:	LD	DE,(next_address_for_routine)
					; ED5BF87F
m3977:	CALL	Transfer			; CD0B7B
m397A:	LD	(next_address_for_routine),DE
					; ED53F87F
m397E:	LD	A,$76			; 3E76
m3980:	RST	$10			; D7
m3981:	JR	L395E			; 18DB
;
; prints data associated with RST 08 or RST 28
;
L3983:	DEC	C			; 0D
m3984:	JR	NZ,L39AA		; 2024
;
m3986:	LD	C,$04			; 0E04
m3988:	LD	D,$13			; 1613
m398A:	CALL	Print_String		; CD537B
m398D:	JR	L39A7			; 1818
;
m398F:	LD	A,B			; 78
m3990:	CP	1			; FE01
m3992:	JR	NZ,L39AE		; 201A
;
m3994:	LD	HL,UNUSED_16		; 217B40
m3997:	LD	(HL),$62		; 3662
m3999:	INC	HL			; 23
m399A:	LD	(HL),$7A		; 367A
;
L399C:	LD	D,$13			; 1613
m399E:	CALL	Print_String		; CD537B
;
L39A1:	LD	HL,data_and_pointers_for_disassembler		; 21F97C
m39A4:	CALL	Add_String		; CD9F7B
;
L39A7:	CALL	Next_Address			; CD3D7A
;
L39AA:	CALL	Next_Byte			; CD727A
m39AD:	RET				; C9
;
L39AE:	CP	5			; FE05
m39B0:	RET	NZ			; C0
;
m39B1:	LD	HL,UNUSED_16		; 217B40
m39B4:	LD	(HL),$68		; 3668
m39B6:	INC	HL			; 23
m39B7:	LD	(HL),$7A		; 367A
m39B9:	LD	C,4			; 0E04
m39BB:	CALL	L399C			; CD9C79
;
L39BE:	LD	A,B			; 78
m39BF:	CP	$34			; FE34
m39C1:	RET	Z			; C8
;
m39C2:	CALL	L3983			; CD8379
m39C5:	JR	L39BE			; 18F7
;
; Data Calculates absolute address for JR instructions
; and adds number and addresses to mnemonic
;
calculate_abs_address:
m39C7:	CALL	Next_Byte			; CD727A
m39CA:	XOR	A			; AF
m39CB:	BIT	7,B			; CB78
m39CD:	JR	Z,L39D0			; 2801
;
m39CF:	CPL				; 2F
;
L39D0:	LD	C,B			; 48
m39D1:	LD	B,A			; 47
m39D2:	LD	HL,(next_address_for_routine)		; 2AF87F
m39D5:	ADD	HL,BC			; 09
m39D6:	EX	DE,HL			; EB
m39D7:	LD	HL,L3D00		; 21007D
m39DA:	LD	A,E			; 7B
m39DB:	CALL	L3A89			; CD897A
m39DE:	DEC	HL			; 2B
m39DF:	LD	A,D			; 7A
m39E0:	CALL	L3A89			; CD897A
m39E3:	INC	HL			; 23
m39E4:	RES	7,(HL)			; CBBE
m39E6:	DEC	HL			; 2B
m39E7:	JR	L3A04			; 181B
;
m39E9:	CALL	Next_Byte			; CD727A
m39EC:	DEC	HL			; 2B
m39ED:	JR	L3A04			; 1815
;
m39EF:	CALL	L3A07			; CD077A
m39F2:	JR	L3A04			; 1810
;
m39F4:	CALL	Next_Byte			; CD727A
m39F7:	DEC	HL			; 2B
m39F8:	JR	L39FD			; 1803
;
m39FA:	CALL	L3A07			; CD077A
;
L39FD:	DEC	HL			; 2B
m39FE:	CALL	L3BA4			; CDA47B
m3A01:	LD	HL,$7C0D		; 210D7C
;
L3A04:	JP	L3BA4			; C3A47B
;
L3A07:	LD	HL,L3D00		; 21007D
m3A0A:	CALL	L3A75			; CD757A
m3A0D:	CALL	Next_Byte			; CD727A
m3A10:	RES	7,(HL)			; CBBE
m3A12:	DEC	HL			; 2B
m3A13:	RET				; C9
;
Input_Address:
;
L3A14:	PUSH	AF			; F5
m3A15:	PUSH	DE			; D5
m3A16:	LD	DE,$10E4		; 11E410
m3A19:	CALL	L3B3B			; CD3B7B
;
L3A1C:	LD	A,L			; 7D
m3A1D:	CP	E			; BB
m3A1E:	JR	Z,L3A25			; 2805
;
m3A20:	CALL	L3FAD			; CDAD7F
m3A23:	JR	L3A1C			; 18F7
;
L3A25:	POP	DE			; D1
m3A26:	CALL	L3B21			; CD217B
m3A29:	POP	AF			; F1
m3A2A:	DEC	A			; 3D
m3A2B:	JR	NZ,Input_Address	; 20E7
m3A2D:	RET				; C9
;
Initial:
;
m3A2E:	LD	HL,L3D42		; 21427D
m3A31:	LD	(HL),$5C		; 365C
m3A33:	DEC	HL			; 2B
m3A34:	LD	(HL),$09		; 3609
m3A36:	DEC	HL			; 2B
m3A37:	LD	(HL),$0F		; 360F
m3A39:	DEC	HL			; 2B
m3A3A:	DEC	HL			; 2B
m3A3B:	LD	(HL),$E0		; 36E0
;
Next_Address:
;
m3A3D:	LD	DE,$7FF9		; 11F97F
m3A40:	LD	HL,$7CFE		; 21FE7C
m3A43:	LD	A,(DE)			; 1A
m3A44:	CALL	L3A7F			; CD7F7A
m3A47:	DEC	DE			; 1B
m3A48:	LD	A,(DE)			; 1A
m3A49:	CALL	L3A7F			; CD7F7A
m3A4C:	XOR	A			; AF
m3A4D:	RST	$10			; D7
m3A4E:	RET				; C9
;
Octal:
;
; converts reg A to three octal digits on the stack, LS first, MS last.
;
m3A4F:	LD	A,B			; 78	; lowest octal digit
m3A50:	AND	%00000111		; E607
m3A52:	LD	C,A			; 4F
m3A53:	LD	A,B			; 78
m3A54:	PUSH	AF			; F5
m3A55:	AND	%00111000		; E638	; middle octal digit
m3A57:	RRCA				; 0F
m3A58:	RRCA				; 0F
m3A59:	RRCA				; 0F
m3A5A:	LD	B,A			; 47
m3A5B:	POP	AF			; F1
m3A5C:	AND	%11000000		; E6C0	; top octal digit
m3A5E:	RLCA				; 07
m3A5F:	RLC	A			; CB07
m3A61:	RET				; C9
;
; Cont, $RST
;
m3A62:	CALL	L39A1			; CDA179
;
L3A65:	JP	L382B			; C32B78
;
m3A68:	LD	C,4			; 0E04
m3A6A:	CALL	L39A1			; CDA179
m3A6D:	CALL	L39BE			; CDBE79
m3A70:	JR	L3A65			; 18F3
;
Next_Byte:
;
m3A72:	LD	HL,$7CFE		; 21FE7C
;
L3A75:	LD	DE,(next_address_for_routine)		; ED5BF87F
m3A79:	LD	A,(DE)			; 1A
m3A7A:	INC	DE			; 13
m3A7B:	LD	(next_address_for_routine),DE		; ED53F87F
;
L3A7F:	CALL	L3A89			; CD897A
m3A82:	RST	$10			; D7
m3A83:	INC	HL			; 23
m3A84:	LD	A,(HL)			; 7E
m3A85:	RES	7,A			; CBBF
m3A87:	RST	$10			; D7
m3A88:	RET				; C9
;
L3A89:	LD	B,A			; 47
m3A8A:	AND	%00001111		; E60F
m3A8C:	ADD	A,$1C			; C61C
m3A8E:	SET	7,A			; CBFF
m3A90:	LD	(HL),A			; 77
m3A91:	DEC	HL			; 2B
m3A92:	LD	A,B			; 78
m3A93:	AND	%11110000		; E6F0
m3A95:	RRA				; 1F
m3A96:	RRA				; 1F
m3A97:	RRA				; 1F
m3A98:	RRA				; 1F
m3A99:	ADD	A,$1C			; C61C
m3A9B:	LD	(HL),A			; 77
m3A9C:	RET				; C9
;
; Offsets
;
m3A9D:	BIT	0,B			; CB40
m3A9F:	JR	NZ,L3ABA		; 2019
;
m3AA1:	CALL	L3AB3			; CDB37A
m3AA4:	INC	DE			; 13
m3AA5:	RET				; C9

m3AA6:	LD	A,1			; 3E01
m3AA8:	BIT	0,B			; CB40
m3AAA:	JR	NZ,L3ACA		; 201E
;
m3AAC:	JR	L3AB3			; 1805
;
m3AAE:	BIT	0,B			; CB40
m3AB0:	JR	Z,L3AC1			; 280F
;
m3AB2:	INC	DE			; 13
;
L3AB3:	XOR	A			; AF
m3AB4:	JR	L3ACA			; 1814
;
m3AB6:	BIT	0,B			; CB40
m3AB8:	JR	Z,L3AC1			; 2807
;
L3ABA:	INC	DE			; 13
;
L3ABB:	LD	A,B			; 78
m3ABC:	RES	0,A			; CB87
m3ABE:	RRCA				; 0F
m3ABF:	JR	L3ACA			; 1809
;
L3AC1:	CALL	L3ABB			; CDBB7A
m3AC4:	INC	DE			; 13
m3AC5:	RET				; C9

m3AC6:	LD	A,B			; 78
m3AC7:	JR	L3ACA			; 1801
;
m3AC9:	LD	A,C			; 79
;
L3ACA:	INC	DE			; 13
m3ACB:	LD	H,D			; 62
m3ACC:	LD	L,E			; 6B
m3ACD:	LD	L,(HL)			; 6E
m3ACE:	LD	H,$7C			; 267C
m3AD0:	CALL	L3BA5			; CDA57B
m3AD3:	RET				; C9
;
Control:
;
m3AD4:	LD	A,(DE)			; 1A
m3AD5:	PUSH	AF			; F5
m3AD6:	AND	%00000111		; E607
m3AD8:	LD	HL,$7ADD		; 21DD7A
m3ADB:	JR	L3AFB			; 181E
;
m3ADD:	POP	AF			; F1
m3ADE:	PUSH	AF			; F5
m3ADF:	BIT	6,A			; CB77
m3AE1:	JR	Z,L3AF0			; 280D
;
m3AE3:	LD	HL,(VAR_7D3E)		; 2A3E7D
;
L3AE6:	BIT	2,L			; CB55
m3AE8:	LD	(HL),0			; 3600
m3AEA:	INC	HL			; 23
m3AEB:	JR	Z,L3AE6			; 28F9
;
m3AED:	LD	(VAR_7D3E),HL		; 223E7D
;
L3AF0:	AND	%00111000		; E638	; middle octal digit
m3AF2:	RRCA				; 0F
m3AF3:	RRCA				; 0F
m3AF4:	RRC	A			; CB0F
m3AF6:	JR	Z,L3B04			; 280C
;
m3AF8:	LD	HL,$7B04		; 21047B
;
L3AFB:	PUSH	HL			; E5
m3AFC:	INC	A			; 3C
m3AFD:	LD	H,$7D			; 267D
m3AFF:	LD	L,A			; 6F
m3B00:	LD	L,(HL)			; 6E
m3B01:	LD	H,$7A			; 267A
m3B03:	JP	(HL)			; E9
;
L3B04:	POP	AF			; F1
m3B05:	BIT	7,A			; CB7F
m3B07:	RET	NZ			; C0
;
m3B08:	INC	DE			; 13
m3B09:	JR	Control			; 18C9
;
Transfer:
;
;
m3B0B:	PUSH	BC			; C5
m3B0C:	LD	A,L			; 7D
m3B0D:	LD	L,$E0			; 2EE0
m3B0F:	SUB	L			; 95
m3B10:	RRCA				; 0F
m3B11:	LD	B,A			; 47
;
L3B12:	LD	A,(HL)			; 7E
m3B13:	CALL	L3B8C			; CD8C7B
m3B16:	INC	HL			; 23
m3B17:	ADD	A,(HL)			; 86
m3B18:	SUB	$1C			; D61C
m3B1A:	LD	(DE),A			; 12
m3B1B:	INC	DE			; 13
m3B1C:	INC	HL			; 23
m3B1D:	DJNZ	L3B12			; 10F3
m3B1F:	POP	BC			; C1
m3B20:	RET				; C9
;
L3B21:	PUSH	BC			; C5
m3B22:	LD	B,$02			; 0602
;
L3B24:	DEC	HL			; 2B
m3B25:	LD	C,(HL)			; 4E
m3B26:	DEC	HL			; 2B
m3B27:	LD	A,(HL)			; 7E
m3B28:	CALL	L3B8C			; CD8C7B
m3B2B:	ADD	A,C			; 81
m3B2C:	SUB	$1C			; D61C
m3B2E:	LD	(DE),A			; 12
m3B2F:	INC	DE			; 13
m3B30:	DJNZ	L3B24			; 10F2
m3B32:	POP	BC			; C1
m3B33:	LD	A,$76			; 3E76
m3B35:	RST	$10			; D7
m3B36:	RST	$10			; D7
m3B37:	RET				; C9
;
L3B38:	LD	DE,$10EF		; 11EF10
;
L3B3B:	CALL	L3833			; CD3378
m3B3E:	LD	H,$7E			; 267E
m3B40:	LD	A,(BC)			; 0A
m3B41:	LD	L,A			; 6F
m3B42:	CALL	Add_String		; CD9F7B
m3B45:	INC	BC			; 03
m3B46:	LD	A,(BC)			; 0A
m3B47:	LD	L,A			; 6F
m3B48:	INC	BC			; 03
m3B49:	CALL	L3BA4			; CDA47B
m3B4C:	CALL	Print_String		; CD537B
m3B4F:	CALL	Input_String			; CDA57F
m3B52:	RET				; C9
;
Print_String:
;
m3B53:	PUSH	BC			; C5
m3B54:	PUSH	DE			; D5
m3B55:	PUSH	HL			; E5
m3B56:	BIT	0,(IY+33)		; FDCB2146
m3B5A:	JR	Z,L3B64			; 2808
;
m3B5C:	LD	BC,($4039)		; ED4B3940
m3B60:	LD	C,D			; 4A
m3B61:	CALL	SET_FIELD			; CD0B09
;
L3B64:	LD	DE,workspace_7FE0	; 11E07F
m3B67:	LD	BC,(VAR_7D3E)		; ED4B3E7D
m3B6B:	LD	B,$00			; 0600
m3B6D:	LD	A,C			; 79
m3B6E:	SUB	$E0			; D6E0
m3B70:	LD	C,A			; 4F
m3B71:	CALL	PR_STR_4			; CD6B0B
m3B74:	BIT	1,(IY+33)		; FDCB214E
m3B78:	JR	Z,L3B7D			; 2803
;
m3B7A:	LD	A,$76			; 3E76
m3B7C:	RST	$10			; D7
;
L3B7D:	POP	HL			; E1
m3B7E:	POP	DE			; D1
m3B7F:	POP	BC			; C1
m3B80:	RET				; C9
;
Check_Finish:
;
m3B81:	LD	HL,(finish_address_for_routine)		; 2AFA7F
m3B84:	LD	DE,(next_address_for_routine)		; ED5BF87F
m3B88:	AND	A			; A7
m3B89:	SBC	HL,DE			; ED52
m3B8B:	RET				; C9
;
L3B8C:	SUB	$1C			; D61C
m3B8E:	RLCA				; 07
m3B8F:	RLCA				; 07
m3B90:	RLCA				; 07
m3B91:	RLCA				; 07
m3B92:	RET				; C9
;
data_for_input_prompt_messages:
;
mark_3B93:	DEFB	 $DD, $E3, $EB, $E3, $F2
mark_3B98:	DEFB	 $F8, $D5, $DC, $30, $E3, $D0, $E3
;
Add_String:				; for building mnemonic
;
m3B9F:	LD	A,$E0			; 3EE0
m3BA1:	LD	(VAR_7D3E),A		; 323E7D
;
L3BA4:	XOR	A			; AF
;
L3BA5:	PUSH	BC			; C5
m3BA6:	PUSH	DE			; D5
;
L3BA7:	AND	A			; A7
m3BA8:	JR	Z,L3BB5			; 280B
;
L3BAA:	BIT	7,(HL)			; CB7E
m3BAC:	JR	NZ,L3BB1		; 2003
;
m3BAE:	INC	HL			; 23
m3BAF:	JR	L3BAA			; 18F9
;
L3BB1:	DEC	A			; 3D
m3BB2:	INC	HL			; 23
m3BB3:	JR	L3BA7			; 18F2
;
L3BB5:	CALL	L3BBB			; CDBB7B
m3BB8:	POP	DE			; D1
m3BB9:	POP	BC			; C1
;
m3BBA:	RET				; C9
;
L3BBB:	LD	DE,(VAR_7D3E)		; ED5B3E7D
m3BBF:	LD	A,(HL)			; 7E
m3BC0:	BIT	7,A			; CB7F
m3BC2:	JR	NZ,L3BC9		; 2005
;
m3BC4:	CALL	L3BCB			; CDCB7B
m3BC7:	JR	L3BBB			; 18F2
;
L3BC9:	RES	7,A			; CBBF
L3BCB:	CP	$40			; FE40
m3BCD:	JR	NC,L3BD7		; 3008
;
m3BCF:	LD	(DE),A			; 12
m3BD0:	INC	DE			; 13
m3BD1:	LD	(VAR_7D3E),DE		; ED533E7D
m3BD5:	INC	HL			; 23
m3BD6:	RET				; C9
;
L3BD7:	INC	HL			; 23
m3BD8:	LD	(VAR_7D3E),DE		; ED533E7D
m3BDC:	PUSH	HL			; E5
m3BDD:	CP	$43			; FE43
m3BDF:	JR	NC,L3BE7		; 3006
;
m3BE1:	LD	H,$7D			; 267D
m3BE3:	LD	L,A			; 6F
m3BE4:	LD	L,(HL)			; 6E
m3BE5:	JR	L3BFB			; 1814
;
L3BE7:	CP	$64			; FE64
m3BE9:	JR	NC,L3BF0		; 3005
;
m3BEB:	LD	H,$7D			; 267D
m3BED:	LD	L,A			; 6F
m3BEE:	JR	L3BFB			; 180B
;
L3BF0:	LD	HL,L3BFE		; 21FE7B	; push return address on stack
m3BF3:	PUSH	HL			; E5
m3BF4:	LD	H,L3D00>>8
					; 267D		; base address
					
;;; 7BF4: 267D6F6E  mark_3BF0:  DEFB     $21, $FE, $7B,
;					 $E5, 
;					$26, $7D, 
;					$6F, $6E
m3BF6:	LD	L,A			; 6F
m3BF7:	LD	L,(HL)			; 6E		; read offset
m3BF8:	LD	H,L3900>>8		; 2679		; base address
m3BFA:	JP	(HL)			; E9
							; return here
;
L3BFB:	CALL	L3BBB			; CDBB7B
L3BFE:	POP	HL			; E1
m3BFF:	RET				; C9
;
data_for_mnemonics:
; lower case are ZX inverse characters
;          
mark_3C00:	DEFB  $A7, $A8, $A9, $AA, $AD, $B1, $C0, $A6
mark_3C08:	DEFB  $A6, $C1, $A6, $10, $43, $91, $10, $45
mark_3C10:	DEFB  $91, $E7, $E7, $C3, $C5, $C1, $C2, $62
mark_3C18:	DEFB  $A8, $45, $A8, $47, $D6, $49, $D6, $47
mark_3C20:	DEFB  $A6, $49, $A6, $29, $26, $A6, $28, $35
mark_3C28:	DEFB  $B1, $38, $28, $AB, $28, $28, $AB, $9C
mark_3C30:	DEFB  $9D, $9E, $9F, $A0, $A1, $A2, $A3, $35
mark_3C38:	DEFB  $3A, $38, $AD, $56, $31, $B1, $37, $2A
mark_3C40:	DEFB  $B9, $4B, $BD, $2F, $B5, $CD, $58, $A9
mark_3C48:	DEFB  $58, $A8, $38, $3A, $A7, $38, $C3, $26
mark_3C50:	DEFB  $33, $A9, $3D, $34, $B7, $34, $B7, $28
mark_3C58:	DEFB  $B5, $35, $34, $B5, $37, $38, $B9, $2F
mark_3C60:	DEFB  $B5, $80, $D3, $E2, $CB, $CB, $29, $AE
mark_3C68:	DEFB  $2A, $AE, $E5, $E8, $66, $1A, $A6, $4F
mark_3C70:	DEFB  $E6, $10, $5C, $11, $DA, $45, $DA, $80
mark_3C78:	DEFB  $80, $10, $41, $91, $5C, $DA, $CF, $CF
mark_3C80:	DEFB  $80, $CF, $80, $80, $80, $80, $33, $BF
mark_3C88:	DEFB  $BF, $33, $A8, $A8, $35, $B4, $35, $AA
mark_3C90:	DEFB  $B5, $B2, $47, $A8, $49, $A8, $C7, $C9
mark_3C98:	DEFB  $38, $31, $A6, $38, $37, $A6, $E4, $38
mark_3CA0:	DEFB  $C7, $27, $2E, $B9, $37, $2A, $B8, $38
mark_3CA8:	DEFB  $2A, $B9, $10, $28, $91, $33, $2A, $AC
mark_3CB0:	DEFB  $B3, $AE, $38, $C3, $58, $A8, $2E, $B2
mark_3CB8:	DEFB  $9C, $A4, $9D, $9E, $CD, $CD, $CD, $CD
mark_3CC0:	DEFB  $49, $A9, $47, $A9, $2E, $9A, $37, $9A
mark_3CC8:	DEFB  $CF, $CF, $80, $80, $5E, $1A, $DE, $E9
mark_3CD0:	DEFB  $E9, $E0, $E0, $E0, $E0, $A6, $A6, $AE
mark_3CD8:	DEFB  $B7, $80, $80, $AE, $A9, $2E, $B7, $29
mark_3CE0:	DEFB  $B7, $CD, $28, $B5, $E2, $D3, $34, $B9
mark_3CE8:	DEFB  $33, $34, $B5, $CB, $29, $2F, $33, $BF
mark_3CF0:	DEFB  $D1, $D1, $D1, $D1, $D1
L3CF5:		DEFB  $2D, $26, $31
mark_3CF8:	DEFB  $B9
;          
data_and_pointers_for_disassembler:
;          
mark_3CF9:	DEFB  $45, $2B, $A7, $10, $1D, $A9, $27
;
L3D00:		DEFB  $9F, $A6, $C9, $B3, $AE, $BB, $9D, $B6
mark_3D08:	DEFB  $C6, $2D, $B1, $2E, $BD, $2E, $BE, $10
mark_3D10:	DEFB  $41, $91, $10, $41, $15, $2A, $27, $91
mark_3D18:	DEFB  $CD, $D3, $D9, $DF, $3C, $E8, $EB, $EE
mark_3D20:	DEFB  $F3, $F3, $F3, $F5, $91, $81, $89, $6D
mark_3D28:	DEFB  $6A, $F9, $7B, $3A, $70, $9C, $A1, $76
mark_3D30:	DEFB  $A4, $AA, $AD, $FC, $B3, $96, $B8, $BB
mark_3D38:	DEFB  $C1, $C7, $87, $1B, $81, $A1
VAR_7D3E:	DEFB  $E4, $7F

pointer_3D40:	DEFB  $0F, $09		; points to 090F ???	must be in RAM!

L3D42:		DEFB  $5C, $27, $A8, $29, $AA, $37
mark_3D48:	DEFB  $B1, $37, $B7, $2A, $BD, $31, $A9, $26
mark_3D50:	DEFB  $9A, $2F, $B7, $34, $3A, $B9, $28, $A6
mark_3D58:	DEFB  $26, $A9, $1A, $C1, $38, $B5, $26, $AB
mark_3D60:	DEFB  $1A, $E9, $2E, $B3, $E9, $EF, $F4, $FA
mark_3D68:	DEFB  $8F, $C7, $FA, $17, $00, $E0, $17, $13
mark_3D70:	DEFB  $7A, $45, $00, $8A, $C5, $00, $F5, $59
mark_3D78:	DEFB  $3E, $13, $77, $7A, $45, $00, $92, $C5
mark_3D80:	DEFB  $9E, $58, $45, $13, $15, $AA, $C5, $6A
mark_3D88:	DEFB  $13, $72, $45, $0B, $07, $B2, $C5, $07
mark_3D90:	DEFB  $0B, $7F, $E8, $82, $87, $CB, $62, $5C
mark_3D98:	DEFB  $2F, $90, $B8, $6B, $7F, $46, $7E, $81
mark_3DA0:	DEFB  $00, $FA, $3E, $86, $7A, $43, $86, $92
mark_3DA8:	DEFB  $C5, $6A, $FF, $5F, $6A, $7A, $3B, $86
mark_3DB0:	DEFB  $92, $C5, $6A, $7F, $46, $7E, $82, $9E
mark_3DB8:	DEFB  $CF, $92, $00, $7A, $A1, $2F, $8A, $C5
mark_3DC0:	DEFB  $00, $7A, $A4, $2F, $8A, $C5, $00, $7A
mark_3DC8:	DEFB  $A7, $2F, $8A, $C5, $00, $7A, $63, $00
mark_3DD0:	DEFB  $92, $C5, $AA, $52, $62, $AA, $BA, $C5
mark_3DD8:	DEFB  $00, $50, $B2, $15, $A2, $C5, $13, $6A
mark_3DE0:	DEFB  $45, $11, $13, $9A, $C5, $13, $11, $00
mark_3DE8:	DEFB  $BA, $3E, $B0, $FA, $B6, $B8, $7F, $BC
mark_3DF0:	DEFB  $C4, $87, $D5, $B9, $E1, $D7, $BC, $E2
mark_3DF8:	DEFB  $D7, $FA, $19, $00, $D8, $37, $13, $6A
;
print_data_for_menu_and_routines:
;
mark_3E00:	DEFB	 $00, $00, $00, $00, $32, $2A, $33, $BA
mark_3E08:	DEFB	 $00, $00, $00, $00, $14, $14, $14, $94
mark_3E10:	DEFB	 $1C, $00, $35, $37, $2E, $33, $39, $00
mark_3E18:	DEFB	 $28, $34, $29, $AA, $1D, $00, $2D, $2A
mark_3E20:	DEFB	 $3D, $00, $29, $3A, $32, $B5, $1E, $00
mark_3E28:	DEFB	 $3C, $37, $2E, $39, $AA, $1F, $00, $2E
mark_3E30:	DEFB	 $33, $38, $2A, $37, $B9, $20, $00, $29
mark_3E38:	DEFB	 $2A, $31, $2A, $39, $AA, $21, $00, $39
mark_3E40:	DEFB	 $37, $26, $33, $38, $2B, $2A, $B7, $22
mark_3E48:	DEFB	 $00, $38, $2A, $26, $37, $28, $AD, $23
mark_3E50:	DEFB	 $00, $37, $2A, $35, $31, $26, $28, $AA
mark_3E58:	DEFB	 $24, $00, $26, $38, $38, $2A, $32, $27
mark_3E60:	DEFB	 $31, $2A, $B7, $25, $00, $37, $3A, $33
mark_3E68:	DEFB	 $00, $28, $34, $29, $AA, $26, $00, $28
mark_3E70:	DEFB	 $26, $31, $28, $3A, $31, $26, $39, $34
mark_3E78:	DEFB	 $B7, $27, $00, $28, $2D, $37, $0D, $00
mark_3E80:	DEFB	 $29, $3A, $32, $B5, $28, $00, $26, $38
mark_3E88:	DEFB	 $28, $2E, $2E, $00, $29, $3A, $32, $B5
mark_3E90:	DEFB	 $29, $00, $37, $2A, $33, $3A, $32, $27
mark_3E98:	DEFB	 $2A, $B7, $2A, $00, $2E, $32, $26, $2C
mark_3EA0:	DEFB	 $2A, $B7, $2B, $00, $32, $2A, $33, $3A
mark_3EA8:	DEFB	 $00, $9E, $80, $80, $00, $00, $00, $00
mark_3EB0:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_3EB8:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_3EC0:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_3EC8:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
mark_3ED0:	DEFB	 $31, $2E, $32, $2E, $B9, $37, $34, $3A
mark_3ED8:	DEFB	 $39, $2E, $33, $2A, $80, $38, $39, $26
mark_3EE0:	DEFB	 $37, $39, $80, $26, $29, $29, $37, $2A
mark_3EE8:	DEFB	 $38, $38, $80, $2B, $2E, $33, $2E, $38
mark_3EF0:	DEFB	 $2D, $80, $1D, $00, $2B, $34, $37, $80
mark_3EF8:	DEFB	 $35, $37, $2E, $33, $39, $2A, $37, $80

; addresses of routines
mark_3F00:	DEFW	Disassemble		; $3823	; 
mark_3F02:	DEFW	hex_dump		; $3920	; 
mark_3F04:	DEFW	function_03	; $3953	; 
mark_3F06:	DEFW	null_function
mark_3F08:	DEFW	null_function
mark_3F0A:	DEFW	null_function
mark_3F0C:	DEFW	null_function
mark_3F0E:	DEFW	null_function
mark_3F10:	DEFW	null_function
mark_3F12:	DEFW	function_10		; $3813
mark_3F14:	DEFW	null_function
mark_3F16:	DEFW	null_function
mark_3F18:	DEFW	null_function
mark_3F1A:	DEFW	null_function
mark_3F1C:	DEFW	null_function
mark_3F1E:	DEFW	null_function
;
;
Read_Keyboard:
;
m3F20:	PUSH	DE			; D5
m3F21:	PUSH	BC			; C5
m3F22:	PUSH	HL			; E5
m3F23:	LD	HL,(LAST_K)		; 2A2540
m3F26:	PUSH	HL			; E5
;
L3F27:	LD	BC,(LAST_K)		; ED4B2540
m3F2B:	POP	HL			; E1
m3F2C:	PUSH	BC			; C5
m3F2D:	AND	A			; A7
m3F2E:	SBC	HL,BC			; ED42
m3F30:	JR	Z,L3F27			; 28F5
;
m3F32:	LD	A,C			; 79
m3F33:	INC	A			; 3C
m3F34:	JR	Z,L3F27			; 28F1
;
m3F36:	POP	HL			; E1
m3F37:	CALL	DECODE			; CDBD07
m3F3A:	LD	A,(HL)			; 7E
m3F3B:	POP	HL			; E1
m3F3C:	POP	BC			; C1
m3F3D:	POP	DE			; D1
m3F3E:	CP	$76			; FE76
m3F40:	RET	Z			; C8
;
m3F41:	CP	$77			; FE77
m3F43:	RET	Z			; C8
;
m3F44:	CP	0			; FE00
m3F46:	JR	NZ,L3F4D		; 2005
;
m3F48:	CALL	CLS			; CD2A0A
m3F4B:	RST	8			; CF
m3F4C:	INC	C			; 0C
;
L3F4D:	CP	$1C			; FE1C
m3F4F:	JR	C,Read_Keyboard			; 38CF
;
m3F51:	CP	$2C			; FE2C
m3F53:	JR	NC,Read_Keyboard		; 30CB
;
m3F55:	RET				; C9
;
; Menu
;
m3F56:	LD	HL,UNUSED_8		; 212140
m3F59:	BIT	7,(HL)			; CB7E
m3F5B:	JR	Z,L3F61			; 2804
;
L3F5D:	LD	HL,(UNUSED_16)		; 2A7B40
m3F60:	JP	(HL)			; E9
;
L3F61:	LD	HL,$7E00		; 21007E
m3F64:	LD	B,$14			; 0614
m3F66:	LD	A,$03			; 3E03
m3F68:	LD	(UNUSED_8),A		; 322140
m3F6B:	LD	DE,$18E1		; 11E118
;
L3F6E:	CALL	Add_String		; CD9F7B
m3F71:	CALL	Print_String		; CD537B
m3F74:	DJNZ	L3F6E			; 10F8
;
m3F76:	LD	BC,$7B99		; 01997B
m3F79:	CALL	L3B3B			; CD3B7B
m3F7C:	DEC	HL			; 2B
m3F7D:	LD	A,(HL)			; 7E
m3F7E:	SUB	$1C			; D61C
m3F80:	LD	B,A			; 47
m3F81:	RLCA				; 07
m3F82:	LD	L,A			; 6F
m3F83:	LD	H,$7F			; 267F
m3F85:	LD	A,(HL)			; 7E
m3F86:	INC	HL			; 23
m3F87:	LD	H,(HL)			; 66
m3F88:	LD	L,A			; 6F
m3F89:	PUSH	HL			; E5
m3F8A:	PUSH	BC			; C5
m3F8B:	CALL	CLS				; CD2A0A
m3F8E:	POP	BC			; C1
m3F8F:	LD	A,$E0			; 3EE0
m3F91:	LD	(VAR_7D3E),A		; 323E7D
m3F94:	LD	A,B			; 78
m3F95:	LD	HL,$7E10		; 21107E
m3F98:	CALL	L3BA5			; CDA57B
m3F9B:	LD	D,$1A			; 161A
m3F9D:	CALL	Print_String		; CD537B
m3FA0:	LD	A,$76			; 3E76
m3FA2:	RST	$10			; D7
m3FA3:	RST	$10			; D7
m3FA4:	RET				; C9
;
Input_String:				; the heart of all routines
;
m3FA5:	LD	A,$01			; 3E01
m3FA7:	LD	(UNUSED_8),A		; 322140
m3FAA:	LD	HL,workspace_7FE0	; 21E07F
;
L3FAD:	LD	(HL),$17		; 3617
m3FAF:	CALL	L3FC0			; CDC07F
;
L3FB2:	CALL	Read_Keyboard		; CD207F
m3FB5:	CP	$76			; FE76
m3FB7:	JR	NZ,L3FC9		; 2010
;
m3FB9:	LD	A,$E0			; 3EE0
m3FBB:	CP	L			; BD
m3FBC:	JR	Z,L3FB2			; 28F4
;
L3FBE:	LD	(HL),$00		; 3600
;
L3FC0:	INC	HL			; 23
m3FC1:	LD	(VAR_7D3E),HL		; 223E7D
m3FC4:	CALL	Print_String		; CD537B
m3FC7:	DEC	HL			; 2B
m3FC8:	RET				; C9
;
L3FC9:	CP	$77			; FE77
m3FCB:	JR	NZ,L3FD8		; 200B
;
m3FCD:	LD	A,$E0			; 3EE0
m3FCF:	CP	L			; BD
m3FD0:	JR	Z,L3FAD			; 28DB
;
m3FD2:	CALL	L3FBE			; CDBE7F
m3FD5:	DEC	HL				; 2B
m3FD6:	JR	L3FAD			; 18D5
;
L3FD8:	LD	(HL),A			; 77
m3FD9:	LD	A,E			; 7B
m3FDA:	CP	L			; BD
m3FDB:	JR	Z,L3FAD			; 28D0
#ENDIF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
m3FDD:	INC	HL			; 23
m3FDE:	JR	L3FAD			; 18CD
;
; mnemonic string, ram area for mnemonic to be built up
;
workspace_7FE0:	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
		DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
;
; spare bytes
; mark_3FF0:
	DEFB	 $00, $00, $00, $00, $00, $00, $00, $00
;
next_address_for_routine:
; VAR_7F F8:
	DEFB	 $00, $00
;
finish_address_for_routine:
; VAR_7FFA:
	DEFB	 $00, $00
;
; spare bytes
;
mark_3FFC:	DEFB	 $00, $00, $00
null_function:
mark_3FFF:	DEFB	 $C9	;	ret





