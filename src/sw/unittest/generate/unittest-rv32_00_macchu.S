#include "ise.h"
.global test
test:
li  t0, 0x06B78EFF
li  t1, 0x4DD4E36E
li  t2, 0xE7621E7C
li  t3, 0xAEED046D
maccwri 10 ; macchu t0, t1, t2, t3
li  t4, 0x7A0AC3EB
bne t4, t0, fail
li  t0, 0xCE977E2A
li  t1, 0xB67709C7
li  t2, 0x29FBE815
li  t3, 0x9C73D0E0
maccwri 5 ; macchu t0, t1, t2, t3
li  t4, 0x4EE69A16
bne t4, t0, fail
li  t0, 0x2E545A45
li  t1, 0xB67860C0
li  t2, 0x0C6FBAE7
li  t3, 0xAD5D053A
maccwri 15 ; macchu t0, t1, t2, t3
li  t4, 0x08DD47F3
bne t4, t0, fail
li  t0, 0x0B8187F7
li  t1, 0x030B7458
li  t2, 0x45F12A2C
li  t3, 0xED0686E5
maccwri 14 ; macchu t0, t1, t2, t3
li  t4, 0xEEB0702E
bne t4, t0, fail
li  t0, 0x0A3113F9
li  t1, 0xE0CA5506
li  t2, 0xF493CB19
li  t3, 0x4D799A10
maccwri 10 ; macchu t0, t1, t2, t3
li  t4, 0x25CD8BED
bne t4, t0, fail
li  t0, 0xB877B97F
li  t1, 0x225EDF08
li  t2, 0x168CB7A4
li  t3, 0xC2E4D07D
maccwri 15 ; macchu t0, t1, t2, t3
li  t4, 0x03070BB5
bne t4, t0, fail
li  t0, 0x7A69283E
li  t1, 0xBD093E70
li  t2, 0x1AB8376A
li  t3, 0xC50F89AA
maccwri 12 ; macchu t0, t1, t2, t3
li  t4, 0x62E748E6
bne t4, t0, fail
li  t0, 0xDAB11EA2
li  t1, 0x7D5A49D7
li  t2, 0xEBE531B1
li  t3, 0x2FADF655
maccwri 0 ; macchu t0, t1, t2, t3
li  t4, 0x3D9EA546
bne t4, t0, fail
li  t0, 0x0B7026FC
li  t1, 0x6B13FA5D
li  t2, 0x28D45D4B
li  t3, 0x6E6F3A27
maccwri 3 ; macchu t0, t1, t2, t3
li  t4, 0xAD9A3204
bne t4, t0, fail
li  t0, 0x2BA515AE
li  t1, 0x21966A4E
li  t2, 0x98B8D481
li  t3, 0x5B178AC7
maccwri 9 ; macchu t0, t1, t2, t3
li  t4, 0x5D7B51D4
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
