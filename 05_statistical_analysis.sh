#!/bin/bash
set -e

# Prepare files
rm -f design_matrix.txt files_log_fc.txt files_fd.txt files_fdc.txt
for_each subjects/* : ./create_files_statistical_analysis.sh PRE

# Perform statistical analysis of FD, FC, and FDC
metrics="fd log_fc fdc"
for i in $metrics; do
    fixelcfestats template/${i}_smooth/ files_${i}.txt design_matrix.txt contrast_matrix.txt template/matrix/ template/stats_${i}/ -force
done
