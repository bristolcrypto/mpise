#ifndef __MAIN_H
#define __MAIN_H

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#if   defined( MPISE_XLEN ) && ( MPISE_XLEN == 32 )
typedef uint32_t limb_t;
#elif defined( MPISE_XLEN ) && ( MPISE_XLEN == 64 )
typedef uint64_t limb_t;
#endif

typedef struct {
  limb_t r;
  limb_t x;
  limb_t y;
  limb_t z;
  int    c;
} vector_macclu_t;

typedef struct {
  limb_t r;
  limb_t x;
  limb_t y;
  limb_t z;
  int    c;
} vector_macchu_t;

#endif
