import matplotlib.pyplot as plt
import re
import sys
import argparse

def parse_cycles_from_file(log_content, function_name):
    """
    Parses the log file content to extract cycle counts for a specific function.

    Args:
        log_content (str): The entire content of the log file as a string.
        function_name (str): The name of the function to find (e.g., 'gfp mul').

    Returns:
        list: A list of integers representing the cycle counts for the function.
              Returns an empty list if the function is not found.
    """
    # CORRECTED and more robust regular expression.
    # It finds the block starting with the function name, looks for the "Cycles"
    # section, and captures all content until the "Instructions" section begins.
    pattern = re.compile(
        # Match the header line, e.g., "test_gfp_arith - gfp mul"
        r"test_gfp_arith - " + re.escape(function_name) +
        # Match everything non-greedily until the "Cycles" header
        r".*?-+\s*Cycles\s*-+.*?\n" +
        # CAPTURE the lines with numbers until the "Instructions" header
        r"(.*?)" +
        # Match the "Instructions" header which marks the end of the section
        r"^-+\s*Instructions",
        # Flags: DOTALL allows '.' to match newlines, MULTILINE allows '^' to match start of lines
        re.DOTALL | re.MULTILINE
    )

    match = pattern.search(log_content)

    if not match:
        print(f"INFO: Data for '{function_name}' not found. Skipping plot.")
        return []

    # The captured text block containing all cycle data for the function
    cycles_block = match.group(1)

    # Find all individual numbers within that captured block and convert to integer
    cycle_counts = [int(num) for num in re.findall(r'\d+', cycles_block)]

    if not cycle_counts:
        print(f"WARNING: Found section for '{function_name}' but it contained no numbers.")

    return cycle_counts

def main():
    """
    Main function to parse arguments, read the file, and generate plots.
    """
    parser = argparse.ArgumentParser(
        description="Parse a log file and plot cycle counts for GFP arithmetic functions."
    )
    parser.add_argument(
        "logfile",
        help="Path to the log file to be analyzed."
    )
    args = parser.parse_args()

    try:
        with open(args.logfile, 'r') as f:
            log_content = f.read()
    except FileNotFoundError:
        print(f"ERROR: The file '{args.logfile}' was not found.")
        sys.exit(1)
    except Exception as e:
        print(f"ERROR: An error occurred while reading the file: {e}")
        sys.exit(1)

    functions_to_plot = {
        'gfp mul': 'firebrick',
        'gfp sqr': 'darkorange',
        'gfp add': 'steelblue',
        'gfp sub': 'seagreen'
    }

    # Dictionary to hold the extracted data
    all_data = {}
    total_data_points = 0

    for func_name in functions_to_plot.keys():
        cycles = parse_cycles_from_file(log_content, func_name)
        all_data[func_name] = cycles
        total_data_points += len(cycles)

    # Check if any data was extracted at all before creating a plot
    if total_data_points == 0:
        print("\nERROR: Failed to extract any cycle data from the log file.")
        print("Please ensure the file format matches the expected structure.")
        sys.exit(1)

    fig, axs = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('Analysis of GFP Arithmetic Cycle Counts', fontsize=16)
    axs = axs.flatten()

    for i, (func_name, color) in enumerate(functions_to_plot.items()):
        cycles = all_data[func_name]
        if cycles:
            ax = axs[i]
            ax.plot(cycles, marker='o', linestyle='-', markersize=4, color=color, label=f'Cycles: {func_name}')
            ax.set_title(f'Performance of {func_name}')
            ax.set_xlabel("Iteration")
            ax.set_ylabel("Clock Cycles")
            ax.grid(True, which='both', linestyle='--', linewidth=0.5)
            # Calculate and display stats
            avg = sum(cycles) / len(cycles)
            stable_val = cycles[-1]
            stat_text = f'Average: {avg:.2f}\nLast Value: {stable_val}'
            ax.text(0.05, 0.95, stat_text, transform=ax.transAxes, fontsize=9,
                    verticalalignment='top', bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
            ax.legend()

    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.show()

if __name__ == "__main__":
    main()
