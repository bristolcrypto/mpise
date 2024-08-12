// void gfp_mul64_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


#include "ise_al.h"


// registers 

// result `r`
#define R0 a3
#define R1 a4
#define R2 a5
#define R3 a6
#define R4 a7
// operand `b`
#define B0 a2 
// operand `a`
#define A0 t0 
#define A1 t1
#define A2 t2 
#define A3 t3
// temporary
#define T0 t4
#define T1 t5
// constants 
#define M0 t6


// prologue + epilogue 

.macro PROLOGUE
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
.endm 

.macro STORE_R
  sd    R0,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// multiplication 

.macro MULTIPLY_B0 
  mul    T1, A0, B0
  mulhu  T0, A0, B0
#if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     R1, T0
#endif
  maddlu R1, A1, B0, T0
  maddhu T0, A1, B0, T0
#if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     R2, T0
#endif
  maddlu R2, A2, B0, T0
  maddhu T0, A2, B0, T0
#if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     R3, T0
  mv     R4, T0
#endif
  maddlu R3, A3, B0, T0
  maddhu R4, A3, B0, T0
.endm

// final reduction 

.macro FINAL_REDC
  srli   T0, R3, 63
  slli   R4, R4, 1
  or     R4, R4, T0 
  slli   R3, R3, 1
  srli   R3, R3, 1
  li     M0, 19
#if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  mv     R0, T1
#endif
  maddlu R0, R4, M0, T1 
  sltu   T0, R0, T1 
  add    R1, R1, T0 
  sltu   T0, R1, T0 
  add    R2, R2, T0 
  sltu   T0, R2, T0 
  add    R3, R3, T0 
.endm


.section .text

.global gfp_mul64_ise

gfp_mul64_ise:
  PROLOGUE
  LOAD_A
  MULTIPLY_B0
  FINAL_REDC
  STORE_R
  EPILOGUE
