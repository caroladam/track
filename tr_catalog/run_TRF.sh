#!/bin/bash

usage() {
    echo "Usage: $0 -g <path_to_fasta_files> -t <path_to_trf_executable>"
    exit 1
}

# Parse options
while getopts "g:t:" opt; do
    case ${opt} in
        g) genomes_dir="$OPTARG" ;;
        t) trf_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all arguments are provided
if [ -z "$genomes_dir" ] || [ -z "$trf_dir" ]; then
    echo "Insufficient arguments."
    usage
fi

echo "Running TRF"

# TRF configuration
matchscore=2
mismatchscore=5
indelscore=7
pm=80
pi=10
minscore=24
maxperiod=2000

# Run TRF on each .fa file in the genomes directory
for fasta_file in "$genomes_dir"/*.fa; do
    if [ ! -e "$fasta_file" ]; then
        echo "No .fa files found in the directory."
        exit 1
    fi
    
    "$trf_dir"/trf "$fasta_file" "$matchscore" "$mismatchscore" "$indelscore" "$pm" "$pi" "$minscore" "$maxperiod" -f -d -h -l 6
done

echo "TRF processing completed for all .fa files in $genomes_dir."
