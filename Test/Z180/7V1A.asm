#!/usr/local/bin/zasm -o original/


; zasm: test silent fallback to 8-bit encoding
; this file seems to use DOS / CP437 encoding


;8LAD Version 7.1 vom 22.Dez.2013
;ladeabschaltung von 4 auf 3 mV ge„ndert
;I/O TEST erweitert
;NMI erweitert Print hinzugefgt
;entladestrom = 240 mA   ladestrom =600 mA /500mA effektiv (pulse-pause)
;und entladestrom = 120 mA   ladestrom =300 mA /250mA effektiv (Switch)

;geaendert messen jezt in der ladepause
;ladelimit = 10stunden eingebaut

;eprom adr. 0000 - 1fffh und 4000 - 5fffh
;ram   adr. 2000h - 3fffh Batterie gepuffert
;uhr   adr. 6000h - 600fh ;wird nur als taktgeber (1min)
;verwendet die zeiten werden ueber nmi/ z80 software maeáig
;ermittelt

;I/O ARESSEN

;adr 18h-1bh =CS6\analog in ADC7002/1
;adr 0-3 =CS0\analog in ADC7002/2
;adc einstellung 2Volt = 4000 digit  (aufl”sung 0.5 mV pro digit)

;adr 4-7 =SIO CS1\
;adr 8-17h = display CS2/CS3/CS4/CS5
;adr 1ch-1fh =8255 CS7 (1c=portA 1d=portB 1e=portC 1f=steuerwort
;port b = leeren  port c =laden  port a =ZN428 (DAC)

;adr 0ch=Tasten   ;z1-z8
;adr 0bh=Tasten   ;enter + - und schalter laden high low

;display links adr 17H  rechts 8
znport          equ     1ch
leerport        equ     1dh
ladeport        equ     1eh

stack           equ     3fffh
leerbyte        equ     2000h ;port B freigabe leeren adr.1dh
ladebyte        equ     2001h ;port C freigabe laden adr.1eh
tastbuf         equ     2002h ;tastenbuffer
hexbuf          equ     2004h  ;enthaelt ergebnis von dezhex
bufhex          equ     2006h  ;buffer fuer hexdez
bufdez          equ     2008h  ;ergebniss von hexdez
adr1            equ     200ch   ;fuer analog10
adr2            equ     200eh   ; '
adr3            equ     2010h   ; '
uhrbuf          equ     2014h   ;zeit im minuten in hex
zell1le         equ     2016h   ;zeit leeren zelle 1 "
zell2le         equ     2018h   ;zeit leeren zelle 2 "
zell3le         equ     201ah   ;zeit leeren zelle 3 "
zell4le         equ     201ch   ;zeit leeren zelle 4 "
zell5le         equ     201eh   ;zeit leeren zelle 5 "
zell6le         equ     2020h   ;zeit leeren zelle 6 "
zell7le         equ     2022h   ;zeit leeren zelle 7 "
zell8le         equ     2024h   ;zeit leeren zelle 8 "

zell1la         equ     2026h   ;zeit laden zelle 1 hex
zell2la         equ     2028h   ;zeit laden zelle 2  "
zell3la         equ     202ah   ;zeit laden zelle 3  "
zell4la         equ     202ch   ;zeit laden zelle 4  "
zell5la         equ     202eh   ;zeit laden zelle 5  "
zell6la         equ     2030h   ;zeit laden zelle 6  "
zell7la         equ     2032h   ;zeit laden zelle 7  "
zell8la         equ     2034h   ;zeit laden zelle 8  "

deltaz1         equ     2036h   ;delta u zelle 1  hex
deltaz2         equ     2038h   ;delta u zelle 2   "
deltaz3         equ     203ah   ;delta u zelle 3   "
deltaz4         equ     203ch   ;delta u zelle 4   "
deltaz5         equ     203eh   ;delta u zelle 5   "
deltaz6         equ     2040h   ;delta u zelle 6   "
deltaz7         equ     2042h   ;delta u zelle 7   "
deltaz8         equ     2044h   ;delta u zelle 8   "
minuten         equ     2046h   ;zwischen speicher fuer mAh
milliamp        equ     2048h   ;  "       "             "
progmerk        equ     204ah   ;programmwahl merker(2=nur refresh 1=le+la)
adcmerk         equ     204ch   ;merker fuer adc1+2
ula1            equ     204eh   ;aktuelle spannung an z1 (laden)
ula2            equ     2050h   ;aktuelle spannung an z2 (laden)
ula3            equ     2052h   ;aktuelle spannung an z3 (laden)
ula4            equ     2054h   ;aktuelle spannung an z4 (laden)
ula5            equ     2056h   ;aktuelle spannung an z5 (laden)
ula6            equ     2058h   ;aktuelle spannung an z6 (laden)
ula7            equ     205ah   ;aktuelle spannung an z7 (laden)
ula8            equ     205ch   ;aktuelle spannung an z8 (laden)
limit           equ     2060h   ;notaus nach 10Std.laden
                ;enth„lt bei 10 std. 55h
ule1            equ     2062h   ;aktuelle spannung an z1 (leeren)
ule2            equ     2064h   ;aktuelle spannung an z2 (leeren)
ule3            equ     2066h   ;aktuelle spannung an z3 (leeren)
ule4            equ     2068h   ;aktuelle spannung an z4 (leeren)
ule5            equ     206ah   ;aktuelle spannung an z5 (leeren)
ule6            equ     206ch   ;aktuelle spannung an z6 (leeren)
ule7            equ     206eh   ;aktuelle spannung an z7 (leeren)
ule8            equ     2070h   ;aktuelle spannung an z8 (leeren)
lestrom         equ     2080h   ;werte fr ZN428  wird von Switch gesetzt
lastrom         equ     2082h   ;werte fr ZN428  wird von Switch gesetzt
mahle           equ     2084h   ;mAh/10   wird von Switch gesetzt
mahla           equ     2086h   ;mAh/10   wird von Switch gesetzt
outstrom        equ     2090h   ;orginal strom wird von Switch gesetzt
instrom         equ     2092h   ;orginal strom wird von Switch gesetzt
textbuf         equ     2500h   ;puffer fr variablen text

        org 00h
        nop
        nop
        nop
        nop
        jp 100h

        org 0ah
uhr0    ld hl,uhrtab    ;uhrzeit =000000
        ld de,6000h     ;adresse uhr
        ld bc,10h
       	ldir
        ld a,6
        ld (600fh),a
	ret
uhrstart nop
        ld a,4
        ld (600fh),a
        ret
uhrstop nop                            ;0 64 Htz
        ld a,6                         ;  Std
        ld (600fh),a                   ;4 Sek
        ret                            ;8 Min
uhrtab  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6
;                                        4 start
;                                        6 stop

siotab  db 18h,4,4ch,5,68h,3,0c1h,1,0
initsio ld b,9
	ld c,7
	ld hl,siotab
	otir
	ret

        org 66h
        jp nmi     ;Minuten Zaehler


        org 0a0h
;Z80 sio b
rxb     in a,(7)        ;warte auf zeichen
	bit 0,a
	jp z,rxb
	in a,(5)

	cp 5ah          ;kleinbuchstaben in grosse wandeln
	jp nc,klgr
	ret
klgr    sub 20h
	ret


send    push af       ;zeichen senden
status  in a,(7)
	bit 2,a
        jp z,status
	pop af
	out (5),a
	ret
;text senden   in hl muss text adresse bergeben werden
sendtxt ld a,(hl)
	cp '$'
	ret z
	push af
sd1     in a,(7)
	bit 2,a
	jp z,sd1
	pop af
	out (5),a
	inc hl
	jp sendtxt

        org 100h

start   nop
        ld sp,stack
        call initp1   ;init 8255 alles ausg„nge
        call uhr0
        call initsio  ;
;************************************

        ld a,0
        out (znport),a
        call cls
        call crlf
        ld hl,tx20
        call sendtxt
         call zapp
         call switch
        ld hl,textp   ;programmwahl mit +
        call tdisp

pro     call tasten
        cp '1'        ;TASTE Z1  = MONITOR aufrufen
        jp z,4000h    ;MONITOR
        cp '+'
        jp z,prog1
        jp pro

prog1   call switch

        ld hl,tx1     ;leeren+laden
        call tdisp
pro1    call tasten
        cp '+'
        jp z,prog2
        cp '-'
        jp z,prog5
        cp 0dh       ;enter
        jp z,lela
        jp pro1
prog2   ld a,(mahla)
        cp 25
        jp z,mt1
        ld hl,tx2  ;pulsladen 600mA
        jp mt2
        jp mah2    ;pulsladen 300mA
mt1     ld hl,tx2a    ;nur laden
mt2     call tdisp
pro2    call tasten
        cp '+'
        jp z,prog3
        cp '-'
        jp z,prog1
        cp 0dh
        jp z,nurla
        jp pro2
prog3   ld a,(mahle)
        cp 12
        jp z,og1
        ld hl,tx3  ; leeren  240 mAh
        jp og2
og1     ld hl,tx3a ;leeren 120 mAh
og2     call tdisp
pro3    call tasten
        cp '+'
        jp z,prog4
        cp '-'
        jp z,prog2
        cp 0dh
        jp z,nurle
        jp pro3

;************************************
prog4   ld hl,tx8  ; 8 MIN.NURREFRESH
        call tdisp
pro4    call tasten
        cp '+'
        jp z,prog5
        cp '-'
        jp z,prog3
        cp 0dh
        jp z,pro4a
        jp pro4
pro4a   ld a,2         ;progmerk  nur refresh
        ld (progmerk),a
        call refresh
        jp start
        ;*************************************
prog5   ld hl,tx9  ;I/O TEST
        call tdisp
pro5    call tasten
        cp '+'
        jp z,prog1
        cp '-'
        jp z,prog4
        cp 0dh
        jp z,test
        jp pro5

;leeren + laden
lela    ld a,1
        ld (progmerk),a   ;bewirkt dass nach leeren
        ld hl,tx1         ;zu laden gesprungen wird
        call tdisp
        ld hl,0000
        ld (uhrbuf),hl
        jp nurle1

;************************************
;nur laden
nurla   ld a,(mahla)
        cp 25
        jp z,mah1
        ld hl,tx2  ;pulsladen 600mA
        jp mah2    ;pulsladen 300mA
mah1    ld hl,tx2a
mah2    call tdisp
        ld hl,0000
        ld (uhrbuf),hl
        ld a,0ffh
        ld (ladebyte),a ;z1-z8 einschalten
        out (ladeport),a  ;laden alle 8 ein
        ld a,(lastrom)
        out (znport),a  ;zn428
        ld a,18h ;adc1
        ld (adcmerk),a
        ld a,0          ;prfen ob Akku vorhanden Z1-Z8
        call analog10   ;wenn nicht Zelle abschalten
        ld de,0fffh     ;und speichern
        and a
        sbc hl,de
        jp c,aus1
        ld a,(ladebyte)
        res 0,a            ;Z1
        ld (ladebyte),a

        out (ladeport),a
aus1    ld a,1             ;Z2
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus2
        ld a,(ladebyte)
        res 1,a
        ld (ladebyte),a
        out (ladeport),a

aus2    ld a,2           ;Z3
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus3
        ld a,(ladebyte)
        res 2,a
        ld (ladebyte),a
        out (ladeport),a
aus3    ld a,3           ;Z4
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus4
        ld a,(ladebyte)
        res 3,a
        ld (ladebyte),a
        out (ladeport),a
aus4    ld a,0           ;adc2
        ld (adcmerk),a
        ld a,0           ;Z5
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus5
        ld a,(ladebyte)
        res 4,a
        ld (ladebyte),a
        out (ladeport),a

aus5    ld a,1          ;Z6
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus6
        ld a,(ladebyte)
        res 5,a
        ld (ladebyte),a
        out (ladeport),a

aus6    ld a,2          ;Z7
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus7
        ld a,(ladebyte)
        res 6,a
        ld (ladebyte),a
        out (ladeport),a

aus7    ld a,3         ;Z8
        call analog10
        ld de,0fffh
        and a
        sbc hl,de
        jp c,aus8
        ld a,(ladebyte)
        res 7,a
        ld (ladebyte),a
        out (ladeport),a

aus8    ld a,(ladebyte)   ;alle aus?
        cp 0
        jp z,ladend       ;laden ende
        ld a,18h      ;adc1
        ld (adcmerk),a
        call uhrstart
min2    call key1         ;Terminal (PC) abfragen
        cp 'P'            ;send šbersicht
        call z,print
        cp 'E'            ;send leeren werte Z1-Z8
        call z,leprint
        cp 'R'
        jp z,0000

        call puls
        ld hl,(uhrbuf)   ;2minuten warten
        ld a,l           ;da bei manchen akkus zu beginn U erst
        cp 2             ;hochgeht & dann wieder runter
        jp nz,min2

wela    ld a,(limit)     ;ist maximale ladezeit erreicht
        cp 55h           ;abschalten
        jp z,ladend
        call key1        ;terminal PC
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

         call zeiga8     ;wert Z8
        ld a,0          ;z1 messen
        call analog0
        ld de,(deltaz1)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next1
        jp next1a       ;sonst weiter
next1   pop hl
        ld (deltaz1),hl
        jp next1b
next1a  pop hl
next1b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 0,a
        jp z,next1c
        ld (ula1),hl
next1c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz1) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit1
        ld a,(ladebyte)
        bit 0,a
        jp z,za2m
        ld hl,(uhrbuf)
        ld (zell1la),hl

;**********************
za2m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga1     ;lade mAh anzeigen
        ld a,1          ;z2 messen
        call analog0
        ld de,(deltaz2)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next2
        jp next2a       ;sonst weiter
next2   pop hl
        ld (deltaz2),hl
        jp next2b
next2a  pop hl
next2b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 1,a
        jp z,next2c

        ld (ula2),hl
next2c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz2) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit2
        ld a,(ladebyte)
        bit 1,a
        jp z,za3m
        ld hl,(uhrbuf)
        ld (zell2la),hl

;*********************************
za3m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga2     ;lade mAh anzeigen
        ld a,2
        call analog0
        ld de,(deltaz3)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next3
        jp next3a       ;sonst weiter
next3   pop hl
        ld (deltaz3),hl
        jp next3b
next3a  pop hl
next3b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 2,a
        jp z,next3c

        ld (ula3),hl
next3c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz3) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit3
        ld a,(ladebyte)
        bit 2,a
        jp z,za4m
        ld hl,(uhrbuf)
        ld (zell3la),hl

;**************************
za4m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga3    ;lade mAh anzeigen
        ld a,3
        call analog0
        ld de,(deltaz4)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next4
        jp next4a       ;sonst weiter
next4   pop hl
        ld (deltaz4),hl
        jp next4b
next4a  pop hl
next4b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 3,a
        jp z,next4c

        ld (ula4),hl
next4c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz4) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit4
        ld a,0
        ld (adcmerk),a ;adc2
        ld a,(ladebyte)
        bit 3,a
        jp z,za5m
        ld hl,(uhrbuf)
        ld (zell4la),hl

;*****************************
za5m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga4    ;lade mAh anzeigen
        ld a,0
        call analog0
        ld de,(deltaz5)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next5
        jp next5a       ;sonst weiter
next5   pop hl
        ld (deltaz5),hl
        jp next5b
next5a  pop hl
next5b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 4,a
        jp z,next5c

        ld (ula5),hl
next5c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz5) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit5
        ld a,(ladebyte)
        bit 4,a
        jp z,za6m
        ld hl,(uhrbuf)
        ld (zell5la),hl

;*******************************
za6m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga5    ;lade mAh anzeigen
        ld a,1
        call analog0
        ld de,(deltaz6)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next6
        jp next6a       ;sonst weiter
next6   pop hl
        ld (deltaz6),hl
        jp next6b
next6a  pop hl
next6b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 5,a
        jp z,next6c

        ld (ula6),hl
next6c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz6) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit6
        ld a,(ladebyte)
        bit 5,a
        jp z,za7m
        ld hl,(uhrbuf)
        ld (zell6la),hl

;****************************
za7m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga6   ;lade mAh anzeigen
        ld a,2
        call analog0
        ld de,(deltaz7)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next7
        jp next7a       ;sonst weiter
next7   pop hl
        ld (deltaz7),hl
        jp next7b
next7a  pop hl
next7b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 6,a
        jp z,next7c

        ld (ula7),hl
next7c  and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz7) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit7
        ld a,(ladebyte)
        bit 6,a
        jp z,za8m
        ld hl,(uhrbuf)
        ld (zell7la),hl

;******************************
za8m    call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        call zeiga7   ;lade mAh anzeigen
        ld a,3
        call analog0
        ld de,(deltaz8)
        and a
        push hl
        sbc hl,de       ;ist hl >delta u hl in deltaz1 speichern
        jp nc,next8
        jp next8a       ;sonst weiter
next8   pop hl
        ld (deltaz8),hl
        jp next8b
next8a  pop hl
next8b  ld de,6  ;3mV
        ld a,(ladebyte)
        bit 7,a
        jp z,next8c

        ld (ula8),hl
next8c   and a
        adc hl,de       ;3mV zum messwert addieren
        ld de,(deltaz8) ;mit delta u vergleichen
        and a
        sbc hl,de       ;wenn hl<de laden ende
        call c,labit8
        ld a,18h
        ld (adcmerk),a ;adc1
        ld a,(ladebyte)
        cp 0
        jp z,ladend
        bit 7,a
        jp z,zam0
        ld hl,(uhrbuf)
        ld (zell8la),hl

zam0    jp wela      ;weiter laden
ladend  ld a,0
        out (ladeport),a
         ld hl,tx6
        call tdisp
        jp ladeend

;************************************
labit1  ld a,(ladebyte)      ;zelle abschalten werte speichern
        bit 0,a
        jp z,lab1
        res 0,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell1la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lab1    ret

labit2  ld a,(ladebyte)    ;zelle abschalten werte speichern
        bit 1,a
        jp z,lab2
        res 1,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell2la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lab2    ret

labit3  ld a,(ladebyte)    ;zelle abschalten werte speichern
        bit 2,a
        jp z,lab3
        res 2,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell3la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lab3    ret

labit4  ld a,(ladebyte)   ;zelle abschalten werte speichern
        bit 3,a
        jp z,lab4
        res 3,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell4la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lab4    ret

labit5  ld a,(ladebyte)   ;zelle abschalten werte speichern
        bit 4,a
       jp z,lb5
        res 4,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell5la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lb5     ret

labit6  ld a,(ladebyte)   ;zelle abschalten werte speichern
        bit 5,a
        jp z,lb6
        res 5,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell6la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lb6     ret

labit7  ld a,(ladebyte)   ;zelle abschalten werte speichern
        bit 6,a
        jp z,lb7
        res 6,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell7la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lb7     ret

labit8  ld a,(ladebyte)   ;zelle abschalten werte speichern
        bit 7,a
       jp z,lb8
        res 7,a
        out (ladeport),a
        ld (ladebyte),a
        ld hl,(uhrbuf)
        ld (zell8la),hl
        call longlop
        call longlop
        call longlop
        call longlop
lb8     ret

puls    ld a,0           ;aus ein 1zu2
        out (ladeport),a
        call longlop
        call lauflop       ;laufzeit ausgleich von analog
        ld a,(ladebyte)
        out (ladeport),a
        call longlop
        call longlop
                ret
;************************************
;nur leeren

nurle   nop
nurle1  ld hl,0000
        ld (uhrbuf),hl
        ld a,0ffh
        ld (leerbyte),a ;z1-z8 einschalten
        out (leerport),a  ;entladen alle 8 ein
        call uhrstart
        ld a,(lestrom)
        out (znport),a
wele    call key1        ;weiter leeren
        cp 'P'
        call z,print     ;šbersicht senden
        cp 'E'           ;leeren werte senden
        call z,leprint
        cp 'R'
        jp z,0000

        ld a,18h         ;Adresse ADC1
        ld (adcmerk),a  ;adc1
        call zeige8
        call longlop
        ld a,(leerbyte)
        bit 0,a
        jp z,z2m
        ld a,0          ;z1 messen
        call analog10
        ld (ule1),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit1   ;wenn z1 0,9 volt
        ld hl,(uhrbuf)
        ld (zell1le),hl

z2m     call zeige1
        ld a,1          ;z2 messen
        call analog10
        ld a,(leerbyte)
        bit 1,a
        jp z,z3m

        ld (ule2),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit2
        ld hl,(uhrbuf)
        ld (zell2le),hl

z3m     call zeige2     ;z2
        ld a,2
        call analog10   ;z3 messen
        ld a,(leerbyte)
        bit 2,a
        jp z,z4m

        ld (ule3),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit3
        ld hl,(uhrbuf)
        ld (zell3le),hl

z4m     call zeige3      ;z3
        ld a,3
        call analog10    ;z4 messen
        ld a,(leerbyte)
        bit 3,a
        jp z,z5m

        ld (ule4),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit4
        ld hl,(uhrbuf)
        ld (zell4le),hl

z5m     call zeige4     ;z4
        ld a,0          ;Adresse ADC2
        ld (adcmerk),a  ;adc2

        call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        ld a,0           ;z5 messen
        call analog10
        ld a,(leerbyte)
        bit 4,a
        jp z,z6m

        ld (ule5),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit5
        ld hl,(uhrbuf)
        ld (zell5le),hl


z6m     call zeige5
        call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        ld a,1           ;z6 messen
        call analog10
        ld a,(leerbyte)
        bit 5,a
        jp z,z7m

        ld (ule6),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit6
        ld hl,(uhrbuf)
        ld (zell6le),hl

z7m     call zeige6
        call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        ld a,2           ;z7 messen
        call analog10
        ld a,(leerbyte)
        bit 6,a
        jp z,z8m

        ld (ule7),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit7
        ld hl,(uhrbuf)
        ld (zell7le),hl

z8m     call zeige7
        ld a,3           ;z8 messen
        call analog10
        ld a,(leerbyte)
         bit 7,a
        jp z,z8ma

        ld (ule8),hl
        and a
        ld de,1800       ;900 mV
        sbc hl,de
        call c,lebit8
        ld hl,(uhrbuf)
        ld (zell8le),hl

z8ma    call lloop
        ld a,(leerbyte)
        cp 0
        jp z,leerend    ;z1-z8 = leer

        jp wele
leerend call uhr0
        ld a,(progmerk)
        cp 1
        jp z,nurla
lend    ld hl,tx6
        call tdisp
leerende call tasten
        cp '1'
        call z,zeige1
        cp '2'
        call z,zeige2
        cp '3'
        call z,zeige3
        cp '4'
        call z,zeige4
        cp '5'
        call z,zeige5
        cp '6'
        call z,zeige6
        cp '7'
        call z,zeige7
        cp '8'
        call z,zeige8
        cp '+'
        jp z,ladeend
        cp '-'
        jp z,ladeend
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000
        jp leerende

;entladene mAh anzeigen

zeige1  push af
        ld hl,tx4       ; 'LEER Z       MAH'
        call tdisp
        ld a,'1'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell1le)
        ld (minuten),de
        call mah         ;mAh brechnen
        call dezdisp     ;+ anzeigen
        pop af
        ret
zeige2  push af
        ld hl,tx4
        call tdisp
        ld a,'2'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell2le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeige3  push af
        ld hl,tx4
        call tdisp
        ld a,'3'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell3le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret

zeige4  push af
        ld hl,tx4
        call tdisp
        ld a,'4'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell4le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret

zeige5  push af
        ld hl,tx4
        call tdisp
        ld a,'5'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell5le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret

zeige6  push af
        ld hl,tx4
        call tdisp
        ld a,'6'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell6le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret

zeige7  push af
        ld hl,tx4
        call tdisp
        ld a,'7'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell7le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret

zeige8  push af
        ld hl,tx4
        call tdisp
        ld a,'8'
        out (11h),a
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell8le)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret


;lade mAh anzeigen

zeiga1  push af
        ld hl,tx5       ; 'LADE Z       MAH'
        call tdisp
        ld a,'1'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig
        ld (milliamp),de
        ld de,(zell1la)
        ld (minuten),de
        call mah         ;mAh brechnen
        call dezdisp     ;+ anzeigen
        pop af
        ret
zeiga2  push af
        ld hl,tx5
        call tdisp
        ld a,'2'
        out (11h),a

        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell2la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga3  push af
        ld hl,tx5
        call tdisp
        ld a,'3'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell3la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga4  push af
        ld hl,tx5
        call tdisp
        ld a,'4'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell4la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga5  push af
        ld hl,tx5
        call tdisp
        ld a,'5'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell5la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga6  push af
        ld hl,tx5
        call tdisp
        ld a,'6'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell6la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga7  push af
        ld hl,tx5
        call tdisp
        ld a,'7'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell7la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret
zeiga8  push af
        ld hl,tx5
        call tdisp
        ld a,'8'
        out (11h),a
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell8la)
        ld (minuten),de
        call mah
        call dezdisp
        pop af
        ret



ladeend call uhr0
        call tasten
        cp '1'
        call z,zeiga1
        cp '2'
        call z,zeiga2
        cp '3'
        call z,zeiga3
        cp '4'
        call z,zeiga4
        cp '5'
        call z,zeiga5
        cp '6'
        call z,zeiga6
        cp '7'
        call z,zeiga7
        cp '8'
        call z,zeiga8
        cp '+'
        jp z,leerende
        cp '-'
        jp z,leerende
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        jp ladeend

lebit1  ld a,(leerbyte)
        bit 0,a
        ret z
        res 0,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell1le),hl
        call lloop
        ret

lebit2  ld a,(leerbyte)
        bit 1,a
        ret z
        res 1,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell2le),hl
        call lloop
        ret

lebit3  ld a,(leerbyte)
        bit 2,a
        ret z
        res 2,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell3le),hl
        call lloop
        ret

lebit4  ld a,(leerbyte)
        bit 3,a
        ret z
        res 3,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell4le),hl
        call lloop
        ret

lebit5  ld a,(leerbyte)
        bit 4,a
        ret z
        res 4,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell5le),hl
        call lloop
        ret

lebit6  ld a,(leerbyte)
        bit 5,a
        ret z
        res 5,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell6le),hl
        call lloop
        ret

lebit7  ld a,(leerbyte)
        bit 6,a
        ret z
        res 6,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell7le),hl
        call lloop
        ret

lebit8  ld a,(leerbyte)
        bit 7,a
        ret z
        res 7,a
        out (leerport),a
        ld (leerbyte),a
        ld hl,(uhrbuf)
        ld (zell8le),hl
        call lloop
        ret


;************************************
tasten  call key1     ;zeichen in sio ?
        cp 0ffh
        jp z,taint    ;nein dann interne tasten
        ret           ;abfragen
;interne tastatur
taint   ld a,0ffh
	ld (tastbuf),a
        in a,(0ch)
        bit 0,a
        jp z,z1
        bit 1,a
        jp z,z2
        bit 2,a
        jp z,z3
        bit 3,a
        jp z,z4
        bit 4,a
        jp z,z5
        bit 5,a
        jp z,z6
        bit 6,a
        jp z,z7
        bit 7,a
        jp z,z8
        in a,(0bh)

        bit 0,a
        jp z,enter
        bit 1,a
        jp z,plus
        bit 2,a
        jp z,minus
	ret



;bitïs in asci wandeln

plus   ld a,'+'
	jp tasout
minus  ld a,'-'
	jp tasout
enter   ld a,0dh
	jp tasout
z1      ld a,'1'
        jp tasout
z2      ld a,'2'
        jp tasout
z3      ld a,'3'
        jp tasout
z4      ld a,'4'
        jp tasout
z5      ld a,'5'
        jp tasout
z6      ld a,'6'
        jp tasout
z7      ld a,'7'
        jp tasout
z8      ld a,'8'
        jp tasout



tasout  ld (tastbuf),a
        call lloop    ;tasten entprellung
        push af
        push bc
;tastwait in a,(0ch)   ;warte bis gedrckte taste wieder frei
 ;       ld b,a
 ;       in a,(0bh)
  ;      and b
  ;      cp 0ffh
   ;     jp nz,tastwait
        call lloop
        pop bc
        pop af
        ret

;einlesen ber V24 wenn pc angeschlossen

key1    in a,(7)
        bit 0,a          ;wenn kein zeichen
	jp z,key2
        in a,(5)         ;hole zeichen
	cp 5ah
        call nc,klgr    ;kleinbuchstaben in grosse wandeln;
	jp tasout
key2    ld a,0ffh       ;wenn kein zeichen mit ff zurueck
	ret

;Tastatur-entbrellung
lloop   push hl
	push de
	push bc
	push af
        ld b,03h      ;#
	ld de,-1
lopa    ld hl,0fffh
lopb    add hl,de
	jr c,lopb
	djnz lopa
	pop af
	pop bc
	pop de
	pop hl
	ret
refloop   push hl
	push de
	push bc
	push af
        ld b,20h      ;#
	ld de,-1
rlopa    ld hl,0fffh
rlopb    add hl,de
        jr c,rlopb
        djnz rlopa
	pop af
	pop bc
	pop de
	pop hl
	ret


longlop push hl
	push de
	push bc
	push af
        ld b,26h      ;#
	ld de,-1
xlopa    ld hl,0fffh
xlopb    add hl,de
        jr c,xlopb
        djnz xlopa
	pop af
	pop bc
	pop de
	pop hl
	ret
lauflop push hl
	push de
	push bc
	push af
        ld b,12h      ;#
	ld de,-1
laufa    ld hl,0fffh
laufb    add hl,de
        jr c,laufb
        djnz laufa
	pop af
	pop bc
	pop de
	pop hl
	ret

loop    push bc
	push af
        ld bc,0fffh
loopa   dec bc
	ld a,b
	or c
	jp nz,loopa
	pop af
	pop bc
	ret
analog0 push af
        call longlop     ;laden ist noch ein
        call longlop
        call longlop
        call longlop
        call longlop
        ld a,0           ;laden aus  = ladepause
        out (ladeport),a
        call loop
        pop af
        call analog10    ;messen
        ld a,(ladebyte)  ;laden ein
        out (ladeport),a
        ret



;die eingangs-spannung wird 10 mal gemessen + addierd
;dann durch 10 geteilt
;ergebnis in hl bc & bufhex

analog10 ld de,0
	ld (adr1),de
	ld (adr2),de
	ld (adr3),de
        ld b,10
anweit  push af
        call analog
	ld (adr1),hl
	ld a,(adr1)
	ld hl,adr2
	add a,(hl)
	ld (adr3),a
	ld a,(adr1+1)
	inc hl
        nop
	adc a,(hl)
	ld (adr3+1),a
	ld hl,(adr3)
	ld (adr2),hl
        pop af
	djnz anweit
	ld bc,0
        ld de,10
	ld (adr2),de
wetsub  and a
	sbc hl,de
	jp c,anaaus
	inc bc
	ld (adr3),hl
	ld (adr1),hl
	jp wetsub
anaaus  push bc
        pop hl        ;ergebnis nach hl

pendel  ld a,h        ;wenn H=0 +L< 250 dann L auf 0 (125mV)
                      ;verhintert bei null volt
        cp 0          ;pendeln der anzeige
        jp nz,pen1
        ld a,l
        cp 250
        jp c,pen2
        jp pen1
pen2    ld hl,00

pen1    ld (bufhex),hl
        ret
;refresh akkus werden nach leeren+laden vor dem laden zyklisch
;8 minuten mit 300/600mA geladen +120/ 240mA entladen (switch)
refresh ld hl,tx8      ;8 MIN.NURREFRESH
        ld a,(progmerk)
        cp 2
        jp z,go1
        ld hl,tx7     ;8 MIN.  REFRESH
go1     call tdisp
        ld hl,0000
        ld (uhrbuf),hl
        call uhr0
        call uhrstart
ref1    ld a,(lastrom)
        out (znport),a
        ld a,0ffh
        out (ladeport),a
        call refloop
        call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

        ld a,0
       out (ladeport),a
       ld a,(lestrom)
       out (znport),a
        ld a,0ffh
        out (leerport),a
        call refloop
        call key1
        cp 'P'
        call z,print
        cp 'E'
        call z,leprint
        cp 'R'
        jp z,0000

         ld a,0
        out (leerport),a
        ld hl,(uhrbuf)   ; 8minuten warten
        ld a,l
        cp 1
        call z,r1
        cp 2
        call z,r2
        cp 3
        call z,r3
        cp 4
        call z,r4
        cp 5
        call z,r5
        cp 6
        call z,r6
        cp 7
        call z,r7
        cp 8
        jp nz,ref1
        call uhr0
        ld a,(progmerk)
        cp 2           ;nur refresh
        jp z,start
        ld hl,tx1     ;leeren+laden
        call tdisp
        ld a,(ladebyte)
        out (ladeport),a
        ld hl,0000
        ld (uhrbuf),hl

        ret

r1      push af
        ld a,37h
        out (17h),a
        pop af
        ret

r2      push af
        ld a,36h
        out (17h),a
        pop af
        ret
r3      push af
        ld a,35h
        out (17h),a
        pop af
        ret
r4      push af
        ld a,34h
        out (17h),a
        pop af
        ret

r5      push af
        ld a,33h
        out (17h),a
        pop af
        ret

r6      push af
        ld a,32h
        out (17h),a
        pop af
        ret

r7      push af
        ld a,31h
        out (17h),a
        pop af
        ret


analog  call lloop
        and 03
	set 3,a         ;12 bit mode
	set 2,a         ;latch ??
        push af
        ld a,(adcmerk)
        ld c,a
        pop af
        out (c),a       ;contr. port
adcx    in a,(c)        ; '      '
	bit 7,a         ;end off conversion ?
        jr nz,adcx
        inc c
        inc c
        in a,(c)        ;4 2 1 0 00 00 00 00
	ld l,a
        dec c
        in a,(c)        ;12-11-10-9  8-7-6-5
	ld h,a
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l
	srl h
	rr l

        ret             ; in hl = messwert
;hex nach dezimal wandeln
;in hl = zu wandelnde hexzahl ergebniss in de
hexdez  ld(bufhex),hl
	ld de,0000      ;ergebniss reg.
	ld b,h          ;mult*256
	ld a,b
	or a            ;0?
	jp z,low        ;low byte

;add. 256 bis b=0 mit bcd korektur

anf0    ld a,e
	ld hl,con0      ;add 256 - b=0
	add a,(hl)      ;low byte in bcd
	daa             ;+akku
	ld e,a
	inc hl
	ld a,d
	adc a,(hl)      ;high byte =2+akku
	daa
	ld d,a          ;ergebniss in de
	dec b
	jp nz,anf0
;low byte wandlung
low     ld a,(bufhex)
	and 0f0h        ;low nibble ausbl.
	jp z,adrest     ;rest addieren
        call rotrra
	ld b,a
anf1    ld a,e
	ld hl,con1      ;add 16 - b=0
	add a,(hl)
	daa
	jp c,kor        ;uebertrag add
weit    ld e,a
	dec b
	jp nz,anf1      ;add-b=0
	jp adrest
kor     push af
	ld a,1          ;d reg +1
	add a,d
	daa
	ld d,a
	pop af
	ccf             ;carry flag loeschen
	jp weit
adrest  ld a,(bufhex)
	and 0fh         ;high nibble loeschen
	or a            ;loesche h-flag
	daa
	add a,e
	daa
	jp c,kor0       ;uebertrag?
	ld e,a
       	ld (bufdez),de
	ret

kor0    push af
	ld a,1
	add a,d
	daa
	ld d,a
	pop af
	ld e,a
	ld (bufdez),de
	ret



;dez buffer asci wandeln + zum display

dezdisp ld c,0ch          ;display adr.
dezdispa ld hl,(bufdez)
	ld a,l
	and 0fh
	add a,30h
	out (c),a
	ld a,l
	and 0f0h
	call shift
	add a,30h
	inc c
	out (c),a
	ld a,h
	and 0fh
	add a,30h
	inc c
	out (c),a
	ld a,h
	and 0f0h
	call shift
	add a,30h
	inc c
	out (c),a
	ret
initp1  ld a,80h        ;8255 init alles ausg„nge
        out (1fh),a
        ld a,00
        out (1ch),a
        out (1dh),a
        out (1eh),a
        ret

rotrra  rra
        rra
        rra
        rra
        ret

shift   rlca
	rlca
	rlca
	rlca
	ret

tdisp   ld b,10h      ;text zum display
        ld c,17h
xdisp   ld a,(hl)
        out (c),a
        dec c
        inc hl
        djnz xdisp
        ret
nmi     push hl
        push bc
        push de
        push af
        ld hl,(uhrbuf)
        inc hl
        ld (uhrbuf),hl
	and a
        ld de,600   ;minuten
        sbc hl,de
        jp nc,li0
li1     call print
        pop af
        pop de
        pop bc
        pop hl
        retn
li0     ld a,55h
        ld (limit),a
        jp li1
;****************************+
;       mAh
;dieses progr. erechnet die mAh fuer laden und entladen
;zahl der minuten nach (minuten) laden   (hex)
;in(milliamp) =mA/10 laden Bsp. fuer 500mA=50
;Formel mAh= Min*(mA/10)/6
;dann hex nach dez wandeln ergebnis in (bufdez)

mah     ld bc,0000
       ;; ld (result),bc
mul16   ld a,(minuten+1)
        ld c,a
        ld a,(minuten)
        ld b,16
        ld de,(milliamp)
        ld hl,0000
mult    srl c
        rra
        jr nc,noadd
        add hl,de
noadd   ex de,hl
        add hl,hl
        ex de,hl
        djnz mult
;**************************
 ;dieses programm divitiert hl:de  ergebnis in hl+bc
 ;werte fr hl+de mssen bergeben werden aufruf=divx

        ld de,0006h      ;Teiler

;------------------------------
divx    ld bc,0      ;
        and a
weitsub  sbc hl,de
        jp c,subaus
	inc bc
        jp weitsub
subaus  push bc
        pop hl
        call hexdez
        ret
;-------------------------------------------
zapp    push af
        ld hl,2000h  ;memmory fllen mit 00
        ld bc,100h   ;bis 2100h  (alte werte loeschen)
zap     ld a,00
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	or c
        jp nz,zap
        pop af
        ret


;**************************
;curser steuerungen nach ANSI

creturn ld a,0dh
	call send
	ret

lfeed   ld a,0ah
	call send
	ret

crlf    ld a,0dh
	call send
	ld a,0ah
	call send
	ret

clinks  ld a,1bh     ;curser links
	call send    ;esc
	ld a,91      ;[ =5bh
	call send
	ld a,68      ;D
	call send
	ret
cu4links push bc
         ld b,4
cuwe     call clinks
         djnz cuwe
         pop bc
         ret

crechts ld a,1bh     ;curser rechts
	call send
	ld a,91
	call send
	ld a,67
	call send
	ret

choch   ld a,1bh     ;curser hoch
	call send
	ld a,91
	call send
	ld a,65
	call send
	ret

cab     ld a,1bh     ;curser abwaerts
	call send
	ld a,91
	call send
	ld a,66
	call send
	ret
cls     ld a,1bh
        call send
        ld a,'['
        call send
        ld a,'2'
        call send
        ld a,'J'
        call send
        ret
;*********************************
; werte zum terminal senden

print  call cls
        call crlf
        ld hl,tx10
        call sendtxt
        ld b,16
hoch16  call choch
        djnz hoch16
;entladewerte senden
        ld b,19
rechts19  call crechts
        djnz rechts19
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell1le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell2le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell3le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell4le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell5le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell6le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell7le)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahle)        ;mah/10
        ld (milliamp),de
        ld de,(zell8le)
        ld (minuten),de
        call mah
        call sendasci

;ab hier ladewerte senden

        ld b,14
hoch14  call choch
        djnz hoch14
        ld b,14
rechts14  call crechts
        djnz rechts14
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell1la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell2la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig
        ld (milliamp),de
        ld de,(zell3la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell4la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell5la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell6la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell7la)
        ld (minuten),de
        call mah
        call sendasci
        call cu4links
        call cab
        call cab
        ld de,(mahla)        ;geladene mah/10 Puls Pause bercksichtig


        ld (milliamp),de
        ld de,(zell8la)
        ld (minuten),de
        call mah
        call sendasci ;

;lade spannung senden

        ld b,14
y14     call choch
        djnz y14
        ld b,10
x10     call crechts
        djnz x10
        ld hl,(ula1)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula2)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula3)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula4)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula5)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula6)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula7)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(ula8)
        call sub2
        call hexdez
        call sendasci
;++++++++++++++++++++++++++
;delta u senden

        ld b,14
y14a     call choch
        djnz y14a
        ld b,10
x10a     call crechts
        djnz x10a
        ld hl,(deltaz1)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz2)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz3)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz4)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz5)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz6)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz7)
        call sub2
        call hexdez
        call sendasci
        call cu4links
        call cab
        call cab
        ld hl,(deltaz8)
        call sub2
        call hexdez
        call sendasci

        call crlf
        call crlf
        ld hl,tx11
        call sendtxt
        call crlf
        ld hl,tx12
        call sendtxt
        call crlf
        call info
        ret

sendasci ld hl,(bufdez)
        ld a,h
        and 0f0h
        call shift
	add a,30h
        call send
        ld a,h
        and 0fh
       	add a,30h
        call send
        ld a,l
        and 0f0h
        call shift
	add a,30h
        call send
        ld a,l
        and 0fh
        add a,30h
        call send
        ret

;hex wert in hl durch 2 teilen
sub2   srl h
        rr l
        ret

test    ld hl,tx13    ;TEST OUTPUT
	call tdisp
        ld a,0
        out (leerport),a
	ld a,0ffh
	out (ladeport),a
        ld a,(lastrom)
        out (znport),a
        call test3

        ld hl,tx14       ;test input
	call tdisp
	ld a,0
	out (ladeport),a
	ld a,0ffh
	out (leerport),a
        ld a,(lestrom)
        out (znport),a
        call test3
 	ld a,0
	out (ladeport),a
        ld a,0
	out (leerport),a
        call test3
        jp test

test3   call tasten      ;Tasten z1 -z8  zeigt Zellen-Spannung an
        cp '+'
        ret z
        cp '1'
        call z,tm03
        cp '2'
        call z,tm03
        cp '3'
        call z,tm03
        cp '4'
        call z,tm03
        cp '5'
        call z,tm47
        cp '6'
        call z,tm47
        cp '7'
        call z,tm47
        cp '8'
        call z,tm47
        cp 'R'
        jp z,0000
        jp test3

tm03    push af
        sub 31h

        push af
        ld a,18h ;adc1
        ld (adcmerk),a
        pop af
        call analog
        call pendel
        call sub2
        call hexdez
        call dezdisp
        call sendasci
        call crlf
        pop af
        ret
tm47    push af
        sub 35h
        push af
        ld a,0 ;adc2
        ld (adcmerk),a
        pop af
        call analog
        call pendel
        call sub2
        call hexdez
        call dezdisp
        call sendasci
        call crlf
        pop af
        ret


con0    db 56h,02h
con1    db 16h,00h
tx13    db 'TESTOUT      MV '
tx14    db 'TEST IN      MV '
txdisp0 db '                '
textp   db 'PROG.WAHL MIT + '

tx1     db ' LEEREN + LADEN '

tx2     db 'PULSLADEN=600 MA'
tx2a    db 'PULSLADEN=300 MA'
tx3     db 'LEEREN 240 MAMP.'
tx3a    db 'LEEREN 120 MAMP.'
tx4     db 'LEER Z       MAH'
tx5     db 'LADE Z       MAH'
tx6     db '  **  ENDE  **  '
tx7     db '8 MIN.  REFRESH '
tx8     db '8 MIN.NURREFRESH'
tx9     db '   I/O TEST     '

tx10    db 0ah,0dh,'   8-FACH AKKULADER VERSION 7.1A  H.Gnther 2013 ',0ah,0dh,0ah,0dh
        db '   ZELLE Nr.     ENTLADEN mA/h    GELADEN mA/h  LADE ENDE mV   DELTA U mV',0ah,0dh,0ah,0dh
        db '         1 ',0ah,0dh,0ah,0dh
        db '         2 ',0ah,0dh,0ah,0dh
        db '         3 ',0ah,0dh,0ah,0dh
        db '         4 ',0ah,0dh,0ah,0dh
        db '         5 ',0ah,0dh,0ah,0dh
        db '         6 ',0ah,0dh,0ah,0dh
        db '         7 ',0ah,0dh,0ah,0dh
        db '         8 ',0ah,0dh,0ah,0dh
        db '$$'
tx11    db '    TASTE E = ZEIGT ENTLADE-SPANNUNG UNTER LAST AN (P=AKTUALISIEREN R=RESTART) $$'
tx12    db '    WERTE WERDEN ERST NACH 2 MINUTEN ANGEZEIGT $$'
tx20    db '     H.Guenther 8 FACH AKKU TESTER & LADER Z2003  ',0ah,0dh,0ah,0dh
        db '     PULS-LADEN = 300 mA = 250 mA EFFEKTIV        ',0ah,0dh
        db '     PULS-LADEN = 600 mA = 500 mA EFFEKTIV        ',0ah,0dh
        db '     EINSTELLUNG MIT SCHALTER ',0ah,0dh,0ah,0dh
        db '     NACH PROGRAMMSTART WERDEN ALLE WERTE NACH 1 MINUTE ',0ah,0dh
        db '     AUTOMATISCH ANGEZEIGT. ODER TASTE P DRUECKEN ',0ah,0dh,'$$'

tz1     db ' Z1 = $'
tz1a    db '  mV $'
tz2     db ' Z2 = $'

tz3     db ' Z3 = $'

tz4     db ' Z4 = $'
tz5     db ' Z5 = $'

tz6     db ' Z6 = $'

tz7     db ' Z7 = $'

tz8     db ' Z8 = $'
tze     db '  Zellen-Spannung leeren  gemessen unter Last ',0ah,0dh
        db '  Zur šbersicht Taste P   $'

leprint call cls
        call crlf
        call crlf
        ld hl,tze
        call sendtxt
        call crlf
        call crlf

        call crlf
        call crechts
        ld hl,tz1
       call sendtxt
        ld hl,(ule1)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
        call sendtxt
        call crlf
        call crlf
        call crechts
        ld hl,tz2
       call sendtxt

        ld hl,(ule2)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz3
       call sendtxt

        ld hl,(ule3)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz4
       call sendtxt

        ld hl,(ule4)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz5
       call sendtxt

        ld hl,(ule5)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz6
       call sendtxt

        ld hl,(ule6)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz7
       call sendtxt

        ld hl,(ule7)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf
        call crechts
        ld hl,tz8
       call sendtxt

        ld hl,(ule8)
        call sub2
        call hexdez
        call sendasci
        ld hl,tz1a
       call sendtxt

        call crlf
        call crlf

        ret
switch push af
       in a,(0bh)
       bit 7,a
       jp z,sthigh
       ld a,70h
       ld (lestrom),a  ;120 mA
       ld de,120
       ld (instrom),de
       ld a,7fh
       ld (lastrom),a  ;puls 300mA
       ld de,300
       ld (outstrom),de
       ld a,12
       ld (mahle),a
       ld a,25
       ld (mahla),a
       pop af
       ret
sthigh ld a,0ffh
       ld (lestrom),a  ;240mA
       ld de,240
       ld (instrom),de
       ld (lastrom),a  ;puls 600mA
       ld de,600
       ld (outstrom),de
       ld a,24
       ld (mahle),a
       ld a,50
       ld (mahla),a
       pop af
       ret

info    ld hl,inftime
        call sendtxt
        ld hl,(uhrbuf)  ;vergangene zeit seit uhrstart
        call hexdez
        call sendasci
        ld hl,inflade
        call sendtxt
        ld hl,(outstrom) ;mA Lade-Puls
        call hexdez
        call sendasci
        ld hl,infleer
        call sendtxt
        ld hl,(instrom)  ;mA Leeren
        call hexdez
        call sendasci
        ld hl,iblank
        call sendtxt
        ret

inftime db      '    MINUTEN = $'
inflade db      '    LADE-PULS mA = $'
infleer db      '    LEEREN mA= $'
iblank  db      '     $'
