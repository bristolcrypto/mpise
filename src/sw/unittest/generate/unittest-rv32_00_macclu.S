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
li  t0, 0xB1E9586B
li  t1, 0x51A32FEB
li  t2, 0xE1D1128C
li  t3, 0x82D7C5AA
maccwri 6 ; macclu t0, t1, t2, t3
li  t4, 0x834F802E
bne t4, t0, fail
li  t0, 0xAF2D01A4
li  t1, 0x986EB2DF
li  t2, 0x4682F318
li  t3, 0xB0F772F3
maccwri 3 ; macclu t0, t1, t2, t3
li  t4, 0xB0FFE4DB
bne t4, t0, fail
li  t0, 0xB03A2394
li  t1, 0xBEE70712
li  t2, 0xA256635C
li  t3, 0x2B6304DA
maccwri 15 ; macclu t0, t1, t2, t3
li  t4, 0xE2318552
bne t4, t0, fail
li  t0, 0xE5ED9241
li  t1, 0xC137633A
li  t2, 0xCA1BD58B
li  t3, 0xB53883BB
maccwri 10 ; macclu t0, t1, t2, t3
li  t4, 0xB6F8A639
bne t4, t0, fail
li  t0, 0x2E2CDFA2
li  t1, 0x70113B8B
li  t2, 0x5E492B6B
li  t3, 0x151D0FB6
maccwri 5 ; macclu t0, t1, t2, t3
li  t4, 0x15344BCF
bne t4, t0, fail
li  t0, 0xD126E984
li  t1, 0x793E85A6
li  t2, 0x8EB6EFBC
li  t3, 0x45E110BC
maccwri 14 ; macclu t0, t1, t2, t3
li  t4, 0x469530A4
bne t4, t0, fail
li  t0, 0x10C3EE6E
li  t1, 0xB1C9E5A9
li  t2, 0x7D1F5D4A
li  t3, 0xEEFDDC87
maccwri 1 ; macclu t0, t1, t2, t3
li  t4, 0xEEFFA461
bne t4, t0, fail
li  t0, 0x1B8ADA16
li  t1, 0x9CEF1AA7
li  t2, 0x2706131C
li  t3, 0x51728806
maccwri 7 ; macclu t0, t1, t2, t3
li  t4, 0x517DD74A
bne t4, t0, fail
li  t0, 0x82CA3E30
li  t1, 0x1219C6F8
li  t2, 0x98234529
li  t3, 0x5574DBF0
maccwri 11 ; macclu t0, t1, t2, t3
li  t4, 0x621E91A8
bne t4, t0, fail
li  t0, 0x69FCD267
li  t1, 0x1DD4F016
li  t2, 0x2E1BAF70
li  t3, 0x8ADB67E1
maccwri 14 ; macclu t0, t1, t2, t3
li  t4, 0xEE757B81
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
