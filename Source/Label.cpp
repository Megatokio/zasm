/*	Copyright  (c)	Günter Woigk 2014 - 2021
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

#include "Label.h"


// --------------------------------------------
//				Label
// --------------------------------------------


Label::Label (cstr name, Segment* segment, uint sourceline, int32 value, Validity validity,
			  bool is_global, bool is_defined, bool is_used)
:
	name(name),
	segment(segment),
	sourceline(sourceline),
	value(value,validity),
	is_global(is_global),
	is_defined(is_defined),
	is_used(is_used),
	is_redefinable(no),
	was_redefined(no),
	is_reusable(no)
{}

Label::Label (cstr name, Segment* segment, uint sourceline, cValue& value,
			  bool is_global, bool is_defined, bool is_used)
:
	name(name),
	segment(segment),
	sourceline(sourceline),
	value(value),
	is_global(is_global),
	is_defined(is_defined),
	is_used(is_used),
	is_redefinable(no),
	was_redefined(no),
	is_reusable(no)
{}

Label::Label (Label const& q)
:
	name(q.name),
	segment(q.segment),
	sourceline(q.sourceline),
	value(q.value),
	is_global(q.is_global),
	is_defined(q.is_defined),
	is_used(q.is_used),
	is_redefinable(q.is_redefinable),
	was_redefined(q.was_redefined),
	is_reusable(q.is_reusable)
{}


























