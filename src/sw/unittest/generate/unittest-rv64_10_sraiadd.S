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
li  t0, 0xE536F2170055762D
li  t1, 0x598B212055030E90
li  t2, 0xA9C00215592BC6AF
sraiadd t0, t1, t2, 12
li  t4, 0x5985BD207658A14C
bne t4, t0, fail
li  t0, 0x2980BFFD954FECEC
li  t1, 0x0C252BCB18C24DEA
li  t2, 0x45F539C4773D5D87
sraiadd t0, t1, t2, 6
li  t4, 0x0D3D00B22A9F4360
bne t4, t0, fail
li  t0, 0x745747EC415034C0
li  t1, 0x91C6BEE5EF12EC85
li  t2, 0x5AA6007525821D2C
sraiadd t0, t1, t2, 0
li  t4, 0xEC6CBF5B149509B1
bne t4, t0, fail
li  t0, 0x0AAA404E32C93E3F
li  t1, 0x29EBCA3B0B9670C8
li  t2, 0x75EE0D1B03A9092C
sraiadd t0, t1, t2, 14
li  t4, 0x29EDA1F340027F6C
bne t4, t0, fail
li  t0, 0x5B8277011C882D2B
li  t1, 0xDEE7FDE0A8781B0D
li  t2, 0x6F225FF25334EB75
sraiadd t0, t1, t2, 7
li  t4, 0xDFC642A08D1E84E3
bne t4, t0, fail
li  t0, 0xE107F1DB5F7C57FD
li  t1, 0xD361B7D44F30B1B6
li  t2, 0x45B4543311C6555A
sraiadd t0, t1, t2, 15
li  t4, 0xD362433CF796D542
bne t4, t0, fail
li  t0, 0xAAAEFCDDA1678AE5
li  t1, 0x93ECAC64BEDD5C6D
li  t2, 0x5DEF463665A34C80
sraiadd t0, t1, t2, 15
li  t4, 0x93ED68434B4A27B3
bne t4, t0, fail
li  t0, 0xC8F9A78BC66375D8
li  t1, 0x91C15FB68898B02B
li  t2, 0x6AEF570593BE656A
sraiadd t0, t1, t2, 5
li  t4, 0x9518DA6EB536A356
bne t4, t0, fail
li  t0, 0xDC0CD06D79B928BA
li  t1, 0x8A5DD6E569525DB6
li  t2, 0x7EACE1A198ABFC95
sraiadd t0, t1, t2, 6
li  t4, 0x8C588A6BEFB50DA8
bne t4, t0, fail
li  t0, 0x92090A8CCD3EB67E
li  t1, 0x42E8F0BB2446786E
li  t2, 0x53147B257A7B55A5
sraiadd t0, t1, t2, 8
li  t4, 0x433C053649C0F3C3
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
