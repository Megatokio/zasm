#!/usr/local/bin/zasm -o original/

#target tzx


; sync bytes:
headerflag:     equ 0
dataflag:       equ 0xff

; some Basic tokens:
tCLEAR			equ	$FD       	; token CLEAR
tLOAD			equ	$EF       	; token LOAD
tCODE			equ	$AF       	; token CODE
tPRINT			equ	$F5       	; token PRINT
tRANDOMIZE		equ	$F9       	; token RANDOMIZE
tUSR			equ	$C0       	; token USR

pixels_start	equ	0x4000		; ZXSP screen pixels
attr_start		equ	0x5800		; ZXSP screen attributes
printer_buffer	equ	0x5B00		; ZXSP printer buffer
code_start		equ	24000

#data VARIABLES, printer_buffer, 0x100
; define some variables here


; ---------------------------------------------------
;		Basic Loader:
; ---------------------------------------------------

#code PROG_HEADER,0,17,headerflag
		defb    0						; Indicates a Basic program
		defb    "mloader   "			; the block name, 10 bytes long
		defw    variables_end-0			; length of block = length of basic program plus variables
		defw    10		    			; line number for auto-start, 0x8000 if none
		defw    program_end-0			; length of the basic program without variables

#tzx turbo, PROG_DATA,0,*,dataflag

; 10 CLEAR 23999
        defb    0,10                    ; line number
        defb    end10-($+1)             ; line length
        defb    0                       ; statement number
        defb    tCLEAR                  ; token CLEAR
        defm    "23999",$0e0000bf5d00   ; number 23999, ascii & internal format
end10:  defb    $0d                     ; line end marker

; 20 LOAD "" CODE 24000
        defb    0,20                    ; line number
        defb    end20-($+1)             ; line length
        defb    0                       ; statement number
        defb    tLOAD,'"','"',tCODE     ; token LOAD, 2 quotes, token CODE
        defm    "24000",$0e0000c05d00   ; number 24000, ascii & internal format
end20:  defb    $0d                     ; line end marker

; 30 RANDOMIZE USR 24000
        defb    0,30                    ; line number
        defb    end30-($+1)             ; line length
        defb    0                       ; statement number
        defb    tRANDOMIZE,tUSR         ; token RANDOMIZE, token USR
        defm    "24000",$0e0000c05d00   ; number 24000, ascii & internal format
end30:  defb    $0d                     ; line end marker

program_end:
variables_end:


; ---------------------------------------------------
;		machine code:
; ---------------------------------------------------

#tzx generalized, CODE_HEADER,0,17,headerflag
		defb    3						; Indicates binary data
		defb    "mcode     "	  		; the block name, 10 bytes long
		defw    code_end-code_start		; length of data block which follows
		defw    code_start				; default location for the data
		defw    0       				; unused

#code CODE_DATA, code_start,*,dataflag

; set print channel to Screen:
		ld		a,2
		call	$1601
; print message:
		ld		hl,msg
1$		ld		a,(hl)
		and		a
		ret		z
		inc		hl
		rst		2
		jr		1$

msg:	dm		13, "Hello World!", 13, 0

code_end:

#tzx message, duration=5, text=""

#tzx info,"Es folgen einige Testblocks"
#tzx pause, 0

#tzx group-start,name="Testgroup 1"
#tzx 0x24,10	; loop start
#tzx pure-tone, count=100, pulse=2000
#tzx 0x12,1000,2000
#tzx 0x25		; loop end
#tzx group-end

#tzx 0x30,"Es folgen weitere Testblocks"

#tzx loop-start, repetitions=10
#tzx pulses
	dw	1000,1000,1000,1000
	dw	2000,2000,2000,2000
	dw	1000,1000,1000,1000
	dw	2000,2000,2000,2000
#tzx 0x13
	dw	1000,1000,1000,1000
	dw	2000,2000,2000,2000
#tzx loop-end

#tzx csw "test-int16x2@44k1.wav", start=0,end=256
#tzx csw "test-int16@11kx1.wav", compressed
#tzx csw "test-float@11kx1.wav", compressed

#tzx 0x21,"Testgroup 2"
#tzx pause, duration = 100
#tzx 0x20, 100
#tzx 0x22 ; group-end

#tzx 0x31, 5, "Tape stops now","if in 48k mode" ; message block
#tzx 0x2a
#tzx stop-48k

#tzx 0x2b,0
#tzx polarity, polarity=1

; these get reordered to the start of the file:
#tzx archive-info
	db	0, "TZX test tape"		; title
	dm	2,"kio@little-bat.de"	; author
	.db	3,"2018"
	.dm	5,"tzx test file for zasm"
	dm	255,"this file doesn't do anything useful. it's purpose is to test tzx encoding of zasm."

#tzx hardware-info
	db	0,0x1a,3			; doesn't run on a jupiter ace
	db	0,0x00,0			; game is known to run on a ZX Spectrum 16k
	db	2,0x01,3			; doesn't run if a MF1 is attached
	db	3,0x02,1			; actually uses the Currah µSpeech

#code foo1, 1000, 100, flag=none, checksum=none
	ds	100,$e5

#tzx standard, foo2, *, *, flag=255, checksum=none, pause=250
	ds	15,$15

#code bar2
	ds	10,$85


#code foo3, *,*, flag=none, checksum=none, pilot=none, pause=250
	ds	20,$20

#code bar3
	ds	10,$95

#tzx turbo, foo4, 2000,*, flag=0, pilot=2500, pause=100, lastbits=4
	.tzx-pilot-sym  0, 900          ; symbol#0 for pilot pulses
	.tzx-pilot-sym  0, 300,400      ; symbol#1 for sync pulses (two pulses)
!	.tzx-pilot      0,1520, 1,1     ; 1520 pilot pulses (symbol#0), then one sync pulse symbol (symbol#1)
	.tzx-pilot      0,2500, 1,1     ; 2500 pilot pulses as defined in #tzx directive
	.tzx-data-sym   0, 290,290      ; symbol#0 for bit 0
	.tzx-data-sym   0, 580,580      ; symbol#1 for bit 1
	ds	25,$25

#code bar4
	ds	10,$A5

#tzx generalized, foo5, 3000,*, flag=255, pause=100
	.tzx-pilot-sym  0, 700,500,700  ; symbol#0 for pilot pulses
	.tzx-pilot-sym  0, 800          ; symbol#1 for pilot pulses
	.tzx-pilot-sym  0, 900          ; symbol#2 for pilot pulses
	.tzx-pilot-sym  0, 300,400      ; symbol#3 for sync pulses (two pulses)
	.tzx-pilot      0,1500, 1,5000, 2,5000, 3,1
	.tzx-data-sym   0, 290,285      ; symbol#0 for bit 0
	.tzx-data-sym   0, 580,570      ; symbol#1 for bit 1
	ds	25,$25

#code bar5
	ds	1000,$B5

#code foo6,100,100,flag=0			; => Standard Data Block
    .tzx-pilot-sym  0,2168          ; symbol for pilot pulses
    .tzx-pilot-sym  0,667,735       ; symbol for sync pulses (two pulses)
    .tzx-pilot      0,8063, 1,1     ; 8063 pilot pulses (symbol#0), then one sync pulse symbol (symbol#1)
    .tzx-data-sym   0,855,855       ; symbol for bit 0
    .tzx-data-sym   0,1710,1710     ; symbol for bit 1

#code foo7,200,100,flag=255			; => Standard Data Block
    .tzx-pilot-sym  0,2168          ; symbol for pilot pulses
    .tzx-pilot-sym  0,667,735       ; symbol for sync pulses (two pulses)
    .tzx-pilot      0,3223, 1,1     ; 3223 pilot pulses (symbol#0), then one sync pulse symbol (symbol#1)
    .tzx-data-sym   0,855,855       ; symbol for bit 0
    .tzx-data-sym   0,1710,1710     ; symbol for bit 1

#code foo8,300,100,flag=0, checksum=ace	; -> Generalized
    .tzx-pilot-sym  0,2011          ; symbol for pilot pulses
    .tzx-pilot-sym  0,601,791       ; symbol for sync pulses (two pulses)
    .tzx-pilot      0,8192, 1,1     ; 8192 pilot pulses (symbol#0), then one sync pulse symbol (symbol#1)
    .tzx-data-sym   0,795,801       ; symbol for bit 0
    .tzx-data-sym   0,1585,1591     ; symbol for bit 1

#code foo9,400,100,flag=255, checksum=ace ; -> Generalized
    .tzx-pilot-sym  0,2011          ; symbol for pilot pulses
    .tzx-pilot-sym  0,601,791       ; symbol for sync pulses (two pulses)
    .tzx-pilot      0,1024, 1,1     ; 1024 pilot pulses (symbol#0), then one sync pulse symbol (symbol#1)
    .tzx-data-sym   0,795,801       ; symbol for bit 0
    .tzx-data-sym   0,1585,1591     ; symbol for bit 1

; Example with 2-bit symbols. this requires 4 data symbols for the 4 possible values:

#code foo10, $500, $100, flag=255
    .tzx-pilot-sym  0, 1500             ; symbol#0 for pilot pulses
    .tzx-pilot-sym  0, 500              ; symbol#1 for sync pulses
    .tzx-pilot      0,1000, 1,2         ; 1000 pilot pulses (symbol#0), 2 short sync pulses (symbol#1)
    .tzx-data-sym   0, 500,350,650,500  ; symbol#0 for 2 bits = 00
    .tzx-data-sym   0, 500,450,550,500  ; symbol#1 for 2 bits = 01
    .tzx-data-sym   0, 500,550,450,500  ; symbol#0 for 2 bits = 10
    .tzx-data-sym   0, 500,650,350,500  ; symbol#1 for 2 bits = 11

; ZX81 program:

#code foo11, $600, $100, flag=NONE, checksum=NONE, pilot=NONE
    .tzx-data-sym   3, 530,520,530,520,530,520,530, 4689
    .tzx-data-sym   3, 530,520,530,520,530,520,530, 520,530,520,530,520,530,520,530,520,530,4689
