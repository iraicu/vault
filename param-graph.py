import os
import pandas as pd
import matplotlib.pyplot as plt

# Get the list of machine directories
data_path = "data"
machines = [d for d in os.listdir(data_path) if os.path.isdir(os.path.join(data_path, d))]

# Iterate through each machine and create plots
for machine in machines:
    output_dir = os.path.join("graphs", machine)
    os.makedirs(output_dir, exist_ok=True)  # Create output directory if it doesn't exist

    for drive_type in ["HDD", "NVMe"]:
        file_path = os.path.join(data_path, machine, f"param-C0-{drive_type}.csv")
        if not os.path.exists(file_path):
            continue

        # Read the data
        df = pd.read_csv(file_path)

        # Define plot configurations
        parameters = ["Hash_threads", "Sort_threads", "IO_threads", "RAM"]
        titles = ["Hash Threads", "Sort Threads", "IO Threads", "RAM (MB)"]

        # Create a figure with 4 subplots
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        axes = axes.flatten()

        for idx, (param, title) in enumerate(zip(parameters, titles)):
            ax = axes[idx]

            # Drop rows with missing or invalid data in the parameter column
            if param not in df or "TOTAL" not in df:
                continue  # Skip if required columns are missing
            df_clean = df.dropna(subset=[param, "TOTAL"]).copy()

            # Ensure the parameter column is numeric
            df_clean[param] = pd.to_numeric(df_clean[param], errors='coerce').dropna()

            if df_clean.empty:
                continue  # Skip if no valid data remains after cleaning

            # Map unique x values to categorical indices
            unique_x = sorted(df_clean[param].unique())
            x_indices = range(len(unique_x))

            # Create bar plot
            ax.bar(x_indices, [df_clean[df_clean[param] == x]["TOTAL"].iloc[0] for x in unique_x],
                   color='skyblue', edgecolor='black', width=0.8)

            # Set x-axis ticks and labels
            ax.set_xticks(x_indices)
            ax.set_xticklabels(unique_x)
            ax.set_xlabel(title, fontsize=12)
            ax.set_ylabel("Total Time (sec)", fontsize=12)
            ax.set_title(f"{title} vs Time", fontsize=14)

        # Adjust layout and save the combined plot
        plt.tight_layout()
        output_file = os.path.join(output_dir, f"param-C0-{drive_type}.svg")
        plt.savefig(output_file)
        plt.close()
