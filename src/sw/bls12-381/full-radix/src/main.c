#include <string.h>

#include "pairing.h"
#include "point.h"
#include "ec_ops.h"


void mpi_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016lX", a[i]);
  printf("%016lX\n", a[0]);
}

void test_pairing()
{
  POINTonE2_affine Q[1];
  POINTonE1_affine P[1];
  POINTonE2 _Q[1];
  POINTonE1 _P[1];
  vec384fp12 e1, e2;

  // currently use _P = BLS12_381_G1 and _Q = BLS12_381_G2 and k = 2 
  // to conduct a very simple test

  puts("bilinear test: e(P, [k]Q) == e([k]P, Q)");
  // compute [k]Q 
  POINTonE2_double(_Q, &BLS12_381_G2);
  // compute e1 = e(P, [k]Q)
  POINTonE1_to_affine(P, &BLS12_381_G1);
  POINTonE2_to_affine(Q, _Q);
  optimal_ate_pairing(e1, Q, P, 1);
  // compute [k]P
  POINTonE1_double(_P, &BLS12_381_G1);
  // compute e2 = e([k]P, Q)
  POINTonE1_to_affine(P, _P);
  POINTonE2_to_affine(Q, &BLS12_381_G2);
  optimal_ate_pairing(e2, Q, P, 1);
  // test whether e1 == e2: i.e., whether e(P, [k]Q) == e([k]P, Q)
  if (memcmp(e1, e2, sizeof(vec384fp12))) puts("\x1b[31m e1 != e2 \x1b[0m");
  else puts("\x1b[32m e1 == e2 \x1b[0m");

  puts("bilinear test: (e(P, [k]Q))^2 == e([2k]P, Q)");
  // compute [2k]P 
  POINTonE1_double(_P, &BLS12_381_G1);
  POINTonE1_double(_P, _P);
  // compute e2 = e([2k]P, Q)
  POINTonE1_to_affine(P, _P);
  POINTonE2_to_affine(Q, &BLS12_381_G2);
  optimal_ate_pairing(e2, Q, P, 1);
  // compute e1 = e1^2 
  sqr_fp12(e1, e1);
  // test whether e1 == e2: i.e., whether (e(P, [k]Q)])^2 == e([2k]P, Q)
  if (memcmp(e1, e2, sizeof(vec384fp12))) puts("\x1b[31m e1 != e2 \x1b[0m");
  else puts("\x1b[32m e1 == e2 \x1b[0m");

  puts("bilinear test: (e(P, [k]Q))^4 == e([2k]P, [2]Q)");
  // compute [2]Q 
  POINTonE2_double(_Q, &BLS12_381_G2);
  // compute e2 = e([2k]P, [2]Q)
  POINTonE1_to_affine(P, _P);
  POINTonE2_to_affine(Q, _Q);
  optimal_ate_pairing(e2, Q, P, 1);
  // compute e1 = e1^2 
  sqr_fp12(e1, e1);
  // test whether e1 == e2: i.e., whether (e(P, [k]Q))^4 == e([2k]P, [2]Q)
  if (memcmp(e1, e2, sizeof(vec384fp12))) puts("\x1b[31m e1 != e2 \x1b[0m");
  else puts("\x1b[32m e1 == e2 \x1b[0m");
}

int main()
{
  test_pairing();

  return 0;
}
