#!/bin/bash

usage() {
    echo "Usage: $0 -f <fasta_file>"
    exit 1
}

# Parse options
while getopts "f:" opt; do
    case ${opt} in
	f) fasta_file="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all arguments are provided
if [ -z "$fasta_file" ]; then
    echo "Insufficient arguments."
    usage
fi

mkdir -p trf_results

# TRF configuration
matchscore=2
mismatchscore=5
indelscore=7
pm=80
pi=10
minscore=24
maxperiod=2000

echo ""
echo "Running TRF on $fasta_file with the following parameters:"
echo "matchscore=$matchscore mismatchscore=$mismatchscore indelscore=$indelscore matchprobability=$pm indelprobability=$pi minscore=$minscore maxperiod=$maxperiod"

trf "$fasta_file" "$matchscore" "$mismatchscore" "$indelscore" "$pm" "$pi" "$minscore" "$maxperiod" -f -d -h -l 6
mv *.dat trf_results/ 2>/dev/null

cd trf_results || exit

for file in *.dat; do
	if [[ $file =~ ^(chr[a-zA-Z0-9]+\.fa)\.[0-9]+.*\.dat$ ]]; then
        	new_name="${BASH_REMATCH[1]}.dat"
	        mv "$file" "$new_name"
	fi
done

echo ""
echo "TRF processing is complete! Find your TR data per chromosome at trf_results directory"
