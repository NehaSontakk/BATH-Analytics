#!/bin/bash
#SBATCH --job-name=bathsearch_parallel
#SBATCH --output=bathsearch_parallel_%j.out
#SBATCH --mem-per-cpu=4GB
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=32:00:00
#SBATCH --account=twheeler
#SBATCH --partition=standard

echo "Process started at $(date)"

# Path to the DNA input file
input_file="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/bin.82.fa.fna"
####

# TANTAN
# Path to the Tantan executable
tantan_exec="/xdisk/twheeler/nsontakke/Software/tantan-49/bin/tantan"

# Output file after Tantan masking for DNA
masked_dna_file="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/bin.82.masked.fa.fna"

# Run Tantan for masking DNA
${tantan_exec} -x N ${input_file} > ${masked_dna_file}

# Specify Tantan input directory
tantan_input_dir="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/kingdom"

# Output directory for masked protein files
masked_protein_dir="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/masked_proteins"
mkdir -p ${masked_protein_dir}

# Running Tantan for Bacteria sprot file
${tantan_exec} -p -x X ${tantan_input_dir}/Bacteria/sprot > ${masked_protein_dir}/Bacteria/sprot.masked
# Running Tantan for Archea sprot file
${tantan_exec} -p -x X ${tantan_input_dir}/Archaea/sprot > ${masked_protein_dir}/Archaea/sprot.masked
# Running Tantan for Virus sprot file
${tantan_exec} -p -x X ${tantan_input_dir}/Viruses/sprot > ${masked_protein_dir}/Viruses/sprot.masked
# Running Tantan for Mitochondria sprot file
${tantan_exec} -p -x X ${tantan_input_dir}/Mitochondria/sprot > ${masked_protein_dir}/Mitochondria/sprot.masked
# Running Tantan for IS file
${tantan_exec} -p -x X ${tantan_input_dir}/Bacteria/IS > ${masked_protein_dir}/Bacteria/IS.masked
# Running Tantan for AMR file
${tantan_exec} -p -x X ${tantan_input_dir}/Bacteria/AMR > ${masked_protein_dir}/Bacteria/AMR.masked
echo "Tantan for DNA completed at $(date)"

####

#BATH SEARCH
# Path to bathsearch executable
bathsearch_exec="/home/u13/nsontakke/BATH/src/bathsearch"
# Create a new directory for output files
output_main_dir="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Output_Bathsearch"
mkdir -p ${output_main_dir}

#Run bacteria
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_kingdom_sprot.out ${masked_protein_dir}/Bacteria/sprot.masked ${masked_dna_file} &
echo "Bathsearch for Bacteria completed at $(date)" &
#Run archea
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Archaea_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Archaea_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Archaea_kingdom_sprot.out ${masked_protein_dir}/Archaea/sprot.masked ${masked_dna_file} &
echo "Bathsearch for Archaea completed at $(date)" &
#Run HAMAP
${bathsearch_exec} -o ${output_main_dir}/HAMAP_bath_bin82.out --tblout ${output_main_dir}/HAMAP_bath_bin82.tbl /xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/HAMAP_ALL.bhmm ${masked_dna_file} &
echo "Bathsearch for HAMAP completed at $(date)" &
# Run on Bacteria/IS
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_IS_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_IS_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_IS_sprot.out ${masked_protein_dir}/Bacteria/IS.masked ${masked_dna_file} &
echo "Bathsearch for Bacteria/IS completed at $(date)" &
# Run on Bacteria/AMR
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_AMR_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_AMR_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_AMR_sprot.out ${masked_protein_dir}/Bacteria/AMR.masked ${masked_dna_file} &
echo "Bathsearch for Bacteria/AMR completed at $(date)" &
# Run viral commands with codon tables 1 and 11
for ct in 1 11; do
    hmmout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.out"
    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} ${masked_protein_dir}/Viruses/sprot.masked ${masked_dna_file} &
done
echo "Bathsearch for Virus completed at $(date)" &
# Run bathsearch for each mitochondrial codon table
declare -a codon_tables=(2 3 4 5 9 13 14 16 21 22 23 24 25)
for ct in "${codon_tables[@]}"; do
    hmmout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.out"
    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} ${masked_protein_dir}/Mitochondria/sprot.masked ${masked_dna_file} &
done
echo "Bathsearch for Mitochnodria completed at $(date)" &
wait
