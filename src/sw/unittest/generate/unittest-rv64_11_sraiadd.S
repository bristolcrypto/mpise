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
li  t0, 0x89E79547B607C405
li  t1, 0x2F95469717460B0B
li  t2, 0x3237CED89E7D5D7B
sraiadd t0, t1, t2, 1
li  t4, 0x48B12E036684B9C8
bne t4, t0, fail
li  t0, 0xBA343AAAF97ADE00
li  t1, 0xC725595459D1DF1E
li  t2, 0xB5A214C00AD29CD8
sraiadd t0, t1, t2, 7
li  t4, 0xC6909D7DD9E78457
bne t4, t0, fail
li  t0, 0x8A53C80847211D38
li  t1, 0x127F18C8F56CC8C0
li  t2, 0x82EDFCF9DEDC671A
sraiadd t0, t1, t2, 9
li  t4, 0x12408FC7725C36F3
bne t4, t0, fail
li  t0, 0x650631BC33F4E5C7
li  t1, 0x9800BBF7BCE18255
li  t2, 0x000ABE701B240A2A
sraiadd t0, t1, t2, 14
li  t4, 0x9800BC22B6A1EEE5
bne t4, t0, fail
li  t0, 0xB9EE775870936B76
li  t1, 0x00E52FC4FF35DA0E
li  t2, 0x379667DF705262BC
sraiadd t0, t1, t2, 6
li  t4, 0x01C389647CF72398
bne t4, t0, fail
li  t0, 0x8CD675FFC956CC08
li  t1, 0xE8160AAB62437E28
li  t2, 0x206B061761E13A85
sraiadd t0, t1, t2, 9
li  t4, 0xE826402E6DF46EC5
bne t4, t0, fail
li  t0, 0x96BF7A89B201F0FA
li  t1, 0x40ECC9FBD4DF606C
li  t2, 0x10BD08EBE94FA5B9
sraiadd t0, t1, t2, 6
li  t4, 0x412FBE1F84849F02
bne t4, t0, fail
li  t0, 0xC7AC87F60168CC82
li  t1, 0x2A0215025283D7DF
li  t2, 0xA46DAB124C686A41
sraiadd t0, t1, t2, 6
li  t4, 0x2893CBAE9BB57988
bne t4, t0, fail
li  t0, 0xB251E6ACE7707FAF
li  t1, 0xCEAAFBE41573DB3D
li  t2, 0x0F50C6EFABE4EC3B
sraiadd t0, t1, t2, 5
li  t4, 0xCF25821B92D3029E
bne t4, t0, fail
li  t0, 0xEAFCCC1318546ACF
li  t1, 0x429EB7063BD9C66D
li  t2, 0x789606AB312A201A
sraiadd t0, t1, t2, 12
li  t4, 0x42A64066A68CD90F
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
