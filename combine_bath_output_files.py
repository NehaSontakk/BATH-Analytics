from glob import glob
import re
import pandas as pd

file_names = [i for i in glob("/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Output_Deduplication/*_deduplicated.tbl")]

# Function to read a .tbl file into a DataFrame
def read_tbl_file_adjusted(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()

    # Extracting the header
    header = lines[0].strip().split("\t")
    num_columns = len(header)

    # Processing the data rows
    data = []
    for line in lines[1:]:
        row = re.split(r'\s+', line.strip())
        if len(row) == num_columns:
            data.append(row)

    return pd.DataFrame(data, columns=header)

# Reading each file into a DataFrame and storing them in a list
dataframes = [read_tbl_file_adjusted(path) for path in file_names]

# Concatenating all DataFrames into one
combined_df = pd.concat(dataframes, ignore_index=True)

print(combined_df.head())

# Convert e-value column to float for comparison
combined_df['E-value'] = combined_df['E-value'].astype(float)

# Group by 'contig name', 'ali from', and 'ali to', then keep the row with the minimum e-value
filtered_df = combined_df.loc[combined_df.groupby(['# target name', 'ali from', 'ali to'])['E-value'].idxmin()]

# Sort within each 'contig name' group by 'ali from'
sorted_df = filtered_df.groupby('# target name', group_keys=False).apply(lambda x: x.sort_values('ali from'))

# Save the sorted DataFrame to CSV and .tbl files
sorted_df.to_csv("/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Output_Deduplication/BATH_output_combined.csv", sep=",", index=False)
sorted_df.to_csv("/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Output_Deduplication/BATH_output_combined.tbl", sep="\t", index=False)

