// Copyright (C) 2021 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

// ============================================================================
// 1. support for CSR access

#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//                 !stateless
.macro maccwri imm
// issue    CSR update
csrrwi x0, 0x801, \imm
// complete CSR update => stall to cater for CVA6 pipeline
.rept 10
nop
.endr
.endm
#endif

// ----------------------------------------------------------------------------
// 2. support for carry propagation

.macro srliadd  rd, rs1, rs2, imm
.insn r  CUSTOM_0, 0, ( \imm & 0x7F ) << 0, \rd, \rs1, \rs2
.endm 
.macro sraiadd  rd, rs1, rs2, imm
.insn r  CUSTOM_0, 1, ( \imm & 0x7F ) << 0, \rd, \rs1, \rs2
.endm 

#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
.macro cacc rd, rs1, rs2, rs3             
.insn r4 CUSTOM_0, 2, 0, \rd, \rs1, \rs2, \rs3 
.endm
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
.macro cacc rd, rs1, rs2
.insn r  CUSTOM_0, 2, 0, \rd, \rs1, \rs2
.endm
#endif

// ----------------------------------------------------------------------------
// 3. support for multiply-add

#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
.macro macclu rd, rs1, rs2, rs3
.insn r4 CUSTOM_1, 0, 0, \rd, \rs1, \rs2, \rs3
.endm
.macro macchu rd, rs1, rs2, rs3
.insn r4 CUSTOM_1, 1, 0, \rd, \rs1, \rs2, \rs3
.endm
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
.macro macclu rd, rs1, rs2, rs3, imm
.insn r4 CUSTOM_1, 0 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2, \rs3
.endm
.macro macchu rd, rs1, rs2, rs3, imm
.insn r4 CUSTOM_1, 1 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2, \rs3
.endm
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
.macro macclu rd, rs1, rs2
.insn r  CUSTOM_1, 0, 0, \rd, \rs1, \rs2
.endm
.macro macchu rd, rs1, rs2
.insn r  CUSTOM_1, 1, 0, \rd, \rs1, \rs2
.endm
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
.macro macclu rd, rs1, rs2, imm
.insn r  CUSTOM_1, 0 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2
.endm
.macro macchu rd, rs1, rs2, imm
.insn r  CUSTOM_1, 1 | ( ( \imm & 0x3 ) << 1 ), ( \imm & 0xC ) >> 2, \rd, \rs1, \rs2
.endm
#endif
#endif

// ============================================================================
