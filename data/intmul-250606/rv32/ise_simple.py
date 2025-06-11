import matplotlib.pyplot as plt
import os
import re
import shutil # For creating/removing dummy directories
import sys
# --- Configuration ---
BASE_DIR = sys.argv[1]
BASE_DIR_SET1 = str(BASE_DIR) + "/fpga"
BASE_DIR_SET2 = str(BASE_DIR) + "/spike"

# List of base log file names (without directory path)
# These are the files expected within BASE_DIR_SET1 and BASE_DIR_SET2
base_log_filenames = [
    "intmul-rv32_ise_32_simple.log",
    "intmul-rv32_ise_30_simple.log", "intmul-rv32_ise_29_simple.log",
    "intmul-rv32_ise_28_simple.log", "intmul-rv32_ise_27_simple.log",
    "intmul-rv32_ise_26_simple.log", "intmul-rv32_ise_25_simple.log",
    "intmul-rv32_ise_24_simple.log", "intmul-rv32_ise_23_simple.log",
    "intmul-rv32_ise_22_simple.log", "intmul-rv32_ise_21_simple.log",
    "intmul-rv32_ise_20_simple.log"
]

# --- Data Parsing (same as before, just called for each file path) ---
def parse_log_file_data(filepath):
    x_values = []
    y_values = []
    file_radix = None
    file_type_from_data = None
    file_xlen_from_data = None

    try:
        with open(filepath, 'r') as f:
            for line_num, line_content in enumerate(f, 1):
                line_content = line_content.strip()
                if line_content.startswith("!"):
                    parts = line_content.lstrip("! ").split(',')
                    if len(parts) == 10:
                        try:
                            current_limbbits = int(parts[0].strip())
                            if file_radix is None: file_radix = current_limbbits
                            elif file_radix != current_limbbits:
                                print(f"Warning: Inconsistent LIMBBITS ({current_limbbits}) in {filepath} at line {line_num}, expected {file_radix}. Skipping line.")
                                continue
                            
                            type_val = parts[1].strip()
                            xlen_val = int(parts[2].strip())
                            if file_type_from_data is None: file_type_from_data = type_val
                            if file_xlen_from_data is None: file_xlen_from_data = xlen_val
                            
                            x_values.append(int(parts[6].strip()))
                            y_values.append(int(parts[9].strip()))
                        except ValueError as e:
                            print(f"Skipping data line due to parsing error in {filepath} at line {line_num}: '{line_content}' - {e}")
                            continue
        
        match_fn = re.search(r'_ise_(\d+)_simple.log', os.path.basename(filepath))
        if match_fn and file_radix is not None:
            radix_from_filename = int(match_fn.group(1))
            if radix_from_filename != file_radix:
                print(f"Warning: Radix from filename ({radix_from_filename}) differs from LIMBBITS ({file_radix}) in data for {filepath}. Using data LIMBBITS.")
        elif match_fn and file_radix is None and x_values:
             file_radix = int(match_fn.group(1))
             print(f"Warning: Using radix from filename for {filepath} as LIMBBITS could not be determined.")
        print(f"Parsed {len(x_values)} lines of data from {filepath}")
        return file_radix, x_values, y_values, file_type_from_data, file_xlen_from_data

    except FileNotFoundError:
        # print(f"Info: File not found {filepath} (this might be expected if one set is incomplete)")
        return None, [], [], None, None
    except Exception as e:
        print(f"Error reading or parsing file {filepath}: {e}")
        return None, [], [], None, None

# --- Main data processing loop ---
plot_data_by_set = {
    "fpga": {},  # Key: radix (int), Value: {'x': [...], 'y': [...]}
    "spike": {}
}
common_config_type = None # Assume type and xlen are common, take from first valid parsed file
common_config_xlen = None
parsed_any_file = False
all_radixes_found = set()
max_x_overall = 0
all_y_vals_flat = []

for base_filename in base_log_filenames:
    for set_name, set_dir in [("fpga", BASE_DIR_SET1), ("spike", BASE_DIR_SET2)]:
        filepath = os.path.join(set_dir, base_filename)
        radix, x_data, y_data, current_file_type, current_file_xlen = parse_log_file_data(filepath)

        if radix is not None and x_data and y_data:
            parsed_any_file = True
            radix_int = int(radix)
            all_radixes_found.add(radix_int)
            plot_data_by_set[set_name][radix_int] = {'x': x_data, 'y': y_data}
            
            if x_data: max_x_overall = max(max_x_overall, max(x_data))
            all_y_vals_flat.extend(y_data)
            
            if common_config_type is None and current_file_type:
                common_config_type = current_file_type
            elif current_file_type and common_config_type and common_config_type != current_file_type:
                print(f"Warning: TYPE mismatch. Global '{common_config_type}', file '{filepath}' has '{current_file_type}'.")

            if common_config_xlen is None and current_file_xlen:
                common_config_xlen = current_file_xlen
            elif current_file_xlen and common_config_xlen and common_config_xlen != current_file_xlen:
                print(f"Warning: XLEN mismatch. Global '{common_config_xlen}', file '{filepath}' has '{current_file_xlen}'.")


if not parsed_any_file:
    print("Critical: No data was successfully parsed from any log file in any set. Cannot generate plot.")
    print(f"Please ensure log files exist in subdirectories '{BASE_DIR_SET1}/' and '{BASE_DIR_SET2}/'")
    print(f"Expected filenames like: {base_log_filenames[0]}")
else:
    # --- Plotting ---
    fig, ax = plt.subplots(figsize=(12, 8)) # Adjusted size slightly

    sorted_radixes = sorted(list(all_radixes_found))
    
    # Define distinct linestyles and markers for sets
    set_styles = {
        "fpga": {'linestyle': '-', 'marker': 'x', 'label_suffix': '(FPGA)'},
        "spike": {'linestyle': '--', 'marker': '+', 'label_suffix': '(Spike)'}
    }

    # Use a color cycler for Radix values
    # Create a list of colors from a colormap
    # `plt.cm.tab10.colors` gives a list of 10 distinct colors
    # `plt.cm.get_cmap('tab20').colors` gives 20 colors
    colors = plt.cm.get_cmap('tab20').colors if len(sorted_radixes) > 10 else plt.cm.tab10.colors


    for i, radix_key in enumerate(sorted_radixes):
        color_for_radix = colors[i % len(colors)] # Cycle through available colors

        # Legend label base
        label_base = f"Radix $2^{{{radix_key}}}$"
        
        for set_name, style_dict in set_styles.items():
            if radix_key in plot_data_by_set[set_name]:
                data = plot_data_by_set[set_name][radix_key]
                ax.plot(data['x'], data['y'],
                        marker=style_dict['marker'],
                        linestyle=style_dict['linestyle'],
                        color=color_for_radix,
                        label=f"{label_base} {style_dict['label_suffix']}")

    ax.set_xlabel("Operand length (bits)")
    ax.set_ylabel("Cycles")

    upper_x_limit = max(4000, (max_x_overall // 1000 + 1) * 1000 if max_x_overall > 0 else 4000)
    ax.set_xticks(range(0, int(upper_x_limit) + 1, 1000))
    ax.set_xlim(left=-100, right=upper_x_limit + 100)

    min_y_data = 0
    max_y_data = max(all_y_vals_flat) if all_y_vals_flat else 20000

    if max_y_data <= 22500:
        tick_step_y = 2500
        max_y_tick_val = max(20000, ((max_y_data // tick_step_y) +1) * tick_step_y if max_y_data > 0 else tick_step_y)
    else:
        tick_step_y = 5000
        max_y_tick_val = ((max_y_data // tick_step_y) + (1 if max_y_data % tick_step_y else 0) ) * tick_step_y
        if max_y_data == 0 : max_y_tick_val = tick_step_y

    ax.set_yticks(range(int(min_y_data), int(max_y_tick_val) + 1, int(tick_step_y)))
    ax.set_ylim(bottom = min_y_data - 0.05 * max_y_tick_val, top = max_y_tick_val * 1.05) 
    #ax.invert_yaxis()

    ax.grid(True)
    # Adjust legend font size and placement if it gets too crowded
    ax.legend(loc='upper right', fontsize='small') 

    type_annot_str = f"type = {common_config_type}" if common_config_type else "type = ?"
    xlen_annot_str = f"xlen = {common_config_xlen}" if common_config_xlen else "xlen = ?"
    
    fig.text(0.90, 0.96, f"{type_annot_str}, {xlen_annot_str}", 
             ha='left', va='top', fontsize=9, transform=fig.transFigure)

    plt.tight_layout(rect=[0.08, 0.05, 0.88, 0.93]) 
    plt.suptitle("Performance Comparison: FPGA vs Spike", fontsize=14, y=0.98) # Add a main title
    plt.show()
