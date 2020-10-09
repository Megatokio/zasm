


; Jupiter ACE memory map
;
; 0000 - 1FFF = ROM 8KB
; 2000 - 23FF = 768 charmap + 256 PAD (CPU priority)
; 2400 - 27FF = 768 charmap + 256 PAD (Video priority)
; 2800 - 2BFF = 1KB charset (CPU priority)
; 2C00 - 2FFF = 1KB charset (Video priority)
; 3000 - 3BFF = RAM 1KB x 3 mirrors
; 3C00 - 3FFF = RAM 1KB
; 3C00 - FFFF = Expansion RAM (0-48KB)
;
; FORTH register usage
;
; A, Flags  Temporary
; BC        Temporary
; DE        Temporary
; HL        Temporary
; IX        System Variables ($3C00)
; IY        Interpreter Pointer
; SP        Return Stack Pointer (IP on top)
; $3C3B     Data Stack Pointer (sys var SPARE)
; RST n     Used for core stack ops


; ---------------------------------------------------------------
;                   THE SYSTEM VARIABLES
; ---------------------------------------------------------------

; #target tap:
; The sysvars are actually not stored in the tape file.
; Just include this file to define names for the system variables so you can easily refer to them.
;
; #target ace or z80:
; The sysvar bytes are actually stored in the snapshot file.
; Copy&paste the sysvar definitions into a #code segment starting at $3C00 and fill in proper values.


#data SYSVARS, 0x3C00, 0x40


FP_WS       ds  19      ; $3C00 (15360) 19 bytes used as work space for floating point arithmetic.
LISTWS      ds  5       ; $3C13 (15379) 5 bytes used as workspace by 'LIST' and 'EDIT'.
RAMTOP      dw  0       ; $3C18 (15384) the first address past the last address in RAM.
HLD         dw  0       ; $3C1A (15386) The address of the latest character held in the pad by formatted output.
                        ;               ('#', 'HOLD' and so on).
SCRPOS      dw  0       ; $3C1C (15388) The address of the place in video RAM where the next character is to be printed
                        ;               (i.e. the 'print position').
INSCRN      dw  0       ; $3C1E (15390) The address of the start of the current 'logical line' in the input buffer.
CURSOR      dw  0       ; $3C20 (15392) The address of the cursor in the input buffer.
ENDBUF      dw  0       ; $3C22 (15394) The address of the end of the current logical line in the input buffer.
L_HALF      dw  0       ; $3C24 (15396) The address of the start of the the input buffer. The input buffer itself is stored
                        ;               in the video RAM, where you see it.
KEYCOD      db  0       ; $3C26 (15398) The ASCII code of the last key pressed.
KEYCNT      db  0       ; $3C27 (15399) Used by the routine that reads the keyboard.
STATIN      db  0       ; $3C28 (15400) Used by the routine that reads the keyboard.
EXWRCH      dw  0       ; $3C29 (15401) This is normally 0 but it can be changed to allow printing to be sent
                        ;               to some device other than the screen.
FRAMES      dw  0,0     ; $3C2B (15403) These four bytes form a double length integer that counts the time since the Ace was
                        ;               switched on in 50ths of a second.
XCOORD      db  0       ; $3C2F (15407) The x-coordinate last used by 'PLOT'.
YCOORD      db  0       ; $3C30 (15408) The y-coordinate last used by 'PLOT'.
CURRENT     dw  0       ; $3C31 (15409) The parameter field address for the vocabulary word of the current vocabulary.
CONTEXT     dw  0       ; $3C33 (15411) The parameter field address for the vocabulary word of the context vocabulary.
VOCLNK      dw  0       ; $3C35 (15413) The address of the fourth byte in the parameter field - the vocabulary linkage -
                        ;               of the vocabulary word of the most recently defined vocabulary.
STKBOT      dw  0       ; $3C37 (15415) The address of the next byte into which anything will be enclosed in the
                        ;               dictionary, i.e. one byte past the present end of the dictionary.
                        ;               'HERE' is equivalent to 15415 @.
DICT        dw  0       ; $3C39 (15417) The address of the length field in the newest word in the dictionary. If that length
                        ;               field is correctly filled in then DICT may be 0.
SPARE       dw  0       ; $3C3B (15419) The address of the first byte past the top of the stack.
ERR_NO      db  0       ; $3C3D (15421) This is usually 255, meaning "no error". If 'ABORT' is used, and ERR_NO is between
                        ;               0 and 127, then "ERROR" will be printed out, followed by the error number ERR_NO.
FLAGS       db  0       ; $3C3E (15422) Shows the state of various parts of the system, each bit showing whether something
                        ;               particular is happening or not. Some of these may be useful.
                        ;               Bit 2, when 1, shows that there is an incomplete definition at the end of the dictionary.
                        ;               Bit 3, when 1, shows that output is to fed into the input buffer.
                        ;               Bit 4, when 1, shows that the Ace is in invisible mode.
                        ;               Bit 6, when 1, shows that the Ace is in compile mode.
BASE        db  0       ; $3C3F (15423) The system number base.




