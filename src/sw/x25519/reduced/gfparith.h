#ifndef _GFPARITH_H
#define _GFPARITH_H


#include "share.h"


void gfp_add_isa(Limb *r, const Limb *a, const Limb *b);
void gfp_mul_isa(Limb *r, const Limb *a, const Limb *b);
void gfp_mul32_isa(Limb *r, const Limb *a, const Limb b);
void gfp_sqr_isa(Limb *r, const Limb *a);
void gfp_sub_isa(Limb *r, const Limb *a, const Limb *b);

void gfp_mul_ise(Limb *r, const Limb *a, const Limb *b);
void gfp_mul32_ise(Limb *r, const Limb *a, const Limb b);
void gfp_sqr_ise(Limb *r, const Limb *a);

void gfp_canon(Limb *r, const Limb *a);
void gfp_inv(Limb *r, const Limb *a);


#if   defined( MPISE_ISE )
#define gfp_mul(r, a, b)   gfp_mul_ise((r), (a), (b))
#define gfp_mul32(r, a, b) gfp_mul32_ise((r), (a), (b))
#define gfp_sqr(r, a)      gfp_sqr_ise((r), (a))
#elif defined( MPISE_ISA )
#define gfp_mul(r, a, b)   gfp_mul_isa((r), (a), (b))
#define gfp_mul32(r, a, b) gfp_mul32_isa((r), (a), (b))
#define gfp_sqr(r, a)      gfp_sqr_isa((r), (a))
#endif

#define gfp_add(r, a, b)   gfp_add_isa((r), (a), (b))
#define gfp_sub(r, a, b)   gfp_sub_isa((r), (a), (b))


#endif
