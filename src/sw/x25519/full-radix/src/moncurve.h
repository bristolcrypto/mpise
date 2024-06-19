#ifndef _MONCURVE_H
#define _MONCURVE_H


#include "share.h"
#include "gfparith.h"


typedef struct projective_point {
  uint64_t x[NLMB64];  
  uint64_t y[NLMB64];  
  uint64_t z[NLMB64];  
} ProPoint;

void mon_ladder_step(ProPoint *p, ProPoint *q, const uint64_t *xd);
void mon_mul_varbase(uint64_t *r, const uint64_t *k, const uint64_t *x);

#endif 
