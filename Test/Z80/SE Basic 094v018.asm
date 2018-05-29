
; **************************************************************************
; **  An assembly file listing to generate a 16K ROM for the ZX Spectrum  **
; **************************************************************************

; THE "SINCLAIR EXTENDED BASIC" ROM
; modified by Andrew Owen

; Copyright (C) 1982-1987 Amstrad PLC

; -------------------------
; Last updated: 20-DEC-2004
; Release 0.94 Version 0.18
; -------------------------

; Note. The Sinclair Interface 1 ROM calls numerous routines in this ROM.
; Non-standard entry points have a label beginning with X.
; This is not compatible with the Opus Discovery Disk Interface which can
; only really work with the Original ROM.

; ZASM cross-assembler directives. (comment out for TASM)

#target	rom			; declare target file format as binary.

; TASM cross-assembler directives. (uncomment by removing ';')

;#define	DEFB	.BYTE      
;#define	DEFW	.WORD
;#define	DEFM	.TEXT
;#define	DEFS	.BLOCK
;#define	ORG	.ORG
;#define	EQU	.EQU
;#define	equ	.EQU

;******************************
;** Part 0. SYSTEM VARIABLES **
;******************************

; ----------------------
; THE 'SYSTEM VARIABLES'
; ----------------------
; X - The variables should not be POKEd because the system might crash.
; N - POKEing the variable will have no lasting effect.
; Addresses are given in IY offsets and decimal, length in decimal.

SCREEN_0	equ	$4000		;          16384  6144
ATTR_0	equ	SCREEN_0 + 6144	;          22528  768
UDGDEF	equ	ATTR_0 + 768	;          23296  168
T_STACK	equ	UDGDEF + 168	;          23464  88

KSTATE	equ	T_STACK + 88	; (IY-3A)  23552  N8
KSTATE_0	equ	KSTATE		; (IY-3A)  23552  N4
KSTATE_4	equ	KSTATE + 4	; (IY-36)  23556  N4
LAST_K	equ	KSTATE + 8	; (IY-32)  23560  N1
REPDEL	equ	LAST_K + 1	; (IY-31)  23561  1
REPPER	equ	REPDEL + 1	; (IY-30)  23562  1
DEFADD	equ	REPPER + 1	; (IY-2F)  23563  N2
DEFADD_H	equ	DEFADD + 1	; (IY-2E)  23564  N1
K_DATA	equ	DEFADD + 2	; (IY-2D)  23565  N1
TVDATA	equ	K_DATA + 1	; (IY-2C)  23566  N2
TVDATA_L	equ	TVDATA		; (IY-2C)  23566  N1
TVDATA_H	equ	TVDATA + 1	; (IY-2B)  23567  N1
STRMS	equ	TVDATA + 2	; (IY-2A)  23568  X38
STRMS_FD	equ	STRMS		; (IY-2A)  23568  X2
STRMS_FE	equ	STRMS + 2	; (IY-28)  23570  X2
STRMS_FF	equ	STRMS + 4	; (IY-26)  23572  X2
STRMS_00	equ	STRMS + 6	; (IY-24)  23574  X2
STRMS_01	equ	STRMS + 8	; (IY-22)  23576  X2
STRMS_02	equ	STRMS + 10	; (IY-20)  23578  X2
STRMS_03	equ	STRMS + 12	; (IY-1E)  23580  X2
STRMS_04	equ	STRMS + 14	; (IY-1C)  23582  X2
STRMS_05	equ	STRMS + 16	; (IY-1A)  23584  X2
STRMS_06	equ	STRMS + 18	; (IY-18)  23586  X2
STRMS_07	equ	STRMS + 20	; (IY-16)  23588  X2
STRMS_08	equ	STRMS + 22	; (IY-14)  23590  X2
STRMS_09	equ	STRMS + 24	; (IY-12)  23592  X2
STRMS_10	equ	STRMS + 26	; (IY-10)  23594  X2
STRMS_11	equ	STRMS + 28	; (IY-0E)  23596  X2
STRMS_12	equ	STRMS + 30	; (IY-0C)  23598  X2
STRMS_13	equ	STRMS + 32	; (IY-0A)  23600  X2
STRMS_14	equ	STRMS + 34	; (IY-08)  23602  X2
STRMS_15	equ	STRMS + 36	; (IY-06)  23604  X2
CHARS	equ	STRMS + 38	; (IY-04)  23606  2
RASP	equ	CHARS + 2	; (IY-02)  23608  1
PIP	equ	RASP + 1		; (IY-01)  23609  1
ERR_NR	equ	PIP + 1		; (IY+00)  23610  1
FLAGS	equ	ERR_NR + 1	; (IY+01)  23611  X1
TV_FLAG	equ	FLAGS + 1	; (IY+02)  23612  X1
ERR_SP	equ	TV_FLAG + 1	; (IY+03)  23613  X2
LIST_SP	equ	ERR_SP + 2	; (IY+05)  23615  N2
MODE	equ	LIST_SP + 2	; (IY+07)  23617  N1
NEWPPC	equ	MODE + 1		; (IY+08)  23618  2
NSPPC	equ	NEWPPC + 2	; (IY+0A)  23620  1
PPC	equ	NSPPC + 1	; (IY+0B)  23621  2
SUBPPC	equ	PPC + 2		; (IY+0D)  23623  1
BORDCR	equ	SUBPPC + 1	; (IY+0E)  23624  1
E_PPC	equ	BORDCR + 1	; (IY+0F)  23625  2
E_PPC_H	equ	E_PPC + 1	; (IY+10)  23626  1
VARS	equ	E_PPC + 2	; (IY+11)  23627  X2
DEST	equ	VARS + 2		; (IY+13)  23629  N2
CHANS	equ	DEST + 2		; (IY+15)  23631  X2
CURCHL	equ	CHANS + 2	; (IY+17)  23633  X2
PROG	equ	CURCHL + 2	; (IY+19)  23635  X2
NXTLIN	equ	PROG + 2		; (IY+1B)  23637  X2
DATADD	equ	NXTLIN + 2	; (IY+1D)  23639  X2
E_LINE	equ	DATADD + 2	; (IY+1F)  23641  X2
K_CUR	equ	E_LINE +2	; (IY+21)  23643  2
CH_ADD	equ	K_CUR + 2	; (IY+23)  23645  X2
X_PTR	equ	CH_ADD + 2	; (IY+25)  23647  2
WORKSP	equ	X_PTR + 2	; (IY+27)  23649  X2
STKBOT	equ	WORKSP + 2	; (IY+29)  23651  X2
STKEND	equ	STKBOT + 2	; (IY+2B)  23653  X2
STKEND_H	equ	STKEND + 1	; (IY+2C)  23654  X1
BREG	equ	STKEND + 2	; (IY+2D)  23655  N1
MEM	equ	BREG + 1		; (IY+2E)  23656  N2
FLAGS2	equ	MEM + 2		; (IY+30)  23658  1
DF_SZ	equ	FLAGS2 + 1	; (IY+31)  23659  X1
S_TOP	equ	DF_SZ + 1	; (IY+32)  23660  2
OLDPPC	equ	S_TOP + 2	; (IY+34)  23662  2
OSPPC	equ	OLDPPC + 2	; (IY+36)  23664  1
FLAGX	equ	OSPPC + 1	; (IY+37)  23665  N1
STRLEN	equ	FLAGX + 1	; (IY+38)  23666  N2
T_ADDR	equ	STRLEN + 2	; (IY+3A)  23668  N2
SEED	equ	T_ADDR + 2	; (IY+3C)  23670  2
FRAMES	equ	SEED + 2		; (IY+3E)  23672  3
UDG	equ	FRAMES + 3	; (IY+41)  23675  2
COORDS	equ	UDG + 2		; (IY+43)  23677  2
COORD_X	equ	COORDS		; (IY+43)  23677  1
COORD_Y	equ	COORDS + 1	; (IY+44)  23678  1
NMIADD	equ	COORDS + 2	; (IY+45)  23679  1
USER	equ	NMIADD + 2	; (IY+47)  23681  1
ECHO_E	equ	USER + 1		; (IY+48)  23682  2
DF_CC	equ	ECHO_E + 2	; (IY+4A)  23684  2
DF_CCL	equ	DF_CC + 2	; (IY+4C)  23686  2
S_POSN	equ	DF_CCL + 2	; (IY+4E)  23688  X2
S_POSN_H	equ	S_POSN + 1	; (IY+4F)  23689  X1
SPOSNL	equ	S_POSN + 2	; (IY+50)  23690  X2
SPOSNL_H	equ	SPOSNL + 1	; (IY+51)  23689  X1
SCR_CT	equ	SPOSNL + 2	; (IY+52)  23692  1
ATTR_P	equ	SCR_CT + 1	; (IY+53)  23693  1
MASK_P	equ	ATTR_P + 1	; (IY+54)  23694  1
ATTR_T	equ	MASK_P + 1	; (IY+55)  23695  N1
MASK_T	equ	ATTR_T + 1	; (IY+56)  23696  N1
P_FLAG	equ	MASK_T + 1	; (IY+57)  23697  1
MEMBOT	equ	P_FLAG + 1	; (IY+58)  23698  N30
MEM_0	equ	MEMBOT		; (IY+58)  23698  N5
MEM_1	equ	MEMBOT + 5	; (IY+5D)  23703  N5
MEM_2	equ	MEMBOT + 10	; (IY+62)  23708  N5
MEM_3	equ	MEMBOT + 15	; (IY+67)  23713  N5
MEM_4	equ	MEMBOT + 20	; (IY+6C)  23718  N5
MEM_5	equ	MEMBOT + 25	; (IY+71)  23723  N5
IF1TXT	equ	MEMBOT + 30	; (IY+76)  23728  X2
RAMTOP	equ	IF1TXT + 2	; (IY+78)  23730  2
P_RAMT	equ	RAMTOP + 2	; (IY+7A)  23732  2

CHANNELS	equ	P_RAMT + 2	; (IY+7C)  23734

SCREEN_1	equ	SCREEN_0 + 8192	;          24576  6144
ATTR_1	equ	SCREEN_1 + 6144	;          30720  768

;*****************************************
;** Part 1. RESTART ROUTINES AND TABLES **
;*****************************************

; -----------
; THE 'START'
; -----------
; At switch on, the Z80 chip is in Interrupt Mode 0.
; The Spectrum uses Interrupt Mode 1.
; This location can also be 'called' to reset the machine.
; Typically with PRINT USR 0.

#code	rom,0,$4000			; declare code segment.
;	ORG	$0000
NEW:
START:	DI			; Disable Interrupts.
	XOR	A		; Signal coming from START.
	LD	DE,$FFFF		; Set pointer to top of possible physical RAM.
	LD	(DE),A		; Set the top byte of physical RAM to $00.
	JR	START_2		; Jump forward to continue.

; -------------------
; THE 'ERROR' RESTART
; -------------------
; The error pointer is made to point to the position of the error to enable
; the editor to highlight the error position if it occurred during syntax
; checking.  It is used at 37 places in the program.  An instruction fetch
; on address $0008 may page in a peripheral ROM such as the Sinclair
; Interface 1 or Disciple Disk Interface.  This was not an original design
; concept and not all errors pass through here.

	ORG	$0008
ERROR_1:	LD	HL,(CH_ADD)	; Fetch the character address.
	LD	(X_PTR),HL	; Copy it to the error pointer.
	JR	ERROR_2		; Forward to continue.

; -----------------------------
; THE 'PRINT CHARACTER' RESTART
; -----------------------------
; The A register holds the code of the character that is to be sent to
; the output stream of the current channel.  The alternate register set is
; used to output a character in the A register so there is no need to
; preserve any of the current main registers (HL, DE, BC).
; This restart is used 21 times.

	ORG	$0010
PRINT_A:	JP	PRINT_A_2	; Jump forward to continue.

; ---

;;;	DEFB	$FF, $FF, $FF	; Five previously unused locations.
;;;	DEFB	$FF, $FF		;

; Often the accumulator is set to zero to print the first message.
; This routine saves three bytes of ROM code in the new section.

PO_MSG0:	XOR	A		; Print the first message.
	JP	PO_MSG		; Jump forward to the PO-MSG routine

	DEFB	$13		; 1 unused byte. (version)

; -------------------------------
; THE 'COLLECT CHARACTER' RESTART
; -------------------------------
; The contents of the location currently addressed by CH_ADD are fetched.
; A return is made if the value represents a character that has
; relevance to the BASIC parser. Otherwise CH_ADD is incremented and the
; tests repeated. CH_ADD will be addressing somewhere -
; 1) in the BASIC program area during line execution.
; 2) in workspace if evaluating, for example, a string expression.
; 3) in the edit buffer if parsing a direct command or a new BASIC line.
; 4) in workspace if accepting input but not that from INPUT LINE.

	ORG	$0018
GET_CHAR:LD	HL,(CH_ADD)	; fetch the address.
	LD	A,(HL)		; use it to pick up current character.

	ORG	$001C
TEST_CHAR:
	CALL	SKIP_OVER	; tests if the character is relevant.
	RET	NC		; Return if it is significant.

; ------------------------------------
; THE 'COLLECT NEXT CHARACTER' RESTART
; ------------------------------------
; As the BASIC commands and expressions are interpreted, this routine is
; called repeatedly to step along the line.  It is used 83 times.

	ORG	$0020
NEXT_CHAR:
	CALL	CH_ADD_P1	; fetches the next immediate character.
	JR	TEST_CHAR	; jump back until a valid character is found.

; ------------------
; THE 'START 2' JUMP
; ------------------
;  The continuation of START.

START_2:	JP	TEST_16K		; Jump forward to continue.

; -----------------------
; THE 'CALCULATE' RESTART
; -----------------------
; This restart enters the Spectrum's internal, floating-point, stack-based,
; FORTH-like language.
; It is further used recursively from within the calculator.
; It is used on 77 occasions.

	ORG	$0028
FP_CALC:	JP	CALCULATE	; jump forward.

; ---

	DEFB	$FF, $FF, $FF	; 5 previously unused bytes
	DEFB	$FF, $FF		;

; ------------------------------
; THE 'CREATE BC SPACES' RESTART
; ------------------------------
; This restart is used on only 12 occasions to create BC spaces
; between workspace and the calculator stack.

	ORG	$0030
BC_SPACES:
	PUSH	BC		; Save number of spaces.
	LD	HL,(WORKSP)	; Fetch  address of workspace.
	PUSH	HL		; Save it.
	JP	RESERVE		; Jump forward to continue.

; --------------------------------
; THE 'MASKABLE INTERRUPT' ROUTINE
; --------------------------------
; This routine increments the Spectrum's three-byte FRAMES counter fifty
; times a second (sixty times a second in the USA ).
; Both this routine and the called KEYBOARD subroutine use the IY register
; to access system variables and flags so a user-written program must
; disable interrupts to make use of the IY register.

	ORG	$0038
MASK_INT:PUSH	AF		; Save the registers that will be used but not
	PUSH	HL		; the IY register unfortunately.
	LD	HL,(FRAMES)	; Fetch the first two bytes at FRAMES1.
	INC	HL		; Increment lowest two bytes of counter.
	LD	(FRAMES),HL	; Place back in FRAMES1.
	LD	A,H		; Test if the result was zero.
	OR	L		;
	JR	NZ,KEY_INT	; Forward, if not, to KEY-INT
	INC	(IY+$40)		; otherwise increment FRAMES3 the third byte.

; While it is possible to rewrite this routine to avoid using the IY
; register, this causes incompatibility with a large number of existing
; programs. A solution is to use the following code in RAM with interrupt
; mode 2 active.

; IM2_MASK_INT:
;	PUSH	AF		; Save the registers that will be used.
;	PUSH	HL		;
;	LD	HL,$5B78		; Fetch the first two bytes at FRAMES1.
;	INC	(HL)		; Increment low byte of counter.
;	JR	NZ,$0048		; Forward, if not back to zero, to KEY_INT.
;	INC	L		; Increment address using 4 clock cycles.
;	INC	(HL)		; Increment middle counter.
;	JR	NZ,KEY_INT	; Forward, if not back to zero, to KEY_INT.
;	INC	L		; All FRAMES addresses have same high byte.
;	INC	(HL)		; Increment last counter.
;	JP	$0048		; Jump to KEY-INT and continue as normal.

; Now save the rest of the main registers and read and decode the keyboard.

	ORG	$0048
KEY_INT:	PUSH	BC		; Save the other main registers.
	PUSH	DE		;
	CALL	KEYBOARD		; executes a stage in the
				; process of reading a key-press.
	POP	DE		;
	POP	BC		; Restore registers.
	POP	HL		;
	POP	AF		;
	EI			; Enable Interrupts.
	RET			; Return.

; ---------------------
; THE 'ERROR-2' ROUTINE
; ---------------------
; A continuation of the code at ERROR_1.
; The error code is stored and after clearing down stacks, an indirect jump
; is made to MAIN_4, etc. to handle the error.

	ORG	$0053
ERROR_2:	POP	HL		; drop the return address - the location
				; after the RST 08H instruction.
	LD	L,(HL)		; fetch the error code that follows.
				; (nice to see this instruction used.)

; Note. this entry point is used when out of memory at REPORT_4.
; The L register has been loaded with the report code but X_PTR is not
; updated.

#assert $==$0055
;	ORG	$0055
ERROR_3:	LD	(IY+$00),L	; Store it in the system variable ERR_NR.
	LD	SP,(ERR_SP)	; points to an error handler on the machine
				; stack. There may be a hierarchy of routines.
				; To MAIN_4 initially at base.
				; or REPORT_G on line entry.
				; or  ED_ERROR when editing.
				; or   ED_FULL during ed-enter.
				; or  IN_VAR_1 during runtime input etc.
	JP	SET_STK		; Jump to clear the calculator stack and reset
				; MEM to usual place in the systems variables
				; area and then indirectly to MAIN_4, etc.

; ---

	DEFB	$FF, $FF, $FF	; 7 previously unused locations.
	DEFB	$FF, $FF, $FF	; before the fixed-position.
	DEFB	$FF		; NMI routine.

; ------------------------------------
; THE 'NON-MASKABLE INTERRUPT' ROUTINE
; ------------------------------------
; New
; There is no NMI switch on the standard Spectrum or its peripherals.
; When the NMI line is held low, then no matter what the Z80 was doing at
; the time, it will now execute the code at 66 Hex.
; This Interrupt Service Routine will jump to location zero if the contents
; of the system variable NMIADD are zero or return if the location holds a
; non-zero address.   So attaching a simple switch to the NMI as in the book
; "Spectrum Hardware Manual" causes a reset.  The logic was obviously
; intended to work the other way.  Sinclair Research said that, since they
; had never advertised the NMI, they had no plans to fix the error "until
; the opportunity arose".

; Note. The location NMIADD was, in fact, later used by Sinclair Research
; to enhance the text channel on the ZX Interface 1.
; On later Amstrad-made Spectrums, and the Brazilian Spectrum, the logic of
; this routine was indeed reversed but not as at first intended.
;
; It can be deduced by looking elsewhere in this ROM that the NMIADD system
; variable pointed to NMI_VECT and that this enabled a Warm Restart to be
; performed at any time, even while playing machine code games, or while
; another Spectrum has been allowed to gain control of this one.
;
; Software houses would have been able to protect their games from attack by
; placing two zeros in the NMIADD system variable.
;
; This system is now in place although the routine uses a convoluted check
; to ensure that NMIADD has not been updated by Interface 1 as the interface
; uses these locations to hold the width of the printer.

#assert $==$0066
;	ORG	$0066
NMI:	PUSH	AF		; Save the
	PUSH	HL		; registers.
	LD	HL,(NMIADD)	; Fetch address from the system variable NMIADD.

NMI4:	LD	A,H		; Test address
	OR	L		; for zero.
;;;	JR	NZ,NO_RESET	; skip if NOT ZERO
	JR	Z,NO_NMI		; Skip to NO_NMI if ZERO
	JP	(HL)		; Jump to routine

	ORG	$0070
NO_NMI:	POP	HL		; Restore the
	POP	AF		; registers.
	RETN			; Return to previous interrupt state.

; ---------------------------
; THE 'CH ADD + 1' SUBROUTINE
; ---------------------------
; This subroutine is called from RST 20, and three times from elsewhere
; to fetch the next immediate character following the current valid character
; address and update the associated system variable.
; The entry point TEMP_PTR1 is used from the SCANNING routine.
; Both TEMP_PTR1 and TEMP_PTR2 are used by the READ command routine.

	ORG	$0074
CH_ADD_P1:
	LD	HL,(CH_ADD)	; fetch address.

#assert $==$0077
;	ORG	$0077
TEMP_PTR1:
	INC	HL		; increase the character address by one.

#assert $==$0078
;	ORG	$0078
TEMP_PTR2:
	LD	(CH_ADD),HL	; update with character address.

; Note. The Interface 1, Opus Discovery, MGT Plus D and DISCiPLE interfaces
; all call the next location.

#assert $==$007B
;	ORG	$007B
XTEMP_PTR3:
	LD	A,(HL)		; load character to A from HL.
	RET			; and return.

; --------------------------
; THE 'SKIP OVER' SUBROUTINE
; --------------------------
; This subroutine is called once from RST 18 to skip over white-space and
; other characters irrelevant to the parsing of a BASIC line etc. .
; Initially the A register holds the character to be considered
; and HL holds its address which will not be within quoted text
; when a BASIC line is parsed.
; Although the 'tab' and 'at' characters will not appear in a BASIC line,
; they could be present in a string expression, and in other situations.
; Note. although white-space is usually placed in a program to indent loops
; and make it more readable, it can also be used for the opposite effect and
; spaces may appear in variable names although the parser never sees them.
; It is this routine that helps make the variables 'Anum bEr5 3BUS' and
; 'a number 53 bus' appear the same to the parser.

	ORG	$007D
SKIP_OVER:
	CP	$20		; Test if space.
	SCF			; Set carry flag.
	RET	Z		; Return with carry set if so.
	CP	$18		; Test if in printable range.
	RET	NC		; return with carry clear if so.
	CP	$0D		; carriage return ?
	RET	Z		; return also with carry clear if so.
	CP	$06		; Test if 0-5d
	CCF			; Complement carry flag.
	RET	NC		; Return with carry clear if so.
				; all other characters have no relevance
				; to the parser and must be returned with
				; carry set.
	CP	$10		; test if 6-15d
	RET	C		; return, if so, with carry set.
				; now leaves 16d-23d
	INC	HL		; all above have at least one extra character
				; to be stepped over.
	CP	$16		; controls 22d ('at') and 23d ('tab') have two.
	JR	C,SKIPS		; forward to SKIPS with ink, paper, flash,
				; bright, inverse or over controls.
				; Note. the high byte of tab is for RS232 only.
				; it has no relevance on this machine.
	INC	HL		; step over the second character of 'at'/'tab'.

SKIPS:	SCF			; set the carry flag
	LD	(CH_ADD),HL	; update the system variable.
	RET			; return with carry set.

; ------------------
; THE 'TOKEN' TABLES
; ------------------
; The tokenized characters 134d (RND) to 255d (COPY) are expanded using
; this table. The last byte of a token is inverted to denote the end of
; the word. The first is an inverted step-over byte.

TKN_TABLE:
	DEFB	'?'+$80		; inverted step-over byte
	DEFB	'R','N','D'+$80	; RND
				;
	DEFM	"INKEY"		; INKEY$
	DEFB	'$'+$80		; INKE.
	DEFB	'P','I'+$80	; PI
				;
	DEFB	'F','N'+$80	; FN
				;
	DEFM	"POIN"		; POINT
	DEFB	'T'+$80		; POI.
	DEFM	"SCREEN"		; SCREEN$
	DEFB	'$'+$80		; SC.
	DEFM	"ATT"		; ATTR
	DEFB	'R'+$80		;
	DEFB	'A','T'+$80	; AT
				;
	DEFB	'T','A','B'+$80	; TAB
				;
	DEFM	"VAL"		; VAL$
	DEFB	'$'+$80		;
	DEFM	"COD"		; CODE
	DEFB	'E'+$80		;
	DEFM	"VA"		; VAL
	DEFB	'L'+$80		; VA.
	DEFM	"LE"		; LEN
	DEFB	'N'+$80		;
	DEFM	"SI"		; SIN
	DEFB	'N'+$80		;
	DEFM	"CO"		; COS
	DEFB	'S'+$80		;
	DEFM	"TA"		; TAN
	DEFB	'N'+$80		;
	DEFM	"AS"		; ASN
	DEFB	'N'+$80		;
	DEFM	"AC"		; ACS
	DEFB	'S'+$80		;
	DEFM	"AT"		; ATN
	DEFB	'N'+$80		;
	DEFB	'L','N'+$80	; LN
				;
	DEFB	'E','X','P'+$80	; EXP
				;
	DEFB	'I','N','T'+$80	; INT
				;
	DEFB	'S','Q','R'+$80	; SQR
				;
	DEFB	'S','G','N'+$80	; SGN
				;
	DEFM	'A','B','S'+$80	; ABS
				;
	DEFM	"PEE"		; PEEK
	DEFB	'K'+$80		; PE.
	DEFB	'I','N'+$80	; IN
				;
	DEFB	'U','S','R'+$80	; USR
				; U.
	DEFM	"STR"		; STR$
	DEFB	'$'+$80		;
	DEFM	"CHR"		; CHR$
	DEFB	'$'+$80		; CH.
	DEFB	'N','O','T'+$80	; NOT
				;
	DEFB	'B','I','N'+$80	; BIN
				;

; The previous 32 function-type words are printed without a leading space
; The following have a leading space if they begin with a letter

	DEFB	'O','R'+$80	; OR
				;
	DEFB	'A','N','D'+$80	; AND
				; A.
	DEFB	$3C,'='+$80	; <=
				;
	DEFB	$3E,'='+$80	; >=
				;
	DEFB	$3C,$3E+$80	; <>
				;
	DEFM	"LIN"		; LINE
	DEFB	'E'+$80		;
	DEFM	"THE"		; THEN
	DEFB	'N'+$80		; TH.
	DEFB	'T','O'+$80	; TO
				;
	DEFM	"STE"		; STEP
	DEFB	'P'+$80		;
	DEFM	"DEF F"		; DEF FN
	DEFB	'N'+$80		; DE.
	DEFM	"CA"		; CAT
	DEFB	'T'+$80		;
	DEFM	"FORMA"		; FORMAT
	DEFB	'T'+$80		; FORM.
	DEFM	"MOV"		; MOVE
	DEFB	'E'+$80		; MO.
	DEFM	"ERAS"		; ERASE
	DEFB	'E'+$80		; ER.
	DEFM	"OPEN "		; OPEN #
	DEFB	'#'+$80		; OP.
	DEFM	"CLOSE "		; CLOSE #
	DEFB	'#'+$80		; CLO.
	DEFM	"MERG"		; MERGE
	DEFB	'E'+$80		; M.
	DEFM	"VERIF"		; VERIFY
	DEFB	'Y'+$80		; V.
	DEFM	"BEE"		; BEEP
	DEFB	'P'+$80		; be.
	DEFM	"CIRCL"		; CIRCLE
	DEFB	'E'+$80		; CI.
	DEFB	'I','N','K'+$80	; INK
				;
	DEFM	"PAPE"		; PAPER
	DEFB	'R'+$80		; PAP.
	DEFM	"FLAS"		; FLASH
	DEFB	'H'+$80		; FL.
	DEFM	"BRIGH"		; BRIGHT
	DEFB	'T'+$80		; BR.
	DEFM	"INVERS"		; INVERSE	
	DEFB	'E'+$80		; INV.
	DEFM	"OVE"		; OVER
	DEFB	'R'+$80		; OV.
	DEFM	"OU"		; OUT
	DEFB	'T'+$80		; 
	DEFM	"LPRIN"		; LPRINT
	DEFB	'T'+$80		; LP.
	DEFM	"LLIS"		; LLIST
	DEFB	'T'+$80		; LL.
	DEFM	"STO"		; STOP
	DEFB	'P'+$80		; ST.
	DEFM	"REA"		; READ
	DEFB	'D'+$80		;
	DEFM	"DAT"		; DATA
	DEFB	'A'+$80		; DA.
	DEFM	"RESTOR"		; RESTORE
	DEFB	'E'+$80		; RES.
	DEFB	'N','E','W'+$80	; NEW
				;
	DEFM	"BORDE"		; BORDER
	DEFB	'R'+$80		; B.
	DEFM	"CONTINU"	; CONTINUE
	DEFB	'E'+$80		; CON.
	DEFB	'D','I','M'+$80	; DIM
				;
	DEFM	"RE"		; REM
	DEFB	'M'+$80		; R.
	DEFM	'F','O','R'+$80	; FOR
				; F.
	DEFM	"GO T"		; GO TO
	DEFB	'O'+$80		; GOTO
	DEFM	"GO SU"		; GO SUB
	DEFB	'B'+$80		; G.
	DEFM	"INPU"		; INPUT
	DEFB	'T'+$80		; IN.
	DEFM	"LOA"		; LOAD
	DEFB	'D'+$80		; LO.
	DEFM	"LIS"		; LIST
	DEFB	'T'+$80		; LI.
	DEFB	'L','E','T'+$80	; LET
				; L.
	DEFM	"PAUS"		; PAUSE
	DEFB	'E'+$80		; PA.
	DEFM	"NEX"		; NEXT
	DEFB	'T'+$80		; N.
	DEFM	"POK"		; POKE
	DEFB	'E'+$80		; PO
	DEFM	"PRIN"		; PRINT
	DEFB	'T'+$80		; PR.
	DEFM	"PLO"		; PLOT
	DEFB	'T'+$80		; P.
	DEFB	'R','U','N'+$80	; RUN
				;
	DEFM	"SAV"		; SAVE
	DEFB	'E'+$80		; SA.
	DEFM	"RANDOMIZ"	; RANDOMIZE
	DEFB	'E'+$80		; RA.
	DEFB	'I','F'+$80	; IF
				;
	DEFB	'C','L','S'+$80	; CLS
				;
	DEFM	"DRA"		; DRAW
	DEFB	'W'+$80		; DR.
	DEFM	"CLEA"		; CLEAR
	DEFB	'R'+$80		; CL.
	DEFM	"RETUR"		; RETURN
	DEFB	'N'+$80		; RET.
	DEFM	"COP"		; COPY
	DEFB	'Y'+$80		; C.
	DEFM	"DELET"		; DELETE
	DEFB	'E'+$80		; D.
	DEFM	"EDI"		; EDIT
	DEFB	'T'+$80		; E.
	DEFM	"RENU"		; RENUM
	DEFB	'M'+$80		; REN.
	DEFM	'S','E','T'+$80	; SET
				;
	DEFM	"SOUN"		; SOUND
	DEFB	'D'+$80		; S.
	DEFM	"ON ER"		; ON ERR
	DEFB	'R'+$80		; O.	

	DEFS	5

AY_OFF:	LD	BC,$FFFD		; turns the volume down to zero
	LD	A,$07		;
	OUT	(C),A		;
	LD	B,$BF		;
	LD	A,$FF		;
	OUT	(C),A		;
	RET			;

; ----------------
; THE 'KEY' TABLES
; ----------------
; These four look-up tables are used by the keyboard reading routine
; to decode the key values.
;
; The first table contains the maps for the 39 keys of the standard
; 40-key Spectrum keyboard. The remaining key [SHIFT $27] is read directly.
; The keys consist of the 26 upper-case alphabetic characters, the 10 digit
; keys and the space, ENTER and symbol shift key.
; Unshifted alphabetic keys have $20 added to the value.

MAIN_KEYS:
	DEFM	"BHY65TGVNJU7"
	DEFM	"4RFCMKI83EDX"
	DEFB	$0E		; SYMBOL SHIFT
	DEFM	"LO92WSZ "
	DEFB	$0D		; ENTER
	DEFM	"P01QA"

; The ten control codes assigned to the top line of digits when the shift
; key is pressed.

	ORG	$0260
CTL_CODES:
	DEFB	$0C		; DELETE
	DEFB	$07		; EDIT
	DEFB	$06		; CAPS LOCK
	DEFB	$04		; TRUE VIDEO
	DEFB	$05		; INVERSE VIDEO
	DEFB	$08		; CURSOR LEFT
	DEFB	$0A		; CURSOR DOWN
	DEFB	$0B		; CURSOR UP
	DEFB	$09		; CURSOR RIGHT
	DEFB	$0F		; GRAPHICS

; The 26 red symbols assigned to the alphabetic characters of the keyboard.

#assert $==$026A
;	ORG	$026A
SYM_CODES:
	DEFB	$7E		; ~
	DEFB	$2A		; *
	DEFB	$3F		; ?
	DEFB	$5C		; \
	DEFB	$C8		; >=
	DEFB	$7B		; {
	DEFB	$7D		; }
	DEFB	$5E		; ^
	DEFB	$7F		; copyright
	DEFB	$2D		; -
	DEFB	$2B		; +
	DEFB	$3D		; =
	DEFB	$2E		; .
	DEFB	$2C		; ,
	DEFB	$3B		; ;
	DEFB	$22		; "
	DEFB	$C7		; <=
	DEFB	$3C		; <
	DEFB	$7C		; |
	DEFB	$3E		; >
	DEFB	$5D		; ]
	DEFB	$2F		; /
	DEFB	$C9		; <>
	DEFB	$60		; pound
	DEFB	$5B		; [
	DEFB	$3A		; :

; The ten red symbols assigned to the digits.

#assert $==$0284
;	ORG	$0284
SYM_DIGITS:
	DEFB	$5F		; _
	DEFB	$21		; !
	DEFB	$40		; @
	DEFB	$23		; #
	DEFB	$24		; $
	DEFB	$25		; %
	DEFB	$26		; &
	DEFB	$27		; '
	DEFB	$28		; (
	DEFB	$29		; )

;*******************************
;** Part 2. KEYBOARD ROUTINES **
;*******************************

; Using shift keys and a combination of modes the Spectrum 40-key keyboard
; can be mapped to 256 input characters

; ---------------------------------------------------------------------------
;
;         0     1     2     3     4 -Bits-  4     3     2     1     0
; PORT                                                                    PORT
;
; F7FE  [ 1 ] [ 2 ] [ 3 ] [ 4 ] [ 5 ]  |  [ 6 ] [ 7 ] [ 8 ] [ 9 ] [ 0 ]   EFFE
;  ^                                   |                                   v
; FBFE  [ Q ] [ W ] [ E ] [ R ] [ T ]  |  [ Y ] [ U ] [ I ] [ O ] [ P ]   DFFE
;  ^                                   |                                   v
; FDFE  [ A ] [ S ] [ D ] [ F ] [ G ]  |  [ H ] [ J ] [ K ] [ L ] [ ENT ] BFFE
;  ^                                   |                                   v
; FEFE  [SHI] [ Z ] [ X ] [ C ] [ V ]  |  [ B ] [ N ] [ M ] [sym] [ SPC ] 7FFE
;  ^     $27                                                 $18           v
; Start                                                                   End
;        00100111                                            00011000
;
; ---------------------------------------------------------------------------
; The above map may help in reading.
; The neat arrangement of ports means that the B register need only be
; rotated left to work up the left hand side and then down the right
; hand side of the keyboard. When the reset bit drops into the carry
; then all 8 half-rows have been read. Shift is the first key to be
; read. The lower six bits of the shifts are unambiguous.

; -------------------------------
; THE 'KEYBOARD SCANNING' ROUTINE
; -------------------------------
; From keyboard and S_INKEYS
; Returns 1 or 2 keys in DE, most significant shift first if any
; key values 0-39 else 255

	ORG	$028E
KEY_SCAN:LD	L,$2F		; initial key value
				; valid values are obtained by subtracting
				; eight five times.
	LD	DE,$FFFF		; a buffer to receive 2 keys.
	LD	BC,$FEFE		; the commencing port address
				; B holds 11111110 initially and is also
				; used to count the 8 half-rows

#assert $==$0296
;	ORG	$0296
KEY_LINE:IN	A,(C)		; read the port to A - bits will be reset
				; if a key is pressed else set.
	CPL			; complement - pressed key-bits are now set
	AND	$1F		; apply 00011111 mask to pick up the
				; relevant set bits.
	JR	Z,KEY_DONE	; forward if zero and therefore
				; no keys pressed in row at all.
	LD	H,A		; transfer row bits to H
	LD	A,L		; load the initial key value to A

#assert $==$029F
;	ORG	$029F
KEY_3KEYS:
	INC	D		; now test the key buffer
	RET	NZ		; if we have collected 2 keys already
				; then too many so quit.
#assert $==$02a1
;	ORG	$02A1
KEY_BITS:SUB	$08		; subtract 8 from the key value
				; cycling through key values (top = $27)
				; e.g. 2F>   27>1F>17>0F>07
				;      2E>   26>1E>16>0E>06
	SRL	H		; shift key bits right into carry.
	JR	NC,KEY_BITS	; back if not pressed
				; but if pressed we have a value (0-39d)
	LD	D,E		; transfer a possible previous key to D
	LD	E,A		; transfer the new key to E
	JR	NZ,KEY_3KEYS	; back if there were more
				; set bits - H was not yet zero.

#assert $==$02ab
;	ORG	$02AB
KEY_DONE:DEC	L		; cycles 2F>2E>2D>2C>2B>2A>29>28 for
				; each half-row.
	RLC	B		; form next port address e.g. FEFE > FDFE
	JR	C,KEY_LINE	; back if still more rows to do.
	LD	A,D		; now test if D is still FF ?
	INC	A		; if it is zero we have at most 1 key
				; range now $01-$28  (1-40d)
	RET	Z		; return if one key or no key.
	CP	$28		; is it capsshift (was $27) ?
	RET	Z		; return if so.
	CP	$19		; is it symbol shift (was $18) ?
	RET	Z		; return also
	LD	A,E		; now test E
	LD	E,D		; but first switch
	LD	D,A		; the two keys.
	CP	$18		; is it symbol shift ?
	RET			; return (with zero set if it was).
				; but with symbol shift now in D

; ----------------------
; THE 'KEYBOARD' ROUTINE
; ----------------------
; Called from the interrupt 50 times a second.
;

	ORG	$02BF
KEYBOARD:CALL	KEY_SCAN		;
	RET	NZ		; return if invalid combinations

; then decrease the counters within the two key-state maps
; as this could cause one to become free.
; if the keyboard has not been pressed during the last five interrupts
; then both sets will be free.

	LD	HL,KSTATE_0	; point to KSTATE_0

#assert $==$02c6
;	ORG	$02C6
K_ST_LOOP:
	BIT	7,(HL)		; is it free ?  (i.e. $FF)
	JR	NZ,K_CH_SET	; forward if so
	INC	HL		; address the 5-counter
	DEC	(HL)		; decrease the counter
	DEC	HL		; step back
	JR	NZ,K_CH_SET	; forward if not at end of count
	LD	(HL),$FF		; else mark this particular map free.

#assert $==$02d1
;	ORG	$02D1
K_CH_SET:LD	A,L		; make a copy of the low address byte.
	LD	HL,KSTATE_4	; point to KSTATE_4
				; (ld l,$04 would do)
	CP	L		; have both sets been considered ?
	JR	NZ,K_ST_LOOP	; back to consider this 2nd set

; now the raw key (0-38d) is converted to a main key (uppercase).

	CALL	K_TEST		; to get main key in A
	RET	NC		; return if just a single shift
	LD	HL,KSTATE_0	; point to KSTATE_0
	CP	(HL)		; does the main key code match ?
	JR	Z,K_REPEAT	; forward to K_REPEAT if so

; if not consider the second key map.

	EX	DE,HL		; save kstate-0 in de
	LD	HL,KSTATE_4	; point to KSTATE_4
	CP	(HL)		; does the main key code match ?
	JR	Z,K_REPEAT	; forward if so

; having excluded a repeating key we can now consider a new key.
; the second set is always examined before the first.

	BIT	7,(HL)		; is the key map free ?
	JR	NZ,K_NEW		; forward if so.
	EX	DE,HL		; bring back KSTATE_0
	BIT	7,(HL)		; is it free ?
	RET	Z		; return if not.
				; as we have a key but nowhere to put it yet.

; continue or jump to here if one of the buffers was free.

#assert $==$02f1
;	ORG	$02F1
K_NEW:	LD	E,A		; store key in E
	LD	(HL),A		; place in free location
	INC	HL		; advance to the interrupt counter
	LD	(HL),$05		; and initialize counter to 5
	INC	HL		; advance to the delay
	LD	A,(REPDEL)	; pick up the system variable
	LD	(HL),A		; and insert that for first repeat delay.
	INC	HL		; advance to last location of state map.
	PUSH	HL		; save state map location
	LD	L,$41		; Avoid IY usage.
	LD	C,(HL)		; Load C register with system variable MODE.
	LD	L,$3B		;
	LD	D,(HL)		; Load D register with system variable FLAGS.
	CALL	K_DECODE		;
	POP	HL		; restore map pointer
	LD	(HL),A		; put the decoded key in last location of map.

#assert $==$0308
;	ORG	$0308
K_END:	LD	(LAST_K),A	; update LAST_K system variable.
	LD	L,$3B		; HL now addresses FLAGS
	SET	5,(HL)		; Signal new key.
	RET			; return to interrupt routine.

; -----------------------
; THE 'REPEAT KEY' BRANCH
; -----------------------
; A possible repeat has been identified. HL addresses the raw key.
; The last location of the key map holds the decoded key from the first
; context.  This could be a keyword and, with the exception of NOT a repeat
; is syntactically incorrect and not really desirable.

	ORG	$0310
K_REPEAT:INC HL			; increment the map pointer to second location.
	LD	(HL),$05		; maintain interrupt counter at 5.
	INC	HL		; now point to third location.
	DEC	(HL)		; decrease the REPDEL value which is used to
				; time the delay of a repeat key.
	RET	NZ		; return if not yet zero.
	LD	A,(REPPER)	; fetch the system variable value REPPER.
	LD	(HL),A		; for subsequent repeats REPPER will be used.
	INC	HL		; advance
				;
	LD	A,(HL)		; pick up the key decoded possibly in another
				; context.
				; Note. should compare with $A5 (RND) and make
				; a simple return if this is a keyword.
				; e.g. cp $a5; ret nc; (3 extra bytes)
	JR	K_END		; back to K-END

; ----------------------
; THE 'KEY-TEST' ROUTINE
; ----------------------
; also called from s-inkey$
; begin by testing for a shift with no other.

	ORG	$031E
K_TEST:	LD	B,D		; load most significant key to B
				; will be $FF if not shift.
	LD	D,$00		; and reset D to index into main table
	LD	A,E		; load least significant key from E
	CP	$27		; is it higher than 39d i.e. FF
	RET	NC		; return with just a shift (in B now)
	CP	$18		; is it symbol shift ?
	JR	NZ,K_MAIN	; forward to K-MAIN if not

; but we could have just symbol shift and no other

	BIT	7,B		; is other key $FF (ie not shift)
	RET	NZ		; return with solitary symbol shift

#assert $==$032c
;	ORG	$032C
K_MAIN:	LD	HL,MAIN_KEYS	; address: MAIN_KEYS
	ADD	HL,DE		; add offset 0-38
	LD	A,(HL)		; pick up main key value
	SCF			; set carry flag
	RET			; return  (B has other key still)

; ----------------------------------
; THE 'KEYBOARD DECODING' SUBROUTINE
; ----------------------------------
; also called from s-inkey$

	ORG	$0333
K_DECODE:LD	A,E		; pick up the stored main key
	CP	$3A		; an arbitrary point between digits and letters
	JR	C,K_DIGIT	; forward to K_DIGIT with digits, space, enter.

K_KLC_LET:
	LD	HL,SYM_CODES-$41; prepare base of sym-codes
	BIT	0,B		; shift=$27 sym-shift=$18
	JR	NZ,K_NO_SYM	; jump unless SYMBOL SHIFT.

K_LOOK_UP:
	LD	D,$00		; prepare to index.
	ADD	HL,DE		; add the main key value.
	LD	A,(HL)		; pick up other mode value.
	RET			; return.

K_NO_SYM:
	BIT	3,(IY+$30)	; test FLAGS2 - consider CAPS LOCK?
	JR	Z,K_NO_CAPS	; jump unless CAPS LOCK.
	XOR	$20		; Make lower case if no CAPS LOCK.

K_NO_CAPS:
	INC	B		; is shift being pressed ?
				; result zero if not
	RET	NZ		; return if CAPS not pressed
	XOR	$20		; Change case, flip CAPSLOCK effect
	RET			; return.

; ---

; the jump was here with digits, space, enter and symbol shift (< $xx)

K_DIGIT:	CP	$30		; is it '0' or higher ?
	RET	C		; return with space, enter and symbol-shift

K_KLC_DGT:
	INC	B		; return with digit codes if neither
	RET	Z		; shift key pressed.
	BIT	5,B		; test for caps shift.
	LD	HL,CTL_CODES-$30	; prepare base of table CTL_CODES.
	JR	NZ,K_LOOK_UP	; back if shift pressed.

; must have been symbol shift

	LD	HL,SYM_DIGITS-$30 ; Prepare base of table KLC-DIGIT.
	JR	K_LOOK_UP	; Back to K-LOOK-UP.

; ------------------------
; Canned cassette messages
; ------------------------
; The last-character-inverted Cassette messages.
; Starts with normal initial step-over byte.

TAPE_MSGS:
	DEFB	$80
	DEFM	"Start tape, then press any key"

TAPE_MSGS2:
	DEFB	'.'+$80
	DEFB	$0D
	DEFM	"Program:"
	DEFB	' '+$80
	DEFB	$0D
	DEFM	"Number array:"
	DEFB	' '+$80
	DEFB	$0D
	DEFM	"Character array:"
	DEFB	' '+$80
	DEFB	$0D
	DEFM	"Bytes:"
	DEFB	' '+$80

; ------------------------------------------------------------------------
; The Spectrum Input character keys. One or two are abbreviated.
; From $00 Flash 0 to $FF COPY. The routine above has decoded all these.

;  | 00 Fl0| 01 Fl1| 02 Br0| 03 Br1| 04 In0| 05 In1| 06 CAP| 07 EDT|
;  | 08 LFT| 09 RIG| 0A DWN| 0B UP | 0C DEL| 0D ENT| 0E SYM| 0F GRA|
;  | 10 Ik0| 11 Ik1| 12 Ik2| 13 Ik3| 14 Ik4| 15 Ik5| 16 Ik6| 17 Ik7|
;  | 18 Pa0| 19 Pa1| 1A Pa2| 1B Pa3| 1C Pa4| 1D Pa5| 1E Pa6| 1F Pa7|
;  | 20 SP | 21  ! | 22  " | 23  # | 24  $ | 25  % | 26  & | 27  ' |
;  | 28  ( | 29  ) | 2A  * | 2B  + | 2C  , | 2D  - | 2E  . | 2F  / |
;  | 30  0 | 31  1 | 32  2 | 33  3 | 34  4 | 35  5 | 36  6 | 37  7 |
;  | 38  8 | 39  9 | 3A  : | 3B  ; | 3C  < | 3D  = | 3E  > | 3F  ? |
;  | 40  @ | 41  A | 42  B | 43  C | 44  D | 45  E | 46  F | 47  G |
;  | 48  H | 49  I | 4A  J | 4B  K | 4C  L | 4D  M | 4E  N | 4F  O |
;  | 50  P | 51  Q | 52  R | 53  S | 54  T | 55  U | 56  V | 57  W |
;  | 58  X | 59  Y | 5A  Z | 5B  [ | 5C  \ | 5D  ] | 5E  ^ | 5F  _ |
;  | 60 ukp| 61  a | 62  b | 63  c | 64  d | 65  e | 66  f | 67  g |
;  | 68  h | 69  i | 6A  j | 6B  k | 6C  l | 6D  m | 6E  n | 6F  o |
;  | 70  p | 71  q | 72  r | 73  s | 74  t | 75  u | 76  v | 77  w |
;  | 78  x | 79  y | 7A  z | 7B  { | 7C  | | 7D  } | 7E  ~ | 7F (c)|
;  | 80 128| 81 129| 82 130| 83 131| 84 132| 85 133| 86 134| 87 135|
;  | 88 136| 89 137| 8A 138| 8B 139| 8C 140| 8D 141| 8E 142| 8F 143|
;  | 90 [A]| 91 [B]| 92 [C]| 93 [D]| 94 [E]| 95 [F]| 96 [G]| 97 [H]|
;  | 98 [I]| 99 [J]| 9A [K]| 9B [L]| 9C [M]| 9D [N]| 9E [O]| 9F [P]|
;  | A0 [Q]| A1 [R]| A2 [S]| A3 [T]| A4 [U]| A5 RND| A6 IK$| A7 PI |
;  | A8 FN | A9 PNT| AA SC$| AB ATT| AC AT | AD TAB| AE VL$| AF COD|
;  | B0 VAL| B1 LEN| B2 SIN| B3 COS| B4 TAN| B5 ASN| B6 ACS| B7 ATN|
;  | B8 LN | B9 EXP| BA INT| BB SQR| BC SGN| BD ABS| BE PEK| BF IN |
;  | C0 USR| C1 ST$| C2 CH$| C3 NOT| C4 BIN| C5 OR | C6 AND| C7 <= |
;  | C8 >= | C9 <> | CA LIN| CB THN| CC TO | CD STP| CE DEF| CF CAT|
;  | D0 FMT| D1 MOV| D2 ERS| D3 OPN| D4 CLO| D5 MRG| D6 VFY| D7 BEP|
;  | D8 CIR| D9 INK| DA PAP| DB FLA| DC BRI| DD INV| DE OVR| DF OUT|
;  | E0 LPR| E1 LLI| E2 STP| E3 REA| E4 DAT| E5 RES| E6 NEW| E7 BDR|
;  | E8 CON| E9 DIM| EA REM| EB FOR| EC GTO| ED GSB| EE INP| EF LOA|
;  | F0 LIS| F1 LET| F2 PAU| F3 NXT| F4 POK| F5 PRI| F6 PLO| F7 RUN|
;  | F8 SAV| F9 RAN| FA IF | FB CLS| FC DRW| FD CLR| FE RET| FF CPY|

; Note that for simplicity, Sinclair have located all the control codes
; below the space character.
; ASCII DEL, $7F, has been made a copyright symbol.
; Also $60, '`', not used in BASIC but used in other languages, has been
; allocated the local currency symbol for the relevant country -
; ukp in most Spectrums.

; ------------------------------------------------------------------------

;**********************************
;** Part 3. LOUDSPEAKER ROUTINES **
;**********************************

; ------------------------------
; Routine to control loudspeaker
; ------------------------------
; Outputs a square wave of given duration and frequency
; to the loudspeaker.
;	Enter with:	DE = #cycles - 1
;			HL = tone period as described next
;
; The tone period is measured in T states and consists of
; three parts: a coarse part (H register), a medium part
; (bits 7..2 of L) and a fine part (bits 1..0 of L) which
; contribute to the waveform timing as follows:
;
;                          coarse    medium       fine
; duration of low  = 118 + 1024*H + 16*(L>>2) + 4*(L&0x3)
; duration of hi   = 118 + 1024*H + 16*(L>>2) + 4*(L&0x3)
; Tp = tone period = 236 + 2048*H + 32*(L>>2) + 8*(L&0x3)
;                  = 236 + 2048*H + 8*L = 236 + 8*HL
;
; As an example, to output five seconds of middle C (261.624 Hz):
;	(a) Tone period = 1/261.624 = 3.822ms
;	(b) Tone period in T-States = 3.822ms*fCPU = 13378
;		where fCPU = clock frequency of the CPU = 3.5MHz
;	(c) Find H and L for desired tone period:
;		HL = (Tp - 236) / 8 = (13378 - 236) / 8 = 1643 = 0x066B
;	(d) Tone duration in cycles = 5s/3.822ms = 1308 cycles
;		DE = 1308 - 1 = 0x051B
;
; The resulting waveform has a duty ratio of exactly 50%.
;

	ORG	$03B5
BEEPER:	DI			; Disable Interrupts so they don't disturb timing
	LD	A,L		;
	SRL	L		;
	SRL	L		; L = medium part of tone period
	CPL			;
	AND	$03		; A = 3 - fine part of tone period
	LD	C,A		;
	LD	B,$00		;
	LD	IX,BE_IX_P3 	;
	ADD	IX,BC		; IX holds address of entry into the loop
				; the loop will contain 0-3 NOPs, implementing
				; the fine part of the tone period.
	LD	A,(BORDCR)	;
	AND	$38		; bits 5..3 contain border colour
	RRCA			; border colour bits moved to 2..0
	RRCA			; to match border bits on port #FE
	RRCA			;
	OR	$08		; bit 3 set (tape output bit on port #FE)
				; for loud sound output

#assert $==$03d1
;	ORG	$03D1
BE_IX_P3:NOP			;(4)	; optionally executed NOPs for small
					; adjustments to tone period

#assert $==$03d2
;	ORG	$03D2
BE_IX_P2:NOP			;(4)	;

#assert $==$03d3
;	ORG	$03D3
BE_IX_P1:NOP			;(4)	;

#assert $==$03d4
;	ORG	$03D4
BE_IX_P0:INC	B		;(4)	;
	INC	C		;(4)	;

#assert $==$03d6
;	ORG	$03D6
BE_H_AND_L_LP:
	DEC	C		;(4)	; timing loop for duration of
	JR	NZ,BE_H_AND_L_LP	;(12/7)	; high or low pulse of waveform
	LD	C,$3F		;(7)	;
	DEC	B		;(4)	;
	JP	NZ,BE_H_AND_L_LP	;(10)	;
	XOR	$10		;(7)	; toggle output beep bit
	OUT	($FE),A		;(11)	; output pulse
	LD	B,H		;(4)	; B = coarse part of tone period
	LD	C,A		;(4)	; save port #FE output byte
	BIT	4,A		;(8)	; if new output bit is high, go
	JR	NZ,BE_AGAIN	;(12/7)	;
	LD	A,D		;(4)	; one cycle of waveform has completed
	OR	E		;(4)	; (low->low). if cycle countdown = 0
	JR	Z,BE_END		;(12/7)	;
	LD	A,C		;(4)	; restore output byte for port #FE
	LD	C,L		;(4)	; C = medium part of tone period
	DEC	DE		;(6)	; decrement cycle count
	JP	(IX)		;(8)	; do another cycle

	ORG	$03F2		; halfway through cycle
BE_AGAIN:LD	C,L		;(4)	; C = medium part of tone period
	INC	C		;(4)	; adds 16 cycles to make duration of
					; high = duration of low
	JP	(IX)		;(8)	; do high pulse of tone

	ORG	$03F6
BE_END:	EI			; Enable Interrupts
	RET			;

; ------------------
; THE 'BEEP' COMMAND
; ------------------
; BASIC interface to BEEPER subroutine.
; Invoked in BASIC with:
; BEEP dur, pitch
; where dur = duration in seconds
; pitch = # of semitones above/below middle C
;
; Enter with: pitch on top of calculator stack
; duration next on calculator stack

	ORG	$03F8
BEEP:	RST	28H		;; FP_CALC
	DEFB	$31		;;duplicate	; duplicate pitch
	DEFB	$27		;;int		; convert to integer
	DEFB	$C0		;;st-mem-0	; store integer pitch to memory 0
	DEFB	$03		;;subtract	; calculate fractional part of
						; pitch = fp_pitch - int_pitch
	DEFB	$34		;;stk-data	; push constant
	DEFB	$EC		;;Exp:$7C, Bytes:4; constant = 0.05762265
	DEFB	$6C,$98,$1F,$F5	;;($6C,$98,$1F,$F5)
	DEFB	$04		;;multiply	; compute:
	DEFB	$A1		;;stk-one	; 1 + 0.05762265 *
						; fraction_part(pitch)
	DEFB	$0F		;;addition
	DEFB	$38		;;end-calc	; leave on calc stack

	LD	HL,MEMBOT	; MEM-0: number stored here is in 16 bit
				; integer format (pitch)
				; 0, 0/FF (pos/neg), LSB, MSB, 0
				; LSB/MSB is stored in two's complement
				; In the following, the pitch is checked
				; if it is in the range -128<=p<=127
	LD	A,(HL)		; First byte must be zero, otherwise
	AND	A		; error in integer conversion
	JR	NZ,REPORT_B	;
	INC	HL		;
	LD	C,(HL)		; C = pos/neg flag = 0/FF
	INC HL			;
	LD	B,(HL)		; B = LSB, two's complement
	LD	A,B		;
	RLA			;
	SBC	A,A		; A = 0/FF if B is pos/neg
	CP	C		; must be the same as C if the pitch is
				; -128<=p<=127
	JR	NZ,REPORT_B	; if no, error
	INC	HL		; if -128<=p<=127, MSB will be 0/FF if B is
				; pos/neg
	CP	(HL)		; verify this
	JR	NZ,REPORT_B	; if no, error
				; now we know -128<=p<=127
	LD	A,B		; A = pitch + 60
	ADD	A,$3C		; if -60<=pitch<=67,
	JP	P,BE_I_OK	;
	JP	PO,REPORT_B	; if pitch <= 67 error
				; lower bound of pitch set at -60

#assert $==$0425
;	ORG	$0425		; here, -60<=pitch<=127
				; and A=pitch+60 -> 0<=A<=187
BE_I_OK:	LD	B,$FA		; 6 octaves below middle C

#assert $==$0427
;	ORG	$0427
BE_OCTAVE:			; A=# semitones above 5 octaves below middle C
	INC	B		; increment octave
	SUB	$0C		; 12 semitones = one octave
	JR	NC,BE_OCTAVE	;
	ADD	A,$0C		; A = # semitones above C (0-11)
	PUSH	BC		; B = octave displacement from middle C,
				; 2's complement: -5<=B<=10
	LD	HL,SEMI_TONES	; Address: semi-tone
	CALL	LOC_MEM		;
				; HL = 5*A + $046E
	CALL	STACK_NUM	;
				; read FP value (freq) from semitone table (HL)
				; and push onto calc stack
	RST	28H		;; FP_CALC
	DEFB	$04		;;multiply mult freq by 1 + 0.0576 *
				; fraction_part(pitch) stacked earlier thys
				; taking into account fractional part of pitch
				; The number 0.0576*frequency is the distance
				; in Hz to the next  note (verify with the
				; frequencies recorded in the semitone table
				; below) so that the fraction_part of the pitch
				; does indeed represent a fractional distance
				; to the next note.
	DEFB	$38		;;end-calc HL points to first byte of fp num
				;;on stack = middle frequency to generate
	POP	AF		; A = octave displacement from middle C,
				; 2's complement: -5<=A<=10
	ADD	A,(HL)		; increase exponent by A (equivalent to
				; multiplying by 2^A)
	LD	(HL),A		;
	RST	28H		;; FP_CALC
	DEFB	$C0		;;st-mem-0	; store frequency in memory 0
	DEFB	$02		;;delete		; remove from calc stack
	DEFB	$31		;;duplicate	; duplicate duration (seconds)
	DEFB	$38		;;end-calc
	CALL	FIND_INT1	; 		; FP duration to A
	CP	$0B		; if dur > 10 seconds,
	JR	NC,REPORT_B	; error

; The following calculation finds the tone period for HL and the cycle count
; for DE expected in the BEEPER subroutine.  From the example in the BEEPER comments,
;
; HL = ((fCPU / f) - 236) / 8 = fCPU/8/f - 236/8 = 437500/f -29.5
; DE = duration * frequency - 1
;
; Note the different constant (30.125) used in the calculation of HL
; below.  This is probably an error.

	RST	28H		;; FP_CALC
	DEFB	$E0		;;get-mem-0	; push frequency
	DEFB	$04		;;multiply	; result1: #cycles =
						; duration * frequency
	DEFB	$E0		;;get-mem-0	; push frequency
	DEFB	$34		;;stk-data	; push constant
	DEFB	$80		;;Exp:$93,Bytes:3	; constant = 437500
	DEFB	$43,$55,$9F,$80	;;($55,$9F,$80,$00)
	DEFB	$01		;;exchange	; frequency on top
	DEFB	$05		;;division	; 437500 / frequency
	DEFB	$34		;;stk-data	; push constant
	DEFB	$35		;;Exp:$85,Bytes:1	; constant = 30.125
	DEFB	$6C		;;($6C,$00,$00,$00) constant = 29.5

				; changed from $71
				; $71 = 30.125	($71,$00,$00,$00)
				; $70 = 30
				; $6F = 29.875
				; $6E = 29.75
				; $6D = 29.625
				; $6C = 29.5	($6C,$00,$00,$00)

	DEFB	$03		;;subtract	; result2: tone_period(HL) =
						; 437500 / freq - 30.125
	DEFB	$38		;;end-calc
	CALL	FIND_INT2	;
	PUSH	BC		; BC = tone_period(HL)
	CALL	FIND_INT2	; BC = #cycles to generate
	POP	HL		; HL = tone period
	LD	D,B		;
	LD	E,C		; DE = #cycles
	LD	A,D		;
	OR	E		;
	RET	Z		; if duration = 0, skip BEEP and avoid
				; 65536 cycle boondoggle that would occur next
	DEC	DE		; DE = #cycles - 1
	JP	BEEPER		;

; ---

	ORG	$046C
REPORT_B:	RST	08H	; ERROR_1
	DEFB	$0A		; Error Report: Out of range

; ---------------------
; THE 'SEMI-TONE' TABLE
; ---------------------
;
; Holds frequencies corresponding to semitones in middle octave.
; To move n octaves higher or lower, frequencies are multiplied by 2^n.

	ORG	$046E
SEMI_TONES:	;   five byte fp	    decimal freq	    note (middle)
	DEFB	$89,$02,$D0,$12,$86;  261.625565290		C
	DEFB	$89,$0A,$97,$60,$75;  277.182631135		C#
	DEFB	$89,$12,$D5,$17,$1F;  293.664768100		D
	DEFB	$89,$1B,$90,$41,$02;  311.126983881		D#
	DEFB	$89,$24,$D0,$53,$CA;  329.627557039		E
	DEFB	$89,$2E,$9D,$36,$B1;  349.228231549		F
	DEFB	$89,$38,$FF,$49,$3E;  369.994422674		F#
	DEFB	$89,$43,$FF,$6A,$73;  391.995436072		G
	DEFB	$89,$4F,$A7,$00,$54;  415.304697513		G#
	DEFB	$89,$5C,$00,$00,$00;  440.000000000		A
	DEFB	$89,$69,$14,$F6,$24;  466.163761616		A#
	DEFB	$89,$76,$F1,$10,$05;  493.883301378		B

; ---

	DEFS	15

;****************************************
;** Part 4. CASSETTE HANDLING ROUTINES **
;****************************************

; ----------------------------
; THE 'CHECK VARIABLE' ROUTINE
; ----------------------------
; Called from SA_V_OLD to check that string being saved is a dimensioned
; array.

CHK_VAR:	CALL	SYNTAX_Z		; Checking syntax ?
	RET	Z		; Return if so.
	BIT	7,(HL)		; Is variable a simple string ?
	RET	NZ		; return if not.
	RST	08H		; Error Restart
	DEFB	$0B		; 'Syntax error'

; These routines begin with the service routines followed by a single
; command entry point.

; ========================================
;
; PORT 254 ($FE)
;
;	             spk mic { border  }
;	 ___ ___ ___ ___ ___ ___ ___ ___
; PORT	|   |   |   |   |   |   |   |   |
; 254	|   |   |   |   |   |   |   |   |
; $FE	|___|___|___|___|___|___|___|___|
;	  7   6   5   4   3   2   1   0
;

; ----------------------------------
; Save header and program/data bytes
; ----------------------------------
; This routine saves a section of data. It is called from SA-CTRL to save the
; seventeen bytes of header data. It is also the exit route from that routine
; when it is set up to save the actual data.
; On entry -
; HL points to start of data.
; IX points to descriptor.
; The accumulator is set to  $00 for a header, $FF for data.

	ORG	$04C2
SA_BYTES:LD	HL,SA_LD_RET	; address: SA_LD_RET
	PUSH	HL		; is pushed as common exit route.
				; however there is only one non-terminal exit
				; point.
	LD	HL,$1F80		; a timing constant H=$1F, L=$80
				; inner and outer loop counters
				; a five second lead-in is used for a header.
	BIT	7,A		; test one bit of accumulator.
				; (AND A ?)
	JR	Z,SA_FLAG	; skip if a header is being saved.

; else is data bytes and a shorter lead-in is used.

	LD	HL,$0C98		; another timing value H=$0C, L=$98.
				; a two second lead-in is used for the data.

#assert $==$04d0
;	ORG	$04D0
SA_FLAG:	EX	AF,AF'		; save flag
	INC	DE		; increase length by one.
	DEC	IX		; decrease start.
	DI			; disable interrupts
	LD	A,$02		; select red for border, microphone bit on.
	LD	B,A		; also does as an initial slight counter value.

#assert $==$04d8
;	ORG	$04D8
SA_LEADER:
	DJNZ	SA_LEADER	; self loop for delay.
				; after initial loop, count is $A4 (or $A3)
	OUT	($FE),A		; output byte $02/$0D to tape port.
	XOR	$0F		; switch from RED (mic on) to CYAN (mic off).
	LD	B,$A4		; hold count. also timed instruction.
	DEC	L		; originally $80 or $98.
				; but subsequently cycles 256 times.
	JR	NZ,SA_LEADER	; back until L is zero.

; the outer loop is counted by H

	DEC	B		; decrement count
	DEC	H		; originally  twelve or thirty-one.
	JP	P,SA_LEADER	; back until H becomes $FF

; now send a sync pulse. At this stage mic is off and A holds value
; for mic on.
; A sync pulse is much shorter than the steady pulses of the lead-in.

	LD	B,$2F		; another short timed delay.

#assert $==$04ea
;	ORG	$04EA
SA_SYNC_1:
	DJNZ	SA_SYNC_1	; self loop
	OUT	($FE),A		; switch to mic on and red.
	LD	A,$0D		; prepare mic off - cyan
	LD	B,$37		; another short timed delay.

#assert $==$04f2
;	ORG	$04F2
SA_SYNC_2:
	DJNZ	SA_SYNC_2	; self loop
	OUT	($FE),A		; output mic off, cyan border.
	LD	BC,$3B0E		; B=$3B time(*), C=$0E, YELLOW, MIC OFF.

;

	EX	AF,AF'		; restore saved flag
				; which is 1st byte to be saved.

	LD	L,A		; and transfer to L.
				; the initial parity is A, $FF or $00.
	JP	SA_START		; JUMP forward to ->
				; the mid entry point of loop.

; -------------------------
; During the save loop a parity byte is maintained in H.
; the save loop begins by testing if reduced length is zero and if so
; the final parity byte is saved reducing count to $FFFF.

	ORG	$04FE
SA_LOOP:	LD	A,D		; fetch high byte
	OR	E		; test against low byte.
	JR	Z,SA_PARITY	; forward if zero.
	LD	L,(IX+$00)	; load currently addressed byte to L.

#assert $==$0505
;	ORG	$0505
SA_LOOP_P:
	LD	A,H		; fetch parity byte.
	XOR	L		; exclusive or with new byte.

; -> the mid entry point of loop.

#assert $==$0507
;	ORG	$0507
SA_START:LD	H,A		; put parity byte in H.
	LD	A,$01		; prepare blue, mic=on.
	SCF			; set carry flag ready to rotate in.
	JP	SA_8_BITS	; JUMP forward  -8->

; ---

	ORG	$050E
SA_PARITY:
	LD	L,H		; transfer the running parity byte to L and
	JR	SA_LOOP_P	; back to output that byte before quitting
				; normally.

; ---

; The entry point to save yellow part of bit.
; A bit consists of a period with mic on and blue border followed by
; a period of mic off with yellow border.
; Note. since the DJNZ instruction does not affect flags, the zero flag is
; used to indicate which of the two passes is in effect and the carry
; maintains the state of the bit to be saved.

	ORG	$0511
SA_BIT_2:LD	A,C		; fetch 'mic on and yellow' which is
				; held permanently in C.
	BIT	7,B		; set the zero flag. B holds $3E.

; The entry point to save 1 entire bit. For first bit B holds $3B(*).
; Carry is set if saved bit is 1. zero is reset NZ on entry.

#assert $==$0514
;	ORG	$0514
SA_BIT_1:DJNZ	SA_BIT_1		; self loop for delay
	JR	NC,SA_OUT	; forward if bit is 0.

; but if bit is 1 then the mic state is held for longer.

	LD	B,$42		; set timed delay. (66 decimal)

	ORG	$051A
SA_SET:	DJNZ	SA_SET		; self loop
				; (roughly an extra 66*13 clock cycles)

	ORG	$051C
SA_OUT:	OUT	($FE),A		; blue and mic on OR  yellow and mic off.
	LD	B,$3E		; set up delay
	JR	NZ,SA_BIT_2	; back if zero reset NZ (first pass)

; proceed when the blue and yellow bands have been output.

	DEC	B		; change value $3E to $3D.
	XOR	A		; clear carry flag (ready to rotate in).
	INC	A		; reset zero flag i.e. NZ.

; -8->

	ORG	$0525
SA_8_BITS:
	RL	L		; rotate left through carry
				; C<76543210<C
	JP	NZ,SA_BIT_1	; JUMP back until all 8 bits done.

; when the initial set carry is passed out again then a byte is complete.

	DEC	DE		; decrease length
	INC	IX		; increase byte pointer
	LD	B,$31		; set up timing.
	LD	A,$7F		; test the space key and
	IN	A,($FE)		; return to common exit (to restore border)
	RRA			; if a space is pressed
	RET	NC		; return to SA_LD_RET. - - >

; now test if byte counter has reached $FFFF.

	LD	A,D		; fetch high byte
	INC	A		; increment.
	JP	NZ,SA_LOOP	; JUMP if more bytes.
	LD	B,$3B		; a final delay.

	ORG	$053C
SA_DELAY:DJNZ	SA_DELAY		; self loop
	RET			; return - - >

; ------------------------------
; THE 'SAVE/LOAD RETURN' ROUTINE
; ------------------------------
; The address of this routine is pushed on the stack prior to any load/save
; operation and it handles normal completion with the restoration of the
; border and also abnormal termination when the break key, or to be more
; precise the space key is pressed during a tape operation.
;
; - - >

	ORG	$053F
SA_LD_RET:
	PUSH	AF		; preserve accumulator throughout.
	LD	A,(BORDCR)	; fetch border colour.
	AND	$38		; mask off paper bits.
	RRCA			; rotate
	RRCA			; to the
	RRCA			; range 0-7.
	OUT	($FE),A		; change the border colour.
	LD	A,$7F		; read from port address $7FFE the
	IN	A,($FE)		; row with the space key at outside.
	RRA			; test for space key pressed.
	EI			; enable interrupts
	JR	C,SA_LD_END	; forward if not

	ORG	$0552
REPORT_DA:
	RST	08H		; ERROR_1
	DEFB	$0C		; Error Report: BREAK, CONT repeats

; ---

	ORG	$0554
SA_LD_END:
	POP	AF		; restore the accumulator.
	RET			; return.

; ------------------------------------
; Load header or block of information
; ------------------------------------
; This routine is used to load bytes and on entry A is set to $00 for a
; header or to $FF for data.  IX points to the start of receiving location
; and DE holds the length of bytes to be loaded. If, on entry the carry flag
; is set then data is loaded, if reset then it is verified.

	ORG	$0556
LD_BYTES:INC	D		; reset the zero flag without disturbing carry.
	EX	AF,AF'		; preserve entry flags.
	DEC	D		; restore high byte of length.
	DI			; disable interrupts
	LD	A,$0F		; make the border white and mic off.
	OUT	($FE),A		; output to port.
	LD	HL,SA_LD_RET	; Address: SA_LD_RET
	PUSH	HL		; is saved on stack as terminating routine.

; the reading of the EAR bit (D6) will always be preceded by a test of the
; space key (D0), so store the initial post-test state.

	IN	A,($FE)		; read the ear state - bit 6.
	RRA			; rotate to bit 5.
	AND	$20		; isolate this bit.
	OR	$02		; combine with red border colour.
	LD	C,A		; and store initial state long-term in C.
	CP	A		; set the zero flag.

;

	ORG	$056B
LD_BREAK:RET	NZ		; return if at any time space is pressed.

	ORG	$056C
LD_START:CALL	LD_EDGE_1	;
	JR	NC,LD_BREAK	; back with time out and no
				; edge present on tape.

; but continue when a transition is found on tape.

	LD	HL,$0115		; set up 16-bit outer loop counter for
				; approx 1/4 second delay.

	ORG	$0574
LD_WAIT:	DJNZ	LD_WAIT		; self loop (for 256 times)
	DEC	HL		; decrease outer loop counter.
	LD	A,H		; test for
	OR	L		; zero.
	JR	NZ,LD_WAIT	; back if not zero, with zero in B.

; continue after delay with H holding zero and B also.
; sample 256 edges to check that we are in the middle of a lead-in section.

	CALL	LD_EDGE_2	;
	JR	NC,LD_BREAK	; back if no edges at all.

	ORG	$0580
LD_LEADER:
	LD	B,$9C		; set timing value.
	CALL	LD_EDGE_2	;
	JR	NC,LD_BREAK	; back if time-out
	LD	A,$C6		; two edges must be spaced apart.
	CP	B		; compare
	JR	NC,LD_START	; back if too close together for a lead-in.
	INC	H		; proceed to test 256 edged sample.
	JR	NZ,LD_LEADER	; back while more to do.

; sample indicates we are in the middle of a two or five second lead-in.
; Now test every edge looking for the terminal sync signal.

	ORG	$058F
LD_SYNC:	LD	B,$C9		; initial timing value in B.
	CALL	LD_EDGE_1	;
	JR	NC,LD_BREAK	; back with time-out.
	LD	A,B		; fetch augmented timing value from B.
	CP	$D4		; compare
	JR	NC,LD_SYNC	; back to LD-SYNC if gap too big, that is,
				; a normal lead-in edge gap.

; but a short gap will be the sync pulse.
; in which case another edge should appear before B rises to $FF

	CALL	LD_EDGE_1	;
	RET	NC		; return with time-out.

; proceed when the sync at the end of the lead-in is found.
; We are about to load data so change the border colours.

	LD	A,C		; fetch long-term mask from C
	XOR	$03		; and make blue/yellow.
	LD	C,A		; store the new long-term byte.
	LD	H,$00		; set up parity byte as zero.
	LD	B,$B0		; timing.
	JR	LD_MARKER	; forward
				; the loop mid entry point with the alternate
				; zero flag reset to indicate first byte
				; is discarded.

; --------------
; the loading loop loads each byte and is entered at the mid point.

	ORG	$05A9
LD_LOOP:	EX	AF,AF'		; restore entry flags and type in A.
	JR	NZ,LD_FLAG	; forward if awaiting initial flag
				; which is to be discarded.
	JR	NC,LD_VERIFY	; forward if not to be loaded.
	LD	(IX+$00),L	; place loaded byte at memory location.
	JR	LD_NEXT		; forward

; ---

	ORG	$05B3
LD_FLAG:	RL	C		; preserve carry (verify) flag in long-term
				; state byte. Bit 7 can be lost.
	XOR	L		; compare type in A with first byte in L.
	RET	NZ		; return if no match e.g. CODE vs. DATA.

; continue when data type matches.

	LD	A,C		; fetch byte with stored carry
	RRA			; rotate it to carry flag again
	LD	C,A		; restore long-term port state.
	INC	DE		; increment length ??
	JR	LD_DEC		; forward
				; but why not to location after ?

; ---
; for verification the byte read from tape is compared with that in memory.

	ORG	$05BD
LD_VERIFY:
	LD	A,(IX+$00)	; fetch byte from memory.
	XOR	L		; compare with that on tape
	RET	NZ		; return if not zero.

	ORG	$05C2
LD_NEXT:	INC	IX		; increment byte pointer.

	ORG	$05C4
LD_DEC:	DEC	DE		; decrement length.
	EX	AF,AF'		; store the flags.
	LD	B,$B2		; timing.

; when starting to read 8 bits the receiving byte is marked with bit at right.
; when this is rotated out again then 8 bits have been read.

	ORG	$05C8
LD_MARKER:
	LD	L,$01		; initialize as %00000001

	ORG	$05CA
LD_8_BITS:
	CALL	LD_EDGE_2	; routine increments B relative to
				; gap between 2 edges.
	RET	NC		; return with time-out.
	LD	A,$CB		; the comparison byte.
	CP	B		; compare to incremented value of B.
				; if B is higher then bit on tape was set.
				; if <= then bit on tape is reset.
	RL	L		; rotate the carry bit into L.
	LD	B,$B0		; reset the B timer byte.
	JP	NC,LD_8_BITS	; JUMP back

; when carry set then marker bit has been passed out and byte is complete.

	LD	A,H		; fetch the running parity byte.
	XOR	L		; include the new byte.
	LD	H,A		; and store back in parity register.
	LD	A,D		; check length of
	OR	E		; expected bytes.
	JR	NZ,LD_LOOP	; back while there are more.

; when all bytes loaded then parity byte should be zero.

	LD	A,H		; fetch parity byte.
	CP	$01		; set carry if zero.
	RET			; return
				; in no carry then error as checksum disagrees.

; -------------------------
; Check signal being loaded
; -------------------------
; An edge is a transition from one mic state to another.
; More specifically a change in bit 6 of value input from port $FE.
; Graphically it is a change of border colour, say, blue to yellow.
; The first entry point looks for two adjacent edges. The second entry point
; is used to find a single edge.
; The B register holds a count, up to 256, within which the edge (or edges)
; must be found. The gap between two edges will be more for a '1' than a '0'
; so the value of B denotes the state of the bit (two edges) read from tape.

; ->

	ORG	$05E3
LD_EDGE_2:
	CALL	LD_EDGE_1	; call routine below.
	RET	NC		; return if space pressed or time-out.
				; else continue and look for another adjacent
				; edge which together represent a bit on the
				; tape.

; ->
; this entry point is used to find a single edge from above but also
; when detecting a read-in signal on the tape.

	ORG	$05E7
LD_EDGE_1:
	LD	A,$16		; a delay value of twenty two.

	ORG	$05E9
LD_DELAY:
	DEC	A		; decrement counter
	JR	NZ,LD_DELAY	; loop back 22 times.
	AND	A		; clear carry.

	ORG	$05ED
LD_SAMPLE:
	INC	B		; increment the time-out counter.
	RET	Z		; return with failure when $FF passed.
	LD	A,$7F		; prepare to read keyboard and EAR port
	IN	A,($FE)		; row $7FFE. bit 6 is EAR, bit 0 is SPACE key.
	RRA			; test outer key the space. (bit 6 moves to 5)
	RET	NC		; return if space pressed.		>>>
	XOR	C		; compare with initial long-term state.
	AND	$20		; isolate bit 5
	JR	Z,LD_SAMPLE	; back if no edge.

; but an edge, a transition of the EAR bit, has been found so switch the
; long-term comparison byte containing both border colour and EAR bit.

	LD	A,C		; fetch comparison value.
	CPL			; switch the bits
	LD	C,A		; and put back in C for long-term.
	AND	$07		; isolate new colour bits.
	OR	$08		; set bit 3 - MIC off.
	OUT	($FE),A		; send to port to effect the change of colour.
	SCF			; set carry flag signaling edge found within
				; time allowed.
	RET			; return.

; ---------------------------------
; Entry point for all tape commands
; ---------------------------------
; This is the single entry point for the four tape commands.
; The routine first determines in what context it has been called by examining
; the low byte of the Syntax table entry which was stored in T_ADDR.
; Subtracting $EO (the present arrangement) gives a value of
; $00 - SAVE
; $01 - LOAD
; $02 - VERIFY
; $03 - MERGE
; As with all commands the address STMT-RET is on the stack.

	ORG	$0605
SAVE_ETC:POP	AF		; discard address STMT_RET.
	LD	A,(T_ADDR)	; fetch T_ADDR

; Now reduce the low byte of the Syntax table entry to give command.

	SUB	$9F		; subtract the known offset.
	LD	(T_ADDR),A	; and put back as 0,1,2, or 3
				; for future reference.
	CALL	EXPT_EXP		; checks that a string
				; expression follows and stacks the
				; parameters in run-time.
	CALL	SYNTAX_Z		;
	JR	Z,SA_DATA	; forward if checking syntax.
	LD	BC,$0011		; presume seventeen bytes for a header.
	LD	A,(T_ADDR)	; fetch command.
	AND	A		; test for zero - SAVE.
	JR	Z,SA_SPACE;	; forward if so.
	LD	C,$22		; else double length to thirty four.

	ORG	$0621
SA_SPACE:RST	30H		; BC_SPACES creates 17/34 bytes in workspace.
	PUSH	DE		; transfer the start of new space to
	POP	IX		; the available index register.

; ten spaces are required for the default filename but it is simpler to
; overwrite the first file-type indicator byte as well.

	LD	B,$0B		; set counter to eleven.
	LD	A,$20		; prepare a space.

	ORG	$0629
SA_BLANK:LD	(DE),A		; set workspace location to space.
	INC	DE		; next location.
	DJNZ	SA_BLANK		; loop back until all eleven done.
	LD	(IX+$01),$FF	; set first byte of ten character filename
				; to $FF as a default to signal null string.
	CALL	STK_FETCH	; fetches the filename parameters
				; from the calculator stack.
				; length of string in BC.
				; start of string in DE.
	LD	HL,$FFF6		; prepare the value minus ten.
	DEC	BC		; decrement length.
				; ten becomes nine, zero becomes $FFFF.
	ADD	HL,BC		; trial addition.
	INC	BC		; restore true length.
	JR	NC,SA_NAME	; forward if length is one to ten.

; the filename is more than ten characters in length or the null string.

	LD	A,(T_ADDR)	; fetch command.
	AND	A		; test for zero - SAVE.
	JR	NZ,SA_NULL	; forward if not the SAVE command.

; but no more than ten characters are allowed for SAVE.
; The first ten characters of any other command parameter are acceptable.
; Weird, but necessary, if saving to sectors.
; Note. the golden rule that there are no restriction on anything is broken.

	ORG	$0642
REPORT_Fa:
	RST	08H		; ERROR_1
	DEFB	$0E		; Error Report: Bad file name

; continue with LOAD, MERGE, VERIFY and also SAVE within ten character limit.

	ORG	$0644
SA_NULL:	LD	A,B		; test length of filename
	OR	C		; for zero.
	JR	Z,SA_DATA	; forward if so using the 255
				; indicator followed by spaces.
	LD	BC,$000A		; else trim length to ten.

; other paths rejoin here with BC holding length in range 1 - 10.

	ORG	$064B
SA_NAME:	PUSH	IX		; push start of file descriptor.
	POP	HL		; and pop into HL.
	INC	HL		; HL now addresses first byte of filename.
	EX	DE,HL		; transfer destination address to DE, start
				; of string in command to HL.
	LDIR			; copy up to ten bytes
				; if less than ten then trailing spaces follow.

; the case for the null string rejoins here.


	ORG	$0652
SA_DATA:	RST	18H		; GET_CHAR
	CP	$E4		; is character after filename the token 'DATA' ?
	JR	NZ,SA_SCR_STR	; forward to consider SCREEN$ if not.

; continue to consider DATA.

	LD	A,(T_ADDR)	; fetch command from T_ADDR
	CP	$03		; is it 'VERIFY' ?
	JP	Z,REPORT_C	; jump forward if so.
				; 'Syntax error'
				; VERIFY "d" DATA is not allowed.

; continue with SAVE, LOAD, MERGE of DATA.

	RST	20H		; NEXT_CHAR
	CALL	LOOK_VARS	; searches variables area returning with
				; carry reset if found or checking syntax.
	SET	7,C		; this converts a simple string to a
				; string array. The test for an array or string
				; comes later.
	JR	NC,SA_V_OLD	; forward if variable found.
	LD	HL,$0000		; set destination to zero as not fixed.
	LD	A,(T_ADDR)	; fetch command from T_ADDR
	DEC	A		; test for 1 - LOAD
	JR	Z,SA_V_NEW	; forward with LOAD DATA to load a new array.

; otherwise the variable was not found in run-time with SAVE/MERGE.

	ORG	$0670
REPORT_2a:
	RST	08H		; ERROR_1
	DEFB	$01		; Error Report: Undefined variable

; continue with SAVE/LOAD  DATA

	ORG	$0672
SA_V_OLD:JP	NZ,REPORT_C	; jump if not an array variable.
				; or erroneously a simple string.
				; 'Syntax error'
	CALL	CHK_VAR		; Eliminate simple strings
	JR	Z,SA_DATA_1	; forward if checking syntax.
	INC	HL		; step past single character variable name.
	LD	A,(HL)		; fetch low byte of length.
	LD	(IX+$0B),A	; place in descriptor.
	INC	HL		; point to high byte.
	LD	A,(HL)		; and transfer that
	LD	(IX+$0C),A	; to descriptor.
	INC	HL		; increase pointer within variable.

	ORG	$0685
SA_V_NEW:LD	(IX+$0E),C	; place character array name in header.
	LD	A,$01		; default to type numeric.
	BIT	6,C		; test result from look-vars.
	JR	Z,SA_V_TYPE	; forward if numeric.
	INC	A		; set type to 2 - string array.


	ORG	$068F
SA_V_TYPE:
	LD	(IX+$00),A	; place type 0, 1 or 2 in descriptor.

	ORG	$0692
SA_DATA_1:
	EX	DE,HL		; save var pointer in DE
	RST	20H		; NEXT_CHAR
	CP	$29		; is character ')' ?
	JR	NZ,SA_V_OLD	; back if not to report
				; 'Syntax error'
	RST	20H		; NEXT_CHAR advances character address.
	CALL	CHECK_END	; errors if not end of the statement.
	EX	DE,HL		; bring back variables data pointer.
	JP	SA_ALL		; jump forward

; ---
; the branch was here to consider a 'SCREEN$', the display file.

	ORG	$06A0
SA_SCR_STR:
	CP	$AA		; is character the token 'SCREEN$' ?
	JR	NZ,SA_CODE	; forward if not.
	LD	A,(T_ADDR)	; fetch command
	CP	$03		; is it MERGE ?
	JP	Z,REPORT_C	; jump if so.
				; 'Syntax error'

; continue with SAVE/LOAD/VERIFY SCREEN$.

	RST	20H		; NEXT_CHAR
	CALL	CHECK_END	; errors if not at end of statement.

; continue in runtime.

	LD	(IX+$0B),$00	; set descriptor length
	LD	(IX+$0C),$1B	; to $1b00 to include bitmaps and attributes.
	LD	HL,SCREEN_0	; set start to display file start.
	LD	(IX+$0D),L	; place start in
	LD	(IX+$0E),H	; the descriptor.
	JR	SA_TYPE_3	; forward

; ---
; the branch was here to consider CODE.

	ORG	$06C3
SA_CODE:	CP	$AF		; is character the token 'CODE' ?
	JR	NZ,SA_LINE	; forward if not to consider an
				; auto-started BASIC program.
	LD	A,(T_ADDR)	; fetch command
	CP	$03		; is it MERGE ?
	JP	Z,REPORT_C	; jump forward if so.
				; 'Syntax error'
	RST	20H		; NEXT_CHAR advances character address.
	CALL	PR_ST_END	; checks if a carriage return or ':' follows.
	JR	NZ,SA_CODE_1	; forward if there are parameters.
	LD	A,(T_ADDR)	; else fetch the command.
	AND	A		; test for zero - SAVE without a specification.
	JP	Z,REPORT_C	; jump if so.
				; 'Syntax error'

; for LOAD/VERIFY put zero on stack to signify handle at location saved from.

	CALL	USE_ZERO		;
	JR	SA_CODE_2	; forward

; ---

; if there are more characters after CODE expect start and possibly length.

	ORG	$06E1
SA_CODE_1:
	CALL	EXPT_1NUM	; checks for numeric expression
				; and stacks it in run-time.
	RST	18H		; GET_CHAR
	CP	$2C		; does a comma follow ?
	JR	Z,SA_CODE_3	; forward if so

; else allow saved code to be loaded to a specified address.

	LD	A,(T_ADDR)	; fetch command.
	AND	A		; is the command SAVE which requires length ?
	JP	Z,REPORT_C	; jump if so.
				; 'Syntax error'

; the command LOAD code may rejoin here with zero stacked as start.

	ORG	$06F0
SA_CODE_2:
	CALL	USE_ZERO		; stacks zero for length.
	JR	SA_CODE_4	; forward

; ---
; the branch was here with SAVE CODE start,

	ORG	$06F5
SA_CODE_3:
	RST	20H		; NEXT_CHAR advances character address.
	CALL	EXPT_1NUM	; checks for expression and stacks in run-time.

; paths converge here and nothing must follow.

	ORG	$06F9
SA_CODE_4:
	CALL	CHECK_END	; errors with extraneous characters
				; and quits if checking syntax.

; in run-time there are two 16-bit parameters on the calculator stack.

	CALL	FIND_INT2	; gets length.
	LD	(IX+$0B),C	; place length
	LD	(IX+$0C),B	; in descriptor.
	CALL	FIND_INT2	; gets start.
	LD	(IX+$0D),C	; place start
	LD	(IX+$0E),B	; in descriptor.
	LD	H,B		; transfer the
	LD	L,C		; start to HL also.

	ORG	$0710
SA_TYPE_3:
	LD	(IX+$00),$03	; place type 3 - code in descriptor.
	JR	SA_ALL		; forward

; ---
; the branch was here with BASIC to consider an optional auto-start line
; number.

	ORG	$0716
SA_LINE:	CP	$CA		; is character the token 'LINE' ?
	JR	Z,SA_LINE_1	; forward if so.

; else all possibilities have been considered and nothing must follow.

	CALL	CHECK_END	;

; continue in run-time to save BASIC without auto-start.

	LD	(IX+$0E),$80	; place high line number in descriptor to
				; disable auto-start.
	JR	SA_TYPE_0	; forward to save program.

; ---
; the branch was here to consider auto-start.

	ORG	$0723
SA_LINE_1:
	LD	A,(T_ADDR)	; fetch command from T_ADDR
	AND	A		; test for SAVE.
	JP	NZ,REPORT_C	; jump forward with anything else.
				; 'Syntax error'

;

	RST	20H		; NEXT_CHAR
	CALL	FETCH_NUM	; routine checks for numeric
				; expression and stacks in run-time.
				; line numbers are optional
	CALL	CHECK_END	; quits if syntax path.
	CALL	FIND_LINE	;

	LD	(IX+$0D),C	; place the auto-start
	LD	(IX+$0E),B	; line number in the descriptor.

; Note. this isn't checked, but is subsequently handled by the system.
; If the user typed 40000 instead of 4000 then it won't auto-start
; at line 4000, or indeed, at all.

; continue to save program and any variables.

	ORG	$073A
SA_TYPE_0:
	LD	(IX+$00),$00	; place type zero - program in descriptor.
	LD	HL,(E_LINE)	;
	LD	DE,(PROG)		;
	SCF			; set carry flag to calculate from end of
				; variables E_LINE -1.
	SBC	HL,DE		; subtract to give total length.
	LD	(IX+$0B),L	; place total length
	LD	(IX+$0C),H	; in descriptor.
	LD	HL,(VARS)		;
	SBC	HL,DE		; subtract to give program length.
	LD	(IX+$0F),L	; place length of program
	LD	(IX+$10),H	; in the descriptor.
	EX	DE,HL		; start to HL, length to DE.

	ORG	$075A
SA_ALL:	LD	A,(T_ADDR)	; fetch command
	AND	A		; test for zero - SAVE.
	JP	Z,SA_CONTRL	; jump forward to SA-CONTRL with SAVE  ->

; ---
; continue with LOAD, MERGE and VERIFY.

	PUSH	HL		; save start.
	LD	BC,$0011		; prepare to add seventeen
	ADD	IX,BC		; to point IX at second descriptor.

	ORG	$0767
LD_LOOK_H:
	PUSH	IX		; save IX
	LD	DE,$0011		; seventeen bytes
	XOR	A		; reset zero flag
	SCF			; set carry flag
	CALL	LD_BYTES		; loads a header from tape to second descriptor.
	POP	IX		; restore IX.
	JR	NC,LD_LOOK_H	; loop back until header found.
	LD	A,$FE		; select system channel 'S'
	CALL	CHAN_OPEN	; opens it.
	LD	(IY+$52),$FF	; set SCR_CT to 255 lines.
	LD	C,$80		; C has bit 7 set to indicate type mismatch as
				; a default startpoint.
	LD	A,(IX+$00)	; fetch loaded header type to A
	CP	(IX-$11)		; compare with expected type.
	JR	NZ,LD_TYPE	; forward with mis-match.
	LD	C,$F6		; set C to minus ten - will count characters
				; up to zero.

	ORG	$078A
LD_TYPE:	CP	$04		; check if type in acceptable range 0 - 3.
	JR	NC,LD_LOOK_H	; back with 4 and over.

; else A indicates type 0-3.

	LD	DE,TAPE_MSGS2	; address base of last 4 tape messages
	PUSH	BC		; save BC
	CALL	PO_MSG		; PO-MSG outputs relevant message.
				; Note. all messages have a leading newline.
	POP	BC		; restore BC
	PUSH	IX		; transfer IX,
	POP	DE		; the 2nd descriptor, to DE.
	LD	HL,$FFF0		; prepare minus seventeen.
	ADD	HL,DE		; add to point HL to 1st descriptor.
	LD	B,$0A		; the count will be ten characters for the
				; filename.
	LD	A,(HL)		; fetch first character and test for
	INC	A		; value 255.
	JR	NZ,LD_NAME	; forward to LD-NAME if not the wildcard.

; but if it is the wildcard, then add ten to C which is minus ten for a type
; match or -128 for a type mismatch. Although characters have to be counted
; bit 7 of C will not alter from state set here.

	LD	A,C		; transfer $F6 or $80 to A
	ADD	A,B		; add $0A
	LD	C,A		; place result, zero or -118, in C.

; At this point we have either a type mismatch, a wildcard match or ten
; characters to be counted. The characters must be shown on the screen.

	ORG	$07A6
LD_NAME:	INC	DE		; address next input character
	LD	A,(DE)		; fetch character
	CP	(HL)		; compare to expected
	INC	HL		; address next expected character
	JR	NZ,LD_CH_PR	; forward with mismatch
	INC	C		; increment matched character count

	ORG	$07AD
LD_CH_PR:RST	10H		; PRINT_A prints character
	DJNZ	LD_NAME		; loop back for ten characters.

; if ten characters matched and the types previously matched then C will
; now hold zero.

	BIT	7,C		; test if all matched
	JR	NZ,LD_LOOK_H	; back if not

; else print a terminal carriage return.

	LD	A,$0D		; prepare carriage return.
	RST	10H		; PRINT_A outputs it.

; The various control routines for LOAD, VERIFY and MERGE are executed
; during the one-second gap following the header on tape.

	POP	HL		; restore xx
	LD	A,(IX+$00)	; fetch incoming type
	CP	$03		; compare with CODE
	JR	Z,VR_CONTROL	; forward if it is CODE.

; type is a program or an array.

	LD	A,(T_ADDR)	; fetch command
	DEC	A		; was it LOAD ?
	JP	Z,LD_CONTRL	; JUMP forward if so to
				; load BASIC or variables.
	CP	$02		; was command MERGE ?
	JP	Z,ME_CONTRL	; jump forward if so.

; else continue into VERIFY control routine to verify.

; ----------------------------
; THE 'VERIFY CONTROL' ROUTINE
; ----------------------------
; There are two branches to this routine.
; 1) From above to verify a program or array
; 2) from earlier with no carry to load or verify code.

	ORG	$07CB
VR_CONTROL:
	PUSH	HL		; save pointer to data.
	LD	L,(IX-$06)	; fetch length of old data
	LD	H,(IX-$05)	; to HL.
	LD	E,(IX+$0B)	; fetch length of new data
	LD	D,(IX+$0C)	; to DE.
	LD	A,H		; check length of old
	OR	L		; for zero.
	JR	Z,VR_CONT_1	; forward if length unspecified
				; e.g. LOAD "x" CODE

; as opposed to, say, LOAD "x" CODE 32768,300.

	SBC	HL,DE		; subtract the two lengths.
	JR	C,REPORT_R	; forward if the length on tape is
				; larger than that specified in command.
				; 'Loading error'
	JR	Z,VR_CONT_1	; forward if lengths match.

; a length on tape shorter than expected is not allowed for CODE

	LD	A,(IX+$00)	; else fetch type from tape.
	CP	$03		; is it CODE ?
	JR	NZ,REPORT_R	; forward if so
				; 'Loading error'

	ORG	$07E9
VR_CONT_1:
	POP	HL		; pop pointer to data
	LD	A,H		; test for zero
	OR	L		; e.g. LOAD "x" CODE
	JR	NZ,VR_CONT_2	; forward if destination specified.
	LD	L,(IX+$0D)	; else use the destination in the header
	LD	H,(IX+$0E)	; and load code at address saved from.

	ORG	$07F4
VR_CONT_2:
	PUSH	HL		; push pointer to start of data block.
	POP	IX		; transfer to IX.
	LD	A,(T_ADDR)	; fetch reduced command
	CP	$02		; is it VERIFY ?
	SCF			; prepare a set carry flag
	JR	NZ,VR_CONT_3	; skip if not
	AND	A		; clear carry flag for VERIFY so that
				; data is not loaded.
	ORG	$0800
VR_CONT_3:
	LD	A,$FF		; signal data block to be loaded

; -----------------
; Load a data block
; -----------------
; This routine is called from 3 places other than above to load a data block.
; In all cases the accumulator is first set to $FF so the routine could be
; called at the previous instruction.

	ORG	$0802
LD_BLOCK:	CALL	LD_BYTES		;
	RET	C		; return if successful.

	ORG	$0806
REPORT_R:	RST	08H		; ERROR_1
	DEFB	$1A		; Error Report: Loading error

; --------------------------
; THE 'LOAD CONTROL' ROUTINE
; --------------------------
; This branch is taken when the command is LOAD with type 0, 1 or 2.

	ORG	$0808
LD_CONTRL:
	LD	E,(IX+$0B)	; fetch length of found data block
	LD	D,(IX+$0C)	; from 2nd descriptor.
	PUSH	HL		; save destination
	LD	A,H		; test for zero
	OR	L		;
	JR	NZ,LD_CONT_1	; forward if not
	INC	DE		; increase length
	INC	DE		; for letter name
	INC	DE		; and 16-bit length
	EX	DE,HL		; length to HL,
	JR	LD_CONT_2		; forward

; ---

	ORG	$0819
LD_CONT_1:
	LD	L,(IX-$06)	; fetch length from
	LD	H,(IX-$05)	; the first header.
	EX	DE,HL		;
	SCF			; set carry flag
	SBC	HL,DE		;
	JR	C,LD_DATA		;

	ORG	$0825
LD_CONT_2:
	LD	DE,$0005		; allow overhead of five bytes.
	ADD	HL,DE		; add in the difference in data lengths.
	LD	B,H		; transfer to
	LD	C,L		; the BC register pair
	CALL	TEST_ROOM		; fails if not enough room.

	ORG	$082E
LD_DATA:	POP	HL		; pop destination
	LD	A,(IX+$00)	; fetch type 0, 1 or 2.
	AND	A		; test for program and variables.
	JR	Z,LD_PROG		; forward if so to LD-PROG

; the type is a numeric or string array.

	LD	A,H		; test the destination for zero
	OR	L		; indicating variable does not already exist.
	JR	Z,LD_DATA_1	; forward if so

; else the destination is the first dimension within the array structure

	DEC	HL		; address high byte of total length
	LD	B,(HL)		; transfer to B.
	DEC	HL		; address low byte of total length.
	LD	C,(HL)		; transfer to C.
	DEC	HL		; point to letter of variable.
	INC	BC		; adjust length to
	INC	BC		; include these
	INC	BC		; three bytes also.
	LD	(X_PTR),IX	; save header pointer.
	CALL	RECLAIM_2		; reclaims the old variable
				; sliding workspace including the two headers
				; downwards.
	LD	IX,(X_PTR)	; reload IX from X_PTR which will have been
				; adjusted down by POINTERS routine.

	ORG	$084C
LD_DATA_1:
	LD	HL,(E_LINE)	;
	DEC	HL		; now point to the $80 variables end-marker.
	LD	C,(IX+$0B)	; fetch new data length
	LD	B,(IX+$0C)	; from 2nd header.
	PUSH	BC		; * save it.
	INC	BC		; adjust the
	INC	BC		; length to include
	INC	BC		; letter name and total length.
	LD	A,(IX-$03)	; fetch letter name from old header.
	PUSH	AF		; preserve accumulator though not corrupted.
	CALL	MAKE_ROOM		; creates space for variable
				; sliding workspace up. IX no longer addresses
				; anywhere meaningful.
	INC	HL		; point to first new location.
	POP	AF		; fetch back the letter name.
	LD	(HL),A		; place in first new location.
	POP	DE		; * pop the data length.
	INC	HL		; address 2nd location
	LD	(HL),E		; store low byte of length.
	INC	HL		; address next.
	LD	(HL),D		; store high byte.
	INC	HL		; address start of data.
	PUSH	HL		; transfer address
	POP	IX		; to IX register pair.
	SCF			; set carry flag indicating load not verify.
	LD	A,$FF		; signal data not header.
	JP	LD_BLOCK		; JUMP back

; -----------------
; the branch is here when a program as opposed to an array is to be loaded.

	ORG	$0873
LD_PROG:	EX	DE,HL		; transfer dest to DE.
	LD	HL,(E_LINE)	;
	DEC	HL		; now variables end-marker.
	LD	(X_PTR),IX	; place the IX header pointer in X_PTR
	LD	C,(IX+$0B)	; get new length
	LD	B,(IX+$0C)	; from 2nd header
	PUSH	BC		; and save it.
	CALL	RECLAIM_1		; reclaims program and vars.
				; adjusting X-PTR.
	POP	BC		; restore new length.
	PUSH	HL		; * save start
	PUSH	BC		; ** and length.
	CALL	MAKE_ROOM		; creates the space.
	LD	IX,(X_PTR)	; reload IX from adjusted X_PTR
	INC	HL		; point to start of new area.
	LD	C,(IX+$0F)	; fetch length of BASIC on tape
	LD	B,(IX+$10)	; from 2nd descriptor
	ADD	HL,BC		; add to address the start of variables.
	LD	(VARS),HL		; set system variable
	LD	H,(IX+$0E)	; fetch high byte of autostart line number.
	LD	A,H		; transfer to A
	AND	$C0		; test if greater than $3F.
	JR	NZ,LD_PROG_1	; forward if so with no autostart.
	LD	L,(IX+$0D)	; else fetch the low byte.
	LD	(NEWPPC),HL	; set system variable to line number NEWPPC
	LD	(IY+$0A),$00	; set statement NSPPC to zero.

	ORG	$08AD
LD_PROG_1:
	POP	DE		; ** pop the length
	POP	IX		; * and start.
	SCF			; set carry flag
	LD	A,$FF		; signal data as opposed to a header.
	JP	LD_BLOCK		; jump back

; ---------------------------
; THE 'MERGE CONTROL' ROUTINE
; ---------------------------
; the branch was here to merge a program and its variables or an array.
;

	ORG	$08B6
ME_CONTRL:
	LD	C,(IX+$0B)	; fetch length
	LD	B,(IX+$0C)	; of data block on tape.
	PUSH	BC		; save it.
	INC	BC		; one for the pot.
	RST	30H		; BC_SPACES creates room in workspace.
				; HL addresses last new location.
	LD	(HL),$80		; place end-marker at end.
	EX	DE,HL		; transfer first location to HL.
	POP	DE		; restore length to DE.
	PUSH	HL		; save start.
	PUSH	HL		; and transfer it
	POP	IX		; to IX register.
	SCF			; set carry flag to load data on tape.
	LD	A,$FF		; signal data not a header.
	CALL	LD_BLOCK		; loads to workspace.
	POP	HL		; restore first location in workspace to HL.

; Note the next location is called by IF1 and the Opus Discovery interface.

	ORG	$08CE
X08CE:	LD	DE,(PROG)		; set DE from system variable PROG.

; now enter a loop to merge the data block in workspace with the program and
; variables.

	ORG	$08D2
ME_NEW_LP:
	LD	A,(HL)		; fetch next byte from workspace.
	AND	$C0		; compare with $3F.
	JR	NZ,ME_VAR_LP	; forward to ME-VAR-LP if a variable or
				; end-marker.

; continue when HL addresses a BASIC line number.

	ORG	$08D7
ME_OLD_LP:
	LD	A,(DE)		; fetch high byte from program area.
	INC	DE		; bump prog address.
	CP	(HL)		; compare with that in workspace.
	INC	HL		; bump workspace address.
	JR	NZ,ME_OLD_L1	; forward if high bytes don't match
	LD	A,(DE)		; fetch the low byte of program line number.
	CP	(HL)		; compare with that in workspace.

	ORG	$08DF
ME_OLD_L1:
	DEC	DE		; point to start of
	DEC	HL		; respective lines again.
	JR	NC,ME_NEW_L2	; forward to ME-NEW-L2 if line number in
				; workspace is less than or equal to current
				; program line as has to be added to program.
	PUSH	HL		; else save workspace pointer.
	EX	DE,HL		; transfer prog pointer to HL
	CALL	NEXT_ONE		; finds next line in DE.
	POP	HL		; restore workspace pointer
	JR	ME_OLD_LP		; back until destination position
				; in program area found.

; ---
; the branch was here with an insertion or replacement point.

	ORG	$08EB
ME_NEW_L2:
	CALL	ME_ENTER		; enters the line
	JR	ME_NEW_LP		; loop back.

; ---
; the branch was here when the location in workspace held a variable.

	ORG	$08F0
ME_VAR_LP:
	LD	A,(HL)		; fetch first byte of workspace variable.
	LD	C,A		; copy to C also.
	CP	$80		; is it the end-marker ?
	RET	Z		; return if so as complete.		>>>>>
	PUSH	HL		; save workspace area pointer.
	LD	HL,(VARS)		; load HL with VARS - start of variables area.

	ORG	$08F9
ME_OLD_VP:
	LD	A,(HL)		; fetch first byte.
	CP	$80		; is it the end-marker ?
	JR	Z,ME_VAR_L2	; forward if so to add variable
				; at end of variables area.
	CP	C		; compare with variable in workspace area.
	JR	Z,ME_OLD_V2	; forward if a match to replace.

; else entire variables area has to be searched.

	ORG	$0901
ME_OLD_V1:
	PUSH	BC		; save character in C.
	CALL	NEXT_ONE		; gets following variable address in DE.
	POP	BC		; restore character in C
	EX	DE,HL		; transfer next address to HL.
	JR	ME_OLD_VP		; loop back to ME-OLD-VP

; ---
; the branch was here when first characters of name matched.

	ORG	$0909
ME_OLD_V2:
	AND	$E0		; keep bits 11100000
	CP	$A0		; compare 10100000 - a long-named variable.
	JR	NZ,ME_VAR_L1	; forward if just one-character.

; but long-named variables have to be matched character by character.

	POP	DE		; fetch workspace 1st character pointer
	PUSH	DE		; and save it on the stack again.
	PUSH	HL		; save variables area pointer on stack.

	ORG	$0912
ME_OLD_V3:
	INC	HL		; address next character in vars area.
	INC	DE		; address next character in workspace area.
	LD	A,(DE)		; fetch workspace character.
	CP	(HL)		; compare to variables character.
	JR	NZ,ME_OLD_V4	; forward with a mismatch.
	RLA			; test if the terminal inverted character.
	JR	NC,ME_OLD_V3	; loop back if more to test.

; otherwise the long name matches in its entirety.

	POP	HL		; restore pointer to first character of variable
	JR	ME_VAR_L1		; forward

; ---
; the branch is here when two characters don't match

	ORG	$091E
ME_OLD_V4:
	POP	HL		; restore the prog/vars pointer.
	JR	ME_OLD_V1		; back to resume search.

; ---
; branch here when variable is to replace an existing one

	ORG	$0921
ME_VAR_L1:
	LD	A,$FF		; indicate a replacement.

; this entry point is when A holds $80 indicating a new variable.

	ORG	$0923
ME_VAR_L2:
	POP	DE		; pop workspace pointer.
	EX	DE,HL		; now make HL workspace pointer, DE vars pointer
	INC	A		; zero flag set if replacement.
	SCF			; set carry flag indicating a variable not a
				; program line.
	CALL	ME_ENTER		; copies variable in.
	JR	ME_VAR_LP		; loop back

; ------------------------
; Merge a Line or Variable
; ------------------------
; A BASIC line or variable is inserted at the current point. If the line
; number or variable names match (zero flag set) then a replacement takes
; place.

	ORG	$092C
ME_ENTER:	JR	NZ,ME_ENT_1	; forward for insertion only.

; but the program line or variable matches so old one is reclaimed.

	EX	AF,AF'		; save flag??
	LD	($5C5F),HL	; preserve workspace pointer in dynamic X_PTR
	EX	DE,HL		; transfer program dest pointer to HL.
	CALL	NEXT_ONE		; finds following location
				; in program or variables area.
	CALL	RECLAIM_2		; reclaims the space between.
	EX	DE,HL		; transfer program dest pointer back to DE.
	LD	HL,(X_PTR)	; fetch adjusted workspace pointer from X_PTR
	EX	AF,AF'		; restore flags.

; now the new line or variable is entered.

	ORG	$093E
ME_ENT_1:	EX	AF,AF'		; save or re-save flags.
	PUSH	DE		; save dest pointer in prog/vars area.
	CALL	NEXT_ONE		; finds next in workspace.
				; gets next in DE, difference in BC.
				; prev addr in HL
	LD	(X_PTR),HL	; store pointer
	LD	HL,(PROG)		; load HL from system variable
	EX	(SP),HL		; swap with prog/vars pointer on stack.
	PUSH	BC		; ** save length of new program line/variable.
	EX	AF,AF'		; fetch flags back.
	JR	C,ME_ENT_2	; skip if variable
	DEC	HL		; address location before pointer
	CALL	MAKE_ROOM		; creates room for BASIC line
	INC	HL		; address next.
	JR	ME_ENT_3		; forward

; ---

	ORG	$0955
ME_ENT_2:	CALL	MAKE_ROOM		; creates room for variable.

	ORG	$0958
ME_ENT_3:	INC	HL		; address next?
	POP	BC		; ** pop length
	POP	DE		; * pop value for PROG which may have been
				; altered by POINTERS if first line.
	LD	(PROG),DE		; set PROG to original value.
	LD	DE,(X_PTR)	; fetch adjusted workspace pointer from X_PTR
	PUSH	BC		; save length
	PUSH	DE		; and workspace pointer
	EX	DE,HL		; make workspace pointer source, prog/vars
				; pointer the destination
	LDIR			; copy bytes of line or variable into new area.
	POP	HL		; restore workspace pointer.
	POP	BC		; restore length.
	PUSH	DE		; save new prog/vars pointer.
	CALL	RECLAIM_2		; reclaims the space used by the line or
				; variable in workspace block as no longer
				; required and space could be useful for
				; adding more lines.
	POP	DE		; restore the prog/vars pointer
	RET			; return.

; --------------------------
; THE 'SAVE CONTROL' ROUTINE
; --------------------------
; A branch from the main SAVE-ETC routine at SAVE-ALL.
; First the header data is saved. Then after a wait of 1 second
; the data itself is saved.
; HL points to start of data.
; IX points to start of descriptor.

	ORG	$0970
SA_CONTRL:
	PUSH	HL		; save start of data
	LD	A,$FD		; select system channel 'S'
	CALL	CHAN_OPEN		;
	XOR	A		; clear to address table directly
	LD	DE,TAPE_MSGS	;
	CALL	PO_MSG		; 'Start tape then press any key.'
	SET	5,(IY+$02)	; TV_FLAG  - Signal lower screen to be cleared.
	CALL	CONS_IN		; read console for single key
	PUSH	IX		; save pointer to descriptor.
	LD	DE,$0011		; there are seventeen bytes.
	XOR	A		; signal a header.
	CALL	SA_BYTES		;
	POP	IX		; restore descriptor pointer.
	LD	B,$32		; wait for a second - 50 interrupts.

	ORG	$0991
SA_1_SEC:	HALT			; wait for interrupt
	DJNZ	SA_1_SEC		; back until pause complete.
	LD	E,(IX+$0B)	; fetch length of bytes from the
	LD	D,(IX+$0C)	; descriptor.
	LD	A,$FF		; signal data bytes.
	POP	IX		; retrieve pointer to start
	JP	SA_BYTES		; jump back

; Arrangement of two headers in workspace.
; Originally IX addresses first location and only one header is required
; when saving.
;
; OLD	NEW	PROG	DATA	DATA	CODE
; HEADER	HEADER		num	chr		NOTES.
; ------	------	----	----	----	----	-----------------------------
; IX-$11	IX+$00	0	1	2	3	Type.
; IX-$10	IX+$01	x	x	x	x	F ($FF if filename is null).
; IX-$0F	IX+$02	x	x	x	x	i
; IX-$0E	IX+$03	x	x	x	x	l
; IX-$0D	IX+$04	x	x	x	x	e
; IX-$0C	IX+$05	x	x	x	x	n
; IX-$0B	IX+$06	x	x	x	x	a
; IX-$0A	IX+$07	x	x	x	x	m
; IX-$09	IX+$08	x	x	x	x	e
; IX-$08	IX+$09	x	x	x	x	.
; IX-$07	IX+$0A	x	x	x	x	(terminal spaces).
; IX-$06	IX+$0B	lo	lo	lo	lo	Total
; IX-$05	IX+$0C	hi	hi	hi	hi	Length of datablock.
; IX-$04	IX+$0D	Auto	-	-	Start	Various
; IX-$03	IX+$0E	Start	a-z	a-z	addr	($80 if no autostart).
; IX-$02	IX+$0F	lo	-	-	-	Length of Program
; IX-$01	IX+$10	hi	-	-	-	only i.e. without variables.
;

; -------------------
; THE 'SOUND' ROUTINE
; -------------------
; Works like the Timex command but uses the 128's AY addresses.

S_LOOP:	RST	20H		; NEXT_CHAR.

; -> entry point

SOUND:	CALL	EXPT_2NUM	; check for two comma separated numeric expressions.
	CALL	SYNTAX_Z		; checking syntax?
	JR	Z,SOUND_1	; jump if so.
	CALL	FP_TO_A		; get data in A.
	PUSH	AF		; save data.
	CALL	FP_TO_A		; get address in A.
	CP	$11		; range includes I/O registers.
	JP	NC,REPORT_B	; out of range.
	DEC	A		; jump if A >= $80
	INC	A		;
	JP	M,REPORT_B	; out of range.
	LD	BC,$FFFD		; select address register.
	OUT	(C),A		; output address regiser.
	POP	AF		; get data.
	LD	B,$BF		; select data register (BC=$BFFD).
	OUT	(C),A		; output data register.

SOUND_1:	RST	18H		; GET_CHAR.
	CP	';'		; is it ';'?
	JR	Z,S_LOOP		; jump back to check next pair.
	CALL	CHECK_END	; exit if not.
	RET			; return

; ----------------------
; THE '16K TEST' ROUTINE
; ----------------------
;   11 bytes. This routine works out if the program is running on a 16K machine. 
;; $04AA
TEST_16K:
	LD	A,(DE)		; get the contents of the top byte of
				; addressable memory.
	CP	$00		; on any machine other than a 16K it will
				; still be zero.
	JR	Z,TEST_16K_2	; but if it is a 16K machine there is no RAM
	XOR	A		; at that address. The register must be reset
	LD	D,$7F		; and the top of memory lowered to $7FFF.

TEST_16K_2:
	JP	START_3		; jump forward to common code at START-NEW.

;**************************************************
;** Part 5. SCREEN AND PRINTER HANDLING ROUTINES **
;**************************************************

; --------------------------
; THE 'PRINT OUTPUT' ROUTINE
; --------------------------
; This is the routine most often used by the RST 10 restart although the
; subroutine is on two occasions called directly when it is known that
; output will definitely be to the lower screen.

PRINT_OUT2:
	ADD	A,$5B		;
	POP	DE		;
	CALL	PO_T		; call PO_T to print TOKENS
	JP	PO_STORE		; exit via PO_STORE

PRINT_OUT3:
	CP	$18		; is it a printable character or token?
	JP	NC,PO_ABLE	; jump forward if so.
	LD	HL,CTRLCHRTAB - 6	; address $0A0B - the base address of control
				; character table - where zero would be.
	LD	E,A		; control character 06 - 23d
	LD	D,$00		; is transferred to DE.
	ADD	HL,DE		; index into table.
	LD	E,(HL)		; fetch the offset to routine.
	ADD	HL,DE		; add to make HL the address.
	PUSH	HL		; push the address.
	JP	PO_FETCH		;

; -> entry point

	ORG	$09F4
PRINT_OUT:
	CALL	PO_FETCH		; fetches print position
				; to HL register pair.
	CP	$06		; is it a token in the range 00-05 ?
	CALL	C,PRINT_OUT2	; call if so
	JP	PRINT_OUT3	; avoid the IM2 vector.

X09FF:	DEFW	$FE69		; Compatibility Note. Some software uses
				; $09FF as an Interrupt 2 vector
				; e.g. CP Software Extended Basic.
				; (normally holds $FE69 as here)

; ---

; ----------------
; Read the console
; ----------------
; This replicates the functionality of the KEY_INPUT routine without
; considering extended mode keys
; It has to accept chr$ 13 or any ASCII key of space and above.
; (16 bytes)

CONS_IN:	LD	HL,LAST_K	; System Variable LAST_K.
	LD	(HL),L		; value 08 is invalid.

WTKEY:	LD	A,(HL)		; Updated by interrupt.
	CP	$0D		; ENTER key ?
	JR	Z,CONS_K		; forward if so.
	CP	$20		; compare with LAST_K value
	JR	C,WTKEY		; back until a space or higher

CONS_K:	JP	KI_END		; use last part of key_input

; -----------------------------
; THE 'CONTROL CHARACTER' TABLE
; -----------------------------
; For control characters in the range 6 - 23d the following table
; is indexed to provide an offset to the handling routine that
; follows the table.

	ORG	$0A11
CTRLCHRTAB:
	DEFB	PO_COMMA - $	; 06d offset $4E	PRINT comma
	DEFB	PO_QUEST - $	; 07d offset $57	BELL
	DEFB	PO_BACK_1 - $	; 08d offset $10	LEFT
	DEFB	PO_RIGHT - $	; 09d offset $29	RIGHT
	DEFB	PO_QUEST - $	; 10d offset $54	DOWN
	DEFB	PO_QUEST - $	; 11d offset $53	UP
	DEFB	PO_QUEST - $	; 12d offset $52	CLS
	DEFB	PO_ENTER - $	; 13d offset $37	ENTER
	DEFB	PO_QUEST - $	; 14d offset $50	not used
	DEFB	PO_QUEST - $	; 15d offset $4F	not used	
	DEFB	PO_1_OPER - $	; 16d offset $5F	INK control
	DEFB	PO_1_OPER - $	; 17d offset $5E	PAPER control
	DEFB	PO_1_OPER - $	; 18d offset $5D	FLASH control
	DEFB	PO_1_OPER - $	; 19d offset $5C	BRIGHT control
	DEFB	PO_1_OPER - $	; 20d offset $5B	INVERSE control	
	DEFB	PO_1_OPER - $	; 21d offset $5A	OVER control
	DEFB	PO_2_OPER - $	; 22d offset $54	AT control	
	DEFB	PO_2_OPER - $	; 23d offset $53	TAB control

; -------------------------
; THE 'CURSOR LEFT' ROUTINE
; -------------------------
; Backspace and up a line if that action is from the left of screen.
; For ZX printer backspace up to first column but not beyond.

	ORG	$0A23
PO_BACK_1:
	INC	C		; move left one column.
	LD	A,$22		; value $21 is leftmost column.
	CP	C		; have we passed ?
	JR	NZ,PO_BACK_3	; jump if not and store new position.
	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	JR	NZ,PO_BACK_2	; jump if so, as we are unable to
				; backspace from the leftmost position.
	INC	B		; move up one screen line
	LD	C,$02		; the rightmost column position.
	LD	A,$19		; Note. Corrected.
	CP	B		; has position moved past top of screen ?
	JR	NZ,PO_BACK_3	; if not and store new position.
	DEC	B		; else back to $18.

	ORG	$0A38
PO_BACK_2:
	LD	C,$21		; the leftmost column position.

	ORG	$0A3A
PO_BACK_3:
	JP	CL_SET		; to CL_SET and PO_STORE to save new
				; position in system variables.

; --------------------------
; THE 'CURSOR RIGHT' ROUTINE
; --------------------------
; This moves the print position to the right leaving a trail in the
; current background colour.
; "However the programmer has failed to store the new print position
; so CHR$ 9 will only work if the next print position is at a newly
; defined place.
; e.g. PRINT PAPER 2; CHR$ 9; AT 4,0;
; does work but is not very helpful"
; - Dr. Ian Logan, Understanding Your Spectrum, 1982.

	ORG	$0A3D
PO_RIGHT:LD	A,(P_FLAG)	; fetch value
	PUSH	AF		; and save it on stack.
	LD	(IY+$57),$01	; temporarily set P_FLAG 'OVER 1'.
	LD	A,$20		; prepare a space.
	CALL	PO_ABLE		; Routine PO_ABLE updates position.
	POP	AF		; restore the permanent flag.
	LD	(P_FLAG),A	; and restore system variable
	RET			; return column position is already updated.

; -----------------------
; Perform carriage return
; -----------------------
; A carriage return is 'printed' to screen or printer buffer.

	ORG	$0A4F
PO_ENTER:BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	JP	NZ,COPY_BUFF	; jump if so, to flush buffer and reset
				; the print position.
	LD	C,$21		; the leftmost column position.
	CALL	PO_SCR		; handles any scrolling required.
	DEC	B		; to next screen line.
	JP	CL_SET		; jump forward to store new position.

; -----------
; Print comma
; -----------
; The comma control character. The 32 column screen has two 16 character
; tabstops.  The routine is only reached via the control character table.

	ORG	$0A5F
PO_COMMA:
;;;	CALL	PO_FETCH		; Note. seems unnecessary.
	LD	A,C		; the column position. $21-$01
	DEC	A		; move right. $20-$00
	DEC	A		; and again $1F-$00 or $FF if trailing
	AND	$10		; will be $00 or $10.
	JR	PO_FILL		; forward

	DEFS	3

; -------------------
; Print question mark
; -------------------
; This routine prints a question mark which is commonly
; used to print an unassigned control character in range 0-31d.
; there are a surprising number yet to be assigned.

	ORG	$0A69
PO_QUEST:LD	A,$3F		; prepare the character '?'.
	JR	PO_ABLE		; forward

; --------------------------------
; Control characters with operands
; --------------------------------
; Certain control characters are followed by 1 or 2 operands.
; The entry points from control character table are PO-2-OPER and PO-1-OPER.
; The routines alter the output address of the current channel so that
; subsequent RST $10 instructions take the appropriate action
; before finally resetting the output address back to PRINT-OUT.

	ORG	$0A6D
PO_TV_2:	LD	DE,PO_CONT	; will be next output routine
	LD	(TVDATA_H),A	; store first operand
	JR	PO_CHANGE	; forward		>>

; ---

; -> This initial entry point deals with two operands - AT or TAB.

	ORG	$0A75
PO_2_OPER:
	LD	DE,PO_TV_2	; will be next output routine
	JR	PO_TV_1		; forward

; ---

; -> This initial entry point deals with one operand INK to OVER.

	ORG	$0A7A
PO_1_OPER:
	LD	DE,PO_CONT	; will be next output routine

	ORG	$0A7D
PO_TV_1:	LD	(TVDATA),A	; store control code in TVDATA-lo

	ORG	$0A80
PO_CHANGE:
	LD	HL,(CURCHL)	; use CURCHL to find current output channel.
	LD	(HL),E		; make it
	INC	HL		; the supplied
	LD	(HL),D		; address from DE.
	RET			; return.

; ---

	ORG	$0A87
PO_CONT:	LD	DE,PRINT_OUT	;
	CALL	PO_CHANGE	; to restore normal channel.
	LD	HL,(TVDATA)	; gives control code and possible
				; subsequent character
	LD	D,A		; save current character
	LD	A,L		; the stored control code
	CP	$16		; was it INK to OVER (1 operand) ?
	JP	C,CO_TEMP_5	;
	JR	NZ,PO_TAB	; jump if not 22d i.e. 23d TAB.

; Else must have been 22 decimal AT.

; Note the next location is called by the Opus Discovery Disk Interface.

	LD	B,H		; line to H (0-23d)
	LD	C,D		; column to C (0-31d)
	LD	A,$1F		; the value 31d
	SUB	C		; reverse the column number.
	JR	C,PO_AT_ERR	; if C was greater than 31d.
	ADD	A,$02		; transform to system range $02-$21
	LD	C,A		; and place in column register.
	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	JR	NZ,PO_AT_SET	; as line can be ignored.
	LD	A,$16		; 22 decimal
	SUB	B		; subtract line number to reverse
				; 0 - 22 becomes 22 - 0.

	ORG	$0AAC
PO_AT_ERR:
	JP	C,REPORT_Bb	; if higher than 22 decimal
				; Out of range.
	INC	A		; adjust for system range $01-$17
	LD	B,A		; place in line register
	INC	B		; adjust to system range  $02-$18
	BIT	0,(IY+$02)	; TV_FLAG  - Lower screen in use ?
	JP	NZ,PO_SCR	; exit to PO_SCR to test for scrolling
	CP	(IY+$31)		; Compare against DF_SZ
	JP	C,REPORT_5	; if too low
				; Out of screen.

	ORG	$0ABF
PO_AT_SET:
	JP	CL_SET		; print position is valid so exit via CL-SET

; ---

; Continue here when dealing with TAB.
; Note. In BASIC, TAB is followed by a 16-bit number and was initially
; designed to work with any output device.

	ORG	$0AC2
PO_TAB:	LD	A,H		; transfer parameter to A
				; Losing current character -
				; High byte of TAB parameter.

	ORG	$0AC3
PO_FILL:	CALL	PO_FETCH		; HL-addr, BC=line/column.
				; column 1 (right), $21 (left)
	ADD	A,C		; add operand to current column
	DEC	A		; range 0 - 31+
	AND	$1F		; make range 0 - 31d
	RET	Z		; return if result zero
	LD	D,A		; Counter to D
	SET	0,(IY+$01)	; update FLAGS  - signal suppress leading space.

	ORG	$0AD0
PO_SPACE:
	LD	A,$20		; space character.
	CALL	PO_SAVE		; prints the character
				; using alternate set (normal output routine)
	DEC	D		; decrement counter.
	JR	NZ,PO_SPACE	; jump until done
	RET			; return

; ----------------------
; Printable character(s)
; ----------------------
; This routine prints printable characters and continues into
; the position store routine

	ORG	$0AD9
PO_ABLE:	CALL	PO_ANY		; and continue into position store routine.

; ----------------------------
; THE 'POSITION STORE' ROUTINE
; ----------------------------
; This routine updates the system variables associated with the main screen,
; the lower screen/input buffer or the ZX printer.

	ORG	$0ADC
PO_STORE:BIT	1,(IY+$01)	; Test FLAGS - is printer in use ?
	JR	NZ,PO_ST_PR	; Forward, if so
	BIT	0,(IY+$02)	; Test TV_FLAG - is lower screen in use ?
	JR	NZ,PO_ST_E	; Forward, if so

; This section deals with the upper screen.

	LD	(S_POSN),BC	; Update - line/column upper screen
	LD	(DF_CC),HL	; Update - upper display file address
	RET			; Return.

; ---

; This section deals with the lower screen.

	ORG	$0AF0
PO_ST_E:	LD	(SPOSNL),BC	; Update line/column lower screen
	LD	(ECHO_E),BC	; Update line/column input buffer
	LD	(DF_CCL),HL	; Update lower screen memory address
	RET			; Return.

; ---

; This section deals with the ZX Printer.

	ORG	$0AFC
PO_ST_PR:LD	(IY+$45),C	; Update P_POSN column position printer
	LD	(23680),HL	; Update PR_CC - full printer buffer memory
				; address
	RET			; Return.

; Note. that any values stored in location 23681 will be overwritten with
; the value 91 decimal.

; ----------------------------
; THE 'POSITION FETCH' ROUTINE
; ----------------------------
; This routine fetches the line/column and display file address of the upper
; and lower screen or, if the printer is in use, the column position and
; absolute memory address.
; Note. that PR-CC-hi (23681) is used by this routine and if, in accordance
; with the manual (that says this is unused), the location has been used for
; other purposes, then subsequent output to the printer buffer could corrupt
; a 256-byte section of memory.

	ORG	$0B03
PO_FETCH:BIT	1,(IY+$01)	; Test FLAGS - is printer in use ?
	JR	NZ,PO_F_PR	; Forward, if so

; assume upper screen in use and thus optimize for path that requires speed.

	LD	BC,(S_POSN)	; Fetch line/column
	LD	HL,(DF_CC)	; Fetch display file address
	BIT	0,(IY+$02)	; Test TV_FLAG - lower screen in use ?
	RET	Z		; Return if upper screen in use.

; Overwrite registers with values for lower screen.

	LD	BC,(SPOSNL)	; Fetch line/column
	LD	HL,(DF_CCL)	; Fetch display file address
	RET			; Return.

; ---

; This section deals with the ZX Printer.

	ORG	$0B1D
PO_F_PR:	LD	C,(IY+$45)	; Fetch column from P_POSN.
	LD	HL,(23680)	; Fetch printer buffer address.
	RET			; Return.

; ---------------------------------
; THE 'PRINT ANY CHARACTER' ROUTINE
; ---------------------------------
; This routine is used to print any character in range 32d - 255d
; It is only called from PO_ABLE which continues into PO_STORE

	ORG	$0B24
PO_ANY:	CP	$80		; ASCII ?
	JR	C,PO_CHAR	; jump if so.
	CP	$90		; test if a block graphic character.
	JR	NC,PO_TKN_UDG	; jump to print tokens and UDGs

; The 16 2*2 mosaic characters 128-143 decimal are formed from
; bits 0-3 of the character.

	LD	B,A		; save character
	CALL	PO_GR_1		; to construct top half then bottom half.
	CALL	PO_FETCH		; fetches print position.
	LD	DE,MEM_0		; location of 8 bytes of character
	JR	PR_ALL		; jump to print to screen or printer

; ---

	ORG	$0B38
PO_GR_1:	LD	HL,MEM_0		; - a temporary buffer in
				; systems variables which is normally used
				; by the calculator.
	CALL	PO_GR_2		; to construct top half
				; and continue into routine to construct
				; bottom half.

	ORG	$0B3E
PO_GR_2:	RR	B		; rotate bit 0/2 to carry
	SBC	A,A		; result $00 or $FF
	AND	$0F		; mask off right hand side
	LD	C,A		; store part in C
	RR	B		; rotate bit 1/3 of original chr to carry
	SBC	A,A		; result $00 or $FF
	AND	$F0		; mask off left hand side
	OR	C		; combine with stored pattern
	LD	C,$04		; four bytes for top/bottom half

	ORG	$0B4C
PO_GR_3:	LD	(HL),A		; store bit patterns in temporary buffer
	INC	HL		; next address
	DEC	C		; jump back
	JR	NZ,PO_GR_3	; until byte is stored 4 times
	RET			; return

; ---

; Tokens and User defined graphics are now separated.

	ORG	$0B52
PO_TKN_UDG:
	SUB	$A5		; the 'RND' character
	JR	NC,PO_T		; to print tokens
	ADD	A,$15		; add 21d to restore to 0 - 20
	PUSH	BC		; save current print position
	LD	BC,(UDG)		; fetch UDG to address bit patterns
	JR	PO_CHAR_2	; - common code to lay down
				; a bit patterned character

; ---

	ORG	$0B5F
PO_T:	CALL	PO_TOKENS	; prints tokens
	JP	PO_FETCH		; exit via a JUMP to PO_FETCH as this routine
				; must continue into PO_STORE.
				; A JR instruction could be used.

; This point is used to print ASCII characters  32d - 127d.

	ORG	$0B65
PO_CHAR:	PUSH	BC		; save print position
	LD	BC,(CHARS)	;

; This common code is used to transfer the character bytes to memory.

	ORG	$0B6A
PO_CHAR_2:
	EX	DE,HL		; transfer destination address to DE
	LD	HL,FLAGS		;
	RES	0,(HL)		; allow for leading space
	CP	$20		; is it a space ?
	JR	NZ,PO_CHAR_3	; jump if not
	SET	0,(HL)		; signal no leading space to FLAGS

	ORG	$0B76
PO_CHAR_3:
	LD	H,$00		; set high byte to 0
	LD	L,A		; character to A
				; 0-21 UDG or 32-127 ASCII.
	ADD	HL,HL		; multiply
	ADD	HL,HL		; by
	ADD	HL,HL		; eight
	ADD	HL,BC		; HL now points to first byte of character
	POP	BC		; the source address CHARS or UDG
	EX	DE,HL		; character address to DE

; ----------------------------------
; THE 'PRINT ALL CHARACTERS' ROUTINE
; ----------------------------------
; This entry point entered from above to print ASCII and UDGs but also from
; earlier to print mosaic characters.
; HL=destination
; DE=character source
; BC=line/column

	ORG	$0B7F
PR_ALL:	LD	A,C		; column to A
	DEC	A		; move right
	LD	A,$21		; pre-load with leftmost position
	JR	NZ,PR_ALL_1	; but if not zero jump
	DEC	B		; down one line
	LD	C,A		; load C with $21
	BIT	1,(IY+$01)	; test FLAGS  - Is printer in use
	JR	Z,PR_ALL_1	; jump if not
	PUSH	DE		; save source address
	CALL	COPY_BUFF	; outputs line to printer
	POP	DE		; restore character source address
	LD	A,C		; the new column number ($21) to C

	ORG	$0B93
PR_ALL_1:CP	C		; this test is really for screen - new line ?
	PUSH	DE		; save source
	CALL	Z,PO_SCR		; considers scrolling
	POP	DE		; restore source
	PUSH	BC		; save line/column
	PUSH	HL		; and destination
	LD	A,(P_FLAG)	; fetch to accumulator
	LD	B,$FF		; prepare OVER mask in B.
	RRA			; bit 0 set if OVER 1
	JR	C,PR_ALL_2	;
	INC	B		; set OVER mask to 0

	ORG	$0BA4
PR_ALL_2:RRA			; skip bit 1 of P_FLAG
	RRA			; bit 2 is INVERSE
	SBC	A,A		; will be FF for INVERSE 1 else zero
	LD	C,A		; transfer INVERSE mask to C
	LD	A,$08		; prepare to count 8 bytes
	AND	A		; clear carry to signal screen
	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	JR	Z,PR_ALL_3	; jump if screen
	SET	1,(IY+$30)	; update FLAGS2  - signal printer buffer has
				; been used.
	SCF			; set carry flag to signal printer.

	ORG	$0BB6
PR_ALL_3:EX	DE,HL		; now HL=source, DE=destination

	ORG	$0BB7
PR_ALL_4:EX	AF,AF'		; save printer/screen flag
	LD	A,(DE)		; fetch existing destination byte
	AND	B		; consider OVER
	XOR	(HL)		; now XOR with source
	XOR	C		; now with INVERSE MASK
	LD	(DE),A		; update screen/printer
	EX	AF,AF'		; restore flag
	JR	C,PR_ALL_6	; - printer address update
	INC	D		; gives next pixel line down screen

	ORG	$0BC1
PR_ALL_5:INC	HL		; address next character byte
	DEC	A		; the byte count is decremented
	JR	NZ,PR_ALL_4	; back for all 8 bytes
	EX	DE,HL		; destination to HL
	DEC	H		; bring back to last updated screen position
	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	CALL	Z,PO_ATTR	; if not, call routine PO_ATTR to update
				; corresponding colour attribute.
	POP	HL		; restore original screen/printer position
	POP	BC		; and line column
	DEC	C		; move column to right
	INC	HL		; increase screen/printer position
	RET			; return and continue into PO_STORE
				; within PO_ABLE

; ---

; This branch is used to update the printer position by 32 places
; Note. The high byte of the address D remains constant (which it should).

	ORG	$0BD3
PR_ALL_6:EX	AF,AF'		; save the flag
	LD	A,$20		; load A with 32 decimal
	ADD	A,E		; add this to E
	LD	E,A		; and store result in E
	EX	AF,AF'		; fetch the flag
	JR	PR_ALL_5		; back

; -----------------------------------
; THE 'GET ATTRIBUTE ADDRESS' ROUTINE
; -----------------------------------
; This routine is entered with the HL register holding the last screen
; address to be updated by PRINT or PLOT.
; The Spectrum screen arrangement leads to the L register holding the correct
; value for the attribute file and it is only necessary to manipulate H to
; form the correct colour attribute address.

	ORG	$0BDB
PO_ATTR:	LD	A,H		; fetch high byte $40 - $57
	RRCA			; shift
	RRCA			; bits 3 and 4
	RRCA			; to right.
	AND	$03		; range is now 0 - 2
	OR	$58		; form correct high byte for third of screen
	LD	H,A		; HL is now correct
	LD	DE,(ATTR_T)	; make D hold ATTR_T, E hold MASK_T
	LD	A,(HL)		; fetch existing attribute
	XOR	E		; apply masks
	AND	D		;
	XOR	E		;
	BIT	6,(IY+$57)	; test P_FLAG  - is this PAPER 9 ??
	JR	Z,PO_ATTR_1	; skip if not.
	AND	$C7		; set paper
	BIT	2,A		; to contrast with ink
	JR	NZ,PO_ATTR_1	; skip
	XOR	$38		;

	ORG	$0BFA
PO_ATTR_1:
	BIT	4,(IY+$57)	; test P_FLAG  - Is this INK 9 ??
	JR	Z,PO_ATTR_2	; skip if not
	AND	$F8		; make ink
	BIT	5,A		; contrast with paper.
	JR	NZ,PO_ATTR_2	;
	XOR	$07		;

	ORG	$0C08
PO_ATTR_2:
	LD	(HL),A		; save the new attribute.
	RET			; return.

; ---------------------------------
; THE 'MESSAGE PRINTING' SUBROUTINE
; ---------------------------------
; This entry point is used to print tape, boot-up, scroll? and error messages.
; On entry the DE register points to an initial step-over byte or the
; inverted end-marker of the previous entry in the table.
; Register A contains the message number, often zero to print first message.
; (HL has nothing important usually P_FLAG)

	ORG	$0C0A
PO_MSG:	PUSH	HL		; put hi-byte zero on stack to suppress
	LD	H,$00		; trailing spaces
	EX	(SP),HL		; ld h,0; push hl would have done ?.
	JR	PO_TABLE		; forward

; ---

; This entry point prints the BASIC keywords, '<>' etc. from alt set

	ORG	$0C10
PO_TOKENS:
	LD	DE,TKN_TABLE	;
	PUSH	AF		; save the token number to control
				; trailing spaces - see later *

; ->

	ORG	$0C14
PO_TABLE:CALL	PO_SEARCH	; will set carry for
				; all messages and function words.
	JR	C,PO_EACH	; forward if not a command, '<>' etc.
	LD	A,$20		; prepare leading space
	BIT	0,(IY+$01)	; test FLAGS  - leading space if not set
	CALL	Z,PO_SAVE	; to print a space without disturbing registers.

	ORG	$0C22
PO_EACH:	LD	A,(DE)		; Fetch character from the table.
	AND	$7F		; Cancel any inverted bit.
	CALL	PO_SAVE		; to print using the alternate set of registers.
	LD	A,(DE)		; Re-fetch character from table.
	INC	DE		; Address next character in the table.
	ADD	A,A		; Was character inverted ?
				; (this also doubles character)
	JR	NC,PO_EACH	; back if not.
	POP	DE		; * re-fetch trailing space byte to D
	CP	$48		; was the last character '$' ?
	JR	Z,PO_TR_SP	; forwatd to consider trailing space if so.
	CP	$82		; was it < 'A' i.e. '#','>','=' from tokens
				; or ' ','.' (from tape) or '?' from scroll
	RET	C		; Return if so as no trailing space required.

	ORG	$0C35
PO_TR_SP:LD	A,D		; The trailing space flag (zero if an error msg)
	CP	$03		; Test against RND, INKEY$ and PI which have no
				; parameters and therefore no trailing space.
	RET	C		; Return if no trailing space.
	LD	A,$20		; Prepare the space character and continue to
				; print and make an indirect return.

; -----------------------------------
; THE 'RECURSIVE PRINTING' SUBROUTINE
; -----------------------------------
; This routine which is part of PRINT-OUT allows RST $10 to be used
; recursively to print tokens and the spaces associated with them.
; It is called on three occasions when the value of DE must be preserved.

	ORG	$0C3B
PO_SAVE:	PUSH	DE		; Save DE value.
	EXX			; Switch in main set
	RST	10H		; PRINT_A prints using this alternate set.
	EXX			; Switch back to this alternate set.
	POP	DE		; Restore the initial DE value.
	RET			; Return.

; ------------
; Table search
; ------------
; This subroutine searches a message or the token table for the
; message number held in A. DE holds the address of the table.

	ORG	$0C41
PO_SEARCH:
	PUSH	AF		; save the message/token number
	EX	DE,HL		; transfer DE to HL
	INC	A		; adjust for initial step-over byte

	ORG	$0C44
PO_STEP:	BIT	7,(HL)		; is character inverted ?
	INC	HL		; address next
	JR	Z,PO_STEP	; back if not inverted.
	DEC	A		; decrease counter
	JR	NZ,PO_STEP	; back if not zero
	EX	DE,HL		; transfer address to DE
	POP	AF		; restore message/token number
	CP	$20		; return with carry set
	RET	C		; for all messages and function tokens
	LD	A,(DE)		; test first character of token
	SUB	$41		; and return with carry set
	RET			; if it is less that 'A'
				; i.e. '<>', '<=', '>='

; ---------------
; Test for scroll
; ---------------
; This test routine is called when printing carriage return, when considering
; PRINT AT and from the general PRINT ALL characters routine to test if
; scrolling is required, prompting the user if necessary.
; This is therefore using the alternate set.
; The B register holds the current line.

	ORG	$0C55
PO_SCR:	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	RET	NZ		; return immediately if so.
	LD	DE,CL_SET	; set DE to address: CL_SET
	PUSH	DE		; and push for return address.
	LD	A,B		; transfer the line to A.
	BIT	0,(IY+$02)	; test TV_FLAG - lower screen in use ?
	JP	NZ,PO_SCR_4	; jump forward if so.
	CP	(IY+$31)		; greater than DF_SZ display file size ?
	JR	C,REPORT_5	; forward if less.
				; 'Out of screen'
	RET	NZ		; return (via CL_SET) if greater
	BIT	4,(IY+$02)	; test TV_FLAG  - Automatic listing ?
	JR	Z,PO_SCR_2	; forward if not.
	LD	E,(IY+$2D)	; fetch BREG - the count of scroll lines to E.
	DEC	E		; decrease and jump
	JR	Z,PO_SCR_3	; jump if zero and scrolling required.
	LD	A,$00		; explicit - select channel zero.
	CALL	CHAN_OPEN	; opens it.
	LD	SP,(LIST_SP)	; set stack pointer
	RES	4,(IY+$02)	; reset TV_FLAG  - signal auto listing finished.
	RET			; return ignoring pushed value, CL_SET
				; to MAIN or EDITOR without updating
				; print position >>

; ---


	ORG	$0C86
REPORT_5:RST	08H		; ERROR_1
	DEFB	$04		; Error Report: Out of screen

; continue here if not an automatic listing.

	ORG	$0C88
PO_SCR_2:DEC	(IY+$52)		; decrease SCR_CT
	JR	NZ,PO_SCR_3	; forward to scroll display if result not zero.

; now produce prompt.

	LD	A,$18		; reset
	SUB	B		; the
	LD	(SCR_CT),A	; scroll count
	LD	HL,(ATTR_T)	; L=ATTR_T, H=MASK_T
	PUSH	HL		; save on stack
	LD	A,(P_FLAG)	;
	PUSH	AF		; save on stack to prevent lower screen
				; attributes (BORDCR etc.) being applied.
	LD	A,$FD		; select system channel 'K'
	CALL	CHAN_OPEN	; opens it
	XOR	A		; clear to address message directly
	LD	DE,SCRL_MSSG	;
	CALL	PO_MSG		; prints to lower screen
	SET	5,(IY+$02)	; set TV_FLAG  - signal lower screen requires
				; clearing
;;;	LD	HL,FLAGS		;
;;;	SET	3,(HL)		; signal 'L' mode.
	RES	5,(IY+$01)	; signal 'no new key'.
	CALL	CONS_IN		; read console for single key
	JR	PO_SCR_2A	; skips 3 unused bytes

	DEFS	3

PO_SCR_2A:
	CP	$20		; space is considered as BREAK
	JR	Z,REPORT_D	; forwatd if so
				; 'BREAK, CONT repeats'
	CP	$E2		; is character 'STOP' ?
	JR	Z,REPORT_D	; forward if so
	OR	$20		; convert to lower-case
	CP	$6E		; is character 'n' ?
	JR	Z,REPORT_D	; if so else scroll.
	LD	A,$FE		; select system channel 'S'
	CALL	CHAN_OPEN	;
	POP	AF		; restore original P_FLAG
	LD	(P_FLAG),A	; and save in P_FLAG.
	POP	HL		; restore original ATTR_T, MASK_T
	LD	(ATTR_T),HL	; and reset ATTR_T, MASK-T as 'scroll?' has
				; been printed.

	ORG	$0CD2
PO_SCR_3:CALL	CL_SC_ALL	; to scroll whole display
	LD	B,(IY+$31)	; fetch DF_SZ to B
	INC	B		; increase to address last line of display
	LD	C,$21		; set C to $21 (was $21 from above routine)
	PUSH	BC		; save the line and column in BC.
	CALL	CL_ADDR		; finds display address.
	LD	A,H		; now find the corresponding attribute byte
	RRCA			; (this code sequence is used twice
	RRCA			; elsewhere and is a candidate for
	RRCA			; a subroutine.)
	AND	$03		;
	OR	$58		;
	LD	H,A		;
	LD	DE,ATTR_0 + 736	; start of last 'line' of attribute area
	LD	A,(DE)		; get attribute for last line
	LD	C,(HL)		; transfer to base line of upper part
	LD	B,$20		; there are thirty two bytes
	EX	DE,HL		; swap the pointers.

#assert $==$0cf0	
;	ORG	$0CE0		<-- this seems to be an error kio 2015-01-05
PO_SCR_3A:
	LD	(DE),A		; transfer
	LD	(HL),C		; attributes.
	INC	DE		; address next.
	INC	HL		; address next.
	DJNZ	PO_SCR_3A	; loop back for all adjacent attribute lines.
	POP	BC		; restore the line/column.
	RET			; return via CL_SET (was pushed on stack).

; ---

; The message 'scroll?' appears here with last byte inverted.

	ORG	$0CF8
SCRL_MSSG:
	DEFB	$80		; initial step-over byte.
	DEFM	"scroll"
	DEFB	'?'+$80

	ORG	$0D00
REPORT_D:RST	08H		; ERROR_1
	DEFB	$0C		; Error Report: BREAK, CONT repeats

; continue here if using lower display - A holds line number.

	ORG	$0D02
PO_SCR_4:CP	$02		; is line number less than 2 ?
	JR	C,REPORT_5	; jump if so
				; 'Out of Screen'.
	ADD	A,(IY+$31)	; add DF_SZ
	SUB	$19		;
	RET	NC		; return if scrolling unnecessary
	NEG			; Negate to give number of scrolls required.
	PUSH	BC		; save line/column
	LD	B,A		; count to B
	LD	HL,(ATTR_T)	; fetch current ATTR_T, MASK_T to HL.
	PUSH	HL		; and save
	LD	HL,(P_FLAG)	; fetch
	PUSH	HL		; and save.
				; to prevent corruption by input AT
	CALL	TEMPS		; sets to BORDCR etc
	LD	A,B		; transfer scroll number to A.

	ORG	$0D1C
PO_SCR_4A:
	PUSH	AF		; save scroll number.
	LD	HL,DF_SZ		;
	LD	B,(HL)		; fetch old value
	LD	A,B		; transfer to A
	INC	A		; and increment
	LD	(HL),A		; then put back.
	LD	HL,S_POSN_H	; - line
	CP	(HL)		; compare
	JR	C,PO_SCR_4B	; forward if scrolling required
	INC	(HL)		; else increment S_POSN_H
	LD	B,$17		; set count to 23 decimal  ??
				; Note. should be $17 and the top line will be
				; scrolled into the ROM which is harmless on
				; the standard set up.

	ORG	$0D2D
PO_SCR_4B:
	CALL	CL_SCROLL	; scrolls B lines
	POP	AF		; restore scroll counter.
	DEC	A		; decrease
	JR	NZ,PO_SCR_4A	; back until done
	POP	HL		; restore original P_FLAG.
	LD	(IY+$57),L	; and overwrite system variable P_FLAG.
	POP	HL		; restore original ATTR_T/MASK_T.
	LD	(ATTR_T),HL	; and update system variables.
	LD	BC,(S_POSN)	; fetch
	RES	0,(IY+$02)	; signal to TV_FLAG  - main screen in use.
	CALL	CL_SET		; for upper display.
	SET	0,(IY+$02)	; signal to TV_FLAG  - lower screen in use.
	POP	BC		; restore line/column
	RET			; return via CL-SET for lower display.

; ----------------------
; Temporary colour items
; ----------------------
; This subroutine is called 11 times to copy the permanent colour items
; to the temporary ones.

	ORG	$0D4D
TEMPS:	XOR	A		; clear the accumulator
	LD	HL,(ATTR_P)	; fetch L=ATTR_P and H=MASK_P
	BIT	0,(IY+$02)	; test TV_FLAG  - is lower screen in use ?
	JR	Z,TEMPS_1		; skip if not
	LD	H,A		; set H, MASK P, to 00000000.
	LD	L,(IY+$0E)	; fetch BORDCR to L which is used for lower
				; screen.

	ORG	$0D5B
TEMPS_1:	LD	(ATTR_T),HL	; transfer values to ATTR_T and MASK_T

; for the print flag the permanent values are odd bits, temporary even bits.

	LD	HL,P_FLAG		;
	JR	NZ,TEMPS_2	; skip if lower screen using A=0.
	LD	A,(HL)		; else pick up flag bits.
	RRCA			; rotate permanent bits to temporary bits.

	ORG	$0D65
TEMPS_2:	XOR	(HL)		;
	AND	$55		; BIN 01010101
	XOR	(HL)		; permanent now as original
	LD	(HL),A		; apply permanent bits to temporary bits.
	RET			; and return.

; -----------------
; THE 'CLS' COMMAND
; -----------------
;  This command clears the display.
;  The routine is also called during initialization and by the CLEAR command.
;  If it's difficult to write it should be difficult to read.

	ORG	$0D6B
CLS:	CALL	CL_ALL		; clears the entire display and
				; sets the attributes to the permanent ones
				; from ATTR-P.

; Having cleared all 24 lines of the display area, continue into the
; subroutine that clears the lower display area.  Note that at the moment
; the attributes for the lower lines are the same as upper ones and have
; to be changed to match the BORDER colour.

; --------------------------
; THE 'CLS-LOWER' SUBROUTINE
; --------------------------
; This routine is called from INPUT, and from the MAIN execution loop.
; This is very much a housekeeping routine which clears between 2 and 23
; lines of the display, setting attributes and correcting situations where
; errors have occurred while the normal input and output routines have been
; temporarily diverted to deal with, say, colour control codes.

	ORG	$0D6E
CLS_LOWER:
	LD	HL,TV_FLAG	;
	RES	5,(HL)		; TV_FLAG - signal do not clear lower screen.
	SET	0,(HL)		; TV_FLAG - signal lower screen in use.
	CALL	TEMPS		; applies permanent attributes,
				; in this case BORDCR to ATTR_T.
				; Note. this seems unnecessary and is repeated
				; within CL_LINE.
	LD	B,(IY+$31)	; fetch lower screen display file size DF_SZ
	CALL	CL_LINE		; clears lines to bottom of the
				; display and sets attributes from BORDCR while
				; preserving the B register.
	LD	HL,ATTR_0 + 704	; set initial attribute address to the leftmost
				; cell of second line up.
	LD	A,(ATTR_P)	; fetch permanent attribute from ATTR_P.
	DEC	B		; decrement lower screen display file size.
	JR	CLS_3		; forward to enter the backfill loop
				; where B is decremented again.

; ---

; The backfill loop is entered at midpoint and ensures, if more than 2
; lines have been cleared, that any other lines take the permanent screen
; attributes.

	ORG	$0D87
CLS_1:	LD	C,$20		; set counter to 32 character cells per line

	ORG	$0D89
CLS_2:	DEC	HL		; decrease attribute address.
	LD	(HL),A		; and place attributes in next line up.
	DEC	C		; decrease the 32 counter.
	JR	NZ,CLS_2		; loop back until all 32 cells done.


	ORG	$0D8E
CLS_3:	DJNZ	CLS_1		; decrease B counter and back if not zero.
	LD	(IY+$31),$02	; now set DF_SZ lower screen to 2

; This entry point is also called from CL-ALL below to
; reset the system channel input and output addresses to normal.

	ORG	$0D94
CL_CHAN:	LD	A,$FD		; select system channel 'K'
	CALL	CHAN_OPEN		; opens it.
	LD	HL,(CURCHL)	; address current channel
	LD	DE,PRINT_OUT	; set address for first pass.
	AND	A		; clear carry for first pass.

	ORG	$0DA0
CL_CHAN_A:
	LD	(HL),E		; Insert the output address on the first pass
	INC	HL		; or the input address on the second pass.
	LD	(HL),D		;
	INC	HL		;
	LD	DE,KEY_INPUT	; fetch address for second pass
	CCF			; complement carry flag - will set on pass 1.
	JR	C,CL_CHAN_A	; back if first pass else done.
	LD	BC,$1721		; line 23 for lower screen
	JR	CL_SET		; exit via CL_SET to set column

; ---------------------------
; Clearing whole display area
; ---------------------------
; This subroutine called from CLS, AUTO-LIST and MAIN-3
; clears 24 lines of the display and resets the relevant system variables.
; This routine also recovers from an error situation where, for instance, an
; invalid colour or position control code has left the output routine addressing
; PO_TV-2 or PO_CONT.

	ORG	$0DAF
CL_ALL:	LD	HL,$0000		; Initialize plot coordinates.
	LD	(COORDS),HL	; Set system variable COORDS to 0,0.
	RES	0,(IY+$30)	; update FLAGS2  - signal main screen is clear.
	CALL	CL_CHAN		; makes channel 'K' 'normal'.
	LD	A,$FE		; select system channel 'S'
	CALL	CHAN_OPEN		; opens it.
	CALL	TEMPS		; applies permanent attributes,
				; in this case ATTR_P, to ATTR_T.
				; Note. this seems unnecessary.
	LD	B,$18		; There are 24 lines.
	CALL	CL_LINE		; clears 24 text lines and sets
				; attributes from ATTR-P.
				; This routine preserves B and sets C to $21.
	LD	HL,(CURCHL)	; make HL address output routine.
	LD	DE,PRINT_OUT	;
	LD	(HL),E		; is made
	INC	HL		; the normal
	LD	(HL),D		; output address.
	LD	(IY+$52),$01	; set SCR_CT - scroll count - to default.

; Note. BC already contains $1821.

z0DD6:	LD	BC,$1821		; reset column and line to 0,0
				; and continue into CL-SET, below, exiting
				; via PO_STORE (for the upper screen).

; --------------------
; THE 'CL-SET' ROUTINE
; --------------------
; This important subroutine is used to calculate the character output
; address for screens or printer based on the line/column for screens
; or the column for printer.

	ORG	$0DD9
CL_SET:	LD	HL,$5B00		; the base address of printer buffer
	BIT	1,(IY+$01)	; test FLAGS  - is printer in use ?
	JR	NZ,CL_SET_2	; forward to CL-SET-2 if so.
	LD	A,B		; transfer line to A.
	BIT	0,(IY+$02)	; test TV_FLAG  - lower screen in use ?
	JR	Z,CL_SET_1	; skip if handling upper part
	ADD	A,(IY+$31)	; add DF_SZ for lower screen
	SUB	$18		; and adjust.

	ORG	$0DEE
CL_SET_1:	PUSH	BC		; save the line/column.
	LD	B,A		; transfer line to B
				; (adjusted if lower screen)
	CALL	CL_ADDR		; calculates address at left of screen.
	POP	BC		; restore the line/column.

	ORG	$0DF4
CL_SET_2:	LD	A,$21		; the column $01-$21 is reversed
	SUB	C		; to range $00 - $20
	LD	E,A		; now transfer to DE
	LD	D,$00		; prepare for addition
	ADD	HL,DE		; and add to base address
	JP	PO_STORE		; exit via PO_STORE to update the relevant
				; system variables.
; ----------------
; Handle scrolling
; ----------------
; The routine CL-SC-ALL is called once from PO to scroll all the display
; and from the routine CL-SCROLL, once, to scroll part of the display.

	ORG	$0DFE
CL_SC_ALL:
	LD	B,$17		; scroll 23 lines, after 'scroll?'.

	ORG	$0E00
CL_SCROLL:
	CALL	CL_ADDR		; gets screen address in HL.
	LD	C,$08		; there are 8 pixel lines to scroll.

	ORG	$0E05
CL_SCR_1:	PUSH	BC		; save counters.
	PUSH	HL		; and initial address.
	LD	A,B		; get line count.
	AND	$07		; will set zero if all third to be scrolled.
	LD	A,B		; re-fetch the line count.
	JR	NZ,CL_SCR_3	; forward if partial scroll.

; HL points to top line of third and must be copied to bottom of previous 3rd.
; ( so HL = $4800 or $5000 ) ( but also sometimes $4000 )

	ORG	$0E0D
CL_SCR_2:	EX	DE,HL		; copy HL to DE.
	LD	HL,$F8E0		; subtract $08 from H and add $E0 to L -
	ADD	HL,DE		; to make destination bottom line of previous
				; third.
	EX	DE,HL		; restore the source and destination.
	LD	BC,$0020		; thirty-two bytes are to be copied.
	DEC	A		; decrement the line count.
	LDIR			; copy a pixel line to previous third.

	ORG	$0E19
CL_SCR_3:	EX	DE,HL		; save source in DE.
	LD	HL,$FFE0		; load the value -32.
	ADD	HL,DE		; add to form destination in HL.
	EX	DE,HL		; switch source and destination
	LD	B,A		; save the count in B.
	AND	$07		; mask to find count applicable to current
	RRCA			; third and
	RRCA			; multiply by
	RRCA			; thirty two (same as 5 RLCAs)
	LD	C,A		; transfer byte count to C ($E0 at most)
	LD	A,B		; store line count to A
	LD	B,$00		; make B zero
	LDIR			; copy bytes (BC=0, H incremented, L=0)
	LD	B,$07		; set B to 7, C is zero.
	ADD	HL,BC		; add 7 to H to address next third.
	AND	$F8		; has last third been done ?
	JR	NZ,CL_SCR_2	; back if not.
	POP	HL		; restore topmost address.
	INC	H		; next pixel line down.
	POP	BC		; restore counts.
	DEC	C		; reduce pixel line count.
	JR	NZ,CL_SCR_1	; if all eight not done.
	CALL	CL_ATTR		; gets address in attributes
				; from current 'ninth line', count in BC.
	LD	HL,$FFE0		; set HL to the 16-bit value -32.
	ADD	HL,DE		; and add to form destination address.
	EX	DE,HL		; swap source and destination addresses.
	LDIR			; copy bytes scrolling the linear attributes.
	LD	B,$01		; continue to clear the bottom line.

; ------------------------------
; THE 'CLEAR TEXT LINES' ROUTINE
; ------------------------------
; This subroutine, called from CL-ALL, CLS-LOWER and AUTO-LIST and above,
; clears text lines at bottom of display.
; The B register holds on entry the number of lines to be cleared 1-24.

	ORG	$0E44
CL_LINE:	PUSH	BC		; save line count
	CALL	CL_ADDR		; gets top address
	LD	C,$08		; there are eight screen lines to a text line.

	ORG	$0E4A
CL_LINE_1:
	PUSH	BC		; save pixel line count
	PUSH	HL		; and save the address
	LD	A,B		; transfer the line to A (1-24).

	ORG	$0E4D
CL_LINE_2:
	AND	$07		; mask 0-7 to consider thirds at a time
	RRCA			; multiply
	RRCA			; by 32  (same as five RLCA instructions)
	RRCA			; now 32 - 256(0)
	LD	C,A		; store result in C
	LD	A,B		; save line in A (1-24)
	LD	B,$00		; set high byte to 0, prepare for ldir.
	DEC	C		; decrement count 31-255.
	LD	D,H		; copy HL
	LD	E,L		; to DE.
	LD	(HL),$00		; blank the first byte.
	INC	DE		; make DE point to next byte.
	LDIR			; ldir will clear lines.
	LD	DE,$0701		; now address next third adjusting
	ADD	HL,DE		; register E to address left hand side
	DEC	A		; decrease the line count.
	AND	$F8		; will be 16, 8 or 0  (AND $18 will do).
	LD	B,A		; transfer count to B.
	JR	NZ,CL_LINE_2	; back if 16 or 8 to do the next third.
	POP	HL		; restore start address.
	INC	H		; address next line down.
	POP	BC		; fetch counts.
	DEC	C		; decrement pixel line count
	JR	NZ,CL_LINE_1	; back to CL_LINE_1 till all done.
	CALL	CL_ATTR		; gets attribute address
				; in DE and B * 32 in BC.
	LD	H,D		; transfer the address
	LD	L,E		; to HL.
	INC	DE		; make DE point to next location.
	LD	A,(ATTR_P)	; fetch - permanent attributes
	BIT	0,(IY+$02)	; test TV_FLAG  - lower screen in use ?
	JR	Z,CL_LINE_3	; skip if not.
	LD	A,(BORDCR)	; else lower screen uses BORDCR as attribute.

	ORG	$0E80
CL_LINE_3:
	LD	(HL),A		; put attribute in first byte.
	DEC	BC		; decrement the counter.
	LDIR			; copy bytes to set all attributes.
	POP	BC		; restore the line $01-$24.
	LD	C,$21		; make column $21. (No use is made of this)
	RET			; return to the calling routine.

; ------------------
; Attribute handling
; ------------------
; This subroutine is called from CL-LINE or CL-SCROLL with the HL register
; pointing to the 'ninth' line and H needs to be decremented before or after
; the division. Had it been done first then either present code or that used
; at the start of PO_ATTR could have been used.
; The Spectrum screen arrangement leads to the L register already holding
; the correct value for the attribute file and it is only necessary
; to manipulate H to form the correct colour attribute address.

	ORG	$0E88
CL_ATTR:	LD	A,H		; fetch H to A - $48, $50, or $58.
	RRCA			; divide by
	RRCA			; eight.
	RRCA			; $09, $0A or $0B.
	DEC	A		; $08, $09 or $0A.
	OR	$50		; $58, $59 or $5A.
	LD	H,A		; save high byte of attributes.
	EX	DE,HL		; transfer attribute address to DE
	LD	H,C		; set H to zero - from last LDIR.
	LD	L,B		; load L with the line from B.
	ADD	HL,HL		; multiply
	ADD	HL,HL		; by
	ADD	HL,HL		; thirty two
	ADD	HL,HL		; to give count of attribute
	ADD	HL,HL		; cells to the end of display.
	LD	B,H		; transfer the result
	LD	C,L		; to register BC.
	RET			; return.

; -------------------------------
; Handle display with line number
; -------------------------------
; This subroutine is called from four places to calculate the address
; of the start of a screen character line which is supplied in B.

	ORG	$0E9B
CL_ADDR:	LD	A,$18		; reverse the line number
	SUB	B		; to range $00 - $17.
	LD	D,A		; save line in D for later.
	RRCA			; multiply
	RRCA			; by
	RRCA			; thirty-two.
	AND	$E0		; mask off low bits to make
	LD	L,A		; L a multiple of 32.
	LD	A,D		; bring back the line to A.
	AND	$18		; now $00, $08 or $10.
	OR	$40		; add the base address of screen.
	LD	H,A		; HL now has the correct address.
	RET			; return.

; -------------------
; Handle COPY command
; -------------------
; This command copies the top 176 lines to the ZX Printer
; It is popular to call this from machine code at point
; L0EAF with B holding 192 (and interrupts disabled) for a full-screen
; copy. This particularly applies to 16K Spectrums as time-critical
; machine code routines cannot be written in the first 16K of RAM as
; it is shared with the ULA which has precedence over the Z80 chip.

	ORG	$0EAC
COPY:	RET			; temporarily disabled.

;;;	DI			; disable interrupts as this is time-critical.
	LD	B,$B0		; top 176 lines.

	ORG	$0EAF
L0EAF:	LD	HL,SCREEN_0	; address start of the display file.

; now enter a loop to handle each pixel line.

	ORG	$0EB2
COPY_1:	PUSH	HL		; save the screen address.
	PUSH	BC		; and the line counter.
	CALL	COPY_LINE		; outputs one line.
	POP	BC		; restore the line counter.
	POP	HL		; and display address.
	INC	H		; next line down screen within 'thirds'.
	LD	A,H		; high byte to A.
	AND	$07		; result will be zero if we have left third.
	JR	NZ,COPY_2		; forward if not to continue loop.
	LD	A,L		; consider low byte first.
	ADD	A,$20		; increase by 32 - sets carry if back to zero.
	LD	L,A		; will be next group of 8.
	CCF			; complement - carry set if more lines in
				; the previous third.
	SBC	A,A		; will be FF, if more, else 00.
	AND	$F8		; will be F8 (-8) or 00.
	ADD	A,H		; that is subtract 8, if more to do in third.
	LD	H,A		; and reset address.

	ORG	$0EC9
COPY_2:	DJNZ	COPY_1		; back for all lines.
	JR	COPY_END		; forward to switch off the printer
				; motor and enable interrupts.
				; Note. Nothing else is required.

; ------------------------------
; Pass printer buffer to printer
; ------------------------------
; This routine is used to copy 8 text lines from the printer buffer
; to the ZX Printer. These text lines are mapped linearly so HL does
; not need to be adjusted at the end of each line.

	ORG	$0ECD
COPY_BUFF:
	DI			; disable interrupts
	LD	HL,$5B00		; the base address of the Printer Buffer.
	LD	B,$08		; set count to 8 lines of 32 bytes.

	ORG	$0ED3
COPY_3:	PUSH	BC		; save counter.
	CALL	COPY_LINE		; outputs 32 bytes
	POP	BC		; restore counter.
	DJNZ	COPY_3		; loop back for all 8 lines.
				; then stop motor and clear buffer.

; Note. the COPY command rejoins here, essentially to execute the next
; three instructions.

	ORG	$0EDA
COPY_END:	LD	A,$04		; output value 4 to port
	OUT	($FB),A		; to stop the slowed printer motor.
	EI			; enable interrupts.

; --------------------
; Clear Printer Buffer
; --------------------
; This routine clears an arbitrary 256 bytes of memory.
; Note. The routine seems designed to clear a buffer that follows the
; system variables.
; The routine should check a flag or HL address and simply return if COPY
; is in use.
; As a consequence of this omission the buffer will needlessly
; be cleared when COPY is used and the screen/printer position may be set to
; the start of the buffer and the line number to 0 (B)
; giving an 'Out of Screen' error.
; There seems to have been an unsuccessful attempt to circumvent the use
; of PR_CC_H.

	ORG	$0EDF
CLEAR_PRB:
	LD	HL,$5B00		; the location of the buffer.
	CALL	CHAN_P		; routine CHAN_P (set 1,(IY+$01); ret)
	XOR	A		; clear the accumulator.
	LD	B,A		; set count to 256 bytes.

	ORG	$0EE7
PRB_BYTES:
	LD	(HL),A		; set addressed location to zero.
	INC	HL		; address next byte - Note. not INC L.
	DJNZ	PRB_BYTES	; back to repeat for 256 bytes.
	RES	1,(IY+$30)	; set FLAGS2 - signal printer buffer is clear.
	LD	C,$21		; set the column position .
	JP	CL_SET		; exit via CL_SET and then PO_STORE.

; -----------------
; Copy line routine
; -----------------
; This routine is called from COPY and COPY-BUFF to output a line of
; 32 bytes to the ZX Printer.
; Output to port $FB -
; bit 7 set - activate stylus.
; bit 7 low - deactivate stylus.
; bit 2 set - stops printer.
; bit 2 reset - starts printer
; bit 1 set - slows printer.
; bit 1 reset - normal speed.

	ORG	$0EF4
COPY_LINE:
	LD	A,B		; fetch the counter 1-8 or 1-176
	CP	$03		; is it 01 or 02 ?.
	SBC	A,A		; result is $FF if so else $00.
	AND	$02		; result is 02 now else 00.
				; bit 1 set slows the printer.
	OUT	($FB),A		; slow the printer for the
				; last two lines.
	LD	D,A		; save the mask to control the printer later.

	ORG	$0EFD
COPY_L_1:CALL	BREAK_KEY	; to read keyboard immediately.
	JR	C,COPY_L_2 	; forward if 'break' not pressed.
	LD	A,$04		; else stop the
	OUT	($FB),A		; printer motor.
	EI			; enable interrupts.
	CALL	CLEAR_PRB	; Note. should not be cleared if COPY in use.

	ORG	$0F0A
REPORT_Dc:
	RST	08H		; ERROR_1
	DEFB	$0C		; Error Report: BREAK, CONT repeats

	ORG	$0F0C
COPY_L_2:IN	A,($FB)		; test now to see if
	ADD	A,A		; a printer is attached.
	RET	M		; return if not - but continue with parent
				; command.
	JR	NC,COPY_L_1	; back if stylus of printer not in position.
	LD	C,$20		; set count to 32 bytes.

	ORG	$0F14
COPY_L_3:LD	E,(HL)		; fetch a byte from line.
	INC	HL		; address next location. Note. not INC L.
	LD	B,$08		; count the bits.

	ORG	$0F18
COPY_L_4:RL	D		; prepare mask to receive bit.
	RL	E		; rotate leftmost print bit to carry
	RR	D		; and back to bit 7 of D restoring bit 1

	ORG	$0F1E
COPY_L_5:IN	A,($FB)		; read the port.
	RRA			; bit 0 to carry.
	JR	NC,COPY_L_5	; back if stylus not in position.
	LD	A,D		; transfer command bits to A.
	OUT	($FB),A		; and output to port.
	DJNZ	COPY_L_4		; loop back for all 8 bits.
	DEC	C		; decrease the byte count.
	JR	NZ,COPY_L_3	; back until 256 bits done.
	RET			; return to calling routine COPY/COPY-BUFF.

; ----------------------------------
; Editor routine for BASIC and INPUT
; ----------------------------------
; The editor is called to prepare or edit a BASIC line.
; It is also called from INPUT to input a numeric or string expression.
; The behaviour and options are quite different in the various modes
; and distinguished by bit 5 of FLAGX.
;
; This is a compact and highly versatile routine.

	ORG	$0F2C
EDITOR:	LD	HL,(ERR_SP)	; fetch
	PUSH	HL		; save on stack

	ORG	$0F30
ED_AGAIN:LD	HL,ED_ERROR	;
	PUSH	HL		; save address on stack and
	LD	(ERR_SP),SP	; make ERR_SP point to it.

; Note. While in editing/input mode should an error occur then RST 08 will
; update X_PTR to the location reached by CH_ADD and jump to ED_ERROR
; where the error will be cancelled and the loop begin again from ED_AGAIN
; above. The position of the error will be apparent when the lower screen is
; reprinted. If no error then the re-iteration is to ED_LOOP below when
; input is arriving from the keyboard.

	ORG	$0F38
ED_LOOP:	CALL	WAIT_KEY		; gets key possibly changing the mode.
	PUSH	AF		; save key.
	LD	D,$00		; and give a short click based
	LD	E,(IY-$01)	; on PIP value for duration.
	LD	HL,$00C8		; and pitch.
	CALL	BEEPER		; gives click - effective with rubber keyboard.
	POP	AF		; get saved key value.
	LD	HL,ED_LOOP	; address is loaded to HL.
	PUSH	HL		; and pushed onto stack.

; At this point there is a looping return address on the stack, an error
; handler and an input stream set up to supply characters.
; The character that has been received can now be processed.

	CP	$18		; range 24 to 255 ?
	JR	NC,ADD_CHAR	; forward if so.
	CP	$06		; lower than 6 ?
	JR	C,ADD_CHAR	; forward also.
				; Note. This is a 'bug' and chr$ 6, the comma
				; control character, should have had an
				; entry in the ED-KEYS table.
	CP	$10		; less than 16 ?
	JR	C,ED_KEYS	; forward if editing control
				; range 7 to 15 dealt with by a table
	LD	BC,$0002		; prepare for ink/paper etc.
	LD	D,A		; save character in D
	CP	$16		; is it ink/paper/bright etc. ?
	JR	C,ED_CONTR	; forward if so
				; leaves 22d AT and 23d TAB
				; which can't be entered via KEY_INPUT.
				; so this code is never normally executed
				; when the keyboard is used for input.
	INC	BC		; if it was AT/TAB - 3 locations required
	BIT	7,(IY+$37)	; test FLAGX  - Is this INPUT LINE ?
	JP	Z,ED_IGNORE	; if not, else
	CALL	WAIT_KEY		; - input address is KEY_NEXT
				; but is reset to KEY_INPUT
	LD	E,A		; save first in E

	ORG	$0F6C
ED_CONTR:CALL	WAIT_KEY		; for control.
				; input address will be key-next.
	PUSH	DE		; saved code/parameters
	LD	HL,(K_CUR)	; fetch address of keyboard cursor
;;;	RES	0,(IY+$07)	; set MODE to 'L'

	NOP
	NOP
	NOP
	NOP

	CALL	MAKE_ROOM	; makes 2/3 spaces at cursor
	POP	BC		; restore code/parameters
	INC	HL		; address first location
	LD	(HL),B		; place code (ink etc.)
	INC	HL		; address next
	LD	(HL),C		; place possible parameter. If only one
				; then DE points to this location also.
	JR	ADD_CH_1		; forward

; ------------------------
; Add code to current line
; ------------------------
; this is the branch used to add normal non-control characters
; with ED_LOOP as the stacked return address.
; it is also the OUTPUT service routine for system channel 'R'.

	ORG	$0F81
ADD_CHAR:
;;;	RES	0,(IY+$07)	; set MODE to 'L'

	NOP			; code to call detokenizer can go here
	NOP			;
	NOP			;
	NOP			;

X0F85:	LD	HL,(K_CUR)	; fetch address of keyboard cursor
	CALL	ONE_SPACE	; creates one space.

; either a continuation of above or from ED-CONTR with ED_LOOP on stack.

	ORG	$0F8B
ADD_CH_1:
	LD	(DE),A		; load current character to last new location.
	INC	DE		; address next
	LD	(K_CUR),DE	; and update system variable.
	RET			; return - either a simple return
				; from ADD-CHAR or to ED_LOOP on stack.

; ---

; a branch of the editing loop to deal with control characters
; using a look-up table.

	ORG	$0F92
ED_KEYS:	LD	E,A		; character to E.
	LD	D,B		; prepare to add.
	LD	HL,ED_KEYS_T - 6  ; base address of editing keys table. $0F99
	ADD	HL,DE		; add E
	LD	E,(HL)		; fetch offset to E
	ADD	HL,DE		; add offset for address of handling routine.
	PUSH	HL		; push the address on machine stack.
	LD	HL,(K_CUR)	; load address of cursor
	RET			; Make an indirect jump forward to routine.

; ------------------
; Editing keys table
; ------------------
; For each code in the range $07 to $0F this table contains a
; single offset byte to the routine that services that code.
; Note. for what was intended there should also have been an
; entry for chr$ 6 with offset to ed-symbol.

ED_KEYS_T:
	DEFB	ED_SYMBOL - $	; 06d offset $??
	DEFB	ED_EDIT - $	; 07d offset $09
	DEFB	ED_LEFT - $	; 08d offset $66
	DEFB	ED_RIGHT - $	; 09d offset $6A
	DEFB	ED_DOWN - $	; 10d offset $50
	DEFB	ED_UP - $	; 11d offset $B5
	DEFB	ED_DELETE - $	; 12d offset $70
	DEFB	ED_ENTER - $	; 13d offset $7E
	DEFB	ED_SYMBOL - $	; 14d offset $CF
	DEFB	ED_GRAPH - $	; 15d offset $D4

; ---------------
; Handle EDIT key
; ---------------
; The user has pressed SHIFT 1 to bring edit line down to bottom of screen.
; Alternatively the user wishes to clear the input buffer and start again.
; Alternatively ...

	ORG	$0FA9
ED_EDIT:	LD	HL,(E_PPC)	; fetch the last line number entered.
				; Note. may not exist and may follow program.
	BIT	5,(IY+$37)	; test FLAGX  - input mode ?
	JP	NZ,CLEAR_SP	; jump if not in editor.
	CALL	LINE_ADDR	; to find address of line
				; or following line if it doesn't exist.
	CALL	LINE_NO		; will get line number from
				; address or previous line if at end-marker.
	LD	A,D		; if there is no program then DE will
	OR	E		; contain zero so test for this.
	JP	Z,CLEAR_SP	; jump if so.

; Note. at this point we have a validated line number, not just an
; approximation and it would be best to update E_PPC with the true
; cursor line value which would enable the line cursor to be suppressed
; in all situations - but there is no room so update hi byte.

	PUSH	HL		; save address of line. (second byte)
	INC	HL		; address low byte of length.
	LD	C,(HL)		; transfer to C
	INC	HL		; next to high byte
	LD	B,(HL)		; transfer to B.
	LD	HL,$000A		; an overhead of ten bytes
	ADD	HL,BC		; is added to length.
	LD	B,H		; transfer adjusted value
	LD	C,L		; to BC register.
	CALL	TEST_ROOM	; checks free memory.
	CALL	CLEAR_SP		; clears editing area.
	LD	HL,(CURCHL)	;
	EX	(SP),HL		; swap with line address on stack
	PUSH	HL		; save line address underneath
	LD	A,$FF		; select system channel 'R'
	CALL	CHAN_OPEN	; opens it
	POP	HL		; Restore line address (+1)
	DEC	HL		; make it point to first byte of line num.

	DEC	(IY+$10)		; decrease E_PPC_H to suppress line cursor.
				; Note. ineffective when E_PPC is one
				; greater than last line of program perhaps
				; as a result of a delete.

;+ next line could be replaced with a call to detokenizer

	CALL	OUT_LINE		; outputs the BASIC line
				; to the editing area.
	INC	(IY+$10)		; restore E_PPC_H to the previous value.

	LD	HL,(E_LINE)	; in editing area.

	CALL	L18BA		; advance past space and digit characters
				; of 5 digit line number (via NUMBER routine)
	LD	(K_CUR),HL	; update to address start of BASIC.
	POP	HL		; restore the address of CURCHL.
	CALL	CHAN_FLAG	; sets flags for it.
	RET			; RETURN to ED_LOOP.

	DEFS	1

; -------------------
; Cursor down editing
; -------------------
; The BASIC lines are displayed at the top of the screen and the user
; wishes to move the cursor down one line in edit mode.
; With INPUT LINE, this key must be used instead of entering STOP.

	ORG	$0FF3
ED_DOWN:	BIT	5,(IY+$37)	; test FLAGX  - Input Mode ?
	JR	NZ,ED_STOP	; skip if so
	LD	HL,E_PPC		; - 'current line'
	CALL	LN_FETCH		; fetches number of next
				; line or same if at end of program.
	JR	ED_LIST		; to produce an automatic listing.

; ---

	ORG	$1001
ED_STOP:	LD	(IY+$00),$10	; set ERR_NR to 'BREAK in INPUT' code
	JR	ED_ENTER		; forward to produce error.

; -------------------
; Cursor left editing
; -------------------
; This acts on the cursor in the lower section of the screen in both
; editing and input mode.

	ORG	$1007
ED_LEFT:	CALL	ED_EDGE		; moves left if possible
	JR	ED_CUR		; forward to update K-CUR
				; and return to ED_LOOP.

; --------------------
; Cursor right editing
; --------------------
; This acts on the cursor in the lower screen in both editing and input
; mode and moves it to the right.

	ORG	$100C
ED_RIGHT:
	JP	ED_FIX1		; handle colour controls.

; ---
	RET	Z		; Old unused instruction

; ---

	ORG	$1010
ED_BUMP:	INC	HL		; address next character

	ORG	$1011
ED_CUR:	LD	(K_CUR),HL	; update system variable
	RET			; return to ED_LOOP

; --------------
; DELETE editing
; --------------
; This acts on the lower screen and deletes the character to left of
; cursor. If control characters are present these are deleted first
; leaving the naked parameter (0-7) which appears as a '?' except in the
; case of chr$ 6 which is the comma control character. It is not mandatory
; to delete these second characters.

	ORG	$1015
ED_DELETE:
	CALL	ED_EDGE		; moves cursor to left.
	EX	DE,HL		; prevents the parameter
	JP	RECLAIM_1	; being left over

	DEFS	2

; ------------------------------------------
; Ignore next 2 codes from key-input routine
; ------------------------------------------
; Since AT and TAB cannot be entered this point is never reached
; from the keyboard. If inputting from a tape device or network then
; the control and two following characters are ignored and processing
; continues as if a carriage return had been received.
; Here, perhaps, another Spectrum has said print #15; AT 0,0; "This is yellow"
; and this one is interpreting input #15; a$.

	ORG	$101E
ED_IGNORE:
	CALL	WAIT_KEY		; to ignore keystroke.
	CALL	WAIT_KEY		; to ignore next key.

; -------------
; Enter/newline
; -------------
; The enter key has been pressed to have BASIC line or input accepted.

	ORG	$1024
ED_ENTER:POP	HL		; discard address ED_LOOP
	POP	HL		; drop address ED_ERROR

	ORG	$1026
ED_END:	POP	HL		; the previous value of ERR_SP
	LD	(ERR_SP),HL	; is restored to system variable
	BIT	7,(IY+$00)	; is ERR_NR $FF (= 'OK') ?
	RET	NZ		; return if so
	LD	SP,HL		; else put error routine on stack
	RET			; and make an indirect jump to it.

; -----------------------------
; Move cursor left when editing
; -----------------------------
; This routine moves the cursor left. The complication is that it must
; not position the cursor between control codes and their parameters.
; It is further complicated in that it deals with TAB and AT characters
; which are never present from the keyboard.
; The method is to advance from the beginning of the line each time,
; jumping one, two, or three characters as necessary saving the original
; position at each jump in DE. Once it arrives at the cursor then the next
; legitimate leftmost position is in DE.

	ORG	$1031
ED_EDGE:	SCF			; carry flag must be set to call the nested
	CALL	SET_DE		; subroutine SET_DE.
				; if input then DE=WORKSP
				; if editing then DE=E_LINE
	SBC	HL,DE		; subtract address from start of line
	ADD	HL,DE		; and add back.
	INC	HL		; adjust for carry.
	POP	BC		; drop return address
	RET	C		; return to ED_LOOP if already at left of line.
	PUSH	BC		; resave return address - ED_LOOP.
	LD	B,H		; transfer HL - cursor address
	LD	C,L		; to BC register pair.
				; at this point DE addresses start of line.

	ORG	$103E
ED_EDGE_1:
	LD	H,D		; transfer DE - leftmost pointer
	LD	L,E		; to HL
	INC	HL		; address next leftmost character to
				; advance position each time.
	LD	A,(DE)		; pick up previous in A
	SUB	$10		; reduce to range $00 - $07.
	CP	$08		; $00 - $07 will set carry flag.
				; that is, is it followed by a parameter ?
	JR      NC,ED_EDGE_2	; to ED-EDGE-2 if not.
				; HL has been incremented once.
	INC	HL		; increment second byte but not for 24d - 31d.

; in fact since 'tab' and 'at' cannot be entered the next section seems
; superfluous. Note. Until 'Insert' mode is added.
; The test will always fail and the jump to ED_EDGE_2 will be taken.

	LD	A,(DE)		; reload leftmost character
	SUB	$17		; decimal 23 ('tab')
	ADC	A,$00		; will be 0 for 'tab' and 'at'.
	JR	NZ,ED_EDGE_2	; forward if not
				; HL has been incremented twice
	INC	HL		; increment a third time for 'at'/'tab'

	ORG	$1051
ED_EDGE_2:
	AND	A		; prepare for true subtraction
	SBC	HL,BC		; subtract cursor address from pointer
	ADD	HL,BC		; and add back
				; Note when HL matches the cursor position BC,
				; there is no carry and the previous
				; position is in DE.
	EX	DE,HL		; transfer result to DE if looping again.
				; transfer DE to HL to be used as K_CUR
				; if exiting loop.
	JR	C,ED_EDGE_1	; if cursor not matched.
	RET			; return.

; -----------------
; Cursor up editing
; -----------------
; The main screen displays part of the BASIC program and the user wishes
; to move up one line scrolling if necessary.
; This has no alternative use in input mode.

	ORG	$1059
ED_UP:	BIT	5,(IY+$37)	; test FLAGX  - input mode ?
	RET	NZ		; return if not in editor - to ED_LOOP.
	LD	HL,(E_PPC)	; get current line
	CALL	LINE_ADDR	; gets address
	EX	DE,HL		; and previous in DE
	CALL	LINE_NO		; gets prev line number
	LD	HL,E_PPC_H	; as next routine stores top first.
	CALL	LN_STORE		; loads DE value to HL
				; high byte first - E_PPC_L takes E

; this branch is also taken from ED_down.

	ORG	$106E
ED_LIST:	CALL	AUTO_LIST	; lists to upper screen
				; including adjusted current line.
	LD	A,$00		; select lower screen again
	JP	CHAN_OPEN	; exit via CHAN_OPEN to ED_LOOP

; --------------------------------
; Use of symbol and graphics codes
; --------------------------------
; These will not be encountered with the keyboard but would be handled
; otherwise as follows.
; As noted earlier, Vickers says there should have been an entry in
; the KEYS table for chr$ 6 which also pointed here.
; If, for simplicity, two Spectrums were both using #15 as a bi-directional
; channel connected to each other:-
; then when the other Spectrum has said PRINT #15; x, y
; input #15; i ; j  would treat the comma control as a newline and the
; control would skip to input j.
; You can get round the missing chr$ 6 handler by sending multiple print
; items separated by a newline '.

; chr$14 would have the same functionality.

; This is chr$ 14.

	ORG	$1076
ED_SYMBOL:
	BIT	7,(IY+$37)	; test FLAGX - is this INPUT LINE ?
	JR	Z,ED_ENTER	; back if not to treat as if
				; enter had been pressed.
				; else continue and add code to buffer.

; Next is chr$ 15
; Note that ADD-CHAR precedes the table so we can't offset to it directly.

	ORG	$107C
ED_GRAPH:JP	ADD_CHAR		; jump back

; --------------------
; Editor error routine
; --------------------
; If an error occurs while editing, or inputting, then ERR_SP
; points to the stack location holding address ED_ERROR.

	ORG	$107F
ED_ERROR:BIT	4,(IY+$30)	; test FLAGS2  - is K channel in use ?
	JR	Z,ED_END		; back if not.

; but as long as we're editing lines or inputting from the keyboard, then
; we've run out of memory so give a short rasp.

	LD	(IY+$00),$FF	; reset ERR_NR to 'OK'.
	LD	D,$00		; prepare for beeper.
	LD	E,(IY-$02)	; use RASP value.
	LD	HL,$1A90		; set a duration.
	CALL	BEEPER		; emits a warning rasp.
	JP	ED_AGAIN		; to re-stack address of
				; this routine and make ERR_SP point to it.

; ---------------------
; Clear edit/work space
; ---------------------
; The editing area or workspace is cleared depending on context.
; This is called from ED_EDIT to clear workspace if edit key is
; used during input, to clear editing area if no program exists
; and to clear editing area prior to copying the edit line to it.
; It is also used by the error routine to clear the respective
; area depending on FLAGX.

	ORG	$1097
CLEAR_SP:PUSH	HL		; preserve HL
	CALL	SET_HL		; if in edit HL = WORKSP-1, DE = E_LINE
				; if in input  HL = STKBOT, DE = WORKSP
	DEC	HL		; adjust
	CALL	RECLAIM_1	; reclaims space
	LD	(K_CUR),HL	; set to start of empty area
	POP	HL		; restore HL.
	RET			; return.

	DEFS	4

; ----------------------------
; THE 'KEYBOARD INPUT' ROUTINE
; ----------------------------
; This is the service routine for the input stream of the keyboard channel 'K'.

	ORG	$10A8
KEY_INPUT:
	BIT	3,(IY+$02)	; test TV_FLAG  - has a key been pressed in
				; editor ?
	CALL	NZ,ED_COPY	; if so, reprint the lower
				; screen at every keystroke/mode change.
	AND	A		; clear carry flag - required exit condition.
	BIT	5,(IY+$01)	; test FLAGS  - has a new key been pressed ?
	RET	Z		; return if not.  >>

; The next entry point is used by the new CONS_IN routine

KI_END:	LD	A,(LAST_K)	; system variable will hold last key -
				; from the interrupt routine.
	RES	5,(IY+$01)	; update FLAGS  - reset the new key flag.
	PUSH	AF		; save the input character.
	BIT	5,(IY+$02)	; test TV_FLAG  - clear lower screen ?
	CALL	NZ,CLS_LOWER	; call if so.
	POP	AF		; restore the character code.
	CP	$20		; if space or higher then
	JR	NC,KEY_DONE2	; forward and return with carry
				; set to signal key-found.
	CP	$10		; with 16d INK and higher skip
	JR	NC,KEY_CONTR	; forward.
	CP	$06		; for 6 - 15d
	JR	NC,KEY_M_CL	; skip forward to handle Modes and CapsLock.

; that only leaves 0-5, the flash bright inverse switches.

	LD	B,A		; save character in B
	AND	$01		; isolate the embedded parameter (0/1).
	LD	C,A		; and store in C
	LD	A,B		; re-fetch copy (0-5)
	RRA			; halve it 0, 1 or 2.
	ADD	A,$12		; add 18d gives 'flash', 'bright' and 'inverse'.
	JR	KEY_DATA		; forward with the parameter (0/1) in C.

; ---

; Now separate capslock 06 from modes 7-15.

	ORG	$10DB
KEY_M_CL:JR	NZ,KEY_MODE	; forward if not 06 (capslock)
	LD	HL,FLAGS2		;
	LD	A,$08		; value 00001000
	XOR	(HL)		; toggle BIT 3 of FLAGS2 the capslock bit
	LD	(HL),A		; and store result in FLAGS2 again.
	JR	KEY_FLAG		; forward to signal no-key.

; ---

	ORG	$10E6
KEY_MODE:CP	$0E		; compare with chr 14d
	RET	C		; return with carry set "key found" for
				; codes 7 - 13d leaving 14d and 15d
				; which are converted to mode codes.
	SUB	$0D		; subtract 13d leaving 1 and 2
				; 1 is 'E' mode, 2 is 'G' mode.
	LD	HL,MODE		; address system variable.
	CP	(HL)		; compare with existing value before
	LD	(HL),A		; inserting the new value.
	JR	NZ,KEY_FLAG	; forward if it has changed.
	LD	(HL),$00		; else make MODE zero - KLC mode
				; Note. while in Extended/Graphics mode,
				; the Extended Mode/Graphics key is pressed
				; again to get out.

	ORG	$10F4
KEY_FLAG:SET	3,(IY+$02)	; update TV_FLAG  - show key state has changed
	CP	A		; clear carry and reset zero flags -
				; no actual key returned.
	RET			; make the return.

; ---

; now deal with colour controls - 16-23 ink, 24-31 paper

	ORG	$10FA
KEY_CONTR:
	LD	B,A		; make a copy of character.
	AND	$07		; mask to leave bits 0-7
	LD	C,A		; and store in C.
	LD	A,$10		; initialize to 16d - INK.
	BIT	3,B		; was it paper ?
	JR	NZ,KEY_DATA	; forward with INK 16d and colour in C.
	INC	A		; else change from INK to PAPER (17d) if so.

	ORG	$1105
KEY_DATA:LD	(IY-$2D),C	; put the colour (0-7)/state(0/1) in K_DATA
	LD	DE,KEY_NEXT	; will be next input stream
	JR	KEY_CHAN		; forward to change it ...

; ---

; ... so that INPUT_AD directs control to here at next call to WAIT_KEY

	ORG	$110D
KEY_NEXT:LD	A,(K_DATA)	; pick up the parameter
	LD	DE,KEY_INPUT	; will be next input stream
				; continue to restore default channel and
				; make a return with the control code.

	ORG	$1113
KEY_CHAN:LD	HL,(CHANS)	; address start of CHANNELS area
				; Note. One might have expected CURCHL to
				; have been used.
	INC	HL		; step over the
	INC	HL		; output address
	LD	(HL),E		; and update the input
	INC	HL		; routine address for
	LD	(HL),D		; the next call to WAIT_KEY.

	ORG	$111B
KEY_DONE2:
	SCF			; set carry flag to show a key has been found
	RET			; and return.

; --------------------
; Lower screen copying
; --------------------
; This subroutine is called whenever the line in the editing area or
; input workspace is required to be printed to the lower screen.
; It is by calling this routine after any change that the cursor, for
; instance, appears to move to the left.
; Remember the edit line will contain characters and tokens
; e.g. "1000 LET a=1" is 8 characters.

	ORG	$111D
ED_COPY:	CALL	TEMPS		; sets temporary attributes.
	RES	3,(IY+$02)	; update TV_FLAG  - signal no change in mode
	RES	5,(IY+$02)	; update TV_FLAG  - signal don't clear lower
				; screen.
	LD	HL,(SPOSNL)	; fetch
	PUSH	HL		; and save on stack.
	LD	HL,(ERR_SP)	; fetch
	PUSH	HL		; and save also
	LD	HL,ED_FULL	;
	PUSH	HL		; is pushed as the error routine
	LD	(ERR_SP),SP	; and ERR_SP made to point to it.
	LD	HL,(ECHO_E)	; fetch
	PUSH	HL		; and push also
	SCF			; set carry flag to control SET-DE
	CALL	SET_DE		; if in input DE = WORKSP
				; if in edit  DE = E_LINE
	EX	DE,HL		; start address to HL
	CALL	OUT_LINE2	; outputs entire line up to
				; carriage return including initial
				; characterized line number when present.
	EX	DE,HL		; transfer new address to DE
	CALL	OUT_CURS		; considers a terminating cursor.
	LD	HL,(SPOSNL)	; fetch updated SPOSNL
	EX	(SP),HL		; exchange with ECHO_E on stack
	EX	DE,HL		; transfer ECHO_E to DE
	CALL	TEMPS		; to re-set attributes if altered.

; the lower screen was not cleared, at the outset, so if deleting then old
; text from a previous print may follow this line and requires blanking.

	ORG	$1150
ED_BLANK:LD	A,(SPOSNL_H)	; fetch current line
	SUB	D		; compare with old
	JR	C,ED_C_DONE	; forward if no blanking
	JR	NZ,ED_SPACES	; forward if line has changed
	LD	A,E		; old column to A
	SUB	(IY+$50)		; subtract new in SPOSNL_L
	JR	NC,ED_C_DONE	; forward if no backfilling.

	ORG	$115E
ED_SPACES:
	LD	A,$20		; prepare a space.
	PUSH	DE		; save old line/column.
	CALL	PRINT_OUT	; prints a space over
				; any text from previous print.
				; Note. Since the blanking only occurs when
				; using $09F4 to print to the lower screen,
				; there is no need to vector via a RST 10
				; and we can use this alternate set.
	POP	DE		; restore the old line column.
	JR	ED_BLANK		; back until all old text blanked.

; -------------------------------
; THE 'EDITOR-FULL' ERROR ROUTINE
; -------------------------------
; This is the error routine addressed by ERR_SP.  This is not for the out of
; memory situation as we're just printing.  The pitch and duration are exactly
; the same as used by ED_ERROR from which this has been augmented.  The
; situation is that the lower screen is full and a rasp is given to suggest
; that this is perhaps not the best idea you've had that day.

	ORG	$1167
ED_FULL:	LD	D,$00		; prepare to moan.
	LD	E,(IY-$02)	; fetch RASP value.
	LD	HL,$1A90		; set duration.
	CALL	BEEPER		;
	LD	(IY+$00),$FF	; clear ERR_NR.
	LD	DE,(SPOSNL)	; fetch
	JR	ED_C_END		; forward

; -------

; the exit point from line printing continues here.

	ORG	$117C
ED_C_DONE:
	POP	DE		; fetch new line/column.
	POP	HL		; fetch the error address.

; the error path rejoins here.

	ORG	$117E
ED_C_END:POP	HL		; restore the old value of ERR_SP.
	LD	(ERR_SP),HL	; update the system variable ERR_SP
	POP	BC		; old value of SPOSN_L
	PUSH	DE		; save new value
	CALL	CL_SET		; routine CL-SET and PO_STORE
				; update ECHO_E and SPOSN_L from BC
	POP	HL		; restore new value
	LD	(ECHO_E),HL	; and overwrite ECHO_E
	LD	(IY+$26),$00	; make error pointer X_PTR_H out of bounds
	RET			; return

; -----------------------------------------------
; Point to first and last locations of work space
; -----------------------------------------------
; These two nested routines ensure that the appropriate pointers are
; selected for the editing area or workspace. The routines that call
; these routines are designed to work on either area.

; this routine is called once


	ORG	$1190
SET_HL:	LD	HL,(WORKSP)	; fetch
	DEC	HL		; point to last location of editing area.
	AND	A		; clear carry to limit exit points to first
				; or last.

; this routine is called with carry set and exits at a conditional return.


	ORG	$1195
SET_DE:	LD	DE,(E_LINE)	; fetch
	BIT	5,(IY+$37)	; test FLAGX  - Input Mode ?
	RET	Z		; return now if in editing mode
	LD	DE,(WORKSP)	; fetch
	RET	C		; return if carry set ( entry = set-de)
	LD	HL,(STKBOT)	; fetch STKBOT as well
	RET			; and return  (entry = set-hl (in input))

; -----------------------------------
; THE 'REMOVE FLOATING POINT' ROUTINE
; -----------------------------------
; When a BASIC LINE or the INPUT BUFFER is parsed any numbers will have
; an invisible chr 14d inserted after them and the 5-byte integer or
; floating point form inserted after that.  Similar invisible value holders
; are also created after the numeric and string variables in a DEF FN list.
; This routine removes these 'compiled' numbers from the edit line or
; input workspace.

	ORG	$11A7
REMOVE_FP:
	LD	A,(HL)		; fetch character
	CP	$0E		; is it the CHR$ 14 number marker ?
	LD	BC,$0006		; prepare to strip six bytes
	CALL	Z,RECLAIM_2	; reclaims bytes if CHR$ 14.
	LD	A,(HL)		; reload next (or same) character
	INC	HL		; and advance address
	CP	$0D		; end of line or input buffer ?
	JR	NZ,REMOVE_FP	; back until entire line done.
	RET			; return.

; *********************************
; ** Part 6. EXECUTIVE ROUTINES  **
; *********************************

; The memory.
;
; +---------+-----------+------------+--------------+-------------+--
; | BASIC   |  Display  | Attributes | ZX Printer   |    System   |
; |  ROM    |   File    |    File    |   Buffer     |  Variables  |
; +---------+-----------+------------+--------------+-------------+--
; ^         ^           ^            ^              ^             ^
; $0000   $4000       $5800        $5B00          $5C00         $5CB6 = CHANS
;
;
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    | Channel  |$80|  BASIC  | Variables |$80| Edit Line  |NL|$80|
;    |   Info   |   | Program |   Area    |   | or Command |  |   |
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    ^              ^         ^               ^                   ^
;  CHANS           PROG      VARS           E_LINE              WORKSP
;
;
;                             ---5-->         <---2---  <--3---
;  --+-------+--+------------+-------+-------+---------+-------+-+---+------+
;    | INPUT |NL| Temporary  | Calc. | Spare | Machine | GOSUB |?|$3E| UDGs |
;    | data  |  | Work Space | Stack |       |  Stack  | Stack | |   |      |
;  --+-------+--+------------+-------+-------+---------+-------+-+---+------+
;    ^                       ^       ^       ^                   ^   ^      ^
;  WORKSP                  STKBOT  STKEND   sp               RAMTOP UDG  P_RAMT
;

; The new memory.
;
; +---------+----------+------------+------+-------+-------------+--
; |  BASIC  | Screen 0 |  Screen 0  | UDGs | Spare |   System    |
; |   ROM   |  Bitmap  | Attributes |      |       |  Variables  |
; +---------+----------+------------+------+-------+-------------+--
; ^         ^          ^            ^      ^       ^             ^
; $0000   $4000      $5800         UDG   $5BA8    $5C00         $5CB6 = CHANS
;
;
;	optionally (with extended video hardware)
;
;	a)			b)
;	--+----------+--		--+----------+------------+--
;	  | Screen 1 |		  | Screen 1 |  Screen 1  |
;	  |  Bitmap  |		  |  Bitmap  | Attributes |
;	--+----------+--		--+----------+------------+--
;	  ^          ^		  ^          ^            ^
;	$6000      $6800 = CHANS	$6000      $6800         $7830 = CHANS
;
;
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    | Channel  |$80|  BASIC  | Variables |$80| Edit Line  |NL|$80|
;    |   Info   |   | Program |   Area    |   | or Command |  |   |
;  --+----------+---+---------+-----------+---+------------+--+---+--
;    ^              ^         ^               ^                   ^
;  CHANS           PROG      VARS           E_LINE              WORKSP
;
;
;                             ---5-->         <---2---  <--3---
;  --+-------+--+------------+-------+-------+---------+-------+-+---+
;    | INPUT |NL| Temporary  | Calc. | Spare | Machine | GOSUB |?|$3E|
;    | data  |  | Work Space | Stack |       |  Stack  | Stack | |   |
;  --+-------+--+------------+-------+-------+---------+-------+-+---+
;    ^                       ^       ^       ^                   ^   ^
;  WORKSP                  STKBOT  STKEND   sp               RAMTOP P_RAMT
;

	DEFS	44

; ----------------------
; THE 'START-NEW' BRANCH
; ----------------------
;  This branch is taken from above and from RST 00h.
;  The common code tests RAM and sets it to zero re-initializing all the
;  non-zero system variables and channel information.  The A register flags
;  if coming from START or NEW.

START_3:
	LD	A,$07		; Select a white border
	OUT	($FE),A		; and set it now by writing to a port.
	XOR	A		; Select default Spectrum screen mode
	OUT	($FF),A		; and set it now by writing to a port.
	LD	A,$3F		; Load the accumulator with last page in ROM.
	LD	I,A		; Set the I register - this remains constant
				; and can't be in the range $40 - $7F as 'snow'
				; appears on the screen.

; -----------------------
; THE 'RAM CLEAR' SECTION
; -----------------------
; Since faulty RAM isn't really an issue these days it is much quicker to just
; wipe it rather than testing it. This routine Zeros up to top of physical RAM
; A different method of testing for a 16K machine is therefore required.

;	LD	IYh,D		; copy the contents of the DE register
;	LD	IYl,E		; pair into the IY register pair. 

	DEFB	$FD		; since these instructions are undocumented
	LD	H,D		; some assemblers won't compile them but we
	DEFB	$FD		; can trick them into it by using DEFB $FD
	LD	H,E		; in front of the LD H,n equivalents.
	EX	DE,HL		; transfer top value to the HL register pair.
	LD	DE,ATTR_0	; start clearing from the attributes.
	AND	A		; prepare for true subtraction.
	SBC	HL,DE		; this gives the number of bytes to clear.
	LD	B,H		; the result is stored in BC.
	LD	C,L		;
	EX	DE,HL		; HL now holds $5BA8.
	LD	(HL),$00		; clear it
	LD	D,H		; this allows progressive clearing.
	LD	E,L		;
	INC	DE		;
	LDIR			; zap the RAM (screen goes black).

;	LD	D,IYh		; copy the contents of the IY register
;	LD	E,IYl		; pair into the DE register pair. 

	DEFB	$FD		; since these instructions are undocumented
	LD	D,H		; most assemblers won't compile them but we
	DEFB	$FD		; can trick them into it by using DEFB $FD
	LD	E,L		; in front of the LD H,n equivalents.

	LD	(P_RAMT),HL	; set P_RAMT to the highest working RAM address.
	LD	HL,CHAR_SET + $108; address of first byte of 'A' bitmap in ROM.
	LD	DE,UDGDEF	; The UDGs now start after the screen.
	LD	(UDG),DE		; make UDG system variable address the first
				; bitmap.
	LD	BC,$00A8		; there are 21 user defined graphics.
	LDIR			; copy of the standard characters A - U.
	LD	HL,NMI_VECT	; The default NMI routine address
	LD	(NMIADD),HL	; is loaded to NMIADD.
	LD	HL,(P_RAMT)	;
	LD	(RAMTOP),HL	; set system variable RAMTOP to HL.
	LD	BC,$0040		; set the values of
	LD	(RASP),BC	; the PIP and RASP system variables.

; New
; Note. this entry point is a disabled Warm Restart that was almost certainly
; once pointed to by the System Variable NMIADD.  It would be essential that
; any NMI Handler would perform the tasks from here to the EI instruction
; below. This is now the default NMI routine.

NMI_VECT:
	LD	HL,CHAR_SET - $100; a strange place to set the pointer to the
	LD	(CHARS),HL	; character set, CHARS - as no printing yet.
	LD	HL,(RAMTOP)	; fetch RAMTOP to HL again as we've lost it.
	LD	(HL),$3E		; top of user ram holds GOSUB end marker
				; an impossible line number - see RETURN.
				; no significance in the number $3E. It has
				; been traditional since the ZX80.
	DEC	HL		; followed by empty byte (not important).
	LD	SP,HL		; set up the machine stack pointer.
	DEC	HL		;
	DEC	HL		;
	LD	(ERR_SP),HL	; ERR_SP is where the error pointer is
				; at moment empty - will take address MAIN-4
				; at the call preceding that address,
				; although interrupts and calls will make use
				; of this location in meantime.
	IM	1		; select interrupt mode 1.
	LD	IY,ERR_NR	; set IY to ERR_NR. IY can reach all standard
				; system variables but shadow ROM system
				; variables will be mostly out of range.
	EI			; enable interrupts now that we have a stack.

; If, as suggested above, the NMI service routine pointed to this section of
; code then a decision would have to be made at this point to jump forward,
; in a Warm Restart scenario, to produce a report code, leaving any program
; intact. Checking CHANS is as good as anything.

	LD	A,(CHANS + 1)	; fetch high byte of CHANS
	AND	A		; Is it unitialized?
	LD	A,$15		; If not set error code L - BREAK.
	JP	NZ,MAIN_G	; to MAIN_G for NMI report.
	JR	SET_CHANS	; skip a spare section.

; If CHANS was zero then this is the first time through here.

SET_CHANS:
	LD	HL,CHANNELS	; The address of the channels - initially
				; following system variables.
	LD	(CHANS),HL	; Set the CHANS system variable.
	LD	DE,INIT_CHAN	; Address in ROM.
	LD	BC,$0010		; there are 16 bytes of initial data in ROM.
	EX	DE,HL		; swap the pointers.
	LDIR			; Copy the bytes to RAM.
	EX	DE,HL		; Swap pointers. HL points to program area.
	DEC	HL		; Decrement address.
	LD	(DATADD),HL	; Set DATADD to location before program area.
	INC	HL		; Increment again.
	LD	(PROG),HL	; Set PROG the location where BASIC starts.
	LD	(VARS),HL	; Set VARS to same location with a
	LD	(HL),$80		; variables end-marker.
	INC	HL		; Advance address.
	LD	(E_LINE),HL	; Set E_LINE, where the edit line
				; will be created.
	LD	A,$38		; the colour system is set to white paper,
				; black ink, no flash or bright.
	LD	(ATTR_P),A	; set ATTR_P permanent colour attributes.
	LD	(BORDCR),A	; set BORDCR the border colour/lower screen
				; attributes.
	LD	HL,$0219		; The keyboard repeat and delay values are
	LD	(REPDEL),HL	; loaded to REPDEL and REPPER.
	DEC	(IY-$3A)		; set KSTATE-0 to $FF - keyboard map available.
	DEC	(IY-$36)		; set KSTATE-4 to $FF - keyboard map available.
	LD	HL,INIT_STRM	; set source to ROM Address: init-strm
	LD	DE,STRMS_FD	; set destination to system variable STRMS-FD
	LD	C,$0C		; copy the 12 bytes of initial 6 streams data
	LDIR			; from ROM to RAM.
	LD	(IY+$31),$02	; set DF_SZ the lower screen display size to
				; two lines
	CALL	CLS		; to set up system
				; variables associated with screen and clear
				; the screen and set attributes.
	LD	DE,COPYRIGHT - 1	; the message table directly.
	CALL	PO_MSG		; puts copyright message at bottom of display.
	SET	5,(IY+$02)	; update TV_FLAG  - signal lower screen will
				; require clearing.

; -------------------
; THE 'RESIDOS' PATCH
; -------------------
;  This location is patched by ResiDOS to display copyright and other information.

	ORG	$12A0
RAM_FWD:	JR	MAIN_1		; forward

; -------------------------
; THE 'MAIN EXECUTION LOOP'
; -------------------------
; The main execution loop controls the 'editing mode', the execution of direct
; commands and the production of reports.

	ORG	$12A2
MAIN_EXEC:
	LD	(IY+$31),$02	; set DF_SZ lower screen display file size to
				; two lines.
	CALL	AUTO_LIST	;

	ORG	$12A9
MAIN_1:	CALL	SET_MIN		; clears work areas.


	ORG	$12AC
MAIN_2:	LD	A,$00		; select channel 'K' the keyboard
	CALL	CHAN_OPEN	; opens it

	CALL	NEWED		; New Editor.

	CALL	LINE_SCAN	; scans the input.
	BIT	7,(IY+$00)	; test ERR_NR - will be $FF if syntax is OK.
	JR	NZ,MAIN_3	; forward, if correct

;

	BIT	4,(IY+$30)	; test FLAGS2 - K channel in use ?
	JR	Z,MAIN_4		; forward if not.

;

	LD	HL,(E_LINE)	; an editing error so address E_LINE.
	CALL	REMOVE_FP		; removes the hidden floating-point forms.
	LD	(IY+$00),$FF	; system variable ERR_NR is reset to 'OK'.
	JR	MAIN_2		; back to allow user to correct.

; ---

; the branch was here if syntax has passed test.


	ORG	$12CF
MAIN_3:
	NOP			;
	NOP			;
	NOP			;
	NOP			;
	NOP			;
	NOP			; balance the bytes removed.

	CALL	E_LINE_NO	; will fetch any line
				; number to BC if this is a program line.
	LD	A,B		; test if the number of
	OR	C		; the line is non-zero.
	JP	NZ,MAIN_ADD	; jump forward if so to add the
				; line to the BASIC program.

; Has the user just pressed the ENTER key ?

	RST	18H		; GET_CHAR gets character addressed by CH_ADD.
	CP	$0D		; is it a carriage return ?
	JR	Z,MAIN_EXEC	; back to MAIN-EXEC if so for an automatic
				; listing.

; this must be a direct command.

	BIT	0,(IY+$30)	; test FLAGS2 - clear the main screen ?
	CALL	NZ,CL_ALL		; if so, e.g. after listing.
	CALL	CLS_LOWER		; anyway.
	LD	A,$19		; compute scroll count as 25 minus
	SUB	(IY+$4F)		; value of S_POSN_H.
	LD	(SCR_CT),A	; update system variable.
	SET	7,(IY+$01)	; update FLAGS - signal running program.
	LD	(IY+$00),$FF	; set ERR_NR to 'OK'.
	LD	(IY+$0A),$01	; set NSPPC to one for first statement.
	CALL	LINE_RUN	; to run the line.
				; sysvar ERR_SP therefore addresses MAIN-4

; Examples of direct commands are RUN, CLS, LOAD "", PRINT USR 40000,
; LPRINT "A"; etc..

; If a user written machine-code program disables interrupts then it
; must enable them to pass the next step. We also jumped to here if the
; keyboard was not being used.
; A HALT instruction is a means by which the Z80 can communicate to an
; external device.
; A side effect of this is that interrupts must be enabled to pass this
; stage. Activating the NMI will also jump past this point even if the
; service routine consists of RETN only.
;
; Normally interrupts are enabled. The exceptions are when a user-written
; program disables them and also when an error is encountered while
; Interface 1 is calling routines in this ROM.

	ORG	$1303
MAIN_4:	EI			; enable interrupts
	HALT			; If interrupts are disabled then halt at this
				; address until the NMI is activated.

;;;	RES	5,(IY+$01)	; update bit 5 of FLAGS - signal no new key.

;;;	BIT	1,(IY+$30)	; test FLAGS2 - is printer buffer clear ?
;;;	CALL	NZ,COPY_BUFF	; call if not.
				; Note. the programmer has neglected
				; to set bit 1 of FLAGS first.
	NOP
	NOP			; the call for ON ERR can go here
	NOP

	CALL	AY_OFF		; turn that racket down!

	RES	5,(IY+$01)	; update bit 5 of FLAGS - signal no new key.
	LD	A,(ERR_NR)	; fetch ERR_NR
	INC	A		; increment to give true code.

; Now deal with a runtime error as opposed to an editing error.
; However if the error code is now zero then the OK message will be printed.

	ORG	$1313
MAIN_G:	PUSH	AF		; save the error number.
	LD	HL,$0000		; prepare to clear some system variables.
	LD	(IY+$37),H	; clear all the bits of FLAGX.
	LD	(IY+$26),H	; blank X_PTR_H to suppress error marker.
	LD	(DEFADD),HL	; blank DEFADD to signal that no defined
				; function is currently being evaluated.
	LD	HL,$0001		; explicit - inc hl would do.
	LD	(STRMS_00),HL	; ensure STRMS-00 is keyboard.
	CALL	SET_MIN		; clears workspace etc.
	RES	5,(IY+$37)	; update FLAGX - signal in EDIT not INPUT mode.
				; Note. all the bits were reset earlier.
	CALL	CLS_LOWER		;
	SET	5,(IY+$02)	; update TV_FLAG - signal lower screen
				; requires clearing.
	POP	AF		; bring back the true error number
	LD	B,A		; and make a copy in B.
	CP	$0A		; is it a print-ready digit ?
	JR	C,MAIN_5		; forward if so.
	ADD	A,$07		; add ASCII offset to letters.


	ORG	$133C
MAIN_5:	CALL	OUT_CODE		; to print the code.
	LD	A,$20		; followed by a space.
	RST	10H		; PRINT_A
	LD	A,B		; fetch stored report code.
	LD	DE,RPT_MESGS	; address: rpt-mesgs.
	CALL	PO_MSG		; to print the message.

X1349:	XOR	A		; clear accumulator to directly
	LD	DE,COMMA_SP - 1	; address the comma and space message.
	CALL	PO_MSG		; prints ', ' although it would
				; be more succinct to use RST $10.

	LD	BC,(PPC)		; fetch the current line number.
	CALL	OUT_NUM_1		; will print that
	LD	A,$3A		; then a ':' character.
	RST	10H		; PRINT_A
	LD	C,(IY+$0D)	; then SUBPPC for statement
	LD	B,$00		; limited to 127
	CALL	OUT_NUM_1		; prints BC.
	CALL	CLEAR_SP		; clears editing area which
				; probably contained 'RUN'.
	LD	A,(ERR_NR)	; fetch ERR_NR again
	INC	A		; test for no error originally $FF.
	JR	Z,MAIN_9		; forward if no error.
	CP	$09		; is code Report 9 STOP ?
	JR	Z,MAIN_6		; forward if so
	CP	$15		; is code Report L Break ?
	JR	NZ,MAIN_7		; forward if not

; Stop or Break was encountered so consider CONTINUE.

	ORG	$1373
MAIN_6:	INC	(IY+$0D)		; increment SUBPPC to next statement.


	ORG	$1376
MAIN_7:	LD	BC,$0003		; prepare to copy 3 system variables to
	LD	DE,OSPPC		; - statement for CONTINUE.
				; also updating OLDPPC line number below.
	LD	HL,NSPPC		; set source top to NSPPC next statement.
	BIT	7,(HL)		; did BREAK occur before the jump ?
				; e.g. between GO TO and next statement.
	JR	Z,MAIN_8		; skip forward, if not, as set-up is correct.
	ADD	HL,BC		; set source to SUBPPC number of current
				; statement/line which will be repeated.

	ORG	$1384
MAIN_8:	LDDR			; copy PPC to OLDPPC and SUBPPC to OSPCC
				; or NSPPC to OLDPPC and NEWPPC to OSPCC

	ORG	$1386
MAIN_9:	LD	(IY+$0A),$FF	; update NSPPC - signal 'no jump'.
	JP	MAIN_2		; jump back to MAIN-2.

; ----------------------
; Canned report messages
; ----------------------
; The Error reports with the last byte inverted. The first entry
; is a dummy entry. The last, which begins with $7F, the Spectrum
; character for copyright symbol, is placed here for convenience
; as is the preceding comma and space.
; The report line must accommodate a 4-digit line number and a 3-digit
; statement number which limits the length of the message text to twenty
; characters.
; e.g.  "B Out of range, 1000:127"

RPT_MESGS:
	DEFB	$80
	DEFB	'O','K'+$80	; 0
	DEFM	"Unexpected NEX"
	DEFB	'T'+$80		; 1
	DEFM	"Undefined variabl"
	DEFB	'e'+$80		; 2
	DEFM	"Bad subscrip"
	DEFB	't'+$80		; 3
	DEFM	"Memory ful"
	DEFB	'l'+$80		; 4
	DEFM	"Out of scree"
	DEFB	'n'+$80		; 5
	DEFM	"Overflo"
	DEFB	'w'+$80		; 6
	DEFM	"Unexpected RETUR"
	DEFB	'N'+$80		; 7
	DEFM	"End of fil"
	DEFB	'e'+$80		; 8
	DEFM	"BREAK in progra"
	DEFB	'm'+$80		; 9
	DEFM	"Bad argumen"
	DEFB	't'+$80		; A
	DEFM	"Out of rang"
	DEFB	'e'+$80		; B
	DEFM	"Syntax erro"
	DEFB	'r'+$80		; C
	DEFM	"BREAK, CONT repeat"
	DEFB	's'+$80		; D
	DEFM	"DATA missin"
	DEFB	'g'+$80		; E
	DEFM	"Bad filenam"
	DEFB	'e'+$80		; F
	DEFM	"Memory lo"
	DEFB	'w'+$80		; G
	DEFM	"BREAK in INPU"
	DEFB	'T'+$80		; H
	DEFM	"NEXT missin"
	DEFB	'g'+$80		; I
	DEFM	"Bad devic"
	DEFB	'e'+$80		; J
	DEFM	"Bad colou"
	DEFB	'r'+$80		; K
	DEFM	"BREA"
	DEFB	'K'+$80		; L
	DEFM	"Bad RAMTO"
	DEFB	'P'+$80		; M
	DEFM	"Statement los"
	DEFB	't'+$80		; N
	DEFM	"Bad strea"
	DEFB	'm'+$80		; O
	DEFM	"Undefined F"
	DEFB	'N'+$80		; P
	DEFM	"Parameter erro"
	DEFB	'r'+$80		; Q
	DEFM	"Loading erro"
	DEFB	'r'+$80		; R

COMMA_SP:DEFB	',',' '+$80	; used in report line.

; -----------------------
; THE 'COPYRIGHT' MESSAGE
; -----------------------
; Modified with the kind permission of Amstrad, plc.

COPYRIGHT:
	DEFW	$0113		; BRIGHT 1
	DEFW	$0114		; INVERSE 1
	DEFM	"SE Basic release 0.94B    "
	DEFW	$0211		; PAPER 2 -red
	DEFB	$1F		; triangle
	DEFW	$0210		; INK 2 - red
	DEFW	$0611		; PAPER 6 - yellow
	DEFB	$1F		; triangle
	DEFW	$0610		; INK 6 - yellow
	DEFW	$0411		; PAPER 4 - green
	DEFB	$1F		; triangle
	DEFW	$0410		; INK 4 - green
	DEFW	$0511		; PAPER 5 - cyan
	DEFB	$1F		; triangle
	DEFW	$0510		; INK 5 - cyan
	DEFW	$0011		; PAPER 0 - black
	DEFB	$1F		; triangle
	DEFW	$0010		; INK 0 - black
	DEFW	$0711		; PAPER 7 - white
	DEFB	$20		; space
	DEFW	$0013		; BRIGHT 0
	DEFW	$0014		; INVERSE 0
	DEFW	$0D0D		; skip a line
	DEFM	"Copyright "	;
	DEFB	$7F		; copyright
	DEFM	"1982-87 Amstrad, plc"
	DEFB	'.'+$80		;

	DEFS	19

; -------------
; REPORT-G
; -------------
; Note ERR_SP points here during line entry which allows the
; normal 'Out of Memory' report to be augmented to the more
; precise 'No Room for line' report.

	ORG	$1555
REPORT_G:	LD	A,$10		; i.e. 'G' -$30 -$07
	LD	BC,$0000		; this seems unnecessary.
	JP	MAIN_G		; jump back

; -----------------------------
; Handle addition of BASIC line
; -----------------------------
; Note this is not a subroutine but a branch of the main execution loop.
; System variable ERR_SP still points to editing error handler.
; A new line is added to the BASIC program at the appropriate place.
; An existing line with same number is deleted first.
; Entering an existing line number deletes that line.
; Entering a non-existent line allows the subsequent line to be edited next.

	ORG	$155D
MAIN_ADD:	LD	(E_PPC),BC	; set E_PPC to extracted line number.
	LD	HL,(CH_ADD)	; - points to location after the
				; initial digits (set in E_LINE_NO).
	EX	DE,HL		; save start of BASIC in DE.
	LD	HL,REPORT_G	;
	PUSH	HL		; is pushed on stack and addressed by ERR_SP.
				; the only error that can occur is
				; 'Memory full'.
	LD	HL,(WORKSP)	; - end of line.
	SCF			; prepare for true subtraction.
	SBC	HL,DE		; find length of BASIC and
	PUSH	HL		; save it on stack.
	LD	H,B		; transfer line number
	LD	L,C		; to HL register.
	CALL	LINE_ADDR		; will see if a line with the same number
				; exists.
	JR	NZ,MAIN_ADD1	; forward if no existing line
	CALL	NEXT_ONE		; finds the existing line.
	CALL	RECLAIM_2		; reclaims it.

	ORG	$157D
MAIN_ADD1:
	POP	BC		; retrieve the length of the new line.
	LD	A,C		; and test if carriage return only
	DEC	A		; i.e. one byte long.
	OR	B		; result would be zero.
	JR	Z,MAIN_ADD2	; forward if so.
	PUSH	BC		; save the length again.
	INC	BC		; adjust for inclusion
	INC	BC		; of line number (two bytes)
	INC	BC		; and line length
	INC	BC		; (two bytes).
	DEC	HL		; HL points to location before the destination
	LD	DE,(PROG)		; fetch the address of PROG
	PUSH	DE		; and save it on the stack
	CALL	MAKE_ROOM		; creates BC spaces in
				; program area and updates pointers.
	POP	HL		; restore old program pointer.
	LD	(PROG),HL		; and put back in PROG as it may have been
				; altered by the POINTERS routine.
	POP	BC		; retrieve BASIC length
	PUSH	BC		; and save again.
	INC	DE		; points to end of new area.
	LD	HL,(WORKSP)	; - location after edit line.
	DEC	HL		; decrement to address end marker.
	DEC	HL		; decrement to address carriage return.
	LDDR			; copy the BASIC line back to initial command.
	LD	HL,(E_PPC)	; - line number.
	EX	DE,HL		; swap it to DE, HL points to last of
				; four locations.
	POP	BC		; retrieve length of line.
	LD	(HL),B		; high byte last.
	DEC	HL		;
	LD	(HL),C		; then low byte of length.
	DEC	HL		;
	LD	(HL),E		; then low byte of line number.
	DEC	HL		;
	LD	(HL),D		; then high byte range $0 - $27 (1-9999).

	ORG	$15AB
MAIN_ADD2:
	POP	AF		; drop the address of Report G
	JP	MAIN_EXEC		; and back producing a listing
				; and to reset ERR_SP in EDITOR.

; ---------------------------------
; THE 'INITIAL CHANNEL' INFORMATION
; ---------------------------------
; This initial channel information is copied from ROM to RAM, during
; initialization.  It's new location is after the system variables and is
; addressed by the system variable CHANS which means that it can slide up and
; down in memory.  The table is never searched, by this ROM, and the last
; character, which could be anything other than a comma, provides a
; convenient resting place for DATADD.

	ORG	$15AF
INIT_CHAN:
	DEFW	PRINT_OUT
	DEFW	KEY_INPUT
	DEFB	'K'
	DEFW	PRINT_OUT
	DEFW	REPORT_J
	DEFB	'S'
	DEFW	ADD_CHAR
	DEFW	REPORT_J
	DEFB	'R'
	DEFB	$80

	DEFS	5

	ORG	$15C4
REPORT_J:
	RST	08H		; ERROR_1
	DEFB	$12		; Error Report: Bad device

; -------------------------
; THE 'INITIAL STREAM' DATA
; -------------------------
; This is the initial stream data for the seven streams $FD - $03 that is
; copied from ROM to the STRMS system variables area during initialization.
; There are reserved locations there for another 12 streams.  Each location
; contains an offset to the second byte of a channel.  The first byte of a
; channel can't be used as that would result in an offset of zero for some
; and zero is used to denote that a stream is closed.

	ORG	$15C6
INIT_STRM:
	DEFB	$01,$00		; stream $FD offset to channel 'K'
	DEFB	$06,$00		; stream $FE offset to channel 'S'
	DEFB	$0B,$00		; stream $FF offset to channel 'R'
	DEFB	$01,$00		; stream $00 offset to channel 'K'
	DEFB	$01,$00		; stream $01 offset to channel 'K'
	DEFB	$06,$00		; stream $02 offset to channel 'S'

	DEFS	2

; ------------------------------
; THE 'INPUT CONTROL' SUBROUTINE
; ------------------------------
; This subroutine is the controlling subroutine for calling the current input
; subroutine.

	ORG	$15D4
WAIT_KEY:	BIT	5,(IY+$02)	; test TV_FLAG - clear lower screen ?
	JR	NZ,WAIT_KEY1	; forward if so.
	SET	3,(IY+$02)	; update TV_FLAG - signal reprint the edit
				; line to the lower screen.

	ORG	$15DE
WAIT_KEY1:
	CALL	INPUT_AD		;
	RET	C		; return with acceptable keys.
	JR	Z,WAIT_KEY1	; back if no key is pressed
				; or it has been handled within INPUT_AD.

; Note. When inputting from the keyboard all characters are returned with
; above conditions so this path is never taken.

	ORG	$15E4
REPORT_8:	RST	08H		; ERROR_1
	DEFB	$07		; Error Report: End of file

; ---------------------------
; THE 'INPUT ADDRESS' ROUTINE
; ---------------------------
; This routine fetches the address of the input stream from the current
; channel area using the system variable CURCHL.


	ORG	$15E6
INPUT_AD:	EXX			; switch in alternate set.
	PUSH	HL		; save HL register
	LD	HL,(CURCHL)	; - current channel.
	INC	HL		; step over output routine
	INC	HL		; to point to low byte of input routine.
	JR	CALL_SUB		; forwatd

; -------------------------
; THE 'CODE OUTPUT' ROUTINE
; -------------------------
; This routine is called on five occasions to print the ASCII equivalent of
; a value 0-9.

	ORG	$15EF
OUT_CODE:	LD	E,$30		; add 48 decimal to give the ASCII character
	ADD	A,E		; '0' to '9' and continue into the main output
				; routine.

; -------------------------
; THE 'MAIN OUTPUT' ROUTINE
; -------------------------
; PRINT_A_2 is a continuation of the RST 10 restart that prints any character.
; The routine prints to the current channel and the printing of control codes
; may alter that channel to divert subsequent RST 10 instructions to temporary
; routines. The normal channel is $09F4.

	ORG	$15F2
PRINT_A_2:
	EXX			; switch in alternate set
	PUSH	HL		; save HL register
	LD	HL,(CURCHL)	; fetch CURCHL the current channel.

; input-ad rejoins here also.

	ORG	$15F7
CALL_SUB:	LD	E,(HL)		; put the low byte in E.
	INC	HL		; advance address.
	LD	D,(HL)		; put the high byte to D.
	EX	DE,HL		; transfer the stream to HL.
	CALL	CALL_JUMP		; in effect CALL (HL).
	POP	HL		; restore saved HL register.
	EXX			; switch back to the main set and
	RET			; return.

; --------------------------
; THE 'OPEN CHANNEL' ROUTINE
; --------------------------
; This subroutine is used by the ROM to open a channel 'K', 'S', 'R' or 'P'.
; This is either for its own use or in response to a user's request, for
; example, when '#' is encountered with output - PRINT, LIST etc.
; or with input - INPUT, INKEY$ etc.
; It is entered with a system stream $FD - $FF, or a user stream $00 - $0F
; in the accumulator.

	ORG	$1601
CHAN_OPEN:
	ADD	A,A		; double the stream ($FF will become $FE etc.)
	ADD	A,$16		; add the offset to stream 0 from $5C00
	LD	L,A		; result to L
	LD	H,$5C		; now form the address in STRMS area.
	LD	E,(HL)		; fetch low byte of CHANS offset
	INC	HL		; address next
	LD	D,(HL)		; fetch high byte of offset
	LD	A,D		; test that the stream is open.
	OR	E		; zero if closed.
	JR	NZ,CHAN_OP_1	; forward if open.

	ORG	$160E
REPORT_Oa:
	RST	08H		; ERROR_1
	DEFB	$17		; Error Report: Bad stream

; continue here if stream was open. Note that the offset is from CHANS
; to the second byte of the channel.

	ORG	$1610
CHAN_OP_1:
	DEC	DE		; reduce offset so it points to the channel.
	LD	HL,(CHANS)	; fetch CHANS the location of the base of
				; the channel information area
	ADD	HL,DE		; and add the offset to address the channel.
				; and continue to set flags.

; -----------------
; Set channel flags
; -----------------
; This subroutine is used from ED_EDIT, str$ and read-in to reset the
; current channel when it has been temporarily altered.

	ORG	$1615
CHAN_FLAG:
	LD	(CURCHL),HL	; set CURCHL system variable to the
				; address in HL
	RES	4,(IY+$30)	; update FLAGS2  - signal K channel not in use.
				; Note. provide a default for channel 'R'.
	INC	HL		; advance past
	INC	HL		; output routine.
	INC	HL		; advance past
	INC	HL		; input routine.
	LD	C,(HL)		; pick up the letter.
	LD	HL,CHN_CD_LU	;
	CALL	INDEXER		; finds offset to a flag-setting routine.
	RET	NC		; but if the letter wasn't found in the
				; table just return now. - channel 'R'.
	LD	D,$00		; prepare to add
	LD	E,(HL)		; offset to E
	ADD	HL,DE		; add offset to location of offset to form
				; address of routine

	ORG	$162C
CALL_JUMP:
	JP	(HL)		; jump to the routine

; Footnote. calling any location that holds JP (HL) is the equivalent to
; a pseudo Z80 instruction CALL (HL). The ROM uses the instruction above.

; --------------------------
; Channel code look-up table
; --------------------------
; This table is used by the routine above to find one of the three
; flag setting routines below it.
; A zero end-marker is required as channel 'R' is not present.

	ORG	$162D
CHN_CD_LU:
	DEFB	'K',CHAN_K-$-1	; offset $06 to CHAN_K
	DEFB	'S',CHAN_S-$-1	; offset $12 to CHAN_S
	DEFB	'P',CHAN_P-$-1	; offset $1B to CHAN_P
	DEFB	$00		; end marker.

; --------------
; Channel K flag
; --------------
; routine to set flags for lower screen/keyboard channel.

	ORG	$1634
CHAN_K:	SET	0,(IY+$02)	; update TV_FLAG  - signal lower screen in use
	RES	5,(IY+$01)	; update FLAGS  - signal no new key
	SET	4,(IY+$30)	; update FLAGS2 - signal K channel in use
	JR	CHAN_S_1		; forward for indirect exit

; --------------
; Channel S flag
; --------------
; routine to set flags for upper screen channel.

	ORG	$1642
CHAN_S:	RES	0,(IY+$02)	; TV_FLAG  - signal main screen in use

	ORG	$1646
CHAN_S_1:	RES	1,(IY+$01)	; update FLAGS  - signal printer not in use
	JP	TEMPS		; jump back to TEMPS and exit via that
				; routine after setting temporary attributes.

; --------------
; Channel P flag
; --------------
; This routine sets a flag so that subsequent print related commands
; print to printer or update the relevant system variables.
; This status remains in force until reset by the routine above.

	ORG	$164D
CHAN_P:	SET	1,(IY+$01)	; update FLAGS  - signal printer in use
	RET			; return

; --------------------------
; THE 'ONE SPACE' SUBROUTINE
; --------------------------
; This routine is called once only to create a single space
; in workspace by ADD-CHAR.

	ORG	$1652
ONE_SPACE:
	LD	BC,$0001		; create space for a single character.

; ---------
; Make Room
; ---------
; This entry point is used to create BC spaces in various areas such as
; program area, variables area, workspace etc..
; The entire free RAM is available to each BASIC statement.
; On entry, HL addresses where the first location is to be created.
; Afterwards, HL will point to the location before this.

	ORG	$1655
MAKE_ROOM:
	PUSH	HL		; save the address pointer.
	CALL	TEST_ROOM		; checks if room
				; exists and generates an error if not.
	POP	HL		; restore the address pointer.
	CALL	POINTERS		; updates the dynamic memory location pointers.
				; DE now holds the old value of STKEND.
	LD	HL,(STKEND)	; fetch new STKEND the top destination.
	EX	DE,HL		; HL now addresses the top of the area to
				; be moved up - old STKEND.
	LDDR			; the program, variables, etc are moved up.
	RET			; return with new area ready to be populated.
				; HL points to location before new area,
				; and DE to last of new locations.

; -----------------------------------------------
; Adjust pointers before making or reclaiming room
; -----------------------------------------------
; This routine is called by MAKE_ROOM to adjust upwards and by RECLAIM to
; adjust downwards the pointers within dynamic memory.
; The fourteen pointers to dynamic memory, starting with VARS and ending
; with STKEND, are updated adding BC if they are higher than the position
; in HL.
; The system variables are in no particular order except that STKEND, the first
; free location after dynamic memory must be the last encountered.

	ORG	$1664
POINTERS:	PUSH	AF		; preserve accumulator.
	PUSH	HL		; put pos pointer on stack.
	LD	HL,VARS		; address VARS the first of the
	LD	A,$0E		; fourteen variables to consider.

	ORG	$166B
PTR_NEXT:	LD	E,(HL)		; fetch the low byte of the system variable.
	INC	HL		; advance address.
	LD	D,(HL)		; fetch high byte of the system variable.
	EX	(SP),HL		; swap pointer on stack with the variable
				; pointer.
	AND	A		; prepare to subtract.
	SBC	HL,DE		; subtract variable address
	ADD	HL,DE		; and add back
	EX	(SP),HL		; swap pos with system variable pointer
	JR	NC,PTR_DONE	; forward if var before pos
	PUSH	DE		; save system variable address.
	EX	DE,HL		; transfer to HL
	ADD	HL,BC		; add the offset
	EX	DE,HL		; back to DE
	LD	(HL),D		; load high byte
	DEC	HL		; move back
	LD	(HL),E		; load low byte
	INC	HL		; advance to high byte
	POP	DE		; restore old system variable address.

	ORG	$167F
PTR_DONE:	INC	HL		; address next system variable.
	DEC	A		; decrease counter.
	JR	NZ,PTR_NEXT	; back if more.
	EX	DE,HL		; transfer old value of STKEND to HL.
				; Note. this has always been updated.
	POP	DE		; pop the address of the position.
	POP	AF		; pop preserved accumulator.
	AND	A		; clear carry flag preparing to subtract.
	SBC	HL,DE		; subtract position from old stkend
	LD	B,H		; to give number of data bytes
	LD	C,L		; to be moved.
	INC	BC		; increment as we also copy byte at old STKEND.
	ADD	HL,DE		; recompute old stkend.
	EX	DE,HL		; transfer to DE.
	RET			; return.

; -------------------
; Collect line number
; -------------------
; This routine extracts a line number, at an address that has previously
; been found using LINE-ADDR, and it is entered at LINE-NO. If it encounters
; the program 'end-marker' then the previous line is used and if that
; should also be unacceptable then zero is used as it must be a direct
; command. The program end-marker is the variables end-marker $80, or
; if variables exist, then the first character of any variable name.

	ORG	$168F
LINE_ZERO:
	DEFB	$00,$00		; dummy line number used for direct commands

	ORG	$1691
LINE_NO_A:
	EX	DE,HL		; fetch the previous line to HL and set
	LD	DE,LINE_ZERO	; DE to LINE_ZERO should HL also fail.

; -> The Entry Point.

	ORG	$1695
LINE_NO:	LD	A,(HL)		; fetch the high byte - max $2F
	AND	$C0		; mask off the invalid bits.
	JR	NZ,LINE_NO_A	; if an end-marker.
	LD	D,(HL)		; reload the high byte.
	INC	HL		; advance address.
	LD	E,(HL)		; pick up the low byte.
	RET			; return from here.

; -------------------
; Handle reserve room
; -------------------
; This is a continuation of the restart BC_SPACES

	ORG	$169E
RESERVE:	LD	HL,(STKBOT)	; first location of calculator stack
	DEC	HL		; make one less than new location
	CALL	MAKE_ROOM		; creates the room.
	INC	HL		; address the first new location
	INC	HL		; advance to second
	POP	BC		; restore old WORKSP
	LD	(WORKSP),BC	; system variable WORKSP was perhaps
				; changed by POINTERS routine.
	POP	BC		; restore count for return value.
	EX	DE,HL		; switch. DE = location after first new space
	INC	HL		; HL now location after new space
	RET			; return.

; ---------------------------
; Clear various editing areas
; ---------------------------
; This routine sets the editing area, workspace and calculator stack
; to their minimum configurations as at initialization and indeed this
; routine could have been relied on to perform that task.
; This routine uses HL only and returns with that register holding
; WORKSP/STKBOT/STKEND though no use is made of this. The routines also
; reset MEM to its usual place in the systems variable area should it
; have been relocated to a FOR-NEXT variable. The main entry point
; SET-MIN is called at the start of the MAIN-EXEC loop and prior to
; displaying an error.

	ORG	$16B0
SET_MIN:	LD	HL,(E_LINE)	; fetch
	LD	(HL),$0D		; insert carriage return
	LD	(K_CUR),HL	; make keyboard cursor point there.
	INC	HL		; next location
	LD	(HL),$80		; holds end-marker $80
	INC	HL		; next location becomes
	LD	(WORKSP),HL	; start of WORKSP

; This entry point is used prior to input and prior to the execution,
; or parsing, of each statement.


	ORG	$16BF
SET_WORK:	LD	HL,(WORKSP)	; fetch value
	LD	(STKBOT),HL	; and place in STKBOT

; This entry point is used to move the stack back to its normal place
; after temporary relocation during line entry and also from ERROR-3


	ORG	$16C5
SET_STK:	LD	HL,(STKBOT)	; fetch value
	LD	(STKEND),HL	; and place in STKEND.
	PUSH	HL		; perhaps an obsolete entry point.
	LD	HL,MEM_0		; normal location of MEM_0
	LD	(MEM),HL		; is restored to system variable MEM.
	POP	HL		; saved value not required.
	RET			; return.

	DEFS	7

; --------------------------
; The Table INDEXING routine
; --------------------------
; This routine is used to search two-byte hash tables for a character
; held in C, returning the address of the following offset byte.
; if it is known that the character is in the table e.g. for priorities,
; then the table requires no zero end-marker. If this is not known at the
; outset then a zero end-marker is required and carry is set to signal
; success.

	ORG	$16DB
INDEXER_1:
	INC	HL		; address the next pair of values.

; -> The Entry Point.


	ORG	$16DC
INDEXER:	LD	A,(HL)		; fetch the first byte of pair
	AND	A		; is it the end-marker ?
	RET	Z		; return with carry reset if so.
	CP	C		; is it the required character ?
	INC	HL		; address next location.
	JR	NZ,INDEXER_1	; back if no match.
	SCF			; else set the carry flag.
	RET			; return with carry set

; --------------------------------
; The Channel and Streams Routines
; --------------------------------
; A channel is an input/output route to a hardware device
; and is identified to the system by a single letter e.g. 'K' for
; the keyboard. A channel can have an input and output route
; associated with it in which case it is bi-directional like
; the keyboard. Others like the upper screen 'S' are output
; only and the input routine usually points to a report message.
; Channels 'K' and 'S' are system channels and it would be inappropriate
; to close the associated streams so a mechanism is provided to
; re-attach them. When the re-attachment is no longer required, then
; closing these streams resets them as at initialization.
; Early adverts said that the network and RS232 were in this ROM.
; Channels 'N' and 'B' are user channels and have been removed successfully
; if, as seems possible, they existed.
; Ironically the tape streamer is not accessed through streams and
; channels.
; Early demonstrations of the Spectrum showed a single microdrive being
; controlled by the main ROM.

; ---------------------
; THE 'CLOSE #' COMMAND
; ---------------------
; This command allows streams to be closed after use.
; Any temporary memory areas used by the stream would be reclaimed and
; finally flags set or reset if necessary.

	ORG	$16E5
CLOSE:	CALL	STR_DATA		; fetches parameter
				; from calculator stack and gets the
				; existing STRMS data pointer address in HL
				; and stream offset from CHANS in BC.

				; Note. this offset could be zero if the
				; stream is already closed. A check for this
				; should occur now and an error should be
				; generated, for example,
				; Report S 'Stream status closed'.

;;; CALL  L1701 ; routine CLOSE-2 would perform any actions
;;;   ; peculiar to that stream without disturbing
;;;   ; data pointer to STRMS entry in HL.
	CALL	CL_FIX		; checks BC for zero then does above.

; Note. The next entry point is used by Interface 1 and the Opus discovery.

X16EB:	LD	BC,$0000		; the stream is to be blanked.
	LD	DE,$A3E2		; the number of bytes from stream 4, $5C1E,
				; to $10000
	EX	DE,HL		; transfer offset to HL, STRMS data pointer
				; to DE.
	ADD	HL,DE		; add the offset to the data pointer.
	JR	C,CLOSE_1		; forward if a non-system stream.
				; i.e. higher than 3.

; proceed with a negative result.

;;;	LD	BC,INIT_STRM + 14	; prepare the address of the byte after
				; the initial stream data in ROM. ($15D4)
	LD	BC,INIT_STRM + 12	; prepare the address of the byte after
				; the initial stream data in ROM. ($15D2)
	ADD	HL,BC		; index into the data table with negative value.
	LD	C,(HL)		; low byte to C
	INC	HL		; address next.
	LD	B,(HL)		; high byte to B.

; and for streams 0 - 2 just enter the initial data back into the STRMS entry
; streams 0 - 2 can't be closed as they are shared by the operating system.
; -> for streams 3 - 15 then blank the entry.

	ORG	$16FC
CLOSE_1:	EX	DE,HL		; address of stream to HL.
	LD	(HL),C		; place zero (or low byte).
	INC	HL		; next address.
	LD	(HL),B		; place zero (or high byte).
	RET			; return.

; ------------------------
; THE 'CLOSE-2' SUBROUTINE
; ------------------------
; There is not much point in coming here.
; The purpose was once to find the offset to a special closing routine,
; in this ROM and within 256 bytes of the close stream look up table that
; would reclaim any buffers associated with a stream. At least one has been
; removed.
; Any attempt to CLOSE streams $00 to $04, without first opening the stream,
; will lead to either a system restart or the production of a strange report.

	ORG	$1701
CLOSE_2:	PUSH	HL		; * save address of stream data pointer
				; in STRMS on the machine stack.
	LD	HL,(CHANS)	; fetch CHANS address to HL
	ADD	HL,BC		; add the offset to address the second
				; byte of the output routine hopefully.
	INC	HL		; step past
	INC	HL		; the input routine.

; Note. When the Sinclair Interface1 is fitted then an instruction fetch
; on the next address pages this ROM out and the shadow ROM in.
; On a standalone Spectrum everything continues OK.
; A check has already been made to ensure that the stream is OPEN
; and the letter was put there by this Operating System.
; With the DISCiPLE then the letter could be 'D' an error has to be
; generated if INDEXER routine does not find the letter.

	ORG	$1708
ROM_TRAP:INC	HL		; to address channel's letter
	LD	C,(HL)		; pick it up in C.
				; Note. but if stream is already closed we
				; get the value $10 (the byte preceding 'K').
	EX	DE,HL		; save the pointer to the letter in DE.

; Note. The string pointer is saved but not used!!

	LD	HL,CL_STR_LU	; use the new look-up table with end-marker
	CALL	INDEXER		; routine  uses the code to get
				; the 8-bit offset from the current point to
				; the address of the closing routine in ROM.
				; Note. it won't find $10 there!
	LD	C,(HL)		; transfer the offset to C.
;;;	LD	B,$00		; prepare to add.
	JR	CL_3		; forward to CL_3

CL_4:	ADD	HL,BC		; add offset to point to the address of the
				; routine that closes the stream.
				; (and presumably removes any buffers that
				; are associated with it.)
	JP	(HL)		; jump to that routine.

CL_3:	LD	B,$00		; displaced instruction
	JR	C,CL_4		; back if code found
	JR	REPORT_Ob	; to report 'Bad stream'

; Note the above report will be converted into a GDOS error.

; ------------------------------
; THE 'CLOSE STREAM' SUBROUTINES
; ------------------------------
; The close stream routines in fact have no ancillary actions to perform
; which is not surprising with regard to 'K' and 'S'.

	ORG	$171C
CLOSE_STR:
	POP	HL		; * now just restore the stream data pointer
	RET			; in STRMS and return.

; -----------
; Stream data
; -----------
; This routine finds the data entry in the STRMS area for the specified
; stream which is passed on the calculator stack. It returns with HL
; pointing to this system variable and BC holding a displacement from
; the CHANS area to the second byte of the stream's channel. If BC holds
; zero, then that signifies that the stream is closed.

	ORG	$171E
STR_DATA:	CALL	FIND_INT1		; fetches parameter to A
	CP	$10		; is it less than 16d ?
	JR	C,STR_DATA1	; skip forward if so.

; ----------------------------------------
; Handle CAT, ERASE, FORMAT, MOVE commands
; ----------------------------------------
; These just generate an error report as the ROM is 'incomplete'.
;
; Luckily this provides a mechanism for extending these in a shadow ROM
; but without the powerful mechanisms set up in this ROM.
; An instruction fetch on $0008 may page in a peripheral ROM,
; e.g. the Sinclair Interface 1 ROM, to handle these commands.
; However that wasn't the plan.
; Development of this ROM continued for another three months until the cost
; of replacing it and the manual became unfeasible.
; The ultimate power of channels and streams died at birth.

	ORG	$1725
CAT_ETC:
REPORT_Ob:
	RST	08H		; ERROR_1
	DEFB	$17		; Error Report: Bad stream


	ORG	$1727
STR_DATA1:
	ADD	A,$03		; add the offset for 3 system streams.
				; range 00 - 15d becomes 3 - 18d.
	RLCA			; double as there are two bytes per
				; stream - now 06 - 36d
	LD	HL,STRMS		; - the start of the streams
				; data area in system variables.
	LD	C,A		; transfer the low byte to A.
	LD	B,$00		; prepare to add offset.
	ADD	HL,BC		; add to address the data entry in STRMS.

; the data entry itself contains an offset from CHANS to the address of the
; stream

	LD	C,(HL)		; low byte of displacement to C.
	INC	HL		; address next.
	LD	B,(HL)		; high byte of displacement to B.
	DEC	HL		; step back to leave HL pointing to STRMS
				; data entry.
	RET			; return with CHANS displacement in BC
				; and address of stream data entry in HL.

; --------------------
; THE 'OPEN #' COMMAND
; --------------------
; Command syntax example: OPEN #5,"s"
; On entry the channel code entry is on the calculator stack with the next
; value containing the stream identifier. They have to swapped.


	ORG	$1736
OPEN:	RST	28H		;; FP_CALC	;s,c.
	DEFB	$01		;;exchange	;c,s.
	DEFB	$38		;;end-calc
	CALL	STR_DATA		; fetches the stream off the stack and
				; returns with the CHANS displacement in BC
				; and HL addressing the STRMS data entry.
	LD	A,B		; test for zero which
	OR	C		; indicates the stream is closed.
	JR	Z,OPEN_1		; skip forward if so.

; if it is a system channel then it can re-attached.

	EX	DE,HL		; save STRMS address in DE.
	LD	HL,(CHANS)	; fetch
	ADD	HL,BC		; add the offset to address the second
				; byte of the channel.
	INC	HL		; skip over the
	INC	HL		; input routine.
	INC	HL		; and address the letter.
	LD	A,(HL)		; pick up the letter.
	EX	DE,HL		; save letter pointer and bring back
				; the STRMS pointer.
	CP	$4B		; is it 'K' ?
	JR	Z,OPEN_1		; forward if so
	CP	$53		; is it 'S' ?
	JR	Z,OPEN_1		; forward if so
	JR	REPORT_Ob	; back for others.
	DEFS	2		; balance removed bytes.

;;;	CP	$50		; is it 'P' ?
;;;	JR	NZ,REPORT_Ob	; back if not.
;;;				; to report 'Bad stream'.

; continue if one of the upper-case letters was found.
; and rejoin here from above if stream was closed.

	ORG	$1756
OPEN_1:	CALL	OPEN_2		; opens the stream.

; it now remains to update the STRMS variable.

	LD	(HL),E		; insert or overwrite the low byte.
	INC	HL		; address high byte in STRMS.
	LD	(HL),D		; insert or overwrite the high byte.
	RET			; return.

; -----------------
; OPEN-2 Subroutine
; -----------------
; There is some point in coming here as, as well as once creating buffers,
; this routine also sets flags.

	ORG	$175D
OPEN_2:	PUSH	HL		; * save the STRMS data entry pointer.
	CALL	STK_FETCH		; now fetches the
				; parameters of the channel string.
				; start in DE, length in BC.
	LD	A,B		; test that it is not
	OR	C		; the null string.
	JR	NZ,OPEN_3		; skip forward with 1 character or more!

	ORG	$1765
REPORT_Fb:
	RST	08H		; ERROR_1
	DEFB	$0E		; Error Report: Bad file name

	ORG	$1767
OPEN_3:	PUSH	BC		; save the length of the string.
	LD	A,(DE)		; pick up the first character.
				; Note. There can be more than one character.
	AND	$DF		; make it upper-case.
	LD	C,A		; place it in C.
	LD	HL,OP_STR_LU	; address loaded.
	CALL	INDEXER		; will search for letter.
	JR	NC,REPORT_Fb	; if not found
				; 'Invalid filename'
	LD	C,(HL)		; fetch the displacement to opening routine.
	LD	B,$00		; prepare to add.
	ADD	HL,BC		; now form address of opening routine.
	POP	BC		; restore the length of string.
	JP	(HL)		; now jump forward to the relevant routine.

; -------------------------
; OPEN stream look-up table
; -------------------------
; The open stream look-up table consists of matched pairs.
; The channel letter is followed by an 8-bit displacement to the
; associated stream-opening routine in this ROM.
; The table requires a zero end-marker as the letter has been
; provided by the user and not the operating system.


	ORG	$177A
OP_STR_LU:
	DEFB	'K',OPEN_K-$-1	; $06 offset to OPEN_K
	DEFB	'S',OPEN_S-$-1	; $08 offset to OPEN_S
	DEFB	'P',OPEN_P-$-1	; $0A offset to OPEN_P
	DEFB	$00		; end-marker.

; ----------------------------
; The Stream Opening Routines.
; ----------------------------
; These routines would have opened any buffers associated with the stream
; before jumping forward to OPEN-END with the displacement value in E
; and perhaps a modified value in BC. The strange pathing does seem to
; provide for flexibility in this respect.
;
; There is no need to open the printer buffer as it is there already
; even if you are still saving up for a ZX Printer or have moved onto
; something bigger. In any case it would have to be created after
; the system variables but apart from that it is a simple task
; and all but one of the ROM routines can handle a buffer in that position.
; (PR-ALL-6 would require an extra 3 bytes of code).
; However it wouldn't be wise to have two streams attached to the ZX Printer
; as you can now, so one assumes that if PR_CC_H was non-zero then
; the OPEN-P routine would have refused to attach a stream if another
; stream was attached.

; Something of significance is being passed to these ghost routines in the
; second character. Strings 'RB', 'RT' perhaps or a drive/station number.
; The routine would have to deal with that and exit to OPEN_END with BC
; containing $0001 or more likely there would be an exit within the routine.
; Anyway doesn't matter, these routines are long gone.

; -----------------
; OPEN-K Subroutine
; -----------------
; Open Keyboard stream.

	ORG	$1781
OPEN_K:	LD	E,$01		; 01 is offset to second byte of channel 'K'.
	JR	OPEN_END		; forward

; -----------------
; OPEN-S Subroutine
; -----------------
; Open Screen stream.


	ORG	$1785
OPEN_S:	LD	E,$06		; 06 is offset to 2nd byte of channel 'S'

OPEN_END:DEC	BC		; the stored length of 'K','S','P' or
				; whatever is now tested. ??
	LD	A,B		; test now if initial or residual length
	OR	C		; is one character.
	JR	NZ,REPORT_Fb	; 'Bad file name' if not.
	LD	D,A		; load D with zero to form the displacement
				; in the DE register.
	POP	HL		; * restore the saved STRMS pointer.
	RET			; return to update STRMS entry thereby
				; signaling stream is open.

; -----------------
; OPEN-P Subroutine
; -----------------
; Open Printer stream.

OPEN_P:	JP	OPEN_ALL		; too big to fit here.

	DEFS	3

; -----------------
; Perform AUTO-LIST
; -----------------
; This produces an automatic listing in the upper screen.

	ORG	$1795
AUTO_LIST:
	LD	(LIST_SP),SP	; save stack pointer
	LD	(IY+$02),$10	; update TV_FLAG set bit 3
	CALL	CL_ALL		;
	SET	0,(IY+$02)	; update TV_FLAG  - signal lower screen in use
	LD	B,(IY+$31)	; fetch DF_SZ to B.
	CALL	CL_LINE		; clears lower display
				; preserving B.
	RES	0,(IY+$02)	; update TV_FLAG  - signal main screen in use
	SET	0,(IY+$30)	; update FLAGS2 - signal will be necessary to
				; clear main screen.
	LD	HL,(E_PPC)	; fetch current edit line to HL.
	LD	DE,(S_TOP)	; fetch the current top line to DE
				; (initially zero)
	AND	A		; prepare for true subtraction.
	SBC	HL,DE		; subtract and
	ADD	HL,DE		; add back.
	JR	C,AUTO_L_2	; jump if S_TOP higher than E_PPC
				; to set S_TOP to E_PPC
	PUSH	DE		; save the top line number.
	CALL	LINE_ADDR		; gets address of E_PPC.
	LD	DE,$02C0		; prepare known number of characters in
				; the default upper screen.
	EX	DE,HL		; offset to HL, program address to DE.
	SBC	HL,DE		; subtract high value from low to obtain
				; negated result used in addition.
	EX	(SP),HL		; swap result with top line number on stack.
	CALL	LINE_ADDR		; gets address of that
				; top line in HL and next line in DE.
	POP	BC		; restore the result to balance stack.

	ORG	$17CE
AUTO_L_1:	PUSH	BC		; save the result.
	CALL	NEXT_ONE		; gets address in HL of
				; line after auto-line (in DE).
	POP	BC		; restore result.
	ADD	HL,BC		; compute back.
	JR	C,AUTO_L_3	; if line 'should' appear
	EX	DE,HL		; address of next line to HL.
	LD	D,(HL)		; get line
	INC	HL		; number
	LD	E,(HL)		; in DE.
	DEC	HL		; adjust back to start.
	LD	(S_TOP),DE	; update S_TOP.
	JR	AUTO_L_1		; until estimate reached.

; ---

; the jump was to here if S_TOP was greater than E_PPC

	ORG	$17E1
AUTO_L_2:	LD	(S_TOP),HL	; make S_TOP the same as E_PPC.

; continue here with valid starting point from above or good estimate
; from computation

	ORG	$17E4
AUTO_L_3:	LD	HL,(S_TOP)	; fetch S_TOP line number to HL.
	CALL	LINE_ADDR		; routine LINE-ADDR gets address in HL.
				; address of next in DE.
	JR	Z,AUTO_L_4	; if line exists.
	EX	DE,HL		; else use address of next line.

	ORG	$17ED
AUTO_L_4:	CALL	LIST_ALL		;	>>>

; The return will be to here if no scrolling occurred

	RES	4,(IY+$02)	; update TV_FLAG  - signal no auto listing.
	RET			; return.

; ------------
; Handle LLIST
; ------------
; A short form of LIST #3. The listing goes to stream 3 - default printer.

	ORG	$17F5
LLIST:	LD	A,$03		; the usual stream for ZX Printer
	JR	LIST_1		; forward

; -----------
; Handle LIST
; -----------
; List to any stream.
; Note. While a starting line can be specified it is
; not possible to specify an end line.
; Just listing a line makes it the current edit line.

	ORG	$17F9
LIST:	LD	A,$02		; default is stream 2 - the upper screen.

	ORG	$17FB
LIST_1:	LD	(IY+$02),$00	; the TV_FLAG is initialized with bit 0 reset
				; indicating upper screen in use.
	CALL	SYNTAX_Z		; - checking syntax ?
	CALL	NZ,CHAN_OPEN	; if in run-time.
	RST	18H		; GET_CHAR
	CALL	STR_ALTER		; will alter if '#'.
	JR	C,LIST_4		; forward if not a '#' .
	RST	18H		; GET_CHAR
	CP	$3B		; is it ';' ?
	JR	Z,LIST_2		; skip if so.
	CP	$2C		; is it ',' ?
	JR	NZ,LIST_3		; forward if neither separator.

; we have, say,  LIST #15, and a number must follow the separator.

	ORG	$1814
LIST_2:	RST	20H		; NEXT_CHAR
	CALL	EXPT_1NUM		;
	JR	LIST_5		; forward

; ---

; the branch was here with just LIST #3 etc.

	ORG	$181A
LIST_3:	CALL	USE_ZERO		;
	JR	LIST_5		; forward

; ---

; the branch was here with LIST


	ORG	$181F
LIST_4:	CALL	FETCH_NUM	; checks if a number
				; follows else uses zero.

	ORG	$1822
LIST_5:	CALL	CHECK_END		; quits if syntax OK >>>

;;;	CALL	FIND_INT2		; routine FIND-INT2 fetches the number
	CALL	FIND_LINE		;+ Similar routine checks line more precisely.

	LD	A,B		; fetch high byte of line number and
	AND	$3F		; make less than $40 so that NEXT_ONE
				; (from LINE_ADDR) doesn't lose context.
				; Note. this is not satisfactory and the typo
				; LIST 20000 will list an entirely different
				; section than LIST 2000. Such typos are not
				; available for checking if they are direct
				; commands.
	LD	H,A		; transfer the modified
	LD	L,C		; line number to HL.
	LD	(E_PPC),HL	; update E_PPC to new line number.
	CALL	LINE_ADDR		; gets the address of the line.

; This routine is called from AUTO_LIST

	ORG	$1833
LIST_ALL:	LD	E,$01		; signal current line not yet printed

	ORG	$1835
LIST_ALL_2:
	CALL	OUT_LINE		; outputs a BASIC line
				; using PRINT-OUT and makes an early return
				; when no more lines to print. >>>
	RST	10H		; PRINT_A prints the carriage return (in A)
	BIT	4,(IY+$02)	; test TV_FLAG  - automatic listing ?
	JR	Z,LIST_ALL_2	; back if not
				; (loop exit is via OUT-LINE)

; continue here if an automatic listing required.

	LD	A,(DF_SZ)		; fetch lower display file size.
	SUB	(IY+$4F)		; subtract S_POSN_H ithe current line number.
	JR	NZ,LIST_ALL_2	; back if upper screen not full.
	XOR	E		; A contains zero, E contains one if the
				; current edit line has not been printed
				; or zero if it has (from OUT_LINE).
	RET	Z		; return if the screen is full and the line
				; has been printed.

; continue with automatic listings if the screen is full and the current
; edit line is missing. OUT-LINE will scroll automatically.

	PUSH	HL		; save the pointer address.
	PUSH	DE		; save the E flag.
	LD	HL,S_TOP		; fetch S_TOP the rough estimate.
	CALL	LN_FETCH		; updates S_TOP with
				; the number of the next line.
	POP	DE		; restore the E flag.
	POP	HL		; restore the address of the next line.
	JR	LIST_ALL_2	; back

; ------------------------
; Print a whole BASIC line
; ------------------------
; This routine prints a whole BASIC line and it is called
; from LIST-ALL to output the line to current channel
; and from ED_EDIT to 'sprint' the line to the edit buffer.

	ORG	$1855
OUT_LINE:LD	BC,(E_PPC)	; fetch E_PPC the current line which may be
				; unchecked and not exist.
	CALL	CP_LINES		; finds match or line after.
	LD	D,$3E		; prepare cursor '>' in D.
	JR	Z,OUT_LINE1	; jump if matched or line after.
	LD	DE,$0000		; put zero in D, to suppress line cursor.
	RL	E		; pick up carry in E if line before current
				; leave E zero if same or after.

	ORG	$1865
OUT_LINE1:
	LD	(IY+$2D),E	; save flag in BREG which is spare.
	LD	A,(HL)		; get high byte of line number.
	CP	$40		; is it too high ($2F is maximum possible) ?
	POP	BC		; drop the return address and
	RET	NC		; make an early return if so >>>
	PUSH	BC		; save return address
	CALL	OUT_NUM_2	; to print addressed number with leading space.
	INC	HL		; skip low number byte.
	INC	HL		; and the two
	INC	HL		; length bytes.
	RES	0,(IY+$01)	; update FLAGS - signal leading space required.
	LD	A,D		; fetch the cursor.
	AND	A		; test for zero.
	JP	OUT_LINE1A	; extra code to invert cursor.

; this entry point is called from ED_COPY


	ORG	$187D
OUT_LINE2:
	SET	0,(IY+$01)	; update FLAGS - suppress leading space.

	ORG	$1881
OUT_LINE3:
	PUSH	DE		; save flag E for a return value.
	EX	DE,HL		; save HL address in DE.
	RES	2,(IY+$30)	; update FLAGS2 - signal NOT in QUOTES.
	JR	OUT_LINE4	;

;---

	DEFS	11

;---

	ORG	$1894
OUT_LINE4:
	LD	HL,(X_PTR)	; - possibly the error pointer address.
	AND	A		; clear the carry flag.
	SBC	HL,DE		; test if an error address has been reached.
	JR	NZ,OUT_LINE5	; forward if not.
	LD	A,$3F		; load A with '?' the error marker.
	CALL	OUT_FLASH	; to print flashing marker.

	ORG	$18A1
OUT_LINE5:
	CALL	OUT_CURS		; will print the cursor if
				; this is the right position.
	EX	DE,HL		; restore address pointer to HL.
	LD	A,(HL)		; fetch the addressed character.
	CALL	NUMBER		; skips a hidden floating
				; point number if present.
	INC	HL		; now increment the pointer.
	CP	$0D		; is character end-of-line ?
	JR	Z,OUT_LINE6	; jump if so, as line is finished.
	EX	DE,HL		; save the pointer in DE.
	CALL	OUT_CHAR		; to output character/token.
	JR	OUT_LINE4	; back until entire line is done.

; ---

	ORG	$18B4
OUT_LINE6:
	POP	DE		; bring back the flag E, zero if current
				; line printed else 1 if still to print.
	RET			; return with A holding $0D

; -------------------------
; Check for a number marker
; -------------------------
; this subroutine is called from two processes. while outputting BASIC lines
; and while searching statements within a BASIC line.
; during both, this routine will pass over an invisible number indicator
; and the five bytes floating-point number that follows it.
; Note that this causes floating point numbers to be stripped from
; the BASIC line when it is fetched to the edit buffer by OUT_LINE.
; the number marker also appears after the arguments of a DEF FN statement
; and may mask old 5-byte string parameters.

	ORG	$18B6
NUMBER:	CP	$0E		; character fourteen ?
	RET	NZ		; return if not.
	INC	HL		; skip the character
L18BA:	INC	HL		; and five bytes
L18BB:	INC	HL		; following.
L18BC:	INC	HL		;
	INC	HL		;
	INC	HL		;
	LD	A,(HL)		; fetch the following character
	RET			; for return value.

; --------------------------
; Print a flashing character
; --------------------------
; This subroutine is called from OUT_LINE to print a flashing error
; marker '?' or from the next routine to print a flashing cursor e.g. 'L'.
; However, this only gets called from OUT_LINE when printing the edit line
; or the input buffer to the lower screen so a direct call to $09F4 can
; be used, even though out-line outputs to other streams.
; In fact the alternate set is used for the whole routine.

	ORG	$18C1
OUT_FLASH:
	EXX			; switch in alternate set
	LD	HL,(ATTR_T)	; fetch L = ATTR_T, H = MASK-T
	PUSH	HL		; save masks.
	RES	7,H		; reset flash mask bit so active.
	SET	7,L		; make attribute FLASH.
	LD	(ATTR_T),HL	; resave ATTR_T and MASK-T
	LD	HL,P_FLAG		;
	LD	D,(HL)		; fetch to D
	PUSH	DE		; and save.
	LD	(HL),$0C		; set inverse, over, ink/paper 9
				; makes cursor more visible in 512x192 mode.
	CALL	PRINT_OUT	; outputs character
				; without the need to vector via RST 10.
	POP	HL		; pop P_FLAG to H.
	LD	(IY+$57),H	; and restore system variable P_FLAG.
	POP	HL		; restore temporary masks
	LD	(ATTR_T),HL	; and restore system variables ATTR_T/MASK_T
	EXX			; switch back to main set
	RET			; return

; ----------------
; Print the cursor
; ----------------
; This routine is called before any character is output while outputting
; a BASIC line or the input buffer. This includes listing to a printer
; or screen, copying a BASIC line to the edit buffer and printing the
; input buffer or edit buffer to the lower screen. It is only in the
; latter two cases that it has any relevance and in the last case it
; performs another very important function also.

	ORG	$18E1
OUT_CURS:LD	HL,(K_CUR)	; fetch K_CUR the current cursor address
	AND	A		; prepare for true subtraction.
	SBC	HL,DE		; test against pointer address in DE and
	RET	NZ		; return if not at exact position.

OUT_C_1:	LD	A,$4C		; prepare letter 'L'.
	BIT	3,(IY+$30)	; test FLAGS2 - consider caps lock ?
				; which is maintained by KEY_INPUT.
	JR	Z,OUT_C_2	; forward if not set to print.
	LD	A,$43		; alter 'L' to 'C'.

OUT_C_2:	JR	OUT_FLASH	; to print and return.

OUT_LINE1A:
	JR	Z,OUT_LINE3	; if zero.
	LD	D,(IY+$57)	; P_FLAG to D.
	LD	(IY+$57),$0C	; set inverse 1, over 0, ink/paper 8
	RST	10H		; PRINT-A prints '>' the current line cursor.
	LD	(IY+$57),D	; restore P_FLAG.
	JP	OUT_LINE2	; return.

	DEFS	11

; ----------------------------
; Get line number of next line
; ----------------------------
; These two subroutines are called while editing.
; This entry point is from ED_DOWN with HL addressing E_PPC
; to fetch the next line number.
; Also from AUTO-LIST with HL addressing S_TOP just to update S_TOP
; with the value of the next line number. It gets fetched but is discarded.
; These routines never get called while the editor is being used for input.

	ORG	$190F
LN_FETCH:LD	E,(HL)		; fetch low byte
	INC	HL		; address next
	LD	D,(HL)		; fetch high byte.
	PUSH	HL		; save system variable hi pointer.
	EX	DE,HL		; line number to HL,
	INC	HL		; increment as a starting point.
	CALL	LINE_ADDR		; gets address in HL.
	CALL	LINE_NO		; gets line number in DE.
	POP	HL		; restore system variable hi pointer.

; This entry point is from the ED_UP with HL addressing E_PPC_H

	ORG	$191C
LN_STORE:
	LD	(HL),D		; save high byte of line number.
	DEC	HL		; address lower
	LD	(HL),E		; save low byte of line number.
	RET			; return.

; -----------------------------
; THE 'NEW COMMANDS' SUBROUTINE
; -----------------------------
;

NEW_CMND:
        CP      $38             ; Greater than $37 ?
        RET     C
        RST     08H             ; ERROR-1
        DEFB    $0B             ; Error Report: Nonsense in BASIC

; -----------------------------------------
; Outputting numbers at start of BASIC line
; -----------------------------------------
; This routine entered at OUT-SP-NO is used to compute then output the first
; three digits of a 4-digit BASIC line printing a space if necessary.
; The line number, or residual part, is held in HL and the BC register
; holds a subtraction value -1000, -100 or -10.
; Note. for example line number 200 -
; space(out_char), 2(out_code), 0(out_char) final number always out-code.

	ORG	$1925
OUT_SP_2:LD	A,E		; will be space if OUT_CODE not yet called.
				; or $FF if spaces are suppressed.
				; else $30 ('0').
				; (from the first instruction at OUT_CODE)
	AND	A		; test bit 7 of A.
	RET	M		; return if $FF, as leading spaces not
				; required. This is set when printing line
				; number and statement in MAIN_5.
	RST	10H		; output character/token.
	RET			; return.

; ---

; -> the single entry point.

	ORG	$192A
OUT_SP_NO:
	XOR	A		; initialize digit to 0

	ORG	$192B
OUT_SP_1:	ADD	HL,BC		; add negative number to HL.
	INC	A		; increment digit
	JR	C,OUT_SP_1	; back until no carry from the addition.
	SBC	HL,BC		; cancel the last addition
	DEC	A		; and decrement the digit.
	JR	Z,OUT_SP_2	; back if it is zero.
	JP	OUT_CODE		; jump back to exit via OUT_CODE.	->

; -------------------------------------
; Outputting characters in a BASIC line
; -------------------------------------
; This subroutine is used for all characters, tokens and control characters.

	ORG	$1937
OUT_CHAR:CP	$22		; is it quote character '"' ?
	JR	NZ,OUT_CH_1	;
	PUSH	AF		; save character.
	LD	A,(FLAGS2)	; fetch
	XOR	$04		; toggle the quotes flag.
	LD	(FLAGS2),A	; update FLAGS2
	POP	AF		; and restore character.

OUT_CH_1:RST	10H		; PRINT_A vectors the character to
				; channel 'S', 'K', 'R' or 'P'.
	RET			; return.

;---

	DEFS	12

; ----------------------
; THE 'READ DIGIT' PATCH
; ----------------------
;   17 bytes. Needed because line numbers are now five digits.

E_LINE_NO_A:
	CALL	NUMERIC		; Read the digits of the line number.
	PUSH	AF		;
	CALL	INT_TO_FP	;
	POP	AF		;
	RET	NC		;
	POP	BC		;
	CALL	FP_TO_BC		;
	SCF			;
	JP	SET_STK		;

; ---------------------
; THE 'OUT-NUM-3' PATCH
; ---------------------
;   10 bytes. Handles lines over 1000.

OUT_NUM_3A:
	LD	BC,$D8F0		; value -10000
	CALL	OUT_SP_NO	; routine OUT-SP-NO
	LD	BC,$FC18		; value -1000
	RET			;

; -------------------------------------------
; Get starting address of line, or line after
; -------------------------------------------
; This routine is used often to get the address, in HL, of a BASIC line
; number supplied in HL, or failing that the address of the following line
; and the address of the previous line in DE.

	ORG	$196E
LINE_ADDR:
	PUSH	HL		; save line number in HL register
	LD	HL,(PROG)	; fetch start of program
	LD	D,H		; transfer address to
	LD	E,L		; the DE register pair.

	ORG	$1974
LINE_AD_1:
	POP	BC		; restore the line number to BC
	CALL	CP_LINES		; compares with that addressed by HL
	RET	NC		; return if line has been passed or matched.
				; if NZ, address of previous is in DE
	PUSH	BC		; save the current line number
	CALL	NEXT_ONE		; finds address of next
				; line number in DE, previous in HL.
	EX	DE,HL		; switch so next in HL
	JR	LINE_AD_1		; back for another comparison

; --------------------
; Compare line numbers
; --------------------
; This routine compares a line number supplied in BC with an addressed
; line number pointed to by HL.

	ORG	$1980
CP_LINES:	LD	A,(HL)		; Load the high byte of line number and
	CP	B		; compare with that of supplied line number.
	RET	NZ		; return if yet to match (carry will be set).
	INC	HL		; address low byte of
	LD	A,(HL)		; number and pick up in A.
	DEC	HL		; step back to first position.
	CP	C		; now compare.
	RET			; zero set if exact match.
				; carry set if yet to match.
				; no carry indicates a match or
				; next available BASIC line or
				; program end marker.

; -------------------
; Find each statement
; -------------------
; The single entry point EACH-STMT is used to
; 1) To find the D'th statement in a line.
; 2) To find a token in held E.

	ORG	$1988		; not-used
THREE_SPARE_BYTES:
	INC	HL		;
	INC	HL		;
	INC	HL		;

; -> entry point.

	ORG	$198B
EACH_STMT:
	LD	(CH_ADD),HL	; save HL in CH_ADD
	LD	C,$00		; initialize quotes flag

	ORG	$1990
EACH_S_1:	DEC	D		; decrease statement count
	RET	Z		; return if zero
	RST	20H		; NEXT_CHAR
	CP	E		; is it the search token ?
	JR	NZ,EACH_S_3	; back if not
	AND	A		; clear carry
	RET			; return signalling success.

; ---

	ORG	$1998
EACH_S_2:	INC	HL		; next address
	LD	A,(HL)		; next character

	ORG	$199A
EACH_S_3:	CALL	NUMBER		; skips if number marker
	LD	(CH_ADD),HL	; save in CH_ADD
	CP	$22		; is it quotes '"' ?
	JR	NZ,EACH_S_4	; jump if not
	DEC	C		; toggle bit 0 of C

	ORG	$19A5
EACH_S_4:	CP	$3A		; is it ':'
	JR	Z,EACH_S_5	;
	CP	$CB		; 'THEN'
	JR	NZ,EACH_S_6	;

	ORG	$19AD
EACH_S_5:	BIT	0,C		; is it in quotes
	JR	Z,EACH_S_1	; jump if not

	ORG	$19B1
EACH_S_6:	CP	$0D		; end of line ?
	JR	NZ,EACH_S_2	;
	DEC	D		; decrease the statement counter
				; which should be zero else
				; 'Statement Lost'.
	SCF			; set carry flag - not found
	RET			; return

; -----------------------------------------------------------------------
; Storage of variables. For full details - see chapter 24.
; ZX Spectrum BASIC Programming by Steven Vickers 1982.
; It is bits 7-5 of the first character of a variable that allow
; the six types to be distinguished. Bits 4-0 are the reduced letter.
; So any variable name is higher that $3F and can be distinguished
; also from the variables area end-marker $80.
;
; 76543210  meaning			brief outline of format.
; --------  -----------------------------	-----------------------
; 010       string variable.		2 byte length + contents.
; 110       string array.			2 byte length + contents.
; 100       array of numbers.		2 byte length + contents.
; 011       simple numeric variable.		5 bytes.
; 101       variable length named numeric.	5 bytes.
; 111       for-next loop variable.		18 bytes.
; 10000000  the variables area end-marker.
;
; Note. any of the above seven will serve as a program end-marker.
;
; -----------------------------------------------------------------------

; ------------
; Get next one
; ------------
; This versatile routine is used to find the address of the next line
; in the program area or the next variable in the variables area.
; The reason one routine is made to handle two apparently unrelated tasks
; is that it can be called indiscriminately when merging a line or a
; variable.

	ORG	$19B8
NEXT_ONE:	PUSH	HL		; save the pointer address.
	LD	A,(HL)		; get first byte.
	CP	$40		; compare with upper limit for line numbers.
	JR	C,NEXT_O_3	; forward if within BASIC area.

; the continuation here is for the next variable unless the supplied
; line number was erroneously over 16383. see RESTORE command.

	BIT	5,A		; is it a string or an array variable ?
	JR	Z,NEXT_O_4	; forward to compute length.
	ADD	A,A		; test bit 6 for single-character variables.
	JP	M,NEXT_O_1	; forward if so
	CCF			; clear the carry for long-named variables.
				; it remains set for for-next loop variables.

	ORG	$19C7
NEXT_O_1:	LD	BC,$0005		; set BC to 5 for floating point number
	JR	NC,NEXT_O_2	; forward if not a for/next variable.
	LD	C,$12		; set BC to eighteen locations.
				; value, limit, step, line and statement.

; now deal with long-named variables

	ORG	$19CE
NEXT_O_2:	RLA			; test if character inverted. carry will also
				; be set for single character variables
	INC	HL		; address next location.
	LD	A,(HL)		; and load character.
	JR	NC,NEXT_O_2	; back if not inverted bit.
				; forward immediately with single character
				; variable names.
	JR	NEXT_O_5		; forward to add length of
				; floating point number(s etc.).

; ---

; this branch is for line numbers.

	ORG	$19D5
NEXT_O_3:	INC	HL		; increment pointer to low byte of line no.

; strings and arrays rejoin here

	ORG	$19D6
NEXT_O_4:	INC	HL		; increment to address the length low byte.
	LD	C,(HL)		; transfer to C and
	INC	HL		; point to high byte of length.
	LD	B,(HL)		; transfer that to B
	INC	HL		; point to start of BASIC/variable contents.

; the three types of numeric variables rejoin here

	ORG	$19DB
NEXT_O_5:	ADD	HL,BC		; add the length to give address of next
				; line/variable in HL.
	POP	DE		; restore previous address to DE.

; ------------------
; Difference routine
; ------------------
; This routine terminates the above routine and is also called from the
; start of the next routine to calculate the length to reclaim.

	ORG	$19DD
DIFFER:	AND	A		; prepare for true subtraction.
	SBC	HL,DE		; subtract the two pointers.
	LD	B,H		; transfer result
	LD	C,L		; to BC register pair.
	ADD	HL,DE		; add back
	EX	DE,HL		; and switch pointers
	RET			; return values are the length of area in BC,
				; low pointer (previous) in HL,
				; high pointer (next) in DE.

; -----------------------
; Handle reclaiming space
; -----------------------
; The entry point RECLAIM_1 is used when the address of the first location to be
; reclaimed is in the DE register pair and the address of the first location to be
; left alone is in the HL register pair.  The entry point RECLAIM_2 is used when
; the HL register pair points to the first location to be reclaimed and the BC
; register pair holds the number of the bytes that are to be reclaimed.

	ORG	$19E5
RECLAIM_1:
	CALL	DIFFER		; Use the 'difference' subroutine to
				; develop the appropriate values.

	ORG	$19E8
RECLAIM_2:
	PUSH	BC		; Save the number of bytes to be reclaimed.
	LD	A,B		; All the system variable
	CPL			; pointers above the area
	LD	B,A		; have to be reduced by 'BC'
	LD	A,C		; so this number is 2's
	CPL			; complemented before the
	LD	C,A		; pointers are altered.
	INC	BC		;
	CALL	POINTERS		;
	EX	DE,HL		; Return the 'first location'
	POP	HL		; address to the DE register
	ADD	HL,DE		; pair and reform the address of
				; the first location to the left.
	PUSH	DE		; Save the 'first location'
	LDIR			; whilst the actual reclamation
	POP	HL		; occurs.
	RET			; Now return.

; ----------------------------------------
; Read line number of line in editing area
; ----------------------------------------
; This routine reads a line number in the editing area returning the number
; in the BC register or zero if no digits exist before commands.
; It is called from LINE_SCAN to check the syntax of the digits.
; It is called from MAIN_3 to extract the line number in preparation for
; inclusion of the line in the BASIC program area.
;
; Interestingly the calculator stack is moved from its normal place at the
; end of dynamic memory to an adequate area within the system variables area.
; This ensures that in a low memory situation, that valid line numbers can
; be extracted without raising an error and that memory can be reclaimed
; by deleting lines. If the stack was in its normal place then a situation
; arises whereby the Spectrum becomes locked with no means of reclaiming space.

	ORG	$19FB
E_LINE_NO:
	LD	HL,(E_LINE)	; load HL from system variable E_LINE.
	DEC	HL		; decrease so that NEXT_CHAR can be used
				; without skipping the first digit.
	LD	(CH_ADD),HL	; store in the system variable CH_ADD.
	RST	20H		; NEXT_CHAR skips any noise and white-space
				; to point exactly at the first digit.
	LD	HL,MEM_0		; use MEM-0 as a temporary calculator stack
				; an overhead of three locations are needed.
	LD	(STKEND),HL	; set new STKEND.
;;;	CALL	INT_TO_FP	; will read digits until a non-digit found.
	CALL	E_LINE_NO_A	; patch to allow line numbers up to 16383
	CALL	FP_TO_BC		; will retrieve number from stack at membot.
	JR	C,E_L_1		; forward if overflow i.e. > 65535.
				; 'Syntax error'
;;;	LD	HL,$D8F0		; load HL with value -9999
	LD	HL,$C000		; load HL with value -16383
	ADD	HL,BC		; add to line number in BC

	ORG	$1A15
E_L_1:	JP	C,REPORT_C	; 'Syntax error' if over.
				; Note. As ERR_SP points to ED_ERROR
				; the report is never produced although
				; the RST $08 will update X_PTR leading to
				; the error marker being displayed when
				; the ED_LOOP is reiterated.
				; in fact, since it is immediately
				; cancelled, any report will do.

; a line in the range 0 - 16383 has been entered.

	JP	SET_STK		; jump back to set the calculator
				; stack back to its normal place and exit
				; from there.

; ---------------------------------
; Report and line number outputting
; ---------------------------------
; Entry point OUT_NUM_1 is used by the Error Reporting code to print
; the line number and later the statement number held in BC.
; If the statement was part of a direct command then -2 is used as a
; dummy line number so that zero will be printed in the report.
; This routine is also used to print the exponent of E-format numbers.
;
; Entry point OUT_NUM_2 is used from OUT_LINE to output the line number
; addressed by HL with leading spaces if necessary.

	ORG	$1A1B
OUT_NUM_1:
	PUSH	DE		; save the
	PUSH	HL		; registers.
	XOR	A		; set A to zero.
	BIT	7,B		; is the line number minus two ?
	JR	NZ,OUT_NUM_4	; forward if so to print zero
				; for a direct command.
	LD	H,B		; transfer the
	LD	L,C		; number to HL.
	LD	E,$FF		; signal 'no leading zeros'.
	JR	OUT_NUM_3		; forward to continue

; ---

; from OUT_LINE - HL addresses line number.

	ORG	$1A28
OUT_NUM_2:
	PUSH	DE		; save flags
	LD	D,(HL)		; high byte to D
	INC	HL		; address next
	LD	E,(HL)		; low byte to E
	PUSH	HL		; save pointer
	EX	DE,HL		; transfer number to HL
	LD	E,$20		; signal 'output leading spaces'

	ORG	$1A30
OUT_NUM_3:
;;;	LD	BC,$FC18		; value -1000
	CALL	OUT_NUM_3A	; patch for lines up to 16383.
	CALL	OUT_SP_NO	; outputs space or number
	LD	BC,$FF9C		; value -100
	CALL	OUT_SP_NO	; routine OUT-SP-NO
	LD	C,$F6		; value -10 ( B is still $FF )
	CALL	OUT_SP_NO	; routine OUT-SP-NO
	LD	A,L		; remainder to A.

	ORG	$1A42
OUT_NUM_4:
	CALL	OUT_CODE		; routine OUT-CODE for final digit.
				; else report code zero wouldn't get
				; printed.
	POP	HL		; restore the
	POP	DE		; registers and
	RET			; return.

	DEFS	148

; ----------------------
; THE 'OPEN_ALL' ROUTINE
; ----------------------
;+  Generic Channel Opening Routine.
;+  DE still points to string (53 bytes?)

OPEN_ALL:
	LD	IX,PCHAN_DAT	; point to the channel data
	LD	HL,(PROG)	; Set pointer from PROG
	LD	C,(IX+$05)	; length lo.
	LD	B,(IX+$06)	; length hi.

	DEC	HL		; decrementing HL first
	CALL	MAKE_ROOM	;
	INC	HL		; and then restoring HL

;   HL points to the 1st location, DE to last new location, BC is zero

	PUSH	HL		; (*) Save channel pointer.
	EX	DE,HL		; Transfer HL to DE.
	PUSH	IX		; Transfer ROM data pointer
	POP	HL		; to HL.
	LD	C,(IX-$01)	; Find number of bytes in ROM
	LDIR			; Block copy the channel data.

;   Note. a call to clear the ZX Printer buffer is required here.
;   but can be done directly.

	LD	A,(IX+$04)	;

	LD	H,D		;
	LD	L,E		;
	INC	DE		;
	LD	(HL),B		; Blank first location
	DEC	C		; set count to 255 decimal or whatever.
	LDIR			;

;   now calculate offset from CHANS

OFFSET:	LD	HL,(CHANS)	; Address CHANS
	POP	DE		; (*) Restore the channel pointer
	EX	DE,HL		;
	INC	HL		; the second byte is used.
	AND	A		; prepare to subtract
	SBC	HL,DE		; result is in HL
	EX	DE,HL		; transfer offset to DE
	POP	HL		;
	RET			;

; ----------------------
; THE '"P" CHANNEL DATA'
; ----------------------
; The eight bytes "P" channel descriptor. (9 bytes)

	DEFB	$08		;+ length of channel data

PCHAN_DAT:
	DEFW	PRINT_OUT	;+ PRINT-OUT
	DEFW	REPORT_J		;+ REPORT-J
	DEFB	'P'		;+ Letter as in standard ROM
	DEFW	$0108		;+ Length of channel including printer buffer.
	DEFB	$21		;+ P_POSN (IX+$07)

;***************************************************
;** Part 7. BASIC LINE AND COMMAND INTERPRETATION **
;***************************************************

; -------------------------------
; Main parser (BASIC interpreter)
; -------------------------------
; This routine is called once from MAIN-2 when the BASIC line is to
; be entered or re-entered into the Program area and the syntax
; requires checking.

	ORG	$1B17
LINE_SCAN:
	RES	7,(IY+$01)	; update FLAGS - signal checking syntax
	CALL	E_LINE_NO		; fetches the line number if in range.
	XOR	A		; clear the accumulator.
	LD	(SUBPPC),A	; set statement number to zero.
	DEC	A		; set accumulator to $FF.
	LD	(ERR_NR),A	; set to 'OK' - 1.
	JR	STMT_L_1		; forward to continue

; --------------
; Statement loop
; --------------
; Each statement is considered in turn until the end of the line is reached.

	ORG	$1B28
STMT_LOOP:
	RST	20H		; NEXT_CHAR

; -> the entry point from above or LINE-RUN


	ORG	$1B29
STMT_L_1:CALL	SET_WORK		; clears workspace etc.
	INC	(IY+$0D)		; increment statement number SUBPPC
	JP	M,REPORT_C	; to raise 'Syntax error' if over 127.
	RST	18H		; GET_CHAR
	LD	B,$00		; set B to zero for later indexing.
				; early so any other reason ???
	CP	$0D		; is character carriage return ?
				; i.e. an empty statement.
	JR	Z,LINE_END	; forward if so.
	CP	$3A		; is it statement end marker ':' ?
				; i.e. another type of empty statement.
	JR	Z,STMT_LOOP	; back if so.
	LD	HL,STMT_RET	;
	PUSH	HL		; is now pushed as a return address
	LD	C,A		; transfer the current character to C.

; advance CH_ADD to a position after command and test if it is a command.

	RST	20H		; NEXT_CHAR to advance pointer
	LD	A,C		; restore current character
	SUB	$CE		; subtract 'DEF FN' - first command
	CALL	C,NEW_CMND	; check if it's a new commmand.
	LD	C,A		; put the valid command code back in C.
				; register B is zero.
	LD	HL,OFFST_TBL	;
	ADD	HL,BC		; index into table with one of 50 commands.
	LD	C,(HL)		; pick up displacement to syntax table entry.
	ADD	HL,BC		; add to address the relevant entry.
	JR	GET_PARAM		; forward to continue

; ----------------------
; The main scanning loop
; ----------------------
; Each of the command class routines applicable to the present command are
; executed in turn. Any required separators are also considered.

	ORG	$1B52
SCAN_LOOP:
	LD	HL,(T_ADDR)	; The temporary pointer to the
				; entries in the parameter table.

; -> the initial entry point with HL addressing start of syntax table entry.

	ORG	$1B55
GET_PARAM:
	LD	A,(HL)		; pick up the parameter.
	INC	HL		; address next one.
	LD	(T_ADDR),HL	; save pointer in system variable.
	LD	BC,SCAN_LOOP	; return address
	PUSH	BC		; is now pushed on stack as looping address.
	LD	C,A		; store parameter in C.
	CP	$20		; is it greater than ' '  ?
	JR	NC,SEPARATOR	; forwatd to check that correct
				; separator appears in statement if so.
	LD	HL,CLASS_TBL	; address: class-tbl.
	LD	B,$00		; prepare to index into the class table.
	ADD	HL,BC		; index to find displacement to routine.
	LD	C,(HL)		; displacement to BC
	ADD	HL,BC		; add to address the CLASS routine.
	PUSH	HL		; push the address on the stack.
	RST	18H		; GET_CHAR - HL points to place in statement.
	DEC	B		; reset the zero flag - the initial state
				; for all class routines.
	RET			; and make an indirect jump to routine
				; and then SCAN-LOOP (also on stack).

; Note. one of the class routines will eventually drop the return address
; off the stack breaking out of the above seemingly endless loop.

; -----------------------
; THE 'SEPARATOR' ROUTINE
; -----------------------
; This routine is called once to verify that the mandatory separator
; present in the parameter table is also present in the correct
; location following the command.  For example, the 'THEN' token after
; the 'IF' token and expression.

	ORG	$1B6F
SEPARATOR:
	RST	18H		; GET_CHAR
	CP	C		; does it match the character in C ?
	JP	NZ,REPORT_C	; jump forward if not: 'Syntax error'.
	RST	20H		; NEXT_CHAR advance to next character
	RET			; return.

; ------------------------------
; Come here after interpretation
; ------------------------------
; After the correct interpretation of a statement a return is made to this
; entry point.

	ORG	$1B76
STMT_RET:	CALL	BREAK_KEY			; is tested after every statement.
	JR	C,STMT_R_1	 ; step forward if not pressed.

	ORG	$1B7B
REPORT_L:	RST	08H		; ERROR_1
	DEFB	$14		; Error Report: BREAK

	ORG	$1B7D
STMT_R_1:	BIT	7,(IY+$0A)	; test NSPPC - will be set if $FF -
				; no jump to be made.
	JR	NZ,STMT_NEXT	; forward if a program line.
	LD	HL,(NEWPPC)	; fetch line number
	BIT	7,H		; will be set if minus two - direct command(s)
	JR	Z,LINE_NEW	; forward if a jump is to be
				; made to a new program line/statement.

; --------------------
; Run a direct command
; --------------------
; A direct command is to be run or, if continuing from above,
; the next statement of a direct command is to be considered.

	ORG	$1B8A
LINE_RUN:	LD	HL,$FFFE		; The dummy value minus two
	LD	(PPC),HL		; is set/reset as line number in PPC.
	LD	HL,(WORKSP)	; point to end of line + 1
	DEC	HL		; now point to $80 end-marker.
	LD	DE,(E_LINE)	; address the start of line
	DEC	DE		; now location before - for GET_CHAR.
	LD	A,(NSPPC)		; load statement to A
	JR	NEXT_LINE		; forward

; ------------------------------
; Find start address of new line
; ------------------------------
; The branch was to here if a jump is to made to a new line number
; and statement.
; That is the previous statement was a GO TO, GO SUB, RUN, RETURN, NEXT etc..

	ORG	$1B9E
LINE_NEW:CALL	LINE_ADDR	; gets address of line
				; returning zero flag set if line found.
	LD	A,(NSPPC)		; fetch new statement
	JR	Z,LINE_USE	; forward if line matched.

; continue as must be a direct command.

	AND	A		; test statement which should be zero
	JR	NZ,REPORT_N	; forward if not: 'Statement lost'

;

	LD	B,A		; save statement in B.??
	LD	A,(HL)		; fetch high byte of line number.
	AND	$C0		; test if using direct command
				; a program line is less than $3F
	LD	A,B		; retrieve statement.
				; (we can assume it is zero).
	JR	Z,LINE_USE	; forward if was a program line

; Alternatively a direct statement has finished correctly.

	ORG	$1BB0
REPORT_0:	RST	08H		; ERROR_1
	DEFB	$FF		; Error Report: OK

; -----------------
; THE 'REM' COMMAND
; -----------------
; The REM command routine.
; The return address STMT-RET is dropped and the rest of line ignored.

	ORG	$1BB2
REM:	POP	BC		; drop return address STMT_RET and
				; continue ignoring rest of line.

; ------------
; End of line?
; ------------
; If checking syntax a simple return is made but when 'running' the address
; held by NXTLIN has to be checked before it can be used.

	ORG	$1BB3
LINE_END:	CALL	SYNTAX_Z		; (UNSTACK_Z?)
	RET	Z		; return if checking syntax.
	LD	HL,(NXTLIN)	; fetch
	LD	A,$C0		; test against the
	AND	(HL)		; system limit $3F.
	RET	NZ		; return if higher as must be
				; end of program.
				; (or direct command)
	XOR	A		; set statement to zero.

; and continue to set up the next following line and then consider this new one.

; ---------------------
; General line checking
; ---------------------
; The branch was here from LINE-NEW if BASIC is branching.
; or a continuation from above if dealing with a new sequential line.
; First make statement zero number one leaving others unaffected.


	ORG	$1BBF
LINE_USE:	CP	$01		; will set carry if zero.
	ADC	A,$00		; add in any carry.
	LD	D,(HL)		; high byte of line number to D.
	INC	HL		; advance pointer.
	LD	E,(HL)		; low byte of line number to E.
	LD	(PPC),DE		; set system variable PPC.
	INC	HL		; advance pointer.
	LD	E,(HL)		; low byte of line length to E.
	INC	HL		; advance pointer.
	LD	D,(HL)		; high byte of line length to D.
	EX	DE,HL		; swap pointer to DE before
	ADD	HL,DE		; adding to address the end of line.
	INC	HL		; advance to start of next line.

; -----------------------------
; Update NEXT LINE but consider
; previous line or edit line.
; -----------------------------
; The pointer will be the next line if continuing from above or to
; edit line end-marker ($80) if from LINE-RUN.

	ORG	$1BD1
NEXT_LINE:
	LD	(NXTLIN),HL	; store pointer in system variable NXTLIN
	EX	DE,HL		; bring back pointer to previous or edit line
	LD	(CH_ADD),HL	; and update CH_ADD with character address.
	LD	D,A		; store statement in D.
	LD	E,$00		; set E to zero to suppress token searching
				; if EACH_STMT is to be called.
	LD	(IY+$0A),$FF	; set statement NSPPC to $FF signalling
				; no jump to be made.
	DEC	D		; decrement and test statement
	LD	(IY+$0D),D	; set SUBPPC to decremented statement number.
	JP	Z,STMT_LOOP	; jump if result zero as statement is
				; at start of line and address is known.
	INC	D		; else restore statement.
	CALL	EACH_STMT		; finds the D'th statement
				; address as E does not contain a token.
	JR	Z,STMT_NEXT	; forward if address found.

	ORG	$1BEC
REPORT_N:	RST	08H			; ERROR_1
	DEFB	$16		; Error Report: Statement lost

; -----------------
; End of statement?
; -----------------
; This combination of routines is called from 20 places when
; the end of a statement should have been reached and all preceding
; syntax is in order.

	ORG	$1BEE
CHECK_END:
	CALL	SYNTAX_Z		;
	RET	NZ		; return immediately in runtime
	POP	BC		; drop address of calling routine.
	POP	BC		; drop address STMT_RET.
				; and continue to find next statement.

; --------------------
; Go to next statement
; --------------------
; Acceptable characters at this point are carriage return and ':'.
; If so go to next statement which in the first case will be on next line.

	ORG	$1BF4
STMT_NEXT:
	RST	18H		; GET_CHAR - ignoring white space etc.
	CP	$0D		; is it carriage return ?
	JR	Z,LINE_END	; back if so.
	CP	$3A		; is it ':' ?
	JP	Z,STMT_LOOP	; jump back to consider
				; further statements
	JP	REPORT_C		; jump with any other character
				; 'Syntax error'.

; Note. the two-byte sequence 'rst 08; defb $0b' could replace the above jp.

; -------------------
; Command class table
; -------------------
;

	ORG	$1C01
CLASS_TBL:
	DEFB	CLASS_00 - $	; $0F offset
	DEFB	CLASS_01 - $	; $1D offset
	DEFB	CLASS_02 - $	; $4B offset
	DEFB	CLASS_03 - $	; $09 offset
	DEFB	CLASS_04 - $	; $67 offset
	DEFB	CLASS_05 - $	; $0B offset
	DEFB	EXPT_1NUM - $	; $7B offset to CLASS_06
	DEFB	CLASS_07 - $	; $8E offset
	DEFB	EXPT_2NUM - $	; $71 offset to CLASS_08
	DEFB	CLASS_09 - $	; $B4 offset
	DEFB	EXPT_EXP - $	; $81 offset to CLASS_0A
	DEFB	CLASS_0B - $	; $CF offset

; --------------------------------
; Command classes---00, 03, and 05
; --------------------------------
; class-03 e.g. RUN or RUN 200 ;  optional operand
; class-00 e.g. CONTINUE ;  no operand
; class-05 e.g. PRINT  ;  variable syntax checked by routine

	ORG	$1C0D
CLASS_03:	CALL	FETCH_NUM		;

	ORG	$1C10
CLASS_00:	CP	A		; reset zero flag.

; if entering here then all class routines are entered with zero reset.

	ORG	$1C11
CLASS_05:	POP	BC		; drop address SCAN-LOOP.
	CALL	Z,CHECK_END	; if zero set then call	>>>
				; as should be no further characters.
	EX	DE,HL		; save HL to DE.
	LD	HL,(T_ADDR)	; fetch
	LD	C,(HL)		; fetch low byte of routine
	INC	HL		; address next.
	LD	B,(HL)		; fetch high byte of routine.
	EX	DE,HL		; restore HL from DE

; Note the next location is called by the Opus Discovery Disk Interface.

x1C1D:	PUSH	BC		; push the address
	RET			; and make an indirect jump to the command.

; --------------------------------
; Command classes---01, 02, and 04
; --------------------------------
; class-01  e.g. LET A = 2*3 ; a variable is reqd

; This class routine is also called from INPUT and READ to find the
; destination variable for an assignment.

	ORG	$1C1F
CLASS_01:	CALL	LOOK_VARS		; returns carry set if not; found in runtime.

; ----------------------
; Variable in assignment
; ----------------------
; This subroutine develops the appropriate values for the system variables
; DEST & STRLEN.

	ORG	$1C22
VAR_A_1:	LD	(IY+$37),$00	; set FLAGX to zero
	JR	NC,VAR_A_2	; forward if found or checking syntax.
	SET	1,(IY+$37)	; FLAGX  - Signal a new variable
	JR	NZ,VAR_A_3	; jump if not assigning to an array
				; e.g. LET a$(3,3) = "X"

	ORG	$1C2E
REPORT_2:	RST	08H		; ERROR_1
	DEFB	$01		; Error Report: Undefined variable

	ORG	$1C30
VAR_A_2:	CALL	Z,STK_VAR		; considers a subscript/slice
	BIT	6,(IY+$01)	; test FLAGS  - Numeric or string result ?
	JR	NZ,VAR_A_3	; jump if numeric
	XOR	A		; default to array/slice - to be retained.
	CALL	SYNTAX_Z		;
	CALL	NZ,STK_FETCH	; is called in runtime
				; may overwrite A with 1.
	LD	HL,FLAGX		; address system variable
	OR	(HL)		; set bit 0 if simple variable to be reclaimed
	LD	(HL),A		; update FLAGX
	EX	DE,HL		; start of string/subscript to DE

	ORG	$1C46
VAR_A_3:	LD	(STRLEN),BC	; update
	LD	(DEST),HL		; and DEST of assigned string.
	RET			; return.

; -------------------------------------------------
; class-02 e.g. LET a = 1 + 1 ; an expression must follow

	ORG	$1C4E
CLASS_02:	POP	BC		; drop return address SCAN-LOOP
	CALL	VAL_FET_1		; is called to check
				; expression and assign result in runtime
	CALL	CHECK_END		; checks nothing else is present in statement.
	RET			; Return

; -------------
; Fetch a value
; -------------
; This subroutine is used by LET, READ & INPUT statements to first evaluate
; and then assign values to the previously designated variable.
; The entry point VAL_FET_1 is used by LET & READ and considers FLAGS whereas
; the entry point VAL_FET_2 is used by INPUT and considers FLAGX.

	ORG	$1C56
VAL_FET_1:
	LD	A,(FLAGS)		; initial FLAGS to A


	ORG	$1C59
VAL_FET_2:
	PUSH	AF		; save A briefly
	CALL	SCANNING		; evaluates expression.
	POP	AF		; restore A
	LD	D,(IY+$01)	; post-SCANNING FLAGS to D
	XOR	D		; xor the two sets of flags
	AND	$40		; pick up bit 6 of xored FLAGS should be zero
	JR	NZ,REPORT_C	; forward if not zero
				; 'Syntax error' - results don't agree.
	BIT	7,D		; test FLAGS - is syntax being checked ?
	JP	NZ,LET		; jump forward to LET to make the assignment
				; in runtime.
	RET			; but return from here if checking syntax.

; ------------------
; Command class---04
; ------------------
; class-04 e.g. FOR i  ; a single character variable must follow

	ORG	$1C6C
CLASS_04:	CALL	LOOK_VARS		;
	PUSH	AF		; preserve flags.
	LD	A,C		; fetch type - should be 011xxxxx
	OR	$9F		; combine with 10011111.
	INC	A		; test if now $FF by incrementing.
	JR	NZ,REPORT_C	; forward if result not zero.
	POP	AF		; else restore flags.
	JR	VAR_A_1		; back

; --------------------------------
; Expect numeric/string expression
; --------------------------------
; This routine is used to get the two coordinates of STRING$, ATTR and POINT.
; It is also called from PRINT-ITEM to get the two numeric expressions that
; follow the AT ( in PRINT AT, INPUT AT).

	ORG	$1C79
NEXT_2NUM:
	RST	20H		; NEXT_CHAR advance past 'AT' or '('.

; --------
; class-08 e.g. POKE 65535,2 ; two numeric expressions separated by comma

	ORG	$1C7A
EXPT_2NUM:
	CALL	EXPT_1NUM		; is called for first numeric expression
	CP	$2C		; is character ',' ?
	JR	NZ,REPORT_C	; jump if not required separator.
				; 'Syntax error'.
	RST	20H		; NEXT_CHAR

; ->
;  class-06  e.g. GOTO a*1000 ; a numeric expression must follow

	ORG	$1C82
EXPT_1NUM:
	CALL	SCANNING		;
	BIT	6,(IY+$01)	; test FLAGS  - Numeric or string result ?
	RET	NZ		; return if result is numeric.


	ORG	$1C8A
REPORT_C:	RST	08H		; ERROR_1
	DEFB	$0B		; Error Report: Syntax error

; ---------------------------------------------------------------
; class-0A e.g. ERASE "????"  ; a string expression must follow.
;   ; these only occur in unimplemented commands
;   ; although the routine expt-exp is called
;   ; from SAVE-ETC

	ORG	$1C8C
EXPT_EXP:	CALL	SCANNING		;
	BIT	6,(IY+$01)	; test FLAGS  - Numeric or string result ?
	RET	Z		; return if string result.
	JR	REPORT_C		; jump if numeric.

; ---------------------
; Set permanent colours
; class 07
; ---------------------
; class-07 e.g. PAPER 6 ; a single class for a collection of
;   ; similar commands. Clever.
;
; Note. these commands should ensure that current channel is 'S'

	ORG	$1C96
CLASS_07:	BIT	7,(IY+$01)	; test FLAGS - checking syntax only ?
				; Note. there is a subroutine to do this.

;;;	RES	0,(IY+$02)	; update TV_FLAG - signal main screen in use
;;;	CALL	NZ,TEMPS		; routine TEMPS is called in runtime.

	NOP			;+
	LD	A,$FE		;+ system screen
	CALL	NZ,CHAN_OPEN	;+ also does above instructions
	NOP			;+

	POP	AF		; drop return address SCAN-LOOP
	LD	A,(T_ADDR)	; T_ADDR_L to accumulator.
				; points to '$07' entry + 1
				; e.g. for INK points to $EC now

; Note if you move/alter the syntax table next line may have to be altered.

	ORG	$1CA5
	ADD	A,$2E		; convert $AA to $D8 ('INK') etc.
	CALL	CO_TEMP_4	;
	CALL	CHECK_END	; check that nothing else in statement.

; return here in runtime.

	LD	HL,(ATTR_T)	; pick up ATTR_T and MASK_T
	LD	(ATTR_P),HL	; and store in ATTR_P and MASK_P
	LD	HL,P_FLAG	; point to P_FLAG.
	LD	A,(HL)		; pick up in A
	RLCA			; rotate to left
	XOR	(HL)		; combine with HL
	AND	$AA		; 10101010
	XOR	(HL)		; only permanent bits affected
	LD	(HL),A		; reload into P_FLAG.
	RET			; return.

; ------------------
; Command class---09
; ------------------
; e.g. PLOT PAPER 0; 128,88 ; two coordinates preceded by optional
;   ; embedded colour items.
;
; Note. this command should ensure that current channel is actually 'S'.


	ORG	$1CBE
CLASS_09:	CALL	SYNTAX_Z		;
	JR	Z,CL_09_1		; forward if checking syntax.

;;;	RES	0,(IY+$02)	; update TV_FLAG - signal main screen in use
;;;	CALL	TEMPS		; routine TEMPS is called.

	NOP			;+
	LD	A,$FE		;+ system screen
	CALL	CHAN_OPEN		;+ also does above instructions
	NOP			;+

	LD	HL,MASK_T		; point to MASK_T
	LD	A,(HL)		; fetch mask to accumulator.
	OR	$F8		; or with 11111000 paper/bright/flash 8
	LD	(HL),A		; mask back to MASK_T system variable.
	RES	6,(IY+$57)	; reset P_FLAG  - signal NOT PAPER 9 ?
	RST	18H		; GET_CHAR


	ORG	$1CD6
CL_09_1:	CALL	CO_TEMP_2		; deals with any embedded colour items.
	JR	EXPT_2NUM		; exit via EXPT-2NUM to check for x,y.

; Note. if either of the numeric expressions contain STR$ then the flag setting
; above will be undone when the channel flags are reset during STR$.
; e.g.
; 10 BORDER 3 : PLOT VAL STR$ 128, VAL STR$ 100

; ------------------
; Command class---0B
; ------------------
; Again a single class for four commands.
; This command just jumps back to SAVE-ETC to handle the four tape commands.
; The routine itself works out which command has called it by examining the
; address in T_ADDR_L. Note therefore that the syntax table has to be
; located where these and other sequential command addresses are not split
; over a page boundary.

	ORG	$1CDB
CLASS_0B:	JP	SAVE_ETC		; jump way back

; --------------
; Fetch a number
; --------------
; This routine is called from CLASS-03 when a command may be followed by
; an optional numeric expression e.g. RUN. If the end of statement has
; been reached then zero is used as the default.
; Also called from LIST-4.

	ORG	$1CDE
FETCH_NUM:
	CP	$0D		; is character a carriage return ?
	JR	Z,USE_ZERO	; forward if so
	CP	$3A		; is it ':' ?
	JR	NZ,EXPT_1NUM	; forward if not.
				; else continue and use zero.

; ----------------
; Use zero routine
; ----------------
; This routine is called four times to place the value zero on the
; calculator stack as a default value in runtime.

	ORG	$1CE6
USE_ZERO:	CALL	SYNTAX_Z		; (UNSTACK-Z?)
	RET	Z		;
	RST	28H		;; FP_CALC
	DEFB	$A0		;;stk-zero	;0.
	DEFB	$38		;;end-calc
	RET			; return.

; -------------------
; Handle STOP command
; -------------------
; Command Syntax: STOP
; One of the shortest and least used commands. As with 'OK' not an error.

	ORG	$1CEE
REPORT_9:RST	08H		; ERROR_1
	DEFB	$08		; Error Report: BREAK in program

; -----------------
; Handle IF command
; -----------------
; e.g. IF score>100 THEN PRINT "You Win"
; The parser has already checked the expression the result of which is on
; the calculator stack. The presence of the 'THEN' separator has also been
; checked and CH-ADD points to the command after THEN.

	ORG	$1CF0
_IF:	POP	BC		; drop return address - STMT-RET
	CALL	SYNTAX_Z		;
	JR	Z,_IF_1		; forward to _IF_1 if checking syntax
				; to check syntax of PRINT "You Win"
	RST	28H		;; FP_CALC	score>100 (1=TRUE 0=FALSE)
	DEFB	$02		;;delete		.
	DEFB	$38		;;end-calc
	EX	DE,HL		; make HL point to deleted value
	CALL	TEST_ZERO		;
	JP	C,LINE_END	; jump if FALSE (0)

	ORG	$1D00
_IF_1:	JP	STMT_L_1		; jump if true (1) to execute command
				; after 'THEN' token.

; ------------------
; Handle FOR command
; ------------------
; e.g. FOR i = 0 TO 1 STEP 0.1
; Using the syntax tables, the parser has already checked for a start and
; limit value and also for the intervening separator.
; the two values v,l are on the calculator stack.
; CLASS-04 has also checked the variable and the name is in STRLEN_L.
; The routine begins by checking for an optional STEP.

	ORG	$1D03
FOR:	CP	$CD		; is there a 'STEP' ?
	JR	NZ,F_USE_1	; if not to use 1 as default.
	RST	20H		; NEXT_CHAR
	CALL	EXPT_1NUM		;
	CALL	CHECK_END		;
	JR	F_REORDER		;

; ---

	ORG	$1D10
F_USE_1:	CALL	CHECK_END		;
	RST	28H		;; FP_CALC	v,l.
	DEFB	$A1		;;stk-one		v,l,1=s.
	DEFB	$38		;;end-calc

	ORG	$1D16
F_REORDER:
	RST	28H		;; FP_CALC	v,l,s.
	DEFB	$C0		;;st-mem-0	v,l,s.
	DEFB	$02		;;delete		v,l.
	DEFB	$01		;;exchange	l,v.
	DEFB	$E0		;;get-mem-0	l,v,s.
	DEFB	$01		;;exchange	l,s,v.
	DEFB	$38		;;end-calc
	CALL	LET		; assigns the initial value v to
				; the variable altering type if necessary.
	LD	(MEM),HL		; The system variable MEM is made to point to
				; the variable instead of its normal
				; location MEMBOT
	DEC	HL		; point to single-character name
	LD	A,(HL)		; fetch name
	SET	7,(HL)		; set bit 7 at location
	LD	BC,$0006		; add six to HL
	ADD	HL,BC		; to address where limit should be.
	RLCA			; test bit 7 of original name.
	JR	C,F_L_S		; forward if already a FOR/NEXT variable
	LD	C,$0D		; otherwise an additional 13 bytes are needed.
				; 5 for each value, two for line number and
				; 1 byte for looping statement.
	CALL	MAKE_ROOM		; creates them.
	INC	HL		; make HL address limit.

	ORG	$1D34
F_L_S:	PUSH	HL		; save position.
	RST	28H		;; FP_CALC	l,s.
	DEFB	$02		;;delete		l.
	DEFB	$02		;;delete .
	DEFB	$38		;;end-calc
				; DE points to STKEND, l.
	POP	HL		; restore variable position
	EX	DE,HL		; swap pointers
	LD	C,$0A		; ten bytes to move
	LDIR			; Copy 'deleted' values to variable.
	LD	HL,(PPC)		; Load with current line number
	EX	DE,HL		; exchange pointers.
	LD	(HL),E		; save the looping line
	INC	HL		; in the next
	LD	(HL),D		; two locations.
	LD	D,(IY+$0D)	; fetch statement from SUBPPC system variable.
	INC	D		; increment statement.
	INC	HL		; and pointer
	LD	(HL),D		; and store the looping statement.
	CALL	NEXT_LOOP		; considers an initial
	RET	NC		; iteration. Return to STMT_RET if a loop is
				; possible to execute next statement.

; no loop is possible so execution continues after the matching 'NEXT'

	LD	B,(IY+$38)	; get single-character name from STRLEN_L
	LD	HL,(PPC)		; get the current line
	LD	(NEWPPC),HL	; and store it
	LD	A,(SUBPPC)	; fetch current statement
	NEG			; Negate as counter decrements from zero
				; initially and we are in the middle of a line.
	LD	D,A		; Store result in D.
	LD	HL,(CH_ADD)	; get current address from CH_ADD
	LD	E,$F3		; search will be for token 'NEXT'

	ORG	$1D64
F_LOOP:
	PUSH  BC  ; save variable name.
  LD  BC,(NXTLIN)  ; fetch
  CALL  LOOK_PROG ; routine searches for 'NEXT' token.
  LD  (NXTLIN),BC  ; update NXTLIN
  POP BC  ; and fetch the letter
  JR  C, REPORT_I ; forward if the end of program
  ; was reached by LOOK_PROG.
  ; 'NEXT missing'

  RST 20H ; NEXT_CHAR fetches character after NEXT
  OR  $20 ; ensure it is upper-case.
  CP  B ; compare with FOR variable name
  JR  Z,F_FOUND ; forward if it matches.

; but if no match i.e. nested FOR/NEXT loops then continue search.

  RST 20H ; NEXT_CHAR
  JR  F_LOOP ; back

; ---

	ORG	$1D7C
F_FOUND:  RST 20H ; NEXT_CHAR
  LD  A,$01 ; subtract the negated counter from 1
  SUB D ; to give the statement after the NEXT
  LD  (NSPPC),A ; set system variable NSPPC
  RET ; return to STMT-RET to branch to new
  ; line and statement. ->
; ---

	ORG	$1D84
REPORT_I:	RST	08H ; ERROR-1
	DEFB	$11 ; Error Report: NEXT missing

; ---------
; LOOK-PROG
; ---------
; Find DATA, DEF FN or NEXT.
; This routine searches the program area for one of the above three keywords.
; On entry, HL points to start of search area.
; The token is in E, and D holds a statement count, decremented from zero.

	ORG	$1D86
LOOK_PROG:  LD  A,(HL)  ; fetch current character
  CP  $3A ; is it ':' a statement separator ?
  JR  Z,L1DA3 ; forward to LOOK-P-2 if so.

; The starting point was PROG - 1 or the end of a line.

	ORG	$1D8B
LOOK_P_1:
L1D8B:  INC HL  ; increment pointer to address
  LD  A,(HL)  ; the high byte of line number
  AND $C0 ; test for program end marker $80 or a
  ; variable
  SCF ; Set Carry Flag
  RET NZ  ; return with carry set if at end
  ; of program. ->

  LD  B,(HL)  ; high byte of line number to B
  INC HL  ;
  LD  C,(HL)  ; low byte to C.
  LD  (NEWPPC),BC  ; set system variable NEWPPC.
  INC HL  ;
  LD  C,(HL)  ; low byte of line length to C.
  INC HL  ;
  LD  B,(HL)  ; high byte to B.
  PUSH  HL  ; save address
  ADD HL,BC ; add length to position.
  LD  B,H ; and save result
  LD  C,L ; in BC.
  POP HL  ; restore address.
  LD  D,$00 ; initialize statement counter to zero.

	ORG	$1DA3
LOOK_P_2:
L1DA3:  PUSH  BC  ; save address of next line
  CALL  EACH_STMT ; routine EACH-STMT searches current line.
  POP BC  ; restore address.
  RET NC  ; return if match was found. ->

  JR  L1D8B ; back to LOOK-P-1 for next line.

; -------------------
; Handle NEXT command
; -------------------
; e.g. NEXT i
; The parameter tables have already evaluated the presence of a variable

	ORG	$1DAB
NEXT:
L1DAB:  BIT 1,(IY+$37)  ; test FLAGX - handling a new variable ?
  JP  NZ,REPORT_2  ; jump back to REPORT-2 if so
  ; 'Undefined variable'

; now test if found variable is a simple variable uninitialized by a FOR.

  LD  HL,(DEST)  ; load address of variable from DEST
  BIT 7,(HL)  ; is it correct type ?
  JR  Z,L1DD8 ; forward to REPORT-1 if not
  ; 'Unexpected NEXT'

  INC HL  ; step past variable name
  LD  (MEM),HL  ; and set MEM to point to three 5-byte values
  ; value, limit, step.

  RST 28H ;; FP_CALC add step and re-store
  DEFB  $E0 ;;get-mem-0  v.
  DEFB  $E2 ;;get-mem-2  v,s.
  DEFB  $0F ;;addition v+s.
  DEFB  $C0 ;;st-mem-0 v+s.
  DEFB  $02 ;;delete .
  DEFB  $38 ;;end-calc

  CALL  L1DDA ; routine NEXT-LOOP tests against limit.
  RET C ; return if no more iterations possible.

  LD  HL,(MEM)  ; find start of variable contents from MEM.
  LD  DE,$000F  ; add 3*5 to
  ADD HL,DE ; address the looping line number
  LD  E,(HL)  ; low byte to E
  INC HL  ;
  LD  D,(HL)  ; high byte to D
  INC HL  ; address looping statement
  LD  H,(HL)  ; and store in H
  EX  DE,HL ; swap registers
  JP  L1E73 ; exit via GO-TO-2 to execute another loop.

; ---

	ORG	$1DD8
REPORT_1:
L1DD8:  RST 08H ; ERROR-1
  DEFB  $00 ; Error Report: Unexpected NEXT


; -----------------
; Perform NEXT loop
; -----------------
; This routine is called from the FOR command to test for an initial
; iteration and from the NEXT command to test for all subsequent iterations.
; the system variable MEM addresses the variable's contents which, in the
; latter case, have had the step, possibly negative, added to the value.

	ORG	$1DDA
NEXT_LOOP:
L1DDA:  RST 28H ;; FP_CALC
  DEFB  $E1 ;;get-mem-1  l.
  DEFB  $E0 ;;get-mem-0  l,v.
  DEFB  $E2 ;;get-mem-2  l,v,s.
  DEFB  $36 ;;less-0 l,v,(1/0) negative step ?
  DEFB  $00 ;;jump-true  l,v.(1/0)

  DEFB  $02 ;;to L1DE2, NEXT-1 if step negative

  DEFB  $01 ;;exchange v,l.

	ORG	$1DE2
NEXT_1:
L1DE2:  DEFB  $03 ;;subtract l-v OR v-l.
  DEFB  $37 ;;greater-0  (1/0)
  DEFB  $00 ;;jump-true  .

  DEFB  $04 ;;to L1DE9, NEXT-2 if no more iterations.

  DEFB  $38 ;;end-calc .

  AND A ; clear carry flag signalling another loop.
  RET ; return

; ---


	ORG	$1DE9
NEXT_2:
L1DE9:  DEFB  $38 ;;end-calc .

  SCF ; set carry flag signalling looping exhausted.
  RET ; return


; -------------------
; Handle READ command
; -------------------
; e.g. READ a, b$, c$(1000 TO 3000)
; A list of comma-separated variables is assigned from a list of
; comma-separated expressions.
; As it moves along the first list, the character address CH_ADD is stored
; in X_PTR while CH_ADD is used to read the second list.

	ORG	$1DEC
READ_3:
L1DEC:  RST 20H ; NEXT_CHAR

; -> Entry point.

	ORG	$1DED
READ:
L1DED:  CALL  CLASS_01 ; routine CLASS-01 checks variable.
  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L1E1E ; forward to READ-2 if checking syntax


  RST 18H ; GET_CHAR
  LD  (X_PTR),HL  ; save character position in X_PTR.
  LD  HL,(DATADD)  ; load HL with Data Address DATADD, which is
  ; the start of the program or the address
  ; after the last expression that was read or
  ; the address of the line number of the
  ; last RESTORE command.
  LD  A,(HL)  ; fetch character
  CP  $2C ; is it a comma ?
  JR  Z,L1E0A ; forward to READ-1 if so.

; else all data in this statement has been read so look for next DATA token

  LD  E,$E4 ; token 'DATA'
  CALL  LOOK_PROG ; routine LOOK-PROG
  JR  NC,L1E0A  ; forward to READ-1 if DATA found

; else report the error.

	ORG	$1E08
REPORT_E:
L1E08:  RST 08H ; ERROR-1
  DEFB  $0D ; Error Report: DATA missing

	ORG	$1E0A
READ_1:
L1E0A:  CALL  TEMP_PTR1 ; routine TEMP-PTR1 advances updating CH_ADD
  ; with new DATADD position.
  CALL  VAL_FET_1 ; routine VAL-FET-1 assigns value to variable
  ; checking type match and adjusting CH_ADD.

  RST 18H ; GET_CHAR fetches adjusted character position
  LD  (DATADD),HL  ; store back in DATADD
  LD  HL,(X_PTR)  ; fetch X_PTR  the original READ CH_ADD
  LD  (IY+$26),$00  ; now nullify X_PTR_H
  CALL  TEMP_PTR2 ; routine TEMP-PTR2 restores READ CH_ADD

	ORG	$1E1E
READ_2:
L1E1E:  RST 18H ; GET_CHAR
  CP  $2C ; is it ',' indicating more variables to read ?
  JR  Z,L1DEC ; back to READ-3 if so

  CALL  CHECK_END ; routine CHECK-END
  RET ; return from here in runtime to STMT-RET.

; -------------------
; Handle DATA command
; -------------------
; In runtime this 'command' is passed by but the syntax is checked when such
; a statement is found while parsing a line.
; e.g. DATA 1, 2, "text", score-1, a$(location, room, object), FN r(49),
; wages - tax, TRUE, The meaning of life

	ORG	$1E27
DATA:
L1E27:  CALL  SYNTAX_Z ; routine SYNTAX-Z to check status
  JR  NZ,L1E37  ; forward to DATA-2 if in runtime

	ORG	$1E2C
DATA_1:
L1E2C:  CALL  SCANNING ; routine SCANNING to check syntax of
  ; expression
  CP  $2C ; is it a comma ?
  CALL  NZ,CHECK_END  ; routine CHECK-END checks that statement
  ; is complete. Will make an early exit if
  ; so. >>>
  RST 20H ; NEXT_CHAR
  JR  L1E2C ; back to DATA-1

; ---

	ORG	$1E37
DATA_2:
L1E37:  LD  A,$E4 ; set token to 'DATA' and continue into
  ; the PASS-BY routine.


; ----------------------------------
; Check statement for DATA or DEF FN
; ----------------------------------
; This routine is used to backtrack to a command token and then
; forward to the next statement in runtime.

	ORG	$1E39
;; PASS-BY
L1E39:  LD  B,A ; Give BC enough space to find token.
  CPDR  ; Compare decrement and repeat. (Only use).
  ; Work backwards till keyword is found which
  ; is start of statement before any quotes.
  ; HL points to location before keyword.
  LD  DE,$0200  ; count 1+1 statements, dummy value in E to
  ; inhibit searching for a token.
  JP  EACH_STMT ; to EACH-STMT to find next statement

; ---------------------
; THE 'RESTORE' COMMAND
; ---------------------
; The restore command sets the system variable for the data address to
; point to the location before the supplied line number or first line
; thereafter.
; This alters the position where subsequent READ commands look for data.
; Note. If supplied with inappropriate high numbers the system may crash
; in the LINE-ADDR routine as it will pass the program/variables end-marker
; and then lose control of what it is looking for - variable or line number.
; - observation, Steven Vickers, 1984, Pitman.

	ORG	$1E42
RESTORE:
;;; CALL  FIND_INT2 ; routine FIND-INT2 puts integer in BC.
  CALL  FIND_LINE ;+

; this entry point is used from RUN command with BC holding zero

	ORG	$1E45
;; REST-RUN
REST_RUN:
L1E45:  LD  H,B ; transfer the line
  LD  L,C ; number to the HL register.
  CALL  LINE_ADDR ; routine LINE-ADDR to fetch the address.
  DEC HL  ; point to the location before the line.
  LD  (DATADD),HL  ; update system variable DATADD.
  RET ; return to STMT-RET (or RUN)

; ------------------------
; Handle RANDOMIZE command
; ------------------------
; This command sets the SEED for the RND function to a fixed value.
; With the parameter zero, a random start point is used depending on
; how long the computer has been switched on.

	ORG	$1E4F
RANDOMIZE:  CALL  FIND_INT2 ; routine FIND-INT2 puts parameter in BC.
  LD  A,B ; test this
  OR  C ; for zero.
  JR  NZ,L1E5A  ; forward to RAND-1 if not zero.

  LD  BC,($5C78)  ; use the lower two bytes at FRAMES1.

	ORG	$1E5A
;; RAND-1
L1E5A:  LD  ($5C76),BC  ; place in SEED system variable.
  RET ; return to STMT-RET

; -----------------------
; Handle CONTINUE command
; -----------------------
; The CONTINUE command transfers the OLD (but incremented) values of
; line number and statement to the equivalent "NEW VALUE" system variables
; by using the last part of GO TO and exits indirectly to STMT-RET.

	ORG	$1E5F
CONT:  LD  HL,($5C6E)  ; fetch OLDPPC line number.
  LD  D,(IY+$36)  ; fetch OSPPC statement.
  JR  L1E73 ; forward to GO-TO-2

; --------------------
; Handle GO TO command
; --------------------
; The GO TO command routine is also called by GO SUB and RUN routines
; to evaluate the parameters of both commands.
; It updates the system variables used to fetch the next line/statement.
; It is at STMT-RET that the actual change in control takes place.
; Unlike some BASICs the line number need not exist.
; Note. the high byte of the line number is incorrectly compared with $F0
; instead of $3F. This leads to commands with operands greater than 32767
; being considered as having been run from the editing area and the
; error report 'Statement Lost' is given instead of 'OK'.
; - Steven Vickers, 1984.

	ORG	$1E67
GO_TO:
;;; CALL  FIND_INT2 ; routine FIND-INT2 puts operand in BC
  CALL  FIND_LINE ;+
  LD  H,B ; transfer line
  LD  L,C ; number to HL.
  LD  D,$00 ; set statement to 0 - first.
  LD  A,H ; compare high byte only
  CP  $F0 ; to $F0 i.e. 61439 in full.
  JR  NC,REPORT_Bb  ; forward to REPORT-B if above.

; This call entry point is used to update the system variables e.g. by RETURN.

	ORG	$1E73
;; GO-TO-2
L1E73:  LD  (NEWPPC),HL  ; save line number in NEWPPC
  LD  (IY+$0A),D  ; and statement in NSPPC
  RET ; to STMT-RET (or GO-SUB command)

; ------------------
; Handle OUT command
; ------------------
; Syntax has been checked and the two comma-separated values are on the
; calculator stack.

	ORG	$1E7A
_OUT:  CALL  L1E85 ; routine TWO-PARAM fetches values
  ; to BC and A.
  OUT (C),A ; perform the operation.
  RET ; return to STMT-RET.

; -------------------
; Handle POKE command
; -------------------
; This routine alters a single byte in the 64K address space.
; Happily no check is made as to whether ROM or RAM is addressed.
; Sinclair BASIC requires no poking of system variables.

	ORG	$1E80
POKE:  CALL  L1E85 ; routine TWO-PARAM fetches values
  ; to BC and A.
  LD  (BC),A  ; load memory location with A.
  RET ; return to STMT-RET.

; ------------------------------------
; Fetch two  parameters from calculator stack
; ------------------------------------
; This routine fetches a byte and word from the calculator stack
; producing an error if either is out of range.

	ORG	$1E85
;; TWO-PARAM
L1E85:  CALL  FP_TO_A ; routine FP-TO-A
  JR  C,REPORT_Bb ; forward to REPORT-B if overflow occurred

  JR  Z,L1E8E ; forward to TWO-P-1 if positive

  NEG ; negative numbers are made positive

	ORG	$1E8E
;; TWO-P-1
L1E8E:  PUSH  AF  ; save the value
  CALL  FIND_INT2 ; routine FIND-INT2 gets integer to BC
  POP AF  ; restore the value
  RET ; return

; -------------
; Find integers
; -------------
; The first of these routines fetches a 8-bit integer (range 0-255) from the
; calculator stack to the accumulator and is used for colours, streams,
; durations and coordinates.
; The second routine fetches 16-bit integers to the BC register pair
; and is used to fetch command and function arguments involving line numbers
; or memory addresses and also array subscripts and tab arguments.
; ->

	ORG	$1E94
FIND_INT1:  CALL  FP_TO_A ; routine FP-TO-A
  JR  L1E9C ; forward to FIND-I-1 for common exit routine.

; ---

; ->

	ORG	$1E99
FIND_INT2:  CALL  FP_TO_BC ; routine FP-TO-BC

	ORG	$1E9C
;; FIND-I-1
L1E9C:  JR  C,REPORT_Bb ; to REPORT-Bb with overflow.

  RET Z ; return if positive.

	ORG	$1E9F
REPORT_Bb:  RST 08H ; ERROR-1
  DEFB  $0A ; Error Report: Out of range

; ------------------
; Handle RUN command
; ------------------
; This command runs a program starting at an optional line.
; It performs a 'RESTORE 0' then CLEAR

	ORG	$1EA1
RUN:  CALL  GO_TO ; routine GO-TO puts line number in
  ; system variables.
  LD  BC,$0000  ; prepare to set DATADD to first line.
  CALL  L1E45 ; routine REST-RUN does the 'restore'.
  ; Note BC still holds zero.
  JR  L1EAF ; forward to CLEAR-RUN to clear variables
  ; without disturbing RAMTOP and
  ; exit indirectly to STMT-RET

; --------------------
; Handle CLEAR command
; --------------------
; This command reclaims the space used by the variables.
; It also clears the screen and the GO SUB stack.
; With an integer expression, it sets the uppermost memory
; address within the BASIC system.
; "Contrary to the manual, CLEAR doesn't execute a RESTORE" -
; Steven Vickers, Pitman Pocket Guide to the Spectrum, 1984.

	ORG	$1EAC
CLEAR:  CALL  FIND_INT2 ; routine FIND-INT2 fetches to BC.

	ORG	$1EAF
;; CLEAR-RUN
L1EAF:  LD  A,B ; test for
  OR  C ; zero.
  JR  NZ,L1EB7  ; skip to CLEAR-1 if not zero.

  LD  BC,(RAMTOP)  ; use the existing value of RAMTOP if zero.

	ORG	$1EB7
;; CLEAR-1
L1EB7:  PUSH  BC  ; save ramtop value.

  LD  DE,(VARS)  ; fetch VARS
  LD  HL,(E_LINE)  ; fetch E_LINE
  DEC HL  ; adjust to point at variables end-marker.
  CALL  RECLAIM_1 ; routine RECLAIM-1 reclaims the space used by
  ; the variables.

;;;  CALL  CLS ; routine CLS to clear screen.
	CALL	CLEAR_1_2	; lets go with the manual.

  LD  HL,(STKEND)  ; fetch STKEND the start of free memory.
  LD  DE,$0032  ; allow for another 50 bytes.
  ADD HL,DE ; add the overhead to HL.

  POP DE  ; restore the ramtop value.
  SBC HL,DE ; if HL is greater than the value then jump
  JR  NC,L1EDA  ; forward to REPORT-M
  ; 'Bad RAMTOP'

  LD  HL,(P_RAMT)  ; now P-RAMT ($7FFF on 16K RAM machine)
  AND A ; exact this time.
  SBC HL,DE ; new ramtop must be lower or the same.
  JR  NC,L1EDC  ; skip to CLEAR-2 if in actual RAM.

	ORG	$1EDA
;; REPORT-M
L1EDA:  RST 08H ; ERROR-1
  DEFB  $15 ; Error Report: Bad RAMTOP

	ORG	$1EDC
;; CLEAR-2
L1EDC:  EX  DE,HL ; transfer ramtop value to HL.
  LD  (RAMTOP),HL  ; update system variable RAMTOP.
  POP DE  ; pop the return address STMT-RET.
  POP BC  ; pop the Error Address.
  LD  (HL),$3E  ; now put the GO SUB end-marker at RAMTOP.
  DEC HL  ; leave a location beneath it.
  LD  SP,HL ; initialize the machine stack pointer.
  PUSH  BC  ; push the error address.
  LD  (ERR_SP),SP  ; make ERR_SP point to location.
  EX  DE,HL ; put STMT-RET in HL.
  JP  (HL)  ; and go there directly.

; ---------------------
; Handle GO SUB command
; ---------------------
; The GO SUB command diverts BASIC control to a new line number
; in a very similar manner to GO TO but
; the current line number and current statement + 1
; are placed on the GO SUB stack as a RETURN point.

	ORG	$1EED
GO_SUB:  POP DE  ; drop the address STMT-RET
  LD  H,(IY+$0D)  ; fetch statement from SUBPPC and
  INC H ; increment it
  EX  (SP),HL ; swap - error address to HL,
  ; H (statement) at top of stack,
  ; L (unimportant) beneath.
  INC SP  ; adjust to overwrite unimportant byte
  LD  BC,(PPC)  ; fetch the current line number from PPC
  PUSH  BC  ; and PUSH onto GO SUB stack.
  ; the empty machine-stack can be rebuilt
  PUSH  HL  ; push the error address.
  LD  (ERR_SP),SP  ; make system variable ERR_SP point to it.
  PUSH  DE  ; push the address STMT-RET.
  CALL  GO_TO ; call routine GO-TO to update the system
  ; variables NEWPPC and NSPPC.
  ; then make an indirect exit to STMT-RET via
  LD  BC,$0014  ; a 20-byte overhead memory check.

; ----------------------
; Check available memory
; ----------------------
; This routine is used on many occasions when extending a dynamic area
; upwards or the GO SUB stack downwards.

	ORG	$1F05
TEST_ROOM:  LD  HL,(STKEND)  ; fetch STKEND
  ADD HL,BC ; add the supplied test value
  JR  C,L1F15 ; forward to REPORT-4 if over $FFFF

  EX  DE,HL ; was less so transfer to DE
  LD  HL,$0050  ; test against another 80 bytes
  ADD HL,DE ; anyway
  JR  C,L1F15 ; forward to REPORT-4 if this passes $FFFF

  SBC HL,SP ; if less than the machine stack pointer
  RET C ; then return - OK.

	ORG	$1F15
;; REPORT-4
L1F15:
REPORT_4:RST	08H		; ERROR_1
	DEFB	$03		; Out of Memory
				; Note. this error can now be trapped at $0008

	DEFS	3

; ------------------------------
; THE 'FREE MEMORY' USER ROUTINE
; ------------------------------
; This routine is not used by the ROM but allows users to evaluate
; approximate free memory with PRINT 65536 - USR 7962.

	ORG	$1F1A
;; free-mem
L1F1A:  LD  BC,$0000  ; allow no overhead.

  CALL  TEST_ROOM ; routine TEST-ROOM.

  LD  B,H ; transfer the result
  LD  C,L ; to the BC register.
  RET ; the USR function returns value of BC.

; --------------------
; THE 'RETURN' COMMAND
; --------------------
; As with any command, there are two values on the machine stack at the time
; it is invoked.  The machine stack is below the GOSUB stack.  Both grow
; downwards, the machine stack by two bytes, the GOSUB stack by 3 bytes.
; The highest location is a statement byte followed by a two-byte line number.

	ORG	$1F23
RETURN:  POP BC  ; drop the address STMT-RET.
  POP HL  ; now the error address.
  POP DE  ; now a possible BASIC return line.
  LD  A,D ; the high byte $00 - $27 is
  CP  $3E ; compared with the traditional end-marker $3E.
  JR  Z,L1F36 ; forward to REPORT-7 with a match.
  ; 'Unexpected RETURN'

; It was not the end-marker so a single statement byte remains at the base of
; the calculator stack. It can't be popped off.

  DEC SP  ; adjust stack pointer to create room for two
  ; bytes.
  EX  (SP),HL ; statement to H, error address to base of
  ; new machine stack.
  EX  DE,HL ; statement to D,  BASIC line number to HL.
  LD  (ERR_SP),SP  ; adjust ERR_SP to point to new stack pointer
  PUSH  BC  ; now re-stack the address STMT-RET
  JP  L1E73 ; to GO-TO-2 to update statement and line
  ; system variables and exit indirectly to the
  ; address just pushed on stack.

; ---

	ORG	$1F36
;; REPORT-7
L1F36:  PUSH  DE  ; replace the end-marker.
  PUSH  HL  ; now restore the error address
  ; as will be required in a few clock cycles.

  RST 08H ; ERROR-1
  DEFB  $06 ; Error Report: Unexpected RETURN

; --------------------
; Handle PAUSE command
; --------------------
; The pause command takes as its parameter the number of interrupts
; for which to wait. PAUSE 50 pauses for about a second.
; PAUSE 0 pauses indefinitely.
; Both forms can be finished by pressing a key.

	ORG	$1F3A
PAUSE:  CALL  FIND_INT2 ; routine FIND-INT2 puts value in BC

	ORG	$1F3D
;; PAUSE-1
L1F3D:  HALT  ; wait for interrupt.
  DEC BC  ; decrease counter.
  LD  A,B ; test if
  OR  C ; result is zero.
  JR  Z,L1F4F ; forward to PAUSE-END if so.

  LD  A,B ; test if
  AND C ; now $FFFF
  INC A ; that is, initially zero.
  JR  NZ,L1F49  ; skip forward to PAUSE-2 if not.

  INC BC  ; restore counter to zero.

	ORG	$1F49
;; PAUSE-2
L1F49:  BIT 5,(IY+$01)  ; test FLAGS - has a new key been pressed ?
  JR  Z,L1F3D ; back to PAUSE-1 if not.

	ORG	$1F4F
;; PAUSE-END
L1F4F:  RES 5,(IY+$01)  ; update FLAGS - signal no new key
  RET ; and return.

; -------------------
; Check for BREAK key
; -------------------
; This routine is called from COPY-LINE, when interrupts are disabled,
; to test if BREAK (SHIFT - SPACE) is being pressed.
; It is also called at STMT-RET after every statement.

	ORG	$1F54
BREAK_KEY:  LD  A,$7F ; Input address: $7FFE
  IN  A,($FE) ; read lower right keys
  RRA ; rotate bit 0 - SPACE
  RET C ; return if not reset

  LD  A,$FE ; Input address: $FEFE
  IN  A,($FE) ; read lower left keys
  RRA ; rotate bit 0 - SHIFT
  RET ; carry will be set if not pressed.
  ; return with no carry if both keys
  ; pressed.

; ---------------------
; Handle DEF FN command
; ---------------------
; e.g. DEF FN r$(a$,a) = a$(a TO )
; this 'command' is ignored in runtime but has its syntax checked
; during line-entry.

	ORG	$1F60
DEF_FN:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L1F6A ; forward to DEF-FN-1 if parsing

  LD  A,$CE ; else load A with 'DEF FN' and
  JP  L1E39 ; jump back to PASS-BY

; ---

; continue here if checking syntax.

	ORG	$1F6A
;; DEF-FN-1
L1F6A:  SET  6,(IY+$01) ; set FLAGS  - Assume numeric result
  CALL  ALPHA ; call routine ALPHA
  JR  NC,L1F89  ; if not then to DEF-FN-4 to jump to
  ; 'Syntax error'


  RST 20H ; NEXT_CHAR
  CP  $24 ; is it '$' ?
  JR  NZ,L1F7D  ; to DEF-FN-2 if not as numeric.

  RES 6,(IY+$01)  ; set FLAGS  - Signal string result

  RST 20H ; get NEXT_CHAR

	ORG	$1F7D
;; DEF-FN-2
L1F7D:  CP  $28 ; is it '(' ?
  JR  NZ,L1FBD  ; to DEF-FN-7 'Syntax error'


  RST 20H ; NEXT_CHAR
  CP  $29 ; is it ')' ?
  JR  Z,L1FA6 ; to DEF-FN-6 if null argument

	ORG	$1F86
;; DEF-FN-3
L1F86:  CALL  ALPHA ; routine ALPHA checks that it is the expected
  ; alphabetic character.

	ORG	$1F89
;; DEF-FN-4
L1F89:  JP  NC,REPORT_C  ; to REPORT-C  if not
  ; 'Syntax error'.

  EX  DE,HL ; save pointer in DE

  RST 20H ; NEXT_CHAR re-initializes HL from CH_ADD
  ; and advances.
  CP  $24 ; '$' ? is it a string argument.
  JR  NZ,L1F94  ; forward to DEF-FN-5 if not.

  EX  DE,HL ; save pointer to '$' in DE

  RST 20H ; NEXT_CHAR re-initializes HL and advances

	ORG	$1F94
;; DEF-FN-5
L1F94:  EX  DE,HL ; bring back pointer.
  LD  BC,$0006  ; the function requires six hidden bytes for
  ; each parameter passed.
  ; The first byte will be $0E
  ; then 5-byte numeric value
  ; or 5-byte string pointer.

  CALL  MAKE_ROOM ; routine MAKE-ROOM creates space in program
  ; area.

  INC HL  ; adjust HL (set by LDDR)
  INC HL  ; to point to first location.
  LD  (HL),$0E  ; insert the 'hidden' marker.

; Note. these invisible storage locations hold nothing meaningful for the
; moment. They will be used every time the corresponding function is
; evaluated in runtime.
; Now consider the following character fetched earlier.

  CP  $2C ; is it ',' ? (more than one parameter)
  JR  NZ,L1FA6  ; to DEF-FN-6 if not


  RST 20H ; else NEXT_CHAR
  JR  L1F86 ; and back to DEF-FN-3

; ---

	ORG	$1FA6
;; DEF-FN-6
L1FA6:  CP  $29 ; should close with a ')'
  JR  NZ,L1FBD  ; to DEF-FN-7 if not
  ; 'Syntax error'


  RST 20H ; get NEXT_CHAR
  CP  $3D ; is it '=' ?
  JR  NZ,L1FBD  ; to DEF-FN-7 if not 'Nonsense...'


  RST 20H ; address NEXT_CHAR
  LD  A,(FLAGS) ; get FLAGS which has been set above
  PUSH  AF  ; and preserve

  CALL  SCANNING ; routine SCANNING checks syntax of expression
  ; and also sets flags.

  POP AF  ; restore previous flags
  XOR (IY+$01)  ; xor with FLAGS - bit 6 should be same
  ; therefore will be reset.
  AND $40 ; isolate bit 6.

	ORG	$1FBD
;; DEF-FN-7
L1FBD:  JP  NZ,REPORT_C  ; jump back to REPORT-C if the expected result
  ; is not the same type.
  ; 'Syntax error'

  CALL  CHECK_END ; routine CHECK-END will return early if
  ; at end of statement and move onto next
  ; else produce error report. >>>

  ; There will be no return to here.

; -------------------------------
; Returning early from subroutine
; -------------------------------
; All routines are capable of being run in two modes - syntax checking mode
; and runtime mode.  This routine is called often to allow a routine to return
; early if checking syntax.

	ORG	$1FC3
;; UNSTACK-Z
L1FC3:  CALL  SYNTAX_Z ; routine SYNTAX-Z sets zero flag if syntax
  ; is being checked.

  POP HL  ; drop the return address.
  RET  Z  ; return to previous call in chain if checking
  ; syntax.

  JP  (HL)  ; jump to return address as BASIC program is
  ; actually running.

; ---------------------
; Handle LPRINT command
; ---------------------
; A simple form of 'PRINT #3' although it can output to 16 streams.
; Probably for compatibility with other BASICs particularly ZX81 BASIC.
; An extra UDG might have been better.

	ORG	$1FC9
LPRINT:  LD  A,$03 ; the printer channel
  JR  L1FCF ; forward to PRINT-1

; ---------------------
; Handle PRINT commands
; ---------------------
; The Spectrum's main stream output command.
; The default stream is stream 2 which is normally the upper screen
; of the computer. However the stream can be altered in range 0 - 15.

	ORG	$1FCD
PRINT:  LD  A,$02 ; the stream for the upper screen.

; The LPRINT command joins here.

	ORG	$1FCF
;; PRINT-1
L1FCF:  CALL  SYNTAX_Z ; routine SYNTAX-Z checks if program running
  CALL  NZ,CHAN_OPEN  ; routine CHAN-OPEN if so
  CALL  TEMPS ; routine TEMPS sets temporary colours.
  CALL  L1FDF ; routine PRINT-2 - the actual item
  CALL  CHECK_END ; routine CHECK-END gives error if not at end
  ; of statement
  RET ; and return >>>

; ------------------------------------
; this subroutine is called from above
; and also from INPUT.

	ORG	$1FDF
;; PRINT-2
L1FDF:  RST 18H ; GET_CHAR gets printable character
  CALL  L2045 ; routine PR-END-Z checks if more printing
  JR  Z,L1FF2 ; to PRINT-4 if not e.g. just 'PRINT :'

; This tight loop deals with combinations of positional controls and
; print items. An early return can be made from within the loop
; if the end of a print sequence is reached.

	ORG	$1FE5
;; PRINT-3
L1FE5:  CALL  L204E ; routine PR-POSN-1 returns zero if more
  ; but returns early at this point if
  ; at end of statement!
  ;
  JR  Z,L1FE5 ; to PRINT-3 if consecutive positioners

  CALL  L1FFC ; routine PR-ITEM-1 deals with strings etc.
  CALL  L204E ; routine PR-POSN-1 for more position codes
  JR  Z,L1FE5 ; loop back to PRINT-3 if so

	ORG	$1FF2
;; PRINT-4
L1FF2:  CP  $29 ; return now if this is ')' from input-item.
  ; (see INPUT.)
  RET Z ; or continue and print carriage return in
  ; runtime

; ---------------------
; Print carriage return
; ---------------------
; This routine which continues from above prints a carriage return
; in run-time. It is also called once from PRINT-POSN.

	ORG	$1FF5
;; PRINT-CR
L1FF5:  CALL  L1FC3 ; routine UNSTACK-Z

  LD  A,$0D ; prepare a carriage return

  RST 10H ; PRINT_A
  RET ; return


; -----------
; Print items
; -----------
; This routine deals with print items as in
; PRINT AT 10,0;"The value of A is ";a
; It returns once a single item has been dealt with as it is part
; of a tight loop that considers sequences of positional and print items

	ORG	$1FFC
;; PR-ITEM-1
L1FFC:  RST 18H ; GET_CHAR
  CP  $AC ; is character 'AT' ?
  JR  NZ,L200E  ; forward to PR-ITEM-2 if not.

  CALL  NEXT_2NUM ; routine NEXT-2NUM  check for two comma
  ; separated numbers placing them on the
  ; calculator stack in runtime.
  CALL  L1FC3 ; routine UNSTACK-Z quits if checking syntax.

  CALL  STK_TO_BC ; routine STK-TO-BC get the numbers in B and C.
  LD  A,$16 ; prepare the 'at' control.
  JR  L201E ; forward to PR-AT-TAB to print the sequence.

; ---

	ORG	$200E
;; PR-ITEM-2
L200E:  CP  $AD ; is character 'TAB' ?
  JR  NZ,L2024  ; to PR-ITEM-3 if not


  RST 20H ; NEXT_CHAR to address next character
  CALL  EXPT_1NUM ; routine EXPT-1NUM
  CALL  L1FC3 ; routine UNSTACK-Z quits if checking syntax.

  CALL  FIND_INT2 ; routine FIND-INT2 puts integer in BC.
  LD  A,$17 ; prepare the 'tab' control.

	ORG	$201E
;; PR-AT-TAB
L201E:  RST 10H ; PRINT_A outputs the control

  LD  A,C ; first value to A
  RST 10H ; PRINT_A outputs it.

  LD  A,B ; second value
  RST 10H ; PRINT_A

  RET ; return - item finished >>>

; ---

; Now consider paper 2; #2; a$

	ORG	$2024
;; PR-ITEM-3
L2024:  CALL  CO_TEMP_3 ; routine CO-TEMP-3 will print any colour
  RET NC  ; items - return if success.

  CALL  STR_ALTER ; routine STR_ALTER considers new stream
  RET NC  ; return if altered.

  CALL  SCANNING ; routine SCANNING now to evaluate expression
  CALL  L1FC3 ; routine UNSTACK-Z if not runtime.

  BIT 6,(IY+$01)  ; test FLAGS  - Numeric or string result ?
  CALL  Z,STK_FETCH ; routine STK-FETCH if string.
  ; note no flags affected.
  JP  NZ,PRINT_FP  ; to PRINT-FP to print if numeric >>>

; It was a string expression - start in DE, length in BC
; Now enter a loop to print it

	ORG	$203C
PR_STRING:  LD  A,B ; this tests if the
  OR  C ; length is zero and sets flag accordingly.
  DEC BC  ; this doesn't but decrements counter.
  RET Z ; return if zero.

  LD  A,(DE)  ; fetch character.
  INC DE  ; address next location.

  RST 10H ; PRINT_A.

  JR  PR_STRING ; loop back to PR-STRING.

; ---------------
; End of printing
; ---------------
; This subroutine returns zero if no further printing is required
; in the current statement.
; The first terminator is found in  escaped input items only,
; the others in print_items.

	ORG	$2045
;; PR-END-Z
L2045:  CP  $29 ; is character a ')' ?
  RET Z ; return if so -  e.g. INPUT (p$); a$

	ORG	$2048
PR_ST_END:  CP  $0D ; is it a carriage return ?
  RET Z ; return also - e.g. PRINT a

  CP  $3A ; is character a ':' ?
  RET ; return - zero flag will be set if so.
  ; e.g. PRINT a :

; --------------
; Print position
; --------------
; This routine considers a single positional character ';', ',', '''

	ORG	$204E
;; PR-POSN-1
L204E:  RST 18H ; GET_CHAR
  CP  $3B ; is it ';' ?
  ; i.e. print from last position.
  JR  Z,L2067 ; forward to PR-POSN-3 if so.
  ; i.e. do nothing.

  CP  $2C ; is it ',' ?
  ; i.e. print at next tabstop.
  JR  NZ,L2061  ; forward to PR-POSN-2 if anything else.

  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L2067 ; forward to PR-POSN-3 if checking syntax.

  LD  A,$06 ; prepare the 'comma' control character.

  RST 10H ; PRINT_A  outputs to current channel in
  ; run-time.

  JR  L2067 ; skip to PR-POSN-3.

; ---

; check for newline.

	ORG	$2061
;; PR-POSN-2
L2061:  CP  $27 ; is character a "'" ? (newline)
  RET NZ  ; return if no match  >>>

  CALL  L1FF5 ; routine PRINT-CR outputs a carriage return
  ; in runtime only.

	ORG	$2067
;; PR-POSN-3
L2067:  RST 20H ; NEXT_CHAR to A.
  CALL  L2045 ; routine PR-END-Z checks if at end.
  JR  NZ,L206E  ; to PR-POSN-4 if not.

  POP BC  ; drop return address if at end.

	ORG	$206E
;; PR-POSN-4
L206E:  CP  A ; reset the zero flag.
  RET ; and return to loop or quit.

; ------------
; Alter stream
; ------------
; This routine is called from PRINT ITEMS above, and also LIST as in
; LIST #15

	ORG	$2070
STR_ALTER:  CP  $23 ; is character '#' ?
  SCF ; set carry flag.
  RET NZ  ; return if no match.


  RST  20H  ; NEXT_CHAR
  CALL  EXPT_1NUM ; routine EXPT-1NUM gets stream number
  AND A ; prepare to exit early with carry reset
  CALL  L1FC3 ; routine UNSTACK-Z exits early if parsing
  CALL  FIND_INT1 ; routine FIND-INT1 gets number off stack
  CP  $10 ; must be range 0 - 15 decimal.
  JP  NC,REPORT_Oa  ; jump back to REPORT-Oa if not
  ; 'Bad stream'.

  CALL  CHAN_OPEN ; routine CHAN-OPEN
  AND A ; clear carry - signal item dealt with.
  RET ; return

; -------------------
; THE 'INPUT' COMMAND
; -------------------
; This command is mysterious.
;

	ORG	$2089
INPUT:  CALL  SYNTAX_Z ; routine SYNTAX-Z to check if in runtime.

  JR  Z,L2096 ; forward to INPUT-1 if checking syntax.

;;; LD  A,$01 ; select stream 1 normally channel 'K' for input
;;; CALL  CHAN_OPEN ; routine CHAN-OPEN activates the channel

; Note. As a consequence of clearing the lower screen channel 0 is made
; the current channel so the above two instructions are superfluous.

  CALL  CLS_LOWER ; routine CLS-LOWER clears the lower screen
  ; and sets DF_SZ to two and TV_FLAG to $01.

  LD  A,$01 ;+ select stream 1 normally channel 'K'
  CALL  CHAN_OPEN ;+ routine CHAN-OPEN activates the channel


	ORG	$2096
;; INPUT-1
L2096:  LD  (IY+$02),$01  ; update TV_FLAG - signal lower screen in use
  ; ensuring that the correct set of system
  ; variables are updated and that the border
  ; colour is used.

; Note. The Complete Spectrum ROM Disassembly incorrectly names DF-SZ as the
; system variable that is updated above and if, as some have done, you make
; this unnecessary alteration then there will be two blank lines between the
; lower screen and the upper screen areas which will also scroll wrongly.

  CALL  L20C1 ; routine IN-ITEM-1 to handle the input.

  CALL  CHECK_END ; routine CHECK-END will make an early exit
  ; if checking syntax. >>>

; Keyboard input has been made and it remains to adjust the upper
; screen in case the lower two lines have been extended upwards.

  LD  BC,($5C88)  ; fetch S_POSN current line/column of
  ; the upper screen.
  LD  A,(DF_SZ) ; fetch DF_SZ the display file size of
  ; the lower screen.
  CP  B ; test that lower screen does not overlap
  JR  C,L20AD ; forward to INPUT-2 if not.

; the two screens overlap so adjust upper screen.

  LD  C,$21 ; set column of upper screen to leftmost.
  LD  B,A ; and line to one above lower screen.
  ; continue forward to update upper screen
  ; print position.

	ORG	$20AD
;; INPUT-2
L20AD:  LD  ($5C88),BC  ; set S_POSN update upper screen line/column.
  LD  A,$19 ; subtract from twenty five
  SUB B ; the new line number.
  LD  (SCR_CT),A ; and place result in SCR_CT - scroll count.
  RES 0,(IY+$02)  ; update TV_FLAG - signal main screen in use.

  CALL  CL_SET ; routine CL-SET sets the print position
  ; system variables for the upper screen.

  JP  CLS_LOWER ; jump back to CLS-LOWER and make
  ; an indirect exit >>.

; ---------------------
; INPUT ITEM subroutine
; ---------------------
; This subroutine deals with the input items and print items.
; from  the current input channel.
; It is only called from the above INPUT routine but was obviously
; once called from somewhere else in another context.

	ORG	$20C1
;; IN-ITEM-1
L20C1:  CALL  L204E ; routine PR-POSN-1 deals with a single
  ; position item at each call.
  JR  Z,L20C1 ; back to IN-ITEM-1 until no more in a
  ; sequence.

  CP  $28 ; is character '(' ?
  JR  NZ,L20D8  ; forward to IN-ITEM-2 if not.

; any variables within brackets will be treated as part, or all, of the
; prompt instead of being used as destination variables.

  RST 20H ; NEXT_CHAR
  CALL  L1FDF ; routine PRINT-2 to output the dynamic
  ; prompt.

  RST 18H ; GET_CHAR
  CP  $29 ; is character a matching ')' ?
  JP  NZ,REPORT_C  ; jump back to REPORT-C if not.
  ; 'Syntax error'.

  RST 20H ; NEXT_CHAR
  JP  L21B2 ; forward to IN-NEXT-2

; ---

	ORG	$20D8
;; IN-ITEM-2
L20D8:  CP  $CA ; is the character the token 'LINE' ?
  JR  NZ,L20ED  ; forward to IN-ITEM-3 if not.

  RST 20H ; NEXT_CHAR - variable must come next.
  CALL  CLASS_01 ; routine CLASS-01 returns destination
  ; address of variable to be assigned.
  ; or generates an error if no variable
  ; at this position.

  SET 7,(IY+$37)  ; update FLAGX  - signal handling INPUT LINE
  BIT 6,(IY+$01)  ; test FLAGS  - numeric or string result ?
  JP  NZ,REPORT_C  ; jump back to REPORT-C if not string
  ; 'Syntax error'.

  JR  L20FA ; forward to IN-PROMPT to set up workspace.

; ---

; the jump was here for other variables.

	ORG	$20ED
;; IN-ITEM-3
L20ED:  CALL ALPHA  ; routine ALPHA checks if character is
  ; a suitable variable name.
  JP  NC,L21AF  ; forward to IN-NEXT-1 if not

  CALL  CLASS_01 ; routine CLASS-01 returns destination
  ; address of variable to be assigned.
  RES 7,(IY+$37)  ; update FLAGX  - signal not INPUT LINE.

	ORG	$20FA
;; IN-PROMPT
L20FA:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JP  Z,L21B2 ; forward to IN-NEXT-2 if checking syntax.

  CALL  SET_WORK ; routine SET-WORK clears workspace.
  LD  HL,FLAGX  ; point to system variable FLAGX
  RES 6,(HL)  ; signal string result.
  SET 5,(HL)  ; signal in Input Mode for editor.
  LD  BC,$0001  ; initialize space required to one for
  ; the carriage return.
  BIT 7,(HL)  ; test FLAGX - INPUT LINE in use ?
  JR  NZ,L211C  ; forward to IN-PR-2 if so as that is
  ; all the space that is required.

  LD  A,(FLAGS) ; load accumulator from FLAGS
  AND $40 ; mask to test BIT 6 of FLAGS and clear
  ; the other bits in A.
  ; numeric result expected ?
  JR  NZ,L211A  ; forward to IN-PR-1 if so

  LD  C,$03 ; increase space to three bytes for the
  ; pair of surrounding quotes.

	ORG	$211A
;; IN-PR-1
L211A:  OR  (HL)  ; if numeric result, set bit 6 of FLAGX.
  LD  (HL),A  ; and update system variable

	ORG	$211C
;; IN-PR-2
L211C:  RST 30H ; BC_SPACES opens 1 or 3 bytes in workspace
  LD  (HL),$0D  ; insert carriage return at last new location.
  LD  A,C ; fetch the length, one or three.
  RRCA  ; lose bit 0.
  RRCA  ; test if quotes required.
  JR  NC,L2129  ; forward to IN-PR-3 if not.

  LD  A,$22 ; load the '"' character
  LD  (DE),A  ; place quote in first new location at DE.
  DEC HL  ; decrease HL - from carriage return.
  LD  (HL),A  ; and place a quote in second location.

	ORG	$2129
;; IN-PR-3
L2129:  LD  (K_CUR),HL  ; set keyboard cursor K_CUR to HL
  BIT 7,(IY+$37)  ; test FLAGX  - is this INPUT LINE ??
  JR  NZ,L215E  ; forward to IN-VAR-3 if so as input will
  ; be accepted without checking its syntax.

  LD  HL,(CH_ADD)  ; fetch CH_ADD
  PUSH  HL  ; and save on stack.
  LD  HL,(ERR_SP)  ; fetch ERR_SP
  PUSH  HL  ; and save on stack

	ORG	$213A
;; IN-VAR-1
L213A:  LD  HL,L213A  ; address: IN-VAR-1 - this address
  PUSH  HL  ; is saved on stack to handle errors.
  BIT 4,(IY+$30)  ; test FLAGS2  - is K channel in use ?
  JR  Z,L2148 ; forward to IN-VAR-2 if not using the
  ; keyboard for input. (??)

  LD  (ERR_SP),SP  ; set ERR_SP to point to IN-VAR-1 on stack.

	ORG	$2148
;; IN-VAR-2
L2148:  LD  HL,(WORKSP)  ; set HL to WORKSP - start of workspace.
  CALL  REMOVE_FP ; routine REMOVE-FP removes floating point
  ; forms when looping in error condition.
  LD  (IY+$00),$FF  ; set ERR_NR to 'OK' cancelling the error.
  ; but X_PTR causes flashing error marker
  ; to be displayed at each call to the editor.
  CALL  EDITOR ; routine EDITOR allows input to be entered
  ; or corrected if this is second time around.

; if we pass to next then there are no system errors

  RES 7,(IY+$01)  ; update FLAGS  - signal checking syntax
  CALL  L21B9 ; routine IN-ASSIGN checks syntax using
  ; the VAL-FET-2 and powerful SCANNING routines.
  ; any syntax error and its back to IN-VAR-1.
  ; but with the flashing error marker showing
  ; where the error is.
  ; Note. the syntax of string input has to be
  ; checked as the user may have removed the
  ; bounding quotes or escaped them as with
  ; "hat" + "stand" for example.
; proceed if syntax passed.

  JR  L2161 ; jump forward to IN-VAR-4

; ---

; the jump was to here when using INPUT LINE.

	ORG	$215E
;; IN-VAR-3
L215E:  CALL  EDITOR ; routine EDITOR is called for input

; when ENTER received rejoin other route but with no syntax check.

; INPUT and INPUT LINE converge here.

	ORG	$2161
;; IN-VAR-4
L2161:  LD  (IY+$22),$00  ; set K_CUR_H to a low value so that the cursor
  ; no longer appears in the input line.

  CALL  L21D6 ; routine IN-CHAN-K tests if the keyboard
  ; is being used for input.
  JR  NZ,L2174  ; forward to IN-VAR-5 if using another input
  ; channel.

; continue here if using the keyboard.

  CALL  ED_COPY ; routine ED_COPY overprints the edit line
  ; to the lower screen. The only visible
  ; affect is that the cursor disappears.
  ; if you're inputting more than one item in
  ; a statement then that becomes apparent.

  LD  BC,(ECHO_E)  ; fetch line and column from ECHO_E
  CALL  CL_SET ; routine CL-SET sets S-POSNL to those
  ; values.

; if using another input channel rejoin here.

	ORG	$2174
;; IN-VAR-5
L2174:  LD  HL,FLAGX  ; point HL to FLAGX
  RES 5,(HL)  ; signal not in input mode
  BIT 7,(HL)  ; is this INPUT LINE ?
  RES 7,(HL)  ; cancel the bit anyway.
  JR  NZ,L219B  ; forward to IN-VAR-6 if INPUT LINE.

  POP HL  ; drop the looping address
  POP HL  ; drop the address of previous
  ; error handler.
  LD  (ERR_SP),HL  ; set ERR_SP to point to it.
  POP HL  ; drop original CH_ADD which points to
  ; INPUT command in BASIC line.
  LD  (X_PTR),HL  ; save in X_PTR while input is assigned.
  SET 7,(IY+$01)  ; update FLAGS - Signal running program
  CALL  L21B9 ; routine IN-ASSIGN is called again
  ; this time the variable will be assigned
  ; the input value without error.
  ; Note. the previous example now
  ; becomes "hatstand"

  LD  HL,(X_PTR)  ; fetch stored CH_ADD value from X_PTR.
  LD  (IY+$26),$00  ; set X_PTR_H so that iy is no longer relevant.
  LD  (CH_ADD),HL  ; put restored value back in CH_ADD
  JR  L21B2 ; forward to IN-NEXT-2 to see if anything
  ; more in the INPUT list.

; ---

; the jump was to here with INPUT LINE only

	ORG	$219B
;; IN-VAR-6
L219B:  LD  HL,(STKBOT)  ; STKBOT points to the end of the input.
  LD  DE,(WORKSP)  ; WORKSP points to the beginning.
  SCF ; prepare for true subtraction.
  SBC HL,DE ; subtract to get length
  LD  B,H ; transfer it to
  LD  C,L ; the BC register pair.
  CALL  STK_STO_STR ; routine STK-STO-$ stores parameters on
  ; the calculator stack.
  CALL  LET ; routine LET assigns it to destination.
  JR  L21B2 ; forward to IN-NEXT-2 as print items
  ; not allowed with INPUT LINE.
  ; Note. that "hat" + "stand" will, for
  ; example, be unchanged as also would
  ; 'PRINT "Iris was here"'.

; ---

; the jump was to here when ALPHA found more items while looking for
; a variable name.

	ORG	$21AF
;; IN-NEXT-1
L21AF:  CALL  L1FFC ; routine PR-ITEM-1 considers further items.

	ORG	$21B2
;; IN-NEXT-2
L21B2:  CALL  L204E ; routine PR-POSN-1 handles a position item.
  JP  Z,L20C1 ; jump back to IN-ITEM-1 if the zero flag
  ; indicates more items are present.

  RET ; return.

; ---------------------------
; INPUT ASSIGNMENT Subroutine
; ---------------------------
; This subroutine is called twice from the INPUT command when normal
; keyboard input is assigned. On the first occasion syntax is checked
; using SCANNING. The final call with the syntax flag reset is to make
; the assignment.

	ORG	$21B9
;; IN-ASSIGN
L21B9:  LD  HL,(WORKSP)  ; fetch WORKSP start of input
  LD  (CH_ADD),HL  ; set CH_ADD to first character

  RST 18H ; GET_CHAR ignoring leading white-space.
  CP  $E2 ; is it 'STOP'
  JR  Z,L21D0 ; forward to IN-STOP if so.

  LD  A,(FLAGX) ; load accumulator from FLAGX
  CALL  VAL_FET_2 ; routine VAL-FET-2 makes assignment
  ; or goes through the motions if checking
  ; syntax. SCANNING is used.

  RST 18H ; GET_CHAR
  CP  $0D ; is it carriage return ?
  RET Z ; return if so
  ; either syntax is OK
  ; or assignment has been made.

; if another character was found then raise an error.
; User doesn't see report but the flashing error marker
; appears in the lower screen.

	ORG	$21CE
;; REPORT-Cb
L21CE:  RST 08H ; ERROR-1
  DEFB  $0B ; Error Report: Syntax error

	ORG	$21D0
;; IN-STOP
L21D0:  CALL  SYNTAX_Z ; routine SYNTAX-Z (UNSTACK-Z?)
  RET Z ; return if checking syntax
  ; as user wouldn't see error report.
  ; but generate visible error report
  ; on second invocation.

	ORG	$21D4
;; REPORT-H
L21D4:  RST 08H ; ERROR-1
  DEFB  $10 ; Error Report: BREAK in INPUT

; -----------------------------------
; THE 'TEST FOR CHANNEL K' SUBROUTINE
; -----------------------------------
; This subroutine is called once from the keyboard INPUT command to check if
; the input routine in use is the one for the keyboard.

	ORG	$21D6
;; IN-CHAN-K
L21D6:  LD  HL,(CURCHL)  ; fetch address of current channel CURCHL
  INC HL  ;
  INC HL  ; advance past
  INC HL  ; input and
  INC HL  ; output streams
  LD  A,(HL)  ; fetch the channel identifier.
  CP  $4B ; test for 'K'
  RET ; return with zero set if keyboard is use.

; --------------------
; Colour Item Routines
; --------------------
;
; These routines have 3 entry points -
; 1) CO-TEMP-2 to handle a series of embedded Graphic colour items.
; 2) CO-TEMP-3 to handle a single embedded print colour item.
; 3) CO TEMP-4 to handle a colour command such as FLASH 1
;
; "Due to a bug, if you bring in a peripheral channel and later use a colour
;  statement, colour controls will be sent to it by mistake." - Steven Vickers
;  Pitman Pocket Guide, 1984.
;
; To be fair, this only applies if the last channel was other than 'K', 'S'
; or 'P', which are all that are supported by this ROM, but if that last
; channel was a microdrive file, network channel etc. then
; PAPER 6; CLS will not turn the screen yellow and
; CIRCLE INK 2; 128,88,50 will not draw a red circle.
;
; This bug does not apply to embedded PRINT items as it is quite permissible
; to mix stream altering commands and colour items.
; The fix therefore would be to ensure that CLASS-07 and CLASS-09 make
; channel 'S' the current channel when not checking syntax.
; -----------------------------------------------------------------

	ORG	$21E1
CO_TEMP_1:  RST 20H ; NEXT_CHAR

; -> Entry point from CLASS-09. Embedded Graphic colour items.
; e.g. PLOT INK 2; PAPER 8; 128,88
; Loops till all colour items output, finally addressing the coordinates.

	ORG	$21E2
CO_TEMP_2:  CALL  CO_TEMP_3 ; routine CO-TEMP-3 to output colour control.
  RET C ; return if nothing more to output. ->


  RST 18H ; GET_CHAR
  CP  $2C ; is it ',' separator ?
  JR  Z,CO_TEMP_1 ; back if so to CO-TEMP-1

  CP  $3B ; is it ';' separator ?
  JR  Z,CO_TEMP_1 ; back to CO-TEMP-1 for more.

  JP  REPORT_C ; to REPORT-C (REPORT-Cb is within range)
  ; 'Syntax error'

; -------------------
; CO-TEMP-3
; -------------------
; -> this routine evaluates and outputs a colour control and parameter.
; It is called from above and also from PR-ITEM-3 to handle a single embedded
; print item e.g. PRINT PAPER 6; "Hi". In the latter case, the looping for
; multiple items is within the PR-ITEM routine.
; It is quite permissible to send these to any stream.

	ORG	$21F2
CO_TEMP_3:  CP  $D9 ; is it 'INK' ?
  RET C ; return if less.

  CP  $DF ; compare with 'OUT'
  CCF ; Complement Carry Flag
  RET C ; return if greater than 'OVER', $DE.

  PUSH  AF  ; save the colour token.

  RST 20H ; address NEXT_CHAR
  POP AF  ; restore token and continue.

; -> this entry point used by CLASS-07. e.g. the command PAPER 6.

	ORG	$21FC
CO_TEMP_4:  SUB $C9 ; reduce to control character $10 (INK)
  ; thru $15 (OVER).
  PUSH  AF  ; save control.
  CALL  EXPT_1NUM ; routine EXPT-1NUM stacks addressed
  ; parameter on calculator stack.
  POP AF  ; restore control.
  AND A ; clear carry

  CALL  L1FC3 ; routine UNSTACK-Z returns if checking syntax.

  PUSH  AF  ; save again
  CALL  FIND_INT1 ; routine FIND-INT1 fetches parameter to A.
  LD  D,A ; transfer now to D
  POP AF  ; restore control.

  RST 10H ; PRINT_A outputs the control to current
  ; channel.
  LD  A,D ; transfer parameter to A.

  RST 10H ; PRINT_A outputs parameter.
  RET ; return. ->

; -------------------------------------------------------------------------
;
; {fl}{br}{ paper }{  ink  }  The temporary colour attributes
;  ___ ___ ___ ___ ___ ___ ___ ___  system variable.
; ATTR_T  | | | | | | | | |
; | | | | | | | | |
; 23695 |___|___|___|___|___|___|___|___|
; 7 6 5 4 3 2 1 0
;
;
; {fl}{br}{ paper }{  ink  }  The temporary mask used for
;  ___ ___ ___ ___ ___ ___ ___ ___  transparent colours. Any bit
; MASK_T  | | | | | | | | | that is 1 shows that the
; | | | | | | | | | corresponding attribute is
; 23696 |___|___|___|___|___|___|___|___| taken not from ATTR-T but from
; 7 6 5 4 3 2 1 0 what is already on the screen.
;
;
; {paper9 }{ ink9 }{ inv1 }{ over1} The print flags. Even bits are
;  ___ ___ ___ ___ ___ ___ ___ ___  temporary flags. The odd bits
; P_FLAG  | | | | | | | | | are the permanent flags.
; | p | t | p | t | p | t | p | t |
; 23697 |___|___|___|___|___|___|___|___|
; 7 6 5 4 3 2 1 0
;
; -----------------------------------------------------------------------

; ------------------------------------
;  The colour system variable handler.
; ------------------------------------
; This is an exit branch from PO_1-OPER, PO_2-OPER
; A holds control $10 (INK) to $15 (OVER)
; D holds parameter 0-9 for ink/paper 0,1 or 8 for bright/flash,
; 0 or 1 for over/inverse.

	ORG	$2211
CO_TEMP_5:  SUB $11 ; reduce range $FF-$04
  ADC A,$00 ; add in carry if INK
  JR  Z,L2234 ; forward to CO-TEMP-7 with INK and PAPER.

  SUB $02 ; reduce range $FF-$02
  ADC A,$00 ; add carry if FLASH
  JR  Z,L2273 ; forward to CO-TEMP-C with FLASH and BRIGHT.

  CP  $01 ; is it 'INVERSE' ?
  LD  A,D ; fetch parameter for INVERSE/OVER
  LD  B,$01 ; prepare OVER mask setting bit 0.
  JR  NZ,L2228  ; forward to CO-TEMP-6 if OVER

  RLCA  ; shift bit 0
  RLCA  ; to bit 2
  LD  B,$04 ; set bit 2 of mask for inverse.

	ORG	$2228
;; CO-TEMP-6
L2228:  LD  C,A ; save the A
  LD  A,D ; re-fetch parameter
  CP  $02 ; is it less than 2
  JR  NC,REPORT_K  ; to REPORT-K if not 0 or 1.
  ; 'Bad colour'.

  LD  A,C ; restore A
  LD  HL,P_FLAG  ; address system variable P_FLAG
  JR  L226C ; forward to exit via routine CO-CHANGE

; ---

; the branch was here with INK/PAPER and carry set for INK.

	ORG	$2234
;; CO-TEMP-7
L2234:  LD  A,D ; fetch parameter
  LD  B,$07 ; set ink mask 00000111
  JR  C,L223E ; forward to CO-TEMP-8 with INK

  RLCA  ; shift bits 0-2
  RLCA  ; to
  RLCA  ; bits 3-5
  LD  B,$38 ; set paper mask 00111000

; both paper and ink rejoin here

	ORG	$223E
;; CO-TEMP-8
L223E:  LD  C,A ; value to C
  LD  A,D ; fetch parameter
  CP  $0A ; is it less than 10d ?
  JR  C,L2246 ; forward to CO-TEMP-9 if so.

; ink 10 etc. is not allowed.

	ORG	$2244
REPORT_K:
	RST	08H		; ERROR-1
  DEFB  $13 ; Error Report: Bad colour

	ORG	$2246
;; CO-TEMP-9
L2246:  LD  HL,ATTR_T  ; address system variable ATTR_T initially.
  CP  $08 ; compare with 8
  JR  C,L2258 ; forward to CO-TEMP-B with 0-7.

  LD  A,(HL)  ; fetch temporary attribute as no change.
  JR  Z,L2257 ; forward to CO-TEMP-A with INK/PAPER 8

; it is either ink 9 or paper 9 (contrasting)

  OR  B ; or with mask to make white
  CPL ; make black and change other to dark
  AND $24 ; 00100100
  JR  Z,L2257 ; forward to CO-TEMP-A if black and
  ; originally light.

  LD  A,B ; else just use the mask (white)

	ORG	$2257
;; CO-TEMP-A
L2257:  LD  C,A ; save A in C

	ORG	$2258
;; CO-TEMP-B
L2258:  LD  A,C ; load colour to A
  CALL  L226C ; routine CO-CHANGE addressing ATTR-T

  LD  A,$07 ; put 7 in accumulator
  CP  D ; compare with parameter
  SBC A,A ; $00 if 0-7, $FF if 8
  CALL  L226C ; routine CO-CHANGE addressing MASK-T
  ; mask returned in A.

; now consider P-FLAG.

  RLCA  ; 01110000 or 00001110
  RLCA  ; 11100000 or 00011100
  AND $50 ; 01000000 or 00010000  (AND 01010000)
  LD  B,A ; transfer to mask
  LD  A,$08 ; load A with 8
  CP  D ; compare with parameter
  SBC A,A ; $FF if was 9,  $00 if 0-8
  ; continue while addressing P-FLAG
  ; setting bit 4 if ink 9
  ; setting bit 6 if paper 9

; -----------------------
; Handle change of colour
; -----------------------
; This routine addresses a system variable ATTR_T, MASK_T or P-FLAG in HL.
; colour value in A, mask in B.

	ORG	$226C
;; CO-CHANGE
L226C:  XOR (HL)  ; impress bits specified
  AND B ; by mask
  XOR (HL)  ; on system variable.
  LD  (HL),A  ; update system variable.
  INC HL  ; address next location.
  LD  A,B ; put current value of mask in A
  RET ; return.

; ---

; the branch was here with flash and bright

	ORG	$2273
;; CO-TEMP-C
L2273:  SBC A,A ; set zero flag for bright.
  LD  A,D ; fetch original parameter 0,1 or 8
  RRCA  ; rotate bit 0 to bit 7
  LD  B,$80 ; mask for flash 10000000
  JR  NZ,L227D  ; forward to CO-TEMP-D if flash

  RRCA  ; rotate bit 7 to bit 6
  LD  B,$40 ; mask for bright 01000000

	ORG	$227D
;; CO-TEMP-D
L227D:  LD  C,A ; store value in C
  LD  A,D ; fetch parameter
  CP  $08 ; compare with 8
  JR  Z,L2287 ; forward to CO-TEMP-E if 8

  CP  $02 ; test if 0 or 1
  JR  NC,REPORT_K  ; back to REPORT-K if not
  ; 'Bad colour'

	ORG	$2287
;; CO-TEMP-E
L2287:  LD  A,C ; value to A
  LD  HL,ATTR_T  ; address ATTR_T
  CALL  L226C ; routine CO-CHANGE addressing ATTR_T
  LD  A,C ; fetch value
  RRCA  ; for flash8/bright8 complete
  RRCA  ; rotations to put set bit in
  RRCA  ; bit 7 (flash) bit 6 (bright)
  JR  L226C ; back to CO-CHANGE addressing MASK_T
  ; and indirect return.

; --------------------
; THE 'BORDER' COMMAND
; --------------------
; Command syntax example: BORDER 7
; This command routine sets the border to one of the eight colours.
; The colours used for the lower screen are based on this.

	ORG	$2294
BORDER:  CALL  FIND_INT1 ; routine FIND-INT1

  CP  $08 ; must be in range 0 (black) to 7 (white)
  JR  NC,REPORT_K  ; back to REPORT-K if not
  ; 'Bad colour'.

; Note. The next location is called from the Opus Discovery disk interface.

x229B:  OUT ($FE),A ; outputting to port effects an immediate change

  RLCA  ; shift the colour to
  RLCA  ; the paper bits setting the
  RLCA  ; ink colour black.

  BIT 5,A ; is the number light coloured ?
  ; i.e. in the range green to white.
  JR  NZ,L22A6  ; skip to BORDER-1 if so

  XOR $07 ; make the ink white.

	ORG	$22A6
;; BORDER-1
L22A6:  LD  (BORDCR),A ; update BORDCR with new paper/ink
  RET ; return.

; -----------------
; Get pixel address
; -----------------
;
;

	ORG	$22AA
;; PIXEL-ADD
L22AA:  LD  A,$AF ; load with 175 decimal.
  SUB B ; subtract the y value.
  JP  C,REPORT_Bc ; jump forward to REPORT-Bc if greater.
  ; 'Out of range'

; the high byte is derived from Y only.
; the first 3 bits are always 010
; the next 2 bits denote in which third of the screen the byte is.
; the last 3 bits denote in which of the 8 scan lines within a third
; the byte is located. There are 24 discrete values.


  LD  B,A ; the line number from top of screen to B.
  AND A ; clear carry (already clear)
  RRA ; 0xxxxxxx
  SCF ; set carry flag
  RRA ; 10xxxxxx
  AND A ; clear carry flag
  RRA ; 010xxxxx

  XOR B ;
  AND $F8 ; keep the top 5 bits 11111000
  XOR B ; 010xxbbb
  LD  H,A ; transfer high byte to H.

; the low byte is derived from both X and Y.

  LD  A,C ; the x value 0-255.
  RLCA  ;
  RLCA  ;
  RLCA  ;
  XOR B ; the y value
  AND $C7 ; apply mask 11000111
  XOR B ; restore unmasked bits  xxyyyxxx
  RLCA  ; rotate to  xyyyxxxx
  RLCA  ; required position. yyyxxxxx
  LD  L,A ; low byte to L.

; finally form the pixel position in A.

  LD  A,C ; x value to A
  AND $07 ; mod 8
  RET ; return

; ----------------
; Point Subroutine
; ----------------
; The point subroutine is called from s-point via the scanning functions
; table.

	ORG	$22CB
;; POINT-SUB
L22CB:
;;; CALL  STK_TO_BC ; routine STK-TO-BC

  CALL  BC_POSTVE ;+

  CALL  L22AA ; routine PIXEL-ADD finds address of pixel.
  LD  B,A ; pixel position to B, 0-7.
  INC B ; increment to give rotation count 1-8.
  LD  A,(HL)  ; fetch byte from screen.

	ORG	$22D4
;; POINT-LP
L22D4:  RLCA  ; rotate and loop back
  DJNZ  L22D4 ; to POINT-LP until pixel at right.

  AND  $01  ; test to give zero or one.
  JP  STACK_A ; jump forward to STACK-A to save result.

; ------------------
; THE 'PLOT' COMMAND
; ------------------
; Command Syntax example: PLOT 128,88
;

	ORG	$22DC
PLOT:
;;; CALL  STK_TO_BC ; routine STK-TO-BC
  CALL  BC_POSTVE ;+

  CALL  L22E5 ; routine PLOT-SUB
  JP  TEMPS ; to TEMPS

; -------------------
; The Plot subroutine
; -------------------
; A screen byte holds 8 pixels so it is necessary to rotate a mask
; into the correct position to leave the other 7 pixels unaffected.
; However all 64 pixels in the character cell take any embedded colour
; items.
; A pixel can be reset (inverse 1), toggled (over 1), or set ( with inverse
; and over switches off). With both switches on, the byte is simply put
; back on the screen though the colours may change.

	ORG	$22E5
;; PLOT-SUB
L22E5:  LD  ($5C7D),BC  ; store new x/y values in COORDS
  CALL  L22AA ; routine PIXEL-ADD gets address in HL,
  ; count from left 0-7 in B.
  LD  B,A ; transfer count to B.
  INC B ; increase 1-8.
  LD  A,$FE ; 11111110 in A.

	ORG	$22F0
;; PLOT-LOOP
L22F0:  RRCA  ; rotate mask.
  DJNZ  L22F0 ; to PLOT-LOOP until B circular rotations.

  LD  B,A ; load mask to B
  LD  A,(HL)  ; fetch screen byte to A

  LD  C,(IY+$57)  ; P_FLAG to C
  BIT 0,C ; is it to be OVER 1 ?
  JR  NZ,L22FD  ; forward to PL-TST-IN if so.

; was over 0

  AND B ; combine with mask to blank pixel.

	ORG	$22FD
;; PL-TST-IN
L22FD:  BIT 2,C ; is it inverse 1 ?
  JR  NZ,L2303  ; to PLOT-END if so.

  XOR B ; switch the pixel
  CPL ; restore other 7 bits

	ORG	$2303
;; PLOT-END
L2303:  LD  (HL),A  ; load byte to the screen.
  JP  PO_ATTR ; exit to PO_ATTR to set colours for cell.

; ------------------------------
; Put two numbers in BC register
; ------------------------------
;
;

	ORG	$2307
STK_TO_BC:  CALL  L2314 ; routine STK-TO-A
  LD  B,A ;
  PUSH  BC  ;
  CALL  L2314 ; routine STK-TO-A
  LD  E,C ;
  POP BC  ;
  LD  D,C ;
  LD  C,A ;
  RET ;

; -----------------------
; Put stack in A register
; -----------------------
; This routine puts the last value on the calculator stack into the accumulator
; deleting the last value.

	ORG	$2314
;; STK-TO-A
L2314:  CALL  FP_TO_A ; routine FP-TO-A compresses last value into
  ; accumulator. e.g. PI would become 3.
  ; zero flag set if positive.
  JP  C,REPORT_Bc ; jump forward to REPORT-Bc if >= 255.5.

  LD  C,$01 ; prepare a positive sign byte.
  RET Z ; return if FP-TO-BC indicated positive.

  LD  C,$FF ; prepare negative sign byte and
  RET ; return.


; --------------------
; THE 'CIRCLE' COMMAND
; --------------------
; "Goe not Thou about to Square eyther circle" -
; - John Donne, Cambridge educated theologian, 1624
;
; The CIRCLE command draws a circle as a series of straight lines.
; In some ways it can be regarded as a polygon, but the first line is drawn
; as a tangent, taking the radius as its distance from the centre.
;
; Both the CIRCLE algorithm and the ARC drawing algorithm make use of the
; 'ROTATION FORMULA' (see later).  It is only necessary to work out where
; the first line will be drawn and how long it is and then the rotation
; formula takes over and calculates all other rotated points.
;
; All Spectrum circles consist of two vertical lines at each side and two
; horizontal lines at the top and bottom. The number of lines is calculated
; from the radius of the circle and is always divisible by 4. For complete
; circles it will range from 4 for a square circle to 32 for a circle of
; radius 87. The Spectrum can attempt larger circles e.g. CIRCLE 0,14,255
; but these will error as they go off-screen after four lines are drawn.
; At the opposite end, CIRCLE 128,88,1.23 will draw a circle as a perfect 3x3
; square using 4 straight lines although very small circles are just drawn as
; a dot on the screen.
;
; The first chord drawn is the vertical chord on the right of the circle.
; The starting point is at the base of this chord which is drawn upwards and
; the circle continues in an anti-clockwise direction. As noted earlier the
; x-coordinate of this point measured from the centre of the circle is the
; radius.
;
; The CIRCLE command makes extensive use of the calculator and as part of
; process of drawing a large circle, free memory is checked 1315 times.
; When drawing a large arc, free memory is checked 928 times.
; A single call to 'sin' involves 63 memory checks and so values of sine
; and cosine are pre-calculated and held in the mem locations. As a
; clever trick 'cos' is derived from 'sin' using simple arithmetic operations
; instead of the more expensive 'cos' function.
;
; Initially, the syntax has been partly checked using the class for the DRAW
; command which stacks the origin of the circle (X,Y).

	ORG	$2320
CIRCLE:  RST 18H ; GET_CHAR  x, y.
  CP  $2C ; Is character the required comma ?
  JP  NZ,REPORT_C  ; Jump, if not, to REPORT-C
  ; 'Nonsense in basic'

  RST 20H ; NEXT_CHAR advances the parsed character address.
  CALL  EXPT_1NUM ; routine EXPT-1NUM stacks radius in runtime.
  CALL  CHECK_END ; routine CHECK-END will return here in runtime
  ; if nothing follows the command.

; Now make the radius positive and ensure that it is in floating point form
; so that the exponent byte can be accessed for quick testing.

  RST 28H ;; FP_CALC  x, y, r.
  DEFB  $2A ;;abs x, y, r.
  DEFB  $3D ;;re-stack  x, y, r.
  DEFB  $38 ;;end-calc  x, y, r.

  LD  A,(HL)  ; Fetch first, floating-point, exponent byte.
  CP  $81 ; Compare to one.
  JR  NC,L233B  ; Forward to C-R-GRE-1
  ; if circle radius is greater than one.

;  The circle is no larger than a single pixel so delete the radius from the
;  calculator stack and plot a point at the centre.

  RST 28H ;; FP_CALC  x, y, r.
  DEFB  $02 ;;delete  x, y.
  DEFB  $38 ;;end-calc  x, y.

  JR  PLOT ; back to PLOT routine to just plot x,y.

; ---

; Continue when the circle's radius measures greater than one by forming
; the angle 2 * PI radians which is 360 degrees.

	ORG	$233B
;; C-R-GRE-1
L233B:  RST 28H ;; FP_CALC  x, y, r
  DEFB  $A3 ;;stk-pi/2  x, y, r, pi/2.
  DEFB  $38 ;;end-calc  x, y, r, pi/2.

; Change the exponent of pi/2 from $81 to $83 giving 2*PI the central angle.
; This is quicker than multiplying by four.

  LD  (HL),$83  ; x, y, r, 2*PI.

; Now store this important constant in mem-5 and delete so that other
; parameters can be derived from it, by a routine shared with DRAW.

  RST 28H ;; FP_CALC  x, y, r, 2*PI.
  DEFB  $C5 ;;st-mem-5  store 2*PI in mem-5
  DEFB  $02 ;;delete  x, y, r.
  DEFB  $38 ;;end-calc  x, y, r.

; The parameters derived from mem-5 (A) and from the radius are set up in
; four of the other mem locations by the CIRCLE DRAW PARAMETERS routine which
; also returns the number of straight lines in the B register.

  CALL  L247D ; routine CD-PRMS1

  ; mem-0 ; A/No of lines (=a)  unused
  ; mem-1 ; sin(a/2)  will be moving x  var
  ; mem-2 ; - will be moving y  var
  ; mem-3 ; cos(a)  const
  ; mem-4 ; sin(a)  const
  ; mem-5 ; Angle of rotation (A) (2*PI)  const
  ; B ; Number of straight lines.

  PUSH  BC  ; Preserve the number of lines in B.

; Next calculate the length of half a chord by multiplying the sine of half
; the central angle by the radius of the circle.

  RST 28H ;; FP_CALC  x, y, r.
  DEFB  $31 ;;duplicate x, y, r, r.
  DEFB  $E1 ;;get-mem-1 x, y, r, r, sin(a/2).
  DEFB  $04 ;;multiply  x, y, r, half-chord.
  DEFB  $38 ;;end-calc  x, y, r, half-chord.

  LD  A,(HL)  ; fetch exponent  of the half arc to A.
  CP  $80 ; compare to a half pixel
  JR  NC,L235A  ; forward, if greater than .5, to C-ARC-GE1

; If the first line is less than .5 then 4 'lines' would be drawn on the same
; spot so tidy the calculator stack and machine stack and plot the centre.

  RST 28H ;; FP_CALC  x, y, r, hc.
  DEFB  $02 ;;delete  x, y, r.
  DEFB  $02 ;;delete  x, y.
  DEFB  $38 ;;end-calc  x, y.

  POP BC  ; Balance machine stack by taking chord-count.

  JP  PLOT ; JUMP to PLOT

; ---

; The arc is greater than 0.5 so the circle can be drawn.

	ORG	$235A
;; C-ARC-GE1
L235A:  RST 28H ;; FP_CALC  x, y, r, hc.
  DEFB  $C2 ;;st-mem-2  x, y, r, half chord to mem-2.
  DEFB  $01 ;;exchange  x, y, hc, r.
  DEFB  $C0 ;;st-mem-0  x, y, hc, r.
  DEFB  $02 ;;delete  x, y, hc.

; Subtract the length of the half-chord from the absolute y coordinate to
; give the starting y coordinate sy.
; Note that for a circle this is also the end coordinate.

  DEFB  $03 ;;subtract  x, y-hc.  (The start y-coord)
  DEFB  $01 ;;exchange  sy, x.

; Next simply add the radius to the x coordinate to give a fuzzy x-coordinate.
; Strictly speaking, the radius should be multiplied by cos(a/2) first but
; doing it this way makes the circle slightly larger.

  DEFB  $E0 ;;get-mem-0 sy, x, r.
  DEFB  $0F ;;addition  sy, x+r.  (The start x-coord)

; We now want three copies of this pair of values on the calculator stack.
; The first pair remain on the stack throughout the circle routine and are
; the end points. The next pair will be the moving absolute values of x and y
; that are updated after each line is drawn. The final pair will be loaded
; into the COORDS system variable so that the first vertical line starts at
; the right place.

  DEFB  $C0 ;;st-mem-0  sy, sx.
  DEFB  $01 ;;exchange  sx, sy.
  DEFB  $31 ;;duplicate sx, sy, sy.
  DEFB  $E0 ;;get-mem-0 sx, sy, sy, sx.
  DEFB  $01 ;;exchange  sx, sy, sx, sy.
  DEFB  $31 ;;duplicate sx, sy, sx, sy, sy.
  DEFB  $E0 ;;get-mem-0 sx, sy, sx, sy, sy, sx.

; Locations mem-1 and mem-2 are the relative x and y values which are updated
; after each line is drawn. Since we are drawing a vertical line then the rx
; value in mem-1 is zero and the ry value in mem-2 is the full chord.

  DEFB  $A0 ;;stk-zero  sx, sy, sx, sy, sy, sx, 0.
  DEFB  $C1 ;;st-mem-1  sx, sy, sx, sy, sy, sx, 0.
  DEFB  $02 ;;delete  sx, sy, sx, sy, sy, sx.

; Although the three pairs of x/y values are the same for a circle, they
; will be labelled terminating, absolute and start coordinates.

  DEFB  $38 ;;end-calc  tx, ty, ax, ay, sy, sx.

; Use the exponent manipulating trick again to double the value of mem-2.

  INC (IY+$62)  ; Increment MEM-2-1st doubling half chord.

; Note. this first vertical chord is drawn at the radius so circles are
; slightly displaced to the right.
; It is only necessary to place the values (sx) and (sy) in the system
; variable COORDS to ensure that drawing commences at the correct pixel.
; Note. a couple of LD (COORDS),A instructions would have been quicker, and
; simpler, than using LD (COORDS),HL.

  CALL  FIND_INT1 ; routine FIND-INT1 fetches sx from stack to A.

  LD  L,A ; place X value in L.
  PUSH  HL  ; save the holding register.

  CALL  FIND_INT1 ; routine FIND-INT1 fetches sy to A

  POP HL  ; restore the holding register.
  LD  H,A ; and place y value in high byte.

  LD  ($5C7D),HL  ; Update the COORDS system variable.
  ;
  ; tx, ty, ax, ay.

  POP BC  ; restore the chord count
  ; values 4,8,12,16,20,24,28 or 32.

  JP  L2420 ; forward to DRW-STEPS
  ; tx, ty, ax, ay.

; Note. the jump to DRW-STEPS is just to decrement B and jump into the
; middle of the arc-drawing loop. The arc count which includes the first
; vertical arc draws one less than the perceived number of arcs.
; The final arc offsets are obtained by subtracting the final COORDS value
; from the initial sx and sy values which are kept at the base of the
; calculator stack throughout the arc loop.
; This ensures that the final line finishes exactly at the starting pixel
; removing the possibility of any inaccuracy.
; Since the initial sx and sy values are not required until the final arc
; is drawn, they are not shown until then.
; As the calculator stack is quite busy, only the active parts are shown in
; each section.


; ------------------
; THE 'DRAW' COMMAND
; ------------------
; The Spectrum's DRAW command is overloaded and can take two parameters sets.
;
; With two parameters, it simply draws an approximation to a straight line
; at offset x,y using the LINE-DRAW routine.
;
; With three parameters, an arc is drawn to the point at offset x,y turning
; through an angle, in radians, supplied by the third parameter.
; The arc will consist of 4 to 252 straight lines each one of which is drawn
; by calls to the DRAW-LINE routine.

	ORG	$2382
DRAW:  RST 18H ; GET_CHAR
  CP  $2C ; is it the comma character ?
  JR  Z,L238D ; forward, if so, to DR-3-PRMS

; There are two parameters e.g. DRAW 255,175

  CALL  CHECK_END ; routine CHECK-END

  JP  L2477 ; jump forward to LINE-DRAW

; ---

;  There are three parameters e.g. DRAW 255, 175, .5
;  The first two are relative coordinates and the third is the angle of
;  rotation in radians (A).

	ORG	$238D
;; DR-3-PRMS
L238D:  RST 20H ; NEXT_CHAR skips over the 'comma'.

  CALL  EXPT_1NUM ; routine EXPT-1NUM stacks the rotation angle.

  CALL  CHECK_END ; routine CHECK-END

; Now enter the calculator and store the complete rotation angle in mem-5

  RST 28H ;; FP_CALC  x, y, A.
  DEFB  $C5 ;;st-mem-5  x, y, A.

; Test the angle for the special case of 360 degrees.

  DEFB  $A2 ;;stk-half  x, y, A, 1/2.
  DEFB  $04 ;;multiply  x, y, A/2.
  DEFB  $1F ;;sin x, y, sin(A/2).
  DEFB  $31 ;;duplicate x, y, sin(A/2),sin(A/2)
  DEFB  $30 ;;not x, y, sin(A/2), (0/1).
  DEFB  $30 ;;not x, y, sin(A/2), (1/0).
  DEFB  $00 ;;jump-true x, y, sin(A/2).

  DEFB  $06 ;;forward to L23A3, DR-SIN-NZ
  ; if sin(r/2) is not zero.

; The third parameter is 2*PI (or a multiple of 2*PI) so a 360 degrees turn
; would just be a straight line.  Eliminating this case here prevents
; division by zero at later stage.

  DEFB  $02 ;;delete  x, y.
  DEFB  $38 ;;end-calc  x, y.

  JP  L2477 ; forward to LINE-DRAW

; ---

; An arc can be drawn.

	ORG	$23A3
;; DR-SIN-NZ
L23A3:  DEFB  $C0 ;;st-mem-0  x, y, sin(A/2). store mem-0
  DEFB  $02 ;;delete  x, y.

; The next step calculates (roughly) the diameter of the circle of which the
; arc will form part.  This value does not have to be too accurate as it is
; only used to evaluate the number of straight lines and then discarded.
; After all for a circle, the radius is used. Consequently, a circle of
; radius 50 will have 24 straight lines but an arc of radius 50 will have 20
; straight lines - when drawn in any direction.
; So that simple arithmetic can be used, the length of the chord can be
; calculated as X+Y rather than by Pythagoras Theorem and the sine of the
; nearest angle within reach is used.

  DEFB  $C1 ;;st-mem-1  x, y. store mem-1
  DEFB  $02 ;;delete  x.

  DEFB  $31 ;;duplicate x, x.
  DEFB  $2A ;;abs x, x (+ve).
  DEFB  $E1 ;;get-mem-1 x, X, y.
  DEFB  $01 ;;exchange  x, y, X.
  DEFB  $E1 ;;get-mem-1 x, y, X, y.
  DEFB  $2A ;;abs x, y, X, Y (+ve).
  DEFB  $0F ;;addition  x, y, X+Y.
  DEFB  $E0 ;;get-mem-0 x, y, X+Y, sin(A/2).
  DEFB  $05 ;;division  x, y, X+Y/sin(A/2).
  DEFB  $2A ;;abs x, y, X+Y/sin(A/2) = D.

;  Bring back sin(A/2) from mem-0 which will shortly get trashed.
;  Then bring D to the top of the stack again.

  DEFB  $E0 ;;get-mem-0 x, y, D, sin(A/2).
  DEFB  $01 ;;exchange  x, y, sin(A/2), D.

; Note. that since the value at the top of the stack has arisen as a result
; of division then it can no longer be in integer form and the next re-stack
; is unnecessary. Only the Sinclair ZX80 had integer division.

  DEFB  $3D ;;re-stack  (unnecessary)

  DEFB  $38 ;;end-calc  x, y, sin(A/2), D.

; The next test avoids drawing 4 straight lines when the start and end pixels
; are adjacent (or the same) but is probably best dispensed with.

  LD  A,(HL)  ; fetch exponent byte of D.
  CP  $81 ; compare to 1
  JR  NC,L23C1  ; forward, if > 1,  to DR-PRMS

; else delete the top two stack values and draw a simple straight line.

  RST 28H ;; FP_CALC
  DEFB  $02 ;;delete
  DEFB  $02 ;;delete
  DEFB  $38 ;;end-calc  x, y.

  JP  L2477 ; to LINE-DRAW

; ---

; The ARC will consist of multiple straight lines so call the CIRCLE-DRAW
; PARAMETERS ROUTINE to pre-calculate sine values from the angle (in mem-5)
; and determine also the number of straight lines from that value and the
; 'diameter' which is at the top of the calculator stack.

	ORG	$23C1
;; DR-PRMS
L23C1:  CALL  L247D ; routine CD-PRMS1

  ; mem-0 ; (A)/No. of lines (=a) (step angle)
  ; mem-1 ; sin(a/2)
  ; mem-2 ; -
  ; mem-3 ; cos(a)  const
  ; mem-4 ; sin(a)  const
  ; mem-5 ; Angle of rotation (A) in
  ; B ; Count of straight lines - max 252.

  PUSH  BC  ; Save the line count on the machine stack.

; Remove the now redundant diameter value D.

  RST 28H ;; FP_CALC  x, y, sin(A/2), D.
  DEFB  $02 ;;delete  x, y, sin(A/2).

; Dividing the sine of the step angle by the sine of the total angle gives
; the length of the initial chord on a unary circle. This factor f is used
; to scale the coordinates of the first line which still points in the
; direction of the end point and may be larger.

  DEFB  $E1 ;;get-mem-1 x, y, sin(A/2), sin(a/2)
  DEFB  $01 ;;exchange  x, y, sin(a/2), sin(A/2)
  DEFB  $05 ;;division  x, y, sin(a/2)/sin(A/2)
  DEFB  $C1 ;;st-mem-1  x, y. f.
  DEFB  $02 ;;delete  x, y.

; With the factor stored, scale the x coordinate first.

  DEFB  $01 ;;exchange  y, x.
  DEFB  $31 ;;duplicate y, x, x.
  DEFB  $E1 ;;get-mem-1 y, x, x, f.
  DEFB  $04 ;;multiply  y, x, x*f  (=xx)
  DEFB  $C2 ;;st-mem-2  y, x, xx.
  DEFB  $02 ;;delete  y. x.

; Now scale the y coordinate.

  DEFB  $01 ;;exchange  x, y.
  DEFB  $31 ;;duplicate x, y, y.
  DEFB  $E1 ;;get-mem-1 x, y, y, f
  DEFB  $04 ;;multiply  x, y, y*f  (=yy)

; Note. 'sin' and 'cos' trash locations mem-0 to mem-2 so fetch mem-2 to the
; calculator stack for safe keeping.

  DEFB  $E2 ;;get-mem-2 x, y, yy, xx.

; Once we get the coordinates of the first straight line then the 'ROTATION
; FORMULA' used in the arc loop will take care of all other points, but we
; now use a variation of that formula to rotate the first arc through (A-a)/2
; radians.
;
; xRotated = y * sin(angle) + x * cos(angle)
; yRotated = y * cos(angle) - x * sin(angle)
;

  DEFB  $E5 ;;get-mem-5 x, y, yy, xx, A.
  DEFB  $E0 ;;get-mem-0 x, y, yy, xx, A, a.
  DEFB  $03 ;;subtract  x, y, yy, xx, A-a.
  DEFB  $A2 ;;stk-half  x, y, yy, xx, A-a, 1/2.
  DEFB  $04 ;;multiply  x, y, yy, xx, (A-a)/2. (=angle)
  DEFB  $31 ;;duplicate x, y, yy, xx, angle, angle.
  DEFB  $1F ;;sin x, y, yy, xx, angle, sin(angle)
  DEFB  $C5 ;;st-mem-5  x, y, yy, xx, angle, sin(angle)
  DEFB  $02 ;;delete  x, y, yy, xx, angle

  DEFB  $20 ;;cos x, y, yy, xx, cos(angle).

; Note. mem-0, mem-1 and mem-2 can be used again now...

  DEFB  $C0 ;;st-mem-0  x, y, yy, xx, cos(angle).
  DEFB  $02 ;;delete  x, y, yy, xx.

  DEFB  $C2 ;;st-mem-2  x, y, yy, xx.
  DEFB  $02 ;;delete  x, y, yy.

  DEFB  $C1 ;;st-mem-1  x, y, yy.
  DEFB  $E5 ;;get-mem-5 x, y, yy, sin(angle)
  DEFB  $04 ;;multiply  x, y, yy*sin(angle).
  DEFB  $E0 ;;get-mem-0 x, y, yy*sin(angle), cos(angle)
  DEFB  $E2 ;;get-mem-2 x, y, yy*sin(angle), cos(angle), xx.
  DEFB  $04 ;;multiply  x, y, yy*sin(angle), xx*cos(angle).
  DEFB  $0F ;;addition  x, y, xRotated.
  DEFB  $E1 ;;get-mem-1 x, y, xRotated, yy.
  DEFB  $01 ;;exchange  x, y, yy, xRotated.
  DEFB  $C1 ;;st-mem-1  x, y, yy, xRotated.
  DEFB  $02 ;;delete  x, y, yy.

  DEFB  $E0 ;;get-mem-0 x, y, yy, cos(angle).
  DEFB  $04 ;;multiply  x, y, yy*cos(angle).
  DEFB  $E2 ;;get-mem-2 x, y, yy*cos(angle), xx.
  DEFB  $E5 ;;get-mem-5 x, y, yy*cos(angle), xx, sin(angle).
  DEFB  $04 ;;multiply  x, y, yy*cos(angle), xx*sin(angle).
  DEFB  $03 ;;subtract  x, y, yRotated.
  DEFB  $C2 ;;st-mem-2  x, y, yRotated.

; Now the initial x and y coordinates are made positive and summed to see
; if they measure up to anything significant.

  DEFB  $2A ;;abs x, y, yRotated'.
  DEFB  $E1 ;;get-mem-1 x, y, yRotated', xRotated.
  DEFB  $2A ;;abs x, y, yRotated', xRotated'.
  DEFB  $0F ;;addition  x, y, yRotated+xRotated.
  DEFB  $02 ;;delete  x, y.

  DEFB  $38 ;;end-calc  x, y.

; Although the test value has been deleted it is still above the calculator
; stack in memory and conveniently DE which points to the first free byte
; addresses the exponent of the test value.

  LD  A,(DE)  ; Fetch exponent of the length indicator.
  CP  $81 ; Compare to that for 1

  POP BC  ; Balance the machine stack

  JP  C,L2477 ; forward, if the coordinates of first line
  ; don't add up to more than 1, to LINE-DRAW

; Continue when the arc will have a discernable shape.

  PUSH  BC  ; Restore line counter to the machine stack.

; The parameters of the DRAW command were relative and they are now converted
; to absolute coordinates by adding to the coordinates of the last point
; plotted. The first two values on the stack are the terminal tx and ty
; coordinates.  The x-coordinate is converted first but first the last point
; plotted is saved as it will initialize the moving ax, value.

  RST 28H ;; FP_CALC  x, y.
  DEFB  $01 ;;exchange  y, x.
  DEFB  $38 ;;end-calc  y, x.

  LD  A,($5C7D) ; Fetch System Variable COORDS-x
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  y, x, last-x.

; Store the last point plotted to initialize the moving ax value.

  DEFB  $C0 ;;st-mem-0  y, x, last-x.
  DEFB  $0F ;;addition  y, absolute x.
  DEFB  $01 ;;exchange  tx, y.
  DEFB  $38 ;;end-calc  tx, y.

  LD  A,($5C7E) ; Fetch System Variable COORDS-y
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  tx, y, last-y.

; Store the last point plotted to initialize the moving ay value.

  DEFB  $C5 ;;st-mem-5  tx, y, last-y.
  DEFB  $0F ;;addition  tx, ty.

; Fetch the moving ax and ay to the calculator stack.

  DEFB  $E0 ;;get-mem-0 tx, ty, ax.
  DEFB  $E5 ;;get-mem-5 tx, ty, ax, ay.
  DEFB  $38 ;;end-calc  tx, ty, ax, ay.

  POP BC  ; Restore the straight line count.

; -----------------------------------
; THE 'CIRCLE/DRAW CONVERGENCE POINT'
; -----------------------------------
; The CIRCLE and ARC-DRAW commands converge here.
;
; Note. for both the CIRCLE and ARC commands the minimum initial line count
; is 4 (as set up by the CD_PARAMS routine) and so the zero flag will never
; be set and the loop is always entered.  The first test is superfluous and
; the jump will always be made to ARC-START.

	ORG	$2420
;; DRW-STEPS
L2420:  DEC B ; decrement the arc count (4,8,12,16...).

  JR  Z,L245F ; forward, if zero (not possible), to ARC-END

  JR  L2439 ; forward to ARC-START

; --------------
; THE 'ARC LOOP'
; --------------
;
; The arc drawing loop will draw up to 31 straight lines for a circle and up
; 251 straight lines for an arc between two points. In both cases the final
; closing straight line is drawn at ARC_END, but it otherwise loops back to
; here to calculate the next coordinate using the ROTATION FORMULA where (a)
; is the previously calculated, constant CENTRAL ANGLE of the arcs.
;
; Xrotated = x * cos(a) - y * sin(a)
; Yrotated = x * sin(a) + y * cos(a)
;
; The values cos(a) and sin(a) are pre-calculated and held in mem-3 and mem-4
; for the duration of the routine.
; Memory location mem-1 holds the last relative x value (rx) and mem-2 holds
; the last relative y value (ry) used by DRAW.
;
; Note. that this is a very clever twist on what is after all a very clever,
; well-used formula.  Normally the rotation formula is used with the x and y
; coordinates from the centre of the circle (or arc) and a supplied angle to
; produce two new x and y coordinates in an anticlockwise direction on the
; circumference of the circle.
; What is being used here, instead, is the relative X and Y parameters from
; the last point plotted that are required to get to the current point and
; the formula returns the next relative coordinates to use.

	ORG	$2425
;; ARC-LOOP
L2425:  RST 28H ;; FP_CALC
  DEFB  $E1 ;;get-mem-1 rx.
  DEFB  $31 ;;duplicate rx, rx.
  DEFB  $E3 ;;get-mem-3 cos(a)
  DEFB  $04 ;;multiply  rx, rx*cos(a).
  DEFB  $E2 ;;get-mem-2 rx, rx*cos(a), ry.
  DEFB  $E4 ;;get-mem-4 rx, rx*cos(a), ry, sin(a).
  DEFB  $04 ;;multiply  rx, rx*cos(a), ry*sin(a).
  DEFB  $03 ;;subtract  rx, rx*cos(a) - ry*sin(a)
  DEFB  $C1 ;;st-mem-1  rx, new relative x rotated.
  DEFB  $02 ;;delete  rx.

  DEFB  $E4 ;;get-mem-4 rx, sin(a).
  DEFB  $04 ;;multiply  rx*sin(a)
  DEFB  $E2 ;;get-mem-2 rx*sin(a), ry.
  DEFB  $E3 ;;get-mem-3 rx*sin(a), ry, cos(a).
  DEFB  $04 ;;multiply  rx*sin(a), ry*cos(a).
  DEFB  $0F ;;addition  rx*sin(a) + ry*cos(a).
  DEFB  $C2 ;;st-mem-2  new relative y rotated.
  DEFB  $02 ;;delete  .
  DEFB  $38 ;;end-calc  .

; Note. the calculator stack actually holds tx, ty, ax, ay
; and the last absolute values of x and y
; are now brought into play.
;
; Magically, the two new rotated coordinates rx and ry are all that we would
; require to draw a circle or arc - on paper!
; The Spectrum DRAW routine draws to the rounded x and y coordinate and so
; repetitions of values like 3.49 would mean that the fractional parts
; would be lost until eventually the draw coordinates might differ from the
; floating point values used above by several pixels.
; For this reason the accurate offsets calculated above are added to the
; accurate, absolute coordinates maintained in ax and ay and these new
; coordinates have the integer coordinates of the last plot position
; ( from System Variable COORDS ) subtracted from them to give the relative
; coordinates required by the DRAW routine.

; The mid entry point.

	ORG	$2439
;; ARC-START
L2439:  PUSH  BC  ; Preserve the arc counter on the machine stack.

; Store the absolute ay in temporary variable mem-0 for the moment.

  RST 28H ;; FP_CALC  ax, ay.
  DEFB  $C0 ;;st-mem-0  ax, ay.
  DEFB  $02 ;;delete  ax.

; Now add the fractional relative x coordinate to the fractional absolute
; x coordinate to obtain a new fractional x-coordinate.

  DEFB  $E1 ;;get-mem-1 ax, xr.
  DEFB  $0F ;;addition  ax+xr (= new ax).
  DEFB  $31 ;;duplicate ax, ax.
  DEFB  $38 ;;end-calc  ax, ax.

  LD  A,($5C7D) ; COORDS-x  last x  (integer ix 0-255)
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  ax, ax, ix.
  DEFB  $03 ;;subtract  ax, ax-ix  = relative DRAW Dx.

; Having calculated the x value for DRAW do the same for the y value.

  DEFB  $E0 ;;get-mem-0 ax, Dx, ay.
  DEFB  $E2 ;;get-mem-2 ax, Dx, ay, ry.
  DEFB  $0F ;;addition  ax, Dx, ay+ry (= new ay).
  DEFB  $C0 ;;st-mem-0  ax, Dx, ay.
  DEFB  $01 ;;exchange  ax, ay, Dx,
  DEFB  $E0 ;;get-mem-0 ax, ay, Dx, ay.
  DEFB  $38 ;;end-calc  ax, ay, Dx, ay.

  LD  A,($5C7E) ; COORDS-y  last y (integer iy 0-175)
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  ax, ay, Dx, ay, iy.
  DEFB  $03 ;;subtract  ax, ay, Dx, ay-iy ( = Dy).
  DEFB  $38 ;;end-calc  ax, ay, Dx, Dy.

  CALL  L24B7 ; Routine DRAW-LINE draws (Dx,Dy) relative to
  ; the last pixel plotted leaving absolute x
  ; and y on the calculator stack.
  ; ax, ay.

  POP BC  ; Restore the arc counter from the machine stack.

  DJNZ  L2425 ; Decrement and loop while > 0 to ARC-LOOP

; -------------
; THE 'ARC END'
; -------------

; To recap the full calculator stack is tx, ty, ax, ay.

; Just as one would do if drawing the curve on paper, the final line would
; be drawn by joining the last point plotted to the initial start point
; in the case of a CIRCLE or to the calculated end point in the case of
; an ARC.
; The moving absolute values of x and y are no longer required and they
; can be deleted to expose the closing coordinates.

	ORG	$245F
;; ARC-END
L245F:  RST 28H ;; FP_CALC  tx, ty, ax, ay.
  DEFB  $02 ;;delete  tx, ty, ax.
  DEFB  $02 ;;delete  tx, ty.
  DEFB  $01 ;;exchange  ty, tx.
  DEFB  $38 ;;end-calc  ty, tx.

; First calculate the relative x coordinate to the end-point.

  LD  A,($5C7D) ; COORDS-x
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  ty, tx, coords_x.
  DEFB  $03 ;;subtract  ty, rx.

; Next calculate the relative y coordinate to the end-point.

  DEFB  $01 ;;exchange  rx, ty.
  DEFB  $38 ;;end-calc  rx, ty.

  LD  A,($5C7E) ; COORDS-y
  CALL  STACK_A ; routine STACK-A

  RST 28H ;; FP_CALC  rx, ty, coords_y
  DEFB  $03 ;;subtract  rx, ry.
  DEFB  $38 ;;end-calc  rx, ry.

; Finally draw the last straight line.

	ORG	$2477
;; LINE-DRAW
L2477:  CALL  L24B7 ; routine DRAW-LINE draws to the relative
  ; coordinates (rx, ry).

  JP  TEMPS ; jump back and exit via TEMPS  >>>


; --------------------------------------------
; THE 'INITIAL CIRCLE/DRAW PARAMETERS' ROUTINE
; --------------------------------------------
; Begin by calculating the number of chords which will be returned in B.
; A rule of thumb is employed that uses a value z which for a circle is the
; radius and for an arc is the diameter with, as it happens, a pinch more if
; the arc is on a slope.
;
; NUMBER OF STRAIGHT LINES = ANGLE OF ROTATION * SQUARE ROOT ( Z ) / 2

	ORG	$247D
;; CD-PRMS1
L247D:  RST 28H ;; FP_CALC  z.
  DEFB  $31 ;;duplicate z, z.
  DEFB  $28 ;;sqr z, sqr(z).
  DEFB  $34 ;;stk-data  z, sqr(z), 2.
  DEFB  $32 ;;Exponent: $82, Bytes: 1
  DEFB  $00 ;;(+00,+00,+00)
  DEFB  $01 ;;exchange  z, 2, sqr(z).
  DEFB  $05 ;;division  z, 2/sqr(z).
  DEFB  $E5 ;;get-mem-5 z, 2/sqr(z), ANGLE.
  DEFB  $01 ;;exchange  z, ANGLE, 2/sqr (z)
  DEFB  $05 ;;division  z, ANGLE*sqr(z)/2 (= No. of lines)
  DEFB  $2A ;;abs (for arc only)
  DEFB  $38 ;;end-calc  z, number of lines.

;  As an example for a circle of radius 87 the number of lines will be 29.

  CALL  FP_TO_A ; routine FP-TO-A

;  The value is compressed into A register, no carry with valid circle.

  JR  C,L2495 ; forward, if over 256, to USE-252

;  now make a multiple of 4 e.g. 29 becomes 28

  AND $FC ; AND 252

;  Adding 4 could set carry for arc, for the circle example, 28 becomes 32.

  ADD A,$04 ; adding 4 could set carry if result is 256.

  JR  NC,L2497  ; forward if less than 256 to DRAW-SAVE

;  For an arc, a limit of 252 is imposed.

	ORG	$2495
;; USE-252
L2495:  LD  A,$FC ; Use a value of 252 (for arc).


; For both arcs and circles, constants derived from the central angle are
; stored in the 'mem' locations.  Some are not relevant for the circle.

	ORG	$2497
;; DRAW-SAVE
L2497:  PUSH  AF  ; Save the line count (A) on the machine stack.

  CALL  STACK_A ; Routine STACK-A stacks the modified count(A).

  RST 28H ;; FP_CALC  z, A.
  DEFB  $E5 ;;get-mem-5 z, A, ANGLE.
  DEFB  $01 ;;exchange  z, ANGLE, A.
  DEFB  $05 ;;division  z, ANGLE/A. (Angle/count = a)
  DEFB  $31 ;;duplicate z, a, a.

;  Note. that cos (a) could be formed here directly using 'cos' and stored in
;  mem-3 but that would spoil a good story and be slightly slower, as also
;  would using square roots to form cos (a) from sin (a).

  DEFB  $1F ;;sin z, a, sin(a)
  DEFB  $C4 ;;st-mem-4  z, a, sin(a)
  DEFB  $02 ;;delete  z, a.
  DEFB  $31 ;;duplicate z, a, a.
  DEFB  $A2 ;;stk-half  z, a, a, 1/2.
  DEFB  $04 ;;multiply  z, a, a/2.
  DEFB  $1F ;;sin z, a, sin(a/2).

; Note. after second sin, mem-0 and mem-1 become free.

  DEFB  $C1 ;;st-mem-1  z, a, sin(a/2).
  DEFB  $01 ;;exchange  z, sin(a/2), a.
  DEFB  $C0 ;;st-mem-0  z, sin(a/2), a.  (for arc only)

; Now form cos(a) from sin(a/2) using the 'DOUBLE ANGLE FORMULA'.

  DEFB  $02 ;;delete  z, sin(a/2).
  DEFB  $31 ;;duplicate z, sin(a/2), sin(a/2).
  DEFB  $04 ;;multiply  z, sin(a/2)*sin(a/2).
  DEFB  $31 ;;duplicate z, sin(a/2)*sin(a/2),
  ;; sin(a/2)*sin(a/2).
  DEFB  $0F ;;addition  z, 2*sin(a/2)*sin(a/2).
  DEFB  $A1 ;;stk-one z, 2*sin(a/2)*sin(a/2), 1.
  DEFB  $03 ;;subtract  z, 2*sin(a/2)*sin(a/2)-1.

  DEFB  $1B ;;negate  z, 1-2*sin(a/2)*sin(a/2).

  DEFB  $C3 ;;st-mem-3  z, cos(a).
  DEFB  $02 ;;delete  z.
  DEFB  $38 ;;end-calc  z.

; The radius/diameter is left on the calculator stack.

  POP BC  ; Restore the line count to the B register.

  RET ; Return.

; --------------------------
; THE 'DOUBLE ANGLE FORMULA'
; --------------------------
; This formula forms cos(a) from sin(a/2) using simple arithmetic.
;
; THE GEOMETRIC PROOF OF FORMULA cos (a) = 1 - 2 * sin(a/2) * sin(a/2)
;
;
;  A
;
;   . /|\
;   .  / | \
;  .  /  |  \
;   .  / |a/2\
;  .  /  |  \
; .  1 / | \
;  .  /  |  \
; .  / | \
;  .  /  |  \
; .  a/2 D / a  E|-+ \
;  B ---------------------/----------+-+--------\ C
;  <- 1 -><- 1 ->
;
; cos a = 1 - 2 * sin(a/2) * sin(a/2)
;
; The figure shows a right triangle that inscribes a circle of radius 1 with
; centre, or origin, D.  Line BC is the diameter of length 2 and A is a point
; on the circle. The periphery angle BAC is therefore a right angle by the
; Rule of Thales 640-546 B.C.
; Line AC is a chord touching two points on the circle and the angle at the
; centre is (a).
; Since the vertex of the largest triangle B touches the circle, the
; inscribed angle (a/2) is half the central angle (a).
; The cosine of (a) is the length DE as the hypotenuse is of length 1.
; This can also be expressed as 1-length CE.  Examining the triangle at the
; right, the top angle is also (a/2) as angle BAE and EBA add to give a right
; angle as do BAE and EAC.
; So cos (a) = 1 - AC * sin(a/2)
; Looking at the largest triangle, side AC can be expressed as
; AC = 2 * sin(a/2) and so combining these we get
; cos (a) = 1 - 2 * sin(a/2) * sin(a/2).
;
; --------------------------
; THE 'LINE DRAWING' ROUTINE
; --------------------------
;
;

	ORG	$24B7
;; DRAW-LINE
L24B7:  CALL  STK_TO_BC ; routine STK-TO-BC
  LD  A,C ;
  CP  B ;
  JR  NC,L24C4  ; to DL-X-GE-Y

  LD  L,C ;
  PUSH  DE  ;
  XOR A ;
  LD  E,A ;
  JR  L24CB ; to DL-LARGER

; ---

	ORG	$24C4
;; DL-X-GE-Y
L24C4:  OR  C ;
  RET Z ;

  LD  L,B ;
  LD  B,C ;
  PUSH  DE  ;
  LD  D,$00 ;

	ORG	$24CB
;; DL-LARGER
L24CB:  LD  H,B ;
  LD  A,B ;
  RRA ;

	ORG	$24CE
;; D-L-LOOP
L24CE:  ADD A,L ;
  JR  C,L24D4 ; to D-L-DIAG

  CP  H ;
  JR  C,L24DB ; to D-L-HR-VT

	ORG	$24D4
;; D-L-DIAG
L24D4:  SUB H ;
  LD  C,A ;
  EXX ;
  POP BC  ;
  PUSH  BC  ;
  JR  L24DF ; to D-L-STEP

; ---

	ORG	$24DB
;; D-L-HR-VT
L24DB:  LD  C,A ;
  PUSH  DE  ;
  EXX ;
  POP BC  ;

	ORG	$24DF
;; D-L-STEP
L24DF:  LD  HL,($5C7D)  ; COORDS
  LD  A,B ;
  ADD A,H ;
  LD  B,A ;
  LD  A,C ;
  INC A ;
  ADD A,L ;
  JR  C,D_L_RANGE ; to D-L-RANGE

  JR  Z,REPORT_Bc ; to REPORT-Bc


	ORG	$24EC
D_L_PLOT:  DEC A ;
  LD  C,A ;
  CALL  L22E5 ; routine PLOT-SUB
  EXX ;
  LD  A,C ;
  DJNZ  L24CE ; to D-L-LOOP

  POP DE  ;
  RET ;

; ---

	ORG	$24F7
D_L_RANGE:
	JR	Z,D_L_PLOT	;

	ORG	$24F9
REPORT_Bc:
	RST	08H		; ERROR_1
	DEFB	$0A		; Error Report: Out of range

;***********************************
;** Part 8. EXPRESSION EVALUATION **
;***********************************
;
; It is at this stage of the ROM that the Spectrum ceases altogether to be
; just a colourful novelty. One remarkable feature is that in all previous
; commands when the Spectrum is expecting a number or a string then an
; expression of the same type can be substituted ad infinitum.
; This is the routine that evaluates that expression.
; This is what causes 2 + 2 to give the answer 4.
; That is quite easy to understand. However you don't have to make it much
; more complex to start a remarkable juggling act.
; e.g. PRINT 2 * (VAL "2+2" + TAN 3)
; In fact, provided there is enough free RAM, the Spectrum can evaluate
; an expression of unlimited complexity.
; Apart from a couple of minor glitches, which you can now correct, the
; system is remarkably robust.

; ---------------------------------
; Scan expression or sub-expression
; ---------------------------------
; This subroutine is used to produce an evaluation result of the 'next expression'.

	ORG	$24FB
SCANNING:  RST 18H ; GET_CHAR
  LD  B,$00 ; priority marker zero is pushed on stack
  ; to signify end of expression when it is
  ; popped off again.
  PUSH  BC  ; put in on stack.
  ; and proceed to consider the first character
  ; of the expression.

	ORG	$24FF
;; S-LOOP-1
L24FF:  LD  C,A ; store the character while a look up is done.
  LD  HL,SCAN_FUNC  ; Address: scan-func
  CALL  INDEXER ; routine INDEXER is called to see if it is
  ; part of a limited range '+', '(', 'ATTR' etc.

  LD  A,C ; fetch the character back
  JP  NC,L2684  ; jump forward to S-ALPHNUM if not in primary
  ; operators and functions to consider in the
  ; first instance a digit or a variable and
  ; then anything else.  >>>

  LD  B,$00 ; but here if it was found in table so
  LD  C,(HL)  ; fetch offset from table and make B zero.
  ADD HL,BC ; add the offset to position found
  JP  (HL)  ; and jump to the routine e.g. S-BIN
  ; making an indirect exit from there.

; -------------------------------------------------------------------------
; The four service subroutines for routines in the scanning function table
; -------------------------------------------------------------------------

; PRINT """Hooray!"" he cried."

	ORG	$250F
;; S-QUOTE-S
L250F:  CALL  CH_ADD_P1 ; routine CH-ADD+1 points to next character
  ; and fetches that character.
  INC BC  ; increase length counter.
  CP  $0D ; is it carriage return ?
  ; inside a quote.
  JP  Z,REPORT_C ; jump back to REPORT-C if so.
  ; 'Syntax error'.

  CP  $22 ; is it a quote '"' ?
  JR  NZ,L250F  ; back to S-QUOTE-S if not for more.

  CALL  CH_ADD_P1 ; routine CH-ADD+1
  CP  $22 ; compare with possible adjacent quote
  RET ; return. with zero set if two together.

; ---

; This subroutine is used to get two coordinate expressions for the three
; functions SCREEN$, ATTR and POINT that have two fixed parameters and
; therefore require surrounding braces.

	ORG	$2522
;; S-2-COORD
L2522:  RST 20H ; NEXT_CHAR
  CP  $28 ; is it the opening '(' ?
  JR  NZ,L252D  ; forward to S-RPORT-C if not
  ; 'Syntax error'.

  CALL  NEXT_2NUM ; routine NEXT-2NUM gets two comma-separated
  ; numeric expressions. Note. this could cause
  ; many more recursive calls to SCANNING but
  ; the parent function will be evaluated fully
  ; before rejoining the main juggling act.

  RST 18H ; GET_CHAR
  CP  $29 ; is it the closing ')' ?

	ORG	$252D
;; S-RPORT-C
L252D:  JP  NZ,REPORT_C  ; jump back to REPORT-C if not.
  ; 'Syntax error'.

; ------------
; Check syntax
; ------------
; This routine is called on a number of occasions to check if syntax is being
; checked or if the program is being run. To test the flag inline would use
; four bytes of code, but a call instruction only uses 3 bytes of code.

	ORG	$2530
SYNTAX_Z:  BIT 7,(IY+$01)  ; test FLAGS  - checking syntax only ?
  RET ; return.

; ----------------
; Scanning SCREEN$
; ----------------
; This function returns the code of a bit-mapped character at screen
; position at line C, column B. It is unable to detect the mosaic characters
; which are not bit-mapped but detects the ASCII 32 - 127 range.
; The bit-mapped UDGs are ignored which is curious as it requires only a
; few extra bytes of code. As usual, anything to do with CHARS is weird.
; If no match is found a null string is returned.
; No actual check on ranges is performed - that's up to the BASIC programmer.
; No real harm can come from SCREEN$(255,255) although the BASIC manual
; says that invalid values will be trapped.
; Interestingly, in the Pitman pocket guide, 1984, Vickers says that the
; range checking will be performed.

	ORG	$2535
;; S-SCRN$-S
L2535:
;;; CALL  STK_TO_BC ; routine STK-TO-BC line to C, and column to B.
  CALL  STK_TO_LC ;+ as above but checks range

  LD  HL,(CHARS)  ; fetch address of CHARS.
  LD  DE,$0100  ; fetch offset to chr$ 32
  ADD HL,DE ; and find start of bitmaps.
  ; Note. not inc h. ??
  LD  A,C ; transfer line to A.
  RRCA  ; multiply
  RRCA  ; by
  RRCA  ; thirty-two.
  AND $E0 ; and with 11100000
  XOR B ; combine with column $00 - $1F
  LD  E,A ; to give the low byte of top line
  LD  A,C ; column to A range 00000000 to 00011111
  AND $18 ; and with 00011000
  XOR $40 ; xor with 01000000 (high byte screen start)
  LD  D,A ; register DE now holds start address of cell.
  LD  B,$60 ; there are 96 characters in ASCII set.

	ORG	$254F
;; S-SCRN-LP
L254F:  PUSH  BC  ; save count
  PUSH  DE  ; save screen start address
  PUSH  HL  ; save bitmap start
  LD  A,(DE)  ; first byte of screen to A
  XOR (HL)  ; xor with corresponding character byte
  JR  Z,L255A ; forward to S-SC-MTCH if they match
  ; if inverse result would be $FF
  ; if any other then mismatch

  INC A ; set to $00 if inverse
  JR  NZ,L2573  ; forward to S-SCR-NXT if a mismatch

  DEC A ; restore $FF

; a match has been found so seven more to test.

	ORG	$255A
;; S-SC-MTCH
L255A:  LD  C,A ; load C with inverse mask $00 or $FF
  LD  B,$07 ; count seven more bytes

	ORG	$255D
;; S-SC-ROWS
L255D:  INC D ; increment screen address.
  INC HL  ; increment bitmap address.
  LD  A,(DE)  ; byte to A
  XOR (HL)  ; will give $00 or $FF (inverse)
  XOR C ; xor with inverse mask
  JR  NZ,L2573  ; forward to S-SCR-NXT if no match.

  DJNZ  L255D ; back to S-SC-ROWS until all eight matched.

; continue if a match of all eight bytes was found

  POP BC  ; discard the
  POP BC  ; saved
  POP BC  ; pointers
  LD  A,$80 ; the endpoint of character set
  SUB B ; subtract the counter
  ; to give the code 32-127
  LD  BC,$0001  ; make one space in workspace.

  RST 30H ; BC_SPACES creates the space sliding
  ; the calculator stack upwards.
  LD  (DE),A  ; start is addressed by DE, so insert code
  JR  L257D ; forward to S-SCR-STO

; ---

; the jump was here if no match and more bitmaps to test.

	ORG	$2573
;; S-SCR-NXT
L2573:  POP HL  ; restore the last bitmap start
  LD  DE,$0008  ; and prepare to add 8.
  ADD HL,DE ; now addresses next character bitmap.
  POP DE  ; restore screen address
  POP BC  ; and character counter in B
  DJNZ  L254F ; back to S-SCRN-LP if more characters.

  LD  C,B ; B is now zero, so BC now zero.

	ORG	$257D
;; S-SCR-STO
L257D:
  RET ;+ Return see below.
  NOP ;+
  NOP ;+

;;; JP  STK_STO_STR ; to STK-STO-$ to store the string in
;;;   ; workspace or a string with zero length.
;;;   ; (value of DE doesn't matter in last case)

; Note. this exit seems correct but the general-purpose routine S-STRING
; that calls this one will also stack any of its string results so this
; leads to a double storing of the result in this case.
; The instruction at L257D should just be a RET.

; -------------
; Scanning ATTR
; -------------
; This function subroutine returns the attributes of a screen location -
; a numeric result.
; Again it's up to the BASIC programmer to supply valid values of line/column.

	ORG	$2580
;; S-ATTR-S
L2580:
;;; CALL  STK_TO_BC ; routine STK-TO-BC line to C, and column to B.
  CALL  STK_TO_LC ;+ as above but checks range

  LD  A,C ; line to A $00 - $17 (max 00010111)
  RRCA  ; rotate
  RRCA  ; bits
  RRCA  ; left.
  LD  C,A ; store in C as an intermediate value.

  AND $E0 ; pick up bits 11100000 ( was 00011100 )
  XOR B ; combine with column $00 - $1F
  LD  L,A ; low byte now correct.

  LD  A,C ; bring back intermediate result from C
  AND $03 ; mask to give correct third of
  ; screen $00 - $02
  XOR $58 ; combine with base address.
  LD  H,A ; high byte correct.
  LD  A,(HL)  ; pick up the colour attribute.
  JP  STACK_A ; forward to STACK-A to store result
  ; and make an indirect exit.

; -----------------------
; Scanning function table
; -----------------------
; This table is used by INDEXER routine to find the offsets to
; four operators and eight functions. e.g. $A8 is the token 'FN'.
; This table is used in the first instance for the first character of an
; expression or by a recursive call to SCANNING for the first character of
; any sub-expression. It eliminates functions that have no argument or
; functions that can have more than one argument and therefore require
; braces. By eliminating and dealing with these now it can later take a
; simplistic approach to all other functions and assume that they have
; one argument.
; Similarly by eliminating BIN and '.' now it is later able to assume that
; all numbers begin with a digit and that the presence of a number or
; variable can be detected by a call to ALPHANUM.
; By default all expressions are positive and the spurious '+' is eliminated
; now as in print +2. This should not be confused with the operator '+'.
; Note. this does allow a degree of nonsense to be accepted as in
; PRINT +"3 is the greatest.".
; An acquired programming skill is the ability to include brackets where
; they are not necessary.
; A bracket at the start of a sub-expression may be spurious or necessary
; to denote that the contained expression is to be evaluated as an entity.
; In either case this is dealt with by recursive calls to SCANNING.
; An expression that begins with a quote requires special treatment.

	ORG	$2596
SCAN_FUNC:
	DEFB	$22,S_QUOTE-$-1	; $1C offset
	DEFB	'(',S_BRACKET-$-1	; $4F offset
	DEFB	'.',S_DEC_BIN-$-1	; $F2 offset
	DEFB	'+',S_U_PLUS-$-1	; $12 offset
	DEFB	$A8,S_FN-$-1	; $56 offset
	DEFB	$A5,S_RND-$-1	; $57 offset
	DEFB	$A7,S_PI-$-1	; $84 offset
	DEFB	$A6,S_INKEY-$-1	; $8F offset
	DEFB	$C4,S_DEC_BIN-$-1	; $E6 offset
	DEFB	$AA,S_SCREEN-$-1	; $BF offset
	DEFB	$AB,S_ATTR-$-1	; $C7 offset
	DEFB	$A9,S_POINT-$-1	; $CE offset
	DEFB	$00		; zero end marker

; --------------------------
; Scanning function routines
; --------------------------
; These are the 11 subroutines accessed by the above table.
; S-BIN and S-DECIMAL are the same
; The 1-byte offset limits their location to within 255 bytes of their
; entry in the table.

; ->

	ORG	$25AF
S_U_PLUS:  RST 20H ; NEXT_CHAR just ignore
  JP  L24FF ; to S-LOOP-1

; ---

; ->

	ORG	$25B3
S_QUOTE:  RST 18H ; GET_CHAR
  INC HL  ; address next character (first in quotes)
  PUSH  HL  ; save start of quoted text.
  LD  BC,$0000  ; initialize length of string to zero.
  CALL  L250F ; routine S-QUOTE-S
  JR  NZ,L25D9  ; forward to S-Q-PRMS if

	ORG	$25BE
;; S-Q-AGAIN
L25BE:  CALL  L250F ; routine S-QUOTE-S copies string until a
  ; quote is encountered
  JR  Z,L25BE ; back to S-Q-AGAIN if two quotes WERE
  ; together.

; but if just an isolated quote then that terminates the string.

  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L25D9 ; forward to S-Q-PRMS if checking syntax.


  RST 30H ; BC_SPACES creates the space for true
  ; copy of string in workspace.
  POP HL  ; re-fetch start of quoted text.
  PUSH  DE  ; save start in workspace.

	ORG	$25CB
;; S-Q-COPY
L25CB:  LD  A,(HL)  ; fetch a character from source.
  INC HL  ; advance source address.
  LD  (DE),A  ; place in destination.
  INC DE  ; advance destination address.
  CP  $22 ; was it a '"' just copied ?
  JR  NZ,L25CB  ; back to S-Q-COPY to copy more if not

  LD  A,(HL)  ; fetch adjacent character from source.
  INC HL  ; advance source address.
  CP  $22 ; is this '"' ? - i.e. two quotes together ?
  JR  Z,L25CB ; to S-Q-COPY if so including just one of the
  ; pair of quotes.

; proceed when terminating quote encountered.

	ORG	$25D9
;; S-Q-PRMS
L25D9:  DEC BC  ; decrease count by 1.
  POP DE  ; restore start of string in workspace.

	ORG	$25DB
;; S-STRING
L25DB:  LD  HL,FLAGS  ; Address FLAGS system variable.
  RES 6,(HL)  ; signal string result.
  BIT 7,(HL)  ; is syntax being checked.
  CALL  NZ,STK_STO_STR  ; routine STK-STO-$ is called in runtime.
  JP  L2712 ; jump forward to S-CONT-2  ===>

; ---

; ->
	ORG	$25E8
S_BRACKET:  RST 20H ; NEXT_CHAR
  CALL  SCANNING ; routine SCANNING is called recursively.
  CP  $29 ; is it the closing ')' ?
  JP  NZ,REPORT_C  ; jump back to REPORT-C if not
  ; 'Syntax error'

  RST 20H ; NEXT_CHAR
  JP  L2712 ; jump forward to S-CONT-2  ===>

; ---

; ->
	ORG	$25F5
S_FN:  JP  L27BD ; jump forward to S-FN-SBRN.

; ---

; ->
	ORG	$25F8
S_RND:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L2625 ; forward to S-RND-END if checking syntax.

  LD  BC,($5C76)  ; fetch system variable SEED
  CALL  STACK_BC ; routine STACK-BC places on calculator stack

  RST  28H ;; FP_CALC ;s.
  DEFB  $A1 ;;stk-one  ;s,1.
  DEFB  $0F ;;addition ;s+1.
  DEFB  $34 ;;stk-data ;
  DEFB  $37 ;;Exponent: $87,
  ;;Bytes: 1
  DEFB  $16 ;;(+00,+00,+00)  ;s+1,75.
  DEFB  $04 ;;multiply ;(s+1)*75 = v
  DEFB  $34 ;;stk-data ;v.
  DEFB  $80 ;;Bytes: 3
  DEFB  $41 ;;Exponent $91
  DEFB  $00,$00,$80 ;;(+00)  ;v,65537.
  DEFB  $32 ;;n-mod-m  ;remainder, result.
  DEFB  $02 ;;delete ;remainder.
  DEFB  $A1 ;;stk-one  ;remainder, 1.
  DEFB  $03 ;;subtract ;remainder - 1. = rnd
  DEFB  $31 ;;duplicate  ;rnd,rnd.
  DEFB  $38 ;;end-calc

  CALL  FP_TO_BC ; routine FP-TO-BC
  LD  ($5C76),BC  ; store in SEED for next starting point.
  LD  A,(HL)  ; fetch exponent
  AND A ; is it zero ?
  JR  Z,L2625 ; forward if so to S-RND-END

  SUB $10 ; reduce exponent by 2^16
  LD  (HL),A  ; place back

	ORG	$2625
;; S-RND-END
L2625:  JR  L2630 ; forward to S-PI-END

; ---

; the number PI 3.14159...

; ->
	ORG	$2627
S_PI:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L2630 ; to S-PI-END if checking syntax.

  RST 28H ;; FP_CALC
  DEFB  $A3 ;;stk-pi/2  pi/2.
  DEFB  $38 ;;end-calc

  INC (HL)  ; increment the exponent leaving pi
  ; on the calculator stack.

	ORG	$2630
;; S-PI-END
L2630:  RST 20H ; NEXT_CHAR
  JP  L26C3 ; jump forward to S-NUMERIC

; ---

; ->
	ORG	$2634
S_INKEY:  LD  BC,$105A  ; priority $10, operation code $1A ('read-in')
  ; +$40 for string result, numeric operand.
  ; set this up now in case we need to use the
  ; calculator.
  RST 20H ; NEXT_CHAR
  CP  $23 ; '#' ?
  JP  Z,L270D ; to S-PUSH-PO if so to use the calculator
  ; single operation
  ; to read from network/RS232 etc. .

; else read a key from the keyboard.

  LD  HL,FLAGS  ; fetch FLAGS
  RES 6,(HL)  ; signal string result.
  BIT 7,(HL)  ; checking syntax ?
  JR  Z,L2665 ; forward to S-INK$-EN if so

  CALL  KEY_SCAN ; routine KEY-SCAN key in E, shift in D.
  LD  C,$00 ; the length of an empty string
  JR  NZ,L2660  ; to S-IK$-STK to store empty string if
  ; no key returned.

  CALL  K_TEST ; routine K-TEST get main code in A
  JR  NC,L2660  ; to S-IK$-STK to stack null string if
  ; invalid

  DEC D ; D is expected to be FLAGS so set bit 3 $FF
  ; 'L' Mode so no keywords.
  LD  E,A ; main key to A
  ; C is MODE 0 'KLC' from above still.
  CALL  K_DECODE ; routine K-DECODE
  PUSH  AF  ; save the code
  LD  BC,$0001  ; make room for one character

  RST 30H ; BC_SPACES
  POP AF  ; bring the code back
  LD  (DE),A  ; put the key in workspace
  LD  C,$01 ; set C length to one

	ORG	$2660
;; S-IK$-STK
L2660:  LD  B,$00 ; set high byte of length to zero
  CALL  STK_STO_STR ; routine STK-STO-$

	ORG	$2665
;; S-INK$-EN
L2665:  JP  L2712 ; to S-CONT-2  ===>

; ---

; ->
	ORG	$2668
S_SCREEN:  CALL  L2522 ; routine S-2-COORD
  CALL  NZ,L2535  ; routine S-SCRN$-S

  RST 20H ; NEXT_CHAR
  JP  L25DB ; forward to S-STRING to stack result

; ---

; ->
	ORG	$2672
S_ATTR:  CALL  L2522 ; routine S-2-COORD
  CALL  NZ,L2580  ; routine S-ATTR-S

  RST 20H ; NEXT_CHAR
  JR  L26C3 ; forward to S-NUMERIC

; ---

; ->
	ORG	$267B
S_POINT:  CALL  L2522 ; routine S-2-COORD
  CALL  NZ,L22CB  ; routine POINT-SUB

  RST 20H ; NEXT_CHAR
  JR  L26C3 ; forward to S-NUMERIC

; -----------------------------

; ==> The branch was here if not in table.

	ORG	$2684
;; S-ALPHNUM
L2684:  CALL  L2C88 ; routine ALPHANUM checks if variable or
  ; a digit.
  JR  NC,L26DF  ; forward to S-NEGATE if not to consider
  ; a '-' character then functions.

  CP  $41 ; compare 'A'
  JR  NC,L26C9  ; forward to S-LETTER if alpha ->
  ; else must have been numeric so continue
  ; into that routine.

; This important routine is called during runtime and from LINE-SCAN
; when a BASIC line is checked for syntax. It is this routine that
; inserts, during syntax checking, the invisible floating point numbers
; after the numeric expression. During runtime it just picks these
; numbers up. It also handles BIN format numbers.

; ->
	ORG	$268D
S_DEC_BIN:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  NZ,L26B5  ; to S-STK-DEC in runtime

; this route is taken when checking syntax.

  CALL  L2C9B ; routine DEC-TO-FP to evaluate number

  RST 18H ; GET_CHAR to fetch HL
  LD  BC,$0006  ; six locations required
  CALL  MAKE_ROOM ; routine MAKE-ROOM
  INC HL  ; to first new location
  LD  (HL),$0E  ; insert number marker
  INC HL  ; address next
  EX  DE,HL ; make DE destination.
  LD  HL,(STKEND)  ; STKEND points to end of stack.
  LD  C,$05 ; result is five locations lower
  AND A ; prepare for true subtraction
  SBC HL,BC ; point to start of value.
  LD  (STKEND),HL  ; update STKEND as we are taking number.
  LDIR  ; Copy five bytes to program location
  EX  DE,HL ; transfer pointer to HL
  DEC HL  ; adjust
  CALL  TEMP_PTR1 ; routine TEMP-PTR1 sets CH-ADD
  JR  L26C3 ; to S-NUMERIC to record nature of result

; ---

; branch here in runtime.

	ORG	$26B5
;; S-STK-DEC
L26B5:  RST 18H ; GET_CHAR positions HL at digit.

	ORG	$26B6
;; S-SD-SKIP
L26B6:  INC HL  ; advance pointer
  LD  A,(HL)  ; until we find
  CP  $0E ; chr 14d - the number indicator
  JR  NZ,L26B6  ; to S-SD-SKIP until a match
  ; it has to be here.

  INC HL  ; point to first byte of number
  CALL  STACK_NUM ; routine STACK-NUM stacks it
  LD  (CH_ADD),HL  ; update system variable CH_ADD

	ORG	$26C3
;; S-NUMERIC
L26C3:  SET 6,(IY+$01)  ; update FLAGS  - Signal numeric result
  JR  L26DD ; forward to S-CONT-1 ===>
  ; actually S-CONT-2 is destination but why
  ; waste a byte on a jump when a JR will do.
  ; actually a JR L2712 can be used. Rats.

; end of functions accessed from scanning functions table.

; --------------------------
; Scanning variable routines
; --------------------------
;
;

	ORG	$26C9
;; S-LETTER
L26C9:  CALL  LOOK_VARS ; routine LOOK-VARS
  JP  C,REPORT_2 ; jump back to REPORT-2 if not found
  ; 'Undefined variable'
  ; but a variable is always 'found' if syntax
  ; is being checked.

  CALL  Z,STK_VAR ; routine STK-VAR considers a subscript/slice
  LD  A,(FLAGS) ; fetch FLAGS value
  CP  $C0 ; compare 11000000
  JR  C,L26DD ; step forward to S-CONT-1 if string  ===>

  INC HL  ; advance pointer
  CALL  STACK_NUM ; routine STACK-NUM

	ORG	$26DD
;; S-CONT-1
L26DD:  JR  L2712 ; forward to S-CONT-2 ===>

; ----------------------------------------
; -> the scanning branch was here if not alphanumeric.
; All the remaining functions will be evaluated by a single call to the
; calculator. The correct priority for the operation has to be placed in
; the B register and the operation code, calculator literal in the C register.
; the operation code has bit 7 set if result is numeric and bit 6 is
; set if operand is numeric. so
; $C0 = numeric result, numeric operand.  e.g. 'sin'
; $80 = numeric result, string operand. e.g. 'code'
; $40 = string result, numeric operand. e.g. 'str$'
; $00 = string result, string operand.  e.g. 'val$'

	ORG	$26DF
;; S-NEGATE
L26DF:  LD  BC,$09DB  ; prepare priority 09, operation code $C0 +
  ; 'negate' ($1B) - bits 6 and 7 set for numeric
  ; result and numeric operand.

  CP  $2D ; is it '-' ?
  JR  Z,L270D ; forward if so to S-PUSH-PO

  LD  BC,$1018  ; prepare priority $10, operation code 'val$' -
  ; bits 6 and 7 reset for string result and
  ; string operand.

  CP  $AE ; is it 'VAL$' ?
  JR  Z,L270D ; forward if so to S-PUSH-PO

  SUB $AF ; subtract token 'CODE' value to reduce
  ; functions 'CODE' to 'NOT' although the
  ; upper range is, as yet, unchecked.
  ; valid range would be $00 - $14.

  JP  C,REPORT_C ; jump back to REPORT-C with anything else
  ; 'Syntax error'

  LD  BC,$04F0  ; prepare priority $04, operation $C0 +
  ; 'not' ($30)

  CP  $14 ; is it 'NOT'
  JR  Z,L270D ; forward to S-PUSH-PO if so

  JP  NC,REPORT_C  ; to REPORT-C if higher
  ; 'Syntax error'

  LD  B,$10 ; priority $10 for all the rest
  ADD A,$DC ; make range $DC - $EF
  ; $C0 + 'code'($1C) thru 'chr$' ($2F)

  LD  C,A ; transfer 'function' to C
  CP  $DF ; is it 'sin' ?
  JR  NC,L2707  ; forward to S-NO-TO-$  with 'sin' through
  ; 'chr$' as operand is numeric.

; all the rest 'cos' through 'chr$' give a numeric result except 'str$'
; and 'chr$'.

  RES 6,C ; signal string operand for 'code', 'val' and
  ; 'len'.

	ORG	$2707
;; S-NO-TO-$
L2707:  CP  $EE ; compare 'str$'
  JR  C,L270D ; forward to S-PUSH-PO if lower as result
  ; is numeric.

  RES 7,C ; reset bit 7 of op code for 'str$', 'chr$'
  ; as result is string.

; >> This is where they were all headed for.

	ORG	$270D
;; S-PUSH-PO
L270D:  PUSH  BC  ; push the priority and calculator operation
  ; code.

  RST 20H ; NEXT_CHAR
  JP  L24FF ; jump back to S-LOOP-1 to go round the loop
  ; again with the next character.

; --------------------------------

; ===>  there were many branches forward to here

	ORG	$2712
;; S-CONT-2
L2712:  RST 18H ; GET_CHAR

	ORG	$2713
;; S-CONT-3
L2713:  CP  $28 ; is it '(' ?
  JR  NZ,L2723  ; forward to S-OPERTR if not  >

  BIT 6,(IY+$01)  ; test FLAGS - numeric or string result ?
  JR  NZ,L2734  ; forward to S-LOOP if numeric to evaluate  >

; if a string preceded '(' then slice it.

  CALL  L2A52 ; routine SLICING

  RST 20H ; NEXT_CHAR
  JR  L2713 ; back to S-CONT-3

; ---------------------------

; the branch was here when possibility of an operator '(' has been excluded.

	ORG	$2723
;; S-OPERTR
L2723:  LD  B,$00 ; prepare to add
  LD  C,A ; possible operator to C
  LD  HL,TBL_OF_OPS  ; Address: $2795 - tbl-of-ops
  CALL  INDEXER ; routine INDEXER
  JR  NC,L2734  ; forward to S-LOOP if not in table

; but if found in table the priority has to be looked up.

  LD  C,(HL)  ; operation code to C ( B is still zero )
  LD  HL,TBL_PRIORS - $C3  ; $26ED is base of table
  ADD HL,BC ; index into table.
  LD  B,(HL)  ; priority to B.

; ------------------
; Scanning main loop
; ------------------
; the juggling act

	ORG	$2734
;; S-LOOP
L2734:  POP DE  ; fetch last priority and operation
  LD  A,D ; priority to A
  CP  B ; compare with this one
  JR  C,L2773 ; forward to S-TIGHTER to execute the
  ; last operation before this one as it has
  ; higher priority.

; the last priority was greater or equal this one.

  AND A ; if it is zero then so is this
  JP  Z,GET_CHAR ; jump to exit via GET_CHAR pointing at
  ; next character.
  ; This may be the character after the
  ; expression or, if exiting a recursive call,
  ; the next part of the expression to be
  ; evaluated.

  PUSH  BC  ; save current priority/operation
  ; as it has lower precedence than the one
  ; now in DE.

; the 'USR' function is special in that it is overloaded to give two types
; of result.

  LD  HL,FLAGS  ; address FLAGS
  LD  A,E ; new operation to A register
  CP  $ED ; is it $C0 + 'usr-no' ($2D)  ?
  JR  NZ,L274C  ; forward to S-STK-LST if not

  BIT 6,(HL)  ; string result expected ?
  ; (from the lower priority operand we've
  ; just pushed on stack )
  JR  NZ,L274C  ; forward to S-STK-LST if numeric
  ; as operand bits match.

  LD  E,$99 ; reset bit 6 and substitute $19 'usr-$'
  ; for string operand.

	ORG	$274C
;; S-STK-LST
L274C:  PUSH  DE  ; now stack this priority/operation
  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L275B ; forward to S-SYNTEST if checking syntax.

  LD  A,E ; fetch the operation code
  AND $3F ; mask off the result/operand bits to leave
  ; a calculator literal.
  LD  B,A ; transfer to B register

; now use the calculator to perform the single operation - operand is on
; the calculator stack.
; Note. although the calculator is performing a single operation most
; functions e.g. TAN are written using other functions and literals and
; these in turn are written using further strings of calculator literals so
; another level of magical recursion joins the juggling act for a while
; as the calculator too is calling itself.

  RST 28H ;; FP_CALC
  DEFB  $3B ;;FP_CALC-2

	ORG	$2758
L2758:  DEFB  $38 ;;end-calc

  JR  L2764 ; forward to S-RUNTEST

; ---

; the branch was here if checking syntax only.

	ORG	$275B
;; S-SYNTEST
L275B:  LD  A,E ; fetch the operation code to accumulator
  XOR (IY+$01)  ; compare with bits of FLAGS
  AND $40 ; bit 6 will be zero now if operand
  ; matched expected result.

	ORG	$2761
;; S-RPORT-C2
L2761:  JP  NZ,REPORT_C  ; to REPORT-C if mismatch
  ; 'Syntax error'
  ; else continue to set flags for next

; the branch is to here in runtime after a successful operation.

	ORG	$2764
;; S-RUNTEST
L2764:  POP DE  ; fetch the last operation from stack
  LD  HL,FLAGS  ; address FLAGS
  SET 6,(HL)  ; set default to numeric result in FLAGS
  BIT 7,E ; test the operational result
  JR  NZ,L2770  ; forward to S-LOOPEND if numeric

  RES 6,(HL)  ; reset bit 6 of FLAGS to show string result.

	ORG	$2770
;; S-LOOPEND
L2770:  POP BC  ; fetch the previous priority/operation
  JR  L2734 ; back to S-LOOP to perform these

; ---

; the branch was here when a stacked priority/operator had higher priority
; than the current one.

	ORG	$2773
;; S-TIGHTER
L2773:  PUSH  DE  ; save high priority op on stack again
  LD  A,C ; fetch lower priority operation code
  BIT 6,(IY+$01)  ; test FLAGS - Numeric or string result ?
  JR  NZ,L2790  ; forward to S-NEXT if numeric result

; if this is lower priority yet has string then must be a comparison.
; Since these can only be evaluated in context and were defaulted to
; numeric in operator look up they must be changed to string equivalents.

  AND $3F ; mask to give true calculator literal
  ADD A,$08 ; augment numeric literals to string
  ; equivalents.
  ; 'no-&-no'  => 'str-&-no'
  ; 'no-l-eql' => 'str-l-eql'
  ; 'no-gr-eq' => 'str-gr-eq'
  ; 'nos-neql' => 'strs-neql'
  ; 'no-grtr'  => 'str-grtr'
  ; 'no-less'  => 'str-less'
  ; 'nos-eql'  => 'strs-eql'
  ; 'addition' => 'strs-add'
  LD  C,A ; put modified comparison operator back
  CP  $10 ; is it now 'str-&-no' ?
  JR  NZ,L2788  ; forward to S-NOT-AND  if not.

  SET 6,C ; set numeric operand bit
  JR  L2790 ; forward to S-NEXT

; ---

	ORG	$2788
;; S-NOT-AND
L2788:  JR  C,L2761 ; back to S-RPORT-C2 if less
  ; 'Syntax error'.
  ; e.g. a$ * b$

  CP  $17 ; is it 'strs-add' ?
  JR  Z,L2790 ; forward to S-NEXT if so
  ; (bit 6 and 7 are reset)

  SET 7,C ; set numeric (Boolean) result for all others

	ORG	$2790
;; S-NEXT
L2790:  PUSH  BC  ; now save this priority/operation on stack

  RST 20H ; NEXT_CHAR
  JP  L24FF ; jump back to S-LOOP-1

; ------------------
; Table of operators
; ------------------
; This table is used to look up the calculator literals associated with
; the operator character. The thirteen calculator operations $03 - $0F
; have bits 6 and 7 set to signify a numeric result.
; Some of these codes and bits may be altered later if the context suggests
; a string comparison or operation.
; that is '+', '=', '>', '<', '<=', '>=' or '<>'.

	ORG	$2795
TBL_OF_OPS:
	DEFB	'+',$CF		;	$C0 + 'addition'
	DEFB	'-',$C3		;	$C0 + 'subtract'
	DEFB	'*',$C4		;	$C0 + 'multiply'
	DEFB	'/',$C5		;	$C0 + 'division'
	DEFB	'^',$C6		;	$C0 + 'to-power'
	DEFB	'=',$CE		;	$C0 + 'nos-eql'
	DEFB	'>',$CC		;	$C0 + 'no-grtr'
	DEFB	'<',$CD		;	$C0 + 'no-less'

	DEFB	$C7,$C9		; '<='	$C0 + 'no-l-eql'
	DEFB	$C8,$CA		; '>='	$C0 + 'no-gr-eql'
	DEFB	$C9,$CB		; '<>'	$C0 + 'nos-neql'
	DEFB	$C5,$C7		; 'OR'	$C0 + 'or'
	DEFB	$C6,$C8		; 'AND'	$C0 + 'no-&-no'

	DEFB	$00		; zero end-marker.


; -------------------
; Table of priorities
; -------------------
; This table is indexed with the operation code obtained from the above
; table $C3 - $CF to obtain the priority for the respective operation.

	ORG	$27B0
TBL_PRIORS:
	DEFB	$06		; '-'	opcode $C3
	DEFB	$08		; '*'	opcode $C4
	DEFB	$08		; '/'	opcode $C5
	DEFB	$0A		; '^'	opcode $C6
	DEFB	$02		; 'OR'	opcode $C7
	DEFB	$03		; 'AND'	opcode $C8
	DEFB	$05		; '<='	opcode $C9
	DEFB	$05		; '>='	opcode $CA
	DEFB	$05		; '<>'	opcode $CB
	DEFB	$05		; '>'	opcode $CC
	DEFB	$05		; '<'	opcode $CD
	DEFB	$05		; '='	opcode $CE
	DEFB	$06		; '+'	opcode $CF

; ----------------------
; Scanning function (FN)
; ----------------------
; This routine deals with user-defined functions.
; The definition can be anywhere in the program area but these are best
; placed near the start of the program as we shall see.
; The evaluation process is quite complex as the Spectrum has to parse two
; statements at the same time. Syntax of both has been checked previously
; and hidden locations have been created immediately after each argument
; of the DEF FN statement. Each of the arguments of the FN function is
; evaluated by SCANNING and placed in the hidden locations. Then the
; expression to the right of the DEF FN '=' is evaluated by SCANNING and for
; any variables encountered, a search is made in the DEF FN variable list
; in the program area before searching in the normal variables area.
;
; Recursion is not allowed: i.e. the definition of a function should not use
; the same function, either directly or indirectly ( through another function).
; You'll normally get error 4, ('Memory full'), although sometimes the system
; will crash. - Vickers, Pitman 1984.
;
; As the definition is just an expression, there would seem to be no means
; of breaking out of such recursion.
; However, by the clever use of string expressions and VAL, such recursion is
; possible.
; e.g. DEF FN a(n) = VAL "n+FN a(n-1)+0" ((n<1) * 10 + 1 TO )
; will evaluate the full 11-character expression for all values where n is
; greater than zero but just the 11th character, "0", when n drops to zero
; thereby ending the recursion producing the correct result.
; Recursive string functions are possible using VAL$ instead of VAL and the
; null string as the final addend.
; - from a turn of the century newsgroup discussion initiated by Mike Wynne.

	ORG	$27BD
;; S-FN-SBRN
L27BD:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  NZ,L27F7  ; forward to SF-RUN in runtime


  RST 20H ; NEXT_CHAR
  CALL  ALPHA ; routine ALPHA check for letters A-Z a-z
  JP  NC,REPORT_C  ; jump back to REPORT-C if not
  ; 'Syntax error'


  RST 20H ; NEXT_CHAR
  CP  $24 ; is it '$' ?
  PUSH  AF  ; save character and flags
  JR  NZ,L27D0  ; forward to SF-BRKT-1 with numeric function


  RST 20H ; NEXT_CHAR

	ORG	$27D0
;; SF-BRKT-1
L27D0:  CP  $28 ; is '(' ?
  JR  NZ,L27E6  ; forward to SF-RPRT-C if not
  ; 'Syntax error'


  RST 20H ; NEXT_CHAR
  CP  $29 ; is it ')' ?
  JR  Z,L27E9 ; forward to SF-FLAG-6 if no arguments.

	ORG	$27D9
;; SF-ARGMTS
L27D9:  CALL  SCANNING ; routine SCANNING checks each argument
  ; which may be an expression.

  RST 18H ; GET_CHAR
  CP  $2C ; is it a ',' ?
  JR  NZ,L27E4  ; forward if not to SF-BRKT-2 to test bracket


  RST 20H ; NEXT_CHAR if a comma was found
  JR  L27D9 ; back to SF-ARGMTS to parse all arguments.

; ---

	ORG	$27E4
;; SF-BRKT-2
L27E4:  CP  $29 ; is character the closing ')' ?

	ORG	$27E6
;; SF-RPRT-C
L27E6:  JP  NZ,REPORT_C  ; jump to REPORT-C
  ; 'Syntax error'

; at this point any optional arguments have had their syntax checked.

	ORG	$27E9
;; SF-FLAG-6
L27E9:  RST 20H ; NEXT_CHAR
  LD  HL,FLAGS  ; address system variable FLAGS
  RES 6,(HL)  ; signal string result
  POP AF  ; restore test against '$'.
  JR  Z,L27F4 ; forward to SF-SYN-EN if string function.

  SET 6,(HL)  ; signal numeric result

	ORG	$27F4
;; SF-SYN-EN
L27F4:  JP  L2712 ; jump back to S-CONT-2 to continue scanning.

; ---

; the branch was here in runtime.

	ORG	$27F7
;; SF-RUN
L27F7:  RST 20H ; NEXT_CHAR fetches name
  AND $DF ; AND 11101111 - reset bit 5 - upper-case.
  LD  B,A ; save in B

  RST 20H ; NEXT_CHAR
  SUB $24 ; subtract '$'
  LD  C,A ; save result in C
  JR  NZ,L2802  ; forward if not '$' to SF-ARGMT1

  RST 20H ; NEXT_CHAR advances to bracket

	ORG	$2802
;; SF-ARGMT1
L2802:  RST 20H ; NEXT_CHAR advances to start of argument
  PUSH  HL  ; save address
  LD  HL,(PROG)  ; fetch start of program area from PROG
  DEC HL  ; the search starting point is the previous
  ; location.

	ORG	$2808
;; SF-FND-DF
L2808:  LD  DE,$00CE  ; search is for token 'DEF FN' in E,
  ; statement count in D.
  PUSH  BC  ; save C the string test, and B the letter.
  CALL  LOOK_PROG ; routine LOOK-PROG will search for token.
  POP BC  ; restore BC.
  JR  NC,L2814  ; forward to SF-CP-DEF if a match was found.


	ORG	$2812
;; REPORT-P
L2812:  RST 08H ; ERROR-1
  DEFB  $18 ; Error Report: Undefined FN

	ORG	$2814
;; SF-CP-DEF
L2814:  PUSH  HL  ; save address of DEF FN
  CALL  L28AB ; routine FN-SKPOVR skips over white-space etc.
  ; without disturbing CH-ADD.
  AND $DF ; make fetched character upper-case.
  CP  B ; compare with FN name
  JR  NZ,L2825  ; forward to SF-NOT-FD if no match.

; the letters match so test the type.

  CALL  L28AB ; routine FN-SKPOVR skips white-space
  SUB $24 ; subtract '$' from fetched character
  CP  C ; compare with saved result of same operation
  ; on FN name.
  JR  Z,L2831 ; forward to SF-VALUES with a match.

; the letters matched but one was string and the other numeric.

	ORG	$2825
;; SF-NOT-FD
L2825:  POP HL  ; restore search point.
  DEC HL  ; make location before
  LD  DE,$0200  ; the search is to be for the end of the
  ; current definition - 2 statements forward.
  PUSH  BC  ; save the letter/type
  CALL  EACH_STMT ; routine EACH-STMT steps past rejected
  ; definition.
  POP BC  ; restore letter/type
  JR  L2808 ; back to SF-FND-DF to continue search

; ---

; Success!
; the branch was here with matching letter and numeric/string type.

	ORG	$2831
;; SF-VALUES
L2831:  AND A ; test A ( will be zero if string '$' - '$' )

  CALL  Z,L28AB ; routine FN-SKPOVR advances HL past '$'.

  POP DE  ; discard pointer to 'DEF FN'.
  POP DE  ; restore pointer to first FN argument.
  LD  (CH_ADD),DE  ; save in CH_ADD

  CALL  L28AB ; routine FN-SKPOVR advances HL past '('
  PUSH  HL  ; save start address in DEF FN  ***
  CP  $29 ; is character a ')' ?
  JR  Z,L2885 ; forward to SF-R-BR-2 if no arguments.

	ORG	$2843
;; SF-ARG-LP
L2843:  INC HL  ; point to next character.
  LD  A,(HL)  ; fetch it.
  CP  $0E ; is it the number marker
  LD  D,$40 ; signal numeric in D.
  JR  Z,L2852 ; forward to SF-ARG-VL if numeric.

  DEC HL  ; back to letter
  CALL  L28AB ; routine FN-SKPOVR skips any white-space
  INC HL  ; advance past the expected '$' to
  ; the 'hidden' marker.
  LD  D,$00 ; signal string.

	ORG	$2852
;; SF-ARG-VL
L2852:  INC HL  ; now address first of 5-byte location.
  PUSH  HL  ; save address in DEF FN statement
  PUSH  DE  ; save D - result type

  CALL  SCANNING ; routine SCANNING evaluates expression in
  ; the FN statement setting FLAGS and leaving
  ; result as last value on calculator stack.

  POP AF  ; restore saved result type to A

  XOR (IY+$01)  ; xor with FLAGS
  AND $40 ; and with 01000000 to test bit 6
  JR  NZ,L288B  ; forward to REPORT-Q if type mismatch.
  ; 'Parameter error'

  POP HL  ; pop the start address in DEF FN statement
  EX  DE,HL ; transfer to DE ?? pop straight into de ?

  LD  HL,(STKEND)  ; set HL to STKEND location after value
  LD  BC,$0005  ; five bytes to move
  SBC HL,BC ; decrease HL by 5 to point to start.
  LD  (STKEND),HL  ; set STKEND 'removing' value from stack.

  LDIR  ; copy value into DEF FN statement
  EX  DE,HL ; set HL to location after value in DEF FN
  DEC HL  ; step back one
  CALL  L28AB ; routine FN-SKPOVR gets next valid character
  CP  $29 ; is it ')' end of arguments ?
  JR  Z,L2885 ; forward to SF-R-BR-2 if so.

; a comma separator has been encountered in the DEF FN argument list.

  PUSH  HL  ; save position in DEF FN statement

  RST 18H ; GET_CHAR from FN statement
  CP  $2C ; is it ',' ?
  JR  NZ,L288B  ; forward to REPORT-Q if not
  ; 'Parameter error'

  RST 20H ; NEXT_CHAR in FN statement advances to next
  ; argument.

  POP HL  ; restore DEF FN pointer
  CALL  L28AB ; routine FN-SKPOVR advances to corresponding
  ; argument.

  JR  L2843 ; back to SF-ARG-LP looping until all
  ; arguments are passed into the DEF FN
  ; hidden locations.

; ---

; the branch was here when all arguments passed.

	ORG	$2885
;; SF-R-BR-2
L2885:  PUSH  HL  ; save location of ')' in DEF FN

  RST 18H ; GET_CHAR gets next character in FN
  CP  $29 ; is it a ')' also ?
  JR  Z,L288D ; forward to SF-VALUE if so.


	ORG	$288B
;; REPORT-Q
L288B:  RST 08H ; ERROR-1
  DEFB  $19 ; Error Report: Parameter error

	ORG	$288D
;; SF-VALUE
L288D:  POP DE  ; location of ')' in DEF FN to DE.
  EX  DE,HL ; now to HL, FN ')' pointer to DE.
  LD  (CH_ADD),HL  ; initialize CH_ADD to this value.

; At this point the start of the DEF FN argument list is on the machine stack.
; We also have to consider that this defined function may form part of the
; definition of another defined function (though not itself).
; As this defined function may be part of a hierarchy of defined functions
; currently being evaluated by recursive calls to SCANNING, then we have to
; preserve the original value of DEFADD and not assume that it is zero.

  LD  HL,(DEFADD)  ; get original DEFADD address
  EX  (SP),HL ; swap with DEF FN address on stack ***
  LD  (DEFADD),HL  ; set DEFADD to point to this argument list
  ; during scanning.

  PUSH  DE  ; save FN ')' pointer.

  RST 20H ; NEXT_CHAR advances past ')' in define

  RST 20H ; NEXT_CHAR advances past '=' to expression

  CALL  SCANNING ; routine SCANNING evaluates but searches
  ; initially for variables at DEFADD

  POP HL  ; pop the FN ')' pointer
  LD  (CH_ADD),HL  ; set CH_ADD to this
  POP HL  ; pop the original DEFADD value
  LD  (DEFADD),HL  ; and re-insert into DEFADD system variable.

  RST 20H ; NEXT_CHAR advances to character after ')'
  JP  L2712 ; to S-CONT-2 - to continue current
  ; invocation of scanning

; --------------------
; Used to parse DEF FN
; --------------------
; e.g. DEF FN s $ ( x ) =  b $ (  TO  x  ) : REM exaggerated
;
; This routine is used 10 times to advance along a DEF FN statement
; skipping spaces and colour control codes. It is similar to NEXT_CHAR
; which is, at the same time, used to skip along the corresponding FN function
; except the latter has to deal with AT and TAB characters in string
; expressions. These cannot occur in a program area so this routine is
; simpler as both colour controls and their parameters are less than space.

	ORG	$28AB
;; FN-SKPOVR
L28AB:  INC HL  ; increase pointer
  LD  A,(HL)  ; fetch addressed character
  CP  $21 ; compare with space + 1
  JR  C,L28AB ; back to FN-SKPOVR if less

  RET ; return pointing to a valid character.

; ---------
; LOOK-VARS
; ---------
;
;

	ORG	$28B2
LOOK_VARS:  SET 6,(IY+$01)  ; update FLAGS - presume numeric result

  RST 18H ; GET_CHAR
  CALL  ALPHA ; routine ALPHA tests for A-Za-z
  JP  NC,REPORT_C  ; jump to REPORT-C if not.
  ; 'Syntax error'

  PUSH  HL  ; save pointer to first letter ^1
  AND $1F ; mask lower bits, 1 - 26 decimal 000xxxxx
  LD  C,A ; store in C.

  RST 20H ; NEXT_CHAR
  PUSH  HL  ; save pointer to second character ^2
  CP  $28 ; is it '(' - an array ?
  JR  Z,L28EF ; forward to V-RUN/SYN if so.

  SET 6,C ; set 6 signaling string if solitary  010
  CP  $24 ; is character a '$' ?
  JR  Z,L28DE ; forward to V-STR-VAR

  SET 5,C ; signal numeric 011
  CALL  L2C88 ; routine ALPHANUM sets carry if second
  ; character is alphanumeric.
  JR  NC,L28E3  ; forward to V-TEST-FN if just one character

; It is more than one character but re-test current character so that 6 reset
; This loop renders the similar loop at V-PASS redundant.

	ORG	$28D4
;; V-CHAR
L28D4:  CALL  L2C88 ; routine ALPHANUM
  JR  NC,L28EF  ; to V-RUN/SYN when no more

  RES 6,C ; make long named type 001

  RST 20H ; NEXT_CHAR
  JR  L28D4 ; loop back to V-CHAR

; ---


	ORG	$28DE
;; V-STR-VAR
L28DE:  RST 20H ; NEXT_CHAR advances past '$'
  RES 6,(IY+$01)  ; update FLAGS - signal string result.

	ORG	$28E3
;; V-TEST-FN
L28E3:  LD  A,($5C0C) ; load A with DEFADD_H
  AND A ; and test for zero.
  JR  Z,L28EF ; forward to V-RUN/SYN if a defined function
  ; is not being evaluated.

; Note.

  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JP  NZ,L2951  ; JUMP to STK-F-ARG in runtime and then
  ; back to this point if no variable found.

	ORG	$28EF
;; V-RUN/SYN
L28EF:  LD  B,C ; save flags in B
  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  NZ,L28FD  ; to V-RUN to look for the variable in runtime

; if checking syntax the letter is not returned

  LD  A,C ; copy letter/flags to A
  AND $E0 ; and with 11100000 to get rid of the letter
  SET 7,A ; use spare bit to signal checking syntax.
  LD  C,A ; and transfer to C.
  JR  L2934 ; forward to V-SYNTAX

; ---

; but in runtime search for the variable.

	ORG	$28FD
;; V-RUN
L28FD:  LD  HL,(VARS)  ; set HL to start of variables from VARS

	ORG	$2900
;; V-EACH
L2900:  LD  A,(HL)  ; get first character
  AND $7F ; and with 01111111
  ; ignoring bit 7 which distinguishes
  ; arrays or for/next variables.

  JR  Z,L2932 ; to V-80-BYTE if zero as must be 10000000
  ; the variables end-marker.

  CP  C ; compare with supplied value.
  JR  NZ,L292A  ; forward to V-NEXT if no match.

  RLA ; destructively test
  ADD A,A ; bits 5 and 6 of A
  ; jumping if bit 5 reset or 6 set

  JP  P,L293F ; to V-FOUND-2  strings and arrays

  JR  C,L293F ; to V-FOUND-2  simple and for next

; leaving long name variables.

  POP DE  ; pop pointer to 2nd. char
  PUSH  DE  ; save it again
  PUSH  HL  ; save variable first character pointer

	ORG	$2912
;; V-MATCHES
L2912:  INC HL  ; address next character in vars area

	ORG	$2913
;; V-SPACES
L2913:  LD  A,(DE)  ; pick up letter from prog area
  INC DE  ; and advance address
  CP  $20 ; is it a space
  JR  Z,L2913 ; back to V-SPACES until non-space

  OR  $20 ; convert to range 1 - 26.
  CP  (HL)  ; compare with addressed variables character
  JR  Z,L2912 ; loop back to V-MATCHES if a match on an
  ; intermediate letter.

  OR  $80 ; now set bit 7 as last character of long
  ; names are inverted.
  CP  (HL)  ; compare again
  JR  NZ,L2929  ; forward to V-GET-PTR if no match

; but if they match check that this is also last letter in prog area

  LD  A,(DE)  ; fetch next character
  CALL  L2C88 ; routine ALPHANUM sets carry if not alphanum
  JR  NC,L293E  ; forward to V-FOUND-1 with a full match.

	ORG	$2929
;; V-GET-PTR
L2929:  POP HL  ; pop saved pointer to char 1

	ORG	$292A
;; V-NEXT
L292A:  PUSH  BC  ; save flags
  CALL  NEXT_ONE ; routine NEXT-ONE gets next variable in DE
  EX  DE,HL ; transfer to HL.
  POP BC  ; restore the flags
  JR  L2900 ; loop back to V-EACH
  ; to compare each variable

; ---

	ORG	$2932
;; V-80-BYTE
L2932:  SET 7,B ; will signal not found

; the branch was here when checking syntax

	ORG	$2934
;; V-SYNTAX
L2934:  POP DE  ; discard the pointer to 2nd. character  v2
  ; in BASIC line/workspace.

  RST 18H ; GET_CHAR gets character after variable name.
  CP  $28 ; is it '(' ?
  JR  Z,L2943 ; forward to V-PASS
  ; Note. could go straight to V-END ?

  SET 5,B ; signal not an array
  JR  L294B ; forward to V-END

; ---------------------------

; the jump was here when a long name matched and HL pointing to last character
; in variables area.

	ORG	$293E
;; V-FOUND-1
L293E:  POP DE  ; discard pointer to first var letter

; the jump was here with all other matches HL points to first var char.

	ORG	$293F
;; V-FOUND-2
L293F:  POP DE  ; discard pointer to 2nd prog char v2
  POP DE  ; drop pointer to 1st prog char  v1
  PUSH  HL  ; save pointer to last char in vars

  RST 18H ; GET_CHAR

	ORG	$2943
;; V-PASS
L2943:  CALL  L2C88 ; routine ALPHANUM
  JR  NC,L294B  ; forward to V-END if not

; but it never will be as we advanced past long-named variables earlier.

  RST 20H ; NEXT_CHAR
  JR  L2943 ; back to V-PASS

; ---

	ORG	$294B
;; V-END
L294B:  POP HL  ; pop the pointer to first character in
  ; BASIC line/workspace.
  RL  B ; rotate the B register left
  ; bit 7 to carry
  BIT 6,B ; test the array indicator bit.
  RET ; return

; -----------------------
; Stack function argument
; -----------------------
; This branch is taken from LOOK-VARS when a defined function is currently
; being evaluated.
; Scanning is evaluating the expression after the '=' and the variable
; found could be in the argument list to the left of the '=' or in the
; normal place after the program. Preference will be given to the former.
; The variable name to be matched is in C.

	ORG	$2951
;; STK-F-ARG
L2951:  LD  HL,(DEFADD)  ; set HL to DEFADD
  LD  A,(HL)  ; load the first character
  CP  $29 ; is it ')' ?
  JP  Z,L28EF ; JUMP back to V-RUN/SYN, if so, as there are
  ; no arguments.

; but proceed to search argument list of defined function first if not empty.

	ORG	$295A
;; SFA-LOOP
L295A:  LD  A,(HL)  ; fetch character again.
  OR  $60 ; or with 01100000 presume a simple variable.
  LD  B,A ; save result in B.
  INC HL  ; address next location.
  LD  A,(HL)  ; pick up byte.
  CP  $0E ; is it the number marker ?
  JR  Z,L296B ; forward to SFA-CP-VR if so.

; it was a string. White-space may be present but syntax has been checked.

  DEC HL  ; point back to letter.
  CALL  L28AB ; routine FN-SKPOVR skips to the '$'
  INC HL  ; now address the hidden marker.
  RES 5,B ; signal a string variable.

	ORG	$296B
;; SFA-CP-VR
L296B:  LD  A,B ; transfer found variable letter to A.
  CP  C ; compare with expected.
  JR  Z,L2981 ; forward to SFA-MATCH with a match.

  INC HL  ; step
  INC HL  ; past
  INC HL  ; the
  INC HL  ; five
  INC HL  ; bytes.

  CALL  L28AB ; routine FN-SKPOVR skips to next character
  CP  $29 ; is it ')' ?
  JP  Z,L28EF ; jump back if so to V-RUN/SYN to look in
  ; normal variables area.

  CALL  L28AB ; routine FN-SKPOVR skips past the ','
  ; all syntax has been checked and these
  ; things can be taken as read.
  JR  L295A ; back to SFA-LOOP while there are more
  ; arguments.

; ---

	ORG	$2981
;; SFA-MATCH
L2981:  BIT 5,C ; test if numeric
  JR  NZ,L2991  ; to SFA-END if so as will be stacked
  ; by scanning

  INC HL  ; point to start of string descriptor
  LD  DE,(STKEND)  ; set DE to STKEND
  CALL  MOVE_FP ; routine MOVE-FP puts parameters on stack.
  EX  DE,HL ; new free location to HL.
  LD  (STKEND),HL  ; use it to set STKEND system variable.

	ORG	$2991
;; SFA-END
L2991:  POP DE  ; discard
  POP DE  ; pointers.
  XOR A ; clear carry flag.
  INC A ; and zero flag.
  RET ; return.

; ------------------------
; Stack variable component
; ------------------------
; This is called to evaluate a complex structure that has been found, in
; runtime, by LOOK-VARS in the variables area.
; In this case HL points to the initial letter, bits 7-5
; of which indicate the type of variable.
; 010 - simple string, 110 - string array, 100 - array of numbers.
;
; It is called from CLASS-01 when assigning to a string or array including
; a slice.
; It is called from SCANNING to isolate the required part of the structure.
;
; An important part of the runtime process is to check that the number of
; dimensions of the variable match the number of subscripts supplied in the
; BASIC line.
;
; If checking syntax,
; the B register, which counts dimensions is set to zero (256) to allow
; the loop to continue till all subscripts are checked. While doing this it
; is reading dimension sizes from some arbitrary area of memory. Although
; these are meaningless it is of no concern as the limit is never checked by
; int-exp during syntax checking.
;
; The routine is also called from the syntax path of DIM command to check the
; syntax of both string and numeric arrays definitions except that bit 6 of C
; is reset so both are checked as numeric arrays. This ruse avoids a terminal
; slice being accepted as part of the DIM command.
; All that is being checked is that there are a valid set of comma-separated
; expressions before a terminal ')', although, as above, it will still go
; through the motions of checking dummy dimension sizes.

	ORG	$2996
STK_VAR:  XOR A ; clear A
  LD  B,A ; and B, the syntax dimension counter (256)
  BIT 7,C ; checking syntax ?
  JR  NZ,L29E7  ; forward to SV-COUNT if so.

; runtime evaluation.

  BIT 7,(HL)  ; will be reset if a simple string.
  JR  NZ,L29AE  ; forward to SV-ARRAYS otherwise

  INC A ; set A to 1, simple string.

	ORG	$29A1
;; SV-SIMPLE$
L29A1:  INC HL  ; address length low
  LD  C,(HL)  ; place in C
  INC HL  ; address length high
  LD  B,(HL)  ; place in B
  INC HL  ; address start of string
  EX  DE,HL ; DE = start now.
  CALL  STK_STO_STR ; routine STK-STO-$ stacks string parameters
  ; DE start in variables area,
  ; BC length, A=1 simple string

; the only thing now is to consider if a slice is required.

  RST 18H ; GET_CHAR puts character at CH_ADD in A
  JP  L2A49 ; jump forward to SV-SLICE? to test for '('

; --------------------------------------------------------

; the branch was here with string and numeric arrays in runtime.

	ORG	$29AE
;; SV-ARRAYS
L29AE:  INC HL  ; step past
  INC HL  ; the total length
  INC HL  ; to address Number of dimensions.
  LD  B,(HL)  ; transfer to B overwriting zero.
  BIT 6,C ; a numeric array ?
  JR  Z,L29C0 ; forward to SV-PTR with numeric arrays

  DEC B ; ignore the final element of a string array
  ; the fixed string size.

  JR  Z,L29A1 ; back to SV-SIMPLE$ if result is zero as has
  ; been created with DIM a$(10) for instance
  ; and can be treated as a simple string.

; proceed with multi-dimensioned string arrays in runtime.

  EX  DE,HL ; save pointer to dimensions in DE

  RST 18H ; GET_CHAR looks at the BASIC line
  CP  $28 ; is character '(' ?
  JR  NZ,L2A20  ; to REPORT-3 if not
  ; 'Bad subscript'

  EX  DE,HL ; dimensions pointer to HL to synchronize
  ; with next instruction.

; runtime numeric arrays path rejoins here.

	ORG	$29C0
;; SV-PTR
L29C0:  EX  DE,HL ; save dimension pointer in DE
  JR  L29E7 ; forward to SV-COUNT with true no of dims
  ; in B. As there is no initial comma the
  ; loop is entered at the midpoint.

; ----------------------------------------------------------
; the dimension counting loop which is entered at mid-point.

	ORG	$29C3
;; SV-COMMA
L29C3:  PUSH  HL  ; save counter

  RST 18H ; GET_CHAR

  POP HL  ; pop counter
  CP  $2C ; is character ',' ?
  JR  Z,L29EA ; forward to SV-LOOP if so

; in runtime the variable definition indicates a comma should appear here

  BIT 7,C ; checking syntax ?
  JR  Z,L2A20 ; forward to REPORT-3 if not
  ; 'Subscript error'

; proceed if checking syntax of an array?

  BIT 6,C ; array of strings
  JR  NZ,L29D8  ; forward to SV-CLOSE if so

; an array of numbers.

  CP  $29 ; is character ')' ?
  JR  NZ,L2A12  ; forward to SV-RPT-C if not
  ; 'Syntax error'

  RST 20H ; NEXT_CHAR moves CH-ADD past the statement
  RET ; return ->

; ---

; the branch was here with an array of strings.

	ORG	$29D8
;; SV-CLOSE
L29D8:  CP  $29 ; as above ')' could follow the expression
  JR  Z,L2A48 ; forward to SV-DIM if so

  CP  $CC ; is it 'TO' ?
  JR  NZ,L2A12  ; to SV-RPT-C with anything else
  ; 'Syntax error'

; now backtrack CH_ADD to set up for slicing routine.
; Note. in a BASIC line we can safely backtrack to a colour parameter.

	ORG	$29E0
;; SV-CH-ADD
L29E0:  RST 18H ; GET_CHAR
  DEC HL  ; backtrack HL
  LD  (CH_ADD),HL  ; to set CH_ADD up for slicing routine
  JR  L2A45 ; forward to SV-SLICE and make a return
  ; when all slicing complete.

; ----------------------------------------
; -> the mid-point entry point of the loop

	ORG	$29E7
;; SV-COUNT
L29E7:  LD  HL,$0000  ; initialize data pointer to zero.

	ORG	$29EA
;; SV-LOOP
L29EA:  PUSH  HL  ; save the data pointer.

  RST 20H ; NEXT_CHAR in BASIC area points to an
  ; expression.

  POP HL  ; restore the data pointer.
  LD  A,C ; transfer name/type to A.
  CP  $C0 ; is it 11000000 ?
  ; Note. the letter component is absent if
  ; syntax checking.
  JR  NZ,L29FB  ; forward to SV-MULT if not an array of
  ; strings.

; proceed to check string arrays during syntax.

  RST 18H ; GET_CHAR
  CP  $29 ; ')'  end of subscripts ?
  JR  Z,L2A48 ; forward to SV-DIM to consider further slice

  CP  $CC ; is it 'TO' ?
  JR  Z,L29E0 ; back to SV-CH-ADD to consider a slice.
  ; (no need to repeat GET_CHAR at L29E0)

; if neither, then an expression is required so rejoin runtime loop ??
; registers HL and DE only point to somewhere meaningful in runtime so
; comments apply to that situation.

	ORG	$29FB
;; SV-MULT
L29FB:  PUSH  BC  ; save dimension number.
  PUSH  HL  ; push data pointer/rubbish.
  ; DE points to current dimension.
  CALL  L2AEE ; routine DE,(DE+1) gets next dimension in DE
  ; and HL points to it.
  EX  (SP),HL ; dim pointer to stack, data pointer to HL (*)
  EX  DE,HL ; data pointer to DE, dim size to HL.

  CALL  L2ACC ; routine INT-EXP1 checks integer expression
  ; and gets result in BC in runtime.
  JR  C,L2A20 ; to REPORT-3 if > HL
  ; 'Subscript out of range'

  DEC BC  ; adjust returned result from 1-x to 0-x
  CALL  L2AF4 ; routine GET-HL*DE multiplies data pointer by
  ; dimension size.
  ADD HL,BC ; add the integer returned by expression.
  POP DE  ; pop the dimension pointer.  ***
  POP BC  ; pop dimension counter.
  DJNZ  L29C3 ; back to SV-COMMA if more dimensions
  ; Note. during syntax checking, unless there
  ; are more than 256 subscripts, the branch
  ; back to SV-COMMA is always taken.

  BIT 7,C ; are we checking syntax ?
  ; then we've got a joker here.

	ORG	$2A12
;; SV-RPT-C
L2A12:  JR  NZ,L2A7A  ; forward to SL-RPT-C if so
  ; 'Syntax error'
  ; more than 256 subscripts in BASIC line.

; but in runtime the number of subscripts are at least the same as dims

  PUSH  HL  ; save data pointer.
  BIT 6,C ; is it a string array ?
  JR  NZ,L2A2C  ; forward to SV-ELEM$ if so.

; a runtime numeric array subscript.

  LD  B,D ; register DE has advanced past all dimensions
  LD  C,E ; and points to start of data in variable.
  ; transfer it to BC.

  RST 18H ; GET_CHAR checks BASIC line
  CP  $29 ; must be a ')' ?
  JR  Z,L2A22 ; skip to SV-NUMBER if so

; else more subscripts in BASIC line than the variable definition.

	ORG	$2A20
;; REPORT-3
L2A20:  RST 08H ; ERROR-1
  DEFB  $02 ; Error Report: Bad subscript

; continue if subscripts matched the numeric array.

	ORG	$2A22
;; SV-NUMBER
L2A22:  RST 20H ; NEXT_CHAR moves CH_ADD to next statement
  ; - finished parsing.

  POP HL  ; pop the data pointer.
  LD  DE,$0005  ; each numeric element is 5 bytes.
  CALL  L2AF4 ; routine GET-HL*DE multiplies.
  ADD HL,BC ; now add to start of data in the variable.

  RET ; return with HL pointing at the numeric
  ; array subscript. ->

; ---------------------------------------------------------------

; the branch was here for string subscripts when the number of subscripts
; in the BASIC line was one less than in variable definition.

	ORG	$2A2C
;; SV-ELEM$
L2A2C:  CALL  L2AEE ; routine DE,(DE+1) gets final dimension
  ; the length of strings in this array.
  EX  (SP),HL ; start pointer to stack, data pointer to HL.
  CALL  L2AF4 ; routine GET-HL*DE multiplies by element
  ; size.
  POP BC  ; the start of data pointer is added
  ADD HL,BC ; in - now points to location before.
  INC HL  ; point to start of required string.
  LD  B,D ; transfer the length (final dimension size)
  LD  C,E ; from DE to BC.
  EX  DE,HL ; put start in DE.
  CALL  L2AB1 ; routine STK-ST-0 stores the string parameters
  ; with A=0 - a slice or subscript.

; now check that there were no more subscripts in the BASIC line.

  RST 18H ; GET_CHAR
  CP  $29 ; is it ')' ?
  JR  Z,L2A48 ; forward to SV-DIM to consider a separate
  ; subscript or/and a slice.

  CP  $2C ; a comma is allowed if the final subscript
  ; is to be sliced e.g. a$(2,3,4 TO 6).
  JR  NZ,L2A20  ; to REPORT-3 with anything else
  ; 'Subscript error'

	ORG	$2A45
;; SV-SLICE
L2A45:  CALL  L2A52 ; routine SLICING slices the string.

; but a slice of a simple string can itself be sliced.

	ORG	$2A48
;; SV-DIM
L2A48:  RST 20H ; NEXT_CHAR

	ORG	$2A49
;; SV-SLICE?
L2A49:  CP  $28 ; is character '(' ?
  JR  Z,L2A45 ; loop back if so to SV-SLICE

  RES 6,(IY+$01)  ; update FLAGS  - Signal string result
  RET ; and return.

; ---

; The above section deals with the flexible syntax allowed.
; DIM a$(3,3,10) can be considered as two dimensional array of ten-character
; strings or a 3-dimensional array of characters.
; a$(1,1) will return a 10-character string as will a$(1,1,1 TO 10)
; a$(1,1,1) will return a single character.
; a$(1,1) (1 TO 6) is the same as a$(1,1,1 TO 6)
; A slice can itself be sliced ad infinitum
; b$ () () () () () () (2 TO 10) (2 TO 9) (3) is the same as b$(5)



; -------------------------
; Handle slicing of strings
; -------------------------
; The syntax of string slicing is very natural and it is as well to reflect
; on the permutations possible.
; a$() and a$( TO ) indicate the entire string although just a$ would do
; and would avoid coming here.
; h$(16) indicates the single character at position 16.
; a$( TO 32) indicates the first 32 characters.
; a$(257 TO) indicates all except the first 256 characters.
; a$(19000 TO 19999) indicates the thousand characters at position 19000.
; Also a$(9 TO 5) returns a null string not an error.
; This enables a$(2 TO) to return a null string if the passed string is
; of length zero or 1.
; A string expression in brackets can be sliced. e.g. (STR$ PI) (3 TO )
; We arrived here from SCANNING with CH-ADD pointing to the initial '('
; or from above.

	ORG	$2A52
;; SLICING
L2A52:  CALL  SYNTAX_Z ; routine SYNTAX-Z
  CALL  NZ,STK_FETCH  ; routine STK-FETCH fetches parameters of
  ; string at runtime, start in DE, length
  ; in BC. This could be an array subscript.

  RST 20H ; NEXT_CHAR
  CP  $29 ; is it ')' ? e.g. a$()
  JR  Z,L2AAD ; forward to SL-STORE to store entire string.

  PUSH  DE  ; else save start address of string

  XOR A ; clear accumulator to use as a running flag.
  PUSH  AF  ; and save on stack before any branching.

  PUSH  BC  ; save length of string to be sliced.
  LD  DE,$0001  ; default the start point to position 1.

  RST 18H ; GET_CHAR

  POP HL  ; pop length to HL as default end point
  ; and limit.

  CP  $CC ; is it 'TO' ?  e.g. a$( TO 10000)
  JR  Z,L2A81 ; to SL-SECOND to evaluate second parameter.

  POP AF  ; pop the running flag.

  CALL  L2ACD ; routine INT-EXP2 fetches first parameter.

  PUSH  AF  ; save flag (will be $FF if parameter>limit)

  LD  D,B ; transfer the start
  LD  E,C ; to DE overwriting 0001.
  PUSH  HL  ; save original length.

  RST 18H ; GET_CHAR
  POP HL  ; pop the limit length.
  CP  $CC ; is it 'TO' after a start ?
  JR  Z,L2A81 ; to SL-SECOND to evaluate second parameter

  CP  $29 ; is it ')' ? e.g. a$(365)

	ORG	$2A7A
;; SL-RPT-C
L2A7A:  JP  NZ,REPORT_C  ; jump to REPORT-C with anything else
  ; 'Syntax error'

  LD  H,D ; copy start
  LD  L,E ; to end - just a one character slice.
  JR  L2A94 ; forward to SL-DEFINE.

; ---------------------

	ORG	$2A81
;; SL-SECOND
L2A81:  PUSH  HL  ; save limit length.

  RST 20H ; NEXT_CHAR

  POP HL  ; pop the length.

  CP  $29 ; is character ')' ?  e.g. a$(7 TO )
  JR  Z,L2A94 ; to SL-DEFINE using length as end point.

  POP AF  ; else restore flag.
  CALL  L2ACD ; routine INT-EXP2 gets second expression.

  PUSH  AF  ; save the running flag.

  RST 18H ; GET_CHAR

  LD  H,B ; transfer second parameter
  LD  L,C ; to HL.  e.g. a$(42 to 99)
  CP  $29 ; is character a ')' ?
  JR  NZ,L2A7A  ; to SL-RPT-C if not
  ; 'Syntax error'

; we now have start in DE and an end in HL.

	ORG	$2A94
;; SL-DEFINE
L2A94:  POP AF  ; pop the running flag.
  EX  (SP),HL ; put end point on stack, start address to HL
  ADD HL,DE ; add address of string to the start point.
  DEC HL  ; point to first character of slice.
  EX  (SP),HL ; start address to stack, end point to HL (*)
  AND A ; prepare to subtract.
  SBC HL,DE ; subtract start point from end point.
  LD  BC,$0000  ; default the length result to zero.
  JR  C,L2AA8 ; forward to SL-OVER if start > end.

  INC HL  ; increment the length for inclusive byte.

  AND A ; now test the running flag.
  JP  M,L2A20 ; jump back to REPORT-3 if $FF.
  ; 'Subscript out of range'

  LD  B,H ; transfer the length
  LD  C,L ; to BC.

	ORG	$2AA8
;; SL-OVER
L2AA8:  POP DE  ; restore start address from machine stack ***
  RES 6,(IY+$01)  ; update FLAGS - signal string result for
  ; syntax.

	ORG	$2AAD
;; SL-STORE
L2AAD:  CALL  SYNTAX_Z ; routine SYNTAX-Z  (UNSTACK-Z?)
  RET Z ; return if checking syntax.
  ; but continue to store the string in runtime.

; ------------------------------------
; other than from above, this routine is called from STK-VAR to stack
; a known string array element.
; ------------------------------------

	ORG	$2AB1
;; STK-ST-0
L2AB1:  XOR A ; clear to signal a sliced string or element.

; -------------------------
; this routine is called from chr$, scrn$ etc. to store a simple string result.
; --------------------------

	ORG	$2AB2
STK_STO_STR:  RES 6,(IY+$01)  ; update FLAGS - signal string result.
  ; and continue to store parameters of string.

; ---------------------------------------
; Pass five registers to calculator stack
; ---------------------------------------
; This subroutine puts five registers on the calculator stack.

	ORG	$2AB6
STK_STORE:  PUSH  BC  ; save two registers
  CALL  TEST_5_SP ; routine TEST-5-SP checks room and puts 5
  ; in BC.
  POP BC  ; fetch the saved registers.
  LD  HL,(STKEND)  ; make HL point to first empty location STKEND
  LD  (HL),A  ; place the 5 registers.
  INC HL  ;
  LD  (HL),E  ;
  INC HL  ;
  LD  (HL),D  ;
  INC HL  ;
  LD  (HL),C  ;
  INC HL  ;
  LD  (HL),B  ;
  INC HL  ;
  LD  (STKEND),HL  ; update system variable STKEND.
  RET ; and return.

; -------------------------------------------
; Return result of evaluating next expression
; -------------------------------------------
; This clever routine is used to check and evaluate an integer expression
; which is returned in BC, setting A to $FF, if greater than a limit supplied
; in HL. It is used to check array subscripts, parameters of a string slice
; and the arguments of the DIM command. In the latter case, the limit check
; is not required and H is set to $FF. When checking optional string slice
; parameters, it is entered at the second entry point so as not to disturb
; the running flag A, which may be $00 or $FF from a previous invocation.

	ORG	$2ACC
;; INT-EXP1
L2ACC:  XOR A ; set result flag to zero.

; -> The entry point is here if A is used as a running flag.

	ORG	$2ACD
;; INT-EXP2
L2ACD:  PUSH  DE  ; preserve DE register throughout.
  PUSH  HL  ; save the supplied limit.
  PUSH  AF  ; save the flag.

  CALL  EXPT_1NUM ; routine EXPT-1NUM evaluates expression
  ; at CH_ADD returning if numeric result,
  ; with value on calculator stack.

  POP AF  ; pop the flag.
  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  Z,L2AEB ; forward to I-RESTORE if checking syntax so
  ; avoiding a comparison with supplied limit.

  PUSH  AF  ; save the flag.

  CALL  FIND_INT2 ; routine FIND-INT2 fetches value from
  ; calculator stack to BC producing an error
  ; if too high.

  POP DE  ; pop the flag to D.
  LD  A,B ; test value for zero and reject
  OR  C ; as arrays and strings begin at 1.
  SCF ; set carry flag.
  JR  Z,L2AE8 ; forward to I-CARRY if zero.

  POP HL  ; restore the limit.
  PUSH  HL  ; and save.
  AND A ; prepare to subtract.
  SBC HL,BC ; subtract value from limit.

	ORG	$2AE8
;; I-CARRY
L2AE8:  LD  A,D ; move flag to accumulator $00 or $FF.
  SBC A,$00 ; will set to $FF if carry set.

	ORG	$2AEB
;; I-RESTORE
L2AEB:  POP HL  ; restore the limit.
  POP DE  ; and DE register.
  RET ; return.


; -----------------------
; LD DE,(DE+1) Subroutine
; -----------------------
; This routine just loads the DE register with the contents of the two
; locations following the location addressed by DE.
; It is used to step along the 16-bit dimension sizes in array definitions.
; Note. Such code is made into subroutines to make programs easier to
; write and it would use less space to include the five instructions in-line.
; However, there are so many exchanges going on at the places this is invoked
; that to implement it in-line would make the code hard to follow.
; It probably had a zippier label though as the intention is to simplify the
; program.

	ORG	$2AEE
;; DE,(DE+1)
L2AEE:  EX  DE,HL ;
  INC HL  ;
  LD  E,(HL)  ;
  INC HL  ;
  LD  D,(HL)  ;
  RET ;

; -------------------
; HL=HL*DE Subroutine
; -------------------
; This routine calls the mathematical routine to multiply HL by DE in runtime.
; It is called from STK-VAR and from DIM. In the latter case syntax is not
; being checked so the entry point could have been at the second CALL
; instruction to save a few clock-cycles.

	ORG	$2AF4
;; GET-HL*DE
L2AF4:  CALL  SYNTAX_Z ; routine SYNTAX-Z.
  RET Z ; return if checking syntax.

  CALL  HL_HL_DE ; routine HL-HL*DE.
  JP  C,L1F15 ; jump back to REPORT-4 if over 65535.

  RET ; else return with 16-bit result in HL.

; -----------------
; THE 'LET' COMMAND
; -----------------
; Sinclair BASIC adheres to the ANSI-78 standard and a LET is required in
; assignments e.g. LET a = 1  : LET h$ = "hat".
;
; Long names may contain spaces but not colour controls (when assigned).
; a substring can appear to the left of the equals sign.

; An earlier mathematician Lewis Carroll may have been pleased that
; 10 LET Babies cannot manage crocodiles = Babies are illogical AND
;  Nobody is despised who can manage a crocodile AND Illogical persons
;  are despised
; does not give the 'Nonsense..' error if the three variables exist.
; I digress.

	ORG	$2AFF
LET:  LD  HL,(DEST)  ; fetch system variable DEST to HL.
  BIT 1,(IY+$37)  ; test FLAGX - handling a new variable ?
  JR  Z,L2B66 ; forward to L-EXISTS if not.

; continue for a new variable. DEST points to start in BASIC line.
; from the CLASS routines.

  LD  BC,$0005  ; assume numeric and assign an initial 5 bytes

	ORG	$2B0B
;; L-EACH-CH
L2B0B:  INC BC  ; increase byte count for each relevant
  ; character

	ORG	$2B0C
;; L-NO-SP
L2B0C:  INC HL  ; increase pointer.
  LD  A,(HL)  ; fetch character.
  CP  $20 ; is it a space ?
  JR  Z,L2B0C ; back to L-NO-SP is so.

  JR  NC,L2B1F  ; forward to L-TEST-CH if higher.

  CP  $10 ; is it $00 - $0F ?
  JR  C,L2B29 ; forward to L-SPACES if so.

  CP  $16 ; is it $16 - $1F ?
  JR  NC,L2B29  ; forward to L-SPACES if so.

; it was $10 - $15  so step over a colour code.

  INC HL  ; increase pointer.
  JR  L2B0C ; loop back to L-NO-SP.

; ---

; the branch was to here if higher than space.

	ORG	$2B1F
;; L-TEST-CH
L2B1F:  CALL  L2C88 ; routine ALPHANUM sets carry if alphanumeric
  JR  C,L2B0B ; loop back to L-EACH-CH for more if so.

  CP  $24 ; is it '$' ?
  JP  Z,L2BC0 ; jump forward if so, to L-NEW$
  ; with a new string.

	ORG	$2B29
;; L-SPACES
L2B29:  LD  A,C ; save length lo in A.
  LD  HL,(E_LINE)  ; fetch E_LINE to HL.
  DEC HL  ; point to location before, the variables
  ; end-marker.
  CALL  MAKE_ROOM ; routine MAKE-ROOM creates BC spaces
  ; for name and numeric value.
  INC HL  ; advance to first new location.
  INC HL  ; then to second.
  EX  DE,HL ; set DE to second location.
  PUSH  DE  ; save this pointer.
  LD  HL,(DEST)  ; reload HL with DEST.
  DEC DE  ; point to first.
  SUB $06 ; subtract six from length_lo.
  LD  B,A ; save count in B.
  JR  Z,L2B4F ; forward to L-SINGLE if it was just
  ; one character.

; HL points to start of variable name after 'LET' in BASIC line.

	ORG	$2B3E
;; L-CHAR
L2B3E:  INC HL  ; increase pointer.
  LD  A,(HL)  ; pick up character.
  CP  $21 ; is it space or higher ?
  JR  C,L2B3E ; back to L-CHAR with space and less.

  OR  $20 ; make variable lower-case.
  INC DE  ; increase destination pointer.
  LD  (DE),A  ; and load to edit line.
  DJNZ  L2B3E ; loop back to L-CHAR until B is zero.

  OR  $80 ; invert the last character.
  LD  (DE),A  ; and overwrite that in edit line.

; now consider first character which has bit 6 set

  LD  A,$C0 ; set A 11000000 is xor mask for a long name.
  ; %101  is xor/or  result

; single character numerics rejoin here with %00000000 in mask.
;  %011  will be xor/or result

	ORG	$2B4F
;; L-SINGLE
L2B4F:  LD  HL,(DEST)  ; fetch DEST - HL addresses first character.
  XOR (HL)  ; apply variable type indicator mask (above).
  OR  $20 ; make lowercase - set bit 5.
  POP HL  ; restore pointer to 2nd character.
  CALL  L2BEA ; routine L-FIRST puts A in first character.
  ; and returns with HL holding
  ; new E_LINE-1  the $80 vars end-marker.

	ORG	$2B59
;; L-NUMERIC
L2B59:  PUSH  HL  ; save the pointer.

; the value of variable is deleted but remains after calculator stack.

  RST 28H ;; FP_CALC
  DEFB  $02 ;;delete  ; delete variable value
  DEFB  $38 ;;end-calc

; DE (STKEND) points to start of value.

  POP HL  ; restore the pointer.
  LD  BC,$0005  ; start of number is five bytes before.
  AND A ; prepare for true subtraction.
  SBC HL,BC ; HL points to start of value.
  JR  L2BA6 ; forward to L-ENTER  ==>

; ---


; the jump was to here if the variable already existed.

	ORG	$2B66
;; L-EXISTS
L2B66:  BIT 6,(IY+$01)  ; test FLAGS - numeric or string result ?
  JR  Z,L2B72 ; skip forward to L-DELETE$ -*->
  ; if string result.

; A numeric variable could be simple or an array element.
; They are treated the same and the old value is overwritten.

  LD  DE,$0006  ; six bytes forward points to loc past value.
  ADD HL,DE ; add to start of number.
  JR  L2B59 ; back to L-NUMERIC to overwrite value.

; ---

; -*-> the branch was here if a string existed.

	ORG	$2B72
;; L-DELETE$
L2B72:  LD  HL,(DEST)  ; fetch DEST to HL.
  ; (still set from first instruction)
  LD  BC,(STRLEN)  ; fetch STRLEN to BC.
  BIT 0,(IY+$37)  ; test FLAGX - handling a complete simple
  ; string ?
  JR  NZ,L2BAF  ; forward to L-ADD$ if so.

; must be a string array or a slice in workspace.
; Note. LET a$(3 TO 6) = h$ will assign "hat " if h$ = "hat"
;  and  "hats" if h$ = "hatstand".
;
; This is known as Procrustean lengthening and shortening after a
; character Procrustes in Greek legend who made travellers sleep in his bed,
; cutting off their feet or stretching them so they fitted the bed perfectly.
; The bloke was hatstand and slain by Theseus.

  LD  A,B ; test if length
  OR  C ; is zero and
  RET Z ; return if so.

  PUSH  HL  ; save pointer to start.

  RST 30H ; BC_SPACES creates room.
  PUSH  DE  ; save pointer to first new location.
  PUSH  BC  ; and length  (*)
  LD  D,H ; set DE to point to last location.
  LD  E,L ;
  INC HL  ; set HL to next location.
  LD  (HL),$20  ; place a space there.
  LDDR  ; copy bytes filling with spaces.

  PUSH  HL  ; save pointer to start.
  CALL  STK_FETCH ; routine STK-FETCH start to DE,
  ; length to BC.
  POP HL  ; restore the pointer.
  EX  (SP),HL ; (*) length to HL, pointer to stack.
  AND A ; prepare for true subtraction.
  SBC HL,BC ; subtract old length from new.
  ADD HL,BC ; and add back.
  JR  NC,L2B9B  ; forward if it fits to L-LENGTH.

  LD  B,H ; otherwise set
  LD  C,L ; length to old length.
  ; "hatstand" becomes "hats"

	ORG	$2B9B
;; L-LENGTH
L2B9B:  EX  (SP),HL ; (*) length to stack, pointer to HL.
  EX  DE,HL ; pointer to DE, start of string to HL.
  LD  A,B ; is the length zero ?
  OR  C ;
  JR  Z,L2BA3 ; forward to L-IN-W/S if so
  ; leaving prepared spaces.

  LDIR  ; else copy bytes overwriting some spaces.

	ORG	$2BA3
;; L-IN-W/S
L2BA3:  POP BC  ; pop the new length.  (*)
  POP DE  ; pop pointer to new area.
  POP HL  ; pop pointer to variable in assignment.
  ; and continue copying from workspace
  ; to variables area.

; ==> branch here from  L-NUMERIC

	ORG	$2BA6
;; L-ENTER
L2BA6:  EX  DE,HL ; exchange pointers HL=STKEND DE=end of vars.
  LD  A,B ; test the length
  OR  C ; and make a
  RET Z ; return if zero (strings only).

  PUSH  DE  ; save start of destination.
  LDIR  ; copy bytes.
  POP HL  ; address the start.
  RET ; and return.

; ---

; the branch was here from L-DELETE$ if an existing simple string.
; register HL addresses start of string in variables area.

	ORG	$2BAF
;; L-ADD$
L2BAF:  DEC HL  ; point to high byte of length.
  DEC HL  ; to low byte.
  DEC HL  ; to letter.
  LD  A,(HL)  ; fetch masked letter to A.
  PUSH  HL  ; save the pointer on stack.
  PUSH  BC  ; save new length.
  CALL  L2BC6 ; routine L-STRING adds new string at end
  ; of variables area.
  ; if no room we still have old one.
  POP BC  ; restore length.
  POP HL  ; restore start.
  INC BC  ; increase
  INC BC  ; length by three
  INC BC  ; to include character and length bytes.
  JP  RECLAIM_2 ; jump to indirect exit via RECLAIM-2
  ; deleting old version and adjusting pointers.

; ---

; the jump was here with a new string variable.

	ORG	$2BC0
;; L-NEW$
L2BC0:  LD  A,$DF ; indicator mask %11011111 for
  ;  %010xxxxx will be result
  LD  HL,(DEST)  ; address DEST first character.
  AND (HL)  ; combine mask with character.

	ORG	$2BC6
;; L-STRING
L2BC6:  PUSH  AF  ; save first character and mask.
  CALL  STK_FETCH ; routine STK-FETCH fetches parameters of
  ; the string.
  EX  DE,HL ; transfer start to HL.
  ADD HL,BC ; add to length.
  PUSH  BC  ; save the length.
  DEC HL  ; point to end of string.
  LD  (DEST),HL  ; save pointer in DEST.
  ; (updated by POINTERS if in workspace)
  INC BC  ; extra byte for letter.
  INC BC  ; two bytes
  INC BC  ; for the length of string.
  LD  HL,(E_LINE)  ; address E_LINE.
  DEC HL  ; now end of VARS area.
  CALL  MAKE_ROOM ; routine MAKE-ROOM makes room for string.
  ; updating pointers including DEST.
  LD  HL,(DEST)  ; pick up pointer to end of string from DEST.
  POP BC  ; restore length from stack.
  PUSH  BC  ; and save again on stack.
  INC BC  ; add a byte.
  LDDR  ; copy bytes from end to start.
  EX  DE,HL ; HL addresses length low
  INC HL  ; increase to address high byte
  POP BC  ; restore length to BC
  LD  (HL),B  ; insert high byte
  DEC HL  ; address low byte location
  LD  (HL),C  ; insert that byte
  POP AF  ; restore character and mask

	ORG	$2BEA
;; L-FIRST
L2BEA:  DEC HL  ; address variable name
  LD  (HL),A  ; and insert character.
  LD  HL,(E_LINE)  ; load HL with E_LINE.
  DEC HL  ; now end of VARS area.
  RET ; return

; ------------------------------------
; Get last value from calculator stack
; ------------------------------------
;
;

	ORG	$2BF1
STK_FETCH:  LD  HL,(STKEND)  ; STKEND
  DEC HL  ;
  LD  B,(HL)  ;
  DEC HL  ;
  LD  C,(HL)  ;
  DEC HL  ;
  LD  D,(HL)  ;
  DEC HL  ;
  LD  E,(HL)  ;
  DEC HL  ;
  LD  A,(HL)  ;
  LD  (STKEND),HL  ; STKEND
  RET ;

; ------------------
; Handle DIM command
; ------------------
; e.g. DIM a(2,3,4,7): DIM a$(32) : DIM b$(20,2,768) : DIM c$(20000)
; the only limit to dimensions is memory so, for example,
; DIM a(2,2,2,2,2,2,2,2,2,2,2,2,2) is possible and creates a multi-
; dimensional array of zeros. String arrays are initialized to spaces.
; It is not possible to erase an array, but it can be re-dimensioned to
; a minimal size of 1, after use, to free up memory.

	ORG	$2C02
DIM:  CALL  LOOK_VARS ; routine LOOK-VARS

	ORG	$2C05
;; D-RPORT-C
L2C05:  JP  NZ,REPORT_C  ; jump to REPORT-C if a long-name variable.
  ; DIM lottery numbers(49) doesn't work.

  CALL  SYNTAX_Z ; routine SYNTAX-Z
  JR  NZ,L2C15  ; forward to D-RUN in runtime.

  RES 6,C ; signal 'numeric' array even if string as
  ; this simplifies the syntax checking.

  CALL  STK_VAR ; routine STK-VAR checks syntax.
  CALL  CHECK_END ; routine CHECK-END performs early exit ->

; the branch was here in runtime.

	ORG	$2C15
;; D-RUN
L2C15:  JR  C,L2C1F ; skip to D-LETTER if variable did not exist.
  ; else reclaim the old one.

  PUSH  BC  ; save type in C.
  CALL  NEXT_ONE ; routine NEXT-ONE find following variable
  ; or position of $80 end-marker.
  CALL  RECLAIM_2 ; routine RECLAIM-2 reclaims the
  ; space between.
  POP BC  ; pop the type.

	ORG	$2C1F
;; D-LETTER
L2C1F:  SET 7,C ; signal array.
  LD  B,$00 ; initialize dimensions to zero and
  PUSH  BC  ; save with the type.
  LD  HL,$0001  ; make elements one character presuming string
  BIT 6,C ; is it a string ?
  JR  NZ,L2C2D  ; forward to D-SIZE if so.

  LD  L,$05 ; make elements 5 bytes as is numeric.

	ORG	$2C2D
;; D-SIZE
L2C2D:  EX  DE,HL ; save the element size in DE.

; now enter a loop to parse each of the integers in the list.

	ORG	$2C2E
;; D-NO-LOOP
L2C2E:  RST 20H ; NEXT_CHAR
  LD  H,$FF ; disable limit check by setting HL high
  CALL  L2ACC ; routine INT-EXP1
  JP  C,L2A20 ; to REPORT-3 if > 65280 and then some
  ; 'Subscript out of range'

  POP HL  ; pop dimension counter, array type
  PUSH  BC  ; save dimension size ***
  INC H ; increment the dimension counter
  PUSH  HL  ; save the dimension counter
  LD  H,B ; transfer size
  LD  L,C ; to HL
  CALL  L2AF4 ; routine GET-HL*DE multiplies dimension by
  ; running total of size required initially
  ; 1 or 5.
  EX  DE,HL ; save running total in DE

  RST 18H ; GET_CHAR
  CP  $2C ; is it ',' ?
  JR  Z,L2C2E ; loop back to D-NO-LOOP until all dimensions
  ; have been considered

; when loop complete continue.

  CP  $29 ; is it ')' ?
  JR  NZ,L2C05  ; to D-RPORT-C with anything else
  ; 'Syntax error'


  RST 20H ; NEXT_CHAR advances to next statement/CR

  POP BC  ; pop dimension counter/type
  LD  A,C ; type to A

; now calculate space required for array variable

  LD  L,B ; dimensions to L since these require 16 bits
  ; then this value will be doubled
  LD  H,$00 ; set high byte to zero

; another four bytes are required for letter(1), total length(2), number of
; dimensions(1) but since we have yet to double allow for two

  INC HL  ; increment
  INC HL  ; increment

  ADD HL,HL ; now double giving 4 + dimensions * 2

  ADD HL,DE ; add to space required for array contents

  JP  C,L1F15 ; to REPORT-4 if > 65535
  ; 'Memory full'

  PUSH  DE  ; save data space
  PUSH  BC  ; save dimensions/type
  PUSH  HL  ; save total space
  LD  B,H ; total space
  LD  C,L ; to BC
  LD  HL,(E_LINE)  ; address E_LINE - first location after
  ; variables area
  DEC HL  ; point to location before - the $80 end-marker
  CALL  MAKE_ROOM ; routine MAKE-ROOM creates the space if
  ; memory is available.

  INC HL  ; point to first new location and
  LD  (HL),A  ; store letter/type

  POP BC  ; pop total space
  DEC BC  ; exclude name
  DEC BC  ; exclude the 16-bit
  DEC BC  ; counter itself
  INC HL  ; point to next location the 16-bit counter
  LD  (HL),C  ; insert low byte
  INC HL  ; address next
  LD  (HL),B  ; insert high byte

  POP BC  ; pop the number of dimensions.
  LD  A,B ; dimensions to A
  INC HL  ; address next
  LD  (HL),A  ; and insert "No. of dims"

  LD  H,D ; transfer DE space + 1 from make-room
  LD  L,E ; to HL
  DEC DE  ; set DE to next location down.
  LD  (HL),$00  ; presume numeric and insert a zero
  BIT 6,C ; test bit 6 of C. numeric or string ?
  JR  Z,L2C7C ; skip to DIM-CLEAR if numeric

  LD  (HL),$20  ; place a space character in HL

	ORG	$2C7C
;; DIM-CLEAR
L2C7C:  POP BC  ; pop the data length

  LDDR  ; LDDR sets to zeros or spaces

; The number of dimensions is still in A.
; A loop is now entered to insert the size of each dimension that was pushed
; during the D-NO-LOOP working downwards from position before start of data.

;; DIM-SIZES
L2C7F:  POP BC  ; pop a dimension size  ***
  LD  (HL),B  ; insert high byte at position
  DEC HL  ; next location down
  LD  (HL),C  ; insert low byte
  DEC HL  ; next location down
  DEC A ; decrement dimension counter
  JR  NZ,L2C7F  ; back to DIM-SIZES until all done.

  RET ; return.

; -----------------------------
; Check whether digit or letter
; -----------------------------
; This routine checks that the character in A is alphanumeric
; returning with carry set if so.

	ORG	$2C88
;; ALPHANUM
L2C88:  CALL  NUMERIC ; routine NUMERIC will reset carry if so.
  CCF ; Complement Carry Flag
  RET C ; Return if numeric else continue into
  ; next routine.

; This routine checks that the character in A is alphabetic

	ORG	$2C8D
ALPHA:  CP  $41 ; less than 'A' ?
  CCF ; Complement Carry Flag
  RET NC  ; return if so

  CP  $5B ; less than 'Z'+1 ?
  RET C ; is within first range

  CP  $61 ; less than 'a' ?
  CCF ; Complement Carry Flag
  RET NC  ; return if so.

  CP  $7B ; less than 'z'+1 ?
  RET ; carry set if within a-z.

; -------------------------
; Decimal to floating point
; -------------------------
; This routine finds the floating point number represented by an expression
; beginning with BIN, '.' or a digit.
; Note that BIN need not have any '0's or '1's after it.
; BIN is really just a notational symbol and not a function.

	ORG	$2C9B
;; DEC-TO-FP
L2C9B:  CP  $C4 ; 'BIN' token ?
  JR  NZ,L2CB8  ; to NOT-BIN if not

  LD  DE,$0000  ; initialize 16 bit buffer register.

	ORG	$2CA2
;; BIN-DIGIT
L2CA2:  RST 20H ; NEXT_CHAR
  SUB $31 ; '1'
  ADC A,$00 ; will be zero if '1' or '0'
  ; carry will be set if was '0'
  JR  NZ,L2CB3  ; forward to BIN-END if result not zero

  EX  DE,HL ; buffer to HL
  CCF ; Carry now set if originally '1'
  ADC HL,HL ; shift the carry into HL
  JP  C,REPORT_6 ; to REPORT-6 if overflow - too many digits
  ; after first '1'. There can be an unlimited
  ; number of leading zeros.
  ; 'Overflow' - raise an error

  EX  DE,HL ; save the buffer
  JR  L2CA2 ; back to BIN-DIGIT for more digits

; ---

	ORG	$2CB3
;; BIN-END
L2CB3:  LD  B,D ; transfer 16 bit buffer
  LD  C,E ; to BC register pair.
  JP  STACK_BC ; JUMP to STACK-BC to put on calculator stack

; ---

; continue here with .1,  42, 3.14, 5., 2.3 E -4

	ORG	$2CB8
;; NOT-BIN
L2CB8:  CP  $2E ; '.' - leading decimal point ?
  JR  Z,L2CCB ; skip to DECIMAL if so.

  CALL  INT_TO_FP ; routine INT-TO-FP to evaluate all digits
  ; This number 'x' is placed on stack.
  CP  $2E ; '.' - mid decimal point ?

  JR  NZ,L2CEB  ; to E-FORMAT if not to consider that format

  RST 20H ; NEXT_CHAR
  CALL  NUMERIC ; routine NUMERIC returns carry reset if 0-9

  JR  C,L2CEB ; to E-FORMAT if not a digit e.g. '1.'

  JR  L2CD5 ; to DEC-STO-1 to add the decimal part to 'x'

; ---

; a leading decimal point has been found in a number.

	ORG	$2CCB
;; DECIMAL
L2CCB:  RST 20H ; NEXT_CHAR
  CALL  NUMERIC ; routine NUMERIC will reset carry if digit

	ORG	$2CCF
;; DEC-RPT-C
L2CCF:  JP  C,REPORT_C ; to REPORT-C if just a '.'
  ; raise 'Syntax error'

; since there is no leading zero put one on the calculator stack.

  RST 28H ;; FP_CALC
  DEFB  $A0 ;;stk-zero  ; 0.
  DEFB  $38 ;;end-calc

; If rejoining from earlier there will be a value 'x' on stack.
; If continuing from above the value zero.
; Now store 1 in mem-0.
; Note. At each pass of the digit loop this will be divided by ten.

	ORG	$2CD5
;; DEC-STO-1
L2CD5:  RST 28H ;; FP_CALC
  DEFB  $A1 ;;stk-one ;x or 0,1.
  DEFB  $C0 ;;st-mem-0  ;x or 0,1.
  DEFB  $02 ;;delete  ;x or 0.
  DEFB  $38 ;;end-calc


	ORG	$2CDA
;; NXT-DGT-1
L2CDA:  RST 18H ; GET_CHAR
  CALL  STK_DIGIT ; routine STK-DIGIT stacks single digit 'd'
  JR  C,L2CEB ; exit to E-FORMAT when digits exhausted  >


  RST 28H ;; FP_CALC ;x or 0,d. first pass.
  DEFB  $E0 ;;get-mem-0  ;x or 0,d,1.
  DEFB  $A4 ;;stk-ten  ;x or 0,d,1,10.
;;; DEFB  $05 ;;division ;
  DEFB  $04 ;;+ multiply ;x or 0,d,1*10.
  DEFB  $C0 ;;st-mem-0 ;x or 0,d,1*10.
;;; DEFB  $04 ;;multiply ;
  DEFB  $05 ;;+ division ;x or 0,d/10.
  DEFB  $0F ;;addition ;x or 0 + d/10.
  DEFB  $38 ;;end-calc last value.

  RST 20H ; NEXT_CHAR  moves to next character
  JR  L2CDA ; back to NXT-DGT-1

; ---

; although only the first pass is shown it can be seen that at each pass
; the new less significant digit is multiplied by an increasingly smaller
; factor (1/100, 1/1000, 1/10000 ... ) before being added to the previous
; last value to form a new last value.

; Finally see if an exponent has been input.

	ORG	$2CEB
;; E-FORMAT
L2CEB:  CP  $45 ; is character 'E' ?
  JR  Z,L2CF2 ; to SIGN-FLAG if so

  CP  $65 ; 'e' is acceptable as well.
  RET NZ  ; return as no exponent.

	ORG	$2CF2
;; SIGN-FLAG
L2CF2:  LD  B,$FF ; initialize temporary sign byte to $FF

  RST 20H ; NEXT_CHAR
  CP  $2B ; is character '+' ?
  JR  Z,L2CFE ; to SIGN-DONE

  CP  $2D ; is character '-' ?
  JR  NZ,L2CFF  ; to ST-E-PART as no sign

  INC B ; set sign to zero

; now consider digits of exponent.
; Note. incidentally this is the only occasion in Spectrum BASIC when an
; expression may not be used when a number is expected.

	ORG	$2CFE
;; SIGN-DONE
L2CFE:  RST 20H ; NEXT_CHAR

	ORG	$2CFF
;; ST-E-PART
L2CFF:  CALL  NUMERIC ; routine NUMERIC
  JR  C,L2CCF ; to DEC-RPT-C if not
  ; raise 'Syntax error'.

  PUSH  BC  ; save sign (in B)
  CALL  INT_TO_FP ; routine INT-TO-FP places exponent on stack
  CALL  FP_TO_A ; routine FP-TO-A  transfers it to A
  POP BC  ; restore sign
  JP  C,REPORT_6 ; to REPORT-6 if overflow (over 255)
  ; raise 'Overflow'.

  AND A ; set flags
  JP  M,REPORT_6 ; to REPORT-6 if over '127'.
  ; raise 'Overflow'.
  ; 127 is still way too high and it is
  ; impossible to enter an exponent greater
  ; than 39 from the keyboard. The error gets
  ; raised later in E-TO-FP so two different
  ; error messages depending how high A is.

  INC B ; $FF to $00 or $00 to $01 - expendable now.
  JR  Z,L2D18 ; forward to E-FP-JUMP if exponent positive

  NEG ; Negate the exponent.

	ORG	$2D18
;; E-FP-JUMP
L2D18:
;;;	JP	E_TO_FP		; JUMP forward to E-TO-FP

	JR	E_TO_FP		;+ Relative jumpforward

; ---

; ---------------------
; THE 'NUMERIC' SUBROUTINE
; ---------------------
; This routine checks that the ASCII character in A is numeric
; returning with carry reset if so.

	ORG	$2D1A
NUMERIC0:	LD	A,(HL)		;+ New entry point saves 2 bytes.

	ORG	$2D1B
NUMERIC:  CP  $30 ; '0'
  RET C ; return if less than zero character.

  CP  $3A ; The upper test is '9'
  CCF ; Complement Carry Flag
  RET ; Return - carry clear if character '0' - '9'

; -----------
; Stack Digit
; -----------
; This subroutine is called from INT_TO_FP and DEC_TO_FP to stack a digit
; on the calculator stack.

	ORG	$2D22
STK_DIGIT:  CALL  NUMERIC ; routine NUMERIC
  RET C ; return if not numeric character

  SUB $30 ; convert from ASCII to digit

; -----------------
; Stack accumulator
; -----------------
;
;

	ORG	$2D28
STACK_A:  LD  C,A ; transfer to C
  LD  B,$00 ; and make B zero

; ----------------------
; Stack BC register pair
; ----------------------
;

	ORG	$2D2B
STACK_BC:  LD  IY,ERR_NR  ; re-initialize ERR_NR

  XOR A ; clear to signal small integer
  LD  E,A ; place in E for sign
  LD  D,C ; LSB to D
  LD  C,B ; MSB to C
  LD  B,A ; last byte not used
  CALL  STK_STORE ; routine STK-STORE

  RST 28H ;; FP_CALC
  DEFB  $38 ;;end-calc  make HL = STKEND-5

  AND A ; clear carry
  RET ; before returning

; -------------------------
; Integer to floating point
; -------------------------
; This routine places one or more digits found in a BASIC line
; on the calculator stack multiplying the previous value by ten each time
; before adding in the new digit to form a last value on calculator stack.

	ORG	$2D3B
INT_TO_FP:  PUSH  AF  ; save first character

  RST 28H ;; FP_CALC
  DEFB  $A0 ;;stk-zero  ; v=0. initial value
  DEFB  $38 ;;end-calc

  POP AF  ; fetch first character back.

	ORG	$2D40
NXT_DGT_2:
	CALL	STK_DIGIT		; puts 0-9 on stack
	RET	C		; will return when character is not numeric >
	RST	28H		;; FP_CALC	; v, d.
	DEFB	$01		;;exchange	; d, v.
	DEFB	$A4		;;stk-ten		; d, v, 10.
	DEFB	$04		;;multiply	; d, v*10.
	DEFB	$0F		;;addition	; d + v*10 = newvalue
	DEFB	$38		;;end-calc	; v.
	CALL	CH_ADD_P1		; get next character
	JR	NXT_DGT_2		; back to process as a digit

;*********************************
;** Part 9. ARITHMETIC ROUTINES **
;*********************************

; Comments in this section have been completed with reference to 'The
; Complete Spectrum ROM Disassembly' by Dr Ian Logan and Dr Frank O'Hara.

; --------------------------
; E-format to floating point
; --------------------------
; This subroutine is used by the PRINT_FP routine and the decimal to FP
; routines to stack a number expressed in exponent format.
; Note. Though not used by the ROM as such, it has also been set up as
; a unary calculator literal but this will not work as the accumulator
; is not available from within the calculator.

; on entry there is a value x on the calculator stack and an exponent of ten
; in A.  The required value is x + 10 ^ A

	ORG	$2D4F
E_TO_FP:	RLCA			; this will set the  x.
	RRCA			; carry if bit 7 is set
	JR	NC,E_SAVE	 ; to E-SAVE  if positive.
	CPL			; make negative positive
	INC	A		; without altering carry.

	ORG	$2D55
E_SAVE:	PUSH	AF		; save positive exp and sign in carry
	LD	HL,MEM_0		;
	CALL	FP_0_1		; places an integer zero, if no carry,
				; else a one in mem-0 as a sign flag
	RST	28H		;; FP_CALC
	DEFB	$A4		;;stk-ten		x, 10.
	DEFB	$38		;;end-calc
	POP	AF		; pop the exponent.

; now enter a loop

	ORG	$2D60
E_LOOP:	SRL	A		; 0>76543210>C
	JR	NC,E_TST_END	; forward if no bit
	PUSH	AF		; save shifted exponent.
	RST	28H		;; FP_CALC
	DEFB	$C1		;;st-mem-1	x, 10.
	DEFB	$E0		;;get-mem-0	x, 10, (0/1).
	DEFB	$00		;;jump-true
	DEFB	$04		;;to E_DIVSN
	DEFB	$04		;;multiply	x*10.
	DEFB	$33		;;jump
	DEFB	$02		;;to E_FETCH

	ORG	$2D6D
E_DIVSN:	DEFB	$05		;;division	x/10.

	ORG	$2D6F
E_FETCH:	DEFB	$E1		;;get-mem-1	x/10 or x*10, 10.
	DEFB	$38		;;end-calc	new x, 10.
	POP	AF		; restore shifted exponent

; the loop branched to here with no carry

	ORG	$2D71
E_TST_END:
	JR	Z,E_END		; jump if A emptied of bits
	PUSH	AF		; re-save shifted exponent
	RST	28H		;; FP_CALC
	DEFB	$31		;;duplicate	new x, 10, 10.
	DEFB	$04		;;multiply	new x, 100.
	DEFB	$38		;;end-calc
	POP	AF		; restore shifted exponent
	JR	E_LOOP		; back until all bits done.

; ---

; although only the first pass is shown it can be seen that for each set bit
; representing a power of two, x is multiplied or divided by the
; corresponding power of ten.

	ORG	$2D7B
E_END:	RST	28H		;; FP_CALC	final x, factor.
	DEFB	$02		;;delete		final x.
	DEFB	$38		;;end-calc	x.
	RET			; return

; -------------
; Fetch integer
; -------------
; This routine is called by the mathematical routines - FP-TO-BC, PRINT-FP,
; mult, re-stack and negate to fetch an integer from address HL.
; HL points to the stack or a location in MEM and no deletion occurs.
; If the number is negative then a similar process to that used in INT-STORE
; is used to restore the twos complement number to normal in DE and a sign
; in C.

	ORG	$2D7F
INT_FETCH:
	INC	HL		; skip zero indicator.
	LD	C,(HL)		; fetch sign to C
	INC	HL		; address low byte
	LD	A,(HL)		; fetch to A
	XOR	C		; two's complement
	SUB	C		;
	LD	E,A		; place in E
	INC	HL		; address high byte
	LD	A,(HL)		; fetch to A
	ADC	A,C		; two's complement
	XOR	C		;
	LD	D,A		; place in D
	RET			; return

; ------------------------
; Store a positive integer
; ------------------------
; This entry point is not used in this ROM but would
; store any integer as positive.

	ORG	$2D8C
P_INT_STO:
	LD	C,$00		; make sign byte positive and continue

; -------------
; Store integer
; -------------
; this routine stores an integer in DE at address HL.
; It is called from mult, truncate, negate and sgn.
; The sign byte $00 +ve or $FF -ve is in C.
; If negative, the number is stored in 2's complement form so that it is
; ready to be added.

	ORG	$2D8E
INT_STORE:
	PUSH	HL		; preserve HL
	LD	(HL),$00		; first byte zero shows integer not exponent
	INC	HL		;
	LD	(HL),C		; then store the sign byte
	INC	HL		;
				; e.g.		+1             -1
	LD	A,E		; fetch low byte	00000001       00000001
	XOR	C		; xor sign	00000000   or  11111111
				; gives		00000001   or  11111110
	SUB	C		; sub sign	00000000   or  11111111
				; gives		00000001>0 or  11111111>C
	LD	(HL),A		; store 2's complement.
	INC	HL		;
	LD	A,D		; high byte	00000000       00000000
	ADC	A,C		; sign		00000000<0     11111111<C
				; gives		00000000   or  00000000
	XOR	C		; xor sign	00000000       11111111
	LD	(HL),A		; store 2's complement.
	INC	HL		;
	LD	(HL),$00		; last byte always zero for integers.
				; is not used and need not be looked at when
				; testing for zero but comes into play should
				; an integer be converted to fp.
	POP	HL		; restore HL
	RET			; return.

; -----------------------------
; Floating point to BC register
; -----------------------------
; This routine gets a floating point number e.g. 127.4 from the calculator
; stack to the BC register.

	ORG	$2DA2
FP_TO_BC:	RST	28H		;; FP_CALC	set HL to
	DEFB	$38		;;end-calc	point to last value.
	LD	A,(HL)		; get first of 5 bytes
	AND	A		; and test
	JR	Z,FP_DELETE	; forward if an integer

; The value is first rounded up and then converted to integer.

	RST	28H		;; FP_CALC	x.
	DEFB	$A2		;;stk-half	x. 1/2.
	DEFB	$0F		;;addition	x + 1/2.
	DEFB	$27		;;int		int(x + .5)
	DEFB	$38		;;end-calc

; now delete but leave HL pointing at integer

	ORG	$2DAD
FP_DELETE:
	RST	28H		;; FP_CALC
	DEFB	$02		;;delete
	DEFB	$38		;;end-calc
	PUSH	HL		; save pointer.
	PUSH	DE		; and STKEND.
	EX	DE,HL		; make HL point to exponent/zero indicator
	LD	B,(HL)		; indicator to B
	CALL	INT_FETCH	; gets int in DE sign byte to C
				; but meaningless values if a large integer
	XOR	A		; clear A
	SUB	B		; subtract indicator byte setting carry
				; if not a small integer.
	BIT	7,C		; test a bit of the sign byte setting zero
				; if positive.
	LD	B,D		; transfer int
	LD	C,E		; to BC
	LD	A,E		; low byte to A as a useful return value.
	POP	DE		; pop STKEND
	POP	HL		; and pointer to last value
	RET			; return
				; if carry is set then the number was too big.

; ------------
; LOG(2^A)
; ------------
; This routine is used when printing floating point numbers to calculate
; the number of digits before the decimal point.

; first convert a one-byte signed integer to its five byte form.

	ORG	$2DC1
LOG_2PA:	LD	D,A		; store a copy of A in D.
	RLA			; test sign bit of A.
	SBC	A,A		; now $FF if negative or $00
	LD	E,A		; sign byte to E.
	LD	C,A		; and to C
	XOR	A		; clear A
	LD	B,A		; and B.
	CALL	STK_STORE		; stacks number AEDCB

; so 00 00 XX 00 00 (positive) or 00 FF XX FF 00 (negative).
; i.e. integer indicator, sign byte, low, high, unused.

; now multiply exponent by log to the base 10 of two.

	RST	28H		;; FP_CALC
	DEFB	$34		;;stk-data	.30103 (log 2)
	DEFB	$EF		;;Exponent: $7F, Bytes: 4
	DEFB	$1A,$20,$9A,$85	;;
	DEFB	$04		;;multiply
	DEFB	$27		;;int
	DEFB	$38		;;end-calc

; -------------------
; Floating point to A
; -------------------
; this routine collects a floating point number from the stack into the
; accumulator returning carry set if not in range 0 - 255.
; Not all the calling routines raise an error with overflow so no attempt
; is made to produce an error report here.

	ORG	$2DD5
FP_TO_A:	CALL	FP_TO_BC		; returns with C in A also.
	RET	C		; return with carry set if > 65535, overflow
	PUSH	AF		; save the value and flags
	DEC	B		; and test that
	INC	B		; the high byte is zero.
	JR	Z,FP_A_END	; forward if zero

; else there has been 8-bit overflow

	POP	AF		; retrieve the value
	SCF			; set carry flag to show overflow
	RET			; and return.

; ---

	ORG	$2DE1
FP_A_END:	POP	AF		; restore value and success flag and
	RET			; return.


; -----------------------------
; Print a floating point number
; -----------------------------
; Not a trivial task.
; Begin by considering whether to print a leading sign for negative numbers.

	ORG	$2DE3
PRINT_FP:	RST	28H		;; FP_CALC
	DEFB	$31		;;duplicate
	DEFB	$36		;;less-0
	DEFB	$00		;;jump-true
	DEFB	$0B		;;to PF_NEGTVE
	DEFB	$31		;;duplicate
	DEFB	$37		;;greater-0
	DEFB	$00		;;jump-true
	DEFB	$0D		;;to PF_POSTVE

; must be zero itself

	DEFB	$02		;;delete
	DEFB	$38		;;end-calc
	LD	A,$30		; prepare the character '0'
	RST	10H		; PRINT_A
	RET			; return. ->
; ---

	ORG	$2DF2
PF_NEGTVE:
	DEFB	$2A		;;abs
	DEFB	$38		;;end-calc
	LD	A,$2D		; the character '-'
	RST	10H		; PRINT_A

; and continue to print the now positive number.

	RST	28H		;; FP_CALC

	ORG	$2DF8
PF_POSTVE:
	DEFB	$A0		;;stk-zero	x,0. begin by
	DEFB	$C3		;;st-mem-3	x,0. clearing a temporary
	DEFB	$C4		;;st-mem-4	x,0. output buffer to
	DEFB	$C5		;;st-mem-5	x,0. fifteen zeros.
	DEFB	$02		;;delete x.
	DEFB	$38		;;end-calc x.
	EXX			; in case called from 'str$' then save the
	PUSH	HL		; pointer to whatever comes after
	EXX			; str$ as HL' will be used.

; now enter a loop?

	ORG	$2E01
PF_LOOP:	RST	28H		;; FP_CALC
	DEFB	$31		;;duplicate	x,x.
	DEFB	$27		;;int		x,int x.
	DEFB	$C2		;;st-mem-2	x,int x.
	DEFB	$03		;;subtract	x-int x. fractional part.
	DEFB	$E2		;;get-mem-2	x-int x, int x.
	DEFB	$01		;;exchange	int x, x-int x.
	DEFB	$C2		;;st-mem-2	int x, x-int x.
	DEFB	$02		;;delete		int x.
	DEFB	$38		;;end-calc	int x.
				;
				; mem-2 holds the fractional part.

; HL points to last value int x

	LD	A,(HL)		; fetch exponent of int x.
	AND	A		; test
	JR	NZ,PF_LARGE	; forward if a large integer > 65535

; continue with small positive integer components in range 0 - 65535
; if original number was say .999 then this integer component is zero.

	CALL	INT_FETCH 	; gets x in DE (but x is not deleted)
	LD	B,$10		; set B, bit counter, to 16d
	LD	A,D		; test if
	AND	A		; high byte is zero
	JR	NZ,PF_SAVE	; forward if 16-bit integer.

; and continue with integer in range 0 - 255.

	OR	E		; test the low byte for zero
				; i.e. originally just point something or other.
	JR	Z,PF_SMALL	; forward if so

;

	LD	D,E		; transfer E to D
	LD	B,$08		; and reduce the bit counter to 8.

	ORG	$2E1E
PF_SAVE:	PUSH	DE		; save the part before decimal point.
	EXX			;
	POP	DE		; and pop in into D'E'
	EXX			;
	JR	PF_BITS		; forward to

; ---------------------

; the branch was here when 'int x' was found to be zero as in say 0.5.
; The zero has been fetched from the calculator stack but not deleted and
; this should occur now. This omission leaves the stack unbalanced and while
; that causes no problems with a simple PRINT statement, it will if str$ is
; being used in an expression e.g. "2" + STR$ 0.5 gives the result "0.5"
; instead of the expected result "20.5".
; A DEFB 02 delete is required immediately on using the calculator.

	ORG	$2E24
PF_SMALL:	RST	28H		;; FP_CALC	int x = 0.

	DEFB	$02		;;+ delete	(see above)

	DEFB	$E2		;;get-mem-2	int x = 0, x-int x.
	DEFB	$38		;;end-calc
	LD	A,(HL)		; fetch exponent of positive fractional number
	SUB	$7E		; subtract
	CALL	LOG_2PA		; routine LOG(2^A) calculates leading digits.
	LD	D,A		; transfer count to D
	LD	A,(MEM_5 + 1)	; The current count is collected
	SUB	D		; from the second byte of MEM_5
	LD	(MEM_5 + 1),A	; and n is subtracted from it.
	LD	A,D		; n is copied from D to A.
	CALL	E_TO_FP		; x =f*10^n is formed and stacked.
	RST	28H		;; FP_CALC	i, x
	DEFB	$31		;;duplicate	i, x, x	
	DEFB	$27		;;int		i, x, (INT (x) = i2
	DEFB	$C1		;;st-mem-1	(i2 is copied to MEM_1)
	DEFB	$03		;;subtract	i, x - i2
	DEFB	$E1		;;get-mem-1	i, x - i2, i2
	DEFB	$38		;;end-calc	i, f2, i2 (f2 = x - i2)
	CALL	FP_TO_A		; i2 is transferred from the stack to A
	PUSH	HL		; save HL
	LD	(MEM_3),A		; i2 is stored in the first byte of
				; MEM_3: a digit for printing.
	DEC	A		; i2 will not count as a digit for
	RLA			; printing if it is zero; A is
	SBC	A,A		; manipulated so that zero will
	INC	A		; produce zero but a non-zero
				; digit will produce 1.
	LD	HL,MEM_5		; address leading digit counter
	LD	(HL),A		; store counter
	INC	HL		; address MEM_5 + 1 total digits
	ADD	A,(HL)		; add counter to contents
	LD	(HL),A		; and store updated value
	POP	HL		; restore HL

;;;	JP	PF_FRACTN		; forward

	JR	PF_FRACTN		; forward

; ---

; Note. while it would be pedantic to comment on every occasion a JP
; instruction could be replaced with a JR instruction, this applies to the
; above, which is useful if you wish to correct the unbalanced stack error
; by inserting a 'DEFB 02 delete' at L2E25, and maintain main addresses.

; the branch was here with a large positive integer > 65535 e.g. 123456789
; the accumulator holds the exponent.

	ORG	$2E56
PF_LARGE:	SUB	$80		; make exponent positive
	CP	$1C		; compare to 28
	JR	C,PF_MEDIUM	; jump if integer <= 2^27
	CALL	LOG_2PA		; routine LOG(2^A)
	SUB	$07		; reduced to n - 7.
	LD	B,A		; then copied to B.
	LD	HL,MEM_5 + 1	; the leading digits counter.
	ADD	A,(HL)		; add A to contents
	LD	(HL),A		; store updated value.
	LD	A,B		; then i is multiplied by 10^(-n+7)
	NEG			; negate
	CALL	E_TO_FP		; this will bring it into medium
				; range for printing.
	JR	PF_LOOP		; back

; ----------------------------

	ORG	$2E6F
PF_MEDIUM:
	EX	DE,HL		; DE now points to i, HL to f.
	CALL	FETCH_TWO		; The mantissa of i is now in D',E',D,E.
	EXX			; Get the exchange registers.
	SET	7,D		; True numerical bit 7 to D'.
	LD	A,L		; Exponent byte e of i to A.
	EXX			; Back to the main registers.
	SUB	$80		; True exponent e'=e - 80 hex to A.
	LD	B,A		; This gives the required bit count.

; the branch was here to handle bits in DE with 8 or 16 in B  if small int
; and integer in D'E', 6 nibbles will accommodate 065535 but routine does
; 32-bit numbers as well from above

	ORG	$2E7B
PF_BITS:	SLA	E		;	C<xxxxxxxx<0
	RL	D		;	C<xxxxxxxx<C
	EXX			;
	RL	E		;	C<xxxxxxxx<C
	RL	D		;	C<xxxxxxxx<C
	EXX			;
	LD	HL,MEM_4 + 4	; set HL to MEM_4 + 4 last byte of buffer
	LD	C,$05		; set byte count to 5 -  10 nibbles

	ORG	$2E8A
PF_BYTES:	LD	A,(HL)		; fetch 0 or prev value
	ADC	A,A		; shift left add in carry	C<xxxxxxxx<C
	DAA			; Decimal Adjust Accumulator.
				; if greater than 9 then the left hand
				; nibble is incremented. If greater than
				; 99 then adjusted and carry set.
				; so if we'd built up 7 and a carry came in
				;	0000 0111 < C
				;	0000 1111
				; daa	   1 0101  which is 15 in BCD
	LD	(HL),A		; put back
	DEC	HL		; work down thru mem 4
	DEC	C		; decrease the 5 counter.
	JR	NZ,PF_BYTES	; back until the ten nibbles rolled
	DJNZ	PF_BITS		; back until 8 or 16 (or 32) done

; at most 9 digits for 32-bit number will have been loaded with digits
; each of the 9 nibbles in mem 4 is placed into ten bytes in mem-3 and mem 4
; unless the nibble is zero as the buffer is already zero.
; ( or in the case of mem-5 will become zero as a result of RLD instruction )

	XOR	A		; clear to accept
	LD	HL,MEM_4		; byte destination.
	LD	DE,MEM_3		; nibble source.
	LD	B,$09		; the count is 9 (not ten) as the first
				; nibble is known to be blank.
	RLD			; shift RH nibble to left in (HL)
				;   A            (HL)
				; 0000 0000 < 0000 3210
				; 0000 0000   3210 0000
				; A picks up the blank nibble
	LD	C,$FF		; set a flag to indicate when a significant
				; digit has been encountered.

	ORG	$2EA1
PF_DIGITS:
	RLD			; pick up leftmost nibble from (HL)
				;   A            (HL)
				; 0000 0000 < 7654 3210
				; 0000 7654   3210 0000
	JR	NZ,PF_INSERT	; jump if non-zero value picked up.
	DEC	C		; test
	INC	C		; flag
	JR	NZ,PF_TEST_2	; skip forward if flag still $FF
				; indicating this is a leading zero.

; but if the zero is a significant digit e.g. 10 then include in digit totals.
; the path for non-zero digits rejoins here.

	ORG	$2EA9
PF_INSERT:
	LD	(DE),A		; insert digit at destination
	INC	DE		; increase the destination pointer
	INC	(IY+$71)		; increment MEM_5		digit counter
	INC	(IY+$72)		; increment MEM_5 + 1	leading digit counter
	LD	C,$00		; set flag to zero indicating that any
				; subsequent zeros are significant and not
				; leading.

	ORG	$2EB3
PF_TEST_2:
	BIT	0,B		; test if the nibble count is even
	JR	Z,PF_ALL_9	; jump if so to deal with the
				; other nibble in the same byte
	INC	HL		; point to next source byte if not

	ORG	$2EB8
PF_ALL_9:	DJNZ	PF_DIGITS		; decrement the nibble count, back to PF_DIGITS
				; if all nine not done.

; For 8-bit integers there will be at most 3 digits.
; For 16-bit integers there will be at most 5 digits.
; but for larger integers there could be nine leading digits.
; if nine digits complete then the last one is rounded up as the number will
; be printed using E-format notation

	LD	A,(MEM_5)		; fetch digit count
	SUB	$09		; subtract 9 - max possible
	JR	C,PF_MORE		; forward if less
	DEC	(IY+$71)		; decrement digit counter MEM_5 to 8
	LD	A,$04		; load A with the value 4.
	CP	(IY+$6F)		; compare with MEM-4 + 3 - the ninth digit
	JR	PF_ROUND		; forward to consider rounding.

; ---------------------------------------

; now delete int x from calculator stack and fetch fractional part.

	ORG	$2ECB
PF_MORE:	RST	28H		;; FP_CALC	int x.
	DEFB	$02		;;delete	.
	DEFB	$E2		;;get-mem-2	x - int x = f.
	DEFB	$38		;;end-calc	f.

	ORG	$2ECF
PF_FRACTN:
	EX	DE,HL		; DE now points to f.
	CALL	FETCH_TWO		; The mantissa of f is now in D',E',D,E.
	EXX			; Get the exchange registers.
	LD	A,$80		; The exponent of f is reduced to
	SUB	L		; zero, by shifting the bits of f 80
	LD	L,$00		; hex - e places right, where L' contained e.
	SET	7,D		; True numerical bit to bit 7 of D'.
	EXX			; Restore the main registers.
	CALL	SHIFT_FP		; Now make the shift.

	ORG	$2EDF
PF_FRN_LP:
:	LD	A,(IY+$71)	; Get the digit count from MEM_5 1st.
	CP	$08		; Are there already 8 digits?
	JR	C,PF_FR_DGT	; If not, jump forward.
	EXX			; If 8 digits, just use f to round i
	RL	D		; up, rotating D' left to set the carry
	EXX			; Restore main registers and jump
	JR	PF_ROUND		; forward to round up.

; ---

	ORG	$2EEC
PF_FR_DGT:
	LD	BC,$0200		; Initial zero to C, count of 2 to B.

	ORG	$2EEF
PF_FR_EXX:
	LD	A,E		; D'E'DE is multiplied by 10 in 2
	CALL	CA_10_X_A_PL_C	; stages, first DE then D'E', each
	LD	E,A		; byte by byte in 2 steps, and the
	LD	A,D		; integer part of the result is
	CALL	CA_10_X_A_PL_C	; obtained in C to be passed into
	LD	D,A		; the print buffer.
	PUSH	BC		; The count and the result
	EXX			; alternate between BC and B'C'.
	POP	BC		; Look back once through the
	DJNZ	PF_FR_EXX		; exchange registers.
	LD	HL,MEM_3		; The start - 1st byte of mem-3.
	LD	A,C		; Result to A for storing.
	LD	C,(IY+$71)	; MEM_5: Count of digits so far in number to C.
	ADD	HL,BC		; Address the first empty byte.
	LD	(HL),A		; Store the next digit.
	INC	(IY+$71)		; MEM_5: Step up the count of digits.
	JR	PF_FRN_LP		; Loop back until there are 8 digits.

; ----------------

; 1) with 9 digits but 8 in mem-5-1 and A holding 4, carry set if rounding up.
; e.g.
;	999999999 is printed as 1E+9
;	100000001 is printed as 1E+8
;	100000009 is printed as 1.0000001E+8

	ORG	$2F0C
PF_ROUND:	PUSH	AF		; save A and flags
	LD	HL,MEM_3		; start of digits
	LD	C,(IY+$71)	; MEM_5 No. of digits to C
	LD	B,$00		; prepare to add
	ADD	HL,BC		; address last digit + 1
	LD	B,C		; No. of digits to B counter
	POP	AF		; restore A and carry flag from comparison.

	ORG	$2F18
PF_RND_LP:
	DEC	HL		; address digit at rounding position.
	LD	A,(HL)		; fetch it
	ADC	A,$00		; add carry from the comparison
	LD	(HL),A		; put back result even if $0A.
	AND	A		; test A
	JR	Z,PF_R_BACK	; jump if ZERO?
	CP	$0A		; compare to 'ten' - overflow
	CCF			; complement carry flag so that set if ten.
	JR	NC,PF_COUNT	; forward with 1 - 9.

	ORG	$2F25
PF_R_BACK:
	DJNZ	PF_RND_LP		; loop back

; if B counts down to zero then we've rounded right back as in 999999995.
; and the first 8 locations all hold $0A.

	LD	(HL),$01		; load first location with digit 1.
	INC	B		; make B hold 1 also.
				; could save an instruction byte here.
	INC (IY+$72)		; make MEM_5 + 1 hold 1.
				; and proceed to initialize total digits to 1.

	ORG	$2F2D
PF_COUNT:
	LD	(IY+$71),B	; MEM_5

; now balance the calculator stack by deleting it

	RST	28H		;; FP_CALC
	DEFB	$02		;;delete
	DEFB	$38		;;end-calc

; note if used from str$ then other values may be on the calculator stack.
; we can also restore the next literal pointer from its position on the
; machine stack.

	EXX			;
	POP	HL		; restore next literal pointer.
	EXX			;

	LD	BC,(MEM_5)	; set C to digit counter.
				; set B to MEM_5 + 1 leading digit counter.
	LD	HL,MEM_3		; set HL to start of digits
	LD	A,B		; If more than 9, or fewer than
	CP	$09		; minus 4, digits are required
	JR	C,PF_NOT_E	; before the decimal, then E-format
				; will be needed.
	CP	$FC		; Fewer than 4 means more than
	JR	C,PF_E_FRMT	; 4 leading zeros after the decimal.

	ORG	$2F46
PF_NOT_E:	AND	A		; test for zero leading digits as in .123
	CALL	Z,OUT_CODE	; prints a zero e.g. 0.123

	ORG	$2F4A
PF_E_SBRN:
	XOR	A		; set A to zero
	SUB	B		; subtract B
	JP	M,PF_OUT_LP	; jump if originally +ve
	LD	B,A		; else negative count now +ve
	JR	PF_DC_OUT		; forward		->

; ---

	ORG	$2F52
PF_OUT_LP:
	LD	A,C		; fetch total digit count
	AND	A		; test for zero
	JR	Z,PF_OUT_DT	; forward if so
	LD	A,(HL)		; fetch digit
	INC	HL		; address next digit
	DEC	C		; decrease total digit counter

	ORG	$2F59
PF_OUT_DT:
L2F59:	CALL	OUT_CODE		; outputs it.
	DJNZ	PF_OUT_LP		; loop back until B leading digits output.

	ORG	$2F5E
PF_DC_OUT:
	LD	A,C		; fetch total digits and
	AND	A		; test if also zero
	RET	Z		; return if so	-->

;

	INC	B		; increment B
	LD	A,$2E		; prepare the character '.'

	ORG	$2F64
PF_DEC_0:
	RST	10H		; PRINT_A outputs the character '.' or '0'
	LD	A,$30		; prepare the character '0'
				; (for cases like .000012345678)
	DJNZ	PF_DEC_0		; loop back for B times.
	LD	B,C		; load B with now trailing digit counter.
	JR	PF_OUT_LP		; back

; ---------------------------------

; the branch was here for E-format printing e.g. 123456789 => 1.2345679e+8

	ORG	$2F6C
PF_E_FRMT:
	LD	D,B		; counter to D
	DEC	D		; decrement
	LD	B,$01		; load B with 1.
	CALL	PF_E_SBRN		; above
	LD	A,$45		; prepare character 'e'
	RST	10H		; PRINT_A
	LD	C,D		; exponent to C
	LD	A,C		; and to A
	AND	A		; test exponent
	JP	P,PF_E_POS	; jump if positive
	NEG			; negate
	LD	C,A		; positive exponent to C
	LD	A,$2D		; prepare character '-'
	JR	PF_E_SIGN		;

; ---

	ORG	$2F83
PF_E_POS:	LD	A,$2B		; prepare character '+'

	ORG	$2F85
PF_E_SIGN:
	RST	10H		; PRINT_A outputs the sign
	LD	B,$00		; make the high byte zero.
	JP	OUT_NUM_1		; exit to print exponent in BC

; ------------------------------
; Handle printing floating point
; ------------------------------
; This subroutine is called twice from above when printing floating-point
; numbers. It returns 10*A +C in registers C and A

	ORG	$2F8B		; CA-10*A+C
CA_10_X_A_PL_C:
	PUSH	DE		; preserve DE.
	LD	L,A		; transfer A to L
	LD	H,$00		; zero high byte.
	LD	E,L		; copy HL
	LD	D,H		; to DE.
	ADD	HL,HL		; double (*2)
	ADD	HL,HL		; double (*4)
	ADD	HL,DE		; add DE (*5)
	ADD	HL,HL		; double (*10)
	LD	E,C		; copy C to E	(D is 0)
	ADD	HL,DE		; and add to give required result.
	LD	C,H		; transfer to
	LD	A,L		; destination registers.
	POP	DE		; restore DE
	RET			; return with result.

; --------------
; Prepare to add
; --------------
; This routine is called twice by addition to prepare the two numbers. The
; exponent is picked up in A and the location made zero. Then the sign bit
; is tested before being set to the implied state. Negative numbers are twos
; complemented.

	ORG	$2F9B
PREP_ADD:	LD	A,(HL)		; pick up exponent
	LD	(HL),$00		; make location zero
	AND	A		; test if number is zero
	RET	Z		; return if so

	INC	HL		; address mantissa
	BIT	7,(HL)		; test the sign bit
	SET	7,(HL)		; set it to implied state
	DEC	HL		; point to exponent
	RET	Z		; return if positive number.
	PUSH	BC		; preserve BC
	LD	BC,$0005		; length of number
	ADD	HL,BC		; point HL past end
	LD	B,C		; set B to 5 counter
	LD	C,A		; store exponent in C
	SCF			; set carry flag

	ORG	$2FAF
NEG_BYTE:	DEC	HL		; work from LSB to MSB
	LD	A,(HL)		; fetch byte
	CPL			; complement
	ADC	A,$00		; add in initial carry or from prev operation
	LD	(HL),A		; put back
	DJNZ	NEG_BYTE		; loop until all 5 done
	LD	A,C		; stored exponent to A
	POP	BC		; restore original BC
	RET			; return

; -----------------
; Fetch two numbers
; -----------------
; This routine is called twice when printing floating point numbers and also
; to fetch two numbers by the addition, multiply and division routines.
; HL addresses the first number, DE addresses the second number.
; For arithmetic only, A holds the sign of the result which is stored in
; the second location.

	ORG	$2FBA
FETCH_TWO:
	PUSH	HL		; save pointer to first number, result if math.
	PUSH	AF		; save result sign.

; Call the five bytes of the first number	- M1, M2, M3, M4 & M5.
; and the second number			- N1, N2, N3, N4 & N5.

	LD	C,(HL)		; M1 to C.
	INC	HL		; next
	LD	B,(HL)		; M2 to B.
	LD	(HL),A		; store the sign at correct location in
				; destination 5 bytes for arithmetic only.
	INC	HL		; next
	LD	A,C		; M1 to A.
	LD	C,(HL)		; M3 to C.
	PUSH	BC		; Save M2 & M3 on the machine stack.
	INC	HL		; next
	LD	C,(HL)		; M4 to C.
	INC	HL		; next
	LD	B,(HL)		; M5 to B.
	EX	DE,HL		; HL now points to N1.
	LD	D,A		; M1 to D.
	LD	E,(HL)		; N1 to E.
	PUSH	DE		; Save M1 & N1 on the machine stack.
	INC	HL		; next
	LD	D,(HL)		; N2 to D.
	INC	HL		; next
	LD	E,(HL)		; N3 to E.
	PUSH	DE		; Save N2 & N3 on the machine stack.
	EXX			; Get the exchange registers.
	POP	DE		; N2 to D' & N3 to E'.
	POP	HL		; M1 to H' & N1 to L'.
	POP	BC		; M2 to B' & M3 to C'.
	EXX			; Get the original set of registers.
	INC	HL		; next
	LD	D,(HL)		; N4 to D.
	INC	HL		; next
	LD	E,(HL)		; N5 to E.
	POP	AF		; restore possible result sign.
	POP	HL		; and pointer to possible result.
	RET			; return.

; Summary:
;	M1 - M5 are in H', B', C', C, B.
;	N1 - N5 are in: L', D', E', D, E.
;	HL points to the first byte of the first number.

; ---------------------------------
; Shift floating point number right
; ---------------------------------
; This subroutine shifts a floating-point number up to 32 decimal, Hex.20,
; places right to line it up properly for addition. The number with the smaller
; exponent has been put in the addend position before this subroutine is called.
; Any overflow to the right, into the carry, is added back into the number. If
; the exponent difference is greater than 32 decimal, or the carry ripples right
; back to the beginning of the number then the number is set to zero so that the
; addition will not alter the other number (the augend).

	ORG	$2FDD
SHIFT_FP:	AND	A		; If the exponent difference is
	RET	Z		; zero, the subroutine returns at
	CP	$21		; once. If the difference is greater
	JR	NC,ADDEND_0	; than Hex.20, jump forward.
	PUSH	BC		; Save BC briefly.
	LD	B,A		; Transfer the exponent difference
				; to B to count the shifts right.

	ORG	$2FE5
ONE_SHIFT:
	EXX			; Arithmetic shift right for L',
	SRA	L		; preserving the sign marker bits.
	RR	D		; Rotate right with carry D', E',
	RR	E		; D & E.
	EXX			; Thereby shifting the whole five
	RR	D		; bytes of the number to the right
	RR	E		; as many times as B counts.
	DJNZ	ONE_SHIFT		; Loop back until B reaches zero.
	POP	BC		; Restore the original BC.
	RET	NC		; Done if no carry to retrieve.
	CALL	ADD_BACK		; Retrieve carry.
	RET	NZ		; Return unless the carry rippled right back.
				; (In this case there is nothing to add).

	ORG	$2FF9
ADDEND_0:	EXX			; Fetch L', D' & E'.
	XOR	A		; Clear the A register.

	ORG	$2FFB
ZEROS_4_5:
	LD	L,$00		; Set the addend to zero in D',E',
	LD	D,A		; D & E, together with its marker
	LD	E,L		; byte (sign indicator) L', which
	EXX			; was Hex.00 for a positive
	LD	DE,$0000		; number and Hex.FF for a
				; negative number. ZEROS-4/5
				; produces only 4 zero bytes
				; when called for near underflow at 3160.
	RET			; Finished.

; ------------------
; Add back any carry
; ------------------
; This subroutine adds back into the number any carry which has overflowed to the
; right. In the extreme case, the carry ripples right back to the left of the number.
; When this subroutine is called during addition, this ripple means that a mantissa
; of 0.5 was shifted a full 32 places right, and the addend will now be set to zero;
; when called from MULTIPLICATION, it means that the exponent must be incremented,
; and this may result in overflow.

	ORG	$3004
ADD_BACK:	INC	E		; Add carry to rightmost byte.
	RET	NZ		; Return if no overflow to left.
	INC	D		; Continue to the next byte.
	RET	NZ		; Return if no overflow to left.
	EXX			; Get the next byte.
	INC	E		; Increment it too.
	JR	NZ,ALL_ADDED	; Jump if no overflow.
	INC	D		; Increment the last byte.

	ORG	$300D
ALL_ADDED:
	EXX			; Restore the original registers.
	RET			; Finished.

; -----------------------
; Handle subtraction (03)
; -----------------------
; Subtraction is done by switching the sign byte/bit of the second number
; which may be integer of floating point and continuing into addition.

	ORG	$300F
SUBTRACT:	EX	DE,HL		; address second number with HL
	CALL	NEGATE		; switches sign
	EX	DE,HL		; address first number again and continue.

; --------------------
; Handle addition (0F)
; --------------------
; HL points to first number, DE to second.
; If they are both integers, then go for the easy route.

	ORG	$3014
ADDITION:	LD	A,(DE)		; fetch first byte of second
	OR	(HL)		; combine with first byte of first
	JR	NZ,FULL_ADDN	; forward if at least one was
				; in floating point form.

; continue if both were small integers.

	PUSH	DE		; save pointer to lowest number for result.
	INC	HL		; address sign byte and
	PUSH	HL		; push the pointer.
	INC	HL		; address low byte
	LD	E,(HL)		; to E
	INC	HL		; address high byte
	LD	D,(HL)		; to D
	INC	HL		; address unused byte
	INC	HL		; address known zero indicator of 1st number
	INC	HL		; address sign byte
	LD	A,(HL)		; sign to A, $00 or $FF
	INC	HL		; address low byte
	LD	C,(HL)		; to C
	INC	HL		; address high byte
	LD	B,(HL)		; to B
	POP	HL		; pop result sign pointer
	EX	DE,HL		; integer to HL
	ADD	HL,BC		; add to the other one in BC
				; setting carry if overflow.
	EX	DE,HL		; save result in DE bringing back sign pointer
	ADC	A,(HL)		; if pos/pos A=01 with overflow else 00
				; if neg/neg A=FF with overflow else FE
				; if mixture A=00 with overflow else FF
	RRCA			; bit 0 to (C)
	ADC	A,$00		; both acceptable signs now zero

	JP	ADDFIX		;+ continue three bytes below at new location

;;;	JR	NZ,ADDN_OFLW	; forward if not
;;;	SBC	A,A		; restore a negative result sign

ADDSTOR:	LD	(HL),A		; Store it on the stack.
	INC	HL		; Point to the next location.
	LD	(HL),E		; Store the low byte of the result.
	INC	HL		; Point to the next location.
	LD	(HL),D		; Store the high byte of the result.
	DEC	HL		; Move the pointer back to
	DEC	HL		; address the first byte of the
	DEC	HL		; result.
	POP	DE		; Restore STKEND to DE.
	RET			; Finished.

; ---

	ORG	$303C
ADDN_OFLW:
	DEC	HL		; Restore the pointer to the first number.
	POP	DE		; Restore the pointer to the second number.

	ORG	$303E
FULL_ADDN:
	CALL	RE_ST_TWO		; Re-stack both numbers in full
				; five byte floating-point form.

; The full ADDITION subroutine first calls PREP-ADD for each number, then gets the
; two numbers from the calculator stack and puts the one with the smaller exponent
; into the addend position. It then calls SHIFT-FP to shift the addend up to 32
; decimal places right to line it up for addition. The actual addition is done in a
; few bytes, a single shift is made for carry (overflow to the left) if needed, the
; result is twos complemented if negative, and any arithmetic overflow is reported;
; otherwise the subroutine jumps to TEST-NORM to normalise the result and return it
; to the stack with the correct sign bit inserted into the second byte.

	EXX			; Exchange the registers.
	PUSH	HL		; Save the next literal address.
	EXX			; Exchange the registers.
	PUSH	DE		; Save pointer to the addend.
	PUSH	HL		; Save pointer to the augend.
	CALL	PREP_ADD		; Prepare the augend.
	LD	B,A		; Save its exponent in B.
	EX	DE,HL		; Exchange its pointers.
	CALL	PREP_ADD		; Prepare the addend.
	LD	C,A		; Save its exponent in C.
	CP	B		; If the first exponent is smaller,
	JR	NC,SHIFT_LEN	; keep the first number in the
	LD	A,B		; addend position; otherwise
	LD	B,C		; change the exponents and the
	EX	DE,HL		; pointers back again.

	ORG	$3055
SHIFT_LEN:
	PUSH	AF		; Save the larger exponent in A.
	SUB	B		; The difference between the exponents
				; is the length of the shift right.
	CALL	FETCH_TWO		; Get the two numbers from the stack.
	CALL	SHIFT_FP		; Shift the addend right.
	POP	AF		; Restore the larger exponent.
	POP	HL		; HL is to point to the result.
	LD	(HL),A		; Store the exponent of the result.
	PUSH	HL		; Save the pointer again.
	LD	L,B		; M4 to H & M5 to L,
	LD	H,C		; (see FETCH-TWO).
	ADD	HL,DE		; Add the two right bytes.
	EXX			; N2 to H' & N3 to L',
	EX	DE,HL		; (see FETCH-TWO).
	ADC	HL,BC		; Add left bytes with carry.
	EX	DE,HL		; Result back in D'E'.
	LD	A,H		; Add H', L' and the carry; the
	ADC	A,L		; resulting mechanisms will ensure
	LD	L,A		; that a single shift right is called
	RRA			; if the sum of 2 positive numbers
	XOR	L		; has overflowed left, or the sum of 2
	EXX			; negative numbers has not overflowed left.
	EX	DE,HL		; The result is now in DED'E'.
	POP	HL		; Get the pointer to the exponent.
	RRA			; The test for shift (H', L' were
	JR	NC,TEST_NEG	; Hex. 00 for positive numbers
				; and Hex.FF for negative numbers)
	LD	A,$01		; A counts a single shift right.
	CALL	SHIFT_FP		; The shift is called.
	INC	(HL)		; Add 1 to the exponent; this
	JR	Z,ADD_REP_6	; may lead to arithmetic overflow.

	ORG	$307C
TEST_NEG:	EXX			; Test for negative result: get
	LD	A,L		; sign bit of L' into A (this now
	AND	$80		; correctly indicates the sign of
	EXX			; the result).
	INC	HL		; Store it in the second byte
	LD	(HL),A		; position of the result on
	DEC	HL		; the calculator stack.
	JR	Z,GO_NC_MLT	; If it is zero, then do not
				; twos complement the result.
	LD	A,E		; Get the first byte.
	NEG			; Negate it.
	CCF			; Complement the carry for
	LD	E,A		; continued negation, and store byte.
	LD	A,D		; Get the next byte.
	CPL			; Ones complement it.
	ADC	A,$00		; Add in the carry for negation.
	LD	D,A		; Store the byte.
	EXX			; Proceed to get next byte into
	LD	A,E		; the A register.
	CPL			; Ones complement it.
	ADC	A,$00		; Add in the carry for negation.
	LD	E,A		; Store the byte.
	LD	A,D		; Get the last byte.
	CPL			; Ones complement it.
	ADC	A,$00		; Add in the carry for negation.
	JR	NC,END_COMPL	; Done if no carry.
	RRA			; Else, get .5 into mantissa and
	EXX			; add 1 to the exponent; this will
	INC	(HL)		; be needed when two negative numbers add
				; to give an exact power of 2, and it may
				; lead to arithmetic overflow.

	ORG	$309F
ADD_REP_6:
	JP	Z,REPORT_6	; Give the error if required.
	EXX			;

	ORG	$30A3
END_COMPL:
:	LD	D,A		; Store the last byte.
	EXX			;

	ORG	$30A5
GO_NC_MLT:
:	XOR	A		; Clear the carry flag.
	JP	TEST_NORM		; Exit via TEST_NORM.

; -----------------------------
; Used in 16 bit multiplication
; -----------------------------
; This routine is used, in the first instance, by the multiply calculator
; literal to perform an integer multiplication in preference to
; 32-bit multiplication to which it will resort if this overflows.
;
; It is also used by STK-VAR to calculate array subscripts and by DIM to
; calculate the space required for multi-dimensional arrays.

	ORG	$30A9		; HL-HL*DE
HL_HL_DE:	PUSH	BC		; preserve BC throughout
	LD	B,$10		; set B to 16
	LD	A,H		; save H in A high byte
	LD	C,L		; save L in C low byte
	LD	HL,$0000		; initialize result to zero

; now enter a loop.

	ORG	$30B1
HL_LOOP:	ADD	HL,HL		; double result
	JR	C,HL_END		; jump if overflow
	RL	C		; shift AC left into carry
	RLA			;
	JR	NC,HL_AGAIN	; jump to skip addition if no carry
	ADD	HL,DE		; add in DE
	JR	C,HL_END		; jump if overflow

	ORG	$30BC
HL_AGAIN:	DJNZ	HL_LOOP		; back for all 16 bits

	ORG	$30BE
HL_END:	POP	BC		; restore preserved BC
	RET			; return with carry reset if successful
				; and result in HL.

; ----------------------------------------------
; THE 'PREPARE TO MULTIPLY OR DIVIDE' SUBROUTINE
; ----------------------------------------------
; This routine is called in succession from multiply and divide to prepare
; two mantissas by setting the leftmost bit that is used for the sign.
; On the first call A holds zero and picks up the sign bit. On the second
; call the two bits are XORed to form the result sign - minus * minus giving
; plus etc. If either number is zero then this is flagged.
; HL addresses the exponent.

	ORG	$30C0
PREP_M_D:	CALL	TEST_ZERO		; preserves accumulator.
	RET	C		; return carry set if zero
	INC	HL		; address first byte of mantissa
	XOR	(HL)		; pick up the first or xor with first.
	SET	7,(HL)		; now set to give true 32-bit mantissa
	DEC	HL		; point to exponent
	RET			; return with carry reset

; --------------------------
; Handle multiplication (04)
; --------------------------
; This subroutine first tests whether the two numbers to be multiplied are 'small
; integers'. If they are, it uses INT-FETCH to get them from the stack, HL=HL*DE to
; multiply them and INT-STORE to return the result to the stack. Any overflow of
; this 'short multiplication' (i.e. if the result is not itself a 'small integer')
; causes a jump to multiplication in full five byte floating-point form (see below).

	ORG	$30CA
MULTIPLY:	LD	A,(DE)		; Test whether the first bytes of
	OR	(HL)		; both numbers are zero.
	JR	NZ,MULT_LONG	; If not, jump for 'long' multiplication.
	PUSH	DE		; Save the pointers: to the second number.
	PUSH	HL		; And to the first number.
	PUSH	DE		; And to the second number yet again.
	CALL	INT_FETCH		; Fetch sign in C, number in DE.
	EX	DE,HL		; Number to HL now.
	EX	(SP),HL		; Number to stack, second pointer to HL.
	LD	B,C		; Save first sign in B.
	CALL	INT_FETCH		; Fetch second sign in C, number in DE.
	LD	A,B		; Form sign of result in A: like
	XOR	C		; signs give plus (00), unlike give minus (FF).
	LD	C,A		; Store sign of result in C.
	POP	HL		; Restore the first number to HL.
	CALL	HL_HL_DE		; Perform the actual multiplication.
	EX	DE,HL		; Store the result in DE.
	POP	HL		; Restore the pointer to the first number.
	JR	C,MULT_OFLW	; Jump on overflow to 'full' multiplication.
	LD	A,D		; These 5 bytes ensure that
	OR	E		; 00 FF 00 00 00 is replaced by
	JR	NZ,MULT_RSLT	; zero; that they should not be
	LD	C,A		; needed if this number were excluded from
				; the system after 303B) above).

	ORG	$30EA
MULT_RSLT:
	CALL	INT_STORE		; Now store the result on the stack.
	POP	DE		; Restore STKEND to DE.
	RET			; Finished.

; ---

	ORG	$30EF
MULT_OFLW:
	POP	DE		; Restore the pointer to the second number.

	ORG	$30F0
MULT_LONG:
	CALL	RE_ST_TWO		; Re-stack both numbers in full
				; five byte floating-point form.

; The full MULTIPLICATION subroutine prepares the first number for multiplication by
; calling PREP-M/D, returning if it is zero; otherwise the second number is prepared
; by again calling PREP-M/D, and if it is zero the subroutine goes to set the result
; to zero. Next it fetches the two numbers from the calculator stack and multiplies
; their mantissas in the usual way, rotating the first number (treated as the
; multiplier) right and adding in the second number (the multiplicand) to the result
; whenever the multiplier bit is set. The exponents are then added together and
; checks are made for overflow and for underflow (giving the result zero). Finally,
; the result is normalised and returned to the calculator stack with the correct
; sign bit in the second byte.

	XOR	A		; A is set to Hex.00 so that the sign
				; of the first number will go into A.
	CALL	PREP_M_D		; Prepare the first number, and
	RET	C		; return if zero. (Result already zero.)
	EXX			; Exchange the registers.
	PUSH	HL		; Save the next literal address.
	EXX			; Exchange the registers.
	PUSH	DE		; Save the pointer to the multiplicand.
	EX	DE,HL		; Exchange the pointers.
	CALL	PREP_M_D		; Prepare the 2nd number.
	EX	DE,HL		; Exchange the pointers again.
	JR	C,ZERO_RSLT	; Jump forward if 2nd number is zero.
	PUSH	HL		; Save the pointer to the result.
	CALL	FETCH_TWO		; Get the two numbers from the stack.
	LD	A,B		; M5 to A (see FETCH_TWO).
	AND	A		; Prepare for a subtraction.
	SBC	HL,HL		; Initialise HL to zero for the result
	EXX			; Exchange the registers.
	PUSH	HL		; Save M1 & N1 (see FETCH_TWO).
	SBC	HL,HL		; Also initialise H'L' for the result.
	EXX			; Exchange the registers.
	LD	B,$21		; B counts 33 decimal, Hex.21, shifts.
	JR	STRT_MLT		; Jump forward into the loop.

; Now enter the multiplier loop.

	ORG	$3114
MLT_LOOP:	JR	NC,NO_ADD		; Jump forward to NO_ADD if no carry,
				; i.e. the multiplier bit was reset.
	ADD	HL,DE		; Else, add the multiplicand in
	EXX			; D'E'DE (see FETCH_TWO) into
	ADC	HL,DE		; the result being built up on
	EXX			; H'L'HL.

	ORG	$311B
NO_ADD:	EXX			; Whether multiplicand was added
	RR	H		; or not, shift result right in
	RR	L		; H'L'HL, i.e. the shift is done by
	EXX			; rotating each byte with carry, so
	RR	H		; that any bit that drops into the
	RR	L		; carry is picked up by the next byte,
				; and the shift continued into B'C'CA.

	ORG	$3125
STRT_MLT:
	EXX			; Shift right the multiplier in
	RR	B		; B'C'CA (see FETCH_TWO & above).
	RR	C		; A final bit dropping into the
	EXX			; carry will trigger another add of
	RR	C		; the multiplicand to the result.
	RRA			;
	DJNZ	MLT_LOOP		; Loop 33 times to get all the bits.
	EX	DE,HL		; Move the result from:
	EXX			;
	EX	DE,HL		; H'L'HL to D'E'DE.

; Now add the exponents together.

	EXX			;
	POP	BC		; Restore the exponents - M1 & N1.
	POP	HL		; Restore the pointer to the exponent byte.
	LD	A,B		; Get the sum of the two exponent
	ADD	A,C		; bytes in A, and the correct carry.
	JR	NZ,MAKE_EXPT	; If the sum equals zero then clear
	AND	A		; the carry; else leave it unchanged.

	ORG	$313B
MAKE_EXPT:
	DEC	A		; Prepare to increase the
	CCF			; exponent by Hex.80.

; The rest of the subroutine is common to both MULTIPLICATION and DIVISION.

	ORG	$313D
DIVN_EXPT:
	RLA			; These few bytes very cleverly
	CCF			; make the correct exponent byte.
	RRA			; Rotating left then right gets the exponent
				; byte (true exponent plus Hex.80) into A.
	JP	P,OFLW1_CLR	; If the sign flag is reset, no report
				; of arithmetic overflow needed.
	JR	NC,REPORT_6	; Report the overflow if carry reset.
	AND	A		; Clear the carry now.

	ORG	$3146
OFLW1_CLR:
	INC	A		; The exponent byte is now complete;
	JR	NZ,OFLW2_CLR	; but if A is zero a further
	JR	C,OFLW2_CLR	; check for overflow is needed.
	EXX			; If there is no carry set and the
	BIT	7,D		; result is already in normal form
	EXX			; (bit 7 of D' set) then there is
	JR	NZ,REPORT_6	; overflow to report; but if bit 7
				; of D' is reset, the result in just
				; in range, i.e. just under 2**127.

	ORG	$3151
OFLW2_CLR:
	LD	(HL),A		; Store the exponent byte, at last.
	EXX			; Pass the fifth result byte to A
	LD	A,B		; for the normalisation sequence,
	EXX			; i.e. the overflow from L into B'.

; The remainder of the subroutine deals with normalisation and is common
; to all the arithmetic routines.

	ORG	$3155
TEST_NORM:
	JR	NC,NORMALISE	; If no carry then normalise now.
	LD	A,(HL)		; Else, deal with underflow (zero
	AND	A		; result) or near underflow

	ORG	$3159
NEAR_ZERO:
	LD	A,$80		; (result 2**-128):
	JR	Z,SKIP_ZERO	; return exponent to A, test if A...

	ORG	$315D
ZERO_RSLT:
	XOR	A		; is zero (case 2**-128) and if so

	ORG	$315E
SKIP_ZERO:
	EXX			; produce 2**-128 if number is
	AND	D		; normal; otherwise produce zero.
	CALL	ZEROS_4_5		; The exponent must then be set
	RLCA			; to zero (for zero) or 1 (for 2**-128).
	LD	(HL),A		; Restore the exponent byte.
	JR	C,OFLOW_CLR	; Jump if case 2**-128.
	INC	HL		; Otherwise, put zero into second
	LD	(HL),A		; byte of result on the calculator stack.
	DEC	HL		;
	JR	OFLOW_CLR		; Jump forward to transfer the result.

; The actual normalisation operation.

	ORG	$316C
NORMALISE:
	LD	B,$20		; Normalise the result by up to 32

	ORG	$316E
SHIFT_ONE:
	EXX			; decimal, Hex.20, shifts left of
	BIT	7,D		; D'E'DE (with A adjoined) until
	EXX			; bit 7 of D' is set. A holds zero
	JR	NZ,NORML_NOW	; after addition so no precision is
	RLCA			; gained or lost; A holds the fifth
	RL	E		; byte from B' after multiplication
	RL	D		; or division; but as only
	EXX			; about 32 bits can be correct, no
	RL	E		; precision is lost. Note that A is
	RL	D		; rotated circularly, with branch
	EXX			; at carry ... eventually a random process.
	DEC	(HL)		; The exponent is decremented on each shift.
	JR	Z,NEAR_ZERO	; If the exponent becomes zero, then number
				; from 2**-129 are rounded up to 2**-128.
	DJNZ	SHIFT_ONE		; Loop back, up to 32 times.
	JR	ZERO_RSLT		; If bit 7 never became 1 then the
				; whole result is to be zero.

; Finish the normalisation by considering the 'carry'.

	ORG	$3186
NORML_NOW:
	RLA			; After normalisation add back
	JR	NC,OFLOW_CLR	; any final carry that went into A.
	CALL	ADD_BACK		; Jump forward if the carry does
	JR	NZ,OFLOW_CLR	; not ripple right back.
	EXX			; If it should ripple right back
	LD	D,$80		; then set mantissa to 0.5 and
	EXX			; increment the exponent.
	INC	(HL)		; This action may lead to arithmetic
	JR	Z,REPORT_6	; overflow (final case).

; The final part of the subroutine involves passing the result to the bytes
; reserved for it on the calculator stack and resetting the pointers.

	ORG	$3195
OFLOW_CLR:
	PUSH	HL		; Save the result pointer.
	INC	HL		; Point to the sign byte in the result
	EXX			; The result is moved from its
	PUSH	DE		; present registers, D'E'DE, to
	EXX			; BCDE; and then to ACDE.
	POP	BC		;
	LD	A,B		; The sign bit is retrieved from
	RLA			; its temporary store and transferred
	RL	(HL)		; to its correct position of
	RRA			; bit 7 of the first byte of the mantissa.
	LD	(HL),A		; The first byte is stored.
	INC	HL		; next
	LD	(HL),C		; The second byte is stored.
	INC	HL		; next
	LD	(HL),D		; The third byte is stored.
	INC	HL		; next
	LD	(HL),E		; The fourth byte is stored.
	POP	HL		; Restore the pointer to the result.
	POP	DE		; Restore the pointer to second number.
	EXX			; Exchange the register.
	POP	HL		; Restore the next literal address.
	EXX			; Exchange the registers.
	RET			; Finished.

; Report 6 - Arithmetic overflow

	ORG	$31AD
REPORT_6:	RST	08H		; ERROR_1
	DEFB	$05		; Error Report: Overflow

; --------------------
; Handle division (05)
; --------------------
; This subroutine first prepared the divisor by calling PREP-M/D, reporting
; arithmetic overflow if it is zero; then it prepares the dividend again calling
; PREP-M/D, returning if it is zero. Next fetches the two numbers from the
; calculator stack and divides their mantissa by means of the usual restoring
; division, trial subtracting the divisor from the dividend and restoring if there
; is carry, otherwise adding 1 to the quotient. The maximum precision is obtained
; for a 4-byte division, and after subtracting the exponents the subroutine exits
; by joining the later part of MULTIPLICATION.

	ORG	$31AF
DIVISION:	CALL	RE_ST_TWO		; Use full floating-point forms.
	EX	DE,HL		; Exchange the pointers.
	XOR	A		; A is set to Hex.00, so that the
				; sign of the first number will go into A.
	CALL	PREP_M_D		; Prepare the divisor and give the
	JR	C,REPORT_6	; report for arithmetic overflow if it is zero.
	EX	DE,HL		; Exchange the pointers.
	CALL	PREP_M_D		; Prepare the dividend and return
	RET	C		; if it is zero (result already zero).
	EXX			; Exchange the pointers.
	PUSH	HL		; Save the next literal address.
	EXX			; Exchange the registers.
	PUSH	DE		; Save pointer to divisor.
	PUSH	HL		; Save pointer to dividend.
	CALL	FETCH_TWO		; Get the two numbers from the stack
	EXX			; Exchange the registers.
	PUSH	HL		; Save M1 & N1 on the machine stack.
	LD	H,B		; Copy the four bytes of the
	LD	L,C		; dividend from registers B'C'CB
	EXX			; (i.e. M2, M3, M4 & M5; see
	LD	H,C		; FETCH_TWO) to the registers
	LD	L,B		; H'L'HL.
	XOR	A		; Clear A and reset the carry flag.
	LD	B,$DF		; B will count upwards from -33 to -1, twos
				; complement, Hex.DF to FF, looping on minus and
				; will jump again on zero for extra precision.
	JR	DIV_START		; Jump forward into the division loop for
				; the first trial subtraction.

; Now enter the division loop.

	ORG	$31D2
DIV_LOOP:	RLA			; Shift the result left into B'C'CA,
	RL	C		; shifting out the bits already
	EXX			; there, picking up 1 from the
	RL	C		; carry whenever it is set, and
	RL	B		; rotating left each byte with
	EXX			; carry to achieve the 32 bit shift.

	ORG	$31DB
DIV_34TH:	ADD	HL,HL		; Move what remains of the
	EXX			; dividend left in H'L'HL before
	ADC	HL,HL		; the next trial subtraction; if a
	EXX			; bit drops into the carry, force no
				; restore and a bit for the quotient,
				; thus retrieving the lost
	JR	C,SUBN_ONLY	; bit and allowing a full 32-bit divisor.

	ORG	$31E2
DIV_START:
	SBC	HL,DE		; Trial subtract divisor in D'E'DE
	EXX			; from rest of dividend in H'L'HL;
	SBC	HL,DE		; there is no initial carry (see
	EXX			; previous step).
	JR	NC,NO_RSTORE	; Jump forward if there is no carry
	ADD	HL,DE		; Otherwise restore, i.e. add back
	EXX			; the divisor. Then clear the carry
	ADC	HL,DE		; so that there will be no bit for
	EXX			; the quotient (the divisor 'did
	AND	A		; not go').
	JR	COUNT_ONE		; Jump forward to the counter.

; ---

	ORG	$31F2
SUBN_ONLY:
	AND	A		; Just subtract with no restore
	SBC	HL,DE		; and go on to set the carry flag
	EXX			; because the lost bit of the dividend
	SBC	HL,DE		; is to be retrieved and used
	EXX			; for the quotient.

	ORG	$31F9
NO_RSTORE:
	SCF			; One for the quotient in B'C'CA.

	ORG	$31FA
COUNT_ONE:
	INC	B		; Step the loop count up by one.
	JP	M,DIV_LOOP	; Loop 32 times for all bits.
	PUSH	AF		; Save any 33rd bit for extra
				; precision (the present carry).
	JR	Z,DIV_START	; Trial subtract yet again for any 34th bit;
				; the PUSH AF above saves this bit too.

;
;
;

	LD	E,A		; Now move the four bytes that
	LD	D,C		; form the mantissa bytes of the
	EXX			; result from B'C'CA to D'E'DE.
	LD	E,C		;
	LD	D,B		;
	POP	AF		; Then put the 34th and 33rd bits
	RR	B		; into B' to be picked up on
	POP	AF		; normalisation.
	RR	B		;
	EXX			;
	POP	BC		; Restore the exponent bytes, M1 & N1.
	POP	HL		; Restore the pointer to the result.
	LD	A,B		; Get the difference between the
	SUB	C		; two exponent bytes into A and
				; set the carry flag if required.
	JP	DIVN_EXPT		; Exit via DIVN_EXPT.

; ------------------------------------
; Integer truncation towards zero ($3A)
; ------------------------------------
; This subroutine (say I(x)) returns the result of integer truncation of x, the
; 'last value', towards zero. Thus I(2.4) is 2 and I(-2.4) is -2. The subroutine
; returns at once if x is in the form of a 'short integer'. It returns zero if
; the exponent byte of x if less than 81 hex (ABS x is less than 1). If I(x) is
; a 'short integer' the subroutine returns it in that form. It returns x if the
; exponent byte is A0 hex or greater (x has no significant non-integral part).
; Otherwise the correct number of bytes of x are set to zero and, if needed,
; one more byte is split with a mask.

	ORG	$3214
TRUNCATE:	LD	A,(HL)		; Get the exponent byte of X into A.
	AND	A		; If A is zero, return since x is
	RET	Z		; already a small integer.
	CP	$81		; Compare e, the exponent, to 81 hex.
	JR	NC,T_GR_ZERO	; Jump if e is greater than 80 hex.
	LD	(HL),$00		; Else, set the exponent to zero;
	LD	A,$20		; enter 32 decimal, 20 hex, into A
	JR	NIL_BYTES		; and jump forward to NIL-_YTES to
				; make all the bits of x be zero.

; ---

	ORG	$3221
T_GR_ZERO:
	CP	$91		; Compare e to 91 hex, 145 decimal.
	JR	T_SMALL		; Jump if e not 91 hex.

; ---

; Note. The last instruction was ADC A,A

ADDFIX:	JP	NZ,ADDN_OFLW	;+ forward if not
	SBC	A,A		;+ restore a negative result sign
	LD	C,A		;+
	INC	A		;+
	OR	E		;+
	OR	D		;+
	LD	A,C		;+
	JR	NZ,REL_AS		;+ back (indirect) if not -65536
	DEC	HL		;+ point to first byte (exponent)
	LD	(HL),$91		;+
	INC	HL		;+
	AND	$80		;+ set A to $80
REL_AS:	JP	ADDSTOR		;+ back to store all 4 mantissa bytes

; ---------------------------------------------------------------

; Room for a new short six-byte routine

GET_BC:	INC	HL		; address sign
	INC	HL		; address low
	LD	C,(HL)		; contents of L to C
	INC	HL		; increment
	LD	B,(HL)		; contents of B to H
	RET			; return

; ---------------------------------------------------------------

; If the exponent byte of x is between 81 and 90 hex (129 and 144 decimal)
; inclusive, I(x) is a 'small integer', and will be compressed into one or
; two bytes. But first a test is made to see whether x is, after all, large.

	ORG	$323F
T_SMALL:	JR	NC,X_LARGE	; Jump with exponent byte 92 or more (it would
				; be better to jump with 91 too).
	PUSH	DE		; Save STKEND in DE.
	CPL			; Range 129 <= A <= 144 becomes 126 >= A >= 111.
	ADD	A,$91		; Range is now 15 dec >= A >= 0.
	INC	HL		; Point HL at second byte.
	LD	D,(HL)		; Second byte to D.
	INC	HL		; Point HL at third byte.
	LD	E,(HL)		; Third byte to E.
	DEC	HL		; Point HL at first byte again.
	DEC	HL		;
	LD	C,$00		; Assume a positive number.
	BIT	7,D		; Now test for negative (bit 7 set).
	JR	Z,T_NUMERIC	; Jump if positive after all.
	DEC	C		; Change the sign.

	ORG	$3252
T_NUMERIC:
	SET	7,D		; Insert true numeric bit, 1, in D.
	LD	B,$08		; Now test whether A >= 8 (one
	SUB	B		; byte only) or two bytes needed.
	ADD	A,B		; Leave A unchanged.
	JR	C,T_TEST		; Jump if two bytes needed.
	LD	E,D		; Put the one byte into E.
	LD	D,$00		; And set D to zero.
	SUB	B		; Now 1 <= A <= 7 to count the shifts needed.

	ORG	$325E
T_TEST:	JR	Z,T_STORE		; Jump if no shift needed.
	LD	B,A		; B will count the shifts.

	ORG	$3261
T_SHIFT:	SRL	D		; Shift D and E right B times to
	RR	E		; produce the correct number.
	DJNZ	T_SHIFT		; Loop until B is zero.

	ORG	$3267
T_STORE:	CALL	INT_STORE		; Store the result on the stack.
	POP	DE		; Restore STKEND to DE.
	RET			; Finished.

; Note. the next byte is now obsolete.

	ORG	$326C
T_EXPNENT:
	LD	A,(HL)		; Get the exponent byte of x into A.

; Large values of x remains to be considered.

	ORG	$326D
X_LARGE:	SUB	$A0		; Subtract 160 decimal, A0 hex, from e.
	RET	P		; Return on plus - x has no significant non-
				; integral part. (If the true exponent were
				; reduced to zero, the 'binary point' would
				; come at or after the end of the four bytes
				; of the mantissa).
	NEG			; Else, negate the remainder; this gives the
				; number of bits to become zero (the number
				; of bits after the 'binary point').

; Now the bits of the mantissa can be cleared.

	ORG	$3272
NIL_BYTES:
	PUSH	DE		; Save the current value of DE (STKEND).
	EX	DE,HL		; Make HL point one past the fifth byte.
	DEC	HL		; HL now points to the fifth byte of x.
	LD	B,A		; Get the number of bits to be set
	SRL	B		; to zero in B and divide it by B
	SRL	B		; to give the number of whole
	SRL	B		; bytes implied.
	JR	Z,BITS_ZERO	; Jump forward if the result is zero.

	ORG	$327E
BYTE_ZERO:
	LD	(HL),$00		; Else, set the bytes to zero;
	DEC	HL		; B counts them.
	DJNZ	BYTE_ZERO		;

	ORG	$3283
BITS_ZERO:
	AND	$07		; Get A (mod 8); this is the number
				; of bits still to be set to zero.
	JR	Z,IX_END		; Jump to the end if nothing more to do.
	LD	B,A		; B will count the bits now.
	LD	A,$FF		; Prepare the mask.

	ORG	$328A
LESS_MASK:
	SLA	A		; With each loop a zero enters the
	DJNZ	LESS_MASK		; mask from the right and thereby a mask
				; of the correct length is produced.
	AND	(HL)		; The unwanted bits of (HL) are
	LD	(HL),A		; lost as the masking is performed.

	ORG	$3290
IX_END:	EX	DE,HL		; Return the pointer to HL.
	POP	DE		; Return STKEND to DE.
	RET			; Finished.

; ----------------------------------
; Storage of numbers in 5 byte form.
; ==================================
; Both integers and floating-point numbers can be stored in five bytes.
; Zero is a special case stored as 5 zeros.
; For integers the form is
; Byte 1 - zero,
; Byte 2 - sign byte, $00 +ve, $FF -ve.
; Byte 3 - Low byte of integer.
; Byte 4 - High byte
; Byte 5 - unused but always zero.
;
; it seems unusual to store the low byte first but it is just as easy either
; way. Statistically it just increases the chances of trailing zeros which
; is an advantage elsewhere in saving ROM code.
;
;             zero     sign     low      high    unused
; So +1 is  00000000 00000000 00000001 00000000 00000000
;
; and -1 is 00000000 11111111 11111111 11111111 00000000
;
; much of the arithmetic found in BASIC lines can be done using numbers
; in this form using the Z80's 16 bit register operation ADD.
; (multiplication is done by a sequence of additions).
;
; Storing -ve integers in two's complement form, means that they are ready for
; addition and you might like to add the numbers above to prove that the
; answer is zero. If, as in this case, the carry is set then that denotes that
; the result is positive. This only applies when the signs don't match.
; With positive numbers a carry denotes the result is out of integer range.
; With negative numbers a carry denotes the result is within range.
; The exception to the last rule is when the result is -65536
;
; Floating point form is an alternative method of storing numbers which can
; be used for integers and larger (or fractional) numbers.
;
; In this form 1 is stored as
; 10000001 00000000 00000000 00000000 00000000
;
; When a small integer is converted to a floating point number the last two
; bytes are always blank so they are omitted in the following steps
;
; first make exponent +1 +16d  (bit 7 of the exponent is set if positive)

; 10010001 00000000 00000001
; 10010000 00000000 00000010 <-  now shift left and decrement exponent
; ...
; 10000010 01000000 00000000 <-  until a 1 abuts the imaginary point
; 10000001 10000000 00000000     to the left of the mantissa.
;
; however since the leftmost bit of the mantissa is always set then it can
; be used to denote the sign of the mantissa and put back when needed by the
; PREP routines which gives
;
; 10000001 00000000 00000000

; ----------------------------------------------
; THE 'RE-STACK TWO "SMALL" INTEGERS' SUBROUTINE
; ----------------------------------------------
; This routine is called to re-stack two numbers in full floating point form
; e.g. from mult when integer multiplication has overflowed.

	ORG	$3293
RE_ST_TWO:
	CALL	RESTK_SUB		; forward and continue
				; into the routine to do the other one.

	ORG	$3296
RESTK_SUB:
	EX	DE,HL		; swap pointers

; ---------------------------------------------
; THE 'RE-STACK ONE "SMALL" INTEGER' SUBROUTINE
; ---------------------------------------------
; (offset: $3D 're-stack')
; This routine re-stacks an integer, usually on the calculator stack, in full
; floating point form.  HL points to first byte.

	ORG	$3297
RE_STACK:	LD	A,(HL)		; Fetch Exponent byte to A
	AND	A		; test it
	RET	NZ		; return if not zero as already in full
				; floating-point form.
	PUSH	DE		; preserve DE.
	CALL	INT_FETCH	; integer to DE, sign to C.

; HL points to 4th byte.

	XOR	A		; clear accumulator.
	INC	HL		; point to 5th.
	LD	(HL),A		; and blank.
	DEC	HL		; point to 4th.
	LD	(HL),A		; and blank.
	LD	B,$91		; set exponent byte +ve $81
				; and imaginary dec point 16 bits to right
				; of first bit.

; we could skip to normalize now but it's quicker to avoid normalizing
; through an empty D.

	LD	A,D		; fetch the high byte D
	AND	A		; is it zero ?
	JR	NZ,RS_NRMLSE 	; skip if not.
	OR	E		; low byte E to A and test for zero
	LD	B,D		; set B exponent to 0
	JR	Z,RS_STORE	; forward if value is zero.
	LD	D,E		; transfer E to D
	LD	E,B		; set E to 0
	LD	B,$89		; reduce the initial exponent by eight.


	ORG	$32B1
RS_NRMLSE:
	EX	DE,HL		; integer to HL, addr of 4th byte to DE.

	ORG	$32B2
RSTK_LOOP:
	DEC	B		; decrease exponent
	ADD	HL,HL		; shift DE left
	JR	NC,RSTK_LOOP	; loop back until a set bit pops into carry
	RRC	C		; now rotate the sign byte $00 or $FF
				; into carry to give a sign bit
	RR	H		; rotate the sign bit to left of H
	RR	L		; rotate any carry into L
	EX	DE,HL		; address 4th byte, normalized int to DE

	ORG	$32BD
RS_STORE:
	DEC	HL		; address 3rd byte
	LD	(HL),E		; place E
	DEC	HL		; address 2nd byte
	LD	(HL),D		; place D
	DEC	HL		; address 1st byte
	LD	(HL),B		; store the exponent
	POP	DE		; restore initial DE.
	RET			; return.

;****************************************
;** Part 10. FLOATING-POINT CALCULATOR **
;****************************************

; As a general rule the calculator avoids using the IY register.
; exceptions are val, val$ and str$.
; So an assembly language programmer who has disabled interrupts to use
; IY for other purposes can still use the calculator for mathematical
; purposes.

; ------------------------
; THE 'TABLE OF CONSTANTS'
; ------------------------
;

	ORG	$32C5		; used 11 times
STK_ZERO:				; 00 00 00 00 00
	DEFB	$00		;;Bytes: 1
	DEFB	$B0		;;Exponent $00
	DEFB	$00		;;(+00,+00,+00)


	ORG	$32C8		; used 19 times
STK_ONE:				; 00 00 01 00 00
	DEFB	$40		;;Bytes: 2
	DEFB	$B0		;;Exponent $00
	DEFB	$00,$01		;;(+00,+00)


	ORG	$32CC		; used 9 times
STK_HALF:				; 80 00 00 00 00
	DEFB	$30		;;Exponent: $80, Bytes: 1
	DEFB	$00		;;(+00,+00,+00)

	ORG	$32CE		; used 4 times
STK_PI_DIV_2:			; 81 49 0F DA A2
	DEFB	$F1		;;Exponent: $81, Bytes: 4
	DEFB	$49,$0F,$DA,$A2	;;

	ORG	$32D3		; used 3 times
STK_TEN:				; 00 00 0A 00 00
	DEFB	$40		;;Bytes: 2
	DEFB	$B0		;;Exponent $00
	DEFB	$00,$0A		;;(+00,+00)

; ------------------------
; THE 'TABLE OF ADDRESSES'
; ------------------------
;
; Starts with binary operations which have two operands and one result.
; Three pseudo binary operations first.

	ORG	$32D7
TBL_ADDRS:
	DEFW	JUMP_TRUE		; $00
	DEFW	EXCHANGE		; $01
	DEFW	DELETE		; $02

; True binary operations.

	DEFW	SUBTRACT		; $03
	DEFW	MULTIPLY		; $04
	DEFW	DIVISION		; $05
	DEFW	TO_POWER		; $06
	DEFW	_OR		; $07

	DEFW	NO_AND_NO		; $08
	DEFW	NO_1_EQL_ETC	; $09	NO_L_EQL
	DEFW	NO_1_EQL_ETC	; $0A	NO_GR_EQL	
	DEFW	NO_1_EQL_ETC	; $0B	NOS_NEQL
	DEFW	NO_1_EQL_ETC	; $0C	NO_GRTR
	DEFW	NO_1_EQL_ETC	; $0D	NO_LESS
	DEFW	NO_1_EQL_ETC	; $0E	NOS_EQL
	DEFW	ADDITION		; $0F

	DEFW	STR_AND_NO	; $10
	DEFW	NO_1_EQL_ETC	; $11	STR_L_EQL
	DEFW	NO_1_EQL_ETC	; $12	STR_GR_EQL
	DEFW	NO_1_EQL_ETC	; $13	STRS_NEQL
	DEFW	NO_1_EQL_ETC	; $14	STR_GRTR
	DEFW	NO_1_EQL_ETC	; $15	STR_LESS
	DEFW	NO_1_EQL_ETC	; $16	STRS_EQL
	DEFW	STRS_ADD		; $17

; Unary follow.

	DEFW	VAL		; $18	VAL$
	DEFW	USR_STRING	; $19
	DEFW	READ_IN		; $1A
	DEFW	NEGATE		; $1B

	DEFW	CODE		; $1C
	DEFW	VAL		; $1D
	DEFW	LEN		; $1E
	DEFW	SIN		; $1F
	DEFW	COS		; $20
	DEFW	TAN		; $21
	DEFW	ASN		; $22
	DEFW	ACS		; $23
	DEFW	ATN		; $24
	DEFW	LN		; $25
	DEFW	EXP		; $26
	DEFW	INT		; $27
	DEFW	SQR		; $28
	DEFW	SGN		; $29
	DEFW	ABS		; $2A
	DEFW	PEEK		; $2B
	DEFW	_IN		; $2C
	DEFW	USR_NO		; $2D
	DEFW	STR		; $2E	STR$
	DEFW	CHRS		; $2F
	DEFW	NOT		; $30

; End of true unary.

	DEFW	MOVE_FP		; $31	DUPLICATE
	DEFW	N_MOD_M		; $32
	DEFW	JUMP		; $33
	DEFW	STK_DATA		; $34
	DEFW	DEC_JR_NZ		; $35
	DEFW	LESS_0		; $36
	DEFW	GREATER_0		; $37
	DEFW	END_CALC		; $38
	DEFW	GET_ARGT		; $39
	DEFW	TRUNCATE		; $3A
	DEFW	FP_CALC_2		; $3B
	DEFW	E_TO_FP		; $3C
;;;	DEFW	not used		; $3C
	DEFW	RE_STACK		; $3D
;;;	DEFW	not used		; $3E
;;;	DEFW	not used		; $3F

; The following are just the next available slots for the 128 compound
; literals which are in range $80 - $FF.

	DEFW	SERIES_XX		; $80 - $9F.
	DEFW	STK_CONST_XX	; $A0 - $BF.
	DEFW	ST_MEM_XX		; $C0 - $DF.
	DEFW	GET_MEM_XX	; $E0 - $FF.

; Aside: 3E - 3F are therefore unused calculator literals.
; If the literal has to be also usable as a function then bits 6 and 7 are
; used to show type of arguments and result.

; --------------
; The Calculator
; --------------
;
;

	ORG	$335B
CALCULATE:
	CALL	STK_PNTRS		; routine STK_PNTRS is called to set up the
				; calculator stack pointers for a default
				; unary operation. HL = last value on stack.
				; DE = STKEND first location after stack.

; the calculate routine is called at this point by the series generator...

	ORG	$335E
GEN_ENT_1:
	LD	A,B		; fetch the Z80 B register to A
	LD	(BREG),A		; and store value in system variable BREG.
				; this will be the counter for DEC_JR_NZ
				; or if used from FP_CALC2 the calculator
				; instruction.

; ... and again later at this point

	ORG	$3362
GEN_ENT_2:
	EXX			; switch sets
	EX	(SP),HL		; and store the address of next instruction,
				; the return address, in HL'.
				; If this is a recursive call the HL'
				; of the previous invocation goes on stack.
				; c.f. END_CALC.
	EXX			; switch back to main set

; this is the re-entry looping point when handling a string of literals.

	ORG	$3365
RE_ENTRY:	LD	(STKEND),DE	; save end of stack in system variable STKEND
	EXX			; switch to alt
	LD	A,(HL)		; get next literal
	INC	HL		; increase pointer'

; single operation jumps back to here

	ORG	$336C
SCAN_ENT:	PUSH	HL		; save pointer on stack
	AND	A		; now test the literal
	JP	P,FIRST_3D	; forward if in range $00 - $3D
				; anything with bit 7 set will be one of
				; 128 compound literals.

; compound literals have the following format.
; bit 7 set indicates compound.
; bits 6-5 the subgroup 0-3.
; bits 4-0 the embedded parameter $00 - $1F.
; The subgroup 0-3 needs to be manipulated to form the next available four
; address places after the simple literals in the address table.

	LD	D,A		; save literal in D
	AND	$60		; and with 01100000 to isolate subgroup
	RRCA			; rotate bits
	RRCA			; 4 places to right
	RRCA			; not five as we need offset * 2
	RRCA			; 00000xx0
	ADD	A,$7C		; add ($3E * 2) to give correct offset.
				; alter above if you add more literals.
	LD	L,A		; store in L for later indexing.
	LD	A,D		; bring back compound literal
	AND	$1F		; use mask to isolate parameter bits
	JR	ENT_TABLE		; forward

; ---

; the branch was here with simple literals.

	ORG	$3380
FIRST_3D:	CP	$18		; compare with first unary operations.
	JR	NC,DOUBLE_A	; jump with unary operations

; it is binary so adjust pointers.

	EXX ;
	LD	BC,$FFFB		; the value -5
	LD	D,H		; transfer HL, the last value, to DE.
	LD	E,L		;
	ADD	HL,BC		; subtract 5 making HL point to second value.
	EXX			;

	ORG	$338C
DOUBLE_A:	RLCA			; double the literal
	LD	L,A		; and store in L for indexing

	ORG	$338E
ENT_TABLE:
	LD	DE,TBL_ADDRS	;
	LD	H,$00		; prepare to index
	ADD	HL,DE		; add to get address of routine
	LD	E,(HL)		; low byte to E
	INC	HL		;
	LD	D,(HL)		; high byte to D
	LD	HL,RE_ENTRY	;
	EX	(SP),HL		; goes to stack
	PUSH	DE		; now address of routine
	EXX			; main set
				; avoid using IY register.
	LD	BC,(STKEND_H)	; nothing much goes to C but BREG to B
				; and continue into next ret instruction
				; which has a dual identity

; ------------------
; Handle delete (02)
; ------------------
; A simple return but when used as a calculator literal this
; deletes the last value from the calculator stack.
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.
; So nothing to do

	ORG	$33A1
DELETE:	RET			; return - indirect jump if from above.

; ---------------------
; Single operation (3B)
; ---------------------
; this single operation is used, in the first instance, to evaluate most
; of the mathematical and string functions found in BASIC expressions.

	ORG	$33A2
FP_CALC_2:
	POP	AF		; drop return address.
	LD	A,(BREG)		; value will be literal e.g. 'TAN'
	EXX			; switch to alt
	JR	SCAN_ENT		; next literal will be end-calc at  S_STK_LST1

; ---------------------------------
; THE 'TEST FIVE SPACES' SUBROUTINE
; ---------------------------------
; This routine is called from MOVE_FP, STK_CONST and STK_STORE to test that
; there is enough space between the calculator stack and the machine stack
; for another five-byte value.  It returns with BC holding the value 5 ready
; for any subsequent LDIR.

	ORG	$33A9
TEST_5_SP:
	PUSH	DE		; save
	PUSH	HL		; registers
	LD	BC,$0005		; an overhead of five bytes
	CALL	TEST_ROOM		; tests free RAM raising an error if not.
	POP	HL		; else restore
	POP	DE		; registers.
	RET			; return with BC set at 5.

; -----------------------------
; THE 'STACK NUMBER' SUBROUTINE
; -----------------------------
; This routine is called to stack a hidden floating point number found in
; a BASIC line.  It is also called to stack a numeric variable value, and
; from BEEP, to stack an entry in the semi-tone table.  It is not part of the
; calculator suite of routines.  On entry, HL points to the number to be
; stacked.

	ORG	$33B4
STACK_NUM:
	LD	DE,(STKEND)	; Load destination from STKEND system variable.
	CALL	MOVE_FP		; puts on calculator stack with a memory check.
	LD	(STKEND),DE	; Set STKEND to next free location.
	RET			; Return.

; ---------------------------------
; Move a floating point number (31)
; ---------------------------------

; This simple routine is a 5-byte LDIR instruction
; that incorporates a memory check.
; When used as a calculator literal it duplicates the last value on the
; calculator stack.
; Unary so on entry HL points to last value, DE to stkend

	ORG	$33C0		;; DUPLICATE
MOVE_FP:	CALL	TEST_5_SP		; test free memory and sets BC to 5.

; Note. the next location is called by the Opus Discovery disk interface.

x33C3:	LDIR			; copy the five bytes.
	RET			; return with DE addressing new STKEND
				; and HL addressing new last value.

; -------------------
; Stack literals ($34)
; -------------------
; When a calculator subroutine needs to put a value on the calculator
; stack that is not a regular constant this routine is called with a
; variable number of following data bytes that convey to the routine
; the integer or floating point form as succinctly as is possible.

	ORG	$33C6
STK_DATA:	LD	H,D		; transfer STKEND
	LD	L,E		; to HL for result.

	ORG	$33C8
STK_CONST:
	CALL	TEST_5_SP		; tests that room exists and sets BC to $05.
	EXX			; switch to alternate set
	PUSH	HL		; save the pointer to next literal on stack
	EXX			; switch back to main set
	EX	(SP),HL		; pointer to HL, destination to stack.
	PUSH	BC		; save BC - value 5 from test room ??.
	LD	A,(HL)		; fetch the byte following 'stk-data'
	AND	$C0		; isolate bits 7 and 6
	RLCA			; rotate
	RLCA			; to bits 1 and 0  range $00 - $03.
	LD	C,A		; transfer to C
	INC	C		; and increment to give number of bytes
				; to read. $01 - $04
	LD	A,(HL)		; reload the first byte
	AND	$3F		; mask off to give possible exponent.
	JR	NZ,FORM_EXP	; forward if it was possible to
				; include the exponent.

; else byte is just a byte count and exponent comes next.

	INC	HL		; address next byte and
	LD	A,(HL)		; pick up the exponent ( - $50).

	ORG	$33DE
FORM_EXP:	ADD	A,$50		; now add $50 to form actual exponent
	LD	(DE),A		; and load into first destination byte.
	LD	A,$05		; load accumulator with $05 and
	SUB	C		; subtract C to give count of trailing
				; zeros plus one.
	INC	HL		; increment source
	INC	DE		; increment destination
	LD	B,$00		; prepare to copy
	LDIR			; copy C bytes
	POP	BC		; restore 5 counter to BC ??.
	EX	(SP),HL		; put HL on stack as next literal pointer
				; and the stack value - result pointer -
				; to HL.
	EXX			; switch to alternate set.
	POP	HL		; restore next literal pointer from stack to HL'.
	EXX			; switch back to main set.
	LD	B,A		; zero count to B
	XOR	A		; clear accumulator

	ORG	$33F1
STK_ZEROS:
	DEC	B		; decrement B counter
	RET	Z		; return if zero.		>>
				; DE points to new STKEND
				; HL to new number.
	LD	(DE),A		; else load zero to destination
	INC	DE		; increase destination
	JR	STK_ZEROS		; loop back until done.

; -------------------------------
; THE 'SKIP CONSTANTS' SUBROUTINE
; -------------------------------
; This routine traverses variable-length entries in the table of constants,
; stacking intermediate, unwanted constants onto a dummy calculator stack,
; in the first five bytes of ROM.  The destination DE normally points to the
; end of the calculator stack which might be in the normal place or in the
; system variables area during E-LINE-NO; INT-TO-FP; stk-ten.  In any case,
; it would be simpler all round if the routine just shoved unwanted values
; where it is going to stick the wanted value.  The instruction LD DE, $0000
; can be removed.

	ORG	$33F7
SKIP_CONS:
	AND	A		; test if initially zero.

	ORG	$33F8
SKIP_NEXT:
	RET	Z		; return if zero.		>>
	PUSH	AF		; save count.
	PUSH	DE		; and normal STKEND

;;;	LD	DE,$0000		; dummy value for STKEND at start of ROM
;;;				; Note. not a fault but this has to be
;;;				; moved elsewhere when running in RAM.
;;;				; e.g. with Expandor Systems 'Soft ROM'.
				; Better still, write to the normal place.
	NOP			;+
	NOP			;+
	NOP			;+
	CALL	STK_CONST		; works through variable length records.
	POP	DE		; restore real STKEND
	POP	AF		; restore count
	DEC	A		; decrease
	JR	SKIP_NEXT		; loop back

; ------------------------------
; THE 'LOCATE MEMORY' SUBROUTINE
; ------------------------------
; This routine, when supplied with a base address in HL and an index in A,
; will calculate the address of the A'th entry, where each entry occupies
; five bytes.  It is used for reading the semi-tone table and addressing
; floating-point numbers in the calculator's memory area.
; It is not possible to use this routine for the table of constants as these
; six values are held in compressed format.

	ORG	$3406
LOC_MEM:	LD	C,A		; store the original number $00-$1F.
	RLCA			; X2 - double.
	RLCA			; X4 - quadruple.
	ADD	A,C		; X5 - now add original to multiply by five.
	LD	C,A		; place the result in the low byte.
	LD	B,$00		; set high byte to zero.
	ADD	HL,BC		; add to form address of start of number in HL.
	RET			; return.

; ------------------------------
; Get from memory area ($E0 etc.)
; ------------------------------
; Literals $E0 to $FF
; A holds $00-$1F offset.
; The calculator stack increases by 5 bytes.

	ORG	$340F
GET_MEM_XX:
	PUSH	DE		; save STKEND
	LD	HL,(MEM)		; base address of the memory cells.
	CALL	LOC_MEM		; so that HL = first byte
	CALL	MOVE_FP		; moves 5 bytes with memory check.
				; DE now points to new STKEND.
	POP	HL		; original STKEND is now RESULT pointer.
	RET			; return.

; --------------------------
; Stack a constant (A0 etc.)
; --------------------------
; This routine allows a one-byte instruction to stack up to 32 constants
; held in short form in a table of constants. In fact only 5 constants are
; required. On entry the A register holds the literal ANDed with 1F.
; It isn't very efficient and it would have been better to hold the
; numbers in full, five byte form and stack them in a similar manner
; to that used for semi-tone table values.

	ORG	$341B
STK_CONST_XX:
	LD	H,D		; save STKEND - required for result
	LD	L,E		;
	EXX			; swap
	PUSH	HL		; save pointer to next literal
	LD	HL,STK_ZERO	; start of table of constants
	EXX			;
	CALL	SKIP_CONS		;
	CALL	STK_CONST		;
	EXX			;
	POP	HL		; restore pointer to next literal.
	EXX			;
	RET			; return.

; --------------------------------
; Store in a memory area ($C0 etc.)
; --------------------------------
; Offsets $C0 to $DF
; Although 32 memory storage locations can be addressed, only six
; $C0 to $C5 are required by the ROM and only the thirty bytes (6*5)
; required for these are allocated. Spectrum programmers who wish to
; use the floating point routines from assembly language may wish to
; alter the system variable MEM to point to 160 bytes of RAM to have
; use the full range available.
; A holds the derived offset $00-$1F.
; This is a unary operation, so on entry HL points to the last value and DE
; points to STKEND.

	ORG	$342D
ST_MEM_XX:
	PUSH	HL		; save the result pointer.
	EX	DE,HL		; transfer to DE.
	LD	HL,(MEM)		; fetch the base of memory area.
	CALL	LOC_MEM		; sets HL to the destination.
	EX	DE,HL		; swap - HL is start, DE is destination.
	CALL	MOVE_FP		;
				; note. a short ld bc,5; ldir
				; the embedded memory check is not required
				; so these instructions would be faster.

	EX	DE,HL		; DE = STKEND
	POP	HL		; restore original result pointer
	RET			; return.

; -------------------------
; THE 'EXCHANGE' SUBROUTINE
; -------------------------
; (offset: $01 'exchange')
; This routine swaps the last two values on the calculator stack.
; On entry, as always with binary operations,
; HL=first number, DE=second number
; On exit, HL=result, DE=stkend.

	ORG	$343C
EXCHANGE:	LD	B,$05		; there are five bytes to be swapped

; start of loop.

	ORG	$343E
SWAP_BYTE:
	LD	A,(DE)		; each byte of second
	LD	C,(HL)		; each byte of first
	EX	DE,HL		; swap pointers
	LD	(DE),A		; store each byte of first
	LD	(HL),C		; store each byte of second
	INC	HL		; advance both
	INC	DE		; pointers.
	DJNZ	SWAP_BYTE		; loop back until all 5 done.
	EX	DE,HL		; even up the exchanges so that DE addresses
				; STKEND.
	RET			; return.

; ------------------------------
; THE 'SERIES GENERATOR' ROUTINE
; ------------------------------
; (offset: $86 'series-06')
; (offset: $88 'series-08')
; (offset: $8C 'series-0C')
; The Spectrum uses Chebyshev polynomials to generate approximations for
; SIN, ATN, LN and EXP.  These are named after the Russian mathematician
; Pafnuty Chebyshev, born in 1821, who did much pioneering work on numerical
; series.  As far as calculators are concerned, Chebyshev polynomials have an
; advantage over other series, for example the Taylor series, as they can
; reach an approximation in just six iterations for SIN, eight for EXP and
; twelve for LN and ATN.  The mechanics of the routine are interesting but
; for full treatment of how these are generated with demonstrations in
; Sinclair BASIC see "The Complete Spectrum ROM Disassembly" by Dr Ian Logan
; and Dr Frank O'Hara, published 1983 by Melbourne House.

	ORG	$3449
SERIES_XX:
	LD	B,A		; parameter $00 - $1F to B counter
	CALL	GEN_ENT_1		;
				; A recursive call to a special entry point
				; in the calculator that puts the B register
				; in the system variable BREG. The return
				; address is the next location and where
				; the calculator will expect its first
				; instruction - now pointed to by HL'.
				; The previous pointer to the series of
				; five-byte numbers goes on the machine stack.

; The initialization phase.

	DEFB	$31		;;duplicate	x,x
	DEFB	$0F		;;addition	x+x
	DEFB	$C0		;;st-mem-0	x+x
	DEFB	$02		;;delete		.
	DEFB	$A0		;;stk-zero	0
	DEFB	$C2		;;st-mem-2	0

; a loop is now entered to perform the algebraic calculation for each of
; the numbers in the series

	ORG	$3453
G_LOOP:	DEFB	$31		;;duplicate	v,v.
	DEFB	$E0		;;get-mem-0	v,v,x+2
	DEFB	$04		;;multiply	v,v*x+2
	DEFB	$E2		;;get-mem-2	v,v*x+2,v
	DEFB	$C1		;;st-mem-1
	DEFB	$03		;;subtract
	DEFB	$38		;;end-calc

; the previous pointer is fetched from the machine stack to HL' where it
; addresses one of the numbers of the series following the series literal.

	CALL	STK_DATA		; called directly to
				; push a value and advance HL'.
	CALL	GEN_ENT_2		; recursively re-enters
				; the calculator without disturbing
				; system variable BREG
				; HL' value goes on the machine stack and is
				; then loaded as usual with the next address.
	DEFB	$0F		;;addition
	DEFB	$01		;;exchange
	DEFB	$C2		;;st-mem-2
	DEFB	$02		;;delete
	DEFB	$35		;;dec-jr-nz
	DEFB	$EE		;;back to G_LOOP

; when the counted loop is complete the final subtraction yields the result
; for example SIN X.

	DEFB	$E1		;;get-mem-1
	DEFB	$03		;;subtract
	DEFB	$38		;;end-calc
	RET			; return with HL' pointing to location
				; after last number in series.

; ---------------------------------
; THE 'ABSOLUTE MAGNITUDE' FUNCTION
; ---------------------------------
; (offset: $2A 'abs')
; This calculator literal finds the absolute value of the last value,
; integer or floating point, on calculator stack.

	ORG	$346A
ABS:	LD	B,$FF		; signal abs
	JR	NEG_TEST		; forward

; ---------------------------
; THE 'UNARY MINUS' OPERATION
; ---------------------------
; (offset: $1B 'negate')
; Unary so on entry HL points to last value, DE to STKEND.

	ORG	$346E
NEGATE:	CALL	TEST_ZERO		;
	RET	C		; return if so leaving zero unchanged.
	LD	B,$00		; signal negate required before joining
				; common code.

	ORG	$3474
NEG_TEST:	LD	A,(HL)		; load first byte and
	AND	A		; test for zero
	JR	Z,INT_CASE	; forward if a small integer

; for floating point numbers a single bit denotes the sign.

	INC	HL		; address the first byte of mantissa.
	LD	A,B		; action flag	$FF=abs,	$00=neg.
	AND	$80		; now		$80	$00
	OR	(HL)		; sets bit 7 for abs
	RLA			; sets carry for abs and if number negative
	CCF			; complement carry flag
	RRA			; and rotate back in altering sign
	LD	(HL),A		; put the altered adjusted number back
	DEC	HL		; HL points to result
	RET			; return with DE unchanged

; ---

; for integer numbers an entire byte denotes the sign.

	ORG	$3483
INT_CASE:
	PUSH	DE		; save STKEND.
	PUSH	HL		; save pointer to the last value/result.
	CALL	INT_FETCH		; puts integer in DE and the sign in C.
	POP	HL		; restore the result pointer.
	LD	A,B		; $FF=abs, $00=neg
	OR	C		; $FF for abs, no change neg
	CPL			; $00 for abs, switched for neg
	LD	C,A		; transfer result to sign byte.
	CALL	INT_STORE		; to re-write the integer.
	POP	DE		; restore STKEND.
	RET			; return.

; ---------------------
; THE 'SIGNUM' FUNCTION
; ---------------------
; (offset: $29 'sgn')
; This routine replaces the last value on the calculator stack,
; which may be in floating point or integer form, with the integer values
; zero if zero, with one if positive and  with -minus one if negative.

	ORG	$3492
SGN:	CALL	TEST_ZERO		;
	RET	C		; exit if so as no change is required.
	PUSH	DE		; save pointer to STKEND.
	LD	DE,$0001		; the result will be 1.
	INC	HL		; skip over the exponent.
	RL	(HL)		; rotate the sign bit into the carry flag.
	DEC	HL		; step back to point to the result.
	SBC	A,A		; byte will be $FF if negative, $00 if positive.
	LD	C,A		; store the sign byte in the C register.
	CALL	INT_STORE		; overwrite the last value with 0001 and sign.
	POP	DE		; restore STKEND.
	RET			; return.

; -----------------
; THE 'IN' FUNCTION
; -----------------
; (offset: $2C 'in')
; This function reads a byte from an input port.

	ORG	$34A5
_IN:	CALL	FIND_INT2		; puts port address in BC.
				; All 16 bits are put on the address line.
	IN	A,(C)		; Read the port.
	JR	IN_PK_STK		; exit to STACK_A (via IN-PK-STK to save a byte
				; of instruction code).

; -------------------
; THE 'PEEK' FUNCTION
; -------------------
; (offset: $2B 'peek')
; This function returns the contents of a memory address.
; The entire address space can be peeked including the ROM.

	ORG	$34AC
PEEK:	CALL	FIND_INT2		; puts port address in BC.
	LD	A,(BC)		; load contents into A register.

	ORG	$34B0
IN_PK_STK	:
	JP	STACK_A		; exit via STACK-A to put the value on the
				; calculator stack.

; ------------------
; THE 'USR' FUNCTION
; ------------------
; (offset: $2d 'usr-no')
; The USR function followed by a number 0-65535 is the method by which
; the Spectrum invokes machine code programs. This function returns the
; contents of the BC register pair.
; Note. that STACK-BC re-initializes the IY register if a user-written
; program has altered it.

	ORG	$34B3
USR_NO:	CALL	FIND_INT2		; to fetch the supplied address into BC.
	LD	HL,STACK_BC	; address: STACK_BC is
	PUSH	HL		; pushed onto the machine stack.
	PUSH	BC		; then the address of the machine code
				; routine.
	RET			; make an indirect jump to the routine
				; and, hopefully, to STACK_BC also.

; -------------------------
; THE 'USR STRING' FUNCTION
; -------------------------
; (offset: $19 'usr-$')
; The user function with a one-character string argument, calculates the
; address of the User Defined Graphic character that is in the string.
; As an alternative, the ASCII equivalent, upper or lower case,
; may be supplied. This provides a user-friendly method of redefining
; the 21 User Definable Graphics e.g.
; POKE USR "a", BIN 10000000 will put a dot in the top left corner of the
; character 144.
; Note. the curious double check on the range. With 26 UDGs the first check
; only is necessary. With anything less the second check only is required.
; It is highly likely that the first check was written by Steven Vickers.

	ORG	$34BC
USR_STRING:
	CALL	STK_FETCH		; fetches the string parameters.
	DEC	BC		; decrease BC by
	LD	A,B		; one to test
	OR	C		; the length.
	JR	NZ,REPORT_A	; jump if not a single character.
	LD	A,(DE)		; fetch the character
	CALL	ALPHA		; sets carry if 'A-Z' or 'a-z'.
	JR	C,USR_RANGE	; forward if ASCII.
	SUB	$90		; make UDGs range 0-20d
	JR	C,REPORT_A	; jump if too low. e.g. usr " ".

	CP	$15		; Note. this test is not necessary.

	JR	NC,REPORT_A	; jump if higher than 20.
	INC	A		; make range 1-21d to match LSBs of ASCII

	ORG	$34D3
USR_RANGE:
	DEC	A		; make range of bits 0-4 start at zero
	ADD	A,A		; multiply by eight
	ADD	A,A		; and lose any set bits
	ADD	A,A		; range now 0 - 25*8
	CP	$A8		; compare to 21*8
	JR	NC,REPORT_A	; jump if originally higher
				; than 'U','u' or graphics U.
	LD	BC,(UDG)		; fetch the system variable value.
	ADD	A,C		; add the offset to character
	LD	C,A		; and store back in register C.
	JR	NC,USR_STACK	; forward if no overflow.
	INC	B		; increment high byte.

	ORG	$34E4
USR_STACK:
	JP	STACK_BC		; jump back and exit via STACK-BC to store

; ---

	ORG	$34E7
REPORT_A:	RST	08H		; ERROR_1
	DEFB	$09		; Error Report: Bad argument

; ------------------------------
; THE 'TEST FOR ZERO' SUBROUTINE
; ------------------------------
; Test if top value on calculator stack is zero.  The carry flag is set if
; the last value is zero but no registers are altered.
; All five bytes will be zero but first four only need be tested.
; On entry, HL points to the exponent the first byte of the value.

	ORG	$34E9
TEST_ZERO:
	PUSH	HL		; preserve HL which is used to address.
	PUSH	BC		; preserve BC which is used as a store.
	LD	B,A		; preserve A in B.
	LD	A,(HL)		; load first byte to accumulator
	INC	HL		; advance.
	OR	(HL)		; OR with second byte and clear carry.
	INC	HL		; advance.
	OR	(HL)		; OR with third byte.
	INC	HL		; advance.
	OR	(HL)		; OR with fourth byte.
	LD	A,B		; restore A without affecting flags.
	POP	BC		; restore the saved
	POP	HL		; registers.
	RET	NZ		; return if not zero and with carry reset.
	SCF			; set the carry flag.
	RET			; return with carry set if zero.

; --------------------------------
; THE 'GREATER THAN ZERO' OPERATOR
; --------------------------------
; (offset: $37 'greater-0' )
; Test if the last value on the calculator stack is greater than zero.
; This routine is also called directly from the end-tests of the comparison
; routine.

	ORG	$34F9
GREATER_0:
	CALL	TEST_ZERO		;
	RET	C		; return if was zero as this
				; is also the Boolean 'false' value.
	LD	A,$FF		; prepare XOR mask for sign bit
	JR	SIGN_TO_C		; forward to put sign in carry
				; (carry will become set if sign is positive)
				; and then overwrite location with 1 or 0
				; as appropriate.

; ------------------
; THE 'NOT' FUNCTION
; ------------------
; (offset: $30 'not')
; This overwrites the last value with 1 if it was zero else with zero
; if it was any other value.
;
; e.g. NOT 0 returns 1, NOT 1 returns 0, NOT -3 returns 0.
;
; The subroutine is also called directly from the end-tests of the comparison
; operator.

	ORG	$3501
NOT:	CALL	TEST_ZERO		; sets carry if zero
	JR	FP_0_1		; to overwrite operand with
				; 1 if carry is set else to overwrite with zero.

; ------------------------------
; THE 'LESS THAN ZERO' OPERATION
; ------------------------------
; (offset: $36 'less-0' )
; Destructively test if last value on calculator stack is less than zero.
; Bit 7 of second byte will be set if so.

	ORG	$3506
LESS_0:	XOR	A		; set XOR mask to zero
				; (carry will become set if sign is negative).

; transfer sign of mantissa to Carry Flag.

	ORG	$3507
SIGN_TO_C:
	INC	HL		; address 2nd byte.
	XOR	(HL)		; bit 7 of HL will be set if number is negative.
	DEC	HL		; address 1st byte again.
	RLCA			; rotate bit 7 of A to carry.

; ----------------------------
; THE 'ZERO OR ONE' SUBROUTINE
; ----------------------------
; This routine places an integer value of zero or one at the addressed
; location of the calculator stack or MEM area.  The value one is written if
; carry is set on entry else zero.

	ORG	$350B
FP_0_1:	PUSH	HL		; save pointer to the first byte
	LD	A,$00		; load accumulator with zero - without
				; disturbing flags.
	LD	(HL),A		; zero to first byte
	INC	HL		; address next
	LD	(HL),A		; zero to 2nd byte
	INC	HL		; address low byte of integer
	RLA			; carry to bit 0 of A
	LD	(HL),A		; load one or zero to low byte.
	RRA			; restore zero to accumulator.
	INC	HL		; address high byte of integer.
	LD	(HL),A		; put a zero there.
	INC	HL		; address fifth byte.
	LD	(HL),A		; put a zero there.
	POP	HL		; restore pointer to the first byte.
	RET			; return.

; -----------------
; THE 'OR' OPERATOR
; -----------------
; (offset: $07 'or' )
; The Boolean OR operator. e.g. X OR Y
; The result is zero if both values are zero else a non-zero value.
;
; e.g.	 0 OR 0  returns 0.
;	-3 OR 0  returns -3.
;	 0 OR -3 returns 1.
;	-3 OR 2  returns 1.
;
; A binary operation.
; On entry HL points to first operand (X) and DE to second operand (Y).

	ORG	$351B
_OR:	EX	DE,HL		; make HL point to second number
	CALL	TEST_ZERO		;
	EX	DE,HL		; restore pointers
	RET	C		; return if result was zero - first operand,
				; now the last value, is the result.
	SCF			; set carry flag
	JR	FP_0_1		; back to overwrite the first operand
				; with the value 1.


; ---------------------------------
; THE 'NUMBER AND NUMBER' OPERATION
; ---------------------------------
; (offset: $08 'no-&-no')
; The Boolean AND operator.
;
; e.g.	-3 AND 2  returns -3.
;	-3 AND 0  returns 0.
;	 0 AND -2 returns 0.
;	 0 AND 0  returns 0.
;
; Compare with OR routine above.

	ORG	$3524
NO_AND_NO:
	EX	DE,HL		; make HL address second operand.
	CALL	TEST_ZERO		; sets carry if zero.
	EX	DE,HL		; restore pointers.
	RET	NC		; return if second non-zero, first is result.

;

	AND	A		; else clear carry.
	JR	FP_0_1		; back to FP_0_1 to overwrite first operand
				; with zero for return value.

; ---------------------------------
; THE 'STRING AND NUMBER' OPERATION
; ---------------------------------
; (offset: $10 'str-&-no')
; e.g. "You Win" AND score>99 will return the string if condition is true
; or the null string if false.

	ORG	$352D
STR_AND_NO:
	EX	DE,HL		; make HL point to the number.
	CALL	TEST_ZERO		;
	EX	DE,HL		; restore pointers.
	RET	NC		; return if number was not zero - the string
				; is the result.

; if the number was zero (false) then the null string must be returned by
; altering the length of the string on the calculator stack to zero.

	PUSH	DE		; save pointer to the now obsolete number
				; (which will become the new STKEND)
	DEC	DE		; point to the 5th byte of string descriptor.
	XOR	A		; clear the accumulator.
	LD	(DE),A		; place zero in high byte of length.
	DEC	DE		; address low byte of length.
	LD	(DE),A		; place zero there - now the null string.
	POP	DE		; restore pointer - new STKEND.
	RET			; return.

; ---------------------------
; THE 'COMPARISON' OPERATIONS
; ---------------------------
; (offset: $0A 'no-gr-eql')
; (offset: $0B 'nos-neql')
; (offset: $0C 'no-grtr')
; (offset: $0D 'no-less')
; (offset: $0E 'nos-eql')
; (offset: $11 'str-l-eql')
; (offset: $12 'str-gr-eql')
; (offset: $13 'strs-neql')
; (offset: $14 'str-grtr')
; (offset: $15 'str-less')
; (offset: $16 'strs-eql')

; True binary operations.
; A single entry point is used to evaluate six numeric and six string
; comparisons. On entry, the calculator literal is in the B register and
; the two numeric values, or the two string parameters, are on the
; calculator stack.
; The individual bits of the literal are manipulated to group similar
; operations although the SUB 8 instruction does nothing useful and merely
; alters the string test bit.
; Numbers are compared by subtracting one from the other, strings are
; compared by comparing every character until a mismatch, or the end of one
; or both, is reached.
;
; Numeric Comparisons.
; --------------------
; The 'x>y' example is the easiest as it employs straight-thru logic.
; Number y is subtracted from x and the result tested for greater-0 yielding
; a final value 1 (true) or 0 (false).
; For 'x<y' the same logic is used but the two values are first swapped on the
; calculator stack.
; For 'x=y' NOT is applied to the subtraction result yielding true if the
; difference was zero and false with anything else.
; The first three numeric comparisons are just the opposite of the last three
; so the same processing steps are used and then a final NOT is applied.
;
; literal	    Test No  sub 8       ExOrNot  1st RRCA  exch sub  ?   End-Tests
; =========  ==== == ======== === ======== ========  ==== ===  =  === === ===
; no-l-eql   x<=y 09 00000001 dec 00000000 00000000  ---- x-y  ?  --- >0? NOT
; no-gr-eql  x>=y 0A 00000010 dec 00000001 10000000c swap y-x  ?  --- >0? NOT
; nos-neql   x<>y 0B 00000011 dec 00000010 00000001  ---- x-y  ?  NOT --- NOT
; no-grtr    x>y  0C 00000100  -  00000100 00000010  ---- x-y  ?  --- >0? ---
; no-less    x<y  0D 00000101  -  00000101 10000010c swap y-x  ?  --- >0? ---
; nos-eql    x=y  0E 00000110  -  00000110 00000011  ---- x-y  ?  NOT --- ---
;
;                                                           comp -> C/F
;                                                           ====    ===
; str-l-eql  x$<=y$ 11 00001001 dec 00001000 00000100  ---- x$y$ 0  !or >0? NOT
; str-gr-eql x$>=y$ 12 00001010 dec 00001001 10000100c swap y$x$ 0  !or >0? NOT
; strs-neql  x$<>y$ 13 00001011 dec 00001010 00000101  ---- x$y$ 0  !or >0? NOT
; str-grtr  x$>y$  14 00001100  -  00001100 00000110  ---- x$y$ 0  !or >0? ---
; str-less  x$<y$  15 00001101  -  00001101 10000110c swap y$x$ 0  !or >0? ---
; strs-eql  x$=y$  16 00001110  -  00001110 00000111  ---- x$y$ 0  !or >0? ---
;
; String comparisons are a little different in that the eql/neql carry flag
; from the 2nd RRCA is, as before, fed into the first of the end tests but
; along the way it gets modified by the comparison process. The result on the
; stack always starts off as zero and the carry fed in determines if NOT is
; applied to it. So the only time the greater-0 test is applied is if the
; stack holds zero which is not very efficient as the test will always yield
; zero. The most likely explanation is that there were once separate end tests
; for numbers and strings.

	ORG	$353B
NO_1_EQL_ETC:
	LD	A,B		; transfer literal to accumulator.
	SUB	$08		; subtract eight - which is not useful.
	BIT	2,A		; isolate '>', '<', '='.
	JR	NZ,EX_OR_NOT	; skip with these.
	DEC	A		; else make $00-$02, $08-$0A to match bits 0-2.

	ORG	$3543
EX_OR_NOT:
	RRCA			; the first RRCA sets carry for a swap.
	JR	NC,NU_OR_STR	; forward with other 8 cases

; for the other 4 cases the two values on the calculator stack are exchanged.

	PUSH	AF		; save A and carry.
	PUSH	HL		; save HL - pointer to first operand.
				; (DE points to second operand).
	CALL	EXCHANGE		; swaps the two values.
				; (HL = second operand, DE = STKEND)
	POP	DE		; DE = first operand
	EX	DE,HL		; as we were.
	POP	AF		; restore A and carry.

; Note. it would be better if the 2nd RRCA preceded the string test.
; It would save two duplicate bytes and if we also got rid of that sub 8
; at the beginning we wouldn't have to alter which bit we test.

	ORG	$354E
NU_OR_STR:
	BIT	2,A		; test if a string comparison.
	JR	NZ,STRINGS	; forward if so.

; continue with numeric comparisons.

	RRCA			; 2nd RRCA causes eql/neql to set carry.
	PUSH	AF		; save A and carry
	CALL	SUBTRACT		; leaves result on stack.
	JR	END_TESTS		; forward

; ---

	ORG	$3559
STRINGS:	RRCA			; 2nd RRCA causes eql/neql to set carry.
	PUSH	AF		; save A and carry.
	CALL	STK_FETCH		; gets 2nd string params
	PUSH	DE		; save start2 *.
	PUSH	BC		; and the length.
	CALL	STK_FETCH		; gets 1st string
				; parameters - start in DE, length in BC.
	POP	HL		; restore length of second to HL.

; A loop is now entered to compare, by subtraction, each corresponding character
; of the strings. For each successful match, the pointers are incremented and
; the lengths decreased and the branch taken back to here. If both string
; remainders become null at the same time, then an exact match exists.

	ORG	$3564
BYTE_COMP:
	LD	A,H		; test if the second string
	OR	L		; is the null string and hold flags.
	EX	(SP),HL		; put length2 on stack, bring start2 to HL *.
	LD	A,B		; hi byte of length1 to A
	JR	NZ,SEC_PLUS	; forward if second not null.
	OR	C		; test length of first string.

	ORG	$356B
SECND_LOW:
	POP	BC		; pop the second length off stack.
	JR	Z,BOTH_NULL	; forward if first string is also of zero length.

; the true condition - first is longer than second (SECND-LESS)

	POP	AF		; restore carry (set if eql/neql)
	CCF			; complement carry flag.
				; Note. equality becomes false.
				; Inequality is true. By swapping or applying
				; a terminal 'not', all comparisons have been
				; manipulated so that this is success path.
	JR	STR_TEST		; forward to leave via STR_TEST

; ---
; the branch was here with a match

	ORG	$3572
BOTH_NULL:
	POP	AF		; restore carry - set for eql/neql
	JR	STR_TEST		; forward

; ---
; the branch was here when 2nd string not null and low byte of first is yet
; to be tested.

	ORG	$3575
SEC_PLUS:	OR	C		; test the length of first string.
	JR	Z,FRST_LESS	; forward if length is zero.

; both strings have at least one character left.

	LD	A,(DE)		; fetch character of first string.
	SUB	(HL)		; subtract with that of 2nd string.
	JR	C,FRST_LESS	; forward if carry set
	JR	NZ,SECND_LOW	; back to SECND_LOW and then STR_TEST
				; if not exact match.
	DEC	BC		; decrease length of 1st string.
	INC	DE		; increment 1st string pointer.
	INC	HL		; increment 2nd string pointer.
	EX	(SP),HL		; swap with length on stack
	DEC	HL		; decrement 2nd string length
	JR	BYTE_COMP		; back

; ---
; the false condition.

	ORG	$3585
FRST_LESS:
	POP	BC		; discard length
	POP	AF		; pop A
	AND	A		; clear the carry for false result.

; ---
; exact match and x$>y$ rejoin here

	ORG	$3588
STR_TEST:	PUSH	AF		; save A and carry
	RST	28H		;; FP_CALC
	DEFB	$A0		;;stk-zero	an initial false value.
	DEFB	$38		;;end-calc

; both numeric and string paths converge here.

	ORG	$358C
END_TESTS:
	POP	AF		; pop carry	- will be set if eql/neql
	PUSH	AF		; save it again.
	CALL	C,NOT		; sets true(1) if equal(0)
				; or, for strings, applies true result.
	POP	AF		; pop carry and
	PUSH	AF		; save A
	CALL	NC,GREATER_0	; tests numeric subtraction
				; result but also needlessly tests the string
				; value for zero - it must be.
	POP	AF		; pop A
	RRCA			; the third RRCA - test for '<=', '>=' or '<>'.
	CALL	NC,NOT		; apply a terminal NOT if so.
	RET			; return.

; ------------------------------------
; THE 'STRING CONCATENATION' OPERATION
; ------------------------------------
; (offset: $17 'strs-add')
; This literal combines two strings into one e.g. LET a$ = b$ + c$
; The two parameters of the two strings to be combined are on the stack.

	ORG	$359C
STRS_ADD:	CALL	STK_FETCH		; fetches string parameters
				; and deletes calculator stack entry.
	PUSH	DE		; save start address.
	PUSH	BC		; and length.
	CALL	STK_FETCH		; for first string
	POP	HL		; re-fetch first length
	PUSH	HL		; and save again
	PUSH	DE		; save start of second string
	PUSH	BC		; and its length.
	ADD	HL,BC		; add the two lengths.
	LD	B,H		; transfer to BC
	LD	C,L		; and create
	RST	30H		; BC_SPACES in workspace.
				; DE points to start of space.
	CALL	STK_STO_STR	; stores parameters
				; of new string updating STKEND.
	POP	BC		; length of first
	POP	HL		; address of start
	LD	A,B		; test for
	OR	C		; zero length.
	JR	Z,OTHER_STR	; jump if null string
	LDIR			; copy string to workspace.

	ORG	$35B7
OTHER_STR:
	POP	BC		; now second length
	POP	HL		; and start of string
	LD	A,B		; test this one
	OR	C		; for zero length
	JR	Z,STK_PNTRS	; skip forward to STK-PNTRS if so as complete.
	LDIR			; else copy the bytes.
				; and continue into next routine which
				; sets the calculator stack pointers.

; -----------------------------------
; THE 'SET STACK POINTERS' SUBROUTINE
; -----------------------------------
; Register DE is set to STKEND and HL, the result pointer, is set to five
; locations below this.
; This routine is used when it is inconvenient to save these values at the
; time the calculator stack is manipulated due to other activity on the
; machine stack.
; This routine is also used to terminate the VAL and READ-IN  routines for
; the same reason and to initialize the calculator stack at the start of
; the CALCULATE routine.

	ORG	$35BF
STK_PNTRS:
	LD	HL,(STKEND)	; fetch value from system variable.
	LD	DE,$FFFB		; the value -5
	PUSH	HL		; push STKEND value.
	ADD	HL,DE		; subtract 5 from HL.
	POP	DE		; pop STKEND to DE.
	RET			; return.

; -------------------
; THE 'CHR$' FUNCTION
; -------------------
; (offset: $2f 'chr$')
; This function returns a single character string that is a result of
; converting a number in the range 0-255 to a string e.g. CHR$ 65 = "A".

	ORG	$35C9
CHRS:	CALL	FP_TO_A		; puts the number in A.
	JR	C,REPORT_Bd	; forward if overflow
	JR	NZ,REPORT_Bd	; forward if negative

; Note. the next location is called by the Opus Discovery Interface.

x35D0:	PUSH	AF		; save the argument.
	LD	BC,$0001		; one space required.
	RST	30H		; BC_SPACES makes DE point to start
	POP	AF		; restore the number.
	LD	(DE),A		; and store in workspace
	CALL	STK_STO_STR		; routine STK-STO-$ stacks descriptor.
	EX	DE,HL		; make HL point to result and DE to STKEND.
	RET			; return.

; ---

	ORG	$35DC
REPORT_Bd:
	RST	08H		; ERROR_1
	DEFB	$0A		; Error Report: Out of range

; ----------------------------
; THE 'VAL and VAL$' FUNCTIONS
; ----------------------------
; (offset: $1d 'val')
; (offset: $18 'val$')
; VAL treats the characters in a string as a numeric expression.
; e.g. VAL "2.3" = 2.3, VAL "2+4" = 6, VAL ("2" + "4") = 24.
; VAL$ treats the characters in a string as a string expression.
; e.g. VAL$ (z$+"(2)") = a$(2) if z$ happens to be "a$".

	ORG	$35DE
VAL:	LD	HL,(CH_ADD)	; fetch value of system variable
	PUSH	HL		; and save on the machine stack.
	LD	A,B		; fetch the literal (either $1D or $18).
	ADD	A,$E3		; add $E3 to form $00 (setting carry) or $FB.
	SBC	A,A		; now form $FF bit 6 = numeric result
				; or $00 bit 6 = string result.
	PUSH	AF		; save this mask on the stack
	CALL	STK_FETCH		; fetches the string operand
				; from calculator stack.
	PUSH	DE		; save the address of the start of the string.
	INC	BC		; increment the length for a carriage return.
	RST	30H		; BC_SPACES creates the space in workspace.
	POP	HL		; restore start of string to HL.
	LD	(CH_ADD),DE	; load CH_ADD with start DE in workspace.
	PUSH	DE		; save the start in workspace
	LDIR			; copy string from program or variables or
				; workspace to the workspace area.
	EX	DE,HL		; end of string + 1 to HL
	DEC	HL		; decrement HL to point to end of new area.
	LD	(HL),$0D		; insert a carriage return at end.
	RES	7,(IY+$01)	; update FLAGS  - signal checking syntax.
	CALL	SCANNING		; evaluates string expression and result.
	RST	18H		; GET_CHAR fetches next character.
	CP	$0D		; is it the expected carriage return ?
	JR	NZ,V_RPORT_C	; forward if not
				; 'Syntax error'.
	POP	HL		; restore start of string in workspace.
	POP	AF		; restore expected result flag (bit 6).
	XOR	(IY+$01)		; xor with FLAGS now updated by SCANNING.
	AND	$40		; test bit 6 - should be zero if result types
				; match.

	ORG	$360C
V_RPORT_C:
	JP	NZ,REPORT_C		; jump back to REPORT-C with a result mismatch.
	LD	(CH_ADD),HL	; set CH_ADD to the start of the string again.
	SET	7,(IY+$01)	; update FLAGS  - signal running program.
	CALL	SCANNING		; evaluates the string
				; in full leaving result on calculator stack.
	POP	HL		; restore saved character address in program.
	LD	(CH_ADD),HL	; and reset the system variable CH_ADD.
	JR	STK_PNTRS		; back to exit via STK_PNTRS.
				; resetting the calculator stack pointers
				; HL and DE from STKEND as it wasn't possible
				; to preserve them during this routine.

; -------------------
; THE 'STR$' FUNCTION
; -------------------
; (offset: $2e 'str$')
; This function produces a string comprising the characters that would appear
; if the numeric argument were printed.
; e.g. STR$ (1/10) produces "0.1".

	ORG	$361F
STR:	LD	BC,$0001		; create an initial byte in workspace
	RST	30H		; using BC_SPACES restart.
	LD	(K_CUR),HL	; set system variable to new location.
	PUSH	HL		; and save start on machine stack also.
	LD	HL,(CURCHL)	; fetch value of system variable
	PUSH	HL		; and save that too.
	LD	A,$FF		; select system channel 'R'.
	CALL	CHAN_OPEN		; opens it.
	CALL	PRINT_FP		; outputs the number to
				; workspace updating K-CUR.
	POP	HL		; restore current channel.
	CALL	CHAN_FLAG		; resets flags.
	POP	DE		; fetch saved start of string to DE.
	LD	HL,(K_CUR)	; load HL with end of string from K_CUR.
	AND	A		; prepare for true subtraction.
	SBC	HL,DE		; subtract start from end to give length.
	LD	B,H		; transfer the length to
	LD	C,L		; the BC register pair.
	CALL	STK_STO_STR	; stores string parameters
				; on the calculator stack.
	EX	DE,HL		; HL = last value, DE = STKEND.
	RET			; return.

; ------------------------
; THE 'READ-IN' SUBROUTINE
; ------------------------
; (offset: $1a 'read-in')
; This is the calculator literal used by the INKEY$ function when a '#'
; is encountered after the keyword.
; INKEY$ # does not interact correctly with the keyboard, #0 or #1, and
; its uses are for other channels.

	ORG	$3645
READ_IN:	CALL	FIND_INT1		; fetches stream to A
	CP	$10		; compare with 16 decimal.
	JP	NC,REPORT_Bb	; jump if not in range 0 - 15.
				; 'Out of range'
				; (REPORT_Bd is within range)
	LD	HL,(CURCHL)	; fetch current channel
	PUSH	HL		; save it
	CALL	CHAN_OPEN		; opens channel
	CALL	INPUT_AD		; the channel must have an input stream
				; or else error here from stream stub.
	LD	BC,$0000		; initialize length of string to zero
	JR	NC,R_I_STORE	; forward if no key detected.
	INC	C		; increase length to one.
	RST	30H		; BC_SPACES creates space for one character
				; in workspace.
	LD	(DE),A		; the character is inserted.

	ORG	$365F
R_I_STORE:
	CALL	STK_STO_STR	; stacks the string parameters.
	POP	HL		; restore current channel address
	CALL	CHAN_FLAG		; resets current channel
				; system variable and flags.
	JP	STK_PNTRS		; jump back

; -------------------
; THE 'CODE' FUNCTION
; -------------------
; (offset: $1c 'code')
; Returns the ASCII code of a character or first character of a string
; e.g. CODE "Aardvark" = 65, CODE "" = 0.

	ORG	$3669
CODE:	CALL	STK_FETCH		; fetch and delete the
				; string parameters.
				; DE points to the start, BC holds the length.
	LD	A,B		; test length
	OR	C		; of the string.
	JR	Z,STK_CODE	; skip with zero if the null string.
	LD	A,(DE)		; else fetch the first character.

	ORG	$3671
STK_CODE:	JP	STACK_A		; jump back (with memory check)

; ------------------
; THE 'LEN' FUNCTION
; ------------------
; (offset: $1e 'len')
; Returns the length of a string.
; In Sinclair BASIC strings can be more than twenty thousand characters long
; so a sixteen-bit register is required to store the length

	ORG	$3674
LEN:	CALL	STK_FETCH		; fetch and delete the
				; string parameters from the calculator stack.
				; Register BC now holds the length of string.
	JP	STACK_BC		; Jump back to save result on the
				; calculator stack (with memory check).

; -------------------------------------
; THE 'DECREASE THE COUNTER' SUBROUTINE
; -------------------------------------
; (offset: $35 'dec-jr-nz')
; The calculator has an instruction that decrements a single-byte
; pseudo-register and makes consequential relative jumps just like
; the Z80's DJNZ instruction.

	ORG	$367A
DEC_JR_NZ:
	EXX			; switch in set that addresses code
	PUSH	HL		; save pointer to offset byte
	LD	HL,BREG		; address BREG in system variables
	DEC	(HL)		; decrement it
	POP	HL		; restore pointer
	JR	NZ,JUMP_2		; to JUMP_2 if not zero
	INC	HL		; step past the jump length.
	EXX			; switch in the main set.
	RET			; return.

; Note. as a general rule the calculator avoids using the IY register
; otherwise the cumbersome 4 instructions in the middle could be replaced by
; dec (iy+$2d) - three bytes instead of six.

; ---------------------
; THE 'JUMP' SUBROUTINE
; ---------------------
; (offset: $33 'jump')
; This enables the calculator to perform relative jumps just like the Z80
; chip's JR instruction.

	ORG	$3686
JUMP:	EXX			; switch in pointer set

	ORG	$3687
JUMP_2:	LD	E,(HL)		; the jump byte 0-127 forward, 128-255 back.
	LD	A,E		; transfer to accumulator.
	RLA			; if backward jump, carry is set.
	SBC	A,A		; will be $FF if backward or $00 if forward.
	LD	D,A		; transfer to high byte.
	ADD	HL,DE		; advance calculator pointer forward or back.
	EXX			; switch back.
	RET			; return.

; --------------------------
; THE 'JUMP-TRUE' SUBROUTINE
; --------------------------
; (offset: $00 'jump-true')
; This enables the calculator to perform conditional relative jumps dependent
; on whether the last test gave a true result.

	ORG	$368F
JUMP_TRUE:
	INC	DE		; Collect the
	INC	DE		; third byte
	LD	A,(DE)		; of the test
	DEC	DE		; result and
	DEC	DE		; backtrack.
	AND	A		; Is result 0 or 1 ?
	JR	NZ,JUMP		; Back to JUMP if true (1).
	EXX			; Else switch in the pointer set.
	INC	HL		; Step past the jump length.
	EXX			; Switch in the main set.
	RET			; Return.

; -------------------------
; THE 'END-CALC' SUBROUTINE
; -------------------------
; (offset: $38 'end-calc')
; The end-calc literal terminates a mini-program written in the Spectrum's
; internal language.

	ORG	$369B
END_CALC:
	POP	AF		; Drop the calculator return address RE-ENTRY
	EXX			; Switch to the other set.
	EX	(SP),HL		; Transfer HL' to machine stack for the
				; return address.
				; When exiting recursion, then the previous
				; pointer is transferred to H'L'.
	EXX			; Switch back to main set.
	RET			; Return.

; ------------------------
; THE 'MODULUS' SUBROUTINE
; ------------------------
; (offset: $32 'n-mod-m')
; (n1,n2 -- r,q)
; Similar to FORTH's 'divide mod' /MOD
; On the Spectrum, this is only used internally by the RND function and could
; have been implemented inline.  On the ZX81, this calculator routine was also
; used by PRINT-FP.
; Note. It is called by by the Opus Discovery Disk Interface.

	ORG	$36A0
N_MOD_M:	RST	28H		;; FP_CALC	17, 3.
	DEFB	$C1		;;st-mem-1	17, 3.
	DEFB	$02		;;delete		17.
	DEFB	$31		;;duplicate	17, 17.
	DEFB	$E1		;;get-mem-1	17, 17, 3.
	DEFB	$05		;;division	17, 17/3.
	DEFB	$27		;;int		17, 5.
	DEFB	$E1		;;get-mem-1	17, 5, 3.
	DEFB	$01		;;exchange	17, 3, 5.
	DEFB	$C1		;;st-mem-1	17, 3, 5.
	DEFB	$04		;;multiply	17, 15.
	DEFB	$03		;;subtract	2.
	DEFB	$E1		;;get-mem-1	2, 5.
	DEFB	$38		;;end-calc	2, 5.
	RET			; return.

; ------------------
; THE 'INT' FUNCTION
; ------------------
; (offset $27: 'int' )
; This function returns the integer of x, which is just the same as truncate
; for positive numbers. The truncate literal truncates negative numbers
; upwards so that -3.4 gives -3 whereas the BASIC INT function has to
; truncate negative numbers down so that INT -3.4 is -4.
; It is best to work through using, say, +-3.4 as examples.

	ORG	$36AF
INT:	RST	28H		;; FP_CALC	x. (= 3.4 or -3.4).
	DEFB	$31		;;duplicate	x, x.
	DEFB	$36		;;less-0		x, (1/0)
	DEFB	$00		;;jump-true	x, (1/0)
	DEFB	$04		;;to X_NEG
	DEFB	$3A		;;truncate	trunc 3.4 = 3.
	DEFB	$38		;;end-calc	3.
	RET			; return with + int x on stack.

; ---

	ORG	$36B7
X_NEG:	DEFB	$31		;;duplicate	-3.4, -3.4.
	DEFB	$3A		;;truncate	-3.4, -3.
	DEFB	$C0		;;st-mem-0	-3.4, -3.
	DEFB	$03		;;subtract	-.4
	DEFB	$E0		;;get-mem-0	-.4, -3.
	DEFB	$01		;;exchange	-3, -.4.
	DEFB	$30		;;not		-3, (0).
	DEFB	$00		;;jump-true	-3.
	DEFB	$03		;;to EXIT		-3.
	DEFB	$A1		;;stk-one		-3, 1.
	DEFB	$03		;;subtract	-4.

	ORG	$36C2
EXIT:	DEFB	$38		;;end-calc	-4.
	RET			; return.

; ------------------
; THE 'EXP' FUNCTION
; ------------------
; (offset $26: 'exp')
; The exponential function EXP x is equal to e^x, where e is the mathematical
; name for a number approximated to 2.718281828.
; ERROR 6 if argument is more than about 88.

	ORG	$36C4
EXP:	RST	28H		;; FP_CALC
	DEFB	$3D		;;re-stack  (not required - mult will do)
	DEFB	$34		;;stk-data
	DEFB	$F1		;;Exponent: $81, Bytes: 4
	DEFB	$38,$AA,$3B,$29	;;
	DEFB	$04		;;multiply
	DEFB	$31		;;duplicate
	DEFB	$27		;;int
	DEFB	$C3		;;st-mem-3
	DEFB	$03		;;subtract
	DEFB	$31		;;duplicate
	DEFB	$0F		;;addition
	DEFB	$A1		;;stk-one
	DEFB	$03		;;subtract
	DEFB	$88		;;series-08
	DEFB	$13		;;Exponent: $63, Bytes: 1
	DEFB	$36		;;(+00,+00,+00)
	DEFB	$58		;;Exponent: $68, Bytes: 2
	DEFB	$65,$66		;;(+00,+00)
	DEFB	$9D		;;Exponent: $6D, Bytes: 3
	DEFB	$78,$65,$40	;;(+00)
	DEFB	$A2		;;Exponent: $72, Bytes: 3
	DEFB	$60,$32,$C9	;;(+00)
	DEFB	$E7		;;Exponent: $77, Bytes: 4
	DEFB	$21,$F7,$AF,$24	;;
	DEFB	$EB		;;Exponent: $7B, Bytes: 4
	DEFB	$2F,$B0,$B0,$14	;;
	DEFB	$EE		;;Exponent: $7E, Bytes: 4
	DEFB	$7E,$BB,$94,$58	;;
	DEFB	$F1		;;Exponent: $81, Bytes: 4
	DEFB	$3A,$7E,$F8,$CF	;;
	DEFB	$E3		;;get-mem-3
	DEFB	$38		;;end-calc
	CALL	FP_TO_A		;
	JR	NZ,N_NEGTV	;
	JR	C,REPORT_6b	; 'Overflow'
	ADD	A,(HL)		;
	JR	NC,RESULT_OK	;

	ORG	$3703
REPORT_6b:
	RST	08H		; ERROR_1
	DEFB	$05		; Error Report: Overflow

; ---

	ORG	$3705
N_NEGTV:	JR	C,RSLT_ZERO	;
	SUB	(HL)		;
	JR	NC,RSLT_ZERO	;
	NEG			; Negate

	ORG	$370C
RESULT_OK:
	LD	(HL),A		;
	RET			; return.

; ---

	ORG	$370E
RSLT_ZERO:
	RST	28H		;; FP_CALC
	DEFB	$02		;;delete
	DEFB	$A0		;;stk-zero
	DEFB	$38		;;end-calc
	RET			; return.

; --------------------------------
; THE 'NATURAL LOGARITHM' FUNCTION
; --------------------------------
; (offset $25: 'ln')
; Function to calculate the natural logarithm (to the base e ).
; Natural logarithms were devised in 1614 by well-traveled Scotsman John
; Napier who noted
; "Nothing doth more molest and hinder calculators than the multiplications,
;  divisions, square and cubical extractions of great numbers".
;
; Napier's logarithms enabled the above operations to be accomplished by
; simple addition and subtraction simplifying the navigational and
; astronomical calculations which beset his age.
; Napier's logarithms were quickly overtaken by logarithms to the base 10
; devised, in conjunction with Napier, by Henry Briggs a Cambridge-educated
; professor of Geometry at Oxford University. These simplified the layout
; of the tables enabling humans to easily scale calculations.
;
; It is only recently with the introduction of pocket calculators and machines
; like the ZX Spectrum that natural logarithms are once more at the fore,
; although some computers retain logarithms to the base ten.
;
; 'Natural' logarithms are powers to the base 'e', which like 'pi' is a
; naturally occurring number in branches of mathematics.
; Like 'pi' also, 'e' is an irrational number and starts 2.718281828...
;
; The tabular use of logarithms was that to multiply two numbers one looked
; up their two logarithms in the tables, added them together and then looked
; for the result in a table of antilogarithms to give the desired product.
;
; The EXP function is the BASIC equivalent of a calculator's 'antiln' function
; and by picking any two numbers, 1.72 and 6.89 say,
; 10 PRINT EXP ( LN 1.72 + LN 6.89 )
; will give just the same result as
; 20 PRINT 1.72 * 6.89.
; Division is accomplished by subtracting the two logs.
;
; Napier also mentioned "square and cubicle extractions".
; To raise a number to the power 3, find its 'ln', multiply by 3 and find the
; 'antiln'.  e.g. PRINT EXP( LN 4 * 3 )  gives 64.
; Similarly to find the n'th root divide the logarithm by 'n'.
; The ZX81 ROM used PRINT EXP ( LN 9 / 2 ) to find the square root of the
; number 9. The Napieran square root function is just a special case of
; the 'to_power' function. A cube root or indeed any root/power would be just
; as simple.

; First test that the argument to LN is a positive, non-zero number.
; Error A if the argument is 0 or negative.

	ORG	$3713
LN:	RST	28H		;; FP_CALC
	DEFB	$3D		;;re-stack
	DEFB	$31		;;duplicate
	DEFB	$37		;;greater-0
	DEFB	$00		;;jump-true
	DEFB	$04		;;to VALID
	DEFB	$38		;;end-calc

	ORG	$371A
REPORT_Ab:
	RST	08H		; ERROR_1
	DEFB	$09		; Error Report: Bad argument

	ORG	$371C
VALID:	DEFB	$A0		;;stk-zero	Note. not
	DEFB	$02		;;delete		necessary.
	DEFB	$38		;;end-calc
	LD	A,(HL)		;
	LD	(HL),$80		;
	CALL	STACK_A		;
	RST	28H		;; FP_CALC
	DEFB	$34		;;stk-data
	DEFB	$38		;;Exponent: $88, Bytes: 1
	DEFB	$00		;;(+00,+00,+00)
	DEFB	$03		;;subtract
	DEFB	$01		;;exchange
	DEFB	$31		;;duplicate
	DEFB	$34		;;stk-data
	DEFB	$F0		;;Exponent: $80, Bytes: 4
	DEFB	$4C,$CC,$CC,$CD	;;
	DEFB	$03		;;subtract
	DEFB	$37		;;greater-0
	DEFB	$00		;;jump-true
	DEFB	$08		;;to L373D, GRE.8
	DEFB	$01		;;exchange
	DEFB	$A1		;;stk-one
	DEFB	$03		;;subtract
	DEFB	$01		;;exchange
	DEFB	$38		;;end-calc
	INC	(HL)		;
	RST	28H		;; FP_CALC

	ORG	$373D
GRE_8:	DEFB	$01		;;exchange
	DEFB	$34		;;stk-data
	DEFB	$F0		;;Exponent: $80, Bytes: 4
	DEFB	$31,$72,$17,$F8	;;
	DEFB	$04		;;multiply
	DEFB	$01		;;exchange
	DEFB	$A2		;;stk-half
	DEFB	$03		;;subtract
	DEFB	$A2		;;stk-half
	DEFB	$03		;;subtract
	DEFB	$31		;;duplicate
	DEFB	$34		;;stk-data
	DEFB	$32		;;Exponent: $82, Bytes: 1
	DEFB	$20		;;(+00,+00,+00)
	DEFB	$04		;;multiply
	DEFB	$A2		;;stk-half
	DEFB	$03		;;subtract
	DEFB	$8C		;;series-0C
	DEFB	$11		;;Exponent: $61, Bytes: 1
	DEFB	$AC		;;(+00,+00,+00)
	DEFB	$14		;;Exponent: $64, Bytes: 1
	DEFB	$09		;;(+00,+00,+00)
	DEFB	$56		;;Exponent: $66, Bytes: 2
	DEFB	$DA,$A5		;;(+00,+00)
	DEFB	$59		;;Exponent: $69, Bytes: 2
	DEFB	$30,$C5		;;(+00,+00)
	DEFB	$5C		;;Exponent: $6C, Bytes: 2
	DEFB	$90,$AA		;;(+00,+00)
	DEFB	$9E		;;Exponent: $6E, Bytes: 3
	DEFB	$70,$6F,$61	;;(+00)
	DEFB	$A1		;;Exponent: $71, Bytes: 3
	DEFB	$CB,$DA,$96	;;(+00)
	DEFB	$A4		;;Exponent: $74, Bytes: 3
	DEFB	$31,$9F,$B4	;;(+00)
	DEFB	$E7		;;Exponent: $77, Bytes: 4
	DEFB	$A0,$FE,$5C,$FC	;;
	DEFB	$EA		;;Exponent: $7A, Bytes: 4
	DEFB	$1B,$43,$CA,$36	;;
	DEFB	$ED		;;Exponent: $7D, Bytes: 4
	DEFB	$A7,$9C,$7E,$5E	;;
	DEFB	$F0		;;Exponent: $80, Bytes: 4
	DEFB	$6E,$23,$80,$93	;;
	DEFB	$04		;;multiply
	DEFB	$0F		;;addition
	DEFB	$38		;;end-calc
	RET			; return.

; -----------------------------
; THE 'TRIGONOMETRIC' FUNCTIONS
; -----------------------------
; Trigonometry is rocket science. It is also used by carpenters and pyramid
; builders.
; Some uses can be quite abstract but the principles can be seen in simple
; right-angled triangles. Triangles have some special properties -
;
; 1) The sum of the three angles is always PI radians (180 degrees).
;  Very helpful if you know two angles and wish to find the third.
; 2) In any right-angled triangle the sum of the squares of the two shorter
;  sides is equal to the square of the longest side opposite the right-angle.
;  Very useful if you know the length of two sides and wish to know the
;  length of the third side.
; 3) Functions sine, cosine and tangent enable one to calculate the length
;  of an unknown side when the length of one other side and an angle is
;  known.
; 4) Functions arcsin, arccosine and arctan enable one to calculate an unknown
;  angle when the length of two of the sides is known.

; --------------------------------
; THE 'REDUCE ARGUMENT' SUBROUTINE
; --------------------------------
; (offset $39: 'get-argt')
;
; This routine performs two functions on the angle, in radians, that forms
; the argument to the sine and cosine functions.
; First it ensures that the angle 'wraps round'. That if a ship turns through
; an angle of, say, 3*PI radians (540 degrees) then the net effect is to turn
; through an angle of PI radians (180 degrees).
; Secondly it converts the angle in radians to a fraction of a right angle,
; depending within which quadrant the angle lies, with the periodicity
; resembling that of the desired sine value.
; The result lies in the range -1 to +1.
;
;		   90 deg.
;
;		   (pi/2)
;	     II	     +1		I
;		      |
;	sin+	 |\   |   /|	sin+
;	cos-	 | \  |  / |	cos+
;	tan-	 |  \ | /  |	tan+
;		 |   \|/)  |
; 180 deg. (pi) 0	-|----+----|-- 0  (0) 0 degrees
;		 |   /|\   |
;	sin-	 |  / | \  |	sin-
;	cos-	 | /  |  \ |	cos+
;	tan+	 |/   |   \|	tan-
;		      |
;	     III	     -1		IV
;		   (3pi/2)
;
;		   270 deg.
;

	ORG	$3783
GET_ARGT:	RST	28H		;; FP_CALC	X.
	DEFB	$3D		;;re-stack	(not rquired done by mult)
	DEFB	$34		;;stk-data
	DEFB	$EE		;;Exponent: $7E,
				;;Bytes: 4
	DEFB	$22,$F9,$83,$6E	;;		X, 1/(2*PI)
	DEFB	$04		;;multiply	X/(2*PI) = fraction
	DEFB	$31		;;duplicate
	DEFB	$A2		;;stk-half
	DEFB	$0F		;;addition
	DEFB	$27		;;int
	DEFB	$03		;;subtract	now range -.5 to .5
	DEFB	$31		;;duplicate
	DEFB	$0F		;;addition	now range -1 to 1.
	DEFB	$31		;;duplicate
	DEFB	$0F		;;addition	now range -2 to +2.

; quadrant I (0 to +1) and quadrant IV (-1 to 0) are now correct.
; quadrant II ranges +1 to +2.
; quadrant III ranges -2 to -1.

	DEFB	$31		;;duplicate	Y, Y.
	DEFB	$2A		;;abs Y, abs(Y).	range 1 to 2
	DEFB	$A1		;;stk-one		Y, abs(Y), 1.
	DEFB	$03		;;subtract	Y, abs(Y)-1.  range 0 to 1
	DEFB	$31		;;duplicate	Y, Z, Z.
	DEFB	$37		;;greater-0	Y, Z, (1/0).
	DEFB	$C0		;;st-mem-0	store as possible sign
				;; for cosine function.
	DEFB	$00		;;jump-true
	DEFB	$04		;;to ZPLUS with quadrants II and III.

; else the angle lies in quadrant I or IV and value Y is already correct.

	DEFB	$02		;;delete		Y. delete the test value.
	DEFB	$38		;;end-calc	Y.
	RET			; return. with Q1 and Q4	>>>

; ---

; the branch was here with quadrants II (0 to 1) and III (1 to 0).
; Y will hold -2 to -1 if this is quadrant III.

	ORG	$37A1
ZPLUS:	DEFB	$A1		;;stk-one		Y, Z, 1.
	DEFB	$03		;;subtract	Y, Z-1. Q3 = 0 to -1
	DEFB	$01		;;exchange	Z-1, Y.
	DEFB	$36		;;less-0		Z-1, (1/0).
	DEFB	$00		;;jump-true	Z-1.
	DEFB	$02		;;to YNEG
				;;if angle in quadrant III

; else angle is within quadrant II (-1 to 0)

	DEFB	$1B		;;negate		range +1 to 0.

	ORG	$37A8
YNEG:	DEFB	$38		;;end-calc	quadrants II and III correct.
	RET			; return.

; ---------------------
; THE 'COSINE' FUNCTION
; ---------------------
; (offset $20: 'cos')
; Cosines are calculated as the sine of the opposite angle rectifying the
; sign depending on the quadrant rules.
;
;
;	    /|
;	 h /y|
;	  /  |o
;	 /x  |
;	/----|
;	  a
;
; The cosine of angle x is the adjacent side (a) divided by the hypotenuse 1.
; However if we examine angle y then a/h is the sine of that angle.
; Since angle x plus angle y equals a right-angle, we can find angle y by
; subtracting angle x from pi/2.
; However it's just as easy to reduce the argument first and subtract the
; reduced argument from the value 1 (a reduced right-angle).
; It's even easier to subtract 1 from the angle and rectify the sign.
; In fact, after reducing the argument, the absolute value of the argument
; is used and rectified using the test result stored in mem-0 by 'get-argt'
; for that purpose.
;

	ORG	$37AA
COS:	RST	28H		;; FP_CALC	angle in radians.
	DEFB	$39		;;get-argt	X reduce -1 to +1
	DEFB	$2A		;;abs		ABS X. 0 to 1
	DEFB	$A1		;;stk-one		ABS X, 1.
	DEFB	$03		;;subtract	now opposite angle
				;;		although sign is -ve.
	DEFB	$E0		;;get-mem-0	fetch the sign indicator
	DEFB	$00		;;jump-true
	DEFB	$06		;;fwd to C_ENT
				;;forward to common code if in QII or QIII.
	DEFB	$1B		;;negate		else make sign +ve.
	DEFB	$33		;;jump
	DEFB	$03		;;fwd to C_ENT
				;; with quadrants I and IV.

; -------------------
; THE 'SINE' FUNCTION
; -------------------
; (offset $1F: 'sin')
; This is a fundamental transcendental function from which others such as cos
; and tan are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.
;
;
;	    /|
;	 1 / |
;	  /  |x
;	 /a  |
;	/----|
;	  y
;
; The 'get-argt' function is designed to modify the angle and its sign
; in line with the desired sine value and afterwards it can launch straight
; into common code.

	ORG	$37B5
SIN:	RST	28H		;; FP_CALC	angle in radians
	DEFB	$39		;;get-argt	reduce - sign now correct.

	ORG	$37B7
C_ENT:	DEFB	$31		;;duplicate
	DEFB	$31		;;duplicate
	DEFB	$04		;;multiply
	DEFB	$31		;;duplicate
	DEFB	$0F		;;addition
	DEFB	$A1		;;stk-one
	DEFB	$03		;;subtract
	DEFB	$86		;;series-06
	DEFB	$14		;;Exponent: $64, Bytes: 1
	DEFB	$E6		;;(+00,+00,+00)
	DEFB	$5C		;;Exponent: $6C, Bytes: 2
	DEFB	$1F,$0B		;;(+00,+00)
	DEFB	$A3		;;Exponent: $73, Bytes: 3
	DEFB	$8F,$38,$EE	;;(+00)
	DEFB	$E9		;;Exponent: $79, Bytes: 4
	DEFB	$15,$63,$BB,$23	;;
	DEFB	$EE		;;Exponent: $7E, Bytes: 4
	DEFB	$92,$0D,$CD,$ED	;;
	DEFB	$F1		;;Exponent: $81, Bytes: 4
	DEFB	$23,$5D,$1B,$EA	;;
	DEFB	$04		;;multiply
	DEFB	$38		;;end-calc
	RET			; return.

; ----------------------
; THE 'TANGENT' FUNCTION
; ----------------------
; (offset $21: 'tan')
;
; Evaluates tangent x as  sin(x) / cos(x).
;
;
;	    /|
;	 h / |
;	  /  |o
;	 /x  |
;	/----|
;	  a
;
; the tangent of angle x is the ratio of the length of the opposite side
; divided by the length of the adjacent side. As the opposite length can
; be calculates using sin(x) and the adjacent length using cos(x) then
; the tangent can be defined in terms of the previous two functions.

; Error 6 if the argument, in radians, is too close to one like pi/2
; which has an infinite tangent. e.g. PRINT TAN (PI/2)  evaluates as 1/0.
; Similarly PRINT TAN (3*PI/2), TAN (5*PI/2) etc.

	ORG	$37DA
TAN:	RST	28H		;; FP_CALC	x.
	DEFB	$31		;;duplicate	x, x.
	DEFB	$1F		;;sin		x, sin x.
	DEFB	$01		;;exchange	sin x, x.
	DEFB	$20		;;cos 		sin x, cos x.
	DEFB	$05		;;division	sin x/cos x (= tan x).
	DEFB	$38		;;end-calc	tan x.
	RET			; return.

; ---------------------
; THE 'ARCTAN' FUNCTION
; ---------------------
; (Offset $24: 'atn')
; the inverse tangent function with the result in radians.
; This is a fundamental transcendental function from which others such as asn
; and acs are directly, or indirectly, derived.
; It uses the series generator to produce Chebyshev polynomials.

	ORG	$37E2
ATN:	CALL	RE_STACK		;
	LD	A,(HL)		; fetch exponent byte.
	CP	$81		; compare to that for 'one'
	JR	C,SMALL		; forward, if less
	RST	28H		;; FP_CALC
	DEFB	$A1		;;stk-one
	DEFB	$1B		;;negate
	DEFB	$01		;;exchange
	DEFB	$05		;;division
	DEFB	$31		;;duplicate
	DEFB	$36		;;less-0
	DEFB	$A3		;;stk-pi/2
	DEFB	$01		;;exchange
	DEFB	$00		;;jump-true
	DEFB	$06		;;to CASES
	DEFB	$1B		;;negate
	DEFB	$33		;;jump
	DEFB	$03		;;to CASES

	ORG	$37F8
SMALL:	RST	28H		;; FP_CALC
	DEFB	$A0		;;stk-zero

	ORG	$37FA
CASES:	DEFB	$01		;;exchange
	DEFB	$31		;;duplicate
	DEFB	$31		;;duplicate
	DEFB	$04		;;multiply
	DEFB	$31		;;duplicate
	DEFB	$0F		;;addition
	DEFB	$A1		;;stk-one
	DEFB	$03		;;subtract
	DEFB	$8C		;;series-0C
	DEFB	$10		;;Exponent: $60, Bytes: 1
	DEFB	$B2		;;(+00,+00,+00)
	DEFB	$13		;;Exponent: $63, Bytes: 1
	DEFB	$0E		;;(+00,+00,+00)
	DEFB	$55		;;Exponent: $65, Bytes: 2
	DEFB	$E4,$8D		;;(+00,+00)
	DEFB	$58		;;Exponent: $68, Bytes: 2
	DEFB	$39,$BC		;;(+00,+00)
	DEFB	$5B		;;Exponent: $6B, Bytes: 2
	DEFB	$98,$FD		;;(+00,+00)
	DEFB	$9E		;;Exponent: $6E, Bytes: 3
	DEFB	$00,$36,$75	;;(+00)
	DEFB	$A0		;;Exponent: $70, Bytes: 3
	DEFB	$DB,$E8,$B4	;;(+00)
	DEFB	$63 		;;Exponent: $73, Bytes: 2
	DEFB	$42,$C4		;;(+00,+00)
	DEFB	$E6		;;Exponent: $76, Bytes: 4
	DEFB	$B5,$09,$36,$BE	;;
	DEFB	$E9		;;Exponent: $79, Bytes: 4
	DEFB	$36,$73,$1B,$5D	;;
	DEFB	$EC		;;Exponent: $7C, Bytes: 4
	DEFB	$D8,$DE,$63,$BE	;;
	DEFB	$F0		;;Exponent: $80, Bytes: 4
	DEFB	$61,$A1,$B3,$0C	;;
	DEFB	$04		;;multiply
	DEFB	$0F		;;addition
	DEFB	$38		;;end-calc
	RET			; return.


; ---------------------
; THE 'ARCSIN' FUNCTION
; ---------------------
; (Offset $22: 'asn')
; The inverse sine function with result in radians.
; Derived from arctan function above.
; Error A unless the argument is between -1 and +1 inclusive.
; Uses an adaptation of the formula asn(x) = atn(x/sqr(1-x*x))
;
;
;	    /|
;	   / |
;	 1/  |x
;	 /a  |
;	/----|
;	  y
;
; e.g. We know the opposite side (x) and hypotenuse (1)
; and we wish to find angle a in radians.
; We can derive length y by Pythagoras and then use ATN instead.
; Since y*y + x*x = 1*1 (Pythagoras Theorem) then
; y=sqr(1-x*x) - no need to multiply 1 by itself.
; So, asn(a) = atn(x/y)
; or more fully,
; asn(a) = atn(x/sqr(1-x*x))

; Close but no cigar.

; While PRINT ATN (x/SQR (1-x*x)) gives the same results as PRINT ASN x,
; it leads to division by zero when x is 1 or -1.
; To overcome this, 1 is added to y giving half the required angle and the
; result is then doubled.
; That is, PRINT ATN (x/(SQR (1-x*x) +1)) *2
;
;
;	           . /|
;	        .  c/ |
;	     .     /1 |x
;	  . c   b /a  |
;	---------/----|
;	  1      y
;
; By creating an isosceles triangle with two equal sides of 1, angles c and
; c are also equal. If b+c+c = 180 degrees and b+a = 180 degrees then c=a/2.
;
; A value higher than 1 gives the required error as attempting to find  the
; square root of a negative number generates an error in Sinclair BASIC.

	ORG	$3833
ASN:	RST	28H		;; FP_CALC	x.
	DEFB	$31		;;duplicate	x, x.
	DEFB	$31		;;duplicate	x, x, x.
	DEFB	$04		;;multiply	x, x*x.
	DEFB	$A1		;;stk-one		x, x*x, 1.
	DEFB	$03		;;subtract	x, x*x-1.
	DEFB	$1B		;;negate		x, 1-x*x.
	DEFB	$28		;;sqr		x, sqr(1-x*x) = y
	DEFB	$A1		;;stk-one		x, y, 1.
	DEFB	$0F		;;addition	x, y+1.
	DEFB	$05		;;division	x/y+1.
	DEFB	$24		;;atn		a/2 (half the angle)
	DEFB	$31		;;duplicate	a/2, a/2.
	DEFB	$0F		;;addition	a.
	DEFB	$38		;;end-calc	a.
	RET			; return.

; ---------------------
; THE 'ARCCOS' FUNCTION
; ---------------------
; (Offset $23: 'acs')
; the inverse cosine function with the result in radians.
; Error A unless the argument is between -1 and +1.
; Result in range 0 to pi.
; Derived from asn above which is in turn derived from the preceding atn.
; It could have been derived directly from atn using acs(x) = atn(sqr(1-x*x)/x).
; However, as sine and cosine are horizontal translations of each other,
; uses acs(x) = pi/2 - asn(x)

; e.g. the arccosine of a known x value will give the required angle b in
; radians.
; We know, from above, how to calculate the angle a using asn(x).
; Since the three angles of any triangle add up to 180 degrees, or pi radians,
; and the largest angle in this case is a right-angle (pi/2 radians), then
; we can calculate angle b as pi/2 (both angles) minus asn(x) (angle a).
;
;
;	    /|
;	 1 /b|
;	  /  |x
;	 /a  |
;	/----|
;	  y
;

	ORG	$3843
ACS:	RST	28H		;; FP_CALC	x.
	DEFB	$22		;;asn asn(x).
	DEFB	$A3		;;stk-pi/2	asn(x), pi/2.
	DEFB	$03		;;subtract	asn(x) - pi/2.
	DEFB	$1B		;;negate		pi/2 -asn(x)  =  acs(x).
	DEFB	$38		;;end-calc	acs(x).
	RET			; return.

; --------------------------
; THE 'SQUARE ROOT' FUNCTION
; --------------------------
; (Offset $28: 'sqr')
; The sqr function has been re-written to use the Newton-Raphson method.
; Although the method is centuries old, this one, appropriately, is based
; on a FORTH word written by Steven Vickers in the Jupiter Ace manual.
; Whereas that algorithm always used an initial guess of one, this one
; manipulates the exponent byte to obtain a better guess.
; First test for zero and return zero, if so, as the result.
; If the argument is negative, then produce an error.

SQR:	RST	28H		;; FP_CALC	x
	DEFB	$3D		;;re-stack	x.   (in f.p. form)
	DEFB	$C3		;;st-mem-3	x.   (seed for guess)
	DEFB	$38		;;end-calc

;    The HL register now addresses the exponent byte

	LD	A,(HL)		; fetch exponent to A
	AND	A		; test for zero.
	RET	Z		; return if so - with zero on calculator stack.
	INC	HL 		; address the byte with the sign bit.
	BIT	7,(HL)		; test the sign bit
	JP	NZ,REPORT_Ab	; REPORT_A: 'Bad argument'

; This guess is based on a Usenet discussion.
; Halve the exponent to achieve a good guess.(accurate with .25 16 64 etc.)

	LD	HL,$5BA1		; Address system variable mem-3
	LD	A,(HL)		; fetch exponent of mem-3
	XOR	$80		; toggle sign of exponent of mem-3
	SRA	A		; shift right, bit 7 unchanged.
	INC	A		;
	JR	Z,ASIS		; forward with say .25 -> .5
	JP	P,ASIS		; leave increment if value > .5
	DEC	A		; restore to shift only.

ASIS:	XOR	$80		; restore sign.
	LD	(HL),A		; and put back 'halved' exponent.

; Now re-enter the calculator.

	RST	28H		;; FP_CALC	x
SLOOP:	DEFB	$31		;;duplicate	x,x.
	DEFB	$E3		;;get-mem-3	x,x,guess
	DEFB	$C4		;;st-mem-4 	x,x,guess
	DEFB	$05		;;div		x,x/guess.
	DEFB	$E3		;;get-mem-3	x,x/guess,guess
	DEFB	$0F		;;addition	x,x/guess+guess
	DEFB	$A2		;;stk-half	x,x/guess+guess,.5
	DEFB	$04		;;multiply	x,(x/guess+guess)*.5
	DEFB	$C3		;;st-mem-3	x,newguess
	DEFB	$E4		;;get-mem-4	x,newguess,oldguess
	DEFB	$03		;;subtract	x,newguess-oldguess
	DEFB	$2A		;;abs		x,difference.
	DEFB	$37		;;greater-0	x,(0/1).
	DEFB	$00		;;jump-true	x.
	DEFB	SLOOP - $	;;to sloop	x.
	DEFB	$02		;;delete		.
	DEFB	$E3		;;get-mem-3	retrieve final guess.
	DEFB	$38		;;end-calc	sqr x.
	RET			; return with square root on stack

; ------------------------------
; THE 'EXPONENTIATION' OPERATION
; ------------------------------
; (Offset $06: 'to-power')
; This raises the first number X to the power of the second number Y.
; As with the ZX80,
; 0 ^ 0 = 1.
; 0 ^ +n = 0.
; 0 ^ -n = arithmetic overflow.
;

TO_POWER:	RST	28H		;; FP_CALC	X, Y.
	DEFB	$01		;;exchange	Y, X.
	DEFB	$31		;;duplicate	Y, X, X.
	DEFB	$30		;;not		Y, X, (1/0).
	DEFB	$00		;;jump-true
	DEFB	$07		;;to XISO		if X is zero.

; else X is non-zero. Function 'ln' will catch a negative value of X.

	DEFB	$25		;;ln		Y, LN X.
	DEFB	$04		;;multiply	Y * LN X.
	DEFB	$38		;;end-calc
	JP	EXP		; jump back ->

; ---

; these routines form the three simple results when the number is zero.
; begin by deleting the known zero to leave Y the power factor.

XISO:	DEFB	$02		;;delete		Y.
	DEFB	$31		;;duplicate	Y, Y.
	DEFB	$30		;;not 		Y, (1/0).
	DEFB	$00		;;jump-true
	DEFB	$09		;;to ONE		if Y is zero.
	DEFB	$A0		;;stk-zero	Y, 0.
	DEFB	$01		;;exchange	0, Y.
	DEFB	$37		;;greater-0	0, (1/0).
	DEFB	$00		;;jump-true 0.
	DEFB	$06 		;;to LAST		if Y was any positive number.

; else force division by zero thereby raising an Arithmetic overflow error.
; There are some one and two-byte alternatives but perhaps the most formal
; might have been to use end-calc; rst 08; defb 05.

	DEFB	$A1		;;stk-one 	0, 1.
	DEFB	$01		;;exchange	1, 0.
	DEFB	$05 		;;division	1/0  ouch!

; ---

ONE:	DEFB	$02		;;delete		.
	DEFB	$A1		;;stk-one		1.

LAST:	DEFB	$38		;;end-calc	last value is 1 or 0.
	RET			; return.		Whew!

;*****************************************
;** Part 11. BUG-FIXES AND ENHANCEMENTS **
;*****************************************

; -----
; NEWED
; -----
; The new editor sets flags that allow the old editor to be called to enter
; lower-case text.

TAG8:
NEWED:
	SET	7,(IY+$00)	; set bit 7 of ERR_NR.
	CALL	EDITOR		; Original EDITOR prepares line

; Otherwise continue into the tokenizer that converts text to tokens.

; ---------------
; THE 'TOKENIZER'
; ---------------
; Note the tokenizer should not tokenize anything after rem
; Also no keywords within quotes although this is normally permissible.
; keywords in any order e.g. 'AT', 'ATTR', 'ATN'
; print pi is taken as the constant and not a variable pi
; REM is treated separately first.
; Then COPY down to RND.
; REM is done again but its easier to just process than avoid.
; Spaces in goto, gosub and deffn are optional.

	LD	DE,$01AA		; Start of 'REM' in ROM token table.
	XOR	A		; A zero detects first pass for 'REM'

NEWTOK:	PUSH	DE		; The same token may be repeated many times.
	POP	IX		; Save token table position in IX
	LD	HL,(E_LINE)	; Get edit line start from E_LINE.

CHAR0:	PUSH	AF		; Preserve the token number on the stack.
	LD	BC,$00		; Flag that previous character is non-alpha

CHAR1:	PUSH	IX		; Transfer the start of current token
	POP	DE		; to the DE register.

L3:	LD	A,(HL)		; Get edit line character.
	CP	$0D		; Carriage return?
	JR	Z,EOL		; End of edit line - next token
	CP	$EA		; Is token REM ?
	JR	Z,EOL		; Treat same as end of line - no more tokens.
	CP	$22		; Is this quote character
	JR	NZ,NOQ		; Skip if not to no quotes
	INC	C		; Increment quotes flag toggling bit 0.

NOQ:	BIT	0,C		; Within quotes?
	JR	NZ,SKIP		; Forward if so to repeat loop
	CALL	UCASE		; Make uppercase sets carry if alpha
	JR	NC,NOT_AZ	; Forward if not A-Z

; If this is alpha then previous must not be to avoid 'INT' in 'PRINT' etc.

	BIT	7,B		; Is previous alpha?
	JR	NZ,SKIP		; Forward if previous is alpha to ignore

NOT_AZ:	EX	DE,HL		; Switch in first character of token
	CP	(HL)		; Is there a match
	EX	DE,HL		; Switch out.
	JR	Z,MATCH1		; Forward if first character matches.

SKIP:	INC	HL		; Address next character in edit line
	JR	L3		; Back - check next character against 1st char.

; ---

; The first characters match.

MATCH1:	LD	(MEM_5 + 1),HL	; Store position within

INTRA:	INC	HL		; Increment edit line pointer.
	LD	A,(HL)		; Next BASIC character.
	CALL	UCASE		; Make uppercase.
	EX	AF,AF'		; Create an entry point.

INTRA2:	EX	AF,AF'		; Start of loop for internal characters
	INC	DE		; Point to next character in token
	EX	DE,HL		;
	CP	(HL)		; compare with token - intra?
	EX	DE,HL		;
	JR	Z,INTRA		; loop while token characters match

; If DE is a space then allow to be skipped now e.g. 'goto' and 'GO TO'

	EX	AF,AF'		; Save the edit line character.
	LD	A,(DE)		; Fetch the token character to A.
	CP	$20		; Is it a space?
	JR	Z,INTRA2		; Consider next token character if so.

; First check for a '.' which indicates an abbreviated keyword.

	EX	AF,AF'		; Retrieve the edit line character.
	CP	$2E		; Is it an abbreviation i.e. '.' ?
	JR	Z,CHKSP		; substitute straight away

; The only possibility now is the terminating character of token.

	EX	DE,HL		; Switch in token
	OR	$80		; Set bit 7
	CP	(HL)		; Is character inverted?
	EX	DE,HL		; Switch out.

; If not go back and reset pointer (DE) to the start of the current token
; and continue until the end of this line.

	JR	NZ,CHAR1		; Back to start at CHAR1 again

; All the characters matched including the final inverted one.
; Examine the last character for a valid non-alpha as in 'val$a$'

	CP	$C0		; Is it <> or STR$ or OPEN # etc.
	JR	C,SUBST		; Good enough - skip the alpha test

; A full match - but check the next character and reclaim if space.
; Note. do not remove! This prevents hidden spaces in listing!
; Also don't substitute if next is alpha. e.g. 'AT' in 'ATN'.
; Also FOR in FORMAT.  Also no substitution if next is '$'
; e.g. VAL in VAL$

CHKSP:	INC	HL		; Advance to next character in edit line.
	LD	A,(HL)		; Get following character in A.
	CP	$20		; Is it a space ?
	JR	Z,SUBST		; Forward, if so, replacing letters AND space.
	DEC	HL		; points to last character of token.
	CP	$24		; is it '$' ? e.g. VAL within VAL$
	JR	Z,CHAR1		; abandon as could be token within token.
	CALL	ALPHA		;
	JR	C,CHAR1		; Start again if next char is alpha
				; e.g. 'AT' in 'ATN'

; A full match - accumulator on stack gives token.
; For convenience we will not reclaim the last character as the new token
; which is a single character can go there.

SUBST:	LD	DE,(MEM_5 + 1)	; First character of token in edit line

BAKT:	DEC	DE		; Harvest any leading spaces
	LD	A,(DE)		;
	CP	$20		;
	JR	Z,BAKT		;
	INC	DE		; Back to first character of keyword.
	CALL	RECLAIM_1		;

; HL points to empty cell, token (AF) is on stack.

	POP	AF		; Retrieve token
	PUSH	IX		; Transfer address within token table
	POP	DE		; to the DE register.

;;	JR	L3901		; skip IM2 vector
;;	ORG	$38FF
;;L38FF:	DEFW	$FFFF		; IM2 vector used by some games.

L3901:	PUSH	AF		; save the parsed token.
	ADD	A,$06		; increment it 6 places to the real token.
	LD	(HL),A		; Insert the token and test it.
	POP	AF		; restore the parsed token.
	AND	A		; Will be zero if on first pass for REM
	JP	NZ,CHAR0		; Else look for more of the same token

; There can only be one token REM in a line.

	LD	(HL),$EA		; Substitute the REM token. No more tokenization
	PUSH	AF		; After the 'REM' token don't loop back.

; ---

; End of BASIC line - do next token down in table.

EOL:	LD	DE,$0220		; set to  START of ON ERR in case first REM pass.
	POP	AF		; Restore token.
	SUB	1		; Decrement but set carry if originally zero.
	JR	C,NXTTOK		; Will point to new token cluster so go.
	CP	$A4-6		; RND -1 -6 (new tokens)
	RET	Z		; Finished if so			>>>

; Have to work down to find the start of the previous token.

	PUSH	IX		;
	POP	HL		;

NXTT:	DEC	HL		; Known inverted end of previous

LLOOP:	DEC	HL		;
	BIT	7,(HL)		; inverted?
	JR	Z,LLOOP		;
	INC	HL		; point to first char.
	EX	DE,HL		; token position to DE

NXTTOK:	JP	NEWTOK		; back to process next token

; -----------------------------------------------------
; UCASE - an isolated subroutine used by the tokenizer.
; -----------------------------------------------------
;  (12 bytes)

UCASE:	CALL	ALPHA		; ROM routine ALPHA.
	LD	B,C		; prev to B
	LD	C,$00		; set flag to non-alpha initially
	RET	NC		; return with >= etc.
	RES	5,A		; make uppercase alpha.
	SET	7,C		; invert flag if alpha
	RET			; Return.

; ----------------------------------------------------

; -----------------------------------------------------------------------

; --------------------------
; THE 'BLOCK DELETE' ROUTINE
; --------------------------
; e.g.  DELETE 10,20
; The DELETE requires two parameters which must be actual BASIC line numbers
; Otherwise, the command aborts. (31 bytes)
;

B_DELETE:
	CALL	GET_LINE		; get second line number
	CALL	NEXT_ONE		; routine NEXT_ONE get address of next in DE
	PUSH	DE		;
	CALL	GET_LINE		; get first line number
	POP	DE		; last address in DE
	AND	A		;
	SBC	HL,DE		; set carry if second line was higher
	JR	NC,REPORT_Az	; second number must be higher than first
	ADD	HL,DE		; reform addresses
	EX	DE,HL		; put addresses in correct place for RECLAIM_1.
	JP	RECLAIM_1	; Exit via RECLAIM_1.

GET_LINE:
	CALL	FIND_LINE	; routine FIND-LINE puts line in BC
	LD	H,B		; transfer line
	LD	L,C		; number to HL.
	CALL	LINE_ADDR	; (LINE_ADDR) HL = line to be deleted
	RET	Z		; return with exact match

REPORT_Az:    
	RST	08H		; ERROR-1
	DEFB	$09		; Error Report: Invalid argument

; ------------------
; THE 'EDIT' COMMAND
; ------------------
; (28 bytes?)

EDIT:
	CALL	FIND_LINE	; routine FIND-LINE to fetch a
				; valid line number into BC.
	LD	(E_PPC),BC	; update E_PPC to new line number.
	CALL	SET_MIN		; routine SET-MIN clears workspace etc.
	CALL	CLS_LOWER	; routine CLS-LOWER clears the lower screen
				; and sets DF_SZ to two and TV_FLAG to $01.
	RES	5,(IY+$37)	; set input mode.
	CALL	ED_EDIT		;
	LD	SP,(ERR_SP)	; ERR_SP points to an error handler on the
				; machine stack.
	POP	AF		;
	JP	MAIN_2		;


;;	JR	CR_TST		; now avoid a well-used IM 2 vector
;;	ORG	$39FF
;;L39FF:	DEFW	$FFFF		; IM2 vector  39FF

; ---------------------------
; THE 'ROLLER COASTER' SPRITE
; ---------------------------
; Used as a sprite by the game Roller Coaster.

;;;	ORG	$3A9C
;;;RC_S:	DEFS	8

; ----------------------
; THE 'RENUMBER' ROUTINE
; ----------------------
;

; mem-0 = start def 100
; mem-1 = end def 16383
; mem-2 = step def 10
; mem-3 = dest def 0 same

NZUNWND:
RBAK2:	JP	REM

RENUM:	LD	A,D		; 5 invalid
	CP	$04		;
	JR	Z,PAR4		; all supplied - higher is error
	JR	NC,NZUNWND	; unwind the stack if > 4
	CP	$02		;
	JR	Z,PAR2		; 2 parameters
	JR	NC,PAR3		; 3 paramaters
	AND	A		;
	JR	NZ,PAR1		; 1 parameter

PAR0:	RST	28H		; CALC
	DEFB	$A4		;;stk-ten
	DEFB	$31		;;duplicate
	DEFB	$04		;;multiply	default dest 100
	DEFB	$38		;;end-calc

PAR1:	RST	28H		; CALC
	DEFB	$A4		;;stk-ten	default step 10
	DEFB	$38		;;end-calc

PAR2:	RST	28H		; CALC
	DEFB	$A1		;;stk-1		first line 1 (not 0)
	DEFB	$38		;;end-calc

PAR3:	LD	BC,16383		; default_high
	CALL	STACK_BC		; places on calculator stack.

PAR4:	RST	28H		; CALC
	DEFB	$C4		;;st-mem-4	last
	DEFB	$C3		;;st-mem-3	last
	DEFB	$02		;;delete
	DEFB	$C2		;;st-mem-2	first def 1
	DEFB	$02		;;delete
	DEFB	$31		;;duplicate	step
	DEFB	$37		;;greater-0
	DEFB	$00		;;jump-true
	DEFB	PAROK - $ 	;;
	DEFB	$38		;;end-calc

RBAK3:	JR	RBAK2

PAROK:	DEFB	$C1		;;st-mem-1	step
	DEFB	$02		;;delete
	DEFB	$C0		;;st-mem-0	newstart
	DEFB	$02		;;delete
	DEFB	$38		;;end-calc - stack is flat

NEWSTRT	equ	MEM_0 + 2
NEWEND	equ	MEM_0 + 4
STEP	equ	MEM_1 + 2
FIRST_LN	equ	MEM_2 + 2
LAST_LN	equ	MEM_3 + 2
LASTX	equ	MEM_4 + 2

; -------------------------------------------------
; Renumber -
; -------------------------------------------------
; Can run in dummy mode returning new line number for specific line
; First test if the renumber would create lines greater than 16383

	CALL	DO_DUMMY
	LD	HL,(NEWEND)
	LD	DE,$4000		; 16384
	AND	A
	SBC	HL,DE
	JR	NC,RBAK3		; to RBAK2

; --------------------------------
; see if renumber clashes
; --------------------------------
; first see if renumbered section is in virgin territory.

	ADD	HL,DE		; reform line number NEWEND
	CALL	LINE_ADDR	;
	JR	Z,IN_SITU	; forward with exact match
	PUSH	HL		;
	LD	HL,(NEWSTRT)	;
	CALL	LINE_ADDR	; gets following line
	POP	DE		;
	JR	Z,IN_SITU	; forward with exact match
	AND	A		;
	SBC	HL,DE		;
	JR	NC,RENU3		; following line is the same so OK.

; The renumbered section encloses existing lines.

IN_SITU:	LD	HL,(LAST_LN)	; last BASIC line number
	INC	HL
	CALL	LINE_ADDR	; address of following line in HL
	LD	D,(HL)		; extract line number (or end-marker)
	INC	HL
	LD	E,(HL)		;
	LD	HL,(NEWEND)	; NEWEND must be less.
	AND	A
	SBC	HL,DE		; subtract following line from new end
	JR	NC,RBAK3		; abort if higher.
;;	JR	VCTA		;
;;	NOP

;;; IM2 vector 3AFF

;;	ORG	$3AFF
;;L3AFF:	DEFW	$FFFF		; IM2 vector 3AFF

; since the new end line is OK  the address of line preceding the first line

VCTA:	LD	HL,(FIRST_LN)
	CALL	LINE_ADDR	; previous addr in DE
	PUSH	DE		; save address of prev
	LD	HL,(NEWSTRT)
	CALL	LINE_ADDR	; prev in DE
	EX	DE,HL
	POP	DE
	AND	A
	SBC	HL,DE
	JR	C,RBAK3
	JR	RENU3		; two bytes extra

; --------
; finally  do true renumber and bubblesort the basic lines.
; --------

; There is no need to balance the calculator stack.
; This is done by the customized REM routine.

RENU4:	RST	28H		; CALC
	DEFB	$E4		;;get-mem-4 last
	DEFB	$C3		;;st-mem-3 last
	DEFB	$38		;;end-calc

;	LD	HL,(LASTX)	; permanent last line
;	LD	(LAST_LN),HL	; working last line

	AND	A		; clear carry indicating update.
	CALL	DO_RENUM		; Renumber the BASIC lines.

SORT_LP:	SCF			; Set a flag
	EX	AF,AF'		; Preserve it.
	CALL	BUBBLE		; Call the bubblesort pass.
	EX	AF,AF'		; Retrieve flag.
	JR	NC,SORT_LP	; Back if an exchange took place
	JR	RBAK3		; Back as BASIC program is now sorted
				; by line number.

; --------------------------------
; alter the gotos in the program
; --------------------------------
;

RENU3:	LD	HL,(PROG)	; start at PROG
	DEC	HL		; create an entry point.

LP0:	INC	HL		; increment BASIC address to lineno-hi.

LP1:	LD	A,(HL)		; Fetch high-order byte.
	AND	$C0		; Test for end-marker.
	JR	NZ,RENU4		; Finish with the actual renumber.  >>>>>>>>>>>
	PUSH	HL		; Transfer start of BASIC line to IX register
	POP	IX		; This makes the length bytes easily accessible
	INC	HL		; lineno-lo
	INC	HL		; length-lo
	INC	HL		; length-hi

LKPRG:	INC	HL		; Address a byte within the BASIC.

LKP1:	LD	A,(HL)		; Fetch the character or token.
	CP	$22		; quotes
	JR	NZ,NOQUO		;

Q2:	INC	HL
	LD	A,(HL)
	CP	$22		; Matching quote ?
	JR	NZ,Q2

NOQUO:	CP	$EA		; REM ?	(with possible machine code) abort
	JR	NZ,NOREM		; Continue otherwise.

; The token 'REM' has been encountered. It may have chr$ 13 machine codes.

NEWLINE:	PUSH	IX		; Transfer the start of line
	POP	HL		; to the HL register.
	CALL	NEXT_ONE		; ROM routine finds next line in DE.
	EX	DE,HL		; transfer to HL.
	JR	LP1		; back to consider the entire line.

NOREM:	CALL	NUMBER		; steps over 14 and embedded numbers.
	CP	$0D		; end of line?
	JR	Z,LP0		; back to start at next line if so.
	LD	(CH_ADD),HL	; update the system variable.

; Now check for specific tokens 'GO TO', 'GO SUB', 'RESTORE' etc.

	LD	HL,TOKTAB		; table of 7 tokens

TOKL1:	CP	(HL)		; compare with accumulator.
	JR	Z,CHKDIG		; forward to check digits with a match
	INC	L		; address next token.
	JR	NZ,TOKL1		; back for all seven tokens.
	RST	18H		; set HL from CH_ADD skipping white space
	JR	LKPRG		; back to next char.

; ---

CHKDIG:	RST	20H		; char after token - could be 13
	CALL	NUMERIC		; NUMERIC 1st digit
	JR	C,LKP1		; to LKP1 with e.g. 'GOTO a' or just 'RUN'
	LD	(K_CUR),HL	; store position of 1st digit in K_CUR

NXTDIG:

;	LD	A,(HL)		; fetch possible digit
;	CALL	NUMERIC		; NUMERIC digit?

	CALL	NUMERIC0		;+ Above two instructions
	INC	HL		; then increment address
	JR	NC,NXTDIG	; back while true
;
; GO TO ; 1 ; 0 ; 0 ; 0 ; 14 ; 0 ; 0 ; 123 ; 2 ; 0 ; 13 ;
;

; only chr 14 allowed now

	CP	$0E		; NUMBER
	JR	NZ,LKP1		; back if not number marker 14
				; e.g. GOTO 111 within REM or variable a1

; HL addresses 0 int indicator - avoid if fp e.g. GO TO 3.1

	DEC	(HL)		;
	INC	(HL)		;
	JR	NZ,C_SANE	; forward if not a simple integer (carry is set)

;	INC	HL		; address sign
;	INC	HL		; address low
;	LD	C,(HL)		;
;	INC	HL		;
;	LD	B,(HL)		;

	CALL	GET_BC		; above code

SKPOVR:	INC	HL		; next character.
	LD	A,(HL)		; load into accumulator.
	CALL	PR_ST_END	; is it ':' or EOL
	JR	Z,DOIT		; only renumber if next char is a separator.
	CP	$21		; ignore space and below.
	JR	C,SKPOVR		; skip over any white space.

RELKP1:	JR	LKP1		; back if not e.g. GOTO 1000 * a

; This single statement can be renumbered.
; What happens is that the entire program is renumbered without update
; but stops when this statement is reached. The new number can be read
; from the location

DOIT

;	LD	H,B		;
;	LD	L,C		;
;	CALL	LINE_ADDR	;

	CALL	$0000		; Above code in new routine. (saves 2 bytes)

; HL now points to start of the line numbered BC.
; The program could be erroneous and have GOTO 40000

	LD	A,(HL)		;
	INC	HL		;
	LD	L,(HL)		; check for 999 here
	LD	H,A		;
	CP	$40		;
	JR	C,NOT16383	;
	LD	HL,$3FFF		; 16383
	LD	(NEWEND),HL	;
	JR	DTINS		;

NOT16383:
	LD	(LAST_LN),HL	; dummy last line stops renumber
	LD	HL,(LASTX)	; permanent last line
	SBC	HL,BC		; subtract destination

C_SANE:	JR	C,SANE		; forward if out of range
	LD	HL,(FIRST_LN)	;
	DEC	HL		;
	SBC	HL,BC		;
	JR	NC,SANE		;
	CALL	DO_DUMMY		; Dummy renumber of lines to extract NEWEND

;  now have new BC

DTINS

; Alter the output channel used by RST 10 (from OUT_NUM)

	LD	DE,ADD_CHAR	;
	CALL	PO_CHANGE	;

; At this point the digits are gone and it is convenient to check that
; memory is OK

	LD	DE,$85		; standard overhead plus 53 adjustment.
	LD	HL,(STKEND)	;
	ADD	HL,DE		; add to STKEND
	SBC	HL,SP		; subtract from Stack Pointer.
	PUSH	AF		; SAVE FLAG
	CALL	STRIP14		; Strip digits at K-CUR until chr$ 14 reached.

; Just in case we are out of memory, update the first byte of the integer
; line number to 14 decimal so that above routine can be used again to
; strip an additional three bytes.

	INC	HL		; Skip known 14 addressing zero indicator.
	INC	HL		; Address sign byte (zero)
	INC	HL		; address defunct integer low
	LD	(HL),A		; set it to 14.
	POP	AF		; GET MEMTEST FLAG
	LD	BC,(NEWEND)	; renumbered line
	JR	C,MEM_OK		; Forward if free memory is OK.
	CALL	STRIP14		; Strip 3 of remaining six bytes
	LD	(HL),$B0		; Insert the token 'VAL'
	INC	HL
	LD	(HL),$22		; Insert the first quote character.

;	INC	HL		; increment address (ed_bump?)
;	LD	(K_CUR),HL	; update K_CUR

	CALL	ED_BUMP		; Above code - saves 1 byte

	LD	(HL),$22		; Insert the second quote character.
	JR	DO_VAL		; forward to output digits between
				; quotes.  e.g. GO TO VAL "1000"

; Note. It would be extremely unlikely that the renumber would run out of
; memory.  Normally everything would be OK and the routine would use the
; next section which simply replaces the two bytes of the integer.

MEM_OK:	LD	(HL),C		;
	INC	HL		;
	LD	(HL),B		;

DO_VAL:	CALL	OUT_NUM_1	; will print BC at K-CUR

; Now, for every digit printed, increment the BASIC line length.

	LD	HL,(K_CUR)	; K_CUR (chr 14 or quote)
	DEC	HL		; known digit

ADJ2:	DEC	HL			;
	INC	(IX+2)		; increment length - lo
	JR	NZ,CHKB2		;
	INC	(IX+3)		; Increment length - hi


;	LD	A,(HL)		; fetch possible digit
;	CALL	NUMERIC		; NUMERIC digit?

CHKB2:	CALL	NUMERIC0		;+ Above two instructions
	JR	NC,ADJ2		; Finished when all digits considered.
; ---

SANE:	RST	18H		; CH_ADD (either first new digit or VAL)
	JR	RELKP1		; start at a sane position

; Note the above is a borderline relative jump

;;	ORG	$3BFF
;;L3BFF:	DEFW	$FFFF		; IM2 vector 3BFF

VCTB:

; -------
; STRIP14
; -------
; routine to strip characters until chr$14 encountered.

STRIP14:	LD	HL,(K_CUR)	; known first digit from K_CUR

ADJ1:	PUSH	BC		;
	LD	BC,$0001		; of character to be deleted.
	CALL	RECLAIM_2	; reclaim the character.
	POP	BC		;
	LD	A,(IX+$02)	;
	DEC	(IX+$02)		; adjust line length
	AND	A		;
	JR	NZ,CHK14		;
	DEC	(IX+$03)		; decrement the hi-order byte

CHK14:	LD	A,(HL)		;
	CP	$0E		;
	JR	NZ,ADJ1		;
	RET			;

; ===========================

BUBBLE:	LD	HL,(PROG)	; Fetch start of program

BUB1:	LD	A,(HL)		; Fetch first character.
	CP	$3F		; Compare to end-marker.
	RET	NC		; Return when reached.
	LD	B,(HL)		; line no to BC
	INC	HL		;
	LD	C,(HL)		;
	DEC	HL		; Back to start of line.
	PUSH	BC		; * Preserve line no
	CALL	NEXT_ONE		; nxt=DE, prv=HL, diff=BC
	EX	DE,HL		; Bring address of next line to HL
	PUSH	BC		; transfer the length
	POP	IX		; to the IX register
	POP	BC		; (*) Retrieve back the previous lineno
	CALL	CP_LINES		; ROM routine compares with that
				; addressed by HL.
	JR	NC,BUB1		; back if addressed line > BC

; The current line is lower than that in BC and they have to be rotated
; one byte at a time to avoid memory overheads.

	EX	AF,AF'		; First mark the alternate accumulator
	AND	A		; clearing carry
	EX	AF,AF'		; to show an exchange has taken place.
	INC	HL		; Address line number lo
	INC	HL		; length lo
	LD	A,(HL)		; A=lo
	INC	HL		; Address length hi
	LD	H,(HL)		; H=hi
	LD	L,A		; HL=length of second BASIC line.
	PUSH	IX		; transfer the length of first BASIC
	POP	BC		; line to BC.
	ADD	HL,BC		; Add to give length of both lines

; The stored lengths do not include line number bytes so adjust for them.

	INC	HL		;
	INC	HL		;
	INC	HL		; Length of two -1
	PUSH	BC		; Preserve length of first line
	LD	B,H		;
	LD	C,L		; Length to roll = total length -1

ROLL:	PUSH	DE		; Preserve DE which points to 1st line
	PUSH	BC		; Preserve the number of bytes to roll
	LD	A,(DE)		; Take the byte addressed by DE.
	LD	H,D		; Make HL (source) point
	LD	L,E		; to one byte higher
	INC	HL		; in memory.
	LDIR			; Copy downwards in memory
	LD	(DE),A		; Place the overwritten byte at end.
	POP	BC		; Retrieve bytes to roll.
	POP	DE		; Retrieve destination
	POP	HL		; Retrieve count of rolls.
	DEC	HL		; Decrement the roll count.
	LD	A,H		; Test for zero
	OR	L		;
	RET	Z		; Return when two lines swapped.
	PUSH	HL		; Preserve the decremented counter.
	JR	ROLL		; Let's roll.

; -------------------------------------------------
; Renumber
; -------------------------------------------------
; Can run in dummy mode returning new line number for specific line

DO_DUMMY:	SCF		; Setting carry prevents update of
				; line numbers.

DO_RENUM:EX	AF,AF'		; Preserve the controlling flag.
	LD	HL,(PROG)	; Fetch address of start of BASIC.
	LD	DE,(NEWSTRT)	; Fetch the new starting line to DE.

LN_LP:	LD	A,(HL)		; Fetch high-order byte of line number.
	CP	$40		; Compare with end-marker.
	RET	NC		; at end-marker - NEWEND updated
	LD	BC,(FIRST_LN)	; Fetch first line to be renumbered.
	CALL	CP_LINES		; Compare to addressed line.
	JR	C,ADVANCE	; Skip forward if yet to reach line.
	LD	BC,(LAST_LN)	; Fetch last line to be renumbered.
	CALL	CP_LINES		; Compare to addressed line.
	JR	Z,REN_LN		; Renumber line with exact match.
	JR	NC,ADVANCE	; Skip forward if endpoint passed.

; we have started renumber

REN_LN:	PUSH	HL		; Preserve address of line
	EX	AF,AF'		; Fetch controlling flag into play.
	JR	C,SKIPR		; Skip forward if only a dummy pass.
	LD	(HL),D		; Update the high-order byte.
	INC	HL		; Increment the address.
	LD	(HL),E		; Update the low-order byte.

SKIPR:	EX	AF,AF'		; Preserve the controlling flag.
	LD	(NEWEND),DE	; Place new line number in variable.
	LD	HL,(STEP)		; Fetch the step.
	ADD	HL,DE		; Add to line number in DE.
	EX	DE,HL		; Transfer back to DE.
	POP	HL		; Retrieve pointer to start of line.

;	INC	HL		; Address low-order byte of line number
;	INC	HL		; Address low-order byte of length.
;	LD	C,(HL)		; length-lo to C.
;	INC	HL		; Increment address.
;	LD	B,(HL)		; length-hi to B.

ADVANCE:
	CALL	GET_BC		; Above code.
	INC	HL		; Increment address.
	ADD	HL,BC		; Add length to address next line.
	JR	LN_LP		; Back to line loop.

; --------------------------------------
; Bugfixes that can't be fixed 'in situ'
; --------------------------------------
;
; ------------------
; THE 'ED_RIGHT' FIX
; ------------------
; Although ED_EDGE checks that the cursor cannot be placed between a colour
; control and its parameter when moving left, there are no such safegards
; when moving right.

ED_FIX1:	LD	A,(HL)		; fetch addressed character.
	CP	$0D		; Carriage Return?
	RET	Z		; Return if at end of line.
	CALL	ED_BUMP		; bump hl - move right and store in K_CUR.
	CP	$15		; OVER or above?
	RET	NC		; return with above 20 (INVERSE)
	CP	$10		; below INK
	RET	C		; return with fifteen or less.

; That leaves range INK - INVERSE and another parameter will follow.

	JP	ED_BUMP		; bump again for the colour parameter.

; -----------------------
; THE 'FIND LINE' ROUTINE
; -----------------------
; This new routine is used to find the integer argument of GO TO, RESTORE
; etc.  This routine generates an error if the argument is more than 16383.

FIND_LINE:
	CALL	FIND_INT2	;
	LD	A,B		; Fetch high-order byte of line number.
	CP	$40		; Compare
	JR	C_CHK		; check carry (below) and return if no error.

; -----------------------------------------
; THE NEW 'STACK TO LINE COLUMN' SUBROUTINE
; -----------------------------------------
; This new subroutine is used by S_ATTR and S_SCRNS essentially to call the
; routine below but, in addition, it produces a runtime error if the column
; is greater than 31 or the line is greater than 23.
; Both parameters must be positive as specified by the BASIC manual.

STK_TO_LC:
	CALL	BC_POSTVE	; Allow resolved positive values only.
	LD	A,B		; First consider the line.
	CP	$20		;
	JR	NC,REPORT_BB	;
	LD	A,C		; Now the columns position
	CP	$18		; Should be range 0 - 23

C_CHK:	RET	C		; Return if in range.

REPORT_BB:
	RST	08H		; Error restart
	DEFB	$0A		; 'Out of range'

; Note. the above subroutine was corrected in version 1.28

; --------------------------------
; THE NEW 'BC POSITIVE' SUBROUTINE
; --------------------------------
; The BASIC manual states that the rounded arguments for PLOT and POINT must
; be positive.  This routine ensures that negative expressions below
; -.49999... are rejected.

BC_POSTVE:
	CALL	STK_TO_BC	; The standard ROM call STK_TO_BC - allows negatives.
	LD	A,D		; Fetch sign $01 or $FF (negative).
	ADD	A,E		; add the other sign $01 or $FF

; Sets carry flag if either was negative.

	RET	NC		; Return if both positive

	RST	08H		; Error restart
	DEFB	$0A		; 'Out of range'

; ---------------
; THE 'CLOSE' FIX
; ---------------
; Routine checks if stream closed before using lookup. (9 bytes)
; Note. The accumulator must be saved not for this ROM but for Interface 1
; which may page itself in due to an instruction fetch on $1708.

CL_FIX:	LD	D,A		;+ Preserve A (stream) for Interface 1
	LD	A,B		;+ Is stream open ?
	OR	C		;+ Sets zero flag if closed.
	LD	A,D		;+ Bring back A in case Interface 1 traps
				;+ at $1708.
	JP	NZ,CLOSE_2	;+ continue, if offset non-zero, at CLOSE_2
				;+ (displaced code)

; Else stream is already closed.

;; REPORT-Oc
	RST	08H		;+ ERROR_1
	DEFB	$17		;+ Error Report: Bad stream

; ------------------------------------
; THE 'CLOSE STREAM LOOK-UP' TABLE
; ------------------------------------
; This table contains an entry for a letter found in the CHANS area.
; followed by an 8-bit displacement, from that byte's address in the
; table to the routine that performs any ancillary actions associated
; with closing the stream of that channel.
; The table doesn't normally require a zero end-marker as the letter has
; been picked up from a channel that has an open stream. However to prevent
; crashes with the Plus D the end-marker has been added

CL_STR_LU:	
	DEFB	'K',NEW_CS-$-1	;+ offset to NEW_CS
	DEFB	'S',NEW_CS-$-1	;+ offset to NEW_CS
	DEFB	'P',NEW_CS-$-1	;+ offset to NEW_CS
	DEFB	0		;+ end-marker

; ------------------------------
; THE 'CLOSE STREAM' SUBROUTINES
; ------------------------------
; The close stream routines in fact have no ancillary actions to perform
; which is not surprising with regard to 'K' and 'S'.
; This is just the same as the original but has to be in reach of the
; above table.

NEW_CS:	POP	HL		;+ * now just restore the stream data pointer
	RET			;+ in STRMS and return.

; ================================================================

;; 58 bytes
SYSTEM:	CALL	STK_TO_BC	; routine STK-TO-BC.
				; returns with first value in C and A and second in B.

; SET 2 - set attributes in 512x192 mode

	CP	$02		; arbitrary number
	JP	NZ,REPORT_B	; next function if not.
	LD	A,B		; get the ink colour
	CP	$08		; must be in range 0 (black) to 7 (white)
	JP	NC,REPORT_K	; Bad colour if not.
	RLCA			; rotate bits 0-2
	RLCA			; to
	RLCA			; bits 3-5.
	LD	B,A		; store the ink colour
	IN	A,($FF)		; read current setting of port #xxFF
	AND	$C7		; mask off attribute bits 3-5
	ADD	A,B		; alter attributes without affecting other bits
	OUT	($FF),A		; change the video mode
	RET			; return.

;; 6 bytes
CLEAR_1_2:
	CALL	REST_RUN		; execute a RESTORE.
	JP	CLS		; routine CLS to clear screen.

	DEFS	24

; ----------------
; The offset table
; ----------------
; The BASIC interpreter has found a command code $CE - $FF
; which is then reduced to range $00 - $31 and added to the base address
; of this table to give the address of an offset which, when added to
; the offset therein, gives the location in the following parameter table
; where a list of class codes, separators and addresses relevant to the
; command exists.

OFFST_TBL:
	DEFB	P_DEF_FN - $	; $offset
	DEFB	P_CAT - $	; $offset
	DEFB	P_FORMAT - $	; $offset
	DEFB	P_MOVE - $	; $offset
	DEFB	P_ERASE - $	; $offset
	DEFB	P_OPEN - $	; $offset
	DEFB	P_CLOSE - $	; $offset
	DEFB	P_MERGE - $	; $offset
	DEFB	P_VERIFY - $	; $offset
	DEFB	P_BEEP - $	; $offset
	DEFB	P_CIRCLE - $	; $offset
	DEFB	P_INK - $	; $offset
	DEFB	P_PAPER - $	; $offset
	DEFB	P_FLASH - $	; $offset
	DEFB	P_BRIGHT - $	; $offset
	DEFB	P_INVERSE - $	; $offset
	DEFB	P_OVER - $	; $offset
	DEFB	P_OUT - $	; $offset
	DEFB	P_LPRINT - $	; $offset
	DEFB	P_LLIST - $	; $offset
	DEFB	P_STOP - $	; $offset
	DEFB	P_READ - $	; $offset
	DEFB	P_DATA - $	; $offset
	DEFB	P_RESTORE - $	; $offset
	DEFB	P_NEW - $	; $offset
	DEFB	P_BORDER - $	; $offset
	DEFB	P_CONT - $	; $offset
	DEFB	P_DIM - $	; $offset
	DEFB	P_REM - $	; $offset
	DEFB	P_FOR - $	; $offset
	DEFB	P_GO_TO - $	; $offset
	DEFB	P_GO_SUB - $	; $offset
	DEFB	P_INPUT - $	; $offset
	DEFB	P_LOAD - $	; $offset
	DEFB	P_LIST - $	; $offset
	DEFB	P_LET - $	; $offset
	DEFB	P_PAUSE - $	; $offset
	DEFB	P_NEXT - $	; $offset
	DEFB	P_POKE - $	; $offset
	DEFB	P_PRINT - $	; $offset
	DEFB	P_PLOT - $	; $offset
	DEFB	P_RUN - $	; $offset
	DEFB	P_SAVE - $	; $offset
	DEFB	P_RANDOM - $	; $offset
	DEFB	P_IF - $		; $offset
	DEFB	P_CLS - $	; $offset
	DEFB	P_DRAW - $	; $offset
	DEFB	P_CLEAR - $	; $offset
	DEFB	P_RETURN - $	; $offset
	DEFB	P_COPY - $	; $offset
	DEFB	P_DELETE - $	; $offset to $00
	DEFB	P_EDIT - $	; $offset to $01
	DEFB	P_RENUM - $	; $offset to $02
	DEFB	P_SET - $	; $offset to $03
	DEFB	P_SOUND - $	; $offset to $04
	DEFB	P_REM - $	; $offset to $05

; -------------------------------
; The parameter or "Syntax" table
; -------------------------------
; For each command there exists a variable list of parameters.
; If the character is greater than a space it is a required separator.
; If less, then it is a command class in the range 00 - 0B.
; Note that classes 00, 03 and 05 will fetch the addresses from this table.
; Some classes e.g. 07 and 0B have the same address in all invocations
; and the command is re-computed from the low-byte of the parameter address.
; Some e.g. 02 are only called once so a call to the command is made from
; within the class routine rather than holding the address within the table.
; Some class routines check syntax entirely and some leave this task for the
; command itself.
; Others for example CIRCLE (x,y,z) check the first part (x,y) using the
; class routine and the final part (,z) within the command.
; The last few commands appear to have been added in a rush but their syntax
; is rather simple e.g. MOVE "M1","M2"

P_LET:	DEFB	$01		; Class-01 - A variable is required.
	DEFB	$3D		; Separator:  '='
	DEFB	$02		; Class-02 - An expression, numeric or string,
				; must follow.

P_GO_TO:	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	GO_TO		;

P_IF:	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$CB		; Separator:  'THEN'
	DEFB	$05		; Class-05 - Variable syntax checked by routine.
	DEFW	_IF		;

P_GO_SUB:DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	GO_SUB		;

P_STOP:	DEFB	$00		; Class-00 - No further operands.
	DEFW	REPORT_9		;

P_RETURN:DEFB	$00		; Class-00 - No further operands.
	DEFW	RETURN		;

P_FOR:	DEFB	$04		; Class-04 - A single character variable must
				; follow.
	DEFB	$3D		; Separator:  '='
	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$CC		; Separator:  'TO'
	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$05		; Class-05 - Variable syntax checked by routine.
	DEFW	FOR		;

P_NEXT:	DEFB	$04		; Class-04 - A single character variable must
				; follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	NEXT		;

P_PRINT:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	PRINT		;

P_INPUT:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	INPUT		;

P_DIM:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	DIM		;

P_REM:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	REM		;

P_NEW:	DEFB	$00		; Class-00 - No further operands.
	DEFW	NEW		;

P_RUN:	DEFB	$03		; Class-03 - A numeric expression may follow
				; else default to zero.
	DEFW	RUN		;

P_LIST:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	LIST		;

P_POKE:	DEFB	$08		; Class-08 - Two comma-separated numeric
				; expressions required.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	POKE		;

P_RANDOM:DEFB	$03		; Class-03 - A numeric expression may follow
				; else default to zero.
	DEFW	RANDOMIZE	;

P_CONT:	DEFB	$00		; Class-00 - No further operands.
	DEFW	CONT		;

P_CLEAR:	DEFB	$03		; Class-03 - A numeric expression may follow
				; else default to zero.
	DEFW	CLEAR		;

P_CLS:	DEFB	$00		; Class-00 - No further operands.
	DEFW	CLS		;

P_PLOT:	DEFB	$09		; Class-09 - Two comma-separated numeric
				; expressions required with optional colour
				; items.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	PLOT		;

P_PAUSE:	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	PAUSE		;

P_READ:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	READ		;

P_DATA:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	DATA		;

P_RESTORE:
	DEFB	$03		; Class-03 - A numeric expression may follow
				; else default to zero.
	DEFW	RESTORE		;

P_DRAW:	DEFB	$09		; Class-09 - Two comma-separated numeric
				; expressions required with optional colour
				; items.
	DEFB	$05		; Class-05 - Variable syntax checked by routine.
	DEFW	DRAW		;

P_COPY:	DEFB	$00		; Class-00 - No further operands.
	DEFW	COPY		;

P_LPRINT:DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	LPRINT		;

P_LLIST:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	LLIST		;

P_SAVE:	DEFB	$0B		; Class-0B - Offset address converted to tape
				; command.

P_LOAD:	DEFB	$0B		; Class-0B - Offset address converted to tape
				; command.

P_VERIFY:DEFB	$0B		; Class-0B - Offset address converted to tape
				; command.

P_MERGE:	DEFB	$0B		; Class-0B - Offset address converted to tape
				; command.

P_BEEP:	DEFB	$08		; Class-08 - Two comma-separated numeric
				; expressions required.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	BEEP

P_CIRCLE:DEFB	$09		; Class-09 - Two comma-separated numeric
				; expressions required with optional colour
				; items.
	DEFB	$05		; Class-05 - Variable syntax checked by routine.
	DEFW	CIRCLE		;

P_INK:	DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_PAPER:	DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_FLASH:	DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_BRIGHT:DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_INVERSE:
	DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_OVER:	DEFB	$07		; Class-07 - Offset address is converted to
				; colour code.

P_OUT:	DEFB	$08		; Class-08 - Two comma-separated numeric
				; expressions required.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	_OUT		;

P_BORDER:DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	BORDER		;

P_DEF_FN:DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	DEF_FN		;

P_OPEN:	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$2C		; Separator:  ','  see Footnote *
	DEFB	$0A		; Class-0A - A string expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	OPEN		;

P_CLOSE:	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	CLOSE		;

P_MOVE:	DEFB	$0A		; Class-0A - A string expression must follow.
	DEFB	$2C		; Separator:  ','
P_FORMAT:
P_ERASE:	DEFB	$0A		; Class-0A - A string expression must follow.
P_CAT:	DEFB	$00		; Class-00 - No further operands.
	DEFW	CAT_ETC		;

P_DELETE:
	DEFB	$08		; Class-08 - Two comma-separated numeric
				; expressions required.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	B_DELETE		;

P_EDIT:
	DEFB	$06		; Class-06 - A numeric expression must follow.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	EDIT		;

P_RENUM:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	RENUM		;

P_SET:	DEFB	$08		; Class-08 - Two comma-separated numeric
				; expressions required.
	DEFB	$00		; Class-00 - No further operands.
	DEFW	SYSTEM		;

P_SOUND:	DEFB	$05		; Class-05 - Variable syntax checked entirely
				; by routine.
	DEFW	SOUND		;

; * Note that a comma is required as a separator with the OPEN command
; but the Interface 1 programmers relaxed this allowing ';' as an
; alternative for their channels creating a confusing mixture of
; allowable syntax as it is this ROM which opens or re-opens the
; normal channels.

	DEFS	17

; -----------------
; THE 'TOKEN TABLE'
; -----------------
; A table of tokens that can be renumbered.

TOKTAB:	DEFB	$EC		; GO TO
	DEFB	$ED		; GO SUB
	DEFB	$E5		; RESTORE
	DEFB	$F7		; RUN
	DEFB	$F0		; LIST
	DEFB	$E1		; LLIST
	DEFB	$CA		; LINE
	DEFB	$00		; DELETE
	DEFB	$01		; EDIT
	DEFB	$02		; RENUM

	DEFB	$01,$03,$07,$0F,$1F,$3F,$7F,$FF	; triangle   031

; ----------------------------
; THE 'SINCLAIR CHARACTER SET'
; ----------------------------
; This is the 1983 version of the Sinclair character set.

	ORG	$3D00
CHAR_SET:DEFB	$00,$00,$00,$00,$00,$00,$00,$00	; space
	DEFB	$00,$10,$10,$10,$10,$00,$10,$00	; !
	DEFB	$00,$24,$24,$00,$00,$00,$00,$00	; "
	DEFB	$00,$24,$7E,$24,$24,$7E,$24,$00	; #
	DEFB	$00,$08,$3E,$28,$3E,$0A,$3E,$08	; $
	DEFB	$00,$62,$64,$08,$10,$26,$46,$00	; %
	DEFB	$00,$10,$28,$10,$2A,$44,$3A,$00	; &
	DEFB	$00,$08,$10,$00,$00,$00,$00,$00	; '
	DEFB	$00,$04,$08,$08,$08,$08,$04,$00	; (
	DEFB	$00,$20,$10,$10,$10,$10,$20,$00	; )
	DEFB	$00,$00,$14,$08,$3E,$08,$14,$00	; *
	DEFB	$00,$00,$08,$08,$3E,$08,$08,$00	; +
	DEFB	$00,$00,$00,$00,$00,$08,$08,$10	; ,
	DEFB	$00,$00,$00,$00,$3E,$00,$00,$00	; -
	DEFB	$00,$00,$00,$00,$00,$18,$18,$00	; .
	DEFB	$00,$00,$02,$04,$08,$10,$20,$00	; /
	DEFB	$00,$3C,$46,$4A,$52,$62,$3C,$00	; 0
	DEFB	$00,$18,$28,$08,$08,$08,$3E,$00	; 1
	DEFB	$00,$3C,$42,$02,$3C,$40,$7E,$00	; 2
	DEFB	$00,$3C,$42,$0C,$02,$42,$3C,$00	; 3
	DEFB	$00,$08,$18,$28,$48,$7E,$08,$00	; 4
	DEFB	$00,$7E,$40,$7C,$02,$42,$3C,$00	; 5
	DEFB	$00,$3C,$40,$7C,$42,$42,$3C,$00	; 6
	DEFB	$00,$7E,$02,$04,$08,$10,$10,$00	; 7
	DEFB	$00,$3C,$42,$3C,$42,$42,$3C,$00	; 8
	DEFB	$00,$3C,$42,$42,$3E,$02,$3C,$00	; 9
	DEFB	$00,$00,$00,$10,$00,$00,$10,$00	; :
	DEFB	$00,$00,$10,$00,$00,$10,$10,$20	; ;
	DEFB	$00,$00,$04,$08,$10,$08,$04,$00	; <
	DEFB	$00,$00,$00,$3E,$00,$3E,$00,$00	; =
	DEFB	$00,$00,$10,$08,$04,$08,$10,$00	; >
	DEFB	$00,$3C,$42,$04,$08,$00,$08,$00	; ?
	DEFB	$00,$3C,$4A,$56,$5E,$40,$3C,$00	; @
	DEFB	$00,$3C,$42,$42,$7E,$42,$42,$00	; A
	DEFB	$00,$7C,$42,$7C,$42,$42,$7C,$00	; B
	DEFB	$00,$3C,$42,$40,$40,$42,$3C,$00	; C
	DEFB	$00,$78,$44,$42,$42,$44,$78,$00	; D
	DEFB	$00,$7E,$40,$7C,$40,$40,$7E,$00	; E
	DEFB	$00,$7E,$40,$7C,$40,$40,$40,$00	; F
	DEFB	$00,$3C,$42,$40,$4E,$42,$3C,$00	; G
	DEFB	$00,$42,$42,$7E,$42,$42,$42,$00	; H
	DEFB	$00,$3E,$08,$08,$08,$08,$3E,$00	; I
	DEFB	$00,$02,$02,$02,$42,$42,$3C,$00	; J
	DEFB	$00,$44,$48,$70,$48,$44,$42,$00	; K
	DEFB	$00,$40,$40,$40,$40,$40,$7E,$00	; L
	DEFB	$00,$42,$66,$5A,$42,$42,$42,$00	; M
	DEFB	$00,$42,$62,$52,$4A,$46,$42,$00	; N
	DEFB	$00,$3C,$42,$42,$42,$42,$3C,$00	; O
	DEFB	$00,$7C,$42,$42,$7C,$40,$40,$00	; P
	DEFB	$00,$3C,$42,$42,$52,$4A,$3C,$00	; Q
	DEFB	$00,$7C,$42,$42,$7C,$44,$42,$00	; R
	DEFB	$00,$3C,$40,$3C,$02,$42,$3C,$00	; S
	DEFB	$00,$FE,$10,$10,$10,$10,$10,$00	; T
	DEFB	$00,$42,$42,$42,$42,$42,$3C,$00	; U
	DEFB	$00,$42,$42,$42,$42,$24,$18,$00	; V
	DEFB	$00,$42,$42,$42,$42,$5A,$24,$00	; W
	DEFB	$00,$42,$24,$18,$18,$24,$42,$00	; X
	DEFB	$00,$82,$44,$28,$10,$10,$10,$00	; Y
	DEFB	$00,$7E,$04,$08,$10,$20,$7E,$00	; Z
	DEFB	$00,$0E,$08,$08,$08,$08,$0E,$00	; [
	DEFB	$00,$00,$40,$20,$10,$08,$04,$00	; \
	DEFB	$00,$70,$10,$10,$10,$10,$70,$00	; ]
	DEFB	$00,$10,$38,$54,$10,$10,$10,$00	; ^
	DEFB	$00,$00,$00,$00,$00,$00,$00,$FF	; _
	DEFB	$00,$1C,$22,$78,$20,$20,$7E,$00	; ukp
	DEFB	$00,$00,$38,$04,$3C,$44,$3C,$00	; a
	DEFB	$00,$20,$20,$3C,$22,$22,$3C,$00	; b
	DEFB	$00,$00,$1C,$20,$20,$20,$1C,$00	; c
	DEFB	$00,$04,$04,$3C,$44,$44,$3C,$00	; d
	DEFB	$00,$00,$38,$44,$78,$40,$3C,$00	; e
	DEFB	$00,$0C,$10,$18,$10,$10,$10,$00	; f
	DEFB	$00,$00,$3C,$44,$44,$3C,$04,$38	; g
	DEFB	$00,$40,$40,$78,$44,$44,$44,$00	; h
	DEFB	$00,$10,$00,$30,$10,$10,$38,$00	; i
	DEFB	$00,$04,$00,$04,$04,$04,$24,$18	; j
	DEFB	$00,$20,$28,$30,$30,$28,$24,$00	; k
	DEFB	$00,$10,$10,$10,$10,$10,$0C,$00	; l
	DEFB	$00,$00,$6C,$92,$92,$92,$92,$00	; m
	DEFB	$00,$00,$78,$44,$44,$44,$44,$00	; n
	DEFB	$00,$00,$38,$44,$44,$44,$38,$00	; o
	DEFB	$00,$00,$78,$44,$44,$78,$40,$40	; p
	DEFB	$00,$00,$3C,$44,$44,$3C,$04,$06	; q
	DEFB	$00,$00,$1C,$20,$20,$20,$20,$00	; r
	DEFB	$00,$00,$38,$40,$38,$04,$78,$00	; s
	DEFB	$00,$10,$38,$10,$10,$10,$0C,$00	; t
	DEFB	$00,$00,$44,$44,$44,$44,$38,$00	; u
	DEFB	$00,$00,$44,$44,$28,$28,$10,$00	; v
	DEFB	$00,$00,$92,$92,$92,$92,$6C,$00	; w
	DEFB	$00,$00,$44,$28,$10,$28,$44,$00	; x
	DEFB	$00,$00,$44,$44,$44,$3C,$04,$38	; y
	DEFB	$00,$00,$7C,$08,$10,$20,$7C,$00	; z
	DEFB	$00,$0E,$08,$30,$08,$08,$0E,$00	; {
	DEFB	$00,$08,$08,$08,$08,$08,$08,$00	; |
	DEFB	$00,$70,$10,$0C,$10,$10,$70,$00	; }
	DEFB	$00,$14,$28,$00,$00,$00,$00,$00	; ~
	DEFB	$3C,$42,$99,$A1,$A1,$99,$42,$3C	; copyright

#end				; generic cross-assembler directive
