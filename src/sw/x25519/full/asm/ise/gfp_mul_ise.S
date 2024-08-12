// void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


#include "ise_al.h"


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
#define T1 t4
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
.macro _ACCU_AIBJ_0 L, M, H, T, A, B
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     \M, \L
#endif 
  maddhu \M, \A, \B, \L
  maddlu \L, \A, \B, \L
.endm

// L != 0, M != 0, H = 0
.macro _ACCU_AIBJ_1 L, M, H, T, A, B 
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     \T, \L
#endif 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  add    \M, \M, \T
  sltu   \H, \M, \T
.endm

// L != 0, M != 0, H != 0
.macro _ACCU_AIBJ_2 L, M, H, T, A, B 
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     \T, \L
#endif 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  cacc   \H, \M, \T
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  cacc   \H, \M, \T, \H
#endif
  add    \M, \M, \T
.endm

.macro COMPUTE_R0
  mul    R0, A0, B0
  mulhu  R1, A0, B0
.endm

.macro COMPUTE_R1 
  _ACCU_AIBJ_0   R1, R2, R3, T0, A0, B1 
  _ACCU_AIBJ_1   R1, R2, R3, T0, A1, B0 
.endm

.macro COMPUTE_R2 
  _ACCU_AIBJ_1   R2, R3, R4, T0, A0, B2 
  _ACCU_AIBJ_2   R2, R3, R4, T0, A1, B1 
  _ACCU_AIBJ_2   R2, R3, R4, T0, A2, B0 
.endm

.macro COMPUTE_R3
  _ACCU_AIBJ_1   R3, R4, R5, T0, A0, B3 
  _ACCU_AIBJ_2   R3, R4, R5, T0, A1, B2 
  _ACCU_AIBJ_2   R3, R4, R5, T0, A2, B1 
  _ACCU_AIBJ_2   R3, R4, R5, T0, A3, B0 
.endm

.macro COMPUTE_R4 
  _ACCU_AIBJ_1   R4, R5, R6, T0, A1, B3
  _ACCU_AIBJ_2   R4, R5, R6, T0, A2, B2
  _ACCU_AIBJ_2   R4, R5, R6, T0, A3, B1
.endm

.macro COMPUTE_R5 
  _ACCU_AIBJ_1   R5, R6, R7, T0, A2, B3
  _ACCU_AIBJ_2   R5, R6, R7, T0, A3, B2
.endm

.macro COMPUTE_R6 
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T0, R6
#endif 
  maddhu T0, A3, B3, R6 
  maddlu R6, A3, B3, R6
.endm

.macro COMPUTE_R7 
  add    R7, R7, T0
.endm

// reduction R0-R4 = R0-R3 + 38*(R4-R7)

.macro REDUCTION
  li     M0, 38
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T0, R0
#endif  
  maddhu T0, R4, M0, R0
  maddlu R0, R4, M0, R0
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T1, T0
#endif
  maddhu T1, R5, M0, T0
  maddlu T0, R5, M0, T0
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  cacc   T1, R1, T0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  cacc   T1, R1, T0, T1
#endif
  add    R1, R1, T0
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T0, T1
#endif
  maddhu T0, R6, M0, T1
  maddlu T1, R6, M0, T1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  cacc   T0, R2, T1
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  cacc   T0, R2, T1, T0
#endif  
  add    R2, R2, T1
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T1, T0
#endif
  maddhu T1, R7, M0, T0
  maddlu T0, R7, M0, T0
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     R4, T1
  cacc   R4, R3, T0
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  mv     R4, T1
  cacc   R4, R3, T0, T1
#endif
  add    R3, R3, T0
.endm

// final reduction 

.macro FINAL_REDC
  srli   T0, R3, 63
  slli   T1, R4, 1
  or     R4, T0, T1 
  slli   R3, R3, 1
  srli   R3, R3, 1
  li     M0, 19
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     T0, R0
#endif
  maddhu T0, R4, M0, R0
  maddlu R0, R4, M0, R0
  add    R1, R1, T0 
  sltu   T0, R1, T0
  add    R2, R2, T0 
  sltu   T0, R2, T0
  add    R3, R3, T0 
  sltu   T0, R3, T0
.endm


.section .text

.global gfp_mul_ise

gfp_mul_ise:
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
