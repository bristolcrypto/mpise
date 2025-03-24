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
li  t0, 0xC01696D75749FB4A
li  t1, 0xA01236143E4FE7B6
li  t2, 0x99750B5B53F97DF0
sraiadd t0, t1, t2, 10
li  t4, 0x9FF893571524E615
bne t4, t0, fail
li  t0, 0x2760013AA63233D9
li  t1, 0x0CFEDCD95F794FED
li  t2, 0x815FAB4F0CFCC51E
sraiadd t0, t1, t2, 10
li  t4, 0x0CDF34C4333C8F1E
bne t4, t0, fail
li  t0, 0x07A46282FC9CB006
li  t1, 0x59E0211BD2EB2706
li  t2, 0x390AB68099AA0DBC
sraiadd t0, t1, t2, 4
li  t4, 0x5D70CC83DC85C7E1
bne t4, t0, fail
li  t0, 0xCAC364BDEA4194BA
li  t1, 0xCD972A5CAB41ED91
li  t2, 0x86544AFD7C1B6BFA
sraiadd t0, t1, t2, 2
li  t4, 0xAF2C3D1C0A48C88F
bne t4, t0, fail
li  t0, 0xA9D8894A8BE60FF4
li  t1, 0xDBBD2F87E2B1383B
li  t2, 0x21AC96EDB0609C09
sraiadd t0, t1, t2, 14
li  t4, 0xDBBDB63A3E67F9BD
bne t4, t0, fail
li  t0, 0x9E31B6D780B76E08
li  t1, 0x0A285BF46A333489
li  t2, 0x3875B34A32F3A5F8
sraiadd t0, t1, t2, 10
li  t4, 0x0A3679613CBFF172
bne t4, t0, fail
li  t0, 0xBDFA16A6D7188EB4
li  t1, 0x6C5D94FF93A19449
li  t2, 0xBCFDC577CE3350D6
sraiadd t0, t1, t2, 2
li  t4, 0x5B9D065D872E687E
bne t4, t0, fail
li  t0, 0xF84DD933EF34B70B
li  t1, 0xA05636A78FD4451F
li  t2, 0xB0E8ACF20B184B70
sraiadd t0, t1, t2, 2
li  t4, 0x8C9061E4129A57FB
bne t4, t0, fail
li  t0, 0x0762B0AF56CCD5EC
li  t1, 0xC519444A47AB7F6C
li  t2, 0xE91116FD5D057CCA
sraiadd t0, t1, t2, 4
li  t4, 0xC3AA55BA1D7BD738
bne t4, t0, fail
li  t0, 0x624D1E23A227616C
li  t1, 0xB6003A309CF89B4B
li  t2, 0x036E24747D320A13
sraiadd t0, t1, t2, 8
li  t4, 0xB603A8551175CD55
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
