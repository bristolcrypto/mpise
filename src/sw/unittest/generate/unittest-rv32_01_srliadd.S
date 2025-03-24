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
li  t0, 0xDCC64223
li  t1, 0xF8B98DE6
li  t2, 0x0DAE467A
srliadd t0, t1, t2, 13
li  t4, 0xF8B9FB58
bne t4, t0, fail
li  t0, 0x09B7DF5D
li  t1, 0xC0B7810D
li  t2, 0x2F5E1192
srliadd t0, t1, t2, 13
li  t4, 0xC0B8FBFD
bne t4, t0, fail
li  t0, 0xAEB9692C
li  t1, 0x7745AB6C
li  t2, 0xE51D2A2E
srliadd t0, t1, t2, 1
li  t4, 0xE9D44083
bne t4, t0, fail
li  t0, 0xF9E4FD80
li  t1, 0xFD262532
li  t2, 0x1C2D5316
srliadd t0, t1, t2, 15
li  t4, 0xFD265D8C
bne t4, t0, fail
li  t0, 0x3DFBDDFF
li  t1, 0x523012F2
li  t2, 0x9999A6FD
srliadd t0, t1, t2, 1
li  t4, 0x9EFCE670
bne t4, t0, fail
li  t0, 0x61AB3052
li  t1, 0x3671096B
li  t2, 0x2BF4466D
srliadd t0, t1, t2, 5
li  t4, 0x37D0AB9E
bne t4, t0, fail
li  t0, 0x33EB92D6
li  t1, 0x246166FF
li  t2, 0x6155F1A5
srliadd t0, t1, t2, 3
li  t4, 0x308C2533
bne t4, t0, fail
li  t0, 0x1C9954A2
li  t1, 0x87AC48FD
li  t2, 0xCC873BD5
srliadd t0, t1, t2, 15
li  t4, 0x87ADE20B
bne t4, t0, fail
li  t0, 0xA82FF894
li  t1, 0x94FBFEAB
li  t2, 0x9774E20E
srliadd t0, t1, t2, 0
li  t4, 0x2C70E0B9
bne t4, t0, fail
li  t0, 0x66D8C3BE
li  t1, 0x41073748
li  t2, 0x20C2ECFC
srliadd t0, t1, t2, 2
li  t4, 0x4937F287
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
