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
li  t0, 0xE5A929C1
li  t1, 0x74261E99
li  t2, 0x43825F1C
sraiadd t0, t1, t2, 13
li  t4, 0x74283AAB
bne t4, t0, fail
li  t0, 0x3F22B3B8
li  t1, 0x0067C8F3
li  t2, 0xE3CDC025
sraiadd t0, t1, t2, 13
li  t4, 0x0066E761
bne t4, t0, fail
li  t0, 0xD25868E4
li  t1, 0xBEC54739
li  t2, 0x1A8FF1C2
sraiadd t0, t1, t2, 13
li  t4, 0xBEC61BB8
bne t4, t0, fail
li  t0, 0xEE9BA08C
li  t1, 0x3D7F57CD
li  t2, 0xDF209C2D
sraiadd t0, t1, t2, 11
li  t4, 0x3D7B3BE0
bne t4, t0, fail
li  t0, 0x6C8DF7A7
li  t1, 0x79023328
li  t2, 0xA05A2998
sraiadd t0, t1, t2, 12
li  t4, 0x78FC38CA
bne t4, t0, fail
li  t0, 0x0D5E3541
li  t1, 0xA735E9D9
li  t2, 0x2BE8F008
sraiadd t0, t1, t2, 1
li  t4, 0xBD2A61DD
bne t4, t0, fail
li  t0, 0xA333B0E6
li  t1, 0x371B637F
li  t2, 0x6E963B0E
sraiadd t0, t1, t2, 8
li  t4, 0x3789F9BA
bne t4, t0, fail
li  t0, 0x1435312A
li  t1, 0xD8DA3E89
li  t2, 0x0FDEC449
sraiadd t0, t1, t2, 5
li  t4, 0xD95934AB
bne t4, t0, fail
li  t0, 0xD184D395
li  t1, 0x2046089E
li  t2, 0xEA6E3F36
sraiadd t0, t1, t2, 13
li  t4, 0x20455C0F
bne t4, t0, fail
li  t0, 0x8DECF636
li  t1, 0x295205E5
li  t2, 0x342A405B
sraiadd t0, t1, t2, 4
li  t4, 0x2C94A9EA
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
