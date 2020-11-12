#!/usr/local/bin/zasm --z180 -o original/


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

#test TEST1, 1000
	.test-timeout 100 ms
	nop
	.expect cc = 3

	nop
	nop

	ld	b,123
	ld	c,66
	mult bc
	.expect bc = 123*66


	; this must not compile:
	;ld	xh,b
	;db	opcode(ld xh,b)

	; these must make the test fail:
	;db	0xDD, opcode(ld h,b)




; *** TODO ***



