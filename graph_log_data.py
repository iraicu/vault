import os
import pandas as pd
import matplotlib.pyplot as plt

def parse_data(file_path):
    """Parses the log data from a file."""
    with open(file_path, 'r') as file:
        lines = file.readlines()

    data = []
    columns = []
    for line in lines:
        if line.startswith('K,'):  # Header line
            columns = line.strip().split(',')
        elif line.strip():  # Data line
            values = line.strip().split(',')
            if len(values) == len(columns):
                data.append(values)

    df = pd.DataFrame(data, columns=columns)
    for col in df.columns:
        try:
            df[col] = pd.to_numeric(df[col])
        except ValueError:
            pass
    return df

def collect_data(root_dir):
    """Collects data from log files in the given root directory."""
    data = {}

    for system in sorted(os.listdir(root_dir)):
        system_path = os.path.join(root_dir, system)
        if os.path.isdir(system_path):
            data[system] = {}
            for storage in ['HDD', 'NVME']:
                file_name = f"log-C0-{storage}.txt"  # Adjust naming convention if needed
                file_path = os.path.join(system_path, file_name)
                if os.path.isfile(file_path):
                    df = parse_data(file_path)
                    data[system][storage.lower()] = df

    return data

def plot_data(data):
    """Plots the data for each system and storage type as bar plots."""
    for system, storage_data in data.items():
        for storage, df in storage_data.items():
            plt.figure(figsize=(10, 6))

            # Create a bar plot for each metric, excluding 'TOTAL'
            bar_width = 0.2
            indices = range(len(df['K']))
            for i, column in enumerate(['HASH', 'SORT', 'FLUSH']):
                if column in df.columns:
                    plt.bar([x + i * bar_width for x in indices], df[column], width=bar_width, label=column)

            plt.title(f"{system}: ({storage})")
            plt.xlabel("K")
            plt.ylabel("Time (s)")
            plt.xticks([x + (len(['HASH', 'SORT', 'FLUSH']) - 1) / 2 * bar_width for x in indices], df['K'])
            plt.legend()
            plt.grid(axis='y')

            # Save the figure
            output_dir = "output_graphs"
            os.makedirs(output_dir, exist_ok=True)
            plt.savefig(os.path.join(output_dir, f"{system}_{storage}.svg"))
            plt.close()

def main():
    root_dir = "./data"  # Change to your actual root directory
    data = collect_data(root_dir)
    plot_data(data)

if __name__ == "__main__":
    main()
