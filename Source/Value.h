/*	Copyright  (c)	Günter Woigk 2017 - 2020
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

#ifndef Value_h
#define Value_h
#include "kio/kio.h"
#include "SyntaxError.h"
#include "Templates/Array.h"


enum Validity
{
	invalid,		// not yet defined or definition based on invalid value
	preliminary,	// defined but subject to final position/size of code
	valid			// fully valid
};


class Value
{
	void	chkv (Validity v)	{ if(v<validity) validity = v; }

public:
	int32	 value;
	Validity validity;

			 Value()					:value(0),validity(invalid){}
	explicit Value(int32 n)				:value(n),validity(valid){}
			 Value(int32 n, Validity v)	:value(n),validity(v){}

	//operator int32() const  	{ return value; }	// auto-cast to int32
	operator int() const		{ return value; }	// auto-cast to int32

	void	set	(int32 n, Validity v) { value = n; validity = v; }

	bool	is_valid ()			const { return validity == valid;   }
	bool	is_invalid ()		const { return validity == invalid; }
	bool	is_preliminary ()	const { return validity == preliminary; }


	void	BOOL()				{ value = !!value; }
	void	NOT ()				{ value = !value; }
	void	cpl ()				{ value = ~value; }
	void	neg	()				{ value = -value; }	// validity check optional
	void	pos	()				{ value = +value; }	// for completeness

	void	ge	(int32 n, Validity v) { value = value >= n; chkv(v); }
	void	le	(int32 n, Validity v) { value = value <= n; chkv(v); }
	void	ne	(int32 n, Validity v) { value = value != n; chkv(v); }
	void	gt	(int32 n, Validity v) { value = value >  n; chkv(v); }
	void	lt	(int32 n, Validity v) { value = value <  n; chkv(v); }
	void	eq	(int32 n, Validity v) { value = value == n; chkv(v); }
	void	sr	(int32 n, Validity v) { value >>= n; chkv(v); }
	void	sl	(int32 n, Validity v) { value <<= n; chkv(v); }
	void	AND (int32 n, Validity v) { value &= n; chkv(v); }
	void	OR  (int32 n, Validity v) { value |= n; chkv(v); }
	void	XOR (int32 n, Validity v) { value ^= n; chkv(v); }
	void	add (int32 n, Validity v) { value += n; chkv(v); }
	void	sub (int32 n, Validity v) { value -= n; chkv(v); }
	void	mul (int32 n, Validity v) { value *= n; chkv(v); }
	void	div (int32 n, Validity v) throws; // throw(any_error);
	void	rem (int32 n, Validity v) throws; // throw(any_error);

	void	set (Value const& v)	{ set(v.value,v.validity); }
	void	ge  (Value const& v)	{ ge (v.value,v.validity); }
	void	le  (Value const& v)	{ le (v.value,v.validity); }
	void	ne  (Value const& v)	{ ne (v.value,v.validity); }
	void	gt  (Value const& v)	{ gt (v.value,v.validity); }
	void	lt  (Value const& v)	{ lt (v.value,v.validity); }
	void	eq  (Value const& v)	{ eq (v.value,v.validity); }
	void	sr	(Value const& v)	{ sr (v.value,v.validity); }
	void	sl	(Value const& v)	{ sl (v.value,v.validity); }
	void	AND (Value const& v)	{ AND(v.value,v.validity); }
	void	OR  (Value const& v)	{ OR (v.value,v.validity); }
	void	XOR (Value const& v)	{ XOR(v.value,v.validity); }
	void	add (Value const& v)	{ add(v.value,v.validity); }
	void	sub (Value const& v)	{ sub(v.value,v.validity); }
	void	mul (Value const& v)	{ mul(v.value,v.validity); }
	void	div (Value const& v)	{ div(v.value,v.validity); }
	void	rem (Value const& v)	{ rem(v.value,v.validity); }

	//void	operator =	(Value const& v) { value = v.value; validity = v.validity; }
	void	operator <<=(Value const& v) { sl (v.value,v.validity); }
	void	operator >>=(Value const& v) { sr (v.value,v.validity); }
	void	operator &= (Value const& v) { AND(v.value,v.validity); }
	void	operator |= (Value const& v) { OR (v.value,v.validity); }
	void	operator ^= (Value const& v) { XOR(v.value,v.validity); }
	void	operator += (Value const& v) { add(v.value,v.validity); }
	void	operator -= (Value const& v) { sub(v.value,v.validity); }
	void	operator *= (Value const& v) { mul(v.value,v.validity); }
	void	operator /= (Value const& v) { div(v.value,v.validity); }
	void	operator %= (Value const& v) { rem(v.value,v.validity); }

	Value&	operator =	(int32 n) { value=n; validity=valid; return *this; }
	void	operator <<=(int32 v) { sl (v,valid); }
	void	operator >>=(int32 v) { sr (v,valid); }
	void	operator &= (int32 v) { AND(v,valid); }
	void	operator |= (int32 v) { OR (v,valid); }
	void	operator ^= (int32 v) { XOR(v,valid); }
	void	operator += (int32 v) { add(v,valid); }
	void	operator -= (int32 v) { sub(v,valid); }
	void	operator *= (int32 v) { mul(v,valid); }
	void	operator /= (int32 v) { div(v,valid); }
	void	operator %= (int32 v) { rem(v,valid); }

	Value	operator ~  ()	const { return Value(~value, validity); }
	Value	operator !  ()	const { return Value(!value, validity); }
	Value	operator +  ()	const { return Value(+value, validity); }
	Value	operator -  ()	const { return Value(-value, validity); }

	Value	operator +  (Value const& q) const { return Value(value +  q.value, min(validity,q.validity)); }
	Value	operator -  (Value const& q) const { return Value(value -  q.value, min(validity,q.validity)); }
	Value	operator *  (Value const& q) const { return Value(value *  q.value, min(validity,q.validity)); }
	Value	operator /  (Value const& q) const { return Value(value /  q.value, min(validity,q.validity)); }
	Value	operator %  (Value const& q) const { return Value(value %  q.value, min(validity,q.validity)); }
	Value	operator &  (Value const& q) const { return Value(value &  q.value, min(validity,q.validity)); }
	Value	operator |  (Value const& q) const { return Value(value |  q.value, min(validity,q.validity)); }
	Value	operator ^  (Value const& q) const { return Value(value ^  q.value, min(validity,q.validity)); }
	Value	operator << (Value const& q) const { return Value(value << q.value, min(validity,q.validity)); }
	Value	operator >> (Value const& q) const { return Value(value >> q.value, min(validity,q.validity)); }
	Value	operator == (Value const& q) const { return Value(value == q.value, min(validity,q.validity)); }
	Value	operator >= (Value const& q) const { return Value(value >= q.value, min(validity,q.validity)); }
	Value	operator <= (Value const& q) const { return Value(value <= q.value, min(validity,q.validity)); }
	Value	operator >  (Value const& q) const { return Value(value >  q.value, min(validity,q.validity)); }
	Value	operator <  (Value const& q) const { return Value(value <  q.value, min(validity,q.validity)); }
	Value	operator != (Value const& q) const { return Value(value != q.value, min(validity,q.validity)); }
};


inline Value min (Value const& a, Value const& b)
{
	return Value(min(a.value,b.value),min(a.validity,b.validity));
}

inline Value max (Value const& a, Value const& b)
{
	return Value(max(a.value,b.value),min(a.validity,b.validity));
}

class Values : public Array<Value>
{
public:
	Validity validity() const
	{
		Validity v = Validity::valid;
		uint i = 0;
		while (i<cnt && v==valid) v = data[i++].validity;
		while (i<cnt && v==preliminary) v = data[i++].validity;
		return v;
	}

	Values& operator << (Value q) throws { append(std::move(q)); return *this; }
};


#endif
