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

end
