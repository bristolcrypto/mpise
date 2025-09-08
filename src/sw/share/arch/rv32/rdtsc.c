/* Copyright (C) 2021 SCARV project <info@scarv.org>
 *
 * Use of this source code is restricted per the MIT license, a copy of which 
 * can be found at https://opensource.org/licenses/MIT (or should be included 
 * as LICENSE.txt within the associated archive or repository).
 */

#include "rdtsc.h"

uint64_t rdtsc() {
  uint32_t t, tsc_lo = 0, tsc_hi = 0;

  __asm__ __volatile__( "1: rdcycleh %0    ;"
                        "   rdcycle  %1    ;"
                        "   rdcycleh %2    ;"
                        "   bne %0, %2, 1b ;" : "=r" (t), "=r" (tsc_lo), "=r" (tsc_hi) );

  return ( ( uint64_t )( tsc_lo ) <<  0 ) |
         ( ( uint64_t )( tsc_hi ) << 32 ) ;
}

uint64_t rdinstr() {
  uint32_t hi1, lo, hi2;

  // This is the standard sequence to ensure an atomic 64-bit read on RV32
  __asm__ __volatile__( "1: rdinstreth %0   ;"  // Read the high 32 bits
                        "   rdinstret  %1   ;"  // Read the low 32 bits
                        "   rdinstreth %2   ;"  // Read the high 32 bits again
                        "   bne %0, %2, 1b ;"   // If high bits changed, retry
                        : "=r" (hi1), "=r" (lo), "=r" (hi2) );

  // Combine the 32-bit high and low parts into a 64-bit value
  return ( (uint64_t)hi2 << 32 ) | lo;
}
