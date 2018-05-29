#!/usr/local/bin/zasm -o original/
; **************************************************************************
;  mouse.asm - Copyright 2003 Chris Cowley
;  			   converted for zasm by kio !
; 
;  BASIC mouse functionality for Kempston Mouse Interface
;
;  To use from Spectrum BASIC:-
;
;    10 GOSUB 9900: REM * Display Mouse Pointer *
;    20 REM *   x = mouseX pos (0 to 255)
;    30 REM *   y = mouseY pos (0 to 175)
;    40 REM * btn = mouse button (2 = left, 1 = right, 3 = both)
;  9900 LET btn=USR 60000
;  9910 LET x=PEEK 60827
;  9920 LET y=PEEK 60828
;  9930 RETURN


#target bin
#code	CODE, 60000, 1000

; Notes: PointerXY - start position of pointer
;        IX = points to 8x16 pixel sprite + mask

		LD	BC,(PointerXY)
      ; Get the initial background
		LD	(OldXY),BC
		CALL	store_backgr

		LD	BC,64479
		IN	A,(C)
		LD	(MouseX),A
		LD	BC,65503
		IN	A,(C)
		LD	(MouseY),A

draw_ptr_loop
		LD	IX,pointer
      ; Replace the old background
		HALT
		CALL	restore_bgr
		CALL	read_mouse
		LD	BC,(PointerXY)

      ; Store the screen background
		LD	(OldXY),BC
		CALL	store_backgr

		CALL	get_screen_offset       ; Position HL at the correct row
		CALL	get_column_offset       ; Position HL at the correct column -
                                          ; C is now set with the column offset
		LD	B,16                    ; Load B with number of rows
mask_sprite_loop
		PUSH	BC
		LD	D,(IX+16)
		ld	E,(IX+0)
		LD	A,C                     ; Load A with offset
		CP	0                       ; Compare offset with zero
		JR	Z,mask_sprite_skip_1	; If offset is zero jump to do the next row
 		LD	B,C                     ; Load B with C to use as a counter
mask_sprite_a_loop
		SRL	D
		SRL	E
		SET	7,D
		RES	7,E
		DJNZ	mask_sprite_a_loop	; Decrement B. If it's not zero, loop back for more shiftinG
mask_sprite_skip_1
		LD	A,(HL)
		AND	D
		OR	E
		LD	(HL),A
		LD	A,C                     ; Load A with offset
		CP	0                       ; Compare offset with zero
		JR	Z, mask_sprite_next     ; If offset is zero jump to do the next row
		LD	A,L
		AND	32
		LD	B,A
		INC	HL                      ; and move HL to the next screen byte
		LD	A,L
		AND	32
		CP	B
		JR	NZ,mask_sprite_dec
		LD	A,C
		XOR	%00000111               ; XOR offset to get left shift offset
		LD	B,A                     ; Load B with A to use as a counter
		INC	B
		LD	D,(IX+16)  
		LD	E,(IX+0)
mask_sprite_b_loop
		DEFB	$CB,$32			; SLS D  (undoc.opcode)
		DEFB	$CB,$33			; SLS E  (undoc.opcode)
		; SET	0,D
		RES	0,E 
		DJNZ	mask_sprite_b_loop	; Decrement B. If it's not zero, loop back for more shifting
		LD	A,(HL)
		AND	D
		OR	E
		LD	(HL),A
mask_sprite_dec
		DEC	HL                      ; Point HL back at the previous byte  
mask_sprite_next  
		POP	BC                      ; Get the original B and C back (we need the B counter)
next_spr_row
		INC	IX                      ; Shift IX to point at the next byte of graphic data
 		CALL	_get_next_row           ; Shift HL to point exactly one row down
		DJNZ	mask_sprite_loop        ; If B is not zero, decrement B and loop
		JR	draw_ptr_loop
		
;
; Pass row in register b
;
get_screen_offset
		PUSH	BC
		PUSH	DE                      ; Store de safely on the stack
		LD	C,B
		LD	B,0
               	SLA	C			; Multiply BC * 2
                RL      B               	; to get offset into the address table
		LD	HL,y_lookup
		ADD	HL,BC
 		LD	E,(HL)			; Load de with the two-byte number stored in the LUT
		INC	HL                      ; (2 byte numbers are stored least-significant byte first)
		LD	D,(HL)
		LD	L,E
		LD	H,D
		POP	DE                      ; Retrieve de from the stack
		POP	BC
		RET

;
; Pass column in register c
;
get_column_offset
		PUSH	DE			; Store de safely on the stack
		LD	A,C			; Load A with column coordinate
		SRL	A			; Divide A by eight
		SRL	A
		SRL	A
		LD	D,0
		LD	E,A			; Load DE with divided column value
		LD	A,C			; Load A with column coordinate
		AND	7			; AND A to get the byte offset
		LD	C,A			; Store this value back into C
		ADD	HL,DE			; Add the basic column to HL
		POP	DE			; Retrieve de from the stack 
		RET

; A quick hack to get the address of the next row down the screen
; Pass the current row address in HL, and it'll return into the same
; register pair
_get_next_row 
		INC	H
		LD	A,H
		AND	7
		RET	NZ
		LD	A,L
		ADD	A,32
		LD	L,A
		CCF
		SBC	A,A
		AND	$F8
		ADD	A,H
		LD	H,A
		RET

store_backgr
		PUSH	BC
		CALL	get_screen_offset
		CALL	get_column_offset
		LD	B,16
		LD	DE,scrbuf
store_next	LD	A,(HL)
		LD	(DE),A
		INC	HL
		INC	DE
		LD	A,(HL)
		LD	(DE),A
		DEC	HL
		INC	DE
		CALL	_get_next_row
		DJNZ	store_next
		POP	BC
		RET

restore_bgr
		PUSH	BC
		LD	BC,(OldXY)
		CALL	get_screen_offset
		CALL	get_column_offset
		LD	B,16
		LD	DE,scrbuf
restore_next	LD	A,(DE)
		LD	(HL),A
		INC	HL
		INC	DE
		LD	A,(DE)
		LD	(HL),A
		DEC	HL
		INC	DE
		CALL	_get_next_row
		DJNZ	restore_next
		POP	BC
		RET

read_mouse
		; Read the kempston mouse port and update PointerXY if the pointer has moved
		; Needs to preserve BC
		PUSH	BC
		LD	BC,64479          ; Kempston X
		LD	A,(MouseX)
		LD	D,A
		IN	A,(C)
		LD	(MouseX),A
		SUB	D
		; Mouse Left/Right
		LD	B,A
		CP	$80
		JR	NC,moving_left
		; Moving Right
		LD	A,(PointerXY)
		ADD	A,B
		LD	B,A               ; B is new X pos
		LD	A,(PointerXY)	; A is old X pos
		CP	B
		JR	Z,mouse_y
		JR	NC,right_edge
		LD	A,B
		LD	(PointerXY),A
		JR	mouse_y
right_edge
		LD	A,255
		LD	(PointerXY),A
		JR	mouse_y

moving_left	
		LD	A,(PointerXY)
		ADD	A,B
		LD	B,A               ; B is new X pos
		LD	A,(PointerXY)	; A is old X pos
		CP	B
		JR	C,left_edge
		LD	A,B
		LD	(PointerXY),A
		JR	mouse_y
left_edge
		XOR	A
		LD	(PointerXY),A

mouse_y	LD	BC,65503               ; Kempston Y
		LD	A,(MouseY)
		LD	D,A
		IN	A,(C)
		LD	(MouseY),A
		SUB	D
		LD	B,A
		LD	A,(PointerXY+1)
		SUB	B
		CP	175
		JR	NC,set_vert_edge
		LD	(PointerXY+1),A
		JR	mouse_btn

set_vert_edge
      ; work out if we are moving up or down
		LD	A,(PointerXY+1)         ; old pos
		CP	88
		JR	C,set_top_edge
      ; set_bottom_edge
		LD	A,175
		LD	(PointerXY+1),A
		JR	mouse_btn
set_top_edge
		XOR	A
		LD	(PointerXY+1),A
		
mouse_btn	LD	BC,64223
		IN	A,(C)
		CP	255
		JR	NZ,end_pointer
		POP	BC
		RET

end_pointer
		XOR	255
		POP	BC
		POP	BC
		LD	B,0
		LD	C,A
		RET
		
y_lookup
                DEFW    $4000,$4100,$4200,$4300,$4400,$4500,$4600,$4700
                DEFW    $4020,$4120,$4220,$4320,$4420,$4520,$4620,$4720
                DEFW    $4040,$4140,$4240,$4340,$4440,$4540,$4640,$4740
                DEFW    $4060,$4160,$4260,$4360,$4460,$4560,$4660,$4760
                DEFW    $4080,$4180,$4280,$4380,$4480,$4580,$4680,$4780
                DEFW    $40A0,$41A0,$42A0,$43A0,$44A0,$45A0,$46A0,$47A0
                DEFW    $40C0,$41C0,$42C0,$43C0,$44C0,$45C0,$46C0,$47C0
                DEFW    $40E0,$41E0,$42E0,$43E0,$44E0,$45E0,$46E0,$47E0
                
                DEFW    $4800,$4900,$4A00,$4B00,$4C00,$4D00,$4E00,$4F00
                DEFW    $4820,$4920,$4A20,$4B20,$4C20,$4D20,$4E20,$4F20
                DEFW    $4840,$4940,$4A40,$4B40,$4C40,$4D40,$4E40,$4F40
                DEFW    $4860,$4960,$4A60,$4B60,$4C60,$4D60,$4E60,$4F60
                DEFW    $4880,$4980,$4A80,$4B80,$4C80,$4D80,$4E80,$4F80
                DEFW    $48A0,$49A0,$4AA0,$4BA0,$4CA0,$4DA0,$4EA0,$4FA0
                DEFW    $48C0,$49C0,$4AC0,$4BC0,$4CC0,$4DC0,$4EC0,$4FC0
                DEFW    $48E0,$49E0,$4AE0,$4BE0,$4CE0,$4DE0,$4EE0,$4FE0
                
                DEFW    $5000,$5100,$5200,$5300,$5400,$5500,$5600,$5700
                DEFW    $5020,$5120,$5220,$5320,$5420,$5520,$5620,$5720
                DEFW    $5040,$5140,$5240,$5340,$5440,$5540,$5640,$5740
                DEFW    $5060,$5160,$5260,$5360,$5460,$5560,$5660,$5760
                DEFW    $5080,$5180,$5280,$5380,$5480,$5580,$5680,$5780
                DEFW    $50A0,$51A0,$52A0,$53A0,$54A0,$55A0,$56A0,$57A0
                DEFW    $50C0,$51C0,$52C0,$53C0,$54C0,$55C0,$56C0,$57C0
                DEFW    $50E0,$51E0,$52E0,$53E0,$54E0,$55E0,$56E0,$57E0

pointer	DEFB	%00000000
		DEFB	%01000000
		DEFB	%01100000
		DEFB	%01110000
		DEFB	%01111000
		DEFB	%01111100
		DEFB	%01111110
		DEFB	%01101000

		DEFB	%01001000
		DEFB	%00000100
		DEFB	%00000100
		DEFB	%00000010
		DEFB	%00000010
		DEFB	%00000000
		DEFB	%00000000
		DEFB	%00000000

		DEFB	%00111111
		DEFB	%00011111
		DEFB	%00001111
		DEFB	%00000111
		DEFB	%00000011
		DEFB	%00000001
		DEFB	%00000000
		DEFB	%00000000

		DEFB	%00000011
		DEFB	%00110001
		DEFB	%11110001
		DEFB	%11111000
		DEFB	%11111000
		DEFB	%11111100
		DEFB	%11111111
		DEFB	%11111111

scrbuf		DEFB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
scrbuf2		DEFB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
OldXY		DEFW	$FFFF
PointerXY	DEFW	$8080
MouseY		DEFB	0
MouseX		DEFB	0

#end
