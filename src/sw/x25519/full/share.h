#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if   ( MPISE_XLEN == 32 )
typedef uint32_t Word;
#define WBYTES 4
#define WBITS 32
#define WPOW2 5
#define FORMATSTR "%08lX"
#elif ( MPISE_XLEN == 64 )
typedef uint64_t Word;
#define WBYTES 8
#define WBITS 64
#define WPOW2 6
#define FORMATSTR "%016lX"
#endif

// the constant of Curve25519
#define CONSTA 486662
// number of words of a field-element
#define NWORDS (256/WBITS)

// auxiliary functions
void rand_bytes(uint8_t *x, int n);
int  hex_to_int(Word *r, const char *hexstring, int len);
void int_to_hex(char *hexstring, const Word *a, int len);
void mpi_print(const char *c, const Word *a, int len);

#endif
