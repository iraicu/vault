#!/bin/bash

# Check for user argument (HDD or NVME)
if [ -z "$1" ]; then
    echo "Usage: $0 <HDD|NVME>"
    exit 1
fi

DISK_TYPE=$1

# Machine-specific configurations
case $(hostname) in
    "epycbox")
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-l/varvara/tmp"
            plot_dir="/data-l/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for epycbox. Use 'HDD' or 'NVME'."
            exit 1
        fi
        threads=64
        buffer=262144
        buckets=128
        stripe=65536
        MACHINE_NAME="epycbox"
        ;;
    "orangepi5plus")
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-a/varvara/tmp"
            plot_dir="/data-a/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for orangepi5plus. Use 'HDD' or 'NVME'."
            exit 1
        fi
        threads=8
        buffer=16384
        buckets=128
        stripe=32768
        MACHINE_NAME="opi5"
        ;;
    "raspberrypi5")
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-a/varvara/tmp"
            plot_dir="/data-a/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for raspberrypi5. Use 'HDD' or 'NVME'."
            exit 1
        fi
        threads=2
        buffer=2048
        buckets=128
        stripe=32768
        MACHINE_NAME="rpi5"
        ;;
    *)
        echo "Unknown machine. Using default configuration."
        temp_dir="/mnt/default_temp"
        plot_dir="/mnt/default_plot"
        threads=4
        buffer=32768
        buckets=64
        stripe=32768
        ;;
esac

# Ensure directories exist
mkdir -p "$temp_dir" "$plot_dir"

# Output directories
log_dir="./chia_k_logs"
output_dir="./data/$MACHINE_NAME"
output_file="$output_dir/chia-C0-${DISK_TYPE}.csv"

# Create directories for logs and output
mkdir -p "$log_dir" "$output_dir"

# Initialize the CSV file with headers
echo "k,Temp_Dir,Final_Dir,Phase_1_Time,Phase_2_Time,Phase_3_Time,Phase_4_Time,Total_Time,Final_File_Size" > "$output_file"

# Function to clean up files in temp and plot directories
cleanup_directories() {
    echo "Cleaning up directories: $temp_dir and $plot_dir..."
    rm -rf "$temp_dir"/* "$plot_dir"/*
}

# Function to run chia plotter and extract data
run_plotter() {
    local k=$1
    local log_file="$log_dir/chia_k${k}_${DISK_TYPE}_$(hostname).log"

    # Drop all caches
    echo "Dropping all caches using ./drop-all-caches.sh $DISK_TYPE..."
    ./drop-all-caches.sh "$DISK_TYPE"

    echo "Running chia plotter for k=$k on $MACHINE_NAME..."
    chia plotters chiapos --override-k \
        -k "$k" \
        -r "$threads" \
        -b "$buffer" \
        -u "$buckets" \
        -s "$stripe" \
        -t "$temp_dir" \
        -d "$plot_dir" > "$log_file" 2>&1

    echo "Completed k=$k. Log saved to $log_file."

    # Extract relevant data from the log
    local temp_dir=$(grep -oP "Starting plotting progress into temporary dirs: \K[^ ]+" "$log_file")
    local final_dir=$(grep "Final Directory is:" "$log_file" | awk '{print $4}')
    local phase_1_time=$(grep "Time for phase 1" "$log_file" | awk '{print $6}')
    local phase_2_time=$(grep "Time for phase 2" "$log_file" | awk '{print $6}')
    local phase_3_time=$(grep "Time for phase 3" "$log_file" | awk '{print $6}')
    local phase_4_time=$(grep "Time for phase 4" "$log_file" | awk '{print $6}')
    local total_time=$(grep "Total time" "$log_file" | awk '{print $4}')
    local final_file_size=$(grep "Final File size:" "$log_file" | awk '{print $5}' | sed 's/[A-Za-z]*//g' | sed 's/ *$//')

    # Append extracted data to the CSV file
    echo "$k,$tmp_dir,$final_dir,$phase_1_time,$phase_2_time,$phase_3_time,$phase_4_time,$total_time,$final_file_size" >> "$output_file"

    # Cleanup directories after plot is created
    cleanup_directories
}

# Run chia plotter for k values from 25 to 35
for k in {25..35}; do
    run_plotter "$k"
done

echo "All k values completed. Results saved to $output_file."
