/*
 * (c) Copyright 2012-2016 by Einar Saukas. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *	 * Redistributions of source code must retain the above copyright
 *	   notice, this list of conditions and the following disclaimer.
 *	 * Redistributions in binary form must reproduce the above copyright
 *	   notice, this list of conditions and the following disclaimer in the
 *	   documentation and/or other materials provided with the distribution.
 *	 * The name of its author may not be used to endorse or promote products
 *	   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*	data types modified to integrate with zasm source
	kio 2017 - 2020
*/

#include "zx7.h"
#include <stdio.h>
#include <stdlib.h>


#define MAX_OFFSET  2176  /* range 1..2176 */
#define MAX_LEN	65536  /* range 2..65536 */

typedef struct optimal_t
{
	uint32 bits;
	int	offset;
	int	len;
} Optimal;

static int elias_gamma_bits(int value)
{
	int bits = 1;
	while (value > 1)
	{
		bits += 2;
		value >>= 1;
	}
	return bits;
}

static int count_bits(int offset, int len)
{
	return 1 + (offset > 128 ? 12 : 8) + elias_gamma_bits(len-1);
}

Optimal* optimize(const Array<uint8>& ibu, uint32 skip)
{
	uint32 *min;
	uint32 *max;
	uint32 *matches;
	uint32 *match_slots;
	Optimal*optimal;
	uint32 *match;
	int	match_index;
	int	offset;
	uint32 len;
	uint32 best_len;
	uint32 bits;
	uint32 i;

	const uint8* input_data = ibu.getData();
	uint32 input_size = ibu.count();

	/* allocate all data structures at once */
	min = new uint32[MAX_OFFSET+1];			memset(min,0,(MAX_OFFSET+1)*sizeof(uint32));
	max = new uint32[MAX_OFFSET+1];			memset(max,0,(MAX_OFFSET+1)*sizeof(uint32));
	matches = new uint32[256*256];			memset(matches,0,(256*256)*sizeof(uint32));
	match_slots = new uint32[input_size];	memset(match_slots,0,input_size*sizeof(uint32));
	optimal = new Optimal[input_size];		memset(optimal,0,input_size*sizeof(Optimal));

	/* index skipped bytes */
	for (i = 1; i <= skip; i++)
	{
		match_index = input_data[i-1] << 8 | input_data[i];
		match_slots[i] = matches[match_index];
		matches[match_index] = i;
	}

	/* first byte is always literal */
	optimal[skip].bits = 8;

	/* process remaining bytes */
	for (; i < input_size; i++)
	{
		optimal[i].bits = optimal[i-1].bits + 9;
		match_index = input_data[i-1] << 8 | input_data[i];
		best_len = 1;
		for (match = &matches[match_index]; *match != 0 && best_len < MAX_LEN; match = &match_slots[*match])
		{
			offset = i - *match;
			if (offset > MAX_OFFSET) { *match = 0; break; }

			for (len = 2; len <= MAX_LEN && i >= skip+len; len++)
			{
				if (len > best_len)
				{
					best_len = len;
					bits = optimal[i-len].bits + count_bits(offset, len);
					if (optimal[i].bits > bits)
					{
						optimal[i].bits = bits;
						optimal[i].offset = offset;
						optimal[i].len = len;
					}
				}
				else if (max[offset] != 0 && i+1 == max[offset]+len)
				{
					len = i-min[offset];
					if (len > best_len) { len = best_len; }
				}
				if (i < offset+len || input_data[i-len] != input_data[i-len-offset]) { break; }
			}
			min[offset] = i+1-len;
			max[offset] = i;
		}
		match_slots[i] = matches[match_index];
		matches[match_index] = i;
	}

	delete[] min;
	delete[] max;
	delete[] matches;
	delete[] match_slots;

	return optimal;
}




static uint8* output_data;
static uint32 output_index;
static uint32 bit_index;
static int	bit_mask;
static int32  diff;

static void read_bytes(int n, int32* delta)
{
   diff += n;
   if (diff > *delta)
	   *delta = diff;
}

static void write_byte(int value)
{
	output_data[output_index++] = value;
	diff--;
}

static void write_bit(int value)
{
	if (bit_mask == 0)
	{
		bit_mask = 128;
		bit_index = output_index;
		write_byte(0);
	}
	if (value > 0)
	{
		output_data[bit_index] |= bit_mask;
	}
	bit_mask >>= 1;
}

static void write_elias_gamma(int value)
{
	int i;

	for (i = 2; i <= value; i <<= 1)
	{
		write_bit(0);
	}
	while ((i >>= 1) > 0)
	{
		write_bit(value & i);
	}
}


Array<uint8> compress(const Array<uint8>& ibu, uint32 skip, int32* delta)
{
	uint32 input_index;
	uint32 input_prev;
	int offset1;
	int mask;
	int i;

	uint8 const* input_data = ibu.getData();

	Optimal* optimal = optimize(ibu, skip);

	/* calculate and allocate output buffer */
	input_index = ibu.count()-1;
	Array<uint8> obu((optimal[input_index].bits+18+7)/8);
	output_data = obu.getData();

	/* initialize delta */
	diff = obu.count() - ibu.count() + skip;
	*delta = 0;

	/* un-reverse optimal sequence */
	optimal[input_index].bits = 0;
	while (input_index != skip)
	{
		input_prev = input_index - (optimal[input_index].len > 0 ? optimal[input_index].len : 1);
		optimal[input_prev].bits = input_index;
		input_index = input_prev;
	}

	output_index = 0;
	bit_mask = 0;

	/* first byte is always literal */
	write_byte(input_data[input_index]);
	read_bytes(1, delta);

	/* process remaining bytes */
	while ((input_index = optimal[input_index].bits) > 0)
	{
		if (optimal[input_index].len == 0)
		{
			/* literal indicator */
			write_bit(0);

			/* literal value */
			write_byte(input_data[input_index]);
			read_bytes(1, delta);

		}
		else
		{
			/* sequence indicator */
			write_bit(1);

			/* sequence length */
			write_elias_gamma(optimal[input_index].len-1);

			/* sequence offset */
			offset1 = optimal[input_index].offset-1;
			if (offset1 < 128)
			{
				write_byte(offset1);
			}
			else
			{
				offset1 -= 128;
				write_byte((offset1 & 127) | 128);
				for (mask = 1024; mask > 127; mask >>= 1)
				{
					write_bit(offset1 & mask);
				}
			}
			read_bytes(optimal[input_index].len, delta);
		}
	}

	/* sequence indicator */
	write_bit(1);

	/* end marker > MAX_LEN */
	for (i = 0; i < 16; i++) { write_bit(0); }
	write_bit(1);

	delete[] optimal;
	return obu;
}














