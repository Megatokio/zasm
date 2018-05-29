#!/usr/local/bin/zasm --z180 -o original/
; get the nice labels for the built-in io ports of the Z180
    include "185macro.lib"

;    CPU = Z180				; kio 2015-01-06 auskommentiert   ((z180 würde passieren, macht aber keinen Sinn…))
;    globals on				; kio 2015-01-06 auskommentiert
    org     0000H         ; this is the monitor

    ; setup the stack @ the top of memory
    LD HL, 0FFFFH
    LD SP, HL

; code starts here
    CALL init_com2

    LD D, 'J'
    CALL output_byte
    
    LD D, 'D'
    CALL output_byte
    
    LD D, 000H
    CALL output_hex
    
    LD D, 0A0H
    CALL output_hex

    LD D, 0BBH
    CALL output_hex

    LD D, 00EH
    CALL output_hex
    
    HALT
    
disp_prompt:
    LD HL, prompt
    CALL output_string

    CALL input_ascii

    CP 'd'
    CALL Z, do_dump

    CP 'e'
    CALL Z, do_exec

    LD D, A
    CALL output_byte
    JR disp_prompt
    
; data starts here
prompt: db 10, 13, "CMD> ", 0
msg_dump: db "dump", 13, 10, 0
msg_exec: db "exec", 0
msg_value: db "value", 13, 10, "0x", 0

; subroutines start here

; dumps bytes in hex to the 2nd serial port
; INPUT: none
; CLOBBERS: none
; RETURNS: none
; STACK: 16 bytes total
do_dump:
    PUSH AF
    PUSH BC
    PUSH DE
    PUSH HL
    
    LD HL, msg_dump
    CALL output_string

    LD DE, 0000H    ; starting address of dump
    LD B, 16        ; how many bytes to dump

dmp_lp:
    LD A, (DE)      ; get the byte to dump

    PUSH DE

    LD D, A         ; move to D for use as input
    CALL output_hex ; and display it
    LD D, ' '
    CALL output_byte

    POP DE
    INC DE
    DJNZ dmp_lp

    POP HL
    POP DE
    POP BC
    POP AF
    RET

do_exec:
    PUSH HL
    
    LD HL, msg_exec
    CALL output_string

    POP HL
    RET

; *FIX FOR REAL Z180* - change to IN0/OUT0 and setup the clock
; initialize the 2nd serial port
; INPUT: none
; CLOBBERS: none
; RETURNS: none
init_com2:
    ; 8-n-1 -  transmit enabled, recieve enabled
    ;   the emulator doesn't seem to support the in0 and out0 instructions
    ;   which means I have to use the in/out z80 instructions, which put
    ;   the value in B on A8-A15.
    ;   in0 a, (cntla1)
    PUSH AF
    PUSH BC

	in0 a, (cntla1)			; kio 2015-01-06: wieder eingebaut für Testing
;	LD B, 0
;	IN A, (cntla1)
    
    OR 01100100B     ; RE=1, TE=1, CKA1D=0, M2 = 1, M1 = 0, M0 = 0
	
    out0 (cntla1), a			; kio 2015-01-06: wieder eingebaut für Testing
;    LD B, 0
;    OUT (cntla1), a

    POP BC
    POP AF
    RET
    
; *FIX FOR REAL Z180* - change to IN0/OUT0
; send a byte out the 2nd serial port
; INPUT: D = byte to output
; CLOBBERS: none
; RETURNS: none
; STACK: 4 bytes
output_byte:
    PUSH AF
    PUSH BC
    
outpb_rdy:
    in0 a, (stat1)      ; status of COM2	; kio 2015-01-06: wieder eingebaut für Testing
    ;LD B, 0
    ;IN A, (stat1)

    BIT 1, A            ; Transmit data register empty?
    JR z, outpb_rdy   ; if(no) wait for room to transmit
    LD A, D             ; a = byte to output

    out0 (tdr1), a     ; send a J to COM2	; kio 2015-01-06: wieder eingebaut für Testing
    ;OUT (tdr1), A

    POP BC
    POP AF
    RET
    
; *FIX FOR REAL Z180* - change to IN0/OUT0
; get a byte into A from the 2nd serial port (no ascii to binary conversion
; i.e. user hits 7 means A = '7')
; INPUT: none
; CLOBBERS: none
; RETURNS: A = byte read
; STACK: 2 bytes
input_ascii:
    PUSH BC
    
inpa_lp:
    in0 a, (stat1)     ; status of COM2		; kio 2015-01-06: wieder eingebaut für Testing
    ;LD B, 0
    ;IN A, (stat1)

    BIT 7, A            ; Recieve data register full?
    JR z, inpa_lp       ; if(no) wait for a character

    in0 a, (rdr1)      ; get a byte from Com2	; kio 2015-01-06: wieder eingebaut für Testing
    ;IN A, (rdr1)
    
    POP BC
    RET

; get a hex value into A from the 2nd serial port - must input 2 values
; upper nibble first, then lower nibble
; (i.e. user types 'f', 'a' means A = 0xFA)
; INPUT: none
; CLOBBERS: none
; RETURNS: A = byte read
; STACK: 6 bytes total
input_hex:
    ; ref: 0-9 = 0x30 - 0x39
    ;      a-f = 0x61 - 0x66
    PUSH AF
    PUSH DE
    
    CALL input_ascii
    LD D, A
    CALL input_ascii
    LD E, A
    
    ; D = upper nibble
    ; E = lower nibble
    LD A, D
    CP 040H
    JP S, inph_upper_less
    SUB 'a'					; <-- Bug! kio 2015-01-06
    LD D, A
    JR inph_lower
    
inph_upper_less:            ; upper nibble < 10
    SUB '0'
    LD D, A                 ; D = upper nibble actual value
    
inph_lower:
    LD A, D
    CP 040H
    JP S, inph_lower_less
    SUB 'a'					; <-- Bug! kio 2015-01-06
    LD E, A
    JR inph_combine
    
inph_lower_less:
    SUB '0'
    LD E, A
    
inph_combine:       ; D = upper nibble, E = lower nibble, want A = result
    LD A, D
    SLA A
    SLA A
    SLA A
    SLA A
    AND E

    POP DE
    POP AF
    RET
    
; send a null-terminated string of bytes out the 2nd serial port
; INPUT: HL = address of first byte
; CLOBBERS: none
; RETURNS: none
; STACK: 6 bytes
output_string:
    PUSH AF
    PUSH BC
    PUSH DE
    
outps_lp:
    LD A, 0         ; string-terminator = 0
    CP (HL)         ; is this the end-of-string?
    JR Z, outps_end ; if(yes) - stop outputting

    LD D, (HL)
    CALL output_byte
    INC HL
    JR outps_lp
    
outps_end:
    POP DE
    POP BC
    POP AF
    RET
    
; send a hex character to the 2nd serial port
; (i.e. if D = 7 then send out '7')
; INPUT: D = character to output
; CLOBBERS: none
; RETURNS: none
; STACK: 4 bytes
output_hex:
    PUSH AF
    PUSH BC
    
    LD B, D
    LD A, D     ; move data byte to accum for math operations
    AND 0F0H    ; A = A & 0xF0 (only work with upper nibble)
    SRL A       ; -+
    SRL A       ;  |
    SRL A       ;  |- A >> 4; move upper nibble to lower nibble
    SRL A       ; -+
    CP 10
    JP S, outph_upper_less    ; A < 10, therefore output A + '0'
    ; A >= 10, therefore output A - 10 + 'A'
    SUB 10
    ADD 'A'
    JR outph_upper_out
    
outph_upper_less:
    ADD '0'

outph_upper_out:
    LD D, A
    CALL output_byte
    
; now do the lower nibble
    LD A, B     ; move data byte to accum for math operations
    AND 0FH     ; A = A & 0x0F
    CP 10
    JP S, outph_lower_less
    SUB 10
    ADD 'A'
    JR outph_lower_out
    
outph_lower_less:
    ADD '0'
    
outph_lower_out:
    LD D, A
    CALL output_byte
    
    POP BC
    POP AF
    RET
