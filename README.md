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
**While we are not formally supporting TRACK use on MacOS**, we are providing guidelines and tips to help MacOS users utilize TRACK's functionalities.

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
- _[Homo sapiens](https://www.dropbox.com/scl/fi/sjmldnebu0acte36yzh18/homo_catalog.no_overlaps.bed?rlkey=dl2jbwjc3jzfycw6lyks5z5ln&st=vf5q3di7&dl=0)_
- _[Pan troglodytes](https://www.dropbox.com/scl/fi/crr1pz10zvhbets8gxxhx/pantro_catalog.no_overlaps.bed?rlkey=q67hr5jxx5czde9wd0coq80a4&st=s03q81jp&dl=0)_
- _[Pan paniscus](https://www.dropbox.com/scl/fi/o07s0q44luw25ymhyitc1/bonobo_catalog.no_overlaps.bed?rlkey=xzrx9a1513eh95ebnmoc5siz6&st=wy7oivrm&dl=0)_
- _[Gorilla gorilla](https://www.dropbox.com/scl/fi/cz1ertfc6xmddequax03t/gorilla_catalog.no_overlaps.bed?rlkey=ba59kh6ktfsbwgougybvu1e3p&st=drpqyd0g&dl=0)_
- _[Pongo abelii](https://www.dropbox.com/scl/fi/b7klw23lzkl3wnrom7ojj/pabelii_catalog.no_overlaps.bed?rlkey=ofq6u7iw1u0yprnfu8yt4s5hi&st=moas0rfm&dl=0)_
- _[Pongo pygmaeous](https://www.dropbox.com/scl/fi/wwq1v8ssipa98tyc878l9/ppyg_catalog.no_overlaps.bed?rlkey=v2cs4f1qi8qn25p9o31uotygg&st=9hzsuqx5&dl=0)_
- _[Symphalangus syndactylus](https://www.dropbox.com/scl/fi/m1bzciwtg5dgsz3y52gmz/symsyn_catalog.no_overlaps.bed?rlkey=ezcvzodw3ixrwsvensvpuo5w0&st=cf9htjdd&dl=0)_

An additional TR catalog for the Rhesus macaque is now available. The reference genome used to create this catalog was obtained from the [T2T-MMU8 QV100 project](https://github.com/zhang-shilong/T2T-MMU8):
- _[Macaca mulatta](https://www.dropbox.com/scl/fi/ybuie7ep1sz97905furfb/macaca_catalog.no_overlaps.bed?rlkey=vkvcg95v4aqns07sg56qecjok&st=ynpoybxp&dl=0)_ 

### ⚠️ Tool Development Warning ⚠️
This repository is constantly being developed and improved; users may encounter changes and updates. We recommend regularly checking for updates and reviewing the documentation to ensure optimal pipeline usage.

## Questions?
Send your questions or suggestions to carolinaladam@gmail.com
