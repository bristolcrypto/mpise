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
li  t0, 0x5F3A94E3AD103DB1
li  t1, 0xFE1393DDEBCCE4BA
li  t2, 0xFE20E83EBAB22AC1
li  t3, 0x6497755E22C4E8B7
maccwri 14 ; macchu t0, t1, t2, t3
li  t4, 0x5D07A0AF7A3E67A8
bne t4, t0, fail
li  t0, 0x7E8728E8AAE40254
li  t1, 0xD32AAADC04D5DD20
li  t2, 0xE68761D48AB21A43
li  t3, 0xCB4A458E97F31972
maccwri 6 ; macchu t0, t1, t2, t3
li  t4, 0x1B4DAE144AE0EE3F
bne t4, t0, fail
li  t0, 0xE014C4B3A4A67367
li  t1, 0xAF71F6CE515D05C9
li  t2, 0xE3A17CC46F4628C1
li  t3, 0x3C5FCA3F3C820813
maccwri 5 ; macchu t0, t1, t2, t3
li  t4, 0x3F47E63314B27909
bne t4, t0, fail
li  t0, 0x00ED75C7E68CC27F
li  t1, 0xA27724B5DFBC2510
li  t2, 0xBD9F4C12C06BC859
li  t3, 0x6C847B33EAEACA73
maccwri 4 ; macchu t0, t1, t2, t3
li  t4, 0x24F785F82C82084B
bne t4, t0, fail
li  t0, 0xC7F243E12D482A76
li  t1, 0x10ADA203028D52F3
li  t2, 0x69F3F80174084E42
li  t3, 0x9C0C53073FED4B21
maccwri 12 ; macchu t0, t1, t2, t3
li  t4, 0xD3453669D0A687D8
bne t4, t0, fail
li  t0, 0x187EE7DF4FE93058
li  t1, 0x98C42A08266A949C
li  t2, 0xE054CDC10835C3F9
li  t3, 0x1A37096D128E4CCA
maccwri 11 ; macchu t0, t1, t2, t3
li  t4, 0x781B08403E52F952
bne t4, t0, fail
li  t0, 0x8E69B8EF18ACE674
li  t1, 0x44FDA120C67342BD
li  t2, 0x959F77F32FFDE580
li  t3, 0x3405DDFF66ECF7C3
maccwri 3 ; macchu t0, t1, t2, t3
li  t4, 0x5D9007667F1B085C
bne t4, t0, fail
li  t0, 0x4979621E185A7744
li  t1, 0x5704F610B499DA6D
li  t2, 0xF0C3BDFEA156DD33
li  t3, 0x8FAC641BE87FF842
maccwri 2 ; macchu t0, t1, t2, t3
li  t4, 0x75ADEE0AE62F7C73
bne t4, t0, fail
li  t0, 0x0E7419C8EDAB61ED
li  t1, 0x95CB48D06A57DA7A
li  t2, 0x5B21E93ADE59F095
li  t3, 0xF5E970A7F3C54F91
maccwri 8 ; macchu t0, t1, t2, t3
li  t4, 0x9F76B82000CA1A43
bne t4, t0, fail
li  t0, 0x993DA5D173039BDC
li  t1, 0x70406CB6E887BB41
li  t2, 0x6B0CEC59FF286C2A
li  t3, 0x2A4EC2C1638A39E6
maccwri 15 ; macchu t0, t1, t2, t3
li  t4, 0x2EF098186643F15D
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
