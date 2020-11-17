#!/ur/local/bin/zasm -o original/


.org 100h


	.align 16
	.db	"AAA "
.if 11 < 0x100
	.db "richtig "
.else
	.db "falsch "
.endif
	.db	" EEE"


	.align 16
	.db	"AAA "
.if 1100 < 0x100
	.db "falsch"
.else
	.db	"richtig"
.endif
	.db	" EEE"


.macro TEST &arg1
	.align 16
	.db	"AA "
.if &arg1 < 0x100
  .if &arg1<0
  	.db "arg < 0"
  .else
	.db "arg < 256"
  .endif
.else
	.db "arg >= 256"
.endif
	.db	" EE"

.endm

	TEST 1
	TEST 0
	TEST 255
	TEST 256
	TEST 3000
	TEST -20556



	.align 16
	.db "----------------"

	.if 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.elif 1
	.db	"richtig"
	.elif 1
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.else
	.db	"falsch"
	.endif

	.align 16
	.db "----------------"

	.if 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.elif 0
	.db	"falsch"
	.else
	.db	"richtig"
	.endif

	.align 16
	.db "----------------"

	.if 1
	  	.if 1
	  	.db	"richtig"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.else
	  	.if 1
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.endif

	.align 16
	.db "----------------"

	.if 1
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"richtig"
	  	.endif
	.else
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.endif

	.align 16
	.db "----------------"

	.if 0
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.else
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"richtig"
	  	.endif
	.endif

	.align 16
	.db "----------------"

	.if 0
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.else
	  	.if 0
	  	.db	"falsch"
	  	.elif 1
	  	.db	"richtig"
	  	.else
	  	.db	"falsch"
	  	.endif
	.endif

	.align 16
	.db "----------------"

	.if 0
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.else
	  	.if 1
	  	.db	"richtig"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.endif

	.align 16
	.db "----------------"

	.if 1
	  	.if 0
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"richtig"
	  	.endif
	.elif 1
	  	.if 1
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.else
	  	.if 1
	  	.db	"falsch"
	  	.elif 0
	  	.db	"falsch"
	  	.else
	  	.db	"falsch"
	  	.endif
	.endif




