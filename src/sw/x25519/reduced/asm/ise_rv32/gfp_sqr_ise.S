// Function prototype:
// -------------------
// void gfp_sqr_ise(uint32_t *r, const uint32_t *a);
//
// Description:
// ------------
// The function `gfp_sqr_ise` computes the square $r = a^2 \bmod p$ of an
// element $a$ of a pseudo-Mersenne prime field. The prime $p$ is the 255-bit
// pseudo-Mersenne prime $p = 2^{255} - 19$, but the reduction is actually
// performed modulo $64p$. Hence, the result can be $9*RADIX = 261$ bits long.
// The least-significant limb of operand $a$ is allowed to be $RADIX + 1$ bits
// long. Also the least-sigfinicant limb of the result can be $RADIX + 1$ bit
// long, but all other limbs have a length of $RADIX$ bits.
//
// Parameters:
// -----------
// `r`: pointer to array for the nine 29-bit limbs of the result $r$.
// `a`: pointer to array containing the nine 29-bit limbs of operand $a$.


#include "ise_al.h"


///////////////////////////////////////////////////////////////////////////////
//////////////////////// REGISTER NAMES AND CONSTANTS /////////////////////////
///////////////////////////////////////////////////////////////////////////////


// Constant c of the pseudo-Mersenne prime: p = 2^k - c
.equ CONSTC, 19
// Number-representation radix for prime-field elements
.equ RADIX, 29
// Scaling factor for constant c ($NLIMBS*RADIX - 255$)
.equ SCALEC, 6

// Register `rptr` holds the start address of array `r`
#define rptr a0
// Register `aptr` holds the start address of array `a`
#define aptr a1
// Register `tmp0` holds temporary/intermediate results
#define tmp0 s0
// Registers `slox` to `slol` hold the lower column-sum
#define slol a1
#define sloh a2
#define slox s1
// Register-pair `shih:shil` holds the upper column-sum
#define shil a3
#define shih a4
// Register-pair `dblh:dbll` holds values to be doubled
#define dbll a5
#define dblh a6
// Registers `aw00` to `aw08` hold limbs of operand `a`
#define aw00 a7
#define aw01 t0
#define aw02 t1
#define aw03 t2
#define aw04 t3
#define aw05 t4
#define aw06 t5
#define aw07 t6
#define aw08 s2
// Registers `rlsw` and `rmsw` hold words of the result
#define rlsw s3
#define rmsw s4
// Registers `mask` and `rcon` hold 0x1FFFFFFF and 64*c
#define mask s5
#define rcon s6


///////////////////////////////////////////////////////////////////////////////
///////// LOW-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MACC_V1` multiplies the limb `aiw` by `bjw` and puts the lower
// RADIX bits of the product in `rlo` and all higher product-bits in `rhi`.
// Consequently, this macro performs a multiply-accumulate operation with an
// initial accumulator that is 0, i.e., a normal multiplication.
// NOTE: Registers `rhi` and `rlo` have to be different from `aiw` and `bjw`.

.macro MACC_V1 rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu \rlo, \aiw, \bjw, zero
    madd51hu \rhi, \aiw, \bjw, zero
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mv      \rlo, zero
    mv      \rhi, zero
    madd51lu \rlo, \aiw, \bjw
    madd51hu \rhi, \aiw, \bjw
#endif
.endm


// The macro `MACC_V3` multiplies the limb `aiw` by `bjw` and adds the lower
// RADIX bits of the product to `rlo` and all higher product-bits to `rhi`.
// NOTE: Registers `rhi` and `rlo` have to be different from `aiw` and `bjw`.

.macro MACC_V3 rhi:req, rlo:req, aiw:req, bjw:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    madd51lu \rlo, \aiw, \bjw, \rlo
    madd51hu \rhi, \aiw, \bjw, \rhi
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    madd51lu \rlo, \aiw, \bjw
    madd51hu \rhi, \aiw, \bjw
#endif
.endm


// The macro `SRLI_V1` shifts the limb-pair `ahi` and `alo` (whose bitlengths
// may exceed RADIX bits) one limb to the right and puts the result in `rhi`
// and `rlo`. Both `rhi` and `rlo` cosist of at most RADIX bits.

.macro SRLI_V1 rhi:req, rlo:req, ahi:req, alo:req
    srli    \rlo, \alo, RADIX
    add     \rlo, \rlo, \ahi
    srli    \rhi, \rlo, RADIX
    and     \rlo, \rlo, mask
.endm


// The macro `SRLI_V2` shifts the limb-triple `aex`, `ahi` and `alo` (whose
// bitlengths may exceed RADIX bits) one limb to the right and puts the result
// in `rhi` and `rlo`. Both `rhi` and `rlo` cosist of at most RADIX bits.

.macro SRLI_V2 rhi:req, rlo:req, aex:req, ahi:req, alo:req
    srli    \rlo, \alo, RADIX
    add     \rlo, \rlo, \ahi
    srli    \rhi, \rlo, RADIX
    and     \rlo, \rlo, mask
    add     \rhi, \rhi, \aex
.endm


// The macro `DADD_V1` shifts `ahi` and `alo` 1 bit to the left (i.e., doubles
// them) and adds the shifted operands to `rhi` and `rlo`, respectively.
// NOTE: This macro does not include any carry propagation from `rlo` to `rhi`.

.macro DADD_V1 rhi:req, rlo:req, ahi:req, alo:req
    slli    \rhi, \ahi, 1
    slli    \rlo, \alo, 1
.endm


// The macro `DADD_V2` shifts `ahi` and `alo` 1 bit to the left (i.e., doubles
// them) and adds the shifted operands to `rhi` and `rlo`, respectively.
// NOTE: This macro does not include any carry propagation from `rlo` to `rhi`.

.macro DADD_V2 rhi:req, rlo:req, ahi:req, alo:req
    slli    \alo, \alo, 1
    add     \rlo, \rlo, \alo
    slli    \ahi, \ahi, 1
    add     \rhi, \rhi, \ahi
.endm


// The macro `DADD_V2` shifts `ahi` and `alo` 1 bit to the left (i.e., doubles
// them), adds the shifted operands to `rhi` and `rlo`, respectively, and puts
// the result in `rex`, `rhi`, and `rlo`. The result is converted to canonical
// limb-representation, which means each result-limb is at most RADIX bits long
// to prevent an overflow of `rlo` or `rhi` in subsequent multiply-accumulate
// operations.

.macro DADD_V3 rex:req, rhi:req, rlo:req, ahi:req, alo:req
    srli    \rex, \alo, RADIX
    add     \ahi, \ahi, \rex
    and     \alo, \alo, mask
    srli    \rex, \ahi, RADIX
    and     \ahi, \ahi, mask
    slli    \alo, \alo, 1
    add     \rlo, \rlo, \alo
    slli    \ahi, \ahi, 1
    add     \rhi, \rhi, \ahi
    slli    \rex, \rex, 1
.endm


// The macro `ST_LIMB` applies the bit-mask in `mask` to limb `lmb` and stores
// the result to `r[i]` in RAM if $1 \leq i < 8$. The actual address is the sum
// of the offset in `ofs` and the base address in `rptr` (i.e., $ofs = 4i$).
// When $i = 0$ or $i = 8$, the limb is stored in a register (either `rlsw` or
// `rmsw`) instead of RAM.

.macro ST_LIMB lmb:req, ofs:req
    .if (\ofs == 0) 
    and     rlsw, \lmb, mask
    .elseif (\ofs == 32)
    and     rmsw, \lmb, mask
    .else   // 4 <= ofs < 28
    and     tmp0, \lmb, mask
    sw      tmp0, \ofs(rptr)
    .endif
.endm


// The macro `MUL_CON` multiplies the limb-pair `ahi` and `alo` by the constant
// $64c$ in `rcon` and puts the double-length product in `rhi` and `rlo`.

.macro MUL_CON rhi:req, rlo:req, ahi:req, alo:req
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
    mul       \rhi, \ahi, rcon
    madd51hu  \rhi, \alo, rcon, \rhi
    madd51lu  \rlo, \alo, rcon, zero
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    mul       \rhi, \ahi, rcon
    madd51hu  \rhi, \alo, rcon
    mul       \rlo, \alo, rcon
    and       \rlo, \rlo, mask
#endif
.endm


// The macro `ADD_MSW` adds the limb `rmaw` to the limb-pair `shi` and `slo`.
// Then, it applies the bit-mask in `mask` to lower limb of the sum and stores
// the result to `r[8]` in RAM.

.macro ADD_MSW shi:req, slo:req
    add     \slo, \slo, rmsw
    and     rmsw, \slo, mask
    sw      rmsw, 32(rptr)
.endm


// The macro `ADD_LSW` shifts the limb-pair `shi` and `slo` RADIX bits to the
// right and multiplies the lower word of the result by the constant $64c$ in
// `rcon`. Then, it adds the limb `rlsw` to the product. The result is stored
// to `r[0]` in RAM.

.macro ADD_LSW shi:req, slo:req
    srli    \slo, \slo, RADIX
    add     \slo, \slo, \shi
    mul     \slo, \slo, rcon
    add     rlsw, rlsw, \slo
    sw      rlsw, 0(rptr)
.endm


///////////////////////////////////////////////////////////////////////////////
//////// HIGH-LEVEL MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION ////////
///////////////////////////////////////////////////////////////////////////////


// The macro `MULCOL8` computes the nine limb-products that form the result-
// limb `r[8]`, which are limb-products $a_i \cdot b_j$ with $i + j = 9$. These
// limb-products are accumulated into the "lower" column-sum in the limb-pair
// `sloh` and `slol`. Then, the limb in `slol` is stored to `r[8]` in RAM and
// the column-sum is shifted one limb (i.e., RADIX bits) to the right. Finally,
// the shifted column-sum is multiplied by the constant $64c$ and the product
// is put in the limb-pair `sloh` and `slol`.
// NOTE: Each limb of the The "lower" column-sum can get up to $RADIX + 4$ bits
// long; thus, a conversion to canonical limb-representation is required.

.macro MULCOL8
    MACC_V1 dblh, dbll, aw00, aw08
    MACC_V3 dblh, dbll, aw01, aw07
    MACC_V3 dblh, dbll, aw02, aw06
    MACC_V3 dblh, dbll, aw03, aw05
    MACC_V1 sloh, slol, aw04, aw04
    DADD_V3 slox, sloh, slol, dblh, dbll
    ST_LIMB slol, 32
    SRLI_V2 sloh, slol, slox, sloh, slol
    MUL_CON sloh, slol, sloh, slol
.endm


// The macro `MULCOL0` computes the nine limb-products that form the result-
// limb `r[0]`, which are limb-products $a_i \cdot b_j$ with $i + j = 0$ and
// $i + j = 9$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[0]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.
// NOTE: Each limb of "higher" column-sum can get up to $RADIX + 3$ bits long
// since `aw00` and `bw00` (which can exceed RADIX by 1 bit) are not operands
// of the multiply-accumulate operations that yield the "higher" column-sum.

.macro MULCOL0
    MACC_V3 sloh, slol, aw00, aw00
    MACC_V1 dblh, dbll, aw01, aw08
    MACC_V3 dblh, dbll, aw02, aw07
    MACC_V3 dblh, dbll, aw03, aw06
    MACC_V3 dblh, dbll, aw04, aw05
    DADD_V1 shih, shil, dblh, dbll
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 0
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL1` computes the nine limb-products that form the result-
// limb `r[1]`, which are limb-products $a_i \cdot b_j$ with $i + j = 1$ and
// $i + j = 10$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[1]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.

.macro MULCOL1
    MACC_V1 dblh, dbll, aw00, aw01
    DADD_V2 sloh, slol, dblh, dbll
    MACC_V1 dblh, dbll, aw02, aw08
    MACC_V3 dblh, dbll, aw03, aw07
    MACC_V3 dblh, dbll, aw04, aw06
    DADD_V2 shih, shil, dblh, dbll
    MACC_V3 shih, shil, aw05, aw05
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 4
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL2` computes the nine limb-products that form the result-
// limb `r[2]`, which are limb-products $a_i \cdot b_j$ with $i + j = 2$ and
// $i + j = 11$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[2]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.

.macro MULCOL2
    MACC_V1 dblh, dbll, aw00, aw02
    DADD_V2 sloh, slol, dblh, dbll
    MACC_V3 sloh, slol, aw01, aw01
    MACC_V1 dblh, dbll, aw03, aw08
    MACC_V3 dblh, dbll, aw04, aw07
    MACC_V3 dblh, dbll, aw05, aw06
    DADD_V2 shih, shil, dblh, dbll
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 8
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL3` computes the nine limb-products that form the result-
// limb `r[2]`, which are limb-products $a_i \cdot b_j$ with $i + j = 3$ and
// $i + j = 12$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[3]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.

.macro MULCOL3
    MACC_V1 dblh, dbll, aw00, aw03
    MACC_V3 dblh, dbll, aw01, aw02
    DADD_V2 sloh, slol, dblh, dbll
    MACC_V1 dblh, dbll, aw04, aw08
    MACC_V3 dblh, dbll, aw05, aw07
    DADD_V2 shih, shil, dblh, dbll
    MACC_V3 shih, shil, aw06, aw06
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 12
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL4` computes the nine limb-products that form the result-
// limb `r[4]`, which are limb-products $a_i \cdot b_j$ with $i + j = 4$ and
// $i + j = 13$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[4]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.

.macro MULCOL4
    MACC_V1 dblh, dbll, aw00, aw04
    MACC_V3 dblh, dbll, aw01, aw03
    DADD_V2 sloh, slol, dblh, dbll
    MACC_V3 sloh, slol, aw02, aw02
    MACC_V1 dblh, dbll, aw05, aw08
    MACC_V3 dblh, dbll, aw06, aw07
    DADD_V2 shih, shil, dblh, dbll
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 16
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL5` computes the nine limb-products that form the result-
// limb `r[5]`, which are limb-products $a_i \cdot b_j$ with $i + j = 5$ and
// $i + j = 14$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[5]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.

.macro MULCOL5
    MACC_V1 dblh, dbll, aw00, aw05
    MACC_V3 dblh, dbll, aw01, aw04
    MACC_V3 dblh, dbll, aw02, aw03
    DADD_V2 sloh, slol, dblh, dbll
    MACC_V1 dblh, dbll, aw06, aw08
    DADD_V2 shih, shil, dblh, dbll
    MACC_V3 shih, shil, aw07, aw07
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 20
    SRLI_V1 sloh, slol, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL6` computes the nine limb-products that form the result-
// limb `r[6]`, which are limb-products $a_i \cdot b_j$ with $i + j = 6$ and
// $i + j = 15$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[6]` in RAM. Finally, both column-
// sums are shifted one limb (i.e., RADIX bits) to the right.
// NOTE: The lower limb of the "lower" column-sum can get up to $RADIX + 4$
// bits long; thus, a conversion to canonical limb-representation is required.

.macro MULCOL6
    MACC_V1 dblh, dbll, aw00, aw06
    MACC_V3 dblh, dbll, aw01, aw05
    MACC_V3 dblh, dbll, aw02, aw04
    DADD_V3 slox, sloh, slol, dblh, dbll
    MACC_V3 sloh, slol, aw03, aw03
    MACC_V1 dblh, dbll, aw07, aw08
    DADD_V2 shih, shil, dblh, dbll
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 24
    SRLI_V2 sloh, slol, slox, sloh, slol
    SRLI_V1 shih, shil, shih, shil
.endm


// The macro `MULCOL7` computes the nine limb-products that form the result-
// limb `r[7]`, which are limb-products $a_i \cdot b_j$ with $i + j = 7$ and
// $i + j = 16$, respectively. The former limb-products are accumulated into
// the "lower" column-sum in the limb-pair `sloh` and `slol`, and the latter
// into the "higher" column-sum in the limb-pair `shih` and `shil`. Then, the
// limb `shil` of the "higher" clumn-sum is multiplied by the constant $64c$
// and the product is accumulated into the "lower" column-sum. The limb `slol`
// of the "lower" column-sum is stored to `r[7]` in RAM. Finally, the "lower"
// column-sum is shifted one limb (i.e., RADIX bits) to the right.
// NOTE: Each limb of the The "lower" column-sum can get up to $RADIX + 4$ bits
// long; thus, a conversion to canonical limb-representation is required.

.macro MULCOL7
    MACC_V1 dblh, dbll, aw00, aw07
    MACC_V3 dblh, dbll, aw01, aw06
    MACC_V3 dblh, dbll, aw02, aw05
    MACC_V3 dblh, dbll, aw03, aw04
    DADD_V3 slox, sloh, slol, dblh, dbll
    MACC_V3 shih, shil, aw08, aw08
    and     tmp0, shil, mask
    MACC_V3 sloh, slol, rcon, tmp0
    ST_LIMB slol, 28
    SRLI_V2 sloh, slol, slox, sloh, slol
    // SRLI_V1 shih, shil, shih, shil
.endm


// The macro `FINREDP` performs the final step of the reduction modulo $p$ by
// multiplying the lower word `shil` of the "higher" column-sum by the constant
// $64c$ and accumulating the double-length product into the "lower" column-sum
// in the limb-pair `sloh` and `slol` (macro `MACC_V3`). The lower limb of this
// sum is added to `r[8]` (macro `ADD_MSW`). Finally, the sum is shifted RADIX
// bits to the reight, multiplied by the constant $64c$, and the single-length
// product is added to `r[0]` (macro `ADD_LSW`).

.macro FINREDP
    srli    shil, shil, RADIX
    add     shil, shil, shih
    MACC_V3 sloh, slol, shil, rcon
    ADD_MSW sloh, slol
    ADD_LSW sloh, slol
.endm


///////////////////////////////////////////////////////////////////////////////
////////// HELPER MACROS FOR PRODUCT-SCANNING MODULAR MULTIPLICATION //////////
///////////////////////////////////////////////////////////////////////////////


// The macro `PROLOGUE` pushes 7 callee-saved registers on the stack.
// NOTE: The stack pointer should be 16-byte aligned!

.macro PROLOGUE
    addi    sp, sp, -32
    sw      s0, (sp)
    sw      s1, 4(sp)
    sw      s2, 8(sp)
    sw      s3, 12(sp)
    sw      s4, 16(sp)
    sw      s5, 20(sp)
    sw      s6, 24(sp)
.endm


// The macro `EPILOGUE` pops 7 callee-saved registers from the stack.

.macro EPILOGUE
    lw      s0, (sp)
    lw      s1, 4(sp)
    lw      s2, 8(sp)
    lw      s3, 12(sp)
    lw      s4, 16(sp)
    lw      s5, 20(sp)
    lw      s6, 24(sp)
    addi    sp, sp, 32
.endm


// The macro `INITVAR` initializes local variables (`mask` and `rcon`).

.macro INITVAR
    li      mask, -1
    srli    mask, mask, (32-RADIX)
    li      rcon, (CONSTC << SCALEC)  // (19 << 6) = 1216
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


///////////////////////////////////////////////////////////////////////////////
//////////// SPEED-OPTIMIZED PRIME-FIELD SQUARING (FULLY UNROLLED) ////////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field squaring is based on the product-scanning
// method and includes a reduction modulo $64p = 2^{261} - 1216$. It is aimed
// at high speed, which means the loops are fully unrolled. Each limb of array
// `a` is loaded from RAM exactly once, and each limb of the result-array `r`
// is stored to RAM exactly once.
// NOTE: The least-significant limb `r[0]` can be $RADIX + 1$ bits long.

.text
.global gfp_sqr_ise
.type gfp_sqr_ise,%function
// .balign 8
gfp_sqr_ise:
    PROLOGUE            // push callee-saved registers on stack
    INITVAR             // initalize local variables (`mask`, `rcon`)
    LDM_OPA             // load the eight words of array `a` from RAM
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
