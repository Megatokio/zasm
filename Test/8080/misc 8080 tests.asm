#!/usr/local/bin/zasm --asm8080 -o original/

; –––––––––––––––––––––––––––––––––––––––––––––––––
; 				misc. tests for asm8080
; –––––––––––––––––––––––––––––––––––––––––––––––––


	org 0
	db	0



; function 'opcode()' for asm8080:
;
#assert 	opcode(NOP) == 0x00
#assert 	opcode(LXI B,NN) == 0x01
#assert 	opcode(STAX B) == 0x02
#assert 	opcode(MVI B, N) == 0x06
#assert 	opcode(STAX D) == 0x12
#assert 	opcode(INX D) == 0x13
#assert 	opcode(INR D) == 0x14
#assert 	opcode(RAR) == 0x1f
#assert 	opcode(DAA) == 0x27
#assert 	opcode(INR L) == 0x2c
#assert 	opcode(DCR L) == 0x2d
#assert 	opcode(INX SP) == 0x33
#assert 	opcode(LDA NN) == 0x3a
#assert 	opcode(MVI A,N) == 0x3e
#assert 	opcode(CMC) == 0x3f
#assert 	opcode(MOV B,L) == 0x45
#assert 	opcode(MOV D,E) == 0x53
#assert 	opcode(MOV E,L) == 0x5d
#assert 	opcode(MOV H,M) == 0x66
#assert 	opcode(MOV L,M) == 0x6e
#assert 	opcode(MOV M,L) == 0x75
#assert 	opcode(HLT) == 0x76
#assert 	opcode(MOV A,M) == 0x7e
#assert 	opcode(MOV A,A) == 0x7f
#assert 	opcode(ADD E) == 0x83
#assert 	opcode(ADC H) == 0x8c
#assert 	opcode(SUB M) == 0x96
#assert 	opcode(SBB D) == 0x9a
#assert 	opcode(ANA D) == 0xa2
#assert 	opcode(XRA D) == 0xaa
#assert 	opcode(ORA L) == 0xb5
#assert 	opcode(CMP M) == 0xbe
#assert 	opcode(CMP A) == 0xbf
#assert 	opcode(RNZ) == 0xc0
#assert 	opcode(ADI N) == 0xc6
#assert 	opcode(RZ) == 0xc8
#assert 	opcode(RET) == 0xc9
#assert 	opcode(JZ NN) == 0xca
#assert 	opcode(CALL NN) == 0xcd
#assert 	opcode(IN N) == 0xdb
#assert 	opcode(CC NN) == 0xdc
#assert 	opcode(POP H) == 0xe1
#assert 	opcode(RPE) == 0xe8
#assert 	opcode(PCHL) == 0xe9
#assert 	opcode(XCHG) == 0xeb
#assert 	opcode(XRI N) == 0xee
#assert 	opcode(CP NN) == 0xf4
#assert 	opcode(PUSH PSW) == 0xf5
#assert 	opcode(ORI N) == 0xf6
#assert 	opcode(RM) == 0xf8
#assert 	opcode(SPHL) == 0xf9
#assert 	opcode(CM NN) == 0xfc
#assert 	opcode(CPI N) == 0xfe
#assert 	opcode(RST 7) == 0xff






