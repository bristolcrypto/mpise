#ifndef _MONCURVE_H
#define _MONCURVE_H


#include "share.h"
#include "gfparith.h"


typedef struct projective_point {
  Limb x[NLIMBS];  
  Limb y[NLIMBS];  
  Limb z[NLIMBS];  
} ProPoint;

void mon_ladder_step(ProPoint *p, ProPoint *q, const Limb *xd);
void mon_mul_varbase(Word *r, const Word *k, const Word *x);

#endif 
