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
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


// The macro `MACC_V2` multiplies the word `aiw` by `bjw` and adds the product
// to the double-length accumulator `rhi:rlo`, whereby the initial value of the
// accumulator is only 32 bits long (i.e., `rhi` is 0).

.macro MACC_V2 rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     \rhi, \rhi, tmp0
.endm


// The macro `MACC_V3` multiplies the word `aiw` by `bjw` and adds the product
// to the triple-length accumulator `rex:rhi:rlo`, whereby the initial value of
// the accumulator is only 64 bits long (i.e., `rex` is 0).

.macro MACC_V3 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   \rex, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     \rex, \rex, tmp0
    add     \rhi, \rhi, \rex
    sltu    \rex, \rhi, \rex
.endm


// The macro `MACC_V4` multiplies the word `aiw` by `bjw` and adds the product
// to the triple-length accumulator `rex:rhi:rlo`.

.macro MACC_V4 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   tmp1, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
    sltu    tmp1, \rhi, tmp1
    add     \rex, \rex, tmp1
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
    add     \rhi, \rhi, tmp0
    sltu    tmp0, \rhi, tmp0
    add     \cow, \cow, tmp0
.endm


// The macro DASQ_V2 doubles the double-length word `rhi:rlo` and adds the
// result along with the incoming carry `ciw` to the square of the word `aiw`.
// The two lower words of the triple-length result is put in the `rhi:rlo`
// register-pair and the higher word in the outgoing carry `cow`.
// NOTE: Register `cow` is (generally) the same as register `ciw`.

.macro DASQ_V2 cow:req, rhi:req, rlo:req, aiw:req, ciw:req
    mulhu   tmp0, \aiw, \aiw
    srli    tmp1, \rlo, 63
    slli    \rlo, \rlo, 1
    add     tmp0, tmp0, tmp1
    srli    tmp1, \rhi, 63
    slli    \rhi, \rhi, 1
    add     \rlo, \rlo, \ciw
    sltu    \cow, \rlo, \ciw
    add     \rhi, \rhi, \cow
    mul     \cow, \aiw, \aiw
    add     \rhi, \rhi, tmp0
    sltu    tmp0, \rhi, tmp0
    add     tmp1, tmp1, tmp0
    add     \rlo, \rlo, \cow
    sltu    tmp0, \rlo, \cow
    add     \rhi, \rhi, tmp0
    sltu    \cow, \rhi, tmp0
    add     \cow, \cow, tmp1
.endm


// The macro DASQ_V3 doubles the word `rlo` and adds the result along with the
// incoming carry `ciw` to the square of the word `aiw`. The double-length
// result is put in the `rhi:rlo` register-pair.

.macro DASQ_V3 rhi:req, rlo:req, aiw:req, ciw:req
    mul     tmp0, \aiw, \aiw
    mulhu   \rhi, \aiw, \aiw
    srli    tmp1, \rlo, 63
    slli    \rlo, \rlo, 1
    add     \rhi, \rhi, tmp1
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     \rhi, \rhi, tmp0
    add     \rlo, \rlo, \ciw
    sltu    tmp0, \rlo, tmp0
    add     \rhi, \rhi, tmp0
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V2` multiplies the word `aiw` by `bjw` and adds the word
// `c0w` to the product. The double-length result is put in the `rhi:rlo`
// register-pair.
// NOTE: Register `c0w` is (generally) the same as register `rlo`.

.macro MADD_V2 rhi:req, rlo:req, aiw:req, bjw:req, c0w:req
    mul     tmp0, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \c0w, tmp0
    sltu    tmp0, \rlo, tmp0
    add     \rhi, \rhi, tmp0
.endm


// The macro `MADD_V3` multiplies the word `aiw` by `bjw` and adds the two
// words `c0w` and `d0w` to the product. The double-length result is put in the
// `rhi:rlo` register-pair.
// NOTE: Register `c0w` is (generally) the same as register `rlo`, and register
// `d0w` is (generally) the same as register `rhi`.

.macro MADD_V3 rhi:req, rlo:req, aiw:req, bjw:req, d0w:req, c0w:req
    mul     tmp0, \aiw, \bjw
    mulhu   tmp1, \aiw, \bjw
    add     \rlo, tmp0, \c0w
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rlo, \rlo, \d0w
    sltu    tmp0, \rlo, \d0w
    add     \rhi, tmp1, tmp0
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
    srli    tmp0, \dlo, 63
    slli    \rhi, \dhi, 1
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
    MACC_V2 \rhi, \rlo, \a0w, \b0w
    MACC_V3 \rex, \rhi, \rlo, \a1w, \b1w
    .else  // acclen == 64
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w
    .endif
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
    MCOL_V1 rw06, rw05, rw04, aw01, aw03, 64
    MCOL_V1 rw07, rw06, rw05, aw02, aw03, 32
.endm


// The macro `DBADDSQ` doubles the 14 column sums `rw01`-`rw14` and adds the
// eight squares $a_i^2$ (which are in the "main diagonal") to the result. The
// eight words of operand $a$ are `aw00`-`aw07` and the 16 words of the final
// result are put in `rw00`-`rw15`.

.macro DBADDSQ
    DASQ_V1 cryw, rw01, rw00, aw00
    DASQ_V2 cryw, rw03, rw02, aw01, cryw
    DASQ_V2 cryw, rw05, rw04, aw02, cryw
    DASQ_V3 rw07, rw06, aw03, cryw
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
// them in registers `aw00`-`aw07`.

.macro LDM_OPA
    ld      aw00, 0(aptr)
    ld      aw01, 8(aptr)
    ld      aw02, 16(aptr)
    ld      aw03, 24(aptr)
.endm


// The macro `STM_RES` stores the eight result-words, which are in registers
// `rw00`-`rw07`, to array `r` in RAM.

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
.global gfp_sqr_isa
.type gfp_sqr_isa,%function
// .balign 8
gfp_sqr_isa:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of operand A from RAM
    MULCOLS             // Column-wise mul of all a[i]*a[j] to be doubled
    DBADDSQ             // Double current result and add squares a[i]^2
    MODREDP             // modular reduction: Rlo = (Rlo + Rhi*2*c) mod p
    STM_RES             // store the eight result-words of the result in RAM
    EPILOGUE            // pop callee-saved registers from stack
    ret


.end


/*
// void gfp_sqr_isa(uint64_t *r, const uint64_t *a);


// registers 

// result `r`
#define R0 a1
#define R1 a2
#define R2 a3
#define R3 a4
#define R4 a5
#define R5 a6
#define R6 a7
#define R7 t5
// partial product `y`
#define Y0 t1
#define Y1 t2
#define Y2 t3
// operand `a`
#define A0 a6 
#define A1 a7
#define A2 t5 
#define A3 t6 
// temporary
#define T0 t0
#define T1 t4
#define T2 t6
// constant `m` 
#define M0 t3


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
  ret 
.endm

// load operand + store result 

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer squaring (based on product-scanning)

// L != 0, M = 0, H = 0
.macro _ACCU_AIBJ_0 L, M, H 
  add   \L, \L, T0 
  sltu  T0, \L, T0
  add   \M, T1, T0
.endm 

// L != 0, M != 0, H = 0
.macro _ACCU_AIBJ_1 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  \H, \M, T1
.endm

// L != 0, M != 0, H != 0
.macro _ACCU_AIBJ_2 L, M, H
  add   \L, \L, T0
  sltu  T0, \L, T0
  add   T1, T1, T0
  add   \M, \M, T1
  sltu  T1, \M, T1
  add   \H, \H, T1
.endm

// `z` = `z` + `y` + `y` (Y2 = 0)
// L != 0, M = 0, H = 0
.macro _ACCU_PRDT_0 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   \M, T0, T1 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   \H, T0, T1 
.endm

// `z` = `z` + `y` + `y` (Y2 = 0)
// L != 0, M != 0, H = 0
.macro _ACCU_PRDT_1 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   T0, T0, T1 
  add   \M, \M, T0 
  sltu  \H, \M, T0 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   T0, T0, T1 
  add   \H, \H, T0
.endm

// `z` = `z` + `y` + `y` (Y2 != 0)
// L != 0, M != 0, H = 0
.macro _ACCU_PRDT_2 L, M, H 
  add   \L, \L, Y0
  sltu  T0, \L, Y0
  add   \L, \L, Y0 
  sltu  T1, \L, Y0 
  add   T0, T0, T1 
  add   \M, \M, T0 
  sltu  \H, \M, T0 
  add   \M, \M, Y1 
  sltu  T0, \M, Y1 
  add   \M, \M, Y1 
  sltu  T1, \M, Y1
  add   T0, T0, T1 
  add   \H, \H, T0
  add   \H, \H, Y2
  add   \H, \H, Y2
.endm

.macro COMPUTE_R0
  mul   R0, A0, A0
  mulhu R1, A0, A0
.endm

.macro COMPUTE_R1
  mul   Y0, A0, A1
  mulhu Y1, A0, A1
  _ACCU_PRDT_0  R1, R2, R3
.endm

.macro COMPUTE_R2
  mul   Y0, A0, A2
  mulhu Y1, A0, A2
  _ACCU_PRDT_1  R2, R3, R4
  mul   T0, A1, A1
  mulhu T1, A1, A1
  _ACCU_AIBJ_2  R2, R3, R4 
.endm

.macro COMPUTE_R3
  mul   Y0, A0, A3
  mulhu Y1, A0, A3
  mul   T0, A1, A2
  mulhu T1, A1, A2
  _ACCU_AIBJ_1  Y0, Y1, Y2
  _ACCU_PRDT_2  R3, R4, R5
.endm

.macro COMPUTE_R4
  mul   Y0, A1, A3
  mulhu Y1, A1, A3
  _ACCU_PRDT_1  R4, R5, R6
  mul   T0, A2, A2
  mulhu T1, A2, A2
  _ACCU_AIBJ_2  R4, R5, R6
.endm

.macro COMPUTE_R5
  mul   Y0, A2, A3
  mulhu Y1, A2, A3
  _ACCU_PRDT_1  R5, R6, R7
.endm

.macro COMPUTE_R6
  mul   T0, A3, A3
  mulhu T1, A3, A3
  add   R6, R6, T0
  sltu  T0, R6, T0
  add   T1, T1, T0
.endm

.macro COMPUTE_R7
  add   R7, R7, T1
.endm

// reduction R0-R3, T1 = R0-R3 + 38*(R4-R7)

.macro REDUCTION 
  li    M0, 38
  mul   T0, R4, M0
  mulhu T1, R4, M0
  add   R0, R0, T0 
  sltu  T0, R0, T0 
  add   T1, T1, T0 
  add   R1, R1, T1 
  sltu  T2, R1, T1
  mul   T0, R5, M0
  mulhu T1, R5, M0
  add   R1, R1, T0 
  sltu  T0, R1, T0 
  add   T1, T1, T0
  add   T1, T1, T2 
  add   R2, R2, T1 
  sltu  T2, R2, T1 
  mul   T0, R6, M0 
  mulhu T1, R6, M0 
  add   R2, R2, T0 
  sltu  T0, R2, T0 
  add   T1, T1, T0 
  add   T1, T1, T2
  add   R3, R3, T1 
  sltu  T2, R3, T1 
  mul   T0, R7, M0 
  mulhu T1, R7, M0 
  add   R3, R3, T0 
  sltu  T0, R3, T0 
  add   T1, T1, T0 
  add   T1, T1, T2
.endm

// final reduction 

.macro FINAL_REDC
  srli  T2, R3, 63
  slli  R3, R3, 1 
  srli  R3, R3, 1
  slli  T1, T1, 1
  or    T2, T1, T2 
  li    M0, 19 
  mul   T0, T2, M0 
  add   R0, R0, T0 
  sltu  T0, R0, T0 
  add   R1, R1, T0 
  sltu  T0, R1, T0 
  add   R2, R2, T0 
  sltu  T0, R2, T0
  add   R3, R3, T0 
.endm


.section .text

.global gfp_sqr_isa

gfp_sqr_isa:
  PROLOGUE
  LOAD_A
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  REDUCTION
  FINAL_REDC
  STORE_R
  EPILOGUE
*/
