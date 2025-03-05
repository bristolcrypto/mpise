#include "ise.h"
.global test
test:
li  t0, 0x40DB9E92
li  t1, 0x92F04578
li  t2, 0xE505E817
li  t3, 0x5DCE0F77
maccwri 13 ; macclu t0, t1, t2, t3
li  t4, 0x83B10D3F
bne t4, t0, fail
li  t0, 0x854AA7A5
li  t1, 0x7E201C20
li  t2, 0x836C8B1A
li  t3, 0xD509A952
maccwri 8 ; macclu t0, t1, t2, t3
li  t4, 0xD511E492
bne t4, t0, fail
li  t0, 0xF8ADE8B9
li  t1, 0xB3886C1A
li  t2, 0x93A5B094
li  t3, 0xD5B23560
maccwri 6 ; macclu t0, t1, t2, t3
li  t4, 0xD6249468
bne t4, t0, fail
li  t0, 0x3DE44947
li  t1, 0xC00AAC63
li  t2, 0x71D2D50F
li  t3, 0x183E33E2
maccwri 12 ; macclu t0, t1, t2, t3
li  t4, 0x3682ACAF
bne t4, t0, fail
li  t0, 0xF4C9D0DE
li  t1, 0x8A851678
li  t2, 0x309C2D76
li  t3, 0x5FDE1230
maccwri 11 ; macclu t0, t1, t2, t3
li  t4, 0x6F498580
bne t4, t0, fail
li  t0, 0x52FCF50C
li  t1, 0x1BB5E213
li  t2, 0x2340592C
li  t3, 0x8C4E4871
maccwri 15 ; macclu t0, t1, t2, t3
li  t4, 0xA8E9BEB5
bne t4, t0, fail
li  t0, 0x51CFEF30
li  t1, 0xE9987DA3
li  t2, 0xF9F2899F
li  t3, 0x1F8920D7
maccwri 13 ; macclu t0, t1, t2, t3
li  t4, 0x1F916414
bne t4, t0, fail
li  t0, 0x7ECDE1EF
li  t1, 0x97E72803
li  t2, 0x8AF77D6B
li  t3, 0xA658D47B
maccwri 5 ; macclu t0, t1, t2, t3
li  t4, 0xA66504BC
bne t4, t0, fail
li  t0, 0xB53AA1BD
li  t1, 0x96534440
li  t2, 0xB283C81D
li  t3, 0x90BD0E89
maccwri 11 ; macclu t0, t1, t2, t3
li  t4, 0x923DC9C9
bne t4, t0, fail
li  t0, 0xE7E0A4E9
li  t1, 0xF30E5DE7
li  t2, 0x2834D2E1
li  t3, 0x60BE5B62
maccwri 10 ; macclu t0, t1, t2, t3
li  t4, 0x64526169
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
