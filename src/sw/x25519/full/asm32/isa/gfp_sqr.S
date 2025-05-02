// Function prototype:
// -------------------
// void gfp_sqr_isa(uint32_t *r, const uint32_t *a);
//
// Description:
// ------------
// The function `gfp_sqr_isa` computes the square $r = a^2 \bmod p$ of an
// element $a$ of a pseudo-Mersenne prime field. The prime $p$ is is the 255-
// bit pseudo-Mersenne prime $p = 2^{255} - 19$. Operand $a$ is allowed to be
// larger than $p$. The result $r$ may not be fully reduced, but $r$ is always
// less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Registers `tmp0` and `tmp1` hold intermediate results
#define tmp0 a1
#define tmp1 a2
// Registers `aw00` to `aw07` hold words of operand `a`
#define aw00 t0
#define aw01 t1
#define aw02 t2
#define aw03 s0
#define aw04 s1
#define aw05 a3
#define aw06 a4
#define aw07 a5
// Registers `rw00` to `rw15` hold words of the square
#define rw00 a6
#define rw01 a7
#define rw02 s2
#define rw03 s3
#define rw04 s4
#define rw05 s5
#define rw06 s6
#define rw07 s7
#define rw08 s8
#define rw09 s9
#define rw10 s10
#define rw11 s11
#define rw12 t3
#define rw13 t4
#define rw14 t5
#define rw15 t6

// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CCON, 19


///////////////////////////////////////////////////////////////////////////////
///////////// MACROS FOR WORD-WISE MULTIPLY-ACCUMULATE OPERATIONS /////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MACC_V1` multiplies the word `aiw` by `bjw` and puts the double-
// length product in the double-length accumulator `rhi`:`rlo` (i.e., the macro
// performs an ordinary multiplication, which can also be seen as a multiply-
// accumulate operation with an initial accumulator that is 0).

.macro MACC_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


// The macro `MACC_V2` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the double-length accumulator `rhi`:`rlo`, whereby the
// initial value of the accumulator is only 32 bits long (i.e., `rhi` is 0).
// The word `tlo` holds temporary results.

.macro MACC_V2 rhi:req, rlo:req, aiw:req, bjw:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \rhi, \rhi, \tlo
.endm


// The macro `MACC_V3` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the triple-length accumulator `rex`:`rhi`:`rlo`, whereby
// the initial value of the accumulator is only 64 bits long (i.e., `rex` is 0).
// The word `tlo` holds temporary results.

.macro MACC_V3 rex:req, rhi:req, rlo:req, aiw:req, bjw:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \rex, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \rex, \rex, \tlo
    add     \rhi, \rhi, \rex
    sltu    \rex, \rhi, \rex
.endm


// The macro `MACC_V4` multiplies the word `aiw` by `bjw` and adds the double-
// length product to the triple-length accumulator `rex`:`rhi`:`rlo`. The words
// `tlo` and `thi` hold temporary results.

.macro MACC_V4 rex:req, rhi:req, rlo:req, aiw:req, bjw:req, thi:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \thi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
    add     \rhi, \rhi, \thi
    sltu    \thi, \rhi, \thi
    add     \rex, \rex, \thi
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR WORD-WISE DOUBLE-AND-ADD-SQUARE OPERATIONS ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro DASQ_V1 doubles the word `rhi` and adds the result to the upper
// half of the double-length square of the word `aiw`. The final result is put
// in the double-length word `rhi`:`rlo` and the outgoing carry in the word
// `cry`.

.macro DASQ_V1 rhi:req, rlo:req, aiw:req, cry:req
    mul     \rlo, \aiw, \aiw
    add     tmp1, \rhi, \rhi
    sltu    \cry, tmp1, \rhi
    mulhu   \rhi, \aiw, \aiw
    add     \rhi, \rhi, tmp1
    sltu    tmp1, \rhi, tmp1
    add     \cry, \cry, tmp1
.endm


// The macro DASQ_V2 doubles the double-length word `rhi`:`rlo` and adds the
// result along with the incoming carry-word `cry` to the double-length square
// of the word `aiw`. The final result is put in the double-length word
// `rhi`:`rlo` and the outgoing carry in the word `cry`.

.macro DASQ_V2 rhi:req, rlo:req, aiw:req, cry:req
    add     tmp1, \rlo, \rlo
    sltu    \rlo, tmp1, \rlo
    add     tmp1, tmp1, \cry
    sltu    \cry, tmp1, \cry
    add     \cry, \cry, \rlo
    mul     \rlo, \aiw, \aiw
    add     \rlo, \rlo, tmp1
    sltu    tmp1, \rlo, tmp1
    add     \cry, \cry, tmp1
    add     tmp1, \rhi, \rhi
    sltu    \rhi, tmp1, \rhi
    add     tmp1, tmp1, \cry
    sltu    \cry, tmp1, \cry
    add     \cry, \cry, \rhi
    mulhu   \rhi, \aiw, \aiw
    add     \rhi, \rhi, tmp1
    sltu    tmp1, \rhi, tmp1
    add     \cry, \cry, tmp1
.endm


// The macro DASQ_V3 doubles the word `rlo` and adds the result along with the
// incoming carry-word `cry` to the double-length square of the word `aiw`. The
// final result is put in the double-length word `rhi`:`rlo` (normally, there
// should be no outgoing carry!).

.macro DASQ_V3 rhi:req, rlo:req, aiw:req, cry:req
    add     tmp1, \rlo, \rlo
    sltu    \rlo, tmp1, \rlo
    add     tmp1, tmp1, \cry
    sltu    \cry, tmp1, \cry
    add     \cry, \cry, \rlo
    mul     \rlo, \aiw, \aiw
    add     \rlo, \rlo, tmp1
    sltu    tmp1, \rlo, tmp1
    add     \cry, \cry, tmp1
    mulhu   \rhi, \aiw, \aiw
    add     \rhi, \rhi, \cry
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V3` multiplies the word `aiw` by `bjw` and adds `rlo` to the
// double-length product. The lower half of the result is put in `rlo` and the
// upper half in `thi` (`tlo` holds temporary results). This macro corresponds
// to the following C code (`temp` is a double-length word):
// temp = ((UI64) a[i]*b[j]) + r[i+j]; r[i+j] = (UI32) temp;

.macro MADD_V3 rlo:req, aiw:req, bjw:req, thi:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \thi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
.endm


// The macro `MADD_V4` multiplies the word `aiw` by `bjw` and adds `rlo` and
// `thi` to the double-length product. The lower half of the result is put in
// `rlo` and the upper half in `thi` (`tlo` holds temporary results). This
// macro corresponds to the following C code (`temp` is a double-length word):
// temp = (temp >> 32) + ((UI64) a[i]*b[j}) + r[i+j]; r[i+j] = (UI32) temp;

.macro MADD_V4 rlo:req, aiw:req, bjw:req, thi:req, tlo:req
    add     \rlo, \rlo, \thi
    sltu    \tlo, \rlo, \thi
    mulhu   \thi, \aiw, \bjw
    add     \thi, \thi, \tlo
    mul     \tlo, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \thi, \thi, \tlo
.endm


// The macro `MULHIXC` splits the double-length word `rhi`:`rlo` into a 31-bit
// lower part and a (normally much shorter) upper part. The lower part remains
// in `rlo`, while the upper part is multiplied by the constant $c = 19$. The
// resulting product, which normally does not exceed a word, is put in `rhi`.

.macro MULHIXC rhi:req, rlo:req
    srli    tmp0, \rlo, 31
    slli    \rhi, \rhi, 1
    li      tmp1, CCON
    add     \rhi, \rhi, tmp0
    slli    \rlo, \rlo, 1
    mul     \rhi, \rhi, tmp1
    srli    \rlo, \rlo, 1
.endm


// The macro `ADDWORD` adds the word `adw` to the 8-word operand `p7w`-`p0w`.

.macro ADDWORD p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, p1w:req, \
               p0w:req, adr:req
    add     \p0w, \p0w, \adr
    sltu    \adr, \p0w, \adr
    add     \p1w, \p1w, \adr
    sltu    \adr, \p1w, \adr
    add     \p2w, \p2w, \adr
    sltu    \adr, \p2w, \adr
    add     \p3w, \p3w, \adr
    sltu    \adr, \p3w, \adr
    add     \p4w, \p4w, \adr
    sltu    \adr, \p4w, \adr
    add     \p5w, \p5w, \adr
    sltu    \adr, \p5w, \adr
    add     \p6w, \p6w, \adr
    sltu    \adr, \p6w, \adr
    add     \p7w, \p7w, \adr
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR COLUMN-WISE MULTIPLY-ACCUMULATE OPERATIONS ////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MCOL_V1` multiplies the word `a0w` by `b0w` and adds the double-
// length product to the triple-length accumulator `rex`:`rhi`:`rlo`. The last
// parameter `acclen` specifies the initial length of the accumulator, which
// can be either 0 (i.e., `rex`, `rhi`, and `rlo` is 0), 32 (i.e., `rex` and
// `rhi` is 0), or 64 (i.e., `rex` is 0).

.macro MCOL_V1 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, acclen:req
    .if (\acclen == 0)
    MACC_V1 \rhi, \rlo, \a0w, \b0w
    .elseif (\acclen == 32)
    MACC_V2 \rhi, \rlo, \a0w, \b0w, tmp0
    .else  // acclen == 64
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w, tmp0
    .endif
.endm


// The macro `MCOL_V2` multiplies the word `a0w` by `b0w` and the word `a1w` by
// `b1w`, and adds the double-length products to the triple-length accumulator
// `rex`:`rhi`:`rlo`. The last parameter `acclen` specifies the initial length
// of the accumulator, which can be either 32 (i.e., `rex` and `rhi` is 0) or
// 64 (i.e., `rex` is 0).

.macro MCOL_V2 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               acclen:req
    .if (\acclen == 32)
    MACC_V2 \rhi, \rlo, \a0w, \b0w, tmp0
    MACC_V3 \rex, \rhi, \rlo, \a1w, \b1w, tmp0
    .else  // acclen == 64
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w, tmp1, tmp0
    .endif
.endm


// The macro `MCOL_V3` multiplies the word `a0w` by `b0w`, the word `a1w` by
// `b1w` and the word `a2w` by `b2w`, and adds the double-length products to
// the triple-length accumulator `rex`:`rhi`:`rlo`. The initial length of the
// accumulator is 64 (i.e., `rex` is 0).

.macro MCOL_V3 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               a2w:req, b2w:req
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w, tmp1, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a2w, \b2w, tmp1, tmp0
.endm


// The macro `MCOL_V4` multiplies the word `a0w` by `b0w`, the word `a1w` by
// `b1w`, the word `a2w` by `b2w` and the word `a3w` by `b3w`, and adds the
// double-length products to the triple-length accumulator `rex`:`rhi`:`rlo`.
// The initial length of the accumulator is 64 (i.e., `rex` is 0).

.macro MCOL_V4 rex:req, rhi:req, rlo:req, a0w:req, b0w:req, a1w:req, b1w:req, \
               a2w:req, b2w:req, a3w:req, b3w:req
    MACC_V3 \rex, \rhi, \rlo, \a0w, \b0w, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a1w, \b1w, tmp1, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a2w, \b2w, tmp1, tmp0
    MACC_V4 \rex, \rhi, \rlo, \a3w, \b3w, tmp1, tmp0
.endm


///////////////////////////////////////////////////////////////////////////////
/////////// HIGH-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR SQUARING ///////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULCOLS` computes the column-sums of all double-length products
// of the form $a_i \cdot a_j$ with $i < j$ (these are exactly the 28 double-
// length products that appear twice in the final result). The eight words of
// operand $a$ are `aw00`-`aw07` and the 14 words of the obtained column-sums
// are put in `rw01`-`rw14` (the computation of the words `rw00` and `rw15` is
// not part of this macro!).

.macro MULCOLS
    MCOL_V1 rw03, rw02, rw01, aw00, aw01, 0
    MCOL_V1 rw04, rw03, rw02, aw00, aw02, 32
    MCOL_V2 rw05, rw04, rw03, aw00, aw03, aw01, aw02, 32
    MCOL_V2 rw06, rw05, rw04, aw00, aw04, aw01, aw03, 64
    MCOL_V3 rw07, rw06, rw05, aw00, aw05, aw01, aw04, aw02, aw03
    MCOL_V3 rw08, rw07, rw06, aw00, aw06, aw01, aw05, aw02, aw04
    MCOL_V4 rw09, rw08, rw07, aw00, aw07, aw01, aw06, aw02, aw05, aw03, aw04
    MCOL_V3 rw10, rw09, rw08, aw01, aw07, aw02, aw06, aw03, aw05
    MCOL_V3 rw11, rw10, rw09, aw02, aw07, aw03, aw06, aw04, aw05
    MCOL_V2 rw12, rw11, rw10, aw03, aw07, aw04, aw06, 64
    MCOL_V2 rw13, rw12, rw11, aw04, aw07, aw05, aw06, 64
    MCOL_V1 rw14, rw13, rw12, aw05, aw07, 64
    MCOL_V1 rw15, rw14, rw13, aw06, aw07, 32
.endm


// The macro `MULCOLS` doubles the 14 column sums `rw01`-`rw14` and adds the
// eight double-length squares $a_i^2$ (i.e., the squares that are in the "main
// diagonal") to the result. The eight words of operand $a$ are `aw00`-`aw07`
// and the 16 words of the final result are put in `rw00`-`rw15`.

.macro DBADDSQ
    DASQ_V1 rw01, rw00, aw00, tmp0
    DASQ_V2 rw03, rw02, aw01, tmp0
    DASQ_V2 rw05, rw04, aw02, tmp0
    DASQ_V2 rw07, rw06, aw03, tmp0
    DASQ_V2 rw09, rw08, aw04, tmp0
    DASQ_V2 rw11, rw10, aw05, tmp0
    DASQ_V2 rw13, rw12, aw06, tmp0
    DASQ_V3 rw15, rw14, aw07, tmp0
.endm


// The macro `MODRED1` performs a (partial) reduction of the 16-word operand
// `rw00`-`rw15` modulo $2p = 2^{256} - 38$ to obtain a 9-word result. The
// upper half of the operand (i.e., the words `rw08`-`rw15`) is multiplied by
// $2c = 38$ and the 9-word product is added to the lower half (i.e., the words
// `rw00`-`rw07`). The result is put in `rw00`-`rw08`, whereby the word `rw08`
// is relatively short (at most one bit longer than $2c$).

.macro MODRED1
    li      tmp1, 2*CCON
    MADD_V3 rw00, rw08, tmp1, rw08, tmp0
    MADD_V4 rw01, rw09, tmp1, rw08, tmp0
    MADD_V4 rw02, rw10, tmp1, rw08, tmp0
    MADD_V4 rw03, rw11, tmp1, rw08, tmp0
    MADD_V4 rw04, rw12, tmp1, rw08, tmp0
    MADD_V4 rw05, rw13, tmp1, rw08, tmp0
    MADD_V4 rw06, rw14, tmp1, rw08, tmp0
    MADD_V4 rw07, rw15, tmp1, rw08, tmp0
.endm


// The macro `MODRED2` performs a (partial) reduction of the 9-word operand
// `rw00`-`rw08` modulo $p = 2^{255} - 19$ to obtain an 8-word result. First,
// the macro `MULHIXC` is called to split the double-length word `rw08`:`rw07`
// into a 31-bit lower part and a (normally much shorter) upper part, which is
// then multiplied by $c = 19$. Then, the macro `ADDWORD` adds the obtained
// product, which fits into a single word, to the eight words `rw00`-`rw07`.

.macro MODRED2
    MULHIXC rw08, rw07
    ADDWORD rw07, rw06, rw05, rw04, rw03, rw02, rw01, rw00, rw08
.endm


///////////////////////////////////////////////////////////////////////////////
///////////// HELPER MACROS FOR PRODUCT-SCANNING MODULAR SQUARING /////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes all callee-saved registers on the stack.

.macro PROLOGUE
    addi    sp, sp, -48
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
    sw      s10, 40(sp)
    sw      s11, 44(sp)
.endm


// The macro `EPILOGUE` pops all callee-saved registers from the stack and
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
    lw      s10, 40(sp)
    lw      s11, 44(sp)
    addi    sp, sp, 48
    ret
.endm


// The macro `LDM_OPA` loads the eight words of array `a` from RAM and puts
// them in registers `aw00`-`aw07`.

.macro LDM_OPA
    lw      aw00, 0(aptr)
    lw      aw01, 4(aptr)
    lw      aw02, 8(aptr)
    lw      aw03, 12(aptr)
    lw      aw04, 16(aptr)
    lw      aw05, 20(aptr)
    lw      aw06, 24(aptr)
    lw      aw07, 28(aptr)
.endm


// The macro `STM_RES` stores the eight result-words, which are in registers
// `rw00`-`rw07`, to array `r` in RAM.

.macro STM_RES
    sw      rw00, 0(rptr)
    sw      rw01, 4(rptr)
    sw      rw02, 8(rptr)
    sw      rw03, 12(rptr)
    sw      rw04, 16(rptr)
    sw      rw05, 20(rptr)
    sw      rw06, 24(rptr)
    sw      rw07, 28(rptr)
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// SPEED-OPTIMIZED PRIME-FIELD SQUARING (FULLY UNROLLED) ////////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field squaring is based on the product-scanning
// method and includes a fast reduction modulo $p = 2^{255} - 19$. It is aimed
// at high speed, which means the loops are fully unrolled. Each word of the
// array `a` is loaded from RAM exactly once, and each word of the result-array
// `r` is stored to RAM exactly once.

.text
.global gfp_sqr_isa
.type gfp_sqr_isa,%function
.balign 16
gfp_sqr_isa:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of operand A from RAM
    MULCOLS             // Column-wise mul of all a[i]*a[j] to be doubled
    DBADDSQ             // Double current result and add squares a[i]^2
    MODRED1             // 1st step of reduction: Rlo = Rlo + Rhi*38
    MODRED2             // 2nd step of reduction: obtain 8-word result
    STM_RES             // store the eight words of the result in RAM
    EPILOGUE            // pop callee-saved registers and return


.end
