// Function prototype:
// -------------------
// void gfp_mul32_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_mul32_isa` computes the product $r = a \cdot b \bmod p$ of
// two elements $a$ and $b$ of a pseudo-Mersenne prime field, with element $b$
// being up to 32 bits long. The prime $p$ is the 255-bit pseudo-Mersenne prime
// $p = 2^{255} - 19$. Operand $a$ is allowed to be larger than $p$. The result
// $r$ may not be fully reduced, but $r$ is always less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.
// `b`: pointer to the 32-bit word of operand $b$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` to `tmp2` hold intermediate results
#define tmp0 a1
#define tmp1 a2
// Registers `aw00` to `aw07` hold words of operand `a`
#define aw00 a4
#define aw01 a5
#define aw02 a6
#define aw03 a7
#define aw04 t0
#define aw05 t1
#define aw06 t2
#define aw07 t3
// Registers `rw00` to `rw08` hold words of the product
#define rw00 a3
#define rw01 a4
#define rw02 a5
#define rw03 a6
#define rw04 a7
#define rw05 t0
#define rw06 t1
#define rw07 t2
#define rw08 t3
// Register `bw00` holds the single word of operand `b`
#define bw00 t4

// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CCON, 19


///////////////////////////////////////////////////////////////////////////////
///////////////// MACROS FOR WORD-WISE MULTIPLY-ADD OPERATIONS ////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V1` multiplies the word `aiw` by `bjw` and puts the double-
// length product in `rhi`:`rlo` (i.e., this macro performs a multiply-add
// operation where 0 is added to the product, which boils down to an ordinary
// multiplication).

.macro MADD_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


// The macro `MADD_V2` multiplies the word `aiw` by `bjw` and adds `rlo` to the
// double-length product. The lower half of the result is put in `rlo` and the
// upper part in `rhi` (`tlo` holds temporary results).

.macro MADD_V2 rhi:req, rlo:req, aiw:req, bjw:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \rhi, \rhi, \tlo
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULHIXC` splits the double-length word in `rw08:rw07` into a 31-
// bit lower part and a 33-bit upper part. The lower part remains in `rw07`,
// while the upper part is multiplied by the constant $c = 19$. The resulting
// product is put in the `rhi:rlo` register-pair

.macro MULHIXC rhi:req, rlo:req
    li      bw00, 2*CCON
    srli    \rhi, rw07, 31
    sub     \rlo, zero, \rhi
    andi    \rlo, \rlo, CCON
    mul     \rhi, rw08, bw00
    add     \rlo, \rlo, \rhi
    sltu    \rhi, \rlo, \rhi
    mulhu   rw08, rw08, bw00
    slli    rw07, rw07, 1
    srli    rw07, rw07, 1
    add     \rhi, \rhi, rw08
.endm


// The macro `ADDWORD` adds the word `adw` to the 8-word operand `p7w`-`p0w`.

.macro ADDWORD whi:req, wlo:req
    add     rw00, rw00, \wlo
    sltu    \wlo, rw00, \wlo
    add     \whi, \whi, \wlo
    add     rw01, rw01, \whi
    sltu    \wlo, rw01, \whi
    add     rw02, rw02, \wlo
    sltu    \wlo, rw02, \wlo
    add     rw03, rw03, \wlo
    sltu    \wlo, rw03, \wlo
    add     rw04, rw04, \wlo
    sltu    \wlo, rw04, \wlo
    add     rw05, rw05, \wlo
    sltu    \wlo, rw05, \wlo
    add     rw06, rw06, \wlo
    sltu    \wlo, rw06, \wlo
    add     rw07, rw07, \wlo
.endm


///////////////////////////////////////////////////////////////////////////////
///////////////// MACROS FOR ROW-WISE MULTIPLY-ADD OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULROW` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `tmp2`) and puts the 9-word product in `p0w`-`p8w`. This macro
// corresponds to the operation $r = a \cdot b_0$ performed by the very first
// iteration of the outer loop of the operand-scanning method. The multiplier
// $b_j$ is loaded to `tmp2` (i.e., `rw15`) via base address `bptr` and offset
// `idx`. The word `tmp0` (i.e., `aptr`) holds temporary results.

.macro MULROW
    lw      bw00, 0(bptr)
    MADD_V1 rw01, rw00, aw00, bw00
    MADD_V2 rw02, rw01, aw01, bw00, tmp0
    MADD_V2 rw03, rw02, aw02, bw00, tmp0
    MADD_V2 rw04, rw03, aw03, bw00, tmp0
    MADD_V2 rw05, rw04, aw04, bw00, tmp0
    MADD_V2 rw06, rw05, aw05, bw00, tmp0
    MADD_V2 rw07, rw06, aw06, bw00, tmp0
    MADD_V2 rw08, rw07, aw07, bw00, tmp0
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MODRED2` performs a (partial) reduction of the 9-word operand
// `rw00`-`rw08` modulo $p = 2^{255} - 19$ to obtain an 8-word result. First,
// the macro `MULHIXC` is called to split the double-length word `rw08`:`rw07`
// into a 31-bit lower part and a (normally much shorter) upper part, which is
// then multiplied by $c = 19$. Then, the macro `ADDWORD` adds the obtained
// product, which fits into a single word, to the eight words `rw00`-`rw07`.

.macro MODRED
    MULHIXC tmp1, tmp0
    ADDWORD tmp1, tmp0
.endm


///////////////////////////////////////////////////////////////////////////////
////////// HELPER MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION //////////
///////////////////////////////////////////////////////////////////////////////


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
.global gfp_mul32_isa
.type gfp_mul32_isa,%function
.balign 16
gfp_mul32_isa:
    LDM_OPA             // load the eight words of array `a` from RAM
    MULROW              // row-wise multiplication R += A*b[j]*2^(32*j)
    MODRED              // 2nd step of reduction: obtain 8-word result
    STM_RES             // store the result-words in array `r` in RAM
    ret

.end
