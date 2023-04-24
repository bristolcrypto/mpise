// void _redc_mont_384_ise(vec384 ret, const vec768 a, const vec384 p, limb_t n0);


#include "ise.h"


// registers 

// accumulator `z`
#define Z0 t0
#define Z1 t1
#define Z2 t2
// modulus `p`
#define P0 t6
#define P1 a4
#define P2 a5
#define P3 a6
#define P4 a7
#define P5 t4
// operand `a`
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 s3
#define A4 s4
#define A5 s5
#define A_ t5
// temporary
#define T0 t3
// constant `u = -p^-1 mod 2^64`
#define U_ a3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -56
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  addi  sp, sp, 56
  ret 
.endm

// load operand

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
.endm 

.macro LOAD_P
  ld    P0,  0(a2)
  ld    P1,  8(a2)
  ld    P2, 16(a2)
  ld    P3, 24(a2)
  ld    P4, 32(a2)
  ld    P5, 40(a2)
.endm 

// first loop of Montgomery reduction (based on product-scanning)

.macro _ACCU_OPERAND L, M, H, A 
  add    \L, \L, \A
  sltu   T0, \L, \A
  add    \M, \M, T0
  sltu   \H, \M, T0
.endm

// L != 0, M = 0, H = 0
.macro _ACCU_PRDCT_0 L, M, H, T, A, B 
  maddhu \M, \A, \B, \L
  maddlu \L, \A, \B, \L
.endm

// L != 0, M != 0, H = 0
.macro _ACCU_PRDCT_1 L, M, H, T, A, B 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  add    \M, \M, \T
  sltu   \H, \M, \T
.endm

// L != 0, M != 0, H != 0
.macro _ACCU_PRDCT_2 L, M, H, T, A, B 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  cadd   \H, \M, \T, \H
  add    \M, \M, \T
.endm

.macro COMPUTE_A0
  mv     Z0, A0
  mul    A0, Z0, U_ 
  _ACCU_PRDCT_0  Z0, Z1, Z2, T0, A0, P0
.endm

.macro COMPUTE_A1
  add    Z1, Z1, A1
  sltu   Z2, Z1, A1
  _ACCU_PRDCT_1  Z1, Z2, Z0, T0, A0, P1
  mul    A1, Z1, U_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A1, P0
.endm

.macro COMPUTE_A2
  _ACCU_OPERAND  Z2, Z0, Z1, A2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A0, P2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A1, P1
  mul    A2, Z2, U_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A2, P0
.endm

.macro COMPUTE_A3
  _ACCU_OPERAND  Z0, Z1, Z2, A3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A0, P3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A1, P2
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A2, P1
  mul    A3, Z0, U_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A3, P0  
.endm

.macro COMPUTE_A4
  _ACCU_OPERAND  Z1, Z2, Z0, A4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A0, P4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A1, P3
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A2, P2
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A3, P1
  mul    A4, Z1, U_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A4, P0
.endm

.macro COMPUTE_A5
  _ACCU_OPERAND  Z2, Z0, Z1, A5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A0, P5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A1, P4
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A2, P3
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A3, P2
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A4, P1
  mul    A5, Z2, U_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A5, P0
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0 
  ld     A_, 48(a1)
  _ACCU_OPERAND  Z0, Z1, Z2, A_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A1, P5
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A2, P4
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A3, P3
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A4, P2
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A5, P1
  sd     Z0,  0(a0)
.endm

.macro COMPUTE_R1
  ld     A_, 56(a1)
  _ACCU_OPERAND  Z1, Z2, Z0, A_
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A2, P5
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A3, P4
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A4, P3
  _ACCU_PRDCT_2  Z1, Z2, Z0, T0, A5, P2
  sd     Z1,  8(a0)
.endm

.macro COMPUTE_R2
  ld     A_, 64(a1)
  _ACCU_OPERAND  Z2, Z0, Z1, A_
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A3, P5
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A4, P4
  _ACCU_PRDCT_2  Z2, Z0, Z1, T0, A5, P3
  sd     Z2, 16(a0)
.endm

.macro COMPUTE_R3
  ld     A_, 72(a1)
  _ACCU_OPERAND  Z0, Z1, Z2, A_
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A4, P5
  _ACCU_PRDCT_2  Z0, Z1, Z2, T0, A5, P4
  sd     Z0, 24(a0)
.endm

.macro COMPUTE_R4
  ld     A_, 80(a1)
  cadd   Z2, Z1, A_, Z2
  add    Z1, Z1, A_
  maddhu T0, A5, P5, Z1
  maddlu Z1, A5, P5, Z1
  add    Z2, Z2, T0
  sd     Z1, 32(a0)
.endm

.macro COMPUTE_R5 
  ld     A_, 88(a1)
  add    Z2, Z2, A_ 
  sd     Z2, 40(a0)    
.endm


.section .text

.global _redc_mont_384_ise

_redc_mont_384_ise:
  PROLOGUE
  LOAD_A
  LOAD_P
  COMPUTE_A0
  COMPUTE_A1
  COMPUTE_A2
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  EPILOGUE
