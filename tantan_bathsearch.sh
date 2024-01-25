#!/bin/bash
#SBATCH --job-name=bathsearch_parallel
#SBATCH --output=bathsearch_parallel_%j.out
#SBATCH --mem-per-cpu=4GB
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=32:00:00
#SBATCH --account=twheeler
#SBATCH --partition=standard

# Path to the DNA input file
input_file="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/MAG_Data/bin.82.fa.fna"
####

#Prokka Database Files
# Base directory for protein files
base_protein_dir="/xdisk/twheeler/nsontakke/Prokka_BATH_Comparison_2/Input_Bathsearch/kingdom"
# List of directories containing .sprot files
declare -a protein_dirs=("Bacteria/sprot" "Archaea/sprot" "Bacteria/IS" "Bacteria/AMR" "Viruses/sprot" "Mitochondria/sprot")
####

#TANTAN
# Path to the Tantan executable
tantan_exec="/xdisk/twheeler/nsontakke/Software/tantan-49/bin/tantan"
# Output file after Tantan masking
masked_file="/home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.masked.fa.fna"
# Run Tantan for masking DNA
${tantan_exec} -x N ${input_file} > ${masked_file}

# Run Tantan for masking Protein database files
masked_protein_dir="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/masked_proteins"
mkdir -p ${masked_protein_dir}
# Process each .sprot file in each directory
for dir in "${protein_dirs[@]}"; do
    current_dir="${base_protein_dir}/${dir}"
    masked_dir="${masked_protein_dir}/${dir}"
    mkdir -p ${masked_dir}

    for protein_file in ${current_dir}/*.sprot; do
        if [ -f "$protein_file" ]; then
            masked_file="${masked_dir}/$(basename ${protein_file})"
            ${tantan_exec} -x X ${protein_file} > ${masked_file}
        fi
    done
done

####

#BATH SEARCH
# Path to bathsearch executable
bathsearch_exec="/home/u13/nsontakke/BATH/src/bathsearch"

# Create a new directory for output files
output_main_dir="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/output"
#mkdir -p ${output_main_dir}

#Run bacteria
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_kingdom_sprot.out ${masked_protein_dir}/Bacteria/sprot/${masked_file} ${input_file} &

#Run archea
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Archaea_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Archaea_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Archaea_kingdom_sprot.out ${masked_protein_dir}/Archaea/sprot/${masked_file} ${input_file} &

#!!!!!!!!!!!SOLVE
#Run HAMAP
#${bathsearch_exec} -o ${output_main_dir}/HAMAP_bath_bin82.out --tblout ${output_main_dir}/HAMAP_bath_bin82.tbl ${output_main_dir}/HAMAP_ALL.bhmm /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

# Run on Bacteria/IS
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_IS_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_IS_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_IS_sprot.out ${masked_protein_dir}/Bacteria/IS  &

# Run on Bacteria/AMR
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_AMR_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_AMR_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_AMR_sprot.out /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Bacteria/AMR /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

# Run viral commands with codon tables 1 and 11
for ct in 1 11; do
    hmmout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.out"
    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Viruses/sprot /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &
done


# Run bathsearch for each mitochondrial codon table
declare -a codon_tables=(2 3 4 5 9 13 14 16 21 22 23 24 25)
for ct in "${codon_tables[@]}"; do
    hmmout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.fhmm"
    tblout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.tbl"
    output="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.out"

    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Mitochondria/sprot ${input_dir} &
done

# Wait for all background jobs to finish
wait
