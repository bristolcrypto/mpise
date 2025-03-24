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
li  t0, 0xB9EAC03132873674
li  t1, 0x561B380CB5BACAAE
li  t2, 0xB7EED8CB26044D52
srliadd t0, t1, t2, 6
li  t4, 0x58FAF36FE252DBE3
bne t4, t0, fail
li  t0, 0x31D6DA5A68461E5F
li  t1, 0x4720B7D3B01E57A7
li  t2, 0xCF2E9854871EDA8E
srliadd t0, t1, t2, 0
li  t4, 0x164F5028373D3235
bne t4, t0, fail
li  t0, 0xEA21B0D174218E86
li  t1, 0xCB83BF4D2EC51677
li  t2, 0xCFF3EF82F6738BC6
srliadd t0, t1, t2, 6
li  t4, 0xCEC38F0B3A9EE4A6
bne t4, t0, fail
li  t0, 0xA59EEE14132339C4
li  t1, 0x384E8D2DD1B566D9
li  t2, 0x56211D77A0CE3B9B
srliadd t0, t1, t2, 13
li  t4, 0x38513E36BD726D4A
bne t4, t0, fail
li  t0, 0x9C5C866F685BA873
li  t1, 0x9748999C5EF0D1B8
li  t2, 0x0271B150238BF052
srliadd t0, t1, t2, 12
li  t4, 0x9748C0B773F30A77
bne t4, t0, fail
li  t0, 0x1653E4BF5F1FAA0A
li  t1, 0xE51D3E3137F8B263
li  t2, 0x8363794BD41A01F9
srliadd t0, t1, t2, 14
li  t4, 0xE51F4BBF1D2802CB
bne t4, t0, fail
li  t0, 0xB8A5C00BD13FB9C6
li  t1, 0x8633A6D94C3350FB
li  t2, 0xE3E9A5493B5E2DCB
srliadd t0, t1, t2, 8
li  t4, 0x8717907E956EAF28
bne t4, t0, fail
li  t0, 0x7DB57AED6C314D6D
li  t1, 0x29989F02D30B1055
li  t2, 0xD3E70D3C7E5460B0
srliadd t0, t1, t2, 9
li  t4, 0x2A029289714A3A85
bne t4, t0, fail
li  t0, 0xCAD4B6921ABA7916
li  t1, 0x1CE128145AE97EDF
li  t2, 0xE4A4DB4F79E1E6AE
srliadd t0, t1, t2, 8
li  t4, 0x1DC5CCEFAA6360C5
bne t4, t0, fail
li  t0, 0x8633E0F928D3D684
li  t1, 0x0FD5103F3CE5AFBE
li  t2, 0x62922E7BB1FF0ABF
srliadd t0, t1, t2, 10
li  t4, 0x0FEDB4CADBD22F80
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
