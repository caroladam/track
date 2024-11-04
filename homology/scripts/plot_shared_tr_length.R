#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)

# Read command-line arguments
args <- commandArgs(trailingOnly = TRUE)

input_bed_file <- args[1]
species1_name <- args[2]
species2_name <- args[3]
output_plot <- args[4]

# Read the input data
df <- read.table(input_bed_file)

# Fit a linear model
lm_fit <- lm(V13 ~ V4, data = df)

# Calculate the R-squared value
r_squared <- round(summary(lm_fit)$r.squared, 3)
r_squared_label <- paste0("R² = ", r_squared)

# Scatterplot of shared TR total length with regression line and R-squared value
p <- ggplot(df, aes(x = V4, y = V13)) + 
    geom_point(size = 2, show.legend = F) + 
    geom_smooth(method = "lm", color = "red", linewidth = 0.5) +
    geom_abline(slope = 1, intercept = 0, color = "black") +
    annotate("text", x = max(df$V4) * 0.8, y = max(df$V13) * 0.2, 
             label = r_squared_label, size = 6, color = "blue") + 
    scale_x_continuous(name = paste0(species1_name, " TR length")) +
    scale_y_continuous(name = paste0(species2_name, " TR length")) +
    theme_bw() +
    theme(
        axis.line = element_line(linewidth = 1, colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        text = element_text(size = 22),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22),
        axis.text.x = element_text(colour = "black", size = 22),
        axis.text.y = element_text(colour = "black", size = 22))

# Save the plot as an SVG file
svg(output_plot)
print(p)
dev.off()
