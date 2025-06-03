#include "ise_al.h"

// ============================================================================

#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 51
#endif

#if   ( MPISE_XLEN == 32 )
#define IMM_SHIFT 2
#define IMM_INC   16
#define ALL1WORD 0xFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (32 - (LIMBBITS)))
#elif ( MPISE_XLEN == 64 )
#define IMM_SHIFT 3
#define IMM_INC   32
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
#define tmp  ra
// Register `mask` holds a radix-dependent mask (LIMBMASK)
#define mask t0
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
#define bw02 s0
#define bw03 s1
// Registers `rw0l` to `rw6h` hold words of the product
#define rw0l s2
#define rw0h s3
#define rw1l s4
#define rw1h s5
#define rw2l s6
#define rw2h s7
#define rw3l s8
#define rw3h s9
#define rw4l s10
#define rw4h s11
#define rw5l t3
#define rw5h t4
#define rw6l t5
#define rw6h t6

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

.macro MACL4x2
    MACC1X1 rw0h, rw0l, aw00, bw00, tmp
    MACC1X1 rw1h, rw1l, aw00, bw01, tmp
    MACC1X1 rw1h, rw1l, aw01, bw00, tmp
    MACC1X1 rw2h, rw2l, aw01, bw01, tmp
    MACC1X1 rw2h, rw2l, aw02, bw00, tmp
    MACC1X1 rw3h, rw3l, aw02, bw01, tmp
    MACC1X1 rw3h, rw3l, aw03, bw00, tmp
    MACC1X1 rw4h, rw4l, aw03, bw01, tmp
.endm


.macro MACH4x2
    MACC1X1 rw2h, rw2l, aw00, bw02, tmp
    MACC1X1 rw3h, rw3l, aw00, bw03, tmp
    MACC1X1 rw3h, rw3l, aw01, bw02, tmp
    MACC1X1 rw4h, rw4l, aw01, bw03, tmp
    MACC1X1 rw4h, rw4l, aw02, bw02, tmp
    MACC1X1 rw5h, rw5l, aw02, bw03, tmp
    MACC1X1 rw5h, rw5l, aw03, bw02, tmp
    MACC1X1 rw6h, rw6l, aw03, bw03, tmp
.endm

// ----------------------------------------------------------------------------

// The macro `PROLOGUE` pushes 13 callee-saved registers on the stack.

#if   ( MPISE_XLEN == 32 )
.macro PROLOGUE
    addi    sp, sp, - 52
    sw      s0,   0(sp)
    sw      s1,   4(sp)
    sw      s2,   8(sp)
    sw      s3,  12(sp)
    sw      s4,  16(sp)
    sw      s5,  20(sp)
    sw      s6,  24(sp)
    sw      s7,  28(sp)
    sw      s8,  32(sp)
    sw      s9,  36(sp)
    sw      s10, 40(sp)
    sw      s11, 44(sp)
    sw      ra,  48(sp)
.endm
#elif ( MPISE_XLEN == 64 )
.macro PROLOGUE
    addi    sp, sp, -104
    sd      s0,   0(sp)
    sd      s1,   8(sp)
    sd      s2,  16(sp)
    sd      s3,  24(sp)
    sd      s4,  32(sp)
    sd      s5,  40(sp)
    sd      s6,  48(sp)
    sd      s7,  56(sp)
    sd      s8,  64(sp)
    sd      s9,  72(sp)
    sd      s10, 80(sp)
    sd      s11, 88(sp)
    sd      ra,  96(sp)
.endm
#endif

// The macro `EPILOGUE` pops 13 callee-saved registers from the stack and
// returns to the caller.

#if   ( MPISE_XLEN == 32 )
.macro EPILOGUE
    lw      ra,  48(sp)
    lw      s11, 44(sp)
    lw      s10, 40(sp)
    lw      s9,  36(sp)
    lw      s8,  32(sp)
    lw      s7,  28(sp)
    lw      s6,  24(sp)
    lw      s5,  20(sp)
    lw      s4,  16(sp)
    lw      s3,  12(sp)
    lw      s2,   8(sp)
    lw      s1,   4(sp)
    lw      s0,   0(sp)
    addi    sp, sp,  52
    ret
.endm
#elif ( MPISE_XLEN == 64 )
.macro EPILOGUE
    ld      ra,  96(sp)
    ld      s11, 88(sp)
    ld      s10, 80(sp)
    ld      s9,  72(sp)
    ld      s8,  64(sp)
    ld      s7,  56(sp)
    ld      s6,  48(sp)
    ld      s5,  40(sp)
    ld      s4,  32(sp)
    ld      s3,  24(sp)
    ld      s2,  16(sp)
    ld      s1,   8(sp)
    ld      s0,   0(sp)
    addi    sp, sp, 104
    ret
.endm
#endif

// ----------------------------------------------------------------------------

// The macro `LDM_OPA` loads four words of array `a` from RAM and puts then in
// registers `aw00`-`aw03`.

#if   ( MPISE_XLEN == 32 )
.macro LDM_OPA
    lw      aw00,  0(aptr)
    lw      aw01,  4(aptr)
    lw      aw02,  8(aptr)
    lw      aw03, 12(aptr)
    addi    aptr, aptr, 16
.endm
#elif ( MPISE_XLEN == 64 )
.macro LDM_OPA
    ld      aw00,  0(aptr)
    ld      aw01,  8(aptr)
    ld      aw02, 16(aptr)
    ld      aw03, 24(aptr)
    addi    aptr, aptr, 32
.endm
#endif

// The macro `LDL_OPB` loads two words of array `b` from RAM and puts then in
// registers `bw00`-`bw01`.

#if   ( MPISE_XLEN == 32 )
.macro LDL_OPB
    lw      bw01, -12(bptr)
    lw      bw00, -16(bptr)
.endm
#elif ( MPISE_XLEN == 64 )
.macro LDL_OPB
    ld      bw01, -24(bptr)
    ld      bw00, -32(bptr)
.endm
#endif

// The macro `LDH_OPB` loads two words of array `b` from RAM and puts then in
// registers `bw02`-`bw03`.

#if   ( MPISE_XLEN == 32 )
.macro LDH_OPB
    lw      bw03, - 4(bptr)
    lw      bw02, - 8(bptr)
    addi    bptr, bptr, -16
.endm
#elif ( MPISE_XLEN == 64 )
.macro LDH_OPB
    ld      bw03, - 8(bptr)
    ld      bw02, -16(bptr)
    addi    bptr, bptr, -32
.endm
#endif

// convert lower half of accu to 60-bit limbs

.macro TOLIMB
    // li      mask, LIMBMASK
    srliadd rw1l, rw1l, rw0l, LIMBBITS
    and     rw0l, rw0l, mask
    srliadd rw1h, rw1h, rw0h, LIMBBITS
    and     rw0h, rw0h, mask
    srliadd rw2l, rw2l, rw1l, LIMBBITS
    and     rw1l, rw1l, mask
    srliadd rw2h, rw2h, rw1h, LIMBBITS
    and     rw1h, rw1h, mask
    srliadd rw3l, rw3l, rw2l, LIMBBITS
    and     rw2l, rw2l, mask
    srliadd rw3h, rw3h, rw2h, LIMBBITS
    and     rw2h, rw2h, mask
    srliadd rw4l, rw4l, rw3l, LIMBBITS
    and     rw3l, rw3l, mask
    srliadd rw5l, rw5l, rw4l, LIMBBITS
    and     rw4l, rw4l, mask
    
    add     rw1l, rw1l, rw0h
    add     rw2l, rw2l, rw1h
    add     rw3l, rw3l, rw2h
    add     rw4l, rw4l, rw3h
    
    srliadd rw2l, rw2l, rw1l, LIMBBITS
    and     rw1l, rw1l, mask
    srliadd rw3l, rw3l, rw2l, LIMBBITS
    and     rw2l, rw2l, mask
    srliadd rw4l, rw4l, rw3l, LIMBBITS
    and     rw3l, rw3l, mask
.endm

// The macro `STM_RES` stores four result-words, which are in registers `rw00`-
// `rw03`, to array `r` in RAM.

#if   ( MPISE_XLEN == 32 )
.macro STM_RES
    sw      rw0l,  0(rptr)
    sw      rw1l,  4(rptr)
    sw      rw2l,  8(rptr)
    sw      rw3l, 12(rptr)
    addi    rptr, rptr, 16
.endm
#elif ( MPISE_XLEN == 64 )
.macro STM_RES
    sd      rw0l,  0(rptr)
    sd      rw1l,  8(rptr)
    sd      rw2l, 16(rptr)
    sd      rw3l, 24(rptr)
    addi    rptr, rptr, 32
.endm
#endif

.macro CLRACCU
    mv      rw0l, zero
    mv      rw0h, zero
    mv      rw1l, zero
    mv      rw1h, zero
    mv      rw2l, zero
    mv      rw2h, zero
    mv      rw3l, zero
    mv      rw3h, zero
    mv      rw4l, zero
    mv      rw4h, zero
    mv      rw5l, zero
    mv      rw5h, zero
    mv      rw6l, zero
    mv      rw6h, zero
.endm

.macro SHRACCU
    mv      rw0l, rw4l
    mv      rw0h, rw4h
    mv      rw1l, rw5l
    mv      rw1h, rw5h
    mv      rw2l, rw6l
    mv      rw2h, rw6h
    mv      rw3l, zero
    mv      rw3h, zero
    mv      rw4l, zero
    mv      rw4h, zero
    mv      rw5l, zero
    mv      rw5h, zero
    mv      rw6l, zero
    mv      rw6h, zero
.endm

// ============================================================================

// Multiple-precision multiplication using reduced-radix representation
// --------------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 limbs of the
// two operands are processed in each iteration of the inner loop.

.text
.global mpi_mul_4x4rr_ise
.type mpi_mul_4x4rr_ise,%function
.balign 16
mpi_mul_4x4rr_ise:
    PROLOGUE            // push callee-saved registers on stack
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
    LDM_OPA     // load four words of array `a` and put them in
    LDL_OPB     // load two words of array `b` and put them in
    MACL4X2     //
    LDH_OPB     // load two words of array `b` and put them in
    MACH4X2     //
    addi    ictr, ictr,  IMM_INC          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP 
    TOLIMB
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     // 
    sub     aptr, aptr, octr
    bne     octr, len, .LOUTLOOP1  // branch to start of loop if octr != len
    // END OF FIRST OUTER LOOP
    add     aptr, aptr, len        // set aptr to address of a[len}
    add     bptr, bptr, len        // set bptr to address of b[len}
    addi    octr, octr, -IMM_INC        // second outer loop is iterated len-1 times
    // START OF SECOND OUTER LOOP
.LOUTLOOP2: 
    mv      ictr, zero
    sub     aptr, aptr, octr
    // START OF SECOND INNER LOOP
.LINNLOOP2:     // the second inner loop is iterated $octr/16$ times
    LDM_OPA     // load four words of array `a` and put them in
    LDL_OPB     // load two words of array `b` and put them in
    MACL4X2     //
    LDH_OPB     // load two words of array `b` and put them in
    MACH4X2     //
    addi    ictr, ictr,  IMM_INC          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP 
    TOLIMB
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     // 
    add     bptr, bptr, octr
    addi    octr, octr, -IMM_INC
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    TOLIMB
    STM_RES     // store the result-words in array `r` in RAM
    EPILOGUE    // pop callee-saved registers and return
.end

// ============================================================================
