#!/bin/bash

# Check for input arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.vcf.gz output.csv"
    exit 1
fi

VCF_FILE=$1
OUTPUT_CSV=$2

# Extract header (sample names)
bcftools query -l $VCF_FILE | awk 'BEGIN{printf "ID,MOTIFS"} {printf ",%s", $1} END{print ""}' > $OUTPUT_CSV

# Extract data: ID, MOTIFS field, and genotypes
bcftools query -f '\t%INFO/TRID\t%MOTIFS[\t%GT]\n' $VCF_FILE | awk '
BEGIN {OFS=","} 
{print $1, $2, $3, $4, $5, $6}' >> $OUTPUT_CSV
