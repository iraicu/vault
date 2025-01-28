#!/bin/bash

if [ $(hostname) == "eightsocket" ]; then
    MACHINE_NAME="8socket"
else
    MACHINE_NAME=$(hostname)
fi

# Output CSV file
output_file="data/${MACHINE_NAME}/${1}-power-SSD.csv"

# Add headers to CSV file
echo "timestamp,power_reading,program_status" > "$output_file"

# Function to collect power readings every 5 seconds
collect_power_reading() {
    while true; do
        # Get the current timestamp and power reading
        ipmitool_output=$(sudo ipmitool dcmi power reading)

        timestamp=$(echo "$ipmitool_output" | grep "IPMI timestamp" | awk -F"IPMI timestamp: " '{print $2}' | sed 's/^[[:space:]]*//')  # Remove leading spaces
        power=$(echo "$ipmitool_output" | grep "Instantaneous power reading" | awk '{print $4}' | sed 's/Watts//' | sed 's/^[[:space:]]*//')  # Remove leading spaces

        # If power reading is not empty, append to CSV
        if [ ! -z "$power" ] && [ ! -z "$timestamp" ]; then
            echo "$timestamp,$power,$program_status" >> "$output_file"
        fi
        sleep 5
    done
}

# Function to monitor specified program status (e.g., chia or vault)
monitor_program() {
    program_name=$1  # The program name passed as an argument
    program_status="idle"  # Start by assuming the program is idle
    started_note_added=false  # Flag to track if the "started" note has been added

    while true; do
        if pgrep -x "$program_name" > /dev/null; then
            # If the program is running, set status to "running"
            if [ "$program_status" != "running" ]; then
                program_status="running"
                # Add a note to CSV when the program starts running
                if [ "$started_note_added" == false ]; then
                    echo "$(date "+%Y-%m-%d %H:%M:%S"),$program_name_started" >> "$output_file"
                    started_note_added=true  # Set flag to prevent repeated "started" notes
                fi
            fi
        else
            # If the program is not running, set status to "idle"
            if [ "$program_status" != "idle" ]; then
                program_status="idle"
                # Add a note to CSV when the program stops running
                echo "$(date "+%Y-%m-%d %H:%M:%S"),$program_name_stopped" >> "$output_file"
            fi
        fi
        sleep 5  # Check program status every 5 seconds
    done
}

# Check if a program name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <program_name>"
    echo "Example: $0 chia"
    exit 1
fi

# Run the power collection in the background
collect_power_reading &

# Run the program monitoring for the specified program and monitor its status
monitor_program $1 &

# Wait for the program to finish
wait $!

# Add a final note to CSV after the program stops running
echo "$(date "+%Y-%m-%d %H:%M:%S"),$1_stopped" >> "$output_file"

# Kill the background power collection after the program stops running
kill %1

