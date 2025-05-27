#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 51
#endif

#if   ( MPISE_XLEN == 32 )
#define XBYTES 4
#define XLOG2B 2
#define ALL1WORD 0xFFFFFFFFUL
#define XLOAD  lw
#define XSTORE sw
#elif ( MPISE_XLEN == 64 )
#define XBYTES 8
#define XLOG2B 3
#define ALL1WORD 0xFFFFFFFFFFFFFFFFULL
#define XLOAD  ld
#define XSTORE sd
#endif

#define LIMBMASK (ALL1WORD >> (MPISE_XLEN - LIMBBITS))

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the limb-length of the arrays
#define len  a3
// Register `blen` holds the byte-length of the arrays
#define blen a3
// Registers `tmp0` and `tmp1` hold intermediate values
#define tmp0 t0
#define tmp1 t1
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t2
#define octr t3
// Register-set `AREGS` holds four limbs of operand `a`
#define AREGS a7,a6,a5,a4
// Register-set `BREGS` holds four limbs of operand `b`
#define BREGS s1,s0,s1,s0
// Register-set `SREGS` holds 14 words of a accumulator
#define SREGS ra,t6,t5,t4,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2


// The macro `MACC1X1` multiplies the limb `ajw` by `bkw` and adds the double-
// length product to the double-length accumulator `rhi:rlo`.

.macro MACC1X1 rhi:req, rlo:req, ajw:req, bkw:req
    mul     tmp0, \ajw, \bkw
    mulhu   tmp1, \ajw, \bkw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
.endm


// The macro `MACL4X2` multiplies the four limbs `aw3`-`aw0` by the lower two
// of the four limbs `bw3`-`bw0` and adds the eight products to the seven
// double-length words of the accumulator (i.e., `s0h:s0l` to `s6h:s6l`)

.macro MACL4X2 s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req, aw3:req, \
      aw2:req, aw1:req, aw0:req, bw3:req, bw2:req, bw1:req, bw0:req
    MACC1X1 \s0h, \s0l, \aw0, \bw0
    MACC1X1 \s1h, \s1l, \aw0, \bw1
    MACC1X1 \s1h, \s1l, \aw1, \bw0
    MACC1X1 \s2h, \s2l, \aw1, \bw1
    MACC1X1 \s2h, \s2l, \aw2, \bw0
    MACC1X1 \s3h, \s3l, \aw2, \bw1
    MACC1X1 \s3h, \s3l, \aw3, \bw0
    MACC1X1 \s4h, \s4l, \aw3, \bw1
.endm


// The macro `MACL4X2` multiplies the four limbs `aw3`-`aw0` by the higher two
// of the four limbs `bw3`-`bw0` and adds the eight products to the seven
// double-length words of the accumulator (i.e., `s0h:s0l` to `s6h:s6l`)

.macro MACH4X2 s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req, aw3:req, \
      aw2:req, aw1:req, aw0:req, bw3:req, bw2:req, bw1:req, bw0:req
    MACC1X1 \s2h, \s2l, \aw0, \bw2
    MACC1X1 \s3h, \s3l, \aw0, \bw3
    MACC1X1 \s3h, \s3l, \aw1, \bw2
    MACC1X1 \s4h, \s4l, \aw1, \bw3
    MACC1X1 \s4h, \s4l, \aw2, \bw2
    MACC1X1 \s5h, \s5l, \aw2, \bw3
    MACC1X1 \s5h, \s5l, \aw3, \bw2
    MACC1X1 \s6h, \s6l, \aw3, \bw3
.endm


// The macro `PROLOGUE` pushes 13 callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -13*XBYTES
    XSTORE  s0, 0*XBYTES(sp)
    XSTORE  s1, 1*XBYTES(sp)
    XSTORE  s2, 2*XBYTES(sp)
    XSTORE  s3, 3*XBYTES(sp)
    XSTORE  s4, 4*XBYTES(sp)
    XSTORE  s5, 5*XBYTES(sp)
    XSTORE  s6, 6*XBYTES(sp)
    XSTORE  s7, 7*XBYTES(sp)
    XSTORE  s8, 8*XBYTES(sp)
    XSTORE  s9, 9*XBYTES(sp)
    XSTORE  s10, 10*XBYTES(sp)
    XSTORE  s11, 11*XBYTES(sp)
    XSTORE  ra , 12*XBYTES(sp)
.endm


// The macro `EPILOGUE` pops 13 callee-saved registers from the stack.

.macro EPILOGUE
    XLOAD   ra , 12*XBYTES(sp)
    XLOAD   s11, 11*XBYTES(sp)
    XLOAD   s10, 10*XBYTES(sp)
    XLOAD   s9, 9*XBYTES(sp)
    XLOAD   s8, 8*XBYTES(sp)
    XLOAD   s7, 7*XBYTES(sp)
    XLOAD   s6, 6*XBYTES(sp)
    XLOAD   s5, 5*XBYTES(sp)
    XLOAD   s4, 4*XBYTES(sp)
    XLOAD   s3, 3*XBYTES(sp)
    XLOAD   s2, 2*XBYTES(sp)
    XLOAD   s1, 1*XBYTES(sp)
    XLOAD   s0, 0*XBYTES(sp)
    addi    sp, sp, 13*XBYTES
.endm


// The macro `LDM_OPA` loads four limbss of array `a` from RAM and puts them in
// registers `aw3`-`aw0`.

.macro LDM_OPA aw3:req, aw2:req, aw1:req, aw0:req
    XLOAD   \aw0, 0*XBYTES(aptr)
    XLOAD   \aw1, 1*XBYTES(aptr)
    XLOAD   \aw2, 2*XBYTES(aptr)
    XLOAD   \aw3, 3*XBYTES(aptr)
    addi    aptr, aptr, 4*XBYTES
.endm


// The macro `LDL_OPB` loads two limbs of array `b` from RAM and puts them in
// registers `bw1`-`bw0`.

.macro LDL_OPB bw3:req, bw2:req, bw1:req, bw0:req
    XLOAD   \bw1, -3*XBYTES(bptr)
    XLOAD   \bw0, -4*XBYTES(bptr)
.endm


// The macro `LDH_OPB` loads two limbs of array `b` from RAM and puts them in
// registers `bw3`-`bw2`.

.macro LDH_OPB bw3:req, bw2:req, bw1:req, bw0:req
    XLOAD   \bw3,  -1*XBYTES(bptr)
    XLOAD   \bw2,  -2*XBYTES(bptr)
    addi    bptr, bptr, -4*XBYTES
.endm


// The macro `SRLIACC` shifts the double-length operand `ahi:alo` to the right
// by `LIMBBITS` bits (determined by `RADIX`) and adds (i.e., accumulates) the
// shifted operand to the `shi:slo` register-pair.

.macro SRLIACC rhi:req, rlo:req, ahi:req, alo:req
    srli    tmp0, \alo, LIMBBITS
    slli    tmp1, \ahi, (MPISE_XLEN-LIMBBITS)
    xor     tmp0, tmp0, tmp1
    srli    tmp1, \ahi, LIMBBITS
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
.endm


// The macro `TOLIMBS` converts the lower words of the four least-significant
// double-length words of the accumulator (i.e., `s3l`, `s2l`, `s1l`, `s0l`) to
// four limbs of length `LIMBBITS` (determined by `RADIX`).

.macro TOLIMBS s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req
    SRLIACC \s1h, \s1l, \s0h, \s0l  // S1 = S1 + (S0 >> LIMBBITS)
    SRLIACC \s2h, \s2l, \s1h, \s1l  // S2 = S2 + (S1 >> LIMBBITS)
    SRLIACC \s3h, \s3l, \s2h, \s2l  // S3 = S3 + (S2 >> LIMBBITS)
    SRLIACC \s4h, \s4l, \s3h, \s3l  // S4 = S4 + (S3 >> LIMBBITS)
    li      tmp0, LIMBMASK
    and     \s0l, \s0l, tmp0
    and     \s1l, \s1l, tmp0
    and     \s2l, \s2l, tmp0
    and     \s3l, \s3l, tmp0
.endm


// The macro `STM_RES` stores four result-limbs, which are in registers `s3l`,
// `s2l`, `s1l`, and `s0l`, to array `r` in RAM.

.macro STM_RES s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req
    XSTORE  \s0l, 0*XBYTES(rptr)
    XSTORE  \s1l, 1*XBYTES(rptr)
    XSTORE  \s2l, 2*XBYTES(rptr)
    XSTORE  \s3l, 3*XBYTES(rptr)
    addi    rptr, rptr, 4*XBYTES
.endm


// The macro `CLRACCU` sets the seven double-length words of the accumulator
// (i.e., `s0h:s0l` to `s6h:s6l`) to 0.

.macro CLRACCU s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req
    mv      \s0l, zero
    mv      \s0h, zero
    mv      \s1l, zero
    mv      \s1h, zero
    mv      \s2l, zero
    mv      \s2h, zero
    mv      \s3l, zero
    mv      \s3h, zero
    mv      \s4l, zero
    mv      \s4h, zero
    mv      \s5l, zero
    mv      \s5h, zero
    mv      \s6l, zero
    mv      \s6h, zero
.endm


// The macro `SHRACCU` shifts the seven double-length words of the accumulator
// (i.e., `s0h:s0l` to `s6h:s6l`) by four words to the right.

.macro SHRACCU s6h:req, s6l:req, s5h:req, s5l:req, s4h:req, s4l:req, s3h:req, \
      s3l:req, s2h:req, s2l:req, s1h:req, s1l:req, s0h:req, s0l:req
    mv      \s0l, \s4l
    mv      \s0h, \s4h
    mv      \s1l, \s5l
    mv      \s1h, \s5h
    mv      \s2l, \s6l
    mv      \s2h, \s6h
    mv      \s3l, zero
    mv      \s3h, zero
    mv      \s4l, zero
    mv      \s4h, zero
    mv      \s5l, zero
    mv      \s5h, zero
    mv      \s6l, zero
    mv      \s6h, zero
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
    PROLOGUE                        // push callee-saved registers on stack
    CLRACCU SREGS                   // set accu-registers to 0
    slli    blen, len, XLOG2B       // set `blen` to byte-length of operands
    mv      octr, zero              // initialize outer-loop counter with 0
    // -- START OF 1ST OUTER LOOP --
.LOUTLOOP1:                         // 1st o-loop is iterated $len/4$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    add     octr, octr, 4*XBYTES    // increment o-loop counter by $4*XBYTES$
    add     bptr, bptr, octr        // set `bptr` to address of b[i+4]
    // -- START OF 1ST INNER LOOP --
.LINNLOOP1:                         // i-loop is iterated $octr/4*XBYTES$ times
    LDM_OPA AREGS                   // load a[j:j+3] via `aptr` to set `AREGS`
    LDL_OPB BREGS                   // load b[k-3:k-2] via `bptr` to `BREGS`
    MACL4X2 SREGS, AREGS, BREGS     // MAC-LO operation: SREGS += AREGS*BREGS
    LDH_OPB BREGS                   // load b[k-1:k] via `bptr` to set `BREGS`
    MACH4X2 SREGS, AREGS, BREGS     // MAC-HI operation: SREGS += AREGS*BREGS
    addi    ictr, ictr, 4*XBYTES    // increment i-loop counter by $4*XBYTES$
    bltu    ictr, octr, .LINNLOOP1  // branch to start of loop if ictr < octr
    // --- END OF 1ST INNER LOOP ---
    TOLIMBS SREGS                   // convert four lower accu-words into limbs
    STM_RES SREGS                   // store set `SREGS` to r[i:i+3] via `rptr`
    SHRACCU SREGS                   // shift accu right by four words
    sub     aptr, aptr, octr        // set `aptr` to address of a[0]
    bltu    octr, blen, .LOUTLOOP1  // branch to start of loop if octr < blen
    // --- END OF 1ST OUTER LOOP ---
    add     aptr, aptr, blen        // set `aptr` to address of a[len]
    add     bptr, bptr, blen        // set `bptr` to address of b[len]
    addi    octr, octr, -4*XBYTES   // set `octr` to $(len-4)*XBYTES$
    // -- START OF 2ND OUTER LOOP --
.LOUTLOOP2:                         // 2nd o-loop is iterated $len-1$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    sub     aptr, aptr, octr        // set `aptr` to address of a[i-(len-4)]
    // -- START OF 2ND INNER LOOP --
.LINNLOOP2:                         // i-loop is iterated $octr/4*XBYTES$ times
    LDM_OPA AREGS                   // load a[j:j+3] via `aptr` to set `AREGS`
    LDL_OPB BREGS                   // load b[k-3:k-2] via `bptr` to `BREGS`
    MACL4X2 SREGS, AREGS, BREGS     // MAC-LO operation: SREGS += AREGS*BREGS
    LDH_OPB BREGS                   // load b[k-1:k] via `bptr` to set `BREGS`
    MACH4X2 SREGS, AREGS, BREGS     // MAC-HI operation: SREGS += AREGS*BREGS
    addi    ictr, ictr, 4*XBYTES    // increment i-loop counter by $4*XBYTES$
    bltu    ictr, octr, .LINNLOOP2  // branch to start of loop if ictr < octr
    // --- END OF 2ND INNER LOOP ---
    TOLIMBS SREGS                   // convert four lower accu-words into limbs
    STM_RES SREGS                   // store set `SREGS` to r[i:i+3] via `rptr`
    SHRACCU SREGS                   // shift accu right by four words
    add     bptr, bptr, octr        // set `bptr` to address of b[len]
    addi    octr, octr, -4*XBYTES   // decrement o-loop counter by $4*XBYTES$
    bltu    zero, octr, .LOUTLOOP2  // branch to start of loop if 0 < octr
    // --- END OF 2ND OUTER LOOP ---
    TOLIMBS SREGS                   // convert four lower accu-words into limbs
    STM_RES SREGS                   // store set `SREGS` to r[i:i+3] via `rptr`
    EPILOGUE                        // pop callee-saved registers from stack
    ret


.end
