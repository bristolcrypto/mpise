#include "ise.h"
.global test
test:
li  t0, 0x3D9B2F48
li  t1, 0xF126C0C7
li  t2, 0x708A11AB
li  t3, 0x4E7FEC1F
macclu t0, t1, t2, t3, 12
li  t4, 0x5175E80C
bne t4, t0, fail
li  t0, 0xEC3CBB47
li  t1, 0x160A415B
li  t2, 0x463DD8A5
li  t3, 0xAF18B02D
macclu t0, t1, t2, t3, 0
li  t4, 0xAF1A97D4
bne t4, t0, fail
li  t0, 0x175A9A08
li  t1, 0x1C625DDA
li  t2, 0x483B3C96
li  t3, 0x79F603AD
macclu t0, t1, t2, t3, 6
li  t4, 0x7A561969
bne t4, t0, fail
li  t0, 0xDA51CC47
li  t1, 0x22DCD6F6
li  t2, 0xF2A5A51D
li  t3, 0xFC24E523
macclu t0, t1, t2, t3, 1
li  t4, 0xFC27CD01
bne t4, t0, fail
li  t0, 0x43B019F5
li  t1, 0x7611C84F
li  t2, 0x7B7881EC
li  t3, 0x4BF27F94
macclu t0, t1, t2, t3, 2
li  t4, 0x4BF6F768
bne t4, t0, fail
li  t0, 0x68568F93
li  t1, 0xADC60D3C
li  t2, 0xC786FA9F
li  t3, 0x430FAF06
macclu t0, t1, t2, t3, 9
li  t4, 0x43667F4A
bne t4, t0, fail
li  t0, 0x1A1A9FA4
li  t1, 0x054A28A0
li  t2, 0x7C376EA3
li  t3, 0x80BECD2C
macclu t0, t1, t2, t3, 1
li  t4, 0x80BF6B0C
bne t4, t0, fail
li  t0, 0xC631F42C
li  t1, 0xF89B921E
li  t2, 0x880C903D
li  t3, 0x0313FB59
macclu t0, t1, t2, t3, 2
li  t4, 0x0316AC7F
bne t4, t0, fail
li  t0, 0x736B8DBF
li  t1, 0x6C0392D6
li  t2, 0x20BF215D
li  t3, 0x909D9F7F
macclu t0, t1, t2, t3, 9
li  t4, 0x91818D3D
bne t4, t0, fail
li  t0, 0x10DD9EEA
li  t1, 0x360D4E83
li  t2, 0x772A4234
li  t3, 0x212B176F
macclu t0, t1, t2, t3, 6
li  t4, 0x219AD00B
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
