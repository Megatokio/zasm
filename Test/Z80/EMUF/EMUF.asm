#!/usr/local/bin/zasm -o ../original/

#target	rom


; Z80-EMUF
; --------
; 
; Ein einfaches, benutzbares, emuliertes Z80-System, bestehend aus:


; very simple serial emulation:
; only data register, no control register
; read:		0xFF		no data
;			0x20-0xFE	ascii character
; write:	0x20-0xFE	ascii character

sio_data	equ	$fe

epromsize	equ	$2000		; eprom size = 8 kB
ramstart	equ	$4000		;
datasize	equ	$100		; monitor variables


; ------------------------------------------------------------
; data segment declaration
; ------------------------------------------------------------

#data		Systemvariablen,ramstart,datasize

tickercell	ds	2		; interrupt counter
ram_top		ds	2		; end of physical ram
last_cmd	ds	2		; what the monitor calls, if 'enter' is pressed
last_addr	ds	2		; last address used
appl_sp		ds	2		; stackpointer of z80 test application
break_byte	ds	1		; byte below breakpoint patch
break_addr	ds	2		; address of breakpoint patch


; ------------------------------------------------------------
; code segment
; ------------------------------------------------------------

#code		Eprom,0,epromsize


; ------------------------------------------------------------
; reset entry
; ------------------------------------------------------------

reset:	di
		im	1
		jp	reset1
		defs	8-$

; ------------------------------------------------------------
; print character a to sio
; in:  a = character to print
; out: --
; mod: --
; ------------------------------------------------------------

printchar:	out	(sio_data),a
		ret
		defs	16-$

; ------------------------------------------------------------
; read character a from sio
; blocking
; in:  --
; out: a = read character
; mod: flags
; ------------------------------------------------------------

readchar:	in	a,(sio_data)
		inc	a
		jr	z,readchar
		dec	a
		ret
		defs	24-$

; ------------------------------------------------------------
; print 0-terminated message
; in:  hl -> message
; out: hl -> behind message
; mod: a, hl, flags
; ------------------------------------------------------------

printstr:	ld	a,(hl)
		inc	hl
		and	a
		ret	z
		rst	printchar
		jr	printstr
		defs	32-$

; ------------------------------------------------------------
; print 0-terminated message
; in:	 message follows immediately on call
; out: --
; mod: a, hl, flags
; ------------------------------------------------------------

printmsg	pop	hl
		rst	printstr
		jp	(hl)
		defs	40-$

; ------------------------------------------------------------
; break point -> switch context: appl -> moni
; ------------------------------------------------------------

breakpoint	jp	break_point
		defs	48-$

; ------------------------------------------------------------
; unused restart vector
; ------------------------------------------------------------

rst_48	defs	56-$


; ------------------------------------------------------------
; the interrupt routine
; ------------------------------------------------------------

interrupt:	push	af
		ld	a,(tickercell)
		inc	a
		ld	(tickercell),a
		jr	nz,irpt_1
		ld	a,(tickercell+1)
		inc	a
		ld	(tickercell+1),a
irpt_1	pop	af
		ei
		ret

		defs	$66-$

; ------------------------------------------------------------
; the non-maskable interrupt routine
; => immediately enter monitor
; => this may interrupt the interrupt routine. rare case, on the 
;    emulated system eventuelly impossible (depends on programming)
;    check the register listing to determine this state and
;    finish the interrupt routine by single stepping if you like
; ------------------------------------------------------------

; note there should be a test to prevent the nmi from breaking
; into the monitor itself

nmi:		call	retn
		jp	break_point

retn		retn



; ------------------------------------------------------------
; include the re-usable utilites
; ------------------------------------------------------------

#include	"UTILS.s"


; ------------------------------------------------------------
; input number
; in:  --
; out: hl = number
;	 z  = ok;
;	 nz = error
;	 a  = last char (esc/enter/space/comma...)
; ------------------------------------------------------------

esc		equ	27
del		equ	8
rub		equ	127
enter		equ	13
tab		equ	9

getnumber:	ld	hl,0
		ld	c,10		; default number base
		ld	b,0		; character counter
gn1		rst	readchar		
		cp	a,del
		jr	z,gn8
		cp	a,rub
		jr	z,gn8
		cp	a,27
		jr	z,gn_err	; abort
		cp	a,'$'
		jr	z,gnx
		cp	a,','
		jr	z,gn_ret
		cp	a,' '
		jr	z,gn_ret
		cp	a,tab
		jr	z,gn_ret
		cp	a,enter
		jr	z,gn_ret

; digit
		cp	a,'0'
		jr	c,gn1
		cp	a,'9'+1
		jr	c,gn2		; dec char
		bit	4,c
		jr	z,gn1		; dec base but no dec char
		or	a,$20		; force lower case
		cp	a,'a'
		jr	c,gn1
		cp	a,'f'+1
		jr	nc,gn1
		rst	printchar
		sub	a,'a'-10
		jr	gn3
gn2		rst	printchar
		sub	a,'0'
gn3		inc	b
		push	af
		push	bc
		ld	e,c
		ld	d,0
		call	mult
		pop	bc
		pop	af
		ld	e,a
		ld	d,0
		add	hl,de
		jr	gn1

; select hex
gnx		ld	a,b
		and	a
		jr	nz,gn1
		ld	c,16		; new number base
		ld	a,'$'
		rst	printchar
		inc	b
		jr	gn1

; delete / rubout
gn8		djnz	gn81
		jr	gn_err	; delete & field empty  ->  abort
gn81		rst	printmsg
		defm	$08200800	; rubout
gn82		djnz	gn81
		jr	getnumber		

; return/space/comma/tab
gn_ret	dec	b
		jp	m,gn_err	; no digit
gn_ok		cp	a,a		; z -> ok
		ret

gn_err	and	a		; nz -> error
		ret	nz
		dec	a		; ((security only))
		ret
		

; ------------------------------------------------------------
; reset sequence (ctd.)
; ------------------------------------------------------------

reset1:	ld	sp,ramstart+datasize
		call	printnl

; welcome message
		rst	printmsg
		defb	27,'b'
		defm	$0d0a,"z80 EMUF - z80 single board system"
		defm	$0d0a,"----------------------------------",$00

; ram test
		rst	printmsg
		defm	$0d0a
		defm	$0d0a,"testing ram ",$00
		call	ramtest

; hl contains ram end
		ld	(ram_top),hl
		push	hl
		rst	printmsg
		defm	$0a0d,"physical ram size: $",$00
		pop	hl
		ld	bc,ramstart
		and	a
		sbc	hl,bc
		call	printhex4

; init init init ...
		ld	hl,0
		ld	(tickercell),hl
		ei

; more messages ...
		rst	printmsg
		defb	$0a
		defm	$0d0a,"this is an emulation of a very simple single board single purpose "
		defm	$0d0a,"micro computer (EMUF) to demonstrate the usage of KIO's z80 engine "
		defm	$0d0a,"to emulate a z80 system."
		defm	$0d0a,"see enclosed documentation, c and z80 source for instructions for the "
		defm	$0d0a,"eprom's monitor, for the emulator's menu items and how to implement "
		defm	$0d0a,"the z80 engine into own emulators for z80 systems."
		defb	$0a
; auskommentiert um roms vergleichbar zu machen:
;		defm	$0d0a,"this eprom was compiled with KIO's z80 assembler on ",__date__," at ",__time__
;		defb	$0a
		defm	$0d0a,"enter '?' to get help for the monitor"
		defm	$0d0a
		defb	0


; init "target application"
; and start monitor
		ld	sp,(ram_top)	; target app's sp must be set to store target app's registers!
idle_app	ld	hl,(tickercell)	; do just something
		call	break_point
		jr	idle_app
		






; -----------------------------------------------------------------------
;		THE MONITOR
; -----------------------------------------------------------------------


monitor:	ld	sp,ramstart+datasize
		
		ld	hl,printhelp	; preset 'last cmd'
		ld	(last_cmd),hl

		call	printregisters

moni		rst	printmsg		; prompt
		defm	$0d0a,"> ",$00

; get command
mon1		rst	readchar
		cp	13
		jr	z,again		; repeat last command
		cp	' '
		jr	c,mon1		; no control char ...
		cp	127
		jr	nc,mon1		; upper half of the room cleaning robot

; dispatch command
		cp	'?'
		jp	z,printhelp

		cp	'i'
		jp	z,printinfo

		cp	'g'
		jp	z,gosub

; no valid command found
beep:		rst	printchar		; echo
		ld	a,7
		rst	printchar
		jp	moni

; repeat last command
again:	ld	hl,(last_cmd)
		jp	(hl)



; ---------------------------------------------------------------------
; call subroutine
gosub:	rst	printmsg
		defm	"gosub ",$00
		
		call	getnumber
		jr	nz,moni		; abort
		cp	a,enter
		jr	nz,beep		; error
		call	printspace

		ld	de,gosub		; remember
		ld	(last_cmd),de
		ld	(last_addr),hl
		
		ld	sp,(appl_sp)	; get target application registers
		exx				; gosub address -> hl
		pop	af
		pop	bc
		pop	de
		pop	hl
		ex	af,af'
		exx
		pop	ix
		pop	iy
		pop	af
		pop	bc
		pop	de
		ex	hl,(sp)		; pop hl  &  push return address
		ret


; switch back to application context
to_appl:	ld	sp,(appl_sp)
		pop	af
		pop	bc
		pop	de
		pop	hl
		ex	af,af'
		exx
		pop	ix
		pop	iy
		pop	af
		pop	bc
		pop	de
		pop	hl
		ret				; continue application !!!


; -------------------------------------------------------------------------
; remove breakpoint
; ein: --
; mod: af
; -------------------------------------------------------------------------
clr_break	push	hl
		ld	hl,(break_addr)
		ld	a,h
		or	l
		jr	z,cbx
		ld	a,(break_byte)
		ld	(hl),a
		ld	hl,0
		ld	(break_addr),hl
cbx		pop	hl
		ret
		

; -------------------------------------------------------------------------
; install breakpoint after actual instruction
; ein: hl = address of actual instruction
; mod: af
; -------------------------------------------------------------------------

nxt_break	call	opcode_len
		add	a,l
		ld	l,a
		jr	nc,set_break
		inc	h
;		jr	set_break


; -------------------------------------------------------------------------
; install breakpoint
; ein: hl = address
; mod: af
; -------------------------------------------------------------------------

set_break	call	clr_break
		ld	(break_addr),hl
		ld	a,(hl)
		ld	(break_byte),a
		ld	(hl),$c7+breakpoint
		ret


; -------------------------------------------------------------------------
; break point trap
; -------------------------------------------------------------------------
break_point	push	af
		call	clr_break
		pop	af

; switch to monitor context
to_moni:	push	hl
		push	de
		push	bc
		push	af
		push	iy
		push	ix
		exx
		ex	af,af'
		push	hl
		push	de
		push	bc
		push	af
		ld	(appl_sp),sp
		jp	monitor	; continue monitor !!!


; --------------------------------------------------------------------------------------------
; Calculate length of instruction							(c) 1995-1996 KIO !
; in:  hl -> opcode
;      2nd byte of opcode is only inspected if 1st byte is a prefix
;	IX/IY before IX/IY/ed have no effect and are reported as length 1
; out: a = len
; mod: af
; --------------------------------------------------------------------------------------------

len0		defm	"1311112111111121231111212111112123311121213111212331112121311121"; 0x00 - 0x3F
len3		defm	"1133312111303321113231211132302111313121113130211131312111313021"; 0xC0 - 0xFF; prefixes are 0

opcode_len:	ld	a,(hl)
		cp	$40
		jr	nc,opl1

; ----------------------> $00 - $3F: various length
opl00		push	hl
		ld	hl,len0
		jr	opl9

; ----------------------> $40 - $7F: load reg,reg:       all 1
; ----------------------> $80 - $BF: arithmetics/logics: all 1
opl1		ld	a,(hl)
		cp	$c0
		jr	nc,opl2
		ld	a,1			
		ret

; ----------------------> $c0 - $ff
opl2		push	hl
		ld	hl,len3-$c0
opl9		add	a,l
		ld	l,a
		jr	nc,$+3
		inc	h
		ld	a,(hl)
		sub	'0'
		pop	hl
		ret	nz

; ----------------------> prefix instruction
		ld	a,(hl)	; opcode again
		cp	a,$cb
		jp	z,opl_2	; prefix cb  =>  all 2 byte
		cp	a,$ed
		jr	nz,opl_xy

; ----------------------> prefix ed  =>  all 2 byte except 2nd byte = %01???011
opl_ed	inc	hl
		ld	a,(hl)	; 2nd opcode byte
		dec	hl
		and	%11000111
		cp	a,%01000011
		jr	nz,opl_2
opl_4		ld	a,4
		ret

opl_2		ld	a,2
		ret

; ----------------------> index instruction
opl_xy	inc	hl
		ld	a,(hl)	; 2nd opcode byte
		dec	hl
		cp	a,$40
		jr	c,oplxy0
		cp	$c0
		jr	nc,oplxy4

; ----------------------> xy + $c0-$ff
opl4		cp	a,$cb
		jr	z,opl_4	; xy cb dis instr  =>  all 4 bytes
		
		push	hl
		ld	hl,len3-$c0
		add	a,l
		ld	l,a
		jr	nc,$+3
		inc	h
		ld	a,(hl)
		sub	a,'0'-1
		pop	hl		; note: entries for prefixes are '0' giving a total of 1, 
		ret			; just to skip the useless prefixes ix, iy and ed

; ----------------------> xy + $00-$3f
oplxy0	cp	a,$34
		jr	c,opl5
		cp	a,$37
		jr	nc,opl5
		call	opl00
		add	a,2
		ret
opl5		call	opl00
		inc	a
		ret

; ----------------------> xy + $40-$bf
; if ( ((op2&0x07)==6) == ((op2&0x0F8)==0x70) ) return 2; else return 3
oplxy4	cp	a,$76
		jr	z,opl_2	; halt
		push	af
		and	a,7
		cp	a,6
		jr	z,opl31	; source = (xy+dis) -> 3 byte
		pop	af	
		and	$f8
		cp	$70
		jr	z,opl_3	; target = (xy+dis) -> 3 byte
		jr	opl_2		; illegal -> 2 byte
opl31		pop	af
opl_3		ld	a,3
		ret


; ---------------------------------------------------------------------
; display help message
; ---------------------------------------------------------------------
printhelp:	rst	printmsg
		defm	"? (help)",$00

		ld	hl,printhelp
		ld	(last_cmd),hl

		rst	printmsg
		defm	$0d0a,"eprom monitor commands:"
		defm	$0d0a,"<?> help                  show help page"
		defm	$0d0a,"<d> display    <address>  display memory"
		defm	$0d0a,"<m> modify     <address>  modify memory"
		defm	$0d0a,"<g> gosub      <address>  call subroutine"
		defm	$0d0a,"<b> breakpoint <address>  set break point"
		defm	$0d0a,"<r> register              show & set register(s)"
		defm	$0d0a,"<c> continue              continue target application"
		defm	$0d0a,"<s> single step           execute next instruction"
		defm	$0d0a,"<i> info                  display system info"
		defm	$0d0a,"<return>                  repeats last command"
		defm	$00
		jp	moni

; ---------------------------------------------------------------------
; display various system info	
; ---------------------------------------------------------------------
printinfo:	halt
		halt
		halt
		call	calcspeed		; calc speed first, because text output
		push	de			; will slow down the engine
		push	hl

		rst	printmsg
		defm	"info",$00

		ld	hl,printinfo
		ld	(last_cmd),hl

;		rst	printmsg
;		defm	$0d0a,"eprom date = ",__date__,$00

		rst	printmsg
		defm	$0d0a,"cpu speed  = ",$00
		pop	hl
		call	printdec
		ld	a,'.'
		rst	printchar
		pop	hl
		call	printdec3
		rst	printmsg
		defm	" MHz",$00

		rst	printmsg
		defm	$0d0a,"ram size   = ",$00
		ld	hl,(ram_top)
		ld	bc,ramstart
		and	a
		sbc	hl,bc
		call	printdec

		rst	printmsg
		defm	$0d0a,"ticks since reset = ",$00
		ld	hl,(tickercell)
		call	printdec

		jp	moni





; ------------------------------------------------------------
; print registers of target application
; ------------------------------------------------------------

printregisters:
		call	printnl
		rst	printmsg
		defm	"A  F        BC   DE   HL   IX   IY   SP   PC   I  R  irpt", $00

		call	printnl
		ld	ix,(appl_sp)

		ld	a,(ix+13)	; A
		call	printhex2
		call	printspace

		ld	c,(ix+12)	; F
		call	print_f
		call	printspace

		ld	h,(ix+15)	; B
		ld	l,(ix+14)	; C
		call	printhex4
		call	printspace
		
		ld	h,(ix+17)	; D
		ld	l,(ix+16)	; E
		call	printhex4
		call	printspace
		
		ld	h,(ix+19)	; H
		ld	l,(ix+18)	; L
		call	printhex4
		call	printspace
		
		ld	h,(ix+09)	; XH
		ld	l,(ix+08)	; XL
		call	printhex4
		call	printspace
		
		ld	h,(ix+11)	; YH
		ld	l,(ix+10)	; YL
		call	printhex4
		call	printspace
		
		ld	hl,(appl_sp)
		ld	de,20
		add	hl,de		; SP
		call	printhex4
		call	printspace

		ld	h,(ix+21)	; PCH
		ld	l,(ix+20)	; PCL
		call	printhex4
		call	printspace

		ld	a,i		; not preserved in context switch
		call	printhex2
		call	printspace

		ld	a,r		; mostly garbage
		call	printhex2
		call	printspace
				
		ld	a,i		; IFF
		jp	po,pr2
		rst	printmsg
		defm	"enabled",$00
		jr	pr1
pr2		rst	printmsg
		defm	"disabled",$00		
pr1		call	printnl

		ld	a,(ix+1)	; A
		call	printhex2
		call	printspace

		ld	c,(ix+0)	; F
		call	print_f
		call	printspace

		ld	h,(ix+3)	; B
		ld	l,(ix+2)	; C
		call	printhex4
		call	printspace
		
		ld	h,(ix+5)	; D
		ld	l,(ix+4)	; E
		call	printhex4
		call	printspace
		
		ld	h,(ix+7)	; H
		ld	l,(ix+6)	; L
		jp	printhex4

; UP: print flag register
; in: c=flags
print_f	ld	b,8
		ld	hl,flags
pf2		ld	a,(hl)
		inc	hl
		rl	c
		jr	c,pf3
		ld	a,'-'
pf3		rst	printchar
		djnz	pf2
		ret
flags		defm	'SZ+H+VNC'




; ----------------------------------------------------------------
; this is the end
; ---------------------------------------------------------------------

;		defs	epromsize-$,$ff		; fill to end of eprom

#end


  
  
  
		
		

		

