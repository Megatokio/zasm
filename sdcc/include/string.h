/*-------------------------------------------------------------------------
   string.h - ISO header for string library functions

   Copyright (C) 1998, Sandeep Dutta
   Copyright (C) 2009-2011, Philipp Klaus Krause pkk@spth.de

   This library is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this library; see the file COPYING. If not, write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.

   As a special exception, if you link this library with other files,
   some of which are compiled with SDCC, to produce an executable,
   this library does not by itself cause the resulting executable to
   be covered by the GNU General Public License. This exception does
   not however invalidate any other reasons why the executable file
   might be covered by the GNU General Public License.
-------------------------------------------------------------------------*/

// kio 2014-11-26	removed test for other targets than z80


#ifndef _STRING_H
#define _STRING_H 1

#ifndef NULL
# define NULL (void *)0
#endif

#ifndef __SIZE_T_DEFINED
# define __SIZE_T_DEFINED
  typedef unsigned int size_t;
#endif

/* Bounds-checking interfaces from annex K of the C11 standard. */
#if defined (__STDC_WANT_LIB_EXT1__) && __STDC_WANT_LIB_EXT1__

#ifndef __RSIZE_T_DEFINED
#define __RSIZE_T_DEFINED
typedef size_t rsize_t;
#endif

#ifndef __ERRNO_T_DEFINED
#define __ERRNO_T_DEFINED
typedef int errno_t;
#endif

#endif

/* The function prototypes are ordered as in the ISO C99 standard. */

/* Todo: fix the "restrict" stuff for C99 compliance. */

/* Copying functions: */
extern void *memcpy (void * /*restrict */ dest, const void * /*restrict*/ src, size_t n);
extern void *memmove (void *dest, const void *src, size_t n);
extern char *strcpy (char * /*restrict*/ dest, const char * /*restrict*/ src);
extern char *strncpy(char * /*restrict*/ dest, const char * /*restrict*/ src, size_t n);

/* Concatenation functions: */
extern char *strcat (char * /*restrict*/ dest, const char * /*restrict*/ src);
extern char *strncat(char * /*restrict*/ dest, const char * /*restrict*/ src, size_t n);

/* Comparison functions: */
extern int memcmp (const void *s1, const void *s2, size_t n);
extern int strcmp (const char *s1, const char *s2);
#define strcoll(s1, s2) strcmp(s1, s2)
/*int strcoll(const char *s1, const char *s2) {return strcmp(s1, s2);}*/
extern int strncmp(const char *s1, const char *s2, size_t n);
extern size_t strxfrm(char *dest, const char *src, size_t n);

/* Search functions: */
extern void *memchr (const void *s, int c, size_t n);
extern char *strchr (const char *s, int c);
extern size_t strcspn(const char *s, const char *reject);
extern char *strpbrk(const char *s, const char *accept);
extern char *strrchr(const char *s, int c);
extern size_t strspn (const char *s, const char *accept);
extern char *strstr (const char *haystack, const char *needle);
extern char *strtok (char * /* restrict*/ str, const char * /*restrict*/ delim);

/* Miscanelleous functions: */
extern void *memset (void *s, int c, size_t n);

/* extern char *strerror(int errnum); */
extern size_t strlen (const char *s);

#define memcpy(dst, src, n) 	__builtin_memcpy(dst, src, n)
#define strcpy(dst, src) 		__builtin_strcpy(dst, src)
#define strncpy(dst, src, n) 	__builtin_strncpy(dst, src, n)
#define strchr(s, c) 			__builtin_strchr(s, c)
#define memset(dst, c, n) 		__builtin_memset(dst, c, n)


#endif
