// void _redc_mont_384_isa(vec384 ret, const vec768 a, const vec384 p, limb_t n0);


// registers

// accumulator `z`
#define Z0 t0
#define Z1 t1
// modulus `p`
#define P0 t3
#define P1 t4
#define P2 t5
#define P3 t6
#define P4 a7
#define P5 s0
#define P6 s1
// operand `a`
#define A0 s2
#define A1 s3
#define A2 s4
#define A3 s5
#define A4 s6
#define A5 s7
#define A6 s8
#define A_ t2
// temporary
#define T0 a4
#define T1 a5
// mask `m`
#define M_ a6
// Montgomery reduction constant `u = -p^-1 mod 2^55`
#define U_ a3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -72
  sd    s0,   0(sp)
  sd    s1,   8(sp)
  sd    s2,  16(sp)
  sd    s3,  24(sp)
  sd    s4,  32(sp)
  sd    s5,  40(sp)
  sd    s6,  48(sp)
  sd    s7,  56(sp)
  sd    s8,  64(sp)
  li    M_, 0x007fffffffffffff
.endm

.macro EPILOGUE
  ld    s0,   0(sp)
  ld    s1,   8(sp)
  ld    s2,  16(sp)
  ld    s3,  24(sp)
  ld    s4,  32(sp)
  ld    s5,  40(sp)
  ld    s6,  48(sp)
  ld    s7,  56(sp)
  ld    s8,  64(sp)
  addi  sp, sp, 72
  ret 
.endm

// load operand and modulus

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
.endm 

.macro LOAD_P
  ld    P0,  0(a2)
  ld    P1,  8(a2)
  ld    P2, 16(a2)
  ld    P3, 24(a2)
  ld    P4, 32(a2)
  ld    P5, 40(a2)
  ld    P6, 48(a2)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _ALIGN_ACMLTR
  srli  Z0, Z0, 55
  slli  T0, Z1,  9
  xor   Z0, Z0, T0
  srai  Z1, Z1, 55
.endm 

.macro _ACCU_PRODUCT
  add   Z0, Z0, T0
  sltu  T0, Z0, T0
  add   Z1, Z1, T1
  add   Z1, Z1, T0
.endm

.macro _ACCU_OPERAND A
  add   Z0, Z0, \A
  sltu  T0, Z0, \A
  add   Z1, Z1, T0
.endm

.macro COMPUTE_A0
  mv    Z0, A0 
  mul   A0, Z0, U_
  and   A0, A0, M_
  mul   T0, A0, P0
  mulhu T1, A0, P0
  add   Z0, Z0, T0
  sltu  T0, Z0, T0
  add   Z1, T0, T1
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A1
  _ACCU_OPERAND A1
  mul   T0, A0, P1
  mulhu T1, A0, P1
  _ACCU_PRODUCT
  mul   A1, Z0, U_
  and   A1, A1, M_
  mul   T0, A1, P0
  mulhu T1, A1, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A2
  _ACCU_OPERAND A2
  mul   T0, A0, P2
  mulhu T1, A0, P2
  _ACCU_PRODUCT
  mul   T0, A1, P1
  mulhu T1, A1, P1
  _ACCU_PRODUCT
  mul   A2, Z0, U_
  and   A2, A2, M_
  mul   T0, A2, P0
  mulhu T1, A2, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A3
  _ACCU_OPERAND A3
  mul   T0, A0, P3
  mulhu T1, A0, P3
  _ACCU_PRODUCT
  mul   T0, A1, P2
  mulhu T1, A1, P2
  _ACCU_PRODUCT
  mul   T0, A2, P1
  mulhu T1, A2, P1
  _ACCU_PRODUCT
  mul   A3, Z0, U_
  and   A3, A3, M_
  mul   T0, A3, P0
  mulhu T1, A3, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A4
  _ACCU_OPERAND A4
  mul   T0, A0, P4
  mulhu T1, A0, P4
  _ACCU_PRODUCT
  mul   T0, A1, P3
  mulhu T1, A1, P3
  _ACCU_PRODUCT
  mul   T0, A2, P2
  mulhu T1, A2, P2
  _ACCU_PRODUCT
  mul   T0, A3, P1
  mulhu T1, A3, P1
  _ACCU_PRODUCT
  mul   A4, Z0, U_
  and   A4, A4, M_
  mul   T0, A4, P0
  mulhu T1, A4, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A5
  _ACCU_OPERAND A5
  mul   T0, A0, P5
  mulhu T1, A0, P5
  _ACCU_PRODUCT
  mul   T0, A1, P4
  mulhu T1, A1, P4
  _ACCU_PRODUCT
  mul   T0, A2, P3
  mulhu T1, A2, P3
  _ACCU_PRODUCT
  mul   T0, A3, P2
  mulhu T1, A3, P2
  _ACCU_PRODUCT
  mul   T0, A4, P1
  mulhu T1, A4, P1
  _ACCU_PRODUCT
  mul   A5, Z0, U_
  and   A5, A5, M_
  mul   T0, A5, P0
  mulhu T1, A5, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

.macro COMPUTE_A6
  _ACCU_OPERAND A6
  mul   T0, A0, P6
  mulhu T1, A0, P6
  _ACCU_PRODUCT
  mul   T0, A1, P5
  mulhu T1, A1, P5
  _ACCU_PRODUCT
  mul   T0, A2, P4
  mulhu T1, A2, P4
  _ACCU_PRODUCT
  mul   T0, A3, P3
  mulhu T1, A3, P3
  _ACCU_PRODUCT
  mul   T0, A4, P2
  mulhu T1, A4, P2
  _ACCU_PRODUCT
  mul   T0, A5, P1
  mulhu T1, A5, P1
  _ACCU_PRODUCT
  mul   A6, Z0, U_
  and   A6, A6, M_
  mul   T0, A6, P0
  mulhu T1, A6, P0
  _ACCU_PRODUCT
  _ALIGN_ACMLTR
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0 
  ld    A_, 56(a1)
  _ACCU_OPERAND A_
  mul   T0, A1, P6
  mulhu T1, A1, P6
  _ACCU_PRODUCT
  mul   T0, A2, P5
  mulhu T1, A2, P5
  _ACCU_PRODUCT
  mul   T0, A3, P4
  mulhu T1, A3, P4
  _ACCU_PRODUCT
  mul   T0, A4, P3
  mulhu T1, A4, P3
  _ACCU_PRODUCT
  mul   T0, A5, P2
  mulhu T1, A5, P2
  _ACCU_PRODUCT
  mul   T0, A6, P1
  mulhu T1, A6, P1
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_,  0(a0)
.endm

.macro COMPUTE_R1
  ld    A_, 64(a1)
  _ACCU_OPERAND A_
  mul   T0, A2, P6
  mulhu T1, A2, P6
  _ACCU_PRODUCT
  mul   T0, A3, P5
  mulhu T1, A3, P5
  _ACCU_PRODUCT
  mul   T0, A4, P4
  mulhu T1, A4, P4
  _ACCU_PRODUCT
  mul   T0, A5, P3
  mulhu T1, A5, P3
  _ACCU_PRODUCT
  mul   T0, A6, P2
  mulhu T1, A6, P2
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_,  8(a0)
.endm

.macro COMPUTE_R2
  ld    A_, 72(a1)
  _ACCU_OPERAND A_
  mul   T0, A3, P6
  mulhu T1, A3, P6
  _ACCU_PRODUCT
  mul   T0, A4, P5
  mulhu T1, A4, P5
  _ACCU_PRODUCT
  mul   T0, A5, P4
  mulhu T1, A5, P4
  _ACCU_PRODUCT
  mul   T0, A6, P3
  mulhu T1, A6, P3
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 16(a0)
.endm

.macro COMPUTE_R3
  ld    A_, 80(a1)
  _ACCU_OPERAND A_
  mul   T0, A4, P6
  mulhu T1, A4, P6
  _ACCU_PRODUCT
  mul   T0, A5, P5
  mulhu T1, A5, P5
  _ACCU_PRODUCT
  mul   T0, A6, P4
  mulhu T1, A6, P4
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 24(a0)
.endm

.macro COMPUTE_R4
  ld    A_, 88(a1)
  _ACCU_OPERAND A_
  mul   T0, A5, P6
  mulhu T1, A5, P6
  _ACCU_PRODUCT
  mul   T0, A6, P5
  mulhu T1, A6, P5
  _ACCU_PRODUCT
  and   A_, Z0, M_
  _ALIGN_ACMLTR
  sd    A_, 32(a0)
.endm

.macro COMPUTE_R5
  ld    A_, 96(a1)
  _ACCU_OPERAND A_
  mul   T0, A6, P6
  mulhu T1, A6, P6
  _ACCU_PRODUCT
  and   A_, Z0, M_
  srli  Z0, Z0, 55
  slli  T0, Z1,  9
  xor   Z0, Z0, T0
  sd    A_, 40(a0)
.endm

.macro COMPUTE_R6
  ld    A_,104(a1)
  add   Z0, Z0, A_
  and   A_, Z0, M_
  sd    A_, 48(a0)
.endm


.section .text

.global _redc_mont_384_isa

_redc_mont_384_isa:
  PROLOGUE
  LOAD_A
  LOAD_P
  COMPUTE_A0
  COMPUTE_A1
  COMPUTE_A2
  COMPUTE_A3
  COMPUTE_A4
  COMPUTE_A5
  COMPUTE_A6
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  EPILOGUE
