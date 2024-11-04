#!/bin/bash

usage() {
    echo "Usage: $0 -g <fasta_dir>"
    exit 1
}

# Parse options
while getopts "g:" opt; do
    case ${opt} in
	g) fasta_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all arguments are provided
if [ -z "$fasta_dir" ]; then
    echo "Insufficient arguments."
    usage
fi

trim_path() {

        echo "$1" | sed 's/\/$//'
}

fasta_dir=$( trim_path "$fasta_dir" )

# Split each .fa or .fasta file into chromosomes
for reference in "$fasta_dir"/*.{fa,fasta}
do
    if [ -f "$reference" ]; then
        faidx -x "$reference"
    fi
done

mkdir -p split_chr_fa
mv *.fa split_chr_fa

# TRF configuration
matchscore=2
mismatchscore=5
indelscore=7
pm=80
pi=10
minscore=24
maxperiod=2000

# Run TRF on each .fa file in the genomes directory
for fasta_file in split_chr_fa/*.fa
do
	if [ ! -f "$fasta_file" ]; then
		echo "No .fa files found in the directory."
		exit 1
	fi
		echo ""
		echo "Running TRF on $fasta_file with the following parameters:"
		echo "matchscore=$matchscore mismatchscore=$mismatchscore indelscore=$indelscore matchprobability=$pm indelprobability=$pi minscore=$minscore maxperiod=$maxperiod"

		trf "$fasta_file" "$matchscore" "$mismatchscore" "$indelscore" "$pm" "$pi" "$minscore" "$maxperiod" -f -d -h -l 6
done

mkdir -p trf_results

for file in *.dat; do
	if [[ $file =~ ^(chr[a-zA-Z0-9]+\.fa)\.[0-9]+.*\.dat$ ]]; then
        	new_name="${BASH_REMATCH[1]}.dat"
	        mv "$file" "$new_name"
	fi
done

mv *.dat trf_results/
