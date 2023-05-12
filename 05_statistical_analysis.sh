#!/bin/bash
set -e

# Prepare files
for_each subjects/* : ./create_files_statistical_analysis.sh PRE
rm -f text_files/design_matrix*.txt files_*.txt contrast_matrix.txt
printf "0 1 -1\n" >> text_files/contrast_matrix.txt
printf "0 -1 1" >> text_files/contrast_matrix.txt

# Perform statistical analysis of FD, FC, and FDC
metrics="fd log_fc fdc"
comparisons="midinter midpre preict interict"

for i in $metrics; do
    for c in $comparisons; do
        fixelcfestats template/${i}_smooth/ text_files/files_${i}_${c}.txt text_files/design_matrix_${c}.txt text_files/contrast_matrix.txt template/matrix/ template/stats_${i}_${c}/ -force
    done
done
