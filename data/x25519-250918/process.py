# ==============================================================================
#                 X25519 Log Analyzer with Plotting (Dynamic Version)
# ==============================================================================
# This script dynamically discovers and analyzes any function in a log file
# that provides detailed performance data (Cycles, Instructions). It is no
# longer limited to just 'mon_varbase_mul' and 'test_scott'.
#
# Dependencies:
#   - numpy, matplotlib, colorama, scikit-learn
#   - Local files: calculations.py, plotting.py, utils.py
#
# To install dependencies:
#   pip install numpy matplotlib colorama scikit-learn
#
# How to Run:
#   python single.py <path_to_your_x25519_logfile.txt>
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
    import sklearn
except ImportError:
    printd("Required packages not installed. Please run:", level='error')
    printd("pip install numpy matplotlib colorama scikit-learn", level='error')
    sys.exit(1)


def parse_x25519_logfile(logfile_path):
    """
    Parses cycle and instruction data for all functions in the logfile
    that provide detailed traces. It dynamically discovers function names
    from structured section headers and explicitly ignores non-performance sections.
    """
    data_streams = {}
    
    # State variables to track our position in the file
    current_function_name = None
    current_key = None
    # This flag tells the parser that it has seen an opening '====' and is now inside a title block.
    in_title_block = False

    try:
        with open(logfile_path, 'r') as f:
            for line in f:
                stripped_line = line.strip()

                # =================== MODIFIED SECTION START ===================
                # This is the corrected, more robust parsing logic that properly
                # handles bracketing separator lines.

                # A line of '===' indicates a section boundary.
                if stripped_line.startswith('====') and stripped_line.endswith('===='):
                    if not in_title_block:
                        # This is an OPENING separator. We are now in a title block.
                        in_title_block = True
                        current_function_name = None # Reset state for the new section
                        current_key = None
                    else:
                        # This is a CLOSING separator. We are no longer in a title block.
                        in_title_block = False
                    continue

                # If we are inside a title block, this line must be the function name.
                if in_title_block and stripped_line:
                    # We have found the function name.
                    # First, check if this is a section we need to IGNORE.
                    if "ecdh correctness test" in stripped_line:
                        current_function_name = None  # Flag this section to be skipped
                    else:
                        current_function_name = stripped_line # This is a valid function
                    
                    # We've processed the title, so we leave the title block state for this line.
                    # The closing '====' will handle the flag on the next iteration.
                    in_title_block = True # Remain in title block until we see the closing ====
                    continue

                # If we haven't identified a valid function we're tracking, skip data processing.
                if not current_function_name:
                    continue

                # --- Data Block Header Detection (Cycles or Instructions) ---
                normalized_header = stripped_line.replace('-', '').replace(' ', '').lower()

                if 'cycles' in normalized_header:
                    current_key = f"{current_function_name} (Cycles)"
                    if current_key not in data_streams:
                        data_streams[current_key] = []
                elif 'instructions' in normalized_header:
                    current_key = f"{current_function_name} (Instructions)"
                    if current_key not in data_streams:
                        data_streams[current_key] = []
                # =================== MODIFIED SECTION END =====================

                # --- Data Extraction ---
                # If we have an active key and see a data line, parse it.
                if current_key and stripped_line.startswith('! @'):
                    try:
                        values = [int(v) for v in stripped_line.split()[2:]]
                        data_streams[current_key].extend(values)
                    except (IndexError, ValueError):
                        # Ignore malformed data lines
                        continue

    except FileNotFoundError:
        printd(f"The file '{logfile_path}' was not found.", level='error')
        return None
        
    # Final check: Remove any function entries that were found but had no data.
    cleaned_data_streams = {k: v for k, v in data_streams.items() if v}

    if not any(cleaned_data_streams.values()):
        printd(f"No valid performance data blocks found in '{logfile_path}'.", level='warning')
        return None

    return cleaned_data_streams

def main():
    """Main function to drive the analysis and plotting for a single file."""
    if len(sys.argv) < 2:
        printd(f"Usage: python {sys.argv[0]} <path_to_x25519_logfile.txt>", level='error')
        sys.exit(1)

    input_filepath = sys.argv[1]
    if not os.path.isfile(input_filepath):
        printd(f"File not found: {input_filepath}", level='error')
        sys.exit(1)
    
    basename = os.path.basename(input_filepath)
    printd(f"Analyzing file: {basename}\n")
    
    parsed_data = parse_x25519_logfile(input_filepath)

    if not parsed_data:
        printd("Parsing failed or no data was found. Exiting.", level='error')
        sys.exit(1)

    # Dictionary to hold all stats needed for reporting and plotting
    all_stats_results = {}
    
    # --- Statistical Analysis Phase ---
    # Iterate through all discovered data streams and apply the analysis
    for category_name, data_list in parsed_data.items():
        if not data_list:
            printd(f"No data found for category '{category_name}'. Skipping.", level='warning')
            continue
        
        # Pass a dummy limb_size=0 as it is not used in the active calculations
        stats = calculate_stats(data_list, limb_size=0)
        
        if stats:
            all_stats_results[category_name] = stats

    # =================== MODIFIED SECTION START ===================
    # --- Console Reporting Phase ---
    # Adjusted column widths and alignment for better readability.
    header =    "Program (Metric)                                       | Int. Latency |          Min |    Orig. Max |    Filt. Max | % Drop  | Orig. Avg (RMSE)         | Filt. Avg (RMSE)         | % Drop Avg (RMSE)   | Outliers"
    separator = "-------------------------------------------------------- | ------------ | ------------ | ------------ | ------------ | ------- | ------------------------ | ------------------------ | ------------------- | --------"
    print(header)
    print(separator)

    for category_name in sorted(all_stats_results.keys()):
        stats = all_stats_results[category_name]
        
        # Format for clean printing
        latency_val = stats.get('interrupt_latency')
        latency_str = f"{latency_val:,}" if latency_val is not None else "N/A"
        
        original_avg_str = f"{stats['original_avg']:,} ({stats['original_rmse']:,})"
        filtered_avg_str = f"{stats['filtered_avg']:,} ({stats['filtered_rmse']:,})"
        drop_avg_str     = f"{stats['avg_percent_drop']:.1f}% ({stats['rmse_percent_drop']:.1f}%)"

        print(
            f"{category_name:<56} | "
            f"{latency_str:<12} | "
            f"{stats['min_val']:>12,} | "
            f"{stats['original_max']:>12,} | "
            f"{stats['filtered_max']:>12,} | "
            f"{stats['max_percent_drop']:>6.1f}% | "
            f"{original_avg_str:<26} | "
            f"{filtered_avg_str:<26} | "
            f"{drop_avg_str:<19} | "
            f"{stats['outliers_removed']}"
        )
    # =================== MODIFIED SECTION END =====================
    
    # --- Visualization Phase ---
    if all_stats_results:
        printd("\nStatistical report complete. Generating plot...", level='info')
        plot_title = f"Performance Analysis (Original vs. Filtered) from {basename}"
        # The plotting function will dynamically create a grid for all discovered data categories
        create_comparison_histogram_grid(all_stats_results, plot_title)
        printd("Plot window closed. Program finished.", level='info')
    else:
        printd("No stats were calculated, skipping plot generation.", level='warning')


if __name__ == "__main__":
    main()
