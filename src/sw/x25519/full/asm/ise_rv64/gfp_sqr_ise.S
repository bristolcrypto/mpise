// Function prototype:
// -------------------
// void gfp_sqr_ise(uint64_t *r, const uint64_t *a);
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
// `r`: pointer to array for the four 64-bit words of the result $r$.
// `a`: pointer to array containing the four 64-bit words of operand $a$.


#include "ise_al.h"


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Registers `tmp0` and `tmp1` hold temporary variables
#define tmp0 a1
#define tmp1 a2
// Register `rcon` holds the constant c of the PM-prime
#define rcon s0
// Registers `aw00` to `aw03` hold words of operand `a`
#define aw00 a3
#define aw01 a4
#define aw02 a5
#define aw03 a6
// Register `cryw` holds a carry for doubling operation
#define cryw s0
// Registers `rw00` to `rw07` hold words of the product
#define rw00 a7
#define rw01 t0
#define rw02 t1
#define rw03 t2
#define rw04 t3
#define rw05 t4
#define rw06 t5
#define rw07 t6


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
// accumulator is only 64 bits long (i.e., `rhi` is 0).
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
// the accumulator is only 128 bits long (i.e., `rex` is 0).

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
    srli    \cow, \rhi, 63
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
    srli    tmp0, \rlo, 63
    slli    tmp1, \rlo, 1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddlu  \rlo, \aiw, \aiw, tmp1
    maddhu  tmp1, \aiw, \aiw, tmp1
    cacc    tmp0, \rlo, \ciw, tmp0
    add     \rlo, \rlo, \ciw
    srli    \cow, \rhi, 63
    slli    \rhi, \rhi, 1
    cacc    \cow, \rhi, tmp0, \cow
    add     \rhi, \rhi, tmp0
    cacc    \cow, \rhi, tmp1, \cow
    add     \rhi, \rhi, tmp1
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rlo, tmp1
    maddlu  \rlo, \aiw, \aiw
    maddhu  tmp1, \aiw, \aiw
    cacc    tmp0, \rlo, \ciw
    add     \rlo, \rlo, \ciw
    srli    \cow, \rhi, 63
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
    srli    tmp0, \rlo, 63
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
// NOTE: The bit-length of `dhi` can be up to $64 - \log_2(c) - 1$, e.g., for
// $c = 19$, `dhi` can be up to 58 bits long.
// NOTE: Register `rcon` contains $2c$ instead of $c$ and must, therefore, be
// halved before the multiplication.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    slli    \rhi, \dhi, 1
    srli    tmp0, \dlo, 63
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
// `rex`, `rhi`, and `rlo` is 0), 64 (i.e., `rex` and `rhi` is 0), or 128
// (i.e., `rex` is 0).

.macro MCOL_V1 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, acclen:req
    .if (\acclen == 0)
    MACC_V1 \rhi, \rlo, \a0w, \b0w
    .elseif (\acclen == 64)
    MACC_V2 \rhi, \rlo, \a0w, \b0w
    .else  // acclen == 128
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    .endif
.endm


// The macro `MCOL_V2` multiplies the word `a0w` by `b0w` and `a1w` by `b1w`,
// and adds the two products to the triple-length accumulator `rex:rhi:rlo`.
// The last parameter `acclen` specifies the initial length of the accumulator
// and can be either 64 (i.e., `rex` and `rhi` is 0) or 128 (i.e., `rex` is 0).

.macro MCOL_V2 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               acclen:req
    .if (\acclen == 64)
    MACC_V5 \rhi, \rlo, \a0w, \b0w
    MACC_V6 \rex, \rhi, \rlo, \a1w, \b1w
    .else  // acclen == 128
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w
    .endif
.endm


///////////////////////////////////////////////////////////////////////////////
/////////// HIGH-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR SQUARING ///////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULCOLS` computes the column-sums of all products of the form
// $a_i \cdot a_j$ with $i < j$ (these are exactly the 6 products that appear
// twice in the final result). The four words of operand $a$ are `aw00`-`aw03`
// and the 6 words of the obtained column-sums are put in `rw01`-`rw06` (the
// two words `rw00` and `rw07` are not computed by this macro!).

.macro MULCOLS
    MCOL_V1 rw03, rw02, rw01, aw00, aw01, 0
    MCOL_V1 rw04, rw03, rw02, aw00, aw02, 64
    MCOL_V2 rw05, rw04, rw03, aw00, aw03, aw01, aw02, 64
    MCOL_V1 rw06, rw05, rw04, aw01, aw03, 128
    MCOL_V1 rw07, rw06, rw05, aw02, aw03, 64
.endm


// The macro `DBADDSQ` doubles the 6 column sums `rw01`-`rw06` and adds the
// eight squares $a_i^2$ (which are in the "main diagonal") to the result. The
// four words of operand $a$ are `aw00`-`aw03` and the 8 words of the final
// result are put in `rw00`-`rw07`.

.macro DBADDSQ
    DASQ_V1 cryw, rw01, rw00, aw00
    DASQ_V2 cryw, rw03, rw02, aw01, cryw
    DASQ_V2 cryw, rw05, rw04, aw02, cryw
    DASQ_V3 rw07, rw06, aw03, cryw
.endm


// The macro `MODREDP` reduces the 8-word operand `rw00`-`rw07` modulo the
// prime $p = 2^{256} - 19$ to get a 4-word result. This reduction consists
// of two steps: (i) the upper half `rw04`-`rw07` is multiplied by $2c = 38$
// and the obtained 5-word product is added to the lower half `rw00`-`rw03`,
// yielding a 5-word intermediate result `rw00`-`rw04`, (ii) the double-length
// word in the `rw04:rw03` register-pair is split into a lower part of 63 bits
// and an upper part, which is multiplied by $c = 19$ and the obtained product
// is added to the intermediate result `rw00`-`rw03`. The implementation below
// merges these steps and performs the modular reduction as follows: (i) `rw07`
// is multiplied by $2c$ and `rw03` is added to the product (macro `MADD_V2`),
// (ii) the obtained product is split into a 63-bit lower part and a (smaller)
// upper part, which is multiplied by $c = 19$ (macro `MULHIXC`), (iii) the
// obtained single-word product is taken into account when the remaining words
// `rw04`-`rw06` are multiplied by $2c$ and added to the words `rw00`-`rw02`.
// NOTE: The word `rw07` is used for temporary results.

.macro MODREDP
    li      rcon, 2*CONSTC  // rcon = 38
    MADD_V2 tmp1, rw03, rw07, rcon, rw03
    MULHIXC rw07, rw03, tmp1, rw03
    MADD_V3 rw07, rw00, rw04, rcon, rw07, rw00
    MADD_V3 rw07, rw01, rw05, rcon, rw07, rw01
    MADD_V3 rw07, rw02, rw06, rcon, rw07, rw02
    add     rw03, rw03, rw07
.endm


///////////////////////////////////////////////////////////////////////////////
///////////// HELPER MACROS FOR PRODUCT-SCANNING MODULAR SQUARING /////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes one callee-saved register on the stack.
// NOTE: The stack pointer should be 16-byte aligned!

.macro PROLOGUE
    addi    sp, sp, -16
    sd      s0, (sp)
.endm


// The macro `EPILOGUE` pops one callee-saved register from the stack.

.macro EPILOGUE
    ld      s0, (sp)
    addi    sp, sp, 16
.endm


// The macro `LDM_OPA` loads the eight words of array `a` from RAM and puts
// them in registers `aw00`-`aw03`.

.macro LDM_OPA
    ld      aw00, 0(aptr)
    ld      aw01, 8(aptr)
    ld      aw02, 16(aptr)
    ld      aw03, 24(aptr)
.endm


// The macro `STM_RES` stores the four result-words, which are in registers
// `rw00`-`rw03`, to array `r` in RAM.

.macro STM_RES
    sd      rw00, 0(rptr)
    sd      rw01, 8(rptr)
    sd      rw02, 16(rptr)
    sd      rw03, 24(rptr)
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
