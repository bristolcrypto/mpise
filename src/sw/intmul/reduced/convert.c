#include <stdint.h>
#include <stdio.h>
#include <string.h>


#define LIMBBITS 60
#define LIMBMASK (0xFFFFFFFFFFFFFFFFULL >> (64 - (LIMBBITS)))


// Prototoype

void mpi64_print(const char *c, const uint64_t *a, int len);


// Initialization of Operands

void init_bytearray(uint8_t *r, int len)
{
  int i;

  for (i = 0; i < len; i++) {
    r[i] = (uint8_t) i;
  }
}


// Conversion full-radix -> reduced radix

void convert_full2red(uint64_t *r, int rlen, const uint64_t *a, int alen)
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

void convert_red2full(uint64_t *r, int rlen, const uint64_t *a, int alen)
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


// Simple test function for convesion between full-radix and reduced-radix 
// representation

void test_conversion(void)
{
  uint64_t x[120], z[80], a[80];
  int len, numlimbs;
  
  init_bytearray((uint8_t *) a, 80*sizeof(uint64_t));
  
  for (len = 4; len < 80; len++) {
    numlimbs = (64*len + LIMBBITS - 1)/LIMBBITS;
    printf("len = %i, numlimbs = %i\n", len, numlimbs);
    mpi64_print("a = ", a, len);
    convert_full2red(x, numlimbs, a, len);
    mpi64_print("x = ", x, numlimbs);
    convert_red2full(z, len, x, numlimbs);
    mpi64_print("z = ", z, len);
  }
}
