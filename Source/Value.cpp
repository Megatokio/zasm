// Copyright (c) 2017 - 2024 kio@little-bat.de
// BSD-2-Clause license
// https://opensource.org/licenses/BSD-2-Clause

#include "Value.h"
#include "kio/kio.h"


Value Value::operator/(cValue& q) const
{
	Validity v = min(validity, q.validity);
	int32	 n = q.value;

	if (n) return Value(value / n, v);

	if (q.is_valid()) throw AnyError(EDOM, "division by zero");
	return Value(n < 0 ? int32(0x80000000) : 0x7FFFFFFF, v);
}

Value Value::operator%(cValue& q) const
{
	Validity v = min(validity, q.validity);
	int32	 n = q.value;

	if (n) return Value(value % n, v);

	if (q.is_valid()) throw AnyError(EDOM, "division by zero");
	return Value(0, v);
}
