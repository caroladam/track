# TRACK - Tandem Repeat Analysis and Comparison Kit

The Tandem Repeat Analysis and Comparison Kit (TRACK) is an automated workflow designed to identify and compare tandem repeats (TRs) across species, and genotype catalogs in population-wide data. The pipeline includes scripts for creating TR catalogs from reference genomes, filtering TRs, generating catalogs of putative homologous TRs, and performing population-level genotyping and basic population genetics analyses. TRACK also includes scripts for visualizing TR length comparisons between species and key population genetics statistics. 

### ⚠️ Early version warning ⚠️
This repository contains an early version of the pipeline and is still under active development. Please note that breaking changes and improvements are expected as the project evolves. We recommend regularly checking for updates and reviewing documentation before using the pipeline.

### TRACK pipeline
![track_workflow](https://github.com/caroladam/track/blob/main/manual/track_workflow.png)

TRACK also provides catalogs of TRs identified in T2T genomes of ape species with [run_trf.sh](https://github.com/caroladam/TR-evolution-analyses/blob/main/run_trf.sh) and filtered with [TR_filter.sh](https://github.com/caroladam/TR-evolution-analyses/blob/main/TR_filter.sh). Reference genomes used to create TR catalogs were obtained from the T2T Consortium [Primate Project v2.0](https://github.com/marbl/Primates?tab=readme-ov-file) and [CHM13 Project v2.0](https://github.com/marbl/CHM13).

Filtered catalogs can be downloaded here:
- _[Homo sapiens](https://www.dropbox.com/scl/fi/szsyk72fyc0gwlkdr2sie/homo_trf.bed.no_overlaps?rlkey=x85jot9gkuoertl3xa6oac1tz&st=6gy3j4lh&dl=0)_
- _[Pan troglodytes](https://www.dropbox.com/scl/fi/1oatewfdrztf3tzekozst/chimp_trf.bed.no_overlaps?rlkey=1xelhe5922lejnupqq3n8b2hc&st=5bvncp4w&dl=0)_
- _[Pan paniscus](https://www.dropbox.com/scl/fi/dqaqhh08d6z2isncq0h3o/bonobo_trf.bed.no_overlaps?rlkey=h0rvsi81e734y5d8hlfrsyoup&st=h22ao6bu&dl=0)_
- _[Gorilla gorilla](https://www.dropbox.com/scl/fi/fuvk9lgyyj3r3al8znb7d/gorilla_trf.bed.no_overlaps?rlkey=ojaqj7z06xwfxabysv3vuhtvo&st=iblgbflk&dl=0)_
- _[Pongo abelii](https://www.dropbox.com/scl/fi/og45rmuuj5rrnax1sz7au/pabelii_trf.bed.no_overlaps?rlkey=pft6kpbq7ouhwsvajcvh4hwcp&st=ph4he45v&dl=0)_
- _[Pongo pygmaeous](https://www.dropbox.com/scl/fi/okib8baqljqr8t0sk0ipc/ppyg_trf.bed.no_overlaps?rlkey=hvrh87v930wjchpqkbp7oofoo&st=se63g5et&dl=0)_
- _[Symphalangus syndactylus](https://www.dropbox.com/scl/fi/jfw6bmjuhkw5kyzi4olp4/symsyn_trf.bed.no_overlaps?rlkey=vngw7jzmr7ejnuynd37mmeu7k&st=2e3gkrt2&dl=0)_

### User's manual
For detailed instructions on how to use this pipeline, please refer to the [user's manual](https://github.com/caroladam/track/blob/main/manual/user_manual.md)

## Questions?
Send your questions or suggestions to carolinaladam@gmail.com
