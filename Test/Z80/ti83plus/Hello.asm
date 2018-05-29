.nolist
#include "ti83plus.inc"
#define    ProgStart    $9D95
.list
.org    ProgStart - 2
    .db    t2ByteTok, tAsmCmp
    b_call(_ClrLCDFull)
    ld    hl, 0
    ld    (PenCol), hl
    ld    hl, msg
    b_call(_PutS)            ; Display the text
    b_call(_NewLine)
    ret
msg:
    "Hello world!"
.end
.end