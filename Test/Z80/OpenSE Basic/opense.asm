#!/usr/local/bin/zasm --dotnames --reqcolon -o ../original/

; The Legalese OpenSE BASIC Disassembly
; Copyright (c) 2011-2012 Andrew Owen 
; Distributed under the CC BY-SA 3.0 license
; Creative Commons Attribution-ShareAlike 3.0 Unported


; Foreword

; Development of OpenSE BASIC was funded by donations to the Red Cross Japan
; Tsunami Appeal (http://www.pledgebank.com/opense). 


; Legal

; The purpose of a commented disassembly is typically as an aid to
; understanding the code.  That is not the purpose of this document. Meaningful
; labels are used throughout and individuals requiring further explanation will
; find an excellent disassembly in Logan and O'Hara's 'The Complete Timex
; TS1000 / Sinclair ZX81 ROM Disassembly', from which the labels used in this
; document are taken (for easy cross-referencing).  This document is provided
; as evidence to support the contention that OpenSE BASIC is a derivative work
; of the ZX81 ROM by Grant and Vickers that may be distributed under an open
; source license without infringing the rights of British Sky Broadcasting
; Group plc, the copyright holder of the ZX Spectrum ROM.


; OpenSE BASIC - An open source firmware for Timex 2000/ZX Spectrum clones
; Copyright (c) 1981 Nine Tiles Networks Ltd

; This program is free software: you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation, either version 2 of the License, or (at your option) any later
; version.  This program is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
; more details.

; You should have received a copy of the GNU General Public License along with
; this program.  If not, see <http://www.gnu.org/licenses/>.


; Purpose

; To enable the legal distribution of 8-bit computers capable of running
; software written for the ZX Spectrum without infringing the rights of British
; Sky Broadcasting Group plc, the copyright holder of the ZX Spectrum ROM.


; Method

; With the ZX81 ROM as the starting point, routines were taken from the ZX80,
; skeleton ROM (from The Messenger), SAM Coupe, and original code from SE Basic
; to replace the missing routines from the ZX Spectrum ROM.  To fill the
; remaining gaps, machine reverse engineering was used to generate functionally
; equivalent but different code, as permitted under the interoperability clause
; in section 50B of the UK Copyright (Computer Programs) Regulations 1992
; amendment to the UK Copyright, Designs and Patents Act 1988.


; Attribution

; The following labels in comments donate the origin of the code that follows
; them: zx80, zx81, sam, skel, se. All other code is legally reverse engineered
; in accordance with section 50B of the 1992 act.


; Acknowledgements

; Jarek Adamski, Alvin Albrecht, Richard Altwasser, Toni Baker, Steve Berry,
; Mark Boyd, Jeff Braine, Martin Brennan, Ian Collier, Rob Collins,
; Chris Cowley, Andrew Cummins, Rick Dickinson, Paul Dunn, John Elliott,
; Paul Farrow, Lou Galie, Simon Goodwin, Rupert Goodwins, Bruce Gordon,
; John Grant, Jim Grimwood, Henk de Groot, Frank O'Hara, Paul Harrison,
; Jonathan Graham Harston, Martijn van der Heide, Pete Hope, Miguel Jodar,
; Dilwyn Jones, Zeljko Juric, Susan Kare, Stephen Kelly, Richard Kelsh,
; Philip Kendall, Slavomir Labsky, Jiri Lamac, Cliff Lawson, Ian Logan,
; Gerton Lunter, Kevin Males, Markos Masouras, Alan Miles, Simon Owen,
; Milan Pikula, Andrew Ryals, Jose Sanchez, Einar Saukas, Clive Sinclair,
; Chris Smith, Dylan Smith, Tony Stratton, Steve Vickers, Geoff Wearmouth,
; Matt Westcott, Jim Westwood, Matthew Wilson, Gunter Woijk, Mark Woodmass,
; Martin Wren-Hilton, Andy Wright, Chris Young, Vladimir Yudin


.section .text

	org 0
	include "opense.def"	

initpal equ 0x0cf7					; code used as palette data

_start:
	di								;
	xor		a						;
	jp		ram_check				; zx81
	nop								; se
	nop								;
									;
l0007:								;
	rst		start					;
			
_error_1:							; zx81
	ld		hl, (chadd)				;
	ld		(xptr), hl				;
	jr		l0013					; se

_print_a:							; zx81
	jp		print_sp				;

l0013:								; se
	ld		(kcur), hl				;
	jr		error_2					; zx81
									;
_get_ch:							;
	ld		hl, (chadd)				;
	ld		a, (hl)					;

test_sp:
	call	l007d
	ret		nc

_next_ch:							; zx81
	call	ch_add_1				;
	jr		test_sp					;

l0025:								; se
	defb	"312"					; version 3.1.2

_fp_calc:							; zx81
	jp		calculate				;

l002b:								; se
	defb	"SE"					; Test this location to check if
									; SE BASIC is present
									;
bc_spaces1:							;
	ld		bc, 1					;

_bc_spaces:							; zx81
	push	bc						;
	ld		hl, (worksp)			; was eline
	push	hl						;
	jp		reserve					;

_interrupt:
	push	hl
	push	af
	ld		hl, frames				; se
	inc		(hl)					;
	jr		nz, anyi				;
	inc		l						;
	inc		(hl)					;
	jr		nz, anyi				;
	inc		l						;
	inc		(hl)					;

anyi:
	push	de
	push	bc
	call	l02bf
	pop		bc
	pop		de						; sam
	pop		af						;
	pop		hl						;
	ei								;
	ret								;

l0051:								; se
	defb	"JG"					;

error_2:							; zx81
	pop		hl						;
	ld		l, (hl)					;
									;
error_3:							;
	ld		(iy + _errnr), l		;
	ld		sp, (errsp)				;
	jp		set_mem

l005f:								; se
	set		0, (iy + _flags)		;
	jp		l0daf					;

nmi:								; sam
	push	af						;
	push	hl						;
	ld		hl, (nmiadd)			;
	ld		a, h					;
	or		l						;
	jr		z, nmi_ret				; se
	jp		(hl)

nmi_ret:							; sam
	pop		hl						;
	pop		af						;
	retn							;

ch_add_1:							; zx81
	ld		hl, (chadd)				;
									;
cursor_so:							;
	inc		hl						;
									;
temp_ptr:							;
	ld		(chadd), hl				;
	ld		a, (hl)					;
	ret

l007d:								; se
	cp		' '						;
	scf								;
	ret		z						;
	cp		24						;
	ret		nc						;
	cp		ctrl_n_l				;
	ret		z						;
	cp		6						;
	ccf								;
	ret		nc						;
	cp		ctrl_pen				;
	ret		c						;
	inc		hl						;
	cp		ctrl_at					;
	jr		c, l0094				;
	inc		hl						;
									;
l0094:								;
	scf								;
	ld		(chadd), hl				;
	ret								;
									;
l0099:								;
	ld		a, (hl)					;
	cp		0x0d					;
	ret		z						;
	call	l100e					;
	cp		0x15					;
	ret		nc						;
	cp		0x10					;
	jp		nc, l100e				;
	ret								;

k_token:							; zx81, sam, se
	incbin		"data/tokens.txt"		;

k_unshifted:						; sam
	incbin		"data/unshifted.txt"		;

k_shifted:
	defb	ctrl_rubout, ctrl_edit, ctrl_caps, ctrl_true_vid
	defb	ctrl_inv_vid, ctrl_left, ctrl_down, ctrl_up, ctrl_right
	defb	ctrl_graphics

k_function:							; se
	incbin		"data/alphasym.txt"		;
									;
k_graphic:							;
	incbin		"data/numsym.txt"		;

keyboard:							; se
	ld		l, 47					;
	ld		de, 0xffff
	ld		bc, 0xfefe				; zx81
									;
l0296:								;
	in		a, (c)					;
	cpl
	and		%00011111
	jr		z, l02ab
	ld		h, a
	ld		a, l						

l029f:
	inc		d
	ret		nz

l02a1:
	sub		8
	srl		h
	jr		nc, l02a1
	ld		d, e
	ld		e, a
	jr		nz, l029f

l02ab:
	dec		l
	rlc		b
	jr		c, l0296
	ld		a, d
	inc		a
	ret		z
	cp		40
	ret		z
	cp		25
	ret		z
	ld		a, e
	ld		e, d
	ld		d, a
	cp		24
	ret

l02bf:
	call	keyboard
	ret		nz
	ld		hl, kstate

l02c6:
	bit		7, (hl)
	jr		nz, l02d1
	inc		hl
	dec		(hl)
	dec		hl
	jr		nz, l02d1
	ld		(hl), 255

l02d1:
	ld		a, l
	ld		hl, kstate_4
	cp		l
	jr		nz, l02c6
	call	l031e
	ret		nc
	ld		hl, kstate
	cp		(hl)
	jr		z, l0310
	ex		de, hl
	ld		hl, kstate_4
	cp		(hl)
	jr		z, l0310
	bit		7, (hl)
	jr		nz, l02f1
	ex		de, hl
	bit		7, (hl)
	ret		z

l02f1:
	ld		(hl), a
	ld		e, a
	inc		hl
	ld		(hl), 5
	ld		a, (repdel)
	inc		hl
	ld		(hl), a
	inc		hl
	ld		d, (iy + _flags)
	ld		c, (iy + _mode)
	push	hl
	call	l0333
	pop		hl
	ld		(hl), a

l0308:
	set		5, (iy + _flags)
	ld		(lastk), a
	ret

l0310:
	inc		hl
	ld		(hl), 5
	inc		hl
	dec		(hl)
	ret		nz
	ld		a, (repper)
	ld		(hl), a
	inc		hl
	ld		a, (hl)
	jr		l0308

l031e:
	ld		b, d
	ld		a, e
	ld		d, 0
	cp		39
	ret		nc
	cp		24
	jr		nz, l032c
	bit		7, b
	ret		nz

l032c:
	ld		hl, k_unshifted
	add		hl, de
	scf
	ld		a, (hl)
	ret

l0333:
	ld		a, e
	cp		':'
	jr		c, l035f
	dec		c
	jp		m, l034b
	jr		z, l034b				; se
	add		a, 79					;
	cp		'V' + 0x4f				;
	ret		c						;
	add		a, 13					;
	call	add_char				;
	ld		a, ctrl_graphics		;
	ret								;

l034b:
	ld		hl, k_function - 'A'
	bit		0, b
	jr		z, l03a1
	bit		3, (iy + _klflag)
	jr		z, l035a				; se
	xor		%00100000				;

l035a:
	inc		b
	ret		nz
	xor		%00100000				; se
	ret								;

l035f:
	cp		'0'
	ret		c
	dec		c
	jp		m, l0395
	jr		nz, l0381
	ld		hl, k_graphic - '0'
	bit		5, b
	jr		z, l03a1
	cp		'8'
	jr		nc, l037a
	sub		32
	inc		b
	ret		z
	add		a, 8
	ret

l037a:
	sub		54
	inc		b
	ret		z
	add		a, 254
	ret

l0381:
	ld		hl, k_shifted - '0'
	cp		'9'
	jr		z, l03a1
	cp		'0'
	jr		z, l03a1
	and		%00000111
	add		a, 0x80
	inc		b
	ret		z
	xor		15
	ret

l0395:
	inc		b
	ret		z
	bit		5, b
	ld		hl, k_shifted - '0'
	jr		nz, l03a1
	ld		hl, k_graphic - '0'

l03a1:
	ld		d, 0
	add		hl, de
	ld		a, (hl)
	ret
	defb	0xff					; se
									;
ram_check:							;
	ld		de, 0xffff				;
	ld		(de), a					;
	ld		a, (de)					;
	and		a						;
	jr		z, l03b2				;
	xor		a						;
	ld		d, 0x7f					;
									;
l03b2:								;
	jp		l11cf					;

l03b5:								; skel
	di								;
	ld		a, l					;
	srl		l						;
	srl		l						;
	cpl								;
	and		%00000011				;
	ld		b, 0					;
	ld		c, a					;
	ld		ix, l03d1				;
	add		ix, bc					;
	ld		a, (bordcr)				;
	and		%00111000				;
	rrca							;
	rrca							;
	rrca							;
	or		%00001000				;
									;
l03d1:								;
	nop								;
	nop								;
	nop								;
	inc		c						;
	inc		b						;
									;
l03d6:								;
	dec		c						;
	jr		nz, l03d6				;
	ld		c, 63					;
	dec		b						;
	jp		nz, l03d6				;
	xor		%00010000				;
	out		(ula), a				;
	ld		c, a					;
	ld		b, h					;
	bit		4, a					;
	jr		nz, l03f2				;
	ld		a, d					;
	or		e						;
	jr		z, l03f6				;
	dec		de						;
	ld		a, c					;
	ld		c, l					;
	jp		(ix)					;
									;
l03f2:								;
	ld		c, l					;
	inc		c						;
	jp		(ix)					;
									;
l03f6:								;
	ei								;
	ret								;

l03f8:
	fwait
	fmove
	fint
	fst		0
	fsub
	fstk
	defb	0xec, 0x6c, 0x98, 0x1f, 0xf5
	fmul
	fstk1
	fadd
	fce
	ld		hl, membot
	ld		a, (hl)
	and		a
	jr		nz, ioorerr
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	ld		a, b
	rla
	sbc		a, a
	cp		c
	jr		nz, ioorerr
	inc		hl
	cp		(hl)
	jr		nz, ioorerr
	ld		a, 60
	add		a, b
	jp		p, l0425
	jp		po, ioorerr

l0425:
	ld		b, 250

l0427:
	sub		12
	inc		b
	jr		nc, l0427
	ld		hl, l046e
	push	bc
	add		a, 12
	call	loc_mem
	call	l33b8
	fwait
	fmul
	fce
	pop		af
	add		a, (hl)
	ld		(hl), a
	fwait
	fst		0
	fdel
	fmove
	fce
	call	getbyte
	cp		11
	jr		nc, ioorerr
	fwait
	fgt		0
	fmul
	fgt		0
	fstk
	defb	0x80, 0x43, 0x55, 0x9f, 0x80
	fxch
	fdiv
	fstk
	defb	0x35, 0x6c
	fsub
	fce
	call	find_int
	push	bc
	call	find_int
	pop		hl
	ld		e, c
	ld		d, b
	ld		a, e
	or		d
	ret		z
	dec		de
	jp		l03b5

ioorerr:							; sam
	rst		error_1					;
	defb	Integer_out_of_range	;

l046e:
	incbin		"data/semitone.data"

l04aa:								; se
	ld		a, (de)					;
	and		%01111111				;
	cp		' '						;
	ret		nc						;
	cp		ctrl_n_l				;
	ret		z						;
	cp		ctrl_left				;
	ret		z						;
	add		a, 223					;
	ret								;
									;
l04b9:								;
	call	syntax_z				;
	ret		z						;
	bit		7, (hl)					;
	ret		nz						;
	rst		error_1					;
	defb	Syntax_error			;

l04c2:								; skel
	ld		hl, l053f				;
	push	hl						;
	bit		7, a					;
	ld		hl, 0x1f80				;
	jr		z, l04d0				;
	ld		hl, 0x0c98				;
									;
l04d0:								;
	di								;
	ex		af, af'					;'
	ld		a, red					;
	dec		ix						;
	inc		de						;
	ld		b, a					;
									;
l04d8:								;
	djnz	l04d8					;
	out		(ula), a				;
	ld		b, 164					;
	xor		%00001111				;
	dec		l						;
	jr		nz, l04d8				;
	dec		b						;
	dec		h						;
	jp		p, l04d8				;
	ld		b, 47					;
									;
l04ea:								;
	djnz	l04ea					;
	out		(ula), a				;
	ld		b, 55					;
	ld		a, 13					;
									;
l04f2:								;
	djnz	l04f2					;
	out		(ula), a				;
	ex		af, af'					;'
	ld		l, a					;
	ld		bc, 0x3b0e				;
	jp		l0507					;
									;
l04fe:								;
	ld		a, e					;
	or		d						;
	jr		z, l050e				;
	ld		l, (ix + 0x00)			;
									;
l0505:								;
	ld		a, h					;
	xor		l						;
									;
l0507:								;
	ld		h, a					;
	scf								;
	ld		a, blue					;
	jp		l0525					;
									;
l050e:								;
	ld		l, h					;
	jr		l0505					;
									;
l0511:								;
	ld		a, c					;
	bit		7, b					;
									;
l0514:								;
	djnz	l0514					;
	jr		nc, l051c				;
	ld		b, 66					;
									;
l051a:								;
	djnz	l051a					;
									;
l051c:								;
	out		(ula), a				;
	ld		b, 62					;
	jr		nz, l0511				;
	xor		a						;
	dec		b						;
	inc		a						;
									;
l0525:								;
	rl		l						;
	jp		nz, l0514				;
	ld		b, 49					;
	inc		ix						;
	dec		de						;
	ld		a, 127					;
	in		a, (ula)				;
	rra								;
	ret		nc						;
	ld		a, d					;
	inc		a						;
	jp		nz, l04fe				;
	ld		b, 59					;
									;
l053c:								;
	djnz	l053c					;
	ret								;
									;
l053f:								;
	push	af						;
	ld		a, (bordcr)				;
	and		%00111000				;
	rrca							;
	rrca							;
	rrca							;
	out		(ula), a				;
	ld		a, 127					;
	in		a, (ula)				;
	rra								;
	ei								;
	jr		c, l0554				;
	rst		error_1					;
	defb	BREAK_CONTINUE_repeats	;
									;
l0554:								;
	pop		af						;
	ret								;
									;
l0556:								;
	di								;
	inc		d						;
	ex		af, af'					;'
	dec		d						;
	ld		a, 15					;
	out		(ula), a				;
	ld		hl, l053f				;
	push	hl						;
	in		a, (ula)				;
	rra								;
	and		%00100000				;
	or		red						;
	ld		c, a					;
	cp		a						;
									;
l056b:								;
	ret		nz						;
									;
l056c:								;
	call	l05e7					;
	jr		nc, l056b				;
	ld		hl, 0x0115				;
									;
l0574:								;
	djnz	l0574					;
	dec		hl						;
	ld		a, l					;
	or		h						;
	jr		nz, l0574				;
	call	l05e3					;
	jr		nc, l056b				;
									;
l0580:								;
	ld		b, 156					;
	call	l05e3					;
	jr		nc, l056b				;
	ld		a, 198					;
	cp		b						;
	jr		nc, l056c				;
	inc		h						;
	jr		nz, l0580				;
									;
l058f:								;
	ld		b, 201					;
	call	l05e7					;
	jr		nc, l056b				;
	ld		a, b					;
	cp		212						;
	jr		nc, l058f				;
	call	l05e7					;
	ret		nc						;
	ld		a, c					;
	xor		%00000011				;
	ld		c, a					;
	ld		h, 0					;
	ld		b, 176					;
	jr		l05c8					;
									;
l05a9:								;
	ex		af, af'					;'
	jr		nz, l05b3				;
	jr		nc, l05bd				;
	ld		(ix + 0x00), l			;
	jr		l05c2					;
									;
l05b3:								;
	rl		c						;
	xor		l						;
	ret		nz						;
	ld		a, c					;
	rra								;
	ld		c, a					;
	jp		l05c5					; se
									;
l05bd:								; skel
	ld		a, (ix + 0x00)			;
	xor		l						;
	ret		nz						;
									;
l05c2:								;
	inc		ix						;
									;
l05c4:								;
	dec		de						;
									;
l05c5:								;
	ex		af, af'					;'
	ld		b, 178					;
									;
l05c8:								;
	ld		l, %00000001			;
									;
l05ca:								;
	call	l05e3					;
	ret		nc						;
	ld		a, 203					;
	cp		b						;
	rl		l						;
	ld		b, 176					;
	jp		nc, l05ca				;
	ld		a, h					;
	xor		l						;
	ld		h, a					;
	ld		a, d					;
	or		e						;
	jr		nz, l05a9 				;
	ld		a, h					;
	cp		1						;
	ret								;
									;
l05e3:								;
	call	l05e7					;
	ret		nc						;
									;
l05e7:								;
	ld		a, 22					;
									;
l05e9:								;
	dec		a						;
	jr		nz, l05e9				;
	and		a						;
									;
l05ed:								;
	inc		b						;
	ret		z						;
	ld		a, 127					;
	in		a, (ula)				;
	rra								;
	ret		nc						;
	xor		c						;
	and		%00100000				;
	jr		z, l05ed				;
	ld		a, c					;
	cpl								;
	ld		c, a					;
	and		%00000111				;
	or		%00001000				;
	out		(ula), a				;
	scf								;
	ret								;

l0605:
	pop		af
	ld		a, (taddr)
;		sub		p_save + 1 % 256 	; not supported by binutils
	sub		0x0e
	ld		(taddr), a
	call	class_a
	call	syntax_z
	jr		z, l0652
	ld		a, (taddr)
	ld		bc, 0x0011
	and		a
	jr		z, l0621
	ld		c, 34

l0621:
	rst		bc_spaces
	push	de
	pop		ix
	ld		a, ' '
	ld		b, 11

l0629:
	ld		(de), a
	inc		de
	djnz	l0629
	ld		(ix + 0x01), 255
	call	stk_fetch
	dec		bc
	ld		hl, 0xfff6
	add		hl, bc
	inc		bc
	jr		nc, l064b
	ld		a, (taddr)
	and		a
	jr		nz, l0644
	rst		error_1
	defb	Bad_filename

l0644:
	ld		a, c
	or		b
	jr		z, l0652
	ld		bc, 10

l064b:
	push	ix
	pop		hl
	ex		de, hl
	inc		de
	ldir

l0652:
	rst		get_ch
	cp		tkdata
	jr		nz, l06a0
	ld		a, (taddr)
	cp		3
	jp		z, report_c
	rst		next_ch
	call	look_vars
	set		7, c
	jr		nc, l0672
	ld		a, (taddr)
	dec		a
	ld		hl, 0
	jr		z, l0685

l0670:
	rst		error_1
	defb	Undefined_variable

l0672:
	jp		nz, report_c
	call	l04b9
	jr		z, l0692
	inc		hl
	ld		a, (hl)
	ld		(ix + 0x0b), a
	inc		hl
	ld		a, (hl)
	ld		(ix + 0x0c), a
	inc		hl

l0685:
	ld		a, 1
	ld		(ix + 0x0e), c
	bit		6, c
	jr		z, l068f
	inc		a

l068f:
	ld		(ix + 0x00), a

l0692:
	ex		de, hl
	rst		next_ch
	cp		')'
	jr		nz, l0672
	rst		next_ch
	call	check_end
	ex		de, hl
	jp		l075a

l06a0:
	cp		tk_screen_str
	jr		nz, l06c3
	ld		a, (taddr)
	cp		3
	jp		z, report_c
	rst		next_ch
	call	check_end
	ld		hl, bitmap
	ld		(ix + 0x0b), 0
	ld		(ix + 0x0c), 27
	ld		(ix + 0x0d), l
	ld		(ix + 0x0e), h
	jr		l0710

l06c3:
	cp		tk_code
	jr		nz, l0716
	ld		a, (taddr)
	cp		3
	jp		z, report_c
	rst		next_ch
	call	l2048
	jr		nz, l06e1
	ld		a, (taddr)
	and		a
	jp		z, report_c
	call	no_to_stk
	jr		l06f0

l06e1:
	call	class_6
	rst		get_ch
	cp		','
	jr		z, l06f5
	ld		a, (taddr)
	and		a
	jp		z, report_c

l06f0:
	call	no_to_stk
	jr		l06f9

l06f5:
	rst		next_ch
	call	class_6

l06f9:
	call	check_end
	call	find_int
	ld		(ix + 0x0c), b
	ld		(ix + 0x0b), c
	call	find_int
	ld		h, b
	ld		(ix + 0x0e), h
	ld		l, c
	ld		(ix + 0x0d), l

l0710:
	ld		(ix + 0x00), 3
	jr		l075a

l0716:
	cp		tk_line
	jr		z, l0723
	call	check_end
	ld		(ix + 0x0e), 0x80
	jr		l073a

l0723:
	ld		a, (taddr)
	and		a
	jp		nz, report_c
	rst		next_ch
	call	class_6
	call	check_end
	call	syntax3
	ld		(ix + 0x0e), b
	ld		(ix + 0x0d), c

l073a:
	ld		de, (prog)
	ld		hl, (eline)
	ld		(ix + 0x00), 0
	scf
	sbc		hl, de
	ld		(ix + 0x0c), h
	ld		(ix + 0x0b), l
	ld		hl, (vars)
	sbc		hl, de
	ld		(ix + 0x10), h
	ld		(ix + 0x0f), l
	ex		de, hl

l075a:
	ld		a, (taddr)
	and		a
	jp		z, l0970
	push	hl
	ld		bc, 0x0011
	add		ix, bc

l0767:
	xor		a
	push	ix
	ld		de, 0x0011
	scf
	call	l0556
	pop		ix
	jr		nc, l0767
	ld		a, 254
	call	l1601
	ld		a, (ix + 0x00)
	ld		(iy + _scrct), 255
	ld		c, 0x80
	cp		(ix - 0x11)
	jr		nz, l078a
	ld		c, 246

l078a:
	cp		4
	jr		nc, l0767
	ld		de, l13d5 - 1
	push	bc
	call	l0c0a
	pop		bc
	push	ix
	pop		de
	ld		hl, 0xfff0
	add		hl, de
	ld		a, (hl)
	ld		b, 10
	inc		a
	jr		nz, l07a6
	ld		a, c
	add		a, b
	ld		c, a

l07a6:
	inc		de
	ld		a, (de)
	cp		(hl)
	inc		hl
	jr		nz, l07ad
	inc		c

l07ad:
	rst		print_a
	djnz	l07a6
	bit		7, c
	jr		nz, l0767
	ld		a, ctrl_n_l
	rst		print_a
	pop		hl
	ld		a, (ix + 0x00)
	cp		3
	jr		z, l07cb
	ld		a, (taddr)
	dec		a
	jp		z, l0808
	cp		2
	jp		z, l08b6

l07cb:
	push	hl
	ld		h, (ix - 0x05)
	ld		l, (ix - 0x06)
	ld		d, (ix + 0x0c)
	ld		e, (ix + 0x0b)
	ld		a, l
	or		h
	jr		z, l07e9
	sbc		hl, de
	jr		c, terror
	jr		z, l07e9
	ld		a, (ix + 0x00)
	cp		3
	jr		nz, terror

l07e9:
	pop		hl
	ld		a, l
	or		h
	jr		nz, l07f4
	ld		h, (ix + 0x0e)
	ld		l, (ix + 0x0d)

l07f4:
	push	hl
	pop		ix
	ld		a, (taddr)
	cp		2
	scf
	jr		nz, l0800
	and		a

l0800:
	ld		a, 255

l0802:
	call	l0556
	ret		c						; skel
									;
terror:								;
	rst		error_1					;
	defb	Loading_error			;

l0808:
	ld		d, (ix + 0x0c)
	ld		e, (ix + 0x0b)
	push	hl
	ld		a, l
	or		h
	jr		nz, l0819
	inc		de
	inc		de
	inc		de
	ex		de, hl
	jr		l0825

l0819:
	ld		h, (ix - 0x05)
	ld		l, (ix - 0x06)
	ex		de, hl
	scf
	sbc		hl, de
	jr		c, l082e

l0825:
	ld		de, 5
	add		hl, de
	ld		c, l
	ld		b, h
	call	test_room

l082e:
	pop		hl
	ld		a, (ix + 0x00)
	and		a
	jr		z, l0873
	ld		a, l
	or		h
	jr		z, l084c
	dec		hl
	ld		b, (hl)
	dec		hl
	ld		c, (hl)
	dec		hl
	inc		bc
	inc		bc
	inc		bc
	ld		(xptr), ix
	call	reclaim_2
	ld		ix, (xptr)

l084c:
	ld		hl, (eline)
	dec		hl
	ld		b, (ix + 0x0c)
	ld		c, (ix + 0x0b)
	push	bc
	inc		bc
	inc		bc
	inc		bc
	ld		a, (ix - 0x03)
	push	af
	call	make_room
	inc		hl
	pop		af
	ld		(hl), a
	pop		de
	inc		hl
	ld		(hl), e
	inc		hl
	ld		(hl), d
	inc		hl
	push	hl
	pop		ix
	scf
	ld		a, 255
	jp		l0802

l0873:
	ex		de, hl
	ld		hl, (eline)
	dec		hl
	ld		(xptr), ix
	ld		b, (ix + 0x0c)
	ld		c, (ix + 0x0b)
	push	bc
	call	reclaim_1
	pop		bc
	push	hl
	push	bc
	call	make_room
	ld		ix, (xptr)
	inc		hl
	ld		b, (ix + 0x10)
	ld		c, (ix + 0x0f)
	add		hl, bc
	ld		(vars), hl
	ld		h, (ix + 0x0e)
	ld		a, h
	and		%11000000
	jr		nz, l08ad
	ld		l, (ix + 0x0d)
	ld		(newppc), hl
	ld		(iy + _nsppc), 0

l08ad:
	pop		de
	pop		ix
	scf
	ld		a, 255
	jp		l0802

l08b6:
	ld		b, (ix + 0x0c)
	ld		c, (ix + 0x0b)
	push	bc
	inc		bc
	rst		bc_spaces
	ld		(hl), 0x80
	ex		de, hl
	pop		de
	push	hl
	push	hl
	pop		ix
	scf
	ld		a, 255
	call	l0802
	pop		hl
	ld		de, (prog)

l08d2:
	ld		a, (hl)
	and		%11000000
	jr		nz, l08f0

l08d7:
	ld		a, (de)
	inc		de
	cp		(hl)
	inc		hl
	jr		nz, l08df
	ld		a, (de)
	cp		(hl)

l08df:
	dec		hl
	dec		de
	jr		nc, l08eb
	push	hl
	ex		de, hl
	call	next_one
	pop		hl
	jr		l08d7

l08eb:
	call	l092c
	jr		l08d2

l08f0:
	ld		a, (hl)
	ld		c, a
	cp		0x80
	ret		z
	push	hl
	ld		hl, (vars)

l08f9:
	ld		a, (hl)
	cp		0x80
	jr		z, l0923
	cp		c
	jr		z, l0909

l0901:
	push	bc
	call	next_one
	pop		bc
	ex		de, hl
	jr		l08f9

l0909:
	and		%11100000
	cp		%10100000
	jr		nz, l0921
	pop		de
	push	de
	push	hl

l0912:
	inc		de
	ld		a, (de)
	inc		hl
	cp		(hl)
	jr		nz, l091e
	rla
	jr		nc, l0912
	pop		hl
	jr		l0921

l091e:
	pop		hl
	jr		l0901

l0921:
	ld		a, 255

l0923:
	inc		a
	pop		de
	ex		de, hl
	scf
	call	l092c
	jr		l08f0

l092c:
	jr		nz, l093e
	ld		(xptr), hl
	ex		af, af'
	ex		de, hl
	call	next_one
	call	reclaim_2
	ex		af, af'
	ex		de, hl
	ld		hl, (xptr)

l093e:
	push	de
	ex		af, af'
	call	next_one
	ex		af, af'
	ld		(xptr), hl
	ld		hl, (prog)
	ex		(sp), hl
	push	bc
	jr		c, l0955
	dec		hl
	call	make_room
	inc		hl
	jr		l0958

l0955:
	call	make_room

l0958:
	pop		bc
	pop		de
	inc		hl
	ld		(prog), de
	ld		de, (xptr)
	push	bc
	push	de
	ex		de, hl
	ldir
	pop		hl
	pop		bc
	push	de
	call	reclaim_2
	pop		de
	ret

l0970:								; skel
	push	hl						;
	ld		a, 253					;
	call	l1601
	xor		a						; skel
	ld		de, l13b6 - 1			;
	call	l0c0a					;
	set		5, (iy + _dflag)		;
	call	waitkey					;
	push	ix						;
	ld		de, 0x0011				;
	xor		a						;
	call	l04c2					;
	pop		ix						;
	ld		b, 50					;
									;
l0991:								;
	halt							;
	djnz	l0991					;
	ld		e, (ix + 0x0b)			;
	ld		d, (ix + 0x0c)			;
	ld		a, 255					;
	pop		ix						;
	jp		l04c2					;

l09a1:								; se
	rst		get_ch					;
	dec		hl						;
	ld		a, (hl)					;
	cp		tk_erase				;
	jr		nz, l09af				;
	rst		get_ch					;
	call	check_end				;
	jp		l3954					;
									;
l09af:								;
	rst		get_ch					;
	cp		'7'						;
	jr		z, l09bb				;
	cp		'8'						;
	jp		z, l3927				;
	rst		error_1					;
	defb	Syntax_error			;
									;
l09bb:								;
	rst		next_ch					;
	call	check_end				;
	jp		l1f1a					;
									;
l09c2:								;
	rst		next_ch					;
									;
l09c3:								;
	call	class_8					;
	call	syntax_z				;
	jr		z, l09e5				;
	call	fp_to_a					;
	push	af						;
	call	fp_to_a					;
	cp		17						;
	jp		nc, ioorerr				;
	dec		a						;
	inc		a						;
	jp		m, ioorerr				;
	ld		bc, ay_reg				;
	out		(c), a					;
	pop		af						;
	call	l38ce					;
									;
l09e5:								;
	rst		get_ch					;
	cp		';'						;
	jr		z, l09c2				;
	call	check_end				;
	ret								;

setudg:								; se
	ld		hl, 0x3e08				;
	jp		setudg2					;

prmain:								;
	call	l0b03					;
	cp		24						;
	jr		nc, l0a5b				;
	cp		6						;
	jp		c, l0c81				;
	cp		24						;
	jr		nc, l0a59
	ld		d, 0
	ld		e, a
	ld		hl, l0a11 - 6
	add		hl, de
	ld		e, (hl)
	add		hl, de
	push	hl
	jp		l0b03

l0a11:
	defb	l0a52 - $
	defb	l0a59 - $
	defb	l0a23 - $
	defb	l0a37 - $
	defb	l0a59 - $
	defb	l0a59 - $
	defb	l0a59 - $
	defb	l0a49 - $
	defb	l0a59 - $
	defb	l0a59 - $
	defb	l0a6a - $
	defb	l0a6a - $
	defb	l0a6a - $
	defb	l0a6a - $
	defb	l0a6a - $
	defb	l0a6a - $
	defb	l0a65 - $
	defb	l0a65 - $

l0a23:
	inc		c
	ld		a, 34
	cp		c
	jp		nz, l0dd9				; se
	dec		c						;
	ld		a, 24					;
	cp		b						;
	jp		nz, l0dd9				;
	ld		c, 2					;
	inc		b						;
	jp		l0dd9

l0a37:
	ld		a, (pflag)
	push	af
	ld		a, ' '
	ld		(iy + _pflag), 1
	call	l0ad9					; se
	pop		af
	ld		(pflag), a
	ret

l0a49:
	ld		c, 33
	call	l0c55
	dec		b
	jp		l0dd9

l0a52:
	ld		a, c
	dec		a
	dec		a
	and		%00010000
	jr		l0ac3

l0a59:
	ld		a, '?'

l0a5b:
	jr		l0ad9

l0a5d:
	ld		(vdudata_h), a
	ld		de, l0a87
	jr		l0a70

l0a65:
	ld		de, l0a5d
	jr		l0a6d

l0a6a:
	ld		de, l0a87

l0a6d:
	ld		(vdudata), a

l0a70:
	ld		hl, (curchl)
	ld		(hl), e
	inc		hl
	ld		(hl), d
	ret

l0a58:								; se
	call	getbyte					;
	ld		(attrp), a				;
	ret								;
									;
l0a7e:								;
	sbc		hl, bc					;
	add		a, '0' - 1				;
	ld		(de), a					;
	inc		de						;
	ret								;

	defb	"SV"					;

l0a87:
	ld		de, prmain
	call	l0a70
	ld		hl, (vdudata)
	ld		d, a
	ld		a, l
	cp		22
	jp		c, l2211
	jr		nz, l0ac2
	ld		c, d
	ld		b, h
	ld		a, 31
	sub		c
	jr		c, l0aa6
	add		a, 2
	ld		c, a
	ld		a, 22
	sub		b

l0aa6:
	jp		c, report_b1
	inc		a
	ld		b, a
	inc		b
	bit		0, (iy + _dflag)
	jp		nz, l0c55
	cp		(iy + _dfsz)
	jp		c, oserror
	jp		l0dd9

l0abc:								; se
	call	pau2					;
	jp		find_int				;

l0ac2:
	ld		a, h

l0ac3:
	call	l0b03
	add		a, c
	dec		a
	and		%00011111
	ret		z
	set		0, (iy + _flags)
	ld		d, a

l0ad0:
	ld		a, ' '
	call	l0c3b
	dec		d
	jr		nz, l0ad0
	ret

l0ad9:
	call	l391d

l0adc:								; skel
	bit		0, (iy + _dflag)		;
	jr		nz, l0aea				;
	ld		(sposnu), bc			;
	ld		(dfcc), hl				;
	ret								;
									;
l0aea:								;
	ld		(sposnl), bc			;
	ld		(echoe), bc				;
	ld		(dfccl), hl				;
	ret								;

l0af6:								; se
	ld		hl, (eline)				;
	ld		de, (kcur)				;
	and		a						;
	sbc		hl, de					;
	ld		b, 0x20					;
	ret								;

l0b03:
	ld		hl, (dfcc)
	ld		bc, (sposnu)
	bit		0, (iy + _dflag)
	ret		z
	ld		hl, (dfccl)
	ld		bc, (sposnl)
	ret

streamfe:							; sam
	ld		a, 254					;
	jp		l1601					;

copy:								; se
	call	find_int				;
	ld		a, b					;
	or		c 						;
	ret		z						;
	push	bc						;
	ret								;

l0b24:
	cp		0x80
	jr		c, l0b65
	cp		144
	jr		nc, l0b52
	ld		b, a
	call	l0b38
	call	l0b03
	ld		de, membot
	jr		l0b7f

l0b38:
	ld		hl, membot
	call	l0b3e

l0b3e:
	rr		b
	sbc		a, a
	and		%00001111
	ld		c, a
	rr		b
	sbc		a, a
	and		%11110000
	or		c
	ld		c, 4

l0b4c:
	ld		(hl), a
	dec		c
	inc		hl
	jr		nz, l0b4c
	ret

l0b52:
	sub		tk_rnd
	jr		nc, l0b5f
	add		a, 21
	push	bc
	ld		bc, (udg)
	jr		l0b6a

l0b5f:
	call	l0c10
	jp		l0b03

l0b65:
	push	bc
	ld		bc, (chars)

l0b6a:
	ex		de, hl
	ld		hl, flags
	res		0, (hl)
	cp		' '
	jr		nz, l0b76
	set		0, (hl)

l0b76:
	ld		l, a
	ld		h, 0
	add		hl, hl
	add		hl, hl
	add		hl, hl
	add		hl, bc
	ex		de, hl
	pop		bc

l0b7f:
	ld		a, c
	dec		a
	ld		a, 33
	jr		nz, l0b87
	ld		c, a
	dec		b

l0b87:
	cp		c
	push	de
	call	z, l0c55
	pop		de
	push	bc
	push	hl
	ld		a, (pflag)
	ld		b, 255
	rra
	jr		c, l0b98
	inc		b

l0b98:
	rra
	rra
	sbc		a, a
	ld		c, a
	ld		a, 8
	and		a
	ex		de, hl

l0ba0:
	ex		af, af'
	ld		a, (de)
	and		b
	xor		c
	xor		(hl)
	ld		(de), a
	ex		af, af'
	inc		d
	dec		a
	inc		hl
	jr		nz, l0ba0
	ex		de, hl
	dec		h
	call	l0bdb					; se
	pop		hl
	pop		bc
	dec		c
	inc		hl
	ret

l0bb6:								; se
	cp		56						;
	ret		c						;
	rst		error_1					;
	defb	Syntax_error			;
									;
l0bbb:								;
	call	l0bd0					;
	call	next_one				;
	push	de						;
	call	l0bd0					;
	pop		de						;
	and		a						;
	sbc		hl, de					;
	jr		nc, l0bdd9				;
	add		hl, de					;
	ex		de, hl					;
	jp		reclaim_1				;
									;
l0bd0:								;
	call	syntax3					;
	ld		h, b					;
	ld		l, c					;
	call	line_addr				;
	ret		z						;
									;
l0bdd9:								;
	rst		error_1					;
	defb	Bad_argument			;

l0bdb:								; skel
	ld		a, h					;
	rrca							;
	rrca							;
	rrca							;
	and		%00000011				;
	or		%01011000				;
	ld		h, a					;
	ld		de, (attrt)				;
	ld		a, (hl)					;
	xor		e						;
	and		d						;
	xor		e						;
	bit		6, (iy + _pflag)		;
	jr		z, l0bfa				;
	and		%11000111				;
	bit		2, a					;
	jr		nz, l0bfa				;
	xor		%00111000				;
									;
l0bfa:								;
	bit		4, (iy + _pflag)		;
	jr		z, l0c08				;
	and		%11111000				;
	bit		5, a					;
	jr		nz, l0c08				;
	xor		%00000111				;
									;
l0c08:								;
	ld		(hl), a					;
	ret								;
									;
l0c0a:								;
	push	hl						;
	ld		h, 0					;
	ex		(sp), hl				;
	jr		l0c14					;
									;
l0c10:								;
	ld		de, k_token - 1			;
	push	af						;
									;
l0c14:								;
	call	l0c41					;
	jr		c, l0c22				;
	ld		a, ' '					;
	bit		0, (iy + _flags)		;
	call	z, l0c3b				;

l0c22:								; se
	call	l04aa					;
	call	l0c3b					; skel
	ld		a, (de)					;
	inc		de						;
	add		a, a					;
	jr		nc, l0c22				;
	pop		de						;
	cp		72						;
	jr		z, l0c35				;
	cp		130						;
	ret		c						;
									;
l0c35:								;
	ld		a, d					;
	cp		3						;
	ret		c						;
	ld		a, ' '					;
									;
l0c3b:								;
	push	de						;
	exx								;
	rst		print_a					;
	exx								;
	pop		de						;
	ret								;
									;
l0c41:								;
	push	af						;
	ex		de, hl					;
	inc		a						;

words:								; zx81
	bit		7, (hl)					;
	inc		hl						;
	jr		z, words				;
	dec		a						; skel
	jr		nz, words				;
	ex		de, hl					;
	pop		af						;
	cp		' '						;
	ret		c						;
	ld		a, (de)					;
	sub		'A'						;
	ret								;

l0c55:
	ld		de, l0dd9
	push	de
	ld		a, b
	bit		0, (iy + _dflag)
	jp		nz, l0d02
	cp		(iy + _dfsz)
	jr		c, oserror
	ret		nz
	bit		4, (iy + _dflag)
	jr		z, l0c88
	ld		e, (iy + _breg)
	dec		e
	jp		z, l0cce
	xor		a
	call	l1601
	ld		sp, (listsp)
	res		4, (iy + _dflag)
	ret

l0c81:
	add		a, 0x5b
	jp		l0b5f

oserror:							; sam
	rst		error_1					;
	defb	Off_screen				;

l0c88:
	dec		(iy + _scrct)
	jr		nz, l0cce
	ld		a, 24
	sub		b
	ld		(scrct), a
	ld		hl, (attrt)
	push	hl
	ld		a, (pflag)
	push	af
	ld		a, 253
	call	l1601
	xor		a
	ld		de, l3235
	call	l0c0a
	set		5, (iy + _dflag)
	ld		hl, flags
	res		5, (hl)
	call	l18ff
	cp		' '
	jr		z, report_d
	cp		tk_stop
	jr		z, report_d
	or		%00100000
	cp		'n'
	jr		z, report_d
	ld		a, 254
	call	l1601
	pop		af
	ld		(pflag), a
	pop		hl
	ld		(attrt), hl

l0cce:
	call	l0dfe
	ld		b, (iy + _dfsz)
	inc		b
	ld		c, 33
	push	bc
	call	l0e9b
	ld		a, h
	rrca
	rrca
	rrca
	and		%00000011
	or		%01011000
	ld		h, a
	ld		de, attrmap + 0x02e0
	ld		a, (de)
	ld		c, (hl)
	ld		b, 32
	ex		de, hl

l0cec:
	ld		(de), a
	ld		(hl), c
	inc		de
	inc		hl
	djnz	l0cec
	pop		bc
	ret

l0cf4:
	call	out_digit
	ld		c, -10
	call	out_digit
	ld		a, l
	ret

l0cfe:								; se
	defb	0xff, 0x00				; ULAplus palette

report_d:							; zx81
	rst		error_1					;
	defb	BREAK_CONTINUE_repeats	;

l0d02:
	cp		2
	jr		c, oserror
	add		a, (iy + _dfsz)
	sub		25
	ret		nc
	neg
	push	bc
	ld		b, a
	ld		hl, (attrt)
	push	hl
	ld		hl, (pflag)
	push	hl
	call	trcurp
	ld		a, b

l0d1c:
	push	af
	ld		hl, dfsz
	ld		b, (hl)
	ld		a, b
	inc		a
	ld		(hl), a
	ld		hl, sposnu_h
	cp		(hl)
	jr		c, l0d2d
	inc		(hl)
	ld		b, 23

l0d2d:
	call	l0e00
	pop		af
	dec		a
	jr		nz, l0d1c
	pop		hl
	ld		(iy + _pflag), l
	pop		hl
	ld		(attrt), hl
	ld		bc, (sposnu)
	res		0, (iy + _dflag)
	call	l0dd9
	set		0, (iy + _dflag)
	pop		bc
	ret

trcurp:								; skel
	xor		a						;
	ld		hl, (attrp)				;
	bit		0, (iy + _dflag)		;
	jr		z, l0d5b				;
	ld		h, a					;
	ld		l, (iy + _bordcr)		;
									;
l0d5b:								;
	ld		(attrt), hl				;
	ld		hl, pflag				;
	jr		nz, l0d65				;
	ld		a, (hl)					;
	rrca							;
									;
l0d65:								;
	xor		(hl)					;
	and		%01010101				;
	xor		(hl)					;
	ld		(hl), a					;
	ret								;
									;
cls:								;
	call	l005f					;
									;
clslower:							;
	ld		hl, dflag				;
	res		5, (hl)					;
	set		0, (hl)					;
	ld		b, (iy + _dfsz)			;
	call	l0e44					;
	ld		hl, attrmap + 0x02c0	;
	ld		a, (attrp)				;
	dec		b						;
	jr		l0d8e					;

l0d84:								; se
	defb	"CMS"					;

l0d87:
	ld		c, 32					; skel
									;
l0d89:								;
	dec		hl						;
	ld		(hl), a					;
	dec		c						;
	jr		nz, l0d89				;
									;
l0d8e:								;
	djnz	l0d87					;
	ld		(iy + _dfsz), 2			;
									;
l0d94:								;
	ld		a, 253					;
	call	l1601
	ld		hl, (curchl)			; skel
	ld		de, prmain				;
	and		a						;
									;
l0da0:								;
	ld		(hl), e					;
	inc		hl						;
	ld		(hl), d					;
	inc		hl						;
	ld		de, kyip				;
	ccf								;
	jr		c, l0da0				;
	ld		bc, 0x1721				;
	jr		l0dd9					;
									;
l0daf:								;
	ld		hl, 0					;
	ld		(xcoord), hl			;
	res		0, (iy + _klflag)		;
	call	l0d94					;
	call	streamfe
	ld		b, 24					; skel
	call	l0e44					;
	ld		hl, (curchl)			;
	ld		de, prmain				;
	ld		(hl), e					;
	inc		hl						;
	ld		(hl), d					;
	ld		(iy + _scrct), 1		;
	jr		l0dd9					;

l0dd3:								; se
	call	numeric					;
	jp		l1068					;

l0dd9:								; skel
	ld		a, b					;
	bit		0, (iy + _dflag)		;
	jr		z, l0de5				;
	add		a, (iy + _dfsz)			;
	sub		24						;
									;
l0de5:								;
	push	bc						;
	ld		b, a					;
	call	l0e9b					;
	pop		bc						;
	ld		a, 33					;
	sub		c						;
	ld		e, a					;
	ld		d, 0					;
	add		hl, de					;
	jp		l0adc					;

x80_ftan:							; zx81
	fwait							;
	fmove							;
	fsin							;
	fxch							;
	fcos							;
	fdiv							;
	fce								;
	ret								;
	defb	0xff					; se

l0dfe:								; skel
	ld		b, 23					;
									;
l0e00:								;
	call	l0e9b					;
	ld		c, 8					;
									;
l0e05:								;
	push	bc						;
	push	hl						;
	ld		a, b					;
	and		%00000111				;
	ld		a, b					;
	jr		nz, l0e19				;
									;
l0e0d:								;
	ex		de, hl					;
	ld		hl, 0xf8e0				;
	add		hl, de					;
	ex		de, hl					;
	ld		bc, 0x0020				;
	dec		a						;
	ldir							;
									;
l0e19:								;
	ex		de, hl					;
	ld		hl, 0xffe0				;
	add		hl, de					;
	ex		de, hl					;
	ld		b, a					;
	and		%00000111				;
	rrca							;
	rrca							;
	rrca							;
	ld		c, a					;
	ld		a, b					;
	ld		b, 0					;
	ldir							;
	ld		b, 7					;
	add		hl, bc					;
	and		%11111000				;
	jr		nz, l0e0d				;
	pop		hl						;
	inc		h						;
	pop		bc						;
	dec		c						;
	jr		nz, l0e05				;
	call	l0e88					;
	ld		hl, 0xffe0				;
	add		hl, de					;
	ex		de, hl					;
	ldir							;
	ld		b, 1					;
									;
l0e44:								;
	push	bc						;
	call	l0e9b					;
	ld		c, 8					;
									;
l0e4a:								;
	push	bc						;
	push	hl						;
	ld		a, b					;
									;
l0e4d:								;
	and		%00000111				;
	rrca							;
	rrca							;
	rrca							;
	ld		c, a					;
	ld		a, b					;
	ld		b, 0					;
	dec		c						;
	ld		d, h					;
	ld		e, l					;
	ld		(hl), b					; se
	inc		de						; skel
	ldir							;
	ld		de, 0x0701				;
	add		hl, de					;
	dec		a						;
	and		%11111000				;
	ld		b, a					;
	jr		nz, l0e4d				;
	pop		hl						;
	inc		h						;
	pop		bc						;
	dec		c						;
	jp		nz, l0e4a				; se
	call	l0e88					; skel

screen2:
	ld		h, d					;
	ld		l, e					;
	inc		de						;
	ld		a, (attrp)				;
	bit		0, (iy + _dflag)		;
	jr		z, l0e80				;
	ld		a, (bordcr)				;
									;
l0e80:								;
	ld		(hl), a					;
	dec		bc						;
	ldir							;
	pop		bc						;
	ld		c, 33					;
	ret								;
									;
l0e88:								;
	ld		a, h					;
	rrca							;
	rrca							;
	rrca							;
	dec		a						;
	or		%01010000				;
	ld		h, a					;
	ex		de, hl					;
	ld		h, c					;
	ld		l, b					;
	add		hl, hl					;
	add		hl, hl					;
	add		hl, hl					;
	add		hl, hl					;
	add		hl, hl					;
	ld		b, h					;
	ld		c, l					;
	ret								;
									;
l0e9b:								;
	ld		a, 24					;
	sub		b						;
	ld		d, a					;
	rrca							;
	rrca							;
	rrca							;
	and		%11100000				;
	ld		l, a					;
	ld		a, d					;
	and		%00011000				;
	or		%01000000				;
	ld		h, a					;
	ret								;

l0eac:
	cp		'\'
	jr		z, l0ebb
	cp		'~'
	jr		nz, l0ede
	pop		af
	ld		bc, 0x107c
	jp		s_push_po

l0ebb:
	pop		af
	call	syntax_z
	jp		nz, s_stk_dec
	ld		de, 0

l0ec5:
	rst		next_ch
	sub		48
	cp		8
	jr		nc, l0f14
	ex		de, hl
	add		hl, hl
	jr		c, l0ed4
	add		hl, hl
	jr		c, l0ed4
	add		hl, hl

l0ed4:
	jp		c, report_6
	ld		d, 0
	ld		e, a
	add		hl, de
	ex		de, hl
	jr		l0ec5

l0ede:
	cp		'&'		
	jp		nz, l16dc
	pop		af
	call	syntax_z
	jp		nz, s_stk_dec
	ld		de, 0

l0eed:
	rst		next_ch
	call	alphanum
	jr		nc, l0f14
	cp		'A'
	jp		c, l0f00
	or		%00100000
	cp		'g'
	jr		nc, l0f14
	sub		0x27

l0f00:
	and		%00001111
	ld		c, a
	ld		a, d
	and		%11110000
	jp		nz, report_6
	ld		a, c
	ex		de, hl
	add		hl, hl
	add		hl, hl
	add		hl, hl
	add		hl, hl
	or		l
	ld		l, a
	ex		de, hl
	jr		l0eed

l0f14:
	call	l2cb3
	jp		l2695

l0f1a:								; se
	ld		bc, -10000				;
	call	out_digit				;
	ld		bc, -1000				; zx81
	call	out_digit				;
	ld		bc, -100				;
	jp		l0cf4					; se

editor:								; sam
	ld		hl, (errsp)				;
	push	hl						;
									;
edag:								;
	ld		hl, eder				;
	push	hl						;
	ld		(errsp), sp				;

l0f38:
	call	waitkey
	push	af
	ld		hl, 200
	ld		a, (click)
	ld		e, a
	and		a
	call	nz, l03b5
	pop		af
	ld		hl, l0f38
	push	hl
	cp		24
	jr		nc, add_char
	cp		7
	jr		c, add_char
	cp		16
	jr		c, l0f92
	ld		bc, 2
	ld		d, a
	cp		22
	jr		c, l0f6c
	inc		bc
	call	waitkey
	bit		7, (iy + _flage)
	jp		z, l101a
	ld		e, a

l0f6c:
	call	waitkey
	push	de
	ld		hl, (kcur)
	res		0, (iy + _mode)
	call	make_room
	pop		bc
	inc		hl
	ld		(hl), b
	inc		hl
	ld		(hl), c
	jr		l0f87

add_char:
	ld		hl, (kcur)
	call	one_space				; zx81
									;
l0f87:								;
	ld		(de), a					;
	inc		de
	ld		(kcur), de
	ret

l0f8e:
	pop		af
	jp		l12ac

l0f92:
	ld		e, a
	ld		d, 0
	ld		hl, cursor - 7
	add		hl, de
	ld		e, (hl)
	add		hl, de
	push	hl
	ld		hl, (kcur)
	ret

cursor:								; zx81
	defb	edit_key - $			;
	defb	left_key - $			;
	defb	right_key - $			;
	defb	down_key - $			;
	defb	up_key - $				;
	defb	rubout - $				;
	defb	n_l_key - $				;
	defb	function - $			;
	defb	graphics - $			;

edit_key:
	ld		hl, (eppc)
	bit		5, (iy + _flage)
	jp		nz, l1095
	call	line_addr				; zx81
	call	line_no					;
	ld		a, d					;
	or		e						;
	jp		z, l1095
	push	hl
	inc		hl						; zx81
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	ld		hl, 10
	add		hl, bc
	ld		b, h
	ld		c, l
	call	test_room
	call	l1095
	ld		hl, (curchl)
	ex		(sp), hl
	push	hl
	ld		a, 255
	call	l1601
	pop		hl
	dec		hl
	call	l1860
	ld		hl, (eline)
	call	l18b5
	ld		(kcur), hl
	pop		hl
	jp		chanflag

down_key:
	bit		5, (iy + _flage)		; se
	jp		nz, l2408				;
	call	l0af6					;
	ld		hl, eppc				;
	ex		de, hl					;
									;
l0ff9:								;
	call	right_key				;
	djnz	l0ff9					;
	ret								;

l0fff:
	ld		a, %00001000
	xor		(hl)
	ld		(hl), a
	jp		l10f4					; se
									;
	
left_key:
	call	left_edge
	jr		l100f

right_key:							; se
	jp		l0099					;

l100e:
	inc		hl

l100f:
	ld		(kcur), hl
	ret

rubout:								; zx81
	call	left_edge				;
	ex		de, hl					; se
	jp		reclaim_1				;

l101a:
	call	waitkey

n_l_key:
	pop		hl
	pop		hl

l101f:
	pop		hl
	ld		(errsp), hl
	bit		7, (iy + _errnr)
	ret		nz
	ld		sp, hl
	ret

left_edge:
	scf
	call	l1195
	sbc		hl, de
	add		hl, de
	inc		hl
	pop		bc
	ret		c
	push	bc
	ld		b, h
	ld		c, l

l1037:
	ld		h, d
	ld		l, e
	inc		hl
	ld		a, (de)
	and		%11110000
	cp		ctrl_pen
	jr		nz, l1042
	inc		hl

l1042:
	and		a
	sbc		hl, bc
	add		hl, bc
	ex		de, hl
	jr		c, l1037
	ret

up_key:
	bit		5, (iy + _flage)		; se
	ret		nz						;
	call	l0af6					;
	ld		hl, (eppc)				;
	ex		de, hl					;
									;
l1056:								;
	push	bc						;
	call	left_key				;
	pop		bc						;
	djnz	l1056					;
	ret								;
									;
l105e:								;
	call	syntax3					;
	ld		a, b					;
	or 		c						;
	ret		nz						;
	pop		bc						;
	jp		l38ec					;
	
l1068:
	push	af						;
	call	int_to_fp				;
	pop		af						;
	ret		nc						;
	pop		bc						;
	call	fp_to_bc				;
	scf								;
	jp		set_mem					;
	
function:
	bit		7, (iy + _flage)
	jr		z, n_l_key

graphics:
	jp		add_char

eder:
	bit		4, (iy + _klflag)
	jr		z, l101f
	call	l1167
	jp		edag

l108b:
	call	l1167
	ld		de, (sposnl)
	jp		l117e

l1095:
	push	hl
	call	l1190
	dec		hl
	call	reclaim_1
	ld		(kcur), hl
	ld		(iy + _mode), 0
	pop		hl
	ret

kyip:
	bit		3, (iy + _dflag)
	call	nz, l111d
	and		a						; sam
	bit		5, (iy + _flags)		;
	ret		z						;
									;
l10b3:								;
	ld		a, (lastk)				;
	res		5, (iy + _flags)		;
	push	af						;
	bit		5, (iy + _dflag)		;
	call	nz, clslower			;
	pop		af						;
	cp		' '
	jr		nc, l111b
	cp		ctrl_pen
	jr		nc, l10fa
	cp		6
	jr		nc, l10d9
	ld		b, a
	and		%00000001
	ld		c, a
	ld		a, b
	rra
	add		a, 18
	jr		l1105

l10d9:
	ld		hl, klflag				; se
	jp		z, l0fff				;
	cp		7						;
	jr		nz, l10e6				;
	dec		a						;
	scf								;
	ret								;

l10e6:
	cp		ctrl_symbol
	ret		c
	sub		13
	ld		hl, mode
	cp		(hl)
	ld		(hl), a
	jr		nz, l10f4
	ld		(hl), 0

l10f4:
	set		3, (iy + _dflag)
	cp		a
	ret

l10fa:
	ld		b, a
	and		%00000111
	ld		c, a
	ld		a, ctrl_pen
	bit		3, b
	jr		nz, l1105
	inc		a

l1105:
	ld		(iy - _kdata), c
	ld		de, l110d
	jr		l1113

l110d:
	ld		a, (kdata)
	ld		de, kyip

l1113:
	ld		hl, (chans)
	inc		hl
	inc		hl
	ld		(hl), e
	inc		hl
	ld		(hl), d

l111b:
	scf
	ret

l111d:
	call	trcurp
	res		3, (iy + _dflag)
	res		5, (iy + _dflag)
	ld		hl, (sposnl)
	push	hl
	ld		hl, (errsp)
	push	hl
	ld		hl, l108b
	push	hl
	ld		(errsp), sp
	ld		hl, (echoe)
	push	hl
	scf
	call	l1195
	ex		de, hl
	call	l187f
	ex		de, hl
	call	opcursor
	ld		hl, (sposnl)
	ex		(sp), hl
	ex		de, hl
	call	trcurp

l1150:
	ld		a, (sposnl_h)
	sub		d
	jr		c, l117c
	jr		nz, l115e
	ld		a, e
	sub		(iy + _sposnl)
	jr		nc, l117c

l115e:
	ld		a, ' '
	push	de
	call	prmain
	pop		de
	jr		l1150

l1167:
	exx
	ld		d, 0
	ld		e, (iy - _errsound)
	ld		hl, 0x0864
	call	l03b5
	exx
	ld		(iy + _errnr), OK
	ret

l1179:						; se
	pop		hl				;
	ld		sp, hl			;
	ret						;

l117c:
	pop		de
	pop		hl

l117e:
	pop		hl
	ld		(errsp), hl
	pop		bc
	push	de
	call	l0dd9
	pop		hl
	ld		(echoe), hl
	ld		(iy + _xptr_h), 0
	ret

l1190:
	ld		hl, (worksp)
	dec		hl
	and		a

l1195:
	ld		de, (eline)
	bit		5, (iy + _flage)
	ret		z
	ld		de, (worksp)
	ret		c
	ld		hl, (stkbot)
	ret

l11a7:
	ld		a, (hl)
	cp		ctrl_number
	ld		bc, 6
	call	z, reclaim_2
	ld		a, (hl)
	inc		hl
	cp		ctrl_n_l
	jr		nz, l11a7
	ret

l11cb:								; se
	ldir							;
	jr		l1179					;
									;
new:								;
	di								;
	xor		a						;
	dec		a						;
	ld		de, (ramtop)			;
	exx								;
	ld		bc, (udg)				;
	ld		de, (nmiadd)			;
	ld		hl, (pramt)				;
	exx								;
									;
l11cf:								;
	ex		af, af'					;'
	xor		a						;
	out		(scld), a				;
	ld		a, 6					;
	ld		i, a					;
	ld		yh, d					;
	ld		yl, e					;
	ex		de, hl					;
	ld		de, 0x5c00				;
	sbc		hl, de					;
	ld		b, h					;
	ld		c, l					;
	ld		h, d					;
	ld		l, e					;
	ld		(hl), l					;
	inc		e						;
	ldir							;
	exx								;
	ld		(udg), bc				;
	ld		(nmiadd), de			;
	ld		(pramt), hl				;
	exx								; 
	ex		af, af'					;'
	inc		a						;
	jp		z, set_top				;
;		ld		h, yh				; not supported
;		ld		l, yl				; by binutils
	defb	0xfd, 0x64, 0xfd, 0x6d	;
	ld		(pramt), hl				;
	ld		hl, initpal				;
	ld		de, palbuf				;
	ld		bc, 64					;
	ldir							;
	jp		setudg					;

setudg_ret:
	ld		hl, (pramt)				;

set_top:							; zx81
	ld		(ramtop), hl			;

initial:							; skel
	ld		hl, font - 256			;
	ld		(chars), hl
	ld		hl, 0x003c				; se
	ld		(errsound), hl			;
	ld		hl, (ramtop)			; zx81
	ld		(hl), 0x3e				;
	dec		hl						;
	ld		sp, hl					;
	dec		hl						;
	dec		hl						;
	ld		(errsp), hl				;
	im		1						;
	ld		iy, errnr				;
	ei
	ld		a, (chans)				; se
	and		a						;
	ld		(iy+_onerrflag_h), 0xff	;
	ld		a, 21					;
	jp		nz, l130f				;
	ld		bc, 0x0015
	ld		de, chantab
	ld		hl, channels
	ld		(chans), hl
	ex		de, hl
	ldir
	ex		de, hl
	dec		hl
	ld		(datadd), hl
	inc		hl
	ld		(vars), hl
	ld		(prog), hl
	ld		(hl), 0x80
	inc		hl
	ld		(eline), hl
	ld		a, white				; se
	ld		(bordcr), a				;
	ld		(attrp), a				;
	ld		hl, 0x0219				;
	ld		(repdel), hl			;
	ld		hl, initial				;
	ld		(nmiadd), hl			;
	dec		(iy - _kstate_4)
	dec		(iy - _kstate)
	ld		c, 14
	ld		de, strms
	ld		hl, strmtab
	ldir
	ld		(iy + _dfsz), 2
	ld		a, black				; se
	out		(ula), a				;
	call	cls						;
	call	l394d					;
	xor		a
	ld		de, l1396
	call	l0c0a
	set		5, (iy + _dflag)
	jr		l12a9

l12a2:
	ld		(iy + _dfsz), 2
	call	autolist

l12a9:
	call	setmin

l12ac:
	xor		a
	call	l1601
	call	l39d0
	call	l1b17
	bit		7, (iy + _errnr)
	jr		nz, l12cf
	bit		4, (iy + _klflag)
	jr		z, l1301
	ld		hl, (eline)
	call	l11a7
	ld		(iy + _errnr), OK
	jp		l12ac

l12cf:
	ld		(iy + _mode), 0
	call	eline_no
	ld		a, c
	or		b
	jp		nz, n_l_line
	rst		get_ch
	cp		ctrl_n_l
	jr		z, l12a2
	bit		0, (iy + _klflag)
	call	nz, l0daf
	call	clslower
	ld		a, 25
	sub		(iy + _sposnu_h)
	ld		(scrct), a
	set		7, (iy + _flags)
	ld		(iy + _nsppc), 1
	ld		(iy + _errnr), OK
	call	linerun

l1301:
	ld		a, (errnr)				; se
	res		5, (iy + _flags)		;
	call	l38af					;
	ld		a, (errnr)
	inc		a
	
l130f:
	push	af
	ld		bc, ay_reg				; se
	ld		a, 7					;
	out		(c), a					;
	ld		a, 0xff					;
	call	l38ce					;
	ld		hl, 0
	ld		(defadd), hl
	ld		(iy + _xptr_h), l
	ld		(iy + _flage), l
	inc		hl
	ld		(strms_00), hl
	call	setmin
	call	clslower
	pop		af
	set		5, (iy + _dflag)
	ld		de, l140c - 1
	set		0, (iy + _flags)
	call	l0c0a
	jp		l134a

l1344:								; se
	call	restorez				;
	jp		cls						;
									;
l134a:								;
	ld		a, ','					;
	rst		print_a					;
	ld		a, ' '					;
	rst		print_a					;
	ld		bc, (ppc)
	call	out_num
	ld		a, ':'
	rst		print_a
	ld		b, 0
	ld		c, (iy + _subppc)
	call	out_num
	call	l1095
	ld		a, (errnr)
	inc		a
	jr		z, l1386
	cp		9
	jr		z, l1373
	cp		21
	jr		nz, l1376

l1373:
	inc		(iy + _subppc)

l1376:
	ld		hl, nsppc
	ld		de, cosppc
	ld		bc, 3
	bit		7, (hl)
	jr		z, l1384
	add		hl, bc

l1384:
	lddr

l1386:
	ld		(iy + _nsppc), 255
	jp		l12ac

setudg3:							; se
	ld		(udg), de				;
	ldir							;
	jp		setudg_ret				;

l1396:								; se
	incbin		"data/copyright.txt"		;

l13b6:								; sam
	incbin		"data/tape.txt"			;
									;
l13d5:								;
	incbin		"data/filetypes.txt"		;

l140c:								; se
	incbin		"data/reports.txt"		;
									;
l1555:								;
	pop		hl						;
	ld		hl, l1301				;
	push	hl						;
	jp		nextstat				;

n_l_line:							; zx81
	ld		(eppc), bc				;
	ld		hl, (chadd)				;
	ex		de, hl					;
	ld		hl, n_l_only			;
	push	hl						;
	ld		hl, (worksp)			; was stkbot
	scf
	sbc		hl, de					; zx81
	push	hl						;
	ld		h, b
	ld		l, c
	call	line_addr				; zx81
	jr		nz, copy_over			;
	call	next_one				;
	call	reclaim_2				;
									;
copy_over:							;
	pop		bc						;
	ld		a, c					;
	dec		a						;
	or		b						;
	jr		z, l15ab
	push	bc						; zx81
	inc		bc						;
	inc		bc						;
	inc		bc						;
	inc		bc						;
	dec		hl						;
	ld		de, (prog)
	push	de
	call	make_room
	pop		hl
	ld		(prog), hl
	pop		bc						; zx81
	push	bc						;
	inc		de						;
	ld		hl, (worksp)			; was stkbot
	dec		hl						;
	dec		hl
	lddr							; zx81
	ld		hl, (eppc)				;
	ex		de, hl					;
	pop		bc						;
	ld		(hl), b					;
	dec		hl						;
	ld		(hl), c					;
	dec		hl						;
	ld		(hl), e					;
	dec		hl						;
	ld		(hl), d					;

l15ab:
	pop		af
	jp		l12a2

chantab:							; sam
	defw	prmain, kyip			;
	defb	'K'						;
	defw	prmain, iderr			;
	defb	'S'						;
	defw	l3963, iderr			;
	defb	'R'						; se
	defw	x80_fdel, iderr			;
	defb	'P'						; sam
	defb	0x80					;
									;
iderr:								;
	rst		error_1					;
	defb	Bad_device				;
									;
strmtab:							;
	defb	0x01, 0x00, 0x06, 0x00, 0x0b, 0x00, 0x01, 0x00
	defb	0x01, 0x00, 0x06, 0x00, 0x10, 0x00
									;
waitkey:							;
	bit		5, (iy + _dflag)		;
	jr		nz, wtky2				;
	set		3, (iy + _dflag)		;
									;
wtky2:								;
	call	inputad					;
	ret		c						;
	jr		z, wtky2				;
	rst		error_1					;
	defb	End_of_file				;
									;
inputad:							;
	exx								;
	push	hl						;
	ld		hl, (curchl)			;
	inc		hl						;
	inc		hl						;
	jr		l15f7

out_code:							; zx81
	ld		e, '0'					;
	add		a, e					;
									;
print_sp:							;
	exx								;
	push	hl						;
	ld		hl, (curchl)

l15f7:
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ex		de, hl
	call	l162c
	pop		hl						; zx81
	exx								;
	ret								;

l1601:
	add		a, a
	add		a, 22
	ld		h, 92
	ld		l, a
	ld		e, (hl)
	inc		hl
	ld		d, (hl)
	ld		a, e
	or		d
	jr		nz, l1610

invstrm:							; sam
	rst		error_1					;
	defb	Bad_stream				;

l1610:
	dec		de
	ld		hl, (chans)
	add		hl, de

chanflag:
	res		4, (iy + _klflag)
	ld		(curchl), hl			; sam
	inc		hl						;
	inc		hl						;
	inc		hl						;
	inc		hl						;
	ld		c, (hl)
	ld		hl, cltab
	call	l16dc
	ret		nc
	ld		e, (hl)
	ld		d, 0
	add		hl, de

l162c:
	jp		(hl)

cltab:								; sam
	defb	'K', l1634 - $			;
	defb	'S', l1642 - $			;
	defb	'R', l1651 - $			; se
	defb	0						;

l1634:
	res		5, (iy + _flags)
	set		4, (iy + _klflag)
	set		0, (iy + _dflag)
	jr		l1646

l1642:
	res		0, (iy + _dflag)

l1646:
	jp		trcurp

l1649:								; se
	defb	'K', l1650 - $			;
	defb	'S', l1650 - $			;
	defb	'R', l1650 - $			;
	defb	0						;
									;
l1650:								;
	pop		hl						;
									;
l1651:								;
	ret								;

one_space:							; zx81
	ld		bc, 1					;
									;
make_room:							;
	push	hl						;
	call	test_room				;
	pop		hl						;
	call	pointers				;
	ld		hl, (stkend)			;
	ex		de, hl					;
	lddr							;
	ret								;
									;
pointers:							;
	push	af						;
	push	hl						;
	ld		hl, vars				;
	ld		a, 14					;
									;
next_ptr:							;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ex		(sp), hl				;
	and		a						;
	sbc		hl, de					;
	add		hl, de					;
	ex		(sp), hl				;
	jr		nc, ptr_done			;
	push	de						;
	ex		de, hl					;
	add		hl, bc					;
	ex		de, hl					;
	ld		(hl), d					;
	dec		hl						;
	ld		(hl), e					;
	inc		hl						;
	pop		de						;
									;
ptr_done:							;
	inc		hl						;
	dec		a						;
	jr		nz, next_ptr			;
	ex		de, hl					;
	pop		de						;
	pop		af						;
	and		a						;
	sbc		hl, de					;
	ld		b, h					;
	ld		c, l					;
	inc		bc						;
	add		hl, de					;
	ex		de, hl					;
	ret								;
									;
l168f:								;
	defw	0x0000					;
									;
zero_de:							;
	ex		de, hl					;
	ld		de, l168f				;
									;
line_no:							;
	ld		a, (hl)					;
	and		%11000000				;
	jr		nz, zero_de				;
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	ret								;
									;
reserve:							;
	ld		hl, (stkbot)			;
	dec		hl						;
	call	make_room				;
	inc		hl						;
	inc		hl						;
	pop		bc						;
	ld		(worksp), bc			; was eline
	pop		bc						;
	ex		de, hl					;
	inc		hl						;
	ret								;

setmin:
	ld		hl, (eline)
	ld		(hl), ctrl_n_l
	ld		(kcur), hl
	inc		hl						; sam
	ld		(hl), 0x80				;
	inc		hl						;
	ld		(worksp), hl			;
									;
setwork:							;
	ld		hl, (worksp)			;
	ld		(stkbot), hl

set_mem:							; zx81
	ld		hl, (stkbot)			;
	ld		(stkend), hl			; sam
	push	hl
	ld		hl, membot				; zx81
	ld		(mem), hl				;
	pop		hl
	ret								; sam

setudg2:							; se
	ld		e, 0x40					;
	ld		c, 168					;
	jp		setudg3					;

l16db:
	inc		hl

l16dc:
	ld		a, (hl)
	and		a
	ret		z
	cp		c
	inc		hl
	jr		nz, l16db
	scf
	ret

l16e5:
	call	l171e
	call	l18a8
	ld		bc, 0
	ld		de, 0xa3e2
	ex		de, hl
	add		hl, de
	jr		c, l16fc
	ld		bc, strmtab + 14
	add		hl, bc
	ld		c, (hl)
	inc		hl
	ld		b, (hl)

l16fc:
	ex		de, hl
	ld		(hl), c
	inc		hl
	ld		(hl), b
	ret

l1701:
	push	hl
	ld		hl, (chans)
	add		hl, bc
	inc		hl
	inc		hl
	inc		hl
	ld		c, (hl)
	ex		de, hl
	ld		hl, l1649
	call	l16dc
	ld		c, (hl)
	jr		l1716

l1714:
	add		hl, bc
	jp		(hl)

l1716:
	ld		b, 0
	jr		c, l1714
	jr		invstrm2
	pop		hl
	ret

l171e:
	call	getbyte
	cp		16
	jr		c, l1727

invstrm2:							; sam
	rst		error_1					;
	defb	Bad_stream				;

l1727:
	add		a, 3
	rlca
	ld		hl, strms
	ld		b, 0
	ld		c, a
	add		hl, bc
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	dec		hl
	ret

l1736:
	fwait
	fxch
	fce
	call	l171e
	ld		a, c
	or		b
	jr		z, l1756
	ex		de, hl
	ld		hl, (chans)
	add		hl, bc
	inc		hl
	inc		hl
	inc		hl
	ld		a, (hl)
	ex		de, hl
	cp		'K'
	jr		z, l1756
	cp		'S'
	jr		z, l1756
	cp		'R'
	jr		nz, invstrm2

l1756:
	call	l175d
	ld		(hl), e
	inc		hl
	ld		(hl), d
	ret

l175d:
	push	hl
	call	stk_fetch
	ld		a, c
	or		b
	jr		nz, l1767

report_f:							; zx81
	rst		error_1					;
	defb	Bad_filename			;

l1767:
	push	bc
	ld		a, (de)
	and		%11011111
	ld		c, a
	ld		hl, l177a
	call	l16dc
	jr		nc, report_f
	ld		b, 0
	ld		c, (hl)
	add		hl, bc
	pop		bc
	jp		(hl)

l177a:
	defb	'K', l1781 - $
	defb	'S', l1785 - $
	defb	'R', l1789 - $			; se
	defb	0						;

l1781:
	ld		e, 1
	jr		l178b

l1785:
	ld		e, 6
	jr		l178b

l1789:
	ld		e, 0x0b

l178b:
	dec		bc
	ld		a, b
	or		c
	jr		nz, report_f
	ld		d, a
	pop		hl
	ret

l1793:
	jr		invstrm2

autolist:
	ld		(iy + _dflag), 16
	ld		(listsp), sp
	call	l0daf
	ld		b, (iy + _dfsz)
	set		0, (iy + _dflag)
	call	l0e44
	res		0, (iy + _dflag)
	set		0, (iy + _klflag)		; sam
	ld		de, (sdtop)				; was hl
	ld		hl, (eppc)				; was de
	and		a						;
	sbc		hl, de					;
	add		hl, de
	jr		c, aul4
	push	de
	call	line_addr
	ld		de, 0x02c0
	ex		de, hl
	sbc		hl, de
	ex		(sp), hl
	call	line_addr
	pop		bc

l17ce:
	push	bc
	call	next_one
	pop		bc
	add		hl, bc
	jr		c, l17e4
	ex		de, hl
	ld		d, (hl)
	inc		hl
	ld		e, (hl)
	dec		hl
	ld		(sdtop), de
	jr		l17ce

aul4:								; sam
	ld		(sdtop), hl				;

l17e4:
	ld		hl, (sdtop)
	call	line_addr
	jr		z, l17ed
	ex		de, hl

l17ed:
	call	l1833
	res		4, (iy + _dflag)
	ret

llist:								; sam
	ld		a, 3					; was c
	jr		l17fb					;
									;
list:								;
	ld		a, 2					; was c
									;
l17fb:								;
	ld		(iy + _dflag), 0		;
	call	syntax_z				;
	call	nz, l1601
	rst		get_ch
	call	l2070
	jr		c, l181f
	rst		get_ch
	cp		','
	jr		z, l1819
	cp		';'
	jr		z, l1819

l1814:
	call	no_to_stk
	jr		l1822

l1819:
	rst		next_ch
	call	class_6
	jr		l1822

l181f:
	call	l1cde

l1822:
	call	check_end
	call	syntax3
	ld		a, b
	and		%00111111
	ld		h, a
	ld		l, c
	ld		(eppc), hl
	call	line_addr

l1833:
	ld		e, 1

l1835:
	call	out_line
	rst		print_a
	bit		4, (iy + _dflag)
	jr		z, l1835
	ld		a, (dfsz)
	sub		(iy + _sposnu_h)
	jr		nz, l1835
	xor		e
	ret		z
	push	de
	push	hl
	ld		hl, sdtop
	call	ln_fetch
	pop		hl
	pop		de
	jr		l1835

out_line:							; zx81
	ld		bc, (eppc)				;
	call	cp_lines				;
	ld		d, 143					;
	jr		z, test_end				;
									;
l1860:								;
	ld		de, 0					;
	rl		e						;
									;
test_end:							;
	ld		(iy + _breg), e			;
	ld		a, (hl)					;
	cp		64						;
	pop		bc						;
	ret		nc						;
	push	bc						;
	call	out_no					;
	inc		hl						; sam
	inc		hl						;
	inc		hl						;
	ld		a, d
	and		a
	res		0, (iy + _flags)
	jr		z, l1883
	call	l18ee

l187f:
	set		0, (iy + _flags)

l1883:
	push	de
	ex		de, hl

l1885:
	ld		hl, (xptr)
	and		a
	sbc		hl, de
	jr		nz, l1895
	ld		a, '?'
	call	l18ee
	call	l1167

l1895:
	call	opcursor
	ex		de, hl
	ld		a, (hl)
	call	number
	inc		hl
	cp		ctrl_n_l
	jr		z, l18a6
	ex		de, hl
	rst		print_a
	jr		l1885

l18a6:
	pop		de
	ret

l18a8:								; se
	ld		d, a					;
	ld		a, b					;
	or		c						;
	ld		a, d					;
	jp		nz, l1701				;
	rst		error_1					;
	defb	Bad_stream				;

number:								; zx81
	cp		ctrl_number				;
	ret		nz						;

l18b4:
	inc		hl						;
									;
l18b5:								;
	inc		hl						;
	inc		hl						;
	inc		hl						;
	inc		hl						;
	inc		hl						; se
	ld		a, (hl)					; zx81
	ret								;

l18bc:								; se
	call	find_int				;
	push	bc						;
	call	find_int				;
	push	bc						;
	call	find_int				;
	push	bc						;
	pop		hl						;
	pop		de						;
	pop		bc						;
	ldir							;
	ret								;

n_l_only:
	ld		a, 16
	jp		l130f

opcursor:							; sam
	ld		hl, (kcur)				;
	and		a						;
	sbc		hl, de					;
	ret		nz						;
	ld		a, (mode)
	cp		2						; se
	jr		c, l18e5				;
	ld		a, 29					;
	jr		l18ee					;
									;
l18e5:								;
	ld		a, 30					;
	bit		3, (iy + _klflag)		;
	jr		z, l18ee				;
	inc		a						;

l18ee:								; se
	exx								;
	ld		hl, pflag				;
	ld		d, (hl)					;
	push	de						;
	ld		(hl), 0x0c				;
	call	prmain					;
	pop		hl						;
	ld		(iy + _pflag), h		;
	exx								;
	ret								;
									;
l18ff:								;
	ld		hl, lastk				;
	ld		(hl), l					;
									;
l1903:								;
	ld		a, (hl)					;
	cp		ctrl_n_l				;
	jr		z, l190c				;
	cp		' '						;
	jr		c, l1903				;
									;
l190c:								;
	jp		l10b3					;

ln_fetch:							; zx80
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	push	hl						;
	ex		de, hl					;
	inc		hl						;
	call	line_addr				;
	call	line_no					;
	pop		hl						;
									;
ln_store:							;
	bit		5, (iy + _flage)		;
	ret		nz
	ld		(hl), d					; zx80
	dec		hl						;
	ld		(hl), e					;
	ret								;

lead_sp:							; zx81
	ld		a, e					;
	and		a						;
	ret		m						;
	rst		print_a					; se
	ret								;

out_digit:							; zx81
	xor		a						;
									;
digit_inc:							;
	add		hl, bc					;
	inc		a						;
	jr		c, digit_inc			;
	sbc		hl, bc					;
	dec		a						;
	jr		z, lead_sp				;
	jp		out_code				; se
									;
l1937:								;
	rst		get_ch					;
	cp		tk_goto					;
	jr		z, l1946				;
	cp		tk_continue				;
	jr		z, l1959				;
	cp		tk_stop					;
	jr		z, l1967				;
	rst		error_1					;
	defb	Syntax_error			;
									;
l1946:								;
	rst		next_ch					;
	call	class_6					;
	call	check_end				;
	call	syntax3					;
	call	syntax_z				;
	ret		z						;
	ld		(onerrflag), bc			;
	ret								;
									;
l1959:								;
	rst		next_ch					;
	call	check_end				;
	call	syntax_z				;
	ret		z						;
	ld		a, 0xfe					;
									;
l1963:								;
	ld		(onerrflag_h), a		;
	ret								;
									;
l1967:								;
	call	l1959					;
	ret		z						;
	inc		a						;
	jr		l1963					;

line_addr:							; zx81
	push	hl						;
	ld		hl, (prog)				;
	ld		d, h					;
	ld		e, l					;
									;
next_test:							;
	pop		bc						;
	call	cp_lines				;
	ret		nc						;
	push	bc						;
	call	next_one				;
	ex		de, hl					;
	jr		next_test				;
									;
cp_lines:							;
	ld		a, (hl)					;
	cp		b						;
	ret		nz						;
	inc		hl						;
	ld		a, (hl)					;
	dec		hl						;
	cp		c						;
	ret								;

l1988:								; se
	defb	"MGT"					;

skipstats:
	ld		(chadd), hl
	ld		c, 0

l1990:
	dec		d
	ret		z
	rst		next_ch
	cp		e
	jr		nz, l199a
	and		a
	ret

l1998:
	inc		hl
	ld		a, (hl)

l199a:
	call	number
	ld		(chadd), hl
	cp		'"'
	jr		nz, l19a5
	dec		c

l19a5:								; sam
	cp		':'						;
	jr		z, fincstat				;
	cp		tk_then					;
	jr		nz, l19b1

fincstat:
	bit		0, c 
	jr		z, l1990

l19b1:
	cp		ctrl_n_l
	jr		nz, l1998
	dec		d
	scf
	ret

next_one:							; zx81
	push	hl						;
	ld		a, (hl)					;
	cp		64						;
	jr		c, lines				;
	bit		5, a					;
	jr		z, bit_5_nil			;
	add		a, a					;
	jp		m, next_five			;
	ccf								;
									;
next_five:							;
	ld		bc, 5					;
	jr		nc, next_lett			;
	ld		c, 18					;
									;
next_lett:							;
	rla								;
	inc		hl						;
	ld		a, (hl)					;
	jr		nc, next_lett			;
	jr		next_add				;
									;
lines:								;
	inc		hl						;
									;
bit_5_nil:							;
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	inc		hl						;
									;
next_add:							;
	add		hl, bc					;
	pop		de						;
									;
differ:								;
	and		a						;
	sbc		hl, de					;
	ld		b, h					;
	ld		c, l					;
	add		hl, de					;
	ex		de, hl					;
	ret								;
									;
reclaim_1:							;
	call	differ					;
									;
reclaim_2:							;
	push	bc						;
	ld		a, b					;
	cpl								;
	ld		b, a					;
	ld		a, c					;
	cpl								;
	ld		c, a					;
	inc		bc						;
	call	pointers				;
	ex		de, hl					;
	pop		hl						;
	add		hl, de					;
	push	de						;
	ldir							;
	pop		hl						;
	ret								;
									;
eline_no:							;
	ld		hl, (eline)				;
	dec		hl						;
	ld		(chadd), hl				;
	rst		next_ch					;
	ld		hl, membot				;
	ld		(stkend), hl			;
	call	l0dd3
	call	fp_to_bc				; zx81
	jr		c, no_number			;
	ld		hl, 0xc000				; was 0xdf80
	add		hl, bc					;
									;
no_number:							;
	jp		c, report_c				;
	jp		set_mem					;
									;
out_num:							;
	push	de						;
	push	hl						;
	xor		a						;
	bit		7, b					;
	jr		nz, units				;
	ld		h, b					;
	ld		l, c					;
	ld		e, 255					;
	jr		thousand				;
									;
out_no:								;
	push	de						;
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	push	hl						;
	ex		de, hl					;
	ld		e, ' '					;

thousand:							; se
	call	l0f1a					;

units:								; zx81
	call	out_code				;
	pop		hl						;
	pop		de						;
	ret								;

syntax:
	defb	p_deffn - $				; sam
	defb	p_cat - $				;
	defb	p_format - $			;
	defb	p_move - $				;
	defb	p_erase - $				;
	defb	p_open  - $				;
	defb	p_close - $				;
	defb	p_merge - $				;
	defb	p_verify - $			;
	defb	p_beep - $				;
	defb	p_circle - $			;
	defb	p_pen - $				;
	defb	p_paper - $				;
	defb	p_flash - $				;
	defb	p_bright - $			;
	defb	p_inverse - $			;
	defb	p_over - $				;
	defb	p_out - $				;
	defb	p_lprint - $			; zx81
	defb	p_llist - $				;
	defb	p_stop - $				;
	defb	p_read - $				; sam
	defb	p_data - $				;
	defb	p_restore - $			;
	defb	p_new - $				; zx81
	defb	p_border - $			; sam
	defb	p_cont - $				; zx81
	defb	p_dim - $				;
	defb	p_rem - $				;
	defb	p_for - $				;
	defb	p_goto - $				;
	defb	p_gosub - $				;
	defb	p_input - $				;
	defb	p_load - $				;
	defb	p_list - $				;
	defb	p_let - $				;
	defb	p_pause - $				;
	defb	p_next - $				;
	defb	p_poke - $				;
	defb	p_print - $				;
	defb	p_plot - $				;
	defb	p_run - $				;
	defb	p_save - $				;
	defb	p_rand - $				;
	defb	p_if - $				;
	defb	p_cls - $				;
	defb	p_draw - $				; sam
	defb	p_clear - $				; zx81
	defb	p_return - $			;
	defb	p_copy - $				;
	defb	p_delete - $			; se
	defb	p_edit - $				;
	defb	p_renum - $				; sam
	defb	p_palette - $			;
	defb	p_sound - $				; se
	defb	p_onerr - $				;

p_let:								; zx81
	defb	var_rqd, '=', expr_num_str
									;
p_goto:								;
	defb	numexp_nofops			;
	defw	goto					;
									;
p_if:								;
	defb	num_exp, tk_then, var_syn
	defw	_if						;
									;
p_gosub:							;
	defb	numexp_nofops			;
	defw	gosub					;
									;
p_stop:								;
	defb	no_f_ops				;
	defw	stop					;
									;
p_return:							;
	defb	no_f_ops				;
	defw	return					;
									;
p_for:								;
	defb	chr_var, '=', num_exp, tk_to, num_exp, var_syn
	defw	for						;
									;
p_next:								;
	defb	chr_var, no_f_ops		;
	defw	next					;
									;
p_print:							;
	defb	var_syn					;
	defw	print					;
									;
p_input:							;
	defb	var_syn					;
	defw	input					;
									;
p_dim:								;
	defb	var_syn					;
	defw	dim						;
									;
p_rem:								;
	defb	var_syn					;
	defw	rem						;
									;
p_new:								;
	defb	no_f_ops				;
	defw	new						;
									;
p_run:								;
	defb	num_exp_0				;
	defw	run						;
									;
p_list:								;
	defb	var_syn					;
	defw	list					;
									;
p_poke:								;
	defb	two_c_s_num, no_f_ops	;
	defw	poke					;
									;
p_rand:								;
	defb	num_exp_0				;
	defw	rand					;
									;
p_cont:								;
	defb	no_f_ops				;
	defw	cont					;
									;
p_clear:							;
	defb	num_exp_0				;
	defw	clear					;
									;
p_cls:								;
	defb	no_f_ops				;
	defw	cls						;
									;
p_plot:								;
	defb	two_csn_col, no_f_ops	;
	defw	plot					;
									;
p_pause:							;
	defb	numexp_nofops			;
	defw	pause					;
									;
p_copy:								;
	defb	num_exp_0				;
	defw	copy					;
									;
p_lprint:							;
	defb	var_syn					;
	defw	lprint					;
									;
p_llist:							;
	defb	var_syn					;
	defw	llist					;

p_beep:								; sam
	defb	two_c_s_num, no_f_ops	;
	defw	l03f8					;
									;								
p_border:							;
	defb	numexp_nofops			;
	defw	l2294					;
									;
p_circle:							;
	defb	two_csn_col, var_syn	;
	defw	circle					;
									;
p_close:							;
	defb	numexp_nofops			;
	defw	l16e5					;
									;
p_data:								;
	defb	var_syn					;
	defw	l1e27					;
									;
p_deffn:							;
	defb	var_syn					;
	defw	l1f60					;

p_delete:							; se
	defb	two_c_s_num, no_f_ops	;
	defw	l0bbb					;

p_draw:								; sam
	defb	two_csn_col, var_syn	;
	defw	l2382					;

p_edit:								; se
	defb	num_exp_0				;
	defw	l38e6					;

p_format:							; sam
	defb	numexp_nofops			;
	defw	l0a58					;
									;
p_move:								;
	defb	two_c_s_num, ',', numexp_nofops
	defw	l18bc					;

p_onerr:							; se
	defb	var_syn					;
	defw	l1937					;

p_open:								; sam
	defb	num_exp, ',', str_exp, no_f_ops
	defw	l1736					;
									;
p_out:								;
	defb	two_c_s_num, no_f_ops	;
	defw	_out					;
									;
p_palette:							;
	defb	two_c_s_num, no_f_ops	;
	defw	l3934					;
									;
p_read:								;
	defb	var_syn					;
	defw	l1ded					;
									;
p_renum:							;
	defb	var_syn					;
	defw	l3aa9					;
									;
p_restore:							;
	defb	num_exp_0				;
	defw	restore					;

p_sound:							; se
	defb	var_syn					;
	defw	l09c3					;

p_cat:								; sam
p_erase:							;
	defb	var_syn					;
	defw	l09a1					;
									;
p_save:								;
	defb	tap_offst				;
									;
p_load:								;
	defb	tap_offst				;
									;
p_verify:							;
	defb	tap_offst				;
									;
p_merge:							;
	defb	tap_offst				;
									;
p_pen:								;
	defb	col_offst				;
									;
p_paper:							;
	defb	col_offst				;
									;
p_flash:							;
	defb	col_offst				;
									;
p_bright:							;
	defb	col_offst				;
									;
p_inverse:							;
	defb	col_offst				;
									;
p_over:								;
	defb	col_offst				;

l1b17:
	res		7, (iy + _flags)
	call	eline_no
	xor		a
	ld		(subppc), a
	dec		a
	ld		(errnr), a
	jr		line_null

stmtlp:
	rst		next_ch

line_null:
	call	setwork					; sam
	inc		(iy + _subppc)			;
	jp		m, report_c
	rst		get_ch
	ld		b, 0
	cp		ctrl_n_l
	jr		z, lineend
	cp		':'						; sam
	jr		z, stmtlp				;
	ld		hl, nextstat			; was de
	push	hl						; was de
	ld		c, a					; zx81
	rst		next_ch					;
	ld		a, c					;
	sub		tk_deffn				;
	call	c, l0bb6				; se
	ld		c, a					; zx81
	ld		hl, syntax				;
	add		hl, bc					;
	ld		c, (hl)					;
	add		hl, bc					;
	jr		get_param				;
									;
scan_loop:							;
	ld		hl, (taddr)				;
									;
get_param:							;
	ld		a, (hl)					;
	inc		hl						;
	ld		(taddr), hl				;
	ld		bc, scan_loop			;
	push	bc						;
	ld		c, a					;
	cp		' '						;
	jr		nc, separator			;
	ld		hl, command				;
	ld		b, 0					;
	add		hl, bc					;
	ld		c, (hl)					;
	add		hl, bc					;
	push	hl						;
	rst		get_ch					;
	dec		b
	ret								; zx81
									;
separator:							;
	rst		get_ch					;
	cp		c						;
	jp		nz, report_c			;
	rst		next_ch					;
	ret								;

nextstat:							; sam
	call	break_1					;
	jr		c, l1b7d
	rst		error_1					; sam
	defb	BREAK_into_program		;

l1b7d:
	bit		7, (iy + _nsppc)
	jr		nz, stmtnext1
	ld		hl, (newppc)
	bit		7, h
	jr		z, l1b9e

linerun:							; sam
	ld		hl, 0xfffe				;
	ld		(ppc), hl				;
	ld		hl, (worksp)			;
	dec		hl						;
	ld		de, (eline)
	dec		de
	ld		a, (nsppc)
	jr		next_line

l1b9e:
	call	line_addr
	ld		a, (nsppc)
	jr		z, lineuse
	and		a
	jr		nz, statlost
	ld		a, (hl)
	and		%11000000
	jr		z, lineuse
	rst		error_1					; sam
	defb	OK						;

l1bb0:								; se
	defb	"AW"					;

rem:								; sam
	pop		af						;

lineend:
	call	syntax_z
	ret		z
	ld		hl, (nxtline)
	ld		a, 192
	and		(hl)
	ret		nz
	xor		a

lineuse:							; sam
	cp		1						;
	adc		a, 0					;
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	inc		hl						;
	ld		(ppc), de				;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ex		de, hl					;
	add		hl, de
	inc		hl

next_line:							; zx81
	ld		(nxtline), hl			;
	ex		de, hl					;
	ld		(chadd), hl
	ld		e, 0
	ld		d, a
	ld		(iy + _nsppc), 255
	dec		d
	ld		(iy + _subppc), d
	jp		z, stmtlp
	inc		d
	call	skipstats				; sam
	jr		z, stmtnext1			;
									;
statlost:							;
	rst		error_1					;
	defb	Missing_statement		;

check_end:							; zx81
	call	syntax_z				;
	ret		nz						;
	pop		bc						;
	pop		bc

stmtnext1:
	rst		get_ch
	cp		ctrl_n_l
	jr		z, lineend
	cp		':'						; sam
	jp		z, stmtlp				;
	rst		error_1					;
	defb	Syntax_error			;

command:							; zx81
	defb	class_0 - $				;
	defb	class_1 - $				;
	defb	class_2 - $				;
	defb	class_3 - $				;
	defb	class_4 - $				;
	defb	class_5 - $				;
	defb	class_6 - $				;
	defb	class_7 - $				; sam
	defb	class_8 - $				;
	defb	class_9 - $				;
	defb	class_a - $				;
	defb	class_b - $				;
	defb	class_c - $				;

class_3:
	call	l1cde

class_0:							; zx81
	cp		a						;
									;
class_5:							;
	pop		bc						;
	call	z, check_end			;
	ex		de, hl					;
	ld		hl, (taddr)				;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	ex		de, hl					;
	push	bc						;
	ret								;
									;
class_1:							;
	call	look_vars				;
									;
class_4_2:							;
	ld		(iy + _flage), 0		;
	jr		nc, set_stk				;
	set		1, (iy + _flage)		;
	jr		nz, set_strln			;
									;
report_2:							;
	rst		error_1					;
	defb	Undefined_variable		;
									;
set_stk:							;
	call	z, stk_var				;
	bit		6, (iy + _flags)		;
	jr		nz, set_strln			;
	xor		a						;
	call	syntax_z				;
	call	nz, stk_fetch			;
	ld		hl, flage				;
	or		(hl)					;
	ld		(hl), a					;
	ex		de, hl					;
									;
set_strln:							;
	ld		(stril), bc				;
	ld		(dest), hl				;
	ret								;
									;
class_2:							;
	pop		bc						;
	jr		l1cb9

class_c:							; se
	call	class_6					;
	jr		class_0					;

l1c56:								; zx81
	ld		a, (flags)				;
									;
input_rep:							;
	push	af						;
	call	scanning				;
	pop		af						;
	ld		d, (iy + _flags)		;
	xor		d						;
	and		%01000000				;
	jr		nz, report_c			;
	bit		7, d					;
	jp		nz, let
	ret

class_4:							; zx81
	call	look_vars				;
	push	af						;
	ld		a, c					;
	or		%10011111				;
	inc		a						;
	jr		nz, report_c			;
	pop		af						;
	jr		class_4_2				;

sexpt2nums:							; sam
	rst		next_ch					;
									;
class_8:							;
	call	class_6					;
	cp		','						;
	jr		nz, report_c			;
									;
sexpt1num:							;
	rst		next_ch					;

class_6:							; zx81
	call	scanning				;
	bit		6, (iy + _flags)		;
	ret		nz						;
									;
report_c:							;
	rst		error_1					;
	defb	Syntax_error			;

class_a:							; sam
	call	scanning				;
	bit		6, (iy + _flags)
	ret		z
	jr		report_c

class_7:							; se
	call	syntax_z				;
	call	nz, streamfe
	pop		af
	ld		a, (taddr)
;		sub		p_pen - (tk_pen - 1) % 256 ; not supported by binutils
	sub		0x39
	call	cotemp4
	call	check_end
	ld		hl, (attrt)
	ld		(attrp), hl
	ld		hl, pflag
	ld		a, (hl)					; skel
	rlca							;
	xor		(hl)					;
	and		%10101010				;
	xor		(hl)					;
	ld		(hl), a					;
	ret								;

l1cb9:								; se
	call	l1c56					;
	jr		l1cd7					;

class_9:
	call	syntax_z
	jr		z, l1cd2
	call	streamfe
	ld		hl, maskt
	ld		a, (hl)
	or		%11111000
	ld		(hl), a
	res		6, (iy + _pflag)
	rst		get_ch

l1cd2:								; se
	call	citem					;
	jr		class_8					;
									;
l1cd7:								;
	call	check_end				;
	ret								;

class_b:
	jp		l0605

l1cde:
	cp		ctrl_n_l
	jr		z, no_to_stk
	cp		':'
	jr		nz, class_6				; zx81
									;
no_to_stk:							;
	call	syntax_z				;
	ret		z						;
	fwait							;
	fstk0							;
	fce								;
	ret								;
									;
stop:								;
	rst		error_1					;
	defb	STOP_statement			;

_if:								; se
	pop		bc						;
	call	syntax_z				; zx81
	jr		z, l1d00				;
	fwait							;
	fdel							;
	fce								;
	ex		de, hl					; se
	call	tstzero					;
	jp		c, lineend				;

l1d00:
	jp		line_null

for:								; zx81
	cp		tk_step					;
	jr		nz, use_one				;
	rst		next_ch					;
	call	class_6					;
	call	check_end				;
	jr		reorder					;
									;
use_one:							;
	call	check_end				;
	fwait							;
	fstk1							;
	fce								;
									;
reorder:							;
	fwait							;
	fst		0						;
	fdel							;
	fxch							;
	fgt		0						;
	fxch							;
	fce								;
	call	let						;
	ld		(mem), hl				;
	dec		hl						;
	ld		a, (hl)					;
	set		7, (hl)					;
	ld		bc, 6					;
	add		hl, bc					;
	rlca							;
	jr		c, lmt_step				;
	ld		c, 13
	call	make_room				; zx81
	inc		hl						;
									;
lmt_step:							;
	push	hl						;
	fwait							;
	fdel							;
	fdel							;
	fce								;
	pop		hl						;
	ex		de, hl					;
	ld		c, 10					;
	ldir							;
	ld		hl, (ppc)				;
	ex		de, hl					;
	ld		(hl), e					;
	inc		hl						;
	ld		(hl), d					;
	ld		d, (iy + _subppc)
	inc		hl
	inc		d
	ld		(hl), d
	call	next_loop				; zx81
	ret		nc						;
	ld		a, (subppc)
	ld		hl, (ppc)
	ld		(newppc), hl
	ld		b, (iy + _stril)
	neg
	ld		hl, (chadd)
	ld		d, a
	ld		e, tk_next

l1d64:
	push	bc
	ld		bc, (nxtline)
	call	l1d86
	ld		(nxtline), bc
	pop		bc
	jr		c, l1d84
	rst		next_ch
	or		%00100000
	cp		b
	jr		z, l1d7c
	rst		next_ch
	jr		l1d64

l1d7c:
	rst		next_ch
	ld		a, 1
	sub		d
	ld		(nsppc), a
	ret

l1d84:								; sam
	rst		error_1					;
	defb	FOR_without_NEXT		;

l1d86:
	ld		a, (hl)
	cp		':'
	jr		z, l1da3

l1d8b:
	inc		hl
	ld		a, (hl)
	and		%11000000
	scf
	ret		nz
	ld		b, (hl)
	inc		hl
	ld		c, (hl)
	ld		(newppc), bc
	inc		hl
	ld		c, (hl)
	inc		hl
	ld		b, (hl)
	push	hl
	add		hl, bc
	ld		c, l
	ld		b, h
	pop		hl
	ld		d, 0

l1da3:
	push	bc
	call	skipstats
	pop		bc
	ret		nc
	jr		l1d8b

next:								; zx81
	bit		1, (iy + _flage)		;
	jp		nz, report_2			;
	ld		hl, (dest)				;
	bit		7, (hl)					;
	jr		z, report_1				;
	inc		hl						;
	ld		(mem), hl				;
	fwait							;
	fgt		0						;
	fgt		2						;
	fadd							;
	fst		0						;
	fdel							;
	fce								;
	call	next_loop				;
	ret		c						;
	ld		hl, (mem)				;
	ld		de, 15					;
	add		hl, de					;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	inc		hl						;
	ld		h, (hl)					;
	ex		de, hl					;
	jp		goto_2					;
									;
report_1:							;
	rst		error_1					;
	defb	NEXT_without_FOR		;
									;
next_loop:							;
	fwait							;
	fgt		1						;
	fgt		0						;
	fgt		2						;
	fcp		.lz						;
	fjpt	lmt_v_val				;
	fxch							;
									;
lmt_v_val:							;
	fsub							;
	fcp		.gz						;
	fjpt	imposs					;
	fce								;
	and		a						;
	ret								;
									;
imposs:								;
	fce								;
	scf								;
	ret								;

l1dec:
	rst		next_ch

l1ded:
	call	class_1
	call	syntax_z
	jr		z, l1e1e
	rst		get_ch					; sam
	ld		(xptr), hl				;
	ld		hl, (datadd)
	ld		a, (hl)
	cp		44
	jr		z, l1e0a
	ld		e, tkdata
	call	l1d86
	jr		nc, l1e0a
	rst		error_1					; sam
	defb	End_of_DATA				;

l1e0a:
	call	cursor_so
	call	l1c56
	rst		get_ch
	ld		(datadd), hl
	ld		hl, (xptr)
	ld		(iy + _xptr_h), 0
	call	temp_ptr

l1e1e:
	rst		get_ch
	cp		44
	jr		z, l1dec
	call	check_end
	ret

l1e27:
	call	syntax_z
	jr		nz, l1e37

l1e2c:
	call	scanning
	cp		44
	call	nz, check_end
	rst		next_ch
	jr		l1e2c

l1e37:
	ld		a, tkdata

l1e39:
	ld		b, a
	cpdr
	ld		de, 0x0200
	jp		skipstats

restore:							; sam
	call	syntax3					;

restorez:
	ld		l, c
	ld		h, b
	call	line_addr
	dec		hl
	ld		(datadd), hl			; sam
	ret								;

rand:								; zx81
	call	find_int				;
	ld		a, b					;
	or		c						;
	jr		nz, set_seed			;
	ld		bc, (frames)			;
									;
set_seed:							;
	ld		(seed), bc				;
	ret								;
									;
cont:								;
	ld		hl, (coppc)				;
	ld		d, (iy + _cosppc)
	jr		goto_2					; zx81
									;
goto:								;
	call	syntax3					; se
	ld		h, b					; zx81
	ld		l, c					;
	ld		d, 0					;
	ld		a, h					;
	cp		240						;
	jr		nc, report_b1			;

goto_2:								; sam
	ld		(iy + _nsppc), d		; was a
	ld		(newppc), hl			;
	ret								;
									;
_out:								;
	call	poke1					;
	out		(c), a					;
	ret								;

poke:								; zx81
	call	poke1					;
	ld		(bc), a					;
	ret								;
									;
poke1:								;
	call	fp_to_a					;
	jr		c, report_b1			;
	jr		z, poke_save			;
	neg								;
									;
poke_save:							;
	push	af						;
	call	find_int				;
	pop		af						;
	ret								;

getbyte:							; sam
	call	fp_to_a					;
	jr		getibc					;

find_int:							; zx81
	call	fp_to_bc				;
									;
getibc:								;
	jr		c, report_b1			;
	ret		z						;
									;
report_b1:							;
	rst		error_1					;
	defb	Integer_out_of_range	;
									;
run:								;
	call	goto					;
	ld		bc, 0
	call	restorez				; sam
	jr		clr1					;

clear:
	call	find_int

clr1:
	ld		a, c
	or		b
	jr		nz, clr3				; sam
	ld		bc, (ramtop)			; was hl
									;
clr3:								;
	push	bc						;
	ld		hl, (eline)
	ld		de, (vars)
	dec		hl
	call	reclaim_1
	call	l1344
	ld		de, 50
	ld		hl, (stkend)
	add		hl, de
	pop		de
	sbc		hl, de
	jr		nc, rterr
	and		a
	ld		hl, (pramt)
	sbc		hl, de
	jr		nc, clr4

rterr:								; sam
	rst		error_1					;
	defb	Bad_CLEAR_address		;

clr4:
	ex		de, hl
	ld		(ramtop), hl			; sam
	pop		de						; was hl
	pop		bc						;
	ld		(hl), 0x3e
	dec		hl
	ld		sp, hl
	push	bc						; sam
	ld		(errsp), sp				;
	ex		de, hl
	jp		(hl)

gosub:
	pop		de
	ld		h, (iy + _subppc)
	inc		h
	ex		(sp), hl
	inc		sp
	ld		bc, (ppc)
	push	bc
	push	hl
	ld		(errsp), sp
	push	de
	call	goto
	ld		bc, 20

test_room:							; zx81
	ld		hl, (stkend)			;
	add		hl, bc					;
	jr		c, report_4				;
	ex		de, hl					;
	ld		hl, 0x0050				;
	add		hl, de					;
	jr		c, report_4
	sbc		hl, sp					; zx81
	ret		c						;
									;
report_4:							;
	ld		l, Out_of_memory		;
	jp		error_3					;

l1f1a:								; se
	ld		a, (flags)				;
	and		%11110111				;
									;
l1f1f:								;
	ld		(flags), a				;
	ret								;

return:
	pop		bc
	pop		hl
	pop		de
	ld		a, d
	cp		0x3e
	jr		z, report_7
	dec		sp
	ex		(sp), hl
	ex		de, hl
	ld		(errsp), sp
	push	bc
	jp		goto_2

report_7:
	push	de
	push	hl						; zx81
	rst		error_1					;
	defb	RETURN_without_GOSUB	;

pause:								; se
	call	l0abc					;

pau1:								; sam
	halt							;
	dec		bc
	ld		a, b					; sam
	or		c						;
	jr		z, pau2					;
	ld		a, c
	and		b
	inc		a
	jr		nz, l1f49
	inc		bc

l1f49:
	bit		5, (iy + _flags)
	jr		z, pau1

pau2:
	res		5, (iy + _flags)
	ret

break_1:							; zx81
	ld		a, 127					;
	in		a, (ula)				;
	rra								;
	ret		c
	ld		a, 254
	in		a, (ula)
	rra
	ret

l1f60:
	call	syntax_z
	jr		z, l1f6a
	ld		a, tk_deffn
	jp		l1e39

l1f6a:
	set		6, (iy + _flags)
	call	alpha
	jr		nc, l1f89
	rst		next_ch
	cp		'$'
	jr		nz, l1f7d
	res		6, (iy + _flags)
	rst		next_ch

l1f7d:
	cp		'('
	jr		nz, l1fbd
	rst		next_ch
	cp		')'
	jr		z, l1fa6

l1f86:
	call	alpha

l1f89:
	jp		nc, report_c
	ex		de, hl
	rst		next_ch
	cp		'$'
	jr		nz, l1f94
	ex		de, hl
	rst		next_ch

l1f94:
	ex		de, hl
	ld		bc, 6
	call	make_room
	inc		hl
	inc		hl
	ld		(hl), ctrl_number
	cp		','
	jr		nz, l1fa6
	rst		next_ch
	jr		l1f86

l1fa6:
	cp		')'
	jr		nz, l1fbd
	rst		next_ch
	cp		'='
	jr		nz, l1fbd
	rst		next_ch
	ld		a, (flags)
	push	af
	call	scanning
	pop		af
	xor		(iy + _flags)
	and		%01000000

l1fbd:
	jp		nz, report_c
	call	check_end

unstack_z:							; zx81
	call	syntax_z				;
	pop		hl						;
	ret		z						;
	jp		(hl)					;

lprint:								; sam
	ld		a, 3					; was c
	jr		l1fcf					;
									;
print:								;
	ld		a, 2					; was c
									;
l1fcf:								;
	call	syntax_z				;
	call	nz, l1601
	call	trcurp
	call	print2
	call	check_end
	ret

print2:								; sam
	rst		get_ch					;
	call	prterm					;
	jr		z, print3				;
									;
mprseplp:							;
	call	prsepr				 	;
	jr		z, mprseplp
	call	pritem					; sam
	call	prsepr					;
	jr		z, mprseplp

print3:								; sam
	cp		')'						;
	ret		z						;

prcifrn:
	call	unstack_z
	ld		a, ctrl_n_l
	rst		print_a
	ret

pritem:								; sam
	rst		get_ch					;
	cp		tk_at					; was tk_tab
	jr		nz, pritem2				;
	call	sexpt2nums
	call	unstack_z
	call	stk_to_bc
	ld		a, ctrl_at				; sam
	jr		atsr4					;
									;
pritem2:							;
	cp		tk_tab					; was tk_at
	jr		nz, pritem4				;
	rst		next_ch
	call	class_6
	call	unstack_z
	call	find_int
	ld		a, ctrl_tab

atsr4:								; sam
	rst		print_a					;
	ld		a, c					; was a, d
	rst		print_a					;
	ld		a, b					; was a, e
	rst		print_a					;
	ret								;
									;
pritem4:							;
	call	citemsr					;
	ret		nc						;
	call	l2070
	ret		nc
	call	scanning
	call	unstack_z
	bit		6, (iy + _flags)
	call	z, stk_fetch
	jp		nz, print_fp

l203c:
	ld		a, b
	or		c
	dec		bc
	ret		z
	ld		a, (de)
	inc		de
	rst		print_a
	jr		l203c

prterm:								; sam
	cp		')'						;
	ret		z						;

l2048:
	cp		ctrl_n_l
	ret		z
	cp		':'						; sam
	ret								;
									;
prsepr:								;
	rst		get_ch					;
	cp		';'						;
	jr		z, prserp3				;
	cp		','						;
	jr		nz, l2061
	call	syntax_z
	jr		z, prserp3
	ld		a, ctrl_comma
	rst		print_a
	jr		prserp3

l2061:								; sam
	cp		0x27					; binutils doesn't like cp "'"
	ret		nz						;
	call	prcifrn					;
									;
prserp3:							;
	rst		next_ch					;
	call	prterm
	jr		nz, l206e
	pop		bc

l206e:
	cp		a
	ret

l2070:
	cp		'#'
	scf
	ret		nz
	rst		next_ch
	call	class_6
	and		a
	call	unstack_z

l207c:
	call	getbyte
	cp		16
	jp		nc, invstrm
	call	l1601
	and		a
	ret

input:
	call	syntax_z
	jr		z, l2096
	call	clslower
	ld		a, 1
	call	l1601

l2096:
	ld		(iy + _dflag), 1
	call	ipitem
	call	check_end
	ld		bc, (sposnu)
	ld		a, (dfsz)
	cp		b
	jr		c, l20ad
	ld		b, a
	ld		c, 33

l20ad:
	ld		(sposnu), bc
	ld		a, 25
	sub		b
	ld		(scrct), a
	res		0, (iy + _dflag)
	call	l0dd9
	jp		clslower

ipitem:
	call	prsepr
	jr		z, ipitem
	cp		'('						; sam
	jr		nz, inp2				;
	rst		next_ch					;
	call	print2					;
	rst		get_ch					;
	cp		')'
	jp		nz, report_c
	rst		next_ch
	jp		l21b2

inp2:								; sam
	cp		tk_line					;
	jr		nz, l20ed
	rst		next_ch
	call	class_1
	set		7, (iy + _flage)
	bit		6, (iy + _flags)
	jp		nz, report_c
	jr		l20fa

l20ed:
	call	alpha					; sam
	jp		nc, l21af				;
	call	class_1
	res		7, (iy + _flage)

l20fa:
	call	syntax_z
	jp		z, l21b2
	call	setwork
	ld		bc, 1
	ld		hl, flage
	set		5, (hl)
	res		6, (hl)
	bit		7, (hl)
	jr		nz, l211c
	ld		a, (flags)
	and		%01000000
	jr		nz, prompt				; zx81
	ld		c, 3					; was 4
									;
prompt:								;
	or		(hl)					;
	ld		(hl), a					;
									;
l211c:								;
	rst		bc_spaces				;
	ld		(hl), ctrl_n_l			;
	ld		a, c					;
	rrca							;
	rrca							;
	jr		nc, inp7
	ld		a, '"'					; zx81
	ld		(de), a					;
	dec		hl						;
	ld		(hl), a					;

inp7:
	ld		(kcur), hl
	bit		7, (iy + _flage)
	jr		nz, inp9
	ld		hl, (chadd)				; sam
	push	hl						;
	ld		hl, (errsp)				;
	push	hl						;
									;
inperr:								;
	ld		hl, inperr				;
	push	hl						;
	bit		4, (iy + _klflag)
	jr		z, l2148
	ld		(errsp), sp

l2148:
	ld		hl, (worksp)
	call	l11a7
	ld		(iy + _errnr), OK
	call	editor
	res		7, (iy + _flags)		; sam
	call	inpas					;
	jr		l2161

inp9:								; sam
	call	editor					;

l2161:
	ld		(iy + _kcur_h), 0
	call	chltchk
	jr		nz, l2174
	call	l111d
	ld		bc, (echoe)
	call	l0dd9

l2174:
	ld		hl, flage
	res		5, (hl)
	bit		7, (hl)
	res		7, (hl)
	jr		nz, l219b
	pop		hl
	pop		hl
	ld		(errsp), hl
	set		7, (iy + _flags)
	pop		hl
	ld		(xptr), hl
	call	inpas
	ld		hl, (xptr)
	ld		(iy + _xptr_h), 0
	ld		(chadd), hl
	jr		l21b2

l219b:
	ld		hl, (stkbot)
	ld		de, (worksp)
	scf
	sbc		hl, de
	ld		c, l
	ld		b, h
	call	stk_store
	call	let
	jr		l21b2

l21af:
	call	pritem

l21b2:
	call	prsepr
	jp		z, ipitem
	ret

inpas:								; sam
	ld		hl, (worksp)			;
	ld		(chadd), hl				;
	rst		get_ch					;
	cp		tk_stop					;
	jr		z, l21d0
	ld		a, (flage)
	call	input_rep
	rst		get_ch
	cp		ctrl_n_l
	ret		z
	rst		error_1					; sam
	defb	Syntax_error			;

l21d0:
	call	syntax_z
	ret		z
	rst		error_1					; sam
	defb	STOP_in_INPUT			;

chltchk:
	ld		hl, (curchl)
	inc		hl
	inc		hl						; sam
	inc		hl						;
	inc		hl						;
	ld		a, (hl)					;
	cp		'K'						;
	ret

l21e1:
	rst		next_ch

citem:								; sam
	call	citemsr					;
	ret		c						;
	rst		get_ch
	cp		';'
	jr		z, l21e1
	cp		','
	jr		z, l21e1
	jp		report_c

citemsr:							; sam
	cp		tk_pen					;
	ret		c						;
	cp		tk_out					;
	ccf								;
	ret		c						;
	ld		c, a					;
	rst		next_ch					;
	ld		a, c					;
									;
cotemp4:							;
	sub		tk_pen - 16				;
	push	af						;
	call	class_6					;
	pop		af
	and		a
	call	unstack_z
	push	af
	call	getbyte					; sam
	ld		d, a					;
	pop		af						;
	rst		print_a
	ld		a, d
	rst		print_a
	ret

l2211:
	sub		17
	adc		a, 0
	jr		z, l2234
	sub		2
	adc		a, 0
	jr		z, l2273
	cp		1
	ld		b, 1
	ld		a, d
	jr		nz, coinverse
	rlca
	rlca
	ld		b, 4

coinverse:
	ld		c, a
	ld		a, d					; sam
	cp		2						;
	jr		nc, invcolerr			;
	ld		a, c
	ld		hl, pflag
	jr		cochng

l2234:
	ld		a, d
	ld		b, %00000111
	jr		c, l223e
	rlca
	rlca
	rlca
	ld		b, %00111000

l223e:
	ld		c, a
	ld		a, d
	cp		10
	jr		c, l2246

invcolerr:							; sam
	rst		error_1					;
	defb	Bad_colour				;

l2246:
	ld		hl, attrt
	cp		8
	jr		c, l2258
	ld		a, (hl)
	jr		z, l2257
	or		b
	cpl
	and		%00100100
	jr		z, l2257
	ld		a, b

l2257:
	ld		c, a

l2258:
	ld		a, c
	call	cochng
	ld		a, 7
	cp		d
	sbc		a, a
	call	cochng
	rlca
	rlca
	and		%01010000
	ld		b, a
	ld		a, 8
	cp		d
	sbc		a, a

cochng:								; sam
	xor		(hl)					;
	and		b						; was c
	xor		(hl)					;
	ld		(hl), a					;
	ld		a, b					; was c
	inc		hl						;
	ret								;

l2273:
	sbc		a, a
	ld		a, d
	rrca
	ld		b, %10000000
	jr		nz, l227d
	rrca
	ld		b, %01000000

l227d:
	ld		c, a
	ld		a, d
	cp		8
	jr		z, cofbok
	cp		2
	jr		nc, invcolerr

cofbok:
	ld		a, c
	ld		hl, attrt				; sam
	call	cochng					;
	ld		a, c					; was b
	rrca							;
	rrca							;
	rrca							;
	jr		cochng					;

l2294:
	call	getbyte
	cp		8
	jr		nc, invcolerr
	out		(ula), a				; skel
	rlca							;
	rlca							;
	rlca							;
	bit		5, a					;
	jr		nz, l22a6				;
	xor		%00000111				;
									;
l22a6:								;
	ld		(bordcr), a				;
	ret								;

l22aa:
	ld		a, 175
	sub		b
	jp		c, report_b
	ld		b, a
	and		a						; skel
	rra								;
	scf								;
	rra								;
	and		a						;
	rra								;
	xor		b						;
	and		%11111000				;
	xor		b						;
	ld		h, a					;
	ld		a, c					;
	rlca							;
	rlca							;
	rlca							;
	xor		b						;
	and		%11000111				;
	xor		b						;
	rlca							;
	rlca							;
	ld		l, a					;
	ld		a, c					;
	and		%00000111				;
	ret								;

l22cb:
	call	l3915
	call	l22aa
	inc		a
	ld		b, a
	ld		a, (hl)

l22d4:
	rlca
	djnz	l22d4
	and		%00000001
	jp		stack_a

plot:
	call	l3915
	call	l22e5
	jp		trcurp

l22e5:
	ld		(xcoord), bc
	call	l22aa
	inc		a
	ld		b, a
	ld		a, %11111110

l22f0:
	rrca
	djnz	l22f0
	ld		b, a
	ld		a, (hl)
	ld		c, (iy + _pflag)
	bit		0, c
	jr		nz, l22fd
	and		b

l22fd:
	bit		2, c
	jr		nz, l2303
	xor		b
	cpl

l2303:
	ld		(hl), a
	jp		l0bdb

stk_to_bc:							; zx81
	call	stk_to_a				;
	ld		b, a					;
	push	bc						;
	call	stk_to_a				;
	ld		e, c					;
	pop		bc						;
	ld		d, c					;
	ld		c, a					;
	ret								;
									;
stk_to_a:							;
	call	fp_to_a					;
	jp		c, report_b				;
	ld		c, 1					;
	ret		z						;
	ld		c, 255					;
	ret								;

circle:
	rst		get_ch
	cp		','
	jp		nz, report_c
	rst		next_ch
	call	class_6
	call	check_end
	fwait
	fabs
	frstk
	fce
	ld		a, (hl)
	cp		129
	jr		nc, l233b
	fwait
	fdel
	fce
	jr		plot

l233b:
	fwait
	fstkpix_5
	fce
	ld		(hl), 131
	fwait
	fst		5
	fdel
	fce
	call	l247d
	push	bc
	fwait
	fmove
	fgt		1
	fmul
	fce
	ld		a, (hl)
	cp		128
	jr		nc, l235a
	fwait
	fdel
	fdel
	fce
	pop		bc
	jp		plot

l235a:
	fwait
	fst		2
	fxch
	fst		0
	fdel
	fsub
	fxch
	fgt		0
	fadd
	fst		0
	fxch
	fmove
	fgt		0
	fxch
	fmove
	fgt		0
	fstk0
	fst		1
	fdel
	fce
	inc		(iy + _mem_2)
	call	getbyte
	ld		l, a
	push	hl
	call	getbyte
	pop		hl
	ld		h, a
	ld		(xcoord), hl
	pop		bc
	jp		l2405

l2382:
	rst		get_ch
	cp		','
	jr		z, l238d
	call	check_end
	jp		linedraw

l238d:
	rst		next_ch
	call	class_6
	call	check_end
	fwait
	fst		5
	fstk_5
	fmul
	fsin
	fmove
	fnot
	fnot
	fjpt	l23a3
	fdel
	fce
	jp		linedraw

l23a3:
	fst		0
	fdel
	fst		1
	fdel
	fmove
	fabs
	fgt		1
	fxch
	fgt		1
	fabs
	fadd
	fgt		0
	fdiv
	fabs
	fgt		0
	fxch
	fce
	call	l247d
	push	bc
	fwait
	fdel
	fgt		1
	fxch
	fdiv
	fst		1
	fdel
	fxch
	fmove
	fgt		1
	fmul
	fst		2
	fdel
	fxch
	fmove
	fgt		1
	fmul
	fgt		2
	fgt		5
	fgt		0
	fsub
	fstk_5
	fmul
	fmove
	fsin
	fst		5
	fdel
	fcos
	fst		0
	fdel
	fst		2
	fdel
	fst		1
	fgt		5
	fmul
	fgt		0
	fgt		2
	fmul
	fadd
	fgt		1
	fxch
	fst		1
	fdel
	fgt		0
	fmul
	fgt		2
	fgt		5
	fmul
	fsub
	fst		2
	fdel
	fxch
	fce
	ld		a, (xcoord)
	call	stack_a
	fwait
	fst		0
	fadd
	fxch
	fce
	ld		a, (ycoord)
	call	stack_a
	fwait
	fst		5
	fadd
	fgt		0
	fgt		5
	fce
	pop		bc

l2405:
	dec		b
	jr		l2439

l2408:
	ld		a, tk_stop
	call	add_char
	ld		(iy + _errnr), STOP_in_INPUT
	jp		n_l_key

l2414:								; se
	ld		a, (hl)					;
	cp		'0'						;
	ret		nz						;
	ld		(hl), ' '				;
	inc		hl						;
	djnz	l2414					;
	ret								;
									;
l241e:								;
	defb	tk_line					;
	defb	tk_list					;
	defb	tk_llist				;
	defb	tk_goto					;
	defb	tk_gosub				;
	defb	tk_restore				;
	defb	tk_run					;

l2425:
	fwait		
	fgt		1
	fmove
	fgt		3
	fmul
	fgt		2
	fgt		4
	fmul
	fsub
	fst		1
	fdel
	fgt		4
	fmul
	fgt		2
	fgt		3
	fmul
	fadd
	fst		2
	fdel
	fce

l2439:
	push	bc
	fwait
	fst		0
	fdel
	fgt		1
	fadd
	fmove
	fce
	ld		a, (xcoord)
	call	stack_a
	fwait
	fsub
	fgt		0
	fgt		2
	fadd
	fst		0
	fxch
	fgt		0
	fce
	ld		a, (ycoord)
	call	stack_a
	fwait
	fsub
	fce
	call	r1offcl
	pop		bc
	djnz	l2425
	fwait
	fdel
	fdel
	fxch
	fce
	ld		a, (xcoord)
	call	stack_a
	fwait
	fsub
	fxch
	fce
	ld		a, (ycoord)
	call	stack_a
	fwait
	fsub
	fce

linedraw:							; sam
	call	r1offcl					;
	jp		trcurp					;

l247d:
	fwait
	fmove
	fsqrt
	fstk
	defb	0x32, 0x00
	fxch
	fdiv
	fgt		5
	fxch
	fdiv
	fabs
	fce
	call	fp_to_a
	jr		c, l2495
	and		252
	add		a, 4
	jr		nc, l2497

l2495:
	ld		a, 252

l2497:
	push	af
	call	stack_a
	fwait
	fgt		5
	fxch
	fdiv
	fmove
	fsin
	fst		4
	fdel
	fmove
	fstk_5
	fmul
	fsin
	fst		1
	fxch
	fst		0
	fdel
	fmove
	fmul
	fmove
	fadd
	fstk1
	fsub
	fneg
	fst		3
	fdel
	fce
	pop		bc
	ret

r1offcl:
	call	stk_to_bc
	ld		a, c
	cp		b
	jr		nc, l24c4
	xor		a
	ld		l, c
	push	de
	ld		e, a
	jr		l24cb

l24c4:
	or		c
	ret		z
	ld		l, b
	ld		b, c
	push	de
	ld		d, 0

l24cb:
	ld		h, b
	ld		a, b
	rra		

l24ce:
	add		a, l
	jr		c, l24d4
	cp		h
	jr		c, l24db

l24d4:
	sub		h
	ld		c, a
	exx
	pop		bc
	push	bc
	jr		l24df

l24db:
	ld		c, a
	push	de
	exx
	pop		bc

l24df:
	ld		hl, (xcoord)
	ld		a, b
	add		a, h
	ld		b, a
	ld		a, c
	inc		a
	add		a, l
	jr		c, l24f7
	jr		z, report_b

l24ec:
	dec		a
	ld		c, a
	call	l22e5
	exx
	ld		a, c
	djnz	l24ce
	pop		de
	ret

l24f7:
	jr		z, l24ec

report_b:							; zx81
	rst		error_1					;
	defb	Integer_out_of_range	;
									;
scanning:							;
	rst		get_ch					;
	ld		b, 0					;
	push	bc						;

l24ff:
	ld		c, a
	ld		hl, l2596
	call	l0eac
	ld		a, c
	jp		nc, l2684
	ld		c, (hl)
	ld		b, 0
	add		hl, bc
	jp		(hl)

l250f:
	call	ch_add_1
	inc		bc
	cp		ctrl_n_l
	jp		z, report_c
	cp		'"'
	jr		nz, l250f
	call	ch_add_1
	cp		'"'
	ret

l2522:
	rst		next_ch
	cp		'('
	jr		nz, l252d
	call	sexpt2nums
	rst		get_ch
	cp		')'

l252d:
	jp		nz, report_c

syntax_z:
	bit		7, (iy + _flags)
	ret

l2535:								; se
	call	l3909					;

l2538:
	jp		l3898

l253b:								; se
	push	bc						;
	ld		b, 96 + 128				;
	
l253e:
	push	bc
	push	de
	push	hl
	ld		a, (de)
	xor		(hl)
	jr		z, l2549
	inc		a
	jr		nz, l2569
	dec		a

l2549:
	ld		c, a
	ld		b, 7

l254c:
	inc		d
	inc		hl
	ld		a, (de)
	xor		(hl)
	xor		c
	jr		nz, l2569
	djnz	l254c
	pop		bc
	pop		bc
	pop		bc
	pop		hl
	ld		a, h					; se
	dec		h						;
	jr		nz, l2562				;
	ld		a, 144 + 21				;
	jp		l2563					;
									;
l2562:								;
	xor		a						;

l2563:
	sub		b
	call	bc_spaces1
	ld		(de), a
	ret

l2569:
	pop		hl
	ld		de, 8
	add		hl, de
	pop		de
	pop		bc
	djnz	l253e
	pop		bc						; se
	dec		b						;
	jr		z, l257e				;
	push	bc						;
	ld		b, 21					;
	ld		hl, (udg)				;
	jr		l253e					;
									;
l257e:								;
	ld		c, b					;
	ret								;
									;
l2580:								;
	call	l3909					;
	ld		a, c
	rrca
	rrca
	rrca
	ld		c, a
	and		%11100000
	xor		b
	ld		l, a
	ld		a, c
	and		%00000011
	xor		%01011000
	ld		h, a
	ld		a, (hl)
	jp		stack_a

l2596:
	defb	'"', l25b3 - $
	defb	'(', l25e8 - $
	defb	'.', s_decimal - $
	defb	'+', l25af - $
	defb	tk_fn, l25f5 - $
	defb	tk_rnd, s_rnd -  $
	defb	tk_pi, s_pi - $
	defb	tk_inkey_str, iminkeys - $
	defb	tk_bin, s_decimal - $
	defb	tk_screen_str, l2668 - $
	defb	tk_attr, l2672 - $
	defb	tk_point, l267b - $
	defb	0

l25af:
	rst		next_ch
	jp		l24ff

l25b3:
	rst		get_ch
	inc		hl
	push	hl
	ld		bc, 0
	call	l250f
	jr		nz, l25d9

l25be:
	call	l250f
	jr		z, l25be
	call	syntax_z
	jr		z, l25d9
	rst		bc_spaces
	pop		hl
	push	de

l25cb:
	ld		a, (hl)
	inc		hl
	ld		(de), a
	inc		de
	cp		'"'
	jr		nz, l25cb
	ld		a, (hl)
	inc		hl
	cp		'"'
	jr		z, l25cb

l25d9:
	dec		bc
	pop		de

s_string:							; zx81
	ld		hl, flags				;
	res		6, (hl)					;
	bit		7, (hl)					;
	call	nz, stk_store			;
	jp		s_cont_2				; was s_cont_3

l25e8:
	rst		next_ch
	call	scanning
	cp		')'
	jp		nz, report_c
	rst		next_ch
	jp		s_cont_2

l25f5:
	jp		l27bd

s_rnd:								; zx81
	call	syntax_z				;
	jr		z, s_rnd_end			;
	ld		bc, (seed)				;
	call	stack_bc1				;
	fwait							;
	fstk1							;
	fadd							;
	fstk							;
	defb	0x37, 0x16				;
	fmul							;
	fstk							;
	defb	0x80, 0x41, 0x00, 0x00, 0x80
	fmod							;
	fdel							;
	fstk1							;
	fsub							;
	fmove							;
	fce								;
	call	fp_to_bc				;
	ld		(seed), bc				;
	ld		a, (hl)					;
	and		a						;
	jr		z, s_rnd_end			;
	sub		16						;
	ld		(hl), a					;
									;
s_rnd_end:							;
	jr		s_pi_end				;
									;
s_pi:								;
	call	syntax_z				;
	jr		z, s_pi_end				;
	fwait							;
	fstkpix_5						;
	fce								;
	inc		(hl)					;
									;
s_pi_end:							;
	rst		next_ch					;
	jp		s_numeric				;

iminkeys:
	ld		bc, 0x105a
	rst		next_ch					; sam
	cp		'#'						;
	jp		z, s_push_po
	ld		hl, flags
	res		6, (hl)
	bit		7, (hl)
	jr		z, l2665
	call	keyboard
	ld		c, 0
	jr		nz, l2660
	call	l031e
	jr		nc, l2660
	ld		e, a
	dec		d
	call	l0333
	ld		bc, 1
	push	af
	rst		bc_spaces
	pop		af
	ld		c, 1
	ld		(de), a

l2660:
	ld		b, 0
	call	stk_store

l2665:
	jp		s_cont_2

l2668:
	call	l2522
	call	nz, l2535
	rst		next_ch
	jp		s_string

l2672:
	call	l2522
	call	nz, l2580
	rst		next_ch
	jr		s_numeric

l267b:
	call	l2522
	call	nz, l22cb
	rst		next_ch
	jr		s_numeric

l2684:
	call	alphanum
	jr		nc, l26df
	cp		'A'
	jr		nc, s_let_num

s_decimal:							; zx81
	call	syntax_z				;
	jr		nz, s_stk_dec			;
	call	dec_to_fp				;
									;
l2695:								;
	rst		get_ch					;
	ld		bc, 6					;
	call	make_room				;
	inc		hl						;
	ld		(hl), ctrl_number		;
	inc		hl						;
	ex		de, hl					;
	ld		hl, (stkend)			;
	ld		c, 5					;
	and		a						;
	sbc		hl, bc					;
	ld		(stkend), hl			;
	ldir							;
	ex		de, hl					;
	dec		hl						;
	call	cursor_so				;
	jr		s_numeric				;

s_stk_dec:
	rst		get_ch

l26b6:
	inc		hl
	ld		a, (hl)
	cp		ctrl_number				; zx81
	jr		nz, l26b6				;
	inc		hl						;
	call	l33b8					;
	ld		(chadd), hl

s_numeric:							; zx81
	set		6, (iy + _flags)		;
	jr		l26dd					;
									;
s_let_num:							;
	call	look_vars				;
	jp		c, report_2				;
	call	z, stk_var				;
	ld		a, (flags)				;
	cp		%11000000				;
	jr		c, l26dd				; was s_cont_2
	inc		hl						;
	call	l33b8

l26dd:
	jr		s_cont_2		

l26df:
	ld		bc, 0x09db
	cp		'-'
	jr		z, s_push_po
	ld		bc, 0x1018
	cp		tk_val_str
	jr		z, s_push_po
	sub		tk_code
	jp		c, report_c
	ld		bc, 0x04f0
	cp		20
	jr		z, s_push_po
	jp		nc, report_c
	add		a, 220
	ld		c, a
	ld		b, 16
	cp		223
	jr		nc, s_no_to_s
	res		6, c

s_no_to_s:							; zx81
	cp		238						;
	jr		c, s_push_po			;
	res		7, c					;
									;
s_push_po:							;
	push	bc						;
	rst		next_ch					;
	jp		l24ff

s_cont_2:							; zx81
	rst		get_ch					;
									;
s_cont_3:							;
	cp		'('						;
	jr		nz, s_opertr 			;
	bit		6, (iy + _flags)		;
	jr		nz, s_loop				;
	call	slicing					;
	rst		next_ch					;
	jr		s_cont_3				;

s_opertr:
	ld		hl, l2795
	ld		b, 0
	ld		c, a
	call	l16dc
	jr		nc, s_loop
	ld		c, (hl)
	ld		hl, priority - 195		; zx81
	add		hl, bc					;
	ld		b, (hl)					;
									;
s_loop:								;
	pop		de						;
	ld		a, d					;
	cp		b						;
	jr		c, s_tighter			;
	and		a						;
	jp		z, _get_ch				;
	push	bc						;
	ld		hl, flags
	ld		a, e
	cp		237
	jr		nz, l274c
	bit		6, (hl)
	jr		nz, l274c
	ld		e, 153

l274c:
	push	de
	call	syntax_z
	jr		z, s_syntest
	ld		a, e
	and		%00111111
	ld		b, a
	fwait
	fsgl
	fce
	jr		s_runtest

s_syntest:							; zx81
	ld		a, e					;
	xor		(iy + _flags)			;
	and		%01000000				;
									;
s_rprt_c2:							;
	jp		nz, report_c			;
									;
s_runtest:							;
	pop		de						;
	ld		hl, flags				;
	set		6, (hl)					;
	bit		7, e					;
	jr		nz, s_endloop			;
	res		6, (hl)					;
									;
s_endloop:							;
	pop		bc						;
	jr		s_loop					;
									;
s_tighter:							;
	push	de						;
	ld		a, c					;
	bit		6, (iy + _flags)		;
	jr		nz, s_next				;
	and		%00111111				;
	add		a, 8					;
	ld		c, a					;
	cp		0x10					;
	jr		nz, s_not_and			;
	set		6, c					;
	jr		s_next					;
									;
s_not_and:							;
	jr		c, s_rprt_c2			;
	cp		0x17					;
	jr		z, s_next				;
	set		7, c					;
									;
s_next:								;
	push	bc						;
	rst		next_ch					;
	jp		l24ff

l2795:
	defb	'+', 0xcf
	defb	'-', 0xc3
	defb	'*', 0xc4
	defb	'/', 0xc5
	defb	'^', 0xc6
	defb	'=', 0xce
	defb	'>', 0xcc
	defb	'<', 0xcd
	defb	tk_l_eql, 0xc9
	defb	tk_gr_eq, 0xca
	defb	tk_neql, 0xcb
	defb	tk_or, 0xc7
	defb	tk_and, 0xc8
	defb	0

priority:							; zx81
	defb	0x06, 0x08, 0x08, 0x0a, 0x02, 0x03, 0x05, 0x05
	defb	0x05, 0x05, 0x05, 0x05, 0x06

l27bd:
	call	syntax_z
	jr		nz, l27f7
	rst		next_ch
	call	alpha
	jp		nc, report_c
	rst		next_ch
	cp		'$'
	push	af
	jr		nz, fnsyn
	rst		next_ch

fnsyn:								; sam
	cp		'('						;
	jr		nz, fnsy5				;
	rst		next_ch					;
	cp		')'						;
	jr		z, fnsy4				;

l27d9:
	call	scanning
	rst		get_ch
	cp		','
	jr		nz, l27e4
	rst		next_ch
	jr		l27d9

l27e4:
	cp		')'

fnsy5:
	jp		nz, report_c

fnsy4:								; sam
	rst		next_ch					;
	ld		hl, flags
	res		6, (hl)
	pop		af
	jr		z, l27f4
	set		6, (hl)

l27f4:
	jp		s_cont_2

l27f7:
	rst		next_ch
	and		%11011111
	ld		b, a
	rst		next_ch
	sub		'$'
	ld		c, a
	jr		nz, l2802
	rst		next_ch

l2802:
	rst		next_ch
	push	hl
	ld		hl, (prog)
	dec		hl

l2808:
	ld		de, 0x00ce
	push	bc
	call	l1d86
	pop		bc
	jr		nc, l2814
	rst		error_1					; sam
	defb	Undefined_FN			;

l2814:
	push	hl
	call	l28ab
	and		%11011111
	cp		b
	jr		nz, l2825
	call	l28ab
	sub		'$'
	cp		c
	jr		z, l2831

l2825:
	pop		hl
	dec		hl
	ld		de, 0x0200
	push	bc
	call	skipstats
	pop		bc
	jr		l2808

l2831:
	and		a
	call	z, l28ab
	pop		de
	pop		de
	ld		(chadd), de
	call	l28ab
	push	hl
	cp		')'
	jr		z, l2885

l2843:
	inc		hl
	ld		a, (hl)
	cp		ctrl_number
	ld		d, 64
	jr		z, l2852
	dec		hl
	call	l28ab
	ld		d, 0
	inc		hl

l2852:
	inc		hl
	push	hl
	push	de
	call	scanfix					; se
	pop		af
	xor		(iy + _flags)
	and		%01000000
	jr		nz, parerr
	pop		hl
	ex		de, hl
	ld		hl, (stkend)
	ld		bc, 5
	sbc		hl, bc
	ld		(stkend), hl
	ldir
	ex		de, hl
	dec		hl
	call	l28ab
	cp		')'
	jr		z, l2885
	push	hl
	rst		get_ch
	cp		','
	jr		nz, parerr
	rst		next_ch
	pop		hl
	call	l28ab
	jr		l2843

l2885:
	push	hl
	rst		get_ch
	cp		')'
	jr		z, l288d

parerr:								; sam
	rst		error_1					;
	defb	Parameter_error			;

l288d:
	pop		de
	ex		de, hl
	ld		(chadd), hl
	ld		hl, (defadd)
	ex		(sp), hl
	ld		(defadd), hl
	push	de
	rst		next_ch
	rst		next_ch
	call	scanning
	pop		hl
	ld		(chadd), hl
	pop		hl
	ld		(defadd), hl
	rst		next_ch
	jp		s_cont_2

l28ab:
	inc		hl
	ld		a, (hl)
	cp		' ' + 1
	jr		c, l28ab
	ret

look_vars:							; zx81
	set		6, (iy + _flags)		;
	rst		get_ch					;
	call	alpha					;
	jp		nc, report_c			;
	push	hl						;
	and		%00011111
	ld		c, a					; zx81
	rst		next_ch					;
	push	hl						;
	cp		'('						;
	jr		z, v_run_syn			;
	set		6, c					;
	cp		'$'						;
	jr		z, v_str_var			;
	set		5, c					;
	call	alphanum				;
	jr		nc, l28e3

v_char:								; zx81
	call	alphanum				;
	jr		nc, v_run_syn			;
	res		6, c					;
	rst		next_ch					;
	jr		v_char					;
									;
v_str_var:							;
	rst		next_ch					;
	res		6, (iy + _flags)		;

l28e3:
	ld		a, (defadd_h)
	and		a
	jr		z, v_run_syn
	call	syntax_z
	jp		nz, l2951

v_run_syn:							; zx81
	ld		b, c					;
	call	syntax_z				;
	jr		nz, v_run				;
	ld		a, c					;
	and		%11100000				;
	or		%10000000				;
	ld		c, a					;
	jr		v_syntax				;
									;
v_run:								;
	ld		hl, (vars)				;
									;
v_each:								;
	ld		a, (hl)					;
	and		%01111111				;
	jr		z, v_80_byte			;
	cp		c						;
	jr		nz, v_next				;
	rla								;
	add		a, a					;
	jp		p, v_found_2			;
	jr		c, v_found_2			;
	pop		de						;
	push	de						;
	push	hl						;
									;
v_matches:							;
	inc		hl						;
									;
v_spaces:							;
	ld		a, (de)					;
	inc		de						;
	cp		' '						;
	jr		z, v_spaces				;
	or		%00100000				;
	cp		(hl)					;
	jr		z, v_matches			;
	or		%10000000				;
	cp		(hl)					;
	jr		nz, v_get_ptr			;
	ld		a, (de)					;
	call	alphanum				;
	jr		nc, v_found_1			;
									;
v_get_ptr:							;
	pop		hl						;
									;
v_next:								;
	push	bc						;
	call	next_one				;
	ex		de, hl					;
	pop		bc						;
	jr		v_each					;
									;
v_80_byte:							;
	set		7, b					;
									;
v_syntax:							;
	pop		de						;
	rst		get_ch					;
	cp		'('						;
	jr		z, v_pass				;
	set		5, b					;
	jr		v_end					;
									;
v_found_1:							;
	pop		de						;
									;
v_found_2:							;
	pop		de						;
	pop		de						;
	push	hl						;
	rst		get_ch					;
									;
v_pass:								;
	call	alphanum				;
	jr		nc, v_end				;
	rst		next_ch					;
	jr		v_pass					;
									;
v_end:								;
	pop		hl						;
	rl		b						;
	bit		6, b					;
	ret								;

l2951:
	ld		hl, (defadd)
	ld		a, (hl)
	cp		')'
	jp		z, v_run_syn

l295a:
	ld		a, (hl)
	or		%01100000
	inc		hl
	ld		b, a
	ld		a, (hl)
	cp		ctrl_number
	jr		z, l296b
	dec		hl
	call	l28ab
	res		5, b
	inc		hl

l296b:
	ld		a, b
	cp		c
	jr		z, l2981
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	call	l28ab
	cp		')'
	jp		z, v_run_syn
	call	l28ab
	jr		l295a

l2981:
	bit		5, c
	jr		nz, l2991
	inc		hl
	ld		de, (stkend)
	call	x80_fmove
	ex		de, hl
	ld		(stkend), hl

l2991:
	pop		de
	pop		de
	xor		a
	inc		a
	ret

stk_var:							; zx81
	xor		a						;
	ld		b, a					;
	bit		7, c					;
	jr		nz, sv_count			;
	bit		7, (hl)					;
	jr		nz, sv_arrays			;
	inc		a						;
									;
sv_smples:							;
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	inc		hl						;
	ex		de, hl					;
	call	stk_store				;
	rst		get_ch					;
	jp		sv_sliceq				;
									;
sv_arrays:							;
	inc		hl						;
	inc		hl						;
	inc		hl						;
	ld		b, (hl)					;
	bit		6, c					;
	jr		z, sv_ptr				;
	dec		b						;
	jr		z, sv_smples			;
	ex		de, hl					;
	rst		get_ch					;
	cp		'('						;
	jr		nz, report_3			;
	ex		de, hl					;
									;
sv_ptr:								;
	ex		de, hl					;
	jr		sv_count				;
									;
sv_comma:							;
	push	hl						;
	rst		get_ch					;
	pop		hl						;
	cp		','						;
	jr		z, sv_loop				;
	bit		7, c					;
	jr		z, report_3				;
	bit		6, c					;
	jr		nz, sv_close			;
	cp		')'						;
	jr		nz, sv_rpt_c			;
	rst		next_ch					;
	ret								;
									;
sv_close:							;
	cp		')'						;
	jr		z, sv_dim				;
	cp		tk_to					;
	jr		nz, sv_rpt_c			;
									;
sv_chadd:							;
	rst		get_ch					;
	dec		hl						;
	ld		(chadd), hl				;
	jr		sv_slice				;
									;
sv_count:							;
	ld		hl, 0					;
									;
sv_loop:							;
	push	hl						;
	rst		next_ch					;
	pop		hl 						;
	ld		a, c					;
	cp		%11000000				;
	jr		nz, sv_mult				;
	rst		get_ch					;
	cp		')'						;
	jr		z, sv_dim				;
	cp		tk_to					;
	jr		z, sv_chadd				;
									;
sv_mult:							;
	push	bc						;
	push	hl						;
	call	de_de_1					;
	ex		(sp), hl				;
	ex		de, hl					;
	call	int_exp1				;
	jr		c, report_3				;
	dec		bc						;
	call	hl_hl_de				;
	add		hl, bc					;
	pop		de						;
	pop		bc						;
	djnz	sv_comma				;
	bit		7, c					;
									;
sv_rpt_c:							;
	jr		nz, sl_rpt_c			;
	push	hl						;
	bit		6, c					;
	jr		nz, sv_elems			;
	ld		b, d					;
	ld		c, e					;
	rst		get_ch					;
	cp		')'						;
	jr		z, sv_number			;
									;
report_3:							;
	rst		error_1					;
	defb	Bad_subscript			;
									;
sv_number:							;
	rst		next_ch					;
	pop		hl						;
	ld		de, 5					;
	call	hl_hl_de				;
	add		hl, bc					;
	ret								;
									;
sv_elems:							;
	call	de_de_1					;
	ex		(sp), hl				;
	call	hl_hl_de				;
	pop		bc						;
	add		hl, bc					;
	inc		hl						;
	ld		b, d					;
	ld		c, e					;
	ex		de, hl					;
	call	stk_st_0				;
	rst		get_ch					;
	cp		')'						;
	jr		z, sv_dim				;
	cp		','						;
	jr		nz, report_3			;
									;
sv_slice:							;
	call	slicing					;
									;
sv_dim:								;
	rst		next_ch					;
									;
sv_sliceq:							;
	cp		'('						;
	jr		z, sv_slice				;
	res		6, (iy + _flags)		;
	ret								;
									;
slicing:							;
	call	syntax_z				;
	call	nz, stk_fetch			;
	rst		next_ch					;
	cp		')'						;
	jr		z, sl_store				;
	push	de						;
	xor		a						;
	push	af						;
	push	bc						;
	ld		de, 1					;
	rst		get_ch					;
	pop		hl						;
	cp		tk_to					;
	jr		z, sl_second			;
	pop		af						;
	call	int_exp2				;
	push	af						;
	ld		d, b					;
	ld		e, c					;
	push	hl						;
	rst		get_ch					;
	pop		hl						;
	cp		tk_to					;
	jr		z, sl_second			;
	cp		')'						;
									;
sl_rpt_c:							;
	jp		nz, report_c			;
	ld		h, d					;
	ld		l, e					;
	jr		sl_define				;
									;
sl_second:							;
	push	hl						;
	rst		next_ch					;
	pop		hl						;
	cp		')'						;
	jr		z, sl_define			;
	pop		af						;
	call	int_exp2				;
	push	af						;
	rst		get_ch					;
	ld		h, b					;
	ld		l, c					;
	cp		')'						;
	jr		nz, sl_rpt_c			;
									;
sl_define:							;
	pop		af						;
	ex		(sp), hl				;
	add		hl, de					;
	dec		hl						;
	ex		(sp), hl				;
	and		a						;
	sbc		hl, de					;
	ld		bc, 0					;
	jr		c, sl_over				;
	inc		hl						;
	and		a						;
	jp		m, report_3				;
	ld		b, h					;
	ld		c, l					;
									;
sl_over:							;
	pop		de						;
	res		6, (iy + _flags)		;
									;
sl_store:							;
	call	syntax_z				;
	ret		z						;
									;
stk_st_0:							;
	xor		a						;
									;
stk_store:							;
	res		6, (iy + _flags)		;
									;
l2ab6:								;
	push	bc						;
	call	test_5_sp				;
	pop		bc						;
	ld		hl, (stkend)			;
	ld		(hl), a					;
	inc		hl						;
	ld		(hl), e					;
	inc		hl						;
	ld		(hl), d					;
	inc		hl						;
	ld		(hl), c					;
	inc		hl						;
	ld		(hl), b					;
	inc		hl						;
	ld		(stkend), hl			;
	ret								;
									;
int_exp1:							;
	xor		a						;
									;
int_exp2:							;
	push	de						;
	push	hl						;
	push	af						;
	call	class_6					;
	pop		af						;
	call	syntax_z				;
	jr		z, i_restore			;
	push	af						;
	call	find_int				;
	pop		de						;
	ld		a, b					;
	or		c						;
	scf								;
	jr		z, i_carry				;
	pop		hl						;
	push	hl						;
	and		a						;
	sbc		hl, bc					;
									;
i_carry:							;
	ld		a, d					;
	sbc		a, 0					;
									;
i_restore:							;
	pop		hl						;
	pop		de						;
	ret								;
									;
de_de_1:							;
	ex		de, hl					;
	inc		hl						;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ret								;
									;
hl_hl_de:							;
	call	syntax_z				;
	ret		z						;
	call	l30a9					;
	jp		c, report_4				;
	ret								;
									;
let:								;
	ld		hl, (dest)				;
	bit		1, (iy + _flage)		;
	jr		z, l_exists				;
	ld		bc, 5					;
									;
l_each_ch:							;
	inc		bc						;
									;
l_no_sp:							;
	inc		hl						;
	ld		a, (hl)					;
	cp		' '
	jr		z, l_no_sp
	jr		nc, l2b1f
	cp		16
	jr		c, l2b29
	cp		22
	jr		nc, l2b29
	inc		hl
	jr		l_no_sp

l2b1f:
	call	alphanum				; zx81
	jr		c, l_each_ch			;
	cp		'$'						;
	jp		z, l_news				;

l2b29:
	ld		a, c
	ld		hl, (eline)
	dec		hl
	call	make_room
	ex		de, hl
	inc		de
	inc		de
	push	de						; zx81
	ld		hl, (dest)				;
	dec		de						;
	sub		6						;
	ld		b, a					;
	jr		z, l_single				;
									;
l_char:								;
	inc		hl						;
	ld		a, (hl)					;
	cp		' ' + 1
	jr		c, l_char
	inc		de
	or		%00100000
	ld		(de), a					; zx81
	djnz	l_char					;
	or		%10000000				;
	ld		(de), a					;
	ld		a, %11000000			;
									;
l_single:							;
	ld		hl, (dest)				;
	xor		(hl)					;
	or		%00100000
	pop		hl
	call	l2bea

l_numeric:							; zx81						
	push	hl						;
	fwait							;
	fdel							;
	fce								;
	pop		hl						;
	ld		bc, 5					;
	and		a						;
	sbc		hl, bc					;
	jr		l_enter					;
									;
l_exists:							;
	bit		6, (iy + _flags)		;
	jr		z, l_deletes			;
	ld		de, 6					;
	add		hl, de					;
	jr		l_numeric				;
									;
l_deletes:							;
	ld		hl, (dest)				;
	ld		bc, (stril)				;
	bit		0, (iy + _flage)		;
	jr		nz, l_adds				;
	ld		a, b					;
	or		c						;
	ret		z						;
	push	hl						;
	rst		bc_spaces				;
	push	de						;
	push	bc						;
	ld		d, h					;
	ld		e, l					;
	inc		hl						;
	ld		(hl), ' '				;
	lddr							;
	push	hl						;
	call	stk_fetch				;
	pop		hl						;
	ex		(sp), hl				;
	and		a						;
	sbc		hl, bc					;
	add		hl, bc					;
	jr		nc, l_length			;
	ld		b, h					;
	ld		c, l					;
									;
l_length:							;
	ex		(sp), hl				;
	ex		de, hl					;
	ld		a, b					;
	or		c						;
	jr		z, l_in_w_s				;
	ldir							;
									;
l_in_w_s:							;
	pop		bc						;
	pop		de						;
	pop		hl						;
									;
l_enter:							;
	ex		de, hl					;
	ld		a, b					;
	or		c						;
	ret		z						;
	push	de						;
	ldir							;
	pop		hl						;
	ret								;
									;
l_adds:								;
	dec		hl						;
	dec		hl						;
	dec		hl						;
	ld		a, (hl)					;
	push	hl						;
	push	bc						;
	call	l_string				;
	pop		bc						;
	pop		hl						;
	inc		bc						;
	inc		bc						;
	inc		bc						;
	jp		reclaim_2				;
									;
l_news:								;
	ld		a, %11011111			;
	ld		hl, (dest)				;
	and		(hl)					;
									;
l_string:							;
	push	af						;
	call	stk_fetch				;
	ex		de, hl					;
	add		hl, bc					;
	dec		hl
	ld		(dest), hl
	push	bc
	inc		bc						; zx81
	inc		bc						;
	inc		bc						;
	ld		hl, (eline)
	dec		hl
	call	make_room
	ld		hl, (dest)
	pop		bc
	push	bc
	inc		bc
	lddr							; zx81
	ex		de, hl					;
	pop		bc
	inc		hl
	ld		(hl), b					; zx81
	dec		hl						;
	ld		(hl), c					;
	pop		af						;

l2bea:
	dec		hl
	ld		(hl), a
	ld		hl, (eline)
	dec		hl
	ret

stk_fetch:							; zx81
	ld		hl, (stkend)			;
	dec		hl						;
	ld		b, (hl)					;
	dec		hl						;
	ld		c, (hl)					;
	dec		hl						;
	ld		d, (hl)					;
	dec		hl						;
	ld		e, (hl)					;
	dec		hl						;
	ld		a, (hl)					;
	ld		(stkend), hl			;
	ret								;
									;
dim:								;
	call	look_vars				;
									;
d_rport_c:							;
	jp		nz, report_c			;
	call	syntax_z				;
	jr		nz, d_run				;
	res		6, c					;
	call	stk_var					;
	call	check_end				;
									;
d_run:								;
	jr		c, d_letter				;
	push	bc						;
	call	next_one				;
	call	reclaim_2				;
	pop		bc						;
									;
d_letter:							;
	set		7, c					;
	ld		b, 0					;
	push	bc						;
	ld		hl, 1					;
	bit		6, c					;
	jr		nz, d_size				;
	ld		l, 5					;
									;
d_size:								;
	ex		de, hl					;
									;
d_no_loop:							;
	rst		next_ch					;
	ld		h, 255					;
	call	int_exp1				;
	jp		c, report_3				;
	pop		hl						;
	push	bc						;
	inc		h						;
	push	hl						;
	ld		h, b					;
	ld		l, c					;
	call	hl_hl_de				;
	ex		de, hl					;
	rst		get_ch					;
	cp		','						;
	jr		z, d_no_loop			;
	cp		')'						;
	jr		nz, d_rport_c			;
	rst		next_ch					;
	pop		bc						;
	ld		a, c					;
	ld		l, b					;
	ld		h, 0					;
	inc		hl						;
	inc		hl						;
	add		hl, hl					;
	add		hl, de					;
	jp		c, report_4				;
	push	de						;
	push	bc						;
	push	hl						;
	ld		b, h					;
	ld		c, l					;
	ld		hl, (eline)				;
	dec		hl						;
	call	make_room				;
	inc		hl						;
	ld		(hl), a					;
	pop		bc						;
	dec		bc						;
	dec		bc						;
	dec		bc						;
	inc		hl						;
	ld		(hl), c					;
	inc		hl						;
	ld		(hl), b					;
	pop		bc
	ld		a, b
	inc		hl						; zx81
	ld		(hl), a 				;
	ld		h, d					;
	ld		l, e					;
	dec		de						;
	ld		(hl), 0					;
	bit		6, c
	jr		z, l2c7c
	ld		(hl), ' '

l2c7c:								; zx81
	pop		bc						;
	lddr							;
									;
dim_sizes:							;
	pop		bc						;
	ld		(hl), b					;
	dec		hl						;
	ld		(hl), c					;
	dec		hl						;
	dec		a						;
	jr		nz, dim_sizes			;
	ret								;

alphanum:
	call	numeric
	ccf
	ret		c

alpha:								; zx81
	cp		'A'						;
	ccf								;
	ret		nc						;
	cp		'z' + 1					; sam
	ret		nc						;
	cp		'Z' + 1					;
	ret		c						;
	cp		'a'						;
	ccf								;
	ret								;

dec_to_fp:
	cp		tk_bin
	jr		nz, l2cb8
	ld		de, 0

l2ca2:
	rst		next_ch
	sub		'1'
	adc		a, 0
	jr		nz, l2cb3
	ex		de, hl
	ccf
	adc		hl, hl
	jp		c, report_6
	ex		de, hl
	jr		l2ca2

l2cb3:
	ld		c, e
	ld		b, d
	jp		stack_bc1

l2cb8:								; sam
	cp		'.'						;
	jr		z, decint				; was nz
	call	int_to_fp				;
	cp		'.'						;
	jr		nz, e_format			;
	rst		next_ch					;
	call	numeric					;
	jr		c, e_format				; was nc
	jr		l2cd5

decint:								; sam
	rst		next_ch					;
	call	numeric					;

nonsense:
	jp		c, report_c
	fwait
	fstk0
	fce

l2cd5:								; zx81
	fwait							;
	fstk1							;
	fst		0						;
	fdel							;
	fce								;
									;
nxt_dgt_1:							;
	rst		get_ch					; was next_ch
	call	stk_digit				;
	jr		c, e_format				;
	fwait							;
	fgt		0						;
	fstk10							;
	fmul							; was fdiv
	fst		0						;
	fdiv							; was fmul
	fadd							;
	fce								;
	rst		next_ch
	jr		nxt_dgt_1

e_format:							; sam
	cp		'E'						;
	jr		z, l2cf2
	cp		'e'
	ret		nz

l2cf2:
	ld		b, 255
	rst		next_ch					; zx81
	cp		'+'						;
	jr		z, sign_done			;
	cp		'-'						;
	jr		nz, st_e_part			;
	inc		b

sign_done:							; zx81
	rst		next_ch					;

st_e_part:							; sam
	call	numeric					;
	jr		c, nonsense				; was nc
	push	bc						;
	call	int_to_fp				;
	call	fp_to_a					;
	pop		bc
	jp		c, report_6
	and		a
	jp		m, report_6
	inc		b
	jr		z, e_fp					; sam
	neg								;
									;
e_fp:								;
	jr		e_to_fp					;
	defb	0xff					; se
									; sam
numeric:							;
	cp		'0'						; was '9' + 1
	ret		c						; was nc
	cp		'9' + 1					; was '0'
	ccf								;
	ret								;

stk_digit:
	call	numeric
	ret		c						; zx81
	sub		'0'						;
									;
stack_a:							;
	ld		c, a					;
	ld		b, 0					;
									;
stack_bc:							;
	ld		iy, errnr				;

stack_bc1:
	ld		d, c
	xor		a
	ld		e, a
	ld		c, b
	ld		b, e
	call	l2ab6
	fwait
	fce
	and		a
	ret

int_to_fp:							; zx81
	push	af						;
	fwait							;
	fstk0							;
	fce								;
	pop		af						;
									;
nxt_dgt_2:							;
	call	stk_digit				;
	ret		c						;
	fwait							;
	fxch							;
	fstk10							;
	fmul							;
	fadd							;
	fce								;
	call	ch_add_1				;
	jr		nxt_dgt_2				;

e_to_fp:
	rlca
	rrca
	jr		nc, l2d55
	cpl
	inc		a

l2d55:
	push	af
	ld		hl, membot
	call	fp_0_1
	fwait
	fstk10
	fce
	pop		af

l2d60:
	srl		a
	jr		nc, l2d71
	push	af
	fwait
	fst		1
	fgt		0
	fjpt	l2d6d
	fmul
	fjp		l2d6e

l2d6d:
	fdiv

l2d6e:
	fgt		1
	fce
	pop		af

l2d71:
	jr		z, l2d7b
	push	af
	fwait
	fmove
	fmul
	fce
	pop		af
	jr		l2d60

l2d7b:
	fwait
	fdel
	fce
	ret

fetchi:								; sam
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		a, (hl)
	xor		c
	sub		c
	ld		e, a
	inc		hl
	ld		a, (hl)
	adc		a, c
	xor		c
	ld		d, a
	ret

l2d8c:								; se
	defb	"MB"					;

l2d8e:
	push	hl
	inc		hl
	ld		(hl), c
	inc		hl
	ld		a, e
	xor		c
	sub		c
	ld		(hl), a
	inc		hl
	ld		a, d
	adc		a, c
	xor		c
	ld		(hl), a
	inc		hl
	xor		a
	ld		(hl), a
	pop		hl
	ld		(hl), a
	ret
	defb	255

fp_to_bc:
	fwait
	fce
	ld		a, (hl)					; sam
	and		a						;
	jr		z, fpbcint				;
	fwait							;
	fstk_5							;
	fadd							;
	fint							;
	fce								;

fpbcint:
	fwait
	fdel
	fce
	push	de
	push	hl
	ex		de, hl
	ld		b, (hl)
	call	fetchi
	xor		a
	sub		b
	bit		7, c
	ld		a, e
	ld		b, d
	ld		c, a
	pop		hl
	pop		de
	ret

l2dc1:
	ld		d, a
	rla
	sbc		a, a
	ld		e, a
	ld		c, a
	xor		a
	ld		b, a
	call	l2ab6
	fwait
	fstk
	defb	0xef, 0x1a, 0x20, 0x9a, 0x85
	fmul
	fint
	fce

fp_to_a:							; zx81
	call	fp_to_bc				;
	ret		c						;
	push	af						;
	dec		b						;
	inc		b						;
	jr		z, fp_a_end				;
	pop		af						;
	scf								;
	ret								;
									;
fp_a_end:							;
	pop		af						;
	ret								;
									;
print_fp:							;
	fwait							;
	fmove							;
	fcp		.lz						;
	fjpt	p_neg					;
	fmove							;
	fcp		.gz						;
	fjpt	p_pos					;
	fdel							;
	fce								;
	ld		a, '0'					;
	rst		print_a					;
	ret								;
									;
p_neg:								;
	fabs							;
	fce								;
	ld		a, '-'					;
	rst		print_a					;
	fwait							;

p_pos:
	fstk0
	fst		3
	fst		4
	fst		5
	fdel
	fce
	exx
	push	hl
	exx

l2e01:
	fwait
	fmove
	fint
	fst		2
	fsub
	fgt		2
	fxch
	fst		2
	fdel
	fce
	ld		a, (hl)
	and		a
	jr		nz, l2e56
	call	fetchi
	ld		b, 16
	ld		a, d
	and		a
	jr		nz, l2e1e
	or		e
	jr		z, l2e24 
	ld		b, 8
	ld		d, e

l2e1e:
	push	de
	exx
	pop		de
	exx
	jr		l2e7b

l2e24:
	fwait
	fdel
	fgt		2
	fce
	ld		a, (hl)
	sub		126
	call	l2dc1
	ld		d, a
	ld		a, (mem_5_1)
	sub		d
	ld		(mem_5_1), a
	ld		a, d 
	call	e_to_fp
	fwait
	fmove
	fint
	fst		1
	fsub
	fgt		1
	fce
	call	fp_to_a
	push	hl
	ld		(mem_3), a
	dec		a
	rla
	sbc		a, a
	inc		a
	ld		hl, mem_5
	ld		(hl), a
	inc		hl
	add		a, (hl)
	ld		(hl), a
	pop		hl
	jr		l2ecf

l2e56:
	sub		128
	cp		28
	jr		c, l2e6f
	call	l2dc1
	sub		7
	ld		hl, mem_5_1
	ld		b, a
	add		a, (hl)
	ld		(hl), a
	ld		a, b 
	neg
	call	e_to_fp
	jr		l2e01

l2e6f:
	ex		de, hl
	call	fetch_two
	exx
	ld		a, l
	set		7, d
	exx
	sub		128
	ld		b, a

l2e7b:
	sla		e
	rl		d
	exx
	rl		e
	rl		d
	exx
	ld		hl, mem_4_4
	ld		c, 5

l2e8a:
	ld		a, (hl)
	adc		a, a
	daa
	ld		(hl), a
	dec		hl
	dec		c
	jr		nz, l2e8a
	djnz	l2e7b
	ld		de, mem_3
	ld		hl, mem_4
	ld		b, 9
	xor		a
	rld
	ld		c, 255

l2ea1:
	rld
	jr		nz, l2ea9
	dec		c
	inc		c
	jr		nz, l2eb3

l2ea9:
	ld		(de), a
	ld		c, 0
	inc		(iy + _mem_5_1)
	inc		(iy + _mem_5)
	inc		de

l2eb3:
	bit		0, b
	jr		z, l2eb8
	inc		hl

l2eb8:
	djnz	l2ea1
	ld		a, (mem_5)
	sub		9
	jr		c, l2ecb
	dec		(iy + _mem_5)
	ld		a, 4
	cp		(iy + _mem_4_3)
	jr		l2f0c
 
l2ecb:
	fwait
	fdel
	fgt		2
	fce

l2ecf:
	ex		de, hl
	call	fetch_two
	exx
	ld		a, 128
	sub		l
	set		7, d
	ld		l, 0
	exx
	call	shift_fp

l2edf:
	ld		a, (iy + _mem_5)
	cp		8
	jr		c, l2eec
	exx
	rl		d
	exx
	jr		l2f0c

l2eec:
	ld		bc, 0x0200

l2eef:
	ld		a, e
	call	l2f8b
	ld		e, a
	ld		a, d
	call	l2f8b
	ld		d, a
	push	bc
	exx
	pop		bc
	djnz	l2eef
	ld		hl, mem_3
	ld		a, c
	ld		c, (iy + _mem_5)
	add		hl, bc
	ld		(hl), a
	inc		(iy + _mem_5)
	jr		l2edf

l2f0c:
	push	af
	ld		b, 0
	ld		c, (iy + _mem_5)
	ld		hl, mem_3
	add		hl, bc
	ld		b, c
	pop		af

l2f18:
	dec		hl
	ld		a, (hl)
	adc		a, 0
	ld		(hl), a
	and		a
	jr		z, l2f25
	cp		10
	ccf
	jr		nc, l2f2d

l2f25:
	djnz	l2f18
	inc		(iy + _mem_5_1)
	inc		b
	ld		(hl), 1

l2f2d:
	ld		(iy + _mem_5), b
	fwait
	fdel
	fce
	exx
	pop		hl
	exx
	ld		bc, (mem_5)
	ld		hl, mem_3
	ld		a, b
	cp		9
	jr		c, l2f46
	cp		252
	jr		c, l2f6c

l2f46:
	and		a
	call	z, out_code

l2f4a:
	xor		a
	sub		b
	jp		m, l2f52
	ld		b, a
	jr		l2f5e

l2f52:
	ld		a, c
	and		a
	jr		z, l2f59
	ld		a, (hl)
	inc		hl
	dec		c

l2f59:
	call	out_code
	djnz	l2f52

l2f5e:
	ld		a, c
	and		a
	ret		z
	ld		a, '.'
	inc		b

l2f64:
	rst		print_a
	ld		a, '0'
	djnz	l2f64
	ld		b, c
	jr		l2f52

l2f6c:
	ld		d, b
	ld		b, 1
	dec		d
	call	l2f4a
	ld		a, 'E'
	rst		print_a
	ld		c, d
	ld		a, d
	and		a
	jp		p, l2f83
	neg
	ld		c, a
	ld		a, '-'
	jr		l2f85

l2f83:
	ld		a, '+'

l2f85:
	rst		print_a
	ld		b, 0
	jp		out_num

l2f8b:
	ld		h, 0
	ld		l, a
	push	de
	ld		d, h
	ld		e, a
	add		hl, hl
	add		hl, hl
	add		hl, de
	add		hl, hl
	ld		e, c
	add		hl, de
	pop		de
	ld		a, l
	ld		c, h
	ret

prep_add:							; zx81
	ld		a, (hl)					;
	and		a						;
	ret		z						;
	ld		(hl), 0					; moved
	inc		hl						;
	bit		7, (hl)					;
	set		7, (hl)					;
	dec		hl						;
	ret		z						;
	push	bc						;
	ld		bc, 5					;
	add		hl, bc					;
	ld		b, c					;
	ld		c, a					;
	scf								;
									;
neg_byte:							;
	dec		hl						;
	ld		a, (hl)					;
	cpl								;
	adc		a, 0					;
	ld		(hl), a					;
	djnz	neg_byte				;
	ld		a, c					;
	pop		bc						;
	ret								;
									;
fetch_two:							;
	push	hl						;
	push	af						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	ld		(hl), a					;
	inc		hl						;
	ld		a, c					;
	ld		c, (hl)					;
	push	bc						;
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	ex		de, hl					;
	ld		d, a					;
	ld		e, (hl)					;
	push	de						;
	inc		hl						;
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	push	de						;
	exx								;
	pop		de						;
	pop		hl						;
	pop		bc						;
	exx								;
	inc		hl						;
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	pop		af						;
	pop		hl						;
	ret								;
									;
shift_fp:							;
	and		a						;
	ret		z						;
	cp		33						;
	jr		nc, addend_0			;
	push	bc						;
	ld		b, a					;
									;
one_shift:							;
	exx								;
	sra		l						;
	rr		d						;
	rr		e						;
	exx								;
	rr		d						;
	rr		e						;
	djnz	one_shift				;
	pop		bc						;
	ret		nc						;
	call	add_back				;
	ret		nz						;
									;
addend_0:							;
	exx								;
	xor		a						;
									;
zeros_4_5:							;
	ld		l, 0					;
	ld		d, a					;
	ld		e, l					;
	exx								;
	ld		de, 0					;
	ret								;
									;
add_back:							;
	inc		e						;
	ret		nz						;
	inc		d						;
	ret		nz						;
	exx								;
	inc		e						;
	jr		nz, all_added			;
	inc		d						;
									;
all_added:							;
	exx								;
	ret								;

x80_fsub:							; sam
	ex		de, hl					;
	call	x80_fneg				;
	ex		de, hl					;
									;
x80_fadd:							;
	ld		a, (de)					;
	or		(hl)					;
	jr		nz, addition			;
	push	de						;
	inc		hl						;
	push	hl						;
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	inc		hl						;
	inc		hl						;
	inc		hl						;
	ld		a, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ex		de, hl					;
	add		hl, bc					;
	ex		de, hl					;
	pop		hl						;
	adc		a, (hl)					;
	rrca							;
	adc		a, 0					; was b
	jp		l3221

l3032:
	ld		(hl), a
	inc		hl
	ld		(hl), e
	inc		hl
	ld		(hl), d
	dec		hl
	dec		hl
	dec		hl
	pop		de
	ret

l303c:
	dec		hl
	pop		de

addition:
	call	l3293
	exx								; zx81
	push	hl						;
	exx								;
	push	de						;
	push	hl						;
	call	prep_add				;
	ld		b, a					;
	ex		de, hl					;
	call	prep_add				;
	ld		c, a					;
	cp		b						;
	jr		nc, shift_len			;
	ld		a, b					;
	ld		b, c					;
	ex		de, hl					;
									;
shift_len:							;
	push	af						;
	sub		b						;
	call	fetch_two				;
	call	shift_fp				;
	pop		af						;
	pop		hl						;
	ld		(hl), a					;
	push	hl						;
	ld		l, b					;
	ld		h, c					;
	add		hl, de					;
	exx								;
	ex		de, hl					;
	adc		hl, bc					;
	ex		de, hl					;
	ld		a, h					;
	adc		a, l					;
	ld		l, a					;
	rra								;
	xor		l						;
	exx								;
	ex		de, hl					;
	pop		hl						;
	rra								;
	jr		nc, test_neg			;
	ld		a, 1					;
	call	shift_fp				;
	inc		(hl)					;
	jr		z, add_rep_6			;
									;
test_neg:							;
	exx								;
	ld		a, l					;
	and		%10000000				;
	exx								;
	inc		hl						;
	ld		(hl), a					;
	dec		hl						;
	jr		z, go_nc_mlt			;
	ld		a, e					;
	neg								;
	ccf								;
	ld		e, a					;
	ld		a, d					;
	cpl								;
	adc		a, 0					;
	ld		d, a					;
	exx								;
	ld		a, e					;
	cpl								;
	adc		a, 0					;
	ld		e, a					;
	ld		a, d					;
	cpl								;
	adc		a, 0					;
	jr		nc, end_compl			;
	rra								;
	exx								;
	inc		(hl)					;
									;
add_rep_6:							;
	jp		z, report_6				;
	exx								;
									;
end_compl:							;
	ld		d, a					;
	exx								;
									;
go_nc_mlt:							;
	xor		a						;
	jp		test_norm				;
									;
l30a9:								;
	push	bc						;
	ld		b, 16					;
	ld		a, h					;
	ld		c, l					;
	ld		hl, 0					;
									;
hl_loop:							;
	add		hl, hl					;
	jr		c, hl_over				;
	rl		c						;
	rla								;
	jr		nc, hl_again			;
	add		hl, de					;
	jr		c, hl_over

hl_again:							; zx81
	djnz	hl_loop					;
									;
hl_over:							;
	pop		bc						;
	ret								;

prep_m_d:
	call	tstzero
	ret		c
	inc		hl						; zx81
	xor		(hl)					;
	set		7, (hl)					;
	dec		hl						;
	ret								;

x80_fmul:							; sam
	ld		a, (de)					;
	or		(hl)					;
	jr		nz, multiply			;
	push	de						;
	push	hl						;
	push	de
	call	fetchi
	ex		de, hl
	ex		(sp), hl
	ld		b, c					; sam
	call	fetchi					;
	ld		a, c					;
	xor		b						;
	ld		c, a					;
	pop		hl
	call	l30a9
	pop		de						; sam
	ex		de, hl					;
	jr		c, qmult				;
	ld		a, e
	or		d
	jr		nz, l30ea
	ld		c, a

l30ea:
	call	l2d8e
	pop		de
	ret

qmult:
	pop		de

multiply:
	call	l3293
	xor		a						; zx81
	call	prep_m_d				;
	ret		c						;
	exx								;
	push	hl						;
	exx								;
	push	de						;
	ex		de, hl					;
	call	prep_m_d				;
	ex		de, hl					;
	jr		c, zero_rslt			;
	push	hl						;
	call	fetch_two				;
	ld		a, b					;
	and		a						;
	sbc		hl, hl					;
	exx								;
	push	hl						;
	sbc		hl, hl					;
	exx								;
	ld		b, 33					;
	jr		strt_mlt				;
									;
mlt_loop:							;
	jr		nc, no_add				;
	add		hl, de					;
	exx								;
	adc		hl, de					;
	exx								;
									;
no_add:								;
	exx								;
	rr		h						;
	rr		l						;
	exx								;
	rr		h						;
	rr		l						;
									;
strt_mlt:							;
	exx								;
	rr		b						;
	rr		c						;
	exx								;
	rr		c						;
	rra								;
	djnz	mlt_loop				;
	ex		de, hl					;
	exx								;
	ex		de, hl					;
	exx								;
	pop		bc						;
	pop		hl						;
	ld		a, b					;
	add		a, c					;
	jr		nz, make_expt			;
	and		a						;
									;
make_expt:							;
	dec		a						;
	ccf								;
									;
divn_expt:							;
	rla								;
	ccf								;
	rra								;
	jp		p, oflw1_clr			;
	jr		nc, report_6			;
	and		a						;
									;
oflw1_clr:							;
	inc		a						;
	jr		nz, oflw2_clr			;
	jr		c, oflw2_clr			;
	exx								;
	bit		7, d					;
	exx								;
	jr		nz, report_6			;
									;
oflw2_clr:							;
	ld		(hl), a					;
	exx								;
	ld		a, b					;
	exx								;
									;
test_norm:							;
	jr		nc, normalize			;
	ld		a, (hl)					;
	and		a						;
									;
near_zero:							;
	ld		a, 128					;
	jr		z, skip_zero			;
									;
zero_rslt:							;
	xor		a						;
									;
skip_zero:							;
	exx								;
	and		d						;
	call	zeros_4_5				;
	rlca							;
	ld		(hl), a					;
	jr		c, oflow_clr			;
	inc		hl						;
	ld		(hl), a					;
	dec		hl						;
	jr		oflow_clr				;
									;
normalize:							;
	ld		b, 32					;
									;
shift_one:							;
	exx								;
	bit		7, d					;
	exx								;
	jr		nz, norml_now			;
	rlca							;
	rl		e						;
	rl		d						;
	exx								;
	rl		e						;
	rl		d						;
	exx								;
	dec		(hl)					;
	jr		z, near_zero			;
	djnz	shift_one				;
	jr		zero_rslt				;
									;
norml_now:							;
	rla								;
	jr		nc, oflow_clr			;
	call	add_back				;
	jr		nz, oflow_clr			;
	exx								;
	ld		d, 128					;
	exx								;
	inc		(hl)					;
	jr		z, report_6				;
									;
oflow_clr:							;
	push	hl						;
	inc		hl						;
	exx								;
	push	de						;
	exx								;
	pop		bc						;
	ld		a, b					;
	rla								;
	rl		(hl)					;
	rra								;
	ld		(hl), a					;
	inc		hl						;
	ld		(hl), c					;
	inc		hl						;
	ld		(hl), d					;
	inc		hl						;
	ld		(hl), e					;
	pop		hl						;
	pop		de						;
	exx								;
	pop		hl						;
	exx								;
	ret								;

report_6:							; zx81
	rst		error_1					;
	defb	Number_too_large		;

x80_fdiv:
	call	l3293
	ex		de, hl					; zx81
	xor		a						;
	call	prep_m_d				;
	jr		c, report_6				;
	ex		de, hl					;
	call	prep_m_d				;
	ret		c						;
	exx								;
	push	hl						;
	exx								;
	push	de						;
	push	hl						;
	call	fetch_two				;
	exx								;
	push	hl						;
	ld		h, b					;
	ld		l, c					;
	exx								;
	ld		h, c					;
	ld		l, b					;
	xor		a						;
	ld		b, 0xdf					;
	jr		div_start				;
									;
div_loop:							;
	rla								;
	rl		c						;
	exx								;
	rl		c						;
	rl		b						;
	exx								;
									;
l31db:								;
	add		hl, hl					;
	exx								;
	adc		hl, hl					;
	exx								;
	jr		c, subn_only			;
									;
div_start:							;
	sbc		hl, de					;
	exx								;
	sbc		hl, de					;
	exx								;
	jr		nc, no_rstore			;
	add		hl, de					;
	exx								;
	adc		hl, de					;
	exx								;
	and		a						;
	jr		count_one				;
									;
subn_only:							;
	and		a						;
	sbc		hl, de					;
	exx								;
	sbc		hl, de					;
	exx								;
									;
no_rstore:							;
	scf								;
									;
count_one:							;
	inc		b						;
	jp		m, div_loop				;
	push	af						;
	jr		z, div_start			;
	ld		e, a					;
	ld		d, c					;
	exx								;
	ld		e, c					;
	ld		d, b					;
	pop		af						;
	rr		b						;
	pop		af						;
	rr		b						;
	exx								;
	pop		bc						;
	pop		hl						;
	ld		a, b					;
	sub		c						;
	jp		divn_expt				;
									;
x80_ftrn:							;
	ld		a, (hl)					;
	and		a
	ret		z
	cp		129						; zx81
	jr		nc, fptrunct			; was x_large
	ld		(hl), 0					;
	ld		a, 32					;
	jr		nil_bytes				;

l3221:								; se
	jp		nz, l303c				;
	sbc		a, a					;
	ld		c, a					;
	inc		a						;
	or		e						;
	or		d						;
	ld		a, c					;
	jr		nz, l3232				;
	dec		hl						;
	ld		(hl), 145				;
	inc		hl						;
	and		%10000000				;
									;
l3232:								;
	jp		l3032					;
									;
l3235:								;
	defb	0x80, 'Scroll', '?' + 0x80

fptrunct:							; sam
	cp		145						;
	jr		nc, x_large				;
	push	de						;
	cpl
	add		a, 145
	inc		hl						; sam
	ld		d, (hl)					;
	inc		hl						;
	ld		e, (hl)					;
	dec		hl						;
	dec		hl						;
	ld		c, 0xff					;
	bit		7, d					;
	jr		nz, trunct2				;
	inc		c						;

trunct2:
	set		7, d
	ld		b, 08
	sub		b						; sam
	add		a, b					;
	jr		c, trunct3				;
	ld		e, d					;
	ld		d, 0					;
	sub		b						;
									;
trunct3:							;
	jr		z, trunct5				;
	ld		b, a					;
									;
trunct4:							;
	srl		d						;
	rr		e						;
	djnz	trunct4					;

trunct5:
	call	l2d8e
	pop		de
	ret
	defb	0xff					; se

x_large:							; zx81
	sub		160						;
	ret		p						;
	neg								;
									;
nil_bytes:							;
	push	de						;
	ex		de, hl					;
	dec		hl						;
	ld		b, a					;
	srl		b						;
	srl		b						;
	srl		b						;
	jr		z, bits_zero			;
									;
byte_zero:							;
	ld		(hl), 0					;
	dec		hl						;
	djnz	byte_zero				;
									;
bits_zero:							;
	and		%00000111				;
	jr		z, ix_end				;
	ld		b, a					;
	ld		a, 255					;
									;
less_mask:							;
	sla		a						;
	djnz	less_mask				;
	and		(hl)					;
	ld		(hl), a					;
									;
ix_end:								;
	ex		de, hl					;
	pop		de						;
	ret								;

l3293:
	call	l3296

l3296:
	ex		de, hl

x80_frstk:
	ld		a, (hl)
	and		a
	ret		nz
	push	de
	call	fetchi
	xor		a
	inc		hl
	ld		(hl), a
	dec		hl
	ld		(hl), a
	ld		b, 145
	ld		a, d
	and		a
	jr		nz, l32b1
	ld		b, d
	or		e
	jr		z, l32bd
	ld		d, e
	ld		e, b
	ld		b, 137

l32b1:
	ex		de, hl

l32b2:
	dec		b
	add		hl, hl
	jr		nc, l32b2
	rrc		c
	rr		h
	rr		l
	ex		de, hl

l32bd:
	dec		hl
	ld		(hl), e
	dec		hl
	ld		(hl), d
	dec		hl
	ld		(hl), b
	pop		de
	ret

constants:							; se
	defb	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 
	defb	0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x81 
	defb	0x49, 0x0f, 0xda, 0xa2, 0x00, 0x00, 0x0a, 0x00 
	defb	0x00					;

addresses:							; zx81
	defw	x80_fjpt				;
	defw	x80_fxch				;
	defw	x80_fdel				;
	defw	x80_fsub				;
	defw	x80_fmul				;
	defw	x80_fdiv				;
	defw	x80_ftop				;
	defw	x80_fbor				;
	defw	x80_fband				;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fadd				;
	defw	x80_fbands				;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcp					;
	defw	x80_fcat				;
	defw	x80_fval				; sam
	defw	x80_fusrs				;
	defw	x80_fread				;
	defw	x80_fneg				; zx81
	defw	x80_fasc				;
	defw	x80_fval				;
	defw	x80_flen				;
	defw	x80_fsin				;
	defw	x80_fcos				;
	defw	x80_ftan				;
	defw	x80_fasin				;
	defw	x80_facos				;
	defw	x80_fatan				;
	defw	x80_flogn				;
	defw	x80_fexp				;
	defw	x80_fint				;
	defw	x80_fsqrt				;
	defw	x80_fsgn				;
	defw	x80_fabs				;
	defw	x80_fpeek				;
	defw	x80_fin					; sam
	defw	x80_fusr				; zx81
	defw	x80_fstrs				;
	defw	x80_fchrs				;
	defw	x80_fnot				;
	defw	x80_fmove				;
	defw	x80_fmod				;
	defw	x80_fjp					;
	defw	x80_fstk				;
	defw	x80_fdjnz				;
	defw	x80_fcp_lz				;
	defw	x80_fcp_gz				;
	defw	x80_fce					;
	defw	x80_fget				;
	defw	x80_ftrn				;
	defw	x80_fsgl				;
	defw	x80_fhexs				; sam
	defw	x80_frstk				; zx81
	defw	x80_fsgen				;
	defw	x80_fstkc				;
	defw	x80_fst					;
	defw	x80_fgt					;

calculate:							; zx81
	call	stk_pntrs				;
									;
gen_ent_1:							;
	ld		a, b					;
	ld		(breg),a				;
									;
gen_ent_2:							;
	exx								;
	ex		(sp), hl				;
	exx								;
									;
re_entry:							;
	ld		(stkend), de			;
	exx								;
	ld		a, (hl)					;
	inc		hl						;
									;
scan_ent:							;
	push	hl						;
	and		a						;
	jp		p, first_38				;
	ld		d, a					;
	and		%01100000				;
	rrca							;
	rrca							;
	rrca							;
	rrca							;
	add		a, 124					;
	ld		l, a					;
	ld		a, d					;
	and		%00011111				;
	jr		ent_table				;
									;
first_38:							;
	cp		24						;
	jr		nc, double_a			;
	exx								;
	call	l359a
	exx

double_a:							; zx81
	rlca							;
	ld		l, a					;
									;
ent_table:							;
	ld		de, addresses			;
	ld		h, 0					;
	add		hl, de					;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ld		hl, re_entry			;
	ex		(sp), hl				;
	push	de						;
	exx								;
	ld		bc, (stkend_h)			;
									;
x80_fdel:							;
	ret								;
									;
x80_fsgl:							;
	pop		af						;
	ld		a, (breg)				;
	exx								;
	jr		scan_ent				;
									;
test_5_sp:							;
	push	de						;
	push	hl						;
	ld		bc, 5					;
	call	test_room				;
	pop		hl						;
	pop		de						;
	ret								;
									;
l33b8:								;
	ld		de, (stkend)			;
	call	x80_fmove				;
	ld		(stkend), de			;
	ret								;
									;
x80_fmove:							;
	call	test_5_sp				;
	ldir							;
	ret								;
									;
x80_fstk:							;
	ld		h, d					;
	ld		l, e					;
									;
stk_const:							;
	call	test_5_sp				;
	exx								;
	push	hl						;
	exx								;
	ex		(sp), hl				;
	ld		a, (hl)					;
	and		%11000000				;
	rlca							;
	rlca							;
	ld		c, a					;
	inc		c						;
	ld		a, (hl)					;
	and		%00111111				;
	jr		nz, form_exp			;
	inc		hl						;
	ld		a, (hl)					;
									;
form_exp:							;
	add		a, 80					;
	ld		(de), a					;
	ld		a, 5					;
	sub		c						;
	inc		hl						;
	inc		de						;
	ldir							;
	ex		(sp), hl				;
	exx								;
	pop		hl						;
	exx								;
	ld		b, a					;
	xor		a						;
									;
stk_zeros:							;
	dec		b						;
	ret		z						;
	ld		(de), a					;
	inc		de						;
	jr		stk_zeros				;
									;
loc_mem:							;
	ld		c, a					;
	rlca							;
	rlca							;
	add		a, c					;
	ld		c, a					;
	ld		b, 0					;
	add		hl, bc					;
	ret								;
									;
x80_fgt:							;
	ld		hl, (mem)				; /|\
									;  |
l3403:								;  |
	push	de						; \|/
	call	loc_mem					;
	call	x80_fmove				;
	pop		hl						;
	ret								;

x80_fstkc:							; se
	ld		hl, constants			;
	jr		l3403					;

x80_fst:							; zx81
	push	hl						;
	ex		de, hl					;
	ld		hl, (mem)				;
	call	loc_mem					;
	ex		de, hl					;
	ld		c, 5
	ldir
	ex		de, hl					; zx81
	pop		hl						;
	ret								;
									;
x80_fxch:							;
	ld		b, 5					;
									;
swap_byte:							;
	ld		a, (de)					;
	ld		c, a						
	ld		a, (hl)
	ld		(de), a					; zx81
	ld		(hl), c					;
	inc		hl						;
	inc		de						;
	djnz	swap_byte				;
	ret								;
									;
x80_fsgen:							;
	ld		b, a					;
	call	gen_ent_1				;
	fmove							;
	fadd							;
	fst		0						;
	fdel							;
	fstk0							;
	fst		2						;
									;
g_loop:								;
	fmove							;
	fgt		0						;
	fmul							;
	fgt		2						;
	fst		1						;
	fsub							;
	fce								;
	call	x80_fstk				;
	call	gen_ent_2				;
	fadd							;
	fxch							;
	fst		2						;
	fdel							;
	fdjnz	g_loop					;
	fgt		1						;
	fsub							;
	fce								;
	ret								;

x80_fabs:
	ld		b, 0xff
	jr		negate

x80_fneg:
	call	tstzero
	ret		c
	ld		b, 0

negate:								; zx81
	ld		a, (hl)					;
	and		a						;
	jr		z, l3468
	inc		hl
	ld		a, b
	and		%10000000
	or		(hl)
	rla
	ccf
	rra
	ld		(hl), a					; zx81
	dec		hl						;
	ret								;

l3468:
	push	de
	push	hl
	call	fetchi
	pop		hl
	ld		a, c
	or		b
	cpl
	jr		l347f

x80_fsgn:							; sam
	call	tstzero					;
	ret		c
	push	de
	ld		de, 1
	inc		hl
	rl		(hl)
	dec		hl						; sam
	sbc		a, a					;
									;
l347f:								;
	ld		c, a
	call	l2d8e
	pop		de
	ret

x80_fin:							;sam
	call	find_int				;
	in		a, (c)					;
	jr		stacka					;

x80_fpeek:							; zx81
	call	find_int				;
	ld		a, (bc)					;
									;
stacka:								;
	jp		stack_a					;
									;
x80_fusr:							;
	call	find_int				;
	ld		hl, stack_bc			;
	push	hl						;
	push	bc						;
	ret								;

x80_fusrs:
	call	stk_fetch
	dec		bc
	ld		a, c
	or		b
	jr		nz, invarg
	ld		a, (de)
	call	alpha
	jr		c, l34af
	sub		144
	jr		c, invarg
	inc		a

l34af:
	dec		a
	add		a, a
	add		a, a
	add		a, a
	cp		0xa8
	jr		nc, invarg
	ld		bc, (udg)
	add		a, c
	ld		c, a
	jr		nc, l34c0
	inc		b

l34c0:
	jp		stack_bc1

invarg:								; sam
	rst		error_1					;
	defb	Bad_argument			;

tstzero:
	push	bc
	push	hl
	ld		c, a
	ld		a, (hl)					; sam
	inc		hl						;
	or		(hl)					;
	inc		hl						;
	or		(hl)					;
	inc		hl
	or		(hl)
	ld		a, c
	pop		hl
	pop		bc
	ret		nz
	scf
	ret

x80_fcp_gz:
	call	tstzero
	ret		c
	ld		a, 0xff					; zx81
	jr		sign_to_c				;

x80_fnot:
	call	tstzero
	jr		fp_0_1					; zx81
									;
x80_fcp_lz:							;
	xor		a						;
									;
sign_to_c:							;
	inc		hl						;
	xor		(hl)					;
	dec		hl						;
	rlca							;
									;
fp_0_1:								;
	push	hl						;
	ld		a, 0
	ld		(hl), a
	inc		hl
	ld		(hl), a
	inc		hl
	rla
	ld		(hl), a
	rra
	inc		hl
	ld		(hl), a
	inc		hl
	ld		(hl), a
	pop		hl
	ret

x80_fbor:
	ex		de, hl
	call	tstzero
	ex		de, hl
	ret		c
	scf								; zx81
	jr		fp_0_1					;

x80_fband:
	ex		de, hl
	call	tstzero
	ex		de, hl
	ret		nc
	and		a						; zx81
	jr		fp_0_1					;

x80_fbands:
	ex		de, hl
	call	tstzero
	ex		de, hl
	ret		nc
	dec		de						; zx81
	xor		a						;
	ld		(de), a					;
	dec		de						;
	ld		(de), a					;
	inc		de						; se
	inc		de						;
	ret								; zx81
									;
x80_fcp:							;
	ld		a, b					;
	bit		2, a					;
	jr		nz, ex_or_not			;
	dec		a						;
									;
ex_or_not:							;
	rrca							;
	jr		nc, nu_or_str			;
	push	af						;
	push	hl						;
	call	x80_fxch				;
	pop		de						;
	ex		de, hl					;
	pop		af						;
									;
nu_or_str:							;
	rrca							;  |
	push	af						;  |
	bit		2, a					; \|/
	jr		nz, strings				; \|/
	call	x80_fsub				;
	jr		end_tests				;
									;
strings:							;
	call	stk_fetch				;
	push	de						;
	push	bc						;
	call	stk_fetch				;
	pop		hl						;
									;
byte_comp:							;
	ld		a, h					;
	or		l						;
	ex		(sp), hl				;
	ld		a, b					;
	jr		nz, sec_plus			;
	or		c						;
									;
secnd_low:							;
	pop		bc						;
	jr		z, both_null			;
	pop		af						;
	ccf								;
	jr		str_test				;
									;
both_null:							;
	pop		af						;
	jr		str_test				;
									;
sec_plus:							;
	or		c						;
	jr		z, frst_less			;
	ld		a, (de)					;
	sub		(hl)					;
	jr		c, frst_less			;
	jr		nz, secnd_low			;
	dec		bc						;
	inc		de						;
	inc		hl						;
	ex		(sp), hl				;
	dec		hl						;
	jr		byte_comp				;
									;
frst_less:							;
	pop		bc						;
	pop		af						;
	and		a						;
									;
str_test:							;
	push	af						;
	fwait							;
	fstk0							;
	fce								;
									;
end_tests:							;
	pop		af						;
	push	af						;
	call	c, x80_fnot				;
	pop		af
	push	af
	call	nc, x80_fcp_gz
	pop		af						; zx81
	rrca							;
	call	nc, x80_fnot			;
	ret								;
									;
x80_fcat:							;
	call	stk_fetch				;
	push	de						;
	push	bc						;
	call	stk_fetch				;
	pop		hl						;
	push	hl						;
	push	de						;
	push	bc						;
	add		hl, bc					;
	ld		b, h					;
	ld		c, l					;
	rst		bc_spaces				;
	call	stk_store				;
	pop		bc						;
	pop		hl						;
	ld		a, b					;
	or		c						;
	jr		z, other_str			;
	ldir							;
									;
other_str:							;
	pop		bc						;
	pop		hl						;
	ld		a, b					;
	or		c						;
	jr		z, stk_pntrs			;
	ldir							;
									;
stk_pntrs:							;
	ld		hl, (stkend)			;
									
l359a:								; zx81
	ld		d, h					;
	ld		e, l					;
	dec		hl
	dec		hl
	dec		hl
	dec		hl
	dec		hl
	ret

x80_fchrs:							; zx81
	call	fp_to_a					;
	jr		c, report_b2			;
	jr		nz, report_b2			;
	call	bc_spaces1				;
	ld		(de), a					;
	jr		x360f

report_b2:							; zx81
	rst		error_1					;
	defb	Integer_out_of_range	;

x80_fval:
	rst		get_ch
	push	hl
	ld		a, b
	add		a, 227
	sbc		a, a
	push	af
	call	stk_fetch				; zx81
	push	de						;
	inc		bc						;
	rst		bc_spaces				;
	pop		hl						;
	ld		(chadd), de				;
	push	de						;
	ldir							;
	ex		de, hl					;
	dec		hl						;
	ld		(hl), ctrl_n_l			;
	res		7, (iy + _flags)		;
	call	scanning
	cp		ctrl_n_l
	jr		nz, l35dc
	pop		hl
	pop		af
	xor		(iy + _flags)
	and		%01000000

l35dc:
	jp		nz, report_c
	ld		(chadd), hl				; zx81
	set		7, (iy + _flags)		;
	call	scanning				;
	pop		hl						;
	ld		(chadd), hl				;
	jr		stk_pntrs				;

x80_fstrs:
	ld		a, (attrt)				; se
	ex		af, af'					;'
	call	bc_spaces1
	ld		(kcur), hl
	push	hl
	ld		hl, (curchl)
	push	hl
	ld		a, 0xff
	call	l1601
	call	print_fp
	pop		hl
	call	chanflag
	ex		af, af'					;'se
	ld		(attrt), a				;
	pop		de						; zx81
	ld		hl, (kcur)				;
	and		a						;
	sbc		hl, de					;
	ld		b, h					;
	ld		c, l					;

x360f:								; zx81
	call	stk_store				;
	ex		de, hl					;
	ret

x80_fread:
	ld		hl, (curchl)
	push	hl
	call	l207c
	call	chltchk
	jr		nz, x3621
	halt

x3621:
	call	inputad
	ld		bc, 0
	jr		nc, x362c
	inc		c
	rst		bc_spaces
	ld		(de), a

x362c:
	call	stk_store
	pop		hl
	call	chanflag
	jp		stk_pntrs

x80_fasc:							; zx81
	call	stk_fetch				;
	ld		a, b					;
	or		c						;
	jr		z, stk_code				;
	ld		a, (de)					;
									;
stk_code:							;
	jp		stack_a					;
									;
x80_flen:							;
	call	stk_fetch				;
	jp		stack_bc1				;
									;
x80_fdjnz:							;
	exx								;
	push	hl						;
	ld		hl, breg				;
	dec		(hl)					;
	pop		hl						;
	jr		nz, jump_2				;
	inc		hl						;
	exx								;
	ret								;
									;
x80_fjp:							;
	exx								;
									;
jump_2:								;
	ld		e, (hl)					;
	ld		a, e					;
	rla								;
	sbc		a, a					;
	ld		d, a					;
	add		hl, de					;
	exx								;
	ret								;

x80_fjpt:
	inc		de
	inc		de
	ld		a, (de)					; zx81
	dec		de						
	dec		de
	and		a						; zx81
	jr		nz, x80_fjp				;
	exx								;
	inc		hl						;
	exx								;
	ret								;
									;
x80_fce:							;
	pop		af						;
	exx								;
	ex		(sp), hl				;
	exx								;
	ret								;
									;
x80_fmod:							;
	fwait							;
	fst		1						; was 0
	fdel							;
	fmove							;
	fgt		1						; was 0
	fdiv							;
	fint							;
	fgt		1						; was 0
	fxch							;
	fst		1						; was 0
	fmul							;
	fsub							;
	fgt		1						; was 0
	fce								;
	ret								;
									;
x80_fint:							;
	fwait							;
	fmove							;
	fcp		.lz						;
	fjpt	x_neg					;
	ftrn							;
	fce								;
	ret								;
									;
x_neg:								;
	fmove							;
	ftrn							;
	fst		0						;
	fsub							;
	fgt		0						;
	fxch							;
	fnot							;
	fjpt	exit					;
	fstk1							;
	fsub							;
									;
exit:								;
	fce								;
	ret								;
									;
x80_fexp:							;
	fwait							;
	fstk							;
	defb	0xf1, 0x38, 0xaa, 0x3b, 0x29
	fmul							;
	fmove							;
	fint							;
	fst		3						;
	fsub							;
	fmove							;
	fadd							;
	fstk1							;
	fsub							;
	defb	0x88, 0x13, 0x36, 0x58, 0x65, 0x66, 0x9d, 0x78
	defb	0x65, 0x40, 0xa2, 0x60, 0x32, 0xc9, 0xe7, 0x21
	defb	0xf7, 0xaf, 0x24, 0xeb, 0x2f, 0xb0, 0xb0, 0x14
	defb	0xee, 0x7e, 0xbb, 0x94, 0x58, 0xf1, 0x3a, 0x7e
	defb	0xf8, 0xcf				;
	fgt		3						;
	fce								;
	call	fp_to_a					;
	jr		nz, n_negtv				;
	jr		c, report6_2			;
	add		a, (hl)					;
	jr		nc, result_ok			;
									;
report6_2:							;
	rst		error_1					;
	defb	Number_too_large		;
									;
n_negtv:							;
	jr		c, rslt_zero			;
	sub		(hl)					;
	jr		nc, rslt_zero			;
	neg								;
									;
result_ok:							;
	ld		(hl), a					;
	ret								;
									;
rslt_zero:							;
	fwait							;
	fdel							;
	fstk0							;
	fce								;
	ret								;
									;
x80_flogn:							;
	fwait							;
	frstk
	fmove							; zx81
	fcp		.gz						;
	fjpt	valid					;
	fce								;
									;
x36e6:								;
	rst		error_1					;
	defb	Bad_argument			;
									;
valid:								;
	fce								;
	ld		a, (hl)					;
	ld		(hl), 0x80				;
	call	stack_a					;
	fwait							;
	fstk							;
	defb	0x38, 0x00				;
	fsub							;
	fxch							;
	fmove							;
	fstk							;
	defb	0xf0, 0x4c, 0xcc, 0xcc, 0xcd
	fsub							;
	fcp		.gz						;
	fjpt	gre_8					;
	fxch							;
	fstk1							;
	fsub							;
	fxch							;
	fce								;
	inc		(hl)					;
	fwait							;
									;
gre_8:								;
	fxch							;
	fstk							;
	defb	0xf0, 0x31, 0x72, 0x17, 0xf8
	fmul							;
	fxch							;
	fstk_5							;
	fsub							;
	fstk_5							;
	fsub							;
	fmove							;
	fstk							;
	defb	0x32, 0x20				;
	fmul							;
	fstk_5							;
	fsub							;
	defb	0x8c, 0x11, 0xac, 0x14, 0x09, 0x56, 0xda, 0xa5
	defb	0x59, 0x30, 0xc5, 0x5c, 0x90, 0xaa, 0x9e, 0x70
	defb	0x6f, 0x61, 0xa1, 0xcb, 0xda, 0x96, 0xa4, 0x31
	defb	0x9f, 0xb4, 0xe7, 0xa0, 0xfe, 0x5c, 0xfc, 0xea
	defb	0x1b, 0x43, 0xca, 0x36, 0xed, 0xa7, 0x9c, 0x7e
	defb	0x5e, 0xf0, 0x6e, 0x23, 0x80, 0x93
	fmul							;
	fadd							;
	fce								;
	ret								;
									;
x80_fget:							;
	fwait							;
	fstk							;
	defb	0xee, 0x22, 0xf9, 0x83, 0x6e
	fmul							;
	fmove							;
	fstk_5							;
	fadd							;
	fint							;
	fsub							;
	fmove							;
	fadd							;
	fmove							;
	fadd							;
	fmove							;
	fabs							;
	fstk1							;
	fsub							;
	fmove							;
	fcp		.gz						;
	fst		0						;
	fjpt	zplus					;
	fdel							;
	fce								;
	ret								;
									;
zplus:								;
	fstk1							;
	fsub							;
	fxch							;
	fcp		.lz						;
	fjpt	yneg					;
	fneg							;
									;
yneg:								;
	fce								;
	ret								;
									;
x80_fcos:							;
	fwait							;
	fget							;
	fabs							;
	fstk1							;
	fsub							;
	fgt		0						;
	fjpt	c_ent					;
	fneg							;
	fjp		c_ent					;
									;
x80_fsin:							;
	fwait							;
	fget							;
									;
c_ent:								;
	fmove							;
	fmove							;
	fmul							;
	fmove							;
	fadd							;
	fstk1							;
	fsub							;
	defb	0x86, 0x14, 0xe6, 0x5c, 0x1f, 0x0b, 0xa3, 0x8f
	defb	0x38, 0xee, 0xe9, 0x15, 0x63, 0xbb, 0x23, 0xee
	defb	0x92, 0x0d, 0xcd, 0xed, 0xf1, 0x23, 0x5d, 0x1b
	defb	0xea					;
	fmul							;
	fce								;
	ret								;
									;
;x80_ftan:							;
;	fwait							;
;	fmove							;
;	fsin							;
;	fxch							;
;	fcos							;
;	fdiv							;
;	fce								;
;	ret								;
									;
x80_fatan:							;
	call	x80_frstk				;
	ld		a, (hl)					;
	cp		0x81					;
	jr		c, small				;
	fwait							;
	fstk1							;
	fneg							;
	fxch							;
	fdiv							;
	fmove							;
	fcp		.lz						;
	fstkpix_5						;
	fxch							;
	fjpt	cases					;
	fneg							;
	fjp		cases					;
									;
small:								;
	fwait							;
	fstk0							;
									;
cases:								;
	fxch							;
	fmove							;
	fmove							;
	fmul							;
	fmove							;
	fadd							;
	fstk1							;
	fsub							;
	defb	0x8c, 0x10, 0xb2, 0x13, 0x0e, 0x55, 0xe4, 0x8d
	defb	0x58, 0x39, 0xbc, 0x5b, 0x98, 0xfd, 0x9e, 0x00
	defb	0x36, 0x75, 0xa0, 0xdb, 0xe8, 0xb4, 0x63, 0x42
	defb	0xc4, 0xe6, 0xb5, 0x09, 0x36, 0xbe, 0xe9, 0x36
	defb	0x73, 0x1b, 0x5d, 0xec, 0xd8, 0xde, 0x63, 0xbe
	defb	0xf0, 0x61, 0xa1, 0xb3, 0x0c
	fmul							;
	fadd							;
	fce								;
	ret								;
									;
x80_fasin:							;
	fwait							;
	fmove							;
	fmove							;
	fmul							;
	fstk1							;
	fsub							;
	fneg							;
	fsqrt							;
	fstk1							;
	fadd							;
	fdiv							;
	fatan							;
	fmove							;
	fadd							;
	fce								;
	ret								;
									;
x80_facos:							;
	fwait							;
	fasin							;
	fstkpix_5						;
	fsub							;
	fneg							;
	fce								;
	ret								;

x80_fsqrt:							; se
	fwait							;
	frstk							;
	fst		3						;
	fce								;
	ld		a, (hl)					;
	and		a						;
	ret		z						;
	inc		hl						;
	bit		7, (hl)					;
	jp		nz, x36e6				;
	ld		hl, mem_3				;
	ld		a, (hl)					;
	xor		%10000000				;
	sra		a						;
	inc		a						;
	jr		z, l382f				;
	jp		p, l382f				;
	dec		a						;
									;
l382f:								;
	xor		%10000000				;
	ld		(hl), a					;
	fwait							;
									;
l3833:								;
	fmove							;
	fgt		3						;
	fst		4						;
	fdiv							;
	fgt		3						;
	fadd							;
	fstk_5							;
	fmul							;
	fst		3						;
	fgt		4						;
	fsub							;
	fabs							;
	fcp		.gz						;
	fjpt	l3833					;
	fdel							;
	fgt		3						;
	fce								;
	ret

x80_ftop:							; zx81
	fwait							;
	fxch							;
	fmove							;
	fnot							;
	fjpt	xis0					;
	flogn							;
	fmul							;
	fce								;
	jp		x80_fexp				;
									;
xis0:								;
	fdel							;
	fmove							;
	fnot							;
	fjpt	one						;
	fstk0							;
	fxch							;
	fcp		.gz						;
	fjpt	last					;
	fstk1							;
	fxch							;
	fdiv							;
									;
one:								;
	fdel							;
	fstk1							;
									;
last:								;
	fce								;
	ret								;

x80_fhexs:							; se
	call	fp_to_bc				;
	jp		c, report_b2			;
	jp		nz, report_b2			;
	push	bc						;
	ld		bc, 4					;
	rst		bc_spaces				;
	pop		hl						;
	push	de						;
	ld		a, h					;
	call	l3882					;
	ld		a, l					;
	call	l3882					;
	pop		de						;
	call	stk_store				;
	jp		stk_pntrs				;
									;
l3882:								;
	ld		h, a					;
	rlca							;
	rlca							;
	rlca							;
	rlca							;
	call	l388b					;
	ld		a, h					;
									;
l388b:								;
	and		%00001111				;
	cp		0x0a					;
	jr		c, l3893				;
	add		a, 7					;
									;
l3893:								;
	add		a, 0x30					;
	ld		(de), a					;
	inc		de						;
	ret								;
									;
l3898:								;
	ld		hl, (chars)				;
	inc		h						;
	ld		a, c					;
	rrca							;
	rrca							;
	rrca							;
	and     %11100000				;
	xor		b						;
	ld		e, a					;
	ld		a, c					;
	and		%00011000				;
	xor		%01000000				;
	ld		d, a					;
	ld		b, 2					;
	jp		l253b					;
									;
l38af:								;
	cp		OK						;
	ret		z						;
	cp		STOP_statement			;
	ret		z						;
	ld		hl, (onerrflag)			;
	ld		a, h					;
	cp		0xff					;
	ret		z						;
	cp		0xfe					;
	jr		z, l38c7				;
	ld		(newppc), hl			;
	ld		(iy + _nsppc), 0		;
									;
l38c7:								;
	ld		(iy + _errnr), OK		;
	jp		l1555					;
									;
l38ce:								;
	ld		bc, ay_128dat			;
	out		(c), a					;
	ld		e, a					;
	ld		a, (iy + _bordcr)		;
	rrca							;
	rrca							;
	rrca							;
	and		7						;
	ld		bc, ay_tmxdat			;
	out		(c), e					;
	out		(ula), a				;
	ret								;
									;
l38e6:								;
	call	l105e					;
	ld		(eppc), bc				;
									;
l38ec:								;
	call	setmin					;
	call	clslower				;
	res		5, (iy + _flage)		;
	call	edit_key				;
	ld		sp, (errsp)				;
	jp		l0f8e					;
									;
l38ff:								;
	defw	0xffff					;
									;
syntax3:							;
	call	find_int				;
	ld		a, b					;
	cp		0x40					;
	jr		l3914					;
									;
l3909:								;
	call	l3915					;
	ld		a, b					;
	cp		' '						;
	jr		nc, l391b				;
	ld		a, c					;
	cp		0x18					;
									;
l3914:								;
	ret		c						;
									;
l3915:								;
	call	stk_to_bc				;
	ld		a, d					;
	add		a, e					;
	ret		nc						;
									;
l391b:								;
	rst		error_1					;
	defb	Integer_out_of_range	;
									;
l391d:								;
	bit		3, (iy + _flags)		;
	jp		nz, l0b65				;
	jp		l0b24					;
									;
l3927:								;
	rst		next_ch					;
	call	check_end				;
	ld		a, (flags)				;
	or		%00001000				;
	jp		l1f1f					;
									;
l3934:								;
	call	poke1					;
	ld		e, a					;
	ld		d, c					;
	ld		a, b					;
	and		a						;
	jp		nz, invcolerr			;
	ld		a, c					;
	cp		65						;
	jp		nc, invcolerr			;
									;
l3943:								;
	ld		bc, ulaplus_reg			;
	out		(c), a					;
	ld		b, 0xff					;
	out		(c), e					;
	ret								;
									;
l394d:								;
	ld		a, 64					;
	ld		e, 0					;
	call	l3943					;
									;
l3954:								;
	xor		a						;
	ld		hl, palbuf				;
									;
l3958:								;
	ld		e, (hl)					;
	call	l3943					;
	inc		a						;
	inc		l						;
	cp		64						;
	jr		c, l3958				;
	ret								;
									;
l3963:								;
	bit		2, (iy + _flags)		;
	jr		nz, l3989				;
	cp		0x15					;
	jr		nc, l3977				;
	cp		0x0f					;
	jr		c, l3977				;
	set		2, (iy + _flags)		;
	jr		l398d					;
									;
l3977:								;
	cp		6						;
	jr		c, l397f				;
	cp		0xa5					;
	jr		c, l398d				;
									;
l397f:								;
	exx								;
	push	de						;
	exx								;
	call	l3990					;
	exx								;
	pop		de						;
	exx								;
	ret								;
									;
l3989:								;
	res		2, (iy + _flags)		;
									;
l398d:								;
	jp		add_char				;
									;
l3990:								;
	push	de						;
	pop		ix						;
	sub		0xa5					;
	ld		de, k_token - 1			;
	push	af						;
	call	l0c41					;
	jr		c, l39a7				;
	ld		a, ' '					;
	bit		0, (iy + _flags)		;
	call	z, l39c6				;
									;
l39a7:								;
	ld		a, (de)					;
	and		%01111111				;
	call	l39c6					;
	ld		a, (de)					;
	inc		de						;
	add		a, a					;
	jr		nc, l39a7				;
	pop		de						;
	cp		'$'						;
	jr		z, l39ba				;
	cp		0x82					;
	ret		c						;
									;
l39ba:								;
	ld		a, d					;
	cp		'&'						;
	ret		z						;
	cp		0x60					;
	ret		z						;
	cp		0x03					;
	ret		c						;
	ld		a, ' '					;
									;
l39c6:								;
	push	de						;
	push	ix						;
	pop		de						;
	rst		print_a					;
	push	de						;
	pop		ix						;
	pop		de						;
	ret								;
									;
l39d0:								;
	set		7, (iy + _errnr)		;
	call	editor					;
	ld		ix, (eline)				;
									;
l39db:								;
	push	ix						;
	ld		hl, k_token + 89		;
	ld		c, tk_usr - 6			;
	call	l3a9b					;
	cp		'I'						;
	jr		nz, l39ec				;
	call	l3a15					;
									;
l39ec:								;
	pop		ix						;
	ld		hl, k_token				;
	ld		c, tk_rnd - 6			;
									;
l39f3:								;
	call	l3a9b					;
	cp		ctrl_n_l				;
	ret		z						;
	cp		tk_rem					;
	ret		z						;
	jp		l3a01					;
									;
l39ff:								;
	defw	0xffff					;
									;
l3a01:								;
	cp		'"'						;
	jr		nz, l3a15				;
									;
l3a05:								;
	inc		ix						;
	ld		a, (ix + 0x00)			;
	cp		ctrl_n_l				;
	ret		z						;
	cp		'"'						;
	jr		nz, l3a05				;
	inc		ix						;
	jr		l39f3					;
									;
l3a15:								;
	push	ix						;
	pop		de						;
	cp		(hl)					;
	jr		nz, l3a40				;
									;
l3a1b:								;
	inc		ix						;
									;
l3a1d:								;
	inc		hl						;
									;
l3a1e:								;
	call	l3a9b					;
	cp		'.'						;
	jr		z, l3a5f				;
	ld		b, (hl)					;
	cp		' '						;
	jr		z, l3a52				;
	push	af						;
	ld		a, b					;
	cp		' '						;
	jr		nz, l3a51				;
	pop		af						;
	inc		hl						;
	jr		l3a1e					;
									;
l3a34:								;
	bit		7, (hl)					;
	jr		z, l3a1b				;
	ld		a, (ix + 0x01)			;
	call	l3a9e					;
	jr		nc, l3a5f				;
									;
l3a40:								;
	inc		c						;
	push	de						;
	pop		ix						;
									;
l3a44:								;
	bit		7, (hl)					;
	inc		hl						;
	jr		z, l3a44				;
	ld		a, c					;
	and		a						;
	jr		nz, l39f3				;
	inc		ix						;
									;
l3a4f:								;
	jr		l39db					;
									;
l3a51:								;
	pop		af						;
									;
l3a52:								;
	res		7, b					;
	cp		b						;
	jr		z, l3a34				;
	ld		a, b					;
	cp		' '						;
	jr		nz, l3a40				;
	inc		hl						;
	jr		l3a1d					;
									;
l3a5f:								;
	ld		a, (ix + 0x01)			;
	cp		' '						;
	jr		nz, l3a68				;
	inc		ix						;
									;
l3a68:								;
	dec		de						;
	ld		a, (de)					;
	cp		' '						;
	jr		z, l3a74				;
	inc		de						;
	call	l3a9e					;
	jr		c, l3a40				;
									;
l3a74:								;
	inc		c						;
	inc		c						;
	inc		c						;
	inc		c						;
	inc		c						;
	inc		c						;
	ld		(ix + 0x00), c			;
	ld		hl, (kcur)				;
	and		a						;
	sbc		hl, de					;
	jr		c, l3a92				;
	add		hl, de					;
	push	ix						;
	pop		bc						;
	scf								;
	sbc		hl, bc					;
	jr		nc, l3a92				;
	ld		(kcur), de				;
									;
l3a92:								;
	push	de						;
	ex		(sp), ix				;
	pop		hl						;
	call	reclaim_1				;
	jr		l3a4f					;
									;
l3a9b:								;
	ld		a, (ix + 0x00)			;
									;
l3a9e:								;
	bit		1, (iy + _mode)			;
	ret		nz						;
	call	alpha					;
	ret		nc						;
	and		%11011111				;
	ret								;
									;
l3aa9:								;
	ld		hl, (stkend)			;
	ld		b, 2					;
	cp		ctrl_n_l				;
	jr		z, l3ac8				;
	cp		':'						;
	jr		z, l3ac8				;
	call	class_6					;
	ld		b, 1					;
									;
l3abc:								;
	rst		get_ch					;
	cp		','						;
	jr		nz, l3ac8				;
	push	bc						;
	call	sexpt1num				;
	pop		bc						;
	djnz	l3abc					;
									;
l3ac8:								;
	call	check_end				;
	ld		a, b					;
	cp		2						;
	jr		z, l3ad6				;
	cp		1						;
	jr		z, l3ad9				;
	jr		l3adc					;
									;
l3ad6:								;
	fwait							;
	fstk10							;
	fce								;
									;
l3ad9:								;
	fwait							;
	fstk10							;
	fce								;
									;
l3adc:								;
	fwait							;
	fst		1						;
	fdel							;
	fst		0						;
	fdel							;
	fce								;
	ld		de, (prog)				;
	ld		hl, (vars)				;
	or		a						;
	sbc		hl, de					;
	ret		z						;
	call	l3c44					;
	ld		hl, (mem_1_2)			;
	call	l30a9					;
	jp		c, parerr				;
	ex		de, hl					;
	ld		hl, (mem_0_2)			;
	jr		l3b01					;
									;
l3aff:								;
	defw	0xffff					;
									;
l3b01:								;
	add		hl, de					;
	ld		de, 16384				;
	or		a						;
	sbc		hl, de					;
	jp		nc, parerr				;
	ld		hl, (prog)				;
									;
l3b0e:								;
	call	next_one				;
	inc		hl						;
	inc		hl						;
	ld		(mem_4_3), hl			;
	inc		hl						;
	inc		hl						;
	ld		(mem_2), de				;
									;
l3b1c:								;
	ld		a, (hl)					;
	call	number					;
	cp		ctrl_n_l				;
	jr		z, l3b29				;
	call	l3b63					;
	JR		l3b1c					;
									;
l3b29:								;
	ld		de, (mem_2)				;
	ld		hl, (vars)				;
	and		a						;
	sbc		hl, de					;
	ex		de, hl					;
	jr		nz, l3b0e				;
	call	l3c44					;
	ld		b, d					;
	ld		c, e					;
	ld		de, 0					;
	ld		hl, (prog)				;
									;
l3b41:								;
	push	bc						;
	push	de						;
	push	hl						;
	ld		hl, (mem_1_2)			;
	call	l30a9					;
	ld		de, (mem_0_2)			;
	add		hl, de					;
	ex		de, hl					;
	pop		hl						;
	ld		(hl), d					;
	inc		hl						;
	ld		(hl), e					;
	inc		hl						;
	ld		c, (hl)					;
	inc		hl						;
	ld		b, (hl)					;
	inc		hl						;
	add		hl, bc					;
	pop		de						;
	inc		de						;
	pop		bc						;
	dec		bc						;
	ld		a, b					;
	or		c						;
	jr		nz, l3b41				;
	ret								;
									;
l3b63:								;
	inc		hl						;
	ld		(mem_4_1), hl			;
	ex		de, hl					;
	ld		bc, 7					;
	ld		hl, l241e				;
	cpir							;
	ex		de, hl					;
	ret		nz						;
	ld		c, 0					;
									;
l3b74:								;
	ld		a, (hl)					;
	cp		' '						;
	jr		z, l3b94				;
	call	numeric					;
	jr		nc, l3b94				;
	cp		'.'						;
	jr		z, l3b94				;
	cp		ctrl_number				;
	jr		z, l3b98				;
	or		%00100000				;
	cp		'e'						;
	jr		nz, l3b90				;
	ld		a, b					;
	or		c						;
	jr		nz, l3b94				;
									;
l3b90:								;
	ld		hl, (mem_4_1)			;
	ret								;
									;
l3b94:								;
	inc		bc						;
	inc		hl						;
	jr		l3b74					;
									;
l3b98:								;
	ld		(mem_2_2), bc			;
	push	hl						;
	call	number					;
	call	l3c77					;
	ld		a, (hl)					;
	pop		hl						;
	cp		':'						;
	jr		z, l3bac				;
	cp		ctrl_n_l				;
	ret		nz						;
									;
l3bac:								;
	inc		hl						;
	call	l33b8					;
	call	fp_to_bc				;
	ld		h, b					;
	ld		l, c					;
	call	line_addr				;
	jr		c, l3bc1				;
	jr		z, l3bc6				;
	ld		a, (hl)					;
	and		%11000000				;
	jr		z, l3bc6				;
									;
l3bc1:								;
	ld		hl, 16383				;
	jr		l3bd7					;
									;
l3bc6:								;
	ld		(mem_3_4), hl			;
	call	l3c4c					;
	ld		hl, (mem_1_2)			;
	call	l30a9					;
	ld		de, (mem_0_2)			;
	add		hl, de					;
									;
l3bd7:								;
	ld		de, mem_2_4				;
	push	hl						;
	call	l3c7d					;
	ld		e, b					;
	inc		e						;
	ld		d, 0					;
	push	de						;
	push	hl						;
	ld		l, e					;
	ld		h, 0					;
	ld		bc, (mem_2_2)			;
	or		a						;
	sbc		hl, bc					;
	ld		(mem_2_2), hl			;
	jr		z, l3c0b				;
	jr		c, l3c01				;
	ld		b, h					;
	ld		c, l					;
	ld		hl, (mem_4_1)			;
	call	make_room				;
	jr		l3c0b					;
									;
l3bff:								;
	defw	0xffff					;
									;
l3c01:								;
	dec		bc						;
	dec		e						;
	jr		nz, l3c01				;
	ld		hl, (mem_4_1)			;
	call	reclaim_2				;
									;
l3c0b:								;
	ld		de, (mem_4_1)			;
	pop		hl						;
	pop		bc						;
	ldir							;
	ex		de, hl					;
	ld		(hl), 14				;
	pop		bc						;
	inc		hl						;
	push	hl						;
	call	stack_bc1				;
	pop		de						;
	ld		bc, 5					;
	ldir							;
	ex		de, hl					;
	push	hl						;
	call	fp_to_bc				;
	ld		hl, (mem_4_3)			;
	push	hl						;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ld		hl, (mem_2_2)			;
	add		hl, de					;
	ex		de, hl					;
	pop		hl						;
	ld		(hl), e					;
	inc		hl						;
	ld		(hl), d					;
	ld		hl, (mem_2)				;
	ld		de, (mem_2_2)			;
	add		hl, de					;
	ld		(mem_2), hl				;
	pop		hl						;
	ret								;
									;
l3c44:								;
	ld		hl, (vars)				;
	ld		(mem_3_4), hl			;
	jr		l3c58					;
									;
l3c4c:								;
	ld		hl, (prog)				;
	ld		de, (mem_3_4)			;
	or		a						;
	sbc		hl, de					;
	jr		z, l3c72				;
									;
l3c58:								;
	ld		hl, (prog)				;
	ld		bc, 0					;
									;
l3c5e:								;
	push	bc						;
	call	next_one				;
	ld		hl, (mem_3_4)			;
	and		a						;
	sbc		hl, de					;
	jr		z, l3c6f				;
	ex		de, hl					;
	pop		bc						;
	inc		bc						;
	jr		l3c5e					;
									;
l3c6f:								;
	pop		de						;
	inc		de						;
	ret								;
									;
l3c72:								;
	ld		de, 0					;
	ret								;
									;
l3c76:								;
	inc		hl						;
									;
l3c77:								;
	ld		a, (hl)					;
	cp		' '						;
	jr		z, l3c76				;
	ret								;
									;
l3c7d:								;
	push	de						;
	ld		bc, -10000				;
	call	l3ca0					;
	ld		bc, -1000				;
	call	l3ca0					;
	ld		bc, -100				;
	call	l3ca0					;
	ld		c, -10					;
	call	l3ca0					;
	ld		a, l					;
	add		a, '0'					;
	ld		(de), a					;
	inc		de						;
	ld		b, 4					;
	pop		hl						;
	jp		l2414					;
									;
l3ca0:								;
	xor		a						;
									;
l3ca1:								;
	add		hl, bc					;
	inc		a						;
	jr		c, l3ca1				;
	jp		l0a7e					;
									;
scanfix:							;
	ld		(oldsp), sp				;
	ld		hl, 6					;
	add		hl, sp					;
	ld		e, (hl)					;
	inc		hl						;
	ld		d, (hl)					;
	ld		h, d					;
	ld		l, e					;
									;
nextchar:							;
	inc		hl						;
	ld		a, (hl)					;
									;
nextchar2:							;
	cp		')'						;
	jr		z, endfn				;
	cp		0x0e					;
	jr		nz, nextchar			;
	call	l18b4					;
	jr		nextchar2				;
									;
endfn:								;
	or		a						;
	sbc		hl, de					;
	ld		b, h					;
	ld		c, l					;
	ld		a, h					;
	cpl								;
	ld		h, a					;
	ld		a, l					;
	cpl								;
	ld		l, a					;
	inc		hl						;
	add		hl, sp					;
	ld		sp, hl					;
	ex		de, hl					;
	ld		ix, (oldsp)				;
	push	ix						;
	push	de						;
	push	hl						;
	push	bc						;
	ldir							;
	call	scanning				;
	pop		bc						;
	pop		de						;
	pop		hl						;
	jp		l11cb					;
									;
	defb	0x00					; end of code
									;
cursors:							;
	incbin		"data/cursors.data"		;
									;
font:								;
	incbin		"data/GenevaMono.data"	;

