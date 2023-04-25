#include "consts.h"


/* z = -0xd201000000010000 */
const vec384 BLS12_381_P = {    /* (z-1)^2 * (z^4 - z^2 + 1)/3 + z */
    TO_LIMB_T(0x7EFFFFFFFFAAAB), TO_LIMB_T(0x7FFD62A7FFFF73),
    TO_LIMB_T(0x03DAC3D8907AAF), TO_LIMB_T(0x1C2895FB398695),
    TO_LIMB_T(0x3ACD764774B84F), TO_LIMB_T(0x53496374F6C869),
    TO_LIMB_T(0x0680447A8E5FF9)
};

const radix384 BLS12_381_Rx = { /* (1<<385)%P, "radix", one-in-Montgomery */
  { { ONE_MONT_P },
    { 0 } }
};
