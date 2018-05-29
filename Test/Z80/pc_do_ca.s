.org 0c000h

	LD B,0FAh
	LD HL, 0C100h
	LD A,0C3h
	OUT (0E3h),A


	LD HL, 0c100h
	LD B, 0FAh

odbior:
	IN A,(0E0h)
	LD (HL),A
	INC HL
	DJNZ odbior

;	RST 030h