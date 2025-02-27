#ifndef _INTARITH_H
#define _INTARITH_H

#include <stdint.h>
// #define MPISE_ISA

#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 51
#endif

#define ALL1WORD 0xFFFFFFFFFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (64 - (LIMBBITS)))

// for initialization of operands
#define AWORD 0x0123456789ABCDEFULL
#define BWORD 0xFEDCBA9876543210ULL

// Helper functions
void mpi_init(uint64_t *r, uint64_t word, uint64_t mask, int len);
void mpi_print(const char *c, const uint64_t *a, int len);
int  mpi_compare(const uint64_t *a, const uint64_t *b, int len);
void mpi_full2red(uint64_t *r, int rlen, const uint64_t *a, int alen);
void mpi_red2full(uint64_t *r, int rlen, const uint64_t *a, int alen);

// C implementations
void mpi_mul_1x1fr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_1x1fr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_1x1rr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);
void mpi_mul_1x1rr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);

// Assembly implementations
void mpi_mul_4x4fr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_4x4fr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int words);
void mpi_mul_4x4rr_isa(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);
void mpi_mul_4x4rr_ise(uint64_t *r, const uint64_t *a, const uint64_t *b, int limbs);

// Test functions
void test_mul_fullradix(int words);
void test_mul_redradix(int limbs);

#if defined( MPISE_ISA )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4rr_isa((r), (a), (b), (len))
#elif defined( MPISE_ISE )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4rr_ise((r), (a), (b), (len))
#endif

#endif  // _INTARITH_H

