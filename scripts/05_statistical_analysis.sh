#!/bin/bash
set -e

# Get suffix of the template directory
read -p 'Choose Suffix: ' arg
if ! [ "${arg}" == "" ]; then 
    suffix="_${arg}"
else
    echo "This will procede without a suffix and the template directory will be overwritten. You have 5s to cancel."
    sleep 5
    suffix=""
fi

# Perform statistical analysis of FD, FC, and FDC
metrics="fdc log_fc fd"
comparisons="midinter midpre preict interict"
mkdir -p text_files
for c in $comparisons; do
    for i in $metrics; do
    echo " "
    echo "Starting comparison ${c} of metric ${i}"
    python ./create_files_stats.py $c $i $suffix
    python ./check_rank.py "./text_files/design_matrix_${c}.txt"
    
    if [ ${c} == "midpre" ] || [ ${c} == "interict" ]; then 
        contrast="contrast_matrix_paired"
    else
        contrast="contrast_matrix_unpaired"
    fi

    fixelcfestats template${suffix}/${i}_smooth/ text_files/files_${i}_${c}.txt text_files/design_matrix_${c}.txt text_files/${contrast}.txt template${suffix}/matrix/ template${suffix}/stats_${i}_${c}/ -force
    fixelcfestats template${suffix}/${i}_smooth/ text_files/files_${i}_${c}.txt text_files/design_matrix_${c}.txt text_files/${contrast}.txt template${suffix}/matrix/ template${suffix}/stats_${i}_${c}_JHUlabels/ -mask template/fixel_JHUlabels/JHUlabels_fixel.mif -force
    fixelcfestats template${suffix}/${i}_smooth/ text_files/files_${i}_${c}.txt text_files/design_matrix_${c}.txt text_files/${contrast}.txt template${suffix}/matrix/ template${suffix}/stats_${i}_${c}_JHUtracts/ -mask template/fixel_JHUtracts/JHUtracts_fixel.mif -force
    done
done
