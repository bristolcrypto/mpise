#ifndef _ISE_H
#define _ISE_H

.macro maddlu                rd, rs1, rs2, rs3      
.insn r4 CUSTOM_3, 7,      ( 0* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro maddhu                rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 1* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                                                                           


#endif
