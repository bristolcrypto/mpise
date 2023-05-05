#include "fields.h"


/*
 * Fp2  = Fp[u]  / (u^2 + 1)
 * Fp6  = Fp2[v] / (v^3 - u - 1)
 * Fp12 = Fp6[w] / (w^2 - v)
 */

void mul_by_u_plus_1_fp2(vec384x ret, const vec384x a)
{   mul_by_1_plus_i_mod_384x(ret, a, BLS12_381_P);   }

/*
 * Fp2x2 is a "widened" version of Fp2, which allows to consolidate
 * reductions from several multiplications. In other words instead of
 * "mul_redc-mul_redc-add" we get "mul-mul-add-redc," where latter
 * addition is double-width... To be more specific this gives ~7-10%
 * faster pairing depending on platform...
 */
#define __FP2x2__

#if defined(__FP2x2__) 

void add_fp2x2(vec768x ret, const vec768x a, const vec768x b)
{
    add_mod_384x384(ret[0], a[0], b[0], BLS12_381_P);
    add_mod_384x384(ret[1], a[1], b[1], BLS12_381_P);
}

void sub_fp2x2(vec768x ret, const vec768x a, const vec768x b)
{
    sub_mod_384x384(ret[0], a[0], b[0], BLS12_381_P);
    sub_mod_384x384(ret[1], a[1], b[1], BLS12_381_P);
}

void mul_by_u_plus_1_fp2x2(vec768x ret, const vec768x a)
{
    /* caveat lector! |ret| may not be same as |a| */
    sub_mod_384x384(ret[0], a[0], a[1], BLS12_381_P);
    add_mod_384x384(ret[1], a[0], a[1], BLS12_381_P);
}

void redc_fp2x2(vec384x ret, const vec768x a)
{
    redc_mont_384(ret[0], a[0], BLS12_381_P, p0);
    redc_mont_384(ret[1], a[1], BLS12_381_P, p0);
}

void mul_fp2x2(vec768x ret, const vec384x a, const vec384x b)
{
#if 0
    mul_382x(ret, a, b, BLS12_381_P);   /* +~6% in Miller loop */
#elif 0
    union { vec384 x[2]; vec768 x2; } t;

    add_mod_384(t.x[0], a[0], a[1], BLS12_381_P);
    add_mod_384(t.x[1], b[0], b[1], BLS12_381_P);
    mul_384(ret[1], t.x[0], t.x[1]);

    mul_384(ret[0], a[0], b[0]);
    mul_384(t.x2,   a[1], b[1]);

    sub_mod_384x384(ret[1], ret[1], ret[0], BLS12_381_P);
    sub_mod_384x384(ret[1], ret[1], t.x2, BLS12_381_P);

    sub_mod_384x384(ret[0], ret[0], t.x2, BLS12_381_P);
#else
    vec768 t0, t1, t2, t3;

    mul_384(t0, a[0], b[0]);
    mul_384(t1, a[0], b[1]);
    mul_384(t2, a[1], b[0]);
    mul_384(t3, a[1], b[1]);

    sub_mod_384x384(ret[0], t0, t3, BLS12_381_P);
    add_mod_384x384(ret[1], t1, t2, BLS12_381_P);
#endif
}

void sqr_fp2x2(vec768x ret, const vec384x a)
{
#if 0
    sqr_382x(ret, a, BLS12_381_P);      /* +~5% in final exponentiation */
#elif 1
    vec384 t0, t1;

    add_mod_384(t0, a[0], a[1], BLS12_381_P);
    sub_mod_384(t1, a[0], a[1], BLS12_381_P);

    mul_384(ret[1], a[0], a[1]);
    add_mod_384x384(ret[1], ret[1], ret[1], BLS12_381_P);

    mul_384(ret[0], t0, t1);
#else
    vec768 t0, t1;
    vec384 t2;

    add_mod_384(t2, a[0], a[0], BLS12_381_P);

    mul_384(t0, a[0], a[0]);
    mul_384(t1, a[1], a[1]);

    mul_384(ret[1], t2, a[1]);
    sub_mod_384x384(ret[0], t0, t1, BLS12_381_P);
#endif
}
#endif

/*
 * Fp6 extension
 */
#if defined(__FP2x2__) 

void sub_fp6x2(vec768fp6 ret, const vec768fp6 a, const vec768fp6 b)
{
    sub_fp2x2(ret[0], a[0], b[0]);
    sub_fp2x2(ret[1], a[1], b[1]);
    sub_fp2x2(ret[2], a[2], b[2]);
}

void mul_fp6x2(vec768fp6 ret, const vec384fp6 a, const vec384fp6 b)
{
#if (ISA)
    vec768x t0, t1, t2;
    vec384x aa, bb;

    mul_fp2x2(t0, a[0], b[0]);
    mul_fp2x2(t1, a[1], b[1]);
    mul_fp2x2(t2, a[2], b[2]);

    /* ret[0] = ((a1 + a2)*(b1 + b2) - a1*b1 - a2*b2)*(u+1) + a0*b0
              = (a1*b2 + a2*b1)*(u+1) + a0*b0 */
    add_fp2(aa, a[1], a[2]);
    add_fp2(bb, b[1], b[2]);
    mul_fp2x2(ret[0], aa, bb);
    sub_fp2x2(ret[0], ret[0], t1);
    sub_fp2x2(ret[0], ret[0], t2);
    mul_by_u_plus_1_fp2x2(ret[1], ret[0]);  /* borrow ret[1] for a moment */
    add_fp2x2(ret[0], ret[1], t0);

    /* ret[1] = (a0 + a1)*(b0 + b1) - a0*b0 - a1*b1 + a2*b2*(u+1)
              = a0*b1 + a1*b0 + a2*b2*(u+1) */
    add_fp2(aa, a[0], a[1]);
    add_fp2(bb, b[0], b[1]);
    mul_fp2x2(ret[1], aa, bb);
    sub_fp2x2(ret[1], ret[1], t0);
    sub_fp2x2(ret[1], ret[1], t1);
    mul_by_u_plus_1_fp2x2(ret[2], t2);      /* borrow ret[2] for a moment */
    add_fp2x2(ret[1], ret[1], ret[2]);

    /* ret[2] = (a0 + a2)*(b0 + b2) - a0*b0 - a2*b2 + a1*b1
              = a0*b2 + a2*b0 + a1*b1 */
    add_fp2(aa, a[0], a[2]);
    add_fp2(bb, b[0], b[2]);
    mul_fp2x2(ret[2], aa, bb);
    sub_fp2x2(ret[2], ret[2], t0);
    sub_fp2x2(ret[2], ret[2], t2);
    add_fp2x2(ret[2], ret[2], t1);
#elif (ISE)
    vec768x t0, t1, t2;

    /* ret[0] = (a1*b2 + a2*b1)*(u+1) + a0*b0 */
    mul_fp2x2(t0, a[0], b[0]);
    mul_fp2x2(t1, a[1], b[2]); 
    mul_fp2x2(t2, a[2], b[1]);
    add_fp2x2(t1, t1, t2);
    mul_by_u_plus_1_fp2x2(ret[0], t1);
    add_fp2x2(ret[0], ret[0], t0);

    /* ret[1] = a0*b1 + a1*b0 + a2*b2*(u+1) */
    mul_fp2x2(t0, a[0], b[1]);
    mul_fp2x2(t1, a[1], b[0]);
    mul_fp2x2(t2, a[2], b[2]);
    mul_by_u_plus_1_fp2x2(ret[1], t2);
    add_fp2x2(ret[1], ret[1], t0);
    add_fp2x2(ret[1], ret[1], t1);

    /* ret[2] = a0*b2 + a2*b0 + a1*b1 */
    mul_fp2x2(t0, a[0], b[2]);
    mul_fp2x2(t1, a[1], b[1]);
    mul_fp2x2(t2, a[2], b[0]);
    add_fp2x2(ret[2], t0, t2);
    add_fp2x2(ret[2], ret[2], t1);
#endif
}

void redc_fp6x2(vec384fp6 ret, const vec768fp6 a)
{
    redc_fp2x2(ret[0], a[0]);
    redc_fp2x2(ret[1], a[1]);
    redc_fp2x2(ret[2], a[2]);
}

void mul_fp6(vec384fp6 ret, const vec384fp6 a, const vec384fp6 b)
{
    vec768fp6 r;

    mul_fp6x2(r, a, b);
    redc_fp6x2(ret, r); /* narrow to normal width */
}

void sqr_fp6(vec384fp6 ret, const vec384fp6 a)
{
#if (ISA)
    vec768x s0, m01, m12, s2, rx;

    sqr_fp2x2(s0, a[0]);

    mul_fp2x2(m01, a[0], a[1]);
    add_fp2x2(m01, m01, m01);

    mul_fp2x2(m12, a[1], a[2]);
    add_fp2x2(m12, m12, m12);

    sqr_fp2x2(s2, a[2]);

    /* ret[2] = (a0 + a1 + a2)^2 - a0^2 - a2^2 - 2*(a0*a1) - 2*(a1*a2)
              = a1^2 + 2*(a0*a2) */
    add_fp2(ret[2], a[2], a[1]);
    add_fp2(ret[2], ret[2], a[0]);
    sqr_fp2x2(rx, ret[2]);
    sub_fp2x2(rx, rx, s0);
    sub_fp2x2(rx, rx, s2);
    sub_fp2x2(rx, rx, m01);
    sub_fp2x2(rx, rx, m12);
    redc_fp2x2(ret[2], rx);

    /* ret[0] = a0^2 + 2*(a1*a2)*(u+1) */
    mul_by_u_plus_1_fp2x2(rx, m12);
    add_fp2x2(rx, rx, s0);
    redc_fp2x2(ret[0], rx);

    /* ret[1] = a2^2*(u+1) + 2*(a0*a1) */
    mul_by_u_plus_1_fp2x2(rx, s2);
    add_fp2x2(rx, rx, m01);
    redc_fp2x2(ret[1], rx);
#elif (ISE)
    vec768x t0, t1;
    vec384x s0, s1;

    add_fp2(s0, a[0], a[0]);
    add_fp2(s1, a[1], a[1]);

    /* ret[0] = a0^2 + 2*(a1*a2)*(u+1) */
    mul_fp2x2(t1, s1, a[2]);
    mul_by_u_plus_1_fp2x2(t0, t1);
    sqr_fp2x2(t1, a[0]);
    add_fp2x2(t0, t0, t1);
    redc_fp2x2(ret[0], t0);

    /* ret[1] = a2^2*(u+1) + 2*(a0*a1) */
    sqr_fp2x2(t1, a[2]);
    mul_by_u_plus_1_fp2x2(t0, t1);
    mul_fp2x2(t1, s0, a[1]);
    add_fp2x2(t0, t0, t1);
    redc_fp2x2(ret[1], t0);

    /* ret[2] = a1^2 + 2*(a0*a2) */
    sqr_fp2x2(t0, a[1]);
    mul_fp2x2(t1, s0, a[2]);
    add_fp2x2(t0, t0, t1);
    redc_fp2x2(ret[2], t0);
#endif
}
#endif

void add_fp6(vec384fp6 ret, const vec384fp6 a, const vec384fp6 b)
{
    add_fp2(ret[0], a[0], b[0]);
    add_fp2(ret[1], a[1], b[1]);
    add_fp2(ret[2], a[2], b[2]);
}

void sub_fp6(vec384fp6 ret, const vec384fp6 a, const vec384fp6 b)
{
    sub_fp2(ret[0], a[0], b[0]);
    sub_fp2(ret[1], a[1], b[1]);
    sub_fp2(ret[2], a[2], b[2]);
}

void neg_fp6(vec384fp6 ret, const vec384fp6 a)
{
    neg_fp2(ret[0], a[0]);
    neg_fp2(ret[1], a[1]);
    neg_fp2(ret[2], a[2]);
}

/*
 * Fp12 extension
 */
#if defined(__FP2x2__)
void mul_fp12(vec384fp12 ret, const vec384fp12 a, const vec384fp12 b)
{
#if 1
    vec768fp6 t0, t1, rx;
    vec384fp6 t2;

    mul_fp6x2(t0, a[0], b[0]);
    mul_fp6x2(t1, a[1], b[1]);

    /* ret[1] = (a0 + a1)*(b0 + b1) - a0*b0 - a1*b1
              = a0*b1 + a1*b0 */
    add_fp6(t2, a[0], a[1]);
    add_fp6(ret[1], b[0], b[1]);
    mul_fp6x2(rx, ret[1], t2);
    sub_fp6x2(rx, rx, t0);
    sub_fp6x2(rx, rx, t1);
    redc_fp6x2(ret[1], rx);

    /* ret[0] = a0*b0 + a1*b1*v */
    mul_by_u_plus_1_fp2x2(rx[0], t1[2]);
    add_fp2x2(rx[0], t0[0], rx[0]);
    add_fp2x2(rx[1], t0[1], t1[0]);
    add_fp2x2(rx[2], t0[2], t1[1]);
    redc_fp6x2(ret[0], rx);
#else
    vec768fp6 t0, t1, t2, t3, rx;

    mul_fp6x2(t0, a[0], b[0]);
    mul_fp6x2(t1, a[0], b[1]);
    mul_fp6x2(t2, a[1], b[0]);
    mul_fp6x2(t3, a[1], b[1]);

    /* ret[0] = a0*b0 + a1*b1*v */
    mul_by_u_plus_1_fp2x2(rx[0], t3[2]);
    add_fp2x2(rx[0], t0[0], rx[0]);
    add_fp2x2(rx[1], t0[1], t3[0]);
    add_fp2x2(rx[2], t0[2], t3[1]);
    redc_fp6x2(ret[0], rx);

    /* ret[1] = a0*b1 + a1*b0 */
    add_fp2x2(t1[0], t1[0], t2[0]);
    add_fp2x2(t1[1], t1[1], t2[1]);
    add_fp2x2(t1[2], t1[2], t2[2]);
    redc_fp6x2(ret[1], t1);
#endif
}

void mul_by_0y0_fp6x2(vec768fp6 ret, const vec384fp6 a, const vec384fp2 b)
{
    mul_fp2x2(ret[1], a[2], b);     /* borrow ret[1] for a moment */
    mul_by_u_plus_1_fp2x2(ret[0], ret[1]);
    mul_fp2x2(ret[1], a[0], b);
    mul_fp2x2(ret[2], a[1], b);
}

void mul_by_xy0_fp6x2(vec768fp6 ret, const vec384fp6 a, const vec384fp6 b)
{
#if (ISA)
    vec768x t0, t1;
    vec384x aa, bb;

    mul_fp2x2(t0, a[0], b[0]);
    mul_fp2x2(t1, a[1], b[1]);

    /* ret[0] = ((a1 + a2)*(b1 + 0) - a1*b1 - a2*0)*(u+1) + a0*b0
              = (a1*0 + a2*b1)*(u+1) + a0*b0 */
    mul_fp2x2(ret[1], a[2], b[1]);  /* borrow ret[1] for a moment */
    mul_by_u_plus_1_fp2x2(ret[0], ret[1]);
    add_fp2x2(ret[0], ret[0], t0);

    /* ret[1] = (a0 + a1)*(b0 + b1) - a0*b0 - a1*b1 + a2*0*(u+1)
              = a0*b1 + a1*b0 + a2*0*(u+1) */
    add_fp2(aa, a[0], a[1]);
    add_fp2(bb, b[0], b[1]);
    mul_fp2x2(ret[1], aa, bb);
    sub_fp2x2(ret[1], ret[1], t0);
    sub_fp2x2(ret[1], ret[1], t1);

    /* ret[2] = (a0 + a2)*(b0 + 0) - a0*b0 - a2*0 + a1*b1
              = a0*0 + a2*b0 + a1*b1 */
    mul_fp2x2(ret[2], a[2], b[0]);
    add_fp2x2(ret[2], ret[2], t1);
#elif (ISE) 
    vec768x t0, t1;

    /* ret[0] = (a1*0 + a2*b1)*(u+1) + a0*b0 */
    mul_fp2x2(t0, a[0], b[0]);
    mul_fp2x2(t1, a[2], b[1]);
    mul_by_u_plus_1_fp2x2(ret[0], t1);
    add_fp2x2(ret[0], ret[0], t0);

    /* ret[1] = a0*b1 + a1*b0 + a2*0*(u+1) */
    mul_fp2x2(t0, a[0], b[1]);
    mul_fp2x2(t1, a[1], b[0]);
    add_fp2x2(ret[1], t0, t1);

    /* ret[2] = a0*0 + a2*b0 + a1*b1 */
    mul_fp2x2(t0, a[1], b[1]);
    mul_fp2x2(t1, a[2], b[0]);
    add_fp2x2(ret[2], t0, t1);
#endif
}

void mul_by_xy00z0_fp12(vec384fp12 ret, const vec384fp12 a, const vec384fp6 xy00z0)
{
    vec768fp6 t0, t1, rr;
    vec384fp6 t2;

    mul_by_xy0_fp6x2(t0, a[0], xy00z0);
    mul_by_0y0_fp6x2(t1, a[1], xy00z0[2]);

    /* ret[1] = (a0 + a1)*(b0 + b1) - a0*b0 - a1*b1
              = a0*b1 + a1*b0 */
    vec_copy(t2[0], xy00z0[0], sizeof(t2[0]));
    add_fp2(t2[1], xy00z0[1], xy00z0[2]);
    add_fp6(ret[1], a[0], a[1]);
    mul_by_xy0_fp6x2(rr, ret[1], t2);
    sub_fp6x2(rr, rr, t0);
    sub_fp6x2(rr, rr, t1);
    redc_fp6x2(ret[1], rr);

    /* ret[0] = a0*b0 + a1*b1*v */
    mul_by_u_plus_1_fp2x2(rr[0], t1[2]);
    add_fp2x2(rr[0], t0[0], rr[0]);
    add_fp2x2(rr[1], t0[1], t1[0]);
    add_fp2x2(rr[2], t0[2], t1[1]);
    redc_fp6x2(ret[0], rr);
}
#endif

void sqr_fp12(vec384fp12 ret, const vec384fp12 a)
{
    vec384fp6 t0, t1;

    add_fp6(t0, a[0], a[1]);
    mul_by_u_plus_1_fp2(t1[2], a[1][2]);
    add_fp2(t1[0], a[0][0], t1[2]);
    add_fp2(t1[1], a[0][1], a[1][0]);
    add_fp2(t1[2], a[0][2], a[1][1]);
    mul_fp6(t0, t0, t1);
    mul_fp6(t1, a[0], a[1]);

    /* ret[1] = 2*(a0*a1) */
    add_fp6(ret[1], t1, t1);

    /* ret[0] = (a0 + a1)*(a0 + a1*v) - a0*a1 - a0*a1*v
              = a0^2 + a1^2*v */
    sub_fp6(ret[0], t0, t1);
    mul_by_u_plus_1_fp2(t1[2], t1[2]);
    sub_fp2(ret[0][0], ret[0][0], t1[2]);
    sub_fp2(ret[0][1], ret[0][1], t1[0]);
    sub_fp2(ret[0][2], ret[0][2], t1[1]);
}

void conjugate_fp12(vec384fp12 a)
{   neg_fp6(a[1], a[1]);   }

void inverse_fp6(vec384fp6 ret, const vec384fp6 a)
{
    vec384x c0, c1, c2, t0, t1;

    /* c0 = a0^2 - (a1*a2)*(u+1) */
    sqr_fp2(c0, a[0]);
    mul_fp2(t0, a[1], a[2]);
    mul_by_u_plus_1_fp2(t0, t0);
    sub_fp2(c0, c0, t0);

    /* c1 = a2^2*(u+1) - (a0*a1) */
    sqr_fp2(c1, a[2]);
    mul_by_u_plus_1_fp2(c1, c1);
    mul_fp2(t0, a[0], a[1]);
    sub_fp2(c1, c1, t0);

    /* c2 = a1^2 - a0*a2 */
    sqr_fp2(c2, a[1]);
    mul_fp2(t0, a[0], a[2]);
    sub_fp2(c2, c2, t0);

    /* (a2*c1 + a1*c2)*(u+1) + a0*c0 */
    mul_fp2(t0, c1, a[2]);
    mul_fp2(t1, c2, a[1]);
    add_fp2(t0, t0, t1);
    mul_by_u_plus_1_fp2(t0, t0);
    mul_fp2(t1, c0, a[0]);
    add_fp2(t0, t0, t1);

    reciprocal_fp2(t1, t0);

    mul_fp2(ret[0], c0, t1);
    mul_fp2(ret[1], c1, t1);
    mul_fp2(ret[2], c2, t1);
}

void inverse_fp12(vec384fp12 ret, const vec384fp12 a)
{
    vec384fp6 t0, t1;

    sqr_fp6(t0, a[0]);
    sqr_fp6(t1, a[1]);
    mul_by_u_plus_1_fp2(t1[2], t1[2]);
    sub_fp2(t0[0], t0[0], t1[2]);
    sub_fp2(t0[1], t0[1], t1[0]);
    sub_fp2(t0[2], t0[2], t1[1]);

    inverse_fp6(t1, t0);

    mul_fp6(ret[0], a[0], t1);
    mul_fp6(ret[1], a[1], t1);
    neg_fp6(ret[1], ret[1]);
}

typedef vec384x vec384fp4[2];

#if defined(__FP2x2__)
void sqr_fp4(vec384fp4 ret, const vec384x a0, const vec384x a1)
{
    vec768x t0, t1, t2;

    sqr_fp2x2(t0, a0);
    sqr_fp2x2(t1, a1);
    add_fp2(ret[1], a0, a1);

    mul_by_u_plus_1_fp2x2(t2, t1);
    add_fp2x2(t2, t2, t0);
    redc_fp2x2(ret[0], t2);

    sqr_fp2x2(t2, ret[1]);
    sub_fp2x2(t2, t2, t0);
    sub_fp2x2(t2, t2, t1);
    redc_fp2x2(ret[1], t2);
}
#endif

void cyclotomic_sqr_fp12(vec384fp12 ret, const vec384fp12 a)
{
    vec384fp4 t0, t1, t2;

    sqr_fp4(t0, a[0][0], a[1][1]);
    sqr_fp4(t1, a[1][0], a[0][2]);
    sqr_fp4(t2, a[0][1], a[1][2]);

    sub_fp2(ret[0][0], t0[0],     a[0][0]);
    add_fp2(ret[0][0], ret[0][0], ret[0][0]);
    add_fp2(ret[0][0], ret[0][0], t0[0]);

    sub_fp2(ret[0][1], t1[0],     a[0][1]);
    add_fp2(ret[0][1], ret[0][1], ret[0][1]);
    add_fp2(ret[0][1], ret[0][1], t1[0]);

    sub_fp2(ret[0][2], t2[0],     a[0][2]);
    add_fp2(ret[0][2], ret[0][2], ret[0][2]);
    add_fp2(ret[0][2], ret[0][2], t2[0]);

    mul_by_u_plus_1_fp2(t2[1], t2[1]);
    add_fp2(ret[1][0], t2[1],     a[1][0]);
    add_fp2(ret[1][0], ret[1][0], ret[1][0]);
    add_fp2(ret[1][0], ret[1][0], t2[1]);

    add_fp2(ret[1][1], t0[1],     a[1][1]);
    add_fp2(ret[1][1], ret[1][1], ret[1][1]);
    add_fp2(ret[1][1], ret[1][1], t0[1]);

    add_fp2(ret[1][2], t1[1],     a[1][2]);
    add_fp2(ret[1][2], ret[1][2], ret[1][2]);
    add_fp2(ret[1][2], ret[1][2], t1[1]);
}


/*
 * caveat lector! |n| has to be non-zero and not more than 3!
 */
void frobenius_map_fp2(vec384x ret, const vec384x a, size_t n)
{
    vec_copy(ret[0], a[0], sizeof(ret[0]));
    cneg_fp(ret[1], a[1], n & 1);
}

void frobenius_map_fp6(vec384fp6 ret, const vec384fp6 a, size_t n)
{
    static const vec384x coeffs1[] = {  /* (u + 1)^((P^n - 1) / 3) */
      { { 0 },
        { TO_LIMB_T(0x0893C90CE43637), TO_LIMB_T(0x091B1C8E974BC0),
          TO_LIMB_T(0x7AC165041A72A9), TO_LIMB_T(0x7F8423EA4D7D95),
          TO_LIMB_T(0x4F4CDB8F4D1F70), TO_LIMB_T(0x7CF79AEA64D88A),
          TO_LIMB_T(0x05F7CBB81BD1C9) } },
      { { TO_LIMB_T(0x626C36F314C9D0), TO_LIMB_T(0x76ADFB3968A8C3),
          TO_LIMB_T(0x5630ABBFBF9DC6), TO_LIMB_T(0x4FD029B16A8CA3),
          TO_LIMB_T(0x038DD84D45FF0E), TO_LIMB_T(0x580D8DADD9981C),
          TO_LIMB_T(0x028DD255920DB0) } },
      { { 0 }, { ONE_MONT_P } }
    };
    static const vec384 coeffs2[] = {  /* (u + 1)^((2P^n - 2) / 3) */
      {   TO_LIMB_T(0x1C93C90CEAE0DB), TO_LIMB_T(0x094F676E9756B0),
          TO_LIMB_T(0x2DAA1818D0DCE9), TO_LIMB_T(0x4C586C49CEF9F1),
          TO_LIMB_T(0x373F9DFA2EB940), TO_LIMB_T(0x7B3BD5C71D304D),
          TO_LIMB_T(0x03F27224FC5248)   },
      {   TO_LIMB_T(0x0893C90CE43637), TO_LIMB_T(0x091B1C8E974BC0),
          TO_LIMB_T(0x7AC165041A72A9), TO_LIMB_T(0x7F8423EA4D7D95),
          TO_LIMB_T(0x4F4CDB8F4D1F70), TO_LIMB_T(0x7CF79AEA64D88A),
          TO_LIMB_T(0x05F7CBB81BD1C9)   },
      {   TO_LIMB_T(0x6BFFFFFFF9555C), TO_LIMB_T(0x7FCBB51FFFF50F),
          TO_LIMB_T(0x4D174CEB4995BF), TO_LIMB_T(0x332BB7A07E83A4),
          TO_LIMB_T(0x180D3D951E6630), TO_LIMB_T(0x01BBC52347A83D),
          TO_LIMB_T(0x020559931F7F81)   }
    };

    frobenius_map_fp2(ret[0], a[0], n);
    frobenius_map_fp2(ret[1], a[1], n);
    frobenius_map_fp2(ret[2], a[2], n);
    --n;    /* implied ONE_MONT_P at index 0 */
    mul_fp2(ret[1], ret[1], coeffs1[n]);
    mul_fp(ret[2][0], ret[2][0], coeffs2[n]);
    mul_fp(ret[2][1], ret[2][1], coeffs2[n]);
}

void frobenius_map_fp12(vec384fp12 ret, const vec384fp12 a, size_t n)
{
    static const vec384x coeffs[] = {  /* (u + 1)^((P^n - 1) / 6) */
      { { TO_LIMB_T(0x112AA56633A8CA), TO_LIMB_T(0x7E4AD42A0C4C1C),
          TO_LIMB_T(0x6688B9147E334A), TO_LIMB_T(0x2DC29EE97E83CC),
          TO_LIMB_T(0x59C9B46B75D956), TO_LIMB_T(0x3AC738E4FA976A),
          TO_LIMB_T(0x04791107D87DB3) },
        { TO_LIMB_T(0x6DD55A99CC01E1), TO_LIMB_T(0x01B28E7DF3B357),
          TO_LIMB_T(0x1D520AC4124765), TO_LIMB_T(0x6E65F711BB02C8),
          TO_LIMB_T(0x6103C1DBFEDEF8), TO_LIMB_T(0x18822A8FFC30FE),
          TO_LIMB_T(0x02073372B5E246) } },
      { { TO_LIMB_T(0x766C36F31B7474), TO_LIMB_T(0x76E2461968B3B3),
          TO_LIMB_T(0x09195ED4760806), TO_LIMB_T(0x1CA47210EC08FF),
          TO_LIMB_T(0x6B809AB82798DE), TO_LIMB_T(0x5651C88A91EFDE),
          TO_LIMB_T(0x008878C2728E2F) } },
      { { TO_LIMB_T(0x5EB0BB4AB935A2), TO_LIMB_T(0x04F61B06060CF8),
          TO_LIMB_T(0x445B11B99214A1), TO_LIMB_T(0x1103E18382844C),
          TO_LIMB_T(0x1E173255A55FA3), TO_LIMB_T(0x32075E5393EB1F),
          TO_LIMB_T(0x05EAC97E3EC12F) },
        { TO_LIMB_T(0x204F44B5467509), TO_LIMB_T(0x7B0747A1F9F27B),
          TO_LIMB_T(0x3F7FB21EFE660E), TO_LIMB_T(0x0B24B477B70248),
          TO_LIMB_T(0x1CB643F1CF58AC), TO_LIMB_T(0x2142052162DD4A),
          TO_LIMB_T(0x00957AFC4F9ECA) } },
    };

    frobenius_map_fp6(ret[0], a[0], n);
    frobenius_map_fp6(ret[1], a[1], n);
    --n;    /* implied ONE_MONT_P at index 0 */
    mul_fp2(ret[1][0], ret[1][0], coeffs[n]);
    mul_fp2(ret[1][1], ret[1][1], coeffs[n]);
    mul_fp2(ret[1][2], ret[1][2], coeffs[n]);
}
