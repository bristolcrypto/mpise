#include "ise.h"
.global test
test:
li  t0, 0xA9BEC03D
li  t1, 0xA2DE04D9
li  t2, 0xBF3AE3A8
li  t3, 0x05719718
cacc t0, t1, t2
li  t4, 0xA9BEC03E
bne t4, t0, fail
li  t0, 0x72EB83C2
li  t1, 0xC53419B1
li  t2, 0x90A978BB
li  t3, 0x5B38BCE6
cacc t0, t1, t2
li  t4, 0x72EB83C3
bne t4, t0, fail
li  t0, 0x4BAE4920
li  t1, 0xC6DBBF5A
li  t2, 0xA716D634
li  t3, 0x395A19D8
cacc t0, t1, t2
li  t4, 0x4BAE4921
bne t4, t0, fail
li  t0, 0x97563024
li  t1, 0x3DDBC2F3
li  t2, 0xCE92A6B3
li  t3, 0x14FF9FA7
cacc t0, t1, t2
li  t4, 0x97563025
bne t4, t0, fail
li  t0, 0x2A266EC2
li  t1, 0x6E5E99C8
li  t2, 0x33F39D6A
li  t3, 0xD8B000D4
cacc t0, t1, t2
li  t4, 0x2A266EC2
bne t4, t0, fail
li  t0, 0x7CFA2315
li  t1, 0x0551B15B
li  t2, 0x26AF1C7E
li  t3, 0xC3CF30D5
cacc t0, t1, t2
li  t4, 0x7CFA2315
bne t4, t0, fail
li  t0, 0x3CF33E1A
li  t1, 0xBD819D9C
li  t2, 0x3DCB83A0
li  t3, 0x8040FE04
cacc t0, t1, t2
li  t4, 0x3CF33E1A
bne t4, t0, fail
li  t0, 0x194082AA
li  t1, 0x12AD81AC
li  t2, 0x7346E9CA
li  t3, 0x08472E48
cacc t0, t1, t2
li  t4, 0x194082AA
bne t4, t0, fail
li  t0, 0xBA6E7692
li  t1, 0xFD4199EF
li  t2, 0x78F9B7E4
li  t3, 0xB314F4DB
cacc t0, t1, t2
li  t4, 0xBA6E7693
bne t4, t0, fail
li  t0, 0x00429713
li  t1, 0x80D1B5AE
li  t2, 0xA50488DB
li  t3, 0xDDB06651
cacc t0, t1, t2
li  t4, 0x00429714
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
