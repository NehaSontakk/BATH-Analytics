import sys
import json

if len(sys.argv) < 5:
    print("Usage: python script.py <e_value_cutoff> <input_filepath> <output_filepath> <output_analysis_filepath>")
    sys.exit(1)

input_filepath = sys.argv[1]
e_value_cutoff_str = sys.argv[2]
output_filepath = sys.argv[3]
output_filepath_analysis = sys.argv[4]

if e_value_cutoff_str.lower() != 'none':
    e_value_cutoff = float(e_value_cutoff_str)
else:
    e_value_cutoff = None

def compare_contig_names(original_contigs, positive_strand, negative_strand):
    # Create sets of contig names for easier comparison
    original_contig_names = set(original_contigs.keys())
    positive_strand_names = set(positive_strand.keys())
    negative_strand_names = set(negative_strand.keys())

    # Check for contig names present in all dictionaries
    in_all_three = original_contig_names.intersection(positive_strand_names, negative_strand_names)

    # Print results
    print("Contig names in all three dictionaries:")
    print(len(in_all_three))
    for contig_name in in_all_three:
        print(contig_name)

    # Additional information: contig names unique to each dictionary
    unique_to_original = original_contig_names - (positive_strand_names.union(negative_strand_names))
    unique_to_positive = positive_strand_names - (negative_strand_names)
    unique_to_negative = negative_strand_names - (positive_strand_names)

    if unique_to_original:
        print("\nContig names unique to original contigs:")
        for contig_name in unique_to_original:
            print(contig_name)
            print(len(contig_name))

    if unique_to_positive:
        print("\nContig names unique to positive strand (not neg):")
        print(len(unique_to_positive))
        for contig_name in unique_to_positive:
            print(contig_name)

    if unique_to_negative:
        print("\nContig names unique to negative strand (not pos):")
        print(len(unique_to_negative))
        for contig_name in unique_to_negative:
            print(contig_name)

def count_total_entries(contigs):
    total_entries = 0
    for target_name in contigs:
        total_entries += len(contigs[target_name])
    return total_entries

def process_file(filepath, e_value_cutoff=None):
    contigs = {}
    header_lines = []
    count = 0

    with open(filepath, 'r') as file:
        lines = file.readlines()

    header_lines = [line for line in lines if line.startswith('#')]
    data_lines = [line for line in lines if not line.startswith('#') and line.strip()]

    for line in data_lines:
        count += 1
        parts = line.split()

        if len(parts) < 18:
            continue

        target_name = parts[0]
        ali_from = int(parts[8])
        ali_to = int(parts[9])
        e_value = float(parts[12])

        # Check if the e-value is below the cutoff (if specified) before adding
        if e_value <= e_value_cutoff:
            if target_name not in contigs:
                contigs[target_name] = []

            contigs[target_name].append({
                'ali_from': ali_from,
                'ali_to': ali_to,
                'e_value': e_value,
                'full_line': line.strip()
            })

    # Sorting each contig's entries
    for target_name in contigs:
        contigs[target_name] = sorted(contigs[target_name], key=lambda x: (x['ali_from']))
        for i in contigs[target_name]:
          print(i)

    
    # Sorting contigs by name
    contigs = dict(sorted(contigs.items()))

    print("Original File Length", count)
    print("Contig Length:", len(contigs))
    print("Contig Value Entry Length:", count_total_entries(contigs))
    return contigs, header_lines


def find_pos_neg_strand(contigs):
    positive_strand = {}
    negative_strand = {}

    for target_name in contigs:
        for entry in contigs[target_name]:
            # Assuming positive strand is when 'ali_from' is less than or equal to 'ali_to'
            if entry['ali_from'] <= entry['ali_to']:
                if target_name not in positive_strand:
                    positive_strand[target_name] = []
                positive_strand[target_name].append(entry)
            # Assuming negative strand is when 'ali_from' is greater than 'ali_to'
            else:
                if target_name not in negative_strand:
                    negative_strand[target_name] = []
                negative_strand[target_name].append(entry)

    # Sorting the positive strand by 'ali_from'
    for target_name in positive_strand:
        positive_strand[target_name] = sorted(positive_strand[target_name], key=lambda x: x['ali_from'])

    # Sorting the negative strand by 'ali_to'
    for target_name in negative_strand:
        negative_strand[target_name] = sorted(negative_strand[target_name], key=lambda x: x['ali_to'], reverse=True)

    print('Contigs after Positive, Negative strand division: ', len(positive_strand) + len(negative_strand))
    return positive_strand, negative_strand


def calculate_overlap(start1, end1, start2, end2):
    overlap = max(0, min(end1, end2) - max(start1, start2))
    #print(overlap)
    total_length = min(end1 - start1, end2 - start2)
    #print(total_length)
    return overlap / total_length if total_length > 0 else 0

def calculate_overlap_negative_strand(start1, end1, start2, end2):
    overlap_start = max(end1, end2)
    overlap_end = min(start1, start2)
    overlap = max(0, overlap_end - overlap_start)
    total_length = min(start1 - end1, start2 - end2)

    # Debugging print statements
    #print(f"Comparing intervals: ({end1}, {start1}) and ({end2}, {start2})")
    #print(f"Overlap start: {overlap_start}, Overlap end: {overlap_end}, Overlap: {overlap}, Total length: {total_length}")

    return overlap / total_length if total_length > 0 else 0


def add_entry_to_dict(dictionary, target_name, entry):
    if target_name not in dictionary:
        dictionary[target_name] = []
    dictionary[target_name].append(entry)


def update_alignments(contig_dict, target_name, i, j, overlap_below_70_old_discard, overlap_below_70_updated_add, update_first_alignment):
    align1 = contig_dict[target_name][i]
    align2 = contig_dict[target_name][j]
    updated_alignment = None  # Initialize to None

    if update_first_alignment:
        # Update align1 based on align2's position
        updated_align1 = align1.copy()

        # Adjust the end of align1 if it overlaps with the start of align2
        if align1['ali_to'] >= align2['ali_from']:
            updated_align1['ali_to'] = align2['ali_from'] - 1
            contig_dict[target_name][i] = updated_align1

        updated_alignment = updated_align1


    else:

        # Update align2 based on align1's position
        updated_align2 = align2.copy()
        if align1['ali_to'] > align2['ali_from']:
            updated_align2['ali_from'] = align1['ali_to'] + 1  # Corrected this line
            contig_dict[target_name][j] = updated_align2
        elif align1['ali_from'] < align2['ali_to']:
            updated_align2['ali_to'] = align1['ali_from'] - 1
            contig_dict[target_name][j] = updated_align2
        updated_alignment = updated_align2

    if updated_alignment:
        add_entry_to_dict(overlap_below_70_old_discard, target_name, align1 if update_first_alignment else align2)
        add_entry_to_dict(overlap_below_70_updated_add, target_name, updated_alignment)

    # Optional debug prints
    print("Final entry values:")
    print("Flag: update_first_alignment", update_first_alignment)
    print("Alignment 1: ", contig_dict[target_name][i]['ali_from'], '\t', contig_dict[target_name][i]['ali_to'], '\t', contig_dict[target_name][i]['e_value'])
    print("Alignment 2: ", contig_dict[target_name][j]['ali_from'], '\t', contig_dict[target_name][j]['ali_to'], '\t', contig_dict[target_name][j]['e_value'])


def save_dict_to_json(contig_dict, filename):
    # Convert the dictionary to a JSON string
    json_string = json.dumps(contig_dict, indent=4)

    # Write the JSON string to a file
    with open(filename, 'w') as file:
        file.write(json_string)


def count_alignments_in_file(data):
    # Count the number of alignments for each contig
    contig_counts = {contig: len(alignments) for contig, alignments in data.items()}

    # Calculate the total number of alignments across all contigs
    total_alignments = sum(contig_counts.values())

    return contig_counts, total_alignments

def deduplication_logic2(contig_dict, is_positive):
    overlap_above_70_keep = {}
    overlap_above_70_discard = {}
    overlap_below_70_updated_add = {}
    overlap_below_70_old_discard = {}

    for target_name in contig_dict:
        i = 0
        while i < len(contig_dict[target_name]):
            align1 = contig_dict[target_name][i]
            j = i + 1
            while j < len(contig_dict[target_name]):
                align2 = contig_dict[target_name][j]
                overlap = (calculate_overlap if is_positive else calculate_overlap_negative_strand)(
                    align1['ali_from'], align1['ali_to'], align2['ali_from'], align2['ali_to']
                )
                # Print overlap details for every pair of alignments
                print(f"Comparing alignments: {align1['full_line']} and {align2['full_line']}")
                print(f"Overlap: {overlap*100:.2f}%")

                if overlap > 0.7:
                  if align1['e_value'] > align2['e_value']:
                      # Keep align2 in contig_dict
                      # Discard align1 from contig_dict
                      add_entry_to_dict(overlap_above_70_discard, target_name, align1)
                      contig_dict[target_name].pop(i)
                      # No need to increment i, as the next element shifts to the current position
                      # Break out of the inner loop since align1 is removed
                      break
                  elif align1['e_value'] <= align2['e_value']:
                      # Keep align1 in contig_dict
                      # Discard align2 from contig_dict
                      add_entry_to_dict(overlap_above_70_discard, target_name, align2)
                      contig_dict[target_name].pop(j)
                      # Continue with the next comparison
                      # j is incremented in the loop no need for an additional increment here
                      continue
                elif 0.1 < overlap < 0.7:
                    print(f"Moderate overlap detected between: {align1['full_line']} and {align2['full_line']}, Overlap: {overlap}")
                    if align1['e_value'] > align2['e_value']:
                      print("\nCase where align2 is best hit, so update align1")
                      update_alignments(contig_dict, target_name, i, j, overlap_below_70_old_discard, overlap_below_70_updated_add, True)  # Update align1
                    else:
                      print("\nCase where align1 is best hit, so update align2")
                      update_alignments(contig_dict, target_name, i, j, overlap_below_70_old_discard, overlap_below_70_updated_add, False)  # Update align2


                j += 1
            i += 1

    return contig_dict, overlap_above_70_discard

# Function to combine positive and negative strand data into a tbl file
def combine_strands_to_tbl(positive_strand_data, negative_strand_data, output_filepath):
    combined_lines = []
    for contig in positive_strand_data:
        combined_lines.extend([alignment['full_line'] for alignment in positive_strand_data[contig]])
    for contig in negative_strand_data:
        combined_lines.extend([alignment['full_line'] for alignment in negative_strand_data[contig]])

    with open(output_filepath, 'w') as file:
        file.write("# target name\taccession\tquery name\taccession\thmm len\thmm from\thmm to\tseq len\tali from\tali to\tenv from\tenv to\tE-value\tscore\tbias\tshifts\tstops\tpipe\tdescription of target\n")
        for line in combined_lines:
            file.write(line + "\n")

contigs, header = process_file(input_filepath,e_value_cutoff)

positive_strand, negative_strand = find_pos_neg_strand(contigs)

compare_contig_names(contigs, positive_strand, negative_strand)

#save_dict_to_json(contigs, 'all_contigs.json')

contig_neg_0, discard_neg_0 = deduplication_logic2(negative_strand,is_positive=False)
contig_neg_1, discard_neg_1 = deduplication_logic2(contig_neg_0,is_positive=False)
contig_neg, discard_neg = deduplication_logic2(contig_neg_1,is_positive=False)

count_total_entries(contig_neg)

#save_dict_to_json(contig_neg, 'negative_strand.json')

contig_pos_0, discard_pos_0 = deduplication_logic2(positive_strand,is_positive=True)
contig_pos_1, discard_pos_1 = deduplication_logic2(contig_pos_0,is_positive=True)
contig_pos, discard_pos = deduplication_logic2(contig_pos_1,is_positive=True)

count_total_entries(contig_pos)

#save_dict_to_json(contig_pos, 'positive_strand.json')

combine_strands_to_tbl(contig_pos,contig_neg,output_filepath)

""" Analysis"""

def save_counts_to_file(positive_counts, negative_counts, original_counts, output_file_path):
    with open(output_file_path, 'w') as file:
        file.write("Contig\tPositive Strand\tNegative Strand\tOriginal Contigs\tTotal (Positive + Negative)\n")

        for contig in set(original_counts.keys()).union(positive_counts.keys(), negative_counts.keys()):
            pos_count = positive_counts.get(contig, 0)
            neg_count = negative_counts.get(contig, 0)

            # Ensure the counts are integers (get the count if it's a list)
            pos_count = len(pos_count) if isinstance(pos_count, list) else pos_count
            neg_count = len(neg_count) if isinstance(neg_count, list) else neg_count
            orig_count = len(original_counts.get(contig, []))

            total_count = pos_count + neg_count
            line = f"{contig}\t{pos_count}\t{neg_count}\t{orig_count}\t{total_count}\n"
            file.write(line)

    return output_file_path

save_counts_to_file(contig_pos,contig_neg,contigs,output_filepath_analysis)

count_alignments_in_file(contig_neg)
