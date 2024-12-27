#!/bin/bash

# Unified script for vault search tests

# Default values
CSV_FILE="search.csv"
MAKE_TARGET="vault_x86"
RAM=262144
THREADS=8
OFFSET=64
HASH_SIZES=(3 4 5 6 7 8 16 32)
MEMO_PREFIX="vault"

# Machine-specific configurations
case $(hostname) in
    "epycbox")
        CSV_FILE="search_epycbox.csv"
        MAKE_TARGET="vault_x86"
        RAM=262144
        HASH_THREADS=8
        SORT_THREADS=64
        MEMO_PREFIX="vault"
        ;;
    "orangepi5plus")
        CSV_FILE="search_opi.csv"
        MAKE_TARGET="vault_arm"
        RAM=4096
        HASH_THREADS=4
        SORT_THREADS=4
        MEMO_PREFIX="vaultx"
        ;;
    *)
        echo "Unknown machine. Using default configuration."
        ;;
esac

# Create output file and write header
echo "K,Hash_Size,Average_Lookup_Time_ms" > $CSV_FILE

# Function to run tests
run_tests() {
    local nonce_size=$1
    local k_start=$2
    local k_end=$3

    make clean
    make $MAKE_TARGET NONCE_SIZE=$nonce_size

    for K in $(seq $k_start $k_end)
    do
        ./vault -t $HASH_THREADS -o $SORT_THREADS -i 1 -m $RAM -k $K -f ${MEMO_PREFIX}$K.memo

        for hash_size in "${HASH_SIZES[@]}"
        do
            ./drop-all-caches.sh
            output=$(./vault -f ${MEMO_PREFIX}$K.memo -k $K -c 100 -l $hash_size)

            avg_time=$(echo "$output" | grep -oP 'Time taken: \K\d+\.\d+(?= ms per lookup)')

            if [ -n "$avg_time" ]; then
                echo "$K,$hash_size,$avg_time" >> $CSV_FILE
            else
                echo "Error: Could not extract time for K=$K, Hash_Size=$hash_size" >&2
            fi
        done
    done
}

# Run tests for NONCE_SIZE=4
run_tests 4 25 32

# Run tests for NONCE_SIZE=5
run_tests 5 33 35

echo "Search tests completed. Results saved to $CSV_FILE."

