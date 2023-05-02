#include "rdtsc.h"


uint64_t rdtsc() {
  uint64_t tsc = 0;

  __asm__ __volatile__( "rdcycle %0" : "=r" (tsc) );

  return tsc;
}
