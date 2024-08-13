#include "main.h"

// ============================================================================

vector_macclu_t VECTOR_MACCLU[] = {
  { .r = 0, .x = 0, .y = 0, .z = 0, .c = 0 }
};

extern limb_t _test_macclu( limb_t r, limb_t x, limb_t y, limb_t z );

void test_macclu() {
  for( int i = 0; i < ( sizeof( VECTOR_MACCLU ) / sizeof( vector_macclu_t ) ); i++ ) {
    limb_t r = 0;
    limb_t x = VECTOR_MACCLU[ i ].x;
    limb_t y = VECTOR_MACCLU[ i ].y;
    limb_t z = VECTOR_MACCLU[ i ].z;

    #if defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
    r = z;
    #endif

    if( ( VECTOR_MACCLU[ i ].c != 0 ) && ( VECTOR_MACCLU[ i ].c != 2 ) ) { // only deal with 64-bit (full) or 51-bit (reduced)
      abort();
    }
    if( _test_macclu( r, x, y, z ) != VECTOR_MACCLU[ i ].r ) {
      abort();
    }
  }
}

// ----------------------------------------------------------------------------

vector_macchu_t VECTOR_MACCHU[] = {
  { .r = 0, .x = 0, .y = 0, .z = 0, .c = 0 }
};

void test_macchu() {

}

// ============================================================================

int main( int argc, char* argv[] ) {
  #if defined( MPISE_ISE ) && ( MPISE_ISE == 1 ) && defined( MPISE_STATELESS ) && ( MPISE_STATELESS == 0 )
  asm( "li t0, 0x2 ; csrrw t1, 0x800, t0" : : : "t0", "t1" ); // imm = c = 2 => radix = (w-15)+c = (64-15)+2 = 51
  #endif

  test_macclu();
  test_macchu();

  return 0;
}

// ============================================================================

