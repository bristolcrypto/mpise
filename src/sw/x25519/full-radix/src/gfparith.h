#ifndef _GFPARITH_H
#define _GFPARITH_H


#include "share.h"


void gfp_mul_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_isa(uint64_t *r, const uint64_t *a);
void gfp_add_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_mul64_isa(uint64_t *r, const uint64_t *a, const uint64_t b);

void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_ise(uint64_t *r, const uint64_t *a);
void gfp_add_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_mul64_ise(uint64_t *r, const uint64_t *a, const uint64_t b);

void gfp_inv(uint64_t *r, const uint64_t *a);

#if (ISE)
#define gfp_mul         gfp_mul_ise
#define gfp_sqr(r, a)   gfp_mul_ise(r, a, a)
#define gfp_add         gfp_add_ise
#define gfp_sub         gfp_sub_ise
#define gfp_mul64       gfp_mul64_ise
#elif (ISA)
#define gfp_mul         gfp_mul_isa
#define gfp_sqr         gfp_sqr_isa
#define gfp_add         gfp_add_isa
#define gfp_sub         gfp_sub_isa
#define gfp_mul64       gfp_mul64_isa
#endif

#endif 
