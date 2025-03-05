#include "ise.h"
.global test
test:
li  t0, 0x290B00AF
li  t1, 0x285FE03C
li  t2, 0x79043DC8
li  t3, 0x90ECA630
cacc t0, t1, t2, t3
li  t4, 0x90ECA630
bne t4, t0, fail
li  t0, 0x556705BB
li  t1, 0xE44BC558
li  t2, 0xC350DEE0
li  t3, 0xCE66F971
cacc t0, t1, t2, t3
li  t4, 0xCE66F972
bne t4, t0, fail
li  t0, 0x80452C14
li  t1, 0x249F9AAD
li  t2, 0x89D765AA
li  t3, 0xB27B5748
cacc t0, t1, t2, t3
li  t4, 0xB27B5748
bne t4, t0, fail
li  t0, 0x1247F436
li  t1, 0x7AA84F43
li  t2, 0x52488616
li  t3, 0x1E3E614E
cacc t0, t1, t2, t3
li  t4, 0x1E3E614E
bne t4, t0, fail
li  t0, 0x34D54EBA
li  t1, 0x749B74C8
li  t2, 0x6D988A28
li  t3, 0x3D03B622
cacc t0, t1, t2, t3
li  t4, 0x3D03B622
bne t4, t0, fail
li  t0, 0xAD1A4296
li  t1, 0xEE6D2A8E
li  t2, 0x4F733C37
li  t3, 0x73F75AE2
cacc t0, t1, t2, t3
li  t4, 0x73F75AE3
bne t4, t0, fail
li  t0, 0xFEB7744F
li  t1, 0x82961A48
li  t2, 0xF4F94162
li  t3, 0x798E9F61
cacc t0, t1, t2, t3
li  t4, 0x798E9F62
bne t4, t0, fail
li  t0, 0x322D93E8
li  t1, 0xDF793B25
li  t2, 0xDAA72092
li  t3, 0x9C877C5C
cacc t0, t1, t2, t3
li  t4, 0x9C877C5D
bne t4, t0, fail
li  t0, 0x2F2E4397
li  t1, 0x72DBFD39
li  t2, 0x9098D299
li  t3, 0x5D941065
cacc t0, t1, t2, t3
li  t4, 0x5D941066
bne t4, t0, fail
li  t0, 0xD0598B5F
li  t1, 0xCAB08357
li  t2, 0x856B2BFB
li  t3, 0x48885DB8
cacc t0, t1, t2, t3
li  t4, 0x48885DB9
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
