#ifndef __GENERATE_H
#define __GENERATE_H

// ============================================================================

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

// ----------------------------------------------------------------------------

#define MARKER_CODE "// "
#define MARKER_DATA "## "

#if ( MPISE_XLEN == 32 )
typedef uint32_t reg_t; 
#define FORMAT_DEC "%d"
#define FORMAT_HEX "0x%08X"
#endif
#if ( MPISE_XLEN == 64 )
typedef uint64_t reg_t; 
#define FORMAT_DEC "%ld"
#define FORMAT_HEX "0x%016lX"
#endif

#define INSN(x,f) {        \
  switch(x) {              \
    case  0: f( 0); break; \
    case  1: f( 1); break; \
    case  2: f( 2); break; \
    case  3: f( 3); break; \
    case  4: f( 4); break; \
    case  5: f( 5); break; \
    case  6: f( 6); break; \
    case  7: f( 7); break; \
    case  8: f( 8); break; \
    case  9: f( 9); break; \
    case 10: f(10); break; \
    case 11: f(11); break; \
    case 12: f(12); break; \
    case 13: f(13); break; \
    case 14: f(14); break; \
    case 15: f(15); break; \
  }                        \
}

// ----------------------------------------------------------------------------

#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
#define EMIT_SRAIADD      printf( MARKER_CODE "sraiadd t0, t1, t2, " FORMAT_DEC "\n", imm );
#define INSN_SRAIADD(imm) asm( "sraiadd %0, %1, %2, " # imm : "=r"(rd) : "r"(rs1), "r"(rs2) ); 
#define EMIT_CACC         printf( MARKER_CODE "cacc t0, t1, t2, t3" "\n" );
#define INSN_CACC         asm( "cacc %0, %1, %2, %3" : "=r"(rd) : "r"(rs1), "r"(rs2), "r"(rs3) );
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
#define EMIT_MACCLU       printf( MARKER_CODE "csrrwi x0, 0x800, " FORMAT_DEC " ; " "macclu t0, t1, t2, t3"              "\n", imm );
#define INSN_MACCLU(imm)  asm( "csrrwi x0, 0x800, " # imm " ; " "macclu %0, %1, %2, %3"         : "=r"(rd) : "r"(rs1), "r"(rs2), "r"(rs3) ); 
#define EMIT_MACCHU       printf( MARKER_CODE "csrrwi x0, 0x800, " FORMAT_DEC " ; " "macchu t0, t1, t2, t3"              "\n", imm );
#define INSN_MACCHU(imm)  asm( "csrrwi x0, 0x800, " # imm " ; " "macchu %0, %1, %2, %3"         : "=r"(rd) : "r"(rs1), "r"(rs2), "r"(rs3) ); 
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
#define EMIT_MACCLU       printf( MARKER_CODE                                       "macclu t0, t1, t2, t3, " FORMAT_DEC "\n", imm );
#define INSN_MACCLU(imm)  asm(                                  "macclu %0, %1, %2, %3, " # imm : "=r"(rd) : "r"(rs1), "r"(rs2), "r"(rs3) ); 
#define EMIT_MACCHU       printf( MARKER_CODE                                       "macchu t0, t1, t2, t3, " FORMAT_DEC "\n", imm );
#define INSN_MACCHU(imm)  asm(                                  "macchu %0, %1, %2, %3, " # imm : "=r"(rd) : "r"(rs1), "r"(rs2), "r"(rs3) ); 
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
#define EMIT_SRAIADD      printf( MARKER_CODE "sraiadd t0, t1, t2, " FORMAT_DEC "\n", imm );
#define INSN_SRAIADD(imm) asm( "sraiadd %0, %1, %2, " # imm : "=r"(rd) : "r"(rs1), "r"(rs2) ); 
#define EMIT_CACC         printf( MARKER_CODE "cacc t0, t1, t2"     "\n" );
#define INSN_CACC         asm( "cacc %0, %1, %2"     : "+r"(rd) : "r"(rs1), "r"(rs2)           );
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
#define EMIT_MACCLU       printf( MARKER_CODE "csrrwi x0, 0x800, " FORMAT_DEC " ; " "macclu t0, t1, t2"                  "\n", imm );
#define INSN_MACCLU(imm)  asm( "csrrwi x0, 0x800, " # imm " ; " "macclu %0, %1, %2"             : "+r"(rd) : "r"(rs1), "r"(rs2)           ); 
#define EMIT_MACCHU       printf( MARKER_CODE "csrrwi x0, 0x800, " FORMAT_DEC " ; " "macchu t0, t1, t2"                  "\n", imm );
#define INSN_MACCHU(imm)  asm( "csrrwi x0, 0x800, " # imm " ; " "macchu %0, %1, %2"             : "+r"(rd) : "r"(rs1), "r"(rs2)           ); 
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
#define EMIT_MACCLU       printf( MARKER_CODE                                       "macclu t0, t1, t2, "     FORMAT_DEC "\n", imm );
#define INSN_MACCLU(imm)  asm(                                  "macclu %0, %1, %2, "     # imm : "+r"(rd) : "r"(rs1), "r"(rs2)           ); 
#define EMIT_MACCHU       printf( MARKER_CODE                                       "macchu t0, t1, t2, "     FORMAT_DEC "\n", imm );
#define INSN_MACCHU(imm)  asm(                                  "macchu %0, %1, %2, "     # imm : "+r"(rd) : "r"(rs1), "r"(rs2)           ); 
#endif
#endif

// ============================================================================

#endif
