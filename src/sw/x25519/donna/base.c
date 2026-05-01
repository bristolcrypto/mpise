// #include "crypto_scalarmult.h"
extern int crypto_scalarmult(uint8_t *mypublic, const uint8_t *secret, const uint8_t *basepoint);

static const unsigned char basepoint[32] = {9};

int crypto_scalarmult_base(unsigned char *q,const unsigned char *n)
{
  return crypto_scalarmult(q, n, basepoint);
}
