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
public:
	int32	 value;
	Validity validity;

			 Value()					:value(0),validity(invalid){}
	explicit Value(int32 n)				:value(n),validity(valid){}
			 Value(int32 n, Validity v)	:value(n),validity(v){}

	Value& operator= (int n) { value = n; validity = valid; return *this; }

	template<typename T>
	explicit operator T() const	{ return T(value); }

	bool	is_valid ()			const { return validity == valid;   }
	bool	is_invalid ()		const { return validity == invalid; }
	bool	is_preliminary ()	const { return validity == preliminary; }

	// used in value() since comparator operators return bool (not Value):
	void	ge  (cValue& v)	{ value = value >= v.value; validity = min(validity,v.validity); }
	void	le  (cValue& v)	{ value = value <= v.value; validity = min(validity,v.validity); }
	void	ne  (cValue& v)	{ value = value != v.value; validity = min(validity,v.validity); }
	void	gt  (cValue& v)	{ value = value >  v.value; validity = min(validity,v.validity); }
	void	lt  (cValue& v)	{ value = value <  v.value; validity = min(validity,v.validity); }
	void	eq  (cValue& v)	{ value = value == v.value; validity = min(validity,v.validity); }

	// mostly used in value():
	void	operator += (cValue& v) { value += v.value; validity = min(validity,v.validity); }
	void	operator -= (cValue& v) { value -= v.value; validity = min(validity,v.validity); }
	void	operator *= (cValue& v) { value *= v.value; validity = min(validity,v.validity); }
	void	operator /= (cValue& v) { value /= v.value; validity = min(validity,v.validity); }
	void	operator %= (cValue& v) { value %= v.value; validity = min(validity,v.validity); }
	void	operator &= (cValue& v) { value &= v.value; validity = min(validity,v.validity); }
	void	operator |= (cValue& v) { value |= v.value; validity = min(validity,v.validity); }
	void	operator ^= (cValue& v) { value ^= v.value; validity = min(validity,v.validity); }

	// used in value():
	Value	operator ~  ()	const { return Value(~value, validity); }
	Value	operator !  ()	const { return Value(!value, validity); }
	Value	operator +  ()	const { return Value(+value, validity); }
	Value	operator -  ()	const { return Value(-value, validity); }

	// general use:
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

	// general use. attn: return bool not Value, validity ignored:
	bool 	operator == (cValue& q) const { return value == q.value; }
	bool 	operator >= (cValue& q) const { return value >= q.value; }
	bool 	operator <= (cValue& q) const { return value <= q.value; }
	bool 	operator >  (cValue& q) const { return value >  q.value; }
	bool 	operator <  (cValue& q) const { return value <  q.value; }
	bool 	operator != (cValue& q) const { return value != q.value; }
};


inline Value operator +  (cValue& v, int q) { return Value(v.value + q, v.validity); }
inline Value operator -  (cValue& v, int q) { return Value(v.value - q, v.validity); }
inline Value operator &  (cValue& v, int q) { return Value(v.value & q, v.validity); }
inline Value operator |  (cValue& v, int q) { return Value(v.value | q, v.validity); }
inline Value operator ^  (cValue& v, int q) { return Value(v.value ^ q, v.validity); }
inline Value operator *  (cValue& v, int q) { return Value(v.value * q, v.validity); }
inline Value operator /  (cValue& v, int q) { return Value(v.value / q, v.validity); }
inline Value operator %  (cValue& v, int q) { return Value(v.value % q, v.validity); }

inline Value operator +  (int q, cValue& v) { return Value(q + v.value, v.validity); }
inline Value operator -  (int q, cValue& v) { return Value(q - v.value, v.validity); }
inline Value operator &  (int q, cValue& v) { return Value(q & v.value, v.validity); }
inline Value operator |  (int q, cValue& v) { return Value(q | v.value, v.validity); }
inline Value operator ^  (int q, cValue& v) { return Value(q ^ v.value, v.validity); }
inline Value operator *  (int q, cValue& v) { return Value(q * v.value, v.validity); }
inline Value operator /  (int q, cValue& v) { return Value(q / v.value, v.validity); }
inline Value operator %  (int q, cValue& v) { return Value(q % v.value, v.validity); }


inline bool  operator == (cValue& v, int q) { return v.value == q; }
inline bool  operator != (cValue& v, int q) { return v.value != q; }
inline bool  operator >= (cValue& v, int q) { return v.value >= q; }
inline bool  operator <= (cValue& v, int q) { return v.value <= q; }
inline bool  operator >  (cValue& v, int q) { return v.value >  q; }
inline bool  operator <  (cValue& v, int q) { return v.value <  q; }

inline bool  operator == (int q, cValue& v) { return q == v.value; }
inline bool  operator != (int q, cValue& v) { return q != v.value; }
inline bool  operator >= (int q, cValue& v) { return q >= v.value; }
inline bool  operator <= (int q, cValue& v) { return q <= v.value; }
inline bool  operator >  (int q, cValue& v) { return q >  v.value; }
inline bool  operator <  (int q, cValue& v) { return q <  v.value; }


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












