CDL's Z80 Macro Assembler C12012-0312                                  Page 1

Exerpt from start of Zapple 2K monitor PRN file as from TDL
Exerpt by Herb Johnson Aug 2012


                         ;       << ZAPPLE 2-K MASKED ROM MONITOR SYSTEM >>
                         ;                       by
                         ;
                         ;       COMPUTER DESIGN LABS
                         ;       342 COLUMBUS AVE.
                         ;       TRENTON, NEW JERSEY 08629
                         ;
                         ;
                         ;       COPYRIGHT 1979 COMPUTER DESIGN LABS;
                         ;
                         .PABS   ;THIS MONITOR IN ABSOLUTE FORMAT
                         ;
                         ;
   F000                  BASE    = 0F000H
   F800                  USER    = BASE+800H
                         ;
                         ;
   0038                  RST7    = 38H   ;RST 7 (LOCATION FOR TRAP)
   0076                  IOBYT   = 76H   ;R/W PORT FOR TEMP. STORAGE
   007A                  SENSE   = 7AH   ;SWITCH WORD FOR INITIAL DEFAULT
   00FF                  SWITCH  = 0FFH  ;TEST PORT TO ABORT READ OPERATION
   007A                  RCP     = 7AH   ;READER CONTROL PORT (OUT)
   00F8                  NN      = 0F8H  ;"I" REGISTER INITIAL VALUE
                         ;
                         ;       <I/O DEVICES>
                         ;
                         ;-TELEPRINTER
                         ;
   0071                  TTI     = 71H   ;DATA IN PORT
   0071                  TTO     = 71H   ;DATA OUT PORT
   0070                  TTS     = 70H   ;STATUS PORT (IN)
   0001                  TTYDA   = 1     ;DATA AVAILABLE MASK BIT
   0002                  TTYBE   = 02    ;XMTR BUFFER EMPTY MASK
                         ;
                         ;-C.R.T. SYSTEM
                         ;
   0073                  CRTI    = 73H   ;DATA PORT (IN)
   0072                  CRTS    = 72H   ;STATUS PORT (IN)
   0073                  CRTO    = 73H   ;DATA PORT (OUT)
   0001                  CRTDA   = 1     ;DATA AVAILABLE MASK
   0002                  CRTBE   = 02    ;XMTR BUFFER EMPTY MASK
                         ;
                         ;-CASSETTE SYSTEM
                         ;
   0075                  RCSD    = 75H   ;DATA IN PORT
   0074                  RCSS    = 74H   ;STATUS PORT (IN)
   0001                  RCSDA   = 1     ;DATA AVAILABLE MASK
   0075                  PCASO   = 75H   ;DATA PORT (OUT)
   0074                  PCASS   = 74H   ;CONTROL PORT (OUT)
   0002                  PCSBE   = 02    ;XMTR BUFFER EMPTY MASK
                         ;
                         ;       <CONSTANTS>
                         ;
   0000                  FALSE   = 0             ;ISN'T SO
   FFFF                  TRUE    = # FALSE       ;IT IS SO
   000D                  CR      = 0DH           ;ASCII CARRIAGE RETURN
   000A                  LF      = 0AH           ;ASCII LINE FEED
   0007                  BELL    = 7             ;DING
   00FF                  RUB     = 0FFH          ;RUB OUT
   0000                  FIL     = 00            ;FILL CHARACTERS AFTER CRLF
   0007                  MAX     = 7             ;NUMBER OF QUES IN EOF
                         ;
                         ;       <I/O CONFIGURATION MASKS>
                         ;
   00FC                  CMSK    = 11111100B     ;CONSOLE DEVICE
   00F3                  RMSK    = 11110011B     ;STORAGE DEVICE (IN)
   00CF                  PMSK    = 11001111B     ;STORAGE DEVICE (OUT)
   003F                  LMSK    = 00111111B     ;LIST DEVICE
                         ;
                         ;
                         ;-CONSOLE CONFIGURATION
   0000                  CTTY    = 0     ;TELEPRINTER
   0001                  CCRT    = 1     ;C.R.T.
   0002                  BATCH   = 2     ;READER FOR INPUT, LIST FOR OUTPUT
   0003                  CUSE    = 3     ;USER DEFINED
                         ;
                         ;-STORAGE INPUT CONFIGURATION
   0000                  RTTY    = 0     ;TELEPRINTER READER
   0004                  RPTR    = 4     ;HIGH-SPEED RDR (EXTERNAL ROUTINE)
   0008                  RCAS    = 8     ;CASSETTE
   000C                  RUSER   = 0CH   ;USER DEFINED
                         ;
                         ;-STORAGE OUTPUT CONFIGURATION
   0000                  PTTY    = 0     ;TELEPRINTER PUNCH
   0010                  PPTP    = 10H   ;HIGH-SPEED PUNCH (EXTERNAL ROUTINE)
   0020                  PCAS    = 20H   ;CASSETTE
   0030                  PUSER   = 30H   ;USER DEFINED
                         ;
                         ;-LIST DEVICE CONFIGURATION
   0000                  LTTY    = 0     ;TELEPRINTER PRINTER
   0040                  LCRT    = 40H   ;C.R.T. SCREEN
   0080                  LINE    = 80H   ;LINE PRINTER (EXTERNAL ROUTINE)
   00C0                  LUSER   = 0C0H  ;USER DEFINED
                         ;
                         ;
                         ;       VECTORS FOR USER DEFINED ROUTINES
                         ;
   F800                  .LOC    USER
   F800                  CILOC:  .BLKB 3 ;CONSOLE INPUT
   F803                  COLOC:  .BLKB 3 ;CONSOLE OUTPUT
   F806                  RPTPL:  .BLKB 3 ;HIGH-SPEED READER
   F809                  RULOC:  .BLKB 3 ;USER DEFINED STORAGE (INPUT)
   F80C                  PTPL:   .BLKB 3 ;HIGH-SPEED PUNCH
   F80F                  PULOC:  .BLKB 3 ;USER DEFINED STORAGE (OUTPUT)
   F812                  LNLOC:  .BLKB 3 ;LINE PRINTER
   F815                  LULOC:  .BLKB 3 ;USER DEFINED PRINTER
   F818                  CSLOC:  .BLKB 3 ;CONSOLE INPUT STATUS ROUTINE
			 ;
                         ;       PROGRAM CODE BEGINS HERE
                         ;
   F000                  .LOC    BASE
   F000    C3 F032               JMP     BEGIN   ;GO AROUND VECTORS
                         ;
                         ;       <VECTORS FOR CALLING PROGRAMS>
                         ;
                         ; THESE VECTORS MAY BE USED BY USER WRITTEN
                         ; PROGRAMS TO SIMPLIFY THE HANDLING OF I/O
                         ; FROM SYSTEM TO SYSTEM.  WHATEVER THE CURRENT
                         ; ASSIGNED DEVICE, THESE VECTORS WILL PERFORM
                         ; THE REQUIRED I/O OPERATION, AND RETURN TO
                         ; THE CALLING PROGRAM. (RET)
                         ;
                         ; THE REGISTER CONVENTION USED FOLLOWS-
                         ;
                         ; ANY INPUT OR OUTPUT DEVICE-
                         ;       CHARACTER TO BE OUTPUT IN 'C' REGISTER.
                         ;       CHARACTER WILL BE IN 'A' REGISTER UPON
                         ;       RETURNING FROM AN INPUT OR OUTPUT.
                         ; 'CSTS'-
                         ;       RETURNS TRUE (0FFH IN 'A' REG.) IF THERE IS
                         ;       SOMETHING WAITING, AND ZERO (00) IF NOT.
                         ; 'IOCHK'-
                         ;       RETURNS WITH THE CURRENT I/O CONFIGURATION
                         ;       BYTE IN 'A' REGISTER.
                         ; 'IOSET'-
                         ;       ALLOWS A PROGRAM TO DYNAMICALLY ALTER THE
                         ;       CURRENT I/O CONFIGURATION, AND REQUIRES
                         ;       THE NEW BYTE IN 'C' REGISTER.
                         ; 'MEMCK'-
                         ;       RETURNS WITH THE HIGHEST ALLOWED USER
                         ;       MEMORY LOCATION. 'B'=HIGH BYTE, 'A'=LOW.
                         ; 'TRAP'-
                         ;       THIS IS THE 'BREAKPOINT' ENTRY POINT,
                         ;       BUT MAY BE 'CALLED'. IT WILL SAVE
                         ;       THE MACHINE STATE. RETURN CAN BE MADE WITH
                         ;       A SIMPLE 'G[CR]' ON THE CONSOLE.
                         ;
   F003    C3 F619               JMP     CI      ;CONSOLE INPUT
   F006    C3 F636               JMP     RI      ;READER INPUT
   F009    C3 F48A               JMP     CO      ;CONSOLE OUTPUT
   F00C    C3 F4C4               JMP     PO      ;PUNCH OUTPUT
   F00F    C3 F4AB               JMP     LO      ;LIST OUTPUT
   F012    C3 F51A               JMP     CSTS    ;CONSOLE STATUS
   F015    DB76                  IN      IOBYT   ;I/O CHECK
   F017    C9                    RET
   F018    C3 F11D               JMP     IOSET   ;I/O SET
   F01B    C3 F5AC               JMP     MEMCK   ;MEMORY LIMIT CHECK
   F01E    C3 F6BE       TRAP:   JMP     RESTART ;BREAKPOINT
                         ;
                         ;       ANNOUNCEMENT OF MONITOR NAME & VERSION
                         ;
   F021    0D0A000000    MSG:    .BYTE   CR,LF,FIL,FIL,FIL
   F026    5A6170706C65          .ASCII  'Zapple V'
   F02E    312E3052              .ASCII  '1.0R'
   0011                  MSGL    = .-MSG
                         ;
                         ;       LET US BEGIN
                         ;
   F032    3E53          BEGIN:  MVI     A,053H  ;INITIALIZE THE HARDWARE
   F034    D370                  OUT     TTS
   F036    D372                  OUT     CRTS
   F038    D374                  OUT     RCSS
   F03A    3E51                  MVI     A,051H
   F03C    D370                  OUT     TTS
   F03E    D372                  OUT     CRTS
   F040    3D                    DCR     A
   F041    D374                  OUT     RCSS
   F043    AF                    XRA     A
   F044    D377                  OUT     IOBYT+1
   F046    D37A                  OUT     RCP     ;CLEAR RDR CONTROL PORT
   F048    3D                    DCR     A
   F049    D376                  OUT     IOBYT
   F04B    3E04                  MVI     A,4
   F04D    D377                  OUT     IOBYT+1 ;WHEW!
                         ;
   F04F    DB7A                  IN      SENSE   ;INITIALIZE I/O CONFIGURATION
   F051    D376                  OUT     IOBYT
   F053    3EF8                  MVI     A,NN    ;INITIAL 'I' REG. CONFIGURATION
   F055    ED47                  STAI            ;SET FOR PAGE 'NN' ON INTERUPT
                         
   F057    31 F05B               LXI     SP,AHEAD-4      ;SET UP A FAKE STACK
   F05A    C3 F5BA               JMP     MEMSIZ+1        ;GET MEMORY SIZE
   F05D    F05F                  .WORD   AHEAD
   F05F    F9            AHEAD:  SPHL            ;SET TRUE STACK
   F060    EB                    XCHG
   F061    01 0023               LXI     B,ENDX-EXIT
   F064    21 F7A8               LXI     H,EXIT
   F067    EDB0                  LDIR            ;MOVE TO RAM
   F069    EB                    XCHG
   F06A    01 FFA1               LXI     B,-5FH  ;SET UP A USER'S STACK VALUE
   F06D    09                    DAD     B
   F06E    E5                    PUSH    H       ;PRE-LOAD STACK VALUE
   F06F    21 0000               LXI     H,0     ;INITIALIZE OTHER REGISTERS
   F072    060A                  MVI     B,10    ; (20 OF THEM)
   F074    E5            STKIT:  PUSH    H       ; TO ZERO
   F075    10FD                  DJNZ    STKIT
   F077    0611          HELLO:  MVI     B,MSGL  ;SAY HELLO TO THE FOLKS 
   F079    CD F44F               CALL    TOM1    ;OUTPUT SIGN-ON MSG
   F07C    11 F07C       START:  LXI     D,START ;MAIN 'WORK' LOOP
   F07F    D5                    PUSH    D       ;SET UP A RETURN TO HERE
   F080    CD F512               CALL    CRLF
   F083    0E3E                  MVI     C,'>'
   F085    CD F48A               CALL    CO
   F088    CD F736       STAR0:  CALL    TI      ;GET A CONSOLE CHARACTER
   F08B    E67F                  ANI     7FH     ;IGNORE NULLS
   F08D    28F9                  JRZ     STAR0   ;GET ANOTHER
   F08F    D641                  SUI     'A'     ;QUALIFY THE CHARACTER
   F091    F8                    RM              ;<A
   F092    FE1A                  CPI     'Z'-'A'+1
   F094    D0                    RNC             ;INVALID CHARACTER
   F095    87                    ADD     A       ;A*2
   F096    21 F0A2               LXI     H,TBL   ;POINT TO COMMAND TABLE
   F099    85                    ADD     L       ;ADD IN DISPLACEMENT
   F09A    6F                    MOV     L,A
   F09B    7E                    MOV     A,M
   F09C    23                    INX     H
   F09D    66                    MOV     H,M
   F09E    6F                    MOV     L,A
   F09F    0E02                  MVI     C,2     ;SET C UP
   F0A1    E9                    PCHL            ;GO EXECUTE COMMAND.
                         ;
                         ;               <COMMAND BRANCH TABLE>
                         ;
   F0A2                  TBL:
   F0A2    F0D6          .WORD   ASSIGN  ;A - ASSIGN I/O
   F0A4    F121          .WORD   BYE     ;B - SYSTEM SHUT-DOWN
   F0A6    F14E          .WORD   COMP    ;C - COMPARE MEMORY VS. READER INPUT
   F0A8    F16F          .WORD   DISP    ;D - DISPLAY MEMORY ON CONS. IN HEX
   F0AA    F186          .WORD   EOF     ;E - END OF FILE TAG FOR HEX DUMPS
   F0AC    F1A2          .WORD   FILL    ;F - FILL MEMORY WITH A CONSTANT
   F0AE    F1AF          .WORD   GOTO    ;G - GOTO [ADDR]<,>BREAKPOINTS (2)
   F0B0    F57E          .WORD   HEXN    ;H - HEX MATH. <SUM>,<DIFFERENCE>
   F0B2    F81B          .WORD   J       ;I * USER DEFINED
   F81E                          J=J+3   ;INCREMENT VECTOR ADDR
   F0B4    F1FD          .WORD   TEST    ;J - NON-DESTRUCTIVE MEMORY TEST
   F0B6    F81E          .WORD   J       ;K * USER DEFINED
   F821                          J=J+3   ;INCREMENT VECTOR ADDR
   F0B8    F681          .WORD   LOAD    ;L - LOAD A BINARY FORMAT FILE
   F0BA    F21B          .WORD   MOVE    ;M - MOVE BLOCKS OF MEMORY
   F0BC    F4F8          .WORD   NULL    ;N - PUNCH NULLS ON PUNCH DEVICE
   F0BE    F821          .WORD   J       ;O * USER DEFINED
   F0C0    F12F          .WORD   PUTA    ;P - 'PUT' ASCII INTO MEMORY.
   F0C2    F757          .WORD   QUERY   ;Q - QI(N)=DISP. N; QO(N,V)=OUT N,V
   F0C4    F226          .WORD   READ    ;R - READ A HEX FILE (W/CHECKSUMS)
   F0C6    F2DF          .WORD   SUBS    ;S - SUBSTITUTE &/OR EXAMINE MEMORY
   F0C8    F308          .WORD   TYPE    ;T - TYPE MEMORY IN ASCII
   F0CA    F4E0          .WORD   UNLD    ;U - MEMORY TO PUNCH (BINARY FORMAT)
   F0CC    F782          .WORD   VERIFY  ;V - COMPARE MEMORY AGAINST MEMORY
   F0CE    F370          .WORD   WRITE   ;W - MEMORY TO PUNCH (HEX FORMAT)
   F0D0    F3B0          .WORD   XAM     ;X - EXAMINE & MODIFY CPU REGISTERS
   F0D2    F328          .WORD   WHERE   ;Y - FIND SEQUENCE OF BYTES IN MEM.
   F0D4    F47B          .WORD   SIZE    ;Z - ADDRESS OF LAST R/W LOCATION
                         ;
                         ;
                         ;
                         ;       THIS ROUTINE CONTROLS THE CONFIGURATION
                         ; OF THE VARIOUS I/O DRIVERS & DEVICES. THIS IS
                         ; ACCOMPLISHED VIA A HARDWARE READ/WRITE PORT.
                         ;       THIS PORT IS INITIALIZED UPON SIGN-ON
                         ; BY THE VALUE READ ON PORT 'SENSE'.  IT MAY BE
                         ; DYNAMICALLY MODIFIED THROUGH CONSOLE COMMANDS.
                         ;
                         ; THE VALUE ON THE 'IOBYT' PORT REPRESENTS THE
                         ; CURRENT CONFIGURATION.  IT IS STRUCTURED THUSLY:
                         ;
                         ; 000000XX - WHERE XX REPRESENTS THE CURRENT CONSOLE.
                         ; 0000XX00 - WHERE XX REPRESENTS THE CURRENT READER.
                         ; 00XX0000 - WHERE XX REPRESENTS THE CURRENT PUNCH.
                         ; XX000000 - WHERE XX REPRESENTS THE CURRENT LISTER.
                         ;
                         ; WHEN XX = 00, THE DEVICE IS ALWAYS THE
                         ; TELEPRINTER.  WHEN XX = 11, THE DEVICE IS ALWAYS THE
                         
                         ; USER DEFINED.  SEE OPERATORS MANUAL FOR FURTHER
                         ; DETAILS.
                         ;
   F0D6    CD F736       ASSIGN: CALL    TI      ;GET DEVICE NAME
   F0D9    21 F794               LXI     H,LTBL  ;POINT TO DEVICE TABLE
   F0DC    01 0400               LXI     B,400H  ;4 DEVICES TO LOOK FOR
   F0DF    11 0005               LXI     D,5     ;IDENTIFIER + 4 DEV. IN TABLE
   F0E2    BE            ..A0:   CMP     M       ;LOOK FOR MATCH
   F0E3    2806                  JRZ     ..A1
   F0E5    19                    DAD     D       ;GO THRU TABLE
   F0E6    0C                    INR     C       ;KEEP TRACK OF DEVICE
   F0E7    10F9                  DJNZ    ..A0
   F0E9    1815                  JMPR    ..ERR   ;WRONG IDENTIFIER
   F0EB    59            ..A1:   MOV     E,C     ;SAVE DEVICE NUMBER
   F0EC    CD F736       ..A2:   CALL    TI      ;SCAN PAST '='
   F0EF    FE3D                  CPI     '='
   F0F1    20F9                  JRNZ    ..A2
   F0F3    CD F736               CALL    TI      ;GET NEW ASSIGNMENT
   F0F6    01 0400               LXI     B,400H  ;4 POSSIBLE ASSIGNMENTS
   F0F9    23            ..A3:   INX     H       ;POINT TO ASSIGNMENT NAME
   F0FA    BE                    CMP     M       ;LOOK FOR PROPER MATCH
   F0FB    2806                  JRZ     ..A4    ;MATCH FOUND
   F0FD    0C                    INR     C       ;KEEP TRACK OF ASSIGNMENT NMBR
                         
   F0FE    10F9                  DJNZ    ..A3
   F100    C3 F464       ..ERR:  JMP     ERROR   ;NO MATCH, ERROR
   F103    3E03          ..A4:   MVI     A,3     ;SET UP A MASK
   F105    1C                    INR     E
   F106    1D            ..A5:   DCR     E       ;DEVICE IN E
   F107    2808                  JRZ     ..A6    ;GOT IT
   F109    CB21                  SLAR    C       ;ELSE MOVE MASKS
   F10B    CB21                  SLAR    C
   F10D    17                    RAL
   F10E    17                    RAL             ;A=DEVICE MASK
   F10F    18F5                  JMPR    ..A5
   F111    2F            ..A6:   CMA             ;INVERT FOR AND'ING
   F112    57                    MOV     D,A     ;SAVE IN D
   F113    CD F60A       ..A7:   CALL    PCHK    ;WAIT FOR [CR]
   F116    30FB                  JRNC    ..A7


