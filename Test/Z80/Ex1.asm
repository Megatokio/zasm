;Disp 'Help us' until Step-Key pushed:
		ORG 	1800H
		LD		IX,Help
Disp	CALL 	Scan		
		CP		13H	;Key-Step
		JR		NZ,Disp
		HALT
		ORG		1820H
Help	DEFB	0AEH	;'S'
		DEFB	0B5H	;'U'
		DEFB	01FH	;'P'
		DEFB	085H	;'L'
		DEFB	08FH	;'E'
		DEFB	037H	;'H'
;
Scan	EQU 	05FEH
		END