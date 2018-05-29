// kio 2014-11-26

#ifndef _SDCC_LIB_H
#define _SDCC_LIB_H	1

#ifndef __SDCC_z80
#error
#endif

/* the following #defines have been removed because they no longer have any effect:

#define _REENTRANT	functions on the z80 are ALWAYS reentrant 
#define _CODE		was only used in _days_per_month.c for char days_per_month[] and in asctime.c
#define _AUTOMEM 
#define _STATMEM 

#define _SDCC_MANGLES_SUPPORT_FUNS	1	__divsint.c and __modsint.c: but __divsint.s and __modsint.s are used
#define _SDCC_Z80_STYLE_LIB_OPT		1	removed test in lib/_strcmp.c
#define _SDCC_PORT_PROVIDES_MEMCPY	0	sdcc may generate inline assembler code; but _memcpy.c may still be used
										-> see lib/string.h
#define _SDCC_PORT_PROVIDES_STRCMP	0	must always be provided by "the linker"; --> _strcmp.c
#define _SDCC_PORT_PROVIDES_STRCPY	0	sdcc may generate inline assembler code; but _strcpy.s may still be used
										-> see lib/string.h
#define _SDCC_MALLOC_TYPE_MLH		1	removed MAH code from _malloc.c, _free.c and _realloc.c

*/

#endif

