			ORG 26112
			

LAST_K		EQU		23560
ATTR_P		EQU		23693	; permanent current colours
ATTR_T		EQU		23695	; temporary current colours
ERR_SP		EQU		23613
ERR_NR		EQU		23610
CHARS		EQU		23606
DF_CC		EQU		23684
ERR_NR		EQU		23610
BORDCR		EQU		23624

;L23808		DEFS	768
;L24576		DEFS	768
;L25344		DEFS	768

; The data that goes here is something to do with the static objects that appear in each room,
; e.g. the bone, fruit, any collectable goodies (toy parts, sugar, cocoa, etc.)

; These values represent the initial room locations of the respective objects, when you are
; carrying any of these objects, it's high bit gets set, and when you drop it, it's high bit
; gets reset.  As you move from room to room with an object, the game updates the objects room
; position by writing the room that you are in to these locations . These values are initially copied
; to the printer buffer at 23296 so that when you start a new game those values can be copied back into
; this area of storage to reset the object locations to their initial positions. These values only ever get
; copied to the printer buffer once on the very first run through the game so if you poke a new value into
; one of these locations after the first run of a game the object will still reset to the position that was 
; originally copied into the printer buffer as these values will not get copied into the printer buffer a second
; time around

; 41 bytes of pickup-able object locations stored here

L26112		DEFB		$52,$53,$53,$53,$5C,$5C,$5D,$5D		; the 8 toy parts in rooms 52h, 53h, etc

			DEFB		$18,$1A,$22,$23,$24,$24,$2D,$2E		; the 8 bottles of milk

			DEFB		$0C,$15,$16,$1F,$20,$29,$2A,$35		; the 8 boxes of cocoa

			DEFB		$56,$57,$58,$59,$61,$62,$63,$64		; the 8 bags of sugar
			DEFB		$5E									; basket for toy parts
			DEFB		$18									; basket for milk
			DEFB		$2A									; basket for cocoa
			DEFB		$6C									; basket for sugar
			DEFB		$0B  								; the bone
			DEFB		$60									; the girder
			DEFB		$6D									; the ladder
			DEFB		$5F									; the toy (bit 7 is set when starting game)
			DEFB		$30									; the egg! (bit 7 is set when starting game)




;our gaming char set goes in here - 736 bytes = 92 * 8 (92 chars)
L29622		DEFB		$01,$04				; 1 char high by 4 chars wide - LIFT sign (32 bytes)
L29624		DEFB		$00,$00,$00,$00		; 00000000000000000000000000000000
			DEFB		$40,$3E,$7E,$FE		; 01000000001111100111111011111110
			DEFB		$40,$08,$40,$10		; 01000000000010000100000000010000
			DEFB		$40,$08,$7C,$10		; 01000000000010000111110000010000
			DEFB		$40,$08,$40,$10		; 01000000000010000100000000010000
			DEFB		$40,$08,$40,$10		; 01000000000010000100000000010000
			DEFB		$7E,$3E,$40,$10		; 01111110001111100100000000010000
			DEFB		$00,$00,$00,$00		; 00000000000000000000000000000000		

			DEFB		01,05				; 1 char high by 5 chars wide - the girder (40 bytes)

			DEFB		$FF,$FF,$FF,$FF,$FF	; 1111111111111111111111111111111111111111

			DEFB		$C2,$42,$42,$42,$42	; 1100001001000010010000100100001001000010

			DEFB		$A4,$24,$24,$24,$24	; 1010010000100100001001000010010000100100

			DEFB		$98,$18,$18,$18,$18	; 1001100000011000000110000001100000011000

			DEFB		$98,$18,$18,$18,$10	; 1001100000011000000110000001100000010000

			DEFB		$A4,$24,$24,$24,$20	; 1010010000100100001001000010010000100000

			DEFB		$C2,$42,$42,$42,$40	; 1100001001000010010000100100001001000000

			DEFB		$FF,$FF,$FF,$FF,$80	; 1111111111111111111111111111111110000000
			
			DEFB		05,01				; ladder - 5 chars high by 1 char wide (40 bytes)
			DEFB		%00011000	; 9 - 18,18,F8,18,18,18,1F,18 - ladder, piece 1 of 5
			DEFB		%00011000
			DEFB		%11111000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011111
			DEFB		%00011000
			DEFB		%00011000	; 10 - 18,18,F8,18,18,18,1F,18 - ladder, piece 2 of 5
			DEFB		%00011000
			DEFB		%11111000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011111
			DEFB		%00011000
			DEFB		%00011000	; 11 - 18,18,F8,18,18,18,1F,18 - ladder, piece 3 of 5
			DEFB		%00011000
			DEFB		%11111000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011111
			DEFB		%00011000
			DEFB		%00011000	; 12 - 18,18,F8,18,18,18,1F,18 - ladder, piece 4 of 5
			DEFB		%00011000
			DEFB		%11111000
			DEFB		%00011000		
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011111
			DEFB		%00011000			
			DEFB		%00011000	; 13 - 18,18,F8,18,18,18,F8,18 - ladder, piece 5 of 5
			DEFB		%00011000
			DEFB		%11111000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011000
			DEFB		%00011111
			DEFB		%00011000
				
			DEFB		02,01				; bag of sugar - 2 chars high by 1 char wide	
			DEFB		%00000000	; 14 - 00,00,00,00,00,7E,FF,E7 - top half of a sugar bag ; 29742
			DEFB		%00000000
			DEFB		%00000000
			DEFB		%00000000
			DEFB		%00000000
			DEFB		%01111110
			DEFB		%11111111
			DEFB		%11100111
			DEFB		%11011011	; 15 - DB,DF,E7,FB,DB,E7,FF,7E - bottom half of a sugar bag ; 29750
			DEFB		%11011111
			DEFB		%11100111
			DEFB		%11111011
			DEFB		%11011011
			DEFB		%11100111
			DEFB		%11111111
			DEFB		%01111110
						
	 		DEFB		02,01		; milk bottle - 2 chars high by 1 char wide
			DEFB		%00111000	; 16 - 38,38,7C,DE,DE,DE,BE,BE - top half of a milk bottle - 29760
			DEFB		%00111000
			DEFB		%01111100
			DEFB		%11101110
			DEFB		%11101110
			DEFB		%11101110
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%10111110	; 17 - BE,BE,BE,BE,BE,BE,BE,5C - bottom half of a milk bottle - 29768
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%10111110
			DEFB		%01011100
			
			DEFB		01,02		; the bone - 1 char high by 2 chars wide
			DEFB		00,00		; 0000000000000000	; 18 - 00,00 - 29778
			DEFB		$60,06		; 0110000000000110	;      60,06
			DEFB		$f0,$0f		; 1111000000001111	;      F0,0F
			DEFB		$ff,$ff		; 1111111111111111	;      FF,FF
			DEFB		$ff,$ff		; 1111111111111111	; 19 - FF,FF - 29786
			DEFB		$f0,$0f		; 1111000000001111	;      F0,0F
			DEFB		$60,06		; 0110000000000110	;      60,06
			DEFB		00,00		; 0000000000000000	;      00,00
									
			DEFB		02,01		; cocoa packet - 2 chars high by 1 char wide

			DEFB		00,00,00,$FF,$7E,$FF,$FF,$FF

			DEFB		$E7,$DF,$DF,$E7,$FF,$FF,$FF,$FF 

			DEFB		01,01		; generator switch in the off position - 1 char high by 1 char wide

			DEFB		$FF,$FF,$7E,$3C,$18,$30,$60,$60 
						
			DEFB		01,01		; generator switch in the on position - 1 char high by 1 char wide

			DEFB		$FF,$FF,$7E,$3C,$18,$0C,$06,$06
						
			DEFB		01,01		; generator power indicator LED (red or green) - 1 char high by 1 char wide

			DEFB		$3C,$7E,$FF,$FF,$FF,$FF,$7E,$3C
						
			DEFB		01,02		; full sign on a vat - 1 char high by 2 chars wide
			DEFB		$FF,$FF
			DEFB		$FF,$FF
			DEFB		$95,$6D
			DEFB		$B5,$6D
			DEFB		$95,$6F
			DEFB		$B1,$25
			DEFB		$FF,$FF
			DEFB		$FF,$FF
						
			DEFB		01,01		; a key - 1 char high by 1 char wide (did they originally have a special use for this??)

			DEFB		$1C,$22,$1C,08,08,$0E,$0C,$0E			
				
			DEFB		01,01		; basket to put milk/sugar/cocoa/toy parts into - 1 char high by 1 char wide

			DEFB		$3C,$42,$42,$42,$FF,$FF,$7E,$3C
						

			DEFB		$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E ; - normal vertical pipe piece - 29880

			DEFB		00,$FF,00,$FF,$FF,$FF,$FF,00	; - normal horizontal pipe piece - 29888

 			DEFB		$78,$7B,$3C,$BD,$BD,$BD,$7B,$78	; - horizontal pipe connector piece - 29896

			DEFB		$5E,$42,$3C,$FF,$FF,$FF,$C3,$1C	; - vertical pipe connector piece - 29904

			DEFB		$7F,$7F,$7F,$3F,$3F,$1F,07,00 	; - 90 degree pipe bend - 29912

			DEFB		$FE,$FE,$FE,$FC,$FC,$F8,$E0,00 	; - 90 degree pipe bend - 29920

			DEFB		00,07,$1F,$3F,$3F,$7F,$7F,$7F 	; - 90 degree pipe bend - 29928

			DEFB		00,$E0,$F8,$FC,$FC,$FE,$FE,$FE	; - 90 degree pipe bend - 29936	

			DEFB		$7E,$C3,$3C,$FF,$FF,$FF,$FF,00	; - pipe T-junction - 29944	

			DEFB		00,$FF,00,$FF,$FF,$FF,$FF,$7E	; - pipe T-junction - 29952			

			DEFB		$5E,$9E,$5E,$DE,$DE,$DE,$DE,$5E	; - pipe T-junction - 29960			

			DEFB		$5E,$5F,$5E,$5F,$5F,$5F,$5F,$5E	; - pipe T-junction - 29968

			DEFB		$FB,$FB,$FB,00,$DF,$DF,$DF,00 	; - brick (used for room building) - 29976					

			DEFB		$FF,$42,$24,$18,$18,$24,$42,$FF ; - X platform (used for room building) - 29984		

			DEFB		$FF,$94,$22,$58,$05,$A8,$41,$FF	; - platform (used for room building) - 29992

			DEFB		$81,$C3,$A5,$99,$99,$A5,$C3,$81 ; - X platform (used for room building) - 30000		

			DEFB		$29,$92,$7C,$3C,$FE,$3C,$52,$91 ; - spiky death object - 30008			

			DEFB		$FF,$FF,$C3,$C3,$81,$81,00,00 ; - doesn't appear to be used - 30016			

			DEFB		$FF,$FF,$6A,$62,$42,$42,00,00 ; - icicles (used in milk bottle rooms) - 30024			

			DEFB		08,08,$1C,$14,$14,$1C,08,08 ; - chain link used for climbable ropes/chains - 30032				

			DEFB		$81,$81,$FF,$81,$81,$81,$FF,$81 ; - climbable ladder piece - 30040			

			DEFB		$5E,$5E,$5E,$5E,$5E,$5E,$5E,$5E ; - vertical pipe piece (used for slippery pipes) - 30048					

			DEFB		00,$FF,00,$FF,$F7,00,$FF,00 ; - train track piece - 30056						

			DEFB		00,00,00,00,00,00,00,00 ; empty block used to draw boxes/rectangles - 30064		

			DEFB		$FF,$7F,$3F,$1F,$0F,07,03,01 ; - used for ramps - 30072						

			DEFB		$FF,$FE,$FC,$F8,$F0,$E0,$C0,$80 ; - used for ramps - 30080					

			DEFB		$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; - solid block - 30088										

			DEFB		$3C,$7E,$FF,$FF,$FF,$FF,$7E,$3C ; - dot used for generator light? (maybe not used) - 30096												

			DEFB		$FF,$7E,$3C,$18,$30,$60,$60,00 ; - switch (not used??) - 30104												

			DEFB		$FF,$7E,$3C,$18,$0C,06,06,00 ; - switch (not used??) - 30112								

			DEFB		00,00,00,00,00,00,$12,$56  ;- grass used in start room - 30120
						

				DEFB	$FF,00,$FF,00,$FF,00,$FF,00 ; - platform (used for room building) - 30128					

				DEFB	$FF,$42,$24,$99,$C3,$A5,$99,$FF ; - platform used in cocoa area - 30136			

				DEFB	$FF,$99,$42,$24,$24,$42,$99,$FF ; - X platform used in rooms 61-65 - 30144				

				DEFB	$FF,$18,$24,$C3,$C3,$24,$18,$FF ; - platform used in rooms 4-6 and 13-16 - 30152	

				DEFB	$FF,$99,$5A,$24,$24,$5A,$99,$FF ; - platform used in rooms 7-10 and 17-20 - 30160				

				DEFB	$FF,$80,$A1,$87,$8E,$99,$9C,$B0 ; - upper left piece of 4 piece dial on egg maker/generator/etc - 30168			

				DEFB	$FF,01,$85,$61,$71,$99,$39,$8D ; - upper right of dial - 30176				

				DEFB	$B0,$99,$99,$8E,$87,$A1,$80,$FF ; - lower left of dial - 30184		

				DEFB	$8D,$19,$19,$31,$E1,$85,$01,$FF ; - lower right of dial - 30192			

				DEFB	$FF,$80,$A0,$80,$80,$80,$88,$88 ; - upper left of big (6 piece) switch on egg maker/mixer/etc - 30200			

				DEFB	$FF,$01,$05,$01,$01,$01,$11,$11 ; - upper right of big switch - 30208

				DEFB	$80,$80,$80,$80,$8E,$8C,$8C,$8F ; - middle left of big switch - 30216				

				DEFB	01,01,01,01,$71,$31,$31,$F1 ; - middle right of big switch - 30224					

				DEFB	$8F,$81,$81,$81,$81,$A0,$80,$FF ; - bottom left of big switch - 30232

				DEFB	$F1,$81,$81,$81,$81,05,01,$FF ; - bottom right of big switch - 30240			

				DEFB	00,$77,$55,$22,$22,00,00,00 ; - 2 little switches used on egg maker/mixer/etc - 30248					

				DEFB	00,00,00,00,00,$33,$33,00 ; - 2 indicator lights used on egg maker/mixer/etc - 30256			

				DEFB	$1C,$16,$14,$74,$14,$17,$14,$34 ; - top part of thermometer on boiler (4 pieces) - 30264			

				DEFB	$14,$16,$14,$74,$14,$17,$14,$14 ; - second part of thermometer - 30272			

				DEFB	$34,$14,$16,$14,$74,$14,$14,$17 ; - third part of thermometer - 30280				

				DEFB	$34,$14,$14,$36,$6F,$6F,$36,$1C ; - final part of thermometer - 30288			

				DEFB	$80,$C0,$E0,$F0,$F8,$FC,$FE,$FF ; - used for ramps - 30296			

				DEFB	01,03,07,$0F,$1F,$3F,$7F,$FF ; - used for ramps - 30304				

				DEFB	$10,$38,$10,$38,$38,$38,$10,$18 ; - no. of lives remaining graphic - 30312			

				DEFB	$60,$38,$1C,$1C,$0E,$0E,$0F,$0F ; - top half of moon - 30320				

				DEFB	$0F,$0F,$0F,$1E,$1E,$3C,$78,$E0 ; - bottom half of moon - 30328					

				DEFB	00,00,00,00,$10,00,00,00 ; - a twinkling star in the night sky! - 30336											

				DEFB	$18,$18,$3C,$FF,$FF,$7E,$3C,$FF ; - the thing that spits out bubbles! - 30344						

				DEFB	$3C,$42,$81,$81,$81,$5A,$3C,$7E ; - death object - 30352
						
						

L26891		LD A,2			; 26891
			LD (L41982),A ; load room
			CALL L31008 ; draw room
LBOP		XOR A			; Clear A
			LD (LAST_K),A	; Load 0 into last key pressed
			HALT			; HALT CPU until an interrupt is detected
			LD A,(LAST_K)	; Get last key pressed into A
			OR A			; Test if a key was actually pressed
			JP Z,LBOP
			CALL L41308	; restore rom char set
			LD BC,0
			RET			; return to basic

		
			
; This is quite a major routine of the game.  It draws the current room on entry to the room.

L31008		LD HL,L26112	; initial room locations of objects such as milk etc.
			LD (L41984),HL
			LD A,(L41982)	; which room we are currently in, in the room matrix
			ADD A,A			; A = A * 2, because there are 2 bytes per pointer
			LD HL,L43370	; HL now points to a list of pointers to room data
			ADD A,L			; L contains LSB of room data area, add current room to it
			LD L,A			; save it back again
			LD A,H			; H contains MSB of room data area
			ADC A,0			; if there was a carry from previous add instr then add it on now
			LD H,A			; save it back again
							; HL now points to a pointer to the start of the room
							; data for the room that we are currently in
			LD A,(HL)		; get first byte of pointer into A
			INC HL			; point to next byte
			LD H,(HL)		; get second byte of pointer into H
			LD L,A			; load first byte into L, HL now points to room data!!!!
			LD A,(HL)		; get first byte of room data (attr byte for colours)
			AND %00000111	; get border colour from bits 0, 1 and 2
			OUT (254),A		; bits 0-2 set border colour when output on port 254
			LD (BORDCR),A	; and update the system variable
			LD A,(HL)		; reload the byte into A
			AND %00111000	; mask off bits 3-5
			LD B,A			; and store it in B
			RRCA			; rotate right with carry through
			RRCA			; accumulator
			RRCA			; three times
			ADD A,B			;
			LD (ATTR_P),A	; set permanent colours
			LD A,(HL)		; reload current byte into A
			AND %00000111	; mask off bits 0-2
			LD B,A			; store it in B
			RLCA			; rotate left with carry through
			RLCA			; accumulator
			RLCA			; three times
			OR B			; OR accumulator with B
			PUSH HL			; save pointer to room data for later restoration
			
;			CALL L32203		; clear top 2 lines to reg A + other 22 lines to ATTR_P
			CALL L32225		; clear 6144 bytes to zero from 16384
			
			LD A,(ATTR_P)	; load permanent colours into A - contains zero on first run thru game
			LD HL,23808		; copy A from address 23808
			LD DE,23809		; for 768 times
			LD BC,767
			LD (HL),A
			LDIR			; do it
			
; Attributes byte is made up like this
; Bits 0-2 = ink colour
; Bits 3-5 = paper colour
; Bit 6 = brightness (0 = normal, 1 = bright)
; Bit 7 = flashing (0 = normal, 1 = flashing)

			LD HL,24576	; 24576 = 6000h - room data attrs go to here
			LD DE,24577		; so here we are clearing 768 bytes to 55 from address 24576
			LD BC,767
			LD (HL),55		; ink 7(white), paper 6(yellow)
			LDIR			; ld conts of HL into conts of DE, inc both dec BC, rep until BC=0
			
							; Set up the alt attr file so that initially we can walk through 
							; everything.
			LD HL,25344		; I think 768 bytes from 25344 in memory contain a copy of the 
			LD DE,25345		; screen attributes file.
			LD BC,767		; Here we are zeroing them.
			LD (HL),0		; L32652 contains a pointer to 25344 (6300h) on loading from tape
			LDIR
			
			CALL L32337		; print a message

			DEFB			22,0,5,1,7			;PRINT AT 0,5;INK 7; (the '1' indicates 'set the ink colour')





			DEFM			"SCORE  CARRYING  LIVES"
			DEFB			255
			
			CALL L41223		; display the current score
			CALL L41838		; display what you are carrying at the moment
			CALL L41657		; display the number of lives left
			
			POP HL			; restore pointer to room data (second byte within room data)
			INC HL			; point to next byte within room data
			LD (L32648),HL	; save pointer to room data

L31151		LD HL,(L32648)	; pointer to room data
			XOR A			; clear A
			LD (L41983),A	; store it
			LD A,(HL)		; get current byte we are pointing to into A

			CP $20			; if A < 20h then
			JP C,L31177		; call one of 10 dedicated graphics drawing routines via this call

			CP $2C			; if A is between 20h and 2Bh then
			JP C,L31271		; call the pipe drawing routine

			CP $60			; if A is >= 2Ch and < 60h
			JP C,L31205		; draw straight runs of UDGs (either horizontal or vertical) with this call

;			JP L30563		;  reset room back to 1 (this instruction should never get executed)
			
			
			
; special case routines here - we get here if the first byte to be drawn in a graphic sequence
; is less than $20 and call one of the 11 graphic routines which are held in a lookup table at L32650
L31177		LD DE,L32650	; the start of a table of pointers to graphics drawing routines
			ADD A,A			; A = A * 2
			ADD A,E			; add the offset into the table of pointers to graphic drawing routines
			LD E,A			; store A
			LD A,D			; no carry from 
			ADC A,0			; above
			LD D,A			; save A back into E
			
			LD A,(DE)		;
			LD Xl,A 		; undocumented Z80 opcode - load A into low byte of IX
			INC DE
			LD A,(DE)
			LD Xh,A		; undocumented Z80 opcode - load A into high byte of IX

			JP (IX)			; jump to the drawing routine
							; removing this causes the game not to draw things like
							; the dog house, the beware of the dog sign, the moon, the stars,
							; the pointy thing that hangs from the ceiling in the bone room,
							; the A&F Chocolate factory yellow entrance building, slides
							
						
						
						

; point to next byte of current graphic sequence	
; we get here when a 00h has been read for the next byte of the graphic sequence
; indicating that we've finished drawing the current room and should carry on with the rest of the game
L31196		NOP
			LD HL,(L32648)	; pointer to room data
			INC HL
			LD (L32648),HL	; pointer to room data
			RET
		
		


; Platforms/grass/ladders/chains/ropes etc. are drawn with this routine	
; we get here if the first byte to be drawn in a drawing sequence is between $2c and $60
; This routine is the main routine for drawing all rooms
; Six bytes make up a call to this routine
; e.g. 3A,00,13,06,83,01  <- this put up the invisible wall in start room (can't walk through van)
; 1st byte = what char to use from the char set
; 2nd byte = ink/paper colour
; 3rd byte = how many rows down the screen to start drawing
; 4th byte = how many cols across to start drawing
; 5th byte = how many chars to draw (if upper bit is set drawing is done vertical else it's horiz)
; 6th byte = attributes byte (0 means you can walk through it, 1 means you can't walk through it,
;                              2 means it is climbable, there may be others)

L31205		INC HL			; point to colour byte
			PUSH AF			; save AF
			LD A,(HL)		; get colour byte into A
			LD (ATTR_P),A	; set permanent colours
			INC HL			; point to y pos
			LD C,(HL)		; get y pos into C
			INC HL			; point to x pos
			LD B,(HL)		; get x pos into B
			INC HL			; point to how many chars to draw
			LD A,(HL)		; get it into A
			INC HL			; point to attr byte (solid/climbable/etc)
			LD D,(HL)		; get it into D
			INC HL			; point to next line of data
			PUSH DE			; save DE, D contains attr byte
			LD (L32648),HL	; save pointer to room data
			EX AF,AF'		; exchange AF with alt AF
			CALL L32308		; move print head, C = lines down, B = rows across
			EX AF,AF'		; exchange AF with alt AF
			LD B,A			; how many chars + which direction to draw
			POP AF			; A now contains attr byte
			POP DE			; D now contains which char to draw
			LD E,A			; E now contains attr byte
			CALL L32239		; DONE - update a pointer to copy of attr file ??
			BIT 7,B			; do we want to draw horizontal or vertical?
			PUSH AF			; if bit 7 of B is set then we want to draw vertical
			RES 7,B			; test status of bit 7 of reg B, save status regs and
			POP AF			; reset bit 7 of reg B then restore status regs
			JR NZ,L31256	; if Z flag is not set then take the jump and draw vertical
L31244		LD A,D			; get which char to draw into A
			CALL L32369		; draw the char to screen
			CALL L32250		; set attrs for horiz drawing - can we walk thru it?
			DJNZ L31244		; repeat until B=0
			JP L31151		; back to main game	
L31256		LD A,D			; get which char to draw into A
			CALL L32369		; draw the char to the screen
			CALL L32272		; set atttrs for vertical drawing - can we walk thru it?
			CALL L32151		; 
			DJNZ L31256		; repeat until B=0
			JP L31151		; back to main game	
			
		
		
; pipe drawing routine			
; we get here if the first byte to be drawn in a graphic sequence is between $20 and $2b 
; (in reality it will only ever be called with values of $20 or $21)
; example of input string :-
; 20,07,13,00,04,17,00 (UDG used for normal piece, colour, y-pos, x-pos, length/orientation, initial/terminating piece, attribute)
; first byte is the UDG that is used for 3 out of every 4 pieces in a length of pipe (20h = normal vertical piece, 21h = normal horizontal piece)
; pipes have a connector piece every 4th char and the second piece of any length of pipe is ALWAYS a connector piece
; they have to be a mininum length of 3 chars (intial piece + connector + terminating piece) any less than this and screen corruption occurs
; so for example if you draw a piece of pipe which is length 9 (5th byte of input string) you'll get :-
; initial piece/connector piece/normal/normal/normal/connector/normal/connector/terminating piece
; but if you draw a piece of which which is only 4 in length you'll get :-
; initial piece/connector piece/connector piece/terminating piece
; there is always a connector piece immediately before a terminating piece
; horizontal pipes are drawn left to right i.e. byte 4 is x-pos of first piece and pipe extends to the right of the screen from there
; vertical pipes are drawn top to bottom i.e. byte 3 is y=pos of first piece and pipe extends down the screen from there
; byte 6 controls the appearance of both the initial piece and the terminating piece of the pipe
; it's split into two 4-bit nibbles, with the upper 4 bits describing the initial piece and the lower 4 bits describing the terminating piece
; decimal values and their respective piece for those 4-bits are:-
; 0 = normal vertical piece
; 1 = normal horizontal piece
; 2 = horizontal connector piece
; 3 = vertical connector piece
; 4 = 90 degree bend (flow goes in from the top and out to the right)
; 5 = 90 degree bend (flow goes in from the top and out to the left)
; 6 = 90 degree bend (flow goes in from the bottom and out to the right)
; 7 = 90 degree bend (flow goes in from the bottom and out to the left)
; 8 = T-junction (flow goes in from top and out to left and right)
; 9 = T-junction (flow goes in from bottom and out to left and right)
; 10 = T-junction (flow goes in from left and out to top and bottom)
; 11 = T-junction (flow goes in from right and out to top and bottom)

L31271		INC HL				; point to first proper byte of input string (colour byte)
			PUSH AF				; A contains which routine we're drawing ($20 to $2c) (push 1)
			LD A,(HL)			; get the colour of the pipe
			LD (ATTR_P),A		; and set system variable
			INC HL				; point to y-pos
			LD C,(HL)			; and save it into C
			INC HL				; point to x-pos
			LD B,(HL)			; and save it into B
			INC HL				; point to length
			LD D,(HL)			; and save it in D
			INC HL				; point to initial/terminating piece
			LD E,(HL)			; and save it into E
			INC HL				; point to attribute byte (solid or not/climbable/etc)
			LD A,(HL)			; and save it into A
			PUSH AF				; push attribute byte (push 2)
			INC HL				; HL now points to next sequence to be drawn in this room
			PUSH DE				; push length and initial/terminating piece (push 3)
			POP IX				; and pop it into IX (pop 3)
			LD (L32648),HL		; store HL in pointer to room data
			CALL L32308			; move print head C lines down, B rows across
			PUSH IX				; push length and initial/terminating piece (push 4)
			POP BC				; and pop it into BC (pop 4)
			POP AF				; pop attribute byte back into A (pop 2)
			POP DE				; pop which routine we're drawing into DE (horizontal or vertical run) (pop 1)
			LD E,A				; save attribute byte into E
			CALL L32239			; DONE - update a pointer to copy of attr file ??
			BIT 7,B				; test bit 7 of length (if it's set then this length of pipe will be drawn vertical)
			PUSH AF				; save attribute byte
			RES 7,B				; clear bit 7 of length byte
			DEC B				; decrease length by 1 (for initial piece)
			DEC B				; decrease length by 1 (for terminating piece)
			POP AF				; restore A and flags
			JR NZ,L31371		; if we're drawing vertical then take this jump

; draw a horizontal pipe run
			LD A,C				; get initial/terminating piece byte into A
			AND 240				; mask off top 4 bits
			RRA					; 
			RRA					; shift them down to bottom 4 bits
			RRA					;
			RRA					; lower 4 bits of A now contain initial piece
			OR 32				; set bit 5
			LD C,1				; draw 1 initial piece
			JR L31338
L31330		LD A,D				; D should be 21h to indicate that normal pieces of this run will be horizontal pieces
			DEC C				; second piece of a pipe is always a connector piece
			JR NZ,L31338
			LD C,4				; 4 pieces to each section of pipe (3 normal and 1 connector piece)
			LD A,34				; horizontal connector piece is always the second piece and then every fourth piece
L31338		CALL L32369			; draw the char to screen
			CALL L32250			; set attribute byte for horizontal drawing (can we walk thru it?)
			DJNZ L31330			; repeat until B=0 (B contains length of pipe)
			LD A,34				; horizontal connector piece is always the last piece before the terminating piece
			CALL L32369			; draw the char to screen
			CALL L32250			; set attr byte for horiz drawing
			PUSH IX				; IX contains length + initial/terminating piece
			POP BC				; pop it into BC
			LD A,C				; get terminating piece into A
			AND 15				; mask off bottom 4-bits 
			OR 32				; set bit  5
			CALL L32369			; draw the char to screen
			CALL L32250			; set attr byte for horiz drawing
			JP L31151			; back to the rest of the room drawing function

; draw a vertical pipe run (much the same as the horizontal pipe run code above)					
L31371		LD A,C				; get initial/terminating piece into A
			AND 240				; mask off the upper 4-bits
			RRA					; rotate right 4 times
			RRA					; to get initial piece value into lower 4 bits of A
			RRA					;
			RRA					;
			OR 32				; set bit 5 
			LD C,1				; draw 1 initial piece
			JR L31392			;
L31384		LD A,D				; D should be 20h to indicate that normal pieces of this run will be vertical pieces
			DEC C				; second piece of a pipe is always a connector piece
			JR NZ,L31392
			LD C,4				; 4 pieces to a run (3 normal and 1 connector piece)
			LD A,35				; vertical connector piece is always the second piece and then every fourth piece				
L31392		CALL L32369			; draw char held in A to screen (print head is already in correct position)
			CALL L32272			; set attribute byte for vertical drawing (can we walk through it?)
			CALL L32151			; update a pointer to copy of attr file ??
			DJNZ L31384			; repeat until B=0 (B contains length of pipe)
			LD A,35				; vertical connector piece is always the last piece before the terminating piece
			CALL L32369			; draw char held in A to screen
			CALL L32272			; set attribute byte for vertical drawing (can we walk through it?)
			CALL L32151			; update a pointer to copy of attr file
			PUSH IX				; IX holds length + initial/terminating piece
			POP BC				; pop it into BC
			LD A,C				; get terminating piece into A
			AND 15				; mask off bottom 4 bits
			OR 32				; set bit 5
			CALL L32369			; draw terminating piece
			CALL L32272			; set attribute byte for vertical drawing (can we walk through it?)
			JP L31151			; back to the rest of the room drawing function
			
			



; The main room drawing graphics routines go from here to 32150
; They are called by an indirect jump through IX in the routine at L31177
; The table of pointers to these routines is stored at L32650
; The all seem to return by jumping back to L31151


; First graphics routine - this draws solid filled boxes/rectangles
; Seven bytes to make up a call to this routine
; e.g. 01,0F,0C,10,07,08,00 <- draws the big blue box that makes up the Beware Of The Dog sign in start room 
; 1st byte = call 1st graphics routine
; 2nd byte = (paper colour * 8) + ink colour
; 3rd byte = y-position of top left corner of box
; 4th byte = x-position of top left corner of box
; 5th byte = height of box
; 6th byte = width of box
; 7th byte = attribute byte (0 = walkthrough, 1 = solid, etc)

L31431		INC HL			; point to first proper byte
			LD A,(HL)		; get colour 
			LD (ATTR_P),A	; save in to the system variable
			INC HL			; point to next byte
			LD C,(HL)		; get y-pos into C
			INC HL			; point to next byte
			LD B,(HL)		; get x-pos into B
			INC HL			; point to next byte
			LD E,(HL)		; get height into E
			INC HL			; point to next byte
			LD D,(HL)		; get width into D
			INC HL			; point to next byte
			LD A,(HL)		; get attr byte into A
			PUSH AF			; save attr byte
			INC HL			; point to next byte
			LD (L32648),HL	; save pointer to room data, HL now points to next sequence in room description
			PUSH DE			; push width/height
			CALL L32308		; move print head to start position
			POP BC			; B now contains width of box, C now contains height of box
			CALL L32239		; point to alt attr file ??
			POP AF			; get attr byte back into A
L31460		PUSH AF			; push attr byte
			PUSH DE			; push width/height
			PUSH BC			; push width/height
			LD E,A			; get attr byte into E
L31464		LD A,55			; char 55 into A (solid block)
			CALL L32369		; print char 55
			CALL L32250		; something to do with attributes
			DJNZ L31464		; draw char 55 x B number of times
			POP BC			; pop width/height into BC
			POP DE			; pop width/height into DE
			INC DE			; increment DE
			LD (L32644),DE	; some kind of pointer into attr file
			CALL L32151
			CALL L32239		; point to alt attr file ??
			LD DE,(L32644)	; some kind of pointer into attr file
			POP AF			; get attr byte back into A
			DEC C			; do the next row of the box
			JP Z,L31151		; if C = 0 then back to the rest of the room drawing function
			JR L31460		; else go back and draw another row
			
			
; Second graphics routine
; This routine is used for writing any text that is in the room
; A line of text in the room data is described as follows
; 02, 0F, 0D, 11, "BEWARE", 80
; The first byte indicates that we are gonna call graphics routine 2 (this one) from the table of
; pointers to graphics routines at L32650
; The second byte will be the colour byte for the text (paper colour * 8) + ink colour
; The third and fourth bytes are the position (rows down, columns across) of the text on screen
; Next x number of bytes are the text itself
; The final byte is 80h to indicate end of text

L31498		INC HL
			LD A,1
			LD (L41983),A
			LD A,(HL)		; get attribute byte
			LD (ATTR_P),A	; set colours
			INC HL			; point to y pos
			LD C,(HL)		; get y pos of text
			INC HL			; point to x pos
			LD B,(HL)		; get x pos of text
			INC HL			; point to first char of text
			PUSH HL			; save HL
			CALL L32308		; move print head C lines down, B rows across
			POP HL			; restore HL
			CALL L41308		; restore original char set from ROM
L31521		LD A,(HL)		; get a char of the message
			INC HL			; point to next char
			CP 128			; if it's 80h then we're at the end of the message
			JR Z,L31532		; so jump to end of function
			CALL L32369		; else print the char
			JR L31521		; go back and get another char
L31532		LD (L32648),HL	; save current pointer into room data
			CALL L41317		; set up gaming char set
			JP L31151		; jump back to the rest of the room drawing function
			
			
			
; Third graphics routine
; draws a 5 section piece of pipe consisting of a normal horizontal piece at the supplied x/y position
; followed by a horizontal connector piece to the left of the x position supplied
; followed by a 90 degree bend pointing downwards
; followed by a vertical connector piece
; followed by a normal vertical piece
; takes a 5 byte string
; e.g. 03,15,04,06,00 (routine 3, ink/paper colour, y-pos, x-pos, attribute)
; the result will look like this :-
;		BCN <-- this N is where the routine starts drawing from
;		C
;		N
; where N = normal piece, C = connector and B = 90 degree bend

L31541		INC HL					; point at colour byte
			LD A,(HL)				; get it
			INC HL					; point at y-pos
			LD (ATTR_P),A			; store colour to system variable
			LD C,(HL)				; get y-pos into C
			INC HL					; point at x-pos
			LD B,(HL)				; get x-pos into B
			INC HL					; point at attribute
			LD E,(HL)				; get it into E
			INC HL					; point at next string in room description
			PUSH DE					; push attribute
			LD (L32648),HL			; save pointer to room data
			CALL L32308				; move print head C lines down, B rows across
			POP DE					; pop attribute back into DE
			CALL L32239				; point to alt attr file ??
			LD A,33					; normal horizontal pipe piece
			CALL L32369				; draw it
			CALL L32261				; set attributes for horizontal drawing
			LD HL,(DF_CC)			; get current print head position into HL
			DEC HL					; 
			DEC HL					; move backwards 1 position
			LD (DF_CC),HL			; store it back
			PUSH DE					; push attribute
			LD DE,(L32644)			; whereabouts in attr file
			LD E,L
			LD (L32644),DE
			POP DE					; pop attribute byte
			LD A,34					; horizontal connector piece
			CALL L32369				; draw it
			CALL L32261				; set attributes for it
			LD HL,(DF_CC)
			DEC HL
			DEC HL					; move backwards another position
			LD (DF_CC),HL
			PUSH DE
			LD DE,(L32644)
			LD E,L
			LD (L32644),DE
			POP DE
			LD A,38					; 90 degree bend
			CALL L32369				; draw it
			CALL L32272				; set attributes byte
			CALL L32151				; move down the screen by one character
			LD A,35					; vertical connector piece
			CALL L32369				; draw it
			CALL L32272				; set attributes byte
			CALL L32151				; move down the screen by one character
			LD A,32					; normal vertical pipe piece
			CALL L32369				; draw it
			CALL L32272				; set attributes byte
			JP L31151				; jump back to the rest of the room drawing function
	
	
	
; Fourth graphics routine		
; Five bytes make up a call to this graphics routine
; e.g. 04,16,00,19,00
; 1st byte = call fourth graphics routine
; 2nd byte = (paper colour * 8) + ink colour
; 3rd byte = how many lines down the screen
; 4th byte = how many rows across the screen
; 5th byte = attributes byte (0 = walkthrough, 1 = solid, 2 = climbable, 4 = ramp)
; draws a 5 section piece of pipe with a 90 degree bend in it, as above routine
L31651		INC HL
			LD A,(HL)
			LD (ATTR_P),A
			INC HL
			LD C,(HL)
			INC HL
			LD B,(HL)
			INC HL
			LD E,(HL)
			PUSH DE
			INC HL
			LD (L32648),HL	; save pointer to room data
			CALL L32308		; move print head C lines down, B rows across
			POP DE
			CALL L32261		; point to alt attr file ??
			LD A,33
			CALL L32369		; DONE
			CALL L32272		; DONE
			LD A,34
			CALL L32369		; DONE
			CALL L32272		; DONE
			LD A,39			; 90 degree bend
			CALL L32369		; DONE
			CALL L32272		; DONE
			CALL L32151		; DONE
			LD A,35
			CALL L32369		; DONE
			CALL L32272		; DONE
			CALL L32151		; DONE
			LD A,32
			CALL L32369		; DONE
			CALL L32272		; DONE
			JP L31151		; jump back to main game
			
			
			
; Fifth graphics routine
; draws a 5 section piece of pipe with a 90 degree bend in it, as above routine
L31723		INC HL
			LD A,(HL)
			LD (ATTR_P),A
			INC HL
			LD C,(HL)
			INC HL
			LD B,(HL)
			INC HL
			LD E,(HL)
			PUSH DE
			INC HL
			LD (L32648),HL
			CALL L32308		; move print head C lines down, B rows across
			POP DE
			CALL L32261		; ALL ROUTINES BELOW ARE DONE
			LD A,32
			CALL L32369
			CALL L32272
			CALL L32151
			LD A,35
			CALL L32369
			CALL L32272
			CALL L32151
			LD A,36			; 90 degree bend
			CALL L32369
			CALL L32272
			LD A,34
			CALL L32369
			CALL L32272
			LD A,33
			CALL L32369
			CALL L32272
			JP L31151		; jump back to main game
	
	
; Sixth graphics routine		
; draws a 5 section piece of pipe with a 90 degree bend in it, as above routine			
L31795		INC HL
			LD A,(HL)
			LD (ATTR_P),A
			INC HL
			LD C,(HL)
			INC HL
			LD B,(HL)
			INC HL
			LD E,(HL)
			PUSH DE
			INC HL
			LD (L32648),HL
			CALL L32308		; move print head C lines down, B rows across
			POP DE
			CALL L32261
			LD A,32
			CALL L32369
			CALL L32272
			CALL L32151
			LD A,35
			CALL L32369
			CALL L32272
			CALL L32151
			LD A,37			; 90 degree bend
			CALL L32369
			CALL L32261
			LD HL,(DF_CC)
			DEC HL
			DEC HL
			DEC HL
			LD (DF_CC),HL
			PUSH DE
			LD DE,(L32650)
			LD E,L
			LD (L32650),DE
			POP DE
			LD A,33
			CALL L32369
			CALL L32261
			LD A,34
			CALL L32369
			CALL L32261
			JP L31151		; jump back to main game
			
		
		
; Seventh graphics routine
; used when drawing the milk/sugar/cocoa vats and toy maker vat on top of the toy maker factory	
; six byte input string
; 07,0D,0D,09,06,0F - milk vat (seventh routine, colour, y-pos, x-pos, height, width)
L31887		INC HL					; point to colour byte		
			LD A,(HL)				; get it
			LD (ATTR_P),A			; store it system variable
			INC HL					; point to y-pos
			LD C,(HL)				; store it into C
			INC HL					; point to x-pos
			LD B,(HL)				; store it into B
			INC HL					; point to height
			LD E,(HL)				; store it into E
			INC HL					; point to width
			LD D,(HL)				; store it into D
			INC HL					; point to next input string
			LD (L32648),HL			; store it back to the pointer
			PUSH DE					; push height/width
			CALL L32308				; move print head to correct position in BC
			CALL L32239				;
			POP BC					; pop width/height back into BC
L31912		PUSH DE					; push width/height
			DEC B					; decrement width
			PUSH BC					; push width/height
			LD A,56					; left hand side angled edge
			CALL L32369				; draw it
			CALL L32250				; set attribute
			DEC B					; decrement width
			JR Z,L31965
			LD A,(ATTR_P)
			PUSH AF
			LD D,A
			AND 7
			RLCA
			RLCA
			RLCA
			LD E,A
			LD A,D
			AND 56
			RRCA
			RRCA
			RRCA
			OR E
			LD (ATTR_P),A
			LD E,128
L31949		LD A,55					; all zeroes UDG
			CALL L32369				; draw it
			CALL L32250				; set attribute
			LD A,58					; all ones UDG
			DJNZ L31949
			POP AF
			LD (ATTR_P),A
L31965		LD A,57					; right hand side angled edge
			CALL L32369				; draw it
			POP BC
			DEC B
			POP DE
			INC DE
			INC DE
			LD (L32644),DE
			CALL L32151				; move down the screen by one char position
			CALL L32239
			LD DE,(L32644)
			DEC C
			JP Z,L31151				; jump back to the rest of the room drawing function
			JR L31912
			
		
			
; Eighth graphics routine - for drawing ramps that go up from left to right
; Six bytes make up this routine
; e.g. 08,02,10,14,02,00
; 1st byte = call 8th graphics routine
; 2nd byte = (paper colour * 8) + ink colour
; 3rd byte = how many lines down screen
; 4th byte = how many rows across screen
; 5th byte = how long the ramp is
; 6th byte = attribute byte (0 = walkthrough, 1 = solid, 2 = climbable, 4 = ramp)

L31995		INC HL
			LD A,(HL)
			LD (ATTR_P),A
			INC HL
			LD C,(HL)
			INC HL
			LD B,(HL)
			INC HL
			LD A,(HL)
			INC HL
			LD E,(HL)
			PUSH DE
			INC HL
			LD (L32648),HL
			PUSH AF
			CALL L32308
			POP BC
			DEC B
			POP DE
			CALL L32261
L32025		LD A,85			; up ramp char
			CALL L32369
			CALL L32272
			LD A,57			; up ramp char
			CALL L32369
			CALL L32272		; set attribute byte
			CALL L32179
			DJNZ L32025
			LD A,85			; up ramp char
			CALL L32369
			CALL L32272
			JP L31151		; back to main game
			
		
		
; Ninth graphics routine - for drawing ramps that go down from left to right
; Six bytes make up this routine
; e.g. 09,02,10,14,02,00
; 1st byte = call 9th graphics routine
; 2nd byte = (paper colour * 8) + ink colour
; 3rd byte = how many lines down screen
; 4th byte = how many rows across screen
; 5th byte = how long the ramp is
; 6th byte = attribute byte (0 = walkthrough, 1 = solid, 2 = climbable, 4 = ramp)

L32055		INC HL
			LD A,(HL)
			LD (ATTR_P),A
			INC HL
			LD C,(HL)
			INC HL
			LD B,(HL)
			INC HL
			LD A,(HL)
			INC HL
			LD E,(HL)
			PUSH DE
			INC HL
			LD (L32648),HL
			PUSH AF
			CALL L32308
			POP BC
			POP DE
			CALL L32261
			DEC B
L32085		LD A,84			; down ramp char
			CALL L32369
			CALL L32272
			CALL L32151
			LD A,56			; down ramp char
			CALL L32369
			CALL L32272
			DJNZ L32085
			LD A,84			; down ramp char
			CALL L32369
			CALL L32272
			JP L31151		; back to main game
			
			
			
; Tenth and final graphics routine - draw a single UDG to screen for each call (e.g. a star, the two halves of the moon, a deadly item)
; Six bytes to each call of this routine
; e.g. 0A,07,59,05,05,00
; 1st byte = call tenth graphics routine
; 2nd byte = (paper colour * 8) + ink colour
; 3rd byte = which UDG to draw
; 4th byte = how many lines down the screen
; 5th byte = how many rows across the screen
; 6th byte = attributes byte (0 = walkthrough,1 = solid,2 = climbable,4 = ramp,128 = DEADLY TO TOUCH!!)

L32115		INC HL			; point to the colour
			LD A,(HL)		; get it
			LD (ATTR_P),A	; store in in the system variable
			INC HL			; point to the UDG byte
			LD A,(HL)		; get it into A
			INC HL			; point to y-pos
			LD C,(HL)		; get it into C
			INC HL			; point to x-pos
			LD B,(HL)		; get it into B
			INC HL			; point to attribute
			LD E,(HL)		; get it into E
			PUSH DE			; push attribute
			INC HL			; point to next input string in room description
			LD (L32648),HL	; and save it back to the pointer
			PUSH AF			; push UDG byte
			CALL L32308		; move print head C lines down, B rows across
			CALL L32239		; point to alt attr file ??
			POP AF			; pop UDG byte back into A
			POP DE			; pop attribute byte back into E
			CALL L32369		; print the char (A holds UDG to draw)
			CALL L32250		; set this particular chars' attributes
			JP L31151		; jump back to the rest of the room drawing function


; move down the screen by one char position	
L32151		LD HL,(L32644)	; pointer to attr file - where are we on screen
			LD A,31
			ADD A,L
			LD L,A
			LD A,H
			ADC A,0
			LD H,A
			LD (L32644),HL
			AND 3
			RLCA
			RLCA
			RLCA
			OR 64
			LD H,A
			LD (DF_CC),HL	; addr in display file of print position
			RET
	
L32179		LD HL,(L32650)
			LD A,L
			SUB 33
			LD L,A
			LD A,H
			SBC A,0
			LD H,A
			LD (L32650),HL
			AND 3
			RLCA
			RLCA
			RLCA
			OR 64
			LD H,A
			LD (DF_CC),HL
			RET
			
				
	

; clear top 2 lines of screen to whatever value was in reg A on entry then clear
; remaining 22 lines of screen to value that is held in ATTR_P
; copy from HL to DE, BC number of times

L32203		LD HL,22528		; clear top 2 lines (i.e. if A= 0 then paper 0 ink 0)
			LD DE,22529		; of screen attr
			LD BC,64		; 64 bytes = 2 * 32 byte lines
			LD (HL),A		; they will get cleared to whatever was in A at point of entry
			LDIR			; do it
			
			LD BC,703		; clear other 22 lines
			LD A,(ATTR_P)	; to whatever value is held in ATTR_P
			LD (HL),A
			LDIR			; do it
			
			RET
	
	
; Clear 6144 bytes to zero, from 16384, clears screen to zero but not attr area.
L32225		LD HL,16384
			LD DE,16385
			LD BC,6143
			LD (HL),0
			LDIR
			RET
	
	
L32239		LD HL,(L32644)	; some kind of pointer to whereabouts we in the attributes file
			LD A,H
			ADD A,11		; if HL=5800h (22528) on entry it will contains 6300h (25344) after add
			LD H,A
			LD (L32646),HL	; L32652 points to a copy of the current attr file which is held in
							; memory starting at 25344
			RET
	
	
; Set attribute byte for horizontal drawing (left to right) (can we walk through this item or not?)	
L32250		LD A,E
			LD HL,(L32646)	; the alt attr file
			OR (HL)			; OR the contents of HL with A
			LD (HL),A		; store the result back to the alt attr file
			INC HL			; point to next byte of alt attr file
			LD (L32646),HL	; store alt attr file back
			RET
	
; Set attribute byte for horizontal drawing (right to left) (can we walk through this item or not?)
L32261		LD A,E
			LD HL,(L32646)
			OR (HL)
			LD (HL),A
			DEC HL
			LD (L32646),HL
			RET
	

; Set attribute byte for vertical drawing (top to bottom) (can we walk through this item or not?)
L32272		LD A,E
			LD HL,(L32646)
			OR (HL)
			LD (HL),A
			LD A,L
			ADD A,32
			LD L,A
			LD A,H
			ADC A,0
			LD H,A
			LD (L32646),HL
			RET
		
; Set attribute byte for vertical drawing (bottom to top) (can we walk through this item or not?)			
L32290		LD A,E
			LD HL,(L32646)
			OR (HL)
			LD (HL),A
			LD A,L
			SUB 32
			LD L,A
			LD A,H
			SBC A,0
			LD H,A
			LD (L32646),HL
			RET

	
; move the print head to the correct row and column
; C = lines down, B = rows across
; on return from routine HL contains vram address of the x/y position passed to it
; and DE contains the attributes address of the x/y position passed to it
L32308		LD A,C			; get y-pos into A
			AND 24			; because there are 24 rows to the screen display
			LD H,A			; store result in H
			SET 6,H			; set bit 6 in H
			RRCA			; rotate A once to right, bit 0 copied into bit 7 and carry flag
			RRCA			; another rotate
			RRCA			; another rotate
			OR %10001000	; (88,  because 88 * 256 = 22528, start of attr area)
			LD D,A			; save
			LD A,C			; get y-pos into A
			AND 7
			RRCA
			RRCA
			RRCA
			ADD A,B			; B contains how many rows across screen we want to print at
			LD L,A			; 
			LD (DF_CC),HL	; next char to be drawn will go at DF_CC position
			LD E,A
			LD (L32644),DE	; our attribute storage area
			RET
			
			
; print a message to the screen

L32337		CALL L41308		; DONE - restore original char set from ROM
L32340		POP HL			; pop the message off the stack into HL
			LD A,(HL)		; get next char of message into A
			INC HL			; point to next char
			PUSH HL			; save message pointer
			CP 255			; are we at the end of the message yet?
			JR Z,L32353		; if so then leave
			CALL L32357		; else print the next char to screen
			JR L32340		; continue until the message is finished
L32353		CALL L41317		; DONE - set up our new char set
			RET				; from whence we came  :)
			
			
L32357		CP 22			; was the char a 22 (AT command)?
			EXX				; exchange regs with alt regs
			JP Z,L32445		; if it was a 22 then jump to here and move the print head
			JP C,L32460		; if it was less than 22 it will have been a paper or ink command
							; so jump to L32460
			EXX				; exchange regs with alt regs
			JR L32401		; it was just a normal char so print it
			
; print a single char/UDG to the screen, print head is already in the correct position for printing
L32369		PUSH HL
			PUSH AF
			LD A,(L41983)
			OR A
			JR Z,L32381
			POP AF
			SET 7,A
			PUSH AF
L32381		LD HL,(L32644)	; whereabouts in attributes file
			LD A,H
			ADD A,5
			LD H,A
			LD A,(ATTR_P)	; permanent colours
			LD (HL),A
			LD A,H
			ADD A,3
			LD H,A
			POP AF
			LD (HL),A
			AND 127
			POP HL	
			
; this routine will display a single char on the screen at the current DF_CC position
L32401		EXX					; exchange normal regs with alt regs
			LD DE,(CHARS)		; get (256 - address of char set) into DE
			LD L,A				; A contains ascii value of key to be displayed
			LD H,0
			ADD HL,HL			; get to correct byte within the charset
			ADD HL,HL			; HL = HL * 8 (because there are 8 bytes to each char)
			ADD HL,HL			; 
			ADD HL,DE			; add that to start of charset and you are now in position
			EX DE,HL			; DE now contains 1st byte of position of char in char set
			LD HL,(DF_CC)		; address in display file of print position into HL
			INC HL				; increment HL, next char will be printed 1 char to right of last
			LD (DF_CC),HL		; save it back to memory
			DEC HL				; decrement HL
			LD B,8				; repeat following 8 times
L32424		LD A,(DE)			; get next byte of char we are wanting to display to screen
			LD (HL),A			; write the byte to screen
			INC DE				; point to next byte of char
			INC H				; move down 1 line in display file
			DJNZ L32424			; repeat 8 times (8 bytes per char)
			LD DE,(L32644)		; whereabouts in attributes area
			LD A,(ATTR_P)		; permanent current colours
			LD (DE),A			; set attributes on screen
			INC DE				; point to next byte in attributes file
			LD (L32644),DE		; save pointer
			EXX					; exchange regs with alt regs
			RET					; to whence we came
			
			
; if the message contains a PRINT AT command then we will jump here to move the print head
; to the correct place on screen

L32445		INC SP				; the last CALL instr will have stacked the old PC
			INC SP				; we need to twice inc the SP to get to the message
			POP HL				; get the message pointer into HL
			LD C,(HL)			; how many lines down the screen into C
			INC HL				; point to next byte in message
			LD B,(HL)			; how many rows across the screen into B
			INC HL				; point to next byte in message
			PUSH HL				; restack the message
			DEC SP				; fix the SP so that the CALL instr returns to
			DEC SP				; the correct address
			CALL L32308			; move the print head
			EXX					; exchange regs with alt regs
			RET					; continue with rest of message
			
			
; if the message has some colour (ink) commands in it then we will jump here
; set up the appropriate colours

L32460		INC SP				; fix the SP for the last CALL instr
			INC SP				; remember to unfix it later
			POP HL				; get message into HL
			LD A,(HL)			; get colour into A
			INC HL				; point to next byte in message
			PUSH HL				; restack message
			DEC SP				; I remembered to 
			DEC SP				; fix the SP :)
			LD (ATTR_P),A		; set the ink colour
			EXX					; exchange regs with alt regs
			RET					; from whence we came
	
L32644		DEFW		$5800	; (22528 - start of attributes area)
L32646		DEFW		$6300	; (25344 ??) - maybe a copy of the attr area in memory
L32648		DEFS		2		; storage for a pointer to the current room data when drawing a room
	
; A table of pointers to room drawing routines
L32650		DEFW		L31196 		; we've read a zero byte, that means we're finished drawing this room
L32652		DEFW		L31431 		; draw a box/rectangle
L32654		DEFW		L31498 		; write some text to the screen 
L32656		DEFW		L31541 		; 90 degree-shaped pipe section
L32658		DEFW		L31651 		; 90 degree-shaped pipe section
L32660		DEFW		L31723		; 90 degree-shaped pipe section
L32662		DEFW		L31795		; 90 degree-shaped pipe section
L32664		DEFW		L31887		; milk/sugar/cocoa/toy vat drawing routine
L32666		DEFW		L31995		; ramp drawing routine - up from left to right
L32668		DEFW		L32055		; ramp drawing routine - down from left to right
L32670		DEFW		L32115		; draw a single UDG to the screen
	


; This routine is called from the display score routine
; On entry reg A contains this rooms points value as taken from the room matrix
; BC contains 7, something to do with the fact that rooms only have a value that is
; a multiple of 100 so we don't need to draw digits 8 and 9, maybe anyhow (indexing starts at 0)

L41149		LD HL,L42053	; score is stored here
			ADD HL,BC		; move to Nth digit within the score (7 on entry but can change)
			ADD A,(HL)		; add this rooms value, or add the overflow to next higher digit
			CP 10			; if the addition results in A being <=9 then carry flag will be set
							; if addition causes A to be > 9 then carry flag will be cleared
			JR C,L41173		; jump if carry flag is set
			SUB 10			; else subtract 10 from A
			LD (HL),A		; store A back into the score
			DEC BC			; point to next digit up in score
			LD A,B			; constantly decrementing BC will eventually make it FFFFh so FFh will
							; be loaded into A
			OR A			; will set Z=1 if A=0, when FFh is loaded, Z flag will be set to 0
							; this is our safeguard against recursively calling ourselves forever
			LD A,1			; doesn't change any flags
			PUSH HL			; save the score on the stack
			CALL Z,L41149	; recursive procedure call, we call ourselves if Z=1
			
			POP HL			; this POP will counteract the push from above, as many times as the
							; recursive procedure calls itself
			INC BC			; point to next digit to be displayed
			LD A,(HL)		; score will cycle back to zero if you have a score of 9999999900 and
							; enter a 100 points value room that you haven't been in before
			
; move to correct position in speccy VRAM and call the display char routine

L41173		LD (HL),A		; store new score byte
			ADD A,48		; get ascii value of new score byte
			LD HL,16416		; move to 0 across, 1 line down, in VRAM
			LD B,0			; 
			ADD HL,BC		; move to correct position for this digit within VRAM
			CALL L41186		; display the digit
			RET
			
; actually display a digit of the score on the screen

L41186		PUSH HL		; HL contains address in display file of where we want to start drawing
			LD L,A		; A contains the ascii value of the number we want to draw on screen
			LD H,0		; clear H
			ADD HL,HL	; * 2
			ADD HL,HL	; * 4
			ADD HL,HL	; * 8    (HL = HL * 8)
			LD DE,15360 ; start of char set in ROM
			ADD HL,DE	; get to correct offset for ascii value of number we want to draw
			POP DE		; DE now contains addr in display file of where we want to start drawing
			LD B,8		; 8 bytes for the char
L41200		LD A,(HL)	; get the next byte of the char
			LD (DE),A	; write it to Speccy VRAM
			INC HL		; point to next byte of char
			INC D		; write to next line down in VRAM
			DJNZ L41200	; do it 8 times
			RET
			
		
		
		
; display score to screen, 10 digits to score, only display leading zeroes if score is less than 10000

L41223		CALL L32337		; print a message to screen

			DEFB			22,1,0,1,7	; PRINT AT 1,0;INK 7;
			DEFB			255			; end of message
			
			CALL L41308		; restore original ROM char set
			LD HL,L42053	; score is stored here (10 digits, 1 byte per digit)
			LD B,5			; when a new game starts and score = 0 print 5 spaces before the zeros
							; when the score is >= 5 digits long we dont print the leading zeros
			LD C,10			; 10 possible digits for the score
L41242		LD A,(HL)		; get first digit
			INC HL			; point to next one
			OR A			; is this digit a zero
			JP NZ,L41258	; if it isn't then take the jump
			LD A,32			; else print a space
			CALL L32401		; print it
			DEC C			; 10 digits in all
			DJNZ L41242		; do first 5 digits
L41256		LD A,(HL)		; get next digit
			INC HL			; point to next one
L41258		ADD A,48		; convert it into it's ASCII equivalent
			CALL L32401		; print it
			DEC C			; decrement the counter
			JP NZ,L41256	; jump if counter hasn't reached zero

			CALL L41317		; set up new char set
			LD (CHARS),HL	; HL now points to L42083
			LD A,(L41982)	; which room we are in at the moment
			LD HL,L41856	; room matrix starts here
			ADD A,L			; get to current room within matrix
			LD L,A			; re-store it
			LD A,H			; if the add above caused a
			ADC A,0			; carry then add that aswell
			LD H,A			; re-store it, HL now points to the room we are in, in the matrix
			LD A,(HL)		; gets it's value (score wise)
			BIT 7,A			; have we already visited this room?
			RET NZ			; if so then return (we only get points for the 1st time a room is entered)
			LD C,A			; save it's score value in reg C
			SET 7,(HL)		; set the bit 7 in the room matrix to indicate that we've been here
			LD A,(L41977)	; L41997 = 1
			LD B,A
			PUSH BC
L41296		LD A,C			; reg A now contains this rooms score
			LD BC,7			; rooms only ever have a 100 point multiple value of between 100 and 1000, 
							; so we only need to modify the 7th digit of the score 
							; (or 6th if overflow occurs)
			CALL L41149		; draw the score to screen
			POP BC
			DJNZ L41296
			RET				; (41317)
							
					
; Restore original char set from ROM				
L41308		PUSH HL			; save HL
			LD HL,15360		; 
			LD (CHARS),HL	;
			POP HL			; restore HL
			RET
			
; Set up our gaming char set
L41317		PUSH HL			; save HL
			LD HL,L29624	; point to our new char set
			LD (CHARS),HL	;
			POP HL			; restore HL
			RET				;					(41335)
				
		
; Display the number of lives left

L41657		LD BC,$1601		; 22 rows across, 1 line down
			CALL L32308		; move the print head C lines down, B rows across
			LD A,7			; ink 7
			LD (ATTR_P),A	; set the ink colour
			LD A,(L41978)	; no. of lives into A
			CP 9			; are we a cat?? have we got 9 lives??
			JR C,L41697		; if we've got more than 9 lives
			LD A,9			; then just display 9
L41697		LD B,A			; otherwise display them all
L41678		LD A,86			; lives UDG is at 86 ascii
			PUSH BC
			CALL L32401		; display a single char at DF_CC, A holds char to be displayed
			POP BC
			DJNZ L41678		; display all lives remaining
			LD A,55			; display char 55 now (empty block)
			CALL L32401		; display a single char at DF_CC
			RET
			
		

; This prints what you are carrying at the moment
L41838		CALL L32337		; print a message

			DEFB			22,1,12,1,7			; PRINT AT 1,12;INK 7;

L41846		DEFM			"NOTHING "
			DEFB			255			; end of message
			
			RET



; This is the room matrix.  It contains 120 rooms.  When the upper bit is set in the room
; byte it means the room has been visited.  The value of the byte is how many points * 100
; you get for visiting that particular room.  So there are 10 rooms where you get 1000 points
; just for entering them.
; the room score is also multiplied by the number of eggs you've delivered
; so if you've delivered 4 eggs you'd get 400 points for entering the dog room (4 * 1 * 100)
; If we take indexing at zero then we'll call byte at L41856 room 0 (room 0 is not used)
; 41877 (index 1) = start room (where you get thrown out of the back of the truck)
;                   you have to leave this room (either to dog room or bone room)
;					then re-enter it for it to register on the matrix
; 41878 (index 2) = dog room (where you have to give dog the bone)
; 41879 (index 3) = entrance to A & F chocolate factory (1000 points for entering this room)
; 41880 (index 4) = spider room (2 spiders going up and down on chains, 3 death objects on floor)
; 41887 (index 11) = bone room (the room where the bone starts)

L41856		DEFB			0						; don't know what this byte represents yet



			DEFB			0,1,10,1,3,2,1,3,2,3	; start room/dog room/A & F factory entrance/etc


			DEFB			1,4,2,2,2,1,1,2,4,3


			DEFB			2,1,3,2,2,2,7,6,5,5


			DEFB			3,1,10,1,1,3,8,4,3,1


			DEFB			2,1,6,2,2,4,10,2,1,4


			DEFB			10,3,2,1,3,5,3,2,1,4


			DEFB			2,2,3,2,3,5,3,2,1,10


			DEFB			1,1,1,1,1,1,1,1,1,2


			DEFB			1,5,6,2,2,4,3,3,2,1


			DEFB			4,4,3,2,2,1,3,2,1,3


			DEFB			5,6,3,2,2,1,2,3,1,10


			DEFB			10,3,5,10,10,2,2,2,3,10	; final room is 'A MONSTERS WORK IS NEVER DONE'

					
L41977		DEFB			1			; no. of eggs delivered so far + 1 (i.e. nth current egg that we're working with)
L41978		DEFB			5			; no. of lives
L41982		DEFB			0			; which room we are in, in the matrix	
L41983		DEFB			0			; what kind of object are we drawing at the moment
L41984		DEFS			2			; gets the value of 26112 (initial room locations of moveable objects)



L42053		DEFB			0,0,0,0,0,0,0,0,0,0			; the current playing score (1 byte per digit, 10 digits)


; Here lies a list of pointers to room data (121 * 2 bytes per pointer = 242 bytes from here)
L43370		DEFW			0			; not sure why this is here???
			
			DEFW			L52905		; (CEA9) - 1   - Start room
			DEFW			L53925 ; L53029		; (CF25) - 2   - Dog house
;			DEFW			L53134		; (CF8E) - 3   - Entrance to A & F Chocolate factory
;			DEFW			L53331		; (D053) - 4   - Spider room (2 spiders on chains)
;			DEFW			L53417		; (D0A9) - 5   - Maze room (ladders + 2 birds)
;			DEFW			L48873		; (BEE9) - 6   - Big ramp + pair of boots and cyan bird
;			DEFW			L51731		; (CA13) - 7   - red room 1/8
;			DEFW			L52187		; (CBDB) - 8   - red room 2/8
;			DEFW			L52321		; (CC61) - 9   - red room 3/8
;			DEFW			L52419		; (CCC3) - 10  - red room 4/8
			
;			DEFW			L53227		; (CFEB) - 11  - bone room
;			DEFW			L50722		; (C622) - 12  - cocoa area 1/10 (1 box of cocoa here)
;			DEFW			L49787		; (C27B) - 13  - 5 ropes, 2 ramps, green tortoise
;			DEFW			L49173		; (C015) - 14  - 3 ropes, 1 ladder, yellow spider + yellow boots
;			DEFW			L49075		; (BFB3) - 15  - 4 ropes, 1 ladder, red rat
;			DEFW			L48953		; (BF39) - 16  - 2 ropes, 3 ladders, 1 ramp, yellow hand, pink elephant, bubble
;			DEFW			L51895		; (CAB7) - 17  - red room 5/8
;			DEFW			L52053		; (CB55) - 18  - red room 6/8
;			DEFW			L52541		; (CD3D) - 19  - red room 7/8
;			DEFW			L52693		; (CDD5) - 20  - red room 8/8
			
;			DEFW			L50802		; (C672) - 21  - cocoa area 2/10 (1 box of cocoa here)
;			DEFW			L50600		; (C5A8) - 22  - cocoa area 3/10 (1 box of cocoa here)
;			DEFW			L49903		; (C2EF) - 23  - milk area 1/12
;			DEFW			L49259		; (C06B) - 24  - milk area 2/12 (1 bottle of milk here)
;			DEFW			L44864		; (AF40) - 25  - milk area 3/12
;			DEFW			L44980		; (AFB4) - 26  - milk area 4/12 (1 bottle of milk here)
;			DEFW			L57179		; (DF5B) - 27  - egg maker area 1/9
;			DEFW			L56233		; (DBA9) - 28  - egg maker area 2/9 (2 long red chains)
;			DEFW			L56102		; (DB26) - 29  - egg maker area 3/9 (2 bubbles)
;			DEFW			L53617		; (D171) - 30  - toxic cloud area 1/4
			
;			DEFW			L50918		; (C6E6) - 31  - cocoa area 4/10 (1 box of cocoa here)
;			DEFW			L50502		; (C546) - 32  - cocoa area 5/10 (1 box of cocoa here)
;			DEFW			L50007		; (C357) - 33  - milk area 5/12 (milk vat room)
;			DEFW			L49369		; (C0D9) - 34  - milk area 6/12 (1 bottle of milk here)
;			DEFW			L44736		; (AEC0) - 35  - milk area 7/12 (1 bottle of milk here)
;			DEFW			L45138		; (B052) - 36  - milk area 8/12 (2 bottles of milk here)
;			DEFW			L57042		; (DED2) - 37  - egg maker area 4/9
;			DEFW			L56310		; (DBF6) - 38  - egg maker area 5/9 (mixer room)
;			DEFW			L55973		; (DAA5) - 39  - egg maker area 6/9 (creeping green hand + spring)
;			DEFW			L53661		; (D19D) - 40  - toxic cloud area 2/4
			
;			DEFW			L51016		; (C748) - 41  - cocoa area 6/10 (1 box of cocoa here)
;			DEFW			L50356		; (C4B4) - 42  - cocoa area 7/10 (1 box of cocoa here)
;			DEFW			L50115		; (C3C3) - 43  - milk area 9/12
;			DEFW			L49455		; (C12F) - 44  - milk area 10/12
;			DEFW			L49561		; (C199) - 45  - milk area 11/12 (1 bottle of milk here)
;			DEFW			L49671		; (C207) - 46  - milk area 12/12 (1 bottle of milk here)
;			DEFW			L56892		; (DE3C) - 47  - egg maker area 7/9 (two green creeping hands)
;			DEFW			L56695		; (DD77) - 48  - egg maker area 8/9 (egg maker room)
;			DEFW			L55829		; (DA15) - 49  - egg maker area 9/9 (Sinclair C5)
;			DEFW			L53753		; (D1F9) - 50  - toxic cloud area 3/4
			
;			DEFW			L51048		; (C768) - 51  - cocoa area 8/10 (cocoa vat room)
;			DEFW			L51109		; (C7A5) - 52  - cocoa area 9/10
;			DEFW			L50247		; (C447) - 53  - cocoa area 10/10 (1 box of cocoa here)
;			DEFW			L55527		; (D8E7) - 54  - black room 1/7
;			DEFW			L55399		; (D867) - 55  - black room 2/7 (lift that takes you up to the milk area)
;			DEFW			L54941		; (D69D) - 56  - blue room 1/8 (Sinclair C5)
;			DEFW			L54829		; (D62D) - 57  - blue room 2/8 (cyan mole/magenta elephant/magenta bat)
;			DEFW			L54433		; (D4A1) - 58  - blue room 3/8 (red rat)
;			DEFW			L54186		; (D3AA) - 59  - blue room 4/8 (yellow creeping hand)
;			DEFW			L53863		; (D267) - 60  - toxic cloud area 4/4
			
;			DEFW			L51269		; (C845) - 61  - black room 3/7 (cyan mole)
;			DEFW			L51401		; (C8C9) - 62  - black room 4/7 (red rat/bubble)
;			DEFW			L51543		; (C957) - 63  - black room 5/7
;			DEFW			L55699		; (D993) - 64  - black room 6/7
;			DEFW			L55244		; (D7CC) - 65  - black room 7/7 (green mole)
;			DEFW			L55111		; (D747) - 66  - blue room 5/8 (yellow bird)
;			DEFW			L54701		; (D5AD) - 67  - blue room 6/8 (black bat)
;			DEFW			L54579		; (D533) - 68  - blue room 7/8 (green mole)
;			DEFW			L54311		; (D427) - 69  - blue room 8/8 (Sinclair C5/green tortoise)
;			DEFW			L53925		; (D2A5) - 70  - reject egg smelter room
			
;			DEFW			L47236		; (B884) - 71  - train track 1/10
;			DEFW			L47274		; (B8AA) - 72  - train track 2/10
;			DEFW			L47318		; (B8D6) - 73  - train track 3/10
;			DEFW			L47366		; (B906) - 74  - train track 4/10 (train is here when power to factory is off)
;			DEFW			L47410		; (B932) - 75  - train track 5/10
;			DEFW			L47460		; (B964) - 76  - train track 6/10
;			DEFW			L47532		; (B9AC) - 77  - train track 7/10
;			DEFW			L47588		; (B9E4) - 78  - train track 8/10
;			DEFW			L47669		; (BA35) - 79  - train track 9/10
;			DEFW			L47719		; (BA67) - 80  - train track 10/10
			
;			DEFW			L48727		; (BE57) - 81  - dispatch area 1/8
;			DEFW			L43734		; (AAD6) - 82  - toy area 1/10 (1 toy part here)
;			DEFW			L43856		; (AB50) - 83  - toy area 2/10 (3 toy parts here)
;			DEFW			L46464		; (B580) - 84  - chain up to train track area
;			DEFW			L46639		; (B62F) - 85  - room above the toy maker room
;			DEFW			L46719		; (B67F) - 86  - sugar area 1/11 (1 bag of sugar here)
;			DEFW			L46835		; (B6F3) - 87  - sugar area 2/11 (1 bag of sugar here)
;			DEFW			L46963		; (B773) - 88  - sugar area 3/11 (1 bag of sugar here)
;			DEFW			L47073		; (B7E1) - 89  - sugar area 4/11 (1 bag of sugar here)
;			DEFW			L47177		; (B849) - 90  - slippery pipe down from the track track area & a bouncy spring
			
;			DEFW			L48575		; (BDBF) - 91  - dispatch area 2/8
;			DEFW			L43612		; (AA5C) - 92  - toy area 3/10 (2 toy parts here)
;			DEFW			L43972		; (ABC4) - 93  - toy area 4/10 (2 toy parts here)
;			DEFW			L44088		; (AC38) - 94  - toy area 5/10 (4 acid dripping pipes & basket)
;			DEFW			L44183		; (AC97) - 95  - toy area 6/10 (toy maker room)
;			DEFW			L44489		; (ADC9) - 96  - toy area 7/10 (girder is here)
;			DEFW			L45984		; (B3A0) - 97  - sugar area 5/11 (1 bag of sugar here)
;			DEFW			L46084		; (B404) - 98  - sugar area 6/11 (1 bag of sugar here)
;			DEFW			L46158		; (B44E) - 99  - sugar area 7/11 (1 bag of sugar here)
;			DEFW			L46329		; (B4F9) - 100 - sugar area 8/11 (1 bag of sugar here)
			
;			DEFW			L48441		; (BD39) - 101 - dispatch area 3/8
;			DEFW			L48172		; (BC2C) - 102 - dispatch area 4/8
;			DEFW			L47916		; (BB2C) - 103 - dispatch area 5/8
;			DEFW			L44307		; (AD13) - 104 - toy area 8/10 (platform that descends when you jump on it from room above)
;			DEFW			L44396		; (AD6C) - 105 - toy area 9/10 (lift with OUT OF ORDER sign when you jump at it)
;			DEFW			L44554		; (AE0A) - 106 - toy area 10/10 (boiler room + lots of pipes)
;			DEFW			L45761		; (B2C1) - 107 - room to the right of boiler room!!
;			DEFW			L45830		; (B306) - 108 - sugar area 9/11 (you come up the this room from below to start sugar collecting part of game)
;			DEFW			L45940		; (B374) - 109 - sugar area 10/11 (ladder is here)
;			DEFW			L46268		; (B4BC) - 110 - sugar area 11/11 (sugar vat room)
			
;			DEFW			L48336		; (BCD0) - 111 - dispatch area 6/8 (dispatch room)
;			DEFW			L48080		; (BBD0) - 112 - dispatch area 7/8
;			DEFW			L47776		; (BAA0) - 113 - dispatch area 8/8
;			DEFW			L45320		; (B108) - 114 - left of generator room (3 acid dripping pipes)
;			DEFW			L45385		; (B149) - 115 - generator room
;			DEFW			L45528		; (B1D8) - 116 - right of generator room (4 acid dripping pipes)
;			DEFW			L45586		; (B212) - 117 - another 4 acid dripping pipes
;			DEFW			L45638		; (B246) - 118 - use ladder in this room to get up to sugar area
;			DEFW			L45664		; (B260) - 119 - yellow boot and long ladder that goes up to ladder room			
;			DEFW			L45684		; (B274) - 120 - final room - A MONSTERS WORK IS NEVER DONE

; start room - 124 bytes for this room
L52905		DEFB			07								; colours for this room

			DEFB			$3E,$04,$16,00,$19,00				; grass at bottom of screen (UDG no.,colour,y-pos,x-pos,length,solid or not?) 0 = we can walk though it, 1 = we can't

			DEFB			$3A,$24,$17,00,$19,01				; the solid green line at very bottom of screen	(the grass from above sits on top of this green line)			

			DEFB			$3A,$24,$17,$1C,04,01				; the solid 4 char long piece of green line to the right of the ladder

			DEFB			$3E,04,$16,$1C,04,00				; the grass that sits on top of above 4 char long line

			DEFB			01,$0F,$0C,$10,07,08,00			; the square part of the BEWARE OF THE DOG sign (UDG,colour,y-pos,x-pos,height,width)

			DEFB			01,$0F,$13,$13,04,02,00			; post of BEWARE sign (UDG,colour,y-pos,x-pos,height,width,solid or not?)


			DEFB			02,$0F,$0D,$11,"BEWARE",$80			; BEWARE (2 indicates this is text,colour,y-pos,x-pos,string text,80h to terminate a string)


			DEFB			02,$0F,$0F,$11,"OF THE",$80			; OF THE 

			DEFB			02,$0F,$11,$12,"DOG",$80 			; DOG

			DEFB			$34,02,$15,$1A,$83,02				; ladder down to bone room - (UDG,colour,y-pos,x-pos,length(high bit set indicates this is to be vertical instead of horizontal),2 indicates climbable)

			DEFB			$0A,07,$59,05,05,00				; 0A indicates a single UDG to be drawn (colour,UDG,y-pos,x-pos,not solid) top left star in sky

			DEFB			$0A,07,$59,$0A,$0C,00				; another star in the sky

			DEFB			$0A,07,$59,$0E,03,00				; another star

			DEFB			$0A,07,$59,$0F,$0E,00				; yet another star

			DEFB			$0A,07,$59,$0A,$1A,00				; one more star for good measure

			DEFB			$0A,07,$57,06,$13,00				; top half of moon in the sky

			DEFB			$0A,07,$58,07,$13,00				; bottom half of moon in the sky

			DEFB			$3A,00,$13,06,$83,01				; back of the van that throws you out to start game - black solid wall to stop you walking leftwards towards the edge of the screen (it's black to make it appear invisible when the room is first drawn because the room is drawn before the wagon reverses onto the screen and if it were made any other colour you'd be able to see it but because it's black it blends into the blackness of the background)
			DEFB			00								; zero byte to indicate end of this room

; reject egg smelter room (room 70) (261 bytes)
L53925		DEFB			00

			DEFB			$3F,$16,02,00,$96,01					; left hand edge of screen

			DEFB			$3F,$16,02,$1F,$96,01					; right hand edge of screen

			DEFB			$3F,$16,$17,01,$1E,01					; bottom of screen

			DEFB			$3F,$16,08,01,05,01					; left hand platform in middle of screen

			DEFB			$3F,$16,08,09,05,01					; next one along

			DEFB			$3F,$16,08,$12,03,01					; next one along

			DEFB			$3F,$16,08,$1A,03,01					; next one along (you land on this one when you slide down the pipe from screen above)

			DEFB			$3F,$16,$0F,02,04,01					; platform at bottom of ladder to left of screen

			DEFB			$34,05,07,03,$88,02					; ladder to left of screen

			DEFB			$33,05,02,$17,$88,02					; chain at upper right of screen

			DEFB			$33,05,09,$0A,$8C,02					; chain that drops you down on the deck

			DEFB			$35,07,02,$1C,$85,$10					; slippery pipe at top right which you enter this room on

			DEFB			$35,06,$13,07,$85,$10					; slippery pipe at bottom left which takes you down to next room					; 

			DEFB			01,$18,$12,$0D,05,$0E,00				; box 1 for factory (main part of factory)

			DEFB			01,$18,$0C,$0F,02,02,00				; box 2 for factory (chimney stack - top left 2x2 block)

			DEFB			01,$18,$0E,$0F,02,04,00				; box 3 for factory (chimney stack - middle piece 2x4)

			DEFB			01,$18,$10,$11,02,02,00				; box 4 for factory (chimney stack - bit that attaches to factory - 2x2)

			DEFB			$0A,03,$3A,$0B,$10,00					; a single block of magenta to go on top of chimney stack - not sure why they did it this way


			DEFB			02,$18,$14,$14,"REJECT",$80				; text REJECT

			DEFB			02,$18,$15,$16,"EGG",$80				; text EGG


			DEFB			02,$18,$16,$14,"SMELTER",$80			; text SMELTER

			DEFB			$0A,$38,$44,$13,$0E,00					; 4 UDGs making 

			DEFB			$0A,$38,$45,$13,$0F,00					; up the

			DEFB			$0A,$38,$46,$14,$0E,00					; dial/gauge

			DEFB			$0A,$38,$47,$14,$0F,00					; on the factory

			DEFB			$0A,$38,$48,$13,$11,00					; 6 UDGs making

			DEFB			$0A,$38,$49,$13,$12,00					; up the big

			DEFB			$0A,$38,$4A,$14,$11,00					; switch

			DEFB			$0A,$38,$4B,$14,$12,00					; on the factory

			DEFB			$0A,$38,$4C,$15,$11,00					;

			DEFB			$0A,$38,$4D,$15,$12,00					;

			DEFB			$4E,$18,$13,$14,05,00					; a row of 10 switches below the indicator lights (2 switches per UDG)

			DEFB			$0A,$1E,$4F,$12,$14,00					; indicator lights on factory - yellow

			DEFB			$0A,$1C,$4F,$12,$15,00					; indicator lights on factory - green

			DEFB			$0A,$19,$4F,$12,$16,00					; indicator lights on factory - blue

			DEFB			$0A,$1E,$4F,$12,$17,00					; indciator lights on factory - yellow

			DEFB			$0A,$1F,$4F,$12,$18,00					; indicator lights on factory - white

			DEFB			$21,07,$13,00,04,$17,00				; horizontal bit of white pipe in lower left of screen

			DEFB			$20,07,$13,03,$85,$70,00				; vertical bit of white pipe in lower left of screen

			DEFB			$0A,03,$3A,$0B,$0F,00					; a single block of magenta to go on top of chimney stack - not sure why they did it this way
			DEFB			00									; end of room (54185)


