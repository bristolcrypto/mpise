// void gfp_mul51_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


#include "ise.h"


// registers

// result "r"
#define R0 t0 
#define R1 t1
#define R2 t2
#define R3 t3
#define R4 t4
#define R5 t5
// operand "a" 
#define A_ a3 
// operand "b"
#define B0 a2
// constants and masks
#define M0 a4
#define M1 a5


// prologue + epilogue 

.macro PROLOGUE 
  li   M0, 19
  li   M1, 0x7FFFFFFFFFFFFULL
.endm

.macro EPILOGUE 
  ret 
.endm

// store result 

.macro STORE_R 
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
  sd    R4, 32(a0)
.endm

// multiplication

.macro MULTIPLY_B0
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
  ld        A_,  8(a1)
  madd51lu  R1, A_, B0, R1
  madd51hu  R2, A_, B0, x0
  ld        A_, 16(a1)
  madd51lu  R2, A_, B0, R2
  madd51hu  R3, A_, B0, x0
  ld        A_, 24(a1)
  madd51lu  R3, A_, B0, R3
  madd51hu  R4, A_, B0, x0
  ld        A_, 32(a1)
  madd51lu  R4, A_, B0, R4
  madd51hu  R5, A_, B0, x0
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  madd51lu  R0, R5, M0, R0
  sraiadd   R1, R1, R0, 51
  and       R0, R0, M1
.endm 


.section .text

.global gfp_mul51_ise

gfp_mul51_ise:
  PROLOGUE
  MULTIPLY_B0
  CARRY_PROPAGATION
  STORE_R 
  EPILOGUE 
