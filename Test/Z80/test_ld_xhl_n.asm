#!/usr/local/bin/zasm -o original/

.org 100

	ld	hl,1000
	ld	(hl),1
	ld	(--hl),2
	ld	(hl++),3
	ld	(hl),a
	ld	(--hl),a
	ld	(hl++),a
	ld	a,(hl)
	ld	a,(--hl)
	ld	a,(hl++)

;	ld	(hl--),4
;	ld	(++hl),5
;	ld	(-hl),2
;	ld	(hl+),3
;	ld	(hl-),4
;	ld	(+hl),5

	ld	ix,1000
	ld	(ix),1
;	ld	(--ix),2
;	ld	(ix++),3
	ld	(ix),a
;	ld	(--ix),a
;	ld	(ix++),a
	ld	a,(ix)
;	ld	a,(--ix)
;	ld	a,(ix++)

	ld	bc,1100
	ld	(bc),a
	ld	(--bc),a
	ld	(bc++),a
	ld	a,(bc)
	ld	a,(--bc)
	ld	a,(bc++)

	ld	de,1100
	ld	(de),a
	ld	(--de),a
	ld	(de++),a
	ld	a,(de)
	ld	a,(--de)
	ld	a,(de++)

	ld	(hl++),bc
	ld	(--hl),bc
	ld	bc,(hl++)
	ld	bc,(--hl)

	ld	(hl++),de
	ld	(--hl),de
	ld	de,(hl++)
	ld	de,(--hl)



