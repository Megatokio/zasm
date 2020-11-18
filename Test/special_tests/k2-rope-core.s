
; ----------------
;    K2 BASIC
; ----------------

#if 0
	register usage:

	sp	interpreter instruction pointer
	hl	lhs operand, 1st or single argument, result
	de	rhs operand, 2nd argument
#endif


.area ROM

; ----------------------------------
; ival ( void -- hl )

ival::
ld_hl_NN::
	pop	hl
	ret

ld_de_NN::
	pop	de
	ret

ld_bc_NN::
	pop	bc
	ret


; ----------------------------------
; int16 math:
; ----------------------------------

; ----------------------------------
; add ( hl de -- hl )

addi::
	pop	de		; NN
add::
	add	hl,de
	ret

; ----------------------------------
; sub ( hl de -- hl )

rsub::
	ex	hl,de
sub::
	and	a
	sbc	hl,de
	ret

subi::			; better: addi -NN
	pop	de		; NN
	and	a
	sbc	hl,de
	ret

; ----------------------------------
; and ( hl de -- hl )
; or  ( hl de -- hl )
; xor ( hl de -- hl )

andi::
	pop	de
and::
	ld	a,d \ and h \ ld h,a
	ld	a,e \ and l \ ld l,a
	ret

ori::
	pop	de
or::
	ld	a,d \ or h \ ld h,a
	ld	a,e \ or l \ ld l,a
	ret

xori::
	pop	de
xor::
	ld	a,d \ xor h \ ld h,a
	ld	a,e \ xor l \ ld l,a
	ret

; ----------------------------------
; mul ( hl de -- hl )
;
; preserves bc, ix, iy

.area ROM
muli::
	pop	de
mul::
	xor a
	cp	a,h
	jr	z,mul_lde	; hl = l*de
	ex	hl,de
	cp	a,h
	jr	z,mul_lde	; hl = l*de

; full 16*16 bit needed:
; hl * de = l * de + (h * e) << 8

; loop1: A = H * E
	rl	h			; cy <- h <- 1  (stopper)
	jr	c,3$
1$:	add	a,a
2$:	sla	h
	jr	nc,1$
	jr	z,4$		; stopper
3$:	add	a,a
	add	a,e
	jr	2$
4$:	ld	h,a			; h = h*e

mul_lde:
	ld	a,l			; a = l
	ld	l,h			; l = h*e (16bit) or l = 0 (8bit)

; loop2: HL = A * DE + L<<8
	scf
	adc	a,a			; cy <- a <- 1	(stopper)
	jr	c,3$
1$:	add	hl,hl
2$:	add	a			; -> cy=bit7
	jr	nc,1$
	ret	z			; this cy was the stopper
3$:	add	hl,hl
	add	hl,de
	jp	2$

.macro test_mul &op1, &op2
	ld	hl,	&op1
	ld	de,	&op2
	call mul
	.expect hl = (&op1 * &op2) & 0xFFFF
.endm

.area TEST
	test_mul 16, 16		; 353 --> 323 cc
	test_mul 116, 23	; 422 --> 386 cc
	test_mul 116, -23	; 422 --> 386 cc
	test_mul -116, 23	; 432 --> 401 cc
	test_mul -116, -23	; 930 --> 787 cc
	test_mul 256, 256	; 644 --> 548 cc
	test_mul 257, 255	; 529 --> 490 cc
	test_mul 12345,3	; 386 --> 359 cc
	test_mul 5,23456	; 376 --> 344 cc
	test_mul 0,0		; 330 --> 302 cc
	test_mul 23456,1	; 363 --> 338 cc
	test_mul 1,56789	; 353 --> 323 cc
	test_mul 255, 255	; 519 --> 475 cc
	test_mul -1, -1		; 999 --> 850 cc
	test_mul 23456,-1	; 999 --> 850 cc
	test_mul -1,56789	; 884 --> 751 cc
.area ROM



; ----------------------------------
; div ( hl de -- hl )
; rem ( hl de -- hl )


div::
	;TODO

rem::
	;TODO

; ----------------------------------
; min ( hl de -- hl )
; max ( hl de -- hl )

.area ROM
min::
	ld	a,h
	xor	d
	jp	p,minu+1
	and	h
	ret	m
	ex	hl,de
	ret

minu::
	and	a
	sbc	hl,de		; hl-de >= 0  or  hl-de-1>=0  <=>  hl>=de  or  hl>de
	ex	hl,de
	ret	nc			; no ovfl --> de = min
	add	hl,de		; undo
	ret

max::
	ld	a,h
	xor	d
	jp	p,maxu+1
	and	h
	ret	p
	ex	hl,de
	ret

maxu::
	and	a
	sbc	hl,de		; hl-de >= 0  or  hl-de-1>=0  <=>  hl>=de  or  hl>de
	ex	hl,de
	ret	c			; ovfl --> de = max
	add	hl,de		; undo
	ret

.area TEST
#define		S_FLAG	0x80
#define		Z_FLAG	0x40
#define		H_FLAG	0x10
#define		P_FLAG	0x04
#define		V_FLAG	0x04
#define		N_FLAG	0x02
#define		C_FLAG	0x01


	ld	hl,500
	ld	de,400
	sbc	hl,de
	.expect f = !S_FLAG + !Z_FLAG + !V_FLAG + N_FLAG + !C_FLAG

	ld	hl,400
	ld	de,500
	sbc	hl,de
	.expect f = S_FLAG + !Z_FLAG + !V_FLAG + N_FLAG + C_FLAG


.macro test_min &A,&B
	ld	hl,&A
	ld	de,&B
	call min
	.expect	 hl = min(&A,&B)
.endm
	test_min 12,34
	test_min 45,12
	test_min 2245,1222
	test_min -12,-33
	test_min -33,-12
	test_min -3345,-14482
	test_min +2345,-1298
	test_min -2345,+1298
	scf
	test_min +12345,+12345
	and a
	test_min +12345,+12345
	scf
	test_min -0x8000,+0x7fff
	and a
	test_min -0x8000,+0x7fff
	scf
	test_min +0x7fff,-0x8000
	and a
	test_min +0x7fff,-0x8000

.macro test_max &A,&B
	ld	hl,&A
	ld	de,&B
	call max
	.expect	 hl = max(&A,&B)
.endm
	test_max 12,34
	test_max 45,12
	test_max 2245,1222
	test_max -12,-33
	test_max -33,-12
	test_max -3345,-14482
	test_max +2345,-1298
	test_max -2345,+1298
	scf
	test_max +12345,+12345
	and a
	test_max +12345,+12345
.area ROM


; -------------------------------------------
; int minmax ( int a, int n, int e ) = max(a,min(n,e))

#local
level = 0
num_lvars = 0

.area ROP
minmax::
	PROC_START
	.dw	ld_a_bc		; todo: caller?
;	.dw	ld_n_de
;	.dw	ld_e_hl		; store hl -> e
;	.dw	ld_de_n
;	.dw	ld_hl_e
	.dw	min			; level0 function
	.dw	ld_de_a
	.dw	max			; level0 function
	RETURN

	LOCAL a
	LOCAL n
	LOCAL e
.area ROM
#endlocal


.area TEST
; first code to test ROP code execution:

.macro minmax_test &A, &N, &E
	ld	bc,&A
	ld	de,&N
	ld	hl,&E
	ld	sp,$+4 \ ret
	.dw	minmax
	.dw	$+2
	.expect hl = min(max(&A,&N),&E)
.endm

	minmax_test 10,100,1000
	minmax_test 100,10,1000
	minmax_test 10,1000,100
	minmax_test -1000,-100,-10
	minmax_test -100,-1000,-10
	minmax_test -1000,-10,-100
	minmax_test -1000,0,+1000
	minmax_test -1000,-2000,+1000
	minmax_test -1000,+2000,+1000
	minmax_test -0x8000,0x7fff,0x7fff
	minmax_test -0x8000,-0x7fff,0x7fff
	minmax_test -0x7fff,-0x8000,0x7fff
	ld	sp,0

.area ROM


; ----------------------------------
; shift left  ( hl -- hl )
; shift right ( hl -- hl )

sl1::
	add	hl,hl
	ret

sru1::
	srl	h
	rr	l
	ret

sr1::
	sra	h
	rr	l
	ret

; ----------------------------------
; incr ( hl -- hl )
; decr ( hl -- hl )

incr::
	inc	hl
	ret

dec::
	dec	hl
	ret

; ----------------------------------
; neg ( hl -- hl )
; cpl ( hl -- hl )

neg::
	xor	a \ sub l \ ld l,a
	sbc	a \ sub	h \ ld h,a
	ret

cpl::
	ld	a,h \ cpl \ ld h,a
	ld	a,l \ cpl \ ld l,a
	ret


; ----------------------------------
; compare and just return the flags: c/z/v

rcmp::				; hl > de   --> cy / pe = overflow
	ex	hl,de		; hl <= de  --> nc / po = no overflow
cmp::				; hl < de   --> cy / pe = overflow
	and	a			; hl >= de  --> nc / po = no overflow
	sbc	hl,de		; hl == de  --> z
	ret				; hl != de  --> nz


; ----------------------------------
; signed compare:
; ----------------------------------

; ----------------------------------
; gt ( hl de -- bool )
; lt ( hl de -- bool )

gt::				; hl > de
	ex	hl,de
lt::				; hl < de
	xor	a
	sbc	hl,de
	ld	h,a \ ld l,a
	ret	po			; no ovfl => hl >= de => false
	inc	l
	ret

; ----------------------------------
; le ( hl de -- bool )
; ge ( hl de -- bool )

le::				; hl <= de
	ex	hl,de
ge::				; hl >= de
	xor	a
	sbc	hl,de
	ld	h,a \ ld l,a
	ret	pe			; ovfl => hl < de => false
	inc	l
	ret


; ----------------------------------
; signed or unsigned:
; ----------------------------------

; ----------------------------------
; eq ( hl de -- bool )
; ne ( hl de -- bool )

eq::
	xor	a
	sbc	hl,de
	ld h,a \ ld l,a
	ret	nz			; nz => false
	inc	l
	ret

ne::
	and	a
	sbc	hl,de
	ret z			; z  --> return 0
	ld	hl,1
	ret



; ----------------------------------
; program flow:
; ----------------------------------

; ----------------------------------
; jump to address

jmp::
	pop	hl			; address
	ld	sp,hl		; jump
	ret

; ----------------------------------
; branch relative
; relative to position behind offset

bra::
	pop	hl			; offset
	add	hl,sp
	ld	sp,hl
	ret

; ----------------------------------
; jump if hl == 0

jp_0::
	ld	a,h
	or	l
	pop	hl			; dest
	ret	nz
	ld	sp,hl		; jump
	ret

; ----------------------------------
; jump if hl != 0

jp_1::
	ld	a,h
	or	l
	pop	hl			; dest
	ret	z
	ld	sp,hl		; jump
	ret

; ----------------------------------
; jump if hl <= de  (signed)
; jump if hl >= de  (signed)

jp_le::
	ex	hl,de
jp_ge::
	and	a
	sbc	hl,de
jp_po::				; jump if parity odd
jp_no::				; jump if no overflow  (signed)
	pop	hl
	ret	pe
	ld	sp,hl
	ret

; ----------------------------------
; jump if hl > de  (signed)
; jump if hl < de  (signed)

jp_gt::
	ex	hl,de
jp_lt::
	and	a
	sbc	hl,de
jp_pe::				; jump if parity even
jp_ov::				; jump if overflow
	pop	hl
	ret	po
	ld	sp,hl
	ret

; ----------------------------------
; jump if hl > de  (unsigned)
; jump if hl < de  (unsigned)

jp_gtu::
	ex	hl,de
jp_ltu::
	and	a
	sbc	hl,de
jp_cy::				; jump if carry from bit15
	pop	hl			; dest
	ret	nc			; don't jump
	ld	sp,hl		; jump
	ret

; ----------------------------------
; jump if hl <= de  (unsigned)
; jump if hl >= de  (unsigned)

jp_leu::
	ex	hl,de
jp_geu::
	and	a
	sbc	hl,de
jp_nc::				; jump if no carry from bit15
	pop	hl
	ret	c
	ld	sp,hl
	ret

; ----------------------------------
; jump if hl == de

jp_eq::
	and	a
	sbc	hl,de
jp_z::
	pop	hl
	ret	nz
	ld	sp,hl
	ret

; ----------------------------------
; jump if hl != de

jp_ne::
	and	a
	sbc	hl,de
jp_nz::
	pop	hl
	ret	z
	ld	sp,hl
	ret















; ---------------------------------------
; The system's interrupt handler
; using checksums to repair overwritten ROP code
;
; The ROP-VM uses the stack pointer as it's PC. Interrupts push a return address on the stack
; and eventually overwrite a word within ROP code.
; => the interrupt handler must restore the overwritten word
; => The ROP code must be ram-based (not romable)
; => calculate checksums of ranges of the program.
;
; This adds some restrictions to the program and has some drawbacks:
; - restoring the overwritten word is expensive
;   this code uses a virtal pagesize of 64 bytes. (adjustable)
; - virtual opcodes must be word-aligned, which luckily is the best anyway.
; - the entire ROP code area must be immutable.
;   -> the remainder of the last page must be unused or immutable as well.
;   for simplicity this implementation only tests the high byte:
;   -> the entire 256 byte pages of the first ROP code page and of the last ROP code page must be immutable too.
;
; INFO: time and size estimation for pagesize 64, 128 and 256 bytes:
; (added size for checksum table for 16kB Vcode and fully unrolled checksum calculation)
; pgsz 64:  512+64  = 576 bytes,  32*21 =  672cc/irpt =  33600cc/sec = 0.96% cpu time@3.5MHz
; pgsz 128: 256+128 = 384 bytes,  64*21 = 1344cc/irpt =  67200cc/sec = 1.92% cpu time@3.5MHz
; pgsz 256: 128+256 = 384 bytes, 128*21 = 2688cc/irpt = 134400cc/sec = 3.84% cpu time@3.5MHz




.area DATA
; ---------------------------------------
; the ROP checksums table
; may be stored in contended ram

rop_pagebits::  = 6
rop_pagesize    = 1 << rop_pagebits
rop_pagemask	= rop_pagesize - 1
rop_start  		= ROP & 0xFF00
rop_end	 		= (ROP_end + 0xff) & 0xFF00
rop_size 		= rop_end - rop_start
rop_numpages 	= rop_size / rop_pagesize

rop_checksums:
	  defs	rop_numpages * 2
rop_checksums_end:


.area GSINIT
; ---------------------------------------
; Initialization:
; calculate checksums
; run-through code

	ld	ix,0			; save sp
	add	ix,sp

	ld	de,rop_checksums	; de -> checksum table
	ld	sp,rop_start		; sp -> Vcode

2$:	ld	a,rop_numpages
	ex	af,af'				; a' = num pages (loop counter)

	ld	hl,0				; hl = checksum akku
	ld	a,rop_pagesize/2	; a = inner loop counter

1$:	pop	bc
	add	hl,bc
	dec	a
	jr	nz,1$

	ld	a,l \ ld (de++),a	; store checksum
	ld	a,h \ ld (de++),a

	ex	af,af'
	dec	a
	jr	nz,2$

	ld	sp,ix				; restore sp


.area DATA
; ---------------------------------------
; interrupt data
; can happily reside in contended ram!

int_stack: 	defs 10			; adjust as needed
int_stackend:
save_de:  	defs 2
save_bc:  	defs 2
save_af:  	defs 2
save_hl:	defs 2


.area RAM
; ---------------------------------------
; system's interrupt handler
; entered with ret addr probably written into ROP code
; -> save registers, set sp to real stack, restore overwritten word
;    call interrupt handler, restore registers, return
; must be in ram because the final jump address must be modified.

interrupt_handler::

; save registers:

	ld 	(save_hl),hl	; save HL
	pop hl
	ld 	(save_reti),hl	; save return address
	ld 	(save_sp),sp	; save SP (as it was before interrupt: points behind the overwritten word)

	ld	hl,0
	push hl				; overwrite overwritten word with 0

	ld	sp,save_af+2	; set sp
	push af				; *** now we can use the FLAGS! ***
	push bc
	push de

; check whether ROP code was overwritten

	ld	hl,(save_sp)	; hl = SP -> overwritten_word+2
	dec	hl				; hl -> overwritten_word+1
	ld	a,h				; a = hi(&overwritten_word)
	sub	a,hi(rop_start)
	sub	a,hi(rop_size)
	jp	nc, notinvc		; not in ROP code

;  calculate checksum of affected ROP code page

	ld	a,l
	and	~rop_pagemask
	ld	l,a				; hl -> rop_page

	ld	sp,hl			; for popping
	ld	hl,0			; checksum
   .rept rop_pagesize/2
  	pop bc \ add hl,bc	; 21cc
   .endm
	ld	sp, int_stackend

	ex	hl,de			; de = checksum of page minus the overwritten word (which was set to 0)

; get original checksum of page
	; &checksum = rop_checksums + (&the_word-rop_start) / rop_pagesize * 2
	; &checksum = rop_checksums + (&the_word-rop_start) >> rop_pagebits << 1

	ld	hl,(save_sp)
	dec	hl
	dec	hl
	ld	bc,-rop_start
	add	hl,bc
	xor	a
	.rept 8 - rop_pagebits
	add	hl,hl \ adc a	; hl << (8-6)
	.endm
	ld	l,h
	ld	h,a				; hl << (8-6) >> 8   => hl >> 6
	add	hl,hl			; hl >> 6 << 1
	ld	bc,rop_checksums
	add	hl,bc			; hl -> page's checksum

	ld	a,(hl++)
	ld	h,(hl)
	ld	l,a				; hl = page's checksum

; calculate missing word and restore it

	and	a
	sbc	hl,de			; hl = original value
	ex	hl,de			; de = original value
	ld	hl,(save_sp)
	ld	(--hl),e
	ld	(--hl),d		; overwritten word restored!    :-)

; call interrupt handler

notinvc:
	call interrupt_handler

; restore registers and return from interrupt

	pop	de
	pop	bc
	pop	af
	pop hl

	ld 	sp,0		; <-- self-modifying code!
save_sp = $-2

	ei
	jp	0			; <-- self-modifying code!
save_reti = $-2








