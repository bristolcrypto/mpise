// void gfp_sub_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


.section .text 

.global gfp_sub_isa

gfp_sub_isa:
  la   a3, MODULUS_2P
  ld   t3,   0(a3)
  ld   t1,   0(a1)
  ld   t2,   0(a2)
  add  t0, t1, t3 
  sub  t0, t0, t2 
  sd   t0,   0(a0)
  ld   t3,   8(a3)
  .set imm,  8
  .rept 4
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  add  t0, t1, t3 
  sub  t0, t0, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret


.section .data 

.balign 8 

MODULUS_2P:
.dword 0xFFFFFFFFFFFDA
.dword 0xFFFFFFFFFFFFE
