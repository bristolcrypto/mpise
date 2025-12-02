// Function prototype:
// -------------------
// void gfp_mul_ise(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_mul_ise` computes the product $r = a \cdot b \bmod p$ of
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
// Register `bptr` holds the start address of array `b`
#define bptr a2
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
// Registers `bw00` to `bw0j` hold words of operand `b`
#define bw00 s1
#define bw0j a0
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
///////////////// MACROS FOR WORD-WISE MULTIPLY-ADD OPERATIONS ////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V1` multiplies the word `aiw` by `bjw` and puts the product
// in the `rhi:rlo` register-pair (i.e., this macro performs a multiply-add
// operation where 0 is added to the product, i.e., a normal multiplication).
// NOTE: Register `rlo` has to be different from `aiw` and `bjw`.

.macro MADD_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mulhu   \rhi, \aiw, \bjw
    mul     \rlo, \aiw, \bjw
.endm


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


// The macro `MADD_V4` is basically the same as `MADD_V3`, but includes the
// loading of the word $b_j$ of the multiplier to `bjw` via base-address `bptr`
// and offset `j`.

.macro MADD_V4 rhi:req, rlo:req, aiw:req, bjw:req, d0w:req, c0w:req, j:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    maddlu  tmp0, \aiw, \bjw, \c0w
    maddhu  tmp1, \aiw, \bjw, \c0w
    lw      \bjw, \j(bptr)
    add     \rlo, \d0w, tmp0
    cacc    \rhi, \d0w, tmp0, tmp1
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      tmp0, \d0w
    maddlu  tmp0, \aiw, \bjw
    maddhu  \rhi, \aiw, \bjw
    lw      \bjw, \j(bptr)
    cacc    \rhi, \c0w, tmp0
    add     \rlo, \c0w, tmp0
#endif
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


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
///////////////// MACROS FOR ROW-WISE MULTIPLY-ADD OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MROW_V1` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `bw00`) and puts the 9-word product in `p0w`-`p8w`. This macro
// corresponds to the operation $r = a \cdot b_0$ performed by the very first
// iteration of the outer loop of the operand-scanning method. The words $b_0$
// and $b_j$` of the multiplier are loaded to `bw00` and `bw0j`, respectively,
// via base-address `bptr` and offset `j`.

.macro MROW_V1 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req, j:req
    lw      bw00, 0(bptr)
    lw      bw0j, \j(bptr)
    MADD_V1 \p1w, \p0w, aw00, bw00
    MADD_V2 \p2w, \p1w, aw01, bw00, \p1w
    MADD_V2 \p3w, \p2w, aw02, bw00, \p2w
    MADD_V2 \p4w, \p3w, aw03, bw00, \p3w
    MADD_V2 \p5w, \p4w, aw04, bw00, \p4w
    MADD_V2 \p6w, \p5w, aw05, bw00, \p5w
    MADD_V2 \p7w, \p6w, aw06, bw00, \p6w
    MADD_V2 \p8w, \p7w, aw07, bw00, \p7w
.endm


// The macro `MROW_V2` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `bw0j`) and adds the 9-word product to operand `p0w`-`p8w`.
// This macro corresponds to the operation $r = r + a \cdot b_j \cdot 2^{32j}$
// for $1 \leq j < 8$ performed by the seven last iterations of the outer loop
// of the operand-scanning method. The word $b_j$ of the multiplier is loaded
// to `bw0j` via base address `bptr` and offset `j`.
// NOTE: The word `p8w` is used for temporary results.

.macro MROW_V2 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req, j:req
    MADD_V2 \p8w, \p0w, aw00, bw0j, \p0w
    MADD_V3 \p8w, \p1w, aw01, bw0j, \p8w, \p1w
    MADD_V3 \p8w, \p2w, aw02, bw0j, \p8w, \p2w
    MADD_V3 \p8w, \p3w, aw03, bw0j, \p8w, \p3w
    MADD_V3 \p8w, \p4w, aw04, bw0j, \p8w, \p4w
    MADD_V3 \p8w, \p5w, aw05, bw0j, \p8w, \p5w
    MADD_V3 \p8w, \p6w, aw06, bw0j, \p8w, \p6w
    MADD_V4 \p8w, \p7w, aw07, bw0j, \p8w, \p7w, \j
.endm


// The macro `MROW_V3` is basically the same as `MROW_V2`, but does not include
// the loading of a word of the multiplier.

.macro MROW_V3 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req
    MADD_V2 \p8w, \p0w, aw00, bw0j, \p0w
    MADD_V3 \p8w, \p1w, aw01, bw0j, \p8w, \p1w
    MADD_V3 \p8w, \p2w, aw02, bw0j, \p8w, \p2w
    MADD_V3 \p8w, \p3w, aw03, bw0j, \p8w, \p3w
    MADD_V3 \p8w, \p4w, aw04, bw0j, \p8w, \p4w
    MADD_V3 \p8w, \p5w, aw05, bw0j, \p8w, \p5w
    MADD_V3 \p8w, \p6w, aw06, bw0j, \p8w, \p6w
    MADD_V3 \p8w, \p7w, aw07, bw0j, \p8w, \p7w
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULROWS` multiplies the 8-word operand $a$ (i.e., the eight words
// `aw00`-`aw07`) by the 8-word operand $b$ (which is loaded word by word from
// RAM) in a row-wise fashion. The 16-word product is put in `rw00`-`rw15`.
// NOTE: The word $b_j$ of the multiplier loaded in `MROW_V1` and `MROW_V2` is
// actually used in the next iteration of the outer loop. This loading of $b_j$
// in advance can help to prevent pipeline stalls.

.macro MULROWS
    MROW_V1 rw08, rw07, rw06, rw05, rw04, rw03, rw02, rw01, rw00, 4
    MROW_V2 rw09, rw08, rw07, rw06, rw05, rw04, rw03, rw02, rw01, 8
    MROW_V2 rw10, rw09, rw08, rw07, rw06, rw05, rw04, rw03, rw02, 12
    MROW_V2 rw11, rw10, rw09, rw08, rw07, rw06, rw05, rw04, rw03, 16
    MROW_V2 rw12, rw11, rw10, rw09, rw08, rw07, rw06, rw05, rw04, 20
    MROW_V2 rw13, rw12, rw11, rw10, rw09, rw08, rw07, rw06, rw05, 24
    MROW_V2 rw14, rw13, rw12, rw11, rw10, rw09, rw08, rw07, rw06, 28
    MROW_V3 rw15, rw14, rw13, rw12, rw11, rw10, rw09, rw08, rw07
.endm


// The macro `MODREDP` reduces the 16-word operand `rw00`-`rw15` modulo the
// prime $p = 2^{256} - 19$ to get an 8-word result. This reduction consists
// of two steps: (i) the upper half `rw08`-`rw15` is multiplied by $2c = 38$
// and the obtained 9-word product is added to the lower half `rw08`-`rw15`,
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
////////// HELPER MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION //////////
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
///////// SPEED-OPTIMIZED PRIME-FIELD MULTIPLICATION (FULLY UNROLLED) /////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field multiplication is based on the operand-
// scanning method and includes a fast reduction modulo $p = 2^{255} - 19$. It
// is aimed at high speed, which means the loops are fully unrolled. Each word
// of the arrays `a` and `b` is loaded from RAM exactly once, and each word of
// the result-array `r` is stored to RAM exactly once.

.text
.global gfp_mul_ise
.type gfp_mul_ise,%function
// .balign 8
gfp_mul_ise:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of array `a` from RAM
    MULROWS             // row-wise multiplication R += A*b[j]*2^(32*j)
    MODREDP             // modular reduction: Rlo = (Rlo + Rhi*2*c) mod p
    STM_RES             // store the eight result-words in array `r` in RAM
    EPILOGUE            // pop callee-saved registers from stack
    ret


.end
