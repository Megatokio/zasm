#!/usr/local/bin/zasm --flatops -o original/
	org	0
	
	db	1+2*3		; 9 (not 7)
	db	3+44%5		; 2 (not 7)
	db	3*4/5		; 2
	db	266+26 % 256	; result < 256
	