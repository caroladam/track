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
# Get index positions from the target in fst_genome_shared_trs and compare to coordinates of snd_genome_shared_trs where the same species served as the query
awk 'BEGIN {FS="\t"; OFS="\t"} {print $5, $6, $7, $8}' "$fst_genome_shared_trs" > tmp1
sort -k1,1 -k2,2n -k3,3 tmp1 > tmp1_sorted

bedtools intersect -a tmp1_sorted -b "$snd_genome_shared_trs" -wb > tmp2

# Keep only columns of interest and sort file
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $1, $2, $3, $4, $9, $10, $11, $12}' tmp2
sort -k1,1 -k2,2n -k3,3 tmp2 > tmp2_sorted

# Intersect file with TRF catalog for the first genome and rearrange to get index positions for the second genome
bedtools intersect -a "$fst_genome_catalog" -b tmp2_sorted -f 1 -F 1 -wa -wb > tmp3
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $14, $15, $16, $17, $1, $2, $3, $4, $5, $6, $7, $8, $9}' tmp3
sort -k1,1 -k2,2n -k3,3 tmp3 > tmp3_sorted

# Intersect file with TRF catalog for the second genome and sort file
bedtools intersect -a "$snd_genome_catalog" -b tmp3_sorted -f 1 -F 1 -wa -wb > tmp4

# Keep columns of interest and rearrange them to keep the first genome in the initial fields
gawk -i inplace 'BEGIN {FS="\t"; OFS="\t"} {print $14, $15, $16, $17, $18, $19, $20, $21, $22, $1, $2, $3, $4, $5, $6, $7, $8, $9}' tmp4

sort -k1,1 -k2,2n -k3,3 tmp4 | uniq > homologous_tr_catalog.bed

# Add final column with TR identification 
gawk -i inplace 'BEGIN {Fs=OFS="\t"} {print $0, "TR" NR}' homologous_tr_catalog.bed

# Remove temporary files
rm tmp*

echo ""
echo "The file homologous_tr_catalog.bed contains the putative homologous TR catalog for your species pair!"
