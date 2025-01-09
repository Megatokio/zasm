// Copyright (c) 2017 - 2025 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#ifndef Value_h
#define Value_h
#include "SyntaxError.h"
#include "Templates/Array.h"
#include "kio/kio.h"


enum Validity {
	invalid		= 0, // not yet defined or definition based on invalid value
	preliminary = 1, // defined but subject to final position/size of code
	valid		= 3, // fully valid
};

// when testing with relational comparators,
// then operator '<' means 'worse than':
// invalid < preliminary < valid

inline Validity min(Validity a, Validity b) { return Validity(a & b); } // that's the trick! :-)
inline Validity max(Validity a, Validity b) { return Validity(a | b); } // probably not useful


using cValue = const class Value;

class Value
{
public:
	int32	 value;
	Validity validity;

	Value() : value(0), validity(invalid) {}
	explicit Value(int32 n) : value(n), validity(valid) {}
	Value(int32 n, Validity v) : value(n), validity(v) {}

	Value& operator=(int n)
	{
		value	 = n;
		validity = valid;
		return *this;
	}

	template<typename T>
	explicit operator T() const
	{
		return T(value);
	}

	bool is_valid() const { return validity == valid; }
	bool is_invalid() const { return validity == invalid; }
	bool is_preliminary() const { return validity == preliminary; }

	// used in value() since comparator operators return bool (not Value):
	void ge(cValue& v)
	{
		value	 = value >= v.value;
		validity = min(validity, v.validity);
	}
	void le(cValue& v)
	{
		value	 = value <= v.value;
		validity = min(validity, v.validity);
	}
	void ne(cValue& v)
	{
		value	 = value != v.value;
		validity = min(validity, v.validity);
	}
	void gt(cValue& v)
	{
		value	 = value > v.value;
		validity = min(validity, v.validity);
	}
	void lt(cValue& v)
	{
		value	 = value < v.value;
		validity = min(validity, v.validity);
	}
	void eq(cValue& v)
	{
		value	 = value == v.value;
		validity = min(validity, v.validity);
	}

	// mostly used in value():
	void operator+=(cValue& v)
	{
		value += v.value;
		validity = min(validity, v.validity);
	}
	void operator-=(cValue& v)
	{
		value -= v.value;
		validity = min(validity, v.validity);
	}
	void operator*=(cValue& v)
	{
		value *= v.value;
		validity = min(validity, v.validity);
	}
	void operator/=(cValue& v) { *this = *this / v; } // { value /= v.value; validity = min(validity,v.validity); }
	void operator%=(cValue& v) { *this = *this % v; } // { value %= v.value; validity = min(validity,v.validity); }
	void operator&=(cValue& v)
	{
		value &= v.value;
		validity = min(validity, v.validity);
	}
	void operator|=(cValue& v)
	{
		value |= v.value;
		validity = min(validity, v.validity);
	}
	void operator^=(cValue& v)
	{
		value ^= v.value;
		validity = min(validity, v.validity);
	}

	// used in value():
	Value operator~() const { return Value(~value, validity); }
	Value operator!() const { return Value(!value, validity); }
	Value operator+() const { return Value(+value, validity); }
	Value operator-() const { return Value(-value, validity); }

	// general use:
	Value operator+(cValue& q) const { return Value(value + q.value, min(validity, q.validity)); }
	Value operator-(cValue& q) const { return Value(value - q.value, min(validity, q.validity)); }
	Value operator*(cValue& q) const { return Value(value * q.value, min(validity, q.validity)); }
	Value operator/(cValue& q) const; // { return Value(value /  q.value, min(validity,q.validity)); }
	Value operator%(cValue& q) const; // { return Value(value %  q.value, min(validity,q.validity)); }
	Value operator&(cValue& q) const { return Value(value & q.value, min(validity, q.validity)); }
	Value operator|(cValue& q) const { return Value(value | q.value, min(validity, q.validity)); }
	Value operator^(cValue& q) const { return Value(value ^ q.value, min(validity, q.validity)); }
	Value operator<<(cValue& q) const { return Value(value << q.value, min(validity, q.validity)); }
	Value operator>>(cValue& q) const { return Value(value >> q.value, min(validity, q.validity)); }

	// general use. attn: return bool not Value, validity ignored:
	bool operator==(cValue& q) const { return value == q.value; }
	bool operator>=(cValue& q) const { return value >= q.value; }
	bool operator<=(cValue& q) const { return value <= q.value; }
	bool operator>(cValue& q) const { return value > q.value; }
	bool operator<(cValue& q) const { return value < q.value; }
	bool operator!=(cValue& q) const { return value != q.value; }
};


inline Value operator+(cValue& v, int q) { return Value(v.value + q, v.validity); }
inline Value operator-(cValue& v, int q) { return Value(v.value - q, v.validity); }
inline Value operator&(cValue& v, int q) { return Value(v.value & q, v.validity); }
inline Value operator|(cValue& v, int q) { return Value(v.value | q, v.validity); }
inline Value operator^(cValue& v, int q) { return Value(v.value ^ q, v.validity); }
inline Value operator*(cValue& v, int q) { return Value(v.value * q, v.validity); }
inline Value operator/(cValue& v, int q) { return v / Value(q); }
inline Value operator%(cValue& v, int q) { return v % Value(q); }
inline Value operator<<(cValue& v, int q) { return Value(v.value << q, v.validity); }
inline Value operator>>(cValue& v, int q) { return Value(v.value >> q, v.validity); }

inline Value operator+(int q, cValue& v) { return Value(q + v.value, v.validity); }
inline Value operator-(int q, cValue& v) { return Value(q - v.value, v.validity); }
inline Value operator&(int q, cValue& v) { return Value(q & v.value, v.validity); }
inline Value operator|(int q, cValue& v) { return Value(q | v.value, v.validity); }
inline Value operator^(int q, cValue& v) { return Value(q ^ v.value, v.validity); }
inline Value operator*(int q, cValue& v) { return Value(q * v.value, v.validity); }
inline Value operator/(int q, cValue& v) { return Value(q) / v; }
inline Value operator%(int q, cValue& v) { return Value(q) % v; }


inline bool operator==(cValue& v, int q) { return v.value == q; }
inline bool operator!=(cValue& v, int q) { return v.value != q; }
inline bool operator>=(cValue& v, int q) { return v.value >= q; }
inline bool operator<=(cValue& v, int q) { return v.value <= q; }
inline bool operator>(cValue& v, int q) { return v.value > q; }
inline bool operator<(cValue& v, int q) { return v.value < q; }

inline bool operator==(int q, cValue& v) { return q == v.value; }
inline bool operator!=(int q, cValue& v) { return q != v.value; }
inline bool operator>=(int q, cValue& v) { return q >= v.value; }
inline bool operator<=(int q, cValue& v) { return q <= v.value; }
inline bool operator>(int q, cValue& v) { return q > v.value; }
inline bool operator<(int q, cValue& v) { return q < v.value; }


inline Value min(cValue& a, cValue& b) { return Value(min(a.value, b.value), min(a.validity, b.validity)); }

inline Value max(cValue& a, cValue& b) { return Value(max(a.value, b.value), min(a.validity, b.validity)); }

class Values : public Array<Value>
{
public:
	Validity validity() const
	{
		Validity v = Validity::valid;
		uint	 i = 0;
		while (i < cnt && v == valid) v = data[i++].validity;
		while (i < cnt && v == preliminary) v = data[i++].validity;
		return v;
	}

	Values& operator<<(Value q) throws
	{
		append(std::move(q));
		return *this;
	}
};


#endif
