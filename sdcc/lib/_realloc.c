/*-------------------------------------------------------------------------
   _realloc.c - reallocate allocated memory.

   Copyright (C) 2004, Maarten Brock, sourceforge.brock@dse.nl

   This library is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License 
   along with this library; see the file COPYING. If not, write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

   As a special exception, if you link this library with other files,
   some of which are compiled with SDCC, to produce an executable,
   this library does not by itself cause the resulting executable to
   be covered by the GNU General Public License. This exception does
   not however invalidate any other reasons why the executable file
   might be covered by the GNU General Public License.


   kio 2014-11-26	removed #define CRITICAL __critical
   kio 2014-11-26	removed __xdata
   kio 2014-11-26	removed the MAH version, because z80 uses MLH version
   kio 2014-11-30	moved _sdcc_find_memheader() from _free.c because it is used by here and inlined it
   kio 2014-11-30	replaced unsigned int with size_t
*/


#include <sdcc-lib.h>
#include <malloc.h>
#include <string.h>
#include <stddef.h>


typedef struct _MEMHEADER MEMHEADER;

struct _MEMHEADER
{
  MEMHEADER *   next;
  MEMHEADER *   prev;
  size_t  		len;
  unsigned char mem;
};

#define HEADER_SIZE (sizeof(MEMHEADER)-sizeof(char))
#define MEM(x)      (&x->mem)


// static
// MEMHEADER * _sdcc_prev_memheader;
//
// // apart from finding the header
// // this function also finds it's predecessor
// static
// MEMHEADER * _sdcc_find_memheader(void * p)
// {
//   register MEMHEADER * pthis;
//   if (!p)
//     return NULL;
//   pthis = (MEMHEADER * )((char *)  p - HEADER_SIZE); //to start of header
//   _sdcc_prev_memheader = pthis->prev;
//
//   return (pthis);
// }


void * realloc (void * p, size_t size)
{
	register MEMHEADER * pthis;
	register MEMHEADER * pnew;
	register void * ret;
	MEMHEADER * prev_memheader;

	if(p) 
	__critical
	{
//		pthis = _sdcc_find_memheader(p);
	    pthis = (MEMHEADER*) ((char*)p - HEADER_SIZE); 	// calc start of header
	    prev_memheader = pthis->prev;

		if (size > (0xFFFF-HEADER_SIZE))
      	{
        	ret = (void *) NULL; 	// To prevent overflow in next line
      	}
      	else
      	{
        	size += HEADER_SIZE; 	// We need memory for header too

			if ((size_t)pthis->next - (size_t)pthis >= size)
        	{	//if spare is more than needed
        		pthis->len = size;
        		ret = p;
        	}
        	else
        	{
          	  	if (prev_memheader &&
              	   	(size_t)pthis->next - (size_t)prev_memheader - prev_memheader->len >= size)
          		{
            		pnew = (MEMHEADER*) ((char*)prev_memheader + prev_memheader->len);
            		prev_memheader->next = pnew;

					pthis->next->prev = pnew;

            		memmove(pnew, pthis, pthis->len);
            		pnew->len = size;
            		ret = MEM(pnew);
          	  	}
          	  	else
          		{
            		ret = malloc(size - HEADER_SIZE);
            		if (ret)
            		{
              	  		memcpy(ret, MEM(pthis), pthis->len - HEADER_SIZE);
              			free(p);
            		}
				}
        	}
      	}
	}
	else
	{
		ret = malloc(size);
	}
  	return ret;
}

