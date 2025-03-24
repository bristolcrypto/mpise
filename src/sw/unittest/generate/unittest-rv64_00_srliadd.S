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
li  t0, 0xA492908E2565519C
li  t1, 0x3CF65D6CC024D2D5
li  t2, 0x7D8845B93BDB75DE
srliadd t0, t1, t2, 12
li  t4, 0x3CFE35F11BB8908C
bne t4, t0, fail
li  t0, 0xD7582D0D9F55DB9E
li  t1, 0x3031C1C7EAA84150
li  t2, 0xF3E3E7ADDD3C4DD5
srliadd t0, t1, t2, 0
li  t4, 0x2415A975C7E48F25
bne t4, t0, fail
li  t0, 0x8EBC003DF7BEC6EB
li  t1, 0x836FDFFCDCE2E839
li  t2, 0x301C37FD89C02531
srliadd t0, t1, t2, 2
li  t4, 0x8F76EDFC3F52F185
bne t4, t0, fail
li  t0, 0xEA688ADD6080A60E
li  t1, 0x1ECBDFB0A795FD5A
li  t2, 0xEF60C6631FE1B5CD
srliadd t0, t1, t2, 11
li  t4, 0x1EE9CBC973F9F990
bne t4, t0, fail
li  t0, 0xB1060CA88C9833F5
li  t1, 0x0AB28F934F5F80BB
li  t2, 0x042F4EC60DF12BE6
srliadd t0, t1, t2, 13
li  t4, 0x0AB2B10DC58FF044
bne t4, t0, fail
li  t0, 0xF779ACE355509979
li  t1, 0x10EEEBFC28D6BB06
li  t2, 0x424431C31A1E6751
srliadd t0, t1, t2, 9
li  t4, 0x11100E150A63CA39
bne t4, t0, fail
li  t0, 0xFF19CDA0C6C9719D
li  t1, 0x7D1F682874AFDF8A
li  t2, 0x03DF28A012A56F72
srliadd t0, t1, t2, 4
li  t4, 0x7D5D5AB275DA3681
bne t4, t0, fail
li  t0, 0x698156190C9638F6
li  t1, 0x8895226943C2750E
li  t2, 0xBD859A8A2F60F6C3
srliadd t0, t1, t2, 10
li  t4, 0x88C483CFE64E4D4B
bne t4, t0, fail
li  t0, 0xDF59A8086DF71C9F
li  t1, 0x110785DF955A536E
li  t2, 0x0FCC9CD29B93D884
srliadd t0, t1, t2, 4
li  t4, 0x12044FACBF1390F6
bne t4, t0, fail
li  t0, 0x8867D99295510400
li  t1, 0x0D78EF7C38E67B1E
li  t2, 0x56B66150BA4FEF06
srliadd t0, t1, t2, 13
li  t4, 0x0D7BA52F436C4D9D
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
