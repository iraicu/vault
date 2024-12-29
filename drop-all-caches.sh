#!/bin/bash

# Unified cache-dropping script

# Default disk configuration
DISK="/dev/nvme0n1"

# Machine-specific configurations
case $(hostname) in
    "epycbox")
        DISK="/dev/sdl"
        ;;
    "orangepi5plus")
        DISK="/dev/nvme0n1"
        ;;
    "raspberrypi5")
	DISK="/dev/sda"
	;;
    *)
        echo "Unknown machine. Using default disk configuration: $DISK"
        ;;
esac

# Synchronize filesystem buffers
sudo sync

# Drop all caches
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
sudo blockdev --flushbufs $DISK

if [ "$DISK" = "/dev/nvme0n1" ]; then
    for disk in /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sdf1 /dev/sdh1 /dev/sdj1 /dev/sdl1 /dev/sdm1 /dev/sdn1 /dev/sdp1; do
	sudo hdparm -F $disk
    done
else
    sudo hdparm -F $DISK
fi
