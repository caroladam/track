#!/bin/bash

# Check if the input file is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

# Input file from the first argument
input_file="$1"

# Use a temporary file to store modifications
temp_file=$(mktemp)

# Process each line in the input file
while IFS=$'\t' read -r chr start end col4 col5 col6 motifs seq col9; do
  # Create ID and formatted STRUC fields
  id="${chr}_${start}_${end}"
  struc="(${motifs})n"
  
  # Print the reformatted line to the temporary file
  echo -e "${chr}\t${start}\t${end}\tID=${id};MOTIFS=${motifs};STRUC=${struc}" >> "${temp_file}"
done < "${input_file}"

# Overwrite the original file with the modified content
mv "${temp_file}" "${input_file}"
