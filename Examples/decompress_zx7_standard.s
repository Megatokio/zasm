; -----------------------------------------------------------------------------
; ZX7 decoder by Einar Saukas, Antonio Villena & Metalbrain
; "Standard" version (69 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

decompress_zx7_standard::
	ld	a, $80
; dzx7s_copy_byte_loop:
1$:	ldi			; copy literal byte
;dzx7s_main_loop:
3$:	call	2$		; dzx7s_next_bit
	jr	nc, 1$		; dzx7s_copy_byte_loop: next bit indicates either literal or sequence

; determine number of bits used for length (Elias gamma coding)
	push	de
	ld	bc, 0
	ld	d, b
;dzx7s_len_size_loop:
4$:	inc	d
	call	2$		; dzx7s_next_bit
	jr	nc, 4$		; dzx7s_len_size_loop

; determine length
;dzx7s_len_value_loop:
5$:	call	nc, 2$		; dzx7s_next_bit
	rl	c
	rl	b
	jr	c, 9$		; dzx7s_exit: check end marker
	dec	d
	jr	nz, 5$		; dzx7s_len_value_loop
	inc	bc		; adjust length

; determine offset
	ld	e, (hl)	 	; load offset flag (1 bit) + offset value (7 bits)
	inc	hl
	sll	e		; note: illegal instruction "SLL E" aka "SLS E"
	jr	nc, 6$		; dzx7s_offset_end: if offset flag is set, load 4 extra bits
	ld	d, $10		; bit marker to load 4 bits
;dzx7s_rld_next_bit:
7$:	call	2$		; dzx7s_next_bit
	rl	d		; insert next bit into D
	jr	nc, 7$		; dzx7s_rld_next_bit: repeat 4 times, until bit marker is out
	inc	d		; add 128 to DE
	srl	d		; retrieve fourth bit from D
;dzx7s_offset_end:
6$:	rr	e		; insert fourth bit into E

; copy previous sequence
	ex	(sp), hl	; store source, restore destination
	push	hl		; store destination
	sbc	hl, de		; HL = destination - offset - 1
	pop	de		; DE = destination
	ldir
;dzx7s_exit:
9$:	pop	hl		; restore source address (compressed data)
	jr	nc, 3$		; dzx7s_main_loop
; dzx7s_next_bit:
2$:	add	a, a		; check next bit
	ret	nz		; no more bits left?
	ld	a, (hl)	 	; load another group of 8 bits
	inc	hl
	rla
	ret
; -----------------------------------------------------------------------------
