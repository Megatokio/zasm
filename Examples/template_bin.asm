; ================================================================
;   Example source with target 'bin'
;   Copyright  (c)  Günter Woigk 1994 - 2017
;                   mailto:kio@little-bat.de
; ================================================================


; same as 'rom', except that the default fill byte for 'defs' et. al. is 0x00
; this example assumes that the code is loaded at address 0x8000 and that
; variables are stored at 0x5B00 upward, which may be used for the ZX Spectrum


#target bin


data_start  equ 0x5B00
code_start  equ 0x8000


#data   VARIABLES, data_start, 0x100

; define some variables here



#code   CODE, code_start

; define some code here

        jr  $

