// void add_mod_384x384_isa(vec768 ret, const vec768 a, const vec768 b, const vec384 p);

// registers 

// result `r`
#define R0 a7
#define R1 s0
#define R2 s1
#define R3 s2
#define R4 s3
#define R5 s4
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
// temporary
#define T0 t2
#define T1 t3
#define T2 t0


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -40
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  addi  sp, sp, 40
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
.endm

.macro STORE_R_LOW
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
.endm

.macro STORE_R_HIGH
  sd    P0, 48(a0)
  sd    P1, 56(a0)
  sd    P2, 64(a0)
  sd    P3, 72(a0)
  sd    P4, 80(a0)
  sd    P5, 88(a0)
.endm

// arithmetic computation

.macro _A_ADD_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2) 
  add   \R, A_, B_
  sltu  T1, \R, A_
  add   \R, \R, T0
  sltu  T0, \R, T0
  or    T0, T0, T1 
.endm

.macro _A_ADD_B_0
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  add   R0, A_, B_
  sltu  T0, R0, A_
.endm

.macro _A_ADD_B_11
  ld    A_, 88(a1)
  ld    B_, 88(a2)
  add   R5, A_, B_
  add   R5, R5, T0 
.endm

.macro A_ADD_B_LOW
  _A_ADD_B_0
  _A_ADD_B_I R1, 1
  _A_ADD_B_I R2, 2
  _A_ADD_B_I R3, 3
  _A_ADD_B_I R4, 4
  _A_ADD_B_I R5, 5
.endm

.macro A_ADD_B_HIGH
  _A_ADD_B_I R0, 6
  _A_ADD_B_I R1, 7
  _A_ADD_B_I R2, 8
  _A_ADD_B_I R3, 9
  _A_ADD_B_I R4, 10
  _A_ADD_B_11
.endm

.macro _R_SUB_P R, P
  sltu  T1, \R, \P
  sub   \P, \R, \P
  sltu  T2, \P, T0 
  sub   \P, \P, T0
  or    T0, T1, T2
.endm

.macro R_SUB_P 
  sltu  T0, R0, P0 
  sub   P0, R0, P0
  _R_SUB_P  R1, P1
  _R_SUB_P  R2, P2
  _R_SUB_P  R3, P3
  _R_SUB_P  R4, P4
  _R_SUB_P  R5, P5
.endm

.macro _CSWAP R, P
  xor   \R, \R, \P
  and   \R, \R, T0
  xor   \P, \P, \R
.endm

.macro CSWAP
  sub   T0, x0, T0
  _CSWAP    R0, P0
  _CSWAP    R1, P1
  _CSWAP    R2, P2
  _CSWAP    R3, P3
  _CSWAP    R4, P4
  _CSWAP    R5, P5
.endm

.section .text

.global add_mod_384x384_isa 

add_mod_384x384_isa:
  PROLOGUE
  LOAD_P
  A_ADD_B_LOW
  STORE_R_LOW
  A_ADD_B_HIGH
  R_SUB_P
  CSWAP 
  STORE_R_HIGH
  EPILOGUE
