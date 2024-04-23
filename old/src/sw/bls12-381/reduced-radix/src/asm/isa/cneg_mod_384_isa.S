// void cneg_mod_384_isa(vec384 ret, const vec384 a, bool_t flag, const vec384 p);


// registers 

// result `r`
#define R0 t4
#define R1 t5
#define R2 t6
#define R3 a4
#define R4 a5
#define R5 a6
#define R6 a7
// operand `a`
#define A0 t0
#define A1 s0
#define A2 s1
#define A3 s2
#define A4 s3
#define A5 s4
#define A6 s5
// modulus `p`
#define P_ t1
// temporary
#define T_ t2
// mask `m`
#define M_ t3


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -48
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  li    M_, 0x007fffffffffffff
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  ld    s4, 32(sp)
  ld    s5, 40(sp)
  addi  sp, sp, 48
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
  ld    A6, 48(a1)
.endm

// arithmetic computation

.macro _P_SUB_A_I R, A, imm
  ld    P_, 8*\imm(a3) 
  sub   \R, P_, \A
.endm

.macro P_SUB_A 
  _P_SUB_A_I R0, A0, 0
  _P_SUB_A_I R1, A1, 1
  _P_SUB_A_I R2, A2, 2
  _P_SUB_A_I R3, A3, 3
  _P_SUB_A_I R4, A4, 4
  _P_SUB_A_I R5, A5, 5
  _P_SUB_A_I R6, A6, 6
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

.macro GET_SIGN
  andi  M_, a2, 1
  sub   M_, x0, M_
.endm

.macro _CSWAP R, A, imm
  xor   \R, \R, \A
  and   \R, \R, M_ 
  xor   \R, \R, \A
  sd    \R, 8*\imm(a0) 
.endm

.macro CSWAP 
  _CSWAP R0, A0, 0
  _CSWAP R1, A1, 1
  _CSWAP R2, A2, 2
  _CSWAP R3, A3, 3
  _CSWAP R4, A4, 4
  _CSWAP R5, A5, 5
  _CSWAP R6, A6, 6
.endm


.section .text

.global cneg_mod_384_isa

cneg_mod_384_isa:
  PROLOGUE
  LOAD_A
  P_SUB_A
  CARRY_PROPAGATION
  GET_SIGN
  CSWAP
  EPILOGUE
