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
li  t0, 0x93C97205
li  t1, 0x45389273
li  t2, 0x607B3651
li  t3, 0x70851433
macchu t0, t1, t2, 1
li  t4, 0x35BBC6C7
bne t4, t0, fail
li  t0, 0x6CD7BB46
li  t1, 0x25061618
li  t2, 0x1C163B58
li  t3, 0x518D0970
macchu t0, t1, t2, 2
li  t4, 0x6908702D
bne t4, t0, fail
li  t0, 0x02A793ED
li  t1, 0x1C6AA78D
li  t2, 0x9FAC6C12
li  t3, 0x0DF8B92D
macchu t0, t1, t2, 1
li  t4, 0x5B159CE7
bne t4, t0, fail
li  t0, 0x2B754668
li  t1, 0xC9EBB11D
li  t2, 0x60CA42C8
li  t3, 0xF7730213
macchu t0, t1, t2, 3
li  t4, 0xAA2658B2
bne t4, t0, fail
li  t0, 0xAF55B92E
li  t1, 0x7C951B52
li  t2, 0x498F0367
li  t3, 0x36E8453B
macchu t0, t1, t2, 15
li  t4, 0x23CC1DBD
bne t4, t0, fail
li  t0, 0x053418D3
li  t1, 0x1BA8F33D
li  t2, 0x25446097
li  t3, 0x30970005
macchu t0, t1, t2, 4
li  t4, 0x3BA7D99B
bne t4, t0, fail
li  t0, 0xF28267A0
li  t1, 0xE557581C
li  t2, 0x393D97E4
li  t3, 0x5CA74DDC
macchu t0, t1, t2, 3
li  t4, 0x6C8A77B6
bne t4, t0, fail
li  t0, 0x8FA106BD
li  t1, 0x9D857261
li  t2, 0x3B542697
li  t3, 0xACBE203E
macchu t0, t1, t2, 6
li  t4, 0x92B2CFF4
bne t4, t0, fail
li  t0, 0x75BAFF70
li  t1, 0x6F21EDB0
li  t2, 0x79A27476
li  t3, 0x9E4514FA
macchu t0, t1, t2, 10
li  t4, 0x0F6CEB56
bne t4, t0, fail
li  t0, 0x45A2C2F8
li  t1, 0x644EE6CC
li  t2, 0x10058081
li  t3, 0xD71BADB7
macchu t0, t1, t2, 7
li  t4, 0x8CB91439
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
