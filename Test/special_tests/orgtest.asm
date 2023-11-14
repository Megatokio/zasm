#!/usr/local/bin/zasm --reqcolon -o original/

;; Initialize assembly variables

CELLL   = 2
_LINK   = 0                                     ;force a null link
_NAME   = $3FFF                                 ;initialize name pointer
_CODE   = 0                                     ;initialize code pointer
_USER   = 4*CELLL                               ;first user variable offset
CALLL   = $1234
LISTL   = $5678

;; Define assembly macros

;       Adjust an address to the next cell boundary.

ALIGN  MACRO
        ;EVEN                                    ;;for 16bit systems
        ENDM

;       Compile a code definition header.

CODE   MACRO   LEX,NAME,LABEL
        ALIGN                            ;;force to cell boundary
LABEL:                                    ;;assembly label
        _CODE   = $                       ;;save code pointer
        _LEN    = (LEX AND 01FH)/CELLL    ;;string cell count, round down
        _NAME   = _NAME-((_LEN+3)*CELLL)  ;;cell boundary, downward

        DW      _CODE   ; debug
        DW      _NAME   ; debug

ORG     _NAME                             ;;set name pointer
        DW       _CODE,_LINK              ;;token pointer and link
        _LINK   = $                       ;;link points to a name string
        
        DW      _LINK   ; debug
        
        DB      LEX,NAME                  ;;name string
ORG     _CODE                             ;;restore code pointer
        ENDM

;       Compile a colon definition header

COLON  MACRO   LEX,NAME,LABEL
        CODE   LEX,NAME,LABEL
        DW      CALLL                     ;;align to cell boundary******
        DW      LISTT                     ;;include CALL doLIST******
        ENDM

;       Compile a user variable header.

USER   MACRO   LEX,NAME,LABEL
        CODE   LEX,NAME,LABEL
        DW      CALLL                     ;;align to cell boundary******
        DW      LISTT                     ;;include CALL doLIST******
        DW      DOUSE,_USER               ;;followed by doUSER and offset
        _USER   = _USER+CELLL             ;;update user area offset
        ENDM

;       Compile an inline string.

_D_      MACRO   FUNCT,STRNG
        DW      FUNCT                     ;;function
        _LEN    = $                       ;;save address of count byte
        DB      0,STRNG                   ;;count byte and string
        _CODE   = $                       ;;save code pointer

        DW      _CODE   ; debug

ORG     _LEN                              ;;point to count byte
        DB      _CODE-_LEN-1              ;;set count
ORG     _CODE                             ;;restore code pointer
        ALIGN
        ENDM




ORG     0

        CODE    4, "Fred", FRED
        
        CODE    3, "Joe", JOE
        
        _D_     StringHandler, "Hello World"
        
        
StringHandler:
        NOP