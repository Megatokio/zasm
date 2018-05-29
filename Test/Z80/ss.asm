org 50h
ld a,00000000
out (71h),a
out (71h),a
out (71h),a
ld a,40h
out (71h),a
ld a,0dah
out (71h),a
ld a,37h
out (71h),a
s: in a,(71h)
rrca
jr nc,s
ld a,(00010000)
out (70h),a
_r: in a,(71h)
rrca
rrca
jr nc,_r
in a,(70h)
ld (00010000),a
end