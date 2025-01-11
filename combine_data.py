import csv

# Input and output file paths
file1 = "data/rpi5/chia-param-C0-NVME.csv"  # Original file
file2 = "data/rpi5/chia-param-C0-NVME-revised.csv"  # Revised file
output_file = "data/rpi5/combined_data.csv"  # Output file

# Function to read CSV data into a list of dictionaries
def read_csv(file_path):
    with open(file_path, "r") as file:
        reader = csv.DictReader(file)
        rows = [row for row in reader]
    return rows, reader.fieldnames

# Read data from both files
data1, headers1 = read_csv(file1)
data2, headers2 = read_csv(file2)

# Ensure both files have the same headers
if headers1 != headers2:
    raise ValueError("The two CSV files have different headers!")

# Combine and sort the data by Threads, Buffer, Buckets, and Stripe
combined_data = data1 + data2
combined_data = sorted(
    combined_data,
    key=lambda row: (
        int(row["Threads"]),
        int(row["Buffer"]),
        int(row["Buckets"]),
        int(row["Stripe"]),
    ),
)

# Write the combined and sorted data to the output file
with open(output_file, "w", newline="") as file:
    writer = csv.DictWriter(file, fieldnames=headers1)
    writer.writeheader()
    writer.writerows(combined_data)

print(f"Combined data saved to {output_file}")
