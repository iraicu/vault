import pandas as pd
import matplotlib.pyplot as plt
import os

# Directory containing the data files (organized by machine)
data_dir = "data"  # Change this to the path where your data files are stored
output_dir = "graphs"  # Directory to save the graphs
os.makedirs(output_dir, exist_ok=True)

# Function to create bar graph for a single machine
def create_bar_graph(data, machine_name):
    plt.figure(figsize=(10, 6))

    # Extract NVMe and HDD data
    nvme_data = data[data['Type'] == 'NVMe']
    hdd_data = data[data['Type'] == 'HDD']

    # Set up x-axis (k-values)
    k_values = nvme_data['K'].values
    nvme_totals = nvme_data['TOTAL'].values
    hdd_totals = hdd_data['TOTAL'].values

    # Bar width and positions
    bar_width = 0.35
    x_positions = range(len(k_values))

    # Plot NVMe and HDD bars with less bright colors
    plt.bar(x_positions, nvme_totals, width=bar_width, label='NVMe', color='blue', alpha=0.7)  # Less bright blue
    plt.bar([x + bar_width for x in x_positions], hdd_totals, width=bar_width, label='HDD', color='orange', alpha=0.7)  # Less bright orange

    # Add labels and title
    plt.xlabel('K-Value', fontsize=12)
    plt.ylabel('Total Time (s)', fontsize=12)
    plt.title(f'Total Time for NVMe and HDD - {machine_name}', fontsize=14)
    plt.xticks([x + bar_width / 2 for x in x_positions], k_values)
    plt.legend()

    # Save graph to output directory
    plt.tight_layout()
    output_path = os.path.join(output_dir, f"{machine_name}.svg")
    plt.savefig(output_path)
    plt.close()

# Process each machine's data directory
for machine_name in os.listdir(data_dir):
    machine_path = os.path.join(data_dir, machine_name)
    if os.path.isdir(machine_path):
        nvme_file = os.path.join(machine_path, "log-C0-NVMe.csv")
        hdd_file = os.path.join(machine_path, "log-C0-HDD.csv")

        if not (os.path.exists(nvme_file) and os.path.exists(hdd_file)):
            print(f"Skipping {machine_name}: Missing NVMe or HDD file.")
            continue

        # Read NVMe and HDD CSV files
        nvme_data = pd.read_csv(nvme_file)
        nvme_data['Type'] = 'NVMe'
        hdd_data = pd.read_csv(hdd_file)
        hdd_data['Type'] = 'HDD'

        # Combine data
        combined_data = pd.concat([nvme_data, hdd_data], ignore_index=True)

        # Create graph for this machine
        create_bar_graph(combined_data, machine_name)

print(f"Graphs saved in directory: {output_dir}")
