#ifndef _SHARE_H
#define _SHARE_H

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if   ( MPISE_XLEN == 32 )
typedef uint32_t Word;
typedef uint32_t Limb;
#define WBYTES 4
#define LBYTES 4
#define WBITS 32
#define LBITS 29
#define WPOW2 5
#define FORMATSTR "%08lX"
#elif ( MPISE_XLEN == 64 )
typedef uint64_t Word;
typedef uint64_t Limb;
#define WBYTES 8
#define LBYTES 7
#define WBITS 64
#define LBITS 51
#define WPOW2 6
#define FORMATSTR "%016lX"
#endif

// bit-length of the prime p
#define PLEN 255
// the constant c of the prime
#define CONSTC 19
// the constant A of Curve25519
#define CONSTA 486662
// number of words of a field-element
#define NWORDS ((PLEN + WBITS - 1)/WBITS)
// number of limbs of a field-element
#define NLIMBS ((PLEN + LBITS - 1)/LBITS)
// bit-mask for limbs
#define LIMBMASK ((1UL << LBITS) - 1)
// least significant limb of prime p 
#define LSLPRIME ((1UL << LBITS) - CONSTC)

// fix-me: remove these defines
#define NLMB51 5                        // the limb number when using radix-51
#define MASK51 0x7FFFFFFFFFFFFULL       // 2^51 - 1
#define LSLP51 0x7FFFFFFFFFFEDULL       // least significant limb of modulus p 

// auxiliary functions
void rand_bytes(uint8_t *x, int n);
int  hex_to_int(Word *r, const char *hexstring, int len);
void int_to_hex(char *hexstring, const Word *a, int len);
void mpi_print(const char *c, const Word *a, int len);
void mpi_full2red(Limb *r, int rlen, const Word *a, int alen);
void mpi_red2full(Word *r, int rlen, const Limb *a, int alen);

#endif
