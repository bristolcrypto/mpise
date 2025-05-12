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
#define tmp0 a4
#define tmp1 a5
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t0
#define octr t1
// Registers `aw0`, `bw0` hold words of arrays `a`, `b`
#define aw0  t2
#define bw0  t3
// Registers `sw0` t0 `sw2` hold the column-sum (accu)
#define sw0  t4
#define sw1  t5
#define sw2  t6


// The macro `MACC1X1` multiplies the word `ajw` by `bkw` and adds the double-
// length product to the triple-length accumulator `rex:rhi:rlo`.

.macro MACC1X1 rex:req, rhi:req, rlo:req, ajw:req, bkw:req
    mul     tmp0, \ajw, \bkw
    mulhu   tmp1, \ajw, \bkw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
    sltu    tmp1, \rhi, tmp1
    add     \rex, \rex, tmp1
.endm


// The macro `LDW_OPA` loads a word of array `a` from RAM and puts it in
// register `ajw`. The address in `aptr` is incremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPA ajw:req
    XLOAD   \ajw, 0(aptr)
    addi    aptr, aptr, XBYTES
.endm


// The macro `LDM_OPB` loads a word of array `b` from RAM and puts it in
// register `bkw`. The address in `aptr` is decremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPB bkw:req
    addi    bptr, bptr, -XBYTES
    XLOAD   \bkw, 0(bptr)
.endm


// The macro `STM_RES` stores a result-word, which is in register `riw`, to
// array `r` in RAM. The address in `rptr` is incremented by 4 bytes on RV32
// and 8 bytes on RV64.

.macro STW_RES riw:req
    XSTORE  \riw, 0(rptr)
    addi    rptr, rptr, XBYTES
.endm


// The macro `CLRACCU` sets the triple-length accumulator `aex:ahi:alo` to 0.

.macro CLRACCU aex: req, ahi:req, alo:req
    mv      \alo, zero
    mv      \ahi, zero
    mv      \aex, zero
.endm


// The macro `SHRACCU` shifts the triple-length accumulator `rex:ahi:alo` to
// the right by one word.

.macro SHRACCU aex:req, ahi:req, alo:req
    mv      \alo, \ahi
    mv      \ahi, \aex
    mv      \aex, zero
.endm


// Multiple-precision multiplication using full-radix representation
// -----------------------------------------------------------------
// Conventional operand-scanning method where a single word of the two operands
// is processed in each iteration of the inner loop.

.text
.global mpi_mul_1x1fr_isa_asm
.type mpi_mul_1x1fr_isa_asm,%function
// .balign 16
mpi_mul_1x1fr_isa_asm:
    CLRACCU sw2, sw1, sw0           // set accu-registers to 0
    slli    blen, len, XLOG2B       // set `blen` to byte-length of operands
    mv      octr, zero              // initialize outer-loop counter with 0
    // -- START OF 1ST OUTER LOOP --
.LOUTLOOP1:                         // 1st o-loop is iterated $len$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    add     octr, octr, XBYTES      // increment o-loop counter by $XBYTES$
    add     bptr, bptr, octr        // set `bptr` to address of b[i+1]
    // -- START OF 1ST INNER LOOP --
.LINNLOOP1:                         // i-loop is iterated $octr/XBYTES$ times
    LDW_OPB bw0                     // load b[k] via `bptr` to register `bw0`
    LDW_OPA aw0                     // load a[j] via `aptr` to register `aw0`
    MACC1X1 sw2, sw1, sw0, aw0, bw0 // MAC operation: accu = accu + a[j]*b[k]
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES$
    bltu    ictr, octr, .LINNLOOP1  // branch to start of loop if ictr < octr
    // --- END OF 1ST INNER LOOP ---
    STW_RES sw0                     // store word in `sw0` to r[i] via `rptr`
    SHRACCU sw2, sw1, sw0           // shift accu right by one word
    sub     aptr, aptr, octr        // set `aptr` to address of a[0]
    bltu    octr, blen, .LOUTLOOP1  // branch to start of loop if octr < blen
    // --- END OF 1ST OUTER LOOP ---
    add     aptr, aptr, blen        // set `aptr` to address of a[len]
    add     bptr, bptr, blen        // set `bptr` to address of b[len]
    addi    octr, octr, -XBYTES     // set `octr` to $(len-1)*XBYTES$
    // -- START OF 2ND OUTER LOOP --
.LOUTLOOP2:                         // 2nd o-loop is iterated $len-1$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    sub     aptr, aptr, octr        // set `aptr` to address of a[i-(len-1)]
    // -- START OF 2ND INNER LOOP --
.LINNLOOP2:                         // i-loop is iterated $octr/XBYTES$ times
    LDW_OPB bw0                     // load b[k] via `bptr` to register `bw0`
    LDW_OPA aw0                     // load a[j] via `aptr` to register `aw0`
    MACC1X1 sw2, sw1, sw0, aw0, bw0 // MAC operation: accu = accu + a[j]*b[k]
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES$
    bltu    ictr, octr, .LINNLOOP2  // branch to start of loop if ictr < octr
    // --- END OF 2ND INNER LOOP ---
    STW_RES sw0                     // store word in `sw0` to r[i] via `rptr`
    SHRACCU sw2, sw1, sw0           // shift accu right by one word
    add     bptr, bptr, octr        // set `bptr` to address of b[len]
    addi    octr, octr, -XBYTES     // decrement o-loop counter by $XBYTES$
    bltu    zero, octr, .LOUTLOOP2  // branch to start of loop if 0 < octr
    // --- END OF 2ND OUTER LOOP ---
    STW_RES sw0                     // store word in `sw0` to r[i] via `rptr`
    ret


.end
