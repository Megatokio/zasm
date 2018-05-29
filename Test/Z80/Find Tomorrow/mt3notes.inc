#define note(l1,l2,r1,r2,time) .dw l1+(l2*256)\.dw r1+(r2*256)\.dw time
#define	endsection .dw 0,0,0
#define endsong .dw 0
#define playsection(section) .dw section-song

#define quarter			6400/tempo		;quarter note length
#define whole			quarter*4		;whole note length
#define half			quarter*2		;half note length
#define eighth			quarter/2		;eighth note length
#define sixteenth		quarter/4		;sixteenth note length
#define thirtysecond		quarter/8		;thirtysecond note length
#define sixtyfourth		quarter/16		;sixtyfourth note length

#define quarterd		quarter+eighth
#define wholed			whole+half
#define halfd			half+quarter
#define eighthd			eighth+sixteenth
#define sixteenthd		sixteenth+thirtysecond
#define thirtysecondd		thirtysecond+sixtyfourth


#define half3			whole/3			;half note triplets
#define quarter3		half/3			;quarter note triplets
#define eighth3			quarter/3		;eighth note triplets
#define sixteenth3		eighth/3		;sixteenth note triplets
#define thirtysecond3		sixteenth/3		;thirtysecond note triplets
#define sixtyfourth3		thirtysecond/3		;sixtyfourth note triplets

#define	c0	255
#define	cs0	242
#define	d0	228
#define	eb0	215
#define	e0	203
#define	f0	192
#define	fs0	181
#define	g0	171
#define	ab0	161
#define	a0	152
#define	bb0	144
#define	b0	136
#define	c1	128
#define	cs1	121
#define	d1	114
#define	eb1	108
#define	e1	102
#define	f1	96
#define	fs1	90
#define	g1	85
#define	ab1	81
#define	a1	76
#define	bb1	72
#define	b1	68
#define	c2	64
#define	cs2	60
#define	d2	57
#define	eb2	54
#define	e2	51
#define	f2	48
#define	fs2	45
#define	g2	43
#define	ab2	40
#define	a2	38
#define	bb2	36
#define	b2	34
#define	c3	32
#define	cs3	30
#define	d3	28
#define	eb3	27
#define	e3	25
#define	f3	24
#define	fs3	23
#define	g3	21
#define	ab3	20
#define	a3	19
#define	bb3	18
#define	b3	17
#define	c4	16
#define	cs4	15
#define	d4	14
#define	eb4	13
#define	e4	13
#define	f4	12
#define	fs4	11
#define	g4	11
#define	ab4	10
#define	a4	9
#define	bb4	9
#define	b4	8
#define	c5	8
#define	cs5	8
#define	d5	7
#define	eb5	7
#define	e5	6
#define	f5	6
#define	fs5	6
#define	g5	5
#define	ab5	5
#define	a5	5
#define	bb5	4
#define	b5	4
#define	c6	4
#define	cs6	4
#define	d6	4
#define	eb6	3
#define	e6	3
#define	f6	3
#define	fs6	3
#define	g6	3
#define	ab6	3
#define	a6	2
#define	bb6	2
#define	b6	2
#define	c7	2
#define	cs7	2
#define	d7	2
#define	eb7	2
#define	e7	2
#define	f7	1
#define	fs7	1
#define	g7	1
#define	ab7	1
#define	a7	1
#define	bb7	1
#define	b7	1
#define	rest	0

