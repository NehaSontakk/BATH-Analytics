#!/bin/bash

# Define file paths and names
prokka_gff="/home/u13/nsontakke/Parkinsons_data/bin_82/prokka_output/bin_82_prokka_annotation.gff"
bath_csv="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/deduplication_output/BATH_output_combined.csv" # Changed to CSV file
bath_dataset_type="bath_data"  # Replace with the actual dataset type as needed
output_dir="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/bedtool_comparison" # Define your output directory path here
prokka_bed="${output_dir}/bin.82.fa.bed"
bath_bed="${output_dir}/${bath_dataset_type}_bin82.bed"
corrected_bath_bed="${output_dir}/corrected_${bath_dataset_type}_bin82_w_strand.bed"
bath_bed_w_strand="${output_dir}/${bath_dataset_type}_bin82_w_strand.bed"
final_features_output="${output_dir}/${bath_dataset_type}_BATH_prokka_overlap_features.bed"
overlap_output="${output_dir}/${bath_dataset_type}_BATH_prokka_WAO.bed"
unique_features_output="${output_dir}/${bath_dataset_type}_inBATH_notprokka.bed"
unique_features_output_prokka="${output_dir}/${bath_dataset_type}_inprokka_notBATH.bed"

# Ensure gff2bed and bedtools are installed and in PATH
for tool in gff2bed bedtools; do
    command -v "$tool" >/dev/null 2>&1 || { echo >&2 "$tool not installed. Aborting."; exit 1; }
done

# Convert prokka GFF file to BED format
echo "Converting Prokka GFF to BED..."
gff2bed < "$prokka_gff" > "$prokka_bed"

# Convert BATH CSV file to BED format
echo "Converting BATH CSV to BED..."
# Assuming columns 1, 10, and 11 in the CSV correspond to the required fields
# Adjust column indices as necessary
awk -F, 'NR>1 {if ($10 > $11) print $1, $11-1, $10; else print $1, $10-1, $11}' "$bath_csv" > "$bath_bed"

# Additional augmentation of BATH CSV files

# Detect number of genes in the negative strand
echo "Counting genes on the negative strand..."
awk '{if ($2 > $3) print}' "$bath_bed" | wc -l

# Make a strand column
echo "Adding strand information..."
awk 'BEGIN {OFS="\t"} {if ($2 > $3) print $1, $2, $3, "-"; else print $1, $2, $3, "+"}' "$bath_bed" > "$bath_bed_w_strand"

# Change the position of start and end after creating the strand column
echo "Correcting start and end positions..."
awk 'BEGIN {OFS="\t"} {if ($2 > $3) print $1, $3, $2, "-"; else print $1, $2, $3, "+"}' "$bath_bed_w_strand" > "$corrected_bath_bed"

# Finding overlaps and unique features

echo "Finding common features..."
bedtools intersect -a "$corrected_bath_bed" -b "$prokka_bed" -wa -wb > "$final_features_output"

echo "Quantifying overlap..."
bedtools intersect -a "$corrected_bath_bed" -b "$prokka_bed" -wao > "$overlap_output"

echo "Finding unique features in BATH..."
bedtools intersect -a "$corrected_bath_bed" -b "$prokka_bed" -v > "$unique_features_output"

echo "Finding unique features in Prokka..."
bedtools intersect -a "$prokka_bed" -b "$corrected_bath_bed" -v > "$unique_features_output_prokka"

# Cleanup intermediate files
echo "Cleaning up intermediate files..."
rm "$prokka_bed" "$bath_bed" "$bath_bed_w_strand" "$corrected_bath_bed"

echo "Pipeline completed."

