/*-------------------------------------------------------------------------
   malloc.c - allocate memory.

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


   kio 2014-11-17	removed the MAH version, because z80 uses MLH version
   kio 2014-11-26	removed #define CRITICAL __critical
   kio 2014-11-30	Put the heap initialization code automatically into the _GSINIT segment.
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



void * malloc (unsigned int size)
{
  register MEMHEADER * current_header;
  register MEMHEADER * new_header;
  register void * ret;

  if (size>(0xFFFF-HEADER_SIZE))
    {
      return NULL; //To prevent overflow in next line
    }

  size += HEADER_SIZE; //We need a memory for header too
  current_header = &_sdcc_heap_start;

  __critical
    {
      while (1)
        {
          //    current
          //    |   len       next
          //    v   v         v
          //....*****.........******....
          //         ^^^^^^^^^
          //           spare

          if ((((unsigned int)current_header->next) -
               ((unsigned int)current_header) -
               current_header->len) >= size)
            { //if spare is more than needed
              ret = &current_header->mem;
              break;
            }
          current_header = current_header->next;    //else try next
          if (!current_header->next)
            { //if end_of_list reached
              ret = NULL;
              break;
            }
        }

      if (ret)
        {
          if (!current_header->len)
            { //This code works only for first_header in the list and only
              current_header->len = size; //for first allocation
            }
          else
            {
              //else create new header at the begin of spare
              new_header = (MEMHEADER * )((char *)current_header + current_header->len);
              new_header->next = current_header->next; //and plug it into the chain
              new_header->prev = current_header;
              current_header->next  = new_header;
              if (new_header->next)
                {
                  new_header->next->prev = new_header;
                }
              new_header->len  = size; //mark as used
              ret = &new_header->mem;
            }
        }
    }
  return ret;
}


/*	kio 2014-11-30:
	Put the heap initialization code automatically into the _GSINIT segment.

  •	By using __naked sdcc does not include a final ret, so we can run 'through' this code in _GSINIT 

  •	#pragma GSINIT should have been used to put sdcc_heap_init() into the _GSINIT segment,
	but can't be used because sdcc applies this setting to the whole file :-(

  •	Then __asm__(".area _GSINIT\n") should have gone directly into sdcc_heap_init(),
	but then sdcc fails to compile this function.

  •	So __asm__(".area _GSINIT\n") is put in a separate __naked otherwise completely empty function.
	sdcc generates .area _CODE only once for all functions, so it is not reset before sdcc_heap_init() is compiled.
	Probably this will fail some day when someone changes this behaviour in sdcc…
*/

#ifndef __SDCC
#error tricks highly specific to sdcc!
#endif

static void z(void) __naked
{
	__asm__(".area _GSINIT\n");		/* #pragma GSINIT can't be used because it works on the whole file :-( */
}

static void sdcc_heap_init(void) __naked
{
	MEMHEADER * pbase = &_sdcc_heap_start;
	unsigned int size = &_sdcc_heap_end - (char*)pbase;

	pbase->next = (MEMHEADER*) ((char*)pbase + size - HEADER_SIZE);
	pbase->next->next = NULL; 	/* And mark it as last		*/
	pbase->prev       = NULL; 	/* and mark first as first	*/
	pbase->len        = 0;    	/* Empty and ready.			*/
}




