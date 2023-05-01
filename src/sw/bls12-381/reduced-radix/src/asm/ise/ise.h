#ifndef _ISE_H
#define _ISE_H

.macro madd55lu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 2* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro madd55hu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 3* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro sraiadd               rd, rs1, rs2, imm            
.insn r  CUSTOM_1, 7, \imm+( 1*64), \rd, \rs1, \rs2       
.endm                                                 

#endif 
