#!/usr/bin/env Rscript

install_if_missing <- function(pkg) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg, repos = "https://cloud.r-project.org/")
        library(pkg, character.only = TRUE)
    }
}

# Check and install required packages
packages <- c("vcfR", "hierfstat", "ggplot2", "tidyr", "dplyr", "viridis")
lapply(packages, install_if_missing)

# Load libraries
library(vcfR)
library(hierfstat)
library(ggplot2)
library(tidyr)
library(dplyr)
library(viridis)

# Read input arguments
args <- commandArgs(trailingOnly = TRUE)
vcf_file <- args[1]
popinfo_file <- args[2]

# Extract the prefix from the VCF filename
vcf_prefix <- tools::file_path_sans_ext(basename(vcf_file))

# Read VCF
vcf <- read.vcfR(vcf_file)
# Read popinfo
popinfo <- read.csv(popinfo_file, header = TRUE, sep = "\t")

cat("Converting VCF to genid object and assigning population info.\n")
df <- vcfR2genind(vcf, ind.names = popinfo$sample, pop = popinfo$pop)

cat("Calculating basic statistics.\n")
basic_stats <- basic.stats(df)

# Extract observed heterozygosity (Ho) and genetic diversity (Hs) per population
ho_pop <- basic_stats$Ho
hs_pop <- basic_stats$Hs

# Write output to CSV
write.csv(ho_pop, paste0(vcf_prefix, "_observed_heterozygosity.csv"),)
write.csv(hs_pop, paste0(vcf_prefix, "_genetic_diversity.csv"))
cat("Writing observed heterozygosity (Ho) and genetic diversity (Hs) to file.\n")

ho_pop_df <- as.data.frame(ho_pop)
ho_pop_df$locus <- rownames(ho_pop_df)

# Transform data into long format (Ho)
ho_pop_long <- pivot_longer(ho_pop_df, cols = -locus, names_to = "Population", values_to = "Heterozygosity")

s_size_ho <- ho_pop_long %>% group_by(Population) %>% summarize(num=n())

# Create violin plot for Ho
p_ho_pop <- ho_pop_long %>%
  left_join(s_size_ho) %>%
  mutate(myaxis=paste0(Population)) %>%
  ggplot(aes(x = factor(myaxis), y = Heterozygosity, fill = Population)) +
  geom_violin(width=1, show.legend=F) + 
  stat_summary(fun=mean, geom="point", shape=23, size=2, show.legend=F) +
  scale_fill_viridis_d() +
theme_bw() +
theme(axis.line = element_line(linewidth=1, colour = "black"),
panel.grid.major = element_blank(),
panel.grid.minor = element_blank(),
panel.border = element_blank(), panel.background = element_blank(),
text = element_text(size=22),
axis.title.x=element_text(size= 22),
axis.title.y=element_text(size = 22),
axis.text.x=element_text(colour="black", size = 22),
axis.text.y=element_text(colour="black", size = 22)) +
labs(x = "Populations", y = "Observed Heterozygosity (Ho)")

svg_filename_ho <- paste0(vcf_prefix, "_observed_heterozygosity.svg")
svg(svg_filename_ho)
print(p_ho_pop)
dev.off()
cat("Violin plot of observed heterozygosity (Ho) saved as SVG.\n")

# Convert the rownames to a column for ease of manipulation (Hs)
hs_pop_df <- as.data.frame(hs_pop)
hs_pop_df$locus <- rownames(hs_pop_df)

# Gather the data into long format (Hs)
hs_pop_long <- pivot_longer(hs_pop_df, cols = -locus, names_to = "Population", values_to = "GeneticDiversity")

s_size_hs <- hs_pop_long %>% group_by(Population) %>% summarize(num=n())

# Create violin plot for Hs
p_hs_pop <- hs_pop_long %>%
  left_join(s_size_hs) %>%
  mutate(myaxis=paste0(Population)) %>%
  ggplot(aes(x = factor(myaxis), y = GeneticDiversity, fill = Population)) + 
  geom_violin(width=0.9, show.legend=F) + 
  geom_boxplot(outlier.size=0.3, width=0.1, alpha=0.6, show.legend=F) + 
  stat_summary(fun=mean, geom="point", shape=23, size=3, show.legend=F) +
  scale_fill_viridis_d() + 
theme_bw() +
theme(axis.line = element_line(linewidth=1, colour = "black"),
panel.grid.major = element_blank(),
panel.grid.minor = element_blank(),
panel.border = element_blank(), panel.background = element_blank(),
text = element_text(size=22),
axis.title.x=element_text(size= 22),
axis.title.y=element_text(size = 22),
axis.text.x=element_text(colour="black", size = 22),
axis.text.y=element_text(colour="black", size = 11)) +
labs(x = "Population", y = "Genetic Diversity (Hs)")

svg_filename_hs <- paste0(vcf_prefix, "_genetic_diversity.svg")
svg(svg_filename_hs)
print(p_hs_pop)
dev.off()
cat("Violin plot of genetic diversity (Hs) saved as SVG.\n")
