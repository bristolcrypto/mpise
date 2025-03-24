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
li  t0, 0xB1973714
li  t1, 0x85BFEDA9
li  t2, 0xC086E514
srliadd t0, t1, t2, 0
li  t4, 0x4646D2BD
bne t4, t0, fail
li  t0, 0xB1E59102
li  t1, 0x06F36C8E
li  t2, 0xDABA5E02
srliadd t0, t1, t2, 1
li  t4, 0x74509B8F
bne t4, t0, fail
li  t0, 0x4F6043A2
li  t1, 0x03E08E83
li  t2, 0x1D9C284B
srliadd t0, t1, t2, 3
li  t4, 0x0794138C
bne t4, t0, fail
li  t0, 0xD91E5A5B
li  t1, 0x53107D3E
li  t2, 0x7E3B1E03
srliadd t0, t1, t2, 9
li  t4, 0x534F9ACD
bne t4, t0, fail
li  t0, 0x3F01629C
li  t1, 0x3479A3FB
li  t2, 0xCD9674F1
srliadd t0, t1, t2, 0
li  t4, 0x021018EC
bne t4, t0, fail
li  t0, 0x854C9054
li  t1, 0x9231086E
li  t2, 0xE2E8AB80
srliadd t0, t1, t2, 15
li  t4, 0x9232CE3F
bne t4, t0, fail
li  t0, 0xDD4E341B
li  t1, 0x9E36E6E7
li  t2, 0xB1196753
srliadd t0, t1, t2, 2
li  t4, 0xCA7D40BB
bne t4, t0, fail
li  t0, 0x8744BC4C
li  t1, 0x2BC73EA0
li  t2, 0x76CD6F2F
srliadd t0, t1, t2, 10
li  t4, 0x2BE4F1FB
bne t4, t0, fail
li  t0, 0x6193463B
li  t1, 0xFCAA7CAE
li  t2, 0xDF21E06F
srliadd t0, t1, t2, 0
li  t4, 0xDBCC5D1D
bne t4, t0, fail
li  t0, 0x602EA46D
li  t1, 0x36057AEC
li  t2, 0xA1F56D44
srliadd t0, t1, t2, 8
li  t4, 0x36A77059
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
