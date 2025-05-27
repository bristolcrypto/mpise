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
#define tmp0 a4
#define tmp1 a5
// Register `mask` holds a (radix-determined) limb-mask
#define mask t0
// Registers `ictr` and `octr` hold loop-counter values
#define ictr t1
#define octr t2
// Registers `aw0`, `bw0` hold limbs of arrays `a`, `b`
#define aw0  t3
#define bw0  t4
// Registers `sw0` and `sw1` hold the column-sum (accu)
#define sw0  t5
#define sw1  t6


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


// The macro `LDW_OPA` loads a limb of array `a` from RAM and puts it in
// register `ajw`. The address in `aptr` is incremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPA ajw:req
    XLOAD   \ajw, 0(aptr)
    addi    aptr, aptr, XBYTES
.endm


// The macro `LDM_OPB` loads a limb of array `b` from RAM and puts it in
// register `bkw`. The address in `aptr` is decremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPB bkw:req
    addi    bptr, bptr, -XBYTES
    XLOAD   \bkw, 0(bptr)
 .endm


// The macro `TOLIMB` converts the word `aw0` to a limb of length `LIMBBITS`
// (determined by `RADIX`) and puts it in `rw0`.

.macro TOLIMB rw0:req, aw0:req
    and     \rw0, \aw0, mask
.endm


// The macro `STM_RES` stores a result-limb, which is in register `riw`, to
// array `r` in RAM. The address in `rptr` is incremented by 4 bytes on RV32
// and 8 bytes on RV64.

.macro STW_RES riw:req
    XSTORE  \riw, 0(rptr)
    addi    rptr, rptr, XBYTES
.endm


// The macro `CLRACCU` sets the double-length accumulator `ahi:alo` to 0.

.macro CLRACCU ahi:req, alo:req
    mv      \ahi, zero
    mv      \alo, zero
.endm


// The macro `SHRACCU` shifts the double-length accumulator `ahi:alo` to the
// right by one limb.

.macro SHRACCU ahi:req, alo:req
    srli    \alo, \alo, LIMBBITS
    slli    tmp0, \ahi, (MPISE_XLEN-LIMBBITS)
    xor     \alo, \alo, tmp0
    srli    \ahi, \ahi, LIMBBITS
.endm


// Multiple-precision multiplication using reduced-radix representation
// --------------------------------------------------------------------
// Conventional operand-scanning method where a single limb of the two operands
// is processed in each iteration of the inner loop.

.text
.global mpi_mul_1x1rr_isa_asm
.type mpi_mul_1x1rr_isa_asm,%function
// .balign 16
mpi_mul_1x1rr_isa_asm:
    li      mask, LIMBMASK          // content of `mask` depends on LIMBBITS
    CLRACCU sw1, sw0                // set accu-registers to 0
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
    MACC1X1 sw1, sw0, aw0, bw0      // MAC operation: accu = accu + a[j]*b[k]
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES$
    bltu    ictr, octr, .LINNLOOP1  // branch to start of loop if ictr < octr
    // --- END OF 1ST INNER LOOP ---
    TOLIMB  tmp0, sw0               // convert lower accu-word into a limb
    STW_RES tmp0                    // store limb in `sw0` to r[i] via `rptr`
    SHRACCU sw1, sw0                // shift accu right by one limb
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
    MACC1X1 sw1, sw0, aw0, bw0      // MAC operation: accu = accu + a[j]*b[k]
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES$
    bltu    ictr, octr, .LINNLOOP2  // branch to start of loop if ictr < octr
    // --- END OF 2ND INNER LOOP ---
    TOLIMB  tmp0, sw0               // convert lower accu-word into a limb
    STW_RES tmp0                    // store limb in `sw0` to r[i] via `rptr`
    SHRACCU sw1, sw0                // shift accu right by one limb
    add     bptr, bptr, octr        // set `bptr` to address of b[len]
    addi    octr, octr, -XBYTES     // decrement o-loop counter by $XBYTES$
    bltu    zero, octr, .LOUTLOOP2  // branch to start of loop if 0 < octr
    // --- END OF 2ND OUTER LOOP ---
    TOLIMB  sw1, sw0                // convert lower accu-word into a limb
    STW_RES sw0                     // store limb in `sw0` to r[i] via `rptr`
    ret


.end
