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
