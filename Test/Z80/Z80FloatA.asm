
	org 1000

f24_exp2:
	db 0
f24_exp1:
	db 0
f24_exp4:
	db 0
f24_exp3:
	db 0
f24_exp6:
	db 0
f24_exp5:
	db 0
f24_man1:
	dw 0
f24_man2:
	dw 0
f24_man3:
	dw 0
f24_man4:
	dw 0
f24_man5:
	dw 0
f24_man6:
	dw 0
tempbyte1:
	db 0
tempword1:
	dw 0

Float24Add:
;BHL+CDE
    ld a,c
    xor 40h
    ld c,a
    rlc c
    ld a,b
    rla
    rlc b
    xor 80h
    sub c
    jr z,f24Shifted
    jr nc,f24ShiftDE
    rra
    cp -16
    jr nc,$+6
    ld a,c
		ex de,hl
		rrca
		ret
    srl h
		rr l
    inc a
		jr nz,$-5
    jr nc,$+3
		inc hl
    ld a,b
		and 1
		ld b,a
		ld a,c
		and $FE
		xor 80h
		or b
		jp f24Shifted+1
f24ShiftDE:
    rra
    cp 16
    jr c,$+5
    ld a,b
		rrca
		ret
    srl d
		rr e
    dec a
		jr nz,$-5
    jr nc,$+3
		inc de
    ld a,c
		and 1
		ld c,a
		ld a,b
		and $FE
		or c
		ld c,a
f24Shifted:
    ld a,b
		rrca
		ld b,a
		ld a,c
		rrca
		ld c,a
		xor b
		ld a,b
		jp m,f24Sub
    add hl,de
		ret nc
    ld c,0
		inc c
		inc c
		rr h
		rr l
		jr nc,$+8
		inc l
		jr nz,$+5
		inc h
    jr z,$-12
    rlca
		add a,c
		jp p,$+10
    jr c,$+7
		bit 6,b
		rrca
		jr z,$+4
    rrca
		ret
SetInf:
    ld hl,$FFFF
    rla
    ld a,h
    rra
    ld b,a
    ret
f24Sub:
    sbc hl,de
    jr nc,normalise24
    xor 80h
    ld b,a
    xor a
		sub l
		ld l,a
    sbc a,a
		sub h
		ld h,a
    ld a,b
normalise24:
    bit 7,h
		ret nz
    ld a,b
		add a,a
    cp $82
		ret z
    dec a
		dec a
    add hl,hl
    rlc b
		rra
		ld b,a
    jp normalise24

Float24Sub:
;BHL-CDE
    ld a,80h
    xor c
    ld c,a
    jp Float24Add
