import pandas as pd
import os

# List of file names
file_names = [
    "DNA_Archaea_kingdom_sprot_counts.tbl",
    "DNA_Bacteria_kingdom_sprot_counts.tbl",
    "DNA_Mitochondria_kingdom_sprot_ctcombined_sorted_data_counts.tbl",
    "DNA_Viruses_kingdom_sprot_ctcombined_sorted_data_counts.tbl",
    "HAMAP_bath_bin82_counts.tbl"
]

# Directory where files are located
file_dir = "/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/deduplication_output"  # Update with the actual directory path

# Combined dataframe
combined_df = pd.DataFrame()

# Process each file
for file_name in file_names:
    # Construct full file path
    file_path = os.path.join(file_dir, file_name)

    # Read the file into a dataframe
    df = pd.read_csv(file_path, sep='\t')  # Assuming tab-separated values

    # Get the last two columns
    last_two_columns = df.iloc[:, -2:]

    # Add a prefix to column names
    prefix = file_name.split('.')[0]  # Adjust the splitting logic as needed
    last_two_columns.columns = [f"{prefix}_{col}" for col in last_two_columns.columns]

    # Concatenate with the combined dataframe
    if combined_df.empty:
        combined_df = last_two_columns.copy()
    else:
        combined_df = pd.concat([combined_df, last_two_columns], axis=1)

# Save the combined dataframe to a new file
output_file = "combined_counts_table.tbl"  # Update with desired output path
combined_df.to_csv(output_file, sep='\t', index=False)

print(f"Combined table saved to: {output_file}")
