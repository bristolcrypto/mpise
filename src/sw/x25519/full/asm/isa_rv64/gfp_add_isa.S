// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `tmp0` holds intermediate/temporary results
#define tmp0 a1
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
// Registers `rw00` to `rw03` hold words of the sum `r`
#define rw00 t0
#define rw01 t1
#define rw02 t2
#define rw03 t3


///////////////////////////////////////////////////////////////////////////////
/////////////////// MACROS FOR WORD-WISE ADDITION OPERATIONS //////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `ADDW_V1` adds the word `aiw` and `biw` and puts the sum in the
// `shi:slo` register-pair.

.macro ADDW_V1 shi:req, slo:req, aiw:req, biw:req
    add     \slo, \aiw, \biw
    sltu    \shi, \slo, \aiw
.endm


// The macro `ADDW_V2` adds the word `aiw` and `biw` together with an incoming
// carry in `cin` and puts the sum in the `shi:slo` register-pair.
// NOTE: Register `slo` has to be different from `cin`.

.macro ADDW_V2 shi:req, slo:req, aiw:req, biw:req, cin:req
    add     \slo, \aiw, \biw
    sltu    tmp0, \slo, \aiw
    add     \slo, \slo, \cin
    sltu    \shi, \slo, \cin
    add     \shi, \shi, tmp0
 .endm


// The macro `MULHIXC` first splits the double-length word in `dhi:dlo` into a
// 63-bit lower part and an upper part. The lower part is put in `rlo`, while
// the upper part is multiplied by the constant $c$ (in register `rcon`) and
// the single-word product is put in `rhi`.
// NOTE: The bit-length of `dhi` can be up to $32 - \log_2(c) - 1$, e.g., for
// $c = 19$, `dhi` can be up to 58 bits long.

.macro MULHIXC rhi:req, rlo:req, dhi:req, dlo:req
    li      rcon, CONSTC
    srli    tmp0, \dlo, 63
    slli    \rhi, \dhi, 1
    add     \rhi, \rhi, tmp0
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
// .balign 8
gfp_add_isa:
    LDM_OPA
    LDM_OPB
    ADDW_V1 cryw, rw03, aw03, bw03
    MULHIXC cryw, rw03, cryw, rw03
    ADDW_V2 cryw, rw00, aw00, bw00, cryw
    ADDW_V2 cryw, rw01, aw01, bw01, cryw
    ADDW_V2 cryw, rw02, aw02, bw02, cryw
    add     rw03, rw03, cryw
    STM_RES
    ret


.end


/*
// void gfp_add_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


// registers 

// result `r`
#define R0 a3
#define R1 a4
#define R2 a5 
#define R3 a6
#define R4 t3
// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
// operand `a`
#define A0 t4 
#define A1 t5 
#define A2 t6 
#define A3 a7
// temporary
#define T0 t0
#define T1 t1
#define T2 t4
// constant `m`
#define M0 t2


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

// integer addition

.macro ADDITION 
  add   R0, A0, T0 
  sltu  T0, R0, A0

  add   R1, A1, T0 
  sltu  T0, R1, T0 
  add   R1, R1, B1 
  sltu  T1, R1, B1 
  or    T0, T0, T1 

  add   R2, A2, T0 
  sltu  T0, R2, T0 
  add   R2, R2, B2 
  sltu  T1, R2, B2 
  or    T0, T0, T1  

  add   R3, A3, T0 
  sltu  T0, R3, T0 
  add   R3, R3, B3 
  sltu  T1, R3, B3 
  or    R4, T0, T1 
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

.global gfp_add_isa

gfp_add_isa:
  PROLOGUE
  LOAD_A
  LOAD_B
  ADDITION
  FINAL_REDC
  STORE_R
  EPILOGUE
*/
