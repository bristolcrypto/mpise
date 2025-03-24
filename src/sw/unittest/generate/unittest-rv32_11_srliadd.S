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
li  t0, 0x526D2181
li  t1, 0xF7457C24
li  t2, 0xFC1B7BF8
srliadd t0, t1, t2, 0
li  t4, 0xF360F81C
bne t4, t0, fail
li  t0, 0x01F5E410
li  t1, 0xB76B3371
li  t2, 0x260EADD9
srliadd t0, t1, t2, 1
li  t4, 0xCA728A5D
bne t4, t0, fail
li  t0, 0x10C1C09C
li  t1, 0x0C7C2D8C
li  t2, 0x1251E798
srliadd t0, t1, t2, 5
li  t4, 0x0D0EBCC8
bne t4, t0, fail
li  t0, 0xEFC6CF92
li  t1, 0x75A86100
li  t2, 0x34CC7ED9
srliadd t0, t1, t2, 12
li  t4, 0x75ABADC7
bne t4, t0, fail
li  t0, 0x9816A7A2
li  t1, 0xF0C8C0F5
li  t2, 0x464687FB
srliadd t0, t1, t2, 14
li  t4, 0xF0C9DA0F
bne t4, t0, fail
li  t0, 0x26BB7C1D
li  t1, 0x9CD0C641
li  t2, 0x021C773B
srliadd t0, t1, t2, 14
li  t4, 0x9CD0CEB2
bne t4, t0, fail
li  t0, 0xB134A6FA
li  t1, 0x35D2B973
li  t2, 0xE339E90C
srliadd t0, t1, t2, 10
li  t4, 0x360B87ED
bne t4, t0, fail
li  t0, 0x534BAC41
li  t1, 0xD0F58382
li  t2, 0xA4EE5A3D
srliadd t0, t1, t2, 8
li  t4, 0xD19A71DC
bne t4, t0, fail
li  t0, 0x53DC5FE5
li  t1, 0xEB201FF5
li  t2, 0x354724E4
srliadd t0, t1, t2, 10
li  t4, 0xEB2D71BE
bne t4, t0, fail
li  t0, 0x68A93A1E
li  t1, 0x2F73CD42
li  t2, 0x8936D6AC
srliadd t0, t1, t2, 3
li  t4, 0x409AA817
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
