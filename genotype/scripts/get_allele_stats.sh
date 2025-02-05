#!/bin/bash

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.vcf.gz output.csv"
    exit 1
fi

VCF_FILE=$1
OUTPUT_CSV=$2

# Extract allele counts
vcftools --gzvcf $VCF_FILE --counts --out tmp_counts

# Get locus (CHROM:POS) and allele count per locus, and write to CSV
awk 'BEGIN {print "LOCUS,ALLELE_COUNTS"} NR>1 {print $1 ":" $2 "," $3}' tmp_counts.frq.count > tmp_allele_counts.csv

# Add header for range estimate
echo "AL_RANGE" > tmp_min_max.csv

# Extract AL values, calculate min-max, and output to CSV
bcftools query -f '[%AL\t]\n' "$VCF_FILE" | \
sed 's/\t/,/g' | \
awk -F',' '
{
    min = max = ""; 
    first = 1;

    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+$/) {
            num = $i + 0;

            if (first) {
                min = max = num;
                first = 0;
            } else {
                if (num < min) min = num;
                if (num > max) max = num;
            }
        }
    }

    # Print min-max range, or NA if no valid numbers
    if (first) {
        print "NA";
    } else {
        print min "-" max;
    }
}' >> tmp_min_max.csv

# Append the data to the final CSV
paste -d, tmp_allele_counts.csv tmp_min_max.csv > $OUTPUT_CSV

# Clean up temporary files
rm tmp_counts.frq.count tmp_counts.log tmp_allele_counts.csv tmp_min_max.csv
