#!/bin/bash

usage() {
  echo "Usage: $0 -a <fst_genome_shared_trs> -b <snd_genome_shared_trs> -c <fst_genome_catalog> -d <snd_genome_catalog>"
  exit 1
}

# Parse command-line options
while getopts ":a:b:c:d:" opt
do
  case ${opt} in
    a) fst_genome_shared_trs="$OPTARG" ;;
    b) snd_genome_shared_trs="$OPTARG" ;;
    c) fst_genome_catalog="$OPTARG" ;;
    d) snd_genome_catalog="$OPTARG" ;;
    *) usage ;;
  esac
done

# Check if all arguments are provided
if [ -z "$fst_genome_shared_trs" ] || [ -z "$snd_genome_shared_trs" ] || [ -z "$fst_genome_catalog" ] || [ -z "$snd_genome_catalog" ]
then
  usage
fi

# Intersect files resulting from the previous alignment step (align_lifted_TRs.sh) from both species
# Get index positions from target in fst_genome_shared_trs and compare to coordenates of snd_genome_shared_trs where the same species served as the query
awk 'BEGIN {FS="\t"; OFS="\t"} {print $5, $6, $7, $8}' "$fst_genome_shared_trs" > tmp1
sort -k1,1 -k2,2n -k3,3 tmp1 | uniq > tmp1_sorted

bedtools intersect -a tmp1_sorted -b "$snd_genome_shared_trs" -wb > tmp2

# Keep only columns of interest and sort file
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $1, $2, $3, $4, $9, $10, $11, $12}' tmp2
sort -k1,1 -k2,2n -k3,3 tmp2 > tmp2_sorted

# Intersect file with TRF catalog for the first genome and rearrange to get index positions for the second genome
bedtools intersect -a "$fst_genome_catalog" -b tmp2_sorted -f 1 -F 1 -wa -wb > tmp3

gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $15, $16, $17, $18, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' tmp3
sort -k1,1 -k2,2n -k3,3 tmp3 > tmp3_sorted

# Intersect file with TRF catalog for the second genome and sort file
bedtools intersect -a "$snd_genome_catalog" -b tmp3_sorted -f 1 -F 1 -wa -wb > tmp4

# Keep columns of interest and rearrange them to keep the first genome in the initial fields
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' tmp4

sort -k1,1 -k2,2n -k3,3 tmp4 | uniq > tmp4_sorted

# Function to check if TRs from one genome match more than one TR in the other genome
# When matching one to many, keep TR with smaller motif length or larger total length when motif lengths are the same.

process_cluster() {
  input_file=$1
  output_file=$2

  bedtools cluster -d 4 -i "$input_file" > "${output_file}_clustered"

  awk '{
      cluster_id = $21;  # Cluster column
      motif_len = $14 + 0;   # Convert to numeric for safety
      total_len = $15 + 0;

      # If cluster ID already exists, compare values
      if (cluster_id in best) {
          split(best[cluster_id], fields, "\t");

          small_motif_len = fields[13] + 0;  # Column 14 (1-based index)
          large_total_len = fields[14] + 0;  # Column 15

          # Apply selection rules
          if (motif_len < small_motif_len || (motif_len == small_motif_len && total_len > large_total_len)) {
              best[cluster_id] = $0;  # Update with better entry
          }
      } else {
          best[cluster_id] = $0;  # Store first occurrence
      }
  } END {
      for (c in best) print best[c];
  }' "${output_file}_clustered" > "$output_file"
}

# Check one-to-many matches for first genome
process_cluster tmp4_sorted tmp5

# Repeat for second genome!
# Rearrange index positions
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' tmp5

sort -k1,1 -k2,2n -k3,3 tmp5 | uniq > tmp5_sorted

# Check one-to-many matches for second genome
process_cluster tmp5_sorted tmp6

# Keep first genome in initial fields and eliminate cliuster column
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' tmp6

sort -k1,1 -k2,2n -k3,3 tmp6 | uniq > homologous_tr_catalog.bed

# Add final column with TR identification
gawk -i inplace 'BEGIN {Fs=OFS="\t"} {print $0, "TR" NR}' homologous_tr_catalog.bed

# Remove temporary files
rm tmp*

echo ""
echo "The file homologous_tr_catalog.bed contains the putative homologous TR catalog for your species pair!"
