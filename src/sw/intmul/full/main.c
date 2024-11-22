#include "rdtsc.h"
#include "intarith.h"


#define DEBUG 0

#define MIN_LEN 512
#define MAX_LEN 4096
#define LEN_STEP 512


const uint64_t awords[2] = { 0x0123456789ABCDEFULL, 0xFEDCBA9876543210ULL };
const uint64_t bwords[2] = { 0xFEDCBA9876543210ULL, 0x0123456789ABCDEFULL };


// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void test_int_mul(void)
{
  uint64_t a[MAX_LEN/64], b[MAX_LEN/64], r[2*MAX_LEN/64], x[2*MAX_LEN/64];
  unsigned long long start_cycles, end_cycles, diff_cycles;
  int i, j, nlimbs;

  (void) x;  // to suppress a warning

  for (i = 0; i < MAX_LEN/64; i++) {
    a[i] = awords[i&1];
    b[i] = bwords[i&1];
  }

  printf("=============================================================\n");
  printf("timing measurements integer multiplication:\n");
  printf("=============================================================\n");

  for (j = MIN_LEN; j <= MAX_LEN; j += LEN_STEP) {
    nlimbs = j/64;
    LOAD_CACHE(int_mul4x4_asm(r, a, b, nlimbs), 100);
    MEASURE_CYCLES(int_mul4x4_asm(r, a, b, nlimbs), 100);
    printf("#limbs = %i, #cycles = %lld\n", nlimbs, diff_cycles);

#if DEBUG
    mpi64_print("  r  = 0x", r, 2*nlimbs);
    mpi64_int_mul(x, a, b, nlimbs);  // C implementation
    if (mpi64_int_cmp(r, x, 2*nlimbs) == 0) {
      printf("  result is correct!\n");
    } else {
      printf("  result is wrong!!!\n");
    }
    memset(r, 0, 2*nlimbs*sizeof(uint64_t));
#endif
  }
}


int main(void)
{
#if defined( MPISE_ISE ) && ( MPISE_ISE == 1 ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "csrrwi x0, 0x801, 0xF" ); // imm = c = 15 => radix = (w-15)+c = (64-15)+15 = 64
#endif

  test_int_mul();

  return 0;
}

