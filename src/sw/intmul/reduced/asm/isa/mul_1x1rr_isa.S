// ============================================================================

#ifdef RADIX
#define LIMBBITS RADIX
#else  // for testing!
#define LIMBBITS 58
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
// Register `len` holds the length of operands `a`, `b`
#define len  a3
// Registers `tmp0` and `tmp1` hold intermediate values
#define tmp0 a4
#define tmp1 a5
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


// The macro `MACC1X1` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the double-length accumulator `rhi:rlo`. The two words
// `tlo` and `thi` hold temporary results.

.macro MACC1X1 rhi:req, rlo:req, aiw:req, bjw:req, tlo:req, thi:req
    mul     \tlo, \aiw, \bjw
    mulhu   \thi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
    add     \rhi, \rhi, \thi
.endm


// The macro `LDM_OPA` loads a word of array `a` from RAM and puts it in
// register `aw0`. The address in `aptr` is incremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPA
    XLOAD   aw0, 0(aptr)
    addi    aptr, aptr, XBYTES
.endm


// The macro `LDM_OPB` loads a word of array `b` from RAM and puts it in
// register `bw0`. The address in `aptr` is decremented by 4 bytes on RV32 and
// 8 bytes on RV64.

.macro LDW_OPB
    addi    bptr, bptr, -XBYTES
    XLOAD   bw0, 0(bptr)
 .endm


// The macro `TOLIMB` converts loweest word of the accu into a limb of length
// `LIMBBITS` (determined by `RADIX`).

.macro TOLIMB
    // li   mask, LIMBMASK
    srli    tmp0, rwl, LIMBBITS
    slli    rwh, rwh, (MPISE_XLEN-LIMBBITS)
    xor     rwh, rwh, tmp0
    and     rwl, rwl, mask
.endm


// The macro `STM_RES` stores a result-word, which is in register `rwl`, to
// array `r` in RAM. The address in `rptr` is decremented by 4 bytes on RV32
// and 8 bytes on RV64.

.macro STW_RES
    XSTORE  rwl, 0(rptr)
    addi    rptr, rptr, XBYTES
.endm


// The macro `CLRACCU` sets the double-length accumulator `rhi:rlo` to 0.

.macro CLRACCU
    mv      rwl, zero
    mv      rwh, zero
.endm


// The macro `SHRACCU` shifts the double-length accumulator `rhi:rlo` to the
// right by one word.

.macro SHRACCU
    mv      rwl, rwh
    mv      rwh, zero
.endm


// Multiple-precision multiplication using reduced-radix representation
// --------------------------------------------------------------------
// Conventional operand-scanning method combined where a single limb of the two
// operands is processed in each iteration of the inner loop.

.text
.global mpi_mul_1x1rr_isa_asm
.type mpi_mul_1x1rr_isa_asm,%function
// .balign 16
mpi_mul_1x1rr_isa_asm:
    CLRACCU
    li      mask, LIMBMASK          // content of `mask` depends on LIMBBITS
    slli    len, len, XLOG2B        // set `len` to byte-len of $len$ words
    mv      octr, zero              // initialize outer-loop counter with 0
    // START OF FIRST OUTER LOOP
.LOUTLOOP1:             // the 1st outer loop is iterated $len/XBYTES$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    add     octr, octr, XBYTES      // increment o-loop counter by $XBYTES$
    add     bptr, bptr, octr        // set `bptr` to address of b[k]
    // START OF FIRST INNER LOOP
.LINNLOOP1:             // the 1st inner loop is iterated $octr/XBYTES$ times
    LDW_OPA             // load single limb a[j] via `aptr` to register `aw0`
    LDW_OPB             // load single limb b[k] via `bptr` to register `bw0`
    MACC1X1 rwh, rwl, aw0, bw0, tmp0, tmp1  // MAC operation accu += a[i]*b[j}
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES§
    bne     ictr, octr, .LINNLOOP1  // branch to start of loop if ictr != octr
    // END OF FIRST INNER LOOP 
    TOLIMB              // convert lower accu-word to a limb (carry-prop!)
    STW_RES             // store single limb in reg `rwl` to r[i] via `rptr`
    SHRACCU             // shift the accu to the right by $LIMBBITS$ bits
    sub     aptr, aptr, octr        // set `aptr` to address of a[0]
    bne     octr, len, .LOUTLOOP1   // branch to start of loop if octr != len
    // END OF FIRST OUTER LOOP
    add     aptr, aptr, len         // set `aptr` to address of a[len]
    add     bptr, bptr, len         // set `bptr` to address of b[len]
    addi    octr, octr, -XBYTES     // set `octr` to byte-len of $len-1$ words
    // START OF SECOND OUTER LOOP
.LOUTLOOP2:             // the 2nd outer loop is iterated $len-1/XBYTES$ times
    mv      ictr, zero              // initialize inner-loop counter with 0
    sub     aptr, aptr, octr        // set `aptr` to address of a[len-1]
    // START OF SECOND INNER LOOP
.LINNLOOP2:             // the 2nd inner loop is iterated $octr/XBYTES$ times
    LDW_OPA             // load single limb a[j] via `aptr` to register `aw0`
    LDW_OPB             // load single limb b[k] via `bptr` to register `bw0`
    MACC1X1 rwh, rwl, aw0, bw0, tmp0, tmp1  // MAC operation accu += a[i]*b[j}
    addi    ictr, ictr, XBYTES      // increment i-loop counter by $XBYTES§
    bne     ictr, octr, .LINNLOOP2  // branch to start of loop if ictr != octr
    // END OF SECOND INNER LOOP 
    TOLIMB              // convert lower accu-word to a limb (carry-prop!)
    STW_RES             // store single limb in reg `rwl` to r[i] via `rptr`
    SHRACCU             // shift the accu to the right by $LIMBBITS$ bits
    add     bptr, bptr, octr        // set `bptr` to address of b[k]
    addi    octr, octr, -XBYTES     // decrement o-loop counter by $XBYTES$
    bne     octr, zero, .LOUTLOOP2  // branch to start of loop if octr != 0
    // END OF SECOND OUTER LOOP
    TOLIMB              // convert lower accu-word to a limb (carry-prop!)
    STW_RES             // store single limb in reg `rwl` to r[i] via `rptr`
    ret


.end
