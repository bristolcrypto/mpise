#include "gfparith.h"


///////////////////////////////////////////////////////////////////////////////
#if ( MPISE_XLEN == 32 ) // FIELD_ARITHMETIC FOR 32-BIT TARGETS ///////////////
///////////////////////////////////////////////////////////////////////////////


void gfp_mul_ref(Limb *r, const Limb *a, const Limb *b)
{
  Limb t[2*NLIMBS];  // temporary array for product
  uint64_t prod = 0;
  const Limb CCON = 64*19;
  int i, j, k;
  
  // NLIMBS iterations of 1st outer loop
  for (i = 0; i <= NLIMBS - 1; i++) {
    for (j = 0, k = i; k >= 0; j++, k--) {
      prod += (uint64_t) a[j]*b[k];
    }
    t[i] = ((Limb) prod) & LIMBMASK;
    prod >>= LBITS;
  }
  
  // NLIMBS-1 iterations of 2nd outer loop
  for (i = NLIMBS; i < 2*NLIMBS - 1; i++) {
    for (j = i - (NLIMBS - 1), k = NLIMBS - 1; j <= NLIMBS - 1; j++, k--) {
      prod += (uint64_t) a[j]*b[k];
    }
    t[i] = ((Limb) prod) & LIMBMASK;
    prod >>= LBITS;
  }
  t[i] = (Limb) prod;
  
  // modular reduction
  prod = 0;
  for (i = 0; i < NLIMBS; i++) {
    prod += (uint64_t) t[i+NLIMBS]*CCON + t[i];
    r[i] = ((Limb) prod) & LIMBMASK;
    prod >>= LBITS;
  }
  r[0] += ((Limb) prod)*CCON;
}


void gfp_mul_opt(Limb *r, const Limb *a, const Limb *b)
{
  Limb t[NLIMBS];  // to prevent overwriting of a, b
  uint64_t sumhi, sumlo;
  const Limb CCON = 64*19;
  
  // limb-products yielding t[8]
  sumlo  = (uint64_t) a[0]*b[8] + (uint64_t) a[1]*b[7] + (uint64_t) a[2]*b[6];
  sumlo += (uint64_t) a[3]*b[5] + (uint64_t) a[4]*b[4] + (uint64_t) a[5]*b[3];
  sumlo += (uint64_t) a[6]*b[2] + (uint64_t) a[7]*b[1] + (uint64_t) a[8]*b[0];
  t[8] = ((Limb) sumlo) & LIMBMASK;
  sumlo = (sumlo >>= LBITS)*CCON;
  
  // limb-products yielding t[0]
  sumlo += (uint64_t) a[0]*b[0];
  sumhi  = (uint64_t) a[1]*b[8] + (uint64_t) a[2]*b[7] + (uint64_t) a[3]*b[6];
  sumhi += (uint64_t) a[4]*b[5] + (uint64_t) a[5]*b[4] + (uint64_t) a[6]*b[3];
  sumhi += (uint64_t) a[7]*b[2] + (uint64_t) a[8]*b[1];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[0] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[1]
  sumlo += (uint64_t) a[0]*b[1] + (uint64_t) a[1]*b[0];
  sumhi += (uint64_t) a[2]*b[8] + (uint64_t) a[3]*b[7] + (uint64_t) a[4]*b[6];
  sumhi += (uint64_t) a[5]*b[5] + (uint64_t) a[6]*b[4] + (uint64_t) a[7]*b[3];
  sumhi += (uint64_t) a[8]*b[2];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[1] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[2]
  sumlo += (uint64_t) a[0]*b[2] + (uint64_t) a[1]*b[1] + (uint64_t) a[2]*b[0];
  sumhi += (uint64_t) a[3]*b[8] + (uint64_t) a[4]*b[7] + (uint64_t) a[5]*b[6];
  sumhi += (uint64_t) a[6]*b[5] + (uint64_t) a[7]*b[4] + (uint64_t) a[8]*b[3];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[2] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[3]
  sumlo += (uint64_t) a[0]*b[3] + (uint64_t) a[1]*b[2] + (uint64_t) a[2]*b[1];
  sumlo += (uint64_t) a[3]*b[0];
  sumhi += (uint64_t) a[4]*b[8] + (uint64_t) a[5]*b[7] + (uint64_t) a[6]*b[6];
  sumhi += (uint64_t) a[7]*b[5] + (uint64_t) a[8]*b[4];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[3] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[4]
  sumlo += (uint64_t) a[0]*b[4] + (uint64_t) a[1]*b[3] + (uint64_t) a[2]*b[2];
  sumlo += (uint64_t) a[3]*b[1] + (uint64_t) a[4]*b[0];
  sumhi += (uint64_t) a[5]*b[8] + (uint64_t) a[6]*b[7] + (uint64_t) a[7]*b[6];
  sumhi += (uint64_t) a[8]*b[5];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[4] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[5]
  sumlo += (uint64_t) a[0]*b[5] + (uint64_t) a[1]*b[4] + (uint64_t) a[2]*b[3];
  sumlo += (uint64_t) a[3]*b[2] + (uint64_t) a[4]*b[1] + (uint64_t) a[5]*b[0];
  sumhi += (uint64_t) a[6]*b[8] + (uint64_t) a[7]*b[7] + (uint64_t) a[8]*b[6];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[5] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[6]
  sumlo += (uint64_t) a[0]*b[6] + (uint64_t) a[1]*b[5] + (uint64_t) a[2]*b[4];
  sumlo += (uint64_t) a[3]*b[3] + (uint64_t) a[4]*b[2] + (uint64_t) a[5]*b[1];
  sumlo += (uint64_t) a[6]*b[0];
  sumhi += (uint64_t) a[7]*b[8] + (uint64_t) a[8]*b[7]; 
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[6] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[7]
  sumlo += (uint64_t) a[0]*b[7] + (uint64_t) a[1]*b[6] + (uint64_t) a[2]*b[5];
  sumlo += (uint64_t) a[3]*b[4] + (uint64_t) a[4]*b[3] + (uint64_t) a[5]*b[2];
  sumlo += (uint64_t) a[6]*b[1] + (uint64_t) a[7]*b[0];
  sumhi += (uint64_t) a[8]*b[8]; 
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[7] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // final modulo reduction step
  sumlo += (uint64_t) sumhi*CCON + t[8];
  t[8] = ((Limb) sumlo) & LIMBMASK;
  sumlo = (sumlo >> LBITS)*CCON;
  t[0] += (Limb) sumlo;
  
  // final result has to be in r
  r[0] = t[0]; r[1] = t[1]; r[2] = t[2];
  r[3] = t[3]; r[4] = t[4]; r[5] = t[5];
  r[6] = t[6]; r[7] = t[7]; r[8] = t[8];
}


void gfp_sqr_opt(Limb *r, const Limb *a)
{
  Limb t[NLIMBS];  // to prevent overwriting of a
  uint64_t sumhi, sumlo, sumx2;
  const Limb CCON = 64*19;
  
  // limb-products yielding t[8]
  sumx2  = (uint64_t) a[0]*a[8] + (uint64_t) a[1]*a[7] + (uint64_t) a[2]*a[6];
  sumx2 += (uint64_t) a[3]*a[5];
  sumlo  = 2*sumx2 + (uint64_t) a[4]*a[4];
  t[8] = ((Limb) sumlo) & LIMBMASK;
  sumlo = (sumlo >>= LBITS)*CCON;
  
  // limb-products yielding t[0]
  sumlo += (uint64_t) a[0]*a[0];
  sumx2  = (uint64_t) a[1]*a[8] + (uint64_t) a[2]*a[7] + (uint64_t) a[3]*a[6];
  sumx2 += (uint64_t) a[4]*a[5];
  sumhi  = 2*sumx2;
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[0] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[1]
  sumx2  = (uint64_t) a[0]*a[1];
  sumlo += 2*sumx2;
  sumx2  = (uint64_t) a[2]*a[8] + (uint64_t) a[3]*a[7] + (uint64_t) a[4]*a[6];
  sumhi += 2*sumx2 + (uint64_t) a[5]*a[5];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[1] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[2]
  sumx2  = (uint64_t) a[0]*a[2];
  sumlo += 2*sumx2 + (uint64_t) a[1]*a[1];
  sumx2  = (uint64_t) a[3]*a[8] + (uint64_t) a[4]*a[7] + (uint64_t) a[5]*a[6];
  sumhi += 2*sumx2;
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[2] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[3]
  sumx2  = (uint64_t) a[0]*a[3] + (uint64_t) a[1]*a[2];
  sumlo += 2*sumx2;
  sumx2  = (uint64_t) a[4]*a[8] + (uint64_t) a[5]*a[7];
  sumhi += 2*sumx2 + (uint64_t) a[6]*a[6];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[3] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[4]
  sumx2  = (uint64_t) a[0]*a[4] + (uint64_t) a[1]*a[3];
  sumlo += 2*sumx2 + (uint64_t) a[2]*a[2];
  sumx2  = (uint64_t) a[5]*a[8] + (uint64_t) a[6]*a[7];
  sumhi += 2*sumx2;
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[4] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[5]
  sumx2  = (uint64_t) a[0]*a[5] + (uint64_t) a[1]*a[4] + (uint64_t) a[2]*a[3];
  sumlo += 2*sumx2;
  sumx2  = (uint64_t) a[6]*a[8];
  sumhi += 2*sumx2 + (uint64_t) a[7]*a[7];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[5] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[6]
  sumx2  = (uint64_t) a[0]*a[6] + (uint64_t) a[1]*a[5] + (uint64_t) a[2]*a[4];
  sumlo += 2*sumx2 + (uint64_t) a[3]*a[3];
  sumx2  = (uint64_t) a[7]*a[8];
  sumhi += 2*sumx2;
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[6] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // limb-products yielding t[7]
  sumx2  = (uint64_t) a[0]*a[7] + (uint64_t) a[1]*a[6] + (uint64_t) a[2]*a[5];
  sumx2 += (uint64_t) a[3]*a[4];
  sumlo += 2*sumx2;
  sumhi += (uint64_t) a[8]*a[8];
  sumlo += (uint64_t) (sumhi & LIMBMASK)*CCON;
  t[7] = ((Limb) sumlo) & LIMBMASK;
  sumhi >>= LBITS;
  sumlo >>= LBITS;
  
  // final modulo reduction step
  sumlo += (uint64_t) sumhi*CCON + t[8];
  t[8] = ((Limb) sumlo) & LIMBMASK;
  sumlo = (sumlo >> LBITS)*CCON;
  t[0] += (Limb) sumlo;
  
  // final result has to be in r
  r[0] = t[0]; r[1] = t[1]; r[2] = t[2];
  r[3] = t[3]; r[4] = t[4]; r[5] = t[5];
  r[6] = t[6]; r[7] = t[7]; r[8] = t[8];
}


void gfp_add_opt(Limb *r, const Limb *a, const Limb *b)
{
  Limb sum;
  const Limb CCON = 64*19;
  
  sum = a[0] + b[0];
  r[0] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[1] + b[1];
  r[1] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[2] + b[2];
  r[2] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[3] + b[3];
  r[3] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[4] + b[4];
  r[4] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[5] + b[5];
  r[5] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[6] + b[6];
  r[6] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[7] + b[7];
  r[7] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[8] + b[8];
  r[8] = sum & LIMBMASK;
  // final modulo reduction step
  r[0] += (sum >> LBITS)*CCON;
}


void gfp_sub_opt(Limb *r, const Limb *a, const Limb *b)
{
  int32_t sum;  // signed !!!
  const Limb CCON = 64*19;
  
  sum = a[0] - b[0] - 2*CCON;
  r[0] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[1] - b[1];
  r[1] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[2] - b[2];
  r[2] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[3] - b[3];
  r[3] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[4] - b[4];
  r[4] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[5] - b[5];
  r[5] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[6] - b[6];
  r[6] = sum & LIMBMASK;
  sum = (sum >> LBITS) + a[7] - b[7];
  r[7] = sum & LIMBMASK;
  sum = (sum >> LBITS) + 0x40000000 + a[8] - b[8];
  r[8] = sum & LIMBMASK;
  // final modulo reduction step
  r[0] += (sum >> LBITS)*CCON;
}


void gfp_mul32_opt(Limb *r, const Limb *a, const Limb b)
{
  uint64_t sum;
  const Limb CCON = 64*19;
  
  sum = (uint64_t) a[8]*b;
  r[8] = ((Limb) sum) & LIMBMASK;
  sum = (sum >>= LBITS)*CCON;
  sum += (uint64_t) a[0]*b;
  r[0] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[1]*b;
  r[1] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[2]*b;
  r[2] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[3]*b;
  r[3] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[4]*b;
  r[4] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[5]*b;
  r[5] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[6]*b;
  r[6] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  sum += (uint64_t) a[7]*b;
  r[7] = ((Limb) sum) & LIMBMASK;
  sum >>= LBITS;
  // final modulo reduction step
  sum += r[8];
  r[8] = ((Limb) sum) & LIMBMASK;
  r[0] += (Limb) (sum >> LBITS)*CCON;
}

/*
void test_gfp_arith(void)
{
  Limb afr[8] = { 0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF, \
                  0x01234567, 0x89ABCDEF, 0x01234567, 0x89ABCDEF };
  Limb bfr[8] = { 0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567, \
                  0x89ABCDEF, 0x01234567, 0x89ABCDEF, 0x01234567 };
  Limb rfr[9];
  Limb arr[9], brr[9], rrr[9];
  // for (int i = 0; i < 8; i++) afr[i] = bfr[i] = 0xFFFFFFFFUL;
  
  mpi_full2red(arr, 9, afr, 8);
  mpi_full2red(brr, 9, bfr, 8);
  
  mpi_print("arr = ", arr, 9);
  mpi_print("brr = ", brr, 9);
  gfp_mul_ref(rrr, arr, brr);
  mpi_print("rrr = ", rrr, 9);
  gfp_canon(rrr, rrr);
  mpi_red2full(rfr, 9, rrr, 9);
  
  mpi_print("afr = ", afr, 8);
  mpi_print("bfr = ", bfr, 8);
  mpi_print("rfr = ", rfr, 8);
  
  gfp_mul_opt(rrr, arr, brr);
  mpi_print("rrr = ", rrr, 9);
  
  gfp_mul_isa(rrr, arr, brr);
  mpi_print("rrr = ", rrr, 9);
  
  gfp_sqr_opt(rrr, arr);
  mpi_print("rrr = ", rrr, 9);
  
  gfp_sqr_isa(rrr, arr);
  mpi_print("rrr = ", rrr, 9);
  
  gfp_add_opt(rrr, arr, brr);
  mpi_print("rrr = ", rrr, 9);
  gfp_canon(rrr, rrr);
  mpi_red2full(rfr, 9, rrr, 9);
  mpi_print("rfr = ", rfr, 8);
  
  gfp_sub_opt(rrr, arr, brr);
  mpi_print("rrr = ", rrr, 9);
  gfp_canon(rrr, rrr);
  mpi_red2full(rfr, 9, rrr, 9);
  mpi_print("rfr = ", rfr, 8);
  
  gfp_sub_opt(rrr, brr, arr);
  mpi_print("rrr = ", rrr, 9);
  gfp_canon(rrr, rrr);
  mpi_red2full(rfr, 9, rrr, 9);
  mpi_print("rfr = ", rfr, 8);
  
  gfp_mul32_opt(rrr, arr, ((CONSTA-2)/4));
  mpi_print("rrr = ", rrr, 9);
  gfp_canon(rrr, rrr);
  mpi_red2full(rfr, 9, rrr, 9);
  mpi_print("rfr = ", rfr, 8);
  
  // Expected result for RADIX = 29:
  // arr = 0089abcd 1de02468 159e26af 06f78091 1456789a 179bde02 08d159e2 0d5e6f78 01234567
  // brr = 00012345 0cf13579 17bc048d 02b3c4d5 1cdef012 068acf13 0af37bc0 091a2b3c 09abcdef
  // rrr = 14cb3e15 0207cec4 0bae474a 0ce8914f 1b406586 0e3d240d 12514847 17dd1a97 0af2d329
  // afr = 89abcdef 01234567 89abcdef 01234567 89abcdef 01234567 89abcdef 01234567
  // bfr = 01234567 89abcdef 01234567 89abcdef 01234567 89abcdef 01234567 89abcdef
  // rfr = 4b3e1510 3e7622eb 91d299d1 229fb406 58671e92 06c94521 1efba352 eaf2d634
  
  // https://magma.maths.usyd.edu.au/calc/
  // afr := 0x89abcdef0123456789abcdef0123456789abcdef0123456789abcdef01234567;
  // bfr := 0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef;
  // rfr := (afr*bfr) mod (2^255 - 19);
  // print rfr:Hex;
  // rfr := (afr*afr) mod (2^255 - 19);
  // print rfr:Hex;
  // rfr := (afr*121665) mod (2^255 - 19);
  // print rfr:Hex;
  // rfr := (afr+bfr) mod (2^255 - 19);
  // print rfr:Hex;
  // rfr := (afr-bfr) mod (2^255 - 19);
  // print rfr:Hex;
}
*/

///////////////////////////////////////////////////////////////////////////////
#else /////////////// FIELD-ARITHMETIC FOR 64-BIT TARGETS /////////////////////
///////////////////////////////////////////////////////////////////////////////


// to be added


///////////////////////////////////////////////////////////////////////////////
#endif //////// FIELD-ARITHMETIC FOR 32-BIT AND 64-BIT TARGETS ////////////////
///////////////////////////////////////////////////////////////////////////////


// conversion to a canonical representation where each limb, except the most-
// significant one, consists of LBITS bits. The length of the most-significant
// limb is such that the sum of the length of all limbs is at most 256 bits.
// This means the most-signifcant limb can be shorter than LBITS (as is the
// case for LBITS = 29), but may also be 1 bit longer (e.g., if LBITS = 51).

void gfp_canon(Limb *r, const Limb *a)
{
  Limb sum;
  int i, d = LBITS - (NLIMBS*LBITS - 255);
  Limb mask = (1ULL << d) - 1;
  
  sum = (a[NLIMBS-1] >> d)*CONSTC;
  for (i = 0; i < NLIMBS - 1; i++) {
    sum += a[i];
    r[i] = sum & LIMBMASK;
    sum >>= LBITS;
  }
  r[NLIMBS-1] = sum + (a[NLIMBS-1] & mask);
}


// Fermat-based inversion (constant-time)

void gfp_inv(Limb *r, const Limb *a)
{
  Limb t0[NLIMBS], t1[NLIMBS], t2[NLIMBS], t3[NLIMBS];
  int i;
  
  gfp_sqr(t0, a);
  gfp_sqr(t1, t0);
  gfp_sqr(t1, t1);
  gfp_mul(t1, a, t1);
  gfp_mul(t0, t0, t1);
  gfp_sqr(t2, t0);
  gfp_mul(t1, t1, t2);
  gfp_sqr(t2, t1);
  for (i = 0; i < 4; i++) gfp_sqr(t2, t2);
  gfp_mul(t1, t2, t1);
  gfp_sqr(t2, t1);
  for (i = 0; i < 9; i++) gfp_sqr(t2, t2);
  gfp_mul(t2, t2, t1);
  gfp_sqr(t3, t2);
  for (i = 0; i < 19; i++) gfp_sqr(t3, t3);   
  gfp_mul(t2, t3, t2);
  gfp_sqr(t2, t2);
  for (i = 0; i < 9; i++) gfp_sqr(t2, t2);
  gfp_mul(t1, t2, t1);
  gfp_sqr(t2, t1);
  for (i = 0; i < 49; i++) gfp_sqr(t2, t2);
  gfp_mul(t2, t2, t1);
  gfp_sqr(t3, t2);
  for (i = 0; i < 99; i++) gfp_sqr(t3, t3);
  gfp_mul(t2, t3, t2);
  gfp_sqr(t2, t2);
  for (i = 0; i < 49; i++) gfp_sqr(t2, t2);
  gfp_mul(t1, t2, t1);
  gfp_sqr(t1, t1);
  for (i = 0; i < 4; i++) gfp_sqr(t1, t1);
  gfp_mul(r, t1, t0);
}
