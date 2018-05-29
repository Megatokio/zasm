
	; added Kio 2015-01-03:
	; Zeile 81: LD A,0E --> LD A,0Eh
	; undefined labels:
	; SSC_Init_Flag
	; START

	

;*******************************************************************************************************
; This code is for testing the Serial I/O port SCC chip output
; inits SCC and send an endless stream of chars out of the serial port
; compile to run at 0000h and set N8VEM/S100 Z80 board V2 jumper block P39
; to 3-4 (ROM address line A12 always low)
;*******************************************************************************************************

org 0000h           ; compile to run from 0000h

jp INITSCC          ; jump to code

;*******************************************************************************************************
; PORT ASSIGNMENTS OF THE ZILOG SCC CHIP
;*******************************************************************************************************

BCTL		EQU	0A0H		; CHANNEL B CONTROL
ACTL		EQU	0A1H		; CHANNEL A CONTROL
BDTA		EQU	0A2H		; CHANNEL B DATA
ADTA		EQU	0A3H		; CHANNEL A DATA

;*******************************************************************************************************
; Table of values to initilize the SCC. Note the SCC is set here for 9,600 BAUD
;*******************************************************************************************************

SCCINIT:
	DB	04H			;Point to WR4
	DB	44H			;X16 clock,1 Stop,NP
;
	DB	03H			;Point to WR3
	DB	0C1H		;Enable reciever, Auto Enable, Recieve 8 bits
;	DB	0E1H		;Enable reciever, No Auto Enable, Recieve 8 bits (for CTS bit)
;
	DB	05H			;Point to WR5
	DB	0EAH		;Enable, Transmit 8 bits
;					;Set RTS,DTR, Enable
;
	DB	0BH			;Point to WR11
	DB	56H			;Recieve/transmit clock = BRG
;
	DB	0CH			;Point to WR12
;	DB	40H			;Low Byte 2400 Baud 
;	DB	1EH			;Low Byte 4800 Baud	
	DB	0EH			;Low Byte 9600 Baud
;	DB	06H			;Low byte 19,200 Baud
;	DB	02H			;Low byte 38,400 Baud 
;	DB	00H			;Low byte 76,800 Baud 
;
	DB	0DH			;Point to WR13
	DB	00H			;High byte for Baud
;
	DB	0EH			;Point to WR14
	DB	01H			;Use 4.9152 MHz Clock. Note SD Systems board uses a 2.4576 MHz clock, enable BRG
;
	DB	0FH			;Point to WR15
	DB	00H			;Generate Int with CTS going high


;*******************************************************************************************************
;Zilog Serial SCC board initilization. Will initilize the chip to 9,600 baud.
;*******************************************************************************************************

INITSCC:
	LD	A,ACTL			;Program Channel A
	LD	C,A
	LD	B,0EH			;Byte count for OTIR below
	LD	HL,SCCINIT
	OTIR
;
	LD	A,BCTL			;Program Channel B
	LD	C,A
	LD	B,0EH			;Byte count for OTIR below
	LD	HL,SCCINIT
	OTIR
;
	LD	A,0Eh 			;Set initilization flag for 9,600 baud
	LD	(SSC_Init_Flag),A
	JP	START


;*******************************************************************************************************
; send endless stream of chars to both serial I/O card (SCC chip) serial ports
;*******************************************************************************************************



CHECK:	in a, BCTL			; Are we ready to send a character to SCC?
        and	04H
        jr nz, LOOP         ; SCC ready go to output
        jr CHECK            ; SCC not ready, check again

LOOP:   ld a, 'X'           ; load "X" into a
        out ADTA, a         ; send it to SCC port A
        out	BDTA, a         ; send it to SCC port B
        jr LOOP             ; and keep doing that forever


