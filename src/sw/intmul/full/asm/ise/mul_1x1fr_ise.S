#include "ise_al.h"

// ============================================================================

#if   ( MPISE_XLEN == 32 )
#define IMM_SHIFT 2
#define IMM_INC   4
#elif ( MPISE_XLEN == 64 )
#define IMM_SHIFT 3
#define IMM_INC   8
#endif

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the length of operands `a`, `b`
#define len  a3
// Registers `tmp` holds an intermediate value (MACC1X1)
#define tmp  a4
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t0
#define octr t1
// Registers `aw0`, `bw0` hold a word of operand `a`, `b`
#define aw0 t2
#define bw0 t3
// Registers `rw0` t0 `rw2` hold words of the product
#define rw0 t4
#define rw1 t5
#define rw2 t6

// ----------------------------------------------------------------------------

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

// ----------------------------------------------------------------------------

// The macro `LDW_OPA` loads a word of array `a` from RAM and puts it in
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

// The macro `LDW_OPB` loads a word of array `b` from RAM and puts it in
// register `bw0`.

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

// The macro `STW_RES` stores a result-word, which is in registers `rw0`, to
// array `r` in RAM.

#if   ( MPISE_XLEN == 32 )
.macro STW_RES
    sw      rw0, 0(rptr)
    addi    rptr, rptr, 4
.endm
#elif ( MPISE_XLEN == 64 )
.macro STW_RES
    sd      rw0, 0(rptr)
    addi    rptr, rptr, 8
.endm
#endif

.macro CLRACCU
    mv      rw0, zero
    mv      rw1, zero
    mv      rw2, zero
.endm


.macro SHRACCU
    mv      rw0, rw1
    mv      rw1, rw2
    mv      rw2, zero
.endm

// ============================================================================

// Multiple-precision multiplication using full-radix representation
// -----------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 words of the
// two operands are processed in each iteration of the inner loop.

.text
.global mpi_mul_1x1fr_ise_asm
.type mpi_mul_1x1fr_ise_asm,%function
.balign 16
mpi_mul_1x1fr_ise_asm:
    CLRACCU
    slli    len, len, IMM_SHIFT
    mv      octr, zero
    // START OF FIRST OUTER LOOP
.LOUTLOOP1:
    mv      ictr, zero
    add     octr, octr,  IMM_INC
    add     bptr, bptr, octr
    // START OF FIRST INNER LOOP
.LINNLOOP1:     // the first inner loop is iterated $octr/16$ times
    LDW_OPA     // load four words of array `a` and put them in
    LDW_OPB     // load four words of array `b` and put them in
    MACC1X1 rw2, rw1, rw0, aw0, bw0, tmp
    addi    ictr, ictr,  IMM_INC           // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP
    STW_RES     // store the result-words in array `r` in RAM
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
    LDW_OPA     // load four words of array `a` and put them in
    LDW_OPB     // load four words of array `b` and put them in
    MACC1X1 rw2, rw1, rw0, aw0, bw0, tmp
    addi    ictr, ictr,  IMM_INC           // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP
    STW_RES     // store the result-words in array `r` in RAM
    SHRACCU     //
    add     bptr, bptr, octr
    addi    octr, octr, -IMM_INC
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    STW_RES     // store the result-words in array `r` in RAM
    ret
.end

// ============================================================================
