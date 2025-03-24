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
li  t0, 0xA2A55D7F
li  t1, 0xE9D7FE05
li  t2, 0xD386DEC6
li  t3, 0x225816BF
macchu t0, t1, t2, t3, 5
li  t4, 0x033BC3C2
bne t4, t0, fail
li  t0, 0x9ED56349
li  t1, 0x00A09C0E
li  t2, 0x38F6EC32
li  t3, 0xD4765154
macchu t0, t1, t2, t3, 11
li  t4, 0xD6B22227
bne t4, t0, fail
li  t0, 0x54CE2FE0
li  t1, 0x4518236A
li  t2, 0xEB713E3B
li  t3, 0x1D8F977A
macchu t0, t1, t2, t3, 1
li  t4, 0x0BCD04B5
bne t4, t0, fail
li  t0, 0x427141DC
li  t1, 0xC17C8BB6
li  t2, 0xA90184B1
li  t3, 0xAF3A51EC
macchu t0, t1, t2, t3, 10
li  t4, 0xA6C61222
bne t4, t0, fail
li  t0, 0x8C25D478
li  t1, 0x7C0FEB9E
li  t2, 0x34B2C176
li  t3, 0x1A7F38D5
macchu t0, t1, t2, t3, 15
li  t4, 0x1989DCAF
bne t4, t0, fail
li  t0, 0x9000F428
li  t1, 0xC9D3CF60
li  t2, 0x2ACCA3F6
li  t3, 0x5F07926A
macchu t0, t1, t2, t3, 10
li  t4, 0x96CA54C3
bne t4, t0, fail
li  t0, 0xB53740E8
li  t1, 0xAC121F68
li  t2, 0x98A023EF
li  t3, 0xA559097F
macchu t0, t1, t2, t3, 8
li  t4, 0xF08C19BF
bne t4, t0, fail
li  t0, 0xD061549B
li  t1, 0xDDE3462F
li  t2, 0x7D6BD0D0
li  t3, 0x455752EC
macchu t0, t1, t2, t3, 11
li  t4, 0x10AE16EF
bne t4, t0, fail
li  t0, 0x81BA063E
li  t1, 0x08EE90BF
li  t2, 0xCCFC4412
li  t3, 0x35C09EAF
macchu t0, t1, t2, t3, 15
li  t4, 0x0726E88E
bne t4, t0, fail
li  t0, 0x94BBC544
li  t1, 0x18DF4183
li  t2, 0x991CB267
li  t3, 0x4B6329D0
macchu t0, t1, t2, t3, 10
li  t4, 0x276A26C6
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
