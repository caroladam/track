# TRACK - Tandem Repeat Analysis and Comparison Kit

The Tandem Repeat Analysis and Comparison Kit (TRACK) is an automated Snakemake workflow designed to identify and compare tandem repeats (TRs) across species, and genotype catalogs in population-wide data. The pipeline includes scripts for creating and filtering TR catalogs from reference genomes, generating catalogs of putative homologous TRs between species pairs, and performing population-level genotyping and basic population genetics analyses. Additionally, TRACK features tools for visualizing TR length comparisons between species and essential population genetic metrics, such as genetic diversity and observed heterozygosity.

![track_workflow](https://github.com/caroladam/track/blob/main/manual/track_workflow.png)

**Basic usage**

To get started with TRACK:
```
# Clone TRACK repository:
git clone https://github.com/caroladam/track.git
cd track

# Create and activate the conda environment:
conda env create -f environment.yml
conda activate track_env

# Get necessary files to run examples:
bash ./setup.sh
```

Each directory within the repository contains example input data, allowing you to perform test runs and familiarize yourself with TRACK's functionalities.

**Repository structure**
```
track/
├── tr_catalog
│   ├── config.yaml
│   ├── data
│   ├── scripts
│   └── Snakefile
├── genotype
│   ├── config.yaml
│   ├── data
│   ├── homo_catalog.bed
│   ├── scripts
│   └── Snakefile
├── homology
│   ├── config.yaml
│   ├── data
│   ├── scripts
│   └── Snakefile
└── popgen_analysis
    ├── config.yaml
    ├── data
    ├── scripts
    └── Snakefile
```
To perform test runs, simply enter the subdirectories and type:
```
snakemake
```

## User's manual
For detailed instructions on setting up configuration files and executing the pipeline with your data, please refer to the [user's manual](https://github.com/caroladam/track/blob/main/manual/user_manual.md)

### Available catalogs
You can download the catalogs of TRs identified in T2T genomes of ape species using TRACK in the links below. Reference genomes used to create TR catalogs were obtained from the T2T Consortium [Primate Project v2.0](https://github.com/marbl/Primates?tab=readme-ov-file) and [CHM13 Project v2.0](https://github.com/marbl/CHM13).

Filtered catalogs can be downloaded here:
- _[Homo sapiens](https://www.dropbox.com/scl/fi/szsyk72fyc0gwlkdr2sie/homo_trf.bed.no_overlaps?rlkey=x85jot9gkuoertl3xa6oac1tz&st=m1oz5zvt&dl=0)_
- _[Pan troglodytes](https://www.dropbox.com/scl/fi/1oatewfdrztf3tzekozst/chimp_trf.bed.no_overlaps?rlkey=1xelhe5922lejnupqq3n8b2hc&st=2zha2bm8&dl=0)_
- _[Pan paniscus](https://www.dropbox.com/scl/fi/dqaqhh08d6z2isncq0h3o/bonobo_trf.bed.no_overlaps?rlkey=h0rvsi81e734y5d8hlfrsyoup&st=rsfomo0h&dl=0)_
- _[Gorilla gorilla](https://www.dropbox.com/scl/fi/fuvk9lgyyj3r3al8znb7d/gorilla_trf.bed.no_overlaps?rlkey=ojaqj7z06xwfxabysv3vuhtvo&st=jdc3uuu6&dl=0)_
- _[Pongo abelii](https://www.dropbox.com/scl/fi/og45rmuuj5rrnax1sz7au/pabelii_trf.bed.no_overlaps?rlkey=pft6kpbq7ouhwsvajcvh4hwcp&st=00e4lrmc&dl=0)_
- _[Pongo pygmaeous](https://www.dropbox.com/scl/fi/okib8baqljqr8t0sk0ipc/ppyg_trf.bed.no_overlaps?rlkey=hvrh87v930wjchpqkbp7oofoo&st=4mkwatsw&dl=0)_
- _[Symphalangus syndactylus](https://www.dropbox.com/scl/fi/jfw6bmjuhkw5kyzi4olp4/symsyn_trf.bed.no_overlaps?rlkey=vngw7jzmr7ejnuynd37mmeu7k&st=fsdurk82&dl=0)_

### ⚠️ Tool Development Warning ⚠️
This repository is in constant development and improvement, and users may encounter changes and updates. We recommend regularly checking for updates and reviewing the documentation to ensure optimal usage of the pipeline.

## Questions?
Send your questions or suggestions to carolinaladam@gmail.com
