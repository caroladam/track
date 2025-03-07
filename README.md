# TRACK - Tandem Repeat Analysis and Comparison Kit

The Tandem Repeat Analysis and Comparison Kit (**TRACK**) is an automated Linux-based Snakemake workflow designed to identify and compare tandem repeats (TRs) across species, and genotype catalogs in population-wide data. The pipeline includes scripts for creating and filtering TR catalogs from reference genomes, generating catalogs of putative homologous TRs between species pairs, and performing population-level genotyping and basic population genetics analyses. Additionally, TRACK features tools for visualizing TR length comparisons between species and essential population genetic metrics, such as genetic diversity and observed heterozygosity.

![track_workflow](https://github.com/caroladam/track/blob/main/manual/track_workflow.png)

**Installation and set up**

## **Linux**
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

**Updating TRACK**

If you already have track_env in your conda environments but need to update to a new version:
```
conda env update --name track_env --file environment.yml --prune
```

## **MacOS**

TRACK is a Linux-based tool. While most required dependencies should work on MacOS via conda-forge or bioconda, some exceptions may require installation via Homebrew or manual setup.
**We do not provide full support for MacOS**, but we offer some tips and suggestions to help MacOS users utilize TRACK's functionalities.

```
# Clone TRACK repository
git clone https://github.com/caroladam/track.git
cd track

# Create and activate the conda environment:
conda env create -f environment.yml
conda activate track_env

# Get necessary files to run examples:
bash ./setup.sh

# If not already, install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Libraries that require Homebrew installation
brew install gawk gcc coreutils postgresql libpq gnu-sed gnu-tar

# Software that require Homebrew installation
brew install ucsc-kent-tools emboss
```
**Tools that require manual installation**
- Tandem Repeat Finder (TRF) - necessary for TR catalog building. Pre-compiled versions and installation instructions [here](https://github.com/Benson-Genomics-Lab/TRF?tab=readme-ov-file#pre-compiled-versions)!
- Tandem Repeat Genotyping Tool (TRGT) - necessary for TR genotyping on long-read data. Source code and instructions available [here](https://github.com/PacificBiosciences/trgt?tab=readme-ov-file)!


## **TRACK Repository structure**

Each directory within the repository contains example input data, allowing you to perform test runs and familiarize yourself with TRACK's functionalities.

```
track/
├── environment.yml
├── LICENSE
├── README.md
├── setup.sh
├── genotype
│   ├── config.yaml
│   ├── data
│   ├── scripts
│   └── Snakefile
├── homology
│   ├── config.yaml
│   ├── data
│   ├── scripts
│   └── Snakefile
├── manual
│   ├── example_plots
│   ├── track_workflow.png
│   └── user_manual.md
├── popgen_analysis
│   ├── config.yaml
│   ├── data
│   ├── scripts
│   └── Snakefile
└── tr_catalog
    ├── config.yaml
    ├── data
    ├── scripts
    └── Snakefile

14 directories, 14 files

```
To perform test runs, enter the subdirectories and type:
```
snakemake --cores <integer>
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
This repository is constantly being developed and improved; users may encounter changes and updates. We recommend regularly checking for updates and reviewing the documentation to ensure optimal pipeline usage.

## Questions?
Send your questions or suggestions to carolinaladam@gmail.com
