#include "rdtsc.h"
#include "intarith.h"

#ifndef DEBUG
#define DEBUG 1
#endif

#ifndef TRIALS
#define TRIALS 1000
#endif

#if !defined( VERSION_SIMPLE ) && !defined( VERSION_HYBRID )
#define VERSION_HYBRID 1
#endif

#if   defined( MPISE_RADIX_FULL    )
#define MIN_LIMBS  8
#define MAX_LIMBS 64
#define LIMB_STEP  4
#elif defined( MPISE_RADIX_REDUCED )
#define MIN_LIMBS  8
#define MAX_LIMBS 72
#define LIMB_STEP  4
#endif

#if   defined( MPISE_ISA )
#define TYPE "isa"
#elif defined( MPISE_ISE )
#define TYPE "ise"
#endif

limb_t a[   MAX_LIMBS ];
limb_t b[   MAX_LIMBS ];
limb_t r[ 2*MAX_LIMBS ];
#if DEBUG
limb_t x[ 2*MAX_LIMBS ];
#endif

int main( int argc, char* argv[] ) {
  #if defined( MPISE_ISE ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "csrrwi x0, 0x801, " MPISE_RADIX_STR );
  #endif
  
  // initialise
  #if   defined( MPISE_RADIX_FULL    )
  mpi_init( a, AWORD, ALL1WORD, MAX_LIMBS );
  mpi_init( b, BWORD, ALL1WORD, MAX_LIMBS );
  #elif defined( MPISE_RADIX_REDUCED )
  mpi_init( a, AWORD, LIMBMASK, MAX_LIMBS );
  mpi_init( b, BWORD, LIMBMASK, MAX_LIMBS );
  #endif
  
  for( int j = MIN_LIMBS; j <= MAX_LIMBS; j += LIMB_STEP ) {
    #if defined( MPISE_ISA ) && defined( MPISE_RADIX_REDUCED )
    if( j > ( 1 << ( ( 2 * MPISE_XLEN ) - ( 2 * LIMBBITS ) ) ) ) { // ISA implementation maximum limbs bounded by 2^( 2*MPISE_XLEN - 2*LIMBBITS )
      continue;
    }
    #endif
    #if defined( MPISE_ISE ) && defined( MPISE_RADIX_REDUCED )
    if( j > ( 1 << ( (     MPISE_XLEN ) - (     LIMBBITS ) ) ) ) { // ISE implementation maximum limbs bounded by 2^(   MPISE_XLEN -   LIMBBITS )
      continue;
    }
    #endif

    unsigned long long rdtsc_x   =  0;
    unsigned long long rdtsc_y   =  0;
    unsigned long long rdtsc_r   =  0;

    unsigned long long rdtsc_min = -1;
    unsigned long long rdtsc_max =  0;
    unsigned long long rdtsc_avr =  0;

    // warm
    for( int i = 0; i < TRIALS; i++ ) {
      #if defined( VERSION_SIMPLE )
      int_mul1x1_asm( r, a, b, j );
      #endif
      #if defined( VERSION_HYBRID )
      int_mul4x4_asm( r, a, b, j );
      #endif
    }

    // execute
    for( int i = 0; i < TRIALS; i++ ) {
      rdtsc_x = rdtsc();
      #if defined( VERSION_SIMPLE )
      int_mul1x1_asm( r, a, b, j );
      #endif
      #if defined( VERSION_HYBRID )
      int_mul4x4_asm( r, a, b, j );
      #endif
      rdtsc_y = rdtsc();

      rdtsc_r = rdtsc_y - rdtsc_x;

      rdtsc_min = ( rdtsc_r <= rdtsc_min ) ? rdtsc_r : rdtsc_min;
      rdtsc_max = ( rdtsc_r >= rdtsc_max ) ? rdtsc_r : rdtsc_max;
      rdtsc_avr =                            rdtsc_r + rdtsc_avr;
    }

    rdtsc_avr /= TRIALS;

    // report
    #if   defined( MPISE_RADIX_FULL    )
    printf("! %d, %s, %d, %d, %d, %d, %d, %lld, %lld, %lld\n", LIMBBITS, TYPE, MPISE_XLEN, MPISE_DESTRUCTIVE, MPISE_STATELESS, j, j * MPISE_XLEN, rdtsc_min, rdtsc_max, rdtsc_avr );
    #elif defined( MPISE_RADIX_REDUCED )
    printf("! %d, %s, %d, %d, %d, %d, %d, %lld, %lld, %lld\n", LIMBBITS, TYPE, MPISE_XLEN, MPISE_DESTRUCTIVE, MPISE_STATELESS, j, j * LIMBBITS,   rdtsc_min, rdtsc_max, rdtsc_avr );
    #endif

    // test/debug
    #if DEBUG
    #if   defined( MPISE_RADIX_FULL    )
    mpi_mul_1x1fr_isa( x, a, b, j );
    #elif defined( MPISE_RADIX_REDUCED )
    mpi_mul_1x1rr_isa( x, a, b, j );
    #endif

    if( mpi_compare( r, x, 2 * j ) == 0 ) {
      printf( "  result is correct!\n" );
    } else {
      printf( "  result is wrong!!!\n" );
      mpi_print( "  a  = 0x", a, 1 * j );
      mpi_print( "  b  = 0x", b, 1 * j );
      mpi_print( "  r  = 0x", r, 2 * j );
      mpi_print( "  x  = 0x", x, 2 * j );
    }

    memset( r, 0, 2 * j * sizeof( limb_t ) );
    #endif
  }
  
  return 0;
}

