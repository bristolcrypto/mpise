#include "unittest.h"

// ============================================================================

int w = XLEN; FILE* PRG = NULL;

void sample( void* r, int n ) {
  while( !fread( r, 1, n, PRG ) ) {
    /* spin */
  }
}

// ============================================================================

void sraiadd( UINT1W_t* rd, UINT1W_t rs1, UINT1W_t rs2, int imm ) {
  SINT1W_t x = rs1;
  SINT1W_t y = rs2;

  SINT1W_t r = x + ( y >> imm );

  *rd = ( UINT1W_t )( r );
}

void sraiadd_test( int i ) {
  UINT1W_t rd, rs1, rs2, rs3, imm;
  
  sample( &rd,  sizeof( rd  ) );
  sample( &rs1, sizeof( rs1 ) );
  sample( &rs2, sizeof( rs2 ) );
  sample( &rs3, sizeof( rs3 ) );
  sample( &imm, sizeof( imm ) ); imm &= 0x3F; // 7-bit imm

  // input
  printf( MARKER_DATA "[%d] sraiadd" " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );

  // instruction
  printf( MARKER_CODE "sraiadd t0, t1, t2, " FORMAT_DEC "\n", imm );

  // model
  sraiadd( &rd, rs1, rs2,      imm );

  // output
  printf( MARKER_DATA "[%d] sraiadd" " < " "rd=" FORMAT_HEX                                                                   "\n", i, rd                );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

// ----------------------------------------------------------------------------

void cacc( UINT1W_t* rd, UINT1W_t rs1, UINT1W_t rs2, UINT1W_t rs3 ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z = *rd;
  #endif

  UINT2W_t r = ( ( x + y ) >> w ) + z;

  *rd = ( UINT1W_t )( r );
}

void cacc_test( int i ) {
  UINT1W_t rd, rs1, rs2, rs3, imm;
  
  sample( &rd,  sizeof( rd  ) );
  sample( &rs1, sizeof( rs1 ) );
  sample( &rs2, sizeof( rs2 ) );
  sample( &rs3, sizeof( rs3 ) );
  sample( &imm, sizeof( imm ) );
  
  // input
  printf( MARKER_DATA "[%d] cacc"    " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "\n", i, rd, rs1, rs2, rs3 );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );

  // instruction
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  printf( MARKER_CODE "cacc t0, t1, t2, t3" "\n" );
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )     
  printf( MARKER_CODE "cacc t0, t1, t2"     "\n" );
  #endif

  // model
  cacc( &rd, rs1, rs2, rs3 );

  // output
  printf( MARKER_DATA "[%d] cacc"    " < " "rd=" FORMAT_HEX                                                                   "\n", i, rd                );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

// ----------------------------------------------------------------------------

void macclu( UINT1W_t* rd, UINT1W_t rs1, UINT1W_t rs2, UINT1W_t rs3, int imm ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z = *rd;
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

  UINT2W_t t_0 = x * y;
  UINT2W_t t_1 = f_0 ? z : 0;
  UINT2W_t t_2 = f_0 ? 0 : z;

  UINT2W_t m   = ( ( UINT2W_t )( 1 ) << f_1 ) - 1;
  UINT2W_t r   = ( ( ( t_0 + t_1 ) >> f_2 ) & m ) + t_2;

  *rd = ( UINT1W_t )( r );
}

void macclu_test( int i ) {
  UINT1W_t rd, rs1, rs2, rs3, imm;
  
  sample( &rd,  sizeof( rd  ) );
  sample( &rs1, sizeof( rs1 ) );
  sample( &rs2, sizeof( rs2 ) );
  sample( &rs3, sizeof( rs3 ) );
  sample( &imm, sizeof( imm ) ); imm &= 0x0F; // 4-bit imm => from imm for stateless, csr for not stateless (i.e., stateful)

  // input
  printf( MARKER_DATA "[%d] macclu"  " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, rs3, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );

  // instruction
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
  printf( MARKER_CODE "csrrwi x0, 0x80, "       FORMAT_DEC "\n", imm );
  printf( MARKER_CODE "macclu t0, t1, t2, t3"              "\n"      );
  #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
  printf( MARKER_CODE "macclu t0, t1, t2, t3, " FORMAT_DEC "\n", imm );
  #endif
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )     
  #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
  printf( MARKER_CODE "csrrwi x0, 0x80, "       FORMAT_DEC "\n", imm );
  printf( MARKER_CODE "macclu t0, t1, t2"                  "\n"      );
  #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
  printf( MARKER_CODE "macclu t0, t1, t2, "     FORMAT_DEC "\n", imm );
  #endif
  #endif

  // model
  macclu( &rd, rs1, rs2, rs3, imm );

  // output
  printf( MARKER_DATA "[%d] macclu"  " < " "rd=" FORMAT_HEX                                                                                         "\n", i, rd                     );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

// ----------------------------------------------------------------------------

void macchu( UINT1W_t* rd, UINT1W_t rs1, UINT1W_t rs2, UINT1W_t rs3, int imm ) {
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  // !destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z =  rs3;
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
  //  destructive
  UINT2W_t x =  rs1;
  UINT2W_t y =  rs2;
  UINT2W_t z = *rd;
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

  UINT2W_t t_0 = x * y;
  UINT2W_t t_1 = f_3 ? z : 0;
  UINT2W_t t_2 = f_3 ? 0 : z;

  UINT2W_t m   = ( ( UINT2W_t )( 1 ) << f_4 ) - 1;
  UINT2W_t r   = ( ( ( t_0 + t_1 ) >> f_5 ) & m ) + t_2;

  *rd = ( UINT1W_t )( r );
}

void macchu_test( int i ) {
  UINT1W_t rd, rs1, rs2, rs3, imm;
  
  sample( &rd,  sizeof( rd  ) );
  sample( &rs1, sizeof( rs1 ) );
  sample( &rs2, sizeof( rs2 ) );
  sample( &rs3, sizeof( rs3 ) );
  sample( &imm, sizeof( imm ) ); imm &= 0x0F; // 4-bit imm => from imm for stateless, csr for not stateless (i.e., stateful)

  // input
  printf( MARKER_DATA "[%d] macchu"  " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, rs3, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );

  // instruction
  #if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
  #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
  printf( MARKER_CODE "csrrwi x0, 0x80, "       FORMAT_DEC "\n", imm );
  printf( MARKER_CODE "macchu t0, t1, t2, t3"              "\n"      );
  #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
  printf( MARKER_CODE "macchu t0, t1, t2, t3, " FORMAT_DEC "\n", imm );
  #endif
  #elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )     
  #if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
  printf( MARKER_CODE "csrrwi x0, 0x80, "       FORMAT_DEC "\n", imm );
  printf( MARKER_CODE "macchu t0, t1, t2"                  "\n"      );
  #elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
  printf( MARKER_CODE "macchu t0, t1, t2, "     FORMAT_DEC "\n", imm );
  #endif
  #endif

  // model
  macchu( &rd, rs1, rs2, rs3, imm );

  // output
  printf( MARKER_DATA "[%d] macchu"  " < " "rd=" FORMAT_HEX                                                                                         "\n", i, rd                     );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

// ============================================================================

int main( int argc, char* argv[] ) {
  if( argc != 3 ) {
    printf( "usage: ./unittest <iterations> <instruction>\n" ); abort();
  }

  PRG = fopen( "/dev/urandom", "rb" );

  int i, n = atoi( argv[ 1 ] );

  for( i = 0; i < n; i++ ) {
    if     ( 0 == strcmp( argv[ 2 ], "sraiadd" ) ) {
      sraiadd_test( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "cacc"    ) ) {
         cacc_test( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "macclu"  ) ) {
       macclu_test( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "macchu"  ) ) {
       macchu_test( i );
    }
  }

  fclose( PRG );

  return 0;
}

// ============================================================================
