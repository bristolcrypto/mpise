// void gfp_sub_ise(uint64_t *r, const uint64_t *a, const uint64_t *b);
// radix-2^64


#include "ise.h"


.section .text

.global test_maddlu
test_maddlu:
    maddlu a0, a0, a1, a2
    ret
  
.global test_maddhu
test_maddhu:
    maddhu a0, a0, a1, a2
    ret

.global test_maddu
test_maddu:
    ld     t1, 0(a2)
    maddlu t0, a0, a1, t1
    sltu   t1, t0, t1
    maddhu t1, a0, a1, t1
    sd     t1, 0(a2)
    mv     a0, t0

    ret 

