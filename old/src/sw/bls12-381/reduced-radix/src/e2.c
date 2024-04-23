#include "point.h"
#include "fields.h"
#include "ec_ops.h"

const POINTonE2 BLS12_381_G2 = {    /* generator point [in Montgomery] */
{ /* (0x024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02
        b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8 << 385) % P */
  { TO_LIMB_T(0x651F4405281420), TO_LIMB_T(0x6C9A1ED2586BD7),
    TO_LIMB_T(0x29F1572C059FAF), TO_LIMB_T(0x23CAEE9A1A893B),
    TO_LIMB_T(0x66CD73129333A3), TO_LIMB_T(0x35DBD9EDD8C618),
    TO_LIMB_T(0x02C0C8C921A85E) },
  /* (0x13e02b6052719f607dacd3a088274f65596bd0d09920b61a
        b5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e << 385) % P */
  { TO_LIMB_T(0x5480EB3C484161), TO_LIMB_T(0x1679908D830F22),
    TO_LIMB_T(0x43396FE7A4DA56), TO_LIMB_T(0x37F2A07881914C),
    TO_LIMB_T(0x75DB6D1BE22141), TO_LIMB_T(0x29A74A464CF41B),
    TO_LIMB_T(0x0248D08A2B507D) }
},
{ /* (0x0ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a7
        6d429a695160d12c923ac9cc3baca289e193548608b82801 << 385) % P */
  { TO_LIMB_T(0x6615F0C0929894), TO_LIMB_T(0x687D78DA716931),
    TO_LIMB_T(0x6550531AD2CBE7), TO_LIMB_T(0x60D495FE7E6856),
    TO_LIMB_T(0x64B4577DF6BD2D), TO_LIMB_T(0x3941F4EA5D7C3B),
    TO_LIMB_T(0x0041FEC73F406D) },
  /* (0x0606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af
        267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be << 385) % P */
  { TO_LIMB_T(0x01F925BEC960BA), TO_LIMB_T(0x1C28AC518772B7),
    TO_LIMB_T(0x51DF275D00C551), TO_LIMB_T(0x13DA33A86ADAC6),
    TO_LIMB_T(0x195DAF292B89D9), TO_LIMB_T(0x7CB9C5D614290F),
    TO_LIMB_T(0x0595E150B1EF0D) },
},
{ { ONE_MONT_P }, { 0 } }
};

static void POINTonE2_from_Jacobian(POINTonE2 *out, const POINTonE2 *in)
{
    vec384x Z, ZZ;
    limb_t inf = vec_is_zero(in->Z, sizeof(in->Z));

    reciprocal_fp2(Z, in->Z);                           /* 1/Z */

    sqr_fp2(ZZ, Z);
    mul_fp2(out->X, in->X, ZZ);                         /* X = X/Z^2 */

    mul_fp2(ZZ, ZZ, Z);
    mul_fp2(out->Y, in->Y, ZZ);                         /* Y = Y/Z^3 */

    vec_select(out->Z, in->Z, BLS12_381_G2.Z,
                       sizeof(BLS12_381_G2.Z), inf);    /* Z = inf ? 0 : 1 */
}

void POINTonE2_to_affine(POINTonE2_affine *out, const POINTonE2 *in)
{
    POINTonE2 p;

    if (!vec_is_equal(in->Z, BLS12_381_Rx.p2, sizeof(in->Z))) {
        POINTonE2_from_Jacobian(&p, in);
        in = &p;
    }
    vec_copy(out, in, sizeof(*out));
}
