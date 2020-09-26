#!/usr/local/bin/zasm -o original/
#target	ram
;		NAME		START	SIZE	FLAGS
#code	KERNEL,		0x0008,	0xF0


head    MACRO   #name
	DB #name
        ENDM

	DB	'U<'
	DB	'U>'
	DB	'<U'
	DB	'>U'
	DB	'><'
	DB	'<>'
	DB	'"U'

	head	'U<'
	head	'U>'
	head	'<U'
	head	'>U'
	head	'><'
	head	'<>'
	head	'"U'

#end
