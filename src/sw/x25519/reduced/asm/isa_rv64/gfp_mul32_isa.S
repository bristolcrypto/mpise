// void gfp_mul51_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


// registers

// accumulators for "r"
#define L0 t0
#define H0 t1
#define L1 t2
#define H1 t3
#define L2 t4
#define H2 t5
#define L3 t6
#define H3 a3
#define L4 a4
#define H4 a5
// operand "a" 
#define A_ a6 
// carry 
#define C_ a6
// operand "b"
#define B0 a2 
// constants and masks
#define M0 a2
#define M1 a7


// prologue + epilogue 

.macro PROLOGUE 
.endm

.macro EPILOGUE 
  ret 
.endm

// store result 

.macro STORE_R 
  sd    L0,  0(a0)
  sd    L1,  8(a0)
  sd    L2, 16(a0)
  sd    L3, 24(a0)
  sd    L4, 32(a0)
.endm

// multiplication 

.macro MULTIPLY_B0
  ld    A_,  0(a1)
  mul   L0, A_, B0
  mulhu H0, A_, B0
  ld    A_,  8(a1)
  mul   L1, A_, B0
  mulhu H1, A_, B0
  ld    A_, 16(a1)
  mul   L2, A_, B0
  mulhu H2, A_, B0
  ld    A_, 24(a1)
  mul   L3, A_, B0
  mulhu H3, A_, B0
  ld    A_, 32(a1)
  mul   L4, A_, B0
  mulhu H4, A_, B0
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  li    M0, 19
  li    M1, 0x7FFFFFFFFFFFFULL
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

.global gfp_mul32_isa

gfp_mul32_isa:
  PROLOGUE
  MULTIPLY_B0
  CARRY_PROPAGATION
  STORE_R 
  EPILOGUE 
