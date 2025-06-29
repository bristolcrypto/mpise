import sys
import os
import re
import glob
import argparse
import numpy as np
from calculations import calculate_stats
from utils import printd
from plotting import create_correlation_plot
import matplotlib.pyplot as plt

# Add scikit-learn for consistency with calculations.py ---
try:
    import numpy
    import sklearn
except ImportError:
    printd("Required packages not installed. Please run:", level='error')
    printd("pip install numpy matplotlib colorama scikit-learn", level='error')
    sys.exit(1)


def parse_logfile(logfile_path):
    """
    Parses the "Threshold debug data" section of the provided logfile.
    It extracts the header information and all associated cycle counts for
    each limb size.

    Args:
        logfile_path (str): The path to the input log file.

    Returns:
        dict: A dictionary where keys are limb sizes (int) and values are
              another dictionary containing:
              {'header_parts': A list of strings from the header line,
               'cycles': A list of all cycle count integers for that limb size}
    """
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

                if not in_debug_section:
                    continue

                # Check for a header line, e.g., '! 27, isa, 32, 0, 0, 8, 216, 1000'
                if stripped_line.startswith('! ') and not stripped_line.startswith('! @'):
                    try:
                        # Remove the '!' prefix and split by comma
                        parts = [p.strip() for p in stripped_line[2:].split(',')]
                        num_limbs = int(parts[5])
                        current_limb_size = num_limbs
                        # Initialize the entry for this limb size
                        data_by_limb[num_limbs] = {'header_parts': parts, 'cycles': []}
                    except (IndexError, ValueError):
                        # Reset if the line is malformed
                        current_limb_size = None
                        continue
                
                # Check for a data line, e.g., '! @  1263 1216 ...'
                elif stripped_line.startswith('! @') and current_limb_size is not None:
                    try:
                        # Split by space, take all values after '! @'
                        values = [int(v) for v in stripped_line.split()[2:]]
                        data_by_limb[current_limb_size]['cycles'].extend(values)
                    except (IndexError, ValueError):
                        continue
    except FileNotFoundError:
        printd(f"The file '{logfile_path}' was not found.", level='error')
        return None
    except Exception as e:
        printd(f"An error occurred while reading the file: {e}", level='error')
        return None

    return data_by_limb

def process_single_file(input_filepath, correlation_data_list):
    """
    Parses a single logfile, prints its metrics, and collects a dictionary
    of data for each valid point for the final correlation analysis.
    """
    printd(f"Processing File: {os.path.basename(input_filepath)}")

    # 1. Parse filename to get metadata
    basename = os.path.basename(input_filepath)
    match = re.search(r'intmul-(.+?)_(.+?)_(\d+?)_(.+?)\.log', basename)
    
    if not match:
        printd(f"Filename '{basename}' does not match expected format. Skipping.", level='warning')
        return
        
    arch, type_val, radix, version = match.groups()

    # 2. Parse logfile content
    parsed_data = parse_logfile(input_filepath)

    if not parsed_data:
        printd("No 'Threshold debug data' found. Skipping file.\n", level='warning')
        return

    # 3. Extract common header values
    try:
        # Get all the keys (limb sizes) and sort them
        sorted_keys = sorted(parsed_data.keys())
        if not sorted_keys:
             printd("Parsed data is empty. Skipping file.\n", level='warning')
             return
        
        first_key = sorted_keys[0]
        first_header_parts = parsed_data[first_key]['header_parts']

        # The format is: (LIMBBITS, TYPE, XLEN, DESTRUCTIVE, STATELESS, #LIMBS, ...)
        mpise_destructive = first_header_parts[3].strip()
        mpise_stateless = first_header_parts[4].strip()
    except (IndexError, KeyError) as e:
        printd(f"Could not parse header parts. Malformed line? Details: {e}. Skipping file.\n", level='warning')
        return

    # 4. Construct output path and write the summary file
    output_filepath = argv.output_dir + "/" + basename
    with open(output_filepath, 'w') as f_out:
        # Write headers to the output file
        f_out.write(">>>>\n====\n")
        f_out.write("REPO_HOME         := auto-generated-text\n")
        f_out.write("RISCV             := auto-generated-text\n")
        f_out.write(f"MPISE_DESTRUCTIVE := {mpise_destructive}\n")
        f_out.write(f"MPISE_STATELESS   := {mpise_stateless}\n")
        f_out.write("----\n")
        f_out.write(f"ARCH              := {arch}\n")
        f_out.write(f"TYPE              := {type_val}\n")
        f_out.write(f"RADIX             := {radix}\n")
        f_out.write("PLATFORM          := cva6-fpga\n")
        f_out.write(f"VERSION           := {version}\n")
        f_out.write("<<<<\n")
        f_out.write("bbl loader\n")

        # Define the header for the metrics table for improved readability
        header =    "Limb | Int. Latency | Min    | Orig. Max  | Filt. Max  | % Drop  | Orig. Avg (RMSE)         | Filt. Avg (RMSE)         | % Drop Avg (RMSE)   | Outliers"
        separator = "---- | ------------ | ------ | ---------- | ---------- | ------- | ------------------------ | ------------------------ | ------------------- | --------"
        print(header)
        print(separator)

        for limb_size in sorted(parsed_data.keys()):
            data = parsed_data[limb_size]
            cycles = data.get('cycles', [])
            header_parts = data.get('header_parts', [])

            if not cycles or not header_parts:
                continue

            stats = calculate_stats(cycles, limb_size)
            
            if not stats:
                printd(f"Could not calculate stats for limb size {limb_size}. Skipping.", level='warning')
                continue
            # --- Collect a dictionary of data for the correlation plot ---
            latency_val = stats.get('interrupt_latency')
            if latency_val is not None:
                # --- MODIFICATION: Add 'type' and 'version' to the dictionary ---
                point_data = {
                    'limb_size': limb_size,
                    'radix': radix,
                    'arch': arch,
                    'type': type_val,
                    'version': version,
                    'original_rmse': stats['original_rmse'],
                    'interrupt_latency': latency_val
                }
                correlation_data_list.append(point_data)

            # Format and print the console report
            latency_str = f"{latency_val:,}" if latency_val is not None else "N/A"

            # --- Create formatted strings for each part of the table ---
            original_avg_str = f"{stats['original_avg']:,} ({stats['original_rmse']:,})"
            filtered_avg_str = f"{stats['filtered_avg']:,} ({stats['filtered_rmse']:,})"
            drop_avg_str     = f"{stats['avg_percent_drop']:.1f}% ({stats['rmse_percent_drop']:.1f}%)"

            # --- Print the new, more detailed row ---
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

            # The output file still uses the filtered min, max, and avg
            output_parts = header_parts + ['1000', str(stats['min_val']), str(stats['filtered_max']), str(stats['filtered_avg'])]
            f_out.write("! " + ", ".join(output_parts) + "\n")
            f_out.write("  result is correct!\n")

    printd(f"Successfully generated summary file: '{output_filepath}'\n")

def main():
    """
    Main function to find and process all matching log files in a directory.
    """
    if not os.path.isdir(argv.input_dir):
        printd(f"'{argv.input_dir}' is not a valid directory.", level='error')
        sys.exit(1)
    if not os.path.isdir(argv.output_dir):
        printd(f"'{argv_output_dir}' is not a valid directory.", level='error')
        sys.exit(1)

    directory_path = argv.input_dir
    search_pattern = os.path.join(directory_path, 'intmul-*.log')
    file_list = glob.glob(search_pattern)

    if not file_list:
        printd(f"No files matching 'intmul-*.log' found in '{directory_path}'.")
        sys.exit(0)
    
    file_list.sort()
    
    # --- Initialize a list to hold data from all files for the final plot ---
    all_correlation_data = []
    
    # --- Create a temp directory where all logs will be stored
    os.makedirs(os.path.dirname(argv.output_dir), exist_ok=True)
    for filepath in file_list:
        # Pass the list to the processing function to be populated
        process_single_file(filepath, all_correlation_data)

    # --- After processing all files, create and show the correlation plot ---
    if all_correlation_data:
        printd("All files processed. Generating correlation plot...", level='info')
        create_correlation_plot(all_correlation_data)
        plt.show()
    else:
        printd("No valid data was found for correlation analysis across all files.", level='warning')

if __name__ == "__main__":
    parser = argparse.ArgumentParser( add_help = False )
    parser.add_argument( '--input-dir',    action = 'store', default="" )
    parser.add_argument( '--output-dir',    action = 'store', default="" )
    argv = parser.parse_args()
    main()
