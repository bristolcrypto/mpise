#include "ise.h"
.global test
test:
li  t0, 0x4BCF0E41
li  t1, 0x386FB8D6
li  t2, 0x258A5C2C
li  t3, 0x81EBB904
maccwri 7 ; macclu t0, t1, t2
li  t4, 0x4CCBBB09
bne t4, t0, fail
li  t0, 0xDA40B9FC
li  t1, 0xAFD240BD
li  t2, 0x4E60AC36
li  t3, 0xECB2D652
maccwri 5 ; macclu t0, t1, t2
li  t4, 0xDA795DDA
bne t4, t0, fail
li  t0, 0x63378F10
li  t1, 0x92C352F6
li  t2, 0x5D518803
li  t3, 0x6CAEBE31
maccwri 3 ; macclu t0, t1, t2
li  t4, 0x633A37F2
bne t4, t0, fail
li  t0, 0xEC4BFBF8
li  t1, 0x0268349B
li  t2, 0xC1E96E57
li  t3, 0xEB122AE2
maccwri 15 ; macclu t0, t1, t2
li  t4, 0x406376A5
bne t4, t0, fail
li  t0, 0xF787CA33
li  t1, 0xB34DF2CA
li  t2, 0x8E425D27
li  t3, 0x7875E62E
maccwri 12 ; macclu t0, t1, t2
li  t4, 0xFDAF28F9
bne t4, t0, fail
li  t0, 0x6CE8EEA5
li  t1, 0x3C98BA49
li  t2, 0x9C14957A
li  t3, 0xF85CBAE0
maccwri 8 ; macclu t0, t1, t2
li  t4, 0x6DD2326F
bne t4, t0, fail
li  t0, 0x6903E403
li  t1, 0x2431C462
li  t2, 0x68B6B3A5
li  t3, 0xBE79BA28
maccwri 4 ; macclu t0, t1, t2
li  t4, 0x6913FD2D
bne t4, t0, fail
li  t0, 0x562A93DC
li  t1, 0x4EAF4CF2
li  t2, 0x5D9C6D98
li  t3, 0xA08D6F20
maccwri 12 ; macclu t0, t1, t2
li  t4, 0x5F7B4D8C
bne t4, t0, fail
li  t0, 0x6A5214E5
li  t1, 0xC654089B
li  t2, 0xC8C499F3
li  t3, 0xC29ADE30
maccwri 6 ; macclu t0, t1, t2
li  t4, 0x6A66E306
bne t4, t0, fail
li  t0, 0x4C71BAA9
li  t1, 0x71FE5198
li  t2, 0x77BD32CD
li  t3, 0x1E335E27
maccwri 14 ; macclu t0, t1, t2
li  t4, 0xA640C161
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
