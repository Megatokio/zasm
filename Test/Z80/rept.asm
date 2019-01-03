#!/usr/local/bin/zasm -o original/


.org $8000
    di
    halt

error:
    .dup 13
	    db 0
    .edup

	.rept 8
		.asciz "Hallo"
	.endm

