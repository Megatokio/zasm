#!/usr/local/bin/zasm -o original/
#target rom
#code   rom,$0000,$1000

        ORG     0000H
        LD      SP,23C0H
        JP      RESTAR
        ORG     0008H
BPENT:  LD      (STKPT),SP
        PUSH    AF
        PUSH    BC
        JR      BPENT2
        JP      RST16
BPENT2: LD      A,I
        DI
        JR      BPENT3
        JP      RST24
BPENT3: PUSH    DE
        PUSH    HL
        PUSH    AF
        JR      BPENT4
        JP      RST32
BPENT4: EX      AF,AF'
        EXX
        PUSH    AF
        JR      BPENT5
        JP      RST40
BPENT5: PUSH    BC
        PUSH    DE
        PUSH    HL
        JR      BPENT6
        JP      RST48
BPENT6: PUSH    IX
        NOP
        JR      BPENT7
        JP      RST56
BPENT7: PUSH    IY
        LD      A,03H
        OUT     (CTC2),A
        LD      IX,(STKPT)
        INC     IX
        INC     IX
        LD      (STKPT),IX
        LD      A,(IX-2)
        OR      A
        JR      NZ,BPENT8
        DEC     (IX-1)
BPENT8: DEC     (IX-2)
        LD      A,(IX-12)
        AND     4
        LD      (UIF),A
        CALL    UFOR3
        JR      BPNT8A
        JP      NMIS
BPNT8A: JR      Z,REMBP2
REMBP:  LD      A,(IX+2)
        CP      0CFH
        JR      Z,REMBP1
REMBP0: LD      L,(IX+1)
        LD      H,(IX+0)
        LD      (HL),A
REMBP1: CALL    UIX3
        JR      NZ,REMBP
REMBP2: LD      IX,DISMEM
        LD      HL,(STKPT)
        DEC     HL
        LD      A,(HL)
        CALL    UFOR1
        INC     IX
        INC     IX
        DEC     HL
        LD      A,(HL)
        CALL    UFOR1
        INC     IX
        INC     IX
        DEC     HL
        LD      A,(HL)
        CALL    UFOR1
        JP      DISUP
RESTAR: LD      (STKPT),SP
        LD      SP,23A8H
        LD      A,00H
        LD      (BFLG),A
        LD      (UIF),A
RESTR1: CALL    UFGCR
        LD      A,11H
        LD      (DISMEM),A
        LD      A,10H
        LD      (DSMEM1),A
        LD      (DSMEM2),A
        JR      RESTR2
        JR      RESTR3
RESTR2: LD      (DSMEM3),A
        LD      (DSMEM4),A
        LD      (DSMEM5),A
        IN      A,(KBSEL)
        BIT     5,A
        JP      NZ,DISUP
        JP      0800H
RESTR3: INC     DE
        PUSH    DE
        POP     IX
        INC     DE
        LD      A,L
        SUB     E
        LD      L,A
        LD      (IX+0),A
        LD      A,H
        SBC     A,D
        LD      IX,DISMEM
        CALL    UFOR1
        LD      IX,DSMEM2
        LD      A,L
        CALL    UFOR1
        JP      DISUP

        ORG     00F4H
DISUP:  LD      HL,DISMEM
        LD      B,020H
DISUP1: LD      E,(HL)
        LD      D,0
        LD      A,0
        OUT     (DIGLH),A
        LD      IX,SEGPT
        ADD     IX,DE
        LD      A,(IX+0)
        OUT     (SEGLH),A
        LD      A,B
        OUT     (DIGLH),A
        LD      E,45D
DISUP2: DEC     E
        LD      A,0
        CP      E
        JR      NZ,DISUP2
        LD      A,01H
        CP      B
        JR      Z,DISUP3
        INC     HL
        SRL     B
        JR      DISUP1
DISUP3: JP      DECKY

        ORG     0123H
DIGLH:  EQU     8CH
KBSEL:  EQU     90H
CTC0:   EQU     84H
CTC1:   EQU     85H
CTC2:   EQU     86H
CTC3:   EQU     87H
SEGLH:  EQU     88H
DECKY:  LD      A,7FH
        OUT     (SEGLH),A
        LD      A,3FH
        OUT     (DIGLH),A
        IN      A,(KBSEL)
        AND     1FH
        CP      1FH
        JP      Z,DISUP
        CALL    D20MS
        LD      C,DIGLH
        LD      B,01H
KEYDN1: OUT     (C),B
        IN      A,(KBSEL)
        AND     1FH
        CP      1FH
        JR      NZ,KEYDN2
        SLA     B
        LD      A,40H
        CP      B
        JR      NZ,KEYDN1
        JP      DISUP
KEYDN2: LD      C,00H
KEYDN3: DEC     C
        SRL     B
        JR      NZ,KEYDN3
        SLA     C
        SLA     C
        SLA     C
        SLA     C
        ADD     A,C
        LD      HL,KYTBL
KEYDN4: CP      (HL)
        JR      Z,KEYDN5
        INC     HL
        INC     B
        JR      KEYDN4
KEYDN5: IN      A,(KBSEL)
        AND     01FH
        CP      01FH
        JR      NZ,KEYDN5
        CALL    D20MS
        LD      A,B
        CP      10H
        JR      NC,KEYDN6
        LD      HL,(KEYPTR)
        LD      (HL),B
        OR      A
        LD      BC,DSMEM1
        SBC     HL,BC
        JR      Z,KEYDNA
        OR      A
        LD      BC,DSMEM3
        LD      HL,(KEYPTR)
        SBC     HL,BC
        JR      Z,KEYDN8
        OR      A
        LD      BC,DSMEM7
        LD      HL,(KEYPTR)
        SBC     HL,BC
        JR      Z,KEYDN9
KEYDN7: LD      HL,(KEYPTR)
        INC     HL
        LD      (KEYPTR),HL
        JP      DISUP
KEYDNA: LD      HL,DIG2
        INC     (HL)
        JR      KEYDN7
KEYDN8: LD      HL,DIG4
        INC     (HL)
        JR      KEYDN7
KEYDN9: CALL    ALTER
        LD      HL,(KEYPTR)
        DEC     HL
        LD      (KEYPTR),HL
        JP      DISUP
KEYDN6: SUB     10H
        LD      C,A
        ADD     A,C
        ADD     A,C
        LD      C,A
        LD      B,00H
        LD      HL,JPTAB
        ADD     HL,BC
        JP      (HL)
NMIS:   LD      (STKPT),SP
        PUSH    AF
        LD      A,03H
        OUT     (CTC2),A
        LD      A,I
        PUSH    BC
        PUSH    DE
        PUSH    HL
        PUSH    AF
        EX      AF,AF'
        EXX
        PUSH    AF
        PUSH    BC
        PUSH    DE
        PUSH    HL
        PUSH    IX
        PUSH    IY
        LD      IX,(STKPT)
        INC     IX
        INC     IX
        LD      A,(IX-12)
        AND     4
        LD      (UIF),A
        LD      (STKPT),IX
NMIS1:  LD      A,(SSFLG)
        OR      A
        JP      Z,DECKY
NMIS2:  LD      A,00H
        LD      (SSFLG),A
        CALL    UFOR3
        JP      Z,REMBP2
        JR      CCS1C
JPTAB   JP      CCS1
        JP      CCS2
        JP      CCS3
        JP      CCS4
        JP      CCS5
        JP      CCS6
        JP      CCS7
        JP      CCS8
        JP      CCS9
        JP      CCS10
        JP      CCS11
        JP      CCS12
CCS1:   LD      A,00H
        OUT     (DIGLH),A
        LD      A,(DIG4)
        OR      A
        JR      Z,CCS1A
        CALL    UFOR2
        LD      IX,(STKPT)
        LD      (IX-2),L
        LD      (IX-1),H
CCS1A:  CALL    UFOR3
        JR      NZ,CCS2A
        JR      CCS1D
CCS1C:  LD      IX,BPTAB
CCS1CA: LD      H,(IX+0)
        LD      L,(IX+1)
        LD      A,(HL)
        LD      C,0CFH
        LD      (HL),C
        LD      (IX+2),A
        CALL    UIX3
        JR      NZ,CCS1CA
CCS1D:  LD      A,04H
        OUT     (DIGLH),A
        LD      A,45H
        OUT     (CTC2),A
        LD      A,01H
        OUT     (CTC2),A
        JR      CCS2B
CCS2:   LD      A,00H
        LD      (BFLG),A
CCS2A:  LD      A,01H
        LD      (SSFLG),A
        LD      A,07H
        OUT     (CTC2),A
        LD      A,11D
        OUT     (CTC2),A
CCS2B:  POP     IY
        POP     IX
        POP     HL
        POP     DE
        POP     BC
        POP     AF
        EX      AF,AF'
        EXX
        POP     AF
        LD      I,A
        POP     HL
        POP     DE
        POP     BC
        LD      A,(UIF)
        OR      A
        JP      NZ,CCS2C
        POP     AF
        DI
        RET
CCS2C:  POP     AF
        EI
        RET
CCS3:   JP      RESTR1
CCS4:   LD      A,(MFLG)
        CP      01H
        JR      Z,CCS4B
        LD      A,(PFLG)
        CP      01H
        JR      Z,CCS4C
        LD      A,(PRFLG)
        CP      01H
CCS4A:  JP      NZ,RESTR1
        JP      CCS12D
CCS4B:  CALL    UFOR2
        INC     HL
        LD      A,H
        CALL    UFOR1
        INC     IX
        INC     IX
        LD      A,L
        CALL    UFOR1
        INC     IX
        INC     IX
        LD      A,(HL)
        CALL    UFOR1
        JP      DISUP
CCS4C:  CALL    UFOR2
        LD      C,H
        INC     C
        IN      A,(C)
        LD      A,C
        CALL    UFOR1
        LD      IX,DSMEM4
        CALL    UFOR1
        JP      DISUP
CCS5:   LD      A,01
        LD      (ARFLG),A
        LD      IX,DISMEM
        LD      A,12H
        LD      (IX+1),A
        CALL    ALTER5
        LD      A,(HL)
        LD      IX,DSMEM4
        CALL    UFOR1
        JR      CCS6C
CCS6:   LD      A,01H
        LD      (RFLG),A
        CALL    ALTER6
        JR      C,CCS6A
        LD      A,(HL)
        LD      IX,DSMEM4
        CALL    UFOR1
        JR      CCS6C
CCS6A:  CP      3
        JR      Z,CCS6B
        CP      2
        JR      Z,CCS6A1
        LD      A,(HL)
        LD      IX,DSMEM4
        LD      (KEYPTR),IX
        CALL    UFOR1
        INC     HL
        LD      A,(HL)
        LD      IX,DSMEM2
        CALL    UFOR1
        JR      CCS6D
CCS6A1: LD      A,(STKPT1)
        LD      IX,DSMEM2
        CALL    UFOR1
        LD      A,(STKPT)
        LD      IX,DSMEM4
        CALL    UFOR1
        LD      (KEYPTR),IX
        JR      CCS6D
CCS6B:  LD      IX,DSMEM4
        LD      A,(UIF)
        CALL    UFOR1
        LD      HL,DSMEM7
CCS6C:  LD      HL,DSMEM6
        LD      (KEYPTR),HL
CCS6D:  JP      DISUP
CCS7:   LD      A,(DIG2)
        CP      1
        JR      NZ,CCS7A
        LD      (PFLG),A
        LD      A,10H
        LD      (DSMEM2),A
        LD      (DSMEM3),A
        CALL    UFOR2
        LD      C,H
        IN      A,(C)
        LD      IX,DSMEM4
        CALL    UFOR1
        INC     IX
        INC     IX
        LD      (KEYPTR),IX
CCS7A:  JP      DISUP
CCS8:   LD      A,(DIG4)
        OR      A
        JR      Z,CCS8A
        LD      (MFLG),A
        CALL    UFOR2
        LD      A,(HL)
        LD      IX,DSMEM4
        CALL    UFOR1
        INC     IX
        INC     IX
        LD      (KEYPTR),IX
CCS8A:  JP      DISUP
ALTER:  LD      IX,DISMEM
        LD      A,(PFLG)
        OR      A
        JR      NZ,ALTER2
        LD      A,(RFLG)
        OR      A
        JR      NZ,ALTR3
        LD      A,(ARFLG)
        OR      A
        JP      NZ,ALTR4
        LD      A,(MFLG)
        OR      A
        JP      Z,RESTR1
        CALL    UFOR2
        LD      A,(IX+6)
        CALL    ALTER7
        OR      (IX+7)
        LD      (HL),A
        LD      A,(HL)
ALTER1: LD      IX,DSMEM4
        CALL    UFOR1
        RET
ALTER2: CALL    UFOR2
        LD      A,(IX+6)
        CALL    ALTER7
        OR      (IX+7)
        LD      C,H
        OUT     (C),A
        JR      ALTER1
ALTR3:  CALL    ALTER6
        JR      C,ALTR3A
        LD      A,(IX+6)
        CALL    ALTER7
        OR      (IX+7)
        LD      (HL),A
        JP      ALTER1
ALTR3A: CP      3
        JR      Z,ALTR3B
        CP      2
        JR      Z,ALTR3C
        LD      A,(IX+4)
        CALL    ALTER7
        OR      (IX+5)
        INC     HL
        LD      (HL),A
        LD      IX,DSMEM2
        CALL    UFOR1
        LD      A,(IX+4)
        CALL    ALTER7
        OR      (IX+5)
        DEC     HL
        LD      (HL),A
        JP      ALTER1
ALTR3B: LD      A,(DSMEM7)
        LD      (UIF),A
        LD      (DSMEM5),A
        RET
ALTR3C: POP     HL
        JP      RESTR1
ALTR4:  LD      IX,DISMEM
        CALL    ALTER5
        LD      A,(IX+6)
        CALL    ALTER7
        OR      (IX+7)
        LD      (HL),A
        JP      ALTER1
ALTER5: LD      E,(IX+0)
        LD      B,00H
        LD      D,00H
        LD      HL,REGTBP
        ADD     HL,DE
        LD      C,(HL)
        LD      A,C
        CP      25D
        JP      Z,RESTR1
        LD      HL,(STKPT)
        OR      A
        SBC     HL,BC
        RET
ALTER6: LD      IX,DISMEM
        LD      E,(IX)
        LD      B,00H
        LD      D,00H
        LD      HL,REGTB
        ADD     HL,DE
        LD      C,(HL)
        LD      A,C
        CP      25D
        JP      Z,RESTR1
        LD      HL,(STKPT)
        LD      A,E
        OR      A
        SBC     HL,BC
        CP      6
        RET
ALTER7: SLA     A
        SLA     A
        SLA     A
        SLA     A
        RET
CCS9:   LD      A,(DIG4)
        OR      A
        JR      NZ,CCS90
        LD      (BFLG),A
        JR      CCS91
CCS90:  CALL    UFOR2
        CALL    UFOR3
        JR      Z,CCS9B
        LD      A,B
        CP      05
        JR      NZ,CCS9A
        JP      RESTR1
CCS91:  JP      DISUP
CCS9A:  CALL    UIX3
        JR      NZ,CCS9A
CCS9B:  LD      A,(BFLG)
        INC     A
        LD      (BFLG),A
        LD      (IX),H
        LD      (IX+1),L
        JP      DISUP
CCS10:  CALL    UFOR4
        LD      A,1
        LD      (FLG24),A
        IM      2
        LD      BC,CTC1P	; kio 2015-01-06: changed from "LD B,CTC1P"
        LD      A,B
        LD      I,A
        LD      A,C
        OUT     (CTC0),A
        LD      A,85H
        OUT     (CTC1),A
        LD      A,26D
        OUT     (CTC1),A
        LD      A,(PUNHSH)
        LD      D,A
        LD      A,(PUNHSL)
        LD      E,A
        LD      A,(PUNHEH)
        LD      H,A
        LD      A,(PUNHEL)
        LD      L,A
        XOR     A
        SBC     HL,DE
        INC     HL
        PUSH    HL
        LD      HL,0000H
        LD      B,3D
        EI
CCS10A: HALT
        DEC     L
        JR      NZ,CCS10A
        DEC     H
        JR      NZ,CCS10A
        DJNZ    CCS10A
CCS10B: LD      A,03AH
        CALL    OTCHR1
        XOR     A
        LD      BC,10H
        POP     HL
        SBC     HL,BC
        JR      NC,CCS10C
        ADD     HL,BC
        ADD     A,L
        LD      B,A
        LD      L,0
        JR      Z,CCS10F
        JR      CCS10D
CCS10C: LD      B,C
CCS10D: PUSH    HL
        LD      C,0
        LD      A,B
        CALL    UPACCS
        LD      A,(PUNHSH)
        LD      H,A
        CALL    UPACCS
        LD      A,(PUNHSL)
        LD      L,A
        CALL    UPACCS
        XOR     A
        CALL    UPACCS
CCS10E: LD      A,(HL)
        CALL    UPACCS
        INC     HL
        DJNZ    CCS10E
        SUB     A
        SUB     C
        CALL    UPACCS
        LD      A,0DH
        CALL    UPACCS
        LD      A,0AH
        CALL    UPACCS
        LD      A,H
        LD      (PUNHSH),A
        LD      A,L
        LD      (PUNHSL),A
        JR      CCS10B
CCS10F: LD      B,3
CCS10G: XOR     A
        LD      C,A
        CALL    UPACCS
        DJNZ    CCS10G
        LD      A,1
        CALL    UPACCS
        SUB     A
        SUB     C
        CALL    UPACCS
CCS10H: LD      HL,0FFFFH
        EI
        HALT
CCS10J: DEC     L
        JR      NZ,CCS10J
        DEC     H
        JR      NZ,CCS10J
        DI
        LD      A,03H
        OUT     (CTC1),A
        DI
        JP      RESTR1
CCS11:  IM      2
        LD      HL,0FFFH
        LD      B,20H
CCS11A: DEC     L
        JR      NZ,CCS11A
        DEC     H
        JR      NZ,CCS11A
        DJNZ    CCS11A
CCS11G: CALL    INCHR
        SUB     03AH
        JR      NZ,CCS11G
        LD      C,A
        CALL    ULACC
        LD      B,A
        CALL    ULACC
        LD      D,A
        CALL    ULACC
        LD      E,A
        CALL    ULACC
        DEC     A
        PUSH    AF
        JR      Z,CCS11J
CCS11H: CALL    ULACC
        LD      (DE),A
        INC     DE
        DJNZ    CCS11H
CCS11J: CALL    ULACC
        XOR     A
        ADD     A,C
        JR      Z,CCS11K
        LD      IX,DISMEM
        LD      A,D
        CALL    UFOR1
        LD      IX,DSMEM2
        LD      A,E
        CALL    UFOR1
        POP     AF
        JP      DISUP
CCS11K: POP     AF
        JR      NZ,CCS11G
        JP      RESTR1
CCS12:  LD      A,01H
        LD      (PRFLG),A
        CALL    UFOR2
        PUSH    HL
        POP     BC
        PUSH    HL
        LD      HL,2000H
        LD      DE,1000H
CCS12A: LD      A,25H
        OUT     (CTC2),A
        LD      A,203D
        OUT     (CTC2),A
        LD      A,80H
        OUT     (DIGLH),A
        LDI
        LD      A,00H
        OUT     (DIGLH),A
        LD      A,03H
        OUT     (CTC2),A
        JP      PE,CCS12A
        POP     BC
        LD      HL,2000H
        LD      DE,1000H
CCS12B: LD      A,(DE)
        CPI
        JR      NZ,CCS12C
        JP      PO,RESTR1
        INC     DE
        JR      CCS12B
CCS12C: PUSH    AF
        PUSH    BC
        PUSH    DE
        EXX
        POP     DE
        POP     BC
CCS12E: LD      IX,DISMEM
        LD      A,D
        CALL    UFOR1
        LD      IX,DSMEM2
        LD      A,E
        CALL    UFOR1
        LD      IX,DSMEM4
        POP     AF
        CALL    UFOR1
        JP      DISUP
CCS12D: EXX
        INC     DE
        JR      CCS12B
	
        ORG     0634H
UIX3:   INC     IX
        INC     IX
        INC     IX
        DEC     B
        RET
UFOR1:  LD      B,A
        AND     00FH
        LD      (IX+1),A
        LD      A,B
        SRL     A
        SRL     A
        SRL     A
        SRL     A
        LD      (IX+0),A
        RET
D20MS:  LD      HL,08FFH
D20MS1: DEC     L
        JR      NZ,D20MS1
        DEC     H
        JR      NZ,D20MS1
        RET
UFOR2:  LD      IX,DISMEM
        LD      A,(IX)
        SLA     A
        SLA     A
        SLA     A
        SLA     A
        OR      (IX+1)
        LD      H,A
        LD      A,(IX+2)
        SLA     A
        SLA     A
        SLA     A
        SLA     A
        OR      (IX+3)
        LD      L,A
        RET
UFOR3:  LD      IX,BPTAB
        LD      A,(BFLG)
        OR      A
        LD      B,A
        RET
UFGCR:  LD      HL,DISMEM
        LD      (KEYPTR),HL
        LD      A,00H
        LD      (DIG2),A
        LD      (DIG4),A
        LD      (SSFLG),A
        LD      (PRFLG),A
        LD      (PFLG),A
        LD      (MFLG),A
        LD      (RFLG),A
        LD      (ARFLG),A
        RET
UFOR4:  LD      B,8
        LD      HL,DISMEM
        LD      A,10H
UFOR4A: LD      (HL),A
        INC     HL
        DJNZ    UFOR4A
        RET
UABIN   SUB     030H
        CP      10
        RET     M
        SUB     7
        RET
UBASC:  AND     0FH
        ADD     A,90H
        DAA
        ADC     A,40H
        DAA
        RET
UPACC:  EXX
        PUSH    AF
        RRCA
        RRCA
        RRCA
        RRCA
        CALL    OTCHR
        POP     AF
        AND     0FH
        CALL    OTCHR
        EXX
        RET
UPACCS: PUSH    AF
        ADD     A,C
        LD      C,A
        POP     AF
        JR      UPACC
ULACC:  PUSH    BC
        CALL    INCHR
        CALL    UABIN
        RLCA
        RLCA
        RLCA
        RLCA
        LD      C,A
        CALL    INCHR
        CALL    UABIN
        OR      C
        POP     BC
        PUSH    AF
        ADD     A,C
        LD      C,A
        POP     AF
        RET
OTCHR:  CALL    UBASC
OTCHR1: EI
        LD      D,A
        LD      A,10H
        LD      L,0AH
        RL      D
OTCHR2: CP      01D
        JR      NZ,OTCHR2
        LD      B,A
        LD      A,0
        LD      (FLG24),A
        LD      A,B
OTCHR3: HALT
        SCF
        RR      D
        DEC     L
        JR      NZ,OTCHR4
        LD      A,1
        LD      (FLG24),A
        DI
        RET
OTCHR4: CP      1
        JR      NZ,OTCHR4
        BIT     0,D
        JR      NZ,OTCHR5
        LD      B,A
        LD      A,0
        LD      (FLG24),A
        LD      A,B
        JR      OTCHR3
OTCHR5: LD      B,A
        LD      A,1
        LD      (FLG24),A
        LD      A,B
        JR      OTCHR3
OTCHR6: DEC     A
        JR      NZ,OTCHR8
        LD      IX,FLG24
        BIT     0,(IX+0)
        JR      NZ,OTCHR7
        LD      A,85H
        OUT     (CTC1),A
        LD      A,52D
        OUT     (CTC1),A
        LD      A,8
        JR      OTCHR8
OTCHR7: LD      A,85H
        OUT     (CTC1),A
        LD      A,26D
        OUT     (CTC1),A
        LD      A,16D
OTCHR8: EI
        RETI
INCHR:  LD      HL,CTC3L
        LD      A,H
        LD      I,A
        LD      A,L
        OUT     (CTC0),A
INCHR1: LD      B,8D
        EI
        LD      A,0
        LD      H,0
INCH1A: IN      A,(KBSEL)
        BIT     7,A
        JR      NZ,INCH1A
        LD      A,0A5H
        OUT     (CTC3),A
        LD      A,0DH
        OUT     (CTC3),A
        LD      A,0A5H
        OUT     (CTC3),A
        LD      A,01AH
        OUT     (CTC3),A
        HALT
        BIT     7,A
        JR      NZ,INCHR3
INCHR2: HALT
        AND     80H
        OR      H
        LD      H,A
        DJNZ    INCHR5
        BIT     7,A
        JR      Z,INCHR3
        DI
        LD      A,03H
        OUT     (CTC3),A
        LD      A,H
        AND     7FH
        RET
INCHR3: LD      A,03H
        OUT     (CTC3),A
        JR      INCHR1
INCHR4: IN      A,(KBSEL)
        EI
        RETI
INCHR5: RRC     H
        JR      INCHR2
SEGPT:  DEFB    40H
        DEFB    79H
        DEFB    24H
        DEFB    30H
        DEFB    19H
        DEFB    12H
        DEFB    02H
        DEFB    78H
        DEFB    00H
        DEFB    18H
        DEFB    08H
        DEFB    03H
        DEFB    46H
        DEFB    21H
        DEFB    06H
        DEFB    0EH
        DEFB    7FH
        DEFB    3FH
        DEFB    7DH
KYTBL:  DEFB    0FFH
        DEFB    0EFH
        DEFB    0F7H
        DEFB    0FBH
        DEFB    0DFH
        DEFB    0E7H
        DEFB    0EBH
        DEFB    0CFH
        DEFB    0D7H
        DEFB    0DBH
        DEFB    0DDH
        DEFB    0EDH
        DEFB    0FDH
        DEFB    00DH
        DEFB    00BH
        DEFB    07H
        DEFB    0EH
        DEFB    0FEH
        DEFB    0EEH
        DEFB    0DEH
        DEFB    0CDH
        DEFB    0CBH
        DEFB    0C7H
        DEFB    0BFH
        DEFB    0BDH
        DEFB    0BBH
        DEFB    0B7H
        DEFB    0AFH
REGTB:  DEFB    25D
        DEFB    02D
        DEFB    2D
        DEFB    12D
        DEFB    22D
        DEFB    24D
        DEFB    11D
        DEFB    9D
        DEFB    10D
        DEFB    25D
        DEFB    3D
        DEFB    5D
        DEFB    6D
        DEFB    7D
        DEFB    8D
        DEFB    4D
REGTBP: DEFB    25D
        DEFB    25D
        DEFB    25D
        DEFB    25D
        DEFB    25D
        DEFB    25D
        DEFB    25D
        DEFB    19D
        DEFB    20D
        DEFB    25D
        DEFB    13D
        DEFB    15D
        DEFB    16D
        DEFB    17D
        DEFB    18D
        DEFB    14D

        ORG     07F8H
CTC0_:  DEFW    CTC0V	; kio 2015-01-06: changed name. CTC0_ is never used.
CTC1P:  DEFW    OTCHR6
CTC2_:  DEFS    2	; kio 2015-01-06: changed name. CTC2_ is never used.
CTC3L:  DEFW    INCHR4

#data 	ram,23C0H
PUNHSH: DATA    1
PUNHSL: DATA    1
PUNHEH: DATA    1
PUNHEL: DATA    1
RST16:  DATA    3
RST24:  DATA    3
RST32:  DATA    3
RST40:  DATA    3
RST48:  DATA    3
RST56:  DATA    3
CTC0V:  DATA    3
FLG24:  DATA    1
PRFLG:  DATA    1
KEYPTR: DATA    2
UIF:    DATA    1
PFLG:   DATA    1
RFLG:   DATA    1
ARFLG:  DATA    1
MFLG:   DATA    1
STKPT:  DATA    1
STKPT1: DATA    1
BPTAB:  DATA    15
SSFLG:  DATA    1
BFLG:   DATA    1
DIG2:   DATA    1
DIG4:   DATA    1
DISMEM: DATA    1
DSMEM1: DATA    1
DSMEM2: DATA    1
DSMEM3: DATA    1
DSMEM4: DATA    1
DSMEM5: DATA    1
DSMEM6: DATA    1
DSMEM7: DATA    1
#end
