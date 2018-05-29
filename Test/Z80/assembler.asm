#target bin

#code ram,65268,$10000-65268

print_str:	
	ld	a,	0
	ld	(cursor),a		

strloop:
	ld	hl,	string	
	ld	a,	(cursor)	
	ld	e,	a		
	ld	d,	0		;loads char position
	add	hl,	de		;finds position	
	ld	a,	(hl)		;loads character	
	cp	0	
	jp	z,	end		;end of string (null terminated)
	ld	c,	a		
	call	print_char		;prints char with subroutine	
	
	ld	a,	(cursor)	;increases cursor by 1
	inc	a	
	ld	(cursor),a	
	;jp	strloop	
end:	ret

print_char:				;prints character in c (ascii) at position (de)
	ld	hl,	16384		;screen address
	add	hl,	de		;positioner
	ld	d,	h	
	ld	e,	l	
	ld	hl,	(23606)		;character set address

	ld	b,	0	
	sla	c	
	rl	b	
	sla	c	
	rl	b	
	sla	c	
	rl	b	

	add	hl,	bc		;address of char to be printed
	ld	b,	8	
chloop:	
	ld	a,	(hl)	
	ld	(de),	a	
	inc	hl	
	inc	d	
	djnz	chloop	

	ret	

string:	defm	'hello world!'	;null terminated string
	defb	0,	0,	0	
cursor:	defb	0		

#end