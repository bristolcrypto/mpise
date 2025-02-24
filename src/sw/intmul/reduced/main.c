#include "rdtsc.h"
#include "intarith.h"


#define DEBUG 0

#define MIN_LIMBS 8
#define MAX_LIMBS 72
#define LIMB_STEP 4


// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void test_int_mul(void)
{
  uint64_t a[MAX_LIMBS], b[MAX_LIMBS], r[2*MAX_LIMBS], x[2*MAX_LIMBS];
  unsigned long long start_cycles, end_cycles, diff_cycles;
  int i, j;
  
  (void) x;  // to suppress a warning
  
  // initialization of operands
  mpi_init(a, AWORD, LIMBMASK, MAX_LIMBS);
  mpi_init(b, BWORD, LIMBMASK, MAX_LIMBS);
  
  printf("=============================================================\n");
  printf("timing measurements integer multiplication (reduced radix):\n");
  printf("=============================================================\n");
  
  for (j = MIN_LIMBS; j <= MAX_LIMBS; j += LIMB_STEP) {
    LOAD_CACHE(int_mul4x4_asm(r, a, b, j), 100);
    MEASURE_CYCLES(int_mul4x4_asm(r, a, b, j), 100);
    printf("%i limbs (%i bits): cycles = %lld\n", j, j*LIMBBITS, diff_cycles);
    #if DEBUG
    // mpi_print("  r  = 0x", r, 2*j);
    mpi_mul_1x1rr_isa(x, a, b, j);  // C implementation
    if (mpi_compare(r, x, 2*j) == 0) {
      printf("  result is correct!\n");
    } else {
      printf("  result is wrong!!!\n");
    }
    memset(r, 0, 2*j*sizeof(uint64_t));
    #endif
  }
}


int main(void)
{
  #if defined( MPISE_ISE ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "csrrwi x0, 0x801, 0x2" ); // imm = c =  2 => radix = (w-15)+c = (64-15)+ 2 = 51
  #endif
  
  test_int_mul();
  
  return 0;
}

