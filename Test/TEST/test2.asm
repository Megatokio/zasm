#!/usr/local/bin/zasm -o original/


#target ram


; ––––––––––––––––––––––––––
; dummy 'real code':
; ––––––––––––––––––––––––––

#code CODE, 0, *
	jp  $

.org 0x38
L1:	push hl
	ld  hl,(systime)
	inc hl
	ld  (systime),hl
	pop hl
	ei
	ret

systime: dw  0



; -------------------------------------------
; test startup cc
; max speed, no int
; -------------------------------------------

#test TEST1, 1000
	nop
	.expect cc = 4

	nop
	nop

	.expect cc = 8

;	.test-timeout 1 s
;	halt
;	nop


; -------------------------------------------
; test startup cc
; speed set, no int
; -------------------------------------------

#test TEST2, 1000
	.test-clock 4 MHz

	nop
	.expect cc = 4

	nop
	nop

	.expect cc = 8

;	.test-timeout 1 s
;	halt
;	nop


; -------------------------------------------
; test startup cc
; max speed, int with auto-off
; -------------------------------------------

#test TEST3, 1000
	.test-int 50 Hz

	nop
	.expect cc = 4

	nop
	nop

	.expect cc = 8

	ei
	nop
	di

; in auto-off mode the first interrupt is suppressed:
	.expect cc = 12

	ei
	halt

; the interrupt occurs in real-time,
; the cpu runs at unknown speed,
; => we can only guess how many nops were executed
;    but let's assume that we are faster than 100 MHz:

	.expect cc > 100 * 1000000 / 50


; -------------------------------------------
; test startup cc
; speed set, int with auto-off
; -------------------------------------------

#test TEST4, 1000
	.test-clock 4 MHz
	.test-int 50 Hz

	nop
	.expect cc = 4

	nop
	nop

	.expect cc = 8

	ei
	nop
	di

	; in auto-off mode the first interrupt is suppressed:
	.expect cc = 12

	ei
	halt

	; the interrupt occurs every 80000 cc:
	; when we are stopped here, the int routine was executed
	; expected cc = +80000
	;          -6*4 (nop,nop,nop,ei,nop,di)
	;          +13+73 (int + int_handler)

	.expect cc = 80000 - 6*4 + 13+73

	halt

	; expect 80000 - (13+73) + (13+73)
	;        + 2 because 13+73=86 = not a multiple of 4

	.expect cc = 80000 + 2

	halt

	; expect 80000 - (13+73) + (13+73)
	;        - 2 because total cc is now again a multiple of 4

	.expect cc = 80000 - 2


; -------------------------------------------
; test startup cc
; max speed, int with dur
; -------------------------------------------

#test TEST5, 1000
.test-int 50000 cc, 21 cc

	nop

.expect cc = 4

	nop
	nop

.expect cc = 8

	ei
	nop
	;		<-- int
	nop

; in int-with-duration mode the first interrupt is not suppressed.
; if interrupts are enabled early enough, we catch the first int:

.expect cc = 8 + 13 + 73 + 4	; ei+nop+int+int_proc+nop

	halt  ;	<-- int
	nop

; we got next int at 50000 cc
; but already executed: 20 cc (nop,nop,nop,ei,nop) + 13+73 (int) + 4 (nop)
; then halt skipped over, +13+73 (int) + 4cc (nop)
; then +2 because 13+73 is not a multiple of 4

.expect cc = 50000 - (20 + 13 + 73 + 4) + (13 + 73 + 4) +2

	halt
	nop

; we got next int after 50000 cc
; time already executed == time added for this interrupt
; now -2 cc earlier because total cc since start now again is a multiple of 4

.expect cc = 50000 - (13 + 73 + 4) + (13 + 73 + 4) -2

; seems it works but it is hard to understand :-)


; -------------------------------------------
; test startup cc
; speed set, int with dur
; -------------------------------------------

#test TEST6, 1000
	.test-clock 4 MHz
	.test-int 50000 cc, 21 cc

; test sequence is as in TEST5
; only difference is the fixed speed

	nop

.expect cc = 4

	nop
	nop

.expect cc = 8

	ei
	nop
	;		<-- int
	nop

.expect cc = 8 + 13 + 73 + 4	; ei+nop+int+int_proc+nop

	halt  ;	<-- int
	nop

.expect cc = 50000 - (20 + 13 + 73 + 4) + (13 + 73 + 4) +2

	halt
	nop

.expect cc = 50000 - (13 + 73 + 4) + (13 + 73 + 4) -2


; -------------------------------------------
; test startup cc
; unlimited speed, int with auto-off, real-world int frreq.
; -------------------------------------------

#test TEST7, 1000
	.test-int 50 Hz

	nop
	ei
	nop
	nop

; with auto-off the first interrupt at cc=0 is suppressed:

.expect cc < 20

	halt
	ld	hl,(systime)

; we waited for and performed the interrupt:

.expect cc > 100 * 1000000 / 50
.expect hl = 1

	halt
	ld	hl,(systime)

; we waited for and performed the next interrupt:

.expect cc > 100 * 1000000 / 50
.expect hl = 2












