#!/bin/bash

# Define file paths and names
prokka_gff="/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Prokka_output/bin_82_prokka_annotation.gff"
bath_csv="/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Output_Deduplication/BATH_output_combined.csv" 
bath_dataset_type="bath_data"
output_dir="/xdisk/twheeler/nsontakke/BATH_Prokka_DB/Output_Bedtools"
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

echo "Converting BATH CSV to Enhanced BED..."
enhanced_bed_file="${output_dir}/enhanced_${bath_dataset_type}_bin82.bed"

awk -F, 'NR>1 {
    info = $0; 
    gsub(/,/, ";", info); 
    start = $10 - 1; end = $11; 
    if (start > end) { tmp = start; start = end; end = tmp; } 
    print $2, start, end, "-", info;
}' "$bath_csv" > "$enhanced_bed_file"

if [ -f "$enhanced_bed_file" ]; then
    echo "Enhanced BED file created."
else
    echo "Failed to create Enhanced BED file."
    exit 1
fi


# Detect number of genes in the negative strand
# Counting genes on the negative strand
# This step should use the enhanced or corrected bed file
echo "Counting genes on the negative strand..."
awk '...' "$corrected_enhanced_bed_file" | wc -l

# Make a strand column
echo "Adding strand information..."
awk 'BEGIN {OFS="\t"} {if ($2 > $3) print $1, $2, $3, "-"; else print $1, $2, $3, "+"}' "$bath_bed" > "$bath_bed_w_strand"

echo "Correcting start and end positions in Enhanced BED..."
awk 'BEGIN {OFS="\t"} {if ($2 > $3) print $1, $3, $2, $4, $5; else print $1, $2, $3, $4, $5}' "${output_dir}/enhanced_${bath_dataset_type}_bin82.bed" > "${output_dir}/corrected_enhanced_${bath_dataset_type}_bin82_w_strand.bed"
echo "Start and end positions corrected."
# Finding overlaps and unique features

echo "Finding common features..."
bedtools intersect -a "$corrected_bath_bed" -b "$prokka_bed" -wa -wb > "$final_features_output"

echo "Quantifying overlap..."
bedtools intersect -a "$corrected_bath_bed" -b "$prokka_bed" -wao > "$overlap_output"

# Finding unique features in BATH with all fields from Enhanced BED
echo "Finding unique features in BATH..."
bedtools intersect -a "${output_dir}/corrected_enhanced_${bath_dataset_type}_bin82_w_strand.bed" -b "$prokka_bed" -v -wa > "$unique_features_output"

echo "Finding unique features in Prokka..."
bedtools intersect -a "$prokka_bed" -b "$corrected_bath_bed" -v > "$unique_features_output_prokka"

# Cleanup intermediate files
echo "Cleaning up intermediate files..."
rm "$prokka_bed" "$bath_bed" "$bath_bed_w_strand" "$corrected_bath_bed"

echo "Pipeline completed."

