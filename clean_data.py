import pandas as pd

# Load the combined CSV data
file_path = "data/rpi5/chia-param-C0-NVME.csv"
data = pd.read_csv(file_path)

# Filter rows where Total_Time is less than 1010
filtered_data = data[data['Total_Time'] < 1010]

# Save the filtered data to a new CSV file
output_file = "data/rpi5/filtered_data_below_1010.csv"
filtered_data.to_csv(output_file, index=False)

print(f"Filtered data saved to {output_file}. Rows with Total_Time < 1010: {len(filtered_data)}")
