/*-----------------------------------------------------------------
   vprintf.c - formatted output conversion

   Copyright (C) 1999, Martijn van Balen <aed AT iae.nl>
   Refactored by - Maarten Brock (2004)

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


   kio 2014-11-16	split file into separate files for each defined symbol
 					_printf.c
  					_vprintf.c
  					_put_char_to_stdout.c	(was static)
   kio 2014-11-26	removed keyword REENTRANT because functions in the z80 port are always reentrant
*/


#include <stdarg.h>
#include <stdio.h>

void put_char_to_stdout (char c, void* p);

int printf (const char *format, ...)
{
  va_list arg;
  int i;

  va_start (arg, format);
  i = _print_format (put_char_to_stdout, NULL, format, arg);
  va_end (arg);

  return i;
}
