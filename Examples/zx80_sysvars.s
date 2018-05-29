


; ---------------------------------------------------------------
;                   THE SYSTEM VARIABLES
; ---------------------------------------------------------------
;
; The names of the system variables are taken from the original Nine Tiles Assembly Listing.
; Example values are taken _AS_AN_EXAMPLE_ONLY_ from Breakout (Macronics, 1980)
;
; #target o, 80 or z80:
; The sysvar bytes are actually stored in the snapshot file.
; Copy&paste the sysvar definitions into a #code segment starting at $4000 and fill in proper values.


#code SYSVARS, 0x4000, 0x28


ERR_NR  db  $FF     ;  1  16384 $4000 IY+$00    One less than report code.
FLAGS   db  $04     ; X1  16385 $4001 IY+$01    Various Flags to control BASIC System:
                    ;                               7  1-Syntax off        0-Syntax on
                    ;                               6  1-Numeric result    0-String result
                    ;                               5  1-Evaluating function (not used)
                    ;                               3  1-K cursor          0-L cursor
                    ;                               2  1-K mode            0-L mode.
                    ;                               0  1-No leading space  0-Leading space.
PPC     dw  $FFFE   ;  2  16386 $4002 IY+$02    Line number of current line.
P_PTR   dw  $434A   ; N2  16388 $4004 IY+$04    Position in RAM of [K] or [L] cursor.
E_PPC   dw  0       ;  2  16390 $4006 IY+$06    Number of current line with [>] cursor.
VARS    dw  $4349   ; X2  16392 $4008 IY+$08    Address of start of variables area.
E_LINE  dw  $434A   ; X2  16394 $400A IY+$0A    Address of start of Edit Line.
D_FILE  dw  $434C   ; X2  16396 $400C IY+$0C    Start of Display File.
DF_EA   dw  $458C   ; X2  16398 $400E IY+$0E    Address of the start of lower screen.
DF_END  dw  $458F   ; X2  16400 $4010 IY+$10    Display File End.

DF_SZ   db  2       ; X1  16402 $4012 IY+$12    Number of lines in lower screen.
S_TOP   dw  0       ;  2  16403 $4013 IY+$13    The number of first line on screen.
X_PTR   dw  0       ;  2  16405 $4015 IY+$15    Address of the character preceding the [S] marker.
OLDPPC  dw  0       ;  2  16407 $4017 IY+$17    Line number to which continue jumps.
FLAGX   db  0       ; N1  16409 $4019 IY+$19    More flags:
                    ;                               7  1-K mode            0-L mode.
                    ;                               6  1-Numeric result    0-String result
                    ;                               5  1-Inputting         0-Editing
T_ADDR   dw $07A2   ; N2  16410 $401A IY+$1A    Address of next item in syntax table.
SEED     dw 0       ; U2  16412 $401C IY+$1C    The seed for the random number.
FRAMES   dw $7484   ; U2  16414 $401E IY+$1E    Count of frames shown since start-up.
DEST     dw $4733   ; N2  16416 $4020 IY+$20    Address of variable in statement.
RESULT   dw $3800   ; N2  16418 $4022 IY+$22    Value of the last expression.
S_POSN_X db $21     ; X1  16420 $4024 IY+$24    Column number for print position.
S_POSN_Y db $17     ; X1  16421 $4025 IY+$25    Line number for print position.
CH_ADD   dw $FFFF   ; X2  16422 $4026 IY+$26    Address of next character to be interpreted.













