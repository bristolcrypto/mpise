#include "ise_al.h"

// ============================================================================

#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 51
#endif

#if   ( MPISE_XLEN == 32 )
#define IMM_SHIFT 2
#define IMM_INC   4
#define ALL1WORD 0xFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (32 - (LIMBBITS)))
#elif ( MPISE_XLEN == 64 )
#define IMM_SHIFT 3
#define IMM_INC   8
#define ALL1WORD 0xFFFFFFFFFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (64 - (LIMBBITS)))
#endif

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the length of operands `a`, `b`
#define len  a3
// Register `tmp` holds an intermediate value (MACC1X1)
#define tmp  t0
// Register `mask` holds a radix-dependent mask (LIMBMASK)
#define mask t0
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t1
#define octr t2
// Registers `aw0`, `bw0` hold a word of operand `a`, `b`
#define aw0 t3
#define bw0 t4
// Registers `rwl` and `rwh` hold words of the product
#define rwl t5
#define rwh t6

// ----------------------------------------------------------------------------

// The macro `MACC1X1` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the double-length accumulator `rhi|rlo`. The two words
// `tlo` and `thi` hold temporary results.

.macro MACC1X1 rhi:req, rlo:req, aiw:req, bjw:req, tmp:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu \rlo, \aiw, \bjw, \rlo
    madd51hu \rhi, \aiw, \bjw, \rhi
#endif
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    madd51lu \rlo, \aiw, \bjw
    madd51hu \rhi, \aiw, \bjw
#endif
.endm

// ----------------------------------------------------------------------------

// The macro `LDM_OPA` loads a word of array `a` from RAM and puts it in
// register `aw0`.

#if   ( MPISE_XLEN == 32 )
.macro LDW_OPA
    lw      aw0, 0(aptr)
    addi    aptr, aptr, 4
.endm
#elif ( MPISE_XLEN == 64 )
.macro LDW_OPA
    ld      aw0, 0(aptr)
    addi    aptr, aptr, 8
.endm
#endif

// The macro `LDM_OPB` loads a word of array `b` from RAM and puts it in
// registers `bw0`.

#if   ( MPISE_XLEN == 32 )
.macro LDW_OPB
    addi    bptr, bptr, -4
    lw      bw0, 0(bptr)
 .endm
#elif ( MPISE_XLEN == 64 )
.macro LDW_OPB
    addi    bptr, bptr, -8
    ld      bw0, 0(bptr)
 .endm
#endif

// convert lower half of accu to 60-bit limbs

.macro TOLIMB
    // li      mask, LIMBMASK
    srliadd rwh, rwh, rwl, LIMBBITS
    and     rwl, rwl, mask
.endm

// The macro `STM_RES` stores a result-words, which is in register `rwl`, to
// array `r` in RAM.

#if   ( MPISE_XLEN == 32 )
.macro STW_RES
    sw      rwl, 0(rptr)
    addi    rptr, rptr, 4
.endm
#elif ( MPISE_XLEN == 64 )
.macro STW_RES
    sd      rwl, 0(rptr)
    addi    rptr, rptr, 8
.endm
#endif

.macro CLRACCU
    mv      rwl, zero
    mv      rwh, zero
.endm

.macro SHRACCU
    mv      rwl, rwh
    mv      rwh, zero
.endm

// ============================================================================

// Multiple-precision multiplication using reduced-radix representation
// --------------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 limbs of the
// two operands are processed in each iteration of the inner loop.

.text
.global mpi_mul_1x1rr_ise_asm
.type mpi_mul_1x1rr_ise_asm,%function
.balign 16
mpi_mul_1x1rr_ise_asm:
    CLRACCU
    li      mask, LIMBMASK
    slli    len, len, IMM_SHIFT
    mv      octr, zero
    // START OF FIRST OUTER LOOP
.LOUTLOOP1: 
    mv      ictr, zero
    add     octr, octr,  IMM_INC
    add     bptr, bptr, octr
    // START OF FIRST INNER LOOP
.LINNLOOP1:     // the first inner loop is iterated $octr/16$ times
    LDW_OPA     // load a words of array `a` and put it in
    LDW_OPB     // load a words of array `b` and put it in
    MACC1X1 rwh, rwl, aw0, bw0, tmp
    addi    ictr, ictr,  IMM_INC           // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP 
    TOLIMB
    STW_RES     // store the result-word in array `r` in RAM
    SHRACCU     // 
    sub     aptr, aptr, octr
    bne     octr, len, .LOUTLOOP1  // branch to start of loop if octr != len
    // END OF FIRST OUTER LOOP
    add     aptr, aptr, len        // set aptr to address of a[len}
    add     bptr, bptr, len        // set bptr to address of b[len}
    addi    octr, octr, -IMM_INC         // second outer loop is iterated len-1 times
    // START OF SECOND OUTER LOOP
.LOUTLOOP2: 
    mv      ictr, zero
    sub     aptr, aptr, octr
    // START OF SECOND INNER LOOP
.LINNLOOP2:     // the second inner loop is iterated $octr/16$ times
    LDW_OPA     // load a words of array `a` and put it in
    LDW_OPB     // load a words of array `b` and put it in
    MACC1X1 rwh, rwl, aw0, bw0, tmp
    addi    ictr, ictr,  IMM_INC           // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP 
    TOLIMB
    STW_RES     // store the result-words in array `r` in RAM
    SHRACCU     // 
    add     bptr, bptr, octr
    addi    octr, octr, -IMM_INC
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    TOLIMB
    STW_RES     // store the result-words in array `r` in RAM
    ret
.end

// ============================================================================
