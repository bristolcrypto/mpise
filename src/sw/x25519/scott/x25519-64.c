// TLSECC X25519 key exchange API

// Script generated code - Command line : python pseudo.py 32/64 X25519

#include <stdint.h>
#include <stdio.h>


/* Drop script generated code in here, 32 or 64 bit */

#define sspint int64_t
#define spint uint64_t
#define udpint __uint128_t
#define dpint __uint128_t

#define Wordlength 64
#define Nlimbs 5
#define Radix 51
#define Nbits 255
#define Nbytes 32

#define MERSENNE
#define MULBYINT
#define X25519

// propagate carries
static spint inline prop(spint *n) {
  int i;
  spint mask = ((spint)1 << 51u) - (spint)1;
  sspint carry = (sspint)n[0];
  carry >>= 51u;
  n[0] &= mask;
  for (i = 1; i < 4; i++) {
    carry += (sspint)n[i];
    n[i] = (spint)carry & mask;
    carry >>= 51u;
  }
  n[4] += (spint)carry;
  return -((n[4] >> 1) >> 62u);
}

// propagate carries and add p if negative, propagate carries again
static int inline flatten(spint *n) {
  spint carry = prop(n);
  n[0] -= ((spint)19u) & carry;
  n[4] += ((spint)0x8000000000000u) & carry;
  (void)prop(n);
  return (int)(carry & 1);
}

// Montgomery final subtract
static int inline modfsb(spint *n) {
  n[0] += (spint)19u;
  n[4] -= (spint)0x8000000000000u;
  return flatten(n);
}

// Modular addition - reduce less than 2p
static void inline modadd(const spint *a, const spint *b, spint *n) {
  n[0] = a[0] + b[0];
  n[1] = a[1] + b[1];
  n[2] = a[2] + b[2];
  n[3] = a[3] + b[3];
  n[4] = a[4] + b[4];
  (void)prop(n);
}

// Modular subtraction - reduce less than 2p
static void inline modsub(const spint *a, const spint *b, spint *n) {
  n[0] = a[0] - b[0];
  n[1] = a[1] - b[1];
  n[2] = a[2] - b[2];
  n[3] = a[3] - b[3];
  n[4] = a[4] - b[4];
  n[0] -= (spint)38u;
  n[4] += (spint)0x10000000000000u;
  (void)prop(n);
}

// Modular negation
static void inline modneg(const spint *b, spint *n) {
  n[0] = (spint)0 - b[0];
  n[1] = (spint)0 - b[1];
  n[2] = (spint)0 - b[2];
  n[3] = (spint)0 - b[3];
  n[4] = (spint)0 - b[4];
  n[0] -= (spint)38u;
  n[4] += (spint)0x10000000000000u;
  (void)prop(n);
}

// Modular multiplication by an integer, c=a*b mod 2p
static void inline modmli(const spint *a, int b, spint *c) {
  udpint t = 0;
  spint carry;
  spint s;
  spint mask = ((spint)1 << 51u) - (spint)1;
  t += (udpint)a[0] * (udpint)b;
  spint v0 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)a[1] * (udpint)b;
  spint v1 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)a[2] * (udpint)b;
  spint v2 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)a[3] * (udpint)b;
  spint v3 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)a[4] * (udpint)b;
  spint v4 = (spint)t & mask;
  t = t >> 51u;
  // second reduction pass

  spint ut = (spint)t;
  ut *= 0x13;
  s = v0 + ((spint)ut & mask);
  c[0] = (spint)(s & mask);
  carry = (s >> 51) + (spint)(ut >> 51);
  c[1] = v1 + carry;
  c[2] = v2;
  c[3] = v3;
  c[4] = v4;
}

// Modular multiplication, c=a*b mod 2p
static void inline modmul(const spint *a, const spint *b, spint *c) {
  dpint t = 0;
  spint ma1 = a[1] * (spint)0x13;
  spint ma2 = a[2] * (spint)0x13;
  spint ma3 = a[3] * (spint)0x13;
  spint ma4 = a[4] * (spint)0x13;
  spint carry;
  spint s;
  spint mask = ((spint)1 << 51u) - (spint)1;
  t += (dpint)ma1 * (dpint)b[4];
  t += (dpint)ma2 * (dpint)b[3];
  t += (dpint)ma3 * (dpint)b[2];
  t += (dpint)ma4 * (dpint)b[1];
  t += (dpint)a[0] * (dpint)b[0];
  spint v0 = (spint)t & mask;
  t = t >> 51u;
  t += (dpint)ma2 * (dpint)b[4];
  t += (dpint)ma3 * (dpint)b[3];
  t += (dpint)ma4 * (dpint)b[2];
  t += (dpint)a[0] * (dpint)b[1];
  t += (dpint)a[1] * (dpint)b[0];
  spint v1 = (spint)t & mask;
  t = t >> 51u;
  t += (dpint)ma3 * (dpint)b[4];
  t += (dpint)ma4 * (dpint)b[3];
  t += (dpint)a[0] * (dpint)b[2];
  t += (dpint)a[1] * (dpint)b[1];
  t += (dpint)a[2] * (dpint)b[0];
  spint v2 = (spint)t & mask;
  t = t >> 51u;
  t += (dpint)ma4 * (dpint)b[4];
  t += (dpint)a[0] * (dpint)b[3];
  t += (dpint)a[1] * (dpint)b[2];
  t += (dpint)a[2] * (dpint)b[1];
  t += (dpint)a[3] * (dpint)b[0];
  spint v3 = (spint)t & mask;
  t = t >> 51u;
  t += (dpint)a[0] * (dpint)b[4];
  t += (dpint)a[1] * (dpint)b[3];
  t += (dpint)a[2] * (dpint)b[2];
  t += (dpint)a[3] * (dpint)b[1];
  t += (dpint)a[4] * (dpint)b[0];
  spint v4 = (spint)t & mask;
  t = t >> 51u;
  // second reduction pass

  spint ut = (spint)t;
  ut *= 0x13;
  s = v0 + ((spint)ut & mask);
  c[0] = (spint)(s & mask);
  carry = (s >> 51) + (spint)(ut >> 51);
  c[1] = v1 + carry;
  c[2] = v2;
  c[3] = v3;
  c[4] = v4;
}

// Modular squaring, c=a*a mod 2p
static void inline modsqr(const spint *a, spint *c) {
  udpint t = 0;
  spint ta1 = a[1] * (spint)2;
  spint ta2 = a[2] * (spint)2;
  spint ta3 = a[3] * (spint)2;
  spint ta4 = a[4] * (spint)2;
  spint ma1 = a[1] * (spint)0x13;
  spint ma2 = a[2] * (spint)0x13;
  spint ma3 = a[3] * (spint)0x13;
  spint ma4 = a[4] * (spint)0x13;
  spint carry;
  spint s;
  spint mask = ((spint)1 << 51u) - (spint)1;
  t += (udpint)ma1 * (udpint)ta4;
  t += (udpint)ma2 * (udpint)ta3;
  t += (udpint)a[0] * (udpint)a[0];
  spint v0 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)ma2 * (udpint)ta4;
  t += (udpint)ma3 * (udpint)a[3];
  t += (udpint)a[0] * (udpint)ta1;
  spint v1 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)ma3 * (udpint)ta4;
  t += (udpint)a[0] * (udpint)ta2;
  t += (udpint)a[1] * (udpint)a[1];
  spint v2 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)ma4 * (udpint)a[4];
  t += (udpint)a[0] * (udpint)ta3;
  t += (udpint)a[1] * (udpint)ta2;
  spint v3 = (spint)t & mask;
  t = t >> 51u;
  t += (udpint)a[0] * (udpint)ta4;
  t += (udpint)a[1] * (udpint)ta3;
  t += (udpint)a[2] * (udpint)a[2];
  spint v4 = (spint)t & mask;
  t = t >> 51u;
  // second reduction pass

  spint ut = (spint)t;
  ut *= 0x13;
  s = v0 + ((spint)ut & mask);
  c[0] = (spint)(s & mask);
  carry = (s >> 51) + (spint)(ut >> 51);
  c[1] = v1 + carry;
  c[2] = v2;
  c[3] = v3;
  c[4] = v4;
}

// copy
static void inline modcpy(const spint *a, spint *c) {
  int i;
  for (i = 0; i < 5; i++) {
    c[i] = a[i];
  }
}

// square n times
static void modnsqr(spint *a, int n) {
  int i;
  for (i = 0; i < n; i++) {
    modsqr(a, a);
  }
}

// Calculate progenitor - use optimal addition chain
static void modpro(const spint *w, spint *z) {
  spint x[5];
  spint t0[5];
  spint t1[5];
  modcpy(w, x);
  modsqr(x, z);
  modmul(x, z, z);
  modcpy(z, t0);
  modnsqr(t0, 2);
  modmul(z, t0, z);
  modsqr(z, z);
  modmul(x, z, t0);
  modcpy(t0, z);
  modnsqr(z, 5);
  modmul(t0, z, z);
  modcpy(z, t1);
  modnsqr(t1, 5);
  modmul(t0, t1, t0);
  modcpy(t0, t1);
  modnsqr(t1, 15);
  modmul(t0, t1, t0);
  modcpy(t0, t1);
  modnsqr(t1, 30);
  modmul(t0, t1, t0);
  modcpy(t0, t1);
  modnsqr(t1, 60);
  modmul(t0, t1, t0);
  modcpy(t0, t1);
  modnsqr(t1, 120);
  modmul(t0, t1, t0);
  modnsqr(t0, 10);
  modmul(z, t0, z);
  modnsqr(z, 2);
  modmul(x, z, z);
}

// calculate inverse, provide progenitor h if available, NULL if not
static void modinv(const spint *x, const spint *h, spint *z) {
  int i;
  spint s[5];
  spint t[5];
  if (h == NULL) {
    modpro(x, t);
  } else {
    modcpy(h, t);
  }
  modcpy(x, s);
  for (i = 0; i < 1; i++) {
    modsqr(s, s);
    modmul(s, x, s);
  }
  modnsqr(t, 3);
  modmul(s, t, z);
}

// Convert m to internal form, n=nres(m)
static void nres(const spint *m, spint *n) {
  int i;
  for (i = 0; i < 5; i++) {
    n[i] = m[i];
  }
}

// Convert n back to normal form, m=redc(n)
static void redc(const spint *n, spint *m) {
  int i;
  for (i = 0; i < 5; i++) {
    m[i] = n[i];
  }
  (void)modfsb(m);
}

// is unity?
static int modis1(const spint *a) {
  int i;
  spint c[5];
  spint c0;
  spint d = 0;
  redc(a, c);
  for (i = 1; i < 5; i++) {
    d |= c[i];
  }
  c0 = (spint)c[0];
  return ((spint)1 & ((d - (spint)1) >> 51u) &
          (((c0 ^ (spint)1) - (spint)1) >> 51u));
}

// is zero?
static int modis0(const spint *a) {
  int i;
  spint c[5];
  spint d = 0;
  redc(a, c);
  for (i = 0; i < 5; i++) {
    d |= c[i];
  }
  return ((spint)1 & ((d - (spint)1) >> 51u));
}

// set to zero
static void modzer(spint *a) {
  int i;
  for (i = 0; i < 5; i++) {
    a[i] = 0;
  }
}

// set to one
static void modone(spint *a) {
  int i;
  a[0] = 1;
  for (i = 1; i < 5; i++) {
    a[i] = 0;
  }
  nres(a, a);
}

// set to integer
static void modint(int x, spint *a) {
  int i;
  a[0] = (spint)x;
  for (i = 1; i < 5; i++) {
    a[i] = 0;
  }
  nres(a, a);
}

// Test for quadratic residue, provide progenitor h if available, NULL if not
static int modqr(const spint *h, const spint *x) {
  spint r[5];
  if (h == NULL) {
    modpro(x, r);
    modsqr(r, r);
  } else {
    modsqr(h, r);
  }
  modmul(r, x, r);
  modnsqr(r, 1);
  return modis1(r) | modis0(x);
}

// conditional move g to f if d=1
static void modcmv(int d, const spint *g, volatile spint *f) {
  int i;
  spint c0,c1,s,t,r,aux;
  static spint R=0;
  R+=0x3cc3c33c5aa5a55a;
  r=R;
  c0=(~d)&(r+1);
  c1=d+r;
  for (i = 0; i < 5; i++) {
      s=g[i]; t=f[i];
      f[i] = aux = c0*t+c1*s;
      f[i] = aux-r*(t+s); 
  }
}

// conditional swap g and f if d=1
static void modcsw(int d, volatile spint *g, volatile spint *f) {
  int i;
  spint c0,c1,s,t,r,w,aux;
  static spint R=0;
  R+=0x3cc3c33c5aa5a55a;
  r=R;
  c0=(~d)&(r+1);
  c1=d+r;
  for (i = 0; i < 5; i++) {
      s=g[i]; t=f[i];
      w=r*(t+s);
      f[i] = aux = c0*t+c1*s;
      f[i] = aux-w;  
      g[i] = aux = c0*s+c1*t;
      g[i] = aux-w;  
  }
}

// Modular square root, provide progenitor h if available, NULL if not
static void modsqrt(const spint *x, const spint *h, spint *r) {
  int k;
  spint t[5];
  spint b[5];
  spint v[5];
  spint z[5] = {0x61b274a0ea0b0, 0xd5a5fc8f189d, 0x7ef5e9cbd0c60,
                0x78595a6804c9e, 0x2b8324804fc1d};
  spint s[5];
  spint y[5];
  if (h == NULL) {
    modpro(x, y);
  } else {
    modcpy(h, y);
  }
  modmul(y, x, s);
  modmul(s, y, t);
  nres(z, z);
  for (k = 2; k > 1; k--) {
    modcpy(t, b);
    modnsqr(b, k - 2);
    int d = 1 - modis1(b);
    modmul(s, z, v);
    modcmv(d, v, s);
    modsqr(z, z);
    modmul(t, z, v);
    modcmv(d, v, t);
  }
  modcpy(s, r);
}

// shift left by less than a word
static void modshl(unsigned int n, spint *a) {
  int i;
  a[4] = ((a[4] << n)) | (a[3] >> (51u - n));
  for (i = 3; i > 0; i--) {
    a[i] = ((a[i] << n) & (spint)0x7ffffffffffff) | (a[i - 1] >> (51u - n));
  }
  a[0] = (a[0] << n) & (spint)0x7ffffffffffff;
}

// shift right by less than a word. Return shifted out part
static int modshr(unsigned int n, spint *a) {
  int i;
  spint r = a[0] & (((spint)1 << n) - (spint)1);
  for (i = 0; i < 4; i++) {
    a[i] = (a[i] >> n) | ((a[i + 1] << (51u - n)) & (spint)0x7ffffffffffff);
  }
  a[4] = a[4] >> n;
  return r;
}

// export to byte array
static void modexp(const spint *a, char *b) {
  int i;
  spint c[5];
  redc(a, c);
  for (i = 31; i >= 0; i--) {
    b[i] = c[0] & (spint)0xff;
    (void)modshr(8, c);
  }
}

// import from byte array
// returns 1 if in range, else 0
static int modimp(const char *b, spint *a) {
  int i, res;
  for (i = 0; i < 5; i++) {
    a[i] = 0;
  }
  for (i = 0; i < 32; i++) {
    modshl(8, a);
    a[0] += (spint)(unsigned char)b[i];
  }
  res = modfsb(a);
  nres(a, a);
  return res;
}

// determine sign
static int modsign(const spint *a) {
  spint c[5];
  redc(a, c);
  return c[0] % 2;
}

// return true if equal
static int modcmp(const spint *a, const spint *b) {
  spint c[5], d[5];
  int i, eq = 1;
  redc(a, c);
  redc(b, d);
  for (i = 0; i < 5; i++) {
    eq &= (((c[i] ^ d[i]) - 1) >> 51) & 1;
  }
  return eq;
}

#define A24 121665  // Montgomery curve constant (A-2)/4
#define COF 3       // Montgomery curve cofactor = 2^cof (2 or 3)
#define GENERATOR 9
#define TWIST_SECURE // If it is a twist secure curve

// reverse bytes. Useful when dealing with little-endian formats
static void reverse(char *w)
{
    int i;
    for (i = 0; i < (Nbytes/2); i++) {
        unsigned char ch = w[i];
        w[i] = w[Nbytes - i - 1]; 
        w[Nbytes - i - 1] = ch; 
    } 
}

// clamp input - see RFC7748
static void clamp(char *bk) {
    int s=(8-(Nbits%8))%8;
    bk[0]&=-(1<<COF);
    char mask=(unsigned char)(0xffu>>s);
    bk[Nbytes-1]&=mask;
    bk[Nbytes-1]|=(unsigned char)(0x80u>>s);
}

// return nth bit of byte array
static int bit(int n,const char *a) {
    return (int)((a[n/8u]&((unsigned char)1u<<(n%8u)))>>(n%8u));
}

// RFC7748 - Montgomery curve
// bv=bk*bu, bu,bv are x coordinates on elliptic curve
static void rfc7748(const char *bk, const char *bu,char *bv) {
    int i;
    int kt;
    int swap = 0;
    char ck[Nbytes];
    char cu[Nbytes];
    spint u[Nlimbs]; spint x1[Nlimbs]; spint x2[Nlimbs]; spint x3[Nlimbs]; spint z2[Nlimbs]; spint z3[Nlimbs];
    spint A[Nlimbs]; spint B[Nlimbs]; spint AA[Nlimbs]; spint BB[Nlimbs]; spint C[Nlimbs]; spint D[Nlimbs]; spint E[Nlimbs];

    for (i=0;i<Nbytes;i++) {
        ck[i]=bk[i];
        cu[i]=bu[i];
    }

    reverse(cu);  // convert from little to big endian

    cu[0]&=0x7f;  // implementations of X25519 (but not X448) MUST mask the most significant bit in the final byte
   
// clamp input
    clamp(ck);

// import into internal representation
    modimp(cu,u);

    modcpy(u,x1);  // x_1=u
    modone(x2);    // x_2=1
    modzer(z2);    // z_2=0
    modcpy(u,x3);  // x_3=u
    modone(z3);    // z_3=1

    for (i=Nbits-1;i>=0;i--)
    {
        kt=bit(i,ck);
        swap^=kt;
        modcsw(swap,x2,x3);
        modcsw(swap,z2,z3);
        swap=kt;
            
        modadd(x2,z2,A);        // A = x_2 + z_2
        modsqr(A,AA);           // AA = A^2
        modsub(x2,z2,B);        // B = x_2 - z_2
        modsqr(B,BB);           // BB = B^2

        modsub(AA,BB,E);        // E = AA - BB
        modadd(x3,z3,C);        // C = x_3 + z_3
        
        modsub(x3,z3,D);        // D = x_3 - z_3
        modmul(D,A,D);          // DA = D * A
        modmul(C,B,C);          // CB = C * B
 
        modadd(D,C,x3); modsqr(x3,x3);    // x_3 = (DA + CB)^2
        
        modsub(D,C,z3); modsqr(z3,z3); modmul(z3,x1,z3);  // z_3 = x_1 * (DA - CB)^2
        modmul(AA,BB,x2);       // x_2 = AA * BB
        modmli(E,A24,z2);        
        modadd(z2,AA,z2); modmul(z2,E,z2);   // z_2 = E * (AA + a24 * E)
    }
    modcsw(swap,x2,x3);
    modcsw(swap,z2,z3);

#ifdef TWIST_SECURE
    modpro(z2,A);       
    modinv(z2,A,z2);    // sufficient for twist secure curves like X25519 and X448 
#else
    // Do cheap point validation here - see https://eprint.iacr.org/2020/1497
    modmul(u,z2,B);     // wZ
    modmul(B,z2,A);     // wZ^2
    modpro(A,E);        // y
    modcpy(A,C);
    modmul(E,z2,D);     // y.Z2
    modsqr(D,D);     
    modmul(D,u,D);      // w.(y.z2)^2 
    for (i=0;i<(COF-2);i++) {  // COF is 2 or 3
        modsqr(C,C);
        modmul(C,A,C);
    }
    for (i=0;i<COF;i++) {
        modsqr(E,E);
    }
    modmul(C,E,C);
    modmul(C,B,z2);
    for (i=0;i<(COF-2);i++) {
        modsqr(D,D);
    }
    modone(A); modadd(D,A,D); modfsb(D); modshr(1,D); // 1 for QR, else 0
    modmul(x2,D,x2); // set to zero for bad input point
#endif
    modmul(x2,z2,x2);   

    modexp(x2,bv);
    reverse(bv); // convert to little endian
}

// API

// #include "tlsecc.h"

void X25519_KEY_PAIR(char *SK,char *PK)
{
    char bu[Nbytes]={};
    bu[0]=GENERATOR;
    rfc7748(SK,bu,PK);
}

int X25519_SHARED_SECRET(char *SK,char *PK,char *SS)
{
    char ors=0;
    rfc7748(SK,PK,SS);

// all zeros is suspect...
    for (int i=0;i<Nbytes;i++) ors|=SS[i];
    if (ors==0) return 0;
    return 1;
}
