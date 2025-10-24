// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bw00` holds the single word of operand `b`
#define bw00 a2
// Registers `tmp0` and `tmp1` hold temporary variables
#define tmp0 a1
#define tmp1 a2
// Register `rcon` holds the constant c of the PM-prime
#define rcon a3
// Registers `aw00` to `aw03` hold words of operand `a`
#define aw00 a4
#define aw01 a5
#define aw02 a6
#define aw03 a7
// Registers `rw00` to `rw04` hold words of the product
#define rw00 t0
#define rw01 t1
#define rw02 t2
#define rw03 t3
#define rw04 t4


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


// The macro `MULHIXC` first splits the double-length word in `dhi:dlo` into a
// 63-bit lower part and an upper part. The lower part is put in `rlo`, while
// the upper part is multiplied by the constant $c$ (in register `rcon`) and
// the single-word product is put in `rhi`.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    li      rcon, CONSTC  // rcon = 19
    srli    tmp0, \dlo, 63
    slli    \rhi, \dhi, 1
    add     \rhi, \rhi, tmp0
    slli    \rlo, \dlo, 1
    mul     \rhi, \rhi, rcon
    srli    \rlo, \rlo, 1
.endm


///////////////////////////////////////////////////////////////////////////////
////////// HELPER MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION //////////
///////////////////////////////////////////////////////////////////////////////


// The macro `LDM_OPA` loads the four words of array `a` from RAM and puts
// them in registers `aw00`-`aw03`.

.macro LDM_OPA
    ld      aw03, 24(aptr)
    ld      aw02, 16(aptr)
    ld      aw01, 8(aptr)
    ld      aw00, 0(aptr)
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
//////// SPEED-OPTIMIZED MULTIPLICATION BY 32-BIT WORD (FULLY UNROLLED) ///////
///////////////////////////////////////////////////////////////////////////////


// This implementation of multiplication of a field-element by a single 32-bit
// word is based on the operand-scanning method and includes a fast reduction
// modulo $p = 2^{255} - 19$. It is aimed at high speed, which means the loops
// are fully unrolled. Each word of the array `a` is loaded from RAM exactly
// once, and each word of the result-array `r` is stored to RAM exactly once.

.text
.global gfp_mul32_isa
.type gfp_mul32_isa,%function
// .balign 8
gfp_mul32_isa:
    LDM_OPA
    MADD_V1 rw04, rw03, aw03, bw00
    MULHIXC rw04, rw03, rw04, rw03
    MADD_V2 rw01, rw00, aw00, bw00, rw04
    MADD_V2 rw02, rw01, aw01, bw00, rw01
    MADD_V2 tmp1, rw02, aw02, bw00, rw02
    add     rw03, rw03, tmp1
    STM_RES
    ret


.end
































/*
// void gfp_mul32_isa(uint64_t *r, const uint64_t *a, uint32_t b);


// registers 

// result `r`
#define R0 a3
#define R1 a4
#define R2 a5
#define R3 a6
#define R4 a7
// operand `b`
#define B0 a2 
// operand `a`
#define A0 t0 
#define A1 t1
#define A2 t2 
#define A3 t3
// temporary
#define T0 t4
#define T1 t5
#define T2 a1
// constant `m`
#define M0 t6


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

// multiplication 

.macro MULTIPLY_B0 
  mul   R0, A0, B0
  mulhu R1, A0, B0
  mul   T0, A1, B0
  mulhu T1, A1, B0
  add   R1, R1, T0 
  sltu  T0, R1, T0 
  add   R2, T1, T0
  mul   T0, A2, B0
  mulhu T1, A2, B0
  add   R2, R2, T0 
  sltu  T0, R2, T0 
  add   R3, T1, T0
  mul   T0, A3, B0
  mulhu T1, A3, B0
  add   R3, R3, T0 
  sltu  T0, R3, T0 
  add   R4, T1, T0
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

.global gfp_mul32_isa

gfp_mul32_isa:
  PROLOGUE
  LOAD_A
  MULTIPLY_B0
  FINAL_REDC
  STORE_R
  EPILOGUE
*/
