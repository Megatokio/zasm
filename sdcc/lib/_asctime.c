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
   kio 2014-11-27	removed _CODE because this is defined as nothing in z80 port
					and sdcc always puts const data inti the current code segment
   kio 2014-11-27	corrected const declaration for __month and __day 
					so that also the pointer array is put into the code segment
					TODO: char[][] might be shorter
*/


#include <stdio.h>
#include <time.h>

void check_struct_tm(struct tm *timeptr);


/* please note that the tm structure has the years since 1900,	*/
/* but time returns the seconds since 1970						*/


char const * const __month[] = 
{
	"Jan","Feb","Mar","Apr","May","Jun",
	"Jul","Aug","Sep","Oct","Nov","Dec"
};

char const * const __day[] = 
{
	"Sun","Mon","Tue","Wed","Thu","Fri","Sat"
};

static char ascTimeBuffer[32];



/* format the time into "Sat Feb 17 17:45:23 2001\n"
*/
char *asctime(struct tm *timeptr) 
{
  check_struct_tm(timeptr);
  sprintf (ascTimeBuffer, "%s %s %2d %02d:%02d:%02d %04d\n",
	   __day[timeptr->tm_wday], 
	   __month[timeptr->tm_mon], 
	   timeptr->tm_mday,
	   timeptr->tm_hour, 
	   timeptr->tm_min, 
	   timeptr->tm_sec, 
	   timeptr->tm_year+1900);
  return ascTimeBuffer;
}





