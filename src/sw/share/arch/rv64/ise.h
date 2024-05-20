// Copyright (C) 2021 SCARV project <info@scarv.org>
//
// Use of this source code is restricted per the MIT license, a copy of which 
// can be found at https://opensource.org/licenses/MIT (or should be included 
// as LICENSE.txt within the associated archive or repository).

// ============================================================================

// 1. support for carry propagation

// 2. support for    full-radix multiply-add

// 3. support for reduced-radix multiply-add

#if   defined( RV64_ISE_TYPE_1 )
// not destructive, not stateless

#elif defined( RV64_ISE_TYPE_2 )
//     destructive, not stateless

#elif defined( RV64_ISE_TYPE_3 )
// not destructive,     stateless

#elif defined( RV64_ISE_TYPE_4 )
//     destructive,     stateless

#else
#error "unknown ISE configuration"
#endif

// ============================================================================
