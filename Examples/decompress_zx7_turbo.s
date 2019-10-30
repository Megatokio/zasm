; -----------------------------------------------------------------------------
; ZX7 decoder by Einar Saukas & Urusergi
; "Turbo" version (88 bytes, 25% faster)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

decompress_zx7_turbo::
	ld	a, $80
;dzx7t_copy_byte_loop:
1$:	ldi			; copy literal byte
;dzx7t_main_loop:
2$:	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	jr	nc, 1$		; dzx7t_copy_byte_loop: next bit indicates either literal or sequence

; determine number of bits used for length (Elias gamma coding)
	push	de
	ld	bc, 1
	ld	d, b
;dzx7t_len_size_loop:
3$:	inc	d
	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	jr	nc, 3$		; dzx7t_len_size_loop
	jp	5$		; dzx7t_len_value_start

; determine length
;dzx7t_len_value_loop:
4$:	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	rl	c
	rl	b
	jr	c, 9$		; dzx7t_exit: check end marker
;dzx7t_len_value_start:
5$:	dec	d
	jr	nz, 4$		; dzx7t_len_value_loop
	inc	bc		; adjust length

; determine offset
	ld	e, (hl)		; load offset flag (1 bit) + offset value (7 bits)
	inc	hl
	sll	e		; note: illegal instruction "SLL E" aka "SLS E"
	jr	nc, 6$		; dzx7t_offset_end: if offset flag is set, load 4 extra bits
	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits no more bits left?
	rl	d		; insert first bit into D
	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	rl	d		; insert second bit into D
	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	rl	d		; insert third bit into D
	add	a, a		; check next bit
	call	z, 7$		; dzx7t_load_bits: no more bits left?
	ccf
	jr	c, 6$		; dzx7t_offset_end
	inc	d		; equivalent to adding 128 to DE
;dzx7t_offset_end:
6$:	rr	e		; insert inverted fourth bit into E

; copy previous sequence
	ex	(sp), hl	; store source, restore destination
	push	hl		; store destination
	sbc	hl, de		; HL = destination - offset - 1
	pop	de		; DE = destination
	ldir
;dzx7t_exit:
9$:	pop	hl		; restore source address (compressed data)
	jp	nc, 2$		; dzx7t_main_loop

;dzx7t_load_bits:
7$:	ld	a, (hl)		; load another group of 8 bits
	inc	hl
	rla
	ret
; -----------------------------------------------------------------------------
