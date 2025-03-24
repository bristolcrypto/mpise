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
li  t0, 0x73AFF11ADC685E39
li  t1, 0x2A311E5ECD6DB81F
li  t2, 0xC3B438105885B586
li  t3, 0xBCB31F157895A06E
maccwri 13 ; macclu t0, t1, t2, t3
li  t4, 0xD4AEC72EE34CEBA8
bne t4, t0, fail
li  t0, 0x001003DECD24E184
li  t1, 0x963EB462830EEF44
li  t2, 0x225F06678060079D
li  t3, 0x4C0F40E78A39ADFC
maccwri 3 ; macclu t0, t1, t2, t3
li  t4, 0x4C150C7F0C6D46B0
bne t4, t0, fail
li  t0, 0x0ACFD0C762753377
li  t1, 0xFDB501FE92645613
li  t2, 0x8FBA8635259CDEAC
li  t3, 0xAEB067DC2AB5989B
maccwri 11 ; macclu t0, t1, t2, t3
li  t4, 0xB8F3FB5DBB57E75F
bne t4, t0, fail
li  t0, 0x4FE7FE69340E37D8
li  t1, 0x20C44BF0575064F8
li  t2, 0x80298F1A7BBB228C
li  t3, 0x55567BD9EE77F3F5
maccwri 9 ; macclu t0, t1, t2, t3
li  t4, 0x5792204F45001B95
bne t4, t0, fail
li  t0, 0x3220AD8BEBD4BD4E
li  t1, 0xE996713BFA224A83
li  t2, 0x9667F4C24B83B9AD
li  t3, 0x91263030C80B7754
maccwri 6 ; macclu t0, t1, t2, t3
li  t4, 0x91546C221B197CDB
bne t4, t0, fail
li  t0, 0x1FC4E3BA40324865
li  t1, 0xF197C35B0996AC58
li  t2, 0x2A82DECA4E0304B8
li  t3, 0xFFF36BC8E63F180C
maccwri 15 ; macclu t0, t1, t2, t3
li  t4, 0x3A1A9414FA44574C
bne t4, t0, fail
li  t0, 0xCC5A80EDA23AD349
li  t1, 0x7437D5EBE1856108
li  t2, 0x9FA2FEB0ADBE7AA9
li  t3, 0x10FEF00E301071C1
maccwri 12 ; macclu t0, t1, t2, t3
li  t4, 0x134EBB500D4B5009
bne t4, t0, fail
li  t0, 0x4DA86D68C292549B
li  t1, 0xE6F738628318A693
li  t2, 0x282DF36C084797A2
li  t3, 0xCEE95C207FEFDA8A
maccwri 6 ; macclu t0, t1, t2, t3
li  t4, 0xCF6315D9CA8EF890
bne t4, t0, fail
li  t0, 0x5E3771FF50B54803
li  t1, 0x61F82C6A0712B3AE
li  t2, 0x0952868EFB9F3B11
li  t3, 0x5C04B0015154160A
maccwri 12 ; macclu t0, t1, t2, t3
li  t4, 0x5CAE8BFA4C0D1E98
bne t4, t0, fail
li  t0, 0xEF06E4F708E66B9F
li  t1, 0x25AC77C73CD04FDF
li  t2, 0xC28E6C54BE3D23C3
li  t3, 0xBD90D4C70DA41ECB
maccwri 14 ; macclu t0, t1, t2, t3
li  t4, 0x0FAAB0F1655F72A8
bne t4, t0, fail
#ifdef PLATFORM_SPIKE
pass: li a0, 1 ; ret
fail: li a0, 0 ; ret
#endif
