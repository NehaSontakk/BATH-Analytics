# BATH-Analytics

1. run_bathsearch.sh (replace bin file name)
2. 

# Testing

1. Non-Overlapping Alignments: Alignment 1 (a to b, any E-value), Alignment 2 (c to d, any E-value), where b < c. This tests the script's ability to handle non-overlapping alignments.
3. Identical Alignments with Different E-values: Alignment 1 (a to b, lower E-value), Alignment 2 (a to b, higher E-value). This checks how the script handles identical alignments with different E-values.
4. Complete Overlap with Equal E-values: Alignment 1 (a to b, E-value X), Alignment 2 (a to b, E-value X). This tests the script's behavior when alignments are identical and have the same E-value.
5. Partial Overlap with Equal E-values: Alignment 1 (a to b, E-value X), Alignment 2 (c to d, E-value X), where a < c < b < d. This scenario tests how the script deals with partial overlaps and equal E-values.
6. Edge Case: Single Point Overlap: Alignment 1 (a to b, any E-value), Alignment 2 (b to c, any E-value). This edge case tests how the script handles alignments that only overlap at a single point.
7. Non-Overlapping Alignments with Negative Strands: Alignment 1 (a to b, any E-value), Alignment 2 (c to d, any E-value) for negative strands, ensuring that the logic for negative strand overlap calculation is correct.
8. Overlapping Alignments with Varying Degrees of Overlap: Multiple test cases with different degrees of overlap (e.g., 10%, 50%, 90%) to test how the script handles varying overlap scenarios.
9. Cases with Multiple Alignments: More than two alignments overlapping in various ways to check how the script handles complex scenarios with multiple overlaps
