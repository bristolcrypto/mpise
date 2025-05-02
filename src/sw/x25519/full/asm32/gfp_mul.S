// Function prototype:
// -------------------
// void gfp_mul_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_mul_isa` computes the product $r = a \cdot b \bmod p$ of
// two elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is
// the 255-bit pseudo-Mersenne prime $p = 2^{255} - 19$. Operands $a$ and $b$
// are allowed to be larger than $p$. The result $r$ may not be fully reduced,
// but $r$ is always less than $2p$.
//
// Parameters:
// -----------
// `r`: pointer to array for the eight 32-bit words of the result $r$.
// `a`: pointer to array containing the eight 32-bit words of operand $a$.
// `b`: pointer to array containing the eight 32-bit words of operand $b$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` to `tmp2` hold intermediate results
#define tmp0 a1
#define tmp1 a2
#define tmp2 t6
// Registers `aw00` to `aw07` hold words of operand `a`
#define aw00 t0
#define aw01 t1
#define aw02 t2
#define aw03 s0
#define aw04 s1
#define aw05 a3
#define aw06 a4
#define aw07 a5
// Registers `rw00` to `rw15` hold words of the product
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
///////////////// MACROS FOR WORD-WISE MULTIPLY-ADD OPERATIONS ////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MADD_V1` multiplies the word `aiw` by `bjw` and puts the double-
// length product in `rhi`:`rlo` (i.e., this macro performs a multiply-add
// operation where 0 is added to the product, which boils down to an ordinary
// multiplication).

.macro MADD_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


// The macro `MADD_V2` multiplies the word `aiw` by `bjw` and adds `rlo` to the
// double-length product. The lower half of the result is put in `rlo` and the
// upper part in `rhi` (`tlo` holds temporary results).

.macro MADD_V2 rhi:req, rlo:req, aiw:req, bjw:req, tlo:req
    mul     \tlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \rlo, \tlo
    sltu    \tlo, \rlo, \tlo
    add     \rhi, \rhi, \tlo
.endm


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
// temp = (temp >> 32) + ((UI64) a[i]*b[j]) + r[i+j]; r[i+j] = (UI32) temp;

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


///////////////////////////////////////////////////////////////////////////////
//////////// MACROS FOR LOW-LEVEL OPERATIONS FOR MODULAR REDUCTION ////////////
///////////////////////////////////////////////////////////////////////////////


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
///////////////// MACROS FOR ROW-WISE MULTIPLY-ADD OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MROW_V1` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `tmp2`) and puts the 9-word product in `p0w`-`p8w`. This macro
// corresponds to the operation $r = a \cdot b_0$ performed by the very first
// iteration of the outer loop of the operand-scanning method. The multiplier
// $b_j$ is loaded to `tmp2` (i.e., `rw15`) via base address `bptr` and offset
// `idx`. The word `tmp0` (i.e., `aptr`) holds temporary results.

.macro MROW_V1 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req, idx:req
    lw      tmp2, \idx(bptr)
    MADD_V1 \p1w, \p0w, aw00, tmp2
    MADD_V2 \p2w, \p1w, aw01, tmp2, tmp0
    MADD_V2 \p3w, \p2w, aw02, tmp2, tmp0
    MADD_V2 \p4w, \p3w, aw03, tmp2, tmp0
    MADD_V2 \p5w, \p4w, aw04, tmp2, tmp0
    MADD_V2 \p6w, \p5w, aw05, tmp2, tmp0
    MADD_V2 \p7w, \p6w, aw06, tmp2, tmp0
    MADD_V2 \p8w, \p7w, aw07, tmp2, tmp0
.endm


// The macro `MROW_V2` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `tmp2`) and adds the 9-word product to operand `p0w`-`p8w`.
// This macro corresponds to the operation $r = r + a \cdot b_j \cdot 2^{32j}$
// for $1 \leq j < 7$ performed by the six middle iterations of the outer loop
// of the operand-scanning method. The multiplier $b_j$ is loaded to `tmp2`
// (i.e., `rw15`) via base address `bptr` and offset `idx`. The words `tmp0`
// (i.e., `aptr`) and `p8w` hold temporary results.

.macro MROW_V2 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req, idx:req
    lw      tmp2, \idx(bptr)
    MADD_V3 \p0w, aw00, tmp2, \p8w, tmp0
    MADD_V4 \p1w, aw01, tmp2, \p8w, tmp0
    MADD_V4 \p2w, aw02, tmp2, \p8w, tmp0
    MADD_V4 \p3w, aw03, tmp2, \p8w, tmp0
    MADD_V4 \p4w, aw04, tmp2, \p8w, tmp0
    MADD_V4 \p5w, aw05, tmp2, \p8w, tmp0
    MADD_V4 \p6w, aw06, tmp2, \p8w, tmp0
    MADD_V4 \p7w, aw07, tmp2, \p8w, tmp0
.endm


// The macro `MROW_V3` multiplies the 8-word operand `aw00`-`aw07` by a single
// word (held in `tmp1`) and adds the 9-word product to operand `p0w`-`p8w`.
// This macro corresponds to the operation $r = r + a \cdot b_7 \cdot 2^{224}$
// performed by the last iteration of the outer loop of the operand-scanning
// method. The multiplier $b_7$ is loaded to `tmp1` (i.e., `bptr`) via base
// address `bptr` (which is not needed anymore!) and offset `idx`. The words
// `tmp0` (i.e., `aptr`) and `p8w` hold temporary results.

.macro MROW_V3 p8w:req, p7w:req, p6w:req, p5w:req, p4w:req, p3w:req, p2w:req, \
               p1w:req, p0w:req, idx:req
    lw      tmp1, \idx(bptr)
    MADD_V3 \p0w, aw00, tmp1, \p8w, tmp0
    MADD_V4 \p1w, aw01, tmp1, \p8w, tmp0
    MADD_V4 \p2w, aw02, tmp1, \p8w, tmp0
    MADD_V4 \p3w, aw03, tmp1, \p8w, tmp0
    MADD_V4 \p4w, aw04, tmp1, \p8w, tmp0
    MADD_V4 \p5w, aw05, tmp1, \p8w, tmp0
    MADD_V4 \p6w, aw06, tmp1, \p8w, tmp0
    MADD_V4 \p7w, aw07, tmp1, \p8w, tmp0
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULROWS` multiplies the 8-word operand $a$ (i.e., the eight words
// `aw00`-`aw07`) by the 8-word operand $b$ (which is loaded word by word from
// RAM) in a row-wise fashion. The 16-word product is put in `rw00`-`rw15`.

.macro MULROWS
    MROW_V1 rw08, rw07, rw06, rw05, rw04, rw03, rw02, rw01, rw00, 0
    MROW_V2 rw09, rw08, rw07, rw06, rw05, rw04, rw03, rw02, rw01, 4
    MROW_V2 rw10, rw09, rw08, rw07, rw06, rw05, rw04, rw03, rw02, 8
    MROW_V2 rw11, rw10, rw09, rw08, rw07, rw06, rw05, rw04, rw03, 12
    MROW_V2 rw12, rw11, rw10, rw09, rw08, rw07, rw06, rw05, rw04, 16
    MROW_V2 rw13, rw12, rw11, rw10, rw09, rw08, rw07, rw06, rw05, 20
    MROW_V2 rw14, rw13, rw12, rw11, rw10, rw09, rw08, rw07, rw06, 24
    MROW_V3 rw15, rw14, rw13, rw12, rw11, rw10, rw09, rw08, rw07, 28
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
////////// HELPER MACROS FOR OPERAND-SCANNING MODULAR MULTIPLICATION //////////
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
///////// SPEED-OPTIMIZED PRIME-FIELD MULTIPLICATION (FULLY UNROLLED) /////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field multiplication is based on the operand-
// scanning method and includes a fast reduction modulo $p = 2^{255} - 19$. It
// is aimed at high speed, which means the loops are fully unrolled. Each word
// of the arrays `a` and `b` is loaded from RAM exactly once, and each word of
// the result-array `r` is stored to RAM exactly once.

.text
.global gfp_mul_isa
.type gfp_mul_isa,%function
.balign 16
gfp_mul_isa:
    PROLOGUE            // push callee-saved registers on stack
    LDM_OPA             // load the eight words of array `a` from RAM
    MULROWS             // row-wise multiplication R += A*b[j]*2^(32*j)
    MODRED1             // 1st step of reduction: Rlo = Rlo + Rhi*2*c
    MODRED2             // 2nd step of reduction: obtain 8-word result
    STM_RES             // store the result-words in array `r` in RAM
    EPILOGUE            // pop callee-saved registers and return


.end
