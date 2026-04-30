#ifndef __X25519_TEST_GFP_H__
#define __X25519_TEST_GFP_H__

#include "instrumentation.h"
#include "share.h"
#include "gfparith.h"

#ifdef X25519_DEBUG
// ------------ Instrumentation code ------------
// Define two arrays to track clock cycles and retired instructions for each
// iteration of a test function. These arrays are defined once, and reused
// multiple times throughout this file.
// ----------------------------------------------
extern uint64_t rdtsc_debug[MAX_TRIALS];
extern uint64_t instr_debug[MAX_TRIALS];
#endif


// single nop subroutine
void test_nop(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  int i;
  
  printf("\n=============================================================\n");
  printf("test_nop - nop_routine");
  printf("\n=============================================================\n");
  LOAD_CACHE(nop_routine(), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(nop_routine(), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(nop_routine(), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
}


void test_gfp_add(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp add");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_add(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_add(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_add(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char addh[] =  // expected result gfp_add
    "0x7777777888888887777777788888888777777778888888877777777888888887";
  if (strcmp(addh, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_sub(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sub");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sub(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sub(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sub(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char subh[] =  // expected result gfp_sub
    "0x0ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1344";
  if (strcmp(subh, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_mul(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char mulh[] =  // expected result gfp_mul
    "0x5EDAF2E6A75EA09F98466E25C3350F84D1B1E964DF0B7E6A0B1D64A3FAE1ED44";
  if (strcmp(mulh, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_mul32(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul32");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul32(resf, op1f, (CONSTA - 2)/4), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul32(resf, op1f, (CONSTA - 2)/4), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul32(resf, op1f, op2f), iter);
  printf("       #cycles = %" PRIu64 "\n", diff_cycles);
  printf("       #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char m32h[] =  // expected result gfp_mul32
    "0x3BBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBBA0EEA";
  if (strcmp(m32h, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_sqr(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  
  hex_to_int(op1f, op1h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sqr");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sqr(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sqr(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sqr(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char sqrh[] =  // expected result gfp_sqr
    "0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465";
  if (strcmp(sqrh, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_inv(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  
  hex_to_int(op1f, op1h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp inv");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_inv(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_inv(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_inv(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char invh[] =  // expected result inv_sqr
    "0x0156A6E8A59F1CE84CF3FE6BB3704486EE3CE441547929141DCF6BE16377749C";
  if (strcmp(invh, resh) != 0) printf("  result r is wrong!!!\n");
#endif
}


void test_gfp_arith(int iter, int num_warmup_iters)
{
  uint64_t start_cycles, end_cycles, diff_cycles;
  uint64_t start_instr, end_instr, diff_instr;
  Word op1f[NWORDS], op2f[NWORDS], resf[NWORDS];  // full-radix
  int i;
  
#if DEBUG
  char resh[2*WBYTES*NWORDS+3];  // result as hex-string
#endif
  
  static const char op1h[] =  // 1st operand for testing
    "0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF";
  static const char op2h[] =  // 2nd operand for testing
    "0x76543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA98";
  
  hex_to_int(op1f, op1h, NWORDS);
  hex_to_int(op2f, op2h, NWORDS);
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp add");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_add(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_add(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_add(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char addh[] =  // expected result gfp_add
    "0x7777777888888887777777788888888777777778888888877777777888888887";
  if (strcmp(addh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sub");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sub(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sub(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sub(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char subh[] =  // expected result gfp_sub
    "0x0ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF13568ACF1344";
  if (strcmp(subh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul(resf, op1f, op2f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul(resf, op1f, op2f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul(resf, op1f, op2f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char mulh[] =  // expected result gfp_mul
    "0x5EDAF2E6A75EA09F98466E25C3350F84D1B1E964DF0B7E6A0B1D64A3FAE1ED44";
  if (strcmp(mulh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp mul32");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_mul32(resf, op1f, (CONSTA - 2)/4), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_mul32(resf, op1f, (CONSTA - 2)/4), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_mul32(resf, op1f, op2f), iter);
  printf("       #cycles = %" PRIu64 "\n", diff_cycles);
  printf("       #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char m32h[] =  // expected result gfp_mul32
    "0x3BBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBB9C0CBBBBBBBBBBBBA0EEA";
  if (strcmp(m32h, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp sqr");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_sqr(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_sqr(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_sqr(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char sqrh[] =  // expected result gfp_sqr
    "0x72CC9B9B881D163356F62CB64EB19AF43B1FBDD115461FB51F494EEBDBDAA465";
  if (strcmp(sqrh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
  
  // --------------------------------------------------------------------------
  
  printf("\n=============================================================\n");
  printf("test_gfp_arith - gfp inv");
  printf("\n=============================================================\n");
  LOAD_CACHE(gfp_inv(resf, op1f), num_warmup_iters);
#if X25519_DEBUG
  MEASURE_CYCLES_DEBUG(gfp_inv(resf, op1f), iter, rdtsc_debug, instr_debug);
  print_performance_counters(rdtsc_debug, instr_debug, iter);
#else
  MEASURE_CYCLES(gfp_inv(resf, op1f), iter);
  printf("         #cycles = %" PRIu64 "\n", diff_cycles);
  printf("         #instr  = %" PRIu64 "\n", diff_instr);
#endif
  
#if DEBUG
  int_to_hex(resh, resf, NWORDS);
  printf("  r  = %s\n", resh);
  static const char invh[] =  // expected result inv_sqr
    "0x0156A6E8A59F1CE84CF3FE6BB3704486EE3CE441547929141DCF6BE16377749C";
  if (strcmp(invh, resh) != 0) printf("  result r is wrong!!!\n");
  memset(resf, 0, WBYTES*NWORDS);
#endif
}


#endif // __TEST_GFP_H__
