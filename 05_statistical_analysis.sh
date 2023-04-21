#!/bin/bash
set -e

# TO DO: create files.txt, design_matrix.txt and contrast_matrix.txt
metrics="fd log_fc fdc"

for i in $metrics; do
    fixelcfestats template/${i}_smooth/ files_${i}.txt design_matrix.txt contrast_matrix.txt template/matrix/ template/stats_${i}/ -force
done


# Perform statistical analysis of FD, FC, and FDC