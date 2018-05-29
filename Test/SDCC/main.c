




#include <stdlib.h>
#include <stdio.h>

#include <string.h>
#include <sdcc-lib.h>

char bu1[10];
char bu2[10];
char str3[10] ="123456789";
volatile int a_counter = 0;

const char so_many_days_per_month[] = { 31,28,31,30,31,30,31,31,30,31,30,31 };


 #pragma std_c99
 //bool requires std-c99 or std-sdcc99 or better
 #include "stdbool.h"
 bool f;

	void Intr(void) __naked __interrupt 0
	{
		__asm__(" exx\n ex af,af'\n");
		a_counter++;
		__asm__(" exx\n ex af,af'\n reti\n");
	}

	void NMI_Intr(void) __critical __interrupt
	{
		a_counter++;
	}

void main()
{
	int i;
	char c;
	char* array;

	puts("Hello C World!");
	puts("Say 'Hi' to Kio");
	puts("");

	array = malloc(44);
	array = realloc(array,88);
	free(array);

	bu1[0]='A';	// sdcc doesn't genate code which exhibits the character, just the number :-(
	c='a';
	if(c==bu1[0]) bu1[1]=c;

#ifdef __STDC_VERSION__
// __STDC_VERSION__ ist erst ab c99 definiert:	(aber nicht für sdcc99!) (und nicht für #pragma std_c99!)
	printf("__STDC_VERSION__ = %li\n",(long)__STDC_VERSION__);		//TODO: DEBUG
//	printf("__STDC_VERSION__ = %i%02i\n",(int)(__STDC_VERSION__/100),(int)(__STDC_VERSION__%100));
#else
	puts("__STDC_VERSION__ undef (c89)");
#endif

	if(strcmp("aa","aa")) printf("");		// --> _strcmp.c
	memcpy(bu1,bu2,10);						// --> __builtin_memcpy ((inline))
	strcpy(bu2,str3);						// --> __builtin_strcpy ((inline))

// __SDCC hat auch einen Wert,
// das ist aber ein nicht weiter definierter Text à la SDCC_3_2_1
// und keine Zahl oder String. Schwer irgendwas damit zu machen.
#ifdef __SDCC					// defined by sdcc
	printf("__SDCC isdef\n");
#else    //"12345678901234567890123456789012"
	#error
#endif

#ifdef __SDCC_z80				// --mz80
	printf("__SDCC_z80 isdef\n");
#else    //"12345678901234567890123456789012"
	#error
#endif

#ifdef __SDCC_STACK_AUTO		// --stack-auto
	printf("__SDCC_STACK_AUTO isdef\n");			// default = defined
#else    //"12345678901234567890123456789012"
	printf("__SDCC_STACK_AUTO ISNDEF\n");
#endif

#ifdef __SDCC_CHAR_UNSIGNED		// --funsigned-char
	printf("__SDCC_CHAR_UNSIGNED ISDEF\n");
#else    //"12345678901234567890123456789012"
	printf("__SDCC_CHAR_UNSIGNED isndef\n");		// default = signed char
#endif

#ifdef __SDCC_ALL_CALLEE_SAVES	// --all-callee-saves
	printf("__SDCC_ALL_CALLEE_SAVES ISDEF\n");
#else    //"12345678901234567890123456789012"
	printf("__SDCC_ALL_CALLEE_SAVES isndef\n");		// default = undefined
#endif

#ifdef __SDCC_FLOAT_REENTRANT	// --float-reentrant
	printf("__SDCC_FLOAT_REENTRANT isdef\n");
#else    //"12345678901234567890123456789012"
	printf("__SDCC_FLOAT_REENTRANT ISNDEF\n");		// default = undefined
#endif												// but lib/math.h says: float is ALWAYS reentrant!

#ifdef __SDCC_INT_LONG_REENT	// --int-long-reent
	printf("__SDCC_INT_LONG_REENT isdef\n");		// default = defined
#else    //"12345678901234567890123456789012"
	printf("__SDCC_INT_LONG_REENT ISNDEF\n");
#endif

//#ifndef _REENTRANT	// sdcc-lib.h: define to empty
//	#error
//#endif
//#ifndef _CODE		// sdcc-lib.h: define to empty
//	#error
//#endif
//#ifndef _AUTOMEM	// sdcc-lib.h: define to empty
//	#error
//#endif
//#ifndef _STATMEM	// sdcc-lib.h: define to empty
//	#error
//#endif



	for(i=0;i<10;i++)
	{
		printf("%i * %i = %i\n", i,i,i*i);
	}
}










