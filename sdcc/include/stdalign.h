

/* kio 2014-11-26	this file defines things required for c++11
					why?
*/


#ifndef _STDALIGN_H
#define _STDALIGN_H 1

#ifndef __alignas_is_defined
#define __alignas_is_defined 1

#define alignas _Alignas		/* seems to be required for c++11 */

#endif


#ifndef __alignof_is_defined
#define __alignof_is_defined 1

#define alignof _Alignof		/* seems to be required for c++11 */

#endif

#endif

