import csv

# Input and output file paths
input_file = "data/rpi5/chia-param-C0-NVME-revised.csv"  # Replace with your input CSV file path
output_file = "data/rpi5/filtered_data.csv"  # Replace with your desired output CSV file path

# Open the input file for reading and output file for writing
with open(input_file, "r") as infile, open(output_file, "w", newline="") as outfile:
    reader = csv.DictReader(infile)
    writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames)
    
    # Write the header to the output file
    writer.writeheader()
    
    # Process each row
    for row in reader:
        # Check if all time columns are filled
        if all(row[column] for column in ["Phase_1_Time", "Phase_2_Time", "Phase_3_Time", "Phase_4_Time", "Total_Time"]):
            writer.writerow(row)  # Write only rows with complete time data

print(f"Filtered data saved to {output_file}")
