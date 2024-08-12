#include "ise.h"

.global _test_macclu

_test_macclu :

// a0 = r
// a1 = x
// a2 = y
// a3 = z

#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
macclu a0, a1, a2, a3
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
macclu a0, a1, a2, a3, 0x2
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
macclu a0, a1, a2
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
macclu a0, a1, a2,     0x2
#endif
#endif

ret
