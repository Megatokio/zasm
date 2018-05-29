#!/usr/local/bin/zasm --reqcolon -o original/
org 16384

; only sort on 1st 2 of 5 bytes

di

sort:       ld hl,kprs_xx     ; 1st stroke of 5 byte
            ld de,kprs_xx+5   ; 2nd stroke of 5 byte

srtem:
            ld bc,5           ; amount to raise later
         push bc              ; store bc
            inc hl            ; first test MSB
            inc de            ; raise both adresses
            ld a,(de)         ; high adres MSB value  minus
            cp (hl)           ; low adres MSB value /  regA minus (hl)
; carry set by borrow of bit 7 ,only if (hl) is bigger
            dec hl            ; back to LSB before jump
            dec de            ; flags not touched
            jr c,swop         ; carry=1= wrong order

            ld a,(de)         ; high adres LSB value  minus
            cp (hl)           ; low adres LSB value   
            jr nc,good        ; carry=0= good sorted already
                              ; if high value = high adres do nothing

swop:                         ; exchange 5 byte, carry=1
           push hl
            ld hl,again       ; after swop check again
            set 0,(hl)        ; carry=1, again = true
           pop hl

            ld b,c            ; 5 byte to exchange
them:
            ld a,(de)         ;a=high
            ld c,a            ; c=high
            ld a,(hl)         ;a=low
            ld (de),a         ;high=a=low
            ld (hl),c         ;low=c=high
            inc hl
            inc de
            djnz them      
            ld c,b           ; b=0 c=0 hl & de already increased 5x
good:
            add hl,bc        ; raise lower adres +5 or +0
            ex de,hl
            add hl,bc        ; raise higher adres +5 or +0


;check end of buffer
         pop bc   ;= 5
           push hl  ;
            ld a,0xff
            cpir             ;check for mark off 0xff ff ff ff ff
           pop hl
            ex de,hl
            jr nz,srtem      ; if 1 then still buffer to check

; buffer fully checked 1 time
back:
            ld hl,again      ; need for a swop check?
            ld a,(hl)
            and a            ; z or nz flag
            ld a,0           ; b=0, no flags
            ld (hl),a        ; again=0, no flags
            jr nz,sort       ; a=ff, always ????


; under this line is for testing only
; make fake databuffer

quit: 
ei
ret

again:       defb 0
kprs_xx:     defs 45
            defs 5  ,0xff

end
