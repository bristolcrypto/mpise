#include "ise.h"
.global test
test:
li  t0, 0x1D6F14FC
li  t1, 0x9C4FD73E
li  t2, 0xE6D487A3
li  t3, 0x6BE8B971
macchu t0, t1, t2, t3, 7
li  t4, 0x5D690B05
bne t4, t0, fail
li  t0, 0x2CFBA0DA
li  t1, 0xF22CF3EF
li  t2, 0xFD05B319
li  t3, 0x65EA6607
macchu t0, t1, t2, t3, 3
li  t4, 0x230076C0
bne t4, t0, fail
li  t0, 0x046F177B
li  t1, 0x718A66F7
li  t2, 0x0C55EF14
li  t3, 0xE1017F78
macchu t0, t1, t2, t3, 0
li  t4, 0x2DE9EBF1
bne t4, t0, fail
li  t0, 0xB0761D06
li  t1, 0x6C86E7E5
li  t2, 0x5CC2B5B7
li  t3, 0x856BFF01
macchu t0, t1, t2, t3, 2
li  t4, 0xE63F5EBE
bne t4, t0, fail
li  t0, 0xB6B9B4EC
li  t1, 0xCA130EDE
li  t2, 0x15B635E6
li  t3, 0xFE427B36
macchu t0, t1, t2, t3, 1
li  t4, 0xD7568CF7
bne t4, t0, fail
li  t0, 0xD2197D6E
li  t1, 0x6D6BACB6
li  t2, 0xF3785767
li  t3, 0xAC433183
macchu t0, t1, t2, t3, 2
li  t4, 0xC0DBDC2D
bne t4, t0, fail
li  t0, 0xBBA62279
li  t1, 0x9FC7972C
li  t2, 0x277D0D5E
li  t3, 0x3F074F36
macchu t0, t1, t2, t3, 8
li  t4, 0x91C1B95F
bne t4, t0, fail
li  t0, 0x800DC745
li  t1, 0x540E6B96
li  t2, 0xF7D58C30
li  t3, 0xF00C0C93
macchu t0, t1, t2, t3, 14
li  t4, 0x92CC1C3C
bne t4, t0, fail
li  t0, 0x779C8C93
li  t1, 0xEC486EEE
li  t2, 0xEEE66204
li  t3, 0xEFBF59DA
macchu t0, t1, t2, t3, 1
li  t4, 0xEE6A7035
bne t4, t0, fail
li  t0, 0x06064EA9
li  t1, 0xEB095CE5
li  t2, 0x23C95056
li  t3, 0x8E3DE391
macchu t0, t1, t2, t3, 5
li  t4, 0xFAAD2014
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
