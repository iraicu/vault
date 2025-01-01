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
            plot_dir="/data-l/varvara/plot"
        elif [ "$DISK_TYPE" == "NVME" ]; then
            temp_dir="/data-fast/varvara/tmp"
            plot_dir="/data-fast/varvara/plot"
        else
            echo "Invalid disk type for epycbox. Use 'HDD' or 'NVME'."
            exit 1
        fi
        output_dir="data/epycbox"
        threads_list=(1 2 4 8 16 32 64)
        buffer_range=(512 1024 2048 4096 8192 16384 32768 65536 131072 262144)
        bucket_range=(16 32 64 128 256 512 1024)
        stripe_min=32768
        stripe_max=131072
        max_threads=64
        ram=262144
        ;;

    "orangepi5plus")
        # Configuration for orange pi 5
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
        output_dir="data/opi5"
        threads_list=(1 2 4 8)
        buffer_range=(512 1024 2048 4096 8192 16384)
        bucket_range=(16 32 64 128 256)
        stripe_min=32768
        stripe_max=65536
        max_threads=32
        ram=16384
        ;;

    "raspberrypi5")
        # Configuration for raspberry pi 5
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
        output_dir="data/rpi5"
        threads_list=(1 2 4)
        buffer_range=(512 1024 2048 4096)
        bucket_range=(16 32 64 128 256)
        stripe_min=16384
        stripe_max=32768
        max_threads=16
        ram=8192
        ;;

    *)
        # Default configuration for unknown machines
        echo "Unknown machine. Using default configuration."
        output_dir="data/default"
        threads_list=(4 8 16 32)
        buffer_range=(8192 16384 32768)
        bucket_range=(16 32 64 128 256)
        stripe_min=32768
        stripe_max=65536
        temp_dir="/mnt/default_temp"
        ;;

esac

# Set the output file name
output_file="$output_dir/chia-param-C0-$DISK_TYPE.csv"

# Set the constant k
k=27

# Initialize the log file with headers
echo "Threads,Buffer,Buckets,Stripe,Temp_Dir,Plot_Dir,Phase_1_Time,Phase_2_Time,Phase_3_Time,Phase_4_Time,Total_Time" > $output_file

# Function to run a single test
run_test() {
    local threads=$1
    local buffer=$2
    local buckets=$3
    local stripe=$4

    log_file="chia_plot_$threads_$buffer_$buckets_$stripe.log"
    chia plotters chiapos --override-k -k $k -r $threads -b $buffer -u $buckets -s $stripe -t $temp_dir -d $plot_dir > "$log_file" 2>&1

    # Extract times from log
    phase_1_time=$(grep "Time for phase 1" "$log_file" | awk '{print $6}')
    phase_2_time=$(grep "Time for phase 2" "$log_file" | awk '{print $6}')
    phase_3_time=$(grep "Time for phase 3" "$log_file" | awk '{print $6}')
    phase_4_time=$(grep "Time for phase 4" "$log_file" | awk '{print $6}')
    total_time=$(grep "Total time" "$log_file" | awk '{print $4}')

    echo "$threads,$buffer,$buckets,$stripe,$temp_dir,$plot_dir,$phase_1_time,$phase_2_time,$phase_3_time,$phase_4_time,$total_time" >> $output_file
}

# Test combinations of all parameters
for threads in "${threads_list[@]}"; do
    for buffer in "${buffer_range[@]}"; do
        for buckets in "${bucket_range[@]}"; do
            for stripe in $(seq $stripe_min $stripe_max $((stripe_max / 2))); do
                echo "Testing: Threads=$threads, Buffer=$buffer, Buckets=$buckets, Stripe=$stripe"
                run_test $threads $buffer $buckets $stripe
            done
        done
    done
done

echo "Parameter sweep completed. Results saved to $output_file."
