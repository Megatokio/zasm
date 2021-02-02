

#code CODE


; ----------------------------
; AHLDE = HLDE * A

mult_HLDE_A:
    push hl
    ld hl,0			; hl' = 0
    exx
    pop de      	; de = i32.hi, de' = i32.lo

    ld  bc,$0800      ; b=8, c=0
    ld  h,c \ ld l,c  ; hl=0

1$:	exx \ add hl,hl \ exx \ adc hl,hl

    rla         	; get most-significant bit of accumulator
    jr nc,2$    	; If zero, skip addition

	exx \ add hl,de \ exx \ adc hl,de

    adc a,c
2$: djnz 1$

    push hl
    exx
    pop de
    ret

