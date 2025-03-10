#!/bin/bash

usage() {
    echo "Usage: $0 -l <lifted_trs> -c <query_tr_catalog> -t <target_prefix> -q <query_prefix> -o <overlap_perc> -a <align_perc> -j <threads>"
    exit 1
}

# Parse command-line options
while getopts ":l:c:t:q:o:a:j:" opt; do
    case ${opt} in
        l) lifted_trs="$OPTARG" ;;
        c) query_tr_catalog="$OPTARG" ;;
        t) target_prefix="$OPTARG" ;;
        q) query_prefix="$OPTARG" ;;
        o) overlap_perc="$OPTARG" ;;
        a) align_perc="$OPTARG" ;;
        j) threads="$OPTARG" ;;
        *) usage ;;
    esac
done

# Check if all required arguments are provided
if [ -z "$lifted_trs" ] || [ -z "$query_tr_catalog" ] || [ -z "$target_prefix" ] || [ -z "$query_prefix" ] || [ -z "$overlap_perc" ] || [ -z "$align_perc" ]; then
    usage
fi

# Ensure required commands are available
for cmd in bedtools awk needle grep paste sed; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is not installed or not in PATH."
        exit 1
    fi
done

# Intersect regions of the lifted TRs file (query to target) with TRF catalog for the query genome

shared_trs="shared_trs_${target_prefix}_${query_prefix}.bed"
sorted_shared_trs="shared_trs_${target_prefix}_${query_prefix}_sorted.bed"

bedtools intersect -a "$lifted_trs" -b "$query_tr_catalog" -f "$overlap_perc" -F "$overlap_perc" -e -wa -wb > "$shared_trs"

# Add species names and keep only columns of interest - index and motif sequence, then sort file
gawk -i inplace -v tgt="$target_prefix" -v qry="$query_prefix" \
    'BEGIN {FS="\t"; OFS="\t"} {print tgt"lifted", $13, $14, $15, $7, qry"query", $13, $14, $15, $19, $10, $11, $12, tgt"originalcatalog"}' "$shared_trs"

sort -k1,1 -k2,2n "$shared_trs" > "$sorted_shared_trs"

rm "$shared_trs"

# Create base directory for chunks
chunk_dir="chunks_${target_prefix}_${query_prefix}"
mkdir -p "$chunk_dir"

# Split `shared_trs` file into 10,000-line chunks in the chunk directory
split -l 10000 "$sorted_shared_trs" "$chunk_dir/chunk_"

echo "Running Needle for $target_prefix (as target) and $query_prefix (as query)."
echo "This might take a while."
echo ""

# Process each chunk
for chunk in "$chunk_dir"/chunk_*; do
    # Create a subdirectory for each chunk and move the chunk file there
    chunk_subdir="${chunk}_subdir"
    mkdir -p "$chunk_subdir"
    mv "$chunk" "$chunk_subdir/"

    # Inside each subdirectory, split each chunk file into single-line files to prepare for alignment
    cd "$chunk_subdir" || exit
    split -l 1 "$(basename "$chunk")" line_

    # Process each single-line file to convert it to FASTA format
    for line_file in line_*; do
        awk 'BEGIN {FS="\t"; OFS="_"} {print ">"$1, $2, $3, $4"\n"$5"\n"">"$6, $7, $8, $9, $11, $12, $13, $14"\n"$10}' "$line_file" > "$line_file.fa"
        rm "$line_file"  # Remove original line file
    done

    # Run needle alignments in parallel and save results in aligned_dir
    parallel -j "$threads" 'needle -asequence {} -bsequence {} -auto -gapopen 10 -gapextend 0.5 -outfile {/.}.out' ::: *.fa

    # Post-processing: sed, concatenate with FASTA file
    for outfile in *.out
    do
        filename=$(basename -- "$outfile")
        sed -i '13,42d' "$outfile"
        cat "$outfile" "${filename%.out}.fa" > temp_file
        mv temp_file "$outfile"
        rm "${filename%.out}.fa"
    done

    score_file=scores.txt
    bedloc_file=locations.txt
    output_file=sim_score_overlap${overlap_perc}_${target_prefix}_${query_prefix}.txt
    filtered_file=sim_score_overlap${overlap_perc}_${target_prefix}_${query_prefix}_filtered.txt

    # Extract similarity scores for each pairwise TR alignment
    grep "Similarity" *.out | grep -o "[0-9]*\.[0-9]" > "$score_file"

    # Extract chromosome locations for each TR
    grep ">${query_prefix}" *.out | sed 's/.*>//' > "$bedloc_file"

    # Combine locations and scores into final output
    paste "$bedloc_file" "$score_file" > "$output_file"
    awk -v align_perc="$align_perc" '$2 >= align_perc' "$output_file" > "$filtered_file"
    rm "${chunk_subdir}"/*.out
    cd - > /dev/null || exit
    
done

# Combine all results into a single file
echo "Calculating similarity scores"
final_output="overlap${overlap_perc}_sim${align_perc}_${target_prefix}_${query_prefix}.bed"
find "$chunk_dir" -type f -name "*_filtered.txt" -exec cat {} + > "$final_output"
sed -i 's/_/\t/g' "$final_output"

# Organize file into BED structure
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $2, $3, $4, $1, $5, $6, $7, $8, $9}' "$final_output"

# Cleanup intermediate files
rm -r "$chunk_dir"
rm "$sorted_shared_trs"

echo ""
echo "Processing completed."
echo ""
echo "Filtered Tandem Repeats for TARGET $target_prefix and QUERY $query_prefix with $overlap_perc overlap and $align_perc similarity are saved in $final_output."
