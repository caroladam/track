#!/bin/bash

usage() {
    echo "Usage: $0 -l <lifted_trs> -c <query_tr_catalog> -t <target_prefix> -q <query_prefix> -o <overlp_perc> -a <align_perc>"
    exit 1
}

# Parse command-line options
while getopts ":l:c:t:q:o:a:" opt
do
    case ${opt} in
        l) lifted_trs="$OPTARG" ;;
        c) query_tr_catalog="$OPTARG" ;;
        t) target_prefix="$OPTARG" ;;
        q) query_prefix="$OPTARG" ;;
        o) overlap_perc="$OPTARG" ;;
        a) align_perc="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$lifted_trs" ] || [ -z "$query_tr_catalog" ] || [ -z "$target_prefix" ] || [ -z "$query_prefix" ] || [ -z "$overlap_perc" ] || [ -z "$align_perc" ]
 then
    usage
fi

# Ensure required commands are available
for cmd in bedtools awk needle parallel grep paste sed
do
    if ! command -v "$cmd" &> /dev/null
    then
        echo "Error: $cmd is not installed or not in PATH."
        exit 1
    fi
done

# Intersect regions of the lifted TRs file with TRF catalog for the query genome - keeping those with threshold reciprocal overlap
shared_trs="shared_trs.bed"
bedtools intersect -a "$lifted_trs" -b "$query_tr_catalog" -wa -wb -f "$overlap_perc" > "$shared_trs"

# Create directories for fasta files and aligned files
fasta_dir="fasta_XXXXXX_${target_prefix}_${query_prefix}"
mkdir -p "$fasta_dir"

# Add species names and keep only columns of interest - index and motif sequence, then split file to keep one TR per file
awk -v tgt="$target_prefix" -v qry="$query_prefix" \
    'BEGIN {FS="\t"; OFS="\t"} {print tgt"target", $1, $2, $3, $7, qry"query", $1, $2, $3, $19, $10, $11, $12, tgt"originalcatalog"}' "$shared_trs" | split -l 1 - "$fasta_dir/x"

rm "$shared_trs"

# Structure each file as FASTA
for file in "$fasta_dir"/x*
do
    awk 'BEGIN {FS="\t"; OFS="_"} {print ">"$1, $2, $3, $4"\n"$5"\n"">"$6, $7, $8, $9, $11, $12, $13, $14"\n"$10}' "$file" > "$file.fa"
done

aligned_dir="aligned_${target_prefix}_${query_prefix}"
mkdir -p "$aligned_dir"

cd "$fasta_dir"

# Align fasta files with Needle using GNU Parallel
parallel -j $(nproc) '
    outfile={}.out
    needle -asequence {} -bsequence {} -gapopen 10 -gapextend 0.5 -outfile $outfile &&
    sed -i "13,42d" $outfile &&
    cat $outfile {} >> $outfile 2>/dev/null
' ::: *.fa

mv *.out ../$aligned_dir

cd ../

# Get alignment similarity scores
score_file="score.txt"
bedloc_file="bedloc.txt"
output_file="sim_score_overlap${overlap_perc}_${target_prefix}_${query_prefix}.txt"

for file in "${aligned_dir}"/*.out
do
    # Extract similarity scores
    grep "Similarity" "${file}" | grep -o "[0-9]*\.[0-9]*" >> "$score_file"
    grep ">${query_prefix}" "${file}" >> "$bedloc_file"
done

# Combine bed locations and scores into a single file with target and query prefixes
paste "$bedloc_file" "$score_file" > "$output_file"
rm "$bedloc_file" "$score_file"

# Get subset of TRs with threshold alignment similarity
thr_score_file="overlap${overlap_perc}_sim${align_perc}_${target_prefix}_${query_prefix}.bed"
awk -v align_perc="$align_perc" '$2 >= align_perc' "$output_file" > "$thr_score_file"
sed 's/_/\t/g; s/"//g' "$thr_score_file" | sed 's/>//g' > temp_file && mv temp_file "$thr_score_file"
awk 'BEGIN {FS="\t"; OFS="\t"} {print $2, $3, $4, $1, $5, $6, $7, $8, $9}' "$thr_score_file" > temp_file && mv temp_file "$thr_score_file"

# Clean up temporary files
rm -r "$fasta_dir"
echo "Alignment similarity score extraction and formatting completed."
