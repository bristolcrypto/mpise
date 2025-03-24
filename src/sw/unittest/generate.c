#include "generate.h"

asm( "#include " "\"" "ise.h" "\"" );

// ============================================================================

FILE* PRG = NULL;

void prg( void* r, int n ) {
  while( !fread( r, 1, n, PRG ) ) {
    /* spin */
  }
}

// ----------------------------------------------------------------------------

void test_srliadd( int i ) {
  reg_t rd, rs1, rs2, rs3, imm; 
  
  // generate  input data
  prg( &rd,  sizeof( rd  ) );
  prg( &rs1, sizeof( rs1 ) );
  prg( &rs2, sizeof( rs2 ) );
  prg( &rs3, sizeof( rs3 ) );
  prg( &imm, sizeof( imm ) ); imm &= 0x0F; // 7-bit => 4-bit due to macro
  // emit      input data
  printf( MARKER_DATA "[%d] srliadd" " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  // emit     instruction
  EMIT_SRLIADD;
  // execute  model
  INSN(imm,INSN_SRLIADD);
  // emit     output data
  printf( MARKER_DATA "[%d] srliadd" " < " "rd=" FORMAT_HEX                                                                   "\n", i, rd                );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

void test_sraiadd( int i ) {
  reg_t rd, rs1, rs2, rs3, imm; 
  
  // generate  input data
  prg( &rd,  sizeof( rd  ) );
  prg( &rs1, sizeof( rs1 ) );
  prg( &rs2, sizeof( rs2 ) );
  prg( &rs3, sizeof( rs3 ) );
  prg( &imm, sizeof( imm ) ); imm &= 0x0F; // 7-bit => 4-bit due to macro
  // emit      input data
  printf( MARKER_DATA "[%d] sraiadd" " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  // emit     instruction
  EMIT_SRAIADD;
  // execute  model
  INSN(imm,INSN_SRAIADD);
  // emit     output data
  printf( MARKER_DATA "[%d] sraiadd" " < " "rd=" FORMAT_HEX                                                                   "\n", i, rd                );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

void test_cacc   ( int i ) {
  reg_t rd, rs1, rs2, rs3;
  
  // generate  input data
  prg( &rd,  sizeof( rd  ) );
  prg( &rs1, sizeof( rs1 ) );
  prg( &rs2, sizeof( rs2 ) );
  prg( &rs3, sizeof( rs3 ) );
  // emit      input data
  printf( MARKER_DATA "[%d] cacc"    " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "\n", i, rd, rs1, rs2, rs3 );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );
  // emit     instruction
  EMIT_CACC;
  // execute  model
  INSN_CACC;
  // emit     output data
  printf( MARKER_DATA "[%d] cacc"    " < " "rd=" FORMAT_HEX                                                                   "\n", i, rd                );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

void test_macclu ( int i ) {
  reg_t rd, rs1, rs2, rs3, imm;
  
  // generate  input data
  prg( &rd,  sizeof( rd  ) );
  prg( &rs1, sizeof( rs1 ) );
  prg( &rs2, sizeof( rs2 ) );
  prg( &rs3, sizeof( rs3 ) );
  prg( &imm, sizeof( imm ) ); imm &= 0x0F; // 4-bit => 4-bit due to macro: imm for stateless, csr for not stateless (i.e., stateful)
  // emit      input data
  printf( MARKER_DATA "[%d] macclu"  " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, rs3, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );
  // emit     instruction
  EMIT_MACCLU;
  // execute  model
  INSN(imm,INSN_MACCLU);
  // emit     output data
  printf( MARKER_DATA "[%d] macclu"  " < " "rd=" FORMAT_HEX                                                                                         "\n", i, rd                     );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

void test_macchu ( int i ) {
  reg_t rd, rs1, rs2, rs3, imm;
  
  // generate  input data
  prg( &rd,  sizeof( rd  ) );
  prg( &rs1, sizeof( rs1 ) );
  prg( &rs2, sizeof( rs2 ) );
  prg( &rs3, sizeof( rs3 ) );
  prg( &imm, sizeof( imm ) ); imm &= 0x0F; // 4-bit => 4-bit due to macro: imm for stateless, csr for not stateless (i.e., stateful)
  // emit      input data
  printf( MARKER_DATA "[%d] macchu"  " > " "rd=" FORMAT_HEX "," "rs1=" FORMAT_HEX "," "rs2=" FORMAT_HEX "," "rs3=" FORMAT_HEX "," "imm=" FORMAT_DEC "\n", i, rd, rs1, rs2, rs3, imm );
  printf( MARKER_CODE "li  t0, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "li  t1, " FORMAT_HEX "\n", rs1 );
  printf( MARKER_CODE "li  t2, " FORMAT_HEX "\n", rs2 );
  printf( MARKER_CODE "li  t3, " FORMAT_HEX "\n", rs3 );
  // emit     instruction
  EMIT_MACCHU;
  // execute  model
  INSN(imm,INSN_MACCHU);
  // emit     output data
  printf( MARKER_DATA "[%d] macchu"  " < " "rd=" FORMAT_HEX                                                                                         "\n", i, rd                     );
  printf( MARKER_CODE "li  t4, " FORMAT_HEX "\n", rd  );
  printf( MARKER_CODE "bne t4, t0, fail"    "\n"      );
}

// ============================================================================

int main( int argc, char* argv[] ) {
  if( argc != 3 ) {
    printf( "usage: ./generate <iterations> <instruction>\n" ); abort();
  }

  PRG = fopen( "/dev/urandom", "rb" );

  printf( "!! MPISE_XLEN        = %d\n", MPISE_XLEN        );
  printf( "!! MPISE_DESTRUCTIVE = %d\n", MPISE_DESTRUCTIVE );
  printf( "!! MPISE_STATELESS   = %d\n", MPISE_STATELESS   );

  int i, n = atoi( argv[ 1 ] );

  printf( MARKER_CODE "#ifdef PLATFORM_SPIKE"               "\n" );
  printf( MARKER_CODE "#include " "\"" "ise.h" "\""         "\n" );
  printf( MARKER_CODE ".global test"                        "\n" );
  printf( MARKER_CODE "test:"                               "\n" );
  printf( MARKER_CODE "#endif"                              "\n" );

  printf( MARKER_CODE "#ifdef PLATFORM_CVA6"                "\n" );
  printf( MARKER_CODE "#include " "\"" "integration.S" "\"" "\n" );
  printf( MARKER_CODE "#include " "\"" "ise.h" "\""         "\n" );
  printf( MARKER_CODE ".global main"                        "\n" );
  printf( MARKER_CODE "main:"                               "\n" );
  printf( MARKER_CODE "#endif"                              "\n" );

  for( i = 0; i < n; i++ ) {
    if     ( 0 == strcmp( argv[ 2 ], "srliadd" ) ) {
      test_srliadd( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "sraiadd" ) ) {
      test_sraiadd( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "cacc"    ) ) {
      test_cacc   ( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "macclu"  ) ) {
      test_macclu ( i );
    }
    else if( 0 == strcmp( argv[ 2 ], "macchu"  ) ) {
      test_macchu ( i );
    }
  }

  printf( MARKER_CODE "#ifdef PLATFORM_SPIKE"               "\n" );
  printf( MARKER_CODE "pass: li a0, 1 ; ret"                "\n" );
  printf( MARKER_CODE "fail: li a0, 0 ; ret"                "\n" );
  printf( MARKER_CODE "#endif"                              "\n" );

  fclose( PRG );

  return 0;
}

// ============================================================================
