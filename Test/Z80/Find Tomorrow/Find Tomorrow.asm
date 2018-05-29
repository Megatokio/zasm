.nolist
#include "mt3notes.inc"
.list
	.org $0000
	.db $BB,$6D
	.db $C9
	.db $31,$80
	.db 0,1,4

Start:

title:	.db "",0
artist:	.db "",0
album:	.db "",0

tempo = 120

song:
	playsection(all)
	endsong

all:
	note(c2,ab0,c2,ab0,2500/tempo)
	note(rest,ab0,rest,ab0,1250/tempo)
	note(rest,rest,rest,rest,1250/tempo)
	note(d2,bb0,d2,bb0,2500/tempo)
	note(rest,bb0,rest,bb0,1250/tempo)
	note(rest,rest,rest,rest,1250/tempo)
	note(d2,c1,d2,c1,1875/tempo)
	note(eb2,c1,eb2,c1,1875/tempo)
	note(g1,c1,g1,c1,3750/tempo)
	note(rest,rest,rest,rest,1250/tempo)
	note(c2,rest,c2,rest,625/tempo)
	note(bb1,rest,bb1,rest,625/tempo)
	note(ab1,rest,ab1,rest,2500/tempo)
	note(eb2,rest,eb2,rest,2500/tempo)
	note(d2,rest,d2,rest,1875/tempo)
	note(eb2,rest,eb2,rest,1875/tempo)
	note(bb1,rest,bb1,rest,1250/tempo)
	note(c2,rest,c2,rest,5000/tempo)
	note(rest,rest,rest,rest,5000/tempo)
	note(c2,ab0,c2,ab0,2500/tempo)
	note(rest,ab0,rest,ab0,1250/tempo)
	note(f2,rest,f2,rest,1250/tempo)
	note(d2,bb0,d2,bb0,2500/tempo)
	note(rest,bb0,rest,bb0,1250/tempo)
	note(bb1,rest,bb1,rest,1250/tempo)
	note(d2,c1,d2,c1,1875/tempo)
	note(eb2,c1,eb2,c1,1875/tempo)
	note(g2,c1,g2,c1,3750/tempo)
	note(rest,rest,rest,rest,2500/tempo)
	note(ab2,ab0,ab2,ab0,1875/tempo)
	note(g2,ab0,g2,ab0,1875/tempo)
	note(f2,rest,f2,rest,1250/tempo)
	note(eb2,eb0,eb2,eb0,2500/tempo)
	note(d2,eb0,d2,eb0,1250/tempo)
	endsection

.end
END
