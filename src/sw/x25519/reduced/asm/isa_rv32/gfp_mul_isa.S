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
// `r`: pointer to array for the nine 32-bit limbs of the result $r$.
// `a`: pointer to array containing the nine 32-bit limbs of operand $a$.
// `b`: pointer to array containing the nine 32-bit limbs of operand $b$.


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `tmp0` to `tmp1` hold intermediate results
#define tmp0 s0
#define tmp1 s1
// Register-pair `sloh:slol` holds the lower column-sum
#define slol a1
#define sloh a2
// Register-pair `shih:shil` holds the upper column-sum
#define shil a3
#define shih a4
// Registers `aw00` to `aw08` hold limbs of operand `a`
#define aw00 a5
#define aw01 a6
#define aw02 a7
#define aw03 t0
#define aw04 t1
#define aw05 t2
#define aw06 t3
#define aw07 t4
#define aw08 t5
// Registers `bw00` to `bw08` hold limbs of perand `b`
#define bw00 t6
#define bw01 s2
#define bw02 s3
#define bw03 s4
#define bw04 s5
#define bw05 s6
#define bw06 s7
#define bw07 s8
#define bw08 s9
// Registers `mask` and `ccon` hold 0x1FFFFFFF and 64*c
#define mask s10
#define ccon s11


///////////////////////////////////////////////////////////////////////////////
///////// LOW-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MACC_V1` multiplies the word `aiw` by `bjw` and puts the product
// in the double-length accumulator `rhi:rlo` (i.e., this macro performs a
// multiply-accumulate operation with an initial accumulator that is 0, i.e.,
// a normal multiplication).
// NOTE: Registers `rhi` and `rlo` have to be different from `aiw` and `bjw`.

.macro MACC_V1 rhi:req, rlo:req, aiw:req, bjw:req
    mul     \rlo, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
.endm


// The macro `MACC_V2` multiplies the word `aiw` by `bjw` and adds the product
// to the double-length accumulator `rhi:rlo`, whereby the initial value of the
// accumulator is only 32 bits long (i.e., `rhi` is 0).
// NOTE: Registers `rhi` and `rlo` have to be different from `aiw` and `bjw`.

.macro MACC_V2 rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   \rhi, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     \rhi, \rhi, tmp0
.endm


// The macro `MACC_V3` multiplies the word `aiw` by `bjw` and adds the product
// to the double-length accumulator `rhi:rlo`.
// NOTE: Registers `rhi` and `rlo` have to be different from `aiw` and `bjw`.

.macro MACC_V3 rhi:req, rlo:req, aiw:req, bjw:req
    mul     tmp0, \aiw, \bjw
    mulhu   tmp1, \aiw, \bjw
    add     \rlo, \rlo, tmp0
    sltu    tmp0, \rlo, tmp0
    add     tmp1, tmp1, tmp0
    add     \rhi, \rhi, tmp1
.endm


// The macro `SRLI_V1` shifts the double-length operand `ahi:alo`, which is up
// to $32 + RADIX$ bits long, RADIX bits to the right. The result has a length
// of 32 bits and is put in register `rlo`.
// NOTE: Register `rhi` is not modified.

.macro SRLI_V1 rhi:req, rlo:req, ahi:req, alo:req
    srli    \rlo, \alo, 29
    slli    tmp0, \ahi, 3
    or      \rlo, \rlo, tmp0
.endm


// The macro `SRLI_V2` shifts the double-length operand `ahi:alo` RADIX bits to
// the right. The result is put in the `rhi:rlo` register-pair.

.macro SRLI_V2 rhi:req, rlo:req, ahi:req, alo:req
    srli    \rlo, \alo, 29
    slli    tmp0, \ahi, 3
    or      \rlo, \rlo, tmp0
    srli    \rhi, \ahi, 29
.endm


// The macro `ST_LIMB` applies the bit-mask in `mask` to word `lmb` and stores
// the result to `r[i]` in RAM. The actual address is the sum of the offset in
// `ofs` and the base address in `rptr` (i.e., $ofs = 4i$).

.macro ST_LIMB lmb:req, ofs:req
    and     tmp0, \lmb, mask
    sw      tmp0, \ofs(rptr)
.endm


// The macro `MUL_CON` multiplies the double-length operand `ahi:alo` by the
// constant $64c$ in `ccon` and puts the double-length product in the `rhi:rlo`
// register-pair.

.macro MUL_CON rhi:req, rlo:req, ahi:req, alo:req
    mul    tmp0, \ahi, ccon
    mulhu  \rhi, \alo, ccon
    mul    \rlo, \alo, ccon
    add    \rhi, \rhi, tmp0
.endm


// The macro `ADD_MSW` loads the word `r[8]` of the (intermediate) result from
// RAM and adds it to the double-length sum `shi:slo`. Then, it applies the
// bit-mask in `mask` to lower word of the sum and stores the result to `r[8]`
// in RAM.

.macro ADD_MSW shi:req, slo:req
    lw      tmp0, 32(rptr)
    add     \slo, \slo, tmp0
    sltu    tmp0, \slo, tmp0
    add     \shi, \shi, tmp0
    and     tmp0, \slo, mask
    sw      tmp0, 32(rptr)
.endm


// The macro `ADD_LSW` shifts the double-length sum `shi:slo` RADIX bits to the
// right and multiplies the lower word of the result by the constant $64c$ in
// `ccon`. Then, it loads the word `r[0]` of the (intermediate) result from RAM
// and adds it to the product. The result is stored to `r[0]` in RAM.

.macro ADD_LSW shi:req, slo:req
    lw      tmp0, 0(rptr)
    srli    \slo, \slo, 29
    slli    \shi, \shi, 3
    or      \slo, \slo, \shi
    mul     \slo, \slo, ccon
    add     tmp0, tmp0, \slo
    sw      tmp0, 0(rptr)
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULCOL8` computes the nine limb-products that form the result-
// limb `r[8]`, which are limb-products $a_i \cdot b_j$ with $i + j = 9$. These
// limb-products are accumulated into the "lower" column-sum in the `sloh:slol`
// register-pair. Then, the limb in the lower word `slol` is stored to `r[8]`
// in RAM and the column-sum is shifted RADIX bits to the right. Finally, the
// shifted column-sum is multiplied by the constant $64c$ and the product is
// put in the `sloh:slol` register-pair.

.macro MULCOL8
    MACC_V1 sloh, slol, aw00, bw08
    MACC_V3 sloh, slol, aw01, bw07
    MACC_V3 sloh, slol, aw02, bw06
    MACC_V3 sloh, slol, aw03, bw05
    MACC_V3 sloh, slol, aw04, bw04
    MACC_V3 sloh, slol, aw05, bw03
    MACC_V3 sloh, slol, aw06, bw02
    MACC_V3 sloh, slol, aw07, bw01
    MACC_V3 sloh, slol, aw08, bw00
    ST_LIMB slol, 32
    SRLI_V2 sloh, slol, sloh, slol
    MUL_CON sloh, slol, sloh, slol
.endm


// The macro `MULCOL0` computes the nine limb-products that form the result-
// limb `r[0]`, which are limb-products $a_i \cdot b_j$ with $i + j = 0$ and
// $i + j = 9$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[0]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL0
    MACC_V3 sloh, slol, aw00, bw00
    MACC_V1 shih, shil, aw01, bw08
    MACC_V3 shih, shil, aw02, bw07
    MACC_V3 shih, shil, aw03, bw06
    MACC_V3 shih, shil, aw04, bw05
    MACC_V3 shih, shil, aw05, bw04
    MACC_V3 shih, shil, aw06, bw03
    MACC_V3 shih, shil, aw07, bw02
    MACC_V3 shih, shil, aw08, bw01
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 0
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL1` computes the nine limb-products that form the result-
// limb `r[1]`, which are limb-products $a_i \cdot b_j$ with $i + j = 1$ and
// $i + j = 10$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[1]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL1
    MACC_V2 sloh, slol, aw00, bw01
    MACC_V3 sloh, slol, aw01, bw00
    MACC_V2 shih, shil, aw02, bw08
    MACC_V3 shih, shil, aw03, bw07
    MACC_V3 shih, shil, aw04, bw06
    MACC_V3 shih, shil, aw05, bw05
    MACC_V3 shih, shil, aw06, bw04
    MACC_V3 shih, shil, aw07, bw03
    MACC_V3 shih, shil, aw08, bw02
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 4
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL2` computes the nine limb-products that form the result-
// limb `r[2]`, which are limb-products $a_i \cdot b_j$ with $i + j = 2$ and
// $i + j = 11$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[2]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL2
    MACC_V2 sloh, slol, aw00, bw02
    MACC_V3 sloh, slol, aw01, bw01
    MACC_V3 sloh, slol, aw02, bw00
    MACC_V2 shih, shil, aw03, bw08
    MACC_V3 shih, shil, aw04, bw07
    MACC_V3 shih, shil, aw05, bw06
    MACC_V3 shih, shil, aw06, bw05
    MACC_V3 shih, shil, aw07, bw04
    MACC_V3 shih, shil, aw08, bw03
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 8
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL3` computes the nine limb-products that form the result-
// limb `r[3]`, which are limb-products $a_i \cdot b_j$ with $i + j = 3$ and
// $i + j = 12$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[3]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL3
    MACC_V2 sloh, slol, aw00, bw03
    MACC_V3 sloh, slol, aw01, bw02
    MACC_V3 sloh, slol, aw02, bw01
    MACC_V3 sloh, slol, aw03, bw00
    MACC_V2 shih, shil, aw04, bw08
    MACC_V3 shih, shil, aw05, bw07
    MACC_V3 shih, shil, aw06, bw06
    MACC_V3 shih, shil, aw07, bw05
    MACC_V3 shih, shil, aw08, bw04
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 12
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL4` computes the nine limb-products that form the result-
// limb `r[4]`, which are limb-products $a_i \cdot b_j$ with $i + j = 4$ and
// $i + j = 13$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[4]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL4
    MACC_V2 sloh, slol, aw00, bw04
    MACC_V3 sloh, slol, aw01, bw03
    MACC_V3 sloh, slol, aw02, bw02
    MACC_V3 sloh, slol, aw03, bw01
    MACC_V3 sloh, slol, aw04, bw00
    MACC_V2 shih, shil, aw05, bw08
    MACC_V3 shih, shil, aw06, bw07
    MACC_V3 shih, shil, aw07, bw06
    MACC_V3 shih, shil, aw08, bw05
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 16
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL5` computes the nine limb-products that form the result-
// limb `r[5]`, which are limb-products $a_i \cdot b_j$ with $i + j = 5$ and
// $i + j = 14$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[5]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL5
    MACC_V2 sloh, slol, aw00, bw05
    MACC_V3 sloh, slol, aw01, bw04
    MACC_V3 sloh, slol, aw02, bw03
    MACC_V3 sloh, slol, aw03, bw02
    MACC_V3 sloh, slol, aw04, bw01
    MACC_V3 sloh, slol, aw05, bw00
    MACC_V2 shih, shil, aw06, bw08
    MACC_V3 shih, shil, aw07, bw07
    MACC_V3 shih, shil, aw08, bw06
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 20
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL6` computes the nine limb-products that form the result-
// limb `r[6]`, which are limb-products $a_i \cdot b_j$ with $i + j = 6$ and
// $i + j = 15$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[6]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL6
    MACC_V2 sloh, slol, aw00, bw06
    MACC_V3 sloh, slol, aw01, bw05
    MACC_V3 sloh, slol, aw02, bw04
    MACC_V3 sloh, slol, aw03, bw03
    MACC_V3 sloh, slol, aw04, bw02
    MACC_V3 sloh, slol, aw05, bw01
    MACC_V3 sloh, slol, aw06, bw00
    MACC_V2 shih, shil, aw07, bw08
    MACC_V3 shih, shil, aw08, bw07
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 24
    SRLI_V1 shih, shil, shih, shil
    SRLI_V1 sloh, slol, sloh, slol
.endm


// The macro `MULCOL7` computes the nine limb-products that form the result-
// limb `r[7]`, which are limb-products $a_i \cdot b_j$ with $i + j = 7$ and
// $i + j = 16$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the `sloh:slol` register-pair and the latter into
// the "higher" column-sum in `shih:shil` register-pair. Then, the limb in the
// lower word `shil` of the "higher" clumn-sum is multiplied by the constant
// $64c$ and the product is accumulated into the "lower" column-sum. The limb
// in the lower word `slol` of the "lower" column-sum is stored to `r[7]` in
// RAM. Finally, both column-sums are shifted RADIX bits to the right.

.macro MULCOL7
    MACC_V2 sloh, slol, aw00, bw07
    MACC_V3 sloh, slol, aw01, bw06
    MACC_V3 sloh, slol, aw02, bw05
    MACC_V3 sloh, slol, aw03, bw04
    MACC_V3 sloh, slol, aw04, bw03
    MACC_V3 sloh, slol, aw05, bw02
    MACC_V3 sloh, slol, aw06, bw01
    MACC_V3 sloh, slol, aw07, bw00
    MACC_V2 shih, shil, aw08, bw08
    and     tmp1, shil, mask
    MACC_V3 sloh, slol, ccon, tmp1
    ST_LIMB slol, 28
    SRLI_V1 shih, shil, shih, shil
    SRLI_V2 sloh, slol, sloh, slol
.endm


// The macro `FINREDP` performs the final step of the reduction modulo $p$ by
// multiplying the lower word `shil` of the "higher" column-sum by the constant
// $64c$ and accumulating the double-length product into the "lower" column-sum
// in the `sloh:slol` register-pair (macro `MACC_V3`). The lower limb of this
// sum is added to `r[8]` (macro `ADD_MSW`). Finally, the sum is shifted RADIX
// bits to the reight, multiplied by the constant $64c$, and the single-length
// product is added to `r[0]` (macro `ADD_LSW`).

.macro FINREDP
    MACC_V3 sloh, slol, shil, ccon
    ADD_MSW sloh, slol
    ADD_LSW sloh, slol
.endm


///////////////////////////////////////////////////////////////////////////////
////////// HELPER MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION //////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes all 12 callee-saved registers on the stack.

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


// The macro `EPILOGUE` pops all 12 callee-saved registers from the stack.

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
.endm


// The macro `INITVAR` initializes local variables (`mask` and `ccon`).

.macro INITVAR
    li      mask, -1
    srli    mask, mask, 3
    li      ccon, 64*CONSTC
.endm


// The macro `LDM_OPA` loads the nine limbs of array `a` from RAM and puts
// them in registers `aw00`-`aw08`.

.macro LDM_OPA
    lw      aw00, 0(aptr)
    lw      aw01, 4(aptr)
    lw      aw02, 8(aptr)
    lw      aw03, 12(aptr)
    lw      aw04, 16(aptr)
    lw      aw05, 20(aptr)
    lw      aw06, 24(aptr)
    lw      aw07, 28(aptr)
    lw      aw08, 32(aptr)
.endm


// The macro `LDM_OPB` loads the nine limbs of array `b` from RAM and puts
// them in registers `bw00`-`bw08`.

.macro LDM_OPB
    lw      bw00, 0(bptr)
    lw      bw01, 4(bptr)
    lw      bw02, 8(bptr)
    lw      bw03, 12(bptr)
    lw      bw04, 16(bptr)
    lw      bw05, 20(bptr)
    lw      bw06, 24(bptr)
    lw      bw07, 28(bptr)
    lw      bw08, 32(bptr)
.endm


///////////////////////////////////////////////////////////////////////////////
///////// SPEED-OPTIMIZED PRIME-FIELD MULTIPLICATION (FULLY UNROLLED) /////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field multiplication is based on the operand-
// scanning method and includes a fast reduction modulo $p = 2^{255} - 19$. It
// is aimed at high speed, which means the loops are fully unrolled. Each limb
// of the arrays `a` and `b` is loaded from RAM exactly once, and each limb of
// the result-array `r` is stored to RAM exactly once (except of the two limbs
// `r[8]` and `[0]`, which are stored twice due to the lack of free registers).
// NOTE: The least-significant limb `r[0]` can be $RADIX + 1$ bits long.

.text
.global gfp_mul_isa
.type gfp_mul_isa,%function
// .balign 8
gfp_mul_isa:
    PROLOGUE            // push callee-saved registers on stack
    INITVAR             // initalize local varianbles (`mask`, `ccon`)
    LDM_OPA             // load the eight words of array `a` from RAM
    LDM_OPB             // load the eight words of array `b` from RAM
    MULCOL8             // compute limb-products for result-limb `r[8]`
    MULCOL0             // compute limb-products for result-limb `r[0]`
    MULCOL1             // compute limb-products for result-limb `r[1]`
    MULCOL2             // compute limb-products for result-limb `r[2]`
    MULCOL3             // compute limb-products for result-limb `r[3]`
    MULCOL4             // compute limb-products for result-limb `r[4]`
    MULCOL5             // compute limb-products for result-limb `r[5]`
    MULCOL6             // compute limb-products for result-limb `r[6]`
    MULCOL7             // compute limb-products for result-limb `r[7]`
    FINREDP             // final reduction (update limb `r[8]`, `r[0]`)
    EPILOGUE            // pop callee-saved registers from stack
    ret


.end
