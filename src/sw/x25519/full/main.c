#include <inttypes.h>
#include <stdlib.h>
#include "share.h"
#include "rdtsc.h"
#include "gfparith.h"
#include "moncurve.h"
#include "instrumentation.h"

#if (MPISE_XLEN==32)
#include "scott_x25519_32.h"
#endif

#if (MPISE_XLEN==64)
#include "scott_x25519_64.h"
#endif

#if X25519_DEBUG
// ------------ Instrumentation code ------------
// Define two arrays to track clock cycles and
// retired instructions for each iteration of a
// test function. These arrays are defined once,
// and reused multiple times throughout this file.
// ----------------------------------------------
#define MAX_TRIALS 2000
uint64_t rdtsc_debug[MAX_TRIALS];
uint64_t instr_debug[MAX_TRIALS];
#endif

#define LOAD_CACHE(X, iter) do {                  \
  for (i = 0; i < (iter); i++) (X);               \
} while (0);

#define MEASURE_CYCLES(X, iter) do {              \
  start_cycles = rdtsc();                         \
  start_instr = rdinstr();                        \
  for (i = 0; i < (iter); i++) (X);               \
  end_cycles = rdtsc();                           \
  end_instr  = rdinstr();                         \
  diff_cycles = (end_cycles-start_cycles)/(iter); \
  diff_instr  = (end_instr - start_instr)/(iter); \
} while (0);

// Single NOP subroutine
void test_nop(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  int i;
  printf("\n=============================================================\n");
  printf("test_nop - nop_routine");
  printf("\n=============================================================\n");
  LOAD_CACHE(nop_routine(), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(nop_routine(), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(nop_routine(), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
}

void test_gfp_mul(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char mulh[] =  // expected result gfp_mul
    "0x5EDAF2E6A75EA09F98466E25C3350F84D1B1E964DF0B7E6A0B1D64A3FAE1ED44";
  if (strcmp(mulh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  // --------------------------------------------------------------------------
}

void test_gfp_arith(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char mulh[] =  // expected result gfp_mul
    "0x5EDAF2E6A75EA09F98466E25C3350F84D1B1E964DF0B7E6A0B1D64A3FAE1ED44";
  if (strcmp(mulh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sqr");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sqr(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sqr(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sqr(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp inv");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_inv(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_inv(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_inv(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char sqrh[] =  // expected result gfp_sqr
    "0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465";
  if (strcmp(sqrh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp add");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_add(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_add(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_add(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char addh[] =  // expected result gfp_add
    "0x7777777888888887777777788888888777777778888888877777777888888887";
  if (strcmp(addh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sub");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sub(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sub(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sub(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char subh[] =  // expected result gfp_sub
    "0x0ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1344";
  if (strcmp(subh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul32");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul32(resf, op1f, (CONSTA - 2)/4), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul32(resf, op1f, (CONSTA - 2)/4), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sub(resf, op1f, op2f), iter);
  printf("       #cycles = %" PRIu64 "\n", diff_cycles);
  printf("       #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char m32h[] =  // expected result gfp_mul32
    "0x3BBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBBA0EEA";
  if (strcmp(m32h, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
}


void test_curve_arith(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  // Word rf[NWORDS], kf[NWORDS]; // Unused
  Word xf[NWORDS]; // full-radix
  ProPoint p, q;
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];
#endif
  
  static const char xpih[] =  // X-coordinate of 1st point
    "0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234A14";
  static const char zpih[] =  // Z-coordinate of 1st point
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABD289";
  static const char xqih[] =  // X-coordinate of 2nd point
    "0x55FFB4E2550C7DC34EE4B28C243185BE45706FBE12835B01A3030242D807AA98";
  static const char zqih[] =  // Z-coordinate of 2nd point
    "0x4F692694C19BF17425C712359BDC06A73B1696B180DEB1FEF27B896F72BE5D74";
  static const char xdih[] =  // x-coordinate of basepoint
    "0x77AC9C65240CA1CC8B8CD5B50FC19DC6384F25E3EFBE47869EF14AD2E49B69C1";
  
  hex_to_int(p.x, xpih, NWORDS);
  hex_to_int(p.z, zpih, NWORDS);
  hex_to_int(q.x, xqih, NWORDS);
  hex_to_int(q.z, zqih, NWORDS);
  hex_to_int(xf,  xdih, NWORDS);
  
  printf("\n=============================================================\n");
  printf("test_curve_arith - mon_ladder_step");
  printf("\n=============================================================\n");
  LOAD_CACHE(mon_ladder_step(&p, &q, xf), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(mon_ladder_step(&p, &q, xf), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(mon_ladder_step(&p, &q, xf), iter);
  printf(" #cycles = %" PRIu64 "\n", diff_cycles);
  printf(" #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  hex_to_int(p.x, xpih, NWORDS);
  hex_to_int(p.z, zpih, NWORDS);
  hex_to_int(q.x, xqih, NWORDS);
  hex_to_int(q.z, zqih, NWORDS);
  mon_ladder_step(&p, &q, xf);
  // check X-coodinate of P
  int_to_hex(resh, p.x, NWORDS);
  printf("  Xp = %s\n", resh);
  static const char xpoh[] =  // expected result for Xp
    "0x470F51948095E1CFB7C4EACC0FE04898287A84039F2AAF6099301D3BB17EC40A";
  if (strcmp(xpoh, resh) != 0) printf("  result Xp is wrong!!!\n");
  // check Z-coodinate of P
  int_to_hex(resh, p.z, NWORDS);
  printf("  Zp = %s\n", resh);
  static const char zpoh[] =  // expected result for Zp
    "0x6BC1BD72824403011C63885844A207D88F7470C8B423A1FA6DC7CA52785B2725";
  if (strcmp(zpoh, resh) != 0) printf("  result Zp is wrong!!!\n");
  // check X-coodinate of Q
  int_to_hex(resh, q.x, NWORDS);
  printf("  Xq = %s\n", resh);
  static const char xqoh[] =  // expected result for Xq
    "0x4F46FD1FD643F60F58FBC3DCB6691EDBB8BC4C0E8619879A1E7CCD145F86813B";
  if (strcmp(xqoh, resh) != 0) printf("  result Xq is wrong!!!\n");
  // check Z-coodinate of Q
  int_to_hex(resh, q.z, NWORDS);
  printf("  Zq = %s\n", resh);
  static const char zqoh[] =  // expected result for Zq
    "0x32C0C112720E8B7C9945DA6D5730D5D9CD118B8C76A5A8E7AB247B06822B993C";
  if (strcmp(zqoh, resh) != 0) printf("  result Zq is wrong!!!\n");
#endif 
}

void test_mon_varbase_mul(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word rf[NWORDS], kf[NWORDS], xf[NWORDS];  // full-radix
  int i; 
  // --------------------------------------------------------------------------
  
  static const char kh[] =  // scalar k for testing
    "0xC49A44BA44226A50185AFCC10A4C1462DD5E46824B15163B9D7C52F06BE346A5";
  static const char xh[] =  // x-coordinate for testing
    "0x4C1CABD0A603A9103B35B326EC2466727C5FB124A4C19435DB3030586768DBE6";
  
  hex_to_int(kf, kh, NWORDS);
  hex_to_int(xf, xh, NWORDS);
  
  printf("\n=============================================================\n");
  printf("test_mon_varbase_mul - mon_varbase_mul");
  printf("\n=============================================================\n");
  LOAD_CACHE(mon_mul_varbase(rf, kf, xf), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(mon_mul_varbase(rf, kf, xf), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(mon_mul_varbase(rf, kf, xf), iter);
  printf(" #cycles = %" PRIu64 "\n", diff_cycles);
  printf(" #instr  = %" PRIu64 "\n", diff_instr);
#endif
#if DEBUG
  int_to_hex(resh, rf, NWORDS);
  printf("  R  = %s\n", resh);
  static const char rh[] =  // expected result for R
    "0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3";
  if (strcmp(rh, resh) != 0) printf("  result R is wrong!!!\n");
#endif
}

void test_ecdh(void)
{
  Word sk_a[NWORDS], sk_b[NWORDS];  // secret keys
  Word pk_a[NWORDS], pk_b[NWORDS];  // public keys
  Word ss_a[NWORDS], ss_b[NWORDS];  // shared secrets
  static Word base_pt[NWORDS] = { 9 };
  int wrong = 0;
  
  static const char RFC7748_A[] =  // RFC7748 test vector
    "0x2A2CB91DA5FB77B12A99C0EB872F4CDF4566B25172C1163C7DA518730A6D0777";
  static const char RFC7748_B[] =  // RFC7748 test vector
    "0xEBE088FF278B2F1CFDB6182629B13B6FE60E80838B7FE1794B8A4A627E08AB5D";
  
  printf("\n=============================================================\n");
  printf("ecdh correctness test");
  printf("\n=============================================================\n");
  
  printf("x25519: (alice <---> bob: rfc7748 test vectors)\n");
  
  hex_to_int(sk_a, RFC7748_A, NWORDS);
  hex_to_int(sk_b, RFC7748_B, NWORDS);
  
  printf("- private keys:\n");
  mpi_print("  alice: ", sk_a, NWORDS);
  mpi_print("  bob  : ", sk_b, NWORDS);
  
  mon_mul_varbase(pk_a, sk_a, base_pt);
  mon_mul_varbase(pk_b, sk_b, base_pt);
  
  printf("- public keys:\n");
  mpi_print("  alice: ", pk_a, NWORDS);
  mpi_print("  bob  : ", pk_b, NWORDS);
  
  mon_mul_varbase(ss_a, sk_a, pk_b);
  mon_mul_varbase(ss_b, sk_b, pk_a);
  
  printf("- shared secrets:\n");
  mpi_print("  alice: ", ss_a, NWORDS);
  mpi_print("  bob  : ", ss_b, NWORDS);
  
  wrong = memcmp(ss_a, ss_b, WBYTES*NWORDS);
  
  printf("- results:");
  
  if (wrong == 0) printf("\x1b[32m equal \x1b[0m\n");
  else            printf("\x1b[31m not equal \x1b[0m\n");
  
  printf("-------------------------------------------------------------\n");
  
  printf("x25519: (carol <---> dave: random test vectors)\n");
  
  rand_bytes((uint8_t *) sk_a, WBYTES*NWORDS);
  rand_bytes((uint8_t *) sk_b, WBYTES*NWORDS);
  
  printf("- private keys:\n");
  mpi_print("  carol: ", sk_a, NWORDS);
  mpi_print("  dave : ", sk_b, NWORDS);
  
  mon_mul_varbase(pk_a, sk_a, base_pt);
  mon_mul_varbase(pk_b, sk_b, base_pt);
  
  printf("- public keys:\n");
  mpi_print("  carol: ", pk_a, NWORDS);
  mpi_print("  dave : ", pk_b, NWORDS);
  
  mon_mul_varbase(ss_a, sk_a, pk_b);
  mon_mul_varbase(ss_b, sk_b, pk_a);
  
  printf("- shared secrets:\n");
  mpi_print("  carol: ", ss_a, NWORDS);
  mpi_print("  dave : ", ss_b, NWORDS);
  
  wrong = memcmp(ss_a, ss_b, WBYTES*NWORDS);
  
  printf("- results:");
  
  if (wrong == 0) printf("\x1b[32m equal \x1b[0m\n");
  else            printf("\x1b[31m not equal \x1b[0m\n");
}



// prototype of mike scott's x25519 implementation
extern int X25519_SHARED_SECRET(char *SK, char *PK, char *SS);

void test_scott(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word rf[NWORDS], kf[NWORDS], xf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];
#endif
  
  static const char kh[] =  // scalar k for testing
    "0xC49A44BA44226A50185AFCC10A4C1462DD5E46824B15163B9D7C52F06BE346A5";
  static const char xh[] =  // x-coordinate for testing
    "0x4C1CABD0A603A9103B35B326EC2466727C5FB124A4C19435DB3030586768DBE6";
  
  hex_to_int(kf, kh, NWORDS);
  hex_to_int(xf, xh, NWORDS);
  printf("\n=============================================================\n");  
  printf("test_scott - X25519_SHARED_SECRET");
  printf("\n=============================================================\n");
  LOAD_CACHE(X25519_SHARED_SECRET((char *) kf, (char *) xf, (char *) rf), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(X25519_SHARED_SECRET((char *) kf, (char *) xf, (char *) rf), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(X25519_SHARED_SECRET((char *) kf, (char *) xf, (char *) rf), iter);
  printf(" #cycles = %" PRIu64 "\n", diff_cycles);
  printf(" #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, rf, NWORDS);
  printf("  R  = %s\n", resh);
  static const char rh[] =  // expected result for R
    "0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3";
  if (strcmp(rh, resh) != 0) printf("  result R is wrong!!!\n");
#endif
}

int main( int argc, char* argv[] )
{
  int num_iters, num_warmup_iters;
  if (argc != 3) {
      printf("Usage (for mon_varbase_mul and test_scott): %s <an_integer> <another_integer>\n", argv[0]);
      num_iters = 1000;
      num_warmup_iters = 100;    
  } else {
      num_iters = atoi(argv[1]);
      num_warmup_iters = atoi(argv[2]);
  }
  printf("Setting num_iters = %d , num_warmup_iters = %d\n", num_iters, num_warmup_iters);

  #if defined( MPISE_ISE ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "csrrwi x0, 0x801, " MPISE_RADIX_STR );
  #endif
  
  test_nop        (100, 10);                         // Warmup : 10,  Run : 100
  test_gfp_arith  (100, 10);                         // Warmup : 10,  Run : 100
  test_curve_arith(200, 10);                         // Warmup : 10,  Run : 200
  test_ecdh();
  // test_gfp_mul    (2, 10);                         // Warmup : 2,  Run : 10
  // test_nop        (2, 10);                         // Warmup : 2,  Run : 10  
  //test_mon_varbase_mul(num_iters, num_warmup_iters); // Warmup : 100, Run : 1000
  //test_scott(num_iters, num_warmup_iters);           // Warmup : 100, Run : 1000
  // test_point_mul();
  
  return 0;
}
