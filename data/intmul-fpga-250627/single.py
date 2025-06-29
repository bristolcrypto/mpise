# ==============================================================================
#                 Detailed Log Analyzer with Plotting
# ==============================================================================
# This script reuses calculations.py and utils.py to analyze a single
# intmul log file, print a detailed report, and generate plots.
#
# Dependencies:
#   - numpy, matplotlib, colorama
#
# To install dependencies:
#   pip install numpy matplotlib colorama
#
# How to Run:
#   python single.py <path_to_your_intmul_logfile.txt>
# ==============================================================================

import sys
import os
import re

# --- Re-usable imports from other files ---
from utils import printd
from calculations import calculate_stats
from plotting import create_comparison_histogram_grid

# --- Dependency Check ---
try:
    import matplotlib
    import numpy
    # Add scikit-learn check for the new clustering dependency
    import sklearn
except ImportError:
    printd("Required packages not installed. Please run:", level='error')
    printd("pip install numpy matplotlib colorama scikit-learn", level='error')
    sys.exit(1)


def parse_logfile(logfile_path):
    """Parses the 'Threshold debug data' section of the logfile."""
    data_by_limb = {}
    current_limb_size = None
    in_debug_section = False
    try:
        with open(logfile_path, 'r') as f:
            for line in f:
                stripped_line = line.strip()
                if "Threshold debug data" in stripped_line:
                    in_debug_section = True
                    continue
                if not in_debug_section or not stripped_line.startswith('!'):
                    continue
                if not stripped_line.startswith('! @'):
                    try:
                        parts = [p.strip() for p in stripped_line[2:].split(',')]
                        num_limbs = int(parts[5])
                        current_limb_size = num_limbs
                        data_by_limb[num_limbs] = []
                    except (IndexError, ValueError):
                        current_limb_size = None
                elif stripped_line.startswith('! @') and current_limb_size is not None:
                    try:
                        values = [int(v) for v in stripped_line.split()[2:]]
                        data_by_limb[current_limb_size].extend(values)
                    except (IndexError, ValueError):
                        continue
    except FileNotFoundError:
        printd(f"The file '{logfile_path}' was not found.", level='error')
        return None
    return data_by_limb


def main():
    """Main function to drive the analysis and plotting for a single file."""
    if len(sys.argv) < 2:
        printd(f"Usage: python {sys.argv[0]} <path_to_intmul_logfile.txt>", level='error')
        sys.exit(1)

    input_filepath = sys.argv[1]
    if not os.path.isfile(input_filepath):
        printd(f"File not found: {input_filepath}", level='error')
        sys.exit(1)
    
    basename = os.path.basename(input_filepath)
    printd(f"Analyzing file: {basename}\n")
    
    parsed_data = parse_logfile(input_filepath)

    if not parsed_data:
        printd("No 'Threshold debug data' found in the file.", level='warning')
        sys.exit(1)

    # Dictionary to hold all stats needed for the final plot
    all_stats_for_plotting = {}
    
    # Print the detailed statistics table first
    header =    "Limb | Int. Latency | Min    | Orig. Max  | Filt. Max  | % Drop  | Orig. Avg (RMSE)         | Filt. Avg (RMSE)         | % Drop Avg (RMSE)   | Outliers"
    separator = "---- | ------------ | ------ | ---------- | ---------- | ------- | -------------------------- | -------------------------- | ------------------- | --------"
    print(header)
    print(separator)

    for limb_size in sorted(parsed_data.keys()):
        cycles = parsed_data[limb_size]
        
        # Pass limb_size to calculate_stats ---
        stats = calculate_stats(cycles, limb_size)
        
        if not stats:
            printd(f"Could not calculate stats for limb size {limb_size}. Skipping.", level='warning')
            continue

        # Store the complete stats dictionary for plotting later
        all_stats_for_plotting[limb_size] = stats

        # Format and print the console report
        latency_val = stats.get('interrupt_latency')
        latency_str = f"{latency_val:,}" if latency_val is not None else "N/A"
        
        original_avg_str = f"{stats['original_avg']:,} ({stats['original_rmse']:,})"
        filtered_avg_str = f"{stats['filtered_avg']:,} ({stats['filtered_rmse']:,})"
        drop_avg_str     = f"{stats['avg_percent_drop']:.1f}% ({stats['rmse_percent_drop']:.1f}%)"

        print(
            f"{limb_size:<4} | "
            f"{latency_str:<12} | "
            f"{stats['min_val']:<6,} | "
            f"{stats['original_max']:<10,} | "
            f"{stats['filtered_max']:<10,} | "
            f"{stats['max_percent_drop']:<6.1f}% | "
            f"{original_avg_str:<26} | "
            f"{filtered_avg_str:<26} | "
            f"{drop_avg_str:<19} | "
            f"{stats['outliers_removed']}"
        )
    
    # After the loop, make a single call to generate the grid plot
    printd("\nStatistical report complete. Generating plot...", level='info')
    plot_title = f"Cycle Count Histograms (Original vs. Filtered) from {basename}"
    create_comparison_histogram_grid(all_stats_for_plotting, plot_title)

    printd("Plot window closed. Program finished.", level='info')

if __name__ == "__main__":
    main()
