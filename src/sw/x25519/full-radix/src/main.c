#include "share.h"
#include "rdtsc.h"
#include "gfparith.h"
#include "moncurve.h"


// macros for measuring CPU cycles

#define LOAD_CACHE(X, ITER) for (i = 0; i < (ITER); i++) (X)

#define MEASURE_CYCLES(X, ITER)                    \
  start_cycles = rdtsc();                          \
  for (i = 0; i < (ITER); i++) (X);                \
  end_cycles = rdtsc();                            \
  diff_cycles = (end_cycles-start_cycles)/(ITER)


void test_gfp_arith()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  // a := 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
  uint64_t a[NLMB64] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL,
                         0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, };
  // b := 0x09ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01234567;
  uint64_t b[NLMB64] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL,
                         0x89ABCDEF01234567ULL, 0x09ABCDEF01234567ULL, };
  uint64_t r[NLMB64];

  printf("=============================================================\n");
  printf("timing measurement:\n");
  printf("=============================================================\n");
  printf("gfp arith:\n");

  printf("- gfp mul:     ");

  LOAD_CACHE(gfp_mul(r, a, b), 100);
  MEASURE_CYCLES(gfp_mul(r, a, b), 1000);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x359FEE6106B5DA2E7C347321EADF6B4942C8F7E2CF08FC64095D7CA3B3328D77;
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------


  printf("- gfp sqr:     ");

  LOAD_CACHE(gfp_sqr(r, a), 100);
  MEASURE_CYCLES(gfp_sqr(r, a), 1000);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  // r := 0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465;
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------

  printf("- gfp add:     ");

  LOAD_CACHE(gfp_add(r, a, b), 100);
  MEASURE_CYCLES(gfp_add(r, a, b), 1000);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  //r  = 0x0acf13568acf13568acf13568acf13568acf13568acf13568acf13568acf1356
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------

  printf("- gfp sub:     ");

  LOAD_CACHE(gfp_sub(r, a, b), 100);
  MEASURE_CYCLES(gfp_sub(r, a, b), 1000);
  printf("         #cycle = %lld\n", diff_cycles);

#if DEBUG
  //r  = 0x7777777888888887777777788888888777777778888888877777777888888875
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif

  // ---------------------------------------------------------------------------

  printf("- gfp mul64:     ");

  LOAD_CACHE(gfp_mul64(r, a, (CONSTA+2)/4), 100);
  MEASURE_CYCLES(gfp_mul64(r, a, (CONSTA+2)/4), 1000);
  printf("       #cycle = %lld\n", diff_cycles);

#if DEBUG
  //r  = 0x3cdf012345658ebabcdf012345658ebabcdf012345658ebabcdf01234565dcd9
  mpi64_print("  r  = 0x", r, NLMB64);
  memset(r, 0, sizeof(uint64_t)*NLMB64);
#endif
}

void test_curve_arith()
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  int i;

  uint64_t xp[NLMB64] = { 0x89ABCDEF01234A14, 0x89ABCDEF01234567, \
    0x89ABCDEF01234567, 0x09ABCDEF01234567 };
  uint64_t zp[NLMB64] = { 0x0123456789ABD289, 0x0123456789ABCDEF, \
    0x0123456789ABCDEF, 0x0123456789ABCDEF };  
  uint64_t xq[NLMB64] = { 0xa3030242d807aa98, 0x45706fbe12835b01, \
    0x4ee4b28c243185be, 0x55ffb4e2550c7dc3 };
  uint64_t zq[NLMB64] = { 0xf27b896f72be5d74, 0x3b1696b180deb1fe, \
    0x25c712359bdc06a7, 0x4f692694c19bf174 };
  uint64_t xd[NLMB64] = { 0x9ef14ad2e49b69c1, 0x384f25e3efbe4786, \
    0x8b8cd5b50fc19dc6, 0x77ac9c65240ca1cc };
  ProPoint p, q;
  uint64_t r[NLMB64];

  printf("-------------------------------------------------------------\n");
  printf("montgomery curve arithmetic:\n");

  memcpy(p.x, xp, sizeof(uint64_t)*NLMB64);
  memcpy(p.z, zp, sizeof(uint64_t)*NLMB64);
  memcpy(q.x, xq, sizeof(uint64_t)*NLMB64);
  memcpy(q.z, zq, sizeof(uint64_t)*NLMB64);

  printf("- mon ladder step:     ");

  LOAD_CACHE(mon_ladder_step(&p, &q, xd), 10);
  MEASURE_CYCLES(mon_ladder_step(&p, &q, xd), 100);
  printf(" #cycle = %lld\n", diff_cycles);

#if DEBUG
  memcpy(p.x, xp, sizeof(uint64_t)*NLMB64);
  memcpy(p.z, zp, sizeof(uint64_t)*NLMB64);
  memcpy(q.x, xq, sizeof(uint64_t)*NLMB64);
  memcpy(q.z, zq, sizeof(uint64_t)*NLMB64);
  // x3 := 0x4F46FD1FD643F60F58FBC3DCB6691EDBB8BC4C0E8619879A1E7CCD145F86813B
  // z3 := 0x32C0C112720E8B7C9945DA6D5730D5D9CD118B8C76A5A8E7AB247B06822B993C
  // x2 := 0x470F51948095E1CFB7C4EACC0FE04898287A84039F2AAF6099301D3BB17EC40A
  // z2 := 0x6BC1BD72824403011C63885844A207D88F7470C8B423A1FA6DC7CA52785B2725
  mon_ladder_step(&p, &q, xd); 
  mpi64_print("  x3 = 0x", q.x, 4);
  mpi64_print("  z3 = 0x", q.z, 4);
  mpi64_print("  x2 = 0x", p.x, 4);
  mpi64_print("  z2 = 0x", p.z, 4);
#endif 

  // ---------------------------------------------------------------------------

  printf("- mon varbase mul:     ");

  uint64_t k[NLMB64] = { 0x9D7C52F06BE346A5ULL, 0xDD5E46824B15163BULL, \
    0x185AFCC10A4C1462ULL, 0xC49A44BA44226A50ULL };
  uint64_t x[NLMB64] = { 0xDB3030586768DBE6ULL, 0x7C5FB124A4C19435ULL, \
    0x3B35B326EC246672ULL, 0x4C1CABD0A603A910ULL };

  LOAD_CACHE(mon_mul_varbase(r, k, x), 10);
  MEASURE_CYCLES(mon_mul_varbase(r, k, x), 50);
  printf(" #cycle = %lld\n", diff_cycles);

#if DEBUG
  // R := 0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3;
  mpi64_print("  R  = 0x", r, 4);
#endif

  printf("=============================================================\n");
}

void test_ecdh()
{
  printf("=============================================================\n");
  printf("ecdh correctness test:\n");
  printf("=============================================================\n");
  
  // RFC7748 test vectors
  static uint32_t RFC7748_A[8] = { 
    0x0a6d0777, 0x7da51873, 0x72c1163c, 0x4566b251, 
    0x872f4cdf, 0x2a99c0eb, 0xa5fb77b1, 0x2a2cb91d };
  static uint32_t RFC7748_B[8] = {
    0x7e08ab5d, 0x4b8a4a62, 0x8b7fe179, 0xe60e8083, 
    0x29b13b6f, 0xfdb61826, 0x278b2f1c, 0xebe088ff };

  union tvec { uint32_t t32[8]; uint64_t t64[4]; };
  union tvec sk_a, sk_b, pk_a, pk_b, ss_a, ss_b;
  static union tvec base_pt = { 9 };
  int wrong = 0;

  printf("x25519: (alice <---> bob: rfc7748 test vectors)\n");

  memcpy(sk_a.t64, RFC7748_A, 32);
  memcpy(sk_b.t64, RFC7748_B, 32);

  printf("- private keys:\n");
  mpi64_print("  alice: ", sk_a.t64, 4);
  mpi64_print("  bob  : ", sk_b.t64, 4);

  mon_mul_varbase(pk_a.t64, sk_a.t64, base_pt.t64);
  mon_mul_varbase(pk_b.t64, sk_b.t64, base_pt.t64);

  printf("- public keys:\n");
  mpi64_print("  alice: ", pk_a.t64, 4);
  mpi64_print("  bob  : ", pk_b.t64, 4);

  mon_mul_varbase(ss_a.t64, sk_a.t64, pk_b.t64);
  mon_mul_varbase(ss_b.t64, sk_b.t64, pk_a.t64);

  printf("- shared secrets:\n");
  mpi64_print("  alice: ", ss_a.t64, 4);
  mpi64_print("  bob  : ", ss_b.t64, 4);

  wrong = memcmp(ss_a.t64, ss_b.t64, 4);

  printf("- results:");

  if (wrong == 0) printf("\x1b[32m equal \x1b[0m\n");
  else            printf("\x1b[31m not equal \x1b[0m\n");

  printf("-------------------------------------------------------------\n");

  printf("x25519: (carol <---> dave: random test vectors)\n");

  rand_bytes((uint8_t *)sk_a.t64, 32);
  rand_bytes((uint8_t *)sk_b.t64, 32);

  printf("- private keys:\n");
  mpi64_print("  carol: ", sk_a.t64, 4);
  mpi64_print("  dave : ", sk_b.t64, 4);

  mon_mul_varbase(pk_a.t64, sk_a.t64, base_pt.t64);
  mon_mul_varbase(pk_b.t64, sk_b.t64, base_pt.t64);

  printf("- public keys:\n");
  mpi64_print("  carol: ", pk_a.t64, 4);
  mpi64_print("  dave : ", pk_b.t64, 4);

  mon_mul_varbase(ss_a.t64, sk_a.t64, pk_b.t64);
  mon_mul_varbase(ss_b.t64, sk_b.t64, pk_a.t64);

  printf("- shared secrets:\n");
  mpi64_print("  carol: ", ss_a.t64, 4);
  mpi64_print("  dave : ", ss_b.t64, 4);

  wrong = memcmp(ss_a.t64, ss_b.t64, 4);

  printf("- results:");

  if (wrong == 0) printf("\x1b[32m equal \x1b[0m\n");
  else            printf("\x1b[31m not equal \x1b[0m\n");
}

int main()
{
  test_ecdh();
  test_gfp_arith();
  test_curve_arith();

  return 0;
}
