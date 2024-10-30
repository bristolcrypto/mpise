#ifndef __UNITTEST_H
#define __UNITTEST_H

// ----------------------------------------------------------------------------

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include <inttypes.h>

// ----------------------------------------------------------------------------

#ifndef XLEN
#define XLEN 64
#endif

#ifndef MPISE_DESTRUCTIVE
#define MPISE_DESTRUCTIVE 0
#endif
#ifndef MPISE_STATELESS
#define MPISE_STATELESS   1
#endif

#if ( XLEN == 32 )
typedef     int32_t SINTSINGLE_t; 
typedef     int64_t SINTDOUBLE_t;
typedef    uint32_t UINTSINGLE_t; 
typedef    uint64_t UINTDOUBLE_t;
#define FORMAT(x) x "=%08X"
#endif
#if ( XLEN == 64 )
typedef     int64_t SINTSINGLE_t; 
typedef  __int128_t SINTDOUBLE_t;
typedef    uint64_t UINTSINGLE_t; 
typedef __uint128_t UINTDOUBLE_t;
#define FORMAT(x) x "=%016lX"
#endif

// ----------------------------------------------------------------------------

#endif
