; ---------------------------------------------------
; Polling demo
; There are 4 tasks, numbered 0, 1, 2, and 3. Port 1 is connected to
; 8 push buttons. P1.0 to P1.3 are the "ON" buttons for tasks 0 to 3.
; Similarly, P1.4 to P1.7 are the "OFF" buttons. The polling loop 
; checks the buttons and calls respective Start and Stop routines for 
; the tasks. The polling loop repeated every second. Time is kept
; in seconds, minutes, and hours.


; --- internal RAM variables --- 
; Push button inputs
  Input        equ 7Ah

; Time 
  Seconds      equ 7Bh
  Minutes      equ 7Ch
  Hours        equ 7Dh

; Task status bytes
; bits 0 to 3 correspond to tasks 0 to 3.
  TempStatus   equ  7Eh
  TaskStatus   equ  7Fh

      org   8000h
; --- initialization ---
      mov   TaskStatus, #0   ; all tasks are off
      mov   Seconds, #0
	  mov   Minutes, #0
	  mov   Hours, #0
      
; --- main loop ---
; this is the endless polling loop. at each iteration the input buttons are 
; inspected and the software timer is updated. each task may be started or 
; stopped by its corresponding push button. the time a task starts or stops
; is reported. the duration of the task is also reported when stopped.
Poll:
	  lcall PrtTime                ; (print time)
      lcall GetInput               ; read P1 or the keyboard while debugging
	  mov   a, Input               ; recal push button values
	  lcall PrtHex
	  mov   a, #' '
	  lcall sndchr
      mov   a, TaskStatus
	  lcall PrtHex
      lcall crlf

; check to see if any of the "start" buttons are pressed
	  mov   a, Input               ; recal push button values
	  cjne  a, #0FFh, PbPressed    ; some pushbutton is pressed
	  ljmp  UpdateTime             ; no buttons, update timer

PbPressed:
      anl   a, #0Fh                ; mask stop bits (make all 0's)
      cjne  a, #0Fh, StartsFound
	  ljmp  CheckStops
StartsFound:     
; at least one start button is pressed -- accordingly update temp status
	  mov   a, Input               ; recal push button values
      cpl   a                      ; TaskStatus bit is 1 if task starts
	  anl   a, #0Fh                ; the 1's in acc are tasks to be started
      orl   a, TaskStatus          ; turn starting task bits on in TaskStatus
	  mov   TempStatus, a          ; temporary -- check stops before actual changes

; check to see if any of the "stop" buttons are pressed
; note that stop buttons dominate, i.e., if both stop and start are pressed
; the task is stopped 
CheckStops:
	  mov   a, Input               ; recal push button values
   	  swap  a                      ; swap nibbles
   	  anl   a, #0Fh                ; the 0's in acc are tasks to be stopped
      anl   TempStatus, a          ; turn stopping task bits off in TempStatus

; we have the old status byte TaskStatus, and the new byte TempStatus
; see if anything changed
      mov   a, TempStatus          ; get temp status
      xrl   a, TaskStatus          ; xor bits that are 1's denote changes
      mov   TaskStatus, TempStatus ; update status byte
	  jz    UpdateTime             ; if result (in acc) is zero, no changes

; the 1's in acc denote state changes -- inspect acc.0 to acc.3
      mov   b, TaskStatus          ; updated status byte

; inspect task 0 changes
      jnb   acc.0, t01             ; skip if task 0 status is the same
      push  acc
	  push  b
	  jb    b.0, s00               ; jump if task 0 is starting
	  lcall Stop0
	  sjmp  s01
s00:
	  lcall Start0
s01:
      pop   b
	  pop   acc

; inspect task 1 changes
t01:
      jnb   acc.1, t02             ; skip if task 1 status is the same
      push  acc
	  push  b
	  jb    b.1, s10               ; jump if task 0 is starting
	  lcall Stop1
	  sjmp  s11
s10:
	  lcall Start1
s11:
      pop   b
	  pop   acc

; inspect task 2 changes
t02:
      jnb   acc.2, t03             ; skip if task 2 status is the same
      push  acc
	  push  b
	  jb    b.2, s20               ; jump if task 0 is starting
	  lcall Stop2
	  sjmp  s21
s20:
	  lcall Start2
s21:
      pop   b
	  pop   acc

; inspect task 3 changes
t03:
      jnb   acc.3, UpdateTime      ; skip if task 3 status is the same
      push  acc
	  push  b
	  jb    b.3, s30               ; jump if task 0 is starting
	  lcall Stop3
	  sjmp  s31
s30:
	  lcall Start3
s31:
      pop   b
	  pop   acc

; --- task buttons inspected, StartX and StopX routines called ---
; now update the time
UpdateTime:
      mov   a, #1
	  lcall sdelay                 ; delay 1 second
	  inc   Seconds
	  mov   a, Seconds
	  cjne  a, #60, TimerOK
	  mov   Seconds, #0
	  inc   Minutes
	  mov   a, Minutes
	  cjne  a, #60, TimerOK
	  mov   Minutes, #0
	  inc   Hours
TimerOK:
	  ljmp  Poll

; -----------------------------------------------------------------------
GetInput:
; comment out one of the following:

; 1. hardware version reads P1
;     mov   Input, P1
;     ret

; 2. debug version uses keyboard inputs
     lcall print
	 db    "? > ", 0
     lcall getbyt;;
	 mov   Input, a
	 lcall crlf
	 ret

; -----------------------------------------------------------------------
Start0:
      lcall print
	  db    "Task 0 starts at : ", 0
      lcall prtTime
	  ret
Start1:
      lcall print
	  db    "Task 1 starts at : ", 0
      lcall prtTime
	  ret
Start2:
      lcall print
	  db    "Task 2 starts at : ", 0
      lcall prtTime
	  ret
Start3:
      lcall print
	  db    "Task 3 starts at : ", 0
      lcall prtTime
	  ret

Stop0:
      lcall print
	  db    "Task 0 stops at : ", 0
      lcall prtTime
	  ret
Stop1:
      lcall print
	  db    "Task 1 stops at : ", 0
      lcall prtTime
	  ret
Stop2:
      lcall print
	  db    "Task 2 stops at : ", 0
      lcall prtTime
	  ret
Stop3:
      lcall print
	  db    "Task 3 stops at : ", 0
      lcall prtTime
	  ret

; -----------------------------------------------------------------------
prtTime:
     mov   a, Hours
	 lcall prtdec
	 mov   a, #':'
	 lcall sndchr
	 mov   a, Minutes
	 lcall prtdec
	 mov   a, #':'
	 lcall sndchr
	 mov   a, Seconds
	 lcall prtdec
     lcall crlf
     ret

; -----------------------------------------------------------------------
PrtDec:
     mov   b, #100
	 div   ab
	 add   a, #'0'
	 lcall sndchr
	 mov   a, b
     mov   b, #10
	 div   ab
	 add   a, #'0'
	 lcall sndchr
     mov   a, b
	 add   a, #'0'
	 lcall sndchr
     ret

; ====================================================
;  subroutine sdelay - second delay
;   delays for 999998 microseconds - 2 microseconds
;   are reserved for the call to this routine.
;  input    : none
;  output   : none
;  destroys : nothing - uses a
; ----------------------------------------------------
; 100h-91h=6fh=(111)decimal
; 9008 * 111 = 999888
; plus 102 from second loop
; plus 8 gives 999998 microseconds
;
;                        microseconds (cycles)
;                       -----------------------
sdelay: push acc             ;   2
        mov  a, #91h        ;   1

sd_olp: inc   a      ; \
        lcall mdelay ; |
        lcall mdelay ; |
        lcall mdelay ; |
        lcall mdelay ; |
        lcall mdelay ; |
        lcall mdelay ; |
        lcall mdelay ; |- loop takes 9008 microseconds
        lcall mdelay ; |
        lcall mdelay ; |
        nop          ; |
        nop          ; |
        nop          ; |
        nop          ; |
        nop          ; |
        jnz   sd_olp ; /

        mov   a, #33h       ;   1
sd_ilp: djnz  acc, sd_ilp    ; -loop takes 2*33h=66h=(102)dec

        pop   acc            ;   2
        ret                  ;   2


; ====================================================
;  subroutine mdelay - millisecond delay
;   delays for 998 microseconds - 2 microseconds are
;   reserved for the call to this routine.
;  input    : none
;  output   : none
;  destroys : nothing - uses a
; ----------------------------------------------------
; 100h-a6h=5ah=(90)decimal
; 90 * 11 = 990
; plus 8 gives 998 microseconds
;
;                        microseconds (cycles)
;                       -----------------------
mdelay: push acc        ;    2
        mov   a, #0a6h  ;    1

md_olp: inc   a         ;    1  \
        nop             ;    1  |
        nop             ;    1  |
        nop             ;    1  |
        nop             ;    1  |
        nop             ;    1  |- 11  cycles
        nop             ;    1  |
        nop             ;    1  |
        nop             ;    1  |
        jnz   md_olp    ;    2  /

        nop             ;    1
        pop   acc       ;    2
        ret             ;    2

; ==========================================================
; subroutine print
; print takes the string immediately following the call and 
; sends it out the serial port.  the string must be terminated
; with a null. this routine will ret to the instruction
; immediately following the string.
; ==========================================================
;
print:   pop   dph              ; put return address in dptr
         pop   dpl
         lcall prtstr           ; print string and update dptr
         mov   a,  #1h          ; point to instruction after string
         jmp   @a+dptr          ; return


; ==========================================================
; subroutine prtstr
; this routine takes the string pointed to by the data pointer
; and sends it out the serial port. the string must be
; terminated with a null.
; ==========================================================
prtstr:  clr  a                  ; set offset = 0
         movc a,  @a+dptr        ; get chr from code memory
         cjne a,  #0h, mchrok    ; if chr = ff then return
         ret
mchrok:  lcall sndchr            ; send character
         inc   dptr              ; point at next character
         ljmp  prtstr            ; loop till end of string

; ==========================================================
; subroutine prthex
; this routine takes the contents of the acc and prints it out 
; as a 2 digit ascii hex number.
; ==========================================================
prthex:  
         push  acc
		 swap  a
		 anl   a, #0Fh
         add   a,  #0F6h         ; adjust it
         jnc   ph01              ; no carry means 0-9
         add   a,  #07h          ; if a-f then readjust
ph01:
         add   a,  #3Ah          ; make ascii
         lcall sndchr            ; print first hex digit

	  	 pop   acc
		 anl   a, #0Fh           ; repeat for low nibble
         add   a,  #0F6h
         jnc   ph02
         add   a,  #07h
ph02:
         add   a,  #3Ah
         lcall sndchr
         ret

; ==========================================================
; subroutine crlf
; crlf sends a carriage return line feed out the serial port
; ==========================================================
crlf:    mov   a,  #0ah         ; print lf
         lcall sndchr
cret:    mov   a,  #0dh         ; print cr
         lcall sndchr
         ret

; ==========================================================
; subroutine sndchr
; this routine takes the chr in the acc and sends it out the
; serial port.
; ==========================================================
;
sndchr:  clr  scon.1             ; clear the tx  buffer full flag.
         mov  sbuf,a             ; put chr in sbuf
txloop:  jnb  scon.1, txloop     ; wait till chr is sent
         ret
; ====================================================

; ==========================================================
; subroutine getbyt
; this routine reads in an 2 digit ascii hex number from the
; serial port. the result is returned in the acc.
; ==========================================================
;
getbyt:  lcall getchr            ; get msb ascii chr
         lcall ascbin            ; conv it to binary
         swap  a                 ; move to most sig half of acc
         mov   b,  a             ; save in b
         lcall getchr            ; get lsb ascii chr
         lcall ascbin            ; conv it to binary
         orl   a,  b             ; combine two halves
         ret
; ==========================================================
; subroutine ascbin
; this routine takes the ascii character passed to it in the
; acc and converts it to a 4 bit binary number which is returned 
; in the acc.
; ==========================================================
ascbin:  add   a,  #0d0h        ; if chr < 30 then error
         jnc   notnum
         clr   c                 ; check if chr is 0-9
         add   a,  #0f6h        ; adjust it
         jc    hextry            ; jmp if chr not 0-9
         add   a,  #0ah         ; if it is then adjust it
         ret

hextry:  clr   acc.5             ; convert to upper
         clr   c                 ; check if chr is a-f
         add   a,  #0f9h        ; adjust it
         jnc   notnum            ; if not a-f then error
         clr   c                 ; see if char is 46 or less.
         add   a,  #0fah        ; adjust acc
         jc    notnum            ; if carry then not hex
         anl   a,  #0fh         ; clear unused bits
         ret

notnum:  mov   a, #0            ; if not a valid digit
         ret

; ==========================================================
; subroutine getchr
; this routine reads in a chr from the serial port and saves it
; in the accumulator.
; ==========================================================
;
getchr:  jnb  ri, getchr         ; wait till character received
         mov  a,  sbuf           ; get character
         anl  a,  #7fh          ; mask off 8th bit
         clr  ri                 ; clear serial status bit
         ret

