#!/bin/bash

usage() {
    echo "Usage: $0 -r <reference_genome_file> -t <tandem_repeat_catalog> -b <bam_file> -p <output_prefix> -n <threads>"
    exit 1
}

# Parse command-line options
while getopts "r:t:b:p:n:" opt; 
do
    case ${opt} in
        r) ref_file="$OPTARG" ;;
        t) tr_catalog="$OPTARG" ;;
        b) bam_file="$OPTARG" ;;
        p) output_prefix="$OPTARG" ;;
        n) threads="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$ref_file" ] || [ -z "$tr_catalog" ] || [ -z "$bam_file" ] || [ -z "$output_prefix" ] || [ -z "$threads" ]; then
    usage
fi

echo "Running TRGT genotype function"
trgt genotype --genome "$ref_file" --repeats "$tr_catalog" --reads "$bam_file" --threads "$threads" --output-prefix "$output_prefix"

echo "Genotyping completed. VCF and BAM outputs saved with prefix $output_prefix"
