import argparse, matplotlib, matplotlib.pyplot as plt, numpy as np, sys

plt.rcParams[ 'text.usetex' ] = True

# =============================================================================

def parse() :
  data = dict()
  
  for line in sys.stdin.readlines() :
    line = [ t.strip() for t in line.split( ',' ) ]
  
    conf_radix       = int( line[  0 ] )
    conf_type        = str( line[  1 ] )
    conf_xlen        = int( line[  2 ] )
    conf_destructive = int( line[  3 ] )
    conf_stateless   = int( line[  4 ] )
    
    operand_limbs    = int( line[  5 ] )
    operand_bits     = int( line[  6 ] )

    trials_total     = int( line[  7 ] )
    trials_valid     = int( line[  8 ] )
  
    rdtsc_min        = int( line[  9 ] )
    rdtsc_max        = int( line[ 10 ] )
    rdtsc_avr        = int( line[ 11 ] )

    if ( conf_type != str( argv.type ) ) :
      continue
    if ( conf_xlen != int( argv.xlen ) ) :
      continue
  
    if ( not conf_radix in data ) :
      data[ conf_radix ] = list()
  
    data[ conf_radix ].append( ( operand_limbs, operand_bits, rdtsc_min, rdtsc_max, rdtsc_avr ) )

  return data

def plot( data ) :
  fig, ax = plt.subplots() ; colors = matplotlib.color_sequences[ 'tab20' ]

  fig.set_figheight( argv.output_ht )
  fig.set_figwidth ( argv.output_wd )

  if ( ( argv.scale_x_max != None ) and ( argv.scale_x_step != None ) ) :
    xticks = np.arange( 0, argv.scale_x_max, argv.scale_x_step )
    xlabels = [ '${0:d}$'.format( x ) for x in xticks ]
    ax.set_xlim( 0, argv.scale_x_max )
    ax.set_xticks( xticks, labels = xlabels )

  if ( ( argv.scale_y_max != None ) and ( argv.scale_y_step != None ) ) :
    yticks = np.arange( 0, argv.scale_y_max, argv.scale_y_step )
    ylabels = [ '${0:d}$'.format( y ) for y in yticks ]
    ax.set_ylim( 0, argv.scale_y_max )
    ax.set_yticks( yticks, labels = ylabels )
  
  for ( i, radix ) in enumerate( sorted( data.keys() ) ) :
    xs     = [ x            for ( _, x, _, _, _ ) in data[ radix ] ]
    ys     = [ y            for ( _, _, _, _, y ) in data[ radix ] ]
  
    es_min = [ abs( y - e ) for ( _, _, e, _, y ) in data[ radix ] ]
    es_max = [ abs( y - e ) for ( _, _, _, e, y ) in data[ radix ] ]
  
    es     = [ es_min, es_max ]
  
    c = colors[ i ] ; m = '*' if ( radix == 64 ) else 'x'

    ax.plot( xs, ys, c = c, linestyle = 'dotted', marker = m, label = 'Radix-$2^{{{0:d}}}$'.format( radix ) )

    if ( argv.error_bars ) :
      plt.errorbar( xs, ys, yerr = es, ecolor = c, elinewidth = 1, capsize = 2, fmt = 'none' )
  
  ax.set( xlabel = 'Operand length (bits)', ylabel = 'Cycles', title = r'$\mbox{{type}} = \mbox{{{0:s}}}$, $\mbox{{\tt xlen}} = {1:s}$, $\mbox{{\tt version}} = {2:s}$'.format( argv.type.upper(), argv.xlen, argv.version ) )
  ax.legend( loc = 'upper left' ) ; ax.grid( True )
  
# -----------------------------------------------------------------------------

if ( __name__ == '__main__' ) :
  parser = argparse.ArgumentParser( add_help = False )

  parser.add_argument( '--type',         action = 'store', choices = [ 'isa', 'ise' ] )
  parser.add_argument( '--xlen',         action = 'store', choices = [  '32',  '64' ] )
  parser.add_argument( '--version',      action = 'store', choices = [ 'simple', 'hybrid' ] )

  parser.add_argument( '--error-bars',   action = 'store_true' )

  parser.add_argument( '--scale-x-max',  action = 'store', type = int, default = None )
  parser.add_argument( '--scale-x-step', action = 'store', type = int, default = None )
  parser.add_argument( '--scale-y-max',  action = 'store', type = int, default = None )
  parser.add_argument( '--scale-y-step', action = 'store', type = int, default = None )

  parser.add_argument( '--output-ht',    action = 'store', type = int, default =   10 )
  parser.add_argument( '--output-wd',    action = 'store', type = int, default =   12 )

  parser.add_argument( '--output',       action = 'store', type = str, default = None )

  argv = parser.parse_args()

  plot( parse() )

  plt.savefig( argv.output, transparent = True, bbox_inches = 'tight', pad_inches = 0.1 )

# =============================================================================
