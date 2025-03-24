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
li  t0, 0xB7B3FEFA9070155F
li  t1, 0x189854D5ADB0F50F
li  t2, 0x43110EEF43D160B0
sraiadd t0, t1, t2, 14
li  t4, 0x18996119E96E0454
bne t4, t0, fail
li  t0, 0xC43B7AA016928447
li  t1, 0x728E3886BDC347BF
li  t2, 0x56197FCAAB7775CD
sraiadd t0, t1, t2, 3
li  t4, 0x7D51688013323678
bne t4, t0, fail
li  t0, 0x7AE777DE625678FA
li  t1, 0x3C1D89530DEF2C77
li  t2, 0xE7E5331EB4671493
sraiadd t0, t1, t2, 6
li  t4, 0x3BBD1E1F88C0C8C9
bne t4, t0, fail
li  t0, 0x2AE27305EB28368D
li  t1, 0xB0E60BC1DF19EE87
li  t2, 0xFD3530F8F3309F2B
sraiadd t0, t1, t2, 5
li  t4, 0xB0CFB549A6B37380
bne t4, t0, fail
li  t0, 0x0170EAE6B895CCCB
li  t1, 0xEDD805107CDD0AC1
li  t2, 0xC2BC7E261A422035
sraiadd t0, t1, t2, 8
li  t4, 0xED9AC18EA2F74CE1
bne t4, t0, fail
li  t0, 0x695819AC14F3B3BD
li  t1, 0x012CDDD06B4510D0
li  t2, 0x141C0F9AC935787A
sraiadd t0, t1, t2, 11
li  t4, 0x012F61525E9E377F
bne t4, t0, fail
li  t0, 0x309B76E393A11EC2
li  t1, 0x3CC900A1E4634362
li  t2, 0xF7F982BF960772C5
sraiadd t0, t1, t2, 12
li  t4, 0x3CC8803A105CA3D9
bne t4, t0, fail
li  t0, 0x960A346ADFD29286
li  t1, 0x53766E027B42D928
li  t2, 0xC4408DFECB6F5A0A
sraiadd t0, t1, t2, 10
li  t4, 0x53677E25FAF5B4FE
bne t4, t0, fail
li  t0, 0x1435C8CC5BCC3CFA
li  t1, 0x9D722FB9DBBA3C54
li  t2, 0x49D80FC164553D0F
sraiadd t0, t1, t2, 11
li  t4, 0x9D7B6ABBD3E6C6FB
bne t4, t0, fail
li  t0, 0x852AFBBF5D0025F8
li  t1, 0x821A7661ACD53117
li  t2, 0x51D262B313A52298
sraiadd t0, t1, t2, 5
li  t4, 0x84A9097745725A2B
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
