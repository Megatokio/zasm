#target bin
#code ram,65268, $10000 - 65268

start:
	ld	a,	65	
	ld	de,	0	
	call	print_char	
	ret	

;******************************************************************
;		PRINT STRING
;******************************************************************

;print_str:
;	ld	hl,	(cursor)	;loads hl with start of string
;	ld	bc,	string	
;	add	hl,	bc	
	
;str_l:		
;	ld	a,	(hl)	
;	cp	0			;null termination check
;	jp	z,	break_l	
;	ld	de,	(cursor)	;position = ascii (for now!)	
;	call	print_char		;prints character
;	ld	hl,	(cursor)	;increase cursor
;	inc	hl	
;	ld	(cursor), hl	
;	ld	bc,	string		;add cursor to start of string
;	add	hl,	bc	
;	jp	str_l			;loops

;break_l:
;	ret	
;	
;******************************************************************
;		PRINT CHARACTER IN A (ASCII) AT	DE
;******************************************************************
print_char:						
	ld	b,	0		;load bc with a for *8
	ld	c,	a	
	
	sla	c	
	rl	b	
	sla	c	
	rl	b	
	sla	c	
	rl	b	
	
	;ld	hl,	16384		;sets position in screen file
	;add	hl,	de	
	;ld	d,	h	
	;ld	e,	l	
	
	;ld	hl,	(23606)	
	;add	hl,	bc		;address of char in charmap
	
	ld	hl,	(23606)	
	inc	h	
	inc	l	
	ld	de,	16384	
	
	ld	b,	8	
	ld	c,	0	
	
char_l:	
	ld	a,	(hl)	
	ld	(de),	a	
	inc	hl	
	inc	d	
	djnz	char_l	
	
	ret	

string:	defm	'hello world'+0	
cursor:	defb	0,	0	

#end	