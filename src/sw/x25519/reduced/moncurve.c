#include "moncurve.h"


static void mon_cswap_point(ProPoint *p, ProPoint *q, int cbit)
{
  uint64_t mask, tx, tz;
  int i;

  cbit &= 1;  
  mask = ~((uint64_t) cbit) + 1;

  for (i = 0; i < NLMB51; i++) {
    tx = (p->x[i] ^ q->x[i]) & mask;
    tz = (p->z[i] ^ q->z[i]) & mask;
    p->x[i] ^= tx;
    p->z[i] ^= tz;
    q->x[i] ^= tx;
    q->z[i] ^= tz; 
  }
}

void mon_ladder_step(ProPoint *p, ProPoint *q, const uint64_t *xd)
{
  uint64_t *tmp1 = p->y, *tmp2 = q->y;

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
  gfp_mul51(q->x, tmp1, (CONSTA-2)/4);
  gfp_add(q->x, q->x, p->z);
  gfp_mul(p->z, q->x, tmp1);
  gfp_add(tmp1, tmp2, q->z);
  gfp_sqr(q->x, tmp1);
  gfp_sub(tmp1, tmp2, q->z);
  gfp_sqr(tmp2, tmp1);
  gfp_mul(q->z, tmp2, xd);
}

void mon_mul_varbase(uint64_t *r, const uint64_t *k, const uint64_t *x)
{
  ProPoint p1, p2;
  uint64_t kp[4], x51[NLMB51];
  int i, b, s = 0;

  // prune scalar k
  for (i = 0; i < 4; i++) kp[i] = k[i];
  kp[0] &= 0xFFFFFFFFFFFFFFF8ULL; 
  kp[3] &= 0x7FFFFFFFFFFFFFFFULL; 
  kp[3] |= 0x4000000000000000ULL;

  // convert x-coordinate to radix-2^51
  mpi_conv_64to51(x51, x);

  // initialize ladder
  for (i = 0; i < NLMB51; i++) {
    p1.x[i] = p1.z[i] = p2.z[i] = 0;
    p2.x[i] = x51[i];
  }
  p1.x[0] = p2.z[0] = 1;

  // main ladder loop
  for (i = 254; i >= 0; i--) {
    b = kp[i>>6] >> (i & 63);
    s = s ^ b;
    mon_cswap_point(&p1, &p2, s);
    mon_ladder_step(&p1, &p2, x51);
    s = b;
  } 

  mon_cswap_point(&p1, &p2, s);

  // projective -> affine
  gfp_inv(p2.y, p1.z);
  gfp_mul(x51, p2.y, p1.x);

  // convert x-coordinate to radix-2^64
  mpi51_carry_prop(x51);
  mpi_conv_51to64(r, x51);
}
