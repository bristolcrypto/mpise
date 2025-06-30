#!/bin/bash
set -e
if ! [ -n "$MPISE_DESTRUCTIVE" ]; then
  echo "Error : MPISE_DESTRUCTIVE is not defined."
  exit
fi
if ! [ -n "$MPISE_STATELESS" ]; then
  echo "Error : MPISE_STATELESS is not defined."
  exit
fi
if ! [ -n "$ARCH" ]; then
  echo "Error : ARCH is not defined. Choices : [ \"rv32\", \"rv64\" ] "
  exit
fi
    
echo "--- Processing: DESTRUCTIVE=${MPISE_DESTRUCTIVE}, STATELESS=${MPISE_STATELESS} ---"

# Define paths based on the current loop variables
SOURCE_FOLDER="original-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"
DESTINATION_FOLDER="generated-logs/${ARCH}_mpise_${MPISE_DESTRUCTIVE}${MPISE_STATELESS}"

# Clean up old destination and create a fresh one
rm -rf "$DESTINATION_FOLDER"
mkdir -p "$DESTINATION_FOLDER"

# Run the python script which generates the 'mod_*.txt' files
python all.py --input-dir "$SOURCE_FOLDER" --output-dir "${DESTINATION_FOLDER}" 

# Move and rename the generated files to the correct destination
# The 'if' statement prevents errors if no 'mod_*.txt' files were created
#    for file in mod_*.txt; do
#      if [ -f "$file" ]; then
#        mv "$file" "$DESTINATION_FOLDER/${file#mod_}"
#      fi
#    done

echo "--- Done. Results moved to $DESTINATION_FOLDER ---"
echo "" # Add a blank line for readability

echo "All generated logfiles processed."
