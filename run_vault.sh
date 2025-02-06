#!/bin/bash

# Unified script to run vault tests on different machines

# Default values (modifiable for specific systems)
OUTPUT_FILE="output.csv"
RAM=262144
HASH_THREADS=8
SORT_THREADS=128
IO_THREADS=8
MAKE_TARGET="vault_x86"
CACHE_DROP_SCRIPT="./drop-all-caches.sh"

# Check for user argument (HDD or NVME)
if [ -z "$1" ]; then
    echo "Usage: $0 <HDD|NVME>"
    exit 1
fi

DISK_TYPE=$1

# Set IO_THREADS and OUTPUT_FILE based on the disk type
if [ "$DISK_TYPE" == "HDD" ]; then
    IO_THREADS=1
    OUTPUT_FILE="log-C0-HDD.csv"
elif [ "$DISK_TYPE" == "NVME" ]; then
    IO_THREADS=8
    OUTPUT_FILE="log-C0-NVMe.csv"
else
    echo "Invalid disk type. Use 'HDD' or 'NVME'."
    exit 1
fi


# Machine-specific configurations
case $(hostname) in
    "eightsocket")
        OUTPUT_DIR="data/8socket"
        RAM=262144
        HASH_THREADS=8
        SORT_THREADS=128
        IO_THREADS=8
        MAKE_TARGET="vault_x86"
        ;;
    "epycbox")
        OUTPUT_DIR="data/epycbox"
        RAM=131072
        HASH_THREADS=8
        SORT_THREADS=32
        IO_THREADS=64
        MAKE_TARGET="vault_x86"
	if [ "$DISK_TYPE" == "HDD" ]; then
	   IO_THREADS=64
	   OUTPUT_FILE="log-C0-HDD.csv"
	elif [ "$DISK_TYPE" == "NVME" ]; then
    	   IO_THREADS=8
    	   OUTPUT_FILE="log-C0-NVMe.csv"
	else
    	   echo "Invalid disk type. Use 'HDD' or 'NVME'."
	   exit 1
	fi
        ;;
    "raspberrypi5")
        OUTPUT_DIR="data/rpi5"
        RAM=4096
        HASH_THREADS=4
        SORT_THREADS=4
        IO_THREADS=1
        MAKE_TARGET="vault_arm"
        ;;
    "orangepi5plus")
        OUTPUT_DIR="data/opi5"
        RAM=16384
        HASH_THREADS=8
        SORT_THREADS=8
        IO_THREADS=1
        MAKE_TARGET="vault_arm"
        ;;
    *)
        echo "Unknown machine. Using default configuration."
        ;;
esac

# Final output file path
OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_FILE"

# Create output file and write header
echo "K,RAM,HASH,SORT,FLUSH,COMPRESS,TOTAL" > $OUTPUT_FILE

# Function to build and run tests
run_tests() {
    local nonce_size=$1
    local k_start=$2
    local k_end=$3

    make clean
    make $MAKE_TARGET NONCE_SIZE=$nonce_size RECORD_SIZE=32

    for k in $(seq $k_start $k_end)
    do
        $CACHE_DROP_SCRIPT
        output=$(./vault -t $HASH_THREADS -o $SORT_THREADS -i $IO_THREADS -f vault$k.memo -m $RAM -k $k -w true)
        echo "$k,$RAM,$output" >> $OUTPUT_FILE
    done
}

# Run tests for NONCE_SIZE=4
run_tests 4 25 32

# Run tests for NONCE_SIZE=5
run_tests 5 33 35

echo "Tests completed. Results saved to $OUTPUT_FILE."
