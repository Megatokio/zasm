; -----------------------------------------------------------------------------
; ZX7 decoder by Einar Saukas, Antonio Villena & Metalbrain
; with additional size-efficient speed optimizations by introspec ("Life on Mars" version 1)
; 214 bytes long and is always faster than "mega" decompressor (by about 4% on average)
; drop me an email if you have any comments/ideas/suggestions: zxintrospec@gmail.com
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

;
; first block is where the entry point is and all the literal copying codes are 
; (fairly well optimized, i think)
;
decompress_zx7_fastest::
dzx7_lom:
	ld	ix, dzx7l_main_loop
	ld	a, $80
	jr	dzx7l_copy_byte_loop	; the entry is ugly, but it helps a lot to speed things up

dzx7l_reload:	
	ld	a, (hl)
	inc	hl
	rla
	jr	c, dzx7l_process_ref
	DUP	3			; increasing this number speeds things up a little (max allowed is 7)
	ldi
	add	a
	jr	c, dzx7l_process_ref
	EDUP

dzx7l_copy_byte_loop:
	ldi				; copy literal byte

dzx7l_main_loop:
	DUP	2			; the more the better, but it may/will break down some JR optimizations
	add	a
	jr	z, dzx7l_reload
	jr	c, dzx7l_process_ref
	ldi
	EDUP
	add	a
	jr	z, dzx7l_reload
	jp	nc,dzx7l_copy_byte_loop	; next bit indicates either literal or sequence
	
;
; determine number of bits used for length (Elias gamma coding) (NB: not too ugly, but...)
;
dzx7l_process_ref:
	push	de
	ld	bc, 1

	ld	d, b
	add	a
	jr	z, dzx7l_reload_size1
	jp	c, dzx7l_len_value_done

dzx7l_len_size_loop:
	inc	d
	add	a
	jr	z, dzx7l_reload_size2
	jp	c, dzx7l_len_value_loop
	jp	dzx7l_len_size_loop

dzx7l_reload_size1:
	ld	a, (hl)
	inc	hl
	rla
	jp	c, dzx7l_len_value_done
	DUP	1			; values above 1 speed things up slightly, but not by much - not really worth it
	inc	d
	add	a
	jp	c, dzx7l_len_value_loop
	EDUP
	jp	dzx7l_len_size_loop

dzx7l_reload_size2:
	ld	a, (hl)
	inc	hl
	rla
	jp	c, dzx7l_len_value_loop
	jp	dzx7l_len_size_loop

;
; the length of the reference is determined here 
; (NB: kinda ugly; the commented out sections runs faster, but takes too much space. DJNZ?)
;
dzx7l_exit:
	pop	de
	ret

dzx7l_len_value_reload:
	ld	a, (hl)
	inc	hl
;	rla
;	rl	c
;dzx7l_len_value_bincluded:
;	rl	b
;	jr	c, dzx7l_exit		; check end marker
;	dec	d
;	jp	z, dzx7l_len_value_done
;
dzx7l_len_value_loop2:
	adc	a
	jr	z, dzx7l_len_value_reload
	rl	c
dzx7l_len_value_bincluded:
	rl	b
	jr	c, dzx7l_exit		; check end marker
	dec	d
	jr	nz, dzx7l_len_value_loop2
	jp	dzx7l_len_value_done

dzx7l_len_value_loop:
	add	a
	jr	z, dzx7l_len_value_reload
	rl	c
	jr	c, dzx7l_len_value_bincluded
dzx7l_len_value_start:
	dec	d
	jr	nz, dzx7l_len_value_loop
dzx7l_len_value_done:
	inc     bc			; adjust length

;
;  the code that determines offset (pretty neat, actually)
;
	ld	e, (hl)			; load offset flag (1 bit) + offset value (7 bits)
	inc	hl
	bit	7, e
	jr	z, dzx7l_copying	; if offset flag is set, load 4 extra bits
	add	a
	jr	z, dzx7l_reload_1
	rl	d
	add	a
	jr	z, dzx7l_reload_2
	rl	d
	add	a
	jr	z, dzx7l_reload_3
	rl	d
	add	a
	jr	z, dzx7l_reload_4	
	jr	nc, dzx7l_copying	; we need to put 4-bit value into D, then INC D, then SRL D : RR E
dzx7l_offset_eoverflow:
	res	7, e			; since bit 7 of E is already 1, we do nothing when NC or RES 7,E : INC D
	inc	d
dzx7l_copying:
	ex	(sp), hl		; store source, restore destination
	push	hl			; store destination
	scf
	sbc	hl, de			; HL = destination - offset - 1
	pop	de			; DE = destination
	ldir				; copy previous sequence
	pop	hl			; restore source address (compressed data)
	jp	(ix)

dzx7l_reload_1:
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a
	rl	d
	add	a
	rl	d
	add	a
	jr	nc, dzx7l_copying
	jp	dzx7l_offset_eoverflow

dzx7l_reload_2:
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a
	rl	d
	add	a
	jr	nc, dzx7l_copying
	jp	dzx7l_offset_eoverflow

dzx7l_reload_3:
	ld	a, (hl)
	inc	hl
	rla
	rl	d
	add	a
	jr	nc, dzx7l_copying
	jp	dzx7l_offset_eoverflow

dzx7l_reload_4:
	ld	a, (hl)
	inc	hl
	rla
	jr	nc, dzx7l_copying
	jp	dzx7l_offset_eoverflow

; -----------------------------------------------------------------------------
