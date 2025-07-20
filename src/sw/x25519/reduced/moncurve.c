#include "moncurve.h"


static void mon_cswap_point(ProPoint *p, ProPoint *q, int cbit)
{
  Limb mask, tx, tz;
  int i;
  
  cbit &= 1;  
  mask = ~((Limb) cbit) + 1;
  
  for (i = 0; i < NLIMBS; i++) {
    tx = (p->x[i] ^ q->x[i]) & mask;
    tz = (p->z[i] ^ q->z[i]) & mask;
    p->x[i] ^= tx;
    p->z[i] ^= tz;
    q->x[i] ^= tx;
    q->z[i] ^= tz; 
  }
}


void mon_ladder_step(ProPoint *p, ProPoint *q, const Limb *xd)
{
  Limb *tmp1 = p->y, *tmp2 = q->y;
  
  gfp_add(tmp1, p->x, p->z);
  gfp_sub(p->x, p->x, p->z);
  gfp_add(tmp2, q->x, q->z);
  gfp_sub(q->x, q->x, q->z);
  gfp_sqr(p->z, tmp1);
  gfp_mul(q->z, tmp2, p->x);
  gfp_mul(tmp2, q->x, tmp1);
  gfp_sqr(tmp1, p->x);
  gfp_mul(p->x, p->z, tmp1);
  gfp_sub(tmp1, p->z, tmp1);
  gfp_mul32(q->x, tmp1, (CONSTA-2)/4);
  gfp_add(q->x, q->x, p->z);
  gfp_mul(p->z, q->x, tmp1);
  gfp_add(tmp1, tmp2, q->z);
  gfp_sqr(q->x, tmp1);
  gfp_sub(tmp1, tmp2, q->z);
  gfp_sqr(tmp2, tmp1);
  gfp_mul(q->z, tmp2, xd);
}


void mon_mul_varbase(Word *r, const Word *k, const Word *x)
{
  ProPoint p1, p2;
  Word kp[NWORDS];
  Limb xrr[NLIMBS];
  int i, b, s = 0;
  
  // prune scalar k
  for (i = 0; i < NWORDS; i++) kp[i] = k[i];
  kp[0] &= (Word) ~(7ULL);                      // 0xFFF..FF8 
  kp[NWORDS-1] &= (Word) ~(1ULL << (WBITS-1));  // 0x7FF..FFF
  kp[NWORDS-1] |= (Word) (1ULL << (WBITS-2));   // 0x400..000
  
  // full -> reduced radix
  mpi_full2red(xrr, NLIMBS, x, NWORDS);
  
  // initialize ladder
  for (i = 0; i < NLIMBS; i++) {
    p1.x[i] = p1.z[i] = p2.z[i] = 0;
    p2.x[i] = xrr[i];
  }
  p1.x[0] = p2.z[0] = 1;
  
  // main ladder loop
  for (i = 254; i >= 0; i--) {
    b = kp[i>>WPOW2] >> (i & (WBITS-1));
    s = s ^ b;
    mon_cswap_point(&p1, &p2, s);
    mon_ladder_step(&p1, &p2, xrr);
    s = b;
  }
  mon_cswap_point(&p1, &p2, s);
  
  // projective -> affine
  gfp_inv(p2.y, p1.z);
  gfp_mul(xrr, p2.y, p1.x);
  
  // reduced -> full radix
  gfp_canon(xrr, xrr);
  mpi_red2full(r, NWORDS, xrr, NLIMBS);
}


/*
void test_point_mul(void)
{
  Word rf[NWORDS], kf[NWORDS], xf[NWORDS];
  static const char kh[] =  // scalar k for testing
    "0xC49A44BA44226A50185AFCC10A4C1462DD5E46824B15163B9D7C52F06BE346A5";
  static const char xh[] =  // x-coordinate for testing
    "0x4C1CABD0A603A9103B35B326EC2466727C5FB124A4C19435DB3030586768DBE6";
  static const char eh[] =  // expected result
    "0x5285A2775507B454F7711C4903CFEC324F088DF24DEA948E90C6E99D3755DAC3";
  char rh[2*WBYTES*NWORDS+3];
  
  hex_to_int(kf, kh, NWORDS);
  hex_to_int(xf, xh, NWORDS);
  
  mon_mul_varbase(rf, kf, xf);
  
  int_to_hex(rh, rf, NWORDS);
  printf("x = %s\n", xh);
  printf("k = %s\n", kh);
  printf("r = %s\n", rh);
  if (strcmp(rh, eh) != 0) printf("result is wrong!!!\n");
}
*/
