// void gfp_mul_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


// registers

// accumulators for "r"
#define L0 a6
#define H0 a7
#define L1 s0
#define H1 s1
#define L2 s2
#define H2 s3
#define L3 s4
#define H3 s5
#define L4 s6
#define H4 s7
// operand "b" 
#define B0 t0 
#define B1 t1 
#define B2 t2 
#define B3 t3
#define B4 t4
// operand "a"
#define A_ t5 
// carry 
#define C_ t5
// temporary
#define TL t6
#define TH a3
// constants and masks
#define M0 a4
#define M1 a5


// prologue + epilogue 

.macro PROLOGUE 
  addi  sp, sp, -64
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
  li    M0, 19
  li    M1, 0x7FFFFFFFFFFFFULL
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
  addi  sp, sp, 64
  ret 
.endm

// load operand + store result 

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
  ld    B4, 32(a2)
.endm 

.macro STORE_R 
  sd    L0,  0(a0)
  sd    L1,  8(a0)
  sd    L2, 16(a0)
  sd    L3, 24(a0)
  sd    L4, 32(a0)
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0
  ld    A_,  0(a1)
  mul   L0, A_, B0
  mulhu H0, A_, B0
  mul   L1, A_, B1
  mulhu H1, A_, B1
  mul   L2, A_, B2
  mulhu H2, A_, B2
  mul   L3, A_, B3
  mulhu H3, A_, B3
  mul   L4, A_, B4
  mulhu H4, A_, B4
.endm

.macro MULTIPLY_A1
  ld    A_,  8(a1)
  mul   B4, B4, M0
  mul   TL, A_, B0
  mulhu TH, A_, B0
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
  mul   TL, A_, B1
  mulhu TH, A_, B1
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
  mul   TL, A_, B2
  mulhu TH, A_, B2
  add   L3, L3, TL
  sltu  TL, L3, TL
  add   H3, H3, TH
  add   H3, H3, TL
  mul   TL, A_, B3
  mulhu TH, A_, B3
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  mul   TL, A_, B4
  mulhu TH, A_, B4
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
.endm 

.macro MULTIPLY_A2
  ld    A_, 16(a1)
  mul   B3, B3, M0
  mul   TL, A_, B0
  mulhu TH, A_, B0
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
  mul   TL, A_, B1
  mulhu TH, A_, B1
  add   L3, L3, TL
  sltu  TL, L3, TL
  add   H3, H3, TH
  add   H3, H3, TL
  mul   TL, A_, B2
  mulhu TH, A_, B2
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  mul   TL, A_, B3
  mulhu TH, A_, B3
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
  mul   TL, A_, B4
  mulhu TH, A_, B4
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
.endm

.macro MULTIPLY_A3
  ld    A_, 24(a1)
  mul   B2, B2, M0
  mul   TL, A_, B0
  mulhu TH, A_, B0
  add   L3, L3, TL
  sltu  TL, L3, TL
  add   H3, H3, TH
  add   H3, H3, TL
  mul   TL, A_, B1
  mulhu TH, A_, B1
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  mul   TL, A_, B2
  mulhu TH, A_, B2
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
  mul   TL, A_, B3
  mulhu TH, A_, B3
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
  mul   TL, A_, B4
  mulhu TH, A_, B4
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
.endm

.macro MULTIPLY_A4
  ld    A_, 32(a1)
  mul   B1, B1, M0
  mul   TL, A_, B0
  mulhu TH, A_, B0
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  mul   TL, A_, B1
  mulhu TH, A_, B1
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
  mul   TL, A_, B2
  mulhu TH, A_, B2
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
  mul   TL, A_, B3
  mulhu TH, A_, B3
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
  mul   TL, A_, B4
  mulhu TH, A_, B4
  add   L3, L3, TL
  sltu  TL, L3, TL
  add   H3, H3, TH
  add   H3, H3, TL
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  srli  C_, L0, 51
  and   L0, L0, M1
  slli  H0, H0, 13
  xor   C_, C_, H0
  add   L1, L1, C_
  sltu  C_, L1, C_
  add   H1, H1, C_
  srli  C_, L1, 51
  and   L1, L1, M1
  slli  H1, H1, 13
  xor   C_, C_, H1
  add   L2, L2, C_
  sltu  C_, L2, C_
  add   H2, H2, C_
  srli  C_, L2, 51
  and   L2, L2, M1
  slli  H2, H2, 13
  xor   C_, C_, H2
  add   L3, L3, C_
  sltu  C_, L3, C_
  add   H3, H3, C_
  srli  C_, L3, 51
  and   L3, L3, M1
  slli  H3, H3, 13
  xor   C_, C_, H3
  add   L4, L4, C_
  sltu  C_, L4, C_
  add   H4, H4, C_
  srli  C_, L4, 51
  and   L4, L4, M1
  slli  H4, H4, 13
  xor   C_, C_, H4
  mul   C_, C_, M0 
  add   L0, L0, C_
  srli  C_, L0, 51 
  and   L0, L0, M1
  add   L1, L1, C_    
.endm 


.section .text

.global gfp_mul_isa

gfp_mul_isa:
  PROLOGUE
  LOAD_B
  MULTIPLY_A0
  MULTIPLY_A1
  MULTIPLY_A2 
  MULTIPLY_A3
  MULTIPLY_A4
  CARRY_PROPAGATION
  STORE_R 
  EPILOGUE 
