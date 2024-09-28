# Tutorial
This tutorial will guide you through using TRACK to identify and filter TRs in reference genomes, and pairwise compare TR catalogs across species. TRACK also includes instructions for genotyping TRs in PacBio HiFi data and performing population genetics analyses.

## 1. Creating TR catalogs
**Obs:** If you already have the TR catalogs for your species of interest, skip Step 1.

**Prerequisites**

- [samtools](https://www.htslib.org/download/)
- [TRF (Tandem Repeats Finder)](https://tandem.bu.edu/trf/home)
- [BEDOPS](https://bedops.readthedocs.io/en/latest/)

Ensure these tools are installed and available in your PATH or provide absolute paths for each tool.

### 1A. [split_chr_fa.sh](https://github.com/caroladam/track/blob/main/tr_catalog/split_chr_fa.sh)

This script processes all .fa files in a directory, splitting them by chromosome and creating index files.

**Usage**

```
./split_chr_fa.sh <path_to_fasta_files>
```

### 1B. [run_trf.sh](https://github.com/caroladam/track/blob/main/tr_catalog/run_TRF.sh)

This script runs TRF on the indexed FASTA files using specific parameters (if necessary, modify TRF parameters within the script).

**Usage**

```
./run_trf.sh <path_to_fasta_files> <path_to_trf_executable>
```

This will process all .fa files in the specified directory with the following TRF parameters:

- Match Score: 2
- Mismatch Score: 5
- Indel Score: 7
- Percent Matches: 80
- Percent Indels: 10
- Minimum Score: 24
- Maximum Period: 2000

### 1C. [filter_tr_catalog.sh](https://github.com/caroladam/track/blob/main/tr_catalog/filter_tr_catalog.sh)

This script filters and processes the TRF output files, generating a TR catalog.

**Usage**

```
./filter_tr_catalog.sh <path_to_trf_results_directory> <output_file_name>
```

**Outputs**

- `<output_file_name>.sorted.bed`: Sorted TR catalog.
- `<output_file_name>.merged.bed`: Merged overlapping TRs.
- `<output_file_name>.no_overlaps.bed`: Filtered TRs without overlaps.

The BED structured output files contain the following fields: 
- `<Chromosome>`  `<StartIndex>`  `<EndIndex>`  `<TRlength>`  `<MotifLength>`  `<CopyNumber>`  `<MotifSequence>`  `<TRSequence>`  `<SpeciesID>`

**Example:**
```
chr1	7470	7481	11	1	12.0	T	TTTTTTTTTTTT	homo
chr1	8006	8019	13	4	3.5	AAAG	AAAGAAAGAAAGAA	homo
chr1	9530	9549	19	6	3.3	CTAACC	CTAATCCTAACCCTAACCCT	homo
chr1	9605	9653	48	6	8.2	CTGACC	CTGACCCTTACTTTGACCCTGACTTTGATCTCGACCCTGACCATGACCC	homo
chr1	9692	9715	23	6	4.0	ATCCTA	ATCCTAATCCTATGCCTAACCCTA	homo
chr1	11719	11739	20	8	2.6	CAGTCCCT	CAGTCCCTCAGTCCCTCTGTC	homo
chr1	12553	12571	18	1	19.0	A	AAAAAAAAAAAAAACAAAA	homo
```

**Note:** The remaining steps in this tutorial expect this BED file structure.

## 2. Perform Liftover analysis

**Prerequisites**

- [Liftover Tools](https://genome.ucsc.edu/cgi-bin/hgLiftOver)
  
Ensure this tool is installed and available in your PATH or provide absolute paths for each tool.

### 2A. [run_liftover.sh](https://github.com/caroladam/track/blob/main/shared_trs/run_liftover.sh)

This script runs a cross-species Liftover analysis. It takes TR coordinates from a `target` genome and identifies the corresponding coordinates in a `query` genome.

**Usage**

```
./run_liftover.sh -i <input_bed> -c <chain_file> -o <output_bed> -u <unmapped_file> -l <liftOver_dir>
```

**Arguments**
- -i **<input_bed>**: Path to the input BED file containing the index position of the TRs you want to lift from a `target genome` in a `query genome`.
- -c **<chain_file>**: Path to the chain file that describes the alignment between the two assemblies (`query` x `target`).
- -o **<output_bed>**: Path to the output BED file where the TRs from the `target genome` successfully lifted in the `query genome` will be saved.
- -u **<unmapped_file>**: Path to the output file where the TRs that couldn't be lifted will be saved.
- -l **<liftOver_dir>**: Path to the directory containing the liftOver executable.

**Example**

Lifting TRs identified in the `Homo sapiens` reference genome to get the corresponding coordinates in the `Pan troglodytes` reference genome.

```
./liftOver_script.sh -i homo_no_overlaps.bed -c homo_to_pantro.chain -o homo_to_pantro_liftover.bed -u unMapped_homo_to_pantro -l /home/downloads/liftover
```

**DIY Chain file**

You can download available chain files directly from the [USCS Genome Browser](https://hgdownload.soe.ucsc.edu/downloads.html). If the chain files for your species or assembly of interest are not available, you can produce a custom-made chain file with the following steps:

- Perform whole-genome alignment between the reference genomes of the species of interest. I recommend [minimap2](https://github.com/lh3/minimap2). Ensure that the output alignment is in PAF format - minimap2 generates PAF alignments by default.

  **Example**

  ./minimap2 --cs --eqx -cx asm20 `<path_to_spp1_ref>` `<path_to_spp2_ref>` > `<spp1_spp2.paf>

- Convert PAF alignment to CHAIN using [paf2chain.py](https://github.com/AndreaGuarracino/paf2chain/tree/v0.1.1)

  **Example**
  
  ./paf2chain -i `<spp1_spp2.paf>` > `<spp1_spp2.chain>`

## 3. Get homologous TRs for species pair

**Prerequisites**
- [bedtools](https://bedtools.readthedocs.io/en/latest/index.html)
- [EMBOSS Needle](https://embossgui.sourceforge.net/demo/manual/needle.html)
  
### 3A. [align_lifted_TRs.sh](https://github.com/caroladam/track/blob/main/shared_trs/align_lifted_trs.sh)

This script processes tandem repeat (TR) data from two genomes, aligns the TR motif sequences, and calculates alignment similarity scores.
The script expects specific BED file fields - those resulting from [Step 1C](https://github.com/caroladam/TR-evolution-analyses/blob/main/tr_catalog/filter_tr_catalog.sh). If you are using your own TR catalogs, please refer to the same BED file structure.

**Usage**

```
./align_lifted_TRs.sh -a <lifted_trs> -b <query_tr_list> -c <target_prefix> -d <query_prefix>
```

**Arguments**
- -a **<lifted_trs>**: Lifted TRs file (.bed) from the target genome.
- -b **<query_tr_list>**: Filtered TRF catalog file (.bed) from the query genome.
- -c **<target_prefix>**: Prefix/ID of the target genome.
- -d **<query_prefix>**: Prefix/ID of the query genome.

**Outputs**

- `shared_trs.bed`: TRs on the TRF query genome catalog lifted from the target genome and have at least 50% reciprocal overlap.
- `sim_score_<target_prefix>_<query_prefix>`: File containing similarity scores for the pairwise alignment of TR motifs from target and query genomes.
- `sim_score_50_50_<target_prefix>_<query_prefix>.bed`: Filtered BED file with overlapping TRs having at least 50% motif alignment similarity

### 3B. [get_putative_homology.sh](https://github.com/caroladam/track/blob/main/shared_trs/get_putative_homologous_catalog.sh)

This script processes tandem repeats (TRs) shared between two genomes and creates a putative homologous TR catalog for a species pair.

**Usage**

```
./get_putative_homology.sh -a <fst_genome_shared_trs> -b <snd_genome_shared_trs> -c <fst_genome_catalog> -d <snd_genome_catalog>
```

**Parameters**
- -a **<fst_genome_shared_trs>**: Shared TRs file (.bed) from previous alignment step - first genome
- -b **<snd_genome_shared_trs>**: Shared TRs file (.bed) from previous alignment step - second genome
- -c **<fst_genome_catalog>**: TRF catalog for the first genome
- -d **<snd_genome_catalog>**: TRF catalog for the second genome

**Output**

The final output file is named `homologous_tr_catalog.bed` and contains the putative homologous TR catalog for the species pair.

### 3C. [run_plot_shared_tr.sh](https://github.com/caroladam/track/blob/main/shared_trs/run_plot_shared_tr.sh)

This script calls R to create a scatterplot comparing TR lengths between two species based on the file `homologous_tr_catalog.bed` made in the previous step.

**Usage**

```
./run_plot_tr_length.sh <r_script> <homologous_tr_catalog.bed> <fst_spp_id> <snd_spp_id> <output_plot>
```

**Parameters**
- **<r_script>:** Path to R script plot_tr_length.R
- **<homologous_tr_catalog.bed>:** Homologous TR catalog created in the previous step
- **<fst_spp_id>:** ID for the first species in the homologous TR catalog
- **<snd_spp_id>:** ID for the second species in the homologous TR catalog
- **<output_plot>:** Output name for the scatterplot (**Note:** must be in SVG)

**Output**

The final output is a scatterplot with a regression line with R2 value and a diagonal line (slope = 1) for reference.

**Example**

The following example shows the total length comparison of TR shared between the human and chimpanzee T2T reference genomes:

![Scatterplot of human and chimp shared TR length](https://github.com/caroladam/track/blob/main/shared_trs/homo_chimp_length.png)

# Genotyping Tandem Repeats

You can use your new catalog generated from Step 1 to genotype TRs in your population data!
TRACK uses [Tandem Repeat Genotyping Tool (TRGT)](https://github.com/PacificBiosciences/trgt) to genotype TRs in PacBio HiFi data. 

**Prerequisites**
- [Tandem Repeat Genotyping Tool (TRGT)](https://github.com/PacificBiosciences/trgt)
- [samtools](https://www.htslib.org/download/)
- [bcftools](https://github.com/samtools/bcftools)

TRGT has an excellent [user manual](https://github.com/PacificBiosciences/trgt/blob/main/docs/tutorial.md) with examples, but below are some tips to go through genotyping smoothly.

## Prep your data for TRGT

**Check for correct BAM headers**

TRGT expects BAM headers generated by the aligners [minimap2](https://github.com/lh3/minimap2) or [pbmm2](https://github.com/PacificBiosciences/pbmm2) (a wrapper for minimap2 specific for PacBio data).
If you used an alternative alignment tool, _don't worry!_ You won't need to realign your data. You can rehead your BAM files to match the expected header.

**Reheading incorrect BAM files**

`samtools view -H <minimap_file.bam> > <correct_header.bam>`: Extract BAM header from minimap2 or pbmm2 alignment.

`samtools reheader <correct_header.bam> <your_file.bam> > <reheaded_file.bam>`: Rehead BAM file from other alignment tool

### Sort and index your files
TRGT requires alignment files to be sorted and indexed.

**Usage**

`samtools sort -o <sorted.bam> <reheaded_file.bam>`: Sort your newly reheaded BAM file (or BAM file generated by minimap2).

`samtools index <sorted.bam> <sorted.bam.bai>`: Index your sorted BAM file.

### Run [trgt_genotype.sh](https://github.com/caroladam/track/blob/main/genotype/trgt_genotype.sh)
This script is designed to automate the process of tandem repeat genotyping using the TRGT genotype function. After genotyping, it sorts and indexes both VCF and BAM output files.

**Usage**

```
./genotype_tr.sh -r <reference_genome_file> -t <tandem_repeat_catalog> -b <bam_file> -p <output_prefix> -n <threads> -g <trgt_path>
```

**Parameters**
- -r **<reference_genome_file>**: Path to the reference genome file (FASTA format).
- -t **<tandem_repeat_catalog>**: Path to the tandem repeat catalog file (TRF results or custom TR catalog from Step 1).
- -b **<bam_file>**: Path to the BAM file containing the aligned reads.
- -p **<output_prefix>**: Output prefix for naming the resulting files (VCF and BAM).
- -n **<threads>**: Number of threads to use for TRGT genotyping.
- -g **<trgt_path>**: Path to the directory where TRGT is installed.

**Outputs**

VCF Files:
- The initial VCF output is sorted and saved as `output_prefix_sorted.vcf.gz` and contains the TR variants genotyped in the sample.
- An index is created for this sorted VCF file `output_prefix_sorted.vcf.gz.csi`.

BAM Files:
- The BAM output is sorted and saved as `output_prefix_sorted.spanning.bam` and contains the chunks of the HiFi reads that span the TR variant.
- An index is created for the sorted BAM file `output_prefix_sorted.spanning.bam.bai`.

### Run [trgt_merge.sh](https://github.com/caroladam/track/blob/main/genotype/trgt_merge.sh)
This script merges multiple VCF files generated from [trgt_genotype.sh](https://github.com/caroladam/TR-evolution-analyses/blob/main/genotype/trgt_genotype.sh) using the TRGT merge function.

**Usage**

```
./merge_trgt.sh -v <vcf_files_dir> -p <output_prefix> -g <trgt_path> [-f <final_output_directory>]
```

**Parameters**
- -v **<vcf_files_dire>**: Directory containing the sorted VCF files.
- -p **<output_prefix>**: Prefix for the output merged VCF files.
- -g **<trgt_path>**: Path to the trgt executable.
- -f **<final_output_directory> (optional)**: Directory where the merged files will be saved. Defaults to the current directory if not specified.

**Output**

The final output is saved as `output_prefix_merged.vcf.gz` and contains the merged TR variants across all genotyped samples.

# Population genetics summary statistics
## Run [get_summary_stats.sh](https://github.com/caroladam/track/blob/main/popgen_analysis/get_summary_stats.sh)

This script processes a VCF file and a population assignment file to calculate basic population genetic statistics using R, then generates violin plots for observed heterozygosity (Ho) and genetic diversity (Hs) across populations.

**Usage**

```
./run_genetic_analysis.sh -v <vcf_file> -p <popinfo_file>
```

**Parameters**
- -v **<vcf_file>**: Path to the VCF file containing merged genotypes
- -p **<popinfo_file>**: Path to the population assignment file
  
**<popinfo_file>** example:
```
sample  pop
ind1  popA
ind2  popB
ind3  popA
```
**Note**: Ensure that the sample names in the `popinfo_file` match the individual names in the `vcf_file`.

**Output**

- `vcf_prefix_observed_heterozygosity.csv`: Observed heterozygosity (Ho) per population.
- `vcf_prefix_genetic_diversity.csv`: Genetic diversity (Hs) per population.
- `violin plots`: Visualizations of Ho and Hs values per population.

**Example**

The following example shows observed heterozygosity estimates from a random subset of 1,000 TR loci from TRACK's human T2T TR catalog genotyped in individuals of the [Human Pangenome Reference Consortium (HPRC)](https://github.com/human-pangenomics/HPP_Year1_Data_Freeze_v1.0).

![Violin plots of Observed Heterozygosity (Ho)](https://github.com/caroladam/track/blob/main/popgen_analysis/human_merged_random_subset_observed_heterozygosity.svg)
