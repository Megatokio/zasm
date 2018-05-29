

; ---------------------------------------------------------------
;                   THE SYSTEM VARIABLES
; ---------------------------------------------------------------

; #target tap:
; The sysvars are actually not stored in most tape files.
; Just include this file to define names for the system variables so you can easily refer to them.
;
; #target sna or z80:
; The sysvar bytes are actually stored in the snapshot file.
; Copy&paste the sysvar definitions into a #code segment starting at $5C00 and fill in proper values.


RAMBEG: equ $4000   ; start of ram
BILD:   equ $4000   ; 0x1800 bytes: screen pixels
ATTRSP: equ $5800   ; 0x300 bytes: screen attributes
PTRBUF: equ $5B00   ; 0x100 bytes: printer buffer


#data SYSVARS, 0x5C00, 23734-0x5C00


KSTATE: ds  8       ; 5C00  buffer for keyboard (2 keys)
LASTK:  db  0       ; 5C08  last key code
REPDEL: db  0       ; 5C09  delay until first key repeat
REPPER: db  0       ; 5C0A  delay for auto repeat
DEFADD: dw  0       ; 5C0B  argument for functions
KDATA:  db  0       ; 5C0D  color of keybord input
TVDATA: dw  0       ; 5C0E  Color, AT and TAB position
STRMS:  ds  38      ; 5C10  table of opened channels
CHARS:  dw  0       ; 5C36  address of character set -256 (~ address of char code 0x00)
RASP:   db  0       ; 5C38  length of warning buzz
PIP:    db  0       ; 5C39

;IY zeigt immer auf ERRNR

ERRNR:  db  0       ; 5C3A  fuer Meldungen: Nummer -1; keine Meldung :0xFF
FLAGS:  db  0       ; 5C3B  Bit 1 = Printer ein
TVFLAG: db  0       ; 5C3C  Flagbyte fuer Bildschirm
ERRSP:  dw  0       ; 5C3D  Errorstackpointer
LISTSP: dw  0       ; 5C3F  Returnadresse bei LIST
MODE:   db  0       ; 5C41  Tastenmodus (K,L,C,E,G)
NEWPPC: dw  0       ; 5C42  Nr. der Zeile, wohin gesprungen wird (GOTO usw.)
NSPPC:  db  0       ; 5C44  Befehl der Zeile bei Sprung
PPC:    dw  0       ; 5C45  aktuelle Nr. der Basiczeile
SUBPPC: db  0       ; 5C47  Zeiger auf Befehl der Zeile
BORDCR: db  0       ; 5C48  Bordercolor * 8
EPPC:   dw  0       ; 5C49  aktuelle Editorzeile
VARS:   dw  0       ; 5C4B  Beginn der Variablen
DEST:   dw  0       ; 5C4D  Variablenadresse bei Zuweisung
CHANS:  dw  0       ; 5C4F  Pointer fuer Kanaldaten
CURCHL: dw  0       ; 5C51  aktuelle I/O Infoadresse
PROG:   dw  0       ; 5C53  Start des Basicprogrammes
NXTLIN: dw  0       ; 5C55  Adresse der naechsten Basiczeile
DATADD: dw  0       ; 5C57  Zeiger auf Endbyte der letzten Daten
ELINE:  dw  0       ; 5C59  Adresse eines eingegebenen Befehls
KCUR:   dw  0       ; 5C5B  Kursoradresse
CHADD:  dw  0       ; 5C5D  naechstes zu interpret. Zeichen
XPTR:   dw  0       ; 5C5F  Adresse des Zeichens nach ? bei Error
WORKSP: dw  0       ; 5C61  derzeitiger Workspace
STKBOT: dw  0       ; 5C63  Anfang des Calculatorstacks
STKEND: dw  0       ; 5C65  Anfang des freien Speichers
BREG:   db  0       ; 5C67  Calculator Hifsregister
MEM:    dw  0       ; 5C68  Zeiger auf Calculatorspeicher
FLAGS2: db  0       ; 5C6A  Flags Teil 2
DFSZ:   db  0       ; 5C6B  Zeilenanzahl+1 im unteren Bildschirmteil
STOP:   dw  0       ; 5C6C  Nummer der obersten Zeile eines Listings
OLDPPC: dw  0       ; 5C6E  Zeilennummer fuer Continue
OSPCC:  db  0       ; 5C70  naechster Befehl fuer Cont.
FLAGX:  db  0       ; 5C71  Flag Teil 3
STRLEN: dw  0       ; 5C72  Laenge eines Strings
TADDR:  dw  0       ; 5C74  Address of next ITEM in Syntax-Table
SEED:   dw  0       ; 5C76  Zufallszahl setzen durch Randomize
FRAMES: ds  3       ; 5C78  3 Byte Bildzaehler (Uhr)
UDG:    dw  0       ; 5C7B  Adresse der User Grafikzeichen
COORDS: dw  0       ; 5C7D  Koordinaten des letzten Plot
PPOSN:  db  0       ; 5C7F
PRCC:   dw  0       ; 5C80  fuer Printer - Buffer
ECHOE:  dw  0       ; 5C82  Position fuer Input
DFCC:   dw  0       ; 5C84  Printadresse im Displayfile
DFCCL:  dw  0       ; 5C86  Printadresse im unteren Teil
SPOSN:  dw  0       ; 5C88  33-Col/24-Zeilennr. fuer Print
SPOSNL: dw  0       ; 5C8A  33-Col/24-Zeilennr. unt. Teil
SCRCT:  db  0       ; 5C8C  Scrollzaehler
ATTRP:  db  0       ; 5C8D  aktuelle Farben permanent
MASKP:  db  0       ; 5C8E
ATTRT:  db  0       ; 5C8F  aktuelle Farben temporaer
MASKT:  db  0       ; 5C90  aktuelle Farbe transp./temp.
PFLAG:  db  0       ; 5C91
MEMBOT: ds  30      ; 5C92  Calculatorspeicher
NMIREG: dw  0       ; 5CB0
RAMTOP: dw  0       ; 5CB2  letzte Speicheradresse fuer Basic
PRAMT:  dw  0       ; 5CB4  letzte Speicheradresse
KANMEM: equ $       ; 5CB6


