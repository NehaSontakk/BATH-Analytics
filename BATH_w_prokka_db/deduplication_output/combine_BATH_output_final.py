import re
import pandas as pd

file_names = [
    "DNA_Archaea_kingdom_sprot_deduplicated.tbl",
    "DNA_Bacteria_kingdom_sprot_deduplicated.tbl",
    "DNA_Mitochondria_kingdom_sprot_ctcombined_deduplicated.tbl",
    "DNA_Viruses_kingdom_sprot_ctcombined_sorted_data_deduplicated.tbl",
    "DNA_Mitochondria_kingdom_sprot_ctcombined_sorted_data_deduplicated.tbl",
    "HAMAP_bath_bin82_deduplicated.tbl"
]


# Function to read a .tbl file into a DataFrame, handling rows with different numbers of columns
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
        # Optionally handle rows with different number of columns here
        # e.g., by padding with None or trimming excess fields

    return pd.DataFrame(data, columns=header)

# Reading each file into a DataFrame and storing them in a list
dataframes = [read_tbl_file_adjusted(path) for path in file_names]

# Concatenating all DataFrames into one
combined_df = pd.concat(dataframes, ignore_index=True)

# Display the first few rows of the combined DataFrame
print(combined_df.shape)

combined_df.to_csv("BATH_output_combined.csv",sep=",")
combined_df.to_csv("BATH_output_combined.tbl", sep="\t", index=False)



