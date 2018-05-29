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

// please note that the tm structure has the years since 1900,
// but time returns the seconds since 1970


void check_struct_tm(struct tm *timeptr);
extern char days_per_month[];


// A leap year is ((((year%4)==0) && ((year%100)!=0)) || ((year%400)==0)) 
// but since we have no fancy years between 1970 and 2038 we can do:
//
#define LEAP_YEAR(year) ((year%4)==0)



// convert broken time to calendar time (seconds since 1970)
//
time_t mktime(struct tm *timeptr) 
{
    int year=timeptr->tm_year+1900, month=timeptr->tm_mon, i;
    long seconds;
    
    check_struct_tm(timeptr);

    // seconds from 1970 till 1 jan 00:00:00 this year
    seconds= (year-1970)*(60*60*24L*365);

    // add extra days for leap years
    for (i=1970; i<year; i++) 
	{
		if (LEAP_YEAR(i)) 
			seconds+= 60*60*24L;
    }

    // add days for this year
    for (i=0; i<month; i++) 
	{
      if (i==1 && LEAP_YEAR(year)) 
		  seconds+= 60*60*24L*29;
	  else 
		  seconds+= 60*60*24L*days_per_month[i];
    }

    seconds+= (timeptr->tm_mday-1)*60*60*24L;
    seconds+= timeptr->tm_hour*60*60L;
    seconds+= timeptr->tm_min*60;
    seconds+= timeptr->tm_sec;
    return seconds;
}













