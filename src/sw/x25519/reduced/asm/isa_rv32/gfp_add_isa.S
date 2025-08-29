// Function prototype:
// -------------------
// void gfp_add_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_add_isa` computes the sum $r = a + b \bmod p$ of two
// elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is the
// 255-bit pseudo-Mersenne prime $p = 2^{255} - 19$, but the reduction is
// actually performed modulo $64p$. Hence, the result can be $9*RADIX = 261$
// bits long. The least-significant limb of operands $a$ and $b$ are allowed to
// be $RADIX + 1$ bits long. Also the least-sigfinicant limb of the result can
// be $RADIX + 1$ bit long, but all other limbs have a length of $RADIX$ bits.
//
// Parameters:
// -----------
// `r`: pointer to array for the nine 29-bit limbs of the result $r$.
// `a`: pointer to array containing the nine 29-bit limbs of operand $a$.
// `b`: pointer to array containing the nine 29-bit limbs of operand $b$.


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
// Register `bptr` holds the start address of array `b`
#define bptr a2
// Registers `lsum` and `rlsl` hold limbs of the result
#define lsum a3
#define rlsl a4
// Registers `almb` and `blmb` hold 2 limbs of operands
#define almb a5
#define blmb a6
// Registers `mask` and `rcon` hold 0x1FFFFFFF and 64*c
#define mask a7
#define rcon t0


///////////////////////////////////////////////////////////////////////////////
/////////////////// MACROS FOR LIMB-WISE ADDITION OPERATIONS //////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `ADDL_V1` loads the limbs `a[i]` and `b[i]` from RAM, adds them
// together, and puts the sum in `sum`. Then, it applies the bit-mask in `mask`
// to the sum and puts the result in `rlsl`. Futhermore, `rcon` is initialized
// with the constant $64c = 1216$.

.macro ADDL_V1 sum:req, i:req
    lw      almb, \i(aptr)
    lw      blmb, \i(bptr)
    li      rcon, (CONSTC << SCALEC)  // (19 << 6) = 1216
    add     \sum, almb, blmb
    and     rlsl, \sum, mask
.endm


// The macro `ADDL_V2` loads the limbs `a[i]` and `b[i]` from RAM, shifts the
// previous sum in `sum` RADIX bits to the right, and adds the two limbs to the
// shifted sum. Then, it applies the bit-mask in `mask` to the sum and stores
// the result to `r[i]` in RAM. The actual address is the sum of the offset in
// `ofs` and the base address in `rptr` (i.e., $ofs = 4i$).

.macro ADDL_V2 sum:req, i:req
    lw      almb, \i(aptr)
    lw      blmb, \i(bptr)
    srai    \sum, \sum, RADIX
    add     \sum, \sum, almb
    add     \sum, \sum, blmb
    and     almb, \sum, mask
    sw      almb, \i(rptr)
.endm


// The macro `MODREDP` shifts the previous sum in `sum` RADIX bits to the
// right, multiplies it by the constant $64c$ in `rcon` and adds the least-
// significant result-limb in `rlsl` to the product. Then, it applies the bit- 
// mask in `mask` to the sum and stores the result to `r[i]` in RAM. The actual
// address is the sum of the offset in `ofs` and the base address in `rptr`
// (i.e., $ofs = 4i$).
// NOTE: The result-limb `r[i]` can be $RADIX + 1$ bits long.

.macro MODREDP sum:req, i:req
    srai    \sum, \sum, RADIX
    mul     \sum, \sum, rcon
    add     rlsl, rlsl, \sum
    sw      rlsl, \i(rptr)
.endm


// The macro `INITVAR` initializes local variables (`mask`).

.macro INITVAR
    li      mask, -1
    srli    mask, mask, (32-RADIX)
.endm


///////////////////////////////////////////////////////////////////////////////
//////////// SPEED-OPTIMIZED PRIME-FIELD ADDITIONN (FULLY UNROLLED) ///////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field addition includes a reduction modulo
// $64p = 2^{261} - 1216$. It is aimed at high speed, which means the loop is
// fully unrolled. Each limb of arrays `a` and `b` is loaded from RAM exactly
// once, and each limb of the result-array `r` is stored to RAM exactly once.
// NOTE: The least-significant limb `r[0]` can be $RADIX + 1$ bits long.

.text
.global gfp_add_isa
.type gfp_add_isa,%function
// .balign 8
gfp_add_isa:
    INITVAR
    ADDL_V1 lsum, 0
    ADDL_V2 lsum, 4
    ADDL_V2 lsum, 8
    ADDL_V2 lsum, 12
    ADDL_V2 lsum, 16
    ADDL_V2 lsum, 20
    ADDL_V2 lsum, 24
    ADDL_V2 lsum, 28
    ADDL_V2 lsum, 32
    MODREDP lsum, 0
    ret


.end
