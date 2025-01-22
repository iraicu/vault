#!/bin/bash

# Check if the plot file path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <plot-file-path>"
    exit 1
fi

PLOT_FILE=$1
MACHINE_NAME=$2
DISK=$3
OUTPUT_CSV="data/${MACHINE_NAME}/chia-search-C0-${DISK}.csv"

# Run chia plots check and save the output to a temporary file
TEMP_LOG="chia_plot_check_temp.log"
chia plots check -n 100 -g "$PLOT_FILE" > "$TEMP_LOG" 2>&1

# Prepare the CSV file with headers
echo "Looking_Up_Qualities(ms),Finding_Proof(ms),Total_Time(ms)" > "$OUTPUT_CSV"

# Extract relevant data and process it
grep -E "Looking up qualities|Finding proof" "$TEMP_LOG" | awk '
BEGIN {
    lookup_time = 0;
    proof_time = 0;
}
{
    if ($6 == "qualities") {
        lookup_time = $7;  # Capture "Looking up qualities" time
    } else if ($4 == "proof") {
        proof_time = $5;  # Capture "Finding proof" time
        total_time = lookup_time + proof_time;  # Calculate total time
        # Append the times to the CSV file
        printf "%s,%s,%s\n", lookup_time, proof_time, total_time >> "'$OUTPUT_CSV'"
    }
}'

# Clean up temporary log file
#rm -f "$TEMP_LOG"

echo "Results saved to $OUTPUT_CSV"

