// void mul_384_aixb_ise(vec768 ret0, vec768 ret1, const vec384 a, const vec384x b)


#include "ise.h"


// registers 

// accumulator `z` and `y`
#define Z0 a4
#define Z1 a5
#define Y0 a6
#define Y1 a7
// operand `b` 
#define B0 t0 
#define B1 t1
#define B2 t2
#define B3 t3
#define B4 t4
#define B5 t5
#define B6 t6
// operand `c` 
#define C0 s7
#define C1 s8
#define C2 s9
#define C3 s10
#define C4 s11
#define C5 a2
#define C6 a3
// operand `a`
#define A0 s0 
#define A1 s1
#define A2 s2
#define A3 s3
#define A4 s4
#define A5 s5
#define A6 s6


// prologue + epilogue 

.macro PROLOGUE
  addi  sp, sp, -96
  sd    s0,  0(sp)
  sd    s1,  8(sp)
  sd    s2, 16(sp)
  sd    s3, 24(sp)
  sd    s4, 32(sp)
  sd    s5, 40(sp)
  sd    s6, 48(sp)
  sd    s7, 56(sp)
  sd    s8, 64(sp)
  sd    s9, 72(sp)
  sd    s10,80(sp)
  sd    s11,88(sp)
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
  ld    s8, 64(sp)
  ld    s9, 72(sp)
  ld    s10,80(sp)
  ld    s11,88(sp)
  addi  sp, sp, 96
  ret
.endm

// load operand

.macro LOAD_A
  ld    A0,  0(a2)
  ld    A1,  8(a2)
  ld    A2, 16(a2)
  ld    A3, 24(a2)
  ld    A4, 32(a2)
  ld    A5, 40(a2)
  ld    A6, 48(a2)
.endm 

.macro LOAD_B
  ld    B0,  0(a3)
  ld    B1,  8(a3)
  ld    B2, 16(a3)
  ld    B3, 24(a3)
  ld    B4, 32(a3)
  ld    B5, 40(a3)
  ld    B6, 48(a3)
.endm

.macro LOAD_C
  ld    C0, 56(a3)
  ld    C1, 64(a3)
  ld    C2, 72(a3)
  ld    C3, 80(a3)
  ld    C4, 88(a3)
  ld    C5, 96(a3)
  ld    C6,104(a3)
.endm

.macro COMPUTE_R0
  madd55lu Z0, A0, B0, x0
  madd55hu Z1, A0, B0, x0
  madd55lu Y0, A0, C0, x0
  madd55hu Y1, A0, C0, x0
  sd       Z0,  0(a0)
  sd       Y0,  0(a1)
.endm

.macro COMPUTE_R1
  madd55lu Z1, A0, B1, Z1
  madd55hu Z0, A0, B1, x0
  madd55lu Y1, A0, C1, Y1
  madd55hu Y0, A0, C1, x0
  madd55lu Z1, A1, B0, Z1
  madd55hu Z0, A1, B0, Z0
  madd55lu Y1, A1, C0, Y1
  madd55hu Y0, A1, C0, Y0
  sd       Z1,  8(a0)
  sd       Y1,  8(a1)
.endm

.macro COMPUTE_R2
  madd55lu Z0, A0, B2, Z0
  madd55hu Z1, A0, B2, x0
  madd55lu Y0, A0, C2, Y0
  madd55hu Y1, A0, C2, x0
  madd55lu Z0, A1, B1, Z0
  madd55hu Z1, A1, B1, Z1
  madd55lu Y0, A1, C1, Y0
  madd55hu Y1, A1, C1, Y1
  madd55lu Z0, A2, B0, Z0
  madd55hu Z1, A2, B0, Z1
  madd55lu Y0, A2, C0, Y0
  madd55hu Y1, A2, C0, Y1
  sd       Z0, 16(a0)
  sd       Y0, 16(a1)
.endm

.macro COMPUTE_R3
  madd55lu Z1, A0, B3, Z1
  madd55hu Z0, A0, B3, x0
  madd55lu Y1, A0, C3, Y1
  madd55hu Y0, A0, C3, x0
  madd55lu Z1, A1, B2, Z1
  madd55hu Z0, A1, B2, Z0
  madd55lu Y1, A1, C2, Y1
  madd55hu Y0, A1, C2, Y0
  madd55lu Z1, A2, B1, Z1
  madd55hu Z0, A2, B1, Z0
  madd55lu Y1, A2, C1, Y1
  madd55hu Y0, A2, C1, Y0
  madd55lu Z1, A3, B0, Z1
  madd55hu Z0, A3, B0, Z0
  madd55lu Y1, A3, C0, Y1
  madd55hu Y0, A3, C0, Y0
  sd       Z1, 24(a0)
  sd       Y1, 24(a1)
.endm

.macro COMPUTE_R4
  madd55lu Z0, A0, B4, Z0
  madd55hu Z1, A0, B4, x0
  madd55lu Y0, A0, C4, Y0
  madd55hu Y1, A0, C4, x0
  madd55lu Z0, A1, B3, Z0
  madd55hu Z1, A1, B3, Z1
  madd55lu Y0, A1, C3, Y0
  madd55hu Y1, A1, C3, Y1
  madd55lu Z0, A2, B2, Z0
  madd55hu Z1, A2, B2, Z1
  madd55lu Y0, A2, C2, Y0
  madd55hu Y1, A2, C2, Y1
  madd55lu Z0, A3, B1, Z0
  madd55hu Z1, A3, B1, Z1
  madd55lu Y0, A3, C1, Y0
  madd55hu Y1, A3, C1, Y1
  madd55lu Z0, A4, B0, Z0
  madd55hu Z1, A4, B0, Z1
  madd55lu Y0, A4, C0, Y0
  madd55hu Y1, A4, C0, Y1
  sd       Z0, 32(a0)
  sd       Y0, 32(a1)
.endm

.macro COMPUTE_R5
  madd55lu Z1, A0, B5, Z1
  madd55hu Z0, A0, B5, x0
  madd55lu Y1, A0, C5, Y1
  madd55hu Y0, A0, C5, x0
  madd55lu Z1, A1, B4, Z1
  madd55hu Z0, A1, B4, Z0
  madd55lu Y1, A1, C4, Y1
  madd55hu Y0, A1, C4, Y0
  madd55lu Z1, A2, B3, Z1
  madd55hu Z0, A2, B3, Z0
  madd55lu Y1, A2, C3, Y1
  madd55hu Y0, A2, C3, Y0
  madd55lu Z1, A3, B2, Z1
  madd55hu Z0, A3, B2, Z0
  madd55lu Y1, A3, C2, Y1
  madd55hu Y0, A3, C2, Y0
  madd55lu Z1, A4, B1, Z1
  madd55hu Z0, A4, B1, Z0
  madd55lu Y1, A4, C1, Y1
  madd55hu Y0, A4, C1, Y0
  madd55lu Z1, A5, B0, Z1
  madd55hu Z0, A5, B0, Z0
  madd55lu Y1, A5, C0, Y1
  madd55hu Y0, A5, C0, Y0
  sd       Z1, 40(a0)
  sd       Y1, 40(a1)
.endm

.macro COMPUTE_R6
  madd55lu Z0, A0, B6, Z0
  madd55hu Z1, A0, B6, x0
  madd55lu Y0, A0, C6, Y0
  madd55hu Y1, A0, C6, x0
  madd55lu Z0, A1, B5, Z0
  madd55hu Z1, A1, B5, Z1
  madd55lu Y0, A1, C5, Y0
  madd55hu Y1, A1, C5, Y1
  madd55lu Z0, A2, B4, Z0
  madd55hu Z1, A2, B4, Z1
  madd55lu Y0, A2, C4, Y0
  madd55hu Y1, A2, C4, Y1
  madd55lu Z0, A3, B3, Z0
  madd55hu Z1, A3, B3, Z1
  madd55lu Y0, A3, C3, Y0
  madd55hu Y1, A3, C3, Y1
  madd55lu Z0, A4, B2, Z0
  madd55hu Z1, A4, B2, Z1
  madd55lu Y0, A4, C2, Y0
  madd55hu Y1, A4, C2, Y1
  madd55lu Z0, A5, B1, Z0
  madd55hu Z1, A5, B1, Z1
  madd55lu Y0, A5, C1, Y0
  madd55hu Y1, A5, C1, Y1
  madd55lu Z0, A6, B0, Z0
  madd55hu Z1, A6, B0, Z1
  madd55lu Y0, A6, C0, Y0
  madd55hu Y1, A6, C0, Y1
  sd       Z0, 48(a0)
  sd       Y0, 48(a1)
.endm

.macro COMPUTE_R7
  madd55lu Z1, A1, B6, Z1
  madd55hu Z0, A1, B6, x0
  madd55lu Y1, A1, C6, Y1
  madd55hu Y0, A1, C6, x0
  madd55lu Z1, A2, B5, Z1
  madd55hu Z0, A2, B5, Z0
  madd55lu Y1, A2, C5, Y1
  madd55hu Y0, A2, C5, Y0
  madd55lu Z1, A3, B4, Z1
  madd55hu Z0, A3, B4, Z0
  madd55lu Y1, A3, C4, Y1
  madd55hu Y0, A3, C4, Y0
  madd55lu Z1, A4, B3, Z1
  madd55hu Z0, A4, B3, Z0
  madd55lu Y1, A4, C3, Y1
  madd55hu Y0, A4, C3, Y0
  madd55lu Z1, A5, B2, Z1
  madd55hu Z0, A5, B2, Z0
  madd55lu Y1, A5, C2, Y1
  madd55hu Y0, A5, C2, Y0
  madd55lu Z1, A6, B1, Z1
  madd55hu Z0, A6, B1, Z0
  madd55lu Y1, A6, C1, Y1
  madd55hu Y0, A6, C1, Y0
  sd       Z1, 56(a0)
  sd       Y1, 56(a1)
.endm

.macro COMPUTE_R8
  madd55lu Z0, A2, B6, Z0
  madd55hu Z1, A2, B6, x0
  madd55lu Y0, A2, C6, Y0
  madd55hu Y1, A2, C6, x0
  madd55lu Z0, A3, B5, Z0
  madd55hu Z1, A3, B5, Z1
  madd55lu Y0, A3, C5, Y0
  madd55hu Y1, A3, C5, Y1
  madd55lu Z0, A4, B4, Z0
  madd55hu Z1, A4, B4, Z1
  madd55lu Y0, A4, C4, Y0
  madd55hu Y1, A4, C4, Y1
  madd55lu Z0, A5, B3, Z0
  madd55hu Z1, A5, B3, Z1
  madd55lu Y0, A5, C3, Y0
  madd55hu Y1, A5, C3, Y1
  madd55lu Z0, A6, B2, Z0
  madd55hu Z1, A6, B2, Z1
  madd55lu Y0, A6, C2, Y0
  madd55hu Y1, A6, C2, Y1
  sd       Z0, 64(a0)
  sd       Y0, 64(a1)
.endm

.macro COMPUTE_R9
  madd55lu Z1, A3, B6, Z1
  madd55hu Z0, A3, B6, x0
  madd55lu Y1, A3, C6, Y1
  madd55hu Y0, A3, C6, x0
  madd55lu Z1, A4, B5, Z1
  madd55hu Z0, A4, B5, Z0
  madd55lu Y1, A4, C5, Y1
  madd55hu Y0, A4, C5, Y0
  madd55lu Z1, A5, B4, Z1
  madd55hu Z0, A5, B4, Z0
  madd55lu Y1, A5, C4, Y1
  madd55hu Y0, A5, C4, Y0
  madd55lu Z1, A6, B3, Z1
  madd55hu Z0, A6, B3, Z0
  madd55lu Y1, A6, C3, Y1
  madd55hu Y0, A6, C3, Y0
  sd       Z1, 72(a0)
  sd       Y1, 72(a1)
.endm

.macro COMPUTE_R10
  madd55lu Z0, A4, B6, Z0
  madd55hu Z1, A4, B6, x0
  madd55lu Y0, A4, C6, Y0
  madd55hu Y1, A4, C6, x0
  madd55lu Z0, A5, B5, Z0
  madd55hu Z1, A5, B5, Z1
  madd55lu Y0, A5, C5, Y0
  madd55hu Y1, A5, C5, Y1
  madd55lu Z0, A6, B4, Z0
  madd55hu Z1, A6, B4, Z1
  madd55lu Y0, A6, C4, Y0
  madd55hu Y1, A6, C4, Y1
  sd       Z0, 80(a0)
  sd       Y0, 80(a1)
.endm

.macro COMPUTE_R11
  madd55lu Z1, A5, B6, Z1
  madd55hu Z0, A5, B6, x0
  madd55lu Y1, A5, C6, Y1
  madd55hu Y0, A5, C6, x0
  madd55lu Z1, A6, B5, Z1
  madd55hu Z0, A6, B5, Z0
  madd55lu Y1, A6, C5, Y1
  madd55hu Y0, A6, C5, Y0
  sd       Z1, 88(a0)
  sd       Y1, 88(a1)
.endm

.macro COMPUTE_R12
  madd55lu Z0, A6, B6, Z0
  madd55hu Z1, A6, B6, x0
  madd55lu Y0, A6, C6, Y0
  madd55hu Y1, A6, C6, x0
  sd       Z0, 96(a0)
  sd       Y0, 96(a1)
.endm

.macro COMPUTE_R13
  sd       Z1,104(a0)
  sd       Y1,104(a1)
.endm


.section .text

.global mul_384_aixb_ise

mul_384_aixb_ise:
  PROLOGUE
  LOAD_A
  LOAD_B
  LOAD_C
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
