#!/bin/bash

usage() {
    echo "Usage: $0 -i <input_bed> -c <chain_file> -o <output_bed> -u <unmapped_file> -l <liftOver_directory>"
    exit 1
}

# Parse arguments
while getopts "i:c:o:u:l:" opt; do
    case ${opt} in
        i) input_bed="$OPTARG" ;;
        c) chain_file="$OPTARG" ;;
        o) output_bed="$OPTARG" ;;
        u) unmapped_file="$OPTARG" ;;
        l) liftOver_dir="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all arguments are provided
if [ -z "$input_bed_file" ] || [ -z "$chain_file" ] || [ -z "$output_bed_file" ] || [ -z "$unmapped_file" ] || [ -z "$liftOver_dir" ]; then
    echo "Insufficient arguments."
    usage
fi

echo "Running liftOver"

"$liftOver_dir"/liftOver -bedPlus=3 -tab "$input_bed_file" "$chain_file" "$output_bed_file" "$unmapped_file"

echo "liftOver completed. Lifted TRs saved to $output_bed_file, unmapped TRs saved to $unmapped_file."
