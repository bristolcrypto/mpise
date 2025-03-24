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
li  t0, 0x2E6BEDD2207A2D2C
li  t1, 0xB5218B8E8AEC0FDC
li  t2, 0xC757376DB001C541
sraiadd t0, t1, t2, 3
li  t4, 0xAE0C727C40EC4884
bne t4, t0, fail
li  t0, 0xA3C1D768E0C0572F
li  t1, 0x564540A93D211BE8
li  t2, 0xA18C28A5BAB98D96
sraiadd t0, t1, t2, 4
li  t4, 0x505E033398CCB4C1
bne t4, t0, fail
li  t0, 0xFB1E6C3D80084A20
li  t1, 0x133E564620C1C442
li  t2, 0x3AEAF2DDBEDE5B36
sraiadd t0, t1, t2, 11
li  t4, 0x1345B3A47C79A00D
bne t4, t0, fail
li  t0, 0x8D57ED743FA62EBE
li  t1, 0xDFD05A20513E15CB
li  t2, 0x020FAEF540AF2726
sraiadd t0, t1, t2, 0
li  t4, 0xE1E0091591ED3CF1
bne t4, t0, fail
li  t0, 0x2280D880F1FF92C4
li  t1, 0x1DD580C6671E599F
li  t2, 0x1015D6F75652F5DA
sraiadd t0, t1, t2, 5
li  t4, 0x1E562F7E21D0F14D
bne t4, t0, fail
li  t0, 0x6FAEECEC78008CF7
li  t1, 0x2501DB972828D93F
li  t2, 0xFE2CC1A8E2AF2FE0
sraiadd t0, t1, t2, 10
li  t4, 0x250166C79261850A
bne t4, t0, fail
li  t0, 0x544899721D86E02E
li  t1, 0x640F4CB522D8F46C
li  t2, 0xA9C12198DB9263D3
sraiadd t0, t1, t2, 8
li  t4, 0x63B90DD6BBB486CF
bne t4, t0, fail
li  t0, 0x3B136F38EBA6B0D4
li  t1, 0x83EB3122BABA2E17
li  t2, 0xF530C9DDD5314DEA
sraiadd t0, t1, t2, 8
li  t4, 0x83E061EC988F5F64
bne t4, t0, fail
li  t0, 0x88F06D5EAC3E65EC
li  t1, 0x236A34F7069F5BBB
li  t2, 0x006A1207D7E53D01
sraiadd t0, t1, t2, 6
li  t4, 0x236BDD3F25FEF0AF
bne t4, t0, fail
li  t0, 0x1205A89AB27187C5
li  t1, 0xD7D519DA34F76556
li  t2, 0x8DA8D29C71027751
sraiadd t0, t1, t2, 12
li  t4, 0xD7CDF4675EBE757D
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
