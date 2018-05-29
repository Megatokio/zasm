/*-------------------------------------------------------------------------
   _ltoa.c - integer to string conversion

   Copyright (c) 1999, Bela Torok, bela.torok@kssg.ch

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


 	usage:

	_ultoa(unsigned long value, char* string, int radix)
	_ltoa(long value, char* string, int radix)

	value  ->  Number to be converted
	string ->  Result
	radix  ->  Base of value (e.g.: 2 for binary, 10 for decimal, 16 for hex)


	2014-11-30 kio	moved _ultoa() and _ltoa() into separate files
					removed non-z80 code
					always use 32 char buffer
*/


void _ultoa(unsigned long value, char* string, unsigned char radix);


void _ltoa(long value, char* string, unsigned char radix)
{
	if (value < 0 && radix == 10) 
	{
		*string++ = '-';
    	value = -value;
	}
	_ultoa(value, string, radix);
}




