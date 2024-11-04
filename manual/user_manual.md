# Tutorial
This tutorial will guide you through using TRACK to identify and filter TRs in reference genomes, and pairwise compare TR catalogs across species. TRACK also includes instructions for genotyping TRs in PacBio HiFi data and performing population genetics analyses.

## Creating TR catalogs
**Obs:** If you already have the TR catalogs for your species of interest, skip Step 1.

**Prerequisites**

- [samtools](https://www.htslib.org/download/)
- [TRF (Tandem Repeats Finder)](https://tandem.bu.edu/trf/home)
- [BEDOPS](https://bedops.readthedocs.io/en/latest/)
- [bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html)

Ensure these tools are installed and available in your PATH or provide absolute paths for each tool.

**Configuration**

```
#config.yaml

fasta_path: "data/"                     # Path to input FASTA files
trf_dir: "~/Downloads/TRF-4.09.1/src"   # Path to TRF directory
trf_run_script: "scripts/run_TRF.sh"    # Path to TRF run script
filter_catalog_script: "scripts/filter_tr_catalog.sh" # Path to catalog filter script
output_prefix: "homo"                   # Prefix for output files

# TRF configuration parameters
matchscore: 2
mismatchscore: 5
indelscore: 7
pm: 80
pi: 10
minscore: 24
maxperiod: 2000
```

### **Usage**
1. **Prepare input files:** Place reference genome FASTA file in the directory specified in `fasta_path` within `config.yaml`. Adjust the path to TRF executable and output prefix within `config.yaml`.
2. **Run the pipeline:**
```
snakemake --cores <number_of_cores>
```

**Outputs**
- `<output_prefix>_catalog.no_overlaps.bed`: a catalog of TRs that have been filtered, merged, and sorted.
- 
Intermediate files are saved in:
- `trf_results/`: `.dat` files containing TR results per chromosome.
- `split_chr_fa/`: stores split chromosome FASTA files, which are deleted after cataloging is completed.

The `<output_prefix>_catalog.no_overlaps.bed` file contains the following fields: 
- `<Chromosome>` `<Start>` `<End>` `<TRlength>` `<MotifLength>` `<CopyNumber>` `<MotifSeq>` `<TRSeq>` `<SppID>`

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

**Note:** The Homology assessment step below expects this BED file structure. If you want to use your own TR catalog, make sure it follows the structure.

## Homology Assessment and Comparative TR Analysis

**Prerequisites**

- [Liftover Tools](https://genome.ucsc.edu/cgi-bin/hgLiftOver)
- [EMBOSS Needle](https://embossgui.sourceforge.net/demo/manual/needle.html)
- [bedtools](https://bedtools.readthedocs.io/en/latest/content/installation.html)
- [Chain files](https://genome.ucsc.edu/goldenpath/help/chain.html) between species of interest. Go to **DIY chain file** if you cannot find your desired chain files at [USCS Genome Browser](https://hgdownload.soe.ucsc.edu/downloads.html). To run the analysis with our example data, access chain files of T2T Human and Chimpanzee alignments [here](https://www.dropbox.com/home/track/chain_files).

**Configuration**

```
# config.yaml

# Paths to input files
input_bed_genome1: "data/homo_catalog.bed"
input_bed_genome2: "data/pantro_catalog.bed"

# Chain files for liftOver
genome1_to_genome2_chain: "data/homo_to_pantro.chain"
genome2_to_genome1_chain: "data/pantro_to_homo.chain"

# Directory for liftOver tool
liftOver_directory: "~/Downloads/"

# Output prefixes
output_prefix_genome1_to_genome2: "homo_to_pantro_lift"
output_prefix_genome2_to_genome1: "pantro_to_homo_lift"

# Genome identifiers
genome1: "homo"
genome2: "pantro"

# Paths to scripts
align_sh: "scripts/align_lifted_trs.sh"
homologous_catalog_sh: "scripts/get_putative_homologous_catalog.sh"
plot_tr_length: "scripts/plot_shared_tr_length.R"

# Similarity parameters
overlap_perc: "0.2"
align_perc: "95.0"
```

### **Usage**
1. **Prepare input files:** Place TR catalogs for both species and chain files corresponding to alignments in both directions in the `data/` directory. Adjust the path to LiftOver executable, genome identifiers, prefixes, and overlap and alignment similarity within `config.yaml`.
2. **Run the pipeline:**
```
snakemake --cores <number_of_cores>
```

 **Outputs**
- `homologous_tr_catalog.bed`: Contains putative homologous TRs between the two genomes.
- `homologous_tr_length_plot.svg`: Visual comparison of TR lengths in the homologous catalog for each genome.

**BONUS: DIY Chain file**

If the chain files for your species or assembly of interest are not available, you can produce a custom-made chain file with the following steps:

- Perform whole-genome alignment between the reference genomes of the species of interest. I recommend [minimap2](https://github.com/lh3/minimap2). Ensure that the output alignment is in PAF format - minimap2 generates PAF alignments by default.

  **Example**

  ./minimap2 --cs --eqx -cx asm20 `<path_to_spp1_ref>` `<path_to_spp2_ref>` > `<spp1_spp2.paf>

- Convert PAF alignment to CHAIN using [paf2chain.py](https://github.com/AndreaGuarracino/paf2chain/tree/v0.1.1)

  **Example**
  
  ./paf2chain -i `<spp1_spp2.paf>` > `<spp1_spp2.chain>`


## Genotyping Tandem Repeats

You can use your new catalog generated from Step 1 to genotype TRs in your population data!
TRACK uses [Tandem Repeat Genotyping Tool (TRGT)](https://github.com/PacificBiosciences/trgt) to genotype TRs in PacBio HiFi data. 

**Prerequisites**
- [Tandem Repeat Genotyping Tool (TRGT)](https://github.com/PacificBiosciences/trgt)
- [samtools](https://www.htslib.org/download/)
- [bcftools](https://github.com/samtools/bcftools)
- Alignment files in BAM format.

TRGT has an excellent [user manual](https://github.com/PacificBiosciences/trgt/blob/main/docs/tutorial.md) with examples, but below are some tips to go through genotyping smoothly.

### Prep your data for TRGT

**1. Check for correct BAM headers**

TRGT expects BAM headers generated by the aligners [minimap2](https://github.com/lh3/minimap2) or [pbmm2](https://github.com/PacificBiosciences/pbmm2) (a wrapper for minimap2 specific for PacBio data).
If you used an alternative alignment tool, _don't worry!_ You might not need to realign your data. You can rehead your BAM files to match the expected header.

**1.2 Reheading incorrect BAM files**

`samtools view -H <minimap_file.bam> > <correct_header.bam>`: Extract BAM header from minimap2 or pbmm2 alignment.

`samtools reheader <correct_header.bam> <your_file.bam> > <reheaded_file.bam>`: Rehead BAM file from other alignment tool

**2. Sort and index your files**

TRGT requires alignment files to be sorted and indexed.

`samtools sort -o <sorted.bam> <reheaded_file.bam>`: Sort your newly reheaded BAM file (or BAM file generated by minimap2).

`samtools index <sorted.bam> <sorted.bam.bai>`: Index your sorted BAM file.

**3. Catalog structure**

TRGT expects the following structure for the TR catalog:

`chrA	10001	10061	ID=TR1;MOTIFS=CAG;STRUC=(CAG)n`

To adjust the BED file produced in the **Creating TR catalogs** step of **TRACK**, run:
```
bash ./scripts/make_trgt_catalog.sh <output_prefix>_catalog.no_overlaps.bed
```

## Genotype your TRs!
**Configuration**

```
# config.yaml
reference_genome: "data/reference.fa"
tandem_repeat_catalog: "data/catalog.bed" #Make sure the file follows TRGT expected structure
bam_dir: "data/bam"
threads: "4"  # Adjust as needed
trgt_path: "~/Downloads/trgt-0.9.0/trgt-v1.0.0-x86_64-unknown-linux-gnu"
```
### **Usage**
```
snakemake --cores <number_of_cores>
```

**Outputs**
- Sorted VCF and BAM files for each genotyped TR are stored in `outputs/`
- Merged VCF file containing multi-sample TR variants are in `merged.vcf.gz`
  
## Population Genetic Analyses
This Snakemake workflow performs basic population genetic analyses by calculating observed heterozygosity and genetic diversity metrics from a merged VCF file. The analysis utilizes an R script to process the VCF and population information files and outputs both summary statistics (in CSV format) and visualizations (in SVG format).

**Configuration**

```
# config.yaml
vcf_file: "data/merged.vcf.gz"  # Path to the VCF file
popinfo_file: "data/popinfo.txt"  # Path to the population info file
```
**<popinfo_file>** example:
```
sample  pop
ind1  popA
ind2  popB
ind3  popA
```
**Note**: Ensure that the sample names in the `popinfo_file` match the individual names in the `vcf_file`.

### **Usage**
```
snakemake --cores <number_of_cores>
```

**Output**

- `<vcf_prefix>_observed_heterozygosity.csv`: Observed heterozygosity (Ho) per population.
- `<vcf_prefix>_genetic_diversity.csv`: Genetic diversity (Hs) per population.
- `violin plots`: Visualizations of Ho and Hs values per population.

**Example**

The following example shows observed heterozygosity estimates from a random subset of 1,000 TR loci from TRACK's human T2T TR catalog genotyped in individuals of the [Human Pangenome Reference Consortium (HPRC)](https://github.com/human-pangenomics/HPP_Year1_Data_Freeze_v1.0).

![Violin plots of Observed Heterozygosity (Ho)](https://github.com/caroladam/track/blob/main/popgen_analysis/human_merged_random_subset_observed_heterozygosity.svg)
