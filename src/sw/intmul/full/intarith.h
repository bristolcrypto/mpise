#ifndef _INTARITH64_H
#define _INTARITH64_H

#include <stdint.h>

// Helper functions
void mpi64_print(const char *c, const uint64_t *a, int len);
int  mpi64_int_cmp(const uint64_t *a, const uint64_t *b, int len);

// C implementations
void mpi64_int_mul(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);
void mpi64_int_sqr(uint64_t *r, const uint64_t *a, int len);
void mpi64_int_sqr_V2(uint64_t *r, const uint64_t *a, int len);
void mpi64_test_int_mul(void);

// Assembly implementations
void int_mul4x4_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);
void int_mul4x4_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);

#if defined( MPISE_ISE ) && ( MPISE_ISE == 0 )
#define int_mul4x4_asm(r, a, b, len) int_mul4x4_isa((r), (a), (b), (len))
#elif defined( MPISE_ISE ) && ( MPISE_ISE == 1 )
#define int_mul4x4_asm(r, a, b, len) int_mul4x4_ise((r), (a), (b), (len))
#endif

#endif  // _INTARITH_64_H

