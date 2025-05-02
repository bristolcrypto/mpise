// Function prototype:
// -------------------
// void gfp_add_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_add_isa` computes the sum $r = a + b \bmod p$ of two
// elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is
// the 255-bit pseudo-Mersenne prime $p = 2^{255} - 19$. Operands $a$ and $b$
// are allowed to be larger than $p$. The result $r$ may not be fully reduced,
// but $r$ is always less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.
// `b`: pointer to array containing the eight 32-bit words of operand $b$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` and `tmp1` hold intermediate results
#define tmp0 a3
#define tmp1 a4
// Registers `sumw` and `cryw` hold sum and carry words
#define sumw a5
#define cryw a6
// Register `rmsw` holds the most-significant result-word
#define rmsw a7

// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CCON, 19


///////////////////////////////////////////////////////////////////////////////
/////////////////// MACROS FOR WORD-WISE ADDITION OPERATIONS //////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `ADDW_V1` loads `a[i]` and `b[i]` from RAM and adds them together
// with an incoming carry in `slo`. The sum, which can exceed a single word, is
// put in the `shi:slo` register-pair. Finally, the lower word `slo` is stored
// in `r[i]` in RAM and the `shi:slo` register-pair is shifted 32 bits to the
// right (NOTE: `shi` may not be 0 and should be ignored!).

.macro ADDW_V1 shi:req, slo:req, i:req
    lw      tmp0, \i(aptr)
    lw      tmp1, \i(bptr)
    add     \slo, \slo, tmp0
    sltu    \shi, \slo, tmp0
    add     \slo, \slo, tmp1
    sltu    tmp0, \slo, tmp1 
    sw      \slo, \i(rptr)
    add     \slo, \shi, tmp0
.endm


// The macro `ADDW_V2` loads `a[i]` and `b[i]` from RAM and adds them. The sum,
// which can exceed a single word, is put in the `shi:slo` register-pair.

.macro ADDW_V2 shi:req, slo:req, i:req
    lw      \slo, \i(aptr)
    lw      tmp0, \i(bptr)
    add     \slo, \slo, tmp0
    sltu    \shi, \slo, tmp0
.endm


// The macro `ADDW_V3` adds the word `slo` to `shi` and stores the sum (which
// always fits in a single word) in `r[i]` in RAM.

.macro ADDW_V3 shi:req, slo:req, i:req
    add     \shi, \shi, \slo
    sw      \shi, \i(rptr)
.endm


// The macro `MULHIXC` splits the double-length word in the `shi:slo` register-
// pair into a 31-bit lower part and a (normally much shorter) upper part. The
// lower part is put in register `msw`, while the upper part is multiplied by
// the constant $c = 19$. The product, which always fits into a single a word,
// is put in `slo`.

.macro MULHIXC shi:req, slo:req, msw:req
    srli    tmp0, \slo, 31
    slli    \shi, \shi, 1
    li      tmp1, CCON
    add     \shi, \shi, tmp0
    slli    \msw, \slo, 1
    mul     \slo, \shi, tmp1
    srli    \msw, \msw, 1
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
.global gfp_add_isa
.type gfp_add_isa,%function
.balign 16
gfp_add_isa:
    ADDW_V2 cryw, sumw, 28
    MULHIXC cryw, sumw, rmsw
    ADDW_V1 cryw, sumw, 0
    ADDW_V1 cryw, sumw, 4
    ADDW_V1 cryw, sumw, 8
    ADDW_V1 cryw, sumw, 12
    ADDW_V1 cryw, sumw, 16
    ADDW_V1 cryw, sumw, 20
    ADDW_V1 cryw, sumw, 24
    ADDW_V3 rmsw, sumw, 28
    ret


.end
