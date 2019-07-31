#pragma once
/*	Copyright  (c)	Günter Woigk 2014 - 2019
  					mailto:kio@little-bat.de

 	This program is distributed in the hope that it will be useful,
 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

 	Permission to use, copy, modify, distribute, and sell this software and
 	its documentation for any purpose is hereby granted without fee, provided
 	that the above copyright notice appear in all copies and that both that
 	copyright notice and this permission notice appear in supporting
 	documentation, and that the name of the copyright holder not be used
 	in advertising or publicity pertaining to distribution of the software
 	without specific, written prior permission.  The copyright holder makes no
 	representations about the suitability of this software for any purpose.
 	It is provided "as is" without express or implied warranty.

 	THE COPYRIGHT HOLDER DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
 	INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
 	EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY SPECIAL, INDIRECT OR
 	CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE,
 	DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 	TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 	PERFORMANCE OF THIS SOFTWARE.


	z80 opcode clock cycles
	-----------------------
*/

#include "kio/kio.h"

#ifndef DEFINE_CB_TABLES
#define DEFINE_CB_TABLES 0
#endif

/*	the tables
	easy computable CB tables only on request
*/
EXT	uint8 cc_normal[256];
EXT	uint8 cc_ED[256];
EXT	uint8 cc_XY[256];
#if DEFINE_CB_TABLES
EXT	uint8 cc_CB[256];
EXT	uint8 cc_XYCB[256];
#endif


/*	the functions
	op2 and op4 evaluated only if required
*/
EXT	bool z80_opcode_can_branch(uint8 op1, uint8 op2);			// op2 only used if op1==0xED
EXT	uint z80_clock_cycles(uint8 op1, uint8 op2, uint8 op4);		// dito, op4 only for IXCB/IYCB
EXT	uint z80_clock_cycles_on_branch(uint8 op1, uint8 op2);		// op2 only used if op1==0xED






