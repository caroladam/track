#!/bin/bash

usage() {
    echo "Usage: $0 <r_script> <input_bed_file> <species1_name> <species2_name> <output_plot>"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 5 ];
then
    usage
fi

# Assign arguments to variables
r_script="$1"
input_bed_file="$2"
species1_name="$3"
species2_name="$4"
output_plot="$5"

echo "Running plot_shared_tr_length.R"
echo -e "\n"
Rscript "$r_script" "$input_bed_file" "$species1_name" "$species2_name" "$output_plot"
echo -e "\n"
echo "plot_shared_tr_length.R is completed"
echo -e "\n"
echo "Scatterplot with shared TR length is saved in" $output_plot
