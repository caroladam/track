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
		awk -v "chrom=$prefix" 'BEGIN{FS=" "; OFS="\t"} {tr_l = $2-$1} {print chrom, $1, $2, $3, tr_l, $4, $6, $14, $15}' OFS='\t' >> "$catalog"
done

# Filter TRs with total length >= 10Kbp and copy number <= 2.5
awk '{ if ($5 <= 10000 && $6 >= 2.5) {print} }' "$catalog" > temp_file && mv temp_file "$catalog"

# Filter out TRs with matching score <=60%
awk '{ if ($7 >= 60) {print} }' "$catalog" > temp_file && mv temp_file "$catalog"

# Remove trailing tabs
sed -i 's/[ \t]*$//' "$catalog"

# Add species prefix to the file
awk -v var="$outfile" '{print $0 "\t" var}' "$catalog" > temp && mv temp "$catalog"

# Sort TRF output
sort -k1,1 -k2,2n -k3 "$catalog" > "${catalog}.sorted.bed"

# Cluster overlapping elements (up to 5bp apart)
bedtools cluster -i "${catalog}.sorted.bed" -d 5 > "${catalog}.clustered.bed"

# Select TR with the smallest motif length

awk 'BEGIN{OFS="\t"} {
    cluster_id = $11;
    motif_length = $4;
    # If cluster ID already exists, compare motif length
    if (cluster_id in cluster) {
        split(cluster[cluster_id], fields, "\t");
        if (motif_length < fields[4]) {
            cluster[cluster_id] = $0;  # Update TR if motif length is smaller
        }
    } else {
        cluster[cluster_id] = $0;
    }
} END {
    for (c in cluster) print cluster[c];
}' "${catalog}.clustered.bed" | cut -f1-10 > "${catalog}.no_overlaps.bed"

rm "$catalog"

# Normalize motifs to smalles motif unit
awk '
BEGIN {
    OFS = "\t"
}

function repeat(str, n,  out, i) {
    out = ""
    for (i = 0; i < n; i++) out = out str
    return out
}

function normalize(motif,   i, unit, n) {
    n = length(motif)
    for (i = 1; i <= n / 2; i++) {
        if (n % i != 0) continue
        unit = substr(motif, 1, i)
        if (repeat(unit, n / i) == motif) return unit
    }
    return motif
}

{
    chr = $1
    start = $2
    end = $3
    motif_len = $4
    tr_len = $5
    copy_num = $6
    match_score = $7
    motif = $8
    tr = $9
    species = $10

    norm_motif = normalize(motif)
    norm_len = length(norm_motif)
    norm_copy = tr_len / norm_len

    print chr, start, end, norm_len, tr_len, norm_copy, match_score, norm_motif, tr, species
}
' "${catalog}.no_overlaps.bed" > temp_norm && mv temp_norm "${catalog}.no_overlaps.bed"

echo "### Tandem Repeat filtering completed successfully ###"
echo ""
