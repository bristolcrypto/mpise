#include "driver.h"

// ============================================================================

extern int test();

int main( int argc, char* argv[] ) {
  int r = test();

  if( r == 0 ) {
    printf( "executed test => fail\n" );
  }
  else {
    printf( "executed test => pass\n" );
  }


  return 0;
}

// ============================================================================
