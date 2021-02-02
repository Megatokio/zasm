

#code CODE


; ----------------------------
; mult (HLDE A -- AHLDE)
;
;   mod DE' HL'

HLDE_times_A:

    push hl
    ld hl,0		; hl' = 0
    exx
    pop de      ; de = i32.hi, de' = i32.lo
    ld	l,0		; hl = 0   ((h will be shifted out))
    exx			; de = i32.lo, de' = i32.hi

;mul_axdedel:
    scf
    adc	a
    jr	c,3$

; 0 --> don't add de:
1$:	add hl,hl \ exx \ adc hl,hl \ exx
2$:	add	a		; -> cy=bit7, z=!a
	jr	nc,1$
	jr	z,4$	; this was the stopper

; 1 --> add de:
3$:	add hl,hl \ exx \ adc hl,hl \ exx
	add hl,de \ exx \ adc hl,de \ exx
	jr	2$

4$:	push hl
	exx
	pop	de
	ret

