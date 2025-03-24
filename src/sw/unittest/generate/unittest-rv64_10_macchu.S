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
li  t0, 0x37CC84CFC5B0A7C7
li  t1, 0x15BFCEB99A299AB2
li  t2, 0xF061E7BBB133565F
li  t3, 0x3C039891D26E16C4
maccwri 10 ; macchu t0, t1, t2
li  t4, 0xC550EA3B176CC65C
bne t4, t0, fail
li  t0, 0x3C8AA43998652D83
li  t1, 0xC2F9DFB17B2C91C2
li  t2, 0x6F21332EE0FD9703
li  t3, 0xF2A96ADCF64F8BE0
maccwri 10 ; macchu t0, t1, t2
li  t4, 0xD0FECA225BD64FA1
bne t4, t0, fail
li  t0, 0xB26F1B10457DEC71
li  t1, 0x3856640A5B028613
li  t2, 0xBF50527CFB5511BA
li  t3, 0xE1C99D261DE35CC7
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x5AD7A238EED80315
bne t4, t0, fail
li  t0, 0x3519BE42572AF90C
li  t1, 0x40896C3B97E1F0D2
li  t2, 0x35B0A273432A3BBB
li  t3, 0x94DD90F853CF8196
maccwri 14 ; macchu t0, t1, t2
li  t4, 0x502BB3EFE04F410E
bne t4, t0, fail
li  t0, 0x25A4030707BAAF08
li  t1, 0xD8200A37A48EC1FC
li  t2, 0xDEAEF722E099FAAD
li  t3, 0x3C0954649C7F650F
maccwri 6 ; macchu t0, t1, t2
li  t4, 0x24A29223892AF340
bne t4, t0, fail
li  t0, 0xB00E13E9845011ED
li  t1, 0xB96019FE5238955D
li  t2, 0x030A1EABA7AA8FE6
li  t3, 0x6565ACDD841D3B34
maccwri 12 ; macchu t0, t1, t2
li  t4, 0xC1A9B60DF8B1FD83
bne t4, t0, fail
li  t0, 0x049D86C23ABA74EE
li  t1, 0x56D866984357716A
li  t2, 0x1153B70306D6F83C
li  t3, 0x51D153CD7CB00DA0
maccwri 2 ; macchu t0, t1, t2
li  t4, 0x1D3F69C350A4A2BB
bne t4, t0, fail
li  t0, 0x6AC6D47771AF7895
li  t1, 0xF811DC8E133AD2D0
li  t2, 0x3A7413DE6AB3748C
li  t3, 0x8630C1ED11B58912
maccwri 15 ; macchu t0, t1, t2
li  t4, 0x38A48750FAFD23CC
bne t4, t0, fail
li  t0, 0x68887B62011FC671
li  t1, 0xE1CF801E5C703E8E
li  t2, 0xCC2C47D580C676E2
li  t3, 0x3AB31E221EC0DCE0
maccwri 13 ; macchu t0, t1, t2
li  t4, 0x38EA1FDE5BB86C3D
bne t4, t0, fail
li  t0, 0x4826B3FFA32D6BAE
li  t1, 0xFCAE4AFF2A2A16A2
li  t2, 0x439B08D696E12116
li  t3, 0x02F37591B1515E3D
maccwri 7 ; macchu t0, t1, t2
li  t4, 0x02CA957121B93BF3
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
