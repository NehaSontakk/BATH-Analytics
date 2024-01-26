# BATH-Analytics

1. bathconvert
2. tantan+bathsearch
3. combine ct bath files


## Pseudocode for Deduplication Logic

**Function:** `deduplication_logic2`

### Inputs:
- `contig_dict`: A dictionary of contigs, where each contig contains a list of alignment entries.
- `is_positive`: A boolean flag indicating whether to process the positive or negative strand.

### Outputs:
- Updated `contig_dict` with deduplicated alignments.

### Process:

1. **Initialize Dictionaries for Tracking Changes**
   - Create dictionaries to track alignments that are kept, discarded, or updated due to overlap resolution.

2. **Iterate Through Each Contig in `contig_dict`**
   - For each `target_name` in `contig_dict`, process its alignments.

3. **Compare Alignments Within Each Contig**
   - Iterate through pairs of alignments (`align1` and `align2`) within the same contig.
   - For each pair, calculate the overlap percentage.

4. **Decision Making Based on Overlap and E-values**
   - If the overlap is above a certain threshold (e.g., 70%):
     - Compare E-values of `align1` and `align2`.
     - Keep the alignment with the lower (better) E-value and discard the other.
   - If the overlap is moderate (e.g., between 10% and 70%):
     - Again, compare E-values.
     - Decide which alignment to update based on the better E-value.
     - Update the alignment with the higher E-value to resolve the overlap.

5. **Updating Alignments to Resolve Overlap**
   - If updating `align1` (when `align2` is a better hit):
     - Adjust `align1['ali_to']` to just before `align2['ali_from']`.
   - If updating `align2` (when `align1` is a better hit):
     - Adjust `align2['ali_from']` to just after `align1['ali_to']`.
   - Ensure that updates do not alter the original start of alignments.

6. **Store Updated Alignments**
   - Record changes in the appropriate dictionaries for tracking.

7. **Return Updated Contig Dictionary**
   - Return the modified `contig_dict` reflecting the deduplication process.

**End Function**


# Testing

1. Non-Overlapping Alignments: Alignment 1 (a to b, any E-value), Alignment 2 (c to d, any E-value), where b < c. This tests the script's ability to handle non-overlapping alignments.
3. Identical Alignments with Different E-values: Alignment 1 (a to b, lower E-value), Alignment 2 (a to b, higher E-value). This checks how the script handles identical alignments with different E-values.
4. Complete Overlap with Equal E-values: Alignment 1 (a to b, E-value X), Alignment 2 (a to b, E-value X). This tests the script's behavior when alignments are identical and have the same E-value.
5. Partial Overlap with Equal E-values: Alignment 1 (a to b, E-value X), Alignment 2 (c to d, E-value X), where a < c < b < d. This scenario tests how the script deals with partial overlaps and equal E-values.
6. Edge Case: Single Point Overlap: Alignment 1 (a to b, any E-value), Alignment 2 (b to c, any E-value). This edge case tests how the script handles alignments that only overlap at a single point.
7. Non-Overlapping Alignments with Negative Strands: Alignment 1 (a to b, any E-value), Alignment 2 (c to d, any E-value) for negative strands, ensuring that the logic for negative strand overlap calculation is correct.
8. Overlapping Alignments with Varying Degrees of Overlap: Multiple test cases with different degrees of overlap (e.g., 10%, 50%, 90%) to test how the script handles varying overlap scenarios.
9. Cases with Multiple Alignments: More than two alignments overlapping in various ways to check how the script handles complex scenarios with multiple overlaps
10. Alignments Completely Overlapping Regions and Larger Alignment with High/Low E-value
