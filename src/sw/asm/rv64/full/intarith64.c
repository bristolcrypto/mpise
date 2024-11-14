#include <stdio.h>
#include <string.h>
#include "intarith64.h"


// Assembly function
extern void mul4x4_rv64m(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);


///////////////////////////////////////////////////////////////////////////////
// Native and custom instructions with 2 source and 1 destination registers  //
///////////////////////////////////////////////////////////////////////////////


static inline uint64_t mul_lo(uint64_t rs1, uint64_t rs2)
{
  uint64_t rd = rs1*rs2;
  
  return rd;
}


static inline uint64_t mul_hi(uint64_t rs1, uint64_t rs2)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  rd = (uint64_t) (prod >> 64);
  
  return rd;
}


static inline uint64_t add2_lo(uint64_t rs1, uint64_t rs2)
{
  uint64_t rd = 2*rs1 + rs2;
  
  return rd;
}


static inline uint64_t add2_hi(uint64_t rs1, uint64_t rs2)
{
  __uint128_t sum;
  uint64_t rd;
  
  sum = (__uint128_t) 2*rs1;
  sum = sum + rs2;
  rd = (uint64_t) (sum >> 64);
  
  return rd;
}


static inline uint64_t sadd2_lo(uint64_t rs1, uint64_t rs2)
{
  uint64_t rd = rs1*rs1 + 2*rs2;
  
  return rd;
}


static inline uint64_t sadd2_hi(uint64_t rs1, uint64_t rs2)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs1;
  prod = prod + (__uint128_t) 2*rs2;
  rd = (uint64_t) (prod >> 64);
  
  return rd;
}


///////////////////////////////////////////////////////////////////////////////
// Custom instructions with 3 source registers (for inner loop operations)   //
///////////////////////////////////////////////////////////////////////////////


static inline uint64_t madd_lo(uint64_t rs1, uint64_t rs2, uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  prod = prod + rs3;
  rd = (uint64_t) prod;
  
  return rd;
}


static inline uint64_t madd_hi(uint64_t rs1, uint64_t rs2, uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  prod = prod + rs3;
  rd = (uint64_t) (prod >> 64);
  
  return rd;
}


static inline uint64_t add3_hi(uint64_t rs1, uint64_t rs2, uint64_t rs3)
{
  __uint128_t sum;
  uint64_t rd;
  
  sum = (__uint128_t) rs1 + rs2;
  rd = ((uint64_t) (sum >> 64)) + rs3;
  
  return rd;
}


///////////////////////////////////////////////////////////////////////////////
// Helper functions                                                          //
///////////////////////////////////////////////////////////////////////////////


// Print a multi-precision integer that is given as an array of 64-bit words.

void __attribute__((noinline)) mpi64_print(const char *c, const uint64_t *a, \
  int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) {
    printf("%s", c);
  }
  for (i = len - 1; i > 0; i--) {
    printf("%016llx", (uint64_t) a[i]);
  }
  printf("%016llx\n", (uint64_t) a[0]);
}


// Compare two multi-precision integers of length len. Return +1, 0, or -1
// respectively as a is >, ==, or < b.

int mpi64_int_cmp(const uint64_t *a, const uint64_t *b, int len)
{
  int i;
  
  for (i = len-1; i >= 0; i--) {
    if (a[i] > b[i]) return 1;
    if (a[i] < b[i]) return -1;
  }
  return 0;
}


///////////////////////////////////////////////////////////////////////////////
// Multiplication and Squaring based on the Product-Scanning Technique       //
///////////////////////////////////////////////////////////////////////////////


// Multiplication of two multi-precision integers based on the product-scanning
// technique.

void mpi64_int_mul(uint64_t *r, const uint64_t *a, const uint64_t *b, int len)
{
  int i, j, k;
  uint64_t tmp;
  
  // first multiplication: a[0]*b[0]
  r[0] = mul_lo(a[0], b[0]);
  r[1] = mul_hi(a[0], b[0]);
  r[2] = 0;
  
  // len-1 iterations of 1st outer loop
  for (i = 1; i <= len - 1; i++) {
    r[i+2] = 0;
    for (j = 0, k = i; k >= 0; j++, k--) {
      tmp = madd_hi(a[j], b[k], r[i]);
      r[i] = madd_lo(a[j], b[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // len-2 iterations of 2nd outer loop
  for (i = len; i < 2*(len - 1); i++) {
    r[i+2] = 0;
    for (j = i - (len - 1), k = len - 1; j <= len - 1; j++, k--) {
      tmp = madd_hi(a[j], b[k], r[i]);
      r[i] = madd_lo(a[j], b[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // last multiplication: a[len-1]*a[len-1]
  tmp = madd_hi(a[len-1], b[len-1], r[2*(len-1)]);
  r[2*(len-1)] = madd_lo(a[len-1], b[len-1], r[2*(len-1)]);
  r[2*len-1] = r[2*len-1] + tmp;
}


// Squaring of a multi-precision integer that is given as an array of 32-bit
// words. The first two nested loops compute all partial-products of the form
// a[j]*a[k] with j != k, which are the partial-products that appear twice in
// the final result and need to be doubled. Then, in a separate third loop, the
// intermediate result is doubled in one go and the partial-products of the
// form a[i]*a[i] for even i (i.e. those partial-products that are not doubled)
// are computed and added to obtain the final result.

// This version is very fast, but it can only be used for Mersenne-like primes
// where the modular reduction is performed *after* the multiplication. It is
// not possible to use this squaring function for Montgomery squaring based on
// the Finely-Integrated Product Scanning (FIPS) technique.

void mpi64_int_sqr(uint64_t *r, const uint64_t *a, int len)
{
  int i, j, k;
  uint64_t tmp, carry1, carry0 = 0;
  
  r[0] = r[1] = r[2] = 0;
  
  // len-1 iterations of 1st outer loop
  for (i = 1; i <= len - 1; i++) {
    r[i+2] = 0;
    for (j = 0, k = i; j < k; j++, k--) {
      tmp = madd_hi(a[j], a[k], r[i]);
      r[i] = madd_lo(a[j], a[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // len-2 iterations of 2nd outer loop
  for (i = len; i < 2*(len - 1); i++) {
    r[i+2] = 0;
    for (j = i - (len - 1), k = len - 1; j < k; j++, k--) {
      tmp = madd_hi(a[j], a[k], r[i]);
      r[i] = madd_lo(a[j], a[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // double result and add squares a[i]^2
  for (i = 0; i < 2*len; i += 2) {
    tmp = sadd2_hi(a[i/2], r[i]);
    r[i] = sadd2_lo(a[i/2], r[i]);
    r[i] = r[i] + carry0;
    carry1 = (r[i] < carry0);  // sltu
    carry0 = add2_hi(r[i+1], tmp);
    r[i+1] = add2_lo(r[i+1], tmp);
    carry0 = add3_hi(r[i+1], carry1, carry0);
    r[i+1] = r[i+1] + carry1;
  }
  
}


// Squaring of a multi-precision integer that is given as an array of 32-bit
// words. This version integrates the doubling of the partial-products that
// need to be doubled into the two nested loops, i.e. there is no third loop
// like in `mpi32_int_sqr`. The partial products that need to be doubled are
// first summed up into three accu registers (in the inner loops) and then the
// accu is doubled and added to the result-array. The partial-products of the
// form a[i]*a[i] (i.e. those partial-products that are not doubled) are not
// computed in every iteration of the outer loop but only when i is even (or,
// equivalently, when j == k at the end of the inner loop). The computation
// and addition of a[i]*a[i] is done in the same way as for all other partial
// products in the inner loop.

// This version is slower than `mpi32_int_sqr`, but has the advantage that it
// can be used for Montgomery squaring based on the Finely Integrated Product
// Scanning (FIPS) method.

void mpi64_int_sqr_V2(uint64_t *r, const uint64_t *a, int len)
{
  int i, j, k;
  uint64_t tmp, aLo, aHi, aEx;
  
  // first square: a[0]^2
  r[0] = mul_lo(a[0], a[0]);
  r[1] = mul_hi(a[0], a[0]);
  r[2] = 0;
  
  // len-1 iterations of 1st outer loop
  for (i = 1; i <= len - 1; i++) {
    aLo = aHi = aEx = 0;
    for (j = 0, k = i; j < k; j++, k--) {
      tmp = madd_hi(a[j], a[k], aLo);
      aLo = madd_lo(a[j], a[k], aLo);
      aEx = add3_hi(tmp, aHi, aEx);
      aHi = aHi + tmp;
    }
    // double accu and add it to result
    tmp = add2_hi(aLo, r[i]);
    r[i] = add2_lo(aLo, r[i]);
    r[i+1] = r[i+1] + tmp;
    tmp = add2_hi(aHi, r[i+1]);
    r[i+1] = add2_lo(aHi, r[i+1]);
    r[i+2] = add2_lo(aEx, tmp);
    // add a[i]^2 if i is even (j == k)
    if (j == k) {  // this means i is even!
      tmp = madd_hi(a[j], a[k], r[i]);
      r[i] = madd_lo(a[j], a[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // len-2 iterations of 2nd outer loop
  for (i = len; i < 2*(len - 1); i++) {
    aLo = aHi = aEx = 0;
    for (j = i - (len - 1), k = len - 1; j < k; j++, k--) {
      tmp = madd_hi(a[j], a[k], aLo);
      aLo = madd_lo(a[j], a[k], aLo);
      aEx = add3_hi(tmp, aHi, aEx);
      aHi = aHi + tmp;
    }
    // double accu and add it to result
    tmp = add2_hi(aLo, r[i]);
    r[i] = add2_lo(aLo, r[i]);
    r[i+1] = r[i+1] + tmp;
    tmp = add2_hi(aHi, r[i+1]);
    r[i+1] = add2_lo(aHi, r[i+1]);
    r[i+2] = add2_lo(aEx, tmp);
    // add a[i]^2 if i is even (j == k)
    if (j == k) {  // this means i is even!
      tmp = madd_hi(a[j], a[k], r[i]);
      r[i] = madd_lo(a[j], a[k], r[i]);
      r[i+2] = add3_hi(tmp, r[i+1], r[i+2]);
      r[i+1] = r[i+1] + tmp;
    }
  }
  
  // last square: a[len-1]^2
  tmp = madd_hi(a[len-1], a[len-1], r[2*(len-1)]);
  r[2*(len-1)] = madd_lo(a[len-1], a[len-1], r[2*(len-1)]);
  r[2*len-1] = r[2*len-1] + tmp;
}


// Simple test program for multiplication of two multi-precision integers that
// are given as arrays of 32-bit words.

void mpi64_test_int_mul(void)
{
  uint64_t a64[8] = { 0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, \
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, \
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL, \
                      0x0123456789ABCDEFULL, 0x0123456789ABCDEFULL };
  uint64_t b64[8] = { 0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, \
                      0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, \
                      0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL, \
                      0x89ABCDEF01234567ULL, 0x89ABCDEF01234567ULL };
  uint64_t r64[16];
  int i;
  
  mpi64_print("a64 = ", a64, 8);
  mpi64_print("b64 = ", b64, 8);
  
  mpi64_int_mul(r64, a64, b64, 8);
  mpi64_print("r64 = ", r64, 16);
  
  for (i = 0; i < 16; i++) r64[i] = 0;
  mul4x4_rv64m(r64, a64, b64, 8);
  mpi64_print("r64 = ", r64, 16);
  
  // expected output:
  // a64 = 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
  // b64 = 89abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234567
  // r64 = 009ca39e1358e7466dc33f6bf00014b5dae9db39cca7422548107707a94e6f94b53712d585f59d04225daea3629cca738f844a713f43f7e2fcaae63f1beb255268983ad0d1e08434fb719f02f53956c58e4b033518922956212467673beafbe6b3fdcb995f43ce7746d72fcb829ca107d9b093fda5f573986c89f82fc94e4629
  // r64 = 009ca39e1358e7466dc33f6bf00014b5dae9db39cca7422548107707a94e6f94b53712d585f59d04225daea3629cca738f844a713f43f7e2fcaae63f1beb255268983ad0d1e08434fb719f02f53956c58e4b033518922956212467673beafbe6b3fdcb995f43ce7746d72fcb829ca107d9b093fda5f573986c89f82fc94e4629
  
  /*
  mpi64_int_sqr(r64, a64, 8);
  mpi64_print("r64 = ", r64, 16);
  */
}


int main(void)
{
  mpi64_test_int_mul();
  return 0;
}
