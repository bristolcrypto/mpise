import matplotlib.pyplot as plt
import re
import sys
import argparse
import math

def find_all_functions(log_content):
    """
    Parses the log file content to find all unique test-function pairs.

    Args:
        log_content (str): The entire content of the log file as a string.

    Returns:
        list: A list of tuples, where each tuple contains the test name and
              the specific function name (e.g., [('test_nop', 'nop_routine'), ...]).
    """
    # This pattern finds all headers like "test_name - function_name"
    pattern = re.compile(r"^=+\s*\n(.*?)\s+-\s+(.*?)\s*\n=+", re.MULTILINE)
    functions = pattern.findall(log_content)
    # The ECDH correctness test is not a performance benchmark, so we exclude it.
    functions = [f for f in functions if f[0] != 'ecdh correctness test']
    return functions

def parse_performance_data(log_content, test_name, func_name):
    """
    Parses the log file to extract cycle and instruction counts for a specific function.

    Args:
        log_content (str): The entire content of the log file as a string.
        test_name (str): The name of the test block (e.g., 'test_gfp_arith').
        func_name (str): The name of the function (e.g., 'gfp mul').

    Returns:
        tuple: A tuple containing two lists: (cycle_counts, instruction_counts).
               Returns ([], []) if the function is not found or data is missing.
    """
    # This more robust pattern finds the function block and then captures
    # the data within the "Cycles" and "Instructions" sections respectively.
    pattern = re.compile(
        # Match the exact header line for the specified test and function
        r"^=+\s*\n" + re.escape(test_name) + r"\s+-\s+" + re.escape(func_name) + r"\s*\n=+" +
        # Match everything non-greedily until the "Cycles" header
        r".*?-+\s*Cycles\s*-+.*?\n" +
        # CAPTURE the lines with cycle numbers
        r"(.*?)" +
        # Match the "Instructions" header which marks the end of the cycles section
        r"-+\s*Instructions\s*-+.*?\n" +
        # CAPTURE the lines with instruction numbers
        r"(.*?)" +
        # The data section ends with a final "---" line
        r"^-+",
        re.DOTALL | re.MULTILINE
    )

    match = pattern.search(log_content)

    if not match:
        return [], []

    # The captured text block containing all cycle data
    cycles_block = match.group(1)
    # The captured text block containing all instruction data
    instructions_block = match.group(2)

    # Find all individual numbers within each block and convert them to integers
    cycle_counts = [int(num) for num in re.findall(r'\d+', cycles_block)]
    instruction_counts = [int(num) for num in re.findall(r'\d+', instructions_block)]

    return cycle_counts, instruction_counts

def main():
    """
    Main function to parse arguments, read the file, and generate plots for all functions.
    """
    parser = argparse.ArgumentParser(
        description="Parse a log file and plot cycle and instruction counts for all functions found."
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

    functions_to_plot = find_all_functions(log_content)

    if not functions_to_plot:
        print("\nERROR: Failed to find any function performance data in the log file.")
        print("Please ensure the file format matches the expected structure.")
        sys.exit(1)

    # Dynamically determine the grid size for the subplots
    num_functions = len(functions_to_plot)
    cols = math.ceil(math.sqrt(num_functions))
    rows = math.ceil(num_functions / cols)

    fig, axs = plt.subplots(rows, cols, figsize=(cols * 5, rows * 4), squeeze=False)
    fig.suptitle('Performance Analysis of Cryptographic Functions on CVA6', fontsize=18)
    axs = axs.flatten()

    for i, (test_name, func_name) in enumerate(functions_to_plot):
        cycles, instructions = parse_performance_data(log_content, test_name, func_name)
        ax = axs[i]

        if cycles and instructions:
            # The x-axis length is automatically determined by the length of the data list
            iterations = range(len(cycles))

            # Plot both cycles and instructions on the same subplot
            ax.plot(iterations, cycles, marker='o', linestyle='-', markersize=3, color='steelblue', label='Clock Cycles')
            ax.plot(iterations, instructions, marker='x', linestyle='--', markersize=3, color='firebrick', label='Instructions')

            ax.set_title(f'{test_name}\n{func_name}', fontsize=10)
            ax.set_xlabel("Iteration")
            ax.set_ylabel("Count")
            ax.grid(True, which='both', linestyle='--', linewidth=0.5)
            ax.legend()
            # Use scientific notation for y-axis if numbers are large
            ax.ticklabel_format(style='sci', axis='y', scilimits=(0,0))
        else:
            # If no data was found for some reason, show an empty plot
            ax.set_title(f'{func_name}\n(No data found)')
            ax.axis('off')

    # Turn off any unused subplots in the grid
    for i in range(num_functions, len(axs)):
        axs[i].axis('off')

    plt.tight_layout(rect=[0, 0.03, 1, 0.96])
    plt.show()

if __name__ == "__main__":
    main()
