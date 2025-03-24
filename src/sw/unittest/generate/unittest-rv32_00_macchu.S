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
li  t0, 0xB3369B60
li  t1, 0xCDD111F4
li  t2, 0x7F81A1DF
li  t3, 0xC12D1967
maccwri 2 ; macchu t0, t1, t2, t3
li  t4, 0x1F39D512
bne t4, t0, fail
li  t0, 0xCFC908FD
li  t1, 0x261E8D11
li  t2, 0x42B71DB3
li  t3, 0xD6C37281
maccwri 11 ; macchu t0, t1, t2, t3
li  t4, 0x75B5BC96
bne t4, t0, fail
li  t0, 0xEA927F1F
li  t1, 0x6C66CEB0
li  t2, 0x03DCF7B6
li  t3, 0x0E5D4BD7
maccwri 2 ; macchu t0, t1, t2, t3
li  t4, 0x67128A0F
bne t4, t0, fail
li  t0, 0x1C9E59E0
li  t1, 0x0A2FD291
li  t2, 0xFCFDC84C
li  t3, 0x1DF0DD85
maccwri 13 ; macchu t0, t1, t2, t3
li  t4, 0x46358F8D
bne t4, t0, fail
li  t0, 0x45D049FD
li  t1, 0x5C662A00
li  t2, 0x7C3AF57C
li  t3, 0x913D012C
maccwri 13 ; macchu t0, t1, t2, t3
li  t4, 0x4498118C
bne t4, t0, fail
li  t0, 0x3F09ECC1
li  t1, 0x69B61AE6
li  t2, 0xAE5B9C16
li  t3, 0x46F3E882
maccwri 12 ; macchu t0, t1, t2, t3
li  t4, 0x86F0BC41
bne t4, t0, fail
li  t0, 0x681D72C4
li  t1, 0x323EC559
li  t2, 0x46B9E874
li  t3, 0x9CD27C62
maccwri 6 ; macchu t0, t1, t2, t3
li  t4, 0x60206197
bne t4, t0, fail
li  t0, 0x8BC76DA5
li  t1, 0x3716C932
li  t2, 0xC1F74AF2
li  t3, 0xC9603AEE
maccwri 13 ; macchu t0, t1, t2, t3
li  t4, 0x7055CE1B
bne t4, t0, fail
li  t0, 0xB968477F
li  t1, 0x03BFBE5B
li  t2, 0x87C0B5AA
li  t3, 0xDAC307C8
maccwri 7 ; macchu t0, t1, t2, t3
li  t4, 0xD7B2E198
bne t4, t0, fail
li  t0, 0x12B910B5
li  t1, 0x7493163B
li  t2, 0xC69F7A50
li  t3, 0xDA6CC3DA
maccwri 7 ; macchu t0, t1, t2, t3
li  t4, 0x4CCF02D1
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
