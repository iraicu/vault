#!/bin/bash

DISK=/dev/nvme4n1

# Synchronize filesystem buffers
sudo sync

# Drop all caches
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
sudo blockdev --flushbufs $DISK
sudo hdparm -F $DISK
# Display memory usage
free -h
