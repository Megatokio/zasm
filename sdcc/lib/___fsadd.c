/*-------------------------------------------------------------------------
   _fsadd.c - Floating point library in optimized assembly for 8051

   Copyright (c) 2004, Paul Stoffregen, paul@pjrc.com

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


** libgcc support for software floating point.
** Copyright (C) 1991 by Pipeline Associates, Inc.  All rights reserved.
** Permission is granted to do *anything* you want with this file,
** commercial or otherwise, provided this message remains intact.  So there!
** I would appreciate receiving any updates/patches/changes that anyone
** makes, and am willing to be the repository for said changes (am I
** making a big mistake?).
**
** Pat Wood
** Pipeline Associates, Inc.
** pipeline!phw@motown.com or
** sun!pipeline!phw or
** uunet!motown!pipeline!phw


   kio 2014-11-16	removed MCS51 asm code
   kio 2014-11-26	added #pragma std_sdcc99 for bool
   kio 2014-11-26	removed AUTOMEM because this is not used by the z80 port
*/


#pragma std_sdcc99
#include <float.h>
#include <stdbool.h>
#include <sdcc-lib.h>


union float_long
{
    float f;
    unsigned long l;
};


/* add two floats 
*/
float __fsadd (float a1, float a2)
{
  long mant1, mant2;
  long *pfl1;
  long *pfl2;
  int exp1, exp2, expd;
  bool sign = false;

  pfl2 = (long *)&a2;
  exp2 = EXP (*pfl2);
  mant2 = MANT (*pfl2) << 4;
  if (SIGN (*pfl2))
    mant2 = -mant2;
  /* check for zero args */
  if (!*pfl2)
    return (a1);

  pfl1 = (long *)&a1;
  exp1 = EXP (*pfl1);
  mant1 = MANT (*pfl1) << 4;
  if (SIGN(*pfl1))
  if (*pfl1 & 0x80000000)
    mant1 = -mant1;
  /* check for zero args */
  if (!*pfl1)
    return (a2);

  expd = exp1 - exp2;
  if (expd > 25)
    return (a1);
  if (expd < -25)
    return (a2);

  if (expd < 0)
    {
      expd = -expd;
      exp1 += expd;
      mant1 >>= expd;
    }
  else
    {
      mant2 >>= expd;
    }
  mant1 += mant2;

  sign = false;

  if (mant1 < 0)
    {
      mant1 = -mant1;
      sign = true;
    }
  else if (!mant1)
    return (0);

  /* normalize */
  while (mant1 < (HIDDEN<<4)) 
  {
    mant1 <<= 1;
    exp1--;
  }

  /* round off */
  while (mant1 & 0xf0000000) 
  {
    if (mant1&1)
      mant1 += 2;
    mant1 >>= 1;
    exp1++;
  }

  /* turn off hidden bit */
  mant1 &= ~(HIDDEN<<4);

  /* pack up and go home */
  if (exp1 >= 0x100)
    *pfl1 = (sign ? (SIGNBIT | __INFINITY) : __INFINITY);
  else if (exp1 < 0)
    *pfl1 = 0;
  else
    *pfl1 = PACK (sign ? SIGNBIT : 0 , exp1, mant1>>4);
  return (a1);
}


