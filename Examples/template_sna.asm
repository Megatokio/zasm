; ================================================================
;   Example file with target 'sna'
;   NMI snapshot for ZX Spectrum 16k or 48k
;   Copyright  (c)  Günter Woigk 1994 - 2017
;                   mailto:kio@little-bat.de
; ================================================================


#target sna


; ---------------------------------------------------
;       .sna header: saved registers
; ---------------------------------------------------

#code HEAD, 0, 27
        defb    $3f             ; i
        defw    0               ; hl'
        defw    0               ; de'
        defw    0               ; bc'
        defw    0               ; af'

        defw    0               ; hl
        defw    0               ; de
        defw    0               ; bc
        defw    0               ; iy
        defw    0               ; ix

        defb    0<<2            ; bit 2 = iff2 (iff1 before nmi) 0=di, 1=ei
        defb    0,0,0           ; r,f,a
        defw    stackend        ; sp
        defb    1               ; irpt mode
        defb    7               ; border color: 0=black ... 7=white



; ---------------------------------------------------
;       contended ram: video ram & rarely used code
; ---------------------------------------------------

#code SLOW_RAM, 0x4000, 0x4000

pixels_start:   defs 0x1800
attr_start:     defs 0x300

code_start:
    ; define some rarely used machine code here
    ; e.g. initialization code

        jr      $


; ---------------------------------------------------
;       fast ram: frequently used code,
;       variables and machine stack
; ---------------------------------------------------

#code FAST_RAM, 0x8000, 0x8000

stackbot:   defs    0xfe
stackend:   defw    code_start  ; will be popped into pc when the emulator loads the .sna file


; define some variables here

; define some machine code here










