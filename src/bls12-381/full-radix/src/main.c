#include "pairing.h"


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
  vec384fp12 ret;

  // generate a random P and Q

  puts("bilinear test: e(P, [k]Q) == e([k]P, Q)");

  // compute [k]Q 

  // compute e1 = e(P, [k]Q)

  // compute [k]P

  // compute e2 = e([k]P, Q)

  // test whether e1 == e2: i.e., whether e(P, [k]Q) == e([k]P, Q)

  puts("bilinear test: (e(P, [k]Q))^2 == e([2k]P, Q)");

  // compute [2k]P 

  // compute e2 = e([2k]P, Q)

  // compute e1 = e1^2 

  // test whether e1 == e2: i.e., whether (e(P, [k]Q)])^2 == e([2k]P, Q)

  puts("bilinear test: (e(P, [k]Q))^4 == e([2k]P, [2]Q)");

  // compute [2]Q 

  // compute e2 = e([2k]P, [2]Q)

  // compute e1 = e1^2 

  // test whether e1 == e2: i.e., whether (e(P, [k]Q))^4 == e([2k]P, [2]Q)

}

int main()
{
  test_pairing();

  return 0;
}
