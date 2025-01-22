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
        bucket_range=(16 32 64 128)					# Maximumm bucket is 128, minimum is 16
        stripe_range=(16384 65536 131072 262144)	# No minimum or maximum
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
	max_memory=16384
        buffer_range=(512 1024 2048 4096 8192 16384)
        bucket_range=(64 128)
	stripe_range=(32768 65536 131072 262144)
        max_threads=8
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
        bucket_range=(16 32 64 128)
        stripe_range=(1024 2048 4096 8192 32768 65536 131072 262144)
        max_threads=4
        ram=8192
        ;;

    *)
        # Default configuration for unknown machines
        echo "Unknown machine. Using default configuration."
        output_dir="data/default"
        threads_list=(4 8 16 32)
        buffer_range=(8192 16384 32768)
        bucket_range=(16 32 64 128)
        stripe_min=32768
        stripe_max=65536
        temp_dir="/mnt/default_temp"
        ;;

esac

mkdir -p $temp_dir
mkdir -p $plot_dir

# Set the output file name
output_file="$output_dir/chia-param-C0-$DISK_TYPE.csv"

# Set the constant k
k=27

# Initialize the log file with headers
echo "Threads,Buffer,Buckets,Stripe,Temp_Dir,Plot_Dir,Phase_1_Time,Phase_2_Time,Phase_3_Time,Phase_4_Time,Total_Time" > $output_file

# Function to run a single test
run_test() {
    local threads=$1
    local buffer=16384
    local buckets=128
    local stripe=32768

    ./drop-all-caches.sh $DISK_TYPE

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

for threads in "${threads_list[@]}"; do
    echo "Testing with $threads threads..."
    run_test $threads
done

# threads=2
# buffer=1024
# buckets=128

# Start the loop
# while [ $threads -le ${threads_list[-1]} ]; do
#     while [ $buffer -le $max_memory ]; do
#         for buckets in "${bucket_range[@]}"; do
#             for stripe in "${stripe_range[@]}"; do
#                 echo "Testing: Threads=$threads, Buffer=$buffer, Buckets=$buckets, Stripe=$stripe"
#                 run_test $buffer $buckets $stripe
#             done
#         done
#         buffer=$((buffer * 2))
#     done
#     threads=$((threads * 2))
#     buffer=1024
# done

# Test combinations of all parameters
#for threads in "${threads_list[@]}"; do
#    for buffer in "${buffer_range[@]}"; do
#        for buckets in "${bucket_range[@]}"; do
#            for stripe in "${stripe_range[@]}"; do
#                echo "Testing: Threads=$threads, Buffer=$buffer, Buckets=$buckets, Stripe=$stripe"
#                run_test $threads $buffer $buckets $stripe
#            done
#        done
#    done
#done

echo "Parameter sweep completed. Results saved to $output_file."
