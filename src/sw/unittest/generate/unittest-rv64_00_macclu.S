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
li  t0, 0xFB1158370E6797B9
li  t1, 0xE572EE117E8D2BE3
li  t2, 0x06B430A91D3990C2
li  t3, 0xC04082F8D226BC39
maccwri 2 ; macclu t0, t1, t2, t3
li  t4, 0xC04677AC9E5CAE3F
bne t4, t0, fail
li  t0, 0xCDB7A27F4E421C66
li  t1, 0x24AC2A948D17634E
li  t2, 0xD2FE8D154465042F
li  t3, 0xD98BDF43E68192E3
maccwri 3 ; macclu t0, t1, t2, t3
li  t4, 0xD998FEBF11200635
bne t4, t0, fail
li  t0, 0x3E1EEB7F26BB8E51
li  t1, 0x5F0773263F916BBF
li  t2, 0xD003F854BAE0A4B8
li  t3, 0x523D5236315128EF
maccwri 3 ; macclu t0, t1, t2, t3
li  t4, 0x524940A017FCF637
bne t4, t0, fail
li  t0, 0xD757C713665FB81A
li  t1, 0x38868DF0098179CB
li  t2, 0x187080900F2C4B00
li  t3, 0x7DFBBD3E60E07833
maccwri 1 ; macclu t0, t1, t2, t3
li  t4, 0x7DFF4A9B2372F133
bne t4, t0, fail
li  t0, 0xB766CB59CA67E510
li  t1, 0x90CDD52FBFF48A96
li  t2, 0xAB6D0372B5A12C2C
li  t3, 0x874562F128EB64DF
maccwri 5 ; macclu t0, t1, t2, t3
li  t4, 0x876D53B7651AFEA7
bne t4, t0, fail
li  t0, 0x6CFC22CC47243CC8
li  t1, 0xC60F71207C1A35A9
li  t2, 0x126DA8C7196F793C
li  t3, 0x0CDC94541E40B5D9
maccwri 1 ; macclu t0, t1, t2, t3
li  t4, 0x0CDF6F935D092A75
bne t4, t0, fail
li  t0, 0x0A4C55FF9468CEF8
li  t1, 0x3095A4B1D066D98E
li  t2, 0xB265929DDFF03EF4
li  t3, 0xA87237BDA249C07D
maccwri 7 ; macclu t0, t1, t2, t3
li  t4, 0xA95FA1B5D4217FD5
bne t4, t0, fail
li  t0, 0x06ED24EF9902491A
li  t1, 0x46F89229FB1378B2
li  t2, 0xAA14CEBF659E6F60
li  t3, 0xAAFCCA75CDE7D9DA
maccwri 12 ; macclu t0, t1, t2, t3
li  t4, 0xB619BB821E664A9A
bne t4, t0, fail
li  t0, 0x6006689660C480E9
li  t1, 0xFE3EBF8B6984C711
li  t2, 0xC59B3593D2BDCB64
li  t3, 0xA226CD22C629CF8D
maccwri 13 ; macclu t0, t1, t2, t3
li  t4, 0xABC8D25A316F0D31
bne t4, t0, fail
li  t0, 0x5E69D6B24C62FEEF
li  t1, 0xBFAD0DE264E19F7D
li  t2, 0x114BCE38E8CF4852
li  t3, 0xBF1750998265ED9F
maccwri 1 ; macclu t0, t1, t2, t3
li  t4, 0xBF19F3CE85992BA9
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
#ifdef PLATFORM_CVA6
                 ret
#endif
