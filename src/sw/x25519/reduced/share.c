#include <string.h>
#include "share.h"


#define MIN(a, b) (((a) < (b)) ? (a) : (b))
#define TOLOWER(a) (((a) <= 'Z') ? ((a) + 32) : (a)) 


#if 0
FILE* rand_bytes_prg = NULL;

void rand_bytes_init() {
  if( NULL == ( rand_bytes_prg = fopen( "/dev/urandom", "rb" ) ) ) {
    abort();
  }
}

void rand_bytes_fini() {
  fclose( rand_bytes_prg );
}

void rand_bytes( uint8_t* x, int n ) {
  if( n != fread( x, sizeof( uint8_t ), n, rand_bytes_prg ) ) {
    abort();
  }
}
#else
void rand_bytes_init() {
  srand( 0 );
}

void rand_bytes_fini() {

}

void rand_bytes( uint8_t* x, int n ) {
  for( int i = 0; i < n; i++ ) {
    x[ i ] = rand() & 0xFF;
  }
}
#endif


// Conversion hexstring -> Word-array

int hex_to_int(Word *r, const char *hexstring, int len)
{
  Word w = 0;
  int hlen, i = 0, j, m;
  unsigned char c;
  
  // some sanity checks
  if (hexstring == NULL) return -1;
  if ((hlen = strlen(hexstring)) < 3) return -1;
  if ((hexstring[0] != '0') || (TOLOWER(hexstring[1]) != 'x')) return -1;
  
  while ((hlen > 2) && (i < len)) {
    m = MIN(hlen - 2, 2*sizeof(Word));
    for (j = hlen - m; j < hlen; j++) {
      c = (unsigned char) hexstring[j];
      // the 3 LSBs of 'a' and 'A' are 0b001
      c = (c <= '9') ? c - '0' : (c & 7) + 9;
      w = (w << 4) | c;
    }
    r[i++] = w;
    hlen -= m;
    w = 0;
  }
  
  while (i < len) r[i++] = 0;
  
  return 0;
}


// Conversion Word-array -> hexstring

void int_to_hex(char *hexstring, const Word *a, int len)
{
  Word w;
  int hlen, i = 0, j;
  unsigned char c;
  
  hexstring[0] = '0';
  hexstring[1] = 'x';
  hlen = 1 + 2*len*sizeof(Word);
  hexstring[hlen+1] = '\0';
  
  while ((hlen >= 2) && (i < len)) {
    w = a[i++];  // from a[0] to a[len-1]
    for (j = 0; j < 2*sizeof(Word); j++) {
      c = ((unsigned char) w) & 0xf;
      // replace 55 by 87 to get lowercase letters
      hexstring[hlen-j] = c + ((c < 10) ? 48 : 55);
      w >>= 4;  // go to next nibble
    }
    hlen -= j;
  }
}


// Printing of a Word-array in hex-format

void mpi_print(const char *c, const Word *a, int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) printf("%s", c);
  for (i = len - 1; i >= 0; i--) printf(FORMATSTR, a[i]);
  printf("\n");
}


// Conversion full radix -> reduced radix

void mpi_full2red(Limb *r, int rlen, const Word *a, int alen)
{
  Limb w0, w1;
  int lbits = LBITS, rbits = 0, i, j = 0;
  
  for (i = 0; i < rlen; i++) {
    w0 = (j < alen) ? a[j] : 0;
    w1 = (j + 1 < alen) ? a[j+1] : 0;
    r[i] = w0 >> rbits;
    if (rbits > (WBITS - LBITS)) r[i] |= (w1 << lbits);
    r[i] &= LIMBMASK;
    // printf("i = %02i, j = %02i, ", i, j);
    // printf("lbits = %02i, rbits = %02i\n", lbits, rbits);
    rbits += LBITS;
    if (rbits >= WBITS) {
      rbits -= WBITS;
      j++;
    }
    lbits = WBITS - rbits;
  }
}


// Conversion reduced radix -> full radix

void mpi_red2full(Word *r, int rlen, const Limb *a, int alen)
{
  Word w0, w1, w2;
  int lbits = LBITS, rbits = 0, i, j = 0;
  
  for (i = 0; i < rlen; i++) {
    w0 = (j < alen) ? a[j] : 0;
    w1 = (j + 1 < alen) ? a[j+1] : 0;
    w2 = (j + 2 < alen) ? a[j+2] : 0;
    r[i] = (w1 << lbits) | (w0 >> rbits);
    if (lbits < (WBITS - LBITS)) r[i] |= (w2 << (LBITS + lbits));
    // printf("i = %02i, j = %02i, ", i, j);
    // printf("lbits = %02i, rbits = %02i\n", lbits, rbits);
    rbits += WBITS;
    while (rbits >= LBITS) {
      rbits -= LBITS;
      j++;
    }
    lbits = LBITS - rbits;
  }
}







/*

void mpi64_print(const char *c, const uint64_t *a, int len)
{
  int i;

  printf("%s", c);
  for (i = len-1; i > 0; i--) printf("%016llX", a[i]);
  printf("%016llX\n", a[0]);
}

void mpi51_carry_prop(uint64_t *a)
{
  a[1] += a[0] >> 51; a[0] &= MASK51;
  a[2] += a[1] >> 51; a[1] &= MASK51;
  a[3] += a[2] >> 51; a[2] &= MASK51;
  a[4] += a[3] >> 51; a[3] &= MASK51;
} 

void mpi_conv_64to51(uint64_t *r, const uint64_t *a)
{
  r[0] = ( a[0]                      ) & MASK51;
  r[1] = ((a[0] >> 51) | (a[1] << 13)) & MASK51;
  r[2] = ((a[1] >> 38) | (a[2] << 26)) & MASK51;
  r[3] = ((a[2] >> 25) | (a[3] << 39)) & MASK51;
  r[4] = ( a[3] >> 12                ) & MASK51;
}

void mpi_conv_51to64(uint64_t *r, const uint64_t *a)
{
  r[0] =  a[0]        | (a[1] << 51);
  r[1] = (a[1] >> 13) | (a[2] << 38);
  r[2] = (a[2] >> 26) | (a[3] << 25);
  r[3] = (a[3] >> 39) | (a[4] << 12); 
  // r[4] =  a[4] >> 52             ; 
}

*/
