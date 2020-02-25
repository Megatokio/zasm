#!/usr/local/bin/zasm -o original/

        ORG $0000
        JP MAIN

;Save all registers
_PUSH:          EX      (SP),HL
                PUSH    DE
                PUSH    BC
                PUSH    AF
                PUSH    IY
                PUSH    IX
                PUSH    HL
                RET
                        
                        
;Restore all registers
_POP:           POP     HL
                POP     IX
                POP     IY
                POP     AF
                POP     BC
                POP     DE
                EX      (SP),HL
                RET




_PC             DEFL    0               ;Parameter counter


;Adds the content of &reg to the stack and increment the _PARAM_COUNT label.
                MACRO   _ADDRP &reg
                PUSH    &reg
_PC             DEFL    {_PC + 1}
                ENDM


;Adds a litteral 16 bits parameter to the stack then increment the
;_PARAM_COUNT label. Register values are preserved.
                MACRO   _ADDLP &lit
                PUSH    HL
                LD      HL,&lit
                EX      (SP),HL
_PC             DEFL    {_PC + 1}
                ENDM


;Macro that calls a procedure &proc. This macro cleans the stack from the
;parameters added with _ADDRP or ADDLP. Register HL and DE may be changed 
;if the subroutine returns respectively a 16(HL) or 32(DEHL) bits value.
                MACRO   _CALL &proc
_PC_&proc       DEFL    {_PC}
_PC             DEFL    0
                CALL    _PUSH
                CALL    &proc
                CALL    _POP
                _CLEANP _PC_&proc
                ENDM


;Recursive macro that cleans &cnt parameters from the stack.
                MACRO   _CLEANP &cnt
                IF &cnt > 0
                  EX      (SP),HL
                  POP     HL
                  _CLEANP {&cnt - 1}
                ENDIF
                ENDM


;Loads the register &reg with the parameter at index &idx
;Since IY is used to get at parameters, its not possible to load
;a parameter into IY using this macro. First parameter is at index 0.
                MACRO   _GETP &reg, &idx
                LD      IY,14
                ADD     IY,SP
                LD      &reg, (IY+{&idx * 2})
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
                MACRO   _RET_DEHL &reg1, &reg2
                LD      IY,0
                ADD     IY,SP
                LD      (IY+12),&reg1
                LD      (IY+10),&reg2
                RET
                ENDM


; *******************************
; *** Actual test starts here ***
; *******************************

MAIN:   _ADDLP  6                   ;add literal param 2
        _ADDLP  5                   ;add literal param 1
        _CALL   EXP

LOOP:   JR      LOOP


;Make parameter 1 exponent parameter 2. I.E. Param1 is the base and param2
;is the exponent. Returns value in HL.
EXP:    _GETP   DE,1                ;base
        _GETP   HL,1                ;initialize HL with base
        _GETP   BC,2                ;exponent
EXP_1:  _ADDRP  DE
        _ADDRP  HL
        _CALL   MUL
        DEC BC
        JR  NZ,EXP_1
        _RET_HL HL


;Multiply parameter 1 with parameter 2. Returns result in HL.
MUL:    _GETP   DE,1
        _GETP   BC,2
        LD      HL,0
MUL_1:  ADD     HL,DE
        DEC     BC
        JR      NZ,MUL_1
        _RET_HL HL


        END
