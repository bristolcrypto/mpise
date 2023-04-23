#include "vect.h"
#include "consts.h"

#include <immintrin.h>
#include <stdint.h>


// macros of intel intrinsics (to facilitate the translation to risc-v asm)

#define MULX(a, b, hi)        _mulx_u64(a, b, (unsigned long long *)hi)
#define ADCX(c_in, a, b, out) _addcarryx_u64(c_in, a, b, (unsigned long long *)out)
#define SUBB(c_in, a, b, out) _subborrow_u64(c_in, a, b, (unsigned long long *)out)


// fp arithmetic 

// ret = a + b mod p 
void add_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  uint64_t a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5];
  uint64_t b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5];
  uint64_t p0 = p[0], p1 = p[1], p2 = p[2], p3 = p[3], p4 = p[4], p5 = p[5];
  uint64_t r0, r1, r2, r3, r4, r5;
  uint64_t m;
  uint8_t c;

  // r = a + b
  c = ADCX(0, a0, b0, &r0);
  c = ADCX(c, a1, b1, &r1);
  c = ADCX(c, a2, b2, &r2);
  c = ADCX(c, a3, b3, &r3);
  c = ADCX(c, a4, b4, &r4);
  c = ADCX(c, a5, b5, &r5);

  // r = r - p
  c = SUBB(0, r0, p0, &r0);
  c = SUBB(c, r1, p1, &r1);
  c = SUBB(c, r2, p2, &r2);
  c = SUBB(c, r3, p3, &r3);
  c = SUBB(c, r4, p4, &r4);
  c = SUBB(c, r5, p5, &r5);

  // m = 0 - c
  m = 0 - (uint64_t)c;

  // p = p & m
  p0 &= m;
  p1 &= m;
  p2 &= m;
  p3 &= m;
  p4 &= m;
  p5 &= m;

  // r = r + p
  c = ADCX(0, r0, p0, &r0);
  c = ADCX(c, r1, p1, &r1);
  c = ADCX(c, r2, p2, &r2);
  c = ADCX(c, r3, p3, &r3);
  c = ADCX(c, r4, p4, &r4);
  c = ADCX(c, r5, p5, &r5);

  ret[0] = r0; ret[1] = r1; ret[2] = r2;
  ret[3] = r3; ret[4] = r4; ret[5] = r5;
}

// ret = a - b mod p 
void sub_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  uint64_t a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5];
  uint64_t b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5];
  uint64_t p0 = p[0], p1 = p[1], p2 = p[2], p3 = p[3], p4 = p[4], p5 = p[5];
  uint64_t r0, r1, r2, r3, r4, r5;
  uint64_t m;
  uint8_t c;

  // r = a - b
  c = SUBB(0, a0, b0, &r0);
  c = SUBB(c, a1, b1, &r1);
  c = SUBB(c, a2, b2, &r2);
  c = SUBB(c, a3, b3, &r3);
  c = SUBB(c, a4, b4, &r4);
  c = SUBB(c, a5, b5, &r5);

  // m = 0 - c
  m = 0 - (uint64_t)c;

  // p = p & m
  p0 &= m;
  p1 &= m;
  p2 &= m;
  p3 &= m;
  p4 &= m;
  p5 &= m;

  // r = r + p
  c = ADCX(0, r0, p0, &r0);
  c = ADCX(c, r1, p1, &r1);
  c = ADCX(c, r2, p2, &r2);
  c = ADCX(c, r3, p3, &r3);
  c = ADCX(c, r4, p4, &r4);
  c = ADCX(c, r5, p5, &r5);

  ret[0] = r0; ret[1] = r1; ret[2] = r2;
  ret[3] = r3; ret[4] = r4; ret[5] = r5;
}

// if flag == 1: ret = p - a
// if flag == 0: ret = a 
void cneg_mod_384(vec384 ret, const vec384 a, bool_t flag, const vec384 p)
{
  uint64_t a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5];
  uint64_t p0 = p[0], p1 = p[1], p2 = p[2], p3 = p[3], p4 = p[4], p5 = p[5];
  uint64_t r0, r1, r2, r3, r4, r5;
  const uint64_t m = 0 - (uint64_t)(flag & 1);
  uint8_t c;

  // r = p - a
  c = SUBB(0, p0, a0, &r0);
  c = SUBB(c, p1, a1, &r1);
  c = SUBB(c, p2, a2, &r2);
  c = SUBB(c, p3, a3, &r3);
  c = SUBB(c, p4, a4, &r4);
  c = SUBB(c, p5, a5, &r5);

  // r = r ^ a
  r0 ^= a0;
  r1 ^= a1;
  r2 ^= a2;
  r3 ^= a3;
  r4 ^= a4;
  r5 ^= a5;

  // r = r & m
  r0 &= m;
  r1 &= m;
  r2 &= m;
  r3 &= m;
  r4 &= m;
  r5 &= m;

  // r = r ^ a
  r0 ^= a0;
  r1 ^= a1;
  r2 ^= a2;
  r3 ^= a3;
  r4 ^= a4;
  r5 ^= a5;

  ret[0] = r0; ret[1] = r1; ret[2] = r2;
  ret[3] = r3; ret[4] = r4; ret[5] = r5;
}

// ret = (a << count) mod p
void lshift_mod_384(vec384 ret, const vec384 a, size_t count, const vec384 p)
{
  vec384 t; 

  vec_copy(t, a, sizeof(vec384));

  while (count--) {
    add_mod_384(t, t, t, p);
  }

  vec_copy(ret, t, sizeof(vec384));
}

// ret = a * 3 mod p
void mul_by_3_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 t;

  add_mod_384(t, a, a, p);
  add_mod_384(ret, t, a, p);
}

// ret = a * 8 mod p
void mul_by_8_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 t;

  add_mod_384(t, a, a, p);
  add_mod_384(t, t, t, p);
  add_mod_384(ret, t, t, p);
}

// ret = a * b * 2^-384 mod p
// coarsely integrated operand-scanning (CIOS)
void mul_mont_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p, limb_t n0)
{
  uint64_t a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5];
  uint64_t b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5];
  uint64_t p0 = p[0], p1 = p[1], p2 = p[2], p3 = p[3], p4 = p[4], p5 = p[5];
  uint64_t z0, z1, z2, z3, z4, z5, z6;
  uint64_t t0, t1, u;
  uint8_t c0, c1;

  // z = a0 * b
  z0 = MULX(a0, b0, &z1);
  t0 = MULX(a0, b1, &z2); c0 = ADCX( 0, z1, t0, &z1);
  t0 = MULX(a0, b2, &z3); c0 = ADCX(c0, z2, t0, &z2);
  t0 = MULX(a0, b3, &z4); c0 = ADCX(c0, z3, t0, &z3);
  t0 = MULX(a0, b4, &z5); c0 = ADCX(c0, z4, t0, &z4);
  t0 = MULX(a0, b5, &z6); c0 = ADCX(c0, z5, t0, &z5);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // z = a1 * b + z
  t0 = MULX(a1, b0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);  
  t0 = MULX(a1, b1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX(a1, b2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX(a1, b3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX(a1, b4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX(a1, b5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z 
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // z = a2 * b + z
  t0 = MULX(a2, b0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);  
  t0 = MULX(a2, b1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX(a2, b2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX(a2, b3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX(a2, b4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX(a2, b5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z 
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // z = a3 * b + z
  t0 = MULX(a3, b0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);  
  t0 = MULX(a3, b1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX(a3, b2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX(a3, b3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX(a3, b4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX(a3, b5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z 
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // z = a4 * b + z
  t0 = MULX(a4, b0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);  
  t0 = MULX(a4, b1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX(a4, b2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX(a4, b3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX(a4, b4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX(a4, b5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z 
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // z = a5 * b + z
  t0 = MULX(a5, b0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);  
  t0 = MULX(a5, b1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX(a5, b2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX(a5, b3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX(a5, b4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX(a5, b5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z 
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0); c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1); c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2); c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3); c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4); c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5); c1 = ADCX(c1, z6, t1, &z6);
                          z6 = z6 + c0;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; z6 = 0;

  // final correction
  c0 = SUBB( 0, z0, p0, &z0);
  c0 = SUBB(c0, z1, p1, &z1);
  c0 = SUBB(c0, z2, p2, &z2);
  c0 = SUBB(c0, z3, p3, &z3);
  c0 = SUBB(c0, z4, p4, &z4);
  c0 = SUBB(c0, z5, p5, &z5);
  t0 = 0 - (uint64_t)c0;
  p0 &= t0; 
  p1 &= t0; 
  p2 &= t0; 
  p3 &= t0;
  p4 &= t0;
  p5 &= t0;
  c0 = ADCX( 0, z0, p0, &z0);
  c0 = ADCX(c0, z1, p1, &z1);
  c0 = ADCX(c0, z2, p2, &z2);
  c0 = ADCX(c0, z3, p3, &z3);
  c0 = ADCX(c0, z4, p4, &z4);
  c0 = ADCX(c0, z5, p5, &z5);

  ret[0] = z0; ret[1] = z1; ret[2] = z2;
  ret[3] = z3; ret[4] = z4; ret[5] = z5; 
}

// ret = a^2 * 2^-384 mod p
// todo: dedicated squaring
void sqr_mont_384(vec384 ret, const vec384 a, const vec384 p, limb_t n0)
{
  mul_mont_384(ret, a, a, p, n0);
}

// ret = a * 2^-384 mod p
// todo: optimize with product-scanning
void redc_mont_384(vec384 ret, const vec768 a, const vec384 p, limb_t n0)
{
  uint64_t z0 = a[0], z1 = a[1], z2 = a[2], z3 = a[3], z4  = a[4],  z5  = a[5];
  uint64_t z6 = a[6], z7 = a[7], z8 = a[8], z9 = a[9], z10 = a[10], z11 = a[11];
  uint64_t p0 = p[0], p1 = p[1], p2 = p[2], p3 = p[3], p4  = p[4],  p5  = p[5];
  uint64_t t0, t1, u;
  uint8_t c0, c1, c2, c3;

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0,  t0, &z0);  c1 = ADCX( 0, z1,  t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1,  t0, &z1);  c1 = ADCX(c1, z2,  t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2,  t0, &z2);  c1 = ADCX(c1, z3,  t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3,  t0, &z3);  c1 = ADCX(c1, z4,  t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4,  t0, &z4);  c1 = ADCX(c1, z5,  t1, &z5);
  t0 = MULX( u, p5, &t1); c2 = ADCX(c0, z5,  t0, &z5);  c3 = ADCX(c1, z6,  t1, &z6);
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4;  z4  = z5;  z5 = z6; 
  z6 = z7; z7 = z8; z8 = z9; z9 = z10; z10 = z11; 

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0,  t0, &z0);  c1 = ADCX( 0, z1,  t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1,  t0, &z1);  c1 = ADCX(c1, z2,  t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2,  t0, &z2);  c1 = ADCX(c1, z3,  t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3,  t0, &z3);  c1 = ADCX(c1, z4,  t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4,  t0, &z4);  c1 = ADCX(c1, z5,  t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5,  t0, &z5);  c1 = ADCX(c1, z6,  t1, &z6);
                          c2 = ADCX(c2, z5,   0, &z5);  c3 = ADCX(c3, z6,   0, &z6);
                          c2 = c0 | c2;                 c3 = c1 | c3;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4;  z4  = z5; z5 = z6; 
  z6 = z7; z7 = z8; z8 = z9; z9 = z10; 

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0);  c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1);  c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2);  c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3);  c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4);  c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5);  c1 = ADCX(c1, z6, t1, &z6);
                          c2 = ADCX(c2, z5,  0, &z5);  c3 = ADCX(c3, z6,  0, &z6);
                          c2 = c0 | c2;                c3 = c1 | c3;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; 
  z6 = z7; z7 = z8; z8 = z9; 

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0);  c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1);  c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2);  c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3);  c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4);  c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5);  c1 = ADCX(c1, z6, t1, &z6);
                          c2 = ADCX(c2, z5,  0, &z5);  c3 = ADCX(c3, z6,  0, &z6);
                          c2 = c0 | c2;                c3 = c1 | c3;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; 
  z6 = z7; z7 = z8; 

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0);  c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1);  c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2);  c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3);  c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4);  c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5);  c1 = ADCX(c1, z6, t1, &z6);
                          c2 = ADCX(c2, z5,  0, &z5);  c3 = ADCX(c3, z6,  0, &z6);
                          c2 = c0 | c2;                c3 = c1 | c3;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; 
  z6 = z7;

  // u = (z0 * n0) mod 2^64
  u  = MULX(z0, n0, &t1);
  // z = u * p + z
  t0 = MULX( u, p0, &t1); c0 = ADCX( 0, z0, t0, &z0);  c1 = ADCX( 0, z1, t1, &z1);
  t0 = MULX( u, p1, &t1); c0 = ADCX(c0, z1, t0, &z1);  c1 = ADCX(c1, z2, t1, &z2);
  t0 = MULX( u, p2, &t1); c0 = ADCX(c0, z2, t0, &z2);  c1 = ADCX(c1, z3, t1, &z3);
  t0 = MULX( u, p3, &t1); c0 = ADCX(c0, z3, t0, &z3);  c1 = ADCX(c1, z4, t1, &z4);
  t0 = MULX( u, p4, &t1); c0 = ADCX(c0, z4, t0, &z4);  c1 = ADCX(c1, z5, t1, &z5);
  t0 = MULX( u, p5, &t1); c0 = ADCX(c0, z5, t0, &z5);  c1 = ADCX(c1, z6, t1, &z6);
                          c2 = ADCX(c2, z5,  0, &z5);  c3 = ADCX(c3, z6,  0, &z6);
                          c2 = c2 | c0;
                          z6 = z6 + c2;
  // z = z / 2^64
  z0 = z1; z1 = z2; z2 = z3; z3 = z4; z4 = z5; z5 = z6; 

  // final correction
  c0 = SUBB( 0, z0, p0, &z0);
  c0 = SUBB(c0, z1, p1, &z1);
  c0 = SUBB(c0, z2, p2, &z2);
  c0 = SUBB(c0, z3, p3, &z3);
  c0 = SUBB(c0, z4, p4, &z4);
  c0 = SUBB(c0, z5, p5, &z5);
  t0 = 0 - (uint64_t)c0;
  p0 &= t0; 
  p1 &= t0; 
  p2 &= t0; 
  p3 &= t0;
  p4 &= t0;
  p5 &= t0;
  c0 = ADCX( 0, z0, p0, &z0);
  c0 = ADCX(c0, z1, p1, &z1);
  c0 = ADCX(c0, z2, p2, &z2);
  c0 = ADCX(c0, z3, p3, &z3);
  c0 = ADCX(c0, z4, p4, &z4);
  c0 = ADCX(c0, z5, p5, &z5);

  ret[0] = z0; ret[1] = z1; ret[2] = z2;
  ret[3] = z3; ret[4] = z4; ret[5] = z5; 
}


// fp2 arithmetic 

void add_mod_384x(vec384x ret, const vec384x a, const vec384x b, const vec384 p)
{
  add_mod_384(ret[0], a[0], b[0], p);
  add_mod_384(ret[1], a[1], b[1], p);
}

void sub_mod_384x(vec384x ret, const vec384x a, const vec384x b, const vec384 p)
{
  sub_mod_384(ret[0], a[0], b[0], p);
  sub_mod_384(ret[1], a[1], b[1], p);
}

