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
li  t0, 0xB28741153D185098
li  t1, 0x58674BF8DB54994C
li  t2, 0x8880BE8DB4A70751
li  t3, 0x0097A97D11AF62E5
maccwri 7 ; macchu t0, t1, t2, t3
li  t4, 0x23ED7947AE254DD7
bne t4, t0, fail
li  t0, 0x11ED0EED13605650
li  t1, 0x42B576AA70BC6212
li  t2, 0x863E3B1353B99A19
li  t3, 0x71D3FA9509A83022
maccwri 13 ; macchu t0, t1, t2, t3
li  t4, 0xFDC0C8684958F98C
bne t4, t0, fail
li  t0, 0x508252009C02A131
li  t1, 0xFB0DB51EAAE39582
li  t2, 0xCD2EB3AEBBE14B51
li  t3, 0x2A9C0EFE5416694C
maccwri 13 ; macchu t0, t1, t2, t3
li  t4, 0x4F7B29D6825839F1
bne t4, t0, fail
li  t0, 0xC3BB44085B8A52CE
li  t1, 0xFB927D35362DA7DC
li  t2, 0x38B25D5CFAF97EA6
li  t3, 0x5B0A57749A489DA4
maccwri 14 ; macchu t0, t1, t2, t3
li  t4, 0xCA78FD712D830E9B
bne t4, t0, fail
li  t0, 0x1BE4F7B66A63750D
li  t1, 0xE4CD07C710CBDB6C
li  t2, 0x436F144F287277DD
li  t3, 0x7941279F8081C458
maccwri 11 ; macchu t0, t1, t2, t3
li  t4, 0x3D9029034C50A7A6
bne t4, t0, fail
li  t0, 0xB7AD12C1BEB1CEE0
li  t1, 0x077F69D54B008C18
li  t2, 0xCD377229E9E1B38D
li  t3, 0xA8841F98BAE3AEE6
maccwri 6 ; macchu t0, t1, t2, t3
li  t4, 0xADD30E9B45028AC7
bne t4, t0, fail
li  t0, 0xF46752E83480CA1E
li  t1, 0x2E251D20E4C84F8B
li  t2, 0x7D33DC47EAA4992B
li  t3, 0x6F6EC832D658E7FB
maccwri 14 ; macchu t0, t1, t2, t3
li  t4, 0x9C91B8D8481D8EF4
bne t4, t0, fail
li  t0, 0x021E527677117D91
li  t1, 0x38F598C189F40D8B
li  t2, 0xA1751D2367ED0D08
li  t3, 0x67E6ACC4D41CDFE7
maccwri 9 ; macchu t0, t1, t2, t3
li  t4, 0x63079FD3A21697D0
bne t4, t0, fail
li  t0, 0x83783381F380ACD0
li  t1, 0x88D8AEDB9E382A89
li  t2, 0x7248D864440B4AE8
li  t3, 0x50BE52FD47F0C0AE
maccwri 8 ; macchu t0, t1, t2, t3
li  t4, 0xDC7590B0AB4BAA03
bne t4, t0, fail
li  t0, 0xD0C9667BD64D5525
li  t1, 0x5793F293B14B5623
li  t2, 0xAEEF7A5B80A65621
li  t3, 0x256203FCA32290F4
maccwri 6 ; macchu t0, t1, t2, t3
li  t4, 0xD659BB4FD391AF7A
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
