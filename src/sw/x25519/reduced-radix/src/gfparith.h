#ifndef _GFPARITH_H
#define _GFPARITH_H


#include "share.h"


void gfp_mul_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_isa(uint64_t *r, const uint64_t *a);
void gfp_add_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sub_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_mul51_isa(uint64_t *r, const uint64_t *a, const uint64_t b);

void gfp_mul_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
void gfp_sqr_ise(uint64_t *r, const uint64_t *a);
void gfp_mul51_ise(uint64_t *r, const uint64_t *a, const uint64_t b);

void gfp_inv(uint64_t *r, const uint64_t *a);

#if (ISE)
#define gfp_mul   gfp_mul_ise
#define gfp_sqr   gfp_sqr_ise
#define gfp_mul51 gfp_mul51_ise
#elif (ISA)
#define gfp_mul   gfp_mul_isa
#define gfp_sqr   gfp_sqr_isa
#define gfp_mul51 gfp_mul51_isa
#endif 
#define gfp_add   gfp_add_isa
#define gfp_sub   gfp_sub_isa

#endif 
