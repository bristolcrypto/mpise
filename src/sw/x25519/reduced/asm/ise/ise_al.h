// Copyright (C) 2021 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

// ============================================================================

#ifndef _ISE_AL_H
#define _ISE_AL_H

#include "ise.h"

.macro madd51lu Z, A, B, S
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
  macclu \Z, \A, \B, \S
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
  macclu \Z, \A, \B, \S,  2 // imm = c =  2 => radix = (w-15)+c = (64-15)+ 2 = 51
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
  macclu \Z, \A, \B
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
  macclu \Z, \A, \B,      2 // imm = c =  2 => radix = (w-15)+c = (64-15)+ 2 = 51
#endif
#endif
.endm

.macro madd51hu Z, A, B, S
#if   defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 0 )
// !destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
// !destructive && !stateless
  macchu \Z, \A, \B, \S
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
// !destructive &&  stateless
  macchu \Z, \A, \B, \S,  2 // imm = c =  2 => radix = (w-15)+c = (64-15)+ 2 = 51
#endif
#elif defined( MPISE_DESTRUCTIVE ) && ( MPISE_DESTRUCTIVE == 1 )
//  destructive
#if   defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 0 )
//  destructive && !stateless
  macchu \Z, \A, \B
#elif defined( MPISE_STATELESS   ) && ( MPISE_STATELESS   == 1 )
//  destructive &&  stateless
  macchu \Z, \A, \B,      2 // imm = c =  2 => radix = (w-15)+c = (64-15)+ 2 = 51
#endif
#endif
.endm

// ============================================================================                              

#endif 
