#ifndef __BLS12_381_ASM_VECT_H__
#define __BLS12_381_ASM_VECT_H__


#include <stdint.h>
#include <stdio.h>


typedef uint64_t limb_t;

// full-radix representation: 64-bit-per-limb
#define LIMB_T_BITS   64

#define TO_LIMB_T(limb64)     limb64

#define NLIMBS(bits)   (bits/LIMB_T_BITS)

typedef limb_t vec384[NLIMBS(384)];
typedef limb_t vec768[NLIMBS(768)];
typedef vec384 vec384x[2];      /* 0 is "real" part, 1 is "imaginary" */

typedef unsigned char byte;

/*
 * Internal Boolean type, Boolean by value, hence safe to cast to or
 * reinterpret as 'bool'.
 */
typedef limb_t bool_t;


/*
 * Assembly subroutines...
 */
// add_mod_384 
void add_mod_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
void add_mod_384_isa(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
// sub_mod_384
void sub_mod_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
void sub_mod_384_isa(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
// mul_by_8_mod_384
void mul_by_8_mod_384(vec384 ret, const vec384 a, const vec384 p);
// mul_by_3_mod_384
void mul_by_3_mod_384(vec384 ret, const vec384 a, const vec384 p);
// cneg_mod_384
void cneg_mod_384_c(vec384 ret, const vec384 a, bool_t flag, const vec384 p);
void cneg_mod_384_isa(vec384 ret, const vec384 a, bool_t flag, const vec384 p);
// lshift_mod_384
void lshift_mod_384(vec384 ret, const vec384 a, size_t count, const vec384 p);

// mul_mont_384
void mul_mont_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p, limb_t n0);
void mul_mont_384_isa(vec384 ret, const vec384 a, const vec384 b, const vec384 p, limb_t n0);
void mul_mont_384_ise(vec384 ret, const vec384 a, const vec384 b, const vec384 p, limb_t n0);
// sqr_mont_384
void sqr_mont_384_c(vec384 ret, const vec384 a, const vec384 p, limb_t n0);
void sqr_mont_384_isa(vec384 ret, const vec384 a, const vec384 p, limb_t n0);
void sqr_mont_384_ise(vec384 ret, const vec384 a, const vec384 p, limb_t n0);
// redc_mont_384
void redc_mont_384_c(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
void redc_mont_384_isa(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
void redc_mont_384_ise(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
void _redc_mont_384_isa(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
void _redc_mont_384_ise(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
void _redc_once_384_isa(vec384 ret, const vec384 a, const vec384 p);
// mul_384
void mul_384_c(vec768 ret, const vec384 a, const vec384 b);
void mul_384_isa(vec768 ret, const vec384 a, const vec384 b);
void mul_384_ise(vec768 ret, const vec384 a, const vec384 b);
// sqr_384
void sqr_384_isa(vec768 ret, const vec384 a);

// void ct_inverse_mod_383(vec768 ret, const vec384 inp, const vec384 mod,
//                                                       const vec384 modx);
// currently use Fermat's Little Theorem instead 
// flt_inverse_mont_384
void flt_inverse_mont_384(vec384 ret, const vec384 inp, const vec384 p, 
                          limb_t n0);

// mul_mont_384x
void mul_mont_384x(vec384x ret, const vec384x a, const vec384x b,
                   const vec384 p, limb_t n0);
// sqr_mont_384x
void sqr_mont_384x(vec384x ret, const vec384x a, const vec384 p, limb_t n0);

// add_mod_384x
void add_mod_384x(vec384x ret, const vec384x a, const vec384x b,
                  const vec384 p);
// sub_mod_384x
void sub_mod_384x(vec384x ret, const vec384x a, const vec384x b,
                  const vec384 p);
// mul_by_8_mod_384x
void mul_by_8_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// mul_by_3_mod_384x
void mul_by_3_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// mul_by_1_plus_i_mod_384x
void mul_by_1_plus_i_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// add_mod_384x384
void add_mod_384x384_c(vec768 ret, const vec768 a, const vec768 b, const vec384 p);
void add_mod_384x384_isa(vec768 ret, const vec768 a, const vec768 b, const vec384 p);
// sub_mod_384x384
void sub_mod_384x384_c(vec768 ret, const vec768 a, const vec768 b, const vec384 p);
void sub_mod_384x384_isa(vec768 ret, const vec768 a, const vec768 b, const vec384 p);

/*
 * Select what implementations to use
 */
#if (ISE)
#define mul_384         mul_384_ise
#define redc_mont_384   redc_mont_384_ise
#define mul_mont_384    mul_mont_384_ise
#define sqr_mont_384    sqr_mont_384_ise
#define _redc_mont_384  _redc_mont_384_ise
#elif (ISA)
#define mul_384         mul_384_isa
#define redc_mont_384   redc_mont_384_isa
#define mul_mont_384    mul_mont_384_isa
#define sqr_mont_384    sqr_mont_384_isa
#define _redc_mont_384  _redc_mont_384_isa
#endif
#define add_mod_384     add_mod_384_isa
#define sub_mod_384     sub_mod_384_isa
#define cneg_mod_384    cneg_mod_384_isa 
#define add_mod_384x384 add_mod_384x384_isa
#define sub_mod_384x384 sub_mod_384x384_isa

#define restrict __restrict__

# define launder(var) asm volatile("" : "+r"(var))

static inline void vec_cswap(void *restrict a, void *restrict b, size_t num,
                             bool_t cbit)
{
    limb_t ai, *ap = (limb_t *)a;
    limb_t bi, *bp = (limb_t *)b;
    limb_t xorm, mask = (limb_t)0 - cbit;
    size_t i;

    num /= sizeof(limb_t);

    for (i = 0; i < num; i++) {
        xorm = ((ai = ap[i]) ^ (bi = bp[i])) & mask;
        ap[i] = ai ^ xorm;
        bp[i] = bi ^ xorm;
    }
}

static inline void vec_select(void *ret, const void *a, const void *b,
                              size_t num, bool_t sel_a)
{
    launder(sel_a);
    limb_t bi;
    volatile limb_t *rp = (limb_t *)ret;
    const limb_t *ap = (const limb_t *)a;
    const limb_t *bp = (const limb_t *)b;
    limb_t xorm, mask = (limb_t)0 - sel_a;
    size_t i;

    num /= sizeof(limb_t);

    for (i = 0; i < num; i++) {
        xorm = (ap[i] ^ (bi = bp[i])) & mask;
        rp[i] = bi ^ xorm;
    }
}

static inline bool_t is_zero(limb_t l)
{
    limb_t ret = (~l & (l - 1)) >> (LIMB_T_BITS - 1);
    launder(ret);
    return ret;
}

static inline bool_t vec_is_zero(const void *a, size_t num)
{
    const limb_t *ap = (const limb_t *)a;
    limb_t acc;
    size_t i;

    num /= sizeof(limb_t);

    for (acc = 0, i = 0; i < num; i++)
        acc |= ap[i];

    return is_zero(acc);
}

static inline bool_t vec_is_equal(const void *a, const void *b, size_t num)
{
    const limb_t *ap = (const limb_t *)a;
    const limb_t *bp = (const limb_t *)b;
    limb_t acc;
    size_t i;

    num /= sizeof(limb_t);

    for (acc = 0, i = 0; i < num; i++)
        acc |= ap[i] ^ bp[i];

    return is_zero(acc);
}

static inline void vec_copy(void *restrict ret, const void *a, size_t num)
{
    limb_t *rp = (limb_t *)ret;
    const limb_t *ap = (const limb_t *)a;
    size_t i;

    num /= sizeof(limb_t);

    for (i = 0; i < num; i++)
        rp[i] = ap[i];
}

static inline void vec_zero(void *ret, size_t num)
{
    volatile limb_t *rp = (volatile limb_t *)ret;
    size_t i;

    num /= sizeof(limb_t);

    for (i = 0; i < num; i++)
        rp[i] = 0;

#if defined(__GNUC__) || defined(__clang__)
    asm volatile("" : : "r"(ret) : "memory");
#endif
}

#endif /* __BLS12_381_ASM_VECT_H__ */
