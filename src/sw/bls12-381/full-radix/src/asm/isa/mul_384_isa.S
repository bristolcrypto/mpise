// void mul_384_isa(vec768 ret, const vec384 a, const vec384 b);


// registers

// accumulator `z`
#define Z0 a1
#define Z1 a2
#define Z2 a3
// operand `b`
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
// operand `a`
#define A0 t6
#define A1 a6
#define A2 a7 
#define A3 s0
#define A4 s1
#define A5 s2
// temporary 
#define T0 a4
#define T1 a5


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

// load operand

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
.endm 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
  ld    B4, 32(a2)
  ld    B5, 40(a2)
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
  mul   Z0, A0, B0
  mulhu Z1, A0, B0
  sd    Z0,  0(a0)
.endm

.macro COMPUTE_R1
  mul   T0, A0, B1
  mulhu T1, A0, B1
  _ACCU_AIBJ_0  Z1, Z2, Z0
  mul   T0, A1, B0
  mulhu T1, A1, B0
  _ACCU_AIBJ_1  Z1, Z2, Z0
  sd    Z1,  8(a0)
.endm

.macro COMPUTE_R2
  mul   T0, A0, B2
  mulhu T1, A0, B2
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A1, B1
  mulhu T1, A1, B1
  _ACCU_AIBJ_2  Z2, Z0, Z1 
  mul   T0, A2, B0
  mulhu T1, A2, B0
  _ACCU_AIBJ_2  Z2, Z0, Z1
  sd    Z2, 16(a0) 
.endm

.macro COMPUTE_R3
  mul   T0, A0, B3
  mulhu T1, A0, B3
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A1, B2
  mulhu T1, A1, B2
  _ACCU_AIBJ_2  Z0, Z1, Z2 
  mul   T0, A2, B1
  mulhu T1, A2, B1
  _ACCU_AIBJ_2  Z0, Z1, Z2
  mul   T0, A3, B0
  mulhu T1, A3, B0
  _ACCU_AIBJ_2  Z0, Z1, Z2
  sd    Z0, 24(a0) 
.endm

.macro COMPUTE_R4
  mul   T0, A0, B4
  mulhu T1, A0, B4
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A1, B3
  mulhu T1, A1, B3
  _ACCU_AIBJ_2  Z1, Z2, Z0 
  mul   T0, A2, B2
  mulhu T1, A2, B2
  _ACCU_AIBJ_2  Z1, Z2, Z0
  mul   T0, A3, B1
  mulhu T1, A3, B1
  _ACCU_AIBJ_2  Z1, Z2, Z0
  mul   T0, A4, B0
  mulhu T1, A4, B0
  _ACCU_AIBJ_2  Z1, Z2, Z0
  sd    Z1, 32(a0)   
.endm

.macro COMPUTE_R5
  mul   T0, A0, B5
  mulhu T1, A0, B5
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A1, B4
  mulhu T1, A1, B4
  _ACCU_AIBJ_2  Z2, Z0, Z1 
  mul   T0, A2, B3
  mulhu T1, A2, B3
  _ACCU_AIBJ_2  Z2, Z0, Z1
  mul   T0, A3, B2
  mulhu T1, A3, B2
  _ACCU_AIBJ_2  Z2, Z0, Z1
  mul   T0, A4, B1
  mulhu T1, A4, B1
  _ACCU_AIBJ_2  Z2, Z0, Z1
  mul   T0, A5, B0
  mulhu T1, A5, B0
  _ACCU_AIBJ_2  Z2, Z0, Z1
  sd    Z2, 40(a0)   
.endm

.macro COMPUTE_R6
  mul   T0, A1, B5
  mulhu T1, A1, B5
  _ACCU_AIBJ_1  Z0, Z1, Z2 
  mul   T0, A2, B4
  mulhu T1, A2, B4
  _ACCU_AIBJ_2  Z0, Z1, Z2
  mul   T0, A3, B3
  mulhu T1, A3, B3
  _ACCU_AIBJ_2  Z0, Z1, Z2
  mul   T0, A4, B2
  mulhu T1, A4, B2
  _ACCU_AIBJ_2  Z0, Z1, Z2
  mul   T0, A5, B1
  mulhu T1, A5, B1
  _ACCU_AIBJ_2  Z0, Z1, Z2
  sd    Z0, 48(a0)   
.endm

.macro COMPUTE_R7
  mul   T0, A2, B5
  mulhu T1, A2, B5
  _ACCU_AIBJ_1  Z1, Z2, Z0
  mul   T0, A3, B4
  mulhu T1, A3, B4
  _ACCU_AIBJ_2  Z1, Z2, Z0
  mul   T0, A4, B3
  mulhu T1, A4, B3
  _ACCU_AIBJ_2  Z1, Z2, Z0
  mul   T0, A5, B2
  mulhu T1, A5, B2
  _ACCU_AIBJ_2  Z1, Z2, Z0
  sd    Z1, 56(a0)   
.endm

.macro COMPUTE_R8
  mul   T0, A3, B5
  mulhu T1, A3, B5
  _ACCU_AIBJ_1  Z2, Z0, Z1
  mul   T0, A4, B4
  mulhu T1, A4, B4
  _ACCU_AIBJ_2  Z2, Z0, Z1
  mul   T0, A5, B3
  mulhu T1, A5, B3
  _ACCU_AIBJ_2  Z2, Z0, Z1
  sd    Z2, 64(a0)
.endm

.macro COMPUTE_R9
  mul   T0, A4, B5
  mulhu T1, A4, B5
  _ACCU_AIBJ_1  Z0, Z1, Z2
  mul   T0, A5, B4
  mulhu T1, A5, B4
  _ACCU_AIBJ_2  Z0, Z1, Z2
  sd    Z0, 72(a0)
.endm

.macro COMPUTE_R10
  mul   T0, A5, B5
  mulhu T1, A5, B5
  add   Z1, Z1, T0
  sltu  T0, Z1, T0
  add   T1, T1, T0
  add   Z2, Z2, T1
  sd    Z1, 80(a0)
.endm

.macro COMPUTE_R11
  sd    Z2, 88(a0) 
.endm


.section .text

.global mul_384_isa

mul_384_isa:
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
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  EPILOGUE
