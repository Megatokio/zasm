/*-------------------------------------------------------------------------
   stdbool.h - ANSI functions forward declarations

   Copyright (C) 2004, Maarten Brock, sourceforge.brock@dse.nl

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


   kio 2014-11-26	removed test for targets other than z80
  					this file defines bool as _Bool but _Bool itself is only defined since std-c99. :-/
  					=> either don't give a --std-cxx option => --std-sdcc99 is default
  					   or     use --std-c99 or --std-sdcc99 or better
  					   or     use #pragma std_sdcc99 or better in source file
  					bool is used in the lib/ files mostly for float and div[s|u]longlong.c
-------------------------------------------------------------------------*/


#ifndef _STDBOOL_H
#define _STDBOOL_H 1

#define true 1
#define false 0

#define	bool _Bool
#define	__bool_true_false_are_defined 1


#endif

