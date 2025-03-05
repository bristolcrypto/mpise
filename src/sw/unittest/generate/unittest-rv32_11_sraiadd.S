#include "ise.h"
.global test
test:
li  t0, 0x1D408738
li  t1, 0x927086F8
li  t2, 0x72666A3F
sraiadd t0, t1, t2, 9
li  t4, 0x92A9BA2D
bne t4, t0, fail
li  t0, 0x242B7F14
li  t1, 0x47C2ADFE
li  t2, 0xAEA56EE4
sraiadd t0, t1, t2, 14
li  t4, 0x47C16893
bne t4, t0, fail
li  t0, 0x9F65C3EC
li  t1, 0xB652B69B
li  t2, 0x9B913684
sraiadd t0, t1, t2, 2
li  t4, 0x9D37043C
bne t4, t0, fail
li  t0, 0x9DD6CE50
li  t1, 0x6198CD04
li  t2, 0xADCBF9EF
sraiadd t0, t1, t2, 14
li  t4, 0x61978433
bne t4, t0, fail
li  t0, 0x4A54081D
li  t1, 0xAA4CEFDD
li  t2, 0x61DD5E0F
sraiadd t0, t1, t2, 2
li  t4, 0xC2C44760
bne t4, t0, fail
li  t0, 0xD4CF666E
li  t1, 0x767656D7
li  t2, 0x7589F40E
sraiadd t0, t1, t2, 9
li  t4, 0x76B11BD1
bne t4, t0, fail
li  t0, 0x205AAF24
li  t1, 0xF7753AD1
li  t2, 0xA64E482A
sraiadd t0, t1, t2, 2
li  t4, 0xE108CCDB
bne t4, t0, fail
li  t0, 0x7D10DAD6
li  t1, 0xAF388E65
li  t2, 0x10BF0164
sraiadd t0, t1, t2, 13
li  t4, 0xAF39145D
bne t4, t0, fail
li  t0, 0x04EEAC5F
li  t1, 0xC8E3B3CB
li  t2, 0x492CF9B4
sraiadd t0, t1, t2, 9
li  t4, 0xC9084A47
bne t4, t0, fail
li  t0, 0xEB35D081
li  t1, 0xA3360FB5
li  t2, 0xB817011D
sraiadd t0, t1, t2, 1
li  t4, 0x7F419043
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
