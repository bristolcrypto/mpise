#include "ise.h"
.global test
test:
li  t0, 0xC473CD69
li  t1, 0x561ADE3F
li  t2, 0xD848D918
li  t3, 0xFCB7E453
cacc t0, t1, t2
li  t4, 0xC473CD6A
bne t4, t0, fail
li  t0, 0x52957E70
li  t1, 0xDAC91615
li  t2, 0x5982A4ED
li  t3, 0x0843F378
cacc t0, t1, t2
li  t4, 0x52957E71
bne t4, t0, fail
li  t0, 0xDFB67247
li  t1, 0x04B64562
li  t2, 0x52D81545
li  t3, 0x8C626CCC
cacc t0, t1, t2
li  t4, 0xDFB67247
bne t4, t0, fail
li  t0, 0x6481F8E9
li  t1, 0xB579B0B9
li  t2, 0xF9895851
li  t3, 0x9CDEF637
cacc t0, t1, t2
li  t4, 0x6481F8EA
bne t4, t0, fail
li  t0, 0xEA789632
li  t1, 0xE75768B0
li  t2, 0x2A7148E0
li  t3, 0x8216919E
cacc t0, t1, t2
li  t4, 0xEA789633
bne t4, t0, fail
li  t0, 0x4D62215E
li  t1, 0x44651BC6
li  t2, 0x60AEE9EF
li  t3, 0x137DEFBA
cacc t0, t1, t2
li  t4, 0x4D62215E
bne t4, t0, fail
li  t0, 0xBFF481DD
li  t1, 0x26772253
li  t2, 0xF5246707
li  t3, 0x041CA67E
cacc t0, t1, t2
li  t4, 0xBFF481DE
bne t4, t0, fail
li  t0, 0x0B9967E4
li  t1, 0x78941092
li  t2, 0xAA33189D
li  t3, 0x4DD24828
cacc t0, t1, t2
li  t4, 0x0B9967E5
bne t4, t0, fail
li  t0, 0xF751E5BE
li  t1, 0x1B68FECF
li  t2, 0xE558E0D9
li  t3, 0x9561DD27
cacc t0, t1, t2
li  t4, 0xF751E5BF
bne t4, t0, fail
li  t0, 0xE3B55757
li  t1, 0x82EEA082
li  t2, 0xAF5B3BC0
li  t3, 0x66749638
cacc t0, t1, t2
li  t4, 0xE3B55758
bne t4, t0, fail
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
