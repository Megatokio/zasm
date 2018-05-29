; .:*~*:.__.:*~*:.
; |              |
; |RiFT8 Firmware|
; |By Fell, 2012 |
; |              |
; ':*~*:.__.:*~*:'

; MEMORY MAP LAYOUT:
; 	0000-7FFF: 32kB ROM
; 	8000-FFFE: 32kB Static RAM
; RAM MAP:
;	8000-83FF: ~1kB OS scratch space (buffers and stuff)
;	8400-FFFE: User space (stack grows down from FFEE)
; I/O MAP LAYOUT:
; 	00-03: SCC2691 UART
;	80-87: IDE Hard Drive
;
; The ROM currently builds with zasm (Online version: http://k1.spdns.de/cgi-bin/zasm.cgi)
; but intention is to return to z80-asm package once I can build binaries for it.
;
; Simplest emulation for SCC2691 UART: 
;	- Respond to an in on IO 01 with bit 3 always set to show TX ready, and bit 0 set when a char is ready for the Rift8
;	- Respond to in on IO 03 with the character
;	- Listen for data from out on IO 03
;
; RFS (IDE driver/filesystem) is on standby pending a proper (but simple) IDE interface, but below is its TODO.
; Existing stuff needs refactored/testing -- there were possibly some bugs when it was working
; with the utter-optimisism IDE "interface" but the interface wasn't really reliable enough to
; know for sure!
;
; - These are easy cos they just use fileindex:
; 	Format - yay!
; 	VolRename - yay!
; 	ListAll - yay!
; 	ListTag - yay!
; 	FileExists - yay! NOTE: This should MAAAYBE??? return file record? NO WAIT -- SHOULD RETURN FIRST BLOCK NUM?????
; 	RenameFile }
; 	RetagFile  }
; - ReadFile
; - DeleteFile (note this must use the freemap too)
;
; Approx sizes of stuff:
;	Shell: 800 lines
;	BASIC interpreter: 600 lines
;	Dungeon Fungler: 3500 lines
;	Game of life: 200 lines
;	API + Drivers for UART, IDE: 2000 lines

; *** Hardware config constants ***
uart_base	equ $00			; UART base address
uart_mr		equ uart_base		; UART mode registers MR1 and MR2
uart_sr_csr	equ uart_base+1		; R: Status register; W: Clock select register
uart_cr		equ uart_base+2		; R: BRG Test; W: Command register
uart_data	equ uart_base+3		; R: Rx holding register; W: Tx holding register

ide_base	equ $80			; IDE base address
ide_register0 	equ ide_base		; IDE register addresses: Data (rw)
ide_register1 	equ ide_base+1		; Error (r)
ide_register2 	equ ide_base+2		; Sec count
ide_register3 	equ ide_base+3		; LBA 0 (ATA-1 spoken here! LBA access for 64Gb of address capacity -- note 256 not 512 byte sectors)
ide_register4 	equ ide_base+4		; LBA 1
ide_register5 	equ ide_base+5		; LBA 2
ide_register6 	equ ide_base+6		; LBA 3, Master/slave select, LBA select
ide_register7 	equ ide_base+7		; Command (w), Status (r)

ram_base	equ $8000		; RAM base (ROM 0-32kB, RAM 32kB-64kB)
ram_size	equ $8000		; RAM size (32kB)
ram_top		equ ram_base+ram_size-1	; Address of last byte of RAM
int_vec		equ $38			; Z80 interupt handler vector
nmi_vec		equ $66			; Z80 NMI handler vector

; *** Memory map: OS scratch space (Bottom of RAM) ***
rand8_seed	equ ram_base		; Location of Rand8's seed (1 byte)
rand16_seed	equ rand8_seed+1	; Location of Rand16's seed (2 bytes)
ide_lba0	equ rand16_seed+2	; IDE: LBA of desired sector (LSB)
ide_lba1	equ ide_lba0+1		; IDE: LBA (cont)
ide_lba2	equ ide_lba1+1		; IDE: LBA (cont)
ide_lba3	equ ide_lba2+1		; IDE: LBA of desired sector (MSB)
ide_status	equ ide_lba3+1		; IDE: Bit 0 selects master (0) or slave (1); other bits reserved (see IDE routines)
freemap_size	equ ide_status+1	; RFS: Freemap size in blocks
fileindex_size	equ freemap_size+1	; RFS: File index size in blocks
int_buffer	equ fileindex_size+1	; Int->string buffer
string_buffer	equ int_buffer+10	; Location of string buffer for GetString (256 bytes max including terminator)
block_buffer	equ string_buffer+256	; RFS: Block buffer (4096 bytes)	NOTE: SAFE TO USE AS TEMP VARS FROM USERSPACE PROGS
scratch_base	equ block_buffer+4096	; General 1Kb scratch variable space.   NOTE: SAFE TO USE AS TEMP VARS FROM USERSPACE PROGS
prog_base	equ scratch_base+1024	; Location of the start of userspace

; *** Sys constants ***
uart_disabletx	equ 00001000b		; Command reg command to disable tx
uart_resettx	equ 00110000b		; CR command to reset tx
uart_enabletx	equ 00000100b		; CR command to enable tx
uart_disablerx	equ 00000010b		; Command reg command to disable rx
uart_resetrx	equ 00100000b		; CR command to reset rx
uart_enablerx	equ 00000001b		; CR command to enable rx
uart_setmr1	equ 00010000b		; CR command to reset MR pointer to mr1
uart_txemptybit	equ 3			; SR bit that signifies tx empty
uart_rxrdybit	equ 0			; SR bit that signifies rx ready

ascii_tab	equ 9			; Tab
ascii_spc	equ 32			; Space

console_width	equ 38			; Console dimensions
console_height	equ 25

shellprompt	equ '$'			; Shell prompt character

; *** Entrypoint: Set up interrupts, init UART, then jump over interrupt handlers to RAM test ***
		org $0000

;		im 1			; Interrupt mode 1
		di			; Disable interrupts

		ld a,uart_disablerx	; Disable UART rx + tx
		out (uart_cr),a
		ld a,uart_disabletx
		out (uart_cr),a
		ld a,uart_resettx	; Reset tx + rx
		out (uart_cr),a
		ld a,uart_resetrx
		out (uart_cr),a		
		ld a,uart_setmr1	; Reset MR pointer (causes the MR pointer to point to MR1)
		out (uart_cr),a		  
		ld a,00010011b		; Config UART mr1 (on this address after reset) for no RTS gubbins on rx, 8 bits per char, no parity
		out (uart_mr),a		; NB: When written to, the register addressed by uart_mr switches to mr2
		ld a,00000111b		; Config UART mr2 for normal mode, no tx RTS, no tx CTS, stop bit length of 1
		out (uart_mr),a
		ld a,11001100b		; Set UART for 38.4k both ways
		out (uart_sr_csr),a
	
		ld a,uart_enabletx	; Enable UART tx & rx
		out (uart_cr),a	
		ld a,uart_enablerx
		out (uart_cr),a	
		
		jp ram_test		; Jump over interrupt handlers to ramtest
	
; *** Interrupt handler ***
		org int_vec
		
;		reti

; *** NMI handler ***
		org nmi_vec	
		
;		retn
	
; *** RAM test (fill every byte with FF and read it back) ***		
;		org nmi_vec+10		; NOTE: This will have to change if NMI grows to more than 10 bytes
		
ram_test:	ld bc,ram_size		; bc is index counter
		ld hl,ram_base		; hl is actual address
		
ram_loop:	ld a,$FF
		ld (hl),a		; set byte
		ld a,(hl)		; try and read it back
		cp $FF
		jp nz,ram_error		; if not the same, error
		
		inc hl
		dec bc
		ld a,b			; check if BC==0
		or c
		jp nz,ram_loop
		jp ram_ok
	
ram_error: 	;ld bc,msgRamError	; can't do this; no stack!
		;call PrintString
		;call PrintHex16
		jp PrintHex16		; try and at least print failing address (this will fault the CPU at the ret statement however)
		;jp ram_error

; *** RAM's OK; Now we can set up the stack and set rand seeds ***
ram_ok:		ld sp,ram_top-1 	; init stack pointer -- now we can call subroutines :)
		ld a,42
		call SeedRand8
		ld hl,3473
		call SeedRand16
		
; *** Show the welcome and results of tests we've already done! ***
		call ClearScreen
		ld bc,msgWelcome
		call PrintString
		ld hl,ram_size
		call PrintUInt16
		ld bc,msgRamOK
		call PrintLine
		ld bc,msgSerialOK
		call PrintLine

; *** Scan for an HD with an RFS filesystem ***		
		ld bc,msgHDScan
		call PrintString
		
		ld a,0			; Select master IDE drive
		ld (ide_status),a
		ld (freemap_size),a

		ld de,0
bootdelolp:	ld b,50			; Insert 4 sec delay
bootdelilp:	djnz bootdelilp
		inc de
		ld a,d
		or e
		jr nz,bootdelolp

		ld (ide_lba2),a		; Grab the superblock
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSReadBlock
		jp nc,nodiskfound
		
		ld a,(block_buffer+8)	; Check magic number
		cp $42
		jp nz,badfs
		
		ld bc,msgHDFSOK		; It's RiFT-FS!
		call PrintString
		
		ld a,(block_buffer+27)	; Grab fileindex_size
		ld (fileindex_size),a
		ld a,(block_buffer+26)	; Grab freemap_size to display FS size (TODO: Backup freemap_size and fileindex_size into RAM vars!!)
		ld (freemap_size),a
		ld b,a
		ld de,16
		ld hl,0
sizedisplp:	add hl,de
		djnz sizedisplp
		call PrintUInt16
		ld bc,msgHDcap
		call PrintString
		ld bc,block_buffer+10
		call PrintLine
		jp hddetectdone
		
nodiskfound:	ld bc,msgHDNotFound
		call PrintLine
		jp hddetectdone

badfs:		ld bc,msgHDBadFS
		call PrintLine

hddetectdone:	call NewLine
		
; *** Rock the shell! ***
shell_ready:	call ScanChar		; eat anything in UART buffer (from kb startup)
		call ScanChar
		call ScanChar
		call ScanChar
		
		ld bc,msgAnyKey		; force a pointless keypress (the first one out of the UART's usually dodgy)
		call PrintLine
		call GetCharSilent

		;;;;;;;;;;;;;;;;;;;;;;;;;
;testloop:	call GetString
;		ld de,string_buffer
;		call AToUInt16
;		call NewLine
;		call PrintUInt16
;		call NewLine
;		jr testloop
		;;;;;;;;;;;;;;;;;;;;;;;;;
		
shell:		ld sp,ram_top-1 	; re-init stack pointer in case something's just jumped out of an app to this label
		ld bc,msgShellRdy
		call PrintLine
shell_loop:	ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine
		
		ld hl,string_buffer

		ld de,cmdClear
		call StrCmp
		jp c,shell_cls

		ld de,cmdDFungler
		call StrCmp
		jp c,dungeonfungler	

		ld de,cmdHelp
		call StrCmp
		jp c,shell_help		

		ld de,cmdMemLoad
		call StrCmp
		jp c,shell_memload		

		ld de,cmdMemDump
		call StrCmp
		jp c,shell_dump		

		ld de,cmdGOL
		call StrCmp
		jp c,shell_gol

		ld de,cmdBASIC
		call StrCmp
		jp c,basic	; Note: Accepts direct jump, not a call

		ld de,cmdBlockLoad
		call StrCmp
		jp c,shell_blockload		

		ld de,cmdBlockWrite
		call StrCmp
		jp c,shell_write_rawblock		

		ld de,cmdRFSLibName
		call StrCmp
		jp c,shell_renamelib		

		ld de,cmdRFSWrite
		call StrCmp
		jp c,shell_writefile		

		ld de,cmdRFSFormat
		call StrCmp
		jp c,shell_format		

		ld de,cmdRFSAll
		call StrCmp
		jp c,shell_rfsall

		ld de,cmdRFSRename
		call StrCmp
		jp c,shell_rename

		ld de,cmdRFSTagged
		call StrCmp
		jp c,shell_rfstagged			

		ld de,cmdMemJump
		call StrCmp
		jp c,shell_jump				

		ld bc,msgShellBadCom
		call PrintLine
		jp shell_loop
				
cmdHelp:	defm "help"
		defb 0
cmdClear:	defm "cls"
		defb 0

cmdBASIC:	defm "basic"
		defb 0

cmdDFungler:	defm "fungle"
		defb 0
cmdGOL:		defm "gol"
		defb 0
		
cmdMemLoad:	defm "serload"
		defb 0
cmdMemDump:	defm "dump"
		defb 0
cmdMemJump:	defm "jump"
		defb 0
		
cmdBlockLoad:	defm "blockload"
		defb 0
cmdBlockWrite:	defm "blockwrite"
		defb 0		
cmdRFSLibName:	defm "renamelib"
		defb 0
cmdRFSRename:	defm "rename"
		defb 0
cmdRFSWrite:	defm "write"
		defb 0
cmdRFSFormat:	defm "format"
		defb 0
cmdRFSAll:	defm "list"
		defb 0
cmdRFSTagged:	defm "listtag"
		defb 0

shell_help:	ld bc,msgShellHelp
		call PrintString
		jp shell_loop

msgShellHelp:	defm "Welcome to the RiFT-OS Shell :)"
		defb 13,10,13,10
		defm "General"
		defb 13,10
		defm "  help       - help"
		defb 13,10
		defm "  basic      - start BASIC"
		defb 13,10		
		defm "  cls        - clear screen"
		defb 13,10,13,10
		defm "Fun Stuffs"
		defb 13,10
		defm "  fungle     - Dungeon Fungler"
		defb 13,10
		defm "  gol        - Game of Life"
		defb 13,10,13,10
		defm "Memory Manipulation"
		defb 13,10
		defm "  dump       - memory dump"
		defb 13,10
		defm "  jump       - jump to a mem address"
		defb 13,10
		defm "  serload    - serial memory load"
		defb 13,10,13,10		
		defm "Filesystem stuff"
		defb 13,10		
		defm "  format     - format RFS library"
		defb 13,10
		defm "  renamelib  - rename RFS library"
		defb 13,10
		defm "  write      - write RFS file"
		defb 13,10
		defm "  list       - list all files"
		defb 13,10				
		defm "  listtag    - list files with tag"
		defb 13,10		
		defm "  rename     - rename/retag a file"
		defb 13,10						
		defm "  blockload  - DEBUG: Raw block load"
		defb 13,10		
		defm "  blockwrite - DEBUG: Raw block write"
		defb 13,10		
		defb 0
		
shell_rfsall:	call RFSListAll
		jp shell_loop
		
shell_rfstagged:
		call RFSListTagged
		jp shell_loop
		
shell_writefile:
		ld bc,msgShellMemHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base),a	; Store start address high byte
		call NewLine
		
		ld bc,msgShellMemLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base+1),a	; Store start address low byte
		call NewLine
		
		ld bc,msgShellNumBytesHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base+2),a	; Store bytecount high byte
		call NewLine
		
		ld bc,msgShellNumBytesLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base+3),a	; Store bytecount low byte
		call NewLine		

		ld bc,msgShellFilename
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine

		ld hl,string_buffer	; Store filename
		ld de,scratch_base+20	; Note: Using a higher part of scratchspace as otherwise the filename will get overwritten before RFSWriteFile has a chance to use it!
		ld bc,15
		ldir
		ld a,0
		ld (scratch_base+35),a ; Ensure a terminated string
		

		ld bc,msgShellTag
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine

		ld hl,string_buffer	; Store filename
		ld de,scratch_base+36
		ld bc,15
		ldir
		ld a,0
		ld (scratch_base+51),a 	; Ensure a terminated string

		ld a,(scratch_base)	; Set start address
		ld h,a
		ld a,(scratch_base+1)
		ld l,a
		ld a,(scratch_base+2)	; Set byte count
		ld d,a
		ld a,(scratch_base+3)
		ld e,a
		ld bc,scratch_base+20	; Set address of filename and tag
		
		call RFSWriteFile	; Expects bc=filename+tag (32 bytes), hl=start address, de=bytecount
		jp shell_loop

msgShellNumBytesHi:	
		defm "Enter byte count high word (hex)"
		defb 0

msgShellNumBytesLo:
		defm "Enter byte count low word (hex)"
		defb 0
		
msgShellFilename:
		defm "Enter filename (max 15 chars)"
		defb 0

msgShellTag:	defm "Enter file tag (max 15 chars)"
		defb 0
		
		
shell_write_rawblock:
		ld a,0			; Set block number
		ld (ide_lba2),a
		ld (ide_lba1),a
		ld (ide_lba0),a
		
		call RFSWriteBlock
		jp shell_loop

shell_format:	call RFSFormat
		jp shell_loop

shell_renamelib:
		call RFSRenameLib
		jp shell_loop
		
shell_rename:
		call RFSRename
		jp shell_loop

shell_blockload:
		ld bc,msgShellBNHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8 	; Expects: hl - pointer to a zero-terminated string. a-f should be LOWERCASE! Returns: 8 bit unsigned integer in c; error code or 0 on success in b
		ld a,c
		ld (ide_lba2),a
		call NewLine
		
		ld bc,msgShellBNMid
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8 	; Expects: hl - pointer to a zero-terminated string. a-f should be LOWERCASE! Returns: 8 bit unsigned integer in c; error code or 0 on success in b
		ld a,c
		ld (ide_lba1),a
		call NewLine
		
		ld bc,msgShellBNLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString		
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (ide_lba0),a
		call NewLine

		call RFSReadBlock
		jp nc,sblfailed
		ld bc,msgShellBNok
		call PrintLine
		
sblfailed:	jp shell_loop
		
msgShellBNHi:	defm "Enter block num high word (hex)"
		defb 0

msgShellBNMid:	defm "Enter block num middle word (hex)"
		defb 0
		
msgShellBNLo:	defm "Enter block num low word (hex)"
		defb 0
		
msgShellBNok:	defm "Loaded block into buffer ($8114)."
		defb 0		
		
shell_dump:	ld bc,msgShellMemHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8 	; Expects: hl - pointer to a zero-terminated string. a-f should be LOWERCASE! Returns: 8 bit unsigned integer in c; error code or 0 on success in b
		ld a,c
		ld (scratch_base),a
		call NewLine
		
		ld bc,msgShellMemLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8 	; Expects: hl - pointer to a zero-terminated string. a-f should be LOWERCASE! Returns: 8 bit unsigned integer in c; error code or 0 on success in b
		ld a,c
		ld (scratch_base+1),a
		call NewLine
		
		ld bc,msgShellMemByt
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString		
		ld hl,string_buffer
		call AToUInt8
		ld (scratch_base+2),a
		call NewLine

		ld h,0
		ld a,(scratch_base+2)
		ld l,a
		ld bc,(scratch_base)
		ld a,b			; Swap 'em!
		ld b,c
		ld c,a		
		call MemDump		; Expects: hl - number of bytes; bc - start address	
		jp shell_loop

msgShellMemHi:	defm "Enter start address high word (hex)"
		defb 0

msgShellMemLo:	defm "Enter start address low word (hex)"
		defb 0
		
msgShellMemByt:	defm "Enter bytecount (decimal) or 0 for"
		defb 13,10
		defm "endless view (a keypress stops)"
		defb 0			

shell_memload:	ld bc,msgShellMemHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base),a	; Store start address high word
		call NewLine
		
		ld bc,msgShellMemLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base+1),a	; Store start address low word
		call NewLine
		
		ld bc,msgShellMemLd
		call PrintLine
		
		ld a,(scratch_base)
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		call MemLoad		; Expects: de - start address
		
		ld bc,msgShellOK
		call PrintLine
		jp shell_loop

msgShellMemLd:	defm "Feed me delicious hex bytes! Follow"
		defb 10,13
		defm "each with Enter, and type a full"
		defb 10,13
		defm "stop to end."
		defb 0			
		
shell_cls:	call ClearScreen
		jp shell_loop
		
shell_gol:	call game_of_life
		jp shell_loop		

shell_jump:	ld bc,msgShellMemHi
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base),a	; Store start address high word
		call NewLine
		
		ld bc,msgShellMemLo
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (scratch_base+1),a	; Store start address low word
		
		call ClearScreen
		ld hl,(scratch_base)
		ld a,h			; Swap 'em!
		ld h,l
		ld l,a
		jp (hl)
		
msgShellBadCom:	defm "Bad command; enter `help' for help!"
		defb 0			

msgShellOK:	defm "OK!"
		defb 0		

msgShellRdy:	defm "Ready (enter `help' for help)"
		defb 0			
		
msgRamError:	defm "RAM ERROR! Failed at address: "
		defb 0
	
msgRamOK:	defm " bytes)"
		defb 0
		
msghaltingdisk:	defb 13,10
		defm "Sorrow in my heart;"
		defb 13,10
		defm "The hard drive, it will not play."
		defb 13,10
		defm "Dead leaves on the ground."
		defb 13,10,0
		
msgWelcome:	defm "  ______ __ _______ _______ ______ "
		defb 10,13
		defm " |   __ \__|    ___|_     _|  __  |"
		defb 10,13
		defm " |      <  |    ___| |   | |  __  |"
		defb 10,13
		defm " |___|__|__|___|     |___| |______|"
		defb 10,13,10,13
		defm " RiFT-OS 1.0 by Fell^RiFT {Iain C}"
		defb 10,13
		defm " ELITE SUPER PRO-SPEC EDITION 2012"
		defb 10,13,10,13
		defm "Testing RAM: OK ("
		defb 0
		
msgSerialOK:	defm "Serial port: OK (38400bps, 8-N-1)"
		defb 0
		
msgAnyKey: 	defm "Hit any key for shell..."		
		defb 0
		
msgHDScan:	defm "Checking HD: "
		defb 0
		
msgHDNotFound:	defm "None found"
		defb 0

msgHDBadFS:	defm "OK (Unformatted)"
		defb 0
		
msgHDFSOK:	defm "OK (RFS, "
		defb 0		
		
msgHDcap:	defm "Mb)"
		defb 10,13
		defm "HD lib name: "
		defb 0				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; *** BRAINDEAD BASIC INTERPRETER ***
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Limits:
;	- Max 255 lines			}- 16384 bytes for user prog
;	- Max line length 64 chars	}
;	- Line numbers must be 1-255
;	- Max 52 x 1 char identified (A-Z, a-z), variables (all 16 bit unsigned int)
;	- Max 52 x "$ and 1 char" identified ($A-$Z, $a-$z) string variables, max 32 bytes each (total 3328 bytes -- SO WASTEFUL)
;
; Legal statements (note -- they are case sensitive):
; (N and M are line numbers; Z is a direct 16 bit unsigned int; A, B and C are var identifiers)
; 	goto N
;	input A	
; 	print A
;	print "Use a ~ for a newline!"
;	A={expression | numeral}
;	end
;	if A>B then N [else M]
;	if A<B then N [else M]
;	if A<=B then N [else M]
;	if A>=B then N [else M]
;	if A==B then N [else M]
;	if A<>B then N [else M]
; TODO:
;	- use the expression evaluator to also do the RHS for comparisons!
;	- input A$
;	- print A$
; 	[Stop here and unify print functions into a nice linear parser.....]
;	- GOSUB
;	- FOR
; NICE TO HAVE:
;	peek, poke, sys, random, seed
; OPTIMISATIONS:
;	(memory) lose the 12 extra bytes in basprogvars
;	(memory) should we really be reserving 1.5k+ string buffer? ;)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

basicprompt	equ '>'			; Command processor prompt character
baslinelength	equ 64			; Line length / stride for stepping through baslines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Memory layout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bascurrline	equ prog_base		; Current line number (1 byte)
basprogvars	equ bascurrline+1	; Program UInt16 variables (58*2 bytes not 51*2 bytes due to ASCII chars 91-96 - TODO - optimise away these 12 wasted bytes!)
basprogstrvars	equ basprogvars+58*2	; Program string variables (58*32 bytes not 52*32 bytes due to ASCII chars 91-96 - TODO - optimise away these 192 wasted bytes!!!!!)
baslines	equ basprogstrvars+58*32; Here starts the prog lines (16384 bytes)
basexprstckdpth	equ baslines+16384	; Expression operators stack depth tracking (1 byte)
basforstart	equ basexprstckdpth+1	; FOR loop beginning line nums (64 bytes)
basforiters	equ basforstart+64	; FOR loop max iters (64 bytes)
basgosubstack	equ basforiters+64	; Stack of return line nums for GOSUB (64 bytes)
basgosubstackp	equ basgosubstack+64	; Index into GOSUB returns stack (1 byte)
bassystop	equ basgosubstackp+1	; (Just for debug)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Editor / command processor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

basic:		call ClearScreen	; Entrypoint - jump here to enter the interpreter :)
		jp basic_new
basic_cmd_loop:	ld a,basicprompt
		call PrintChar
		call GetString
		call NewLine
		ld hl,string_buffer
		ld de,basList
		call StrCmp
		jp c,basic_list
		ld de,basNew
		call StrCmp
		jp c,basic_new	
		ld de,basQuit
		call StrCmp
		jp c,shell_loop
		ld de,basRun
		call StrCmp
		jp c,basic_run				
		jp basic_addline

; Add/edit/delete a listing line
basic_addline:	ld hl,string_buffer
		call AToUInt8
		cp 0
		jp z,basic_cmd_loop
		ld e,a			; Backup line num
		ld a,(hl)		; Jump over any space
		cp 32
		jp nz,basic_al_nosp
		inc hl			; Now a contains uint8 line number and hl=start of the actual line (after line number)
basic_al_nosp:	ld a,e			; Restore line num
		ld bc,hl		; Backup address of start of actual line
		ld h,0
		ld l,a
		push hl			; Push line num
		add hl,hl		; Multiply by 64 (Shift left x 6) - NOTE: THIS NEEDS TO CHANGE IF BASLINELENGTH DOES!!!
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld de,baslines
		add hl,de		; hl = target address to copy to; bc = start address to copy from
		ld de,hl		; de = dest
		ld hl,bc		; hl = source
		ld bc,baslinelength-1	; bc = count
		ldir
		ld a,0
		ld (de),a		; Ensure a terminated string
		ld bc,basMsgLineAdd1
		call PrintString
		pop hl			; Pop line number
		call PrintUInt16
		ld bc,basMsgLineAdd2
		call PrintLine
		jp basic_cmd_loop
		
; LIST command
basic_list:	ld hl,0
		ld bc,baslines
basic_list_lp:	ld a,(bc)
		cp 0
		jp z,basic_list_dp	; Skip printing if line is empty
		call PrintUInt16
		ld a,' '
		call PrintChar
		call PrintString
		call NewLine
basic_list_dp:	push hl
		ld hl,bc
		ld bc,baslinelength
		add hl,bc
		ld bc,hl
		pop hl
		inc hl
		ld a,l
		cp 255
		jp z,basic_cmd_loop
		jp basic_list_lp
		
; NEW command
basic_new:	ld hl,baslines
		ld de,baslines+1
		ld bc,baslinelength*256
		ld (hl),0
		ldir
		jp basic_cmd_loop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RUN command (Main interpreter)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
basic_run:	ld a,0			; Reset PC
		ld (bascurrline),a

		ld hl,basStmtEnd	; Insert an END at last instruction
		ld de,baslines+baslinelength*255	
		ld bc,4
		ldir
		
basic_run_loop:	call bas_next_line	; hl now points to start of current line
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;ld bc,basMsgCurLine	; Show debug info
		;call PrintLine
		;push hl
		;ld a,(bascurrline)
		;ld h,0
		;ld l,a
		;call PrintUInt16
		;ld a,' '
		;call PrintChar	
		;pop hl
		;ld bc,hl
		;call PrintLine
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		ld de,basStmtGoto	; GOTO
		call StrStarts
		jp c,bas_stmt_goto
		
		ld de,basStmtRem	; REM
		call StrStarts
		jp c,bas_step_pc_and_cont
		
		ld de,basStmtCls	; CLS
		call StrStarts
		jp c,bas_stmt_cls
		
		ld de,basStmtPrintString	; PRINT "....."
		call StrStarts
		jp c,bas_stmt_print_string
		
		ld de,basStmtPrint	; PRINT a
		call StrStarts
		jp c,bas_stmt_print
		
		ld de,basStmtInput	; INPUT a
		call StrStarts
		jp c,bas_stmt_input
		
		ld de,basStmtEnd	; END
		call StrStarts
		jp c,basic_cmd_loop
		
		ld de,basStmtIf		; IF
		call StrStarts
		jp c,basic_stmt_if
		
		inc hl			; Assignment (A=3)
		ld a,'='
		cp (hl)
		jp z,bas_stmt_ass
		dec hl
		
bas_syn_err:	ld bc,basMsgSynErr	; Syntax error!
		call PrintLine
		push hl
		ld a,(bascurrline)
		ld h,0
		ld l,a
		call PrintUInt16
		pop hl
		ld a,' '
		call PrintChar		
		ld bc,hl
		call PrintLine
		jp basic_cmd_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helpers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Using bascurrline, set hl to that line or the next non-empty line
bas_next_line:	ld bc,baslinelength
		ld a,(bascurrline)
		ld h,0
		ld l,a
		add hl,hl		; Multiply by 64 (Shift left x 6) - NOTE: THIS NEEDS TO CHANGE IF BASLINELENGTH DOES!!!
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		add hl,hl
		ld de,baslines
		add hl,de		; hl = address of current statement
bas_next_stmt_lp:
		ld a,(hl)
		cp 0
		jp nz,bas_stmt_fnd
		add hl,bc		; Hmm let's step to next line
		ld a,(bascurrline)	; Also inc PC!
		inc a
		ld (bascurrline),a
		jp bas_next_stmt_lp
bas_stmt_fnd:	ret
	
; Step prog counter and run the next line
bas_step_pc_and_cont:	
		ld a,(bascurrline)
		inc a
		ld (bascurrline),a
		jp basic_run_loop

; Get a var.
; Expects: c - var name
; Returns: de - var value
bas_get_var:	push hl
		push bc
		ld hl,basprogvars	; hl=basprogvars
		ld b,0
		add hl,bc		; add the var ident offset
		add hl,bc		; add the var ident offset
		ld bc,65
		sbc hl,bc
		ld de,(hl)
		pop bc
		pop hl
		ret
		
; Set a var.
; Expects: c - var name; de - var value		
bas_set_var:	ld hl,basprogvars	; hl=basprogvars
		ld b,0			; (c = var name)
		add hl,bc		; add the var ident offset
		add hl,bc		; add the var ident offset (2 bytes)
		
		ld bc,65		; make ASCII A the first one...
		sbc hl,bc		
		
		ld (hl),de
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Handle statements
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; IF conditionals :)
basic_stmt_if:	ld bc,3
		add hl,bc
		ld b,(hl)		; Pick up LHS op
		inc hl
		ld de,gr_or_eq		; Try 2-char conditions first...
		call StrStarts
		jp c,bas_if_gthan_or_eq
		ld de,ls_or_eq
		call StrStarts
		jp c,bas_if_lthan_or_eq
		ld de,equal
		call StrStarts
		jp c,bas_if_equal
		ld de,not_equal
		call StrStarts
		jp c,bas_if_not_equal
		ld a,(hl)		; OK, try single char conditions...
		cp '>'
		jp z,bas_if_gthan
		cp '<'
		jp z,bas_if_lthan
		jp bas_syn_err		; Didn't find a recognised one!

bas_if_lthan:	call bas_if_get_post_args	; de=LHS; bc=RHS -- ie, do if (de < bc)
bas_if_lthan_actual_chk:
		and a
		push hl
		ld hl,de
		sbc hl,bc
		pop hl
		jp c,bas_if_pass
		jp bas_if_fail
		
bas_if_gthan:	call bas_if_get_post_args	; if (de > bc)
		ld a,e			; Like gthan_or_eq but with not-equal check first...
		cp c
		jp nz,bas_if_gthan_eq_actual_chk	; Different -- do next check
		ld a,d
		cp b
		jp nz,bas_if_gthan_eq_actual_chk	; Different -- do next check
		jp bas_if_fail	; Same! Continue
		
bas_if_lthan_or_eq:			; if (de <= bc)
		inc hl
		call bas_if_get_post_args
		
		ld a,e			; Equality check first
		cp c
		jp nz,bas_if_lthan_actual_chk	; Different -- do next check
		ld a,d
		cp b
		jp nz,bas_if_lthan_actual_chk	; Different -- do next check
		jp bas_if_pass		; Same! Pass :)
		
bas_if_gthan_or_eq:			; if (de >= bc)
		inc hl
		call bas_if_get_post_args
bas_if_gthan_eq_actual_chk:
		and a
		push hl
		ld hl,de
		sbc hl,bc
		pop hl
		jp nc,bas_if_pass
		jp bas_if_fail
		
bas_if_equal:	inc hl			; if (de == bc)
		call bas_if_get_post_args
		ld a,e
		cp c
		jp nz,bas_if_fail
		ld a,d
		cp b
		jp nz,bas_if_fail
		jp bas_if_pass
		
bas_if_not_equal:			; if (de != bc)
		inc hl
		call bas_if_get_post_args
		ld a,e
		cp c
		jp z,bas_if_fail
		ld a,d
		cp b
		jp z,bas_if_fail
		jp bas_if_pass		
		
bas_if_pass:	ld bc,7
		add hl,bc		; Skip past RHS var and " then "
		call AToUInt8
		ld (bascurrline),a
		jp basic_run_loop
		
bas_if_fail:	ld bc,7
		add hl,bc		; Skip past RHS var and " then "
		call AToUInt8		; Eat the then-case line number
		inc hl			; Step over a potential space " "
		ld de,basStmtElse
		call StrStarts		; Check we have "else"
		jp nc,bas_step_pc_and_cont	; Nope -- just continue
		ld bc,5			; Step over "else "
		add hl,bc
		call AToUInt8		; Get else-case line number
		ld (bascurrline),a	; And set it
		jp basic_run_loop	; And go!!
		
; Put LHS value into de and RHS value into bc.
; NOTE!! Accepts: b = LHS var name; hl = address of RHS var name
bas_if_get_post_args:
		ld c,b			; Get LHS name into c
		call bas_get_var	; Expects c, returns value in de (doesn't trash bc)
		push de			; de now contains LHS value
		inc hl			; step to RHS var name
		ld c,(hl)		; Get RHS var name into c
		call bas_get_var	; de now contains RHS value
		ld bc,de		; RHS value is in bc
		pop de			; LHS value is in de
		ret
		
; CLS
bas_stmt_cls:	call ClearScreen
		jp bas_step_pc_and_cont
	
; PRINT (a direct string)
bas_stmt_print_string:
		ld bc,7
		add hl,bc
bas_stmt_ps_lp:	ld a,(hl)
		cp '"'
		jp z,bas_step_pc_and_cont
		cp '~'
		jp nz,bas_stmt_ps_no_newline
		call NewLine
		jp bas_stmt_ps_no_char
bas_stmt_ps_no_newline:
		call PrintChar
bas_stmt_ps_no_char:
		inc hl
		jp bas_stmt_ps_lp
			
; PRINT (an int or string var)
bas_stmt_print:	ld bc,6
		add hl,bc
		ld c,(hl)		; c=var name
		
		inc hl			; check for string var ($)
		ld a,(hl)
		cp '$'
		jp z,bas_stmt_print_strvar
		
		call bas_get_var	; ok, not a string var
		ld hl,de
		call PrintUInt16
		jp bas_step_pc_and_cont

bas_stmt_print_strvar:
		; TODO: Print the string var
		inc hl			; now pointing at string var name
		jp bas_step_pc_and_cont
		
; INPUT (an int var)
bas_stmt_input:	ld bc,6
		add hl,bc
		ld c,(hl)		; get var name in c
		inc hl			; check for string var ($)
		ld a,(hl)
		cp '$'
		jp z,bas_stmt_instr

		; Input a UInt16
		push bc			; to backup var name
		call GetString
		ld de,string_buffer
		call AToUInt16
		ld de,hl
		pop bc			; to restore var name
		call bas_set_var
		jp bas_step_pc_and_cont
	
bas_stmt_instr:	; Input a string
		push bc
		call GetString
		; TODO: STORE THIS SHIT SOMEWHERE
	
; ASSIGNMENT
bas_stmt_ass:	dec hl			; Step back to var identifier
		ld c,(hl)		; Store var ident in c
		push bc			; Backup var identifier
		inc hl			; Step over var ident
		inc hl			; Step over = sign
		call Parse		; Invoke the cocking expression parser! Returns the result in de :))))
		pop bc			; Restore c=var ident
		call bas_set_var
		jp bas_step_pc_and_cont

; GOTO		
bas_stmt_goto:	ld bc,5
		add hl,bc		; Skip past goto token and space
		call AToUInt8
		ld (bascurrline),a
		jp basic_run_loop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Holy 16-bit unsigned int recursive descent expression parser, batman!!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer		
Parse:		call ParseFactors	; de=terminal value (num1)
Parse_lp:	ld a,(hl)		; Grab the oper
		cp '-'			; check for -
		jp z,Parse_sub_add	; found!
		cp '+'			; check for +
		jp z,Parse_sub_add	; found!
		ret			; Not found -- return leaving result in de
Parse_sub_add:	inc hl			; do a sub or add... start with step!
		ld bc,de		; bc = num1
		push bc			; backup num1, we're about to trash it
		push af			; backup a (the oper), we're about to trash it
		call ParseFactors	; de = num2
		pop af			; restore a=oper
		pop bc			; restore bc=num1
		push hl			; backup input pointer, about to kill it
		ld hl,bc		; hl = num1
		cp '-'			; check which oper again
		jp z,Parse_sub		; ok, let's sub
		add hl,de		; let's add!!!
		jp Parse_s_a_done	; done!
Parse_sub:	and a			; Clear carry flag to prevent sbc off-by-1!
		sbc hl,de		; hl = num1 - num2 \o/
Parse_s_a_done:	ld de,hl		; update num1
		pop hl			; restore input pointer
		jp Parse_lp		; loop da shizz
		
; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer		
ParseFactors:	call ParseTerminal	; de=terminal value (num1 in c)
ParseFact_lp:	ld a,(hl)		; char a = *hl;
		cp '/'			; check for /
		jp z,ParseFact_d_m	; found!
		cp '*'			; check for *
		jp z,ParseFact_d_m	; found!
		ret			; Not found -- return (note we leave our retval in de)
ParseFact_d_m:	inc hl			; step to the RHS!
		ld bc,de		; bc = num1
		push af			; backup a (the oper), we're about to trash it
		call ParseTerminal	; de = num2
		pop af			; restore a=oper
		push hl			; backup input pointer, about to kill it
		cp '/'
		jp z,ParseFact_div
		call Mul16		; hl = bc*de
		ld de,hl		; update num1
		jp ParseFact_dn
ParseFact_div:	call Div16		; bc = bc/de
		ld de,bc		; update num1
ParseFact_dn:	pop hl			; restore input pointer
		jp ParseFact_lp		; sloop
		
; Expects: hl=input pointer
; Returns: de=value; hl=updated input pointer
ParseTerminal:	push bc			; Gonna trash bc whatever we do so back it up
		ld a,(hl)		; First let's peek at this badger to check for a numeral (in which case it's a direct value) or a letter (in which case it's a var)
		cp 58
		jr nc,ParseTerm_var	; (Legit numeric chars are only 48-57!)
		ld de,hl
		call AToUInt16		; convert value into a UInt16 and store it (incrementing hl)
		ld bc,de		; backup current address after the num...
		ld de,hl		; set output value in de
		ld hl,bc		; restore current address
		pop bc			; restore bc
		ret
ParseTerm_var:	ld c,a			; c=var name
		call bas_get_var	; returns the value in de
		pop bc			; restore bc
		inc hl			; manually inc hl to step over the var name
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Strings n things
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ls_or_eq:	defm "<="
		defb 0

gr_or_eq:	defm ">="
		defb 0

equal:		defm "=="
		defb 0

not_equal:	defm "<>"
		defb 0
		
basNew:		defm "new"
		defb 0
				
basList:	defm "list"
		defb 0
				
basRun:		defm "run"
		defb 0
		
basQuit:	defm "quit"
		defb 0

basStmtRem:	defm "rem"
		defb 0

basStmtCls:	defm "cls"
		defb 0

basStmtInput:	defm "input "
		defb 0

basStmtEnd:	defm "end"
		defb 0
		
basStmtGoto:	defm "goto "
		defb 0
		
basStmtIf:	defm "if "
		defb 0

basStmtElse:	defm "else"
		defb 0
		
basStmtPrintString:
		defm 'print "'
		defb 0
		
basStmtPrint:	defm "print "
		defb 0
		
basMsgLineAdd1:	defm "Line "
		defb 0
		
basMsgLineAdd2: defm " added/edited"
		defb 0
		
basMsgLines:	defm " lines."
		defb 0
		
basMsgCurLine:	defm "DEBUG: Line about to execute:"
		defb 0
		
basMsgSynErr:	defm "Syntax error near:"
		defb 0
				
; *** DUNGEON FUNGLER ***
;
; Stats: ATT (range 0-15), DEF (range 0-20), HP (range 1-255)
;
; Normal unarmed human: Att=3, Def=2, HP=12
;
; Character progression levels -- range 0-9
;
; ATT = 3 + level + equipped-weapon bonus
; DEF = 2 + level + equipped-armour bonus (head) + equipped-armour bonus (body) + equipped-armour bonus (feet) + equipped-weapon or shield bonus
;
; #### COMBAT MODEL ####
;
; (All ATT and DEF below refers to ATTACKER'S ATT and DEFENDER'S DEF)
; Calculate hitcheck = (ATT*16) / (ATT+DEF)
; Roll a d16 numbered 0-15 and compare to hitcheck:
; 0 rolled --> critical hit: 			DMG = ATT * 2
; 1 to (hitcheck - 1) rolled --> regular hit: 	DMG = ATT
; hitcheck rolled --> glancing blow: 		DMG = ATT / 2 (Possibility to expand this for defender to execute a stop-hit or time-hit if they have the higher att)
; higher than hitcheck rolled --> miss: 	DMG = 0
;
; Corner case: ATT=15, DEF=20 -> Attacker must roll 0-6 on a d16 numbered 0-15
;
; #### DATA STRUCTURES ####
;
; ITEM TABLE @ mfitemtbl (1-BASED INDEX)
; <name:11><map char:1><{if weapon: att/def bonuses}{if not weapon: RESERVED}:1><RESERVED:1><flags:1><activate function:2>
; Att/Def bonuses byte:
;	Bits 0-3: Def bonus
; 	Bits 4-7: Att bonus
;
; Flags: 
;	Bit 7: Is slottable as head armour?
;	Bit 6: Is slottable as body armour?
;	Bit 5: Is slottable as feet armour?
;	Bit 4: Is slottable as hand weapon?
;	Bit 3: If weapon, requires two hands?
;	Bit 2: RESERVED
;	Bit 1: RESERVED
;	Bit 0: RESERVED
;
; MONSTER TABLE @ mfmonstertbl (1-BASED INDEX)
; <name:11><map char:1><att:1><def:1><start hp:1><update function:2>
;
; MONSTER INSTANCE ARRAY @ mfmonsters (1-BASED INDEX)
; <type ID:1><x coord:1><y coord:1><hp:1><standing-on map char:1>
;
; RANKS TABLE @ mfranktbl (0-BASED INDEX)
; <name:11>

; Constants
mfmapwidth	equ 28			; Map width
mfmapheight	equ console_height-1	; Map height
mfnumlevels	equ 3			; Number of dungeon levels before the key's found	
mfmaxinv	equ 20			; Max inventory slots
mfmaxmonsters	equ 60			; Max live monsters :P
mfmaxlos	equ 5			; Max line of sight distance

; Memory
mfplayername	equ prog_base		; Player name
mfgold		equ mfplayername+10	; Gold
mfhp		equ mfgold+2		; Current HP
mfmaxhp		equ mfhp+1		; Max HP
mfrank		equ mfmaxhp+1		; Rank
mfplayerx	equ mfrank+1		; x (1-indexed)
mfplayery	equ mfplayerx+1		; y (1-indexed)
mfplayeratt	equ mfplayery+1		; Attack points
mfplayerdef	equ mfplayeratt+1	; Defend points
mfplayeroldx	equ mfplayerdef+1	; Previous x (1-indexed)
mfplayeroldy	equ mfplayeroldx+1	; Previous y (1-indexed)
mfdungeonlev	equ mfplayeroldy+1	; Dungeon level (1=right below surface, 2=next down)
mfdungeondir	equ mfdungeonlev+1	; Direction of entry into level (0=down, 1=up)
mfdoorindex	equ mfdungeondir+1	; Door array counter
mfdoorarray 	equ mfdoorindex+1	; Door array
mfmap		equ mfdoorarray+(12)	; The map!
mfseenmap	equ mfmap+(mfmapwidth*mfmapheight) 	; Seen+fov map (0=not seen, 1=seen, 2=Going out of fov, 4=In fov)
mfinventory	equ mfseenmap+(mfmapwidth*mfmapheight)	; Inventory (0=empty slot, anything else=ID into item table)
mfmonsters	equ mfinventory+mfmaxinv ; Monster slots
mfprintinfoudp	equ mfmonsters+(mfmaxmonsters*5)	; Printinfo needed? (1=Yup)
mfctlfirstcall 	equ mfprintinfoudp+1	; Flag whether this will be first call to cleartopline this frame
mfequipslothead	equ mfctlfirstcall+1	; Equip slot: Head armour
mfequipslotbody	equ mfequipslothead+1	; Equip slot: Body armour
mfequipslotfeet equ mfequipslotbody+1	; Equip slot: Boots
mfequipslothnd1 equ mfequipslotfeet+1	; Equip slot: Main hand
mfequipslothnd2	equ mfequipslothnd1+1	; Equip slot: Off hand

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; THE HIGH LEVEL CONTROL ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Game entrypoint
dungeonfungler:	call ClearScreen	; Show welcome message
		ld bc,mfmsgbanner
		call PrintLine
		ld bc,mfmsgintro
		call PrintLine
		call GetCharSilent
		call ClearScreen
		ld bc,mfmsgbanner
		call PrintLine
		ld bc,mfmsgintro2
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call ClearScreen	

		ld hl,string_buffer	; Store player name
		ld de,mfplayername
		ld bc,10
		ldir
		ld a,0
		ld (mfplayername+9),a	; Ensure a terminated string
		
		ld a,1			; Starting dungeon level = 1
		ld (mfdungeonlev),a
		ld a,0
		ld (mfdungeondir),a	; Set direction -- going down
		
		ld hl,(mfplayername)	; Set the seed
		call SeedRand16
		
		ld a,3			; Set starting stats
		ld (mfplayeratt),a
		ld a,3
		ld (mfplayerdef),a
		ld hl,30
		ld (mfgold),hl
		ld a,250		; DEBUG: WANTON CHEATING!
		ld (mfhp),a
		ld (mfmaxhp),a
		ld a,0
		ld (mfrank),a
		
		ld hl,mfinventory	; Clear inventory
		ld a,0
		ld b,mfmaxinv
mfinvblnkloop:	ld (hl),a
		inc hl
		dec b
		jp nz,mfinvblnkloop
		
		ld (mfequipslothead),a	; Clear equip slots
		ld (mfequipslotbody),a
		ld (mfequipslotfeet),a
		ld (mfequipslothnd1),a
		ld (mfequipslothnd2),a
		
; Level change setup
mfdolevelchng:	ld a,1			; Inhibit the prompt/wait on below call to mfcleartopline
		ld (mfctlfirstcall),a
		call mfcleartopline	; Show stair ascend/descend message
		ld a,(mfdungeondir)
		cp 0
		jp z,mfshowdnmess
		
		call Rand16		; Pick a random up msg
		ld a,l
		and 3
		cp 0
		jp z,mfupmsg1
		cp 1
		jp z,mfupmsg2
		ld bc,mfmsgasc3
		jp mfshowmsg		
mfupmsg1:	ld bc,mfmsgasc1
		jp mfshowmsg
mfupmsg2:	ld bc,mfmsgasc2
		jp mfshowmsg		
		
mfshowdnmess: 	call Rand16		; Pick a random down msg
		ld a,l
		and 3
		cp 0
		jp z,mfdownmsg1
		cp 1
		jp z,mfdownmsg2
		ld bc,mfmsgdec3
		jp mfshowmsg		
mfdownmsg1:	ld bc,mfmsgdec1
		jp mfshowmsg
mfdownmsg2:	ld bc,mfmsgdec2
		jp mfshowmsg		

mfshowmsg:	call PrintString
		call mfbuildmap		; Build the new map
		
		call ClearScreen
		call mfprintinfo	; Print initial infos
				
		ld a,(mfdungeonlev)	; Bottom level? 
		cp mfnumlevels
		jp nz,mfnotbottomlev
		
		ld a,1
		call mfcheckinventory	; User doesn't already have the key?
		cp 1
		jp z,mfskipstairsdn
		
		call mffindfloor	; Add the key!!
		ld a,'F'
		call mfsetcellat

		jp mfskipstairsdn
		
mfnotbottomlev:	call mffindfloor	; Not bottom level; place the stairs down
		ld a,'>'
		call mfsetcellat
		
		ld a,(mfdungeondir)
		cp 1			; Player heading up (entered from below)?
		jp nz,mfskipstairsdn
		
		ld a,d			; Yep - so place player on stairs down
		ld (mfplayerx),a
		ld a,e
		ld (mfplayery),a
		
mfskipstairsdn:	call mffindfloor	; Place stairs up

		ld a,'<'
		call mfsetcellat
		
		ld a,(mfdungeondir)
		cp 0			; Player heading down (entered from above)?
		jp nz,mftick		; No -- so they're already placed, let's play already!
		
		ld a,d			; Yep - so place player on stairs up
		ld (mfplayerx),a
		ld a,e
		ld (mfplayery),a
		
; Main game loop
mftick:		ld a,1			; Tell next mfcleartopline calls that this is a new frame (ie don't show the Press Space message)
		ld (mfctlfirstcall),a
		call mfcalcfov		; Calculate visibility map
		call mfredrawmap	; Redraw dirty map areas
		call mfdrawplayer	; Draw the PC
		jp mfupdateplayer	; Let the PC take their turn
mfplayermvret: 	ld a,(mfprintinfoudp)	; Side panel update needed?
		cp 1
		call z,mfprintinfo	; OK, do it
		call mfupdatemonsters	; Update the monsters

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		ld a,1			; DEBUG: Bottom-line debugger display
		ld d,a
		ld a,console_height
		ld e,a
		call CursorXY
		ld bc,mfmsgblinetest
		call PrintString
		ld hl,0
		add hl,sp
		call PrintHex16
		ld bc,mfmsgblinetest2
		call PrintString
		ld a,(mfplayerx)
		call PrintHex8
		ld a,','
		call PrintChar
		ld a,(mfplayery)
		call PrintHex8
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		jp mftick		; Loop
				
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SIDE PANEL / OTHER UI STUFF ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Prints the sidepanel and bottom line
; Expects: Nowt
; Returns: Nowt
mfprintinfo:	ld a,0			; Reset our printinfo-redraw-needed flag
		ld (mfprintinfoudp),a
		
		ld a,29			; Print info: Side panel
		ld d,a
		ld a,3
		ld e,a
		call CursorXY
				
		ld bc,mfplayername	; Name
		call PrintString
		
		inc e
		call CursorXY
		
		call mfprintrank	; Rank
		
		inc e
		inc e
		call CursorXY
		
		push de
		call mfprintdepth	; Depth
		pop de
		
		ld bc,mfmsgdepth
		call PrintString
		
		inc e
		call CursorXY
		
		ld bc,mfmsggold		; Gold
		call PrintString
		ld hl,(mfgold)
		call PrintUInt16
		
		inc e
		call CursorXY

		ld bc,mfmsghp		; HP
		call PrintString
		ld a,(mfhp)
		ld h,0
		ld l,a
		call PrintUInt16
		ld bc,mfmsgpad2
		call PrintString
		inc e
		call CursorXY
		ld bc,msgofhp
		call PrintString
		ld a,(mfmaxhp)
		ld h,0
		ld l,a
		call PrintUInt16
		
		inc e
		inc e
		call CursorXY
		
		ld bc,mfmsgatt		; Att
		call PrintString
		ld a,(mfplayeratt)
		ld h,0
		ld l,a
		call PrintUInt16
		
		inc e
		call CursorXY
		
		ld bc,mfmsgdef		; Def
		call PrintString
		ld a,(mfplayerdef)
		ld h,0
		ld l,a
		call PrintUInt16
		
		ret
		
; Clears top line and positions cursor ready to print a line there. If this is not the first message received this frame, it'll
; give a "Press space to continue" prompt before blanking the line -- uses (mfctlfirstcall)
; Expects: Nowt
; Returns: Nowt		
mfcleartopline:	ld a,(mfctlfirstcall)
		cp 1			; First call this frame? Skip the wait!
		jp z,mfctlskipwait
		ld d,console_width-1
		ld e,1
		call CursorXY
		ld a,175
		call PrintChar
		call GetCharSilent
mfctlskipwait:	ld a,0			; Set not-first-time-called-this-frame
		ld (mfctlfirstcall),a	
		call CursorHome
		ld bc,mfmsgpad38
		call PrintString
		call CursorHome
		ret

; Prints current dungeon depth in feet
; Expects: Nowt
; Returns: Nowt	
mfprintdepth:	ld a,(mfdungeonlev)	; Current dungeon level (displayed as depth)
		ld b,a
		ld hl,0
		ld de,50
mflevloop:	add hl,de
		dec b
		jp nz,mflevloop
		call PrintUInt16
		ret

; Prints current PC rank
; Expects: Nowt
; Returns: Nowt	
mfprintrank:	ld hl,mfranktbl		; Rank
		ld bc,mfranktblstride
		ld a,(mfrank)
mfpinlp1:	cp 0
		jp z,mfpinlpdn
		add hl,bc
		dec a
		jp mfpinlp1
mfpinlpdn:	ld b,h
		ld c,l
		call PrintString
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAP BUILDING / DRAWING / ACCESS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Checks the seen map for given cell; if not seen, it draws the cell and marks as seen.
; If revealing an unseen cell, has a chance to spawn a monster if the cell's carpet.
; Expects: d,e=x,y
; Returns: a=the map cell
; Trashes: hl
mfsetfovspawnandretchar:	
		push bc
		
		call mfmoveto		; Load mapcell address into hl
		ld b,(hl)		; Backup map char
		
		push de			; Backup xy
		ld de,mfmapwidth*mfmapheight
		add hl,de
		
		ld a,(hl)		; Check the seenmap cell
		cp 0			; Never seen it?
		jp nz,mfmsdifdone	; Skip spawn if we actually have
				
		ld a,b			; Restore the map char
		cp '.'			; Carpet? Then chance to reveal a MONSTER!
		jp nz,mfmsdifdone
		
		push hl
		call Rand16
		ld a,l
		pop hl
		and 15			; Relate this to dungeon level maybe? (Actually, it's fine)
		cp 7
		jp nz,mfmsdifdone
		
		pop de
		push de
		ld b,0			; Ask for a random monster
		push hl
		call mfspawnmonster	; Spawn a monster! NB: It'll return the monster char in b...	
		pop hl
		cp 1			; Did we spawn ok?
		jp z,mfmsdifdone	; Yep -- go ahead and draw the char
		ld b,'.'		; No! Just make it carpet, then
		
mfmsdifdone:	ld a,4			; Mark as seen THIS FRAME
		ld (hl),a
		ld a,b			; Load the char for ret val
		pop de			; Restore xy		
		pop bc
		ret
		
; Expects: Nothing
; Trashes: Everything
mfbuildmap:	;ld hl,(rand16_seed)	; DEBUG: View the seed
		;call PrintHex16	; DEBUG
		;ld a,' '		; DEBUG
		;call PrintChar		; DEBUG
		
		ld d,0			; Blank the door array
		ld (mfdoorindex),a
		ld d,1			; Blank the map
		ld e,1
		ld b,mfmapheight
		ld c,mfmapwidth
		ld a,' '
		call mffillrect		; Expects: d=startx, e=starty, b=height, c=width

		ld a,0			; Reset seen map
		ld de,mfseenmap
		ld h,mfmapheight
mfbsmoloop:	ld l,mfmapwidth
mfbsmiloop:	ld (de),a
		inc de
		dec l
		jp nz,mfbsmiloop
		dec h
		jp nz,mfbsmoloop
		
		ld hl,mfmonsters	; Clear monsters
		ld a,0
		ld b,mfmaxmonsters
mfmnstblnkloop:	ld (hl),a
		inc hl
		ld (hl),a
		inc hl
		ld (hl),a
		inc hl
		ld (hl),a
		inc hl
		ld (hl),a
		inc hl		
		dec b
		jp nz,mfmnstblnkloop		
		
		ld d,$FF		; LOOP: Place rooms (FF max placement attempts)...
mfbmaplp:	push de			

		call Rand16		; Pick a width and height
		ld a,l
		and 7
		add a,4
		ld c,a			; W

		call Rand16		
		ld a,l
		and 7
		add a,4
		ld b,a			; H

		call Rand16
		ld a,l
		and 15
		add a,4
		ld d,a			; X

		call Rand16
		ld a,l
		and 15
		add a,4
		ld e,a			; Y

		ld a,c			; Check bounds, jp to next if no good
		add a,d
		cp mfmapwidth
		jp nc,mfbmaplpnext
		
		ld a,b
		add a,e
		cp mfmapheight
		jp nc,mfbmaplpnext
		
		dec d
		dec e
		inc b
		inc b
		inc c
		inc c
		call mftestfillrect	; Check the space (+ gap) is actually free, jp to next if not
		cp 0
		jp nz,mfbmaplpnext
		inc d
		inc e
		dec b
		dec b
		dec c
		dec c
		
		call mfdig		; Looks good! Dig the room, dog
		
mfdoorstart:	call Rand16		; Pick a wall for the door :)
		ld a,l
		and 3
		cp 0
		jp z,mfdoor2
		cp 1
		jp z,mfdoor3
		cp 2
		jp z,mfdoor4

mfdoor1:	ld a,h			; Left-hand wall: Just inc e between 1 and height-1 (b)
		and 7
		ld h,a
		ld l,b
		dec l
		dec l
		call Div8
		inc a
		
		add a,e
		ld e,a
		
		jp mfdoordone

mfdoor2:	ld a,d			; Right-hand wall: Inc d by width-1 (c) then inc e between 1 and height-1 (b)
		add a,c
		dec a
		ld d,a
		
		and 7
		ld h,a
		ld l,b
		dec l
		dec l
		call Div8
		inc a

		add a,e
		ld e,a
		
		jp mfdoordone

mfdoor3:	ld a,h			; Top wall: Inc d between 1 and width-1 (c)
		and 7
		ld h,a
		ld l,c
		dec l
		dec l
		call Div8
		inc a
		
		add a,d
		ld d,a
				
		jp mfdoordone		

mfdoor4:	ld a,e			; Bottom wall: Inc e by height-1 (b) then inc d between 1 and width-1 (c)
		add a,b
		dec a
		ld e,a
		
		and 7
		ld h,a
		ld l,c
		dec l
		dec l
		call Div8
		inc a
		
		add a,d
		ld d,a
		
mfdoordone:	ld hl,mfdoorarray	; Write the door pos into the door array
		ld a,(mfdoorindex)
		ld b,0
		ld c,a
		add hl,bc		; Step to current blank pos		
		add hl,bc		; (2 bytes per entry!)
		
		ld (hl),d		; Write the door x and y...
		inc hl
		ld (hl),e
		inc a			; Inc array counter and store it
		ld (mfdoorindex),a
		
		ld a,'.'		; Set the door as actual map carpet to make it a fungletarget
		call mfsetcellat
		
		call Rand16		; 1-in-16 chance for another door!!
		ld a,l
		and 15
		cp 0
		jp z,mfdoorstart
		
mfbmaplpnext:	pop de
		dec d
		jp nz,mfbmaplp

		ld hl,mfdoorarray	; LOOP: Step through door array, digging paths
		ld a,(mfdoorindex)
		ld b,a		
mfdoorloop:	ld d,(hl)
		inc hl
		ld e,(hl)
		inc hl		
		call mffungle		; Start Horace from (d,e)
		cp 0			; Check return value....
		
		jp z,mfbuildmap		; Shit, we couldn't fungle! Go back to the start of the whole damn thing!

		push bc			; Set a door character where the door was...
		push de
		push hl
		ld a,'+'
		call mfsetcellat
		pop hl
		pop de
		pop bc
		
		dec b
		jp nz,mfdoorloop

		ld d,'='		; Now replace all temp floor in rooms with actual floor :)
		ld e,'.'
		call mfmapreplace
		
		ld e,mfmapheight	; LOOP: Step through map, adding walls around corridors
mfwallfoloop:	ld d,mfmapwidth
mfwallfiloop:	call mfgetcellat
		cp ' '
		jp nz,mfwallfnext
		inc d			; OK, this cell's a space! Check its neighbours for carpet/doors....
		call mfgetcellat
		dec d
		cp '.'
		jp z,mfwallcarfnd
		dec d
		call mfgetcellat
		inc d
		cp '.'
		jp z,mfwallcarfnd
		inc e
		call mfgetcellat
		dec e
		cp '.'
		jp z,mfwallcarfnd
		dec e
		call mfgetcellat
		inc e
		cp '.'
		jp z,mfwallcarfnd		

		inc d			; Skipping this block gives rounded corners....
		inc e
		call mfgetcellat
		dec d
		dec e
		cp '.'
		jp z,mfwallcarfnd
		dec d
		dec e
		call mfgetcellat
		inc d
		inc e
		cp '.'
		jp z,mfwallcarfnd
		dec d
		inc e
		call mfgetcellat
		inc d
		dec e
		cp '.'
		jp z,mfwallcarfnd
		inc d
		dec e
		call mfgetcellat
		dec d
		inc e
		cp '.'
		jp z,mfwallcarfnd		
		
mfwallfnext:	dec d			; Next cell
		jp nz,mfwallfiloop		
		dec e
		jp nz,mfwallfoloop
		
		ld b,8			; All walls and carpet now added; let's add some furniture..
mfpuddleloop:	call mffindfloor	; Add some puddles!
		ld a,'~'
		call mfsetcellat
		
		call Rand16
		ld a,l
		and 15
		jp nz,mfskipsword
		
		call mffindfloor	; DEBUG: Add some longswords!
		ld a,'l'
		call mfsetcellat

mfskipsword:	call Rand16
		ld a,l
		and 15
		jp nz,mfskippotion

		call mffindfloor	; DEBUG: Add some potions!
		ld a,173
		call mfsetcellat

mfskippotion:	call Rand16
		ld a,l
		and 8
		jp nz,mfskipgold
		
		call mffindfloor	; DEBUG: Add some delicious gold!
		ld a,'$'
		call mfsetcellat
		
mfskipgold:	dec b
		jp nz,mfpuddleloop
		
		ret
		
mfwallcarfnd:	ld a,178		; Carpet found in neighbour! Set current cell to wall
		call mfsetcellat
		jp mfwallfnext
				
; A friendly mole called Horace fungles his way from (d,e) until he finds delicious carpet
; Expects: d=x, e=y
; Trashes: d, e
mffungle:	call NewLine
		ld a,$FF
		ld (scratch_base),a
		push hl
		push bc
mffungletryagn:	push de
		ld a,(scratch_base)
		dec a
		ld (scratch_base),a
		ld b,$FF		; Max steps
mffungleloop:	dec b			; Check max step counter
		jp z,mfdonebail
		ld a,d			; Check x bounds
		cp 26
		jp nc,mfdonebail
		jp z,mfdonebail
		cp 1
		jp z,mfdonebail
		ld a,e			; Check y bounds
		cp mfmapheight-1
		jp nc,mfdonebail
		jp z,mfdonebail
		cp 1
		jp z,mfdonebail
		ld a,'!'		; Set current cell to temp carpet (we'll replace later with actual carpet -- just don't want to collide with self and think done!)
		call mfsetcellat
		
		call Rand16		; OK, let's have a look around for some space! Pick a direction to try first randomly (but only allow each dir to be tried once)
		ld a,l
		and 00000011b
		
		ld c,5			; Only allow each of the 4 directions to be tried once (pre-decrement)
		
		cp 1
		jp z,mftrydir2
		cp 2
		jp z,mftrydir3
		cp 3
		jp z,mftrydir4
		
mftrydir1:	dec c			; Pre-decrement remaining tries
		jp z,mfdonebail		; and bail out if tried all 4
		
		dec d			; Step in x
		call mfgetcellat
		cp ' '			; Empty? Go that way!
		jp z,mffungleloop
		cp '.'			; Next to carpet? We're done!
		jp z,mfdoneok		
		inc d			; Not empty OR door; step back to current cell
				
mftrydir2:	dec c
		jp z,mfdonebail
		
		dec e
		call mfgetcellat
		cp ' '
		jp z,mffungleloop
		cp '.'
		jp z,mfdoneok		
		inc e
		
mftrydir3:	dec c
		jp z,mfdonebail
		
		inc d
		call mfgetcellat
		cp ' '
		jp z,mffungleloop
		cp '.'
		jp z,mfdoneok
		dec d
		
mftrydir4:	dec c
		jp z,mfdonebail
		
		inc e
		call mfgetcellat
		cp ' '
		jp z,mffungleloop
		cp '.'
		jp z,mfdoneok				
		dec e
		
		jp mftrydir1		; Loop back to the start (we randomly jumped in somewhere remember, and c's not 0 so there are dirs left to try)
		
mfdoneok:	ld d,'!'		; Door reached; replace temp with actual carpet!
		ld e,'.'
		call mfmapreplace
		pop de
		pop bc
		pop hl
		ld a,1			; Mark success
		ret		
		
mfdonebail:	ld d,'!'		; Outta tries, or stuck; roll back!
		ld e,' '
		call mfmapreplace	
		pop de
				
		ld a,(scratch_base)
		cp 0
		jp nz,mffungletryagn
				
		ld a,0			; Mark failure :(
		pop bc
		pop hl		
		ret
				
; Replaces all instances of a char with another char in the map
; Expects: d=char to replace, e=replacement
; Trashes: Stuff...
mfmapreplace:	ld bc,mfmap
		ld h,mfmapheight
mfmaproloop:	ld l,mfmapwidth
mfmapriloop:	ld a,(bc)
		cp d
		jp nz,mfmaprnext
		ld a,e
		ld (bc),a
mfmaprnext:	inc bc
		dec l
		jp nz,mfmapriloop
		dec h
		jp nz,mfmaproloop
		ret
		
; Expects: d=x, e=y, c=width, b=height
mfdig:		push de
		push bc
		ld a,219
		call mffillrect
		inc d
		inc e
		dec c
		dec c
		dec b
		dec b
		ld a,'='		; Note use of a temp char -- prevents Horace thinking it's actually carpet yet!
		call mffillrect
		pop bc
		pop de
		ret

; Expects: d=x, e=y
; Returns: Memory address of cell in hl
mfmoveto:	push bc
		push de
		ex af,af'
		ld bc,mfmapwidth
		ld hl,mfmap
		ld a,e
mfmovetolp1:	cp 1
		jp z,mfmtlp1done
		add hl,bc
		dec a
		jp mfmovetolp1
mfmtlp1done:	dec d
		ld e,d
		ld d,0
		add hl,de
		ex af,af'
		pop de
		pop bc
		ret

; Expects: d=startx, e=starty, b=height, c=width
; Returns: a=0 if space clear, a=1 if not
mftestfillrect:	push bc
		push de
		push hl
		call mfmoveto		; hl is now address of TL cell
		ld a,mfmapwidth		; Calculate stride, store in e
		sub c
		ld e,a
		ld d,c			; Backup width, store in d
mftestfoloop:	ld c,d
mftestfiloop:	ld a,(hl)		
		cp ' '
		jp nz,mftestfillbad
		
		inc hl
		dec c
		jp nz,mftestfiloop
		dec b
		push de
		ld d,0
		add hl,de
		pop de
		jp nz,mftestfoloop

		ld a,0
		jp mftestfilldn
		
mftestfillbad:	ld a,1

mftestfilldn:	pop hl
		pop de
		pop bc
		
		ret
		
; Expects: a=fill character, d=startx, e=starty, b=height, c=width
; Returns: Nothing
; Trashes: Nothing
mffillrect:	push bc
		push de
		push hl
		call mfmoveto		; hl is now address of TL cell
		ex af,af'		; Backup a (it's the fill char)
		ld a,mfmapwidth		; Calculate stride, store in e
		sub c
		ld e,a
		ld d,c			; Backup width, store in d
		ex af,af'		; Restore a
mffillloloop:	ld c,d
mffillliloop:	ld (hl),a
		inc hl
		dec c
		jp nz,mffillliloop
		dec b
		push de
		ld d,0
		add hl,de
		pop de
		jp nz,mffillloloop
		pop hl
		pop de
		pop bc
		ret
		
; Calculates the fov map
; Expects: Nowt
; Returns: Nowt		
mfcalcfov:	ld a,(mfplayerx)
		ld d,a
		ld a,(mfplayery)
		ld e,a
		
		dec d
		dec e
		call mfcalcfoviter
		inc d
		call mfcalcfoviter		
		inc d
		call mfcalcfoviter		
		dec d
		dec d
		inc e
		call mfcalcfoviter		
		inc d
		call mfcalcfoviter
		inc d
		call mfcalcfoviter
		
		dec d
		dec d
		inc e
		call mfcalcfoviter		
		inc d
		call mfcalcfoviter
		inc d
		call mfcalcfoviter		

		ret
		
; Does one simple fov star
; Expects: de - x,y star center point
mfcalcfoviter:	call mfgetcellat
		cp 178
		ret z
		cp 219
		ret z
		cp ' '
		ret z

		push de				
		ld b,mfmaxlos
mfdplp1:	dec e			; Step up
		jp z,mfdplp1dn
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp1dn
		cp 219
		jp z,mfdplp1dn
		cp ' '
		jp z,mfdplp1dn
		dec b
		jp z,mfdplp1dn
		jp mfdplp1
mfdplp1dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp2:	inc e			; Step down
		ld a,e
		cp mfmapheight
		jp z,mfdplp2dn
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp2dn
		cp 219
		jp z,mfdplp2dn		
		cp ' '
		jp z,mfdplp2dn		
		dec b
		jp z,mfdplp2dn
		jp mfdplp2
mfdplp2dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp3:	dec d			; Step left
		jp z,mfdplp3dn
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp3dn
		cp 219
		jp z,mfdplp3dn		
		cp ' '
		jp z,mfdplp3dn		
		dec b
		jp z,mfdplp3dn
		jp mfdplp3
mfdplp3dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp4:	inc d			; Step right
		ld a,d
		cp mfmapwidth
		jp z,mfdplp4dn
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp4dn
		cp 219
		jp z,mfdplp4dn		
		cp ' '
		jp z,mfdplp4dn		
		dec b
		jp z,mfdplp4dn
		jp mfdplp4
mfdplp4dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp5:	dec d			; Step up-left
		jp z,mfdplp5dn
		dec e
		jp z,mfdplp5dn			
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp5dn
		cp 219
		jp z,mfdplp5dn	
		cp ' '
		jp z,mfdplp5dn		
		dec b
		jp z,mfdplp5dn
		jp mfdplp5
mfdplp5dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp6:	inc d			; Step up-right
		ld a,d
		cp mfmapwidth
		jp z,mfdplp6dn
		dec e
		jp z,mfdplp6dn		
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp6dn
		cp 219
		jp z,mfdplp6dn	
		cp ' '
		jp z,mfdplp6dn		
		dec b
		jp z,mfdplp6dn
		jp mfdplp6
mfdplp6dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp7:	inc e			; Step down-left
		ld a,e
		cp mfmapheight
		jp z,mfdplp7dn
		dec d
		jp z,mfdplp7dn		
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp7dn
		cp 219
		jp z,mfdplp7dn	
		cp ' '
		jp z,mfdplp7dn		
		dec b
		jp z,mfdplp7dn
		jp mfdplp7
mfdplp7dn:	pop de

		push de				
		ld b,mfmaxlos
mfdplp8:	inc e			; Step down-right
		ld a,e
		cp mfmapheight
		jp z,mfdplp8dn
		inc d
		ld a,d
		cp mfmapwidth	
		jp z,mfdplp8dn			
		call mfsetfovspawnandretchar
		cp 178
		jp z,mfdplp8dn
		cp 219
		jp z,mfdplp8dn
		cp ' '
		jp z,mfdplp8dn		
		dec b
		jp z,mfdplp8dn
		jp mfdplp8
mfdplp8dn:	pop de

		ret
	
; Expects: d=x, e=y
; Returns: a=cell contents
; Trashes: hl, bc
mfgetcellat:	call mfmoveto
		ld a,(hl)
		ret

; Expects: d=x, e=y, a=cell contents
; Returns: Nowt
; Trashes: hl, bc
mfsetcellat:	call mfmoveto
		ld (hl),a
		ret

; Picks a blank bit of floor
; Returns: de=xy
mffindfloor:	push hl
		push bc
		ld b,$FF		; Max attempts
mffindfloorlp:	call Rand16		; Pick random xy
		ld a,l
		and 31
		inc a
		cp mfmapheight
		jp nc,mffindfloorlp
		ld e,a
mffindfloorretryx:
		call Rand16
		ld a,l
		and 31
		inc a
		cp mfmapwidth
		jp nc,mffindfloorretryx
		ld d,a
		call mfgetcellat	; Check for floor
		cp '.'
		jp z,mffindfloordn
		dec b
		jp nz,mffindfloorlp
mffindfloordn:	pop bc
		pop hl
		ret
		
; Expects: Nowt
mfredrawmapfull:
		call CursorHome
		ld bc,mfmap
		ld de,mfseenmap
		ld h,mfmapheight
mfdrawfoloop:	ld l,mfmapwidth
mfdrawfiloop:	ld a,(de)
		cp 1			; Has this cell been seen (in memory)?
		jp z,mffmemcheck
		cp 2			; In view RIGHT NOW?!
		jp z,mffdrawactual
		ld a,' '
		jp mfdrawfdodraw
mffmemcheck:	ld a,(bc)
		cp 219
		jp z,mfdrawfmem1
		cp 178		
		jp z,mfdrawfmem2
		ld a,' '
		jp mfdrawfdodraw
mfdrawfmem1:	ld a,177
		jp mfdrawfdodraw
		
mfdrawfmem2:	ld a,176
mfdrawfdodraw:	call PrintChar		; MARK: DIRECT-RENDERING
		inc bc
		inc de
		dec l
		jp nz,mfdrawfiloop		
		call NewLine
		dec h
		jp nz,mfdrawfoloop	
		ret
		
mffdrawactual:	ld a,(bc)
		jp mfdrawfdodraw

; (just regions marked as seen)
; Expects: Nowt
mfredrawmap:	ld bc,mfmap
		ld de,mfseenmap
		ld h,mfmapheight
mfdrawoloop:	ld l,mfmapwidth
mfdrawiloop:	ld a,(de)
		cp 4			; Is this cell currently in FOV?
		jp z,mfdrawfull
		cp 2			; Has this cell GONE OUT OF FOV?
		jp z,mfdrawandmark1

		jp mfshlooop

mfdrawfull:	ld a,2			; Set to maybe-going-out-of-fov
		ld (de),a
		ld a,(bc)
		jp mfdrawdodraw
		
mfdrawmem1:	ld a,177
		jp mfdrawdodraw

mfdrawmem2:	ld a,176

mfdrawdodraw:	push af			; Set the goddam cursor
		push de
		ld a,mfmapwidth
		sub l
		inc a
		ld d,a
		ld a,mfmapheight
		sub h
		inc a
		ld e,a
		
		ld a,(mfplayerx)	; Is this really the player?!
		cp d
		jp nz,mfdrawreallydraw
		ld a,(mfplayery)
		cp e
		jp nz,mfdrawreallydraw
		pop de
		pop af
		jp mfshlooop
		
mfdrawreallydraw:		
		push hl
		call CursorXY
		pop hl
		pop de
		pop af		
		call PrintChar		; MARK: DIRECT-RENDERING
mfshlooop:	inc bc
		inc de
		dec l
		jp nz,mfdrawiloop
		dec h
		jp nz,mfdrawoloop	
		ret

mfdrawandmark1: ld a,1			; Set to seen-but-not-in-fov
		ld (de),a
		ld a,(bc)
		cp 219
		jp z,mfdrawmem1
		cp 178		
		jp z,mfdrawmem2
		ld a,' '
		jp mfdrawdodraw
		
; Expects: Nowt
; Returns: Nowt
mfdrawplayer:	ld a,(mfplayerx)
		ld d,a
		ld a,(mfplayery)
		ld e,a
		;inc e			; Account for fact that screen coords are 1 pix down from map coords!
		call CursorXY
		ld a,'@'
		call PrintChar
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLAYER MOVEMENT / COMBAT / ACTIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check player movement, with bounds + coldet checking
; Expects: Nothing
; Returns: a=0 if movement occured; a=1 if none occured; a=2 if stairs down encountered; a=3 if stairs up encountered
; NOTE: USES JP NOT CALL/RET -- To allow this routine to send player to new maps without breaking stack
mfupdateplayer:
		;call ScanChar		; Uncomment this for crazy realtime mode :P
mfupdplykeylp:	call GetCharSilent	; (and comment this, obviously!)
		cp 'w'
		jp z,mfplayerup
		cp ' '
		jp z,mfplayeraction
		cp 's'
		jp z,mfplayerdown
		cp 'a'
		jp z,mfplayerleft
		cp 'd'
		jp z,mfplayerright
		cp 'r'
		jp z,mfplayermvret
		cp 'q'
		jp z,mfquit
		cp 'i'
		call z,mfshowinv
		jp mfupdplykeylp
		
mfplayerup:	ld a,(mfplayery)
		dec a
		cp 0
		jp z,mfplayermvret
		ld e,a
		ld a,(mfplayerx)
		ld d,a
		call mfgetcellat
		cp 178
		jp z,mfplayermvret
		cp 219
		jp z,mfplayermvret
		jp mfmovementdone
		
mfplayerdown:	ld a,(mfplayery)	
		inc a
		cp mfmapheight+1
		jp z,mfplayermvret
		ld e,a
		ld a,(mfplayerx)
		ld d,a
		call mfgetcellat
		cp 178
		jp z,mfplayermvret
		cp 219
		jp z,mfplayermvret
		jp mfmovementdone

mfplayerleft:	ld a,(mfplayerx)
		dec a
		cp 0
		jp z,mfplayermvret
		ld d,a
		ld a,(mfplayery)
		ld e,a
		call mfgetcellat
		cp 178
		jp z,mfplayermvret
		cp 219
		jp z,mfplayermvret
		jp mfmovementdone
		
mfplayerright:	ld a,(mfplayerx)
		inc a
		cp mfmapwidth+1
		jp z,mfplayermvret	
		ld d,a
		ld a,(mfplayery)
		ld e,a
		call mfgetcellat
		cp 178
		jp z,mfplayermvret
		cp 219
		jp z,mfplayermvret		
mfmovementdone:	push af
		call mfgetmonsteridbychar	; Where are we going? Monster?
		cp 0
		jp nz,mfmeleeattack

		pop af
		push de
		call mfgetitemidbychar	; No; item?
		cp 0
		jp nz,mfshowiteminfo	; Yes!!

		ld bc,mfmsgpad10	; No :/
		ld d,29
		ld e,20
		call CursorXY
		call PrintString
		inc e
		call CursorXY
		call PrintString
		inc e
		call CursorXY
		call PrintString

		jp mfiteminfodone

mfshowiteminfo:	push af
		ld d,29			; Yep, an item!
		ld e,20
		call CursorXY	
		call Rand16
		ld a,l
		and 1
		cp 0
		jp z,mfshowiteminf1
		ld bc,mfmsgthereis2
		jp mfshowiteminf
mfshowiteminf1:	ld bc,mfmsgthereis1
mfshowiteminf:	call PrintString
		ld d,29
		ld e,21
		call CursorXY
		pop af
		call mfgetitemrecordbyid
		call PrintString
		ld d,29
		ld e,22
		call CursorXY
		ld bc,mfmsghere
		call PrintString
		
mfiteminfodone:	pop de
		ld a,d
		ld (mfplayerx),a
		ld a,e
		ld (mfplayery),a
		jp mfplayermvret	; Note no ret!
		
mfplayeraction:	ld a,(mfplayerx)	; Player pressed space
		ld d,a
		ld a,(mfplayery)
		ld e,a
		call mfgetcellat	; Grab the current cell
		
		push de			; Push coords
		call mfgetitemidbychar	; Check t'see if it's an Item?
		pop de			; Pop coords
		cp 0
		jp z,mfplayermvret	; Nothing we recognise...
		
		; It IS an item! Fire its activate handler...		
		ld (scratch_base),a	; Just put that there for a sec (item ID)!
		call mfgetitemrecordbyid
		push bc
		ld h,b
		ld l,c
		ld bc,15
		add hl,bc
		ld b,(hl)		; Grab update jump address...
		inc hl
		ld c,(hl)
		ld h,c			; Prepare jump address in hl
		ld l,b
		pop bc			; Restore the master record
		ld a,(scratch_base)	; Restore the item ID (xy coords of activation square handily still in de)
		jp (hl)			; Jump to the event handler....
mfitemactretpoint:			; ... which'll jump back here		
		jp mfplayermvret
		
mfmeleeattack:	; Attacking monster in (d,e); a=monster type -- but we need to match it against the live monster table by coords
		pop af			; Housekeeping..
		call mfgetlivemonsterbycoords
		push de
		push hl
		ld c,0
		ld a,(hl)		; Get target's type and do a name lookup
		call mfgetmonsterecordbyid
		push hl			; Push array record
		ld d,29
		ld e,16
		call CursorXY		
		ld bc,mfmsgtarget
		call PrintString
		ld d,29
		ld e,17
		call CursorXY
		pop hl
		ld b,h
		ld c,l
		push hl			; Push master record
		call PrintString

		call mfcleartopline
		
		call Rand16		; Pick a random attack msg
		ld a,l
		and 3
		cp 0
		jp z,mfstrikemsg1
		cp 1
		jp z,mfstrikemsg2
		cp 2
		jp z,mfstrikemsg3
		ld bc,mfmsgstrike4
		jp mfshowstrikemsg	
mfstrikemsg1:	ld bc,mfmsgstrike1
		jp mfshowstrikemsg
mfstrikemsg2:	ld bc,mfmsgstrike2
		jp mfshowstrikemsg		
mfstrikemsg3:	ld bc,mfmsgstrike3
		jp mfshowstrikemsg		

mfshowstrikemsg:
		call PrintString
		pop hl			; Pop master record
		
		; Run the combat model calcs for PC attacking NPC and stick final damage inflicted in a (or 0 for a miss)
		ld de,13		; Step to monster's DEF
		add hl,de
		ld a,(hl)
		ld d,a			; Store monster's DEF in d
		ld a,(mfplayeratt)
		add a,d			; a = att + def
		ld l,a			; l <-- att+def
		ld a,(mfplayeratt)
		rla
		rla
		rla
		rla
		ld h,a			; h <-- att * 16
		call Div8		; h = (att * 16) / (att+def) -> ie h = required roll, 0-15		
;		ld a,h			; DEBUG: FOR CHANCE-TO-HIT DISPLAY
;		ld (scratch_base+7),a	; DEBUG: FOR CHANCE-TO-HIT DISPLAY		
		push hl			; Backup chance-to-hit ((att*16) / (att+def))
		call Rand16		; Roll a d16 ;)
		ld a,l
		and 15
;		ld (scratch_base+8),a	; DEBUG: FOR CHANCE-TO-HIT DISPLAY
		pop hl			; Restore chance-to-hit
		cp 0
		jp z,mfmeleecrithit	; Crit hit!
		cp h
		jp c,mfmeleehit		; Regular hit!
		jp z,mfmeleeshithit	; Glancing blow!
		ld a,0			; Ooooh, that's a bad miss!
		jp mfmeleecalcdn		

mfmeleecrithit:	ld a,(mfplayeratt)	; Crit Hit! DMG = ATT * 2
		add a,a
		jp mfmeleecalcdn

mfmeleeshithit:	ld a,(mfplayeratt)	; Shit Hit! DMG = ATT/2
		ld h,a
		ld l,2
		call Div8
		ld a,h
		jp mfmeleecalcdn
													
mfmeleehit:	ld a,(mfplayeratt)	; Regular hit! DMG = ATT
		
mfmeleecalcdn:	ld (scratch_base),a
		pop hl			; Pop local array record -- for to update target's HP
		push hl
		inc hl
		inc hl
		inc hl
		ld a,(scratch_base)
		ld d,a
		ld a,(hl)		; Get target's hitpoints
		sub d
		jp z,mfkillmonster		
		jp c,mfkillmonster
		ld (hl),a		
		push af
		
		ld a,(scratch_base)
		cp 0
		jp z,mfpickmissmsg
		ld d,a									
		ld a,(mfplayeratt)	; Compare with player's ATT
		cp d							
		jp z,mfreghit						
		jp c,mfcrithit						
									
		ld bc,mfmsgshithit					
		jp mfshowhitmissmsg					
									
mfcrithit:	ld bc,mfmsgcrithit					
		jp mfshowhitmissmsg					
									
mfreghit:	call Rand16		; Pick a random hit msg
		ld a,l
		and 3
		cp 0
		jp z,mfhitmsg1
		cp 1
		jp z,mfhitmsg2
		cp 2
		jp z,mfhitmsg3
		ld bc,mfmsghit4
		jp mfshowhitmissmsg	
mfhitmsg1:	ld bc,mfmsghit1
		jp mfshowhitmissmsg
mfhitmsg2:	ld bc,mfmsghit2
		jp mfshowhitmissmsg		
mfhitmsg3:	ld bc,mfmsghit3
		jp mfshowhitmissmsg

mfpickmissmsg:  call Rand16		; Pick a random miss msg
		ld a,l
		and 3
		cp 0
		jp z,mfmissmsg1
		cp 1
		jp z,mfmissmsg2
		cp 2
		jp z,mfmissmsg3
		ld bc,mfmsgmiss4
		jp mfshowhitmissmsg	
mfmissmsg1:	ld bc,mfmsgmiss1
		jp mfshowhitmissmsg
mfmissmsg2:	ld bc,mfmsgmiss2
		jp mfshowhitmissmsg		
mfmissmsg3:	ld bc,mfmsgmiss3
		jp mfshowhitmissmsg		

mfshowhitmissmsg:   
		call PrintString
		
		ld a,(scratch_base)
		cp 0
		jp z,mfskipdmgmsg
		ld h,0
		ld l,a
		call PrintUInt16	
		ld bc, mfmsgdamage
		call PrintString
		
mfskipdmgmsg:	;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;push hl			; DEBUG: Display max roll against our roll
		;ld d,console_width-9
		;ld e,2
		;call CursorXY
		;ld a,(scratch_base+7)
		;ld l,a
		;ld h,0
		;call PrintUInt16
		;ld a,':'
		;call PrintChar
		;ld a,(scratch_base+8)
		;ld l,a
		;ld h,0
		;call PrintUInt16		
		;ld a,' '
		;call PrintChar
		;call PrintChar
		;pop hl
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		pop af			; Print sidepanel stuff
		push af
		ld d,29			
		ld e,18
		call CursorXY
		ld bc,mfmsghp
		call PrintString
		pop af
		ld h,0
		ld l,a
		call PrintUInt16
		ld bc,mfmsgpad3
		call PrintString		
		pop hl
		pop de
		jp mfplayermvret
		
mfkillmonster:	pop hl
		pop de
		ld a,0
		ld (hl),a		; Blank the monster's entry in live monster table: Type
		inc hl
		ld (hl),a		; x
		inc hl
		ld (hl),a		; y
		inc hl
		ld (hl),a		; hp
		inc hl		
		ld a,(hl)
		push hl
		call mfsetcellat
		
mfpickvanqmsg:  call Rand16		; Pick a random vanquished msg
		ld a,l
		and 3
		cp 0
		jp z,mfvanqmsg1
		cp 1
		jp z,mfvanqmsg2
		cp 2
		jp z,mfvanqmsg3
		ld bc,mfmsgvanq4
		jp mfshowhitvanqmsg	
mfvanqmsg1:	ld bc,mfmsgvanq1
		jp mfshowhitvanqmsg
mfvanqmsg2:	ld bc,mfmsgvanq2
		jp mfshowhitvanqmsg		
mfvanqmsg3:	ld bc,mfmsgvanq3
		jp mfshowhitvanqmsg		

mfshowhitvanqmsg:   
		call PrintString

		pop hl		
		ld d,29
		ld e,18
		call CursorXY
		ld bc,mfmsgmnstrdead
		call PrintString
		
		ld a,1			; Mark PrintInfo update needed
		ld (mfprintinfoudp),a
		
		jp mfplayermvret
		
mfquit:		call ClearScreen
		jp shell
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INVENTORY / ITEMS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Shows the inventory screen
; Expects: Nothing
; Returns: Nothing
mfshowinv:	call ClearScreen
		ld bc,mfmsginv
		call PrintLine
		call NewLine
		ld b,mfmaxinv
		ld c,'a'
		ld d,0
		ld hl,mfinventory
mfshowinvlp:	ld a,(hl)
		cp 0
		jp nz,mfinvlistitem
mfshowinvlpcnt:	inc c
		inc hl
		dec b
		jp nz,mfshowinvlp
		jp mfinvprompt
mfinvlistitem:	push bc
		push hl
		ld d,a
		ld a,c
		call PrintChar
		ld a,':'
		call PrintChar
		ld a,ascii_tab
		call PrintChar
		ld a,d
		call mfgetitemrecordbyid
		call PrintString
		call NewLine
		pop hl
		pop bc
		inc d
		jp mfshowinvlpcnt
mfinvprompt:	call NewLine
		ld a,d
		cp 0
		jp z,mflstnoitems
		ld bc,mfmsginvprompt
		call PrintLine
		call GetChar
		call NewLine
		cp 'e'
		jp z,mfinvequip
		cp 'd'
		jp z,mfinvdrop
		cp 'x'
		jp z,mfinvexit
		jp mfshowinv
mflstnoitems:	ld bc,msgnoitems
		call PrintString
		call GetCharSilent
		jp mfinvexit
mfinvexit:	call ClearScreen	; Full screen redraw process: Clear the screen...
		call mfredrawmapfull	; Draw the memory map
		;call mfcalcfov		; Calc fov
		;call mfredrawmap	; Draw active FoV regions
		call mfdrawplayer	; Draw the player
		call mfprintinfo	; Draw sidebar
		call mfcleartopline
		ld bc,mfmsginvclose
		call PrintString
		ret
mfinvdrop:	ld hl,mfinventory
		ld bc,mfmsgdropsel
		call PrintLine
		call GetChar
		call NewLine
		sub 97
		cp mfmaxinv
		jp nc,mfinvbaditem
mfdropsellp:	cp 0
		jp z,mfdropseldn
		dec a
		inc hl
		jp mfdropsellp
mfdropseldn:	ld a,(hl)		; a now contains table ID of chosen item, and hl is item's address in inv
		cp 0
		jp z,mfinvbaditem
		push hl
		call mfgetitemcharbyid	; a=map char of item, hl=item's inv address
		pop hl
		ld b,a			; Backup A (it's the item char)
		ld a,(mfplayerx)	; de contains player's xy
		ld d,a
		ld a,(mfplayery)
		ld e,a
		push bc
		push hl
		call mfgetcellat	; Check for a gap at player's location
		pop hl
		pop bc
		cp '.'
		jp nz,mfinvdropnorm
		ld a,b			; OK -- Restore A		
		push hl
		call mfsetcellat	; Place the item down
		pop hl
		ld a,0
		ld (hl),a		; Remove item from inv
		jp mfinvexit
mfinvdropnorm:	ld bc,mfmsgnodrprm
		call PrintLine
		call GetCharSilent
		jp mfinvexit
mfinvbaditem:	ld bc,mfmsgbaditem
		call PrintLine
		call GetCharSilent
		jp mfinvexit
mfinvequip:	; TODO: Implement me
		jp mfshowinv		

; Checks for presence of an item by ID
; Expects: a=item ID
; Returns: a=1 if found, a=0 if not
mfcheckinventory:
		ld b,mfmaxinv
		ld c,a
		dec b
		ld hl,mfinventory
mfchkinvlp:	ld a,(hl)
		cp c
		jp z,mfchkinvfnd
		inc hl
		dec b
		jp nz,mfchkinvlp
		ld a,0
		ret
mfchkinvfnd:	ld a,1
		ret

; Finds an empty slot and adds the item
; Expects: a=Item ID
; Returns: a=1 on success, a=0 on failure (inv full)
mfaddinventory:	ld c,mfmaxinv
		ld b,a
		ld hl,mfinventory
mfaddinvloop:	ld a,(hl)
		cp 0
		jp z,mfaddinvdoit
		inc hl
		dec c
		jp z,mfinvfull
		jp mfaddinvloop
mfaddinvdoit:	ld (hl),b
		push bc
		call mfcleartopline
						
		call Rand16		; Pick a random picked-up msg
		ld a,l
		and 3
		cp 0
		jp z,mfpupmsg1
		cp 1
		jp z,mfpupmsg2
		cp 2
		jp z,mfpupmsg3
		ld bc,mfmsgpickup4
		jp mfshowpupmsg	
mfpupmsg1:	ld bc,mfmsgpickup1
		jp mfshowpupmsg
mfpupmsg2:	ld bc,mfmsgpickup2
		jp mfshowpupmsg		
mfpupmsg3:	ld bc,mfmsgpickup3
		jp mfshowpupmsg		

mfshowpupmsg:	call PrintString
		pop bc
		ld a,b
		call mfgetitemrecordbyid		
		call PrintString
		ld a,1
		ret
mfinvfull:	call mfcleartopline
		ld bc, mfmsginvfull
		call PrintString
		ld a,0
		ret

; Gets an item record by ID
; Expects: a=Item ID
; Returns: bc=0-terminated string with item name
mfgetitemrecordbyid:
		dec a			; Account for 1-based indexing
		ld hl,mfitemtbl
		ld bc,mfitemtblstride
mfginlp:	cp 0
		jp z,mfitemfound
		add hl,bc
		dec a
		jp mfginlp
mfitemfound:	ld b,h
		ld c,l
		ret
		
; Gets an item ID by map char
; Expects: a=Item char
; Returns: a=Item ID, or 0 for no match
mfgetitemidbychar:
		ld d,a
		ld e,1
		ld hl,mfitemtbl
		ld bc,11
		add hl,bc
		ld bc,mfitemtblstride

mfgiilp:	ld a,(hl)
		cp d
		jp z,mfgiifound
		add hl,bc
		inc e
		ld a,e
		cp mfnumitems+1
		jp nz,mfgiilp
		ld a,0
		ret
		
mfgiifound:	ld a,e
		ret		
		
; Gets an item map character by ID
; Expects: a=Item ID
; Returns: a=Item char
mfgetitemcharbyid:	
		dec a			; Account for 1-based indexing
		ld hl,mfitemtbl
		ld bc,mfitemtblstride
mfgiclp:	cp 0
		jp z,mfitemcfound
		add hl,bc
		dec a
		jp mfgiclp
mfitemcfound:	ld b,0
		ld c,11
		add hl,bc		; Step to char entry in this table row
		ld a,(hl)
		ret		
						
; *** Item Activation Behaviours ***
; Called when an item in a map cell is activated by the player
; Can expect the following:
; bc=Base of master record in item table
; de=XY coord we've been activated on
; a=Item ID
; And SHOULD jump back to mfitemactretpoint

; Null behaviour
mfitemnothing:	jp mfitemactretpoint

; Pickupable behaviour
mfitempickup:	call mfaddinventory	; It IS pick-up-able -- let's do that :)
		cp 0			; Check for pickup failure (inventory could be full for example)
		jp z,mfitemactretpoint	; Failed -- don't update map char
		ld a,'.'		; OK, update map char
		call mfsetcellat
		jp mfitemactretpoint
	
; Stairs down behaviour
mfitemstdwn:	ld a,(mfdungeonlev)
		inc a
		ld (mfdungeonlev),a
		ld a,0
		ld (mfdungeondir),a
		jp mfdolevelchng	; Fine to jp to this, won't kill stack :)

; Stairs up behaviour
mfitemstup:	ld a,(mfdungeonlev)
		cp 1			; Trying to go up from first level?
		jp z,mfcheckforkey
		dec a
		ld (mfdungeonlev),a
		ld a,1
		ld (mfdungeondir),a		
		jp mfdolevelchng

mfcheckforkey:	ld a,1
		call mfcheckinventory	; Got the key?
		cp 1
		jp z,mkkeyfound
		call mfcleartopline	; No -- show message of stern protestation
		ld bc,mfmsgnoleave
		call PrintString
		jp mfplayermvret
		
mkkeyfound:	call ClearScreen	; Yes -- show win message!!
		ld bc,mfmsgbanner
		call PrintLine
		ld bc,mfmsgwin
		call PrintString
		ld bc,mfplayername
		call PrintString
		ld a,'!'
		call PrintChar
		ld bc,mfmsgwin2
		call PrintString
		call mfprintrank
		ld bc,mfmsgwin3
		call PrintString
		ld hl,(mfgold)
		call PrintUInt16
		ld bc,mfmsgwin4
		call PrintString
		call GetCharSilent
		call ClearScreen
		jp shell		; Jump out to the shell, it's all over!

; Gold pickup behaviour
mfitemgoldpickup:
		push de			; We'll want those coords in a mo...
		call Rand16
		ld a,(mfdungeonlev)
		ld b,a
		ld a,l
		and 15
		ld c,a
		ld a,0
mflootloop:	add a,c
		dec b
		jp nz,mflootloop
		inc a			; In case it's 0
		ld d,0
		ld e,a
		ld hl,(mfgold)
		add hl,de
		ld (mfgold),hl
		call mfcleartopline
		ld bc,mfmsggoldpup1
		call PrintString
		ld hl,(mfgold)
		ld h,d			; hl <-- gold gained
		ld l,e
		call PrintUInt16
		ld bc,mfmsggoldpup2
		call PrintString		
		ld a,1
		ld (mfprintinfoudp),a
		ld a,'.'		; Remove the gold :)
		pop de			; Restore xy coords
		call mfsetcellat
		jp mfitemactretpoint
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MONSTERS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Expects: de=Starting x,y; b=Monster ID to use or 0 for random choice
; Returns: b=Monster char; a=0 if failed and a=1 if succeeded
mfspawnmonster: ld c,mfmaxmonsters
		ld hl,mfmonsters
mfspawnloop:	ld a,(hl)
		cp 0
		jp z,mfspawndoit
		inc hl
		inc hl
		inc hl
		inc hl
		inc hl
		ld a,0			; Prepare a=0 in case we're about to return with failure
		dec c
		ret z			; Outta slots :/
		jp mfspawnloop		
mfspawndoit:	push hl			; Slot found; push its address and choose a mob

		ld a,b			; Check for a specific ID....
		cp 0
		jp nz,mfspawnchosen
		
		call Rand16		; Choose a random monster from the bestiary
		ld a,l
		and mfbestiarysize
		inc a
				
mfspawnchosen:	pop hl

		ld (hl),a		; Start to fill out the record... type
		inc hl
		ld (hl),d		; Start x
		inc hl
		ld (hl),e		; Start y
		inc hl
		push hl
		ld b,0
		ld c,14			; Select HP
		call mfgetmonsterecordbyid
		ld a,(hl)
		dec hl
		dec hl
		dec hl
		ld b,(hl)		; Grab its character
		pop hl
		ld (hl),a		; Start HP
		inc hl
		ld a,'.'
		ld (hl),a		; Char underneath us
		
		ld a,b			; Set the map cell
		call mfsetcellat
		ld a,1
		ret
		
; Expects: Nothing
; Returns: Nothing
mfupdatemonsters:		
		ld c,mfmaxmonsters
		ld hl,mfmonsters
mfumonsterloop: ld a,(hl)
		cp 0
		call nz,mfumdoit
		
		ld de,5
		add hl,de
		dec c
		ret z			; All done
		jp mfumonsterloop
		
mfumdoit:	ld d,h			; Store live monster array address for this monster for the update handler
		ld e,l
		
		push hl
		push bc
		push de
		ld b,0
		ld c,0
		
		call mfgetmonsterecordbyid	; Grab monster table record for this type...
		
		ld b,h			; Store master record address for the update handler
		ld c,l
		push bc
		ld de,15
		add hl,de		; Step to update handler address
		ld b,(hl)		; Grab update jump address...
		inc hl
		ld c,(hl)
		ld h,c			; Prepare jump address in hl
		ld l,b
		pop bc			; Restore monster table record
		pop de			; Restore monster live array record
		jp (hl)			; Jump to the update handler
mfupdretpoint:	pop bc			; ... which'll jump back here
		pop hl
		ret
				
; *** Monster Behaviours ***
; These are called for each active monster each frame and can expect:
; de=address of current monster in live array
; bc=address of monster record in master table

; An infestation of spreading stuff!!
; OK for main behaviour: YES
; OK for external jumpin from another behaviour: NO
mfmonspreader:	call Rand16
		ld a,l
		and 15			; 1 chance to spread in 32 turns
		cp 0
		jp nz,mfupdretpoint
		call mfmonupdstandardsave
		call Rand16
		ld a,l
		and 3
		cp 0
		jp z,mfmonspreadup
		cp 1
		jp z,mfmonspreaddown
		cp 2
		jp z,mfmonspreadleft
		jp mfmonspreadright
		
mfmonspreadup:	ld a,(scratch_base+1)
		dec a
		cp 0
		jp z,mfupdretpoint
		ld e,a
		ld a,(scratch_base)
		ld d,a
		call mfgetcellat
		cp '.'
		jp z,mfspreadok
		cp '+'
		jp z,mfspreadok		
		jp mfupdretpoint
		
mfmonspreaddown:	
		ld a,(scratch_base+1)	
		inc a
		cp mfmapheight+1
		jp z,mfupdretpoint
		ld e,a
		ld a,(scratch_base)
		ld d,a
		call mfgetcellat
		cp '.'
		jp z,mfspreadok
		cp '+'
		jp z,mfspreadok		
		jp mfupdretpoint

mfmonspreadleft:
		ld a,(scratch_base)
		dec a
		cp 0
		jp z,mfupdretpoint
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		call mfgetcellat
		cp '.'
		jp z,mfspreadok
		cp '+'
		jp z,mfspreadok		
		jp mfupdretpoint		
mfmonspreadright:
		ld a,(scratch_base)
		inc a
		cp mfmapwidth+1
		jp z,mfupdretpoint	
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		call mfgetcellat
		cp '.'
		jp z,mfspreadok
		cp '+'
		jp z,mfspreadok		
		jp mfupdretpoint
		
mfspreadok:	ld a,(mfplayerx)	; Is the player in the way?!
		cp d
		jp nz,mfspreadnotplayer
		ld a,(mfplayery)
		cp e
		jp nz,mfspreadnotplayer
		jp mfupdretpoint
		
mfspreadnotplayer:
		ld a,(scratch_base+5)
		ld b,a
		push de
		call mfspawnmonster
		pop de
		;cp 1
		;jp nz,mfupdretpoint	; Bail if spawn failed
		jp mfupdretpoint

; A monster that wanders unless attacked, in which case it pegs it!
; Checks its HP against the template's to determine if it's been attacked
; OK for main behaviour: YES
; OK for external jumpin from another behaviour: NO
mfmoncoward:	call mfmonupdstandardsave
		ld h,b
		ld l,c	
		push de
		ld de,14
		add hl,de
		pop de
		ld a,(hl)
		ld l,a			; l <-- Start HP
		ld a,(scratch_base+4)	; a <-- current HP
		cp l			; Compare
		jp z,mfmonwanderer_extentry ; Hasn't been attacked :)
		
		call Rand16		; RUN AWAY AND COWER!!! Pick a direction
		ld a,l
		and 1
		cp 0
		jp nz,mfcowardotherway
		
		ld a,(mfplayerx)
		ld h,a		
		ld a,(scratch_base)
		cp h
		jp c,mfmongoleft
		jp mfmongoright
				
mfcowardotherway:
		ld a,(mfplayery)
		ld h,a		
		ld a,(scratch_base+1)
		cp h
		jp c,mfmongoup
		jp mfmongodown		
		

; A monster that wanders unless attacked, in which case it persues relentlessly
; Checks its HP against the template's to determine if it's been attacked
; OK for main behaviour: YES
; OK for external jumpin from another behaviour: NO
mfmonhonourable:
		call mfmonupdstandardsave
		ld h,b
		ld l,c	
		push de
		ld de,14
		add hl,de
		pop de
		ld a,(hl)
		ld l,a			; l <-- Start HP
		ld a,(scratch_base+4)	; a <-- current HP
		cp l			; Compare
		jp z,mfmonwanderer_extentry	; Hasn't been attacked :)
		jp mfmonpsycho_extentry	; I DEMAND A DUEL OLD BOY

; A monster that just wanders randomly
; OK for main behaviour: YES
; OK for external jumpin from another behaviour: YES
mfmonwanderer:	call mfmonupdstandardsave
mfmonwanderer_extentry:
		call Rand16
		ld a,l
		and 3
		cp 0
		jp z,mfmongoup
		cp 1
		jp z,mfmongodown
		cp 2
		jp z,mfmongoleft
		jp mfmongoright
		
; A monster that CAN ONLY ATTACK. This mawfocker LIVES to attack. ATTACK!
; OK for main behaviour: YES
; OK for external jumpin from another behaviour: YES
mfmonpsycho:	call mfmonupdstandardsave
mfmonpsycho_extentry:
		call Rand16
		ld a,l
		and 1
		cp 0
		jp nz,mfpsychootherway
		
mfpsychothisway:
		ld a,(mfplayerx)
		ld h,a		
		ld a,(scratch_base)
		cp h
		jp z,mfpsychootherway	; We're locked in on x -- force y to lock in
		jp c,mfmongoright
		jp mfmongoleft
				
mfpsychootherway:
		ld a,(mfplayery)
		ld h,a		
		ld a,(scratch_base+1)
		cp h
		jp z,mfpsychothisway	; We're locked in on y -- force x to lock in
		jp c,mfmongodown
		jp mfmongoup
			
; Behaviours helper: Save useful stuff in scratch without wrecking de and bc: current xy, monster character, and such
mfmonupdstandardsave:
		push de			; push live array address
		ld a,(de)		; grab current type
		ld (scratch_base+5),a	; store it		
		inc de
		ld a,(de)		; grab current x
		ld (scratch_base),a	; and store it
		inc de
		ld a,(de)		; grab current y
		ld (scratch_base+1),a	; and store it
		inc de
		ld a,(de)		; grab current hp
		ld (scratch_base+4),a	; and store it
		inc de
		ld a,(de)		; grab current standing-on map char
		ld (scratch_base+3),a	; and store it
		ld de,11		
		ld h,b
		ld l,c
		add hl,de
		ld a,(hl)		; Grab monster's map char
		ld (scratch_base+2),a	; Store it
		inc hl
		ld a,(hl)
		ld (scratch_base+6),a	; Store monster's Att
		;inc hl
		;ld (scratch_base+7),a	; Store monster's Def
		
		pop de			; Restore live array address
				
		ret

; Behaviours helper: Perform chosen movement or attack player
; OK for main behaviour: NO
; OK for external jumpin from another behaviour: YES
mfmongoup:	push de
		ld a,(scratch_base+1)
		dec a
		cp 0
		jp z,mfmonmovementnone
		ld e,a
		ld a,(scratch_base)
		ld d,a
		call mfgetcellat
		cp 178
		jp z,mfmonmovementnone
		cp 219
		jp z,mfmonmovementnone
		jp mfmonmovementdone
		
mfmongodown:	push de
		ld a,(scratch_base+1)	
		inc a
		cp mfmapheight+1
		jp z,mfmonmovementnone
		ld e,a
		ld a,(scratch_base)
		ld d,a
		call mfgetcellat
		cp 178
		jp z,mfmonmovementnone
		cp 219
		jp z,mfmonmovementnone
		jp mfmonmovementdone

mfmongoleft:	push de
		ld a,(scratch_base)
		dec a
		cp 0
		jp z,mfmonmovementnone
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		call mfgetcellat
		cp 178
		jp z,mfmonmovementnone
		cp 219
		jp z,mfmonmovementnone
		jp mfmonmovementdone
		
mfmongoright:	push de
		ld a,(scratch_base)
		inc a
		cp mfmapwidth+1
		jp z,mfmonmovementnone	
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		call mfgetcellat
		cp 178
		jp z,mfmonmovementnone
		cp 219
		jp z,mfmonmovementnone
		
mfmonmovementdone:
		push af			; Backup the char in the square for a mo, as mfmonnotplayer will want it
		ld a,(mfplayerx)
		cp d
		jp nz,mfmonnotplayer
		ld a,(mfplayery)
		cp e
		jp nz,mfmonnotplayer
		pop af
		
		; It's the player -- attack!!		
		call mfcleartopline
		
		call Rand16
		ld a,l
		and 3
		cp 0
		jp z,mfmonstrmsg1
		cp 1
		jp z,mfmonstrmsg2
		cp 2
		jp z,mfmonstrmsg3
		ld bc,mfmsgmnstrike4
		jp mfshowmnstrikemsg	
mfmonstrmsg1:	ld bc,mfmsgmnstrike1
		jp mfshowmnstrikemsg
mfmonstrmsg2:	ld bc,mfmsgmnstrike2
		jp mfshowmnstrikemsg		
mfmonstrmsg3:	ld bc,mfmsgmnstrike3

mfshowmnstrikemsg:
		call PrintString
				
		; Run NPC on PC combat calcs
		ld a,(mfplayerdef)
		ld d,a			; Store players's DEF in d
		ld a,(scratch_base+6)	; Load monster's ATT
		add a,d			; a = att + def
		ld l,a			; l <-- att+def
		ld a,(scratch_base+6)
		rla
		rla
		rla
		rla
		ld h,a			; h <-- att * 16
		call Div8		; h = (att * 16) / (att+def) -> ie h = required roll, 0-15		

		push hl			; Backup chance-to-hit ((att*16) / (att+def))
		call Rand16		; Roll a d16 ;)
		ld a,l
		and 15
		pop hl			; Restore chance-to-hit
		cp 0			; Compare roll to 0
		jp z,mfmonstercrithit	; Crit hit!							
		cp h			; Compare roll to chance-to-hit requirement
		jp c,mfmonsterhit	; Chance-to-hit greater than what we rolled? Then we hit!
		jp z,mfmonstershithit	; Glancing blow							
		
		ld a,0			; Missed! Set damage to 0
		ld (scratch_base+8),a
		jp mfmonstercalcdn
													
mfmonstercrithit:											
		ld a,(scratch_base+6)	; Crit Hit! Set damage to monster's ATT * 2			
		add a,a											
		ld (scratch_base+8),a									
		jp mfmonstercalcdn									
													
mfmonstershithit:											
		ld a,(scratch_base+6)	; Shit Hit! Set damage to monster's ATT / 2			
		ld h,a											
		ld l,2											
		call Div8										
		ld a,h											
		ld (scratch_base+8),a									
		jp mfmonstercalcdn									
													
mfmonsterhit:	ld a,(scratch_base+6)	; Hit! Set damage to monster's ATT				
		ld (scratch_base+8),a									
													
mfmonstercalcdn:											
		ld a,(scratch_base+8)									
		ld d,a											
		ld a,(mfhp)										
		sub d											
		jp z,mfplayerdead	; Have we just killed the player?!
		jp c,mfplayerdead
		ld (mfhp),a
		
		ld a,d
		cp 0
		jp z,mfmpickmissmsg
													
		ld a,(scratch_base+6)	; Compare with monster's ATT					
		cp d											
		jp z,mfmreghit										
		jp c,mfmcrithit										
													
		ld bc,mfmmsgshithit									
		jp mfmshowhitmissmsg									
													
mfmcrithit:	ld bc,mfmmsgcrithit									
		jp mfmshowhitmissmsg									
													
mfmreghit:												
		call Rand16		; Pick a random hit msg						
		ld a,l											
		and 3											
		cp 0											
		jp z,mfmhitmsg1										
		cp 1											
		jp z,mfmhitmsg2										
		cp 2
		jp z,mfmhitmsg3
		ld bc,mfmmsghit4
		jp mfmshowhitmissmsg	
mfmhitmsg1:	ld bc,mfmmsghit1
		jp mfmshowhitmissmsg
mfmhitmsg2:	ld bc,mfmmsghit2
		jp mfmshowhitmissmsg		
mfmhitmsg3:	ld bc,mfmmsghit3
		jp mfmshowhitmissmsg

mfmpickmissmsg: call Rand16		; Pick a random miss msg
		ld a,l
		and 3
		cp 0
		jp z,mfmmissmsg1
		cp 1
		jp z,mfmmissmsg2
		cp 2
		jp z,mfmmissmsg3
		ld bc,mfmmsgmiss4
		jp mfmshowhitmissmsg	
mfmmissmsg1:	ld bc,mfmmsgmiss1
		jp mfmshowhitmissmsg
mfmmissmsg2:	ld bc,mfmmsgmiss2
		jp mfmshowhitmissmsg		
mfmmissmsg3:	ld bc,mfmmsgmiss3
		jp mfmshowhitmissmsg		

mfmshowhitmissmsg:   
		call PrintString
		
		ld a,(scratch_base+8)
		cp 0
		jp z,mfmskipdmgmsg
		ld h,0
		ld l,a
		call PrintUInt16	
		ld bc, mfmmsgdamage
		call PrintString
mfmskipdmgmsg:	pop de			; Restore live array address

		; Show our opponent info
		ld a,(scratch_base+5)
		ld c,0
		call mfgetmonsterecordbyid
		push hl
		ld d,29
		ld e,16
		call CursorXY		
		ld bc,mfmsgtarget
		call PrintString
		ld d,29
		ld e,17
		call CursorXY
		pop hl
		ld b,h
		ld c,l
		call PrintString
		ld d,29			
		ld e,18
		call CursorXY
		ld bc,mfmsghp
		call PrintString
		ld a,(scratch_base+4)
		ld h,0
		ld l,a
		call PrintUInt16
		ld bc,mfmsgpad3
		call PrintString
		
		ld a,33			; Update player's HP display in side panel
		ld d,a
		ld a,8
		ld e,a
		call CursorXY
		ld a,(mfhp)
		ld h,0
		ld l,a
		call PrintUInt16
		ld bc,mfmsgpad2
		call PrintString
		
		jp mfupdretpoint	; Attack done, back to the ret point
			
mfmonnotplayer:	pop af
		call mfgetmonsteridbychar	; Trying to walk into another monster?
		cp 0
		jp nz,mfmonmovementnone	; Disallow that!
		
		ld h,d			; OK, actual legal movement!! h <-- new x
		ld l,e			; l <-- new y
		pop de
		
		; Update live array with new position
		push de			; push live array address
		inc de
		ld a,h
		ld (de),a
		inc de
		ld a,l
		ld (de),a
		pop de			; Restore live array address
		
		; Remove old pos from map and undraw
		push de			; push live array address
		ld a,(scratch_base)	; grab OLD xy
		ld d,a
		ld a,(scratch_base+1)
		ld e,a
		ld a,(scratch_base+3)
		call mfsetcellat	; Set current cell back to whatever we're standing on
		pop de			; Restore live array address
			
		; Set new pos in map and redraw
		ld h,d			; copy live array address into hl
		ld l,e
		push de			; push live array address
		inc hl			; Put NEW x and y coords into de
		ld d,(hl)
		inc hl
		ld e,(hl)
		
		push hl
		call mfgetcellat	; Get the char currently at the place we're stepping to...
		pop hl
		
		inc hl
		inc hl			; Step to right entry in live array cell
		ld (hl),a		; Update our standing-on character
		
		ld a,(scratch_base+2)	; Load the monster char
		call mfsetcellat	; Set current cell as monster
		pop de			; Restore live array address
			
		jp mfupdretpoint
		
mfmonmovementnone:	
		pop de			; Restore live array address
		jp mfupdretpoint
		
mfplayerdead:	pop de
		ld bc,mfmsgcollapse
		call PrintString

		ld a,33			; Show HP as 0 in side panel
		ld d,a
		ld a,8
		ld e,a
		call CursorXY
		ld a,'0'
		call PrintChar
		ld bc,mfmsgpad2
		call PrintString
		
		ld a,(scratch_base+5)	; Show our opponent info
		ld c,0
		call mfgetmonsterecordbyid
		push hl
		ld d,29
		ld e,16
		call CursorXY		
		ld bc,mfmsgtarget
		call PrintString
		ld d,29
		ld e,17
		call CursorXY
		pop hl
		ld b,h
		ld c,l
		call PrintString
		ld d,29			
		ld e,18
		call CursorXY
		ld bc,mfmsghp
		call PrintString
		ld a,(scratch_base+4)
		ld h,0
		ld l,a
		call PrintUInt16
		ld bc,mfmsgpad3
		call PrintString
				
mfdeadspacelp:	call GetCharSilent
		cp ' '
		jp nz,mfdeadspacelp
		call ClearScreen
		ld bc,mfmsgbanner
		call PrintLine
		ld bc,mfmsgdeath
		call PrintString
		ld bc,mfplayername
		call PrintString
		ld bc,mfmsgdeath2
		call PrintString
		call mfprintrank
		ld bc,mfmsgdeath3
		call PrintString
		call mfprintdepth
		ld bc,mfmsgdeath4
		call PrintString
		ld hl,(mfgold)
		call PrintUInt16		
		ld bc,mfmsgdeath5
		call PrintString
		ld a,(scratch_base+2)
		call mfgetmonsteridbychar
		ld c,0
		call mfgetmonsterecordbyid
		ld b,h
		ld c,l
		call PrintString
		call NewLine
		call GetCharSilent
		call ClearScreen
		ld bc,mfmsgbanner
		call PrintLine
		call NewLine
		ld bc,mfmsgdeath6
		call PrintString
		ld d,25
		ld e,23
		call CursorXY
		ld bc,mfplayername
		call StrLen
		ld h,a
		ld l,2
		call Div8
		ld a,5
		sub h
		dec a
		ld h,a
		ld a,' '
mfdeathsplp:	call PrintChar		
		dec h 
		jp nz,mfdeathsplp		
		call PrintString		
		call GetCharSilent
		call ClearScreen
		jp shell

; Gets a live monster entry by xy coords
; Expects: de=x,y on map
; Returns: hl=Base address of record in live monster array
mfgetlivemonsterbycoords:
		ld hl,mfmonsters
		inc hl
mfglmbclp:	ld a,(hl)
		cp d
		jp z,mfglmbcdblchk
		inc hl
		inc hl
		inc hl
		inc hl
		inc hl
		jp mfglmbclp
mfglmbcdblchk:	inc hl
		ld a,(hl)
		cp e
		jp z,mfglmbcyup
		inc hl
		inc hl
		inc hl
		inc hl
		jp mfglmbclp
mfglmbcyup:	dec hl
		dec hl
		ret
		
; Gets a monster entry by ID; also uses an offset to choose the field you want.
; Expects: a=Monster ID; c=offset
; Returns: hl=Base address of record in master table
mfgetmonsterecordbyid:	
		push bc
		dec a			; Account for 1-based indexing
		ld hl,mfmonstertbl
		ld bc,mfmonstertblstride
mfgmclp:	cp 0
		jp z,mfmonstrcfound
		add hl,bc
		dec a
		jp mfgmclp
mfmonstrcfound:	pop bc
		ld b,0
		add hl,bc		; Step to wabted entry in this table row
		ret
		
; Gets an item ID by map char
; Expects: a=Monster char
; Returns: a=Monster ID, or 0 for no match
mfgetmonsteridbychar:
		push de
		push bc
		ld d,a
		ld e,1
		ld hl,mfmonstertbl
		ld bc,11
		add hl,bc
		ld bc,mfmonstertblstride
		
mfgmilp:	ld a,(hl)
		cp d
		jp z,mfgmifound
		add hl,bc
		inc e
		ld a,e
		cp mfnummonsters+1
		jp nz,mfgmilp
		ld a,0
		pop bc
		pop de
		ret
		
mfgmifound:	ld a,e
		pop bc
		pop de
		ret			

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; STRINGS AND TABLES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Strings: Banner screens
mfmsgbanner:	defm "   __  _  _ __  _  __ ___ __  __  _"
		defb 13,10
		defm "  |*_\| || |  \| |/ _] __/__\|  \| |"
		defb 13,10
		defm "  | v | \/ | | ' | [/\ _| \/ | | ' |"
		defb 13,10
		defm "  |__/ \__/|_|\__|\__/___\__/|_|\__|"
		defb 13,10
		defm "    ___ _  _ __  _  __ _   ___ ___"
		defb 13,10
		defm "   |*__| || |  \| |/ _] | | __| _ \"
		defb 13,10
		defm "   | _|| \/ | | ' | [/\ |_| _|| v /"
		defb 13,10
		defm "   |_|  \__/|_|\__|\__/___|___|_|_\"
		defb 13,10
		defb 0

mfmsgintro:	defm "  Foolishly, you've ventured through"
		defb 13,10
		defm " the trapdoor in Robber's Cave... and"
		defb 13,10
		defm " it's already slammed shut and locked"
		defb 13,10
		defm " behind you. Your only choice now is"
		defb 13,10
		defm " onwards, deep into the terrible Maen"
		defb 13,10
		defm "  Arthur dungeons, to find the key -"
		defb 13,10
		defm "      and with it, your freedom!"
		defb 13,10
		defb 13,10
		defm "  ~ Prithee press a key to continue ~"
		defb 0
		
mfmsgintro2:	defm "           ~ Ye Controls ~"
		defb 13,10
		defm "     Climb, pick up, etc : Space"
		defb 13,10
		defm "       Move/melee attack : wsad"
		defb 13,10
		defm "          View inventory : i"
		defb 13,10
		defm "                    Rest : r"
		defb 13,10		
		defb 13,10
		defm " Whenever you see "
		defb 175
		defm ", hit any key "
		defb 13,10		
		defm " to continue."
		defb 13,10		
		defb 13,10
		defm "Enter your name to start:"
		defb 0

mfmsgdeath:	defm " GAH! You totally died :("
		defb 13,10
		defb 13,10
		defm " RIP "
		defb 0
		
mfmsgdeath2:	defm ", brave adventurer,"
		defb 13,10
		defm " who held the rank of "
		defb 0

mfmsgdeath3:	defb 13,10
		defb 13,10
		defm " Killed at a depth of "
		defb 0
		
mfmsgdeath4:	defm " feet"
		defb 13,10
		defm " while carrying "
		defb 0
		
mfmsgdeath5:	defm " gold, "
		defb 13,10
		defm " by a "
		defb 0			

mfmsgdeath6:	defm "     _.---,._,' "
		defb 13,10
		defm "    /' _.--.< "
		defb 13,10
		defm "      /'     `' "
		defb 13,10
		defm "    /' _.---._____ "
		defb 13,10
		defm "    \.'   ___, .-'` "
		defb 13,10
		defm "        /'    \\"
		defb 13,10
		defm "      /'       `-."
		defb 13,10
		defm "     |"
		defb 13,10
		defm "     |                  .-'~~~`-."
		defb 13,10
		defm "     |                .'         `."
		defb 13,10
		defm "     |                |   R I P   |"
		defb 13,10
		defm "     |                |           |"
		defb 13,10
		defm " jgs |                |           |"
		defb 13,10
		defm "      \             \\|           |//"
		defb 13,10
		defm "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		defb 0		
		
mfmsgwin:	defm " ** YOU ARE FREE FROM THE DUNGEONS **"
		defb 13,10
		defb 13,10
		defm " As you emerge, blinking in the light,"
		defb 13,10
		defm " the citizens of Maen Arthur gather"
		defb 13,10
		defm " round you in wonder -- for you are"
		defb 13,10
		defm " the first adventurer to ever survive"
		defb 13,10
		defm " the dreaded dungeons."
		defb 13,10
		defb 13,10
		defm " Congratulations, "		
		defb 0
		
mfmsgwin2:	defb 13,10
		defb 13,10
		defm " You attained the rank of "
		defb 0
		
mfmsgwin3:	defb 13,10
		defm " and escaped with "
		defb 0
		
mfmsgwin4:	defm " gold."
		defb 0
		
; Strings: Topline stuff
mfmsginvclose:	defm "You stop rummaging in your bag."
		defb 0
		
mfmsgmnstrike1:	defm "The foe attacks"
		defb 0

mfmsgmnstrike2:	defm "The foe assaults"
		defb 0
		
mfmsgmnstrike3:	defm "The foe assails"
		defb 0
		
mfmsgmnstrike4:	defm "The foe strikes"
		defb 0

mfmsgcollapse:	defm "... YOU COLLAPSE! [SP]"
		defb 0

mfmmsgmiss1:	defm " but you dodge!"
		defb 0	

mfmmsgmiss2:	defm " but you block!"
		defb 0	

mfmmsgmiss3:	defm " but misses!"
		defb 0	

mfmmsgmiss4:	defm " but you parry!"
		defb 0	

mfmmsgcrithit:	defm "; CRITICAL HIT! -"
		defb 0	
		
mfmmsgshithit:	defm "; glancing blow -"
		defb 0			
		
mfmmsghit1:	defm " and hits! -"
		defb 0	

mfmmsghit2:	defm " well; -"
		defb 0	
		
mfmmsghit3:	defm " for -"
		defb 0	
		
mfmmsghit4:	defm ", causing -"
		defb 0			

mfmmsgdamage:	defm " HP"
		defb 0		

mfmsggoldpup1:	defm "You acquire "
		defb 0

mfmsggoldpup2:	defm " gold!"
		defb 0		

mfmsgpickup1:	defm "You pick up a "
		defb 0

mfmsgpickup2:	defm "You grab a "
		defb 0		
		
mfmsgpickup3:	defm "You sieze a "
		defb 0		

mfmsgpickup4:	defm "You grasp a "
		defb 0		
		
mfmsgstrike1:	defm "You strike"
		defb 0	

mfmsgstrike2:	defm "You thrust"
		defb 0			

mfmsgstrike3:	defm "You attack"
		defb 0	
		
mfmsgstrike4:	defm "You swing"
		defb 0	
		
mfmsgmiss1:	defm " but are parried!"
		defb 0	

mfmsgmiss2:	defm " but your foe blocks!"
		defb 0	

mfmsgmiss3:	defm " but miss!"
		defb 0	

mfmsgmiss4:	defm " but the enemy dodges!"
		defb 0	
		
mfmsghit1:	defm " and hit: "
		defb 0	

mfmsghit2:	defm " and hit for "
		defb 0	
		
mfmsghit3:	defm " and cause "
		defb 0	
		
mfmsghit4:	defm ", inflicting "
		defb 0			

mfmsgcrithit:	defm "; a HUGE hit! "
		defb 0			
				
mfmsgshithit:	defm "; a POOR hit! "
		defb 0			
		
mfmsgdamage:	defm " HP damage"
		defb 0		
		
mfmsgvanq1:	defm "; your foe is vanquished!"
		defb 0	
		
mfmsgvanq2:	defm ", destroying your enemy"
		defb 0	
		
mfmsgvanq3:	defm " and kill your adversary"
		defb 0	
		
mfmsgvanq4:	defm ", dispatching the creature"
		defb 0			
		
mfmsginvfull:	defm "You're too encumbered to pick that up!"
		defb 0

mfmsgdec1:	defm "You descend the stairs..."
		defb 0
		
mfmsgasc1:	defm "You ascend the stairs..."
		defb 0		

mfmsgdec2:	defm "You clamber down the stairs..."
		defb 0
		
mfmsgasc2:	defm "You clamber up the stairs..."
		defb 0		

mfmsgdec3:	defm "You stumble down the stairs..."
		defb 0
		
mfmsgasc3:	defm "You drag yourself up the stairs..."
		defb 0		

mfmsgnoleave:	defm "You can't leave without the key!"
		defb 0
		
; Strings: Sidepanel stuff		
mfmsgdepth:	defm " feet  "
		defb 0

mfmsggold:	defm "Au: "
		defb 0

mfmsghp:	defm "HP: "
		defb 0		

msgofhp:	defm " of "
		defb 0
		
mfmsgatt:	defm "Att:"
		defb 0

mfmsgdef:	defm "Def:"
		defb 0

mfmsgtarget:	defm "Opponent:"
		defb 0

mfmsgthereis1:	defm "There is a"
		defb 0
		
mfmsgthereis2:	defm "You see a "
		defb 0		

mfmsghere:	defm "here."
		defb 0

mfmsgmnstrdead:	defm "* DEAD *  "
		defb 0

; Strings: Misc
mfmsginv: 	defm "INVENTORY"
		defb 0
		
mfmsginvprompt: defm "Commands: (e)quip, (d)rop, e(x)it"
		defb 0
	
msgnoitems:	defm "You are bereft of carryments! "
		defb 175
		defb 0
		
mfmsgdropsel:	defm "Choose an item to drop..."
		defb 0

mfmsgbaditem:	defm "No such item, adventurin' dude! "
		defb 175
		defb 0

mfmsgnodrprm:	defm "There's no room to put that down here! "
		defb 175
		defb 0

mfmsgblinetest: defm "SP="	; DEBUG
		defb 0
		
mfmsgblinetest2:
		defm ";Player="	; DEBUG
		defb 0
		
mfmsgpad2:	defm "  "
		defb 0

mfmsgpad3:	defm "   "
		defb 0
	
mfmsgpad10:	defm "          "
		defb 0
	
mfmsgpad38:	defm "                                      "
		defb 0
		
; Tables
; Rank table
; <name:11>
mfranktblstride	equ 11
mfranktbl:	defm "Nubbins   "	; 0
		defb 0
		defm "Blagger   "	; 1
		defb 0
		defm "Novice    "	; 2
		defb 0
		defm "Apprentice"	; 3
		defb 0
		defm "Journeyman"	; 4
		defb 0
		defm "Adventurer"	; 5
		defb 0
		defm "Total Pro "	; 6
		defb 0
		defm "Master    "	; 7
		defb 0
		defm "Legendary "	; 8
		defb 0
		defm "Godlike   "	; 9
		defb 0

; Item table
; <name:11><map char:1><{if weapon: att/def bonuses}{if not weapon: RESERVED}:1><RESERVED:1><flags:1><activate function:2>
; Att/Def bonuses byte:
;	Bits 0-3: Def bonus
; 	Bits 4-7: Att bonus
;
; Flags: 
;	Bit 7: Is slottable as head armour
;	Bit 6: Is slottable as body armour
;	Bit 5: Is slottable as feet armour
;	Bit 4: Is slottable as hand weapon
;	Bit 3: If weapon, requires two hands
;	Bit 2: RESERVED
;	Bit 1: RESERVED
;	Bit 0: RESERVED

mfitemtblstride	equ 17
mfnumitems	equ 8
mfitemtbl:	defm "GOLDEN KEY"	; Name
		defb 0
		defb 'F'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags!
		defw mfitempickup	; OnActivate
		
		defm "longsword "	; Name
		defb 0
		defb 'l'		; Map char
		defb 2			; Att/def bonuses if weapon
		defb 1			; RESERVED
		defb 00010000b		; Flags!		
		defw mfitempickup	; OnActivate
		
		defm "Coin Purse"	; Name
		defb 0
		defb '$'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00010000b		; Flags!		
		defw mfitemgoldpickup	; OnActivate		

		defm "HP Potion "	; Name
		defb 0
		defb 173		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags				
		defw mfitempickup	; OnActivate	
		
		defm "puddle    "	; Name
		defb 0
		defb '~'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags	
		defw mfitemnothing	; OnActivate

		defm "staircase "	; Name
		defb 0
		defb '<'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags		
		defw mfitemstup		; OnActivate
		
		defm "staircase "	; Name
		defb 0
		defb '>'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags				
		defw mfitemstdwn	; OnActivate	
		
		defm "door      "	; Name
		defb 0
		defb '+'		; Map char
		defb 0			; Att/def bonuses if weapon
		defb 0			; RESERVED
		defb 00000000b		; Flags				
		defw mfitemnothing	; OnActivate	
		
; Monster table
; <name:11><map char:1><att:1><def:1><start hp:1><update function:2>
; TODO: XP for monsters innit;
;	+ Implement level-gaining
;	Also, monster loot drops can be based on monster XP!

mfmonstertblstride equ 17
mfbestiarysize	equ 7	; NB: USED AS AND FLAG WITH RESULT THEN INC'D BY 1
mfnummonsters 	equ 8
mfmonstertbl:	; MONSTER 1
		defm "Slime mold"	; Name
		defb 0
		defb '*'		; Map char
		defb 1			; Att
		defb 1			; Def
		defb 1			; Start HP
		defw mfmonspreader	; OnUpdate
		; MONSTER 2
		defm "Baselisk  "	; Name
		defb 0
		defb 's'		; Map char
		defb 2			; Att
		defb 2			; Def
		defb 5			; Start HP
		defw mfmonhonourable	; OnUpdate
		; MONSTER 3
		defm "Feral Mani"	; Name
		defb 0
		defb 'm'		; Map char
		defb 3			; Att
		defb 3			; Def
		defb 6			; Start HP
		defw mfmonhonourable	; OnUpdate
		; MONSTER 4
		defm "Balrog    "
		defb 0
		defb 'B'		; Map char
		defb 9			; Att
		defb 9			; Def
		defb 10			; Start HP
		defw mfmonpsycho	; OnUpdate
		; MONSTER 5
		defm "Fungleater"	; Name
		defb 0
		defb '#'		; Map char
		defb 5			; Att
		defb 1			; Def
		defb 3			; Start HP
		defw mfmoncoward	; OnUpdate		
		; MONSTER 6
		defm "Barrel-man"	; Name
		defb 0
		defb 'U'		; Map char
		defb 4			; Att
		defb 4			; Def
		defb 4			; Start HP
		defw mfmonhonourable	; OnUpdate		
		; MONSTER 7
		defm "Drunk bat "
		defb 0
		defb '"'		; Map char
		defb 2			; Att
		defb 4			; Def
		defb 4			; Start HP
		defw mfmonwanderer	; OnUpdate		
		; MONSTER 8
		defm "Farty hog "
		defb 0
		defb '&'		; Map char
		defb 8			; Att
		defb 8			; Def
		defb 7			; Start HP
		defw mfmonhonourable	; OnUpdate		
		; MONSTER 9
		defm "Winged hob"	; Name
		defb 0
		defb 'w'		; Map char
		defb 3			; Att
		defb 7			; Def
		defb 7			; Start HP
		defw mfmonhonourable	; OnUpdate			
	
; *** Subroutine: Play the game of life! ***
game_of_life:

golwidth	equ console_width	; Game constants
golheight	equ console_height
golboardaddress	equ prog_base+golwidth
golboardsize	equ golwidth*golheight

;golcellnew	equ 'o'			; Game of Life characters
;golcell2	equ 'O'
;golcell	equ '@'
golcellnew	equ 176
golcell2	equ 177
golcell		equ 178

golempty	equ ' '

		ld bc,golmsgintro	; Show welcome
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetChar		; Get and set seed
		call SeedRand8
		call ClearScreen
	
		ld bc,golboardaddress	; Setup initial board
		ld h,golheight
golsetupoloop:	ld l,golwidth
golsetupiloop:	call Rand8
		cp 80
		jp nc,golsetempcell
		ld a,golcell
		ld (bc),a
		jp golsetupcont
golsetempcell:	ld a,golempty
		ld (bc),a
golsetupcont:	inc bc
		dec l
		jp nz,golsetupiloop
		dec h
		jp nz,golsetupoloop
		
		ld bc,prog_base		; Setup blank top border (as update reads above board when neighbour checking)
		ld l,golwidth
golborderloop:	ld a,golempty
		ld (bc),a
		inc bc
		dec l
		jp nz,golborderloop
		
goldrawloop: 	call CursorHome		; Update & draw board
		ld bc,golboardaddress
		ld h,golheight
golupdoloop:	ld l,golwidth
golupdiloop:	push hl
		push bc
		ld h,b				
		ld l,c
		ld b,0			; Counter for num of neighbours found	
		
		ld de,golwidth+1	; Set hl to first neighbour pos (above-left of us)
		sbc hl,de
		ld a,(hl)
		cp golempty
		jp z,golnextneigh1
		inc b
		
golnextneigh1: 	inc hl			; 2nd pos: above us
		ld a,(hl)
		cp golempty
		jp z,golnextneigh2
		inc b
		
golnextneigh2: 	inc hl			; 3rd pos: above-right of us
		ld a,(hl)
		cp golempty
		jp z,golnextneigh3
		inc b		

golnextneigh3:	ld de,golwidth-2	; 4 pos: left of us
		add hl,de
		ld a,(hl)
		cp golempty
		jp z,golnextneigh4
		inc b		

golnextneigh4:  inc hl			; 5 pos: right of us
		inc hl
		ld a,(hl)
		cp golempty
		jp z,golnextneigh5
		inc b		

golnextneigh5:	ld de,golwidth-2	; 6 pos: below-left of us
		add hl,de
		ld a,(hl)
		cp golempty
		jp z,golnextneigh6
		inc b		

golnextneigh6:	inc hl			; 7 pos: below us
		ld a,(hl)
		cp golempty
		jp z,golnextneigh7
		inc b		

golnextneigh7:	inc hl			; 8 pos: below-right of us
		ld a,(hl)
		cp golempty
		jp z,golneighdone
		inc b
		
golneighdone: 	ld d,b
		pop bc
		pop hl
		ld a,(bc)		; d now contains (bc)'s number of neighbours
		cp golempty
		jp nz,golfullcell
		
		ld a,d			; Cell empty -- only create cell if 3 neighbours
		cp 3
		jp nz,golwbbempty
		jp golwbbfullnew
		
golfullcell:	ld a,d			; Cell full -- cell only survives if 2 or 3 neighbours
		cp 2
		jp z,golwbbfull2
		cp 3
		jp z,golwbbfull
		jp golwbbempty
		
golwbbfullnew:	ld a,golcellnew
		call golwritetobb
		jp golupdated		

golwbbfull:	ld a,golcell
		call golwritetobb
		jp golupdated
		
golwbbfull2:	ld a,golcell2
		call golwritetobb
		jp golupdated
		
golwbbempty:	ld a,golempty
		call golwritetobb
		
golupdated:	ld a,(bc)		; Draw from front buffer
		call PrintChar
		inc bc
		dec l
		jp nz,golupdiloop		
		call NewLine
		dec h
		jp nz,golupdoloop
		
		ld hl,golboardaddress+golboardsize	; Blit backbuffer into front
		ld de,golboardaddress
		ld bc,golboardsize
		ldir
		
		call ScanChar
		cp 0
		jp z,goldrawloop
		call ClearScreen
		ret

golwritetobb:	push hl			; Expects: bc - equiv frontbuffer address; a - byte to write
		push de
		ld h,b
		ld l,c
		ld de,golboardsize
		add hl,de
		ld (hl),a
		pop de
		pop hl
		ret
		
golmsgintro:	defm "Let's rock some cellular automata!"
		defb 13, 10
		defm "(Once started press any key to quit)"
		defb 13, 10
		defm "Hit a key to seed start pattern..."
		defb 0
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; API FUNCTIONS ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; *** API: ClearScreen ***
; Expects: nothing
ClearScreen:	ld a,12
		call PrintChar
		ret
		
; *** API: CursorHome ***
; Expects: nothing
CursorHome:	ld a,$1B		; <esc>
		call PrintChar
		ld a,'['
		call PrintChar
		ld a,'H'
		call PrintChar
		ret
		
; *** API: CursorXY ***
; Origin is 1,1 in top-left corner!
; Expects: d = x; e = y
; Trashes: h, l, a
CursorXY:	ld a,$1B		; <esc>
		call PrintChar
		ld a,'['
		call PrintChar
		
		ld h,0			; Row (y)
		ld l,e
		call PrintUInt16	
		
		ld a,';'
		call PrintChar
		
		ld h,0
		ld l,d			; Col (x)
		call PrintUInt16
		
		ld a,'H'
		call PrintChar
		ret
		
; *** API: NewLine ***
; Expects: nothing
NewLine:	ex af,af'
		push bc
		ld bc,ascii_newline
		call PrintString
		pop bc
		ex af,af'
		ret

ascii_newline:	defb 10, 13, 0

; *** API: MemLoad ***
; Expects: de - start address
; Returns: A bunch of populated memory :P
MemLoad:	ld h,d
		ld l,e
		call PrintHex16
		ld a,ascii_spc
		call PrintChar

		ld a, shellprompt
		call PrintChar
		
		call GetString
		call NewLine
		ld a,(string_buffer)
		cp '.'
		jp z,MemLoad_end
		ld hl,string_buffer
		call AHexToUInt8
		ld a,c
		ld (de),a
		inc de
		jp MemLoad
				
MemLoad_end:	ret
		
; *** API: MemDump ***
; Expects: hl - number of bytes; bc - start address
MemDump:	push bc
		push hl
		ld d, 1			; Trigger newline
MemDump_loop:	dec d
		jp z, MemDump_nline
MemDump_next:	ld a,(bc)
		call PrintHex8
		ld a,ascii_spc
		call PrintChar		
		inc bc
		dec hl
		ld a,1
		cp d
		jp z,MemDump_ascii
MemDump_cont:	call ScanChar		; Check for keypress
		cp 0
		jp nz,MemDump_quit
		ld a,h			; Check if HL==0
		or l
		jp nz,MemDump_loop
MemDump_quit:	pop hl
		pop bc
		call NewLine
		ret
		
MemDump_nline:	call NewLine
		push hl
		ld h,b
		ld l,c
		call PrintHex16
		ld a,':'
		call PrintChar
		ld a,ascii_spc
		call PrintChar
		pop hl
		ld d,8
		jp MemDump_next
		
MemDump_ascii:	push hl
		push de
		ld de,8
		ld h,b
		ld l,c
		sbc hl,de
		ld b,h
		ld c,l
		pop de
		pop hl
		
		ld e,8
MemDump_ascii_loop:
		ld a,(bc)
		cp 32
		jp c,MemDump_skip
		cp 126
		jp nc,MemDump_skip
		call PrintChar
		jp MemDump_cdone
MemDump_skip:	ld a,'.'
		call PrintChar
MemDump_cdone:	inc bc
		dec e
		jp nz, MemDump_ascii_loop
		jp MemDump_cont	
		
; *** API: GetString ***
; Expects: Nothing
; Returns: Received string in the string buffer at string_buffer
GetString:	push bc
		push hl
		ld l,255
		ld bc, string_buffer
GetString_loop:	in a,(uart_sr_csr)	; Wait for SR RxRdy
		bit uart_rxrdybit,a
		jr z,GetString_loop
		in a,(uart_data)	; Get char
		cp 10			; Check for 10 (maybe a serial client sent 13,10 as a newline)
		jp z,GetString_loop	; Meh, we ignore them
		cp 13			; Check for Enter pressed?
		jp z,GetString_done	; Done if so
		cp 127			; Check for Backspace/Delete pressed...
		jp z,GetString_backspace
		ld (bc),a		; Otherwise, store char
		call PrintChar		; Echo it too
		inc bc			; Inc address
		dec l			; Check buffer space left
		jp z,GetString_done	; Buffer out? Accept
		jp GetString_loop
GetString_done:	ld a,0
		ld (bc),a
		pop hl
		pop bc
		ret

GetString_backspace:
		ld h,a
		ld a,l
		cp 255
		jp z,GetString_loop	; Don't let them back up past 0!
		ld a,h
		
		call PrintChar		; Still print the backspace so display steps back
		dec bc			; But decrement the buffer address... 
		inc l			; ...and inc avail buffer space
		jp GetString_loop	; Go about your business..
		
; *** API: StrLen ***
; Expects: bc - base address of zero-terminated string
; Returns: a - length of the string
StrLen:		push bc
		push hl
		ld l,0
StrLen_lp:	ld a,(bc)
		cp 0
		jp z,StrLen_end
		inc l
		inc bc
		jp StrLen_lp
StrLen_end:	ld a,l
		pop hl
		pop bc
		ret		
		
; *** API: StrCmp ***
; Expects: hl and de to point to the strings to compare
; Returns: carry set if they're the same, unset otherwise
StrCmp:		push hl
		push de
		
StrCmp_lp:	ld a,(de)		; fetch *s1
		cp (hl)
		jp nz,StrCmp_diff	; quit if *s1 != *s2
		or a			; check *s1 for zero
		inc de
		inc hl
		jp nz,StrCmp_lp		; loop if *s1 != 0
		
		pop de
		pop hl
		scf			; we ran out of string and they ain't been different yet! set carry flag
		ret
		
StrCmp_diff:	pop de
		pop hl
		and a			; reset carry flag
		ret
	
; *** API: StrCmp ***
; Expects: hl and de to point to the strings to compare
; Returns: carry set if hl starts with de
StrStarts:	push hl
		push de
		
StrStarts_lp:	ld a,(de)		; fetch *s1
		cp 0			; if *s1 is 0 we got to end of s1 without a difference!
		jp z,StrStarts_same
		cp (hl)
		jp nz,StrStarts_diff	; quit if *s1 != *s2
		or a			; check *s1 for zero
		inc de
		inc hl
		jp nz,StrStarts_lp	; loop if *s1 != 0
		
StrStarts_same:	pop de
		pop hl
		scf			; we ran out of string and they ain't been different yet! set carry flag
		ret
		
StrStarts_diff:	pop de
		pop hl
		and a			; reset carry flag
		ret
	
; *** API: ScanChar ***
; Expects: Nothing
; Returns: Received character in a, or 0 if none waiting
ScanChar:	in a,(uart_sr_csr)
		bit uart_rxrdybit,a
		jr z,ScanChar_none
		in a,(uart_data)
		ret
ScanChar_none:	ld a,0
		ret
		
; *** API: GetChar ***
; Expects: Nothing
; Returns: Received character in a
GetChar:	in a,(uart_sr_csr)	; Wait for SR RxRdy
		bit uart_rxrdybit,a
		jr z,GetChar
		in a,(uart_data)
		cp 10			; Check for 10 (maybe a serial client sent 13,10 as a newline)
		jp z,GetChar		; Meh, we ignore them		
		call PrintChar
		ret

; *** API: GetCharSilent ***
; (This variant doesn't echo the character)
; Expects: Nothing
; Returns: Received character in a
GetCharSilent:	in a,(uart_sr_csr)	; Wait for SR RxRdy
		bit uart_rxrdybit,a
		jr z,GetCharSilent
		in a,(uart_data)
		cp 10			; Check for 10 (maybe a serial client sent 13,10 as a newline)
		jp z,GetCharSilent	; Meh, we ignore them		
		ret

; *** API: PrintChar ***
; Expects: a - ASCII char to print
PrintChar:	ex af,af'		; Save a			
PrintChar_wait_txempty:	
		in a,(uart_sr_csr)	; Wait for SR TxEmpty bit
		bit uart_txemptybit,a
		jr z,PrintChar_wait_txempty
		ex af,af'		; Load a
		out (uart_data),a	; Send it
		ret

; *** API: PrintLine ***
; Expects: bc - base address of zero-terminated string
PrintLine:	call PrintString
		call NewLine
		ret

; *** API: PrintString ***
; Expects: bc - base address of zero-terminated string
PrintString:	push bc
PrintString_wait_txrdy:	
		in a,(uart_sr_csr)	; Wait for SR TxEmpty bit
		bit uart_txemptybit,a
		jp z,PrintString_wait_txrdy
		ld a,(bc)		; Get current byte
		cp 0			; Check for 0
		jp z,PrintString_end
		out (uart_data),a	; Send it
		inc bc
		jp PrintString_wait_txrdy
PrintString_end:
		pop bc
		ret
	
; *** API: PrintHex8 and PrintHex16 ***
; Expects: a - Number to print (1 byte)
; Expects: hl - Number to print (2 byte)
PrintHex8:	push bc
		push de
		ld b,a			; Back up a
		call PrintHex_Num21
		ld a,b			; Restore a
		jp PrintHex_Num24

PrintHex16:	push bc
		push de
		ld a,h
		call PrintHex_Num21
		ld a,h
		call PrintHex_Num22
		ld a,l
		call PrintHex_Num21
		ld a,l
		jp PrintHex_Num24

PrintHex_Num21:	rra
		rra
		rra
		rra
PrintHex_Num22:	or $F0
		daa
		add a,$A0
		adc a,$40
		call PrintChar
		inc de
		ret
PrintHex_Num24:	or $F0
		daa
		add a,$A0
		adc a,$40
		call PrintChar
		pop de
		pop bc
		ret
		
; *** API: PrintBinary8 ***
; Expects: a - Number to print
PrintBinary8:	push bc
		ld b,8
PrintBinary8_loop:	
		rlca
		ld c,a
		and $1
		add a,$30
		call PrintChar
		ld a,c
		djnz PrintBinary8_loop
		pop bc
		ret
	
; *** API: SandRand8 ***
; Seeds the PRNG
; Expects: hl - seed
SeedRand16:	ld (rand16_seed),hl
		ret	

; *** API: Rand16 ***
; Expects: Nothing
; Returns: Pseudorandom num in HL, period 65536
Rand16:		push de
		ld de,(rand16_seed)
		ld a,d
		ld h,e
		ld l,253
		or a
		sbc hl,de
		sbc a,0
		sbc hl,de
		ld d,0
		sbc a,d
		ld e,a
		sbc hl,de
		jr nc,Rand16_done
		inc hl
Rand16_done	ld (rand16_seed),hl
		pop de
		ret

; *** API: SandRand8 ***
; Seeds the PRNG
; Expects: a - seed
SeedRand8:	ld (rand8_seed),a
		ret

; *** API: Rand8 ***
; Expects: Nothing
; Returns: Pseudorandom num in a, period 256
; Algo: x[i + 1] = (5 * x[i] + 1) mod 256
Rand8:		ld a,(rand8_seed)
		push bc
		ld b,a
		add a,a
		add a,a
		add a,b
		inc a			; another possibility is ADD A,7
		ld (rand8_seed),a
		pop bc
		ret

; *** API: PrintUInt16 ***
; Input: HL = number to print
PrintUInt16:	push bc
		push de
		push hl
		ld de,int_buffer
		call Num2Dec16		
		ld a,0			; Add zero terminator
		ld (de),a			
		ld bc,int_buffer		
PrintUInt16Step:
		ld a,(bc)
		cp '0'
		jp nz,PrintUInt16Done
		inc bc
		jp PrintUInt16Step
PrintUInt16Done:
		call PrintString
		pop hl
		pop de
		pop bc
		ret
		
Num2Dec16:	ld bc,-10000
		call Num2Dec16_Num1
		ld bc,-1000
		call Num2Dec16_Num1
		ld bc,-100
		call Num2Dec16_Num1
		ld c,-10
		call Num2Dec16_Num1
		ld c,-1

Num2Dec16_Num1:	ld a,'0'-1
Num2Dec16_Num2:	inc a
		add hl,bc
		jr c,Num2Dec16_Num2
		sbc hl,bc
		ld (de),a
		inc de
		ret	

; *** API: AToUInt16 ***
; Expects: de - pointer to a zero-terminated string
; Returns: hl - UInt16
AToUInt16:	ld hl,0			; Clear hl
AToUInt16_loop:	ld a,(de)		; Get current char
		cp 48			; Check for non-ASCII
		jr c,AToUInt16_end	; 48 is bigger than A
		cp 58
		jr nc,AToUInt16_end	; 58 is bigger than A (legit chars are 48-57!)
		sub 48			; Sub 48 to make ASCII char a decimal digit
		ld b,0
		ld c,a	 		; bc = new_digit
		
		push de
		ld de,hl
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		add hl,de
		pop de
		add hl,bc		; hl = 10*old_number+new_digit
		inc de
		jr AToUInt16_loop
AToUInt16_end:	ret
		
; *** API: AToUInt8 ***
; Expects: hl - pointer to a zero-terminated string
; Returns: 8 bit unsigned integer in a
AToUInt8:	push bc
		ld c,0			; Clear c
AToUInt8_loop:	ld a,(hl)
		cp 0			; End-of-string?
		jr z,AToUInt8_end
		cp ' '			; MARK: Allow a space to terminate also!
		jr z,AToUInt8_end
		sub '0'			; (Sub 48)
		jr c,AToUInt8_end 	; Less than 0
		cp 10
		jr nc,AToUInt8_end 	; Greater than 9
		ld b,a	 		; b = new_digit
		ld a,c			; a = old_number
		sla a
		sla a			; a = 4*old_number
		add a,c			; a = 5*old_number
		sla a			; a = 10*old_number
		add a,b			; a = 10*old_number+new_digit
		ld c,a
		inc hl
		jr AToUInt8_loop
AToUInt8_end:	ld a,c
		pop bc
		ret
		
; *** API: AHexToUInt8 ***
; Expects: hl - pointer to a zero-terminated string. a-f should be LOWERCASE!
; Returns: 8 bit unsigned integer in c; error code or 0 on success in b
AHexToUInt8:	push af
		ld c,0
		ld b,2			; counter for 2 nibbles
AHexToUInt8_nextc:	
		ld a,(hl)
		inc hl
		cp 0
		jr z,AHexToUInt8_end 	; End-of-string found
		cp ' '			; Skip space
		jr z,AHexToUInt8_nextc
		cp 9			; Skip tabs
		jr z,AHexToUInt8_nextc
		cp 'a'
		jr c,AHexToUInt8_test_hex_uc
		sub 'a'-10
		cp 16
		jr nc,AHexToUInt8_end 	; Not in a-f, skip conversion
		jp AHexToUInt8_svr
AHexToUInt8_test_hex_uc:	
		cp 'a'
		jr c,AHexToUInt8_test_dec
		sub 'a'-10
		cp 16
		jr nc,AHexToUInt8_end 	; Not in a-f, skip conversion
		jp AHexToUInt8_svr
AHexToUInt8_test_dec:	
		sub '0'
		cp 10
		jr nc,AHexToUInt8_end 	; Not in 0-9, skip conversion
AHexToUInt8_svr:	
		or c
		ld c,a
		dec b
		jr z,AHexToUInt8_end
		sla c
		sla c
		sla c
		sla c
		jp AHexToUInt8_nextc 	; Next char
AHexToUInt8_end:
		pop af
		ret
		
; *** API: Div8 ***
; Expects: h = dividend, l = divisor
; Returns: h = quotient, a = remainder
Div8:		ld a,0
		
		sla h			; unroll 8 times: 1 
		rla			; ...
		cp l			; ...
		jr c,div8lu1		; ...
		sub l			; ...
		inc h			; ...
		
div8lu1:	sla h			; unroll 8 times: 2
		rla			; ...
		cp l			; ...
		jr c,div8lu2		; ...
		sub l			; ...
		inc h			; ...
		
div8lu2:	sla h			; unroll 8 times: 3
		rla			; ...
		cp l			; ...
		jr c,div8lu3		; ...
		sub l			; ...
		inc h			; ...
		
div8lu3:	sla h			; unroll 8 times: 4
		rla			; ...
		cp l			; ...
		jr c,div8lu4		; ...
		sub l			; ...
		inc h			; ...
		
div8lu4:	sla h			; unroll 8 times: 5
		rla			; ...
		cp l			; ...
		jr c,div8lu5		; ...
		sub l			; ...
		inc h			; ...
		
div8lu5:	sla h			; unroll 8 times: 6
		rla			; ...
		cp l			; ...
		jr c,div8lu6		; ...
		sub l			; ...
		inc h			; ...
		
div8lu6:	sla h			; unroll 8 times: 7
		rla			; ...
		cp l			; ...
		jr c,div8lu7		; ...
		sub l			; ...
		inc h			; ...
		
div8lu7:	sla h			; unroll 8 times: 8
		rla			; ...
		cp l			; ...
		jr c,div8lu8		; ...
		sub l			; ...
		inc h			; ...

div8lu8:	ret
		
; *** API: Add32 ***
; Performs H'L'HL = H'L'HL + D'E'DE
; Expects: H, H', L, L', D, D', E, E' as above
; Returns: H, H', L, L' as above
; Changes: Flags
Add32:		add hl,de   		; 16-bit add of hl and de
        	exx
	        adc hl,de   		; 16-bit add of hl and de with carry
        	exx
	        ret			; result is in h'l'hl

; *** API: Mul32 ***
; Performs H'L'HL = B'C'BC * D'E'DE (32 bit result)
; Expects: B, B', C, C', D, D', E, E' as above
; Returns: H, H', L, L' as above
; Changes: A, Flags
Mul32:		and a               	; reset carry flag
		sbc hl,hl           	; lower result = 0
		exx
		sbc hl,hl           	; higher result = 0
		ld a,b            	; mpr is ac'bc
		ld b,32            	; initialize loop counter

Mul32loop:	sra a               	; right shift mpr
		rr c
		exx
		rr b
		rr c               	; lowest bit into carry
		jr nc,Mul32noadd
		add hl,de           	; result += mpd
		exx
		adc hl,de
		exx

Mul32noadd:	sla e              	; left shift mpd
		rl d
		exx
		rl e
		rl d
		djnz Mul32loop
		exx

		ret			; result in h'l'hl

; *** API: Mul16 ***
; Performs HL = BC * DE
; Expects: BC, DE
; Returns: HL
Mul16:		ld a,b
		ld b,16
Mul16_lp:	add hl,hl
		sla c
		rla
		jr nc,Mul16_noadd
		add hl,de
Mul16_noadd:	djnz Mul16_lp
		ret

; *** API: Div16 ***
; Performs BC = BC / DE
; Expects: BC, DE
; Returns: BC = result, HL = remainder
Div16:		ld hl,0
		ld a,b
		ld b,8
Div16_Loop1:	rla
		adc hl,hl
		sbc hl,de
		jr nc,Div16_NoAdd1
		add hl,de
Div16_NoAdd1:	djnz Div16_Loop1
		ld b,a
		ld a,c
		ld c,b
		ld b,8
Div16_Loop2:	rla
		adc hl,hl
		sbc hl,de
		jr nc,Div16_NoAdd2
		add hl,de
Div16_NoAdd2:	djnz Div16_Loop2
		rla
		cpl
		ld b,a
		ld a,c
		ld c,b
		rla
		cpl
		ld b,a
		ret
		
; *** API: RFSRename ***
; Interactive file rename
; Expects: Nothing
; Returns: Nothing
RFSRename:	call RFSCheckFSMounted
		ret nc
		
		ld bc,msgrnsource
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine

		ld de,scratch_base	; de<--target address ldir
		ld hl,string_buffer
		ld bc,15		; bc<--bytecount ldir
		ldir
		
		ld a,0
		ld (de),a ; Ensure a terminated string
		
		ld bc,msgrnsourcetag
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine
		
		ld de,scratch_base+16	; de<--target address ldir
		ld hl,string_buffer
		ld bc,15		; bc<--bytecount ldir
		ldir
		
		ld a,0
		ld (de),a ; Ensure a terminated string
		
		ld a,(fileindex_size)
		ld b,a			; b <-- num blocks of fileindex left to traverse
		ld a,(freemap_size)
		ld h,0
		ld l,a
		inc hl			; hl <-- current fileindex block num
		
rnnextfiblock:	push bc			; Backup num blocks of fileindex left
		push hl			; Backup current fileindex block
		ld a,0
		ld (ide_lba2),a		; Grab the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld b,64			; b <-- 64 file records per block
rnfiinnerblocklp:	
		push bc			; backup records left this block
		push hl			; backup start of current record into block_buffer
		
		ld de,string_buffer
		call StrCmp		; compare filename
		jp nc,rntrynext

		ld de,16
		add hl,de
		ld de,string_buffer+16
		call StrCmp		; compare tag
		jp nc,rntrynext
		
		ld de,16		; Sub 16 from hl to step back to filename, store it in de
		sbc hl,de
		ld d,h
		ld e,l
		
		jp rnfoundit
				
rntrynext:	pop hl			; pop curr rec addr
		ld de,64
		add hl,de		; hl <-- start of next file record
		
		pop bc			; pop records left this block
		djnz rnfiinnerblocklp	; Keep going till block finished
		
		pop hl			; Restore current fileindex block
		pop bc			; Restore num blocks of fileindex left
		inc hl			; Inc fileindex block
		djnz rnnextfiblock	; Loop if more blocks to go through
		
		ld bc,msgrnnotok
		call PrintLine
		
		ret
	
rnfoundit:	pop hl
		pop bc
		pop hl
		pop bc
		
		push de
		ld bc,msgrndest
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine
		pop de			; de<--target address ldir

		push de
		ld hl,string_buffer
		ld bc,15		; bc<--bytecount ldir
		ldir
		
		ld a,0
		ld (de),a ; Ensure a terminated string
		
		ld bc,msgrndest
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine
		pop de			; de<--target address ldir

		ld h,d
		ld l,e
		ld de,16
		add hl,de
		ld d,h
		ld e,l
		
		ld hl,string_buffer
		ld bc,15		; bc<--bytecount ldir
		ldir

		ld a,0
		ld (de),a ; Ensure a terminated string

		; TODO: Check rename looks OK in block buffer (debug)
		; TODO: rewrite the block and show success message
		ld bc,msgrnok
		call PrintLine
		
		ret
		
msgrnsource	defm "Enter source filename"
		defb 0

msgrnsourcetag	defm "Enter source tag"
		defb 0
		
msgrndest	defm "Enter destination filename"
		defb 0

msgrndesttag	defm "Enter destination tag"
		defb 0
		
msgrnok		defm "The shizzle is renamed!"
		defb 0
		
msgrnnotok 	defm "I am sorry ese, cause I no find file"
		defb 0
		
; *** API: RFSFileExists ***
; Does a file exist?
; Expects: bc = filename/tag combo to check (32 bytes)
; Returns: carry set if exists, not set if doesn't
; Trashes: STRING BUFFER
RFSFileExists:	call RFSCheckFSMounted
		ret nc
	
		push bc			; backup filename
		
		ld de,string_buffer	; de<--target address ldir
		ld h,b			; hl<--source address ldir
		ld l,c
		ld bc,32		; bc<--bytecount ldir
		ldir
		
		ld a,(fileindex_size)
		ld b,a			; b <-- num blocks of fileindex left to traverse
		ld a,(freemap_size)
		ld h,0
		ld l,a
		inc hl			; hl <-- current fileindex block num
		
fenextfiblock:	push bc			; Backup num blocks of fileindex left
		push hl			; Backup current fileindex block
		ld a,0
		ld (ide_lba2),a		; Grab the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld b,64			; b <-- 64 file records per block
fefiinnerblocklp:	
		push bc			; backup records left this block
		push hl			; backup start of current record into block_buffer
		
		ld de,string_buffer
		call StrCmp
		jp nc,fetrynext

		ld de,16
		add hl,de
		ld de,string_buffer+16
		call StrCmp
		jp nc,fetrynext
		
		jp fefoundit
				
fetrynext:	pop hl			; pop curr rec addr
		ld de,64
		add hl,de		; hl <-- start of next file record
		
		pop bc			; pop records left this block
		djnz fefiinnerblocklp	; Keep going till block finished
		
		pop hl			; Restore current fileindex block
		pop bc			; Restore num blocks of fileindex left
		inc hl			; Inc fileindex block
		djnz fenextfiblock	; Loop if more blocks to go through
		
		pop bc			; Restore filename
		and a			; Clear carry flag to indicate it doesn't exist!
		ret
	
fefoundit:	pop hl
		pop bc
		pop hl
		pop bc
		pop bc			; Restore filename
		
		scf
		ret
		
; *** API: RFSListTagged ***
; List all files with given tag (it asks)
; Expects: Nothing
; Returns: Nothing
RFSListTagged:	call RFSCheckFSMounted
		ret nc

		ld a,0
		ld (ide_lba2),a		; Grab the superblock
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld bc,msglistall	; Print current name
		call PrintString
		ld bc,block_buffer+10
		call PrintLine
		
		ld bc,msgwithtag
		call PrintLine
		ld a,shellprompt
		call PrintChar
		call GetString
		call NewLine
		
		ld bc,msglistall2
		call PrintLine
		
		ld a,(fileindex_size)
		ld b,a			; b <-- num blocks of fileindex left to traverse
		ld a,(freemap_size)
		ld h,0
		ld l,a
		inc hl			; hl <-- current fileindex block num
		
ltnextfiblock:	push bc			; Backup num blocks of fileindex left
		push hl			; Backup current fileindex block
		ld a,0
		ld (ide_lba2),a		; Grab the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld b,64			; b <-- 64 file records per block
ltfiinnerblocklp:	
		push bc			; backup records left this block
		push hl			; backup start of current record into block_buffer
		
		push hl			; backup start of current record into block_buffer
		ld de,16
		add hl,de		; hl <-- current record tag
		ld d,h			; de <-- current tag
		ld e,l
		ld hl,string_buffer	; hl <-- string buffer
		call StrCmp
		pop hl			; restore start of current record in b_buff
		jp nc,ltskipit		; tag didn't match? skip it
		
		ld b,h			; Matched, print the record son!!
		ld c,l
		call PrintString
		ld bc,msgFileColSep1
		call PrintString
		ld de,16
		add hl,de
		ld b,h			; Print the tag!
		ld c,l
		call PrintString
		ld bc,msgFileColSep2
		call PrintString
		ld de,19
		add hl,de			
		ld a,(hl)		; Grab num blocks

		ld b,a
		ld de,4
		ld hl,0
ltsizedisplp:	add hl,de		; Calc filesize from that
		djnz ltsizedisplp
		call PrintUInt16	; Print that shizzle!
		ld bc,msgkb
		call PrintLine
		
ltskipit:	pop hl
		ld de,64		; Step to next record
		add hl,de
		pop bc
		djnz ltfiinnerblocklp
		
		pop hl			; Restore current fileindex block
		pop bc			; Restore num blocks of fileindex left
		inc hl			; Inc fileindex block
		djnz ltnextfiblock	; Loop if more blocks to go through
		
		ret
	
msgwithtag:	defm "with tag?"
		defb 0
		
; *** API: RFSListAll ***
; List all files
; Expects: Nothing
; Returns: Nothing
RFSListAll:	call RFSCheckFSMounted
		ret nc

		ld a,0
		ld (ide_lba2),a		; Grab the superblock
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld bc,msglistall	; Print current name
		call PrintString
		ld bc,block_buffer+10
		call PrintLine
		ld bc,msglistall2
		call PrintLine
		
		ld a,(fileindex_size)
		ld b,a			; b <-- num blocks of fileindex left to traverse
		ld a,(freemap_size)
		ld h,0
		ld l,a
		inc hl			; hl <-- current fileindex block num
		
lanextfiblock:	push bc			; Backup num blocks of fileindex left
		push hl			; Backup current fileindex block
		ld a,0
		ld (ide_lba2),a		; Grab the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld b,64			; 64 file records per block
lafiinnerblocklp:	
		push bc
		push hl
		ld a,(hl)		; Grab this byte
		cp 0			; Is it a 0?
		jp z,laskipit		; Yeah, skip it
		
		ld b,h			; No, print it son!!
		ld c,l
		call PrintString
		ld bc,msgFileColSep1
		call PrintString
		ld de,16
		add hl,de
		ld b,h			; Print the tag!
		ld c,l
		call PrintString
		ld bc,msgFileColSep2
		call PrintString
		ld de,19
		add hl,de			
		ld a,(hl)		; Grab num blocks

		ld b,a
		ld de,4
		ld hl,0
lasizedisplp:	add hl,de		; Calc filesize from that
		djnz lasizedisplp
		call PrintUInt16	; Print that shizzle!
		ld bc,msgkb
		call PrintLine
		
laskipit:	pop hl
		ld de,64		; Step to next record
		add hl,de
		pop bc
		djnz lafiinnerblocklp
		
		pop hl			; Restore current fileindex block
		pop bc			; Restore num blocks of fileindex left
		inc hl			; Inc fileindex block
		djnz lanextfiblock	; Loop if more blocks to go through
		
		ret
		
msglistall:	defm "Listing all files on "
		defb 0

msglistall2:	defm "Filename (Tag) Size"
		defb 0

msgFileColSep1: defm " ("
		defb 0
		
msgFileColSep2: defm ") "
		defb 0		

msgkb:		defm "KB"
		defb 0
		
; *** API: RFSWriteFile ***
; Write a goddam file
; Expects: bc=filename, hl=start address, de=bytecount
; Returns: Nothing
RFSWriteFile:	call RFSCheckFSMounted
		ret nc

		call RFSFileExists
		jp c,RFSBailFileExistsAndReturn

		; 1. Check bytecount and calculate how many blocks needed
		push hl
		push bc
		ld h,d
		ld l,e
		ld de,4093
		ld b,0
blksneededlp:	inc b
		jp z,filetoobig
		sbc hl,de
		jp nc,blksneededlp
		ld a,b
		ld (scratch_base),a	; Store num blocks needed
		pop bc
		pop hl
		
		; 2. Loop through freemap blocks checking each byte until enough free blocks found; for every free one found, stick its block number in a FIFO, mark it as used. Re-write all touched freemap blocks.
		push hl			; Backup arguments - start address
		push bc			; Backup arguments - filename
		
		ld a,0			; scratch_base 3-5 will keep track of found block number
		ld (scratch_base+3),a
		ld (scratch_base+4),a
		ld (scratch_base+5),a
		
		ld hl,scratch_base+10	; scratch_base 6 and 7 will keep track of next FIFO address
		ld a,l
		ld (scratch_base+6),a
		ld a,h
		ld (scratch_base+7),a
		
		ld a,(freemap_size)
		ld b,a			; b <-- num blocks of freemap left
		ld a,(scratch_base)
		ld (scratch_base+1),a	; Backup num required blocks left to find
		ld hl,1			; hl <-- current freemap block num
nextfmblock:	push bc			; Backup num blocks of freemap left
		push hl			; Backup current freemap block
		ld a,0
		ld (ide_lba2),a		; Grab the current freemap block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		ld a,0
		ld (scratch_base+2),a	; Indicate that no block re-write needed
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld bc,4096		; Loop entire block
innerblocklp:	ld a,(hl)		; Grab this byte
		cp 0			; Is it a 0?
		jp nz,skipthisone	; No -- block occupied
		
		ld a,1			; Yes!! Mark the block as occupied...
		ld (hl),a		
		ld (scratch_base+2),a	; Indicate that block re-write IS needed
		
		; Found one! Store the block number in the FIFO :P
		push hl
		ld a,(scratch_base+6)	; Grab current FIFO address
		ld l,a
		ld a,(scratch_base+7)
		ld h,a
		ld a,(scratch_base+3)	; Write block num low byte...
		ld (hl),a
		inc hl
		ld a,(scratch_base+4)	; Write block num mid byte...
		ld (hl),a
		inc hl
		ld a,(scratch_base+5)	; Write block num high byte...
		ld (hl),a
		inc hl		
		ld a,l
		ld (scratch_base+6),a	; Store current FIFO address
		ld a,h
		ld (scratch_base+7),a
		pop hl
		
		ld a,(scratch_base+1)	; Grab number of remaining needed blocks, decrement it, rewrite
		dec a
		ld (scratch_base+1),a
		cp 0			; Is it zero now?
		jp z,writethisblockandcont ; Yes!! Bail out -- write the current freemap block cos it just changed, but don't check any more
		
skipthisone:	inc hl			; Increment address into block buffer
		
		push hl			; Now inc main 3-byte block num.....		
		ld a,(scratch_base+3)
		ld l,a
		ld a,(scratch_base+4)
		ld h,a
		ld de,1
		exx
		ld a,(scratch_base+5)
		ld l,a
		ld a,0
		ld h,a
		ld de,0
		exx
		call Add32         	; does H'L'HL = H'L'HL + D'E'DE
		exx
		ld a,l
		ld (scratch_base+5),a
		exx
		ld a,h
		ld (scratch_base+4),a
		ld a,l
		ld (scratch_base+3),a
		pop hl			; Block num inc'd!	
		
		dec bc			; See if more bytes remaining this block
		ld a,b			; check if BC==0
		or c
		jp nz,innerblocklp
		
		ld a,(scratch_base+2)	; No more bytes this block; rewrite the block if needed
		cp 0			; Is it then?
		jp z,rewritedone	; not needed? skip it
		pop hl			; rewrite needed! restore the block num...
		push hl			; ...re-push block num
		ld a,0
		ld (ide_lba2),a		; Re-write the current freemap block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSWriteBlock	
		
rewritedone:	pop hl			; Restore current freemap block
		pop bc			; Restore num blocks of freemap left
		inc hl			; Inc freemap block
		;djnz nextblock		; Loop if more blocks to go through
		dec b			; LOL -- too far away for djnz...
		jp nz,nextfmblock	; ...needs a long jump!

		pop bc			; Oh no! Ran out of freemap blocks without finding space -- save failed :(
		pop hl			; Restore arguments...
		
		ld bc,msgDiskFull
		call PrintLine
		
		and a			; Set carry to false...
		ret			; And ret :(			
		
writethisblockandcont:			; OK, all needed blocks found; re-write the current block and we're on our way.
		pop hl			; rewrite needed! restore the block num...
		push hl			; ...re-push block num
		ld a,0
		ld (ide_lba2),a		; Re-write the current freemap block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSWriteBlock	
		pop hl			; Restore current freemap block
		pop bc			; Restore num blocks of freemap left
		pop bc			; Restore arguments: Filename
		pop hl			; Restore arguments: Start address

		push hl
		ld a,(scratch_base+6)	; Grab current FIFO address
		ld l,a
		ld a,(scratch_base+7)
		ld h,a
		ld a,0			; Write block num 0 (these will be picked up and used as continuation records by step 3)
		ld (hl),a
		inc hl
		ld (hl),a
		inc hl
		ld (hl),a
		pop hl
		
		; 3. Dump the data
		; ALRIGHT! (scratch_base) contains number of blocks to write, and block numbers to use are in memory at scratch_base+10 onwards (stride=3).
		; They've already been marked as used in the freemap.
		; hl = start address in RAM of data to dump
		; de = bytecount to dump
		
		; set fifo pointer in scratch_base6 and 7 back to scratch_base+10
		; for (num blocks to write) {
		;    - copy next 4093 bytes into block buffer
		;    - retrieve current block number and increment the pointer
		;    - peek at next block number and tack it into last 3 bytes of block buffer
		;    - write the block
		; }
		push hl
		ld hl,scratch_base+10	; scratch_base 6 and 7 will keep track of next FIFO address
		ld a,l
		ld (scratch_base+6),a
		ld a,h
		ld (scratch_base+7),a		
		pop hl
		
		push bc			; Backup arguments: Filename
		ld a,(scratch_base)
		ld b,a			; b <-- num blocks to write
dumpnextblock:	push bc			; Backup block write counter
		ld de,block_buffer	; Target address ldir
		ld bc,4093		; Bytecount for ldir
		ldir			; Copy next 4093 bytes into block buffer (source address for ldir is hl)
		
		push hl			; retrieve current block number from the FIFO and increment the pointer
		ld a,(scratch_base+6)	; Grab current FIFO address...
		ld l,a
		ld a,(scratch_base+7)
		ld h,a
		
		ld a,(hl)		; Grab destination block number: Low byte
		ld (ide_lba0),a
		inc hl
		ld a,(hl)		; Mid byte
		ld (ide_lba1),a
		inc hl
		ld a,(hl)		; High byte
		ld (ide_lba2),a
		inc hl

		ld a,l
		ld (scratch_base+6),a	; Store current FIFO address
		ld a,h
		ld (scratch_base+7),a
				
		ld a,(hl)		; Grab next destination block number: Low byte
		ld (block_buffer+4093),a ; Stick it at the tail end of block buffer (it's the block continuation record)
		inc hl
		ld a,(hl)		; Mid byte
		ld (block_buffer+4094),a
		inc hl
		ld a,(hl)		; High byte
		ld (block_buffer+4095),a
		
		call RFSWriteBlock	; write the block!!
		pop hl
		
		pop bc			; Restore block write counter
		djnz dumpnextblock
		pop bc			; Restore arguments: Filename
		
		; 4. Create the file record
		; foreach (file index block) {
		; 	- read current block
		;	- search current block for a blank entry
		;	if (blank entry found) {
		;		- Create record
		;		- Break out of for loop
		;	}
		; }
		; scratch_base+10 contains start block (3 bytes), and
		; bc is the filename. Go!
		push bc			; Backup arguments - filename
				
		ld a,(fileindex_size)
		ld b,a			; b <-- num blocks of fileindex left
		
		ld a,(freemap_size)
		ld h,0
		ld l,a
		inc hl			; hl <-- current fileindex block num
		
nextfiblock:	push bc			; Backup num blocks of fileindex left
		push hl			; Backup current fileindex block
		ld a,0
		ld (ide_lba2),a		; Grab the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld hl,block_buffer	; hl <-- current address in block buffer
		ld b,64			; 64 file records per block
fiinnerblocklp:	ld a,(hl)		; Grab this byte
		cp 0			; Is it a 0?
		jp z,writefiblock	; Found a blank!	
		ld de,64		; File record stride
		add hl,de		; Increment address into block buffer
		djnz fiinnerblocklp
		
		pop hl			; Restore current freemap block
		pop bc			; Restore num blocks of freemap left
		inc hl			; Inc freemap block
		djnz nextfiblock	; Loop if more blocks to go through
		
		pop bc			; Oh no! Ran out of FI blocks without finding file record space -- save failed :( Restore args -- filename
		ld bc,msgFileIndexFull
		call PrintLine		
		and a			; Set carry to false...
		ret			; And ret :(			
		
writefiblock:	ld d,h			; Backup filerecord address in de
		ld e,l
		pop hl			; Restore the fileindex block num
		pop bc			; Restore num blocks of freemap left
		pop bc			; Restore arguments: Filename
		; bc = filename address; de = filerecord address; hl = block number

		push hl			; Backup block number
		ld h,b
		ld l,c
		ld bc,31
		ldir
		ld a,0
		ld (de),a		; Ensure a terminated string		
		pop hl			; Restore block number
		
		inc de
		ld a,(scratch_base+10)	; Grab first block in file (low byte)
		ld (de),a		; Dump it into file record
		inc de
		ld a,(scratch_base+11)	; Grab first block in file (mid byte)
		ld (de),a		; Dump it into file record
		inc de
		ld a,(scratch_base+12)	; Grab first block in file (high byte)
		ld (de),a		; Dump it into file record		
		
		inc de
		ld a,(scratch_base)	; Grab number of blocks
		ld (de),a		; Dump that into file too
		
		ld a,0
		ld (ide_lba2),a		; Re-write the current fileindex block
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSWriteBlock		
		scf			; Saved OK! \o/ Set carry flag
		ret
		
filetoobig:	pop bc			; File is too big to save!!
		pop hl			; Restore arguments...
		ld bc,msgFileTooBig
		call PrintLine		
		and a			; Set carry to false...
		ret			; And ret :(			
		
msgDiskFull:	defm "Eek; disk full! (No free blocks)"
		defb 0
		
msgFileIndexFull:
		defm "Eek; disk full! (Out of file records)"
		defb 0

msgFileTooBig:	defm "A file that big?"
		defb 13,10
		defm "It might be very useful."
		defb 13,10
		defm "But now it is gone."
		defb 13,10
		defb 13,10
		defm "Only supporting up to 1Mb per file"
		defb 13,10
		defm "for now (but not due to any RFS"
		defb 13,10
		defm "limitation). You must have upped"
		defb 13,10
		defm "your RAM in a BIG way!!"
		defb 0
		
; *** API: RFSRenameLib ***
; Interactive library rename
; Expects: Nothing
; Returns: Nothing
RFSRenameLib:	call RFSCheckFSMounted
		ret nc

		ld a,0
		ld (ide_lba2),a		; Grab the superblock
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSReadBlock
		
		ld bc,msgrenamelibcn	; Print current name
		call PrintString
		ld bc,block_buffer+10
		call PrintLine
		
		ld bc,msgrenamelibnn	; Prompt for new name
		call PrintLine
		ld a,shellprompt
		call PrintChar		
		call GetString		
		call NewLine
		ld hl,string_buffer	; Copy lib name into WIP superblock
		ld de,block_buffer+10
		ld bc,16
		ldir
		ld a,0
		ld (block_buffer+25),a 	; Ensure a terminated string
		
		ld a,0			; Write the superblock! No turning back now...
		ld (ide_lba2),a
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSWriteBlock		

		ld bc,msgrenamelibok
		call PrintLine
		
		ret

msgrenamelibcn:	defm "Current library name: "
		defb 0		
		
msgrenamelibnn:	defm "Enter new name (15 chars max)..."
		defb 0

msgrenamelibok:	defm "Renamed OK, dog!"
		defb 0
		
; *** API: RFSFormat ***
; Interactive format routine
; Expects: Nothing
; Returns: Nothing
RFSFormat:	ld bc,msgformatwelcome	; Continue confirmation
		call PrintLine
		call GetChar
		cp 'y'
		call NewLine
		ret nz
		
		call RFSBlankBlockBuffer ; Blank to generate the superblock
		
		ld a,$42		; Store RFS magic number in right place of WIP superblock
		ld (block_buffer+8),a
		
		ld bc,msgformatfmsize	; Prompt for freemap size
		call PrintLine
		ld a,shellprompt
		call PrintChar		
		call GetString		
		call NewLine
		ld hl,string_buffer
		call AToUInt8
		ld (block_buffer+26),a 	; Store size in WIP superblock
		ld (freemap_size),a 	; Store size in sys constant
		
		ld bc,msgformatfisize	; Prompt for fileindex size
		call PrintLine
		ld a,shellprompt
		call PrintChar		
		call GetString		
		call NewLine
		ld hl,string_buffer
		call AToUInt8
		ld (block_buffer+27),a 	; Store size in WIP superblock
		ld (fileindex_size),a 	; Store size in sys constant

		ld bc,msgformatlibnm
		call PrintLine
		ld a,shellprompt
		call PrintChar		
		call GetString		
		call NewLine
		ld hl,string_buffer	; Copy lib name into WIP superblock
		ld de,block_buffer+10
		ld bc,16
		ldir
		ld a,0
		ld (block_buffer+25),a 	; Ensure a terminated string
		
		ld bc,msgformatgo
		call PrintLine
				
		ld a,0			; Write the superblock! No turning back now...
		ld (ide_lba2),a
		ld (ide_lba1),a
		ld (ide_lba0),a
		call RFSWriteBlock
				
		call RFSBlankBlockBuffer ; Blank to generate the first freemap block
		
		ld a,(fileindex_size)
		inc a
		ld d,a
		ld a,(freemap_size)
		add a,d
		ld b,a			; b <-- 1+freemapsize+fileindexsize
		push af			; backup 1+freemapsize+fileindexsize
		ld hl,block_buffer
freemapcrtlp:	ld (hl),1		; Now set first hl bytes in freemap to 1!
		inc hl
		djnz freemapcrtlp
		
		ld a,0			; Write the first freemap block
		ld (ide_lba2),a
		ld (ide_lba1),a
		ld a,1
		ld (ide_lba0),a
		call RFSWriteBlock
		
		call RFSBlankBlockBuffer ; Blank to generate other freemap blocks + fileindex blocks
		
		pop af			; Restore 1+freemapsize+fileindexsize
		sub 2			; We've done the superblock + first freemap block...
		ld b,a			; b <-- the number of blank blocks to now write!
		ld hl,2			; First block num to write
bnkblklp:	push bc
		push hl
		ld a,0
		ld (ide_lba2),a
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		call RFSWriteBlock		
		pop hl
		pop bc
		inc hl
		djnz bnkblklp
		
		ld bc,msgformatok
		call PrintLine
		ret
		
msgformatwelcome:
		defm "RiFT-FS 1.0 HD format"
		defb 13,10,13,10
		defm "WARNING: This will completely destroy"
		defb 13,10
		defm "the disk contents! Press y to go on,"
		defb 13,10
		defm "or any other key to exit."
		defb 0

msgformatfmsize:
		defm "How many blocks for freemap? (RFS can"
		defb 13,10
		defm "address 16Mb per freemap block)"
		defb 0

msgformatfisize:
		defm "How many blocks for file index? (RFS"
		defb 13,10
		defm "can store 64 files per freemap block)"
		defb 0

msgformatlibnm: defm "Enter library name (up to 15 chars)"
		defb 0
				
msgformatgo: 	defm "Formatting... "
		defb 0

msgformatok: 	defm "Formatted OK!"
		defb 0
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; RFS Internal routines  ;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; *** RFS Support Routine: RFSBailFileExistsAndReturn ***
; ****** Note this gets JUMPED TO: it's just supposed to show message and return ******
RFSBailFileExistsAndReturn:
		ld bc,msgFileExists
		call PrintLine
		ret
		
msgFileExists:	defm "File already exists!"
		defb 0
		
; *** RFS Support Routine: RFSCheckFSMounted ***
; Checks a drive exists and is mounted
; Expects: Nothing
; Returns: carry set if exists, unset if not
; Trashes: a
RFSCheckFSMounted:
		ld a,(freemap_size)
		cp 0
		jp z,rfscdenodrv
		scf
		ret
		
rfscdenodrv:	ld bc,msgNoDriveMounted
		call PrintLine
		and a
		ret

msgNoDriveMounted:
		defm "No drive mounted!"
		defb 0
		
; *** RFS Support Routine: RFSBlankBlockBuffer ***
; Fills the block buffer with zeroes
; Expects: Nothing
; Returns: Nothing
RFSBlankBlockBuffer:
		ld hl,block_buffer
		ld a,0
		ld c,16			; 16 sectors
rfsfsetolp:	ld b,0			; * 256 bytes per sector	
rfsfsetlp:	ld (hl),a
		inc hl
		djnz rfsfsetlp
		dec c
		jp nz,rfsfsetolp
		ret
		
; *** RFS Support Routine: RFSReadBlock ***
; Expects: ide_lba0 - ide_lba2: block number; ide_status bit 0 set for master (0) or slave (1)
; Returns: The block, in the block buffer. Carry set if successful, not set if failed.
RFSReadBlock:	call RFSBlockToLBA
	
		ld hl,block_buffer
		ld b,16
readblklp:	push bc
		call ide_read_sector	; NB: This self-advances hl, so we DON'T NEED TO ADD 256 HERE...
		pop bc
		jp nc,diskreaderror		
		push hl			; Now inc sector num.....
		ld a,(ide_lba0)
		ld l,a
		ld a,(ide_lba1)
		ld h,a
		ld de,1
		exx
		ld a,(ide_lba2)
		ld l,a
		ld a,(ide_lba3)
		ld h,a
		ld de,0
		exx
		call Add32         	; does H'L'HL = H'L'HL + D'E'DE
		exx			; load H'L' into top 2 bytes of lba num
		ld a,h
		ld (ide_lba3),a
		ld a,l
		ld (ide_lba2),a
		exx			; load HL into bottom 2 bytes of lba num
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a	
		pop hl			; Sector num inc'd!
		
		djnz readblklp
		scf
		ret
		
diskreaderror:	push af
		ld a,(freemap_size)
		cp 0
		jp z,disknotfound
		ld bc,msghaltingdisk
		call PrintLine
		ld bc,msgdiskrerror
		call PrintString
		pop af
		call PrintHex8
		call NewLine
		halt
		
disknotfound:	pop af
		and a			; Clear carry flag to indicate failure
		ret
		
msgdiskrerror:	defm "Disk Read: "
		defb 0
	
; *** RFS Support Routine: RFSWriteBlock ***
; Expects: ide_lba0 - ide_lba2: block number; ide_status bit 0 set for master (0) or slave (1)
; Returns: Nowt.
RFSWriteBlock:	call RFSBlockToLBA
		
		ld hl,block_buffer
		ld b,16
		
writeblklp:	push bc
		call ide_write_sector
		pop bc		
		jp nc,diskwriteerror		
		push hl			; Now inc sector num.....		
		ld a,(ide_lba0)
		ld l,a
		ld a,(ide_lba1)
		ld h,a
		ld de,1
		exx
		ld a,(ide_lba2)
		ld l,a
		ld a,(ide_lba3)
		ld h,a
		ld de,0
		exx
		call Add32         	; does H'L'HL = H'L'HL + D'E'DE
		exx			; load H'L' into top 2 bytes of lba num
		ld a,h
		ld (ide_lba3),a
		ld a,l
		ld (ide_lba2),a
		exx			; load HL into bottom 2 bytes of lba num
		ld a,h
		ld (ide_lba1),a
		ld a,l
		ld (ide_lba0),a
		pop hl			; Sector num inc'd!
				
		djnz writeblklp
		
		ret

diskwriteerror:	push af
		ld bc,msghaltingdisk
		call PrintLine
		ld bc,msgdiskwerror
		call PrintString
		pop af
		call PrintHex8
		call NewLine
		halt
		
msgdiskwerror:	defm "Disk write: "
		defb 0
		
; *** RFS Support Routine: RFSBlockToLBA ***
; Expects: ide_lba0 - ide_lba2 filled with block num
; Returns: ide_lba0 - ide_lba3 filled with lba num
RFSBlockToLBA:	ld a,(ide_lba1)		; d <- 2nd byte of block num
		ld d,a
		ld a,(ide_lba0)		; e <- Low byte of block num
		ld e,a
		ld bc,16
		exx
		ld d,0
		ld a,(ide_lba2)		; e' <- Top byte of block num
		ld e,a
		ld bc,0
		exx
		
		call Mul32		; does H'L'HL = B'C'BC * D'E'DE
		exx
		ld a,h
		ld (ide_lba3),a		; (ide_lba3) <- 4th (top) byte of lba num
		ld a,l
		ld (ide_lba2),a		; (ide_lba2) <- 3rd byte of lba num
		exx
		ld a,h
		ld (ide_lba1),a		; (ide_lba1) <- 2nd byte of lba num
		ld a,l
		ld (ide_lba0),a		; (ide_lba0) <- 1st (bottom) byte of lba num
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;; IDE INTERNAL ROUTINES ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
; *** IDE Routine: ide_read_sector ***
; Read an LBA-addressed 256 byte sector (I ignore the high databyte!!) into address in hl
; Expects: ide_lba0 - ide_lba3 set to desired LBA address, ide_status bit 0 set for master (0) or slave (1); hl=target address
; Returns: carry flag = 1 if operation sucessful else A = IDE error flags (or if $00, operation timed out)
ide_read_sector:
		push hl
		call ide_setup_lba	;tell ide what drive/sector is required
		pop hl
		call ide_wait_busy_ready	;make sure drive is ready to proceed
		ret nc
		ld a,$20
		out (ide_register7),a	;write $20 "read sector" command to reg 7
ide_srex:	call ide_wait_busy_ready	;make sure drive is ready to proceed
		ret nc
		call ide_test_error	;ensure no error was reported
		ret nc
		call ide_wait_buffer	;wait for full buffer signal from drive
		ret nc

		ld b,0			;read 256 words (512 bytes per sector)
idebufrd:	in a,(ide_register0)	;get low byte of ide data word first	
		ld (hl),a
		inc hl
		djnz idebufrd
		
		scf			;carry set on return = operation ok
		ret
		
; *** IDE Routine: ide_write_sector ***
; Write from hl into an LBA-addressed 256 byte sector
; Expects: ide_lba0 - ide_lba3 set to desired LBA address, ide_status bit 0 set for master (0) or slave (1); hl=source address
; Returns: carry flag = 1 if operation sucessful else A = IDE error flags (or if $00, operation timed out)
ide_write_sector: 
		push hl
		call ide_setup_lba	;tell ide what drive/sector is required
		pop hl
		call ide_wait_busy_ready	;make sure drive is ready to proceed after lba req
		ret nc
		ld a,$30
		out (ide_register7),a	;write $30 "write sector" command to reg 7		
		call ide_wait_busy_ready
		ret nc
		call ide_test_error	;ensure no error was reported
		ret nc
		call ide_wait_buffer	;wait for buffer ready signal from drive
		ret nc
		
		ld b,0			;write 256 words (512 bytes per sector)
idebufwt:	ld a,(hl)			
		out (ide_register0),a	;send low byte to output entire word
		inc hl
		djnz idebufwt
		
		call ide_wait_busy_ready	;make sure drive is ready to proceed
		ret nc
		call ide_test_error	;ensure no error was reported
		ret 			;carry set on return = operation ok
		
; *** IDE Routine: Wait for drive to be ready ***
ide_wait_busy_ready:
		ld a,(ide_status)	;choose bit 1 or bit 2 to test for previous 
		and 1			;access depending on master or slave drive
		inc a			;selection
		sla a
		ld c,a
		
		ld de,0
ide_wbsy:	ld b,250		;ide times out after ~10 seconds if disk(s) not
		ld a,(ide_status)	;spun up (first time access). ~1 second otherwise
		and c
		jr z,ide_dlp
		
		ld b,50			;(~1 second)
ide_dlp:	djnz ide_dlp
		inc de
		ld a,d
		or e
		jr z,ide_timeout	; If de got to 0, we timed out :/
		
		in a,(ide_register7)	; get status reg in A
		
		; MARK/DBUG: SOMETIMES IT'S NOT ON THE GODDAM BUS AT THIS POINT; this is what causes the hard fail :/
		
		and 11000000b		;mask off busy and rdy bits
		xor 01000000b		;we want busy(7) to be 0 and rdy(6) to be 1
		jr nz,ide_wbsy
		ld a,(ide_status)	;from first time a disk is ready, timeout is reduced
		or c			;as spin-up is main reason for 10 second allowance
		ld (ide_status),a
		scf			;carry 1 = ok
		ret
		
ide_timeout:	xor a			;carry 0 = timed out
		ret
			
; *** IDE Routine: Wait for buffer ***
ide_wait_buffer:
		ld de,0
ide_wdrq:	ld b,250		;wait 10 seconds approx
ide_blp:	djnz ide_blp
		inc de
		ld a,d
		or e
		jr z,ide_timeout2
		in a,(ide_register7)
		bit 3,a			;to fill (or ready to fill)
		jr z,ide_wdrq
		scf			;carry 1 = ok
		ret
ide_timeout2:	xor a			;carry 0 = timed out
		ret

; *** IDE Routine: Test for error ***
ide_test_error: scf			;carry set = all OK
		in a,(ide_register7)	;get status in A
		bit 0,a			;test error bit
		ret z			
		bit 5,a
		jr nz,ide_err		;test write error bit
		in a,(ide_register1)	;read error report register
ide_err:	or a			;make carry flag zero = error!
		ret			;if a = 0, ide busy timed out
		
; *** IDE Routine: Setup for a 1-sector LBA transfer from the LBA address vars ***
ide_setup_lba:	ld a,1
		out (ide_register2),a	;set sector count to 1
		ld hl,ide_lba0
		ld a,(hl)
		out (ide_register3),a	;set lba 0:7
		inc hl
		ld a,(hl)
		out (ide_register4),a	;set lba 8:15
		inc hl
		ld a,(hl)
		out (ide_register5),a	;set lba 16:23
		inc hl
		ld a,(hl)
		and 00001111b		;lowest 4 bits used only
		or 11100000b		;to enable lba mode
		push hl			;set bit 4 for master or slave
		ld hl,(ide_status)
		bit 0,(hl)
		jr z,ide_mast
		or 16
ide_mast:	pop hl
		out (ide_register6),a	;set lba 24:27 + bits 5:7=111
		ret
				
		defm "Here lie the ROMTOP mountains ;)"
		defb 0

