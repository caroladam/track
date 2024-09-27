#!/bin/bash

usage() {
    echo "Usage: $0 -l <lifted_trs> -c <query_tr_catalog> -t <target_prefix> -q <query_prefix> -o <overlp_perc> -a <align_perc>"
    exit 1
}

# Parse command-line options
while getopts ":l:c:t:q:o:a" opt
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

# Create directories for fasta files and aligned files
fasta_dir=$(mktemp -d fasta_XXXXXX)
aligned_dir="aligned"
mkdir -p "$aligned_dir"

# Intersect regions of the lifted TRs file with TRF catalog for the query genome - keeping those with threshold reciprocal overlap
shared_trs="shared_trs.bed"
bedtools intersect -a "$lifted_trs" -b "$query_tr_catalog" -wa -wb -f "$overlap_perc" -r > "$shared_trs"

# Add species names and keep only columns of interest - index and motif sequence, then split file to keep one TR per file
awk -v tgt="$target_prefix" -v qry="$query_prefix" \
    'BEGIN {FS="\t"; OFS="\t"} {print tgt, $1, $2, $3, $7, qry, $1, $2, $3, $19, $10, $11, $12, tgt}' "$shared_trs" | split -l 1 - "$fasta_dir/x"

# Structure each file as FASTA
cd "$fasta_dir"
for file in x*
do
    awk 'BEGIN {FS="\t"; OFS="_"} {print ">"$1, $2, $3, $4"\n"$5"\n"">"$6, $7, $8, $9, $11, $12, $13, $14"\n"$10}' "$file" > "$file.fa"
done

# Align fasta files with Needle using GNU Parallel
parallel -j $(nproc) "needle -asequence {1} -bsequence {1} -gapopen 10 -gapextend 0.5 -outfile ${aligned_dir}/{1}.out" ::: *.fa

cd ../

# Get alignment similarity scores
score_file="score.txt"
bedloc_file="bedloc.txt"
output_file="sim_score_${target_prefix}_${query_prefix}"

for file in "${aligned_dir}"/*.out
do
    # Extract similarity scores
    grep "Similarity" "${file}" | grep -o "[0-9]*\.[0-9]*" >> "$score_file"
    grep ">${query_prefix}" "${file}" >> "$bedloc_file"
done

# Combine bed locations and scores into a single file with target and query prefixes
paste "$bedloc_file" "$score_file" > "$output_file"
rm "$bedloc_file" "$score_file"

# Clean up unnecessary text from the output file
sed -i 's/[a-z]*\.fa\.out:>//g' "$output_file"

# Get subset of TRs with threshold alignment similarity
awk -v align_perc="$align_perc" '$2 >= align_perc' "$output_file" | sed 's/_/\t/g; s/"//g'
awk 'BEGIN {FS="\t"; OFS="\t"} {print $2, $3, $4, $1, $5, $6, $7, $8}' "$output_file" > "sim_score_${overlap_perc}_${align_perc}_${target_prefix}_${query_prefix}.bed"

# Clean up temporary files
rm -r "$fasta_dir"

echo "Alignment similarity score extraction and formatting completed."
