#ifndef _SHARE_H
#define _SHARE_H


#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>


#define CONSTA 486662                   // the constant of Curve25519
#define NLMB51 5                        // the limb number when using radix-51
#define MASK51 0x7FFFFFFFFFFFFULL       // 2^51 - 1
#define LSLP51 0x7FFFFFFFFFFEDULL       // least significant limb of modulus p 

// auxiliary functions
void rand_bytes(uint8_t *x, int n);
void mpi64_print(const char *c, const uint64_t *a, int len);
void mpi51_carry_prop(uint64_t *a);
void mpi_conv_64to51(uint64_t *r, const uint64_t *a);
void mpi_conv_51to64(uint64_t *r, const uint64_t *a);

#endif
