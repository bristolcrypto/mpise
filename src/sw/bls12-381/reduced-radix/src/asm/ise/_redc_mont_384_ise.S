// void _redc_mont_384_ise(vec384 ret, const vec768 a, const vec384 p, limb_t n0);


#include "ise.h"


// registers 

// accumulator `z`
#define Z0 t0
#define Z1 t1
// modulus `p`
#define P0 t2
#define P1 t3
#define P2 t4
#define P3 t5
#define P4 t6
#define P5 a4
#define P6 a5
// operand `a`
#define A0 a7
#define A1 s0
#define A2 s1
#define A3 s2
#define A4 s3
#define A5 s4
#define A6 s5
// mask `m`
#define M_ a6
// Montgomery reduction constant `u = -p^-1 mod 2^55`
#define U_ a3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,   0(sp)
  sd    s1,   8(sp)
  sd    s2,  16(sp)
  sd    s3,  24(sp)
  sd    s4,  32(sp)
  sd    s5,  40(sp)
  li    M_, 0x007fffffffffffff
.endm

.macro EPILOGUE
  ld    s0,   0(sp)
  ld    s1,   8(sp)
  ld    s2,  16(sp)
  ld    s3,  24(sp)
  ld    s4,  32(sp)
  ld    s5,  40(sp)
  addi  sp, sp, 48
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

.macro _PROPAGATE_CARRY A, B 
  sraiadd  \B, \B, \A, 55
  and      \A, \A, M_
.endm

.macro COMPUTE_A0
  mv       Z0, A0
  madd55lu A0, Z0, U_, x0
  madd55lu Z0, A0, P0, Z0 
  madd55hu Z1, A0, P0, A1
  sraiadd  Z1, Z1, Z0, 55
.endm

.macro COMPUTE_A1 
  madd55lu Z1, A0, P1, Z1
  madd55hu Z0, A0, P1, A2
  madd55lu A1, Z1, U_, x0
  madd55lu Z1, A1, P0, Z1
  madd55hu Z0, A1, P0, Z0
  sraiadd  Z0, Z0, Z1, 55
.endm

.macro COMPUTE_A2
  madd55lu Z0, A0, P2, Z0
  madd55hu Z1, A0, P2, A3
  madd55lu Z0, A1, P1, Z0
  madd55hu Z1, A1, P1, Z1
  madd55lu A2, Z0, U_, x0
  madd55lu Z0, A2, P0, Z0
  madd55hu Z1, A2, P0, Z1
  sraiadd  Z1, Z1, Z0, 55
.endm

.macro COMPUTE_A3
  madd55lu Z1, A0, P3, Z1
  madd55hu Z0, A0, P3, A4
  madd55lu Z1, A1, P2, Z1
  madd55hu Z0, A1, P2, Z0
  madd55lu Z1, A2, P1, Z1
  madd55hu Z0, A2, P1, Z0
  madd55lu A3, Z1, U_, x0
  madd55lu Z1, A3, P0, Z1
  madd55hu Z0, A3, P0, Z0
  sraiadd  Z0, Z0, Z1, 55
.endm

.macro COMPUTE_A4
  madd55lu Z0, A0, P4, Z0
  madd55hu Z1, A0, P4, A5
  madd55lu Z0, A1, P3, Z0
  madd55hu Z1, A1, P3, Z1
  madd55lu Z0, A2, P2, Z0
  madd55hu Z1, A2, P2, Z1
  madd55lu Z0, A3, P1, Z0
  madd55hu Z1, A3, P1, Z1
  madd55lu A4, Z0, U_, x0
  madd55lu Z0, A4, P0, Z0
  madd55hu Z1, A4, P0, Z1
  sraiadd  Z1, Z1, Z0, 55
.endm

.macro COMPUTE_A5
  madd55lu Z1, A0, P5, Z1
  madd55hu Z0, A0, P5, A6
  madd55lu Z1, A1, P4, Z1
  madd55hu Z0, A1, P4, Z0
  madd55lu Z1, A2, P3, Z1
  madd55hu Z0, A2, P3, Z0
  madd55lu Z1, A3, P2, Z1
  madd55hu Z0, A3, P2, Z0
  madd55lu Z1, A4, P1, Z1
  madd55hu Z0, A4, P1, Z0
  madd55lu A5, Z1, U_, x0
  madd55lu Z1, A5, P0, Z1
  madd55hu Z0, A5, P0, Z0
  sraiadd  Z0, Z0, Z1, 55
.endm

.macro COMPUTE_A6
  ld       Z1, 56(a1)
  madd55lu Z0, A0, P6, Z0
  madd55hu Z1, A0, P6, Z1
  madd55lu Z0, A1, P5, Z0
  madd55hu Z1, A1, P5, Z1
  madd55lu Z0, A2, P4, Z0
  madd55hu Z1, A2, P4, Z1
  madd55lu Z0, A3, P3, Z0
  madd55hu Z1, A3, P3, Z1
  madd55lu Z0, A4, P2, Z0
  madd55hu Z1, A4, P2, Z1
  madd55lu Z0, A5, P1, Z0
  madd55hu Z1, A5, P1, Z1
  madd55lu A6, Z0, U_, x0
  madd55lu Z0, A6, P0, Z0
  madd55hu Z1, A6, P0, Z1
  sraiadd  Z1, Z1, Z0, 55
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  ld       Z0, 64(a1)
  madd55lu Z1, A1, P6, Z1
  madd55hu Z0, A1, P6, Z0
  madd55lu Z1, A2, P5, Z1
  madd55hu Z0, A2, P5, Z0
  madd55lu Z1, A3, P4, Z1
  madd55hu Z0, A3, P4, Z0
  madd55lu Z1, A4, P3, Z1
  madd55hu Z0, A4, P3, Z0
  madd55lu Z1, A5, P2, Z1
  madd55hu Z0, A5, P2, Z0
  madd55lu Z1, A6, P1, Z1
  madd55hu Z0, A6, P1, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1,  0(a0)
.endm

.macro COMPUTE_R1
  ld       Z1, 72(a1)
  madd55lu Z0, A2, P6, Z0
  madd55hu Z1, A2, P6, Z1
  madd55lu Z0, A3, P5, Z0
  madd55hu Z1, A3, P5, Z1
  madd55lu Z0, A4, P4, Z0
  madd55hu Z1, A4, P4, Z1
  madd55lu Z0, A5, P3, Z0
  madd55hu Z1, A5, P3, Z1
  madd55lu Z0, A6, P2, Z0
  madd55hu Z1, A6, P2, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0,  8(a0)
.endm

.macro COMPUTE_R2
  ld       Z0, 80(a1)
  madd55lu Z1, A3, P6, Z1
  madd55hu Z0, A3, P6, Z0
  madd55lu Z1, A4, P5, Z1
  madd55hu Z0, A4, P5, Z0
  madd55lu Z1, A5, P4, Z1
  madd55hu Z0, A5, P4, Z0
  madd55lu Z1, A6, P3, Z1
  madd55hu Z0, A6, P3, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1, 16(a0)
.endm

.macro COMPUTE_R3
  ld       Z1, 88(a1)
  madd55lu Z0, A4, P6, Z0
  madd55hu Z1, A4, P6, Z1
  madd55lu Z0, A5, P5, Z0
  madd55hu Z1, A5, P5, Z1
  madd55lu Z0, A6, P4, Z0
  madd55hu Z1, A6, P4, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0, 24(a0)
.endm

.macro COMPUTE_R4
  ld       Z0, 96(a1)
  madd55lu Z1, A5, P6, Z1
  madd55hu Z0, A5, P6, Z0
  madd55lu Z1, A6, P5, Z1
  madd55hu Z0, A6, P5, Z0
  _PROPAGATE_CARRY Z1, Z0
  sd       Z1, 32(a0)
.endm

.macro COMPUTE_R5
  ld       Z1,104(a1)
  madd55lu Z0, A6, P6, Z0
  madd55hu Z1, A6, P6, Z1
  _PROPAGATE_CARRY Z0, Z1
  sd       Z0, 40(a0)
.endm

.macro COMPUTE_R6
  sd       Z1, 48(a0)
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
  COMPUTE_A6
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  EPILOGUE
