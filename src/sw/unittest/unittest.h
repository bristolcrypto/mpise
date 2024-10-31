#ifndef __UNITTEST_H
#define __UNITTEST_H

// ============================================================================

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

#define MARKER_CODE "// "
#define MARKER_DATA "## "

#if ( XLEN == 32 )
typedef     int32_t SINT1W_t; 
typedef     int64_t SINT2W_t;
typedef    uint32_t UINT1W_t; 
typedef    uint64_t UINT2W_t;
#define FORMAT_DEC "%d"
#define FORMAT_HEX "0x%08X"
#endif
#if ( XLEN == 64 )
typedef     int64_t SINT1W_t; 
typedef  __int128_t SINT2W_t;
typedef    uint64_t UINT1W_t; 
typedef __uint128_t UINT2W_t;
#define FORMAT_DEC "%ld"
#define FORMAT_HEX "0x%016lX"
#endif

// ============================================================================

#endif
