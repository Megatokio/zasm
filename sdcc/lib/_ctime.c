/*-------------------------------------------------------------------------
   time.c - stdlib time conversion routines

   Copyright (C) 2001, Johan Knol <johan.knol AT iduna.nl>

   This library is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
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


   kio 2014-11-16	split file into individual files for each symbol:
  					_time.c
  					_check_struct_tm.c	(was static)
  					_asctime.c
  					_ctime.c
  					_localtime.s
  					_gmtime.c
  					_mktime.c
*/


#include <stdio.h>
#include <time.h>

void check_struct_tm(struct tm *timeptr);

/* please note that the tm structure has the years since 1900,	*/
/* but time returns the seconds since 1970						*/


char *ctime(time_t *timep) 
{
  return asctime(localtime(timep));
}





