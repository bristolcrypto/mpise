#ifndef __INSTRUMENTATION_H__
#define __INSTRUMENTATION_H__
#include <stdlib.h>
void nop_routine() {
  asm volatile("nop");
}
#if X25519_DEBUG
#define MEASURE_CYCLES_DEBUG(X, iter, cc, ir) do {\
  for (i = 0; i < (iter); i++) {                  \
    start_instr  = rdinstr();                     \
    start_cycles = rdtsc();                       \
    (X);                                          \
    end_cycles = rdtsc();                         \
    end_instr  = rdinstr();                       \
    diff_cycles = (end_cycles-start_cycles);      \
    diff_instr  = end_instr - start_instr;        \
    cc[i] = diff_cycles;                          \
    ir[i] = diff_instr;                           \
  }                                               \
} while (0);

void print_performance_counters(uint64_t *cycles, uint64_t *instrs, int iter) {
  printf("\n-------------------- Cycles --------------------\n");
  for (int t = 0; t < iter; t++)
  {
     if (t % 100 == 0) {
         printf("\n! @ ");
     }
     printf(" %" PRIu64, cycles[t]);
  }
  printf("\n");
  printf("\n---------------- Instructions ----------------\n");
  for (int t = 0; t < iter; t++)
  {
     if (t % 100 == 0) {
         printf("\n! @ ");
     }
     printf(" %" PRIu64, instrs[t]);
  }
  printf("\n");
  printf("\n----------------------------------------------\n");
}
#endif // X25519_DEBUG 
#endif // __INSTRUMENTATION_H__
