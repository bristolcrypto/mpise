// #include "../../../includes/lib.h"
int crypto_scalarmult(unsigned char *, const unsigned char *, const unsigned char *);

const unsigned char base[32] = {9};

int crypto_scalarmult_base(unsigned char *q,
  const unsigned char *n)
{
  return crypto_scalarmult(q,n,base);
}
