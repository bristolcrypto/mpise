// void gfp_add_isa(uint64_t *r, const uint64_t *a, const uint64_t *b);


.section .text

.global gfp_add_isa

gfp_add_isa:
  .set imm, 0
  .rept 5
  ld   t1, imm(a1)
  ld   t2, imm(a2)
  add  t0, t1, t2 
  sd   t0, imm(a0)
  .set imm, imm + 8
  .endr 
  ret
  