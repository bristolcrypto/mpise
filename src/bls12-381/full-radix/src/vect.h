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
// done 
void add_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
// done
void sub_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p);
// done
void mul_by_8_mod_384(vec384 ret, const vec384 a, const vec384 p);
// done
void mul_by_3_mod_384(vec384 ret, const vec384 a, const vec384 p);
// done
void cneg_mod_384(vec384 ret, const vec384 a, bool_t flag, const vec384 p);
// done
void lshift_mod_384(vec384 ret, const vec384 a, size_t count, const vec384 p);

// done
void mul_mont_384(vec384 ret, const vec384 a, const vec384 b,
                  const vec384 p, limb_t n0);
// done
void sqr_mont_384(vec384 ret, const vec384 a, const vec384 p, limb_t n0);
// done
void redc_mont_384(vec384 ret, const vec768 a, const vec384 p, limb_t n0);
// done
void mul_384(vec768 ret, const vec384 a, const vec384 b);

// void ct_inverse_mod_383(vec768 ret, const vec384 inp, const vec384 mod,
//                                                       const vec384 modx);
// currently use Fermat's Little Theorem instead 
// done
void flt_inverse_mont_384(vec384 ret, const vec384 inp, const vec384 p, 
                          limb_t n0);

// done
void mul_mont_384x(vec384x ret, const vec384x a, const vec384x b,
                   const vec384 p, limb_t n0);
// done
void sqr_mont_384x(vec384x ret, const vec384x a, const vec384 p, limb_t n0);

// done
void add_mod_384x(vec384x ret, const vec384x a, const vec384x b,
                  const vec384 p);
// done
void sub_mod_384x(vec384x ret, const vec384x a, const vec384x b,
                  const vec384 p);
// done
void mul_by_8_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// done
void mul_by_3_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// done
void mul_by_1_plus_i_mod_384x(vec384x ret, const vec384x a, const vec384 p);
// done
void add_mod_384x384(vec768 ret, const vec768 a, const vec768 b,
                     const vec384 p);
// done
void sub_mod_384x384(vec768 ret, const vec768 a, const vec768 b,
                     const vec384 p);

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
