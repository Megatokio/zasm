;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.4.1 #9090 (Nov 13 2014) (Mac OS X x86_64)
; This file was generated Sun Mar  5 13:12:14 2017
;--------------------------------------------------------
	.module __print_format
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _strlen
	.globl __print_format
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:95: output_digit (unsigned char n, bool lower_case, pfn_outputchar output_char, void* p)
;	---------------------------------
; Function output_digit
; ---------------------------------
_output_digit:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:97: register unsigned char c = n + (unsigned char)'0';
	ld	a,4 (ix)
	add	a, #0x30
	ld	d,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:99: if (c > (unsigned char)'9')
	ld	a,#0x39
	sub	a, d
	jr	NC,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:101: c += (unsigned char)('A' - '0' - 10);
	ld	a,d
	add	a, #0x07
	ld	d,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:102: if (lower_case)
	bit	0,5 (ix)
	jr	Z,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:103: c += (unsigned char)('a' - 'A');
	ld	a,d
	add	a, #0x20
	ld	d,a
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:105: output_char( c, p );
	ld	l,8 (ix)
	ld	h,9 (ix)
	push	hl
	push	de
	inc	sp
	ld	l,6 (ix)
	ld	h,7 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	ix
	ret
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:109: output_2digits (unsigned char b, bool lower_case, pfn_outputchar output_char, void* p)
;	---------------------------------
; Function output_2digits
; ---------------------------------
_output_2digits:
	push	ix
	ld	ix,#0
	add	ix,sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:111: output_digit( b>>4,   lower_case, output_char, p );
	ld	a,4 (ix)
	rlca
	rlca
	rlca
	rlca
	and	a,#0x0F
	ld	d,a
	ld	l,8 (ix)
	ld	h,9 (ix)
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,5 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_output_digit
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:112: output_digit( b&0x0F, lower_case, output_char, p );
	ld	a,4 (ix)
	and	a, #0x0F
	ld	d,a
	ld	l,8 (ix)
	ld	h,9 (ix)
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,5 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_output_digit
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:116: calculate_digit (value_t * value, unsigned char radix)
;	---------------------------------
; Function calculate_digit
; ---------------------------------
_calculate_digit:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-6
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:118: unsigned long ul = value->ul;
	ld	a,4 (ix)
	ld	-2 (ix),a
	ld	a,5 (ix)
	ld	-1 (ix),a
	ld	e,-2 (ix)
	ld	d,-1 (ix)
	ld	hl, #0x0000
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:119: unsigned char * pb4 = &value->byte[4];
	ld	a,-2 (ix)
	add	a, #0x04
	ld	c,a
	ld	a,-1 (ix)
	adc	a, #0x00
	ld	b,a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:120: unsigned char i = 32;
	ld	d,#0x20
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:122: do
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:124: *pb4 = (*pb4 << 1) | ((ul >> 31) & 0x01);
	ld	a,(bc)
	add	a, a
	ld	e,a
	ld	a,-3 (ix)
	rlc	a
	and	a,#0x01
	or	a, e
	ld	(bc),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:125: ul <<= 1;
	push	af
	pop	af
	sla	-6 (ix)
	rl	-5 (ix)
	rl	-4 (ix)
	rl	-3 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:127: if (radix <= *pb4 )
	ld	a,(bc)
	ld	e,a
	sub	a, 6 (ix)
	jr	C,00104$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:129: *pb4 -= radix;
	ld	a,e
	sub	a, 6 (ix)
	ld	(bc),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:130: ul |= 1;
	set	0, -6 (ix)
00104$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:133: while (--i);
	ld	a,d
	add	a,#0xFF
	ld	d,a
	or	a, a
	jr	NZ,00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:134: value->ul = ul;
	ld	e,-2 (ix)
	ld	d,-1 (ix)
	ld	hl, #0x0000
	add	hl, sp
	ld	bc, #0x0004
	ldir
	ld	sp, ix
	pop	ix
	ret
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:152: output_float (float f, unsigned char reqWidth,
;	---------------------------------
; Function output_float
; ---------------------------------
_output_float:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-156
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:157: unsigned char charsOutputted = 0;
	ld	-14 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:159: bool negative = 0;
	ld	iy,#13
	add	iy,sp
	ld	0 (iy),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:165: signed char exp = -128;
	ld	-1 (ix),#0x80
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:168: if (f<0)
	ld	hl,#0x0000
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fslt
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a,l
	or	a, a
	jr	Z,00102$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:170: negative=1;
	ld	iy,#13
	add	iy,sp
	ld	0 (iy),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:171: f=-f;
	ld	a,7 (ix)
	xor	a,#0x80
	ld	7 (ix),a
00102$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:174: if (f>0x00ffffff)
	ld	hl,#0x4B7F
	push	hl
	ld	hl,#0xFFFF
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fsgt
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a,l
	or	a, a
	jp	Z,00111$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:178: for (exp = 0; f >= 10.0; exp++) f /=10.0;
	ld	iy,#0
	add	iy,sp
	ld	0 (iy),#0x00
00181$:
	ld	hl,#0x4120
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fslt
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a,l
	or	a, a
	jr	NZ,00205$
	ld	hl,#0x4120
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fsdiv
	pop	af
	pop	af
	pop	af
	pop	af
	ld	4 (ix), l
	ld	5 (ix), h
	ld	6 (ix),e
	ld	7 (ix),d
	ld	iy,#0
	add	iy,sp
	inc	0 (iy)
	jr	00181$
00205$:
00184$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:179: for (       ; f < 1.0;   exp--) f *=10.0;
	ld	hl,#0x3F80
	push	hl
	ld	hl,#0x0000
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fslt
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-2 (ix), l
	ld	a, l
	or	a, a
	jr	Z,00246$
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	hl,#0x4120
	push	hl
	ld	hl,#0x0000
	push	hl
	call	___fsmul
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-3 (ix),d
	ld	-4 (ix),e
	ld	-5 (ix),h
	ld	-6 (ix),l
	ld	hl, #160
	add	hl, sp
	ex	de, hl
	ld	hl, #150
	add	hl, sp
	ld	bc, #4
	ldir
	ld	iy,#0
	add	iy,sp
	dec	0 (iy)
	jr	00184$
00246$:
	ld	iy,#0
	add	iy,sp
	ld	a,0 (iy)
	ld	-1 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:181: if (negative) { OUTPUT_CHAR ('-', p); }
	ld	iy,#13
	add	iy,sp
	bit	0,0 (iy)
	jr	Z,00108$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	ld	-14 (ix),#0x01
	jr	00109$
00108$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:182: else if (sign) { OUTPUT_CHAR ('+', p); }
	bit	0,12 (ix)
	jr	Z,00109$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2B
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	ld	-14 (ix),#0x01
00109$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:184: reqWidth = 0;
	ld	8 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:185: left = 0;
	ld	10 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:186: zero = 0;
	ld	11 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:187: sign = 0;
	ld	12 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:188: space = 0;
	ld	13 (ix),#0x00
00111$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:192: if (reqDecimals==-1)
	ld	a,9 (ix)
	inc	a
	jr	NZ,00113$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:193: reqDecimals=DEFAULT_FLOAT_PRECISION;
	ld	9 (ix),#0x06
00113$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:196: rounding = 0.5;
	ld	bc,#0x0000
	ld	de,#0x3F00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:197: for (i=reqDecimals; i>0; i--)
	ld	a,9 (ix)
	ld	iy,#1
	add	iy,sp
	ld	0 (iy),a
	ld	a,0 (iy)
	ld	-6 (ix),a
00187$:
	ld	a,-6 (ix)
	or	a, a
	jr	Z,00114$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:199: rounding /= 10.0;
	ld	hl,#0x4120
	push	hl
	ld	hl,#0x0000
	push	hl
	push	de
	push	bc
	call	___fsdiv
	pop	af
	pop	af
	pop	af
	pop	af
	ld	c,l
	ld	b,h
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:197: for (i=reqDecimals; i>0; i--)
	dec	-6 (ix)
	jr	00187$
00114$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:201: f += rounding;
	push	de
	push	bc
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fsadd
	pop	af
	pop	af
	pop	af
	pop	af
	ld	4 (ix), l
	ld	5 (ix), h
	ld	6 (ix),e
	ld	7 (ix),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:204: integerPart = f;
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fs2ulong
	pop	af
	pop	af
	ld	b,l
	ld	c,h
	ld	iy,#9
	add	iy,sp
	ld	0 (iy),b
	ld	1 (iy),c
	ld	2 (iy),e
	ld	3 (iy),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:205: decimalPart = f - integerPart;
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	___ulong2fs
	pop	af
	pop	af
	push	de
	push	hl
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	call	___fssub
	pop	af
	pop	af
	pop	af
	pop	af
	ld	b,l
	ld	c,h
	ld	iy,#5
	add	iy,sp
	ld	0 (iy),b
	ld	1 (iy),c
	ld	2 (iy),e
	ld	3 (iy),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:208: while (integerPart)
	ld	hl,#0x000E
	add	hl,sp
	ld	-6 (ix),l
	ld	-5 (ix),h
	ld	iy,#4
	add	iy,sp
	ld	0 (iy),#0x00
00115$:
	ld	iy,#9
	add	iy,sp
	ld	a,3 (iy)
	or	a, 2 (iy)
	or	a, 1 (iy)
	or	a,0 (iy)
	jp	Z,00248$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:210: fpBuffer[fpBI++]='0' + integerPart%10;
	ld	iy,#4
	add	iy,sp
	ld	d,0 (iy)
	inc	0 (iy)
	ld	a,-6 (ix)
	add	a, d
	ld	-8 (ix),a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	-7 (ix),a
	ld	hl,#0x0000
	push	hl
	ld	hl,#0x000A
	push	hl
	ld	iy,#13
	add	iy,sp
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	__modulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	a, l
	add	a, #0x30
	ld	l,-8 (ix)
	ld	h,-7 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:211: integerPart /= 10;
	ld	hl,#0x0000
	push	hl
	ld	hl,#0x000A
	push	hl
	ld	iy,#13
	add	iy,sp
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	__divulong
	pop	af
	pop	af
	pop	af
	pop	af
	ld	b,l
	ld	c,h
	ld	iy,#9
	add	iy,sp
	ld	0 (iy),b
	ld	1 (iy),c
	ld	2 (iy),e
	ld	3 (iy),d
	jp	00115$
00248$:
	ld	iy,#4
	add	iy,sp
	ld	a,0 (iy)
	ld	-8 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:213: if (!fpBI)
	ld	a,0 (iy)
	or	a, a
	jr	NZ,00119$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:216: fpBuffer[fpBI++]='0';
	ld	a,0 (iy)
	inc	a
	ld	-8 (ix),a
	ld	a,-6 (ix)
	ld	hl,#4
	add	hl,sp
	add	a, (hl)
	ld	e,a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	d,a
	ld	a,#0x30
	ld	(de),a
00119$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:222: for (i=reqDecimals; i>0; i--)
	ld	a,9 (ix)
	ld	iy,#1
	add	iy,sp
	ld	0 (iy),a
	ld	a,-8 (ix)
	ld	iy,#3
	add	iy,sp
	ld	0 (iy),a
	ld	iy,#1
	add	iy,sp
	ld	a,0 (iy)
	ld	-2 (ix),a
00190$:
	ld	a,-2 (ix)
	or	a, a
	jr	NZ,00189$
	ld	a,-2 (ix)
	ld	iy,#1
	add	iy,sp
	ld	0 (iy),a
	jp	00120$
00189$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:224: decimalPart *= 10.0;
	ld	iy,#5
	add	iy,sp
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	ld	hl,#0x4120
	push	hl
	ld	hl,#0x0000
	push	hl
	call	___fsmul
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-9 (ix),d
	ld	-10 (ix),e
	ld	-11 (ix),h
	ld	-12 (ix),l
	ld	hl, #5
	add	hl, sp
	ex	de, hl
	ld	hl, #144
	add	hl, sp
	ld	bc, #4
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:226: integerPart = decimalPart;
	ld	iy,#5
	add	iy,sp
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	___fs2ulong
	pop	af
	pop	af
	ld	-9 (ix),d
	ld	-10 (ix),e
	ld	-11 (ix),h
	ld	-12 (ix),l
	ld	hl, #9
	add	hl, sp
	ex	de, hl
	ld	hl, #144
	add	hl, sp
	ld	bc, #4
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:227: fpBuffer[fpBD++] = '0' + integerPart;
	ld	iy,#3
	add	iy,sp
	ld	d,0 (iy)
	inc	0 (iy)
	ld	a,-6 (ix)
	add	a, d
	ld	-12 (ix),a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	-11 (ix),a
	ld	iy,#9
	add	iy,sp
	ld	a,0 (iy)
	ld	-13 (ix), a
	add	a, #0x30
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:228: decimalPart -= integerPart;
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	___ulong2fs
	pop	af
	pop	af
	ld	-9 (ix),d
	ld	-10 (ix),e
	ld	-11 (ix),h
	ld	-12 (ix),l
	ld	l,-10 (ix)
	ld	h,-9 (ix)
	push	hl
	ld	l,-12 (ix)
	ld	h,-11 (ix)
	push	hl
	ld	iy,#9
	add	iy,sp
	ld	l,2 (iy)
	ld	h,3 (iy)
	push	hl
	ld	l,0 (iy)
	ld	h,1 (iy)
	push	hl
	call	___fssub
	pop	af
	pop	af
	pop	af
	pop	af
	ld	-9 (ix),d
	ld	-10 (ix),e
	ld	-11 (ix),h
	ld	-12 (ix),l
	ld	hl, #5
	add	hl, sp
	ex	de, hl
	ld	hl, #144
	add	hl, sp
	ld	bc, #4
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:222: for (i=reqDecimals; i>0; i--)
	dec	-2 (ix)
	jp	00190$
00120$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:231: minWidth=fpBI; // we need at least these
	ld	a,-8 (ix)
	ld	iy,#2
	add	iy,sp
	ld	0 (iy),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:232: minWidth+=reqDecimals?reqDecimals+1:0; // maybe these
	ld	a,9 (ix)
	or	a, a
	jr	Z,00198$
	ld	e,9 (ix)
	inc	e
	jr	00199$
00198$:
	ld	e,#0x00
00199$:
	push	hl
	ld	iy,#4
	add	iy,sp
	pop	hl
	add	hl, de
	push	hl
	ld	0 (iy), l
	pop	hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:233: if (negative || sign || space)
	ld	iy,#13
	add	iy,sp
	bit	0,0 (iy)
	jr	NZ,00121$
	bit	0,12 (ix)
	jr	NZ,00121$
	bit	0,13 (ix)
	jr	Z,00122$
00121$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:234: minWidth++; // and maybe even this :)
	ld	iy,#2
	add	iy,sp
	inc	0 (iy)
00122$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:236: if (!left && reqWidth>i)
	bit	0,10 (ix)
	jp	NZ,00159$
	ld	hl,#1
	add	hl,sp
	ld	a,(hl)
	sub	a, 8 (ix)
	jp	NC,00159$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:238: if (zero)
	bit	0,11 (ix)
	jp	Z,00228$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:240: if (negative) { OUTPUT_CHAR('-', p); }
	ld	iy,#13
	add	iy,sp
	bit	0,0 (iy)
	jr	Z,00131$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
	jr	00226$
00131$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:241: else if (sign) { OUTPUT_CHAR('+', p); }
	bit	0,12 (ix)
	jr	Z,00128$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2B
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
	jr	00226$
00128$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:242: else if (space) { OUTPUT_CHAR(' ', p); }
	bit	0,13 (ix)
	jr	Z,00226$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:243: while (reqWidth-->minWidth)
00226$:
	ld	d,-14 (ix)
	ld	e,8 (ix)
00133$:
	ld	b,e
	dec	e
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	sub	a, b
	jp	NC,00250$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:245: OUTPUT_CHAR('0', p);
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x30
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	inc	d
	jr	00133$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:250: while (reqWidth-->minWidth)
00228$:
	ld	a,-14 (ix)
	ld	-13 (ix),a
	ld	d,8 (ix)
00136$:
	ld	e,d
	dec	d
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	sub	a, e
	jr	NC,00251$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:252: OUTPUT_CHAR(' ', p);
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	inc	-13 (ix)
	jr	00136$
00251$:
	ld	a,-13 (ix)
	ld	-14 (ix),a
	ld	8 (ix),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:254: if (negative) { OUTPUT_CHAR('-', p); }
	ld	iy,#13
	add	iy,sp
	bit	0,0 (iy)
	jr	Z,00145$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	ld	a,-13 (ix)
	inc	a
	ld	-14 (ix),a
	jp	00160$
00145$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:255: else if (sign) { OUTPUT_CHAR('+', p); }
	bit	0,12 (ix)
	jr	Z,00142$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2B
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	ld	a,-13 (ix)
	inc	a
	ld	-14 (ix),a
	jp	00160$
00142$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:256: else if (space) { OUTPUT_CHAR(' ', p); }
	bit	0,13 (ix)
	jp	Z,00160$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	ld	a,-13 (ix)
	inc	a
	ld	-14 (ix),a
	jr	00160$
00159$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:261: if (negative) { OUTPUT_CHAR('-', p); }
	ld	iy,#13
	add	iy,sp
	bit	0,0 (iy)
	jr	Z,00156$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
	jr	00160$
00156$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:262: else if (sign) { OUTPUT_CHAR('+', p); }
	bit	0,12 (ix)
	jr	Z,00153$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2B
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
	jr	00160$
00153$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:263: else if (space) { OUTPUT_CHAR(' ', p); }
	bit	0,13 (ix)
	jr	Z,00160$
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:304: return charsOutputted;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:263: else if (space) { OUTPUT_CHAR(' ', p); }
00250$:
	ld	-14 (ix),d
	ld	8 (ix),e
00160$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:267: i = fpBI-1;
	ld	d,-8 (ix)
	dec	d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:268: do
	ld	e,-14 (ix)
00162$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:270: OUTPUT_CHAR (fpBuffer[i], p);
	ld	a,-6 (ix)
	add	a, d
	ld	l,a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	h,a
	ld	b,(hl)
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	push	bc
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	inc	e
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:272: while (i--);
	ld	b,d
	dec	d
	ld	a,b
	or	a, a
	jr	NZ,00162$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:275: if (reqDecimals)
	ld	-14 (ix),e
	ld	a,9 (ix)
	or	a, a
	jr	Z,00169$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:277: OUTPUT_CHAR ('.', p);
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2E
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	ld	a,e
	inc	a
	ld	-14 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:279: while (reqDecimals--)
	ld	e,-8 (ix)
	ld	a,-14 (ix)
	ld	-13 (ix),a
	ld	a,9 (ix)
	ld	-12 (ix),a
00165$:
	ld	c,-12 (ix)
	dec	-12 (ix)
	ld	a,c
	or	a, a
	jr	Z,00253$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:281: OUTPUT_CHAR (fpBuffer[i++], p);
	ld	l,e
	inc	e
	ld	a,-6 (ix)
	add	a, l
	ld	l,a
	ld	a,-5 (ix)
	adc	a, #0x00
	ld	h,a
	ld	d,(hl)
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	push	de
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	inc	-13 (ix)
	jr	00165$
00253$:
	ld	a,-13 (ix)
	ld	-14 (ix),a
00169$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:285: if (left && reqWidth>minWidth)
	bit	0,10 (ix)
	jr	Z,00174$
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	sub	a, 8 (ix)
	jr	NC,00174$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:287: while (reqWidth-->minWidth)
	ld	e,-14 (ix)
	ld	c,8 (ix)
00170$:
	ld	d,c
	dec	c
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	sub	a, d
	jr	NC,00254$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:289: OUTPUT_CHAR(' ', p);
	push	bc
	push	de
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	pop	bc
	inc	e
	jr	00170$
00254$:
	ld	-14 (ix),e
00174$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:293: if (exp != -128)
	ld	a,-1 (ix)
	sub	a, #0x80
	jp	Z,00179$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:295: OUTPUT_CHAR ('e', p);
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x65
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:296: if (exp<0)
	bit	7, -1 (ix)
	jr	Z,00177$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:298: OUTPUT_CHAR ('-', p);
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:299: exp = -exp;
	xor	a, a
	sub	a, -1 (ix)
	ld	-1 (ix),a
00177$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:301: OUTPUT_CHAR ('0'+exp/10, p);
	ld	a,#0x0A
	push	af
	inc	sp
	ld	a,-1 (ix)
	push	af
	inc	sp
	call	__divuschar
	pop	af
	ld	a,l
	add	a, #0x30
	ld	d,a
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	push	de
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:302: OUTPUT_CHAR ('0'+exp%10, p);
	ld	a,#0x0A
	push	af
	inc	sp
	ld	a,-1 (ix)
	push	af
	inc	sp
	call	__moduschar
	pop	af
	ld	a,l
	add	a, #0x30
	ld	d,a
	ld	l,16 (ix)
	ld	h,17 (ix)
	push	hl
	push	de
	inc	sp
	ld	l,14 (ix)
	ld	h,15 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-14 (ix)
00179$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:304: return charsOutputted;
	ld	l,-14 (ix)
	ld	sp, ix
	pop	ix
	ret
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:310: _print_format (pfn_outputchar pfn, void* pvoid, const char *format, va_list ap)
;	---------------------------------
; Function _print_format
; ---------------------------------
__print_format_start::
__print_format:
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	hl,#-53
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:335: charsOutputted = 0;
	ld	-21 (ix),#0x00
	ld	-20 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:337: while( c=*format++ )
	ld	hl,#0x0011
	add	hl,sp
	ld	-23 (ix),l
	ld	-22 (ix),h
	ld	hl,#0x0007
	add	hl,sp
	ld	-2 (ix),l
	ld	-1 (ix),h
	ld	hl,#0x0011
	add	hl,sp
	ld	-25 (ix),l
	ld	-24 (ix),h
	ld	a,-25 (ix)
	add	a, #0x04
	ld	-15 (ix),a
	ld	a,-24 (ix)
	adc	a, #0x00
	ld	-14 (ix),a
00228$:
	ld	e,8 (ix)
	ld	d,9 (ix)
	ld	a,(de)
	ld	h,a
	inc	de
	ld	8 (ix),e
	ld	9 (ix),d
	ld	-45 (ix),h
	ld	a,h
	or	a, a
	jp	Z,00230$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:339: if ( c=='%' )
	ld	a,-45 (ix)
	sub	a, #0x25
	jp	NZ,00226$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:341: left_justify    = 0;
	ld	-43 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:342: zero_padding    = 0;
	ld	-39 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:343: prefix_sign     = 0;
	ld	-37 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:344: prefix_space    = 0;
	ld	-26 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:345: signed_argument = 0;
	ld	-27 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:346: char_argument   = 0;
	ld	-28 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:347: long_argument   = 0;
	ld	-29 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:348: float_argument  = 0;
	ld	-30 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:349: radix           = 0;
	ld	-41 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:350: width           = 0;
	ld	-42 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:351: decimals        = -1;
	ld	-38 (ix),#0xFF
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:353: get_conversion_spec:
	ld	a,8 (ix)
	ld	-17 (ix),a
	ld	a,9 (ix)
	ld	-16 (ix),a
00101$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:355: c = *format++;
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	a,(hl)
	ld	-45 (ix),a
	inc	-17 (ix)
	jr	NZ,00466$
	inc	-16 (ix)
00466$:
	ld	a,-17 (ix)
	ld	8 (ix),a
	ld	a,-16 (ix)
	ld	9 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:357: if (c=='%')
	ld	a,-45 (ix)
	sub	a, #0x25
	jr	NZ,00103$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:359: OUTPUT_CHAR(c, p);
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-45 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jp	NZ,00228$
	inc	-20 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:360: continue;
	jp	00228$
00103$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:363: if (isdigit(c))
	ld	h,-45 (ix)
	ld	a,h
	sub	a, #0x30
	jr	C,00110$
	ld	a,#0x39
	sub	a, h
	jr	C,00110$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:365: if (decimals==-1)
	ld	a,-38 (ix)
	inc	a
	jr	NZ,00107$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:367: width = 10*width + c - '0';
	ld	a,-42 (ix)
	ld	c,a
	add	a, a
	add	a, a
	add	a, c
	add	a, a
	ld	-18 (ix), a
	add	a, -45 (ix)
	add	a,#0xD0
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:368: if (width == 0)
	ld	-42 (ix), a
	or	a, a
	jr	NZ,00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:371: zero_padding = 1;
	ld	-39 (ix),#0x01
	jr	00101$
00107$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:376: decimals = 10*decimals + c - '0';
	ld	l,-38 (ix)
	ld	c,l
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	ld	a,l
	add	a, -45 (ix)
	add	a,#0xD0
	ld	-38 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:378: goto get_conversion_spec;
	jp	00101$
00110$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:381: if (c=='.')
	ld	a,-45 (ix)
	sub	a, #0x2E
	jr	NZ,00115$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:383: if (decimals==-1)
	ld	a,-38 (ix)
	inc	a
	jp	NZ,00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:384: decimals=0;
	ld	-38 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:387: goto get_conversion_spec;
	jp	00101$
00115$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:390: if (islower(c))
	ld	h,-45 (ix)
	ld	a,h
	sub	a, #0x61
	jr	C,00117$
	ld	a,#0x7A
	sub	a, h
	jr	C,00117$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:392: c = toupper(c);
	res	5, -45 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:393: lower_case = 1;
	ld	-31 (ix),#0x01
	jr	00118$
00117$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:396: lower_case = 0;
	ld	-31 (ix),#0x00
00118$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:398: switch( c )
	ld	a,-45 (ix)
	sub	a, #0x20
	jp	Z,00122$
	ld	a,-45 (ix)
	sub	a, #0x2B
	jp	Z,00121$
	ld	a,-45 (ix)
	sub	a, #0x2D
	jr	Z,00120$
	ld	a,-45 (ix)
	sub	a, #0x42
	jp	Z,00123$
	ld	a,-45 (ix)
	sub	a, #0x43
	jp	Z,00129$
	ld	a,-45 (ix)
	sub	a, #0x44
	jp	Z,00154$
	ld	a,-45 (ix)
	sub	a, #0x46
	jp	Z,00158$
	ld	a,-45 (ix)
	sub	a, #0x48
	jp	Z,00101$
	ld	a,-45 (ix)
	sub	a, #0x49
	jp	Z,00154$
	ld	a,-45 (ix)
	sub	a, #0x4A
	jp	Z,00101$
	ld	a,-45 (ix)
	sub	a, #0x4C
	jr	Z,00128$
	ld	a,-45 (ix)
	sub	a, #0x4F
	jp	Z,00155$
	ld	a,-45 (ix)
	sub	a, #0x50
	jp	Z,00152$
	ld	a,-45 (ix)
	sub	a, #0x53
	jp	Z,00133$
	ld	a,-45 (ix)
	sub	a, #0x54
	jp	Z,00101$
	ld	a,-45 (ix)
	sub	a, #0x55
	jp	Z,00156$
	ld	a,-45 (ix)
	sub	a, #0x58
	jp	Z,00157$
	ld	a,-45 (ix)
	sub	a, #0x5A
	jp	Z,00101$
	jp	00159$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:400: case '-':
00120$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:401: left_justify = 1;
	ld	-43 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:402: goto get_conversion_spec;
	jp	00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:403: case '+':
00121$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:404: prefix_sign = 1;
	ld	-37 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:405: goto get_conversion_spec;
	jp	00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:406: case ' ':
00122$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:407: prefix_space = 1;
	ld	-26 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:408: goto get_conversion_spec;
	jp	00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:409: case 'B': /* byte */
00123$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:410: char_argument = 1;
	ld	-28 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:411: goto get_conversion_spec;
	jp	00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:418: case 'L': /* long */
00128$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:419: long_argument = 1;
	ld	-29 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:420: goto get_conversion_spec;
	jp	00101$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:422: case 'C':
00129$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:423: if( char_argument )
	bit	0,-28 (ix)
	jr	Z,00131$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:424: c = va_arg(ap,char);
	ld	a,10 (ix)
	add	a, #0x01
	ld	-17 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-16 (ix),a
	ld	a,-17 (ix)
	ld	10 (ix),a
	ld	a,-16 (ix)
	ld	11 (ix),a
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	dec	hl
	ld	-17 (ix),l
	ld	-16 (ix),h
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	a,(hl)
	ld	-45 (ix),a
	jr	00132$
00131$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:426: c = va_arg(ap,int);
	ld	a,10 (ix)
	add	a, #0x02
	ld	-17 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-16 (ix),a
	ld	a,-17 (ix)
	ld	10 (ix),a
	ld	a,-16 (ix)
	ld	11 (ix),a
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	dec	hl
	dec	hl
	ld	-17 (ix),l
	ld	-16 (ix),h
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	a,(hl)
	ld	-17 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-16 (ix),a
	ld	a,-17 (ix)
	ld	-45 (ix),a
00132$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:427: OUTPUT_CHAR( c, p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-45 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jp	NZ,00160$
	inc	-20 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:428: break;
	jp	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:430: case 'S':
00133$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:431: PTR = va_arg(ap,ptr_t);
	ld	hl,#0x0011
	add	hl,sp
	ld	-17 (ix),l
	ld	-16 (ix),h
	ld	e,10 (ix)
	ld	d,11 (ix)
	inc	de
	inc	de
	ld	10 (ix),e
	ld	11 (ix),d
	dec	de
	dec	de
	ex	de,hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	(hl),e
	inc	hl
	ld	(hl),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:433: length = strlen(PTR);
	push	de
	call	_strlen
	pop	af
	ld	d,l
	ld	e,h
	ld	-18 (ix),d
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:435: if ( decimals == -1 )
	ld	a,-38 (ix)
	inc	a
	jr	NZ,00135$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:437: decimals = length;
	ld	a,-18 (ix)
	ld	-38 (ix),a
00135$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:439: if ( ( !left_justify ) && (length < width) )
	bit	0,-43 (ix)
	jr	NZ,00274$
	ld	a,-18 (ix)
	sub	a, -42 (ix)
	jr	NC,00274$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:441: width -= length;
	ld	a,-42 (ix)
	sub	a, -18 (ix)
	ld	-42 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:442: while( width-- != 0 )
	ld	c,-21 (ix)
	ld	b,-20 (ix)
	ld	d,-42 (ix)
00136$:
	ld	l,d
	dec	d
	ld	a,l
	or	a, a
	jr	Z,00307$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:444: OUTPUT_CHAR( ' ', p );
	push	bc
	push	de
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	pop	bc
	inc	bc
	jr	00136$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:448: while ( (c = *PTR)  && (decimals-- > 0))
00307$:
	ld	-21 (ix),c
	ld	-20 (ix),b
	ld	-42 (ix),d
00274$:
	ld	a,-38 (ix)
	ld	-19 (ix),a
	ld	a,-21 (ix)
	ld	-4 (ix),a
	ld	a,-20 (ix)
	ld	-3 (ix),a
00143$:
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	a,(de)
	ld	-45 (ix),a
	or	a, a
	jr	Z,00308$
	ld	a,-19 (ix)
	ld	-5 (ix),a
	dec	-19 (ix)
	xor	a, a
	sub	a, -5 (ix)
	jp	PO, 00497$
	xor	a, #0x80
00497$:
	jp	P,00308$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:450: OUTPUT_CHAR( c, p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-45 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-4 (ix)
	jr	NZ,00498$
	inc	-3 (ix)
00498$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:451: PTR++;
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	bc
	ld	d,c
	ld	l,-17 (ix)
	ld	h,-16 (ix)
	ld	(hl),d
	inc	hl
	ld	(hl),b
	jr	00143$
00308$:
	ld	a,-19 (ix)
	ld	-38 (ix),a
	ld	a,-4 (ix)
	ld	-21 (ix),a
	ld	a,-3 (ix)
	ld	-20 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:454: if ( left_justify && (length < width))
	bit	0,-43 (ix)
	jp	Z,00160$
	ld	a,-18 (ix)
	sub	a, -42 (ix)
	jp	NC,00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:456: width -= length;
	ld	a,-42 (ix)
	sub	a, -18 (ix)
	ld	-42 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:457: while( width-- != 0 )
	ld	e,-4 (ix)
	ld	d,-3 (ix)
	ld	c,-42 (ix)
00146$:
	ld	h,c
	dec	c
	ld	a,h
	or	a, a
	jp	Z,00309$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:459: OUTPUT_CHAR( ' ', p );
	push	bc
	push	de
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	pop	bc
	inc	de
	jr	00146$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:464: case 'P':
00152$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:465: PTR = va_arg(ap,ptr_t);
	ld	hl,#0x0011
	add	hl,sp
	ex	de,hl
	ld	c,10 (ix)
	ld	b,11 (ix)
	inc	bc
	inc	bc
	ld	10 (ix),c
	ld	11 (ix),b
	dec	bc
	dec	bc
	ld	l, c
	ld	h, b
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,c
	ld	(de),a
	inc	de
	ld	a,b
	ld	(de),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:467: OUTPUT_CHAR('0', p);
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x30
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00499$
	inc	-20 (ix)
00499$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:468: OUTPUT_CHAR('x', p);
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x78
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00500$
	inc	-20 (ix)
00500$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:469: OUTPUT_2DIGITS( value.byte[1] );
	ld	hl,#0x0012
	add	hl,sp
	ex	de,hl
	ld	a,(de)
	ld	d,a
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	a,-31 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_output_2digits
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	ld	a,-21 (ix)
	add	a, #0x02
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, #0x00
	ld	-20 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:470: OUTPUT_2DIGITS( value.byte[0] );
	ld	l,-23 (ix)
	ld	h,-22 (ix)
	ld	d,(hl)
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	a,-31 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_output_2digits
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
	ld	a,-21 (ix)
	add	a, #0x02
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, #0x00
	ld	-20 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:471: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:474: case 'I':
00154$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:475: signed_argument = 1;
	ld	-27 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:476: radix = 10;
	ld	-41 (ix),#0x0A
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:477: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:479: case 'O':
00155$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:480: radix = 8;
	ld	-41 (ix),#0x08
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:481: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:483: case 'U':
00156$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:484: radix = 10;
	ld	-41 (ix),#0x0A
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:485: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:487: case 'X':
00157$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:488: radix = 16;
	ld	-41 (ix),#0x10
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:489: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:491: case 'F':
00158$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:492: float_argument=1;
	ld	-30 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:493: break;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:495: default:
00159$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:497: OUTPUT_CHAR( c, p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-45 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00160$
	inc	-20 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:667: return charsOutputted;
	jr	00160$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:499: }
00309$:
	ld	-21 (ix),e
	ld	-20 (ix),d
	ld	-42 (ix),c
00160$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:501: if (float_argument)
	bit	0,-30 (ix)
	jp	Z,00223$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:503: value.f = va_arg(ap, float);
	ld	hl,#0x0011
	add	hl,sp
	ld	-4 (ix),l
	ld	-3 (ix),h
	ld	a,10 (ix)
	add	a, #0x04
	ld	-17 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-16 (ix),a
	ld	a,-17 (ix)
	ld	10 (ix),a
	ld	a,-16 (ix)
	ld	11 (ix),a
	ld	a,-17 (ix)
	add	a,#0xFC
	ld	-17 (ix),a
	ld	a,-16 (ix)
	adc	a,#0xFF
	ld	-16 (ix),a
	ld	e,-17 (ix)
	ld	d,-16 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	e,-4 (ix)
	ld	d,-3 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:506: charsOutputted += OUTPUT_FLOAT(value.f, width, decimals, left_justify,
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	a,(hl)
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	h,-26 (ix)
	ld	l,-37 (ix)
	push	hl
	ld	h,-39 (ix)
	ld	l,-43 (ix)
	push	hl
	ld	h,-38 (ix)
	ld	l,-42 (ix)
	push	hl
	ld	l,-7 (ix)
	ld	h,-6 (ix)
	push	hl
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	push	hl
	call	_output_float
	ld	c, l
	ld	b, h
	ld	hl,#14
	add	hl,sp
	ld	sp,hl
	ld	d, c
	ld	h,#0x00
	ld	a,-21 (ix)
	add	a, d
	ld	-21 (ix),a
	ld	a,-20 (ix)
	adc	a, h
	ld	-20 (ix),a
	jp	00228$
00223$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:521: else if (radix != 0)
	ld	a,-41 (ix)
	or	a, a
	jp	Z,00228$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:526: unsigned char MEM_SPACE_BUF_PP *pstore = &store[5];
	ld	a,-2 (ix)
	ld	-53 (ix),a
	ld	a,-1 (ix)
	ld	-52 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:529: if (char_argument)
	bit	0,-28 (ix)
	jp	Z,00169$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:531: value.l = va_arg(ap, char);
	ld	hl,#0x0011
	add	hl,sp
	ld	-9 (ix),l
	ld	-8 (ix),h
	ld	a,10 (ix)
	add	a, #0x01
	ld	-4 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-3 (ix),a
	ld	a,-4 (ix)
	ld	10 (ix),a
	ld	a,-3 (ix)
	ld	11 (ix),a
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	dec	hl
	ld	-4 (ix),l
	ld	-3 (ix),h
	ld	l,-4 (ix)
	ld	h,-3 (ix)
	ld	a,(hl)
	ld	-5 (ix), a
	ld	-13 (ix),a
	ld	a,-5 (ix)
	rla
	sbc	a, a
	ld	-12 (ix),a
	ld	-11 (ix),a
	ld	-10 (ix),a
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	hl, #0x0028
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:532: if (!signed_argument)
	bit	0,-27 (ix)
	jp	NZ,00170$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:534: value.l &= 0xFF;
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	hl, #0x0028
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	-12 (ix),#0x00
	ld	-11 (ix),#0x00
	ld	-10 (ix),#0x00
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	hl, #0x0028
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jp	00170$
00169$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:537: else if (long_argument)
	bit	0,-29 (ix)
	jr	Z,00166$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:539: value.l = va_arg(ap, long);
	ld	hl,#0x0011
	add	hl,sp
	ld	-13 (ix),l
	ld	-12 (ix),h
	ld	a,10 (ix)
	add	a, #0x04
	ld	-9 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-8 (ix),a
	ld	a,-9 (ix)
	ld	10 (ix),a
	ld	a,-8 (ix)
	ld	11 (ix),a
	ld	a,-9 (ix)
	add	a,#0xFC
	ld	-9 (ix),a
	ld	a,-8 (ix)
	adc	a,#0xFF
	ld	-8 (ix),a
	ld	a,-9 (ix)
	ld	-9 (ix),a
	ld	a,-8 (ix)
	ld	-8 (ix),a
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jp	00170$
00166$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:543: value.l = va_arg(ap, int);
	ld	hl,#0x0011
	add	hl,sp
	ld	-13 (ix),l
	ld	-12 (ix),h
	ld	a,10 (ix)
	add	a, #0x02
	ld	-9 (ix),a
	ld	a,11 (ix)
	adc	a, #0x00
	ld	-8 (ix),a
	ld	a,-9 (ix)
	ld	10 (ix),a
	ld	a,-8 (ix)
	ld	11 (ix),a
	ld	a,-9 (ix)
	add	a,#0xFE
	ld	-9 (ix),a
	ld	a,-8 (ix)
	adc	a,#0xFF
	ld	-8 (ix),a
	ld	a,-9 (ix)
	ld	-9 (ix),a
	ld	a,-8 (ix)
	ld	-8 (ix),a
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	ld	a,(hl)
	ld	-9 (ix),a
	inc	hl
	ld	a,(hl)
	ld	-8 (ix),a
	ld	a,-9 (ix)
	ld	-9 (ix),a
	ld	a,-8 (ix)
	ld	-8 (ix), a
	rla
	sbc	a, a
	ld	-7 (ix),a
	ld	-6 (ix),a
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ld	bc, #0x0004
	ldir
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:544: if (!signed_argument)
	bit	0,-27 (ix)
	jr	NZ,00170$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:546: value.l &= 0xFFFF;
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	-7 (ix),#0x00
	ld	-6 (ix),#0x00
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ld	bc, #0x0004
	ldir
00170$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:550: if ( signed_argument )
	bit	0,-27 (ix)
	jr	Z,00175$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:552: if (value.l < 0)
	ld	hl,#0x0011
	add	hl,sp
	ld	-13 (ix),l
	ld	-12 (ix),h
	ex	de,hl
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	bit	7, -6 (ix)
	jr	Z,00172$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:553: value.l = -value.l;
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	xor	a, a
	sub	a, -9 (ix)
	ld	-9 (ix),a
	ld	a, #0x00
	sbc	a, -8 (ix)
	ld	-8 (ix),a
	ld	a, #0x00
	sbc	a, -7 (ix)
	ld	-7 (ix),a
	ld	a, #0x00
	sbc	a, -6 (ix)
	ld	-6 (ix),a
	ld	e,-13 (ix)
	ld	d,-12 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ld	bc, #0x0004
	ldir
	jr	00175$
00172$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:555: signed_argument = 0;
	ld	-27 (ix),#0x00
00175$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:559: lsd = 1;
	ld	-40 (ix),#0x01
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:561: do {
	ld	a,-53 (ix)
	ld	-13 (ix),a
	ld	a,-52 (ix)
	ld	-12 (ix),a
	ld	-44 (ix),#0x00
00179$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:562: value.byte[4] = 0;
	ld	hl,#0x0015
	add	hl,sp
	ld	-9 (ix),l
	ld	-8 (ix),h
	ld	l,-9 (ix)
	ld	h,-8 (ix)
	ld	(hl),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:563: calculate_digit(&value, radix);
	ld	e,-25 (ix)
	ld	d,-24 (ix)
	ld	a,-41 (ix)
	push	af
	inc	sp
	push	de
	call	_calculate_digit
	pop	af
	inc	sp
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:564: if (!lsd)
	bit	0,-40 (ix)
	jr	NZ,00177$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:566: *pstore = (value.byte[4] << 4) | (value.byte[4] >> 4) | *pstore;
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	a,(hl)
	ld	-9 (ix), a
	rlca
	rlca
	rlca
	rlca
	and	a,#0xF0
	ld	-9 (ix),a
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	a,(hl)
	ld	-5 (ix), a
	rlca
	rlca
	rlca
	rlca
	and	a,#0x0F
	ld	-5 (ix),a
	ld	a,-9 (ix)
	or	a, -5 (ix)
	ld	-9 (ix),a
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	ld	a,(hl)
	or	a, -9 (ix)
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	ld	(hl),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:567: pstore--;
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	dec	hl
	ld	-13 (ix),l
	ld	-12 (ix),h
	jr	00178$
00177$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:571: *pstore = value.byte[4];
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	a,(hl)
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	ld	(hl),a
00178$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:573: length++;
	inc	-44 (ix)
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:574: lsd = !lsd;
	ld	a,-40 (ix)
	xor	a, #0x01
	ld	-40 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:575: } while( value.ul );
	ld	e,-25 (ix)
	ld	d,-24 (ix)
	ld	hl, #0x002C
	add	hl, sp
	ex	de, hl
	ld	bc, #0x0004
	ldir
	ld	a,-6 (ix)
	or	a, -7 (ix)
	or	a, -8 (ix)
	or	a,-9 (ix)
	jp	NZ,00179$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:577: if (width == 0)
	ld	a,-13 (ix)
	ld	-53 (ix),a
	ld	a,-12 (ix)
	ld	-52 (ix),a
	ld	a,-44 (ix)
	ld	-18 (ix),a
	ld	a,-42 (ix)
	or	a, a
	jr	NZ,00183$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:582: width = 1;
	ld	-42 (ix),#0x01
00183$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:586: if (!zero_padding && !left_justify)
	bit	0,-39 (ix)
	jr	NZ,00188$
	bit	0,-43 (ix)
	jr	NZ,00188$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:588: while ( width > (unsigned char) (length+1) )
	ld	a,-18 (ix)
	inc	a
	ld	-13 (ix),a
	ld	e,-21 (ix)
	ld	d,-20 (ix)
	ld	b,-42 (ix)
00184$:
	ld	a,-13 (ix)
	sub	a, b
	jr	NC,00311$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:590: OUTPUT_CHAR( ' ', p );
	push	bc
	push	de
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	pop	bc
	inc	de
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:591: width--;
	dec	b
	jr	00184$
00311$:
	ld	-21 (ix),e
	ld	-20 (ix),d
	ld	-42 (ix),b
00188$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:595: if (signed_argument) // this now means the original value was negative
	bit	0,-27 (ix)
	jr	Z,00198$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:597: OUTPUT_CHAR( '-', p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x2D
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00502$
	inc	-20 (ix)
00502$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:599: width--;
	dec	-42 (ix)
	jr	00199$
00198$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:601: else if (length != 0)
	ld	a,-18 (ix)
	or	a, a
	jr	Z,00199$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:604: if (prefix_sign)
	bit	0,-37 (ix)
	jr	Z,00193$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:606: OUTPUT_CHAR( '+', p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x2B
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00503$
	inc	-20 (ix)
00503$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:608: width--;
	dec	-42 (ix)
	jr	00199$
00193$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:610: else if (prefix_space)
	bit	0,-26 (ix)
	jr	Z,00199$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:612: OUTPUT_CHAR( ' ', p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jr	NZ,00504$
	inc	-20 (ix)
00504$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:614: width--;
	dec	-42 (ix)
00199$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:619: if (!left_justify)
	bit	0,-43 (ix)
	jr	NZ,00207$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:621: while ( width-- > length )
	ld	a,-21 (ix)
	ld	-13 (ix),a
	ld	a,-20 (ix)
	ld	-12 (ix),a
	ld	a,-42 (ix)
	ld	-9 (ix),a
00200$:
	ld	h,-9 (ix)
	dec	-9 (ix)
	ld	a,-18 (ix)
	sub	a, h
	jr	NC,00312$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:623: OUTPUT_CHAR( zero_padding ? '0' : ' ', p );
	bit	0,-39 (ix)
	jr	Z,00233$
	ld	-5 (ix),#0x30
	jr	00234$
00233$:
	ld	-5 (ix),#0x20
00234$:
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-5 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-13 (ix)
	jr	NZ,00200$
	inc	-12 (ix)
	jr	00200$
00207$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:629: if (width > length)
	ld	a,-18 (ix)
	sub	a, -42 (ix)
	jr	NC,00204$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:630: width -= length;
	ld	a,-42 (ix)
	sub	a, -18 (ix)
	ld	-42 (ix),a
	jr	00304$
00204$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:632: width = 0;
	ld	-42 (ix),#0x00
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:667: return charsOutputted;
	jr	00304$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:636: while( length-- )
00312$:
	ld	a,-13 (ix)
	ld	-21 (ix),a
	ld	a,-12 (ix)
	ld	-20 (ix),a
	ld	a,-9 (ix)
	ld	-42 (ix),a
00304$:
	ld	a,-53 (ix)
	ld	-13 (ix),a
	ld	a,-52 (ix)
	ld	-12 (ix),a
	ld	a,-21 (ix)
	ld	-9 (ix),a
	ld	a,-20 (ix)
	ld	-8 (ix),a
	ld	a,-18 (ix)
	ld	-5 (ix),a
00212$:
	ld	h,-5 (ix)
	dec	-5 (ix)
	ld	a,h
	or	a, a
	jr	Z,00313$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:638: lsd = !lsd;
	ld	a,-40 (ix)
	xor	a, #0x01
	ld	-40 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:639: if (!lsd)
	bit	0,-40 (ix)
	jr	NZ,00210$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:641: pstore++;
	inc	-13 (ix)
	jr	NZ,00506$
	inc	-12 (ix)
00506$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:642: value.byte[4] = *pstore >> 4;
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	ld	a,(hl)
	rlca
	rlca
	rlca
	rlca
	and	a,#0x0F
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	(hl),a
	jr	00211$
00210$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:646: value.byte[4] = *pstore & 0x0F;
	ld	l,-13 (ix)
	ld	h,-12 (ix)
	ld	a,(hl)
	and	a, #0x0F
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	(hl),a
00211$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:648: output_digit( value.byte[4], lower_case, output_char, p );
	ld	l,-15 (ix)
	ld	h,-14 (ix)
	ld	d,(hl)
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	l,4 (ix)
	ld	h,5 (ix)
	push	hl
	ld	a,-31 (ix)
	push	af
	inc	sp
	push	de
	inc	sp
	call	_output_digit
	ld	hl,#6
	add	hl,sp
	ld	sp,hl
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:649: charsOutputted++;
	inc	-9 (ix)
	jr	NZ,00212$
	inc	-8 (ix)
	jr	00212$
00313$:
	ld	a,-9 (ix)
	ld	-21 (ix),a
	ld	a,-8 (ix)
	ld	-20 (ix),a
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:651: if (left_justify)
	bit	0,-43 (ix)
	jp	Z,00228$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:653: while (width-- > 0)
	ld	e,-9 (ix)
	ld	d,-8 (ix)
	ld	b,-42 (ix)
00215$:
	ld	h,b
	dec	b
	ld	a,h
	or	a, a
	jp	Z,00228$
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:655: OUTPUT_CHAR(' ', p);
	push	bc
	push	de
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,#0x20
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	pop	de
	pop	bc
	inc	de
	ld	-21 (ix),e
	ld	-20 (ix),d
	jr	00215$
00226$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:663: OUTPUT_CHAR( c, p );
	ld	l,6 (ix)
	ld	h,7 (ix)
	push	hl
	ld	a,-45 (ix)
	push	af
	inc	sp
	ld	l,4 (ix)
	ld	h,5 (ix)
	call	__sdcc_call_hl
	pop	af
	inc	sp
	inc	-21 (ix)
	jp	NZ,00228$
	inc	-20 (ix)
	jp	00228$
00230$:
;/pub/Develop/Projects/zasm-4.0/Test/SDCC/library/__print_format.c:667: return charsOutputted;
	ld	l,-21 (ix)
	ld	h,-20 (ix)
	ld	sp, ix
	pop	ix
	ret
__print_format_end::
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
