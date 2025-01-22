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
LOOKUP_TIMES=()
PROOF_TIMES=()

# Read the log file line by line
while IFS= read -r line; do
    if [[ "$line" =~ Looking\ up\ qualities\ took:\ ([0-9]+)\ ms ]]; then
        LOOKUP_TIMES+=("${BASH_REMATCH[1]}")
    elif [[ "$line" =~ Finding\ proof\ took:\ ([0-9]+)\ ms ]]; then
        PROOF_TIMES+=("${BASH_REMATCH[1]}")
    fi
done < "$TEMP_LOG"

# Ensure equal entries for lookup and proof times
if [ "${#LOOKUP_TIMES[@]}" -ne "${#PROOF_TIMES[@]}" ]; then
    echo "Error: Mismatched number of 'Looking up qualities' and 'Finding proof' entries."
    rm -f "$TEMP_LOG"
    exit 1
fi

# Write data to CSV
for ((i = 0; i < ${#LOOKUP_TIMES[@]}; i++)); do
    LOOKUP="${LOOKUP_TIMES[$i]}"
    PROOF="${PROOF_TIMES[$i]}"
    TOTAL=$((LOOKUP + PROOF))
    echo "$LOOKUP,$PROOF,$TOTAL" >> "$OUTPUT_CSV"
done

# Clean up temporary log file
#rm -f "$TEMP_LOG"

echo "Results saved to $OUTPUT_CSV"

