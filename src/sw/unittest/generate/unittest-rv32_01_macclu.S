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
li  t0, 0xC7FA6C54
li  t1, 0xAB1FA6C5
li  t2, 0x0C0354EB
li  t3, 0x56B8761C
macclu t0, t1, t2, t3, 10
li  t4, 0x57CE30F3
bne t4, t0, fail
li  t0, 0x8D36731E
li  t1, 0xCC141DA2
li  t2, 0x747ADF66
li  t3, 0xAE1999A8
macclu t0, t1, t2, t3, 6
li  t4, 0xAE218634
bne t4, t0, fail
li  t0, 0x06D24642
li  t1, 0x1DF8D1F3
li  t2, 0x95D963A4
li  t3, 0x7DF07CBC
macclu t0, t1, t2, t3, 10
li  t4, 0x8082F568
bne t4, t0, fail
li  t0, 0xE31D3D42
li  t1, 0x90A4B7B5
li  t2, 0x69C7132C
li  t3, 0xD7D96207
macclu t0, t1, t2, t3, 6
li  t4, 0xD7FE6423
bne t4, t0, fail
li  t0, 0x3C7F63AE
li  t1, 0xD630DBD4
li  t2, 0x4E371104
li  t3, 0xCA64280C
macclu t0, t1, t2, t3, 12
li  t4, 0xD44CAB5C
bne t4, t0, fail
li  t0, 0xC27EA13A
li  t1, 0x158DCFA9
li  t2, 0x430B1605
li  t3, 0x2C8BB34A
macclu t0, t1, t2, t3, 12
li  t4, 0x2F6C4797
bne t4, t0, fail
li  t0, 0x0863D790
li  t1, 0x75CD4091
li  t2, 0xEE9D3273
li  t3, 0xBA2992A2
macclu t0, t1, t2, t3, 1
li  t4, 0xBA2AE5C5
bne t4, t0, fail
li  t0, 0xF89B3F05
li  t1, 0x73B313FA
li  t2, 0x7819598D
li  t3, 0xFEC1D654
macclu t0, t1, t2, t3, 6
li  t4, 0xFF3FC106
bne t4, t0, fail
li  t0, 0x61A030C6
li  t1, 0xB0226FC9
li  t2, 0x9EEDCA76
li  t3, 0x3867C814
macclu t0, t1, t2, t3, 7
li  t4, 0x3890E8BA
bne t4, t0, fail
li  t0, 0xE2999841
li  t1, 0x8B26DDDB
li  t2, 0xBCE50253
li  t3, 0xEEEAD274
macclu t0, t1, t2, t3, 8
li  t4, 0xEF277675
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
