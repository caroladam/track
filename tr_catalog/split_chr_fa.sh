#!/bin/bash

trim_path() {

        echo "$1" | sed 's/\/$//'
}

usage() {
    echo "Usage: $0 <path_to_fasta_files>"
    exit 1
}

# Check if an argument is provided
if [ -z "$1" ]
then
    echo "No path provided."
    usage
fi

fasta_path=$(trim_path "$1")

# Iterate over all .fa files
for fasta_file in "$fasta_path"/*.fa
do
    # Check if there are any .fa files in the directory
    if [ ! -e "$fasta_file" ]; then
        echo "No .fa files found in the directory."
        exit 1
    fi
    
    # Run faidx on each .fa file
    faidx -x "$fasta_file"
done

echo "Indexing completed for all .fa files in $fasta_path."
