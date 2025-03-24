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
li  t0, 0xA61BD35DA5F3AB60
li  t1, 0x8A086C0674773A93
li  t2, 0xC0D3A85ABBD240D3
srliadd t0, t1, t2, 4
li  t4, 0x9615A68C20345EA0
bne t4, t0, fail
li  t0, 0x74D4D3CFA699E33B
li  t1, 0x199D8F66F130A656
li  t2, 0xCF25088CBF0CB47C
srliadd t0, t1, t2, 15
li  t4, 0x199F2DB1024A246F
bne t4, t0, fail
li  t0, 0xB93F3D0578865135
li  t1, 0xE9F1BD204EA202ED
li  t2, 0x5D4134879D1DA12D
srliadd t0, t1, t2, 1
li  t4, 0x189257641D30D383
bne t4, t0, fail
li  t0, 0x0A03F61FBFF8D741
li  t1, 0xAF965947669960E9
li  t2, 0xF59344360C42087F
srliadd t0, t1, t2, 9
li  t4, 0xB01122E9819F81ED
bne t4, t0, fail
li  t0, 0xA244A96ACCA68A9E
li  t1, 0x372A5837A023A093
li  t2, 0x2FF5F62CE4A84621
srliadd t0, t1, t2, 8
li  t4, 0x375A4E2DCD0848D9
bne t4, t0, fail
li  t0, 0xA107E34B6D4F2C2A
li  t1, 0x035F3AE10A3ECDB3
li  t2, 0x89B0689B44DE4FF1
srliadd t0, t1, t2, 11
li  t4, 0x037070EE1DA7697C
bne t4, t0, fail
li  t0, 0xE43877E664BD25A9
li  t1, 0x8F51EBFCEF0C344F
li  t2, 0xE32FFC9ED30C11C7
srliadd t0, t1, t2, 1
li  t4, 0x00E9EA4C58923D32
bne t4, t0, fail
li  t0, 0x42E6DAC943930A8A
li  t1, 0x44760064B6C6C7C0
li  t2, 0x6754449F1BDFC6ED
srliadd t0, t1, t2, 13
li  t4, 0x44793B06DBBFA6BE
bne t4, t0, fail
li  t0, 0xE27BC68C143A88A4
li  t1, 0x32D78105884AC21C
li  t2, 0x3F510EAB3DD55877
srliadd t0, t1, t2, 11
li  t4, 0x32DF6B275DB27CC7
bne t4, t0, fail
li  t0, 0x492666B4508878A4
li  t1, 0x856D58C9DFE54E7A
li  t2, 0xE476F2CF4E684B91
srliadd t0, t1, t2, 1
li  t4, 0xF7A8D23187197442
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
