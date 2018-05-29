;43K CP/M 2.2 BIOS for PC-6001
; Original by AKIKAWA, Hisashi(for PC-6001mkII/6601)
; Modified by tanam


BLS	equ	1024		;data block size
NRETRY	equ	8		;disk access retry

SYSPAR	equ	0000h		;CP/M system parameter area
TDRIVE	equ	0004h		;current user/drive
TPA	equ	0100h		;transient program area
DISK	equ	4274h		;disk access routine

CBASE	equ	09000h		;CCP
BDOS	equ	09806h		;BDOS
DSKPBF	equ	0af20h		;copy of 0fe70-0fe84 (disk parameter)
DSKSP	equ	0aff0h		;stack pointer in BASIC ROM call (READ,WRITE)
INTSP	equ	0b000h		;stack pointer in interrupt routine
RBUF	equ	0b000h		;disk read buffer
WBUF	equ	0b400h		;disk write buffer
VDISP	equ	0b800h		;virtual display address
DSKIX	equ	0bfd0h		;disk access work area used by ROM routine
VRAM	equ	0e200h		;VRAM plane1
ATTR	equ	0e000h		;VRAM plane2

;BIOS jump table
	org	0a600h
	jp	BOOT
JPWBT:	jp	WBOOT
	jp	CONST
	jp	CONIN
	jp	CONOUT
	jp	LIST
	jp	PUNCH
	jp	READER
	jp	HOME
	jp	SELDSK		
	jp	SETTRK
	jp	SETSEC
	jp	SETDMA
	jp	READ
	jp	WRITE
	jp	LISTST
	jp	SECTRN

;disk parameter header, drive0-3
DPH0:
	dw	0000h		;translate table for skew
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	DIRBUF		;buffer for directory
	dw	DPB1D		;disk parameter block
	dw	CSV0		;check sum vector
	dw	ALV0		;allocation vector

DPH1:
	dw	0000h		;translate table for skew
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	DIRBUF		;buffer for directory
	dw	DPB1D		;disk parameter block
	dw	CSV1		;check sum vector
	dw	ALV1		;allocation vector

DPH2:
	dw	0000h		;translate table for skew
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	DIRBUF		;buffer for directory
	dw	DPB1D		;disk parameter block
	dw	CSV2		;check sum vector
	dw	ALV2		;allocation vector

DPH3:
	dw	0000h		;translate table for skew
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	0		;scratch pad area used by BDOS
	dw	DIRBUF		;buffer for directory
	dw	DPB1D		;disk parameter block
	dw	CSV3		;check sum vector
	dw	ALV3		;allocation vector

;BIOS work area
WIDTH:	db	64		;virtual display size=80x25
HEIGHT:	db	24		;
	ds	1
VDAREA:	db	0		;display area number in virtual display

;disk parameter block
DPB1D:
SPT:	dw	32		;logical sector per track
				; 4096[bytes/track]/128[bytes/sector]
BSH:	db	3		;block shift factor, BLS=128*2^BSH
BLM:	db	7		;block length mask, 2^BSH-1
EXM:	db	0		;extent mask
				; (BLS*16)/(128*128)-1, for DSM<256
				; (BLS*8)/(128*128)-1, for DSM>=256
DSM:	dw	151		;disk size max,
				; 4096[bytes/track]*(40-OFF)[track]/BLS-1
DRM:	dw	63		;directory max BLS*ALbit(=2)/32-1
AL0:	db	11000000b	;allocation vector for directory, block0-7
AL1:	db	0		;allocation vector for directory, block8-15
CKS:	dw	16		;checksum size, (DRM+1)/4
OFF:	dw	2		;reserved track offset

;BIOS work area
DMA:	dw	0		;set by SETDMA
DRIVE:	db	0		;set by SELDSK
TRACK:	db	0		;set by SETTRK
SECTOR:	db	0		;set by SETSEC (logical sector)

RDRIVE:	db	0ffh		;drive in read buffer
RTRACK:	db	0ffh		;track in read buffer
RBLOCK:	db	0ffh		;block in read buffer
WDRIVE:	db	0ffh		;drive in write buffer
WTRACK:	db	0ffh		;track in write buffer
WBLOCK:	db	0ffh		;block in write buffer
PEND:	db	0		;write pending
CBUF:	db	0		;write mode
DSKSPB:	dw	0		;store stack pointer in BASIC ROM call

CSRX:	db	0		;cursor x position on virtual display
CSRY:	db	0		;cursor y positin on virtual display
CSRAD:	dw	VDISP		;cursor address on virtual display
CSRATT:	dw	ATTR		;cursor attribute address on real display
				; used and changed by only CONIN and INTGAM
CSROUT:	db	0		;cursor in/out of real display (non-zero=out)
				; used and changed by only CONIN and INTGAM
FCENABL:db	0ffh		;auto focus enable, non-zero=on

KEYBUF:	db	0		;key
CAPS:	db	0		;caps lock, non-zero=on
ESCMOD:	db	0		;waiting for ESC character
ESCEQY:	db	0		;
TIME:	db	0		;2ms timer

;BDOS work area
DIRBUF:	ds	128		;buffer for directory
CSV0:	ds	16		;check sum vector, (DRM+1)/4
ALV0:	ds	19		;allocation vector, (DSM+1)/8
CSV1:	ds	16		;check sum vector, (DRM+1)/4
ALV1:	ds	19		;allocation vector, (DSM+1)/8
CSV2:	ds	16		;check sum vector, (DRM+1)/4
ALV2:	ds	19		;allocation vector, (DSM+1)/8
CSV3:	ds	16		;check sum vector, (DRM+1)/4
ALV3:	ds	19		;allocation vector, (DSM+1)/8

INTTBL:
	dw	INTKEY		;fa02 normal key
	dw	INTKEY		;fa04 RS-232C
	dw	INTTIM		;fa06 2ms timer
	dw	INTKEY		;fa08 CMT read
	dw	EIRET		;fa0a
	dw	EIRET		;fa0c
	dw	EIRET		;fa0e CMT load stop
	dw	EIRET		;fa10 CMT save stop
	dw	EIRET		;fa12 CMT error
	dw	INTGRP		;fa14 GRAPH etc.
	dw	INTKEY		;fa16 reply to game key query

SYSTBL:
	jp	JPWBT
	db	81h		;IOBYTE LST=LPT,PUN=TTY,RDR=TTY,CON=CRT
	db	0		;user number and current drive
	jp	BDOS

GRPTBL1:
;GRAPH+		\   -   _   [   ]
	db	09h,17h,83h,84h,85h
GRPTBL2:
	db	"|","~","`","{","}"


;BIOS main program
BOOT:
	di
	ld	(SELDSK+2),a	;ndrive
	call	KEPDSKP
	ld	ix,DSKIX
	ld	sp,DSKSP	;stack must be in RAM
	ld	a,0afh
	ld	i,a
	ld	hl,INTTBL
	ld	d,a
	ld	e,02h
	ld	bc,11*2
	ldir
	ei

	xor	a
	ld	(TDRIVE),a
	out	(0c0h),a	;color attribute
	out	(0c1h),a	;320x200 graphic
	ld	a,2
	out	(0b0h),a	;relay=off,VRAM=c000,timer=on

	ld	hl,MSG
MSGLP:
	ld	c,(hl)
	ld	a,c
	or	a
	jr	z,GOCPM
	push	hl
	call	CONOUT
	pop	hl
	inc	hl
	jr	MSGLP

MSG:	db	1ah,"43K CP/M 2.2",00h

WBOOT:
	ld	ix,DSKIX
	ld	sp,DSKSP	;stack must be in RAM
	ld	a,11h
	out	(0f0h),a	;0000-7fff:ROM
	call	BCKDSKP
	call	LOADSYS
GOCPM:
	ld	a,0ddh
	out	(0f0h),a	;0000-7fff:RAM
	ld	(RDRIVE),a	;invalid drive
	ld	(WDRIVE),a	;invalid drive
	ld	a,(TDRIVE)	;current user/drive
	ld	hl,SYSTBL
	ld	de,SYSPAR
	ld	bc,8
	ldir
	and	0fh		;current drive
	ld	c,a
	call	SELDSK		;c no change
	ld	a,h
	or	l
	jr	nz,TDRVOK
	ld	c,a		;if hl=0 then c=0
TDRVOK:
	ld	sp,CBASE
	jp	CBASE		;c=drive


LOADSYS:
;CCP=9000-9805 (track0,sector2-track1,sector10)
;BDOS=9806-a5ff (track1,sector10-track2,sector7)
	xor	a
	ld	(ix+0),a	;drive number
	ld	(ix+27),a	;error count
	ld	bc,0002h	;track0,sector2
	ld	a,15		;15 sectors
	ld	de,CBASE
	or	a		;clear z- and c-flag for reading
	call	DISK
	jr	c,LOADSYS
LOADSYS2:
	xor	a
	ld	(ix+27),a	;error count
	ld	bc,0101h	;track1,sector1
	ld	a,7		;7 sectors
	ld	de,CBASE+0f00h
	or	a		;clear z- and c-flag for reading
	call	DISK
	jr	c,LOADSYS2
	ret

KEPDSKP:
	ld	hl,0fe70h
	ld	de,DSKPBF
	ld	bc,0015h
	ldir
	ret

BCKDSKP:
	ld	hl,DSKPBF
	ld	de,0fe70h
	ld	bc,0015h
	ldir
	ret

CONST:
	ld	a,(KEYBUF)
	or	a
	ret	z
	ld	a,0ffh
	ret

CONIN:
	call	CALCAD
;	ld	de,ATTR-VRAM+40*7
	ld	de,32*7
	add	hl,de
CONINLP:
	ld	a,(KEYBUF)
	or	a
	jr	nz,KEYIN
	ld	a,(TIME)
	ld	b,00h
	rlca
	jr	c,SETCSR
	ld	b,0fh
	ld	a,(CSRX)
	rrca
	jr	c,SETCSR
	ld	b,0f0h
SETCSR:
	ld	(hl),b
	jr	CONINLP
KEYIN:
	ld	b,a		;
	xor	a
	ld	(KEYBUF),a
	ld	(hl),a
	ld	a,b		;
	ret

CTL:
	ld	hl,CTLTBL
	add	a,a
	add	a,l
	ld	l,a
	jr	nc,NOINC1
	inc	h
NOINC1:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ex	de,hl
JPHL:
	jp	(hl)

CTLTBL:
	dw	CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL
	dw	CTLLFT,CTLRHT,CTLLF, CTLUP, CTLRHT,CTLCR, CTLNUL,CTLNUL
	dw	CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL,CTLNUL
	dw	CTLNUL,CTLNUL,CTLCLS,CTLESC,CTLRHT,CTLLFT,CTLHOM,CTLNUL

CONOUT:
	ld	a,(ESCMOD)
	or	a
	jp	nz,ESC
	ld	a,c
	and	7fh		;reset bit7
	cp	20h
	jr	c,CTL
	call	COPYCHR
	ret	nz

CTLLF:				;0ah(LF), line feed + carriage return
	ld	hl,CSRX
	ld	(hl),0
	inc	hl
	inc	(hl)		;CSRY
	ld	a,(HEIGHT)
	cp	(hl)
	jr	nz,SETAD
	dec	(hl)
	ld	de,VDISP
	ld	hl,VDISP+64
	ld	bc,64*(24-1)
	ldir
	ld	a,(WIDTH)
	ld	b,a
LOWEST:
	ld	a,20h		;" "
	ld	(de),a
	inc	de
	djnz	LOWEST

	ld	de,VRAM
	ld	hl,VRAM+64*4
	ld	bc,64*(24-1)*4
	ldir
	ex	de,hl
	ld	de,VRAM+64*(24-1)*4+1
	ld	bc,64*4-1
	ld	(hl),0
	ldir

SETAD:
;set (CSRAD)
	ld	bc,(CSRX)	;c=X,b=Y
	ld	a,b
	add	a,a		;Y*2
	add	a,a		;Y*4
;	add	a,b		;Y*5
	add	a,a		;Y*10
	ld	h,0
	ld	l,a
	add	hl,hl		;Y*20
	add	hl,hl		;Y*40
	add	hl,hl		;Y*80
	ld	b,VDISP/256
	add	hl,bc		;VDISP+Y*80+X
	ld	(CSRAD),hl
	ret

CTLCR:				;0dh(CR)
	xor	a
	ld	(CSRX),a
	jr	SETAD

CTLUP:				;0bh(VT)
	ld	hl,CSRY
	ld	a,(hl)
	or	a
	ret	z
	dec	(hl)
	jr	SETAD

CTLRHT:				;09h(HT),0ch(FF),1ch(FS)
	ld	hl,CSRX
	ld	bc,(WIDTH)
	ld	a,(hl)
	inc	a
	cp	c
	jr	c,RHTOK
	inc	hl		;CSRY
	ld	a,(hl)
	dec	b
	cp	b
	ret	nc
	inc	(hl)
	dec	hl		;CSRX
	xor	a
RHTOK:
	ld	(hl),a
	jr	SETAD
	
CTLLFT:				;08h(BS),1dh(GS)
	ld	hl,CSRX
	ld	a,(hl)
	or	a
	jr	nz,LFTOK
	inc	hl		;CSRY
	ld	a,(hl)
	or	a
	ret	z
	dec	(hl)
	dec	hl		;CSRX
	ld	a,(WIDTH)
LFTOK:
	dec	a
	ld	(hl),a
	jr	SETAD

CTLHOM:				;1eh(RS)
	ld	hl,0
	ld	(CSRX),hl
	jr	SETAD

CTLCLS:				;1ah(SUB)
	ld	hl,VDISP
	ld	de,VDISP+1
	ld	bc,64*24-1
	ld	(hl),20h	;" "
	ldir

	ld	hl,ATTR
	ld	de,ATTR+1
	ld	bc,200h
	ld	(hl),09ch
	ldir

	ld	hl,VRAM
	ld	de,VRAM+1
	ld	bc,1800h
	ld	(hl),0h
	ldir

	jr	CTLHOM		;?

CTLESC:				;1bh(ESC)
	ld	a,1
	ld	(ESCMOD),a
CTLNUL:				;00h(NUL),etc.
	ret

ESC:
	dec	a		;a=(ESCMOD)
	jr	z,ESC1
	dec	a
	jr	z,ESC2

ESC3:
	xor	a
	ld	(ESCMOD),a
	ld	a,c
	sub	20h
	ld	bc,(WIDTH)
	cp	c
	jr	c,XOK
	ld	a,c
	dec	a
XOK:
	ld	(CSRX),a
	ld	a,(ESCEQY)
	sub	20h
	cp	b
	jr	c,YOK
	ld	a,b
	dec	a
YOK:
	ld	(CSRY),a
	jp	SETAD

ESC2:
	ld	a,3
	ld	(ESCMOD),a
	ld	a,c
	ld	(ESCEQY),a
	ret

ESC1:
	ld	(ESCMOD),a	;a=0
	ld	a,c
	cp	3Dh		;"="
	jr	z,ESCEQ
	cp	54h		;"T"
	jr	z,ESCT
	cp	59h		;"Y"
	jr	z,ESCY
	cp	2Ah		;"*"
	jr	z,CTLCLS
	ret

ESCEQ:				;set cursor (ESC=YX)
	ld	a,2
	ld	(ESCMOD),a
	ret

ESCT:				;clear to line end
	ld	hl,(CSRX)
	push	hl
	call	ESCTLP
	pop	hl
	ld	(CSRX),hl
	jp	SETAD

ESCTLP:
	ld	a,20h		;" "
	call	COPYCHR
	jr	nz,ESCTLP
	ret

ESCY:				;clear to screen end
	ld	hl,(CSRX)
	push	hl
ESCYLP:
	call	ESCTLP
	ld	hl,CSRX
	ld	(hl),0
	inc	hl
	inc	(hl)
	ld	a,(hl)
	cp	25
	jr	c,ESCYLP
	pop	hl
	ld	(CSRX),hl
	ret

CALCAD:			; af,bc,hl
;calculate VRAM address
	ld	a,(CSRY)
	ld	b,a		;Y
	add	a,a		;Y*2
	add	a,a		;Y*4
;	add	a,b		;Y*5
	add	a,a		;Y*10
	ld	h,0
	ld	l,a
	add	hl,hl		;Y*20
	add	hl,hl		;Y*40
	add	hl,hl		;Y*80
	add	hl,hl		;Y*160
	add	hl,hl		;Y*320,c-flag=0
	ld	b,VRAM/256
	ld	a,(CSRX)
	rra			;X/2
	ld	c,a
	add	hl,bc		;VRAM+Y*320+X/2
	ret

COPYCHR:	;return z-flag=1 if cursor reach line end
	ld	hl,(CSRAD)
	cp	(hl)
	jr	z,INCCSR
	ld	(hl),a
	add	a,a
	ld	h,0
	ld	l,a
	add	hl,hl
	ld	de,FONT-80h
	add	hl,de
	ex	de,hl
	call	CALCAD		;de no change
	ld	b,4
	ld	a,(CSRX)
	rrca
	jr	c,XODD

XEVEN:
;x=0,2,4,...
	ld	c,(hl)		;VRAM
	ld	a,(de)		;font
	xor	c
	and	0f0h
	xor	c
	ld	(hl),a
	ld	a,32
	add	a,l
	ld	l,a
	jr	nc,NOINC3
	inc	h
NOINC3:
	ld	c,(hl)		;VRAM
	ld	a,(de)		;font
	rlca
	rlca
	rlca
	rlca
	xor	c
	and	0f0h
	xor	c
	ld	(hl),a
	ld	a,32
	add	a,l
	ld	l,a
	jr	nc,NOINC4
	inc	h
NOINC4:
	inc	de
	djnz	XEVEN
	jr	INCCSR

XODD:
;x=1,3,5,...
	ld	c,(hl)		;VRAM
	ld	a,(de)		;font
	rrca
	rrca
	rrca
	rrca
	xor	c
	and	0fh
	xor	c
	ld	(hl),a
	ld	a,32
	add	a,l
	ld	l,a
	jr	nc,NOINC5
	inc	h
NOINC5:
	ld	c,(hl)		;VRAM
	ld	a,(de)		;font
	xor	c
	and	0fh
	xor	c
	ld	(hl),a
	ld	a,32
	add	a,l
	ld	l,a
	jr	nc,NOINC6
	inc	h
NOINC6:
	inc	de
	djnz	XODD

INCCSR:
	ld	hl,(CSRAD)
	inc	hl
	ld	(CSRAD),hl
	ld	hl,CSRX
	inc	(hl)
	ld	a,(WIDTH)
	cp	(hl)
	ret

READER:
	ld	a,1ah		;ctrl-z
LIST:
PUNCH:
	ret

SELDSK:				;hl=DPH0+drive*16
	ld	a,c
	cp	1		;ndrive: written in BOOT
	ld	hl,0
	ret	nc
	ld	(DRIVE),a
	ld	hl,DPH0
	add	a,a		;drive*2
	add	a,a		;drive*4
	add	a,a		;drive*8
	add	a,a		;drive*16
	add	a,l
	ld	l,a
	ret	nc
	inc	h
	ret

HOME:
	ld	c,0
SETTRK:
	ld	a,c
	ld	(TRACK),a
	ret

SETSEC:
	ld	a,c
	ld	(SECTOR),a
	ret

SETDMA:
	ld	(DMA),bc
	ret

READ:
	call	BCKDSKP
	ld	(DSKSPB),sp
	ld	sp,DSKSP	;stack area must be in RAM
RCHECK:
	ld	hl,WDRIVE
;	ld	de,WBUF
	call	CHKBLK
	call	z,CPW2RA
	ld	hl,RDRIVE
	ld	de,RBUF
	call	CHKBLK		;de no change
	jr	nz,RDIFF
	ld	de,(DMA)
	ld	bc,128
	ldir
	call	CLDSKWK
	ld	sp,(DSKSPB)
	xor	a		;ok
	ret

RDIFF:
	ld	hl,RDRIVE
	call	REDDSK
	jr	RCHECK

REDDSK:
	call	SETBLK		;de no change
	ld	ix,DSKIX
	xor	a	
	ld	(ix+27),a	;error count
REDRTRY:
	call	SETPAR		;de no change
	ld	(ix+0),a	;drive number
	ld	a,11h
	out	(0f0h),a	;0000-7fff:ROM
	ld	a,4		;the number of sector
	or	a		;clear z- and c-flag for reading
	push	de
	call	DISK
	pop	de
	ld	a,0ddh
	out	(0f0h),a	;0000-7fff:RAM
	ret	nc		;no error
	ld	a,(ix+27)
	cp	NRETRY
	jr	nc,DSKERR
	jr	REDRTRY

WRITE:
	call	BCKDSKP
	ld	(DSKSPB),sp
	ld	sp,DSKSP	;stack area must be in RAM
	ld	a,c		;c=write condition
	ld	(CBUF),a
WCHECK:
	ld	hl,WDRIVE
	ld	de,WBUF
	call	CHKBLK		;de no change
	jr	nz,WDIFF
;write from DMA to buffer
	ex	de,hl
	ld	hl,(DMA)
	ld	bc,128
	ldir
	ld	a,1
	ld	(PEND),a
	ld	a,(CBUF)
	dec	a
	call	z,WRTIMM	;c=1 directory write (close)
WRTEND:
	ld	hl,RDRIVE
	ld	de,RBUF
	call	CHKBLK
	call	z,CPW2R
	call	CLDSKWK
	ld	sp,(DSKSPB)
	xor	a		;ok
	ret

DSKERR:
	call	CLDSKWK
	ld	sp,(DSKSPB)
	ld	a,1
	ret

WDIFF:
;not loaded
	ld	a,(PEND)
	or	a
	call	nz,WRTPND

	ld	hl,RDRIVE
;	ld	de,RBUF
	call	CHKBLK
	jr	z,CPR2W

	ld	hl,WDRIVE
	ld	de,WBUF
	call	REDDSK
	jr	WCHECK

CPR2W:
	ld	hl,RBUF
	ld	de,WBUF
	ld	bc,1024
	ldir
	ld	hl,WDRIVE
	call	SETBLK
	jr	WCHECK

WRTPND:
;write pending data
	ld	hl,WBLOCK
	ld	a,(hl)		;WBLOCK
	add	a,a
	add	a,a
	inc	a
	ld	c,a		;sector=WBLOCK*4+1
	dec	hl
	ld	b,(hl)		;WTRACK
	dec	hl
	ld	a,(hl)		;WDRIVE
	call	WRTDSK
	xor	a
	ld	(PEND),a
	ret

WRTIMM:
;write immediately
	call	SETPAR
	call	WRTDSK
	xor	a
	ld	(PEND),a
	ret

WRTDSK:
	ld	ix,DSKIX
	ld	(ix+0),a
	xor	a	
	ld	(ix+27),a	;error count
WRTRTRY:
	ld	a,11h
	out	(0f0h),a	;0000-7fff:ROM
	ld	de,WBUF		;address
	ld	a,4		;the number of sector
	scf			;set c-flag for writing
	call	DISK
	ld	a,0ddh
	out	(0f0h),a	;0000-7fff:RAM
	ret	nc		;no error
	ld	a,(ix+27)
	cp	NRETRY
	jr	nc,DSKERR
	jr	WRTRTRY	

CPW2R:
	ex	de,hl
	ld	hl,(DMA)
	ld	bc,128
	ldir
	ret

CPW2RA:
	ld	hl,WBUF
	ld	de,RBUF
	ld	bc,1024
	ldir
	ld	hl,RDRIVE
	call	SETBLK
	ret

CHKBLK:
;compare (DRIVE),(TRACK),(SECTOR) to read/write buffer
;IN: hl=RDRIVE/WDRIVE, de=RBUF/WBUF
;OUT:hl=buffer address, z-flag=1 (match) / z-flag=0 (not match)
	ld	a,(DRIVE)
	cp	(hl)
	ret	nz
	inc	hl
	ld	a,(TRACK)
	cp	(hl)		;RTRACK/WTRACK
	ret	nz
	inc	hl
	ld	a,(SECTOR)
	and	0f8h		;8sector/block
	rrca
	rrca
	rrca
	cp	(hl)		;RBLOCK/WBLOCK=0-3
	ret	nz
DSKBFAD:
	ld	a,(SECTOR)
	and	07h		;8sector/block
	rra			;c-flag=0
	ld	h,a
	ld	l,0
	rr	l		;hl=(a&7)*128
	add	hl,de
	xor	a		;set z-flag
	ret

SETBLK:
;set RDRIVE/WDRIVE etc.
	ld	a,(DRIVE)
	ld	(hl),a		;RDRIVE/WDRIVE
	inc	hl
	ld	a,(TRACK)
	ld	(hl),a		;RTRACK/WTRACK
	inc	hl
	ld	a,(SECTOR)
	and	0f8h		;8sector/block
	rrca
	rrca
	rrca
	ld	(hl),a		;RBLOCK/WBLOCK=0-3
	ret

SETPAR:
;OUT:a=drive,b=track,c=sector,(de=address)
	ld	hl,SECTOR
	ld	a,(hl)
	and	0f8h
	rrca
	ld	c,a
	inc	c		;physical sector
	dec	hl
	ld	b,(hl)		;track
	dec	hl
	ld	a,(hl)		;drive
	ret

CLDSKWK:		;clear 0fe64h,0fe70h-0fe84h
	xor	a
	ld	hl,0fe64h
	ld	b,21h
DSKWKLP:
	ld	(hl),a
	inc	hl
	djnz	DSKWKLP
	ret


LISTST:
	xor	a		;not ready
	ret

SECTRN:
	ld	h,b		;no skew factor
	ld	l,c
	ret

INTKEY:
	ld	(INTEND+2),sp	;CCP stack area is very limited !!!
	ld	sp,INTSP
	push	af
	call	IN90H
	cp	7fh
	jr	c,NODEL
	jp	nz,INTEND	;bit7 must be 0,parity
	ld	a,08h		;DEL:7fh->08h
NODEL:
	ld	(KEYBUF),a
	ld	a,(CAPS)
	or	a
	jr	z,INTEND
;caps lock
	ld	a,(KEYBUF)
	cp	41h		;"A"
	jr	c,INTEND
	cp	52h		;"Z"+1
	jr	c,UPLOW
	cp	61h		;"a"
	jr	c,INTEND
	cp	7Bh		;"z"+1
	jr	nc,INTEND
UPLOW:
	xor	20h		;A-Z <-> a-z
	ld	(KEYBUF),a
	jr	INTEND

INTGRP:
	ld	(INTEND+2),sp	;CCP stack area is very limited !!!
	ld	sp,INTSP
	push	af
	call	IN90H
	cp	0fbh
	jr	z,SWCAPS
	push	hl
	push	bc
	ld	hl,GRPTBL1
	ld	bc,GRPTBL2-GRPTBL1
	cpir
	jr	nz,NOMATCH
	ld	bc,GRPTBL2-GRPTBL1-1
	add	hl,bc
	ld	a,(hl)
	ld	(KEYBUF),a
NOMATCH:
	pop	bc
	pop	hl
	jr	INTEND

SWCAPS:				;switch caps lock on/off
	ld	a,(CAPS)
	cpl
	ld	(CAPS),a
	jr	INTEND

INTTIM:
	ld	(INTEND+2),sp	;CCP stack area is very limited !!!
	ld	sp,INTSP
	push	af
	ld	a,(TIME)
	inc	a
	ld	(TIME),a
INTEND:
	pop	af
	ld	sp,0000h
EIRET:
	ei
	ret

IN90H:
	in	a,(92h)
	cpl
	and	28h
	jr	nz,IN90H	;wait for ibf=1,intr=1
	in	a,(90h)
	ret

FONT:
	db	000h,000h,000h,000h	;sp
	db	044h,044h,040h,040h	;!
	db	0aah,000h,000h,000h	;"
	db	00ah,0eah,0eah,000h	;#
	db	04eh,0ceh,06eh,040h	;$
	db	008h,024h,082h,000h	;%
	db	04ah,0a4h,0a8h,060h	;&
	db	048h,000h,000h,000h	;'
	db	024h,044h,044h,020h	;(
	db	084h,044h,044h,080h	;)
	db	004h,0e4h,0e4h,000h	;*
	db	004h,04eh,044h,000h	;+
	db	000h,000h,044h,080h	;,
	db	000h,00eh,000h,000h	;-
	db	000h,000h,000h,040h	;.
	db	022h,044h,048h,080h	;/

	db	04ah,0aeh,0aah,040h	;0
	db	04ch,044h,044h,0e0h	;1
	db	04ah,0a2h,048h,0e0h	;2
	db	04ah,024h,02ah,040h	;3
	db	026h,0aah,0e2h,020h	;4
	db	0e8h,08ch,022h,0c0h	;5
	db	04ah,08ch,0aah,040h	;6
	db	0eah,022h,044h,040h	;7
	db	04ah,0a4h,0aah,040h	;8
	db	04ah,0a6h,02ah,040h	;9
	db	004h,040h,044h,000h	;:
	db	004h,040h,044h,080h	;;
	db	002h,048h,042h,000h	;<
	db	000h,0e0h,0e0h,000h	;=
	db	008h,042h,048h,000h	;>
	db	04ah,024h,040h,040h	;?

	db	04ah,022h,06ah,040h	;@
	db	04ah,0aeh,0aah,0a0h	;A
	db	0cah,0ach,0aah,0c0h	;B
	db	04ah,088h,08ah,040h	;C
	db	0cah,0aah,0aah,0c0h	;D
	db	0e8h,08eh,088h,0e0h	;E
	db	0e8h,08eh,088h,080h	;F
	db	068h,08eh,0aah,040h	;G
	db	0aah,0aeh,0aah,0a0h	;H
	db	0e4h,044h,044h,0e0h	;I
	db	0e4h,044h,044h,080h	;J
	db	0aah,0cch,0aah,0a0h	;K
	db	088h,088h,088h,0e0h	;L
	db	0aeh,0eeh,0aah,0a0h	;M
	db	0aeh,0eeh,0eeh,0a0h	;N
	db	04ah,0aah,0aah,040h	;O

	db	0cah,0ach,088h,080h	;P
	db	04ah,0aah,0a4h,020h	;Q
	db	0cah,0ach,0aah,0a0h	;R
	db	04ah,084h,02ah,040h	;S
	db	0e4h,044h,044h,040h	;T
	db	0aah,0aah,0aah,0e0h	;U
	db	0aah,0aah,0aah,040h	;V
	db	0aah,0eeh,0eeh,0a0h	;W
	db	0aah,0a4h,0aah,0a0h	;X
	db	0aah,0a4h,044h,040h	;Y
	db	0e2h,0a4h,0a8h,0e0h	;Z
	db	064h,044h,044h,060h	;[
	db	0aah,04eh,04eh,040h	;\
	db	0c4h,044h,044h,0c0h	;]
	db	04ah,000h,000h,000h	;^
	db	000h,000h,000h,0e0h	;_

	db	042h,000h,000h,000h	;`
	db	000h,0c2h,0eah,0e0h	;a
	db	088h,08ch,0aah,0c0h	;b
	db	000h,068h,088h,060h	;c
	db	022h,026h,0aah,060h	;d
	db	000h,04ah,0e8h,060h	;e
	db	024h,04eh,044h,040h	;f
	db	000h,06ah,062h,0c0h	;g
	db	088h,08ch,0aah,0a0h	;h
	db	040h,044h,044h,040h	;i
	db	020h,022h,02ah,040h	;j
	db	088h,0ach,0cah,0a0h	;k
	db	044h,044h,044h,060h	;l
	db	000h,0eeh,0eeh,0a0h	;m
	db	000h,0cah,0aah,0a0h	;n
	db	000h,04ah,0aah,040h	;o

	db	000h,0cah,0c8h,080h	;p
	db	000h,06ah,062h,020h	;q
	db	000h,0ach,088h,080h	;r
	db	000h,068h,042h,0c0h	;s
	db	004h,0e4h,044h,060h	;t
	db	000h,0aah,0aah,060h	;u
	db	000h,0aah,0aah,040h	;v
	db	000h,0aah,0eeh,0a0h	;w
	db	000h,0aah,04ah,0a0h	;x
	db	000h,0aah,062h,0c0h	;y
	db	000h,0e2h,048h,0e0h	;z
	db	024h,048h,044h,020h	;{
	db	044h,040h,044h,040h	;|
	db	084h,042h,044h,080h	;}
	db	000h,02eh,080h,000h	;~
	db	000h,000h,000h,000h	;none

BIOSEND:
	ds	0af00h-BIOSEND

