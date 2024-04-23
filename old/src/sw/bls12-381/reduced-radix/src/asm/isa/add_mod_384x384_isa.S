// void add_mod_384x384_isa(vec768 ret, const vec768 a, const vec768 b, const vec384 p);


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

.macro STORE_R_LOW
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
  srai  R0, R6, 55
  and   R6, R6, M_
  sd    R6, 48(a0)
.endm

.macro STORE_R_HIGH
  sd    R0, 56(a0)
  sd    R1, 64(a0)
  sd    R2, 72(a0)
  sd    R3, 80(a0)
  sd    R4, 88(a0)
  sd    R5, 96(a0)
  sd    R6,104(a0)
.endm

// arithmetic computation

.macro _A_ADD_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  add   \R, A_, B_
.endm

.macro A_ADD_B_LOW 
  _A_ADD_B_I R0, 0
  _A_ADD_B_I R1, 1
  _A_ADD_B_I R2, 2
  _A_ADD_B_I R3, 3
  _A_ADD_B_I R4, 4
  _A_ADD_B_I R5, 5
  _A_ADD_B_I R6, 6
.endm

.macro _A_ADD_B_7
  ld    A_, 56(a1)
  ld    B_, 56(a2) 
  add   R0, R0, A_
  add   R0, R0, B_ 
.endm

.macro A_ADD_B_HIGH
  _A_ADD_B_7
  _A_ADD_B_I R1, 8
  _A_ADD_B_I R2, 9
  _A_ADD_B_I R3, 10
  _A_ADD_B_I R4, 11
  _A_ADD_B_I R5, 12
  _A_ADD_B_I R6, 13
.endm

.macro R_SUB_P
  sub   R0, R0, P0
  sub   R1, R1, P1
  sub   R2, R2, P2
  sub   R3, R3, P3
  sub   R4, R4, P4
  sub   R5, R5, P5
  sub   R6, R6, P6
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
  srai  T_, R0, 55
  add   T_, T_, R1
  srai  T_, T_, 55
  add   T_, T_, R2
  srai  T_, T_, 55
  add   T_, T_, R3
  srai  T_, T_, 55
  add   T_, T_, R4
  srai  T_, T_, 55
  add   T_, T_, R5
  srai  T_, T_, 55
  add   T_, T_, R6
  srai  T_, T_, 63
.endm

.macro _PROPAGATE_CARRY A, B 
  srai  T_, \A, 55
  add   \B, \B, T_
  and   \A, \A, M_
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

.global add_mod_384x384_isa 

add_mod_384x384_isa:
  PROLOGUE
  LOAD_P
  A_ADD_B_LOW
  CARRY_PROPAGATION
  STORE_R_LOW
  A_ADD_B_HIGH
  R_SUB_P
  GET_SIGN
  MASK_P
  ADD_MASK
  CARRY_PROPAGATION
  STORE_R_HIGH
  EPILOGUE
