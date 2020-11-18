
; ----------------
;    K2 BASIC
; ----------------

; this file should be included twice:
; 1st time will define the macros and put some code in area ROM
; 2nd time will resolve missing helper functions

#if !defined(RESOLVE)
RESOLVE = 0
DEFINE  = 1
#else
RESOLVE = 1
DEFINE  = 0
#endif

; helpers are stored in:
; .area ROM:  code & const data (romable)
; .area RAM:  code & data (self-modifying)
; .area ROP:  ROP coded functions. the SP will point into this area.
;			  must be in RAM and words overwritten by interrupts must be restored.
; .area DATA: zero-initialized data



; ----------------------------------
; return from ROP coded function
;
; the ROP engine has no stack, therefore return addresses
; are stored in dedicated variables, one for each function level:
; level0 calls no other functions, level1 only level0 functions and so on.
; NOTE: these functions are NOT reentrant!

#if DEFINE

.macro PROC_START
	ld	(return + 1 + level*4),sp
	ld	sp,$+4
	ret
.endm

.macro RETURN
	.dw return + level*4
.endm

.area RAM
return::
	ld sp,0 \ ret  	; level0 -- address set at function entry
	ld sp,0 \ ret  	; level1
	ld sp,0 \ ret  	; level2
	ld sp,0 \ ret  	; ...
	ld sp,0 \ ret
	ld sp,0 \ ret
	ld sp,0 \ ret
	ld sp,0 \ ret
	ld sp,0 \ ret
	ld sp,0 \ ret  	; level9

#endif


; ----------------------------------
; local variables and rop coded getter and setter
; to be placed in a library

#if RESOLVE

.macro DEFINE_LVAR &NAME

; setters and getters for local int16 variable '&NAME':

.area ROM
.if required(ld_&NAME_hl)
ld_&NAME_hl::	ld (&NAME),hl \ ret
.endif
.if required(ld_&NAME_de)
ld_&NAME_de::	ld (&NAME),de \ ret
.endif
.if required(ld_&NAME_bc)
ld_&NAME_bc::	ld (&NAME),bc \ ret
.endif
.if required(ld_&NAME_ix)
ld_&NAME_ix::	ld (&NAME),ix \ ret
.endif
.if required(ld_&NAME_iy)
ld_&NAME_iy::	ld (&NAME),iy \ ret
.endif

	.if required(ld_hl_&NAME)
ld_hl_&NAME::	ld hl,(&NAME) \ ret
	.endif
.if required(ld_bc_&NAME)
ld_bc_&NAME::	ld bc,(&NAME) \ ret
.endif
.if required(ld_ix_&NAME)
ld_ix_&NAME::	ld ix,(&NAME) \ ret
.endif
.if required(ld_iy_&NAME)
ld_iy_&NAME::	ld iy,(&NAME) \ ret
.endif

.area RAM
.if required(ld_de_&NAME) || required(&NAME)
&NAME:: 		equ $+1
ld_de_&NAME::	ld de,0 \ ret			; <-- value set with setter
.endif

.endm

	DEFINE_LVAR int00	;level0, int variable #1
	DEFINE_LVAR int01
	DEFINE_LVAR int02
	DEFINE_LVAR int03
	DEFINE_LVAR int04
	DEFINE_LVAR int05
	DEFINE_LVAR int06
	DEFINE_LVAR int07

	DEFINE_LVAR int10
	DEFINE_LVAR int11
	DEFINE_LVAR int12
	DEFINE_LVAR int13
	DEFINE_LVAR int14
	DEFINE_LVAR int15
	DEFINE_LVAR int16
	DEFINE_LVAR int17

	DEFINE_LVAR int20
	DEFINE_LVAR int21
	DEFINE_LVAR int22
	DEFINE_LVAR int23
	DEFINE_LVAR int24
	DEFINE_LVAR int25
	DEFINE_LVAR int26
	DEFINE_LVAR int27

	DEFINE_LVAR int30
	DEFINE_LVAR int31
	DEFINE_LVAR int32
	DEFINE_LVAR int33
	DEFINE_LVAR int34
	DEFINE_LVAR int35
	DEFINE_LVAR int36
	DEFINE_LVAR int37

	DEFINE_LVAR int40
	DEFINE_LVAR int41
	DEFINE_LVAR int42
	DEFINE_LVAR int43
	DEFINE_LVAR int44
	DEFINE_LVAR int45
	DEFINE_LVAR int46
	DEFINE_LVAR int47

	DEFINE_LVAR int50
	DEFINE_LVAR int51
	DEFINE_LVAR int52
	DEFINE_LVAR int53
	DEFINE_LVAR int54
	DEFINE_LVAR int55
	DEFINE_LVAR int56
	DEFINE_LVAR int57

	DEFINE_LVAR int60
	DEFINE_LVAR int61
	DEFINE_LVAR int62
	DEFINE_LVAR int63
	DEFINE_LVAR int64
	DEFINE_LVAR int65
	DEFINE_LVAR int66
	DEFINE_LVAR int67

	DEFINE_LVAR int70
	DEFINE_LVAR int71
	DEFINE_LVAR int72
	DEFINE_LVAR int73
	DEFINE_LVAR int74
	DEFINE_LVAR int75
	DEFINE_LVAR int76
	DEFINE_LVAR int77

	DEFINE_LVAR int80
	DEFINE_LVAR int81
	DEFINE_LVAR int82
	DEFINE_LVAR int83
	DEFINE_LVAR int84
	DEFINE_LVAR int85
	DEFINE_LVAR int86
	DEFINE_LVAR int87

	DEFINE_LVAR int90
	DEFINE_LVAR int91
	DEFINE_LVAR int92
	DEFINE_LVAR int93
	DEFINE_LVAR int94
	DEFINE_LVAR int95
	DEFINE_LVAR int96
	DEFINE_LVAR int97

#endif


; define a local int16 variable with setters and getters:
; this is done by assigning the variable to an entry in the above DEFINE_LVARs
; type = int16 (default)
; 'level' must be defined
; 'num_lvars' must be defined and will be incremented
; macro LOCAL must be placed at the end of a function
; and it will only pull in those getters and setters which were actually used

#if DEFINE

.macro LOCAL &NAME

; local variable '&NAME':
num_lvars = num_lvars+1
_&NAME = int{level}{num_lvars}

.if required(ld_hl_&NAME)
ld_hl_&NAME = ld_hl_int{level}{num_lvars}
.endif
.if required(ld_de_&NAME)
ld_de_&NAME = ld_de_int{level}{num_lvars}
.endif
.if required(ld_bc_&NAME)
ld_bc_&NAME = ld_bc_int{level}{num_lvars}
.endif
.if required(ld_ix_&NAME)
ld_ix_&NAME = ld_ix_int{level}{num_lvars}
.endif
.if required(ld_iy_&NAME)
ld_iy_&NAME = ld_iy_int{level}{num_lvars}
.endif

.if required(ld_&NAME_hl)
ld_&NAME_hl = ld_int{level}{num_lvars}_hl
.endif
.if required(ld_&NAME_de)
ld_&NAME_de = ld_int{level}{num_lvars}_de
.endif
.if required(ld_&NAME_bc)
ld_&NAME_bc = ld_int{level}{num_lvars}_bc
.endif
.if required(ld_&NAME_ix)
ld_&NAME_ix = ld_int{level}{num_lvars}_ix
.endif
.if required(ld_&NAME_iy)
ld_&NAME_iy = ld_int{level}{num_lvars}_iy
.endif

.endm

#endif




; ==========================================
;                EXAMPLE
; ==========================================

#if 0

; -------------------------------------------
; int max ( int a, int b ) = a >= b ? a : b
; -------------------------------------------

#local
level = 0
num_lvars = 0

max::
	PROC_START
	.dw	ld_a_de		; store de -> a
	.dw	ld_b_hl		; store hl -> b
;	.dw	ld_de_a
;	.dw	ld_hl_b
	.dw	ge_cy		; built-in, no local variables in memory
	.dw	jp_cy, L1
	.dw	ld_hl_a
	RETURN
L1:	.dw	ld_hl_b
	RETURN

	LOCAL a
	LOCAL b

#endlocal


; -------------------------------------------
; int min ( int a, int b ) = a >= b ? b : a
; -------------------------------------------

#local
level = 0
num_lvars = 0

min::
	PROC_START
	.dw	ld_a_de		; store de -> a
	.dw	ld_b_hl		; store hl -> b
;	.dw	ld_de_a
;	.dw	ld_hl_b
	.dw	jp_lt
	.dw	ld_hl_b, L1
	RETURN
L1:	.dw	ld_hl_a
	RETURN

	LOCAL a
	LOCAL b

#endlocal

; -------------------------------------------
; int minmax ( int a, int n, int e ) = max(a,min(n,e))
; -------------------------------------------

#local
level = 1			; assuming that min and max are level0 functions
num_lvars = 0

minmax::
	PROC_START
	.dw	ld_a_bc		; todo: caller?
;	.dw	ld_n_de
;	.dw	ld_e_hl		; store hl -> e
;	.dw	ld_de_n
;	.dw	ld_hl_e
	.dw	min			; level0 function
	.dw	ld_de_a
	.dw	max			; level0 function
	RETURN

	LOCAL a
	LOCAL n
	LOCAL e

#endlocal

#endif ; ----- Example -----









