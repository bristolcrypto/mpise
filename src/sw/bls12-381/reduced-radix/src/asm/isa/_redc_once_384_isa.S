// void _redc_once_384_isa(vec384 ret, const vec384 a, const vec384 p);


// registers 

// result `r`
#define R0 a5
#define R1 a6
#define R2 a7
#define R3 s0
#define R4 s1
#define R5 s2
#define R6 s3
// modulus `p`
#define P0 t2
#define P1 t3
#define P2 t4
#define P3 t5
#define P4 t6
#define P5 a3
#define P6 a4
// temporary 
#define T_ t0
// mask `m`
#define M_ t1


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  li    M_, 0x007fffffffffffff
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  addi  sp, sp, 32
  ret 
.endm

// load modulus/operand + store result

.macro LOAD_P
  ld    P0,  0(a2)
  ld    P1,  8(a2)
  ld    P2, 16(a2)
  ld    P3, 24(a2)
  ld    P4, 32(a2)
  ld    P5, 40(a2)
  ld    P6, 48(a2)
.endm

.macro LOAD_A
  ld    R0,  0(a1)
  ld    R1,  8(a1)
  ld    R2, 16(a1)
  ld    R3, 24(a1)
  ld    R4, 32(a1)
  ld    R5, 40(a1)
  ld    R6, 48(a1)
.endm

.macro STORE_R 
  sd    P0,  0(a0)
  sd    P1,  8(a0)
  sd    P2, 16(a0)
  sd    P3, 24(a0)
  sd    P4, 32(a0)
  sd    P5, 40(a0)
  sd    P6, 48(a0)
.endm

// arithmetic computation

.macro R_SUB_P
  sub   P0, R0, P0
  sub   P1, R1, P1
  sub   P2, R2, P2
  sub   P3, R3, P3
  sub   P4, R4, P4
  sub   P5, R5, P5
  sub   P6, R6, P6
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T_
  xor   \P, \P, \R
.endm

.macro CSWAP 
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
  _CSWAP    R6, P6
.endm

// carry propagation

.macro GET_SIGN 
  srai  T_, P0, 57
  and   P0, P0, M_
  add   P1, P1, T_
  srai  T_, P1, 57
  and   P1, P1, M_
  add   P2, P2, T_
  srai  T_, P2, 57
  and   P2, P2, M_
  add   P3, P3, T_
  srai  T_, P3, 57
  and   P3, P3, M_
  add   P4, P4, T_
  srai  T_, P4, 57
  and   P4, P4, M_
  add   P5, P5, T_
  srai  T_, P5, 57
  and   P5, P5, M_
  add   P6, P6, T_
  srai  T_, P6, 63
.endm


.section .text

.global _redc_once_384_isa

_redc_once_384_isa:
  PROLOGUE
  LOAD_P
  LOAD_A
  R_SUB_P
  GET_SIGN
  CSWAP
  STORE_R
  EPILOGUE
