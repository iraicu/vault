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
        # Configuration for epycbox machine
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-l/varvara/tmp"
            secondary_temp_dir="/data-l/varvara/tmp2"
            plot_dir="/data-l/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            secondary_temp_dir="/data-fast/varvara/tmp2"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for epycbox. Use 'HDD' or 'NVME'."
            exit 1
        fi
        output_dir="data/epycbox"
        threads_list=(1 2 4 8 16 32 64)
        memory_list=(512 1024 2048 4096 8192 16384 32768 65536 131072 262144)
        buckets_list=(64 128 256)
        build="chia_x86"
        ;;
    "orangepi5plus")
        # Configuration for orange pi 5
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-a/varvara/tmp"
            secondary_temp_dir="/data-a/varvara/tmp2"
            plot_dir="/data-a/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            secondary_temp_dir="/data-fast/varvara/tmp2"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for orangepi5plus. Use 'HDD' or 'NVME'."
            exit 1
        fi
        output_dir="data/opi5"
        threads_list=(1 2 4 8)
        memory_list=(512 1024 2048 4096 8192 16384)
        buckets_list=(64 128)
        build="chia_arm"
        ;;
    "raspberrypi5")
        # Configuration for raspberry pi 5
        if [ "$DISK_TYPE" == "HDD" ]; then
            temp_dir="/data-a/varvara/tmp"
            secondary_temp_dir="/data-a/varvara/tmp2"
            plot_dir="/data-a/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            secondary_temp_dir="/data-fast/varvara/tmp2"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for raspberrypi5. Use 'HDD' or 'NVME'."
            exit 1
        fi
        output_dir="data/rpi5"
        threads_list=(1 2 4)
        memory_list=(512 1024 2048 4096)
        buckets_list=(64 128)
        build="chia_arm"
        ;;
    *)
        # Default configuration for unknown machines
        echo "Unknown machine. Using default configuration."
        output_dir="data/default"
        threads_list=(4 8 16 32)
        memory_list=(8192 16384 32768)
        buckets_list=(64 128 256)
        temp_dir="/mnt/default_temp"
        secondary_temp_dir="/mnt/default_secondary"
        build="chia_x86"
        ;;
esac

# Set the output file name
output_file="$output_dir/chia-param-C0-$DISK_TYPE.csv"

# Set the constant k
k=27

# Initialize the log file with headers
echo "Threads,Memory,Buckets,Temp_Dir,Secondary_Temp_Dir,Plot_Dir,Elapsed_Time" > $output_file

# Function to run a single test
run_test() {
    local threads=$1
    local memory=$2
    local buckets=$3

    start_time=$(date +%s)
    chia plots create -k $k -r $threads -b $memory -u $buckets -t $temp_dir -2 $secondary_temp_dir -d $plot_dir -n 1
    end_time=$(date +%s)
    
    elapsed_time=$((end_time - start_time))
    echo "$threads,$memory,$buckets,$temp_dir,$secondary_temp_dir,$elapsed_time" >> $output_file
}

# Iterate through parameter combinations and run the tests
for threads in "${threads_list[@]}"; do
    for memory in "${memory_list[@]}"; do
        for buckets in "${buckets_list[@]}"; do
            echo "Testing: Threads=$threads, Memory=$memory, Buckets=$buckets, Temp=$temp_dir, Secondary_Temp=$secondary_temp_dir"
            run_test $threads $memory $buckets
        done
    done
done

echo "Parameter sweep completed. Results saved to $output_file."