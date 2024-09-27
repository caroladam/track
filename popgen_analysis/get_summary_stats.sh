#!/bin/bash

usage() {
    echo "Usage: $0 -v <vcf_file> -p <popinfo_file> -r <r_script>"
    exit 1
}

# Parse command-line arguments
while getopts "v:p:r:" opt;
do
    case $opt in
        v) vcf_file="$OPTARG" ;;
        p) popinfo_file="$OPTARG" ;;
        r) r_script="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if the required arguments are provided
if [ -z "$vcf_file" ] || [ -z "$popinfo_file" ] || [ -z "$r_script" ];
then
    usage
fi

# Run the R script with the provided VCF and popinfo file
Rscript "$r_script" "$vcf_file" "$popinfo_file"

echo "summary_stats.R is completed"

echo "Output files with observed heterozygosity and genetic diversity have been saved and violin plots were generated"
