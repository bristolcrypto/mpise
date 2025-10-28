// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` and `tmp1` hold temporary variables
#define tmp0 s0
#define tmp1 s1
// Register `rcon` holds the constant c of the PM-prime
#define rcon t5
// Registers `aw00` to `aw03` hold words of operand `a`
#define aw00 a3
#define aw01 a4
#define aw02 a5
#define aw03 a6
// Registers `bw00` to `bw03` hold words of operand `b`
#define bw00 s1
#define bw01 t5
#define bw02 t6
#define bw03 t5
// Registers `rw00` to `rw07` hold words of the product
#define rw00 a7
#define rw01 t0
#define rw02 t1
#define rw03 t2
#define rw04 t3
#define rw05 t4
#define rw06 a1
#define rw07 a2


///////////////////////////////////////////////////////////////////////////////
///////////////// MACROS FOR WORD-WISE MULTIPLY-ADD OPERATIONS ////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V1` multiplies the word `aiw` by `bjw` and puts the product
// in the `rhi:rlo` register-pair (i.e., this macro performs a multiply-add
// operation where 0 is added to the product, i.e., a normal multiplication).
// NOTE: Register `rlo` has to be different from `aiw` and `bjw`.

.macro MADD_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


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
    srli    tmp0, \dlo, 63
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
// word (held in `bw0j`) and puts the 9-word product in `p0w`-`p8w`. This macro
// corresponds to the operation $r = a \cdot b_0$ performed by the very first
// iteration of the outer loop of the operand-scanning method. The word $b_0$
// of the multiplier is loaded to `bw0j` via base-address `bptr` and offset
// `j`.

.macro MROW_V1 p4w:req, p3w:req, p2w:req, p1w:req, p0w:req, bjw:req
    MADD_V1 \p1w, \p0w, aw00, \bjw
    MADD_V2 \p2w, \p1w, aw01, \bjw, \p1w
    MADD_V2 \p3w, \p2w, aw02, \bjw, \p2w
    MADD_V2 \p4w, \p3w, aw03, \bjw, \p3w
.endm


// The macro `MROW_V2` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `bw0j`) and adds the 9-word product to operand `p0w`-`p8w`.
// This macro corresponds to the operation $r = r + a \cdot b_j \cdot 2^{32j}$
// for $1 \leq j < 8$ performed by the seven last iterations of the outer loop
// of the operand-scanning method. The word $b_j$ of the multiplier is loaded
// to `bw0j` via base address `bptr` and offset `j`.
// NOTE: The word `p4w` is used for temporary results.

.macro MROW_V2 p4w:req, p3w:req, p2w:req, p1w:req, p0w:req, bjw:req
    MADD_V2 \p4w, \p0w, aw00, \bjw, \p0w
    MADD_V3 \p4w, \p1w, aw01, \bjw, \p4w, \p1w
    MADD_V3 \p4w, \p2w, aw02, \bjw, \p4w, \p2w
    MADD_V3 \p4w, \p3w, aw03, \bjw, \p4w, \p3w
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULROWS` multiplies the 8-word operand $a$ (i.e., the eight words
// `aw00`-`aw07`) by the 8-word operand $b$ (which is loaded word by word from
// RAM) in a row-wise fashion. The 16-word product is put in `rw00`-`rw15`.

.macro MULROWS
    ld      bw00, 0(bptr)
    ld      bw01, 8(bptr)
    ld      bw02, 16(bptr)
    MROW_V1 rw04, rw03, rw02, rw01, rw00, bw00
    MROW_V2 rw05, rw04, rw03, rw02, rw01, bw01
    ld      bw03, 24(bptr)
    MROW_V2 rw06, rw05, rw04, rw03, rw02, bw02
    MROW_V2 rw07, rw06, rw05, rw04, rw03, bw03
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
////////// HELPER MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION //////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes two callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -16
    sd      s0, (sp)
    sd      s1, 8(sp)
.endm


// The macro `EPILOGUE` pops two callee-saved registers from the stack.

.macro EPILOGUE
    ld      s0, (sp)
    ld      s1, 8(sp)
    addi    sp, sp, 16
.endm


// The macro `LDM_OPA` loads the four words of array `a` from RAM and puts
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
///////// SPEED-OPTIMIZED PRIME-FIELD MULTIPLICATION (FULLY UNROLLED) /////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field multiplication is based on the operand-
// scanning method and includes a fast reduction modulo $p = 2^{255} - 19$. It
// is aimed at high speed, which means the loops are fully unrolled. Each word
// of the arrays `a` and `b` is loaded from RAM exactly once, and each word of
// the result-array `r` is stored to RAM exactly once.

.text
.global gfp_mul_isa
.type gfp_mul_isa,%function
// .balign 8
gfp_mul_isa:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of array `a` from RAM
    MULROWS             // row-wise multiplication R += A*b[j]*2^(32*j)
    MODREDP             // modular reduction: Rlo = (Rlo + Rhi*2*c) mod p
    STM_RES             // store the eight result-words in array `r` in RAM
    EPILOGUE            // pop callee-saved registers from stack
    ret


.end


/*
// void gfp_mul_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


// registers 

// result `r`
#define R0 a1
#define R1 a2
#define R2 a3 
#define R3 a4
#define R4 a5
#define R5 a6
#define R6 t1
#define R7 t2
// operand `b` 
#define B0 t1 
#define B1 t2
#define B2 t3
#define B3 t4
// operand `a`
#define A0 a6 
#define A1 a7 
#define A2 t5 
#define A3 t6
// temporary
#define T0 t0
#define T1 s0
#define T2 t4
// constant `m`
#define M0 t3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -8
  sd    s0,  0(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  addi  sp, sp, 8 
  ret 
.endm

// load operand + store result 

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
.endm 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer multiplication (based on product-scanning)

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

.macro COMPUTE_R0
  mul   R0, A0, B0
  mulhu R1, A0, B0
.endm

.macro COMPUTE_R1 
  mul   T0, A0, B1
  mulhu T1, A0, B1
  _ACCU_AIBJ_0  R1, R2, R3
  mul   T0, A1, B0 
  mulhu T1, A1, B0
  _ACCU_AIBJ_1  R1, R2, R3
.endm

.macro COMPUTE_R2
  mul   T0, A0, B2 
  mulhu T1, A0, B2
  _ACCU_AIBJ_1  R2, R3, R4
  mul   T0, A1, B1
  mulhu T1, A1, B1
  _ACCU_AIBJ_2  R2, R3, R4 
  mul   T0, A2, B0
  mulhu T1, A2, B0
  _ACCU_AIBJ_2  R2, R3, R4
.endm 

.macro COMPUTE_R3
  mul   T0, A0, B3
  mulhu T1, A0, B3
  _ACCU_AIBJ_1  R3, R4, R5
  mul   T0, A1, B2
  mulhu T1, A1, B2
  _ACCU_AIBJ_2  R3, R4, R5 
  mul   T0, A2, B1
  mulhu T1, A2, B1
  _ACCU_AIBJ_2  R3, R4, R5
  mul   T0, A3, B0
  mulhu T1, A3, B0
  _ACCU_AIBJ_2  R3, R4, R5
.endm

.macro COMPUTE_R4
  mul   T0, A1, B3
  mulhu T1, A1, B3
  _ACCU_AIBJ_1  R4, R5, R6
  mul   T0, A2, B2
  mulhu T1, A2, B2
  _ACCU_AIBJ_2  R4, R5, R6 
  mul   T0, A3, B1
  mulhu T1, A3, B1
  _ACCU_AIBJ_2  R4, R5, R6 
.endm

.macro COMPUTE_R5
  mul   T0, A2, B3
  mulhu T1, A2, B3
  _ACCU_AIBJ_1  R5, R6, R7
  mul   T0, A3, B2
  mulhu T1, A3, B2
  _ACCU_AIBJ_2  R5, R6, R7
.endm

.macro COMPUTE_R6
  mul   T0, A3, B3
  mulhu T1, A3, B3
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

.global gfp_mul_isa

gfp_mul_isa:
  PROLOGUE
  LOAD_A
  LOAD_B
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
