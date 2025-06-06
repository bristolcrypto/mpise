# split_log.py
import sys
import os

def split_log_file(main_log_path):
    """
    Splits a large log file into smaller files based on header lines.
    
    A header line looks like:
    -----------------Showing filename.log-----------------
    """
    try:
        # Safely open the main log file for reading
        with open(main_log_path, 'r') as infile:
            current_outfile = None
            
            for line in infile:
                # Check if the line is a header
                if line.startswith('-----------------Showing ') and line.strip().endswith('-----------------'):
                    
                    # If a file is already open, close it before opening the next one.
                    if current_outfile:
                        current_outfile.close()
                    
                    # --- Extract the new filename from the header line ---
                    # 1. Strip whitespace and the outer dashes
                    filename = line.strip().replace('-----------------Showing ', '').replace('-----------------', '')
                    
                    # 2. A more robust way using split():
                    # filename = line.split()[1].removesuffix('-----------------') # Python 3.9+
                    
                    print(f"Found new section. Creating '{filename}'...")
                    
                    # Open the new file for writing
                    current_outfile = open(filename, 'w')
                    
                # If it's not a header line and we have an open file, write the line to it.
                elif current_outfile:
                    current_outfile.write(line)

            # After the loop finishes, make sure the last file is closed.
            if current_outfile:
                current_outfile.close()
                
            print("\nProcessing complete.")

    except FileNotFoundError:
        print(f"Error: The file '{main_log_path}' was not found.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    # Expect the log file name as a command-line argument.
    # If not provided, ask the user for it.
    if len(sys.argv) > 1:
        log_file_name = sys.argv[1]
    else:
        print("Usage: python split_log.py <your_main_log_file.log>")
        # A fallback to ask for input interactively
        try:
            log_file_name = input("Please enter the name of the main log file: ")
            if not os.path.exists(log_file_name):
                 print(f"File '{log_file_name}' not found. Exiting.")
                 sys.exit(1)
        except (KeyboardInterrupt, EOFError):
            print("\nCancelled. Exiting.")
            sys.exit(1)

    split_log_file(log_file_name)
