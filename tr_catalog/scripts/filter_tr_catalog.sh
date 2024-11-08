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

# Concatenate and process TRF results
for file in "$trf_dir"/*.dat
do
	# Remove headers (keeping only lines starting with numbers)
	sed -i '/^[0-9]/!d' "$file"
	filename=$( trim_file "$file" )
	prefix=$( get_prefix "$filename" )
	catalog="$outfile"_catalog
	cat "$file" | \
		# Extract columns of interest and calculate TR total length
		awk -v "chrom=$prefix" 'BEGIN{FS=" "; OFS="\t"} {tr_l = $2-$1} {print chrom, $1, $2, $3, tr_l, $4, $14, $15}' OFS='\t' >> "$catalog"
done

# Filter TRs with total length <= 10Kbp and copy number >= 2.5
awk '{ if ($5 <= 10000 && $6 >= 2.5) {print} }' "$catalog" > temp_file && mv temp_file "$catalog"

# Remove trailing tabs
sed -i 's/[ \t]*$//' "$catalog"

# Add species prefix to the file
awk -v var="$outfile" '{print $0 "\t" var}' "$catalog" > temp && mv temp "$catalog"

# Sort TRF output
sort -k1,1 -k2,2n -k3 "$catalog" > "${catalog}.sorted.bed"

# Merge overlapping elements (up to 5bp apart)
mergeBed -i "${catalog}.sorted.bed" -d 5 > "${catalog}.merged.bed"

# Select TR with the smallest motif length using bedmap
bedmap --min-element "${catalog}.merged.bed" "${catalog}.sorted.bed" > "${catalog}.no_overlaps.bed"

# Remove trailing decimals
sed -i 's/\.000000//g' "${catalog}.no_overlaps.bed"

rm "$catalog"

echo "### Tandem Repeat filtering completed successfully ###"
echo ""
