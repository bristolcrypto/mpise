# Copyright (C) 2021 SCARV project <info@scarv.org>
#
# Use of this source code is restricted per the MIT license, a copy of which 
# can be found at https://opensource.org/licenses/MIT (or should be included 
# as LICENSE.txt within the associated archive or repository).

import argparse, os, subprocess

# =============================================================================

def run( args, ARCH, ALG, RADIX, TYPE, CONF ) :
  CONF  = ' '.join( [ '-D%s' % ( x ) for x in CONF ] )

  CONF += ( ' ' if ( CONF != '' ) else '' ) #+ '-DDRIVER_TRIALS_WARN="%d"' % ( args.trials_warm )
  CONF += ( ' ' if ( CONF != '' ) else '' ) #+ '-DDRIVER_TRIALS_REAL="%d"' % ( args.trials_real )

  print( '>>> ALG      = "%s"' % ( ALG      ) )
  print( '>>> RADIX    = "%s"' % ( RADIX    ) )
  print( '>>> ARCH     = "%s"' % ( ARCH     ) )
  print( '>>> TYPE     = "%s"' % ( TYPE     ) )
  print( '>>> CONF     = "%s"' % ( CONF     ) )

  env = dict()

  env[ 'REPO_HOME'    ] = os.environ[ 'REPO_HOME'    ]
  #env[ 'REPO_VERSION' ] = os.environ[ 'REPO_VERSION' ]

  env[ 'PORT'            ] = os.environ[ 'PORT'    ]
  env[ 'RISCV_ROCKET'    ] = os.environ[ 'RISCV_ROCKET'    ]
  env[ 'ROCKETCHIP_REPO' ] = os.environ[ 'ROCKETCHIP_REPO' ]

  env.update( { 'ARCH' : ARCH, 'ALG' : ALG, 'RADIX' : RADIX, 'TYPE' : TYPE, 'FPGA_SWCONF' : CONF } )

  subprocess.run( [ 'make', os.path.expandvars( '--directory=${REPO_HOME}/src/hw' ), 'fpga-swclean', 'fpga-run' ], env = env )

  print( '<<<'                                )

def program_fpga( args, ARCH='rv64', ALG='x25519', RADIX='full' ) :
  print( '>>> ARCH = "%s", ALG = "%s", RADIX = "%s" ' % ( ARCH, ALG, RADIX ) )
  print( '>>> Program FPGA ...')

  env = dict()
  env[ 'PATH'            ] = os.environ[ 'PATH'            ]
  env[ 'HOME'            ] = os.environ[ 'HOME'            ]
  env[ 'REPO_HOME'       ] = os.environ[ 'REPO_HOME'       ]
  env[ 'RISCV_ROCKET'    ] = os.environ[ 'RISCV_ROCKET'    ]
  env[ 'ROCKETCHIP_REPO' ] = os.environ[ 'ROCKETCHIP_REPO' ]

  env.update( { 'ALG' : ALG, 'ARCH' : ARCH, 'RADIX' : RADIX } )
  subprocess.run( [ 'make', '--quiet', os.path.expandvars( '--directory=${REPO_HOME}/src/hw' ), 'program-fpga' ], env = env, stdout=subprocess.DEVNULL)
  print( '>>> Done.')
# -----------------------------------------------------------------------------

def main( rv32, rv64 ) :
  parser = argparse.ArgumentParser()

  parser.add_argument( '--rv32',        dest = 'rv32',        action = 'store_true',        default = False )
  parser.add_argument( '--rv64',        dest = 'rv64',        action = 'store_true',        default = False )

  parser.add_argument( '--prog',        dest = 'prog',        action = 'store_true',        default = False )

  #parser.add_argument( '--trials-warm', dest = 'trials_warm', action = 'store', type = int, default = 10  )
  #parser.add_argument( '--trials-real', dest = 'trials_real', action = 'store', type = int, default = 50  )

  args = parser.parse_args()

  if ( args.rv32 ) :
    rv32( args )
  if ( args.rv64 ) :
    rv64( args )

# =============================================================================
