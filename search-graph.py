import pandas as pd
import matplotlib.pyplot as plt
import os

# Directory containing the data files (organized by machine)
data_dir = "data"  # Change this to the path where your data files are stored
output_dir = "graphs"  # Directory to save the graphs
os.makedirs(output_dir, exist_ok=True)

# Function to create bar plot for NVMe and HDD separately
def create_bar_plot(data, machine_name, disk_type):
    # Filter data for the selected disk type (NVMe or HDD)
    disk_data = data[data['Type'] == disk_type]

    # Set up k-values and hash sizes
    k_values = sorted(disk_data['K'].unique())  # Unique K values
    hash_sizes = sorted(disk_data['Hash_Size'].unique())  # Unique Hash Sizes

    bar_width = 1.0 / (len(hash_sizes) + 1)  # Bar width adjusted based on number of hash_sizes
    x_positions = range(len(k_values))  # X positions for K values

    # Create a figure for the bar plot
    plt.figure(figsize=(12, 6))

    # Plot the bar graph for each hash_size and corresponding lookup time
    for i, hash_size in enumerate(hash_sizes):
        # Filter data for each hash_size
        lookup_times = disk_data[disk_data['Hash_Size'] == hash_size]

        # Calculate the offset for each hash_size so that the bars are next to each other
        offset = i * bar_width  # Adjust offset to make bars next to each other

        # Plot bars for lookup times for each k-value and hash_size
        plt.bar([x + offset for x in x_positions], lookup_times['Average_Lookup_Time_ms'], 
                width=bar_width, label=f'Hash_Size {hash_size}', alpha=0.8)

    # Set up the graph labels and title
    plt.title(f'{disk_type} Lookup Time - {machine_name}', fontsize=14)
    plt.xlabel('K-Value', fontsize=12)
    plt.ylabel('Average Lookup Time (ms)', fontsize=12)

    # Set the x-ticks to be at the center of the bars
    plt.xticks(x_positions, k_values)
    plt.legend()

    # Save the graph in the output directory
    output_path = os.path.join(output_dir, f"{machine_name}/search-C0-{disk_type}.svg")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)  # Ensure machine directory exists
    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()

# Process each machine's data directory
for machine_name in os.listdir(data_dir):
    machine_path = os.path.join(data_dir, machine_name)
    if os.path.isdir(machine_path):
        hdd_file = os.path.join(machine_path, "search-C0-HDD.csv")
        nvme_file = os.path.join(machine_path, "search-C0-NVMe.csv")

        if not (os.path.exists(hdd_file) and os.path.exists(nvme_file)):
            print(f"Skipping {machine_name}: Missing NVMe or HDD file.")
            continue

        # Read NVMe and HDD CSV files
        hdd_data = pd.read_csv(hdd_file)
        hdd_data['Type'] = 'HDD'
        nvme_data = pd.read_csv(nvme_file)
        nvme_data['Type'] = 'NVMe'

        # Combine data
        combined_data = pd.concat([hdd_data, nvme_data], ignore_index=True)

        # Create separate graphs for NVMe and HDD
        create_bar_plot(combined_data, machine_name, 'NVMe')
        create_bar_plot(combined_data, machine_name, 'HDD')

print(f"Graphs saved in directory: {output_dir}")
