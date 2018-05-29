#target rom
#code 0,$4000

;include ti83asm.inc

;org 9327h

;call _CLRLCDFULL
call 0x4755
ret

#end
