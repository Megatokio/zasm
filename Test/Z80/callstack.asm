#!/usr/local/bin/zasm -o original/

        ORG $0000

_STACK_SIZE     DEFL    0
_PARAM_COUNT_0  DEFL    0               ;Redefinable labels initialization


;Adds the content of &reg to the stack and increment the _PARAM_COUNT_0 label.
                MACRO	_ADD_PARAM &reg
                PUSH	&reg
_PARAM_COUNT_0  DEFL	{_PARAM_COUNT_0+1}
                ENDM

;Adds a litteral 16 bits parameter to the stack then increment the
;_PARAM_COUNT_0 label. Register values are preserved.
                MACRO   _ADD_LPARAM &lit
                PUSH	HL
                LD      HL,&lit
                EX		(SP),HL
_PARAM_COUNT_0  DEFL    {_PARAM_COUNT_0+1}
                ENDM

;Macro that calls a procedure &proc. This macro cleans the stack from the
;parameters added with _ADD_PARAM or ADD_LPARAM. Register HL and DE may be
;changed if the subroutine returns respectively a 16 or 32 bits value.
                MACRO   _CALL &proc
                _PUSH_STACK
                CALL    &proc
                _POP_STACK
                _CLEAN_PARAMS {_PARAM_COUNT_0}
_PARAM_COUNT_0  DEFL    0
                ENDM

;Increments the _STACK_SIZE label and shift _PARAM_COUNT_# labels value to
;_PARAM_COUNT_#+1, up to _PARAM_COUNT_{STACK_SIZE}, then save all the Z80
;registers on the stack.
                MACRO   _PUSH_STACK
_STACK_SIZE     DEFL    {_STACK_SIZE+1}
                _SHIFT_STACK {_STACK_SIZE+1}
                CALL    _PUSH
                ENDM

;Shift _PARAM_COUNT_# values up the stack.
                MACRO   _SHIFT_STACK &cnt
                IF &cnt > 0
_PARAM_COUNT_{&cnt} DEFL _PARAM_COUNT_{&cnt-1}
_PARAM_COUNT_{&cnt-1} DEFL 0
                _SHIFT_STACK {&cnt-1}
                ENDIF
                ENDM

;Shift _PARAM_COUNT_# down the stack and then restores Z80 registers. Then
;decrement _STACK_SIZE label.
                MACRO   _POP_STACK
                _UNSHIFT_STACK _STACK_SIZE
_STACK_SIZE     DEFL    {_STACK_SIZE-1}
                CALL    _POP
                ENDM

;Shift _PARAM_COUNT_# values down the stack.
                MACRO   _UNSHIFT_STACK &cnt
                IF      &cnt > 0
_PARAM_COUNT_{&cnt-1} DEFL _PARAM_COUNT_{&cnt}
_PARAM_COUNT_{&cnt}   DEFL 0
                _UNSHIFT_STACK {&cnt-1}
                ENDIF
                ENDM


;Macro that cleans &count parameters from the stack.
                MACRO   _CLEAN_PARAMS &cnt
                IF 		&cnt > 0
                EX      (SP),HL
                POP     HL
                _CLEAN_PARAMS {&cnt-1}
                ENDIF
                ENDM


;Loads the register &reg with the parameter at index &idx
;Since IY is used to get at parameters, its not possible to load
;a parameter into IY using this macro.
                MACRO   _GET_PARAM &reg, &idx
                LD      IY,14
                ADD     IY,SP
                LD      &reg, (IY+{&idx*2})
                ENDM


;Return the content of &reg1 at the stack position of HL. The content of IY
;can not be returned using this macro.
                MACRO   _RET_HL &reg1
                LD      IY,0
                ADD     IY,SP
                LD      (IY+12),&reg1
                RET
                ENDM



;Return the content of &reg1 at the stack position of HL and the
;content of &reg2 at the DE stack position. The content of IY canot
;be returned by this macro.
                MACRO   _RET_HLDE &reg1, &reg2
                LD      IY,0
                ADD     IY,SP
                LD      (IY+12),&reg1
                LD      (IY+10),&reg2
                RET
                ENDM


;Save all registers
_PUSH:          EX      (SP),HL
		PUSH    DE
		PUSH    BC
                PUSH    AF
                PUSH    IY
                PUSH    IX
                PUSH    HL
                RET


;restore all registers
_POP:           POP     HL
                POP     IX
                POP     IY
                POP     AF
                POP     BC
                POP     DE
                EX      (SP),HL
                RET


; *** Actual test starts here ***

        _ADD_LPARAM 6		;param 2
        _ADD_LPARAM 5		;param 1
        _CALL	EXP

LOOP:   JR      LOOP


;Make parameter 1 exponent parameter 2. I.E. Param1 is the base and param2
;is the exponent. Returns value in HL.
EXP:	_GET_PARAM DE,1	;base
		_GET_PARAM HL,1 ;initialize HL with base
		_GET_PARAM BC,2	;exponent
EXP_1:	_ADD_PARAM DE
		_ADD_PARAM HL
		_CALL	MUL
		DEC		BC
		JR		NZ,EXP_1
		_RET_HL HL


;Multiply parameter 1 with parameter 2. Returns result in HL.
MUL:    _GET_PARAM DE,1
        _GET_PARAM BC,2
        LD      HL,0
MUL_1:  ADD     HL,DE
        DEC     BC
        JR      NZ,MUL_1
        _RET_HL HL
