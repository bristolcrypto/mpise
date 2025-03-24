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
li  t0, 0xBE1B484C
li  t1, 0x0C55C803
li  t2, 0x2B9942A5
li  t3, 0xDE3B61FE
maccwri 3 ; macclu t0, t1, t2
li  t4, 0xBE20F83B
bne t4, t0, fail
li  t0, 0x515F2660
li  t1, 0xACD66499
li  t2, 0x95D7A1A4
li  t3, 0x9DF40E94
maccwri 12 ; macclu t0, t1, t2
li  t4, 0x697AD164
bne t4, t0, fail
li  t0, 0x61C7FDBA
li  t1, 0x0CBCA907
li  t2, 0x07C08005
li  t3, 0x95E9A704
maccwri 14 ; macclu t0, t1, t2
li  t4, 0x6C3ACADD
bne t4, t0, fail
li  t0, 0x8A92AECE
li  t1, 0x04F53FF7
li  t2, 0xFC862BFC
li  t3, 0x83A529DF
maccwri 10 ; macclu t0, t1, t2
li  t4, 0x8D0622F2
bne t4, t0, fail
li  t0, 0xE213C762
li  t1, 0x666D5F5C
li  t2, 0x400471B0
li  t3, 0xD6578D61
maccwri 14 ; macclu t0, t1, t2
li  t4, 0x11CCF2A2
bne t4, t0, fail
li  t0, 0x99A8D3F4
li  t1, 0x5EE9FCDA
li  t2, 0xBF45B85F
li  t3, 0x86F4223B
maccwri 8 ; macclu t0, t1, t2
li  t4, 0x9AFC58DA
bne t4, t0, fail
li  t0, 0x56A15032
li  t1, 0xA352E5F3
li  t2, 0xFBE5C09A
li  t3, 0xF0ECC35F
maccwri 15 ; macclu t0, t1, t2
li  t4, 0xB654E460
bne t4, t0, fail
li  t0, 0x329F2B45
li  t1, 0x9D97EFCB
li  t2, 0x4221BA02
li  t3, 0x8423AF61
maccwri 8 ; macclu t0, t1, t2
li  t4, 0x333388DB
bne t4, t0, fail
li  t0, 0xFD42E7BB
li  t1, 0x6C5B3CEB
li  t2, 0x7D38B160
li  t3, 0x45D64DA1
maccwri 6 ; macclu t0, t1, t2
li  t4, 0xFD803ADB
bne t4, t0, fail
li  t0, 0xE05B12E5
li  t1, 0x389446EE
li  t2, 0xCDF02D79
li  t3, 0x7F2415AA
maccwri 15 ; macclu t0, t1, t2
li  t4, 0xC4086F63
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
