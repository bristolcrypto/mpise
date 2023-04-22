#include "vect.h"
#include "consts.h"

#include <immintrin.h>
#include <stdint.h>


// macros of intel intrinsics (to facilitate the translation to risc-v asm)

#define MULX(a, b, hi)        _mulx_u64(a, b, (unsigned long long *)hi)
#define ADCX(c_in, a, b, out) _addcarryx_u64(c_in, a, b, (unsigned long long *)out)
#define SUBB(c_in, a, b, out) _subborrow_u64(c_in, a, b, (unsigned long long *)out)


// fp arithmetic 

void add_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  vec384 z, _p;
  uint64_t m;
  uint8_t c;

  // z = a + b
  c = ADCX(0, a[0], b[0], &z[0]);
  c = ADCX(c, a[1], b[1], &z[1]);
  c = ADCX(c, a[2], b[2], &z[2]);
  c = ADCX(c, a[3], b[3], &z[3]);
  c = ADCX(c, a[4], b[4], &z[4]);
  c = ADCX(c, a[5], b[5], &z[5]);

  // z = z - p
  c = SUBB(0, z[0], p[0], &z[0]);
  c = SUBB(c, z[1], p[1], &z[1]);
  c = SUBB(c, z[2], p[2], &z[2]);
  c = SUBB(c, z[3], p[3], &z[3]);
  c = SUBB(c, z[4], p[4], &z[4]);
  c = SUBB(c, z[5], p[5], &z[5]);

  // m = 0 - c
  m = 0 - (uint64_t)c;

  // _p = p & m
  _p[0] = p[0] & m;
  _p[1] = p[1] & m;
  _p[2] = p[2] & m;
  _p[3] = p[3] & m;
  _p[4] = p[4] & m;
  _p[5] = p[5] & m;

  // ret = z + _p
  c = ADCX(0, z[0], _p[0], &ret[0]);
  c = ADCX(c, z[1], _p[1], &ret[1]);
  c = ADCX(c, z[2], _p[2], &ret[2]);
  c = ADCX(c, z[3], _p[3], &ret[3]);
  c = ADCX(c, z[4], _p[4], &ret[4]);
  c = ADCX(c, z[5], _p[5], &ret[5]);
}

void sub_mod_384(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  vec384 z, _p;
  uint64_t m;
  uint8_t c;

  // z = a - b
  c = SUBB(0, a[0], b[0], &z[0]);
  c = SUBB(c, a[1], b[1], &z[1]);
  c = SUBB(c, a[2], b[2], &z[2]);
  c = SUBB(c, a[3], b[3], &z[3]);
  c = SUBB(c, a[4], b[4], &z[4]);
  c = SUBB(c, a[5], b[5], &z[5]);

  // m = 0 - c
  m = 0 - (uint64_t)c;

  // _p = p & m
  _p[0] = p[0] & m;
  _p[1] = p[1] & m;
  _p[2] = p[2] & m;
  _p[3] = p[3] & m;
  _p[4] = p[4] & m;
  _p[5] = p[5] & m;

  // ret = z + _p
  c = ADCX(0, z[0], _p[0], &ret[0]);
  c = ADCX(c, z[1], _p[1], &ret[1]);
  c = ADCX(c, z[2], _p[2], &ret[2]);
  c = ADCX(c, z[3], _p[3], &ret[3]);
  c = ADCX(c, z[4], _p[4], &ret[4]);
  c = ADCX(c, z[5], _p[5], &ret[5]);
}

void cneg_mod_384(vec384 ret, const vec384 a, bool_t flag, const vec384 p)
{
  vec384 t;
  uint8_t c;
  uint64_t m = 0 - (uint64_t)(flag & 1);

  // if flag == 1: ret = p - a
  // if flag == 0: ret = a 

  // t = p - a
  c = SUBB(0, p[0], a[0], &t[0]);
  c = SUBB(c, p[1], a[1], &t[1]);
  c = SUBB(c, p[2], a[2], &t[2]);
  c = SUBB(c, p[3], a[3], &t[3]);
  c = SUBB(c, p[4], a[4], &t[4]);
  c = SUBB(c, p[5], a[5], &t[5]);

  // t = t ^ a
  t[0] ^= a[0];
  t[1] ^= a[1];
  t[2] ^= a[2];
  t[3] ^= a[3];
  t[4] ^= a[4];
  t[5] ^= a[5];

  // t = t & m
  t[0] &= m;
  t[1] &= m;
  t[2] &= m;
  t[3] &= m;
  t[4] &= m;
  t[5] &= m;

  // ret = t ^ a
  ret[0] = t[0] ^ a[0];
  ret[1] = t[1] ^ a[1];
  ret[2] = t[2] ^ a[2];
  ret[3] = t[3] ^ a[3];
  ret[4] = t[4] ^ a[4];
  ret[5] = t[5] ^ a[5];
}

void lshift_mod_384(vec384 ret, const vec384 a, size_t count, const vec384 p)
{
  vec384 t; 

  while (count--) {
    add_mod_384(ret, a, a, p);
  }
}

void mul_by_3_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 t;

  lshift_mod_384(t, a, 1, p);
  add_mod_384(ret, t, a, p);
}

void mul_by_8_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  lshift_mod_384(ret, a, 3, p);
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

