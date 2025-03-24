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
li  t0, 0x53EF566661996387
li  t1, 0xA4FA0EB9C76C87E4
li  t2, 0x73E67CBD1C97573A
sraiadd t0, t1, t2, 12
li  t4, 0xA5014D21933E5159
bne t4, t0, fail
li  t0, 0x5548D7238FE920CE
li  t1, 0x7AF550A3C2F00209
li  t2, 0x7698AA0069B58A65
sraiadd t0, t1, t2, 3
li  t4, 0x89C865E3D026B355
bne t4, t0, fail
li  t0, 0x29A1451435B851E7
li  t1, 0x182D196E82A9CC85
li  t2, 0x7F56529B02CDCB91
sraiadd t0, t1, t2, 3
li  t4, 0x2817E3C1E30385F7
bne t4, t0, fail
li  t0, 0x9A34AEFE43691A1B
li  t1, 0x1FE0960130116EA2
li  t2, 0x94655E4978A12478
sraiadd t0, t1, t2, 12
li  t4, 0x1FD9DC5714A8F8B4
bne t4, t0, fail
li  t0, 0xC951FB042D1DAFD7
li  t1, 0xDDE554EB88A218A3
li  t2, 0xF68DF62805725EE5
sraiadd t0, t1, t2, 6
li  t4, 0xDDBF8CC428B7E21E
bne t4, t0, fail
li  t0, 0x6D4A1A87044FA194
li  t1, 0x1688A34D0D8847EA
li  t2, 0x7A82F70D8EF5CD61
sraiadd t0, t1, t2, 14
li  t4, 0x168A8D58E9BE83C1
bne t4, t0, fail
li  t0, 0xEF345B00BA940672
li  t1, 0xECA0B8707330CDD5
li  t2, 0xC8F6383AD90DF4BA
sraiadd t0, t1, t2, 11
li  t4, 0xEC99D7377A8BEF93
bne t4, t0, fail
li  t0, 0x2C40A74CC1D8DB5E
li  t1, 0xF4064FD6F6947C19
li  t2, 0x6878CBA705CCDA4E
sraiadd t0, t1, t2, 1
li  t4, 0x2842B5AA797AE940
bne t4, t0, fail
li  t0, 0xCD8C2D176FFEC9B3
li  t1, 0x759019D5F9441E9F
li  t2, 0x212666C21348E784
sraiadd t0, t1, t2, 3
li  t4, 0x79B4E6AE3BAD3B8F
bne t4, t0, fail
li  t0, 0x1FBF6AEE9AFAC710
li  t1, 0x2FFD06576DC28379
li  t2, 0xA42539E3761BE426
sraiadd t0, t1, t2, 1
li  t4, 0x020FA34928D0758C
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
