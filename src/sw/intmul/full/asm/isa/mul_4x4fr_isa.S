#if   ( MPISE_XLEN == 32 )
#define XBYTES 4
#define XLOG2B 2
#define XLOAD  lw
#define XSTORE sw
#elif ( MPISE_XLEN == 64 )
#define XBYTES 8
#define XLOG2B 3
#define XLOAD  ld
#define XSTORE sd
#endif

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Register `len` holds the word-length of the arrays
#define len  a3
// Register `blen` holds the byte-length of the arrays
#define blen a3
// Registers `tmp0` and `tmp1` hold intermediate values
#define tmp0 t0
#define tmp1 t1
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t2
#define octr t3
// Register-set `AREGS` holds four words of operand `a`
#define AREGS a7,a6,a5,a4
// Register-set `BREGS` holds four words of operand `b`
#define BREGS s3,s2,s1,s0
// Register-set `SREGS` holds nine words of accumulator
#define SREGS t6,t5,t4,s9,s8,s7,s6,s5,s4


// The macro `MACC1X1` multiplies the word `ajw` by `bkw` and adds the double-
// length product to the triple-length accumulator `rex:rhi:rlo`.

.macro MACC1X1 rex:req, rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   tmp1, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
    sltu    tmp1, \rhi, tmp1
    add     \rex, \rex, tmp1
.endm


// The macro `MACC4X4` multiplies the four words `aw3`-`aw0` by `bw3`-`bw0` and
// adds the 16 products to the nine-word accumulator `sw8`-`sw0`.

.macro MACC4X4 sw8:req, sw7:req, sw6:req, sw5:req, sw4:req, sw3:req, sw2:req, \
      sw1:req, sw0:req, aw3:req, aw2:req, aw1:req, aw0:req, bw3:req, bw2:req, \
      bw1:req, bw0:req
    MACC1X1 \sw2, \sw1, \sw0, \aw0, \bw0
    MACC1X1 \sw3, \sw2, \sw1, \aw0, \bw1
    MACC1X1 \sw3, \sw2, \sw1, \aw1, \bw0
    MACC1X1 \sw4, \sw3, \sw2, \aw0, \bw2
    MACC1X1 \sw4, \sw3, \sw2, \aw1, \bw1
    MACC1X1 \sw4, \sw3, \sw2, \aw2, \bw0
    MACC1X1 \sw5, \sw4, \sw3, \aw0, \bw3
    MACC1X1 \sw5, \sw4, \sw3, \aw1, \bw2
    MACC1X1 \sw5, \sw4, \sw3, \aw2, \bw1
    MACC1X1 \sw5, \sw4, \sw3, \aw3, \bw0
    MACC1X1 \sw6, \sw5, \sw4, \aw1, \bw3
    MACC1X1 \sw6, \sw5, \sw4, \aw2, \bw2
    MACC1X1 \sw6, \sw5, \sw4, \aw3, \bw1
    MACC1X1 \sw7, \sw6, \sw5, \aw2, \bw3
    MACC1X1 \sw7, \sw6, \sw5, \aw3, \bw2
    MACC1X1 \sw8, \sw7, \sw6, \aw3, \bw3
.endm


// The macro `PROLOGUE` pushes 10 callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -10*XBYTES
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
.endm


// The macro `EPILOGUE` pops 10 callee-saved registers from the stack and
// returns to the caller.

.macro EPILOGUE
    XLOAD   s0, 0*XBYTES(sp)
    XLOAD   s1, 1*XBYTES(sp)
    XLOAD   s2, 2*XBYTES(sp)
    XLOAD   s3, 3*XBYTES(sp)
    XLOAD   s4, 4*XBYTES(sp)
    XLOAD   s5, 5*XBYTES(sp)
    XLOAD   s6, 6*XBYTES(sp)
    XLOAD   s7, 7*XBYTES(sp)
    XLOAD   s8, 8*XBYTES(sp)
    XLOAD   s9, 9*XBYTES(sp)
    addi    sp, sp, 10*XBYTES
.endm


// The macro `LDM_OPA` loads four words of array `a` from RAM and puts them in
// registers `aw3`-`aw0`.

.macro LDM_OPA aw3:req, aw2:req, aw1:req, aw0:req
    XLOAD   \aw0, 0*XBYTES(aptr)
    XLOAD   \aw1, 1*XBYTES(aptr)
    XLOAD   \aw2, 2*XBYTES(aptr)
    XLOAD   \aw3, 3*XBYTES(aptr)
    addi    aptr, aptr, 4*XBYTES
.endm


// The macro `LDM_OPB` loads four words of array `b` from RAM and puts them in
// registers `bw3`-`bw0`.

.macro LDM_OPB bw3:req, bw2:req, bw1:req, bw0:req 
    XLOAD   \bw3, -1*XBYTES(bptr)
    XLOAD   \bw2, -2*XBYTES(bptr)
    XLOAD   \bw1, -3*XBYTES(bptr)
    XLOAD   \bw0, -4*XBYTES(bptr)
    addi    bptr, bptr, -4*XBYTES
.endm


// The macro `STM_RES` stores four result-words, which are in registers `sw0`-
// `sw3`, to array `r` in RAM.

.macro STM_RES sw8:req, sw7:req, sw6:req, sw5:req, sw4:req, sw3:req, sw2:req, \
      sw1:req, sw0:req
    XSTORE  \sw0, 0*XBYTES(rptr)
    XSTORE  \sw1, 1*XBYTES(rptr)
    XSTORE  \sw2, 2*XBYTES(rptr)
    XSTORE  \sw3, 3*XBYTES(rptr)
    addi    rptr, rptr, 4*XBYTES
.endm


// The macro `CLRACCU` sets the nine-word accumulator `sw8`-`sw0` to 0.

.macro CLRACCU sw8:req, sw7:req, sw6:req, sw5:req, sw4:req, sw3:req, sw2:req, \
      sw1:req, sw0:req
    mv      \sw0, zero
    mv      \sw1, zero
    mv      \sw2, zero
    mv      \sw3, zero
    mv      \sw4, zero
    mv      \sw5, zero
    mv      \sw6, zero
    mv      \sw7, zero
    mv      \sw8, zero
.endm


// The macro `SHRACCU` shifts the nine-word accumulator `sw8`-`sw0` to the
// right by one word.

.macro SHRACCU sw8:req, sw7:req, sw6:req, sw5:req, sw4:req, sw3:req, sw2:req, \
      sw1:req, sw0:req
    mv      \sw0, \sw4
    mv      \sw1, \sw5
    mv      \sw2, \sw6
    mv      \sw3, \sw7
    mv      \sw4, \sw8
    mv      \sw5, zero
    mv      \sw6, zero
    mv      \sw7, zero
    mv      \sw8, zero
.endm


// Multiple-precision multiplication using full-radix representation
// -----------------------------------------------------------------
// Operand-scanning method combined with hybrid technique where 4 words of the
// two operands are processed in each iteration of the inner loop.

.text
.global mpi_mul_4x4fr_isa
.type mpi_mul_4x4fr_isa,%function
// .balign 16
mpi_mul_4x4fr_isa:
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
    LDM_OPB BREGS                   // load b[k-3:k] via `bptr` to set `BREGS`
    LDM_OPA AREGS                   // load a[j:j+3] via `aptr` to set `AREGS`
    MACC4X4 SREGS, AREGS, BREGS     // MAC operation: SREGS += AREGS*BREGS
    addi    ictr, ictr, 4*XBYTES    // increment i-loop counter by $4*XBYTES$
    bltu    ictr, octr, .LINNLOOP1  // branch to start of loop if ictr < octr
    // --- END OF 1ST INNER LOOP ---
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
    LDM_OPB BREGS                   // load b[k-3:k] via `bptr` to set `BREGS`
    LDM_OPA AREGS                   // load a[j:j+3] via `aptr` to set `AREGS`
    MACC4X4 SREGS, AREGS, BREGS     // MAC operation: SREGS += AREGS*BREGS
    addi    ictr, ictr, 4*XBYTES    // increment i-loop counter by $4*XBYTES$
    bltu    ictr, octr, .LINNLOOP2  // branch to start of loop if ictr < octr
    // --- END OF 2ND INNER LOOP ---
    STM_RES SREGS                   // store set `SREGS` to r[i:i+3] via `rptr`
    SHRACCU SREGS                   // shift accu right by four words
    add     bptr, bptr, octr        // set `bptr` to address of b[len]
    addi    octr, octr, -4*XBYTES   // decrement o-loop counter by $4*XBYTES$
    bltu    zero, octr, .LOUTLOOP2  // branch to start of loop if 0 < octr
    // --- END OF 2ND OUTER LOOP ---
    STM_RES SREGS                   // store set `SREGS` to r[i:i+3] via `rptr`
    EPILOGUE                        // pop callee-saved registers from stack
    ret


.end
