#include "ise_al.h"

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the length of operands `a`, `b`
#define len  a3
// Registers `tmp` holds an intermediate value (MACC1X1)
#define tmp  t0
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t1
#define octr t2
// Registers `aw00` to `aw03` hold words of operand `a`
#define aw00 a4
#define aw01 a5
#define aw02 a6
#define aw03 a7
// Registers `bw00` to `bw03` hold words of operand `b`
#define bw00 s0
#define bw01 s1
#define bw02 s2
#define bw03 s3
// Registers `rw00` to `rw08` hold words of the product
#define rw00 s4
#define rw01 s5
#define rw02 s6
#define rw03 s7
#define rw04 s8
#define rw05 t3
#define rw06 t4
#define rw07 t5
#define rw08 t6


// The macro `MACC1X1` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the triple-length accumulator `rex|rhi|rlo`. The word
// `tmp` holds a temporary result.

.macro MACC1X1 rex:req, rhi:req, rlo:req, aiw:req, bjw:req, tmp:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \tmp, \rlo
#endif
    maddhu  \tmp, \aiw, \bjw, \rlo
    maddlu  \rlo, \aiw, \bjw, \rlo
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    cacc    \rex, \rhi, \tmp
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    cacc    \rex, \rhi, \tmp, \rex
#endif
    add     \rhi, \rhi, \tmp
.endm


.macro MACC4x4
    MACC1X1 rw02, rw01, rw00, aw00, bw00, tmp
    MACC1X1 rw03, rw02, rw01, aw00, bw01, tmp
    MACC1X1 rw03, rw02, rw01, aw01, bw00, tmp
    MACC1X1 rw04, rw03, rw02, aw00, bw02, tmp
    MACC1X1 rw04, rw03, rw02, aw01, bw01, tmp
    MACC1X1 rw04, rw03, rw02, aw02, bw00, tmp
    MACC1X1 rw05, rw04, rw03, aw00, bw03, tmp
    MACC1X1 rw05, rw04, rw03, aw01, bw02, tmp
    MACC1X1 rw05, rw04, rw03, aw02, bw01, tmp
    MACC1X1 rw05, rw04, rw03, aw03, bw00, tmp
    MACC1X1 rw06, rw05, rw04, aw01, bw03, tmp
    MACC1X1 rw06, rw05, rw04, aw02, bw02, tmp
    MACC1X1 rw06, rw05, rw04, aw03, bw01, tmp
    MACC1X1 rw07, rw06, rw05, aw02, bw03, tmp
    MACC1X1 rw07, rw06, rw05, aw03, bw02, tmp
    MACC1X1 rw08, rw07, rw06, aw03, bw03, tmp
.endm


// The macro `PROLOGUE` pushes 9 callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -72
    sd      s0, (sp)
    sd      s1, 8(sp)
    sd      s2, 16(sp)
    sd      s3, 24(sp)
    sd      s4, 32(sp)
    sd      s5, 40(sp)
    sd      s6, 48(sp)
    sd      s7, 56(sp)
    sd      s8, 64(sp)
.endm


// The macro `EPILOGUE` pops 9 callee-saved registers from the stack and
// returns to the caller.

.macro EPILOGUE
    ld      s0, (sp)
    ld      s1, 8(sp)
    ld      s2, 16(sp)
    ld      s3, 24(sp)
    ld      s4, 32(sp)
    ld      s5, 40(sp)
    ld      s6, 48(sp)
    ld      s7, 56(sp)
    ld      s8, 64(sp)
    addi    sp, sp, 72
    ret
.endm


// The macro `LDM_OPA` loads four words of array `a` from RAM and puts then in
// registers `aw00`-`aw03`.

.macro LDM_OPA
    ld      aw00, 0(aptr)
    ld      aw01, 8(aptr)
    ld      aw02, 16(aptr)
    ld      aw03, 24(aptr)
    addi    aptr, aptr, 32
.endm


// The macro `LDM_OPB` loads four words of array `b` from RAM and puts then in
// registers `bw00`-`bw03`.

.macro LDM_OPB
    ld      bw03, -8(bptr)
    ld      bw02, -16(bptr)
    ld      bw01, -24(bptr)
    ld      bw00, -32(bptr)
    addi    bptr, bptr, -32
.endm


// The macro `STM_RES` stores four result-words, which are in registers `rw00`-
// `rw03`, to array `r` in RAM.

.macro STM_RES
    sd      rw00, 0(rptr)
    sd      rw01, 8(rptr)
    sd      rw02, 16(rptr)
    sd      rw03, 24(rptr)
    addi    rptr, rptr, 32
.endm


.macro CLRACCU
    mv      rw00, zero
    mv      rw01, zero
    mv      rw02, zero
    mv      rw03, zero
    mv      rw04, zero
    mv      rw05, zero
    mv      rw06, zero
    mv      rw07, zero
    mv      rw08, zero
.endm


.macro SHRACCU
    mv      rw00, rw04
    mv      rw01, rw05
    mv      rw02, rw06
    mv      rw03, rw07
    mv      rw04, rw08
    mv      rw05, zero
    mv      rw06, zero
    mv      rw07, zero
    mv      rw08, zero
.endm


// Multiple-precision multiplication using full-radix representation
// -----------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 words of the
// two operands are processed in each iteration of the inner loop.


.text
.global mpi_mul_4x4fr_ise
.type mpi_mul_4x4fr_ise,%function
.balign 16
mpi_mul_4x4fr_ise:
    PROLOGUE            // push callee-saved registers on stack
    CLRACCU
    slli    len, len, 3
    mv      octr, zero
    // START OF FIRST OUTER LOOP
.LOUTLOOP1:
    mv      ictr, zero
    add     octr, octr, 32
    add     bptr, bptr, octr
    // START OF FIRST INNER LOOP
.LINNLOOP1:     // the first inner loop is iterated $octr/16$ times
    LDM_OPA     // load four words of array `a` and put them in
    LDM_OPB     // load four words of array `b` and put them in
    MACC4X4     //
    addi    ictr, ictr, 32          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     //
    sub     aptr, aptr, octr
    bne     octr, len, .LOUTLOOP1  // branch to start of loop if octr != len
    // END OF FIRST OUTER LOOP
    add     aptr, aptr, len        // set aptr to address of a[len}
    add     bptr, bptr, len        // set bptr to address of b[len}
    addi    octr, octr, -32        // second outer loop is iterated len-1 times
    // START OF SECOND OUTER LOOP
.LOUTLOOP2:
    mv      ictr, zero
    sub     aptr, aptr, octr
    // START OF SECOND INNER LOOP
.LINNLOOP2:     // the second inner loop is iterated $octr/16$ times
    LDM_OPA     // load four words of array `a` and put them in
    LDM_OPB     // load four words of array `b` and put them in
    MACC4X4     //
    addi    ictr, ictr, 32          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     //
    add     bptr, bptr, octr
    addi    octr, octr, -32
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    STM_RES     // store the result-words in array `r` in RAM
    EPILOGUE    // pop callee-saved registers and return


.end

