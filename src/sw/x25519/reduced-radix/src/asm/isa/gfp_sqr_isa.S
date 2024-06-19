// void gfp_sqr_isa(uint64_t *r, const uint64_t *a);


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
// operand "a" 
#define A0 t0 
#define A1 t1 
#define A2 t2 
#define A3 t3
#define A4 t4
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

.macro LOAD_A
  ld    A0,  0(a1)
  ld    A1,  8(a1)
  ld    A2, 16(a1)
  ld    A3, 24(a1)
  ld    A4, 32(a1)
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
  mul   L0, A0, A0
  mulhu H0, A0, A0
  add   A0, A0, A0
  mul   L1, A0, A1
  mulhu H1, A0, A1
  mul   L2, A0, A2
  mulhu H2, A0, A2
  mul   L3, A0, A3
  mulhu H3, A0, A3
  mul   L4, A0, A4
  mulhu H4, A0, A4
.endm

.macro MULTIPLY_A1
  mul   A0, A4, M0
  mul   TL, A1, A1
  mulhu TH, A1, A1
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
  add   A1, A1, A1 
  mul   TL, A1, A2
  mulhu TH, A1, A2
  add   L3, L3, TL
  sltu  TL, L3, TL
  add   H3, H3, TH
  add   H3, H3, TL
  mul   TL, A1, A3
  mulhu TH, A1, A3
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  mul   TL, A1, A0
  mulhu TH, A1, A0
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
.endm 

.macro MULTIPLY_A2
  mul   A1, A3, M0
  mul   TL, A2, A2
  mulhu TH, A2, A2
  add   L4, L4, TL
  sltu  TL, L4, TL
  add   H4, H4, TH
  add   H4, H4, TL
  add   A2, A2, A2 
  mul   TL, A2, A1
  mulhu TH, A2, A1
  add   L0, L0, TL
  sltu  TL, L0, TL
  add   H0, H0, TH
  add   H0, H0, TL
  mul   TL, A2, A0
  mulhu TH, A2, A0
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
.endm

.macro MULTIPLY_A3
  mul   TL, A3, A1
  mulhu TH, A3, A1
  add   L1, L1, TL
  sltu  TL, L1, TL
  add   H1, H1, TH
  add   H1, H1, TL
  add   A3, A3, A3
  mul   TL, A3, A0
  mulhu TH, A3, A0
  add   L2, L2, TL
  sltu  TL, L2, TL
  add   H2, H2, TH
  add   H2, H2, TL
.endm

.macro MULTIPLY_A4
  mul   TL, A4, A0
  mulhu TH, A4, A0
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


// field squaring

.section .text

.global gfp_sqr_isa

gfp_sqr_isa:
  PROLOGUE
  LOAD_A
  MULTIPLY_A0
  MULTIPLY_A1
  MULTIPLY_A2 
  MULTIPLY_A3
  MULTIPLY_A4
  CARRY_PROPAGATION
  STORE_R 
  EPILOGUE 
