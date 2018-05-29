crtdge	equ	04000h
stack	equ	09000h
vzdelay equ	060h		;rom delay routine, delay value in bc
beep	equ	03450h		;beep routine
pcrlf1	equ	03ae2h		;send cr and lf to printer
list	equ	058dh		;printer driver
listst	equ	05c4h		;printer status, bit 0 of A=0 if ready
chrot	equ	033ah		;character output routine
exitkey equ	101		;shift 'X' is exit from term
outadr	equ	05800h		;transmit latch address
inadr	equ	05000h		;input address
toplin	equ	28672		;top line of screen
nolin	equ	480		;(number of lines - 1) * 32
;
;ascii definitions.
;
home	equ	28
cr	equ	13
esc	equ	27
bell	equ	7
ff	equ	12
lf	equ	10
bs	equ	8
ht	equ	9
;
;Now define our storage area, where basic text usually starts
;
dumsg	equ	08000h		;part of the signon message that changes
pntmsg	equ	dumsg+25	;printer on/off message
dbits	equ	pntmsg+24	;dbits message
sbits	equ	dbits+24	;sbits message
parmsg	equ	sbits+24	;parity message
p1msg	equ	parmsg+24	;strip parity message
pntflg	equ	p1msg+count3	;printer on/off flag
dupflg	equ	pntflg+1	;duplex flag, 0=full
p1flg	equ	dupflg+1	;add lf to cr flag
char	equ	p1flg+1		;character found
flag	equ	char+1		;keyboard flag
curpos	equ	flag+1		;column counter for output routine
cursor	equ	curpos+1	;cursor location
bufend	equ	09000h		;to accomodate VZ-200/300
;
	.z80
	aseg
	org	0100h
	.phase	crtdge		;place that it will run
;
begadr	equ	$
;
	defb	0aah		;mask for rom pack installation recognition
	defb	055h		;checked at power-up by the basic roms
	defb	0e7h
	defb	018h
;
	jp	start
;
;A few messages....
;
onmsg:	defb	'ON '
offmsg: defb	'OFF'
fullmsg:defb	'FULL'
halfmsg:defb	'HALF'
;
signon: defb	ff
	defb	'VZ-200/300 RS-232 - VERSION 1.5',cr
	defb	'(C) 1985 DICK SMITH ELECTRONICS',cr
	defb	'-------------------------------',cr
	defb	'0] ENTER TERMINAL',cr
	defb	'1] FULL/HALF DUPLEX:',0
;
ivals:	defb	'FULL',cr
	defb	'2] TOGGLE PRINTER  :'
	defb	'OFF',cr
	defb	'3] SET # DATA BITS :'
	defb	'8  ',cr
	defb	'4] SET # STOP BITS :'
	defb	'1  ',cr
	defb	'5] SET PARITY      :'
	defb	'N  ',cr
	defb	'6] ADD LF TO CR    :'
count1	equ	$
	defb	'OFF'
	defb	cr,cr
	defb	'******* WHEN IN TERMINAL *******'
	defb	'*  SHIFT - X TO EXIT TERMINAL  *'
	defb	'********************************',0
count2	equ	$
count3	defl	count2-count1
ivals2	equ	$

	defb	0	;printer on/off flag
	defb	0	;duplex flag
	defb	0	;add lf to cr flag
	defb	0	;where characters are placed when recvd from the keybrd
	defb	0	;a flag for the keyboard driver
	defb	0	;column counter
	defw	0	;cursor position
;
ivalend equ	$
;
start:	di			;get rid of the 6847 interrupt
	ld	sp,stack	;make a stack
	ld	hl,ivals	;point to initial values
	ld	de,dumsg	;where to put them
	ld	bc,ivalend-ivals ;number to put
	ldir			;init the system
start1: ld	a,(p1flg)	;get crlf flag
	push	af		;save it
	ld	a,1		;we want crlf on signon
	ld	(p1flg),a
	ld	hl,signon	;point to signon
	call	msgout
	ld	hl,dumsg
	call	msgout
	pop	af		;restore crlf flag
	ld	(p1flg),a	;and save it here
	call	beep		;make a noise
	ld	hl,start1	;set return address
	push	hl		;put it on the stack
kget:	call	getkey		;get a key
	or	a
	jr	z,kget		;loop till key ready
	sub	'0'		;make it 0-10
	jr	c,kget		;continue if error
	cp	6+1
	jr	nc,kget		;continue if error
	ld	hl,cmdtab	;point to command table address
	add	a,a		;make it *2
	ld	e,a		;put it in de
	ld	d,0
	add	hl,de		;now hl points to correct table entry
	ld	e,(hl)		;get lsb
	inc	hl
	ld	d,(hl)		;get msb, now hl points to correct address
	ex	de,hl
	jp	(hl)		;go to that address
;
;table of addresses for the command table options
;
cmdtab: defw	term		;actual terminal
	defw	setfh		;set full/half duplex
	defw	prnton		;turn printer on/off
	defw	sdbits		;set # of data bits
	defw	ssbits		;set # of stop bits
	defw	spar		;set parity
	defw	addlf		;add on lf to cr
;
;set full or half duplex
;
setfh:	ld	a,(dupflg)	;check current
	or	a		;check for full already
	ld	a,1		;make half just in case
	ld	hl,halfmsg
	jr	z,setfh1
	xor	a		;else make full
	ld	hl,fullmsg
setfh1: ld	(dupflg),a
	ld	de,dumsg	;where to go to
	ld	bc,4		;move it
	ldir
	ret
;
;toggle printer
;
prnton: ld	hl,pntflg	;check printer flag
	ld	de,pntmsg
	call	toggle
	ret
;
;add lf to cr flag
;
addlf:	ld	hl,p1flg
	ld	de,p1msg
	call	toggle
	ret
;
;set parity
;
spar:	ld	a,(parmsg)	;get parity message
	cp	'N'		;none ?
	ld	c,'E'		;make it an even then
	jr	z,stpar1	;save this one if z flag set
	cp	'E'
	ld	c,'O'
	jr	z,stpar1	;if even, make an odd
	ld	c,'N'		;must be odd, make none
stpar1: ld	a,c
	ld	(parmsg),a
	ret
;
toggle: ld	a,(hl)		;get current flag value
	or	a		;is it zero
	ld	a,1		;make it one if so
	jr	z,togg1
	xor	a		;else make it a zero
togg1:	ld	(hl),a		;save new value
	ld	hl,offmsg
	or	a
	jr	z,moveit1
	ld	hl,onmsg
moveit1:ld	bc,3
moveit: ldir
	ret
;
;set databits
;
sdbits: ld	a,(dbits)	;get current value
	cp	'7'		;seven ?
	ld	a,'8'		;just in case
	jr	z,sdb1
	ld	a,'7'
sdb1:	ld	(dbits),a
	ret
;
;set stop bits
;
ssbits: ld	a,(sbits)	;get current value
	cp	'1'		;seven ?
	ld	a,'2'		;just in case
	jr	z,ssb2		;if z, must be 8, make it 7
	ld	a,'1'
ssb2:	ld	(sbits),a
	ret
;
term:	call	clrscr		;clear the screen
tryser: call	chkstr		;check for incoming serial stuff
	jr	nz,term1	;no-look for keyboard input then
	call	inchr		;stuff there, get it
	call	chrout		;and print it on the screen
	ld	c,a		;put char in correct register for list routine
	ld	a,(pntflg)
	or	a
	call	nz,list1
term1:	call	getkey		;see if user has typed anything
	or	a
	jr	z,tryser	;no, try the serial instead
	cp	exitkey		;see if a return to main loop key
	ret	z		;return if so
	push	af		;save char
	call	outchr		;send to RS-232
	pop	af		;restore for screen output
	ld	c,a
	ld	a,(dupflg)	;check duplex first
	or	a
	ld	a,c
	jr	z,tryser	;jump if full duplex
	call	chrout		;and screen as well if 1/2 duplex
	ld	c,a		;put char in correct register for list routine
	ld	a,(pntflg)
	or	a
	call	nz,list1
	jr	tryser
;
;get a character from the board
;
;incoming char must have been checked by a call to chkstr
;
;This routine is time critical and as i took be a long time to get it right,
;i would suggest that it not be touched.
;
inchr:	call	del3a		;wait for 1/2 bit time, half way thru start bit
	call	del300		;and 1 bit time, half way thru data bit 0
	ld	a,(dbits)	;get data bit value
	sub	'0'		;remove ascii offset, 8 for 8 bits 7 for 7
	ld	e,a		;and put the calculated data bit value in e
	ld	b,8		;must always do 8 shifts to get bit 0 correct
	ld	c,0		;accumulator for our serial bit stream
inchr1: ld	a,b		;check for last loop
	cp	1		;are we nearly finished (we are if seven bits)
	jr	nz,inchr2	;no-continue
	ld	a,e		;see if 7 or 8 data bits required
	cp	8		;if e=8, 8 bits are needed and one further loop
	jr	z,inchr3
	jr	inchr4		;finish up if seven
;
inchr2: ld	a,(inadr)	;get the entered bit
	and	10000000b	;mask off invalid bits
	or	c		;mask on our accumulated value
	ld	c,a		;and save it here
	srl	c		;and shift it into the next bit position
	call	del300		;delay one 300 baud bit time
inchr3: djnz	inchr1		;loop for all data bits
inchr4: call	del302		;wait till end of data bit
	ld	a,(parmsg)	;check if parity delay needed
	cp	'N'
	call	nz,del300
	ld	a,c		;get the char back
	ret
;
;output char
;
outchr: push	af		;save the char
	ld	a,255		;make a start bit
	ld	(outadr),a	;send it
	call	del300		;and do a delay for 1 bit time
	ld	a,(dbits)	;get # of data bits
	sub	'0'
	ld	b,a		;and put the calculated data bit value in b
	pop	af
	push	af
	ld	c,a
snd1:	srl	c		;rotate bit 0 of c into carry flag
	ld	a,00000000b	;in case of carry
	jr	c,snd2		;send if bit was 1
	ld	a,10000000b	;make it one
snd2:	ld	(outadr),a	;send the char
	call	del300		;delay for one bit time
	djnz	snd1
	pop	af		;restore char that was sent
	ld	c,a		;save it in c
	ld	a,(parmsg)	;check for parity
	cp	'N'
	jr	z,nopar0	;z if no parity
	ld	a,c		;get back restored character
	or	a		;set parity flags
	ld	a,(parmsg)	;and get parity type for later testing
	jp	po,oddpar	;jump if parity of the byte is odd
	cp	'E'		;was it supposed to be even
tstpar: ld	a,10000000b
	jr	z,sndpar
	ld	a,00000000b
	jr	sndpar
;
oddpar: cp	'O'		;set z flag if it was supposed to be odd
	jr	tstpar

sndpar: ld	(outadr),a
	call	del300
nopar0: ld	a,(sbits)	;get # of stop bits
	sub	'0'		;make it hex 1 or 2
	ld	b,a
sbdel1: xor	a		;make a stop bit
	ld	(outadr),a
	call	del300		;delay for middle of stop bit
	djnz	sbdel1
	ret
;
;check for a character coming in
;
;RX provides an active low input to the address buffer
;
;i.e. returned value is nz if a char is ready, z if not
;
chkstr: ld	a,(inadr)	;check input address
	bit	7,a
	ret
;
;These delay routines provide a correct mark to space ratio for checking
;and sending the serial bit stream and are VERY VERY VERY critical.
;if you÷ send a series of 'U' (a character with the same mark to space ratio)
;characters and look at the output of the interface on a CRO, you will
;see what i mean.
;
;
del300: push	af
	push	bc
	call	del3a
	call	del3a
	pop	bc
	pop	af
	ret
;
del3a:	push	bc
	ld	a,215/6		;300 baud delay
loop0:	ld	b,11
loop1:	djnz	loop1
	dec	a
	jr	nz,loop0
	pop	bc
	ret
;
del302: call	del3a		;one 1/2 300 baud delay
	push	bc		;save this
	ld	a,205/6		;nex timing constant
	jr	loop0
;
kdelay: push	af
	push	bc
	ld	bc,04fffh	;delay value
	call	vzdelay		;delay it
	pop	bc		;get registers back
	pop	af
	ret
;
msgout: ld	a,(hl)
	or	a
	ret	z
	call	chrout
	inc	hl
	jr	msgout
;
;Character output routine
;
clrscr: ld	hl,toplin
	ld	(cursor),hl
	ld	de,toplin+1
	ld	bc,nolin+31
	ld	(hl),96
	ldir
	xor	a
	ld	(curpos),a
	ld	(26624),a
	ret
;
chrout: push	af
	push	hl
	push	bc
	push	de
	call	pntit
	pop	de
	pop	bc
	pop	hl
	pop	af
	ret
;
pntit:	ld	de,(cursor)
	cp	ff
	jr	z,clrscr
	cp	cr
	jr	z,crt		;do a cr
	cp	bs
	jr	z,bsp
	cp	ht
	jr	z,fsp
	cp	lf
	jr	z,lfd
	cp	bell
	jp	z,beep
	bit	7,a
	jr	nz,grap
	cp	32		;if not recognised control char, return
	ret	m
	call	fold		;fold lower to upper
	set	6,a		;change non-alphabetical char
				;to black with white background
;
grap:	ld	(de),a
fsp:	inc	de
	ld	(cursor),de
	ld	a,(curpos)
	inc	a
	ld	(curpos),a
	cp	32
	ret	m
	call	docrlf
	ld	a,(pntflg)	;printer on ?
	or	a
	ret	z		;return if not
	call	pcrlf
	ret
;
bsp:	ld	a,(curpos)
	or	a
	jr	z,bsp1
	dec	a
bsp2:	ld	(curpos),a
	dec	de
	ld	(cursor),de
	ret
;
bsp1:	push	hl
	ld	hl,toplin
	or	a
	sbc	hl,de
	pop	hl
	ret	z
	ld	a,31
	jr	bsp2
;
lfd:	ld	a,(curpos)
	ld	c,a
	ld	b,0
	push	bc
	call	docrlf
	pop	bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	ld	(cursor),de
	ld	a,c
	ld	(curpos),a
	ret
;
docrlf: ld	a,(p1flg)	;get current setting
	push	af		;save it
	ld	a,1		;make it so it does add on lf
	ld	(p1flg),a
	call	crt		;do it
	pop	af		;get back original flag
	ld	(p1flg),a	;and save it again
	ret
;
crt:	push	hl
	ex	de,hl
	ld	a,(curpos)
	ld	e,a
	ld	d,0
	or	a
	sbc	hl,de
	ld	a,(p1flg)	;do we want to add on an lf to a cr
	or	a		;if zero we don't
	jr	z,nolf
	ld	de,32		;add on an lf if cr
	add	hl,de
nolf:	ex	de,hl
	ld	hl,29184
	or	a
	sbc	hl,de		;check for end of screen
	jr	z,scroll	;scroll if so
write4: ld	(cursor),de
	xor	a
	ld	(curpos),a
	pop	hl
	ret
;
scroll: ld	hl,toplin+32
	ld	de,toplin
	ld	bc,nolin
	ldir
	ld	hl,29152
	ld	de,29153
	ld	bc,31
	ld	(hl),96
	ldir
	ld	de,29152
	jr	write4
;
pcrlf:	call	listst		;check printer status
	bit	0,a
	ret	nz		;return if printer not ready
	call	pcrlf1		;send crlf to printer if printer is ready
	ret
;
;
list1:	call	listst
	bit	0,a
	ret	nz		;return if printer not ready
	ld	a,c
	jp	list		;list it and return
;
fold:	cp	'a'
	ret	c
	cp	'z'+1
	ret	nc
	and	05fh		;make upper if lower
	ret
;
;Keyboard driver for VZ-200/300
;
;This keyboard drive is (c) Dick Smith Electronics and (c) 1982,1983,1984
;Video Technology HK Ltd.
;
row1	equ	068feh
row2	equ	068dfh
;
getkey: ld	hl,row1		;point to first row
	ld	c,8		;row counter
scan1:	ld	b,6		;column counter
	ld	a,(hl)		;get first key
	or	4		;mask out bit 2
rot:	rra			;rotate bits
	jr	nc,found	;exit if key pressed
	djnz	rot		;else try next bit
	rlc	l		;get next address
	dec	c		;dec row counter
	jr	nz,scan1	;try next row
	ld	b,4		;get col counter
	ld	hl,row2		;get next address
	ld	a,(hl)		;read key
	bit	2,a		;test bit 2 for keypress
	jr	z,minus		;exit if key pressed
	rlc	l		;get next address
	ld	a,(hl)		;read key
	bit	2,a		;test for keypress
	jr	z,carret	;exit if cr key pressed
	rlc	l		;get next addr
	bit	2,a
	jr	z,colon		;test if : pressed
	rlc	l		;get next addr
	rlc	l		;last addr had no char
	ld	a,(hl)		;get the key
	bit	2,a		;test for cntrl
	jr	z,ctrl
	rlc	l		;get next address
	ld	a,(hl)		;read key
	bit	2,a
	jr	z,shift		;exit if shift key pressed
	ld	a,0ffh		;get no char code
	ld	(char),a
	xor	a
	ld	(flag),a	;clear shift flag
	ret
;
ctrl:	ld	a,(flag)
	set	2,a
	jr	keyexit
;
shift:	ld	a,(flag)	;get flag
	set	1,a		;set bit 1 flag
keyexit:ld	(flag),a
	ld	a,0ffh		;make no char code
	ld	(char),a
same:	xor	a		;if char the same, return no char so as to
				;remove the key repeat
	ret
;
minus:	ld	c,3		;set row count
	jr	found		;exit
;
carret: ld	c,2		;set row count
	jr	found
;
colon:	ld	c,1		;set row count
;
found:	ld	hl,txtble	;point to lookup table
	ld	e,0		;clear shift/control offset
	ld	a,(flag)
	bit	2,a		;test for ctrl key hit last time
	jr	z,noctrl
	ld	e,48*2		;make up control table offset
	jr	noshift
;
noctrl: bit	1,a		;test for the shift key
	jr	z,noshift
	ld	e,48		;set shifted offset
noshift:ld	a,8		;setup row count
	sub	c		;calc offset
	ld	c,a		;store in C
	ld	a,6		;setup column count
	sub	b		;calc offset
	ld	b,a		;store in b
	call	cond		;get table offset in A
	add	a,e		;add shift offset
	ld	b,0		;clear b
	ld	c,a		;offset in C
	add	hl,bc		;get character position
	ld	a,(hl)		;get char in A
	ld	hl,char		;get last char
	cp	(hl)		;same as last ?
	jr	z,same
	ld	(hl),a		;if not same, save the char
	ret
;
cond:	xor	a		;clear a reg.
	cp	c		;is c=0
	jr	z,hre		;bypass if yes
mult:	add	a,6		;inc by six
	dec	c		;dec counter
	jr	nz,mult
hre:	add	a,b		;add bit count
	ret
;
txtble: defb	'TW EQRGS DAFBX CZV52 314N. , M'
	defb	'69-807YO'
	defb	0dh
	defb	'IPUHL:K;J'
;
;shifted characters
;
	defb	0		;shift T
	defb	0		;shift w
	defb	0
	defb	0		;shift e
	defb	0		;shift q
	defb	0		;shift r
	defb	0		;shift g
	defb	0		;shift s
	defb	0		;cntrl
	defb	0		;shift d
	defb	0		;shift a
	defb	0		;shift f
	defb	0		;shift b
	defb	101		;shift x
	defb	0		;null
	defb	0		;shift c
	defw	0		;null
	defb	'%" #!$'        ;shifted 52 314
	defb	0		;shift n
	defb	'>'		;shift .
	defb	0
	defb	'<'		;shift ,
	defb	0		;null
	defb	92		;shift m
	defb	'&)=('		;shifted 69-8
	defb	'@'		;shift 0
	defb	0		;shift 7
	defb	0		;shift y
	defb	0		;shift o
	defb	0		;shift cr
	defb	0		;shift i
	defb	0		;shift p
	defb	0		;shift u
	defb	0		;shift h
	defb	'?'		;shift l
	defb	'*'		;shift :
	defb	'/'		;shift k
	defb	'+'		;shift ;
	defb	0		;shift j
;
;control characters
;
	defb	'T'-040h	;control t
	defb	'W'-040h	;control w
	defb	0
	defb	'E'-040h	;control e
	defb	'Q'-040h	;control q
	defb	'R'-040h	;control r
	defb	'G'-040h	;control g
	defb	'S'-040h	;control s
	defb	0
	defb	0		;control d
	defb	'A'-040h	;control a
	defb	'F'-040h	;control f
	defb	'B'-040h	;control b
	defb	'X'-040h	;control x
	defb	0
	defb	'C'-040h	;control c
	defb	'Z'-040h	;control z
	defb	'V'-040h	;control v
	defb	0
	defb	0
	defb	0
	defb	0
	defb	0
	defb	0
	defb	'N'-040h	;control n
	defb	0
	defb	0
	defb	0
	defb	0
	defb	cr		;control m
	defb	0
	defb	0
	defb	0
	defb	0
	defb	0
	defb	0
	defb	'Y'-040h	;control y
	defb	'O'-040h	;control o
	defb	0
	defb	ht		;control i
	defb	'P'-040h	;control p
	defb	'U'-040h	;control u
	defb	bs		;control h
	defb	ff		;control l
	defb	0
	defb	'K'-040h	;control k
	defb	0
	defb	lf		;control j

