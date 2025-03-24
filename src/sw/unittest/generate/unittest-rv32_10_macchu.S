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
li  t0, 0xCF599B1B
li  t1, 0x1DF0055E
li  t2, 0xD73B6969
li  t3, 0x39259959
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x3407B7B6
bne t4, t0, fail
li  t0, 0x87F4296D
li  t1, 0xE30B8322
li  t2, 0x780693FF
li  t3, 0xC4DA059C
maccwri 11 ; macchu t0, t1, t2
li  t4, 0x2F27D959
bne t4, t0, fail
li  t0, 0x9BBA50B3
li  t1, 0xE6ABF1DC
li  t2, 0xACA74BF6
li  t3, 0xC236BEC4
maccwri 7 ; macchu t0, t1, t2
li  t4, 0x2DFF6D52
bne t4, t0, fail
li  t0, 0xACBDE047
li  t1, 0x1060C958
li  t2, 0x342C17EC
li  t3, 0x04EBD484
maccwri 1 ; macchu t0, t1, t2
li  t4, 0x4B81F1E3
bne t4, t0, fail
li  t0, 0x40D179A1
li  t1, 0xDA61018B
li  t2, 0xE4754856
li  t3, 0xAB363DEE
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x4C5B3F49
bne t4, t0, fail
li  t0, 0x694D9F1D
li  t1, 0xD8A7858E
li  t2, 0x3135737C
li  t3, 0x7D39C038
maccwri 3 ; macchu t0, t1, t2
li  t4, 0xBE1D4F85
bne t4, t0, fail
li  t0, 0x22D196DD
li  t1, 0x42C50EB5
li  t2, 0x209BE735
li  t3, 0xB2ECCF37
maccwri 0 ; macchu t0, t1, t2
li  t4, 0xC88BAC31
bne t4, t0, fail
li  t0, 0x4555D013
li  t1, 0xCA29778C
li  t2, 0xBD344647
li  t3, 0xF736EA92
maccwri 10 ; macchu t0, t1, t2
li  t4, 0xF29275D4
bne t4, t0, fail
li  t0, 0xA847BD7E
li  t1, 0x1AC04588
li  t2, 0x9A4D21D2
li  t3, 0xAA5ED567
maccwri 14 ; macchu t0, t1, t2
li  t4, 0xC8872FE0
bne t4, t0, fail
li  t0, 0x729A6A14
li  t1, 0x98190A45
li  t2, 0xE9451214
li  t3, 0x05D765C2
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x9CF9B96C
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
