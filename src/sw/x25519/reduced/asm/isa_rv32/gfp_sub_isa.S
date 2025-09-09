// Function prototype:
// -------------------
// void gfp_sub_isa(uint32_t *r, const uint32_t *a, const uint32_t *b);
//
// Description:
// ------------
// The function `gfp_sub_isa` computes the difference $r = a + b \bmod p$ of
// two elements $a$ and $b$ of a pseudo-Mersenne prime field. The prime $p$ is
// the 255-bit pseudo-Mersenne prime $p = 2^{255} - 19$, but the reduction is
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
// Registers `ldif` and `rlsl` hold limbs of the result
#define ldif a3
#define rlsl a4
// Registers `almb` and `blmb` hold 2 limbs of operands
#define almb a5
#define blmb a6
// Registers `mask` and `rcon` hold 0x1FFFFFFF and 64*c
#define mask a7
#define rcon t0


///////////////////////////////////////////////////////////////////////////////
///////////////// MACROS FOR LIMB-WISE SUBTRACTION OPERATIONS /////////////////
///////////////////////////////////////////////////////////////////////////////


// The macro `ADDL_V1` loads the limbs `a[i]` and `b[i]` from RAM, subtracts
// the latter together with twice the constant $64c$ from the former and puts
// the difference (which can be negative) in `dif`. Then, it applies the bit-
// mask in `mask` to the difference and puts the result in `rlsl`. Futhermore,
// `rcon` is initialized with the constant $64c = 1216$.

.macro SUBL_V1 dif:req, i:req
    lw      almb, \i(aptr)
    lw      blmb, \i(bptr)
    li      rcon, (CONSTC << SCALEC)  // (19 << 6) = 1216
    sub     \dif, almb, blmb
    sub     \dif, \dif, rcon
    sub     \dif, \dif, rcon
    and     rlsl, \dif, mask
.endm


// The macro `SUBL_V2` loads the limbs `a[i]` and `b[i]` from RAM, shifts the
// previous difference in `dif`, which can be negative, arithmetically RADIX
// bits to the right (i.e., the sign is preserved), adds the former limb to and
// and subtracts the latter limb from the shifted difference. Then, it applies
// the bit-mask in `mask` to the difference and stores the result to `r[i]` in
// RAM. The actual address is the sum of the offset in `ofs` and the base
// address in `rptr` (i.e., $ofs = 4i$).

.macro SUBL_V2 sum:req, i:req
    lw      almb, \i(aptr)
    lw      blmb, \i(bptr)
    srai    \sum, \sum, RADIX
    add     \sum, \sum, almb
    sub     \sum, \sum, blmb
    and     almb, \sum, mask
    sw      almb, \i(rptr)
.endm


// The macro `SUBL_V3` loads the limbs `a[i]` and `b[i]` from RAM, shifts the
// previous difference in `dif`, which can be negative, arithmetically RADIX
// bits to the right (i.e., the sign is preserved), and adds two times `mask`
// plus 2 (i.e., 0x40000000) to the shifted difference. Furthermore, the first
// loaded limb is added to `dif` and the second loaded limb is subtracted from
// `dif`. Then, the macro applies the bit-mask in `mask` to the difference and
// stores the result to `r[i]` in RAM. The actual address is the sum of the
// offset in `ofs` and the base address in `rptr` (i.e., $ofs = 4i$).

.macro SUBL_V3 sum:req, i:req
    lw      almb, \i(aptr)
    lw      blmb, \i(bptr)
    srai    \sum, \sum, RADIX
    add     \sum, \sum, almb
    sub     \sum, \sum, blmb
    add     \sum, \sum, mask
    add     \sum, \sum, mask
    addi    \sum, \sum, 2
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
/////////// SPEED-OPTIMIZED PRIME-FIELD SUBTRACTION (FULLY UNROLLED) //////////
///////////////////////////////////////////////////////////////////////////////


// This implementation of prime-field subtraction includes a reduction modulo
// $64p = 2^{261} - 1216$. It is aimed at high speed, which means the loop is
// fully unrolled. In order to ensure that the final result is positive, the
// operation actually performed is $r = 128p + a - b \bmod 64p$. Each limb of
// arrays `a` and `b` is loaded from RAM exactly once, and each limb of the
// result-array `r` is stored to RAM exactly once.
// NOTE: The least-significant limb `r[0]` can be $RADIX + 1$ bits long.

.text
.global gfp_sub_isa
.type gfp_sub_isa,%function
// .balign 8
gfp_sub_isa:
    INITVAR
    SUBL_V1 ldif, 0
    SUBL_V2 ldif, 4
    SUBL_V2 ldif, 8
    SUBL_V2 ldif, 12
    SUBL_V2 ldif, 16
    SUBL_V2 ldif, 20
    SUBL_V2 ldif, 24
    SUBL_V2 ldif, 28
    SUBL_V3 ldif, 32
    MODREDP ldif, 0
    ret


.end
