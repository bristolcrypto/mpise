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
li  t0, 0xB08D2D1E2C453672
li  t1, 0xC1AF38B6EDDF9631
li  t2, 0xF1168B3DDBE1C8D1
sraiadd t0, t1, t2, 7
li  t4, 0xC19165CD699759C2
bne t4, t0, fail
li  t0, 0xBC2458942BA68583
li  t1, 0x611AAD87F5F46449
li  t2, 0x35C49B90810D5A98
sraiadd t0, t1, t2, 10
li  t4, 0x61281EAEDA14A79F
bne t4, t0, fail
li  t0, 0x3B70D88765832C7B
li  t1, 0x725088150D57121D
li  t2, 0x6A7ACE5B335DF8C1
sraiadd t0, t1, t2, 1
li  t4, 0xA78DEF42A7060E7D
bne t4, t0, fail
li  t0, 0x01ED42E49A96D852
li  t1, 0x3050141A67487EA6
li  t2, 0xD3C7180F201D4B17
sraiadd t0, t1, t2, 4
li  t4, 0x2D8C859B594A5357
bne t4, t0, fail
li  t0, 0x09C90053CAE41E40
li  t1, 0x25467E8634D38601
li  t2, 0x801C896AB0FFA067
sraiadd t0, t1, t2, 4
li  t4, 0x1D48471CDFE38007
bne t4, t0, fail
li  t0, 0xDE8098D1F88229E3
li  t1, 0xFF5F4894CA946A5B
li  t2, 0x415EEF06A0C8D653
sraiadd t0, t1, t2, 6
li  t4, 0x0064C450E5178DB4
bne t4, t0, fail
li  t0, 0x0C1CD005FDACC769
li  t1, 0x8F2C93D06F96068B
li  t2, 0xA67FB0F54E693A78
sraiadd t0, t1, t2, 10
li  t4, 0x8F1633BCACE9A0D9
bne t4, t0, fail
li  t0, 0x278542BAE1FFD79A
li  t1, 0x236D4EE72B1B03FF
li  t2, 0x057B61FF8066A9AA
sraiadd t0, t1, t2, 2
li  t4, 0x24CC27670B34AE69
bne t4, t0, fail
li  t0, 0x2C64B5EDC868DB4F
li  t1, 0xB9F99B4456307FBB
li  t2, 0x9189D34507FC0492
sraiadd t0, t1, t2, 6
li  t4, 0xB83FC2916A506FCD
bne t4, t0, fail
li  t0, 0xC799618E04990B60
li  t1, 0x9F7630AB3AA21DFD
li  t2, 0x63B4037983BB5BC4
sraiadd t0, t1, t2, 3
li  t4, 0xABECB11A6B198975
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
