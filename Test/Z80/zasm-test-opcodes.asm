#!/usr/local/bin/zasm --ixcbr2 -o original/
; –––––––––––––––––––––––––––––––––––––––––––––––––
; 		zasm test file
; –––––––––––––––––––––––––––––––––––––––––––––––––
;
; 2014-10-29 kio
; 2014-12-25 kio
; 2014-12-26 kio
; 2014-12-27 kio
; 2014-12-31 kio:	jp(hl) for 8080 allowed, removed 8080regs


; tests selector:

; other selectors are from command line options:

;		--ixcbr2		set n,(ix+dis),r	etc.
;		--ixcbxh		set n,(xh)		etc.
;		--8080			8080 instructions only
;		--z180			Z180 / HD64180 additional instructions


#target rom
#code CODE,0,*



; –––––––––––––––––––––––––––––––––––––––––––––––––
; 		test expressions
; –––––––––––––––––––––––––––––––––––––––––––––––––

#local
n5 	= 	5
n20	equ	20
n20	equ 	20

; test_fails:
!anton	equ	20 30		; operator missing
!n20	equ 	30		; label redefined
!foo	equ				; value missing

	db	10
	db	$10
	db	%10
	db	10h
	db	10b
	db	0x10
	db	'A'
	db	-123
	db	+123
	db	0
	db	2
	db	0b
	db	1b
	db	8h
	db	0b1010
	db	0b10

#ASSERT	0 == 0
#aSSert	-1 == -1
#assert	33 == 33

#assert	5 > 3
#assert	3 < 5
#assert	5 != 3
#assert	3 >= 3
#assert	3 <= 3
#assert	5 >= 3
#assert	3 <= 5

#assert (0 || 0) == 0
#assert	(0 && 0) == 0
#assert (1 || 1) == 1
#assert	(1 && 1) == 1
#assert (0 || 1) == 1
#assert	(1 && 0) == 0
#assert (1 || foo) == 1
#assert	(0 && foo) == 0
#assert	0 ? 0 : 1
#assert	0 ? foo : 1
#assert	1 ? 1 : foo
#assert	!(1 ? 0 : 1)
#assert	!(0 ? 1 : 0)
#assert	1||0 ? 1 : 0
#assert	0||1 ? 1 : 0
#assert	0&&1 ? 0 : 1
#assert	1&&0 ? 0 : 1
#assert	!(0 && 0 == 0)
#assert	1 ? 1 : 1 ? 0 : 0
#assert	0 ? 0 : 1 ? 1 : 0
#assert	0 ? 0 : 0 ? 0 : 1
#assert	1 ?   1 ? 1 : 0   :   1 ? 0 : 0
#assert	1 ?   1 ? 1 : 0   :   0 ? 0 : 0
#assert	1 ?   0 ? 0 : 1   :   1 ? 0 : 0
#assert	1 ?   0 ? 0 : 1   :   0 ? 0 : 0
#assert	0 ?   1 ? 0 : 0   :   1 ? 1 : 0
#assert	0 ?   0 ? 0 : 0   :   1 ? 1 : 0
#assert	0 ?   1 ? 0 : 0   :   0 ? 0 : 1
#assert	0 ?   0 ? 0 : 0   :   0 ? 0 : 1
#assert	!(1 ? 0 : 1 ? 1 : 1)
#assert	!(0 ? 1 : 1 ? 0 : 1)
#assert	!(1 ?   1 ? 0 : 1   :   1 ? 1 : 1)
#assert	!(0 ?   1 ? 1 : 1   :   1 ? 0 : 1)
#assert	!(0 ?   1 ? 1 : 1   :   0 ? 1 : 0)

#assert	-n20 == -20

#assert	~0 == -1
#assert	~-1 == 0

#assert	!0 == 1
#assert	!77 == 0
#assert	!-33 == 0
#assert	!-0 == 1

#assert	3|5 == 7
#assert	3&5 == 1
#assert	3^5 == 6

#assert 3<<2 == 3*4
#assert	0xff00<<4 == 0xff000
#assert	7>>1 == 3
#assert	0xff00>>4 == 0x0ff0

#assert	3 + 5 == 8
#assert	3 + -5 == -2
#assert	3-5==-2
#assert	3- -5==8
#assert	3*5==15
#assert	3*-5==-15
#assert	3/5==0
#assert	55/3==18
#assert	-55/3==-18
#assert	55/-3==-18
#assert	-55/-3==18
#assert	6/3==2
#assert	3%5==3
#assert	55%3==1
#assert	-55%3==-1
#assert	55%-3==1
#assert	-55%-3==-1
#assert	6%3==0

#assert	3 == 3/5*5 + 3%5
#assert	55 == 55/3*3 + 55%3
#assert	-55 == -55/3*3 + -55%3
#assert	55 == 55/-3*-3 + 55%-3
#assert	-55 == -55/-3*-3 + -55%-3
#assert	6 == 6/3*3 + 6%3

#assert	n5+n20 == 25
#assert	n5+n20*2 == 45
#assert	n20*2+n5 == 45
#assert	2+4-1*7 == -1
#assert	-(20) == 20 * -1
#assert	n20/7 == 2
#assert	(n20+1)/7 == 3
#assert	1 + 2*3<<4 == 97

#assert	hi(1234h) == 12h
#assert	lo(1234h) == 34h
#assert	opcode(nop) == 0
#assert	opcode(ld a,n) == 0x3e
#assert	opcode(ld bc,(nn)) == 4Bh
#assert	opcode(adc hl,bc) == 4Ah
#assert	opcode(rla) == 17h
#assert	opcode(rr b) == 18h
#assert	opcode(bit 1,(ix+dis)) == 4Eh
#assert	opcode(jp nn) == 0C3h
#assert	opcode(jr c,dis) == 38h
#assert	opcode(rst 8) == 0CFh

#assert &1234 == 0x1234
#assert 1234h == 0x1234
#assert $1234 == 0x1234
#assert &A234 == 0xA234
#assert 0A234h == 0xA234
#assert $A234 == 0xA234
#assert &AF00 + &FE == $AFFE
#assert (0 ? &AF00 + &FE : 123) == 123
#assert (1 ? &AF00 + &FE : 123) == &AFFE
#assert $AF00 + $FE == 0xAFFE
#assert (0 ? $AF00 + $FE : 123) == 123
#assert (1 ? $AF00 + $FE : 123) == 0AFFEh
#assert 0xAF00 + 0xFE == 0xAFFE
#assert (0 ? 0xAF00 + 0xFE : 123) == 123
#assert (1 ? 0xAF00 + 0xFE : 123) == 0AFFEh
#assert 0AF00h + 0FEh == 0xAFFE
#assert (0 ? 0AF00h + 0FEh : 123) == 123
#assert (1 ? 0AF00h + 0FEh : 123) == $AFFE
#endlocal



; –––––––––––––––––––––––––––––––––––––––––––––––––
; 		test addressing modes
; –––––––––––––––––––––––––––––––––––––––––––––––––

#local
	ld	a,0
	ld	b,1
	ld	c,2
	ld	d,#3
	ld	e,4
	ld	h,5
	ld	l,6
	ld	hl,1234h
	ld	(hl),7
	in	a,(33)
	out	(33),a
	rst	0
	rst	1
	rst	8
	rst	n6
	jp	p,nn
	jp	m,nn
	jp	pe,nn
	jp	po,nn
	POP	af
	Pop	bc
	PoP	de
	pOp	hl
	ld	sp,hl
	ex	hl,(sp)
	ld	a,(nn)
	ld	a,(bc)
	ld	a,(de)
	rrca

#if !defined(_8080_)
	in	d,(c)
	in	d,(bc)
	in	f,(c)
	in	(bc)
	out	(c),d
	out	(bc),d
	out	(bc),0

	im	1
	bit	6,h
	jr	$
1$:	jr	1$
	jr	z,$
	jr	nz,$
	jr	c,$
	jr	nc,$
!	jr	$+2+128
!	jr	$+2-129
	ex	af,af'
	ld	a,i
	ld	a,r

	pop	ix
	pop	iy
	ld	(ix),8
	ld	(ix+2),9
	ld	2(ix),10
	ld	(iy),11
	ld	(iy+2),12
	ld	2(iy),13
	ld	+3(ix),14
	ld	2+3(ix),15
	ld	(ix-2),16
	ld	(ix+2-3),17
	ld	(ix-3+2),18
	ld	(ix+3*2),19

	ld	(ix+33h),nn
	ld	(ix-33h),nn
	ld	(ix),nn
	ld	33h(ix),nn
	ld	-33h(ix),nn
	ld	(ix+33h+5),nn
#endif

nn	equ	0x40
n6	equ	6

#endlocal




; –––––––––––––––––––––––––––––––––––––––––––––––––
;	8080/z80 opcodes (z80 syntax)
; –––––––––––––––––––––––––––––––––––––––––––––––––

	ccf
	cpl
	daa
	di
	ei
	halt
	Nop
	Rla
	Rlca
	Rra
	Rrca
	scf
	in   a,(n)
	out  (n),a

; ––––––––––––––––––––––––––––––––––
	ADD  a,(hl)
	add  a,a
	add  a,b
	add  a,c
	add  a,d
	add  a,e
	add  a,h
	add  a,l
	ADD  (hl)
	add  a,n
	add  a
	add  b
	add  n

	ADC  a,(hl)
	adc  a,a
	adc  a,b
	adc  a,c
	adc  a,d
	adc  a,e
	adc  a,h
	adc  a,l
	adc  a,n
	adc  a
	adc  b
	adc  n

	sbc  a,(hl)
	sbc  a,a
	sbc  a,b
	sbc  a,c
	sbc  a,d
	sbc  a,e
	sbc  a,h
	sbc  a,l
	sbc  a,n
	sbc  a
	sbc  b
	sbc  n

	sub  (HL)
	sub  A
	sub  B
	sub  C
	sub  D
	sub  E
	sub  H
	sub  L
	sub  n
	sub  a,A
	sub  a,B
	sub  a,n
	sub  a,(hl)

	AND  (HL)
	and  A
	and  B
	and  C
	and  D
	and  E
	and  H
	and  L
	and  n
	and  a,A
	and  a,B
	and  a,n
	and  a,(hl)

	or  (HL)
	or  A
	or  B
	or  C
	or  D
	or  E
	or  H
	or  L
	or  n
	or  a,A
	or  a,B
	or  a,n
	or  a,(hl)

	xor  (HL)
	xor  A
	xor  B
	xor  C
	xor  D
	xor  E
	xor  H
	xor  L
	xor  n
	xor  a,A
	xor  a,B
	xor  a,n
	xor  a,(hl)

	cp  (HL)
	cp  A
	cp  B
	cp  C
	cp  D
	cp  E
	cp  H
	cp  L
	cp  n
	cp  a,A
	cp  a,B
	cp  a,n
	cp  a,(hl)

; ––––––––––––––––––––––––––––––––––
	inc  (HL)
	inc  a
	inc  b
	inc  c
	inc  d
	inc  e
	inc  h
	inc  l

	DEC  (HL)
	dec  a
	dec  b
	dec  c
	dec  d
	dec  e
	dec  h
	dec  l

; ––––––––––––––––––––––––––––––––––
	ld   a,a
	ld   a,b
	ld   a,c
	ld   a,d
	ld   a,e
	ld   a,h
	ld   a,l
	ld   a,(hl)
	ld   a,n

	ld   b,a
	ld   b,b
	ld   b,c
	ld   b,d
	ld   b,e
	ld   b,h
	ld   b,l
	ld   b,(hl)
	ld   b,n

	ld   c,a
	ld   c,b
	ld   c,c
	ld   c,d
	ld   c,e
	ld   c,h
	ld   c,l
	ld   c,(hl)
	ld   c,n

	ld   d,a
	ld   d,b
	ld   d,c
	ld   d,d
	ld   d,e
	ld   d,h
	ld   d,l
	ld   d,(hl)
	ld   d,n

	ld   e,a
	ld   e,b
	ld   e,c
	ld   e,d
	ld   e,e
	ld   e,h
	ld   e,l
	ld   e,(hl)
	ld   e,n

	ld   h,a
	ld   h,b
	ld   h,c
	ld   h,d
	ld   h,e
	ld   h,h
	ld   h,l
	ld   h,(hl)
	ld   h,n

	ld   l,a
	ld   l,b
	ld   l,c
	ld   l,d
	ld   l,e
	ld   l,h
	ld   l,l
	ld   l,(hl)
	ld   l,n

	ld   (hl),a
	ld   (hl),b
	ld   (hl),c
	ld   (hl),d
	ld   (hl),e
	ld   (hl),h
	ld   (hl),l
	ld   (hl),n

	LD   (BC),A
	ld   (de),a
	ld   (nn),a
	ld   a,(bc)
	ld   a,(de)
	ld   a,(nn)

; ––––––––––––––––––––––––––––––––––
	jp   c,nn
	jp   m,nn
	jp   nc,nn
	jp   nz,nn
	jp   p,nn
	jp   pe,nn
	jp   po,nn
	jp   Z,nn
	JP   nn
	jp   (hl)
	jp   hl

	CALL C,nn
	call m,nn
	call nc,nn
	call nz,nn
	call P,nn
	call pe,nn
	call po,nn
	call z,nn
	call nn

	RET
	ret  c
	ret  m
	ret  nc
	ret  nz
	ret  p
	ret  pe
	ret  po
	ret  z

	RST  00h
	rst  08h
	rst  n16
	rst  18h
	rst  20h
	rst  28h
	rst  30h
	rst  $38

	rst  0
	rst  n1
	rst  2
	rst  3
	rst  4
	rst  5
	rst  n6
	rst  7

; ––––––––––––––––––––––––––––––––––
	ex   de,hl
	ex   hl,de
	EX   (sp),hl
	EX   hl,(sp)

	POP  af
	pop  bc
	pop  de
	pop  hl

	PUSH af
	push bc
	push de
	push hl

	ld   sp,hl
	ld   bc,nn
	ld   de,nn
	ld   hl,nn
	ld   sp,nn

	add  hl,bc
	add  hl,de
	add  hl,hl
	add  hl,sp

	inc  bc
	inc  de
	inc  hl
	inc  sp
	dec  bc
	dec  de
	dec  hl
	dec  sp

; ––––––––––––––––––––––––––––––––––
nn	equ	0x4142
n	equ	40h




; –––––––––––––––––––––––––––––––––––––––––––––––––
;			Z80 / non 8080 opcodes
; –––––––––––––––––––––––––––––––––––––––––––––––––

#if !defined(_8080_)
	exx
	Neg
	cpd
	cpdr
	cpir
	cpi
	Ind
	Indr
	Ini
	Inir
	Ldd
	Lddr
	Ldi
	Ldir
	Otdr
	Otir
	Outd
	Outi
	Rld
	Rrd
	Reti
	Retn

	djnz $
	ex  af,af'

	IM	0
	im	n1
	im	2

loop2:
	jr   loop2
	JR   C,loop2
	jr   nc,loop2
	jr   nz,loop2
	jr   z,loop2

; ––––––––––––––––––––––––––––––––––
	adc  hl,bc
	adc  hl,de
	adc  hl,hl
	adc  hl,sp

	sbc  hl,bc
	sbc  hl,de
	sbc  hl,hl
	sbc  hl,sp

; ––––––––––––––––––––––––––––––––––
	IN   a,(c)
	in   b,(bc)
	in   c,(c)
	in   d,(bc)
	in   e,(c)
	in   h,(bc)
	in   l,(c)
	in   f,(bc)

	OUT  (c),a
	out  (bc),b
	out  (c),c
	out  (bc),d
	out  (c),e
	out  (bc),h
	out  (c),l
	out  (c),0

; ––––––––––––––––––––––––––––––––––
	ld   a,i
	ld   a,r
	ld   i,a
	ld   r,a

	ld   (nn),bc
	ld   (nn),de
	ld   (nn),hl
	ld   (nn),sp
	ld   bc,(nn)
	ld   de,(nn)
	ld   hl,(nn)
	ld   sp,(nn)

; ––––––––––––––––––––––––––––––––––
	bit  0,a
	bit  0,b
	bit  0,c
	bit  0,d
	bit  0,e
	bit  0,h
	bit  0,l
	BIT  0,(hl)
	bit  1,a
	BIT  n1,(hl)
	bit  2,h
	BIT  2,(hl)
	bit  3,l
	BIT  3,(hl)
	bit  4,d
	BIT  4,(hl)
	bit  5,e
	BIT  5,(hl)
	bit  6,c
	BIT  n6,(hl)
	bit  7,b
	BIT  7,(hl)

	res  0,a
	res  0,b
	res  0,c
	res  0,d
	res  0,e
	res  0,h
	res  0,l
	res  0,(hl)
	res  1,a
	res  1,(hl)
	res  2,h
	res  2,(hl)
	res  3,l
	res  3,(hl)
	res  4,d
	res  4,(hl)
	res  5,e
	res  5,(hl)
	res  6,c
	res  6,(hl)
	res  7,b
	res  7,(hl)

	set  0,a
	set  0,b
	set  0,c
	set  0,d
	set  0,e
	set  0,h
	set  0,l
	set  0,(hl)
	set  1,a
	set  n1,(hl)
	set  2,h
	set  2,(hl)
	set  3,l
	set  3,(hl)
	set  4,d
	set  4,(hl)
	set  5,e
	set  5,(hl)
	set  6,c
	set  n6,(hl)
	set  7,b
	set  7,(hl)

; ––––––––––––––––––––––––––––––––––
	RL   (hl)
	rl   a
	rl   b
	rl   c
	rl   d
	rl   e
	rl   h
	rl   l

	RLC  (hl)
	rlc  a
	rlc  b
	rlc  c
	rlc  d
	rlc  e
	rlc  h
	rlc  l

	RR   (hl)
	rr   a
	rr   b
	rr   c
	rr   d
	rr   e
	rr   h
	rr   l

	RRC  (hl)
	rrc  a
	rrc  b
	rrc  c
	rrc  d
	rrc  e
	rrc  h
	rrc  l

	sla  (hl)
	sla  a
	sla  b
	sla  c
	sla  d
	sla  e
	sla  h
	sla  l

	sll  (hl)
	sll  a
	sll  b
	sll  c
	sll  d
	sll  e
	sll  h
	sll  l

	sra   (hl)
	sra   a
	sra   b
	sra   c
	sra   d
	sra   e
	sra   h
	sra   l

	srl   (hl)
	srl   a
	srl   b
	srl   c
	srl   d
	srl   e
	srl   h
	srl   l
#endif



; –––––––––––––––––––––––––––––––––––––––––––––––––
;		Z80 / non 8080 opcodes
;		using index register
; –––––––––––––––––––––––––––––––––––––––––––––––––

#if !defined(_8080_)
	jp   ix
	jp   iy
	jp   (ix)
	jp   (iy)
	jp   (ix+0)
	jp   (iy-0)
!	jp   (ix+10)
!	jp   (iy-10)

	ld   sp,ix
	ld   sp,iy
	ld   (nn),ix
	ld   (nn),iy
	ld   ix,(nn)
	ld   iy,(nn)
	ld   ix,nn
	ld   iy,nn

	add  ix,bc
	add  ix,de
	add  ix,ix
	add  ix,sp
	add  iy,bc
	add  iy,de
	add  iy,iy
	add  iy,sp

	inc  ix
	inc  iy
	dec  ix
	dec  iy

	ex   (sp),ix
	ex   ix,(sp)
	ex   (sp),iy
	ex   iy,(sp)

	pop  ix
	pop  iy
	push ix
	push iy

; ––––––––––––––––––––––––––––––––––
	ld   a,ixh		; illegal
	ld   a,ixl		; illegal
	ld   a,iyh		; illegal
	ld   a,iyl		; illegal

	ld   b,xh		; illegal
	ld   b,xl		; illegal
	ld   b,yh		; illegal
	ld   b,yl		; illegal

	ld   c,ixh		; illegal
	ld   c,ixl		; illegal
	ld   c,iyh		; illegal
	ld   c,iyl		; illegal

	ld   d,xh		; illegal
	ld   d,xl		; illegal
	ld   d,yh		; illegal
	ld   d,yl		; illegal

	ld   e,ixh		; illegal
	ld   e,ixl		; illegal
	ld   e,iyh		; illegal
	ld   e,iyl		; illegal

	ld   xh,a		; illegal
	ld   xh,b		; illegal
	ld   xh,c		; illegal
	ld   xh,d		; illegal
	ld   xh,e		; illegal
	ld   xh,xh		; illegal
	ld   xh,xl		; illegal
	ld   xh,n		; illegal

	ld   yl,a		; illegal
	ld   yl,b		; illegal
	ld   yl,c		; illegal
	ld   yl,d		; illegal
	ld   yl,e		; illegal
	ld   yl,yh		; illegal
	ld   yl,yl		; illegal
	ld   yl,n		; illegal

	ld   a,(ix+1)
	ld   a,(iy+n1)
	ld   b,(ix+n1)
	ld   b,(iy+1)
	ld   c,(ix+1)
	ld   c,(iy+n1)
	ld   d,(ix+1)
	ld   d,(iy+n1)
	ld   e,(ix+n1)
	ld   e,(iy+1)
	ld   h,(ix+1)
	ld   h,(iy+n1)
	ld   l,(ix+1)
	ld   l,(iy+n1)

	ld   (ix+1),a
	ld   (ix+1),b
	ld   (ix+1),c
	ld   (ix+n1),d
	ld   (ix+1),e
	ld   (ix+1),h
	ld   (ix+1),l
	ld   (ix+1),n

	ld   (iy+1),a
	ld   (iy+1),b
	ld   (iy+1),c
	ld   (iy+1),d
	ld   (iy+n1),e
	ld   (iy+1),h
	ld   (iy+1),l
	ld   (iy+1),n

; ––––––––––––––––––––––––––––––––––
	add  a,xh		; illegal
	add  a,xl		; illegal
	add  a,yh		; illegal
	add  a,yl		; illegal

	sub  a,XH		; illegal
	sub  a,XL		; illegal
	sub  a,YH		; illegal
	sub  a,YL		; illegal

	adc  a,xh		; illegal
	adc  a,xl		; illegal
	adc  a,yh		; illegal
	adc  a,yl		; illegal

	sbc  a,xh		; illegal
	sbc  a,xl		; illegal
	sbc  a,yh		; illegal
	sbc  a,yl		; illegal

	and  a,XH		; illegal
	and  a,XL		; illegal
	and  a,YH		; illegal
	and  a,YL		; illegal

	or  a,XH		; illegal
	or  a,XL		; illegal
	or  a,YH		; illegal
	or  a,YL		; illegal

	xor  a,XH		; illegal
	xor  a,XL		; illegal
	xor  a,YH		; illegal
	xor  a,YL		; illegal

	cp  a,XH		; illegal
	cp  a,XL		; illegal
	cp  a,YH		; illegal
	cp  a,YL		; illegal

	inc  xh			; illegal
	inc  xl			; illegal
	inc  yh			; illegal
	inc  yl			; illegal

	dec  xh			; illegal
	dec  xl			; illegal
	dec  yh			; illegal
	dec  yl			; illegal

; ––––––––––––––––––––––––––––––––––
	add  a,(ix+1)
	add  a,(iy+n1)

	sub  (ix+1)
	sub  (iy+1)
	sub  a,(ix+1)
	sub  a,(iy+1)

	adc  a,(ix+1)
	adc  a,(iy+n1)

	sbc  a,(ix+1)
	sbc  a,(iy+1)

	AND  (ix+1)
	AND  (iy+1)
	and  a,(ix+1)
	and  a,(iy+n1)

	or  (ix+1)
	or  (iy+1)
	or  a,(ix+1)
	or  a,(iy+1)

	xor  (ix+1)
	xor  (iy+1)
	xor  a,(ix+1)
	xor  a,(iy+1)

	cp  (ix+n1)
	cp  (iy+1)
	cp  a,(ix+1)
	cp  a,(iy+1)

	inc  (IX+1)
	inc  (iy+1)
	dec  (IX+n1)
	dec  (iy+1)

; ––––––––––––––––––––––––––––––––––
	bit  0,(ix+n1)
	bit  0,(iy+1)
	bit  1,(ix+1)
	bit  2,(iy+1)
	bit  3,(ix+1)
	bit  4,(iy+1)
	bit  5,(ix+1)
	bit  6,(iy+1)
	bit  7,(ix+1)

	res  0,(ix+1)
	res  0,(iy+1)
	res  1,(ix+1)
	res  2,(iy+1)
	res  3,(ix+1)
	res  4,(iy+1)
	res  5,(ix+1)
	res  6,(iy+1)
	res  7,(ix+1)

	set  0,(ix+1)
	set  0,(iy+1)
	set  1,(ix+1)
	set  2,(iy+1)
	set  3,(ix+1)
	set  4,(iy+1)
	set  5,(ix+1)
	set  6,(iy+1)
	set  7,(ix+1)

	rl   (ix+1)
	rl   (iy+1)
	rlc  (ix+1)
	rlc  (iy+1)
	rr   (ix+1)
	rr   (iy+1)
	rrc  (ix+1)
	rrc  (iy+1)
	sla  (ix+1)
	sla  (iy+1)
	sll  (ix+1)
	sll  (iy+1)
	sra  (ix+1)
	sra  (iy+1)
	srl  (ix+1)
	srl  (iy+1)
#endif		; !defined(i8080)




; –––––––––––––––––––––––––––––––––––––––––––––––––
;		z80 illegal IXCB opcodes
; –––––––––––––––––––––––––––––––––––––––––––––––––

#if defined(_ixcbxh_)
	sra  xh
	sra  yl
	sla  xh
	sla  yl
	srl  xh
	srl  yl
	sll  xh
	sll  yl

	rl   xh
	rl   yl
	rlc  xh
	rlc  yl
	rr   xh
	rr   yl
	rrc  xh
	rrc  yl

	bit  0,xh		; illegal
	bit  1,xl		; illegal
	bit  2,yh		; illegal
	bit  3,yl		; illegal
	bit  4,xh		; illegal
	bit  5,xl		; illegal
	bit  6,yh		; illegal
	bit  7,yl		; illegal

	res  0,xh		; illegal
	res  1,xl		; illegal
	res  2,yh		; illegal
	res  3,yl		; illegal
	res  4,xh		; illegal
	res  5,xl		; illegal
	res  6,yh		; illegal
	res  7,yl		; illegal

	set  0,xh		; illegal
	set  1,xl		; illegal
	set  2,yh		; illegal
	set  3,yl		; illegal
	set  4,xh		; illegal
	set  5,xl		; illegal
	set  6,yh		; illegal
	set  7,yl		; illegal
#endif

#if !defined(_ixcbxh_)
!	bit  0,xh		; illegal
!	bit  1,xl		; illegal
!	bit  2,yh		; illegal
!	bit  3,yl		; illegal
!	bit  4,xh		; illegal
!	bit  5,xl		; illegal
!	bit  6,yh		; illegal
!	bit  7,yl		; illegal

!	res  0,xh		; illegal
!	res  1,xl		; illegal
!	res  2,yh		; illegal
!	res  3,yl		; illegal
!	res  4,xh		; illegal
!	res  5,xl		; illegal
!	res  6,yh		; illegal
!	res  7,yl		; illegal

!	set  0,xh		; illegal
!	set  1,xl		; illegal
!	set  2,yh		; illegal
!	set  3,yl		; illegal
!	set  4,xh		; illegal
!	set  5,xl		; illegal
!	set  6,yh		; illegal
!	set  7,yl		; illegal

!	rl	 xh
!	rl	 yl
!	rlc	 xh
!	rlc	 yl
!	rr	 xh
!	rr	 yl
!	rrc	 xh
!	rrc	 yl

!	sra	 xh
!	sra	 yl
!	sla	 xh
!	sla	 yl
!	srl	 xh
!	srl	 yl
!	sll	 xh
!	sll	 yl
#endif

#if defined(_ixcbr2_)
	sra  (ix+1),a
	sra  (iy+1),b
	sla  (ix+1),c
	sla  (iy+1),d
	srl  (ix+1),e
	srl  (iy+1),a
	sll  (ix+1),b
	sll  (iy+1),c
	sra  (iy+1),h
	sla  (ix+1),l
	srl  (iy+1),h
	sll  (ix+1),l

	rl   (ix+1),a
	rl   (iy+1),b
	rlc  (ix+1),c
	rlc  (iy+1),d
	rr   (ix+1),e
	rr   (iy+1),a
	rrc  (ix+1),b
	rrc  (iy+1),c
	rl   (iy+1),h
	rlc  (ix+1),l
	rr   (iy+1),h
	rrc  (ix+1),l

	bit  0,(ix+1),a	; illegal		TODO:	evtl. they all behave like "bit b,(ix+dis)"
	bit  1,(iy+1),b	; illegal			because 'bit' does not write to register
	bit  2,(ix+1),c	; illegal			to be tested!
	bit  3,(iy+1),h	; illegal			different docs state different opinions!
	bit  4,(ix+1),l	; illegal
	bit  5,(iy+1),d	; illegal
	bit  6,(ix+1),e	; illegal
	bit  7,(iy+1),b	; illegal

	res  0,(ix+1),a	; illegal
	res  1,(iy+1),b	; illegal
	res  2,(ix+1),c	; illegal
	res  3,(iy+1),h	; illegal
	res  4,(ix+1),l	; illegal
	res  5,(iy+1),d	; illegal
	res  6,(ix+1),e	; illegal
	res  7,(iy+1),b	; illegal

	set  0,(ix+1),a	; illegal
	set  1,(iy+1),b	; illegal
	set  2,(ix+1),c	; illegal
	set  3,(iy+1),h	; illegal
	set  4,(ix+1),l	; illegal
	set  5,(iy+1),d	; illegal
	set  6,(ix+1),e	; illegal
	set  7,(iy+1),b	; illegal

#else ; if !defined(_ixcbr2_)

!	rl   (ix+1),a
!	rl   (iy+1),b
!	rlc  (ix+1),c
!	rlc  (iy+1),d
!	rr   (ix+1),e
!	rr   (iy+1),a
!	rrc  (ix+1),b
!	rrc  (iy+1),c

!	sra  (ix+1),a
!	sra  (iy+1),b
!	sla  (ix+1),c
!	sla  (iy+1),d
!	srl  (ix+1),e
!	srl  (iy+1),a
!	sll  (ix+1),b
!	sll  (iy+1),c

!	bit  0,(ix+1),a	; illegal
!	bit  1,(iy+1),b	; illegal
!	bit  2,(ix+1),c	; illegal
!	bit  3,(iy+1),h	; illegal
!	bit  4,(ix+1),l	; illegal
!	bit  5,(iy+1),d	; illegal
!	bit  6,(ix+1),e	; illegal
!	bit  7,(iy+1),b	; illegal

!	res  0,(ix+1),a	; illegal
!	res  1,(iy+1),b	; illegal
!	res  2,(ix+1),c	; illegal
!	res  3,(iy+1),h	; illegal
!	res  4,(ix+1),l	; illegal
!	res  5,(iy+1),d	; illegal
!	res  6,(ix+1),e	; illegal
!	res  7,(iy+1),b	; illegal

!	set  0,(ix+1),a	; illegal
!	set  1,(iy+1),b	; illegal
!	set  2,(ix+1),c	; illegal
!	set  3,(iy+1),h	; illegal
!	set  4,(ix+1),l	; illegal
!	set  5,(iy+1),d	; illegal
!	set  6,(ix+1),e	; illegal
!	set  7,(iy+1),b	; illegal

!	rl   (iy+1),h
!	rlc  (ix+1),l
!	rr   (iy+1),h
!	rrc  (ix+1),l
!	sra  (iy+1),h
!	sla  (ix+1),l
!	srl  (iy+1),h
!	sll  (ix+1),l
#endif


n6	equ	6
n1	equ	1
n16	equ	16






; –––––––––––––––––––––––––––––––––––––––––––––––––
;	ill. arguments for all opcodes:
; –––––––––––––––––––––––––––––––––––––––––––––––––

!	jr   p,loop2
!	jr   m,loop2
!	jr   po,loop2
!	jr   pe,loop2

!	im	3

!	adc  ix,bc
!	adc  ix,de
!	adc  ix,ix
!	adc  ix,iy
!	adc  ix,sp
!	adc  iy,bc
!	adc  iy,de
!	adc  iy,iy
!	adc  iy,ix
!	adc  iy,sp

!	add  ix,iy
!	add  ix,hl
!	add  iy,ix
!	add  iy,hl

!	ld   (hl),(hl)
!	ld   (ix+1),(ix+1)
!	ld   (ix+1),(iy+1)
!	ld   (iy+1),(hl)
!	ld   (iy+1),(ix+1)
!	ld   (iy+1),(iy+1)

!	ld   XH,(hl)
!	ld   xh,(ix+1)
!	ld   xh,(iy+1)
!	ld   xh,h
!	ld   xh,l
!	ld   xh,yl
!	ld   YL,(hl)
!	ld   yl,(ix+1)
!	ld   yl,(iy+1)
!	ld   yl,h
!	ld   yl,l
!	ld   yl,xh

!	out  (c),xh
!	out  (c),yl

!	sbc  ix,bc
!	sbc  ix,de
!	sbc  ix,ix
!	sbc  ix,iy
!	sbc  ix,sp
!	sbc  iy,bc
!	sbc  iy,de
!	sbc  iy,iy
!	sbc  iy,ix
!	sbc  iy,sp



; –––––––––––––––––––––––––––––––––––––––––––––––––
;	ill. 8080 opcodes:
; –––––––––––––––––––––––––––––––––––––––––––––––––

#if defined(_8080_)	; z80 syntax, target 8080
!	exx
!	Neg
!	cpd
!	cpdr
!	cpir
!	cpi
!	Ind
!	Indr
!	Ini
!	Inir
!	Ldd
!	Lddr
!	Ldi
!	Ldir
!	Otdr
!	Otir
!	Outd
!	Outi
!	Rld
!	Rrd
!	Reti
!	Retn
!	djnz $
#endif



; –––––––––––––––––––––––––––––––––––––––––––––––––
;	ill. arguments for 8080 opcodes:
; –––––––––––––––––––––––––––––––––––––––––––––––––

#if defined(_8080_)	; z80 syntax, target 8080
!	jp   (ix)
!	jp   (iy)

; ––––––––––––––––––––––––––––––––––
loop3:
!	jr   loop3
!	JR   C,loop3
!	jr   nc,loop3
!	jr   nz,loop3
!	jr   z,loop3

; ––––––––––––––––––––––––––––––––––
!	IM	0
!	im	n1
!	im	2

; ––––––––––––––––––––––––––––––––––
!	pop  ix
!	pop  iy
!	push ix
!	push iy

!	ld   i,a
!	ld   r,a

!	ld   (nn),bc
!	ld   (nn),de
!	ld   (nn),ix
!	ld   (nn),iy
!	ld   (nn),sp
!	ld   bc,(nn)
!	ld   de,(nn)
!	ld   ix,(nn)
!	ld   iy,(nn)
!	ld   sp,(nn)
!	ld   ix,nn
!	ld   iy,nn

!	ld   (ix+1),b
!	ld   (ix+1),c
!	ld   (ix+n1),d
!	ld   (ix+1),e
!	ld   (ix+1),h
!	ld   (ix+1),l
!	ld   (ix+1),n

!	ld   (iy+1),b
!	ld   (iy+1),c
!	ld   (iy+1),d
!	ld   (iy+n1),e
!	ld   (iy+1),h
!	ld   (iy+1),l
!	ld   (iy+1),n

!	ld   xh,a		; illegal
!	ld   xh,b		; illegal
!	ld   xh,c		; illegal
!	ld   xh,d		; illegal
!	ld   xh,e		; illegal
!	ld   xh,xh		; illegal
!	ld   xh,xl		; illegal
!	ld   xh,n		; illegal

!	ld   yl,a		; illegal
!	ld   yl,b		; illegal
!	ld   yl,c		; illegal
!	ld   yl,d		; illegal
!	ld   yl,e		; illegal
!	ld   yl,yh		; illegal
!	ld   yl,yl		; illegal
!	ld   yl,n		; illegal

!	add  ix,bc
!	add  ix,de
!	add  ix,ix
!	add  ix,sp
!	add  iy,bc
!	add  iy,de
!	add  iy,iy
!	add  iy,sp

!	adc  hl,bc
!	adc  hl,de
!	adc  hl,hl
!	adc  hl,sp

!	sbc  hl,bc
!	sbc  hl,de
!	sbc  hl,hl
!	sbc  hl,sp

; ––––––––––––––––––––––––––––––––––
!	inc  (IX+1)
!	inc  (iy+1)
!	inc  xh			; illegal
!	inc  xl			; illegal
!	inc  yh			; illegal
!	inc  yl			; illegal
!	inc  ix
!	inc  iy

; ––––––––––––––––––––––––––––––––––
!	dec  (IX+n1)
!	dec  (iy+1)
!	dec  xh			; illegal
!	dec  ixl		; illegal
!	dec  iyh		; illegal
!	dec  yl			; illegal
!	dec  ix
!	dec  iy

; ––––––––––––––––––––––––––––––––––
!	ex   af,af'
!	ex   (sp),ix
!	ex   ix,(sp)
!	ex   (sp),iy
!	ex   iy,(sp)

; ––––––––––––––––––––––––––––––––––
!	IN   a,(c)
!	in   b,(bc)
!	in   c,(c)
!	in   d,(bc)
!	in   e,(c)
!	in   h,(bc)
!	in   l,(c)
!	in   f,(bc)
!	in   (c)

; ––––––––––––––––––––––––––––––––––
!	OUT  (c),a
!	out  (bc),b
!	out  (c),c
!	out  (bc),d
!	out  (c),e
!	out  (bc),h
!	out  (c),l
!	out  (c),0

; ––––––––––––––––––––––––––––––––––
!	bit  0,a
!	bit  0,b
!	bit  0,c
!	bit  0,d
!	bit  0,e
!	bit  0,h
!	bit  0,l
!	BIT  0,(hl)
!	bit  0,(ix+n1)
!	bit  0,(iy+1)

!	bit  1,a
!	BIT  n1,(hl)
!	bit  1,(ix+1)
!	bit  2,h
!	BIT  2,(hl)
!	bit  2,(iy+1)
!	bit  3,l
!	BIT  3,(hl)
!	bit  3,(ix+1)
!	bit  4,d
!	BIT  4,(hl)
!	bit  4,(iy+1)
!	bit  5,e
!	BIT  5,(hl)
!	bit  5,(ix+1)
!	bit  6,c
!	BIT  n6,(hl)
!	bit  6,(iy+1)
!	bit  7,b
!	BIT  7,(hl)
!	bit  7,(ix+1)

; ––––––––––––––––––––––––––––––––––
!	res  0,a
!	res  0,b
!	res  0,c
!	res  0,d
!	res  0,e
!	res  0,h
!	res  0,l
!	res  0,(hl)
!	res  0,(ix+1)
!	res  0,(iy+1)

!	res  1,a
!	res  1,(hl)
!	res  1,(ix+1)
!	res  2,h
!	res  2,(hl)
!	res  2,(iy+1)
!	res  3,l
!	res  3,(hl)
!	res  3,(ix+1)
!	res  4,d
!	res  4,(hl)
!	res  4,(iy+1)
!	res  5,e
!	res  5,(hl)
!	res  5,(ix+1)
!	res  6,c
!	res  6,(hl)
!	res  6,(iy+1)
!	res  7,b
!	res  7,(hl)
!	res  7,(ix+1)

; ––––––––––––––––––––––––––––––––––
!	set  0,a
!	set  0,b
!	set  0,c
!	set  0,d
!	set  0,e
!	set  0,h
!	set  0,l
!	set  0,(hl)
!	set  0,(ix+1)
!	set  0,(iy+1)

!	set  1,a
!	set  n1,(hl)
!	set  1,(ix+1)
!	set  2,h
!	set  2,(hl)
!	set  2,(iy+1)
!	set  3,l
!	set  3,(hl)
!	set  3,(ix+1)
!	set  4,d
!	set  4,(hl)
!	set  4,(iy+1)
!	set  5,e
!	set  5,(hl)
!	set  5,(ix+1)
!	set  6,c
!	set  n6,(hl)
!	set  6,(iy+1)
!	set  7,b
!	set  7,(hl)
!	set  7,(ix+1)

; ––––––––––––––––––––––––––––––––––
!	RL   (hl)
!	rl   (ix+1)
!	rl   (iy+1)
!	rl   a
!	rl   b
!	rl   c
!	rl   d
!	rl   e
!	rl   h
!	rl   l

; ––––––––––––––––––––––––––––––––––
!	RLC  (hl)
!	rlc  (ix+1)
!	rlc  (iy+1)
!	rlc  a
!	rlc  b
!	rlc  c
!	rlc  d
!	rlc  e
!	rlc  h
!	rlc  l

; ––––––––––––––––––––––––––––––––––
!	RR   (hl)
!	rr   (ix+1)
!	rr   (iy+1)
!	rr   a
!	rr   b
!	rr   c
!	rr   d
!	rr   e
!	rr   h
!	rr   l

; ––––––––––––––––––––––––––––––––––
!	RRC  (hl)
!	rrc  (ix+1)
!	rrc  (iy+1)
!	rrc  a
!	rrc  b
!	rrc  c
!	rrc  d
!	rrc  e
!	rrc  h
!	rrc  l

; ––––––––––––––––––––––––––––––––––
!	sla  (hl)
!	sla  (ix+1)
!	sla  (iy+1)
!	sla  a
!	sla  b
!	sla  c
!	sla  d
!	sla  e
!	sla  h
!	sla  l

; ––––––––––––––––––––––––––––––––––
!	sll  (hl)
!	sll  (ix+1)
!	sll  (iy+1)
!	sll  a
!	sll  b
!	sll  c
!	sll  d
!	sll  e
!	sll  h
!	sll  l

; ––––––––––––––––––––––––––––––––––
!	sra   (hl)
!	sra   (ix+1)
!	sra   (iy+1)
!	sra   a
!	sra   b
!	sra   c
!	sra   d
!	sra   e
!	sra   h
!	sra   l

; ––––––––––––––––––––––––––––––––––
!	srl   (hl)
!	srl   (ix+1)
!	srl   (iy+1)
!	srl   a
!	srl   b
!	srl   c
!	srl   d
!	srl   e
!	srl   h
!	srl   l


; ––––––––––––––––––––––––––––––––––
!	jp   ix
!	jp   iy

!	ld   a,i
!	ld   a,r

!	ld   sp,ix
!	ld   sp,iy

!	ld   h,xh
!	ld   h,xl
!	ld   h,yh
!	ld   h,yl
!	ld   l,xh
!	ld   l,xl
!	ld   l,yh
!	ld   l,yl
!	ld   (hl),(ix+1)
!	ld   (hl),(iy+1)
!	ld   (hl),xh
!	ld   (hl),xl
!	ld   (hl),yh
!	ld   (hl),yl
!	ld   (ix+1),(hl)
!	ld   (ix+1),xh
!	ld   (ix+1),xl
!	ld   (ix+1),yh
!	ld   (ix+1),yl
!	ld   (iy+1),xh
!	ld   (iy+1),xl
!	ld   (iy+1),yh
!	ld   (iy+1),yl
!	ld   hl,ix
!	ld   hl,iy

!	ld   a,(ix+1)
!	ld   a,(iy+n1)
!	ld   a,xh		; illegal
!	ld   a,xl		; illegal
!	ld   a,yh		; illegal
!	ld   a,yl		; illegal

!	ld   b,(ix+n1)
!	ld   b,(iy+1)
!	ld   b,xh		; illegal
!	ld   b,xl		; illegal
!	ld   b,yh		; illegal
!	ld   b,yl		; illegal

!	ld   c,(ix+1)
!	ld   c,(iy+n1)
!	ld   c,xh		; illegal
!	ld   c,xl		; illegal
!	ld   c,yh		; illegal
!	ld   c,yl		; illegal

!	ld   d,(ix+1)
!	ld   d,(iy+n1)
!	ld   d,xh		; illegal
!	ld   d,xl		; illegal
!	ld   d,yh		; illegal
!	ld   d,yl		; illegal

!	ld   e,(ix+n1)
!	ld   e,(iy+1)
!	ld   e,xh		; illegal
!	ld   e,xl		; illegal
!	ld   e,yh		; illegal
!	ld   e,yl		; illegal

!	ld   h,(ix+1)
!	ld   h,(iy+n1)

!	ld   l,(ix+1)
!	ld   l,(iy+n1)

!	add  a,(ix+1)
!	add  a,(iy+n1)
!	add  a,xh		; illegal
!	add  a,xl		; illegal
!	add  a,yh		; illegal
!	add  a,yl		; illegal

!	sub  (ix+1)
!	sub  (iy+1)
!	sub  a,(ix+1)
!	sub  a,(iy+1)
!	sub  a,XH		; illegal
!	sub  a,XL		; illegal
!	sub  a,YH		; illegal
!	sub  a,YL		; illegal

!	adc  a,(ix+1)
!	adc  a,(iy+n1)
!	adc  a,xh		; illegal
!	adc  a,xl		; illegal
!	adc  a,yh		; illegal
!	adc  a,yl		; illegal

!	sbc  a,(ix+1)
!	sbc  a,(iy+1)
!	sbc  a,xh		; illegal
!	sbc  a,xl		; illegal
!	sbc  a,yh		; illegal
!	sbc  a,yl		; illegal

!	AND  (ix+1)
!	AND  (iy+1)
!	and  a,(ix+1)
!	and  a,(iy+n1)
!	and  a,XH		; illegal
!	and  a,XL		; illegal
!	and  a,YH		; illegal
!	and  a,YL		; illegal

!	or  (ix+1)
!	or  (iy+1)
!	or  a,(ix+1)
!	or  a,(iy+1)
!	or  a,XH		; illegal
!	or  a,XL		; illegal
!	or  a,YH		; illegal
!	or  a,YL		; illegal

!	xor  (ix+1)
!	xor  (iy+1)
!	xor  a,(ix+1)
!	xor  a,(iy+1)
!	xor  a,XH		; illegal
!	xor  a,XL		; illegal
!	xor  a,YH		; illegal
!	xor  a,YL		; illegal

!	cp  (ix+n1)
!	cp  (iy+1)
!	cp  a,(ix+1)
!	cp  a,(iy+1)
!	cp  a,XH		; illegal
!	cp  a,XL		; illegal
!	cp  a,YH		; illegal
!	cp  a,YL		; illegal

#endif ; defined(_8080_)



; –––––––––––––––––––––––––––––––––––––––––––––––––
; 	test_compound_opcodes:
; –––––––––––––––––––––––––––––––––––––––––––––––––

	jr $	\ jr $
	jp $	\ jp $-3
	ld hl,$	\ ld hl,$-3

	ld	bc,de
	ld b,d\ld c,e
	ld	bc,hl
	ld b,h\ld c,l
	ld	de,bc
	ld d,b\ld e,c
	ld	de,hl
	ld d,h\ld e,l
	ld	hl,bc
	ld h,b\ld l,c
	ld	hl,de
	ld h,d\ld l,e

	ld	bc,(hl)
	ld c,(hl++)\ld b,(hl)\dec hl
	ld	de,(hl)
	ld e,(hl++)\ld d,(hl)\dec hl
	ld	bc,(hl++)
	ld c,(hl++)\ld b,(hl++)
	ld	de,(hl++)
	ld e,(hl++)\ld d,(hl++)
	ld	bc,(--hl)
	ld b,(--hl)\ld c,(--hl)
	ld	de,(--hl)
	ld d,(--hl)\ld e,(--hl)

	ld	(hl),bc
	ld(hl++),c\ld(hl),b\dec hl
	ld	(hl),de
	ld(hl++),e\ld(hl),d\dec hl
	ld	(--hl),bc
	ld(--hl),b\ld(--hl),c
	ld	(--hl),de
	ld(--hl),d\ld(--hl),e
	ld	(hl++),bc
	ld(hl++),c\ld(hl++),b
	ld	(hl++),de
	ld(hl++),e\ld(hl++),d

	ld	(--bc),a
	dec bc\ld(bc),a
	ld	(--de),a
	dec de\ld(de),a
	ld	(bc++),a
	ld(bc),a\inc bc
	ld	(de++),a
	ld(de),a\inc de
	ld	a,(--bc)
	dec bc\ld a,(bc)
	ld	a,(--de)
	dec de\ld a,(de)
	ld	a,(bc++)
	ld a,(bc)\inc bc
	ld	a,(de++)
	ld a,(de)\inc de

	ld	a,(hl++)
	ld a,(hl)\inc hl
	ld	b,(--hl)
	dec hl\ld b,(hl)
	ld	c,(hl++)
	ld c,(hl)\inc hl
	ld	d,(--hl)
	dec hl\ld d,(hl)
	ld	h,(hl++)
	ld h,(hl)\inc hl	; potentially void
	ld	l,(--hl)
	dec	hl\ld l,(hl)

	add 	(hl++)
	add (hl)\inc hl
	adc 	(hl++)
	adc (hl)\inc hl
	sub 	(hl++)
	sub (hl)\inc hl
	sbc 	(hl++)
	sbc (hl)\inc hl
	and 	(hl++)
	and (hl)\inc hl
	or 	(hl++)
	or  (hl)\inc hl
	xor 	(hl++)
	xor (hl)\inc hl
	cp	(hl++)
	cp  (hl)\inc hl

	add 	(--hl)
	dec hl\add(hl)
	adc 	(--hl)
	dec hl\adc(hl)
	sub 	(--hl)
	dec hl\sub(hl)
	sbc 	(--hl)
	dec hl\sbc(hl)
	and 	(--hl)
	dec hl\and(hl)
	or 	(--hl)
	dec hl\or(hl)
	xor 	(--hl)
	dec hl\xor(hl)
	cp	(--hl)
	dec hl\cp(hl)


#if !defined(_8080_)
	ld	bc,ix		; illegal ...
	ld b,xh\ld c,xl
	ld	bc,iy		; ...
	ld b,yh\ld c,yl
	ld	de,ix		; ...
	ld d,xh\ld e,xl
	ld	de,iy		; ...
	ld d,yh\ld e,yl
	ld	ix,bc		; ...
	ld xh,b\ld xl,c
	ld	ix,de		; ...
	ld xh,d\ld xl,e
	ld	iy,bc		; ...
	ld yh,b\ld yl,c
	ld	iy,de		; ...
	ld yh,d\ld yl,e

	ld	bc,(ix+1)
	ld c,(ix+1)\ld b,(ix+2)
	ld	de,(iy+4)
	ld e,(iy+4)\ld d,(iy+5)
	ld	hl,(ix+5)
	ld l,(ix+5)\ld h,(ix+6)
	ld	hl,(iy+6)
	ld l,(iy+6)\ld h,(iy+7)

	ld	(ix+3),bc
	ld(ix+3),c\ld(ix+4),b
	ld	(iy+6),de
	ld(iy+6),e\ld(iy+7),d
	ld	(ix+7),hl
	ld(ix+7),l\ld(ix+8),h
	ld	(iy+8),hl
	ld(iy+8),l\ld(iy+9),h

	rr 	(hl++)			; 0xCB group:
	rr(hl)\inc hl
	rrc	(hl++)
	rrc(hl)\inc hl
	rl 	(hl++)
	rl(hl)\inc hl
	rlc 	(hl++)
	rlc(hl)\inc hl
	sla 	(hl++)
	sla(hl)\inc hl
	sra 	(hl++)
	sra(hl)\inc hl
	sll 	(hl++)			; illegal
	sll(hl)\inc hl
	srl 	(hl++)
	srl(hl)\inc hl
	bit	3,(hl++)
	bit 3,(hl)\inc hl
	set	4,(hl++)
	set 4,(hl)\inc hl
	res	5,(hl++)
	res 5,(hl)\inc hl

	rr 	(--hl)			; 0xCB group:
	dec hl\rr(hl)
	rrc 	(--hl)
	dec hl\rrc(hl)
	rl 	(--hl)
	dec hl\rl(hl)
	rlc 	(--hl)
	dec hl\rlc(hl)
	sla 	(--hl)
	dec hl\sla(hl)
	sra 	(--hl)
	dec hl\sra(hl)
	sll 	(--hl)			; illegal
	dec hl\sll(hl)
	srl 	(--hl)
	dec hl\srl(hl)
	bit	0,(--hl)
	dec hl\bit 0,(hl)
	set	1,(--hl)
	dec hl\set 1,(hl)
	res	2,(--hl)
	dec hl\res 2,(hl)

#endif


#data DATA, 1000,100
	db	0
	ds	4
	dw	0
	ds	0
	dm	$000000
!	db	1
!	dw	1
!	dm	"1"
!	db	0xff

#end
















