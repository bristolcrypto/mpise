#include "vect.h"
#include "consts.h"

#include <stdint.h>


#define BMASK 0x007fffffffffffff

// fp arithmetic 

// ret = a mod p
void _redc_once_384_c(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 _r, _a, _p;
  uint64_t m;
  size_t i;

  vec_copy(_a, a, sizeof(vec384));
  vec_copy(_p, p, sizeof(vec384));

  // r = a - p
  for (i = 0; i < NLIMBS; i++) _r[i] = _a[i] - _p[i];

  // carry propagation
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  // generate mask
  m = (int64_t)_r[NLIMBS-1] >> 63;

  // p = p & m
  for (i = 0; i < NLIMBS; i++) _p[i] &= m;

  // r = r + p
  for (i = 0; i < NLIMBS; i++) _r[i] += _p[i];

  // carry propagation 
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  vec_copy(ret, _r, sizeof(vec384));
}

// ret = a + b mod p
void add_mod_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  vec384 _r, _a, _b;
  size_t i;

  vec_copy(_a, a, sizeof(vec384));
  vec_copy(_b, b, sizeof(vec384));

  // r = a + b
  for (i = 0; i < NLIMBS; i++) _r[i] = _a[i] + _b[i];

  // carry propagation
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  // reduce once
  _redc_once_384_c(_r, _r, p);

  vec_copy(ret, _r, sizeof(vec384));
}

// ret = a - b mod p 
void sub_mod_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p)
{
  vec384 _r, _a, _b, _p;
  uint64_t m;
  size_t i;

  vec_copy(_a, a, sizeof(vec384));
  vec_copy(_b, b, sizeof(vec384));
  vec_copy(_p, p, sizeof(vec384));

  // r = a - b
  for (i = 0; i < NLIMBS; i++) _r[i] = _a[i] - _b[i];

  // carry propagation
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  // generate mask
  m = (int64_t)_r[NLIMBS-1] >> 63;

  // p = p & m
  for (i = 0; i < NLIMBS; i++) _p[i] &= m;

  // r = r + p
  for (i = 0; i < NLIMBS; i++) _r[i] += _p[i];

  // carry propagation 
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  vec_copy(ret, _r, sizeof(vec384));
}

void cneg_mod_384_c(vec384 ret, const vec384 a, bool_t flag, const vec384 p)
{
  vec384 _r, _a;
  const uint64_t m = 0 - (uint64_t)(flag & 1);
  size_t i;

  vec_copy(_a, a, sizeof(vec384));

  // r = p - a 
  for (i = 0; i < NLIMBS; i++) _r[i] = p[i] - _a[i];

  // carry propagation
  for (i = 0; i < NLIMBS-1; i++) {
    _r[i+1] += (int64_t)_r[i] >> LIMB_T_BITS;
    _r[i]   &= BMASK;
  }

  // r = r ^ a
  for (i = 0; i < NLIMBS-1; i++) _r[i] ^= _a[i];

  // r = r & m
  for (i = 0; i < NLIMBS-1; i++) _r[i] &= m;

  // r = r ^ a
  for (i = 0; i < NLIMBS-1; i++) _r[i] ^= _a[i];

  vec_copy(ret, _r, sizeof(vec384));
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

// ret = a * 8 mod p
void mul_by_8_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 t;

  add_mod_384(t, a, a, p);
  add_mod_384(t, t, t, p);
  add_mod_384(ret, t, t, p);
}

// ret = a * 3 mod p
void mul_by_3_mod_384(vec384 ret, const vec384 a, const vec384 p)
{
  vec384 t;

  add_mod_384(t, a, a, p);
  add_mod_384(ret, t, a, p);
}

void mul_mont_384_c(vec384 ret, const vec384 a, const vec384 b, const vec384 p, limb_t n0)
{
  vec768 z;

  mul_384_c(z, a, b);
  redc_mont_384_c(ret, z, p, n0);
}

void sqr_mont_384_c(vec384 ret, const vec384 a, const vec384 p, limb_t n0)
{
  vec768 z;

  mul_384_c(z, a, a);
  redc_mont_384_c(ret, z, p, n0);
}

void mul_384_c(vec768 ret, const vec384 a, const vec384 b)
{
  vec768 _r;
  vec384 _a, _b;
  __uint128_t t = 0;
  uint64_t c;
  size_t i, j, k;

  vec_copy(_a, a, sizeof(vec384));
  vec_copy(_b, b, sizeof(vec384));

  for (i = 0; i <= NLIMBS-1; i++) {
    for (j = 0, k = i; k >= 0; j++, k--) 
      t += (__uint128_t)_a[j] * _b[k];
    _r[i] = t & BMASK;
    t >>= 64;
    t <<= (64 - LIMB_T_BITS);
  }

  for (i = NLIMBS; i <= 2*(NLIMBS-1); i++) {
    for (j = i-(NLIMBS-1), k = NLIMBS-1; j <= NLIMBS-1; j++, k--)
      t += (__uint128_t)_a[j] * _b[k];
    _r[i] = t & BMASK;
    t >>= 64;
    t <<= (64 - LIMB_T_BITS);
  }

  vec_copy(ret, _r, sizeof(vec768));
}

void redc_mont_384_c(vec384 ret, const vec768 a, const vec384 p, limb_t n0)
{
  vec768 _a;
  vec384 _r;
  __uint128_t acc = 0;
  size_t i, j, k;

  vec_copy(_a, a, sizeof(vec768));

  for (i = 0; i < NLIMBS; i++) {
    for (j = 0; j < i; j++) {
      acc = acc + ((__uint128_t)_r[j] * p[i-j]);
    }
    acc += _a[i];
    _r[i] = (uint64_t) acc;
    _r[i] = ((__uint128_t)_r[i]*n0) & BMASK;
    acc = acc + ((__uint128_t)_r[i] * p[0]);
    acc = acc >> LIMB_T_BITS;
  }

  for (i = NLIMBS; i < 2*NLIMBS-1; i++) {
    for (j = i-NLIMBS+1; j < NLIMBS; j++) {
      acc = acc + ((__uint128_t)_r[j] * p[i-j]);
    }
    acc += _a[i];
    _r[i-NLIMBS] = acc & BMASK;
    acc = acc >> LIMB_T_BITS;
  }

  acc += _a[2*NLIMBS-1];
  _r[NLIMBS-1] = acc;

  // final correction
  _redc_once_384_c(_r, _r, p);

  vec_copy(ret, _r, sizeof(vec384));
}

void flt_inverse_mont_384(vec384 ret, const vec384 inp, const vec384 p, limb_t n0)
{
  vec384 r = { ONE_MONT_P }, a, p_minus_2, two = { 2 };
  uint64_t t;
  size_t i, j;

  vec_copy(a, inp, sizeof(vec384));
  sub_mod_384(p_minus_2, p, two, p);

  for (i = 0; i < NLIMBS; i++) {
    t = p_minus_2[i];
    for (j = 0; j < LIMB_T_BITS; j++, t >>= 1) {
      if (t & 1) mul_mont_384(r, r, a, p, n0);
      sqr_mont_384(a, a, p, n0);
    }
  }

  vec_copy(ret, r, sizeof(vec384));
}

// fp2 arithmetic 

// schoolbook
// todo: Karatsuba + Longa's method
void mul_mont_384x(vec384x ret, const vec384x a, const vec384x b, const vec384 p, limb_t n0)
{
  vec384 t0, t1, t2, t3;
  vec384 r0, r1;

  // t0 = a0 * b0 mod p
  mul_mont_384(t0, a[0], b[0], p, n0);
  // t1 = a0 * b1 mod p
  mul_mont_384(t1, a[0], b[1], p, n0);
  // t2 = a1 * b0 mod p
  mul_mont_384(t2, a[1], b[0], p, n0);
  // t3 = a1 * b1 mod p
  mul_mont_384(t3, a[1], b[1], p, n0);
  // r0 = (a0*b0 - a1*b1) mod p
  sub_mod_384(r0, t0, t3, p);
  // r1 = (a0*b1 + a1*b0) mod p
  add_mod_384(r1, t1, t2, p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

// Karatsuba
void sqr_mont_384x(vec384x ret, const vec384x a, const vec384 p, limb_t n0)
{
  vec384 t0, t1, t2, t3;
  vec384 r0, r1;

  // t0 = a0 + a1
  add_mod_384(t0, a[0], a[1], p);
  // t1 = a0 - a1 
  sub_mod_384(t1, a[0], a[1], p);
  // t2 = 2 * a0
  add_mod_384(t2, a[0], a[0], p);
  // r0 = (a0+a1) * (a0-a1)
  mul_mont_384(r0, t0, t1, p, n0);
  // r1 = 2*a0 * a1
  mul_mont_384(r1, t2, a[1], p, n0);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

void add_mod_384x(vec384x ret, const vec384x a, const vec384x b, const vec384 p)
{
  vec384 r0, r1;

  add_mod_384(r0, a[0], b[0], p);
  add_mod_384(r1, a[1], b[1], p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

void sub_mod_384x(vec384x ret, const vec384x a, const vec384x b, const vec384 p)
{  
  vec384 r0, r1;

  sub_mod_384(r0, a[0], b[0], p);
  sub_mod_384(r1, a[1], b[1], p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

void mul_by_8_mod_384x(vec384x ret, const vec384x a, const vec384 p)
{
  vec384 r0, r1;

  mul_by_8_mod_384(r0, a[0], p);
  mul_by_8_mod_384(r1, a[1], p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

void mul_by_3_mod_384x(vec384x ret, const vec384x a, const vec384 p)
{
  vec384 r0, r1;

  mul_by_3_mod_384(r0, a[0], p);
  mul_by_3_mod_384(r1, a[1], p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

void mul_by_1_plus_i_mod_384x(vec384x ret, const vec384x a, const vec384 p)
{
  vec384 r0, r1;

  sub_mod_384(r0, a[0], a[1], p);
  add_mod_384(r1, a[0], a[1], p);

  vec_copy(ret[0], r0, sizeof(vec384));
  vec_copy(ret[1], r1, sizeof(vec384));
}

// void add_mod_384x384_c(vec768 ret, const vec768 a, const vec768 b, const vec384 p)
// {
//   vec768 _r, _a, _b;
//   size_t i;

//   for (i = 0; i < NLIMBS; i++) _r[i] = _a[i] + _b[i];



// }
