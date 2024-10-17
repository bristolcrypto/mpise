#include <stdio.h>
#include <string.h>
#include <stdint.h>

/*
extern void gfp_add_rv32m(uint32_t *r, const uint32_t *a, const uint32_t *b);
extern void gfp_mul_rv32m(uint32_t *r, const uint32_t *a, const uint32_t *b);
extern void gfp_sqr_rv32m(uint32_t *r, const uint32_t *a);
*/
extern void mul4x4_rv32m(uint32_t *r, const uint32_t *a, const uint32_t *b, int len);


///////////////////////////////////////////////////////////////////////////////
// Native and custom instructions with 2 source and 1 destination registers  //
///////////////////////////////////////////////////////////////////////////////


static inline uint32_t mul_lo(uint32_t rs1, uint32_t rs2)
{
  uint32_t rd = rs1*rs2;
  
  return rd;
}


static inline uint32_t mul_hi(uint32_t rs1, uint32_t rs2)
{
  uint64_t prod;
  uint32_t rd;
  
  prod = (uint64_t) rs1*rs2;
  rd = (uint32_t) (prod >> 32);
  
  return rd;
}


static inline uint32_t add2_lo(uint32_t rs1, uint32_t rs2)
{
  uint32_t rd = 2*rs1 + rs2;
  
  return rd;
}


static inline uint32_t add2_hi(uint32_t rs1, uint32_t rs2)
{
  uint64_t sum;
  uint32_t rd;
  
  sum = (uint64_t) 2*rs1;
  sum = sum + rs2;
  rd = (uint32_t) (sum >> 32);
  
  return rd;
}


static inline uint32_t sadd2_lo(uint32_t rs1, uint32_t rs2)
{
  uint32_t rd = rs1*rs1 + 2*rs2;
  
  return rd;
}


static inline uint32_t sadd2_hi(uint32_t rs1, uint32_t rs2)
{
  uint64_t prod;
  uint32_t rd;
  
  prod = (uint64_t) rs1*rs1;
  prod = prod + (uint64_t) 2*rs2;
  rd = (uint32_t) (prod >> 32);
  
  return rd;
}


///////////////////////////////////////////////////////////////////////////////
// Custom instructions with 3 source registers (for inner loop operations)   //
///////////////////////////////////////////////////////////////////////////////


static inline uint32_t madd_lo(uint32_t rs1, uint32_t rs2, uint32_t rs3)
{
  uint64_t prod;
  uint32_t rd;
  
  prod = (uint64_t) rs1*rs2;
  prod = prod + rs3;
  rd = (uint32_t) prod;
  
  return rd;
}


static inline uint32_t madd_hi(uint32_t rs1, uint32_t rs2, uint32_t rs3)
{
  uint64_t prod;
  uint32_t rd;
  
  prod = (uint64_t) rs1*rs2;
  prod = prod + rs3;
  rd = (uint32_t) (prod >> 32);
  
  return rd;
}


static inline uint32_t add3_hi(uint32_t rs1, uint32_t rs2, uint32_t rs3)
{
  uint64_t sum;
  uint32_t rd;
  
  sum = (uint64_t) rs1 + rs2;
  rd = ((uint32_t) (sum >> 32)) + rs3;
  
  return rd;
}


///////////////////////////////////////////////////////////////////////////////
// Helper functions                                                          //
///////////////////////////////////////////////////////////////////////////////


// Print a multi-precision integer that is given as an array of 32-bit words.

void __attribute__((noinline)) mpi32_print(const char *c, const uint32_t *a, \
  int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) {
    printf("%s", c);
  }
  for (i = len - 1; i > 0; i--) {
    printf("%08x", a[i]);
  }
  printf("%08x\n", a[0]);
}


// Compare two multi-precision integers of length len. Return +1, 0, or -1
// respectively as a is >, ==, or < b.

int mpi32_int_cmp(const uint32_t *a, const uint32_t *b, int len)
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

void mpi32_int_mul(uint32_t *r, const uint32_t *a, const uint32_t *b, int len)
{
  int i, j, k;
  uint32_t tmp;
  
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

void mpi32_int_sqr(uint32_t *r, const uint32_t *a, int len)
{
  int i, j, k;
  uint32_t tmp, carry1, carry0 = 0;
  
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

void mpi32_int_sqr_V2(uint32_t *r, const uint32_t *a, int len)
{
  int i, j, k;
  uint32_t tmp, aLo, aHi, aEx;
  
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

void mpi32_test_int_mul(void)
{
  // uint32_t a32[8] = { 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, \
  //                     0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF };
  uint32_t a32[16] = { 0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF, \
                       0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF, \
                       0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF, \
                       0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF };
  uint32_t b32[16] = { 0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567, \
                       0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567, \
                       0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567, \
                       0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567 };
  uint32_t r32[32];
  
  mpi32_print("a32 = ", a32, 16);
  mpi32_print("b32 = ", b32, 16);
  
  mpi32_int_mul(r32, a32, b32, 16);
  mpi32_print("r32 = ", r32, 32);
  
  for (int i = 0; i < 32; i++) r32[i] = 0;
  mul4x4_rv32m(r32, a32, b32, 16);
  mpi32_print("r32 = ", r32, 32);
  
  /*
  gfp_mul_rv32m(r32, a32, b32);
  mpi32_print("r32 = ", r32, 8);
  
  mpi32_int_sqr(r32, a32, 8);
  mpi32_print("r32 = ", r32, 16);
  
  gfp_sqr_rv32m(r32, a32);
  mpi32_print("r32 = ", r32, 8);
  
  gfp_add_rv32m(r32, a32, b32);
  mpi32_print("r32 = ", r32, 8);
  */
}


int main(void)
{
  mpi32_test_int_mul();
  // mpi32_test_gfp_mul();
  
  return 0;
}
