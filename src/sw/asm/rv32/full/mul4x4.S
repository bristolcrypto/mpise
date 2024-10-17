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
#define bw02 s2
#define bw03 s3
// Registers `rw00` to `rw08` hold words of the product
#define rw00 s4
#define rw01 s5
#define rw02 s6
#define rw03 s7
#define rw04 s8
#define rw05 s9
#define rw06 t4
#define rw07 t5
#define rw08 t6






// The macro `MACC1X1` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the triple-length accumulator `rex`:`rhi`:`rlo`. The words
// `tlo` and `thi` hold temporary results.

.macro MACC1X1 rex:req, rhi:req, rlo:req, aiw:req, bjw:req, thi:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \thi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
    add     \rhi, \rhi, \thi
    sltu    \thi, \rhi, \thi
    add     \rex, \rex, \thi
.endm



.macro MACC4x4
    MACC1X1 rw02, rw01, rw00, aw00, bw00, tmp1, tmp0
    MACC1X1 rw03, rw02, rw01, aw00, bw01, tmp1, tmp0
    MACC1X1 rw03, rw02, rw01, aw01, bw00, tmp1, tmp0
    MACC1X1 rw04, rw03, rw02, aw00, bw02, tmp1, tmp0
    MACC1X1 rw04, rw03, rw02, aw01, bw01, tmp1, tmp0
    MACC1X1 rw04, rw03, rw02, aw02, bw00, tmp1, tmp0
    MACC1X1 rw05, rw04, rw03, aw00, bw03, tmp1, tmp0
    MACC1X1 rw05, rw04, rw03, aw01, bw02, tmp1, tmp0
    MACC1X1 rw05, rw04, rw03, aw02, bw01, tmp1, tmp0
    MACC1X1 rw05, rw04, rw03, aw03, bw00, tmp1, tmp0
    MACC1X1 rw06, rw05, rw04, aw01, bw03, tmp1, tmp0
    MACC1X1 rw06, rw05, rw04, aw02, bw02, tmp1, tmp0
    MACC1X1 rw06, rw05, rw04, aw03, bw01, tmp1, tmp0
    MACC1X1 rw07, rw06, rw05, aw02, bw03, tmp1, tmp0
    MACC1X1 rw07, rw06, rw05, aw03, bw02, tmp1, tmp0
    MACC1X1 rw08, rw07, rw06, aw03, bw03, tmp1, tmp0
.endm





// The macro `PROLOGUE` pushes 10 callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -40
    sw      s0, (sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    sw      s3, 12(sp)
    sw      s4, 16(sp)
    sw      s5, 20(sp)
    sw      s6, 24(sp)
    sw      s7, 28(sp)
    sw      s8, 32(sp)
    sw      s9, 36(sp)
.endm


// The macro `EPILOGUE` pops 10 callee-saved registers from the stack and
// returns to the caller.

.macro EPILOGUE
    lw      s0, (sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    lw      s3, 12(sp)
    lw      s4, 16(sp)
    lw      s5, 20(sp)
    lw      s6, 24(sp)
    lw      s7, 28(sp)
    lw      s8, 32(sp)
    lw      s9, 36(sp)
    addi    sp, sp, 40
    ret
.endm


// The macro `LDM_OPA` loads four words of array `a` from RAM and puts then in
// registers `aw00`-`aw03`.

.macro LDM_OPA
    lw      aw00, 0(aptr)
    lw      aw01, 4(aptr)
    lw      aw02, 8(aptr)
    lw      aw03, 12(aptr)
    addi    aptr, aptr, 16
.endm


// The macro `LDM_OPB` loads four words of array `b` from RAM and puts then in
// registers `bw00`-`bw03`.

.macro LDM_OPB
    lw      bw03, -4(bptr)
    lw      bw02, -8(bptr)
    lw      bw01, -12(bptr)
    lw      bw00, -16(bptr)
    addi    bptr, bptr, -16
.endm


// The macro `STM_RES` stores four result-words, which are in registers `rw00`-
// `rw03`, to array `r` in RAM.

.macro STM_RES
    sw      rw00, 0(rptr)
    sw      rw01, 4(rptr)
    sw      rw02, 8(rptr)
    sw      rw03, 12(rptr)
    addi    rptr, rptr, 16
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









.text
.global mul4x4_rv32m
.type mul4x4_rv32m,%function
.balign 16
mul4x4_rv32m:
    PROLOGUE            // push callee-saved registers on stack
    CLRACCU
    slli    len, len, 2
    mv      octr, zero
    // START OF FIRST OUTER LOOP
.LOUTLOOP1: 
    mv      ictr, zero
    add     octr, octr, 16
    add     bptr, bptr, octr
    // START OF FIRST INNER LOOP
.LINNLOOP1:     // the first inner loop is iterated $octr/16$ times
    LDM_OPA     // load four words of array `a` and put them in
    LDM_OPB     // load four words of array `b` and put them in 
    MACC4X4     // 
    addi    ictr, ictr, 16          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP 
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     // 
    sub     aptr, aptr, octr
    bne     octr, len, .LOUTLOOP1  // branch to start of loop if octr != len
    // END OF FIRST OUTER LOOP
    addi    octr, octr, -16
    // START OF SECOND OUTER LOOP
.LOUTLOOP2: 
    mv      ictr, zero
    add     bptr, bptr, octr
    // START OF SECOND INNER LOOP
.LINNLOOP2:     // the second inner loop is iterated $octr/16$ times
    LDM_OPA     // load four words of array `a` and put them in
    LDM_OPB     // load four words of array `b` and put them in 
    MACC4X4     // 
    addi    ictr, ictr, 16          // increment inner-loop counter
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP 
    STM_RES     // store the result-words in array `r` in RAM
    SHRACCU     // 
    sub     aptr, aptr, octr
    addi    octr, octr, -16
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    STM_RES     // store the result-words in array `r` in RAM
    EPILOGUE            // pop callee-saved registers and return


.end
