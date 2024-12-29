#!/bin/bash

# Check for user argument (HDD or NVME)
if [ -z "$1" ]; then
    echo "Usage: $0 <HDD|NVME>"
    exit 1
fi

DISK_TYPE=$1

# Set IO_THREADS based on the disk type
if [ "$DISK_TYPE" == "HDD" ]; then
    io_threads=1
    output_file_suffix="param-C0-HDD.csv"
elif [ "$DISK_TYPE" == "NVME" ]; then
    io_threads=8
    output_file_suffix="param-C0-NVMe.csv"
else
    echo "Invalid disk type. Use 'HDD' or 'NVME'."
    exit 1
fi

# Machine-specific configurations
case $(hostname) in
    "epycbox")
        output_dir="data/epycbox"
        hash_threads=8
        sort_threads=64
        max_threads=64
        ram=262144
        io_threads=$([ "$DISK_TYPE" == "HDD" ] && echo 1 || echo 8)
        build="vault_x86"
        ;;
    "orangepi5plus")
        output_dir="data/opi5"
        hash_threads=8
        sort_threads=8
        max_threads=8
        ram=16384
        io_threads=$([ "$DISK_TYPE" == "HDD" ] && echo 1 || echo 8)
        build="vault_arm"
        ;;
    "raspberrypi5")
        output_dir="data/rpi5"
        hash_threads=4
        sort_threads=4
        max_threads=4
        ram=4096
        io_threads=$([ "$DISK_TYPE" == "HDD" ] && echo 1 || echo 4) # NVME defaults to 4 here
        build="vault_arm"
        ;;
    *)
        echo "Unknown machine. Using default configuration."
        output_dir="data/default"
        hash_threads=64
        sort_threads=64
        max_threads=64
        ram=262144
        io_threads=$([ "$DISK_TYPE" == "HDD" ] && echo 1 || echo 8)
        build="vault_x86"
        ;;
esac

# Set the output file name based on disk type
output_file_suffix=$([ "$DISK_TYPE" == "HDD" ] && echo "param-C0-HDD.csv" || echo "param-C0-NVMe.csv")
output_file="$output_dir/$output_file_suffix"

# Set the constant `k`
k=32

echo "Hash_threads,Sort_threads,IO_threads,RAM,HASH,SORT,FLUSH,COMPRESS,TOTAL" > $output_file

make clean
make $build NONCE_SIZE=4 RECORD_SIZE=32

# Function to run tests for a specific parameter
run_tests() {
    local param_name=$1
    local values=$2

    for value in $values
    do
        if [ $value -gt $max_threads ]; then
            break
        fi

        ./drop-all-caches.sh

        case $param_name in
            "hash_threads")
                output=$(./vault -t $value -o $sort_threads -i $io_threads -m $ram -k $k -f vault$k.memo -w true)
                echo "$value,$sort_threads,$io_threads,$ram,$output" >> $output_file
                ;;
            "sort_threads")
                output=$(./vault -t $hash_threads -o $value -i $io_threads -m $ram -k $k -f vault$k.memo -w true)
                echo "$hash_threads,$value,$io_threads,$ram,$output" >> $output_file
                ;;
            "io_threads")
                output=$(./vault -t $hash_threads -o $sort_threads -i $value -m $ram -k $k -f vault$k.memo -w true)
                echo "$hash_threads,$sort_threads,$value,$ram,$output" >> $output_file
                ;;
            "ram")
                if [ $value -gt $ram ]; then
                    continue
                fi
                output=$(./vault -t $hash_threads -o $sort_threads -i $io_threads -m $value -k $k -f vault$k.memo -w true)
                echo "$hash_threads,$sort_threads,$io_threads,$value,$output" >> $output_file
                ;;
        esac
    done
}

# Run tests for each parameter
run_tests "hash_threads" "2 4 8 16 32 64"
run_tests "sort_threads" "1 2 4 8 16 32 64"
run_tests "io_threads" "1 2 4 8 16 32 64"
run_tests "ram" "512 1024 2048 4096 8192 16384 32768 65536 131072 262144"

echo "Parameter tests completed. Results saved to $output_file."

