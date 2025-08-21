// Function prototype:
// -------------------
// void gfp_add_ise(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_add_ise` computes the sum $r = a + b \bmod p$ of two
// elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is the
// 255-bit pseudo-Mersenne prime $p = 2^{255} - 19$. Operands $a$ and $b$ are
// allowed to be larger than $p$. The result $r$ may not be fully reduced, but
// $r$ is always less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.
// `b`: pointer to array containing the eight 32-bit words of operand $b$.


#include "ise_al.h"


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CCON, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` to `tmp1` hold intermediate results
#define tmp0 a3
#define tmp1 a4
// Register `rcon` holds the constant c = 19 of prime p
#define rcon a4
// Registers `sumw` and `cryw` hold sum and carry words
#define sumw a5
#define cryw a6
// Register `rmsw` holds the highest word of the result
#define rmsw a7


///////////////////////////////////////////////////////////////////////////////
/////////////////// MACROS FOR WORD-WISE ADDITION OPERATIONS //////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `ADDW_V1` loads the words `a[i]` and `b[i]` from RAM, adds them
// together with an incoming carry in `cin`, and puts the sum in the `shi:slo`
// register-pair. The lower word of the sum is stored in `r[i]` in RAM.
// NOTE: Register `slo` has to be different from `cin`.

.macro ADDW_V1 shi:req, slo:req, cin:req, i:req
    lw      \slo, \i(aptr)
    lw      tmp0, \i(bptr)
    add     \slo, \slo, \cin
    sltu    \shi, \slo, \cin
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    cacc    \shi, \slo, tmp0, \shi
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    cacc    \shi, \slo, tmp0
#endif
    add     \slo, \slo, tmp0
    sw      \slo, \i(rptr)
.endm


// The macro `ADDW_V2` loads the words `a[i]` and `b[i]` from RAM, adds them,
// and puts the sum in the `shi:slo` register-pair.

.macro ADDW_V2 shi:req, slo:req, i:req
    lw      \slo, \i(aptr)
    lw      tmp0, \i(bptr)
    add     \slo, \slo, tmp0
    sltu    \shi, \slo, tmp0
.endm


// The macro `ADDW_V3` adds the word `cin` to `sum` and stores the result in
// `r[i]` in RAM.
// NOTE: The bit-length of `sum` and `cin` can be up to 31.

.macro ADDW_V3 sum:req, cin:req, i:req
    add     \sum, \sum, \cin
    sw      \sum, \i(rptr)
.endm


// The macro `MULHIXC` first splits the double-length word in `dhi:dlo` into a
// 31-bit lower part and an upper part. The lower part is put in `rlo`, while
// the upper part is multiplied by the constant $c$ (in register `rcon`) and
// the single-word product is put in `rhi`.
// NOTE: The bit-length of `dhi` can be up to $32 - \log_2(c) - 1$, e.g., for
// $c = 19$, `dhi` can be up to 26 bits long.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    li      rcon, CCON  // rcon = 19
    srli    tmp0, \dlo, 31
    slli    \rhi, \dhi, 1
    add     \rhi, \rhi, tmp0
    slli    \rlo, \dlo, 1
    mul     \rhi, \rhi, rcon
    srli    \rlo, \rlo, 1
 .endm


///////////////////////////////////////////////////////////////////////////////
//////////// SPEED-OPTIMIZED PRIME-FIELD ADDITION (FULLY UNROLLED) ////////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field addition tightly integrates a normal
// addition $a + b$ with a fast reduction modulo $p = 2^{255} - 19$. It aims
// for high performance, which means the loop is fully unrolled. Each word of
// the arrays `a` and `b` is loaded from RAM exactly once, and each word of
// the result-array `r` is stored to RAM exactly once.

.text
.global gfp_add_ise
.type gfp_add_ise,%function
// .balign 8
gfp_add_ise:
    ADDW_V2 cryw, sumw, 28
    MULHIXC cryw, rmsw, cryw, sumw
    ADDW_V1 cryw, sumw, cryw, 0
    ADDW_V1 cryw, sumw, cryw, 4
    ADDW_V1 cryw, sumw, cryw, 8
    ADDW_V1 cryw, sumw, cryw, 12
    ADDW_V1 cryw, sumw, cryw, 16
    ADDW_V1 cryw, sumw, cryw, 20
    ADDW_V1 cryw, sumw, cryw, 24
    ADDW_V3 rmsw, cryw, 28
    ret


.end
