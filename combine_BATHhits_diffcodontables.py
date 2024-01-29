import os
import re

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()
    
def process_file_data(file_data, ct_number):
    """
    Process the data from a file by adding the ct number to the description of target column.
    :param file_data: List of lines from the file
    :param ct_number: ct number extracted from the file name
    :return: Processed list of lines
    """
    processed_data = []
    for line in file_data:
        if not line.startswith("#") and line.strip():
            # Add the ct number to the description of target column
            parts = line.split()
            parts[-1] += f" ct{ct_number}"
            processed_data.append("\t".join(parts))
        else:
            processed_data.append(line)
    return processed_data


def process_and_combine_files(file_list, directory, output_file):
    """
    Process, combine, sort, and filter files from a given directory, adding the ct number to the description of target column.
    Save the combined data to an output file.
    :param file_list: List of file names
    :param directory: Directory where the files are located
    :param output_file: Path to the output file
    :return: None
    """
    combined_data = []
    for file_name in file_list:
        file_path = os.path.join(directory, file_name)
        if os.path.exists(file_path):
            file_data = read_file(file_path)
            # Extract ct number from file name
            match = re.search(r"ct(\d+)\.tbl", file_name)
            if match:
                ct_number = match.group(1)
                processed_data = process_file_data(file_data, ct_number)
                combined_data.extend(processed_data)
        else:
            print(f"File not found: {file_name}")

    # Sort and filter the data
    sorted_filtered_data = sort_and_filter_data(combined_data)

    # Save the combined, sorted, and filtered data to an output file
    with open(output_file, 'w') as output_file:
        output_file.writelines(sorted_filtered_data)

    print(f"Combined data saved to {output_file}")


# Directory where the files are located
directory = "/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Output_Bathsearch"

# List of file names
file_list_virus = [
    "DNA_Viruses_kingdom_sprot_ct11.tbl",  
    "DNA_Viruses_kingdom_sprot_ct1.tbl",
]

# Output file path
output_file_virus = "/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Output_Bathsearch_Combined/DNA_Viruses_kingdom_sprot_ctcombined.tbl"
# Process, combine, and sort the files, then save to the output file
process_and_combine_files(file_list_virus, directory, output_file_virus)

file_list_mitochondria = ['DNA_Mitochondria_kingdom_sprot_ct13.tbl','DNA_Mitochondria_kingdom_sprot_ct22.tbl','DNA_Mitochondria_kingdom_sprot_ct2.tbl','DNA_Mitochondria_kingdom_sprot_ct9.tbl','DNA_Mitochondria_kingdom_sprot_ct14.tbl','DNA_Mitochondria_kingdom_sprot_ct23.tbl','DNA_Mitochondria_kingdom_sprot_ct3.tbl','DNA_Mitochondria_kingdom_sprot_ct16.tbl','DNA_Mitochondria_kingdom_sprot_ct24.tbl','DNA_Mitochondria_kingdom_sprot_ct4.tbl','DNA_Mitochondria_kingdom_sprot_ct21.tbl','DNA_Mitochondria_kingdom_sprot_ct25.tbl','DNA_Mitochondria_kingdom_sprot_ct5.tbl']

# Output file path
output_file_mito = "/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Output_Bathsearch_Combined/DNA_Mitochondria_kingdom_sprot_ctcombined.tbl"

# Process, combine, and sort the files, then save to the output file
process_and_combine_files(file_list_mitochondria, directory, output_file_mito)

