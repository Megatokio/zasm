; Disassembly of the file "C:\Program Files\xeltek\WINSP580\bin\wmfirmware.bin"
; 
; CPU Type: Z80
; 
; Created with dZ80 2.0
; 
; on Tuesday, 25 of May 2004 at 02:47 PM
;


; Z80 assembly notes
;	'sub a' is faster than 'ld a,00', 4 vs 7 

; PORTS

;26		controls port speed, 2-byte value
;2A		serial port 1 input/output
;2B		serial port 1 status/control
;
;38		bit 1: 0=96	1=384		plate LEDs
;
;3C		bit 0: might be front panel keys
;		.
;		.
;		.
;		bit 7: Ditto
;3D		bit 3: Ditto
;
;		8A is initialized with ffh
;8A		bit 0: 0=st rst	1=end reset	resets something, INT 5
;		bit 2: 0=st rst	1=end reset	resets something, INT 5
;		bit 3: 0=fwd	1=rev		pump direction control

;8C		bit 0: 0=FALSE	1=TRUE		stage at home
;		bit 1: 0=FALSE	1=TRUE		stage at start
;		bit 2: 0=FALSE	1=TRUE		pump at home	
;		bit 3: 0=24cols 1=12cols	plate type
;		bit 4: 0=open   1=closed	pump jaw


; SRAM

;D040 - D261	21 buffers of 26 bytes each
;D500		38 - Holds status of front panel LEDs?????
;D501		3a - Stage status?????
;D503		3e - Holds value outputted to port 3e
;D509		Holds port 8A
;D514		Might hold plate-type status
;D517		Zero based column count
;D51D		Holds front panel key press
;D522 - D523	Canned timeout value, set to 50, used at 2676
;D524 - D525	Canned timeout value, set to 200, used at 266C
;D529		Stage-in-motion flag?
;D52E - D52F	Used to initialize D530 - D531, initialized to 3
;D530 - D531	Count down thingy
;D535 - D536	Canned timeout value, difference between two values.  Calc'ed at runtime
;D537 - D538	Canned timeout value, set to 10, used at 200E
;D550		Pump On Flag
;D561		Timer countdown enable/disable
;D562		Pump stuff
;D577		Seems to turn pump on and off
;D578		Controls pump direction: 0 - dispense, 1 - reverse to supply
;D579 - D57B	Holds pump volume
;D586 - D587	PS setting
;D588		WellMate is stopped flag
;D589 - D58B	Preset pump volume used in function 1FDE
;D598 - D59C	Holds string or number to be converted
;D59E - D5A2	Holds number or string created by conversion
;D5B0		Error number - perhaps pump related
;D5DB		Full message received flag
;D5DC - D9DB	Buffer for serial input INT routine
;D9DC		STX received flag
;D9DD - D9DE	serial input INT routine buffer index
;D9Df - DDDE	Buffer for processed input from serial port
;DDDF		Processing input flag
;DDE3		Current column #
;DDE5 - DDE6	Output serial port buffer index
;DDE7		Serial port stuff
;DDE8 - D???	Output serial port buffer
;DE4C - DE4D	Processed serial input buffer index
;DE4E - DE4F	Position to move stage to in steps?
;DE50 - DE51	Column # to move to
;DE52 - DE53	Offset # to move to
;DE58 - DE59	Holds PS setting for function E11, which writes it out to port 26


; EPROM

#target rom
#code rom,0,65536

Label_1:
    jp      Label_2		; HW Start

    defs    66h - $

    retn    			; NMI

    defs    80h - $

;	Interrupt Vector Table for mode 2 interrupts

    defw    IntRoutine_7
    defw    IntRoutine_1
    defw    IntRoutine_6
    defw    IntRoutine_5
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_4
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_1
    defw    IntRoutine_3
    defw    IntRoutine_2
    defw    IntRoutine_1

    defs    100h - $

Label_2:
    ld      a,3fh
    out     (00h),a		; Ports: 00 01 02 03 04 05 06 07
    ld      a,00h		; Value: 3f 00 3f 00 33 13 3f f0
    out     (01h),a
    ld      a,3fh
    out     (02h),a
    ld      a,00h
    out     (03h),a
    ld      a,33h
    out     (04h),a
    ld      a,13h
    out     (05h),a
    ld      a,3fh
    out     (06h),a
    ld      a,0f0h
    out     (07h),a
    ld      sp,0fffeh		; Initialize the stack pointer
    ld      a,00h
    out     (1ah),a		; Zero out ports 1A - 1F
    ld      a,00h
    out     (1bh),a
    ld      a,00h
    out     (1ch),a
    ld      a,9bh
    out     (1dh),a
    ld      a,00h
    out     (1eh),a
    ld      a,00h
    ld      (001fh),a

;	This section zeros out D000 through FFFF
;	

    ld      hl,0d000h
Label_3:
    xor     a
    ld      (hl),a		; (D000 - FFFF) = 0
    inc     hl
    ld      a,h
    cp      0ffh
    jp      nz,Label_3
    ld      a,l
    cp      0ffh
    jp      nz,Label_3

    call    Label_458
    ld      a,00h		; Set interrupt table to page 0
    ld      i,a
    im      2			; Interrupt Mode 2
    ld      a,60h
    out     (35h),a
    ld      a,09h
    out     (34h),a
    ld      a,80h
    out     (37h),a
    ld      a,01h
    out     (35h),a
    ld      a,04h
    out     (34h),a
    ld      a,0deh
    out     (37h),a
    ld      a,0f2h
    out     (36h),a
    ld      a,0c0h
    out     (13h),a
    ld      a,3ah
    out     (2bh),a
    ld      a,01h
    out     (28h),a
    ld      a,0e5h
    out     (2bh),a
    call    Label_20
    ld      a,3ah
    out     (2fh),a
    ld      a,01h
    out     (2ch),a
    ld      a,0e5h
    out     (2fh),a
    call    Label_21
    ld      a,04h
    out     (23h),a
    ld      a,04h
    out     (21h),a
    in      a,(21h)
    ld      hl,1680h
    ld      a,l
    out     (20h),a
    ld      a,h
    out     (20h),a
    ld      a,06h
    out     (27h),a
    in      a,(27h)
    ld      hl,0062h
    ld      a,l
    out     (26h),a
    ld      a,h
    out     (26h),a
    ld      a,05h
    out     (25h),a
    in      a,(25h)
    ld      hl,0266h
    ld      a,l
    out     (24h),a
    ld      a,h
    out     (24h),a
    ld      a,00h
    ld      (0d500h),a
    out     (38h),a
    ld      a,0ffh
    out     (3bh),a
    ld      a,00h
    ld      (0d501h),a
    out     (3ah),a
    ld      a,00h
    out     (3dh),a
    ld      a,97h
    out     (3fh),a
    ld      a,00h
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ffh
    ld      (0d509h),a
    out     (8ah),a
    ld      hl,0695h
    ld      (0d570h),hl
    ld      hl,4000h
    ld      (0d572h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,01ech
    ld      (0d580h),hl
    ld      hl,024dh
    ld      (0d582h),hl
    ld      hl,03d7h
    ld      (0d584h),hl
    ld      hl,(0d580h)
    ld      (0d586h),hl
    ld      hl,0003h
    ld      (0d52eh),hl
    ld      a,00h
    ld      (0d54bh),a
    ld      hl,000dh
    ld      (0d52bh),hl
    ld      hl,07d0h
    ld      (0d54ch),hl
    ld      hl,0002h
    ld      (0d54eh),hl
    ld      hl,0000h
    ld      (0d535h),hl		; Init (D535) timeout value to 0
    ld      hl,000ah
    ld      (0d537h),hl		; Init (D537) timeout value to 10
    ld      hl,0064h
    ld      (0d552h),hl
    ld      hl,0064h
    ld      (0d554h),hl
    ld      a,00h
    ld      (0d52dh),a
    ld      (0d532h),a
    ld      (0d588h),a
    ld      hl,0000h
    ld      (0dde3h),hl		; Set current column to 0
    ld      a,00h
    ld      (0de5ch),a
    ld      (0de5ah),a
    ld      (0de5bh),a
    ld      a,(0d000h)
    cp      0aah
    call    nz,Label_333	; Inits 21 buffers and Dxxx memory
    ei      			; Enable Interrupts
    in      a,(3ch)
    cp      03h
    jp      z,Label_407
    in      a,(3ch)
    cp      80h
    jp      z,Label_4
    jp      Label_5
Label_4:
    in      a,(3eh)
    and     08h
    cp      08h
    jp      z,Label_416
Label_5:
    in      a,(3ch)
    cp      60h
    jp      z,Label_426
    in      a,(80h)
    and     0f0h
    cp      80h
    jp      z,Label_450
    call    Label_340
    jp      Label_6

    defs    500h - $

Label_6:
    ld      a,0f8h
    out     (81h),a
    ld      a,0eeh
    out     (80h),a
    ld      a,0b6h
    out     (80h),a
    ld      a,0edh
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      hl,03e8h
    ld      (0d562h),hl		; (D562) = 1000
    call    Label_366		; Look at pump and pump-jaw
Label_7:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_8
    ld      a,(0d001h)
    cp      00h
    jp      z,Label_200
    cp      01h
    jp      z,Label_223
    cp      02h
    jp      z,Label_237
    cp      03h
    jp      z,Label_200
    cp      04h
    jp      z,Label_223
    cp      05h
    jp      z,Label_237
Label_8:
    call    Label_114		; Stage home, X0 command
Label_9:
    ld      a,(0d001h)
    cp      00h
    jp      z,Label_149
    cp      01h
    jp      z,Label_173
    cp      02h
    jp      z,Label_186
    cp      03h
    jp      z,Label_149
    cp      04h
    jp      z,Label_173
    cp      05h
    jp      z,Label_186
    ld      a,00h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    set     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a		; Set 38:0/1
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a		; Set 3a:0
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a		; Clear 3e:0
    ld      a,0f8h
    out     (81h),a		; 81 = f8
    ld      a,0ffh
    out     (80h),a		; 80 = ff,ff,ff,ff,00,00,00,00,00
    ld      a,0ffh
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
Label_10:
    ld      a,81h
    out     (2fh),a		; 2f = 81, enable serial port INTs?????
    in      a,(2fh)
    and     40h
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      4dh			; M - do nothing
    jp      z,Label_11
    cp      52h			; R
    jp      z,Label_12
    cp      43h			; C - do nothing
    jp      z,Label_13
    cp      55h			; U - do nothing
    jp      z,Label_14
    cp      44h			; D - do nothing
    jp      z,Label_15
    cp      47h			; G
    jp      z,Label_16
    cp      53h			; S - do nothing
    jp      z,Label_17
    cp      46h			; F - do nothing
    jp      z,Label_18
    cp      42h			; B - do nothing
    jp      z,Label_19
    jp      Label_10

Label_11:
    jp      Label_10
Label_12:
    call    Label_114		; Act on R, Stage home, X0 command
    jp      Label_10
Label_13:
    jp      Label_10
Label_14:
    jp      Label_10
Label_15:
    jp      Label_10

Label_16:
    call    Label_122		; Act on G, Stage-to-start, X1 command
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    call    Label_120
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_16

    jp      Label_10
Label_17:
    jp      Label_10
Label_18:
    jp      Label_10
Label_19:
    jp      Label_10

Label_20:
    ld      a,40h		; Called from 0183 only: Sets up serial port 1?????
    out     (2bh),a
    ld      a,3ah
    out     (2bh),a
    ld      a,25h
    out     (2bh),a
    ret     

    ld      a,00h		; NOT called by anyone: Shut down serial port 1????
    out     (2bh),a
    ret     

Label_21:
    ld      a,40h		; Called from 0192 only: Sets up serial port 2?????
    out     (2fh),a
    ld      a,3ah
    out     (2fh),a
    ld      a,25h
    out     (2fh),a
    ret     

    ld      a,00h		; NOT called by anyone: Shut down serial port 2????
    out     (2fh),a
    ret     

Label_22:
    ld      a,(0d500h)		; Called from 070e only
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,0f8h
    out     (81h),a
    ld      a,84h
    out     (80h),a
    ld      a,0eeh
    out     (80h),a
    ld      a,0cbh
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a


Label_23:
    ld      a,(0d550h)		; Beginning of loop
    and     a
    jp      z,Label_24		; Jump if pump off
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370

Label_24:
    ld      a,(0dddfh)
    and     a
    jp      nz,Label_25
    call    Label_340		; If dddf = 0 do this
    jp      Label_26

Label_25:
    ld      a,03h		; Else if dddf = 1 do this
    ld      (0d5b0h),a
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     bc
    ld      a,(0d514h)
    xor     b
    call    nz,Label_370

Label_26:
    ld      a,(0de5ah)		; Then continue here
    and     a
    call    nz,Label_326
    ld      a,(0dddfh)
    and     a
    jp      z,Label_23
    call    Label_30		; Look for serial port input
    jp      Label_23


Label_27:
    ld      hl,0d9dfh
    ld      de,(0de4ch)
    add     hl,de
    ld      a,(hl)
    inc     de
    ld      (0de4ch),de
    cp      4fh
    jp      nz,Label_28
    call    Label_29
    ld      a,01h
    ld      (0de5ch),a
    pop     af
    jp      Label_22
Label_28:
    ld      hl,8683h
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    Label_77		; Send msg via serial port
    ld      a,00h
    ld      (0dddfh),a
    ret     

;	Create and send status string 'N.n,An,Bn,Cn,Dn,XWnn+nnn'

Label_29:
    ld      ix,0dde8h		; ix = dde8 + 0
    ld      de,0000h
    add     ix,de
    call    Label_137		; Setup eprom revision (N.n)
    ld      a,2ch		; Replace '@' with ','
    ld      (0ddebh),a
    ld      ix,0dde8h		; ix = dde8 + 4
    ld      de,0004h
    add     ix,de
    call    Label_138		; Setup stage-at-home status (An)
    ld      a,2ch		; Replace '@' with ','
    ld      (0ddeeh),a
    ld      ix,0dde8h		; ix = dde8 + 7
    ld      de,0007h
    add     ix,de
    call    Label_140		; Setup stage-at-start status (Bn)
    ld      a,2ch		; Replace '@' with ','
    ld      (0ddf1h),a
    ld      ix,0dde8h		; ix = dde8 + a
    ld      de,000ah
    add     ix,de
    call    Label_142		; Setup plate-type status (Cn)
    ld      a,2ch		; Replace '@' with ','
    ld      (0ddf4h),a
    ld      ix,0dde8h		; ix = dde8 + d
    ld      de,000dh
    add     ix,de
    call    Label_144		; Setup pump-jaw status (Dn)
    ld      a,2ch		; Replace '@' with ','
    ld      (0ddf7h),a
    ld      ix,0dde8h		; ix = dde8 + 10
    ld      de,0010h
    add     ix,de
    call    Label_146		; Setup stage-position location (XWnn+nnn)
    call    Label_77		; Send entire msg via serial port
    ret

;	Start of serial port input

Label_30:
    ld      a,00h
    ld      (0d529h),a		; Start with d529 set to FALSE
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,Label_31
    jp      Label_32

Label_31:
    ld      a,01h
    ld      (0d529h),a		; Set d529 to TRUE if bit 6 of port 2f is set

Label_32:
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de		; Point to processed input buffer + index
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    push    af
    ld      a,(0d550h)
    and     a
    jp      nz,Label_33		; Jump if pump on

; If pump is off then these commands are processed

    pop     af
    cp      4fh			; O
    jp      z,Label_34
    cp      43h			; C
    jp      z,Label_35
    cp      52h			; R
    jp      z,Label_36
    cp      58h			; X
    jp      z,Label_39
    cp      50h			; P
    jp      z,Label_53
    cp      53h			; S
    jp      z,Label_62
    cp      41h			; A
    jp      z,Label_63
    cp      51h			; Q
    jp      z,Label_64
    cp      57h			; W
    jp      z,Label_70
    cp      4ch			; L
    jp      z,Label_71
    cp      03h			; ETX
    jp      z,Label_75
    jp      Label_76		; Send an 'E99' string

; If pump is on then only these commands are processed

Label_33:
    pop     af
    cp      50h			; P
    jp      z,Label_53
    cp      57h			; W
    jp      z,Label_70
    cp      03h			; ETX
    jp      z,Label_75
    jp      Label_76		; Send an 'E99' string

Label_34:
    call    Label_29		; O command
    ret     

Label_35:
    ld      a,00h		; C command
    ld      (0de5ch),a
    call    Label_86
    ld      a,00h
    ld      (0dddfh),a
    pop     af
    jp      Label_9

Label_36:
    ld      a,(0d529h)		; R command
    and     a
    jp      nz,Label_37
    call    Label_114		; Stage home, X0 command
    jp      Label_38
Label_37:
    jp      Label_38
Label_38:
    ld      a,00h
    ld      (0dddfh),a
    call    Label_88		; Send an 'R' message
    ret     

Label_39:
    ld      ix,0d9dfh		; X command
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      53h			; S
    jp      z,Label_40
    cp      30h			; 0
    jp      z,Label_42
    cp      31h			; 1
    jp      z,Label_44
    cp      32h			; 2
    jp      z,Label_46
    cp      57h			; W
    jp      z,Label_48
    jp      Label_76		; Send an 'E99' string

Label_40:
    ld      ix,0d9dfh		; XS command
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    Label_483		; Convert string to number
    ld      hl,(0d59eh)
    ld      hl,018fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,4e20h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de
    jp      m,Label_76		; Send an 'E99' string
    ld      a,(0d529h)
    and     a
    jp      nz,Label_41
    ld      hl,(0d59eh)
    ld      (0d565h),hl
    ret     

Label_41:
    ret     

Label_42:
    ld      a,(0d529h)		; X0 command
    and     a
    jp      nz,Label_43
    call    Label_114		; Go to Home
    ret     

Label_43:
    ret     

Label_44:
    ld      a,(0d529h)		; X1 command
    and     a
    jp      nz,Label_45
    call    Label_122		; Go to Start
    ret     

Label_45:
    ret     

Label_46:
    ld      a,(0d529h)		; X2 command
    and     a
    jp      nz,Label_47
    call    Label_124		; Go to Waste
    ret     

Label_47:
    ret     

Label_48:
    ld      ix,0d9dfh		; XW command
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d599h),a
    ld      a,(ix+01h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59ah),a
    ld      (0d59bh),a
    ld      (0d59ch),a
    call    Label_483		; Convert string to number
    ld      hl,(0d59eh)
    ld      hl,0000h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If column # < 0 or column # = 0 then respectively
    jp      p,Label_76		; Send an 'E99' string
    jp      z,Label_76		; Send an 'E99' string
    in      a,(8ch)
    bit     3,a
    jp      z,Label_49		; Jump if slide switch says 384-well plate

    ld      hl,000ch		; 12 Columns
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If column # > 12 then
    jp      m,Label_76		; Send an 'E99' string
;				; Goofy that it doesn't 'jp 0948h'
Label_49:
    ld      hl,0018h		; 24 Columns
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If column # > 24 then
    jp      m,Label_76		; Send an 'E99' string

    ld      hl,(0d59eh)
    ld      (0de50h),hl		; (de50) = column to move to
    ld      a,(ix+02h)
    cp      2bh			; +
    jp      z,Label_51
    cp      2dh			; -
    jp      z,Label_52
    jp      Label_50
Label_50:
    ld      hl,0000h
    ld      (0de52h),hl
    call    Label_109		; Go move stage
    ret     

Label_51:
    ld      de,(0de4ch)		; XWnn+ command
    inc     de
    ld      (0de4ch),de
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      a,30h
    ld      (0d59ch),a
    call    Label_483		; Convert string to number
    ld      hl,(0d59eh)
    ld      hl,0ffffh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If column offset # < 0 then
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,00f0h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If colum offset # > 240 then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      (0de52h),hl
    call    Label_109		; Go move stage
    ret     

Label_52:
    ld      de,(0de4ch)		; XWnn- command
    inc     de
    ld      (0de4ch),de
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      a,30h
    ld      (0d59ch),a
    call    Label_483		; Convert string to number
    ld      de,(0d59eh)
    ld      hl,0000h
    and     a
    sbc     hl,de		; Convert positive # to negative #
    ld      (0d59eh),hl
    ld      hl,00f0h
    ld      de,(0d59eh)
    and     a
    add     hl,de		; If negated offset # < -240
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,0000h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If converted offset # > 0 then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      (0de52h),hl
    call    Label_109		; Go move stage
    ret     

Label_53:
    ld      ix,0d9dfh		; P command
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    push    af
    ld      a,(0d550h)
    and     a
    jp      nz,Label_54		; Jump if pump on
    pop     af
    cp      53h			; S
    jp      z,Label_55
    cp      30h			; 0
    jp      z,Label_56
    cp      31h			; 1
    jp      z,Label_57
    cp      32h			; 2
    jp      z,Label_58
    cp      33h			; 3
    jp      z,Label_59
    cp      2bh			; +
    jp      z,Label_60
    cp      2dh			; -
    jp      z,Label_61
Label_54:
    pop     af			; THIS IS A BUG! Should be a "jp 0d28h" instruction before the "pop af"
    cp      33h			; 3
    jp      z,Label_59		; A P3 (stop pump) is the only command allowed when the pump is on
    jp      Label_76		; Send an 'E99' string, unknown Px command

;	PSnnnnn command - Set speed of pump

Label_55:
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de		; Processed input buffer w/ index
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on
    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    Label_483		; Convert string to number
    ld      hl,(0d59eh)		; -----REMOVE-----
    ld      hl,018fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If speed < 400 units then
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,4e20h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If speed < 20,000 units then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      (0d586h),hl
    ret     

;	P0 command - Home pump

Label_56:
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on
    call    Label_134
    ret     

;	P1 command - Turn on pump, start dispensing

Label_57:
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on
    ld      a,00h
    ld      (0d578h),a		; Set direction to dispense
    call    Label_131
    ld      a,01h
    ld      (0d550h),a		; Set pump-on flag
    ret     

;	P2 command - Turn on pump, in reverse, towards supply

Label_58:
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on
    ld      a,01h
    ld      (0d578h),a		; Set direction to reverse to supply
    call    Label_131
    ld      a,01h
    ld      (0d550h),a		; Set pump-on flag
    ret

;	P3 command - Turn off pump

Label_59:
    ld      a,(0d550h)
    and     a
    ret     z			; Leave if pump is already off
    ld      a,00h
    ld      (0d577h),a		; Turns off pump?
    ld      a,00h
    ld      (0d550h),a		; Clear pump-on flag
    ret

;	P+ command

Label_60:
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on

    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    Label_483		; Convert string to number
    ld      a,(0d5a0h)
    sub     02h			; If volume > 131071 (1ffffh) then
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,869fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; Why bother with the first compare if you have to do the second one?
    ld      a,(0d5a0h)
    ld      e,a
    ld      a,01h
    sbc     a,e			; If volume > 100000 (1869fh) then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      (0d579h),hl
    ld      a,(0d5a0h)
    ld      (0d57bh),a		; Set (D579 - D57B) to pump volume
    ld      a,00h
    ld      (0d578h),a		; Set pump direction to dispense
    call    Label_125		; Go run pump for volume in (D579-D57B)
    ret

;	P- command

Label_61:
    ld      ix,0d9dfh
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(0d550h)
    and     a
    ret     nz			; Leave if pump on

    ld      a,(ix+00h)
    ld      (0d59ch),a
    ld      a,(ix+01h)
    ld      (0d59bh),a
    ld      a,(ix+02h)
    ld      (0d59ah),a
    ld      a,(ix+03h)
    ld      (0d599h),a
    ld      a,(ix+04h)
    ld      (0d598h),a
    call    Label_483		; Convert string to number
    ld      a,(0d5a0h)
    sub     02h			; If volume > 131071 (1ffffh) then
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,869fh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; Why bother with the first compare if you have to do the second one?
    ld      a,(0d5a0h)
    ld      e,a
    ld      a,01h
    sbc     a,e			; If volume > 100000 (1869fh) then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      (0d579h),hl
    ld      a,(0d5a0h)
    ld      (0d57bh),a		; Set (D579 - D57B) to pump volume
    ld      a,01h
    ld      (0d578h),a		; Set pump direction to reverse to supply
    call    Label_125		; Go run pump for volume in (D579-D57B)
    ret     

Label_62:
    ld      a,01h		; S command
    ld      (0d588h),a
    ret     

Label_63:
    ld      a,00h		; A command
    ld      (0d588h),a
    ret     

Label_64:
    ld      ix,0d9dfh		; Q command
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      41h			; A
    jp      z,Label_65
    cp      42h			; B
    jp      z,Label_66
    cp      43h			; C
    jp      z,Label_67
    cp      44h			; D
    jp      z,Label_68
    cp      58h			; X
    jp      z,Label_69
    jp      Label_76		; Send an 'E99' string

Label_65:
    ld      ix,0dde8h		; QA command
    call    Label_138
    call    Label_77		; Send msg via serial port
    ret     

Label_66:
    ld      ix,0dde8h		; QB command
    call    Label_140
    call    Label_77		; Send msg via serial port
    ret     

Label_67:
    ld      ix,0dde8h		; QC command
    call    Label_142
    call    Label_77		; Send msg via serial port
    ret     

Label_68:
    ld      ix,0dde8h		; QD command
    call    Label_144
    call    Label_77		; Send msg via serial port
    ret     

Label_69:
    ld      ix,0dde8h		; QX command
    call    Label_146
    call    Label_77		; Send msg via serial port
    ret     

Label_70:
    ld      ix,0d9dfh		; W command
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,(ix+00h)
    ld      (0d59ah),a
    ld      a,(ix+01h)
    ld      (0d599h),a
    ld      a,(ix+02h)
    ld      (0d598h),a
    ld      a,30h
    ld      (0d59bh),a
    ld      (0d59ch),a
    call    Label_483		; Convert string to number
    ld      hl,0ffffh
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If wait command value < 0 then
    jp      p,Label_76		; Send an 'E99' string
    ld      hl,03e7h
    ld      de,(0d59eh)
    and     a
    sbc     hl,de		; If wait command value > 1024 then
    jp      m,Label_76		; Send an 'E99' string
    ld      hl,(0d59eh)
    ld      de,000ah
    call    Label_497
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_71:
    ld      ix,0d9dfh		; L command
    ld      de,(0de4ch)
    add     ix,de
    ld      a,(ix+00h)
    inc     de
    ld      (0de4ch),de
    cp      50h			; P
    jp      z,Label_72
    cp      4ch			; L
    jp      z,Label_73
    cp      55h			; U
    jp      z,Label_74
    jp      Label_76		; Send an 'E99' string

Label_72:
    ld      ix,0d9dfh		; LPnnn command
    ld      de,(0de4ch)
    add     ix,de
    inc     de
    inc     de
    inc     de
    ld      (0de4ch),de
    ld      a,4ch		; L
    ld      (0dde8h),a
    ld      a,50h		; P
    ld      (0dde9h),a
    ld      a,40h		; @
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_73:
    ld      a,4ch		; L	LL command
    ld      (0dde8h),a
    ld      a,4ch		; L
    ld      (0dde9h),a
    ld      a,40h		; @
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_74:
    ld      a,4ch		; L	LU command
    ld      (0dde8h),a
    ld      a,55h		; U
    ld      (0dde9h),a
    ld      a,40h		; @
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_75:
    call    Label_86		; Handle ETX
    ld      a,00h
    ld      (0dddfh),a
    ret     

;	Send an 'E99' string via serial port

Label_76:
    ld      hl,8683h		; E99 string
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    Label_77		; Send msg via serial port
    ld      a,00h
    ld      (0dddfh),a
    ret     

;	Send a message through the serial port

Label_77:
    ld      a,00h
    ld      (0dde7h),a
Label_78:
    ld      hl,0000h
    ld      (0dde5h),hl		; Set output index to zero
    call    Label_89		; Wait for send complete
    ld      a,02h		; STX
    out     (2ah),a

Label_79:
    ld      hl,0dde8h		; Top of loop
    ld      de,(0dde5h)
    add     hl,de
    ld      a,(hl)
    inc     de
    ld      (0dde5h),de
    cp      40h			; '@' indicates end of message
    jp      z,Label_80
    call    Label_89		; Wait for send complete
    out     (2ah),a		; Send character
    jp      Label_79		; Loop back and send the whole message

Label_80:
    call    Label_89		; Wait for send complete
    ld      a,03h		; ETX
    out     (2ah),a
    ld      hl,07d0h
    ld      (0d562h),hl		; Init (d562) = 2000 - 2 second timeout???
    call    Label_369		; Check d562 & if non-zero set d561

Label_81:
    ld      a,(0d550h)		; Top of loop
    and     a
    jp      z,Label_82		; Jump if pump is off
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370		; Jump if pump-jaw is opened

Label_82:
    ld      hl,(0d562h)
    ld      a,h
    or      l
    jp      z,Label_83		; Jump on a timeout
    ld      a,(0d5dbh)
    and     a
    jp      z,Label_81		; Loop back up to top of loop
    ld      a,(0d5dch)
    cp      06h
    jp      z,Label_84		; Jump if we got an ack
Label_83:
    ld      a,00h
    ld      (0d5dbh),a
    ld      (0d561h),a
    ld      a,(0dde7h)
    cp      02h
    jp      z,Label_85
    inc     a
    ld      (0dde7h),a
    jp      Label_78
Label_84:
    ld      a,00h
    ld      (0d5dbh),a
    and     a
    ret     

Label_85:
    ld      a,00h
    ld      (0dddfh),a
    scf				; Set carry flag
    ret     

;	Send "OK" via serial port

Label_86:
    ld      hl,8680h		; "OK"
    ld      de,0dde8h
    ld      bc,000ah
    ldir    
    call    Label_77		; Send msg via serial port
    ret     

;	Called by serial INT routine, Addr = 8503
;	Sends an ACK message (02 06 03)

Label_87:
    call    Label_89		; Wait for send complete
    ld      a,02h
    out     (2ah),a
    call    Label_89		; Wait for send complete
    ld      a,06h
    out     (2ah),a
    call    Label_89		; Wait for send complete
    ld      a,03h
    out     (2ah),a
    ret     

;	Called by ?????? routine, Addr = 0834
;	Sends an R message (02 'R' 03)

Label_88:
    call    Label_89		; Wait for send complete
    ld      a,02h
    out     (2ah),a
    call    Label_89		; Wait for send complete
    ld      a,52h
    out     (2ah),a
    call    Label_89		; Wait for send complete
    ld      a,03h
    out     (2ah),a
    ret

;	Waits for 'send complete' flag

Label_89:
    push    af
Label_90:
    in      a,(2bh)		; Read status register of serial port
    and     01h
    jp      z,Label_90
    pop     af
    ret     

;	NOT called by anyone

    call    Label_114		; Stage home, X0 command
    ret     

;	Write the 2-byte value at de58 out port 26

Label_91:
    ld      hl,(0de58h)
    in      a,(27h)
    ld      a,l
    out     (26h),a
    ld      a,h
    out     (26h),a
    ret     

;	Move the stage the # of counts in (DE4E)

Label_92:
    ld      hl,(0de4eh)
    ld      hl,(0de4eh)		; Where we want the stage to go
    ld      de,(0dde0h)		; Where the stage is currently at
    and     a
    sbc     hl,de
    jp      z,Label_93
    jp      p,Label_94
    jp      Label_95
Label_93:
    scf     
    ret     

Label_94:
    ld      a,00h		; hl > de
    ld      (0d567h),a
    ld      hl,(0de4eh)
    push    hl
    ld      de,(0dde0h)
    and     a
    sbc     hl,de
    ld      (0d568h),hl
    pop     hl
    ld      (0dde0h),hl
    and     a
    ret     

Label_95:
    ld      a,01h		; de > hl
    ld      (0d567h),a
    ld      hl,(0dde0h)
    ld      de,(0de4eh)
    and     a
    sbc     hl,de
    ld      (0d568h),hl
    ld      (0dde0h),de
    and     a
    ret     

;	Unknown function

Label_96:
    ld      a,(0d567h)
    and     a
    jp      nz,Label_97
    ld      a,(0d509h)
    res     1,a
    ld      (0d509h),a
    out     (8ah),a
    jp      Label_98

Label_97:
    ld      a,(0d509h)
    set     1,a
    ld      (0d509h),a
    out     (8ah),a

Label_98:
    ld      a,(0d574h)
    and     a
    jp      nz,Label_100
Label_99:
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE, even though it already is?
    ld      hl,(0d565h)
    ld      (0de58h),hl
    call    Label_91		; write word (DE58) out port 26
    ld      hl,0000h
    ld      (0d575h),hl
    jp      Label_101

Label_100:
    ld      hl,(0d565h)		; If (D574) is TRUE
    ld      de,(8691h)
    and     a
    sbc     hl,de
    jp      p,Label_99
    jp      z,Label_99
    ld      (0de58h),de		; Diff between current & desired location???
    call    Label_91		; write word (DE58) out port 26
    ld      hl,0001h
    ld      (0d575h),hl
    ld      hl,(0d568h)
    srl     h
    rr      l
    inc     hl
    ld      (0d56ah),hl
Label_101:
    ld      hl,0001h
    ld      (0d562h),hl		; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d564h),a		; Set (D564) TRUE
Label_102:
    ld      hl,(0d568h)
    ld      a,h
    or      l
    jp      nz,Label_102	; Wait for (D568) to tick down to 0
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ret     

Label_103:
    ld      a,(0d567h)
    and     a
    jp      nz,Label_104
    ld      a,(0d509h)
    res     1,a
    ld      (0d509h),a
    out     (8ah),a
    jp      Label_105

Label_104:
    ld      a,(0d509h)
    set     1,a
    ld      (0d509h),a
    out     (8ah),a

Label_105:
    ld      a,(0d574h)
    and     a
    jp      nz,Label_107
Label_106:
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE, even though it already is?
    ld      hl,(0d565h)
    ld      (0de58h),hl
    call    Label_91		; write word (DE58) out port 26
    ld      hl,0000h
    ld      (0d575h),hl
    jp      Label_108

Label_107:
    ld      hl,(0d565h)		; If (D574) is TRUE
    ld      de,(8691h)
    and     a
    sbc     hl,de
    jp      p,Label_106
    jp      z,Label_106
    ld      (0de58h),de
    call    Label_91		; write word (DE58) out port 26
    ld      hl,0001h
    ld      (0d575h),hl
    ld      hl,(0d568h)
    srl     h
    rr      l
    inc     hl
    ld      (0d56ah),hl
Label_108:
    ld      hl,0001h
    ld      (0d562h),hl		; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d564h),a		; Set (D564) TRUE
    ret     

;	Move stage

Label_109:
    in      a,(8ch)
    bit     3,a
    jp      z,Label_111		; Jump if in 24 column mode

;	Move stage in 12 column mode

    ld      hl,0000h
    ld      de,(0de50h)		; de = column # to move to
    and     a
    sbc     hl,de
    ret     p			; Leave if column # is negative
    ret     z			; or zero
    ld      hl,000ch
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     m			; Leave is column # is > 12
    in      a,(82h)
    push    af
    and     7fh
    ld      de,0000h
    ld      e,a
    ld      (0de54h),de		; Save port 82 in (de54) w/ mask 7F
    pop     af
    bit     7,a
    jp      z,Label_110
    ld      hl,0000h
    ld      de,(0de54h)		; Better way to do this section----------
    and     a
    sbc     hl,de
    ld      (0de54h),hl		; de now contains port 82 extended to 16 bits
Label_110:
    ld      ix,8691h		; 12-column move stage data table
    ld      hl,(0de50h)
    ld      (0dde3h),hl		; Set current column to (de50)
    add     hl,hl
    push    hl
    pop     de
    add     ix,de
    ld      l,(ix+00h)
    ld      h,(ix+01h)		; Put table value in hl
    ld      de,(0de54h)
    add     hl,de		; hl = table value + (de54)
    ld      de,(0d005h)
    add     hl,de		; hl = table value + (de54) + (d005)
    ld      de,(0de52h)		; Get offset
    add     hl,de		; hl = table value + (de54) + (d005) + (de52)
    ld      (0de4eh),hl		; (de4e) = hl
    call    Label_92
    jp      c,Label_113
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_96
    jp      Label_113

;	Move stage in 24 column mode

Label_111:
    ld      hl,0000h
    ld      de,(0de50h)		; de = column # to move to
    and     a
    sbc     hl,de
    ret     p			; Leave if column # is negative
    ret     z			; or zero
    ld      hl,0018h
    ld      de,(0de50h)
    and     a
    sbc     hl,de
    ret     m			; Leave is column # is > 24
    in      a,(84h)
    push    af
    and     7fh
    ld      de,0000h
    ld      e,a
    ld      (0de56h),de
    pop     af
    bit     7,a
    jp      z,Label_112
    ld      hl,0000h
    ld      de,(0de56h)
    and     a
    sbc     hl,de
    ld      (0de56h),hl
Label_112:
    ld      ix,86abh		; 24-column move stage data table
    ld      hl,(0de50h)
    ld      (0dde3h),hl		; Set current column to (de50)
    add     hl,hl
    push    hl
    pop     de
    add     ix,de
    ld      l,(ix+00h)
    ld      h,(ix+01h)		; Put table value in hl
    ld      de,(0de56h)
    add     hl,de		; hl = table value + (de56)
    ld      de,(0d007h)
    add     hl,de		; hl = table value + (de56) + (d007)
    ld      de,(0de52h)
    add     hl,de		; hl = table value + (de56) + (d007) + (de52)
    ld      (0de4eh),hl		; (de4e) = hl
    call    Label_92
    jp      c,Label_113
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_96
Label_113:
    ret				; Return from moving stage

;	Move stage home

Label_114:
    ld      a,01h
    ld      (0d52dh),a
    ld      hl,(0d565h)
    push    hl
    ld      hl,(0d52eh)
    ld      (0d530h),hl
    ld      a,01h
    ld      (0d52dh),a
    in      a,(8ch)
    bit     0,a
    jp      z,Label_116		; Jump if stage is not at home
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
Label_115:
    ld      a,01h
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,Label_370
    in      a,(8ch)
    bit     0,a
    jp      nz,Label_115	; Jump if stage is at home
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw

Label_116:
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
Label_117:
    in      a,(8ch)
    bit     0,a
    jp      z,Label_117
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      hl,0032h
    ld      (0d562h),hl		; (D562) = 50
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
Label_118:
    in      a,(8ch)
    bit     0,a
    jp      nz,Label_118
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d572h)
    ld      (0d565h),hl
    ld      hl,(0d52bh)
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
Label_119:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_119
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      hl,0000h
    ld      (0dde0h),hl		; Set current stage location to 0
    ld      a,00h
    ld      (0dde2h),a
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    pop     hl
    ld      (0d565h),hl
    ld      a,00h
    ld      (0d52dh),a
    ld      hl,0000h
    ld      (0dde3h),hl		; Set current column to 00
    ld      (0de52h),hl
    ret     

Label_120:
    in      a,(8ch)
    bit     0,a
    ret     z

    ld      a,01h
    ld      (0d567h),a
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
Label_121:
    ld      a,01h
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,Label_370
    in      a,(8ch)
    bit     0,a
    jp      nz,Label_121
    di      
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ei      
    ld      hl,15b8h
    ld      de,(0d568h)
    and     a
    sbc     hl,de
    push    hl
    pop     de
    ld      hl,(0dde0h)
    and     a
    sbc     hl,de
    ld      (0dde0h),hl
    ld      a,00h
    ld      (0dde2h),a
    ld      hl,0000h
    ld      (0dde3h),hl		; Set current column to 00
    ld      (0de52h),hl
    ret     

;	This is the X1 Command, go to start? Something to do with G

Label_122:
    in      a,(8ch)
    bit     1,a
    ret     z
    
    ld      a,00h
    ld      (0d567h),a
    ld      hl,15b8h
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103

Label_123:
    ld      a,02h		; Top of loop
    ld      (0d5b0h),a
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      z,Label_370
    in      a,(8ch)
    bit     1,a
    jp      nz,Label_123	; Loop till 8c:1 = 0
    di      
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ei      
    ld      hl,15b8h		; hl = 5560
    ld      de,(0d568h)
    and     a
    sbc     hl,de
    ld      de,(0dde0h)
    add     hl,de
    ld      (0dde0h),hl
    ld      a,01h
    ld      (0dde2h),a
    ld      hl,0019h
    ld      (0dde3h),hl		; Set current column to 25
    ld      hl,0000h
    ld      (0de52h),hl
    ret     

;	This is the X2 command, go to Waste? Something to do with 

Label_124:
    call    Label_120
    ld      hl,001ah
    ld      (0dde3h),hl		; Set current column to 26
    ld      hl,0000h
    ld      (0de52h),hl
    ret     
    ret

;	Run pump till volume in (D579-D57B) is dispensed

Label_125:
    ld      hl,(0d586h)		; Get PS setting
    ld      (0de58h),hl
    call    Label_91		; write word (DE58) out port 26

    ld      a,(0d578h)		; Get pump direction
    and     a
    jp      nz,Label_126	; Jump if direction is reverse to supply
    ld      a,(0d509h)
    res     3,a
    ld      (0d509h),a
    out     (8ah),a		; Clear 8a:3 if pump direction is dispense
    jp      Label_127

Label_126:
    ld      a,(0d509h)
    set     3,a
    ld      (0d509h),a
    out     (8ah),a		; Set 8a:3 if pump direction is reverse to supply

Label_127:
    ld      hl,0001h
    ld      (0d562h),hl	; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d577h),a		; Turn pump on

Label_128:
    ld      a,05h		; Top of loop
    ld      (0d5b0h),a		; Preset pump error to 5
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370		; Jump if pump-jaw is opened
    ld      hl,(0d579h)
    ld      a,h
    or      l
    jp      nz,Label_128	; Back to top if hl > 0
    ld      a,(0d57bh)
    and     a
    jp      z,Label_130		; If 0 then (D579-D57B) have ticked down, leave
    dec     a
    ld      (0d57bh),a

Label_129:
    ld      hl,(0d579h)		; (D57B) has ticked down to 0 wait for (D579-D57A)
    ld      a,h
    or      l			; This coding is done poorly!
    jp      z,Label_129
    jp      Label_128
Label_130:
    ld      a,00h
    ld      (0d577h),a
    ret     

;	Move pump in some fashion

Label_131:
    ld      hl,(0d586h)
    ld      (0de58h),hl
    call    Label_91		; write word (DE58) out port 26
    ld      a,(0d578h)		; Get pump direction
    and     a
    jp      nz,Label_132

    ld      a,(0d509h)		; Move forward
    res     3,a
    ld      (0d509h),a
    out     (8ah),a
    jp      Label_133

Label_132:
    ld      a,(0d509h)		; Move in reverse
    set     3,a
    ld      (0d509h),a
    out     (8ah),a

Label_133:
    ld      hl,0001h
    ld      (0d562h),hl	; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d577h),a
    ret     

;	Home Pump

Label_134:
    in      a,(8ch)
    bit     2,a
    jp      z,Label_135		; Jump if pump isn't at home
    ld      a,00h
    ld      (0d578h),a		; Move off home in forward direction
    ld      hl,0032h
    ld      (0d579h),hl		; Set pump volume to 50
    call    Label_125		; Go run pump for volume in (D579-D57B)

Label_135:
    ld      a,00h
    ld      (0d578h),a		; Move to home in forward direction
    ld      hl,07d0h
    ld      (0d579h),hl		; Set pump volume to 2000
    call    Label_131		; Move pump to home

Label_136:
    in      a,(8ch)
    bit     2,a
    jp      z,Label_136		; Wait forever for success
    ld      a,00h
    ld      (0d577h),a
    ret     

;	Create eprom revision string

Label_137:
    push    ix
    pop     de
    ld      hl,868dh		; '4.2@'
    ld      bc,0004h
    ldir    
    ret     

;	Create stage-at-home status string

Label_138:
    in      a,(8ch)
    bit     0,a
    jp      z,Label_139
    ld      (ix+00h),41h	; 'A0@'
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     
Label_139:
    ld      (ix+00h),41h	; 'A1@'
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

;	Create stage-at-start status string

Label_140:
    in      a,(8ch)
    bit     1,a
    jp      z,Label_141
    ld      (ix+00h),42h	; 'B0@'
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     
Label_141:
    ld      (ix+00h),42h	; 'B1@'
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

;	Create plate-type status string

Label_142:
    in      a,(8ch)
    bit     3,a
    jp      z,Label_143
    ld      (ix+00h),43h	; 'C0@'
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     
Label_143:
    ld      (ix+00h),43h	; 'C1@'
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

;	Create pump-jaw status string

Label_144:
    in      a,(8ch)
    bit     4,a
    jp      z,Label_145
    ld      (ix+00h),44h	; 'D0@'
    ld      (ix+01h),30h
    ld      (ix+02h),40h
    ret     
Label_145:
    ld      (ix+00h),44h	; 'D1@'
    ld      (ix+01h),31h
    ld      (ix+02h),40h
    ret     

;	Create stage position status string

Label_146:
    ld      (ix+00h),58h	; 'WX'
    ld      (ix+01h),57h
    push    ix
    ld      hl,(0dde3h)		; Get current column #
    ld      (0d598h),hl
    ld      a,00h
    ld      (0d59ah),a
    call    Label_474		; Convert column # to string
    pop     ix
    ld      a,(0d59fh)
    ld      (ix+02h),a
    ld      a,(0d59eh)
    ld      (ix+03h),a
    ld      hl,(0de52h)		; Get offset #
    ld      a,h
    bit     7,a
    jp      z,Label_147		; Jump if offset positive
    ld      a,2dh		; '-'
    ld      (ix+04h),a
    ld      hl,0000h
    ld      de,(0de52h)
    and     a
    sbc     hl,de		; Get absolute value of offset
    jp      Label_148
Label_147:
    ld      a,2bh		; '+'
    ld      (ix+04h),a
    ld      hl,(0de52h)
Label_148:
    push    ix
    ld      (0d598h),hl
    ld      a,00h
    ld      (0d59ah),a
    call    Label_474		; Convert offset # to string
    pop     ix
    ld      a,(0d5a0h)
    ld      (ix+05h),a
    ld      a,(0d59fh)
    ld      (ix+06h),a
    ld      a,(0d59eh)
    ld      (ix+07h),a
    ld      a,40h
    ld      (ix+08h),a
    ret     

;	Unknown function

Label_149:
    ld      a,00h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    set     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
Label_150:
    call    Label_172

Label_151:
    ld      a,81h		; Top of loop
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,Label_200
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     bc
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_150
    in      a,(3ch)		; Read in front panel keys
    bit     3,a
    jp      nz,Label_152	; Jump if U
    bit     4,a
    jp      nz,Label_157	; Jump if D
    bit     7,a
    jp      nz,Label_162	; Jump if F
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_163	; Jump if B
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_164		; (M) Mode
    cp      52h
    jp      z,Label_165		; (R) Reset
    cp      47h
    jp      z,Label_171		; (G) Start
    jp      Label_151		; Back to top of loop

;	Read in a U

Label_152:
    ld      hl,0000h
    ld      (0d51eh),hl
    call    Label_361
Label_153:
    ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54ch)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_155
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      m,Label_154
    inc     hl
    inc     hl
    inc     hl
    inc     hl
Label_154:
    inc     hl
    ld      (0d040h),hl
    jp      Label_156
Label_155:
    ld      hl,(0d54eh)
    ld      (0d040h),hl
    call    Label_172
Label_156:
    call    Label_172
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl		; Init (D524) timeout value to 200
    ld      hl,0032h
    ld      (0d522h),hl		; Init (D522) timeout value to 50
    call    Label_359
    in      a,(3ch)
    bit     3,a
    jp      nz,Label_153
    call    Label_338
    jp      Label_150

;	Read in a D

Label_157:
    ld      hl,0000h
    ld      (0d51eh),hl
    call    Label_361
Label_158:
    ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54eh)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_160
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_159
    jp      m,Label_159
    dec     hl
    dec     hl
    dec     hl
    dec     hl
Label_159:
    dec     hl
    ld      (0d040h),hl
    jp      Label_161
Label_160:
    ld      hl,(0d54ch)
    ld      (0d040h),hl
Label_161:
    call    Label_172
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl		; Init (D524) timeout value to 200
    ld      hl,0032h
    ld      (0d522h),hl		; Init (D522) timeout value to 50
    call    Label_359
    in      a,(3ch)
    bit     4,a
    jp      nz,Label_158
    call    Label_338
    jp      Label_150

;	Read in a F

Label_162:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_307
    jp      Label_151

;	Read in a B

Label_163:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_310
    jp      Label_151

;	Unknown function

Label_164:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_173
Label_165:
    call    Label_361
    ld      de,(0d040h)
    ld      hl,(0d54ch)
    and     a
    sbc     hl,de
    jp      z,Label_169
    ld      hl,(0d54ch)
Label_166:
    ld      bc,00c8h
    and     a
    sbc     hl,bc
    jp      z,Label_167
    jp      m,Label_167
    and     a
    push    hl
    sbc     hl,de
    pop     hl
    jp      z,Label_168
    jp      m,Label_168
    jp      Label_166

Label_167:
    ld      hl,0000h
Label_168:
    ld      de,00c8h
    add     hl,de
    ld      (0d040h),hl
    jp      Label_170

Label_169:
    ld      hl,(0d54eh)
    ld      (0d040h),hl
Label_170:
    call    Label_338
    call    Label_172
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_150

Label_171:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    Label_265
    ld      a,00h
    ld      (0d54bh),a
    jp      Label_150
Label_172:
    ld      hl,(0d040h)
    ld      a,h
    ld      (0d599h),a
    ld      a,l
    ld      (0d598h),a
    call    Label_467
    ld      a,(0d5a1h)
    ld      (0d510h),a
    ld      a,(0d5a0h)
    ld      (0d511h),a
    ld      a,(0d59fh)
    ld      (0d512h),a
    ld      a,(0d59eh)
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    ret     

Label_173:
    ld      a,01h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    res     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      hl,0000h
    ld      (0d50ch),hl
Label_174:
    call    Label_185
Label_175:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,Label_223
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_173
    in      a,(3ch)
    bit     3,a
    jp      nz,Label_181
    bit     4,a
    jp      nz,Label_183
    bit     7,a
    jp      nz,Label_176
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_177
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_178
    cp      43h
    jp      z,Label_180
    cp      47h
    jp      z,Label_179
    jp      Label_175

Label_176:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_307
    jp      Label_174

Label_177:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_310
    jp      Label_174

Label_178:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_186

Label_179:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    Label_265
    ld      a,00h
    ld      (0d54bh),a
    jp      Label_174

Label_180:
    call    Label_361
    ld      hl,0032h
    ld      (0d562h),hl		; (D562) = 50
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    xor     01h
    ld      (hl),a
    call    Label_338
    jp      Label_174

Label_181:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50ch)
    ld      bc,(0d517h)		; zero based column count
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_182
    inc     hl
    ld      (0d50ch),hl
    jp      Label_174

Label_182:
    ld      hl,(0d515h)
    ld      (0d50ch),hl
    jp      Label_174

Label_183:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50ch)
    ld      bc,(0d515h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_184
    dec     hl
    ld      (0d50ch),hl
    jp      Label_174
Label_184:
    ld      hl,(0d517h)		; zero based column count
    ld      (0d50ch),hl
    jp      Label_174
Label_185:
    ld      bc,(0d50ch)
    inc     bc
    ld      (0d598h),bc
    call    Label_467
    ld      a,(0d59fh)
    ld      (0d510h),a
    ld      a,(0d59eh)
    ld      (0d511h),a
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    ld      (0d598h),a
    call    Label_467
    ld      a,(0d59eh)
    ld      (0d513h),a
    ld      a,0ah
    ld      (0d512h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    ret     

Label_186:
    ld      a,02h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    res     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ah
    ld      (0d510h),a
    ld      (0d511h),a
    ld      (0d512h),a
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
Label_187:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,Label_186
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    cp      b
    jp      nz,Label_149
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_188
    cp      55h
    jp      z,Label_189
    cp      44h
    jp      z,Label_190
    jp      Label_187

Label_188:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_149

Label_189:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      Label_191

Label_190:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      Label_191
Label_191:
    call    Label_199
Label_192:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      nz,Label_237
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_149
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_193
    cp      43h
    jp      z,Label_194
    cp      55h
    jp      z,Label_195
    cp      44h
    jp      z,Label_197
    jp      Label_192

Label_193:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_149

Label_194:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_250

Label_195:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50eh)
    ld      bc,(0d51bh)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_196
    inc     hl
    ld      (0d50eh),hl
    jp      Label_191

Label_196:
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      Label_191

Label_197:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50eh)
    ld      bc,(0d519h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_198
    dec     hl
    ld      (0d50eh),hl
    jp      Label_191
Label_198:
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      Label_191
Label_199:
    ld      hl,(0d50eh)
    ld      (0d598h),hl
    call    Label_467
    ld      a,(0d59fh)
    ld      (0d511h),a
    ld      a,(0d59eh)
    ld      (0d512h),a
    ld      a,0fh
    ld      (0d510h),a
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    ret     

;	Unknown function

Label_200:
    ld      a,03h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    set     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a		; Set 38:0 & clear 38:1
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a		; Clear 3A:0
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a		; Set 3E:0
Label_201:
    call    Label_172

Label_202:
    ld      a,81h		; Top of loop
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_149
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_201
    in      a,(3ch)
    bit     3,a
    jp      nz,Label_203
    bit     4,a
    jp      nz,Label_208
    bit     7,a
    jp      nz,Label_213
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_214
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_215
    cp      52h
    jp      z,Label_216
    cp      47h
    jp      z,Label_222
    jp      Label_202		; Go to top of loop

Label_203:
    ld      hl,0000h
    ld      (0d51eh),hl
    call    Label_361
Label_204:
    ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54ch)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_206
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      m,Label_205
    inc     hl
    inc     hl
    inc     hl
    inc     hl
Label_205:
    inc     hl
    ld      (0d040h),hl
    jp      Label_207
Label_206:
    ld      hl,(0d54eh)
    ld      (0d040h),hl
Label_207:
    call    Label_172
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl		; Init (D524) timeout value to 200
    ld      hl,0032h
    ld      (0d522h),hl		; Init (D522) timeout value to 50
    call    Label_359
    in      a,(3ch)
    bit     3,a
    jp      nz,Label_204
    call    Label_338
    jp      Label_201
Label_208:
    ld      hl,0000h
    ld      (0d51eh),hl
    call    Label_361
Label_209:
    ld      hl,(0d51eh)
    inc     hl
    ld      (0d51eh),hl
    ld      hl,(0d040h)
    ld      de,(0d54eh)
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_211
    ld      de,0064h
    push    hl
    and     a
    sbc     hl,de
    pop     hl
    jp      z,Label_210
    jp      m,Label_210
    dec     hl
    dec     hl
    dec     hl
    dec     hl
Label_210:
    dec     hl
    ld      (0d040h),hl
    jp      Label_212
Label_211:
    ld      hl,(0d54ch)
    ld      (0d040h),hl
Label_212:
    call    Label_172
    ld      hl,000ah
    ld      (0d520h),hl
    ld      hl,00c8h
    ld      (0d524h),hl		; Init (D524) timeout value to 200
    ld      hl,0032h
    ld      (0d522h),hl		; Init (D522) timeout value to 50
    call    Label_359
    in      a,(3ch)
    bit     4,a
    jp      nz,Label_209
    call    Label_338
    jp      Label_201

Label_213:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d560h),a
    jp      Label_202		; Go to top of loop

Label_214:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d560h),a
    jp      Label_202		; Go to top of loop

Label_215:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_223

Label_216:
    call    Label_361
    ld      de,(0d040h)
    ld      hl,(0d54ch)
    and     a
    sbc     hl,de
    jp      z,Label_220
    ld      hl,(0d54ch)
Label_217:
    ld      bc,00c8h
    and     a
    sbc     hl,bc
    jp      z,Label_218
    jp      m,Label_218
    and     a
    push    hl
    sbc     hl,de
    pop     hl
    jp      z,Label_219
    jp      m,Label_219
    jp      Label_217

Label_218:
    ld      hl,0000h
Label_219:
    ld      de,00c8h
    add     hl,de
    ld      (0d040h),hl
    jp      Label_221

Label_220:
    ld      hl,0002h
    ld      (0d040h),hl
Label_221:
    call    Label_338
    call    Label_172
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_201

Label_222:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d551h),a
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d54bh),a
    jp      Label_201
Label_223:
    ld      a,04h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    res     0,a
    set     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    res     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      hl,0000h
    ld      (0d50ch),hl
Label_224:
    call    Label_185
Label_225:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_173
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_223
    in      a,(3ch)
    bit     3,a
    jp      nz,Label_231
    bit     4,a
    jp      nz,Label_234
    bit     7,a
    jp      nz,Label_226
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_227
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_228
    cp      43h
    jp      z,Label_230
    cp      47h
    jp      z,Label_229
    jp      Label_225

Label_226:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d560h),a
    jp      Label_224

Label_227:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d560h),a
    jp      Label_224

Label_228:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_237

Label_229:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d551h),a
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d54bh),a
    jp      Label_224

Label_230:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,0d042h
    ld      bc,(0d50ch)
    add     hl,bc
    ld      a,(hl)
    xor     01h
    ld      (hl),a
    call    Label_338
    jp      Label_224

Label_231:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50ch)
    ld      bc,(0d517h)		; zero based column count
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_232
    inc     hl
    ld      (0d50ch),hl
    jp      Label_233
Label_232:
    ld      hl,(0d515h)
    ld      (0d50ch),hl
Label_233:
    jp      Label_224

Label_234:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50ch)
    ld      bc,(0d515h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_235
    dec     hl
    ld      (0d50ch),hl
    jp      Label_236
Label_235:
    ld      hl,(0d517h)		; zero based column count
    ld      (0d50ch),hl
Label_236:
    jp      Label_224
Label_237:
    ld      a,05h
    ld      (0d001h),a
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    ld      a,(0d500h)
    res     0,a
    res     1,a
    ld      (0d500h),a
    out     (38h),a
    ld      a,(0d501h)
    set     0,a
    ld      (0d501h),a
    out     (3ah),a
    ld      a,(0d503h)
    set     0,a
    ld      (0d503h),a
    out     (3eh),a
    ld      a,0ah
    ld      (0d510h),a
    ld      (0d511h),a
    ld      (0d512h),a
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
Label_238:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_186
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    cp      b
    jp      nz,Label_200
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_239
    cp      55h
    jp      z,Label_240
    cp      44h
    jp      z,Label_241
    jp      Label_238

Label_239:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_200

Label_240:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      Label_242

Label_241:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      Label_242
Label_242:
    call    Label_199
Label_243:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_186
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_200
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      4dh
    jp      z,Label_244
    cp      43h
    jp      z,Label_245
    cp      55h
    jp      z,Label_246
    cp      44h
    jp      z,Label_248
    jp      Label_243

Label_244:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_200

Label_245:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_250

Label_246:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 200
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50eh)
    ld      bc,(0d51bh)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_247
    inc     hl
    ld      (0d50eh),hl
    jp      Label_242
Label_247:
    ld      hl,(0d519h)
    ld      (0d50eh),hl
    jp      Label_242

Label_248:
    call    Label_361
    ld      hl,00c8h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d50eh)
    ld      bc,(0d519h)
    push    hl
    and     a
    sbc     hl,bc
    pop     hl
    jp      z,Label_249
    dec     hl
    ld      (0d50eh),hl
    jp      Label_242

Label_249:
    ld      hl,(0d51bh)
    ld      (0d50eh),hl
    jp      Label_242

Label_250:
    ld      a,0bh
    ld      (0d510h),a
    ld      a,1dh
    ld      (0d511h),a
    ld      a,7eh
    ld      (0d512h),a
    ld      a,3dh
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
Label_251:
    ld      a,(0d001h)
    cp      05h
    jp      z,Label_252
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_253
Label_252:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_186
Label_253:
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_149
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      43h
    jp      z,Label_254
    cp      47h
    jp      z,Label_255
    jp      Label_251

Label_254:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    jp      Label_257

Label_255:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,0d05ah
    ld      de,001ah
    ld      bc,(0d50eh)
    ld      a,c
    ld      b,a
Label_256:
    add     hl,de
    djnz    Label_256
    ld      de,0d040h
    ld      bc,001ah
    ldir    
    call    Label_338
    jp      Label_149
Label_257:
    ld      a,57h
    ld      (0d510h),a
    ld      a,7eh
    ld      (0d511h),a
    ld      a,3bh
    ld      (0d512h),a
    ld      a,4fh
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
Label_258:
    ld      a,(0d001h)
    cp      05h
    jp      z,Label_259
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_260
Label_259:
    ld      a,81h
    out     (2fh),a
    in      a,(2fh)
    and     40h
    jp      z,Label_186
Label_260:
    ld      a,(0dddfh)
    and     a
    call    nz,Label_27		; Call if processing message buffer valid
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     af
    ld      b,a
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_149
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      43h
    jp      z,Label_261
    cp      47h
    jp      z,Label_263
    jp      Label_258

Label_261:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,(0d001h)
    cp      05h
    jp      z,Label_262
    jp      Label_191
Label_262:
    jp      Label_242

Label_263:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,0d05ah
    ld      de,001ah
    ld      a,(0d50eh)
    ld      b,a
Label_264:
    add     hl,de
    djnz    Label_264
    ld      a,l
    ld      e,a
    ld      a,h
    ld      d,a
    ld      hl,0d040h
    ld      bc,001ah
    ldir    
    call    Label_460		; Tweaks ports 10-12 w/ 13 ctrl
    jp      Label_149
Label_265:
    ld      a,(0d588h)
    and     a
    call    nz,Label_313
    ld      a,03h
    ld      (0d5b0h),a
    ld      a,(0d514h)
    push    af
    call    Label_340
    pop     bc
    ld      a,(0d514h)
    xor     b
    jp      nz,Label_370
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370
    ld      a,(0d532h)
    cp      00h
    jp      z,Label_266
    cp      01h
    jp      z,Label_268
    cp      02h
    jp      z,Label_270
    cp      03h
    jp      z,Label_275
    cp      04h
    jp      z,Label_277
    cp      05h
    jp      z,Label_280
    cp      06h
    jp      z,Label_282
    cp      07h
    jp      z,Label_284
    cp      08h
    jp      z,Label_289
    cp      09h
    jp      z,Label_291
    cp      0ah
    jp      z,Label_293
    cp      0bh
    jp      z,Label_296
    cp      0ch
    jp      z,Label_298
    cp      0dh
    jp      z,Label_300
    cp      0eh
    jp      z,Label_304
    cp      0fh
    jp      z,Label_306
    ret     

Label_266:
    call    Label_267
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_267:
    ld      hl,0000h
    ld      (0d533h),hl
    call    Label_465
    ret     

Label_268:
    call    Label_269
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_269:
    call    Label_114		; Stage home, X0 command
    ret     

Label_270:
    call    Label_271
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_271:
    ld      hl,(0d003h)
    ld      (0d586h),hl
    call    Label_134
    ld      a,00h
    ld      (0d578h),a		; Set pump direction to dispense
    ld      hl,(0d003h)
    ld      (0d586h),hl
    ld      hl,0190h
    ld      (0d579h),hl		; Set pump volume to 400
    ld      a,00h
    ld      (0d57bh),a
    call    Label_131

Label_272:
    ld      hl,(0d579h)		; Top of loop
    ld      a,l
    or      h
    jp      z,Label_273
    jp      Label_272
Label_273:
    ld      a,(0d57bh)
    and     a
    jp      z,Label_274		; Jump out of loop if (D579 - D57B) has ticked down to 0
    dec     a
    ld      (0d57bh),a
    jp      Label_272
Label_274:
    ld      a,00h
    ld      (0d577h),a		; Turn pump off
    ret     

Label_275:
    call    Label_276
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_276:
    ret     

Label_277:
    call    Label_279
    jp      c,Label_278
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_278:
    ld      a,07h
    ld      (0d532h),a
    jp      Label_265
Label_279:
    ld      hl,0d042h
    ld      bc,(0d533h)
    add     hl,bc
    ld      a,(hl)
    and     a
    ret     nz

    scf     
    ret     

Label_280:
    call    Label_281
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_281:
    ld      hl,(0d533h)
    inc     hl
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    Label_109		; Go move stage
    ret     

;	Unknown pump function

Label_282:
    call    Label_283
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265

Label_283:
    ld      hl,(0d535h)
    ld      (0d562h),hl		; (D562) = (D535)
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d003h)
    ld      (0d586h),hl
    ld      hl,(0d589h)
    ld      (0d579h),hl
    ld      a,(0d58bh)
    ld      (0d57bh),a		; Set 
    call    Label_125		; Go run pump for volume in (D579-D57B)
    ld      hl,(0d537h)
    ld      (0d562h),hl		; (D562) = (D537)
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_284:
    call    Label_287
    jp      c,Label_285
    ld      a,04h
    ld      (0d532h),a
    jp      Label_265
Label_285:
    ld      a,(0d514h)
    and     a
    jp      nz,Label_286
    ld      a,0eh
    ld      (0d532h),a
    jp      Label_265
Label_286:
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_287:
    ld      hl,(0d517h)		; zero based column count
    ld      bc,(0d533h)
    and     a
    sbc     hl,bc
    jp      z,Label_288
    inc     bc
    ld      (0d533h),bc
    and     a
    ret     

Label_288:
    scf     
    ret     

Label_289:
    call    Label_290
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_290:
    call    Label_122		; X1 Command
    ld      hl,00fah
    ld      (0d562h),hl		; (D562) = 250
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_291:
    call    Label_292
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_292:
    ret     

Label_293:
    call    Label_295
    jp      c,Label_294
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_294:
    ld      a,0dh
    ld      (0d532h),a
    jp      Label_265
Label_295:
    ld      hl,0d042h
    ld      bc,(0d533h)
    add     hl,bc
    ld      a,(hl)
    and     a
    ret     nz

    scf     
    ret     

Label_296:
    call    Label_297
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_297:
    ld      hl,(0d533h)
    inc     hl
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    Label_109		; Go move stage
    ret     

Label_298:
    call    Label_299
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_299:
    call    Label_283
    ret     

Label_300:
    call    Label_302
    jp      c,Label_301
    ld      a,0ah
    ld      (0d532h),a
    jp      Label_265
Label_301:
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_302:
    ld      hl,(0d515h)
    ld      bc,(0d533h)
    and     a
    sbc     hl,bc
    jp      z,Label_303
    dec     bc
    ld      (0d533h),bc
    and     a
    ret     

Label_303:
    scf     
    ret     

Label_304:
    call    Label_305
    ld      a,(0d532h)
    inc     a
    ld      (0d532h),a
    jp      Label_265
Label_305:
    call    Label_114		; Stage home, X0 command
    ret     

Label_306:
    ld      a,(0d5dah)
    and     a
    ret     z

    ld      a,(0d001h)
    cp      00h
    call    z,Label_172
    cp      01h
    call    z,Label_185
    ld      a,00h
    ld      (0d532h),a
    jp      Label_265
Label_307:
    ld      a,04h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     0,a
    jp      nz,Label_370
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370
Label_308:
    ld      a,00h
    ld      (0d578h),a		; Set pump direction to dispense
    ld      hl,(0d580h)
    ld      (0d586h),hl
    call    Label_131
Label_309:
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370
    in      a,(3ch)
    bit     7,a
    jp      nz,Label_309
    ld      a,00h
    ld      (0d577h),a
    ret     

Label_310:
    ld      a,04h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     0,a
    jp      nz,Label_370
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370
Label_311:
    ld      a,01h
    ld      (0d578h),a		; Set pump direction to reverse to supply
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    call    Label_131
Label_312:
    ld      a,05h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      z,Label_370
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_312
    ld      a,00h
    ld      (0d577h),a
    ret     

Label_313:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    Label_364		; Set 3e:1 store in d503
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
Label_314:
    ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
Label_315:
    ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
Label_316:
    ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    Label_316
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    Label_315
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    Label_314
    call    Label_365		; Clear 3e:1 store in d503
Label_317:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      z,Label_318
    cp      52h
    jp      z,Label_319
    jp      Label_317
Label_318:
    call    Label_361
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

Label_319:
    call    Label_361
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    call    Label_114		; Stage home, X0 command
    pop     af
    ret     

    push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    Label_364		; Set 3e:1 store in d503
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
Label_320:
    ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
Label_321:
    ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
Label_322:
    ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    Label_322
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    Label_321
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    Label_320
    call    Label_365		; Clear 3e:1 store in d503
Label_323:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      z,Label_324
    cp      52h
    jp      z,Label_325
    jp      Label_323
Label_324:
    call    Label_361
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

Label_325:
    call    Label_361
    ld      a,10h
    ld      (0d551h),a
    ld      a,00h
    ld      (0d588h),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

Label_326:
    push    af
    push    bc
    push    de
    push    hl
    ld      a,00h
    ld      (0d52dh),a
    ld      a,(0d501h)
    set     1,a
    ld      (0d501h),a
    out     (3ah),a
    call    Label_364		; Set 3e:1 store in d503
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      (0d528h),a
    ld      b,a
Label_327:
    ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
Label_328:
    ld      a,b
    ld      (0d527h),a
    ld      a,(0d528h)
    ld      b,a
Label_329:
    ld      a,b
    ld      (0d528h),a
    ld      a,(0d528h)
    ld      b,a
    djnz    Label_329
    ld      a,01h
    ld      (0d528h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    Label_328
    ld      a,7fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    Label_327
    call    Label_365		; Clear 3e:1 store in d503
Label_330:
    ld      a,(0de5ah)
    and     a
    jp      z,Label_331
    ld      a,(0de5bh)
    and     a
    jp      nz,Label_332
    jp      Label_330
Label_331:
    pop     hl
    pop     de
    pop     bc
    pop     af
    ret     

Label_332:
    ld      a,00h
    ld      (0de5bh),a
    ld      (0de5ah),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    call    Label_114		; Stage home, X0 command
    ld      a,00h
    ld      (0dddfh),a		; Done with process message buffer
    ret     

;	Initializes a bunch of stuff; called from hw reset & 2 other places

Label_333:
    ld      hl,0d000h
    ld      de,0d4ffh
Label_334:
    ld      a,00h		; Top of loop, zero out D000 - D4FE (bug?)
    ld      (hl),a
    and     a
    inc     hl
    push    hl
    sbc     hl,de
    pop     hl
    jp      nz,Label_334		; Loop back up
    ld      a,0aah
    ld      (0d000h),a		; Set D000 to AA
    ld      a,00h
    ld      (0d001h),a		; Clear D0001
    ld      hl,0005h
    ld      (0d040h),hl		; Create a 26 byte buffer
    ld      a,18h		;	The first word is set to 5
    ld      b,a			;	The following 24 bytes are set to 1
    ld      a,01h		; Then make 20 copies of the buffer
    ld      ix,0d042h		; One after the other.
Label_335:
    ld      (ix+00h),a		; From D040 to D261 for a total of 546 bytes (222h)
    inc     ix
    djnz    Label_335		; Make Original
    ld      hl,0d040h
    ld      de,0d05ah
    ld      bc,001ah
    ldir			; Copy 1
    ld      hl,0d040h
    ld      de,0d074h
    ld      bc,001ah
    ldir			; Copy 2
    ld      hl,0d040h
    ld      de,0d08eh
    ld      bc,001ah
    ldir			; Copy 3
    ld      hl,0d040h
    ld      de,0d0a8h
    ld      bc,001ah
    ldir			; Copy 4
    ld      hl,0d040h
    ld      de,0d0c2h
    ld      bc,001ah
    ldir			; Copy 5
    ld      hl,0d040h
    ld      de,0d0dch
    ld      bc,001ah
    ldir			; Copy 6
    ld      hl,0d040h
    ld      de,0d0f6h
    ld      bc,001ah
    ldir			; Copy 7
    ld      hl,0d040h
    ld      de,0d110h
    ld      bc,001ah
    ldir			; Copy 8
    ld      hl,0d040h
    ld      de,0d12ah
    ld      bc,001ah
    ldir			; Copy 9
    ld      hl,0d040h
    ld      de,0d144h
    ld      bc,001ah
    ldir			; Copy 10
    ld      hl,0d040h
    ld      de,0d15eh
    ld      bc,001ah
    ldir			; Copy 11
    ld      hl,0d040h
    ld      de,0d178h
    ld      bc,001ah
    ldir			; Copy 12
    ld      hl,0d040h
    ld      de,0d192h
    ld      bc,001ah
    ldir			; Copy 13
    ld      hl,0d040h
    ld      de,0d1ach
    ld      bc,001ah
    ldir			; Copy 14
    ld      hl,0d040h
    ld      de,0d1c6h
    ld      bc,001ah
    ldir			; Copy 15
    ld      hl,0d040h
    ld      de,0d1e0h
    ld      bc,001ah
    ldir			; Copy 16
    ld      hl,0d040h
    ld      de,0d1fah
    ld      bc,001ah
    ldir			; Copy 17
    ld      hl,0d040h
    ld      de,0d214h
    ld      bc,001ah
    ldir			; Copy 18
    ld      hl,0d040h
    ld      de,0d22eh
    ld      bc,001ah
    ldir			; Copy 19
    ld      hl,0d040h
    ld      de,0d248h
    ld      bc,001ah
    ldir			; Copy 20 - Twenty-one all together
    ld      a,01h
    ld      (0d002h),a		; Initialize d002 to 1
    ld      hl,(0d580h)
    ld      (0d003h),hl
    ld      hl,0000h
    ld      (0d005h),hl
    ld      (0d007h),hl
    call    Label_460		; Go manipulate ports 10 - 13
    ret     

;	Program port 80 w/ 81 = 98

Label_336:
    ld      a,98h
    out     (81h),a		; 81 = 98
    ld      a,(0d510h)
    or      80h
    out     (80h),a		; 80 = (d511),(d512),(d513),80,80,80,80,80
    ld      a,(0d511h)
    or      80h
    out     (80h),a
    ld      a,(0d512h)
    or      80h
    out     (80h),a
    ld      a,(0d513h)
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ret     

;	Program port 80 w/ 81 = b8

Label_337:
    ld      a,0b8h
    out     (81h),a		; 81 = b8
    ld      a,(0d510h)
    or      80h
    out     (80h),a		; 80 = (d511),(d512),(d513),80,80,80,80,80
    ld      a,(0d511h)
    or      80h
    out     (80h),a
    ld      a,(0d512h)
    or      80h
    out     (80h),a
    ld      a,(0d513h)
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ld      a,00h
    or      80h
    out     (80h),a
    ret     

Label_338:
    ld      a,(0d514h)
    and     a
    jp      nz,Label_339
    ld      hl,0d040h
    ld      de,0d05ah
    ld      bc,001ah
    ldir    
    call    Label_460		; Tweaks ports 10-12 w/ 13 ctrl
    ret     

Label_339:
    ld      hl,0d040h
    ld      de,0d15eh
    ld      bc,001ah
    ldir    
    call    Label_460		; Tweaks ports 10-12 w/ 13 ctrl
    ret     

;	Unknown function

Label_340:
    call    Label_342
    in      a,(8ch)
    bit     3,a
    jp      nz,Label_341		; Jump if 12 columns
    ld      a,01h		; 24 Columns
    ld      (0d514h),a
    ld      hl,0000h
    ld      (0d515h),hl
    ld      hl,0017h
    ld      (0d517h),hl		; zero based column count
    ld      hl,000bh
    ld      (0d519h),hl
    ld      hl,0013h
    ld      (0d51bh),hl
    ld      a,(0d501h)
    res     4,a
    set     5,a
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,0d15eh
    ld      de,0d040h
    ld      bc,001ah
    ldir			; Copy buffer 11 to buffer 0
    ret     

Label_341:
    ld      a,00h		; 12 Columns
    ld      (0d514h),a
    ld      hl,0000h
    ld      (0d515h),hl
    ld      hl,000bh
    ld      (0d517h),hl		; zero based column count
    ld      hl,0001h
    ld      (0d519h),hl
    ld      hl,0009h
    ld      (0d51bh),hl
    ld      a,(0d501h)
    set     4,a
    res     5,a
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,0d05ah
    ld      de,0d040h
    ld      bc,001ah
    ldir			; Copy buffer 1 to buffer 0
    ret     

;	Unknown function - cares about plate-type

Label_342:
    ld      a,(0d514h)
    and     a
    jp      nz,Label_344
    jp      Label_343
Label_343:
    in      a,(8ch)
    bit     3,a
    ret     nz			; Leave if plate-type = 12 column
    jp      Label_345

Label_344:
    in      a,(8ch)		; If D514 <> 0
    bit     3,a
    ret     z
    jp      Label_345

Label_345:
    ld      hl,0063h		; (!(D514) && !(8C:3)) || (D514 && 8C:3)
    ld      (0dde3h),hl		; Set current column # to 99?
    ld      hl,0000h
    ld      (0de52h),hl
    ret     

;	Reads in front panel keys - I think.
;	Look at all the bits of port 3c, and bit 3 of port 3d
;	Depending on the bit/port stuff a letter into d51d and
;	wait for bit 3 of the port to go low

Label_346:
    ld      a,00h
    ld      (0d51dh),a		; Set d51d = 0
    in      a,(3ch)
    bit     0,a
    jp      nz,Label_349
    bit     1,a
    jp      nz,Label_350
    bit     2,a
    jp      nz,Label_351
    bit     3,a
    jp      nz,Label_352
    bit     4,a
    jp      nz,Label_353
    bit     5,a
    jp      nz,Label_354
    bit     6,a
    jp      nz,Label_355
    bit     7,a
    jp      nz,Label_356
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_357
    ret     

Label_347:
    ld      hl,0001h		; Top of loop
    ld      (0d562h),hl		; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    in      a,(3ch)
    and     a
    jp      nz,Label_347		; Loop forever till 3c:3 = 0
    ret     

Label_348:
    ld      hl,0001h		; Top of loop
    ld      (0d562h),hl		; (D562) = 1
    call    Label_366		; Look at pump and pump-jaw
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_348	; Loop forever till 3e:3 = 0
    ret     

;	Looks like ASCII - Stuff a letter into d51d, wait for bit 3 to go 0

Label_349:
    ld      a,4dh		; 3c:0	M
    ld      (0d51dh),a
    jp      Label_347
Label_350:
    ld      a,52h		; 3c:1	R
    ld      (0d51dh),a
    jp      Label_347
Label_351:
    ld      a,43h		; 3c:2	C
    ld      (0d51dh),a
    jp      Label_347
Label_352:
    ld      a,55h		; 3c:3	U
    ld      (0d51dh),a
    jp      Label_347
Label_353:
    ld      a,44h		; 3c:4	D
    ld      (0d51dh),a
    jp      Label_347
Label_354:
    ld      a,47h		; 3c:5	G
    ld      (0d51dh),a
    jp      Label_347
Label_355:
    ld      a,53h		; 3c:6	S
    ld      (0d51dh),a
    jp      Label_347
Label_356:
    ld      a,46h		; 3c:7	F
    ld      (0d51dh),a
    jp      Label_347
Label_357:
    ld      a,42h		; 3e:3	B
    ld      (0d51dh),a
    jp      Label_348

;	Same as 2599 except don't look at 3e:3 or 3c:3/4

Label_358:
    ld      a,00h
    ld      (0d51dh),a
    in      a,(3ch)
    bit     0,a
    jp      nz,Label_349
    bit     1,a
    jp      nz,Label_350
    bit     2,a
    jp      nz,Label_351
    bit     5,a
    jp      nz,Label_354
    bit     6,a
    jp      nz,Label_355
    bit     7,a
    jp      nz,Label_356
    ret     

;	Unknown Function

Label_359:
    ld      hl,(0d51eh)
    ld      bc,(0d520h)
    and     a
    sbc     hl,bc
    jp      p,Label_360
    ld      hl,(0d524h)
    ld      (0d562h),hl		; (D562) = (D524)
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_360:
    ld      hl,(0d522h)
    ld      (0d562h),hl		; (D562) = (D522)
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_361:
    call    Label_364		; Set 3e:1 store in d503
    ld      a,0ffh
    ld      (0d526h),a
    ld      (0d527h),a
    ld      b,a
Label_362:
    ld      a,b
    ld      (0d526h),a
    ld      a,(0d527h)
    ld      b,a
Label_363:
    ld      a,b
    ld      (0d527h),a
    ld      a,(0d527h)
    ld      b,a
    djnz    Label_363
    ld      a,0fh
    ld      (0d527h),a
    ld      a,(0d526h)
    ld      b,a
    djnz    Label_362
    call    Label_365		; Clear 3e:1 store in d503
    ret     

;	Sets bit 1 in d503 and outputs to 3e

Label_364:
    ld      a,(0d503h)
    set     1,a
    ld      (0d503h),a
    out     (3eh),a
    ret     

;	Clears bit 1 in d503 and outputs to 3e

Label_365:
    ld      a,(0d503h)
    res     1,a
    ld      (0d503h),a
    out     (3eh),a
    ret     

;	This looks at the pump and pump-jaw sensor

Label_366:
    ld      hl,(0d562h)
    ld      a,l
    or      h
    ret     z			; If counter, (D562), is zero, leave
    ld      a,01h		; Else set d561 to TRUE
    ld      (0d561h),a

Label_367:
    ld      a,(0d550h)		; Start of loop, look at pump
    and     a
    jp      z,Label_368		; Jump if pump is off
    ld      a,05h		; preset error 5 incase pump-jaw is open
    ld      (0d5b0h),a
    in      a,(8ch)		; Look at pump-jaw sensor
    bit     4,a
    jp      z,Label_370		; Go send 'E05' message if pump jaw opened
Label_368:
    ld      hl,(0d562h)
    ld      a,l
    or      h
    jp      nz,Label_367	; if (D562) is non-zero, Go back and look at pump
    ld      a,00h
    ld      (0d561h),a		; Set d561 to FALSE
    ret     

;	Checks (D562).  If it is non-zero sets (D561) True

Label_369:
    ld      hl,(0d562h)
    ld      a,l
    or      h
    ret     z
    ld      a,01h
    ld      (0d561h),a
    ret     

;	Send error message and .....

Label_370:
    ld      a,(0de5ch)
    and     a
    jp      nz,Label_396	; Send error message "E0n"
    ld      a,01h
    ld      (0d52dh),a
    ld      a,(0d5b0h)
    cp      01h
    jp      z,Label_372
    cp      02h
    jp      z,Label_372
    cp      03h
    jp      z,Label_372
    cp      04h
    jp      z,Label_376
    cp      05h
    jp      z,Label_372
    cp      06h
    jp      z,Label_373
Label_371:
    jp      Label_371

Label_372:
    ld      a,00h		; if d5b0 is 1,2,3,or5
    ld      (0d564h),a		; Set (D564) FALSE
    ld      (0d577h),a
    ld      a,00h
    ld      (0d550h),a		; Clear 'pump on' flag
    call    Label_382
    call    Label_364		; Set 3e:1 store in d503
    call    Label_384
    call    Label_374
    call    Label_375
    ld      hl,0064h
    ld      (0d562h),hl		; (D562) = 100
    call    Label_366		; Look at pump and pump-jaw
    di      
    nop     
    jp      0000h		; Restart the firmware

Label_373:
    call    Label_382		; if d5b0 is 6
    call    Label_364		; Set 3e:1 store in d503
    ld      a,4fh
    ld      (0d510h),a
    ld      a,7bh
    ld      (0d511h),a
    ld      a,7bh
    ld      (0d512h),a
    ld      a,57h
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
    call    Label_374
    call    Label_375
    ld      hl,0064h
    ld      (0d562h),hl		; (D562) = 100
    call    Label_366		; Look at pump and pump-jaw
    ret     

Label_374:
    in      a,(3ch)
    and     40h
    jp      z,Label_374
    call    Label_365		; Clear 3e:1 store in d503
    ret     

Label_375:
    in      a,(3ch)
    and     02h
    jp      z,Label_375
    call    Label_361
    call    Label_383
    ret     

Label_376:
    call    Label_382		; if d5b0 is 1,2,3,or5
    call    Label_364		; Set 3e:1 store in d503
    ld      a,4bh
    ld      (0d510h),a
    ld      a,7bh
    ld      (0d511h),a
    ld      a,7bh
    ld      (0d512h),a
    ld      a,30h
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
    call    Label_377
    jp      Label_378
Label_377:
    in      a,(3ch)
    and     40h
    jp      z,Label_377
    call    Label_365		; Clear 3e:1 store in d503
    ret     

Label_378:
    in      a,(3ch)
    bit     1,a
    jp      nz,Label_379
    bit     7,a
    jp      nz,Label_380
    in      a,(3eh)
    bit     3,a
    jp      nz,Label_381
    jp      Label_378
Label_379:
    call    Label_361
    call    Label_383
    di      
    nop     
    jp      0000h
Label_380:
    call    Label_361
    call    Label_383
    jp      Label_308
Label_381:
    call    Label_361
    call    Label_383
    jp      Label_311
Label_382:
    ld      a,(0d501h)
    set     6,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

Label_383:
    ld      a,(0d501h)
    res     6,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

Label_384:
    ld      a,0bh
    ld      (0d510h),a
    ld      a,00h
    ld      (0d511h),a
    ld      hl,0000h
    ld      a,(0d5b0h)
    ld      l,a
    ld      (0d598h),hl
    call    Label_467
    ld      a,(0d59fh)
    ld      (0d512h),a
    ld      a,(0d59eh)
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    ret     

    ld      a,01h
    ld      (0d52dh),a
    ld      a,(0d5b1h)
    cp      01h
    jp      z,Label_385
    ret     

Label_385:
    call    Label_388
    call    Label_364		; Set 3e:1 store in d503
    call    Label_390
    call    Label_386
    call    Label_387
    di      
    jp      0000h
Label_386:
    in      a,(3ch)
    and     40h
    jp      z,Label_386
    call    Label_365		; Clear 3e:1 store in d503
    ret     

Label_387:
    in      a,(3ch)
    and     02h
    jp      z,Label_387
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_389
    ret     

Label_388:
    ld      a,(0d501h)
    set     7,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

Label_389:
    ld      a,(0d501h)
    res     7,a
    ld      (0d501h),a
    out     (3ah),a
    ret     

Label_390:
    ld      a,68h
    out     (81h),a
    ret     

    ld      a,00h
    ld      (0d5b2h),a
    ld      a,01h
    ld      (0d52dh),a
    ld      hl,0005h
    ld      (0d562h),hl		; (D562) = 5
    call    Label_366		; Look at pump and pump-jaw
    in      a,(2ah)
    cp      31h
    jp      z,Label_391
    cp      32h
    jp      z,Label_391
    cp      33h
    jp      z,Label_391
    cp      34h
    jp      z,Label_391
    cp      35h
    jp      z,Label_391
    cp      36h
    jp      z,Label_391
    cp      37h
    jp      z,Label_392
    cp      38h
    jp      z,Label_391
    ret     

Label_391:
    call    Label_382
    call    Label_364		; Set 3e:1 store in d503
    call    Label_395
    call    Label_393
    call    Label_394
    ld      hl,0064h
    ld      (0d562h),hl		; (D562) = 100
    call    Label_366		; Look at pump and pump-jaw
    di      
    nop     
    jp      0000h
Label_392:
    ld      a,00h
    ld      (0d52dh),a
    ld      a,01h
    ld      (0d5b3h),a
    ret     

Label_393:
    in      a,(3ch)
    and     40h
    jp      z,Label_393
    call    Label_365		; Clear 3e:1 store in d503
    ret     

Label_394:
    in      a,(3ch)
    and     02h
    jp      z,Label_394
    call    Label_361
    call    Label_383
    ret     

Label_395:
    ld      a,0bh
    ld      (0d510h),a
    ld      a,01h
    ld      (0d511h),a
    ld      a,00h
    ld      (0d512h),a
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    ret     

;	Send the error code in d5b0 via message "E0n", where n = 1-6

Label_396:
    ld      a,(0d5b0h)
    cp      01h
    jp      z,Label_398
    cp      02h
    jp      z,Label_398
    cp      03h
    jp      z,Label_398
    cp      04h
    jp      z,Label_398
    cp      05h
    jp      z,Label_398
    cp      06h
    jp      z,Label_398
Label_397:
    jp      Label_397		; If reg a isn't 1-6 inclusive, loop forever

Label_398:
    ld      a,00h		; Else if reg a is 1-6 inclusive, come here
    ld      (0d564h),a		; Set (D564) FALSE
    ld      (0d577h),a
    call    Label_399
    ld      a,00h
    ld      (0dddfh),a		; Done with process message buffer
    jp      Label_23		; Jump back to main loop

Label_399:
    ld      a,45h
    ld      (0dde8h),a		; buffer an 'E'
    ld      a,30h
    ld      (0dde9h),a		; buffer a '0'
    ld      a,40h
    ld      (0ddebh),a		; buffer an '@' (end-of-string marker)
    ld      a,(0d5b0h)
    cp      01h			; This block of code has been done poorly
    jp      z,Label_401
    cp      02h
    jp      z,Label_402
    cp      03h
    jp      z,Label_403
    cp      04h
    jp      z,Label_404
    cp      05h
    jp      z,Label_405
    cp      06h
    jp      z,Label_406
Label_400:
    jp      Label_400		; Loop forever if not 1 - 6 inclusive

Label_401:
    ld      a,31h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_402:
    ld      a,32h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_403:
    ld      a,33h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_404:
    ld      a,34h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_405:
    ld      a,35h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

Label_406:
    ld      a,36h
    ld      (0ddeah),a
    call    Label_77		; Send msg via serial port
    ret     

;	Unknown Function

Label_407:
    call    Label_333		; Inits 21 buffers and Dxxx memory
    ld      a,0bh
    ld      (0d510h),a
    ld      a,0ah
    ld      (0d511h),a
    ld      a,4eh
    ld      (0d512h),a
    ld      a,4fh
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
Label_408:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      z,Label_409
    cp      43h
    jp      z,Label_410
    jp      Label_408

Label_409:
    call    Label_361
    call    Label_340
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d5dah),a
    jp      Label_7
Label_410:
    call    Label_361
    jp      Label_411
Label_411:
    ld      a,00h
    ld      (0d510h),a
    ld      a,0ch
    ld      (0d511h),a
    ld      a,19h
    ld      (0d512h),a
    ld      a,1ch
    ld      (0d513h),a
    call    Label_337		; Program port 80 w/ 81 = b8
Label_412:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      43h
    jp      z,Label_415
    cp      47h
    call    z,Label_413
    jp      Label_412
Label_413:
    call    Label_361
    ld      hl,03e8h
    ld      (0d562h),hl		; (D562) = 1000
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d52ah),a
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,01h
    ld      (0d54bh),a
Label_414:
    ld      a,(0d588h)
    and     a
    call    nz,Label_313
    call    Label_172
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d56ch),hl
    ld      hl,0ffffh
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      a,00h
    ld      (0d578h),a		; Set pump direction to dispense
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    ld      hl,0ffffh
    ld      (0d579h),hl
    call    Label_131
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d577h),a
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d56ch),hl
    ld      hl,0ffffh
    ld      (0d568h),hl
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    call    Label_103
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ld      a,01h
    ld      (0d578h),a		; Set pump direction to reverse to supply
    ld      hl,(0d580h)
    ld      (0d57ch),hl
    ld      hl,0ffffh
    ld      (0d579h),hl
    call    Label_131
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d577h),a
    jp      Label_414
Label_415:
    call    Label_361
    jp      Label_407

;	Function that plays with ports 80, 81 alot

Label_416:
    ld      a,(0d002h)
    cp      01h
    jp      z,Label_417
    cp      02h
    jp      z,Label_418
    cp      03h
    jp      z,Label_419

Label_417:
    ld      a,0f8h		; D002 = 1
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0b0h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      Label_420

Label_418:
    ld      a,0f8h		; D002 = 2
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0edh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      Label_420

Label_419:
    ld      a,0f8h		; D002 = 3
    out     (81h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,84h
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0f5h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    jp      Label_420

Label_420:
    in      a,(3ch)		; Then do this
    cp      04h
    jp      nz,Label_420	; Wait for bit 2 of port 3c to clear
    jp      Label_421
Label_421:
    call    Label_361
Label_422:
    ld      hl,0032h
    ld      (0d562h),hl		; (D562) = 50
    call    Label_366		; Look at pump and pump-jaw
    in      a,(3ch)
    and     04h
    jp      nz,Label_422	; Wait for bit 2 of port 3c to clear
    ld      a,(0d002h)
    cp      01h
    jp      z,Label_423
    cp      02h
    jp      z,Label_424
    cp      03h
    jp      z,Label_425

Label_423:
    ld      a,02h		; if D002 <> 2 or 3
    ld      (0d002h),a
    ld      hl,(0d582h)
    ld      (0d003h),hl
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    jp      Label_416

Label_424:
    ld      a,03h		; if D002 = 2
    ld      (0d002h),a
    ld      hl,(0d584h)
    ld      (0d003h),hl
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    jp      Label_416

Label_425:
    ld      a,01h		; if D002 = 3
    ld      (0d002h),a
    ld      hl,(0d580h)
    ld      (0d003h),hl
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    jp      Label_416

Label_426:
    ld      a,0f8h
    out     (81h),a		; 81 = f8
    ld      a,80h
    out     (80h),a		; 80 = 80,ee,fb,d7,00,00,00,00,00
    ld      a,0eeh
    out     (80h),a
    ld      a,0fbh
    out     (80h),a
    ld      a,0d7h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      hl,03e8h
    ld      (0d562h),hl		; (d562) = 1000
    call    Label_366		; Look at pump and pump-jaw
Label_427:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      nz,Label_427
    call    Label_361
Label_428:
    call    Label_114		; Stage home, X0 command
    ld      a,0f8h
    out     (81h),a		; 81 = f8
    ld      a,80h
    out     (80h),a		; 80 = 80,80,f7,df,00,00,00,00,00
    ld      a,80h
    out     (80h),a
    ld      a,0f7h
    out     (80h),a
    ld      a,0dfh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
Label_429:
    call    Label_340
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      nz,Label_429
    call    Label_361
    call    Label_340
    ld      a,(0d514h)
    and     a
    jp      nz,Label_428
    ld      a,06h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      nz,Label_430
    call    Label_370
    jp      Label_428
Label_430:
    call    Label_267
    ld      hl,0007h
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    Label_109		; Go move stage
Label_431:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      bc,(0d005h)
    ld      a,b
    and     80h
    jp      nz,Label_432
    ld      a,0fh
    ld      (0d510h),a
    ld      hl,0000h
    add     hl,bc
    jp      Label_433
Label_432:
    ld      a,0ah
    ld      (0d510h),a
    ld      hl,0000h
    and     a
    sbc     hl,bc
Label_433:
    ld      de,0064h
    call    Label_494		; Divide hl by de
    ld      a,c
    ld      (0d511h),a
    ld      de,000ah
    call    Label_494		; Divide hl by de
    ld      a,c
    ld      (0d512h),a
    ld      a,l
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      52h
    jp      z,Label_434
    in      a,(3ch)
    bit     3,a
    call    nz,Label_442
    bit     4,a
    call    nz,Label_444
    jp      Label_431
Label_434:
    call    Label_361
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
Label_435:
    call    Label_114		; Stage home, X0 command
    ld      a,0f8h
    out     (81h),a
    ld      a,80h
    out     (80h),a
    ld      a,0f5h
    out     (80h),a
    ld      a,0ffh
    out     (80h),a
    ld      a,0b6h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
Label_436:
    call    Label_340
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      nz,Label_436
    call    Label_361
    call    Label_340
    ld      a,(0d514h)
    and     a
    jp      z,Label_435
    ld      a,06h
    ld      (0d5b0h),a
    in      a,(8ch)
    bit     4,a
    jp      nz,Label_437
    call    Label_370
    jp      Label_435
Label_437:
    call    Label_267
    ld      hl,000dh
    ld      (0de50h),hl
    ld      hl,(0d570h)
    ld      (0d565h),hl
    call    Label_109		; Go move stage
Label_438:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      bc,(0d007h)
    ld      a,b
    and     80h
    jp      nz,Label_439
    ld      a,0fh
    ld      (0d510h),a
    ld      hl,0000h
    add     hl,bc
    jp      Label_440
Label_439:
    ld      a,0ah
    ld      (0d510h),a
    ld      hl,0000h
    and     a
    sbc     hl,bc
Label_440:
    ld      de,0064h
    call    Label_494		; Divide hl by de
    ld      a,c
    ld      (0d511h),a
    ld      de,000ah
    call    Label_494		; Divide hl by de
    ld      a,c
    ld      (0d512h),a
    ld      a,l
    ld      (0d513h),a
    call    Label_336		; Program port 80 w/ 81 = 98
    call    Label_358		; Read in front panel key press, except up/down
    ld      a,(0d51dh)
    cp      52h
    jp      z,Label_441
    in      a,(3ch)
    bit     3,a
    call    nz,Label_446
    bit     4,a
    call    nz,Label_448
    jp      Label_438
Label_441:
    call    Label_361
    call    Label_463		; Loads ports 10-12 w/ 13 ctrl
    call    Label_114		; Stage home, X0 command
    jp      Label_426

Label_442:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d005h)
    ld      bc,012ch
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d005h)
    inc     hl
    ld      (0d005h),hl
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    Label_103
Label_443:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_443
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ret     

Label_444:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d005h)
    ld      bc,0fed4h
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d005h)
    dec     hl
    ld      (0d005h),hl
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    Label_103
Label_445:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_445
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ret     

Label_446:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d007h)
    ld      bc,012ch
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d007h)
    inc     hl
    ld      (0d007h),hl
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    Label_103
Label_447:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_447
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ret     

Label_448:
    ld      hl,0014h
    ld      (0d562h),hl		; (D562) = 20
    call    Label_366		; Look at pump and pump-jaw
    ld      hl,(0d007h)
    ld      bc,0fed4h
    and     a
    sbc     hl,bc
    ret     z

    ld      hl,(0d007h)
    dec     hl
    ld      (0d007h),hl
    ld      a,01h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0001h
    ld      (0d568h),hl
    call    Label_103
Label_449:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_449
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
    ret     

Label_450:
    ld      a,9eh
    out     (37h),a
    ld      a,0f2h
    out     (36h),a
    ld      a,04h
    out     (23h),a
    ld      hl,0100h
    ld      a,l
    out     (22h),a
    ld      a,h
    out     (22h),a
    ld      a,0f8h
    out     (81h),a
    ld      a,0feh
    out     (80h),a
    ld      a,8bh
    out     (80h),a
    ld      a,0ceh
    out     (80h),a
    ld      a,0feh
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    ld      a,00h
    out     (80h),a
    call    Label_361
    ld      hl,01f4h
    ld      (0d562h),hl		; (D562) = 500
    call    Label_366		; Look at pump and pump-jaw
    call    Label_333		; Inits 21 buffers and Dxxx memory
    call    Label_340
Label_451:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      47h
    jp      z,Label_452
    cp      46h
    jp      z,Label_453
    cp      52h
    jp      z,Label_456
    jp      Label_451
Label_452:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_340
    ld      a,01h
    ld      (0d54bh),a
    ld      a,00h
    ld      (0d532h),a
    call    Label_265
    ld      a,00h
    ld      (0d54bh),a
    jp      Label_451
Label_453:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    ld      a,00h
    ld      (0d567h),a
    ld      hl,(0d570h)
    ld      (0d565h),hl
    ld      hl,0f43h
    ld      (0d568h),hl
    call    Label_103
Label_454:
    ld      hl,(0d568h)
    ld      a,l
    or      h
    jp      nz,Label_454
    ld      a,00h
    ld      (0d564h),a		; Set (D564) FALSE
Label_455:
    call    Label_346		; Read in front panel key press
    ld      a,(0d51dh)
    cp      52h
    jp      nz,Label_455
    call    Label_114		; Stage home, X0 command
    jp      Label_451
Label_456:
    call    Label_361
    ld      hl,0096h
    ld      (0d562h),hl		; (D562) = 150
    call    Label_366		; Look at pump and pump-jaw
    call    Label_114		; Stage home, X0 command
    jp      Label_451
Label_457:
    jp      Label_457		; Loop forever

    defs    8000h - $

;	Tweaks ports 10 - 13

Label_458:
    ld      a,00h
    out     (13h),a
    ld      hl,0000h
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,04h
    out     (10h),a
    ld      hl,0000h
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,02h
    out     (11h),a
    ld      hl,0400h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,00h
    out     (13h),a
    ld      a,0a0h
    out     (13h),a
Label_459:
    in      a,(13h)
    and     01h
    in      a,(13h)
    jp      nz,Label_459
    ld      a,80h
    out     (13h),a
    ret     

;	Tweaks ports 10, 11, & 12 w/ 13 as control

Label_460:
    di      
    ld      a,00h
    out     (13h),a
    ld      hl,0000h
    ld      (0d58ch),hl
    ld      a,02h
    ld      (0d58eh),a
    ld      hl,0000h
    ld      (0d58fh),hl
    ld      a,04h
    ld      (0d591h),a
    ld      a,02h
    out     (13h),a
    ld      hl,0040h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,10h
    ld      b,a
Label_461:
    push    bc
    ld      hl,(0d58ch)
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,(0d58eh)
    out     (10h),a
    ld      hl,(0d58fh)
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,(0d591h)
    out     (11h),a
    ld      a,0a0h
    out     (13h),a
    in      a,(10h)
    ld      (0d58ch),a
    in      a,(10h)
    ld      (0d58dh),a
    in      a,(10h)
    ld      (0d58eh),a
    in      a,(11h)
    ld      (0d58fh),a
    in      a,(11h)
    ld      (0d590h),a
    in      a,(11h)
    ld      (0d591h),a
    ld      hl,1964h
Label_462:
    dec     hl
    ld      a,l
    or      h
    jp      nz,Label_462
    pop     bc
    djnz    Label_461
    ld      a,80h
    out     (13h),a
    ei      
    ret     

;	Loads ports 10, 11, & 12 w/ 13 as control

Label_463:
    ld      a,00h
    out     (13h),a
    ld      hl,0000h
    ld      a,l
    out     (10h),a
    ld      a,h
    out     (10h),a
    ld      a,02h
    out     (10h),a
    ld      hl,0000h
    ld      a,l
    out     (11h),a
    ld      a,h
    out     (11h),a
    ld      a,04h
    out     (11h),a
    ld      a,00h
    out     (13h),a
    ld      hl,0040h
    ld      a,l
    out     (12h),a
    ld      a,h
    out     (12h),a
    ld      a,0a0h
    out     (13h),a
Label_464:
    in      a,(13h)
    and     01h
    in      a,(13h)
    jp      nz,Label_464
    ld      a,80h
    out     (13h),a
    ret

;	Multiple (D040) by 40 and put in (D589 - D58B), pump volume

Label_465:
    ld      a,00h
    ld      (0d589h),a
    ld      (0d58ah),a
    ld      (0d58bh),a		; Zero out pump volume used if function 1FDE
    ld      bc,0028h
    and     a

Label_466:
    ld      hl,(0d589h)	; Top of loop
    ld      de,(0d040h)
    add     hl,de
    ld      (0d589h),hl
    ld      a,(0d58bh)
    ld      e,00h
    adc     a,e
    ld      (0d58bh),a
    dec     bc
    ld      a,c
    or      b
    jp      nz,Label_466		; Loop 40 times
    ret     

Label_467:
    ld      hl,(0d598h)
    ld      de,03e8h
    ld      bc,0000h
Label_468:
    and     a
    sbc     hl,de
    jp      m,Label_469
    inc     bc
    jp      Label_468
Label_469:
    ld      a,c
    ld      (0d5a1h),a
    add     hl,de
    ld      de,0064h
    ld      bc,0000h
Label_470:
    and     a
    sbc     hl,de
    jp      m,Label_471
    inc     bc
    jp      Label_470
Label_471:
    ld      a,c
    ld      (0d5a0h),a
    add     hl,de
    ld      de,000ah
    ld      bc,0000h
Label_472:
    and     a
    sbc     hl,de
    jp      m,Label_473
    inc     bc
    jp      Label_472
Label_473:
    ld      a,c
    ld      (0d59fh),a
    add     hl,de
    ld      a,l
    ld      (0d59eh),a
    ret     

;	Convert number at d598-d59c to string at d59e-d5a2

Label_474:
    ld      a,00h
    ld      (0d59eh),a
    ld      (0d59fh),a
    ld      (0d5a0h),a
    ld      (0d5a1h),a
    ld      (0d5a2h),a
    ld      a,(0d598h)
    ld      (0d5a4h),a
    ld      a,(0d599h)
    ld      (0d5a5h),a
    ld      a,(0d59ah)
    ld      (0d5a6h),a
    ld      de,2710h
    ld      (0d5a7h),de
    ld      a,00h
    ld      (0d5a9h),a
    ld      e,00h
Label_475:
    push    de
    call    Label_502		; Subtract two 3-byte numbers in memory
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,Label_476
    inc     e
    jp      Label_475
Label_476:
    ld      a,e
    ld      (0d5a2h),a
    call    Label_500		; Add two 3-byte numbers in memory
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,03e8h
    ld      (0d5a7h),de
    ld      e,00h
Label_477:
    push    de
    call    Label_502		; Subtract two 3-byte numbers in memory
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,Label_478
    inc     e
    jp      Label_477
Label_478:
    ld      a,e
    ld      (0d5a1h),a
    call    Label_500		; Add two 3-byte numbers in memory
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,0064h
    ld      (0d5a7h),de
    ld      e,00h
Label_479:
    push    de
    call    Label_502		; Subtract two 3-byte numbers in memory
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,Label_480
    inc     e
    jp      Label_479
Label_480:
    ld      a,e
    ld      (0d5a0h),a
    call    Label_500		; Add two 3-byte numbers in memory
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    ld      de,000ah
    ld      (0d5a7h),de
    ld      e,00h
Label_481:
    push    de
    call    Label_502		; Subtract two 3-byte numbers in memory
    pop     de
    ld      a,(0d5aah)
    ld      (0d5a4h),a
    ld      a,(0d5abh)
    ld      (0d5a5h),a
    ld      a,(0d5ach)
    ld      (0d5a6h),a
    jp      m,Label_482
    inc     e
    jp      Label_481
Label_482:
    ld      a,e
    ld      (0d59fh),a
    call    Label_500		; Add two 3-byte numbers in memory
    ld      a,(0d5aah)
    ld      (0d59eh),a
    ld      e,30h
    ld      a,(0d59eh)
    add     a,e
    ld      (0d59eh),a
    ld      a,(0d59fh)
    add     a,e
    ld      (0d59fh),a
    ld      a,(0d5a0h)
    add     a,e
    ld      (0d5a0h),a
    ld      a,(0d5a1h)
    add     a,e
    ld      (0d5a1h),a
    ld      a,(0d5a2h)
    add     a,e
    ld      (0d5a2h),a
    ret     

;	Convert string at d598-d59c to number at d59e-d5a0

Label_483:
    ld      a,00h
    ld      (0d59eh),a		; Clear output buffer
    ld      (0d59fh),a
    ld      (0d5a0h),a
    ld      hl,0000h
    ld      de,0001h
    ld      a,(0d598h)
    sub     30h
    jp      z,Label_485
    ld      b,a
Label_484:
    add     hl,de
    djnz    Label_484		; Loop adding units
Label_485:
    ld      de,000ah
    ld      a,(0d599h)
    sub     30h
    jp      z,Label_487
    ld      b,a
Label_486:
    add     hl,de
    djnz    Label_486		; Loop adding tens
Label_487:
    ld      de,0064h
    ld      a,(0d59ah)
    sub     30h
    jp      z,Label_489
    ld      b,a
Label_488:
    add     hl,de
    djnz    Label_488		; Loop adding hundreds
Label_489:
    ld      de,03e8h
    ld      a,(0d59bh)
    sub     30h
    jp      z,Label_491
    ld      b,a
Label_490:
    add     hl,de
    djnz    Label_490		; Loop adding thousands
Label_491:
    ld      de,2710h
    ld      a,(0d59ch)
    sub     30h
    jp      z,Label_493
    ld      b,a
    ld      a,00h
Label_492:
    add     hl,de
    adc     a,00h
    djnz    Label_492		; Loop adding ten thousands
    ld      (0d5a0h),a
Label_493:
    ld      (0d59eh),hl
    ret     

;	Divides hl by de - bc has the quotient, hl has the remainder

Label_494:
    ld      bc,0000h
    or      a
Label_495:
    sbc     hl,de
    jr      c,Label_496
    inc     bc
    jr      Label_495
Label_496:
    add     hl,de
    ret     

Label_497:
    push    hl
    pop     bc
    ld      hl,0000h
    ld      a,10h
Label_498:
    srl     d			; divide de by 2
    rr      e
    jp      nc,Label_499
    add     hl,bc
Label_499:
    sla     c			; multiply bc by 2
    rl      b
    dec     a
    jp      nz,Label_498	; do it 16 times
    ret     

;	Add two 3-byte numbers in memory
;	Add # at d5a4-d5a6 to # at d5a7-d5a9 and put at d5aa-d5ac

Label_500:
    ld      de,0d5a4h
    ld      hl,0d5a7h
    ld      ix,0d5aah
    and     a			; Clear carry
    ld      b,03h
Label_501:
    ld      a,(de)
    adc     a,(hl)
    ld      (ix+00h),a
    inc     de
    inc     hl
    inc     ix
    djnz    Label_501
    ret     

;	Subtract two 3-byte numbers in memory
;	Subtract # at d5a4-d5a6 from # at d5a7-d5a9 and put at d5aa-d5ac

Label_502:
    ld      de,0d5a4h
    ld      hl,0d5a7h
    ld      ix,0d5aah
    and     a			; Clear carry
    ld      b,03h
Label_503:
    ld      a,(de)
    sbc     a,(hl)
    ld      (ix+00h),a
    inc     de
    inc     hl
    inc     ix
    djnz    Label_503
    ret     

;	Convert register a to its absolute value - Not used

    push    de
    bit     7,a
    jp      z,Label_504
    ld      e,a
    ld      a,00h
    sub     e
Label_504:
    pop     de
    ret     

;	Convert register hl to its absolute value - Not Used

    push    af
    push    de
    bit     7,h
    jp      z,Label_505
    push    hl
    pop     de
    ld      hl,0000h
    and     a			; Clear carry
    sbc     hl,de
Label_505:
    pop     de
    pop     af
    ret     

;	Interrupt Routine 1

IntRoutine_1:

    di
    nop     
    ei      
    nop     
    reti    

;	Interrupt Routine 2

IntRoutine_2:

    di
    push    af
    push    bc
    push    de
    push    hl

    in      a,(8ch)		; Stage at home sensor
    bit     0,a
    jp      nz,Label_506	; Jump if stage is at home
    ld      a,(0d501h)
    set     4,a
    set     5,a
    jp      Label_507
Label_506:
    ld      a,(0d501h)
    res     4,a
    res     5,a
Label_507:
    ld      (0d501h),a
    out     (3ah),a

    in      a,(8ch)		; Stage at start sensor
    bit     1,a
    jp      nz,Label_508	; Jump if stage is at start
    ld      a,(0d501h)
    set     6,a
    set     7,a
    jp      Label_509
Label_508:
    ld      a,(0d501h)
    res     6,a
    res     7,a
Label_509:
    ld      (0d501h),a
    out     (3ah),a

    in      a,(8ch)		; Pump home sensor
    bit     2,a
    jp      nz,Label_510	; Jump if pump is at home
    ld      a,(0d500h)
    set     0,a
    jp      Label_511
Label_510:
    ld      a,(0d500h)
    res     0,a
Label_511:
    ld      (0d500h),a
    out     (38h),a		; Control the LEDs

    in      a,(8ch)		; Plate-type sensor
    bit     3,a
    jp      nz,Label_512	; Jump if switch set to 12 column
    ld      a,(0d500h)
    set     1,a
    jp      Label_513
Label_512:
    ld      a,(0d500h)
    res     1,a
Label_513:
    ld      (0d500h),a		; Save current settings
    out     (38h),a		; Control the LEDs


    in      a,(8ch)		; Pump-jaw sensor
    bit     4,a
    jp      nz,Label_514	; Jump if pump-jaw is closed
    ld      a,(0d501h)
    set     0,a
    jp      Label_515

Label_514:
    ld      a,(0d501h)
    res     0,a
Label_515:
    ld      (0d501h),a

    out     (3ah),a
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 3

IntRoutine_3:

    di      
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d54bh)
    and     a
    jp      z,Label_516
    ld      a,(0d588h)
    and     a
    jp      nz,Label_516
    in      a,(3ch)
    bit     6,a
    jp      z,Label_516
    ld      a,01h		; If (d54b) && !(d588) && (3C:6)
    ld      (0d588h),a
    ld      (0d52dh),a

Label_516:
    ld      a,(0d52dh)		; Else
    and     a
    jp      z,Label_518
    ld      hl,(0d530h)
    ld      a,l
    or      h
    jp      z,Label_517
    dec     hl
    ld      (0d530h),hl		; Decrement d530
    jp      Label_518
Label_517:
    ld      a,(0d501h)		; If (d52d) && !(d530)
    xor     02h			; Clear bit 1
    ld      (0d501h),a
    out     (3ah),a
    ld      hl,(0d52eh)
    ld      (0d530h),hl		; Re-initialize with 3
    jp      Label_518
Label_518:
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 4 - serial port

IntRoutine_4:

    di
    push    af
    push    bc
    push    de
    push    hl
    in      a,(2bh)
    and     38h
    jp      z,Label_519
    jp      Label_522

Label_519:
    ld      a,(0d9dch)
    and     a
    jp      nz,Label_520	; If stx already recieved jump
    in      a,(2ah)		; Get 7-bit character
    and     7fh
    cp      02h			; STX?
    jp      nz,Label_525	; nop - leave
    ld      a,01h
    ld      (0d9dch),a		; STX received
    ld      hl,0000h
    ld      (0d9ddh),hl		; Set input index to 0
    jp      Label_525		; leave

Label_520:
    in      a,(2ah)		; Get 7-bit character
    and     7fh
    ld      hl,0d5dch
    ld      de,(0d9ddh)
    add     hl,de
    ld      (hl),a		; Put in buffer
    inc     de
    ld      (0d9ddh),de
    ld      hl,0400h
    ld      de,(0d9ddh)
    and     a
    sbc     hl,de
    jp      m,Label_522		; Jump if buffer indext > 1024 - Error

    cp      03h			; Is it an ETX?
    jp      z,Label_521
    jp      Label_525		; No, leave

Label_521:
    ld      a,01h		; Got ETX
    ld      (0d5dbh),a		; Set MSG received
    ld      a,00h
    ld      (0d9dch),a		; ETX received waiting for STX
    ld      a,(0d5dch)		; Check first char of string
    cp      53h			; == S
    jp      z,Label_523
    cp      41h			; == A
    jp      z,Label_524
    ld      a,(0dddfh)
    and     a			; Currently processing input?
    jp      nz,Label_525	; Yes, leave
    ld      hl,0d5dch
    ld      de,(0d9ddh)
    add     hl,de
    ld      (hl),a		; Put a 0 at end of message
    ld      hl,0d5dch
    ld      de,0d9dfh
    ld      bc,0400h
    ldir    			; Move serial input buff to msg processing buff
    ld      a,01h
    ld      (0dddfh),a		; Set processing input flag
    ld      a,00h
    ld      (0d5dbh),a		; Clear full msg received?????
    ld      hl,0000h
    ld      (0de4ch),hl		; Zero index into msg processing buff
    call    Label_87
    jp      Label_525		; Leave

Label_522:
    in      a,(2ah)		; Called by 84B6: index>1024 & 8479: bad HW handshaking
    ld      a,15h
    out     (2bh),a		; Send a NAK????? no mention in manual
    ld      a,00h
    ld      (0d9dch),a		; Waiting for STX
    jp      Label_525

Label_523:
    ld      a,(0de5ah)		; Got an 'S'
    xor     01h
    ld      (0de5ah),a
    jp      Label_525

Label_524:
    ld      a,(0de5ah)		; Got an 'A'
    and     a
    jp      z,Label_525
    ld      a,01h
    ld      (0de5bh),a
    jp      Label_525

Label_525:
    pop     hl			; Leave serial port INT routine
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 5 - Runs the pump for some volume in some direction

IntRoutine_5:

    di
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d564h)
    and     a
    jp      z,Label_532

    ld      a,(0d509h)		; (D564) is TRUE
    res     0,a
    out     (8ah),a
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix			; Delay for 145 T states
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    set     0,a
    out     (8ah),a		; Clear then set 8A:0
    ld      hl,(0d568h)
    dec     hl
    ld      (0d568h),hl		; Decrement (D568-D569)
    ld      a,(0d574h)
    cp      01h
    jp      z,Label_526
    cp      02h
    jp      z,Label_531
    jp      Label_529

Label_526:
    ld      hl,(0d568h)		; (D574) = 1
    ld      de,(0d56ah)
    and     a
    sbc     hl,de
    jp      nz,Label_527
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    jp      Label_533
Label_527:
    ld      ix,8691h
    ld      de,(0d575h)
    add     ix,de
    add     ix,de
    inc     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      hl,(0d565h)
    and     a
    sbc     hl,de
    jp      m,Label_528
    ld      a,00h
    ld      (0d574h),a		; Set (D574) FALSE
    ld      de,(0d565h)
Label_528:
    ld      (0de58h),de
    call    Label_91		; write word (DE58) out port 26
    jp      Label_533

Label_529:
    ld      hl,(0d568h)		; (D574) <> 1 or 2
    ld      de,(0d575h)
    and     a
    sbc     hl,de
    jp      nz,Label_530
    ld      hl,(0d568h)
    ld      a,h
    or      l
    jp      z,Label_533
    ld      a,02h
    ld      (0d574h),a		; Set (D574) to 2
    ld      ix,8691h
    ld      de,(0d575h)
    dec     de
    add     ix,de
    add     ix,de
    dec     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      (0de58h),de
    call    Label_91		; write word (DE58) out port 26
Label_530:
    jp      Label_533

Label_531:
    ld      ix,8691h		; (D574) = 2
    ld      de,(0d575h)
    add     ix,de
    add     ix,de
    dec     de
    ld      (0d575h),de
    ld      d,(ix+01h)
    ld      e,(ix+00h)
    ld      (0de58h),de
    call    Label_91		; write word (DE58) out port 26
    jp      Label_533

Label_532:
    ld      a,(0d577h)		; If (D564) = 0
    and     a
    jp      z,Label_533		; If pump off then leave
    ld      a,(0d509h)
    res     2,a
    out     (8ah),a
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix
    push    ix
    pop     ix			; Wait 145 T states
    set     2,a
    out     (8ah),a		; Clear then set 8A:2
    ld      hl,(0d579h)
    dec     hl
    ld      (0d579h),hl		; Tick down pump volume counter
    jp      Label_533

Label_533:
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 6

IntRoutine_6:
    di
    push    af
    push    bc
    push    de
    push    hl
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti    

;	Interrupt Routine 7 - Timer interrupt, each tick = 1us?

IntRoutine_7:
    di
    push    af
    push    bc
    push    de
    push    hl
    ld      a,(0d561h)
    and     a
    jp      z,Label_534		; if d561 = 0, leave
    ld      hl,(0d562h)
    dec     hl
    ld      (0d562h),hl		; Else decrement d562
Label_534:
    pop     hl
    pop     de
    pop     bc
    pop     af
    ei      
    nop     
    reti

;	Some canned messages

Msg_ok:
    defm    "OK@"
Msg_e99:
    defm    "E99@"
Msg_error:
    defm    "ERROR@"
Msg_4_2:
    defm    "4.2@"

;	12-column plate data

Table_12:
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

;	24-column plate data

Table_24:
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

;	Looks like a 12-column table of some sort

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

;	Looks like a 24-column table of some sort

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

    defs    10000h - $

#end
