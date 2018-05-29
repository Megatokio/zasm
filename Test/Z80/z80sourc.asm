#!/usr/local/bin/zasm -o original/
;***********************************
;*  Z80 Assembler program          *
;*  Thomas Scherrer                *
;*  scherrer@hotmail.com           *
;*  4/9  97                        *
;***********************************

#target rom
#data ram,$8000
;             .ORG    $8000          ; RAM VARIABELS

RAMSTART:    .DS     1              ; RAM start adresse (256 test adr)
INT_COUNTER: .DS     1              ; Interrupt-counter
SER_ON:      .DS     1              ; serial on/off
UARTFEJL:    .DS     1              ;
SER_BAUD:    .DS     1

;********************* HARDWARE IO ADR ************************************
; PIO 82C55 I/O
PIO1A:       .EQU    0              ; (INPUT)  IN 1-8
PIO1B:       .EQU    1              ; (OUTPUT) OUT TO LEDS
PIO1C:       .EQU    2              ; (INPUT)  
PIO1CONT:    .EQU    3              ; CONTROL BYTE PIO 82C55

; UART 16C550 SERIAL
UART0:       .EQU    8              ; DATA IN/OUT
UART1:       .EQU    9              ; CHECK RX
UART2:       .EQU    10             ; INTERRUPTS
UART3:       .EQU    11             ; LINE CONTROL
UART4:       .EQU    12             ; MODEM CONTROL
UART5:       .EQU    13             ; LINE STATUS
UART6:       .EQU    14             ; MODEM STATUS
UART7:       .EQU    15             ; SCRATCH REG.

DAC1:        .EQU    $20            ; 
DAC2:        .EQU    $21            ; 
ADC:         .EQU    $23            ;



;********************* CONSTANTS ****************************************
RAMTOP:      .EQU    $FFFF          ; 32Kb RAM   8000H-FFFFH

END:         .EQU    $FF            ; Mark END OF TEXT
NET_FREK:    .EQU    32             ; INTERRUP frekvens in Hz



#code rom,0
;*******************************************************************
;*        START AFTER RESET,                                       *
;*        Function....: ready system and restart                   *
;*******************************************************************
;             .ORG    0
             DI                    ; Disable interrupt
             LD     SP,RAMTOP      ; Set stack pointer to top off ram
             IM     1              ; Set interrupt mode 1
             JP     $100           ; jump to Start of program

             .byte " test system "  ; text string in rom
             .byte " V 1.00 "
             .byte " 1997 "



;************************************************************************
;*        INTERRUPT-PROGRAM                                             *
;*        Function....:                                                 *
;*        Input.......:                                                 *
;*        Output......: number interrupt at adr. INT_COUNTER            *
;*        uses........: only alternative registres.                     *
;*        calls.......: none                                            *
;*        info........: TST.  date: 27/10-96                            *
;************************************************************************
             .ORG   $38            ; Int mode 1
             DI                    ; disable
             EXX                   ; IN THE INT ROUTINE, YOU ONLY USES
             EX     AF,AF'         ; THE EXTRA REGISTERS.

             LD     A,(INT_COUNTER)
             INC    A
             LD     (INT_COUNTER),A

             EX     AF,AF'         ; BEFORE RETURN, SWITCH REGISTERS BACK
             EXX
             EI                    ; enable again
             RETI                  ; return from interrupt



             .ORG   $66            ; HERE IS THE NMI ROUTINE
             LD     HL,TXT_HELLO  ; POINT AT TEXT
             CALL   TX_SER        ; SENT TEXT 
             RETI

;*******************************************************************
;*        MAIN PROGRAM                                             *
;*******************************************************************
             .ORG   $100

             CALL   INIT_PIO    ; programm the PIO 
             LD     A,0   
             OUT    (PIO1B),A   ; ALL BITS OFF

             LD     BC,10000    
             CALL   PAUSE

             LD     A,255   
             OUT    (PIO1B),A    ; ALL BITS ON FOR 1 SEC..

             LD     BC,10000
             CALL   PAUSE

             LD     A,0   
             OUT    (PIO1B),A


         ;    CALL   INIT_UART      ; INIT AND TEST OF UART
         ;    ONLY CALL THIS IF YOU HAVE THE UART MOUNTED..

             EI                    ; Start INT COUNTER

MAIN_LOOP:
             LD     A,(INT_COUNTER)   ; GET COUNTER
             OUT    (PIO1B),A         ; OUTPUT IT TO SOME LEDS

             JP     MAIN_LOOP





;******************************************************************
;        INIT_UART                                                ;
;        Funktion....: Init seriel port  8250 OR 16C550    ;
;                      9600 Baud, 8 bit, 1 stopbit, 0 paritet     ;
;        Output......:                                            ;
;        call........: PAUSE                             TST 1993 ;
;******************************************************************
INIT_UART:   LD     A,$AA
             OUT    (UART7),A
             IN     A,(UART7)
             CP     $AA           ; TEST IF YOU CULD STORE AA
             JP     NZ,INITUARTFEJL  ; IF NOT, THE UART CAN'T BE FOUND
             LD     A,$55
             OUT    (UART7),A     ; 
             IN     A,(UART7)
             CP     $55           ; 
             JP     NZ,INITUARTFEJL
             JP     UART_OK

INITUARTFEJL:                      ; Her er der fejl i UART
             LD     A,1
             LD     (UARTFEJL),A
             HALT




UART_OK:     LD     A,0
             LD     (UARTFEJL),A   ; UART OK FUND
             LD     A,(SER_BAUD)
             CP     1
             JP     Z,UART1200
             CP     2
             JP     Z,UART2400
             CP     3
             JP     Z,UART4800
             CP     4
             JP     Z,UART9600
             CP     5
             JP     Z,UART19K2
             CP     6
             JP     Z,UART38K4
             CP     7
             JP     Z,UART57K6
             CP     8
             JP     Z,UART76K8
             ; IF NOTHING IS DEFINED 1200 WILL BE USED..


UART1200:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,218         ; (218.45)
             OUT    (UART0),A     ;
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART2400:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,109         ; (109.23)
             OUT    (UART0),A     ;
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART4800:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,55          ; (54.61)
             OUT    (UART0),A     ;
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART9600:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,27          ; (27.3)
             OUT    (UART0),A     ; Set BAUD rate til 9600
             LD     A,00H
             OUT    (UART1),A     ; Set BAUD rate til 9600
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART19K2:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,14          ; (13.65)
             OUT    (UART0),A     ;
             LD     A,0
             OUT    (UART1),A     ;
             LD     A,3
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART38K4:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,7
             OUT    (UART0),A     ; (6.82)
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART57K6:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,5
             OUT    (UART0),A     ; (4.55)
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
             JP     INITRET       ; 0 paritet, reset DLAP FLAG
UART76K8:    LD     A,80H
             OUT    (UART3),A     ; SET DLAB FLAG
             LD     A,3
             OUT    (UART0),A     ; (3.41)
             LD     A,00H
             OUT    (UART1),A     ;
             LD     A,03H
             OUT    (UART3),A     ; Set 8 bit data, 1 stopbit
                                  ; 0 paritet, reset DLAP FLAG
INITRET:     RET





;******************************************************************
;        INIT_PIO                                                 ;
;        Funktion....: Init par port >8255< ;
;******************************************************************
INIT_PIO:     
             LD     A,10011001B    ; A= IN, B= OUT C= IN
             OUT    (PIO1CONT),A
             RET

BOUT:   ;     LD     A,10000000B    ; A= OUT, B= OUT C= OUT (DATA TIL LCD)
        ;     OUT    (PIO2CONT),A   ; if there are 2 PIO
        ;     RET

BIN:    ;     LD     A,10000010B    ; A= OUT, B= IN C= OUT  (DATA FRA LCD)
        ;     OUT    (PIO2CONT),A
        ;     RET






;******************************************************************
;        SUB-RUTINE..: PAUSE                                      ;
;        Function....: Pause in 100uS. times value in BC          ;
;        Input.......: BC reg                                     ;
;        Output......: no                                         ;
;        call........: NONE                                       ;
;        Info........: KEA.      dato: 23/5-93                    ;
;******************************************************************
PAUSE:       PUSH   AF
             INC    B
             INC    C              ; ADJUST THE LOOP
PAUSELOOP1:  LD     A,13H          ; ADJUST THE TIME 13h IS FOR 4 MHZ
PAUSELOOP2:  DEC    A              ; DEC COUNTER. 4 T-states = 1 uS.
             JP     NZ,PAUSELOOP2  ; JUMP TO PAUSELOOP2 IF A <> 0.
             DEC    C              ; DEC COUNTER
             JP     NZ,PAUSELOOP1  ; JUMP TO PAUSELOOP1 IF C <> 0.

             DJNZ   PAUSELOOP1     ; JUMP TO PAUSELOOP1 IF B <> 0.
PAUSESLUT:   POP    AF
             RET




;******************************************************************
;        TX_SER                                                   *
;        Funktion....: Sen tekst and data with serielport         *
;        Input.......: HL points at text start adr                *
;        Output......: Text to serielport                         *
;        uses........: A,HL                                       *
;        call........: TX_BUSY                      tst 28-4-1994 *
;******************************************************************
TX_SER:      PUSH   AF
             LD     A,(SER_ON)     ; IF COM IS OFF
             CP     0              ; 
             JP     Z,TX_SLUT
TX_SERLP:    LD     A,(HL)         ; GET CHARATER TO A
             CP     END            ; TEST FOR END BYTE
             JP     Z,TX_SLUT      ; JUMP IF END BYTE IS FUND
             CALL   TX_BUSY        ; WAIT FOR UART TO GET READY
             OUT    (UART0),A      ; THEN WRITE THE CHAR TO UART
             INC    HL             ; INC POINTER, TO NEXT CHAR
             JP     TX_SERLP       ; TRANSMIT LOOP
TX_SLUT:     POP    AF
             RET



;******************************************************************
;        RX_BUSY                                                  *
;        Funktion....: WAIT FOR UART TO HAVE DATA IN BUFFER       *
;        Input.......: Bit 0 FROM UART MODEM CONTROL REGISTER  *
;******************************************************************
RX_BUSY:     PUSH   AF
RX_BUSYLP:   IN     A,(UART5)      ; READ Line Status Register
             BIT    0,A            ; TEST IF DATA IN RECIEVE BUFFER
             JP     Z,RX_BUSYLP    ; LOOP UNTIL DATA IS READY
             POP    AF
             RET


;******************************************************************
;        TX_BUSY                                                  *
;        Funktion....: WAIT FOR UART, TX BUFFER EMPTY             *
;        Input.......: Bit 5 FROM UART MODEM CONTROL REGISTER     *
;******************************************************************
TX_BUSY:     PUSH   AF
TX_BUSYLP:   IN     A,(UART5)     ; READ Line Status Register
             BIT    5,A           ; TEST IF UART IS READY TO SEND
             JP     Z,TX_BUSYLP   ; IF NOT REPEAT
             POP    AF
             RET



NEW_LINJE:   LD     A,$0A         ; THIS GIVES A NEW LINE ON A TERMINAL
             CALL   TX_BUSY
             OUT    (UART0),A
             LD     A,$0D
             CALL   TX_BUSY
             OUT    (UART0),A
             RET




TXT_HELLO:  .BYTE " HELLO WORLD ",END




 ;  .include ctxt001.asm         ; YOU CAN INCLUDE OTHER ASM FILES AND USE-
                                 ; THE SUB ROUTINES FROM THEM.
; .text "\n\r  -END-OF-FILE-  \n\r"
 .end


