// void mul_384_aixb_ise(vec768 ret0, vec768 ret1, const vec384 a, const vec384x b)


#include "ise.h"


// registers 

// accumulator `z` and `y`
#define Z0 a2
#define Z1 a3
#define Z2 a4
#define Y0 a5
#define Y1 a6
#define Y2 a7
// operand `b`
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
// operand `a`
#define A0 t6
#define A1 s0
#define A2 s1
#define A3 s2
#define A4 s3
#define A5 s4
// operand `c`
#define C0 s5
#define C1 s6
#define C2 s7
#define C3 s8
#define C4 s9
#define C5 s10
// temporary
#define T0 s11
#define T1 ra


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -104
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
  sd    s8, 64(sp)
  sd    s9, 72(sp)
  sd    s10,80(sp)
  sd    s11,88(sp)
  sd    ra, 96(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  ld    s6, 48(sp)
  ld    s7, 56(sp)
  ld    s8, 64(sp)
  ld    s9, 72(sp)
  ld    s10,80(sp)
  ld    s11,88(sp)
  ld    ra, 96(sp)
  addi  sp, sp, 104
  ret 
.endm

// load operand

.macro LOAD_A
  ld    A0,  0(a2)
  ld    A1,  8(a2)
  ld    A2, 16(a2)
  ld    A3, 24(a2)
  ld    A4, 32(a2)
  ld    A5, 40(a2)
.endm 

.macro LOAD_B
  ld    B0,  0(a3)
  ld    B1,  8(a3)
  ld    B2, 16(a3)
  ld    B3, 24(a3)
  ld    B4, 32(a3)
  ld    B5, 40(a3)
.endm

.macro LOAD_C
  ld    C0, 48(a3)
  ld    C1, 56(a3)
  ld    C2, 64(a3)
  ld    C3, 72(a3)
  ld    C4, 80(a3)
  ld    C5, 88(a3)
.endm

// integer multiplication (based on product-scanning)

// L != 0, M = 0, H = 0
.macro _ACCU_AIBJ_0 L, M, H, T, A, B, C, U, V, W, S
  maddhu \M, \A, \B, \L
  maddlu \L, \A, \B, \L
  maddhu \V, \A, \C, \U
  maddlu \U, \A, \C, \U
.endm

// L != 0, M != 0, H = 0
.macro _ACCU_AIBJ_1 L, M, H, T, A, B, C, U, V, W, S
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  maddhu \S, \A, \C, \U
  maddlu \U, \A, \C, \U
  add    \M, \M, \T
  sltu   \H, \M, \T
  add    \V, \V, \S
  sltu   \W, \V, \S
.endm

// L != 0, M != 0, H != 0
.macro _ACCU_AIBJ_2 L, M, H, T, A, B, C, U, V, W, S 
  maddhu \T, \A, \B, \L
  maddlu \L, \A, \B, \L
  maddhu \S, \A, \C, \U
  maddlu \U, \A, \C, \U
  cadd   \H, \M, \T, \H
  add    \M, \M, \T
  cadd   \W, \V, \S, \W
  add    \V, \V, \S
.endm

.macro COMPUTE_R0
  maddlu Z0, A0, B0, x0
  maddhu Z1, A0, B0, x0
  maddlu Y0, A0, C0, x0
  maddhu Y1, A0, C0, x0
  sd     Z0,  0(a0)
  sd     Y0,  0(a1)
.endm

.macro COMPUTE_R1
  _ACCU_AIBJ_0  Z1, Z2, Z0, T0, A0, B1, C1, Y1, Y2, Y0, T1
  _ACCU_AIBJ_1  Z1, Z2, Z0, T0, A1, B0, C0, Y1, Y2, Y0, T1
  sd     Z1,  8(a0)
  sd     Y1,  8(a1)
.endm

.macro COMPUTE_R2
  _ACCU_AIBJ_1  Z2, Z0, Z1, T0, A0, B2, C2, Y2, Y0, Y1, T1
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A1, B1, C1, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A2, B0, C0, Y2, Y0, Y1, T1  
  sd     Z2, 16(a0) 
  sd     Y2, 16(a1) 
.endm

.macro COMPUTE_R3
  _ACCU_AIBJ_1  Z0, Z1, Z2, T0, A0, B3, C3, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A1, B2, C2, Y0, Y1, Y2, T1  
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A2, B1, C1, Y0, Y1, Y2, T1  
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A3, B0, C0, Y0, Y1, Y2, T1   
  sd     Z0, 24(a0)
  sd     Y0, 24(a1) 
.endm

.macro COMPUTE_R4
  _ACCU_AIBJ_1  Z1, Z2, Z0, T0, A0, B4, C4, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A1, B3, C3, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A2, B2, C2, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A3, B1, C1, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A4, B0, C0, Y1, Y2, Y0, T1 
  sd     Z1, 32(a0)
  sd     Y1, 32(a1)
.endm

.macro COMPUTE_R5
  _ACCU_AIBJ_1  Z2, Z0, Z1, T0, A0, B5, C5, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A1, B4, C4, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A2, B3, C3, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A3, B2, C2, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A4, B1, C1, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A5, B0, C0, Y2, Y0, Y1, T1 
  sd     Z2, 40(a0)
  sd     Y2, 40(a1)
.endm

.macro COMPUTE_R6
  _ACCU_AIBJ_1  Z0, Z1, Z2, T0, A1, B5, C5, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A2, B4, C4, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A3, B3, C3, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A4, B2, C2, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A5, B1, C1, Y0, Y1, Y2, T1 
  sd     Z0, 48(a0)
  sd     Y0, 48(a1)  
.endm

.macro COMPUTE_R7
  _ACCU_AIBJ_1  Z1, Z2, Z0, T0, A2, B5, C5, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A3, B4, C4, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A4, B3, C3, Y1, Y2, Y0, T1 
  _ACCU_AIBJ_2  Z1, Z2, Z0, T0, A5, B2, C2, Y1, Y2, Y0, T1 
  sd     Z1, 56(a0)
  sd     Y1, 56(a1) 
.endm

.macro COMPUTE_R8
  _ACCU_AIBJ_1  Z2, Z0, Z1, T0, A3, B5, C5, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A4, B4, C4, Y2, Y0, Y1, T1 
  _ACCU_AIBJ_2  Z2, Z0, Z1, T0, A5, B3, C3, Y2, Y0, Y1, T1 
  sd     Z2, 64(a0)
  sd     Y2, 64(a1)
.endm

.macro COMPUTE_R9
  _ACCU_AIBJ_1  Z0, Z1, Z2, T0, A4, B5, C5, Y0, Y1, Y2, T1 
  _ACCU_AIBJ_2  Z0, Z1, Z2, T0, A5, B4, C4, Y0, Y1, Y2, T1 
  sd     Z0, 72(a0)
  sd     Y0, 72(a1)
.endm

.macro COMPUTE_R10
  maddhu T0, A5, B5, Z1 
  maddlu Z1, A5, B5, Z1
  maddhu T1, A5, C5, Y1 
  maddlu Y1, A5, C5, Y1
  sd     Z1, 80(a0)
  sd     Y1, 80(a1)
.endm

.macro COMPUTE_R11
  add    Z2, Z2, T0
  add    Y2, Y2, T1
  sd     Z2, 88(a0)
  sd     Y2, 88(a1)
.endm


.section .text

.global mul_384_aixb_ise

mul_384_aixb_ise:
  PROLOGUE
  LOAD_A
  LOAD_B
  LOAD_C
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  EPILOGUE
