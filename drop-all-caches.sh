#!/bin/bash

<<<<<<< HEAD
DISK=/dev/nvme0n1
=======
#DISK=/dev/sdl
>>>>>>> 732e0d80f19bb3b3f116ef97f1cc9a879ad69670

# Synchronize filesystem buffers
sudo sync

# Drop all caches
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
sudo blockdev --flushbufs /dev/md2
for disk in /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1 /dev/sdf1 /dev/sdh1 /dev/sdj1 /dev/sdl1 /dev/sdm1 /dev/sdn1 /dev/sdp1; do
    sudo hdparm -F $disk
done

# Display memory usage
free -h
