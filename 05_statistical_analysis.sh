#!/bin/bash
set -e

# Prepare files

arg=$1

if ! [ "${arg}" == "" ]; then 
    suffix="_${arg}"
else
    echo "This will procede without a suffix and the template directory will be overwritten. You have 10s to cancel."
    sleep 10
    suffix=""
fi

# Perform statistical analysis of FD, FC, and FDC
metrics="fd log_fc fdc"
comparisons="midinter midpre preict interict"

for c in $comparisons; do
    for i in $metrics; do
    python ./create_files_stats.py "$c" "$i"
    fixelcfestats template"${suffix}"/"${i}"_smooth/ text_files/files_"${i}"_"${c}".txt text_files/design_matrix_"${c}".txt text_files/contrast_matrix.txt template"${suffix}"/matrix/ template"${suffix}"/stats_"${i}"_"${c}"/ -force
    done
done
