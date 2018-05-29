;		
;	///////////////////////////////////////////////	
;		
;	///////////////////////////////////////////////	
;		
;		
;	+++++ MMU REG +++++	
BBR1	EQU	00H
BR1	EQU	01H
BBR2	EQU	02H
BR2	EQU	03H
BBR3	EQU	04H
BR3	EQU	05H
BBR4	EQU	06H
BR4	EQU	07H
;		
;	+++++ DMA +++++	
B_PAR0	EQU	10H
B_SAR0	EQU	11H
B_BCR0	EQU	12H
CR0	EQU	13H
C_PAR0	EQU	10H
C_SAR0	EQU	11H
C_BCR0	EQU	12H
SR0	EQU	13H
B_PAR1	EQU	14H
B_SAR1	EQU	15H
B_BCR1	EQU	16H
CR1	EQU	17H
C_PAR1	EQU	14H
C_SAR1	EQU	15H
C_BCR1	EQU	16H
SR1	EQU	17H
;		
;	+++++ SYSTEM +++++	
SCR0	EQU	1AH
SCR1	EQU	1BH
SCR2	EQU	1CH
SCR3	EQU	1DH
SCR4	EQU	1EH
SCR5	EQU	1FH
;		
;	+++++ CTC +++++	
CTC0	EQU	20H
CTC0C	EQU	21H
CTC1	EQU	22H
CTC1C	EQU	23H
CTC2	EQU	24H
CTC2C	EQU	25H
CTC3	EQU	26H
CTC3C	EQU	27H
;		
;	+++++ SIO +++++	
;	SIO0:ASYNC (STACKER)	
;	SIO1:ASYNC (PC)	
;	SIO2:SYNC	
SIO0RT	EQU	28H
SIO0DT	EQU	2AH
SIO0MD	EQU	2BH
SIO1RT	EQU	2CH
SIO1DT	EQU	2EH
SIO1MD	EQU	2FH
;		
SIO2DT	EQU	30H
SIO2MD	EQU	31H
;		
;	+++++ INT +++++	
LERL	EQU	34H
LERH	EQU	35H
PGRL	EQU	34H
PGRH	EQU	35H
IMRL	EQU	36H
IMRH	EQU	37H
IVR	EQU	37H
ISRL	EQU	34H
ISRH	EQU	35H
;		
;	+++++ PIO +++++	
PIO0	EQU	38H
PIO0C	EQU	39H
PIO1	EQU	3AH
PIO1C	EQU	3BH
PIO2	EQU	3CH
PIO2C	EQU	3DH
PIO3	EQU	3EH
PIO3C	EQU	3FH
;		
;	+++++ HDLC +++++	
WR0	EQU	40H
WR1	EQU	41H
WR2	EQU	42H
WR3	EQU	43H
WR4	EQU	44H
WR5	EQU	45H
WR6	EQU	46H
WR7	EQU	47H
WR8	EQU	48H
WR9	EQU	49H
WR10	EQU	4AH
;		
RR0	EQU	40H
RR1	EQU	41H
RR2	EQU	42H
RR3	EQU	43H
RR4	EQU	44H
RR5	EQU	45H
RR6	EQU	46H
RR7	EQU	47H
RR8	EQU	48H
RR9	EQU	49H
RR10	EQU	4AH
;		
RR2C	EQU	4BH
RR9C	EQU	4CH
;		
;		
;	+++++ SW TABLE +++++	
SW_MODE	EQU	01H
SW_RESET	EQU	02H
SW_SELECT	EQU	04H
SW_PLUS	EQU	08H
SW_MINUS	EQU	10H
SW_START	EQU	20H
SW_STOP	EQU	40H
SW_FEED	EQU	80H
SW_BACK	EQU	08H
;		
;		
;	+++++ DIP_SW +++++	
DIP2	EQU	3AH
DIP3	EQU	3CH
DIP4	EQU	80H
DIP5	EQU	82H
;		
;		
;	+++++ EXTERN I/O +++++	
EIO0	EQU	80H
EIO1	EQU	82H
EIO2	EQU	84H
EIO3	EQU	86H
EIO4	EQU	88H
;		
DISP0	EQU	80H
DISP1	EQU	81H
;		
;		
;	+++++ ASCII CODE +++++	
STX	EQU	02H
ETX	EQU	03H
ACK	EQU	06H
COMMA	EQU	2CH
;		
#target rom
#code rom,0,65536
;		
;**************************************************		
;	***** JUMP TABLE *****	
;		
	ORG	0H
;		
	JP	100H
;		
;	+++++++ VECTOR TABLE ++++++	
;		
;	ORG	0066H
	DEFS	66h - $
	RETN	
;		
;		
;	ORG	80H		; (10000000B)
	DEFs	80h - $
;		
	DEFW	INTCTC2
	DEFW	INTTXRDY1
	DEFW	INTRXRDY1
	DEFW	INTCTC3
	DEFW	INTDMA0
	DEFW	INTDMA1
	DEFW	INTSIO2
	DEFW	INTTXRDY0
	DEFW	INTRXRDY0
	DEFW	INTEXINT
	DEFW	INTTXINT
	DEFW	INTRXINT
	DEFW	INTSPINT
	DEFW	INTCTC0
	DEFW	INTCTC1
	DEFW	INTP20
;		
;		
;**************************************************		
;	***** PROG. BEGIN *****	
;		
;	ORG	100H
	DEFS	100h - $
BEGIN:		
;		
;	++++++ MMU SET +++++	
;	ROM:0000H-CFFFH(00000H-07FFFH)	
;	RAM:D000H-FFFFH(20000H-27FFFH)	
;		
;	BBR?	A1~A0 + B5~B0
;	BR?	A9~A2
;		
;		
	LD	A, 00111111B
	OUT	(BBR1), A
	LD	A, 00000000B
	OUT	(BR1), A
	LD	A, 00111111B
	OUT	(BBR2), A
	LD	A, 00000000B
	OUT	(BR2), A
	LD	A, 00110011B
	OUT	(BBR3), A
	LD	A, 00010011B
	OUT	(BR3), A
	LD	A, 00111111B
	OUT	(BBR4), A
	LD	A, 11110000B
	OUT	(BR4), A
;		
;		
;	++++++ STACK POINTER SET +++++	
;		
	LD	SP, 0FFFEH
;		
;	++++++ SYSTEM REG. SET +++++	
;		
	LD	A, 00000000B
	OUT	(SCR0), A
	LD	A, 00000000B
	OUT	(SCR1), A
	LD	A, 00000000B
	OUT	(SCR2), A
	LD	A, 10011011B
	OUT	(SCR3), A
;;;	LD	A, 10000000B
	LD	A, 00000000B
	OUT	(SCR4), A
	LD	A, 00000000B
	LD	(SCR5), A
;		
;	++++++ RAM CLEAR +++++	
;		
	LD	HL, 0D000H
RAMCLR:		
	XOR	A
	LD	(HL), A
	INC	HL
	LD	A, H
;;;	CP	0DFH
	CP	0FFH
	JP	NZ, RAMCLR
	LD	A, L
	CP	0FFH
	JP	NZ, RAMCLR
;		
;		
;	+++++++ INT SET +++++++	
;		
	LD	A, 0
	LD	I, A
;		
	IM	2
;		
	LD	A, 01100000B
	OUT	(LERH), A
	LD	A, 00001001B
	OUT	(LERL), A
;		
	LD	A,10000000B
	OUT	(IVR), A
;		
	LD	A,00000001B
	OUT	(PGRH), A
	LD	A,00000100B
	OUT	(PGRL), A
;		
	LD	A, 11011110B
	OUT	(IMRH), A
	LD	A, 11110010B
	OUT	(IMRL), A
;		
;		
;	++++++ DMA SET +++++	
;		
;	DMA_CH0,DMA_CH1??	
;		
	LD	A, 11000000B
	OUT	(CR0), A
;		
	LD	A, 00H
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
;		
;		
;	++++++ SIO SET +++++	
;		
;	SIO_CH0 (PC)	

	LD	A, 00111010B
	OUT	(SIO0MD), A
;		
;		

	LD	A, 01H
	OUT	(SIO0RT), A
;		

	LD	A, 11100101B
	OUT	(SIO0MD), A
;		
	CALL	SIO0ON
;		
;		
;	SIO_CH1	(STACKER)

	LD	A, 00111010B
	OUT	(SIO1MD), A
;		
;		

	LD	A, 01H
	OUT	(SIO1RT), A
;		

	LD	A, 11100101B
	OUT	(SIO1MD), A
;		
	CALL	SIO1ON
;		
;	+++++++ TIMER SET +++++++	
;	?IR:CTC1 > CTC0 > CTC3 > CTC2	
;		
;	CTC_CH1	
	LD	A, 00000100B
	OUT	(CTC1C), A
;		
;	CTC_CH0	
	LD	A, 00000100B
	OUT	(CTC0C), A
	IN	A, (CTC0C)
	LD	HL, 5760
	LD	A, L
;		
	OUT	(CTC0), A
	LD	A, H
	OUT	(CTC0), A
;		
;	CTC_CH3	
	LD	A, 00000110B
	OUT	(CTC3C), A
	IN	A, (CTC3C)
	LD	HL, 98
	LD	A, L
	OUT	(CTC3), A
	LD	A, H
	OUT	(CTC3), A
;		
;	CTC_CH2	
	LD	A, 00000101B
	OUT	(CTC2C), A
	IN	A, (CTC2C)
	LD	HL, 614
	LD	A, L
	OUT	(CTC2), A
	LD	A, H
	OUT	(CTC2), A
;		
;		
;	+++++++ PIO SET +++++++	
;	;0:INPUT, 1:OUTPUT	
;		

	LD	A, 00000000B
	LD	(BPIO0), A
	OUT	(PIO0), A
;		
;	PIO1: DIP_SW(SW2)	
	LD	A, 00000000B
	OUT	(PIO1C), A
;		
;	PIO2: DIP_SW(SW3)	
	LD	A, 00000000B
	OUT	(PIO2C), A
;		
;	PIO3: SIO1 & SW_BACK & BZ & LED_LODER	
	LD	A, 10010111B
	OUT	(PIO3C), A
	LD	A, 00000000B
	LD	(BPIO3), A
	OUT	(PIO3), A
;		
;		
;	+++++++ EIO SET +++++++	
;		
;	;EIO0: DIP_SW(SW4)	
;		
;	;EIO1: DIO_SW(SW5)	
;		
;	;EIO2: MOTOR_OUT & SENSOR IN	
	LD	A, 11111111B
	LD	(BEIO2), A
	OUT	(EIO2), A
;		
;	;EIO3: LED OUT	
	LD	A, 00000000B
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	;EIO4: SW IN	
;		
;		
;	/////////////////////////////////////	
;		DATA INIT.
;	/////////////////////////////////////	
;		

;		
	LD	HL, 1685
	LD	(XSPD1), HL
	LD	HL, 16384
	LD	(XSPD2), HL
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
;		
	LD	HL, 492
	LD	(PSPD1), HL
	LD	HL, 589
	LD	(PSPD2), HL
	LD	HL, 983
	LD	(PSPD3), HL
	LD	HL, (PSPD1)
	LD	(M2SPD), HL
;		
;		
	LD	HL, 3
	LD	(RDYTIMER0), HL
;		
	LD	A, 0
	LD	(BNFLG), A
;		
	LD	HL, 13
	LD	(HPHOSEI), HL
;		
	LD	HL, 2000
	LD	(VOLMAX), HL
	LD	HL, 2
	LD	(VOLMIN), HL
;		
	LD	HL, 0
	LD	(PWAIT1), HL
	LD	HL ,10
	LD	(PWAIT2), HL
	LD	HL, 100
	LD	(PWAIT3), HL
	LD	HL ,100
	LD	(PWAIT4), HL
;		
	LD	A, 0
	LD	(RDYFLG), A
	LD	(STASEQ), A
	LD	(STOPFLG), A
;		
	LD	HL, 0
	LD	(NOW_WELL), HL
;		
	LD	A, 0
	LD	(PCFLG), A
	LD	(CMDSFLG), A
	LD	(CMDAFLG), A
;		
;		
;	+++++ BACKUP DATA INIT +++++	
;		
	CALL	ROM2RAM
;		
	LD	A, (BKUPFLG)
	CP	0AAH
	CALL	NZ, BKUPRES
;		
	EI	
;		
;	====== AGING MODE ======	
;	IF MODE + RESET ON ENTER AGING MODE	
;		
	IN	A, (EIO4)
	CP	00000011B
	JP	Z, AGINGMOD
;	========================	
;	====== PUMP SPEED SET MODE ======	
;	IF FEED + RETURN ON ENTER SPEED SET MODE	
;		
	IN	A, (EIO4)
	CP	10000000B
	JP	Z, PSPDMOD_E1
	JP	PSPDMOD_E2
PSPDMOD_E1:		
	IN	A, (PIO3)
	AND	00001000B
	CP	00001000B
	JP	Z, PSPDMOD
PSPDMOD_E2:		
;	========================	
;	====== POSITION HOSEI SET MODE ======	
;	IF START + STOP ON ENTER POSITION HOSEI MODE	
;		
	IN	A, (EIO4)
	CP	01100000B
	JP	Z, POSMOD
;	========================	
;	====== DEBUG MODE ======	
;	IF DIP_SW0-7 ON ENTER DEBUG MODE	
;		
	IN	A, (DIP2)
	AND	11110000B
	CP	10000000B
	JP	Z, DEBUGMOD
;	========================	
;	====== STACKER MANUAL MODE ======	
;	IF DOP_SW0-6 ON (STACKER) MANUAL MODE	
;		
;;	IN	A, (DIP2)
;;	AND	11110000B
;;	CP	01000000B
;;	JP	Z, MANMOD
;	========================	
;		
;		
	CALL	CHPLATE
;		
	JP	MAIN
;		
;	+++++++ MAIN LOOP +++++++	
;		
;	ORG	500H
	DEFS	500h - $
;		
MAIN:		
;	;???????(VER)	
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 11101110B
	OUT	(DISP0), A
	LD	A, 11101101B
	OUT	(DISP0), A
	LD	A, 11010111B
	OUT	(DISP0), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
	LD	HL, 1000
	LD	(DELTGT), HL
	CALL	DELAY
;		
;		
;;;	JP	TEST
;		
;		
MAIN0:		
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
;		
	IN	A, (SIO1MD)
	AND	01000000B
	JP	Z, MAIN1
;		
;		
	LD	A, (MODEFLG)
	CP	0
	JP	Z, LVOL
	CP	1
	JP	Z, LPAT
	CP	2
	JP	Z, LPROG
	CP	3
	JP	Z, LVOL
	CP	4
	JP	Z, LPAT
	CP	5
	JP	Z, LPROG
;		
MAIN1:		
;		
	CALL	M1GEN
;		
MAIN2:		
	LD	A, (MODEFLG)
	CP	0
	JP	Z, VOL
	CP	1
	JP	Z, PAT
	CP	2
	JP	Z, PROG
	CP	3
	JP	Z, VOL
	CP	4
	JP	Z, PAT
	CP	5
	JP	Z, PROG
;		
;		
;		
;////////////////////////////////////////		
;	TEST MODE	
;////////////////////////////////////////		
;/*TEST*/		
TEST:		
	LD	A, 0
	LD	(MODEFLG), A
	CALL	RAM2ROMF
;		
	LD	A, (BPIO0)
	SET	0, A
	SET	1, A
	LD	(BPIO0), A
	OUT	(PIO0), A
;		
	LD	A, (BEIO3)
	SET	0, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	LD	A, (BPIO3)
	RES	0, A
	LD	(BPIO3), A
	OUT	(PIO3), A
;		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 11111111B
	OUT	(DISP0), A
	LD	A, 11111111B
	OUT	(DISP0), A
	LD	A, 11111111B
	OUT	(DISP0), A
	LD	A, 11111111B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
;		
TESTLP:		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'M'
	JP	Z, TEST_M
	CP	'R'
	JP	Z, TEST_R
	CP	'C'
	JP	Z, TEST_C
	CP	'U'
	JP	Z, TEST_U
	CP	'D'
	JP	Z, TEST_D
	CP	'G'
	JP	Z, TEST_G
	CP	'S'
	JP	Z, TEST_S
	CP	'F'
	JP	Z, TEST_F
	CP	'B'
	JP	Z, TEST_B
;		
	JP	TESTLP
;		
;~~~~~		
TEST_M:		
	JP	TESTLP
;~~~~~		
TEST_R:		
	CALL	M1GEN
;		
	JP	TESTLP
;		
;~~~~~		
TEST_C:		
;		
	JP	TESTLP
;		
;~~~~~		
TEST_U:		
;		
	JP	TESTLP
;		
;~~~~~		
TEST_D:		
;		
	JP	TESTLP
;		
;~~~~~		
TEST_G:		
	CALL	M1EP
;		
	LD	HL, 500
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	M1HP
;		
	LD	HL, 500
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	TEST_G
;		
	JP	TESTLP
;		
;~~~~~		
TEST_S:		
	JP	TESTLP
;		
;~~~~~		
TEST_F:		
;		
	JP	TESTLP
;~~~~~		
TEST_B:		
;		
	JP	TESTLP
;~~~~~		
;~~~~~		
;~~~~~		
;		
;/*END TEST*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SIO0(PC) ON	
;		
;	RXRDY0, TXRDY0 ENABLE	
;		
;////////////////////////////////////////		
;/*SIO0ON*/		
SIO0ON:		
;???????		
	LD	A, 01000000B
	OUT	(SIO0MD), A
;		
;???????		
	LD	A, 00111010B
	OUT	(SIO0MD), A
;		
;		
;????????A		
	LD	A, 00100101B
	OUT	(SIO0MD), A
;		
	RET	
;		
;/*END SIO0ON*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SIO0(PC) OFF	
;		
;	RXRDY0, TXRDY0 DISABLE	
;		
;////////////////////////////////////////		
;/*SIO0OF*/		
SIO0OF:		
;????????A		
	LD	A, 00000000B
	OUT	(SIO0MD), A
;		
	RET	
;		
;/*END SIO0OF*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SIO1(STACKER) ON	
;		
;	RXRDY1, TXRDY1 ENABLE	
;		
;////////////////////////////////////////		
;/*SIO1ON*/		
SIO1ON:		

	LD	A, 01000000B
	OUT	(SIO1MD), A
;		

	LD	A, 00111010B
	OUT	(SIO1MD), A
;		
;		

	LD	A, 00100101B
	OUT	(SIO1MD), A
;	
	RET
;	
;/*END SIO1ON*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	SIO1(STACKER) OFF
;	
;	RXRDY1, TXRDY1 DISABLE
;	
;////////////////////////////////////////	
;/*SIO1OF*/	
SIO1OF:	

	LD	A, 00000000B
	OUT	(SIO1MD), A
;		
	RET	
;		
;/*END SIO1OF*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	PC ?????	
;////////////////////////////////////////		
;/*PC*/		
PC:		
	LD	A, (BPIO0)
	RES	0, A
	RES	1, A
	LD	(BPIO0), A
	OUT	(PIO0), A
;		
	LD	A, (BEIO3)
	RES	0, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 11101110B
	OUT	(DISP0), A
	LD	A, 11001011B
	OUT	(DISP0), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		

PCLP:		
	LD	A, (FEEDFLG)
	AND	A
	JP	Z, PCLP1
;		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
;		
PCLP1:		
;==========;PLATE_SW CHANGE -> ALARM1-3		


	LD	A, (CMD0FLG)
	AND	A
	JP	NZ, PCLP2
;		
	CALL	CHPLATE
	JP	PCLP3
;		
PCLP2:		
	LD	A, 3
	LD	(ALM1FLG), A
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	BC
	LD	A, (PLATEFLG)
	XOR	B
	CALL	NZ, ALARM1
;===========		
;		
PCLP3:		
;==========COMMAND S FLG ??		
	LD	A, (CMDSFLG)
	AND	A
	CALL	NZ, STOP3
;==========		
	LD	A, (CMD0FLG)
	AND	A
	JP	Z, PCLP
;		
	CALL	FETCHPC
;		
	JP	PCLP
;		
;		
;/*END PC*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	FETCHPC0	
;		
;		
;////////////////////////////////////////		
;/*FETCHPC0*/		
FETCHPC0:		
	LD	HL, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	HL, DE
	LD	A, (HL)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	CP	'O'
	JP	NZ, FETCHPC0_ERR
;		
;		
	CALL	OPENRET
;		
	LD	A, 1
	LD	(PCFLG), A
;		
	POP	AF
	JP	PC
;		
;		
FETCHPC0_ERR:		
	LD	HL, STR_E99
	LD	DE, SOSIN0BUF
	LD	BC, 100
	LDIR	
	CALL	SOSIN0
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	RET	
;		
;/*END FETCHPC0*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	OPEN RETERN	
;		
;	????????????	
;		
;////////////////////////////////////////		
;/*OPENRET*/		
OPENRET:		
;		

	LD	IX, SOSIN0BUF
	LD	DE, 0
	ADD	IX, DE
	CALL	QVER
;		

	LD	A, COMMA
	LD	(SOSIN0BUF+3), A
;		

	LD	IX, SOSIN0BUF
	LD	DE, 4
	ADD	IX, DE
	CALL	QA
;		

	LD	A, COMMA
	LD	(SOSIN0BUF+6), A
;		

	LD	IX, SOSIN0BUF
	LD	DE, 7
	ADD	IX, DE
	CALL	QB
;		

	LD	A, COMMA
	LD	(SOSIN0BUF+9), A
;		
;96/384???		
	LD	IX, SOSIN0BUF
	LD	DE, 10
	ADD	IX, DE
	CALL	QC
;		
;???		
	LD	A, COMMA
	LD	(SOSIN0BUF+12), A
;		
;COVER???		
	LD	IX, SOSIN0BUF
	LD	DE, 13
	ADD	IX, DE
	CALL	QD
;		
;???		
	LD	A, COMMA
	LD	(SOSIN0BUF+15), A
;		
;XW??±???		
	LD	IX, SOSIN0BUF
	LD	DE, 16
	ADD	IX, DE
	CALL	QX
;		
;		
	CALL	SOSIN0
;		
;		
	RET	
;		
;/*END OPENRET*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	FETCH (PC)	
;		
;		
;////////////////////////////////////////		
;/*FETCHPC*/		
FETCHPC:		
;		

	LD	A, 0
	LD	(STCONFLG), A
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	NZ, FETCHPC_STCON1
	JP	FETCHPC_STCON2
;		
FETCHPC_STCON1:		
	LD	A, 1
	LD	(STCONFLG), A
FETCHPC_STCON2:		
;		
;		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
	LD	A, (IX+0)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		
;		
;		
;FEEDFLG == 1 ??		
	PUSH	AF
	LD	A, (FEEDFLG)
	AND	A
	JP	NZ, FETCHPC2
;		
;??????		
	POP	AF
	CP	'O'
	JP	Z, FETCHPC_O
	CP	'C'
	JP	Z, FETCHPC_C
	CP	'R'
	JP	Z, FETCHPC_R
	CP	'X'
	JP	Z, FETCHPC_X
	CP	'P'
	JP	Z, FETCHPC_P
	CP	'S'
	JP	Z, FETCHPC_S
	CP	'A'
	JP	Z, FETCHPC_A
	CP	'Q'
	JP	Z, FETCHPC_Q
	CP	'W'
	JP	Z, FETCHPC_W
	CP	'L'
	JP	Z, FETCHPC_L
	CP	ETX
	JP	Z, FETCHPC_EXT
;		
	JP	FETCHPC_ERR
;		

FETCHPC2:		
	POP	AF
	CP	'P'
	JP	Z, FETCHPC_P
	CP	'W'
	JP	Z, FETCHPC_W
	CP	ETX
	JP	Z, FETCHPC_EXT
	JP	FETCHPC_ERR
;		
;~~~~~		
FETCHPC_O:		
	CALL	OPENRET
;		
	RET	
;		
;~~~~~		
FETCHPC_C:		
;		
	LD	A, 0
	LD	(PCFLG), A
;		
	CALL	SOSIN0OK
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	POP	AF
	JP	MAIN2
;		
;~~~~~		
FETCHPC_R:		

	LD	A, (STCONFLG)
	AND	A
	JP	NZ, FETCHPC_R2
;		
FETCHPC_R1:		;????????
	CALL	M1GEN
;		
	JP	FETCHPC_REND
;		
;		
FETCHPC_R2:		;???????
;;		

;;;		
	JP	FETCHPC_REND
;		
FETCHPC_REND:		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	CALL	SOSIN0R
;		
	RET	
;		
;~~~~~		
FETCHPC_X:		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
	LD	A, (IX+0)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	CP	'S'
	JP	Z, FETCHPC_XS
	CP	'0'
	JP	Z, FETCHPC_X0
	CP	'1'
	JP	Z, FETCHPC_X1
	CP	'2'
	JP	Z, FETCHPC_X2
	CP	'W'
	JP	Z, FETCHPC_XW
	JP	FETCHPC_ERR
;		
;~~~~~		
FETCHPC_XS:		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (IX+0)
	LD	(K3_IN4), A
	LD	A, (IX+1)
	LD	(K3_IN3), A
	LD	A, (IX+2)
	LD	(K3_IN2), A
	LD	A, (IX+3)
	LD	(K3_IN1), A
	LD	A, (IX+4)
	LD	(K3_IN0), A
;		
	CALL	ASC2HEX
	LD	HL, (K3_OUT0)
;		
;==========???( 400 - 20000 )		
	LD	HL, 399
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	P, FETCHPC_ERR
;		
	LD	HL, 20000
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	M, FETCHPC_ERR
;		
;==========		
;		
;		

	LD	A, (STCONFLG)
	AND	A
	JP	NZ, FETCHPC_XS2
;		
;		

	LD	HL, (K3_OUT0)
	LD	(M1SPD), HL
;		
	RET	
;		
FETCHPC_XS2:		; This label was missing from source, how did it assemble?
	RET	
;		
;~~~~~		
FETCHPC_X0:		

	LD	A, (STCONFLG)
	AND	A
	JP	NZ, FETCHPC_X02
;		
FETCHPC_X01:		
	CALL	M1GEN
;		
	RET	
;		
;		
FETCHPC_X02:		
	RET	
;		
;~~~~~		
FETCHPC_X1:		

	LD	A, (STCONFLG)
	AND	A
	JP	NZ, FETCHPC_X12
;		
FETCHPC_X11:		
	CALL	M1EP
;		
	RET	
;		
FETCHPC_X12:		
	RET	
;		
;		
;~~~~~		
FETCHPC_X2:		
;????????		
	LD	A, (STCONFLG)
	AND	A
	JP	NZ, FETCHPC_X22
;		
FETCHPC_X21:		
	CALL	M1DP
;		
	RET	
;		
FETCHPC_X22:		
	RET	
;		
;		
;		
;~~~~~		
FETCHPC_XW:		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (IX+0)
	LD	(K3_IN1), A
	LD	A, (IX+1)
	LD	(K3_IN0), A
	LD	A, '0'
	LD	(K3_IN2), A
	LD	(K3_IN3), A
	LD	(K3_IN4), A
;		
	CALL	ASC2HEX
	LD	HL, (K3_OUT0)
;		
;==========		

	LD	HL, 0
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	P, FETCHPC_ERR
	JP	Z, FETCHPC_ERR
;		
	IN	A, (EIO2)
	BIT	3, A
	JP	Z, FETCHPC_XW1		;384WELL -> JMP
;				

	LD	HL, 12		
	LD	DE, (K3_OUT0) 		
	AND	A		
	SBC	HL, DE		
	JP	M, FETCHPC_ERR		
;				

FETCHPC_XW1:				
	LD	HL, 24		
	LD	DE, (K3_OUT0) 		
	AND	A		
	SBC	HL, DE		
	JP	M, FETCHPC_ERR		
;		
;==========		
;		
	LD	HL, (K3_OUT0)
	LD	(WELL_SET), HL
;		
	LD	A, (IX+2)
	CP	'+'
	JP	Z, FETCHPC_XW_P
	CP	'-'
	JP	Z, FETCHPC_XW_M
	JP	FETCHPC_XW_N
;		
;		
;~~~~~		
FETCHPC_XW_N:		
	LD	HL, 0
	LD	(WELL_ADR), HL
;		
	CALL	M1WELL
;		
	RET	
;		
;~~~~~		
FETCHPC_XW_P:		

	LD	DE, (FETCHPCCNT)
	INC	DE
	LD	(FETCHPCCNT), DE
;		
;3??????(???)		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (IX+0)
	LD	(K3_IN2), A
	LD	A, (IX+1)
	LD	(K3_IN1), A
	LD	A, (IX+2)
	LD	(K3_IN0), A
	LD	A, '0'
	LD	(K3_IN3), A
	LD	A, '0'
	LD	(K3_IN4), A
;		
	CALL	ASC2HEX
	LD	HL, (K3_OUT0)
;		

	LD	HL, -1
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	P, FETCHPC_ERR
;		
	LD	HL, 240
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0)
	LD	(WELL_ADR), HL
;		
	CALL	M1WELL
;		
	RET	
;		
;~~~~~		
FETCHPC_XW_M:		

	LD	DE, (FETCHPCCNT)
	INC	DE
	LD	(FETCHPCCNT), DE
;		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (IX+0)
	LD	(K3_IN2), A
	LD	A, (IX+1)
	LD	(K3_IN1), A
	LD	A, (IX+2)
	LD	(K3_IN0), A
	LD	A, '0'
	LD	(K3_IN3), A
	LD	A, '0'
	LD	(K3_IN4), A
;		
	CALL	ASC2HEX
	LD	DE, (K3_OUT0)
;		
	LD	HL, 0
	AND	A
	SBC	HL, DE
	LD	(K3_OUT0), HL
;		
;==========		
	LD	HL, 240
	LD	DE, (K3_OUT0)
	AND	A
	ADD	HL, DE
	JP	M, FETCHPC_ERR
;		
	LD	HL, 0
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0)
	LD	(WELL_ADR), HL
;		
	CALL	M1WELL
;		
	RET	
;		
;~~~~~		
FETCHPC_P:		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
	LD	A, (IX+0)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		

	PUSH	AF
	LD	A, (FEEDFLG)
	AND	A
	JP	NZ, FETCHPC_PF
;		
	POP	AF
	CP	'S'
	JP	Z, FETCHPC_PS
	CP	'0'
	JP	Z, FETCHPC_P0
	CP	'1'
	JP	Z, FETCHPC_P1
	CP	'2'
	JP	Z, FETCHPC_P2
	CP	'3'		
	JP	Z, FETCHPC_P3		
	CP	'+'		
	JP	Z, FETCHPC_P_P		
	CP	'-'		
	JP	Z, FETCHPC_P_M		
;				
FETCHPC_PF:				
	POP	AF		;(PUSH AF)
	CP	'3'		
	JP	Z, FETCHPC_P3		
	JP	FETCHPC_ERR		
;				
;				
;~~~~~				
FETCHPC_PS:				
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
;		
	LD	A, (IX+0)
	LD	(K3_IN4), A
	LD	A, (IX+1)
	LD	(K3_IN3), A
	LD	A, (IX+2)
	LD	(K3_IN2), A
	LD	A, (IX+3)
	LD	(K3_IN1), A
	LD	A, (IX+4)
	LD	(K3_IN0), A
;		
	CALL	ASC2HEX
	LD	HL, (K3_OUT0)
;		

	LD	HL, 399
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	P, FETCHPC_ERR
;		
	LD	HL, 20000
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0)
	LD	(M2SPD), HL
;		
	RET	
;		
;~~~~~		
FETCHPC_P0:		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
	CALL	M2GEN
;		
	RET	
;		
;~~~~~		
FETCHPC_P1:		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
	LD	A, 0
	LD	(M2DIR), A
	CALL	M2START
;		
	LD	A, 1
	LD	(FEEDFLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_P2:		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
	LD	A, 1
	LD	(M2DIR), A
	CALL	M2START
;		
	LD	A, 1
	LD	(FEEDFLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_P3:		
	LD	A, (FEEDFLG)
	AND	A
	RET	Z
;		
	LD	A, 0
	LD	(M2FLG), A
;		
	LD	A, 0
	LD	(FEEDFLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_P_P:		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
;		
	LD	A, (IX+0)
	LD	(K3_IN4), A
	LD	A, (IX+1)
	LD	(K3_IN3), A
	LD	A, (IX+2)
	LD	(K3_IN2), A
	LD	A, (IX+3)
	LD	(K3_IN1), A
	LD	A, (IX+4)
	LD	(K3_IN0), A
;		
	CALL	ASC2HEX
;		

	LD	A, (K3_OUT0+2)
	SUB	2
	JP	P, FETCHPC_ERR
;		
	LD	HL, 0869FH
	LD	DE, (K3_OUT0+0)
	AND	A
	SBC	HL, DE
;		
	LD	A, (K3_OUT0+2)
	LD	E, A
	LD	A, 01H
	SBC	A, E
;		
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0+0)
	LD	(M2TGT+0), HL
	LD	A, (K3_OUT2)
	LD	(M2TGT+2), A
;		
	LD	A, 0
	LD	(M2DIR), A
	CALL	M2MOVE
;		
	RET	
;		
;~~~~~		
FETCHPC_P_M:		

	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	LD	A, (FEEDFLG)
	AND	A
	RET	NZ
;		
;		
	LD	A, (IX+0)
	LD	(K3_IN4), A
	LD	A, (IX+1)
	LD	(K3_IN3), A
	LD	A, (IX+2)
	LD	(K3_IN2), A
	LD	A, (IX+3)
	LD	(K3_IN1), A
	LD	A, (IX+4)
	LD	(K3_IN0), A
;		
	CALL	ASC2HEX
;		

	LD	A, (K3_OUT0+2)
	SUB	2
	JP	P, FETCHPC_ERR
;		
	LD	HL, 0869FH
	LD	DE, (K3_OUT0+0)
	AND	A
	SBC	HL, DE
;		
	LD	A, (K3_OUT0+2)
	LD	E, A
	LD	A, 01H
	SBC	A, E
;		
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0+0)
	LD	(M2TGT+0), HL
	LD	A, (K3_OUT2)
	LD	(M2TGT+2), A
;		
	LD	A, 1
	LD	(M2DIR), A
	CALL	M2MOVE
;		
	RET	
;		
;~~~~~		
FETCHPC_S:		
	LD	A, 1
	LD	(STOPFLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_A:		
	LD	A, 0
	LD	(STOPFLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_Q:		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
	LD	A, (IX+0)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	CP	'A'
	JP	Z, FETCHPC_QA
	CP	'B'
	JP	Z, FETCHPC_QB
	CP	'C'
	JP	Z, FETCHPC_QC
	CP	'D'
	JP	Z, FETCHPC_QD
	CP	'X'
	JP	Z, FETCHPC_QX
	JP	FETCHPC_ERR
;		
;~~~~~		
FETCHPC_QA:		
	LD	IX, SOSIN0BUF
	CALL	QA
	CALL	SOSIN0
;		
	RET	
;		
;~~~~~		
FETCHPC_QB:		
	LD	IX, SOSIN0BUF
	CALL	QB
	CALL	SOSIN0
;		
	RET	
;		
;~~~~~		
FETCHPC_QC:		
	LD	IX, SOSIN0BUF
	CALL	QC
	CALL	SOSIN0
;		
	RET	
;		
;~~~~~		
FETCHPC_QD:		
	LD	IX, SOSIN0BUF
	CALL	QD
	CALL	SOSIN0
;		
	RET	
;		
;~~~~~		
FETCHPC_QX:		
	LD	IX, SOSIN0BUF
	CALL	QX
	CALL	SOSIN0
;		
	RET	
;		
;~~~~~				
FETCHPC_W:				
	LD	IX, CMD0BUF		
	LD	DE, (FETCHPCCNT)		
	ADD	IX, DE		;
;				
	INC	DE		
	INC	DE		
	INC	DE		
	LD	(FETCHPCCNT), DE		
;				
	LD	A, (IX+0)		
	LD	(K3_IN2), A		
	LD	A, (IX+1)		
	LD	(K3_IN1), A		
	LD	A, (IX+2)		
	LD	(K3_IN0), A
	LD	A, '0'
	LD	(K3_IN3), A
	LD	(K3_IN4), A
	CALL	ASC2HEX
;		

	LD	HL, -1
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	P, FETCHPC_ERR
;		
	LD	HL, 999
	LD	DE, (K3_OUT0)
	AND	A
	SBC	HL, DE
	JP	M, FETCHPC_ERR
;		
;==========		
;		
	LD	HL, (K3_OUT0)
	LD	DE, 10
	CALL	HLXDE
	LD	(DELTGT), HL
	CALL	DELAY
;		
	RET	
;		
;~~~~~		
FETCHPC_L:		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
	LD	A, (IX+0)
;		
	INC	DE
	LD	(FETCHPCCNT), DE
;		
	CP	'P'
	JP	Z, FETCHPC_LP
	CP	'L'
	JP	Z, FETCHPC_LL
	CP	'U'
	JP	Z, FETCHPC_LU
	JP	FETCHPC_ERR
;		
;~~~~~		
FETCHPC_LP:		
	LD	IX, CMD0BUF
	LD	DE, (FETCHPCCNT)
	ADD	IX, DE
;		
	INC	DE
	INC	DE
	INC	DE
	LD	(FETCHPCCNT), DE
;		
;?????????		
;		
	LD	A, 'L'
	LD	(SOSIN0BUF+0), A
	LD	A, 'P'
	LD	(SOSIN0BUF+1), A
	LD	A, '@'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
FETCHPC_LL:		
	LD	A, 'L'
	LD	(SOSIN0BUF+0), A
	LD	A, 'L'
	LD	(SOSIN0BUF+1), A
	LD	A, '@'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
FETCHPC_LU:		
	LD	A, 'L'
	LD	(SOSIN0BUF+0), A
	LD	A, 'U'
	LD	(SOSIN0BUF+1), A
	LD	A, '@'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
FETCHPC_EXT:		
;???????		
	CALL	SOSIN0OK
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	RET	
;		
;~~~~~		
FETCHPC_ERR:		
	LD	HL, STR_E99
	LD	DE, SOSIN0BUF
	LD	BC, 100
	LDIR	
	CALL	SOSIN0
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	RET
;	
;~~~~~	
;	

;	
;/*END FETCHPC*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	SOSIN0
;	
;////////////////////////////////////////	
;/*SOSIN0*/	
SOSIN0:	
	LD	A, 0
	LD	(SOSIN0NUM), A
SOSIN0_1:		
	LD	HL, 0
	LD	(SOSIN0CNT), HL
;		
	CALL	SOSIN0RDY
;		
	LD	A, STX
	OUT	(SIO0DT), A
;		

SOSIN0_DT:		
	LD	HL, SOSIN0BUF
	LD	DE, (SOSIN0CNT)
	ADD	HL, DE
	LD	A, (HL)
;		
	INC	DE
	LD	(SOSIN0CNT), DE
;		
	CP	'@'
	JP	Z, SOSIN0_EXT
;		
	CALL	SOSIN0RDY
	OUT	(SIO0DT), A
;		
	JP	SOSIN0_DT
;		
SOSIN0_EXT:		
	CALL	SOSIN0RDY
	LD	A, ETX
	OUT	(SIO0DT),A
;		
;		

;;;	RET	
;		
;		
	LD	HL, 2000
	LD	(DELTGT), HL
	CALL	OPENDELAY

SOSIN0_ACKLP:		
	LD	A, (FEEDFLG)
	AND	A
	JP	Z, SOSIN0_ACKLP1 

; SOSINOK ??		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
SOSIN0_ACKLP1:		
	LD	HL, (DELTGT)
	LD	A, H
	OR	L
	JP	Z, SOSIN0_NOACK
;		
	LD	A, (RX0FLG)
	AND	A
	JP	Z, SOSIN0_ACKLP
;		
	LD	A, (RX0BUF)
	CP	ACK
	JP	Z, SOSIN0_END
;		

SOSIN0_NOACK:		
	LD	A, 0
	LD	(RX0FLG), A
	LD	(DELFLG), A
;		
	LD	A, (SOSIN0NUM)
	CP	2
	JP	Z, SOSIN0_ERR
;		
	INC	A
	LD	(SOSIN0NUM), A
;		
	JP	SOSIN0_1
;		
SOSIN0_END:		
	LD	A, 0
	LD	(RX0FLG), A
;		
	AND	A
	RET	
;		
SOSIN0_ERR:		
	LD	A, 0
	LD	(CMD0FLG), A
	SCF
	RET
;	
;	
;/*END SOSIN0*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	SOSIN0OK
;	

;	
;////////////////////////////////////////	
;/*SOSIN0OK*/	
SOSIN0OK:	
	LD	HL, STR_OK
	LD	DE, SOSIN0BUF
	LD	BC, 100
	LDIR	
;		
	CALL	SOSIN0
;		
	RET	
;		
;/*END SOSIN0OK*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SOSIN0ACK	
;		
;	ACK???	
;		
;////////////////////////////////////////		
;/*SOSIN0ACK*/		
SOSIN0ACK:		
	CALL	SOSIN0RDY
	LD	A, STX
	OUT	(SIO0DT), A
;		
	CALL	SOSIN0RDY
	LD	A, ACK
	OUT	(SIO0DT), A
;		
	CALL	SOSIN0RDY
	LD	A, ETX
	OUT	(SIO0DT),A
;		
	RET	
;		
;/*END SOSIN0ACK*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SOSIN0R	
;		
;		
;		
;////////////////////////////////////////		
;/*SOSIN0R*/		
SOSIN0R:		
	CALL	SOSIN0RDY
	LD	A, STX
	OUT	(SIO0DT), A
;		
	CALL	SOSIN0RDY
	LD	A, 'R'
	OUT	(SIO0DT), A
;		
	CALL	SOSIN0RDY
	LD	A, ETX
	OUT	(SIO0DT),A
;		
	RET	
;		
;/*END SOSIN0R*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SOSIN0RDY	
;		
;////////////////////////////////////////		
;/*SOSIN0RDY*/		
SOSIN0RDY:		
	PUSH	AF
;		
SOSIN0RDYLP:		
	IN	A, (SIO0MD)
	AND	00000001B
	JP	Z, SOSIN0RDYLP
;		
	POP	AF
;		
	RET
;	
;/*END SOSOIN0RDY*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	
;////////////////////////////////////////	
;/**/	
;	
;/*END */	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	PC COMMAND R	
;		
;////////////////////////////////////////		
;/*PCMDR*/		
PCMDR:		
	CALL	M1GEN
;		
	RET	
;		
;/*END PCMDR*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;		
;////////////////////////////////////////		
;/**/		
;		
;/*END */		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	CHANGE MOTOR SPEED	
;		
;////////////////////////////////////////		
;/*CHMSPD*/		
CHMSPD:		
	LD	HL, (MSPD)
;		
	IN	A, (CTC3C)
	LD	A, L
	OUT	(CTC3), A
	LD	A, H
	OUT	(CTC3), A
;		
	RET	
;		
;		
;/*END CHMSPD*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	MOTOR1 ????	
;		
;////////////////////////////////////////		
;/*M1SET*/		
M1SET:		

	LD	HL, (ZAHYO_SET1)
;==========		
;		
	LD	HL, (ZAHYO_SET1)
	LD	DE, (NOW_X)
	AND	A
	SBC	HL, DE
	JP	Z, M1SET_Z
	JP	P, M1SET_P
	JP	M1SET_M
;		
;~~~~~		
M1SET_Z:		
	SCF	
	RET	
;		
;~~~~~		
M1SET_P:		
	LD	A, 0
	LD	(M1DIR), A
	LD	HL, (ZAHYO_SET1)
	PUSH	HL
	LD	DE, (NOW_X)
	AND	A
	SBC	HL, DE
	LD	(M1TGT), HL
;		
	POP	HL
	LD	(NOW_X), HL
;		
	AND	A
	RET	
;		
;~~~~~		
M1SET_M:		
	LD	A, 1
	LD	(M1DIR), A
	LD	HL, (NOW_X)
	LD	DE, (ZAHYO_SET1)
	AND	A
	SBC	HL, DE
	LD	(M1TGT), HL
;		
	LD	(NOW_X), DE
;		
	AND	A
	RET	
;		
;~~~~~		
;~~~~~		
;		
;/*END M1SET*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	MOROT1 MOVE	
;		
;		M1DIR(0:HIDARI, 1:MIGI)
;		M1TGT
;		M1MODE
;		
;////////////////////////////////////////		
;/*M1MOVE*/		
M1MOVE:		

	LD	A, (M1DIR)
	AND	A
	JP	NZ, M1MOVECW
;		
	LD	A, (BEIO2)
	RES	1, A
	LD	(BEIO2), A
	OUT	(EIO2), A
	JP	M1MOVECCWEX
;		
M1MOVECW:		
	LD	A, (BEIO2)
	SET	1, A
	LD	(BEIO2), A
	OUT	(EIO2), A
;		
M1MOVECCWEX:		
;		
;		

	LD	A, (M1MODE)
	AND	A
	JP	NZ, M1MOVEACC
;		
M1MOVEFIX:		
	LD	A, 0
	LD	(M1MODE), A
;		
	LD	HL, (M1SPD)
	LD	(MSPD), HL
	CALL	CHMSPD
;		
	LD	HL, 0
	LD	(M1ACCNUM), HL
;		
	JP	M1MOVE1
;		
M1MOVEACC:		

	LD	HL, (M1SPD)
	LD	DE, (ACCDATA)
	AND	A
	SBC	HL, DE
	JP	P, M1MOVEFIX
	JP	Z, M1MOVEFIX		
;				
	LD	(MSPD), DE		
	CALL	CHMSPD		
;				
	LD	HL, 1		;
	LD	(M1ACCNUM), HL		
;				
	LD	HL, (M1TGT)		
	SRL	H		
	RR	L		
	INC	HL		
	LD	(M1HTGT), HL		
;				
;				
M1MOVE1:				
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(M1FLG), A
;		
M1MOVELP:		

;==========		
;		
	LD	HL, (M1TGT)
	LD	A, H
	OR	L
	JP	NZ, M1MOVELP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	RET	
;		
;/*END M1MOVE*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	M1START	
;		

;		
;	??:	M1DIR(0:HIDARI,1:MIGI)
;		M1SPD
;		M1MODE
;		
;////////////////////////////////////////		
;/*M1START*/		
M1START:		

	LD	A, (M1DIR)
	AND	A
	JP	NZ, M1STARTCW
;		
	LD	A, (BEIO2)
	RES	1, A
	LD	(BEIO2), A
	OUT	(EIO2), A
	JP	M1STARTCCWEX
;		
M1STARTCW:		
	LD	A, (BEIO2)
	SET	1, A
	LD	(BEIO2), A
	OUT	(EIO2), A
;		
M1STARTCCWEX:		
;		
;		

	LD	A, (M1MODE)
	AND	A
	JP	NZ, M1STARTACC
;		
M1STARTFIX:		
	LD	A, 0
	LD	(M1MODE), A
;		
	LD	HL, (M1SPD)
	LD	(MSPD), HL
	CALL	CHMSPD
;		
	LD	HL, 0
	LD	(M1ACCNUM), HL
;		
	JP	M1START1
;		
M1STARTACC:		

	LD	HL, (M1SPD)
	LD	DE, (ACCDATA)
	AND	A
	SBC	HL, DE		
	JP	P, M1STARTFIX		
	JP	Z, M1STARTFIX		
;				
	LD	(MSPD), DE		
	CALL	CHMSPD		
;				
	LD	HL, 1		;
	LD	(M1ACCNUM), HL		
;				
	LD	HL, (M1TGT)		
	SRL	H		
	RR	L		
	INC	HL		
	LD	(M1HTGT), HL		
;				
;		
M1START1:		
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(M1FLG), A
;		
	RET	
;		

;/*END M1START*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	MOTOR1 WELL IDOU	
;		
;	??:	WELL_SET
;		H_96/H_38
;		WELL_ADR
;		
;////////////////////////////////////////		
;/*M1WELL*/		
M1WELL:		
	IN	A, (EIO2)
	BIT	3, A
	JP	Z, WELL38
;		
;		
WELL96:		
;==========		

	LD	HL, 0
	LD	DE, (WELL_SET)
	AND	A
	SBC	HL, DE
	RET	P
	RET	Z
;		
	LD	HL, 12
	LD	DE, (WELL_SET)
	AND	A
	SBC	HL, DE
	RET	M
;==========		
;		

	IN	A, (DIP3)
	PUSH	AF
	AND	01111111B
	LD	DE, 0
	LD	E, A
	LD	(D_96), DE
;		
	POP	AF
	BIT	7, A
	JP	Z, M1WELL96_1
;		
	LD	HL, 0
	LD	DE, (D_96)
	AND	A
	SBC	HL, DE
	LD	(D_96), HL
M1WELL96_1:		
;		
	LD	IX, WELL_96X
	LD	HL, (WELL_SET)
	LD	(NOW_WELL), HL
	ADD	HL, HL
	PUSH	HL
	POP	DE
	ADD	IX, DE
	LD	L, (IX+0)
	LD	H, (IX+1)
;		
	LD	DE, (D_96)
	ADD	HL, DE
;		
	LD	DE, (H_96)
	ADD	HL, DE
;		
	LD	DE, (WELL_ADR)
	ADD	HL, DE
;		
	LD	(ZAHYO_SET1), HL
	CALL	M1SET
	JP	C, M1WELL_END
;		
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1MOVE
;		
	JP	M1WELL_END
;		
WELL38:		
;==========		

	LD	HL, 0
	LD	DE, (WELL_SET)
	AND	A
	SBC	HL, DE
	RET	P
	RET	Z
;		
	LD	HL, 24
	LD	DE, (WELL_SET)
	AND	A
	SBC	HL, DE
	RET	M
;==========		

	IN	A, (DIP4)
	PUSH	AF
	AND	01111111B
	LD	DE, 0
	LD	E, A
	LD	(D_38), DE
;		
	POP	AF
	BIT	7, A
	JP	Z, M1WELL38_1
;		
	LD	HL, 0
	LD	DE, (D_38)
	AND	A
	SBC	HL, DE
	LD	(D_38), HL
M1WELL38_1:		
;		
	LD	IX, WELL_38X
	LD	HL, (WELL_SET)
	LD	(NOW_WELL), HL
	ADD	HL, HL
	PUSH	HL
	POP	DE
	ADD	IX, DE
	LD	L, (IX+0)
	LD	H, (IX+1)
;		
	LD	DE, (D_38)
	ADD	HL, DE
;		
	LD	DE, (H_38)
	ADD	HL, DE
;		
	LD	DE, (WELL_ADR)
	ADD	HL, DE
;		
	LD	(ZAHYO_SET1), HL
	CALL	M1SET
	JP	C, M1WELL_END
;		
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1MOVE
;		
M1WELL_END:		
	RET	
;		
;/*END M1WELL*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	M1 GENTEN HUKKI	
;////////////////////////////////////////		
;/*M1GEN*/		
M1GEN:		
	LD	A, 1
	LD	(RDYFLG), A
;		
;		
	LD	HL, (M1SPD)
	PUSH	HL
;		
M1GEN0:		

	LD	HL, (RDYTIMER0)
	LD	(RDYTIMER), HL
	LD	A, 1
	LD	(RDYFLG), A
;		
;		

	IN	A, (EIO2)
	BIT	0, A
	JP	Z, M1GEN2
;		

M1GEN1:		
	LD	A, 1
	LD	(M1DIR), A
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	LD	HL, 5560
	LD	(M1TGT), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
M1GEN1LP:		
;==========		
	LD	A, 1
	LD	(ALM1FLG), A
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	Z, ALARM1
;==========		
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, M1GEN1LP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		

M1GEN2:		
	LD	A, 0
	LD	(M1DIR), A
	LD	HL, (XSPD2)
	LD	(M1SPD), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
M1GEN2LP:		
	IN	A, (EIO2)
	BIT	0, A
	JP	Z, M1GEN2LP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	LD	HL, 50
	LD	(DELTGT), HL
	CALL	DELAY
;		

GEN3:		
	LD	A, 1
	LD	(M1DIR), A
	LD	HL, (XSPD2)
	LD	(M1SPD), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
GEN3LP:		
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, GEN3LP
;		
	LD	A, 0
	LD	(M1FLG), A
;		

GEN4:		
	LD	A, 1
	LD	(M1DIR), A
	LD	HL, (XSPD2)
	LD	(M1SPD), HL
	LD	HL, (HPHOSEI)
	LD	(M1TGT), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
GEN4LP:		
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	NZ, GEN4LP
;		
	LD	A, 0
	LD	(M1FLG), A
;		

	LD	HL, 0
	LD	(NOW_X), HL
	LD	A, 0
	LD	(NOW_Y), A
;		
;		

GEN5:		
	LD	A, 0
	LD	(RDYFLG), A
;		
	LD	A, (BEIO3)
	SET	1, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
;		
	POP	HL
	LD	(M1SPD), HL
;		
	LD	A, 0
	LD	(RDYFLG), A
;		
;		
;NOW_WELL, WELL_ADR??		
	LD	HL, 0
	LD	(NOW_WELL), HL
	LD	(WELL_ADR), HL
;		
;		
	RET	
;		
;		
;/*END M1GEN*/		
;////////////////////////////////////////		
;		
;////////////////////////////////////////		
;/*M1HP*/		
M1HP:		

	IN	A, (EIO2)
	BIT	0, A
	RET	Z
;		
M1HP0:		

M1HP1:		
	LD	A, 1
	LD	(M1DIR), A
;;;	LD	HL, (XSPD1)
;;;	LD	(M1SPD), HL
	LD	HL, 5560
	LD	(M1TGT), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
M1HP1LP:		
;==========		
	LD	A, 1
	LD	(ALM1FLG), A
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	Z, ALARM1
;==========		
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, M1HP1LP
;		
	DI	
	LD	A, 0
	LD	(M1FLG), A
	EI			
;				

	LD	HL, 5560		
	LD	DE, (M1TGT)		
	AND	A		
	SBC	HL, DE		
;				
	PUSH	HL		;DE = HL
	POP	DE		
;				
	LD	HL, (NOW_X)		
	AND	A		
	SBC	HL, DE		
;				
	LD	(NOW_X), HL		
;		
	LD	A, 0
	LD	(NOW_Y), A
;		
;		
;NOW_WELL, WELL_ADR??		
	LD	HL, 0
	LD	(NOW_WELL), HL
	LD	(WELL_ADR), HL
;		
;		
	RET	
;		
;		
;/*END M1HP*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	M1 EP????	
;////////////////////////////////////////		
;/*M1EP*/		
M1EP:		

	IN	A, (EIO2)
	BIT	1, A
	RET	Z
;		
M1EP0:		

M1EP1:		
	LD	A, 0
	LD	(M1DIR), A
;;;	LD	HL, (XSPD1)
;;;	LD	(M1SPD), HL
	LD	HL, 5560
	LD	(M1TGT), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
M1EP1LP:		
;==========		
	LD	A, 2
	LD	(ALM1FLG), A
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	Z, ALARM1
;==========		
	IN	A, (EIO2)
	BIT	1, A
	JP	NZ, M1EP1LP
;		
	DI	
	LD	A, 0
	LD	(M1FLG), A
	EI	
;		

	LD	HL, 5560
	LD	DE, (M1TGT)
	AND	A
	SBC	HL, DE
;		
	LD	DE, (NOW_X)
	ADD	HL, DE
;		
	LD	(NOW_X), HL
;		
	LD	A, 1
	LD	(NOW_Y), A
;		
;		
;NOW_WELL, WELL_ADR??		
	LD	HL, 25
	LD	(NOW_WELL), HL
	LD	HL, 0
	LD	(WELL_ADR), HL
;		
;		
	RET	
;		
;		
;/*END M1EP*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	M1 DP(DRAIN-TANK POINT) ????	
;////////////////////////////////////////		
;/*M1DP*/		
M1DP:		
	CALL	M1HP
;		
;NOW_WELL, WELL_ADR???		
	LD	HL, 26
	LD	(NOW_WELL), HL
	LD	HL, 0
	LD	(WELL_ADR), HL
;		
;		
	RET	
;		
;/*END M1DP*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;/*M1CP*/		
M1CP:		

;		
	RET	
;		
;/*END M1CP*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	MOROT2 MOVE	
;		
;	M2TGT?????	
;		
;	??:	M2SPD
;		M2DIR(0:HIDARI, 1:MIGI)
;		M2TGT
;		
;////////////////////////////////////////		
;/*M2MOVE*/		
M2MOVE:		
	LD	HL, (M2SPD)
	LD	(MSPD), HL
	CALL	CHMSPD
;		
	LD	A, (M2DIR)
	AND	A
	JP	NZ, M2MOVECW
;		
	LD	A, (BEIO2)
	RES	3, A
	LD	(BEIO2), A
	OUT	(EIO2), A
	JP	M2MOVECCWEX
;		
M2MOVECW:		
	LD	A, (BEIO2)
	SET	3, A
	LD	(BEIO2), A
	OUT	(EIO2), A
;		
M2MOVECCWEX:		
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(M2FLG), A
;		
M2MOVELP:		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
;		
	LD	HL, (M2TGT)
	LD	A, H
	OR	L
	JP	NZ, M2MOVELP
;		
	LD	A, (M2TGT+2)
	AND	A
	JP	Z, M2MOVE2
;		
	DEC	A
	LD	(M2TGT+2), A
;		
M2MOVELP1:		
	LD	HL, (M2TGT)
	LD	A, H
	OR	L
	JP	Z, M2MOVELP1
;		
	JP	M2MOVELP
;		
M2MOVE2:		
	LD	A, 0
	LD	(M2FLG), A
;		
	RET	
;		
;/*END M2MOVE*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	MOROT2 START	
;		
;	?????	
;		
;	??:	M2SPD
;		M2DIR(0:HIDARI, 1:MIGI)
;		
;////////////////////////////////////////		
;/*M2START*/		
M2START:		
	LD	HL, (M2SPD)
	LD	(MSPD), HL
	CALL	CHMSPD
;		
	LD	A, (M2DIR)
	AND	A
	JP	NZ, M2STARTCW
;		
	LD	A, (BEIO2)
	RES	3, A
	LD	(BEIO2), A
	OUT	(EIO2), A
	JP	M2STARTCCWEX
;		
M2STARTCW:		
	LD	A, (BEIO2)
	SET	3, A
	LD	(BEIO2), A
	OUT	(EIO2), A
;		
M2STARTCCWEX:		
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(M2FLG), A
;		
	RET	
;		
;/*END M2START*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	M2 GENTEN (????)	
;////////////////////////////////////////		
;/*M2GEN*/		
M2GEN:		
;		
M2GEN0:		

	IN	A, (EIO2)
	BIT	2, A
	JP	Z, M2GEN20
;		

M2GEN10:		
	LD	A, 0
	LD	(M2DIR), A
	LD	HL, 50
	LD	(M2TGT), HL
	CALL	M2MOVE
;		

;;	LD	HL, (M2TGT)
;;	LD	A, H
;;	OR	L
;;	JP	Z, $
;==========		
;		

M2GEN20:		
	LD	A, 0
	LD	(M2DIR), A
	LD	HL, 2000
	LD	(M2TGT), HL
	CALL	M2START
M2GEN20LP:		
;==========;?????????????		
;;	LD	HL, (M2TGT)
;;	LD	A, H
;;	OR	L
;;	JP	Z, $
;==========		
	IN	A, (EIO2)
	BIT	2, A
	JP	Z, M2GEN20LP
;		
	LD	A, 0
	LD	(M2FLG), A
;		
;		
	RET	
;		
;/*END M2GEN*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;/*QVER*/		
QVER:		
	PUSH	IX
	POP	DE
;		
	LD	HL, STR_VER
	LD	BC, 4
	LDIR	
;		
	RET	
;		
;/*END QVER*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	HP??? ??	
;		
;	??: IX 	
;		


;		
;////////////////////////////////////////		
;/*QA*/		
QA:		
	IN	A, (EIO2)
	BIT	0, A
	JP	Z, QA_ON
;		
;OFF ??		
	LD	(IX+0), 'A'
	LD	(IX+1), '0'
	LD	(IX+2), '@'
;		
	RET	
;		
;		
QA_ON:		
;ON ??		
	LD	(IX+0), 'A'
	LD	(IX+1), '1'
	LD	(IX+2), '@'
;		
	RET	
;		
;/*END QA*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;/*QB*/		
QB:		
	IN	A, (EIO2)
	BIT	1, A
	JP	Z, QB_ON
;		
;OFF ??		
	LD	(IX+0), 'B'
	LD	(IX+1), '0'
	LD	(IX+2), '@'
;		
	RET	
;		
;		
QB_ON:		
;ON ??		
	LD	(IX+0), 'B'
	LD	(IX+1), '1'
	LD	(IX+2), '@'
;		
	RET	
;		
;/*END QB*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	96/384??? ??	
;		
;////////////////////////////////////////		
;/*QC*/		
QC:		
	IN	A, (EIO2)
	BIT	3, A
	JP	Z, QC_ON
;		
;OFF ??		
	LD	(IX+0), 'C'
	LD	(IX+1), '0'
	LD	(IX+2), '@'
;		
	RET	
;		
;		
QC_ON:		
;ON ??		
	LD	(IX+0), 'C'
	LD	(IX+1), '1'
	LD	(IX+2), '@'
;		
	RET	
;		
;/*END QC*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	?????? ??	
;		
;////////////////////////////////////////		
;/*QD*/		
QD:		
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, QD_ON
;		
;OFF ??		
	LD	(IX+0), 'D'
	LD	(IX+1), '0'
	LD	(IX+2), '@'
;		
	RET	
;		
;		
QD_ON:		
;ON ??		
	LD	(IX+0), 'D'
	LD	(IX+1), '1'
	LD	(IX+2), '@'
;		
	RET	
;		
;/*END QD*/				
;////////////////////////////////////////				
;				
;				
;////////////////////////////////////////				
;/*QX*/				
QX:				
	LD	(IX+0), 'X'		
	LD	(IX+1), 'W'		
;				
;NOW_WELL				
;				
	PUSH	IX		;
	LD	HL, (NOW_WELL)		
	LD	(K3_IN0), HL		
	LD	A, 0		
	LD	(K3_IN2), A		
	CALL	HEX2ASC		
	POP	IX		;
;				
	LD	A, (K3_OUT1)		
	LD	(IX+2), A		
	LD	A, (K3_OUT0)		
	LD	(IX+3), A		
;				
;WELL_ADD?????				
	LD	HL, (WELL_ADR)		
	LD	A, H		
	BIT	7, A		
	JP	Z, QX1		
;				
	LD	A, '-'		
	LD	(IX+4), A		
;				
	LD	HL, 0		
	LD	DE, (WELL_ADR)		
	AND	A		
	SBC	HL, DE		
	JP	QX2		
;				
QX1:				
	LD	A, '+'		
	LD	(IX+4), A		
;				
	LD	HL, (WELL_ADR)		
QX2:				
;				
	PUSH	IX		;
	LD	(K3_IN0), HL		
	LD	A, 0		
	LD	(K3_IN2), A		
	CALL	HEX2ASC		
	POP	IX		;
;				
	LD	A, (K3_OUT2)		
	LD	(IX+5), A		
	LD	A, (K3_OUT1)		
	LD	(IX+6), A		
	LD	A, (K3_OUT0)		
	LD	(IX+7), A		
;				
;				
	LD	A, '@'		
	LD	(IX+8), A		
;	
;	
	RET
;	
;	
;/*END QX*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	
;////////////////////////////////////////	
;/**/	
;	
;/*END */	
;////////////////////////////////////////	
;		
;		
;////////////////////////////////////////		
;	VOL MODE( MODEFLG = 0 )	
;////////////////////////////////////////		
;/*VOL*/		
VOL:		
	LD	A, 0
	LD	(MODEFLG), A
	CALL	RAM2ROMF
;		
	LD	A, (BPIO0)
	SET	0, A
	RES	1, A
	LD	(BPIO0), A
	OUT	(PIO0), A
;		
	LD	A, (BEIO3)
	RES	0, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	LD	A, (BPIO3)
	RES	0, A
	LD	(BPIO3), A
	OUT	(PIO3), A
;		
VOL1:		
	CALL	DISPVOL
;		
VOLLP:		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	NZ, LVOL
;		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	XOR	B
	JP	NZ, VOL		;PLATE CHANGE -> JMP
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW?
	JP	NZ, VOL_U		
	BIT	4, A		;- SW?
	JP	NZ, VOL_D		
	BIT	7, A		;FEED SW?
	JP	NZ, VOL_F		
;				
	IN	A, (PIO3)		
	BIT	3, A		;BACK SW?
	JP	NZ, VOL_B		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'M'		;MODE SW?
	JP	Z, VOL_M		
	CP	'R'		;RESET SW?
	JP	Z, VOL_R		
	CP	'G'		;START SW?
	JP	Z, VOL_G		
;				


	JP	VOLLP		
;				
;~~~~~				
VOL_U:				
	LD	HL, 0		
	LD	(PUSH_CNT), HL		
;				
	CALL	KEYPUSH
;		
VOL_ULP0:		
	LD	HL, (PUSH_CNT)
	INC	HL
	LD	(PUSH_CNT), HL
;		
	LD	HL, (PARA_VOL)
	LD	DE, (VOLMAX)
	PUSH	HL
	AND	A
	SBC	HL, DE
	POP	HL
	JP	Z, VOL_ULP2
;		
	LD	DE, 100
	PUSH	HL		
	AND	A		
	SBC	HL, DE		
	POP	HL		
	JP	M, VOL_ULP1		
;				
;				
	INC	HL		;PARA_VOL += 5
	INC	HL		
	INC	HL		
	INC	HL		
;				
VOL_ULP1:				
	INC	HL		
	LD	(PARA_VOL), HL		
	JP	VOL_ULP3		
;		
VOL_ULP2:		
	LD	HL, (VOLMIN)
	LD	(PARA_VOL), HL
	CALL	DISPVOL
;		
VOL_ULP3:		
	CALL	DISPVOL
;		
	LD	HL, 10
	LD	(CNT_CNT), HL
	LD	HL, 200
	LD	(CNT_TGTH), HL
	LD	HL, 50
	LD	(CNT_TGTL), HL
	CALL	CNTDELAY
;		
	IN	A, (EIO4)
	BIT	3, A
	JP	NZ, VOL_ULP0
;		
	CALL	CHPARA
;		
	JP	VOL1
;		
;~~~~~		
VOL_D:		
	LD	HL, 0
	LD	(PUSH_CNT), HL
;		
	CALL	KEYPUSH
;		
VOL_DLP0:		
	LD	HL, (PUSH_CNT)
	INC	HL
	LD	(PUSH_CNT), HL
;		
	LD	HL, (PARA_VOL)
	LD	DE, (VOLMIN)
	PUSH	HL
	AND	A
	SBC	HL, DE
	POP	HL
	JP	Z, VOL_DLP2
;		
	LD	DE, 100
	PUSH	HL
	AND	A
	SBC	HL, DE
	POP	HL
	JP	Z, VOL_DLP1
	JP	M, VOL_DLP1
;		
;		
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
;		
VOL_DLP1:		
	DEC	HL
	LD	(PARA_VOL), HL
	JP	VOL_DLP3
;		
VOL_DLP2:		
	LD	HL, (VOLMAX)
	LD	(PARA_VOL), HL
;		
VOL_DLP3:		
	CALL	DISPVOL
;		
	LD	HL, 10
	LD	(CNT_CNT), HL
	LD	HL, 200
	LD	(CNT_TGTH), HL
	LD	HL, 50
	LD	(CNT_TGTL), HL
	CALL	CNTDELAY
;		
	IN	A, (EIO4)
	BIT	4, A
	JP	NZ, VOL_DLP0
;		
	CALL	CHPARA
;		
	JP	VOL1
;		
;~~~~~		
VOL_F:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	FEED
;		
	JP	VOLLP
;		
;~~~~~		
VOL_B:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	BACK
;		
	JP	VOLLP
;		
;~~~~~		
VOL_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	PAT
;		
;~~~~~		
VOL_R:		
	CALL	KEYPUSH
;		
	LD	DE, (PARA_VOL)
;		
	LD	HL, (VOLMAX)
	AND	A
	SBC	HL, DE
	JP	Z, VOL_R2
;		
	LD	HL, (VOLMAX)
VOL_RLP:		
	LD	BC, 200
	AND	A
	SBC	HL, BC
	JP	Z, VOL_R0
	JP	M, VOL_R0
;		
	AND	A
	PUSH	HL
	SBC	HL, DE
	POP	HL
	JP	Z, VOL_R1
	JP	M, VOL_R1
;		
	JP	VOL_RLP
;		
;~		
VOL_R0:		
	LD	HL, 0
;		
VOL_R1:		
	LD	DE, 200
	ADD	HL, DE
	LD	(PARA_VOL), HL
	JP	VOL_R3
;		
VOL_R2:		
	LD	HL, (VOLMIN)
	LD	(PARA_VOL), HL
;		
VOL_R3:		
	CALL	CHPARA
	CALL	DISPVOL
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	VOL1
;		
;~~~~~		
VOL_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(BNFLG), A
;		
	LD	A, 0
	LD	(STASEQ), A
	CALL	START
;		
	LD	A, 0
	LD	(BNFLG), A
;		
	JP	VOL1
;		
;~~~~~		
;		
;/*END VOL*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;/*DISPVOL*/		
DISPVOL:		
	LD	HL, (PARA_VOL)
	LD	A, H
	LD	(K3_IN1), A
	LD	A, L
	LD	(K3_IN0), A
	CALL	HEX2DEC
	LD	A, (K3_OUT3)
	LD	(DIGIT1K), A
	LD	A, (K3_OUT2)
	LD	(DIGIT100), A
	LD	A, (K3_OUT1)
	LD	(DIGIT10), A
	LD	A, (K3_OUT0)
	LD	(DIGIT1), A
;		
	CALL	DISP7SEG
;		
	RET	
;		
;/*END DISPVOL*/		
;////////////////////////////////////////		
;		
;				
;////////////////////////////////////////				
;	PAT MODE( MODEFLG = 1 )			
;////////////////////////////////////////				
;/*PAT*/				
PAT:				
	LD	A, 1		
	LD	(MODEFLG), A		
	CALL	RAM2ROMF		
;				
	LD	A, (BPIO0)		
	RES	0, A		;VOL LED
	SET	1, A		;PAT LED
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
	LD	A, (BEIO3)		
	RES	0, A		;PROG LED
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	A, (BPIO3)		
	RES	0, A		;LODER LED
	LD	(BPIO3), A		
	OUT	(PIO3), A		
;				
	LD	HL, 0		
	LD	(PAT_BUF), HL		
PAT1:				
	CALL	DISPPAT		
;				
PATLP:				
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	NZ, LPAT
;		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	XOR	B		
	JP	NZ, PAT		;CHANGE PLATE -> JMP
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW?
	JP	NZ, PAT_U		
;				
	BIT	4, A		;- SW?
	JP	NZ, PAT_D		
;				
	BIT	7, A		;FEED SW?
	JP	NZ, PAT_F		
;				
	IN	A, (PIO3)		
	BIT	3, A		;BACK SW?
	JP	NZ, PAT_B		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'M'		;MODE SW?
	JP	Z, PAT_M		
	CP	'C'		;SEL SW?
	JP	Z, PAT_C		
	CP	'G'		;START SW?
	JP	Z, PAT_G		
;				
	JP	PATLP		
;				
;~~~~~				
PAT_F:				
	CALL	KEYPUSH		
;				
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	FEED
;		
	JP	PAT1
;		
;~~~~~		
PAT_B:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	BACK
;		
	JP	PAT1
;		
;~~~~~		
PAT_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	PROG
;		
;~~~~~		
PAT_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(BNFLG), A
;		
	LD	A, 0
	LD	(STASEQ), A
	CALL	START
;		
	LD	A, 0
	LD	(BNFLG), A
;		
	JP	PAT1
;		
;~~~~~		
PAT_C:		
	CALL	KEYPUSH
;		
	LD	HL, 50
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, PARA_PAT
	LD	BC, (PAT_BUF)
	ADD	HL, BC
	LD	A, (HL)
;		
	XOR	1
	LD	(HL), A
;		
	CALL	CHPARA
;		
	JP	PAT1
;		
;~~~~~		
PAT_U:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (PAT_BUF)
	LD	BC, (END_HOLE)
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, PAT_U1		
;				
	INC	HL		
	LD	(PAT_BUF), HL		
	JP	PAT1		
;				
PAT_U1:				
	LD	HL, (STA_HOLE)		
	LD	(PAT_BUF), HL		
	JP	PAT1		
;				
;				
;~~~~~				
PAT_D:				
	CALL	KEYPUSH		
;				
	LD	HL, 200		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (PAT_BUF)		
	LD	BC, (STA_HOLE)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, PAT_D1		
;				
	DEC	HL
	LD	(PAT_BUF), HL
	JP	PAT1
;		
PAT_D1:		
	LD	HL, (END_HOLE)
	LD	(PAT_BUF), HL
	JP	PAT1
;		
;		
;~~~~~		
;~~~~~		
;		
;/*END PAT*/		
;////////////////////////////////////////		
;		
;				
;////////////////////////////////////////				
;	DISPLAY PATTERN			

;				
;	??	:PARA_PAT		
;		:PAT_NUM		
;////////////////////////////////////////				
;/*DISPPAT*/				
DISPPAT:				
	LD	BC, (PAT_BUF)		
	INC	BC		;PAT_NUM + 1
	LD	(K3_IN0), BC		
	CALL	HEX2DEC		
;				
	LD	A, (K3_OUT1)		
	LD	(DIGIT1K), A		
	LD	A, (K3_OUT0)		
	LD	(DIGIT100), A		
;				
;				
	LD	HL, PARA_PAT		
	LD	BC, (PAT_BUF)		
	ADD	HL, BC		;PARA_PAT + (PAT_NUM)
	LD	A, (HL)		
;				
	LD	(K3_IN0), A		
	CALL	HEX2DEC		
;				
	LD	A, (K3_OUT0)		
	LD	(DIGIT1), A		
;				
	LD	A, 0AH		;'-'
	LD	(DIGIT10), A		
;				
	CALL	DISP7SEG		
;				
	RET			
;				
;/*END DISPPAT*/				
;////////////////////////////////////////				
;				
;				
;////////////////////////////////////////				
;	PROG MODE( MODEFLG = 2 )			
;////////////////////////////////////////				
;/*PROG*/				
PROG:				
PROG0:				
	LD	A, 2		
	LD	(MODEFLG), A		
	CALL	RAM2ROMF		
;				
	LD	A, (BPIO0)		
	RES	0, A		;VOL LED
	RES	1, A		;PAT LED
	LD	(BPIO0), A		
	OUT	(PIO0), A		

	LD	A, (BEIO3)		
	SET	0, A		;PROG LED
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	A, (BPIO3)		
	RES	0, A		;LODER LED
	LD	(BPIO3), A		
	OUT	(PIO3), A		
;				
	LD	A, 0AH		;'-'
	LD	(DIGIT1K), A		
	LD	(DIGIT100), A		
	LD	(DIGIT10), A		
	LD	(DIGIT1), A		
	CALL	DISP7SEG		
;				
PROG0LP:				
	LD	A, 10000001B		
	OUT	(SIO1MD), A		
	IN	A, (SIO1MD)		
	AND	01000000B
	JP	NZ, PROG
;		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	CP	B
	JP	NZ, VOL
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'M'
	JP	Z, PROG0_M
	CP	'U'
	JP	Z, PROG0_U
	CP	'D'
	JP	Z, PROG0_D
	JP	PROG0LP
;		
;~~~~~		
PROG0_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	VOL
;		
;~~~~~		
PROG0_U:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (STA_PROG)
	LD	(PROG_NUM), HL
	JP	PROG1
;		
;~~~~~		
PROG0_D:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (END_PROG)
	LD	(PROG_NUM), HL
	JP	PROG1
;		
;~~~~~		
;~~~~~		
;		
PROG1:		
	CALL	DISPPROG
;		
PROG1LP:		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	NZ, LPROG
;		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	XOR	B
	JP	NZ, VOL
;		
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'M'
	JP	Z, PROG1_M
	CP	'C'
	JP	Z, PROG1_C
	CP	'U'
	JP	Z, PROG1_U
	CP	'D'
	JP	Z, PROG1_D
;		
	JP	PROG1LP
;		
;~~~~~		
PROG1_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	VOL
;		
;~~~~~		
PROG1_C:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LOAD
;		
;		
;~~~~~		
PROG1_U:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;				
	LD	HL, (PROG_NUM)		
	LD	BC, (END_PROG)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, PROG1_U1		
;				
	INC	HL		
	LD	(PROG_NUM), HL		
	JP	PROG1		
;				
PROG1_U1:				
	LD	HL, (STA_PROG)		
	LD	(PROG_NUM), HL		
	JP	PROG1		
;				
;~~~~~				
PROG1_D:				
	CALL	KEYPUSH		
;				
	LD	HL, 200		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (PROG_NUM)		
	LD	BC, (STA_PROG)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, PROG1_D1
;		
	DEC	HL
	LD	(PROG_NUM), HL
	JP	PROG1
;		
PROG1_D1:		
	LD	HL, (END_PROG)
	LD	(PROG_NUM), HL
	JP	PROG1
;		
;		
;~~~~~		
;		
;/*END PROG*/		
;////////////////////////////////////////		
;				
;				
;////////////////////////////////////////				
;/*DISPPROG*/				
DISPPROG:				
	LD	HL, (PROG_NUM)		
	LD	(K3_IN0), HL		
	CALL	HEX2DEC		
;				
	LD	A, (K3_OUT1)		
	LD	(DIGIT100), A		
	LD	A, (K3_OUT0)		
	LD	(DIGIT10), A		
;				
	LD	A, 0FH		;'-'
	LD	(DIGIT1K), A		
	LD	(DIGIT1), A
;		
	CALL	DISP7SEG
;		
	RET	
;		
;/*END DISPPROG*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	LODER VOL MODE( MODEFLG = 3 )	
;////////////////////////////////////////		
;/*LVOL*/		
LVOL:		
	LD	A, 3
	LD	(MODEFLG), A		
	CALL	RAM2ROMF		
;				
	LD	A, (BPIO0)		
	SET	0, A		;VOL LED
	RES	1, A		;PAT LED
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
	LD	A, (BEIO3)		
	RES	0, A		;PROG LED
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	A, (BPIO3)		
	SET	0, A		;LODER LED
	LD	(BPIO3), A		
	OUT	(PIO3), A		
;				
LVOL1:				
	CALL	DISPVOL		
;				
LVOLLP:				
	LD	A, 10000001B		
	OUT	(SIO1MD), A		
	IN	A, (SIO1MD)		
	AND	01000000B		
	JP	Z, VOL		;STACKER DISCONNECT -> JMP
;				
	LD	A, (CMD0FLG)		
	AND	A		
	CALL	NZ, FETCHPC0		
;				
	LD	A, (PLATEFLG)		
	PUSH	AF		
	CALL	CHPLATE		
	POP	AF		
	LD	B, A		
	LD	A, (PLATEFLG)		
	XOR	B		
	JP	NZ, LVOL1		
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW?
	JP	NZ, LVOL_U		
	BIT	4, A		;- SW?
	JP	NZ, LVOL_D		
	BIT	7, A		;FEED SW?
	JP	NZ, LVOL_F		
;				
	IN	A, (PIO3)		
	BIT	3, A		;BACK SW?
	JP	NZ, LVOL_B		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'M'		
	JP	Z, LVOL_M		
	CP	'R'		
	JP	Z, LVOL_R		
	CP	'G'		
	JP	Z, LVOL_G		
;				
	JP	LVOLLP		
;		
;~~~~~		
LVOL_U:		
	LD	HL, 0
	LD	(PUSH_CNT), HL
;		
	CALL	KEYPUSH
;		
LVOL_ULP0:		
	LD	HL, (PUSH_CNT)
	INC	HL
	LD	(PUSH_CNT), HL
;		
	LD	HL, (PARA_VOL)
	LD	DE, (VOLMAX)
	PUSH	HL
	AND	A		
	SBC	HL, DE		
	POP	HL		
	JP	Z, LVOL_ULP2		
;				
	LD	DE, 100		
	PUSH	HL		
	AND	A		
	SBC	HL, DE		
	POP	HL		
	JP	M, LVOL_ULP1		
;				
;				
	INC	HL		;PARA_LVOL += 5
	INC	HL		
	INC	HL		
	INC	HL
;		
LVOL_ULP1:		
	INC	HL
	LD	(PARA_VOL), HL
	JP	LVOL_ULP3
;		
LVOL_ULP2:		
	LD	HL, (VOLMIN)
	LD	(PARA_VOL), HL
;		
LVOL_ULP3:		
	CALL	DISPVOL
;		
	LD	HL, 10
	LD	(CNT_CNT), HL
	LD	HL, 200
	LD	(CNT_TGTH), HL
	LD	HL, 50
	LD	(CNT_TGTL), HL
	CALL	CNTDELAY
;		
	IN	A, (EIO4)
	BIT	3, A
	JP	NZ, LVOL_ULP0
;		
	CALL	CHPARA
;		
	JP	LVOL1
;		
;~~~~~		
LVOL_D:		
	LD	HL, 0
	LD	(PUSH_CNT), HL
;		
	CALL	KEYPUSH
;		
LVOL_DLP0:		
	LD	HL, (PUSH_CNT)
	INC	HL
	LD	(PUSH_CNT), HL
;		
	LD	HL, (PARA_VOL)
	LD	DE, (VOLMIN)
	PUSH	HL
	AND	A
	SBC	HL, DE
	POP	HL
	JP	Z, LVOL_DLP2
;		
	LD	DE, 100
	PUSH	HL
	AND	A
	SBC	HL, DE
	POP	HL
	JP	Z, LVOL_DLP1
	JP	M, LVOL_DLP1
;		
;		
	DEC	HL
	DEC	HL
	DEC	HL
	DEC	HL
;		
LVOL_DLP1:		
	DEC	HL
	LD	(PARA_VOL), HL
	JP	LVOL_DLP3
;		
LVOL_DLP2:		
	LD	HL, (VOLMAX)
	LD	(PARA_VOL), HL
;		
LVOL_DLP3:		
	CALL	DISPVOL
;		
	LD	HL, 10
	LD	(CNT_CNT), HL
	LD	HL, 200
	LD	(CNT_TGTH), HL
	LD	HL, 50
	LD	(CNT_TGTL), HL
	CALL	CNTDELAY
;		
	IN	A, (EIO4)
	BIT	4, A
	JP	NZ, LVOL_DLP0
;		
	CALL	CHPARA
;		
	JP	LVOL1
;		
;~~~~~		
LVOL_F:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(LFDSEQ), A
;;	CALL	LFD
;		
	JP	LVOLLP
;		
;~~~~~		
LVOL_B:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(LFDSEQ), A
;;	CALL	LBK
;		
	JP	LVOLLP
;		
;~~~~~		
LVOL_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LPAT
;		
;~~~~~		
LVOL_R:		
	CALL	KEYPUSH
;		
	LD	DE, (PARA_VOL)
;		
	LD	HL, (VOLMAX)
	AND	A
	SBC	HL, DE
	JP	Z, LVOL_R2
;		
	LD	HL, (VOLMAX)
LVOL_RLP:		
	LD	BC, 200
	AND	A		
	SBC	HL, BC		
	JP	Z, LVOL_R0		
	JP	M, LVOL_R0		
;				
	AND	A		
	PUSH	HL		;VOLMAX - (200 * X) ???
	SBC	HL, DE		
	POP	HL		
	JP	Z, LVOL_R1		
	JP	M, LVOL_R1		
;				
	JP	LVOL_RLP		
;				
;~				
LVOL_R0:				
	LD	HL, 0
;		
LVOL_R1:		
	LD	DE, 200
	ADD	HL, DE
	LD	(PARA_VOL), HL
	JP	LVOL_R3
;		
LVOL_R2:		
	LD	HL, 2
	LD	(PARA_VOL), HL
;		
LVOL_R3:		
	CALL	CHPARA
	CALL	DISPVOL
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LVOL1
;		
;~~~~~		
LVOL_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(LSTASEQ), A
	LD	A, 1
	LD	(BNFLG), A
;;	CALL	LSTA
	LD	A, 0
	LD	(BNFLG), A
;		
	JP	LVOL1
;		
;~~~~~		
;		
;/*END LVOL*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	LODER PAT MODE( MODEFLG = 4 )	
;////////////////////////////////////////				
;/*LPAT*/				
LPAT:				
	LD	A, 4		
	LD	(MODEFLG), A		
	CALL	RAM2ROMF		
;				
	LD	A, (BPIO0)		
	RES	0, A		;VOL LED
	SET	1, A		;PAT LED
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
	LD	A, (BEIO3)		
	RES	0, A		;PROG LED
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	A, (BPIO3)		
	SET	0, A		;LODER LED
	LD	(BPIO3), A		
	OUT	(PIO3), A		
;				
	LD	HL, 0		
	LD	(PAT_BUF), HL		
LPAT1:				
	CALL	DISPPAT		
;				
LPATLP:				
	LD	A, 10000001B		
	OUT	(SIO1MD), A		
	IN	A, (SIO1MD)		
	AND	01000000B		
	JP	Z, PAT		;STACKER DISCONNECT -> JMP
;				
	LD	A, (CMD0FLG)		
	AND	A		
	CALL	NZ, FETCHPC0		
;				
	LD	A, (PLATEFLG)		
	PUSH	AF		
	CALL	CHPLATE		
	POP	AF		
	LD	B, A		
	LD	A, (PLATEFLG)		
	XOR	B		
	JP	NZ, LPAT		
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW?
	JP	NZ, LPAT_U		
	BIT	4, A		;- SW?
	JP	NZ, LPAT_D		
	BIT	7, A		;FEED SW?
	JP	NZ, LPAT_F		
;				
	IN	A, (PIO3)		
	BIT	3, A		;BACK SW?
	JP	NZ, LPAT_B		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'M'		;MODE SW?
	JP	Z, LPAT_M		
	CP	'C'		;SEL SW?
	JP	Z, LPAT_C		
	CP	'G'		;START SW?
	JP	Z, LPAT_G		
;				

	JP	LPATLP		
;				
;~~~~~				
LPAT_F:				
	CALL	KEYPUSH		
;				
	LD	HL, 150		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	A, 0
	LD	(LFDSEQ), A
;;	CALL	LFD
;		
	JP	LPAT1
;		
;~~~~~		
LPAT_B:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(LFDSEQ), A
;;	CALL	LBK
;		
	JP	LPAT1
;		
;~~~~~		
LPAT_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LPROG
;		
;~~~~~		
LPAT_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(LSTASEQ), A
	LD	A, 1
	LD	(BNFLG), A
;;	CALL	LSTA
	LD	A, 0
	LD	(BNFLG), A
;		
	JP	LPAT1
;		
;~~~~~		
LPAT_C:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, PARA_PAT
	LD	BC, (PAT_BUF)
	ADD	HL, BC
	LD	A, (HL)
;		
	XOR	1
	LD	(HL), A
;		
	CALL	CHPARA
;		
	JP	LPAT1
;		
;~~~~~		
LPAT_U:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (PAT_BUF)
	LD	BC, (END_HOLE)
	PUSH	HL
	AND	A
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, LPAT_U1		
;				
	INC	HL		
	LD	(PAT_BUF), HL		
	JP	LPAT_U2		
;				
LPAT_U1:				
	LD	HL, (STA_HOLE)		
	LD	(PAT_BUF), HL		
;				
LPAT_U2:				
	JP	LPAT1		
;				
;~~~~~				
LPAT_D:				
	CALL	KEYPUSH		
;				
	LD	HL, 200		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (PAT_BUF)		
	LD	BC, (STA_HOLE)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, LPAT_D1		
;				
	DEC	HL		
	LD	(PAT_BUF), HL
	JP	LPAT_D2
;		
LPAT_D1:		
	LD	HL, (END_HOLE)
	LD	(PAT_BUF), HL
;		
LPAT_D2:		
	JP	LPAT1
;		
;~~~~~		
;~~~~~		
;		
;/*END LPAT*/		
;////////////////////////////////////////		
;		
;				
;////////////////////////////////////////				
;	LODER PROG MODE( MODEFLG = 5 )			
;////////////////////////////////////////				
;/*LPROG*/				
LPROG:				
LPROG0:				
	LD	A, 5		
	LD	(MODEFLG), A		
	CALL	RAM2ROMF		
;				
	LD	A, (BPIO0)		
	RES	0, A		;VOL LED
	RES	1, A		;PAT LED
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
	LD	A, (BEIO3)		
	SET	0, A		;PROG LED
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	A, (BPIO3)		
	SET	0, A		;LODER LED
	LD	(BPIO3), A		
	OUT	(PIO3), A		
;				
	LD	A, 0AH		;'-'
	LD	(DIGIT1K), A		
	LD	(DIGIT100), A		
	LD	(DIGIT10), A		
	LD	(DIGIT1), A		
	CALL	DISP7SEG		
;				
LPROG0LP:				
	LD	A, 10000001B		
	OUT	(SIO1MD), A		
	IN	A, (SIO1MD)		
	AND	01000000B		
	JP	Z, PROG		;STACKER DISCONNECT -> JMP
;				
	LD	A, (CMD0FLG)		
	AND	A		
	CALL	NZ, FETCHPC0		
;				
	LD	A, (PLATEFLG)		
	PUSH	AF		
	CALL	CHPLATE		
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	CP	B
	JP	NZ, LVOL
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'M'
	JP	Z, LPROG0_M
	CP	'U'
	JP	Z, LPROG0_U
	CP	'D'
	JP	Z, LPROG0_D
	JP	LPROG0LP
;		
;~~~~~		
LPROG0_M:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LVOL
;		
;~~~~~		
LPROG0_U:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (STA_PROG)
	LD	(PROG_NUM), HL
	JP	LPROG1
;		
;~~~~~		
LPROG0_D:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (END_PROG)
	LD	(PROG_NUM), HL
	JP	LPROG1		
;				
;~~~~~				
;~~~~~				
;				
LPROG1:				
	CALL	DISPPROG		
;				
LPROG1LP:				
	LD	A, 10000001B		
	OUT	(SIO1MD), A		
	IN	A, (SIO1MD)		
	AND	01000000B		
	JP	Z, PROG		;STACKER DISCONNECT -> JMP
;				
	LD	A, (CMD0FLG)		
	AND	A		
	CALL	NZ, FETCHPC0		
;				
	LD	A, (PLATEFLG)		
	PUSH	AF		
	CALL	CHPLATE		
	POP	AF		
	LD	B, A		
	LD	A, (PLATEFLG)		
	XOR	B		
	JP	NZ, LVOL		
;				
;				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'M'		;MODE SW?
	JP	Z, LPROG1_M		
	CP	'C'		;SELECT SW?
	JP	Z, LPROG1_C		
	CP	'U'		;+ SW?
	JP	Z, LPROG1_U		
	CP	'D'		;- SW?
	JP	Z, LPROG1_D		
;				
	JP	LPROG1LP		
;				
;~~~~~				
LPROG1_M:				
	CALL	KEYPUSH		
;				
	LD	HL, 150		
	LD	(DELTGT), HL		
	CALL	DELAY
;		
	JP	LVOL
;		
;~~~~~		
LPROG1_C:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	LOAD
;		
;		
;~~~~~		
LPROG1_U:				
	CALL	KEYPUSH		
;				
	LD	HL, 200		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (PROG_NUM)		
	LD	BC, (END_PROG)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, LPROG1_U1		
;				
	INC	HL		
	LD	(PROG_NUM), HL
	JP	LPROG1
;		
LPROG1_U1:		
	LD	HL, (STA_PROG)
	LD	(PROG_NUM), HL
	JP	LPROG1
;		
;~~~~~		
LPROG1_D:		
	CALL	KEYPUSH
;		
	LD	HL, 200
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (PROG_NUM)		
	LD	BC, (STA_PROG)		
	PUSH	HL		
	AND	A		
	SBC	HL, BC		
	POP	HL		;PUSH HL
	JP	Z, LPROG1_D1		
;				
	DEC	HL		
	LD	(PROG_NUM), HL		
	JP	LPROG1		
;				
LPROG1_D1:				
	LD	HL, (END_PROG)		
	LD	(PROG_NUM), HL		
	JP	LPROG1		
;		
;		
;~~~~~		
;		
;/*END LPROG*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	LOAD MODE( PROG/LPROG MODE ? )	
;		
;////////////////////////////////////////		
;/*LOAD*/		
LOAD:		
	LD	A, 00001011B
	LD	(DIGIT1K), A
	LD	A, 00011101B
	LD	(DIGIT100), A
	LD	A, 01111110B
	LD	(DIGIT10), A
	LD	A, 00111101B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		
LOADLP:		
	LD	A, (MODEFLG)
	CP	5
	JP	Z, LOADLP1
;		
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	Z, LOADLP2
;		
;		
LOADLP1:		
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	Z, PROG
;		
;		
LOADLP2:		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	XOR	B
	JP	NZ, VOL
;		
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'C'
	JP	Z, LOAD_C
	CP	'G'
	JP	Z, LOAD_G
;		
	JP	LOADLP
;		
;~~~~~		
;~~~~~		
LOAD_C:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	JP	SAVE
;		
;~~~~~		
LOAD_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, PARA00
	LD	DE, 26
	LD	BC, (PROG_NUM)
	LD	A, C
	LD	B, A
LOAD_G1:		
	ADD	HL, DE
	DJNZ	LOAD_G1
;		
	LD	DE, PARA
	LD	BC, 26
	LDIR	
;		
	CALL	CHPARA
;		
	JP	VOL
;~~~~~		
;		
;/*END LOAD*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SAVE MODE( PROG/LPROG MODE ? )	
;////////////////////////////////////////		
;/*SAVE*/		
SAVE:		
	LD	A, 01010111B
	LD	(DIGIT1K), A
	LD	A, 01111110B
	LD	(DIGIT100), A
	LD	A, 00111011B
	LD	(DIGIT10), A
	LD	A, 01001111B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		
SAVELP:		
	LD	A, (MODEFLG)
	CP	5
	JP	Z, SAVELP1
;		
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	Z, SAVELP2
;		
;		
SAVELP1:		
;		
	LD	A, 10000001B
	OUT	(SIO1MD), A
	IN	A, (SIO1MD)
	AND	01000000B
	JP	Z, PROG
;		
;		
SAVELP2:		
	LD	A, (CMD0FLG)
	AND	A
	CALL	NZ, FETCHPC0
;		
	LD	A, (PLATEFLG)
	PUSH	AF
	CALL	CHPLATE
	POP	AF
	LD	B, A
	LD	A, (PLATEFLG)
	XOR	B
	JP	NZ, VOL		
;				
;				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'C'		;SEL SW?
	JP	Z, SAVE_C		
	CP	'G'		;START SW?
	JP	Z, SAVE_G		
;				
	JP	SAVELP		
;				
;~~~~~				
;~~~~~				
SAVE_C:				
	CALL	KEYPUSH		
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, (MODEFLG)
	CP	5
	JP	Z, SAVE_C1
;		
	JP	PROG1
;		
SAVE_C1:		
	JP	LPROG1
;		
;~~~~~		
SAVE_G:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, PARA00
	LD	DE, 26
	LD	A, (PROG_NUM)
	LD	B, A
SAVE_G1:		
	ADD	HL, DE
	DJNZ	SAVE_G1
;		
	LD	A, L
	LD	E, A
	LD	A, H
	LD	D, A
	LD	HL, PARA
	LD	BC, 26
	LDIR	
;		
	CALL	RAM2ROM
;		


	JP	VOL
;		
;~~~~~		
;		
;/*END SAVE*/		
;////////////////////////////////////////		
;	
;	
;////////////////////////////////////////	
;	ON
;////////////////////////////////////////	
;/**/	

;/*END */	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	ON
;////////////////////////////////////////	
;/**/	

;/*END */
;////////////////////////////////////////
;
;
;////////////////////////////////////////
;
;////////////////////////////////////////
;/**/
;
;/*END */
;////////////////////////////////////////
;
;
;/*START*/
START:
;
;==========;STOPFLG != 0 -> CALL STOP1				
	LD	A, (STOPFLG)		
	AND	A		
	CALL	NZ, STOP1		
;==========				
;==========;PLATE_SW CHANGE -> ALARM1-3				
	LD	A, 3		
	LD	(ALM1FLG), A		
	LD	A, (PLATEFLG)		
	PUSH	AF		
	CALL	CHPLATE		
	POP	BC		;PUSH AF (B=A)
	LD	A, (PLATEFLG)		
	XOR	B		
	JP	NZ, ALARM1		
;==========				
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
	LD	A, (STASEQ)
	CP	0
	JP	Z, STA000
	CP	1
	JP	Z, STA010
	CP	2
	JP	Z, STA020
	CP	3
	JP	Z, STA030		
	CP	4		
	JP	Z, STA040		
;				; & (XSTEPBUF += XSTEP)
	CP	5		
	JP	Z, STA050		
;				; & XSTEPBUF RESET
	CP	6		
	JP	Z, STA060		
	CP	7		
	JP	Z, STA070		
;				; & PAT_NUM ++
;				;TO DROP HANTEI
	CP	8		
	JP	Z, STA080		
	CP	9		
	JP	Z, STA090		
	CP	10		
	JP	Z, STA100		
	CP	11		
	JP	Z, STA110		
;				; & XSTEPBUF RESET
	CP	12		
	JP	Z, STA120		
	CP	13		
	JP	Z, STA130		
;				; & TO PAT_NUM --
;				;TO DROP HANTEI
	CP	14		
	JP	Z, STA140		
	CP	15		
	JP	Z, STA150		
	RET	
;		
;~~~~~~~~~~		
;~~~~~~~~~~		
STA000:		
	CALL	STA001
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA001:		

	LD	HL, 0
	LD	(PAT_NUM), HL
;		

	CALL	VOL2PLS
;		
;		
	RET	
;		
;~~~~~~~~~~		
STA010:		
	CALL	STA011
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA011:		
	CALL	M1GEN
;		
	RET	
;		
;~~~~~~~~~~		
STA020:		
	CALL	STA021
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA021:		
;	;FEED TILL HP	
	LD	HL, (PSPD)
	LD	(M2SPD), HL
	CALL	M2GEN
;		
STA022:		
;	;FEED 1/4 ROUND	
	LD	A, 0
	LD	(M2DIR), A
	LD	HL, (PSPD)
	LD	(M2SPD), HL
	LD	HL, 400
	LD	(M2TGT), HL
	LD	A, 0
	LD	(M2TGT+2), A
	CALL	M2START
STA022LP1:		
	LD	HL, (M2TGT)
	LD	A, L
	OR	H
	JP	Z, STA022LP2
	JP	STA022LP1
STA022LP2:		
	LD	A, (M2TGT+2)
	AND	A
	JP	Z, STA023
	DEC	A
	LD	(M2TGT+2), A
	JP	STA022LP1
;		
STA023:		
	LD	A, 0
	LD	(M2FLG), A
;		
	RET	
;		
;~~~~~~~~~~		
STA030:		
	CALL	STA031
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA031:		
;		
	RET	
;		
;~~~~~~~~~~		
STA040:		
	CALL	STA041
;		
	JP	C, STA04A
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
STA04A:		
	LD	A, 7		
	LD	(STASEQ), A		
	JP	START		;TO STA070(END HOLE HANTEI)
;				
;~~~~~				
STA041:				
	LD	HL, PARA_PAT		
	LD	BC, (PAT_NUM)		
	ADD	HL, BC		
	LD	A, (HL)		
	AND	A		
	RET	NZ		;DROP OK -> RET
;				
;				
	SCF			;DROP NG -> SCF
	RET			
;		
;		
;~~~~~~~~~~		
STA050:		
	CALL	STA051
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA051:		
	LD	HL, (PAT_NUM)
	INC	HL
	LD	(WELL_SET), HL
	LD	HL, 0
	LD	(WELL_ADR), HL
;		
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	CALL	M1WELL
;		
	RET	
;		
;~~~~~~~~~~		
STA060:		
	CALL	STA061
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA061:		
	LD	HL, (PWAIT1)
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(M1DIR), A	; Bill did this was m2dir
	LD	HL, (PSPD)
	LD	(M2SPD), HL
	LD	HL, (PPLS)
	LD	(M2TGT), HL
	LD	A, (PPLS+2)
	LD	(M2TGT+2), A
	CALL	M2MOVE
;		
	LD	HL, (PWAIT2)
	LD	(DELTGT), HL
	CALL	DELAY
;		
	RET	
;		
;~~~~~~~~~~		
STA070:		
	CALL	STA071
;		
	JP	C, STA07A
;		
	LD	A, 4
	LD	(STASEQ), A
	JP	START		
;				
STA07A:				
	LD	A, (PLATEFLG)		
	AND	A		
	JP	NZ, STA07B		
;				
	LD	A, 14		
	LD	(STASEQ), A		
	JP	START		
;				
STA07B:				
	LD	A, (STASEQ)		
	INC	A		
	LD	(STASEQ), A		
	JP	START		;TO STA080(STAGE KIRIKAE)
;				
;~~~~~				
STA071:				
	LD	HL, (END_HOLE)		
	LD	BC, (PAT_NUM)		
	AND	A		
	SBC	HL, BC		
	JP	Z, STA072		
;				
	INC     BC			
	LD	(PAT_NUM), BC		
	AND	A		;CARRY RES
	RET			
;				
;				
STA072:				
	SCF	
	RET	
;		
;~~~~~~~~~~		
STA080:		
	CALL	STA081
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA081:		
	CALL	M1EP
;		
	LD	HL, 250
	LD	(DELTGT), HL
	CALL	DELAY
;		
	RET	
;		
;~~~~~~~~~~		
STA090:		
	CALL	STA091
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA091:		
;		
	RET	
;		
;~~~~~~~~~~		
STA100:		
	CALL	STA101
;		
	JP	C, STA10A
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
STA10A:		
	LD	A, 13		
	LD	(STASEQ), A		
	JP	START		
;				
;~~~~~				
STA101:				;DROP GO/NOGO HANTEI
	LD	HL, PARA_PAT		
	LD	BC, (PAT_NUM)		
	ADD	HL, BC		
	LD	A, (HL)		
	AND	A		
	RET	NZ		;DROP OK -> RET
;				
	SCF			;DROP NG -> SCF
	RET			
;				
;		
;~~~~~~~~~~		
STA110:		
	CALL	STA111
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA111:		
	LD	HL, (PAT_NUM)
	INC	HL
	LD	(WELL_SET), HL
;		
	IN	A, (DIP5)
	PUSH	AF
	AND	01111111B
	LD	DE, 0
	LD	E, A
	LD	(WELL_ADR), DE
;		
	POP	AF
	BIT	7, A
	JP	Z, STA111_1
;		
	LD	HL, 0
	LD	DE, (WELL_ADR)
	AND	A
	SBC	HL, DE
	LD	(WELL_ADR), HL
STA111_1:		
;		
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	CALL	M1WELL
;		
	RET	
;		
;~~~~~~~~~~		
STA120:		
	CALL	STA121
;		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;				
;~~~~~				
STA121:				
	CALL	STA061		;DROP
;				
	RET			
;				
;~~~~~~~~~~				
STA130:				
	CALL	STA131		
;				
	JP	C, STA13A		
;				
	LD	A, 10		
	LD	(STASEQ), A		
	JP	START		
;		
STA13A:		
	LD	A, (STASEQ)
	INC	A
	LD	(STASEQ), A
	JP	START
;		
;~~~~~		
STA131:		
	LD	HL, (STA_HOLE)
	LD	BC, (PAT_NUM)
	AND	A
	SBC	HL, BC
	JP	Z, STA132
;		
	DEC	BC
	LD	(PAT_NUM), BC		
	AND	A		;CARRY RES
	RET			
;				
STA132:				
	SCF			
	RET			
;				
;~~~~~~~~~~				
STA140:				
	CALL	STA141		
;				
	LD	A, (STASEQ)		
	INC	A		
	LD	(STASEQ), A		
	JP	START		
;		
;~~~~~		
STA141:		
	CALL	M1GEN
;		
	RET	
;		
;~~~~~~~~~~		
STA150:		
	LD	A, (AGINGFLG)
	AND	A
	RET	Z
;		
;		
	LD	A, (MODEFLG)
	CP	0
	CALL	Z, DISPVOL		
	CP	1		
	CALL	Z, DISPPAT		
;				
	LD	A, 0		
	LD	(STASEQ), A		
	JP	START		;AGINGFLG == 1 -> ENDLESS
;				
;~~~~~~~~~~				
;				
;				
;				
;/*END START*/				
;////////////////////////////////////////				
;				
;				
;////////////////////////////////////////		
;	PUMP FEED ( TILL SW ON )	
;////////////////////////////////////////		
;/*FEED*/		
FEED:		
;==========		
	LD	A, 4
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, ALARM1
;==========		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
;		
FEEDNOERR:		
;		
	LD	A, 0
	LD	(M2DIR), A
	LD	HL, (PSPD1)
	LD	(M2SPD), HL
	CALL	M2START
FEEDLP:		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)		
	BIT	4, A		
	JP	Z, ALARM1		
;==========				
	IN	A, (EIO4)		
	BIT	7, A		;
	JP	NZ, FEEDLP		
;				
	LD	A, 0		
	LD	(M2FLG), A		
;				
	RET			
;				
;/*END FEED*/				
;////////////////////////////////////////				
;				
;		
;////////////////////////////////////////		
;	PUMP RETURN ( TILL SW ON )	
;////////////////////////////////////////		
;/*BACK*/		
BACK:		
;==========		
	LD	A, 4
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, ALARM1
;==========		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
;		
;		
BACKNOERR:		
	LD	A, 1
	LD	(M2DIR), A
	LD	HL, (PSPD1)
	LD	(M2TIMER0), HL
	CALL	M2START
BACKLP:		
;==========;COVER SENSOR ON -> ALARM1-5		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)		
	BIT	4, A		
	JP	Z, ALARM1		
;==========				
	IN	A, (PIO3)		
	BIT	3, A		;
	JP	NZ, BACKLP		
;				
	LD	A, 0		
	LD	(M2FLG), A		
;				
	RET			
;				
;/*END BACK*/				
;////////////////////////////////////////				
;				
;				
;////////////////////////////////////////				
;	STOP LOOP 1			
;				


;////////////////////////////////////////				
;/*STOP1*/				
STOP1:				
	PUSH	AF		
	PUSH	BC		
	PUSH	DE		
	PUSH	HL		
;				
;				
	LD	A, 0		;TENMETSH TEISHI
	LD	(RDYFLG), A
	LD	A, (BEIO3)
	SET	1, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	CALL	BUZSET
;		
	LD	A, 0FFH
	LD	(KPBUF0), A
	LD	(KPBUF1), A
	LD	(KPBUF2), A
	LD	B, A
STOP1_0:		
	LD	A, B
	LD	(KPBUF0), A
;		
	LD	A, (KPBUF1)
	LD	B, A
STOP1_1:		
	LD	A, B
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF2)
	LD	B, A
STOP1_2:		
	LD	A, B
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF2)
	LD	B, A
	DJNZ	STOP1_2
	LD	A, 01H
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF1)
	LD	B, A
	DJNZ	STOP1_1
	LD	A, 07FH
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF0)
	LD	B, A
	DJNZ	STOP1_0
;		
	CALL	BUZRES
;		
;		
STOP1LP:		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'G'
	JP	Z, STOP1_G
	CP	'R'
	JP	Z, STOP1_R
	JP	STOP1LP
;		
;~~~~~		
STOP1_G:		
	CALL	KEYPUSH
;		
	LD	A, 0
	LD	(STOPFLG), A
;		
	POP	HL		
	POP	DE		
	POP	BC		
	POP	AF		
	RET			;(CALL STOP1)
;				
;~~~~~				
STOP1_R:				
	CALL	KEYPUSH		
	LD	A, 0		
	LD	(STOPFLG), A		
;;;	LD	(AGINGFLG), A		
;				
	POP	HL		
	POP	DE		
	POP	BC		
	POP	AF
;		
	CALL	M1GEN
;		
	POP	AF 
	RET	
;		
;		
;/*END STOP1*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	STOP LOOP 2( LODER MODE )	
;////////////////////////////////////////		
;/*STOP2*/		
STOP2:		
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		
;		
	LD	A, 0
	LD	(RDYFLG), A
	LD	A, (BEIO3)
	SET	1, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	CALL	BUZSET
;		
	LD	A, 0FFH
	LD	(KPBUF0), A
	LD	(KPBUF1), A
	LD	(KPBUF2), A
	LD	B, A
STOP2_0:		
	LD	A, B
	LD	(KPBUF0), A
;		
	LD	A, (KPBUF1)
	LD	B, A
STOP2_1:		
	LD	A, B
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF2)
	LD	B, A
STOP2_2:		
	LD	A, B
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF2)
	LD	B, A
	DJNZ	STOP2_2
	LD	A, 01H
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF1)
	LD	B, A
	DJNZ	STOP2_1
	LD	A, 07FH
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF0)
	LD	B, A
	DJNZ	STOP2_0
;		
	CALL	BUZRES
;		
;		
STOP2LP:		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'G'
	JP	Z, STOP2_G
	CP	'R'
	JP	Z, STOP2_R
	JP	STOP2LP
;		
;~~~~~		
STOP2_G:		
	CALL	KEYPUSH
;		
	LD	A, 0
	LD	(STOPFLG), A
;		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
;		
	RET	
;		
;~~~~~		
STOP2_R:				
	CALL	KEYPUSH		
;				
	LD	A, 16		;JMP PLATE UNLOAD
	LD	(LSTASEQ), A		
	LD	A, 0		
	LD	(STOPFLG), A		
;;;	LD	(AGINGFLG), A		
;				
	POP	HL		
	POP	DE		
	POP	BC		
	POP	AF		
;				
	RET			
;				
;		
;		
;/*END STOP2*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	STOP LOOP 3	
;		
;	PC?????????	
;		
;////////////////////////////////////////		
;/*STOP3*/		
STOP3:		
	PUSH	AF
	PUSH	BC
	PUSH	DE		
	PUSH	HL		
;				
	LD	A, 0		;TENMETSH TEISHI
	LD	(RDYFLG), A		
	LD	A, (BEIO3)		
	SET	1, A		
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	CALL	BUZSET		
;				
	LD	A, 0FFH		
	LD	(KPBUF0), A		
	LD	(KPBUF1), A		
	LD	(KPBUF2), A		
	LD	B, A
STOP3_0:		
	LD	A, B
	LD	(KPBUF0), A
;		
	LD	A, (KPBUF1)
	LD	B, A
STOP3_1:		
	LD	A, B
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF2)
	LD	B, A
STOP3_2:		
	LD	A, B
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF2)
	LD	B, A
	DJNZ	STOP3_2
	LD	A, 01H
	LD	(KPBUF2), A
;		
	LD	A, (KPBUF1)
	LD	B, A
	DJNZ	STOP3_1
	LD	A, 07FH
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF0)
	LD	B, A
	DJNZ	STOP3_0
;		
	CALL	BUZRES
;		
;		
STOP3LP:		
	LD	A, (CMDSFLG)
	AND	A
	JP	Z, STOP3_S0
	LD	A, (CMDAFLG)
	AND	A
	JP	NZ, STOP3_A
	JP	STOP3LP
;		
;~~~~~		
STOP3_S0:		
;		
	POP	HL		
	POP	DE		
	POP	BC		
	POP	AF		
	RET			;(CALL STOP3)
;				
;~~~~~				
STOP3_A:				
	LD	A, 0		
	LD	(CMDAFLG), A		
	LD	(CMDSFLG), A		
;				
	POP	HL		
	POP	DE		
	POP	BC		
	POP	AF		
;		
	CALL	M1GEN
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	RET	
;		
;		
;/*END STOP1*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	BACKUP DATA RESET	
;////////////////////////////////////////		
;/*BKUPRES*/				
BKUPRES:				
;				
	LD	A, 0AAH		;(10101010B)
	LD	(BKUPFLG), A		
;				
	LD	A, 0		
	LD	(MODEFLG), A		
;				
	LD	HL, 5		
	LD	(PARA_VOL), HL		
;				
;	;PATTERN DEFAULT VALUE			
	LD	A, 24		
	LD	B, A		
	LD	A, 1		
	LD	IX, PARA_PAT
DEF_PATLP:		
	LD	(IX+0), A
	INC	IX
	DJNZ	DEF_PATLP
;		
	LD	HL, PARA
	LD	DE, PARA00
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA01
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA02
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA03
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA04
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA05
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA06
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA07
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA08
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA09
	LD	BC, 26
	LDIR	
;		
	LD	HL, PARA
	LD	DE, PARA10
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA11
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA12
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA13
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA14
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA15
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA16
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA17
	LD	BC, 26
	LDIR	
	LD	HL, PARA
	LD	DE, PARA18		
	LD	BC, 26		
	LDIR			
	LD	HL, PARA		
	LD	DE, PARA19		
	LD	BC, 26		
	LDIR			
;				
	LD	A, 1		
	LD	(PSPDFLG), A		
	LD	HL, (PSPD1)		;PSPEED HI
	LD	(PSPD), HL		
;				
	LD	HL, 0		;POSITION HOHEI
	LD	(H_96), HL		
	LD	(H_38), HL		
;		
	CALL	RAM2ROM
;		
	RET	
;		
;/*END BKUPRES*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	DISPLAY 7SEG_LED	
;	?"CODE B" DECODE	
;		
;	??:	DIGIT1K
;		DIGIT100
;		DIGIT10
;		DIGI1		
;////////////////////////////////////////				
;/*DISP7SEG/				
DISP7SEG:				
	LD	A, 10011000B		;CONTROL WORD
	OUT	(DISP1), A		
	LD	A, (DIGIT1K)		;DIGIT1 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT100)		;DIGIT2 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT10)		;DIGIT3 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT1)		;DIGIT4 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT5 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT6 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT7 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT8 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;IGNORED PLS
	OR	10000000B		
	OUT	(DISP0), A
;		
	RET	
;		
;/*END DISP7SEG*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	DISPLAY 7SEG_LED 2	
;	?NO DECODE	
;		
;	??:	DIGIT1K
;		DIGIT100
;		DIGIT10
;		DIGI1
;////////////////////////////////////////				
;/*DISP7SEG2/				
DISP7SEG2:				
	LD	A, 10111000B		;CONTROL WORD
	OUT	(DISP1), A		
	LD	A, (DIGIT1K)		;DIGIT1 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT100)		;DIGIT2 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT10)		;DIGIT3 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, (DIGIT1)		;DIGIT4 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT5 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT6 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT7 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;DIGIT8 DATA
	OR	10000000B		
	OUT	(DISP0), A		
	LD	A, 0		;IGNORED PLS
	OR	10000000B		
	OUT	(DISP0), A		
;	
	RET
;	
;/*END DISP7SEG2*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	CHANGE PARAMETER
;	
;	96 : PARA -> PARA00
;	384: PARA -> PARA10
;	
;////////////////////////////////////////	
;/*CHPARA*/	
CHPARA:	
	LD	A, (PLATEFLG)
	AND	A
	JP	NZ, CHPARA1
;		
	LD	HL, PARA
	LD	DE, PARA00
	LD	BC,26
	LDIR	
;		
	CALL	RAM2ROM
;		
	RET	
;		
CHPARA1:		
	LD	HL, PARA
	LD	DE, PARA10
	LD	BC, 26
	LDIR	
;		
	CALL	RAM2ROM
;		
	RET	
;		
;		
;/*END CHPARA*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	CHANGE(CHECK) PLATE	
;		
;	?:	PLATEFLG (0:96, 1:384)
;		STA_HOLE (0)
;		END_HOLE (11/23)
;		STA_PROG (1/11)
;		END_PROG (9/19)
;		
;		
;////////////////////////////////////////		
;/*CHPLATE*/		
CHPLATE:		
	CALL	CKPLATE
;		
	IN	A, (EIO2)
	BIT	3, A
	JP	NZ, CHPLATE_96
;		
;PLATE384		
	LD	A, 1		
	LD	(PLATEFLG), A		
;				
	LD	HL, 0		
	LD	(STA_HOLE), HL		
	LD	HL, 23		
	LD	(END_HOLE), HL		
;				
	LD	HL, 11		
	LD	(STA_PROG), HL		
	LD	HL, 19		
	LD	(END_PROG), HL		
;				
	LD	A, (BEIO3)		
	RES	4, A		;LED 96
	SET	5, A		;LED 384
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	HL, PARA10	;	KARA LOAD
	LD	DE, PARA		
	LD	BC, 26		
	LDIR			
	RET			
;				
;				
CHPLATE_96:				
	LD	A, 0		
	LD	(PLATEFLG), A		
;				
	LD	HL, 0		
	LD	(STA_HOLE), HL		
	LD	HL, 11		
	LD	(END_HOLE), HL		
;				
	LD	HL, 1		
	LD	(STA_PROG), HL		
	LD	HL, 9		
	LD	(END_PROG), HL		
;				
	LD	A, (BEIO3)		
	SET	4, A		;LED 96
	RES	5, A		;LED 384
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
	LD	HL, PARA00		
	LD	DE, PARA		
	LD	BC, 26
	LDIR	
	RET	
;		
;		
;/*END CHPLATE*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	CHECK PLATE	
;		
;////////////////////////////////////////		
;/*CKPLATE*/		
CKPLATE:		
	LD	A, (PLATEFLG)
	AND	A
	JP	NZ, CKPLATE384
	JP	CKPLATE96
;		
CKPLATE96:		
	IN	A, (EIO2)
	BIT	3, A
	RET	NZ
;		
	JP	CKPLATEEND
;		
;		
CKPLATE384:		
	IN	A, (EIO2)
	BIT	3, A
	RET	Z
;		
	JP	CKPLATEEND
;		
CKPLATEEND:		
	LD	HL, 99
	LD	(NOW_WELL), HL
	LD	HL, 0
	LD	(WELL_ADR), HL
;		
	RET	
;		
;		
;/*END CKPLATE*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SWITCH SCAN	
;		
;	?:	SWVAL
;		
;	SW?????RET	
;	MODE	- 'M'
;	RESET	- 'R'
;	SELECT	- 'C'(CHOICE)
;	+	- 'U'(UP)
;	-	- 'D'(DOWM)
;	START	- 'G'
;	STOP	- 'S'
;	FEED	- 'F'
;	BACK	- 'B'
;////////////////////////////////////////		
;/*SWSCAN*/		
SWSCAN:		
	LD	A, 0
	LD	(SWVAL), A
;		
	IN	A, (EIO4)
	BIT	0, A
	JP	NZ, SW_M
	BIT	1, A
	JP	NZ, SW_R
	BIT	2, A
	JP	NZ, SW_C
	BIT	3, A
	JP	NZ, SW_U
	BIT	4, A
	JP	NZ, SW_D
	BIT	5, A
	JP	NZ, SW_G
	BIT	6, A
	JP	NZ, SW_S
	BIT	7, A
	JP	NZ, SW_F
;		
	IN	A, (PIO3)
	BIT	3, A
	JP	NZ, SW_B
	RET	
;		
;		
SWSCAN1:		
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	IN	A, (EIO4)
	AND	A
	JP	NZ, SWSCAN1
	RET	
;		
;		
SWSCAN2:		
	LD	HL, 1
	LD	(DELTGT), HL
	CALL	DELAY
;		
	IN	A, (PIO3)
	BIT	3, A
	JP	NZ, SWSCAN2
	RET	
;		
;~~~~~		
SW_M:		
	LD	A, 'M'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_R:		
	LD	A, 'R'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_C:		
	LD	A, 'C'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_U:		
	LD	A, 'U'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_D:		
	LD	A, 'D'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_G:		
	LD	A, 'G'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_S:		
	LD	A, 'S'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_F:		
	LD	A, 'F'
	LD	(SWVAL), A
	JP	SWSCAN1
;~~~~~		
SW_B:		
	LD	A, 'B'
	LD	(SWVAL), A
	JP	SWSCAN2
;~~~~~		
;		
;/*END SWSCAN*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	SWITCH SCAN FAST	
;		
;////////////////////////////////////////		
;/*SWSCANF*/		
SWSCANF:		
	LD	A, 0
	LD	(SWVAL), A
;		
	IN	A, (EIO4)
	BIT	0, A
	JP	NZ, SW_M
	BIT	1, A
	JP	NZ, SW_R
	BIT	2, A
	JP	NZ, SW_C
;;;	BIT	3, A
;;;	JP	NZ, SW_U
;;;	BIT	4, A
;;;	JP	NZ, SW_D
	BIT	5, A
	JP	NZ, SW_G
	BIT	6, A
	JP	NZ, SW_S
	BIT	7, A
	JP	NZ, SW_F
;		
;;;	IN	A, (PIO3)
;;;	BIT	3, A
;;;	JP	NZ, SW_B
	RET	
;		
;~~~~~		
;		
;/*END SWSCANF*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	CNTDELAY	
;////////////////////////////////////////		
;/*CNTDELAY*/		
CNTDELAY:		
	LD	HL, (PUSH_CNT)		
	LD	BC, (CNT_CNT)		
	AND	A		
	SBC	HL, BC		
	JP	P, CNTDELAY1		;PUSH_CNT >= (CNT_CNT)
;				
	LD	HL, (CNT_TGTH)		
	LD	(DELTGT), HL		
	CALL	DELAY		
	RET			
;				
CNTDELAY1:				
	LD	HL, (CNT_TGTL)		
	LD	(DELTGT), HL		
	CALL	DELAY		
	RET			
;		
;		
;/*END CNTDELAY*/		
;////////////////////////////////////////		
;/*KEYPUSH*/		
KEYPUSH:		
	CALL	BUZSET
;		
	LD	A, 0FFH
	LD	(KPBUF0), A
	LD	(KPBUF1), A
	LD	B, A
KEYPLP0:		
	LD	A, B
	LD	(KPBUF0), A
;		
	LD	A, (KPBUF1)
	LD	B, A
KEYPLP1:		
	LD	A, B
	LD	(KPBUF1), A
;		
;		
	LD	A, (KPBUF1)
	LD	B, A
	DJNZ	KEYPLP1
	LD	A, 0FH
	LD	(KPBUF1), A
;		
	LD	A, (KPBUF0)
	LD	B, A
	DJNZ	KEYPLP0
;		
	CALL	BUZRES
;		
	RET	
;		
;		
;/*KEYPUSH END*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	BUZZER SET	
;////////////////////////////////////////		
;/*BUZSET*/		
BUZSET:		
	LD	A, (BPIO3)
	SET	1, A
	LD	(BPIO3), A
	OUT	(PIO3), A
	RET	
;		
;/*END BUZSET*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	BUZZER RESET	
;////////////////////////////////////////		
;/*BUZSET*/		
BUZRES:		
	LD	A, (BPIO3)
	RES	1, A
	LD	(BPIO3), A
	OUT	(PIO3), A
	RET	
;		
;		
;/*END BUSRES*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	DELAY	(DELTGT*1mSEC)
;		
;	??:	DELTGT
;		
;////////////////////////////////////////		
;/*DELAY*/		
DELAY:		
	LD	HL, (DELTGT)
	LD	A, L
	OR	H
	RET	Z
;		
	LD	A, 1
	LD	(DELFLG), A
DELAYLP:		
;==========		
	LD	A, (FEEDFLG)
	AND	A
	JP	Z, DELAYLP1
;		
	LD	A, 5
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	Z, ALARM1
;==========		
DELAYLP1:		
	LD	HL, (DELTGT)
	LD	A, L
	OR	H
	JP	NZ, DELAYLP
;		
	LD	A, 0
	LD	(DELFLG), A
;		
	RET	
;		
;		
;/*END DELAY*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	OPENDELAY (DELTGT*1mSEC)	
;		
;////////////////////////////////////////		
;/*OPENDELAY*/		
OPENDELAY:		
	LD	HL, (DELTGT)
	LD	A, L
	OR	H
	RET	Z
;		
	LD	A, 1
	LD	(DELFLG), A
;		
	RET	
;		
;		
;/*END OPENDELAY*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ON	
;////////////////////////////////////////		
;/**/		

;/*END */		
;////////////////////////////////////////		
;		
;		
;**************************************************		
;	***** ALARM *****	
;		
;////////////////////////////////////////		
;	ALARM1	
;		
;	??:	ALM1FLG
;		
;////////////////////////////////////////		
;/*ALARM1*/		
ALARM1:		
	LD	A, (PCFLG)
	AND	A
	JP	NZ, ALARM4
;		
;		
	LD	A, 1
	LD	(RDYFLG), A
;		
	LD	A, (ALM1FLG)
	CP	1
	JP	Z, ALM1_1
	CP	2
	JP	Z, ALM1_2
	CP	3
	JP	Z, ALM1_3
	CP	4
	JP	Z, ALM1_4
	CP	5
	JP	Z, ALM1_5
	CP	6
	JP	Z, ALM1_6
	JP	$
;		
;		
;~~~~~~~~~~		
;~~~~~~~~~~		
ALM1_1:		
ALM1_2:		
ALM1_3:		
ALM1_5:		
	LD	A, 0
	LD	(M1FLG), A
	LD	(M2FLG), A
;		
	CALL	ALM1LEDSET
	CALL	BUZSET
	CALL	DISPALM1
	CALL	ALM11LOOP1
	CALL	ALM11LOOP2
;		
	LD	HL, 100
	LD	(DELTGT), HL
	CALL	DELAY
;		
	DI	
	NOP	
	JP	0
;		
;~~~~~~~~~~		
ALM1_6:		
	CALL	ALM1LEDSET
	CALL	BUZSET
;		
	LD	A, 01001111B
	LD	(DIGIT1K), A
	LD	A, 01111011B
	LD	(DIGIT100), A
	LD	A, 01111011B
	LD	(DIGIT10), A
	LD	A, 01010111B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		
	CALL	ALM11LOOP1
	CALL	ALM11LOOP2
;		
	LD	HL, 100
	LD	(DELTGT), HL
	CALL	DELAY
;		
	RET	
;		
;~~~~~~~~~~		
ALM11LOOP1:		
	IN	A, (EIO4)
	AND	01000000B
	JP	Z, ALM11LOOP1
	CALL	BUZRES
	RET	
;		
;~~~~~~~~~~		
ALM11LOOP2:		
	IN	A, (EIO4)
	AND	00000010B
	JP	Z, ALM11LOOP2
	CALL	KEYPUSH
	CALL	ALM1LEDRES
	RET	
;		
;		
;~~~~~~~~~~		
;~~~~~~~~~~		
ALM1_4:		
	CALL	ALM1LEDSET
	CALL	BUZSET
;		
	LD	A, 01001011B
	LD	(DIGIT1K), A
	LD	A, 01111011B
	LD	(DIGIT100), A
	LD	A, 01111011B
	LD	(DIGIT10), A
	LD	A, 00110000B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		
	CALL	ALM14LOOP1
	JP	ALM14LOOP2
;		
;		
;~~~~~~~~~~		
ALM14LOOP1:		
	IN	A, (EIO4)
	AND	01000000B
	JP	Z, ALM14LOOP1
	CALL	BUZRES
	RET	
;		
;~~~~~~~~~~		
ALM14LOOP2:		
	IN	A, (EIO4)
	BIT	1, A
	JP	NZ, ALM14LP2_R
	BIT	7, A
	JP	NZ, ALM14LP2_F
	IN	A, (PIO3)
	BIT	3, A
	JP	NZ, ALM14LP2_B
	JP	ALM14LOOP2
;		
;~~~~~		
ALM14LP2_R:		
	CALL	KEYPUSH
	CALL	ALM1LEDRES
;		
	DI	
	NOP	
	JP	0
;		
;~~~~~		
ALM14LP2_F:		
	CALL	KEYPUSH
	CALL	ALM1LEDRES
;		
	JP	FEEDNOERR
;		
;~~~~~		
ALM14LP2_B:		
	CALL	KEYPUSH
	CALL	ALM1LEDRES
;		
	JP	BACKNOERR
;		
;~~~~~		
;		
;/*END ALARM1*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALARM1 LED SET	
;////////////////////////////////////////		
;/*ALM1LEDSET*/		
ALM1LEDSET:		
	LD	A, (BEIO3)
	SET	6, A
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	RET	
;		
;/*END ALM1LEDSET*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALARM1 LED RESET	
;////////////////////////////////////////		
;/*ALM1LEDRES*/		
ALM1LEDRES:		
	LD	A, (BEIO3)
	RES	6, A
	LD	(BEIO3), A
   	OUT	(EIO3), A
;		
	RET	
;		
;/*END ALM1LEDRES*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	DISPLAY ALARM1	
;////////////////////////////////////////		
;/*DISPALM1*/		
DISPALM1:				
	LD	A, 11		;'E'
	LD	(DIGIT1K), A		
	LD	A, 0		;'0'
	LD	(DIGIT100), A		
;				
	LD	HL, 0		
	LD	A, (ALM1FLG)		
	LD	L, A		
	LD	(K3_IN0), HL		
	CALL	HEX2DEC		
;				
	LD	A, (K3_OUT1)		
	LD	(DIGIT10), A		
	LD	A, (K3_OUT0)		
	LD	(DIGIT1), A		
;		
	CALL	DISP7SEG
;		
	RET	
;		
;/*END DISPAML1*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALARMFLG_2 UP	
;		
;////////////////////////////////////////		
;/*ALARM2*/		
ALARM2:		
	LD	A, 1
	LD	(RDYFLG), A		
;				
	LD	A, (ALM2FLG)		
	CP	1		
	JP	Z, ALM21		
	RET			
;				
;~~~~~~~~~~~~~~~~~~~~				
ALM21:				
	CALL	ALM2LEDSET		
	CALL	BUZSET		;BUZZER ON
	CALL	DISPALM2		
	CALL	ALM21LOOP1		
	CALL	ALM21LOOP2		
	DI			
	JP	0		
;				
;~~~~~~~~~~~~~~~~~~~~				
ALM21LOOP1:				
	IN	A, (EIO4)		
	AND	01000000B		;STOP BUTTON?
	JP	Z, ALM21LOOP1		
	CALL	BUZRES		
	RET			
;				
;~~~~~~~~~~~~~~~~~~~~				
ALM21LOOP2:				
	IN	A, (EIO4)		
	AND	00000010B		
	JP	Z, ALM21LOOP2		
	CALL	KEYPUSH		
;				
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	ALM2LEDRES
;		
	RET	
;		
;/*END ALARM2*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALM2LEDSET	
;////////////////////////////////////////		
;/*ALM2LEDSET*/		
ALM2LEDSET:		
	LD	A, (BEIO3)
	SET	7, A
	LD	(BEIO3), A
	OUT	(EIO3), A
	RET	
;		
;/*END ALM2LEDSET*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALM2LEDRES	
;////////////////////////////////////////		
;/*ALM2LEDRES*/		
ALM2LEDRES:		
	LD	A, (BEIO3)		;ARARM2 LED
	RES	7, A		
	LD	(BEIO3), A		
   	OUT	(EIO3), A		
	RET			
;				
;/*END ALM2LEDRES*/				
;////////////////////////////////////////				
;				
;				
;////////////////////////////////////////				
;	DISPALM2			
;////////////////////////////////////////				
;/*DISPALM2*/				
DISPALM2:				
	LD	A, 01101000B		
	OUT	(DISP1), A
	RET	
;		
;/*END DISPALM2*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ALARM3 ( STACKER ERROR )	
;////////////////////////////////////////		
;/*ALARM3*/		
ALARM3:		
;		
	LD	A, 0
	LD	(ERRFLG), A
;		
	LD	A, 1
	LD	(RDYFLG), A
;		
	LD	HL, 5
	LD	(DELTGT), HL
	CALL	DELAY
;		
	IN	A, (SIO0DT)
;;;	LD	(BSIO0DT), A
;;;	LD	A, (BSIO0DT)
	CP	'1'
	JP	Z, ALM31
	CP	'2'
	JP	Z, ALM32
	CP	'3'
	JP	Z, ALM33
	CP	'4'
	JP	Z, ALM34
	CP	'5'
	JP	Z, ALM35
	CP	'6'
	JP	Z, ALM36
	CP	'7'
	JP	Z, ALM37
	CP	'8'
	JP	Z, ALM38
	RET	
;		
;~~~~~		
ALM31:		
ALM32:		
ALM33:		
ALM34:		
ALM35:		
ALM36:		
ALM38:		
	CALL	ALM1LEDSET
	CALL	BUZSET
	CALL	DISPALM3
	CALL	ALM3LP1
	CALL	ALM3LP2
;		
	LD	HL, 100
	LD	(DELTGT), HL
	CALL	DELAY
;		
	DI	
	NOP	
	JP	0		
;				
;~~~~~				
ALM37:				
	LD	A, 0		
	LD	(RDYFLG), A		
;				
	LD	A, 1		
	LD	(STACKFLG), A		
	RET			
;				
;~~~~~~~~~~~~~~~				
;~~~~~~~~~~~~~~~				
ALM3LP1:				
	IN	A, (EIO4)		
	AND	01000000B		;STOP BUTTON?
	JP	Z, ALM3LP1		
	CALL	BUZRES		
	RET			
;				
;~~~~~~~~~~~~~~~				
ALM3LP2:				
	IN	A, (EIO4)		
	AND	00000010B		;RESET BUTTON?
	JP	Z, ALM3LP2		
	CALL	KEYPUSH		
	CALL	ALM1LEDRES		
	RET			
;				
;~~~~~~~~~~~~~~~				
DISPALM3:				
	LD	A, 11		;'E'
	LD	(DIGIT1K), A		
	LD	A, 1		;'1'
	LD	(DIGIT100), A		
	LD	A, 0		;'0'
	LD	(DIGIT10), A		
;;;	LD	A, (BSIO0DT)		
	LD	(DIGIT1), A		
;				
	CALL	DISP7SEG		
;				
	RET			
;				
;~~~~~~~~~~~~~~~				
;				
;/*END ALARM3*/				
;////////////////////////////////////////				
;		
;		
;////////////////////////////////////////		
;	ALARM4	
;		
;////////////////////////////////////////		
;/*ALARM4*/		
ALARM4:		
	LD	A, (ALM1FLG)
	CP	1
	JP	Z, ALM4_1
	CP	2
	JP	Z, ALM4_2
	CP	3
	JP	Z, ALM4_3
	CP	4
	JP	Z, ALM4_4
	CP	5
	JP	Z, ALM4_5
	CP	6
	JP	Z, ALM4_6
	JP	$
;		
;		
;~~~~~~~~~~		
;~~~~~~~~~~		
ALM4_1:		
ALM4_2:		
ALM4_3:		
ALM4_4:		
ALM4_5:		
ALM4_6:		
	LD	A, 0
	LD	(M1FLG), A
	LD	(M2FLG), A
;		
	LD	A, 0
	LD	(FEEDFLG), A
;		
;	?????	
	CALL	ALM4SOSIN
;		
	LD	A, 0
	LD	(CMD0FLG), A
;		
	JP	PCLP
;		
;~~~~~~~~~~		
;/*END ALARM4*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;		
;	ALARM 4 SOSIN	
;		
;	??:	AML1FLG
;		
;////////////////////////////////////////		
;/*ALM4SOSIN*/		
ALM4SOSIN:		
	LD	A, 'E'
	LD	(SOSIN0BUF+0), A
	LD	A, '0'
	LD	(SOSIN0BUF+1), A
	LD	A, '@'
	LD	(SOSIN0BUF+3), A
;		
	LD	A, (ALM1FLG)
	CP	1
	JP	Z, ALM4SOSIN_1
	CP	2
	JP	Z, ALM4SOSIN_2
	CP	3
	JP	Z, ALM4SOSIN_3
	CP	4
	JP	Z, ALM4SOSIN_4
	CP	5
	JP	Z, ALM4SOSIN_5
	CP	6
	JP	Z, ALM4SOSIN_6
	JP	$
;		
;~~~~~		
ALM4SOSIN_1:		
	LD	A, '1'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
ALM4SOSIN_2:		
	LD	A, '2'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
ALM4SOSIN_3:		
	LD	A, '3'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
ALM4SOSIN_4:		
	LD	A, '4'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
ALM4SOSIN_5:		
	LD	A, '5'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
ALM4SOSIN_6:		
	LD	A, '6'
	LD	(SOSIN0BUF+2), A
	CALL	SOSIN0
	RET	
;		
;~~~~~		
;		
;/*END ALM4SOSIN*/		
;////////////////////////////////////////	
;	
;	
;**************************************************	
;	***** SIO RUTINE etc. *****
;	
;	
;////////////////////////////////////////	
;	ON
;////////////////////////////////////////	
;/**/	
;	
;/*END */	
;////////////////////////////////////////	
;	
;	
;**************************************************		
;	***** AGING MODE *****	
;		
AGINGMOD:		
	CALL	BKUPRES
;		
	LD	A, 00001011B
	LD	(DIGIT1K), A
	LD	A, 00001010B
	LD	(DIGIT100), A
	LD	A, 01001110B
	LD	(DIGIT10), A
	LD	A, 01001111B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		

AMODLP:		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'G'
	JP	Z, AMOD_G
	CP	'C'
	JP	Z, AMOD_C
	JP	AMODLP
;		
;~~~		
AMOD_G:		
	CALL	KEYPUSH
	CALL	CHPLATE
;		
	LD	HL, 500
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 1
	LD	(AGINGFLG), A
;		
	JP	MAIN0
;		
;~~~		
AMOD_C:		
	CALL	KEYPUSH
	JP	RUNMOD
;		
;~~~~~~~~~~		
;	***** RUNNING MODE *****	
;   X_CCW(0.5SEC) ~ P_CCW(0.5SEC)		
;      ~ X_CW(0.5SEC) ~ P_CW(0.5SEC) ????		
;		
;		
;		
RUNMOD:		
	LD	A, 00000000B
	LD	(DIGIT1K), A
	LD	A, 000001100B
	LD	(DIGIT100), A
	LD	A, 00011001B
	LD	(DIGIT10), A
	LD	A, 00011100B
	LD	(DIGIT1), A
	CALL	DISP7SEG2
;		

RUNMODLP:				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'C'		
	JP	Z, RUN_C		
	CP	'G'		;START SW?
	CALL	Z, RUN_G		
	JP	RUNMODLP		
;				

;~~~				
RUN_G:				
	CALL	KEYPUSH		
;				
	LD	HL, 1000		
	LD	(DELTGT), HL		
	CALL	DELAY
;		
	LD	A, 0
	LD	(GENSEQ), A
;;	CALL	GENTEN
;		
	LD	HL, 500
	LD	(DELTGT), HL
	CALL	DELAY
;		
RUN:		
	LD	A, 1
	LD	(BNFLG), A
RUNLP:		
;==========;STOPFLG == 1 -> CALL STOP1		
	LD	A, (STOPFLG)
	AND	A
	CALL	NZ, STOP1
;==========		
;	;DISP VOL	
	CALL	DISPVOL
;		
;	;M1 CCW	
	LD	A, 0
	LD	(M1DIR), A
	LD	HL, (XSPD1)
	LD	(M1TIMER0), HL
	LD	HL, 0FFFFH
	LD	(M1TGT), HL
	LD	A, 0
	LD	(M1MODE), A
	CALL	M1START
;				
	LD	HL, 500		;WAIT
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	A, 0		
	LD	(M1FLG), A		
;				
;	;M2 CCW			
	LD	A, 0		
	LD	(M2DIR), A		
	LD	HL, (PSPD1)		
	LD	(M2TIMER0), HL		
	LD	HL, 0FFFFH		
	LD	(M2TGT), HL		
	CALL	M2START		
;				
	LD	HL, 500		;WAIT
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	A, 0		
	LD	(M2FLG), A		
;				
;	;M1 CW			
	LD	A, 1		
	LD	(M1DIR), A		
	LD	HL, (XSPD1)		
	LD	(M1TIMER0), HL		
	LD	HL, 0FFFFH		
	LD	(M1TGT), HL		
	LD	A, 0		
	LD	(M1MODE), A		
	CALL	M1START		
;				
	LD	HL, 500		;WAIT
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	A, 0		
	LD	(M1FLG), A		
;				
;	M2 CW			
	LD	A, 1		
	LD	(M2DIR), A		
	LD	HL, (PSPD1)		
	LD	(M2TIMER0), HL		
	LD	HL, 0FFFFH		
	LD	(M2TGT), HL		
	CALL	M2START		
;				
	LD	HL, 500		;WAIT
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	A, 0		
	LD	(M2FLG), A		
;				
	JP	RUNLP		
;				
;~~~				
RUN_C:				
	CALL	KEYPUSH		
	JP	AGINGMOD		
;		
;~~~~~~~~~~		
;		
;**************************************************		
;	***** PUMP SPEED SET MODE *****	
PSPDMOD:		
	LD	A, (PSPDFLG)
	CP	1
	JP	Z, PSPDLP01
	CP	2
	JP	Z, PSPDLP02
	CP	3
	JP	Z, PSPDLP03
;		
;		
PSPDLP01:		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 11010111B
	OUT	(DISP0), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 11111011B
	OUT	(DISP0), A
	LD	A, 10110000B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
	JP	PSPDLP
;		
;~~~~~~~~~~		
PSPDLP02:		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 11010111B
	OUT	(DISP0), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 11111011B
	OUT	(DISP0), A
	LD	A, 11101101B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
	JP	PSPDLP
;		
;~~~~~~~~~~		
PSPDLP03:		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 11010111B
	OUT	(DISP0), A
	LD	A, 10000100B
	OUT	(DISP0), A
	LD	A, 11111011B
	OUT	(DISP0), A
	LD	A, 11110101B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0		
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
;				
	JP	PSPDLP		
;				
;~~~~~~~~~~				
PSPDLP:				
	IN	A, (EIO4)		
	CP	SW_SELECT		
	JP	NZ, PSPDLP		
	JP	CH_PSPD		;SELECT_SW -> JMP
;				
;~~~~~~~~~~		
CH_PSPD:		
	CALL	KEYPUSH
CH_PSPDLP:		
	LD	HL, 50
	LD	(DELTGT), HL
	CALL	DELAY
	IN	A, (EIO4)
	AND	SW_SELECT
	JP	NZ, CH_PSPDLP
;		
	LD	A, (PSPDFLG)
	CP	1
	JP	Z, PSPD_1TO2
	CP	2
	JP	Z, PSPD_2TO3
	CP	3
	JP	Z, PSPD_3TO1
;		
;~~~~~		
PSPD_1TO2:		
	LD	A, 2
	LD	(PSPDFLG), A
	LD	HL, (PSPD2)
	LD	(PSPD), HL
;		
	CALL	RAM2ROMF
	JP	PSPDMOD
;		
;~~~~~		
PSPD_2TO3:		
	LD	A, 3
	LD	(PSPDFLG), A
	LD	HL, (PSPD3)
	LD	(PSPD), HL
;		
	CALL	RAM2ROMF
	JP	PSPDMOD
;		
;~~~~~		
PSPD_3TO1:		
	LD	A, 1
	LD	(PSPDFLG), A
	LD	HL, (PSPD1)
	LD	(PSPD), HL
;		
	CALL	RAM2ROMF
	JP	PSPDMOD
;		
;~~~~~~~~~~		
;		
;**************************************************		
;	***** POSITION HOSEI MODE *****	
;		
POSMOD:		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 10000000B
	OUT	(DISP0), A
	LD	A, 11101110B
	OUT	(DISP0), A
	LD	A, 11111011B
	OUT	(DISP0), A
	LD	A, 11010111B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
;;	LD	A, 10000001B
;;	OUT	(SIO1MD), A
;;;		
;;	IN	A, (SIO1MD)
;;	AND	01000000B		
;;	JP	NZ, L_POSMOD		
;				
;				
	LD	HL, 1000		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
POSMOD1:				
	CALL	SWSCAN		;START_SW MACHI
	LD	A, (SWVAL)		
	CP	'G'		
	JP	NZ, POSMOD1		
	CALL	KEYPUSH		
;				
;				
;		
;~~~~~~~~~~~~~~~		
POSMOD15:		
	CALL	M1GEN
;		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 10000000B
	OUT	(DISP0), A
	LD	A, 10000000B
	OUT	(DISP0), A
	LD	A, 11110111B
	OUT	(DISP0), A
	LD	A, 11011111B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
;		
POSMOD2:	;96 START MACHI	
	CALL	CHPLATE
;		
	CALL	SWSCAN
	LD	A, (SWVAL)
	CP	'G'
	JP	NZ, POSMOD2
;		
	CALL	KEYPUSH
;		
	CALL	CHPLATE
	LD	A, (PLATEFLG)
	AND	A
	JP	NZ, POSMOD15
;		
;==========;COVER OPEN		
	LD	A, 6
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	NZ, POSMOD21
	CALL	ALARM1
	JP	POSMOD15		
;==========				
;				
POSMOD21:				
	CALL	STA001		;PARAMETER SET
;				
	LD	HL, 7		;MOVE 7TH WELL
	LD	(WELL_SET), HL		
	LD	HL, (XSPD1)		
	LD	(M1SPD), HL		
	CALL	M1WELL		
;				
;~~~~~~~~~~~~~~~				
POS96LP:				
	LD	HL, 20		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	BC, (H_96)		
	LD	A, B		
	AND	10000000B		
	JP	NZ, POS96LP_1		
	LD	A, 0FH		;' '
	LD	(DIGIT1K), A		
	LD	HL, 0		
	ADD	HL, BC		;HL = ABS(H_96)
	JP	POS96LP_2		
POS96LP_1:				
	LD	A, 10		;'-'
	LD	(DIGIT1K), A		
	LD	HL, 0		
	AND	A		
	SBC	HL, BC		;HL = ABS(H_96)
POS96LP_2:				
;				
;				
	LD	DE, 100		
	CALL	WARIZ		;HL/DE->BC...HL
	LD	A, C		
	LD	(DIGIT100), A		
	LD	DE, 10		
	CALL	WARIZ		
	LD	A, C		
	LD	(DIGIT10), A		
	LD	A, L		
	LD	(DIGIT1), A		
	CALL	DISP7SEG		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'R'		;RESET SW
	JP	Z, POS96END		
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW
	CALL	NZ, POS96_P		
	BIT	4, A		;- SW
	CALL	NZ, POS96_M		
;				
	JP	POS96LP		
;				
POS96END:				
	CALL	KEYPUSH		
	CALL	RAM2ROMF		
;		
;~~~~~~~~~~~~~~~		
POSMOD25:		
	CALL	M1GEN
;		
	LD	A, 11111000B
	OUT	(DISP1), A
	LD	A, 10000000B
	OUT	(DISP0), A
	LD	A, 11110101B
	OUT	(DISP0), A
	LD	A, 11111111B
	OUT	(DISP0), A
	LD	A, 10110110B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
	LD	A, 0		
	OUT	(DISP0), A		
;				
POSMOD3:				
	CALL	CHPLATE		
;				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'G'		;START_SW ?
	JP	NZ, POSMOD3
;		
	CALL	KEYPUSH
;		
	CALL	CHPLATE
	LD	A, (PLATEFLG)
	AND	A
	JP	Z, POSMOD25
;		
;==========;COVER OPEN		
	LD	A, 6
	LD	(ALM1FLG), A
	IN	A, (EIO2)
	BIT	4, A
	JP	NZ, POSMOD31
	CALL	ALARM1
	JP	POSMOD25
;==========		
;		
;		
POSMOD31:		
	CALL	STA001
;		
	LD	HL, 13
	LD	(WELL_SET), HL
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	CALL	M1WELL
;		
;~~~~~~~~~~~~~~~		
POS384GOLP:		
	LD	HL, 20
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	BC, (H_38)		
	LD	A, B		
	AND	10000000B		
	JP	NZ, POS384GOLP_1		
	LD	A, 0FH		;' '
	LD	(DIGIT1K), A		
	LD	HL, 0		
	ADD	HL, BC		;HL = ABS(H_38)
	JP	POS384GOLP_2		
POS384GOLP_1:				
	LD	A, 10		;'-'
	LD	(DIGIT1K), A		
	LD	HL, 0		
	AND	A		
	SBC	HL, BC		;HL = ABS(H_38)
POS384GOLP_2:				
;				
;				
	LD	DE, 100		
	CALL	WARIZ		
	LD	A, C		
	LD	(DIGIT100), A		
	LD	DE, 10		
	CALL	WARIZ		
	LD	A, C		
	LD	(DIGIT10), A		
	LD	A, L		
	LD	(DIGIT1), A		
	CALL	DISP7SEG		
;				
	CALL	SWSCANF		
	LD	A, (SWVAL)		
	CP	'R'		;RESET SW
	JP	Z, POS384GOEND		
;				
	IN	A, (EIO4)		
	BIT	3, A		;+ SW
	CALL	NZ, POS384GO_P		
	BIT	4, A		;- SW
	CALL	NZ, POS384GO_M		
;				
	JP	POS384GOLP		
;				
POS384GOEND:				
	CALL	KEYPUSH		
	CALL	RAM2ROMF		
;				
;~~~~~~~~~~~~~~~				
	CALL	M1GEN		
	JP	POSMOD		
;				
;				
;~~~~~~~~~~~~~~~				
;~~~~~~~~~~				
POS96_P:				
	LD	HL, 20		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (H_96)		
	LD	BC, 300		;MAX HOSEI
	AND	A		
	SBC	HL, BC		
	RET	Z		;HOSEI MAX -> RET
;				
	LD	HL, (H_96)		
	INC	HL		
	LD	(H_96), HL		
;				
	LD	A, 0		
	LD	(M1DIR), A		
	LD	HL, (XSPD1)		
	LD	(M1SPD), HL		
	LD	HL, 1		;1 PLUSE IDOU
	LD	(M1TGT), HL		
	CALL	M1START		
POS96_PLP:				
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	NZ, POS96_PLP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	RET	
;		
;~~~~~~~~~~		
POS96_M:		
	LD	HL, 20
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (H_96)		
	LD	BC, -300		
	AND	A		
	SBC	HL, BC		
	RET	Z		;HOSEI MIN -> RET
;				
	LD	HL, (H_96)		
	DEC	HL		
	LD	(H_96), HL		
;				
	LD	A, 1		
	LD	(M1DIR), A		
	LD	HL, (XSPD1)		
	LD	(M1SPD), HL		
	LD	HL, 1		;1 PLUSE IDOU
	LD	(M1TGT), HL		
	CALL	M1START
POS96_MLP:		
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	NZ, POS96_MLP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	RET	
;		
;~~~~~~~~~~		
POS384GO_P:		
	LD	HL, 20
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	HL, (H_38)
	LD	BC, 300
	AND	A
	SBC	HL, BC
	RET	Z
;		
	LD	HL, (H_38)
	INC	HL
	LD	(H_38), HL
;		
	LD	A, 0
	LD	(M1DIR), A
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	LD	HL, 1
	LD	(M1TGT), HL
	CALL	M1START
POS384GO_PLP:		
	LD	HL, (M1TGT)
	LD	A, L
	OR	H
	JP	NZ, POS384GO_PLP
;		
	LD	A, 0
	LD	(M1FLG), A
;		
	RET	
;		
;~~~~~~~~~~		
POS384GO_M:		
	LD	HL, 20		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	LD	HL, (H_38)		
	LD	BC, -300		
	AND	A		
	SBC	HL, BC		
	RET	Z		;HOSEI MIN -> RET
;				
	LD	HL, (H_38)		
	DEC	HL		
	LD	(H_38), HL		
;				
	LD	A, 1		
	LD	(M1DIR), A		
	LD	HL, (XSPD1)		
	LD	(M1SPD), HL		
	LD	HL, 1		;1 PLUSE IDOU
	LD	(M1TGT), HL		
	CALL	M1START		
POS384GO_MLP:				
	LD	HL, (M1TGT)		
	LD	A, L		
	OR	H		
	JP	NZ, POS384GO_MLP		
;				
	LD	A, 0		
	LD	(M1FLG), A		
;				
	RET			
;				
;~~~~~~~~~~	
;~~~~~~~~~~	
;	
;~~~~~~~~~~~~~~~	

;	
;~~~~~~~~~~~~~~~	
;	
;~~~~~~~~~~	
;~~~~~~~~~~	
;	
;	
;**************************************************	
;	***** DEBUG MODE *****
;	
DEBUGMOD:	
;				
	LD	A, 10011110B		;MASK ENABLE
	OUT	(IMRH), A		;INTCTC1
	LD	A, 11110010B		
	OUT	(IMRL), A		
;				
	LD	A, 0000100B		;6.7mSEC
	OUT	(CTC1C), A		
	LD	HL, 256		
	LD	A, L		
	OUT	(CTC1), A		
	LD	A, H		
	OUT	(CTC1), A		
;				
	LD	A, 11111000B		
	OUT	(DISP1), A		
	LD	A, 11111110B
	OUT	(DISP0), A
	LD	A, 10001011B
	OUT	(DISP0), A
	LD	A, 11001110B
	OUT	(DISP0), A
	LD	A, 11111110B
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0
	OUT	(DISP0), A
	LD	A, 0		
	OUT	(DISP0), A		
;				
;				
	CALL	KEYPUSH		
;				
	LD	HL, 500		
	LD	(DELTGT), HL		
	CALL	DELAY		
;				
	CALL	BKUPRES		;BACK UP RESET
;				
	CALL	CHPLATE		
;				
DEBUGLP:				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'G'		;START SW?
	JP	Z, DEBUG_G		
	CP	'F'		;FEED SW?
	JP	Z, DEBUG_F		
	CP	'R'		;RESET SW?
	JP	Z, DEBUG_R		
	JP	DEBUGLP		
;				
;				
;~~~~~				
DEBUG_G:				
	CALL	KEYPUSH		
;				
	LD	HL, 150		
	LD	(DELTGT), HL		
	CALL	DELAY
;		
	CALL	CHPLATE
;		
	LD	A, 1
	LD	(BNFLG), A
;		
	LD	A, 0
	LD	(STASEQ), A
	CALL	START
;		
	LD	A, 0
	LD	(BNFLG), A
;		
	JP	DEBUGLP
;		
;~~~~~		
DEBUG_F:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	LD	A, 0
	LD	(M1DIR), A
	LD	HL, (XSPD1)
	LD	(M1SPD), HL
	LD	HL, 3907
	LD	(M1TGT), HL
	CALL	M1START
DEBUG_FLP1:		
	LD	HL, (M1TGT)		
	LD	A, L		
	OR	H		
	JP	NZ, DEBUG_FLP1		
;				
	LD	A, 0		
	LD	(M1FLG), A		
;				
DEBUG_FLP2:				
	CALL	SWSCAN		
	LD	A, (SWVAL)		
	CP	'R'		;RESET SW?
	JP	NZ, DEBUG_FLP2		
;				
	CALL	M1GEN		
;				
	JP	DEBUGLP
;		
;~~~~~		
DEBUG_R:		
	CALL	KEYPUSH
;		
	LD	HL, 150
	LD	(DELTGT), HL
	CALL	DELAY
;		
	CALL	M1GEN
;		
	JP	DEBUGLP
;		
;~~~~~;		
;~~~~~		
;		
;		
;		
;**************************************************		
;	***** MANUAL MODE *****	
MANMOD:		
	JP	$
;;		
;/*END MANCMDI*/		
;////////////////////////////////////////		
;		
;		
;**************************************************************		
;;;	ORG	0E000H
;	ORG	08000H
	DEFS	8000h - $
;*****? ???? 0CFFFH ??????????????? ?*****		
;////////////////////////////////////////		
;		
;////////////////////////////////////////		
;/**/		
;		
;/*END */		
;////////////////////////////////////////		
;		
;		
;**************************************************		
;	***** K3 RUTINE etc. *****	
;		
;////////////////////////////////////////		
;	PARAMETER LOAD	
;	E2PROM(40000H - 403FFH)	
;	   ? RAM(20000H - 203FFH) 	
;	   (1024 BYTE)	
;		
;	?DMA CH0 ???	
;		
;////////////////////////////////////////		
;/*ROM2RAM*/		
ROM2RAM:		
	LD	A, 00000000B
	OUT	(CR0), A
;		
	LD	HL, 0A00H
	LD	A, L
	OUT	(B_PAR0), A
	LD	A, H
	OUT	(B_PAR0), A
	LD	A, 04H
	OUT	(B_PAR0), A
;		
	LD	HL, 0500H
	LD	A, L
	OUT	(B_SAR0), A
	LD	A, H
	OUT	(B_SAR0), A
	LD	A, 02H
	OUT	(B_SAR0), A
;		
	LD	HL, 1024
	LD	A, L
	OUT	(B_BCR0), A
	LD	A, H
	OUT	(B_BCR0), A
;		
	LD	A, 00000000B
	OUT	(CR0), A
;		
;		
	LD	A, 10100000B
	OUT	(CR0), A
ROM2RAMLP:		
	IN	A, (SR0)
	AND	00000001B
	IN	A, (SR0)
	JP	NZ, ROM2RAMLP
;		
	LD	A, 10000000B
	OUT	(CR0), A
;		
	LD	A, 00H
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
;		
	RET	
;		
;/*END ROM2RAM*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	PARAMATER SAVE	
;	RAM(20000H - 203FFH) 	
;	   ? E2PROM(40000H - 403FFH)	
;	   (1024 BYTE)	
;		
;	?DMA CH0 ???	
;		
;////////////////////////////////////////		
;/*RAM2ROM*/		
RAM2ROM:		
	LD	A, 00000000B
	OUT	(CR0), A
;		
	LD	HL, 0500H
	LD	(PAR0BUF), HL
	LD	A, 02H
	LD	(PAR0BUF+2), A
;		
	LD	HL, 0A00H
	LD	(SAR0BUF), HL
	LD	A, 04H
	LD	(SAR0BUF+2), A
;		
	LD	A, 00000010B
	OUT	(CR0), A
;		
	LD	HL, 64
	LD	A, L
	OUT	(B_BCR0), A
	LD	A, H
	OUT	(B_BCR0), A
;		
	LD	A, 16
	LD	B, A
RAM2ROM2:		
	PUSH	BC
;		

	LD	HL, (PAR0BUF)
	LD	A, L
	OUT	(B_PAR0), A
	LD	A, H
	OUT	(B_PAR0), A
	LD	A, (PAR0BUF+2)
	OUT	(B_PAR0), A
;		
	LD	HL, (SAR0BUF)
	LD	A, L
	OUT	(B_SAR0), A
	LD	A, H
	OUT	(B_SAR0), A
	LD	A, (SAR0BUF+2)
	OUT	(B_SAR0), A
;		
;;		
	LD	A, 10100000B
	OUT	(CR0), A
;		
;;RAM2ROMLP1:		
;;	IN	A, (SR0)
;;	AND	00000001B
;;	IN	A, (SR0)
;;	JP	NZ, RAM2ROMLP1
;		
	IN	A, (C_PAR0)
	LD	(PAR0BUF+0), A
	IN	A, (C_PAR0)
	LD	(PAR0BUF+1), A
	IN	A, (C_PAR0)
	LD	(PAR0BUF+2), A
;		
	IN	A, (C_SAR0)
	LD	(SAR0BUF+0), A
	IN	A, (C_SAR0)
	LD	(SAR0BUF+1), A
	IN	A, (C_SAR0)
	LD	(SAR0BUF+2), A
;		
;		
	LD	HL, 7000
RAM2ROMLP2:		
	DEC	HL
	LD	A, L
	OR	H
	JP	NZ, RAM2ROMLP2
;		
	POP	BC
	DJNZ	RAM2ROM2
;		
	LD	A, 10000000B
	OUT	(CR0), A
;		
;;	LD	HL, 5000
;;RAM2ROMLP3:		
;;	DEC	HL
;;	LD	A, L
;;	OR	H
;;	JP	NZ, RAM2ROMLP3
;		
	LD	A, 00H
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
;		
	RET	
;		
;/*END RAM2ROM*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	PARAMATER SAVE (??? ???64BYTE??)	
;	RAM(20000H - 2003FH) 	
;	   ? E2PROM(40000H - 4003FH)	
;	   (64 BYTE)	
;		
;	?DMA CH0 ???	
;		
;	RAM TO ROM FAST	
;		
;////////////////////////////////////////		
;/*RAM2ROMF*/		
RAM2ROMF:		
	LD	A, 00000000B
	OUT	(CR0), A
;		
	LD	HL, 0500H
	LD	A, L
	OUT	(B_PAR0), A
	LD	A, H
	OUT	(B_PAR0), A
	LD	A, 02H
	OUT	(B_PAR0), A
;		
	LD	HL, 0A00H
	LD	A, L
	OUT	(B_SAR0), A
	LD	A, H
	OUT	(B_SAR0), A
	LD	A, 04H
	OUT	(B_SAR0), A
;		
	LD	A, 00000000B
	OUT	(CR0), A
;		
	LD	HL, 64
	LD	A, L
	OUT	(B_BCR0), A
	LD	A, H
	OUT	(B_BCR0), A
;		
;		
	LD	A, 10100000B
	OUT	(CR0), A
RAM2ROMFLP1:		
	IN	A, (SR0)
	AND	00000001B
	IN	A, (SR0)
	JP	NZ, RAM2ROMFLP1
;		
	LD	A, 10000000B
	OUT	(CR0), A
;		
	LD	HL, 10000
RAM2ROMFLP2:		
	DEC	HL
	LD	A, L
	OR	H
	JP	NZ, RAM2ROMFLP2
;		
	LD	A, 00H
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_PAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
	OUT	(B_SAR0), A
;		
	RET	
;		
;/*END RAM2ROMF*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ON	
;////////////////////////////////////////		
;/**/		
;		
;/*END */		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	K3 VOLUME TO PULSE(PUMP)	
;		
;	??:	PARA_VOL
;	?:	PPLS (3BYTE)
;////////////////////////////////////////		
;/*VOL2PLS*/		
VOL2PLS:		
;		
	LD	A, 0
	LD	(PPLS+0), A
	LD	(PPLS+1), A
	LD	(PPLS+2), A
;		
	LD	BC, 40
	AND	A
VOL2PLSLP:		
	LD	HL, (PPLS+0)
	LD	DE, (PARA_VOL+0)
	ADD	HL, DE
	LD	(PPLS+0), HL
;		
	LD	A, (PPLS+2)
	LD	E, 0
	ADC	A, E
	LD	(PPLS+2), A
;		
	DEC	BC
	LD	A, C
	OR	B
	JP	NZ, VOL2PLSLP
;		
;		
	RET	
;		
;/*END VOL2PLS*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	HEX(2 DIGIT) ? DEC(LOW 4 DIGIT)	
;		
;	?? :	K3_IN0 - K3_IN1
;	? :	K3_OUT0 - K3_OUT3
;////////////////////////////////////////		
;/*HEX2DEC*/		
HEX2DEC:		
	LD	HL, (K3_IN0)
;		
H2D1:		
	LD	DE, 1000
	LD	BC, 0
H2D1LP:		
	AND	A
	SBC	HL, DE
	JP	M, H2D2
	INC	BC
	JP	H2D1LP
;		
H2D2:		
	LD	A, C
	LD	(K3_OUT3), A
;		
	ADD	HL, DE
	LD	DE, 100
	LD	BC, 0
H2D2LP:		
	AND	A
	SBC	HL, DE
	JP	M, H2D3
	INC	BC
	JP	H2D2LP
;		
H2D3:		
	LD	A, C
	LD	(K3_OUT2), A
;		
	ADD	HL, DE
	LD	DE, 10
	LD	BC, 0
H2D3LP:		
	AND	A
	SBC	HL, DE
	JP	M, H2D4
	INC	BC
	JP	H2D3LP
;		
H2D4:		
	LD	A, C
	LD	(K3_OUT1), A
;		
	ADD	HL, DE
	LD	A, L
	LD	(K3_OUT0), A
;		
	RET	
;		
;		
;/*END HEX2DEC*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	HEX TO ASCII	
;	?MAX? 99999 = 1869F ???	
;		
;	??:	K3_IN2
;		K3_IN1
;		K3_IN0
;		
;	?:	K3_OUT4
;		K3_OUT3
;		K3_OUT2
;		K3_OUT1
;		K3_OUT0
;		
;	?cf. 10000(16) = 65536	
;		
;////////////////////////////////////////		
;/*HEX2ASC*/		
HEX2ASC:		
	LD	A, 0
	LD	(K3_OUT0), A
	LD	(K3_OUT1), A
	LD	(K3_OUT2), A
	LD	(K3_OUT3), A
	LD	(K3_OUT4), A
;		
H2A1:		
	LD	A, (K3_IN0)
	LD	(K3_IN10), A
	LD	A, (K3_IN1)
	LD	(K3_IN11), A
	LD	A, (K3_IN2)
	LD	(K3_IN12), A
;		
	LD	DE, 10000
	LD	(K3_IN13), DE
	LD	A, 0
	LD	(K3_IN15), A		
	LD	E, 0		
H2A1LP:				
	PUSH	DE		;????
	CALL	SBC3B		
	POP	DE		
	LD	A, (K3_OUT10)		
	LD	(K3_IN10), A		
	LD	A, (K3_OUT11)		
	LD	(K3_IN11), A		
	LD	A, (K3_OUT12)		
	LD	(K3_IN12), A		
	JP	M, H2A2		
;				
	INC	E		
	JP	H2A1LP		
;		
H2A2:		
	LD	A, E
	LD	(K3_OUT4), A
;		
	CALL	ADC3B
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
;		
;		
	LD	DE, 1000
	LD	(K3_IN13), DE
	LD	E, 0
H2A2LP:		
	PUSH	DE
	CALL	SBC3B
	POP	DE
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
	JP	M, H2A3
;		
	INC	E
	JP	H2A2LP
;		
;		
H2A3:		
	LD	A, E
	LD	(K3_OUT3), A
;		
	CALL	ADC3B
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
;		
;		
	LD	DE, 100
	LD	(K3_IN13), DE
	LD	E, 0
H2A3LP:		
	PUSH	DE
	CALL	SBC3B
	POP	DE
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
	JP	M, H2A4
;		
	INC	E
	JP	H2A3LP
;		
;		
H2A4:		
	LD	A, E
	LD	(K3_OUT2), A
;		
	CALL	ADC3B
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
;		
;		
	LD	DE, 10
	LD	(K3_IN13), DE
	LD	E, 0
H2A4LP:		
	PUSH	DE
	CALL	SBC3B
	POP	DE
	LD	A, (K3_OUT10)
	LD	(K3_IN10), A
	LD	A, (K3_OUT11)
	LD	(K3_IN11), A
	LD	A, (K3_OUT12)
	LD	(K3_IN12), A
	JP	M, H2A5
;		
	INC	E
	JP	H2A4LP
;		
;		
H2A5:		
	LD	A, E
	LD	(K3_OUT1), A
	CALL	ADC3B
	LD	A, (K3_OUT10)
	LD	(K3_OUT0), A
;		
;		
H2A6:		
	LD	E, '0'
	LD	A, (K3_OUT0)
	ADD	A, E
	LD	(K3_OUT0), A
	LD	A, (K3_OUT1)
	ADD	A, E
	LD	(K3_OUT1), A
	LD	A, (K3_OUT2)
	ADD	A, E
	LD	(K3_OUT2), A
	LD	A, (K3_OUT3)
	ADD	A, E
	LD	(K3_OUT3), A
	LD	A, (K3_OUT4)
	ADD	A, E
	LD	(K3_OUT4), A
;		
;		
	RET	
;		
;		
;/*END HEX2ASC*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ASCII TO HEX	
;		
;	??:	K3_IN4
;		K3_IN3
;		K3_IN2
;		K3_IN1
;		K3_IN0
;	?:	K3_OUT2
;		K3_OUT1 ;
;		K3_OUT0 ;
;		
;	?cf. 99999(10) = 1869F(16)	
;	       9999(10)  = 270F(16)	
;		
;////////////////////////////////////////		
;/*ASC2HEX*/		
ASC2HEX:		
	LD	A, 0
	LD	(K3_OUT0), A
	LD	(K3_OUT1), A
	LD	(K3_OUT2), A
	LD	HL, 0
;		
;9999????K3_OUT2???????????		
;		
A2H1:		
	LD	DE, 1
	LD	A, (K3_IN0)
	SUB	'0'
	JP	Z, A2H2
	LD	B, A
A2H1LP:		
	ADD	HL, DE
	DJNZ	A2H1LP
;		
;		
A2H2:		
	LD	DE, 10
	LD	A, (K3_IN1)
	SUB	'0'
	JP	Z, A2H3
	LD	B, A
A2H2LP:		
	ADD	HL, DE
	DJNZ	A2H2LP
;		
;		
A2H3:		
	LD	DE, 100
	LD	A, (K3_IN2)
	SUB	'0'
	JP	Z, A2H4
	LD	B, A
A2H3LP:		
	ADD	HL, DE
	DJNZ	A2H3LP
;		
;		
A2H4:		
	LD	DE, 1000
	LD	A, (K3_IN3)
	SUB	'0'
	JP	Z, A2H5
	LD	B, A
A2H4LP:		
	ADD	HL, DE
	DJNZ	A2H4LP
;		
;		
A2H5:		
	LD	DE, 10000
	LD	A, (K3_IN4)
	SUB	'0'
	JP	Z, A2H6
	LD	B, A
	LD	A, 0
A2H5LP:		
	ADD	HL, DE
	ADC	A, 0
	DJNZ	A2H5LP
;		
	LD	(K3_OUT2), A
;		
A2H6:		
	LD	(K3_OUT0), HL
;		
	RET	
;		
;/*END ASC2HEX*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	HL/DE->BC...HL	
;		

;////////////////////////////////////////		
;/*WARIZ*/		
WARIZ:		
	LD	BC,0
	OR	A
WARIZ1:		
	SBC	HL,DE
	JR	C,WARIZEND
	INC	BC
	JR	WARIZ1
WARIZEND:		
	ADD	HL,DE
	RET	
;		
;/*END WARIZ*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	HL * DE = HL	
;		

;////////////////////////////////////////		
;/*HLXDE*/		
HLXDE:		
	PUSH	HL
	POP	BC
	LD	HL, 0
	LD	A, 16
;		
HLXDE1:		
	SRL	D
	RR	E
	JP	NC, HLXDE2
	ADD	HL, BC
HLXDE2:		
	SLA	C
	RL	B
	DEC	A
	JP	NZ, HLXDE1
;		
	RET	
;		
;/*END HLXDE*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ADC K3 (3BYTE)	
;		
;	??:	K3_IN12
;		K3_IN11
;		K3_IN10
;		
;		K3_IN15
;		K3_IN14
;		K3_IN13
;		
;	?:	K3_OUT12 ;MSB
;		K3_OUT11 ;
;		K3_OUT10 ;LSB		
;				
;   K3_OUT12,11,10 = K3_IN12,11,10 + K3_IN15,14,13				

;				
;////////////////////////////////////////				
;/*ADC3B*/				
ADC3B:				
	LD	DE, K3_IN10		
	LD	HL, K3_IN13		
	LD	IX, K3_OUT10		
;				
	AND	A		
	LD	B, 3		;3BYTE
;				
ADC3BLP:				
	LD	A, (DE)		
	ADC	A, (HL)		;DE - HL
	LD	(IX+0), A		
;				
	INC	DE		
	INC	HL		
	INC	IX		
;				
	DJNZ	ADC3BLP		
;				
	RET			
;				
;				
;/*END ADC3B*/				
;////////////////////////////////////////				
;				
;		
;////////////////////////////////////////		
;	SBC K3 (3BYTE)	
;		
;	??:	K3_IN12
;		K3_IN11
;		K3_IN10
;		
;		K3_IN15
;		K3_IN14
;		K3_IN13
;		
;	?:	K3_OUT12 ;MSB
;		K3_OUT11 ;
;		K3_OUT10 ;LSB
;		
;   K3_OUT12,11,10 = K3_IN12,11,10 - K3_IN15,14,13				
;	?????????????			
;				
;////////////////////////////////////////				
;/*SBC3B*/				
SBC3B:				
	LD	DE, K3_IN10		
	LD	HL, K3_IN13		
	LD	IX, K3_OUT10		
;				
	AND	A		
	LD	B, 3		;3BYTE
;				
SBC3BLP:				
	LD	A, (DE)		
	SBC	A, (HL)		;DE - HL
	LD	(IX+0), A
;		
	INC	DE
	INC	HL
	INC	IX
;		
	DJNZ	SBC3BLP
;		
	RET	
;		
;		
;/*END SBC3B*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ABS (REG.A)	
;		

;		
;////////////////////////////////////////		
;/*ABSA*/		
ABSA:		
	PUSH	DE
;		
	BIT	7, A
	JP	Z, ABSAEND
	LD	E, A
;		
	LD	A, 0
	SUB	E
;		
ABSAEND:		
	POP	DE
;		
	RET	
;		
;/*END ABSA*/		
;////////////////////////////////////////		
;		
;		
;////////////////////////////////////////		
;	ABS (REG.HL)	
;		

;		
;////////////////////////////////////////		
;/*ABSHL*/		
ABSHL:				
	PUSH	AF		
	PUSH	DE		
;				
	BIT	7, H		
	JP	Z, ABSHLEND		
	PUSH	HL		;DE = HL
	POP	DE		
;				
	LD	HL, 0		
	AND	A		
	SBC	HL, DE		
;				
ABSHLEND:				
	POP	DE		
	POP	AF		
;	
	RET
;	
;/*END ABSHL*/	
;////////////////////////////////////////	
;	
;	
;////////////////////////////////////////	
;	ON
;////////////////////////////////////////	
;/**/	

;/*END */	
;////////////////////////////////////////	
;	
;	
;**************************************************		
;	***** INT PROG *****	
;		
;	+++++++ ????????? +++++++	
;		
INTP20:		;INT15
;INTCTC1:	;INT14	
;INTCTC0:	;INT13	
INTSPINT:	;INT12(HELC)	
INTRXINT:	;INT11(HELC)	
INTTXINT:	;INT10(HELC)	
INTEXINT:	;INT9(HELC)	
;INTRXRDY0:	;INT8(PC)	
INTTXRDY0:	;INT7	
INTSIO2:	;INT6(SYNC SIO)	
INTDMA1:	;INT5	
INTDMA0:	;INT4
;INTCTC3:	;INT3
;INTRXRDY1:	;INT2(STACKER)
INTTXRDY1:	;INT1
;INTCTC2:	;INT0
	DI
	NOP
;	
	EI
	NOP
	RETI
;	
;	
;	+++++++ CTC1 +++++++
;	
;SENSOR CHECK (DEBUG MODE ONLY)	
;6.7mSEC		
;		
INTCTC1:		
	DI	
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		
;		
;	;X HP CHECK	
;		
	IN	A, (EIO2)
	BIT	0, A
	JP	NZ, XHPOFF
;		
	LD	A, (BEIO3)		
	SET	4, A		;LED_96
	SET	5, A		;LED_384
	JP	XHP_LED		
XHPOFF:				
	LD	A, (BEIO3)		
	RES	4, A		
	RES	5, A		
XHP_LED:				
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
;				
;	;X EP CHECK			
;				
	IN	A, (EIO2)		
	BIT	1, A		
	JP	NZ, XEPOFF		
;				
	LD	A, (BEIO3)		
	SET	6, A		;LED_ALM1
	SET	7, A		;LED_ALM2
	JP	XEP_LED		
XEPOFF:				
	LD	A, (BEIO3)		
	RES	6, A		
	RES	7, A		
XEP_LED:				
	LD	(BEIO3), A		
	OUT	(EIO3), A		
;				
;				
;	;P HP CHECK			
;				
	IN	A, (EIO2)		
	BIT	2, A		
	JP	NZ, PHPOFF		
;				
	LD	A, (BPIO0)		
	SET	0, A		;LED_VOL
	JP	PHP_LED		
PHPOFF:				
	LD	A, (BPIO0)		
	RES	0, A		
PHP_LED:				
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
;				
;	;PLATE SENSOR CHECK			
;				
	IN	A, (EIO2)		
	BIT	3, A		
	JP	NZ, PLOFF		
;				
	LD	A, (BPIO0)		
	SET	1, A		;LED_PATTERN
	JP	PL_LED		
PLOFF:				
	LD	A, (BPIO0)		
	RES	1, A		
PL_LED:				
	LD	(BPIO0), A		
	OUT	(PIO0), A		
;				
;				
;	;COVER SENSOR CHECK			
;				
	IN	A, (EIO2)		
	BIT	4, A		
	JP	NZ, CVOFF		
;				
	LD	A, (BEIO3)		
	SET	0, A		;LED_PROG
	JP	CV_LED		
CVOFF:				
	LD	A, (BEIO3)		
	RES	0, A		
CV_LED:				
	LD	(BEIO3), A		
	OUT	(EIO3), A
;		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
;		
	EI	
	NOP	
	RETI	
;		
;		
;	+++++++ CTC0 +++++++	
;~~~~~		
;TIMER(150mSEC)		
;~~~~~		
INTCTC0:		
	DI	
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		
;~~~~~		
;STOP SW CHECK		
CTC0_1:		
	LD	A, (BNFLG)
	AND	A
	JP	Z, CTC0_2
;		
	LD	A, (STOPFLG)
	AND	A
	JP	NZ, CTC0_2
;		
	IN	A, (EIO4)
	BIT	6, A
	JP	Z, CTC0_2
;		
	LD	A, 1
	LD	(STOPFLG), A
	LD	(RDYFLG), A
;		
;		
;~~~~~		
;READY LED TENMETSU		
CTC0_2:		
	LD	A, (RDYFLG)
	AND	A
	JP	Z, CTC0_3
;		
	LD	HL, (RDYTIMER)
	LD	A, L
	OR	H
	JP	Z, RDYTIMRES
;		
	DEC	HL
	LD	(RDYTIMER), HL
	JP	CTC0_3
;		
;		
RDYTIMRES:		
	LD	A, (BEIO3)
	XOR	00000010B
	LD	(BEIO3), A
	OUT	(EIO3), A
;		
	LD	HL, (RDYTIMER0)
	LD	(RDYTIMER), HL
	JP	CTC0_3
;		
;~~~~~		
CTC0_3:		
;		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
;		
	EI	
	NOP	
	RETI	
;		
;		
;	+++++ RXRDY0 +++++	
;PC???		
INTRXRDY0:		
	DI	
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		


INTRX10:		
	IN	A, (SIO0MD)
	AND	00111000B
	JP	Z, INTRX20
;		
	JP	INTRX0ERR
;		

INTRX20:		
	LD	A, (RX0STXFLG)
	AND	A
	JP	NZ, INTRX40
;		


INTRX30:		
	IN	A, (SIO0DT)
	AND	01111111B
;		


	CP	02H
	JP	NZ, INTRX0END
;		


	LD	A, 1
	LD	(RX0STXFLG), A
;		
	LD	HL, 0
	LD	(RX0CNT), HL
;		
	JP	INTRX0END
;		
;		

INTRX40:		
;		

	IN	A, (SIO0DT)
	AND	01111111B
;		

	LD	HL, RX0BUF
	LD	DE, (RX0CNT)
	ADD	HL, DE
	LD	(HL), A
;		
	INC	DE
	LD	(RX0CNT), DE
;		

	LD	HL, 1024
	LD	DE, (RX0CNT)
	AND	A
	SBC	HL, DE
	JP	M, INTRX0ERR
;		
;		
; ETX????		
	CP	03H
	JP	Z, INTRX50
;		
	JP	INTRX0END
;		
;		

INTRX50:		
;      ?????		
	LD	A, 1
	LD	(RX0FLG), A
	LD	A, 0
	LD	(RX0STXFLG), A
;		
;		
;		

	LD	A, (RX0BUF)
	CP	'S'
	JP	Z, INTRX0S
	CP	'A'
	JP	Z, INTRX0A
;		
;		
	LD	A, (CMD0FLG)
	AND	A
	JP	NZ, INTRX0END
;		

	LD	HL, RX0BUF
	LD	DE, (RX0CNT)
	ADD	HL, DE
	LD	(HL), A
;		
	LD	HL, RX0BUF
	LD	DE, CMD0BUF
	LD	BC, 1024
	LDIR	
;		
	LD	A, 1
	LD	(CMD0FLG), A
	LD	A, 0
	LD	(RX0FLG), A
	LD	HL, 0
	LD	(FETCHPCCNT), HL ;????????0???
;		

	CALL	SOSIN0ACK
;		
	JP	INTRX0END
;		
;		
INTRX0ERR:		
	IN	A, (SIO0DT)
	LD	A, 00010101B
	OUT	(SIO0MD), A
	LD	A, 0
	LD	(RX0STXFLG), A
	JP	INTRX0END
;		
;		
INTRX0S:		
	LD	A, (CMDSFLG)
	XOR	1
	LD	(CMDSFLG), A
	JP	INTRX0END
;		
INTRX0A:		
	LD	A, (CMDSFLG)
	AND	A
	JP	Z, INTRX0END
	LD	A, 1
	LD	(CMDAFLG), A
	JP	INTRX0END
;		
;		
INTRX0END:		
;		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EI	
	NOP	
	RETI	
;		
;		
;	+++++++ CTC3 +++++++	
;~~~~~		


;~~~~~		
INTCTC3:		
	DI	
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		
;~~~~~		
;M1 TIMER 		
CTC3_10:		
	LD	A, (M1FLG)
	AND	A
	JP	Z, CTC3_20
;		
M1TIMRES:		
	LD	A, (BEIO2)
;		
;		
	RES	0, A
	OUT	(EIO2), A
;		
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX		
	PUSH	IX		
	POP	IX		
	PUSH	IX		
	POP	IX		
;				
	SET	0, A		;
	OUT	(EIO2), A		
;				
	LD	HL, (M1TGT)		
	DEC	HL		
	LD	(M1TGT), HL		
;				
	LD	A, (M1MODE)		
	CP	1		
	JP	Z, M1ACC		
	CP	2
	JP	Z, M1DEC
	JP	M1FIX
;		
;~~~		
M1ACC:		
	LD	HL, (M1TGT)
	LD	DE, (M1HTGT)
	AND	A
	SBC	HL, DE
	JP	NZ, M1ACC1
;		
	LD	A, 0
	LD	(M1MODE),A
;		
	JP	CTC3_30
;		
;		

M1ACC1:		
	LD	IX, ACCDATA
	LD	DE, (M1ACCNUM)
	ADD	IX, DE
	ADD	IX, DE
;		
	INC	DE
	LD	(M1ACCNUM), DE
;		
	LD	D, (IX+1)
	LD	E, (IX+0)
	LD	HL, (M1SPD)
	AND	A
	SBC	HL, DE
	JP	M, M1ACC2
;		
	LD	A, 0
	LD	(M1MODE), A
;		
	LD	DE, (M1SPD)
;		
M1ACC2:		
	LD	(MSPD), DE
	CALL	CHMSPD
;		
	JP	CTC3_30
;		
;~~~		
M1FIX:		
	LD	HL, (M1TGT)
	LD	DE, (M1ACCNUM)
;		
	AND	A
	SBC	HL, DE
	JP	NZ, M1FIX2
;		
;		
	LD	HL, (M1TGT)
	LD	A, H
	OR	L
	JP	Z, CTC3_30
;		
;		
	LD	A, 2
	LD	(M1MODE), A
;		
	LD	IX, ACCDATA
	LD	DE, (M1ACCNUM)
	DEC	DE
	ADD	IX, DE
	ADD	IX, DE
;		
	DEC	DE
	LD	(M1ACCNUM), DE
;		
	LD	D, (IX+1)
	LD	E, (IX+0)
	LD	(MSPD), DE
	CALL	CHMSPD
;		
;		
M1FIX2:		
	JP	CTC3_30
;		
;~~~		
M1DEC:		

	LD	IX, ACCDATA
	LD	DE, (M1ACCNUM)
	ADD	IX, DE
	ADD	IX, DE
;		
	DEC	DE
	LD	(M1ACCNUM), DE
;		
	LD	D, (IX+1)
	LD	E, (IX+0)
	LD	(MSPD), DE
	CALL	CHMSPD
;		
	JP	CTC3_30
;		
;		
;~~~~~		
;M2 TIMER		
CTC3_20:		
	LD	A, (M2FLG)
	AND	A
	JP	Z, CTC3_30
;		
M2TIMRES:		
	LD	A, (BEIO2)
	RES	2, A
	OUT	(EIO2), A
;		
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX
	PUSH	IX
	POP	IX
;		
	SET	2, A
	OUT	(EIO2), A
;		
	LD	HL, (M2TGT)
	DEC	HL
	LD	(M2TGT), HL
;		
	JP	CTC3_30
;		
;~~~~~		
CTC3_30:		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
;		
	EI	
	NOP	
	RETI	
;		
;		
;	+++++ RXRDY1 +++++	
;STACKER???		
INTRXRDY1:		
	DI	
	PUSH	AF
	PUSH	BC 
	PUSH	DE
	PUSH	HL
;		
;		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	EI	
	NOP	
	RETI	
;		
;		
;	+++++++ CTC2 +++++++	
;~~~~~		
;DELAY TIMER(1mSEC)		
;~~~~~		
INTCTC2:		
	DI	
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;		
	LD	A, (DELFLG)
	AND	A
	JP	Z, CTC2_1
;		
	LD	HL, (DELTGT)
	DEC	HL
	LD	(DELTGT), HL
;		

;		
CTC2_1:		
	POP	HL
	POP	DE
	POP	BC
	POP	AF
;		
	EI
	NOP
	RETI
;	
;	
;**************************************************	
;	***** STR DATA (SOSIN DATA) *****
;	'1234567890'
;	
STR_OK:	
 DEFM	'OK@'
;	
STR_E99:	
 DEFM	'E99@'
;	
STR_ERROR:	
 DEFM	'ERROR@'
;	
STR_VER:	
 DEFM	'2.5@'
;	
;	
;	
;**************************************************	
;	***** SPD DATA *****
;	
ACCDATA:	
;	
;	
;	
;**************************************************	
;	***** ZAHYO DATA *****
;	
;	
;??????	
WELL_96X:	
; DEFW	0
; DEFW	860,110,013,401,580,000,000,000,000,000,000,000,000
; DEFW	32,623,502
    defw    0000h
    defw    035ch
    defw    044ch
    defw    053ch
    defw    062ch
    defw    071dh
    defw    080dh
    defw    08fdh
    defw    09edh
    defw    0addh
    defw    0bceh
    defw    0cbeh
    defw    0daeh
;	
WELL_38X:	
; DEFW	0
; DEFW	800,092,010,401,160,000,000,000,000,000,000,000,000
; DEFW	2,002,212,222,422,360,000,000,000,000,000,000,000,000
; DEFW	3,204,332,434,443,560
    defw    0000h
    defw    0320h
    defw    0398h
    defw    0410h
    defw    0488h
    defw    0501h
    defw    0579h
    defw    05f1h
    defw    0669h
    defw    06e1h
    defw    075ah
    defw    07d2h
    defw    084ah
    defw    08c2h
    defw    093ah
    defw    09b3h
    defw    0a2bh
    defw    0aa3h
    defw    0b1bh
    defw    0b93h
    defw    0c0ch
    defw    0c84h
    defw    0cfch
    defw    0d74h
    defw    0dech
;	
WELL_L96X:	
; DEFW	0
; DEFW	1,130,137,016,101,850,000,000,000,000,000,000,000,000
; DEFW	35,323,772
    defw    0000h
    defw    046ah
    defw    055ah
    defw    064ah
    defw    073ah
    defw    082bh
    defw    091bh
    defw    0a0bh
    defw    0afbh
    defw    0bebh
    defw    0cdch
    defw    0dcch
    defw    0ebch
;	
WELL_L38X:	
; DEFW	0
; DEFW	1,060,118,013,001,420,000,000,000,000,000,000,000,000
; DEFW	2,262,238,225,022,620,000,000,000,000,000,000,000,000
; DEFW	3,464,358,437,043,820
    defw    0000h
    defw    0424h
    defw    049ch
    defw    0514h
    defw    058ch
    defw    0605h
    defw    067dh
    defw    06f5h
    defw    076dh
    defw    07e5h
    defw    085eh
    defw    08d6h
    defw    094eh
    defw    09c6h
    defw    0a3eh
    defw    0ab7h
    defw    0b2fh
    defw    0ba7h
    defw    0c1fh
    defw    0c97h
    defw    0d10h
    defw    0d88h
    defw    0e00h
    defw    0e78h
    defw    0ef0h
;	
;	
;	
;	
;**************************************************		
;	***** ROM MONITOR AREA *****	
;	   7600H - 7FFFH	
;	????????	
;**************************************************		
;		
;		
;		
;	//////////////////////////////////////	
;		
;		sub. lib.
;		
;	//////////////////////////////////////	
;		
;		
;	+++++++ BACKUP RAM AREA +++++++	
;	(0D000H - 0D3FFH : 1024BYTE)	
;		
;	ORG	0D500H
	DEFS	0d500h - $
;		
EEPROM:		
BKUPFLG:	DEFS	1

;		
MODEFLG:	DEFS	1
;		
;		
;//PUMP SPEED		
PSPDFLG:	DEFS	1
;		
;		
PSPD:	DEFS	2
;		
;//????????		
H_96:	DEFS	2
H_38:	DEFS	2
;		
;		
;----------?RAM2ROMF????----------		
;--------------------------------------		
;		
;	ORG	0D540H
	DEFS	0d540h - $
;		
PARA:		
PARA_VOL:	DEFS	2
PARA_PAT:	DEFS	24
;		
;;;;;;;;;;;		
;PARAXX???		
; VOL    - 2 BYTE (2 - 2000)		
; PAT    - 1 BYTE (0:NO GO / 1:GO)		
;	|	
; PAT+23 - 1 BYTE (0:NO GO / 1:GO)		
;		
;;;;;;;;;;;		
;		
;		
;96????		
PARA00:	DEFS	26
PARA01:	DEFS	26
PARA02:	DEFS	26
PARA03:	DEFS	26
PARA04:	DEFS	26
PARA05:	DEFS	26
PARA06:	DEFS	26
PARA07:	DEFS	26
PARA08:	DEFS	26
PARA09:	DEFS	26
;384????		
PARA10:	DEFS	26
PARA11:	DEFS	26
PARA12:	DEFS	26
PARA13:	DEFS	26
PARA14:	DEFS	26
PARA15:	DEFS	26
PARA16:	DEFS	26
PARA17:	DEFS	26
PARA18:	DEFS	26
PARA19:	DEFS	26
;		
;----------?RAM2ROM ????----------		
;--------------------------------------		
;		
;	+++++++ RAM AREA +++++++	
;		
;	ORG	0DA00H
        DEFS    0DA00H - $
;		
;//PARALLEL PORT		
BPIO0:	DEFS	1
BPIO1:	DEFS	1
BPIO2:	DEFS	1
BPIO3:	DEFS	1
BPIO4:	DEFS	1
BEIO0:	DEFS	1
BEIO1:	DEFS	1
BEIO2:	DEFS	1
BEIO3:	DEFS	1
BEIO4:	DEFS	1
;		
;//PATTERN		
PAT_BUF:	DEFS	2
;		
;//PROG		
PROG_NUM:	DEFS	2
;		
;//DISP7SEG,DISP7SEG2		
DIGIT1K:	DEFS	1
DIGIT100:	DEFS	1
DIGIT10:	DEFS	1
DIGIT1:	DEFS	1
;		
;//CHPLATE		
PLATEFLG:	DEFS	1
STA_HOLE:	DEFS	2
END_HOLE:	DEFS	2
STA_PROG:	DEFS	2
END_PROG:	DEFS	2
;		
;//SWSCAN		
SWVAL:	DEFS	1
;		
;//CNTDELAY		
PUSH_CNT:	DEFS	2
CNT_CNT:	DEFS	2
CNT_TGTL:	DEFS	2
CNT_TGTH:	DEFS	2
;		
;//KEYPUSH		
KPBUF0:	DEFS	1
KPBUF1:	DEFS	1
KPBUF2:	DEFS	1
;		
;//STACKER CONNECT ?		
STCONFLG:	DEFS	1
;		
;//GENTEN		
GENSEQ:	DEFS	1
HPHOSEI:	DEFS	2

RDYFLG:	DEFS	1
RDYTIMER0:	DEFS	2
RDYTIMER:	DEFS	2
;		
;//START		
STASEQ:	DEFS	1
PAT_NUM:	DEFS	2
PWAIT1:	DEFS	2
PWAIT2:	DEFS	2
XSTEPBUF:	DEFS	2
XSTART:	DEFS	2
XEND:	DEFS	2
XSTEP:	DEFS	2
XSTART0A:	DEFS	2
XSTEP0A:	DEFS	2
XSTART0B:	DEFS	2
XSTEP0B:	DEFS	2
XEND0B:	DEFS	2
BNFLG:	DEFS	1
		
VOLMAX:	DEFS	2
VOLMIN:	DEFS	2
;		
;		
;//FEED,RETURN		
FEEDFLG:	DEFS	1
;		
;		
;//LSTA		
LSTASEQ:	DEFS	1
PWAIT3:	DEFS	2
PWAIT4:	DEFS	2
L_XSTART0A:	DEFS	2
L_XSTEP0A:	DEFS	2
L_XSTART0B:	DEFS	2
L_XSTEP0B:	DEFS	2
L_XEND0B:	DEFS	2
;		
;//LFD,LBK		
LFDSEQ:	DEFS	1
;		
;//DELAY		
DELFLG:	DEFS	1
DELTGT:	DEFS	2
;		
;		
;//M1 KANREN		
M1FLG:	DEFS	1
M1SPD:	DEFS	2
M1DIR:	DEFS	1
M1TGT:	DEFS	2
M1HTGT:	DEFS	2
M1TIMER0:	DEFS	2
M1TIMER:	DEFS	2
XSPD1:	DEFS	2
XSPD2:	DEFS	2
M1MODE:	DEFS	1
;		
;		
M1ACCNUM:	DEFS	2
;		
;//M2 KANREN		
M2FLG:	DEFS	1
M2DIR:	DEFS	1
M2TGT:	DEFS	3
M2TIMER0:	DEFS	2
M2TIMER:	DEFS	2
PSPD1:	DEFS	2
PSPD2:	DEFS	2
PSPD3:	DEFS	2
M2SPD:	DEFS	2
;		
;//STOP1, STOP2		
STOPFLG:	DEFS	1
;		
;//VOL2PLS		
PPLS:	DEFS	3
;		
;//ROM2RAM		
PAR0BUF:	DEFS	3
SAR0BUF:	DEFS	3
PAR1BUF:	DEFS	3
SAR1BUF:	DEFS	3
;		
;		
;//K3?		
K3_IN0:	DEFS	1
K3_IN1:	DEFS	1
K3_IN2:	DEFS	1
K3_IN3:	DEFS	1
K3_IN4:	DEFS	1
K3_IN5:	DEFS	1
K3_OUT0:	DEFS	1
K3_OUT1:	DEFS	1
K3_OUT2:	DEFS	1
K3_OUT3:	DEFS	1
K3_OUT4:	DEFS	1
K3_OUT5:	DEFS	1
;		
;//K3?????		
K3_IN10:	DEFS	1
K3_IN11:	DEFS	1
K3_IN12:	DEFS	1
K3_IN13:	DEFS	1
K3_IN14:	DEFS	1
K3_IN15:	DEFS	1
K3_OUT10:	DEFS	1
K3_OUT11:	DEFS	1
K3_OUT12:	DEFS	1
K3_OUT13:	DEFS	1
K3_OUT14:	DEFS	1
K3_OUT15:	DEFS	1
;		
;//ALARM1		
ALM1FLG:	DEFS	1
;		
;//ALARM2		
ALM2FLG:	DEFS	1
;		
;//ALARM3		
ERRFLG:	DEFS	1
STACKFLG:	DEFS	1
;		
;//MOVE		
MVSEQNO:	DEFS	1
MVDIR:	DEFS	1
MVRATE0:	DEFS	1
MVRATE1:	DEFS	1
MVRATE2:	DEFS	1
MVRATE3:	DEFS	1
MVRATE4:	DEFS	1
NUMRECOM1:	DEFS	2
NUMRECOM2:	DEFS	2
NUMRECOM3:	DEFS	2
;		
;//CMD1		
CMD1SEQNO:	DEFS	1
;		
;//SOSIN1,SOSIN6,SOSIN7		
SOSINBF0:	DEFS	1
SOSINBF1:	DEFS	1
SOSINBF2:	DEFS	1
SOSINBF3:	DEFS	1
SOSINBF4:	DEFS	1
SOSINBF5:	DEFS	1
SOSINBF6:	DEFS	1
SOSINBF7:	DEFS	1
;		
;//TOUT		
TOUTFLG:	DEFS	1
TOUT_C:	DEFS	2
;		
;//FETCH(OLD)		
CMDBF00:	DEFS	1
CMDFLG:	DEFS	1
RECBF00:	DEFS	1
RECBF0:	DEFS	1
RECBF1:	DEFS	1
RECBF2:	DEFS	1
RECBF3:	DEFS	1
RECBF4:	DEFS	1
RECBF5:	DEFS	1
RECBF6:	DEFS	1
RECBF7:	DEFS	1
LENGTH:	DEFS	2
;		
;//AGING MODE		
AGINGFLG:	DEFS	1
;		
;//RXRDY		
RX0FLG:	DEFS	1
RX0BUF:	DEFS	1024
RX0STXFLG:	DEFS	1
RX0CNT:	DEFS	2
CMD0BUF:	DEFS	1024
CMD0FLG:	DEFS	1
;		
;		
;//?????		
NOW_X:	DEFS	2
NOW_Y:	DEFS	1
NOW_WELL:	DEFS	2
;		
;		
;//SOSIN		
SOSIN0CNT:	DEFS	2
SOSIN0NUM:	DEFS	1
SOSIN0BUF:	DEFS	100
;		
;		
;//FETCH		
FETCHPCCNT:	DEFS	2
;		
;		
;//????		
ZAHYO_SET1:	DEFS	2
WELL_SET:	DEFS	2
WELL_ADR:	DEFS	2
;		
;		
;//??????????		
D_96:	DEFS	2
D_38:	DEFS	2
;		
;//		
MSPD:	DEFS	2
;		
;//S,A ????		
CMDSFLG:	DEFS	1
CMDAFLG:	DEFS	1
;		
;//COM ????/????		
PCFLG:	DEFS	1
;		
;		END	
;	
 DEFS	10000h - $

#end