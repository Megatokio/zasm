#!/usr/local/bin/zasm --s19 --date=20200412 -o original/

; test target rom
; test that adresses are stored as expected

#target rom
#data DATA,$8000
foo1	defs 4
foo2	defs 2

#code CODE1,$100,$10
	defb "CODE1"
	defs 4
	ret

#code CODE2,$200,$10
	defb "CODE2"
	defs 4
	ret

#code CODE0,$000
	defb "CODE0"
	defs 4
	ret

end
