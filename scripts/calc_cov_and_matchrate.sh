#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_bam> <ref_fasta> <output_file>"
    exit 1
fi

# Assign command line arguments to variables
INPUT_BAM=$1
REF_FASTA=$2
OUTPUT_FILE=$3

# Print header to the output file
echo -e "chr\twindow_start\treads_all\tmatches\tmatchrate" > "$OUTPUT_FILE"

# Piping the result of pysamstats into awk serves several purposes:
# 1. Aggregate Data: The base-by-base statistics from pysamstats is summarized into larger genomic windows.
#    This condenses the detailed information into more manageable and interpretable chunks.
# 2. Calculate Key Metrics: Within each window, we compute total number of reads and the proportion of matching reads.
#    This provides a clear overview of alignment quality in each genomic segment.
# 3. Filter and Format: We discard header lines and present a clean tabulated summary for further analysis or visualization.

pysamstats --pad --fasta "$REF_FASTA" --type variation "$INPUT_BAM" -u | \
awk 'BEGIN{OFS="\t"; window=100; count=0; total_reads=0; total_matches=0;} 
!/^#/ {count++; total_reads+=$3; total_matches+=$4; 
if(count==window){print $1, $2-window+1, total_reads, total_matches, (total_reads>0 ? total_matches/total_reads : 0); count=0; total_reads=0; total_matches=0;}} 
END{if(count>0){print $1, $2-count+1, total_reads, total_matches, (total_reads>0 ? total_matches/total_reads : 0);}}' >> "$OUTPUT_FILE"

echo "Processing completed. Results saved in $OUTPUT_FILE"
