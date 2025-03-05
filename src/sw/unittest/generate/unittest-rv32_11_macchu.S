#include "ise.h"
.global test
test:
li  t0, 0x8394F319
li  t1, 0x0CEC2697
li  t2, 0xC4E831E6
li  t3, 0x81F407C7
macchu t0, t1, t2, 6
li  t4, 0x64A119E1
bne t4, t0, fail
li  t0, 0xC939556E
li  t1, 0xFC992313
li  t2, 0xDDC08CBC
li  t3, 0x283CFBD8
macchu t0, t1, t2, 9
li  t4, 0x7CC5952B
bne t4, t0, fail
li  t0, 0x6447365F
li  t1, 0x76D2CEDF
li  t2, 0x46BEECA9
li  t3, 0xD174486E
macchu t0, t1, t2, 2
li  t4, 0x2CA31FCB
bne t4, t0, fail
li  t0, 0xAA363FB4
li  t1, 0x83B2711F
li  t2, 0x8FC9F1CC
li  t3, 0x7B89E53A
macchu t0, t1, t2, 5
li  t4, 0x8C78FBF8
bne t4, t0, fail
li  t0, 0x4A0F44C4
li  t1, 0x3953B73F
li  t2, 0xAD6FF072
li  t3, 0x4BC815DE
macchu t0, t1, t2, 8
li  t4, 0xB56141C9
bne t4, t0, fail
li  t0, 0x924AB6F8
li  t1, 0xD210A30F
li  t2, 0x29522F94
li  t3, 0x86E25DF0
macchu t0, t1, t2, 1
li  t4, 0x98E9BF4F
bne t4, t0, fail
li  t0, 0x910A01C4
li  t1, 0xD404DEC1
li  t2, 0x85384A36
li  t3, 0x0A12A106
macchu t0, t1, t2, 10
li  t4, 0x5BAEC9E8
bne t4, t0, fail
li  t0, 0xC172931E
li  t1, 0x7D52C802
li  t2, 0x4EF481F5
li  t3, 0x5FCCE403
macchu t0, t1, t2, 5
li  t4, 0x5D206AB1
bne t4, t0, fail
li  t0, 0xAEB57AD3
li  t1, 0x60F21370
li  t2, 0x9C6695C2
li  t3, 0x2DB32801
macchu t0, t1, t2, 14
li  t4, 0x252A34D7
bne t4, t0, fail
li  t0, 0xF760D491
li  t1, 0xF0ECAF02
li  t2, 0x3A6EECD1
li  t3, 0x727A1D04
macchu t0, t1, t2, 3
li  t4, 0xD7A45D27
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
