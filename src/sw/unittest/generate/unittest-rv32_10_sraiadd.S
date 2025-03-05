#include "ise.h"
.global test
test:
li  t0, 0xC1689C05
li  t1, 0xA10637E5
li  t2, 0x93921D39
sraiadd t0, t1, t2, 13
li  t4, 0xA102D475
bne t4, t0, fail
li  t0, 0x157DC5AA
li  t1, 0x49486598
li  t2, 0x6A9E78F5
sraiadd t0, t1, t2, 15
li  t4, 0x49493AD4
bne t4, t0, fail
li  t0, 0xB8E6952E
li  t1, 0x643269F3
li  t2, 0x99C2FEFA
sraiadd t0, t1, t2, 8
li  t4, 0x63CC2CF1
bne t4, t0, fail
li  t0, 0x456EEA9B
li  t1, 0x06061B07
li  t2, 0x5344C6E3
sraiadd t0, t1, t2, 10
li  t4, 0x061AEC38
bne t4, t0, fail
li  t0, 0x0D430F7B
li  t1, 0x7CE78BAF
li  t2, 0xA59F567D
sraiadd t0, t1, t2, 5
li  t4, 0x7A148662
bne t4, t0, fail
li  t0, 0x0F520081
li  t1, 0x3736CA12
li  t2, 0xCE3E7B4B
sraiadd t0, t1, t2, 2
li  t4, 0x2AC668E4
bne t4, t0, fail
li  t0, 0x9F8A5E3C
li  t1, 0x3477A307
li  t2, 0x00A24A99
sraiadd t0, t1, t2, 9
li  t4, 0x3477F42C
bne t4, t0, fail
li  t0, 0x02448B87
li  t1, 0x6459EA49
li  t2, 0x6DDD4177
sraiadd t0, t1, t2, 5
li  t4, 0x67C8D454
bne t4, t0, fail
li  t0, 0x17E07550
li  t1, 0x3212B103
li  t2, 0x87548E0D
sraiadd t0, t1, t2, 3
li  t4, 0x22FD42C4
bne t4, t0, fail
li  t0, 0x6944E8ED
li  t1, 0x56DDE45E
li  t2, 0x1918B774
sraiadd t0, t1, t2, 12
li  t4, 0x56DF75E9
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
