// void gfp_sub_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);


#include "ise_al.h"


// registers 

// result `r`
#define R0 a3
#define R1 a4
#define R2 a5 
#define R3 a6
#define R4 t0
// operand `b`
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
// operand `a`
#define A0 t4 
#define A1 t5 
#define A2 t6 
#define A3 a7
// temporary
#define T0 a1
#define T1 a2
// constant `m` 
#define M0 t3


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

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
.endm 

.macro STORE_R
  sd    T1,  0(a0)
  sd    R1,  8(a0)
  sd    R2, 16(a0)
  sd    R3, 24(a0)
.endm

// integer subtraction r = a - b + 2p > 0

.macro SUBTRACTION
  sltu  T0, A0, B0
  sub   R0, A0, B0
  sltiu T1, R0,  38
  addi  R0, R0, -38
  add   T0, T0, T1
  sltu  T1, A1, T0 
  sub   R1, A1, T0 
  sltu  T0, R1, B1
  sub   R1, R1, B1
  add   T0, T1, T0 
  sltu  T1, A2, T0 
  sub   R2, A2, T0 
  sltu  T0, R2, B2 
  sub   R2, R2, B2
  add   T0, T1, T0  
  sltu  T1, A3, T0 
  sub   R3, A3, T0 
  sltu  T0, R3, B3 
  sub   R3, R3, B3
  add   T0, T1, T0 
  li    R4,  1
  sub   R4, R4, T0 
.endm

// final reduction 

.macro FINAL_REDC
  srli   T0, R3, 63
  slli   R4, R4, 1
  or     R4, R4, T0
  slli   R3, R3, 1
  srli   R3, R3, 1
  li     M0, 19
#if defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
  mv     T1, R0
#endif
  maddlu T1, R4, M0, R0 
  sltu   T0, T1, T0 
  add    R1, R1, T0 
  sltu   T0, R1, T0 
  add    R2, R2, T0 
  sltu   T0, R2, T0 
  add    R3, R3, T0
.endm


.section .text

.global gfp_sub_ise

gfp_sub_ise:
  PROLOGUE
  LOAD_A
  LOAD_B
  SUBTRACTION
  FINAL_REDC
  STORE_R
  EPILOGUE
  
