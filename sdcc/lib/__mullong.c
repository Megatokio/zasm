/*-------------------------------------------------------------------------
   _mullong.c - routine for multiplication of 32 bit (unsigned) long

   Copyright (C) 1999, Sandeep Dutta . sandeep.dutta@usa.net
   Copyright (C) 1999, Jean Louis VERN jlvern@writeme.com

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


   kio 2014-11-16	removed MCS51 asm code
   kio 2014-11-26	removed AUTOMEM because this is not used by the z80 port
   kio 2014-11-26	removed version for SDCC_USE_XSTACK because this is for 8051 only
*/


struct some_struct 
{
	short a ;
	char b;
	long c ;
};


#if defined(__SDCC_hc08) || defined(__SDCC_s08) || defined(__SDCC_stm8)
/* big endian order */
union bil 
{
        struct {unsigned char b3,b2,b1,b0 ;} b;
        struct {unsigned short hi,lo ;} i;
        unsigned long l;
        struct { unsigned char b3; unsigned short i12; unsigned char b0;} bi;
} ;
#else
/* little endian order */
union bil 
{
        struct {unsigned char b0,b1,b2,b3 ;} b;
        struct {unsigned short lo,hi ;} i;
        unsigned long l;
        struct { unsigned char b0; unsigned short i12; unsigned char b3;} bi;
} ;
#endif


#include <sdcc-lib.h>


#define bcast(x) ((union bil *)&(x))

/*
                     3   2   1   0
       X             3   2   1   0
       ----------------------------
                   0.3 0.2 0.1 0.0
               1.3 1.2 1.1 1.0
           2.3 2.2 2.1 2.0
       3.3 3.2 3.1 3.0
       ----------------------------
                  |3.3|1.3|0.2|0.0|   A
                    |2.3|0.3|0.1|     B
                    |3.2|1.2|1.0|     C
                      |2.2|1.1|       D
                      |3.1|2.0|       E
                        |2.1|         F
                        |3.0|         G
                          |-------> only this side 32 x 32 -> 32
*/



#if defined(__SDCC_z80) || defined(__SDCC_gbz80) || defined(__SDCC_r2k) || defined(__SDCC_r3k)
	// 32x32->32 multiplication to be used
	// if 16x16->16 is faster than three 8x8->16.
	// 2009, by M.Bodrato ( http://bodrato.it/ )

long _mullong (long a, long b)
{
  unsigned short i12;

  bcast(a)->i.hi *= bcast(b)->i.lo;
  bcast(a)->i.hi += bcast(b)->i.hi * bcast(a)->i.lo;

  /* only (a->i.lo * b->i.lo) 16x16->32 to do. asm? */
  bcast(a)->i.hi += bcast(a)->b.b1 * bcast(b)->b.b1;

  i12 = bcast(b)->b.b0 * bcast(a)->b.b1;
  bcast(b)->bi.i12 = bcast(a)->b.b0 * bcast(b)->b.b1;

  /* add up the two partial result, store carry in b3 */
  bcast(b)->b.b3 = ((bcast(b)->bi.i12 += i12) < i12);

  bcast(a)->i.lo  = bcast(a)->b.b0 * bcast(b)->b.b0;

  bcast(b)->bi.b0 = 0;

  return a + b;
}


#else

long _mullong (long a, long b)
{
	union bil t;

	t.i.hi = bcast(a)->b.b0 * bcast(b)->b.b2;           // A
	t.i.lo = bcast(a)->b.b0 * bcast(b)->b.b0;           // A
	t.b.b3 += bcast(a)->b.b3 * bcast(b)->b.b0;          // G
	t.b.b3 += bcast(a)->b.b2 * bcast(b)->b.b1;          // F
	t.i.hi += bcast(a)->b.b2 * bcast(b)->b.b0;          // E <- b lost in .lst
	// bcast(a)->i.hi is free !
	t.i.hi += bcast(a)->b.b1 * bcast(b)->b.b1;          // D <- b lost in .lst

	bcast(a)->bi.b3 = bcast(a)->b.b1 * bcast(b)->b.b2;  // C
	bcast(a)->bi.i12 = bcast(a)->b.b1 * bcast(b)->b.b0; // C

	bcast(b)->bi.b3 = bcast(a)->b.b0 * bcast(b)->b.b3;  // B
	bcast(b)->bi.i12 = bcast(a)->b.b0 * bcast(b)->b.b1; // B

	bcast(b)->bi.b0 = 0;                                // B
	bcast(a)->bi.b0 = 0;                                // C
	t.l += a;

	return t.l + b;
}

#endif


