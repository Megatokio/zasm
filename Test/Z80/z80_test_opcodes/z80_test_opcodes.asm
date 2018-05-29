
#target sna
#head 27
#insert "empty_sna_head"
#code $4000,$c000
#insert "empty_sna_page1"
#data $c000,$4000



;	bc = Rückgabewert
;	rst 16: print char in A

OPKAN		equ	$1601		; Öffne Kanal in A

PRTBUF		equ	$5b00		; $100 Bytes Druckerpuffer
FRAMES		equ	$5C78		; FRAMES: 3 Byte Bildzaehler (Uhr)


sp_save		data	2
contended_banks	data	1		; bitmask of contended banks, expected: %00000010
cc2_per_irpt	data	2
cc_per_im0_ackn	data	1
cc_per_im1_ackn	data	1
cc_per_im2_ackn	data	1
cc_waitmap_start data	2
cc_per_line	data	2
early_halt	data	1


scratch		data	256
stack		data	256		; not in contended ram!


; -------------	entry point ----------------------
start:
		ld	(sp_save),sp
		ld	sp,stack+256

		ld	a,2			; Stream: Hauptbildschirm
		call	OPKAN			; Kanal öffnen
		call	print_msg		
		defm	"-- Z80 Test Programm (c) 2004/5 Kio --",$00

		ld	a,irptvector>>8
		ld	i,a			; setup i for im2 irpt table

	; basic clock calc

		call	test1			; calc cpu clock

	; test the current bank (bank 2 $8000..$BFFF) for contention

		call	print_msg
		defm	$0d,"Bank 2 wait states: ",$00
		call	is_page_contended
		call	print_yes_no		
		jp	c,abort

	; test all visible banks for contention

		call	test_4_contention
		ld	(contended_banks),a
		cp	a,%0010
		jr	z,s0
		call	print_msg
		defm	$0d,"  unexpected map of contention",$00
s0			

	; assert that WAIT increments the R register

		call	print_msg
		defm	$0d,"WAIT increments R: ",$00			
		call	test_wait_incr_r	; wait and r register
		call	print_yes_no		
		jp	nc,abort

	; calc cc per irpt ackn

		call	print_msg
		defm	$0d,"cpu cycles per irpt ackn:",$00
		call	calc_cc_per_irpt_ackn
		
		call	print_msg
		defm	$0d,"  im0: ",$00
		ld	a,(cc_per_im0_ackn)
		call	printdec_a
		
		call	print_msg
		defm	"  im1: ",$00
		ld	a,(cc_per_im1_ackn)
		call	printdec_a

		call	print_msg
		defm	"  im2: ",$00
		ld	a,(cc_per_im2_ackn)
		call	printdec_a

		ld	a,(cc_per_im2_ackn)
		cp	19
		jp	z,s3
		call	print_msg
		defm	$0d,"  not the expected value [19]",$00
		jp	abort
s3
				
	; calculate exact cpu cc/frame/2
	; (cc/frame/2 because cc/frame > 65535)

		call	print_msg
		defm	$0d,"cpu cycles per frame: 2 * ",$00
		call	calc_cc2_per_irpt
		ld	(cc2_per_irpt),hl

		push	af			; R
		call	printdec		; hl
		pop	af	

	; war R im Erwartungsbereich?
		ld	b,a
		rrca				; schiebt bit 0 -> bit 7
		sub	38/2
		sub	1+ (56-38)/2 
		jr	c,s2
		ld	a,b

	; R war ungerade und/oder nicht im Erwartungsbereich [38..56]:
		call	print_msg
		defm	$0d,"  R = ",$00

		push	af
		call	printdec_a
		pop	af

		rrca
		jr	nc,s1
		call	print_msg
		defm	$0d,"  unexpectedly odd!",$00
s1		rlca

		sub	38
		sub	56-38+1
		jr	c,s2
		call	print_msg
		defm	$0d,"  not in expected range [38..56]",$00

s2	; early halt detected?
		ld	a,(early_halt)
		and	a
		jr	z,s9	; no
		call	print_msg
		defm	$0d,"HALT detects irpt 1 cc earlier",$00
s9

#if 1
	; validate internal timers

		call	print_msg
		defm	$0d,"validating test timers: ", $00

		; validate cc2_per_irpt			(implicitely)
		; validate at_hl_jp_de			(implicitely)
		; validate wait_cc			(implicitely)
		; validate restzeit_bis_irpt_x16
		; validate restzeit_bis_irpt_x4
		; validate restzeit_bis_irpt
	
		call	test_restzeit_x16		; aborts on failure
		call	test_restzeit_x4		; aborts on failure
		call	test_restzeit			; aborts on failure
		
		call	print_msg
		defm	"ok",$00
#endif
		

	; ---- following tests only with contention ----

		ld	a,(contended_banks)
		and	a,%0010
		jp	z,s4				; no contention
		


	; Find Start of Contention

		call	print_msg
		defm	$0d,"first wait cycle at: ",$00
		call	find_first_wait
		ld	(cc_waitmap_start),hl
		call	printdec

#if 1
	; Get and display contention pattern
	; 1: slow method (for emu test too)
	
		call	print_msg
		defm	$0d,"waitmap pattern: ",$00
		ld	hl,(cc_waitmap_start)
		ld	a,24
		call	get_waitmap
		call	print_msg
		defm	$0d,"  ",$00
		ld	hl,scratch
s5		ld	a,(hl)
		add	a,'0'
		call	print_char
		inc	hl
		ld	a,l
		cp	a,+(scratch+24)&$ff
		jr	nz,s5
				
	; Get and display contention pattern
	; 2: fast method

		ld	hl,(cc_waitmap_start)
		ld	a,2*16+1		; [nowait,wait] tupel
		call	get_waitmap_fast	; we'll ignore first and last data byte
		push hl				; hl -> next cc

		call	print_nl
		ld	de,scratch+1
s6		ld	a,(de)
		inc	de
		push	de
		call	printdec_a
		ld	a,'+'
		call	print_char
		pop	de
		
		ld	a,(de)
		inc	de
		push	de
		call	printdec_a
		ld	a,' '
		call	print_char
		pop	de

		ld	a,e
		cp	a,$ff&(scratch+1+16*2)
		jr	nz,s6
		
	; test whether pattern repeats as expected

		ld	hl,scratch+1
		ld	de,scratch+1+32
		ld	b,32+1
s7		ld	a,(de)
		cp	a,(hl)
		inc	hl
		inc	de
		jr	z,s8
		call	print_msg
		defm	$0d,"waitmap repeat not as expected",$00
		jp	abort			
s8		djnz	s7

	; calc and display cc/line:

		pop	hl			; -> next cc 

		ld	a,(scratch+1+32)	; last wait cycles
		ld	e,a
		sub	a			; a=0, cy=0
		ld	d,a
		sbc	hl,de			
		ld	de,(cc_waitmap_start)
		sbc	hl,de			; hl = cc/2lines
		sra	h
		rr	l
		ld	(cc_per_line),hl	; NOTE: assuming 16 blocks / line

		call	print_msg
		defm	$0d,"cpu cycles per line: ",$00
		call	printdec
#endif

	; calc opcode access patterns
		
		call	print_msg
		defm	$0d,"opcode memory access patterns:",$00
		call	test_opa
		

s4	; ---- resume for no contention ----


		ld	sp,(sp_save)
		im	1			; security
		ei				; ""

		call	print_nl			; final nl
		ld	bc,0			; bc = Rückgabewert
		ret				; finish
	
	
; -------------	abort on failure -----------------
abort:	
		ld	sp,(sp_save)		; restore SP
		im	1			; security
		ei				; ""

		call	print_msg		; print alert
		defm	$0d,"(abort) ",$00
		ld	bc,666			; ret_val
		ret


            
#include	"math.ass"
#include	"print.ass"
#include	"timer.ass"
#include	"contention.ass"
#include	"disass.ass"
#include	"op_tests_1.ass"





; ----------------------------------------------
;	Test 1:
;	Ermittelt die Interruptfrequenz auf 1/1000s genau
;	Annahme: FFB-Frequenz = 50 Hz
;	Annahme: Aktuelle Bank is waitstate-frei.
;
test1		call	print_msg			
		defm	$0d, "cpu clock: ", $00
		call	calcspeed	; -> hl.de MHz			
		push	de
		call	printdec
		ld	a,'.'
		call	print_char
		pop	hl
		call	printdec3
		call	print_msg
		defm	" MHz",$00
		ret



	






; ------------------------------------------------------------
;	Vergleiche hl und de
;	ret z:  wenn sie um max. +/1 1 abweichen 
;	ret nz: wenn sie mehr abweichen
cp_hl_de	and	a
		sbc	hl,de
		ret	z		; v1 - v2 == 0
		ld	a,h
		and	l
		inc	a
		ret	z		; v1 - v2 == -1 ist auch ok
		ld	a,l
		dec	a
		or	h
		ret			; v1 - v2 == +1 ist auch ok


; ------------------------------------------------------------
; allgemein verwendbare Interruptvektortabelle
; das Busbyte im Irpt Ackn Cycle muss $ff sein
; ------------------------------------------------------------

		defs	$ff - ($ & $ff)
irptvector	defw	$0000			; muss jeweils vorher gesetzt werden


; ------------------------------------------------------------
; calculate cpu speed
; interrupts must be enabled
; in:  --
; out: cpu clock = hl*1,000,000 + de*1,000
; mod: af,bc,de,hl
; fails for cpu clock > 65.535 MHz
; ------------------------------------------------------------

; Minimal Interrupt:
; die Interruptroutine muss bis ei mind. 32 Takte dauern incl. irpt ackn. B-)

;		irpt	ackn			; 19 T
inc_xhl_irpt	inc	(hl)			; 10 T		; cspeed_cell
		ei				;  4 T
		ret				; 10 T
						; 43 * 5 +7 +7 = 229 

cspeed_cell	data	1			; interrupt tickercell  -  FRAMES liegt im contended ram!

calcspeed:	ld	hl,inc_xhl_irpt
		ld	(irptvector),hl		; setup vector table
			
		ld	a,irptvector>>8
		ld	i,a			; setup i for table
		ld	hl,cspeed_cell			
		im	2			; setup irpt mode to use table

		ld	de,229/100		; pre-increment total loop count for setup and interrupt routine itself
		halt
		ld	a,(hl)			; 7 T
		add	a,5			; 7 T	; => run for 5 interrupts

cs1		ld	b,5			; 7
cs2		dec	b			; 5*4
		jp	nz,cs2			; 5*10
		inc	de			; 6
		cp	a,(hl)			; 7
		jp	nz,cs1			; 10
			
		im	1			
		ex	hl,de
			
; this took hl*100 ticks for 5/50 sec
; == hl*1,000 ticks for 1 sec
		ld	de,1000
		call	divide
; == hl*1,000,000 + de*1,000 ticks
		ret






#end














