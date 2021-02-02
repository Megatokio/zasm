#!/usr/local/bin/zasm --casefold -o original/


.org $100

L7FFD	EQU	$7FFD	;data port

	LD	A, hi(L7FFD)
	IN	A, (lo(L7FFD))

	LD	A, HI(L7FFD)
	IN	A, (LO(L7FFD))









