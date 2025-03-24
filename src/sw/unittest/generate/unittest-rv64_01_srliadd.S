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
li  t0, 0x5C87788A9B12600D
li  t1, 0xB0923556F1916256
li  t2, 0xD73C0CD683A8C121
srliadd t0, t1, t2, 10
li  t4, 0xB0C8045A27324C86
bne t4, t0, fail
li  t0, 0x4AE3FADAF652267A
li  t1, 0xB76F7CD566F3B339
li  t2, 0x28F9691D26646A10
srliadd t0, t1, t2, 14
li  t4, 0xB77020BB0B684CCA
bne t4, t0, fail
li  t0, 0x7776A8FA4678927E
li  t1, 0xA1340F89E949386A
li  t2, 0xC7CD91F88F93FB10
srliadd t0, t1, t2, 14
li  t4, 0xA1372EC0312B76B9
bne t4, t0, fail
li  t0, 0x25AE287216317080
li  t1, 0x56967D4A1493490A
li  t2, 0x08F5B668F12E4865
srliadd t0, t1, t2, 2
li  t4, 0x58D3EAE450DEDB23
bne t4, t0, fail
li  t0, 0xCF15456208CD0186
li  t1, 0xC4CD94CA4DED8D3A
li  t2, 0xDFF126080A3A2F00
srliadd t0, t1, t2, 15
li  t4, 0xC4CF54AC99FDA1AE
bne t4, t0, fail
li  t0, 0x2012E3A742A470C5
li  t1, 0x80B18C57C4B9E8A4
li  t2, 0xBE44AA897C538DD0
srliadd t0, t1, t2, 11
li  t4, 0x80C954ED15E97315
bne t4, t0, fail
li  t0, 0x2431433CA9E7323F
li  t1, 0x0926F8B17B24C7C9
li  t2, 0xD85566A5A88F9478
srliadd t0, t1, t2, 12
li  t4, 0x09347E07E57F50C2
bne t4, t0, fail
li  t0, 0x85A60552A00312A8
li  t1, 0x1B0ABD9DFC64EC14
li  t2, 0xD447A60C9280B87A
srliadd t0, t1, t2, 11
li  t4, 0x1B254692BDF73C2B
bne t4, t0, fail
li  t0, 0x76E4A28F0445BE52
li  t1, 0x4A1DB8EACCCCA3C5
li  t2, 0x33DBB0BA9CE20852
srliadd t0, t1, t2, 9
li  t4, 0x4A37A6C32A1B14C9
bne t4, t0, fail
li  t0, 0x9BA835DFA5AD33D2
li  t1, 0x4DB7CDB7298901D2
li  t2, 0x5D355B57BD47620D
srliadd t0, t1, t2, 15
li  t4, 0x4DB88821E0387C60
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
