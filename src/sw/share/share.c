/* Copyright (C) 2021 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include "share.h"

#if defined( MPISE_STDC_RAND )
static unsigned long int next = 1;

int rand() {
  next = next * 1103515245 + 12345; return ( unsigned int )( next / 65536 ) % 32768;
}

void srand( unsigned int seed ) {
    next = seed;
}
#endif
