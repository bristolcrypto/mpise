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
li  t0, 0xCE592850
li  t1, 0x0F0647A6
li  t2, 0x5D1E2BDB
li  t3, 0x92E978CD
cacc t0, t1, t2
li  t4, 0xCE592850
bne t4, t0, fail
li  t0, 0x24E1D35B
li  t1, 0x344F32DB
li  t2, 0x27885CC2
li  t3, 0xB49B9FBA
cacc t0, t1, t2
li  t4, 0x24E1D35B
bne t4, t0, fail
li  t0, 0xCA6F3B24
li  t1, 0x8FC4099C
li  t2, 0x666FC7B3
li  t3, 0x4303AF39
cacc t0, t1, t2
li  t4, 0xCA6F3B24
bne t4, t0, fail
li  t0, 0xDAF5F9CF
li  t1, 0xE7AEC872
li  t2, 0x39286F19
li  t3, 0xF4DB0693
cacc t0, t1, t2
li  t4, 0xDAF5F9D0
bne t4, t0, fail
li  t0, 0x9D158EE8
li  t1, 0x26608B34
li  t2, 0x9F0CA7AF
li  t3, 0xA7FB9938
cacc t0, t1, t2
li  t4, 0x9D158EE8
bne t4, t0, fail
li  t0, 0x60EC260A
li  t1, 0x7947E49F
li  t2, 0xA790E1A0
li  t3, 0x3664D252
cacc t0, t1, t2
li  t4, 0x60EC260B
bne t4, t0, fail
li  t0, 0xC22D951E
li  t1, 0xD277F9F8
li  t2, 0x76541875
li  t3, 0xF1871EB2
cacc t0, t1, t2
li  t4, 0xC22D951F
bne t4, t0, fail
li  t0, 0xD166074F
li  t1, 0x2705D526
li  t2, 0x1C97F010
li  t3, 0x9951B47D
cacc t0, t1, t2
li  t4, 0xD166074F
bne t4, t0, fail
li  t0, 0xAB04CAB1
li  t1, 0x8A7D1950
li  t2, 0xF948676F
li  t3, 0x14B1692B
cacc t0, t1, t2
li  t4, 0xAB04CAB2
bne t4, t0, fail
li  t0, 0x8ED54183
li  t1, 0xF0769C34
li  t2, 0xE77BFB3D
li  t3, 0x7F1FBEAD
cacc t0, t1, t2
li  t4, 0x8ED54184
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
