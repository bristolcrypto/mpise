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
li  t0, 0x814CA47B59C56B89
li  t1, 0xC9C0B49CE16C3729
li  t2, 0xC63C9F71B5550227
li  t3, 0x6B4C3E5F5F14CFFD
maccwri 8 ; macchu t0, t1, t2
li  t4, 0x9EB5E6777BBD4046
bne t4, t0, fail
li  t0, 0x84F8DB758AB4DCB8
li  t1, 0x6381B33FD0477BB7
li  t2, 0x9D8F2EBF8989C7C3
li  t3, 0x3AB47F6E9EA28DE0
maccwri 10 ; macchu t0, t1, t2
li  t4, 0x2CBF2D1624E01700
bne t4, t0, fail
li  t0, 0xECA0466CF85F356D
li  t1, 0xDE5F58DDFE3F1D6F
li  t2, 0x5B5559E9E47B9A3E
li  t3, 0x543596179A6AA3AE
maccwri 5 ; macchu t0, t1, t2
li  t4, 0x44C1AD5DE52A6639
bne t4, t0, fail
li  t0, 0x50D306C18A8A147C
li  t1, 0x9253E97BB51AAE0B
li  t2, 0xBC71C97C222DD397
li  t3, 0x48A63D1EFBBC233F
maccwri 1 ; macchu t0, t1, t2
li  t4, 0xFB3DF68850A43586
bne t4, t0, fail
li  t0, 0x86FEDD42D9F92D58
li  t1, 0x476CB975837B6074
li  t2, 0x9587ACDD8586AC43
li  t3, 0xE8E3EF9D848AFD26
maccwri 8 ; macchu t0, t1, t2
li  t4, 0x63101E49759AD52B
bne t4, t0, fail
li  t0, 0xFF1207906D41D8CA
li  t1, 0xFDA9F2A9E902602E
li  t2, 0xFD6B8A80AB3C869F
li  t3, 0xBC78BF97ECEEB7AC
maccwri 10 ; macchu t0, t1, t2
li  t4, 0x62828A7EE566D654
bne t4, t0, fail
li  t0, 0x9F8972363E82C734
li  t1, 0x4A07A8CC0FA31F6E
li  t2, 0x8C3AC81748611AB1
li  t3, 0x2250B139582345AD
maccwri 3 ; macchu t0, t1, t2
li  t4, 0x7287FB1AA7AF6E28
bne t4, t0, fail
li  t0, 0x2F8C264195E213A6
li  t1, 0x46B8B09B64768352
li  t2, 0xB54F010B2B22EAF5
li  t3, 0xE28CE4470AB6054C
maccwri 10 ; macchu t0, t1, t2
li  t4, 0x72592B0726B72690
bne t4, t0, fail
li  t0, 0xFDE2850B6A1CC166
li  t1, 0x2F788AB83E1A5DBE
li  t2, 0x36E4062517930FC9
li  t3, 0xA318C07F0340DF9B
maccwri 9 ; macchu t0, t1, t2
li  t4, 0x894FF592B9327E13
bne t4, t0, fail
li  t0, 0x5890CFC9E8EEB39A
li  t1, 0x47AC6F5A64D2CD4F
li  t2, 0x96FF4E1DACB1A437
li  t3, 0x903749A02F158FEB
maccwri 15 ; macchu t0, t1, t2
li  t4, 0x2A4683E0BAEDB140
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
