#!/usr/local/bin/zasm --convert8080 --asm8080 --reqcolon -o original/
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

		LXI     SP,STACK        ; Initialize stack for welcome msg

		CALL    ilprt           ;Display welcome message
		db      lf,cr,'Altair 8800 Monitor 8.4',00h
		CALL    ilprt           ;Display welcome message
		db      lf,cr,'(C) 2009 John Garza',lf,cr,00h

wrmst:
		LXI     SP,STACK        ;Re-Initialize stack

		LXI     H,wrmst         ;Put return addr on stack
		PUSH    H               ; so command routines can do a RET

		CALL    inpln           ;Get command string
		CALL    getch           ;Get first char from command

		; Process the command

		CPI     'D'     ; Deposit data into memory
		JZ      enter   ;

		CPI     'E'     ; Examine memory to console
		JZ      dump    ;

		CPI     'B'     ; Block Move
		JZ      block   ;

		CPI     'J'     ; Jump - execute external code (no return)
		JZ      go      ;

		CPI     'L'     ; MBL - Microsoft Boot Loader for BASIC
		JZ      mbl     ;

		CPI     'M'     ; Memory Test
		JZ      mem     ;

		CPI     'X'     ; Xmodem receive
		JZ      xmdm

		CPI     'Z'     ; Block Move to Zero & RUN
		JZ      bmzr    ;

		CPI     '?'     ; Help screen
		JZ      help    ;


		JMP     wrmst   ; Go back for another command

;--------------------------------------
;Command Main Routines
;--------------------------------------

;------------------
;Memory Load routine
; Load hex or ascii into mem from console
; Check data was written, apostrophe precedes ascii
; CR passes over a location

enter:
		CALL	ilprt
		db		lf,cr,'Memory Load: apostrophe for ASCII, CR skips addr, Ctrl-X exits',lf,cr,00h

load:   CALL    readhl  ;Addr
load2:  CALL    outhl   ;Print it
		CALL    pasci   ;Ascii
		CALL    outsp
		MOV     C,M     ;Orig byte
		CALL    outhex  ;Hex
		PUSH    H       ;Save pointer
		CALL    inpl2   ;Input
		CALL    readhl  ; Byte
		MOV     B,L     ; To B
		POP     H
		CPI     APOS
		JZ      load6   ;Ascii input
		MOV     A,C     ;How many?
		ORA     A       ;None?
		JZ      load3   ;Yes
load4:  CALL    chekm   ;Into mem
load3:  INX     H       ;Pointer
		JMP     load2

		;load ascii char

load6:  CALL    getch
		MOV     B,A
		JMP     load4

		;copy byte from B to memory
		; and see that it got there

chekm:  MOV     M,B     ;Put in mem
		MOV     A,M     ;Read back into A
		CMP     B       ;Same?
		RZ              ;Yes
errp:
		POP		PSW		;RAISE STACK
errb:
		MVI		A,'B'	;'B' = 'BAD'
err2:
		CALL	outt
		CALL	outsp
		JMP		outhl


;------------------
; Memory Dump routine
; Display Hex & ascii mem contents over specified range
;

dump:

		CALL    rdhlde  ;Range
dump2:  CALL    crhl    ;New line
dump3:  MOV     C,M     ;Get byte
		CALL    outhx   ;Print
		INX     H       ;Pointer
		MOV     A,L
		ANI     0FH     ;Line end?
		JZ      dump4   ;Yes, ascii
		ANI     3       ;Space
		CZ      outsp   ; 4 bytes
		JMP     dump3   ;Next hex
dump4:  CALL    outsp
		PUSH    D
		LXI     D,-10H  ;Reset line
		DAD     D
		POP     D
dump5:  CALL    pasci   ;ascii dump
		CALL    tstop   ;Done?
		MOV     A,L     ;No
		ANI     0FH     ;line end?
		JNZ     dump5   ;No
		JMP     dump2

		;display byte in ascii if possible, otherwise dot

pasci:  MOV     A,M     ;Get byte
		CPI     DEL     ;High bit on?
		JNC     pasc2   ;Yes
		CPI     ' '     ;Control char?
		JNC     pasc3   ;No
pasc2:  MVI     A,'.'   ;Change to dot
pasc3:  JMP     outt    ;Send

		;get HL and DE from console, check that DE is larger

rdhlde: CALL    hhlde
rdhld2: MOV     A,E
		SUB     L       ;E - L
		MOV     A,D
		SBB     H       ;D - H
		JC      error   ;HL is bigger
		RET

		;input HL and DE, check that 2 addr are entered

hhlde:  CALL    readhl  ;HL
		JC      error   ;Only 1 addr
		XCHG            ;Save in DE
		CALL    readhl  ;DE
		XCHG            ;Put back
		RET

		;input HL from console

readhl: PUSH    D
		PUSH    B       ;Save regs
		LXI     H,0     ;Clear
rdhl2:  CALL    getch   ;Get char
		JC      rdhl5   ;Line end
		CALL    nib     ;To binary
		JC      rdhl4   ;Not hex
		DAD     H       ;Times 2
		DAD     H       ;Times 4
		DAD     H       ;Times 8
		DAD     H       ;Times 16
		ORA     L       ;Add new char
		MOV     L,A
		JMP     rdhl2   ;Next

		;check for blank at end

rdhl4:  CPI     APOS    ;Apostrophe
		JZ      rdhl5   ;Ascii input
		CPI     (' '-'0') AND 0FFH
		JNZ     error   ;N0
rdhl5:  POP     B
		POP     D       ;Restore
		RET

		;convert ascii chars to binary

nib:    SUI     '0'     ;Ascii bias
		RC              ;<0
		CPI     'F'-'0'+1
		CMC             ;Invert
		RC              ;Error, >F
		CPI     10
		CMC             ;Invert
		RNC             ;Number 0-9
		SUI     'A'-'9'-1
		CPI     10      ;Skip : to
		RET             ;Letter A-F

		;print ? on improper input

error:  MVI     A,'?'
		CALL    outt
		JMP     wrmst   ;Try again

		;start new line, give addr

crhl:   CALL    crlf    ;New line
outhl:  MOV     C,H
		CALL    outhx
outll:  MOV     C,L
outhex: CALL    outhx
outsp:  MVI     A,' '
		JMP     outt

		;output a hex byte from C (ASCII to HEX converter)

outhx:  MOV     A,C
		RAR             ;Rotate
		RAR             ; 4 bits
		RAR             ; to
		RAR             ; the right
		CALL    hex1    ;Upper char
		MOV     A,C     ;Lower char
hex1:   ANI     0FH     ;Take 4 bits
		ADI     90H
		DAA             ;DAA trick
		ACI     40H
		DAA
		JMP     OUTT

		;check for end, HL minus DE, incr HL

tstop:  INX     H
		MOV     A,E
		SUB     L       ;E - L
		MOV     A,D
		SBB     H       ;D - H
		RNC             ;Not done

		POP     H       ;Raise stack
		RET             ; -- Back

;------------------
;Routine to go anywhere in memory
; Addr of WARM is on stack, so a RET will work for CALLS

go:     POP     H       ;Remove return addr for GO command
calls:  CALL    readhl  ;Get addr
		PCHL            ;Go there

;------------------
; Block Move
block:
	CALL	hldebc	;3 ADDR
movdn:
	CALL	movin	;MOVE/CHECK
	CALL	tstop	;DONE?
	INX		B		;NO
	JMP		movdn
movin:
	MOV	A,M			;BYTE
	STAX	B		;NEW LOCATION
	LDAX	B		;CHECK
	CMP		M		;IS IT THERE?
	RZ				;YES
	MOV		H,B		;ERROR
	MOV		L,C		;INTO H,L
	JMP		errp	;SHOW BAD

hldebc:
	CALL	hldeck	;RANGE
	JC		error	;NO BYTE
	PUSH	H
	CALL	readhl	;3RD INPUT
	MOV	B,H			;MOVE TO...
	MOV	C,L			;...B,C
	POP	H
	RET
	;
	; GET TWO ADDRESSES, CHECK THAT
	; ADDITIONAL DATA IS INCLUDED
	;
hldeck:
	CALL	hhlde	;2 ADDR
	JC		error	; THAT'S ALL
	JMP		rdhld2	;CHECK


;------------------------------------------------
; MITS/MICROSOFT Boot Loader (MBL)
;  Loads MS BASIC via serial port (emulating paper tape)
;  Set sense switches as needed prior to execution
;------------------------------------------------

IF SIO2
mbl:
		CALL	ilprt
		db		lf,cr,'MBL: Set A10 & A11 up, all others down, start transfer...',lf,cr,00h

		LXI		H,mbl4		; point to source
		LXI		D,0h		; point to destination
		MVI		B,32		; move 32 bytes from source to destination
mbl1:
		MOV		A,M			; move a byte
		STAX	D			;

		INX		H			; bump pointers
		INX		D			;
		DCR		B			;

		JZ		0000h		; if done, jump to 0000h to run it!

		JMP		mbl1		; otherwise, process more data

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
		CALL	ilprt
		db		lf,cr,'MBL: Set switch A14 up all others down, start transfer...',lf,cr,00h

		LXI		H,mbl4		; point to source
		LXI		D,0h		; point to destination
		MVI		B,24		; move 24 bytes from source to destination
mbl1:
		MOV		A,M			; move a byte
		STAX	D			;

		INX		H			; bump pointers
		INX		D			;
		DCR		B			;

		JZ		0000h		; if done, jump to 0000h to run it!

		JMP		mbl1		; otherwise, process more data


mbl4:	; hex codes for MITS MBL (4K, SIO-A)
		DB	21H,0AEH,0FH,31H,13H,00H,0DBH,00H
		DB	0E6H,20H,0C8H,0DBH,01H,0BDH,0C8H,2DH
		DB	77H,0C0H,0E9H,03H,00H,00H,00H,00H

ENDIF

;-----
  IF SS1

mbl:
		CALL	ilprt
		db		lf,cr,'Unsupported I/O card',lf,cr,00h
		jmp		wrmst

  ENDIF

;------------------
; Block Move to Zero & Run
bmzr:
	CALL    rdhlde  ;Get Range (test mem from HL to DE)
	MVI		B,0		; Zero BC (destination)
	MVI		C,0		;

bmz:
	MOV		A,M		;BYTE
	STAX	B		;NEW LOCATION
	LDAX	B		;CHECK
	CMP		M		;IS IT THERE?
	JZ		gdz		;YES
	MOV		H,B		;ERROR
	MOV		L,C		;INTO H,L
	JMP		erm		;SHOW BAD

gdz:
	INX     H		; test if done
	MOV     A,E
	SUB     L       ;E - L
	MOV     A,D
	SBB     H       ;D - H
	JC		0		; If Done, jump to 0000h

	INX		B		; Not done
	JMP		bmz		;


;------------------
;Test block of memory

mem:
		CALL    rdhlde  ;Get Range (test mem from HL to DE)

		CALL    ilprt
		db      lf,cr,'Memory Test - Bad Bytes:',lf,cr,00h


		DCX     H       ; adjust pointer for looping
mloop:  INX     H       ;Point to next byte
		MOV     A,M     ;Get byte
		CMA             ;Complement
		MOV     M,A     ;Put back complement
		CMP     M       ;Same?
		JNZ     badm    ;No - bad memory
		CMA             ;Orig byte
		MOV     M,A     ;Restore it

		MOV		C,M		; Save mem byte for bit test
						;
		MVI		M, 55H	; Bit test pattern 55H
		MOV		B,M		;
		MVI		A, 55H	;
		CMP		B		;
		JNZ		badm	;
						;
		MVI		M, 0AAH	; Bit test pattern 0AAH
		MOV		B,M		;
		MVI		A, 0AAH	;
		CMP		B		;
		JNZ		badm	;
						;
		MOV		M,C		; Restore mem byte


mcont:  MOV     A,H     ; Compare HL to DE, at end?
		CMP     D       ;
		JNZ     mloop   ;
		MOV     A,L     ;
		CMP     E       ;
		JNZ     mloop   ;

		CALL	ilprt
		db		lf,cr,'Memory Test Completed',lf,cr,00h

		JMP     wrmst   ; at end


badm:   CALL    outhl   ; Display address of bad memory

		JMP     mcont   ; continue

;---------------------
; XMODEM receive routine
;---------------------
; Implements basic XMODEM checksum receive function to allow loading larger
; files from PC with fewer errors.  Code modified from XMODEM v3.2 source
; by Keith Petersen

xmdm:
		CALL    readhl  ;set load location via readhl input routine
		SHLD	dest	;save destination address

		MVI		A,0		; Initialize sector number to zero
		STA		SECTNO	;

		CALL	ilprt
		db		lf,cr,'Ready to receive file to memory...',lf,cr,0

RCVLP:
		CALL	RCVSECT	;GET A SECTOR
		JC		RCVEOT	;GOT EOT?
		CALL	WRSECT	;WRITE THE SECTOR
		CALL	INCRSNO	;BUMP SECTOR #
		CALL	SENDACK	;ACK THE SECTOR
		JMP		RCVLP	;LOOP UNTIL EOF
;
;GOT EOT ON SECTOR - FLUSH BUFFERS, END
;
RCVEOT:
		;CALL	WRSECT	;WRITE THE LAST BLOCK
		CALL	SENDACK	;ACK THE SECTOR
		;CALL	CLOSFIL	;CLOSE THE FILE
		;JMP	EXIT		;ALL DONE

		JMP	wrmst


;**** xmodem SUBROUTINES
;
;---->	RCVSECT: RECEIVE A SECTOR
;
;RETURNS WITH CARRY SET IF EOT RECEIVED.
;
RCVSECT: XRA	A		;GET 0
		STA		ERRCT	;INIT ERROR COUNT
;
RCVRPT:	MVI		B,10	;10 SEC TIMEOUT
		CALL	RECV	;GET SOH/EOT
		JC		RCVSTOT	;TIMEOUT
		CPI		SOH		;GET SOH?
		JZ		RCVSOH	;..YES
;
;EARLIER VERS. OF MODEM PROG SENT SOME NULLS -
;IGNORE THEM
;
		ORA		A		;00 FROM SPEED CHECK?
		JZ		RCVRPT	;YES, IGNORE IT
		CPI		EOT		;END OF TRANSFER?
		STC				;RETURN WITH CARRY..
		RZ				;..SET IF EOT
;
;DIDN'T GET SOH  OR EOT -
;
;DIDN'T GET VALID HEADER - PURGE THE LINE,
;THEN SEND NAK.
;
RCVSERR:	MVI	B,1	;WAIT FOR 1 SEC..
	CALL	RECV	;..WITH NO CHARS
	JNC	RCVSERR	;LOOP UNTIL SENDER DONE
	MVI	A,NAK	;SEND..
	CALL	SEND	;..THE NAK
	LDA	ERRCT	;ABORT IF..
	INR	A	;..WE HAVE REACHED..
	STA	ERRCT	;..THE ERROR..
	CPI	ERRLIM	;..LIMIT?
	JC	RCVRPT	;..NO, TRY AGAIN
;
;10 ERRORS IN A ROW -
;
RCVSABT:
	;CALL	CLOSFIL	;KEEP WHATEVER WE GOT
	;CALL	ERXIT

	CALL	ilprt
	DB	'++UNABLE TO RECEIVE BLOCK '
	DB	'- ABORTING++',CR,0

	JMP		wrmst
;
;TIMEDOUT ON RECEIVE
;
RCVSTOT:
	JMP	RCVSERR	;BUMP ERR CT, ETC.
;
;GOT SOH - GET BLOCK #, BLOCK # COMPLEMENTED
;
RCVSOH:
	MVI	B,1	;TIMEOUT = 1 SEC
	CALL	RECV	;GET SECTOR
	JC	RCVSTOT	;GOT TIMEOUT
	MOV	D,A	;D=BLK #
	MVI	B,1	;TIMEOUT = 1 SEC
	CALL	RECV	;GET CMA'D SECT #
	JC	RCVSTOT	;TIMEOUT
	CMA		;CALC COMPLEMENT
	CMP	D	;GOOD SECTOR #?
	JZ	RCVDATA	;YES, GET DATA
;
;GOT BAD SECTOR #
;
	JMP	RCVSERR	;BUMP ERROR CT.
;
RCVDATA:
	MOV	A,D	;GET SECTOR #
	STA	RCVSNO	;SAVE IT to storage area
	MVI	C,0	;INIT CKSUM
	LXI	H,DMABUF	;POINT TO BUFFER  <--- CPM DMA buffer @ 80H
;
RCVCHR:
	MVI	B,1	;1 SEC TIMEOUT
	CALL	RECV	;GET CHAR
	JC	RCVSTOT	;TIMEOUT
	MOV	M,A	;STORE CHAR
	INR	L	;DONE?
	JNZ	RCVCHR	;NO, LOOP
;
;VERIFY CHECKSUM
;
	MOV	D,C	;SAVE CHECKSUM
	MVI	B,1	;TIMEOUT LEN.
	CALL	RECV	;GET CHECKSUM
	JC	RCVSTOT	;TIMEOUT
	CMP	D	;CHECKSUM OK?
	JNZ	RCVSERR	;NO, ERROR
;
;GOT A SECTOR, IT'S A DUP IF = PREV,
;	OR OK IF = 1 + PREV SECTOR
;
	LDA	RCVSNO	;GET RECEIVED
	MOV	B,A	;SAVE IT
	LDA	SECTNO	;GET PREV
	CMP	B	;PREV REPEATED?
	JZ	RECVACK	;ACK TO CATCH UP
	INR	A	;CALC NEXT SECTOR #
	CMP	B	;MATCH?
	JNZ	ABORT	;NO MATCH - STOP SENDER, EXIT
	RET		;CARRY OFF - NO ERRORS
;
;PREV SECT REPEATED, DUE TO THE LAST ACK
;BEING GARBAGED.  ACK IT SO SENDER WILL CATCH UP
;
RECVACK:
	CALL	SENDACK	;SEND THE ACK,
	JMP	RCVSECT	;GET NEXT BLOCK
;
;SEND AN ACK FOR THE SECTOR
;
SENDACK:
	MVI	A,ACK	;GET ACK
	CALL	SEND	;..AND SEND IT
	RET
;

ABORT:
	;LXI	SP,STACK
;
ABORTL:
	MVI	B,1	;1 SEC. W/O CHARS.
	CALL	RECV
	JNC	ABORTL	;LOOP UNTIL SENDER DONE
	MVI	A,CTRX	;CONTROL X
	CALL	SEND	;STOP SENDING END
;
ABORTW:
	MVI	B,1	;1 SEC W/O CHARS.
	CALL	RECV
	JNC	ABORTW	;LOOP UNTIL SENDER DONE
	MVI	A,' '	;GET A SPACE...
	CALL	SEND	;TO CLEAR OUT CONTROL X
	;CALL	ERXIT	;EXIT WITH ABORT MSG
	;DB	'XMODEM PROGRAM CANCELLED',lf,cr,'$'
	CALL	ilprt
	db	CR,'XMODEM CANCELLED',CR,'0'
	RET			; <--------exit point -------

;
;---->	INCRSNO: INCREMENT SECTOR #
;
INCRSNO:
	LDA	SECTNO	;INCR..
	INR	A	;..SECT..
	STA	SECTNO	;..NUMBER
	RET
;

;
;---->	WRSECT: WRITE A SECTOR
;
WRSECT:

	LHLD	dest		;load destination address to HL
	XCHG				;put destination address in DE
	LXI		H,DMABUF	;load CPM dma buffer address to HL
	CALL	MOVE128		;move 128 bytes to destination
	XCHG				; get updated dest addr in HL
	SHLD	dest		; store it - update destination pointer
	RET

;
;---->	RECV: RECEIVE A CHARACTER
;
;TIMEOUT TIME IS IN B, IN SECONDS.
;
RECV:
	PUSH	D	;SAVE
;
	;IF	FASTCLK	;4MHZ?
	;MOV	A,B	;GET TIME REQUEST
	;ADD	A	;DOUBLE IT
	;MOV	B,A	;NEW TIME IN B
	;ENDIF
;
MSEC:
	LXI	D,50000	;1 SEC DCR COUNT
;
MWTI:

	IN      TTS		; IMSAI specific, check input status
	ANI     TTYDA	; ""
	JNZ		MCHAR	;got a char

	DCR	E	;COUNT..
	JNZ	MWTI	;..DOWN..
	DCR	D	;..FOR..
	JNZ	MWTI	;..TIMEOUT
	DCR	B	;MORE SECONDS?
	JNZ	MSEC	;YES, WAIT
;
;MODEM TIMED OUT RECEIVING
;
	POP	D	;RESTORE D,E
	STC		;CARRY SHOWS TIMEOUT
	RET
;
;GOT CHAR FROM MODEM
;
MCHAR:
	IN      TTI	; IMSAI specific, get input byte
	POP	D	;RESTORE DE
;
;CALC CHECKSUM
;
	PUSH	PSW	;SAVE THE CHAR
	ADD	C	;ADD TO CHECKSUM
	MOV	C,A	;SAVE CHECKSUM
	POP	PSW	;RESTORE CHAR
	ORA	A	;CARRY OFF: NO ERROR
	RET		;FROM "RECV"
;
;
;---->	SEND: SEND A CHARACTER TO THE MODEM
;
SEND:
	PUSH	PSW		;SAVE THE CHAR
	ADD		C		;CALC CKSUM
	MOV		C,A		;SAVE CKSUM

SENDW:
	IN		TTS		; IMSAI specific, Check Console Output Status
	ANI		TTYTR
	JZ		SENDW	;..NO, WAIT
	POP		PSW		;GET CHAR
	OUT		TTO     ; IMSAI specific, Send Data
	RET				;FROM "SEND"

;
;----->  MOVE 128 CHARACTERS
;
MOVE128:MVI	B,128	;SET MOVE COUNT
;
;MOVE FROM (HL) TO (DE) LENGTH IN (B)
;
MOVE:
	MOV	A,M	;GET A CHAR
	STAX	D	;STORE IT
	INX	H	;TO NEXT "FROM"
	INX	D	;TO NEXT "TO"
	DCR	B	;MORE?
	JNZ	MOVE	;..YES, LOOP
	RET		;..NO, RETURN
;
; END XMODEM CODE
;------------------

;-------------------------------------
; HELP SCREEN
;-------------------------------------
help:
		CALL    ilprt

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

		JMP     wrmst

;--------------------------------------
;Monitor Command Subroutines
;--------------------------------------

;------------------
;Inline Print
;
;THE CALL TO ILPRT IS FOLLOWED BY A MESSAGE,
;BINARY 0 AS THE END.
;

ilprt:  XTHL            ;SAVE HL, GET HL=MSG
ilplp:  MOV     A,M     ;GET CHAR
		ORA		A		;END OF MSG?
		JZ      ilpret  ;..YES, RETURN
		CALL    outt    ;TYPE THE MSG
		INX		H		;TO NEXT CHAR
		JMP     ilplp   ;LOOP
ilpret: XTHL            ;RESTORE HL
	RET		;PAST MSG


;------------------
;Input line from console and store in buffer
;Ctl-X cancels line, ,BKSP erases last char, CR enters line

inpln:                          ;Input line from console and
		CALL    ilprt
		db      lf,cr,'>',00h      ; * PROMPT CHARACTER *

inpl2:  LXI     H,IBUFF         ;Input buffer addr
		SHLD    IBUFP
		MVI     C,0             ;Init count to zero

inpli:  CALL    intt            ;Get char from console

		CPI     ' '             ;Control char?
		JC      inplc           ;Yes

		CPI     DEL             ;Delete char?
		JZ      inplb           ;Yes

		CPI     'Z'+1           ;Upper case?
		JC      inpl3           ;Yes
		ANI     5Fh             ;No - so make upper case


inpl3:  MOV     M,A             ;Into buffer
		MVI     A,IBL           ;Buffer size
		CMP     C               ;Full?
		JZ      inpli           ;Yes, loop
		MOV     A,M             ;Get char from buffer
		INX     H               ;Incr pointer
		INR     C               ; and count
inple:  CALL    OUTT            ;Show char
		JMP     inpli           ;Next char

		;Process control chars

inplc:  CPI     CTRH            ;Ctl H ?
		JZ      inplb           ;Yes
		CPI     CR              ;Return?
		JNZ     inpli           ;No, ignore

		;End of input line

		MOV     A,C             ;Count
		STA     IBUFC           ;Save it

		;CR LF routine

crlf:
		MVI     A,CR
		CALL    outt            ;Send CR
		MVI     A,LF
		JMP     outt            ;Send LF

;        MVI     A,CR
;        JMP     outt

		;Delete prior char, if any

inplb:  MOV     A,C             ;Char count
		ORA     A               ;Zero?
		JZ      inpli           ;Yes
		DCX     H               ;Back pointer
		DCR     C               ; and count

		MVI     A,CTRH
		;;MVI     A,DEL

		JMP     inple           ;Send ctrl H

;------------------
;Get Character from Console Buffer
; Set Carry Bit if empty

getch:  PUSH    H               ;Save Regs
		LHLD    IBUFP           ;Get Pointer
		LDA     IBUFC           ; and Count
		SUI     1               ;Decr with carry
		JC      getc4           ;No more char
		STA     IBUFC           ;Save new count
		MOV     A,M             ;Get character
		INX     H               ;Incr pointer
		SHLD    IBUFP           ; and save
getc4:  POP     H               ;Restore Regs
		RET

;-------------------
; Memory error message
erm:

		CALL    ilprt
		db      lf,cr,'Memory Error at ',00h
		CALL	outhl

		JMP		wrmst


;------------------
; Simplified Core IO Routines

;------------------
;Console Input

intt:
		CALL    instat          ;Check status
		IN      TTI             ;Get byte
		ANI     DEL
		CPI     CTRX            ;Abort?
		JZ      wrmst           ;
		RET

;------------------
;Console Output

outt:
		PUSH    PSW
		CALL    outstat
		POP     PSW
		OUT     TTO             ;Send Data
		RET


;------------------
;Check Console Input Status

instat:
		IN      TTS
		ANI     TTYDA
		JZ      instat
		RET

;------------------
;Check Console Output Status

outstat:
		IN      TTS             ;CHECK FOR USER INPUT CTRL-X
		ANI     TTYDA           ;
		JZ      out2            ;
		IN      TTI             ;
		ANI     DEL             ;
		CPI     CTRX            ;
		JZ      wrmst           ;

out2:   IN      TTS             ;Check Console Output Statuas
		ANI     TTYTR           ;
		JZ      outstat         ;
		RET


;==================
		END
;==================
