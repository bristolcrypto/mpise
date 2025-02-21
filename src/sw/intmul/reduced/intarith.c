#include <stdio.h>
#include <string.h>
#include "intarith.h"


// NOTE: LIMBBITS must be 64 when testing the full-radix multiplication!!!

#ifdef RADIX
#define LIMBBITS RADIX
#else  // for testing!
#define LIMBBITS 60
#endif

#define LIMBMASK (0xFFFFFFFFFFFFFFFFULL >> (64 - (LIMBBITS)))


///////////////////////////////////////////////////////////////////////////////
///////////////// Functions emulating the custom instructions /////////////////
///////////////////////////////////////////////////////////////////////////////


static inline uint64_t cacc(uint64_t rs1, uint64_t rs2,  uint64_t rs3)
{
  __uint128_t sum;
  uint64_t rd;
  
  sum = (__uint128_t) rs1 + rs2;
  sum = (sum >> 64) + rs3;
  rd = (uint64_t) (sum);
  
  return rd;
}


static inline uint64_t maccfrlu(uint64_t rs1, uint64_t rs2,  uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  prod += rs3;
  rd = (uint64_t) (prod);
    
  return rd;
}


static inline uint64_t maccfrhu(uint64_t rs1, uint64_t rs2,  uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  prod += rs3;
  rd = (uint64_t) (prod >> 64);
  
  return rd;
}


static inline uint64_t maccrrlu(uint64_t rs1, uint64_t rs2,  uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  rd = rs3 + (((uint64_t ) prod) & LIMBMASK);
    
  return rd;
}


static inline uint64_t maccrrhu(uint64_t rs1, uint64_t rs2,  uint64_t rs3)
{
  __uint128_t prod;
  uint64_t rd;
  
  prod = (__uint128_t) rs1*rs2;
  rd = rs3 + ((uint64_t ) (prod >> LIMBBITS));
  
  return rd;
}


///////////////////////////////////////////////////////////////////////////////
//////// Helper functions (radix conversion, initialization, printing) ////////
///////////////////////////////////////////////////////////////////////////////


// Initialization of operands

static void mpi_init(uint64_t *r, int len)
{
  uint8_t *rb = (uint8_t *) r;
  int i;
  
  for (i = 0; i < 8*len; i++) rb[i] = (uint8_t) i;
  for (i = 0; i < len; i++) r[i] &= LIMBMASK;
}


// Printing of a multi-precision integer

void __attribute__((noinline)) mpi_print(const char *c, const uint64_t *a, \
  int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) {
    printf("%s", c);
  }
  for (i = len - 1; i > 0; i--) {
    printf("%016llx ", (unsigned long long) a[i]);
  }
  printf("%016llx\n", (unsigned long long) a[0]);
}


// Comparison two multi-precision integers of length `len`, return value is
// either +1, 0, or -1, depending on whether a > b, a == b, or a < b.

int mpi_compare(const uint64_t *a, const uint64_t *b, int len)
{
  int i;
  
  for (i = len - 1; i >= 0; i--) {
    if (a[i] > b[i]) return 1;
    if (a[i] < b[i]) return -1;
  }
  return 0;
}


// Conversion full-radix -> reduced radix

void mpi_full2red(uint64_t *r, int rlen, const uint64_t *a, int alen)
{
  uint64_t w0, w1;
  int lbits = LIMBBITS, rbits = 0, i, j = 0;
  
  for (i = 0; i < rlen; i++) {
    w0 = (j < alen) ? a[j] : 0;
    w1 = (j + 1 < alen) ? a[j+1] : 0;
    r[i] = w0 >> rbits;
    if (rbits > (64 - LIMBBITS)) r[i] |= (w1 << lbits);
    r[i] &= LIMBMASK;
    // printf("i = %02i, j = %02i, ", i, j);
    // printf("lbits = %02i, rbits = %02i\n", lbits, rbits);
    rbits += LIMBBITS;
    if (rbits >= 64) {
      rbits -= 64;
      j++;
    }
    lbits = 64 - rbits;
  }
}


// Conversion full-radix -> reduced radix

void mpi_red2full(uint64_t *r, int rlen, const uint64_t *a, int alen)
{
  uint64_t w0, w1, w2;
  int lbits = LIMBBITS, rbits = 0, i, j = 0;
  
  for (i = 0; i < rlen; i++) {
    w0 = (j < alen) ? a[j] : 0;
    w1 = (j + 1 < alen) ? a[j+1] : 0;
    w2 = (j + 2 < alen) ? a[j+2] : 0;
    r[i] = (w1 << lbits) | (w0 >> rbits);
    if (lbits < (64 - LIMBBITS)) r[i] |= (w2 << (LIMBBITS + lbits));
    // printf("i = %02i, j = %02i, ", i, j);
    // printf("lbits = %02i, rbits = %02i\n", lbits, rbits);
    rbits += 64;
    while (rbits >= LIMBBITS) {
      rbits -= LIMBBITS;
      j++;
    }
    lbits = LIMBBITS - rbits;
  }
}


///////////////////////////////////////////////////////////////////////////////
////// Full/reduced-radix multiplication based on product-scanning method /////
///////////////////////////////////////////////////////////////////////////////


// Multiplication of two multi-precision integers (product-scanning method)
// using the full-radix representation.

void mpi_mul_fullradix(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                       int len)
{
  int i, j, k;
  uint64_t t, h = 0, m = 0, l = 0;
  
  // len iterations of 1st outer loop
  for (i = 0; i < len; i++) {
    k = i;  // to access b[k]
    for (j = 0; j <= i; j++) {
      t = maccfrhu(a[j], b[k], l);
      l = maccfrlu(a[j], b[k], l);
      h = cacc(t, m, h);
      m = m + t;
      k--;
    }
    r[i] = l;
    l = m;
    m = h;
    h = 0;
  }
  
  // len-1 iterations of 2nd outer loop
  for (i = len; i < 2*len - 1; i++) {
    k = len - 1;  // to access b[k]
    for (j = i - k; j < len; j++) {
      t = maccfrhu(a[j], b[k], l);
      l = maccfrlu(a[j], b[k], l);
      h = cacc(t, m, h);
      m = m + t;
      k--;
    }
    r[i] = l;
    l = m;
    m = h;
    h = 0;
  }
  r[2*len-1] = l;
}


// Multiplication of two multi-precision integers (product-scanning method)
// using the reduced-radix representation

void mpi_mul_redradix(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                      int len)
{
  int i, j, k;
  uint64_t h = 0, l = 0;
  
  // len iterations of 1st outer loop
  for (i = 0; i < len; i++) {
    k = i;  // to access b[k]
    for (j = 0; j <= i; j++) {
      l = maccrrlu(a[j], b[k], l);
      h = maccrrhu(a[j], b[k], h);
      k--;
    }
    r[i] = (l & LIMBMASK);
    l = (l >> LIMBBITS) + h;
    h = 0;
  }
  
  // len-1 iterations of 2nd outer loop
  for (i = len; i < 2*len - 1; i++) {
    k = len - 1;  // to access b[k]
    for (j = i - k; j < len; j++) {
      l = maccrrlu(a[j], b[k], l);
      h = maccrrhu(a[j], b[k], h);
      k--;
    }
    r[i] = (l & LIMBMASK);
    l = (l >> LIMBBITS) + h;
    h = 0;
  }
  r[2*len-1] = (l & LIMBMASK);
}


///////////////////////////////////////////////////////////////////////////////
//////// Simple test functions for radix conversion and multiplication ////////
///////////////////////////////////////////////////////////////////////////////


// Simple test function for convesion between full-radix and reduced-radix 
// representation

void test_conversion(void)
{
  uint64_t x[120], z[80], a[80];
  int len, numlimbs;
  
  for (len = 0; len < 8*80; len++) {
    ((uint8_t *) a)[len] = (uint8_t) len;
  } 
  
  for (len = 4; len < 80; len++) {
    numlimbs = (64*len + LIMBBITS - 1)/LIMBBITS;
    printf("number of words = %i, number of limbs = %i", len, numlimbs);
    // mpi_print("a = ", a, len);
    mpi_full2red(x, numlimbs, a, len);
    // mpi_print("x = ", x, numlimbs);
    mpi_red2full(z, len, x, numlimbs);
    // mpi_print("z = ", z, len);
    if (mpi_compare(a, z, len) != 0) {
      printf(" -> wrong!!\n");
    } else {
      printf(" -> correct\n");
    }
  }
}


// Simple test program for multiplication of two multi-precision integers using
// full-radix representation.

void test_mul_fullradix(int words)
{
  uint64_t a[words], b[words], r[2*words], c[2*words];
  int i;
  
  // LIMBBITS must be 64!
  mpi_init(a, words);
  mpi_init(b, words);
  
  mpi_print("a = ", a, words);
  mpi_print("b = ", b, words);
  mpi_mul_fullradix(r, a, b, words);
  mpi_print("r = ", r, 2*words);
  
  mpi_mul_4x4fr_isa(c, a, b, words);
  mpi_print("c = ", c, 2*words);
  if (mpi_compare(r, c, 2*words) != 0) printf("Result Wrong!!!\n");
  
  // expected output for words = 8 and LIMBBITS = 64:
  // a = 3f3e3d3c3b3a3938 3736353433323130 2f2e2d2c2b2a2928 2726252423222120 1f1e1d1c1b1a1918 1716151413121110 0f0e0d0c0b0a0908 0706050403020100
  // b = 3f3e3d3c3b3a3938 3736353433323130 2f2e2d2c2b2a2928 2726252423222120 1f1e1d1c1b1a1918 1716151413121110 0f0e0d0c0b0a0908 0706050403020100
  // r = 0f9fb1455cf91ac2 f2aaecb910f56767 f818cb0fe85557f1 21eb4e4be51aee60 7224786f09482cb7 eac64b7b56df14f9 8dd2c972cfe1a927 5d4bf4577651eb43 5bb3491c2b75fab8 aedc3fd8a5a5d83b cf9283a1ec6201ca bbd41275fda87563 719eea52d7773103 eef1093677cc32aa 31c86d1edca57854 3823140a04010000
  // c = 0f9fb1455cf91ac2 f2aaecb910f56767 f818cb0fe85557f1 21eb4e4be51aee60 7224786f09482cb7 eac64b7b56df14f9 8dd2c972cfe1a927 5d4bf4577651eb43 5bb3491c2b75fab8 aedc3fd8a5a5d83b cf9283a1ec6201ca bbd41275fda87563 719eea52d7773103 eef1093677cc32aa 31c86d1edca57854 3823140a04010000
}


// Simple test program for multiplication of two multi-precision integers using
// reduced-radix representation.

void test_mul_redradix(int limbs)
{
  int words = (limbs*LIMBBITS + 63)/64;
  uint64_t arr[limbs], brr[limbs], crr[2*limbs], rrr[2*limbs];
  uint64_t afr[words], bfr[words], rfr[2*words];  // to check result
  int i;
  
  mpi_init(arr, limbs);
  mpi_init(brr, limbs);
  
  mpi_print("a = ", arr, limbs);
  mpi_print("b = ", brr, limbs);
  mpi_mul_redradix(rrr, arr, brr, limbs);
  mpi_print("r = ", rrr, 2*limbs);
  
  // assembly implementation
  for (i = 0; i < 2*limbs; i++) rrr[i] = 0;
  mpi_mul_4x4rr_isa(rrr, arr, brr, limbs);
  mpi_print("r = ", rrr, 2*limbs);
  
  // check result with full-radix mul
  mpi_red2full(afr, words, arr, limbs);
  mpi_red2full(bfr, words, brr, limbs);
  mpi_mul_fullradix(rfr, afr, bfr, words);
  mpi_full2red(crr, 2*limbs, rfr, 2*words);
  mpi_print("c = ", crr, 2*limbs);
  if (mpi_compare(rrr, crr, 2*limbs) != 0) printf("Result Wrong!!!\n");
  
  // expected output for limbs = 8 and LIMBBITS = 60:
  // a = 0f3e3d3c3b3a3938 0736353433323130 0f2e2d2c2b2a2928 0726252423222120 0f1e1d1c1b1a1918 0716151413121110 0f0e0d0c0b0a0908 0706050403020100
  // b = 0f3e3d3c3b3a3938 0736353433323130 0f2e2d2c2b2a2928 0726252423222120 0f1e1d1c1b1a1918 0716151413121110 0f0e0d0c0b0a0908 0706050403020100
  // r = 0e85a4ec6c3454de 052124efa056304f 050d9e85f2111121 05881477efb91137 0ad68e8f249b3f5e 0c360f941f0bb57a 0dec9f506a578257 0737408c94d2bfd7 0fcb1d8f8973b6bc 0a39f1293b81540e 0d8be127a9b1897d 02036a41c52fbca8 03db052e832f5f3f 0b552ea4d4dbd6e3 04ac5f5baf689543 0823140a04010000
  // r = 0e85a4ec6c3454de 052124efa056304f 050d9e85f2111121 05881477efb91137 0ad68e8f249b3f5e 0c360f941f0bb57a 0dec9f506a578257 0737408c94d2bfd7 0fcb1d8f8973b6bc 0a39f1293b81540e 0d8be127a9b1897d 02036a41c52fbca8 03db052e832f5f3f 0b552ea4d4dbd6e3 04ac5f5baf689543 0823140a04010000
  // c = 0e85a4ec6c3454de 052124efa056304f 050d9e85f2111121 05881477efb91137 0ad68e8f249b3f5e 0c360f941f0bb57a 0dec9f506a578257 0737408c94d2bfd7 0fcb1d8f8973b6bc 0a39f1293b81540e 0d8be127a9b1897d 02036a41c52fbca8 03db052e832f5f3f 0b552ea4d4dbd6e3 04ac5f5baf689543 0823140a04010000
}


/*
int main(void)
{
  // test_conversion();
  // test_mul_fullradix(8);
  test_mul_redradix(8);
  return 0;
}
*/

