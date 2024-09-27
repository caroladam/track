#!/bin/bash

usage() {
    echo "Usage: $0 <trf_dir> <outfile>"
    echo "    <trf_dir>: Path to the TRF results directory."
    echo "    <outfile>: Output file name."
    exit 1
}

function trim_path {
	echo $1 | sed 's/\/$//'
}

function trim_file {
  echo $1 | grep -o '[^\/]*$' | sed 's/\.[^\.]*$//'
}

function get_prefix {
  echo "${1%%.*}"
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

trf_dir=$1
outfile=$2

# Check if outfile already exists
if [ -f "$outfile" ];
then
    echo "Error: Outfile $outfile already exists."
    exit 1
else
    touch "$outfile"
fi

# Concatenate and process TRF results
for file in "$trf_dir"/*.dat
do
	# Remove headers
	sed -i '/^[0-9]/!d' "$file"
	filename=$( trim_file "$file" )
	prefix=$( get_prefix "$filename" )
	cat "$file" | \
		# Extract columns of interest and calculate TR total length
		awk -v "chrom=$prefix" 'BEGIN{FS=" "; OFS="\t"} {tr_l = $3-$2} {print chrom, $1, $2, $3, tr_l, $4, $14, $15}' | \
		# Filter TRs with total length <= 10Kbp and copy number >= 2.5
		awk '{ if ($5 <= 10000 && $6 >= 2.5) {print $1, $2, $3, $4, $6, $7, $8, $9} }' OFS='\t' >> "$outfile"
done

# Sort TRF output
sort -k1,1 -k2,2n -k3 "$outfile" > "${outfile}.sorted.bed"

# Merge overlapping elements (up to 5bp apart)
mergeBed -i "${outfile}.sorted" -d 5 > "${outfile}.merged.bed"

# Select TR with the smallest motif length using bedmap
bedmap --min-element "${outfile}.merged.bed" "${outfile}.sorted.bed" > "${outfile}.no_overlaps.bed"

# Remove trailing decimals
sed -i 's/\.000000//g' "${outfile}.no_overlaps.bed"

echo "Tandem Repeat filtering completed successfully."
