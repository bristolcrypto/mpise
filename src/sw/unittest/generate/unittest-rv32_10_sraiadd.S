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
li  t0, 0xD60E4FF3
li  t1, 0x019EEA35
li  t2, 0x1029F482
sraiadd t0, t1, t2, 15
li  t4, 0x019F0A88
bne t4, t0, fail
li  t0, 0xB4492AAE
li  t1, 0xD4558C8F
li  t2, 0x0C00E8B2
sraiadd t0, t1, t2, 1
li  t4, 0xDA5600E8
bne t4, t0, fail
li  t0, 0xCD3EA406
li  t1, 0xC107BCCC
li  t2, 0x322C033C
sraiadd t0, t1, t2, 0
li  t4, 0xF333C008
bne t4, t0, fail
li  t0, 0x7CAB3F03
li  t1, 0x14ADD984
li  t2, 0x2F6C0BD9
sraiadd t0, t1, t2, 10
li  t4, 0x14B9B486
bne t4, t0, fail
li  t0, 0x0AEAE57F
li  t1, 0xEFD709AB
li  t2, 0x2D26956A
sraiadd t0, t1, t2, 14
li  t4, 0xEFD7BE45
bne t4, t0, fail
li  t0, 0xA9912C37
li  t1, 0xC29D4B42
li  t2, 0x8A657CBC
sraiadd t0, t1, t2, 14
li  t4, 0xC29B74D7
bne t4, t0, fail
li  t0, 0x8BF26C0C
li  t1, 0x654A1715
li  t2, 0x9587E7BE
sraiadd t0, t1, t2, 6
li  t4, 0x63A036B3
bne t4, t0, fail
li  t0, 0x1381F906
li  t1, 0xB5124934
li  t2, 0x94F0AD91
sraiadd t0, t1, t2, 11
li  t4, 0xB504E749
bne t4, t0, fail
li  t0, 0xB1993865
li  t1, 0x07810660
li  t2, 0x4B219E48
sraiadd t0, t1, t2, 5
li  t4, 0x09DA1352
bne t4, t0, fail
li  t0, 0x2AFEE96E
li  t1, 0x6B183659
li  t2, 0x6AE4E0C0
sraiadd t0, t1, t2, 12
li  t4, 0x6B1EE4A7
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
