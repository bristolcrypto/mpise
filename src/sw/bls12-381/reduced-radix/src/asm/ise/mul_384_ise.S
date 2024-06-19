// void mul_384_ise(vec768 ret, const vec384 a, const vec384 b);


#include "ise.h"


// registers

// accumulator `z`
#define Z0 a3
#define Z1 a4
// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
// operand `a`
#define A0 a5 
#define A1 a6
#define A2 a7
#define A3 s0
#define A4 s1
#define A5 s2
#define A6 s3


// macros to use custom instructions

// .macro maccrrlu Z, A, B, S
// #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// // !destructive
// #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// // !destructive && !stateless
// #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// // !destructive &&  stateless
//   // maccrrlu \Z, \A, \B, \S, 7    // imm = 7 = 55 - 48
// #endif
// #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
// //  destructive
// #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// //  destructive && !stateless
// #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// //  destructive &&  stateless
// #endif
// #endif
// .endm

// .macro maccrrhu Z, A, B, S
// #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// // !destructive
// #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// // !destructive && !stateless
// #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// // !destructive &&  stateless
//   maccrrhu \Z, \A, \B, \S, 7    // imm = 7 = 55 - 48
// #endif
// #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
// //  destructive
// #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// //  destructive && !stateless
// #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// //  destructive &&  stateless
// #endif
// #endif
// .endm

// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -32
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
.endm

.macro EPILOGUE
  ld    s0,  0(sp)
  ld    s1,  8(sp)
  ld    s2, 16(sp)
  ld    s3, 24(sp)
  addi  sp, sp, 32
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

.macro LOAD_B
  ld    B0,  0(a2)
  ld    B1,  8(a2)
  ld    B2, 16(a2)
  ld    B3, 24(a2)
  ld    B4, 32(a2)
  ld    B5, 40(a2)
  ld    B6, 48(a2)
.endm

.macro COMPUTE_R0
  maccrrlu Z0, A0, B0, x0, 7
  maccrrhu Z1, A0, B0, x0, 7
  sd       Z0,  0(a0)
.endm

.macro COMPUTE_R1
  maccrrlu Z1, A0, B1, Z1, 7
  maccrrhu Z0, A0, B1, x0, 7
  maccrrlu Z1, A1, B0, Z1, 7
  maccrrhu Z0, A1, B0, Z0, 7
  sd       Z1,  8(a0)
.endm

.macro COMPUTE_R2
  maccrrlu Z0, A0, B2, Z0, 7
  maccrrhu Z1, A0, B2, x0, 7
  maccrrlu Z0, A1, B1, Z0, 7
  maccrrhu Z1, A1, B1, Z1, 7
  maccrrlu Z0, A2, B0, Z0, 7
  maccrrhu Z1, A2, B0, Z1, 7
  sd       Z0, 16(a0)
.endm

.macro COMPUTE_R3
  maccrrlu Z1, A0, B3, Z1, 7
  maccrrhu Z0, A0, B3, x0, 7
  maccrrlu Z1, A1, B2, Z1, 7
  maccrrhu Z0, A1, B2, Z0, 7
  maccrrlu Z1, A2, B1, Z1, 7
  maccrrhu Z0, A2, B1, Z0, 7
  maccrrlu Z1, A3, B0, Z1, 7
  maccrrhu Z0, A3, B0, Z0, 7
  sd       Z1, 24(a0)
.endm

.macro COMPUTE_R4
  maccrrlu Z0, A0, B4, Z0, 7
  maccrrhu Z1, A0, B4, x0, 7
  maccrrlu Z0, A1, B3, Z0, 7
  maccrrhu Z1, A1, B3, Z1, 7
  maccrrlu Z0, A2, B2, Z0, 7
  maccrrhu Z1, A2, B2, Z1, 7
  maccrrlu Z0, A3, B1, Z0, 7
  maccrrhu Z1, A3, B1, Z1, 7
  maccrrlu Z0, A4, B0, Z0, 7
  maccrrhu Z1, A4, B0, Z1, 7
  sd       Z0, 32(a0)
.endm

.macro COMPUTE_R5
  maccrrlu Z1, A0, B5, Z1, 7
  maccrrhu Z0, A0, B5, x0, 7
  maccrrlu Z1, A1, B4, Z1, 7
  maccrrhu Z0, A1, B4, Z0, 7
  maccrrlu Z1, A2, B3, Z1, 7
  maccrrhu Z0, A2, B3, Z0, 7
  maccrrlu Z1, A3, B2, Z1, 7
  maccrrhu Z0, A3, B2, Z0, 7
  maccrrlu Z1, A4, B1, Z1, 7
  maccrrhu Z0, A4, B1, Z0, 7
  maccrrlu Z1, A5, B0, Z1, 7
  maccrrhu Z0, A5, B0, Z0, 7
  sd       Z1, 40(a0)
.endm

.macro COMPUTE_R6
  maccrrlu Z0, A0, B6, Z0, 7
  maccrrhu Z1, A0, B6, x0, 7
  maccrrlu Z0, A1, B5, Z0, 7
  maccrrhu Z1, A1, B5, Z1, 7
  maccrrlu Z0, A2, B4, Z0, 7
  maccrrhu Z1, A2, B4, Z1, 7
  maccrrlu Z0, A3, B3, Z0, 7
  maccrrhu Z1, A3, B3, Z1, 7
  maccrrlu Z0, A4, B2, Z0, 7
  maccrrhu Z1, A4, B2, Z1, 7
  maccrrlu Z0, A5, B1, Z0, 7
  maccrrhu Z1, A5, B1, Z1, 7
  maccrrlu Z0, A6, B0, Z0, 7
  maccrrhu Z1, A6, B0, Z1, 7
  sd       Z0, 48(a0)
.endm

.macro COMPUTE_R7
  maccrrlu Z1, A1, B6, Z1, 7
  maccrrhu Z0, A1, B6, x0, 7
  maccrrlu Z1, A2, B5, Z1, 7
  maccrrhu Z0, A2, B5, Z0, 7
  maccrrlu Z1, A3, B4, Z1, 7
  maccrrhu Z0, A3, B4, Z0, 7
  maccrrlu Z1, A4, B3, Z1, 7
  maccrrhu Z0, A4, B3, Z0, 7
  maccrrlu Z1, A5, B2, Z1, 7
  maccrrhu Z0, A5, B2, Z0, 7
  maccrrlu Z1, A6, B1, Z1, 7
  maccrrhu Z0, A6, B1, Z0, 7
  sd       Z1, 56(a0)
.endm

.macro COMPUTE_R8
  maccrrlu Z0, A2, B6, Z0, 7
  maccrrhu Z1, A2, B6, x0, 7
  maccrrlu Z0, A3, B5, Z0, 7
  maccrrhu Z1, A3, B5, Z1, 7
  maccrrlu Z0, A4, B4, Z0, 7
  maccrrhu Z1, A4, B4, Z1, 7
  maccrrlu Z0, A5, B3, Z0, 7
  maccrrhu Z1, A5, B3, Z1, 7
  maccrrlu Z0, A6, B2, Z0, 7
  maccrrhu Z1, A6, B2, Z1, 7
  sd       Z0, 64(a0)
.endm

.macro COMPUTE_R9
  maccrrlu Z1, A3, B6, Z1, 7
  maccrrhu Z0, A3, B6, x0, 7
  maccrrlu Z1, A4, B5, Z1, 7
  maccrrhu Z0, A4, B5, Z0, 7
  maccrrlu Z1, A5, B4, Z1, 7
  maccrrhu Z0, A5, B4, Z0, 7
  maccrrlu Z1, A6, B3, Z1, 7
  maccrrhu Z0, A6, B3, Z0, 7
  sd       Z1, 72(a0)
.endm

.macro COMPUTE_R10
  maccrrlu Z0, A4, B6, Z0, 7
  maccrrhu Z1, A4, B6, x0, 7
  maccrrlu Z0, A5, B5, Z0, 7
  maccrrhu Z1, A5, B5, Z1, 7
  maccrrlu Z0, A6, B4, Z0, 7
  maccrrhu Z1, A6, B4, Z1, 7
  sd       Z0, 80(a0)
.endm

.macro COMPUTE_R11
  maccrrlu Z1, A5, B6, Z1, 7
  maccrrhu Z0, A5, B6, x0, 7
  maccrrlu Z1, A6, B5, Z1, 7
  maccrrhu Z0, A6, B5, Z0, 7
  sd       Z1, 88(a0)
.endm

.macro COMPUTE_R12
  maccrrlu Z0, A6, B6, Z0, 7
  maccrrhu Z1, A6, B6, x0, 7
  sd       Z0, 96(a0)
.endm

.macro COMPUTE_R13
  sd       Z1,104(a0)
.endm


.section .text

.global mul_384_ise

mul_384_ise:
  PROLOGUE
  LOAD_A
  LOAD_B
  COMPUTE_R0
  COMPUTE_R1
  COMPUTE_R2
  COMPUTE_R3
  COMPUTE_R4
  COMPUTE_R5
  COMPUTE_R6
  COMPUTE_R7
  COMPUTE_R8
  COMPUTE_R9
  COMPUTE_R10
  COMPUTE_R11
  COMPUTE_R12
  COMPUTE_R13
  EPILOGUE
