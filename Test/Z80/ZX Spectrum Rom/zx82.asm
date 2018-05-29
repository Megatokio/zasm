#!/usr/local/bin/zasm -o ../original/
#target	rom



PFE:	equ	0FEh	;Port


#data	SYSVARS, 4000h, 23734-4000h

RAMBEG:	ds	0		;Anfang des Rambereiches
BILD:	ds	1800H	;Bildschirmspeicher

ATTRSP: ds	300H	;Attributspeicher
PTRBUF: ds	100H	;Druckerpuffer
KSTATE: ds	8		;2*4 Speicher fuer Tastatur
LASTK:	ds	1		;letzter Tastencode
REPDEL: ds	1		;Zeitkonstante bis Repeat
REPPER: ds	1		;Zeitkonstante bei Repeat
DEFADD: ds	2		;Argument fuer Funktionen
KDATA:	ds	1		;Farbe fuer Keybordinput
TVDATA: ds	2		;Color, AT und TAB Pos.
STRMS:	ds	38		;Tabelle der offenen Kanaele
CHARS:	ds	2		;Zeichensatzadresse -256
RASP:	ds	1		;Laenge Warnton
PIP:	ds	1

;IY zeigt immer auf ERRNR

ERRNR:	ds	1	;fuer Meldungen: Nummer -1; keine Meldung :FFh
FLAGS:	ds	1	;Bit 1 = Printer ein
TVFLAG: ds	1	;Flagbyte fuer Bildschirm
ERRSP:	ds	2	;Errorstackpointer
LISTSP: ds	2	;Returnadresse bei LIST
MODE:	ds	1	;Tastenmodus (K,L,C,E,G)
NEWPPC: ds	2	;Nr. der Zeile, wohin gesprungen wird (GOTO usw.)
NSPPC:	ds	1	;Befehl der Zeile bei Sprung
PPC:	ds	2	;aktuelle Nr. der Basiczeile
SUBPPC: ds	1	;Zeiger auf Befehl der Zeile
BORDCR: ds	1	;Bordercolor * 8
EPPC:	ds	2	;aktuelle Editorzeile
VARS:	ds	2	;Beginn der Variablen
DEST:	ds	2	;Variablenadresse bei Zuweisung
CHANS:	ds	2	;Pointer fuer Kanaldaten
CURCHL: ds	2	;aktuelle I/O Infoadresse
PROG:	ds	2	;Start des Basicprogrammes
NXTLIN: ds	2	;Adresse der naechsten Basiczeile
DATADD: ds	2	;Zeiger auf Endbyte der letzten Daten
ELINE:	ds	2	;Adresse eines eingegebenen Befehls
KCUR:	ds	2	;Kursoradresse
CHADD:	ds	2	;naechstes zu interpret. Zeichen
XPTR:	ds	2	;Adresse des Zeichens nach ? bei Error
WORKSP: ds	2	;derzeitiger Workspace
STKBOT: ds	2	;Anfang des Calculatorstacks
STKEND: ds	2	;Anfang des freien Speichers
BREG:	ds	1	;Calculator Hifsregister
MEM:	ds	2	;Zeiger auf Calculatorspeicher
FLAGS2: ds	1	;Flags Teil 2
DFSZ:	ds	1	;Zeilenanzahl+1 im unteren Bildschirmteil
STOP:	ds	2	;Nummer der obersten Zeile eines Listings
OLDPPC: ds	2	;Zeilennummer fuer Continue
OSPCC:	ds	1	;naechster Befehl fuer Cont.
FLAGX:	ds	1	;Flag Teil 3
STRLEN: ds	2	;Laenge eines Strings
TADDR:	ds	2	;Address of next ITEM in Syntax-Table
SEED:	ds	2	;Zufallszahl setzen durch Randomize
FRAMES: ds	3	;3 Byte Bildzaehler (Uhr)
UDG:	ds	2	;Adresse der User Grafikzeichen
COORDS: ds	2	;Koordinaten des letzten Plot
PPOSN:	ds	1
PRCC:	ds	2	;fuer Printer - Buffer
ECHOE:	ds	2	;Position fuer Input
DFCC:	ds	2	;Printadresse im Displayfile
DFCCL:	ds	2	;Printadresse im unteren Teil
SPOSN:	ds	2	;33-Col/24-Zeilennr. fuer Print
SPOSNL: ds	2	;33-Col/24-Zeilennr. unt. Teil
SCRCT:	ds	1	;Scrollzaehler
ATTRP:	ds	1	;aktuelle Farben permanent
MASKP:	ds	1
ATTRT:	ds	1	;aktuelle Farben temporaer
MASKT:	ds	1	;aktuelle Farbe transp./temp.
PFLAG:	ds	1
MEMBOT: ds	30	;Calculatorspeicher
NMIREG: ds	2
RAMTOP: ds	2	;letzte Speicheradresse fuer Basic
PRAMT:	ds	2	;letzte Speicheradresse
KANMEM:	ds	0



#code	ROM, 0, $4000

RESET:	DI
	XOR A
	LD DE,0FFFFH		;oberste moegliche Ramzelle
	JP RESET1

ERRAUS: LD HL,(CHADD)		;der Errorzeiger wird auf die
	LD (XPTR),HL		;Eingabe gesetzt,welche nicht
	JR ERROR		;mehr interpretiert werden kann

PRTOUT: JP AUSGA2		;Buchstaben in Reg A ausdrucken
	DEFS 5

GETAKT: LD HL,(CHADD)		;holt aktuelles Zeichen aus
	LD A,(HL)		;Programm oder bei Eingabe
AUSWER: CALL BASZCP		;Pruefen auf Stuerzeichen
	RET NC			;druckbares Zeichen/ Basictoken

GETNXT: CALL NEXZEI		;holt naechstes Zeichen
	JR AUSWER
	DEFS 3

CALRUF: JP RECHNE		;zur Rechnerroutine
	DEFS 5

REST30: PUSH BC			;reserviere Speicherplatz im
	LD HL,(WORKSP)		;Workspace, Anzahl = BC
	PUSH HL
	JP RESERV

;Interrupt - Routine (Uhr und Tastatur)

INTERR: PUSH AF
	PUSH HL
	LD HL,(FRAMES)		;3 Byte Bildzaehler (Uhr)
	INC HL			;Zeit in 1/50 Sekunden
	LD (FRAMES),HL
	LD A,H
	OR L
	JR NZ,M0048
	INC (IY+40H)		;wenn Null drittes Byte
				;inkrementieren
M0048:	PUSH BC
	PUSH DE
	CALL KEYBOA		;Tastaturabfrage
	POP DE
	POP BC
	POP HL
	POP AF
	EI
	RET

ERROR:	POP HL			;Adresse der Fehlerstelle laden
	LD L,(HL)		;die dort stehende Fehlernummer
M0055:	LD (IY+0),L		;in 'ERRNR' schreiben
	LD SP,(ERRSP)		;Stackpointer restaurieren
	JP CLRCAL
	DEFS 7

;NMI:	LD A,0
;	RST ERRAUS
;	NOP
;	NOP

NMI:	push af
	push hl
	ld hl,($5cb0)

	LD A,H			;falls HL=0, dann Kaltstart
	OR L
	JR NZ,M0070		;sonst passiert nichts
	JP (HL)
M0070:	POP HL
	POP AF
	RETN

NEXZEI: LD HL,(CHADD)		;Programmzeiger erhoehen
M0077:	INC HL
M0078:	LD (CHADD),HL		;Adr. des naechsten zu
				;interpret. Zeichens
	LD A,(HL)		;neues Zeichen laden
	RET

;Vergleich der Basic - Zeichen

BASZCP: CP 21H			;Rueckkehr, wenn >=21H
	RET NC			;also bei allen druckbaren
				;Zeichen oder Tokens
	CP 0DH			;oder CR
	RET Z
	CP 10H			;Return mit Carry bei 0...0FH
	RET C
	CP 18H
	CCF
	RET C			;Return mit Carry bei 18...20H
;Beeinflussung von CHADD, dem aktuellen Basic-Zeichenzeiger
	INC HL			;bei 10...17H inkrementieren
	CP 16H			;16 u. 17H ausblenden
	JR C,M0090		;bei 10...15H nicht inkrementieren
	INC HL
M0090:	SCF
	LD (CHADD),HL		;naechstes zu interpret. Zeichen
	RET

;=======================================================

M0095:	DEFM '?'+80H
	DEFM 'RND'+80H
	DEFM 'INKEY$'+80H
	DEFM 'PI'+80H
	DEFM 'FN'+80H
	DEFM 'POINT'+80H
	DEFM 'SCREEN$'+80H
	DEFM 'ATTR'+80H
	DEFM 'AT'+80H
	DEFM 'TAB'+80H
	DEFM 'VAL$'+80H
	DEFM 'CODE'+80H
	DEFM 'VAL'+80H
	DEFM 'LEN'+80H
	DEFM 'SIN'+80H
	DEFM 'COS'+80H
	DEFM 'TAN'+80H
	DEFM 'ASN'+80H
	DEFM 'ACS'+80H
	DEFM 'ATN'+80H
	DEFM 'LN'+80H
	DEFM 'EXP'+80H
	DEFM 'INT'+80H
	DEFM 'SQR'+80H
	DEFM 'SGN'+80H
	DEFM 'ABS'+80H
	DEFM 'PEEK'+80H
	DEFM 'IN'+80H
	DEFM 'USR'+80H
	DEFM 'STR$'+80H
	DEFM 'CHR$'+80H
	DEFM 'NOT'+80H
	DEFM 'BIN'+80H
	DEFM 'OR'+80H
	DEFM 'AND'+80H
	DEFM '<='+80H
	DEFM '>='+80H
	DEFM '<>'+80H
	DEFM 'LINE'+80H
	DEFM 'THEN'+80H
	DEFM 'TO'+80H
	DEFM 'STEP'+80H
	DEFM 'DEF FN'+80H
	DEFM 'CAT'+80H
	DEFM 'FORMAT'+80H
	DEFM 'MOVE'+80H
	DEFM 'ERASE'+80H
	DEFM 'OPEN #'+80H
	DEFM 'CLOSE #'+80H
	DEFM 'MERGE'+80H
	DEFM 'VERIFY'+80H
	DEFM 'BEEP'+80H
	DEFM 'CIRCLE'+80H
	DEFM 'INK'+80H
	DEFM 'PAPER'+80H
	DEFM 'FLASH'+80H
	DEFM 'BRIGHT'+80H
	DEFM 'INVERSE'+80H
	DEFM 'OVER'+80H
	DEFM 'OUT'+80H
	DEFM 'LPRINT'+80H
	DEFM 'LLIST'+80H
	DEFM 'STOP'+80H
	DEFM 'READ'+80H
	DEFM 'DATA'+80H
	DEFM 'RESTORE'+80H
	DEFM 'NEW'+80H
	DEFM 'BORDER'+80H
	DEFM 'CONTINUE'+80H
	DEFM 'DIM'+80H
	DEFM 'REM'+80H
	DEFM 'FOR'+80H
	DEFM 'GO TO'+80H
	DEFM 'GO SUB'+80H
	DEFM 'INPUT'+80H
	DEFM 'LOAD'+80H
	DEFM 'LIST'+80H
	DEFM 'LET'+80H
	DEFM 'PAUSE'+80H
	DEFM 'NEXT'+80H
	DEFM 'POKE'+80H
	DEFM 'PRINT'+80H
	DEFM 'PLOT'+80H
	DEFM 'RUN'+80H
	DEFM 'SAVE'+80H
	DEFM 'RANDOMIZE'+80H
	DEFM 'IF'+80H
	DEFM 'CLS'+80H
	DEFM 'DRAW'+80H
	DEFM 'CLEAR'+80H
	DEFM 'RETURN'+80H
	DEFM 'COPY'+80H

;======================================

;Tabelle der Zuordnung Keyboard Matrix - ASCII

KEYTAB: DEFM 'BHY65TGV'		;Reihe 1
	DEFM 'NJU74RFC'		;Reihe 2
	DEFM 'MKI83EDX'		;Reihe 3
	DEFB 0EH		;Symbol Shift  Reihe 4
	DEFM 'LO92WSZ'
	DEFM ' '		;Reihe 5
	DEFB 0DH		;Enter
	DEFM 'P01QA'

;=====================================

;Tabellen der Basic - Tokens

;gruene Befehle auf den Tasten A....Z

	DEFB 0E3H		;READ
	DEFB 0C4H		;BIN
	DEFB 0E0H		;LPRINT
	DEFB 0E4H		;DATA
	DEFB 0B4H		;TAN
	DEFB 0BCH		;SGN
	DEFB 0BDH		;ABS
	DEFB 0BBH		;SQR
	DEFB 0AFH		;CODE
	DEFB 0B0H		;VAL
	DEFB 0B1H		;LEN
	DEFB 0C0H		;USR
	DEFB 0A7H		;PI
	DEFB 0A6H		;INKEY$
	DEFB 0BEH		;PEEK
	DEFB 0ADH		;TAB
	DEFB 0B2H		;SIN
	DEFB 0BAH		;INT
	DEFB 0E5H		;RESTORE
	DEFB 0A5H		;RND
	DEFB 0C2H		;CHR$
	DEFB 0E1H		;LLIST
	DEFB 0B3H		;COS
	DEFB 0B9H		;EXP
	DEFB 0C1H		;STR$
	DEFB 0B8H		;LN

;die roten Befehle unter den Tasten A....Z

	DEFB 07EH		;Schlangenlinie
	DEFB 0DCH		;BRIGHT
	DEFB 0DAH		;PAPER
	DEFB 05CH		;Schraegstrich rueckwaerts
	DEFB 0B7H		;ATN
	DEFB 07BH		;geschweifte Klammer auf
	DEFB 07DH		;	"	"    zu
	DEFB 0D8H		;CIRCLE
	DEFB 0BFH		;IN
	DEFB 0AEH		;VAL$
	DEFB 0AAH		;SCREEN$
	DEFB 0ABH		;ATTR
	DEFB 0DDH		;INVERSE
	DEFB 0DEH		;OVER
	DEFB 0DFH		;OUT
	DEFB 07FH		;COPYRIGHT
	DEFB 0B5H		;ASN
	DEFB 0D6H		;VERIFY
	DEFB 07CH		;Strich
	DEFB 0D5H		;MERGE
	DEFB 05DH		;eckige Klammer auf
	DEFB 0DBH		;FLASH
	DEFB 0B6H		;ACS
	DEFB 0D9H		;INK
	DEFB 05BH		;eckige Klammer zu
	DEFB 0D7H		;BEEP

;Befehle ueber den Tasten 0....9

	DEFB 0CH		;DELETE
	DEFB 07H		;EDIT
	DEFB 06H		;SHIFT LOCK
	DEFB 04H		;VIDEO NORMAL
	DEFB 05H		;INVERSE VIDEO
	DEFB 08H		;Cursor nach links
	DEFB 0AH		;  "	 "   unten
	DEFB 0BH		;  "	 "   oben
	DEFB 09H		;  "	 "   rechts
	DEFB 0FH		;Grafik

;rote Befehle auf den Tasten A....Z

	DEFB 0E2H		;STOP
	DEFB 02AH		;*
	DEFB 03FH		;?
	DEFB 0CDH		;STEP
	DEFB 0C8H		;>=
	DEFB 0CCH		;TO
	DEFB 0CBH		;THEN
	DEFB 05EH		;Pfeil nach oben
	DEFB 0ACH		;AT
	DEFB 02DH		;-
	DEFB 02BH		;+
	DEFB 03DH		;=
	DEFB 02EH		;.
	DEFB 02CH		;,
	DEFB 03BH		;;
	DEFB 022H		;"
	DEFB 0C7H		;<=
	DEFB 03CH		;<
	DEFB 0C3H		;NOT
	DEFB 03EH		;>
	DEFB 0C5H		;OR
	DEFB 02FH		;/
	DEFB 0C9H		;<>
	DEFB 060H		;POUND SIGN
	DEFB 0C6H		;AND
	DEFB 03AH		;:

;rote Befehle unter den Tasten 0....9

	DEFB 0D0H		;FORMAT
	DEFB 0CEH		;DEF FN
	DEFB 0A8H		;FN
	DEFB 0CAH		;LINE
	DEFB 0D3H		;OPEN
	DEFB 0D4H		;CLOSE
	DEFB 0D1H		;MOVE
	DEFB 0D2H		;ERASE
	DEFB 0A9H		;POINT
	DEFB 0CFH		;CAT

;====================================

;Keyboard - Abfrageroutine
;Output: E = Taste als Wert 0....27H
;	 D = Shift - Funktion

KEY:	LD L,2FH		;Zeiger auf Ende der
				;Keycode-Tabelle +8
	LD DE,0FFFFH		;keine Taste
	LD BC,0FEFEH		;C = I/O-Port der Tastatur
				;B = Maske mit einer Null
				;zum Abfragen der 1. Spalte
NXTREI: IN A,(C)		;Abfrage
	CPL			;'1' = Tastendruck
	AND 1FH			;5 Tasten in einer Spalte
	JR Z,NOKEY
	LD H,A			;Matrixwert in H
	LD A,L			;Startwert aus L holen
TEST3:	INC D			;D haelt 0FFH bei 1-2 ge-
				;drueckten Tasten
	RET NZ			;bei mehr als zwei gedr. Tasten
KEINTA: SUB 8			;A = Tabellenzeiger des Keycodes
	SRL H			;Tastendruck suchen
	JR NC,KEINTA
	LD D,E			;fuer zwei zulaessige Tasten
				;nochmals 0FFH laden
	LD E,A			;Tastencode 0....27H in E
	JR NZ,TEST3		;nochmals Taste in laufender
				;Reihe suchen
NOKEY:	DEC L			;naechste Reihe
	RLC B			;Maske in B schieben
	JR C,NXTREI

;wenn die Null aus B in Carry gelangt, fertig

	LD A,D			;Test auf Funktionstasten
	INC A			;bei einer Taste steht hier 0FFH
	RET Z			;wenn nur eine Taste gedrueckt

	CP 28H			;Taste 'CAPS SHIFT' ?
	RET Z
	CP 19H			;Taste 'SYMBOL SHIFT' ?
	RET Z
	LD A,E			;E und D vertauschen
	LD E,D
	LD D,A
	CP 18H			;Taste 'SYMBOL SHIFT' ?
	RET			;ZERO gesetzt bei 'SYMBOL
				;SHIFT + andere Taste

;Aufruf der Tastaturabfrage und Auswertung der Eingaben
;erfolgt im Interrupt, alle 1/50 Sekunden

KEYBOA: CALL KEY		;Tastaturabfrage
	RET NZ

;hier erfolgt weitere Auswertung in den Faellen:
;kein oder einfacher Tastendruck
;'CAPS SHIFT' + andere Taste
;'SYMBOL SHIFT' + andere Taste

;die Tastaturauswertung benutzt die 8 Bytes 'KSTATE'
;in zwei Gruppen zu 4 Bytes, um zwei folgende
;gedrueckte Tasten verarbeiten zu koennen

;Byte 0: Belegtkennung (FF = frei, 0 = belegt)
;Byte 1: Repeat-Zaehler (5...0)
;Byte 2: REPDEL (Wartezeit vom Beginn des Repeat)
;Byte 3: Code der gedrueckten Taste, ASCII oder Token

	LD HL,KSTATE		;2*4 Speicher fuer Tastatur
M02C6:	BIT 7,(HL)		;Tastaturspeicher frei ?
	JR NZ,BLOCK2		;wenn frei
	INC HL
	DEC (HL)		;DEC Repeat-Zaehler
	DEC HL
	JR NZ,BLOCK2
	LD (HL),0FFH		;Block freigeben
BLOCK2: LD A,L
	LD HL,KSTATE+4		;Block 2 anwaehlen
	CP L			;war es schon Block 2 ?
	JR NZ,M02C6		;nein
	CALL M031E
	RET NC			;Ende, wenn keine Taste
	LD HL,KSTATE
	CP (HL)			;ist es noch dieselbe Taste ?
	JR Z,KEYREP		;wenn ja, Repeat
	EX DE,HL
	LD HL,KSTATE+4		;Block 2 pruefen
	CP (HL)
	JR Z,KEYREP
	BIT 7,(HL)		;Block 2 frei ?
	JR NZ,M02F1
	EX DE,HL		;KSTATE in HL zurueckladen
	BIT 7,(HL)		;Freipruefung
	RET Z			;Ende der Tastaturabfrage
				;bei belegt

;neue Taste gedrueckt

M02F1:	LD E,A
	LD (HL),A		;Byte 0
	INC HL			;HL zeigt auf Byte 1
	LD (HL),5		;Repeat-Zaehler = 5
	INC HL			;Byte 2
	LD A,(REPDEL)		;Zeitkonstante bis Repeat
	LD (HL),A
	INC HL			;Byte 3
	LD C,(IY+7)		;Mode
	LD D,(IY+1)		;Flags
	PUSH HL
	CALL M0333		;Tastencode (Token) erzeugen
	POP HL
	LD (HL),A		;in Byte 3 speichern
M0308:	LD (LASTK),A		;und in LASTK
	SET 5,(IY+1)		;neuer Tastencode liegt vor
	RET

;Repeat - Funktion

KEYREP: INC HL			;zeigt auf Repeat - Zaehler
	LD (HL),5		;wieder = 5
	INC HL			;zeigt auf Wartezeit
	DEC (HL)
	RET NZ

	LD A,(REPPER)		;Zeitkonstante bei Repeat
	LD (HL),A		;in Byte 2
	INC HL			;Byte 3 = Tastencode
	LD A,(HL)
	JR M0308		;setze letzten Tastendruck

M031E:	LD B,D			;Funktionstaste merken
	LD D,0
	LD A,E
	CP 27H			;'CAPS SHIFT'
	RET NC			;oder keine Taste: RETURN

	CP 18H			;'SYMBOL SHIFT'
	JR NZ,M032C
	BIT 7,B			;RETURN bei 'SYMBOL SHIFT'
	RET NZ			;allein
M032C:	LD HL,KEYTAB		;Tastaturtabelle
	ADD HL,DE		;aktuelles Zeichen als ASCII-
	LD A,(HL)		;Wert aus der Tabelle holen
	SCF			;CARRY = Zeichen gefunden
	RET
;----------------------------------------------------

;Auswertung des ermittelten Tastencodes
;und Bildung der Basictoken je nach Eingabemodus
;(Cursor Mode K,L,C und E)

M0333:	LD A,E			;ASCII-Code der Taste
	CP 3AH			;Ziffer, Space, Enter oder
	JR C,M0367		;Shift, dann Sprung
	DEC C			;nur A....Z
	JP M,M034F
	JR Z,M0341
	ADD A,4FH		;revers Buchstaben liegen ab 90H
	RET

;gruene Tokens ueber Tasten A....Z

M0341:	LD HL,1EBH
	INC B
	JR Z,TABDIR

;rote Tokens unter den Tasten A....Z

	LD HL,KEYTAB		;Tastaturtabelle

;endgueltiges Token wird aus der
;entsprechenden Tabelle geladen

TABDIR: LD D,0			;E = ASCII - Wert
	ADD HL,DE		;HL = Basisadresse -41H bzw. 30H
	LD A,(HL)
	RET

;rote Tokens auf den Tasten A....Z

M034F:	LD HL,229H
	BIT 0,B
	JR Z,TABDIR		;'SYMBOL SHIFT' + Buchstabe
	BIT 3,D			;K - Modus
	JR Z,M0364
	BIT 3,(IY+30H)		;FLAGS2 pruefen auf 'CAPS LOCK'
	RET NZ
	INC B			;SHIFT ?
	RET NZ
	ADD A,20H		;ASCII - Wert fuer Kleinschreibung
	RET

M0364:	ADD A,0A5H		;direkt erzeugbare Tokens
	RET			;durch Addition (E6H)

M0367:	CP 30H			;Zeichen <30H ?
	RET C
	DEC C			;Modus
	JP M,M039D		;bei K,L,C
	JR NZ,M0389		;bei G

;rote Tokens unter den Tasten 0....9

	LD HL,254H
	BIT 5,B
	JR Z,TABDIR		;ohne 'CAPS SHIFT'
	CP 38H
	JR NC,M0382
	SUB 20H			;aus 30H..37H wird 10H..17H
	INC B
	RET Z			;wenn ohne SHIFT
	ADD A,8			;Farbcode 18H..1FH
	RET
;Tasten 8 und 9 (Codes fuer BRIGHT und FLASH)
M0382:	SUB 36H			;erzeuge 2 oder 3 ohne SHIFT
	INC B
	RET Z			;ohne SHIFT
	ADD A,0FEH		;erzeuge 0 oder 1 mit SHIFT
	RET

;Grafikzeichen auf den Tasten 0....9

M0389:	LD HL,230H		;(mit 'CAPS SHIFT')
	CP 39H			;Test auf 'GRAPHICS'
	JR Z,TABDIR
	CP 30H			;Test auf 'DELETE'
	JR Z,TABDIR
	AND 7			;nur Tasten '1...7'
	ADD A,80H		;80H..87H sind die Grafikzeichen
	INC B
	RET Z			;wenn kein SHIFT
	XOR 0FH			;erzeuge Steuerzeichen ueber den
				;Tasten 1...8 (Codes:88H..8FH)
	RET

M039D:	INC B
	RET Z			;wenn kein SHIFT
	BIT 5,B			;'CAPS SHIFT' ?

	;Befehle ueber den Tasten 0....9

	LD HL,230H
	JR NZ,TABDIR
	SUB 10H			;aus 30H..39H wird 20H..29H
	CP 22H			;'AT-SIGN' ?
	JR Z,M03B2
	CP 20H			;unterstreichen ?
	RET NZ
	LD A,5FH		;UNDERLINE
	RET

M03B2:	LD A,40H
	RET
;-----------------------------------------------------

;Lautsprecher = Routinen
;Bit 4 von Port 0FEH steuert den Lautsprecher
;High = stromlos

PIEPEN: DI			;Tastatur und Uhr gesperrt
	LD A,L
	SRL L
	SRL L
	CPL
	AND 3
	LD C,A
	LD B,0
	LD IX,3D1H		;Basisadresse der Zeitschleife
	ADD IX,BC
	LD A,(BORDCR)		;Bordercolor * 8
	AND 38H			;Lautsprecher aktivieren
	RRCA			;in Bit 0...2 von A
	RRCA
	RRCA
	OR 8			;Kassettenausgang abschalten
	NOP
	NOP
	NOP
	INC B
	INC C
HALBZE: DEC C			;Zeitschleife fuer halbe Periode
	JR NZ,HALBZE
	LD C,3FH
	DEC B
	JP NZ,HALBZE
	XOR 10H			;Bit 4 invertieren
	OUT (0FEH),A
	LD B,H			;B wieder laden
	LD C,A			;A retten
	BIT 4,A			;Mitte des Zyklus ?
	JR NZ,TONMIT		;ja
	LD A,D			;DE = 0 ?
	OR E
	JR Z,TONEND		;0 = Pieper Ende
	LD A,C			;A zurueck
	LD C,L
	DEC DE			;Schleifenzaehler - 1
	JP (IX)

TONMIT: LD C,L
	INC C
	JP (IX)			;weiter

TONEND: EI
	RET

;Befehlsausfuehrung 'BEEP'

M03F8:	RST CALRUF		;Aufruf Calculator
				;um die Werte fuer Tonhoehe
				;(P bzw I=INT(P)) und die
				;Zeit T zu berechnen
	DEFB 031H
	DEFB 027H
	DEFB 0C0H
	DEFB 003H
	DEFB 034H
	DEFB 0ECH
	DEFB 06CH
	DEFB 098H
	DEFB 01FH
	DEFB 0F5H
	DEFB 004H
	DEFB 0A1H
	DEFB 00FH
	DEFB 038H

	LD HL,MEMBOT
	LD A,(HL)		;Exponent von I holen
	AND A
	JR NZ,ERRTON		;nicht 0: ERROR
	INC HL
	LD C,(HL)		;Vorzeichenbyte
	INC HL
	LD B,(HL)		;Low-Byte
	LD A,B
	RLA
	SBC A,A			;Test -128<=I<=+127 ?
	CP C
	JR NZ,ERRTON
	INC HL
	CP (HL)
	JR NZ,ERRTON

	LD A,B			;Low-Byte in A
	ADD A,3CH		;-60 bis +67
	JP P,M0425		;ok
	JP PO,ERRTON

;Oktave des Tons in B suchen

M0425:	LD B,0FAH		;6 Oktaven unter mittlerem C
OKTAV:	INC B			;beginnen
	SUB 12			;pro Oktave 12 Toene abziehen
	JR NC,OKTAV
	ADD A,12		;A: Zeiger auf Halbton dieser Oktave
	PUSH BC			;Nr der Okt.
	LD HL,TONC
	CALL M3406		;Halbton in A in den
	CALL M33B4		;Calculator-Stack
	RST CALRUF		;Tonhoehe berechnen
	DEFB 4
	DEFB 38H

	POP AF			;Oktav-Nr
	ADD A,(HL)		;add. Exponent = *2
	LD (HL),A

	RST CALRUF
	DEFB 0C0H		;Frequenz in MEM0
	DEFB 2
	DEFB 31H
	DEFB 38H

	CALL INTEG1		;Zeit muss < 10 sein
	CP 11
	JR NC,ERRTON		;sonst Error

	RST CALRUF		;Berechnung Frequenz*Zeit
	DEFB 0E0H		;ermittelte Frequenz holen
	DEFB 4H			;T * F
	DEFB 0E0H
	DEFB 34H
	DEFB 80H
	DEFB 43H
	DEFB 55H
	DEFB 9FH
	DEFB 80H
	DEFB 1H
	DEFB 5H
	DEFB 34H
	DEFB 35H
	DEFB 71H
	DEFB 3H
	DEFB 38H

	CALL M1E99		;Zeitschleifenwert holen
	PUSH BC			;und retten
	CALL M1E99		;Frequenz * Zeit --> BC
	POP HL
	LD D,B
	LD E,C			;DE=Anzahl der Durchlaeufe

	LD A,D
	OR E
	RET Z

	DEC DE
	JP PIEPEN		;Tonausgabe

ERRTON: RST ERRAUS
	DEFB 0AH

;Halbtontabelle

TONC:	DEFB 89H,2,0D0H,12H,86H
TONCIS: DEFB 89H,0AH,97H,60H,75H
TOND:	DEFB 89H,12H,0D5H,17H,1FH
TONDIS: DEFB 89H,1BH,90H,41H,2
TONE:	DEFB 89H,24H,0D0H,53H,0CAH
TONF:	DEFB 89H,2EH,9DH,36H,0B1H
TONFIS: DEFB 89H,38H,0FFH,49H,3EH
TONG:	DEFB 89H,43H,0FFH,6AH,73H
TONGIS: DEFB 89H,4FH,0A7H,0,54H
TONA:	DEFB 89H,5CH,0,0,0
TONB:	DEFB 89H,69H,14H,0F6H,24H
TONH:	DEFB 89H,76H,0F1H,10H,5

;Diese Routine wird nicht benutzt !!!

	CALL 24FBH
	LD A,(FLAGS)		;Bit 1= Printer ein
	ADD A,A
	JP M,M1C8A
	POP HL
	RET NC
	PUSH HL
	CALL M2BF1
	LD H,D
	LD L,E
	DEC C
	RET M
	ADD HL,BC
	SET 7,(HL)
	RET


;Kassettenrekorder

;Byte abspeichern

M04C2:	LD HL,SAVLOA		;Returnadresse fuer SAVE, LOAD
	PUSH HL
	LD HL,1F80H		;Konstante fuer 5 s Headerton
	BIT 7,A
	JR Z,M04D0		;Header speichern
	LD HL,0C98H		;Konstante fuer 2 s
M04D0:	EX AF,AF'		;Programm-Header-Flag retten
	INC DE
	DEC IX
	DI
	LD A,2			;Bordercolour rot und 'MIC' ein
	LD B,A

HEADER: DJNZ HEADER		;Bitperiode Headerton
	OUT (0FEH),A		; 'MIC' ein/ausschalten
	XOR 0FH
	LD B,0A4H		;Konstante Bitperiode
	DEC L
	JR NZ,HEADER
	DEC B
	DEC H			;Wiederholung bis HL < 0
	JP P,HEADER

;Synchronimpuls senden

	LD B,2FH
SYNC1:	DJNZ SYNC1		;'MIC' aus
	OUT (0FEH),A		;'MIC' ein und rot
	LD A,0DH		;fuer 'MIC' ein und 'CYAN'
	LD B,37H
SYNC2:	DJNZ SYNC2
	OUT (0FEH),A		;'MIC' aus und 'CYAN'

	LD BC,3B0EH
	EX AF,AF'
	LD L,A			;Flag in L
	JP M0507

BYTEAU: LD A,D
	OR E
	JR Z,M050E		;Bytes Ende und Parity senden

	LD L,(IX+0)		;sonst naechstes Byte
M0505:	LD A,H			;"Parity"-Bildung in A
	XOR L			;mit aktuellem Byte
M0507:	LD H,A
	LD A,1			;'MIC' ein und 'blau'
	SCF			;Endemarkierung
	JP SAVE8		;Fuer 8 Bit setzen und senden

M050E:	LD L,H			;Ende-"parity" nach L
	JR M0505

BITEND: LD A,C			;Teil 2 des Bits senden und hierfuer
	BIT 7,B			;Zero setzen

BITANF: DJNZ BITANF		;Zeitschleife
	JR NC,BITOUT		;wenn Nullbit
	LD B,42H
BITSET: DJNZ BITSET		;bei 1 weiter verzoegern
BITOUT: OUT (0FEH),A		;Teil1: 'MIC' ein und blau
				;Teil2: 'MIC' aus und gelb
	LD B,3EH
	JR NZ,BITEND		;Teil2 ausgeben
	DEC B
	XOR A			;CY=0
	INC A			;'MIC' ein mit blau

;Beim ersten Bit eines Byte ist Carry gesetzt, sonst immer
;geloescht --> Begrenzung auf 8 Bit beim Rotieren des L-Reg.

SAVE8:	RL L			;Bit 7 der Ausgabe ins Carry
	JP NZ,BITANF		;weiter bis 8 Bit fertig

	DEC DE			;Bytezaehler
	INC IX			;Adresse naechstes Byte
	LD B,31H
	LD A,7FH
	IN A,(0FEH)		;Break-Taste?
	RRA
	RET NC			;ja

	LD A,D
	INC A
	JP NZ,BYTEAU		;Ausgabe bis DE=FFFFH

	LD B,3BH
SAVEDE: DJNZ SAVEDE		;etwas verzoegern
	RET


;Nach SAVE oder LOAD hierhin zurueckkehren

SAVLOA: PUSH AF			;CY retten
	LD A,(BORDCR)		;original Bordercolor
	AND 38H			;nehmen und in Bit 0..2
	RRCA
	RRCA
	RRCA
	OUT (0FEH),A		;Border original
	LD A,7FH
	IN A,(0FEH)		;Breaktaste?
	RRA
	EI
	JR C,M0554		;nein

	RST ERRAUS		;Meldung
	DEFB 0CH

M0554:	POP AF			;Flags
	RET

	;UP fuer LOAD und VERIFY

M0556:	INC D			;Zero loeschen
	EX AF,AF'		;und retten
	DEC D			;D regen.
	DI
	LD A,0FH		;Border colour weiss
	OUT (0FEH),A
	LD HL,SAVLOA		;Returnadr.
	PUSH HL
	IN A,(0FEH)		;1 * zum Initialisieren lesen
	RRA
	AND 20H			; 'EAR'-Bit merken
	OR 2			;Border-Colour rot
	LD C,A			;retten (22H = aus, 2 = ein)
	CP A			;fuer Uebersprung RET NZ

LOABRK: RET NZ			;EXIT bei Break

LOABEG: CALL FLANK1		;CY geloescht: keine Flanke
	JR NC,LOABRK		;gefunden oder Break gedrueckt

	LD HL,415H
LDWART: DJNZ LDWART		;Warteschleife etwa 1 s
	DEC HL
	LD A,H
	OR L
	JR NZ,LDWART
	CALL FLANK2		;noch mal auf 2 Flanken warten
	JR NC,LOABRK		;falls nicht, Error

;Nur ein Headersignal akzeptieren

HEADIN: LD B,9CH		;Zeitkonstante
	CALL FLANK2		;2 Flanken erwarten
	JR NC,LOABRK		;falls nicht Error
	LD A,0C6H		;max. Zeitabstand
	CP B			;ca. 3000 T Zyklen
	JR NC,LOABEG		;sonst noch mal suchen
	INC H			;256 Doppelflanken abwarten
	JR NZ,HEADIN

;Jetzt wird ein Synchronimpuls erwartet

SYNWAR: LD B,0C9H		;Zeitkonstante
	CALL FLANK1
	JR NC,LOABRK
	LD A,B			;2 kurz aufeinander folgende
	CP 0D4H			;Flanken bilden den Sync-Impuls
	JR NC,SYNWAR
	CALL FLANK1		;abfallende Sync-Flanke
	RET NC			;muss existieren

;Die Bytes koennen geladen oder verifiziert werden

	LD A,C			;Border Colours auf blau
	XOR 3			;bzw. gelb schalten
	LD C,A
	LD H,0			;fuer Parity-Pruefung
	LD B,0B0H		;Zeitkonstante fuer FLAG-Byte
	JR M05C8

M05A9:	EX AF,AF'		;Flags holen
	JR NZ,LOAFLG		;nur bei Flagpruefung (1. Byte)
	JR NC,VERIFY
	LD (IX+0),L		;geladenes Byte speichern
	JR LADWEI		;und naechstes laden
LOAFLG: RL C			;CY retten
	XOR L			;erstes Byte = Typ-Flag
	RET NZ			;nein Error

	LD A,C			;sonst CY wiederholen
	RRA
	LD C,A
	INC DE			;dieses INC wird unten wieder
	JR M05C4		;rueckgaengig gemacht

VERIFY: LD A,(IX+0)		;bei Verify Originalbyte holen
	XOR L			;und vergleichen
	RET NZ			;Verify-Error (Carry geloescht)

LADWEI: INC IX			;Adresse fuer Load/Verify erhoehen
M05C4:	DEC DE			;Zaehler -1
	EX AF,AF'		;Flags retten
	LD B,0B2H		;Zeitkonstante
M05C8:	LD L,1			;Endekennung beim 9. Schieben

BITHOL: CALL FLANK2		;Laenge der Pulse holen
	RET NC			;Zeitueberschreitung

	LD A,0CBH		;Zeitvergleich, um daraus eine 0
	CP B			;oder 1 im CY zu gewinnen und
	RL L			;in L zu schieben
	LD B,0B0H		;Zeitkonstante naechstes Bit
	JP NC,BITHOL		;Byte noch nicht kompl.

	LD A,H			;Parity holen
	XOR L			;und neues bilden
	LD H,A			;neues Parity
	LD A,D
	OR E
	JR NZ,M05A9		;Ende noch nicht erreicht
	LD A,H			;letztes Parity-Byte muss 0
	CP 1			;sein: CY gesetzt
	RET			;sonst Carry geloescht: Error


;Pegelwechsel (Flanken) am Kassettenrekoordereingang erfassen

;B: Zeitzaehler
;Innerhalb dieser festgelegten Zeit muessen die geforderten
;Flanken auftreten --> sonst Error mit CY=0

FLANK2: CALL FLANK1		;Auf 2 Flanken pruefen
	RET NC			;Error

FLANK1: LD A,16H		;1 Flanke pruefen
WARTLD: DEC A			;warten
	JR NZ,WARTLD
	AND A			;CY=0
FLANKE: INC B			;Zeitzaehler
	RET Z			;Zeitende: CY Z

	LD A,7FH
	IN A,(0FEH)		;Breaktaste und 'EAR'
	RRA			;Break gedrueckt:
	RET NC			;  NC & NZ

	XOR C			;Flanke aufgetreten ?
	AND 20H
	JR Z,FLANKE		;nein: weiter warten

;Innerhalb der erlaubten Zeit wurde Flanke erkannt

	LD A,C
	CPL			;C = Flankenart
	LD C,A
	AND 7			;Bordercolour ausblenden
	OR 8			;MIC aus
	OUT (0FEH),A
	SCF			;CY=1: OK
	RET

;Einsprung bei LOAD, SAVE, VERIFY & MERGE

;Unterscheidung der Befehle Mittels TADDR

KASHAU: POP AF			;Ret-Adr. vernichten
	LD A,(TADDR)		;Naechster Token in der Tabelle
	SUB 0E0H		;-E0H, um 0 fuer SAVE, 1 fuer LOAD,
				;2 fuer VERIFY und 3 fuer MERGE zu
				;erhalten
	LD (TADDR),A
	CALL PAR0A		;Namensparameter in Calc.-Stack
	CALL M2530		;Syntaxpruefung?
	JR Z,M0652		;ja

	LD BC,17		;Namenslaenge: 17
	LD A,(TADDR)		;Adresse des naechsten Tokens
				;in der Tabelle
	AND A
	JR Z,KASPAC		;bei SAVE
	LD C,34			;sonst Laenge 34
KASPAC: RST REST30		;Speicher reservieren
	PUSH DE			;Startadresse in IX
	POP IX
	LD B,11
	LD A,' '
CLRNAM: LD (DE),A		;Filename loeschen
	INC DE
	DJNZ CLRNAM

	LD (IX+1),255		;zeigt 'kein Name' an
	CALL M2BF1		;Namensparameter holen
	LD HL,-10
	DEC BC
	ADD HL,BC		;Laenge=10?
	INC BC
	JR NC,M064B		;<=10
	LD A,(TADDR)		;falls nicht SAVE:
	AND A
	JR NZ,NAMOK		;mehr zulassen
NAMERR: RST ERRAUS
	DEFB 0EH		;'INVALD FILE NAME'

NAMOK:	LD A,B
	OR C
	JR Z,M0652		;ohne Namensangabe
	LD BC,10		;Name auf 10 begrenzen
M064B:	PUSH IX			;Adresse des Namens
	POP HL			;in HL
	INC HL
	EX DE,HL
	LDIR			;Namen umspeichern

M0652:	RST GETAKT		;naechstes Zeichen lesen
	CP 0E4H			;Token 'DATA' ?
	JR NZ,M06A0		;nein
	LD A,(TADDR)		;auf MERGE pruefen
	CP 3
	JP Z,M1C8A		;'MERGE' mit 'DATA': ERROR
	RST GETNXT		;naechstes Zeichen
	CALL M28B2		;in Variablentabelle suchen
	SET 7,C			;Bit 7 des Arraynamens setzen
	JR NC,M0672		;bei vorhandenen Array
	LD HL,0			;neues Array
	LD A,(TADDR)		;Adresse des naechsten Tokens
				;in der Tabelle
	DEC A
	JR Z,M0685		;nur 'LOAD' zugelassen

	RST ERRAUS
	DEFB 1			;'VARIABLE NOT FOUND'

M0672:	JP NZ,M1C8A
	CALL M2530		;bei Syntaxpruefung
	JR Z,M0692		;Sprung
	INC HL			;sonst Laengenbyte LOW
	LD A,(HL)
	LD (IX+0BH),A
	INC HL			;und HIGH in den
	LD A,(HL)		;Workspace
	LD (IX+0CH),A
	INC HL
M0685:	LD (IX+0EH),C		;Arrayname speichern
	LD A,1			;Zahlenarray
	BIT 6,C
	JR Z,M068F
	INC A			;Buchstabenarray
M068F:	LD (IX+0),A		;erstes Headerbyte
M0692:	EX DE,HL
	RST GETNXT		;naechste Zeichen
	CP ')'
	JR NZ,M0672		;ERROR C
	RST GETNXT
	CALL M1BEE		;Aussprung bei Syntaxpruefung
	EX DE,HL
	JP M075A		;weiter

M06A0:	CP 0AAH			;ist Token ='SCREEN$' ?
	JR NZ,M06C3		;nein

	LD A,(TADDR)
	CP 3			;bei MERGE ist 'SCREEN$' als
	JP Z,M1C8A		;Name nicht zugelassen
	RST GETNXT
	CALL M1BEE
	LD (IX+0BH),0		;Laenge des Display- und
	LD (IX+0CH),1BH		;Attributspeichers = 1B00H
	LD HL,BILD		;Video - RAM
	LD (IX+0DH),L
	LD (IX+0EH),H
	JR M0710

M06C3:	CP 0AFH			;Token = 'CODE' ?
	JR NZ,M0716		;nein
	LD A,(TADDR)		;bei MERGE ist 'CODE'
	CP 3
	JP Z,M1C8A		;nicht zugelassen
	RST GETNXT
	CALL M2048		;Eingabeende ?
	JR NZ,M06E1		;nein
	LD A,(TADDR)		;bei SAVE ist 'CODE'
	AND A
	JP Z,M1C8A		;nicht zugelassen
	CALL M1CE6		;0 auf Calculatorstack fuer Start
	JR M06F0

;Startadresse suchen

M06E1:	CALL PAR06		;erste Zahl holen
	RST GETAKT		;naechstes Zeichen
	CP ','
	JR Z,M06F5
	LD A,(TADDR)		;ERROR, falls bei 'SAVE'
	AND A			;nur die Startadresse
	JP Z,M1C8A		;und keine Laenge
M06F0:	CALL M1CE6		;0 als Laenge auf Calculatorstack
	JR M06F9

M06F5:	RST GETNXT		;naechstes Zeichen und die
	CALL PAR06		;Laenge holen

M06F9:	CALL M1BEE		;weiter zum naechsten Befehl,
				;falls Syntaxpruefung
	CALL M1E99		;Laenge ins BC Register
	LD (IX+0BH),C		;und in Header
	LD (IX+0CH),B
	CALL M1E99		;ebenso mit der Startadresse
	LD (IX+0DH),C
	LD (IX+0EH),B
	LD H,B			;Startadresse als Pointer in HL
	LD L,C
M0710:	LD (IX+0),3		;Typ '3' fuer SCREEN$ und CODE
	JR M075A

M0716:	CP 0CAH			;Token = 'LINE' ?
	JR Z,M0723		;ja
	CALL M1BEE		;naechster Befehl bei Syntaxpruef.
	LD (IX+0EH),80H		;falls keine weiteren Parameter
	JR M073A

M0723:	LD A,(TADDR)		;pruefen ob 'SAVE', denn eine
	AND A			;Zeilennummer muss folgen
	JP NZ,M1C8A		;nicht 'SAVE'
	RST GETNXT
	CALL PAR06		;Zeilennummer auf Calc-Stack
	CALL M1BEE		;bei Syntaxpruefung EXIT
	CALL M1E99		;sonst Zeilennummer in BC
	LD (IX+0DH),C
	LD (IX+0EH),B
M073A:	LD (IX+0),0		;'LINE' und ohne weitere Angaben
				;sind vom Typ '0'

	LD HL,(ELINE)		;Zeiger auf Variablenende
	LD DE,(PROG)		;Zeiger auf Start des Basicprogrammes
	SCF
	SBC HL,DE
	LD (IX+0BH),L		;Laenge von Programm + Variablenspeicher
	LD (IX+0CH),H
	LD HL,(VARS)		;Beginn der Variablen
	SBC HL,DE
	LD (IX+0FH),L		;Programmlaenge
	LD (IX+10H),H
	EX DE,HL		;HL=Programmanfang

;Der Header ist fertig:
;IX+ 0: Typ
;IX+ 1 bis 10: Name bzw. IX+1=FF, wenn kein Name
;IX+ 11,12: Laenge Programm +Variablenspeicher
;IX+ 13,14: Zeilen-Nr.
;IX+ 15,16: Programmlaenge

M075A:	LD A,(TADDR)		;Adresse des naechsten Tokens
				;in der Tabelle
	AND A			;SAVE?
	JP Z,M0970		;ja

	PUSH HL			;Pointer fuer LOAD etc. retten
	LD BC,011H
	ADD IX,BC		;Adr des 2. Headers
M0767:	PUSH IX
	LD DE,17		;17 Bytes laden
	XOR A			;HEADER anmerken
	SCF			;LOAD anmerken
	CALL M0556		;HEADER laden
	POP IX			;2. Headeradr. zurueck
	JR NC,M0767		;Header noch nicht gefunden

	LD A,0FEH		;Kanal S oefffnen
	CALL OPKAN
	LD (IY+52H),3		;Scrolling-Zaehler setzen
	LD C,80H		;Default fuer Haeder falsch
	LD A,(IX+0)		;Die beiden Haeder vergleichen
	CP (IX-11H)
	JR NZ,M078A		;noch nicht richtig

	LD C,-10		;10 Zeichen muessen stimmen
M078A:	CP 4			;Typ > 4 ist Unsinn
	JR NC,M0767		;noch mal Header laden

	LD DE,M09C0		;Basisadr. Meldungen
	PUSH BC
	CALL PRTMEL		;Typ anzeigen
	POP BC
	PUSH IX
	POP DE			;Zeiger auf geladenen Haeder
	LD HL,-16
	ADD HL,DE		;HL: Zeiger auf 1.Header
	LD B,10			;10 Zeichen pruefen
	LD A,(HL)
	INC A			;war Name angegeben?
	JR NZ,M07A6		;ja

	LD A,C			;nein: Name stimmt immer
	ADD A,B
	LD C,A

M07A6:	INC DE
	LD A,(DE)		;1. Zeichen vergleichen
	CP (HL)			;und anzeigen
	INC HL
	JR NZ,M07AD		;Haeder stimmen nicht
	INC C			;sonst Zaehler+1

M07AD:	RST PRTOUT		;Ausgabe B-mal
	DJNZ M07A6

	BIT 7,C			;C>=0? (Header OK?)
	JR NZ,M0767		;nein: noch mal holen

;Weiter, wenn der richtige Header gefunden wurde

	LD A,0DH
	RST PRTOUT		;<CR> ausgeben
	POP HL			;Pointer
	LD A,(IX+0)		;SCREEN oder
	CP 3			;CODE
	JR Z,M07CB		;ja

	LD A,(TADDR)		;Adresse des naechsten Tokens
				;in der Tabelle
	DEC A			;LOAD-Befehl?
	JP Z,M0808		;ja

	CP 2			;MERGE-Befehl?
	JP Z,M08B6		;ja

;Verify-Routine

M07CB:	PUSH HL			;Pointer
	LD L,(IX-6)
	LD H,(IX-5)		;HL: Laenge
	LD E,(IX+0BH)
	LD D,(IX+0CH)		;DE: Laenge des geladenen Haeders
	LD A,H
	OR L			;Laenge = 0 ?
	JR Z,M07E9		;ja

	SBC HL,DE		;Neue Laenge > alte Laenge?
	JR C,M0806		;ja, Error

	JR Z,M07E9		;gleiche Laenge --> ok
	LD A,(IX+0)
	CP 3			;Bei Verify muessen Laengen
				;uebereinstimmen
	JR NZ,M0806		;sonst --> Error

M07E9:	POP HL			;Startpointer
	LD A,H
	OR L			; = 0?
	JR NZ,M07F4		;nein

	LD L,(IX+0DH)		;Startpointer des geladenen
	LD H,(IX+0EH)		;Haeders benutzen
M07F4:	PUSH HL
	POP IX
	LD A,(TADDR)		;Adresse des naechsten Tokens
				;in der Tabelle
	CP 2
	SCF			;CY: LOAD
	JR NZ,M0800

	AND A			;NC: VERIFY
M0800:	LD A,0FFH

;UP-Ruf fuer alle Ladevorgaenge (LOAD, VERIFY, MERGE)

M0802:	CALL M0556
	RET C			;kein Fehler

M0806:	RST ERRAUS		;Meldung:
	DEFB 1AH		;'TAPE LOADING ERROR'

;LOAD-Routine

M0808:	LD E,(IX+11)		;Laenge aus geladenem Header
	LD D,(IX+12)
	PUSH HL			;Zielpointer
	LD A,H
	OR L			;=0? (nichtdeklariertes Array?)
	JR NZ,M0819		;nein

	INC DE			;ja
	INC DE
	INC DE			;+3 fuer Name und Laenge
	EX DE,HL
	JR M0825

M0819:	LD L,(IX-6)		;Laenge Programm + Variable
	LD H,(IX-5)
	EX DE,HL
	SCF
	SBC HL,DE		;wird zusaetzlicher Speicherpl. ben.?
	JR C,M082E		;nein

M0825:	LD DE,5
	ADD HL,DE		;+ 5 Byte
	LD B,H
	LD C,L
	CALL M1F05		;Speicherplatztest

M082E:	POP HL			;Startadresse
	LD A,(IX+0)
	AND A			;wird BASIC-Progr. geladen?
	JR Z,M0873		;ja

	LD A,H
	OR L			;neues ARRAY?
	JR Z,M084C		;ja

	DEC HL			;nein
	LD B,(HL)
	DEC HL
	LD C,(HL)		;BC=Laenge des bereits ex. Arrays
	DEC HL			;HL - Zeiger zum alten Namen
	INC BC
	INC BC			;Laenge + 3 fuer Namen und Laenge
	INC BC
	LD (XPTR),IX		;IX zwischenspeichern
	CALL RAUS2		;altes Array wegwerfen
	LD IX,(XPTR)		;IX regen.
M084C:	LD HL,(ELINE)		;Zeiger auf Endemarkierung (80H)
	DEC HL			; der Variablen
	LD C,(IX+0BH)
	LD B,(IX+0CH)		;Laenge des neuen Arrays
	PUSH BC
	INC BC
	INC BC
	INC BC			;+3 fuer Name und Laenge
	LD A,(IX-3)		;Name aus altem Haeder fuer das neue
	PUSH AF			; Array
	CALL MACHPL		;BC Speicherplaetze beschaffen
	INC HL
	POP AF
	LD (HL),A		;Name des Arrays einschreiben
	POP DE			;Laenge
	INC HL
	LD (HL),E
	INC HL
	LD (HL),D		; einschreiben
	INC HL			;Zeiger auf 1. Platz der vom Band
				; geladen wird
	PUSH HL
	POP IX			;Startadr.
	SCF			;LOAD
	LD A,0FFH		; und Daten anmerken
	JP M0802		;zur Laderoutine


;Laden eines BASIC-Programms mit Variablen

M0873:	EX DE,HL		;DE: Zieladresse
	LD HL,(ELINE)		;Variablenende suchen
	DEC HL
	LD (XPTR),IX		;Zwischenspeichern
	LD C,(IX+11)
	LD B,(IX+12)		;Laenge des neuen Headers
	PUSH BC
	CALL RAUS1		;derzeitiges Programm wegwerfen
	POP BC			;Laenge
	PUSH HL			;Zeiger auf Start
	PUSH BC
	CALL MACHPL		;BC Speicherplaetze freimachen
	LD IX,(XPTR)		;IX regen.
	INC HL
	LD C,(IX+15)
	LD B,(IX+16)
	ADD HL,BC
	LD (VARS),HL		;VARS neu setzen
	LD H,(IX+14)
	LD A,H
	AND 0C0H		;Zeilen-Nr. angeben?
	JR NZ,M08AD		;nein

	LD L,(IX+0DH)		;NEWPPC und
	LD (NEWPPC),HL		;NSPPC neu setzen
	LD (IY+0AH),0

M08AD:	POP DE			;Laenge und
	POP IX			;Startadresse holen
	SCF			;'LOAD' und
	LD A,0FFH		;Daten anmerken
	JP M0802		;zur Laderoutine

;Merge - Routine

M08B6:	LD C,(IX+0BH)		;Laenge des
	LD B,(IX+0CH)		;Datenblockes holen
	PUSH BC
	INC BC			;Laenge + 1 Speicherplaetze
	RST REST30		;im Workspace beschaffen
	LD (HL),80H		;Endemarkierung
	EX DE,HL		;Startadresse in HL
	POP DE			;Laenge in DE
	PUSH HL
	PUSH HL
	POP IX			;Startadr. in IX
	SCF			;laden
	LD A,0FFH		;und Daten anmerken
	CALL M0802		;Laderoutine
	POP HL			;neuer Start
	LD DE,(PROG)		;DE zeigt auf alten Start

;die neuen Zeilen werden in das alte Programm eingefuegt

M08D2:	LD A,(HL)
	AND 0C0H		;fertig ?
	JR NZ,M08F0		;ja

M08D7:	LD A,(DE)		;Zeilennummer HIGH vergleichen
	INC DE			;und beide Pointer + 1
	CP (HL)
	INC HL
	JR NZ,M08DF		;nicht gleich
	LD A,(DE)		;Zeilenummer LOW vergleichen
	CP (HL)
M08DF:	DEC DE			;beide Pointer
	DEC HL			;wieder original
	JR NC,M08EB		;Platz fuer neue Zeile gefunden
	PUSH HL			;sonst Start der naechsten
	EX DE,HL		;Zeile suchen
	CALL M19B8
	POP HL
	JR M08D7		;im alten Programm weitersuchen

M08EB:	CALL M092C		;neue Zeile einfuegen
	JR M08D2		;und weitersuchen

M08F0:	LD A,(HL)		;Variablennamen holen
	LD C,A
	CP 80H			;fertig ?
	RET Z			;ja

	PUSH HL			;aktuellen neuen Pointer retten
	LD HL,(VARS)		;alten Pointer holen
M08F9:	LD A,(HL)		;Variablenname und
	CP 80H			;-Ende pruefen
	JR Z,M0923		;Ende erreicht
	CP C			;stimmt Name ?
	JR Z,M0909		;ja
M0901:	PUSH BC			;Variablenname retten
	CALL M19B8		;naechste alte Variable suchen
	POP BC
	EX DE,HL		;Pointer wieder richtig
	JR M08F9		;und weitersuchen

M0909:	AND 0E0H		;langer Variablenname ?
	CP 0A0H
	JR NZ,M0921		;nein
	POP DE			;zeigt auf 1. Buchstaben
	PUSH DE			;des neuen Namens
	PUSH HL

M0912:	INC HL
	INC DE
	LD A,(DE)		;den Rest des Namens
	CP (HL)			;vergleichen
	JR NZ,M091E		;nicht gefunden
	RLA			;letztes Zeichen ?
	JR NC,M0912		;nein
	POP HL			;Adresse des alten Namens
	JR M0921		;ersetzen

M091E:	POP HL
	JR M0901		;weitersuchen

M0921:	LD A,0FFH		;Variable ersetzen
				;A=80H Variable hinzufuegen
M0923:	POP DE			;Adresse neu holen
	EX DE,HL		;Pointer richtig setzen
	INC A			;Zero fuer ersetzen = 1
	SCF			;Variablenbehandlung
	CALL M092C		;Variable eintragen
	JR M08F0		;naechste Variable suchen

;Subroutine zum Einfuegen einer Zeile oder Variablen
;bei 'MERGE'

M092C:	JR NZ,M093E		;hinzufuegen
	EX AF,AF'		;Flags retten
	LD (XPTR),HL		;'neu'-Pointer retten
	EX DE,HL
	CALL M19B8		;naechste Zeile/Variable suchen
	CALL RAUS2		;alte Zeile/Variable entfernen
	EX DE,HL		;Pointer und
	LD HL,(XPTR)
	EX AF,AF'		;Flags zurueck
M093E:	EX AF,AF'
	PUSH DE			;Zieladresse speichern
	CALL M19B8		;naechste Zeile/Variable und
				;deren Laenge suchen
	LD (XPTR),HL		;Zeile/Variable 'neu' retten
	LD HL,(PROG)		;Prog zwischenspeichern
	EX (SP),HL		;und Pointer 'neu' holen
	PUSH BC			;Laenge retten
	EX AF,AF'
	JR C,M0955		;wenn Variable neu
	DEC HL			;neuer Zeile vor der Zieladresse
	CALL MACHPL		;den Platz frei machen
	INC HL
	JR M0958

M0955:	CALL MACHPL		;Platz fuer neue Variable machen
M0958:	INC HL			;erste freie Stelle
	POP BC			;Laenge holen
	POP DE			;PROG holen und
	LD (PROG),DE		;Pointer 'neu' retten
	LD DE,(XPTR)		;neuen Pointer holen
	PUSH BC			;Laenge und
	PUSH DE			;Pointer 'neu' retten
	EX DE,HL		;Pointer richtig setzen zum
	LDIR			;Kopieren der Zeile/Variablen
	POP HL			;Pointer 'neu'
	POP BC			;Laenge
	PUSH DE			;Pointer 'alt'
	CALL RAUS2		;Zeile/Variable aus Workspace
	POP DE			;entfernen,Pointer 'alt'
	RET			;zurueckholen und fertig

;UP fuer SAVE

M0970:	PUSH HL
	LD A,0FDH		;Kanal K oeffnen
	CALL OPKAN
	XOR A			;0 = erste Meldung
	LD DE,KASMEL		;Adresse fuer Kassettenmeldung
	CALL PRTMEL		;Ausgabe 'Start Tape'
	SET 5,(IY+2)		;merken: Bildschirm loeschen
	CALL WARTA		;auf Tastendruck warten
	PUSH IX			;Headeradresse retten
	LD DE,17		;17 Bytes Header
	XOR A			;0 = Header
	CALL M04C2		;Header abspeichern
	POP IX			;Headeradresse
	LD B,50			;Verzoegerung 1 Sek.
M0991:	HALT
	DJNZ M0991
	LD E,(IX+0BH)		;DE = Laenge des zu speichern-
	LD D,(IX+0CH)		;den Datenblockes
	LD A,0FFH		;FF = Datenblock
	POP IX			;Datenanfang
	JP M04C2		;abspeichern

;Meldungen fuer Kassettenbetrieb

KASMEL: DEFB 80H
	DEFM 'Start tape, then press any key'
M09C0:	DEFB 0AEH
	DEFB 0DH
	DEFM 'Program:'
	DEFB 0A0H
	DEFB 0DH
	DEFM 'Number array:'
	DEFB 0A0H
	DEFB 0DH
	DEFM 'Character array:'
	DEFB 0A0H
	DEFB 0DH
	DEFM 'Bytes:'
	DEFB 0A0H

;==========================================

;Ausgaberoutinen fuer Bildschirm und Drucker

;A enthaelt auszugebendes Zeichen, ein Token oder Steuerzeichen

AUSGAB: CALL POSHOL		;Printposition holen
	CP ' '			;alle druckbaren Zeichen und
	JP NC,PRTCHA		;Tokens
	CP 6			;fuer 0-5 ? drucken
	JR C,PRTFRA
	CP 18H			;desgleichen fuer 18H-1FH
	JR NC,PRTFRA
	LD HL,CONTRO-6		;Adr. der Control-Zeichen-
	LD E,A			;Tabelle (6-17H ist zugelassen)
	LD D,0
	ADD HL,DE
	LD E,(HL)		;Offset holen
	ADD HL,DE		;fuer Return-Adresse addieren
	PUSH HL			;in Stack
	JP POSHOL		;Printposition holen

;Tabelle der Offsets fuer Control-Zeichen

CONTRO: DEFB M0A5F-$		;Print Komma
	DEFB PRTFRA-$		;Edit
	DEFB M0A23-$		;Cursor nach links
	DEFB M0A3D-$		;Cursor nach rechts
	DEFB PRTFRA-$		;Cursor nach unten
	DEFB PRTFRA-$		;Cursor nach oben
	DEFB PRTFRA-$		;Delete
	DEFB M0A4F-$		;Enter
	DEFB PRTFRA-$		;nicht benutzt
	DEFB PRTFRA-$		;nicht benutzt
	DEFB M0A7A-$		;Ink
	DEFB M0A7A-$		;Paper
	DEFB M0A7A-$		;Flash
	DEFB M0A7A-$		;Bright
	DEFB M0A7A-$		;Inverse
	DEFB M0A7A-$		;Over
	DEFB M0A75-$		;At
	DEFB M0A75-$		;Tab

;Cursor nach links
;B enthaelt die Zeilennummer und C die Spaltenposition
;die Zeilennummer wird von unten und die Spalte von
;rechts gezaehlt

M0A23:	INC C
	LD A,34			;linker Rand erreicht ?
	CP C
	JR NZ,M0A3A		;nein
	BIT 1,(IY+1)		;Printerausgabe ?
	JR NZ,M0A38		;ja
	INC B			;sonst Zeile 1 hoeher
	LD C,2			;Spalte = 2
	LD A,24			;Bildschirmoberkante erreicht ?
	CP B
	JR NZ,M0A3A		;nein
	DEC B			;Zeile wie vorher
M0A38:	LD C,33			;erste Spalte
M0A3A:	JP M0DD9

;Cursor 1 nach rechts
;BC wie oben bei Einstieg
;diese Routine entspricht im BASIC: PRINT OVER1;CHR$32;

M0A3D:	LD A,(PFLAG)		;Printerflag
	PUSH AF
	LD (IY+57H),1		;PFLAG auf OVER 1 setzen
	LD A,' '
	CALL M0B65		;Leerzeichen ausgeben
	POP AF
	LD (PFLAG),A		;Printerflag zurueck
	RET

;Behandlung von Carriage Return
;bei Printerausgabe wird Printerbuffer ausgegeben
;bei Display  " "  erst getestet, ob der
;Bildschirm nach oben gerollt (SCROLL) werden muss

M0A4F:	BIT 1,(IY+1)		;Printer ?
	JP NZ,M0ECD		;ja

	LD C,33			;linken Rand setzen
	CALL M0C55		;evtl. Scrolling durchfuehren
	DEC B			;1 Zeile nach unten
	JP M0DD9

;'PRINT KOMMA' Subroutine
;Tabausgabe: Spalte 0 oder 16

M0A5F:	CALL POSHOL		;Zeile und Spalte in BC holen
	LD A,C
	DEC A			;2 Spalten nach rechts
	DEC A
	AND 10H			;0 oder 16 wird daraus
	JR TABFIL		;SPACE daraus machen

PRTFRA: LD A,'?'		;nicht druckbare Zeichen
	JR PRTCHA		;durch ? ersetzen

;Steuerzeichen mit Operanden behandeln
;bei 2 Operanden (AT und TAB): Einstieg 0A75H
; 1 Operand (INK bis OVER): Einstieg 0A7AH
;Steuerzeichen immer in TVDATA merken, bei 2 Operanden
;den ersten in TVDATA+1 merken (Ausgabe auf 0A6DH)

ZWEIOP: LD DE,EINOP
	LD (TVDATA+1),A		;erster Operand
	JR AUSSET

;Einstieg bei AT und TAB

M0A75:	LD DE,ZWEIOP
	JR M0A7D

M0A7A:	LD DE,EINOP
M0A7D:	LD (TVDATA),A		;Steuerzeichen speichern

AUSSET: LD HL,(CURCHL)		;aktiven Ausgabekanal
	LD (HL),E		;neu setzen
	INC HL
	LD (HL),D
	RET

EINOP:	LD DE,AUSGAB		;Operanden geholt und Ausgabe
	CALL AUSSET		;wieder normal
	LD HL,(TVDATA)		;Steuerzeichen und OP1
	LD D,A			;letzten Operand retten
	LD A,L			;Steuerzeichen:
	CP 16H			;INK bis OVER ?
	JP C,M2211		;ja
	JR NZ,PRTTAB		;bei TAB

;Behandlung von AT

	LD B,H			;Zeilennummer (1. Oper.)
	LD C,D			;Spalten  "
	LD A,31			;da rueckwaerts gezaehlt wird,
	SUB C			;umrechnen
	JR C,M0AAC		;bei Bereichsueberschreitung
	ADD A,2
	LD C,A
	BIT 1,(IY+1)		;Printerausgabe ?
	JR NZ,M0ABF		;ja: LPRINT AT

	LD A,22			;Zeilennummer umrechnen
	SUB B
M0AAC:	JP C,M1E9F		;ERROR: INTEGER OUT OF RANGE

	INC A
	LD B,A
	INC B
	BIT 0,(IY+2)		;unterer Teil ?
	JP NZ,M0C55		;ja, evtl. Scrolling
	CP (IY+31H)		;innerhalb des Bildschirmes ?
	JP C,M0C86		;nein: OUT OF SCREEN
M0ABF:	JP M0DD9		;restliche Parameter setzen

;TAB-Ausfuehrung

PRTTAB: LD A,H			;1. Oper.
TABFIL: CALL POSHOL		;Position holen
	ADD A,C			;Spalte addieren
	DEC A			;Spaceanzahl berechnen
	AND 1FH
	RET Z			;falls keine Space

	LD D,A
	SET 0,(IY+1)		;fuehrende Space unterdruecken
PRTSPA: LD A,' '
	CALL M0C3B		;ausgeben
	DEC D
	JR NZ,PRTSPA
	RET

;druckbare Zeichen bzw. Tokens ausgeben

PRTCHA: CALL M0B24

;neue Zeilen- und Spaltennummer, sowie Pixel-Adresse
;in den Systemvariablen setzen

NEUSTO: BIT 1,(IY+1)		;Printer ?
	JR NZ,M0AFC		;ja

	BIT 0,(IY+2)		;bei unterem Bildschirmteil
	JR NZ,M0AF0		;springen
	LD (SPOSN),BC		;Werte des Hauptteiles speichern
	LD (DFCC),HL
	RET

M0AF0:	LD (SPOSNL),BC		;Werte unterer Teil speichern
	LD (ECHOE),BC
	LD (DFCCL),HL
	RET

M0AFC:	LD (IY+45H),C		;Printer Buffer Pointer
	LD (PRCC),HL		;neu setzen
	RET

;Bildschirm- oder Printerposition in BC und HL holen

POSHOL: BIT 1,(IY+1)		;Printer ?
	JR NZ,M0B1D		;ja
	LD BC,(SPOSN)		;Hauptschirmparameter
	LD HL,(DFCC)		;laden
	BIT 0,(IY+2)
	RET Z			;Return bei Hauptbildschirm
	LD BC,(SPOSNL)		;sonst untere Schirmparameter
	LD HL,(DFCCL)		;laden
	RET

M0B1D:	LD C,(IY+45H)		;Printerbufferwerte holen
	LD HL,(PRCC)
	RET

;Zeichen oder Tokens ausgeben

M0B24:	CP 80H			;normales Zeichen 20H...7FH ?
	JR C,M0B65		;ja
	CP 90H
	JR NC,PRTOU		;alle Tokens und Zeichen >80H
	LD B,A			;hier nur 80H...8FH
	CALL M0B38		;Grafikzeichen generieren
	CALL POSHOL		;HL wieder holen
	LD DE,MEMBOT		;Calculatorspeicher
	JR M0B7F

;aus den Bits 0..3 wird das Grafikzeichen generiert

M0B38:	LD HL,MEMBOT		;Calculatorspeicher zum zwischenspeichern
				;des Grafikzeichens
	CALL M0B3E		;2 * aufrufen
M0B3E:	RR B			;Bit 0 oder 2 auswerten
	SBC A,A			;A enthaelt 0FH, falls Bit gesetzt
	AND 0FH			;war, sonst 00
	LD C,A
	RR B			;Bit 1 oder 3 auswerten
	SBC A,A
	AND 0F0H		;A wird F0H oder 00
	OR C
	LD C,4			;Bitmuster 4 * speichern
M0B4C:	LD (HL),A
	INC HL
	DEC C
	JR NZ,M0B4C
	RET

;Token Codes und UDG

PRTOU:	SUB 0A5H
	JR NC,PRTTO		;wenn Token Codes
	ADD A,15H		;UDGs jetzt 00...0FH
	PUSH BC			;Position
	LD BC,(UDG)		;Adresse der User Grafikzeichen
	JR M0B6A

PRTTO:	CALL PRTTOK		;Token in Befehl umwandeln
	JP POSHOL

;normales Zeichen ausgeben

M0B65:	PUSH BC			;Position
	LD BC,(CHARS)		;Zeichensatzadresse -256
M0B6A:	EX DE,HL
	LD HL,FLAGS
	RES 0,(HL)		;fuehrende Space zulassen
	CP ' '
	JR NZ,PRTREA
	SET 0,(HL)
PRTREA: LD H,0			;Zeichen berechnen und ausgeben
	LD L,A
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
	POP BC
	EX DE,HL		;DE --> Beginn des Zeichens

;alle 8*8 Zeichen ausgeben

M0B7F:	LD A,C			;Spalte
	DEC A
	LD A,33			;erste Spalte
	JR NZ,M0B93
	DEC B			;neue Zeile
	LD C,A
	BIT 1,(IY+1)		;Printer ?
	JR Z,M0B93		;nein
	PUSH DE			;Startadresse
	CALL M0ECD		;Printerbuffer ausgeben
	POP DE
	LD A,C			;neue Spalte
M0B93:	CP C			;neue Zeile ?
	PUSH DE			;Zeichenadresse
	CALL Z,M0C55		;neue Zeile: evtl. Scrolling
	POP DE
	PUSH BC
	PUSH HL
	LD A,(PFLAG)		;Printerflag
	LD B,0FFH
	RRA			;PFLAG Bit 0 ?
	JR C,M0BA4
	INC B			;OVER1: B=FFH, sonst 0
M0BA4:	RRA			;PFLAG Bit 2 ?
	RRA
	SBC A,A
	LD C,A			;INVERSE1: C=FFH, sonst 0
	LD A,8			;Pixelzaehler
	AND A			;Reset Carry
	BIT 1,(IY+1)		;Printer ?
	JR Z,M0BB6		;nein
	SET 1,(IY+30H)		;Printerbuffer nicht leer
	SCF			;Printer wird benutzt
M0BB6:	EX DE,HL		;Ziel- und Basisadr. tauschen

;8-fach Schleife zur Ausgabe des Zeichens

M0BB7:	EX AF,AF'
	LD A,(DE)
	AND B			;OVER: 0 Zeichen wie Space
	XOR (HL)
	XOR C			;INVERSE beruecksichtigen
	LD (DE),A
	EX AF,AF'
	JR C,M0BD3		;wenn Printer
	INC D
M0BC1:	INC HL
	DEC A
	JR NZ,M0BB7		;noch nicht 8*

	EX DE,HL
	DEC H
	BIT 1,(IY+1)		;Attribut-Byte nur bei
	CALL Z,M0BDB		;Bildschirmhandling bearbeiten
	POP HL
	POP BC
	DEC C			;Spalte +1
	INC HL			;Ziel +1
	RET

M0BD3:	EX AF,AF'
	LD A,32			;Offset
	ADD A,E
	LD E,A
	EX AF,AF'
	JR M0BC1

;Subroutine zum Setzen der Attribute

M0BDB:	LD A,H			;Highteil des Zieles
	RRCA			;dividiert durch 8
	RRCA
	RRCA
	AND 3
	OR 58H			;Highbyte des Attributspeichers
	LD H,A
	LD DE,(ATTRT)		;D = ATTRT E = MASKT
	LD A,(HL)		;altes Attribut
	XOR E
	AND D
	XOR E
	BIT 6,(IY+57H)
	JR Z,M0BFA		;bei Paper9 springen
	AND 0C7H		;alte Farbe ausbleden
	BIT 2,A			;INK = dunkel ?
	JR NZ,M0BFA		;nein
	XOR 38H			;Papercolor = weiss
M0BFA:	BIT 4,(IY+57H)		;INK = 9 ?
	JR Z,M0C08		;nein
	AND 0F8H		;altes INKCOLOUR wegwerfen
	BIT 5,A			;bei Papercol. = weiss
	JR NZ,M0C08		;INKCOL.= dunkel
	XOR 7			;sonst umgedreht
M0C08:	LD (HL),A		;Attributwert speichern
	RET

;Subroutine zum ausgeben von Meldungen und Tokens
;DE enthaelt die Basisadresse der jeweiligen Tabelle
;und A die Nummer der Meldung oder des Tokens

PRTMEL: PUSH HL
	LD H,0			;nachfolgende Space unterdruecken
	EX (SP),HL
	JR M0C14

PRTTOK: LD DE,095H		;Adresse Tokentabelle
	PUSH AF
M0C14:	CALL M0C41		;Start in der Tabelle suchen
	JR C,M0C22		;ausgeben
	LD A,' '
	BIT 0,(IY+1)		;Leerzeichen ausgeben ?
	CALL Z,M0C3B

;Ausgabe der Meldung oder Tokens, bis ein Zeichen mit Bit 7=1

M0C22:	LD A,(DE)		;Zeichen aus Tabelle
	AND 7FH
	CALL M0C3B		;Ausgabe
	LD A,(DE)
	INC DE			;Pointer+1
	ADD A,A			;Bit 7 ?
	JR NC,M0C22		;nein

	POP DE			;D=0 Meldung, sonst
;D=0...5AH fuer Tokens
	CP 48H
	JR Z,M0C35		;wenn letztes Zeichen $ war
	CP 82H
	RET C			;falls kleiner 41H war

M0C35:	LD A,D			;bei Meldungen 'RND', 'INKEY$'
	CP 3			;und 'PI' RETURN
	RET C
	LD A,' '		;sonst Space ausgeben

;Ausgabe eines Zeichens in Register A und
;retten der Register BC,DE und HL

M0C3B:	PUSH DE
	EXX
	RST PRTOUT		;Ausgabe eines Zeichens
	EXX
	POP DE
	RET

;in Tabelle (=DE) den Start der Meldung oder des
;Tokens suchen

M0C41:	PUSH AF			;A=Nummer
	EX DE,HL		;HL=Anfang der Tabelle
	INC A			;fuer Suchschleife
M0C44:	BIT 7,(HL)		;bei jedem gesetztem Bit 7
	INC HL			;A dekrementieren bis 0
	JR Z,M0C44
	DEC A			;A=0 Meldung gefunden
	JR NZ,M0C44
	EX DE,HL		;DE zeigt auf Meldung
	POP AF			;Nummer
	CP 32			;Nummer <32
	RET C			;RETURN
	LD A,(DE)		;sonst erstes Zeichen laden
	SUB 41H			;auf >41H pruefen
	RET

;Subroutine zum Testen, ob ein Scrolling notwendig ist.
;Register B enthaelt die zu testende  Zeilennummer

M0C55:	BIT 1,(IY+1)		;Printer ?
	RET NZ			;ja

	LD DE,M0DD9		;Returnadresse
	PUSH DE
	LD A,B
	BIT 0,(IY+2)		;Test TV-Flag: Sprung,
	JP NZ,M0D02		;falls 'INPUT AT'
	CP (IY+31H)		;Zeilennummer > als DFSZ?
	JR C,M0C86		;ja, ERROR
	RET NZ			;wenn < DFSZ
				;weiter wenn =DFSZ
	BIT 4,(IY+2)		;automatisches Listing ?
	JR Z,M0C88		;nein
	LD E,(IY+2DH)		;Zeilenzaehler holen
	DEC E
	JR Z,M0CD2		;falls =0 Scrolling
	LD A,0			;Kanal k eroeffnen
	CALL OPKAN
	LD SP,(LISTSP)		;Returnadresse bei LIST
	RES 4,(IY+2)		;automatisches Listen beendet
	RET

M0C86:	RST ERRAUS		;Meldung 'OUT OF SCREEN'
	DEFB 4

M0C88:	DEC (IY+52H)		;Scroll-Zaehler-1
	JR NZ,M0CD2		;zumm direkten Scrolling
				;Ausgabe der Meldung 'SCROLL ?'
	LD A,24
	SUB B			;Scroll-Zaehler
	LD (SCRCT),A		;zuruecksetzen
	LD HL,(ATTRT)		;ATTRT und MASKT retten
	PUSH HL
	LD A,(PFLAG)		;PFLAG retten
	PUSH AF
	LD A,0FDH		;Kanal k oeffnen
	CALL OPKAN
	XOR A			;A=0=erste Meldung
	LD DE,SCROLL
	CALL PRTMEL		;laden und Ausgabe
	SET 5,(IY+2)		;merke: unt. Teil nach Tasten-
				;druck loeschen
	LD HL,FLAGS
	SET 3,(HL)		;L-Modus
	RES 5,(HL)		;'keine Taste bisher' anmerken
	EXX
	CALL WARTA		;1 Zeichen holen
	EXX
	CP 20H			;falls Tastendruck 'BREAK'
	JR Z,M0D00		;'STOP', 'N' oder 'n' war
	CP 0E2H			;Meldung 'BREAK - CONT repeats'
	JR Z,M0D00		;ausgeben
	OR 20H
	CP 6EH
	JR Z,M0D00
	LD A,0FEH		;sonst Kanal 'S' eroeffnen
	CALL OPKAN
	POP AF
	LD (PFLAG),A
	POP HL
	LD (ATTRT),HL

;Bildschirm rollen und Parameter neu setzen

M0CD2:	CALL M0DFE		;ganzen Bildschirm rollen
	LD B,(IY+31H)
	INC B			;Zeilennummer oberer Teil neu
	LD C,21H		;erste Spalte
	PUSH BC
	CALL M0E9B		;fuer diesen Teil entsprechendes
	LD A,H			;Attribute suchen
	RRCA
	RRCA
	RRCA
	AND 3
	OR 58H
	LD H,A
	LD DE,5AE0H		;Zeiger auf erstes Attribut der
				;untersten Zeile
	LD A,(DE)
	LD C,(HL)
	LD B,32			;32 * tauschen
	EX DE,HL
M0CF0:	LD (DE),A
	LD (HL),C
	INC DE
	INC HL
	DJNZ M0CF0
	POP BC			;Zeilen/Spalennummer der untersten Zeile
	RET

;Meldung 'SCROLL?'

SCROLL: DEFB 80H
	DEFM 'scroll?'+80H

M0D00:	RST ERRAUS		;Meldung:
	DEFB 0CH		;'BREAK - CONT repeats'

;unteren Bildschirm behandeln

M0D02:	CP 2			;unterer Teil zu gross ?
	JR C,M0C86		;ERROR

	ADD A,(IY+31H)
	SUB 19H			;Scrolling notwendig ?
	RET NC			;nein
	NEG			;A=Anzahl der Scrolls
	PUSH BC			;Zeile/Spalte
	LD B,A
	LD HL,(ATTRT)		;ATTRT, MASKT und
	PUSH HL
	LD HL,(PFLAG)		;PFLAG retten
	PUSH HL
	CALL AKTCOL
	LD A,B			;Scrollingzahl in A
M0D1C:	PUSH AF
	LD HL,DFSZ		;Zeilenanzahl+1 im unteren Bildschirmteil
	LD B,(HL)
	LD A,B
	INC A			;DFSZ + 1
	LD (HL),A
	LD HL,SPOSN+1		;Zeile/Spalte fuer Print
	CP (HL)			;unteren Teil scrollen ?
	JR C,M0D2D		;ja
	INC (HL)		;SPOSN-High +1
	LD B,18H		;ganzen Bildschirm scrollen
M0D2D:	CALL M0E00		;B Zeilen scrollen
	POP AF			;Scrollzaehler
	DEC A
	JR NZ,M0D1C		;nochmal
	POP HL
	LD (IY+57H),L		;PFLAG
	POP HL
	LD (ATTRT),HL		;ATTRT und MASKT
	LD BC,(SPOSN)
	RES 0,(IY+2)
	CALL M0DD9		;DFCC neu berechnen
	SET 0,(IY+2)		;Behandlung unterer Teil
	POP BC			;Zeile/Spalte
	RET

;Subroutine holt die aktuellen Farben in die
;'transparenten' Variablen ATTRT und MASKT

AKTCOL: XOR A
	LD HL,(ATTRP)		;aktuelle ATTRP und MASKP
	BIT 0,(IY+2)
	JR Z,M0D5B		;oberer Bildschirmteil
	LD H,A			;A und
	LD L,(IY+0EH)		;BORDCR benutzen fuer
M0D5B:	LD (ATTRT),HL		;ATTRT und MASKT
				;PFLAG neu setzen (fuer unteren Teil A=0)
	LD HL,PFLAG
	JR NZ,M0D65		;Sprung bei unteren Teil

	LD A,(HL)		;oberer Teil: alten Wert holen
	RRCA			;ungerade Bits (7,5,...)
M0D65:	XOR (HL)		;in die geraden kopieren
	AND 55H			;loeschen der geraden Bits
	XOR (HL)		;bei unteren Bildschirm
	LD (HL),A
	RET

;'CLS'-Befehl

M0D6B:	CALL M0DAF		;ganzen Bildschirm loeschen
M0D6E:	LD HL,TVFLAG		;unteren Teil nach Tastendruck
	RES 5,(HL)		;nicht loeschen
	SET 0,(HL)		;unteren Teil setzen
	CALL AKTCOL		;BORDCR nach ATTRT kopieren
	LD B,(IY+31H)		;laden DFSZ und unteren Teil
	CALL M0E44		;des Bildschirmes loeschen
	LD HL,5AC0H		;Adresse Attribut der Zeile 22
	LD A,(ATTRP)		;ATTRP als Atribut fuer
	DEC B			;unteren Teil
	JR M0D8E		;in die Schleife

M0D87:	LD C,32			;32 Zeichen pro Zeile
M0D89:	DEC HL
	LD (HL),A		;Werte setzen
	DEC C
	JR NZ,M0D89
M0D8E:	DJNZ M0D87

	LD (IY+31H),2		;2 Zeilen als unteren Teil setzen
M0D94:	LD A,0FDH		;Kanal K oeffnen
	CALL OPKAN
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	LD DE,AUSGAB		;Ausgabeadresse
	AND A
M0DA0:	LD (HL),E
	INC HL
	LD (HL),D
	INC HL
	LD DE,TASTIN		;Eingabeadresse
	CCF
	JR C,M0DA0
	LD BC,1721H		;Zeile/Spalte der ersten unteren Zeile
	JR M0DD9

;Bildschirm loeschen

M0DAF:	LD HL,0			;'COORDS' loeschen
	LD (COORDS),HL		;Koordinaten des letzten Plot
	RES 0,(IY+30H)		;FLAGS2: Bildschirm geloescht
	CALL M0D94		;Ein/Ausgabeadresse und Kanal K
	;original setzen
	LD A,0FEH		;Kanal S oeffnen
	CALL OPKAN
	CALL AKTCOL		;permanente Werte benutzen
	LD B,24			;24 Zeilen des Bildschirmes loeschen
	CALL M0E44
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	LD DE,AUSGAB
	LD (HL),E
	INC HL
	LD (HL),D
	LD (IY+52H),1		;Scrollzaehler Reset
	LD BC,1821H		;erste Zeile, erste Spalte

;Printposition auf Bildschirm setzen
;Einsprung mit Zeilen-/Spaltennummer in BC oder, falls
;Printer angesprochen, Spaltenposition in C fuer Printer

M0DD9:	LD HL,PTRBUF		;Druckerpuffer
	BIT 1,(IY+1)		;Printer ?
	JR NZ,M0DF4		;ja
	LD A,B			;Zeile
	BIT 0,(IY+2)		;Hauptbildschirmteil ?
	JR Z,M0DEE		;ja
	ADD A,(IY+31H)		;+ DFSZ
	SUB 24			;- 24 weil von unten gezaehlt wird
M0DEE:	PUSH BC
	LD B,A
	CALL M0E9B		;Adresse der Zeile berechnen
	POP BC
M0DF4:	LD A,33
	SUB C			;Spaltenzahl umrechnen
	LD E,A
	LD D,0
	ADD HL,DE
	JP NEUSTO

;Subroutine zum Rollen (Scrolling) des Bildschirmes
;B = Anzahl der gerollten Zeilen

M0DFE:	LD B,23			;Einstieg nach 'SCROLL ?'
M0E00:	CALL M0E9B		;Startadresse der Zeile suchen
	LD C,8			;8 Pixel-Zeilen
M0E05:	PUSH BC			;Zeilen/Pixelzaehler
	PUSH HL			;Startadresse
	LD A,B
	AND 7			;oberste Zeile eines Bildschirmdrittels ?
	LD A,B
	JR NZ,M0E19		;nein
M0E0D:	EX DE,HL
	LD HL,0F8E0H
	ADD HL,DE		;Adresse berechnen
	EX DE,HL
	LD BC,32		;32 Zeichen
	DEC A
	LDIR

;Pixel-Zeilen innerhalb der Bildschirmdrittel scrollen

M0E19:	EX DE,HL
	LD HL,0FFE0H
	ADD HL,DE		;Adresse berechnen
	EX DE,HL
	LD B,A			;Zeilennummer
	AND 7			;Anzahl, der in diesem Bilddrittel
	RRCA			;vorhandenen Zeichen berechnen
	RRCA
	RRCA
	LD C,A			;in C
	LD A,B			;Zeilennummer
	LD B,0			;BC = Anzahl 'ALLE ZEICHEN'
	LDIR
	LD B,7
	ADD HL,BC		;HL+700H fuer naechstes Drittel
	AND 0F8H		;naechstes Drittel bearbeiten ?
	JR NZ,M0E0D		;ja

;die obige Routine muss 8 mal, fuer jede Pixelzeile einmal,
;durchlaufen werden

	POP HL			;Startadresse
	INC H			;+1 fuer naechste Pixelzeile
	POP BC			;Pixelzaehler
	DEC C
	JR NZ,M0E05		;noch nicht 8*

;die Attribute muessen auch noch gescrollt werden

	CALL M0E88		;Attributadresse berechnen
	LD HL,0FFE0H		;Differenz von 32 fuer Attribute
	ADD HL,DE		;von DE abziehen
	EX DE,HL
	LDIR			;Attribute verschieben
	LD B,1			;unterste Zeile loeschen

;diese Routine loescht B Zeilen von unten

M0E44:	PUSH BC			;Zeilennummer
	CALL M0E9B		;Adresse in HL berechnen
	LD C,8			;8 Pixelzeilen
M0E4A:	PUSH BC			;Zeilennummer, Pixelzaehler
	PUSH HL			;Startadresse
	LD A,B			;Zeilenzahl
M0E4D:	AND 7
	RRCA			;Zeilenzahl berechnen und in
	RRCA
	RRCA
	LD C,A			;C
	LD A,B
	LD B,0
	DEC C			;Zeichenzahl - 1
	LD D,H
	LD E,L
	LD (HL),0		;ein Pixel loeschen
	INC DE
	LDIR			;weiter loeschen
	LD DE,701H		;fuer Pixelreihe im naechsten
	ADD HL,DE		;Drittel
	DEC A			;Zeilenzahl - 1
	AND 0F8H		;nur den Drittelzaehler
	LD B,A			;in B bringen
	JR NZ,M0E4D		;weitere Drittel bearbeiten

;pruefen ob 8* die Routine durchlaufen wurde

	POP HL			;Startadresse
	INC H
	POP BC			;Zeilen/Pixelzaehler
	DEC C			;Pixel - 1
	JR NZ,M0E4A		;noch nicht 8*
	CALL M0E88		;Adresse und Zahl der Attribut-
	;bytes suchen
	LD H,D
	LD L,E
	INC DE
	LD A,(ATTRP)		;ATTRP fuer Hauptteil benutzen
	BIT 0,(IY+2)		;TVFLAG: Hauptteil Bildschirm ?
	JR Z,M0E80		;ja
	LD A,(BORDCR)		;sonst Bordercolor benutzen
M0E80:	LD (HL),A		;erstes setzen
	DEC BC
	LDIR			;Rest setzen
	POP BC
	LD C,33			;Spaltenzahl auf erste setzen
	RET

;Berechne zu einer Bildschirmstelle die Adresse
;der Attribut-Informationen

M0E88:	LD A,H			;hoeheres Byte laden
	RRCA			;* 32
	RRCA
	RRCA
	DEC A			;- 1
	OR 50H			;Basisadresse der Attributinform.
	LD H,A			;hoeheres Byte berechnet
	EX DE,HL		;Low-Byte bleibt
	LD H,C			;C ist immer 0
	LD L,B			;Zeilennummer
	ADD HL,HL		;* 32
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD B,H			;in BC
	LD C,L
	RET

;bilde Speicheradresse einer Punktreihe des Schirmes in HL

M0E9B:	LD A,18H
	SUB B			;Zeile wird von unten gezaehlt
	LD D,A			;* 32
	RRCA
	RRCA
	RRCA
	AND 0E0H		;nur 3 Bits gueltig
	LD L,A
	LD A,D
	AND 18H
	OR BILD>>8		;Startadresse des Bildschirmes
	LD H,A
	RET

;COPY SCREEN

M0EAC:	DI
	LD B,0B0H		;176 (22*8) Druckzeilen
	;zu je einer Nadel
	LD HL,BILD		;Video - RAM
NXLINE: PUSH HL
	PUSH BC
	CALL PRLINE		;eine Nadelzeile ausgeben
	POP BC
	POP HL
	INC H			;256 Bytes weiter: naechste Zeile
	LD A,H
	AND 7
	JR NZ,NXLIN1		;noch innerhalb einer Zeile
	LD A,L
	ADD A,32		;32 Bytes weiter: naechste Zeile
	LD L,A
	CCF			;L uebergelaufen ?
	SBC A,A			;bei Ueberl. FFH sonst 0
	AND 0F8H		;Bit 0..3 zaehlen Nadelzeilen
	ADD A,H			;F8H addieren wenn L=0
	LD H,A
NXLIN1: DJNZ NXLINE
	JR M0EDA		;Ende COPY

;  Printerbuffer 5B00H...5BFFH ausdrucken

M0ECD:	DI
	LD HL,PTRBUF		;Druckerpuffer
	LD B,8			;8 Nadeln
M0ED3:	PUSH BC
	CALL PRLINE
	POP BC
	DJNZ M0ED3
M0EDA:	LD A,4			;Abschaltbit fuer Drucker
	OUT (0FBH),A		;ausgeben
	EI
M0EDF:	LD HL,PTRBUF		;Druckerpuffer
	LD (IY+46H),L
	;ganzen Printerbuffer loeschen
	XOR A
	LD B,A
CLRPRB: LD (HL),A
	INC HL
	DJNZ CLRPRB		;255 Nullen
	RES 1,(IY+30H)		;FLAGS2: Printerbuffer leer
	LD C,33
	JP M0DD9

;Ausgabe einer Druckerzeile (32 Bytes Nadelgrafik)

PRLINE: LD A,B			;Anzahl der noch zu druckenden
	CP 3			;Nadelreihen
	SBC A,A
	AND 2			;wenn nur noch 2 Zeilen
	OUT (0FBH),A		;Printermotor bremsen
	LD D,A
M0EFD:	CALL M1F54		;Stoptaste ?
	JR C,M0F0C
	LD A,4			;Abschaltbit fuer Printer
	OUT (0FBH),A
	EI
	CALL M0EDF		;Clear Printerbuffer
	RST ERRAUS		;Meldung:
	DEFB 0CH		;'BREAK - CONT REPEATS'

M0F0C:	IN A,(0FBH)		;Druckerstatus
	ADD A,A			;Bit 6 muss 0 sein, sonst
	RET M			;kein Drucker da
	JR NC,M0EFD		;warten wenn Bit 7 0 war

;alles zur Ausgabe bereit

	LD C,32			;32 Bytes
PRTBYT: LD E,(HL)		;auszugebendes Byte
	INC HL
	LD B,8
PRTBIT: RL D			;Bit 7 von Port FBH = Nadel
	RL E			;E bitweise ausgeben
	RR D
M0F1E:	IN A,(0FBH)
	RRA			;Bit 0 = Drucker Ready
	JR NC,M0F1E
	LD A,D
	OUT (0FBH),A		;OUT Nadel
	DJNZ PRTBIT
	DEC C			;naechstes Byte
	JR NZ,PRTBYT
	RET
;==================================================

;Editieren einer Bildschirmzeile
;Aufruf durch Hauptroutine zum eingeben einer Basiczeile
;oder bei einem Inputbefehl in einem Programm

M0F2C:	LD HL,(ERRSP)		;Errorstackpointer retten
	PUSH HL
M0F30:	LD HL,M107F		;Return fuer Editorerror
	PUSH HL
	LD (ERRSP),SP		;Errorstackpointer setzen
M0F38:	CALL WARTA		;ein Zeichen von Tastatur
	PUSH AF
	LD D,0
	LD E,(IY-1)		;Tastenklick
	LD HL,0C8H		;Tonhoehe
	CALL PIEPEN
	POP AF			;Zeichen
	LD HL,M0F38		;als RETURN
	PUSH HL
	CP 18H			;alle Zeichen, Tokens und
	JR NC,M0F81		;Grafikzeichen uebernehmen
	CP 7			;Komma ebenfalls
	JR C,M0F81
	CP 10H			;Editorzeichen ?
	JR C,M0F92		;ja

;Steuerzeichen 'INK' bis 'TAB'

	LD BC,2			;2 Plaetze bei 'INK' und 'PAPER'
	LD D,A
	CP 16H			;'INK' und 'PAPER' ?
	JR C,M0F6C		;ja

	INC BC			;fuer 'AT' und 'TAB' 3 Plaetze
	BIT 7,(IY+37H)		;'INPUT LINE' ?
	JP Z,M101E		;nein

	CALL WARTA		;naechstes Zeichen
	LD E,A			;in E

M0F6C:	CALL WARTA		;naechstes Zeichen fuer Steuercodes
	PUSH DE
	LD HL,(KCUR)		;Kursoradresse
	RES 0,(IY+7)		;'K' - Modus
	CALL MACHPL		;2 oder 3 Plaetze besorgen
	POP BC			;Steuercodes
	INC HL
	LD (HL),B		;speichern
	INC HL			;bei 'INK' und 'PAPER'
	LD (HL),C		;wird der Zweite wieder ueberschrieben
	JR M0F8B

;Routine fuegt ein Zeichen zu einer Editor- oder
;Inputzeile hinzu

M0F81:	RES 0,(IY+7)		;K-Modus
	LD HL,(KCUR)		;Kursoradresse
	CALL NUREIN		;1 Speicherplatz besorgen
M0F8B:	LD (DE),A
	INC DE			;Kursor + 1
	LD (KCUR),DE		;Kursoradresse
	RET

;Editiersteuerzeichen behandeln

M0F92:	LD E,A
	LD D,0			;Code in DE
	LD HL,M0FA0-7		;Adresse Editorzeichen
	ADD HL,DE		;Adresse Zeichen
	LD E,(HL)		;Offset holen
	ADD HL,DE		;Routineadresse
	PUSH HL
	LD HL,(KCUR)		;Kursoradresse
	RET			;in die Routine

;Offset der Editorsteuerzeichen

M0FA0:	DEFB M0FA9-$		;EDIT
	DEFB M1007-$		;CURSOR LINKS
	DEFB M100C-$		;CURSOR RECHTS
	DEFB M0FF3-$		;CURSOR DOWN
	DEFB M1059-$		;CURSOR UP
	DEFB M1015-$		;DELETE
	DEFB M1024-$		;ENTER
	DEFB M1076-$		;SYMBOL SHIFT
	DEFB M107C-$		;GRAPHICS

M0FA9:	LD HL,(EPPC)		;Zeilennummer
	BIT 5,(IY+37H)		;'INPUT MODUS' ?
	JP NZ,M1097		;ja
	CALL M196E		;Startadresse der Zeile suchen
	CALL ZSUCHE		;Zeilennummer dazu
	LD A,D			;Zeilennummer = 0 ?
	OR E
	JP Z,M1097		;nur Editorbereich loeschen
	PUSH HL			;Adresse Zeile
	INC HL
	LD C,(HL)		;Laenge	 Zeile
	INC HL
	LD B,(HL)
	LD HL,10
	ADD HL,BC		;10 + Laenge
	LD B,H
	LD C,L
	CALL M1F05		;Speicherplatztest
	CALL M1097		;Editorbereich loeschen
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	EX (SP),HL
	PUSH HL
	LD A,0FFH		;Kanal R oeffnen, um die Zeile
	CALL OPKAN		;in den Editorbereich zu kopieren
	POP HL			;Startadresse Zeile
	DEC HL
	DEC (IY+0FH)		;Zeilennummer-1
	CALL M1855		;Basiczeile listen
	INC (IY+0FH)		;Zeilennummer+1
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	INC HL			;Zeilennummer und Laenge uebergehen
	INC HL
	INC HL
	INC HL
	LD (KCUR),HL		;Kursoradresse
	POP HL			;vorherige Kanaladresse
	CALL M1615		;holen und Flags setzen
	RET			;zur Editorschleife

;Cursor-Down-Routine

M0FF3:	BIT 5,(IY+37H)		;INPUT MODUS ?
	JR NZ,M1001		;ja
	LD HL,EPPC		;aktuelle Editorzeile
	CALL M190F		;naechste Zeilennummer suchen
	JR M106E		;Listing ausgeben

M1001:	LD (IY+0),16		;ERRNR: Stop in Input
	JR M1024

;Cursor eins nach links

M1007:	CALL M1031		;Cursor bewegen
	JR SETKCU		;und KCUR setzen

;Cursor eins nach rechts

M100C:	LD A,(HL)		;aktuelles Zeichen=0DH ?
	CP 0DH
	RET Z			;ja
	INC HL			;Kursor auf naechstes Zeichen
SETKCU: LD (KCUR),HL		;Kursoradresse
	RET

;loeschen eines Zeichens beim Editieren

M1015:	CALL M1031		;Cursor nach links
	LD BC,1			;1 Zeichen entfernen
	JP RAUS2

M101E:	CALL WARTA		;2 Zeichen von der
	CALL WARTA		;Tastatur wegwerfen

M1024:	POP HL			;Aufruf von Editor und
	POP HL			;Editor-Error wegwerfen
M1026:	POP HL			;alter Wert von ERRSP
	LD (ERRSP),HL		;Errorstackpointer
	BIT 7,(IY+0)		;Fehler ?
	RET NZ			;nein
	LD SP,HL		;Sprung in Errorroutine
	RET

;Cursor nach links bis maximal an den Anfang der Zeile
;bewegen. HL zeigt auf Cursorposition.

M1031:	SCF			;DE auf ELINE (editieren) oder
	CALL EDDE		;auf WORKSP (INPUT) setzen
	SBC HL,DE		;CARRY =1, wenn Cursor am
	ADD HL,DE		;Anfang der Zeile
	INC HL
	POP BC			;eine Returnadresse wegwerfen
	RET C			;RET in Editorschleife, wenn
				;Cursor am Zeilenanfang
	PUSH BC
	LD B,H			;Cursoradresse in BC
	LD C,L
M103E:	LD H,D			;Zeichenadresse nach HL
	LD L,E
	INC HL
	LD A,(DE)		;Zeichen
	AND 0F0H		;>0F0H
	CP 10H			;und <20H ?
	JR NZ,M1051		;nein
	INC HL			;Parameter+1
	LD A,(DE)
	SUB 17H
	ADC A,0			;16H und 17H wird 0
	JR NZ,M1051
	INC HL
M1051:	AND A
	SBC HL,BC
	ADD HL,BC		;HL wie vorher
	EX DE,HL
	JR C,M103E
	RET

;Cursor eins nach oben bewegen

M1059:	BIT 5,(IY+37H)		;FLAGX: INPUT MODUS ?
	RET NZ			;ja
	LD HL,(EPPC)		;aktuelle Editorzeile
	CALL M196E		;Startadresse holen
	EX DE,HL		;HL eine Zeile davor
	CALL ZSUCHE		;Zeilennummer holen
	LD HL,EPPC+1
	CALL M191C		;Zeilennummer speichern
M106E:	CALL LISTAU		;ein Listing ausgeben
	LD A,0			;Kanal K wieder eroeffnen
	JP OPKAN

M1076:	BIT 7,(IY+37H)		;FLAGX
	JR Z,M1024		;bei 'INPUT LINE' nicht springen
M107C:	JP M0F81

;Einstieg, wenn ein Fehler beim Editieren auftrat

M107F:	BIT 4,(IY+48)		;Kanal K ?
	JR Z,M1026		;nein
	LD (IY+0),0FFH		;Fehlernummer loeschen
	LD D,0
	LD E,(IY-2)		;ein Piepser als
	LD HL,1A90H
	CALL PIEPEN		;Warnung ausgeben
	JP M0F30		;in Editor

;Editorbereich oder Workspace loeschen

M1097:	PUSH HL			;Pointer auf freien Platz
	CALL EDHLDE		;DE auf erstes und HL auf
	DEC HL			;letztes Zeichen setzen
	CALL RAUS1		;Speicher freigeben
	LD (KCUR),HL		;Kursoradresse
	LD (IY+7),0		;Modus 'K'
	POP HL
	RET

;diese Routine holt die letzte gedrueckte Taste und
;wertet 'CAPS LOCK', Modusaenderungen und Colorparameter
;direkt aus

TASTIN: BIT 3,(IY+2)		;Moduswechsel ?
	CALL NZ,M111D		;ja, Editorzeile anzeigen
	AND A
	BIT 5,(IY+1)		;CARRY und ZERO = 0 wenn,
	RET Z			;keine Taste gedrueckt
	LD A,(LASTK)		;Tastencode
	RES 5,(IY+1)		;abgeholt
	PUSH AF
	BIT 5,(IY+2)		;unteren Bildschirm loeschen ?
	CALL NZ,M0D6E		;ja
	POP AF
	CP ' '			;alle ASCII-Zeichen und Tokens
	JR NC,M111B		;uebernehmen
	CP 10H			;Steuerzeichen 10H...1FH ?
	JR NC,M10FA		;ja
	CP 6			;'MODE'-Zeichen und 'CAPS'-Lock
	JR NC,MODCAP		;ja

	LD B,A			;FLASH, BRIGHT und INVERSE
	AND 1			;Bit0 fuer aus oder ein
	LD C,A
	LD A,B
	RRA			;FLASH=12H, BRIGHT=13H, INVERSE=14H
	ADD A,12H
	JR M1105

MODCAP: JR NZ,MODES
	LD HL,FLAGS2		;Flags Teil 2
	LD A,8			;Bit 3 von FLAGS2
	XOR (HL)		;invertieren
	LD (HL),A
	JR M10F4

MODES:	CP 0EH			;nur 0EH (SYMBOL SHIFT) und
	RET C			;0FH (GRAPHICS) weiter
	SUB 0DH
	LD HL,MODE		;Tastenmodus (K,L,C,E,G)
	CP (HL)			;Modus geaendert ?
	LD (HL),A
	JR NZ,M10F4		;ja
	LD (HL),0		;sonst L-Modus
M10F4:	SET 3,(IY+2)		;Modus kann sich geandert haben
	CP A			;CARRY = 0
	RET

M10FA:	LD B,A
	AND 7			;Bit 0...2
	LD C,A
	LD A,10H		;Codes fuer 'INK'
	BIT 3,B			;ungeshifteter Code ?
	JR NZ,M1105		;nein
	INC A			;A='PAPER'-Code
M1105:	LD (IY-2DH),C		;Parameter speichern
	LD DE,TASTI2		;Input aendern
	JR M1113

TASTI2: LD A,(KDATA)		;noch eine Taste als Parameter
	LD DE,TASTIN		;holen und Input wieder normal
M1113:	LD HL,(CHANS)		;aktuelle Kanaladresse
	INC HL			;auf Input zeigen lassen
	INC HL
	LD (HL),E		;neuen Input-Einsprung speichern
	INC HL
	LD (HL),D
M111B:	SCF
	RET

;diese Routine wird immer aufgerufen, wenn der
;Editor- oder Inputbereich in den unteren
;Bildschirmteil geschrieben werden soll

M111D:	CALL AKTCOL		;aktuelle Farben bleiben
	RES 3,(IY+2)		;keine Mode-Aenderung
	RES 5,(IY+2)		;unteren Teil nicht loeschen
	LD HL,(SPOSNL)		;akt. Werte des unteren Teil
	PUSH HL			;retten
	LD HL,(ERRSP)		;Errorstackpointer
	PUSH HL
	LD HL,EDERR		;Fehlerreturnadresse
	PUSH HL
	LD (ERRSP),SP		;Errorstackpointer
	LD HL,(ECHOE)		;Position fuer Input
	PUSH HL
	SCF
	CALL EDDE
	EX DE,HL		;HL = Anfang; DE = Ende
	CALL M187D		;Zeile ausgeben
	EX DE,HL
	CALL M18E1		;Cursor anzeigen
	LD HL,(SPOSNL)		;SPOSNL mit ECHOE austauschen
	EX (SP),HL
	EX DE,HL
	CALL AKTCOL		;akt. Farben noch mal setzen

;den Rest einer Zeile mit Leerzeichen fuellen

RESTLE: LD A,(SPOSNL+1)		;akt. Bildschirmzeile
	SUB D			;mit der Alten vergleichen
	JR C,M117C		;Leerzeichenausgabe nicht noetig
	JR NZ,REST1		;nicht die gleiche Zeile
	LD A,E			;alte minus
	SUB (IY+50H)		;neue Spaltenposition
	JR NC,M117C
REST1:	LD A,' '
	PUSH DE
	CALL AUSGAB
	POP DE
	JR RESTLE

;Fehlerbehandlung im Editor

EDERR:	LD D,0
	LD E,(IY-2)		;= RASP
	LD HL,1A90H
	CALL PIEPEN		;Warnton
	LD (IY+0),0FFH		;Errornummer loeschen
	LD DE,(SPOSNL)		;akt. Wert SPOSNL fuer
	JR M117E		;ECHOE holen

;normaler Ausstieg bei Ausgabe der Editor- oder Inputzeile

M117C:	POP DE
	POP HL
M117E:	POP HL
	LD (ERRSP),HL		;Errorstackpointer
	POP BC			;SPOSNL alt
	PUSH DE			;SPOSNL neu
	CALL M0DD9		;Systemvariable setzen
	POP HL			;SPOSNL neu in ECHOE
	LD (ECHOE),HL		;Position fuer Input
	LD (IY+26H),0		;Errorzeiger loeschen
	RET

;HL auf die letzte Position, DE auf die Erste entweder
;des Editor- oder des Workspacebereichs setzen

EDHLDE: LD HL,(WORKSP)		;derzeitiger Workspace
	DEC HL			;Ende Editorbereich
	AND A
EDDE:	LD DE,(ELINE)		;Anfang Editorbereich
	BIT 5,(IY+37H)		;Editormode Return
	RET Z
	LD DE,(WORKSP)		;sonst DE auf Workspace
	RET C
	LD HL,(STKBOT)		;Anfang des Calculatorstacks
	RET

;Routine holt die versteckten Floatingpoint-Zahlen
;einer BASIC-Zeile zurueck

HOLFLO: LD A,(HL)
	CP 0EH			;Floatingpoint-Zahl ?
	LD BC,6			;wenn ja, 6 Plaetze
	CALL Z,RAUS2		;beschaffen
	LD A,(HL)
	INC HL
	CP 0DH			;Ende ?
	JR NZ,HOLFLO		;nein
	RET

;===================================================

;Systeminitialisierung bei Befehl 'NEW' oder durch
;RESET beim Einschalten
;Unterscheidung durch Reg A: FFH = 'NEW'

NEW:	DI
	LD A,0FFH
	LD DE,(RAMTOP)		;letzte Speicheradresse fuer Basic
	EXX
	LD BC,(PRAMT)		;letzte Speicheradresse
	LD DE,(RASP)		;Laenge Warnton
	LD HL,(UDG)		;Adresse der User Grafikzeichen
	EXX
;=======================================================

;Resetroutine mit Vorbereitung aller Pointer nach Start

;=======================================================
RESET1: LD B,A			;bei Kaltstart B=0
	LD A,7
	OUT (PFE),A
	LD A,3FH
	LD I,A
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	LD H,D
	LD L,E
M11DC:	LD (HL),2
	DEC HL
	CP H
	JR NZ,M11DC
RAMTES: AND A
	SBC HL,DE
	ADD HL,DE
	INC HL
	JR NC,RAMFER
	DEC (HL)
	JR Z,RAMFER
	DEC (HL)
	JR Z,RAMTES

RAMFER: DEC HL
	EXX
	LD (PRAMT),BC		;letzte Speicheradresse
	LD (RASP),DE		;Laenge Warnton
	LD (UDG),HL		;Adresse der User Grafikzeichen
	EXX
	INC B
	JR Z,SETTOP
	LD (PRAMT),HL		;letzte Speicheradresse
	LD DE,3EAFH		;Zeichengenerator laden
	LD BC,0A8H
	EX DE,HL
	LDDR
	EX DE,HL
	INC HL
	LD (UDG),HL		;Adresse der User Grafikzeichen
	DEC HL
	LD BC,040H
	LD (RASP),BC		;Laenge Warnton
SETTOP: LD (RAMTOP),HL		;letzte Speicheradresse fuer Basic
	LD HL,CHARR0-256
	LD (CHARS),HL		;Zeichensatzadresse -256

	LD HL,(RAMTOP)		;letzte Speicheradresse fuer Basic
	LD (HL),3EH
	DEC HL
	LD SP,HL
	DEC HL
	DEC HL
	LD (ERRSP),HL		;Errorstackpointer
	IM 1
	LD IY,ERRNR
	EI
	LD HL,KANMEM
	LD (CHANS),HL		;Pointer fuer Kanaldaten
	LD DE,INIKAN
	LD BC,21
	EX DE,HL
	LDIR

	EX DE,HL
	DEC HL
	LD (DATADD),HL		;Zeiger auf Endbyte der letzten Daten
	INC HL
	LD (PROG),HL		;Start des Basicprogrammes
	LD (VARS),HL		;Beginn der Variablen
	LD (HL),80H
	INC HL
	LD (ELINE),HL		;Adresse des eingegebenen Befehls
	LD (HL),0DH
	INC HL
	LD (HL),80H
	INC HL
	LD (WORKSP),HL		;derzeitiger Workspace
	LD (STKBOT),HL		;Anfang des Calculatorstacks
	LD (STKEND),HL		;Anfang des freien Speichers
	LD A,38H
	LD (ATTRP),A		;aktuelle Farben permanent
	LD (ATTRT),A		;aktuelle Farben temporaer
	LD (BORDCR),A		;Bordercolor * 8
	LD HL,523H
	LD (REPDEL),HL		;Zeitkonstante bis Repeat
	DEC (IY-3AH)
	DEC (IY-36H)
	LD HL,STDATA
	LD DE,STRMS		;Tabelle der offenen Kanaele
	LD BC,0EH
	LDIR
	SET 1,(IY+1)
	CALL M0EDF
	LD (IY+31H),2
	CALL M0D6B
	XOR A
	LD DE,COPRIG-1
	CALL PRTMEL
	SET 5,(IY+2)
	JR M12A9

;===================================================

;Hauptschleife des Ausfuehrprogramms

HAUPT:	LD (IY+31H),2
	CALL LISTAU
M12A9:	CALL CLREDI
HAUEDI: LD A,0
	CALL OPKAN
	CALL M0F2C
	CALL M1B17
	BIT 7,(IY+0)
	JR NZ,KORRIN
	BIT 4,(IY+30H)
	JR Z,M1303
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	CALL HOLFLO
	LD (IY+0),0FFH
	JR HAUEDI

KORRIN: LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	CALL M19FB
	LD A,B
	OR C
	JP NZ,EINFUE
	RST GETAKT
	CP 0DH
	JR Z,HAUPT
	BIT 0,(IY+30H)
	CALL NZ,M0DAF
	CALL M0D6E
	LD A,19H
	SUB (IY+4FH)
	LD (SCRCT),A		;Scrollzaehler
	SET 7,(IY+1)
	LD (IY+0),0FFH
	LD (IY+0AH),1
	CALL M1B8A


;Rueckkehr nach Ausfuehrung der Zeile bzw. Programm
;an diese Stelle zur Ausgabe einer Meldung
;der Interrupt muss freigegeben sein !

M1303:	HALT

	RES 5,(IY+1)
	BIT 1,(IY+30H)
	CALL NZ,M0ECD
	LD A,(ERRNR)
	INC A
M1313:	PUSH AF
	LD HL,0
	LD (IY+37H),H
	LD (IY+26H),H
	LD (DEFADD),HL		;Argument fuer Funktionen
	LD HL,1
	LD (STRMS+6),HL		;Tabelle der offenen Kanaele
	CALL CLREDI
	RES 5,(IY+37H)
	CALL M0D6E
	SET 5,(IY+2)
	POP AF
	LD B,A
	CP 0AH
	JR C,ERRAU
	ADD A,7
ERRAU:	CALL M15EF
	LD A,' '
	RST PRTOUT
	LD A,B
	LD DE,MELDU
	CALL PRTMEL
	XOR A
	LD DE,MELDS-1
	CALL PRTMEL
	LD BC,(PPC)		;aktuelle Nr. der Basiczeile
	CALL M1A1B
	LD A,':'
	RST PRTOUT
	LD C,(IY+0DH)
	LD B,0
	CALL M1A1B
	CALL M1097
	LD A,(ERRNR)
	INC A
	JR Z,M1386
	CP 9
	JR Z,M1373
	CP 15H
	JR NZ,M1376
M1373:	INC (IY+0DH)
M1376:	LD BC,3
	LD DE,OSPCC		;naechster Befehl fuer Cont.
	LD HL,NSPPC		;Befehl der Zeile bei Sprung
	BIT 7,(HL)
	JR Z,M1384
	ADD HL,BC
M1384:	LDDR
M1386:	LD (IY+0AH),0FFH
	RES 3,(IY+1)
	JP HAUEDI

;Meldungen des Betriebssystems
;das letzte Byte einer Meldung wird mit 80H geodert

MELDU:	DEFB 80H
MELD0:	DEFM 'OK'+80H
MELD1:	DEFM 'NEXT without FOR'+80H
MELD2:	DEFM 'Variable not found'+80H
MELD3:	DEFM 'Subscript wrong'+80H
MELD4:	DEFM 'Out of memory'+80H
MELD5:	DEFM 'Out of screen'+80H
MELD6:	DEFM 'Number too big'+80H
MELD7:	DEFM 'RETURN without GOSUB'+80H
MELD8:	DEFM 'End of file'+80H
MELD9:	DEFM 'STOP statement'+80H
MELDA:	DEFM 'Invalid argument'+80H
MELDB:	DEFM 'Integer out of range'+80H
MELDC:	DEFM 'Nonsense in BASIC'+80H
MELDD:	DEFM 'BREAK - CONT repeats'+80H
MELDE:	DEFM 'Out of DATA'+80H
MELDF:	DEFM 'Invalid file name'+80H
MELDG:	DEFM 'No room for line'+80H
MELDH:	DEFM 'STOP in INPUT'+80H
MELDI:	DEFM 'FOR without NEXT'+80H
MELDJ:	DEFM 'Invalid I/O device'+80H
MELDK:	DEFM 'Invalid colour'+80H
MELDL:	DEFM 'BREAK into program'+80H
MELDM:	DEFM 'RAMTOP no good'+80H
MELDN:	DEFM 'Statement lost'+80H
MELDO:	DEFM 'Invalid stream'+80H
MELDP:	DEFM 'FN without DEF'+80H
MELDQ:	DEFM 'Parameter error'+80H
MELDR:	DEFM 'Tape loading error'+80H
MELDS:	DEFM ', '+80H
COPRIG: DEFM 7FH,' 1982 Sinclair Research Ltd'+80H

NOROOM: LD A,10H
	LD BC,0
	JP M1313

;eine neue BASIC-Zeile ins Programm einfuegen
;wenn die Zeile schon existiert, dann ersetzen oder,
;falls nur eine Zeilennummer eingegeben wurde,
;diese Zeile loeschen

EINFUE: LD (EPPC),BC		;aktuelle Editorzeile
	LD HL,(CHADD)		;Adr. des naechsten zu interpret. Zeichens
	EX DE,HL
	LD HL,NOROOM
	PUSH HL
	LD HL,(WORKSP)		;derzeitiger Workspace
	SCF
	SBC HL,DE
	PUSH HL
	LD H,B
	LD L,C
	CALL M196E
	JR NZ,EINFU1
	CALL M19B8
	CALL RAUS2

EINFU1: POP BC
	LD A,C
	DEC A
	OR B
	JR Z,M15AB

	PUSH BC
	INC BC
	INC BC
	INC BC
	INC BC
	DEC HL
	LD DE,(PROG)		;Start des Basicprogrammes
	PUSH DE
	CALL MACHPL
	POP HL
	LD (PROG),HL		;Start des Basicprogrammes
	POP BC
	PUSH BC
	INC DE
	LD HL,(WORKSP)		;derzeitiger Workspace
	DEC HL
	DEC HL
	LDDR
	LD HL,(EPPC)		;aktuelle Editorzeile
	EX DE,HL
	POP BC
	LD (HL),B
	DEC HL
	LD (HL),C
	DEC HL
	LD (HL),E
	DEC HL
	LD (HL),D
M15AB:	POP AF
	JP HAUPT

;Kanalinformationen zum Initialisieren
;K = Keyboard  (Tastatur)
;S = Screen (Bildschirm)
;R = Workspace (Arbeitsspeicher)
;P = Printer  (Drucker)

INIKAN: DEFB 0F4H
	DEFB 9
	DEFW TASTIN
	DEFB 'K'
	DEFB 0F4H
	DEFB 9
	DEFW INVIO
	DEFB 'S'
	DEFB 81H
	DEFB 0FH
	DEFW INVIO
	DEFB 'R'
	DEFB 0F4H
	DEFB 9
	DEFW INVIO
	DEFB 'P'
	DEFB 80H

INVIO:	RST ERRAUS
	DEFB 12H		;'INVALID I/O'

;Stream Daten

STDATA: DEFB 1
	DEFB 0
	DEFB 6
	DEFB 0
	DEFB 0BH
	DEFB 0
	DEFB 1
	DEFB 0
	DEFB 1
	DEFB 0
	DEFB 6
	DEFB 0
	DEFB 010H
	DEFB 0

;Diese Subroutine ueberwacht den Aufruf der aktuellen
;Input-Subroutine

WARTA:	BIT 5,(IY+2)
	JR NZ,M15DE
	SET 3,(IY+2)
M15DE:	CALL M15E6
	RET C
	JR Z,M15DE

	RST ERRAUS
	DEFB 7			;'END OF FILE'

;Inputroutine fuer den gerade aktuellen File

M15E6:	EXX
	PUSH HL
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	INC HL
	INC HL
	JR INDCAL

;allgemeine Ausgaberoutine
;AUSGA2 mit auszugebenden Zeichen in A

M15EF:	LD E,30H
	ADD A,E
AUSGA2: EXX
	PUSH HL
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse

;die aktuelle Ausgabe- oder Eingaberoutine aufrufen
;HL zeigt auf die Adresse, an der die Sprungadresse
;zu finden ist

INDCAL: LD E,(HL)
	INC HL
	LD D,(HL)
	EX DE,HL
	CALL INDJMP
	POP HL
	EXX
	RET

;Routine um einen Kanal zu eroeffnen
;A enthaelt gueltige 'STREAM'-Nummer und der
;entsprechende Kanal wird eroeffnet

OPKAN:	ADD A,A
	ADD A,16H
	LD L,A
	LD H,5CH
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD A,D
	OR E
	JR NZ,M1610

ISTREA: RST ERRAUS
	DEFB 17H		;'INVALID STREAM'

M1610:	DEC DE
	LD HL,(CHANS)		;Pointer fuer Kanaldaten
	ADD HL,DE
M1615:	LD (CURCHL),HL		;aktuelle I/O Infoadresse
	RES 4,(IY+30H)
	INC HL
	INC HL
	INC HL
	INC HL
	LD C,(HL)
	LD HL,KLOOK
	CALL SUCHTA
	RET NC
	LD D,0
	LD E,(HL)
	ADD HL,DE
INDJMP: JP (HL)

KLOOK:	DEFB 'K'
	DEFB KANALK-$

	DEFB 'S'
	DEFB KANALS-$

	DEFB 'P'
	DEFB KANALP-$

	DEFB 0

KANALK: SET 0,(IY+2)
	RES 5,(IY+1)
	SET 4,(IY+30H)
	JR KANS1

KANALS: RES 0,(IY+2)
KANS1:	RES 1,(IY+1)
	JP AKTCOL

KANALP: SET 1,(IY+1)
	RET

;diese Routine schafft einen benoetigten Speicherraum.
;die Bytezahl steht in BC
;HL zeigt hinter die Position an der Platz benoetigt wird.

NUREIN: LD BC,1
MACHPL: PUSH HL
	CALL M1F05
	POP HL
	CALL POINTE
	LD HL,(STKEND)		;Anfang des freien Speichers
	EX DE,HL
	LDDR
	RET

;diese Subroutine veraendert alle Systemvariablen (Pointer),
;die auf den Positionen hinter dem Speicherplatz zeigen (=HL),
;an dem Platz etc. geschaffen werden soll. BC muss die Anzahl der
;Bytes enthalten.

POINTE: PUSH AF
	PUSH HL
	LD HL,VARS		;Beginn der Variablen
	LD A,14

POINTL: LD E,(HL)
	INC HL
	LD D,(HL)
	EX (SP),HL
	AND A
	SBC HL,DE
	ADD HL,DE
	EX (SP),HL
	JR NC,NOCHA
	PUSH DE
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	LD (HL),D
	DEC HL
	LD (HL),E
	INC HL
	POP DE
NOCHA:	INC HL
	DEC A
	JR NZ,POINTL

	EX DE,HL
	POP DE
	POP AF
	AND A
	SBC HL,DE
	LD B,H
	LD C,L
	INC BC
	ADD HL,DE
	EX DE,HL
	RET

;holen der Nummer der Zeile, die durch HL adressiert wird.
;Falls ungueltig, Test ob DE auf eine gueltige Nummer zeigt.
;Trifft dies auch nicht zu, so wird 0000 als Zeilennummer in
;DE geladen (Nummer<10000). Normalerweise enthaelt DE die
;Zeilennummer und HL die Startadresse dieser Zeile bei RETURN.

ZEINUL: DEFW 0

ZDAVOR: EX DE,HL
	LD DE,ZEINUL

ZSUCHE: LD A,(HL)
	AND 0C0H
	JR NZ,ZDAVOR
	LD D,(HL)
	INC HL
	LD E,(HL)
	RET

;Routine wird normalerweise ueber RESTART 30, (BC) Plaetze
;besorgen, aufgerufen. Stack enthaelt daher als letzten Wert
;'WORKSPACE' und davor die Anzahl 'BC'.

RESERV: LD HL,(STKBOT)		;Anfang des Calculatorstacks
	DEC HL
	CALL MACHPL
	INC HL
	INC HL
	POP BC
	LD (WORKSP),BC		;derzeitiger Workspace
	POP BC
	EX DE,HL
	INC HL
	RET

;Routine loescht den Editorbereich, den Workspace und den
;Calculatorstack

CLREDI: LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	LD (HL),0DH
	LD (KCUR),HL		;Kursoradresse
	INC HL
	LD (HL),80H
	INC HL
	LD (WORKSP),HL		;derzeitiger Workspace
CLRWOR: LD HL,(WORKSP)		;derzeitiger Workspace
	LD (STKBOT),HL		;Anfang des Calculatorstacks
CLRCAL: LD HL,(STKBOT)		;Anfang des Calculatorstacks
	LD (STKEND),HL		;Anfang des freien Speichers
	PUSH HL
	LD HL,MEMBOT		;Calculatorspeicher
	LD (MEM),HL		;Zeiger auf Calculatorspeicher
	POP HL
	RET

;die Editorzeile wieder entfernen

M16D4:	LD DE,(ELINE)		;Adresse des eingegebenen Befehls
	JP RAUS1

;Subroutine zum durchsuchen von Tabellen (Ende = 00)
;HL zeigt auf deren Anfang  und C enthaelt das zu suchende
;Zeichen. Carry gesetzt = gefunden.

SUCHT1: INC HL
SUCHTA: LD A,(HL)
	AND A
	RET Z
	CP C
	INC HL
	JR NZ,SUCHT1
	SCF
	RET

;CLOSE#-Subroutine zum schliessen von Streams
;fuer Streams 00-03 werden die Grunddaten immer gesetzt,
;so dass diese nicht geschlossen werden koennen

M16E5:	CALL STRDAT
	CALL CLOKSP
	LD BC,0
	LD DE,0A3E2H
	EX DE,HL
	ADD HL,DE
	JR C,M16FC
	LD BC,15D4H
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)
M16FC:	EX DE,HL
	LD (HL),C
	INC HL
	LD (HL),B
	RET
;Streamkode K, S oder P pruefen und Stream schliessen

CLOKSP: PUSH HL
	LD HL,(CHANS)		;Pointer fuer Kanaldaten
	ADD HL,BC
	INC HL
	INC HL
	INC HL
	LD C,(HL)
	EX DE,HL
	LD HL,CSTRTA
	CALL SUCHTA
	LD C,(HL)
	LD B,0
	ADD HL,BC
	JP (HL)

;Tabelle fuer CLOSE STREAM

CSTRTA: DEFB 'K'
	DEFB CLOSTR-$
	DEFB 'S'
	DEFB CLOSTR-$
	DEFB 'P'
	DEFB CLOSTR-$

;CLOSE STREAM

CLOSTR: POP HL
	RET

;nach BC die Daten eines Stream holen

STRDAT: CALL INTEG1
	CP 10H
	JR C,M1727
M1725:	RST ERRAUS
	DEFB 17H

M1727:	ADD A,3
	RLCA
	LD HL,STRMS		;Tabelle der offenen Kanaele
	LD C,A
	LD B,0
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)
	DEC HL
	RET

;OPEN#-Subroutine
;Kanalkode muss K, S oder P sein

STROPE: RST CALRUF
	DEFB 1
	DEFB 38H
	CALL STRDAT
	LD A,B
	OR C
	JR Z,STROP1
	EX DE,HL
	LD HL,(CHANS)		;Pointer fuer Kanaldaten
	ADD HL,BC
	INC HL
	INC HL
	INC HL
	LD A,(HL)
	EX DE,HL
	CP 'K'
	JR Z,STROP1
	CP 'S'
	JR Z,STROP1
	CP 'P'
	JR NZ,M1725
STROP1: CALL M175D
	LD (HL),E
	INC HL
	LD (HL),D
	RET

M175D:	PUSH HL
	CALL M2BF1
	LD A,B
	OR C
	JR NZ,M1767
M1765:	RST ERRAUS
	DEFB 0EH

M1767:	PUSH BC
	LD A,(DE)
	AND 0DFH
	LD C,A
	LD HL,OPTAB
	CALL SUCHTA
	JR NC,M1765
	LD C,(HL)
	LD B,0
	ADD HL,BC
	POP BC
	JP (HL)

;Tabelle fuer Streameroeffnung

OPTAB:	DEFB 'K'
	DEFB OPENK-$

	DEFB 'S'
	DEFB OPENS-$

	DEFB 'P'
	DEFB OPENP-$
	DEFB 0

OPENK:	LD E,1
	JR M178B

OPENS:	LD E,6
	JR M178B

OPENP:	LD E,10H
M178B:	DEC BC
	LD A,B
	OR C
	JR NZ,M1765
	LD D,A
	POP HL
	RET

;CAT-, ERASE-, FORMAT- und MOVE-Befehle ergeben die
;Fehlermeldung 'INVALID STREAM'

M1793:	JR M1725

;LIST- und LLIST-Routine
;Ausgabe der Zeilennummer, Tokenumwandlung, Cursordarstellung usw.

LISTAU: LD (LISTSP),SP		;Returnadresse bei LIST
	LD (IY+2),10H
	CALL M0DAF
	SET 0,(IY+2)
	LD B,(IY+31H)
	CALL M0E44
	RES 0,(IY+2)
	SET 0,(IY+30H)
	LD HL,(EPPC)		;aktuelle Editorzeile
	LD DE,(STOP)		;Nummer der obersten Zeile eines Listings
	AND A
	SBC HL,DE
	ADD HL,DE
	JR C,M17E1
	PUSH DE
	CALL M196E
	LD DE,2C0H
	EX DE,HL
	SBC HL,DE
	EX (SP),HL
	CALL M196E
	POP BC
M17CE:	PUSH BC
	CALL M19B8
	POP BC
	ADD HL,BC
	JR C,M17E4
	EX DE,HL
	LD D,(HL)
	INC HL
	LD E,(HL)
	DEC HL
	LD (STOP),DE		;Nummer der obersten Zeile eines Listings
	JR M17CE

M17E1:	LD (STOP),HL		;Nummer der obersten Zeile eines Listings
M17E4:	LD HL,(STOP)		;Nummer der obersten Zeile eines Listings
	CALL M196E
	JR Z,M17ED
	EX DE,HL
M17ED:	CALL M1833
	RES 4,(IY+2)
	RET

;Einstieg bei 'LLIST'

M17F5:	LD A,3
	JR M17FB

M17F9:	LD A,2
M17FB:	LD (IY+2),0
	CALL M2530
	CALL NZ,OPKAN
	RST GETAKT
	CALL M2070
	JR C,M181F
	RST GETAKT
	CP ';'
	JR Z,M1814
	CP ','
	JR NZ,M181A
M1814:	RST GETNXT
	CALL PAR06
	JR M1822

M181A:	CALL M1CE6
	JR M1822

M181F:	CALL M1CDE
M1822:	CALL M1BEE
	CALL M1E99
	LD A,B
	AND 3FH
	LD H,A
	LD L,C
	LD (EPPC),HL		;aktuelle Editorzeile
	CALL M196E
M1833:	LD E,1

;Schleife zum Listen mehrerer Zeilen

M1835:	CALL M1855
	RST PRTOUT
	BIT 4,(IY+2)
	JR Z,M1835
	LD A,(DFSZ)		;Zeilenanzahl+1 im unteren Bildschirmteil
	SUB (IY+4FH)
	JR NZ,M1835
	XOR E
	RET Z

	PUSH HL
	PUSH DE
	LD HL,STOP		;Nummer der obersten Zeile eines Listings
	CALL M190F
	POP DE
	POP HL
	JR M1835

	;Ausgabe einer kompletten Basiczeile

M1855:	LD BC,(EPPC)		;aktuelle Editorzeile
	CALL M1980
	LD D,3EH
	JR Z,M1865
	LD DE,0
	RL E
M1865:	LD (IY+2DH),E
	LD A,(HL)
	CP 40H
	POP BC
	RET NC

	PUSH BC
	CALL M1A28
	INC HL
	INC HL
	INC HL
	RES 0,(IY+1)
	LD A,D
	AND A
	JR Z,M1881

	RST PRTOUT
M187D:	SET 0,(IY+1)
M1881:	PUSH DE
	EX DE,HL
	RES 2,(IY+30H)
	LD HL,FLAGS		;Bit 1= Printer ein
	RES 2,(HL)
	BIT 5,(IY+37H)
	JR Z,M1894
	SET 2,(HL)
M1894:	LD HL,(XPTR)		;Adresse des Zeichens nach ? bei Error
	AND A
	SBC HL,DE
	JR NZ,M18A1
	LD A,'?'
	CALL M18C1
M18A1:	CALL M18E1
	EX DE,HL
	LD A,(HL)
	CALL M18B6
	INC HL
	CP 0DH
	JR Z,M18B4
	EX DE,HL
	CALL M1937
	JR M1894

M18B4:	POP DE
	RET

;wenn Zeichen ein Zahlenmerker ist, dann die
;Floating - Pointzahl uebergehen

M18B6:	CP 0EH
	RET NZ

	INC HL
	INC HL
	INC HL
	INC HL
	INC HL
	INC HL
	LD A,(HL)
	RET

;Ausgabe eines blinkenden Zeichens

M18C1:	EXX
	LD HL,(ATTRT)		;aktuelle Farben temporaer
	PUSH HL
	RES 7,H
	SET 7,L
	LD (ATTRT),HL		;aktuelle Farben temporaer
	LD HL,PFLAG		;Printerflag
	LD D,(HL)
	PUSH DE
	LD (HL),0
	CALL AUSGAB
	POP HL
	LD (IY+57H),H
	POP HL
	LD (ATTRT),HL		;aktuelle Farben temporaer
	EXX
	RET

;Ausgabe des Cursors
;falls aktuelle Ausgabeposition nicht Cursorposition ist,
;sofort RETURN, sonst den entsprechenden Cursor (C/E/G/K/L)
;drucken

M18E1:	LD HL,(KCUR)		;Kursoradresse
	AND A
	SBC HL,DE
	RET NZ

	LD A,(MODE)		;Tastenmodus (K,L,C,E,G)
	RLC A
	JR Z,M18F3
	ADD A,43H
	JR M1909

M18F3:	LD HL,FLAGS		;Bit 1= Printer ein
	RES 3,(HL)
	LD A,'K'
	BIT 2,(HL)
	JR Z,M1909
	SET 3,(HL)
	INC A
	BIT 3,(IY+30H)
	JR Z,M1909
	LD A,'C'
M1909:	PUSH DE
	CALL M18C1
	POP DE
	RET

;bei Einstieg zeigt HL auf STOP oder EPPC. Am Ende
;enthaelt die jeweilige Variable die Zeilennummer.

M190F:	LD E,(HL)
	INC HL
	LD D,(HL)
	PUSH HL
	EX DE,HL
	INC HL
	CALL M196E
	CALL ZSUCHE
	POP HL
M191C:	BIT 5,(IY+37H)
	RET NZ

	LD (HL),D
	DEC HL
	LD (HL),E
	RET

;Routine gibt Zeichen einer Basiczeile aus. Bei Zahlen
;werden fuehrende Space unterdrueckt (A=FFH) oder nicht.

M1925:	LD A,E
	AND A
	RET M
	JR M1937

;Wandlung einer Zeilennummer in HL in eine Dezimalzahl
;dazu enthaelt BC, je nach Aufruf, die Werte -1000, -100
;oder -10 (deshalb Addition).

M192A:	XOR A
M192B:	ADD HL,BC
	INC A
	JR C,M192B
	SBC HL,BC
	DEC A
	JR Z,M1925
	JP M15EF

;hier alle Zeichen, Controlcodes und Tokens ausgeben

M1937:	CALL ZIFFER
	JR NC,M196C
	CP '!'
	JR C,M196C
	RES 2,(IY+1)
	CP 0CBH
	JR Z,M196C
	CP ':'
	JR NZ,M195A
	BIT 5,(IY+37H)
	JR NZ,M1968
	BIT 2,(IY+30H)
	JR Z,M196C
	JR M1968

M195A:	CP '"'
	JR NZ,M1968
	PUSH AF
	LD A,(FLAGS2)		;Flags Teil 2
	XOR 4
	LD (FLAGS2),A		;Flags Teil 2
	POP AF
M1968:	SET 2,(IY+1)
M196C:	RST PRTOUT
	RET

;Subroutine zum suchen des Anfangs einer Zeile nach
;deren Zeilennummer (in HL). Wird diese Zeile nicht
;gefunden, wird die Startadresse der naechsten Zeile
;uebergeben, jeweils in HL, und in DE die Adresse der
;Zeile davor. Falls Zeile gefunden wurde, ist das ZERO-
;Flag gesetzt.

M196E:	PUSH HL
	LD HL,(PROG)		;Start des Basicprogrammes
	LD D,H
	LD E,L
M1974:	POP BC
	CALL M1980
	RET NC
	PUSH BC
	CALL M19B8
	EX DE,HL
	JR M1974

;Vergleich einer Zeilennummer in Bc mit einer durch HL
;adressierten Zeile

M1980:	LD A,(HL)
	CP B
	RET NZ
	INC HL
	LD A,(HL)
	DEC HL
	CP C
	RET

;diese Routine sucht das durch das Register D bestimmte
;Zeichen einer Zeile oder das Zeichen, Token etc. welches
;in Register E enthalten ist

M1988:	INC HL
	INC HL
	INC HL
;normaler Einstieg
M198B:	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	LD C,0
M1990:	DEC D
	RET Z

	RST GETNXT
	CP E
	JR NZ,M199A
	AND A
	RET

M1998:	INC HL
	LD A,(HL)
M199A:	CALL M18B6
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	CP '"'
	JR NZ,M19A5
	DEC C
M19A5:	CP ':'
	JR Z,M19AD
	CP 0CBH
	JR NZ,M19B1
M19AD:	BIT 0,C
	JR Z,M1990
M19B1:	CP 0DH
	JR NZ,M1998
	DEC D
	SCF
	RET

;Subroutine zum Suchen der naechsten Basiczeile oder der
;naechsten Variablen

M19B8:	PUSH HL
	LD A,(HL)
	CP 40H
	JR C,M19D5
	BIT 5,A
	JR Z,M19D6
	ADD A,A
	JP M,M19C7
	CCF
M19C7:	LD BC,5
	JR NC,M19CE
	LD C,12H
M19CE:	RLA
	INC HL
	LD A,(HL)
	JR NC,M19CE
	JR M19DB

M19D5:	INC HL
M19D6:	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	INC HL
M19DB:	ADD HL,BC
	POP DE

;Subroutine zum Berechnen einer Differenz in BC.
;HL und DE sind bei RETURN vertauscht.

DIFFER: AND A
	SBC HL,DE
	LD B,H
	LD C,L
	ADD HL,DE
	EX DE,HL
	RET

;diese Routine entfernt Speicherbereiche und korrigiert
;alle entsprechenden Pointer.
;Am ersten Einstieg enthaelt DE die erste zu entfernende
;und HL die erste, nicht mehr zu entfernende, Speicherstelle.
;Beim zweiten Einstiegspunkt enthaelt HL die erste zu ent-
;fernende Speicherstelle und BC die Anzahl.

RAUS1:	CALL DIFFER
RAUS2:	PUSH BC
	LD A,B
	CPL
	LD B,A
	LD A,C
	CPL
	LD C,A
	INC BC
	CALL POINTE
	EX DE,HL
	POP HL
	ADD HL,DE
	PUSH DE
	LDIR
	POP HL
	RET

;Einlesen einer Zeilennummer beim Editieren.
;Bei einem Direktkommando wird diese zu Null gesetzt.
;Das Ergebnis steht immer in BC.

M19FB:	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	RST GETNXT
	LD HL,MEMBOT		;Calculatorspeicher
	LD (STKEND),HL		;Anfang des freien Speichers
	CALL M2D3B
	CALL M2DA2
	JR C,M1A15
	LD HL,0D8F0H
	ADD HL,BC
M1A15:	JP C,M1C8A
	JP CLRCAL

;Zeilennummerausgabe
;Inhalt BC wird in dezimal gewandelt und ausgegeben.

M1A1B:	PUSH DE
	PUSH HL
	XOR A
	BIT 7,B
	JR NZ,M1A42
	LD H,B
	LD L,C
	LD E,0FFH
	JR M1A30

;Die durch HL adressierte (hexadezimale) Zeilennummer
;in dezimal wandeln und ausgeben (mit fuehrenden Spaces)

M1A28:	PUSH DE
	LD D,(HL)
	INC HL
	LD E,(HL)
	PUSH HL
	EX DE,HL
	LD E,' '
M1A30:	LD BC,0FC18H
	CALL M192A
	LD BC,0FF9CH
	CALL M192A
	LD C,0F6H
	CALL M192A
	LD A,L
M1A42:	CALL M15EF
	POP HL
	POP DE
	RET

;=====================================================

;Basicbefehlsinterpretation

;Offsettabelle der Basicbefehle fuer die Zweite Tabelle

BEFOFF: DEFB PADEFN-$
	DEFB PACAT-$
	DEFB PAFORM-$
	DEFB PAMOVE-$
	DEFB PAERAS-$
	DEFB PAOPEN-$
	DEFB PACLOS-$
	DEFB PAMERG-$
	DEFB PAVERI-$
	DEFB PABEEP-$
	DEFB PACIRC-$
	DEFB PAINK-$
	DEFB PAPAPE-$
	DEFB PAFLAS-$
	DEFB PABRIG-$
	DEFB PAINVE-$
	DEFB PAOVER-$
	DEFB PAOUT-$
	DEFB PALPRI-$
	DEFB PALLIS-$
	DEFB PASTOP-$
	DEFB PAREAD-$
	DEFB PADATA-$
	DEFB PAREST-$
	DEFB PANEW-$
	DEFB PABORD-$
	DEFB PACONT-$
	DEFB PADIM-$
	DEFB PAREM-$
	DEFB PAFOR-$
	DEFB PAGOTO-$
	DEFB PAGOSU-$
	DEFB PAINPU-$
	DEFB PALOAD-$
	DEFB PALIST-$
	DEFB PALET-$
	DEFB PAPAUS-$
	DEFB PANEXT-$
	DEFB PAPOKE-$
	DEFB PAPRIN-$
	DEFB PAPLOT-$
	DEFB PARUN-$
	DEFB PASAVE-$
	DEFB PARAND-$
	DEFB PAIF-$
	DEFB PACLS-$
	DEFB PADRAW-$
	DEFB PACLEA-$
	DEFB PARETU-$
	DEFB PACOPY-$

;Parametertabelle fuer die Befehle
;Bytes im Bereich von 00...0BH geben die weiteren
;notwendigen Parameter fuer die einzelnen Befehle an

;PAR00: keine weiteren Parameter
;PAR01: bei LET, eine Variable wird gebraucht
;PAR02: ein numerischer/String-Ausdruck muss folgen
;PAR03: numerischer Ausdruck kann folgen, sonst 0
;PAR04: eine einfache Variable muss folgen
;PAR05: ein Parametersatz kann folgen
;PAR06: ein numerischer Ausdruck muss folgen
;PAR07: Farbenbehandlung etc.
;PAR08: zwei durch ',' geterennte, numerische Ausdruecke
;PAR09: wie 08,aber Farbenausdruecke duerfen vorangehen
;PAR0A: ein String-Ausdruck muss folgen
;PAR0B: bearbeitet Kassettenroutinen

PALET:	DEFB 1
	DEFB '='
	DEFB 2
PAGOTO: DEFB 6
	DEFB 0
	DEFW M1E67

PAIF:	DEFB 6
	DEFB 0CBH
	DEFB 5
	DEFW M1CF0

PAGOSU: DEFB 6
	DEFB 0
	DEFW M1EED

PASTOP: DEFB 0
	DEFW M1CEE

PARETU: DEFB 0
	DEFW M1F23

PAFOR:	DEFB 4
	DEFB '='
	DEFB 6
	DEFB 0CCH
	DEFB 6
	DEFB 5
	DEFW M1D03

PANEXT: DEFB 4
	DEFB 0
	DEFW M1DAB

PAPRIN: DEFB 5
	DEFW M1FCD

PAINPU: DEFB 5
	DEFW M2089

PADIM:	DEFB 5
	DEFW M2C02

PAREM:	DEFB 5
	DEFW M1BB2

PANEW:	DEFB 0
	DEFW NEW

PARUN:	DEFB 3
	DEFW M1EA1

PALIST: DEFB 5
	DEFW M17F9

PAPOKE: DEFB 8
	DEFB 0
	DEFW M1E80

PARAND: DEFB 3
	DEFW M1E4F

PACONT: DEFB 0
	DEFW M1E5F

PACLEA: DEFB 3
	DEFW M1EAC

PACLS:	DEFB 0
	DEFW M0D6B

PAPLOT: DEFB 9
	DEFB 0
	DEFW PLOTHA

PAPAUS: DEFB 6
	DEFB 0
	DEFW M1F3A

PAREAD: DEFB 5
	DEFW M1DED

PADATA: DEFB 5
	DEFW M1E27

PAREST: DEFB 3
	DEFW M1E42

PADRAW: DEFB 9
	DEFB 5
	DEFW M2382

PACOPY: DEFB 0
	DEFW M0EAC

PALPRI: DEFB 5
	DEFW M1FC9

PALLIS: DEFB 5
	DEFW M17F5

PASAVE: DEFB 0BH
PALOAD: DEFB 0BH
PAVERI: DEFB 0BH
PAMERG: DEFB 0BH
PABEEP: DEFB 8
	DEFB 0
	DEFW M03F8

PACIRC: DEFB 9
	DEFB 5
	DEFW KREIS

PAINK:	DEFB 7
PAPAPE: DEFB 7
PAFLAS: DEFB 7
PABRIG: DEFB 7
PAINVE: DEFB 7
PAOVER: DEFB 7
PAOUT:	DEFB 8
	DEFB 0
	DEFW M1E7A

PABORD: DEFB 6
	DEFB 0
	DEFW M2294

PADEFN: DEFB 5
	DEFW M1F60

PAOPEN: DEFB 6
	DEFB ','
	DEFB 0AH
	DEFB 0
	DEFW STROPE

PACLOS: DEFB 6
	DEFB 0
	DEFW M16E5

PAFORM: DEFB 0AH
	DEFB 0
	DEFW M1793

PAMOVE: DEFB 0AH
	DEFB ','
	DEFB 0AH
	DEFB 0
	DEFW M1793

PAERAS: DEFB 0AH
	DEFB 0
	DEFW M1793

PACAT:	DEFB 0
	DEFW M1793

;=======================================================

;Hauptroutine des Basicinterpreters mit Syntaxpruefung

M1B17:	RES 7,(IY+1)
	CALL M19FB
	XOR A
	LD (SUBPPC),A		;Zeiger auf Befehl der Zeile
	DEC A
	LD (ERRNR),A
	JR M1B29

M1B28:	RST GETNXT
M1B29:	CALL CLRWOR
	INC (IY+0DH)
	JP M,M1C8A
	RST GETAKT
	LD B,0
	CP 0DH
	JR Z,M1BB3
	CP ':'
	JR Z,M1B28

	LD HL,BRKTST
	PUSH HL
	LD C,A
	RST GETNXT
	LD A,C
	SUB 0CEH
	JP C,M1C8A
	LD C,A
	LD HL,BEFOFF
	ADD HL,BC
	LD C,(HL)
	ADD HL,BC
	JR M1B55

;die Parameter der Befehle werden ausgewertet

PARHOL: LD HL,(TADDR)		;Adresse des naechsten Tokens in der Tabelle
M1B55:	LD A,(HL)
	INC HL
	LD (TADDR),HL		;Adresse des naechsten Tokens in der Tabelle
	LD BC,PARHOL
	PUSH BC
	LD C,A
	CP ' '
	JR NC,M1B6F
	LD HL,M1C01
	LD B,0
	ADD HL,BC
	LD C,(HL)
	ADD HL,BC
	PUSH HL
	RST GETAKT
	DEC B
	RET

;der Seperator gemaess Parametertabelle, steht in Reg. C
;muss an dieser Stelle in der Zeile zu finden sein

M1B6F:	RST GETAKT
	CP C
	JP NZ,M1C8A
	RST GETNXT
	RET

;nach jedem richtigen Befehl wird an dieser Stelle, zum
;Pruefen der Breaktaste, zurueckgekehrt

BRKTST: CALL M1F54
	JR C,M1B7D
	RST ERRAUS
	DEFB 14H

M1B7D:	BIT 7,(IY+0AH)
	JR NZ,M1BF4
	LD HL,(NEWPPC)		;Zeilennummer wohin gesprungen wird (GO TO ...)
	BIT 7,H
	JR Z,M1B9E

;Routine fuer 'RUN'
;das Syntax/RUN- Flag (7 von FLAGS) ist dann gesetzt

M1B8A:	LD HL,0FFFEH
	LD (PPC),HL		;aktuelle Nr. der Basiczeile
	LD HL,(WORKSP)		;derzeitiger Workspace
	DEC HL
	LD DE,(ELINE)		;Adresse des eingegebenen Befehls
	DEC DE
	LD A,(NSPPC)		;Befehl der Zeile bei Sprung
	JR M1BD1

;neue Zeile nach einem Sprungbefehl suchen

M1B9E:	CALL M196E
	LD A,(NSPPC)		;Befehl der Zeile bei Sprung
	JR Z,M1BBF
	AND A
	JR NZ,M1BEC
	LD B,A
	LD A,(HL)
	AND 0C0H
	LD A,B
	JR Z,M1BBF
	RST ERRAUS
	DEFB 0FFH

;Einstieg bei dem Befehl 'REM'
;durch entfernen der Returnadresse BRKTST wird der Rest
;der Zeile ignoriert

M1BB2:	POP BC

;Behandlung der Zeile, wenn das Ende gefunden wurde

M1BB3:	CALL M2530
	RET Z

	LD HL,(NXTLIN)		;Adresse der naechsten Basiczeile
	LD A,0C0H
	AND (HL)
	RET NZ

	XOR A

;diese Routine holt die neue Zeilennummer nach 'PPC'
;und sucht den Beginn der darauffolgenden Zeile

M1BBF:	CP 1
	ADC A,0
	LD D,(HL)
	INC HL
	LD E,(HL)
	LD (PPC),DE		;aktuelle Nr. der Basiczeile
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	EX DE,HL
	ADD HL,DE
	INC HL

;Variable fuer naechste Zeile setzen

M1BD1:	LD (NXTLIN),HL		;Adresse der naechsten Basiczeile
	EX DE,HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	LD D,A
	LD E,0
	LD (IY+0AH),0FFH
	DEC D
	LD (IY+0DH),D
	JP Z,M1B28
	INC D
	CALL M198B
	JR Z,M1BF4

M1BEC:	RST ERRAUS
	DEFB 16H

M1BEE:	CALL M2530
	RET NZ
	POP BC
	POP BC

;naechsten Befehl finden:
;bei Carriage Return in der naechsten Zeile, bei
;':' in der gleichen Zeile.
;alle anderen Zeichen bedeuten Syntax-Error

M1BF4:	RST GETAKT
	CP 0DH
	JR Z,M1BB3
	CP ':'
	JP Z,M1B28
	JP M1C8A

M1C01:	DEFB PAR00-$
	DEFB PAR01-$
	DEFB PAR02-$
	DEFB PAR03-$
	DEFB PAR04-$
	DEFB PAR05-$
	DEFB PAR06-$
	DEFB PAR07-$
	DEFB PAR08-$
	DEFB PAR09-$
	DEFB PAR0A-$
	DEFB PAR0B-$

;Parameter 03: es kann eine Zahl folgen

PAR03:	CALL M1CDE

;Parameter 00: es duerfen keine Angaben folgen z.B. COPY

PAR00:	CP A

;Parameter 05: es koennen Ausdruecke folgen:
;z.B. PRINT"SPECTRUM"

PAR05:	POP BC
	CALL Z,M1BEE
	EX DE,HL

;jetzt kann nach erfolgter Pruefung, aus der Parametertabelle
;der einzelnen Befehle die Sprungadresse geladen und auf den
;STACK geschoben werden

M1C16:	LD HL,(TADDR)	;Adresse des naechsten Tokens in der Tabelle
	LD C,(HL)
	INC HL
	LD B,(HL)
	EX DE,HL
	PUSH BC
	RET

;Parameter 01: Variablenzuweisung bei LET

PAR01:	CALL M28B2
M1C22:	LD (IY+37H),0
	JR NC,M1C30
	SET 1,(IY+37H)
	JR NZ,M1C46

M1C2E:	RST ERRAUS
	DEFB 1

M1C30:	CALL Z,M2996
	BIT 6,(IY+1)
	JR NZ,M1C46
	XOR A
	CALL M2530
	CALL NZ,M2BF1
	LD HL,FLAGX		;Flag Teil 3
	OR (HL)
	LD (HL),A
	EX DE,HL

;fuer alle numerischen und neuen String- oder
;Stringarrayvariablen enthaelt C den Variablennamen.
;Fuer alte String- oder Stringarrayvariable enthaelt BC
;die Laenge fuer die Zuweisung.

M1C46:	LD (STRLEN),BC		;Laenge eines Strings
	LD (DEST),HL		;Variablenadresse bei Zuweisung
	RET

;Parameter 02: aktuelle Berechnung fuer Zuweisung einer
;Variablen in einem LET-Befehl durchfuehren

PAR02:	POP BC
	CALL M1C56
	CALL M1BEE
	RET

;Diese Routine wird von LET, READ und INPUT benutzt um
;erst eine Variable zu berechnen und diese dann zuzuweisen.
;INPUT benutzt FLAGX und steigt beim zweiten Befehl ein.

M1C56:	LD A,(FLAGS)	;Bit 1= Printer ein
M1C59:	PUSH AF
	CALL AUSDRU
	POP AF
	LD D,(IY+1)
	XOR D
	AND 40H
	JR NZ,M1C8A
	BIT 7,D
	JP NZ,M2AFF
	RET

;Parameter 04: Einstieg fuer FOR..NEXT - Befehle

PAR04:	CALL M28B2
	PUSH AF
	LD A,C
	OR 09FH
	INC A
	JR NZ,M1C8A
	POP AF
	JR M1C22

;Die folgenden Routinen dienen dem Berechnen von
;numerischen Ausdruecken. Das jeweilige Ergebnis kommt
;als letztes auf den Calculatorstack.
;Der erste Einstiegspunkt dient dem Berechnen von zwei
;durch Komma getrennten Ausdruecken (PAR 08).

M1C79:	RST GETNXT
PAR08:	CALL PAR06
	CP ','
	JR NZ,M1C8A
	RST GETNXT

;ab hier nur einen Ausdruck berechnen

PAR06:	CALL AUSDRU
	BIT 6,(IY+1)
	RET NZ

M1C8A:	RST ERRAUS
	DEFB 0BH

;Berechnung eines einfachen String-Ausdrucks

PAR0A:	CALL AUSDRU
	BIT 6,(IY+1)
	RET Z
	JR M1C8A

;Parameter 07: setzen der dauerhaften Farben

PAR07:	BIT 7,(IY+1)
	RES 0,(IY+2)
	CALL NZ,AKTCOL
	POP AF
	LD A,(TADDR)		;Adresse des naechsten Tokens in der Tabelle
	SUB 13H
	CALL M21FC
	CALL M1BEE
	LD HL,(ATTRT)		;aktuelle Farben temporaer
	LD (ATTRP),HL		;aktuelle Farben permanent
	LD HL,PFLAG		;Printerflag
	LD A,(HL)
	RLCA
	XOR (HL)
	AND 0AAH
	XOR (HL)
	LD (HL),A
	RET

;Parameter 09: Diese Routine wird von PLOT, DRAW und
;CIRCLE benutzt, um erst einmal Defaultwerte von
;FLASH, BRIGHT und PAPER auf 8 zu setzen.

PAR09:	CALL M2530
	JR Z,M1CD6
	RES 0,(IY+2)
	CALL AKTCOL
	LD HL,MASKT		;aktuelle Farbe transp./temp.
	LD A,(HL)
	OR 0F8H
	LD (HL),A
	RES 6,(IY+57H)
	RST GETAKT
M1CD6:	CALL FAREIN
	JR PAR08

;Parameter 0B: alle Kassettenroutinen

PAR0B:	JP KASHAU

;Routine um einen numerischen Ausdruck zu berechnen.
;Es wird der Wert Null uebergeben, falls kein Ausdruck
;vorhanden ist.

M1CDE:	CP 0DH
	JR Z,M1CE6
	CP ':'
	JR NZ,PAR06

;sonst den Calculator benutzen und eine Null im
;Caculatorstack addieren.

M1CE6:	CALL M2530
	RET Z
	RST CALRUF
	DEFB 0A0H
	DEFB 38H
	RET

;die folgenden Routinen dienen der Befehlsausfuehrung

M1CEE:	RST ERRAUS
	DEFB 8

;Befehl IF

M1CF0:	POP BC
	CALL M2530
	JR Z,M1D00
	RST CALRUF
	DEFB 2
	DEFB 38H

	EX DE,HL
	CALL M34E9
	JP C,M1BB3
M1D00:	JP M1B29

;Befehl FOR

M1D03:	CP 0CDH
	JR NZ,M1D10
	RST GETNXT
	CALL PAR06
	CALL M1BEE
	JR M1D16

M1D10:	CALL M1BEE
	RST CALRUF
	DEFB 0A1H
	DEFB 38H

;die letzten drei Werte des Calculatorstacks sind:
;der Wert der Variablen (W), die Obergrenze (O) und
;die Schrittweite

M1D16:	RST CALRUF
	DEFB 0C0H
	DEFB 2
	DEFB 1
	DEFB 0E0H
	DEFB 1
	DEFB 38H

	CALL M2AFF
	LD (MEM),HL
	DEC HL
	LD A,(HL)
	SET 7,(HL)
	LD BC,6
	ADD HL,BC
	RLCA
	JR C,M1D34
	LD C,0DH
	CALL MACHPL
	INC HL
M1D34:	PUSH HL
	RST CALRUF
	DEFB 2
	DEFB 2
	DEFB 38H

	POP HL
	EX DE,HL
	LD C,10
	LDIR
	LD HL,(PPC)		;aktuelle Nr. der Basiczeile
	EX DE,HL
	LD (HL),E
	INC HL
	LD (HL),D
	LD D,(IY+0DH)
	INC D
	INC HL
	LD (HL),D

;Es folgt der Test, ob eine FOR-NEXT-Schleife auge-
;fuehrt werden kann. Wenn ja: RETURN, sonst muss
;naechster Befehl hinter NEXT gefunden werden.

	CALL M1DDA
	RET NC

	LD B,(IY+38H)
	LD HL,(PPC)		;aktuelle Nr. der Basiczeile
	LD (NEWPPC),HL		;Zeilennummer wohin gesprungen wird (GO TO ...)
	LD A,(SUBPPC)		;Zeiger auf Befehl der Zeile
	NEG
	LD D,A
	LD HL,(CHADD)		;Adr. des naechsten zu interpret. Zeichens
	LD E,0F3H
M1D64:	PUSH BC
	LD BC,(NXTLIN)		;Adresse der naechsten Basiczeile
	CALL M1D86
	LD (NXTLIN),BC		;Adresse der naechsten Basiczeile
	POP BC
	JR C,M1D84
	RST GETNXT
	OR 20H
	CP B
	JR Z,M1D7C
	RST GETNXT
	JR M1D64

;NEWPPC enthaelt nun die Zeilennummer, in der das
;richtige NEXT-Statement gefunden wurde. Die Befehlszahl
;des 'NEXT' wird gesucht und in NSPPC gespeichert.

M1D7C:	RST GETNXT
	LD A,1
	SUB D
	LD (NSPPC),A		;Befehl der Zeile bei Sprung
	RET

M1D84:	RST ERRAUS
	DEFB 011H

;Diese Routine durchsucht das Programm nach 'DATA',
;'DEF FN' und 'NEXT'. Token im Register E und Start-
;adresse des Suchens in HL.

M1D86:	LD A,(HL)
	CP ':'
	JR Z,M1DA3
M1D8B:	INC HL
	LD A,(HL)
	AND 0C0H
	SCF
	RET NZ

	LD B,(HL)
	INC HL
	LD C,(HL)
	LD (NEWPPC),BC		;Zeilennummer wohin gesprungen wird (GO TO ...)
	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	PUSH HL
	ADD HL,BC
	LD B,H
	LD C,L
	POP HL
	LD D,0
M1DA3:	PUSH BC
	CALL M198B
	POP BC
	RET NC
	JR M1D8B

;Befehl NEXT
;die Laufvariable wird um den STEP-WERT erhoeht

M1DAB:	BIT 1,(IY+37H)
	JP NZ,M1C2E
	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	BIT 7,(HL)
	JR Z,M1DD8
	INC HL
	LD (MEM),HL		;Zeiger auf Calculatorspeicher
	RST CALRUF
	DEFB 0E0H
	DEFB 0E2H
	DEFB 0FH
	DEFB 0C0H
	DEFB 2
	DEFB 38H

	CALL M1DDA
	RET C

	LD HL,(MEM)		;Zeiger auf Calculatorspeicher
	LD DE,0FH
	ADD HL,DE
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD H,(HL)
	EX DE,HL
	JP M1E73

M1DD8:	RST ERRAUS
	NOP

;Ueberpruefung, ob die Ober-/Untergrenze einer FOR-
;NEXT-Schleife erreicht (je nach Vorzeichen von STEP)

M1DDA:	RST CALRUF
	DEFB 0E1H
	DEFB 0E0H
	DEFB 0E2H
	DEFB 36H
	DEFB 0
	DEFB NXTNEG-$
	DEFB 1
NXTNEG: DEFB 3
	DEFB 37H
	DEFB 0
	DEFB NXTEND-$
	DEFB 38H
	AND A
	RET

NXTEND: DEFB 38H
	SCF
	RET

;Befehl READ
;CHADD wird als Zeiger entlang der einzelnen DATA-Statements
;benutzt. DATADD zeigt auf das aktuelle Element der Daten-
;liste (noetig fuer mehrere READ-Befehle)

M1DEC:	RST GETNXT
M1DED:	CALL PAR01
	CALL M2530
	JR Z,M1E1E
	RST GETAKT
	LD (XPTR),HL		;Adresse des Zeichens nach ? bei Error
	LD HL,(DATADD)		;Zeiger auf Endbyte der letzten Daten
	LD A,(HL)
	CP ','
	JR Z,M1E0A
	LD E,0E4H
	CALL M1D86
	JR NC,M1E0A

	RST ERRAUS
	DEFB 0DH

M1E0A:	CALL M0077
	CALL M1C56
	RST GETAKT
	LD (DATADD),HL		;Zeiger auf Endbyte der letzten Daten
	LD HL,(XPTR)		;Adresse des Zeichens nach ? bei Error
	LD (IY+26H),0
	CALL M0078
M1E1E:	RST GETAKT
	CP ','
	JR Z,M1DEC
	CALL M1BEE
	RET

;Befehl DATA
;beim Programmlauf werden die DATA-Statements uebersprungen

M1E27:	CALL M2530
	JR NZ,M1E37
M1E2C:	CALL AUSDRU
	CP ','
	CALL NZ,M1BEE
	RST GETNXT
	JR M1E2C
M1E37:	LD A,0E4H

;Routine zum Ueberspringen von Programmteilen

M1E39:	LD B,A
	CPDR
	LD DE,200H
	JP M198B

;Befehl RESTORE
;ein Operand wird als Zeilennummer interpretiert,
;wenn keiner vorhanden, Defaultwert Null

M1E42:	CALL M1E99
M1E45:	LD H,B
	LD L,C
	CALL M196E
	DEC HL
	LD (DATADD),HL		;Zeiger auf Endbyte der letzten Daten
	RET

;Befehl RANDOMIZE
;falls der Operand Null ist, wird statt dessen FRAMES
;als Ersatz genommen

M1E4F:	CALL M1E99
	LD A,B
	OR C
	JR NZ,M1E5A
	LD BC,(FRAMES)		;3 Byte Bildzaehler (Uhr)
M1E5A:	LD (SEED),BC		;Zufallszahl setzen durch Randomize
	RET

;Befehl CONTINUE
;die entsprechenden Zeilen- und Befehlsnummern werden
;geladen, um dann ein 'GO TO' auszufuehren

M1E5F:	LD HL,(OLDPPC)		;Zeilennummer fuer Continue
	LD D,(IY+36H)
	JR M1E73

;Befehl GO TO
;die Zeilennummer sollte im Bereich von 0 - 9999 sein,
;es wird jedoch nur auf >61439 geprueft

M1E67:	CALL M1E99
	LD H,B
	LD L,C
	LD D,0
	LD A,H
	CP 0F0H
	JR NC,M1E9F

M1E73:	LD (NEWPPC),HL		;Zeilennummer wohin gesprungen wird (GO TO ...)
	LD (IY+0AH),D
	RET

;Befehl OUT
;die zwei Parameter werden vom Calculatorstack
;geholt und ausgegeben

M1E7A:	CALL M1E85
	OUT (C),A
	RET

;Befehl POKE
;die beiden Parameter werden, wie bei OUT, vom
;Calculatorstack genommen

M1E80:	CALL M1E85
	LD (BC),A
	RET

;Die zwei obersten Parameter vom Calculatorstack entnehmen:
;Der erste muss im Bereich von 0 - 255 sein, (es wird das
;Zweierkomplement gebildet, falls negativ), der Zweite im
;Bereich von 0 - 65535 sein (Integer)

M1E85:	CALL M2DD5
	JR C,M1E9F
	JR Z,M1E8E
	NEG
M1E8E:	PUSH AF
	CALL M1E99
	POP AF
	RET

;Subroutine, um Integerzahlen vom Calculatorstack zu holen.
;INTEG1 fuer Zahlen von 0 -  255 (1 Byte)
;INTEG2 fuer Zahlen von 0 - 65535 (2 Byte)

INTEG1: CALL M2DD5
	JR M1E9C

M1E99:	CALL M2DA2
M1E9C:	JR C,M1E9F
	RET Z

M1E9F:	RST ERRAUS
	DEFB 0AH

;Befehl RUN
;Parameter von RUN wird ueber GO TO zugewiesen, danach
;wird ein 'RESTORE 0' und 'CLEAR' ausgefuehrt

M1EA1:	CALL M1E67
	LD BC,0
	CALL M1E45
	JR M1EAF

;Befehl CLEAR
;hiermit werden die Variablen und der Bildschirm
;geloescht. RAMTOP und der Stack werden neu angelegt.

M1EAC:	CALL M1E99
M1EAF:	LD A,B
	OR C
	JR NZ,M1EB7
	LD BC,(RAMTOP)		;letzte Speicheradresse fuer Basic
M1EB7:	PUSH BC
	LD DE,(VARS)		;Beginn der Variablen
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	CALL RAUS1
	CALL M0D6B
	LD HL,(STKEND)		;Anfang des freien Speichers
	LD DE,032H
	ADD HL,DE
	POP DE
	SBC HL,DE
	JR NC,M1EDA
	LD HL,(PRAMT)		;letzte Speicheradresse
	AND A
	SBC HL,DE
	JR NC,M1EDC

M1EDA:	RST ERRAUS
	DEFB 15H

M1EDC:	EX DE,HL
	LD (RAMTOP),HL		;letzte Speicheradresse fuer Basic
	POP DE
	POP BC
	LD (HL),3EH
	DEC HL
	LD SP,HL
	PUSH BC
	LD (ERRSP),SP		;Errorstackpointer
	EX DE,HL
	JP (HL)

;Befehl GO SUB
;der aktuelle Wert von PPC und SUBPPC+1 werden im
;'GO SUB'-Stack gespeichert

M1EED:	POP DE
	LD H,(IY+0DH)
	INC H
	EX (SP),HL
	INC SP
	LD BC,(PPC)		;aktuelle Nr. der Basiczeile
	PUSH BC
	PUSH HL
	LD (ERRSP),SP		;Errorstackpointer
	PUSH DE
	CALL M1E67
	LD BC,14H

;Testroutine fuer benoetigten Speicherplatz (in BC)

M1F05:	LD HL,(STKEND)		;Anfang des freien Speichers
	ADD HL,BC
	JR C,M1F15
	EX DE,HL
	LD HL,50H
	ADD HL,DE
	JR C,M1F15
	SBC HL,SP
	RET C

;Fehlermeldung 'OUT OF MEMORY'

M1F15:	LD L,3
	JP M0055

;Routine zum Berechnen des freien Speicherplatzes (FRE)
;der freie Platz ergibt sich durch: PRINT65535-USR7962

M1F1A:	LD BC,0
	CALL M1F05
	LD B,H
	LD C,L
	RET

;Befhl RETURN
;Zeilennummer und Befehlszahl in der Zeile werden vom
;'GO SUB'-Stack genommen

M1F23:	POP BC
	POP HL
	POP DE
	LD A,D
	CP 3EH
	JR Z,M1F36
	DEC SP
	EX (SP),HL
	EX DE,HL
	LD (ERRSP),SP		;Errorstackpointer
	PUSH BC
	JP M1E73

M1F36:	PUSH DE
	PUSH HL
	RST ERRAUS
	DEFB 6

;Befehl PAUSE
;Es werden hierbei die Interrupts gezaehlt, die 50 mal
;pro Sekunde (fuer die Tastaturabfrage) auftreten. Wenn
;eine Taste gedrueckt wird, wird die Pause ebenfalls beendet.

M1F3A:	CALL M1E99
M1F3D:	HALT

	DEC BC
	LD A,B
	OR C
	JR Z,M1F4F
	LD A,B
	AND C
	INC A
	JR NZ,M1F49
	INC BC
M1F49:	BIT 5,(IY+1)
	JR Z,M1F3D

M1F4F:	RES 5,(IY+1)
	RET

;Subroutine, um auf gedrueckte Break-Taste zu pruefen

M1F54:	LD A,7FH
	IN A,(0FEH)
	RRA
	RET C

	LD A,0FEH
	IN A,(0FEH)
	RRA
	RET

;Befehl DEF FN
;Zur Laufzeit wird 'DEF FN' uebersprungen (wie DATA).
;Bei der Syntaxpruefung wird der Ausdruck geprueft.

M1F60:	CALL M2530
	JR Z,M1F6A
	LD A,0CEH
	JP M1E39

M1F6A:	SET 6,(IY+1)
	CALL M2C8D
	JR NC,M1F89
	RST GETNXT
	CP '$'
	JR NZ,M1F7D
	RES 6,(IY+1)
	RST GETNXT
M1F7D:	CP '('
	JR NZ,M1FBD
	RST GETNXT
	CP ')'
	JR Z,M1FA6

;Schleife, um alle Parameter nacheinander abzuarbeiten

M1F86:	CALL M2C8D
M1F89:	JP NC,M1C8A
	EX DE,HL
	RST GETNXT
	CP '$'
	JR NZ,M1F94
	EX DE,HL
	RST GETNXT
M1F94:	EX DE,HL
	LD BC,6
	CALL MACHPL
	INC HL
	INC HL
	LD (HL),0EH
	CP ','
	JR NZ,M1FA6
	RST GETNXT
	JR M1F86

M1FA6:	CP ')'
	JR NZ,M1FBD
	RST GETNXT
	CP '='
	JR NZ,M1FBD
	RST GETNXT
	LD A,(FLAGS)		;Bit 1= Printer ein
	PUSH AF
	CALL AUSDRU
	POP AF
	XOR (IY+1)
	AND 40H
M1FBD:	JP NZ,M1C8A
	CALL M1BEE

;Stackkorrekturroutine fuer verschiedene Gelegenheiten
;bei der Syntaxpruefung

M1FC3:	CALL M2530
	POP HL
	RET Z
	JP (HL)

;Befehle LPRINT und PRINT
;der erforderliche Kanal wird geoeffnet

M1FC9:	LD A,3
	JR M1FCF

M1FCD:	LD A,2
M1FCF:	CALL M2530
	CALL NZ,OPKAN
	CALL AKTCOL
	CALL M1FDF
	CALL M1BEE
	RET

M1FDF:	RST GETAKT
	CALL M2045
	JR Z,M1FF2
M1FE5:	CALL M204E
	JR Z,M1FE5
	CALL M1FFC
	CALL M204E
	JR Z,M1FE5
M1FF2:	CP ')'
	RET Z

;Subroutine, um ein CARRIAGE RETURN auszudrucken, aber
;nur zur Laufzeit

M1FF5:	CALL M1FC3
	LD A,0DH
	RST PRTOUT
	RET

;Subroutine zum Ausgeben von Ausdruecken bei PRINT etc.

M1FFC:	RST GETAKT
	CP 0ACH
	JR NZ,M200E
	CALL M1C79
	CALL M1FC3
	CALL M2307
	LD A,16H
	JR M201E

M200E:	CP 0ADH
	JR NZ,M2024
	RST GETNXT
	CALL PAR06
	CALL M1FC3
	CALL M1E99
	LD A,17H
M201E:	RST PRTOUT
	LD A,C
	RST PRTOUT
	LD A,B
	RST PRTOUT
	RET

M2024:	CALL FARBUN
	RET NC
	CALL M2070
	RET NC

;die zu druckenden Zeichen muessen entweder ein String
;oder ein numerischer Ausdruck sein

	CALL AUSDRU
	CALL M1FC3
	BIT 6,(IY+1)
	CALL Z,M2BF1
	JP NZ,M2DE3

;Ausgabeschleife fuer einen String

M203C:	LD A,B
	OR C
	DEC BC
	RET Z
	LD A,(DE)
	INC DE
	RST PRTOUT
	JR M203C

;Subroutine zum Untersuchen, ob eine Ausgabe zu Ende
;ist. Trifft dies zu, so ist das ZERO-Flag gesetzt.

M2045:	CP ')'
	RET Z
M2048:	CP 0DH
	RET Z
	CP ':'
	RET

;Subroutine zum Positionieren beim Ausdrucken

M204E:	RST GETAKT
	CP ';'
	JR Z,M2067
	CP ','
	JR NZ,M2061
	CALL M2530
	JR Z,M2067
	LD A,6
	RST PRTOUT
	JR M2067

M2061:	CP 27H			;'
	RET NZ

	CALL M1FF5
M2067:	RST GETNXT
	CALL M2045
	JR NZ,M206E
	POP BC
M206E:	CP A
	RET

;Subroutine zum STREAM-aendern, falls der Benutzer
;es wuenscht

M2070:	CP '#'
	SCF
	RET NZ
	RST GETNXT
	CALL PAR06
	AND A
	CALL M1FC3
	CALL INTEG1
	CP 10H
	JP NC,ISTREA
	CALL OPKAN
	AND A
	RET

;Befehl INPUT
;eventuelle Ausgaben beim INPUT werden im unteren
;Bildschirmteil gedruckt

M2089:	CALL M2530
	JR Z,M2096
	LD A,1
	CALL OPKAN
	CALL M0D6E
M2096:	LD (IY+2),1
	CALL M20C1
	CALL M1BEE
	LD BC,(SPOSN)		;Zeile/Spalte fuer Print
	LD A,(DFSZ)		;Zeilenanzahl+1 im unteren Bildschirmteil
	CP B
	JR C,M20AD
	LD C,33
	LD B,A
M20AD:	LD (SPOSN),BC		;Zeile/Spalte fuer Print
	LD A,25
	SUB B
	LD (SCRCT),A		;Scrollzaehler
	RES 0,(IY+2)
	CALL M0DD9
	JP M0D6E

;eigentliche INPUT-Routine

M20C1:	CALL M204E
	JR Z,M20C1
	CP '('
	JR NZ,M20D8
	RST GETNXT
	CALL M1FDF
	RST GETAKT
	CP ')'
	JP NZ,M1C8A
	RST GETNXT
	JP M21B2

M20D8:	CP 0CAH
	JR NZ,M20ED
	RST GETNXT
	CALL PAR01
	SET 7,(IY+37H)
	BIT 6,(IY+1)
	JP NZ,M1C8A
	JR M20FA

;normale INPUT-Variablen

M20ED:	CALL M2C8D
	JP NC,M21AF
	CALL PAR01
	RES 7,(IY+37H)

;die PROMPT-Ausgabe wird im WORKSPACE aufgebaut

M20FA:	CALL M2530
	JP Z,M21B2
	CALL CLRWOR
	LD HL,FLAGX		;Flag Teil 3
	RES 6,(HL)
	SET 5,(HL)
	LD BC,1
	BIT 7,(HL)
	JR NZ,M211C
	LD A,(FLAGS)		;Bit 1= Printer ein
	AND 40H
	JR NZ,M211A
	LD C,3
M211A:	OR (HL)
	LD (HL),A
M211C:	RST REST30
	LD (HL),0DH
	LD A,C
	RRCA
	RRCA
	JR NC,M2129
	LD A,'"'
	LD (DE),A
	DEC HL
	LD (HL),A
M2129:	LD (KCUR),HL		;Kursoradresse
	BIT 7,(IY+37H)
	JR NZ,M215E
	LD HL,(CHADD)		;Adr. des naechsten zu interpret. Zeichens
	PUSH HL
	LD HL,(ERRSP)		;Errorstackpointer
	PUSH HL
	LD HL,$
	PUSH HL
	BIT 4,(IY+30H)
	JR Z,M2148
	LD (ERRSP),SP		;Errorstackpointer
M2148:	LD HL,(WORKSP)		;derzeitiger Workspace
	CALL HOLFLO
	LD (IY+0),0FFH
	CALL M0F2C
	RES 7,(IY+1)
	CALL M21B9
	JR M2161

M215E:	CALL 0F2CH
M2161:	LD (IY+22H),0
	CALL M21D6
	JR NZ,M2174
	CALL M111D
	LD BC,(ECHOE)		;Position fuer Input
	CALL M0DD9
M2174:	LD HL,FLAGX		;Flag Teil 3
	RES 5,(HL)
	BIT 7,(HL)
	RES 7,(HL)
	JR NZ,M219B
	POP HL
	POP HL
	LD (ERRSP),HL		;Errorstackpointer
	POP HL
	LD (XPTR),HL		;Adresse des Zeichens nach ? bei Error
	SET 7,(IY+1)
	CALL M21B9
	LD HL,(XPTR)		;Adresse des Zeichens nach ? bei Error
	LD (IY+26H),0
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	JR M21B2

M219B:	LD HL,(STKBOT)		;Anfang des Calculatorstacks
	LD DE,(WORKSP)		;derzeitiger Workspace
	SCF
	SBC HL,DE
	LD B,H
	LD C,L
	CALL M2AB2
	CALL M2AFF
	JR M21B2

M21AF:	CALL M1FFC
M21B2:	CALL M204E
	JP Z,M20C1
	RET

;Subroutine fuer INPUT-Zuweisung
;erster Aufruf mit Syntaxflag gesetzt und zweiter
;mit Syntaxflag zurueckgesetzt (Programmlauf)

M21B9:	LD HL,(WORKSP)		;derzeitiger Workspace
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	RST GETAKT
	CP 0E2H
	JR Z,M21D0
	LD A,(FLAGX)		;Flag Teil 3
	CALL M1C59
	RST GETAKT
	CP 0DH
	RET Z

	RST ERRAUS
	DEFB 0BH

M21D0:	CALL M2530
	RET Z

;erstes Zeichen des INPUT war STOP

	RST ERRAUS
	DEFB 10H

;Subroutine zum Pruefen, ob Kanal K im INPUT benutzt
;wird. Falls ja, dann ZERO = 1

M21D6:	LD HL, (CURCHL)
	INC HL
	INC HL
	INC HL
	INC HL
	LD A,(HL)
	CP 'K'
	RET

;Unterprogramme zur Behandlung von Farbanweisungen

M21E1:	RST GETNXT

;normaler Einstieg

FAREIN: CALL FARBUN
	RET C
	RST GETAKT
	CP ','
	JR Z,M21E1
	CP ';'
	JR Z,M21E1
	JP M1C8A

FARBUN: CP 0D9H
	RET C
	CP 0DFH
	CCF
	RET C

	PUSH AF
	RST GETNXT
	POP AF
M21FC:	SUB 0C9H
	PUSH AF
	CALL PAR06
	POP AF
	AND A
	CALL M1FC3
	PUSH AF
	CALL INTEG1
	LD D,A
	POP AF
	RST PRTOUT
	LD A,D
	RST PRTOUT
	RET

;Die folgenden Unterprogramme werden von der PRINT-Routine
;aufgerufen. Dabei werden die Systemvariablen ATTRT, MASKT
;und PFLAG entsprechend den Anweisungen geaendert (nur die
;Temporaeren). REG A enthaelt das Steuerzeichen und REG D
;den Parameter

M2211:	SUB 11H
	ADC A,0
	JR Z,M2234

	SUB 2
	ADC A,0
	JR Z,M2273

	CP 1
	LD A,D
	LD B,1
	JR NZ,M2228

	RLCA
	RLCA
	LD B,4
M2228:	LD C,A
	LD A,D
	CP 2
	JR NC,M2244
	LD A,C
	LD HL,PFLAG		;Printerflag
	JR M226C

;Behandlung von INK und PAPER

M2234:	LD A,D
	LD B,7
	JR C,M223E
	RLCA
	RLCA
	RLCA
	LD B,38H
M223E:	LD C,A
	LD A,D
	CP 0AH
	JR C,M2246

M2244:	RST ERRAUS
	DEFB 13H

M2246:	LD HL,ATTRT		;aktuelle Farben temporaer
	CP 8
	JR C,M2258
	LD A,(HL)
	JR Z,M2257
	OR B
	CPL
	AND 24H
	JR Z,M2257
	LD A,B
M2257:	LD C,A
M2258:	LD A,C
	CALL M226C

;jetzt wird MASKT bearbeitet

	LD A,7
	CP D
	SBC A,A
	CALL M226C

;zuletzt noch PFLAG bearbeiten

	RLCA
	RLCA
	AND 50H
	LD B,A
	LD A,8
	CP D
	SBC A,A

;Subroutine zum Setzen der Farbdetails. REG HL enthaelt
;die Adresse, REG B die Maske und REG A den neuen Wert.

M226C:	XOR (HL)
	AND B
	XOR (HL)
	LD (HL),A
	INC HL
	LD A,B
	RET

;Behandlung von FLASH und BRIGHT

M2273:	SBC A,A
	LD A,D
	RRCA
	LD B,80H
	JR NZ,M227D
	RRCA
	LD B,40H
M227D:	LD C,A
	LD A,D
	CP 8
	JR Z,M2287
	CP 2
	JR NC,M2244

M2287:	LD A,C
	LD HL,ATTRT		;aktuelle Farben temporaer
	CALL M226C
	LD A,C
	RRCA
	RRCA
	RRCA
	JR M226C

;Befehl BORDER
;Der Parameter von BORDER wird ueber einen 'OUT'-Befehl
;ausgegeben. Anschliessend wird der Parameter in BORDCR
;gespeichert.

M2294:	CALL INTEG1
	CP 8
	JR NC,M2244
	OUT (0FEH),A
	RLCA
	RLCA
	RLCA
	BIT 5,A
	JR NZ,M22A6
	XOR 7
M22A6:	LD (BORDCR),A		;Bordercolor * 8
	RET

;Subroutine zum Berechnen einer 'PIXEL'-Adresse
;auf dem Bildschirm
;Aufruf von POINT und PLOT mit Adresse des Punktes in
;BC. Bei RETURN enthaelt HL die Adresse des Bytes im ent-
;sprechenden Bildschirmbereich und A die Bitposition des
;Punktes in diesem Byte

PKTADR: LD A,0AFH
	SUB B
	JP C,M24F9
	LD B,A
	AND A
	RRA
	SCF
	RRA
	AND A
	RRA
	XOR B
	AND 0F8H
	XOR B
	LD H,A
	LD A,C
	RLCA
	RLCA
	RLCA
	XOR B
	AND 0C7H
	XOR B
	RLCA
	RLCA
	LD L,A
	LD A,C
	AND 7
	RET

;Subroutine fuer die POINT-Funktion

M22CB:	CALL M2307
	CALL PKTADR
	LD B,A
	INC B
	LD A,(HL)
M22D4:	RLCA
	DJNZ M22D4
	AND 1
	JP M2D28

;Befehl PLOT
;Beim Einstieg liegen die Koordinaten auf dem Calc.-Stack.
;Unter Beruecksichtigung von 'INVERSE' und 'OVER' (in
;PFLAG) wird der Punkt entsprechend gesetzt

PLOTHA: CALL M2307
	CALL PLOTTE
	JP AKTCOL

PLOTTE: LD (COORDS),BC		;Koordinaten des letzten Plot
	CALL PKTADR
	LD B,A
	INC B
	LD A,0FEH
M22F0:	RRCA
	DJNZ M22F0
	LD B,A
	LD A,(HL)
	LD C,(IY+57H)
	BIT 0,C
	JR NZ,M22FD
	AND B
M22FD:	BIT 2,C
	JR NZ,M2303
	XOR B
	CPL
M2303:	LD (HL),A
	JP M0BDB

;Subroutine, um BC mit den letzten zwei Werten, im
;Bereich jeweils von 0-FFH, des Calc.-Stacks zu
;laden. D und E enthalten jeweils +/- 1 fuer die
;Zeichenrichtung.

M2307:	CALL STAINA
	LD B,A
	PUSH BC
	CALL STAINA
	LD E,C
	POP BC
	LD D,C
	LD C,A
	RET

;Letzte Floatingpoint-Zahl vom Calc.-Stack nach A
;laden, Bereich 0-FFH. C enthaelt +1 fuer positive
;-1 fuer negative Werte

STAINA: CALL M2DD5
	JP C,M24F9
	LD C,1
	RET Z
	LD C,0FFH
	RET

;Befehl CIRCLE
;Es wird ein angenaeherter Kreis mit Radius 'R' um die
;Koordinate X,Y (=Mitte) gezeichnet. Alle drei Werte
;werden zuerst gerundet.

KREIS:	RST GETAKT
	CP ','
	JP NZ,M1C8A
	RST GETNXT
	CALL PAR06
	CALL M1BEE
	RST CALRUF
	DEFB 2AH
	DEFB 3DH
	DEFB 38H

	LD A,(HL)
	CP 81H
	JR NC,M233B
	RST CALRUF
	DEFB 2
	DEFB 38H
	JR PLOTHA

M233B:	RST CALRUF
	DEFB 0A3H
	DEFB 38H

	LD (HL),83H
	RST CALRUF
	DEFB 0C5H
	DEFB 2
	DEFB 38H

	CALL M247D

;Der Kreis wird auf Geradenstuecken zurueckgefuehrt,
;die mit der 'DRAW'-Subroutine gezeichnet werden. Die
;Anzahl der Geradenstuecken ist A und in BC enthalten.

	PUSH BC
	RST CALRUF
	DEFB 31H
	DEFB 0E1H
	DEFB 4
	DEFB 38H

	LD A,(HL)
	CP 80H
	JR NC,M235A
	RST CALRUF
	DEFB 2
	DEFB 2
	DEFB 38H
	POP BC
	JP PLOTHA

M235A:	RST CALRUF
	DEFB 0C2H
	DEFB 1
	DEFB 0C0H
	DEFB 2
	DEFB 3
	DEFB 1
	DEFB 0E0H
	DEFB 0FH
	DEFB 0C0H
	DEFB 1
	DEFB 31H
	DEFB 0E0H
	DEFB 1
	DEFB 31H
	DEFB 0E0H
	DEFB 0A0H
	DEFB 0C1H
	DEFB 2
	DEFB 38H

	INC (IY+62H)
	CALL INTEG1
	LD L,A
	PUSH HL
	CALL INTEG1
	POP HL
	LD H,A
	LD (COORDS),HL		;Koordinaten des letzten Plot
	POP BC
	JP M2420

;Befehl DRAW
;Die Startkoordinaten (X0,Y0) einer Geraden sind in
;COORDS enthalten. Wenn ausser den Endpunkten X und Y
;keine weiteren Parameter angegeben sind, wird eine
;Gerade von X0,Y0 nach X+X0,Y+Y0 gezeichnet.

M2382:	RST GETAKT
	CP ','
	JR Z,M238D
	CALL M1BEE
	JP M2477

M238D:	RST GETNXT
	CALL PAR06
	CALL M1BEE
	RST CALRUF
	DEFB 0C5H
	DEFB 0A2H
	DEFB 4
	DEFB 1FH
	DEFB 31H
	DEFB 30H
	DEFB 30H
	DEFB 0
	DEFB ZEIWIN-$
	DEFB 2
	DEFB 38H
	JP M2477

ZEIWIN: DEFB 0C0H
	DEFB 2
	DEFB 0C1H
	DEFB 2
	DEFB 31H
	DEFB 2AH
	DEFB 0E1H
	DEFB 1
	DEFB 0E1H
	DEFB 2AH
	DEFB 0FH
	DEFB 0E0H
	DEFB 5
	DEFB 2AH
	DEFB 0E0H
	DEFB 1
	DEFB 3DH
	DEFB 38H

	LD A,(HL)
	CP 81H
	JR NC,M23C1
	RST CALRUF
	DEFB 2
	DEFB 2
	DEFB 38H
	JP M2477

M23C1:	CALL M247D
	PUSH BC
	RST CALRUF
	DEFB 2
	DEFB 0E1H
	DEFB 1
	DEFB 5
	DEFB 0C1H
	DEFB 2
	DEFB 1
	DEFB 31H
	DEFB 0E1H
	DEFB 4
	DEFB 0C2H
	DEFB 2
	DEFB 1
	DEFB 31H
	DEFB 0E1H
	DEFB 4
	DEFB 0E2H
	DEFB 0E5H
	DEFB 0E0H
	DEFB 3
	DEFB 0A2H
	DEFB 4
	DEFB 31H
	DEFB 1FH
	DEFB 0C5H
	DEFB 2
	DEFB 20H
	DEFB 0C0H
	DEFB 2
	DEFB 0C2H
	DEFB 2
	DEFB 0C1H
	DEFB 0E5H
	DEFB 4
	DEFB 0E0H
	DEFB 0E2H
	DEFB 4
	DEFB 0FH
	DEFB 0E1H
	DEFB 1
	DEFB 0C1H
	DEFB 2
	DEFB 0E0H
	DEFB 4
	DEFB 0E2H
	DEFB 0E5H
	DEFB 4
	DEFB 3
	DEFB 0C2H
	DEFB 2AH
	DEFB 0E1H
	DEFB 2AH
	DEFB 0FH
	DEFB 2
	DEFB 38H

	LD A,(DE)
	CP 81H
	POP BC
	JP C,M2477
	PUSH BC
	RST CALRUF
	DEFB 1
	DEFB 38H

	LD A,(COORDS)
	CALL M2D28
	RST CALRUF
	DEFB 0C0H
	DEFB 0FH
	DEFB 1
	DEFB 38H

	LD A,(COORDS+1)
	CALL M2D28
	RST CALRUF
	DEFB 0C5H
	DEFB 0FH
	DEFB 0E0H
	DEFB 0E5H
	DEFB 38H
	POP BC

;Im folgenden werden die Geradenteile gezeichnet.
;Auf dem Calc.-Stack liegen die Werte:
;X0+X,Y0+Y,Xn,Yn
;als Zwischenwerte werden benutzt:
;Un=Xn+1-Xn, Vn=Yn+1-Yn

M2420:	DEC B
	JR Z,M245F
	JR M2439

GERADS: RST CALRUF
	DEFB 0E1H
	DEFB 31H
	DEFB 0E3H
	DEFB 4
	DEFB 0E2H
	DEFB 0E4H
	DEFB 4
	DEFB 3
	DEFB 0C1H
	DEFB 2
	DEFB 0E4H
	DEFB 4
	DEFB 0E2H
	DEFB 0E3H
	DEFB 4
	DEFB 0FH
	DEFB 0C2H
	DEFB 2
	DEFB 38H

M2439:	PUSH BC
	RST CALRUF
	DEFB 0C0H
	DEFB 2
	DEFB 0E1H
	DEFB 0FH
	DEFB 31H
	DEFB 38H

	LD A,(COORDS)
	CALL M2D28
	RST CALRUF
	DEFB 3
	DEFB 0E0H
	DEFB 0E2H
	DEFB 0FH
	DEFB 0C0H
	DEFB 1
	DEFB 0E0H
	DEFB 38H

	LD A,(COORDS+1)
	CALL M2D28
	RST CALRUF
	DEFB 3
	DEFB 38H

	CALL M24B7
	POP BC
	DJNZ GERADS

M245F:	RST CALRUF
	DEFB 2
	DEFB 2
	DEFB 1
	DEFB 38H

	LD A,(COORDS)
	CALL M2D28
	RST CALRUF
	DEFB 3
	DEFB 1
	DEFB 38H

	LD A,(COORDS+1)
	CALL M2D28
	RST CALRUF
	DEFB 3
	DEFB 38H

M2477:	CALL M24B7
	JP AKTCOL

;Subroutine zum Berechnen der Anfangsparameter.
;Beim Aufruf durch die Subroutine zum Zeichnen
;des Kreises liegen X,Y,R (Radius, hier=Z) und
;bei Aufruf durch 'DRAW' X,Y,SIN(G/2),Z auf dem
;Calc.-Stack. Die Rechnungen werden nur ab Z
;aufgefuehrt.

M247D:	RST CALRUF
	DEFB 31H
	DEFB 28H
	DEFB 34H
	DEFB 32H
	DEFB 0
	DEFB 1
	DEFB 5
	DEFB 0E5H
	DEFB 1
	DEFB 5
	DEFB 2AH
	DEFB 38H

	CALL M2DD5
	JR C,M2495
	AND 0FCH
	ADD A,4
	JR NC,M2497
M2495:	LD A,0FCH
M2497:	PUSH AF
	CALL M2D28
	RST CALRUF
	DEFB 0E5H
	DEFB 1
	DEFB 5
	DEFB 31H
	DEFB 1FH
	DEFB 0C4H
	DEFB 2
	DEFB 31H
	DEFB 0A2H
	DEFB 4
	DEFB 1FH
	DEFB 0C1H
	DEFB 1
	DEFB 0C0H
	DEFB 2
	DEFB 31H
	DEFB 4
	DEFB 31H
	DEFB 0FH
	DEFB 0A1H
	DEFB 3
	DEFB 1BH
	DEFB 0C3H
	DEFB 2
	DEFB 38H

	POP BC
	RET

;Subroutine zum Zeichnen von Geraden

M24B7:	CALL M2307
	LD A,C
	CP B
	JR NC,M24C4
	LD L,C
	PUSH DE
	XOR A
	LD E,A
	JR M24CB

M24C4:	OR C
	RET Z
	LD L,B
	LD B,C
	PUSH DE
	LD D,0
M24CB:	LD H,B
	LD A,B
	RRA
M24CE:	ADD A,L
	JR C,M24D4
	CP H
	JR C,M24DB
M24D4:	SUB H
	LD C,A
	EXX
	POP BC
	PUSH BC
	JR M24DF

M24DB:	LD C,A
	PUSH DE
	EXX
	POP BC
M24DF:	LD HL,(COORDS)		;Koordinaten des letzten Plot
	LD A,B
	ADD A,H
	LD B,A
	LD A,C
	INC A
	ADD A,L
	JR C,M24F7
	JR Z,M24F9
M24EC:	DEC A
	LD C,A
	CALL PLOTTE
	EXX
	LD A,C
	DJNZ M24CE
	POP DE
	RET
M24F7:	JR Z,M24EC

M24F9:	RST ERRAUS
	DEFB 0AH

;=================================================

;Unterprogramme zur Auswertung von Ausdruecken.
;Das Ergebnis wird als letzter Wert auf dem Calc.-Stack
;abgelgt (numerisch), bei Strings 5 Bytes mit folgender
;Bedeutung: das Erste ist nicht definiert, das Zweite+
;Dritte sind die Startadresse des String und die letzten
;zwei geben die Laenge an.

AUSDRU: RST GETAKT
	LD B,0
	PUSH BC
M24FF:	LD C,A
	LD HL,M2596
	CALL SUCHTA
	LD A,C
	JP NC,M2684
	LD B,0
	LD C,(HL)
	ADD HL,BC
	JP (HL)

;Subroutine zum Untersuchen auf Anfuehrstriche '"'

M250F:	CALL NEXZEI
	INC BC
	CP 0DH
	JP Z,M1C8A
	CP '"'
	JR NZ,M250F
	CALL NEXZEI
	CP '"'
	RET

;Subroutine untersucht, ob die benoetigten zwei
;Koordinaten folgen

M2522:	RST GETNXT
	CP '('
	JR NZ,M252D
	CALL M1C79
	RST GETAKT
	CP ')'
M252D:	JP NZ,M1C8A

;Diese Unterroutine ueberprueft, ob eine Syntaxpruefung
;stattfindet oder ein Programm (Zero gesetzt) laeuft.

M2530:	BIT 7,(IY+1)
	RET

;Subroutine zum Suchen des Zeichens an den Koordinaten
;X,Y durch 'SCREEN$'. Normal werden nur die im Zeichen-
;satz-ROM (ab 3D00H) abgelegten Zeichen gefunden: 20H - 7FH

M2535:	CALL M2307
	LD HL,(CHARS)		;Zeichensatzadresse -256
	LD DE,100H
	ADD HL,DE
	LD A,C
	RRCA
	RRCA
	RRCA
	AND 0E0H
	XOR B
	LD E,A
	LD A,C
	AND 18H
	XOR 40H			;HIGH-Teil von BILD
	LD D,A
	LD B,60H
M254F:	PUSH BC
	PUSH DE
	PUSH HL
	LD A,(DE)
	XOR (HL)
	JR Z,M255A
	INC A
	JR NZ,M2573
	DEC A
M255A:	LD C,A
	LD B,7
M255D:	INC D
	INC HL
	LD A,(DE)
	XOR (HL)
	XOR C
	JR NZ,M2573
	DJNZ M255D
	POP BC
	POP BC
	POP BC
	LD A,80H
	SUB B
	LD BC,1
	RST REST30
	LD (DE),A
	JR M257D

M2573:	POP HL
	LD DE,8
	ADD HL,DE
	POP DE
	POP BC
	DJNZ M254F
	LD C,B
M257D:	JP M2AB2

;Unterprogramm, um den Wert von ATTR (X,Y) zu bestimmen

M2580:	CALL M2307
	LD A,C
	RRCA
	RRCA
	RRCA
	LD C,A
	AND 0E0H
	XOR B
	LD L,A
	LD A,C
	AND 3
	XOR 58H
	LD H,A
	LD A,(HL)
	JP M2D28

;Offsettabelle fuer die Entwicklung von Ausdruecken

M2596:	DEFB '"'
	DEFB M25B3-$
	DEFB '('
	DEFB M25E8-$
	DEFB '.'
	DEFB M268D-$
	DEFB '+'
	DEFB M25AF-$
	DEFB 0A8H
	DEFB M25F5-$
	DEFB 0A5H
	DEFB M25F8-$
	DEFB 0A7H
	DEFB M2627-$
	DEFB 0A6H
	DEFB M2634-$
	DEFB 0C4H
	DEFB M268D-$
	DEFB 0AAH
	DEFB M2668-$
	DEFB 0ABH
	DEFB M2672-$
	DEFB 0A9H
	DEFB M267B-$
	DEFB 0

;Es folgen die einzelnen Unterprogramm, die mit Hilfe
;der Offsettabelle aufgerufen werden

;Pluszeichen

M25AF:	RST GETNXT
	JP M24FF

;Textmodus: Strings, einfache und mehrfache, die mit
;'"' eingeschlossen sind, bearbeiten.

M25B3:	RST GETAKT
	INC HL
	PUSH HL
	LD BC,0
	CALL M250F
	JR NZ,M25D9
M25BE:	CALL M250F
	JR Z,M25BE
	CALL M2530
	JR Z,M25D9
	RST REST30
	POP HL
	PUSH DE
M25CB:	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	CP '"'
	JR NZ,M25CB
	LD A,(HL)
	INC HL
	CP '"'
	JR Z,M25CB
M25D9:	DEC BC
	POP DE
M25DB:	LD HL,FLAGS		;Bit 1= Printer ein
	RES 6,(HL)
	BIT 7,(HL)
	CALL NZ,M2AB2
	JP M2712

;Einstieg bei Klammer auf

M25E8:	RST GETNXT
	CALL AUSDRU
	CP ')'
	JP NZ,M1C8A
	RST GETNXT
	JP M2712

;Einstieg bei 'FN'

M25F5:	JP M27BD

;Einstieg bei 'RND'

M25F8:	CALL M2530
	JR Z,M2625
	LD BC,(SEED)		;Zufallszahl setzen durch Randomize
	CALL M2D2B
	RST CALRUF
	DEFB 0A1H
	DEFB 0FH
	DEFB 34H
	DEFB 37H
	DEFB 16H
	DEFB 4
	DEFB 34H
	DEFB 80H
	DEFB 41H
	DEFB 0
	DEFB 0
	DEFB 80H
	DEFB 32H
	DEFB 2
	DEFB 0A1H
	DEFB 3
	DEFB 31H
	DEFB 38H

	CALL M2DA2
	LD (SEED),BC		;Zufallszahl setzen durch Randomize
	LD A,(HL)
	AND A
	JR Z,M2625
	SUB 10H
	LD (HL),A
M2625:	JR M2630

;die Zahl PI als letzten Wert auf den Calc.-Stack bringen

M2627:	CALL M2530
	JR Z,M2630
	RST CALRUF
	DEFB 0A3H
	DEFB 38H

	INC (HL)
M2630:	RST GETNXT
	JP M26C3

;Einsprung bei INKEY$

M2634:	LD BC,105AH
	RST GETNXT
	CP '#'
	JP Z,M270D
	LD HL,FLAGS		;Bit 1= Printer ein
	RES 6,(HL)
	BIT 7,(HL)
	JR Z,M2665
	CALL KEY
	LD C,0
	JR NZ,M2660
	CALL M031E
	JR NC,M2660
	DEC D
	LD E,A
	CALL M0333
	PUSH AF
	LD BC,1
	RST REST30
	POP AF
	LD (DE),A
	LD C,1
M2660:	LD B,0
	CALL M2AB2
M2665:	JP M2712

;Einstieg bei SCREEN$

M2668:	CALL M2522
	CALL NZ,M2535
	RST GETNXT
	JP M25DB

;Einstieg bei ATTR

M2672:	CALL M2522
	CALL NZ,M2580
	RST GETNXT
	JR M26C3

;Einstieg bei POINT

M267B:	CALL M2522
	CALL NZ,M22CB
	RST GETNXT
	JR M26C3

;ein Zeichen auf alphanumerisch Pruefen

M2684:	CALL M2C88
	JR NC,M26DF
	CP 'A'
	JR NC,M26C9

;Routine zum Bearbeiten von Dezimalzahlen (auch 'BIN')

M268D:	CALL M2530
	JR NZ,M26B5


;Bei der Eingabe einer Zeile (Syntaxpruefung) wird eine
;Zahl in eine Floatingpointzahl umgewandelt und in die
;BASIC-Zeile kopiert

	CALL DEZFLO
	RST GETAKT
	LD BC,6
	CALL MACHPL
	INC HL
	LD (HL),0EH
	INC HL
	EX DE,HL
	LD HL,(STKEND)		;Anfang des freien Speichers
	LD C,5
	AND A
	SBC HL,BC
	LD (STKEND),HL		;Anfang des freien Speichers
	LDIR
	EX DE,HL
	DEC HL
	CALL M0077
	JR M26C3

;der folgende Teil wird im Programmlauf bearbeitet

M26B5:	RST GETAKT
M26B6:	INC HL
	LD A,(HL)
	CP 0EH
	JR NZ,M26B6
	INC HL
	CALL M33B4
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
M26C3:	SET 6,(IY+1)
	JR M26DD

;Subroutine sucht Variable (numerisch, String) im
;Variablen- oder Programmbereich. Die Variable oder
;die Parameter bei Stringvar. werden in den Calc.-
;Stack gebracht

M26C9:	CALL M28B2
	JP C,M1C2E
	CALL Z,M2996
	LD A,(FLAGS)		;Bit 1= Printer ein
	CP 0C0H
	JR C,M26DD
	INC HL
	CALL M33B4
M26DD:	JR M2712

;Im folgenden werden verschiedene Operatoren geprueft

M26DF:	LD BC,9DBH
	CP '-'
	JR Z,M270D

	LD BC,1018H
	CP 0AEH
	JR Z,M270D

	SUB 0AFH
	JP C,M1C8A

	LD BC,4F0H
	CP 14H
	JR Z,M270D
	JP NC,M1C8A

;Tokens jetzt in Operationskodes wandeln

	LD B,10H
	ADD A,0DCH
	LD C,A
	CP 0DFH
	JR NC,M2707
	RES 6,C
M2707:	CP 0EEH
	JR C,M270D
	RES 7,C

;Der Prioritaetskode in B und der Operationskode in C
;werden auf dem Stack abgelegt, bevor der naechste Teil
;des Ausdruckes untersucht wird.

M270D:	PUSH BC
	RST GETNXT
	JP M24FF

;Es wird jetzt der weitere Ausdruck untersucht Klammer,
;Ende etc.

M2712:	RST GETAKT
M2713:	CP '('
	JR NZ,M2723
	BIT 6,(IY+1)
	JR NZ,M2734
	CALL M2A52
	RST GETNXT
	JR M2713

;Routine, um fuer die diversen Operatoren (+,*,NOT etc.)
;die Prioritaeten und den Operationskode zu suchen.

M2723:	LD B,0
	LD C,A
	LD HL,M2795
	CALL SUCHTA
	JR NC,M2734
	LD C,(HL)
	LD HL,M27B0-0C3H
	ADD HL,BC
	LD B,(HL)
M2734:	POP DE
	LD A,D
	CP B
	JR C,M2773
	AND A
	JP Z,GETAKT
	PUSH BC
	LD HL,FLAGS		;Bit 1= Printer ein
	LD A,E
	CP 0EDH
	JR NZ,M274C
	BIT 6,(HL)
	JR NZ,M274C
	LD E,99H
M274C:	PUSH DE
	CALL M2530
	JR Z,M275B
	LD A,E
	AND 3FH
	LD B,A
	RST CALRUF
	DEFB 3BH
	DEFB 38H

	JR M2764

;Die Art der letzten Operation mit der zu
;untersuchenden Vergleichen

M275B:	LD A,E
	XOR (IY+1)
	AND 40H
M2761:	JP NZ,M1C8A

;Die Art der vorherigen Operation muss noch
;in FLAGS angemerkt werden.

M2764:	POP DE
	LD HL,FLAGS		;Bit 1= Printer ein
	SET 6,(HL)
	BIT 7,E
	JR NZ,M2770
	RES 6,(HL)
M2770:	POP BC
	JR M2734

;Falls die jetzige Prioritaet hoeher als die vorherige ist,
;werden beide Operationen auf dem Stack gespeichert. Wenn
;die jetzige Operation eine Stringbearbeitung bedeutet, muss
;diese noch im Operationkode angemerkt werden.

M2773:	PUSH DE
	LD A,C
	BIT 6,(IY+1)
	JR NZ,M2790
	AND 3FH
	ADD A,8
	LD C,A
	CP 10H
	JR NZ,M2788
	SET 6,C
	JR M2790

M2788:	JR C,M2761
	CP 17H
	JR Z,M2790
	SET 7,C
M2790:	PUSH BC
	RST GETNXT
	JP M24FF

;Tabelle zum Umsetzen der Operatoren in Operationskodes

M2795:	DEFB '+'
	DEFB 0CFH
	DEFB '-'
	DEFB 0C3H
	DEFB '*'
	DEFB 0C4H
	DEFB '/'
	DEFB 0C5H
	DEFB '^'
	DEFB 0C6H
	DEFB '='
	DEFB 0CEH
	DEFB '>'
	DEFB 0CCH
	DEFB '<'
	DEFB 0CDH
	DEFB 0C7H		;<=
	DEFB 0C9H
	DEFB 0C8H		;>=
	DEFB 0CAH
	DEFB 0C9H		;<>
	DEFB 0CBH
	DEFB 0C5H		;OR
	DEFB 0C7H
	DEFB 0C6H		;AND
	DEFB 0C8H
	DEFB 0

;Tabelle der zugehoerigen Prioritaeten

M27B0:	DEFB 6
	DEFB 8
	DEFB 8
	DEFB 0AH
	DEFB 2
	DEFB 3
	DEFB 5
	DEFB 5
	DEFB 5
	DEFB 5
	DEFB 5
	DEFB 5
	DEFB 6

;Subroutine zur Entwicklung von Benutzerdefinitionen
;(DEF FN)

M27BD:	CALL M2530
	JR NZ,M27F7
	RST GETNXT
	CALL M2C8D
	JP NC,M1C8A
	RST GETNXT
	CP '$'
	PUSH AF
	JR NZ,M27D0
	RST GETNXT
M27D0:	CP '('
	JR NZ,M27E6
	RST GETNXT
	CP ')'
	JR Z,M27E9
M27D9:	CALL AUSDRU
	RST GETAKT
	CP ','
	JR NZ,M27E4
	RST GETNXT
	JR M27D9

M27E4:	CP ')'
M27E6:	JP NZ,M1C8A
M27E9:	RST GETNXT
	LD HL,FLAGS		;Bit 1= Printer ein
	RES 6,(HL)
	POP AF
	JR Z,M27F4
	SET 6,(HL)
M27F4:	JP M2712

;Einstieg fuer Funktionen im Programmlauf

M27F7:	RST GETNXT
	AND 0DFH
	LD B,A
	RST GETNXT
	SUB '$'
	LD C,A
	JR NZ,M2802
	RST GETNXT
M2802:	RST GETNXT
	PUSH HL
	LD HL,(PROG)		;Start des Basicprogrammes
	DEC HL
M2808:	LD DE,0CEH
	PUSH BC
	CALL M1D86
	POP BC
	JR NC,M2814
	RST ERRAUS
	DEFB 18H

M2814:	PUSH HL
	CALL M28AB
	AND 0DFH
	CP B
	JR NZ,M2825
	CALL M28AB
	SUB '$'
	CP C
	JR Z,M2831
M2825:	POP HL
	DEC HL
	LD DE,200H
	PUSH BC
	CALL M198B
	POP BC
	JR M2808

;Der richtige FN-Befehl wurde gefunden.

M2831:	AND A
	CALL Z,M28AB
	POP DE
	POP DE
	LD (CHADD),DE		;Adr. des naechsten zu interpret. Zeichens
	CALL M28AB
	PUSH HL
	CP ')'
	JR Z,M2885
M2843:	INC HL
	LD A,(HL)
	CP 0EH
	LD D,40H
	JR Z,M2852
	DEC HL
	CALL M28AB
	INC HL
	LD D,0
M2852:	INC HL
	PUSH HL
	PUSH DE
	CALL AUSDRU
	POP AF
	XOR (IY+1)
	AND 40H
	JR NZ,M288B
	POP HL
	EX DE,HL
	LD HL,(STKEND)		;Anfang des freien Speichers
	LD BC,5
	SBC HL,BC
	LD (STKEND),HL		;Anfang des freien Speichers
	LDIR
	EX DE,HL
	DEC HL
	CALL M28AB
	CP ')'
	JR Z,M2885
	PUSH HL
	RST GETAKT
	CP ','
	JR NZ,M288B
	RST GETNXT
	POP HL
	CALL M28AB
	JR M2843

M2885:	PUSH HL
	RST GETAKT
	CP ')'
	JR Z,M288D

M288B:	RST ERRAUS
	DEFB 19H

M288D:	POP DE
	EX DE,HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	LD HL,(DEFADD)		;Argument fuer Funktionen
	EX (SP),HL
	LD (DEFADD),HL		;Argument fuer Funktionen
	PUSH DE
	RST GETNXT
	RST GETNXT
	CALL AUSDRU
	POP HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	POP HL
	LD (DEFADD),HL		;Argument fuer Funktionen
	RST GETNXT
	JP M2712

;Routine zum Ueberspringen von Funktionsteilen (Zeichen <21H)
;nur mit HL, denn CHADD muss erhalten bleiben.

M28AB:	INC HL
	LD A,(HL)
	CP '!'
	JR C,M28AB
	RET

;Subroutine zum Suchen von Variablen.
;Suche entweder im Variablenbereich oder, bei 'DEF FN'
;im Argumentbereich der Funktion.

M28B2:	SET 6,(IY+1)
	RST GETAKT
	CALL M2C8D
	JP NC,M1C8A
	PUSH HL
	AND 1FH
	LD C,A
	RST GETNXT
	PUSH HL
	CP '('
	JR Z,M28EF
	SET 6,C
	CP '$'
	JR Z,M28DE
	SET 5,C
	CALL M2C88
	JR NC,M28E3

;das letzte Zeichen eines Variablennamens suchen

M28D4:	CALL M2C88
	JR NC,M28EF
	RES 6,C
	RST GETNXT
	JR M28D4

M28DE:	RST GETNXT
	RES 6,(IY+1)

;Wenn das Highbyte von DEFADD nicht Null ist (=DEF FN)
;und wenn zur Laufzeit, dann wird die Suche nach den
;Argumenten von 'DEF FN' durchgefuehrt.

M28E3:	LD A,(DEFADD+1)		;Argument fuer Funktionen
	AND A
	JR Z,M28EF
	CALL M2530
	JP NZ,M2951
M28EF:	LD B,C
	CALL M2530
	JR NZ,M28FD
	LD A,C
	AND 0E0H
	SET 7,A
	LD C,A
	JR M2934

;Waehrend des Programmlaufes wird die Suche nach der
;Variablen im Variablenbereich durchgefuehrt.

M28FD:	LD HL,(VARS)		;Beginn der Variablen
M2900:	LD A,(HL)
	AND 7FH
	JR Z,M2932
	CP C
	JR NZ,M292A
	RLA
	ADD A,A
	JP P,M293F
	JR C,M293F

;lange Namen ganz untersuchen

	POP DE
	PUSH DE
	PUSH HL
M2912:	INC HL
M2913:	LD A,(DE)
	INC DE
	CP ' '
	JR Z,M2913
	OR 20H
	CP (HL)
	JR Z,M2912
	OR 80H
	CP (HL)
	JR NZ,M2929
	LD A,(DE)
	CALL M2C88
	JR NC,M293E

;Wenn die Namen nicht stimmen, muss die naechste
;Variable im Variablenbereich gesucht werden.
;HL ist Zeiger darauf

M2929:	POP HL
M292A:	PUSH BC
	CALL M19B8
	EX DE,HL
	POP BC
	JR M2900

M2932:	SET 7,B

;bei Syntaxpruefung hier hin

M2934:	POP DE
	RST GETAKT
	CP '('
	JR Z,M2943
	SET 5,B
	JR M294B

;der richtige Namen ist gefunden

M293E:	POP DE
M293F:	POP DE
	POP DE
	PUSH HL
	RST GETAKT
M2943:	CALL M2C88
	JR NC,M294B
	RST GETNXT
	JR M2943

M294B:	POP HL
	RL B
	BIT 6,B
	RET

;Unterprogramm, um die Argumente von 'DEF FN' auf den
;Calc.-Stack abzulegen. Der Einsprung erfolgt von der
;Variablensuchroutine aus.

M2951:	LD HL,(DEFADD)		;Argument fuer Funktionen
	LD A,(HL)
	CP ')'
	JP Z,M28EF
M295A:	LD A,(HL)
	OR 60H
	LD B,A
	INC HL
	LD A,(HL)
	CP 0EH
	JR Z,M296B
	DEC HL
	CALL M28AB
	INC HL
	RES 5,B
M296B:	LD A,B
	CP C
	JR Z,M2981
	INC HL
	INC HL
	INC HL
	INC HL
	INC HL
	CALL M28AB
	CP ')'
	JP Z,M28EF
	CALL M28AB
	JR M295A

M2981:	BIT 5,C
	JR NZ,M2991
	INC HL
	LD DE,(STKEND)		;Anfang des freien Speichers
	CALL VERDO
	EX DE,HL
	LD (STKEND),HL		;Anfang des freien Speichers
M2991:	POP DE
	POP DE
	XOR A
	INC A
	RET

;Subroutine zum Suchen von Stringparametern im
;Variablenbereich oder zum Finden der Basisadresse
;eines Arrays

M2996:	XOR A
	LD B,A
	BIT 7,C
	JR NZ,M29E7
	BIT 7,(HL)
	JR NZ,M29AE
	INC A
M29A1:	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	INC HL
	EX DE,HL
	CALL M2AB2
	RST GETAKT
	JP M2A49

M29AE:	INC HL
	INC HL
	INC HL
	LD B,(HL)
	BIT 6,C
	JR Z,M29C0
	DEC B
	JR Z,M29A1
	EX DE,HL
	RST GETAKT
	CP '('
	JR NZ,M2A20
	EX DE,HL
M29C0:	EX DE,HL
	JR M29E7

;Nachfolgend die Schleife zum Suchen der Parameter eines
;Arrayelements. B dient als Dimensionszaehler. Stringarrays
;haben eine Dimension weniger als angegeben, da der letzte
;Teil als Beschreibung eines Teilstrings dient.

M29C3:	PUSH HL
	RST GETAKT
	POP HL
	CP ','
	JR Z,M29EA
	BIT 7,C
	JR Z,M2A20
	BIT 6,C
	JR NZ,M29D8
	CP ')'
	JR NZ,M2A12
	RST GETNXT
	RET

M29D8:	CP ')'
	JR Z,M2A48
	CP 0CCH
	JR NZ,M2A12
M29E0:	RST GETAKT
	DEC HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	JR M2A45

;normaler Einstiegspunkt in diese Routine

M29E7:	LD HL,0
M29EA:	PUSH HL
	RST GETNXT
	POP HL
	LD A,C
	CP 0C0H
	JR NZ,M29FB
	RST GETAKT
	CP ')'
	JR Z,M2A48
	CP 0CCH
	JR Z,M29E0
M29FB:	PUSH BC
	PUSH HL
	CALL M2AEE
	EX (SP),HL
	EX DE,HL
	CALL M2ACC
	JR C,M2A20
	DEC BC
	CALL M2AF4
	ADD HL,BC
	POP DE
	POP BC
	DJNZ M29C3
	BIT 7,C
M2A12:	JR NZ,M2A7A
	PUSH HL
	BIT 6,C
	JR NZ,M2A2C
	LD B,D
	LD C,E
	RST GETAKT
	CP ')'
	JR Z,M2A22
M2A20:	RST ERRAUS
	DEFB 2

M2A22:	RST GETNXT
	POP HL
	LD DE,5
	CALL M2AF4
	ADD HL,BC
	RET

;Stringarrays weiter bearbeiten

M2A2C:	CALL M2AEE
	EX (SP),HL
	CALL M2AF4
	POP BC
	ADD HL,BC
	INC HL
	LD B,D
	LD C,E
	EX DE,HL
	CALL M2AB1
	RST GETAKT
	CP ')'
	JR Z,M2A48
	CP ','
	JR NZ,M2A20
M2A45:	CALL M2A52
M2A48:	RST GETNXT
M2A49:	CP '('
	JR Z,M2A45
	RES 6,(IY+1)
	RET

;Subroutine zum Bearbeiten von Teilstrings

M2A52:	CALL M2530
	CALL NZ,M2BF1
	RST GETNXT
	CP ')'
	JR Z,M2AAD
	PUSH DE
	XOR A
	PUSH AF
	PUSH BC
	LD DE,1
	RST GETAKT
	POP HL
	CP 0CCH
	JR Z,M2A81
	POP AF
	CALL M2ACD
	PUSH AF
	LD D,B
	LD E,C
	PUSH HL
	RST GETAKT
	POP HL
	CP 0CCH
	JR Z,M2A81
	CP ')'
M2A7A:	JP NZ,M1C8A

;Hier wird ein einzelnes Zeichen eines Strings,
;z.B. C$(7), bearbeitet

	LD H,D
	LD L,E
	JR M2A94

M2A81:	PUSH HL
	RST GETNXT
	POP HL
	CP ')'
	JR Z,M2A94
	POP AF
	CALL M2ACD
	PUSH AF
	RST GETAKT
	LD H,B
	LD L,C
	CP ')'
	JR NZ,M2A7A
M2A94:	POP AF
	EX (SP),HL
	ADD HL,DE
	DEC HL
	EX (SP),HL
	AND A
	SBC HL,DE
	LD BC,0
	JR C,M2AA8
	INC HL
	AND A
	JP M,M2A20
	LD B,H
	LD C,L
M2AA8:	POP DE
	RES 6,(IY+1)
M2AAD:	CALL M2530
	RET Z

;Subroutine, um Parameter, die in den Reg. A - E enthalten
;sind, auf den Calc.-Stack abzulegen. Reg. A = 0 bedeutet
;String von einem Array oder ein Teilstring, eine 1 signa-
;lisiert einen einfachen String, dessen alter Wert entfernt
;werden kann.

M2AB1:	XOR A

M2AB2:	RES 6,(IY+1)
M2AB6:	PUSH BC
	CALL PLATZ5
	POP BC
	LD HL,(STKEND)		;Anfang des freien Speichers
	LD (HL),A
	INC HL
	LD (HL),E
	INC HL
	LD (HL),D
	INC HL
	LD (HL),C
	INC HL
	LD (HL),B
	INC HL
	LD (STKEND),HL		;Anfang des freien Speichers
	RET

;Subroutine zum Einlesen einer Integerzahl ins Reg. BC.
;Das Ergebnis darf nicht groesser als der Inhalt von HL
;sein, sonst ERROR. Erroranzeige in Reg. A: 0FFH = ERROR

M2ACC:	XOR A
M2ACD:	PUSH DE
	PUSH HL
	PUSH AF
	CALL PAR06
	POP AF
	CALL M2530
	JR Z,M2AEB
	PUSH AF
	CALL M1E99
	POP DE
	LD A,B
	OR C
	SCF
	JR Z,M2AE8
	POP HL
	PUSH HL
	AND A
	SBC HL,BC
M2AE8:	LD A,D
	SBC A,0
M2AEB:	POP HL
	POP DE
	RET

;Diese Subroutine laedt Register DE aus den Speicher-
;plaetzen (DE+1),(DE+2)

M2AEE:	EX DE,HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	RET

;Subroutine zum Berechnen von DE * HL und Test, dass
;das Ergibnis in HL kleiner als 65536 ist

M2AF4:	CALL M2530
	RET Z
	CALL M30A9
	JP C,M1F15
	RET

;Befehl LET
;Es wird die tatsaechliche Zuweisung bei LET, READ und
;INPUT durchgefuehrt

M2AFF:	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	BIT 1,(IY+37H)
	JR Z,M2B66
	LD BC,5
M2B0B:	INC BC
M2B0C:	INC HL
	LD A,(HL)
	CP ' '
	JR Z,M2B0C
	JR NC,M2B1F
	CP 10H
	JR C,M2B29
	CP 16H
	JR NC,M2B29
	INC HL
	JR M2B0C

M2B1F:	CALL M2C88
	JR C,M2B0B
	CP '$'
	JP Z,M2BC0


;Fuer eine neue numerische Variable werden 'BC' Plaetze
;gebraucht (NAME + WERT). Danach wird die Variable
;komplett kopiert.

M2B29:	LD A,C
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	CALL MACHPL
	INC HL
	INC HL
	EX DE,HL
	PUSH DE
	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	DEC DE
	SUB 6
	LD B,A
	JR Z,M2B4F
M2B3E:	INC HL
	LD A,(HL)
	CP '!'
	JR C,M2B3E
	OR 20H
	INC DE
	LD (DE),A
	DJNZ M2B3E
	OR 80H
	LD (DE),A
	LD A,0C0H
M2B4F:	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	XOR (HL)
	OR 20H
	POP HL
	CALL M2BEA
M2B59:	PUSH HL
	RST CALRUF
	DEFB 2
	DEFB 38H

	POP HL
	LD BC,5
	AND A
	SBC HL,BC
	JR M2BA6

;Bearbeitung einer bereits vorhandenen Variablen

M2B66:	BIT 6,(IY+1)
	JR Z,M2B72

;Der alte Zahlenwert einer numerischen Variablen wird
;durch den neuen ueberschrieben. HL muss deshalb
;korrigiert werden.

	LD DE,6
	ADD HL,DE
	JR M2B59

;Stringvariablen bearbeiten

M2B72:	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	LD BC,(STRLEN)		;Laenge eines Strings
	BIT 0,(IY+37H)
	JR NZ,M2BAF

;Bearbeiten von Teilstrings und Strings von Arrays

	LD A,B
	OR C
	RET Z
	PUSH HL
	RST REST30
	PUSH DE
	PUSH BC
	LD D,H
	LD E,L
	INC HL
	LD (HL),' '
	LDDR
	PUSH HL
	CALL M2BF1
	POP HL
	EX (SP),HL
	AND A
	SBC HL,BC
	ADD HL,BC
	JR NC,M2B9B
	LD B,H
	LD C,L
M2B9B:	EX (SP),HL
	EX DE,HL
	LD A,B
	OR C
	JR Z,M2BA3
	LDIR
M2BA3:	POP BC
	POP DE
	POP HL

;Subroutine zum Einschreiben einer numerischen Variablen
;vom Calc.-Stack oder eines Strings vom Workspace in den
;Variablenbereich

M2BA6:	EX DE,HL
	LD A,B
	OR C
	RET Z
	PUSH DE
	LDIR
	POP HL
	RET

;Bearbeitung eines kompletten, neuen und einfachen Strings
;(von LET herkommend)

M2BAF:	DEC HL
	DEC HL
	DEC HL
	LD A,(HL)
	PUSH HL
	PUSH BC
	CALL M2BC6
	POP BC
	POP HL
	INC BC
	INC BC
	INC BC
	JP RAUS2

;neue einfache Strings bearbeiten

M2BC0:	LD A,0DFH
	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	AND (HL)
M2BC6:	PUSH AF
	CALL M2BF1
	EX DE,HL
	ADD HL,BC
	PUSH BC
	DEC HL
	LD (DEST),HL		;Variablenadresse bei Zuweisung
	INC BC
	INC BC
	INC BC
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	CALL MACHPL
	LD HL,(DEST)		;Variablenadresse bei Zuweisung
	POP BC
	PUSH BC
	INC BC
	LDDR
	EX DE,HL
	INC HL
	POP BC
	LD (HL),B
	DEC HL
	LD (HL),C
	POP AF

;Subroutine zum Einschreiben des ersten Zeichens eines
;Variablennamens (altes Endebyte mit 80H). HL zeigt am
;Ende auf die neue Ende(80H)-Position.

M2BEA:	DEC HL
	LD (HL),A
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	RET

;Subroutine zum Laden des letzten Eintrags vom Calc.-Stack.
;Dier Werte koennen eine Variable oder Stringparameter sein.

M2BF1:	LD HL,(STKEND)		;Anfang des freien Speichers
	DEC HL
	LD B,(HL)
	DEC HL
	LD C,(HL)
	DEC HL
	LD D,(HL)
	DEC HL
	LD E,(HL)
	DEC HL
	LD A,(HL)
	LD (STKEND),HL		;Anfang des freien Speichers
	RET

;Befehl DIM
;Diese Routine dient zum Anlegen der Arrays. Wenn bereits
;ein Array unter dem gleichen Namen existiert, so wird das
;alte ueberschrieben. Das ganze Array wird beim Anlegen mit
;0 (numerisch) oder 20H (Space, bei Strings) beschrieben.

M2C02:	CALL M28B2
M2C05:	JP NZ,M1C8A
	CALL M2530
	JR NZ,M2C15
	RES 6,C
	CALL M2996
	CALL M1BEE
M2C15:	JR C,M2C1F
	PUSH BC
	CALL M19B8
	CALL RAUS2
	POP BC
M2C1F:	SET 7,C
	LD B,0
	PUSH BC
	LD HL,1
	BIT 6,C
	JR NZ,M2C2D
	LD L,5
M2C2D:	EX DE,HL
M2C2E:	RST GETNXT
	LD H,0FFH
	CALL M2ACC
	JP C,M2A20
	POP HL
	PUSH BC
	INC H
	PUSH HL
	LD H,B
	LD L,C
	CALL M2AF4
	EX DE,HL
	RST GETAKT
	CP ','
	JR Z,M2C2E
	CP ')'
	JR NZ,M2C05
	RST GETNXT
	POP BC
	LD A,C
	LD L,B
	LD H,0
	INC HL
	INC HL
	ADD HL,HL
	ADD HL,DE
	JP C,M1F15
	PUSH DE
	PUSH BC
	PUSH HL
	LD B,H
	LD C,L
	LD HL,(ELINE)		;Adresse des eingegebenen Befehls
	DEC HL
	CALL MACHPL
	INC HL
	LD (HL),A
	POP BC
	DEC BC
	DEC BC
	DEC BC
	INC HL
	LD (HL),C
	INC HL
	LD (HL),B
	POP BC
	LD A,B
	INC HL
	LD (HL),A
	LD H,D
	LD L,E
	DEC DE
	LD (HL),0
	BIT 6,C
	JR Z,M2C7C
	LD (HL),' '
M2C7C:	POP BC
	LDDR
M2C7F:	POP BC
	LD (HL),B
	DEC HL
	LD (HL),C
	DEC HL
	DEC A
	JR NZ,M2C7F
	RET

;Subroutine zum Pruefen auf alphanumerisch. CARRY ist
;gesetzt bei Buchstaben und Ziffern.

M2C88:	CALL ZIFFER
	CCF
	RET C

;Subroutine ueberprueft auf Buchstaben. CARRY ist
;bei Buchstaben gesetzt.

M2C8D:	CP 'A'
	CCF
	RET NC
	CP 5BH
	RET C
	CP 'a'
	CCF
	RET NC
	CP 7BH
	RET

;Subroutien zum Wandeln von Dezimalzahlen oder, mit dem
;Zusatz 'BIN', Binaerzahlen in Floatingpointzahlen, die
;dann als letztes Ergebnis auf dem Calc.-Stack abgelegt
;werden.

DEZFLO: CP 0C4H
	JR NZ,M2CB8
	LD DE,0
BINFLO: RST GETNXT
	SUB '1'
	ADC A,0
	JR NZ,M2CB3
	EX DE,HL
	CCF
	ADC HL,HL
	JP C,M31AD
	EX DE,HL
	JR BINFLO

M2CB3:	LD B,D
	LD C,E
	JP M2D2B

M2CB8:	CP '.'
	JR Z,M2CCB
	CALL M2D3B
	CP '.'
	JR NZ,M2CEB
	RST GETNXT
	CALL ZIFFER
	JR C,M2CEB
	JR M2CD5

;Zahlen, die mit Punkt anfangen bearbeiten

M2CCB:	RST GETNXT
	CALL ZIFFER
M2CCF:	JP C,M1C8A
	RST CALRUF
	DEFB 0A0H
	DEFB 38H

M2CD5:	RST CALRUF
	DEFB 0A1H
	DEFB 0C0H
	DEFB 2
	DEFB 38H

M2CDA:	RST GETAKT
	CALL M2D22
	JR C,M2CEB
	RST CALRUF
	DEFB 0E0H
	DEFB 0A4H
	DEFB 5
	DEFB 0C0H
	DEFB 4
	DEFB 0FH
	DEFB 38H

	RST GETNXT
	JR M2CDA

;Exponent untersuchen

M2CEB:	CP 'E'
	JR Z,M2CF2
	CP 'e'
	RET NZ

M2CF2:	LD B,0FFH
	RST GETNXT
	CP '+'
	JR Z,M2CFE
	CP '-'
	JR NZ,M2CFF
	INC B
M2CFE:	RST GETNXT
M2CFF:	CALL ZIFFER
	JR C,M2CCF
	PUSH BC
	CALL M2D3B
	CALL M2DD5
	POP BC
	JP C,M31AD
	AND A
	JP M,M31AD
	INC B
	JR Z,M2D18
	NEG
M2D18:	JP M2D4F

;Subroutine zum Untersuchen auf Ziffern. Bei Ziffern
;wird das CARRY-Flag gesetzt.

ZIFFER: CP '0'
	RET C
	CP ':'
	CCF
	RET

;Subroutine zum Ablegen eines Digits (Ziffer) auf dem
;Calc.-Stack.

M2D22:	CALL ZIFFER
	RET C
	SUB '0'

;Subroutine legt Binaerzahl in A als Floatingpointzahl
;auf dem Calc.-Stack als letzten Wert ab.

M2D28:	LD C,A
	LD B,0

;Subroutine zum Ablegen der Integerzahl in BC auf dem
;Calc.-Stack als letzter Wert in Floatingpointformat.
;Das 1. und das 5. Byte sind immer 0, das 2. gibt das
;Vorzeichen an: 0 = positiv, FFH = negativ. Das 3. Byte
;ist das Lowbyte und das 4. das Highbyte. Die Ablage
;erfolgt im 2-Komplement.

M2D2B:	LD IY,ERRNR
	XOR A
	LD E,A
	LD D,C
	LD C,B
	LD B,A
	CALL M2AB6
	RST CALRUF
	DEFB 38H

	AND A
	RET

;Subroutine zum Einlesen ganzzahliger Dezimalzahlen als
;letzten Wert auf dem Calc.-Stack. Aufruf erfolgt z.B.
;beim Einlesen einer Dezimalzahl aus einer BASIC-Zeile.
;(siehe (DEZFLO)

M2D3B:	PUSH AF
	RST CALRUF
	DEFB 0A0H
	DEFB 38H

	POP AF
M2D40:	CALL M2D22
	RET C
	RST CALRUF
	DEFB 1
	DEFB 0A4H
	DEFB 4
	DEFB 0FH
	DEFB 38H

	CALL NEXZEI
	JR M2D40

;Arithmetische Routinen

;Wandlung von Dezimalzahlen mit Mantisse/Exponent-
;Darstellung (xEn) in eine Floatingpointzahl. X steht
;als letzter Wert bereits auf dem Calc.-Stack.

M2D4F:	RLCA
	RRCA
	JR NC,M2D55
	CPL
	INC A
M2D55:	PUSH AF
	LD HL,MEMBOT		;Calculatorspeicher
	CALL M350B
	RST CALRUF
	DEFB 0A4H
	DEFB 38H

	POP AF
EXSCHL: SRL A
	JR NC,M2D71
	PUSH AF
	RST CALRUF
	DEFB 0C1H
	DEFB 0E0H
	DEFB 0
	DEFB EXDIV-$
	DEFB 4
	DEFB 33H
	DEFB EXGET1-$
EXDIV:	DEFB 5
EXGET1: DEFB 0E1H
	DEFB 38H

	POP AF
M2D71:	JR Z,M2D7B
	PUSH AF
	RST CALRUF
	DEFB 31H
	DEFB 4
	DEFB 38H

	POP AF
	JR EXSCHL

M2D7B:	RST CALRUF
	DEFB 2
	DEFB 38H
	RET

;Subroutine zum Holen einer Integerzahl vom Calc.-Stack

M2D7F:	INC HL
	LD C,(HL)
	INC HL
	LD A,(HL)
	XOR C
	SUB C
	LD E,A
	INC HL
	LD A,(HL)
	ADC A,C
	XOR C
	LD D,A
	RET

;Subroutine zum Abspeichern einer Integegerzahl auf dem
;Calc.-Stack

M2D8C:	LD C,0
M2D8E:	PUSH HL
	LD (HL),0
	INC HL
	LD (HL),C
	INC HL
	LD A,E
	XOR C
	SUB C
	LD (HL),A
	INC HL
	LD A,D
	ADC A,C
	XOR C
	LD (HL),A
	INC HL
	LD (HL),0
	POP HL
	RET

;Subroutine zum Wandeln einer Floatingpointzahl in eine
;Integerzahl und Uebertragen des Ergebnisses in BC

M2DA2:	RST CALRUF
	DEFB 38H
	LD A,(HL)
	AND A
	JR Z,M2DAD
	RST CALRUF
	DEFB 0A2H
	DEFB 0FH
	DEFB 27H
	DEFB 38H

M2DAD:	RST CALRUF
	DEFB 2
	DEFB 38H

	PUSH HL
	PUSH DE
	EX DE,HL
	LD B,(HL)
	CALL M2D7F
	XOR A
	SUB B
	BIT 7,C
	LD B,D
	LD C,E
	LD A,E
	POP DE
	POP HL
	RET

;Subroutine zum Berechnen von LOG(2^A). A enthaelt den
;Exponent einer Floatingpointzahl. Die Berechnung dient
;zum Bestimmen der Vorkommastellen einer auszugebenden
;Dezimalzahl oder der auf den Dezimalpunkt folgenden Nullen.

LOG2A:	LD D,A
	RLA
	SBC A,A
	LD E,A
	LD C,A
	XOR A
	LD B,A
	CALL M2AB6
	RST CALRUF
	DEFB 34H
	DEFB 0EFH
	DEFB 1AH
	DEFB 20H
	DEFB 9AH
	DEFB 85H
	DEFB 4
	DEFB 27H
	DEFB 38H

;Floatingpointzahl in eine Integerzahl von einem Byte wandeln,
;Ergebnis in A. Wenn das Ergebnis >255 ist, erfolgt eine ERROR-
;Meldung.



M2DD5:	CALL M2DA2
	RET C
	PUSH AF
	DEC B
	INC B
	JR Z,M2DE1
	POP AF
	SCF
	RET

M2DE1:	POP AF
	RET

;Subroutine zum Ausgeben einer Floatingpointzahl durch 'PRINT'-
;oder 'STR$'-Befehl

M2DE3:	RST CALRUF
	DEFB 31H
	DEFB 36H
	DEFB 0
	DEFB FPNEGA-$
	DEFB 31H
	DEFB 37H
	DEFB 0
	DEFB FPPOSI-$
	DEFB 2
	DEFB 38H

	LD A,'0'
	RST PRTOUT
	RET

;Fuer negative Zahlen erst ein Minuszeichen ausgeben und
;dann ABS(X) bilden, so dass die Zahl im weiteren wie eine
;Positive behandelt werden kann.

FPNEGA: DEFB 2AH
	DEFB 38H

	LD A,'-'
	RST PRTOUT
	RST CALRUF

;Xist im folgenden ABS(X)

FPPOSI: DEFB 0A0H
	DEFB 0C3H
	DEFB 0C4H
	DEFB 0C5H
	DEFB 2
	DEFB 38H

	EXX
	PUSH HL
	EXX
M2E01:	RST CALRUF
	DEFB 31H
	DEFB 27H
	DEFB 0C2H
	DEFB 3
	DEFB 0E2H
	DEFB 1
	DEFB 0C2H
	DEFB 2
	DEFB 38H

	LD A,(HL)
	AND A
	JR NZ,M2E56
	CALL M2D7F
	LD B,10H
	LD A,D
	AND A
	JR NZ,M2E1E
	OR E
	JR Z,M2E24
	LD D,E
	LD B,8
M2E1E:	PUSH DE
	EXX
	POP DE
	EXX
	JR M2E7B

;Bearbeitung, wenn nur ein Nachkommateil vorhanden

M2E24:	RST CALRUF
	DEFB 0E2H
	DEFB 38H

	LD A,(HL)
	SUB 7EH
	CALL LOG2A
	LD D,A
	LD A,(5CACH)
	SUB D
	LD (5CACH),A
	LD A,D
	CALL M2D4F
	RST CALRUF
	DEFB 31H
	DEFB 27H
	DEFB 0C1H
	DEFB 3
	DEFB 0E1H
	DEFB 38H

	CALL M2DD5
	PUSH HL
	LD (5CA1H),A
	DEC A
	RLA
	SBC A,A
	INC A
	LD HL,5CABH
	LD (HL),A
	INC HL
	ADD A,(HL)
	LD (HL),A
	POP HL
	JP M2ECF

;Zahlen, die groesser als 2^27 sind, werden so bearbeitet,
;dass 8 Stellen vor dem Komma ausgegeben werden.

M2E56:	SUB 80H
	CP 28
	JR C,M2E6F
	CALL LOG2A
	SUB 7
	LD B,A
	LD HL,5CACH
	ADD A,(HL)
	LD (HL),A
	LD A,B
	NEG
	CALL M2D4F
	JR M2E01

;Integerteil von X in den Ausgabepuffer MEM3 und MEM4
;speichern

M2E6F:	EX DE,HL
	CALL M2FBA
	EXX
	SET 7,D
	LD A,L
	EXX
	SUB 80H
	LD B,A
M2E7B:	SLA E
	RL D
	EXX
	RL E
	RL D
	EXX
	LD HL,5CAAH
	LD C,5
M2E8A:	LD A,(HL)
	ADC A,A
	DAA
	LD (HL),A
	DEC HL
	DEC C
	JR NZ,M2E8A
	DJNZ M2E7B

;Das Ergbenis liegt nunmehr gepackt in MEM4 vor. Dieses wird
;jetzt auf insgesamt 9 Bytes, pro Stelle ein Byte, aufgeteilt
;nach MEM3 und MEM4.

	XOR A
	LD HL,5CA6H
	LD DE,5CA1H
	LD B,9
	RLD
	LD C,0FFH
M2EA1:	RLD
	JR NZ,M2EA9
	DEC C
	INC C
	JR NZ,M2EB3
M2EA9:	LD (DE),A
	INC DE
	INC (IY+71H)
	INC (IY+72H)
	LD C,0
M2EB3:	BIT 0,B
	JR Z,M2EB8
	INC HL
M2EB8:	DJNZ M2EA1
	LD A,(5CABH)
	SUB 9
	JR C,M2ECB
	DEC (IY+71H)
	LD A,4
	CP (IY+6FH)
	JR DEZRND

;Die Nachkommastellen werden jetzt im Ausgabepuffer
;abgelegt.

M2ECB:	RST CALRUF
	DEFB 2
	DEFB 0E2H
	DEFB 38H

M2ECF:	EX DE,HL
	CALL M2FBA
	EXX
	LD A,80H
	SUB L
	LD L,0
	SET 7,D
	EXX
	CALL SHIFTF
M2EDF:	LD A,(IY+71H)
	CP 8
	JR C,M2EEC
	EXX
	RL D
	EXX
	JR DEZRND

M2EEC:	LD BC,200H
M2EEF:	LD A,E
	CALL M2F8B
	LD E,A
	LD A,D
	CALL M2F8B
	LD D,A
	PUSH BC
	EXX
	POP BC
	DJNZ M2EEF
	LD HL,5CA1H
	LD A,C
	LD C,(IY+71H)
	ADD HL,BC
	LD (HL),A
	INC (IY+71H)
	JR M2EDF

;die Dezimalstellen runden

DEZRND: PUSH AF
	LD HL,5CA1H
	LD C,(IY+71H)
	LD B,0
	ADD HL,BC
	LD B,C
	POP AF
M2F18:	DEC HL
	LD A,(HL)
	ADC A,0
	LD (HL),A
	AND A
	JR Z,M2F25
	CP 0AH
	CCF
	JR NC,M2F2D
M2F25:	DJNZ M2F18
	LD (HL),1
	INC B
	INC (IY+72H)
M2F2D:	LD (IY+71H),B
	RST CALRUF
	DEFB 2
	DEFB 38H

	EXX
	POP HL
	EXX

;die Zahl kann ausgegeben werden

	LD BC,(5CABH)
	LD HL,5CA1H
	LD A,B
	CP 9
	JR C,M2F46
	CP 0FCH
	JR C,M2F6C
M2F46:	AND A
	CALL Z,M15EF
M2F4A:	XOR A
	SUB B
	JP M,M2F52
	LD B,A
	JR M2F5E

;die Stellen vor dem Punkt ausgeben

M2F52:	LD A,C
	AND A
	JR Z,M2F59
	LD A,(HL)
	INC HL
	DEC C
M2F59:	CALL M15EF
	DJNZ M2F52
M2F5E:	LD A,C
	AND A
	RET Z
	INC B
	LD A,'.'
M2F64:	RST PRTOUT
	LD A,'0'
	DJNZ M2F64
	LD B,C
	JR M2F52

;Einstieg, wenn die Zahl in Exponentialformat
;gedruckt werden muss

M2F6C:	LD D,B
	DEC D
	LD B,1
	CALL M2F4A
	LD A,'E'
	RST PRTOUT
	LD C,D
	LD A,C
	AND A
	JP P,M2F83
	NEG
	LD C,A
	LD A,'-'
	JR M2F85

M2F83:	LD A,'+'
M2F85:	RST PRTOUT
	LD B,0
	JP M1A1B

;Subroutine zum Berechnen von 10*(A)+(C)

M2F8B:	PUSH DE
	LD L,A
	LD H,0
	LD E,L
	LD D,H
	ADD HL,HL
	ADD HL,HL
	ADD HL,DE
	ADD HL,HL
	LD E,C
	ADD HL,DE
	LD C,H
	LD A,L
	POP DE
	RET

;Subroutine zum Vorbereiten der Addition einer
;Floatingpointzahl

M2F9B:	LD A,(HL)
	LD (HL),0
	AND A
	RET Z
	INC HL
	BIT 7,(HL)
	SET 7,(HL)
	DEC HL
	RET Z
	PUSH BC
	LD BC,5
	ADD HL,BC
	LD B,C
	LD C,A
	SCF
M2FAF:	DEC HL
	LD A,(HL)
	CPL
	ADC A,0
	LD (HL),A
	DJNZ M2FAF
	LD A,C
	POP BC
	RET

;Subroutine zum Laden von 2 Floatingpointzahlen in die
;Prozessorregister. HL zeigt auf 1. Byte der ersten und
;DE auf 1.Byte der zweiten Zahl.
;Zahl 1: M1 - M5 in H',B',C',C,B
;Zahl 2: M1 - M5 in L',D',E',D,E

M2FBA:	PUSH HL
	PUSH AF
	LD C,(HL)
	INC HL
	LD B,(HL)
	LD (HL),A
	INC HL
	LD A,C
	LD C,(HL)
	PUSH BC
	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	EX DE,HL
	LD D,A
	LD E,(HL)
	PUSH DE
	INC HL
	LD D,(HL)
	INC HL
	LD E,(HL)
	PUSH DE
	EXX
	POP DE
	POP HL
	POP BC
	EXX
	INC HL
	LD D,(HL)
	INC HL
	LD E,(HL)
	POP AF
	POP HL
	RET

;Subroutine zum Shiften einer Zahl um maximal 32 Bits
;fuer eine Addition (Exponentenangleich)

SHIFTF: AND A
	RET Z
	CP 33
	JR NC,ADDNUL
	PUSH BC
	LD B,A
SHIFTB: EXX
	SRA L
	RR D
	RR E
	EXX
	RR D
	RR E
	DJNZ SHIFTB
	POP BC
	RET NC
	CALL M3004
	RET NZ
ADDNUL: EXX
	XOR A
M2FFB:	LD L,0
	LD D,A
	LD E,L
	EXX
	LD DE,0
	RET

;Subroutine zum Addieren eines Carrys bei der Rechtsver-
;schiebung einer Zahl

M3004:	INC E
	RET NZ
	INC D
	RET NZ
	EXX
	INC E
	JR NZ,M300D
	INC D
M300D:	EXX
	RET

;Subtraktion zweier Floatingpointzahlen

SUBTRA: EX DE,HL
	CALL NEGIER
	EX DE,HL

;Subroutine zum Addieren zweier Floatingpointzahlen
;auf dem Calc.-Stack zu einem 'letzten Wert'

ADDIER: LD A,(DE)
	OR (HL)
	JR NZ,M303E

;Addition von Integerzahlen

	PUSH DE
	INC HL
	PUSH HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	INC HL
	INC HL
	LD A,(HL)
	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	POP HL
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	ADC A,(HL)
	RRCA
	ADC A,0
	JR NZ,M303C
	SBC A,A
	LD (HL),A
	INC HL
	LD (HL),E
	INC HL
	LD (HL),D
	DEC HL
	DEC HL
	DEC HL
	POP DE
	RET

M303C:	DEC HL
	POP DE
M303E:	CALL M3293

;volle Addition zweier Zahlen (keine Integerzahlen)

	EXX
	PUSH HL
	EXX
	PUSH DE
	PUSH HL
	CALL M2F9B
	LD B,A
	EX DE,HL
	CALL M2F9B
	LD C,A
	CP B
	JR NC,M3055
	LD A,B
	LD B,C
	EX DE,HL
M3055:	PUSH AF
	SUB B
	CALL M2FBA
	CALL SHIFTF
	POP AF
	POP HL
	LD (HL),A
	PUSH HL
	LD L,B
	LD H,C
	ADD HL,DE
	EXX
	EX DE,HL
	ADC HL,BC
	EX DE,HL
	LD A,H
	ADC A,L
	LD L,A
	RRA
	XOR L
	EXX
	EX DE,HL
	POP HL
	RRA
	JR NC,M307C
	LD A,1
	CALL SHIFTF
	INC (HL)
	JR Z,M309F
M307C:	EXX
	LD A,L
	AND 80H
	EXX
	INC HL
	LD (HL),A
	DEC HL
	JR Z,M30A5
	LD A,E
	NEG
	CCF
	LD E,A
	LD A,D
	CPL
	ADC A,0
	LD D,A
	EXX
	LD A,E
	CPL
	ADC A,0
	LD E,A
	LD A,D
	CPL
	ADC A,0
	JR NC,M30A3
	RRA
	EXX
	INC (HL)
M309F:	JP Z,M31AD
	EXX
M30A3:	LD D,A
	EXX
M30A5:	XOR A
	JP TSTNOR

;Subroutine zum Berechnen von HL=DE*HL

M30A9:	PUSH BC
	LD B,10H
	LD A,H
	LD C,L
	LD HL,0
M30B1:	ADD HL,HL
	JR C,M30BE
	RL C
	RLA
	JR NC,M30BC
	ADD HL,DE
	JR C,M30BE
M30BC:	DJNZ M30B1
M30BE:	POP BC
	RET

;Subroutine zum Vorbereiten einer Multiplikation oder
;Division

M30C0:	CALL M34E9
	RET C
	INC HL
	XOR (HL)
	SET 7,(HL)
	DEC HL
	RET

;Subroutine Multiplikation

MULTIP: LD A,(DE)
	OR (HL)
	JR NZ,M30F0
	PUSH DE
	PUSH HL
	PUSH DE
	CALL M2D7F
	EX DE,HL
	EX (SP),HL
	LD B,C
	CALL M2D7F
	LD A,B
	XOR C
	LD C,A
	POP HL
	CALL M30A9
	EX DE,HL
	POP HL
	JR C,M30EF
	LD A,D
	OR E
	JR NZ,M30EA
	LD C,A
M30EA:	CALL M2D8E
	POP DE
	RET

M30EF:	POP DE
M30F0:	CALL M3293
	XOR A
	CALL M30C0
	RET C
	EXX
	PUSH HL
	EXX
	PUSH DE
	EX DE,HL
	CALL M30C0
	EX DE,HL
	JR C,M315D
	PUSH HL
	CALL M2FBA
	LD A,B
	AND A
	SBC HL,HL
	EXX
	PUSH HL
	SBC HL,HL
	EXX
	LD B,21H
	JR M3125

M3114:	JR NC,M311B
	ADD HL,DE
	EXX
	ADC HL,DE
	EXX
M311B:	EXX
	RR H
	RR L
	EXX
	RR H
	RR L
M3125:	EXX
	RR B
	RR C
	EXX
	RR C
	RRA
	DJNZ M3114
	EX DE,HL
	EXX
	EX DE,HL
	EXX
	POP BC
	POP HL
	LD A,B
	ADD A,C
	JR NZ,M313B
	AND A
M313B:	DEC A
	CCF
M313D:	RLA
	CCF
	RRA
	JP P,M3146
	JR NC,M31AD
	AND A
M3146:	INC A
	JR NZ,M3151
	JR C,M3151
	EXX
	BIT 7,D
	EXX
	JR NZ,M31AD
M3151:	LD (HL),A
	EXX
	LD A,B
	EXX

;normalisieren der Mantisse fuer alle Rechenroutinen

TSTNOR: JR NC,NORMAL
	LD A,(HL)
	AND A
M3159:	LD A,80H
	JR Z,M315E
M315D:	XOR A
M315E:	EXX
	AND D
	CALL M2FFB
	RLCA
	LD (HL),A
	JR C,M3195
	INC HL
	LD (HL),A
	DEC HL
	JR M3195

NORMAL: LD B,32
M316E:	EXX
	BIT 7,D
	EXX
	JR NZ,M3186
	RLCA
	RL E
	RL D
	EXX
	RL E
	RL D
	EXX
	DEC (HL)
	JR Z,M3159
	DJNZ M316E
	JR M315D

M3186:	RLA
	JR NC,M3195
	CALL M3004
	JR NZ,M3195
	EXX
	LD D,80H
	EXX
	INC (HL)
	JR Z,M31AD
M3195:	PUSH HL
	INC HL
	EXX
	PUSH DE
	EXX
	POP BC
	LD A,B
	RLA
	RL (HL)
	RRA
	LD (HL),A
	INC HL
	LD (HL),C
	INC HL
	LD (HL),D
	INC HL
	LD (HL),E
	POP HL
	POP DE
	EXX
	POP HL
	EXX
	RET

M31AD:	RST ERRAUS
	DEFB 5			;'ARITHMETIC OVERFLOW'

;Subroutine Division

M31AF:	CALL M3293
	EX DE,HL
	XOR A
	CALL M30C0
	JR C,M31AD
	EX DE,HL
	CALL M30C0
	RET C
	EXX
	PUSH HL
	EXX
	PUSH DE
	PUSH HL
	CALL M2FBA
	EXX
	PUSH HL
	LD H,B
	LD L,C
	EXX
	LD H,C
	LD L,B
	XOR A
	LD B,0DFH
	JR M31E2

M31D2:	RLA
	RL C
	EXX
	RL C
	RL B
	EXX
	ADD HL,HL
	EXX
	ADC HL,HL
	EXX
	JR C,M31F2
M31E2:	SBC HL,DE
	EXX
	SBC HL,DE
	EXX
	JR NC,M31F9
	ADD HL,DE
	EXX
	ADC HL,DE
	EXX
	AND A
	JR M31FA

M31F2:	AND A
	SBC HL,DE
	EXX
	SBC HL,DE
	EXX
M31F9:	SCF
M31FA:	INC B
	JP M,M31D2
	PUSH AF
	JR Z,M31E2
	LD E,A
	LD D,C
	EXX
	LD E,C
	LD D,B
	POP AF
	RR B
	POP AF
	RR B
	EXX
	POP BC
	POP HL
	LD A,B
	SUB C
	JP M313D

;Subroutine zum Abtrennen des Integerteils einer
;Variablen

M3214:	LD A,(HL)
	AND A
	RET Z
	CP 81H
	JR NC,M3221
	LD (HL),0
	LD A,32
	JR M3272

M3221:	CP 91H
	JR NZ,M323F
	INC HL
	INC HL
	INC HL
	LD A,80H
	AND (HL)
	DEC HL
	OR (HL)
	DEC HL
	JR NZ,M3233
	LD A,80H
	XOR (HL)
M3233:	DEC HL
	JR NZ,M326C
	LD (HL),A
	INC HL
	LD (HL),0FFH
	DEC HL
	LD A,18H
	JR M3272

M323F:	JR NC,M326D
	PUSH DE
	CPL
	ADD A,91H
	INC HL
	LD D,(HL)
	INC HL
	LD E,(HL)
	DEC HL
	DEC HL
	LD C,0
	BIT 7,D
	JR Z,M3252
	DEC C
M3252:	SET 7,D
	LD B,8
	SUB B
	ADD A,B
	JR C,M325E
	LD E,D
	LD D,0
	SUB B
M325E:	JR Z,M3267
	LD B,A
M3261:	SRL D
	RR E
	DJNZ M3261
M3267:	CALL M2D8E
	POP DE
	RET

;grosse Werte fuer 'X' untersuchen

M326C:	LD A,(HL)
M326D:	SUB 0A0H
	RET P
	NEG
M3272:	PUSH DE
	EX DE,HL
	DEC HL
	LD B,A
	SRL B
	SRL B
	SRL B
	JR Z,M3283
M327E:	LD (HL),0
	DEC HL
	DJNZ M327E
M3283:	AND 7
	JR Z,M3290
	LD B,A
	LD A,0FFH
M328A:	SLA A
	DJNZ M328A
	AND (HL)
	LD (HL),A
M3290:	EX DE,HL
	POP DE
	RET

;Subroutine zum Abspeichern von 2 Integerzahlen
;in Floatingpointform auf dem Calc.-Stack

M3293:	CALL M3296
M3296:	EX DE,HL

;Subroutine zum Abspeichern einer Integerzahl
;auf dem Calc.-Stack in Floatingpointform

M3297:	LD A,(HL)
	AND A
	RET NZ
	PUSH DE
	CALL M2D7F
	XOR A
	INC HL
	LD (HL),A
	DEC HL
	LD (HL),A
	LD B,91H
	LD A,D
	AND A
	JR NZ,M32B1
	OR E
	LD B,D
	JR Z,M32BD
	LD D,E
	LD E,B
	LD B,89H
M32B1:	EX DE,HL
M32B2:	DEC B
	ADD HL,HL
	JR NC,M32B2
	RRC C
	RR H
	RR L
	EX DE,HL
M32BD:	DEC HL
	LD (HL),E
	DEC HL
	LD (HL),D
	DEC HL
	LD (HL),B
	POP DE
	RET

;===============================================

;ab hier Unterprogramme und Tabellen des

;	FLOATING - POINT - CALCULATORS


;Tabelle der Konstanten NULL, EINS, 0.5, PI/2, ZEHN

M32C5:	DEFB 0			;NULL
	DEFB 0B0H
	DEFB 0

	DEFB 40H		;EINS
	DEFB 0B0H
	DEFB 0
	DEFB 1

	DEFB 30H		;0.5
	DEFB 0

	DEFB 0F1H		;PI/2
	DEFB 49H
	DEFB 0FH
	DEFB 0DAH
	DEFB 0A2H

	DEFB 40H		;ZEHN
	DEFB 0B0H
	DEFB 0
	DEFB 0AH

;Tabelle der 'OPCODES', die dem Befehl RST CALRUF
;folge mit den dazugehoerigen Sprungadressen

M32D7:	DEFW M368F		;00: Sprung, wenn war
	DEFW TAUSCH		;01: Tauschen
	DEFW M33A1		;02: Loeschen
	DEFW SUBTRA		;03: Subtrahieren
	DEFW MULTIP		;04: Multiplizieren
	DEFW M31AF		;05: Dividieren
	DEFW M3851		;06: hoch 2 (^2)
	DEFW M351B		;07: ODER
	DEFW M3524		;08: logisch UND
	DEFW M353B		;09: ungleich
	DEFW M353B		;0A: kleiner als
	DEFW M353B		;0B: Strings ungleich
	DEFW M353B		;0C: nicht groesser
	DEFW M353B		;0D: nicht kleiner
	DEFW M353B		;0E: Strings gleich
	DEFW ADDIER		;0F: Addieren
	DEFW M352D		;10: String and Number
	DEFW M353B		;11: String <=
	DEFW M353B		;12: String >=
	DEFW M353B		;13: String <>
	DEFW M353B		;14: String >
	DEFW M353B		;15: String <
	DEFW M353B		;16: String =
	DEFW M359C		;17: Stringaddition
	DEFW M35DE		;18: VAL$
	DEFW M34BC		;19: USR$
	DEFW M3645		;1A: READIN
	DEFW NEGIER		;1B: negieren
	DEFW M3669		;1C: CODE
	DEFW M35DE		;1D: VAL
	DEFW M3674		;1E: LEN
	DEFW M37B5		;1F: SINUS
	DEFW M37AA		;20: COSINUS
	DEFW M37DA		;21: TANGENS
	DEFW M3833		;22: ARCUSSINUS
	DEFW M3843		;23: ARCUSCOSINUS
	DEFW M37E2		;24: ARCUSTANGENS
	DEFW M3713		;25: LN (Logarithmus)
	DEFW M36C4		;26: EXP (E hoch X)
	DEFW M36AF		;27: INT(EGER)
	DEFW M384A		;28: SQR (Wurzel)
	DEFW M3492		;29: SGN (Vorzeichen)
	DEFW ABSOLU		;2A: ABS (Betrag)
	DEFW M34AC		;2B: PEEK
	DEFW M34A5		;2C: IN
	DEFW M34B3		;2D: USR mit Zahl
	DEFW M361F		;2E: STR$
	DEFW M35C9		;2F: CHR$
	DEFW M3501		;30: NOT
	DEFW VERDO		;31: Duplizieren
	DEFW M36A0		;32: N MOD M- Division
	DEFW M3686		;33: Sprung
	DEFW M33C6		;34: Daten auf Stack
	DEFW M367A		;35: DJNZ
	DEFW M3506		;36: kleiner 0
	DEFW M34F9		;37: groesser 0
	DEFW M369B		;38: Ende CALCULATOR
	DEFW M3783		;39: hole Argument
	DEFW M3214		;3A: Abschneiden mit Runden
	DEFW M33A2		;3B: FP-CALC-2
	DEFW M2D4F		;3C: in Floating-Zahl wandeln
	DEFW M3297		;3D: wieder auf Stack legen
	DEFW M3449		;3E: Polynomenentwicklung
	DEFW M341B		;3F: NULL auf Stack
	DEFW M342D		;40: speichere in MEMO etc.
	DEFW M340F		;41: hole von MEMO etc.

;Calculator

;Aufruf normal durch RST 28H (RST CALRUF)
;Hinter dem RST 28H Befehl folgen ein oder mehrere Bytes,
;die die auszufuehrenden Operationen gemaess obenstehender
;Tabelle bestimmen.
;Die Rechenoperationen beziehen sich im allgemeinen auf
;den oder die 'LETZTEN WERT(E)' im Calculatorstack. Ein
;letzter Wert (genau 5 Bytes) kann eine Floatingpointzahl
;oder Stringparameter sein. Zusaetzlich benutzt der Calcu-
;lator einige Speicherplaetze zur Zwischenspeicherung von
;Teilergebnissen etc., die mit MEM0 - MEM5 bezeichnet sind
;und jeweils 5 Byte umfassen.

RECHNE: CALL M35BF
M335E:	LD A,B
	LD (BREG),A		;Calculator Hifsregister
RECH2:	EXX
	EX (SP),HL
	EXX
CLOOP:	LD (STKEND),DE		;Anfang des freien Speichers
	EXX
	LD A,(HL)
	INC HL
M336C:	PUSH HL
	AND A
	JP P,M3380
	LD D,A
	AND 60H
	RRCA
	RRCA
	RRCA
	RRCA
	ADD A,7CH
	LD L,A
	LD A,D
	AND 1FH
	JR M338E

M3380:	CP 18H
	JR NC,M338C
	EXX
	LD BC,0FFFBH
	LD D,H
	LD E,L
	ADD HL,BC
	EXX
M338C:	RLCA
	LD L,A
M338E:	LD DE,M32D7
	LD H,0
	ADD HL,DE
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD HL,CLOOP
	EX (SP),HL
	PUSH DE
	EXX
	LD BC,(STKEND+1)
M33A1:	RET

;Subroutine zum Loeschen des letzten Wertes im Calc.-Stack
;(OP-CODE 02). Der Aufruf fuehrt nur auf das obige 'RET',
;so dass nur HL als Zeiger auf den letzten Wert um 5 Byte
;vermindert wird, also auf den Vorletzten zeigt. Dadurch
;wird der bisherige letzte Wert nicht mehr adressiert und
;bei der naechsten Operation ueberschrieben.

;Subroutine um eine Operation auszufuehren (Auruf bei der
;Entwicklung von Ausdruecken, OP-CODE 3BH)

M33A2:	POP AF
	LD A,(BREG)		;Calculator Hifsregister
	EXX
	JR M336C

;Subroutine zum Ueberpruefen, ob noch 5 Speicherplaetze
;frei sind

PLATZ5: PUSH DE
	PUSH HL
	LD BC,5
	CALL M1F05
	POP HL
	POP DE
	RET

;Subroutine um 1 Zahl auf den Stack zu bringen

M33B4:	LD DE,(STKEND)		;Anfang des freien Speichers
	CALL VERDO
	LD (STKEND),DE		;Anfang des freien Speichers
	RET

;Umspeichern einer Floatingpointzahl (OP-CODE 31H)

VERDO:	CALL PLATZ5
	LDIR
	RET

;Abspeichern einer Floatingpointzahl, die dem OP-CODE 34H
;direkt folgt. Das 1. Byte, welches Exponent ist, gibt
;hierbei die Anzahl der noch folgenden Mantissenstellen an
;(Bit 7 und 6), der Rest wird mit Nullen aufgefuellt.

M33C6:	LD H,D
	LD L,E
M33C8:	CALL PLATZ5
	EXX
	PUSH HL
	EXX
	EX (SP),HL
	PUSH BC
	LD A,(HL)
	AND 0C0H
	RLCA
	RLCA
	LD C,A
	INC C
	LD A,(HL)
	AND 3FH
	JR NZ,M33DE
	INC HL
	LD A,(HL)
M33DE:	ADD A,50H
	LD (DE),A
	LD A,5
	SUB C
	INC HL
	INC DE
	LD B,0
	LDIR
	POP BC
	EX (SP),HL
	EXX
	POP HL
	EXX
	LD B,A
	XOR A
M33F1:	DEC B
	RET Z
	LD (DE),A
	INC DE
	JR M33F1

;Suchen der Konstanten in der Calculatortabelle. Die
;Nummer steht in A.

M33F7:	AND A
M33F8:	RET Z
	PUSH AF
	PUSH DE
	LD DE,0
	CALL M33C8
	POP DE
	POP AF
	DEC A
	JR M33F8

;Ausrechnen der Adresse eines 5-Byte-Bereichs im Calcu-
;latorspeicherbereich (MEM0 - MEM5)

M3406:	LD C,A
	RLCA
	RLCA
	ADD A,C
	LD C,A
	LD B,0
	ADD HL,BC
	RET

;Eine  Variable vom Calculatorspeicher in den Calc.-
;Stack holen als letzten Wert

M340F:	PUSH DE
	LD HL,(MEM)		;Zeiger auf Calculatorspeicher
	CALL M3406
	CALL VERDO
	POP HL
	RET

;Ablegen einer Konstanten auf dem Calc.-Stack
;(OP-CODES A0H - A4H)

M341B:	LD H,D
	LD L,E
	EXX
	PUSH HL
	LD HL,M32C5
	EXX
	CALL M33F7
	CALL M33C8
	EXX
	POP HL
	EXX
	RET

;Speichern des letzten Wertes in MEM0 - MEM5
;(OP-CODES C0H -C5H)

M342D:	PUSH HL
	EX DE,HL
	LD HL,(MEM)		;Zeiger auf Calculatorspeicher
	CALL M3406
	EX DE,HL
	CALL VERDO
	EX DE,HL
	POP HL
	RET

;Austauschen der beiden letzten Werte im Calc.-Stack

TAUSCH: LD B,5
M343E:	LD A,(DE)
	LD C,(HL)
	EX DE,HL
	LD (DE),A
	LD (HL),C
	INC HL
	INC DE
	DJNZ M343E
	EX DE,HL
	RET

;Generieren von Polynomen bei Funktionen wie SINUS,
;ATN etc. (OP-CODES 86H,88H,8CH = 3EH in Tabelle)

M3449:	LD B,A
	CALL M335E

;den letzten Wert 'Z' vorbereiten

	DEFB 31H
	DEFB 0FH
	DEFB 0C0H
	DEFB 2
	DEFB 0A0H
	DEFB 0C2H

;In der folgenden Schleife werden die Koeffizienten
;berechnet:
;B(M)=2*Z*B(M-1)-B(M-2)+C(M), wobei M=0....N.
;Die Konstanten C(M) stehen hinter dem jeweiligen
;Aufruf dieser Routine.

POLYS:	DEFB 31H
	DEFB 0E0H
	DEFB 4
	DEFB 0E2H
	DEFB 0C1H
	DEFB 3
	DEFB 38H

;naechste Konstante in den Calc.-Stack laden

	CALL M33C6
	CALL RECH2

	DEFB 0FH
	DEFB 1
	DEFB 0C2H
	DEFB 2
	DEFB 35H
	DEFB 0EEH
	DEFB 0E1H
	DEFB 3
	DEFB 38H

	RET

;die 'ABS(-OLUT)'-Funktion (OP-CODE 2AH)

ABSOLU: LD B,0FFH
	JR M3474

;Wechseln des Vorzeichens des letzten Wertes
;Negieren (OP-CODE 1BH)

NEGIER: CALL M34E9
	RET C
	LD B,0
M3474:	LD A,(HL)
	AND A
	JR Z,M3483
	INC HL
	LD A,B
	AND 80H
	OR (HL)
	RLA
	CCF
	RRA
	LD (HL),A
	DEC HL
	RET
;Vorzeichenwechsel bei Integerzahlen

M3483:	PUSH DE
	PUSH HL
	CALL M2D7F
	POP HL
	LD A,B
	OR C
	CPL
	LD C,A
	CALL M2D8E
	POP DE
	RET

;Auswerten des Vorzeichens:
;Negativ=-1, Positiv=+1, Null=0
;SIGN-Funktion (OP-CODE 29H)
;als letzten Wert speichern

M3492:	CALL M34E9
	RET C
	PUSH DE
	LD DE,1
	INC HL
	RL (HL)
	DEC HL
	SBC A,A
	LD C,A
	CALL M2D8E
	POP DE
	RET

;Befehl 'IN' (laden eines Ports, OP-CODE 2CH)

M34A5:	CALL M1E99
	IN A,(C)
	JR M34B0

;Befehl 'PEEK' (OP-CODE 2BH)

M34AC:	CALL M1E99
	LD A,(BC)
M34B0:	JP M2D28

;Befehl 'USR' mit Zahlen (OP-CODE 2DH)
;Im Maschinenprogramm duerfen alle Register ausser HL'
;benutzt werden. Wird HL' trotzdem gebraucht, muss vor
;dem Ende des Maschinenprogramms HL' mit 2758H geladen
;werden.

M34B3:	CALL M1E99
	LD HL,M2D2B
	PUSH HL
	PUSH BC
	RET

;Befehl 'USR A$' (OP-CODE 19H)

M34BC:	CALL M2BF1
	DEC BC
	LD A,B
	OR C
	JR NZ,M34E7
	LD A,(DE)
	CALL M2C8D
	JR C,M34D3
	SUB 90H
	JR C,M34E7
	CP 15H
	JR NC,M34E7
	INC A
M34D3:	DEC A
	ADD A,A
	ADD A,A
	ADD A,A
	CP 0A8H
	JR NC,M34E7
	LD BC,(UDG)		;Adresse der User Grafikzeichen
	ADD A,C
	LD C,A
	JR NC,M34E4
	INC B
M34E4:	JP M2D2B

M34E7:	RST ERRAUS
	DEFB 9			;'INVALID ARGUMENT'

;Test, ob eine Zahl Null ist

M34E9:	PUSH HL
	PUSH BC
	LD B,A
	LD A,(HL)
	INC HL
	OR (HL)
	INC HL
	OR (HL)
	INC HL
	OR (HL)
	LD A,B
	POP BC
	POP HL
	RET NZ
	SCF
	RET

;Test auf >0 (OP-CODE 37H)
;trifft dies zu, dann letzter Wert = 1
;		sonst = 0

M34F9:	CALL M34E9
	RET C
	LD A,0FFH
	JR M3507

;Funktion 'NOT' (OP-CODE 30H)
;letzter Wert wird 1, wenn letzter Wert Null
;war, sonst wird letzter Wert immer Null

M3501:	CALL M34E9
	JR M350B

;Funktion <0 (OP-CODE 36H)

M3506:	XOR A
M3507:	INC HL
	XOR (HL)
	DEC HL
	RLCA

;Speichern einer 0 (CARRY geloescht) oder
;einer 1 als letzten Wert

M350B:	PUSH HL
	LD A,0
	LD (HL),A
	INC HL
	LD (HL),A
	INC HL
	RLA
	LD (HL),A
	RRA
	INC HL
	LD (HL),A
	INC HL
	LD (HL),A
	POP HL
	RET

;Funktion 'OR' (OP-CODE 07)
;Das Ergebnis dieser Operation (X OR Y) ist X,
;wenn Y Null ist, andernfalls 1

M351B:	EX DE,HL
	CALL M34E9
	EX DE,HL
	RET C
	SCF
	JR M350B

;Funktion 'AND' (OP-CODE 08)
;Die Operation 'X AND Y' liefert X als Ergebnis,
;wenn Y<>0 ist, andernfalls den Wert 0

M3524:	EX DE,HL
	CALL M34E9
	EX DE,HL
	RET NC
	AND A
	JR M350B

;Funktion 'STRING AND ZAHL' (OP-CODE 10H)
;Das Ergebnis der Operation 'A$ AND X' ist A$, wenn
;X<>0 ist, sonst wird ein Nullstring uebergeben

M352D:	EX DE,HL
	CALL M34E9
	EX DE,HL
	RET NC
	PUSH DE
	DEC DE
	XOR A
	LD (DE),A
	DEC DE
	LD (DE),A
	POP DE
	RET

;Vergleichsoperationen (OP-CODE 09-0EH, 11H-16H)
;OP-CODE ist beim Einstieg in Reg B

M353B:	LD A,B
	SUB 8
	BIT 2,A
	JR NZ,M3543
	DEC A
M3543:	RRCA
	JR NC,M354E
	PUSH AF
	PUSH HL
	CALL TAUSCH
	POP DE
	EX DE,HL
	POP AF
M354E:	BIT 2,A
	JR NZ,M3559
	RRCA
	PUSH AF
	CALL SUBTRA
	JR M358C

;Stringoperationen

M3559:	RRCA
	PUSH AF
	CALL M2BF1
	PUSH DE
	PUSH BC
	CALL M2BF1
	POP HL
M3564:	LD A,H
	OR L
	EX (SP),HL
	LD A,B
	JR NZ,M3575
	OR C
M356B:	POP BC
	JR Z,M3572
	POP AF
	CCF
	JR M3588

M3572:	POP AF
	JR M3588

M3575:	OR C
	JR Z,M3585
	LD A,(DE)
	SUB (HL)
	JR C,M3585
	JR NZ,M356B
	DEC BC
	INC DE
	INC HL
	EX (SP),HL
	DEC HL
	JR M3564

M3585:	POP BC
	POP AF
	AND A
M3588:	PUSH AF
	RST CALRUF
	DEFB 0A0H
	DEFB 38H

M358C:	POP AF
	PUSH AF
	CALL C,M3501
	POP AF
	PUSH AF
	CALL NC,M34F9
	POP AF
	RRCA
	CALL NC,M3501
	RET

;Addieren von Strings (OP-CODE 17H)

M359C:	CALL M2BF1
	PUSH DE
	PUSH BC
	CALL M2BF1
	POP HL
	PUSH HL
	PUSH DE
	PUSH BC
	ADD HL,BC
	LD B,H
	LD C,L
	RST REST30
	CALL M2AB2
	POP BC
	POP HL
	LD A,B
	OR C
	JR Z,M35B7
	LDIR
M35B7:	POP BC
	POP HL
	LD A,B
	OR C
	JR Z,M35BF
	LDIR

;Setzen von DE auf STKEND und HL auf
;STKEND-5, d.h. 1. Byte des letzten Wertes im
;Calc.-Stack

M35BF:	LD HL,(STKEND)		;Anfang des freien Speichers
	LD DE,0FFFBH
	PUSH HL
	ADD HL,DE
	POP DE
	RET

;Funktion 'CHR$' (OP-CODE 2FH)

M35C9:	CALL M2DD5
	JR C,M35DC
	JR NZ,M35DC
	PUSH AF
	LD BC,1
	RST REST30
	POP AF
	LD (DE),A
	CALL M2AB2
	EX DE,HL
	RET

M35DC:	RST ERRAUS
	DEFB 0AH		;'INTEGER OUT OF RANGE'

;Funktion 'VAL' (OP-CODE 1DH) und 'VAL$' (18H)

M35DE:	LD HL,(CHADD)		;Adr. des naechsten zu interpret. Zeichens
	PUSH HL
	LD A,B
	ADD A,0E3H
	SBC A,A
	PUSH AF
	CALL M2BF1
	PUSH DE
	INC BC
	RST REST30
	POP HL
	LD (CHADD),DE		;Adr. des naechsten zu interpret. Zeichens
	PUSH DE
	LDIR
	EX DE,HL
	DEC HL
	LD (HL),0DH
	RES 7,(IY+1)
	CALL AUSDRU
	RST GETAKT
	CP 0DH
	JR NZ,M360C
	POP HL
	POP AF
	XOR (IY+1)
	AND 40H
M360C:	JP NZ,M1C8A
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	SET 7,(IY+1)
	CALL AUSDRU
	POP HL
	LD (CHADD),HL		;Adr. des naechsten zu interpret. Zeichens
	JR M35BF

;Funktion 'STR $' (OP-CODE 2EH)

M361F:	LD BC,1
	RST REST30
	LD (KCUR),HL		;Kursoradresse
	PUSH HL
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	PUSH HL
	LD A,0FFH
	CALL OPKAN
	CALL M2DE3
	POP HL
	CALL M1615
	POP DE
	LD HL,(KCUR)		;Kursoradresse
	AND A
	SBC HL,DE
	LD B,H
	LD C,L
	CALL M2AB2
	EX DE,HL
	RET

;Funktion 'READ-IN' (OP-CODE 1AH)

M3645:	CALL INTEG1
	CP 10H
	JP NC,M1E9F
	LD HL,(CURCHL)		;aktuelle I/O Infoadresse
	PUSH HL
	CALL OPKAN
	CALL M15E6
	LD BC,0
	JR NC,M365F
	INC C
	RST REST30
	LD (DE),A
M365F:	CALL M2AB2
	POP HL
	CALL M1615
	JP M35BF

;Funktion 'CODE' (OP-CODE 1CH)
;Ausgabe des ASCII-Wertes eines Zeichens

M3669:	CALL M2BF1
	LD A,B
	OR C
	JR Z,M3671
	LD A,(DE)
M3671:	JP M2D28


;Funktion 'LEN' (OP-CODE 1EH)

M3674:	CALL M2BF1
	JP M2D2B

;Vermindern von 'BREG' um 1, welches als Schleifen-
;zaehler dient, (Nachbildung von DJNZ) (OP-CODE 35H)

M367A:	EXX
	PUSH HL
	LD HL,BREG		;Calculator Hifsregister
	DEC (HL)
	POP HL
	JR NZ,M3687
	INC HL
	EXX
	RET

;Funktion 'JUMP' (OP-CODE 33H) zum ueberspringen
;von Calculator-OP-CODES

M3686:	EXX
M3687:	LD E,(HL)
	LD A,E
	RLA
	SBC A,A
	LD D,A
	ADD HL,DE
	EXX
	RET

;Ueberspringen von Calculatorbefehlen, wenn der
;letzte Wert <>0 ist (OP-CODE 00)

M368F:	INC DE
	INC DE
	LD A,(DE)
	DEC DE
	DEC DE
	AND A
	JR NZ,M3686
	EXX
	INC HL
	EXX
	RET

;Ende der Calculatoroperation

M369B:	POP AF
	EXX
	EX (SP),HL
	EXX
	RET


;Berechnen von N MOD M (OP-CODE 32H)
;Der ganzahlige Anteil INT (N/M) ergibt den
;letzten Wert, der Rest der Division den vor-
;letzten Wert.

M36A0:	RST CALRUF
	DEFB 0C0H
	DEFB 2
	DEFB 31H
	DEFB 0E0H
	DEFB 5
	DEFB 27H
	DEFB 0E0H
	DEFB 1
	DEFB 0C0H
	DEFB 4
	DEFB 3
	DEFB 0E0H
	DEFB 38H

	RET

;Funktion 'INTEGER' (OP-CODE 27H)

M36AF:	RST CALRUF
	DEFB 31H
	DEFB 36H
	DEFB 0
	DEFB INTINV-$
	DEFB 3AH
	DEFB 38H
	RET

INTINV: DEFB 31H
	DEFB 3AH
	DEFB 0C0H
	DEFB 3
	DEFB 0E0H
	DEFB 1
	DEFB 30H
	DEFB 0
	DEFB NEGINT-$
	DEFB 0A1H
	DEFB 3
NEGINT: DEFB 38H
	RET

;Funktion E^X (OP-CODE 26H, EXP)

M36C4:	RST CALRUF
	DEFB 3DH
	DEFB 34H
	DEFB 0F1H
	DEFB 38H
	DEFB 0AAH
	DEFB 3BH
	DEFB 29H
	DEFB 4
	DEFB 31H
	DEFB 27H
	DEFB 0C3H
	DEFB 3
	DEFB 31H
	DEFB 0FH
	DEFB 0A1H
	DEFB 3
	DEFB 88H

;es folgen 8 Konstanten

	DEFB 13H
	DEFB 36H
	DEFB 58H
	DEFB 65H
	DEFB 66H
	DEFB 9DH
	DEFB 78H
	DEFB 65H
	DEFB 40H
	DEFB 0A2H
	DEFB 60H
	DEFB 32H
	DEFB 0C9H
	DEFB 0E7H
	DEFB 21H
	DEFB 0F7H
	DEFB 0AFH
	DEFB 24H
	DEFB 0EBH
	DEFB 2FH
	DEFB 0B0H
	DEFB 0B0H
	DEFB 14H
	DEFB 0EEH
	DEFB 07EH
	DEFB 0BBH
	DEFB 94H
	DEFB 58H
	DEFB 0F1H
	DEFB 3AH
	DEFB 7EH
	DEFB 0F8H
	DEFB 0CFH
	DEFB 0E3H
	DEFB 38H

	CALL M2DD5
	JR NZ,M3705
	JR C,M3703
	ADD A,(HL)
	JR NC,M370C

M3703:	RST ERRAUS
	DEFB 5			;'NUMBER TOO BIG'

M3705:	JR C,M370E
	SUB (HL)
	JR NC,M370E
	NEG
M370C:	LD (HL),A
	RET

M370E:	RST CALRUF
	DEFB 2
	DEFB 0A0H
	DEFB 38H
	RET

;Funktion 'LN (X)' (OP-CODE 25H)
;X wird bei LN(X) auf 2 Arten berechnet. Die Unter-
;scheidung wird daran getroffen, ob X<.8 oder >.8
;ist, nachdem X in den Bereich von .5<=X<1 gebracht
;wurde.

M3713:	RST CALRUF
	DEFB 3DH
	DEFB 31H
	DEFB 37H
	DEFB 0
	DEFB LNPOS-$
	DEFB 38H

	RST ERRAUS
	DEFB 9			;'INVALID ARGUMENT'

LNPOS:	DEFB 0A0H
	DEFB 2
	DEFB 38H

	LD A,(HL)
	LD (HL),80H
	CALL M2D28
	RST CALRUF
	DEFB 34H
	DEFB 38H
	DEFB 0
	DEFB 3
	DEFB 1
	DEFB 31H
	DEFB 34H
	DEFB 0F0H
	DEFB 4CH
	DEFB 0CCH
	DEFB 0CCH
	DEFB 0CDH
	DEFB 3
	DEFB 37H
	DEFB 0
	DEFB GROSS8-$
	DEFB 1
	DEFB 0A1H
	DEFB 3
	DEFB 1
	DEFB 38H

	INC (HL)
	RST CALRUF
GROSS8: LD BC,0F034H		;ab hier nur OP-CODES
	LD SP,1772H
	RET M
	INC B
	LD BC,3A2H
	AND D
	INC BC
	LD SP,3234H
	JR NZ,6+$		;3753H
	AND D
	INC BC
	ADC A,H
	LD DE,14ACH
	ADD HL,BC
	LD D,(HL)
	JP C,59A5H
	JR NC,-39H+$		;3721H
	LD E,H
	SUB B
	XOR D
	SBC A,(HL)
	LD (HL),B
	LD L,A
	LD H,C
	AND C
	SET 3,D
	SUB (HL)
	AND H
	LD SP,0B49FH
	RST GETNXT
	AND B
	CP 5CH
	CALL M,1BEAH
	LD B,E
	JP Z,0ED36H
	AND A
	SBC A,H
	LD A,(HL)
	LD E,(HL)
	RET P
	LD L,(HL)
	INC HL
	ADD A,B
	SUB E
	INC B
	RRCA
	DEFB 38H		;Ende der OP-CODES
	RET

;Reduzieren des Arguments bei SINUS und COSINUS
;in den Bereich -.5 <=V<.5

M3783:	RST CALRUF
	DEC A			;ab hier nur OP-CODES
	INC (HL)
	XOR 22H
	LD SP,HL
	ADD A,E
	LD L,(HL)
	INC B
	LD SP,0FA2H
	DAA
	INC BC
	LD SP,310FH
	RRCA
	LD SP,0A12AH
	INC BC
	LD SP,0C037H
	NOP
	INC B
	LD (BC),A
	DEFB 38H		;Ende der OP-CODES
	RET

ZPOSI:	AND C			;ab hier nur OP-CODES
	INC BC
	LD BC,036H
	LD (BC),A
	DEC DE
YNEGAT: DEFB 38H		;Ende der OP-CODES
	RET

;Funktion COSINUS (OP-CODE 20H)

M37AA:	RST CALRUF
	ADD HL,SP		;ab hier nur OP-CODES
	LD HL,(3A1H)
	RET PO
	NOP
	LD B,1BH
	INC SP
	INC BC

;Berechnen SINUS (OP-CODE 1FH)

M37B5:	RST CALRUF
	ADD HL,SP		;immer noch OP-CODES
SINCOS: LD SP,431H
	LD SP,0A10FH
	INC BC
	ADD A,(HL)
	INC D
	AND 5CH
	RRA
	DEC BC
	AND E
	ADC A,A
	JR C,-10H+$
	JP (HL)
	DEC D
	LD H,E
	CP E
	INC HL
	XOR 92H
	DEC C
	CALL 0F1EDH
	INC HL
	LD E,L
	DEC DE
	JP PE,3804H
	RET			;Ende des OP-CODES

;Berechnung TANGENS (OP-CODE 21H)

M37DA:	RST CALRUF
	LD SP,11FH		;ab hier nur OP-CODES
	JR NZ,7+$
	DEFB 38H		;Ende der OP-CODES
	RET

;Berechnung ARCUSTANGENS (OP-CODE 24H)

;Unterteilung in 3 Faelle:
;fuer -1<X<1:	W=0,  Y=0
;fuer 1<=X: W=PI/2,  Y=-1/X
;fuer X<=-1:	W=-PI/2,Y=-1/X

M37E2:	CALL M3297
	LD A,(HL)
	CP 81H
	JR C,TANGE1
	RST CALRUF
	AND C			;ab hier nur OP-CODES
	DEC DE
	LD BC,3105H
	LD (HL),0A3H
	LD BC,600H
	DEC DE
	INC SP
	INC BC

TANGE1: RST CALRUF
	AND B			;immer noch OP-CODES
TANGE2: LD BC,3131H
	INC B
	LD SP,0A10FH
	INC BC
	ADC A,H
	DJNZ -4CH+$
	INC DE
	LD C,55H
	CALL PO,588DH
	ADD HL,SP
	CP H
	LD E,E
	SBC A,B
	SBC A,(IY+0)
	LD (HL),75H
	AND B
	IN A,(0E8H)
	OR H
	LD H,E
	LD B,D
	CALL NZ,0B5E6H
	ADD HL,BC
	LD (HL),0BEH
	JP (HL)
	LD (HL),73H
	DEC DE
	LD E,L
	CALL PE,0DED8H
	LD H,E
	CP (HL)
	RET P
	LD H,C
	AND C
	OR E
	INC C
	INC B
	RRCA
	DEFB 38H		;Ende der OP-CODES
	RET

;Funktion ARCUSSINUS (OP-CODE 22H)

M3833:	RST CALRUF
	LD SP,431H		;ab hier nur OP-CODES
	AND C
	INC BC
	DEC DE
	JR Z,-5DH+$
	RRCA
	DEC B
	INC H
	LD SP,380FH
	RET			;Ende des OP-CODES

;Funktion ARCUSCOSINUS (OP-CODE 23H)

M3843:	RST CALRUF
	LD (3A3H),HL		;ab hier nur OP-CODES
	DEC DE
	DEFB 38H		;Ende der OP-CODES
	RET

;Berechnen der Quadratwurzel (OP-CODE 28H)

M384A:	RST CALRUF
	LD SP,030H		;ab hier nur OP-CODES
	LD E,0A2H
	DEFB 38H		;Ende der OP-CODES

;Berechnung von X^Y (OP-CODE 06)

M3851:	RST CALRUF
	LD BC,3031H		;ab hier nur OP-CODES
	NOP
	RLCA
	DEC H
	INC B
	DEFB 38H		;Ende der OP-CODES
	JP M36C4

XNULL:	DEFB 2			;ab hier nur OP-CODE
	LD SP,030H
	ADD HL,BC
	AND B
	LD BC,037H
	LD B,0A1H
	DEFB 1
	DEFB 5
EINSSP: DEFB 2
	AND C
LETZWE: DEFB 38H		;Ende der OP-CODES
	RET

;================================================

; es folgen bis Adr. 3CFF nur 'FF's. Danach liegt der Zeichensatz

	DEFS	$3D00-$

;==================================================

CHARR0:	DEFM	$00000000000000000010101010001000
	DEFM	$002424000000000000247E24247E2400
	DEFM	$00083E283E0A3E080062640810264600
	DEFM	$001028102A443A000008100000000000
	DEFM	$00040808080804000020101010102000
	DEFM	$000014083E081400000008083E080800
	DEFM	$0000000000080810000000003E000000
	DEFM	$00000000001818000000020408102000
	DEFM	$003C464A52623C000018280808083E00
	DEFM	$003C42023C407E00003C420C02423C00
	DEFM	$00081828487E0800007E407C02423C00
	DEFM	$003C407C42423C00007E020408101000
	DEFM	$003C423C42423C00003C42423E023C00
	DEFM	$00000010000010000000100000101020
	DEFM	$00000408100804000000003E003E0000
	DEFM	$0000100804081000003C420408000800
	DEFM	$003C4A565E403C00003C42427E424200
	DEFM	$007C427C42427C00003C424040423C00
	DEFM	$0078444242447800007E407C40407E00
	DEFM	$007E407C40404000003C42404E423C00
	DEFM	$0042427E42424200003E080808083E00
	DEFM	$0002020242423C000044487048444200
	DEFM	$0040404040407E000042665A42424200
	DEFM	$004262524A464200003C424242423C00
	DEFM	$007C42427C404000003C4242524A3C00
	DEFM	$007C42427C444200003C403C02423C00
	DEFM	$00FE1010101010000042424242423C00
	DEFM	$004242424224180000424242425A2400
	DEFM	$00422418182442000082442810101000
	DEFM	$007E040810207E00000E080808080E00
	DEFM	$00004020100804000070101010107000
	DEFM	$001038541010100000000000000000FF
	DEFM	$001C227820207E00000038043C443C00
	DEFM	$0020203C22223C0000001C2020201C00
	DEFM	$0004043C44443C000000384478403C00
	DEFM	$000C10181010100000003C44443C0438
	DEFM	$00404078444444000010003010103800
	DEFM	$00040004040424180020283030282400
	DEFM	$0010101010100C000000685454545400
	DEFM	$00007844444444000000384444443800
	DEFM	$000078444478404000003C44443C0406
	DEFM	$00001C20202020000000384038047800
	DEFM	$0010381010100C000000444444443800
	DEFM	$00004444282810000000445454542800
	DEFM	$000044281028440000004444443C0438
	DEFM	$00007C0810207C00000E083008080E00
	DEFM	$00080808080808000070100C10107000
	DEFM	$00142800000000003C4299A1A199423C

; ====================================================




;#end



