;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PacAlpaca.asm
;
;  ALPACA: A Multitasking operating system for Pac-Man Z80 arcade hardware
;
;  Written by 
;       Scott "Jerry" Lawrence
;       alpaca@umlautllama.com
;
;  This source file is covered by the LGPL:
;
;;   Alpaca - A Multitasking operating system for Z80 arcade hardware
;;   Copyright (C) 2003 Scott "Jerry" Lawrence
;;                      alpaca@umlautllama.com
;;
;;    This is free software; you can redistribute it and/or modify
;;    it under the terms of the GNU Lesser General Public License
;;    as published by the Free Software Foundation; either version
;;    2 of the License, or (at your option) any later version.
;;
;;    This software is distributed in the hope that it will be
;;    useful, but WITHOUT ANY WARRANTY; without even the implied
;;    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;;    PURPOSE.  See the GNU Lesser General Public License for
;;    more details.
;;
;;    You should have received a copy of the GNU Lesser General
;;    Public License along with this library; if not, write to
;;    the Free Foundation, Inc., 59 Temple Place, Suite 330,
;;    Boston, MA  02111-1307  USA
;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;           This file is machine generated.  Do not edit it by hand!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


        .title alpaca
        .module alpaca

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; some constants:
        stack           = 0x4ff0
        vidram          = 0x4000
        colram          = 0x4400
        ram             = 0x4c00
        dsw0            = 0x5080
        in1             = 0x5040
        in0             = 0x5000
        specreg         = 0x5000
        speclen         = 0x00C0
        sprtbase        = 0x4ff0
        sprtlen         = 0x0010
        p1_port         = in0
        p1_up           = 0
        p1_left         = 1
        p1_right        = 2
        p1_down         = 3
        p2_port         = in1
        p2_up           = 0
        p2_left         = 1
        p2_right        = 2
        p2_down         = 3
        start_port      = in1
        start1          = 5
        start2          = 6
        coin_port       = in0
        coin1           = 5
        coin2           = 6
        coin3           = 7
        rack_port       = in0
        racktest        = 4
        svc_port        = in1
        service         = 4
        cab_port        = in1
        cabinet         = 7
        sprtMult        = 4
        sprtColor       = 1
        sprtIndex       = 0
        sprtXFlip       = 0
        bitXFlip        = 0
        valXFlip        = 1
        sprtYFlip       = 0
        bitYFlip        = 1
        valYFlip        = 2
        spritebase      = 0x4ff0
        nsprites        = 0x08
        spritecoords    = 0x5060
        v1_acc          = 0x5040
        v1_wave         = 0x5045
        v1_freq         = 0x5050
        v1_vol          = 0x5055
        v2_acc          = 0x5046
        v2_wave         = 0x504a
        v2_freq         = 0x5056
        v2_vol          = 0x505a
        v3_acc          = 0x504b
        v3_wave         = 0x504f
        v3_freq         = 0x505b
        v3_vol          = 0x505f
        irqen           = 0x5000
        sounden         = 0x5001
        flipscreen      = 0x5003
        coincount       = 0x5007
        watchdog        = 0x50C0

; constants for the task system
        stacksize       = 192           ; number of bytes per stack
        slotTicks       = 4     ; number of ticks per slot to start with


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM allocation:
            ; which task is in which slot (index into tasklist)
        slotIdx         = (ram + 0) ; 4 bytes, one per slot
        slotIdx0        = (ram + 0)
        slotIdx1        = (ram + 1)
        slotIdx2        = (ram + 2)
        slotIdx3        = (ram + 3)
        slotOpen        = 0xff
            ; control information for each slot (to be handled by switcher)
        slotCtrl        = (ram + 4) ; 4 bytes, one per slot
        slot0Ctrl       = (ram + 4)
        slot1Ctrl       = (ram + 5)
        slot2Ctrl       = (ram + 6)
        slot3Ctrl       = (ram + 7)
        C_InUse         = 7
        C_EXT0          = 4
            killSlot    = 0
            execSlot    = 1
            sleepSlot   = 2
        ; stack pointers for the four slots
        slotSP          = (ram + 8)  ; 8 bytes, two per slot
        slotSP0         = (ram + 8)
        slotSP1         = (ram + 10)
        slotSP2         = (ram + 12)
        slotSP3         = (ram + 14)
        ; Base of ram for the currently active slot.
        ramBase         = (ram + 16)    ; word
            ; various flags about the task switcher system
        taskFlag        = (ram + 18)    ; byte
        slot0use        = 0
        slot1use        = 1
        slot2use        = 2
        slot3use        = 3
        taskActive      = 7
            ; the currently active slot number
        taskSlot        = (ram + 19)    ; byte
            ; how many ticks does this slot have before it gets swapped out
        slotTime        = (ram + 20)    ; byte
            ; timer counter (word)
        timer           = (ram + 21)
            ; random assistance register (byte)
        randval         = (ram + 23)
            ; messages
        msgbase         = (ram + 0x0ca0)
        msgmax          = (msgbase + 0x003f)
            ; semaphores
        semabase        = (ram + 0x0ce0)
        semamax         = (semabase + 0x0F)
            ; stack regions for the four tasks
        stackbottom     = (stack-(stacksize*4)) ; 192 bytes (bottom of stack 3)
        stack3          = (stack-(stacksize*3)) ; 192 bytes
        stack2          = (stack-(stacksize*2)) ; 192 bytes
        stack1          = (stack-(stacksize*1)) ; 192 bytes
        stack0          = (stack-(0))           ; top of space - sprite ram


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; area configuration
; we want absolute dataspace, with this area called "CODE"
.area   .CODE (ABS)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RST functions

; RST 00
.org 0x000
.reset00:                       ; RST 00 - Init
        jp .start

; RST 08
.org 0x0008
.reset08:                       ; RST 08 - Semaphore control
        ret

; RST 10
.org 0x0010
.reset10:                       ; RST 10 - TBD
        ret

; RST 18
.org 0x0018
.reset18:                       ; RST 18 - TBD
        ret

; RST 20
.org 0x0020
.reset20:                       ; RST 20 - TBD
        ret

; RST 28
.org 0x0028
.reset28:                       ; RST 28 - TBD
        ret

; RST 30
.org 0x0030
.reset30:                       ; RST 30 - TBD
        ret

; RST 38
.org 0x0038
.reset38:                       ; RST 38 - Vblank Interrupt Service Routine
        jp      .isr

; NMI
.org 0x0066
.nmi:                           ; NMI handler
        retn



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; interrupt service routine:
.isr:
        di                      ; disable interrupts (no re-entry!)
        push    af              ; store aside some registers
        xor     a               ; a = 0
        ld      (irqen), a      ; disable external interrupt mechanism
        push    bc
        push    de
        push    hl
        push    ix
        push    iy
        ld      (watchdog), a   ; kick the dog
        ld      bc, (timer)     ; bc = timer
        inc     bc              ; bc++
        ld      (timer), bc     ; timer = bc
            ;; task management stuff
            ; check for disabled switching
        ld      hl, (taskFlag)
        bit     #taskActive, (hl)       ; check to see if task switching is on
        jr      Z, .doneTask            ; jp over if switching is disabled
        ; check to see if any of the control flags are set
            ; loop throgh all slots
            ; check for kill
            ; check for sleep
            ; check for start
            ;; check to see if we need to task switch yet
        ld      hl, #slotTime           ; hl = time address
        ld      c, (hl)                 ; c = current time for active slot
            ; check the current value
        xor     a                       ; a = 0
        cp      c                       ; is C >=0?  ( Carry set )
        jp      C, .noSwitch            ; still greater than zero?
            ;; change to next dormant task (or this one...)
.tsNext:
        ld      a, (taskSlot)           ; a = current task slot (a is try)
        ld      e, a                    ; de = current slot
.tsloop1:
        inc     a                       ; ++try
        and     a, #slotMask            ; try &= 0x03
        ld      hl, #(slotCtrl)         ; hl = slotCtrl base
        ld      c, a
        ld      b, #0x00                ; bc = task number
        add     hl, bc                  ; hl = control for this task
        bit     #C_InUse, (hl)          ; check the flag
        jr      NZ, .tsloop1            ; if not active, inc again
            ; compare selected task with "current"
        ld      a, e                    ; A = current (again)
        cp      c                       ; compare A(curr) and C(try)
        jr      Z, .overslot1           ; skip this next bit if we're there
.storeTheSP:
            ; snag the SP into IX
        ld      ix, #0x0000             ; zero ix
        add     ix, sp                  ; ix = SP

            ; setup HL as ram location to store SP
        ld      hl, #(slotSP)           ; hl = base of slotSP array
        ld      d, #0x00                ; de = current slot  
        rlc     e                       ;    = current slot * 2
                                        ; bc still contains the try value
        add     hl, de                  ; hl = base of current slot SP
        push    ix                      ; de
        pop     de                      ;    = SP
            ; store the current SP
        ld      (hl), e                 ; (hl) = 
        inc     hl
        ld      (hl), d                 ;      = de   (really SP)
.loadInTheSP:
            ; swap in the new SP
        ld      d, #0
        ld      e, c                    ; de = new slot number
        rlc     e                       ;    = new slot number * 2
        ld      hl, #(slotSP)           ; hl = base of slotSP array
        add     hl, de                  ; hl = base of new slot SP
            ; snag it and shove it into place
        ld      e, (hl)                 ; de = 
        inc     hl
        ld      d, (hl)                 ;    = new sp
        ld      h, d                    ; hl =
        ld      l, e                    ;    = sp
        ld      sp, hl                  ; new SP!
.setupVars:
            ; set up reference variables
        ld      a, c                    ; a = c
        ld      (taskSlot), a           ; taskSlot = new slot number
            ; set up ramBase
        ld      hl, #(stackList)        ; hl = base of stackList array
        ld      e, c                    ; e = new slot
        inc     e                       ; e = new slot + 1
        rlc     e                       ; e = (new slot + 1) * 2
        ld      d, #0                   ; de = (new slot + 1) * 2 
        add     hl, de                  ;    = index of this slot + 1 word
        ld      c, (hl)                 ; bc =
        inc     hl
        ld      b, (hl)                 ;    = new ramBase item
        ld      hl, #(ramBase)
        ld      (hl), c                 ; ramBase =
        inc     hl
        ld      (hl), b                 ;         = correct value!
.overslot1:
        ld      hl, #slotTime           ; hl = time address
        ld      (hl), #slotTicks        ; reset the ticks for this task
.noSwitch:
            ; decrement the slot timer
        ld      hl, #slotTime           ; hl = time address
        ld      c, (hl)                 ; c = current time for active slot
        dec     c                       ; current time --
        ld      (hl), c                 ; store the current time
.doneTask:
            ; restore the registers
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        ld      a, #0x01        ; a = 1
        ld      (irqen), a      ; enable external interrupt mechanism
        pop     af
        ei                      ; enable processor interrupts
        reti                    ; return from interrupt routine


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; the core OS stuff:
    ; initialization and splash screen
.start:
        di                      ; disable processor interrupts
        ld      sp, #(stack)    ; setup the initial stack pointer
        im      1               ; setup interrupt mode 1

        ;; clear the special registers
        ld      a, #0x00        ; a  = 0x00
        ld      hl, #(specreg)  ; hl = start of special registers
        ld      b, #(speclen)   ; b  = 0xC0 bytes to zero
        call    memset256       ; 0x5000-0x50C0 will get 0x00

        ;; clear sprite registers
        ld      a, #0x00        ; a  = 0x00
        ld      hl, #(sprtbase) ; hl = start of sprite registers
        ld      b, #(sprtlen)   ; b  = 0x10 16 bytes
        call    memset256       ; 0x4ff0-0x4fff will get 0x00

        ;; clear the screen ram
        call    cls             ; clear the screen RAM

        ;; clear user ram
        ld      hl, #(ram)      ; hl = base of RAM
        ld      a, #0x03        ; a = 0
        ld      b, #0x02        ; b = 2 blocks of 256 bytes to clear
        call    memsetN         ; clear the blocks

        ;; initialize tasks
            ; clear flags
        xor     a               ; a = 0
        ld      (taskFlag), a   ; clear all task flags
            ; clear the dormant stack pointers (set all four to 0x0000)
        xor     a               ; a = 0
        ld      b, #8           ; 8 bytes (4 one-word variables)
        ld      hl, #(slotSP)   ; base of slot stack pointers
        call    memset256       ; clear it
            ; set all slots as open
        ld      a, #(slotOpen)  ; a = openslot
        ld      b, #4           ; 4 bytes
        ld      hl, #(slotIdx)  ; base of slot index bytes
        call    memset256
            ; clear control bytes 
        xor     a               ; a = 0
        ld      b, #4           ; 4 bytes
        ld      hl, #(slotCtrl) ; base of slot control bytes
        call    memset256
            ; clear taskSlot
        xor     a               ; a = 0
        ld      (taskSlot), a   ; taskSlot = 0
            ; enable the task switcher
        ld      hl, (taskFlag)
        set     #taskActive, (hl)       ; set the flag
        ;; setup pac interrupts
        ld      a, #0xff        ; fill register 'a' with 0xff
        out     (0x00), a       ; send the 0xff to port 0x00
        ld      a, #0x01        ; fill register 'a' with 0x01
        ld      (irqen), a      ; enable the external interrupt mechanism.
        ei

            ; Splash screen!
.splash:
        call    guicls

        ; draw out the llama!
        ld      hl, #(llama1)   ; top half of llama
        ld      bc, #0x0d09
        ld      a, #(LlamaC)
        call    putstrB
        ld      hl, #(llama2)   ; bottom half of llama
        inc     c
        call    putstrB

        ; draw out the copyright notice and version info
        ld      hl, #(cprt1)
        ld      bc, #0x060f
        ld      a, #0x00        ; black text
        call    putstrB         ; top black border

        ld      bc, #0x0611
        call    putstrB         ; bottom black border

        ld      hl, #(cprt1)
        ld      a, #0x14        ; yellow text
        ld      bc, #0x0610
        call    putstrB         ; 'Alpaca OS...'

        ld      hl, #(cprt2)
        ld      a, #0x0b        ; cyan text
        ld      bc, #0x041e
        call    putstrB         ; '(C) 2003...

        ld      hl, #(cprt3)
        ld      bc, #0x0200
        call    putstrC         ; email addy

    ; the core task
.coretask:
        ; set up sprite 1 as the flying llama
        ld      ix, #(sprtbase)
        ld      a, #(LlamaFS*sprtMult)
        ld      sprtIndex(ix), a
        ld      a, #(3)                 ; decent llama color
        ld      sprtColor(ix), a

        ;; set up sprite 2 and 3
        ld      ix, #(sprtbase)
        ld      a, #4           ;(hardcoded for now)
        ld      2+sprtIndex(ix), a
        ld      4+sprtIndex(ix), a
        ld      a, #(3)         ;0x12
        ld      2+sprtColor(ix), a
        ld      4+sprtColor(ix), a

foo:
        ; do a lissajous on the screen with the first sprite (arrow cursor)
        ;; X
        ld      ix, #(spritecoords)
        ld      bc, (timer)
        rlc     c       ; *2 
        rlc     c       ; *2 
        call    sine
        rrca
        and     #0x7f
        add     #0x40
        ld      sprtIndex(ix), a
        ;; Y
        ld      bc, (timer)
        ;rlc    c
        call    cosine
        rrca
        and     #0x7f
        add     #0x40
        ld      sprtColor(ix), a

        ; try to hug a screen refresh
        ld      bc, #1
        call    sleep

        jp      foo
        halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; some helpful utility functions

; memset256
        ;; memset256 - set up to 256 bytes of ram to a certain value
        ;               in      a       value to poke
        ;               in      b       number of bytes to set 0x00 for 256
        ;               in      hl      base address of the memory location
        ;               out     -
        ;               mod     hl, bc
memset256:
        ld      (hl), a         ; *hl = 0
        inc     hl              ; hl++
        djnz    memset256       ; decrement b, jump to memset256 if b>0
        ret                     ; return


; memsetN
        ;; memsetN - set N blocks of ram to a certain value
        ;               in      a       value to poke
        ;               in      b       number of blocks to set
        ;               in      hl      base address of the memory location
        ;               out     -
        ;               mod     hl, bc
memsetN:
        push    bc              ; set aside bc
        ld      b, #0x00        ; b = 256
        call    memset256       ; set 256 bytes
        pop     bc              ; restore the outer bc
        djnz    memsetN         ; if we're not done, set another chunk.
        ret                     ; otherwise return


; clear screen
        ;; cls - clear the screen (color and video ram)
        ;               in      -
        ;               out     -
        ;               mod     -
cls:
        push    hl              ; set aside some registers
        push    af
        push    bc

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x00        ; clear the screen to 0x00
        ld      b, #0x08        ; need to set 256 bytes 8 times.

        call    memsetN         ; do it.

        pop     bc              ; restore the registers
        pop     af
        pop     hl
        ret                     ; return

; clear screen (gui tile version)
        ;; guicls - clear the screen to the GUI background
        ;               in      -
        ;               out     -
        ;               mod     -
guicls:
        push    hl              ; set aside some registers
        push    af
        push    bc

        ; fill the screen with the background color
        ld      hl, #(colram)   ; color ram
        ld      a, #(PwpC)      ; color
        ld      b, #0x04        ; 4 blocks
        call    memsetN

        ; fill the screen with the background tile
        ld      hl, #(vidram)   ; character ram
        ld      a, #(PwpS)      ; background tile
        ld      b, #0x04        ; 4 blocks
        call    memsetN

        pop     bc              ; restore the registers
        pop     af
        pop     hl
        ret                     ; return


; rand
        ;; rand - get a random number
        ;               in      -
        ;               out     a       random number 0..256
        ;               mod     flags
rand:
            ; set aside registers
        push    hl
        push    bc
            ; compute a random number
        ld      hl, (randval)   ; hl = last random number
        push    hl
        pop     bc              ; bc = hl
        call    sine            ; a = sine (c)
        ld      c, a            ; c = sine ( last value )
.r01:
        ld      a, r            ; a = R
        add     a, c            ; a += sine( last value )
        ld      c, a            ; c = sine( last value ) + R
.r02:
        add     hl, bc          ; rnd += sin ( last value ) + R
        ld      bc, (timer)
        add     hl, bc          ; rnd += timer
        ld      (randval), hl   ; hl = computed random (rnd)
        ld      a, (randval)    ; a = rnd
            ; restore registers
        pop     bc
        pop     hl
            ; return
        ret


; sine
        ;; sine - get the sine of a
        ;               in      c       value to look up
        ;               out     a       sine value 0..256
        ;               mod     -
sine:
            ; set aside registers
        push    hl
        push    bc
            ; look up the value in the sine table
        ld      hl, #(.sinetab) ; hl = sinetable base
        ld      b, #0x00        ; b = 0
        add     hl, bc          ; hl += bc
        ld      a, (hl)         ; a = sine(c)
            ; restore registers
        pop     bc
        pop     hl
            ; return
        ret

; cosine
        ;; cosine - get the cosine of a
        ;               in      c       value to look up
        ;               out     a       cosine value 0..256
        ;               mod     f
cosine:
            ; set aside registers
        push    bc
            ; add 180 degrees, call sine
        ld      a, #0x3f
        add     a, c
        ld      c, a
        call    sine
            ; restore registers 
        pop     bc
            ; return
        ret


; text justification
        ;; textcenter - adjust the x ordinate 
        ;               in      hl      pascal string
        ;               in      b       x ordinate
        ;               in      c       y ordinate  BC ->  0xXXYY
        ;               out     -
        ;               mod     b       adjusted for center
        hscrwide = 14
textcenter:
            ; set aside registers
        push    af
            ; halve the width
        ld      b, (hl)         ; b = length of text
        jp      NC, .tcrr       ; make sure carry is cleared
        ccf
.tcrr:
        rr      b               ; b = half of text length
            ; add on the center position
        ld      a, #hscrwide    ; a = screenwidth/2
        sub     b               ; a = screenwidth/2 - textlength/2
        ld      b, a            ; b = that result
            ; restore registers
        pop     af
            ; return
        ret

        ;; textright - adjust the x ordinate 
        ;               in      hl      pascal string
        ;               in      b       x ordinate
        ;               in      c       y ordinate  BC ->  0xXXYY
        ;               out     -
        ;               mod     b       adjusted for right
textright:
            ; set aside registers
        push    af
            ; halve the width
        ld      a, b            ; a = start location
        ld      b, (hl)         ; b = length of text
        sub     b               ; a = start loc - length
        ld      b, a            ; b = new position
            ; restore registers
        pop     af
            ; return
        ret


; xy2offs
        ;; xy2offsB - get the vid/color buffer offset of the X Y coordinates
        ;               in      b       x ordinate
        ;               in      c       y ordinate  BC ->  0xXXYY
        ;               out     hl      offset
        ;               mod     -
xy2offsB:
            ; set aside registers
        push    af
        push    bc
        push    de
        push    ix
            ; set aside Y for later in DE
        ld      d, #0x00        ; d = 0
        ld      e, c            ; shove Y into E
            ; get the base offset
        ld      ix, #(.scroffs) ; ix = offset table base
            ; add in X component
                ;; XXXXJJJJJ This can probably be shortened if we 
                ;;              drop the range check.
        ld      a, b            ; shove X into A
        and     a, #0x1f        ; make sure X is reasonable
        rlc     a               ; x *= 2
        ld      c, a            ; c = offset * 2
        ld      b, #0x00        ; b = 0
        add     ix, bc          ; ix += bc
            ; retrieve that value into HL
        ld      b, 1(ix)
        ld      c, 0(ix)
        push    bc
        pop     hl              ; hl = scroffs[x]
            ; add in Y component
        add     hl, de          ; hl += DE   hl = scroffs[x]+y
            ; restore registers 
        pop     ix
        pop     de
        pop     bc
        pop     af
            ; return
        ret

        ;; xy2offAC - get the vid/color buffer offset of the X Y coordinates
        ;               in      b       x ordinate
        ;               in      c       y ordinate  BC ->  0xXXYY
        ;               out     hl      offset
        ;               mod     -
xy2offsAC:
            ; set aside registers
        push    bc
        push    de
        push    ix
            ; generate the X component into DE
        ld      d, #0x00        ; d = 0
        ld      e, b            ; e = X
            ; get the base offset
        ld      ix, #(.acoffs)  ; ix = offset table base
            ; add in the y component. (BC)
        ld      b, #0x00        ; zero B (top of BC)
        rlc     c               ; y *= 2
        add     ix, bc          ; offset += index
            ; retrieve that value into HL
        ld      b, 1(ix)
        ld      c, 0(ix)
        push    bc
        pop     hl              ; hl = acroffs[x]
            ; subtract out the X component.
        sbc     hl, de          ; hl -= DE   hl = acoffs[y]-x
            ; restore registers 
        pop     ix
        pop     de
        pop     bc
            ; return
        ret


; putstr 
        ;; putstrA - get the vid/color buffer offset of the X Y coordinates
        ;               in      hl      pointer to the string (asciz)
        ;               in      b       x position
        ;               in      c       y position
        ;               in      a       color
        ;               out     -
        ;               mod     -
putstrA:
            ; set aside registers
        push    bc
.psChook:                       ; this is where putstrC joins in...
        push    hl
        push    de
        push    ix
        push    iy
            ; compute the offsets
        push    hl              ; set aside the string pointer
        call    xy2offsAC
        push    hl
        pop     ix              ; move the offset into ix (char ram)
        push    hl
        pop     iy              ; move the offset into iy (color ram)
        ld      de, #(vidram)   ; base of video ram
        add     ix, de          ; set IX to appropriate location in vid ram
        ld      de, #(colram)   ; base of color ram
        add     iy, de          ; set IY to appropriate location in color ram
            ; prep for the loop
        pop     hl
        ld      b, (hl)         ; b is the number of bytes (pascal string)
        inc     hl              ; HL points to the text now
.pstra1:
            ; loop for each character
        ld      c, (hl)         ; c = character
        ld      (ix), c         ; vidram[b+offs] = character
        ld      (iy), a         ; colram[b+offs] = color
            ; adjust pointers
        inc     hl              ; inc string location
        dec     ix              ; dec char ram pointer
        dec     iy              ; dec color ram pointer
        djnz    .pstra1         ; dec b, jump back if not done
            ; restore registers
        pop     iy
        pop     ix
        pop     de
        pop     hl
        pop     bc
            ; return
        ret

        ;; putstrB - get the vid/color buffer offset of the X Y coordinates
        ;               in      hl      pointer to the string (asciz)
        ;               in      b       x position
        ;               in      c       y position
        ;               in      a       color
        ;               out     -
        ;               mod     -
        offsadd = -32
putstrB:
            ; set aside registers
        push    hl
        push    bc
        push    de
        push    ix
        push    iy
        push    hl
            ; compute the offsets
        call    xy2offsB        ; hl = core offset
        push    hl
        pop     ix              ; move the offset into ix (char ram)
        push    hl
        pop     iy              ; move the offset into iy (color ram)
        ld      de, #(vidram)   ; base of video ram
        add     ix, de          ; set IX to appropriate location in vid ram
        ld      de, #(colram)   ; base of color ram
        add     iy, de          ; set IY to appropriate location in color ram
            ; prep for the loop
        pop     hl
        ld      b, (hl)         ; b is the number of bytes (pascal string)
        inc     hl              ; HL points to the text now
        ld      de, #offsadd    ; set up the column offset
.pstrb1:
            ; loop for each character
        ld      c, (hl)         ; c = character
        ld      (ix), c         ; vidram[b+offs] = character
        ld      (iy), a         ; colram[b+offs] = color
            ; adjust pointers
        inc     hl              ; inc string location
        add     ix, de          ; add in offset into char ram
        add     iy, de          ; add in offset into color ram
        djnz    .pstrb1         ; dec b, jump back if not done
            ; restore registers
        pop     iy
        pop     ix
        pop     de
        pop     bc
        pop     hl
            ; return
        ret

        ;; putstrC - get the vid/color buffer offset of the X Y coordinates
        ;               in      hl      pointer to the string (asciz)
        ;               in      b       x position
        ;               in      c       y position
        ;               in      a       color
        ;               out     -
        ;               mod     -
putstrC:
            ; set aside registers
        push    bc
        inc     c               ; just change indexing 0,1 into 2,3
        inc     c
        jp      .psChook        ; jump back into putstrA



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; semaphore control

; lock semaphore
    ;; semalock - lock a semaphore
        ;               in      a       which semaphore to lock
        ;               out     -
        ;               mod     -
semalock:
            ; set aside registers
        push    af
        push    bc
        push    hl
            ; set up the address
        and     #0x0f           ; limit A to 0..15
        ld      c, a            ; c is the current semaphore number
        ld      b, #0x00        ; make sure that b=0   (bc = 0x00SS)
        ld      hl, (semabase)  ; hl = base address
        add     hl, bc          ; hl = address of this semaphore
.sl2:
        bit     1, (hl)
        jr      NZ, .sl2        ; while it's set, loop
            ; set the bit
        set     1, (hl)         ; lock the semaphore
            ; restore registers
        pop     hl
        pop     bc
        pop     af
            ; return
        ret

; release semaphore
    ;; semarel - release a semaphore
        ;               in      a       which semaphore to release
        ;               out     -
        ;               mod     -
semarel:
            ; set aside registers
        push    af
        push    bc
        push    hl
            ; set up the address
        and     #0x0F           ; limit A to 0..15
        ld      c, a            ; c is the current semaphore number
        ld      b, #0x00        ; b=0   (bc = 0x000S)
        ld      hl, (semabase)  ; hl = base address
        add     hl, bc          ; hl = address of this semaphore
            ; clear the semaphore
        res     1, (hl)         ; clear the bit
            ; restore registers
        pop     hl
        pop     bc
        pop     af
            ; return
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; task exec, kill, and sleep routines

    ;; execstart - starts up a new task
        ;               in      E       task number to start
        ;               in      D       task slot to use (0..3)
        ;               out     -
        ;               mod     -
execstart:
            ; save registers we're using
        push    af
        push    de
        push    bc
        push    hl
            ; limit E (task) to 127
        res     7, e            ; limit task number to 127
            ; limit D (slot)
        ld      a, d            ; a=d
        and     #0x03           ; slot is 0,1,2, or 3
        ld      c, a            ; c=a
        ld      b, #0x00        ; b=0x00, bc = 0x000S
            ; set the control value
        ld      hl, #(taskctrl) ; set up the control register
        add     hl, bc          ; hl = base + offset
        ld      (hl), e         ; taskctrl[d] = e
            ; restore the registers     
        pop     hl
        pop     bc
        pop     de
        pop     af
            ; return
        ret

    ;; execkill - kills a running task 
        ;               in      D       task slot to kill 
        ;               out     -
        ;               mod     -
execkill:
            ; save registers we're using
        push    af
        push    de
        push    bc
        push    hl
            ; limit D (slot) and shove it into C
        ld      a, d            ; a=d
        and     #0x03           ; slot is 0,1,2, or 3
        ld      c, a            ; c=a
        ld      b, #0x00        ; b=0x00,  bc = 0x000S
            ; set the control value
        ld      hl, #(taskctrl) ; set up the control register
        add     hl, bc          ; hl = base + offset
        ld      (hl), #(killslot)       ; taskctrl[d] = KILL!
            ; restore the registers     
        pop     hl
        pop     bc
        pop     de
        pop     af
            ; return
        ret


        ;; sleep - wait a specified number of ticks
        ;               in      bc      number of ticks to wait
        ;               out     -
        ;               mod     -
sleep:
            ; set side some registers
        push    bc
        push    af
        push    hl
            ;; this is where we would set the flag for
            ;; the exec system to relinquish the rest of our time.
            ; compute the timeout into BC
        ld      hl, (timer)     ; hl = timer
        add     hl, bc          ; hl += ticks to wait
        push    hl              ; bc = 
        pop     bc              ;    = hl
.slp:
            ; loop until the timeout comes
        ld      hl, (timer)     ; hl = current time
        sbc     hl, bc          ; set flags
        jp      M, .slp         ; if (HL >= BC) then JP .slp2
            ; restore the registers
        pop     hl
        pop     af
        pop     bc
            ; return
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The tasks

; task list -- list of all available tasks
        ; list of all tasks available, null terminated
tasklist:
        .word t0header
        .word t1header
        .word t2header
        .word t3header
        .word 0x0000


;;;;;;;;;;;;;;;;;;;;
; task number 0
        ;; Task 0 - PTUI
; constants 
        ; GUI constants
    ; cursor and wallpaper
        PcursorS        =    0  ; sprite 0 for the cursor
        PcursorC        =    9  ; color 9 for the cursor

        CrosshFS        =    1  ; crosshair for window movement
        CrosshC         = 0x09  ; crosshair color

        PwpS            =  162  ; wallpaper sprite
        PwpC            = 0x10  ; wallpaper color 0x13- blues

        LlamaC          = 0x10  ; llama color  (might be the same as PwpC above)
        LlamaS          = 0x7b  ; base of llama tile
        LlamaFS         =    2  ; llama floating sprite
        CprtC           = 0x14  ; copyright color 11
    ; flags
        F_Noframe       =    1  ; no frame in render (hard flag)
        F_Frame         =    2  ; frame in render (hard flag)

        F_Dirty         =    1  ; frame needs redraw (soft flag)
        F_Focus         =    2  ; frame is capturing focus currently
    ; -- frame widgets --
        ; close
        PcloseS         =  128  ; close widget sprite
        PcloseCS        =    1  ; close widget selected color (5)
        PcloseCU        = 0x1e  ; close widget unselected color

        ; raise
        PraiseS         =  131  ; raise widget sprite
        PraiseCS        =    1  ; raise widget selected color (5)
        PraiseCU        =  0xc  ; raise widget unselected color

    ; -- frame ornaments --
        PfrmTSel        =    9  ; dragbar text selected color 0x14 0xb
        PfrmTUns        =    1  ; dragbar text unselected color

        PfrmCSel        =    1  ; frame selected color
        PfrmCUns        = 0x1e  ; frame unselected color

        ; bottom corners
        PSWcornS        =  138  ; southwest corner
        PSEcornS        =  139  ; southeast corner

        ; top corners
        PNWcornS        =    1  ; northwest corner 140
        PNEcornS        =    1  ; northeast corner 141

        ; top bar
        PfN_W           =  129  ; top left      (145 or 129)
        PfN_N           =   32  ; top center    (146 or 32)
        PfN_E           =  130  ; top right     (147 or 130)

        ; left bar
        PfW_N           =  132  ; left top
        PfW_W           =  133  ; left center
        PfW_S           =  134  ; left bottom

        ; right bar
        PfE_N           =  135  ; right top
        PfE_E           =  136  ; right center
        PfE_S           =  137  ; right bottom

        ; bottom bar
        PfS_W           =  142  ; bottom left
        PfS_S           =  143  ; bottom center
        PfS_E           =  144  ; bottom right
    ; widgets
        PwC             =    1  ; generic widget color
        PwBGS           =  127  ; window background sprite

        ; button
        PwbLuS          =  148  ; [    button left unselected sprite
        PwbRuS          =  149  ;    ] button right unselected sprite

        ; selected button
        PwbLsS          =  150  ; [[   button left selected sprite
        PwbRsS          =  151  ;   ]] button right selected sprite

        ; checkbox
        PwcuS           =  152  ; [ ] checkbox unselected sprite
        PwcsS           =  153  ; [X] checkbox selected sprite

        ; radio box
        PwruS           =  154  ; ( ) radio unselected sprite
        PwrsS           =  155  ; (X) radio selected sprite

        ; slider
        PwsnS           =  156  ; === slider notch sprite
        PwsbS           =  157  ; =|= slider bar sprite

        ; progress bar
        PwpoS           =  158  ;     progress bar open sprite
        PwpfS           =  159  ; ### progress bar filled sprite

        ; spin
        PwHsS           =  160  ; <>  horizontal spin controller
        PwVsS           =  161  ; ^v  vertical spin controller
        ; Widget Types (for the frame-widget table)

        W_End           =    0  ; end of the widget list
        W_Frame         =    1  ; window frame (needs to be first)

         ; frame flags:
         FF_Border      =    1  ; use a border on the frame
         FF_NClose      =    2  ; no close button
         FF_NRaise      =    4  ; no raise button

        W_MButton       =    2  ; momentary button
        W_SButton       =    3  ; sticky button

        W_Radio         =    4  ; radio button (flags is the group number)
        W_Check         =    5  ; check button

        W_SText         =    6  ; static text  (text is the idx of a string)
        W_DText         =    7  ; dynamic text (data is idx of ram)

        W_DInt          =    8  ; dynamic integer (data is idx in the ram)

        W_HSlider       =    9  ; horizontal slider
        W_VSlider       =   10  ; vertical slider

        W_HSpin         =   11  ; horizontal spin
        W_VSpin         =   12  ; vertical spin

; header
t0header:
        .byte   0xc9, 0x4a, 0x73, 0x4c  ; cookie
        .byte   0x01                    ; version
        .byte   0x04                    ; requested timeslices
        .word   t0name                  ; name 
        .word   t0process               ; process function

t0name:
        .byte   6                       ; strlen
        .asciz  "Task 0"                ; name

; routines
t0process:
        ld      hl, #(colram)   ; base of color ram
        ld      a, #0x01        ; clear the screen to 0x00
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN         ; do it.

t0p2:
        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x41        ; 'A'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x42        ; 'B'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x43        ; 'C'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        jp      t0p2
        halt


;;;;;;;;;;;;;;;;;;;;
; task number 1
        ;; Task 1 - TBD
; header
t1header:
        .byte   0xc9, 0x4a, 0x73, 0x4c  ; cookie
        .byte   0x01                    ; version
        .byte   0x04                    ; requested timeslices
        .word   t1name                  ; name
        .word   t1process               ; process function

t1name:
        .byte   6                       ; strlen
        .asciz  "Task 1"                ; name

; routines
t1process:
        ld      hl, #(colram)   ; base of color ram
        ld      a, #0x01        ; clear the screen to blue
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(colram)   ; base of color ram
        ld      a, #0x09        ; clear the screen to red
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        jp      t1process
        halt


;;;;;;;;;;;;;;;;;;;;
; task number 2
        ;; Task 2 - TBD
; header
t2header:
        .byte   0xc9, 0x4a, 0x73, 0x4c  ; cookie
        .byte   0x01                    ; version
        .byte   0x04                    ; requested timeslices
        .word   t2name                  ; name
        .word   t2process               ; process function

t2name:
        .byte   6                       ; strlen
        .asciz  "Task 2"                ; name

; routines
t2process:
        ld      hl, #(colram)   ; base of color ram
        ld      a, #0x01        ; clear the screen to 0x00
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x61        ; 'a'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x62        ; 'b'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x63        ; 'c'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        jp      t2process
        halt


;;;;;;;;;;;;;;;;;;;;
; task number 3
        ;; Task 3 - TBD
; header
t3header:
        .byte   0xc9, 0x4a, 0x73, 0x4c  ; cookie
        .byte   0x01                    ; version
        .byte   0x04                    ; requested timeslices
        .word   t3name                  ; name
        .word   t3process               ; process function

t3name:
        .byte   6                       ; strlen
        .asciz  "Task 3"                ; name

; routines
t3process:
        ld      hl, #(colram)   ; base of color ram
        ld      a, #0x01        ; clear the screen to 0x00
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x78        ; 'X'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x79        ; 'Y'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        ld      hl, #(vidram)   ; base of video ram
        ld      a, #0x7a        ; 'Z'
        ld      b, #0x04        ; 256*4 = 1k
        call    memsetN

        jp      t3process
        halt


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The Data

; splash strings
llama1:
        .byte   0x02, (LlamaS+0), (LlamaS+1)    ; first row of llama
llama2:
        .byte   0x02, (LlamaS+2), (LlamaS+3)    ; second row of llama
cprt1:
        .byte   0x10
        .ascii  " Alpaca OS v0.8 "
cprt2:
        .byte   0x14
        .ascii  "/2003 Jerry Lawrence"
cprt3:  
        .byte   0x18
        .ascii  "alpacaOS@umlautllama.com"

; Some tables for the Task Switcher
            ; table of stack/user RAM usage (stacks, ram)
stacklist:
        .word   stack0
        .word   stack1
        .word   stack2
        .word   stack3
        .word   stackbottom

; The sine table
.sinetab:
        .byte   0x80, 0x83, 0x86, 0x89, 0x8c, 0x8f, 0x92, 0x95
        .byte   0x99, 0x9c, 0x9f, 0xa2, 0xa5, 0xa8, 0xab, 0xae
        .byte   0xb1, 0xb4, 0xb6, 0xb9, 0xbc, 0xbf, 0xc2, 0xc4
        .byte   0xc7, 0xc9, 0xcc, 0xcf, 0xd1, 0xd3, 0xd6, 0xd8
        .byte   0xda, 0xdc, 0xdf, 0xe1, 0xe3, 0xe5, 0xe7, 0xe8
        .byte   0xea, 0xec, 0xee, 0xef, 0xf1, 0xf2, 0xf3, 0xf5
        .byte   0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfb, 0xfc, 0xfd
        .byte   0xfd, 0xfe, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff
        .byte   0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0xfe, 0xfd
        .byte   0xfd, 0xfc, 0xfb, 0xfb, 0xfa, 0xf9, 0xf8, 0xf7
        .byte   0xf5, 0xf4, 0xf3, 0xf1, 0xf0, 0xee, 0xed, 0xeb
        .byte   0xe9, 0xe8, 0xe6, 0xe4, 0xe2, 0xe0, 0xde, 0xdb
        .byte   0xd9, 0xd7, 0xd5, 0xd2, 0xd0, 0xcd, 0xcb, 0xc8
        .byte   0xc6, 0xc3, 0xc0, 0xbd, 0xbb, 0xb8, 0xb5, 0xb2
        .byte   0xaf, 0xac, 0xa9, 0xa6, 0xa3, 0xa0, 0x9d, 0x9a
        .byte   0x97, 0x94, 0x91, 0x8e, 0x8b, 0x87, 0x84, 0x81
        .byte   0x7e, 0x7b, 0x78, 0x74, 0x71, 0x6e, 0x6b, 0x68
        .byte   0x65, 0x62, 0x5f, 0x5c, 0x59, 0x56, 0x53, 0x50
        .byte   0x4d, 0x4a, 0x47, 0x44, 0x42, 0x3f, 0x3c, 0x39
        .byte   0x37, 0x34, 0x32, 0x2f, 0x2d, 0x2a, 0x28, 0x26
        .byte   0x24, 0x21, 0x1f, 0x1d, 0x1b, 0x19, 0x17, 0x16
        .byte   0x14, 0x12, 0x11, 0x0f, 0x0e, 0x0c, 0x0b, 0x0a
        .byte   0x08, 0x07, 0x06, 0x05, 0x04, 0x04, 0x03, 0x02
        .byte   0x02, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
        .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x02
        .byte   0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09
        .byte   0x0a, 0x0c, 0x0d, 0x0e, 0x10, 0x11, 0x13, 0x15
        .byte   0x17, 0x18, 0x1a, 0x1c, 0x1e, 0x20, 0x23, 0x25
        .byte   0x27, 0x29, 0x2c, 0x2e, 0x30, 0x33, 0x36, 0x38
        .byte   0x3b, 0x3d, 0x40, 0x43, 0x46, 0x49, 0x4b, 0x4e
        .byte   0x51, 0x54, 0x57, 0x5a, 0x5d, 0x60, 0x63, 0x66
        .byte   0x6a, 0x6d, 0x70, 0x73, 0x76, 0x79, 0x7c, 0x7f

; The XY-offset table
.scroffs:
        .word   0x03a0, 0x0380, 0x0360, 0x0340
        .word   0x0320, 0x0300, 0x02e0, 0x02c0
        .word   0x02a0, 0x0280, 0x0260, 0x0240
        .word   0x0220, 0x0200, 0x01e0, 0x01c0
        .word   0x01a0, 0x0180, 0x0160, 0x0140
        .word   0x0120, 0x0100, 0x00e0, 0x00c0
        .word   0x00a0, 0x0080, 0x0060, 0x0040

; The Region A and C offset table
.acoffs:
        .word   0x03dd          ; Region A row 'E' -> AC row 0
        .word   0x03fd          ; Region A row 'F' -> AC row 1
        .word   0x001d          ; Region C row 'A' -> AC row 2
        .word   0x003d          ; Region C row 'B' -> AC row 3

