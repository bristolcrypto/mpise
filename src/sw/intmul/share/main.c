#include "rdtsc.h"
#include "intarith.h"

#define DEBUG 0

#ifndef TRIALS
#define TRIALS 1000
#endif

#define MIN_WORDS  8
#define MAX_WORDS 64
#define WORD_STEP  4

uint64_t a[   MAX_WORDS ];
uint64_t b[   MAX_WORDS ];
uint64_t r[ 2*MAX_WORDS ]; 
#if DEBUG
uint64_t x[ 2*MAX_WORDS ];
#endif

int main( int argc, char* argv[] ) {
  #if defined( MPISE_RADIX_REDUCED ) && defined( MPISE_ISE ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "csrrwi x0, 0x801, 0xF" ); // imm = c = 15 => radix = (w-15)+c = (64-15)+15 = 64
  #endif
  
  // initialise
  mpi_init(a, AWORD, ALL1WORD, MAX_WORDS);
  mpi_init(b, BWORD, ALL1WORD, MAX_WORDS);
  
  for( int j = MIN_WORDS; j <= MAX_WORDS; j += WORD_STEP ) {
    unsigned long long rdtsc_x   =  0;
    unsigned long long rdtsc_y   =  0;
    unsigned long long rdtsc_r   =  0;

    unsigned long long rdtsc_min = -1;
    unsigned long long rdtsc_max =  0;
    unsigned long long rdtsc_avr =  0;

    // warm
    for( int i = 0; i < TRIALS; i++ ) {
      int_mul4x4_asm( r, a, b, j );
    }

    // execute
    for( int i = 0; i < TRIALS; i++ ) {
      rdtsc_x = rdtsc();
      int_mul4x4_asm( r, a, b, j );
      rdtsc_y = rdtsc();

      rdtsc_r = rdtsc_y - rdtsc_x;

      rdtsc_min = ( rdtsc_r <= rdtsc_min ) ? rdtsc_r : rdtsc_min;
      rdtsc_max = ( rdtsc_r >= rdtsc_min ) ? rdtsc_r : rdtsc_max;
      rdtsc_avr =                            rdtsc_r + rdtsc_avr;
    }

    rdtsc_avr /= TRIALS;

    // report
    printf("! %d, %d, %d, %lld, %lld, %lld\n", TRIALS, LIMBBITS, j, rdtsc_min, rdtsc_max, rdtsc_avr );

    // test/debug
    #if DEBUG
    // mpi_print("  r  = 0x", r, 2*j);
    mpi_mul_1x1fr_isa(x, a, b, j);  // C implementation
    if (mpi_compare(r, x, 2*j) == 0) {
      printf("  result is correct!\n");
    } else {
      printf("  result is wrong!!!\n");
    }
    memset(r, 0, 2*j*sizeof(uint64_t));
    #endif
  }
  
  return 0;
}

