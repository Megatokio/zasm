#target	    bin
#code	    ram, $2000, $2FFF

leds:		equ	$ff		; Programmable LED's	
urtdat:		equ	$80		; 8251 UART ports
urtcnt:		equ	$81

		di

		ld	a, 0
		out	(leds), a

		ld	hl, res8251
		ld	b, $06
intlp:		ld	a, (hl)
		out	(urtcnt), a
		inc	hl
		dec	b
		jp	nz, intlp

mainloop:
rwait:		in	a, (urtcnt)
		and	a, $02		; Mask off RxRDY status
		cp	a, $02		; Any new characters?
		jp	nz, rwait
		in	a, (urtdat)
		out	(leds), a
		ld	c, a

twait:		in	a, (urtcnt)
		and	a, $01		; Mask off TxRDY status
		cp	a, $01		; Rre we ready?
		jp	nz, twait

		ld	a, c
		out	(urtdat), a
		jp	mainloop

res8251:	db $00,$00,$00,$40,$4D,$37

#end
