// Copyright (C) 2021 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

// ============================================================================

#ifndef _ISE_H
#define _ISE_H


.macro sraiadd  rd, rs1, rs2, imm
.insn r  CUSTOM_0, 1, ( \imm & 0x7F ) << 0, \rd, \rs1, \rs2
.endm 
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive                                                                                                                                                                                                   
.macro cacc rd, rs1, rs2, rs3             
.insn r4 CUSTOM_0, 0, 0, \rd, \rs1, \rs2, \rs3 
.endm
.macro maccfrlu rd, rs1, rs2, rs3            
.insn r4 CUSTOM_1, 0, 0, \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro maccfrhu rd, rs1, rs2, rs3            
.insn r4 CUSTOM_1, 1, 0, \rd, \rs1, \rs2, \rs3 
.endm    
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless                                                                                                                                                                                     
.macro maccrrlu rd, rs1, rs2, rs3
.insn r4 CUSTOM_2, 0, 0, \rd, \rs1, \rs2, \rs3
.endm
.macro maccrrhu rd, rs1, rs2, rs3
.insn r4 CUSTOM_2, 1, 0  \rd, \rs1, \rs2, \rs3
.endm
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless                                                                                                                                                                                     
.macro maccrrlu rd, rs1, rs2, rs3, imm
.insn r4 CUSTOM_2, 0 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2, \rs3
.endm
.macro maccrrhu rd, rs1, rs2, rs3, imm
.insn r4 CUSTOM_2, 1 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2, \rs3
.endm
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive                                                                                                                                                                                                   
.macro cacc rd, rs1, rs2
.insn r  CUSTOM_0, 0, 0, \rd, \rs1, \rs2
.endm
.macro maccfrlu rd, rs1, rs2, rs3            
.insn r  CUSTOM_1, 0, 0, \rd, \rs1, \rs2
.endm
.macro maccfrhu rd, rs1, rs2, rs3            
.insn r  CUSTOM_1, 1, 0, \rd, \rs1, \rs2
.endm
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless                                                                                                                                                                                     
.macro maccrrlu rd, rs1, rs2
.insn r  CUSTOM_2, 0, 0, \rd, \rs1, \rs2
.endm
.macro maccrrhu rd, rs1, rs2
.insn r  CUSTOM_2, 1, 0, \rd, \rs1, \rs2
.endm
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
.macro maccrrlu rd, rs1, rs2, imm
.insn r  CUSTOM_2, 0 | ( ( \imm & 0x003 ) << 1 ), ( \imm & 0x1FC ) >> 2, \rd, \rs1, \rs2
.endm
.macro maccrrhu rd, rs1, rs2, imm
.insn r  CUSTOM_2, 1 | ( ( \imm & 0x003 ) << 1 ), ( \imm & 0x1FC ) >> 2, \rd, \rs1, \rs2
.endm
#endif
#endif


// macros to use different custom instructions 

.macro madd51lu Z, A, B, S
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
  maccrrlu \Z, \A, \B, \S, 3    // imm = 3 = 51 - 48
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
  maccrrlu \Z, \A, \B, 51
#endif
#endif
.endm

.macro madd51hu Z, A, B, S
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
  maccrrhu \Z, \A, \B, \S, 3    // imm = 3 = 51 - 48
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
  maccrrhu \Z, \A, \B, 51    
#endif
#endif
.endm

// ============================================================================                              

#endif 
