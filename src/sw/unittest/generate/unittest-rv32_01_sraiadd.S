#include "ise.h"
.global test
test:
li  t0, 0x66E3A3A8
li  t1, 0xE0C46417
li  t2, 0x422EFCFD
sraiadd t0, t1, t2, 5
li  t4, 0xE2D5DBFE
bne t4, t0, fail
li  t0, 0x6EF92E84
li  t1, 0x0A738B65
li  t2, 0x8ED5D375
sraiadd t0, t1, t2, 5
li  t4, 0x06EA3A00
bne t4, t0, fail
li  t0, 0xCCA17129
li  t1, 0xACDC24AF
li  t2, 0x9F612C1D
sraiadd t0, t1, t2, 9
li  t4, 0xACABD545
bne t4, t0, fail
li  t0, 0x9208A4BA
li  t1, 0x232E41E2
li  t2, 0xBE685DF1
sraiadd t0, t1, t2, 2
li  t4, 0x12C8595E
bne t4, t0, fail
li  t0, 0x7F7BCAD1
li  t1, 0x96B4072C
li  t2, 0xFECFAC94
sraiadd t0, t1, t2, 10
li  t4, 0x96B3BB17
bne t4, t0, fail
li  t0, 0x0E720261
li  t1, 0xA166516D
li  t2, 0xB2173890
sraiadd t0, t1, t2, 4
li  t4, 0x9C87C4F6
bne t4, t0, fail
li  t0, 0x84E11133
li  t1, 0xC5CE9A8C
li  t2, 0x3C08D4F6
sraiadd t0, t1, t2, 2
li  t4, 0xD4D0CFC9
bne t4, t0, fail
li  t0, 0x8F286D2F
li  t1, 0xB8AEC48F
li  t2, 0xADAF5A4E
sraiadd t0, t1, t2, 14
li  t4, 0xB8AD7B4C
bne t4, t0, fail
li  t0, 0xA9A0F966
li  t1, 0x10836ACC
li  t2, 0xD1C3564C
sraiadd t0, t1, t2, 7
li  t4, 0x1026F178
bne t4, t0, fail
li  t0, 0xB0337532
li  t1, 0x11FF3AEB
li  t2, 0x8CE4562F
sraiadd t0, t1, t2, 1
li  t4, 0xD8716602
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
