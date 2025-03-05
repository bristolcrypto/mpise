#include "ise.h"
.global test
test:
li  t0, 0xD76C3FCF
li  t1, 0xB060F2F1
li  t2, 0x511238D5
li  t3, 0x7882E01E
macclu t0, t1, t2, 13
li  t4, 0xE32D1A54
bne t4, t0, fail
li  t0, 0x735555D4
li  t1, 0xC05D5B12
li  t2, 0xD758FF1E
li  t3, 0xB0971A24
macclu t0, t1, t2, 7
li  t4, 0x742CEFF0
bne t4, t0, fail
li  t0, 0x663A2A57
li  t1, 0x5BCC61C0
li  t2, 0x2229D804
li  t3, 0x14D317BE
macclu t0, t1, t2, 4
li  t4, 0x6645B157
bne t4, t0, fail
li  t0, 0x64EC9A67
li  t1, 0x43F14FBA
li  t2, 0x380CF664
li  t3, 0x672D3856
macclu t0, t1, t2, 2
li  t4, 0x64F47B0F
bne t4, t0, fail
li  t0, 0x5A596958
li  t1, 0x590FA8E8
li  t2, 0x1A74FC88
li  t3, 0x37CB8E45
macclu t0, t1, t2, 3
li  t4, 0x5A5F8498
bne t4, t0, fail
li  t0, 0x1E4FFEFC
li  t1, 0xCE3E56D9
li  t2, 0x2B69765B
li  t3, 0xD15F55CD
macclu t0, t1, t2, 2
li  t4, 0x1E51E41F
bne t4, t0, fail
li  t0, 0xF0D653A5
li  t1, 0xA81F85A8
li  t2, 0xF7E7582A
li  t3, 0xC0F1540C
macclu t0, t1, t2, 11
li  t4, 0xFE8C0135
bne t4, t0, fail
li  t0, 0x6BA8DA34
li  t1, 0xF53F13E6
li  t2, 0x30571622
li  t3, 0x56E4C9CD
macclu t0, t1, t2, 9
li  t4, 0x6CE942C0
bne t4, t0, fail
li  t0, 0xEB3F9CA1
li  t1, 0xEFDE4A56
li  t2, 0xD8045B7D
li  t3, 0xEE725565
macclu t0, t1, t2, 6
li  t4, 0xEB8E7A9F
bne t4, t0, fail
li  t0, 0xA42575D5
li  t1, 0x58927932
li  t2, 0x8E3CA0E7
li  t3, 0x1101B1CA
macclu t0, t1, t2, 7
li  t4, 0xA4C811F3
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
