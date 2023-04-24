// void _redc_once_384_isa(vec384 ret, const vec384 a, const vec384 p);


// registers 

// result and operand `r`
#define R0 a5
#define R1 a6
#define R2 a7
#define R3 s0
#define R4 s1
#define R5 s2
// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a3
#define P5 a4
// temporary
#define T0 t0
#define T1 t1
#define T2 t2


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -24
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  addi  sp, sp, 24
  ret 
.endm

// load modulus + store result

.macro LOAD_P
  ld    P0,  0(a2)
  ld    P1,  8(a2)
  ld    P2, 16(a2)
  ld    P3, 24(a2)
  ld    P4, 32(a2)
  ld    P5, 40(a2)
.endm

.macro LOAD_A
  ld    R0,  0(a1)
  ld    R1,  8(a1)
  ld    R2, 16(a1)
  ld    R3, 24(a1)
  ld    R4, 32(a1)
  ld    R5, 40(a1)
.endm

.macro STORE_R 
  sd    P0,  0(a0)
  sd    P1,  8(a0)
  sd    P2, 16(a0)
  sd    P3, 24(a0)
  sd    P4, 32(a0)
  sd    P5, 40(a0)
.endm

// arithmetic computation

.macro _A_SUB_P R, P
  sltu  T1, \R, \P
  sub   \P, \R, \P
  sltu  T2, \P, T0 
  sub   \P, \P, T0
  or    T0, T1, T2
.endm

.macro A_SUB_P 
  sltu  T0, R0, P0 
  sub   P0, R0, P0
  _A_SUB_P  R1, P1
  _A_SUB_P  R2, P2
  _A_SUB_P  R3, P3
  _A_SUB_P  R4, P4
  _A_SUB_P  R5, P5
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T0
  xor   \P, \P, \R
.endm

.macro CSWAP 
  sub   T0, x0, T0
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
.endm


.section .text

.global _redc_once_384_isa

_redc_once_384_isa:
  PROLOGUE
  LOAD_P
  LOAD_A
  A_SUB_P
  CSWAP
  STORE_R
  EPILOGUE
