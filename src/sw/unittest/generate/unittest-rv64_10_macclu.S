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
li  t0, 0xEFBF77F3361015DC
li  t1, 0x8108B11D32860B21
li  t2, 0xCD9B18AABD695D98
li  t3, 0x6C8F597158789FA3
maccwri 8 ; macclu t0, t1, t2
li  t4, 0xF09067BFD53AAE74
bne t4, t0, fail
li  t0, 0x4F6CDEE4A28B4EB1
li  t1, 0x37480A5A43722D52
li  t2, 0x674730B08B8DA6CE
li  t3, 0x0E8B5AA8D51124E5
maccwri 5 ; macclu t0, t1, t2
li  t4, 0x4F6E68216DF8F2AD
bne t4, t0, fail
li  t0, 0xD25B3EAB9C5A6EC6
li  t1, 0x132B2219AA9C09C1
li  t2, 0x24B21FD752F5704C
li  t3, 0x761CF02F7A0C8020
maccwri 3 ; macclu t0, t1, t2
li  t4, 0xD2676B7AAEA6C412
bne t4, t0, fail
li  t0, 0xF40024476B1535C6
li  t1, 0x5ACF89EEEBB9F7B3
li  t2, 0xCDECC420E7A14A05
li  t3, 0xA36A700460432E7B
maccwri 15 ; macclu t0, t1, t2
li  t4, 0x96CBF6ED13E3CA45
bne t4, t0, fail
li  t0, 0xE3ED703FB2A20578
li  t1, 0xFDB978185C657932
li  t2, 0x58E6107C9561B03E
li  t3, 0xF51BAFD63E34DCF1
maccwri 8 ; macclu t0, t1, t2
li  t4, 0xE4112BE0DC79BF94
bne t4, t0, fail
li  t0, 0xB49E60601D7EC25F
li  t1, 0x85DA3100D3A1F4E2
li  t2, 0xDF278FFEB7E470A8
li  t3, 0x453FC5E5FC8931B4
maccwri 14 ; macclu t0, t1, t2
li  t4, 0xDC2D5E09823256AF
bne t4, t0, fail
li  t0, 0x452615E4C3F2ED83
li  t1, 0x0CCDA6A0F3B781CF
li  t2, 0xD77274D325374584
li  t3, 0x09249415FBEC13B0
maccwri 1 ; macclu t0, t1, t2
li  t4, 0x45270E5FB307A73F
bne t4, t0, fail
li  t0, 0xD7C96FD103AB3734
li  t1, 0x54D52999DD7D1A54
li  t2, 0xB3D657FF8991FAB0
li  t3, 0x1BE8339C13D83803
maccwri 14 ; macclu t0, t1, t2
li  t4, 0x1E6C788452F758F4
bne t4, t0, fail
li  t0, 0xF377F80E2BD12550
li  t1, 0x9170F131A7AFE4B1
li  t2, 0x40257C01D14DA543
li  t3, 0xD02F0C75795EB6FB
maccwri 10 ; macclu t0, t1, t2
li  t4, 0xF55CC36EB77D14A3
bne t4, t0, fail
li  t0, 0xECF423AE3A72E547
li  t1, 0x0A5272E7F357EFA6
li  t2, 0x512BDDCDEB1C2B0C
li  t3, 0x7A36681DDCE70B58
maccwri 12 ; macclu t0, t1, t2
li  t4, 0xEE0E08F6FFFB030F
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
