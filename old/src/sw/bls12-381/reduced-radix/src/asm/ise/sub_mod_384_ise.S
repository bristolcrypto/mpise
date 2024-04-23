// void sub_mod_384_ise(vec384 ret, const vec384 a, const vec384 b, const vec384 p);


#include "ise.h"


// registers 

// result `r`
#define R0 s0
#define R1 s1
#define R2 s2
#define R3 s3
#define R4 s4
#define R5 s5
#define R6 s6
// operand `a`
#define A_ t0
// operand `b`
#define B_ t1
// modulus `p`
#define P0 t4
#define P1 t5
#define P2 t6
#define P3 a4
#define P4 a5
#define P5 a6
#define P6 a7
// temporary
#define T_ t2
// mask `m`
#define M_ t3


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
  li    M_, 0x007fffffffffffff
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

// load modulus + store result

.macro LOAD_P
  ld    P0,  0(a3)
  ld    P1,  8(a3)
  ld    P2, 16(a3)
  ld    P3, 24(a3)
  ld    P4, 32(a3)
  ld    P5, 40(a3)
  ld    P6, 48(a3)
.endm

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  sd    R6, 48(a0)
.endm

// arithmetic computation

.macro _A_SUB_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  sub   \R, A_, B_
.endm

.macro A_SUB_B 
  _A_SUB_B_I R0, 0
  _A_SUB_B_I R1, 1
  _A_SUB_B_I R2, 2
  _A_SUB_B_I R3, 3
  _A_SUB_B_I R4, 4
  _A_SUB_B_I R5, 5
  _A_SUB_B_I R6, 6
.endm

.macro MASK_P
  and   P0, P0, T_
  and   P1, P1, T_
  and   P2, P2, T_
  and   P3, P3, T_
  and   P4, P4, T_
  and   P5, P5, T_
  and   P6, P6, T_
.endm

.macro ADD_MASK 
  add   R0, R0, P0
  add   R1, R1, P1
  add   R2, R2, P2
  add   R3, R3, P3
  add   R4, R4, P4
  add   R5, R5, P5
  add   R6, R6, P6
.endm

// carry propagation

.macro GET_SIGN 
  sraiadd T_, R1, R0, 55
  sraiadd T_, R2, T_, 55
  sraiadd T_, R3, T_, 55
  sraiadd T_, R4, T_, 55
  sraiadd T_, R5, T_, 55
  sraiadd T_, R6, T_, 55
  srai    T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  sraiadd \B, \B, \A, 55
  and     \A, \A, M_
.endm

.macro CARRY_PROPAGATION 
  _PROPAGATE_CARRY R0, R1
  _PROPAGATE_CARRY R1, R2
  _PROPAGATE_CARRY R2, R3
  _PROPAGATE_CARRY R3, R4
  _PROPAGATE_CARRY R4, R5
  _PROPAGATE_CARRY R5, R6
.endm


.section .text

.global sub_mod_384_ise

sub_mod_384_ise:
  PROLOGUE
  A_SUB_B
  LOAD_P
  GET_SIGN
  MASK_P
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R
  EPILOGUE
