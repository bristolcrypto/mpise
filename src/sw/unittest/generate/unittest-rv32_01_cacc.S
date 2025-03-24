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
li  t0, 0x62DF235C
li  t1, 0xFBBB5A4A
li  t2, 0x4FA28204
li  t3, 0x8D0F8BE9
cacc t0, t1, t2, t3
li  t4, 0x8D0F8BEA
bne t4, t0, fail
li  t0, 0xF0C7B316
li  t1, 0x3D68E1E4
li  t2, 0x517478CA
li  t3, 0x6DA86133
cacc t0, t1, t2, t3
li  t4, 0x6DA86133
bne t4, t0, fail
li  t0, 0x35BDD1C4
li  t1, 0x2FDBAFFB
li  t2, 0x93927272
li  t3, 0xF71168DB
cacc t0, t1, t2, t3
li  t4, 0xF71168DB
bne t4, t0, fail
li  t0, 0xF552558D
li  t1, 0x5A8AE80F
li  t2, 0x5EDDE115
li  t3, 0xFED92537
cacc t0, t1, t2, t3
li  t4, 0xFED92537
bne t4, t0, fail
li  t0, 0x94597C73
li  t1, 0x56C3EA38
li  t2, 0x4F4EDF71
li  t3, 0x5F86DB0E
cacc t0, t1, t2, t3
li  t4, 0x5F86DB0E
bne t4, t0, fail
li  t0, 0xA25430D1
li  t1, 0x285E8295
li  t2, 0x0D81302F
li  t3, 0xFA97EA73
cacc t0, t1, t2, t3
li  t4, 0xFA97EA73
bne t4, t0, fail
li  t0, 0x9C8A3FC7
li  t1, 0xBECE8DE6
li  t2, 0xEA861586
li  t3, 0x1A685378
cacc t0, t1, t2, t3
li  t4, 0x1A685379
bne t4, t0, fail
li  t0, 0x1B4EB3FC
li  t1, 0x49C97B15
li  t2, 0xFBCAD104
li  t3, 0x62367BD7
cacc t0, t1, t2, t3
li  t4, 0x62367BD8
bne t4, t0, fail
li  t0, 0x2781C2F5
li  t1, 0x7F2B4289
li  t2, 0x01C78AF0
li  t3, 0xE0B233B3
cacc t0, t1, t2, t3
li  t4, 0xE0B233B3
bne t4, t0, fail
li  t0, 0xEFEEA9C0
li  t1, 0xB91067BA
li  t2, 0xAB00444F
li  t3, 0xE1410AA7
cacc t0, t1, t2, t3
li  t4, 0xE1410AA8
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
