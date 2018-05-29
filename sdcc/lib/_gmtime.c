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


extern char days_per_month[];


// return value:
//
static struct tm lastTime;


// A leap year is ((((year%4)==0) && ((year%100)!=0)) || ((year%400)==0)) 
// but since we have no fancy years between 1970 and 2038 we can do:
//
#define LEAP_YEAR(year) ((year%4)==0)




/* convert calendar time (seconds since 1970) to broken-time
   This only works for dates between 01-01-1970 00:00:00 and 
   19-01-2038 03:14:07
*/
struct tm *gmtime(time_t *timep) 
{
  unsigned long epoch=*timep;
  unsigned int year;
  unsigned char month, monthLength;
  unsigned long days;
  
  lastTime.tm_sec=epoch%60;
  epoch/=60; // now it is minutes
  lastTime.tm_min=epoch%60;
  epoch/=60; // now it is hours
  lastTime.tm_hour=epoch%24;
  epoch/=24; // now it is days
  lastTime.tm_wday=(epoch+4)%7;
  
  year=1970;
  days=0;
  while((days += (LEAP_YEAR(year) ? 366 : 365)) <= epoch) 
  {
    year++;
  }
  lastTime.tm_year=year-1900;
  
  days -= LEAP_YEAR(year) ? 366 : 365;
  epoch -= days; // now it is days in this year, starting at 0
  lastTime.tm_yday=epoch;
  
  days=0;
  month=0;
  monthLength=0;
  for (month=0; month<12; month++) 
  {
    if (month==1 /*februar*/ && LEAP_YEAR(year))	// kio 2016-04-26: simplified
		monthLength=29;
	else 
      	monthLength = days_per_month[month];
    
    if (epoch >= monthLength) 
      epoch -= monthLength;
	else 
	  break;
  }
  lastTime.tm_mon=month;
  lastTime.tm_mday=epoch+1;
  
  lastTime.tm_isdst=0;
  
  return &lastTime;
}






