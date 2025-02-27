#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 60
#endif

#define LIMBMASK (0xFFFFFFFFFFFFFFFFULL >> (64 - (LIMBBITS)))


// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the length of operands `a`, `b`
#define len  a3
// Registers `tmp0` and `tmp1` hold intermediate values
#define tmp0 t0
#define tmp1 t1
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t2
#define octr t3
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
#define rw5l t4
#define rw5h t5
#define rw6l t6
#define rw6h ra


// The macro `MACC1X1` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the double-length accumulator `rhi|rlo`. The two words
// `tlo` and `thi` hold temporary results.

.macro MACC1X1 rhi:req, rlo:req, aiw:req, bjw:req, tlo:req, thi:req
    mul     \tlo, \aiw, \bjw
    mulhu   \thi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
    add     \rhi, \rhi, \thi
.endm


.macro MACL4x2
    MACC1X1 rw0h, rw0l, aw00, bw00, tmp1, tmp0
    MACC1X1 rw1h, rw1l, aw00, bw01, tmp1, tmp0
    MACC1X1 rw1h, rw1l, aw01, bw00, tmp1, tmp0
    MACC1X1 rw2h, rw2l, aw01, bw01, tmp1, tmp0
    MACC1X1 rw2h, rw2l, aw02, bw00, tmp1, tmp0
    MACC1X1 rw3h, rw3l, aw02, bw01, tmp1, tmp0
    MACC1X1 rw3h, rw3l, aw03, bw00, tmp1, tmp0
    MACC1X1 rw4h, rw4l, aw03, bw01, tmp1, tmp0
.endm


.macro MACH4x2
    MACC1X1 rw2h, rw2l, aw00, bw02, tmp1, tmp0
    MACC1X1 rw3h, rw3l, aw00, bw03, tmp1, tmp0
    MACC1X1 rw3h, rw3l, aw01, bw02, tmp1, tmp0
    MACC1X1 rw4h, rw4l, aw01, bw03, tmp1, tmp0
    MACC1X1 rw4h, rw4l, aw02, bw02, tmp1, tmp0
    MACC1X1 rw5h, rw5l, aw02, bw03, tmp1, tmp0
    MACC1X1 rw5h, rw5l, aw03, bw02, tmp1, tmp0
    MACC1X1 rw6h, rw6l, aw03, bw03, tmp1, tmp0
.endm


// The macro `PROLOGUE` pushes 13 callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -104
    sd      s0, (sp)
    sd      s1, 8(sp)
    sd      s2, 16(sp)
    sd      s3, 24(sp)
    sd      s4, 32(sp)
    sd      s5, 40(sp)
    sd      s6, 48(sp)
    sd      s7, 56(sp)
    sd      s8, 64(sp)
    sd      s9, 72(sp)
    sd      s10, 80(sp)
    sd      s11, 88(sp)
    sd      ra, 96(sp)
.endm


// The macro `EPILOGUE` pops 13 callee-saved registers from the stack and
// returns to the caller.

.macro EPILOGUE
    ld      ra, 96(sp)
    ld      s11, 88(sp)
    ld      s10, 80(sp)
    ld      s9, 72(sp)
    ld      s8, 64(sp)
    ld      s7, 56(sp)
    ld      s6, 48(sp)
    ld      s5, 40(sp)
    ld      s4, 32(sp)
    ld      s3, 24(sp)
    ld      s2, 16(sp)
    ld      s1, 8(sp)
    ld      s0, (sp)
    addi    sp, sp, 104
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


// The macro `LDL_OPB` loads two words of array `b` from RAM and puts then in
// registers `bw00`-`bw01`.

.macro LDL_OPB
    ld      bw01, -24(bptr)
    ld      bw00, -32(bptr)
.endm


// The macro `LDH_OPB` loads two words of array `b` from RAM and puts then in
// registers `bw02`-`bw03`.

.macro LDH_OPB
    ld      bw03, -8(bptr)
    ld      bw02, -16(bptr)
    addi    bptr, bptr, -32
.endm


// convert lower half of accu to 60-bit limbs

.macro TOLIMB
    srli   tmp0, rw0l, LIMBBITS
    slli   tmp1, rw0h, (64-LIMBBITS)
    xor    tmp0, tmp0, tmp1
    srli   tmp1, rw0h, LIMBBITS
    add    rw1l, rw1l, tmp0
    sltu   tmp0, rw1l, tmp0
    add    tmp1, tmp1, tmp0
    add    rw1h, rw1h, tmp1
    srli   tmp0, rw1l, LIMBBITS
    slli   tmp1, rw1h, (64-LIMBBITS)
    xor    tmp0, tmp0, tmp1
    srli   tmp1, rw1h, LIMBBITS
    add    rw2l, rw2l, tmp0
    sltu   tmp0, rw2l, tmp0
    add    tmp1, tmp1, tmp0
    add    rw2h, rw2h, tmp1
    srli   tmp0, rw2l, LIMBBITS
    slli   tmp1, rw2h, (64-LIMBBITS)
    xor    tmp0, tmp0, tmp1
    srli   tmp1, rw2h, LIMBBITS
    add    rw3l, rw3l, tmp0
    sltu   tmp0, rw3l, tmp0
    add    tmp1, tmp1, tmp0
    add    rw3h, rw3h, tmp1
    srli   tmp0, rw3l, LIMBBITS
    slli   tmp1, rw3h, (64-LIMBBITS)
    xor    tmp0, tmp0, tmp1
    srli   tmp1, rw3h, LIMBBITS
    add    rw4l, rw4l, tmp0
    sltu   tmp0, rw4l, tmp0
    add    tmp1, tmp1, tmp0
    add    rw4h, rw4h, tmp1
    li     tmp0, LIMBMASK
    and    rw0l, rw0l, tmp0
    and    rw1l, rw1l, tmp0
    and    rw2l, rw2l, tmp0
    and    rw3l, rw3l, tmp0
.endm


// The macro `STM_RES` stores four result-words, which are in registers `rw00`-
// `rw03`, to array `r` in RAM.

.macro STM_RES
    sd      rw0l, 0(rptr)
    sd      rw1l, 8(rptr)
    sd      rw2l, 16(rptr)
    sd      rw3l, 24(rptr)
    addi    rptr, rptr, 32
.endm


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


// Multiple-precision multiplication using reduced-radix representation
// --------------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 limbs of the
// two operands are processed in each iteration of the inner loop.

.text
.global mpi_mul_4x4rr_isa
.type mpi_mul_4x4rr_isa,%function
.balign 16
mpi_mul_4x4rr_isa:
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
    LDL_OPB     // load two words of array `b` and put them in
    MACL4X2     //
    LDH_OPB     // load two words of array `b` and put them in
    MACH4X2     //
    addi    ictr, ictr, 32          // increment inner-loop counter
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
    addi    octr, octr, -32        // second outer loop is iterated len-1 times
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
    addi    ictr, ictr, 32          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP
    TOLIMB
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     //
    add     bptr, bptr, octr
    addi    octr, octr, -32
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    TOLIMB
    STM_RES     // store the result-words in array `r` in RAM
    EPILOGUE    // pop callee-saved registers and return


.end

