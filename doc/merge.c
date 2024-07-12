#include "merge.h"

// ============================================================================
// old

int old_f_0( int c ) {
  return c + 48;
}

int old_f_1( int c ) {
  return 0;
}

int old_f_2( int c ) {
  return BITSOF( limb_t );
}

int old_f_3( int c ) {
  return c + 48;
}

limb_t old_maccfrlu( limb_t x, limb_t y, limb_t z ) {
  dlimb_t t = x * y;
  dlimb_t m = ( 1 << BITSOF( limb_t ) ) - 1;
  dlimb_t r =   ( t + z )                       & m;
  return r;
}
   
limb_t old_maccfrhi( limb_t x, limb_t y, limb_t z ) {
  dlimb_t t = x * y;
  dlimb_t m = ( 1 << BITSOF( limb_t ) ) - 1;
  dlimb_t r = ( ( t + z ) >> BITSOF( limb_t ) ) & m;
  return r;
}

limb_t old_maccrrlu( limb_t x, limb_t y, limb_t z, int c ) {
  dlimb_t t = x * y;
  dlimb_t m = ( 1 << old_f_0( c ) ) - 1;
  dlimb_t r = ( ( t >> old_f_1( c ) ) & m ) + z;
  return r;
}
      
limb_t old_maccrrhi( limb_t x, limb_t y, limb_t z, int c ) {
  dlimb_t t = x * y;
  dlimb_t m = ( 1 << old_f_2( c ) ) - 1;
  dlimb_t r = ( ( t >> old_f_3( c ) ) & m ) + z;
  return r;
}

// ----------------------------------------------------------------------------
// new

int new_f_0( int c ) {
  if     ( c == 0 ) { // fr
    return 1;
  }
  else if( c != 0 ) { // rr 
    return 0;
  }
}

int new_f_1( int c ) {
  if     ( c == 0 ) { // fr
    return BITSOF( limb_t );
  }
  else if( c != 0 ) { // rr 
    return c + 48;
  }
}

int new_f_2( int c ) {
  if     ( c == 0 ) { // fr
    return 0;
  }
  else if( c != 0 ) { // rr 
    return 0;
  }
}

int new_f_3( int c ) {
  if     ( c == 0 ) { // fr
    return 1;
  }
  else if( c != 0 ) { // rr 
    return 0;
  }
}

int new_f_4( int c ) {
  if     ( c == 0 ) { // fr
    return BITSOF( limb_t );
  }
  else if( c != 0 ) { // rr 
    return BITSOF( limb_t );
  }
}

int new_f_5( int c ) {
  if     ( c == 0 ) { // fr
    return BITSOF( limb_t );
  }
  else if( c != 0 ) { // rr 
    return c + 48;
  }
}

limb_t new_macclu( limb_t x, limb_t y, limb_t z, int c ) {
  dlimb_t t_0 = x * y;
  dlimb_t t_1 = new_f_0( c ) ? z : 0; // fr : rr
  dlimb_t t_2 = new_f_0( c ) ? 0 : z;
  dlimb_t m   = ( 1 << new_f_1( c ) ) - 1;
  dlimb_t r   = ( ( ( t_0 + t_1 ) >> new_f_2( c ) ) & m ) + t_2;
  return r;
}

limb_t new_macchi( limb_t x, limb_t y, limb_t z, int c ) {
  dlimb_t t_0 = x * y;
  dlimb_t t_1 = new_f_3( c ) ? z : 0; // fr : rr
  dlimb_t t_2 = new_f_3( c ) ? 0 : z;
  dlimb_t m   = ( 1 << new_f_4( c ) ) - 1;
  dlimb_t r   = ( ( ( t_0 + t_1 ) >> new_f_5( c ) ) & m ) + t_2;
  return r;
}

// ============================================================================

int main( int argc, char* argv[] ) {

  for( int _x = 0; _x < ( 1 << BITSOF( limb_t ) ); _x++ ) {
    for( int _y = 0; _y < ( 1 << BITSOF( limb_t ) ); _y++ ) {
      for( int _z = 0; _z < ( 1 << BITSOF( limb_t ) ); _z++ ) {
        limb_t x = _x;
        limb_t y = _y;
        limb_t z = _z;

        int    c = 7;

        limb_t old_r_lo = old_maccfrlu( x, y, z    );
        limb_t new_r_lo = new_macclu  ( x, y, z, 0 );
        limb_t old_r_hi = old_maccfrhi( x, y, z    );
        limb_t new_r_hi = new_macchi  ( x, y, z, 0 );

        if( ( old_r_lo != new_r_lo ) || ( old_r_hi != new_r_hi ) ) {
          printf( "-- failed fr case:\n" );
          printf( "c        = %d\n",   c        );
          printf( "x        = %08X\n", x        );
          printf( "y        = %08X\n", y        );
          printf( "z        = %08X\n", z        );
          printf( "old_r_lo = %08X\n", old_r_lo );
          printf( "new_r_lo = %08X\n", new_r_lo );
          printf( "old_r_hi = %08X\n", old_r_hi );
          printf( "new_r_hi = %08X\n", new_r_hi );

          abort();
        }

               old_r_lo = old_maccrrlu( x, y, z, c );
               new_r_lo = new_macclu  ( x, y, z, c );
               old_r_hi = old_maccrrhi( x, y, z, c );
               new_r_hi = new_macchi  ( x, y, z, c );

        if( ( old_r_lo != new_r_lo ) || ( old_r_hi != new_r_hi ) ) {
          printf( "-- failed rr case:\n" );
          printf( "c        = %d\n",   c        );
          printf( "x        = %08X\n", x        );
          printf( "y        = %08X\n", y        );
          printf( "z        = %08X\n", z        );
          printf( "old_r_lo = %08X\n", old_r_lo );
          printf( "new_r_lo = %08X\n", new_r_lo );
          printf( "old_r_hi = %08X\n", old_r_hi );
          printf( "new_r_hi = %08X\n", new_r_hi );

          abort();
        }
      }
    }
  }

 return 0;
}

// ============================================================================

