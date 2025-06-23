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
#if THRESHOLD_DEBUG
unsigned long long rdtsc_debug[TRIALS];
#endif
#if THRESHOLD_STATIC
#define THRESHOLD_ABSOLUTE 20000
unsigned long long rdtsc_trial[TRIALS];
#endif
#if THRESHOLD_DYNAMIC
#define THRESHOLD_WINDOW_SIZE 5
#define THRESHOLD_FACTOR 3
unsigned long long rdtsc_window[THRESHOLD_WINDOW_SIZE];
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

    int trials = 0;

    #if THRESHOLD_DYNAMIC
    int rdtsc_last_index=0;               	// index tracking the window's last element.
    unsigned long long rdtsc_last_value;  	// rdtsc element that is about to be evicted from the window
    unsigned long long rdtsc_avr_temp;    	// temp value of rdtsc window average
    unsigned long long rdtsc_avr_window = 0;    // current value of rdtsc window average
    // Initialize the window's elements to zero
    for (int i = 0; i < THRESHOLD_WINDOW_SIZE; i++) {
      rdtsc_window[i] = 0;
    }
    #endif
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

      #if THRESHOLD_DEBUG
      rdtsc_debug[i] = rdtsc_r;
      #endif // THRESHOLD_DEBUG

    #if THRESHOLD_STATIC
      if( rdtsc_r < THRESHOLD_ABSOLUTE ) {
        rdtsc_min  = ( rdtsc_r <= rdtsc_min ) ? rdtsc_r : rdtsc_min;
        rdtsc_max  = ( rdtsc_r >= rdtsc_max ) ? rdtsc_r : rdtsc_max;
        rdtsc_avr  =                            rdtsc_r + rdtsc_avr;
        trials    += 1;
      }
    #elif THRESHOLD_DYNAMIC
        rdtsc_last_value = (i==0) ? 0 : rdtsc_window[rdtsc_last_index];  // this value is zero for the first trial
        rdtsc_avr_temp  = rdtsc_avr_window + rdtsc_r - rdtsc_last_value; // 
        // After the first few trials, if rdtsc_r is greater than the moving average, then treat it as an outlier spike.
        if (i > THRESHOLD_WINDOW_SIZE  && THRESHOLD_FACTOR * rdtsc_avr_window < rdtsc_r * THRESHOLD_WINDOW_SIZE ) {
          // Discard this trial
          // Don't replace rdtsc_window[rdtsc_last_index] with rdtsc_r,
          // Don't advance rdtsc_last_index,
          // Don't adjust rdtsc_avr, don't adjust rdtsc_min and rdtsc_max
          // Don't adjust trials
	  printf(" Dynamic thresholding :: i = %d : rdtsc_r = %lld, rdtsc_avr = %lld\n", i, rdtsc_r, rdtsc_avr_temp / THRESHOLD_WINDOW_SIZE);
          rdtsc_window[rdtsc_last_index] = rdtsc_last_value;
          rdtsc_last_index  =  (rdtsc_last_index + 0) % THRESHOLD_WINDOW_SIZE;
          rdtsc_min         = rdtsc_min;
          rdtsc_max         = rdtsc_max;
          rdtsc_avr_window  = rdtsc_avr_window; // no change to window average
	  rdtsc_avr         = rdtsc_avr;
          trials           += 0;
        } else {
          rdtsc_window[rdtsc_last_index] = rdtsc_r;
          rdtsc_last_index  =  (rdtsc_last_index + 1) % THRESHOLD_WINDOW_SIZE;
          rdtsc_min  	    = ( rdtsc_r <= rdtsc_min ) ? rdtsc_r : rdtsc_min;
          rdtsc_max         = ( rdtsc_r >= rdtsc_max ) ? rdtsc_r : rdtsc_max;
          rdtsc_avr_window  = rdtsc_avr_temp; // update window average
	  rdtsc_avr         = rdtsc_avr + rdtsc_r; // update total average
          trials           += 1;
        }
    #else
      rdtsc_min = ( rdtsc_r <= rdtsc_min ) ? rdtsc_r : rdtsc_min;
      rdtsc_max = ( rdtsc_r >= rdtsc_max ) ? rdtsc_r : rdtsc_max;
      rdtsc_avr =                            rdtsc_r + rdtsc_avr;
      trials    += 1;
    #endif // THRESHOLD_STATIC || THRESHOLD_DYNAMIC
    }

    rdtsc_avr /= trials;

    // report
    #if   defined( MPISE_RADIX_FULL    )
    printf("! %d, %s, %d, %d, %d, %d, %d, %d, %d, %lld, %lld, %lld\n", LIMBBITS, TYPE, MPISE_XLEN, MPISE_DESTRUCTIVE, MPISE_STATELESS, j, j * MPISE_XLEN, TRIALS, trials, rdtsc_min, rdtsc_max, rdtsc_avr );
    #elif defined( MPISE_RADIX_REDUCED )
    printf("! %d, %s, %d, %d, %d, %d, %d, %d, %d, %lld, %lld, %lld\n", LIMBBITS, TYPE, MPISE_XLEN, MPISE_DESTRUCTIVE, MPISE_STATELESS, j, j * LIMBBITS,   TRIALS, trials, rdtsc_min, rdtsc_max, rdtsc_avr );
    #endif

    // test/debug

    #if THRESHOLD_DEBUG
    # if TRIALS < 100
    printf("\n! @ ");
    for (int j = 0; j < trials; j++) {
        printf(" %lld", rdtsc_debug[j] );
    }
    printf("\n");
    #else
    for (int i = 0; i < TRIALS/100; i++) {
        printf("\n! @ ");
        for (int j = 0; j < 100; j++) {
            printf(" %lld", rdtsc_debug[100*i + j] );
	}
    }
    printf("\n");
    #endif // TRIALS
    #endif // THRESHOLD_DEBUG
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

