#!/bin/bash

# Usage check
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_bam> <ref_fasta> <output_file>"
    exit 1
fi

# Command line argument assignment
INPUT_BAM=$1
REF_FASTA=$2
OUTPUT_FILE=$3

# Purpose of the following pipeline:
# 1. Aggregate Data: Condense the base-by-base statistics from pysamstats into larger genomic windows.
# 2. Calculate Key Metrics: Within each window, compute the total number of reads and the ratio of matching reads.
# 3. Filter and Format: Discard header lines to produce a clean, tabulated summary for further analysis or visualization.

# Print header to the output file
echo -e "chr\twindow_start\treads_all\tmatches\tmatchrate" > "$OUTPUT_FILE"

# Execute the command and append results to the output file
time pysamstats --pad --fasta "$REF_FASTA" --type variation --fields chrom,pos,reads_all,matches "$INPUT_BAM" -u | \
awk 'BEGIN{OFS="\t"; window=100; count=0; total_reads=0; total_matches=0;} 
!/^#/ {count++; total_reads+=$3; total_matches+=$4; 
if(count==window){print $1, $2-window+1, total_reads, total_matches, (total_reads>0 ? total_matches/total_reads : 0); count=0; total_reads=0; total_matches=0;}} 
END{if(count>0){print $1, $2-count+1, total_reads, total_matches, (total_reads>0 ? total_matches/total_reads : 0);}}' >> "$OUTPUT_FILE"

echo "Processing completed. Results saved in $OUTPUT_FILE"
