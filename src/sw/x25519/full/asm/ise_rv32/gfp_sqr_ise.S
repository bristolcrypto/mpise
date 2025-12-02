// Function prototype:
// -------------------
// void gfp_sqr_ise(uint32_t *r, const uint32_t *a);
//
// Description:
// ------------
// The function `gfp_sqr_ise` computes the square $r = a^2 \bmod p$ of an
// element $a$ of a pseudo-Mersenne prime field. The prime $p$ is is the 255-
// bit pseudo-Mersenne prime $p = 2^{255} - 19$. Operand $a$ is allowed to be
// larger than $p$. The result $r$ may not be fully reduced, but $r$ is always
// less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.


#include "ise_al.h"


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr t1
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Registers `tmp0` and `tmp1` hold temporary variables
#define tmp0 s0
#define tmp1 s1
// Register `rcon` holds the constant c of the PM-prime
#define rcon a0
// Registers `aw00` to `aw07` hold words of operand `a`
#define aw00 s2
#define aw01 s3
#define aw02 s4
#define aw03 s5
#define aw04 s6
#define aw05 s7
#define aw06 s8
#define aw07 s9
// Register `cryw` holds a carry for doubling operation
#define cryw a0
// Registers `rw00` to `rw15` hold words of the product
#define rw00 s10
#define rw01 s11
#define rw02 a3
#define rw03 a4
#define rw04 a5
#define rw05 a6
#define rw06 a7
#define rw07 t0
#define rw08 t1
#define rw09 t2
#define rw10 t3
#define rw11 t4
#define rw12 t5
#define rw13 t6
#define rw14 a1
#define rw15 a2


///////////////////////////////////////////////////////////////////////////////
///////////// MACROS FOR WORD-WISE MULTIPLY-ACCUMULATE OPERATIONS /////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MACC_V1` multiplies the word `aiw` by `bjw` and puts the product
// in the double-length accumulator `rhi:rlo` (i.e., this macro performs a
// multiply-accumulate operation with an initial accumulator that is 0, i.e.,
// a normal multiplication).
// NOTE: Register `rlo` has to be different from `aiw` and `bjw`.

.macro MACC_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mulhu   \rhi, \aiw, \bjw
    mul     \rlo, \aiw, \bjw
.endm


// The macro `MACC_V2` multiplies the word `aiw` by `bjw` and adds the product
// to the double-length accumulator `rhi:rlo`, whereby the initial value of the
// accumulator is only 32 bits long (i.e., `rhi` is 0).
// NOTE: Register `rhi` has to be different from `aiw` and `bjw`.

.macro MACC_V2 rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  \rhi, \aiw, \bjw, \rlo
    maddlu  \rlo, \aiw, \bjw, \rlo
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rhi, \rlo
    maddhu  \rhi, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
#endif
.endm


// The macro `MACC_V3` multiplies the word `aiw` by `bjw` and adds the product
// to the triple-length accumulator `rex:rhi:rlo`, whereby the initial value of
// the accumulator is only 64 bits long (i.e., `rex` is 0).

.macro MACC_V3 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  tmp0, \aiw, \bjw, \rlo
    maddlu  \rlo, \aiw, \bjw, \rlo
    add     \rhi, \rhi, tmp0
    sltu    \rex, \rhi, tmp0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp0, \rlo
    maddhu  tmp0, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
    add     \rhi, \rhi, tmp0
    sltu    \rex, \rhi, tmp0
#endif
.endm


// The macro `MACC_V4` multiplies the word `aiw` by `bjw` and adds the product
// to the triple-length accumulator `rex:rhi:rlo`.

.macro MACC_V4 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  tmp0, \aiw, \bjw, \rlo
    maddlu  \rlo, \aiw, \bjw, \rlo
    cacc    \rex, \rhi, tmp0, \rex
    add     \rhi, \rhi, tmp0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp0, \rlo
    maddhu  tmp0, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
    cacc    \rex, \rhi, tmp0
    add     \rhi, \rhi, tmp0
#endif
.endm


// The macro `MACC_V5` is the same as `MACC_V2`, except that the lower word of
// the accumulator is written to `tmp1` instead of `rlo`.
// NOTE: The purpose of this macro is to help prevent pipeline stalls.

.macro MACC_V5 rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddlu  tmp1, \aiw, \bjw, \rlo
    maddhu  \rhi, \aiw, \bjw, \rlo
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rhi, \rlo
    maddhu  \rhi, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
#endif
.endm


// The macro `MACC_V6` is the same as `MACC_V3`, except that the lower word of
// the accumulator is read from `tmp1` instead of `rlo`.
// NOTE: The purpose of this macro is to help prevent pipeline stalls.

.macro MACC_V6 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  tmp0, \aiw, \bjw, tmp1
    maddlu  \rlo, \aiw, \bjw, tmp1
    add     \rhi, \rhi, tmp0
    sltu    \rex, \rhi, tmp0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp0, \rlo
    maddhu  tmp0, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
    add     \rhi, \rhi, tmp0
    sltu    \rex, \rhi, tmp0
#endif
.endm



///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR WORD-WISE DOUBLE-AND-ADD-SQUARE OPERATIONS ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro DASQ_V1 doubles the word `rhi` and adds the result to the upper
// half of the square of the word `aiw`. The two lower words of the triple-
// length result is put in the `rhi:rlo` register-pair and the higher word in
// the outgoing carry `cow`.

.macro DASQ_V1 cow:req, rhi:req, rlo:req, aiw:req
    mul     \rlo, \aiw, \aiw
    mulhu   tmp0, \aiw, \aiw
    srli    \cow, \rhi, 31
    slli    \rhi, \rhi, 1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    cacc    \cow, \rhi, tmp0, \cow
    add     \rhi, \rhi, tmp0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    cacc    \cow, \rhi, tmp0
    add     \rhi, \rhi, tmp0
#endif
.endm


// The macro DASQ_V2 doubles the double-length word `rhi:rlo` and adds the
// result along with the incoming carry `ciw` to the square of the word `aiw`.
// The two lower words of the triple-length result is put in the `rhi:rlo`
// register-pair and the higher word in the outgoing carry `cow`.
// NOTE: Register `cow` is (generally) the same as register `ciw`.

.macro DASQ_V2 cow:req, rhi:req, rlo:req, aiw:req, ciw:req
    srli    tmp0, \rlo, 31
    slli    tmp1, \rlo, 1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddlu  \rlo, \aiw, \aiw, tmp1
    maddhu  tmp1, \aiw, \aiw, tmp1
    cacc    tmp0, \rlo, \ciw, tmp0
    add     \rlo, \rlo, \ciw
    srli    \cow, \rhi, 31
    slli    \rhi, \rhi, 1
    cacc    \cow, \rhi, tmp0, \cow
    add     \rhi, \rhi, tmp0
    cacc    \cow, \rhi, tmp1, \cow
    add     \rhi, \rhi, tmp1
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp1, \rlo
    maddlu  \rlo, \aiw, \aiw
    maddhu  tmp1, \aiw, \aiw
    cacc    tmp0, \rlo, \ciw
    add     \rlo, \rlo, \ciw
    srli    \cow, \rhi, 31
    slli    \rhi, \rhi, 1
    cacc    \cow, \rhi, tmp0
    add     \rhi, \rhi, tmp0
    cacc    \cow, \rhi, tmp1
    add     \rhi, \rhi, tmp1
#endif
.endm


// The macro DASQ_V3 doubles the word `rlo` and adds the result along with the
// incoming carry `ciw` to the square of the word `aiw`. The double-length
// result is put in the `rhi:rlo` register-pair.

.macro DASQ_V3 rhi:req, rlo:req, aiw:req, ciw:req
    srli    tmp0, \rlo, 31
    slli    \rlo, \rlo, 1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  \rhi, \aiw, \aiw, \rlo
    maddlu  \rlo, \aiw, \aiw, \rlo
    add     \rhi, \rhi, tmp0
    cacc    \rhi, \rlo, \ciw, \rhi
    add     \rlo, \rlo, \ciw
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rhi, \rlo
    maddhu  \rhi, \aiw, \aiw
    maddlu  \rlo, \aiw, \aiw
    add     \rhi, \rhi, tmp0
    cacc    \rhi, \rlo, \ciw
    add     \rlo, \rlo, \ciw
#endif
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V2` multiplies the word `aiw` by `bjw` and adds the word
// `c0w` to the product. The double-length result is put in the `rhi:rlo`
// register-pair.
// NOTE: Register `rhi` has to be different from `aiw` and `bjw`.
// NOTE: Register `c0w` is (generally) the same as register `rlo`.

.macro MADD_V2 rhi:req, rlo:req, aiw:req, bjw:req, c0w:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddhu  \rhi, \aiw, \bjw, \c0w
    maddlu  \rlo, \aiw, \bjw, \c0w
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rhi, \c0w
    maddhu  \rhi, \aiw, \bjw
    maddlu  \rlo, \aiw, \bjw
#endif
.endm


// The macro `MADD_V3` multiplies the word `aiw` by `bjw` and adds the two
// words `c0w` and `d0w` to the product. The double-length result is put in the
// `rhi:rlo` register-pair.
// NOTE: Register `c0w` is (generally) the same as register `rlo`, and register
// `d0w` is (generally) the same as register `rhi`.

.macro MADD_V3 rhi:req, rlo:req, aiw:req, bjw:req, d0w:req, c0w:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddlu  tmp0, \aiw, \bjw, \c0w
    maddhu  tmp1, \aiw, \bjw, \c0w
    add     \rlo, \d0w, tmp0
    cacc    \rhi, \d0w, tmp0, tmp1
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp0, \d0w
    maddlu  tmp0, \aiw, \bjw
    maddhu  \rhi, \aiw, \bjw
    cacc    \rhi, \c0w, tmp0
    add     \rlo, \c0w, tmp0
#endif
.endm


// The macro `MULHIXC` first splits the double-length word in `dhi:dlo` into a
// 31-bit lower part and an upper part. The lower part is put in `rlo`, while
// the upper part is multiplied by the constant $c$ (in register `rcon`) and
// the single-word product is put in `rhi`.
// NOTE: The bit-length of `dhi` can be up to $32 - \log_2(c) - 1$, e.g., for
// $c = 19$, `dhi` can be up to 26 bits long.
// NOTE: Register `rcon` contains $2c$ instead of $c$ and must, therefore, be
// halved before the multiplication.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    slli    \rhi, \dhi, 1
    srli    tmp0, \dlo, 31
    add     \rhi, \rhi, tmp0
    srli    tmp0, rcon, 1
    slli    \rlo, \dlo, 1
    mul     \rhi, \rhi, tmp0
    srli    \rlo, \rlo, 1
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR COLUMN-WISE MULTIPLY-ACCUMULATE OPERATIONS ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MCOL_V1` multiplies the word `a0w` by `b0w` and adds the product
// to the triple-length accumulator `rex:rhi:rlo`. The last parameter `acclen`
// specifies the initial length of the accumulator and can be either 0 (i.e.,
// `rex`, `rhi`, and `rlo` is 0), 32 (i.e., `rex` and `rhi` is 0), or 64 (i.e.,
// `rex` is 0).

.macro MCOL_V1 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, acclen:req
    .if (\acclen == 0)
    MACC_V1 \rhi, \rlo, \a0w, \b0w
    .elseif (\acclen == 32)
    MACC_V2 \rhi, \rlo, \a0w, \b0w
    .else  // acclen == 64
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    .endif
.endm


// The macro `MCOL_V2` multiplies the word `a0w` by `b0w` and `a1w` by `b1w`,
// and adds the two products to the triple-length accumulator `rex:rhi:rlo`.
// The last parameter `acclen` specifies the initial length of the accumulator
// and can be either 32 (i.e., `rex` and `rhi` is 0) or 64 (i.e., `rex` is 0).

.macro MCOL_V2 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               acclen:req
    .if (\acclen == 32)
    MACC_V5 \rhi, \rlo, \a0w, \b0w
    MACC_V6 \rex, \rhi, \rlo, \a1w, \b1w
    .else  // acclen == 64
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w
    .endif
.endm


// The macro `MCOL_V3` multiplies the word `a0w` by `b0w`, `a1w` by `b1w` and
// `a2w` by `b2w`, and adds the three products to the triple-length accumulator
// `rex:rhi:rlo`. The initial length of the accumulator is 64 (i.e., `rex` is
// 0).

.macro MCOL_V3 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               a2w:req, b2w:req
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w
    MACC_V4 \rex, \rhi, \rlo, \a2w, \b2w
.endm


// The macro `MCOL_V4` multiplies the word `a0w` by `b0w`, `a1w` by `b1w`,
// `a2w` by `b2w` and `a3w` by `b3w`, and adds the four products to the triple-
// length accumulator `rex:rhi:rlo`. The initial length of the accumulator is
// 64 (i.e., `rex` is 0).

.macro MCOL_V4 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               a2w:req, b2w:req, a3w:req, b3w:req
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w
    MACC_V4 \rex, \rhi, \rlo, \a2w, \b2w
    MACC_V4 \rex, \rhi, \rlo, \a3w, \b3w
.endm


///////////////////////////////////////////////////////////////////////////////
/////////// HIGH-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR SQUARING ///////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULCOLS` computes the column-sums of all products of the form
// $a_i \cdot a_j$ with $i < j$ (these are exactly the 28 products that appear
// twice in the final result). The eight words of operand $a$ are `aw00`-`aw07`
// and the 14 words of the obtained column-sums are put in `rw01`-`rw14` (the
// two words `rw00` and `rw15` are not computed by this macro!).

.macro MULCOLS
    MCOL_V1 rw03, rw02, rw01, aw00, aw01, 0
    MCOL_V1 rw04, rw03, rw02, aw00, aw02, 32
    MCOL_V2 rw05, rw04, rw03, aw00, aw03, aw01, aw02, 32
    MCOL_V2 rw06, rw05, rw04, aw00, aw04, aw01, aw03, 64
    MCOL_V3 rw07, rw06, rw05, aw00, aw05, aw01, aw04, aw02, aw03
    MCOL_V3 rw08, rw07, rw06, aw00, aw06, aw01, aw05, aw02, aw04
    MCOL_V4 rw09, rw08, rw07, aw00, aw07, aw01, aw06, aw02, aw05, aw03, aw04
    MCOL_V3 rw10, rw09, rw08, aw01, aw07, aw02, aw06, aw03, aw05
    MCOL_V3 rw11, rw10, rw09, aw02, aw07, aw03, aw06, aw04, aw05
    MCOL_V2 rw12, rw11, rw10, aw03, aw07, aw04, aw06, 64
    MCOL_V2 rw13, rw12, rw11, aw04, aw07, aw05, aw06, 64
    MCOL_V1 rw14, rw13, rw12, aw05, aw07, 64
    MCOL_V1 rw15, rw14, rw13, aw06, aw07, 32
.endm


// The macro `DBADDSQ` doubles the 14 column sums `rw01`-`rw14` and adds the
// eight squares $a_i^2$ (which are in the "main diagonal") to the result. The
// eight words of operand $a$ are `aw00`-`aw07` and the 16 words of the final
// result are put in `rw00`-`rw15`.

.macro DBADDSQ
    DASQ_V1 cryw, rw01, rw00, aw00
    DASQ_V2 cryw, rw03, rw02, aw01, cryw
    DASQ_V2 cryw, rw05, rw04, aw02, cryw
    DASQ_V2 cryw, rw07, rw06, aw03, cryw
    DASQ_V2 cryw, rw09, rw08, aw04, cryw
    DASQ_V2 cryw, rw11, rw10, aw05, cryw
    DASQ_V2 cryw, rw13, rw12, aw06, cryw
    DASQ_V3 rw15, rw14, aw07, cryw
.endm


// The macro `MODREDP` reduces the 16-word operand `rw00`-`rw15` modulo the
// prime $p = 2^{256} - 19$ to get an 8-word result. This reduction consists
// of two steps: (i) the upper half `rw08`-`rw15` is multiplied by $2c = 38$
// and the obtained 9-word product is added to the lower half `rw00`-`rw07`,
// yielding a 9-word intermediate result `rw00`-`rw08`, (ii) the double-length
// word in the `rw08:rw07` register-pair is split into a lower part of 31 bits
// and an upper part, which is multiplied by $c = 19$ and the obtained product
// is added to the intermediate result `rw00`-`rw07`. The implementation below
// merges these steps and performs the modular reduction as follows: (i) `rw15`
// is multiplied by $2c$ and `rw07` is added to the product (macro `MADD_V2`),
// (ii) the obtained product is split into a 31-bit lower part and a (smaller)
// upper part, which is multiplied by $c = 19$ (macro `MULHIXC`), (iii) the
// obtained single-word product is taken into account when the remaining words
// `rw08`-`rw14` are multiplied by $2c$ and added to the words `rw00`-`rw06`.
// NOTE: The word `rw15` is used for temporary results.

.macro MODREDP
    li      rcon, 2*CONSTC  // rcon = 38
    MADD_V2 tmp1, rw07, rw15, rcon, rw07
    MULHIXC rw15, rw07, tmp1, rw07
    MADD_V3 rw15, rw00, rw08, rcon, rw15, rw00
    MADD_V3 rw15, rw01, rw09, rcon, rw15, rw01
    MADD_V3 rw15, rw02, rw10, rcon, rw15, rw02
    MADD_V3 rw15, rw03, rw11, rcon, rw15, rw03
    MADD_V3 rw15, rw04, rw12, rcon, rw15, rw04
    MADD_V3 rw15, rw05, rw13, rcon, rw15, rw05
    lw      rptr, 48(sp)  // popped from stack
    MADD_V3 rw15, rw06, rw14, rcon, rw15, rw06
    add     rw07, rw07, rw15
.endm


///////////////////////////////////////////////////////////////////////////////
///////////// HELPER MACROS FOR PRODUCT-SCANNING MODULAR SQUARING /////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes all 12 callee-saved registers along with `a0` on
// the stack.
// NOTE: The stack pointer should be 16-byte aligned!

.macro PROLOGUE
    addi    sp, sp, -64
    sw      s0, (sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    sw      s3, 12(sp)
    sw      s4, 16(sp)
    sw      s5, 20(sp)
    sw      s6, 24(sp)
    sw      s7, 28(sp)
    sw      s8, 32(sp)
    sw      s9, 36(sp)
    sw      s10, 40(sp)
    sw      s11, 44(sp)
    sw      a0, 48(sp)
.endm


// The macro `EPILOGUE` pops all 12 callee-saved registers from the stack.
// NOTE: `rptr` is popped separately in maco `MODREDP`.

.macro EPILOGUE
    lw      s0, (sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    lw      s3, 12(sp)
    lw      s4, 16(sp)
    lw      s5, 20(sp)
    lw      s6, 24(sp)
    lw      s7, 28(sp)
    lw      s8, 32(sp)
    lw      s9, 36(sp)
    lw      s10, 40(sp)
    lw      s11, 44(sp)
    addi    sp, sp, 64
.endm


// The macro `LDM_OPA` loads the eight words of array `a` from RAM and puts
// them in registers `aw00`-`aw07`.

.macro LDM_OPA
    lw      aw00, 0(aptr)
    lw      aw01, 4(aptr)
    lw      aw02, 8(aptr)
    lw      aw03, 12(aptr)
    lw      aw04, 16(aptr)
    lw      aw05, 20(aptr)
    lw      aw06, 24(aptr)
    lw      aw07, 28(aptr)
.endm


// The macro `STM_RES` stores the eight result-words, which are in registers
// `rw00`-`rw07`, to array `r` in RAM.

.macro STM_RES
    sw      rw00, 0(rptr)
    sw      rw01, 4(rptr)
    sw      rw02, 8(rptr)
    sw      rw03, 12(rptr)
    sw      rw04, 16(rptr)
    sw      rw05, 20(rptr)
    sw      rw06, 24(rptr)
    sw      rw07, 28(rptr)
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// SPEED-OPTIMIZED PRIME-FIELD SQUARING (FULLY UNROLLED) ////////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field squaring is based on the product-scanning
// method and includes a fast reduction modulo $p = 2^{255} - 19$. It is aimed
// at high speed, which means the loops are fully unrolled. Each word of the
// array `a` is loaded from RAM exactly once, and each word of the result-array
// `r` is stored to RAM exactly once.

.text
.global gfp_sqr_ise
.type gfp_sqr_ise,%function
// .balign 8
gfp_sqr_ise:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of operand A from RAM
    MULCOLS             // Column-wise mul of all a[i]*a[j] to be doubled
    DBADDSQ             // Double current result and add squares a[i]^2
    MODREDP             // modular reduction: Rlo = (Rlo + Rhi*2*c) mod p
    STM_RES             // store the eight result-words of the result in RAM
    EPILOGUE            // pop callee-saved registers from stack
    ret


.end
