#include "unittest.h"

int w = XLEN; FILE* PRG = NULL;

void sample( void* r, int n ) {
  if( PRG == NULL ) {
    PRG = fopen( "/dev/urandom", "rb" );
  }

  int t;

  while( !fread( r, 1, n, PRG ) ) {
    /* spin */
  }
}

// ----------------------------------------------------------------------------

void sraiadd( UINTSINGLE_t* rd, UINTSINGLE_t rs1, UINTSINGLE_t rs2, int imm ) {
  SINTSINGLE_t x = rs1;
  SINTSINGLE_t y = rs2;

  SINTSINGLE_t r = x + ( y >> imm );

  *rd = ( UINTSINGLE_t )( r );
}

void cacc( UINTSINGLE_t* rd, UINTSINGLE_t rs1, UINTSINGLE_t rs2, UINTSINGLE_t rs3 ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z = *rd;
  #endif

  UINTDOUBLE_t r = ( ( x + y ) >> w ) + z;

  *rd = ( UINTSINGLE_t )( r );
}

void macclu( UINTSINGLE_t* rd, UINTSINGLE_t rs1, UINTSINGLE_t rs2, UINTSINGLE_t rs3, int imm ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z = *rd;
  #endif

  int c = imm, f_0, f_1, f_2;

  if     ( c == 0xF ) { //    full-radix
    f_0 =        1;
    f_1 =  w      ;
    f_2 =        0;
  }
  else if( c != 0xF ) { // reduced-radix
    f_0 =        0;
    f_1 = (w-15)+c;
    f_2 =        0;
  }

  UINTDOUBLE_t t_0 = x * y;
  UINTDOUBLE_t t_1 = f_0 ? z : 0;
  UINTDOUBLE_t t_2 = f_0 ? 0 : z;

  UINTDOUBLE_t m   = ( ( UINTDOUBLE_t )( 1 ) << f_1 ) - 1;
  UINTDOUBLE_t r   = ( ( ( t_0 + t_1 ) >> f_2 ) & m ) + t_2;

  *rd = ( UINTSINGLE_t )( r );
}

void macchu( UINTSINGLE_t* rd, UINTSINGLE_t rs1, UINTSINGLE_t rs2, UINTSINGLE_t rs3, int imm ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINTDOUBLE_t x =  rs1;
  UINTDOUBLE_t y =  rs2;
  UINTDOUBLE_t z = *rd;
  #endif

  int c = imm, f_3, f_4, f_5;

  if     ( c == 0xF ) { //    full-radix
    f_3 =        1;
    f_4 =  w      ;
    f_5 =  w      ;
  }
  else if( c != 0xF ) { // reduced-radix
    f_3 =        0;
    f_4 =  w      ;
    f_5 = (w-15)+c;
  }

  UINTDOUBLE_t t_0 = x * y;
  UINTDOUBLE_t t_1 = f_3 ? z : 0;
  UINTDOUBLE_t t_2 = f_3 ? 0 : z;

  UINTDOUBLE_t m   = ( ( UINTDOUBLE_t )( 1 ) << f_4 ) - 1;
  UINTDOUBLE_t r   = ( ( ( t_0 + t_1 ) >> f_5 ) & m ) + t_2;

  *rd = ( UINTSINGLE_t )( r );
}

// ----------------------------------------------------------------------------

int main( int argc, char* argv[] ) {
  int i, n = atoi( argv[ 1 ] );

  for( i = 0; i < n; i++ ) {
    UINTSINGLE_t rd, rs1, rs2, rs3, imm;
  
    sample( &rd,  sizeof( rd  ) );
    sample( &rs1, sizeof( rs1 ) );
    sample( &rs2, sizeof( rs2 ) );
    sample( &rs3, sizeof( rs3 ) );
    sample( &imm, sizeof( imm ) );
  
    if     ( 0 == strcmp( argv[ 2 ], "sraiadd" ) ) {
      imm &= 0x3F; // 7-bit imm

      printf( "[%d] sraiadd" " > " FORMAT("rd") "," FORMAT("rs1") "," FORMAT("rs2")                       FORMAT("imm") "\n", i, rd, rs1, rs2,      imm );
      sraiadd( &rd, rs1, rs2,      imm );
      printf( "[%d] sraiadd" " < " FORMAT("rd")                                                                         "\n", i, rd                     );
    }
    else if( 0 == strcmp( argv[ 2 ], "cacc"    ) ) {
      printf( "[%d] cacc"    " > " FORMAT("rd") "," FORMAT("rs1") "," FORMAT("rs2") "," FORMAT("rs3")                   "\n", i, rd, rs1, rs2, rs3      );
         cacc( &rd, rs1, rs2, rs3      );
      printf( "[%d] cacc"    " < " FORMAT("rd")                                                                         "\n", i, rd                     );
    }
    else if( 0 == strcmp( argv[ 2 ], "macclu"  ) ) {
      imm &= 0x0F; // 4-bit imm => from imm for stateless, csr for not stateless (i.e., stateful)

      printf( "[%d] macclu"  " > " FORMAT("rd") "," FORMAT("rs1") "," FORMAT("rs2") "," FORMAT("rs3") "," FORMAT("imm") "\n", i, rd, rs1, rs2, rs3, imm );
       macclu( &rd, rs1, rs2, rs3, imm );
      printf( "[%d] macclu"  " < " FORMAT("rd")                                                                         "\n", i, rd                     );
    }
    else if( 0 == strcmp( argv[ 2 ], "macchu"  ) ) {
      imm &= 0x0F; // 4-bit imm => from imm for stateless, csr for not stateless (i.e., stateful)

      printf( "[%d] macchu"  " > " FORMAT("rd") "," FORMAT("rs1") "," FORMAT("rs2") "," FORMAT("rs3") "," FORMAT("imm") "\n", i, rd, rs1, rs2, rs3, imm );
       macchu( &rd, rs1, rs2, rs3, imm );
      printf( "[%d] macchu"  " < " FORMAT("rd")                                                                         "\n", i, rd                     );
    }
  }

  return 0;
}

// ----------------------------------------------------------------------------
