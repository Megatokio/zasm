#!/usr/local/bin/zasm --8080 -o original/
; Final version 22-07-2014

*LIST ON
p0000   EQU 0                   ; DOS EXIT
p0005   EQU 5                   ; DOS entry point
p0006   EQU 6
x0080   EQU 80H                 ; PSP area

CR      EQU 0DH
LF      EQU 0AH
TAB     EQU 09H

        ORG 100H
p0100:  LD HL,p010A             ; 0100
        JP p470C                ; 0103

xs0106: DB "MAC",0              ; 0106

p010A:  LD (xw4027),HL          ; 010A
        INC A                   ; 010D
        CPL                     ; 010E
        LD D,A                  ; 010F
        LD E,00H                ; 0110
        ADD HL,DE               ; 0112
        LD (xw4029),HL          ; 0113
        XOR A                   ; 0116
        LD BC,033BH             ; 0117 count = 827
        LD HL,xb3CEC            ; 011A address
        LD E,A                  ; 011D
p011E:  LD (HL),E               ; 011E clear range
        INC HL                  ; 011F
        DEC BC                  ; 0120
        LD A,B                  ; 0121
        OR C                    ; 0122
        JP NZ,p011E             ; 0123
        LD HL,x4F35             ; 0126
        LD (xw3D41),HL          ; 0129
        LD (HL),A               ; 012C
        INC H                   ; 012D
        INC H                   ; 012E
        INC H                   ; 012F
        INC H                   ; 0130
        LD (xw401D),HL          ; 0131
        LD BC,0020H             ; 0134
        ADD HL,BC               ; 0137
        LD (xw401F),HL          ; 0138
        LD HL,0F800H            ; 013B
        LD (xb3EC3),HL          ; 013E
        LD HL,xt402B            ; 0141 Register look-up table
p0144:  LD DE,xb3DE9            ; 0144 address
        LD A,(HL)               ; 0147
        OR A                    ; 0148
        JP Z,p0176              ; 0149
        PUSH AF                 ; 014C
        AND 07H                 ; 014D
        LD (DE),A               ; 014F
        LD C,A                  ; 0150
p0151:  INC HL                  ; 0151
        INC DE                  ; 0152
        LD A,(HL)               ; 0153
        LD (DE),A               ; 0154
        DEC C                   ; 0155
        JP NZ,p0151             ; 0156
        PUSH HL                 ; 0159
        CALL p0CFC              ; 015A
        POP DE                  ; 015D
        POP AF                  ; 015E
        AND 0F8H                ; 015F
        LD (HL),A               ; 0161
        INC HL                  ; 0162
        INC DE                  ; 0163
        LD A,(DE)               ; 0164
        INC DE                  ; 0165
        LD (HL),20H             ; 0166
        INC HL                  ; 0168
        LD (HL),A               ; 0169
        EX DE,HL                ; 016A
        JP p0144                ; 016B

p016E:  CALL p4B84              ; 016E
        LD A,01H                ; 0171
        LD (xb3CEC),A           ; 0173
p0176:  XOR A                   ; 0176
        LD (xb4006),A           ; 0177
        LD (xf3E81),A           ; 017A
        LD (xb3D2D),A           ; 017D
        LD (xb3CF3),A           ; 0180
        LD (xb3CF4),A           ; 0183
        LD (xb3DE8),A           ; 0186
        LD (xb3CF5),A           ; 0189
        LD (xb3FFA),A           ; 018C
        LD (xb3DE4),A           ; 018F
        LD HL,xw3DD2            ; 0192
        LD B,0AH                ; 0195
p0197:  LD (HL),A               ; 0197
        INC HL                  ; 0198
        DEC B                   ; 0199
        JP NZ,p0197             ; 019A
        INC A                   ; 019D
        LD (xb3D28),A           ; 019E
        LD (xb3D2E),A           ; 01A1
        LD (xb3D2F),A           ; 01A4
        LD (xb3DD1),A           ; 01A7
        LD A,0AH                ; 01AA
        LD (xb3CF1),A           ; 01AC
        LD A,(xb4088)           ; 01AF
        LD (xb3CEA),A           ; 01B2
        LD A,(xb408D)           ; 01B5
        LD (xb3D2A),A           ; 01B8
        LD A,3BH                ; 01BB
        LD (xb3D33),A           ; 01BD
        INC A                   ; 01C0
        LD (xb3D32),A           ; 01C1
        LD HL,0001H             ; 01C4
        LD (xw3D34),HL          ; 01C7
        DEC HL                  ; 01CA
        LD (xw4016),HL          ; 01CB
        DEC HL                  ; 01CE
        LD (xw3D36),HL          ; 01CF
        LD HL,(xw4027)          ; 01D2
        LD SP,HL                ; 01D5
        LD HL,p02CC             ; 01D6
        PUSH HL                 ; 01D9
        LD HL,p0236             ; 01DA spoofed return address
        PUSH HL                 ; 01DD
p01DE:  XOR A                   ; 01DE
        LD (xb3F5B),A           ; 01DF
        LD (xb3D31),A           ; 01E2
        LD (xb3D2B),A           ; 01E5
        LD (xf3D39),A           ; 01E8
        LD (xb3FFB),A           ; 01EB
        INC A                   ; 01EE
        LD (xb3D29),A           ; 01EF
        CALL p043F              ; 01F2
        POP HL                  ; 01F5
        PUSH HL                 ; 01F6
        LD BC,p01FC             ; 01F7 spoofed return address
        PUSH BC                 ; 01FA
        JP (HL)                 ; 01FB

p01FC:  LD HL,xf3D48            ; 01FC address of buffer
        LD (xw3D46),HL          ; 01FF ptr
        LD BC,840CH             ; 0202 132 count / test byte
p0205:  LD A,(HL)               ; 0205
        CP C                    ; 0206
        CALL Z,p021D            ; 0207
        INC HL                  ; 020A
        CP CR                   ; 020B carriage return?
        JP Z,p0214              ; 020D
        DEC B                   ; 0210
        JP NZ,p0205             ; 0211
p0214:  POP BC                  ; 0214
        POP HL                  ; 0215
        PUSH HL                 ; 0216
        PUSH BC                 ; 0217
        LD BC,p0452             ; 0218 Save return address
        PUSH BC                 ; 021B
        JP (HL)                 ; 021C

p021D:  PUSH AF                 ; 021D
        PUSH HL                 ; 021E
        LD HL,(xw3D34)          ; 021F
        INC HL                  ; 0222
        LD (xw3D34),HL          ; 0223
        LD HL,0FFFFH            ; 0226
        LD (xw3D36),HL          ; 0229
        LD A,(xb3D32)           ; 022C
        DEC A                   ; 022F
        LD (xb3D33),A           ; 0230
        POP HL                  ; 0233
        POP AF                  ; 0234
        RET                     ; 0235

p0236:  LD HL,xf3D39            ; 0236 address
        LD A,01H                ; 0239
        LD (xb4010),A           ; 023B
        LD (xb400F),A           ; 023E
        LD C,06H               ; 0241
p0243:  CALL p0296              ; 0243
        CP 0AH                  ; 0246
        JP Z,p0243              ; 0248
        CALL p02C6              ; 024B
        JP Z,p0243              ; 024E
        OR A                    ; 0251
        JP P,p026C              ; 0252
        AND 7FH                 ; 0255
        INC C                   ; 0257
        DEC C                   ; 0258
        JP Z,p0243              ; 0259
        CALL p02C6              ; 025C
        JP Z,p0243              ; 025F
        CP 30H                  ; 0262
        JP C,p0243              ; 0264
        LD (HL),A               ; 0267
        INC HL                  ; 0268
        JP p0243                ; 0269

p026C:  LD C,83H               ; 026C
        LD HL,xf3D48            ; 026E address of buffer
p0271:  CP 0AH                  ; 0271
        JP Z,p028E              ; 0273
        DEC C                   ; 0276
        INC C                   ; 0277
        JP Z,p027E              ; 0278
        LD (HL),A               ; 027B
        INC HL                  ; 027C
        DEC C                   ; 027D
p027E:  CP CR                   ; 027E carriage return?
        JP NZ,p028E             ; 0280
        LD (HL),A               ; 0283
        LD A,(xf3D39)           ; 0284
        OR A                    ; 0287
        RET Z                   ; 0288
        DEC A                   ; 0289
        LD (xb3D38),A           ; 028A
        RET                     ; 028D

p028E:  CALL p0296              ; 028E
        AND 7FH                 ; 0291
        JP p0271                ; 0293

p0296:  LD A,(xb3D2C)           ; 0296
        OR A                    ; 0299
        JP Z,p02A8              ; 029A
        CALL p4EF4              ; 029D
        RET NC                  ; 02A0
        XOR A                   ; 02A1
        LD (xb3D2C),A           ; 02A2
        CALL p4F34              ; 02A5
p02A8:  CALL p4D04              ; 02A8
        JP C,p02AF              ; 02AB
        RET                     ; 02AE

p02AF:  LD HL,x0500             ; 02AF '%No END statement'
        CALL p46CC              ; 02B2
        LD A,CR                 ; 02B5 carriage return?
        LD (xf3D48),A           ; 02B7
        CALL p4AEE              ; 02BA
        LD A,LF                 ; 02BD line feed?
        CALL p4AEE              ; 02BF
        SCF                     ; 02C2
        JP p2DB2                ; 02C3

p02C6:  CP 0CH                  ; 02C6
        RET NZ                  ; 02C8
        JP p021D                ; 02C9

p02CC:  LD HL,0000H             ; 02CC
        LD (xw3D43),HL          ; 02CF
        XOR A                   ; 02D2
        LD (xb3D30),A           ; 02D3
        DEC A                   ; 02D6
        LD (xb3FFB),A           ; 02D7
        LD HL,(xw3DDA)          ; 02DA
        LD (xw3DDE),HL          ; 02DD
        LD A,(xf3D48)           ; 02E0
        CP 2AH                  ; 02E3
        JP NZ,p02ED             ; 02E5
        LD A,24H                ; 02E8
        LD (xf3D48),A           ; 02EA
p02ED:  SUB 24H                 ; 02ED
        LD (xb3D45),A           ; 02EF
        CALL p0B55              ; 02F2
        JP NZ,p040D             ; 02F5
        CP 3AH                  ; 02F8
        JP Z,p038B              ; 02FA
        LD A,(xb3D45)           ; 02FD
        OR A                    ; 0300
        JP NZ,p0324             ; 0301
        LD A,(xb3DE9)           ; 0304
        DEC A                   ; 0307
        JP NZ,p0324             ; 0308
        CALL p0B55              ; 030B
        LD B,12H                ; 030E
        LD HL,xb3DE9            ; 0310 address
        LD A,(HL)               ; 0313
        CP B                    ; 0314
        JP NC,p0319             ; 0315
        INC (HL)                ; 0318
p0319:  INC HL                  ; 0319
        LD A,24H                ; 031A
p031C:  LD C,(HL)               ; 031C
        LD (HL),A               ; 031D
        LD A,C                  ; 031E
        INC HL                  ; 031F
        DEC B                   ; 0320
        JP NZ,p031C             ; 0321
p0324:  LD HL,(xw3D46)          ; 0324
        DEC HL                  ; 0327
        LD A,(HL)               ; 0328
        INC HL                  ; 0329
        CP CR                   ; 032A <CR>
        JP Z,p03BF              ; 032C
        PUSH HL                 ; 032F
        CALL p042B              ; 0330
        CALL p0B55              ; 0333
        CALL p0515              ; 0336
        JP NZ,p0381             ; 0339
        LD A,(HL)               ; 033C
        OR A                    ; 033D
x033E:  JP P,p0381              ; 033E
        INC HL                  ; 0341
        LD A,(HL)               ; 0342
        CP 22H                  ; 0343
        JP Z,p0352              ; 0345
        CP 1CH                  ; 0348
        JP Z,p0352              ; 034A
        CP CR                   ; 034D <CR>
        JP NZ,p0381             ; 034F
p0352:  POP HL                  ; 0352
        LD HL,(xw3D46)          ; 0353
        DEC HL                  ; 0356
        LD (xw3D46),HL          ; 0357
        PUSH AF                 ; 035A
        LD A,(xb3D28)           ; 035B
        OR A                    ; 035E
        JP Z,p046B              ; 035F
        CALL p042B              ; 0362
        POP AF                  ; 0365
        PUSH AF                 ; 0366
        CP 1CH                  ; 0367
        JP Z,p0373              ; 0369
        OR A                    ; 036C
        CALL p0CFC              ; 036D
        CALL p2D15              ; 0370
p0373:  POP AF                  ; 0373
        CP 22H                  ; 0374
        JP Z,p2D78              ; 0376
        CP 1CH                  ; 0379
        JP Z,p37AF              ; 037B
        JP p2D44                ; 037E

p0381:  POP HL                  ; 0381
        LD (xw3D46),HL          ; 0382
        CALL p042B              ; 0385
        JP p03BF                ; 0388

p038B:  LD A,(xb3D28)           ; 038B
        OR A                    ; 038E
        JP Z,p03B9              ; 038F
        CALL p1B31              ; 0392
        CALL p0CFC              ; 0395
        CALL p2D15              ; 0398
        LD (xw3D43),HL          ; 039B
        EX DE,HL                ; 039E
        CALL p1B6A              ; 039F
        EX DE,HL                ; 03A2
        OR 20H                  ; 03A3
        PUSH AF                 ; 03A5
        CALL p0B23              ; 03A6
        CP 3AH                  ; 03A9
        JP NZ,p03B5             ; 03AB
        POP AF                  ; 03AE
        OR 40H                  ; 03AF
        PUSH AF                 ; 03B1
        CALL p0AEA              ; 03B2
p03B5:  POP AF                  ; 03B5
        CALL p0DDB              ; 03B6
p03B9:  CALL p0B55              ; 03B9
        JP NZ,p040D             ; 03BC
p03BF:  CALL p0B36              ; 03BF
        LD A,(xb3D28)           ; 03C2
        OR A                    ; 03C5
        JP Z,p03CF              ; 03C6
        CALL p0C0E              ; 03C9
        JP Z,p3892              ; 03CC
p03CF:  CALL p0515              ; 03CF
        JP NZ,p040D             ; 03D2
        OR A                    ; 03D5
        PUSH AF                 ; 03D6
        LD A,(xb3D28)           ; 03D7
        OR A                    ; 03DA
        JP NZ,p03E8             ; 03DB
        POP AF                  ; 03DE
        JP P,p046C              ; 03DF
        PUSH AF                 ; 03E2
        AND 60H                 ; 03E3
        JP Z,p046B              ; 03E5
p03E8:  POP AF                  ; 03E8
        JP P,p03FB              ; 03E9
        INC HL                  ; 03EC
        LD A,(HL)               ; 03ED
        LD HL,xt0A06            ; 03EE
p03F1:  ADD A,A                 ; 03F1
        LD E,A                  ; 03F2
        LD D,00H                ; 03F3
        ADD HL,DE               ; 03F5
        LD E,(HL)               ; 03F6
        INC HL                  ; 03F7
        LD D,(HL)               ; 03F8
        EX DE,HL                ; 03F9
        JP (HL)                 ; 03FA

p03FB:  RRA                     ; 03FB
        RRA                     ; 03FC
        RRA                     ; 03FD
        AND 0FH                 ; 03FE
        INC HL                  ; 0400
        LD C,(HL)               ; 0401
        PUSH AF                 ; 0402
        CALL p1B31              ; 0403
        LD HL,xt09E8            ; 0406 Start of address vector
        POP AF                  ; 0409
        JP p03F1                ; 040A

p040D:  CP ';'                  ; 040D
        RET Z                   ; 040F
        CP CR                   ; 0410 carriage return?
        RET Z                   ; 0412
        LD HL,xf3D48            ; 0413 address of buffer
        LD (xw3D46),HL          ; 0416
        LD HL,(xw3D43)          ; 0419
        LD A,H                  ; 041C
        OR L                    ; 041D
        CALL NZ,p0B55           ; 041E
        LD A,(xb3D28)           ; 0421
        OR A                    ; 0424
        JP Z,p046C              ; 0425
        JP p278D                ; 0428

p042B:  LD HL,xb3DE9            ; 042B address
        LD DE,xf3DFC            ; 042E buffer address
        LD B,13H                ; 0431
p0433:  LD C,(HL)               ; 0433
        LD A,(DE)               ; 0434
        LD (HL),A               ; 0435
        LD A,C                  ; 0436
        LD (DE),A               ; 0437
        INC HL                  ; 0438
        INC DE                  ; 0439
        DEC B                   ; 043A
        JP NZ,p0433             ; 043B
        RET                     ; 043E

p043F:  LD HL,xf3E1B            ; 043F buffer address
        LD (xw3E0F),HL          ; 0442
        LD HL,xb3E11            ; 0445
        LD BC,2020H             ; 0448 count / ' '
p044B:  LD (HL),C               ; 044B
        INC HL                  ; 044C
        DEC B                   ; 044D
        JP NZ,p044B             ; 044E
        RET                     ; 0451

p0452:  CALL p0B36              ; 0452
p0455:  CALL p0BC8              ; 0455
        OR A                    ; 0458
        JP Z,p0455              ; 0459
p045C:  PUSH HL                 ; 045C
        CP CR                   ; 045D carriage return?
        JP Z,p046C              ; 045F
        CP ';'                  ; 0462 comment
        JP Z,p046C              ; 0464
        CALL p04CD              ; 0467
        PUSH AF                 ; 046A
p046B:  POP AF                  ; 046B
p046C:  POP HL                  ; 046C
        LD A,(xb3CEC)           ; 046D
        OR A                    ; 0470
        JP NZ,p0497             ; 0471
        LD A,(xb3E11)           ; 0474
        CP 'V'                  ; 0477 [V]
        JP Z,p048B              ; 0479
        CP 'M'                  ; 047C [M]
        JP Z,p048B              ; 047E
        CP 'D'                  ; 0481 [D]
        JP Z,p048B              ; 0483
        CP 'X'                  ; 0486 [X]
        JP NZ,p01DE             ; 0488
p048B:  LD (xb3F5B),A           ; 048B
        CALL p1B16              ; 048E
        CALL p197E              ; 0491
        JP p01DE                ; 0494

p0497:  CALL p192B              ; 0497
        JP p01DE                ; 049A

p049D:  PUSH BC                 ; 049D
        LD B,'A'                ; 049E [A]
        JP p04E8                ; 04A0

p04A3:  PUSH BC                 ; 04A3
        LD B,'C'                ; 04A4 [C]
        JP p04E8                ; 04A6

p04A9:  PUSH BC                 ; 04A9
        LD B,'D'                ; 04AA [D]
        JP p04E8                ; 04AC

p04AF:  PUSH BC                 ; 04AF
        LD B,'E'                ; 04B0 [E]
        JP p04E8                ; 04B2

p04B5:  PUSH BC                 ; 04B5
        LD B,'M'                ; 04B6 [M]
        JP p04E8                ; 04B8

p04BB:  PUSH BC                 ; 04BB
        LD B,'N'                ; 04BC [N]
        JP p04E8                ; 04BE

p04C1:  PUSH BC                 ; 04C1
        LD B,'O'                ; 04C2 [O]
        JP p04E8                ; 04C4

p04C7:  PUSH BC                 ; 04C7
        LD B,'P'                ; 04C8 [P]
        JP p04E8                ; 04CA

p04CD:  PUSH BC                 ; 04CD
        LD B,'Q'                ; 04CE [Q]
        JP p04E8                ; 04D0

p04D3:  PUSH BC                 ; 04D3
        LD B,'R'                ; 04D4 [R]
        JP p04E8                ; 04D6

p04D9:  PUSH BC                 ; 04D9
        LD B,'U'                ; 04DA [U]
        JP p04E8                ; 04DC

p04DF:  PUSH BC                 ; 04DF
        LD B,'V'                ; 04E0 [V]
        JP p04E8                ; 04E2

p04E5:  PUSH BC                 ; 04E5
        LD B,'X'                ; 04E6 [X]
p04E8:  PUSH HL                 ; 04E8
        PUSH AF                 ; 04E9
        LD HL,xb3E11            ; 04EA
        LD A,(HL)               ; 04ED
        CP ' '                  ; 04EE
        JP NZ,p04FC             ; 04F0
        LD (HL),B               ; 04F3
        LD A,(xb3ED4)           ; 04F4
        OR 10H                  ; 04F7
        LD (xb3ED4),A           ; 04F9
p04FC:  POP AF                  ; 04FC
        POP HL                  ; 04FD
        POP BC                  ; 04FE
        RET                     ; 04FF

x0500:  DB "%No END statement",0

p0512:  JP p04C1                ; 0512

p0515:  LD A,(xb3DEA)           ; 0515
        CP 2EH                  ; 0518 [.]
        JP Z,p058A              ; 051A
        CP 24H                  ; 051D [$]
        JP Z,p0592              ; 051F
        CP 5BH                  ; 0522 '['
        INC A                   ; 0524
        RET NC                  ; 0525
        SUB 42H                 ; 0526 'B'
        OR A                    ; 0528
        RET M                   ; 0529
        ADD A,A                 ; 052A
        PUSH BC                 ; 052B
        PUSH DE                 ; 052C
        LD E,A                  ; 052D
        LD D,00H                ; 052E
        LD HL,xt0598            ; 0530 Start of address vector
        ADD HL,DE               ; 0533
        LD E,(HL)               ; 0534
        INC HL                  ; 0535
        LD D,(HL)               ; 0536
        EX DE,HL                ; 0537
p0538:  LD A,(xb3DE9)           ; 0538
        DEC A                   ; 053B
        LD C,A                  ; 053C
p053D:  LD A,(HL)               ; 053D
        OR A                    ; 053E
        JP Z,p0586              ; 053F
        OR A                    ; 0542
        JP M,p055B              ; 0543
        LD A,(xb3CEA)           ; 0546
        ADD A,A                 ; 0549
p054A:  LD A,(HL)               ; 054A
        JP NZ,p0556             ; 054B
        CP 50H                  ; 054E
        JP NC,p055B             ; 0550
        JP p057A                ; 0553

p0556:  CP 50H                  ; 0556
        JP NC,p057A             ; 0558
p055B:  AND 07H                 ; 055B
        CP C                    ; 055D
        JP NZ,p057A             ; 055E
        LD DE,xf3DEB            ; 0561 address
        PUSH HL                 ; 0564
        LD B,C                  ; 0565
        INC HL                  ; 0566
        INC HL                  ; 0567
p0568:  LD A,(DE)               ; 0568
        CP (HL)                 ; 0569
        JP NZ,p0579             ; 056A
        INC HL                  ; 056D
        INC DE                  ; 056E
        DEC B                   ; 056F
        JP NZ,p0568             ; 0570
        POP HL                  ; 0573
        XOR A                   ; 0574
        LD A,(HL)               ; 0575
        POP DE                  ; 0576
        POP BC                  ; 0577
        RET                     ; 0578

p0579:  POP HL                  ; 0579
p057A:  LD A,(HL)               ; 057A
        AND 07H                 ; 057B
        ADD A,02H               ; 057D
        LD E,A                  ; 057F
        LD D,00H                ; 0580
        ADD HL,DE               ; 0582
        JP p053D                ; 0583

p0586:  POP DE                  ; 0586
        POP DE                  ; 0587
        INC A                   ; 0588
        RET                     ; 0589

p058A:  LD HL,xt0948            ; 058A Start of '.' cmmands table
p058D:  PUSH BC                 ; 058D
        PUSH DE                 ; 058E
        JP p0538                ; 058F

p0592:  LD HL,xt09D0            ; 0592 Start of table
        JP p058D                ; 0595

; Address vector for op-codes

xt0598: DW xt05CC               ; 0598 A
        DW xt05FB               ; 059A B
        DW xt0605               ; 059C C
        DW xt066A               ; 059E D
        DW xt06B8               ; 05A0 E
        DW xt0702               ; 05A2 F
        DW xt0703               ; 05A4 G
        DW xt070B               ; 05A6 H
        DW xt0715               ; 05A8 I
        DW xt0787               ; 05AA J
        DW xt07AE               ; 05AC K
        DW xt07AF               ; 05AE L
        DW xt07DD               ; 05B0 M
        DW xt07F3               ; 05B2 N
        DW xt0805               ; 05B4 O
        DW xt0831               ; 05B6 P
        DW xt0855               ; 05B8 Q
        DW xt0856               ; 05BA R
        DW xt08D2               ; 05BC S
        DW xt0925               ; 05BE T
        DW xt092C               ; 05C0 U
        DW xt092D               ; 05C2 V
        DW xt092E               ; 05C4 W
        DW xt092F               ; 05C6 X
        DW xt0946               ; 05C8 Y
        DW xt0947               ; 05CA Z

; 'A's ACI ADC ADC ADD ADD ADI ANA AND
;      ANI ASEG ASET

xt05CC: DB 2AH,0CEH             ; 05CC 5 << 3 OR 2
        DB "CI"                 ; 05CE
        DB 1AH,88H              ; 05D0 4 << 3 OR 2
        DB "DC"                 ; 05D2
        DB 52H,00H              ; 05D4 10 << 3 OR 2
        DB "DC"                 ; 05D6
        DB 1AH,80H              ; 05D8 4 << 3 OR 2
        DB "DD"                 ; 05DA
        DB 52H,02H              ; 05DD 10 << 3 OR 2
        DB "DD"                 ; 05DE
        DB 2AH,0C6H             ; 05E0 5 << 3 OR 2
        DB "DI"                 ; 05E2
        DB 1AH,0A0H             ; 05E4 4 << 3 OR 2
        DB "NA"                 ; 05E6
        DB 52H,04H              ; 05E8 10 << 3 OR 2
        DB "ND"                 ; 05EA
        DB 2AH,0E6H             ; 05EC 5 << 3 OR 2
        DB "NI"                 ; 05EE
        DB 83H,00H              ; 05F0 32 << 3 OR 2
        DB "SEG"                ; 05F2
        DB 83H,22H              ; 05F5 32 << 3 OR 2
        DB "SET"                ; 05F7
        DB 00H                  ; 05FA

; 'B's BIT BYTE

xt05FB: DB 5AH,06H              ; 05FB
        DB "IT"                 ; 05FD
        DB 83H,3EH              ; 05FF
        DB "YTE"                ; 0601
        DB 00H                  ; 0604

; 'C's CALL CALL CC CCF CM CMA CMC CMP
;      CNC CNZ COMMON COND CP CP CPD
;      CPDR CPE CPI CPI CPIR CPL CPO
;      CSEG CZ

xt0605: DB 33H,0CDH             ; 0605
        DB "ALL"                ; 0607
        DB 53H,08H              ; 060A
        DB "ALL"                ; 060C
        DB 31H,0DCH             ; 060F
        DB "C"
        DB 6AH,3FH
        DB "CF"                 ; 0611
        DB 31H,0FCH             ; 0616
        DB "M"                  ; 0618
        DB 02H,2FH              ; 0619
        DB "MA"                 ; 0619
        DB 02H,3FH              ; 061D
        DB "MC"                 ; 061F
        DB 1AH,0B8H             ; 0621
        DB "MP"                 ; 0623
        DB 32H,0D4H             ; 0625
        DB "NC"                 ; 0627
        DB 32H,0C4H             ; 0629
        DB "NZ"                 ; 062B
        DB 85H,01H              ; 062D
        DB "OMMON"              ; 062F
        DB 0C3H,14H             ; 0634
        DB "OND"                ; 0636
        DB 31H,0F4H             ; 0639
        DB "P"                  ; 063B
        DB 51H,0AH              ; 063C
        DB "P"                  ; 063E
        DB 72H,0A9H             ; 063F
        DB "PD"                 ; 0641
        DB 73H,0B9H             ; 0643
        DB "PDR"                ; 0645
        DB 32H,0ECH             ; 0648
        DB "PE"                 ; 064A
        DB 2AH,0FEH             ; 064C
        DB "PI"                 ; 064E
        DB 72H,0A1H             ; 0650
        DB "PI"                 ; 0652
        DB 73H,0B1H             ; 0654
        DB "PIR"
        DB 6AH,2FH
        DB "PL"                 ; 0656
        DB 32H,0E4H             ; 065D
        DB "PO"                 ; 065F
        DB 83H,02H              ; 0661
        DB "SEG"                ; 0663
        DB 31H,0CCH             ; 0666
        DB "Z"                  ; 0668
        DB 00H                  ; 0669

; 'D's DAA DAA DAD DB DC DCR DCX DEC
;      DEFB DEFL DEFM DEFS DEFW DI DI
;      DJNZ DS DSEG DW

xt066A: DB 02H,27H              ; 066A
        DB "AA"                 ; 066C
        DB 6AH,27H              ; 066E
        DB "AA"                 ; 0670
        DB 12H,09H              ; 0672
        DB "AD"                 ; 0674
        DB 81H,03H              ; 0676
        DB "B"                  ; 0678
        DB 81H,04H              ; 0679
        DB "C"                  ; 067B
        DB 22H,05H              ; 067C
        DB "CR"                 ; 067E
        DB 12H,0BH              ; 0680
        DB "CX"                 ; 0682
        DB 52H,0CH              ; 0684
        DB "EC"                 ; 0686
        DB 83H,03H              ; 0688
        DB "EFB"                ; 068A
        DB 83H,22H              ; 068D
        DB "EFL"                ; 068E
        DB 83H,03H              ; 0692
        DB "EFM"                ; 0694
        DB 83H,05H              ; 0697
        DB "EFS"                ; 0699
        DB 83H,07H              ; 069C
        DB "EFW"                ; 069E
        DB 01H,0F3H             ; 06A1
        DB "I"                  ; 06A3
        DB 69H,0F3H             ; 06A4
        DB "I"                  ; 06A6
        DB 53H,0EH              ; 06A7
        DB "JNZ"                ; 06A9
        DB 81H,05H              ; 06AC
        DB "S"                  ; 06AE
        DB 83H,06H              ; 06AF
        DB "SEG"                ; 06B1
        DB 81H,07H              ; 06B4
        DB "W"                  ; 06B6
        DB 00H                  ; 06B7

; 'E's EI EI ELSE END ENDC ENDIF ENDM
;      ENTRY EQU EX EXX EXITM EXT
;      EXTERNAL EXTRN

xt06B8: DB 01H,0FBH             ; 06B8
        DB "I"                  ; 06BA
        DB 69H,0FBH
        DB "I"                  ; 06BD
        DB 0C3H,08H             ; 06BE
        DB "LSE"                ; 06C0
        DB 82H,09H              ; 06C3
        DB "ND"                 ; 06C5
        DB 0A3H,0AH             ; 06C7
        DB "NDC"                ; 06C9
        DB 0A4H,0AH             ; 06CC
        DB "NDIF"               ; 06CE
        DB 8BH,0BH              ; 06D2
        DB "NDM"                ; 06D4
        DB 84H,0CH              ; 06D7
        DB "NTRY"               ; 06D9
        DB 82H,0DH              ; 06DD
        DB "QU"                 ; 06DF
        DB 51H,10H              ; 06E1
        DB "X"                  ; 06E3
        DB 6AH,0D9H             ; 06E4
        DB "XX"                 ; 06E6
        DB 84H,0EH              ; 06E8
        DB "XITM"               ; 06EA
        DB 82H,0FH              ; 06EE
        DB "XT"                 ; 06F0
        DB 87H,0FH              ; 06F2
        DB "XTERNAL"            ; 06F4
        DB 84H,10H              ; 06FB
        DB "XTRN"               ; 06FD
        DB 00H                  ; 0701

; 'F's none

xt0702: DB 00H                  ; 0702

; 'G's GLOBAL

xt0703: DB 85H,20H              ; 0703
        DB "LOBAL"              ; 0705
        DB 00H                  ; 070A

; 'H's HALT HLT

xt070B: DB 6BH,76H
        DB "ALT"                ; 070c
        DB 02H,76H              ; 0710
        DB "LT"                 ; 0712
        DB 00H                  ; 0714

; 'I's IF IFB IFDIF IFE IFF IFIDN IFT
;      IM IN IN INCLUDE IND INDR INI
;      INIR INX IF1 IF2 IFDEF IPR IPRC

xt0715: DB 0C1H,11H             ; 0715
        DB "F"                  ; 0717
        DB 0C2H, 32H            ; 0718
        DB "FB"                 ; 071A
        DB 0C4H,39H             ; 071C
        DB "FDIF"               ; 071D
        DB 0C2H,12H             ; 0722
        DB "FE"                 ; 0724
        DB 0C2H,13H             ; 0726
        DB "FF"                 ; 0728
        DB 0C4H,3AH             ; 072A
        DB "FIDN"               ; 072B
        DB 0C3H,33H             ; 0730
        DB "FNB"                ; 0732
        DB 0C2H,14H             ; 0735
        DB "FT"                 ; 0737
        DB 61H,12H              ; 0739
        DB "M"                  ; 073B
        DB 29H,0DBH             ; 073C
        DB "N"                  ; 073E
        DB 51H,14H              ; 073F
        DB "N"                  ; 0741
        DB 52H,16H              ; 0742
        DB "NC"                 ; 0744
        DB 86H,38H              ; 0746
        DB "NCLUDE"             ; 0748
        DB 72H,0AAH             ; 074E
        DB "ND"                 ; 0750
        DB 73H,0BAH             ; 0752
        DB "NDR"                ; 0754
        DB 72H,0A2H             ; 0757
        DB "NI"                 ; 0759
        DB 73H,0B2H             ; 075B
        DB "NIR"                ; 075D
        DB 22H,04H              ; 0760
        DB "NR"                 ; 0762
        DB 12H,03H              ; 0764
        DB "NX"                 ; 0766
        DB 0C2H,15H             ; 0768
        DB "F1"                 ; 076A
        DB 0C2H,16H             ; 076C
        DB "F2"                 ; 076E
        DB 0C4H,17H             ; 0770
        DB "FDEF"               ; 0772
        DB 0C5H,18H             ; 0776
        DB "FNDEF"              ; 0778
        DB 92H,19H              ; 077D
        DB "RP"                 ; 077F
        DB 93H,1AH              ; 0781
        DB "RPC"                ; 0783
        DB 00H                  ; 0786
		
; 'J's JC JM JMP JNC JNZ JP JP
;      JPE JPO JR JZ
 
xt0787: DB 31H,0DAH             ; 0787
        DB "C"                  ; 0789
        DB 31H,0FAH             ; 078A
        DB "M"                  ; 078C
        DB 32H,0C3H             ; 078D
        DB "MP"                 ; 078F
        DB 32H,0D2H             ; 0791
        DB "NC"                 ; 0793
        DB 32H,0C2H             ; 0795
        DB "NZ"                 ; 0797
        DB 31H,0F2H             ; 0799
        DB "P"                  ; 079B
        DB 51H,18H              ; 079C
        DB "P"                  ; 079E
        DB 32H,0EAH             ; 09F0
        DB "PE"                 ; 07A1
        DB 32H,0E2H             ; 07A3
        DB "PO"                 ; 07A5
        DB 51H,1AH              ; 07A7
        DB "R"                  ; 07A9
        DB 31H,0CAH             ; 07AA
        DB "Z"                  ; 07AC
        DB 00H                  ; 07AD
		
; 'K's none

xt07AE: DB 00H                  ; 07AE

; 'L's LD LDA LDAX LDD LDDR LDI LDIR
;      LHLD LOCAL LXI

xt07AF: DB 51H,1CH              ; 07AF
        DB "D"                  ; 07B1
        DB 32H,3AH              ; 07B2
        DB "DA"                 ; 07B5
        DB 0BH,0AH              ; 07B6
        DB "DAX"                ; 07B8
        DB 72H,0A8H             ; 07BB
        DB "DD"                 ; 07BD
        DB 73H,0B8H             ; 07BF
        DB "DDR"                ; 07C1
        DB 72H,0A0H             ; 07C4
        DB "DI"                 ; 07C6
        DB 73H,0B0H             ; 07C8
        DB "DIR"                ; 07CA
        DB 33H,2AH              ; 07CD
        DB "HLD"                ; 07CF
        DB 84H,1BH              ; 07D2
        DB "OCAL"               ; 07D4
        DB 4AH,01H              ; 07D8
        DB "XI"                 ; 07DA
        DB 00H                  ; 07DC
		
; 'M's MACLIB MACRO MOV MVI

xt07DD: DB 85H,38H              ; 07DD
        DB "ACLIB"              ; 07DF
        DB 94H,1CH              ; 07E4
        DB "ACRO"               ; 07E6
        DB 3AH,40H              ; 07EA
        DB "OV"                 ; 07EC
        DB 42H,06H              ; 07EE
        DB "VI"                 ; 07F0
        DB 00H                  ; 07F2
		
; 'N's NAME NEG NOP NOP

xt07F3: DB 83H,1DH              ; 07F3
        DB "AME"                ; 07F5
        DB 72H,44H              ; 07F8
        DB "EG"                 ; 07FA
        DB 02H,00H              ; 07FC
        DB "OP"                 ; 07FE
        DB 6AH,00H              ; 0800
        DB "OP"                 ; 0802
        DB 00H                  ; 0804
		
; 'O's OR ORA ORG ORI OTDR OTIR OUT OUT
;      OUTD OUTI

xt0805: DB 51H,1EH              ; 0805
        DB "R"                  ; 0807
        DB 1AH,0B0H             ; 0808
        DB "RA"                 ; 080A
        DB 82H,1EH              ; 080C
        DB "RG"                 ; 080E
        DB 2AH,0F6H             ; 0810
        DB "RI"                 ; 0812
        DB 73H,0BBH             ; 0814
        DB "TDR"                ; 0816
        DB 73H,0B3H             ; 0819
        DB "TIR"                ; 081B
        DB 2AH,0D3H             ; 081E
        DB "UT"                 ; 0820
        DB 52H,20H              ; 0822
        DB "UT"                 ; 0824
        DB 73H,0ABH             ; 0826
        DB "UTD"                ; 0828
        DB 73H,0A3H             ; 082B
        DB "UTI"                ; 082D
        DB 00H                  ; 0830
		
; 'P's PAGE PCHL POP POP PUBLIC PUSH
;      PUSH

xt0831: DB 83H,1FH              ; 0831
        DB "AGE"                ; 0833
        DB 03H,0E9H             ; 0836
        DB "CHL"                ; 0838
        DB 12H,0C1H             ; 083B
        DB "OP"                 ; 083D
        DB 52H,22H              ; 083F
        DB "OP"                 ; 0841
        DB 85H,20H              ; 0843
        DB "UBLIC"              ; 0845
        DB 13H,0C5H             ; 084A
        DB "USH"                ; 084C
        DB 53H,24H              ; 084F
        DB "USH"                ; 0851
        DB 00H                  ; 0854
		
; 'Q's none

xt0855: DB 00H                  ; 0855

; 'R's RAL RAR RC REPT RES RET RET RETI
;      RETN RIM RNC RNZ RP RPE RPO RR
;      RRA RRC RRC RRCA RRD RST RST RZ

xt0856: DB 02H,17H              ; 0856
        DB "AL"                 ; 0858
        DB 02H,1FH              ; 085A
        DB "AR"                 ; 085C
        DB 01H,0D8H             ; 085E
        DB "C"                  ; 0860
        DB 93H,21H              ; 0861
        DB "EPT"                ; 0862
        DB 5AH,26H              ; 0865
        DB "ES"                 ; 0867
        DB 02H,0C9H             ; 0869
        DB "ET"                 ; 086B
        DB 52H,28H              ; 086D
        DB "ET"                 ; 086F
        DB 73H, 4DH             ; 0871
        DB "ETI"                ; 0873
        DB 73H,45H              ; 0876
        DB "ETN"                ; 0878
        DB 02H,20H              ; 087B
        DB "IM"                 ; 087D
        DB 59H,2AH              ; 087F
        DB "L"                  ; 0881
        DB 6AH,17H              ; 0882
        DB "LA"                 ; 0884
        DB 02H,07H              ; 0886
        DB "LC"                 ; 0888
        DB 5AH,2CH              ; 088A
        DB "LC"                 ; 088C
        DB 6BH,07H              ; 088E
        DB "LCA"                ; 0890
        DB 72H,6FH              ; 0893
        DB "LD"                 ; 0895
        DB 01H,0F8H             ; 0897
        DB "M"                  ; 0899
        DB 02H,0D0H             ; 089A
        DB "NC"                 ; 089C
        DB 02H,0C0H             ; 089E
        DB "NZ"                 ; 08A0
        DB 01H,0F0H             ; 08A2
        DB "P"                  ; 08A4
        DB 02H,0E8H             ; 08A5
        DB "PE"                 ; 08A7
        DB 02H,0E0H             ; 08A9
        DB "PO"                 ; 08AB
        DB 59H,2EH              ; 08AD
        DB "R"                  ; 08AF
        DB 6AH,1FH              ; 08B1
        DB "RA"                 ; 08B3
        DB 02H,0FH              ; 08B5
        DB "RC"                 ; 08B7
        DB 5AH,30H
        DB "RC"
        DB 6BH,0FH              ; 08BD
        DB "RCA"                ; 08BF
        DB 72H,67H
        DB "RD"
        DB 22H,0C7H             ; 08C7
        DB "ST"
        DB 52H,32H
        DB "ST"                 ; 08C8
        DB 01H,0C8H             ; 08CE
        DB "Z"                  ; 08D0
        DB 00H                  ; 08D1

; 'S's SBB SBI SBC SCF SET SET SHLD SIM
;      SLA SPHL SRA SRL STA STAX STC SUB
;      SUB SUBTTL SUI

xt08D2: DB 1AH,98H              ; 08D2
        DB "BB"                 ; 08D4
        DB 2AH,0DEH             ; 08D6
        DB "BI"                 ; 08D8
        DB 52H,34H              ; 08DA
        DB "BC"                 ; 08DC
        DB 6AH,37H              ; 08DE
        DB "CF"                 ; 08F0
        DB 5AH,36H              ; 08F2
        DB "ET"                 ; 08F4
        DB 82H,22H              ; 08E6
        DB "ET"
        DB 33H,22H
        DB "HLD"                ; 08E7
        DB 02H,30H              ; 08EF
        DB "IM"                 ; 08F1
        DB 5AH,38H
        DB "LA" 
        DB 03H,0F9H             ; 08F7
        DB "PHL"                ; 08F9
        DB 5AH,3AH
        DB "RA"
        DB 5AH,3CH
        DB "RL"
        DB 32H,32H
        DB "TA"
        DB 0BH,02H              ; 0908
        DB "TAX"                ; 090A
        DB 02H,37H              ; 090D
        DB "TC"                 ; 090F
        DB 1AH,90H              ; 0911
        DB "UB"
        DB 52H,3EH
        DB "UB"                 ; 0913
        DB 85H,23H              ; 0919
        DB "UBTTL"              ; 091B
        DB 2AH,0D6H             ; 0920
        DB "UI"                 ; 0922
        DB 00H                  ; 0924

; 'T's TITLE

xt0925: DB 84H,24H              ; 0925
        DB "ITLE"               ; 0927
        DB 00H                  ; 092B
		
; 'U's none

xt092C: DB 00H                  ; 092C

; 'V's none

xt092D: DB 00H                  ; 092D

; 'W's none

xt092E: DB 00H                  ; 092E

; 'X's XCHG XOR XRA XRI XTHL

xt092F: DB 03H,0EBH             ; 092F
        DB "CHG"
        DB 52H,40H
        DB "OR"                 ; 0931
        DB 1AH,0A8H             ; 0938
        DB "RA"                 ; 093A
        DB 2AH,0EEH             ; 093C
        DB "RI"                 ; 093E
        DB 03H,0E3H             ; 0940
        DB "THL"                ; 0942
        DB 00H                  ; 0945

; 'Y's none

xt0946: DB 00H                  ; 0946

; 'Z's none

xt0947: DB 00H

; '.'s  .8080 .Z80 .COMMENT .CRF .DEPHASE
;       .LALL .PASS2 .PHASE .PRINTX .RADIX
;       .RADIX .REQUEST .SALL .SFCOND
;       .SALL .SFCOND .TFCOND .XALL
;       .XCREF .XLIST

xt0948: DB 84H,36H              ; 0948
        DB "8080"               ; 094A
        DB 83H,37H              ; 094E
        DB "Z80"                ; 094F
        DB 87H,25H              ; 0953
        DB "COMMENT"            ; 0955
        DB 84H,26H              ; 095C
        DB "CREF"               ; 095E
        DB 87H ,27H             ; 0962
        DB "DEPHASE"            ; 0963
        DB 84H,28H              ; 096B
        DB "LALL"               ; 096D
        DB 86H,3BH              ; 0971
        DB "LFCOND"             ; 0973
        DB 84H,29H              ; 0979
        DB "LIST"               ; 097B
        DB 85H,2AH              ; 097F
        DB "PASS2"              ; 0981
        DB 85H,2BH              ; 0986
        DB "PHASE"              ; 0988
        DB 86H,2CH              ; 098D
        DB "PRINTX"             ; 098F
        DB 85H,2DH              ; 0995
        DB "RADIX"              ; 0997
        DB 87H,35H              ; 099C
        DB "REQUEST"            ; 099E
        DB 84H,2EH              ; 09A5
        DB "SALL"               ; 09A7
        DB 86H,3CH              ; 09AB
        DB "SFCOND"             ; 09AD
        DB 86H,3DH              ; 09B3
        DB "TFCOND"             ; 09B5
        DB 84H,2FH              ; 09BB
        DB "XALL"               ; 09BD
        DB 85H,30H              ; 09C1
        DB "XCREF"              ; 09C3
        DB 85H,31H              ; 09C8
        DB "XLIST"              ; 09C8
        DB 00H                  ; 09CF

;      EJECT INCLUDE TITLE

xt09D0: DB 85H,1FH              ; 09D0
        DB "EJECT"              ; 09D2
        DB 87H,38H              ; 09D7
        DB "INCLUDE"            ; 09D9
        DB 85H,34H              ; 09E0
        DB "TITLE"              ; 09E2
        DB 00H                  ; 09E7

xt09E8: DW p0E79                ;
        DW p0E80                ;
        DW p0E8F                ;
        DW p0E9E                ;
        DW p0EAA                ;
        DW p0EB9                ;
        DW p0EC7                ;
        DW p0ED3                ;
        DW p0EF4                ;
        DW p0F10                ;
        DW p0F68                ;
        DW p0F6B                ; mid-command
        DW p0F6E                ; mid-command
        DW p0E79                ;
        DW p0E74                ; 0A04

xt0A06: DW p26EF                ; 0A06
        DW p2C8E                ; 0A08
        DW p2708                ; 0A0A
        DW p278D
        DW p283E                ; 0A0E
        DW p2883                ; 0A10
        DW p271D                ; 0A12
        DW p28D7                ; 0A14
        DW p2916                ; 0A16
        DW p2DB2                ; 0A18
        DW p28EA                ; 0A1A
        DW p3528                ; 0A1C
        DW p2A89                ; 0A1E
        DW p04C1                ; 0A20
        DW p350E                ; 0A22
        DW p2CDD                ; 0A24
        DW p2CDD                ; 0A26
        DW p297F                ; 0A28
        DW p2987                ; 0A2A
        DW p2987                ; 0A2C
        DW p297F                ; 0A2E
        DW p2994                ; 0A30
        DW p299E                ; 0A32
        DW p29A8                ; 0A34
        DW p29A9                ; 0A36 mid-command
        DW p3668                ; 0A38 mid-command
        DW p3666                ; 0A3A
        DW p3528                ; 0A3C
        DW p04C1                ; 0A3E
        DW p2C43                ; 0A40
        DW p267E                ; 0A42
        DW p2BBE                ; 0A44
        DW p2A89                ; 0A46
        DW p3441                ; 0A48
        DW p04C1                ; 0A4A
        DW p2ABE                ; 0A4C
        DW p2AB5                ; 0A4E
        DW p3769                ; 0A50
        DW p2B1A                ; 0A52
        DW p3986                ; 0A54
        DW p2B4D                ; 0A56
        DW p2B0B                ; 0A58
        DW p0512                ; 0A5A
        DW p395B                ; 0A5C
        DW p373B                ; 0A5E
        DW p2B92                ; 0A60
        DW p2B55                ; 0A62
        DW p2B5C                ; 0A64
        DW p2B21                ; 0A66
        DW p2B13                ; 0A68
        DW p29E3                ; 0A6A
        DW p29E4                ; 0A6C mid-command
        DW p2AE9                ; 0A6E
        DW p2BEA                ; 0A70
        DW p2B83                ; 0A72
        DW p2B8B                ; 0A74
        DW p2C16                ; 0A76
        DW p29F8                ; 0A78 mid-command
        DW p29F7                ; 0A7A
        DW p2B64                ; 0A7C
        DW p2B68                ; 0A7E
        DW p2B6D                ; 0A80
        DW p2D27                ; 0A82
;=====================================
xt0A84: DB 04H,88H              ; 0A84
        DB 06H,80H              ; 0A86
        DB 00H,0A0H             ; 0A88
        DB 02H,40H              ; 0A8A
        DB 0CH,0CDH             ; 0A8C
        DB 00H,0B8H             ; 0A8E
        DB 08H,05H              ; 0A90
        DB 16H,10H              ; 0A92
        DB 1EH,00H              ; 0A94
        DB 0AH,46H              ; 0A96      
        DB 1AH,00H              ; 0A98
        DB 08H,04H              ; 0A9A
        DB 10H,0C3H             ; 0A9C
        DB 12H,18H              ; 0A9E
        DB 22H,00H              ; 0AA0
        DB 00H,0B0H             ; 0AA2
        DB 1CH,00H              ; 0AA4
        DB 20H,0C1H             ; 0AA6
        DB 20H,0C5H             ; 0AA8
        DB 02H,80H              ; 0AAA
        DB 0EH,00H              ; 0AAC
        DB 14H,10H              ; 0AAE
        DB 14H,00H              ; 0ABO
        DB 14H,18H              ; 0AB2
        DB 14H,08H              ; 0AB4
        DB 18H,0C7H             ; 0AB6
        DB 04H,98H              ; 0AB8
        DB 02H,0C0H             ; 0ABA
        DB 14H,20H              ; 0ABC
        DB 14H,28H              ; 0ABE
        DB 14H,38H              ; 0AC0
        DB 00H,90H              ; 0AC2
        DB 00H,0A8H             ; 0AC4
;=====================================
xt0AC6: DW p1335                ; 0AC6
        DW p1284                ; 0AC8
        DW p1376                ; 0ACA
        DW p13BF                ; 0ACC
        DW p12E9                ; 0ACE
        DW p0F83                ; 0AD0
        DW p1043                ; 0AD2
        DW p0FCD                ; 0AD4
        DW p1064                ; 0AD6
        DW p1090                ; 0AD8
        DW p1298                ; 0ADA
        DW p1101                ; 0ADC
        DW p0FA3                ; 0ADE
        DW p11CF                ; 0AE0
        DW p117D                ; 0AE2
        DW p1212                ; 0AE4
        DW p0FB5                ; 0AE6
        DW p1420                ; 0AE8
;=====================================
p0AEA:  PUSH HL                 ; 0AEA
p0AEB:  LD HL,(xw3D46)          ; 0AEB
        LD A,(HL)               ; 0AEE
        INC HL                  ; 0AEF
        LD (xw3D46),HL          ; 0AF0
        CP 0CH                  ; 0AF3
        JP Z,p0AEB              ; 0AF5
        LD L,A                  ; 0AF8
        CP 'A'                  ; 0AF9
        JP NC,p0B10             ; 0AFB
p0AFE:  CP '0'                  ; 0AFE
        JP C,p0B08              ; 0B00
        CP '9'+1                ; 0B03
        JP C,p0B0D              ; 0B05
p0B08:  SCF                     ; 0B08
        SBC A,A                 ; 0B09
        LD A,L                  ; 0B0A
        POP HL                  ; 0B0B
        RET                     ; 0B0C

p0B0D:  OR A                    ; 0B0D
        POP HL                  ; 0B0E
        RET                     ; 0B0F

p0B10:  CP 'Z'+1                ; 0B10
        JP C,p0B1F              ; 0B12
        CP 'a'                  ; 0B15
        JP C,p0B08              ; 0B17
        CP 'z'+1                ; 0B1A
        JP NC,p0B08             ; 0B1C
p0B1F:  XOR A                   ; 0B1F
        LD A,L                  ; 0B20
        POP HL                  ; 0B21
        RET                     ; 0B22

p0B23:  CALL p0AEA              ; 0B23
        JP p0B36                ; 0B26

p0B29:  CALL p0AEA              ; 0B29
        PUSH AF                 ; 0B2C
        CP 0DH                  ; 0B2D
        JP NZ,p18C7             ; 0B2F
        CALL p04C1              ; 0B32
        POP AF                  ; 0B35
p0B36:  PUSH HL                 ; 0B36
        LD HL,(xw3D46)          ; 0B37
        DEC HL                  ; 0B3A
        LD (xw3D46),HL          ; 0B3B
x0B3E:  POP HL                  ; 0B3E
        RET                     ; 0B3F

p0B40:  LD HL,(xw3D46)          ; 0B40
        INC HL                  ; 0B43
        LD (xw3D46),HL          ; 0B44
        RET                     ; 0B47

p0B48:  CALL p0AEA              ; 0B48
        RET NZ                  ; 0B4B
        CP 'a'                  ; 0B4C
        JP C,p0B53              ; 0B4E
        SUB 20H                 ; 0B51
p0B53:  CP A                    ; 0B53
        RET                     ; 0B54

p0B55:  CALL p0BC8              ; 0B55
        CALL p0B36              ; 0B58
        LD HL,xb3DEA            ; 0B5B
        LD BC,1220H             ; 0B5E count, ' '
p0B61:  LD (HL),C               ; 0B61
        INC HL                  ; 0B62
        DEC B                   ; 0B63
        JP NZ,p0B61             ; 0B64
        LD HL,xb3DE9            ; 0B67 address
        LD (HL),00H             ; 0B6A
        INC HL                  ; 0B6C
        CALL p0BB1              ; 0B6D
        CALL NZ,p0C02           ; 0B70
p0B73:  LD (xb3CE6),A           ; 0B73
        LD C,00H                ; 0B76
p0B78:  CP 'a'                  ; 0B78
        JP C,p0B7F              ; 0B7A
        SUB 20H                 ; 0B7D
p0B7F:  LD (HL),A               ; 0B7F
        INC HL                  ; 0B80
        INC C                   ; 0B81
        LD A,C                  ; 0B82
        CP 12H                  ; 0B83
        JP Z,p0B9F              ; 0B85
        CALL p0BB1              ; 0B88
        JP P,p0B78              ; 0B8B
        CALL p0BDA              ; 0B8E
        JP NC,p0B97             ; 0B91
        JP P,p0B78              ; 0B94
p0B97:  LD B,A                  ; 0B97
        LD A,C                  ; 0B98
        LD (xb3DE9),A           ; 0B99
        XOR A                   ; 0B9C
        LD A,B                  ; 0B9D
        RET                     ; 0B9E

p0B9F:  CALL p0BB1              ; 0B9F
p0BA2:  JP P,p0B9F              ; 0BA2
        CALL p0BDA              ; 0BA5
        JP NC,p0B97             ; 0BA8
        JP P,p0B9F              ; 0BAB
        JP p0B97                ; 0BAE

p0BB1:  CALL p0AEA              ; 0BB1
        RET P                   ; 0BB4
        CP '$'                  ; 0BB5
        RET Z                   ; 0BB7
        CP '.'                  ; 0BB8
        RET Z                   ; 0BBA
        CP '@'                  ; 0BBB
        RET Z                   ; 0BBD
        CP '?'                  ; 0BBE
        RET Z                   ; 0BC0
        CP '_'                  ; 0BC1
        RET Z                   ; 0BC3
        CPL                     ; 0BC4
        OR A                    ; 0BC5
        CPL                     ; 0BC6
        RET                     ; 0BC7

p0BC8:  CALL p0AEA              ; 0BC8
        RET P                   ; 0BCB
        CP ' '                  ; 0BCC
        JP Z,p0BC8              ; 0BCE
        CP 09H                  ; 0BD1
        JP Z,p0BC8              ; 0BD3
        CPL                     ; 0BD6
        OR A                    ; 0BD7
        CPL                     ; 0BD8
        RET                     ; 0BD9

p0BDA:  PUSH AF                 ; 0BDA
        OR A                    ; 0BDB
        JP Z,p0BE4              ; 0BDC
        CP 26H                  ; 0BDF ^Z
        JP NZ,p18C7             ; 0BE1
p0BE4:  LD A,(xb3FFB)           ; 0BE4
        OR A                    ; 0BE7
        JP NZ,p0BED             ; 0BE8
        POP AF                  ; 0BEB
        RET                     ; 0BEC

p0BED:  POP AF                  ; 0BED
p0BEE:  CALL p0BB1              ; 0BEE
        OR A                    ; 0BF1
        JP Z,p0BEE              ; 0BF2
        CP 26H                  ; 0BF5 ^Z
        JP Z,p0BEE              ; 0BF7
        CALL p0B36              ; 0BFA
        CALL p0BB1              ; 0BFD
        SCF                     ; 0C00
        RET                     ; 0C01

p0C02:  CALL p0BDA              ; 0C02
        JP NC,p0C09             ; 0C05
        RET Z                   ; 0C08
p0C09:  POP BC                  ; 0C09
        LD C,00H                ; 0C0A
        LD B,A                  ; 0C0C
        RET                     ; 0C0D

p0C0E:  LD HL,xf3F72            ; 0C0E start of buffer
        LD A,(xb3DE9)           ; 0C11
        PUSH AF                 ; 0C14
        CALL p0C27              ; 0C15
        JP Z,p0C22              ; 0C18
        POP AF                  ; 0C1B
        LD (xb3DE9),A           ; 0C1C
        OR A                    ; 0C1F
        LD A,(HL)               ; 0C20
        RET                     ; 0C21

p0C22:  POP BC                  ; 0C22
        RET                     ; 0C23

p0C24:  LD HL,xf3FB4            ; 0C24 start of buffer
p0C27:  CALL p0CDC              ; 0C27
        LD B,00H                ; 0C2A
        ADD HL,BC               ; 0C2C
        ADD HL,BC               ; 0C2D
        LD (xw3F70),HL          ; 0C2E
        LD E,(HL)               ; 0C31
        INC HL                  ; 0C32
        LD D,(HL)               ; 0C33
        LD HL,xf3F67            ; 0C34 address
        LD B,09H                ; 0C37
        XOR A                   ; 0C39
p0C3A:  LD (HL),A               ; 0C3A
        INC HL                  ; 0C3B
        DEC B                   ; 0C3C
        JP NZ,p0C3A             ; 0C3D
        LD HL,xb3DE9            ; 0C40 address
        LD A,(HL)               ; 0C43
        CP 10H                  ; 0C44
        JP C,p0C4B              ; 0C46
        LD (HL),10H             ; 0C49
p0C4B:  LD HL,xb3DE9            ; 0C4B address
        LD C,(HL)               ; 0C4E
        DEC C                   ; 0C4F
p0C50:  LD A,D                  ; 0C50
        OR E                    ; 0C51
        JP Z,p0CBE              ; 0C52
        EX DE,HL                ; 0C55
        LD E,(HL)               ; 0C56
        INC HL                  ; 0C57
        LD D,(HL)               ; 0C58
        PUSH DE                 ; 0C59
        INC HL                  ; 0C5A
        LD E,(HL)               ; 0C5B
        INC HL                  ; 0C5C
        LD D,(HL)               ; 0C5D
        PUSH DE                 ; 0C5E
        PUSH HL                 ; 0C5F
        INC HL                  ; 0C60
        LD A,(HL)               ; 0C61
        DEC A                   ; 0C62
        JP Z,p0C79              ; 0C63
        LD DE,0008H             ; 0C66
        ADD HL,DE               ; 0C69
        LD DE,xf3DEB            ; 0C6A address
        LD B,A                  ; 0C6D
p0C6E:  LD A,(DE)               ; 0C6E
        CP (HL)                 ; 0C6F
        JP NZ,p0C8B             ; 0C70
        INC HL                  ; 0C73
        INC DE                  ; 0C74
        DEC B                   ; 0C75
        JP NZ,p0C6E             ; 0C76
p0C79:  POP HL                  ; 0C79
        INC HL                  ; 0C7A
        LD A,(HL)               ; 0C7B
        DEC A                   ; 0C7C
        CP C                    ; 0C7D
        JP NZ,p0CB8             ; 0C7E
        INC HL                  ; 0C81
        LD (xw3D3F),HL          ; 0C82
        INC HL                  ; 0C85
        LD A,(HL)               ; 0C86
        DEC HL                  ; 0C87
        POP BC                  ; 0C88
        POP BC                  ; 0C89
        RET                     ; 0C8A

p0C8B:  CCF                     ; 0C8B
        SBC A,A                 ; 0C8C
        AND 02H                 ; 0C8D
        POP HL                  ; 0C8F
p0C90:  PUSH AF                 ; 0C90
        EX DE,HL                ; 0C91
        DEC DE                  ; 0C92
        DEC DE                  ; 0C93
        DEC DE                  ; 0C94
        PUSH AF                 ; 0C95
        PUSH DE                 ; 0C96
        LD DE,xf3F6A            ; 0C97 address
        LD HL,xf3F67            ; 0C9A address
        LD B,06H                ; 0C9D
p0C9F:  LD A,(DE)               ; 0C9F
        LD (HL),A               ; 0CA0
        INC HL                  ; 0CA1
        INC DE                  ; 0CA2
        DEC B                   ; 0CA3
        JP NZ,p0C9F             ; 0CA4
        POP DE                  ; 0CA7
        POP AF                  ; 0CA8
        LD (HL),A               ; 0CA9
        INC HL                  ; 0CAA
        LD (HL),E               ; 0CAB
        INC HL                  ; 0CAC
        LD (HL),D               ; 0CAD
        POP AF                  ; 0CAE
        POP HL                  ; 0CAF
        POP DE                  ; 0CB0
        JP Z,p0C50              ; 0CB1
        EX DE,HL                ; 0CB4
        JP p0C50                ; 0CB5

p0CB8:  DEC HL                  ; 0CB8
        LD A,02H                ; 0CB9
        JP p0C90                ; 0CBB

p0CBE:  INC A                   ; 0CBE
        LD HL,(xw3D41)          ; 0CBF
        LD A,(HL)               ; 0CC2
        RET                     ; 0CC3

p0CC4:  LD HL,(xw401B)          ; 0CC4
        INC HL                  ; 0CC7
        INC HL                  ; 0CC8
        INC HL                  ; 0CC9
        INC HL                  ; 0CCA
        LD A,(HL)               ; 0CCB
        OR A                    ; 0CCC
        SCF                     ; 0CCD
        RET Z                   ; 0CCE
        INC HL                  ; 0CCF
        PUSH HL                 ; 0CD0
        ADD A,06H               ; 0CD1
        LD D,00H                ; 0CD3
        LD E,A                  ; 0CD5
        ADD HL,DE               ; 0CD6
        LD (xw401B),HL          ; 0CD7
        POP HL                  ; 0CDA
        RET                     ; 0CDB

p0CDC:  LD A,(xb3DEA)           ; 0CDC
        CP '$'                  ; 0CDF
        LD C,00H                ; 0CE1
        RET Z                   ; 0CE3
        CP '.'                  ; 0CE4
        LD C,01H                ; 0CE6
        RET Z                   ; 0CE8
        CP '?'                  ; 0CE9
        LD C,02H                ; 0CEB
        RET Z                   ; 0CED
        CP '_'                  ; 0CEE
        LD C,03H                ; 0CF0
        RET Z                   ; 0CF2
        CP ' '                  ; 0CF3
        LD C,04H                ; 0CF5
        RET Z                   ; 0CF7
        SUB 3BH                 ; 0CF8
        LD C,A                  ; 0CFA
        RET                     ; 0CFB

p0CFC:  PUSH AF                 ; 0CFC
        CALL p0C24              ; 0CFD
p0D00:  LD (xw3D3F),HL          ; 0D00
        POP BC                  ; 0D03
        PUSH AF                 ; 0D04
        PUSH BC                 ; 0D05
        POP AF                  ; 0D06
        CALL p0D93              ; 0D07
        POP AF                  ; 0D0A
        RET Z                   ; 0D0B
        PUSH HL                 ; 0D0C
        LD HL,(xw3F6E)          ; 0D0D
        EX DE,HL                ; 0D10
        LD A,D                  ; 0D11
        OR E                    ; 0D12
        JP Z,p0DCE              ; 0D13
        LD A,(xb3F6D)           ; 0D16
        EX DE,HL                ; 0D19
        LD B,00H                ; 0D1A
        LD C,A                  ; 0D1C
        ADD HL,BC               ; 0D1D
p0D1E:  POP DE                  ; 0D1E
        LD (HL),E               ; 0D1F
        INC HL                  ; 0D20
        LD (HL),D               ; 0D21
        EX DE,HL                ; 0D22
        LD C,04H                ; 0D23
        XOR A                   ; 0D25
p0D26:  LD (HL),A               ; 0D26
        INC HL                  ; 0D27
        DEC C                   ; 0D28
        JP NZ,p0D26             ; 0D29
        LD DE,xb3DE9            ; 0D2C address
        LD A,(DE)               ; 0D2F
        CP 10H                  ; 0D30
        JP C,p0D37              ; 0D32
        LD A,10H                ; 0D35
p0D37:  LD (HL),A               ; 0D37
        LD B,A                  ; 0D38
        INC HL                  ; 0D39
        INC DE                  ; 0D3A
        XOR A                   ; 0D3B
        LD (HL),A               ; 0D3C
        LD (xw3D3F),HL          ; 0D3D
        INC HL                  ; 0D40
        LD (HL),A               ; 0D41
        INC HL                  ; 0D42
        LD (HL),A               ; 0D43
        INC HL                  ; 0D44
        LD (HL),A               ; 0D45
        INC HL                  ; 0D46
        INC HL                  ; 0D47
        INC HL                  ; 0D48
p0D49:  LD A,(DE)               ; 0D49
        LD (HL),A               ; 0D4A
        INC HL                  ; 0D4B
        INC DE                  ; 0D4C
        DEC B                   ; 0D4D
        JP NZ,p0D49             ; 0D4E
        LD (xw3D41),HL          ; 0D51
        INC HL                  ; 0D54
        INC HL                  ; 0D55
        INC HL                  ; 0D56
        INC HL                  ; 0D57
        LD (HL),B               ; 0D58
        LD DE,0100H             ; 0D59
        ADD HL,DE               ; 0D5C
        EX DE,HL                ; 0D5D
        LD HL,(xw401D)          ; 0D5E
        CALL p0D8D              ; 0D61
        CALL C,p3B00            ; 0D64
        LD HL,(xw3D3F)          ; 0D67
        LD A,H                  ; 0D6A
        OR A                    ; 0D6B
        LD A,00H                ; 0D6C
        RET                     ; 0D6E

p0D6F:  LD HL,xs0D78            ; 0D6F message
p0D72:  CALL p46CC              ; 0D72
        JP p0100                ; 0D75
;=====================================
xs0D78: DB "?Symbol table full" ; 0D78
        DB CR                   ; 0D8A
xs0D8B: DB LF,0                 ; 0D8B
;=====================================
p0D8D:  LD A,H                  ; 0D8D
        SUB D                   ; 0D8E
        RET NZ                  ; 0D8F
        LD A,L                  ; 0D90
        SUB E                   ; 0D91
        RET                     ; 0D92

p0D93:  PUSH AF                 ; 0D93
        LD A,(xb3CEC)           ; 0D94
        OR A                    ; 0D97
        JP Z,p18C7              ; 0D98
        LD A,(xb408C)           ; 0D9B
        OR A                    ; 0D9E
        JP Z,p18C7              ; 0D9F
        LD A,(xb3D2D)           ; 0DA2
        OR A                    ; 0DA5
        JP NZ,p18C7             ; 0DA6
        LD HL,(xw3D3F)          ; 0DA9
        LD A,(HL)               ; 0DAC
        AND 40H                 ; 0DAD
        JP NZ,p18C7             ; 0DAF
        POP AF                  ; 0DB2
        JP C,p0DB9              ; 0DB3
        LD A,82H                ; 0DB6
        DB 0DAH                 ; 0DB8 (JP C,p813E)
p0DB9:  LD A,81H                ; 0DB9
        CALL p4C76              ; 0DBB
        PUSH HL                 ; 0DBE
        LD HL,xb3DE9            ; 0DBF address
        LD B,(HL)               ; 0DC2
p0DC3:  INC HL                  ; 0DC3
        LD A,(HL)               ; 0DC4
        CALL p4C76              ; 0DC5
        DEC B                   ; 0DC8
        JP NZ,p0DC3             ; 0DC9
        POP HL                  ; 0DCC
        RET                     ; 0DCD

p0DCE:  LD HL,(xw3F70)          ; 0DCE
        JP p0D1E                ; 0DD1

p0DD4:  PUSH AF                 ; 0DD4
        CALL p0C0E              ; 0DD5
        JP p0D00                ; 0DD8

p0DDB:  LD B,A                  ; 0DDB
        LD A,(HL)               ; 0DDC
        AND 38H                 ; 0DDD
        JP NZ,p0E02             ; 0DDF
        INC HL                  ; 0DE2
        LD A,(HL)               ; 0DE3
        AND 20H                 ; 0DE4
        JP NZ,p0E11             ; 0DE6
p0DE9:  DEC HL                  ; 0DE9
        LD A,(HL)               ; 0DEA
        OR 80H                  ; 0DEB
        LD (HL),A               ; 0DED
        INC HL                  ; 0DEE
        LD A,(HL)               ; 0DEF
        OR B                    ; 0DF0
        LD (HL),A               ; 0DF1
        INC HL                  ; 0DF2
        LD (HL),E               ; 0DF3
        INC HL                  ; 0DF4
        LD (HL),D               ; 0DF5
        INC HL                  ; 0DF6
        PUSH DE                 ; 0DF7
        EX DE,HL                ; 0DF8
        LD HL,(xw3DDE)          ; 0DF9
        EX DE,HL                ; 0DFC
        LD (HL),E               ; 0DFD
        INC HL                  ; 0DFE
        LD (HL),D               ; 0DFF
        POP DE                  ; 0E00
        RET                     ; 0E01

p0E02:  LD A,(HL)               ; 0E02
        AND 40H                 ; 0E03
        LD (HL),A               ; 0E05
        LD A,(xb3CEA)           ; 0E06
        OR A                    ; 0E09
        CALL Z,p04CD            ; 0E0A
        INC HL                  ; 0E0D
        JP p0DE9                ; 0E0E

p0E11:  LD A,(HL)               ; 0E11
        AND 94H                 ; 0E12
        CALL NZ,p0E61           ; 0E14
        LD A,(HL)               ; 0E17
        XOR B                   ; 0E18
        AND 03H                 ; 0E19
        CALL NZ,p0E61           ; 0E1B
        INC HL                  ; 0E1E
        PUSH DE                 ; 0E1F
        LD E,(HL)               ; 0E20
        INC HL                  ; 0E21
        LD D,(HL)               ; 0E22
        INC HL                  ; 0E23
        EX (SP),HL              ; 0E24
        CALL p0D8D              ; 0E25
        CALL NZ,p0E52           ; 0E28
        POP DE                  ; 0E2B
        PUSH HL                 ; 0E2C
        LD HL,(xw3DDE)          ; 0E2D
        EX DE,HL                ; 0E30
        LD A,B                  ; 0E31
        AND 03H                 ; 0E32
        CP 03H                  ; 0E34
        JP NZ,p0E44             ; 0E36
        LD A,E                  ; 0E39
        CP (HL)                 ; 0E3A
        CALL NZ,p0E61           ; 0E3B
        INC HL                  ; 0E3E
        LD A,D                  ; 0E3F
        CP (HL)                 ; 0E40
        CALL NZ,p0E61           ; 0E41
p0E44:  POP DE                  ; 0E44
        LD A,(xb3E11)           ; 0E45
        CP 20H                  ; 0E48
        LD HL,(xw3D3F)          ; 0E4A
        INC HL                  ; 0E4D
        JP Z,p0DE9              ; 0E4E
        RET                     ; 0E51

p0E52:  LD A,(xb3D30)           ; 0E52
        OR A                    ; 0E55
        JP NZ,p0E61             ; 0E56
        LD HL,(xw3D3F)          ; 0E59
        LD A,(HL)               ; 0E5C
        OR A                    ; 0E5D
        JP P,p04C7              ; 0E5E
p0E61:  PUSH HL                 ; 0E61
        PUSH AF                 ; 0E62
        LD HL,(xw3D3F)          ; 0E63
        INC HL                  ; 0E66
        LD A,(HL)               ; 0E67
        OR 10H                  ; 0E68
        LD (HL),A               ; 0E6A
        LD A,B                  ; 0E6B
        OR 10H                  ; 0E6C
        LD B,A                  ; 0E6E
        POP AF                  ; 0E6F
        POP HL                  ; 0E70
        JP p04B5                ; 0E71

p0E74:  LD A,0EDH               ; 0E74
        CALL p164C              ; 0E76
p0E79:  LD A,C                  ; 0E79
        CALL p164C              ; 0E7A
        JP p0B40                ; 0E7D

p0E80:  PUSH BC                 ; 0E80
        CALL p0F5A              ; 0E81
        CALL p0F36              ; 0E84
        ADD A,A                 ; 0E87
        ADD A,A                 ; 0E88
        ADD A,A                 ; 0E89
        POP BC                  ; 0E8A
        ADD A,C                 ; 0E8B
        JP p164C                ; 0E8C

p0E8F:  PUSH BC                 ; 0E8F
        CALL p0F5A              ; 0E90
        CALL p0F40              ; 0E93
        ADD A,A                 ; 0E96
        ADD A,A                 ; 0E97
        ADD A,A                 ; 0E98
        POP BC                  ; 0E99
        ADD A,C                 ; 0E9A
        JP p164C                ; 0E9B

p0E9E:  PUSH BC                 ; 0E9E
        CALL p0F5A              ; 0E9F
        CALL p0F52              ; 0EA2
        POP BC                  ; 0EA5
        ADD A,C                 ; 0EA6
        JP p164C                ; 0EA7

p0EAA:  PUSH BC                 ; 0EAA
        CALL p0F5A              ; 0EAB
        CALL p0F52              ; 0EAE
        POP BC                  ; 0EB1
        ADD A,A                 ; 0EB2
        ADD A,A                 ; 0EB3
        ADD A,A                 ; 0EB4
        ADD A,C                 ; 0EB5
        JP p164C                ; 0EB6

p0EB9:  LD A,C                  ; 0EB9
        PUSH AF                 ; 0EBA
        CALL p0F5A              ; 0EBB
        LD C,A                  ; 0EBE
        POP AF                  ; 0EBF
        CALL p164C              ; 0EC0
        LD A,C                  ; 0EC3
        JP p16D9                ; 0EC4

p0EC7:  LD A,C                  ; 0EC7
        PUSH AF                 ; 0EC8
        CALL p2D6D              ; 0EC9
        POP AF                  ; 0ECC
        CALL p164C              ; 0ECD
        JP p17D5                ; 0ED0

p0ED3:  PUSH BC                 ; 0ED3
        CALL p0F5A              ; 0ED4
        CALL p0F52              ; 0ED7
        POP BC                  ; 0EDA
        ADD A,A                 ; 0EDB
        ADD A,A                 ; 0EDC
        ADD A,A                 ; 0EDD
        ADD A,C                 ; 0EDE
        LD C,A                  ; 0EDF
        PUSH BC                 ; 0EE0
        CALL p0F2A              ; 0EE1
        CALL p0F5A              ; 0EE4
        CALL p0F52              ; 0EE7
        POP BC                  ; 0EEA
        ADD A,C                 ; 0EEB
        CP 76H                  ; 0EEC
        CALL Z,p049D            ; 0EEE
        JP p164C                ; 0EF1

p0EF4:  PUSH BC                 ; 0EF4
        CALL p0F5A              ; 0EF5
        CALL p0F52              ; 0EF8
        POP BC                  ; 0EFB
        ADD A,A                 ; 0EFC
        ADD A,A                 ; 0EFD
        ADD A,A                 ; 0EFE
        ADD A,C                 ; 0EFF
        PUSH AF                 ; 0F00
        CALL p0F2A              ; 0F01
        CALL p0F5A              ; 0F04
        LD C,A                  ; 0F07
        POP AF                  ; 0F08
        CALL p164C              ; 0F09
        LD A,C                  ; 0F0C
        JP p16D9                ; 0F0D

p0F10:  PUSH BC                 ; 0F10
        CALL p0F5A              ; 0F11
        POP BC                  ; 0F14
        CALL p0F40              ; 0F15
        ADD A,A                 ; 0F18
        ADD A,A                 ; 0F19
        ADD A,A                 ; 0F1A
        ADD A,C                 ; 0F1B
        PUSH AF                 ; 0F1C
        CALL p0F2A              ; 0F1D
        CALL p2D6D              ; 0F20
        POP AF                  ; 0F23
        CALL p164C              ; 0F24
        JP p17D5                ; 0F27

p0F2A:  CALL p0B36              ; 0F2A
        CALL p0AEA              ; 0F2D
        CP 2CH                  ; 0F30
        CALL NZ,p04C1           ; 0F32
        RET                     ; 0F35

p0F36:  OR A                    ; 0F36
        RET Z                   ; 0F37
        CP 02H                  ; 0F38
        RET Z                   ; 0F3A
        AND 02H                 ; 0F3B
        JP p049D                ; 0F3D

p0F40:  CP 07H                  ; 0F40
        PUSH AF                 ; 0F42
        JP NC,p0F4B             ; 0F43
        AND 01H                 ; 0F46
        JP Z,p0F4E              ; 0F48
p0F4B:  CALL p049D              ; 0F4B
p0F4E:  POP AF                  ; 0F4E
        AND 06H                 ; 0F4F
        RET                     ; 0F51

p0F52:  CP 08H                  ; 0F52
        RET C                   ; 0F54
        AND 07H                 ; 0F55
        JP p049D                ; 0F57

p0F5A:  CALL p2D6D              ; 0F5A
        LD A,D                  ; 0F5D
        OR A                    ; 0F5E
        JP Z,p0F66              ; 0F5F
        INC A                   ; 0F62
        CALL NZ,p049D           ; 0F63
p0F66:  LD A,E                  ; 0F66
        RET                     ; 0F67

p0F68:  LD B,00H                ; 0F68
        DB 11H                  ; 0F6A (LD DE,CB06H)
p0F6B:  LD B,0CBH               ; 0F6B
        DB 11H                  ; 0F6D (LD DE,ED06H)
p0F6E:  LD B,0EDH               ; 0F6E
        LD E,C                  ; 0F70
        LD D,00H                ; 0F71
        LD HL,xt0A84            ; 0F73
        ADD HL,DE               ; 0F76
        LD E,(HL)               ; 0F77
        INC HL                  ; 0F78
        LD C,(HL)               ; 0F79
        LD HL,xt0AC6            ; 0F7A Table start
        ADD HL,DE               ; 0F7D
        LD E,(HL)               ; 0F7E
        INC HL                  ; 0F7F
        LD D,(HL)               ; 0F80
        EX DE,HL                ; 0F81
        JP (HL)                 ; 0F82

p0F83:  PUSH BC                 ; 0F83
        CALL p0F5A              ; 0F84
        CP 03H                  ; 0F87
        CALL NC,p049D           ; 0F89
        CALL p1642              ; 0F8C
        POP BC                  ; 0F8F
        LD A,B                  ; 0F90
        CALL p164C              ; 0F91
        LD A,E                  ; 0F94
        CP 01H                  ; 0F95
        CCF                     ; 0F97
        ADC A,00H               ; 0F98
        AND 03H                 ; 0F9A
p0F9C:  ADD A,A                 ; 0F9C
        ADD A,A                 ; 0F9D
        ADD A,A                 ; 0F9E
        ADD A,C                 ; 0F9F
        JP p164C                ; 0FA0

p0FA3:  PUSH BC                 ; 0FA3
        CALL p0F5A              ; 0FA4
        AND 38H                 ; 0FA7
        CP E                    ; 0FA9
        CALL NZ,p049D           ; 0FAA
        CALL p1642              ; 0FAD
        POP BC                  ; 0FB0
        ADD A,C                 ; 0FB1
        JP p164C                ; 0FB2

p0FB5:  PUSH BC                 ; 0FB5
        CALL p114E              ; 0FB6
        CALL C,p049D            ; 0FB9
        AND 08H                 ; 0FBC
        CALL NZ,p0FF1           ; 0FBE
        POP BC                  ; 0FC1
        CALL p1163              ; 0FC2
        LD A,(xb3CE8)           ; 0FC5
        AND 06H                 ; 0FC8
        JP p0F9C                ; 0FCA

p0FCD:  CALL p2083              ; 0FCD
        LD A,(xb3EC2)           ; 0FD0
        OR A                    ; 0FD3
        JP NZ,p0FEC             ; 0FD4
        CALL p1148              ; 0FD7
        LD A,(xb3CE7)           ; 0FDA
        CP 30H                  ; 0FDD
        CALL NZ,p1001           ; 0FDF
        LD A,(xb3CE8)           ; 0FE2
        AND 07H                 ; 0FE5
        LD C,0C0H               ; 0FE7
        JP p0F9C                ; 0FE9

p0FEC:  LD A,0C9H               ; 0FEC
        JP p164C                ; 0FEE

p0FF1:  LD A,(xb3CE8)            ; 0FF1
        AND 20H                 ; 0FF4
        ADD A,0DDH              ; 0FF6
        CALL p164C              ; 0FF8
        LD A,04H                ; 0FFB
        LD (xb3CE8),A           ; 0FFD
        RET                     ; 1000

p1001:  CP 10H                  ; 1001
        JP NZ,p049D             ; 1003
        LD A,(xb3CE8)           ; 1006
        INC A                   ; 1009
        CP 02H                  ; 100A
        JP Z,p1015              ; 100C
        DEC A                   ; 100F
        CP 06H                  ; 1010
        JP NZ,p049D             ; 1012
p1015:  INC A                   ; 1015
        LD (xb3CE8),A           ; 1016
        RET                     ; 1019

p101A:  PUSH BC                 ; 101A
        XOR A                   ; 101B
        LD (xb3CE9),A           ; 101C
        CALL p0BC8              ; 101F
        CALL p0B36              ; 1022
        CP 28H                  ; 1025
        JP NZ,p102D             ; 1027
        LD (xb3CE9),A           ; 102A
p102D:  CALL p2D6D              ; 102D
        LD A,C                  ; 1030
        SUB 2CH                 ; 1031
        POP BC                  ; 1033
        OR A                    ; 1034
        RET NZ                  ; 1035
        CALL p1148              ; 1036
        LD A,(xb3CE7)           ; 1039
        CP 30H                  ; 103C
        CALL NZ,p1001           ; 103E
        SCF                     ; 1041
        RET                     ; 1042

p1043:  CALL p101A              ; 1043
        JP NC,p105D             ; 1046
        LD C,0C4H               ; 1049
p104B:  LD A,(xb3CE8)           ; 104B
        ADD A,A                 ; 104E
        ADD A,A                 ; 104F
        ADD A,A                 ; 1050
        AND 38H                 ; 1051
        ADD A,C                 ; 1053
        LD C,A                  ; 1054
        PUSH BC                 ; 1055
        CALL p2D6D              ; 1056
        CALL p1642              ; 1059
        POP BC                  ; 105C
p105D:  LD A,C                  ; 105D
        CALL p164C              ; 105E
        JP p17D5                ; 1061

p1064:  CALL p101A              ; 1064
        JP C,p108B              ; 1067
        LD A,(xb3CE7)           ; 106A
        CP 20H                  ; 106D
        CCF                     ; 106F
        JP NC,p105D             ; 1070
        CP 28H                  ; 1073
        CALL Z,p0FF1            ; 1075
        CALL p115B              ; 1078
        LD A,(xb3CE8)           ; 107B
        CP 04H                  ; 107E
        CALL NZ,p049D           ; 1080
        CALL p1148              ; 1083
        LD A,0E9H               ; 1086
        JP p164C                ; 1088

p108B:  LD C,0C2H               ; 108B
        JP p104B                ; 108D

p1090:  CALL p101A              ; 1090
        JP NC,p10AB             ; 1093
        LD A,(xb3CE8)           ; 1096
        CP 04H                  ; 1099
        CALL NC,p049D           ; 109B
        AND 03H                 ; 109E
        ADD A,A                 ; 10A0
        ADD A,A                 ; 10A1
        ADD A,A                 ; 10A2
        ADD A,20H               ; 10A3
        LD C,A                  ; 10A5
        PUSH BC                 ; 10A6
        CALL p2D6D              ; 10A7
        POP BC                  ; 10AA
p10AB:  CALL p10B7              ; 10AB
        LD A,C                  ; 10AE
        LD C,B                  ; 10AF
        CALL p164C              ; 10B0
        LD A,C                  ; 10B3
        JP p164C                ; 10B4

p10B7:  LD A,(xb3EC1)           ; 10B7
        LD B,A                  ; 10BA
        AND 80H                 ; 10BB
        JP NZ,p04AF             ; 10BD
        CALL p1642              ; 10C0
        LD A,B                  ; 10C3
        AND 03H                 ; 10C4
        LD B,A                  ; 10C6
        CALL p1B6A              ; 10C7
        CP B                    ; 10CA
        JP NZ,p04D3             ; 10CB
        CP 03H                  ; 10CE
        JP NZ,p10E2             ; 10D0
        PUSH DE                 ; 10D3
        LD HL,(xw3DDA)          ; 10D4
        EX DE,HL                ; 10D7
        LD HL,(xw3DDE)          ; 10D8
        CALL p0D8D              ; 10DB
        POP DE                  ; 10DE
        JP NZ,p04D3             ; 10DF
p10E2:  CALL p1B6A              ; 10E2
        INC HL                  ; 10E5
        INC HL                  ; 10E6
        EX DE,HL                ; 10E7
        CALL p3954              ; 10E8
        LD A,D                  ; 10EB
        OR A                    ; 10EC
        LD B,E                  ; 10ED
        JP Z,p10FB              ; 10EE
        INC A                   ; 10F1
        JP NZ,p049D             ; 10F2
        LD A,B                  ; 10F5
        OR A                    ; 10F6
        JP P,p049D              ; 10F7
        RET                     ; 10FA

p10FB:  LD A,B                  ; 10FB
        OR A                    ; 10FC
        JP M,p049D              ; 10FD
        RET                     ; 1100

p1101:  PUSH BC                 ; 1101
        CALL p2D6D              ; 1102
        POP BC                  ; 1105
        JP p10AB                ; 1106

p1109:  CALL p0F2A              ; 1109
p110C:  PUSH BC                 ; 110C
        XOR A                   ; 110D
        LD (xb3CE9),A           ; 110E
        CALL p0BC8              ; 1111
        CALL p0B36              ; 1114
        CP 28H                  ; 1117
        JP NZ,p111F             ; 1119
        LD (xb3CE9),A           ; 111C
p111F:  CALL p2D6D              ; 111F
        POP BC                  ; 1122
        LD A,(xb3CE7)           ; 1123
        OR A                    ; 1126
        RET Z                   ; 1127
        CP 30H                  ; 1128
        CALL Z,p049D            ; 112A
        LD L,A                  ; 112D
        LD A,(xb3CE9)           ; 112E
        OR A                    ; 1131
        LD A,L                  ; 1132
        JP Z,p1148              ; 1133
        CP 28H                  ; 1136
        JP NZ,p1148             ; 1138
p113B:  LD A,D                  ; 113B
        OR A                    ; 113C
        JP Z,p114D              ; 113D
        INC A                   ; 1140
        LD D,A                  ; 1141
        JP Z,p114D              ; 1142
        CALL p049D              ; 1145
p1148:  LD A,D                  ; 1148
        OR E                    ; 1149
        CALL NZ,p049D           ; 114A
p114D:  RET                     ; 114D

p114E:  CALL p110C              ; 114E
        LD A,(xb3CE7)           ; 1151
        OR A                    ; 1154
        JP Z,p049D              ; 1155
        CP 20H                  ; 1158
        RET                     ; 115A

p115B:  LD A,(xb3CE9)           ; 115B
        OR A                    ; 115E
        CALL Z,p049D            ; 115F
        RET                     ; 1162

p1163:  LD A,(xb3CE9)           ; 1163
        OR A                    ; 1166
        CALL NZ,p049D           ; 1167
        RET                     ; 116A

p116B:  CALL p110C              ; 116B
p116E:  LD A,(xb3CE7)           ; 116E
        CP 10H                  ; 1171
        RET NZ                  ; 1173
        LD A,(xb3CE8)           ; 1174
        CP 08H                  ; 1177
        RET C                   ; 1179
        JP p049D                ; 117A

p117D:  CALL p116B              ; 117D
        CALL p0F2A              ; 1180
        CALL p115B              ; 1183
        LD A,(xb3CE7)           ; 1186
        CP 10H                  ; 1189
        JP Z,p11AF              ; 118B
        OR A                    ; 118E
        CALL NZ,p049D           ; 118F
        CALL p113B              ; 1192
        LD A,0D3H               ; 1195
        CALL p164C              ; 1197
        LD A,E                  ; 119A
        CALL p16D9              ; 119B
        CALL p114E              ; 119E
        CALL NC,p049D           ; 11A1
        LD A,(xb3CE8)           ; 11A4
        CP 07H                  ; 11A7
        CALL NZ,p049D           ; 11A9
        JP p1163                ; 11AC

p11AF:  LD A,(xb3CE8)           ; 11AF
        DEC A                   ; 11B2
        CALL NZ,p049D           ; 11B3
        CALL p114E              ; 11B6
        CALL NC,p049D           ; 11B9
        CALL p1163              ; 11BC
        LD A,0EDH               ; 11BF
        CALL p164C              ; 11C1
        CALL p1163              ; 11C4
        CALL p116E              ; 11C7
        LD C,41H                ; 11CA
        JP p0F9C                ; 11CC

p11CF:  CALL p114E              ; 11CF
        CALL NC,p049D           ; 11D2
        CALL p1163              ; 11D5
        CALL p116E              ; 11D8
        PUSH AF                 ; 11DB
        CALL p1109              ; 11DC
        CALL p115B              ; 11DF
        LD A,(xb3CE7)           ; 11E2
        CP 10H                  ; 11E5
        JP Z,p1200              ; 11E7
        OR A                    ; 11EA
        CALL NZ,p049D           ; 11EB
        LD A,0DBH               ; 11EE
        CALL p164C              ; 11F0
        POP AF                  ; 11F3
        CP 07H                  ; 11F4
        CALL NZ,p049D           ; 11F6
        CALL p113B              ; 11F9
        LD A,E                  ; 11FC
        JP p16D9                ; 11FD

p1200:  LD A,(xb3CE8)           ; 1200
        DEC A                   ; 1203
        CALL NZ,p049D           ; 1204
        LD A,0EDH               ; 1207
        CALL p164C              ; 1209
        POP AF                  ; 120C
        LD C,40H                ; 120D
        JP p0F9C                ; 120F

p1212:  CALL p114E              ; 1212
        CALL C,p049D            ; 1215
        CALL p0F2A              ; 1218
        CALL p2065              ; 121B
        JP Z,p1252              ; 121E
        LD A,(xb3CE8)           ; 1221
        CP 02H                  ; 1224
        JP Z,p1266              ; 1226
        CP 06H                  ; 1229
        CALL NZ,p049D           ; 122B
        CALL p115B              ; 122E
        CALL p114E              ; 1231
        CALL C,p049D            ; 1234
        CALL p1163              ; 1237
        CALL p1148              ; 123A
        LD A,(xb3CE7)           ; 123D
        CP 28H                  ; 1240
        CALL Z,p0FF1            ; 1242
        LD A,(xb3CE8)           ; 1245
        CP 04H                  ; 1248
        CALL NZ,p049D           ; 124A
        LD A,0E3H               ; 124D
        JP p164C                ; 124F

p1252:  CALL p1163              ; 1252
        CALL p114E              ; 1255
        CALL C,p049D            ; 1258
        CALL p2065              ; 125B
        CALL NZ,p049D           ; 125E
        LD A,08H                ; 1261
        JP p164C                ; 1263

p1266:  CALL p1163              ; 1266
        CALL p114E              ; 1269
        CALL C,p049D            ; 126C
        LD A,(xb3CE7)           ; 126F
        CP 20H                  ; 1272
        CALL NZ,p049D           ; 1274
        LD A,(xb3CE8)           ; 1277
        CP 04H                  ; 127A
        CALL NZ,p049D           ; 127C
        LD A,0EBH               ; 127F
        JP p164C                ; 1281

p1284:  PUSH BC                 ; 1284
        CALL p0F5A              ; 1285
        CP 08H                  ; 1288
        CALL NC,p049D           ; 128A
        AND 07H                 ; 128D
        ADD A,A                 ; 128F
        ADD A,A                 ; 1290
        ADD A,A                 ; 1291
        POP BC                  ; 1292
        ADD A,C                 ; 1293
        LD C,A                  ; 1294
        CALL p0F2A              ; 1295
p1298:  CALL p116B              ; 1298
        DB 0F6H                 ; 129B (OR 37H)      
p129C:  SCF                     ; 129C
        PUSH AF                 ; 129D
        LD A,(xb3CE7)           ; 129E
        CP 28H                  ; 12A1
        PUSH AF                 ; 12A3
        CALL Z,p0FF1            ; 12A4
        POP HL                  ; 12A7
        POP AF                  ; 12A8
        PUSH HL                 ; 12A9
        PUSH AF                 ; 12AA
        LD A,0CBH               ; 12AB
        CALL NC,p164C           ; 12AD
        POP AF                  ; 12B0
        JP C,p12BA              ; 12B1
        POP AF                  ; 12B4
        LD A,E                  ; 12B5
        CALL Z,p16D9            ; 12B6
        PUSH AF                 ; 12B9
p12BA:  PUSH AF                 ; 12BA
        LD A,(xb3CE7)           ; 12BB
        OR A                    ; 12BE
        CALL Z,p049D            ; 12BF
        AND 20H                 ; 12C2
        LD A,(xb3CE8)           ; 12C4
        JP NZ,p12D4             ; 12C7
        ADD A,C                 ; 12CA
        CALL p164C              ; 12CB
        CALL p1163              ; 12CE
        POP AF                  ; 12D1
        POP AF                  ; 12D2
        RET                     ; 12D3

p12D4:  CP 04H                  ; 12D4
        CALL NZ,p049D           ; 12D6
        LD A,06H                ; 12D9
        ADD A,C                 ; 12DB
        CALL p164C              ; 12DC
        CALL p115B              ; 12DF
        POP AF                  ; 12E2
        JP NC,p18C7             ; 12E3
        JP p132F                ; 12E6

p12E9:  CALL p116B              ; 12E9
        LD A,(xb3CE7)           ; 12EC
        OR A                    ; 12EF
        CALL Z,p049D            ; 12F0
        CP 10H                  ; 12F3
        JP Z,p1322              ; 12F5
        CP 28H                  ; 12F8
        PUSH AF                 ; 12FA
        CALL Z,p0FF1            ; 12FB
        LD A,(xb3CE8)           ; 12FE
        CP 04H                  ; 1301
        JP NZ,p130D             ; 1303
        LD A,(xb3CE9)           ; 1306
        OR A                    ; 1309
        JP NZ,p132A             ; 130A
p130D:  CALL p1163              ; 130D
        POP AF                  ; 1310
        LD A,C                  ; 1311
        DEC C                   ; 1312
        CP 05H                  ; 1313
        JP NZ,p131A             ; 1315
        LD C,0BH                ; 1318
p131A:  LD A,(xb3CE8)           ; 131A
        AND 06H                 ; 131D
        JP p0F9C                ; 131F

p1322:  LD A,(xb3CE8)           ; 1322
p1325:  AND 07H                 ; 1325
        JP p0F9C                ; 1327

p132A:  LD A,06H                ; 132A
        CALL p1325              ; 132C
p132F:  POP AF                  ; 132F
        LD A,E                  ; 1330
        CALL Z,p16D9            ; 1331
        RET                     ; 1334

p1335:  CALL p110C              ; 1335
        LD A,(xb3CE7)           ; 1338
        OR A                    ; 133B
        JP Z,p1369              ; 133C
        CP 10H                  ; 133F
        JP Z,p1360              ; 1341
        CP 28H                  ; 1344
        PUSH AF                 ; 1346
        CALL Z,p0FF1            ; 1347
        CALL p115B              ; 134A
        LD A,(xb3CE8)           ; 134D
        AND 07H                 ; 1350
        CP 04H                  ; 1352
        CALL NZ,p049D           ; 1354
        LD A,06H                ; 1357
        ADD A,C                 ; 1359
        CALL p164C              ; 135A
        JP p132F                ; 135D

p1360:  LD A,(xb3CE8)           ; 1360
        AND 07H                 ; 1363
        ADD A,C                 ; 1365
        JP p164C                ; 1366

p1369:  LD A,46H                ; 1369
        ADD A,C                 ; 136B
        CALL p164C              ; 136C
        CALL p113B              ; 136F
        LD A,E                  ; 1372
        JP p16D9                ; 1373

p1376:  CALL p114E              ; 1376
        CALL p0F2A              ; 1379
        CALL p1163              ; 137C
        LD A,(xb3CE7)           ; 137F
        CP 10H                  ; 1382
        JP Z,p13B4              ; 1384
        CP 20H                  ; 1387
        CALL NZ,p049D           ; 1389
        LD A,(xb3CE8)           ; 138C
        CP 04H                  ; 138F
        CALL NZ,p049D           ; 1391
        LD A,0EDH               ; 1394
        CALL p164C              ; 1396
        LD A,C                  ; 1399
        XOR 10H                 ; 139A
        RRA                     ; 139C
        AND 08H                 ; 139D
        ADD A,42H               ; 139F
        LD C,A                  ; 13A1
p13A2:  CALL p114E              ; 13A2
        CALL NZ,p049D           ; 13A5
        CALL p2065              ; 13A8
        CALL Z,p049D            ; 13AB
        CALL p1163              ; 13AE
        JP p131A                ; 13B1

p13B4:  LD A,(xb3CE8)           ; 13B4
        CP 07H                  ; 13B7
        CALL NZ,p049D           ; 13B9
        JP p1335                ; 13BC

p13BF:  CALL p114E              ; 13BF
        CALL p0F2A              ; 13C2
        CALL p1163              ; 13C5
        LD A,(xb3CE7)           ; 13C8
        CP 10H                  ; 13CB
        JP Z,p13B4              ; 13CD
        CP 28H                  ; 13D0
        JP Z,p13E2              ; 13D2
        LD A,(xb3CE8)           ; 13D5
        CP 04H                  ; 13D8
        CALL NZ,p049D           ; 13DA
        LD C,09H                ; 13DD
        JP p13A2                ; 13DF

p13E2:  LD A,(xb3CE8)           ; 13E2
        PUSH AF                 ; 13E5
        CALL p0FF1              ; 13E6
        CALL p114E              ; 13E9
        CALL C,p049D            ; 13EC
        PUSH AF                 ; 13EF
        CALL p2065              ; 13F0
        CALL Z,p049D            ; 13F3
        CALL p1163              ; 13F6
        LD A,(xb3CE8)           ; 13F9
        CP 04H                  ; 13FC
        CALL Z,p049D            ; 13FE
        LD B,A                  ; 1401
        POP AF                  ; 1402
        LD A,B                  ; 1403
        JP Z,p140F              ; 1404
        POP AF                  ; 1407
        CP B                    ; 1408
        CALL NZ,p049D           ; 1409
        LD A,04H                ; 140C
        PUSH AF                 ; 140E
p140F:  POP BC                  ; 140F
        AND 06H                 ; 1410
        LD C,09H                ; 1412
        JP p0F9C                ; 1414

p1417:  LD A,(xb3CE7)           ; 1417
        CP 10H                  ; 141A
        CALL NZ,p049D           ; 141C
        RET                     ; 141F

p1420:  CALL p110C              ; 1420
        LD A,(xb3CE7)           ; 1423
        OR A                    ; 1426
        JP Z,p145B              ; 1427
        CP 10H                  ; 142A
        JP Z,p1534              ; 142C
        LD A,(xb3CE9)           ; 142F
        OR A                    ; 1432
        JP Z,p14C1              ; 1433
        LD A,(xb3CE8)           ; 1436
        AND 06H                 ; 1439
        CP 04H                  ; 143B
        JP Z,p1599              ; 143D
        CALL NC,p049D           ; 1440
        PUSH AF                 ; 1443
        CALL p110C              ; 1444
        CALL p1163              ; 1447
        CALL p1417              ; 144A
        LD A,(xb3CE8)           ; 144D
        CP 07H                  ; 1450
        CALL NZ,p049D           ; 1452
        LD C,02H                ; 1455
        POP AF                  ; 1457
        JP p0F9C                ; 1458

p145B:  PUSH DE                 ; 145B
        CALL p1628              ; 145C
        CALL p115B              ; 145F
        LD A,(xb3EBD)           ; 1462
        PUSH AF                 ; 1465
        LD A,(xb3EC1)           ; 1466
        PUSH AF                 ; 1469
        CALL p1109              ; 146A
        CALL p1163              ; 146D
        LD A,(xb3CE7)           ; 1470
        OR A                    ; 1473
        CALL Z,p049D            ; 1474
        CP 20H                  ; 1477
        JP C,p14B1              ; 1479
        LD A,(xb3CE8)           ; 147C
        LD C,A                  ; 147F
        AND 06H                 ; 1480
        CP 04H                  ; 1482
        JP Z,p14A1              ; 1484
        LD A,0EDH               ; 1487
        CALL p164C              ; 1489
        LD A,C                  ; 148C
        LD C,43H                ; 148D
        CALL p0F9C              ; 148F
p1492:  CALL p1628              ; 1492
        POP AF                  ; 1495
        LD (xb3EC1),A           ; 1496
        POP AF                  ; 1499
        LD (xb3EBD),A           ; 149A
        POP DE                  ; 149D
        JP p17D5                ; 149E

p14A1:  LD A,(xb3CE7)           ; 14A1
        CP 28H                  ; 14A4
        CALL Z,p0FF1            ; 14A6
        LD A,22H                ; 14A9
        CALL p164C              ; 14AB
        JP p1492                ; 14AE

p14B1:  LD A,(xb3CE8)           ; 14B1
        CP 07H                  ; 14B4
        CALL NZ,p049D           ; 14B6
        LD A,32H                ; 14B9
        CALL p164C              ; 14BB
        JP p1492                ; 14BE

p14C1:  LD A,(xb3CE8)           ; 14C1
        PUSH AF                 ; 14C4
        CALL p1109              ; 14C5
        LD A,(xb3CE7)           ; 14C8
        CP 20H                  ; 14CB
        JP NC,p14F1             ; 14CD
        OR A                    ; 14D0
        CALL NZ,p049D           ; 14D1
        LD A,(xb3CE9)           ; 14D4
        OR A                    ; 14D7
        JP NZ,p150A             ; 14D8
        LD C,01H                ; 14DB
        POP AF                  ; 14DD
        PUSH AF                 ; 14DE
        AND 60H                 ; 14DF
        ADD A,9DH               ; 14E1
        CP 0C0H                 ; 14E3
        CALL NC,p164C           ; 14E5
        POP AF                  ; 14E8
        AND 06H                 ; 14E9
        CALL p0F9C              ; 14EB
        JP p17D5                ; 14EE

p14F1:  CALL NZ,p0FF1           ; 14F1
        POP AF                  ; 14F4
        CP 06H                  ; 14F5
        CALL NZ,p049D           ; 14F7
        CALL p1163              ; 14FA
        LD A,(xb3CE8)           ; 14FD
        CP 04H                  ; 1500
        CALL NZ,p049D           ; 1502
        LD A,0F9H               ; 1505
        JP p164C                ; 1507

p150A:  POP AF                  ; 150A
        LD (xb3CE8),A           ; 150B
        LD C,A                  ; 150E
        AND 06H                 ; 150F
        CP 04H                  ; 1511
        JP NZ,p1524             ; 1513
        LD A,C                  ; 1516
        CP 40H                  ; 1517
        CALL NC,p0FF1           ; 1519
        LD A,2AH                ; 151C
        CALL p164C              ; 151E
        JP p17D5                ; 1521

p1524:  LD A,0EDH               ; 1524
        CALL p164C              ; 1526
        LD A,C                  ; 1529
        AND 06H                 ; 152A
        LD C,4BH                ; 152C
        CALL p0F9C              ; 152E
        JP p17D5                ; 1531

p1534:  CALL p1163              ; 1534
        LD A,(xb3CE8)           ; 1537
        CP 08H                  ; 153A
        JP NC,p157D             ; 153C
        PUSH AF                 ; 153F
        CALL p1109              ; 1540
        LD A,(xb3CE7)           ; 1543
        OR A                    ; 1546
        JP NZ,p155E             ; 1547
        LD A,(xb3CE9)           ; 154A
        OR A                    ; 154D
        JP NZ,p15CA             ; 154E
        CALL p113B              ; 1551
        LD C,06H                ; 1554
        POP AF                  ; 1556
        CALL p0F9C              ; 1557
        LD A,E                  ; 155A
        JP p16D9                ; 155B

p155E:  LD A,(xb3CE7)           ; 155E
        CP 10H                  ; 1561
        CALL Z,p160A            ; 1563
        CP 20H                  ; 1566
        JP NZ,p1573             ; 1568
        LD A,(xb3CE8)           ; 156B
        CP 04H                  ; 156E
        JP C,p15D8              ; 1570
p1573:  POP AF                  ; 1573
        ADD A,A                 ; 1574
        ADD A,A                 ; 1575
        ADD A,A                 ; 1576
        ADD A,40H               ; 1577
        LD C,A                  ; 1579
        JP p129C                ; 157A

p157D:  PUSH AF                 ; 157D
        CALL p1109              ; 157E
        CALL p1417              ; 1581
        LD A,(xb3CE8)           ; 1584
        CP 07H                  ; 1587
        CALL NZ,p049D           ; 1589
        LD A,0EDH               ; 158C
        CALL p164C              ; 158E
        POP AF                  ; 1591
        AND 01H                 ; 1592
        LD C,47H                ; 1594
        JP p0F9C                ; 1596

p1599:  LD A,(xb3CE8)           ; 1599
        PUSH DE                 ; 159C
        PUSH AF                 ; 159D
        CALL p1628              ; 159E
        CALL p1109              ; 15A1
        CALL p1163              ; 15A4
        POP AF                  ; 15A7
        PUSH AF                 ; 15A8
        AND 60H                 ; 15A9
        ADD A,9DH               ; 15AB
        CP 0C0H                 ; 15AD
        CALL NC,p164C           ; 15AF
        LD C,70H                ; 15B2
        LD A,(xb3CE7)           ; 15B4
        OR A                    ; 15B7
        JP Z,p15E9              ; 15B8
        CALL p129C              ; 15BB
        CALL p1628              ; 15BE
        POP AF                  ; 15C1
        POP DE                  ; 15C2
        CP 40H                  ; 15C3
        LD A,E                  ; 15C5
        CALL NC,p16D9           ; 15C6
        RET                     ; 15C9

p15CA:  POP AF                  ; 15CA
        CP 07H                  ; 15CB
        CALL NZ,p049D           ; 15CD
        LD A,3AH                ; 15D0
        CALL p164C              ; 15D2
        JP p17D5                ; 15D5

p15D8:  CALL p115B              ; 15D8
        POP AF                  ; 15DB
        CP 07H                  ; 15DC
        CALL NZ,p049D           ; 15DE
        LD A,(xb3CE8)           ; 15E1
        LD C,0AH                ; 15E4
        JP p0F9C                ; 15E6

p15E9:  CALL p113B              ; 15E9
        CALL p1163              ; 15EC
        LD A,36H                ; 15EF
        CALL p164C              ; 15F1
        LD C,E                  ; 15F4
        LD B,D                  ; 15F5
        CALL p1628              ; 15F6
        POP AF                  ; 15F9
        POP DE                  ; 15FA
        CP 40H                  ; 15FB
        LD A,E                  ; 15FD
        CALL NC,p16D9           ; 15FE
        CALL p1628              ; 1601
        LD E,C                  ; 1604
        LD D,B                  ; 1605
        LD A,C                  ; 1606
        JP p16D9                ; 1607

p160A:  LD A,(xb3CE8)           ; 160A
        CP 08H                  ; 160D
        LD C,A                  ; 160F
        LD A,(xb3CE7)           ; 1610
        RET C                   ; 1613
        POP HL                  ; 1614
        POP AF                  ; 1615
        CP 07H                  ; 1616
        CALL NZ,p049D           ; 1618
        LD A,0EDH               ; 161B
        CALL p164C              ; 161D
        LD A,C                  ; 1620
        AND 01H                 ; 1621
        LD C,57H                ; 1623
        JP p0F9C                ; 1625

p1628:  PUSH BC                 ; 1628
        PUSH DE                 ; 1629
        PUSH HL                 ; 162A
        LD HL,xb3ED4            ; 162B
        LD DE,xf3F15            ; 162E start of buffer
        LD C,41H                ; 1631
p1633:  LD B,(HL)               ; 1633
        LD A,(DE)               ; 1634
        LD (HL),A               ; 1635
        LD A,B                  ; 1636
        LD (DE),A               ; 1637
        INC HL                  ; 1638
        INC DE                  ; 1639
        DEC C                   ; 163A
        JP NZ,p1633             ; 163B
        POP HL                  ; 163E
        POP DE                  ; 163F
        POP BC                  ; 1640
        RET                     ; 1641

p1642:  PUSH AF                 ; 1642
        LD A,(xb3CE7)           ; 1643
        OR A                    ; 1646
        CALL NZ,p04CD           ; 1647
        POP AF                  ; 164A
        RET                     ; 164B

p164C:  LD B,A                  ; 164C
        LD A,(xb3CEC)           ; 164D
        OR A                    ; 1650
        SCF                     ; 1651
        CALL NZ,p1662           ; 1652
        PUSH HL                 ; 1655
        LD HL,(xw3DD2)          ; 1656
        INC HL                  ; 1659
        LD (xw3DD2),HL          ; 165A
        POP HL                  ; 165D
        JP NZ,p1C27             ; 165E
        RET                     ; 1661

p1662:  PUSH HL                 ; 1662
        PUSH DE                 ; 1663
        PUSH BC                 ; 1664
        PUSH AF                 ; 1665
        CALL p2768              ; 1666
        LD HL,(xw3E0F)          ; 1669
        LD DE,xf3E27            ; 166C
        CALL p0D8D              ; 166F
        PUSH BC                 ; 1672
        CALL NC,p192B           ; 1673
        POP BC                  ; 1676
        LD HL,(xw3E0F)          ; 1677
        EX DE,HL                ; 167A
        LD A,(xb408F)           ; 167B
        OR A                    ; 167E
        JP Z,p16D3              ; 167F
        LD H,B                  ; 1682
        XOR A                   ; 1683
        ADD HL,HL               ; 1684
        ADC A,A                 ; 1685
        ADD HL,HL               ; 1686
        ADC A,A                 ; 1687
        ADD A,30H               ; 1688
        LD (DE),A               ; 168A
        INC DE                  ; 168B
        LD B,02H                ; 168C
p168E:  XOR A                   ; 168E
        LD C,03H                ; 168F
p1691:  ADD HL,HL               ; 1691
        ADC A,A                 ; 1692
        DEC C                   ; 1693
        JP NZ,p1691             ; 1694
        ADD A,30H               ; 1697
        LD (DE),A               ; 1699
        INC DE                  ; 169A
        DEC B                   ; 169B
        JP NZ,p168E             ; 169C
p169F:  EX DE,HL                ; 169F
        POP AF                  ; 16A0
        PUSH AF                 ; 16A1
        JP C,p16CA              ; 16A2
        LD A,(xb3ED4)           ; 16A5
        AND 0A0H                ; 16A8
        JP Z,p16CA              ; 16AA
        AND 80H                 ; 16AD
        JP NZ,p16C8             ; 16AF mid code
        LD A,(xb3EC1)           ; 16B2
        AND 03H                 ; 16B5
        CP 02H                  ; 16B7
        JP C,p16C5              ; 16B9 mid code
        JP Z,p16C2              ; 16BC mid code
        LD (HL),21H             ; 16BF
        DB 01H                  ; 16C1 (LD BC,2236H)
p16C2:  LD (HL),22H             ; 16C2
        DB 01H                  ; 16C4 (LD BC,2736H)
p16C5:  LD (HL),27H             ; 16C5
        DB 01H                  ; 16C7 (LD BC,2A36H)
p16C8:  LD (HL),2AH             ; 16C8

p16CA:  INC HL                  ; 16CA
        LD (xw3E0F),HL          ; 16CB
        POP AF                  ; 16CE
        POP BC                  ; 16CF
        POP DE                  ; 16D0
        POP HL                  ; 16D1
        RET                     ; 16D2

p16D3:  CALL p1914              ; 16D3
        JP p169F                ; 16D6

p16D9:  LD B,A                  ; 16D9
        LD A,(xb3ED4)           ; 16DA
        OR 40H                  ; 16DD
        LD (xb3ED4),A           ; 16DF
        LD A,(xb3CEC)           ; 16E2
        OR A                    ; 16E5
        CALL NZ,p1662           ; 16E6
        PUSH HL                 ; 16E9
        LD HL,(xw3DD2)          ; 16EA
        INC HL                  ; 16ED
        LD (xw3DD2),HL          ; 16EE
        POP HL                  ; 16F1
        JP NZ,p16FE             ; 16F2
        RET                     ; 16F5

p16F6:  LD A,(xb3ED4)           ; 16F6
        AND 0BFH                ; 16F9
        LD (xb3ED4),A           ; 16FB
p16FE:  PUSH HL                 ; 16FE
        LD HL,xb3ED4            ; 16FF
        LD A,(HL)               ; 1702
        AND 10H                 ; 1703
        JP Z,p1711              ; 1705
        CALL p04AF              ; 1708
        LD A,(HL)               ; 170B
        AND 40H                 ; 170C
        JP p17B4                ; 170E

p1711:  LD A,(HL)               ; 1711
        AND 0A0H                ; 1712
        JP Z,p17B9              ; 1714
        PUSH DE                 ; 1717
        PUSH BC                 ; 1718
        INC HL                  ; 1719
        LD A,(HL)               ; 171A
        AND 3FH                 ; 171B
        LD B,A                  ; 171D
p171E:  LD A,B                  ; 171E
        OR A                    ; 171F
        JP Z,p179A              ; 1720
        INC HL                  ; 1723
        DEC B                   ; 1724
        LD A,(HL)               ; 1725
        OR A                    ; 1726
        JP M,p1737              ; 1727
        LD (xb3ECD),A           ; 172A
        LD A,41H                ; 172D
        LD E,02H                ; 172F
p1731:  CALL p17BE              ; 1731
        JP p171E                ; 1734

p1737:  AND 7FH                 ; 1737
        RRA                     ; 1739
        JP C,p1768              ; 173A
        CP 03H                  ; 173D
        JP NZ,p1753             ; 173F
        INC HL                  ; 1742
        LD E,(HL)               ; 1743
        INC HL                  ; 1744
        LD D,(HL)               ; 1745
        DEC B                   ; 1746
        DEC B                   ; 1747
        EX DE,HL                ; 1748
        LD (xw3DDE),HL          ; 1749
        EX DE,HL                ; 174C
        PUSH BC                 ; 174D
        LD B,A                  ; 174E
        CALL p1B83              ; 174F
        POP BC                  ; 1752
p1753:  LD (xb3ECD),A           ; 1753
        INC HL                  ; 1756
        LD E,(HL)               ; 1757
        INC HL                  ; 1758
        LD D,(HL)               ; 1759
        DEC B                   ; 175A
        DEC B                   ; 175B
        EX DE,HL                ; 175C
        LD (xf3ECE),HL          ; 175D
        EX DE,HL                ; 1760
        LD A,43H                ; 1761
        LD E,04H                ; 1763
        JP p1731                ; 1765

p1768:  INC HL                  ; 1768
        LD E,(HL)               ; 1769
        INC HL                  ; 176A
        LD D,(HL)               ; 176B
        DEC B                   ; 176C
        DEC B                   ; 176D
        PUSH BC                 ; 176E
        PUSH HL                 ; 176F
        EX DE,HL                ; 1770
        DEC HL                  ; 1771
        LD A,(HL)               ; 1772
        CP 06H                  ; 1773
        JP C,p177A              ; 1775
        LD A,06H                ; 1778
p177A:  INC A                   ; 177A
        LD (xb3EC5),A           ; 177B
        DEC A                   ; 177E
        LD BC,0006H             ; 177F
        ADD HL,BC               ; 1782
        LD B,A                  ; 1783
        LD DE,xb3ECC            ; 1784
        LD A,42H                ; 1787
        LD (DE),A               ; 1789
p178A:  INC DE                  ; 178A
        INC HL                  ; 178B
        LD A,(HL)               ; 178C
        LD (DE),A               ; 178D
        DEC B                   ; 178E
        JP NZ,p178A             ; 178F
        CALL p17C5              ; 1792
        POP HL                  ; 1795
        POP BC                  ; 1796
        JP p171E                ; 1797

p179A:  LD A,(xb3ED4)           ; 179A
        AND 40H                 ; 179D
        PUSH AF                 ; 179F
        LD A,01H                ; 17A0
        JP NZ,p17A7             ; 17A2
        LD A,02H                ; 17A5
p17A7:  LD (xb3ECD),A           ; 17A7
        LD A,41H                ; 17AA
        LD E,02H                ; 17AC
        CALL p17BE              ; 17AE
        POP AF                  ; 17B1
        POP BC                  ; 17B2
        POP DE                  ; 17B3
p17B4:  LD B,00H                ; 17B4
        CALL Z,p1C27            ; 17B6
p17B9:  CALL p1C27              ; 17B9
        POP HL                  ; 17BC
        RET                     ; 17BD

p17BE:  LD (xb3ECC),A           ; 17BE
        LD A,E                  ; 17C1
        LD (xb3EC5),A           ; 17C2
p17C5:  PUSH BC                 ; 17C5
        PUSH HL                 ; 17C6
        LD HL,xb3EC6            ; 17C7
        LD (xw3D3F),HL          ; 17CA
        LD C,04H                ; 17CD
        CALL p1BA9              ; 17CF
        POP HL                  ; 17D2
        POP BC                  ; 17D3
        RET                     ; 17D4

p17D5:  LD A,(xb3CEC)           ; 17D5
        OR A                    ; 17D8
        CALL NZ,p18C9           ; 17D9
        PUSH HL                 ; 17DC
        LD HL,(xw3DD2)          ; 17DD
        INC HL                  ; 17E0
        INC HL                  ; 17E1
        LD (xw3DD2),HL          ; 17E2
        POP HL                  ; 17E5
        RET Z                   ; 17E6
        LD A,(xb3EC1)           ; 17E7
        LD B,A                  ; 17EA
        LD A,(xb3ED4)           ; 17EB
        AND 40H                 ; 17EE
        LD A,B                  ; 17F0
        CALL Z,p1893            ; 17F1
        LD A,(xb3EC1)           ; 17F4
        LD B,A                  ; 17F7
        CALL p1B83              ; 17F8
        LD HL,(xw3E0F)          ; 17FB
        AND 83H                 ; 17FE
        JP NZ,p180F             ; 1800
        INC HL                  ; 1803
        LD (xw3E0F),HL          ; 1804
        LD B,E                  ; 1807
        CALL p1C27              ; 1808
        LD B,D                  ; 180B
        JP p1C27                ; 180C

p180F:  LD A,B                  ; 180F
        AND 80H                 ; 1810
        PUSH BC                 ; 1812
        JP NZ,p1826             ; 1813
        LD A,B                  ; 1816
        AND 03H                 ; 1817
        CP 02H                  ; 1819
        JP M,p1837              ; 181B
        JP Z,p1834              ; 181E
        LD (HL),21H             ; 1821
        JP p1839                ; 1823

p1826:  LD (HL),2AH             ; 1826
        EX DE,HL                ; 1828
        LD HL,(xw3EBF)          ; 1829
        INC HL                  ; 182C
        INC HL                  ; 182D
        LD A,(HL)               ; 182E
        INC HL                  ; 182F
        LD H,(HL)               ; 1830
        LD L,A                  ; 1831
        EX DE,HL                ; 1832
        DB 01H                  ; 1833 (LD BC,2236H)
p1834:  LD (HL),22H             ; 1834
        DB 01H                  ; 1836 (LD BC,2736H)
p1837:  LD (HL),27H             ; 1837        
p1839:  POP BC                  ; 1839
        INC HL                  ; 183A
        INC HL                  ; 183B
        LD (xw3E0F),HL          ; 183C
        CALL p1B83              ; 183F
        LD A,B                  ; 1842
        AND 80H                 ; 1843
        JP Z,p1850              ; 1845
        LD A,(xb3ED4)           ; 1848
        AND 40H                 ; 184B
        JP NZ,p16F6             ; 184D
p1850:  LD A,B                  ; 1850
        AND 03H                 ; 1851
        PUSH BC                 ; 1853
        JP Z,p1888              ; 1854
        CALL p1C3A              ; 1857
        LD B,E                  ; 185A
        CALL p1C2B              ; 185B
        LD B,D                  ; 185E
        CALL p1C2B              ; 185F
p1862:  POP BC                  ; 1862
        LD A,B                  ; 1863
        AND 80H                 ; 1864
        RET Z                   ; 1866
        LD HL,(xw3DD2)          ; 1867
        DEC HL                  ; 186A
        DEC HL                  ; 186B
        EX DE,HL                ; 186C
        LD HL,(xw3EBF)          ; 186D
        INC HL                  ; 1870
        LD A,(xb3DD1)           ; 1871
        LD B,A                  ; 1874
        LD A,(HL)               ; 1875
        AND 0FCH                ; 1876
        OR B                    ; 1878
        LD (HL),A               ; 1879
        INC HL                  ; 187A
        LD (HL),E               ; 187B
        INC HL                  ; 187C
        LD (HL),D               ; 187D
        INC HL                  ; 187E
        EX DE,HL                ; 187F
        LD HL,(xw3DDC)          ; 1880
        EX DE,HL                ; 1883
        LD (HL),E               ; 1884
        INC HL                  ; 1885
        LD (HL),D               ; 1886
        RET                     ; 1887

p1888:  LD B,E                  ; 1888
        CALL p1C27              ; 1889
        LD B,D                  ; 188C
        CALL p1C27              ; 188D
        JP p1862                ; 1890

p1893:  PUSH AF                 ; 1893
        OR A                    ; 1894
        JP P,p18C7              ; 1895
        LD A,(xb3EBE)           ; 1898
        LD (xb3EC1),A           ; 189B
        LD A,(xb3EBD)           ; 189E
        OR A                    ; 18A1
        JP Z,p18C7              ; 18A2
        PUSH HL                 ; 18A5
        PUSH BC                 ; 18A6
        PUSH DE                 ; 18A7
        LD A,B                  ; 18A8
        CALL p1B83              ; 18A9
        AND 03H                 ; 18AC
        JP NZ,p18B3             ; 18AE
        LD A,D                  ; 18B1
        OR E                    ; 18B2
p18B3:  LD C,09H                ; 18B3
        CALL NZ,p1BA9           ; 18B5
        XOR A                   ; 18B8
        LD (xb3EBD),A           ; 18B9
        POP DE                  ; 18BC
        POP BC                  ; 18BD
        LD HL,(xw3EBF)          ; 18BE
        INC HL                  ; 18C1
        LD A,(HL)               ; 18C2
        LD (xb3EC1),A           ; 18C3
        POP HL                  ; 18C6
p18C7:  POP AF                  ; 18C7
        RET                     ; 18C8

p18C9:  PUSH AF                 ; 18C9
        PUSH HL                 ; 18CA
        PUSH DE                 ; 18CB
        LD HL,(xw3E0F)          ; 18CC
        LD DE,xf3E23            ; 18CF
        CALL p0D8D              ; 18D2
        CALL NC,p192B           ; 18D5
        LD HL,(xw3E0F)          ; 18D8
        EX DE,HL                ; 18DB
        POP HL                  ; 18DC
        PUSH HL                 ; 18DD
        LD A,(xb408F)           ; 18DE
        OR A                    ; 18E1
        JP Z,p1908              ; 18E2
        XOR A                   ; 18E5
        ADD HL,HL               ; 18E6
        ADC A,30H               ; 18E7
        LD (DE),A               ; 18E9
        INC DE                  ; 18EA
        PUSH BC                 ; 18EB
        LD B,05H                ; 18EC
p18EE:  XOR A                   ; 18EE
        LD C,03H                ; 18EF
p18F1:  ADD HL,HL               ; 18F1
        ADC A,A                 ; 18F2
        DEC C                   ; 18F3
        JP NZ,p18F1             ; 18F4
        ADD A,30H               ; 18F7
        LD (DE),A               ; 18F9
        INC DE                  ; 18FA
        DEC B                   ; 18FB
        JP NZ,p18EE             ; 18FC
p18FF:  EX DE,HL                ; 18FF
        LD (xw3E0F),HL          ; 1900
        POP BC                  ; 1903
        POP DE                  ; 1904
        POP HL                  ; 1905
        POP AF                  ; 1906
        RET                     ; 1907

p1908:  PUSH BC                 ; 1908
        LD B,H                  ; 1909
        CALL p1914              ; 190A
        LD B,L                  ; 190D
        CALL p1914              ; 190E
        JP p18FF                ; 1911

p1914:  LD A,B                  ; 1914
        RRA                     ; 1915
        RRA                     ; 1916
        RRA                     ; 1917
        RRA                     ; 1918
        CALL p191D              ; 1919
        LD A,B                  ; 191C
p191D:  AND 0FH                 ; 191D
        ADD A,30H               ; 191F
        CP 3AH                  ; 1921
        JP C,p1928              ; 1923
        ADD A,07H               ; 1926
p1928:  LD (DE),A               ; 1928
        INC DE                  ; 1929
        RET                     ; 192A

p192B:  PUSH AF                 ; 192B
        PUSH BC                 ; 192C
        PUSH DE                 ; 192D
        PUSH HL                 ; 192E
        CALL p1B16              ; 192F
        LD A,(xb3D2A)           ; 1932
        OR A                    ; 1935
        JP Z,p1947              ; 1936
        LD A,(xb3D29)           ; 1939
        OR A                    ; 193C
        JP Z,p1947              ; 193D
        LD A,(xb3D28)           ; 1940
        OR A                    ; 1943
        JP Z,p194E              ; 1944
p1947:  LD A,(xb3D2F)           ; 1947
        OR A                    ; 194A
        JP NZ,p1953             ; 194B
p194E:  LD A,(xb3E11)           ; 194E
        CP 20H                  ; 1951
p1953:  CALL NZ,p197E           ; 1953
        LD A,(xb3E11)           ; 1956
        CP 20H                  ; 1959
        JP Z,p196F              ; 195B
        LD A,(xf40B4)           ; 195E
        INC A                   ; 1961
        JP Z,p196F              ; 1962
        LD (xb3F5B),A           ; 1965
        CALL p197E              ; 1968
        XOR A                   ; 196B
        LD (xb3F5B),A           ; 196C
p196F:  INC A                   ; 196F
        LD (xb3D2B),A           ; 1970
        CALL p043F              ; 1973
        CALL p1B31              ; 1976
        POP HL                  ; 1979
        POP DE                  ; 197A
        POP BC                  ; 197B
        POP AF                  ; 197C
        RET                     ; 197D

p197E:  LD A,(xb3FFA)           ; 197E
        OR A                    ; 1981
        JP Z,p19BF              ; 1982
        DEC A                   ; 1985
        JP NZ,p199F             ; 1986
        LD A,(xb3FFB)           ; 1989
        OR A                    ; 198C
        JP NZ,p199F             ; 198D
        LD A,(xb3D2E)           ; 1990
        OR A                    ; 1993
        JP NZ,p19BF             ; 1994
        LD A,2BH                ; 1997
        LD (xf3E2B),A           ; 1999
        JP p19BF                ; 199C

p199F:  LD A,2BH                ; 199F
        LD (xf3E2B),A           ; 19A1
        LD A,(xb3E11)           ; 19A4
        CP 20H                  ; 19A7
        JP NZ,p19BF             ; 19A9
        LD A,(xb3D2E)           ; 19AC
        OR A                    ; 19AF
        JP M,p19BF              ; 19B0
        RET Z                   ; 19B3
        LD A,(xf3E13)           ; 19B4
        CP 20H                  ; 19B7
        RET Z                   ; 19B9
        LD A,(xb3D31)           ; 19BA
        OR A                    ; 19BD
        RET NZ                  ; 19BE
p19BF:  LD A,(xb3D2C)           ; 19BF
        OR A                    ; 19C2
        JP Z,p19CB              ; 19C3
        LD A,43H                ; 19C6
        LD (xb3E2A),A           ; 19C8
p19CB:  LD A,(xb3F5B)           ; 19CB
        OR A                    ; 19CE
        JP NZ,p19FD             ; 19CF
        LD A,(xb3D2F)           ; 19D2
        OR A                    ; 19D5
        JP NZ,p19DF             ; 19D6
        LD A,(xb3E11)           ; 19D9
        CP 20H                  ; 19DC
        RET Z                   ; 19DE
p19DF:  LD HL,xb3D33            ; 19DF
        INC (HL)                ; 19E2
        LD A,(xb3D32)           ; 19E3
        CP (HL)                 ; 19E6
        CALL Z,p1A70            ; 19E7
        LD A,(xb3F5B)           ; 19EA
        OR A                    ; 19ED
        JP NZ,p19FD             ; 19EE
        LD A,(xb408C)           ; 19F1
        OR A                    ; 19F4
        JP Z,p19FD              ; 19F5
        LD A,83H                ; 19F8
        CALL p4C76              ; 19FA
p19FD:  LD HL,xb3E11            ; 19FD
        LD B,20H                ; 1A00
p1A02:  LD A,(HL)               ; 1A02
        INC HL                  ; 1A03
        CALL p1A64              ; 1A04
        DEC B                   ; 1A07
        JP NZ,p1A02             ; 1A08
        LD A,(xb3D2B)           ; 1A0B
        OR A                    ; 1A0E
        JP NZ,p1A5A             ; 1A0F
        LD A,(xb3FFA)           ; 1A12
        DEC A                   ; 1A15
        JP M,p1A23              ; 1A16
        JP NZ,p1A23             ; 1A19
        LD A,(xb3FFB)           ; 1A1C
        OR A                    ; 1A1F
        JP Z,p1A23              ; 1A20
p1A23:  LD HL,xf3D39            ; 1A23 address
        LD B,06H                ; 1A26
p1A28:  LD A,(HL)               ; 1A28
        INC HL                  ; 1A29
        CP 30H                  ; 1A2A
        JP C,p1A36              ; 1A2C
        CALL p1A64              ; 1A2F
        DEC B                   ; 1A32
        JP NZ,p1A28             ; 1A33
p1A36:  LD A,06H                ; 1A36
        CP B                    ; 1A38
        JP NZ,p1A43             ; 1A39
        LD A,(xb3D38)           ; 1A3C
        OR A                    ; 1A3F
        JP Z,p1A48              ; 1A40
p1A43:  LD A,09H                ; 1A43
        CALL p1A64              ; 1A45
p1A48:  LD HL,xf3D48            ; 1A48 address of buffer
p1A4B:  LD A,(HL)               ; 1A4B
        INC HL                  ; 1A4C
        CP 0DH                  ; 1A4D
        JP Z,p1A5A              ; 1A4F
        CP 0CH                  ; 1A52
        CALL NZ,p1A64           ; 1A54
        JP p1A4B                ; 1A57

p1A5A:  LD A,CR                 ; 1A5A
        CALL p1A64              ; 1A5C
        LD A,LF                 ; 1A5F
        JP p1A64                ; 1A61

p1A64:  LD C,A                  ; 1A64
        LD A,(xb3F5B)           ; 1A65
        OR A                    ; 1A68
        LD A,C                  ; 1A69
        JP Z,p4C76              ; 1A6A
        JP p4AEE                ; 1A6D

p1A70:  LD A,04H                ; 1A70
        LD (xb3D33),A           ; 1A72
        LD A,(xb3D2F)           ; 1A75
        OR A                    ; 1A78
        JP Z,p1A8D              ; 1A79
        LD A,0CH                ; 1A7C
        CALL p4C76              ; 1A7E
        LD HL,xf3E31            ; 1A81 buffer start
        CALL p1AD5              ; 1A84
        LD HL,x1AF7             ; 1A87 MACRO-80 heading
        CALL p1AD5              ; 1A8A
p1A8D:  LD HL,(xw3D34)          ; 1A8D
        INC HL                  ; 1A90
        LD A,H                  ; 1A91
        OR L                    ; 1A92
        DEC HL                  ; 1A93
        PUSH AF                 ; 1A94
        LD A,(xb3D2F)           ; 1A95
        OR A                    ; 1A98
        JP Z,p1AA4              ; 1A99
        POP AF                  ; 1A9C
        PUSH AF                 ; 1A9D
        JP Z,p1ACD              ; 1A9E
        CALL p1ADF              ; 1AA1
p1AA4:  POP AF                  ; 1AA4
        LD HL,(xw3D36)          ; 1AA5
        INC HL                  ; 1AA8
        LD (xw3D36),HL          ; 1AA9
        LD A,(xb3D2F)           ; 1AAC
        OR A                    ; 1AAF
        RET Z                   ; 1AB0
        LD A,H                  ; 1AB1
        OR L                    ; 1AB2
        JP Z,p1ABE              ; 1AB3
        LD A,2DH                ; 1AB6
        CALL p4C76              ; 1AB8
        CALL p1ADF              ; 1ABB
p1ABE:  CALL p1A5A              ; 1ABE
        LD HL,xf3E81            ; 1AC1 Buffer
        CALL p1AD5              ; 1AC4
        CALL p1A5A              ; 1AC7
        JP p1A5A                ; 1ACA

p1ACD:  LD A,53H                ; 1ACD
        CALL p4C76              ; 1ACF
        JP p1AA4                ; 1AD2

p1AD5:  LD A,(HL)               ; 1AD5
        INC HL                  ; 1AD6
        OR A                    ; 1AD7
        RET Z                   ; 1AD8
        CALL p4C76              ; 1AD9
        JP p1AD5                ; 1ADC

p1ADF:  LD BC,0FFF6H            ; 1ADF
p1AE2:  LD D,B                  ; 1AE2
        LD E,B                  ; 1AE3
p1AE4:  ADD HL,BC               ; 1AE4
        INC DE                  ; 1AE5
        JP C,p1AE4              ; 1AE6
        PUSH HL                 ; 1AE9
        EX DE,HL                ; 1AEA
        LD A,H                  ; 1AEB
        OR L                    ; 1AEC
        CALL NZ,p1AE2           ; 1AED
        LD A,3AH                ; 1AF0
        POP BC                  ; 1AF2
        ADD A,C                 ; 1AF3
        JP p1A64                ; 1AF4
;=====================================
x1AF7:  DB 09H                  ; 1AF7
        DB 'MACRO-80 3.44'      ; 1AF8
        DB TAB                  ; 1B05
        DB '09-Dec-81'          ; 1B06
        DB TAB                  ; 1B0F
        DB 'PAGE'               ; 1BA0
        DB 09H,00
;=====================================
p1B16:  LD A,(xb3E11)           ; 1B16
        CP 20H                  ; 1B19
        RET Z                   ; 1B1B
        CP 51H                  ; 1B1C
        JP Z,p1B29              ; 1B1E
        LD HL,(xw3CED)          ; 1B21
        INC HL                  ; 1B24
        LD (xw3CED),HL          ; 1B25
        RET                     ; 1B28

p1B29:  LD HL,(xw3CEF)          ; 1B29
        INC HL                  ; 1B2C
        LD (xw3CEF),HL          ; 1B2D
p1B30:  RET                     ; 1B30

p1B31:  CALL p1B6A              ; 1B31
p1B34:  PUSH AF                 ; 1B34
p1B35:  LD A,(xb3CEC)           ; 1B35
        OR A                    ; 1B38
        JP Z,p18C7              ; 1B39
        LD A,(xf3E13)           ; 1B3C
        CP 20H                  ; 1B3F
p1B41:  JP NZ,p18C7             ; 1B41
        POP AF                  ; 1B44
        EX DE,HL                ; 1B45
        LD HL,xf3E13            ; 1B46 buffer
        LD (xw3E0F),HL          ; 1B49
        CALL p18C9              ; 1B4C
        AND 03H                 ; 1B4F
        PUSH BC                 ; 1B51
        LD C,A                  ; 1B52
        LD B,00H                ; 1B53
        LD HL,x1B66             ; 1B55 table
        ADD HL,BC               ; 1B58
        LD A,(HL)               ; 1B59
        LD HL,(xw3E0F)          ; 1B5A
        LD (HL),A               ; 1B5D
        LD HL,xf3E1B            ; 1B5E buffer address
        LD (xw3E0F),HL          ; 1B61
        POP BC                  ; 1B64
        RET                     ; 1B65

x1B66:  DB 20H,27H,22H,21H      ; 1B66

p1B6A:  LD HL,(xw3DD2)          ; 1B6A
        LD A,(xb3DE4)           ; 1B6D
        OR A                    ; 1B70
        JP Z,p1B7F              ; 1B71
        PUSH DE                 ; 1B74
        EX DE,HL                ; 1B75
        LD HL,(xw3DE5)          ; 1B76
        ADD HL,DE               ; 1B79
        POP DE                  ; 1B7A
        LD A,(xb3DE7)           ; 1B7B
        RET                     ; 1B7E

p1B7F:  LD A,(xb3DD1)           ; 1B7F
        RET                     ; 1B82

p1B83:  PUSH AF                 ; 1B83
        PUSH BC                 ; 1B84
        LD A,B                  ; 1B85
        AND 03H                 ; 1B86
        CP 03H                  ; 1B88
        JP NZ,p1BA6             ; 1B8A
        PUSH DE                 ; 1B8D
        PUSH HL                 ; 1B8E
p1B8F:  LD HL,(xw3DDC)          ; 1B8F
        EX DE,HL                ; 1B92
        LD HL,(xw3DDE)          ; 1B93
        CALL p0D8D              ; 1B96
        LD (xw3D3F),HL          ; 1B99
        LD (xw3DDC),HL          ; 1B9C
        LD C,01H                ; 1B9F
        CALL NZ,p1BA9           ; 1BA1
        POP HL                  ; 1BA4
        POP DE                  ; 1BA5
p1BA6:  POP BC                  ; 1BA6
        POP AF                  ; 1BA7
        RET                     ; 1BA8

p1BA9:  PUSH BC                 ; 1BA9
        LD B,00H                ; 1BAA
        CALL p1C3A              ; 1BAC
        LD B,C                  ; 1BAF
        LD A,04H                ; 1BB0
        CALL p1C0B              ; 1BB2
        POP BC                  ; 1BB5
        LD A,C                  ; 1BB6
        CP 05H                  ; 1BB7
        JP C,p1BD0              ; 1BB9
        CP 0FH                  ; 1BBC
        RET Z                   ; 1BBE
        LD A,02H                ; 1BBF
        CALL p1C0B              ; 1BC1
        LD B,E                  ; 1BC4
        CALL p1C2B              ; 1BC5
        LD B,D                  ; 1BC8
        CALL p1C2B              ; 1BC9
        LD A,C                  ; 1BCC
        CP 08H                  ; 1BCD
        RET NC                  ; 1BCF
p1BD0:  PUSH HL                 ; 1BD0
        LD B,06H                ; 1BD1
        CP 04H                  ; 1BD3
        JP Z,p1BDD              ; 1BD5
        CP 03H                  ; 1BD8
        JP NZ,p1BDE             ; 1BDA
p1BDD:  INC B                   ; 1BDD
p1BDE:  LD HL,(xw3D3F)          ; 1BDE
        DEC HL                  ; 1BE1
        LD A,(HL)               ; 1BE2
        CP B                    ; 1BE3
        JP C,p1BE8              ; 1BE4
        LD A,B                  ; 1BE7
p1BE8:  LD B,A                  ; 1BE8
        LD D,A                  ; 1BE9
        LD A,03H                ; 1BEA
        CALL p1C0B              ; 1BEC
        INC HL                  ; 1BEF
        INC HL                  ; 1BF0
        INC HL                  ; 1BF1
        INC HL                  ; 1BF2
        INC HL                  ; 1BF3
        INC HL                  ; 1BF4
        INC HL                  ; 1BF5
p1BF6:  LD B,(HL)               ; 1BF6
        LD A,C                  ; 1BF7
        CP 04H                  ; 1BF8
        JP Z,p1C01              ; 1BFA
        LD A,B                  ; 1BFD
        AND 7FH                 ; 1BFE
        LD B,A                  ; 1C00
p1C01:  CALL p1C2B              ; 1C01
        INC HL                  ; 1C04
        DEC D                   ; 1C05
        JP NZ,p1BF6             ; 1C06
        POP HL                  ; 1C09
        RET                     ; 1C0A

p1C0B:  PUSH DE                 ; 1C0B
        LD D,A                  ; 1C0C
        LD A,08H                ; 1C0D
        SUB D                   ; 1C0F
        JP Z,p1C1B              ; 1C10
        LD E,A                  ; 1C13
        LD A,B                  ; 1C14
p1C15:  ADD A,A                 ; 1C15
        DEC E                   ; 1C16
        JP NZ,p1C15             ; 1C17
        LD B,A                  ; 1C1A
p1C1B:  LD A,B                  ; 1C1B
        ADD A,A                 ; 1C1C
        LD B,A                  ; 1C1D
        CALL p1C46              ; 1C1E
        DEC D                   ; 1C21
        JP NZ,p1C1B             ; 1C22
        POP DE                  ; 1C25
        RET                     ; 1C26

p1C27:  XOR A                   ; 1C27
        CALL p1C46              ; 1C28
p1C2B:  PUSH BC                 ; 1C2B
        LD C,08H                ; 1C2C
p1C2E:  LD A,B                  ; 1C2E
        RLA                     ; 1C2F
        LD B,A                  ; 1C30
        CALL p1C46              ; 1C31
        DEC C                   ; 1C34
        JP NZ,p1C2E             ; 1C35
        POP BC                  ; 1C38
        RET                     ; 1C39

p1C3A:  SCF                     ; 1C3A
        CALL p1C46              ; 1C3B
        LD A,B                  ; 1C3E
        RRA                     ; 1C3F
        RRA                     ; 1C40
        CALL p1C46              ; 1C41
        LD A,B                  ; 1C44
        RRA                     ; 1C45
p1C46:  PUSH HL                 ; 1C46
        LD HL,xb3EC3            ; 1C47
        LD A,(HL)               ; 1C4A
        RLA                     ; 1C4B
        LD (HL),A               ; 1C4C
        INC HL                  ; 1C4D
        INC (HL)                ; 1C4E
        JP NZ,p1C5A             ; 1C4F
        CALL p4CDD              ; 1C52
        LD A,0F8H               ; 1C55
        LD (xb3EC4),A           ; 1C57
p1C5A:  POP HL                  ; 1C5A
        RET                     ; 1C5B

p1C5C:  PUSH BC                 ; 1C5C
        CALL p0B55              ; 1C5D
        POP BC                  ; 1C60
        JP Z,p1E43              ; 1C61
        JP P,p1D07              ; 1C64
        CP ' '                  ; 1C67
        JP Z,p1C5C              ; 1C69 Skip spaces
        CP TAB                  ; 1C6C TAB
        JP Z,p1C5C              ; 1C6E Skip tabs
        CP "'"                  ; 1C71
        JP Z,p1CC3              ; 1C73
        CP '"'                  ; 1C76
        JP Z,p1CC3              ; 1C78
        CP '('                  ; 1C7B
        JP Z,p1CAC              ; 1C7D
        CP ')'                  ; 1C80
        JP Z,p1CAF              ; 1C82 *
        CP '+'                  ; 1C85
        JP Z,p1CB2              ; 1C87 *
        CP '-'                  ; 1C8A
        JP Z,p1CB5              ; 1C8C *
        CP '*'                  ; 1C8F
        JP Z,p1CB8              ; 1C91 *
        CP '/'                  ; 1C94
        JP Z,p1CBB              ; 1C96 *
        CP ';'                  ; 1C99
        JP Z,p1CA8              ; 1C9B
        CP ','                  ; 1C9E
        JP Z,p1CA8              ; 1CA0
        CP CR                   ; 1CA3 <CR>
        CALL NZ,p04C1           ; 1CA5
p1CA8:  XOR A                   ; 1CA8
        JP p1CC0                ; 1CA9

; *Jumps into mid code
p1CAC:  LD A,02H                ; 1CAC
        DB 11H                  ; 1CAE (LD DE,033EH)
p1CAF:  LD A,03H                ; 1CAF
        DB 11H                  ; 1CB1 (LD DE,093EH)
p1CB2:  LD A,08H                ; 1CB2
        DB 11H                  ; 1CB4 (LD DE,093EH) 
p1CB5:  LD A,09H                ; 1CB5
        DB 11H                  ; 1CB7 (LD DE,0A3EH)
p1CB8:  LD A,0AH                ; 1CB8
        DB 11H                  ; 1CBA (LD DE,0B3EH)
p1CBB:  LD A,0BH                ; 1CBB
        DB 11H                  ; 1CBD (LD DE,013EH)
p1CBE:  LD A,01H                ; 1CBE 
p1CC0:  CP 01H                  ; 1CC0
        RET                     ; 1CC2

p1CC3:  LD HL,0000H             ; 1CC3
        PUSH BC                 ; 1CC6
        LD B,A                  ; 1CC7
        CALL p0B29              ; 1CC8
        CP B                    ; 1CCB
        JP NZ,p1CD9             ; 1CCC
        CALL p0B23              ; 1CCF
        CP B                    ; 1CD2
        JP NZ,p1CF9             ; 1CD3
        CALL p0B29              ; 1CD6
p1CD9:  LD L,A                  ; 1CD9
        LD (xb3DE2),A           ; 1CDA
        CALL p0B29              ; 1CDD
        CP B                    ; 1CE0
        JP NZ,p1CEF             ; 1CE1
        CALL p0B23              ; 1CE4
        CP B                    ; 1CE7
        LD A,B                  ; 1CE8
        JP NZ,p1CF4             ; 1CE9
        CALL p0B29              ; 1CEC
p1CEF:  LD H,L                  ; 1CEF
        LD L,A                  ; 1CF0
        CALL p0B29              ; 1CF1
p1CF4:  CP B                    ; 1CF4
        POP BC                  ; 1CF5
        JP p1D6E                ; 1CF6

p1CF9:  LD DE,xb3DE2            ; 1CF9
        LD A,(DE)               ; 1CFC
        OR A                    ; 1CFD
        JP NZ,p1D03             ; 1CFE
        DEC A                   ; 1D01
        LD (DE),A               ; 1D02
p1D03:  LD A,B                  ; 1D03
        JP p1CF4                ; 1D04

p1D07:  LD HL,(xw3D46)          ; 1D07
        DEC HL                  ; 1D0A
        PUSH HL                 ; 1D0B
p1D0C:  CALL p0B48              ; 1D0C
        JP P,p1D0C              ; 1D0F
        LD (xb3DE2),A           ; 1D12
        LD HL,(xw3D46)          ; 1D15
        DEC HL                  ; 1D18
        DEC HL                  ; 1D19
        LD (xw3D46),HL          ; 1D1A
        CALL p0B48              ; 1D1D
        POP HL                  ; 1D20
        LD (xw3D46),HL          ; 1D21
        JP NZ,p1DFB             ; 1D24
        CP 47H                  ; 1D27
        JP NC,p1D48             ; 1D29
        LD H,A                  ; 1D2C
        LD A,(xb3CF1)           ; 1D2D
        CP 0EH                  ; 1D30
        JP NC,p1DFB             ; 1D32
        LD L,A                  ; 1D35
        LD A,H                  ; 1D36
        CP 44H                  ; 1D37
        JP Z,p1D48              ; 1D39
        CP 42H                  ; 1D3C
        JP NZ,p1DFB             ; 1D3E
        LD A,L                  ; 1D41
        CP 0CH                  ; 1D42
        JP NC,p1DFB             ; 1D44
        LD A,H                  ; 1D47
p1D48:  CP 42H                  ; 1D48
        JP Z,p1D77              ; 1D4A
        CP 44H                  ; 1D4D
        JP Z,p1D95              ; 1D4F
        CP 48H                  ; 1D52
        JP Z,p1D9D              ; 1D54
        CP 4FH                  ; 1D57
        JP Z,p1D64              ; 1D59
        CP 51H                  ; 1D5C
        CALL NZ,p04C1           ; 1D5E
        JP NZ,p1D95             ; 1D61
p1D64:  CALL p1DBC              ; 1D64
        CP 4FH                  ; 1D67
        JP Z,p1D71              ; 1D69
        CP 51H                  ; 1D6C
p1D6E:  CALL NZ,p04C1           ; 1D6E
p1D71:  LD C,20H                ; 1D71
        EX DE,HL                ; 1D73
        JP p1CBE                ; 1D74

p1D77:  LD HL,0000H             ; 1D77
p1D7A:  CALL p0B48              ; 1D7A
        CP 42H                  ; 1D7D
        JP Z,p1D71              ; 1D7F
        SUB 30H                 ; 1D82
        CALL M,p04BB            ; 1D84
        CP 02H                  ; 1D87
        CALL NC,p04BB           ; 1D89
        ADD HL,HL               ; 1D8C
        OR A                    ; 1D8D
        JP Z,p1D7A              ; 1D8E
        INC HL                  ; 1D91
        JP p1D7A                ; 1D92

p1D95:  CALL p1DA5              ; 1D95
        CP 44H                  ; 1D98
        JP p1D6E                ; 1D9A

p1D9D:  CALL p1DD5              ; 1D9D
        CP 48H                  ; 1DA0
        JP p1D6E                ; 1DA2

p1DA5:  LD HL,0000H             ; 1DA5
p1DA8:  CALL p0B48              ; 1DA8
        RET Z                   ; 1DAB
        RET M                   ; 1DAC
        SUB 30H                 ; 1DAD
        ADD HL,HL               ; 1DAF
        LD D,H                  ; 1DB0
        LD E,L                  ; 1DB1
        ADD HL,HL               ; 1DB2
        ADD HL,HL               ; 1DB3
        ADD HL,DE               ; 1DB4
        LD D,00H                ; 1DB5
        LD E,A                  ; 1DB7
        ADD HL,DE               ; 1DB8
        JP p1DA8                ; 1DB9

p1DBC:  LD HL,0000H             ; 1DBC
p1DBF:  CALL p0B48              ; 1DBF
        RET Z                   ; 1DC2
        RET M                   ; 1DC3
        SUB 30H                 ; 1DC4
        CP 08H                  ; 1DC6
        CALL NC,p04BB           ; 1DC8
        ADD HL,HL               ; 1DCB
        ADD HL,HL               ; 1DCC
        ADD HL,HL               ; 1DCD
        LD E,A                  ; 1DCE
        LD D,00H                ; 1DCF
        ADD HL,DE               ; 1DD1
        JP p1DBF                ; 1DD2

p1DD5:  LD HL,0000H             ; 1DD5
p1DD8:  CALL p0B48              ; 1DD8
        RET M                   ; 1DDB
        CP 47H                  ; 1DDC
        JP NC,p1DF5             ; 1DDE
        SUB 30H                 ; 1DE1
        CP 0AH                  ; 1DE3
        JP C,p1DEA              ; 1DE5
        SUB 07H                 ; 1DE8
p1DEA:  ADD HL,HL               ; 1DEA
        ADD HL,HL               ; 1DEB
        ADD HL,HL               ; 1DEC
        ADD HL,HL               ; 1DED
        LD E,A                  ; 1DEE
        LD D,00H                ; 1DEF
        ADD HL,DE               ; 1DF1
        JP p1DD8                ; 1DF2

p1DF5:  CP 48H                  ; 1DF5
        RET Z                   ; 1DF7
        JP p04BB                ; 1DF8

p1DFB:  LD A,(xb3CF2)           ; 1DFB
        OR A                    ; 1DFE
        JP NZ,p1E34             ; 1DFF
        LD HL,0000H             ; 1E02
        PUSH BC                 ; 1E05
p1E06:  CALL p0B48              ; 1E06
        JP M,p1E30              ; 1E09
        SUB 30H                 ; 1E0C
        CP 0AH                  ; 1E0E
        JP C,p1E18              ; 1E10
        SUB 07H                 ; 1E13
        CALL C,p04BB            ; 1E15
p1E18:  LD C,A                  ; 1E18
        LD B,00H                ; 1E19
        LD A,(xb3CF1)           ; 1E1B
        DEC A                   ; 1E1E
        CP C                    ; 1E1F
        CALL C,p04BB            ; 1E20
        INC A                   ; 1E23
        LD E,A                  ; 1E24
        LD D,B                  ; 1E25
        PUSH BC                 ; 1E26
        CALL p2463              ; 1E27
        EX DE,HL                ; 1E2A
        POP BC                  ; 1E2B
        ADD HL,BC               ; 1E2C
        JP p1E06                ; 1E2D

p1E30:  POP BC                  ; 1E30
        JP p1E3D                ; 1E31

p1E34:  CALL p1DA5              ; 1E34
        JP p1E3D                ; 1E37

        CALL p1DBC              ; 1E3A
p1E3D:  CALL p0B36              ; 1E3D
        JP p1D71                ; 1E40

p1E43:  PUSH BC                 ; 1E43
        CALL p0B36              ; 1E44
        LD A,(xb3DE9)           ; 1E47
        LD (xb3DE2),A           ; 1E4A
        CP 05H                  ; 1E4D
        JP NC,p1EBF             ; 1E4F
        DEC A                   ; 1E52
        JP Z,p1FE4              ; 1E53
        CALL p0C24              ; 1E56
        JP Z,p1EBF              ; 1E59
        LD HL,x2010             ; 1E5C Operand table
        LD BC,0012H             ; 1E5F
p1E62:  DEC C                   ; 1E62
        JP Z,p1EBF              ; 1E63
        INC B                   ; 1E66
p1E67:  DEC B                   ; 1E67
        JP Z,p1E6F              ; 1E68
        INC HL                  ; 1E6B
        JP p1E67                ; 1E6C

p1E6F:  LD B,04H                ; 1E6F
        LD DE,xb3DEA            ; 1E71
p1E74:  LD A,(DE)               ; 1E74
        CP (HL)                 ; 1E75
        JP NZ,p1E62             ; 1E76
        INC DE                  ; 1E79
        INC HL                  ; 1E7A
        DEC B                   ; 1E7B
        JP NZ,p1E74             ; 1E7C
        LD HL,x2054-1           ; 1E7F end of list
        ADD HL,BC               ; 1E82
        LD A,(HL)               ; 1E83
        CP 1EH                  ; 1E84
        JP NZ,p1E8C             ; 1E86
        LD (xb3CEB),A           ; 1E89
p1E8C:  POP BC                  ; 1E8C
        OR A                    ; 1E8D
        JP P,p1CC0              ; 1E8E
        CALL p0BC8              ; 1E91
        LD DE,0FFFFH            ; 1E94
p1E97:  CP ';'                  ; 1E97
        JP Z,p1EB9              ; 1E99
        CP CR                   ; 1E9C <CR>
        JP Z,p1EB9              ; 1E9E
        OR A                    ; 1EA1
        JP NZ,p1EB0             ; 1EA2
        CALL p0AEA              ; 1EA5
        CP '&'                  ; 1EA8
        CALL Z,p0AEA            ; 1EAA
        JP p1E97                ; 1EAD

p1EB0:  CALL p0AEA              ; 1EB0
        CP CR                   ; 1EB3 <CR>
        JP NZ,p1EB0             ; 1EB5
        INC DE                  ; 1EB8
p1EB9:  CALL p0B36              ; 1EB9
        JP p1CBE                ; 1EBC

p1EBF:  LD HL,(xw3D46)          ; 1EBF
        PUSH HL                 ; 1EC2
        CALL p0AEA              ; 1EC3
        CP 23H                  ; 1EC6
        JP NZ,p1EED             ; 1EC8
        CALL p0AEA              ; 1ECB
        CP 23H                  ; 1ECE
        JP NZ,p1EED             ; 1ED0
        SCF                     ; 1ED3
        CALL p0CFC              ; 1ED4
        CALL p2D15              ; 1ED7
        INC HL                  ; 1EDA
        LD A,(HL)               ; 1EDB
        LD B,A                  ; 1EDC
        AND 20H                 ; 1EDD
        CALL NZ,p04B5           ; 1EDF
        LD A,B                  ; 1EE2
        AND 03H                 ; 1EE3
        OR 80H                  ; 1EE5
        LD (HL),A               ; 1EE7
        POP BC                  ; 1EE8
        DEC HL                  ; 1EE9
        JP p1F21                ; 1EEA

p1EED:  POP HL                  ; 1EED
        LD (xw3D46),HL          ; 1EEE
        CALL p0C24              ; 1EF1
        JP Z,p1F74              ; 1EF4
        LD A,(xb3CEA)           ; 1EF7
        ADD A,A                 ; 1EFA
        JP Z,p1F04              ; 1EFB
        CALL p0515              ; 1EFE
        JP Z,p1FAE              ; 1F01
p1F04:  LD A,(xb3CEB)           ; 1F04
        OR A                    ; 1F07
        JP Z,p1F1D              ; 1F08
        SCF                     ; 1F0B
        CALL p0D93              ; 1F0C
        CALL p0C24              ; 1F0F
        JP Z,p1F21              ; 1F12
        XOR A                   ; 1F15
        LD HL,(xw401D)          ; 1F16
        LD (HL),A               ; 1F19
        JP p1F21                ; 1F1A

p1F1D:  SCF                     ; 1F1D
        CALL p0CFC              ; 1F1E
p1F21:  AND 0A3H                ; 1F21
        LD B,A                  ; 1F23
        AND 80H                 ; 1F24
        LD A,B                  ; 1F26
        JP Z,p1F32              ; 1F27
        LD (xb3EBE),A           ; 1F2A
        LD B,80H                ; 1F2D
        LD (xw3EBF),HL          ; 1F2F
p1F32:  AND 10H                 ; 1F32
        CALL NZ,p04A9           ; 1F34
        LD A,(xb3CEA)           ; 1F37
        ADD A,A                 ; 1F3A
        LD A,00H                ; 1F3B
        JP NZ,p1F43             ; 1F3D
        LD A,(HL)               ; 1F40
        AND 40H                 ; 1F41
p1F43:  OR A                    ; 1F43
        LD A,B                  ; 1F44
        INC HL                  ; 1F45
        INC HL                  ; 1F46
        LD E,(HL)               ; 1F47
        INC HL                  ; 1F48
        LD D,(HL)               ; 1F49
        POP BC                  ; 1F4A
        LD C,A                  ; 1F4B
        JP Z,p1F51              ; 1F4C
        LD E,00H                ; 1F4F
p1F51:  AND 03H                 ; 1F51
        CP 03H                  ; 1F53
        JP NZ,p1F62             ; 1F55
        PUSH DE                 ; 1F58
        INC HL                  ; 1F59
        LD E,(HL)               ; 1F5A
        INC HL                  ; 1F5B
        LD D,(HL)               ; 1F5C
        EX DE,HL                ; 1F5D
        LD (xw3DDE),HL          ; 1F5E
        POP DE                  ; 1F61
p1F62:  LD A,C                  ; 1F62
        AND 20H                 ; 1F63
        LD A,C                  ; 1F65
        JP NZ,p1CBE             ; 1F66
        AND 80H                 ; 1F69
        CALL Z,p04D9            ; 1F6B
        LD DE,0000H             ; 1F6E
        JP p1CBE                ; 1F71

p1F74:  PUSH HL                 ; 1F74
        PUSH AF                 ; 1F75
        SCF                     ; 1F76
        CALL p0D93              ; 1F77
        POP AF                  ; 1F7A
        POP HL                  ; 1F7B
        LD (xw3D3F),HL          ; 1F7C
        LD A,(HL)               ; 1F7F
        AND 7FH                 ; 1F80
        CP 42H                  ; 1F82
        JP C,p1FA8              ; 1F84
        LD A,(HL)               ; 1F87
        AND 38H                 ; 1F88
        PUSH AF                 ; 1F8A
        LD A,(xb3CE7)           ; 1F8B
        OR A                    ; 1F8E
        CALL NZ,p04C1           ; 1F8F
        POP AF                  ; 1F92
        LD (xb3CE7),A           ; 1F93
        INC HL                  ; 1F96
        INC HL                  ; 1F97
        LD A,(HL)               ; 1F98
        LD (xb3CE8),A           ; 1F99
        CALL p2065              ; 1F9C
        CALL Z,p207A            ; 1F9F
        DEC HL                  ; 1FA2
        LD A,(HL)               ; 1FA3
        DEC HL                  ; 1FA4
        JP p1F21                ; 1FA5

p1FA8:  INC HL                  ; 1FA8
        LD A,(HL)               ; 1FA9
        DEC HL                  ; 1FAA
        JP p1F21                ; 1FAB

p1FAE:  OR A                    ; 1FAE
        JP M,p1F04              ; 1FAF
        INC HL                  ; 1FB2
        LD E,(HL)               ; 1FB3
        AND 78H                 ; 1FB4
        RRA                     ; 1FB6
        RRA                     ; 1FB7
        RRA                     ; 1FB8
        LD C,A                  ; 1FB9
        LD D,00H                ; 1FBA
        LD B,D                  ; 1FBC
        LD HL,x1FDA             ; 1FBD
        ADD HL,BC               ; 1FC0
        LD A,(HL)               ; 1FC1
        OR A                    ; 1FC2
        JP Z,p1FD4              ; 1FC3
        CP 1DH                  ; 1FC6
        JP NZ,p1FCE             ; 1FC8
        LD (xb3EC7),A           ; 1FCB
p1FCE:  POP BC                  ; 1FCE
        LD C,20H                ; 1FCF
        JP p1CC0                ; 1FD1

p1FD4:  POP BC                  ; 1FD4
        LD C,20H                ; 1FD5
        JP p1CBE                ; 1FD7
;=====================================
x1FDA:  DB 00H,1BH,1AH,18H
        DB 19H,00H,00H,1DH
        DB 19H,1AH
;=====================================
p1FE4:  LD A,(xb3DEA)           ; 1FE4
        CP 58H                  ; 1FE7
        JP NZ,p2000             ; 1FE9
        CALL p0B23              ; 1FEC
        CP 27H                  ; 1FEF
        JP NZ,p1EBF             ; 1FF1
        CALL p0AEA              ; 1FF4
        CALL p1DD5              ; 1FF7
        CP 27H                  ; 1FFA
        POP BC                  ; 1FFC
        JP p1D6E                ; 1FFD

p2000:  CP 24H                  ; 2000
        JP NZ,p1EBF             ; 2002
        CALL p1B6A              ; 2005
        EX DE,HL                ; 2008
        ADD A,20H               ; 2009
        POP BC                  ; 200B
        LD C,A                  ; 200C
        JP p1CBE                ; 200D

x2010:  DB "XOR AND NOT MOD "
        DB "SHL SHR OR  EQ  "
        DB "NE  LT  LE  GT  "
        DB "GE  LOW HIGHNUL "
        DB "TYPE"

x2054:  DB 1EH,0FFH             ; 2054
        DB 16H,15H,14H,13H      ; 2056
        DB 12H,11H,10H,0FH      ; 205A
        DB 04H,0EH,0DH,0CH      ; 205E 
        DB 07H,06H,05H          ; 2063      

p2065:  LD A,(xb3CE7)           ; 2065
        CP ' '                  ; 2068
        RET NZ                  ; 206A
        LD A,(xb3CE8)           ; 206B
        CP 06H                  ; 206E ^F
        RET NZ                  ; 2070
        LD A,(xb3CE6)           ; 2071
        CP 'A'                  ; 2074
        RET Z                   ; 2076
        CP 'a'                  ; 2077
        RET                     ; 2079

p207A:  CALL p0B23              ; 207A
        CP 27H                  ; 207D
        CALL Z,p0AEA            ; 207F
        RET                     ; 2082

p2083:  XOR A                   ; 2083
        LD B,A                  ; 2084
        LD C,20H                ; 2085
        LD L,A                  ; 2087
        LD H,A                  ; 2088
        LD (xb3EC7),A           ; 2089
        LD (xb3EBD),A           ; 208C
        LD (xb3DE2),A           ; 208F
        LD (xb3CEB),A           ; 2092
        LD (xb3ED4),A           ; 2095
        LD (xf3ED5),A           ; 2098
        LD (xb3ED3),A           ; 209B
        LD (xb3CE7),A           ; 209E
        LD (xb3CE8),A           ; 20A1
        ADD HL,SP               ; 20A4
        LD (xw3EC8),HL          ; 20A5
        EX DE,HL                ; 20A8
        LD HL,(xw4029)          ; 20A9
        CALL p0D8D              ; 20AC
        JP NC,p3414             ; 20AF
        PUSH BC                 ; 20B2
p20B3:  CALL p1C5C              ; 20B3
        JP M,p211B              ; 20B6
        JP Z,p215D              ; 20B9
        CP 03H                  ; 20BC
        JP M,p217E              ; 20BE
        JP Z,p21F2              ; 20C1
        CP 18H                  ; 20C4
        JP C,p20CE              ; 20C6
        CP 1EH                  ; 20C9
        CALL C,p2166            ; 20CB
p20CE:  LD C,A                  ; 20CE
        LD (xb3EC6),A           ; 20CF
        CALL p2183              ; 20D2
        DEC A                   ; 20D5
        CP B                    ; 20D6
        LD A,C                  ; 20D7
        JP NC,p220C             ; 20D8
        CP 08H                  ; 20DB
        JP Z,p2204              ; 20DD
        CP 09H                  ; 20E0
        JP Z,p2204              ; 20E2
p20E5:  CALL p223F              ; 20E5
        LD A,C                  ; 20E8
        LD (xb3F57),A           ; 20E9
        CALL p218E              ; 20EC
        CP 02H                  ; 20EF
        JP Z,p213C              ; 20F1
        OR A                    ; 20F4
        JP NZ,p2107             ; 20F5
        LD A,(xb3EC6)           ; 20F8
        CP 03H                  ; 20FB
        JP NZ,p213C             ; 20FD
        CALL Z,p04C1            ; 2100
        PUSH BC                 ; 2103
        JP p213C                ; 2104

p2107:  PUSH BC                 ; 2107
        CALL p2183              ; 2108
        PUSH AF                 ; 210B
        LD A,(xb3F57)           ; 210C
        LD C,A                  ; 210F
        POP AF                  ; 2110
        CALL p2166              ; 2111
        LD B,A                  ; 2114
        LD A,(xb3EC6)           ; 2115
        JP p20CE                ; 2118

p211B:  PUSH AF                 ; 211B
        CALL p0B36              ; 211C
        CALL p0AEA              ; 211F
        CP 2CH                  ; 2122
        JP NZ,p2138             ; 2124
        LD A,(xb3EC7)           ; 2127
        OR A                    ; 212A
        JP Z,p2138              ; 212B
        POP AF                  ; 212E
        XOR A                   ; 212F
        LD (xb3EC7),A           ; 2130
        LD A,1CH                ; 2133
        JP p20CE                ; 2135

p2138:  POP AF                  ; 2138
        JP p219F                ; 2139

p213C:  LD A,(xb3F57)           ; 213C
        LD C,A                  ; 213F
        LD A,(xb3EC6)           ; 2140
        CP 03H                  ; 2143
        JP Z,p214F              ; 2145
        PUSH BC                 ; 2148
        CALL p2166              ; 2149
        JP p220C                ; 214C

p214F:  POP BC                  ; 214F
        PUSH BC                 ; 2150
        LD A,B                  ; 2151
        CALL p2183              ; 2152
        LD B,A                  ; 2155
        LD A,(xb3F57)           ; 2156
        LD C,A                  ; 2159
        JP p2160                ; 215A

p215D:  CALL p22C4              ; 215D
p2160:  CALL p2166              ; 2160
        JP p20B3                ; 2163

p2166:  POP HL                  ; 2166
        PUSH DE                 ; 2167
        LD E,A                  ; 2168
        LD A,C                  ; 2169
        AND 03H                 ; 216A
        CP 03H                  ; 216C
        LD A,E                  ; 216E
        JP NZ,p2179             ; 216F
        EX DE,HL                ; 2172
        LD HL,(xw3DDE)          ; 2173
        EX (SP),HL              ; 2176
        PUSH HL                 ; 2177
        EX DE,HL                ; 2178
p2179:  LD D,01H                ; 2179
        LD E,C                  ; 217B
        PUSH DE                 ; 217C
p217D:  JP (HL)                 ; 217D

p217E:  LD B,A                  ; 217E
        PUSH BC                 ; 217F
        JP p20B3                ; 2180

p2183:  PUSH DE                 ; 2183
        LD HL,x22FB             ; 2184 data table
        LD E,A                  ; 2187
        LD D,00H                ; 2188
        ADD HL,DE               ; 218A
        LD A,(HL)               ; 218B
        POP DE                  ; 218C
        RET                     ; 218D

p218E:  POP HL                  ; 218E
        POP BC                  ; 218F
        LD A,B                  ; 2190
        CP 01H                  ; 2191
        JP NZ,p219E             ; 2193
        CALL p04C1              ; 2196
        PUSH BC                 ; 2199
        XOR A                   ; 219A
        LD B,A                  ; 219B
        CP 01H                  ; 219C
p219E:  JP (HL)                 ; 219E
p219F:  POP HL                  ; 219F
        LD A,H                  ; 21A0
        CP 01H                  ; 21A1
        SBC A,A                 ; 21A3
        LD (xb3EC2),A           ; 21A4
        PUSH HL                 ; 21A7
p21A8:  CALL p223F              ; 21A8
        LD A,C                  ; 21AB
        LD (xb3F57),A           ; 21AC
        CALL p218E              ; 21AF
        JP M,p21CF              ; 21B2
        CP 02H                  ; 21B5
        JP Z,p2546              ; 21B7
        PUSH BC                 ; 21BA
        LD A,(xb3F57)           ; 21BB
        LD C,A                  ; 21BE
        CALL p2166              ; 21BF
        JP p21A8                ; 21C2

p21C5:  LD DE,0000H             ; 21C5
        CALL p0B40              ; 21C8
        XOR A                   ; 21CB
        LD (xb3F57),A           ; 21CC
p21CF:  LD A,(xb3F57)           ; 21CF
        LD B,A                  ; 21D2
        LD (xb3EC1),A           ; 21D3
        AND 03H                 ; 21D6
        LD C,A                  ; 21D8
        JP Z,p21DE              ; 21D9
        LD C,20H                ; 21DC
p21DE:  LD A,B                  ; 21DE
        AND 80H                 ; 21DF
        OR C                    ; 21E1
        LD HL,xb3ED4            ; 21E2
        OR (HL)                 ; 21E5
        LD (HL),A               ; 21E6
        LD HL,(xw3D46)          ; 21E7
        DEC HL                  ; 21EA
        LD C,(HL)               ; 21EB
        LD A,E                  ; 21EC
        LD HL,(xw3EC8)          ; 21ED
        LD SP,HL                ; 21F0
        RET                     ; 21F1

p21F2:  LD (xb3EC6),A           ; 21F2
        POP DE                  ; 21F5
        LD A,D                  ; 21F6
        CP 02H                  ; 21F7
        CALL Z,p04C1            ; 21F9
        OR A                    ; 21FC
        CALL Z,p04C1            ; 21FD
        PUSH DE                 ; 2200
        JP p20E5                ; 2201

p2204:  EX (SP),HL              ; 2204
        LD A,H                  ; 2205
        EX (SP),HL              ; 2206
        DEC A                   ; 2207
        JP Z,p20E5              ; 2208
        LD A,C                  ; 220B
p220C:  POP BC                  ; 220C
        LD D,A                  ; 220D
        PUSH BC                 ; 220E
        LD A,B                  ; 220F
        DEC A                   ; 2210
        LD A,D                  ; 2211
        JP Z,p2236              ; 2212
        LD A,D                  ; 2215
        CP 07H                  ; 2216
        JP Z,p2236              ; 2218
        CP 08H                  ; 221B
        JP Z,p20B3              ; 221D
        CP 15H                  ; 2220
        JP Z,p2236              ; 2222
        CP 16H                  ; 2225
        JP Z,p2236              ; 2227
        CP 1EH                  ; 222A
        JP Z,p2236              ; 222C
        CP 09H                  ; 222F
        CALL NZ,p04C1           ; 2231
        LD A,17H                ; 2234
p2236:  LD B,A                  ; 2236
        PUSH BC                 ; 2237
        CALL p2183              ; 2238
        LD B,A                  ; 223B
        JP p20B3                ; 223C

p223F:  POP HL                  ; 223F
        LD (xw3F59),HL          ; 2240
        POP DE                  ; 2243
        LD A,D                  ; 2244
        OR A                    ; 2245
p2246:  PUSH DE                 ; 2246
        JP NZ,p2252             ; 2247
        LD DE,0000H             ; 224A
        PUSH DE                 ; 224D
        LD DE,0120H             ; 224E
        PUSH DE                 ; 2251
p2252:  CALL p22AA              ; 2252
        LD (xw3DE0),HL          ; 2255
        EX DE,HL                ; 2258
        LD (xw3ECA),HL          ; 2259
        EX DE,HL                ; 225C
        LD A,C                  ; 225D
        LD (xb3F57),A           ; 225E
        CALL p218E              ; 2261
        JP M,p22A1              ; 2264
        SUB 02H                 ; 2267
        JP Z,p22A1              ; 2269
        LD (xb3F58),A           ; 226C
        CP 05H                  ; 226F
        JP Z,p228B              ; 2271
        CP 14H                  ; 2274
        JP Z,p228B              ; 2276
        CP 13H                  ; 2279
        JP Z,p228B              ; 227B
        CP 15H                  ; 227E
        JP Z,p228B              ; 2280
        CP 1CH                  ; 2283
        JP Z,p228B              ; 2285
        CALL p22AA              ; 2288
p228B:  LD A,(xb3F58)           ; 228B
        LD HL,(xw3F59)          ; 228E
        PUSH HL                 ; 2291
        LD HL,x2316             ; 2292 dispatch table
        ADD A,A                 ; 2295
        ADD A,L                 ; 2296
        LD L,A                  ; 2297
        LD A,00H                ; 2298
        ADC A,H                 ; 229A
        LD H,A                  ; 229B
        LD A,(HL)               ; 229C
        INC HL                  ; 229D
        LD H,(HL)               ; 229E
        LD L,A                  ; 229F
        JP (HL)                 ; 22A0

p22A1:  PUSH BC                 ; 22A1
        LD A,(xb3F57)           ; 22A2
        LD C,A                  ; 22A5
        LD HL,(xw3F59)          ; 22A6
        JP (HL)                 ; 22A9

p22AA:  POP HL                  ; 22AA
        POP BC                  ; 22AB
        DEC B                   ; 22AC
        CALL NZ,p04C1           ; 22AD
        JP Z,p22B6              ; 22B0
        INC B                   ; 22B3
        PUSH BC                 ; 22B4
        JP (HL)                 ; 22B5

p22B6:  POP DE                  ; 22B6
        LD A,C                  ; 22B7
        AND 03H                 ; 22B8
        CP 03H                  ; 22BA
        JP NZ,p217D             ; 22BC
        EX (SP),HL              ; 22BF
        LD (xw3DDE),HL          ; 22C0
        RET                     ; 22C3

p22C4:  PUSH AF                 ; 22C4
        PUSH DE                 ; 22C5
        PUSH HL                 ; 22C6
        LD A,C                  ; 22C7
        RLCA                    ; 22C8
        AND 07H                 ; 22C9
        OR 80H                  ; 22CB
        CALL p25CC              ; 22CD
        AND 07H                 ; 22D0
        CP 06H                  ; 22D2
        JP NZ,p22E3             ; 22D4
        PUSH DE                 ; 22D7
        LD HL,(xw3DDE)          ; 22D8
        EX DE,HL                ; 22DB
        CALL p22F3              ; 22DC
        POP DE                  ; 22DF
        JP p22EC                ; 22E0

p22E3:  CP 01H                  ; 22E3
        JP NZ,p22EC             ; 22E5
        LD HL,(xw3EBF)          ; 22E8
        EX DE,HL                ; 22EB
p22EC:  CALL p22F3              ; 22EC
        POP HL                  ; 22EF
        POP DE                  ; 22F0
        POP AF                  ; 22F1
        RET                     ; 22F2

p22F3:  LD A,E                  ; 22F3
        CALL p25CC              ; 22F4
        LD A,D                  ; 22F7
        JP p25CC                ; 22F8
;=====================================
; DATA
x22FB:  DB 01H,01H,01H,01H      ; 22FB
        DB 04H,04H,05H,06H      ; 22FF
        DB 08H,08H,09H,09H      ; 2303
        DB 09H,09H,09H,07H      ; 2307
        DB 07H,07H,07H,07H      ; 230B
        DB 07H,0AH,0AH,0AH      ; 230F
        DB 02H,02H,02H,02H      ; 2313
        DB 03H,02H,0AH          ; 2317

x2316:  EQU $-4
X231A:  DW p2350                ; 231A
        DW p235A                ; 231C
        DW p2364                ; 231E
        DW p236E                ; 2320
        DW p23CF                ; 2322
        DW p23FE                ; 2324
        DW p244E                ; 2326
        DW p249E                ; 2328
        DW p2517                ; 232A
        DW p239D                ; 232C
        DW p23AE                ; 232E
        DW p2551                ; 2330
        DW p255C                ; 2332
        DW p2568                ; 2334
        DW p2575                ; 2336
        DW p257B                ; 2338
        DW p2584                ; 233A
        DW p25B6                ; 233C
        DW p25A7                ; 234E
        DW p2385                ; 2340
        DW p25F4                ; 2342
        DW p2600                ; 2344
        DW p260F                ; 2346
        DW p261E                ; 2348
        DW p262D                ; 234A
        DW p2643                ; 234C
        DW p2663                ; 234E
;=====================================
p2350:  CALL p2484              ; 2350
        LD A,D                  ; 2353
        OR H                    ; 2354
        LD D,A                  ; 2355
        LD A,E                  ; 2356
        OR L                    ; 2357
        LD E,A                  ; 2358
        RET                     ; 2359

p235A:  CALL p2484              ; 235A
        LD A,D                  ; 235D
        XOR H                   ; 235E
        LD D,A                  ; 235F
        LD A,E                  ; 2360
        XOR L                   ; 2361
        LD E,A                  ; 2362
        RET                     ; 2363

p2364:  CALL p2484              ; 2364
        LD A,D                  ; 2367
        AND H                   ; 2368
        LD D,A                  ; 2369
        LD A,E                  ; 236A
        AND L                   ; 236B
        LD E,A                  ; 236C
        RET                     ; 236D

p236E:  LD HL,(xw3ECA)          ; 236E
        LD A,H                  ; 2371
        CPL                     ; 2372
        LD D,A                  ; 2373
        LD A,L                  ; 2374
        CPL                     ; 2375
        LD E,A                  ; 2376
        LD A,(xb3F57)           ; 2377
        LD C,A                  ; 237A
        AND 83H                 ; 237B
        LD A,05H                ; 237D
        JP NZ,p25C2             ; 237F
        JP p25CC                ; 2382

p2385:  LD HL,(xw3ECA)          ; 2385
        LD A,H                  ; 2388
        CPL                     ; 2389
        LD D,A                  ; 238A
        LD A,L                  ; 238B
        CPL                     ; 238C
        LD E,A                  ; 238D
        INC DE                  ; 238E
        LD A,(xb3F57)           ; 238F
        LD C,A                  ; 2392
        AND 83H                 ; 2393
        LD A,06H                ; 2395
        JP NZ,p25C2             ; 2397
        JP p25CC                ; 239A

p239D:  CALL p2484              ; 239D
        EX DE,HL                ; 23A0
        INC DE                  ; 23A1
p23A2:  DEC DE                  ; 23A2 time wasting loop
        LD A,D                  ; 23A3
        OR E                    ; 23A4
        JP Z,p23AC              ; 23A5
        ADD HL,HL               ; 23A8
        JP p23A2                ; 23A9

p23AC:  EX DE,HL                ; 23AC
        RET                     ; 23AD

p23AE:  CALL p2484              ; 23AE
        INC HL                  ; 23B1
p23B2:  DEC HL                  ; 23B2
        LD A,L                  ; 23B3
        OR H                    ; 23B4
        RET Z                   ; 23B5
        LD A,D                  ; 23B6
        RRA                     ; 23B7
        LD D,A                  ; 23B8
        LD A,E                  ; 23B9
        RRA                     ; 23BA
        LD E,A                  ; 23BB
        JP p23B2                ; 23BC

        LD HL,(xw3ECA)          ; 23BF
        LD A,(xb3F57)           ; 23C2
        AND 80H                 ; 23C5
        RET Z                   ; 23C7
        LD A,C                  ; 23C8
        AND 80H                 ; 23C9
        CALL M,p04AF            ; 23CB
        RET                     ; 23CE

p23CF:  CALL p23E0              ; 23CF
        LD A,(xb3F57)           ; 23D2
        OR C                    ; 23D5
        LD C,A                  ; 23D6
        AND 83H                 ; 23D7
        CP 80H                  ; 23D9
        RET NZ                  ; 23DB
        LD (xb3EBD),A           ; 23DC
        RET                     ; 23DF

p23E0:  LD A,(xb3F57)           ; 23E0
        CP 20H                  ; 23E3
        JP Z,p23EE              ; 23E5
        LD HL,(xw3DE0)          ; 23E8
        LD (xw3DDE),HL          ; 23EB
p23EE:  LD HL,(xw3ECA)          ; 23EE
        ADD HL,DE               ; 23F1
        EX DE,HL                ; 23F2
        CALL p2494              ; 23F3
        LD A,08H                ; 23F6
        JP NZ,p25C2             ; 23F8
        JP p25CC                ; 23FB

p23FE:  LD HL,(xw3ECA)          ; 23FE
        CALL p2447              ; 2401
        LD A,(xb3F57)           ; 2404
        AND 83H                 ; 2407
        JP M,p2425              ; 2409
        JP Z,p2425              ; 240C
        LD A,C                  ; 240F
        AND 83H                 ; 2410
        JP M,p2425              ; 2412
        JP Z,p2424              ; 2415
        LD A,(xb3F57)           ; 2418
        CP C                    ; 241B
        JP NZ,p2425             ; 241C
        LD C,20H                ; 241F
        JP p243F                ; 2421

p2424:  DEC A                   ; 2424
p2425:  PUSH AF                 ; 2425
        LD A,(xb3F57)           ; 2426
        AND 83H                 ; 2429
        JP NZ,p2439             ; 242B
        LD A,C                  ; 242E
        AND 83H                 ; 242F
        CP 80H                  ; 2431
        JP NZ,p2439             ; 2433
        LD (xb3EBD),A           ; 2436
p2439:  LD A,(xb3F57)           ; 2439
        OR C                    ; 243C
        LD C,A                  ; 243D
        POP AF                  ; 243E
p243F:  LD A,07H                ; 243F
        JP NZ,p25C2             ; 2441
        JP p25CC                ; 2444

p2447:  LD A,E                  ; 2447
        SUB L                   ; 2448
        LD E,A                  ; 2449
        LD A,D                  ; 244A
        SBC A,H                 ; 244B
        LD D,A                  ; 244C
        RET                     ; 244D

p244E:  LD HL,(xw3ECA)          ; 244E
        CALL p2469              ; 2451
        LD A,(xb3F57)           ; 2454
        OR C                    ; 2457
        LD C,A                  ; 2458
        AND 83H                 ; 2459
        LD A,09H                ; 245B
        JP NZ,p25C2             ; 245D
        JP p25CC                ; 2460

p2463:  CALL p2469              ; 2463
        LD C,20H                ; 2466
        RET                     ; 2468

p2469:  LD B,H                  ; 2469
        LD C,L                  ; 246A
        LD HL,0000H             ; 246B
        LD A,11H                ; 246E
p2470:  DEC A                   ; 2470
        JP Z,p2482              ; 2471
        ADD HL,HL               ; 2474
        PUSH HL                 ; 2475
        PUSH BC                 ; 2476
        POP HL                  ; 2477
        ADD HL,HL               ; 2478
        EX (SP),HL              ; 2479
        POP BC                  ; 247A
        JP NC,p2470             ; 247B
        ADD HL,DE               ; 247E
        JP p2470                ; 247F

p2482:  EX DE,HL                ; 2482
        RET                     ; 2483

p2484:  LD A,(xb3F57)           ; 2484
        CP C                    ; 2487
        CALL NZ,p04D3           ; 2488
        CP 20H                  ; 248B
        CALL NZ,p04D3           ; 248D
        LD HL,(xw3ECA)          ; 2490
        RET                     ; 2493

p2494:  LD A,(xb3F57)           ; 2494
        AND 83H                 ; 2497
        RET Z                   ; 2499
        LD A,C                  ; 249A
        AND 83H                 ; 249B
        RET                     ; 249D

p249E:  LD HL,(xw3ECA)          ; 249E
        CALL p24B3              ; 24A1
        LD A,(xb3F57)           ; 24A4
        OR C                    ; 24A7
        LD C,A                  ; 24A8
        AND 83H                 ; 24A9
        LD A,0AH                ; 24AB
        JP NZ,p25C2             ; 24AD
        JP p25CC                ; 24B0

p24B3:  PUSH BC                 ; 24B3
        EX DE,HL                ; 24B4
        LD A,D                  ; 24B5
        OR E                    ; 24B6
        CALL Z,p04C1            ; 24B7
        LD A,D                  ; 24BA
        OR A                    ; 24BB
        LD B,D                  ; 24BC
        CALL M,p250F            ; 24BD
        LD A,H                  ; 24C0
        XOR B                   ; 24C1
        LD B,A                  ; 24C2
        LD A,H                  ; 24C3
        OR L                    ; 24C4
        JP Z,p24D8              ; 24C5
        LD A,H                  ; 24C8
        OR A                    ; 24C9
        EX DE,HL                ; 24CA
        CALL M,p250F            ; 24CB
        PUSH BC                 ; 24CE
        CALL p24DB              ; 24CF
        POP AF                  ; 24D2
        OR A                    ; 24D3
        CALL M,p250F            ; 24D4
        EX DE,HL                ; 24D7
p24D8:  EX DE,HL                ; 24D8
        POP BC                  ; 24D9
        RET                     ; 24DA

p24DB:  LD A,H                  ; 24DB
        CPL                     ; 24DC
        LD B,A                  ; 24DD
        LD A,L                  ; 24DE
        CPL                     ; 24DF
        LD C,A                  ; 24E0
        INC BC                  ; 24E1
        LD HL,0000H             ; 24E2
        LD A,11H                ; 24E5
        PUSH AF                 ; 24E7
        OR A                    ; 24E8
        JP p24F6                ; 24E9

p24EC:  PUSH AF                 ; 24EC
        PUSH HL                 ; 24ED
        ADD HL,BC               ; 24EE
        JP NC,p24F5             ; 24EF
        POP AF                  ; 24F2
        SCF                     ; 24F3
        DB 03EH                 ; 24F4 (LD A,0E1H)
p24F5:  POP HL                  ; 24F5
p24F6:  LD A,E                  ; 24F6
        RLA                     ; 24F7
        LD E,A                  ; 24F8
        LD A,D                  ; 24F9
        RLA                     ; 24FA
        LD D,A                  ; 24FB
        LD A,L                  ; 24FC
        RLA                     ; 24FD
        LD L,A                  ; 24FE
        LD A,H                  ; 24FF
        RLA                     ; 2500
        LD H,A                  ; 2501
        POP AF                  ; 2502
        DEC A                   ; 2503
        JP NZ,p24EC             ; 2504
        LD A,H                  ; 2507
        OR A                    ; 2508
        RRA                     ; 2509
        LD H,A                  ; 250A
        LD A,L                  ; 250B
        RRA                     ; 250C
        LD L,A                  ; 250D
        RET                     ; 250E

p250F:  XOR A                   ; 250F
        LD C,A                  ; 2510
        SUB E                   ; 2511
        LD E,A                  ; 2512
        LD A,C                  ; 2513
        SBC A,D                 ; 2514
        LD D,A                  ; 2515
        RET                     ; 2516

p2517:  LD HL,(xw3ECA)          ; 2517
        PUSH BC                 ; 251A
        EX DE,HL                ; 251B
        LD A,D                  ; 251C
        OR E                    ; 251D
        JP Z,p2535              ; 251E
        LD A,H                  ; 2521
        OR L                    ; 2522
        JP Z,p2535              ; 2523
        LD A,H                  ; 2526
        XOR D                   ; 2527
        PUSH AF                 ; 2528
        PUSH DE                 ; 2529
        EX DE,HL                ; 252A
        CALL p24B3              ; 252B
        EX DE,HL                ; 252E
        POP HL                  ; 252F
        POP AF                  ; 2530
        CALL M,p250F            ; 2531
        EX DE,HL                ; 2534

p2535:  EX DE,HL                ; 2535
        POP BC                  ; 2536
        LD A,(xb3F57)           ; 2537
        OR C                    ; 253A
        LD C,A                  ; 253B
        AND 83H                 ; 253C
        LD A,0BH                ; 253E
        JP NZ,p25C2             ; 2540
        JP p25CC                ; 2543

p2546:  LD A,4FH                ; 2546
        LD DE,p21C5             ; 2548 spoofed return address
        PUSH DE                 ; 254B
        PUSH BC                 ; 254C
        LD B,A                  ; 254D
        JP p04E8                ; 254E

p2551:  CALL p2599              ; 2551
        CALL p0D8D              ; 2554
        SUB 01H                 ; 2557
        JP p256F                ; 2559

p255C:  CALL p2599              ; 255C
        CALL p0D8D              ; 255F
        SUB 01H                 ; 2562
        CCF                     ; 2564
        JP p256F                ; 2565

p2568:  CALL p2599              ; 2568
        EX DE,HL                ; 256B
        CALL p0D8D              ; 256C
p256F:  SBC A,A                 ; 256F
        LD D,A                  ; 2570
        LD E,A                  ; 2571
        LD C,20H                ; 2572
        RET                     ; 2574

p2575:  CALL p2599              ; 2575
        JP p2588                ; 2578

p257B:  CALL p2599              ; 257B
        CALL p0D8D              ; 257E
        JP p256F                ; 2581

p2584:  CALL p2599              ; 2584
        EX DE,HL                ; 2587
p2588:  LD A,E                  ; 2588
        SUB L                   ; 2589
        LD E,A                  ; 258A
        LD A,D                  ; 258B
        SBC A,H                 ; 258C
        JP C,p256F              ; 258D
        OR E                    ; 2590
        SCF                     ; 2591
        JP Z,p256F              ; 2592
        CCF                     ; 2595
        JP p256F                ; 2596

p2599:  LD A,(xb3F57)           ; 2599
        CP C                    ; 259C
        CALL NZ,p04D3           ; 259D
        CALL p264C              ; 25A0
        LD HL,(xw3ECA)          ; 25A3
        RET                     ; 25A6

p25A7:  LD HL,(xw3ECA)          ; 25A7
        LD E,H                  ; 25AA
        XOR A                   ; 25AB
        LD D,A                  ; 25AC
        LD A,(xb3F57)           ; 25AD
        LD C,A                  ; 25B0
        LD A,03H                ; 25B1
        JP p25C2                ; 25B3

p25B6:  LD HL,(xw3ECA)          ; 25B6
        LD E,L                  ; 25B9
        XOR A                   ; 25BA
        LD D,A                  ; 25BB
        LD A,(xb3F57)           ; 25BC
        LD C,A                  ; 25BF
        LD A,04H                ; 25C0
p25C2:  PUSH AF                 ; 25C2
        LD A,(xb3ED4)           ; 25C3
        OR 40H                  ; 25C6
        LD (xb3ED4),A           ; 25C8
        POP AF                  ; 25CB
p25CC:  PUSH HL                 ; 25CC
        PUSH AF                 ; 25CD
        LD HL,xf3ED5            ; 25CE buffer
        INC (HL)                ; 25D1
        LD A,(HL)               ; 25D2
        AND 3FH                 ; 25D3
        JP Z,p25E2              ; 25D5
        ADD A,L                 ; 25D8
        LD L,A                  ; 25D9
        JP NC,p25DE             ; 25DA
        INC H                   ; 25DD
p25DE:  POP AF                  ; 25DE
        LD (HL),A               ; 25DF
        POP HL                  ; 25E0
        RET                     ; 25E1

p25E2:  DEC (HL)                ; 25E2
        LD A,C                  ; 25E3
        AND 83H                 ; 25E4
        JP Z,p25F1              ; 25E6

        LD A,(xb3ED4)           ; 25E9
        OR 10H                  ; 25EC
        LD (xb3ED4),A           ; 25EE
p25F1:  POP AF                  ; 25F1
        POP HL                  ; 25F2
        RET                     ; 25F3

p25F4:  CALL p2484              ; 25F4
        LD A,L                  ; 25F7
        CALL p0F52              ; 25F8
        AND 07H                 ; 25FB
        ADD A,E                 ; 25FD
        LD E,A                  ; 25FE
        RET                     ; 25FF

p2600:  CALL p2484              ; 2600
        LD A,L                  ; 2603
        CALL p0F52              ; 2604
        AND 07H                 ; 2607
        RLA                     ; 2609
        RLA                     ; 260A
        RLA                     ; 260B
        ADD A,E                 ; 260C
        LD E,A                  ; 260D
        RET                     ; 260E

p260F:  CALL p2484              ; 260F
        LD A,L                  ; 2612
        CALL p0F40              ; 2613
        AND 06H                 ; 2616
        RLA                     ; 2618
        RLA                     ; 2619
        RLA                     ; 261A
        ADD A,E                 ; 261B
        LD E,A                  ; 261C
        RET                     ; 261D

p261E:  CALL p2484              ; 261E
        LD A,L                  ; 2621
        CALL p0F36              ; 2622
        AND 02H                 ; 2625
        RLA                     ; 2627
        RLA                     ; 2628
        RLA                     ; 2629
        ADD A,E                 ; 262A
        LD E,A                  ; 262B
        RET                     ; 262C

p262D:  CALL p2484              ; 262D
        LD A,L                  ; 2630
        CALL p0F52              ; 2631
        AND 07H                 ; 2634
        LD L,A                  ; 2636
        LD A,E                  ; 2637
        CALL p0F52              ; 2638
        AND 07H                 ; 263B
        RLA                     ; 263D
        RLA                     ; 263E
        RLA                     ; 263F
        ADD A,L                 ; 2640
        LD E,A                  ; 2641
        RET                     ; 2642

p2643:  CALL p2484              ; 2643
        LD A,L                  ; 2646
        AND 3FH                 ; 2647
        ADD A,E                 ; 2649
        LD E,A                  ; 264A
        RET                     ; 264B

p264C:  AND 03H                 ; 264C
        CP 03H                  ; 264E
        RET NZ                  ; 2650
        PUSH HL                 ; 2651
        PUSH DE                 ; 2652
        LD HL,(xw3DDE)          ; 2653
        EX DE,HL                ; 2656
        LD HL,(xw3DE0)          ; 2657
        CALL p0D8D              ; 265A
        CALL NZ,p04D3           ; 265D
        POP DE                  ; 2660
        POP HL                  ; 2661
        RET                     ; 2662

p2663:  LD A,(xb3F57)           ; 2663
        LD E,A                  ; 2666
        LD D,00H                ; 2667
        LD C,20H                ; 2669
        LD A,(xb3E11)           ; 266B
        CP 20H                  ; 266E
        RET Z                   ; 2670
        CP 4FH                  ; 2671
        JP NZ,p2678             ; 2673
        LD E,00H                ; 2676
p2678:  LD A,20H                ; 2678
        LD (xb3E11),A           ; 267A
        RET                     ; 267D

p267E:  CALL p2CD4              ; 267E
        CALL p2083              ; 2681
        EX DE,HL                ; 2684
        LD A,B                  ; 2685
        AND 20H                 ; 2686
        JP Z,p04DF              ; 2688
        XOR A                   ; 268B
        LD (xb3DE8),A           ; 268C
        LD A,B                  ; 268F
        AND 03H                 ; 2690
        LD B,A                  ; 2692
        JP Z,p26B1              ; 2693
        LD A,(xb3DD1)           ; 2696
        CP B                    ; 2699
        JP NZ,p04D3             ; 269A
        CP 03H                  ; 269D
        JP NZ,p26B1             ; 269F
        PUSH HL                 ; 26A2
        LD HL,(xw3DDA)          ; 26A3
        EX DE,HL                ; 26A6
        LD HL,(xw3DDE)          ; 26A7
        CALL p0D8D              ; 26AA
        JP NZ,p04D3             ; 26AD
        POP HL                  ; 26B0
p26B1:  LD A,(xb3DD1)           ; 26B1
        LD B,A                  ; 26B4
p26B5:  EX DE,HL                ; 26B5
        LD HL,(xw3DDA)          ; 26B6
        LD (xw3DDE),HL          ; 26B9
        LD A,(xb3CEC)           ; 26BC
        OR A                    ; 26BF
        CALL NZ,p1B83           ; 26C0
        EX DE,HL                ; 26C3
        LD (xw3DD2),HL          ; 26C4
        EX DE,HL                ; 26C7
        LD C,0BH                ; 26C8
        LD A,(xb3DE8)           ; 26CA
        OR A                    ; 26CD
        JP NZ,p26DF             ; 26CE
        LD A,(xb3CEC)           ; 26D1
        OR A                    ; 26D4
        CALL NZ,p1BA9           ; 26D5
        LD A,(xb3F5C)           ; 26D8
        OR A                    ; 26DB
        CALL Z,p2732            ; 26DC
p26DF:  LD A,(xb3F5C)           ; 26DF
        OR A                    ; 26E2
        RET Z                   ; 26E3
        XOR A                   ; 26E4
        LD (xb3F5C),A           ; 26E5
        CALL p0B55              ; 26E8
        JP Z,p04CD              ; 26EB
        RET                     ; 26EE

p26EF:  CALL p2732              ; 26EF
        CALL p1B31              ; 26F2
        LD A,00H                ; 26F5
        LD B,A                  ; 26F7
        LD (xb3DD1),A           ; 26F8
        INC A                   ; 26FB
        LD (xb3F5C),A           ; 26FC
        LD (xb3DE8),A           ; 26FF
        LD HL,(xw3DD4)          ; 2702
        JP p26B5                ; 2705

p2708:  CALL p2732              ; 2708
        CALL p1B31              ; 270B
        LD A,01H                ; 270E
        LD (xb3F5C),A           ; 2710
        LD B,A                  ; 2713
        LD (xb3DD1),A           ; 2714
        LD HL,(xw3DD6)          ; 2717
        JP p26B5                ; 271A

p271D:  CALL p2732              ; 271D
        CALL p1B31              ; 2720
        LD A,02H                ; 2723
        LD (xb3F5C),A           ; 2725
        LD B,A                  ; 2728
        LD (xb3DD1),A           ; 2729
        LD HL,(xw3DD8)          ; 272C
        JP p26B5                ; 272F

p2732:  LD A,(xb3F5C)           ; 2732
        OR A                    ; 2735
x2736:  CALL NZ,p2CD4           ; 2736
        LD A,(xb3DD1)           ; 2739
        LD BC,xw3DD4            ; 273C
        AND 03H                 ; 273F
        CP 03H                  ; 2741
        JP Z,p2760              ; 2743
        ADD A,A                 ; 2746
        LD L,A                  ; 2747
        LD H,00H                ; 2748
        ADD HL,BC               ; 274A
p274B:  PUSH HL                 ; 274B
        LD E,(HL)               ; 274C
        INC HL                  ; 274D
        LD D,(HL)               ; 274E
        LD HL,(xw3DD2)          ; 274F
        CALL p0D8D              ; 2752
        POP DE                  ; 2755
        RET C                   ; 2756
        EX DE,HL                ; 2757
        LD (HL),E               ; 2758
        INC HL                  ; 2759
        LD (HL),D               ; 275A
        XOR A                   ; 275B
        LD (xb3DE8),A           ; 275C
        RET                     ; 275F

p2760:  LD HL,(xw3DDA)          ; 2760
        INC HL                  ; 2763
        INC HL                  ; 2764
        JP p274B                ; 2765

p2768:  PUSH AF                 ; 2768
        LD A,(xb3CEC)           ; 2769
        OR A                    ; 276C
        JP Z,p2787              ; 276D
        LD A,(xb3DE8)           ; 2770
        OR A                    ; 2773
        JP Z,p2787              ; 2774
        PUSH BC                 ; 2777
        PUSH DE                 ; 2778
        PUSH HL                 ; 2779
        LD HL,(xw3DD4)          ; 277A
        EX DE,HL                ; 277D
        LD BC,000BH             ; 277E
        CALL p1BA9              ; 2781
        POP HL                  ; 2784
        POP DE                  ; 2785
        POP BC                  ; 2786
p2787:  XOR A                   ; 2787
        LD (xb3DE8),A           ; 2788
        POP AF                  ; 278B
        RET                     ; 278C

p278D:  CALL p1B31              ; 278D
        CALL p0BC8              ; 2790
        CALL p0B36              ; 2793
        CP 22H                  ; 2796
        JP Z,p27A0              ; 2798
        CP 27H                  ; 279B
        JP NZ,p281C             ; 279D
p27A0:  LD B,A                  ; 27A0
        CALL p0B29              ; 27A1
        CALL p0B29              ; 27A4
        LD HL,(xw3D46)          ; 27A7
        DEC HL                  ; 27AA
        DEC HL                  ; 27AB
        PUSH HL                 ; 27AC
        CP B                    ; 27AD
        LD C,00H                ; 27AE
        JP Z,p27C0              ; 27B0
p27B3:  INC C                   ; 27B3
        CALL p0B29              ; 27B4
        CP 0DH                  ; 27B7
        JP Z,p27C7              ; 27B9
        CP B                    ; 27BC
        JP NZ,p27B3             ; 27BD
p27C0:  CALL p0AEA              ; 27C0
        CP B                    ; 27C3
        JP Z,p27B3              ; 27C4
p27C7:  CALL p0B36              ; 27C7
        CALL p0BC8              ; 27CA
        CP 2CH                  ; 27CD
        JP Z,p27DD              ; 27CF
        CP 3BH                  ; 27D2
        JP Z,p27DD              ; 27D4
        CP B                    ; 27D7
        JP Z,p27DD              ; 27D8
        CP 0DH                  ; 27DB
p27DD:  POP HL                  ; 27DD
        LD (xw3D46),HL          ; 27DE
        JP NZ,p281C             ; 27E1
        LD A,C                  ; 27E4
        CP 02H                  ; 27E5
        JP C,p281C              ; 27E7
        CALL p0B23              ; 27EA
        LD B,A                  ; 27ED
        CALL p0B29              ; 27EE
        CALL p0B29              ; 27F1
        JP p27FF                ; 27F4

p27F7:  PUSH BC                 ; 27F7
        CALL p164C              ; 27F8
        POP BC                  ; 27FB
        CALL p0B29              ; 27FC
p27FF:  CP 0DH                  ; 27FF
        RET Z                   ; 2801
        CP B                    ; 2802
        JP NZ,p27F7             ; 2803
        CALL p0B23              ; 2806
        CP B                    ; 2809
        JP Z,p2816              ; 280A
        CALL p0AEA              ; 280D
        CP 2CH                  ; 2810
        JP Z,p278D              ; 2812
        RET                     ; 2815

p2816:  CALL p164C              ; 2816
        JP p278D                ; 2819

p281C:  CALL p0F5A              ; 281C
        PUSH AF                 ; 281F
        LD A,(xb3DE2)           ; 2820
        OR A                    ; 2823
        JP M,p18C7              ; 2824
        POP AF                  ; 2827
p2828:  CALL p16D9              ; 2828
        LD A,C                  ; 282B
        CP 2CH                  ; 282C
        JP Z,p278D              ; 282E
        RET                     ; 2831

p2832:  CALL p2083              ; 2832
        PUSH AF                 ; 2835
        LD A,B                  ; 2836
        AND 83H                 ; 2837
        CALL NZ,p04D3           ; 2839
        POP AF                  ; 283C
        RET                     ; 283D

p283E:  CALL p1B31              ; 283E
p2841:  CALL p0BC8              ; 2841
        CP 22H                  ; 2844
        JP Z,p284E              ; 2846
        CP 27H                  ; 2849
        CALL NZ,p049D           ; 284B
p284E:  LD C,A                  ; 284E
        XOR A                   ; 284F
p2850:  PUSH AF                 ; 2850
        CALL p0B29              ; 2851
        CP 0DH                  ; 2854
        JP Z,p18C7              ; 2856
        CP C                    ; 2859
        JP NZ,p2864             ; 285A
        CALL p0AEA              ; 285D
        CP C                    ; 2860
        JP NZ,p286F             ; 2861
p2864:  LD B,A                  ; 2864
        POP AF                  ; 2865
        PUSH BC                 ; 2866
        OR A                    ; 2867
        CALL NZ,p164C           ; 2868
        POP AF                  ; 286B
        JP p2850                ; 286C

p286F:  POP BC                  ; 286F
        PUSH AF                 ; 2870
        LD A,B                  ; 2871
        ADD A,A                 ; 2872
        LD A,B                  ; 2873
        JP Z,p287C              ; 2874
        OR 80H                  ; 2877
        CALL p164C              ; 2879
p287C:  POP AF                  ; 287C
        CP 2CH                  ; 287D
        JP Z,p2841              ; 287F
        RET                     ; 2882

p2883:  CALL p1B31              ; 2883
        CALL p28C4              ; 2886
        CALL p2768              ; 2889
        LD A,C                  ; 288C
        CP 2CH                  ; 288D
        JP NZ,p289B             ; 288F
        PUSH DE                 ; 2892
        CALL p0F5A              ; 2893
        LD B,E                  ; 2896
        POP DE                  ; 2897
        JP p28A4                ; 2898

p289B:  LD A,(xb4091)           ; 289B
        OR A                    ; 289E
        JP Z,p28B9              ; 289F
        LD B,00H                ; 28A2
p28A4:  LD A,D                  ; 28A4
        OR E                    ; 28A5
        RET Z                   ; 28A6
        DEC DE                  ; 28A7
        LD HL,(xw3DD2)          ; 28A8
        INC HL                  ; 28AB
        LD (xw3DD2),HL          ; 28AC
        LD A,(xb3CEC)           ; 28AF
        OR A                    ; 28B2
        CALL NZ,p1C27           ; 28B3
        JP p28A4                ; 28B6

p28B9:  LD HL,(xw3DD2)          ; 28B9
        ADD HL,DE               ; 28BC
        LD A,(xb3DD1)           ; 28BD
        LD B,A                  ; 28C0
        JP p26B5                ; 28C1

p28C4:  CALL p2832              ; 28C4
        LD A,(xb3CEC)           ; 28C7
        OR A                    ; 28CA
        RET NZ                  ; 28CB
        LD A,(xb3E11)           ; 28CC
        CP 55H                  ; 28CF
        RET NZ                  ; 28D1
        INC A                   ; 28D2
        LD (xb3E11),A           ; 28D3
        RET                     ; 28D6

p28D7:  CALL p1B31              ; 28D7
        CALL p2768              ; 28DA
        CALL p2083              ; 28DD
        CALL p17D5              ; 28E0
        LD A,C                  ; 28E3
        CP 2CH                  ; 28E4
        JP Z,p28D7              ; 28E6
        RET                     ; 28E9

p28EA:  LD A,(xb3CF3)           ; 28EA
        DEC A                   ; 28ED
        JP M,p2912              ; 28EE
        LD B,A                  ; 28F1
        LD (xb3CF3),A           ; 28F2
        LD A,(xb3CF4)           ; 28F5
        DEC A                   ; 28F8
        CP B                    ; 28F9
        JP NZ,p2900             ; 28FA
        LD (xb3CF4),A           ; 28FD
p2900:  LD A,(xb3CF4)           ; 2900
        SUB B                   ; 2903
        SBC A,A                 ; 2904
        INC A                   ; 2905
        LD (xb3D28),A           ; 2906
        CALL p293F              ; 2909
        LD (xb3CF5),A           ; 290C
        JP p0B40                ; 290F

p2912:  CALL p04A3              ; 2912
        RET                     ; 2915

p2916:  LD A,(xb3CF5)           ; 2916
        OR A                    ; 2919
        CALL NZ,p04A3           ; 291A
        LD A,(xb3CF3)           ; 291D
        OR A                    ; 2920
        CALL Z,p04A3            ; 2921
        LD HL,xb3CF4            ; 2924
        SUB (HL)                ; 2927
        JP Z,p293B              ; 2928
        DEC A                   ; 292B
        JP NZ,p0B40             ; 292C
        INC (HL)                ; 292F
        DEC A                   ; 2930
p2931:  LD (xb3D28),A           ; 2931
        INC A                   ; 2934
        LD (xb3CF5),A           ; 2935
        JP p0B40                ; 2938

p293B:  DEC (HL)                ; 293B
        JP p2931                ; 293C

p293F:  LD A,(xb3CF3)           ; 293F
        LD E,A                  ; 2942
        CP 32H                  ; 2943
        LD A,00H                ; 2945
        RET NC                  ; 2947
        LD D,A                  ; 2948
        LD HL,xf3CF6            ; 2949 start of buffer
        ADD HL,DE               ; 294C
        SCF                     ; 294D
        LD A,(HL)               ; 294E
        RET                     ; 294F

p2950:  PUSH AF                 ; 2950
        CALL p293F              ; 2951
        LD DE,xb3CF5            ; 2954
        JP NC,p295C             ; 2957
        LD A,(DE)               ; 295A
        LD (HL),A               ; 295B
p295C:  XOR A                   ; 295C
        LD (DE),A               ; 295D
        LD HL,xb3CF3            ; 295E
        INC (HL)                ; 2961
        LD A,(xb3D28)            ; 2962
        OR A                    ; 2965
        JP Z,p18C7              ; 2966
        POP AF                  ; 2969
        LD (xb3D28),A           ; 296A
        LD HL,xb3CF4            ; 296D
        OR A                    ; 2970
        JP Z,p2976              ; 2971
        INC (HL)                ; 2974
        RET                     ; 2975

p2976:  LD A,(xb3CF3)           ; 2976
        DEC A                   ; 2979
        SUB (HL)                ; 297A
        LD (xb3D29),A           ; 297B
        RET                     ; 297E

p297F:  CALL p29D1              ; 297F
        LD A,D                  ; 2982
        OR E                    ; 2983
        JP p2950                ; 2984

p2987:  CALL p29D1              ; 2987
        LD A,D                  ; 298A
        OR E                    ; 298B
        CPL                     ; 298C
        JP Z,p2950              ; 298D
        XOR A                   ; 2990
        JP p2950                ; 2991

p2994:  LD A,(xb3CEC)           ; 2994
        CALL p0B40              ; 2997
        DEC A                   ; 299A
        JP p2950                ; 299B

p299E:  LD A,(xb3CEC)           ; 299E
        CALL p0B40              ; 29A1
        OR A                    ; 29A4
        JP p2950                ; 29A5

p29A8:  DB 0F6H                 ; 29A8 (OR 37H)
p29A9:  SCF                     ; 29A9
        PUSH AF                 ; 29AA save carry flag
        LD A,(xb3D28)           ; 29AB
        OR A                    ; 29AE
        JP Z,p29D8              ; 29AF
        CALL p0B55              ; 29B2
        CALL p0C24              ; 29B5
        JP NZ,p29C0             ; 29B8
        AND 0A0H                 ; 29BB
        JP NZ,p29CB             ; 29BD
p29C0:  CALL p0C0E              ; 29C0
        JP Z,p29CB              ; 29C3
p29C6:  POP AF                  ; 29C6
        SBC A,A                 ; 29C7
        JP p2950                ; 29C8

p29CB:  POP AF                  ; 29CB
        CCF                     ; 29CC
        SBC A,A                 ; 29CD
        JP p2950                ; 29CE

p29D1:  LD A,(xb3D28)           ; 29D1
        OR A                    ; 29D4
        JP NZ,p28C4             ; 29D5
p29D8:  POP BC                  ; 29D8
        XOR A                   ; 29D9
        LD HL,xs0D8B            ; 29DA 0AH, 00H
        LD (xw3D46),HL          ; 29DD
        JP p2950                ; 29E0

p29E3:  DB 0F6H                 ; 29E3 (OR 37H)
p29E4:  SCF                     ; 29E4
        PUSH AF                 ; 29E5
        CALL p2A32              ; 29E6
        JP NZ,p29D8             ; 29E9
        LD (xw3D46),HL          ; 29EC
        LD A,B                  ; 29EF
        OR C                    ; 29F0
        JP Z,p29CB              ; 29F1
        JP p29C6                ; 29F4

p29F7:  DB 0F6H                 ; 29F7 (OR 37H)
p29F8:  SCF                     ; 29F8
        PUSH AF                 ; 29F9
        CALL p2A32              ; 29FA
        JP NZ,p29D8             ; 29FD
        PUSH DE                 ; 2A00
        PUSH BC                 ; 2A01
        LD A,(HL)               ; 2A02
        CP 2CH                  ; 2A03
        JP NZ,p2A2A             ; 2A05
        INC HL                  ; 2A08
        LD (xw3D46),HL          ; 2A09
        CALL p2A32              ; 2A0C
        JP NZ,p2A2D             ; 2A0F
        LD (xw3D46),HL          ; 2A12
        LD A,C                  ; 2A15
        POP BC                  ; 2A16
        POP HL                  ; 2A17
        CP C                    ; 2A18
        JP NZ,p29C6             ; 2A19
p2A1C:  LD A,(DE)               ; 2A1C
        CP (HL)                 ; 2A1D
        JP NZ,p29C6             ; 2A1E
x2A21:  INC DE                  ; 2A21
        INC HL                  ; 2A22
        DEC C                   ; 2A23
        JP NZ,p2A1C             ; 2A24
        JP p29CB                ; 2A27

p2A2A:  CALL p04C1              ; 2A2A
p2A2D:  POP HL                  ; 2A2D
        POP HL                  ; 2A2E
        JP p29D8                ; 2A2F

p2A32:  CALL p0BC8              ; 2A32
        CP 3CH                  ; 2A35
        CALL NZ,p049D           ; 2A37
p2A3A:  CALL p0B23              ; 2A3A
        OR A                    ; 2A3D
        JP NZ,p2A52             ; 2A3E
        CALL p0AEA              ; 2A41
        CALL p0B23              ; 2A44
        CP 26H                  ; 2A47
        JP NZ,p2A52             ; 2A49
        CALL p0AEA              ; 2A4C
        JP p2A3A                ; 2A4F

p2A52:  LD HL,(xw3D46)          ; 2A52
        DEC HL                  ; 2A55
        LD DE,0000H             ; 2A56
p2A59:  INC HL                  ; 2A59
        LD A,(HL)               ; 2A5A
        CP 3EH                  ; 2A5B
        JP NZ,p2A62             ; 2A5D
        LD D,H                  ; 2A60
        LD E,L                  ; 2A61
p2A62:  CP 2CH                  ; 2A62
        JP NZ,p2A6C             ; 2A64
        LD A,D                  ; 2A67
        OR E                    ; 2A68
        JP NZ,p2A72             ; 2A69
p2A6C:  CP 0DH                  ; 2A6C
        JP NZ,p2A59             ; 2A6E
        INC HL                  ; 2A71
p2A72:  PUSH HL                 ; 2A72
        LD HL,(xw3D46)          ; 2A73
        LD A,D                  ; 2A76
        OR E                    ; 2A77
        CALL Z,p049D            ; 2A78
        EX DE,HL                ; 2A7B
        LD A,L                  ; 2A7C
        SUB E                   ; 2A7D
        LD C,A                  ; 2A7E
        LD A,H                  ; 2A7F
        SBC A,D                 ; 2A80
        LD B,A                  ; 2A81
        POP HL                  ; 2A82
        LD A,(xb3E11)           ; 2A83
        CP 20H                  ; 2A86
        RET                     ; 2A88

p2A89:  CALL p0B55              ; 2A89
        LD C,A                  ; 2A8C
        PUSH BC                 ; 2A8D
        CALL NZ,p049D           ; 2A8E
        SCF                     ; 2A91
        CALL p0CFC              ; 2A92
        CALL p2D15              ; 2A95
        INC HL                  ; 2A98
        LD A,(HL)               ; 2A99
        OR 40H                  ; 2A9A
        LD (HL),A               ; 2A9C
        POP BC                  ; 2A9D
        AND 20H                 ; 2A9E
        CALL Z,p04D9            ; 2AA0
        LD A,(HL)               ; 2AA3
        AND 80H                 ; 2AA4
        CALL NZ,p04B5           ; 2AA6
        RRA                     ; 2AA9
        RRA                     ; 2AAA
        RRA                     ; 2AAB
        OR (HL)                 ; 2AAC
        LD (HL),A               ; 2AAD
        LD A,C                  ; 2AAE
        CP 2CH                  ; 2AAF
        JP Z,p2A89              ; 2AB1
        RET                     ; 2AB4

p2AB5:  LD DE,xf3E31            ; 2AB5 buffer start
        LD BC,4F00H             ; 2AB8
        JP p2AC5                ; 2ABB

p2ABE:  LD C,00H                ; 2ABE
p2AC0:  LD DE,xf3E81            ; 2AC0 buffer start
        LD B,3BH                ; 2AC3
p2AC5:  CALL p0BC8              ; 2AC5
        LD HL,(xw3D46)          ; 2AC8
        DEC HL                  ; 2ACB
p2ACC:  LD A,(HL)               ; 2ACC
        INC HL                  ; 2ACD
        CP 0DH                  ; 2ACE
        JP Z,p2AE2              ; 2AD0
        CP C                    ; 2AD3
        JP Z,p2AE2              ; 2AD4
        INC B                   ; 2AD7
        DEC B                   ; 2AD8
        JP Z,p2ACC              ; 2AD9
        LD (DE),A               ; 2ADC
        INC DE                  ; 2ADD
        DEC B                   ; 2ADE
        JP p2ACC                ; 2ADF

p2AE2:  XOR A                   ; 2AE2
        LD (DE),A               ; 2AE3
        INC HL                  ; 2AE4
        LD (xw3D46),HL          ; 2AE5
        RET                     ; 2AE8

p2AE9:  CALL p0BC8              ; 2AE9
        CP 28H                  ; 2AEC
        JP NZ,p049D             ; 2AEE
        CALL p0B29              ; 2AF1
        CP 27H                  ; 2AF4
        JP NZ,p049D             ; 2AF6
        LD C,A                  ; 2AF9
        CALL p2AC0              ; 2AFA
        CALL p0B36              ; 2AFD
        CALL p0B29              ; 2B00
        CP 29H                  ; 2B03
        CALL NZ,p049D           ; 2B05
        JP p0B40                ; 2B08

p2B0B:  LD A,01H                ; 2B0B
        LD (xb3D2F),A           ; 2B0D
        JP p2B59                ; 2B10

p2B13:  XOR A                   ; 2B13
        LD (xb3D2F),A           ; 2B14
        JP p2B59                ; 2B17

p2B1A:  XOR A                   ; 2B1A
        LD (xb3D2D),A           ; 2B1B
        JP p2B59                ; 2B1E

p2B21:  CALL p0B55              ; 2B21
        JP NZ,p2B47             ; 2B24
        INC C                   ; 2B27
        DEC C                   ; 2B28
        JP Z,p2B47              ; 2B29
p2B2C:  PUSH AF                 ; 2B2C
        CALL p0C0E              ; 2B2D
        CALL NZ,p0C24           ; 2B30
        JP NZ,p2B3A             ; 2B33
        LD A,(HL)               ; 2B36
        OR 40H                  ; 2B37
        LD (HL),A               ; 2B39
p2B3A:  POP AF                  ; 2B3A
        CP 2CH                  ; 2B3B
        RET NZ                  ; 2B3D
        CALL p0B55              ; 2B3E
        JP NZ,p04C1             ; 2B41
        JP p2B2C                ; 2B44

p2B47:  LD A,01H                ; 2B47
        LD (xb3D2D),A           ; 2B49
        RET                     ; 2B4C

p2B4D:  LD A,0FFH               ; 2B4D
        LD (xb3D2E),A           ; 2B4F
        JP p2B59                ; 2B52

p2B55:  XOR A                   ; 2B55
        LD (xb3D2E),A           ; 2B56
p2B59:  JP p0B40                ; 2B59

p2B5C:  LD A,01H                ; 2B5C
        LD (xb3D2E),A           ; 2B5E
        JP p2B59                ; 2B61

p2B64:  XOR A                   ; 2B64
        JP p2B7D                ; 2B65

p2B68:  LD A,0FFH               ; 2B68
        JP p2B7D                ; 2B6A

p2B6D:  LD A,(xb408D)           ; 2B6D
        CPL                     ; 2B70
        LD L,A                  ; 2B71
        LD A,(xb3CEC)           ; 2B72
        OR A                    ; 2B75
        JP Z,p2B59              ; 2B76
        LD A,L                  ; 2B79
        LD (xb408D),A           ; 2B7A
p2B7D:  LD (xb3D2A),A           ; 2B7D
        JP p2B59                ; 2B80

p2B83:  LD A,01H                ; 2B83
        LD (xb3CEA),A           ; 2B85
        JP p2B59                ; 2B88

p2B8B:  XOR A                   ; 2B8B
        LD (xb3CEA),A           ; 2B8C
        JP p2B59                ; 2B8F

p2B92:  LD A,0FFH               ; 2B92
        LD (xb3CF2),A           ; 2B94
        CALL p28C4              ; 2B97
        XOR A                   ; 2B9A
        LD (xb3CF2),A           ; 2B9B
        LD A,D                  ; 2B9E
        OR A                    ; 2B9F
        JP NZ,p049D             ; 2BA0
        LD A,(xb3E11)           ; 2BA3
        CP 20H                  ; 2BA6
        RET NZ                  ; 2BA8
        LD A,E                  ; 2BA9
        DEC A                   ; 2BAA
        RET M                   ; 2BAB
        JP Z,p049D              ; 2BAC
        CP 10H                  ; 2BAF
        JP NC,p049D             ; 2BB1
        INC A                   ; 2BB4
        LD (xb3CF1),A           ; 2BB5
        XOR A                   ; 2BB8
        LD H,A                  ; 2BB9
        LD L,E                  ; 2BBA
        JP p1B34                ; 2BBB

p2BBE:  CALL p28C4              ; 2BBE
        LD A,D                  ; 2BC1
        OR A                    ; 2BC2
        JP NZ,p049D             ; 2BC3
        LD A,(xb3CEC)           ; 2BC6
        OR A                    ; 2BC9
        RET Z                   ; 2BCA
        LD A,E                  ; 2BCB
        OR A                    ; 2BCC
        JP Z,p2BE1              ; 2BCD
        CP 0AH                  ; 2BD0
        CALL C,p049D            ; 2BD2
        LD A,(xb3E11)           ; 2BD5
        CP 20H                  ; 2BD8
        JP NZ,p2BE1             ; 2BDA
        LD A,E                  ; 2BDD
        LD (xb3D32),A           ; 2BDE
p2BE1:  CALL p192B              ; 2BE1
        CALL p043F              ; 2BE4
        JP p1A70                ; 2BE7

p2BEA:  CALL p0B55              ; 2BEA
        JP NZ,p049D             ; 2BED
        PUSH AF                 ; 2BF0
        LD A,(xb3DE9)           ; 2BF1
        CP 08H                  ; 2BF4
        JP C,p2BFE              ; 2BF6
        CALL p04CD              ; 2BF9
        LD A,07H                ; 2BFC
p2BFE:  LD HL,xb3DE3            ; 2BFE
        LD (HL),A               ; 2C01
        INC HL                  ; 2C02
        LD (xw3D3F),HL          ; 2C03
        LD A,(xb3CEC)           ; 2C06
        OR A                    ; 2C09
        LD C,03H                ; 2C0A
        CALL NZ,p1BA9           ; 2C0C
        POP AF                  ; 2C0F
        CP 2CH                  ; 2C10
        JP Z,p2BEA              ; 2C12
        RET                     ; 2C15

p2C16:  LD A,(xb3D2C)           ; 2C16
        OR A                    ; 2C19
        JP NZ,p04C1             ; 2C1A
        CALL p0BC8              ; 2C1D
        LD HL,(xw3D46)          ; 2C20
        DEC HL                  ; 2C23
        CALL p4E71              ; 2C24
        OR A                    ; 2C27
        JP Z,p2C31              ; 2C28
        CALL p4F34              ; 2C2B
        JP p04DF                ; 2C2E

p2C31:  DEC A                   ; 2C31
        LD (xb3D2C),A           ; 2C32
p2C35:  LD HL,(xw3D46)          ; 2C35
        LD A,(HL)               ; 2C38
        INC HL                  ; 2C39
        LD (xw3D46),HL          ; 2C3A
        CP 21H                  ; 2C3D
        JP NC,p2C35             ; 2C3F
        RET                     ; 2C42

p2C43:  CALL p0BC8              ; 2C43
        CP 28H                  ; 2C46
        JP NZ,p049D             ; 2C48
        CALL p0B29              ; 2C4B
        CP 27H                  ; 2C4E
        JP NZ,p049D             ; 2C50
        CALL p0B55              ; 2C53
        JP NZ,p049D             ; 2C56
        CP 27H                  ; 2C59
        JP NZ,p049D             ; 2C5B
        CALL p0B29              ; 2C5E
        CP 29H                  ; 2C61
        JP NZ,p049D             ; 2C63
        CALL p0B40              ; 2C66
        LD A,(xb3CEC)           ; 2C69
        OR A                    ; 2C6C
        RET NZ                  ; 2C6D
        LD A,(xb3DE9)           ; 2C6E
        CP 06H                  ; 2C71
        JP C,p2C78              ; 2C73
        LD A,06H                ; 2C76
p2C78:  LD DE,xb3DEA            ; 2C78
        LD HL,xf3F5D            ; 2C7B
        LD B,A                  ; 2C7E
        LD A,(HL)               ; 2C7F
        OR A                    ; 2C80
        JP NZ,p04B5             ; 2C81
p2C84:  LD A,(DE)               ; 2C84
        LD (HL),A               ; 2C85
        INC HL                  ; 2C86
        INC DE                  ; 2C87
        DEC B                   ; 2C88
        JP NZ,p2C84             ; 2C89
        LD (HL),B               ; 2C8C
        RET                     ; 2C8D

p2C8E:  CALL p2CD4              ; 2C8E
        CALL p0BC8              ; 2C91
        CP 2FH                  ; 2C94
        JP NZ,p049D             ; 2C96
        CALL p0B55              ; 2C99
        CALL NZ,p2CCC           ; 2C9C
        CP 2FH                  ; 2C9F
        JP NZ,p049D             ; 2CA1
        CALL p0B40              ; 2CA4
        CALL p0CFC              ; 2CA7
        INC HL                  ; 2CAA
        LD A,(HL)               ; 2CAB
        AND 0D0H                ; 2CAC
        JP NZ,p04B5             ; 2CAE
        PUSH HL                 ; 2CB1
        LD A,(HL)               ; 2CB2
        OR 24H                  ; 2CB3
        LD (HL),A               ; 2CB5
        CALL p2732              ; 2CB6
        POP HL                  ; 2CB9
        DEC HL                  ; 2CBA
        LD (xw3DDA),HL          ; 2CBB
        LD A,03H                ; 2CBE
        LD (xb3DD1),A           ; 2CC0
        LD HL,0000H             ; 2CC3
        LD (xw3DD2),HL          ; 2CC6
        JP p26B1                ; 2CC9

p2CCC:  PUSH AF                 ; 2CCC
        LD A,01H                ; 2CCD
        LD (xb3DE9),A           ; 2CCF
        POP AF                  ; 2CD2
        RET                     ; 2CD3

p2CD4:  LD A,(xb3DE4)           ; 2CD4
        OR A                    ; 2CD7
        RET Z                   ; 2CD8
        POP BC                  ; 2CD9
        JP p04C7                ; 2CDA

p2CDD:  LD DE,0080H             ; 2CDD
p2CE0:  CALL p0B55              ; 2CE0
        JP NZ,p2D06             ; 2CE3
        PUSH AF                 ; 2CE6
        OR A                    ; 2CE7
        PUSH DE                 ; 2CE8
        CALL p0CFC              ; 2CE9
        CALL p2D15              ; 2CEC
        POP DE                  ; 2CEF
        LD A,(HL)               ; 2CF0
        OR D                    ; 2CF1
        LD (HL),A               ; 2CF2
        INC HL                  ; 2CF3
        LD A,(HL)               ; 2CF4
        AND 64H                 ; 2CF5
        JP NZ,p2D0C             ; 2CF7
        LD A,(HL)               ; 2CFA
        AND 03H                 ; 2CFB
        OR E                    ; 2CFD
        LD (HL),A               ; 2CFE
p2CFF:  POP AF                  ; 2CFF
p2D00:  CP 2CH                  ; 2D00
        JP Z,p2CE0              ; 2D02
        RET                     ; 2D05

p2D06:  CALL p049D              ; 2D06
        JP p2D00                ; 2D09

p2D0C:  OR 10H                  ; 2D0C
        LD (HL),A               ; 2D0E
        CALL p04B5              ; 2D0F
        JP p2CFF                ; 2D12

p2D15:  LD A,(HL)               ; 2D15
        AND 7FH                 ; 2D16
        CP 42H                  ; 2D18
        RET C                   ; 2D1A
        XOR A                   ; 2D1B
        LD (HL),A               ; 2D1C
        PUSH HL                 ; 2D1D
        XOR A                   ; 2D1E
        INC HL                  ; 2D1F
        LD (HL),A               ; 2D20
        INC HL                  ; 2D21
        LD (HL),A               ; 2D22
        INC HL                  ; 2D23
        LD (HL),A               ; 2D24
        POP HL                  ; 2D25
        RET                     ; 2D26

p2D27:  CALL p0B55              ; 2D27
        CALL p0515              ; 2D2A
        LD A,(HL)               ; 2D2D
        ADD A,A                 ; 2D2E
        CALL NC,p04C1           ; 2D2F
        INC HL                  ; 2D32
        LD A,(HL)               ; 2D33
        CP 10H                  ; 2D34
        JP Z,p2D3E              ; 2D36
        CP 0FH                  ; 2D39
        CALL NZ,p04C1           ; 2D3B
p2D3E:  LD DE,0480H             ; 2D3E
        JP p2CE0                ; 2D41

p2D44:  LD (xw3D43),HL          ; 2D44
        CALL p2D6D              ; 2D47
        LD A,(xb3E11)           ; 2D4A
        LD (xb3D31),A           ; 2D4D
        CP 55H                  ; 2D50
        RET Z                   ; 2D52
        LD A,B                  ; 2D53
        AND 80H                 ; 2D54
        JP NZ,p04AF             ; 2D56
        LD A,B                  ; 2D59
        OR 20H                  ; 2D5A
        LD (xb3D30),A           ; 2D5C
        LD HL,(xw3D43)          ; 2D5F
        LD (xw3D3F),HL          ; 2D62
        CALL p0DDB              ; 2D65
        EX DE,HL                ; 2D68
        LD A,B                  ; 2D69
        JP p1B34                ; 2D6A

p2D6D:  CALL p2083              ; 2D6D
        LD A,(xb3EC2)           ; 2D70
        OR A                    ; 2D73
        RET Z                   ; 2D74
        JP p04CD                ; 2D75

p2D78:  LD (xw3D43),HL          ; 2D78
        LD A,(HL)               ; 2D7B
        OR 80H                  ; 2D7C
        LD (HL),A               ; 2D7E
        LD A,H                  ; 2D7F
        LD (xb3D31),A           ; 2D80
        CALL p2D6D              ; 2D83
        LD A,B                  ; 2D86
        AND 80H                 ; 2D87
        JP NZ,p04AF             ; 2D89
        LD HL,(xw3D43)          ; 2D8C
        CALL p2D15              ; 2D8F
        INC HL                  ; 2D92
        LD A,(HL)               ; 2D93
        AND 94H                 ; 2D94
        JP NZ,p04B5             ; 2D96
        LD A,(HL)               ; 2D99
        AND 40H                 ; 2D9A
        OR B                    ; 2D9C
        OR 20H                  ; 2D9D
        LD (HL),A               ; 2D9F
        INC HL                  ; 2DA0
        LD (HL),E               ; 2DA1
        INC HL                  ; 2DA2
        LD (HL),D               ; 2DA3
        INC HL                  ; 2DA4
        PUSH DE                 ; 2DA5
        EX DE,HL                ; 2DA6
        LD HL,(xw3DDE)          ; 2DA7
        EX DE,HL                ; 2DAA
        LD (HL),E               ; 2DAB
        INC HL                  ; 2DAC
        LD (HL),D               ; 2DAD
        POP HL                  ; 2DAE
        JP p1B34                ; 2DAF

p2DB2:  PUSH AF                 ; 2DB2
        CALL p4BB8              ; 2DB3
        LD A,(xb3FFA)           ; 2DB6
        OR A                    ; 2DB9
        CALL NZ,p2F77           ; 2DBA
        LD A,(xb3CF3)           ; 2DBD
        OR A                    ; 2DC0
        CALL NZ,p2FA8           ; 2DC1
        POP AF                  ; 2DC4
        LD HL,xb3CEC            ; 2DC5 address
        INC (HL)                ; 2DC8
        LD A,(HL)               ; 2DC9
        DEC A                   ; 2DCA
        JP NZ,p2E5A             ; 2DCB
        LD HL,xf3F5D            ; 2DCE address
        LD A,(HL)               ; 2DD1
        OR A                    ; 2DD2
        JP NZ,p2DE2             ; 2DD3
        LD HL,xf3E31            ; 2DD6 buffer start
        LD A,(HL)               ; 2DD9
        OR A                    ; 2DDA
        JP NZ,p2DE2             ; 2DDB
        LD HL,xf40D5            ; 2DDE FCB address
        INC HL                  ; 2DE1
p2DE2:  LD BC,0006H             ; 2DE2
        LD DE,xf3F5D            ; 2DE5 address
p2DE8:  LD A,(HL)               ; 2DE8
        INC HL                  ; 2DE9
        CP 20H                  ; 2DEA
        JP Z,p2E04              ; 2DEC
        CP 09H                  ; 2DEF
        JP Z,p2E04              ; 2DF1
        OR A                    ; 2DF4
        JP Z,p2E04              ; 2DF5
        CP 0DH                  ; 2DF8
        JP Z,p2E04              ; 2DFA
        LD (DE),A               ; 2DFD
        INC DE                  ; 2DFE
        INC B                   ; 2DFF
        DEC C                   ; 2E00
        JP NZ,p2DE8             ; 2E01
p2E04:  LD HL,xb3F56            ; 2E04
        LD (HL),B               ; 2E07
        INC HL                  ; 2E08
        LD (xw3D3F),HL          ; 2E09
        LD C,02H                ; 2E0C
        CALL p1BA9              ; 2E0E
        CALL p2732              ; 2E11
        LD HL,x4F35             ; 2E14
        LD (xw401B),HL          ; 2E17
p2E1A:  CALL p0CC4              ; 2E1A
        JP C,p2E41              ; 2E1D
        LD (xw3D3F),HL          ; 2E20
        LD A,(HL)               ; 2E23
        AND 7FH                 ; 2E24
        LD (HL),A               ; 2E26
        INC HL                  ; 2E27
        LD A,(HL)               ; 2E28
        AND 40H                 ; 2E29
        JP NZ,p2F6B             ; 2E2B
        LD A,(HL)               ; 2E2E
        AND 04H                 ; 2E2F
        JP Z,p2E1A              ; 2E31
        INC HL                  ; 2E34
        LD E,(HL)               ; 2E35
        INC HL                  ; 2E36
        LD D,(HL)               ; 2E37
        LD BC,0005H             ; 2E38
        CALL p1BA9              ; 2E3B
        JP p2E1A                ; 2E3E

p2E41:  LD HL,(xw3DD8)          ; 2E41
        EX DE,HL                ; 2E44
        LD BC,000AH             ; 2E45
        CALL p1BA9              ; 2E48
        LD BC,010DH             ; 2E4B
        LD HL,(xw3DD6)          ; 2E4E
        EX DE,HL                ; 2E51
        LD A,E                  ; 2E52
        OR D                    ; 2E53
        CALL NZ,p1BA9           ; 2E54
        JP p016E                ; 2E57

p2E5A:  LD HL,(xw3D46)          ; 2E5A
        PUSH AF                 ; 2E5D
        CALL NC,p2083           ; 2E5E
        PUSH DE                 ; 2E61
        PUSH BC                 ; 2E62
        CALL p192B              ; 2E63
        LD HL,0FFFFH            ; 2E66
        LD (xw3D34),HL          ; 2E69
        LD (xw3D36),HL          ; 2E6C
        LD A,L                  ; 2E6F
        LD (xb3D2F),A           ; 2E70
        CALL p1A70              ; 2E73
        LD HL,x2FF4             ; 2E76 Macros message
        CALL p1AD5              ; 2E79
        LD HL,xb3D33            ; 2E7C
        INC (HL)                ; 2E7F
        INC (HL)                ; 2E80
        LD HL,xf3F72            ; 2E81 start of buffer
        LD A,05H                ; 2E84
        CALL p3B97              ; 2E86
        CALL p1A5A              ; 2E89
        LD A,(xb3D33)           ; 2E8C
        CP 38H                  ; 2E8F
        CALL NC,p1A70           ; 2E91
        LD HL,xb3D33            ; 2E94
        INC (HL)                ; 2E97
        INC (HL)                ; 2E98
        LD HL,x2FE9             ; 2E99 Symbols message
        CALL p1AD5              ; 2E9C
        LD HL,xf3FB4            ; 2E9F start of buffer
        LD A,03H                ; 2EA2
        CALL p3B97              ; 2EA4
        CALL p1A5A              ; 2EA7
        CALL p2FB4              ; 2EAA
        LD HL,(xw3CED)          ; 2EAD
        LD A,H                  ; 2EB0
        OR L                    ; 2EB1
        JP Z,p2ECB              ; 2EB2
        PUSH HL                 ; 2EB5
        CALL p1ADF              ; 2EB6
        POP HL                  ; 2EB9
        LD A,(xf40B4)           ; 2EBA
        INC A                   ; 2EBD
        LD (xb3F5B),A           ; 2EBE
        CALL NZ,p1ADF           ; 2EC1
        XOR A                   ; 2EC4
        LD (xb3F5B),A           ; 2EC5
        JP p2ED1                ; 2EC8

p2ECB:  LD HL,x2F4C             ; 2ECB 'No' message
        CALL p2FD0              ; 2ECE
p2ED1:  LD HL,x2F4F             ; 2ED1 'Fatal errors' message
        CALL p2FD0              ; 2ED4
        LD HL,(xw3CEF)          ; 2ED7
        LD A,H                  ; 2EDA
        OR L                    ; 2EDB
        JP Z,p2F06              ; 2EDC
        LD A,2CH                ; 2EDF
        CALL p4C76              ; 2EE1
        LD A,(xf40B4)           ; 2EE4
        INC A                   ; 2EE7
        LD A,2CH                ; 2EE8
        CALL NZ,p4AEE           ; 2EEA
        PUSH HL                 ; 2EED
        CALL p1ADF              ; 2EEE
        POP HL                  ; 2EF1
        LD A,(xf40B4)           ; 2EF2
        INC A                   ; 2EF5
        LD (xb3F5B),A           ; 2EF6
        CALL NZ,p1ADF           ; 2EF9
        XOR A                   ; 2EFC
        LD (xb3F5B),A           ; 2EFD
        LD HL,x2F5F             ; 2F00 'Warnings' message
        CALL p2FD0              ; 2F03
p2F06:  CALL p2FB4              ; 2F06
        POP BC                  ; 2F09
        POP DE                  ; 2F0A
        POP AF                  ; 2F0B
        JP NC,p2F14             ; 2F0C
        LD B,00H                ; 2F0F
        LD DE,0000H             ; 2F11
p2F14:  CALL p1B83              ; 2F14
        LD C,0EH                ; 2F17
        CALL p1BA9              ; 2F19
p2F1C:  LD HL,(xb3EC3)          ; 2F1C
        LD A,H                  ; 2F1F
        CP 0F8H                 ; 2F20
        JP Z,p2F2C              ; 2F22
        XOR A                   ; 2F25
        CALL p1C46              ; 2F26
        JP p2F1C                ; 2F29

p2F2C:  LD BC,000FH             ; 2F2C
        CALL p1BA9              ; 2F2F
        LD B,00H                ; 2F32
        CALL p1C2B              ; 2F34
        LD A,(xb408C)           ; 2F37
        OR A                    ; 2F3A
        JP Z,p2F43              ; 2F3B
        LD A,80H                ; 2F3E
        CALL p4C76              ; 2F40
p2F43:  CALL p4BDB              ; 2F43
        CALL p4C1B              ; 2F46
        JP p0100                ; 2F49
;=====================================
x2F4C:  DB "No",0
x2F4F:  DB " Fatal error(s)",0
x2F5F:  DB " Warning(s)",0
;=====================================
p2F6B:  LD C,00H                ; 2F6B
        LD A,(xb3DD1)           ; 2F6D
        LD B,A                  ; 2F70
        CALL p1BA9              ; 2F71
        JP p2E1A                ; 2F74

p2F77:  CALL p2FCD              ; 2F77
        LD HL,x2F86             ; 2F7A
        CALL p2FD0              ; 2F7D
        CALL p1B29              ; 2F80
        JP p2FB4                ; 2F83
;=====================================
x2F86:  DB "REPT/IRP/IRPC/MACRO",0
x2F9A:  DB "Unterminated ",0
;=====================================
p2FA8:  CALL p2FCD              ; 2FA8
        LD HL,x2FDD             ; 2FAB 'Conditional' message
        CALL p2FD0              ; 2FAE
        CALL p1B29              ; 2FB1
p2FB4:  LD A,0DH                ; 2FB4 CR
        CALL p1A5A              ; 2FB6
        LD A,0AH                ; 2FB9 LF
        CALL p1A5A              ; 2FBB
        LD A,(xf40B4)           ; 2FBE
        INC A                   ; 2FC1
        RET Z                   ; 2FC2
        LD A,0DH                ; 2FC3 CR
        CALL p4AEE              ; 2FC5
        LD A,0AH                ; 2FC8 LF
        JP p4AEE                ; 2FCA

p2FCD:  LD HL,x2F9A             ; 2FCD 'Unterminated' message
p2FD0:  PUSH HL                 ; 2FD0
        CALL p1AD5              ; 2FD1
        POP HL                  ; 2FD4
        LD A,(xf40B4)           ; 2FD5
        INC A                   ; 2FD8
        RET Z                   ; 2FD9
        JP p46CC                ; 2FDA

x2FDD:  DB "Conditional",0
x2FE9:  DB "Symbols:",0DH,0AH,00H
x2FF4:  DB "Macros:",0DH,0AH,00H

p2FFE:  LD HL,0FFE2H            ; 2FFE
        ADD HL,SP               ; 3001
        EX DE,HL                ; 3002
        LD HL,(xw4029)          ; 3003
        CALL p0D8D              ; 3006
        JP NC,p3414             ; 3009
        LD A,(xb3FFA)           ; 300C
        OR A                    ; 300F
        LD HL,0000H             ; 3010
        LD (xw4023),HL          ; 3013
        LD (xw4025),HL          ; 3016
        LD HL,(xw3FF8)          ; 3019
        JP NZ,p3023             ; 301C
        LD HL,(xw4029)          ; 301F
        DEC HL                  ; 3022
p3023:  INC A                   ; 3023
        LD (xb3FFA),A           ; 3024
        XOR A                   ; 3027
        LD (xb3FFB),A           ; 3028
        LD (xb4005),A           ; 302B
p302E:  EX DE,HL                ; 302E
        LD HL,(xw401F)          ; 302F
        INC H                   ; 3032
        CALL p0D8D              ; 3033
        JP NC,p303E             ; 3036
        EX DE,HL                ; 3039
        LD (xw3FF8),HL          ; 303A
        RET                     ; 303D

p303E:  DEC H                   ; 303E
        EX DE,HL                ; 303F
        PUSH HL                 ; 3040
        CALL p3B4F              ; 3041
        POP HL                  ; 3044
        JP p302E                ; 3045

p3048:  CALL p0515              ; 3048
        RET NZ                  ; 304B
        LD A,(HL)               ; 304C
        OR A                    ; 304D
        INC A                   ; 304E
        RET P                   ; 304F
        DEC A                   ; 3050
        PUSH AF                 ; 3051
        AND 10H                 ; 3052
        JP Z,p3072              ; 3054
        LD A,(xb4005)           ; 3057
        INC A                   ; 305A
        LD (xb4005),A           ; 305B
p305E:  POP AF                  ; 305E
        AND 08H                 ; 305F
        XOR 08H                 ; 3061
        RET NZ                  ; 3063
        LD A,(xb4005)           ; 3064
        OR A                    ; 3067
        RET Z                   ; 3068
        LD A,(xb4005)           ; 3069
        DEC A                   ; 306C
        LD (xb4005),A           ; 306D
        INC A                   ; 3070
        RET                     ; 3071

p3072:  INC HL                  ; 3072
        LD A,(HL)               ; 3073
        CP 1BH                  ; 3074
        JP NZ,p305E             ; 3076
        LD A,(xb4005)           ; 3079
        OR A                    ; 307C
        JP NZ,p305E             ; 307D
        LD A,(xb400F)           ; 3080
        OR A                    ; 3083
        JP NZ,p305E             ; 3084
        POP AF                  ; 3087
        SCF                     ; 3088
        RET                     ; 3089

p308A:  LD (xw3FF8),HL          ; 308A
        LD A,(xb3FFA)           ; 308D
        DEC A                   ; 3090
        LD (xb3FFA),A           ; 3091
        RET                     ; 3094

p3095:  CALL p0AEA              ; 3095
        CP 26H                  ; 3098
        JP NZ,p30D1             ; 309A
        LD HL,(xw3D46)          ; 309D
        LD A,(HL)               ; 30A0
        CP 20H                  ; 30A1
        JP Z,p30CF              ; 30A3
        CP 09H                  ; 30A6
        JP Z,p30CF              ; 30A8
        PUSH HL                 ; 30AB
        PUSH BC                 ; 30AC
        CALL p0B55              ; 30AD
        CALL p30DD              ; 30B0
        POP BC                  ; 30B3
        POP HL                  ; 30B4
        LD (xw3D46),HL          ; 30B5
        JP NZ,p30CF             ; 30B8
        LD A,26H                ; 30BB
        LD (xb3FFC),A           ; 30BD
        JP p313E                ; 30C0

p30C3:  CP 26H                  ; 30C3
        JP NZ,p30D1             ; 30C5
        LD A,(xb3FFC)           ; 30C8
        OR A                    ; 30CB
        JP NZ,p30D6             ; 30CC
p30CF:  LD A,26H                ; 30CF
p30D1:  CALL p3A3B              ; 30D1
        OR A                    ; 30D4
        RET M                   ; 30D5
p30D6:  PUSH AF                 ; 30D6
        XOR A                   ; 30D7
        LD (xb3FFC),A           ; 30D8
        POP AF                  ; 30DB
        RET                     ; 30DC

p30DD:  LD HL,(xw4007)          ; 30DD
        LD B,00H                ; 30E0
p30E2:  LD A,(HL)               ; 30E2
        OR A                    ; 30E3
        JP Z,p310B              ; 30E4
        LD DE,xb3DE9            ; 30E7 address
        LD A,(DE)               ; 30EA
        CP (HL)                 ; 30EB
        JP NZ,p3100             ; 30EC
        LD C,A                  ; 30EF
p30F0:  DEC HL                  ; 30F0
        INC DE                  ; 30F1
        LD A,(DE)               ; 30F2
        CP (HL)                 ; 30F3
        JP NZ,p3100             ; 30F4
        DEC C                   ; 30F7
        JP NZ,p30F0             ; 30F8
        LD A,B                  ; 30FB
        OR 80H                  ; 30FC
        CP A                    ; 30FE
        RET                     ; 30FF

p3100:  DEC HL                  ; 3100
        LD A,(HL)               ; 3101
        CP 07H                  ; 3102
        JP NC,p3100             ; 3104
        INC B                   ; 3107
        JP p30E2                ; 3108

p310B:  LD A,(xb4010)           ; 310B
        OR A                    ; 310E
        RET NZ                  ; 310F
        LD HL,(xw4011)          ; 3110
        LD B,0C0H               ; 3113
p3115:  LD A,(HL)               ; 3115
        OR A                    ; 3116
        JP Z,p313C              ; 3117
        LD DE,xb3DE9            ; 311A address
        LD A,(DE)               ; 311D
        CP (HL)                 ; 311E
        JP NZ,p3131             ; 311F
        LD C,A                  ; 3122
p3123:  DEC HL                  ; 3123
        INC DE                  ; 3124
        LD A,(DE)               ; 3125
        CP (HL)                 ; 3126
        JP NZ,p3131             ; 3127
        DEC C                   ; 312A
        JP NZ,p3123             ; 312B
        XOR A                   ; 312E
        LD A,B                  ; 312F
        RET                     ; 3130

p3131:  DEC HL                  ; 3131
        LD A,(HL)               ; 3132
        CP 07H                  ; 3133
        JP NC,p3131             ; 3135
        INC B                   ; 3138
        JP p3115                ; 3139

p313C:  INC A                   ; 313C
        RET                     ; 313D

p313E:  LD HL,(xw3D46)          ; 313E
        PUSH HL                 ; 3141
        CALL p0B55              ; 3142
        PUSH AF                 ; 3145
        CALL p30DD              ; 3146
        JP NZ,p3177             ; 3149
        LD B,A                  ; 314C
        POP AF                  ; 314D
        POP HL                  ; 314E
        PUSH AF                 ; 314F
p3150:  LD A,(HL)               ; 3150
        INC HL                  ; 3151
        CP 20H                  ; 3152
        JP Z,p315C              ; 3154
        CP 09H                  ; 3157
        JP NZ,p3164             ; 3159
p315C:  PUSH HL                 ; 315C
        CALL p30D1              ; 315D
        POP HL                  ; 3160
        JP p3150                ; 3161

p3164:  LD A,B                  ; 3164
        CALL p30D1              ; 3165
        POP AF                  ; 3168
        LD B,A                  ; 3169
        PUSH AF                 ; 316A
p316B:  POP AF                  ; 316B
        JP NZ,p30C3             ; 316C
        CP 26H                  ; 316F
        JP NZ,p30C3             ; 3171
        JP p0B36                ; 3174

p3177:  POP AF                  ; 3177
        POP HL                  ; 3178
        PUSH AF                 ; 3179
        LD (xw3D46),HL          ; 317A
p317D:  CALL p0AEA              ; 317D
        CP 20H                  ; 3180
        JP Z,p3190              ; 3182
        CP 09H                  ; 3185
        JP Z,p3190              ; 3187
        CALL p0B36              ; 318A
        JP p3196                ; 318D

p3190:  CALL p30D1              ; 3190
        JP p317D                ; 3193

p3196:  CALL p0BB1              ; 3196
        JP NZ,p316B             ; 3199
        JP p31A5                ; 319C

p319F:  CALL p0BB1              ; 319F
        JP M,p316B              ; 31A2
p31A5:  CALL p30D1              ; 31A5
        JP p319F                ; 31A8

p31AB:  CALL p0AEA              ; 31AB
        CP 3BH                  ; 31AE
        JP Z,p31C7              ; 31B0
        JP p31B9                ; 31B3

p31B6:  CALL p3AC6              ; 31B6
p31B9:  CALL p30D1              ; 31B9
        CP 0DH                  ; 31BC
        JP Z,p3A9E              ; 31BE
        CALL p0AEA              ; 31C1
        JP p31B9                ; 31C4

p31C7:  CALL p3AC6              ; 31C7
p31CA:  CALL p3AC6              ; 31CA
        CP 20H                  ; 31CD
        JP Z,p31CA              ; 31CF
        CP 09H                  ; 31D2
        JP Z,p31CA              ; 31D4
        OR A                    ; 31D7
        CALL p3AED              ; 31D8
        LD (xw4025),HL          ; 31DB
        JP Z,p3A9E              ; 31DE
        CP 0DH                  ; 31E1
        JP Z,p3A9E              ; 31E3
        LD A,0DH                ; 31E6
        CALL p3A3B              ; 31E8
        JP p3A9E                ; 31EB

p31EE:  PUSH HL                 ; 31EE
        PUSH AF                 ; 31EF
        LD A,(xb4010)           ; 31F0
        OR A                    ; 31F3
        JP Z,p31FF              ; 31F4
        PUSH DE                 ; 31F7
        EX DE,HL                ; 31F8
        LD HL,(xw401D)          ; 31F9
        ADD HL,DE               ; 31FC
        INC (HL)                ; 31FD
        POP DE                  ; 31FE
p31FF:  POP AF                  ; 31FF
        AND 7FH                 ; 3200
        PUSH AF                 ; 3202
        ADD A,A                 ; 3203
        JP M,p3249              ; 3204
        LD HL,(xw400B)          ; 3207
        LD A,(HL)               ; 320A
        OR A                    ; 320B
        JP Z,p3238              ; 320C
        POP AF                  ; 320F
        PUSH BC                 ; 3210
        LD B,A                  ; 3211
        INC B                   ; 3212
        DEC HL                  ; 3213
p3214:  DEC B                   ; 3214
        JP Z,p3223              ; 3215
        LD A,(HL)               ; 3218
        PUSH DE                 ; 3219
        CPL                     ; 321A
        LD E,A                  ; 321B
        LD D,0FFH               ; 321C
        ADD HL,DE               ; 321E
        POP DE                  ; 321F
        JP p3214                ; 3220

p3223:  LD A,(HL)               ; 3223
        OR A                    ; 3224
        JP Z,p3246              ; 3225
        DEC A                   ; 3228
        LD B,A                  ; 3229
p322A:  DEC HL                  ; 322A
        LD A,(HL)               ; 322B
        INC B                   ; 322C
        DEC B                   ; 322D
        JP Z,p3246              ; 322E
        CALL p33D8              ; 3231
        DEC B                   ; 3234
        JP p322A                ; 3235

p3238:  POP AF                  ; 3238
        DEC HL                  ; 3239
        INC A                   ; 323A
p323B:  DEC A                   ; 323B
        JP Z,p3243              ; 323C
        DEC HL                  ; 323F
        JP p323B                ; 3240

p3243:  LD A,(HL)               ; 3243
        POP HL                  ; 3244
        RET                     ; 3245

p3246:  POP BC                  ; 3246
        POP HL                  ; 3247
        RET                     ; 3248

p3249:  LD A,2EH                ; 3249
        CALL p33D8              ; 324B
        CALL p33D8              ; 324E
        POP AF                  ; 3251
        AND 3FH                 ; 3252
        PUSH BC                 ; 3254
        LD HL,(xw4018)          ; 3255
        LD C,A                  ; 3258
        LD B,00H                ; 3259
        ADD HL,BC               ; 325B
        LD B,H                  ; 325C
        CALL p1914              ; 325D
        LD B,L                  ; 3260
        CALL p1914              ; 3261
        POP BC                  ; 3264
        POP HL                  ; 3265
        DEC DE                  ; 3266
        LD A,(DE)               ; 3267
        RET                     ; 3268

p3269:  PUSH HL                 ; 3269
        CALL p0B55              ; 326A
        POP HL                  ; 326D
        CALL NZ,p3282           ; 326E
        PUSH AF                 ; 3271
        LD DE,xb3DE9            ; 3272 address
        LD A,(DE)               ; 3275
        INC A                   ; 3276
        LD C,A                  ; 3277
p3278:  LD A,(DE)               ; 3278
        LD (HL),A               ; 3279
        INC DE                  ; 327A
        DEC HL                  ; 327B
        DEC C                   ; 327C
        JP NZ,p3278             ; 327D
        POP AF                  ; 3280
        RET                     ; 3281

p3282:  CP 0DH                  ; 3282
        RET Z                   ; 3284
        CP 3BH                  ; 3285
        RET Z                   ; 3287
        POP DE                  ; 3288
        JP p049D                ; 3289

p328C:  LD B,00H                ; 328C
        PUSH BC                 ; 328E
        PUSH HL                 ; 328F
        DEC HL                  ; 3290
        CALL p0BC8              ; 3291
p3294:  CP "'"                  ; 3294
        JP Z,p337D              ; 3296
        CP '"'                  ; 3299
        JP Z,p337D              ; 329B
        CP "<"                  ; 329E
        JP Z,p339B              ; 32A0
        CP ">"                  ; 32A3
        JP Z,p33A6              ; 32A5
        CP "%"                  ; 32A8
        JP Z,p32D3              ; 32AA
        CP ","                  ; 32AD
        JP Z,p33B0              ; 32AF
        CP " "                  ; 32B2
        JP Z,p33B0              ; 32B4
        CP 09H                  ; 32B7 Tab
        JP Z,p33B0              ; 32B9
        CP ';'                  ; 32BC
        JP Z,p33B0              ; 32BE
        CP "!"                  ; 32C1
        CALL Z,p0B29            ; 32C3
        CP 0DH                  ; 32C6
        JP Z,p33CD              ; 32C8
p32CB:  LD (HL),A               ; 32CB
        DEC HL                  ; 32CC
p32CD:  CALL p0AEA              ; 32CD
        JP p3294                ; 32D0

p32D3:  LD (x337B),HL           ; 32D3
        PUSH BC                 ; 32D6
        LD BC,p3371             ; 32D7 code address
        PUSH BC                 ; 32DA
        CALL p28C4              ; 32DB
        EX DE,HL                ; 32DE
        LD C,00H                ; 32DF
        LD A,(xb3E11)           ; 32E1
        CP 20H                  ; 32E4
        JP NZ,p3336             ; 32E6
        LD A,(xb3CF1)           ; 32E9
        CP 10H                  ; 32EC
        JP Z,p332E              ; 32EE
        CP 08H                  ; 32F1
        JP Z,p330E              ; 32F3
        LD BC,0FFF6H            ; 32F6
p32F9:  LD D,B                  ; 32F9
        LD E,B                  ; 32FA
p32FB:  ADD HL,BC               ; 32FB
        INC DE                  ; 32FC
        JP C,p32FB              ; 32FD
        PUSH HL                 ; 3300
        EX DE,HL                ; 3301
        LD A,H                  ; 3302
        OR L                    ; 3303
        CALL NZ,p32F9           ; 3304
        LD A,3AH                ; 3307
        POP BC                  ; 3309
        ADD A,C                 ; 330A
        JP p3366                ; 330B

p330E:  XOR A                   ; 330E
        ADD HL,HL               ; 330F
        ADC A,30H               ; 3310
        CALL p3352              ; 3312
        LD A,05H                ; 3315
p3317:  PUSH AF                 ; 3317
        XOR A                   ; 3318
        LD B,03H                ; 3319
p331B:  ADD HL,HL               ; 331B
        ADC A,A                 ; 331C
        DEC B                   ; 331D
        JP NZ,p331B             ; 331E
        ADD A,30H               ; 3321
        CALL p3352              ; 3323
        POP AF                  ; 3326
        DEC A                   ; 3327
        JP NZ,p3317             ; 3328
        JP p3336                ; 332B

p332E:  LD B,H                  ; 332E
        CALL p333E              ; 332F
        LD B,L                  ; 3332
        CALL p333E              ; 3333
p3336:  INC C                   ; 3336
        DEC C                   ; 3337
        RET NZ                  ; 3338
        LD A,30H                ; 3339
        JP p3366                ; 333B

p333E:  LD A,B                  ; 333E
        RRA                     ; 333F
        RRA                     ; 3340
        RRA                     ; 3341
        RRA                     ; 3342
        CALL p3347              ; 3343
        LD A,B                  ; 3346
p3347:  AND 0FH                 ; 3347
        ADD A,30H               ; 3349
        CP 3AH                  ; 334B
        JP C,p3352              ; 334D
        ADD A,07H               ; 3350
p3352:  INC C                   ; 3352
        DEC C                   ; 3353
        JP NZ,p3366             ; 3354
        CP 30H                  ; 3357
        RET Z                   ; 3359
        LD C,A                  ; 335A
        CP 3AH                  ; 335B
        JP C,p3366              ; 335D
        LD A,30H                ; 3360
        CALL p3366              ; 3362
        LD A,C                  ; 3365
p3366:  PUSH HL                 ; 3366
        LD HL,(x337B)           ; 3367
        LD (HL),A               ; 336A
        DEC HL                  ; 336B
        LD (x337B),HL           ; 336C
        POP HL                  ; 336F
        RET                     ; 3370

p3371:  POP BC                  ; 3371
        CALL p0B36              ; 3372
        LD HL,(x337B)           ; 3375
        JP p32CD                ; 3378

x337B:  DW 0                    ; 337B

p337D:  LD C,A                  ; 337D
p337E:  LD (HL),A               ; 337E
        DEC HL                  ; 337F
        CALL p0AEA              ; 3380
        CP C                    ; 3383
        JP Z,p338F              ; 3384
        CP 0DH                  ; 3387
        JP Z,p33D2              ; 3389
        JP p337E                ; 338C

p338F:  LD (HL),A               ; 338F
        DEC HL                  ; 3390
        CALL p0AEA              ; 3391
        CP C                    ; 3394
        JP Z,p337E              ; 3395
        JP p3294                ; 3398

p339B:  INC B                   ; 339B
        DEC B                   ; 339C
        JP Z,p33A2              ; 339D
        LD (HL),A               ; 33A0
        DEC HL                  ; 33A1
p33A2:  INC B                   ; 33A2
        JP p32CD                ; 33A3

p33A6:  DEC B                   ; 33A6
        JP Z,p32CD              ; 33A7
        JP M,p33B5              ; 33AA
        JP p32CB                ; 33AD

p33B0:  INC B                   ; 33B0
        DEC B                   ; 33B1
        JP NZ,p32CB             ; 33B2
p33B5:  POP DE                  ; 33B5
        LD A,E                  ; 33B6
        SUB L                   ; 33B7
        DEC A                   ; 33B8
        LD (DE),A               ; 33B9
        POP BC                  ; 33BA
        EX DE,HL                ; 33BB
        LD HL,(xw3D46)          ; 33BC
        DEC HL                  ; 33BF
        LD A,(HL)               ; 33C0
        CP 20H                  ; 33C1
        CALL Z,p0B36            ; 33C3
        CP 09H                  ; 33C6
        CALL Z,p0B36            ; 33C8
        EX DE,HL                ; 33CB
        RET                     ; 33CC

p33CD:  INC B                   ; 33CD
        DEC B                   ; 33CE
        JP Z,p33B5              ; 33CF
p33D2:  CALL p04E5              ; 33D2
        JP p33B5                ; 33D5

p33D8:  PUSH AF                 ; 33D8
        PUSH HL                 ; 33D9
        LD HL,xf3DCA            ; 33DA address
        CALL p0D8D              ; 33DD
        JP NC,p33EB             ; 33E0
        INC HL                  ; 33E3
        LD (HL),0DH             ; 33E4
        DEC HL                  ; 33E6
        EX DE,HL                ; 33E7
        POP HL                  ; 33E8
        POP AF                  ; 33E9
        RET                     ; 33EA

p33EB:  POP HL                  ; 33EB
        POP AF                  ; 33EC
        LD (DE),A               ; 33ED
        INC DE                  ; 33EE
        RET                     ; 33EF

p33F0:  CALL p313E              ; 33F0
        CP 26H                  ; 33F3
        JP Z,p33F0              ; 33F5
        CP 3AH                  ; 33F8
        JP Z,p313E              ; 33FA
        CP 21H                  ; 33FD
        RET NC                  ; 33FF
        CP 0DH                  ; 3400
        RET Z                   ; 3402
        PUSH AF                 ; 3403
        CALL p0C0E              ; 3404
        JP Z,p3410              ; 3407
        CALL p0515              ; 340A
        JP Z,p18C7              ; 340D
p3410:  POP AF                  ; 3410
        JP p313E                ; 3411

p3414:  LD HL,x341A             ; 3414 message
        JP p0D72                ; 3417

x341A:  DB "?Stack overflow, try more P switches"
        DB 0DH,0AH,00H

p3441:  CALL p28C4              ; 3441
        LD A,(xb3E11)           ; 3444
        CP 20H                  ; 3447
        JP Z,p344F              ; 3449
        LD DE,0000H             ; 344C
p344F:  EX DE,HL                ; 344F
        LD (xw3FFD),HL          ; 3450
        CALL p2FFE              ; 3453
        POP BC                  ; 3456
        POP DE                  ; 3457
        POP HL                  ; 3458
        LD BC,p3463             ; 3459 code address
p345C:  PUSH BC                 ; 345C
        PUSH DE                 ; 345D
p345E:  LD A,0DH                ; 345E
        JP p045C                ; 3460

p3463:  POP BC                  ; 3463
        LD BC,p345E             ; 3464 code address
        PUSH BC                 ; 3467
        CALL p0B55              ; 3468
        CP 3AH                  ; 346B
        CALL Z,p0B55            ; 346D
        CALL p3048              ; 3470
        JP Z,p3484              ; 3473
        LD DE,xf3D48            ; 3476 address of buffer
p3479:  LD A,(DE)               ; 3479
        CALL p3A3B              ; 347A
        INC DE                  ; 347D
        CP 0DH                  ; 347E
        JP NZ,p3479             ; 3480
        RET                     ; 3483

p3484:  XOR A                   ; 3484
p3485:  CALL p3A3B              ; 3485
        CALL p3A9E              ; 3488
        POP BC                  ; 348B
        POP DE                  ; 348C
        POP HL                  ; 348D
        LD HL,p02CC             ; 348E code address
p3491:  PUSH HL                 ; 3491
        PUSH DE                 ; 3492
        LD HL,(xw4023)          ; 3493
        PUSH HL                 ; 3496
        PUSH HL                 ; 3497
        LD HL,(xw3FFD)          ; 3498
        PUSH HL                 ; 349B
        LD HL,p02CC             ; 349C code address
        PUSH HL                 ; 349F
p34A0:  LD HL,p34A6             ; 34A0 code address
        PUSH HL                 ; 34A3
        PUSH BC                 ; 34A4
        RET                     ; 34A5

p34A6:  CALL p34F9              ; 34A6
        POP BC                  ; 34A9
p34AA:  POP HL                  ; 34AA
p34AB:  POP DE                  ; 34AB
        CALL p0D8D              ; 34AC
        JP NZ,p34D5             ; 34AF
        LD A,(xb4006)           ; 34B2
        OR A                    ; 34B5
        JP NZ,p34BE             ; 34B6
        LD A,B                  ; 34B9
        OR C                    ; 34BA
        JP NZ,p34D5             ; 34BB
p34BE:  LD HL,(xw3FF8)          ; 34BE
p34C1:  PUSH HL                 ; 34C1
        CALL p3994              ; 34C2
        POP HL                  ; 34C5
p34C6:  CALL p308A              ; 34C6
        XOR A                   ; 34C9
        LD (xb4006),A           ; 34CA
        POP DE                  ; 34CD
        PUSH DE                 ; 34CE
        LD HL,(xw3FFF)          ; 34CF
        PUSH HL                 ; 34D2
        EX DE,HL                ; 34D3
        JP (HL)                 ; 34D4

p34D5:  PUSH DE                 ; 34D5
        CALL p3A72              ; 34D6
        OR A                    ; 34D9
        JP Z,p3508              ; 34DA
        LD DE,xf3D48            ; 34DD address of buffer
p34E0:  CALL p3A88              ; 34E0
        CALL p33D8              ; 34E3
        CP 0DH                  ; 34E6
        JP NZ,p34E0             ; 34E8
        PUSH HL                 ; 34EB
        PUSH BC                 ; 34EC
p34ED:  LD HL,(xw4001)          ; 34ED
        PUSH HL                 ; 34F0
        LD HL,(xw4003)          ; 34F1
        PUSH HL                 ; 34F4
        LD HL,(xw3FFF)          ; 34F5
        JP (HL)                 ; 34F8
p34F9:  POP DE                  ; 34F9
        POP HL                  ; 34FA
        LD (xw3FFF),HL          ; 34FB
        POP HL                  ; 34FE
        LD (xw4003),HL          ; 34FF
        POP HL                  ; 3502
        LD (xw4001),HL          ; 3503
        EX DE,HL                ; 3506
        JP (HL)                 ; 3507

p3508:  DEC BC                  ; 3508
        LD H,D                  ; 3509
        LD L,E                  ; 350A
        JP p34AB                ; 350B

p350E:  LD A,(xb3FFA)           ; 350E
        OR A                    ; 3511
        JP Z,p04E5              ; 3512
        LD (xb4006),A           ; 3515
        POP BC                  ; 3518
        POP HL                  ; 3519
        POP DE                  ; 351A
        LD DE,p352B             ; 351B code address
        PUSH DE                 ; 351E
        PUSH HL                 ; 351F
        PUSH BC                 ; 3520
        XOR A                   ; 3521
        LD (xb4005),A           ; 3522
        JP p0B40                ; 3525

p3528:  JP p04C1                ; 3528

p352B:  LD A,(xb4006)           ; 352B
        OR A                    ; 352E
        JP Z,p358A              ; 352F
        POP BC                  ; 3532
        LD BC,p01DE             ; 3533 spoofed return address
        PUSH BC                 ; 3536
        CALL p0B55              ; 3537
        CP 3AH                  ; 353A
        CALL Z,p0B55            ; 353C
        CALL p0515              ; 353F
        RET NZ                  ; 3542
        OR A                    ; 3543
        RET P                   ; 3544
        LD C,A                  ; 3545
        AND 08H                 ; 3546
        JP NZ,p355E             ; 3548
        LD A,C                  ; 354B
        AND 10H                 ; 354C
        JP NZ,p3566             ; 354E
        LD A,C                  ; 3551
        AND 20H                 ; 3552
        JP NZ,p356E             ; 3554
        LD A,C                  ; 3557
        AND 40H                 ; 3558
        JP NZ,p357B             ; 355A
        RET                     ; 355D

p355E:  LD A,(xb4005)           ; 355E
        DEC A                   ; 3561
        LD (xb4005),A           ; 3562
        RET                     ; 3565

p3566:  LD A,(xb4005)           ; 3566
        INC A                   ; 3569
        LD (xb4005),A           ; 356A
        RET                     ; 356D

p356E:  LD A,(xb4005)           ; 356E
        OR A                    ; 3571
        RET NZ                  ; 3572
        LD A,(xb3CF3)           ; 3573
        OR A                    ; 3576
        RET Z                   ; 3577
        JP p28EA                ; 3578

p357B:  LD A,(xb4005)           ; 357B
        OR A                    ; 357E
        RET NZ                  ; 357F
        INC HL                  ; 3580
        LD A,(HL)               ; 3581
        CP 08H                  ; 3582
        RET Z                   ; 3584
        LD A,0FFH               ; 3585
        JP p2950                ; 3587

p358A:  POP BC                  ; 358A
        POP DE                  ; 358B
        POP HL                  ; 358C
        LD HL,p02CC             ; 358D code address
        PUSH HL                 ; 3590
        PUSH DE                 ; 3591
        PUSH BC                 ; 3592
        RET                     ; 3593

p3594:  OR A                    ; 3594
        PUSH AF                 ; 3595
        CALL p2FFE              ; 3596
        LD (xw4007),HL          ; 3599
        CALL p3269              ; 359C
        LD C,A                  ; 359F
        LD A,(xb3E11)           ; 35A0
        CP 20H                  ; 35A3
        JP Z,p35B0              ; 35A5
        LD HL,(xw4007)          ; 35A8
        CALL p308A              ; 35AB
        POP AF                  ; 35AE
        RET                     ; 35AF

p35B0:  LD A,C                  ; 35B0
        LD (HL),00H             ; 35B1
        DEC HL                  ; 35B3
        CP 2CH                  ; 35B4
        CALL NZ,p049D           ; 35B6
        POP AF                  ; 35B9
        PUSH AF                 ; 35BA
        JP Z,p35EC              ; 35BB
        CALL p0B29              ; 35BE
        CP 3CH                  ; 35C1
        CALL NZ,p049D           ; 35C3
p35C6:  POP AF                  ; 35C6
        LD (HL),A               ; 35C7
        PUSH HL                 ; 35C8
        PUSH AF                 ; 35C9
        LD C,00H                ; 35CA
        DEC HL                  ; 35CC
        LD A,(xb3E11)           ; 35CD
        CP 20H                  ; 35D0
        JP NZ,p3647             ; 35D2
        POP AF                  ; 35D5
        PUSH AF                 ; 35D6
        LD B,A                  ; 35D7
        JP Z,p35FA              ; 35D8

p35DB:  CALL p328C              ; 35DB
        INC C                   ; 35DE
        CP 0DH                  ; 35DF
        JP Z,p3644              ; 35E1
        CP 3EH                  ; 35E4
        JP Z,p3647              ; 35E6
        JP p35DB                ; 35E9

p35EC:  CALL p0B23              ; 35EC
        SUB 3CH                 ; 35EF
        LD (xb400E),A           ; 35F1
        CALL Z,p0AEA            ; 35F4
        JP p35C6                ; 35F7

p35FA:  CALL p0AEA              ; 35FA
        CP 0DH                  ; 35FD
        JP Z,p363D              ; 35FF
        PUSH AF                 ; 3602
        LD A,(xb400E)           ; 3603
        OR A                    ; 3606
        JP Z,p361F              ; 3607
        POP AF                  ; 360A
        LD DE,p3647             ; 360B spoofed return address
        PUSH DE                 ; 360E
        CP 20H                  ; 360F
        RET Z                   ; 3611
        CP 09H                  ; 3612
        RET Z                   ; 3614
        CP 3BH                  ; 3615
        RET Z                   ; 3617
        CP 2CH                  ; 3618
        RET Z                   ; 361A
        POP DE                  ; 361B
        JP p3637                ; 361C

p361F:  POP AF                  ; 361F
        CP 3CH                  ; 3620
        JP Z,p3633              ; 3622
        CP 3EH                  ; 3625
        JP NZ,p3637             ; 3627
        INC B                   ; 362A
        DEC B                   ; 362B
        JP Z,p3647              ; 362C
        DEC B                   ; 362F
        JP p3637                ; 3630

p3633:  INC B                   ; 3633
        JP p3637                ; 3634

p3637:  INC C                   ; 3637
        LD (HL),A               ; 3638
        DEC HL                  ; 3639
        JP p35FA                ; 363A

p363D:  LD A,(xb400E)           ; 363D
        OR A                    ; 3640
        JP NZ,p3647             ; 3641
p3644:  CALL p04CD              ; 3644
p3647:  LD (HL),00H             ; 3647
        DEC HL                  ; 3649
        CALL p302E              ; 364A
        LD A,B                  ; 364D
        OR A                    ; 364E
        CALL NZ,p049D           ; 364F
        POP AF                  ; 3652
        POP HL                  ; 3653
        LD (xw4009),HL          ; 3654
        LD H,00H                ; 3657
        LD L,C                  ; 3659
        LD (xw3FFD),HL          ; 365A
        POP BC                  ; 365D
        POP DE                  ; 365E
        POP HL                  ; 365F
        LD BC,p366D             ; 3660 code address
        JP p345C                ; 3663

; Crimes against humanity. The JP NZ is never executed.

p3666:  XOR A                   ; 3666
        DB 0C2H                 ; 3667 (JP NZ,013EH)
p3668:  LD A,01H                ; 3668
        JP p3594                ; 366A

p366D:  POP BC                  ; 366D
        LD BC,p345E             ; 366E code address
        PUSH BC                 ; 3671
        LD HL,(xw4025)          ; 3672
        LD A,01H                ; 3675
        LD (xb4010),A           ; 3677
        PUSH HL                 ; 367A
        CALL p33F0              ; 367B
        PUSH AF                 ; 367E
        CALL p3048              ; 367F
        JP Z,p36B1              ; 3682
        POP AF                  ; 3685
        POP HL                  ; 3686
p3687:  CP 0DH                  ; 3687
        JP Z,p31B6              ; 3689
        CP 3BH                  ; 368C
        JP Z,p31AB              ; 368E
        CP 27H                  ; 3691
        JP Z,p36A1              ; 3693
        CP 22H                  ; 3696
        JP Z,p36A1              ; 3698
p369B:  CALL p313E              ; 369B
        JP p3687                ; 369E

p36A1:  LD B,A                  ; 36A1
p36A2:  CALL p3095              ; 36A2
        CP 0DH                  ; 36A5
        JP Z,p31B6              ; 36A7
        CP B                    ; 36AA
        JP Z,p369B              ; 36AB
        JP p36A2                ; 36AE

p36B1:  POP AF                  ; 36B1
        POP HL                  ; 36B2
        LD (xw4025),HL          ; 36B3
        XOR A                   ; 36B6
        CALL p3A3B              ; 36B7
        CALL p3A9E              ; 36BA
        POP BC                  ; 36BD
        POP DE                  ; 36BE
        POP HL                  ; 36BF
        LD HL,p02CC             ; 36C0 code address
        PUSH HL                 ; 36C3
        PUSH DE                 ; 36C4
        LD HL,(xw4023)          ; 36C5
        PUSH HL                 ; 36C8
        PUSH HL                 ; 36C9
        LD HL,(xw4009)          ; 36CA
        PUSH HL                 ; 36CD
        LD HL,(xw3FFD)          ; 36CE
        PUSH HL                 ; 36D1
        LD HL,p02CC             ; 36D2 code address
        PUSH HL                 ; 36D5
        LD HL,p36DC             ; 36D6 code address
        PUSH HL                 ; 36D9
        PUSH BC                 ; 36DA
        RET                     ; 36DB

p36DC:  CALL p34F9              ; 36DC
        POP BC                  ; 36DF
        POP HL                  ; 36E0
        POP DE                  ; 36E1
        LD A,01H                ; 36E2
        LD (xb4010),A           ; 36E4
        LD (xw400B),HL          ; 36E7
        POP HL                  ; 36EA
        CALL p0D8D              ; 36EB
        JP NZ,p370D             ; 36EE
p36F1:  LD A,(xb4006)           ; 36F1
        OR A                    ; 36F4
        JP NZ,p36FD             ; 36F5
        LD A,B                  ; 36F8
        OR C                    ; 36F9
        JP NZ,p370D             ; 36FA
p36FD:  LD HL,(xw400B)          ; 36FD
        INC HL                  ; 3700
        INC HL                  ; 3701
p3702:  LD A,(HL)               ; 3702
        CP 08H                  ; 3703
        INC HL                  ; 3705
        JP NC,p3702             ; 3706
        DEC HL                  ; 3709
        JP p34C1                ; 370A

p370D:  EX DE,HL                ; 370D
        PUSH DE                 ; 370E
        CALL p3A72              ; 370F
        OR A                    ; 3712
        JP Z,p3734              ; 3713
        LD DE,xf3D48            ; 3716 address of buffer
p3719:  CALL p3A72              ; 3719
        OR A                    ; 371C
        CALL M,p31EE            ; 371D
        CALL p3AED              ; 3720
        CALL p33D8              ; 3723
        CP 0DH                  ; 3726
        JP NZ,p3719             ; 3728
        PUSH HL                 ; 372B
        LD HL,(xw400B)          ; 372C
        PUSH HL                 ; 372F
        PUSH BC                 ; 3730
        JP p34ED                ; 3731

p3734:  DEC BC                  ; 3734
        LD H,D                  ; 3735
        LD L,E                  ; 3736
        POP DE                  ; 3737
        JP p36F1                ; 3738

p373B:  CALL p0BC8              ; 373B
        CP 0DH                  ; 373E
        JP Z,p049D              ; 3740
        LD C,A                  ; 3743
        CALL p4AEE              ; 3744
p3747:  CALL p0B29              ; 3747
        CP 0DH                  ; 374A
        JP Z,p3756              ; 374C
        CALL p4AEE              ; 374F
        CP C                    ; 3752
        JP NZ,p3747             ; 3753
p3756:  LD A,0DH                ; 3756
        CALL p4AEE              ; 3758
        LD A,0AH                ; 375B
        CALL p4AEE              ; 375D
        LD A,(xb3E11)           ; 3760
        CP 20H                  ; 3763
        RET NZ                  ; 3765
        JP p0B40                ; 3766

p3769:  CALL p0BC8              ; 3769
        CP 0DH                  ; 376C
        JP Z,p049D              ; 376E
        LD (xb400D),A           ; 3771
        LD C,A                  ; 3774
p3775:  CALL p0AEA              ; 3775
        CP 0DH                  ; 3778
        JP Z,p3784              ; 377A
        CP C                    ; 377D
        JP Z,p0B40              ; 377E
        JP p3775                ; 3781

p3784:  POP HL                  ; 3784
        POP DE                  ; 3785
        POP BC                  ; 3786
        LD BC,p378D             ; 3787 code address
        JP p345C                ; 378A

p378D:  POP BC                  ; 378D
        LD BC,p345E             ; 378E code address
        PUSH BC                 ; 3791
        LD HL,xf3D48            ; 3792 address of buffer
        LD A,(xb400D)           ; 3795
        LD C,A                  ; 3798
p3799:  LD A,(HL)               ; 3799
        CP C                    ; 379A
        JP Z,p37A5              ; 379B
        CP 0DH                  ; 379E
        RET Z                   ; 37A0
        INC HL                  ; 37A1
        JP p3799                ; 37A2

p37A5:  POP BC                  ; 37A5
        POP DE                  ; 37A6
        POP HL                  ; 37A7
        LD HL,p02CC             ; 37A8 code address
        PUSH HL                 ; 37AB
        PUSH DE                 ; 37AC
        PUSH BC                 ; 37AD
        RET                     ; 37AE

p37AF:  OR A                    ; 37AF
        CALL p0DD4              ; 37B0
        INC HL                  ; 37B3
        LD (xw3FF6),HL          ; 37B4
        LD A,(HL)               ; 37B7
        OR 28H                  ; 37B8
        LD (HL),A               ; 37BA
        CALL p2FFE              ; 37BB
        LD (xw4007),HL          ; 37BE
        LD C,00H                ; 37C1
p37C3:  PUSH BC                 ; 37C3
        CALL p3269              ; 37C4
        POP BC                  ; 37C7
        INC C                   ; 37C8
        CP 2CH                  ; 37C9
        JP Z,p37C3              ; 37CB
        XOR A                   ; 37CE
        LD (HL),A               ; 37CF
        DEC HL                  ; 37D0
        LD (xb400F),A           ; 37D1
        LD (xb4015),A           ; 37D4
        INC A                   ; 37D7
        LD (HL),A               ; 37D8
        DEC HL                  ; 37D9
        LD (xw4011),HL          ; 37DA
        LD (xw4013),HL          ; 37DD
        LD (HL),00H             ; 37E0
        LD A,C                  ; 37E2
        LD (xb401A),A           ; 37E3
        CALL p3A3B              ; 37E6
        XOR A                   ; 37E9
        CALL p3A3B              ; 37EA
        POP BC                  ; 37ED
        POP DE                  ; 37EE
        POP HL                  ; 37EF
        LD HL,p37F7             ; 37F0 code address
        PUSH HL                 ; 37F3
        PUSH DE                 ; 37F4
        PUSH BC                 ; 37F5
        RET                     ; 37F6

p37F7:  POP BC                  ; 37F7
        LD BC,p345E             ; 37F8 code address
        PUSH BC                 ; 37FB
        LD HL,(xw4025)          ; 37FC
        PUSH HL                 ; 37FF
        XOR A                   ; 3800
        LD (xb400F),A           ; 3801
        LD (xb4010),A           ; 3804
        CALL p33F0              ; 3807
        PUSH AF                 ; 380A
        CALL p3048              ; 380B
        JP C,p381C              ; 380E
        JP Z,p384F              ; 3811
        POP AF                  ; 3814
        LD (xb400F),A           ; 3815
        POP HL                  ; 3818
        JP p3687                ; 3819

p381C:  POP AF                  ; 381C
p381D:  CALL p0B55              ; 381D
        CALL NZ,p049D           ; 3820
        LD HL,(xw4013)          ; 3823
        PUSH AF                 ; 3826
        JP NZ,p3831             ; 3827
        LD A,(xb4015)           ; 382A
        INC A                   ; 382D
        LD (xb4015),A           ; 382E
p3831:  LD DE,xb3DE9            ; 3831 address
        LD A,(DE)               ; 3834
        INC A                   ; 3835
        LD C,A                  ; 3836
p3837:  LD A,(DE)               ; 3837
        LD (HL),A               ; 3838
        DEC HL                  ; 3839
        INC DE                  ; 383A
        DEC C                   ; 383B
        JP NZ,p3837             ; 383C
        LD (HL),00H             ; 383F
        LD (xw4013),HL          ; 3841
        POP AF                  ; 3844
        CP 2CH                  ; 3845
        JP Z,p381D              ; 3847
        POP HL                  ; 384A
        LD (xw4025),HL          ; 384B
        RET                     ; 384E

p384F:  POP AF                  ; 384F
        POP HL                  ; 3850
        XOR A                   ; 3851
        LD (xw4025),HL          ; 3852
        CALL p3A3B              ; 3855
        CALL p3A9E              ; 3858
        LD HL,(xw4023)          ; 385B
        LD DE,0005H             ; 385E
        ADD HL,DE               ; 3861
        EX DE,HL                ; 3862
        LD HL,(xw401D)          ; 3863
        ADD HL,DE               ; 3866
        LD A,(xb4015)           ; 3867
        LD (HL),A               ; 386A
        LD HL,(xw4023)          ; 386B
        EX DE,HL                ; 386E
        LD HL,(xw3FF6)          ; 386F
        INC HL                  ; 3872
        PUSH DE                 ; 3873
        PUSH HL                 ; 3874
        LD E,(HL)               ; 3875
        INC HL                  ; 3876
        LD D,(HL)               ; 3877
        LD A,D                  ; 3878
        OR E                    ; 3879
        CALL NZ,p3994           ; 387A
        POP HL                  ; 387D
        POP DE                  ; 387E
        LD (HL),E               ; 387F
        INC HL                  ; 3880
        LD (HL),D               ; 3881
        LD HL,(xw4007)          ; 3882
        CALL p308A              ; 3885
        POP BC                  ; 3888
        POP DE                  ; 3889
        POP HL                  ; 388A
        LD HL,p02CC             ; 388B code address
        PUSH HL                 ; 388E
        PUSH DE                 ; 388F
        PUSH BC                 ; 3890
        RET                     ; 3891

p3892:  PUSH HL                 ; 3892
        SCF                     ; 3893
        CALL p0D93              ; 3894
        CALL p2FFE              ; 3897
        LD (HL),00H             ; 389A
        DEC HL                  ; 389C
        LD (HL),01H             ; 389D
        LD (xw400B),HL          ; 389F
        DEC HL                  ; 38A2
        LD C,00H                ; 38A3
p38A5:  CALL p328C              ; 38A5
        LD B,A                  ; 38A8
        INC C                   ; 38A9
        CALL p0B36              ; 38AA
        CALL p0BC8              ; 38AD
        CP 0DH                  ; 38B0
        JP Z,p38CD              ; 38B2
        CP 3BH                  ; 38B5
        JP Z,p38CD              ; 38B7
        CP 2CH                  ; 38BA
        JP Z,p38A5              ; 38BC
        LD A,B                  ; 38BF
        CP 20H                  ; 38C0
        JP Z,p38A5              ; 38C2
        CP 09H                  ; 38C5
        CALL NZ,p04CD           ; 38C7
        JP p38A5                ; 38CA

p38CD:  EX (SP),HL              ; 38CD
        INC HL                  ; 38CE
        INC HL                  ; 38CF
        LD E,(HL)               ; 38D0
        INC HL                  ; 38D1
        LD D,(HL)               ; 38D2
        EX DE,HL                ; 38D3
        CALL p3A88              ; 38D4
        EX (SP),HL              ; 38D7
        OR A                    ; 38D8
        JP Z,p38EA              ; 38D9
p38DC:  CP C                    ; 38DC
        JP Z,p38EA              ; 38DD
        JP C,p38EA              ; 38E0
        LD (HL),00H             ; 38E3
        DEC HL                  ; 38E5
        INC C                   ; 38E6
        JP p38DC                ; 38E7

p38EA:  LD (HL),00H             ; 38EA
        DEC HL                  ; 38EC
        CALL p302E              ; 38ED
        POP HL                  ; 38F0
        POP BC                  ; 38F1
        CALL p3A88              ; 38F2
        PUSH HL                 ; 38F5
        LD HL,(xw4016)          ; 38F6
        PUSH HL                 ; 38F9
        PUSH BC                 ; 38FA
        LD C,A                  ; 38FB
        LD B,00H                ; 38FC
        ADD HL,BC               ; 38FE
        LD (xw4016),HL          ; 38FF
        POP BC                  ; 3902
        LD HL,(xw400B)          ; 3903
        PUSH HL                 ; 3906
        LD HL,p02CC             ; 3907 code address
        PUSH HL                 ; 390A
        LD DE,p3911             ; 390B code address
        PUSH DE                 ; 390E
        PUSH BC                 ; 390F
        RET                     ; 3910

p3911:  CALL p34F9              ; 3911
        POP HL                  ; 3914
        LD (xw400B),HL          ; 3915
        POP HL                  ; 3918
        LD (xw4018),HL          ; 3919
        POP HL                  ; 391C
        XOR A                   ; 391D
        LD (xb4010),A           ; 391E
        CALL p3A72              ; 3921
        OR A                    ; 3924
        JP Z,p3949              ; 3925
        LD DE,xf3D48            ; 3928 address of buffer
p392B:  CALL p3A72              ; 392B
        OR A                    ; 392E
        CALL M,p31EE            ; 392F
        CALL p3AED              ; 3932
        CALL p33D8              ; 3935
        CP 0DH                  ; 3938
        JP NZ,p392B             ; 393A
        PUSH HL                 ; 393D
        LD HL,(xw4018)          ; 393E
        PUSH HL                 ; 3941
        LD HL,(xw400B)          ; 3942
        PUSH HL                 ; 3945
        JP p34ED                ; 3946

p3949:  LD HL,(xw400B)          ; 3949
        INC HL                  ; 394C
        XOR A                   ; 394D
        LD (xb4006),A           ; 394E
        JP p34C6                ; 3951

p3954:  LD A,L                  ; 3954
        SUB E                   ; 3955
        LD E,A                  ; 3956
        LD A,H                  ; 3957
        SBC A,D                 ; 3958
        LD D,A                  ; 3959
        RET                     ; 395A

p395B:  LD A,(xb3DE4)           ; 395B
        OR A                    ; 395E
        JP NZ,p04C7             ; 395F
        CALL p2083              ; 3962
        LD A,(xb3E11)           ; 3965
        CP 20H                  ; 3968
        RET NZ                  ; 396A
        LD (xb3DE4),A           ; 396B
        LD A,B                  ; 396E
        AND 80H                 ; 396F
        JP NZ,p049D             ; 3971
        LD A,B                  ; 3974
        AND 03H                 ; 3975
        LD (xb3DE7),A           ; 3977
        LD HL,(xw3DD2)          ; 397A
        EX DE,HL                ; 397D
        CALL p3954              ; 397E
        EX DE,HL                ; 3981
        LD (xw3DE5),HL          ; 3982
        RET                     ; 3985

p3986:  LD A,(xb3DE4)           ; 3986
        OR A                    ; 3989
        CALL Z,p04CD            ; 398A
        XOR A                   ; 398D
        LD (xb3DE4),A           ; 398E
        JP p0B40                ; 3991

p3994:  LD HL,xw4021            ; 3994
        LD C,(HL)               ; 3997
        LD (HL),E               ; 3998
        INC HL                  ; 3999
        LD B,(HL)               ; 399A
        LD (HL),D               ; 399B
        CALL p39A6              ; 399C
        CALL p39AF              ; 399F
        LD (HL),C               ; 39A2
        INC HL                  ; 39A3
        LD (HL),B               ; 39A4
        RET                     ; 39A5

p39A6:  LD HL,(xw401D)          ; 39A6
        ADD HL,DE               ; 39A9
        LD E,(HL)               ; 39AA
        INC HL                  ; 39AB
        LD D,(HL)               ; 39AC
        DEC HL                  ; 39AD
        RET                     ; 39AE

p39AF:  LD HL,(xw401D)          ; 39AF
        ADD HL,DE               ; 39B2
        INC HL                  ; 39B3
        INC HL                  ; 39B4
        LD E,(HL)               ; 39B5
        INC HL                  ; 39B6
        LD D,(HL)               ; 39B7
        DEC HL                  ; 39B8
        RET                     ; 39B9

p39BA:  LD HL,(xw4021)          ; 39BA
        LD A,L                  ; 39BD
        OR H                    ; 39BE
        JP Z,p39CF              ; 39BF
        EX DE,HL                ; 39C2
        PUSH DE                 ; 39C3
        CALL p39AF              ; 39C4
        EX DE,HL                ; 39C7
        LD (xw4021),HL          ; 39C8
        POP DE                  ; 39CB
        JP p39FB                ; 39CC

p39CF:  LD HL,(xw401F)          ; 39CF
        LD DE,0020H             ; 39D2
        EX DE,HL                ; 39D5
        ADD HL,DE               ; 39D6
        LD (xw401F),HL          ; 39D7
        PUSH DE                 ; 39DA
        EX DE,HL                ; 39DB
        LD HL,(xw4029)          ; 39DC
        CALL p0D8D              ; 39DF
        POP DE                  ; 39E2
        JP C,p3B49              ; 39E3
        LD HL,(xw3FF8)          ; 39E6
        DEC H                   ; 39E9
        LD A,(xb3FFA)           ; 39EA
        OR A                    ; 39ED
        CALL p0D8D              ; 39EE
        JP C,p3B49              ; 39F1
        LD HL,(xw401D)          ; 39F4
        EX DE,HL                ; 39F7
        CALL p3954              ; 39F8
p39FB:  PUSH DE                 ; 39FB
        CALL p39A6              ; 39FC
        EX DE,HL                ; 39FF
        LD HL,(xw4025)          ; 3A00
        EX DE,HL                ; 3A03
        LD A,E                  ; 3A04
        AND 0E0H                ; 3A05
        LD E,A                  ; 3A07
        LD A,E                  ; 3A08
        OR D                    ; 3A09
        JP NZ,p3A0F             ; 3A0A
        POP DE                  ; 3A0D
        PUSH DE                 ; 3A0E
p3A0F:  LD (HL),E               ; 3A0F
        INC HL                  ; 3A10
        LD (HL),D               ; 3A11
        INC HL                  ; 3A12
        LD A,00H                ; 3A13
        LD (HL),A               ; 3A15
        INC HL                  ; 3A16
        LD (HL),A               ; 3A17
        CALL p39AF              ; 3A18
        POP DE                  ; 3A1B
        JP Z,p3A25              ; 3A1C
        LD (HL),E               ; 3A1F
        INC HL                  ; 3A20
        LD (HL),D               ; 3A21
        JP p3A2A                ; 3A22

p3A25:  EX DE,HL                ; 3A25
        LD (xw4023),HL          ; 3A26
        EX DE,HL                ; 3A29
p3A2A:  LD HL,(xw4023)          ; 3A2A
        PUSH DE                 ; 3A2D
        EX DE,HL                ; 3A2E
        CALL p39A6              ; 3A2F
        POP DE                  ; 3A32
        LD (HL),E               ; 3A33
        INC HL                  ; 3A34
        LD (HL),D               ; 3A35
        LD A,E                  ; 3A36
        OR 04H                  ; 3A37
        LD E,A                  ; 3A39
        RET                     ; 3A3A

p3A3B:  PUSH DE                 ; 3A3B
        PUSH AF                 ; 3A3C
p3A3D:  LD HL,(xw4025)          ; 3A3D
        EX DE,HL                ; 3A40
        LD A,E                  ; 3A41
        AND 1FH                 ; 3A42
        CALL Z,p39BA            ; 3A44
        LD HL,(xw401D)          ; 3A47
        ADD HL,DE               ; 3A4A
        POP AF                  ; 3A4B
        PUSH AF                 ; 3A4C
        LD (HL),A               ; 3A4D
        LD A,E                  ; 3A4E
        AND 1FH                 ; 3A4F
        CP 1FH                  ; 3A51
        JP Z,p3A57              ; 3A53
        INC DE                  ; 3A56
p3A57:  CALL Z,p3A61            ; 3A57
        EX DE,HL                ; 3A5A
        LD (xw4025),HL          ; 3A5B
        POP AF                  ; 3A5E
        POP DE                  ; 3A5F
        RET                     ; 3A60

p3A61:  LD A,E                  ; 3A61
        AND 0E0H                ; 3A62
        LD E,A                  ; 3A64
        CALL p39AF              ; 3A65
        LD A,D                  ; 3A68
        OR E                    ; 3A69
        JP Z,p39BA              ; 3A6A
        INC DE                  ; 3A6D
        INC DE                  ; 3A6E
        INC DE                  ; 3A6F
        INC DE                  ; 3A70
        RET                     ; 3A71

p3A72:  PUSH DE                 ; 3A72
        EX DE,HL                ; 3A73
        LD HL,(xw401D)          ; 3A74
        EX DE,HL                ; 3A77
        LD A,L                  ; 3A78
        AND 1FH                 ; 3A79
        JP NZ,p3A82             ; 3A7B
        LD A,L                  ; 3A7E
        OR 04H                  ; 3A7F
        LD L,A                  ; 3A81
p3A82:  EX DE,HL                ; 3A82
        ADD HL,DE               ; 3A83
        LD A,(HL)               ; 3A84
        EX DE,HL                ; 3A85
        POP DE                  ; 3A86
        RET                     ; 3A87

p3A88:  CALL p3A72              ; 3A88
        PUSH AF                 ; 3A8B
        PUSH DE                 ; 3A8C
        EX DE,HL                ; 3A8D
        LD A,E                  ; 3A8E
        AND 1FH                 ; 3A8F
        CP 1FH                  ; 3A91
        JP Z,p3A97              ; 3A93
        INC DE                  ; 3A96
p3A97:  CALL Z,p3A61            ; 3A97
        EX DE,HL                ; 3A9A
        POP DE                  ; 3A9B
        POP AF                  ; 3A9C
        RET                     ; 3A9D

p3A9E:  EX DE,HL                ; 3A9E
        LD A,E                  ; 3A9F
        AND 0E0H                ; 3AA0
        LD E,A                  ; 3AA2
        PUSH DE                 ; 3AA3
        CALL p39AF              ; 3AA4
        LD A,E                  ; 3AA7
        OR D                    ; 3AA8
        POP BC                  ; 3AA9
        RET Z                   ; 3AAA
        XOR A                   ; 3AAB
        LD (HL),A               ; 3AAC
        INC HL                  ; 3AAD
        LD (HL),A               ; 3AAE
        LD HL,(xw401D)          ; 3AAF
        ADD HL,DE               ; 3AB2
        LD (HL),E               ; 3AB3
        INC HL                  ; 3AB4
        LD (HL),D               ; 3AB5
        PUSH BC                 ; 3AB6
        CALL p3994              ; 3AB7
        POP BC                  ; 3ABA
        LD HL,(xw4023)          ; 3ABB
        EX DE,HL                ; 3ABE
        CALL p39A6              ; 3ABF
        LD (HL),C               ; 3AC2
        INC HL                  ; 3AC3
        LD (HL),B               ; 3AC4
        RET                     ; 3AC5

p3AC6:  LD HL,(xw4025)          ; 3AC6
        PUSH DE                 ; 3AC9
        EX DE,HL                ; 3ACA
        LD A,E                  ; 3ACB
        AND 1FH                 ; 3ACC
        DEC DE                  ; 3ACE
        CP 04H                  ; 3ACF
        CALL Z,p3AE1            ; 3AD1
        LD HL,(xw401D)          ; 3AD4
        EX DE,HL                ; 3AD7
        LD (xw4025),HL          ; 3AD8
        EX DE,HL                ; 3ADB
        ADD HL,DE               ; 3ADC
        LD A,(HL)               ; 3ADD
        EX DE,HL                ; 3ADE
        POP DE                  ; 3ADF
        RET                     ; 3AE0

p3AE1:  LD A,E                  ; 3AE1
        AND 0E0H                ; 3AE2
        LD E,A                  ; 3AE4
        CALL p39A6              ; 3AE5
        LD A,E                  ; 3AE8
        OR 1FH                  ; 3AE9
        LD E,A                  ; 3AEB
        RET                     ; 3AEC

p3AED:  PUSH DE                 ; 3AED
        PUSH AF                 ; 3AEE
        EX DE,HL                ; 3AEF
        LD A,E                  ; 3AF0
        AND 1FH                 ; 3AF1
        CP 1FH                  ; 3AF3
        JP Z,p3AF9              ; 3AF5
        INC DE                  ; 3AF8
p3AF9:  CALL Z,p3A61            ; 3AF9
        EX DE,HL                ; 3AFC
        POP AF                  ; 3AFD
        POP DE                  ; 3AFE
        RET                     ; 3AFF

p3B00:  LD HL,(xw401F)          ; 3B00
        EX DE,HL                ; 3B03
        LD HL,(xw3FF8)          ; 3B04
        LD A,(xb3FFA)           ; 3B07
        OR A                    ; 3B0A
        JP NZ,p3B12             ; 3B0B
        LD HL,(xw4029)          ; 3B0E
        DEC H                   ; 3B11
p3B12:  CALL p3954              ; 3B12
        JP C,p0D6F              ; 3B15
        LD A,D                  ; 3B18
        OR A                    ; 3B19
        JP Z,p0D6F              ; 3B1A
        RRA                     ; 3B1D
        LD D,A                  ; 3B1E
        LD A,E                  ; 3B1F
        RRA                     ; 3B20
        LD E,A                  ; 3B21
        PUSH DE                 ; 3B22
        LD HL,(xw401D)          ; 3B23
        EX DE,HL                ; 3B26
        LD HL,(xw401F)          ; 3B27
        CALL p3954              ; 3B2A
        LD B,D                  ; 3B2D
        LD C,E                  ; 3B2E
        POP DE                  ; 3B2F
        LD HL,(xw401F)          ; 3B30
        EX DE,HL                ; 3B33
        ADD HL,DE               ; 3B34
        LD (xw401F),HL          ; 3B35
p3B38:  LD A,B                  ; 3B38
        OR C                    ; 3B39
        JP Z,p3B45              ; 3B3A
        DEC HL                  ; 3B3D
        DEC DE                  ; 3B3E
        LD A,(DE)               ; 3B3F
        LD (HL),A               ; 3B40
        DEC BC                  ; 3B41
        JP p3B38                ; 3B42

p3B45:  LD (xw401D),HL          ; 3B45
        RET                     ; 3B48

p3B49:  CALL p3B4F              ; 3B49
        JP p39CF                ; 3B4C

p3B4F:  PUSH DE                 ; 3B4F
        LD HL,(xw3D41)          ; 3B50
        EX DE,HL                ; 3B53
        LD HL,(xw401D)          ; 3B54
        CALL p3954              ; 3B57
        JP C,p0D6F              ; 3B5A
        LD A,D                  ; 3B5D
        CP 03H                  ; 3B5E
        JP C,p0D6F              ; 3B60
        RRA                     ; 3B63
        LD D,A                  ; 3B64
        LD A,E                  ; 3B65
        RRA                     ; 3B66
        LD E,A                  ; 3B67
        POP HL                  ; 3B68
        PUSH BC                 ; 3B69
        PUSH HL                 ; 3B6A
        LD HL,(xw401D)          ; 3B6B
        EX DE,HL                ; 3B6E
        EX (SP),HL              ; 3B6F
        CALL p3954              ; 3B70
        LD B,D                  ; 3B73
        LD C,E                  ; 3B74
        POP DE                  ; 3B75
        LD HL,(xw401D)          ; 3B76
        PUSH HL                 ; 3B79
        LD HL,(xw3D41)          ; 3B7A
        ADD HL,DE               ; 3B7D
        PUSH HL                 ; 3B7E
        LD (xw401D),HL          ; 3B7F
        ADD HL,BC               ; 3B82
        LD (xw401F),HL          ; 3B83
        POP HL                  ; 3B86
        POP DE                  ; 3B87
p3B88:  LD A,B                  ; 3B88
        OR C                    ; 3B89
        JP Z,p3B95              ; 3B8A
        DEC BC                  ; 3B8D
        LD A,(DE)               ; 3B8E
        LD (HL),A               ; 3B8F
        INC HL                  ; 3B90
        INC DE                  ; 3B91
        JP p3B88                ; 3B92

p3B95:  POP BC                  ; 3B95
        RET                     ; 3B96

p3B97:  LD (xb3EC1),A           ; 3B97
        LD (xb3EC2),A           ; 3B9A
        LD C,A                  ; 3B9D
        LD B,21H                ; 3B9E
p3BA0:  LD E,(HL)               ; 3BA0
        INC HL                  ; 3BA1
        LD D,(HL)               ; 3BA2
        INC HL                  ; 3BA3
        PUSH HL                 ; 3BA4
        PUSH BC                 ; 3BA5
        CALL p3BB7              ; 3BA6
        POP BC                  ; 3BA9
        POP HL                  ; 3BAA
        DEC B                   ; 3BAB
        JP NZ,p3BA0             ; 3BAC
        LD A,(xb3EC1)           ; 3BAF
        CP C                    ; 3BB2
        CALL NZ,p1A5A           ; 3BB3
        RET                     ; 3BB6

p3BB7:  LD BC,0000H             ; 3BB7
        PUSH BC                 ; 3BBA
        LD A,D                  ; 3BBB
        OR E                    ; 3BBC
        JP Z,p18C7              ; 3BBD
p3BC0:  EX DE,HL                ; 3BC0
        PUSH HL                 ; 3BC1
        LD E,(HL)               ; 3BC2
        INC HL                  ; 3BC3
        LD D,(HL)               ; 3BC4
        LD A,E                  ; 3BC5
        OR D                    ; 3BC6
        JP NZ,p3BC0             ; 3BC7
p3BCA:  POP HL                  ; 3BCA
        LD A,L                  ; 3BCB
        OR H                    ; 3BCC
        RET Z                   ; 3BCD
        CALL p3BE6              ; 3BCE
        DEC HL                  ; 3BD1
        DEC HL                  ; 3BD2
        LD D,(HL)               ; 3BD3
        DEC HL                  ; 3BD4
        LD E,(HL)               ; 3BD5
        LD A,E                  ; 3BD6
        OR D                    ; 3BD7
        JP Z,p3BCA              ; 3BD8
        XOR A                   ; 3BDB
        LD (HL),A               ; 3BDC
        INC HL                  ; 3BDD
        LD (HL),A               ; 3BDE
        DEC HL                  ; 3BDF
        DEC HL                  ; 3BE0
        DEC HL                  ; 3BE1
        PUSH HL                 ; 3BE2
        JP p3BC0                ; 3BE3

p3BE6:  LD BC,0004H             ; 3BE6
        ADD HL,BC               ; 3BE9
        LD B,(HL)               ; 3BEA
        INC HL                  ; 3BEB
        LD (xw3D3F),HL          ; 3BEC
        LD A,(HL)               ; 3BEF
        AND 40H                 ; 3BF0
        RET NZ                  ; 3BF2
        INC HL                  ; 3BF3
        LD A,(HL)               ; 3BF4
        AND 80H                 ; 3BF5
        CALL NZ,p3CD4           ; 3BF7
        LD A,(HL)               ; 3BFA
        INC HL                  ; 3BFB
        LD E,(HL)               ; 3BFC
        INC HL                  ; 3BFD
        LD D,(HL)               ; 3BFE
        PUSH BC                 ; 3BFF
        PUSH HL                 ; 3C00
        LD B,A                  ; 3C01
        AND 08H                 ; 3C02
        JP NZ,p3C35             ; 3C04
        PUSH BC                 ; 3C07
        CALL p3CC0              ; 3C08
        POP AF                  ; 3C0B
        LD E,A                  ; 3C0C
        AND 80H                 ; 3C0D
        JP NZ,p3C7F             ; 3C0F
        LD A,E                  ; 3C12
        AND 04H                 ; 3C13
        JP NZ,p3C85             ; 3C15
        LD A,E                  ; 3C18
        AND 40H                 ; 3C19
        CALL NZ,p3C90           ; 3C1B
        LD A,E                  ; 3C1E
        AND 0A0H                ; 3C1F
        JP Z,p3C88              ; 3C21
        LD A,E                  ; 3C24
        AND 03H                 ; 3C25
        LD E,A                  ; 3C27
        LD D,00H                ; 3C28
        LD HL,x1B66             ; 3C2A table
        ADD HL,DE               ; 3C2D
        LD A,(HL)               ; 3C2E
        CALL p4C76              ; 3C2F
p3C32:  CALL p3C7A              ; 3C32
p3C35:  POP HL                  ; 3C35
        POP BC                  ; 3C36
        INC HL                  ; 3C37
        INC HL                  ; 3C38
        INC HL                  ; 3C39
        PUSH BC                 ; 3C3A
p3C3B:  LD A,(HL)               ; 3C3B
        INC HL                  ; 3C3C
        CALL p4C76              ; 3C3D
        DEC B                   ; 3C40
        JP NZ,p3C3B             ; 3C41
        POP BC                  ; 3C44
        LD A,10H                ; 3C45
        SUB B                   ; 3C47
        JP NZ,p3C4C             ; 3C48
        INC A                   ; 3C4B
p3C4C:  LD B,A                  ; 3C4C
p3C4D:  CALL p3C75              ; 3C4D
        DEC B                   ; 3C50
        JP NZ,p3C4D             ; 3C51
        LD HL,xb3EC1            ; 3C54
        DEC (HL)                ; 3C57
        JP NZ,p3C6D             ; 3C58
        LD A,(xb3EC2)           ; 3C5B
        LD (HL),A               ; 3C5E
        CALL p1A5A              ; 3C5F
        LD HL,xb3D33            ; 3C62
        INC (HL)                ; 3C65
        LD A,(xb3D32)           ; 3C66
        CP (HL)                 ; 3C69
        CALL Z,p1A70            ; 3C6A
p3C6D:  LD HL,(xw3D3F)          ; 3C6D
        LD A,(HL)               ; 3C70
        OR 40H                  ; 3C71
        LD (HL),A               ; 3C73
        RET                     ; 3C74

p3C75:  LD A,20H                ; 3C75
        JP p3C7C                ; 3C77

p3C7A:  LD A,09H                ; 3C7A
p3C7C:  JP p4C76                ; 3C7C

p3C7F:  LD A,2AH                ; 3C7F
        DB 0CAH                 ; 3C81 (JP Z,4D3E)
        LD A,4DH                ; 3C82
        DB 0CAH                 ; 3C84 (JP Z,433E)
p3C85:  LD A,43H                ; 3C85
        DB 0CAH                 ; 3C87 (JP Z,553E)
p3C88:  LD A,55H                ; 3C88
        CALL p4C76              ; 3C8A
        JP p3C32                ; 3C8D

p3C90:  PUSH DE                 ; 3C90
        PUSH BC                 ; 3C91
        LD HL,(xw3D3F)          ; 3C92
        PUSH HL                 ; 3C95
        INC HL                  ; 3C96
        LD A,E                  ; 3C97
        AND 03H                 ; 3C98
        LD B,A                  ; 3C9A
        LD C,07H                ; 3C9B
        INC HL                  ; 3C9D
        LD E,(HL)               ; 3C9E
        INC HL                  ; 3C9F
        LD D,(HL)               ; 3CA0
        INC HL                  ; 3CA1
        PUSH DE                 ; 3CA2
        LD E,(HL)               ; 3CA3
        INC HL                  ; 3CA4
        LD D,(HL)               ; 3CA5
        EX DE,HL                ; 3CA6
        LD (xw3DDE),HL          ; 3CA7
        POP DE                  ; 3CAA
        CALL p1B83              ; 3CAB
        POP HL                  ; 3CAE
        LD (xw3D3F),HL          ; 3CAF
        INC HL                  ; 3CB2
        LD A,(HL)               ; 3CB3
        AND 20H                 ; 3CB4
        CALL NZ,p1BA9           ; 3CB6
        POP BC                  ; 3CB9
        POP DE                  ; 3CBA
        LD A,49H                ; 3CBB
        JP p4C76                ; 3CBD

p3CC0:  LD HL,xb3E11            ; 3CC0
        LD (xw3E0F),HL          ; 3CC3
        CALL p18C9              ; 3CC6
        LD HL,(xw3E0F)          ; 3CC9
        LD (HL),00H             ; 3CCC
        LD HL,xb3E11            ; 3CCE
        JP p1AD5                ; 3CD1

p3CD4:  PUSH BC                 ; 3CD4
        PUSH HL                 ; 3CD5
        LD A,(HL)               ; 3CD6
        AND 03H                 ; 3CD7
        LD B,A                  ; 3CD9
        LD C,06H                ; 3CDA
        INC HL                  ; 3CDC
        LD E,(HL)               ; 3CDD
        INC HL                  ; 3CDE
        LD D,(HL)               ; 3CDF
        CALL p1BA9              ; 3CE0
        POP HL                  ; 3CE3
        POP BC                  ; 3CE4
        RET                     ; 3CE5
;=====================================
xb3CE6: DB 0                    ; 3CE6
xb3CE7: DB 0                    ; 3CE7
xb3CE8: DB 0                    ; 3CE8
xb3CE9: DB 0                    ; 3CE9
xb3CEA: DB 0                    ; 3CEA
xb3CEB: DB 0                    ; 3CEB
xb3CEC: DB 0                    ; 3CEC
xw3CED: DW 0                    ; 3CED
xw3CEF: DW 0                    ; 3CEF
xb3CF1: DB 0                    ; 3CF1
xb3CF2: DB 0                    ; 3CF2
xb3CF3: DB 0                    ; 3CF3
xb3CF4: DB 0                    ; 3CF4
xb3CF5: DB 0                    ; 3CF5
xf3CF6: DS 50                   ; 3CF5 space
xb3D28: DB 0                    ; 3D28
xb3D29: DB 0                    ; 3D29
xb3D2A: DB 0                    ; 3D2A
xb3D2B: DB 0                    ; 3D2B
xb3D2C: DB 0                    ; 3D2C
xb3D2D: DB 0                    ; 3D2D
xb3D2E: DB 0                    ; 3D2E
xb3D2F: DB 0                    ; 3D2F
xb3D30: DB 0                    ; 3D30
xb3D31: DB 0                    ; 3D31
xb3D32: DB 0                    ; 3D32
xb3D33: DB 0                    ; 3D33
xw3D34: DW 0                    ; 3D34
xw3D36: DW 0                    ; 3D36
xb3D38: DB 0                    ; 3D38
xf3D39: DB 0,0,0,0,0,0          ; 3D39 space
xw3D3F: DW 0                    ; 3D3F
xw3D41: DW 0                    ; 3D41
xw3D43: DW 0                    ; 3D43
xb3D45: DB 0                    ; 3D45
xw3D46: DW 0                    ; 3D46 buf1 ptr
xf3D48: DS 130                  ; 3D47 buf1

xf3DCA: DB 0,0,0,0,0,0,0        ; 3DCA buf2
xb3DD1: DB 0                    ; 3DD1
xw3DD2: DW 0                    ; 3DD2
xw3DD4: DW 0                    ; 3DD4
xw3DD6: DW 0                    ; 3DD6
xw3DD8: DW 0                    ; 3DD8
xw3DDA: DW 0                    ; 3DDA
xw3DDC: DW 0                    ; 3DDC
xw3DDE: DW 0                    ; 3DDE
xw3DE0: DW 0                    ; 3DE0
xb3DE2: DB 0                    ; 3DE2
xb3DE3: DB 0                    ; 3DE3
xb3DE4: DB 0                    ; 3DE4
xw3DE5: DW 0                    ; 3DE5
xb3DE7: DB 0                    ; 3DE7
xb3DE8: DB 0                    ; 3DE8
xb3DE9: DB 0                    ; 3DE9
xb3DEA: DB 0                    ; 3DEA
xf3DEB: DS 17                   ; 3DEB buf3
xf3DFC: DS 19                   ; 3DFC buf4
xw3E0F: DW 0                    ; 3E0F
xb3E11: DB 0,0                  ; 3E11
xf3E13: DS 8                    ; 3E13 buf5
xf3E1B: DS 8                    ; 3E1B buf6
xf3E23: DS 4                    ; 3E23 buf7
xf3E27: DS 3                    ; 3E27 buf8
xb3E2A: DB 0                    ; 3E2A
xf3E2B: DB 0,0,0,0,0,0          ; 3E2B buf9
xf3E31: DS 80                   ; 3E31 buf10

xf3E81: DS 60                   ; 3E81 buf11
xb3EBD: DB 0                    ; 3EBD
xb3EBE: DB 0                    ; 3EBE
xw3EBF: DW 0                    ; 3EBF
xb3EC1: DB 0                    ; 3EC1
xb3EC2: DB 0                    ; 3EC2
xb3EC3: DB 0                    ; 3EC3
xb3EC4: DB 0                    ; 3EC4
xb3EC5: DB 0                    ; 3EC5
xb3EC6: DB 0                    ; 3EC6
xb3EC7: DB 0                    ; 3EC7
xw3EC8: DW 0                    ; 3EC8
xw3ECA: DW 0                    ; 3ECA
xb3ECC: DB 0                    ; 3ECC
xb3ECD: DB 0                    ; 3ECD
xf3ECE: DS 5                    ; 3ECE buf12
xb3ED3: DB 0                    ; 3ED3
xb3ED4: DB 0                    ; 3ED4
xf3ED5: DS 64                   ; 3ED5 buf13
xf3F15: DS 65                   ; 3F15 buf14
xb3F56: DB 0                    ; 3F56
xb3F57: DB 0                    ; 3F57
xb3F58: DB 0                    ; 3F58
xw3F59: DW 0                    ; 3F59
xb3F5B: DB 0                    ; 3F5B
xb3F5C: DB 0                    ; 3F5C
xf3F5D: DS 10                   ; 3F5D buf15
xf3F67: DB 0,0,0                ; 3F67 space
xf3F6A: DB 0,0,0                ; 3F6A space
xb3F6D: DB 0                    ; 3F6D
xw3F6E: DW 0                    ; 3F6E
xw3F70: DW 0                    ; 3F70

xf3F72: DS 66
xf3FB4: DS 66
xw3FF6: DW 0                    ; 3FF6
xw3FF8: DW 0                    ; 3FF8
xb3FFA: DB 0                    ; 3FFA
xb3FFB: DB 0                    ; 3FFB
xb3FFC: DB 0                    ; 3FFC
xw3FFD: DW 0                    ; 3FFD
xw3FFF: DW 0                    ; 3FFF
xw4001: DW 0                    ; 4001
xw4003: DW 0                    ; 4003
xb4005: DB 0                    ; 4005
xb4006: DB 0                    ; 4006
xw4007: DW 0                    ; 4007
xw4009: DW 0                    ; 4009
xw400B: DW 0                    ; 400B
xb400D: DB 0                    ; 400D
xb400E: DB 0                    ; 400E
xb400F: DB 0                    ; 400F
xb4010: DB 0                    ; 4010
xw4011: DW 0                    ; 4011
xw4013: DW 0                    ; 4013
xb4015: DB 0                    ; 4015
xw4016: DW 0                    ; 4016
xw4018: DW 0                    ; 4018
xb401A: DB 0                    ; 401A
xw401B: DW 0                    ; 401B
xw401D: DW 0                    ; 401D
xw401F: DW 0                    ; 401F
xw4021: DW 0                    ; 4021
xw4023: DW 0                    ; 4023
xw4025: DW 0                    ; 4025
xw4027: DW 0                    ; 4027
xw4029: DW 0                    ; 4029
;=====================================
xt402B: DB 51H,'A',07H
        DB 51H,'B',00H
        DB 51H,'C',01H
        DB 51H,'D',02H
        DB 51H,'E',03H
        DB 51H,'H',04H
        DB 51H,'L',05H
        DB 51H,'M',06H
        DB 62H,'SP',06H
        DB 63H,'PSW',06H
        DB 51H,'I',08H
        DB 51H,'R',09H
        DB 62H,'BC',00H
        DB 62H,'DE',02H
        DB 62H,'HL',04H
        DB 62H,'AF',06H
        DB 6AH,'IX',44H
        DB 6AH,'IY',64H
        DB 72H,'NZ',00H
        DB 71H,'Z',01H
        DB 72H,'NC',02H
        DB 71H,'P',06H
        DB 72H,'PO',04H
        DB 72H,'PE',05H
        DB 0
;=====================================
xb4081: DB 0                    ; 4081
xw4082: DW 0                    ; 4082
xb4084: DB 0                    ; 4084
xb4085: DB 0                    ; 4085
xb4086: DB 0                    ; 4086
xb4087: DB 0                    ; 4087
xb4088: DB 0                    ; 4088
xb4089: DB 0                    ; 4089
xb408A: DB 0                    ; 408A
xb408B: DB 0                    ; 408B
xb408C: DB 0                    ; 408C
xb408D: DB 0                    ; 408D
xb408E: DB 0                    ; 408E
xb408F: DB 0                    ; 408F
xb4090: DB 0                    ; 4090
xb4091: DB 0                    ; 4091
xb4092: DB 0                    ; 4092
xf4093: DS 33                   ; 4093 buffer
xf40B4: DS 9                    ; 40B4 buffer
xf40BD: DS 24                   ; 40BD buffer
xf40D5: DS 87                   ; 40D5 FCB address
xb412C: DB 0                    ; 412C
xf412D: DS 8                    ; 412D buffer
xf4135: DB 0,0,0                ; 4135

xs4138: DB 'REL'
xs413B: DB 'CRF'
xs413E: DB 'PRN'

xb4141: DB 0                    ; 4141
xb4142: DB 0                    ; 4142

xf4143: DS 256                  ; 4143

xb4243: DB 0                    ; 4243
xb4244: DB 0                    ; 4244

xf4245: DS 512

xb4445: DB 0                    ; 4445
xb4446: DB 0                    ; 4446
xf4447: DS 10                   ; 4447
xf4451: DS 502                  ; 4451
xb4647: DB 50H                  ; 4647
xb4648: DB 00H                  ; 4648
xf4649: DS 80                   ; 4649

xw4699: DW 0                    ; 4699
;=====================================
xs469B: DB "?Command error",0
xs46AA: DB "?File not found",0
xs46BA: DB "?Can't enter file",0
;=====================================
p46CC:  LD A,(HL)               ; 46CC
        AND 7FH                 ; 46CD
        RET Z                   ; 46CF
        CALL p4AEE              ; 46D0
        INC HL                  ; 46D3
        JP p46CC                ; 46D4

p46D7:  LD HL,xs469B            ; 46D7 message
        JP p46E6                ; 46DA

p46DD:  LD HL,xs46AA            ; 46DD message
        JP p46E6                ; 46E0

p46E3:  LD HL,xs46BA            ; 46E3 message
p46E6:  CALL p46CC              ; 46E6
        JP p4758                ; 46E9

        DB "COMSCN"             ; 46EC

x46F2:  DB 00H                  ; 46F2 cold start flag
        DS 23
xb470A: DB 0F2H                 ; Address 46F2
xb470B: DB 46H

; Start up code

p470C:  LD (xb412C),HL          ; 470C save address
        LD DE,x46F2             ; 470F
        LD A,(DE)               ; 4712
        OR A                    ; 4713 cold start?
        JP Z,p473C              ; 4714 yes - jump
        LD A,(xb470B)           ; 4717
        LD B,A                  ; 471A
p471B:  LD A,(xb470A)           ; 471B
        LD C,A                  ; 471E
        LD HL,(p0006)           ; 471F address in CP/M call
        LD L,00H                ; 4722
p4724:  LD A,(DE)               ; 4724
        CP (HL)                 ; 4725
        JP NZ,p4732             ; 4726
        INC HL                  ; 4729
        INC DE                  ; 472A
        DEC C                   ; 472B
        JP NZ,p4724             ; 472C
        JP p473C                ; 472F

p4732:  INC DE                  ; 4732
        DEC C                   ; 4733
        JP NZ,p4732             ; 4734
        DEC B                   ; 4737
        RET Z                   ; 4738
        JP p471B                ; 4739

p473C:  XOR A                   ; 473C
        LD (x46F2),A            ; 473D
        LD HL,(p0006)           ; 4740 address in CP/M call
        DEC HL                  ; 4743
        LD SP,HL                ; 4744 init. stack
        DEC HL                  ; 4745
        DEC HL                  ; 4746
        LD (xw4082),HL          ; 4747
        LD HL,(xb412C)          ; 474A
        PUSH HL                 ; 474D
        LD A,(xb408E)           ; 474E
        OR A                    ; 4751
        JP NZ,p0000             ; 4752
        LD (xb4085),A           ; 4755
p4758:  LD HL,(xw4082)          ; 4758
        LD SP,HL                ; 475B
        CALL p4A4B              ; 475C
        LD A,(xf4649)           ; 475F
        CP 0DH                  ; 4762
        JP Z,p4758              ; 4764
        XOR A                   ; 4767 clear data
        LD (xb4092),A           ; 4768
        LD (xb4089),A           ; 476B
        LD (xb4090),A           ; 476E
        LD (xb408F),A           ; 4771
        LD (xb408C),A           ; 4774
        LD (xb408D),A           ; 4777
        LD (xb408B),A           ; 477A
        LD (xb4091),A           ; 477D
        INC A                   ; 4780
        LD (xb408A),A           ; 4781
        LD (xb4088),A           ; 4784
        LD BC,p46D7             ; 4787 spoofed return address
        PUSH BC                 ; 478A
        XOR A                   ; 478B
        LD (xb4081),A           ; 478C
        CALL p48E1              ; 478F
        RET C                   ; 4792
        LD DE,xs4138            ; 4793 'REL'
        CALL p48C4              ; 4796
        LD DE,xf412D            ; 4799
        LD A,(DE)               ; 479C
        CP 20H                  ; 479D
        JP NZ,p47A7             ; 479F
        LD A,80H                ; 47A2
        LD (xb4081),A           ; 47A4
p47A7:  PUSH HL                 ; 47A7
        LD HL,xf4093            ; 47A8 address
        CALL p48B8              ; 47AB
        POP HL                  ; 47AE
        LD A,20H                ; 47AF
        LD (xf412D),A           ; 47B1
        LD (xf4135),A           ; 47B4
        XOR A                   ; 47B7
        LD (xb412C),A           ; 47B8
        LD A,C                  ; 47BB
        SUB 2CH                 ; 47BC
        OR A                    ; 47BE
        LD (xb408B),A           ; 47BF
        JP NZ,p47D1             ; 47C2
        LD A,(xb4081)           ; 47C5
        XOR 80H                 ; 47C8
        LD (xb408B),A           ; 47CA
        CALL p48E1              ; 47CD
        RET C                   ; 47D0
p47D1:  LD DE,xs413E            ; 47D1 'PRN'
        LD A,(xb408C)           ; 47D4
        OR A                    ; 47D7
        JP Z,p47DE              ; 47D8
        LD DE,xs413B            ; 47DB 'CRF'
p47DE:  CALL p48C4              ; 47DE
        LD DE,xf412D            ; 47E1
        LD A,(xb412C)           ; 47E4
        LD (xb4087),A           ; 47E7
        LD A,(DE)               ; 47EA
        SUB 20H                 ; 47EB
        LD (xb4086),A           ; 47ED
        JP NZ,p47FB             ; 47F0
        LD A,(xb4081)           ; 47F3
        ADD A,40H               ; 47F6
        LD (xb4081),A           ; 47F8
p47FB:  PUSH HL                 ; 47FB
        LD HL,xf40B4            ; 47FC
        CALL p48B8              ; 47FF
        POP HL                  ; 4802
        LD A,C                  ; 4803
        CP 3DH                  ; 4804
        SCF                     ; 4806
        RET NZ                  ; 4807
        CALL p48E1              ; 4808
        CP 0DH                  ; 480B
        SCF                     ; 480D
        RET NZ                  ; 480E
        LD DE,xs0106            ; 480F 'MAC'
        CALL p48C4              ; 4812
        LD DE,xb412C            ; 4815
        LD A,(DE)               ; 4818
        INC DE                  ; 4819
        OR A                    ; 481A
        JP M,p4823              ; 481B
        LD A,(DE)               ; 481E
        CP 20H                  ; 481F
        SCF                     ; 4821
        RET Z                   ; 4822
p4823:  PUSH HL                 ; 4823
        LD HL,xf40D5            ; 4824 address
        CALL p48B8              ; 4827
        POP HL                  ; 482A
        LD A,(xb4081)           ; 482B
        ADD A,A                 ; 482E
        LD HL,xf4093            ; 482F address
        CALL C,p4898            ; 4832
        ADD A,A                 ; 4835
        LD HL,xf40B4            ; 4836
        PUSH AF                 ; 4839
        LD A,(xb408C)           ; 483A
        OR A                    ; 483D
        JP Z,p4853              ; 483E
        LD DE,xf40BD            ; 4841 address
        LD BC,xs413B            ; 4844 'CRF'
        LD A,03H                ; 4847
p4849:  PUSH AF                 ; 4849
        LD A,(BC)               ; 484A
        LD (DE),A               ; 484B
        INC DE                  ; 484C
        INC BC                  ; 484D
        POP AF                  ; 484E
        DEC A                   ; 484F
        JP NZ,p4849             ; 4850
p4853:  POP AF                  ; 4853
        CALL C,p4898            ; 4854
        LD A,(xb4089)           ; 4857
        OR A                    ; 485A
        JP NZ,p4868             ; 485B
        LD A,(xb4086)           ; 485E
        OR A                    ; 4861
        JP NZ,p4868             ; 4862
        LD A,(xb4087)           ; 4865
p4868:  LD (xb4089),A           ; 4868

; Return current disk

        LD C,25                 ; 486B
        CALL p0005              ; 486D
        PUSH AF                 ; 4870

; Reset disk system

        LD C,13                 ; 4871
        CALL p0005              ; 4873
        POP AF                  ; 4876
        LD E,A                  ; 4877

; Select disk

        LD C,14                 ; 4878
        CALL p0005              ; 487A
        XOR A                   ; 487D
        LD (x0080),A            ; 487E
        CALL p4B84              ; 4881
        CALL p4B25              ; 4884
        CALL p4B3B              ; 4887
        POP HL                  ; 488A
        LD HL,(xw4082)          ; 488B
        INC HL                  ; 488E
        INC HL                  ; 488F
        LD A,(xb408A)           ; 4890
        LD (xb4085),A           ; 4893
        LD B,A                  ; 4896
        RET                     ; 4897

p4898:  PUSH AF                 ; 4898
        LD DE,xb412C            ; 4899
        LD C,09H                ; 489C
        LD A,(HL)               ; 489E
        OR A                    ; 489F
        JP NZ,p48B2             ; 48A0
        LD A,(DE)               ; 48A3
        OR A                    ; 48A4
        JP M,p48B2              ; 48A5
p48A8:  LD A,(DE)               ; 48A8
        LD (HL),A               ; 48A9
        INC HL                  ; 48AA
        INC DE                  ; 48AB
        DEC C                   ; 48AC
        JP NZ,p48A8             ; 48AD
p48B0:  POP AF                  ; 48B0
        RET                     ; 48B1

p48B2:  DEC C                   ; 48B2
        INC HL                  ; 48B3
        INC DE                  ; 48B4
        JP p48A8                ; 48B5

p48B8:  DEC DE                  ; 48B8
        LD B,0CH                ; 48B9
p48BB:  LD A,(DE)               ; 48BB
        LD (HL),A               ; 48BC
        INC HL                  ; 48BD
        INC DE                  ; 48BE
        DEC B                   ; 48BF
        JP NZ,p48BB             ; 48C0
        RET                     ; 48C3

p48C4:  LD A,(xb4084)           ; 48C4
        OR A                    ; 48C7
        RET Z                   ; 48C8
        PUSH HL                 ; 48C9
        LD HL,xf4135            ; 48CA
        LD A,(HL)               ; 48CD
        CP 20H                  ; 48CE
        JP NZ,p48DF             ; 48D0
        LD B,03H                ; 48D3
p48D5:  LD A,(DE)               ; 48D5
        AND 7FH                 ; 48D6
        LD (HL),A               ; 48D8
        INC HL                  ; 48D9
        INC DE                  ; 48DA
        DEC B                   ; 48DB
        JP NZ,p48D5             ; 48DC
p48DF:  POP HL                  ; 48DF
        RET                     ; 48E0

p48E1:  CALL p4A2A              ; 48E1
        CP 3AH                  ; 48E4
        SCF                     ; 48E6
        LD A,00H                ; 48E7
        JP NZ,p4905             ; 48E9
        LD A,B                  ; 48EC
        OR A                    ; 48ED
        JP Z,p48E1              ; 48EE
        EX DE,HL                ; 48F1
        CALL p4AD7              ; 48F2
        LD C,A                  ; 48F5
        LD A,B                  ; 48F6
        DEC A                   ; 48F7
        LD A,C                  ; 48F8
        JP NZ,p4926             ; 48F9
        CP 5BH                  ; 48FC
        RET NC                  ; 48FE
        CP 41H                  ; 48FF
        RET C                   ; 4901
        SUB 40H                 ; 4902
        EX DE,HL                ; 4904
p4905:  LD (xb412C),A           ; 4905
        CALL NC,p4A2A           ; 4908
        LD A,B                  ; 490B
        CP 0BH                  ; 490C
        JP C,p4913              ; 490E
        LD B,0BH                ; 4911
p4913:  PUSH BC                 ; 4913
        EX DE,HL                ; 4914
        PUSH DE                 ; 4915
        LD DE,xf412D            ; 4916
        INC B                   ; 4919
p491A:  DEC B                   ; 491A
        JP Z,p496F              ; 491B
        CALL p4AD7              ; 491E
        LD (DE),A               ; 4921
        INC DE                  ; 4922
        JP p491A                ; 4923

p4926:  CP 54H                  ; 4926
        JP NZ,p493F             ; 4928
        CALL p4AD7              ; 492B
        CP 54H                  ; 492E
        SCF                     ; 4930
        RET NZ                  ; 4931
        CALL p4AD7              ; 4932
        CP 59H                  ; 4935
        SCF                     ; 4937
        RET NZ                  ; 4938
        SBC A,A                 ; 4939
        EX DE,HL                ; 493A
        OR A                    ; 493B
        JP p4905                ; 493C

p493F:  CP 4CH                  ; 493F
        JP NZ,p4959             ; 4941
        CALL p4AD7              ; 4944
        CP 53H                  ; 4947
        SCF                     ; 4949
        RET NZ                  ; 494A
        CALL p4AD7              ; 494B
        CP 54H                  ; 494E
        SCF                     ; 4950
        RET NZ                  ; 4951
        LD A,0FEH               ; 4952
        EX DE,HL                ; 4954
        OR A                    ; 4955
        JP p4905                ; 4956

p4959:  CP 52H                  ; 4959
        SCF                     ; 495B
        RET NZ                  ; 495C
        CALL p4AD7              ; 495D
        CP 44H                  ; 4960
        SCF                     ; 4962
        RET NZ                  ; 4963
        CP 52H                  ; 4964
        SCF                     ; 4966
        RET NZ                  ; 4967
        LD A,0FEH               ; 4968
        EX DE,HL                ; 496A
        OR A                    ; 496B
        JP p4905                ; 496C

p496F:  POP HL                  ; 496F
        POP BC                  ; 4970
        LD A,0AH                ; 4971
        SUB B                   ; 4973
        JP C,p4980              ; 4974
        EX DE,HL                ; 4977
p4978:  LD (HL),20H             ; 4978
        INC HL                  ; 497A
        DEC A                   ; 497B
        JP P,p4978              ; 497C
        EX DE,HL                ; 497F
p4980:  LD A,C                  ; 4980
        LD B,00H                ; 4981
        SUB 2EH                 ; 4983
        LD (xb4084),A           ; 4985
        CALL Z,p4A2A            ; 4988
        EX DE,HL                ; 498B
        PUSH DE                 ; 498C
        LD DE,xf4135            ; 498D
        LD A,B                  ; 4990
        CP 04H                  ; 4991
        JP C,p4998              ; 4993
        LD B,03H                ; 4996
p4998:  INC B                   ; 4998
p4999:  DEC B                   ; 4999
        JP Z,p49A5              ; 499A
        CALL p4AD7              ; 499D
        LD (DE),A               ; 49A0
        INC DE                  ; 49A1
        JP p4999                ; 49A2

p49A5:  POP HL                  ; 49A5
p49A6:  LD A,C                  ; 49A6
        SUB 2FH                 ; 49A7
        OR A                    ; 49A9
        LD A,C                  ; 49AA
        RET NZ                  ; 49AB
        CALL p4AD7              ; 49AC
        CP 4CH                  ; 49AF
        JP NZ,p49BE             ; 49B1
        LD (xb4089),A           ; 49B4
p49B7:  CALL p4AD7              ; 49B7
        LD C,A                  ; 49BA
        JP p49A6                ; 49BB

p49BE:  CP 4EH                  ; 49BE
        JP NZ,p49C9             ; 49C0
        LD (xb4090),A           ; 49C3
        JP p49B7                ; 49C6

p49C9:  CP 4FH                  ; 49C9
        JP NZ,p49D4             ; 49CB
        LD (xb408F),A           ; 49CE
        JP p49B7                ; 49D1

p49D4:  CP 52H                  ; 49D4
        JP NZ,p49DF             ; 49D6
        LD (xb408B),A           ; 49D9
        JP p49B7                ; 49DC

p49DF:  CP 43H                  ; 49DF
        JP NZ,p49ED             ; 49E1
        LD (xb408C),A           ; 49E4
        LD (xb4089),A           ; 49E7
        JP p49B7                ; 49EA

p49ED:  CP 4DH                  ; 49ED
        JP NZ,p49F8             ; 49EF
        LD (xb4091),A           ; 49F2
        JP p49B7                ; 49F5

p49F8:  CP 49H                  ; 49F8
        JP NZ,p4A03             ; 49FA
        LD (xb4088),A           ; 49FD
        JP p49B7                ; 4A00

p4A03:  CP 58H                  ; 4A03
        JP NZ,p4A10             ; 4A05
        LD A,0FFH               ; 4A08
        LD (xb408D),A           ; 4A0A
        JP p49B7                ; 4A0D

p4A10:  CP 5AH                  ; 4A10
        JP NZ,p4A1C             ; 4A12
        XOR A                   ; 4A15
        LD (xb4088),A           ; 4A16
        JP p49B7                ; 4A19

p4A1C:  CP 50H                  ; 4A1C
        SCF                     ; 4A1E
        RET NZ                  ; 4A1F
        LD A,(xb408A)           ; 4A20
        INC A                   ; 4A23
        LD (xb408A),A           ; 4A24
        JP p49B7                ; 4A27

p4A2A:  LD B,00H                ; 4A2A
        PUSH HL                 ; 4A2C
p4A2D:  CALL p4AD7              ; 4A2D
        CP 5BH                  ; 4A30
        JP NC,p4A48             ; 4A32
        CP 30H                  ; 4A35
        JP C,p4A48              ; 4A37
        CP 41H                  ; 4A3A
        JP NC,p4A44             ; 4A3C
        CP 3AH                  ; 4A3F
        JP NC,p4A48             ; 4A41
p4A44:  INC B                   ; 4A44
        JP p4A2D                ; 4A45

p4A48:  LD C,A                  ; 4A48
        POP DE                  ; 4A49
        RET                     ; 4A4A

p4A4B:  PUSH BC                 ; 4A4B
        PUSH DE                 ; 4A4C
        LD HL,0080H             ; 4A4D
        LD A,(HL)               ; 4A50
        LD (HL),00H             ; 4A51
        OR A                    ; 4A53
        LD B,A                  ; 4A54
p4A55:  JP Z,p4A7A              ; 4A55
        INC HL                  ; 4A58
        LD A,(HL)               ; 4A59
        CP 20H                  ; 4A5A
        JP NZ,p4A63             ; 4A5C
        DEC B                   ; 4A5F
        JP p4A55                ; 4A60

p4A63:  LD DE,xb4648            ; 4A63
        LD A,B                  ; 4A66
        DEC HL                  ; 4A67
        INC B                   ; 4A68
p4A69:  LD (DE),A               ; 4A69
        INC DE                  ; 4A6A
        INC HL                  ; 4A6B
        DEC B                   ; 4A6C
        JP Z,p4A74              ; 4A6D
        LD A,(HL)               ; 4A70
        JP p4A69                ; 4A71

p4A74:  LD (xb408E),A           ; 4A74
        JP p4A9A                ; 4A77

p4A7A:  XOR A                   ; 4A7A
        LD (xb408E),A           ; 4A7B
        LD A,(xb4085)           ; 4A7E
        OR A                    ; 4A81
        JP NZ,p4A8D             ; 4A82
        CALL p4B1B              ; 4A85
        LD A,2AH                ; 4A88
        CALL p4AEE              ; 4A8A

; Read console buffer

p4A8D:  LD C,10                 ; 4A8D
        LD DE,xb4647            ; 4A8F
        CALL p0005              ; 4A92
        LD A,0AH                ; 4A95
        CALL p4AEE              ; 4A97
p4A9A:  POP DE                  ; 4A9A
        POP BC                  ; 4A9B
        LD A,(xb4648)           ; 4A9C
        LD HL,xf4649            ; 4A9F
        PUSH HL                 ; 4AA2
        LD (xw4699),HL          ; 4AA3
        ADD A,L                 ; 4AA6
        LD L,A                  ; 4AA7
        LD A,00H                ; 4AA8
        ADC A,H                 ; 4AAA
        LD H,A                  ; 4AAB
        LD (HL),0DH             ; 4AAC
        INC HL                  ; 4AAE
        LD A,0AH                ; 4AAF
        LD (HL),A               ; 4AB1
        POP HL                  ; 4AB2
        LD A,(xb4085)           ; 4AB3
        OR A                    ; 4AB6
        JP NZ,p4AD6             ; 4AB7
        PUSH HL                 ; 4ABA
        LD HL,xf4649            ; 4ABB
p4ABE:  LD A,(HL)               ; 4ABE
        CP 0DH                  ; 4ABF
        JP Z,p4AD5              ; 4AC1
        SUB 61H                 ; 4AC4
        JP C,p4AD1              ; 4AC6
        CP 1AH                  ; 4AC9
        JP NC,p4AD1             ; 4ACB
        ADD A,41H               ; 4ACE
        LD (HL),A               ; 4AD0
p4AD1:  INC HL                  ; 4AD1
        JP p4ABE                ; 4AD2

p4AD5:  POP HL                  ; 4AD5
p4AD6:  RET                     ; 4AD6

p4AD7:  LD A,(HL)               ; 4AD7
        INC HL                  ; 4AD8
        CP 20H                  ; 4AD9
        JP Z,p4AD7              ; 4ADB
        CP 0AH                  ; 4ADE
        JP Z,p4AD7              ; 4AE0
        CP 0DH                  ; 4AE3
        JP NZ,p4B15             ; 4AE5
        INC HL                  ; 4AE8
        LD (xw4699),HL          ; 4AE9
        RET                     ; 4AEC

p4AED:  POP AF                  ; 4AED
p4AEE:  PUSH HL                 ; 4AEE
        PUSH DE                 ; 4AEF
        PUSH BC                 ; 4AF0
        PUSH AF                 ; 4AF1

; Console output

        LD C,2                  ; 4AF2
        AND 7FH                 ; 4AF4
        LD E,A                  ; 4AF6
        CALL p0005              ; 4AF7
        POP AF                  ; 4AFA
        POP BC                  ; 4AFB
        POP DE                  ; 4AFC
        POP HL                  ; 4AFD
        OR A                    ; 4AFE
        RET                     ; 4AFF

p4B00:  PUSH HL                 ; 4B00
        LD HL,(xw4699)          ; 4B01
        DEC HL                  ; 4B04
        LD A,(HL)               ; 4B05
        AND 7FH                 ; 4B06
        CP 0AH                  ; 4B08
        INC HL                  ; 4B0A
        CALL Z,p4A4B            ; 4B0B
        INC HL                  ; 4B0E
        LD (xw4699),HL          ; 4B0F
        DEC HL                  ; 4B12
p4B13:  LD A,(HL)               ; 4B13
        POP HL                  ; 4B14
p4B15:  CP 1AH                  ; 4B15
        SCF                     ; 4B17
        RET Z                   ; 4B18
        OR A                    ; 4B19
        RET                     ; 4B1A

p4B1B:  LD A,CR                 ; 4B1B <CR>
        CALL p4AEE              ; 4B1D
        LD A,LF                 ; 4B20 <LF>
        JP p4AEE                ; 4B22

p4B25:  PUSH AF                 ; 4B25
        PUSH BC                 ; 4B26
        PUSH DE                 ; 4B27
        PUSH HL                 ; 4B28
        LD DE,xf4245            ; 4B29 Disk sector buffer
        LD HL,0000H             ; 4B2C
        LD (xb4243),HL          ; 4B2F
        LD HL,xf40B4            ; 4B32
        LD A,(xb4089)           ; 4B35
        JP p4B4E                ; 4B38

p4B3B:  PUSH AF                 ; 4B3B
        PUSH BC                 ; 4B3C
        PUSH DE                 ; 4B3D
        PUSH HL                 ; 4B3E
        LD DE,xf4143            ; 4B3F
        LD HL,0000H             ; 4B42
        LD (xb4141),HL          ; 4B45
        LD HL,xf4093            ; 4B48 address
        LD A,(xb408B)           ; 4B4B
p4B4E:  OR A                    ; 4B4E
        JP Z,p4B7F              ; 4B4F
        PUSH HL                 ; 4B52

; Set DMA address

        LD C,26                 ; 4B53
        CALL p0005              ; 4B55
        POP HL                  ; 4B58
        LD A,(HL)               ; 4B59
        OR A                    ; 4B5A
        JP M,p4B7F              ; 4B5B
        CALL p4BA1              ; 4B5E
        PUSH DE                 ; 4B61

; Delete file

        LD C,19                 ; 4B62
        CALL p0005              ; 4B64
        POP DE                  ; 4B67
        PUSH DE                 ; 4B68

; Create file

        LD C,22                 ; 4B69
        CALL p0005              ; 4B6B
        INC A                   ; 4B6E
        JP Z,p46E3              ; 4B6F
        POP HL                  ; 4B72
p4B73:  CALL p4BA1              ; 4B73

; Open file

        LD C,15                 ; 4B76
        CALL p0005              ; 4B78
        INC A                   ; 4B7B
        JP Z,p46DD              ; 4B7C
p4B7F:  POP HL                  ; 4B7F
        POP DE                  ; 4B80
        POP BC                  ; 4B81
        POP AF                  ; 4B82
        RET                     ; 4B83

p4B84:  PUSH AF                 ; 4B84
        PUSH BC                 ; 4B85
        PUSH DE                 ; 4B86
        PUSH HL                 ; 4B87
        LD HL,0200H             ; 4B88
        LD (xb4445),HL          ; 4B8B
        LD DE,xf4447            ; 4B8E DMA buffer

; Set DMA address

        LD C,26                 ; 4B91
        CALL p0005              ; 4B93
        LD HL,xf40D5            ; 4B96 address
        LD A,(HL)               ; 4B99
        OR A                    ; 4B9A
        JP M,p4B7F              ; 4B9B
        JP p4B73                ; 4B9E

p4BA1:  PUSH HL                 ; 4BA1
        PUSH DE                 ; 4BA2
        LD DE,000CH             ; 4BA3
        ADD HL,DE               ; 4BA6
        XOR A                   ; 4BA7
        LD D,04H                ; 4BA8
p4BAA:  LD (HL),A               ; 4BAA
        INC HL                  ; 4BAB
        DEC D                   ; 4BAC
        JP NZ,p4BAA             ; 4BAD
        LD DE,0010H             ; 4BB0
        ADD HL,DE               ; 4BB3
        LD (HL),A               ; 4BB4
        POP HL                  ; 4BB5
        POP DE                  ; 4BB6
        RET                     ; 4BB7

p4BB8:  PUSH AF                 ; 4BB8
        PUSH DE                 ; 4BB9
        LD DE,xf40D5            ; 4BBA FCB address
        LD A,(DE)               ; 4BBD
        OR A                    ; 4BBE
        JP M,p4BD8              ; 4BBF
        PUSH BC                 ; 4BC2
        PUSH HL                 ; 4BC3
        PUSH DE                 ; 4BC4

; Set DMA address

        LD DE,xf4447            ; 4BC5 DMA buffer
        LD C,26                 ; 4BC8
        CALL p0005              ; 4BCA
        POP DE                  ; 4BCD

; Close disk file

        DB 01H                  ; 4BCE (LD BC,0E5C5H)
p4BCF:  PUSH BC                 ; 4BCF
        PUSH HL                 ; 4BD0
        LD C,16                 ; 4BD1
        CALL p0005              ; 4BD3
        POP HL                  ; 4BD6
        POP BC                  ; 4BD7
p4BD8:  POP DE                  ; 4BD8
        POP AF                  ; 4BD9
        RET                     ; 4BDA

p4BDB:  PUSH AF                 ; 4BDB
        LD A,(xb4089)           ; 4BDC
        OR A                    ; 4BDF
        JP Z,p48B0              ; 4BE0
        PUSH DE                 ; 4BE3
        LD A,(xf40B4)           ; 4BE4
        INC A                   ; 4BE7
        JP Z,p4BD8              ; 4BE8
        JP M,p4C64              ; 4BEB
        LD A,CR                 ; 4BEE
        CALL p4C76              ; 4BF0
        LD A,LF                 ; 4BF3
        CALL p4C76              ; 4BF5
        LD A,1AH                ; 4BF8 ^Z
        CALL p4C76              ; 4BFA
        PUSH HL                 ; 4BFD
        LD HL,(xb4243)          ; 4BFE
        LD DE,xf4245            ; 4C01 Disk sector buffer
        PUSH BC                 ; 4C04
        LD BC,xf40B4            ; 4C05
        CALL p4C4E              ; 4C08

; Set DMA address

        LD DE,xf4245            ; 4C0B DMA Address
        LD C,26                 ; 4C0E
        CALL p0005              ; 4C10
        POP BC                  ; 4C13
        POP HL                  ; 4C14
        LD DE,xf40B4            ; 4C15
        JP p4BCF                ; 4C18

p4C1B:  PUSH AF                 ; 4C1B
        LD A,(xb408B)           ; 4C1C
        OR A                    ; 4C1F
        JP Z,p48B0              ; 4C20
        PUSH DE                 ; 4C23
        LD A,(xf4093)           ; 4C24
        OR A                    ; 4C27
        JP M,p4BD8              ; 4C28
        LD A,1AH                ; 4C2B
        CALL p4CDD              ; 4C2D
        PUSH HL                 ; 4C30
        LD HL,(xb4141)          ; 4C31
        LD DE,xf4143            ; 4C34
        PUSH BC                 ; 4C37
        LD BC,xf4093            ; 4C38
        CALL p4C4E              ; 4C3B
        LD DE,xf4143            ; 4C3E

; Set DMA address

        LD C,26                 ; 4C41
        CALL p0005              ; 4C43
        POP BC                  ; 4C46
        POP HL                  ; 4C47
        LD DE,xf4093            ; 4C48
        JP p4BCF                ; 4C4B

p4C4E:  LD A,H                  ; 4C4E
        OR L                    ; 4C4F
        RET Z                   ; 4C50 Return when HL == 0
        LD A,L                  ; 4C51
        AND 7FH                 ; 4C52
        JP Z,p4C59              ; 4C54
        ADD A,80H               ; 4C57
p4C59:  RLA                     ; 4C59
        RLA                     ; 4C5A
        AND 03H                 ; 4C5B
        ADD HL,HL               ; 4C5D
        ADD A,H                 ; 4C5E
        LD H,B                  ; 4C5F
        LD L,C                  ; 4C60
        JP p4CAD                ; 4C61

p4C64:  LD A,CR                 ; 4C64
        CALL p4C76              ; 4C66
        LD A,LF                 ; 4C69
        CALL p4C76              ; 4C6B
        LD A,0CH                ; 4C6E form feed
        CALL p4C76              ; 4C70
        POP DE                  ; 4C73
        POP AF                  ; 4C74
        RET                     ; 4C75

p4C76:  PUSH AF                 ; 4C76
        LD A,(xb4089)           ; 4C77
        OR A                    ; 4C7A
        JP Z,p48B0              ; 4C7B
        LD A,(xf40B4)           ; 4C7E
        INC A                   ; 4C81
        JP Z,p4AED              ; 4C82
        JP M,p4D55              ; 4C85
        EX (SP),HL              ; 4C88
        PUSH HL                 ; 4C89
        PUSH DE                 ; 4C8A
        LD HL,(xb4243)          ; 4C8B
        LD A,H                  ; 4C8E
        CP 02H                  ; 4C8F
        CALL Z,p4CA5            ; 4C91
        INC HL                  ; 4C94
        LD (xb4243),HL          ; 4C95
        LD DE,xb4244            ; 4C98
        ADD HL,DE               ; 4C9B
        POP DE                  ; 4C9C
        POP AF                  ; 4C9D
        PUSH AF                 ; 4C9E
        AND 7FH                 ; 4C9F
        LD (HL),A               ; 4CA1
        POP AF                  ; 4CA2
        POP HL                  ; 4CA3
        RET                     ; 4CA4

p4CA5:  LD DE,xf4245            ; 4CA5 DMA address
        LD HL,xf40B4            ; 4CA8
        LD A,04H                ; 4CAB
p4CAD:  PUSH AF                 ; 4CAD
        PUSH BC                 ; 4CAE
        PUSH DE                 ; 4CAF
        PUSH HL                 ; 4CB0

; Set DMA address

        LD C,26                 ; 4CB1
        CALL p0005              ; 4CB3
        POP DE                  ; 4CB6
        PUSH DE                 ; 4CB7

; Write sequential to disk

        LD C,21                 ; 4CB8
        CALL p0005              ; 4CBA
        OR A                    ; 4CBD
        JP NZ,p4DA1             ; 4CBE
        POP DE                  ; 4CC1
        POP HL                  ; 4CC2
        LD BC,0080H             ; 4CC3
        ADD HL,BC               ; 4CC6
        EX DE,HL                ; 4CC7
        POP BC                  ; 4CC8
        POP AF                  ; 4CC9
        DEC A                   ; 4CCA
        JP NZ,p4CAD             ; 4CCB
        LD HL,0000H             ; 4CCE
        RET                     ; 4CD1

p4CD2:  LD DE,xf4143            ; 4CD2
        LD A,02H                ; 4CD5
        LD HL,xf4093            ; 4CD7
        JP p4CAD                ; 4CDA

p4CDD:  PUSH AF                 ; 4CDD
        LD A,(xb408B)           ; 4CDE
        OR A                    ; 4CE1
        JP Z,p48B0              ; 4CE2
        LD A,(xf4093)           ; 4CE5
        OR A                    ; 4CE8
        JP M,p4AED              ; 4CE9
        EX (SP),HL              ; 4CEC
        PUSH HL                 ; 4CED
        PUSH DE                 ; 4CEE
        LD HL,(xb4141)          ; 4CEF
        LD A,H                  ; 4CF2
        DEC A                   ; 4CF3
        CALL Z,p4CD2            ; 4CF4
        INC HL                  ; 4CF7
        LD (xb4141),HL          ; 4CF8
        LD DE,xb4142            ; 4CFB
        ADD HL,DE               ; 4CFE
        POP DE                  ; 4CFF
        POP AF                  ; 4D00
        LD (HL),A               ; 4D01
        POP HL                  ; 4D02
        RET                     ; 4D03

p4D04:  LD A,(xf40D5)           ; 4D04
        INC A                   ; 4D07
        JP Z,p4B00              ; 4D08
        JP M,p4D90              ; 4D0B
        PUSH HL                 ; 4D0E
        PUSH DE                 ; 4D0F
        LD HL,(xb4445)          ; 4D10
        LD A,H                  ; 4D13
        CP 02H                  ; 4D14
        CALL Z,p4D25            ; 4D16
        INC HL                  ; 4D19
        LD (xb4445),HL          ; 4D1A
        LD DE,xb4446            ; 4D1D
        ADD HL,DE               ; 4D20
        POP DE                  ; 4D21
        JP p4B13                ; 4D22

p4D25:  LD DE,xf4447            ; 4D25 buffer
        LD A,04H                ; 4D28
p4D2A:  PUSH AF                 ; 4D2A
        PUSH DE                 ; 4D2B
        PUSH BC                 ; 4D2C

; Set DMA address

        LD C,26                 ; 4D2D
        CALL p0005              ; 4D2F

; Sequential disk read

        LD DE,xf40D5            ; 4D32 FCB address
        LD C,20                 ; 4D35
        CALL p0005              ; 4D37
        POP BC                  ; 4D3A
        POP DE                  ; 4D3B
        DEC A                   ; 4D3C
        JP Z,p4D4E              ; 4D3D
        LD HL,0080H             ; 4D40
        ADD HL,DE               ; 4D43
        EX DE,HL                ; 4D44
        POP AF                  ; 4D45
        DEC A                   ; 4D46
        JP NZ,p4D2A             ; 4D47
p4D4A:  LD HL,0000H             ; 4D4A
        RET                     ; 4D4D

p4D4E:  POP AF                  ; 4D4E
        LD A,1AH                ; 4D4F
        LD (DE),A               ; 4D51
        JP p4D4A                ; 4D52

; Output char to console

p4D55:  POP AF                  ; 4D55
        PUSH HL                 ; 4D56
        PUSH DE                 ; 4D57
        PUSH BC                 ; 4D58
        PUSH AF                 ; 4D59
        LD C,5                  ; 4D5A
        AND 7FH                 ; 4D5C
        LD E,A                  ; 4D5E
        LD HL,xb4092            ; 4D5F
        CP 20H                  ; 4D62
        JP NC,p4D73             ; 4D64
        SUB 0DH                 ; 4D67
        JP Z,p4D71              ; 4D69
        INC A                   ; 4D6C
        JP Z,p4D71              ; 4D6D
        LD A,(HL)               ; 4D70
p4D71:  DEC A                   ; 4D71
        LD (HL),A               ; 4D72
p4D73:  INC (HL)                ; 4D73
        LD A,E                  ; 4D74
        CP 09H                  ; 4D75
        JP NZ,p4D88             ; 4D77
p4D7A:  LD A,20H                ; 4D7A
        CALL p4C76              ; 4D7C
        LD A,(HL)               ; 4D7F
        AND 07H                 ; 4D80
        JP NZ,p4D7A             ; 4D82
        JP p4D8B                ; 4D85

p4D88:  CALL p0005              ; 4D88
p4D8B:  POP AF                  ; 4D8B
        POP BC                  ; 4D8C
        POP DE                  ; 4D8D
        POP HL                  ; 4D8E
        RET                     ; 4D8F

p4D90:  PUSH HL                 ; 4D90
        PUSH DE                 ; 4D91
        PUSH BC                 ; 4D92

; Read char from input

        LD C,3                  ; 4D93
        CALL p0005              ; 4D95
        POP BC                  ; 4D98
        POP DE                  ; 4D99
        POP HL                  ; 4D9A
        CP 1AH                  ; 4D9B ^Z
        SCF                     ; 4D9D
        RET Z                   ; 4D9E
        OR A                    ; 4D9F
        RET                     ; 4DA0

p4DA1:  LD HL,x4DC1             ; 4DA1 'DISK'
        CALL p46CC              ; 4DA4
        POP DE                  ; 4DA7
        LD A,(DE)               ; 4DA8
        ADD A,40H               ; 4DA9
        CP 40H                  ; 4DAB
        JP NZ,p4DB2             ; 4DAD
        LD A,20H                ; 4DB0
p4DB2:  CALL p4AEE              ; 4DB2
        LD HL,x4DC7             ; 4DB5 'FULL'
        CALL p46CC              ; 4DB8
        CALL p4B1B              ; 4DBB
        JP p0000                ; 4DBE EXIT to O/S

x4DC1:  DB "DISK ",0
x4DC7:  DB " FULL",0

xf4DCD: DS 32                   ; 4DCD FCB address
x4DED:  DB 0                    ; 4DED
x4DEE:  DB 0                    ; 4DEE
x4DEF:  DW 0                    ; 4DEF

xf4DF1: DS 128                  ; 4DF1 DMA transfer area

p4E71:  PUSH HL                 ; 4E71
x4E72:  PUSH DE                 ; 4E72
        PUSH BC                 ; 4E73
        EX DE,HL                ; 4E74
        LD HL,xf4DCD            ; 4E75
        INC DE                  ; 4E78
        LD A,(DE)               ; 4E79
        DEC DE                  ; 4E7A
        CP 3AH                  ; 4E7B
        LD A,00H                ; 4E7D
        JP NZ,p4E8C             ; 4E7F
        LD A,(DE)               ; 4E82
        INC DE                  ; 4E83
        SUB 40H                 ; 4E84
        CP 1BH                  ; 4E86
        JP NC,p4EF0             ; 4E88
        INC DE                  ; 4E8B
p4E8C:  LD (HL),A               ; 4E8C
        INC HL                  ; 4E8D
        LD B,08H                ; 4E8E
p4E90:  LD A,(DE)               ; 4E90
        INC DE                  ; 4E91
        LD (xb4084),A           ; 4E92
        CP 2EH                  ; 4E95
        JP Z,p4EB7              ; 4E97
        CP 21H                  ; 4E9A
        JP C,p4EB7              ; 4E9C
        LD (HL),A               ; 4E9F
        INC HL                  ; 4EA0
        DEC B                   ; 4EA1
        JP NZ,p4E90             ; 4EA2
p4EA5:  LD A,(DE)               ; 4EA5
        INC DE                  ; 4EA6
        LD (xb4084),A           ; 4EA7
        CP 2EH                  ; 4EAA
        JP Z,p4EBE              ; 4EAC
        CP 21H                  ; 4EAF
        JP NC,p4EA5             ; 4EB1
        JP p4EBE                ; 4EB4

p4EB7:  LD (HL),20H             ; 4EB7
        INC HL                  ; 4EB9
        DEC B                   ; 4EBA
        JP NZ,p4EB7             ; 4EBB
p4EBE:  LD B,03H                ; 4EBE
        LD A,(xb4084)           ; 4EC0
        CP 2EH                  ; 4EC3
        JP Z,p4ECB              ; 4EC5
        LD DE,xs0106            ; 4EC8
p4ECB:  LD A,(DE)               ; 4ECB
        INC DE                  ; 4ECC
        LD (HL),A               ; 4ECD
        INC HL                  ; 4ECE
        DEC B                   ; 4ECF
        JP NZ,p4ECB             ; 4ED0
        LD (HL),B               ; 4ED3

; Set DMA address

        LD DE,xf4DF1            ; 4ED4 DMA address
        LD C,26                 ; 4ED7
        CALL p0005              ; 4ED9

; Open file

        LD DE,xf4DCD            ; 4EDC FCB address
        LD C,15                 ; 4EDF
        CALL p0005              ; 4EE1
        CP 0FFH                  ; 4EE4
        JP Z,p4EF0              ; 4EE6
        XOR A                   ; 4EE9
        LD (x4DED),A            ; 4EEA
        LD (x4DEE),A            ; 4EED
p4EF0:  POP BC                  ; 4EF0
        POP DE                  ; 4EF1
        POP HL                  ; 4EF2
        RET                     ; 4EF3

p4EF4:  PUSH HL                 ; 4EF4
        PUSH DE                 ; 4EF5
        PUSH BC                 ; 4EF6
        LD A,(x4DEE)            ; 4EF7
        DEC A                   ; 4EFA
        JP P,p4F1B              ; 4EFB

; Set DMA address

        LD DE,xf4DF1            ; 4EFE
        LD C,26                 ; 4F01
        CALL p0005              ; 4F03

; Read sequential

        LD DE,xf4DCD            ; 4F06 FCB address
        LD C,20                 ; 4F09
        CALL p0005              ; 4F0B
        ADD A,0FFH              ; 4F0E
        JP C,p4F30              ; 4F10
        LD HL,xf4DF1            ; 4F13 DMA address
        LD (x4DEF),HL           ; 4F16
        LD A,7FH                ; 4F19
p4F1B:  LD (x4DEE),A            ; 4F1B
        LD HL,(x4DEF)           ; 4F1E
        LD A,(HL)               ; 4F21
        CP 1AH                  ; 4F22
        JP NZ,p4F2B             ; 4F24
        SCF                     ; 4F27
        JP p4F30                ; 4F28

p4F2B:  INC HL                  ; 4F2B
        LD (x4DEF),HL           ; 4F2C
        OR A                    ; 4F2F
p4F30:  POP BC                  ; 4F30
        POP DE                  ; 4F31
        POP HL                  ; 4F32
        RET                     ; 4F33

p4F34:  RET                     ; 4F34

x4F35:  DB 30H                  ; 4F35
        DS 74                   ; 4F36
        END