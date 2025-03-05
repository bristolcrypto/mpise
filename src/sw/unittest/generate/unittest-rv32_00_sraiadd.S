#include "ise.h"
.global test
test:
li  t0, 0x10FA2E0D
li  t1, 0xE84A3B7F
li  t2, 0x38C488C0
sraiadd t0, t1, t2, 7
li  t4, 0xE8BBC490
bne t4, t0, fail
li  t0, 0x7DB41D83
li  t1, 0x83824351
li  t2, 0xD0ECEA17
sraiadd t0, t1, t2, 1
li  t4, 0x6BF8B85C
bne t4, t0, fail
li  t0, 0xD154E7BA
li  t1, 0x48CEA39D
li  t2, 0xAB9770BE
sraiadd t0, t1, t2, 8
li  t4, 0x487A3B0D
bne t4, t0, fail
li  t0, 0xCFA4D5AC
li  t1, 0xDD2E7117
li  t2, 0x257967B1
sraiadd t0, t1, t2, 3
li  t4, 0xE1DD9E0D
bne t4, t0, fail
li  t0, 0x844EF413
li  t1, 0x00B25BAE
li  t2, 0xBBD95FFF
sraiadd t0, t1, t2, 10
li  t4, 0x00A15205
bne t4, t0, fail
li  t0, 0x7ECA7297
li  t1, 0x197C4D59
li  t2, 0xFF523529
sraiadd t0, t1, t2, 13
li  t4, 0x197C47EA
bne t4, t0, fail
li  t0, 0xB6D41DED
li  t1, 0x80853972
li  t2, 0x3EEE85AB
sraiadd t0, t1, t2, 2
li  t4, 0x9040DADC
bne t4, t0, fail
li  t0, 0x8A33B765
li  t1, 0x63602513
li  t2, 0x49B1C038
sraiadd t0, t1, t2, 2
li  t4, 0x75CC9521
bne t4, t0, fail
li  t0, 0x8A429BF6
li  t1, 0xF8D8FB8E
li  t2, 0x9E20CC8E
sraiadd t0, t1, t2, 14
li  t4, 0xF8D77411
bne t4, t0, fail
li  t0, 0x7FE69C4C
li  t1, 0x12AE987F
li  t2, 0x4F62867D
sraiadd t0, t1, t2, 15
li  t4, 0x12AF3744
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
