#ifndef _ISE_H
#define _ISE_H

.macro madd51lu              rd, rs1, rs2, rs3
.insn r4 CUSTOM_3, 7,      ( 0* 1), \rd, \rs1, \rs2, \rs3
.endm
.macro madd51hu              rd, rs1, rs2, rs3
.insn r4 CUSTOM_3, 7,      ( 1* 1), \rd, \rs1, \rs2, \rs3
.endm
.macro sraiadd               rd, rs1, rs2, imm
.insn r  CUSTOM_1, 7, \imm+( 1*64), \rd, \rs1, \rs2
.endm                                                         

#endif
