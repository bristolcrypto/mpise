// Function prototype:
// -------------------
// void gfp_mul32_ise(uint32_t *r, const uint32_t *a, uint32_t b);
//
// Description:
// ------------
// The function `gfp_mul32_ise` computes the product $r = a \cdot b \bmod p$ of
// two elements $a$ and $b$ of a pseudo-Mersenne prime field, with element $b$
// being up to 32 bits long. The prime $p$ is the 255-bit pseudo-Mersenne prime
// $p = 2^{255} - 19$, but the reduction is actually performed modulo $64p$.
// Hence, the result can be $9*RADIX = 261$ bits long. The least-significant
// limb of operand $a$ is allowed to be $RADIX + 1$ bits long. Also the least-
// sigfinicant limb of the result can be $RADIX + 1$ bit long, but all other
// limbs have a length of $RADIX$ bits.
//
// Parameters:
// -----------
// `r`: pointer to array for the nine 29-bit limbs of the result $r$.
// `a`: pointer to array containing the nine 29-bit limbs of operand $a$.
// `b`: 32-bit word of operand $b$.


#include "ise_al.h"


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19
// Number-representation radix for prime-field elements
.equ RADIX, 29
// Scaling factor for constant c ($NLIMBS*RADIX - 255$)
.equ SCALEC, 6

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Registers `almb` and `blmb` hold 2 limbs of operands
#define blmb a2
#define almb a3
// Registers `tmp0` to `tmp1` hold intermediate results
#define tmp0 a4
#define tmp1 a5
// Register-pair `sumh:suml` holds a product of 2 limbs
#define suml a6
#define sumh a7
// Register-pair `shih:shil` holds the upper column-sum
#define shil a3
#define shih a4
// Registers `rmsl` and `rlsl` hold limbs of the result
#define rmsl t0
#define rlsl t1
// Registers `mask` and `rcon` hold 0x1FFFFFFF and 64*c
#define mask t2
#define rcon t3


///////////////////////////////////////////////////////////////////////////////
//////////////// MACROS FOR LIMB-WISE MULTIPLICATION OPERATIONS ///////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULL_V1` loads the limb `a[i]` from RAM, multiplies it by `blmb`,
// and puts the product in the `shi:slo` register-pair. The lower word of the
// product is also copied to `rmsl` and the bit-mask in `mask` applied to it.
// Futhermore, `rcon` is initialized with the constant $64c = 1216$. Then, the
// `shi:slo` register-pair is shifted RADIX bits to the right, multiplied by
// the constant $64c$ in `rcon`, and the single-length product is put in `slo`.

.macro MULL_V1 shi:req, slo:req, i:req
    lw      almb, \i(aptr)
    li      rcon,  (CONSTC << SCALEC)  // (19 << 6) = 1216
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu rmsl, almb, blmb, zero
    madd51hu \slo, almb, blmb, zero
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      rmsl, zero
    mv      \slo, zero
    madd51lu rmsl, almb, blmb
    madd51hu \slo, almb, blmb
#endif
.endm


// The macro `MULL_V2` first multiplies `slo` by the constant $64c$ in `rcon`
// and puts the single-length product in `slo`. Then, it loads the limb `a[i]`
// from RAM, multiplies it by `blmb`, adds `slo` the double-length product, and
// puts the result in the `shi:slo` register-pair. The lower word of the sum is
// copied to `rlsl` and the bit-mask in `mask` applied to it. Thereafter, the
// `shi:slo` register-pair is shifted RADIX bits to the right, which yields a
// single-word result. However, this result-word is split across two registers:
// the 3 LSBs are in `slo` and the 29 MSBs in `shi`, i.e., the two parts have
// to be combined to get the actual single-word result.

.macro MULL_V2 shi:req, slo:req, i:req
    lw      almb, \i(aptr)
    mul     \slo, \slo, rcon
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu \slo, almb, blmb, \slo
    madd51hu \shi, almb, blmb, zero
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \shi, zero
    madd51lu \slo, almb, blmb
    madd51hu \shi, almb, blmb
#endif
    and     rlsl, \slo, mask
    srli    \slo, \slo, RADIX
.endm


// The macro `MULL_V3` first combines `slo` and `shi` to a single word, which
// is put in `slo`. Then, it loads the limb `a[i]` from RAM, multiplies it by
// `blmb`, adds `slo` the double-length product, and puts the result in the
// `shi:slo` register-pair. The lower word of the sum is stored to `r[i]` in
// RAM after the bit-mask in `mask` has been applied to it. Thereafter, the
// `shi:slo` register-pair is shifted RADIX bits to the right, which yields a
// single-word result. However, this result-word is split across two registers:
// the 3 LSBs are in `slo` and the 29 MSBs in `shi`, i.e., the two parts have
// to be combined to get the actual single-word result.

.macro MULL_V3 slo:req, shi:req, i:req
    lw      almb, \i(aptr)
    add     \slo, \slo, \shi
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu \slo, almb, blmb, \slo
    madd51hu \shi, almb, blmb, zero
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \shi, zero
    madd51lu \slo, almb, blmb
    madd51hu \shi, almb, blmb
#endif
    and     tmp0, \slo, mask
    sw      tmp0, \i(rptr)
    srli    \slo, \slo, RADIX
.endm


// The macro `MODREDP` first combines `slo` and `shi` to a single word, which
// is put in `slo`. Then, it adds `slo` to `rmsl`, applies the bit-mask in
// `mask` to the sum, and stores the result to `r[i1]` in RAM. Thereafter,
// `slo` is shifted RADIX bits to the right, multiplied by the constant $64c$
// in `rcon`, and the single-word product is put in `slo`. Finally `rlsl` is
// added to `slo` and the sum is stored to `r[i0]` in RAM.
// NOTE: The result-limb `r[i0]` can be $RADIX + 1$ bits long.

.macro MODREDP shi:req, slo:req, i1:req, i0:req
    add     \slo, \slo, \shi
    add     \slo, \slo, rmsl
    and     rmsl, \slo, mask
    sw      rmsl, \i1(rptr)
    srli    \slo, \slo, RADIX
    mul     \slo, \slo, rcon
    add     \slo, \slo, rlsl
    sw      \slo, \i0(rptr)
.endm


// The macro `INITVAR` initializes local variables (`mask`).

.macro INITVAR
    li      mask, -1
    srli    mask, mask, (32-RADIX)
.endm


///////////////////////////////////////////////////////////////////////////////
///////// SPEED-OPTIMIZED PRIME-FIELD MULTIPLICATION (FULLY UNROLLED) /////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field multiplication is based on the operand-
// scanning method and includes a reduction modulo $64p = 2^{261} - 1216$. It
// is aimed at high speed, which means the loops are fully unrolled. Each limb
// of array `a` is loaded from RAM exactly once, and each limb of the result-
// array `r` is stored to RAM exactly once.
// NOTE: The least-significant limb `r[0]` can be $RADIX + 1$ bits long.

.text
.global gfp_mul32_ise
.type gfp_mul32_ise,%function
// .balign 8
gfp_mul32_ise:
    INITVAR
    MULL_V1 sumh, suml, 32
    MULL_V2 sumh, suml, 0
    MULL_V3 sumh, suml, 4
    MULL_V3 sumh, suml, 8
    MULL_V3 sumh, suml, 12
    MULL_V3 sumh, suml, 16
    MULL_V3 sumh, suml, 20
    MULL_V3 sumh, suml, 24
    MULL_V3 sumh, suml, 28
    MODREDP sumh, suml, 32, 0
    ret


.end
