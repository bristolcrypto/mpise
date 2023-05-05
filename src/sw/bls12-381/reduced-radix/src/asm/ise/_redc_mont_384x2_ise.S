// void _redc_mont_384x2_ise(vec384x ret, const vec768x a, const vec384 p, limb_t n0);


#include "ise.h"


// registers 

// accumulator `z` and `y`
#define Z0 t0
#define Z1 t1
#define Y0 t2
#define Y1 t3
// modulus `p`
#define P0 t4
#define P1 t5
#define P2 t6
#define P3 a4
#define P4 a5
#define P5 a6
#define P6 a7
// operand `a`
#define A0 s0
#define A1 s1
#define A2 s2
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 s6
// operand `b`
#define B0 s7
#define B1 s8
#define B2 s9
#define B3 s10
#define B4 s11
#define B5 a2
#define B6 s7
// mask `m`
#define M_ s0
// Montgomery reduction constant `u = -p^-1 mod 2^55`
#define U_ a3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -96
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
  addi  sp, sp, 96
  ret
.endm

// load operand and modulus

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
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
  ld    A5, 40(a1)
  ld    A6, 48(a1)
.endm 

.macro LOAD_B
  ld    B0, 112(a1)
  ld    B1, 120(a1)
  ld    B2, 128(a1)
  ld    B3, 136(a1)
  ld    B4, 144(a1)
  ld    B5, 152(a1)
.endm

// first loop of Montgomery reduction (based on product-scanning)

.macro _PROPAGATE_CARRY A, B 
  sraiadd  \B, \B, \A, 55
  and      \A, \A, M_
.endm

.macro COMPUTE_A0
  mv       Z0, A0
  mv       Y0, B0
  madd55lu A0, Z0, U_, x0
  madd55lu B0, Y0, U_, x0
  madd55lu Z0, A0, P0, Z0
  madd55hu Z1, A0, P0, A1
  madd55lu Y0, B0, P0, Y0 
  madd55hu Y1, B0, P0, B1
  sraiadd  Z1, Z1, Z0, 55
  sraiadd  Y1, Y1, Y0, 55
.endm

.macro COMPUTE_A1 
  madd55lu Z1, A0, P1, Z1
  madd55hu Z0, A0, P1, A2
  madd55lu Y1, B0, P1, Y1
  madd55hu Y0, B0, P1, B2  
  madd55lu A1, Z1, U_, x0
  madd55lu B1, Y1, U_, x0
  madd55lu Z1, A1, P0, Z1
  madd55hu Z0, A1, P0, Z0
  madd55lu Y1, B1, P0, Y1
  madd55hu Y0, B1, P0, Y0
  sraiadd  Z0, Z0, Z1, 55
  sraiadd  Y0, Y0, Y1, 55
.endm

.macro COMPUTE_A2
  madd55lu Z0, A0, P2, Z0
  madd55hu Z1, A0, P2, A3
  madd55lu Y0, B0, P2, Y0
  madd55hu Y1, B0, P2, B3
  madd55lu Z0, A1, P1, Z0
  madd55hu Z1, A1, P1, Z1
  madd55lu Y0, B1, P1, Y0
  madd55hu Y1, B1, P1, Y1
  madd55lu A2, Z0, U_, x0
  madd55lu B2, Y0, U_, x0
  madd55lu Z0, A2, P0, Z0
  madd55hu Z1, A2, P0, Z1
  madd55lu Y0, B2, P0, Y0
  madd55hu Y1, B2, P0, Y1
  sraiadd  Z1, Z1, Z0, 55
  sraiadd  Y1, Y1, Y0, 55
.endm

.macro COMPUTE_A3
  madd55lu Z1, A0, P3, Z1
  madd55hu Z0, A0, P3, A4
  madd55lu Y1, B0, P3, Y1
  madd55hu Y0, B0, P3, B4
  madd55lu Z1, A1, P2, Z1
  madd55hu Z0, A1, P2, Z0
  madd55lu Y1, B1, P2, Y1
  madd55hu Y0, B1, P2, Y0
  madd55lu Z1, A2, P1, Z1
  madd55hu Z0, A2, P1, Z0
  madd55lu Y1, B2, P1, Y1
  madd55hu Y0, B2, P1, Y0
  madd55lu A3, Z1, U_, x0
  madd55lu B3, Y1, U_, x0
  madd55lu Z1, A3, P0, Z1
  madd55hu Z0, A3, P0, Z0
  madd55lu Y1, B3, P0, Y1
  madd55hu Y0, B3, P0, Y0
  sraiadd  Z0, Z0, Z1, 55
  sraiadd  Y0, Y0, Y1, 55
.endm

.macro COMPUTE_A4
  madd55lu Z0, A0, P4, Z0
  madd55hu Z1, A0, P4, A5
  madd55lu Y0, B0, P4, Y0
  madd55hu Y1, B0, P4, B5
  madd55lu Z0, A1, P3, Z0
  madd55hu Z1, A1, P3, Z1
  madd55lu Y0, B1, P3, Y0
  madd55hu Y1, B1, P3, Y1
  madd55lu Z0, A2, P2, Z0
  madd55hu Z1, A2, P2, Z1
  madd55lu Y0, B2, P2, Y0
  madd55hu Y1, B2, P2, Y1
  madd55lu Z0, A3, P1, Z0
  madd55hu Z1, A3, P1, Z1
  madd55lu Y0, B3, P1, Y0
  madd55hu Y1, B3, P1, Y1
  madd55lu A4, Z0, U_, x0
  madd55lu B4, Y0, U_, x0
  madd55lu Z0, A4, P0, Z0
  madd55hu Z1, A4, P0, Z1
  madd55lu Y0, B4, P0, Y0
  madd55hu Y1, B4, P0, Y1
  sraiadd  Z1, Z1, Z0, 55
  sraiadd  Y1, Y1, Y0, 55
.endm

.macro COMPUTE_A5
  ld       Y0,160(a1)  
  madd55lu Z1, A0, P5, Z1
  madd55hu Z0, A0, P5, A6
  madd55lu Y1, B0, P5, Y1
  madd55hu Y0, B0, P5, Y0
  madd55lu Z1, A1, P4, Z1
  madd55hu Z0, A1, P4, Z0
  madd55lu Y1, B1, P4, Y1
  madd55hu Y0, B1, P4, Y0
  madd55lu Z1, A2, P3, Z1
  madd55hu Z0, A2, P3, Z0
  madd55lu Y1, B2, P3, Y1
  madd55hu Y0, B2, P3, Y0
  madd55lu Z1, A3, P2, Z1
  madd55hu Z0, A3, P2, Z0
  madd55lu Y1, B3, P2, Y1
  madd55hu Y0, B3, P2, Y0
  madd55lu Z1, A4, P1, Z1
  madd55hu Z0, A4, P1, Z0
  madd55lu Y1, B4, P1, Y1
  madd55hu Y0, B4, P1, Y0
  madd55lu A5, Z1, U_, x0
  madd55lu B5, Y1, U_, x0
  madd55lu Z1, A5, P0, Z1
  madd55hu Z0, A5, P0, Z0
  madd55lu Y1, B5, P0, Y1
  madd55hu Y0, B5, P0, Y0
  sraiadd  Z0, Z0, Z1, 55
  sraiadd  Y0, Y0, Y1, 55
.endm

.macro COMPUTE_A6
  ld       Z1, 56(a1)
  ld       Y1,168(a1)
  madd55lu Z0, A0, P6, Z0
  madd55hu Z1, A0, P6, Z1
  madd55lu Y0, B0, P6, Y0
  madd55hu Y1, B0, P6, Y1
  madd55lu Z0, A1, P5, Z0
  madd55hu Z1, A1, P5, Z1
  madd55lu Y0, B1, P5, Y0
  madd55hu Y1, B1, P5, Y1
  madd55lu Z0, A2, P4, Z0
  madd55hu Z1, A2, P4, Z1
  madd55lu Y0, B2, P4, Y0
  madd55hu Y1, B2, P4, Y1
  madd55lu Z0, A3, P3, Z0
  madd55hu Z1, A3, P3, Z1
  madd55lu Y0, B3, P3, Y0
  madd55hu Y1, B3, P3, Y1
  madd55lu Z0, A4, P2, Z0
  madd55hu Z1, A4, P2, Z1
  madd55lu Y0, B4, P2, Y0
  madd55hu Y1, B4, P2, Y1
  madd55lu Z0, A5, P1, Z0
  madd55hu Z1, A5, P1, Z1
  madd55lu Y0, B5, P1, Y0
  madd55hu Y1, B5, P1, Y1
  madd55lu A6, Z0, U_, x0
  madd55lu B6, Y0, U_, x0
  madd55lu Z0, A6, P0, Z0
  madd55hu Z1, A6, P0, Z1
  madd55lu Y0, B6, P0, Y0
  madd55hu Y1, B6, P0, Y1
  sraiadd  Z1, Z1, Z0, 55
  sraiadd  Y1, Y1, Y0, 55
.endm

// second loop of Montgomery reduction (based on product-scanning) 

.macro COMPUTE_R0
  li       M_, 0x007fffffffffffff
  ld       Z0, 64(a1)
  ld       Y0,176(a1)
  madd55lu Z1, A1, P6, Z1
  madd55hu Z0, A1, P6, Z0
  madd55lu Y1, B1, P6, Y1
  madd55hu Y0, B1, P6, Y0
  madd55lu Z1, A2, P5, Z1
  madd55hu Z0, A2, P5, Z0
  madd55lu Y1, B2, P5, Y1
  madd55hu Y0, B2, P5, Y0
  madd55lu Z1, A3, P4, Z1
  madd55hu Z0, A3, P4, Z0
  madd55lu Y1, B3, P4, Y1
  madd55hu Y0, B3, P4, Y0
  madd55lu Z1, A4, P3, Z1
  madd55hu Z0, A4, P3, Z0
  madd55lu Y1, B4, P3, Y1
  madd55hu Y0, B4, P3, Y0
  madd55lu Z1, A5, P2, Z1
  madd55hu Z0, A5, P2, Z0
  madd55lu Y1, B5, P2, Y1
  madd55hu Y0, B5, P2, Y0
  madd55lu Z1, A6, P1, Z1
  madd55hu Z0, A6, P1, Z0
  madd55lu Y1, B6, P1, Y1
  madd55hu Y0, B6, P1, Y0
  _PROPAGATE_CARRY Z1, Z0
  _PROPAGATE_CARRY Y1, Y0
  sd       Z1,  0(a0)
  sd       Y1, 56(a0)
.endm

.macro COMPUTE_R1
  ld       Z1, 72(a1)
  ld       Y1,184(a1)
  madd55lu Z0, A2, P6, Z0
  madd55hu Z1, A2, P6, Z1
  madd55lu Y0, B2, P6, Y0
  madd55hu Y1, B2, P6, Y1
  madd55lu Z0, A3, P5, Z0
  madd55hu Z1, A3, P5, Z1
  madd55lu Y0, B3, P5, Y0
  madd55hu Y1, B3, P5, Y1
  madd55lu Z0, A4, P4, Z0
  madd55hu Z1, A4, P4, Z1
  madd55lu Y0, B4, P4, Y0
  madd55hu Y1, B4, P4, Y1
  madd55lu Z0, A5, P3, Z0
  madd55hu Z1, A5, P3, Z1
  madd55lu Y0, B5, P3, Y0
  madd55hu Y1, B5, P3, Y1
  madd55lu Z0, A6, P2, Z0
  madd55hu Z1, A6, P2, Z1
  madd55lu Y0, B6, P2, Y0
  madd55hu Y1, B6, P2, Y1
  _PROPAGATE_CARRY Z0, Z1
  _PROPAGATE_CARRY Y0, Y1
  sd       Z0,  8(a0)
  sd       Y0, 64(a0)
.endm

.macro COMPUTE_R2
  ld       Z0, 80(a1)
  ld       Y0,192(a1)
  madd55lu Z1, A3, P6, Z1
  madd55hu Z0, A3, P6, Z0
  madd55lu Y1, B3, P6, Y1
  madd55hu Y0, B3, P6, Y0
  madd55lu Z1, A4, P5, Z1
  madd55hu Z0, A4, P5, Z0
  madd55lu Y1, B4, P5, Y1
  madd55hu Y0, B4, P5, Y0
  madd55lu Z1, A5, P4, Z1
  madd55hu Z0, A5, P4, Z0
  madd55lu Y1, B5, P4, Y1
  madd55hu Y0, B5, P4, Y0
  madd55lu Z1, A6, P3, Z1
  madd55hu Z0, A6, P3, Z0
  madd55lu Y1, B6, P3, Y1
  madd55hu Y0, B6, P3, Y0
  _PROPAGATE_CARRY Z1, Z0
  _PROPAGATE_CARRY Y1, Y0
  sd       Z1, 16(a0)
  sd       Y1, 72(a0)
.endm

.macro COMPUTE_R3
  ld       Z1, 88(a1)
  ld       Y1,200(a1)
  madd55lu Z0, A4, P6, Z0
  madd55hu Z1, A4, P6, Z1
  madd55lu Y0, B4, P6, Y0
  madd55hu Y1, B4, P6, Y1
  madd55lu Z0, A5, P5, Z0
  madd55hu Z1, A5, P5, Z1
  madd55lu Y0, B5, P5, Y0
  madd55hu Y1, B5, P5, Y1
  madd55lu Z0, A6, P4, Z0
  madd55hu Z1, A6, P4, Z1
  madd55lu Y0, B6, P4, Y0
  madd55hu Y1, B6, P4, Y1
  _PROPAGATE_CARRY Z0, Z1
  _PROPAGATE_CARRY Y0, Y1
  sd       Z0, 24(a0)
  sd       Y0, 80(a0)
.endm

.macro COMPUTE_R4
  ld       Z0, 96(a1)
  ld       Y0,208(a1)
  madd55lu Z1, A5, P6, Z1
  madd55hu Z0, A5, P6, Z0
  madd55lu Y1, B5, P6, Y1
  madd55hu Y0, B5, P6, Y0
  madd55lu Z1, A6, P5, Z1
  madd55hu Z0, A6, P5, Z0
  madd55lu Y1, B6, P5, Y1
  madd55hu Y0, B6, P5, Y0
  _PROPAGATE_CARRY Z1, Z0
  _PROPAGATE_CARRY Y1, Y0
  sd       Z1, 32(a0)
  sd       Y1, 88(a0)
.endm

.macro COMPUTE_R5
  ld       Z1,104(a1)
  ld       Y1,216(a1)
  madd55lu Z0, A6, P6, Z0
  madd55hu Z1, A6, P6, Z1
  madd55lu Y0, B6, P6, Y0
  madd55hu Y1, B6, P6, Y1
  _PROPAGATE_CARRY Z0, Z1
  _PROPAGATE_CARRY Y0, Y1
  sd       Z0, 40(a0)
  sd       Y0, 96(a0)
.endm

.macro COMPUTE_R6
  sd       Z1, 48(a0)
  sd       Y1,104(a0)
.endm


.section .text

.global _redc_mont_384x2_ise

_redc_mont_384x2_ise:
  PROLOGUE
  LOAD_P
  LOAD_A
  LOAD_B
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
