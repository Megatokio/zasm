/*-------------------------------------------------------------------------
   free.c - release allocated memory.

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


   kio 2014-11-17	removed the MAH version, because z80/features.h says: z80 uses MLH version
  					commented out #if tests
   kio 2014-11-26	removed #define CRITICAL __critical
   kio 2014-11-30	moved sdcc_find_memheader() to _realloc.c where it is used
*/


#include <sdcc-lib.h>
#include <malloc.h>

typedef struct _MEMHEADER MEMHEADER;

struct _MEMHEADER
{
  MEMHEADER *    next;
  MEMHEADER *    prev;
  unsigned int   len;
  unsigned char  mem;
};

#define HEADER_SIZE (sizeof(MEMHEADER)-sizeof(char))

/* These variables are defined through the crt0 functions. */
/* Base of this variable is the first byte of the heap. */
extern MEMHEADER _sdcc_heap_start;

/* Address of this variable is the last byte of the heap. */
extern char _sdcc_heap_end;


void free (void *p)
{
  MEMHEADER *prev_header, *pthis;

  if ( p ) //For allocated pointers only!
    __critical
    {
      pthis = (MEMHEADER * )((char *)  p - HEADER_SIZE); //to start of header
      if ( pthis->prev ) // For the regular header
        {
          prev_header = pthis->prev;
          prev_header->next = pthis->next;
          if (pthis->next)
            {
              pthis->next->prev = prev_header;
            }
        }
      else
        {
          pthis->len = 0; //For the first header
        }
    }
}



