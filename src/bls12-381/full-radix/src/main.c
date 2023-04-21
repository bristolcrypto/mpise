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
  POINTonE2_affine Q[1] = { 0 };
  POINTonE1_affine P[1] = { 0 };
  vec384fp12 ret;

  Q[0].X[0][0] = 1;
  Q[0].Y[0][0] = 2;
  Q[0].X[1][0] = 3;
  Q[0].Y[1][0] = 4;
  P[0].X[0]    = 5;
  P[0].Y[0]    = 6;

  optimal_ate_pairing(ret, Q, P, 1);

  mpi_print("* result r0:  ", ret[0][0][0], 6);
  mpi_print("* result r1:  ", ret[0][0][1], 6);
  mpi_print("* result r2:  ", ret[0][1][0], 6);
  mpi_print("* result r3:  ", ret[0][1][1], 6);
  mpi_print("* result r4:  ", ret[0][2][0], 6);
  mpi_print("* result r5:  ", ret[0][2][1], 6);
  mpi_print("* result r6:  ", ret[1][0][0], 6);
  mpi_print("* result r7:  ", ret[1][0][1], 6);
  mpi_print("* result r8:  ", ret[1][1][0], 6);
  mpi_print("* result r9:  ", ret[1][1][1], 6);
  mpi_print("* result r10: ", ret[1][2][0], 6);
  mpi_print("* result r11: ", ret[1][2][1], 6);
}

int main()
{
  test_pairing();

  return 0;
}