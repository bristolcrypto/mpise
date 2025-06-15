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


void mpi_print(const char *c, const Word *a, int len)
{
  int i;
  
  if ((c != NULL) && (strlen(c) > 0)) printf("%s", c);
  for (i = len - 1; i >= 0; i--) printf(FORMATSTR, a[i]);
  printf("\n");
}
