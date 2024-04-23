#include "point.h"
#include "fields.h"

const POINTonE1 BLS12_381_G1 = {    /* generator point [in Montgomery] */
  /* (0x17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905
   *    a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb << 385) % P */
  { TO_LIMB_T(0x680F21FAA66D81), TO_LIMB_T(0x71A10333FFD5FE),
    TO_LIMB_T(0x34C719357B460F), TO_LIMB_T(0x20E5DE761B72C7),
    TO_LIMB_T(0x43BAA7CE58A16F), TO_LIMB_T(0x0A321026BC400D),
    TO_LIMB_T(0x0280772640A604) },
  /* (0x08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af6
   *    00db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1 << 385) % P */
  { TO_LIMB_T(0x5927AA19CE44E2), TO_LIMB_T(0x0C69E463F63AEA),
    TO_LIMB_T(0x1AB8392E746113), TO_LIMB_T(0x0405194DD595F1),
    TO_LIMB_T(0x0B380A358B052A), TO_LIMB_T(0x1A8387230FEB40),
    TO_LIMB_T(0x05DE1F7E280451) },
  { ONE_MONT_P }
};

static void POINTonE1_from_Jacobian(POINTonE1 *out, const POINTonE1 *in)
{
    vec384 Z, ZZ;
    limb_t inf = vec_is_zero(in->Z, sizeof(in->Z));

    reciprocal_fp(Z, in->Z);                            /* 1/Z   */

    sqr_fp(ZZ, Z);
    mul_fp(out->X, in->X, ZZ);                          /* X = X/Z^2 */

    mul_fp(ZZ, ZZ, Z);
    mul_fp(out->Y, in->Y, ZZ);                          /* Y = Y/Z^3 */

    vec_select(out->Z, in->Z, BLS12_381_G1.Z,
                       sizeof(BLS12_381_G1.Z), inf);    /* Z = inf ? 0 : 1 */
}

void POINTonE1_to_affine(POINTonE1_affine *out, const POINTonE1 *in)
{
    POINTonE1 p;

    if (!vec_is_equal(in->Z, BLS12_381_Rx.p, sizeof(in->Z))) {
        POINTonE1_from_Jacobian(&p, in);
        in = &p;
    }
    vec_copy(out, in, sizeof(*out));
}
