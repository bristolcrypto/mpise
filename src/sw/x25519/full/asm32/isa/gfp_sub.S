// Function prototype:
// -------------------
// void gfp_sub_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_sub_isa` computes the difference $r = a - b \bmod p$ of
// two elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is
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
///////////////// MACROS FOR WORD-WISE SUBTRACTION OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `SUBW_V1` loads `a[i]` and `b[i]` from RAM, adds the former to the
// signed double-length word in the `shi:slo` register-pair, and subtracts the
// latter from it. The result can be negative, whereby `shi` is always in the
// range [-2, 1]. Finally, the lower word `slo` is stored in `r[i]` in RAM and
// the `shi:slo` register-pair is shifted 32 bits to the right (NOTE: the shift
// is an arithmetic right shift, which means the sign is preserved).

.macro SUBW_V1 shi:req, slo:req, i:req
    lw      tmp0, \i(aptr)
    lw      tmp1, \i(bptr)
    add     \slo, \slo, tmp0
    sltu    tmp0, \slo, tmp0
    add     \shi, \shi, tmp0
    sltu    tmp0, \slo, tmp1
    sub     tmp1, \slo, tmp1
    sub     \slo, \shi, tmp0
    sw      tmp1, \i(rptr)
    srai    \shi, \slo, 1
.endm


// The macro `SUBW_V2` loads `a[i]` and `b[i]` from RAM, adds the former to
// 0x1FFFFFFFC, and subtracts the latter from the sum. The result, which can
// exceed a single word, is put in the `shi:slo` register-pair (NOTE: this
// result is always positive,  whereby `shi` is in the range [0, 2]). 

.macro SUBW_V2 shi:req, slo:req, i:req
    lw      tmp0, \i(aptr)
    lw      tmp1, \i(bptr)
    addi    \slo, tmp0, -4
    sltu    tmp0, \slo, tmp0
    addi    \shi, tmp0, 1
    sltu    tmp0, \slo, tmp1
    sub     \slo, \slo, tmp1
    sub     \shi, \shi, tmp0
.endm


// The macro `SUBW_V3` adds the word `slo` along with 4 to `shi` and stores the
// sum (which always fits in a single word) in `r[i]` in RAM.

.macro SUBW_V3 shi:req, slo:req, i:req
    add     \shi, \shi, \slo
    addi    \shi, \shi, 4
    sw      \shi, \i(rptr)
.endm


// The macro `MULHIXC` splits the double-length word in the `shi:slo` register-
// pair into a 31-bit lower part and a (normally much shorter) upper part. The
// lower part is put in register `msw`, while the upper part is multiplied by
// the constant $c = 19$. Then, $4*c$ is subtracted from the obtained product.
// The result is put in the `shi:slo` register-pair (NOTE: this result can be
// be negative, whereby `shi` is always in the range [-2, 1]).

.macro MULHIXC rhi:req, rlo:req, msw:req
    srli    \rlo, \msw, 31
    slli    \rhi, \rhi, 1
    add     \rhi, \rhi, \rlo
    li      tmp0, CCON
    slli    \msw, \msw, 1
    mul     \rlo, \rhi, tmp0
    srli    \msw, \msw, 1
    sltiu   tmp1, \rlo, 4*CCON
    addi    \rlo, \rlo, -4*CCON
    sub     \rhi, zero, tmp1
.endm


///////////////////////////////////////////////////////////////////////////////
/////////// SPEED-OPTIMIZED PRIME-FIELD SUBTRACTION (FULLY UNROLLED) //////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field subtraction tightly integrates a normal
// subtraction $a - b$ with a fast reduction modulo $p = 2^{255} - 19$. It aims
// for high performance, which means the loop is fully unrolled. Each word of
// the arrays `a` and `b` is loaded from RAM exactly once, and each word of
// the result-array `r` is stored to RAM exactly once.

.text
.global gfp_sub_isa
.type gfp_sub_isa,%function
.balign 16
gfp_sub_isa:
    SUBW_V2 cryw, rmsw, 28
    MULHIXC cryw, sumw, rmsw
    SUBW_V1 cryw, sumw, 0
    SUBW_V1 cryw, sumw, 4
    SUBW_V1 cryw, sumw, 8
    SUBW_V1 cryw, sumw, 12
    SUBW_V1 cryw, sumw, 16
    SUBW_V1 cryw, sumw, 20
    SUBW_V1 cryw, sumw, 24
    SUBW_V3 rmsw, sumw, 28
    ret


.end
