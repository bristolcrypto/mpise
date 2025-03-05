#include "ise.h"
.global test
test:
li  t0, 0xCEBF07BA
li  t1, 0x60696F37
li  t2, 0x767DCD17
li  t3, 0x5977DA88
cacc t0, t1, t2, t3
li  t4, 0x5977DA88
bne t4, t0, fail
li  t0, 0xF160C2B3
li  t1, 0x078366E2
li  t2, 0xBB26E529
li  t3, 0x97B17A16
cacc t0, t1, t2, t3
li  t4, 0x97B17A16
bne t4, t0, fail
li  t0, 0x16246072
li  t1, 0x91753FD7
li  t2, 0xA798C148
li  t3, 0x98F417F2
cacc t0, t1, t2, t3
li  t4, 0x98F417F3
bne t4, t0, fail
li  t0, 0x338D21CF
li  t1, 0x8E9F34F3
li  t2, 0x2EF169E1
li  t3, 0xBE1ECE07
cacc t0, t1, t2, t3
li  t4, 0xBE1ECE07
bne t4, t0, fail
li  t0, 0x7BC8039D
li  t1, 0x9104E203
li  t2, 0x27AC15F8
li  t3, 0x58B3F10B
cacc t0, t1, t2, t3
li  t4, 0x58B3F10B
bne t4, t0, fail
li  t0, 0x2DA207A1
li  t1, 0x0CC23608
li  t2, 0xF605ACB7
li  t3, 0xB4123474
cacc t0, t1, t2, t3
li  t4, 0xB4123475
bne t4, t0, fail
li  t0, 0x9683E876
li  t1, 0x2BFEB525
li  t2, 0x32268F6A
li  t3, 0xC2BD0676
cacc t0, t1, t2, t3
li  t4, 0xC2BD0676
bne t4, t0, fail
li  t0, 0x6B1F37FA
li  t1, 0xFA06CC6B
li  t2, 0x28D3AA2D
li  t3, 0x27E355C1
cacc t0, t1, t2, t3
li  t4, 0x27E355C2
bne t4, t0, fail
li  t0, 0x06C2475E
li  t1, 0x65365BAC
li  t2, 0x0FD3FAC6
li  t3, 0x75829134
cacc t0, t1, t2, t3
li  t4, 0x75829134
bne t4, t0, fail
li  t0, 0xF14A15B6
li  t1, 0x36F948F4
li  t2, 0xDEA34E8E
li  t3, 0x775EF216
cacc t0, t1, t2, t3
li  t4, 0x775EF217
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
