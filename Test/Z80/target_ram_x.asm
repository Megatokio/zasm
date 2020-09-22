#!/usr/local/bin/zasm -x -o original/

; test target ram
; test that adresses are stored as expected

#target ram
#data DATA,$8000
foo1	defs 4
foo2	defs 2

#code CODE1,$100,$10
	defb "CODE1"
	defs 4
	ret

#code CODE2,$200
	defb "CODE2"
	defs 4
	ret

#code CODE0,$000
	defb "CODE0"
	defs 4
	ret

#code CODE3,$100,$10
	defb "CODE3"
	defs 4
	jp	 0x0066			; last byte = 0x00

#code CODE4,$200,$10
	defb "CODE4"
	defs 4				; last 4 bytes = 0x00

#code CODE5,$000,$10
	defb "CODE5"
	defs 4
	ret
	defs	2,0xff
	defs	2,0x00		; last 2 bytes = 0x00

end
