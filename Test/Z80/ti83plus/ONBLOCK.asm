.nolist
#include "ti83plus.inc"
.org userMem-2
.db $BB,$6D
.list


	bcall(_RclAns)
	bcall(_ConvOp1)
	ld a,e
	or a
	jr z,Install_Interrupt
	dec a
	ret nz
Uninstall_Interrupt:
	im 1
	ret
Install_Interrupt:

	di
	ld hl,$9900
	ld de,$9901
	ld bc,256
	ld (hl),$9a
	ldir


	ld	hl,interrupt_start			
	ld	de,$9a9a				
	ld	bc,interrupt_end-interrupt_start	
	ldir						
	ld	a,$99
	ld	i,a			
	im	2			;switch to mode 2
	ei				;enable interrupts
	ret




Interrupt_Start:
	ex af,af'
	exx
	in a,($03)
	and %11111110
	out ($03),a
	call $003A
	reti
Interrupt_End:
.end