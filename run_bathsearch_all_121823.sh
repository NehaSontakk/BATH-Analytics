#!/bin/bash
#SBATCH --job-name=bathsearch_parallel
#SBATCH --output=bathsearch_parallel_%j.out
#SBATCH --mem-per-cpu=4GB
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=32:00:00
#SBATCH --account=twheeler
#SBATCH --partition=standard

# Path to bathsearch executable
bathsearch_exec="/home/u13/nsontakke/BATH/src/bathsearch"

# Create a new directory for output files
output_main_dir="/xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/output"
#mkdir -p ${output_main_dir}

#Run bacteria
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_kingdom_sprot.out /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Bacteria/sprot /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

#Run archea
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Archaea_kingdom_sprot.fhmm --tblout ${output_main_dir}/DNA_Archaea_kingdom_sprot.tbl -o ${output_main_dir}/DNA_Archaea_kingdom_sprot.out /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Archaea/sprot /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

#Run HAMAP
${bathsearch_exec} -o ${output_main_dir}/HAMAP_bath_bin82.out --tblout ${output_main_dir}/HAMAP_bath_bin82.tbl /xdisk/twheeler/nsontakke/Prokka_db/HAMAP_ALL.bhmm /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

# Run on Bacteria/IS
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_IS_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_IS_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_IS_sprot.out /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Bacteria/IS /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

# Run on Bacteria/AMR
${bathsearch_exec} --ct 11 --hmmout ${output_main_dir}/DNA_Bacteria_AMR_sprot.fhmm --tblout ${output_main_dir}/DNA_Bacteria_AMR_sprot.tbl -o ${output_main_dir}/DNA_Bacteria_AMR_sprot.out /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Bacteria/AMR /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &

# Run viral commands with codon tables 1 and 11
#for ct in 1 11; do
#    hmmout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.fhmm"
#    tblout="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.tbl"
#    output="${output_main_dir}/DNA_Viruses_kingdom_sprot_ct${ct}.out"

#    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Viruses/sprot /home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna &
#done

# Define the path to the input directory
#input_dir="/home/u13/nsontakke/Parkinsons_data/bin_82/bin.82.fa.fna"

# Run bathsearch for each mitochondrial codon table
#declare -a codon_tables=(2 3 4 5 9 13 14 16 21 22 23 24 25)
#for ct in "${codon_tables[@]}"; do
#    hmmout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.fhmm"
#    tblout="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.tbl"
#    output="${output_main_dir}/DNA_Mitochondria_kingdom_sprot_ct${ct}.out"

#    ${bathsearch_exec} --ct ${ct} --hmmout ${hmmout} --tblout ${tblout} -o ${output} /xdisk/twheeler/nsontakke/Prokka_db/BATH_w_prokka_db/kingdom/Mitochondria/sprot ${input_dir} &
#done

# Wait for all background jobs to finish
wait
