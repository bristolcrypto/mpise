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
li  t0, 0x39E286D936BECE3B
li  t1, 0x52545FF1BBAFBE4A
li  t2, 0xC84D5DB789115362
sraiadd t0, t1, t2, 11
li  t4, 0x524D699D72A0E074
bne t4, t0, fail
li  t0, 0xF815B652601870A3
li  t1, 0x0DCBA5ACCC19D561
li  t2, 0x0175C45D79CEB8C4
sraiadd t0, t1, t2, 9
li  t4, 0x0DCC608EFAD6BCBD
bne t4, t0, fail
li  t0, 0x3BF7732E88B7CCD7
li  t1, 0xFA7A3FC772FAAA5B
li  t2, 0x365F6167A0F05588
sraiadd t0, t1, t2, 1
li  t4, 0x15A9F07B4372D51F
bne t4, t0, fail
li  t0, 0x8C83618162E59531
li  t1, 0x937CCA16EB2345CE
li  t2, 0x6848E21EB5559D29
sraiadd t0, t1, t2, 0
li  t4, 0xFBC5AC35A078E2F7
bne t4, t0, fail
li  t0, 0x7A2B08B1787A25D6
li  t1, 0x983C296823245ED1
li  t2, 0x849BBD2995479236
sraiadd t0, t1, t2, 14
li  t4, 0x983A3BD717CAB3EF
bne t4, t0, fail
li  t0, 0x3BA10C3F3578FA14
li  t1, 0x8F8A3D29AC52E9E1
li  t2, 0x0D1C6FE76E4FA34E
sraiadd t0, t1, t2, 10
li  t4, 0x8F8D8445A62E7DC9
bne t4, t0, fail
li  t0, 0x242DB0612577E21A
li  t1, 0xE96167ACBB8C1588
li  t2, 0x9141D424819E86EA
sraiadd t0, t1, t2, 6
li  t4, 0xE7A66EFD4D928FA3
bne t4, t0, fail
li  t0, 0xAD37A7BC001B37E5
li  t1, 0x875CED5A5C157A5A
li  t2, 0xE44E7B20284CC93A
sraiadd t0, t1, t2, 13
li  t4, 0x875C0FCE3516BCC0
bne t4, t0, fail
li  t0, 0x4A717DBFAED45F46
li  t1, 0xED512548FADF9EE3
li  t2, 0x471D7BC46A56F1FC
sraiadd t0, t1, t2, 12
li  t4, 0xED559720B7264452
bne t4, t0, fail
li  t0, 0xE235978F66EF20DA
li  t1, 0xB84376C9C9DD62DD
li  t2, 0x7F9B8F7B64E957B6
sraiadd t0, t1, t2, 0
li  t4, 0x37DF06452EC6BA93
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
