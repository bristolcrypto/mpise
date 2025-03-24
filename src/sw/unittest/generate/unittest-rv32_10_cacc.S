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
li  t0, 0xA3C9B759
li  t1, 0xA4042DDB
li  t2, 0x8C4A888B
li  t3, 0x13EA35B1
cacc t0, t1, t2
li  t4, 0xA3C9B75A
bne t4, t0, fail
li  t0, 0xE5DB3282
li  t1, 0x64B5B554
li  t2, 0x7CB92CA9
li  t3, 0xF4F62375
cacc t0, t1, t2
li  t4, 0xE5DB3282
bne t4, t0, fail
li  t0, 0xDCBCF678
li  t1, 0x26C4B428
li  t2, 0xEDAD5020
li  t3, 0xB60EDB42
cacc t0, t1, t2
li  t4, 0xDCBCF679
bne t4, t0, fail
li  t0, 0xF2EFB9AA
li  t1, 0x7457D3CB
li  t2, 0xC93624D0
li  t3, 0x0A5F97B8
cacc t0, t1, t2
li  t4, 0xF2EFB9AB
bne t4, t0, fail
li  t0, 0x883C2F4D
li  t1, 0x4627DCAC
li  t2, 0x1F775F86
li  t3, 0x34C02CDE
cacc t0, t1, t2
li  t4, 0x883C2F4D
bne t4, t0, fail
li  t0, 0x24E8270A
li  t1, 0x0946E7FB
li  t2, 0x45880CD0
li  t3, 0x205A585F
cacc t0, t1, t2
li  t4, 0x24E8270A
bne t4, t0, fail
li  t0, 0x23391CF0
li  t1, 0x7FDD4293
li  t2, 0x165BA30D
li  t3, 0xBC38DBDA
cacc t0, t1, t2
li  t4, 0x23391CF0
bne t4, t0, fail
li  t0, 0xCA2AABB2
li  t1, 0x1BDF355A
li  t2, 0x0B7D2730
li  t3, 0x3F4B7786
cacc t0, t1, t2
li  t4, 0xCA2AABB2
bne t4, t0, fail
li  t0, 0xF6F6181B
li  t1, 0x5556F76F
li  t2, 0xFA47637B
li  t3, 0xB1BFFC17
cacc t0, t1, t2
li  t4, 0xF6F6181C
bne t4, t0, fail
li  t0, 0x7B90A337
li  t1, 0x039A87ED
li  t2, 0x15825CE5
li  t3, 0xC3B3137A
cacc t0, t1, t2
li  t4, 0x7B90A337
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
