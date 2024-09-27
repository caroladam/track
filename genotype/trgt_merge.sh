#!/bin/bash

usage() {
    echo "Usage: $0 -v <vcf_files_dir> -p <output_prefix> -g <trgt_path> [-f <final_output_dir>]"
    exit 1
}

# Parse command-line options
final_output_dir=$(pwd)  # Default to current directory
while getopts "v:b:p:n:g:f:" opt;
do
    case ${opt} in
        v) vcf_dir="$OPTARG" ;;
        p) output_prefix="$OPTARG" ;;
        g) trgt_path="$OPTARG" ;;
        f) final_output_dir="$OPTARG" ;;  # Optional final output directory
        *) usage ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$vcf_dir" ] || [ -z "$output_prefix" ] || [ -z "$trgt_path" ];
then
    usage
fi

echo "Merging VCF files from $vcf_dir..."
"$trgt_path"/trgt merge --vcf "$vcf_dir"/*.vcf.gz -O z -o "$final_output_dir"/"$output_prefix"_merged.vcf.gz
if [ $? -ne 0 ];
then
    echo "Error: Failed to merge VCF files."
    exit 1
fi

echo "VCF merge completed. Output saved to $final_output_dir/${output_prefix}_merged.vcf.gz"
