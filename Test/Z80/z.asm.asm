;
; changes:
; 023E:	DISPLAY_2:	CALL	KEYBOARD	CD BB 02
; 023E:	DISPLAY_2:	CALL	KEYBOARD	CD 00 40	;; CALL 4000 hex
; 02BB: KEYBOARD: (original)

#target     rom                 ; declare target file format

#code       rom,$2000,$100             ; declare code segment start and size

;;	keyboard	equ	$02BB
;	The keyboard routine scans every row, one by one.
;	This is quite complicated but there is enough time in vsync to do this.
;	However, it would be better off generating proper sync pulses.
;	My idea is something like this:
;
	in a,(0)	; read all rows at once
	cp $FF
	jr	z, make_nice_syncs	; if nothing pressed, make_nice_syncs
;	jp	keyboard		; if anything pressed, scan in detail
	jp	$02BB			; if anything pressed, scan in detail
make_nice_syncs:
; Do blank lines after visible lines

; the routine's bad sync generation will disrupt the image on monitor,
; but that happens anyway as the keypress is parsed.
; If no keys are pressed, we are free to generate nice sync pulses.
; There are five line periods, best though of as ten half-lines.
;
;
	call	line_32us_with_long_sync; do this five times
	call	line_32us_with_long_sync;
	call	line_32us_with_long_sync;
	call	line_32us_with_long_sync;
	call	line_32us_with_long_sync;
;
	call	line_32us_with_normal_sync; do this five times
	call	line_32us_with_normal_sync;
	call	line_32us_with_normal_sync;
	call	line_32us_with_normal_sync;
	call	line_32us_with_normal_sync;

; Do blank lines before visible lines

	ret	; end
;
; Subroutines:
;
; call	takes 17 T
; ret	takes 10 T
; 32 us is 118 T states at 14.75 MHz, 
; subtract 27 leaves 91 T states 
;
;
line_32us_with_long_sync:
	in a,($FE)	; 11 T sync lo 
			; 80 T sync (29.65 us ideally)
	ld b,$5		; (80-8)/13 = 5.54 = 5 remainder 7
line_32us_with_long_sync_loop:
	djnz	line_32us_with_long_sync_loop	; 13/8
	ld b,$0		; 7 T
	out ($FF),a	; 11 T sync hi
			; immediate negation is the fastest possible,
			;  giving 2.983 us (2.35 us ideally)
	in a,($FE)	; 11 T sync lo 
	ret
;
;
line_32us_with_normal_sync:
	in a,($FE)	; 11 T sync lo (4.7 us ideally)
			; immediate negation is the fastest possible,
			;  giving 2.983 us
	or  a,0		;  add 7 T-states
	out ($FF),a	; 11 T sync hi
			; 96 T non-sync	time here
	ld b,$6		; (96-8)/13 = 6.77
line_32us_with_normal_sync_loop:
	djnz	line_32us_with_normal_sync_loop	; 13/8
			; 6*13+8 = 86 so 10 more to go
	jp return	; 10
return:
;;	keyboard:
	ret		;


	
#end                            ; terminate #target
