// void sub_mod_384_isa(vec384 ret, const vec384 a, const vec384 b, const vec384 p);


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

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
  sd    R5, 40(a0)
.endm

// arithmetic computation

.macro _A_SUB_B_I R, imm
  ld    A_, 8*\imm(a1)
  ld    B_, 8*\imm(a2)
  sltu  T1, A_, T0 
  sub   \R, A_, T0
  sltu  T0, \R, B_
  sub   \R, \R, B_
  or    T0, T0, T1
.endm

.macro _A_SUB_B_0 
  ld    A_,  0(a1)
  ld    B_,  0(a2)
  sltu  T0, A_, B_
  sub   R0, A_, B_
.endm

.macro A_SUB_B
  _A_SUB_B_0
  _A_SUB_B_I R1, 1
  _A_SUB_B_I R2, 2
  _A_SUB_B_I R3, 3
  _A_SUB_B_I R4, 4
  _A_SUB_B_I R5, 5
.endm

.macro MASK_P
  sub   T0, x0, T0
  and   P0, P0, T0
  and   P1, P1, T0
  and   P2, P2, T0
  and   P3, P3, T0
  and   P4, P4, T0
  and   P5, P5, T0
.endm

.macro _R_ADD_P R, P
  add   \R, \R, T0 
  sltu  T0, \R, T0 
  add   \R, \R, \P
  sltu  T1, \R, \P
  or    T0, T0, T1
.endm

.macro ADD_MASK 
  add   R0, R0, P0
  sltu  T0, R0, P0
  _R_ADD_P  R1, P1 
  _R_ADD_P  R2, P2
  _R_ADD_P  R3, P3
  _R_ADD_P  R4, P4
  add   R5, R5, T0 
  add   R5, R5, P5
.endm


.section .text

.global sub_mod_384_isa

sub_mod_384_isa:
  PROLOGUE
  LOAD_P
  A_SUB_B
  MASK_P
  ADD_MASK
  STORE_R
  EPILOGUE