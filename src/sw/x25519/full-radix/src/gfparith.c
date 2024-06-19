#include "gfparith.h"

void gfp_inv(uint64_t *r, const uint64_t *a)
{
  uint64_t t0[NLMB64], t1[NLMB64], t2[NLMB64], t3[NLMB64];
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
