#ifndef __BLS12_381_ASM_PAIRING_H__
#define __BLS12_381_ASM_PAIRING_H__

#include "fields.h"
#include "point.h"
#include "consts.h"

void optimal_ate_pairing(vec384fp12 ret, POINTonE2_affine Q[], 
                                         POINTonE1_affine P[], size_t n);

#endif 
