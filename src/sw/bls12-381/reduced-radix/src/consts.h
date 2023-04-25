#ifndef __BLS12_381_ASM_CONST_H__
#define __BLS12_381_ASM_CONST_H__


#include "vect.h"


extern const vec384 BLS12_381_P;
static const limb_t p0 = (limb_t)0x0073fffcfffcfffd;  /* -1/P */
typedef union { vec384 p12[12]; vec384x p2; vec384 p; } radix384;
extern const radix384 BLS12_381_Rx; /* (1<<385)%P, "radix", one-in-Montgomery */

#define ONE_MONT_P TO_LIMB_T(0x1300000006554F), \
                   TO_LIMB_T(0x0031AD88000A64), \
                   TO_LIMB_T(0x36C376ED46E4F0), \
                   TO_LIMB_T(0x68FCDE5ABB02F0), \
                   TO_LIMB_T(0x22C038B256521E), \
                   TO_LIMB_T(0x518D9E51AF202C), \
                   TO_LIMB_T(0x047AEAE76EE078)

#endif
