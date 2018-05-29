;
;	kio 2014-11-16	made a define in assembler because the compiler can't optimize it 
;



; 	forget about timezones for now
; 	struct tm *localtime(time_t *timep) 
; 	{
;   	return gmtime(timep);
; 	}


	.area  _CODE
	.globl _localtime
	
_localtime equ _gmtime



	