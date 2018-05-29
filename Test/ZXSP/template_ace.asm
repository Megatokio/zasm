#!/usr/local/bin/zasm -o original/
; ================================================================
;	Example source for target 'ace'
;	Emulator snapshot format for Jupiter ACE
;	Copyright  (c)	Günter Woigk 1994 - 2015
;					mailto:kio@little-bat.de
; ================================================================


;
; space is filled with 0x00
; #segments have no additional argument
; ram size should total to 3k, 19k or 35k.
;
; the .ace file stores ram as seen by the CPU, which means, it also stores page echoes:
;
;	$2000		copy of video ram
;	$2400		video ram
;	$2800		copy of character ram
;	$2C00		character ram
;	$3000		1st copy of built-in programme ram
;	$3400		2nd copy of built-in programme ram
;	$3800		3rd copy of built-in programme ram
;	$3C00		built-in programme ram
;	$4000++		expansion ram
;
; The page copies are blanked-out.
; The Z80 registers are saved in the VRAM echo page at $2000.


ramsize	equ	3 * 1024		; legal values: 3K, 3+16K, or 3+32K
ramtop	equ	$3400+ramsize	; Ramtop: $4000 (3K), $8000(19K), $C000(35K)


#target ace


; ______________________________________________________________
; ram at $2000
; 1k echo of video ram; fast access for CPU
; always saved as all-zero
; except for
; $2000-$2148: ACE32 settings and Z80 registers

#code VRAM_COPY, $2000, $400

; Flag:
	.long	$8001		; ?

; ACE32 settings:
	org		$2080
	.long		ramtop	; Ramtop
	.long		0		; Debugger Data Address
	.long		0		; Debugger Breakpoint Address
	.long		3		; Frame Skip Rate (3)
	.long		3		; Frames per TV Tick (3)
	.long		$FDFD	; ?
	.long		100		; Time emulator is running (probably in ms)
	.long		0		; Emulator Colour: white on Black
#assert $ == $20a0

; Z80 Registers:
	org		$2100
	db		1,2,0,0		; F, A
	.long	$10			; BC
	.long	$20			; DE
	.long	$30			; HL
	.long	$40			; IX
	.long	$50			; IY
	.long	ramtop		; SP
	.long	progstart	; PC
	db		3,4,0,0		; F', A'
	.long	$60			; BC'
	.long	$70			; DE'
	.long	$80			; HL'
	.long	1			; IM
	.long	1			; IFF1
	.long	1			; IFF1
	.long	5			; I
	.long	6			; R
	.long	$80			; ?
#assert $ == $2100 + 18*4

; ______________________________________________________________
; ram at $2400
; 1k video ram
; 24 rows * 32 chars + 256 bytes scratch

#code VRAM, $2400, $400

	dm		"Hello World! ;-)"


; ______________________________________________________________
; ram at $2800
; 1k echo of character ram, fast access for CPU
; always saved as all-zero

#code CRAM_COPY, $2800, $400


; ______________________________________________________________
; ram at $2C00
; 1k character ram

#code CRAM, $2C00, $400
#insert "jupiter_ace_character_ram.bin"


; ______________________________________________________________
; ram at $3000, $3400, and $3800
; 3 echoes of built-in 1k programme ram
; always saved as all-zero

#code RAM_COPIES, $3000, $C00


; ______________________________________________________________
; ram at $3C00
; $3C00 - $3FFF built-in programme ram
; $4000++       expansion ram

#code SYSVARS, 0x3C00, 0x40
FP_WS		ds	19		; $3C00 (15360)	19 bytes used as work space for floating point arithmetic.
LISTWS		ds	5		; $3C13 (15379)	5 bytes used as workspace by 'LIST' and 'EDIT'.
RAMTOP		dw	0		; $3C18 (15384)	the first address past the last address in RAM.
HLD			dw	0		; $3C1A (15386)	The address of the latest character held in the pad by formatted output.
SCRPOS		dw	0		; $3C1C (15388)	The address of the place in video RAM where the next character is to be printed
INSCRN		dw	0		; $3C1E (15390)	The address of the start of the current 'logical line' in the input buffer.
CURSOR		dw	0		; $3C20 (15392)	The address of the cursor in the input buffer.
ENDBUF		dw	0		; $3C22 (15394)	The address of the end of the current logical line in the input buffer.
L_HALF		dw	0		; $3C24 (15396)	The address of the start of the the input buffer.
KEYCOD		db	0		; $3C26 (15398)	The ASCII code of the last key pressed.
KEYCNT		db	0		; $3C27 (15399)	Used by the routine that reads the keyboard.
STATIN		db	0		; $3C28 (15400)	Used by the routine that reads the keyboard.
EXWRCH		dw	0		; $3C29 (15401)	This is normally 0 but it can be changed to print to some other device.
FRAMES		dw	0,0		; $3C2B (15403)	time since the Ace was started.
XCOORD		db	0		; $3C2F (15407)	The x-coordinate last used by 'PLOT'.
YCOORD		db	0		; $3C30 (15408)	The y-coordinate last used by 'PLOT'.
CURRENT		dw	0		; $3C31 (15409)	The parameter field address for the vocabulary word of the current vocabulary.
CONTEXT		dw	0		; $3C33 (15411)	The parameter field address for the vocabulary word of the context vocabulary.
VOCLNK		dw	0		; $3C35 (15413)	The address of the fourth byte in the parameter field - the vocabulary linkage -
STKBOT		dw	0		; $3C37 (15415)	The address of the next byte into which anything will be enclosed in the
DICT		dw	0		; $3C39 (15417)	The address of the length field in the newest word in the dictionary.
SPARE		dw	0		; $3C3B (15419)	The address of the first byte past the top of the stack.
ERR_NO		db	0		; $3C3D (15421)	This is usually 255, meaning "no error".
FLAGS		db	0		; $3C3E (15422)	Shows the state of various parts of the system.
BASE		db	0		; $3C3F (15423)	The system number base.


#code RAM, $3C40, ramsize - $840
progstart:
	jp	$		; insert your programme here




















