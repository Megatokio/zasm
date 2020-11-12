#!/usr/local/bin/zasm --8080 -o original/


#target ram


; ––––––––––––––––––––––––––
; dummy 'real code':
; ––––––––––––––––––––––––––

#code CODE, 0, *
	jp  $

.org 0x38
L1:	push hl
	ld  hl,(systime)
	inc hl
	ld  (systime),hl
	pop hl
	ei
	ret

systime: dw  0



; -------------------------------------------
; test
; -------------------------------------------

#test TEST1, 0x400
	.test-timeout 10 ms

	nop
	.expect cc = 4

	; these all must make the test fail:

	;db	0xdd,1,2
	;db	0xed,3,4
	;db	0xCB,2,3
	;db	0xfd,1,2
	;db	opcode(exx)
	;db	opcode(ex af,af')
	;db	opcode(jr dis)
	;db	opcode(djnz dis)

	nop
	nop











