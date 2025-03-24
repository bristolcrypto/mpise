#ifdef PLATFORM_SPIKE
#include "ise.h"
.global test
test:
#endif
#ifdef PLATFORM_CVA6
#include "integration.S"
#include "ise.h"
.global main
main:
#endif
li  t0, 0x97BEB5BA
li  t1, 0x799901D9
li  t2, 0x6E8E3464
li  t3, 0x34321DD4
macclu t0, t1, t2, 0
li  t4, 0x97BF827E
bne t4, t0, fail
li  t0, 0xE51ED5FE
li  t1, 0xCEEA5F4C
li  t2, 0xDC2496D8
li  t3, 0x95093BE8
macclu t0, t1, t2, 10
li  t4, 0xE565C61E
bne t4, t0, fail
li  t0, 0x8E83A396
li  t1, 0x82AD965A
li  t2, 0x27C27C75
li  t3, 0x8EB1F182
macclu t0, t1, t2, 11
li  t4, 0x92E0F2B8
bne t4, t0, fail
li  t0, 0xC66A310F
li  t1, 0x8E76B4F4
li  t2, 0xC3177569
li  t3, 0x1E96CC7D
macclu t0, t1, t2, 4
li  t4, 0xC679ED23
bne t4, t0, fail
li  t0, 0x4134A638
li  t1, 0x12C4F84A
li  t2, 0x3922482D
li  t3, 0x9DD9F2CF
macclu t0, t1, t2, 13
li  t4, 0x677D1B3A
bne t4, t0, fail
li  t0, 0x23945D6B
li  t1, 0x8EF956F3
li  t2, 0x18B78F84
li  t3, 0x7401C5B0
macclu t0, t1, t2, 2
li  t4, 0x239BEFB7
bne t4, t0, fail
li  t0, 0xD90909A1
li  t1, 0x4479D2E5
li  t2, 0xAF0962D9
li  t3, 0xB24E9F05
macclu t0, t1, t2, 9
li  t4, 0xDC1577BE
bne t4, t0, fail
li  t0, 0x4510B1F1
li  t1, 0xFCE2B2F3
li  t2, 0x4D00BD5F
li  t3, 0xF67BD0B8
macclu t0, t1, t2, 4
li  t4, 0x452E811E
bne t4, t0, fail
li  t0, 0xD5F1D1ED
li  t1, 0x7852A45E
li  t2, 0x17C90333
li  t3, 0x9D7B0F21
macclu t0, t1, t2, 14
li  t4, 0x4623AAA7
bne t4, t0, fail
li  t0, 0x29DCE77F
li  t1, 0x5B31A1B3
li  t2, 0xAA504E52
li  t3, 0xCF49BE05
macclu t0, t1, t2, 14
li  t4, 0x64F73CD5
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
