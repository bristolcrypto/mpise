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

  // ret = r + p
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

  // ret = r + _p
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

