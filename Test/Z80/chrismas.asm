#define	progStart	06900h
#define	LF	0Ah
#define	CR	0Dh
#define	BDOS	00005h
#define	BUFTOP	04000h
#define	CALSLT	0001Ch
#define	DMA	00080h
#define	ENASLT	00024h
#define	FCB	0005ch
#define	MNROM	0FCC1h
#define	MSXVER	0002dh
#define	RAMAD0	0F341h
#define	RAMAD1	0F342h
#define	RAMAD2	0F343h
#define	RAMAD3	0F344h
#define	RDSLT	0000Ch
#define	WRSLT	00014h

.org	progStart

	ld	H,080h
	call	MMM_Srch	; MMM detection

	ld	h,080h
	ld	a,(MMM_Slot)
	ld	(RAMAD2),a
	call	ENASLT		; Select MMM RAM at Bank 8000h~BFFFh

	jp	02103
	
; Musical Memory Mapper detection

MMM_Srch:
	ld	l,0FFh
	ld	b,16

MMM_Srch_Loop:
	push	hl

	ld	a,b
	dec	a
	and	3

	ld	hl,MNROM
	add	a,l
	ld	l,a

	ld	a,b
	dec	a
	or	(hl)

	pop    hl

	jp	m,Sec_SLT	; Jump if secondary Slot

	and	%00001111
	cp	4
	jr	nc,NextMMM_Srch ; Jump if 3-3 Slot

Sec_SLT:
	ld	c,a

	push	bc
	push	hl
	call	ENASLT		; Slot to search
	pop	hl
	pop	bc

	di

	ld	a,080h
	out	(03Ch),a	; Enable acces to registers by memory address mode

	ld	a,(hl)
	and	%00011111
	inc	a

	out	(0FFh),a

	or	%11000000
	cp	(hl)		; Same value?

	xor	a
	out	(03Ch),a
	out	(0FFh),a	; Restore initial mapper page in bank 0C000H~0FFFFH 

	ei

	ld	a,c		; A = Found Slot Number (F000SSPP)
	jr	z,MMM_Found

NextMMM_Srch:
	djnz	MMM_Srch_Loop	; Jump if MMM is not found

	ld	a,0FFh		; MMM not found value
	ret

MMM_Found:
	dec	b
	ret


