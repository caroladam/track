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

sorted_lifted_trs="${lifted_trs}_sorted"
shared_trs="shared_trs_${target_prefix}_${query_prefix}.bed"
sorted_shared_trs="shared_trs_${target_prefix}_${query_prefix}_sorted.bed"

sort -k1,1 -k2,2n "$lifted_trs" > "$sorted_lifted_trs"

# Intersect regions of the lifted TRs file (query to target) with TRF catalog for the query genome
bedtools intersect -a "$sorted_lifted_trs" -b "$query_tr_catalog" -f "$overlap_perc" -F "$overlap_perc" -e -wa -wb > "$shared_trs"

sort -k1,1 -k2,2n "$shared_trs" > "$sorted_shared_trs"

rm "$shared_trs"

# Add species names and keep only columns of interest - index and motif sequence, then sort file
gawk -i inplace -v tgt="$target_prefix" -v qry="$query_prefix" \
    'BEGIN {FS="\t"; OFS="\t"} {print tgt"lifted", $14, $15, $16, $8, qry"query", $14, $15, $16, $21, $11, $12, $13, tgt"originalcatalog"}' "$sorted_shared_trs"

echo "Processing cyclic permutations and generating reverse complement motif for ${target_prefix} as target."

cyclic_shared_trs="cyclic_shared_trs_${target_prefix}_${query_prefix}.bed"
cyclic_rev_shared_trs="cyclic_revcomp_shared_trs_${target_prefix}_${query_prefix}.bed"

# Call Perl script to run reverse complement and run cyclic permutations
perl scripts/process_motifs.pl "$sorted_shared_trs" "$cyclic_shared_trs" "$cyclic_rev_shared_trs"

echo "Cyclic permutation processing completed. Results stored in:"
echo "  - $cyclic_shared_trs"
echo "  - $cyclic_rev_shared_trs"

run_needle() {
    local input_file=$1
    local suffix=$2  # normal or revcomp
    local chunk_dir="chunks_${target_prefix}_${query_prefix}_${suffix}"
    mkdir -p "$chunk_dir"

    split -l 10000 "$input_file" "$chunk_dir/chunk_"

    for chunk in "$chunk_dir"/chunk_*; do
        chunk_subdir="${chunk}_subdir"
        mkdir -p "$chunk_subdir"
        mv "$chunk" "$chunk_subdir/"

        cd "$chunk_subdir" || exit
        split -l 1 "$(basename "$chunk")" line_

        for line_file in line_*; do
            awk 'BEGIN {FS="\t"; OFS="_"} {print ">"$1, $2, $3, $4"\n"$5"\n"">"$6, $7, $8, $9, $11, $12, $13, $14"\n"$10}' "$line_file" > "$line_file.fa"
            rm "$line_file"
        done

        parallel -j "$threads" 'needle -asequence {} -bsequence {} -auto -gapopen 10 -gapextend 0.5 -outfile {/.}.out' ::: *.fa

        for outfile in *.out; do
            filename=$(basename -- "$outfile")
            sed -i '13,42d' "$outfile"
            cat "$outfile" "${filename%.out}.fa" > temp_file
            mv temp_file "$outfile"
            rm "${filename%.out}.fa"
        done

        score_file="${suffix}_scores.txt"
        bedloc_file="${suffix}_locations.txt"
        output_file="sim_score_overlap${overlap_perc}_${target_prefix}_${query_prefix}_${suffix}.txt"
        filtered_file="sim_score_overlap${overlap_perc}_${target_prefix}_${query_prefix}_${suffix}_filtered.txt"

        grep "Similarity" *.out | grep -o "[0-9]*\.[0-9]" > "$score_file"
        grep ">${query_prefix}" *.out | sed 's/.*>//' > "$bedloc_file"
        paste "$bedloc_file" "$score_file" > "$output_file"

        cd - > /dev/null || exit
    done
}

chunk_dir="chunks_${target_prefix}_${query_prefix}_normal"
chunk_dir_rev="chunks_${target_prefix}_${query_prefix}_revcomp"

# Step 3: Run needle on both standard and reverse complement TR sets
echo "Running Needle on motif with normal orientation for $target_prefix (as target)."
run_needle "$cyclic_shared_trs" "normal" &

echo "Running Needle on motif with reverse complement for $target_prefix (as target)."
run_needle "$cyclic_rev_shared_trs" "revcomp" &

wait

# Step 4: Select the best alignment score from both runs
echo "Calculating similarity scores"

# Locate all files for normal and reverse complement
normal_output="${target_prefix}_${query_prefix}_normal_combined.txt"
revcomp_output="${target_prefix}_${query_prefix}_revcomp_combined.txt"
best_score_output="overlap${overlap_perc}_${target_prefix}_${query_prefix}.bed"

find "$chunk_dir" -type f -name "*_normal.txt" -exec cat {} + > "${normal_output}"
find "$chunk_dir_rev" -type f -name "*_revcomp.txt" -exec cat {} + > "${revcomp_output}"

# Select best score from both sets of files
echo "Selecting the best alignment score..."
awk 'FNR==NR {score[$1]=$2; next}
     {if ($1 in score && $2 > score[$1]) score[$1]=$2}
     END {for (key in score) print key, score[key]}' \
     "${normal_output}" "${revcomp_output}" > "$best_score_output"

filtered_output="overlap${overlap_perc}_sim${align_perc}_${target_prefix}_${query_prefix}.bed"

awk -v align_perc="$align_perc" '$2 >= align_perc' "$best_score_output" > "$filtered_output"

sed -i 's/_/\t/g' "$filtered_output"
sed -i 's/ /\t/g' "$filtered_output"
sed -i 's/[[:space:]]*$//' "$filtered_output"

# Organize file into BED structure
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $2, $3, $4, $1, $5, $6, $7, $8, $9}' "$filtered_output"

echo ""
echo "Region overlap assessment and pairwise motif alignment similarity completed for $target_prefix as target."
echo ""
echo "Tandem Repeats for TARGET $target_prefix and QUERY $query_prefix with $overlap_perc overlap and $align_perc similarity are saved in $final_output."
