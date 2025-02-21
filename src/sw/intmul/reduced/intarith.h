#ifndef _INTARITH_H
#define _INTARITH_H

#include <stdint.h>

// Helper functions
void mpi_print(const char *c, const uint64_t *a, int len);
int  mpi_compare(const uint64_t *a, const uint64_t *b, int len);
void mpi_full2red(uint64_t *r, int rlen, const uint64_t *a, int alen);
void mpi_red2full(uint64_t *r, int rlen, const uint64_t *a, int alen);

// C implementations
void mpi_mul_fullradix(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);
void mpi_mul_redradix(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);

// Assembly implementations
void mpi_mul_4x4fr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_4x4fr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);
void mpi_mul_4x4rr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_4x4rr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);

// Test functions
void test_mul_fullradix(int words);
void test_mul_redradix(int limbs);


#if defined( MPISE_ISA )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4fr_isa((r), (a), (b), (len))
#elif defined( MPISE_ISE )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4fr_ise((r), (a), (b), (len))
#endif

#endif  // _INTARITH_H
