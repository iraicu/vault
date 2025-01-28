#!/bin/bash

output_file="data/8socket/bladebit-ram-C0-SSD.csv"

echo "Threads,Phase3_Time,Phase4_Time,Write_Time,Total_Time" > "$output_file"

# Function to run Bladebit and extract times
run_bladebit_test() {
    local threads=$1
    local disk_type=$2
    local plot_dir=$3

    ./drop-all-caches.sh "$disk_type"

    log_file="bladebit_${threads}_${disk_type}.log"
    chia plotters bladebit ramplot -d "$plot_dir" --compress 0 -r "$threads" &> "$log_file"
    rm $plot_dir/*

    # Extract times from the log
    phase3_time=$(grep "Finished Phase 3" "$log_file" | awk '{print $4}')
    phase4_time=$(grep "Finished Phase 4" "$log_file" | awk '{print $4}')
    write_time=$(grep "Finished writing tables to disk" "$log_file" | awk '{print $6}')
    total_time=$(grep "Finished plotting" "$log_file" | awk '{print $4}')

    # Append the results to the output file
    echo "$threads,$phase3_time,$phase4_time,$write_time,$total_time" >> "$output_file"
}

#for threads in 1 2 4 8 16 32 64; do
#    echo "Running Bladebit test on HDD with $threads threads..."
#    run_bladebit_test "$threads" "HDD" "/data-l/varvara/plot/"
#done

for threads in 1 2 4 8 16 32 64 128; do
    echo "Running Bladebit test on SSD with $threads threads..."
    run_bladebit_test "$threads" "SSD" "/ssd-raid0/varvara/plot"
done

echo "Bladebit parameter sweep completed. Results saved to $output_file."
