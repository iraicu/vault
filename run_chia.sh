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

# Output log directory
log_dir="./chia_k_logs"
mkdir -p "$log_dir"

# Function to run chia plotter for a specific k value
run_plotter() {
    local k=$1
    local log_file="$log_dir/chia_k${k}_${DISK_TYPE}_$(hostname).log"

    echo "Running chia plotter for k=$k on $(hostname)..."
    chia plotters chiapos --override-k \
        -k "$k" \
        -r "$threads" \
        -b "$buffer" \
        -u "$buckets" \
        -s "$stripe" \
        -t "$temp_dir" \
        -d "$plot_dir" > "$log_file" 2>&1

    echo "Completed k=$k. Log saved to $log_file."
}

# Run chia plotter for k values from 25 to 35
for k in {25..35}; do
    run_plotter "$k"
done

echo "All k values completed. Logs saved to $log_dir."
