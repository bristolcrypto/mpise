#include "ise.h"
.global test
test:
li  t0, 0x98A4F20D
li  t1, 0x3F4F1114
li  t2, 0x2BB5AE9F
li  t3, 0x69A7A62E
maccwri 6 ; macchu t0, t1, t2
li  t4, 0x3710DB0A
bne t4, t0, fail
li  t0, 0x3614E862
li  t1, 0xC4FE64B6
li  t2, 0x50A24CB7
li  t3, 0xE0743CAF
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x2E467655
bne t4, t0, fail
li  t0, 0xDD56370F
li  t1, 0x0AC56B06
li  t2, 0xCBD18F80
li  t3, 0x7926F14B
maccwri 10 ; macchu t0, t1, t2
li  t4, 0xEFC1D988
bne t4, t0, fail
li  t0, 0x234B9F02
li  t1, 0x4AA31EE6
li  t2, 0x55612E22
li  t3, 0xEF7962E5
maccwri 0 ; macchu t0, t1, t2
li  t4, 0x628DC530
bne t4, t0, fail
li  t0, 0x412957FA
li  t1, 0x4B924FD7
li  t2, 0x3BE8AC10
li  t3, 0xCF49D900
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x87E6F721
bne t4, t0, fail
li  t0, 0x4AC7F7FF
li  t1, 0x28108E26
li  t2, 0xEF93630C
li  t3, 0xD0203DCE
maccwri 14 ; macchu t0, t1, t2
li  t4, 0x95C5036D
bne t4, t0, fail
li  t0, 0xB116F49B
li  t1, 0x09A44CE5
li  t2, 0x3559607B
li  t3, 0x2650A473
maccwri 9 ; macchu t0, t1, t2
li  t4, 0x31AF5FB3
bne t4, t0, fail
li  t0, 0x9664EFDA
li  t1, 0x3CA86ABC
li  t2, 0xDA84FA83
li  t3, 0xDE123109
maccwri 8 ; macchu t0, t1, t2
li  t4, 0x79DB7B2B
bne t4, t0, fail
li  t0, 0x54EA3844
li  t1, 0x07FA3523
li  t2, 0xCF885DF2
li  t3, 0xB8886CD9
maccwri 9 ; macchu t0, t1, t2
li  t4, 0xF2CE6C81
bne t4, t0, fail
li  t0, 0xA7D1A256
li  t1, 0xA5375749
li  t2, 0x65673216
li  t3, 0x456C2C20
maccwri 1 ; macchu t0, t1, t2
li  t4, 0x03935DA1
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
