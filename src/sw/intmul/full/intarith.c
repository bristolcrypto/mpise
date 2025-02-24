#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "intarith.h"


#define ROTL(x, dist) (((x) << (dist)) | ((x) >> (64 - (dist))))
#define ROTR(x, dist) (((x) >> (dist)) | ((x) << (64 - (dist))))


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


// Initialization of a multi-precision integer

void mpi_init(uint64_t *r, uint64_t word, uint64_t mask, int len)
{
  int i;
  
  for (i = 0; i < len; i++) {
    r[i] = (ROTL(word, 4*(i & 15)) & mask);
  }
}


// Printing of a multi-precision integer

// __attribute__((noinline))
void mpi_print(const char *c, const uint64_t *a, int len)
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


// Conversion full radix -> reduced radix

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


// Conversion reduced radix -> full radix

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
////// Full/reduced-radix multiplication modelling ISA/ISE implementation /////
///////////////////////////////////////////////////////////////////////////////


// The function ` mpi_mul_1x1fr_isa` multiplies two multi-precision integers
// using the full-radix representation. Note that, when the two operands are 
// represented as full-radix (i.e., 64-bits-per-word) integers, the operand-
// scanning method is easier to implement in C (and usually also faster) than
// the product-scanning method, whereas the opposite is the case for Assembly,
// i.e., an Assembly implementation of the product-scanning method normally
// outperforms the operand-scanning method. Hence, the "ISA" C implementation
// below is based on operand scanning, but the "ISA" Assembly implementation
// follows the product-scanning approach. As indicated by the "1x1" in the
// function name, the implementation processes one word operand `a` and one
// word of operand `b` in each iteration of the inner loop.

void mpi_mul_1x1fr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                       int len)
{
  __uint128_t prod = 0;
  int i, j;
  
  // multiplication of A by b[0]
  for (j = 0; j < len; j++) {
    prod += (__uint128_t) a[j]*b[0];
    r[j] = (uint64_t) prod;
    prod >>= 64;
  }
  r[j] = (uint64_t) prod;
  
  // multiplication of A by b[i] for 1 <= i < len
  for (i = 1; i < len; i++) {
    prod = 0;
    for (j = 0; j < len; j++) {
      prod += (__uint128_t) a[j]*b[i];
      prod += r[i+j];
      r[i+j] = (uint64_t) prod;
      prod >>= 64;
    }
    r[i+j] = (uint64_t) prod;
  }
}


// The function ` mpi_mul_1x1fr_ise` multiplies two multi-precision integers
// using the full-radix representation. This C implementation executes the
// three custom instructions `maccfrhu`, `maccfrlu`, and `cacc`; thereby it
// mimics the "ISE" Assembly implementation. As indicated by the "1x1" in the
// function name, the implementation processes one word operand `a` and one
// word of operand `b` in each iteration of the inner loops.

void mpi_mul_1x1fr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                       int len)
{
  uint64_t t, h = 0, m = 0, l = 0;
  int i, j, k;
  
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


// The function ` mpi_mul_1x1rr_isa` multiplies two multi-precision integers
// using the reduced-radix representation. This C implementation adds the two-
// limb product a[j]*b[k] to a 128-bit accumulator, which means the maximum
// number of limbs is $2^(128-2*LIMBBITS)$. For example, when LIMBBITS is 60,
// the maximum number of limbs of the two operands is 256. As indicated by the
// "1x1" in the function name, the implementation processes one word operand
// `a` and one word of operand `b` in each iteration of the inner loops.

void mpi_mul_1x1rr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                      int len)
{
  __uint128_t prod = 0;
  int i, j, k;
  
  // len iterations of 1st outer loop
  for (i = 0; i < len; i++) {
    k = i;  // to access b[k]
    for (j = 0; j <= i; j++) {
      prod += (__uint128_t) a[j]*b[k];
      k--;
    }
    r[i] = ((uint64_t) prod) & LIMBMASK;
    prod >>= LIMBBITS;
  }
  
  // len-1 iterations of 2nd outer loop
  for (i = len; i < 2*len - 1; i++) {
    k = len - 1;  // to access b[k]
    for (j = i - k; j < len; j++) {
      prod += (__uint128_t) a[j]*b[k];
      k--;
    }
    r[i] = ((uint64_t) prod) & LIMBMASK;
    prod >>= LIMBBITS;
  }
  r[2*len-1] = (uint64_t) prod;
}


// The function ` mpi_mul_1x1rr_ise` multiplies two multi-precision integers
// using the reduced-radix representation. This C implementation executes the
// three custom instructions `maccrrhu`, `maccrrlu`, and `sraiadd`; thereby it
// mimics the "ISE" Assembly implementation. This C implementation adds the
// lower half and the upper half of the two-limb product a[j]*b[k] separately
// to a 64-bit accumulator (i.e., one for each half), which means the maximum
// number of limbs is $2^(64-LIMBBITS)$. For example, when LIMBBITS is 60, the
// maximum number of limbs of the two operands is 16. As indicated by the "1x1"
// in the function name, the implementation processes one word operand `a` and
// one word of operand `b` in each iteration of the inner loops.

void mpi_mul_1x1rr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, \
                      int len)
{
  uint64_t h = 0, l = 0;
  int i, j, k;
  
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
  
  // initialization of operand
  mpi_init(a, AWORD, ALL1WORD, 80);
  
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
  
  // initialization of operands
  mpi_init(a, AWORD, ALL1WORD, words);
  mpi_init(b, BWORD, ALL1WORD, words);
  
  mpi_print("a = ", a, words);
  mpi_print("b = ", b, words);
  mpi_mul_1x1fr_ise(r, a, b, words);  // C implementation
  // mpi_mul_4x4fr_isa(r, a, b, words);  // Asm implementation
  mpi_print("r = ", r, 2*words);
  
  // check result
  mpi_mul_1x1fr_isa(c, a, b, words);
  mpi_print("c = ", c, 2*words);
  if (mpi_compare(r, c, 2*words) != 0) printf("Result Wrong!!!\n");
  
  // expected output for words = 8 and LIMBBITS = 64:
  // a = 789abcdef0123456 6789abcdef012345 56789abcdef01234 456789abcdef0123 3456789abcdef012 23456789abcdef01 123456789abcdef0 0123456789abcdef
  // b = 876543210fedcba9 9876543210fedcba a9876543210fedcb ba9876543210fedc cba9876543210fed dcba9876543210fe edcba9876543210f fedcba9876543210
  // r = 3fc94e4627701a9e 70f037befb142be9 c2f19545773d5bed 66009a0ccdeedddc 8e1079483248e4ea 6e6f662ad77d744a 3a5333e7f0bfac2f 24ef4eb2b142be9b e9c7cc7feb38be03 9e75a6ba31bfe905 abe2a67ff7396cc6 dedb989e75a21614 042d49e27fa9b1b9 e8a48718e26c3c85 590e1d0e6aba8643 2236d88fe5618cf0
  // c = 3fc94e4627701a9e 70f037befb142be9 c2f19545773d5bed 66009a0ccdeedddc 8e1079483248e4ea 6e6f662ad77d744a 3a5333e7f0bfac2f 24ef4eb2b142be9b e9c7cc7feb38be03 9e75a6ba31bfe905 abe2a67ff7396cc6 dedb989e75a21614 042d49e27fa9b1b9 e8a48718e26c3c85 590e1d0e6aba8643 2236d88fe5618cf0
}


// Simple test program for multiplication of two multi-precision integers using
// reduced-radix representation.

void test_mul_redradix(int limbs)
{
  uint64_t a[limbs], b[limbs], c[2*limbs], r[2*limbs];
  // int words = (limbs*LIMBBITS + 63)/64;  // operand length full-radix
  // uint64_t afr[words], bfr[words], rfr[2*words];  // to verify result
  
  // initialization of operands
  mpi_init(a, AWORD, LIMBMASK, limbs);
  mpi_init(b, BWORD, LIMBMASK, limbs);
  
  mpi_print("a = ", a, limbs);
  mpi_print("b = ", b, limbs);
  mpi_mul_1x1rr_ise(r, a, b, limbs);  // C implementation
  // mpi_mul_4x4rr_isa(r, a, b, limbs);  // Asm implementation
  mpi_print("r = ", r, 2*limbs);
  
  // check result
  mpi_mul_1x1rr_isa(c, a, b, limbs);
  mpi_print("c = ", c, 2*limbs);
  if (mpi_compare(r, c, 2*limbs) != 0) printf("Result Wrong!!!\n");
  
  /*
  // check result with full-radix mul
  mpi_red2full(afr, words, a, limbs);
  mpi_red2full(bfr, words, b, limbs);
  mpi_mul_1x1fr_isa(rfr, afr, bfr, words);
  mpi_full2red(c, 2*limbs, rfr, 2*words);
  mpi_print("c = ", c, 2*limbs);
  if (mpi_compare(r, c, 2*limbs) != 0) printf("Result Wrong!!!\n");
  */
  
  // expected output for limbs = 8 and LIMBBITS = 60:
  // a = 089abcdef0123456 0789abcdef012345 06789abcdef01234 056789abcdef0123 0456789abcdef012 03456789abcdef01 023456789abcdef0 0123456789abcdef
  // b = 076543210fedcba9 0876543210fedcba 09876543210fedcb 0a9876543210fedc 0ba9876543210fed 0cba9876543210fe 0dcba9876543210f 0edcba9876543210
  // r = 03fa278386ef7590 0a62fb4ac901d0bd 03c86541d5994aa2 016ea9acefea2783 085a0cd05c27aba5 0ce9d2f05e950b4d 0364e0513b7679be 000fb23737103a2b 0e9534a4ef64bc7f 035679e61cd2f2f5 062c3a081eaaf9a2 02d230c71db88c41 050419dedb98668e 087db10b14555445 08fab20783af1222 0236d88fe5618cf0
  // c = 03fa278386ef7590 0a62fb4ac901d0bd 03c86541d5994aa2 016ea9acefea2783 085a0cd05c27aba5 0ce9d2f05e950b4d 0364e0513b7679be 000fb23737103a2b 0e9534a4ef64bc7f 035679e61cd2f2f5 062c3a081eaaf9a2 02d230c71db88c41 050419dedb98668e 087db10b14555445 08fab20783af1222 0236d88fe5618cf0
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

