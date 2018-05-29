#!/usr/local/bin/zasm -o original/
; ================================================================
;	Example file for target 'z80'
;	Emulator snapshot format for Sinclair computers
;	Copyright  (c)	Günter Woigk 1994 - 2015
;					mailto:kio@little-bat.de
; ================================================================


; space is filled with 0x00
;
; The first code segment must contain the z80 header data and must be properly set up.
; Header size may be 30 (v1, deprecated), 55 (v2.01) or 86 to 88 (v3 recommended).

; Ram segments have an additional argument: the pageID. see pageID description.
; Segment size must be 16k except for b&w models. see pageID description.
; All ram pages must be saved.
; Roms may be included if a non-standard rom is used.


#target z80


; ---------------------------------------------------
;		.z80 header: saved machine state
; ---------------------------------------------------

; header length:
z80v1len	equ	30
z80v2len    equ	55
z80v3len    equ	86
z80maxlen   equ z80v3len+3

; first segment must be the header segment:
;
#code HEADER, 0, z80v3len

	dw		0			; af
	dw		0			; bc
	dw		0			; hl
	dw		0			; pc_in_z80v1		0x0000 => header z80v2 or higher
	dw		stack_end	; sp

	db		$3f,0		; i, r
	db		0			; data		Bit 0   : Bit 7 of the R-register
						;			Bit 1-3 : Border colour
						;			Bit 4   : 1 = Basic SamRom switched in
						;			Bit 5   : 1 = Block of data is compressed
						;			Bit 6-7 : unused

	dw		0			; de

	dw		0			; bc'
	dw		0			; de'
	dw		0			; hl'
	dw		0			; af'
	dw		0			; iy
	dw		0			; ix

	db		0,0			; iff1,iff2
	db		1			; im		Bit 0-1 : Interrupt mode (0, 1 or 2)
						;			Bit 2   : 1 = Issue 2 emulation / 60 Hz model
						;			Bit 3   : 1 = Double interrupt frequency
						;			Bit 4-5 : 1 = High video synchronisation
						;				 	  3 = Low video synchronisation
						;					  0,2 = Normal
						;			Bit 6-7 : 0 = Cursor/Protek/AGF joystick
						;				 	  1 = Kempston joystick
						;					  2 = Sinclair 2 left joystick (or user defined, for z80v3)
						;					  3 = Sinclair 2 right joystick

; Z80 version 2.01:

	dw		z80v3len-z80v1len-2		; h2len = size of header extension: 23 for z80v2
	dw		code_start				; pc
	db		0		; model	 	0 = ZX Spectrum 48k
					;
					;			Value	Meaning in v2.01	Meaning in v3.0		ldiremu.bit7	im.bit2
					;			0		48k					48k					16k				issue2
					;			1		48k + If.1			48k + If.1			16k				issue2
					;			2		SamRam				SamRam				16k				issue2
					;			3		128k				48k + M.G.T.		16k				issue2
					;			4		128k + If.1			128k				+2				.
					;			5		-					128k + If.1			+2				.
					;			6		-					128k + M.G.T.		+2				.
					;			7,8		-					+3					+2A				.
					;			9		-					Pentagon 128k		.				.
					;			10		-					Scorpion 256k		.				.
					;			11		-					Didaktik-Kompakt	.				.
					;			12		-					+2					.				.
					;			13		-					+2A					.				.
					;			14		-					TC2048				.				.
					;			15		-					TC2068				.				.
					;	*zxsp*	76		-					TK85				.				.
					;	*zxsp*	77      -                   TS1000				.				60 Hz
					;	*zxsp*	78		-					TS1500				.				60 Hz
					;	*zxsp*	80		-					ZX80				.				60 Hz
					;	*zxsp*	81		-					ZX81				.				60 Hz
					;	*zxsp*	83		-					Jupiter ACE			.				60 Hz
					;	*zxsp*	84		-					Inves 48k			.				.
					;	*zxsp*	85		-					+128 Span.			.				.
					;	*zxsp*	86		-					Sam Coupé			.				.
					;	*zxsp*	87		-					+2 Spanish			.				.
					;	*zxsp*	88		-					+2 French			.				.
					;	*zxsp*	89		-					+3 Spanish			.				.
					;	*zxsp*	90		-					+2A Spanish			.				.
					;	*zxsp*	91		-					tk90x				.				.
					;	*zxsp*	92		-					tk95				.				.
					;			128		-					TS2068				.				.

	db		0		; port_7ffd or port_f4
					; If in SamRam mode, bitwise state of 74ls259.
					; For example, bit 6=1 after an OUT 31,13 (=2*6+1)
					; If in 128 mode, contains last OUT to 7ffd (paging control)
					; if timex ts2068: last out to port 244

	db		0		; if1paged or port_ff
					; !=0 means: interface1 rom is paged in
					; if timex ts2068: last out to port 255

	db		7		; rldiremu		Bit 0: 1 if R register emulation on
					;				Bit 1: 1 if LDIR emulation on
					;				Bit 2: AY sound in use, even on 48K machines
					;	*zxsp*		Bit 3: SPECTRA interface present, can only add to 48k models
					;	*zxsp*		Bit 5: if zxsp, then present a ZX Spectrum Plus
					;				Bit 6: (if bit 2 set) Fuller Audio Box emulation
					;				Bit 7: Modify hardware (see below)

	db		0		; port_fffd		Last OUT to fffd (soundchip register number)
	ds		16		; soundreg[16]	Contents of the sound chip registers

; Z80 version 3.0:

	db		0,0,0	; t_l,t_m,t_h		T state counter
					; 	The hi T state counter counts up modulo 4. Just after the ULA generates its
					;	50 Hz interrupt, it is 3, and is increased by one every 5 emulated milliseconds.
					; 	In these 1/200s intervals, the low T state counter counts down from 17471 to 0 (17726 in 128K modes),
					; 	which make a total of 69888 (70908) T states per frame.
	db		0		; spectator			Flag byte used by Spectator QL Specci emulator.
					; 	*zxsp*			ram size (in kB) for b&w models ID 76 to 83. 0 = default ram size (no memory expansion).
	db		0		; mgt_paged			0xFF if MGT Rom paged
	db		0		; multiface_paged	0xFF if Multiface Rom paged. Should always be 0.
	db		0,0		; ram0,ram1			0xFF if 0-8191 / 8192-16383 is ROM
	ds		10		; joy[10]			5* ascii word: keys for user defined joystick
	ds		10		; stick[10]			5* keyboard mappings corresponding to keys above
	db		0		; mgt_type			MGT type: 0=Disciple+Epson,1=Disciple+HP,16=Plus D
	db		0		; disciple_inhibit_button_status	0=out, 0xFF=in
	db		0		; disciple_inhibit_flag				0=rom pageable, 0xFF=not

; warajewo/xzx extension if PC=0 & h2len≥55:

;	db		0		; port_1ffd			last out to $1ffd (bank switching on +3)

; zxsp extension if PC=0 & h2len≥57:

;	db		0		; spectra_bits if SPECTRA present:
					;	*zxsp*			Bit 0: new colour modes enabled
					;	*zxsp*			Bit 1: RS232 enabled
					;	*zxsp*			Bit 2: Joystick enabled
					;	*zxsp*			Bit 3: IF1 rom hooks enabled
					;	*zxsp*			Bit 4: rom paged in
					;	*zxsp*			Bit 5: port 239: Comms out bit
					;	*zxsp*			Bit 6: port 239: CTS out bit
					;	*zxsp*			Bit 7: port 247: Data out bit

; 	db		0		; spectra_port_7fdf	if SPECTRA present:
					;	*zxsp*			last out to port 7FDF (colour mode register)





; ---------------------------------------------------
;		saved ram (and rom) pages
; ---------------------------------------------------

; The pages are numbered, depending on the hardware mode, in the following way:
;
;       PageID	48 mode				128 mode			SamRam mode			varying_pagesize
;       0		48K rom				rom (basic)			48K rom					-
;       1		Interface I, Disciple or Plus D rom, according to setting		-
;		2							rom (reset)			samram rom (basic)		-
;       3		-					page 0				samram rom (monitor)	1k
;       4		8000-bfff			page 1				Normal 8000-bfff		2k
;       5		c000-ffff			page 2				Normal c000-ffff		4k
;       6		-					page 3				Shadow 8000-bfff		8k
;       7		-					page 4				Shadow c000-ffff		16k
;       8		4000-7fff			page 5				4000-7fff				32k
;       9		-					page 6				-						64k
;       10		-					page 7				-						128k
;       11		Multiface rom		Multiface rom		-						-
;*zxsp*	12		SPECTRA rom			SPECTRA rom			SPECTRA rom				-
;*zxsp*	13		SPECTRA ram[0]		SPECTRA ram[0]		SPECTRA ram[0]			-
;*zxsp*	14		SPECTRA ram[1]		SPECTRA ram[1]		SPECTRA ram[1]			-
;
;   In 16k mode, only page 8 is saved.
;   In 48k mode, pages 4, 5 and 8 are saved.
;   In SamRam mode, pages 4 to 8 must be saved.
;   In 128 mode, all pages from 3 to 10 are saved.
;
;   The 128 has a memory map like:   Rom [switchable];   Ram 5;   Ram 2;   Ram [switchable, reset=0]
;
;	Some models (Russian) have more than 128k of ram. They can have ram page IDs from 3+0 up to 3+31 (up to 512k ram).
;
;	b&w models ID 76 to 83 (TK85, TS1000, TS1500, ZX80, ZX81, Jupiter ACE) have a 'varying ram size'.
;	their ram is saved in one block of 1k, 2k, 4k, 8k, 16k, 32k, 64k and 128k each as required to sum up to the actual ram size.
;	maximum ram size which can be saved this way is 255k: 1+2+4+8+16+32+64+128=255. (actually they have 64k at most.)
;	these ram pages may occur in any order. They are concatenated in sequence of occurance when loaded,
;	so e.g. for a 48k ram you have the choice to save the 16k or the 32k chunk first, whichever fits your memory layout better.

; page IDs:

; misc. roms visible at 0x0000:
; note: listed for completeness. roms are almost never saved in a snapshot!
pageID_48k_rom			equ	0
pageID_128k_basic_rom	equ	0
pageID_128k_boot_rom	equ	2
pageID_if1_rom			equ	1
pageID_disciple_rom		equ	1
pageID_plusD_rom		equ	1
pageID_multiface_rom	equ	11

pageID_spectra_rom		equ	12			; *zxsp*
pageID_spectra_ram0		equ	13			; *zxsp*
pageID_spectra_ram1		equ	14			; *zxsp*

pageID_samram_basic_rom			equ	2
pageID_samram_monitor_rom 		equ 3
pageID_samram_shadow_ram_0x8000	equ 6
pageID_samram_shadow_ram_0xC000	equ 7

; 48k model (not pageable) ram:
pageID_48k_ram_0x4000	equ	8
pageID_48k_ram_0x8000	equ	4
pageID_48k_ram_0xC000	equ	5

; 128k models with pageable ram:
pageID_128k_ram_page0	equ	3
pageID_128k_ram_page1	equ	4
pageID_128k_ram_page2	equ	5
pageID_128k_ram_page3	equ	6
pageID_128k_ram_page4	equ	7
pageID_128k_ram_page5	equ	8
pageID_128k_ram_page6	equ	9
pageID_128k_ram_page7	equ	10
pageID_128k_ram_0x4000	equ	pageID_128k_ram_page5
pageID_128k_ram_0x8000	equ	pageID_128k_ram_page2

; b&w models with varying ram size:
pageID_var_ram_1k		equ	3
pageID_var_ram_2k		equ	4
pageID_var_ram_4k		equ	5
pageID_var_ram_8k		equ	6
pageID_var_ram_16k		equ	7
pageID_var_ram_32k		equ	8
pageID_var_ram_64k		equ	9
pageID_var_ram_128k		equ	10



; ---------------------------------------------------
;		contended ram: video ram & rarely used code
;		pageID for 48k Specci (set in header.model above)
; ---------------------------------------------------

#code SLOW_RAM, 0x4000, 0x4000, pageID_48k_ram_0x4000

pixels_start:	defs 0x1800
attr_start:		defs 0x300

code_start:
	; define some rarely used machine code here
	; e.g. initialization code



; ---------------------------------------------------
;		fast ram: frequently used code,
;		variables and machine stack
;		must be segmented into 16k chunks for .z80 file
;		pageIDs for 48k Specci (set in header.model above)
; ---------------------------------------------------

#code RAM_0x8000, 0x8000, 0x4000, pageID_48k_ram_0x8000

stack_bot:	defs	0x100
stack_end:	equ		$


; define some variables here

; define some machine code here


#code RAM_0xC000, 0xC000, 0x4000, pageID_48k_ram_0xC000


; define some variables here

; define some machine code here









