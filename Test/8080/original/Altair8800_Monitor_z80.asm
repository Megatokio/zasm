#!/usr/local/bin/zasm --8080 --casefold --reqcolon -o original/
;================================================
;MONITOR 8.4 (2K version)
; Upgraded Monitor/Executive program for ALTAIR 8800
; Conditional assembly supports SIO-A and 2-SIO cards
;
; (C) John Garza 2009
; Non-commercial use for hobbyists granted
;================================================
	ORG		0F000H			; Location of ROM chip containing this monitor
;------------------
; SET I/O CARD HERE
SIOA	EQU		0
SIO2	EQU		1
SS1		EQU		0
;------------------
; STACK LOCATION
STACK   EQU     50H			; Stack Location (80 bytes available)
;------------------
; Other storage
RCVSNO	EQU		STACK+2			; SECT # RECEIVED (XMODEM)
SECTNO	EQU		STACK+3			; CURRENT SECTOR NUMBER (XMODEM)
ERRCT	EQU		STACK+4			; ERROR COUNT(XMODEM)
dest	EQU		STACK+6			; destination address pointer 2BYTES (XMODEM)
;--
IBUFP   EQU     STACK+13        ; Buffer Pointer 2BYTES
IBUFC   EQU     IBUFP+2         ; Buffer Count 2BYTES
IBUFF   EQU     IBUFP+3         ; Input Buffer
IBL		EQU		16				; Input Buffer Length
;------------------
;RS-232 EQUATES for SIO-A (COM 2502 chip)
IF SIOA
	TTS     equ     00h     ;MITS SIO-A channel A status port
	TTI     equ     01h     ;MITS SIO-A data input port (yes input=output)
	TTO     equ     01h     ;MITS SIO-A data output port
	TTYDA   equ     20h     ;tty data available (ready to receive?) for MITS SIO-A
	TTYTR   equ     02h     ;tty terminal ready (ready to transmit?) for MITS SIO-A
ENDIF
;------------------
;RS-232 EQUATES for 2SIO (6850 chip)
IF SIO2
	TTS     equ     10h     ;MITS 2SIO status/control port
	TTI     equ     11h     ;MITS 2SIO data input port (yes input=output)
	TTO     equ     11h     ;MITS 2SIO data output port
	TTYDA   equ     01h     ;tty data available (ready to receive?) for MITS 2SIO
	TTYTR   equ     02h     ;tty terminal ready (ready to transmit?) for MITS 2SIO
ENDIF
;------------------
;RS-232 EQUATES for Compupro SS-1 card
IF SS1
	TTS     equ     5Dh     ; status/control port
	TTI     equ     5Ch     ; data input port (yes input=output)
	TTO     equ     5Ch     ; data output port
	TTYDA   equ     01h     ; tty data available (ready to receive?)
	TTYTR   equ     02h     ; tty terminal ready (ready to transmit?)
ENDIF
;---------------------------------------------------------
; SERIAL IO PARAMETERS FOR COMPUPRO SYSTEM SUPPORT 1:
;
;SSBASE    EQU    50H           ;BASE ADDRESS
;SSMODE    EQU    SSBASE+0EH    ;UART MODE PORT
;SSCMND    EQU    SSBASE+0FH    ;UART COMMAND PORT
;TTSTAT    EQU    SSBASE+0DH    ;TTY STATUS PORT
;TTDATA    EQU    SSBASE+0CH    ;TTY DATA PORT
;TTTBE     EQU    01H           ;TRANSMITTER BUFFER EMPTY
;TTRDA     EQU    02H           ;RECEIVER DATA AVAILABLE
;---------------------------------------------------------
;------------------
;ASCII characters used
NUL				EQU		0		; NULL (ZERO)
CR				EQU		0DH		; Carriage return
LF				EQU		0AH		; Line feed
CTRH            EQU     8       ; Ctl H Backspace
DEL             EQU     127     ; Delete char
TAB             EQU     9       ; Tab char
CTRX            EQU     24      ; Ctl X Cancel
CTRS            EQU     19      ; Ctl S Suspend
CTRQ            EQU     17      ; Ctl Q Resume
APOS            EQU     (39-'0') AND 0FFH  ;apostrophe
;------------------
;xmdm values
SOH				EQU		1		; Start of Header
ACK             EQU     06H     ; Acknowledge
NAK             EQU     15H     ; Negative acknowledge
EOF             EQU     1AH     ; End of file - ^Z
EOT             EQU     04H     ; End of transmission
ERRLIM			EQU		10		; Max allowable errors
DMABUF			EQU		80H		; DMA Buffer location
;================================================
cldst:                          ; COLD START
		ld sp,STACK        ; Initialize stack for welcome msg
		call ilprt           ;Display welcome message
		db      lf,cr,'Altair 8800 Monitor 8.4',00h
		call ilprt           ;Display welcome message
		db      lf,cr,'(C) 2009 John Garza',lf,cr,00h
wrmst:
		ld sp,STACK        ;Re-Initialize stack
		ld hl,wrmst         ;Put return addr on stack
		push hl               ; so command routines can do a RET
		call inpln           ;Get command string
		call getch           ;Get first char from command
		; Process the command
		cp a,'D'     ; Deposit data into memory
		jp z,enter   ;
		cp a,'E'     ; Examine memory to console
		jp z,dump    ;
		cp a,'B'     ; Block Move
		jp z,block   ;
		cp a,'J'     ; Jump - execute external code (no return)
		jp z,go      ;
		cp a,'L'     ; MBL - Microsoft Boot Loader for BASIC
		jp z,mbl     ;
		cp a,'M'     ; Memory Test
		jp z,mem     ;
		cp a,'X'     ; Xmodem receive
		jp z,xmdm
		cp a,'Z'     ; Block Move to Zero & RUN
		jp z,bmzr    ;
		cp a,'?'     ; Help screen
		jp z,help    ;
		 jp wrmst   ; Go back for another command
;--------------------------------------
;Command Main Routines
;--------------------------------------
;------------------
;Memory Load routine
; Load hex or ascii into mem from console
; Check data was written, apostrophe precedes ascii
; CR passes over a location
enter:
		call ilprt
		db		lf,cr,'Memory Load: apostrophe for ASCII, CR skips addr, Ctrl-X exits',lf,cr,00h
load:   call readhl  ;Addr
load2:  call outhl   ;Print it
		call pasci   ;Ascii
		call outsp
		ld c,(hl)     ;Orig byte
		call outhex  ;Hex
		push hl       ;Save pointer
		call inpl2   ;Input
		call readhl  ; Byte
		ld b,l     ; To B
		pop hl
		cp a,APOS
		jp z,load6   ;Ascii input
		ld a,c     ;How many?
		or a,a       ;None?
		jp z,load3   ;Yes
load4:  call chekm   ;Into mem
load3:  inc hl       ;Pointer
		 jp load2
		;load ascii char
load6:  call getch
		ld b,a
		 jp load4
		;copy byte from B to memory
		; and see that it got there
chekm:  ld (hl),b     ;Put in mem
		ld a,(hl)     ;Read back into A
		cp a,b       ;Same?
		ret z              ;Yes
errp:
		pop af		;RAISE STACK
errb:
		ld a,'B'	;'B' = 'BAD'
err2:
		call outt
		call outsp
		 jp outhl
;------------------
; Memory Dump routine
; Display Hex & ascii mem contents over specified range
;
dump:
		call rdhlde  ;Range
dump2:  call crhl    ;New line
dump3:  ld c,(hl)     ;Get byte
		call outhx   ;Print
		inc hl       ;Pointer
		ld a,l
		and a,0FH     ;Line end?
		jp z,dump4   ;Yes, ascii
		and a,3       ;Space
		call z,outsp   ; 4 bytes
		 jp dump3   ;Next hex
dump4:  call outsp
		push de
		ld de,-10H  ;Reset line
		add hl,de
		pop de
dump5:  call pasci   ;ascii dump
		call tstop   ;Done?
		ld a,l     ;No
		and a,0FH     ;line end?
		jp nz,dump5   ;No
		 jp dump2
		;display byte in ascii if possible, otherwise dot
pasci:  ld a,(hl)     ;Get byte
		cp a,DEL     ;High bit on?
		jp nc,pasc2   ;Yes
		cp a,' '     ;Control char?
		jp nc,pasc3   ;No
pasc2:  ld a,'.'   ;Change to dot
pasc3:   jp outt    ;Send
		;get HL and DE from console, check that DE is larger
rdhlde: call hhlde
rdhld2: ld a,e
		sub a,l       ;E - L
		ld a,d
		sbc a,h       ;D - H
		jp c,error   ;HL is bigger
		ret
		;input HL and DE, check that 2 addr are entered
hhlde:  call readhl  ;HL
		jp c,error   ;Only 1 addr
		ex de,hl            ;Save in DE
		call readhl  ;DE
		ex de,hl            ;Put back
		ret
		;input HL from console
readhl: push de
		push bc       ;Save regs
		ld hl,0     ;Clear
rdhl2:  call getch   ;Get char
		jp c,rdhl5   ;Line end
		call nib     ;To binary
		jp c,rdhl4   ;Not hex
		add hl,hl       ;Times 2
		add hl,hl       ;Times 4
		add hl,hl       ;Times 8
		add hl,hl       ;Times 16
		or a,l       ;Add new char
		ld l,a
		 jp rdhl2   ;Next
		;check for blank at end
rdhl4:  cp a,APOS    ;Apostrophe
		jp z,rdhl5   ;Ascii input
		cp a,+(' '-'0') AND 0FFH
		jp nz,error   ;N0
rdhl5:  pop bc
		pop de       ;Restore
		ret
		;convert ascii chars to binary
nib:    sub a,'0'     ;Ascii bias
		ret c              ;<0
		cp a,'F'-'0'+1
		ccf             ;Invert
		ret c              ;Error, >F
		cp a,10
		ccf             ;Invert
		ret nc             ;Number 0-9
		sub a,'A'-'9'-1
		cp a,10      ;Skip : to
		ret             ;Letter A-F
		;print ? on improper input
error:  ld a,'?'
		call outt
		 jp wrmst   ;Try again
		;start new line, give addr
crhl:   call crlf    ;New line
outhl:  ld c,h
		call outhx
outll:  ld c,l
outhex: call outhx
outsp:  ld a,' '
		 jp outt
		;output a hex byte from C (ASCII to HEX converter)
outhx:  ld a,c
		rra             ;Rotate
		rra             ; 4 bits
		rra             ; to
		rra             ; the right
		call hex1    ;Upper char
		ld a,c     ;Lower char
hex1:   and a,0FH     ;Take 4 bits
		add a,90H
		daa             ;DAA trick
		adc a,40H
		daa
		 jp OUTT
		;check for end, HL minus DE, incr HL
tstop:  inc hl
		ld a,e
		sub a,l       ;E - L
		ld a,d
		sbc a,h       ;D - H
		ret nc             ;Not done
		pop hl       ;Raise stack
		ret             ; -- Back
;------------------
;Routine to go anywhere in memory
; Addr of WARM is on stack, so a RET will work for CALLS
go:     pop hl       ;Remove return addr for GO command
calls:  call readhl  ;Get addr
		jp (hl)            ;Go there
;------------------
; Block Move
block:
	call hldebc	;3 ADDR
movdn:
	call movin	;MOVE/CHECK
	call tstop	;DONE?
	inc bc		;NO
	 jp movdn
movin:
	ld a,(hl)			;BYTE
	ld (bc),a		;NEW LOCATION
	ld a,(bc)		;CHECK
	cp a,(hl)		;IS IT THERE?
	ret z				;YES
	ld h,b		;ERROR
	ld l,c		;INTO H,L
	 jp errp	;SHOW BAD
hldebc:
	call hldeck	;RANGE
	jp c,error	;NO BYTE
	push hl
	call readhl	;3RD INPUT
	ld b,h			;MOVE TO...
	ld c,l			;...B,C
	pop hl
	ret
	;
	; GET TWO ADDRESSES, CHECK THAT
	; ADDITIONAL DATA IS INCLUDED
	;
hldeck:
	call hhlde	;2 ADDR
	jp c,error	; THAT'S ALL
	 jp rdhld2	;CHECK
;------------------------------------------------
; MITS/MICROSOFT Boot Loader (MBL)
;  Loads MS BASIC via serial port (emulating paper tape)
;  Set sense switches as needed prior to execution
;------------------------------------------------
IF SIO2
mbl:
		call ilprt
		db		lf,cr,'MBL: Set A10 & A11 up, all others down, start transfer...',lf,cr,00h
		ld hl,mbl4		; point to source
		ld de,0h		; point to destination
		ld b,32		; move 32 bytes from source to destination
mbl1:
		ld a,(hl)			; move a byte
		ld (de),a			;
		inc hl			; bump pointers
		inc de			;
		dec b			;
		jp z,0000h		; if done, jump to 0000h to run it!
		 jp mbl1		; otherwise, process more data
;-------------------
; MITS Boot Loader for 2SIO
mbl4:	; hex codes for MITS MBL (4K, 2SIO)
		DB	3Eh,03h,0D3h,10h,3Eh,15h,0D3h,10h
		DB	21h,0AEh,0Fh,31h,1Ah,00h,0DBh,10h
		DB	0Fh,0D0h,0DBh,11h,0BDh,0C8h,2Dh,77h
		DB	0C0h,0E9h,0Bh,00h,00h,00h,00h,00h
ENDIF
;-----
IF SIOA
mbl:
		call ilprt
		db		lf,cr,'MBL: Set switch A14 up all others down, start transfer...',lf,cr,00h
		ld hl,mbl4		; point to source
		ld de,0h		; point to destination
		ld b,24		; move 24 bytes from source to destination
mbl1:
		ld a,(hl)			; move a byte
		ld (de),a			;
		inc hl			; bump pointers
		inc de			;
		dec b			;
		jp z,0000h		; if done, jump to 0000h to run it!
		 jp mbl1		; otherwise, process more data
mbl4:	; hex codes for MITS MBL (4K, SIO-A)
		DB	21H,0AEH,0FH,31H,13H,00H,0DBH,00H
		DB	0E6H,20H,0C8H,0DBH,01H,0BDH,0C8H,2DH
		DB	77H,0C0H,0E9H,03H,00H,00H,00H,00H
ENDIF
;-----
  IF SS1
mbl:
		call ilprt
		db		lf,cr,'Unsupported I/O card',lf,cr,00h
		 jp wrmst
  ENDIF
;------------------
; Block Move to Zero & Run
bmzr:
	call rdhlde  ;Get Range (test mem from HL to DE)
	ld b,0		; Zero BC (destination)
	ld c,0		;
bmz:
	ld a,(hl)		;BYTE
	ld (bc),a		;NEW LOCATION
	ld a,(bc)		;CHECK
	cp a,(hl)		;IS IT THERE?
	jp z,gdz		;YES
	ld h,b		;ERROR
	ld l,c		;INTO H,L
	 jp erm		;SHOW BAD
gdz:
	inc hl		; test if done
	ld a,e
	sub a,l       ;E - L
	ld a,d
	sbc a,h       ;D - H
	jp c,0		; If Done, jump to 0000h
	inc bc		; Not done
	 jp bmz		;
;------------------
;Test block of memory
mem:
		call rdhlde  ;Get Range (test mem from HL to DE)
		call ilprt
		db      lf,cr,'Memory Test - Bad Bytes:',lf,cr,00h
		dec hl       ; adjust pointer for looping
mloop:  inc hl       ;Point to next byte
		ld a,(hl)     ;Get byte
		cpl             ;Complement
		ld (hl),a     ;Put back complement
		cp a,(hl)       ;Same?
		jp nz,badm    ;No - bad memory
		cpl             ;Orig byte
		ld (hl),a     ;Restore it
		ld c,(hl)		; Save mem byte for bit test
						;
		ld (hl),55H	; Bit test pattern 55H
		ld b,(hl)		;
		ld a,55H	;
		cp a,b		;
		jp nz,badm	;
						;
		ld (hl),0AAH	; Bit test pattern 0AAH
		ld b,(hl)		;
		ld a,0AAH	;
		cp a,b		;
		jp nz,badm	;
						;
		ld (hl),c		; Restore mem byte
mcont:  ld a,h     ; Compare HL to DE, at end?
		cp a,d       ;
		jp nz,mloop   ;
		ld a,l     ;
		cp a,e       ;
		jp nz,mloop   ;
		call ilprt
		db		lf,cr,'Memory Test Completed',lf,cr,00h
		 jp wrmst   ; at end
badm:   call outhl   ; Display address of bad memory
		 jp mcont   ; continue
;---------------------
; XMODEM receive routine
;---------------------
; Implements basic XMODEM checksum receive function to allow loading larger
; files from PC with fewer errors.  Code modified from XMODEM v3.2 source
; by Keith Petersen
xmdm:
		call readhl  ;set load location via readhl input routine
		ld (dest),hl	;save destination address
		ld a,0		; Initialize sector number to zero
		ld (SECTNO),a	;
		call ilprt
		db		lf,cr,'Ready to receive file to memory...',lf,cr,0
RCVLP:
		call RCVSECT	;GET A SECTOR
		jp c,RCVEOT	;GOT EOT?
		call WRSECT	;WRITE THE SECTOR
		call INCRSNO	;BUMP SECTOR #
		call SENDACK	;ACK THE SECTOR
		 jp RCVLP	;LOOP UNTIL EOF
;
;GOT EOT ON SECTOR - FLUSH BUFFERS, END
;
RCVEOT:
		;CALL	WRSECT	;WRITE THE LAST BLOCK
		call SENDACK	;ACK THE SECTOR
		;CALL	CLOSFIL	;CLOSE THE FILE
		;JMP	EXIT		;ALL DONE
		 jp wrmst
;**** xmodem SUBROUTINES
;
;---->	RCVSECT: RECEIVE A SECTOR
;
;RETURNS WITH CARRY SET IF EOT RECEIVED.
;
RCVSECT: xor a,a		;GET 0
		ld (ERRCT),a	;INIT ERROR COUNT
;
RCVRPT:	ld b,10	;10 SEC TIMEOUT
		call RECV	;GET SOH/EOT
		jp c,RCVSTOT	;TIMEOUT
		cp a,SOH		;GET SOH?
		jp z,RCVSOH	;..YES
;
;EARLIER VERS. OF MODEM PROG SENT SOME NULLS -
;IGNORE THEM
;
		or a,a		;00 FROM SPEED CHECK?
		jp z,RCVRPT	;YES, IGNORE IT
		cp a,EOT		;END OF TRANSFER?
		scf				;RETURN WITH CARRY..
		ret z				;..SET IF EOT
;
;DIDN'T GET SOH  OR EOT -
;
;DIDN'T GET VALID HEADER - PURGE THE LINE,
;THEN SEND NAK.
;
RCVSERR:	ld b,1	;WAIT FOR 1 SEC..
	call RECV	;..WITH NO CHARS
	jp nc,RCVSERR	;LOOP UNTIL SENDER DONE
	ld a,NAK	;SEND..
	call SEND	;..THE NAK
	ld a,(ERRCT)	;ABORT IF..
	inc a	;..WE HAVE REACHED..
	ld (ERRCT),a	;..THE ERROR..
	cp a,ERRLIM	;..LIMIT?
	jp c,RCVRPT	;..NO, TRY AGAIN
;
;10 ERRORS IN A ROW -
;
RCVSABT:
	;CALL	CLOSFIL	;KEEP WHATEVER WE GOT
	;CALL	ERXIT
	call ilprt
	DB	'++UNABLE TO RECEIVE BLOCK '
	DB	'- ABORTING++',CR,0
	 jp wrmst
;
;TIMEDOUT ON RECEIVE
;
RCVSTOT:
	 jp RCVSERR	;BUMP ERR CT, ETC.
;
;GOT SOH - GET BLOCK #, BLOCK # COMPLEMENTED
;
RCVSOH:
	ld b,1	;TIMEOUT = 1 SEC
	call RECV	;GET SECTOR
	jp c,RCVSTOT	;GOT TIMEOUT
	ld d,a	;D=BLK #
	ld b,1	;TIMEOUT = 1 SEC
	call RECV	;GET CMA'D SECT #
	jp c,RCVSTOT	;TIMEOUT
	cpl		;CALC COMPLEMENT
	cp a,d	;GOOD SECTOR #?
	jp z,RCVDATA	;YES, GET DATA
;
;GOT BAD SECTOR #
;
	 jp RCVSERR	;BUMP ERROR CT.
;
RCVDATA:
	ld a,d	;GET SECTOR #
	ld (RCVSNO),a	;SAVE IT to storage area
	ld c,0	;INIT CKSUM
	ld hl,DMABUF	;POINT TO BUFFER  <--- CPM DMA buffer @ 80H
;
RCVCHR:
	ld b,1	;1 SEC TIMEOUT
	call RECV	;GET CHAR
	jp c,RCVSTOT	;TIMEOUT
	ld (hl),a	;STORE CHAR
	inc l	;DONE?
	jp nz,RCVCHR	;NO, LOOP
;
;VERIFY CHECKSUM
;
	ld d,c	;SAVE CHECKSUM
	ld b,1	;TIMEOUT LEN.
	call RECV	;GET CHECKSUM
	jp c,RCVSTOT	;TIMEOUT
	cp a,d	;CHECKSUM OK?
	jp nz,RCVSERR	;NO, ERROR
;
;GOT A SECTOR, IT'S A DUP IF = PREV,
;	OR OK IF = 1 + PREV SECTOR
;
	ld a,(RCVSNO)	;GET RECEIVED
	ld b,a	;SAVE IT
	ld a,(SECTNO)	;GET PREV
	cp a,b	;PREV REPEATED?
	jp z,RECVACK	;ACK TO CATCH UP
	inc a	;CALC NEXT SECTOR #
	cp a,b	;MATCH?
	jp nz,ABORT	;NO MATCH - STOP SENDER, EXIT
	ret		;CARRY OFF - NO ERRORS
;
;PREV SECT REPEATED, DUE TO THE LAST ACK
;BEING GARBAGED.  ACK IT SO SENDER WILL CATCH UP
;
RECVACK:
	call SENDACK	;SEND THE ACK,
	 jp RCVSECT	;GET NEXT BLOCK
;
;SEND AN ACK FOR THE SECTOR
;
SENDACK:
	ld a,ACK	;GET ACK
	call SEND	;..AND SEND IT
	ret
;
ABORT:
	;LXI	SP,STACK
;
ABORTL:
	ld b,1	;1 SEC. W/O CHARS.
	call RECV
	jp nc,ABORTL	;LOOP UNTIL SENDER DONE
	ld a,CTRX	;CONTROL X
	call SEND	;STOP SENDING END
;
ABORTW:
	ld b,1	;1 SEC W/O CHARS.
	call RECV
	jp nc,ABORTW	;LOOP UNTIL SENDER DONE
	ld a,' '	;GET A SPACE...
	call SEND	;TO CLEAR OUT CONTROL X
	;CALL	ERXIT	;EXIT WITH ABORT MSG
	;DB	'XMODEM PROGRAM CANCELLED',lf,cr,'$'
	call ilprt
	db	CR,'XMODEM CANCELLED',CR,'0'
	ret			; <--------exit point -------
;
;---->	INCRSNO: INCREMENT SECTOR #
;
INCRSNO:
	ld a,(SECTNO)	;INCR..
	inc a	;..SECT..
	ld (SECTNO),a	;..NUMBER
	ret
;
;
;---->	WRSECT: WRITE A SECTOR
;
WRSECT:
	ld hl,(dest)		;load destination address to HL
	ex de,hl				;put destination address in DE
	ld hl,DMABUF	;load CPM dma buffer address to HL
	call MOVE128		;move 128 bytes to destination
	ex de,hl				; get updated dest addr in HL
	ld (dest),hl		; store it - update destination pointer
	ret
;
;---->	RECV: RECEIVE A CHARACTER
;
;TIMEOUT TIME IS IN B, IN SECONDS.
;
RECV:
	push de	;SAVE
;
	;IF	FASTCLK	;4MHZ?
	;MOV	A,B	;GET TIME REQUEST
	;ADD	A	;DOUBLE IT
	;MOV	B,A	;NEW TIME IN B
	;ENDIF
;
MSEC:
	ld de,50000	;1 SEC DCR COUNT
;
MWTI:
	in a,(TTS)		; IMSAI specific, check input status
	and a,TTYDA	; ""
	jp nz,MCHAR	;got a char
	dec e	;COUNT..
	jp nz,MWTI	;..DOWN..
	dec d	;..FOR..
	jp nz,MWTI	;..TIMEOUT
	dec b	;MORE SECONDS?
	jp nz,MSEC	;YES, WAIT
;
;MODEM TIMED OUT RECEIVING
;
	pop de	;RESTORE D,E
	scf		;CARRY SHOWS TIMEOUT
	ret
;
;GOT CHAR FROM MODEM
;
MCHAR:
	in a,(TTI)	; IMSAI specific, get input byte
	pop de	;RESTORE DE
;
;CALC CHECKSUM
;
	push af	;SAVE THE CHAR
	add a,c	;ADD TO CHECKSUM
	ld c,a	;SAVE CHECKSUM
	pop af	;RESTORE CHAR
	or a,a	;CARRY OFF: NO ERROR
	ret		;FROM "RECV"
;
;
;---->	SEND: SEND A CHARACTER TO THE MODEM
;
SEND:
	push af		;SAVE THE CHAR
	add a,c		;CALC CKSUM
	ld c,a		;SAVE CKSUM
SENDW:
	in a,(TTS)		; IMSAI specific, Check Console Output Status
	and a,TTYTR
	jp z,SENDW	;..NO, WAIT
	pop af		;GET CHAR
	out (TTO),a     ; IMSAI specific, Send Data
	ret				;FROM "SEND"
;
;----->  MOVE 128 CHARACTERS
;
MOVE128:ld b,128	;SET MOVE COUNT
;
;MOVE FROM (HL) TO (DE) LENGTH IN (B)
;
MOVE:
	ld a,(hl)	;GET A CHAR
	ld (de),a	;STORE IT
	inc hl	;TO NEXT "FROM"
	inc de	;TO NEXT "TO"
	dec b	;MORE?
	jp nz,MOVE	;..YES, LOOP
	ret		;..NO, RETURN
;
; END XMODEM CODE
;------------------
;-------------------------------------
; HELP SCREEN
;-------------------------------------
help:
		call ilprt
		db      lf,cr
		db		'Altair 8800 Monitor Commands:',lf,cr
		db		'------------------------------------------',lf,cr
		db      ' Ex y   - Examine memory x to y',lf,cr
		db      ' Dx     - Deposit data at address x',lf,cr
		db		' Bx y z - Block move x-y to z',lf,cr
		db      ' Jx     - Jump to x',lf,cr
		db		' L      - MITS 4K BASIC Boot Loader',lf,cr
		db      ' Mx y   - Memory Test x-y',lf,cr
		db		' Xx     - Xmodem File Receive to memory at x',lf,cr
		db		' Zx y   - Block move x-y to 0000h & RUN',lf,cr
		db      00h
		 jp wrmst
;--------------------------------------
;Monitor Command Subroutines
;--------------------------------------
;------------------
;Inline Print
;
;THE CALL TO ILPRT IS FOLLOWED BY A MESSAGE,
;BINARY 0 AS THE END.
;
ilprt:  ex hl,(sp)            ;SAVE HL, GET HL=MSG
ilplp:  ld a,(hl)     ;GET CHAR
		or a,a		;END OF MSG?
		jp z,ilpret  ;..YES, RETURN
		call outt    ;TYPE THE MSG
		inc hl		;TO NEXT CHAR
		 jp ilplp   ;LOOP
ilpret: ex hl,(sp)            ;RESTORE HL
	ret		;PAST MSG
;------------------
;Input line from console and store in buffer
;Ctl-X cancels line, ,BKSP erases last char, CR enters line
inpln:                          ;Input line from console and
		call ilprt
		db      lf,cr,'>',00h      ; * PROMPT CHARACTER *
inpl2:  ld hl,IBUFF         ;Input buffer addr
		ld (IBUFP),hl
		ld c,0             ;Init count to zero
inpli:  call intt            ;Get char from console
		cp a,' '             ;Control char?
		jp c,inplc           ;Yes
		cp a,DEL             ;Delete char?
		jp z,inplb           ;Yes
		cp a,'Z'+1           ;Upper case?
		jp c,inpl3           ;Yes
		and a,5Fh             ;No - so make upper case
inpl3:  ld (hl),a             ;Into buffer
		ld a,IBL           ;Buffer size
		cp a,c               ;Full?
		jp z,inpli           ;Yes, loop
		ld a,(hl)             ;Get char from buffer
		inc hl               ;Incr pointer
		inc c               ; and count
inple:  call OUTT            ;Show char
		 jp inpli           ;Next char
		;Process control chars
inplc:  cp a,CTRH            ;Ctl H ?
		jp z,inplb           ;Yes
		cp a,CR              ;Return?
		jp nz,inpli           ;No, ignore
		;End of input line
		ld a,c             ;Count
		ld (IBUFC),a           ;Save it
		;CR LF routine
crlf:
		ld a,CR
		call outt            ;Send CR
		ld a,LF
		 jp outt            ;Send LF
;        MVI     A,CR
;        JMP     outt
		;Delete prior char, if any
inplb:  ld a,c             ;Char count
		or a,a               ;Zero?
		jp z,inpli           ;Yes
		dec hl               ;Back pointer
		dec c               ; and count
		ld a,CTRH
		;;MVI     A,DEL
		 jp inple           ;Send ctrl H
;------------------
;Get Character from Console Buffer
; Set Carry Bit if empty
getch:  push hl               ;Save Regs
		ld hl,(IBUFP)           ;Get Pointer
		ld a,(IBUFC)           ; and Count
		sub a,1               ;Decr with carry
		jp c,getc4           ;No more char
		ld (IBUFC),a           ;Save new count
		ld a,(hl)             ;Get character
		inc hl               ;Incr pointer
		ld (IBUFP),hl           ; and save
getc4:  pop hl               ;Restore Regs
		ret
;-------------------
; Memory error message
erm:
		call ilprt
		db      lf,cr,'Memory Error at ',00h
		call outhl
		 jp wrmst
;------------------
; Simplified Core IO Routines
;------------------
;Console Input
intt:
		call instat          ;Check status
		in a,(TTI)             ;Get byte
		and a,DEL
		cp a,CTRX            ;Abort?
		jp z,wrmst           ;
		ret
;------------------
;Console Output
outt:
		push af
		call outstat
		pop af
		out (TTO),a             ;Send Data
		ret
;------------------
;Check Console Input Status
instat:
		in a,(TTS)
		and a,TTYDA
		jp z,instat
		ret
;------------------
;Check Console Output Status
outstat:
		in a,(TTS)             ;CHECK FOR USER INPUT CTRL-X
		and a,TTYDA           ;
		jp z,out2            ;
		in a,(TTI)             ;
		and a,DEL             ;
		cp a,CTRX            ;
		jp z,wrmst           ;
out2:   in a,(TTS)             ;Check Console Output Statuas
		and a,TTYTR           ;
		jp z,outstat         ;
		ret
;==================
		END
;==================
