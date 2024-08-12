#ifndef _SHARE_H
#define _SHARE_H


#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>


#define CONSTA 486662                   // the constant of Curve25519
#define NLMB64 4                        // the limb number when using radix-51


// auxiliary functions
void rand_bytes(uint8_t *x, int n);
void mpi64_print(const char *c, const uint64_t *a, int len);

#endif
