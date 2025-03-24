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
li  t0, 0x3A2AA0EE
li  t1, 0xDA893496
li  t2, 0xBBB64627
sraiadd t0, t1, t2, 7
li  t4, 0xDA00A122
bne t4, t0, fail
li  t0, 0x31B3EE48
li  t1, 0x9138FBF2
li  t2, 0x9EEBB1B4
sraiadd t0, t1, t2, 1
li  t4, 0x60AED4CC
bne t4, t0, fail
li  t0, 0xB99C5A0C
li  t1, 0xF440BAF9
li  t2, 0x11439386
sraiadd t0, t1, t2, 9
li  t4, 0xF4495CC2
bne t4, t0, fail
li  t0, 0x6E4E76EE
li  t1, 0xB8E63D6B
li  t2, 0x713F060D
sraiadd t0, t1, t2, 9
li  t4, 0xB91EDCEE
bne t4, t0, fail
li  t0, 0xD4C92F3E
li  t1, 0xB1FB9FB5
li  t2, 0x3038A3CB
sraiadd t0, t1, t2, 5
li  t4, 0xB37D64D3
bne t4, t0, fail
li  t0, 0xCD34DF52
li  t1, 0x3E5853A7
li  t2, 0xEF709A1A
sraiadd t0, t1, t2, 15
li  t4, 0x3E583288
bne t4, t0, fail
li  t0, 0x6A26ED33
li  t1, 0x81632B18
li  t2, 0xECF64695
sraiadd t0, t1, t2, 3
li  t4, 0x7F01F3EA
bne t4, t0, fail
li  t0, 0x8D4EBB1E
li  t1, 0x76003039
li  t2, 0x8A3EA406
sraiadd t0, t1, t2, 14
li  t4, 0x75FE5933
bne t4, t0, fail
li  t0, 0xB5EF77C3
li  t1, 0x3D6EC8BC
li  t2, 0x052FD996
sraiadd t0, t1, t2, 4
li  t4, 0x3DC1C655
bne t4, t0, fail
li  t0, 0x431AB197
li  t1, 0x14E2F98E
li  t2, 0x41E4411E
sraiadd t0, t1, t2, 15
li  t4, 0x14E37D56
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
