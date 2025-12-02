// Function prototype:
// -------------------
// void gfp_sub_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
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
// `r`: pointer to array for the four 64-bit words of the result $r$.
// `a`: pointer to array containing the four 64-bit words of operand $a$.
// `b`: pointer to array containing the four 64-bit words of operand $b$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` and `tmp1` hold temporary variables
#define tmp0 a1
#define tmp1 a2
// Register `rcon` holds the constant c of the PM-prime
#define rcon a2
// Register `cryw` holds the carry word of the addition
#define cryw a3
// Registers `aw00` to `aw03` hold words of operand `a`
#define aw00 a4
#define aw01 a5
#define aw02 a6
#define aw03 a7
// Registers `bw00` to `bw03` hold words of operand `b`
#define bw00 t0
#define bw01 t1
#define bw02 t2
#define bw03 t3
// Registers `rw00` to `rw03` hold words of the dif `r`
#define rw00 t0
#define rw01 t1
#define rw02 t2
#define rw03 t3


///////////////////////////////////////////////////////////////////////////////
///////////////// MACROS FOR WORD-WISE SUBTRACTION OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `SUBW_V1` adds `aiw` to 0x1FFFFFFFFFFFFFFFC and subtracts `biw`
// from the sum. The double-length result is put in the `shi:slo` register-
// pair. This result is always positive, whereby the upper word (in `shi`) is
// in the range $[0, 2]$.

.macro SUBW_V1 shi:req, slo:req, aiw:req, biw:req
    addi    tmp0, \aiw, -4
    sltu    \shi, tmp0, \aiw
    addi    \shi, \shi, 1
    sltu    tmp1, tmp0, \biw
    sub     \slo, tmp0, \biw
    sub     \shi, \shi, tmp1
.endm


// The macro `SUBW_V2` adds `aiw` to an incoming carry in `cin` (which is
// signed and can therefore be negative) and subtracts `biw` from the sum. The
// double-length result is put in the `shi:slo` register-pair. This result can
// be negative, whereby the upper word (in `shi`) is always in the range $[-2,
// 1]$.
// NOTE: Register `slo` has to be different from `cin`.

.macro SUBW_V2 shi:req, slo:req, aiw:req, biw:req, cin:req
    srai    tmp0, \cin, 31
    add     tmp1, \aiw, \cin
    sltu    \shi, tmp1, \aiw
    add     tmp0, tmp0, \shi
    sltu    \shi, tmp1, \biw
    sub     \slo, tmp1, \biw
    sub     \shi, tmp0, \shi
.endm


// The macro `SUBW_V3` adds the word `cin` along with 4 to `sum`.
// NOTE: The bit-length of `sum` and `cin` can be up to 31.

.macro SUBW_V3 sum:req, cin:req
    add     \sum, \sum, \cin
    addi    \sum, \sum, 4
.endm


// The macro `MULHIXC` first splits the double-length word in `dhi:dlo` into a
// 63-bit lower part and an upper part. The lower part is put in `rlo`, while
// the upper part, after subtraction of 4, is multiplied by the constant $c$
// (in register `rcon`) and the single-word product (which can be negative) is
// put in `rhi`.
// NOTE: The bit-length of `dhi` can be up to $64 - \log_2(c) - 1$, e.g., for
// $c = 19$, `dhi` can be up to 58 bits long.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    li      rcon, CONSTC
    srli    tmp0, \dlo, 63
    slli    \rhi, \dhi, 1
    add     \rhi, \rhi, tmp0
    addi    \rhi, \rhi, -4
    slli    \rlo, \dlo, 1
    mul     \rhi, \rhi, rcon
    srli    \rlo, \rlo, 1
.endm


// The macro `LDM_OPA` loads the four words of array `a` from RAM and puts
// them in registers `aw00`-`aw03`.

.macro LDM_OPA
    ld      aw03, 24(aptr)
    ld      aw02, 16(aptr)
    ld      aw01, 8(aptr)
    ld      aw00, 0(aptr)
.endm


// The macro `LDM_OPB` loads the four words of array `b` from RAM and puts
// them in registers `bw00`-`bw03`.

.macro LDM_OPB
    ld      bw03, 24(bptr)
    ld      bw02, 16(bptr)
    ld      bw01, 8(bptr)
    ld      bw00, 0(bptr)
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
// .balign 8
gfp_sub_isa:
    LDM_OPA
    LDM_OPB
    SUBW_V1 cryw, rw03, aw03, bw03
    MULHIXC cryw, rw03, cryw, rw03
    SUBW_V2 cryw, rw00, aw00, bw00, cryw
    SUBW_V2 cryw, rw01, aw01, bw01, cryw
    SUBW_V2 cryw, rw02, aw02, bw02, cryw
    SUBW_V3 rw03, cryw
    STM_RES
    ret


.end
