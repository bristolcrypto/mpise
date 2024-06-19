// void gfp_sqr_ise(uint64_t *r, const uint64_t *a);


#include "ise.h"


// registers

// result "r"
#define R0 a2 
#define R1 a3
#define R2 a4
#define R3 a5
#define R4 a6
#define R5 a7
// operand "a" 
#define A0 t0 
#define A1 t1 
#define A2 t2 
#define A3 t3
#define A4 t4
// constants and masks
#define M0 t6
#define M1 t5


// prologue + epilogue 

.macro PROLOGUE 
  li   M0, 19
  li   M1, 0x7FFFFFFFFFFFFULL
.endm

.macro EPILOGUE 
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
  sd    A0,  0(a0)
  sd    A1,  8(a0)
  sd    A2, 16(a0)
  sd    A3, 24(a0)
  sd    A4, 32(a0)
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
  madd51lu  R0, A0, A0, x0
  madd51hu  R1, A0, A0, x0
  add       A0, A0, A0
  madd51lu  R1, A0, A1, R1
  madd51hu  R2, A0, A1, x0
  madd51lu  R2, A0, A2, R2
  madd51hu  R3, A0, A2, x0
  madd51lu  R3, A0, A3, R3
  madd51hu  R4, A0, A3, x0
  madd51lu  R4, A0, A4, R4
  madd51hu  R5, A0, A4, x0 
.endm

.macro MULTIPLY_A1
  mul       A0, A4, M0
  madd51lu  R2, A1, A1, R2
  madd51hu  R3, A1, A1, R3
  add       A1, A1, A1
  madd51lu  R3, A1, A2, R3
  madd51hu  R4, A1, A2, R4
  madd51lu  R4, A1, A3, R4
  madd51hu  R5, A1, A3, R5
  madd51lu  R0, A1, A0, R0
  madd51hu  R1, A1, A0, R1  
.endm

.macro MULTIPLY_A2
  mul       A1, A3, M0
  madd51lu  R4, A2, A2, R4
  madd51hu  R5, A2, A2, R5
  add       A2, A2, A2 
  madd51lu  R0, A2, A1, R0
  madd51hu  R1, A2, A1, R1
  madd51lu  R1, A2, A0, R1
  madd51hu  R2, A2, A0, R2
.endm

.macro MULTIPLY_A3
  madd51lu  R1, A3, A1, R1
  madd51hu  R2, A3, A1, R2
  add       A3, A3, A3 
  madd51lu  R2, A3, A0, R2
  madd51hu  R3, A3, A0, R3
.endm

.macro MULTIPLY_A4
  madd51lu  R3, A4, A0, R3
  madd51hu  R4, A4, A0, R4
.endm

// carry propagation 

.macro CARRY_PROPAGATION
  mul       R5, R5, M0
  add       R0, R0, R5
  sraiadd   R1, R1, R0, 51
  and       A0, R0, M1
  sraiadd   R2, R2, R1, 51
  and       A1, R1, M1 
  sraiadd   R3, R3, R2, 51
  and       A2, R2, M1
  sraiadd   R4, R4, R3, 51
  and       A3, R3, M1 
  srl       R5, R4,     51
  and       A4, R4, M1
  madd51lu  A0, R5, M0, A0
.endm 


.section .text

.global gfp_sqr_ise

gfp_sqr_ise:
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
