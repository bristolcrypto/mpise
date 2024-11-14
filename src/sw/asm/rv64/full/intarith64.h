#ifndef _INTARITH64_H
#define _INTARITH64_H

#include <stdint.h>

void mpi64_print(const char *c, const uint64_t *a, int len);
int  mpi64_int_cmp(const uint64_t *a, const uint64_t *b, int len);

void mpi64_int_mul(uint64_t *r, const uint64_t *a, const uint64_t *b, int len);
void mpi64_int_sqr(uint64_t *r, const uint64_t *a, int len);
void mpi64_int_sqr_V2(uint64_t *r, const uint64_t *a, int len);
void mpi64_test_int_mul(void);

#endif  // _INTARITH_64_H
