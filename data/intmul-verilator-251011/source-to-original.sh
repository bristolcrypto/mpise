#!/bin/bash
WORK_DIR="$(pwd)"
TEMP1_DIR="${WORK_DIR}/original-logs/$1"
SOURCE_DIR="${WORK_DIR}/source-logs/$1/cva6-logs"
mkdir -p $TEMP1_DIR
for i in $SOURCE_DIR/*;
do
	source_file=$i;                                  # Original logfile (from verilator)
	file_b="${TEMP1_DIR}/$(basename "${i%%.*}").logb" # name of temp1 processed file
	file_c="${TEMP1_DIR}/$(basename "${i%%.*}").log"  # name of final processed file
	touch $file_b;                                   # Create new file

	sed -n '/Listening on port..../,/\*\*\* SUCCESS \*\*\*/p' $source_file > $file_b;

	# Final processed output in file_c
        sed '1d;$d' $file_b > $file_c
	rm $file_b					  # remove temp file
done

