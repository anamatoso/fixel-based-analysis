#!/bin/bash
set -e

# Get suffix of the template directory
read -p 'Choose Suffix [ "" | ictals | controls ]: ' arg
if ! [ "${arg}" == "" ]; then 
    suffix="_${arg}"
else
    echo "This will procede without a suffix and the template directory will be overwritten. You have 5s to cancel."
    sleep 5
    suffix=""
fi

# Perform statistical analysis of FD, FC, and FDC on various comparisons with many atlas as masks
metrics="fdc fd log_fc"
comparisons="midinter midprem premict interict"
atlases="JHUlabels JHUtracts AAL116"

# Output directory and text files directory
mkdir -p template${suffix}/stats_results
mkdir -p template${suffix}/text_files

for i in $metrics; do
    for c in $comparisons; do
        echo " "
        echo "Starting comparison ${c} of metric ${i}"
        python ./create_files_stats.py $c $i $suffix

        if [ ${c} == "midinter" ] || [ ${c} == "premict" ] || [ ${c} == "prempost" ] || [ ${c} == "prempre" ]; then 
            contrast="contrast_matrix_unpaired"
        else
            contrast="contrast_matrix_paired"
        fi
        mkdir -p template${suffix}/stats_results/${c}
        fixelcfestats template${suffix}/${i}_smooth/ \
                        template${suffix}/text_files/files_${i}_${c}.txt \
                        template${suffix}/text_files/design_matrix_${c}.txt \
                        template${suffix}/text_files/${contrast}.txt \
                        template${suffix}/matrix/ \
                        template${suffix}/stats_results/${c}/${i}/ -force
        for atlas in $atlases; do
            fixelcfestats template${suffix}/${i}_smooth/ \
                            template${suffix}/text_files/files_${i}_${c}.txt \
                            template${suffix}/text_files/design_matrix_${c}.txt \
                            template${suffix}/text_files/${contrast}.txt \
                            template${suffix}/matrix/ \
                            template${suffix}/stats_results/${c}/${i}_${atlas}/ \
                            -mask template${suffix}/fixel_${atlas}/${atlas}_fixel.mif -force
        done
    done
done
