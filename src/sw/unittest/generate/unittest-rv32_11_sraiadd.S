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
li  t0, 0xCAA21980
li  t1, 0x54BBF616
li  t2, 0xB7094BF5
sraiadd t0, t1, t2, 4
li  t4, 0x502C8AD5
bne t4, t0, fail
li  t0, 0xE644B4A1
li  t1, 0x623FDB82
li  t2, 0x876249B3
sraiadd t0, t1, t2, 13
li  t4, 0x623C1694
bne t4, t0, fail
li  t0, 0xFFCA628B
li  t1, 0xE90451C8
li  t2, 0x865417C7
sraiadd t0, t1, t2, 10
li  t4, 0xE8E5E6CD
bne t4, t0, fail
li  t0, 0xA7701375
li  t1, 0x106E9E47
li  t2, 0xAEF84C25
sraiadd t0, t1, t2, 14
li  t4, 0x106D5A28
bne t4, t0, fail
li  t0, 0x91E9753C
li  t1, 0x256F38C3
li  t2, 0x7317AD9E
sraiadd t0, t1, t2, 1
li  t4, 0x5EFB0F92
bne t4, t0, fail
li  t0, 0x98859309
li  t1, 0x875B8F4E
li  t2, 0x962AA6D0
sraiadd t0, t1, t2, 2
li  t4, 0x6CE63902
bne t4, t0, fail
li  t0, 0x6654762B
li  t1, 0x5660391B
li  t2, 0x962C38EB
sraiadd t0, t1, t2, 14
li  t4, 0x565E91CB
bne t4, t0, fail
li  t0, 0x49816995
li  t1, 0x94308CA2
li  t2, 0xAFA49D18
sraiadd t0, t1, t2, 14
li  t4, 0x942F4B34
bne t4, t0, fail
li  t0, 0x1C00EFA8
li  t1, 0x94C5203D
li  t2, 0xA36228BC
sraiadd t0, t1, t2, 0
li  t4, 0x382748F9
bne t4, t0, fail
li  t0, 0xB9A83B2F
li  t1, 0xBC4E5F13
li  t2, 0xFCB87E81
sraiadd t0, t1, t2, 1
li  t4, 0xBAAA9E53
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
