#!/bin/bash
#SBATCH --job-name=prokka_deduplication
#SBATCH --output=/path/to/logfile.log
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --mem=1000


FILE_DIR="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/output"

# Set the directory to save the output
OUTPUT_DIR="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/deduplication_output"

# List of filenames to process
FILES=("DNA_Bacteria_kingdom_sprot.tbl" "DNA_Archaea_kingdom_sprot.tbl" "DNA_Viruses_kingdom_sprot_ctcombined_sorted_data.tbl" "DNA_Mitochondria_kingdom_sprot_ctcombined_sorted_data.tbl" "HAMAP_bath_bin82.tbl")

# Loop through each file
for FILE in "${FILES[@]}"; do
    INPUT_FILEPATH="${FILE_DIR}/${FILE}"
    OUTPUT_FILEPATH="${OUTPUT_DIR}/$(basename "${FILE}" .tbl)_deduplicated.tbl"
    OUTPUT_ANALYSIS_FILEPATH="${OUTPUT_DIR}/$(basename "${FILE}" .tbl)_counts.tbl"

    # Run the Python script with the updated file paths
    python /path/to/your/deduplication_of_bath_tbl_output.py "${INPUT_FILEPATH}" "${OUTPUT_FILEPATH}" "${OUTPUT_ANALYSIS_FILEPATH}"
done
