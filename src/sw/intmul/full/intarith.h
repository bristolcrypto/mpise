#ifndef _INTARITH_H
#define _INTARITH_H

#include <stdint.h>
// #define MPISE_ISA

#define ROTL(x, dist) (((x) << (dist)) | ((x) >> (MPISE_XLEN - (dist))))
#define ROTR(x, dist) (((x) >> (dist)) | ((x) << (MPISE_XLEN - (dist))))

#if ( MPISE_XLEN == 32 )
typedef uint32_t  limb_t;
typedef uint64_t dlimb_t;
#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 28
#endif
#define ALL1WORD 0xFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (32 - (LIMBBITS)))
#define AWORD 0x01234567ULL
#define BWORD 0xFEDCBA98ULL
#endif

#if ( MPISE_XLEN == 64 )
typedef uint64_t     limb_t;
typedef __uint128_t dlimb_t;
#ifdef MPISE_RADIX
#define LIMBBITS MPISE_RADIX
#else  // for testing!
#define LIMBBITS 60
#endif
#define ALL1WORD 0xFFFFFFFFFFFFFFFFULL
#define LIMBMASK (ALL1WORD >> (64 - (LIMBBITS)))
#define AWORD 0x0123456789ABCDEFULL
#define BWORD 0xFEDCBA9876543210ULL
#endif

// Helper functions
void mpi_init(limb_t *r, limb_t word, limb_t mask, int len);
void mpi_print(const char *c, const limb_t *a, int len);
int  mpi_compare(const limb_t *a, const limb_t *b, int len);
void mpi_full2red(limb_t *r, int rlen, const limb_t *a, int alen);
void mpi_red2full(limb_t *r, int rlen, const limb_t *a, int alen);

// C implementations
void mpi_mul_1x1fr_isa(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_1x1fr_ise(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_1x1rr_isa(limb_t *r, const limb_t *a, const limb_t *b, int limbs);
void mpi_mul_1x1rr_ise(limb_t *r, const limb_t *a, const limb_t *b, int limbs);

// Assembly implementations
void mpi_mul_4x4fr_isa(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_4x4fr_ise(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_4x4rr_isa(limb_t *r, const limb_t *a, const limb_t *b, int limbs);
void mpi_mul_4x4rr_ise(limb_t *r, const limb_t *a, const limb_t *b, int limbs);
void mpi_mul_1x1fr_isa_asm(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_1x1fr_ise_asm(limb_t *r, const limb_t *a, const limb_t *b, int words);
void mpi_mul_1x1rr_isa_asm(limb_t *r, const limb_t *a, const limb_t *b, int limbs);
void mpi_mul_1x1rr_ise_asm(limb_t *r, const limb_t *a, const limb_t *b, int limbs);

// Test functions
void test_mul_fullradix(int words);
void test_mul_redradix(int limbs);

#if defined( MPISE_ISA )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4fr_isa((r), (a), (b), (len))
#define int_mul1x1_asm(r, a, b, len) mpi_mul_1x1fr_isa_asm((r), (a), (b), (len))
#elif defined( MPISE_ISE )
#define int_mul4x4_asm(r, a, b, len) mpi_mul_4x4fr_ise((r), (a), (b), (len))
#define int_mul1x1_asm(r, a, b, len) mpi_mul_1x1fr_ise_asm((r), (a), (b), (len))
#endif

#endif  // _INTARITH_H
