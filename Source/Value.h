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
	invalid = 0,		// not yet defined or definition based on invalid value
	preliminary = 1,	// defined but subject to final position/size of code
	valid = 3,			// fully valid
};

// when testing with relational comparators,
// then operator '<' means 'worse than':
// invalid < preliminary < valid

inline Validity min (Validity a, Validity b) { return Validity(a&b); }	// that's the trick! :-)
inline Validity max (Validity a, Validity b) { return Validity(a|b); }	// probably not useful



using cValue = const class Value;

class Value
{
	void	chkv (Validity v)	{ validity = min(validity,v); }

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
	void	div (int32 n, Validity v) throws; // throw(AnyError);
	void	rem (int32 n, Validity v) throws; // throw(AnyError);

	void	set (cValue& v)	{ set(v.value,v.validity); }
	void	ge  (cValue& v)	{ ge (v.value,v.validity); }
	void	le  (cValue& v)	{ le (v.value,v.validity); }
	void	ne  (cValue& v)	{ ne (v.value,v.validity); }
	void	gt  (cValue& v)	{ gt (v.value,v.validity); }
	void	lt  (cValue& v)	{ lt (v.value,v.validity); }
	void	eq  (cValue& v)	{ eq (v.value,v.validity); }
	void	sr	(cValue& v)	{ sr (v.value,v.validity); }
	void	sl	(cValue& v)	{ sl (v.value,v.validity); }
	void	AND (cValue& v)	{ AND(v.value,v.validity); }
	void	OR  (cValue& v)	{ OR (v.value,v.validity); }
	void	XOR (cValue& v)	{ XOR(v.value,v.validity); }
	void	add (cValue& v)	{ add(v.value,v.validity); }
	void	sub (cValue& v)	{ sub(v.value,v.validity); }
	void	mul (cValue& v)	{ mul(v.value,v.validity); }
	void	div (cValue& v)	{ div(v.value,v.validity); }
	void	rem (cValue& v)	{ rem(v.value,v.validity); }

	//void	operator =	(cValue& v) { value = v.value; validity = v.validity; }
	void	operator <<=(cValue& v) { sl (v.value,v.validity); }
	void	operator >>=(cValue& v) { sr (v.value,v.validity); }
	void	operator &= (cValue& v) { AND(v.value,v.validity); }
	void	operator |= (cValue& v) { OR (v.value,v.validity); }
	void	operator ^= (cValue& v) { XOR(v.value,v.validity); }
	void	operator += (cValue& v) { add(v.value,v.validity); }
	void	operator -= (cValue& v) { sub(v.value,v.validity); }
	void	operator *= (cValue& v) { mul(v.value,v.validity); }
	void	operator /= (cValue& v) { div(v.value,v.validity); }
	void	operator %= (cValue& v) { rem(v.value,v.validity); }

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

	Value	operator +  (cValue& q) const { return Value(value +  q.value, min(validity,q.validity)); }
	Value	operator -  (cValue& q) const { return Value(value -  q.value, min(validity,q.validity)); }
	Value	operator *  (cValue& q) const { return Value(value *  q.value, min(validity,q.validity)); }
	Value	operator /  (cValue& q) const { return Value(value /  q.value, min(validity,q.validity)); }
	Value	operator %  (cValue& q) const { return Value(value %  q.value, min(validity,q.validity)); }
	Value	operator &  (cValue& q) const { return Value(value &  q.value, min(validity,q.validity)); }
	Value	operator |  (cValue& q) const { return Value(value |  q.value, min(validity,q.validity)); }
	Value	operator ^  (cValue& q) const { return Value(value ^  q.value, min(validity,q.validity)); }
	Value	operator << (cValue& q) const { return Value(value << q.value, min(validity,q.validity)); }
	Value	operator >> (cValue& q) const { return Value(value >> q.value, min(validity,q.validity)); }
	Value	operator == (cValue& q) const { return Value(value == q.value, min(validity,q.validity)); }
	Value	operator >= (cValue& q) const { return Value(value >= q.value, min(validity,q.validity)); }
	Value	operator <= (cValue& q) const { return Value(value <= q.value, min(validity,q.validity)); }
	Value	operator >  (cValue& q) const { return Value(value >  q.value, min(validity,q.validity)); }
	Value	operator <  (cValue& q) const { return Value(value <  q.value, min(validity,q.validity)); }
	Value	operator != (cValue& q) const { return Value(value != q.value, min(validity,q.validity)); }
};


inline Value min (cValue& a, cValue& b)
{
	return Value(min(a.value,b.value),min(a.validity,b.validity));
}

inline Value max (cValue& a, cValue& b)
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
