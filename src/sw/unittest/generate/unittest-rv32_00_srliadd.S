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
li  t0, 0x62905ACD
li  t1, 0x9E59D696
li  t2, 0x31FF2801
srliadd t0, t1, t2, 11
li  t4, 0x9E60167B
bne t4, t0, fail
li  t0, 0xC64F808D
li  t1, 0x5364E22A
li  t2, 0x722DBE8E
srliadd t0, t1, t2, 14
li  t4, 0x5366AAE0
bne t4, t0, fail
li  t0, 0x12A5DBE5
li  t1, 0x1D5463AF
li  t2, 0x6ED2A7DD
srliadd t0, t1, t2, 13
li  t4, 0x1D57DA44
bne t4, t0, fail
li  t0, 0xA914EC59
li  t1, 0x75093723
li  t2, 0x59EF5EA9
srliadd t0, t1, t2, 8
li  t4, 0x75632681
bne t4, t0, fail
li  t0, 0x2D25334F
li  t1, 0x6609785C
li  t2, 0x8D5D61E3
srliadd t0, t1, t2, 2
li  t4, 0x8960D0D4
bne t4, t0, fail
li  t0, 0x33075A84
li  t1, 0x8F18472E
li  t2, 0x6F076522
srliadd t0, t1, t2, 4
li  t4, 0x9608BD80
bne t4, t0, fail
li  t0, 0x7425E31A
li  t1, 0x4320B56F
li  t2, 0x5FFFB33A
srliadd t0, t1, t2, 8
li  t4, 0x4380B522
bne t4, t0, fail
li  t0, 0x3095605E
li  t1, 0x651A98B0
li  t2, 0x4FFCD95C
srliadd t0, t1, t2, 5
li  t4, 0x679A7F7A
bne t4, t0, fail
li  t0, 0x581A1B18
li  t1, 0x4BAF049A
li  t2, 0xF21A7127
srliadd t0, t1, t2, 4
li  t4, 0x5AD0ABAC
bne t4, t0, fail
li  t0, 0x059B8932
li  t1, 0xD7BCEDAE
li  t2, 0x3ABAE814
srliadd t0, t1, t2, 12
li  t4, 0xD7C0995C
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
