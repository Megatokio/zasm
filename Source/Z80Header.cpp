/*	Copyright  (c)	Günter Woigk 2002 - 2021
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
*/

#include "Z80Header.h"



Model Z80Header::getZxspModel ()
{
	// get zxsp-style model id from header data
	// returns -1 on error or not supported

    if (isVersion145())
    {
        return im&4 ? zxsp_i2 : zxsp_i3;
    }

	uint8 model = this->model;

    if (isVersion201())
    {
		//	model:        Meaning in v2           Meaning in v3
		//	-----------------------------------------------------
		//	0             48k                     48k
		//	1             48k + If.1              48k + If.1
		//	2             SamRam                  SamRam
		//	3             128k                    48k + M.G.T.
		//	4             128k + If.1             128k
		//	5             -                       128k + If.1
		//	6             -                       128k + M.G.T.

		if (model==3||model==4) model += 1;
    }

	// Version 3.0 and later:

	//	model:          Meaning
	//	-----------------------------------------------------
	//	  7             Spectrum +3
	//	  8             [mistakenly used by some versions of XZX-Pro to indicate a +3]
	//	  9             Pentagon (128K)
	//    10            Scorpion (256K)
	//    11            Didaktik-Kompakt
	//    12            Spectrum +2
	//    13            Spectrum +2A
	//    14            TC2048
	//    15            TC2068
	//   128            TS2068

	// While most emulators using these extensions write version 3 files, some write version 2 files
	// so it's probably best to assume any of these values can be seen in either version 2 or version 3 files.

	//  rldiremu    Bit 7 = 1: Modify hardware
	//				If bit 7 is set, the hardware types are modified slightly:
	//				any 48K machine becomes a 16K machine,
	//				any 128K machines becomes a +2
	//				and any +3 machine becomes a +2A.
	//	im          Bit 2 = 1: Issue2 emulation

    switch (model)
    {
    case 2:     //return -1;				// SamRam
    case 0:
    case 1:
    case 3:		// 46k, modify hw: 16k
				return rldiremu>>7 ? zxsp_i1 : im&4 ? zxsp_i2 : (rldiremu>>5)&1 ? zxplus : zxsp_i3;

    case 4:
    case 5:
    case 6:     return rldiremu>>7 ? zxplus2 : zx128;                       // 128, modify hw: +2

    case 7:
    case 8:     return rldiremu>>7 ? zxplus2a : zxplus3;                    // +3, modify hw: +2A

    case 9:     return pentagon128;		// Pentagon 128k
    case 10:    return scorpion;        // Scorpion 256k
    case 11:    return unknown_model;	// Didaktik-Kompakt
    case 12:    return zxplus2;
    case 13:    return zxplus2a;
    case 14:    return tc2048;
    case 15:    return tc2068;

	case 76:	return tk85;			// TK85			(kio)
    case 77:    return ts1000;			// TS1000		(kio)
    case 78:    return ts1500;			// TS1500		(kio)
    case 80:    return zx80;            // ZX80			(kio)
    case 81:    return zx81;            // ZX81			(kio)
    case 83:    return jupiter;         // Jupiter ACE  (kio)
    case 84:    return inves;           // Inves 48k	(kio)
    case 85:    return zx128_span;      // +128 Span.	(kio)
    case 86:    return samcoupe;        // Sam Coupé	(kio)
    case 87:    return zxplus2_span;    // +2 Spanish	(kio)
    case 88:    return zxplus2_frz;		// +2 French	(kio)
    case 89:    return zxplus3_span;    // +3 Spanish	(kio)
    case 90:    return zxplus2a_span;   // +2A Spanish	(kio)
    case 91:	return tk90x;			// TK90X		(kio)
    case 92:	return tk95;			// TK95			(kio)
    case 128:   return ts2068;

	default:	return unknown_model;
    }
}

uint32 Z80Header::getRamsize ()
{
	// get required ramsize for machine
	// returns 0 for default ram size

	uint model = this->model;
    if (isVersion201() && (model==3||model==4)) model += 1;
	if (model<=3) return rldiremu>>7 ? 16 kB : 48 kB;
	if (varyingRamsize()) return spectator * 1 kB;
	return 0;
}

int32 Z80Header::getCpuCycle (int cc_per_frame)
{
	// decode cc from t_l, t_m and t_h fields

    int32 cc_per_4th = cc_per_frame/4;
    int32 n = ((t_h-3)&3) * cc_per_4th + cc_per_4th -1 - uint16(t_m*256+t_l);
    limit(0, n, cc_per_frame);
    return n;
}





















