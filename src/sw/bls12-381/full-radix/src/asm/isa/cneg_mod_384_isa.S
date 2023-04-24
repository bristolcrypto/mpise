// void cneg_mod_384_isa(vec384 ret, const vec384 a, bool_t flag, const vec384 p)


// registers 

// result `r`
#define R_ t4
// operand `a`
#define A_ t0
// modulus `p`
#define P_ t1
// mask 
#define M_ a2
// temporary 
#define T0 t2
#define T1 t3


// prologue + epilogue 

.macro PROLOGUE
.endm

.macro EPILOGUE
 ret
.endm

// arithmetic computation 

.macro _P_SUB_A_I imm 
  ld    P_,  8*\imm(a3)
  ld    A_,  8*\imm(a1)
  sltu  T1, P_, T0 
  sub   R_, P_, T0
  sltu  T0, R_, A_
  sub   R_, R_, A_
  or    T0, T0, T1
.endm

.macro _P_SUB_A_0 
  ld    P_,  0(a3)
  ld    A_,  0(a1)
  sltu  T0, P_, A_
  sub   R_, P_, A_
.endm

.macro _P_SUB_A_5 imm 
  ld    P_,  40(a3)
  ld    A_,  40(a1)
  sub   R_, P_, T0
  sub   R_, R_, A_
.endm

.macro _CSWAP imm
  xor   R_, R_, A_
  and   R_, R_, M_ 
  xor   R_, R_, A_
  sd    R_, 8*\imm(a0) 
.endm

.macro CNEG
  andi  M_, M_, 1
  sub   M_, x0, M_
  _P_SUB_A_0
  _CSWAP 0
  _P_SUB_A_I 1
  _CSWAP 1
  _P_SUB_A_I 2
  _CSWAP 2
  _P_SUB_A_I 3
  _CSWAP 3
  _P_SUB_A_I 4
  _CSWAP 4
  _P_SUB_A_5
  _CSWAP 5
.endm

.section .text

.global cneg_mod_384_isa

cneg_mod_384_isa:
  PROLOGUE
  CNEG
  EPILOGUE
