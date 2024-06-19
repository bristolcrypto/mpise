// void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


#include "ise.h"


// registers

// result "r"
#define R0 a3 
#define R1 a4
#define R2 a5
#define R3 a6
#define R4 a7
#define R5 s0
// operand "b" 
#define B0 t0 
#define B1 t1 
#define B2 t2 
#define B3 t3
#define B4 t4
// operand "a"
#define A_ t5 
// constants and masks
#define M0 t6
#define M1 t5


// prologue + epilogue 

.macro PROLOGUE 
  addi  sp, sp, -8
  sd    s0,  0(sp)
  li    M0, 19
.endm

.macro EPILOGUE 
  ld    s0,  0(sp)
  addi  sp, sp, 8
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
  sd    B0,  0(a0)
  sd    B1,  8(a0)
  sd    B2, 16(a0)
  sd    B3, 24(a0)
  sd    B4, 32(a0)
.endm

// interleaved multiplication and reduction (based on operand-scanning)

.macro MULTIPLY_A0
#if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  xor       R0, R0, R0
  xor       R1, R1, R1
  xor       R2, R2, R2
  xor       R3, R3, R3
  xor       R4, R4, R4
  xor       R5, R5, R5
#endif
  ld        A_,  0(a1)
  madd51lu  R0, A_, B0, x0
  madd51hu  R1, A_, B0, x0
  madd51lu  R1, A_, B1, R1
  madd51hu  R2, A_, B1, x0
  madd51lu  R2, A_, B2, R2
  madd51hu  R3, A_, B2, x0
  madd51lu  R3, A_, B3, R3
  madd51hu  R4, A_, B3, x0
  madd51lu  R4, A_, B4, R4
  madd51hu  R5, A_, B4, x0 
.endm

.macro MULTIPLY_A1
  ld        A_,  8(a1)
  mul       B4, B4, M0
  madd51lu  R1, A_, B0, R1
  madd51hu  R2, A_, B0, R2
  madd51lu  R2, A_, B1, R2
  madd51hu  R3, A_, B1, R3
  madd51lu  R3, A_, B2, R3
  madd51hu  R4, A_, B2, R4
  madd51lu  R4, A_, B3, R4
  madd51hu  R5, A_, B3, R5
  madd51lu  R0, A_, B4, R0
  madd51hu  R1, A_, B4, R1
.endm 

.macro MULTIPLY_A2
  ld        A_, 16(a1)
  mul       B3, B3, M0
  madd51lu  R2, A_, B0, R2
  madd51hu  R3, A_, B0, R3
  madd51lu  R3, A_, B1, R3
  madd51hu  R4, A_, B1, R4
  madd51lu  R4, A_, B2, R4
  madd51hu  R5, A_, B2, R5
  madd51lu  R0, A_, B3, R0
  madd51hu  R1, A_, B3, R1
  madd51lu  R1, A_, B4, R1
  madd51hu  R2, A_, B4, R2
.endm

.macro MULTIPLY_A3
  ld        A_, 24(a1)
  mul       B2, B2, M0
  madd51lu  R3, A_, B0, R3
  madd51hu  R4, A_, B0, R4
  madd51lu  R4, A_, B1, R4
  madd51hu  R5, A_, B1, R5
  madd51lu  R0, A_, B2, R0
  madd51hu  R1, A_, B2, R1
  madd51lu  R1, A_, B3, R1
  madd51hu  R2, A_, B3, R2
  madd51lu  R2, A_, B4, R2
  madd51hu  R3, A_, B4, R3
.endm

.macro MULTIPLY_A4
  ld        A_, 32(a1)
  mul       B1, B1, M0
  madd51lu  R4, A_, B0, R4
  madd51hu  R5, A_, B0, R5
  madd51lu  R0, A_, B1, R0
  madd51hu  R1, A_, B1, R1
  madd51lu  R1, A_, B2, R1
  madd51hu  R2, A_, B2, R2
  madd51lu  R2, A_, B3, R2
  madd51hu  R3, A_, B3, R3
  madd51lu  R3, A_, B4, R3
  madd51hu  R4, A_, B4, R4
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  li        M1, 0x7FFFFFFFFFFFFULL
  mul       R5, R5, M0
  add       R0, R0, R5
  sraiadd   R1, R1, R0, 51
  and       B0, R0, M1
  sraiadd   R2, R2, R1, 51
  and       B1, R1, M1 
  sraiadd   R3, R3, R2, 51
  and       B2, R2, M1
  sraiadd   R4, R4, R3, 51
  and       B3, R3, M1
  srl       R5, R4,     51
  and       B4, R4, M1
  madd51lu  B0, R5, M0, B0
.endm 


.section .text

.global gfp_mul_ise

gfp_mul_ise:
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
