#!/bin/bash

# Usage: ./drop-all-caches.sh <HDD|NVME>
if [ -z "$1" ]; then
    echo "Usage: $0 <HDD|NVME>"
    exit 1
fi

DISK_TYPE=$1

# Machine-specific configurations
case $(hostname) in
    "epycbox")
        HDD_DISK="/dev/sdl"
        NVME_DISK="/dev/nvme0n1"
        ;;
    "orangepi5plus")
        HDD_DISK="/dev/sda"
        NVME_DISK="/dev/nvme0n1"
        ;;
    "raspberrypi5")
        HDD_DISK="/dev/sda"
        NVME_DISK="/dev/nvme0n1"
        ;;
    *)
        echo "Unknown machine. Cannot determine disk configuration."
        exit 1
        ;;
esac

# Function to clear HDD caches
clear_hdd_cache() {
    local disk=$1
    echo "Clearing HDD cache for $disk..."
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    sudo blockdev --flushbufs "$disk"
    sudo hdparm -F "$disk"
}

# Function to clear NVMe caches
clear_nvme_cache() {
    local disk=$1
    echo "Clearing NVMe cache for $disk..."
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
    sudo nvme flush "$disk"
}

# Main logic based on disk type
case $DISK_TYPE in
    "HDD")
        if [ -b "$HDD_DISK" ]; then
            clear_hdd_cache "$HDD_DISK"
        else
            echo "Error: HDD device $HDD_DISK not found."
            exit 1
        fi
        ;;
    "NVME")
        if [ -b "$NVME_DISK" ]; then
            clear_nvme_cache "$NVME_DISK"
        else
            echo "Error: NVMe device $NVME_DISK not found."
            exit 1
        fi
        ;;
    *)
        echo "Invalid argument. Use 'HDD' or 'NVME'."
        exit 1
        ;;
esac

echo "Cache clearing completed for $DISK_TYPE."
