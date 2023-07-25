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

for metric in $metrics; do
    for c in $comparisons; do
        echo " "
        echo "Starting comparison ${c} of metric ${metric}"
        python ./create_files_stats.py $c $metric $suffix

        if [ ${c} == "midinter" ] || [ ${c} == "premict" ] || [ ${c} == "prempost" ] || [ ${c} == "prempre" ]; then 
            contrast="contrast_matrix_unpaired"
        else
            contrast="contrast_matrix_paired"
        fi
        mkdir -p template${suffix}/stats_results/${c}

        # Perform the statistical analysis
        fixelcfestats template${suffix}/${metric}_smooth/ \
                        template${suffix}/text_files/files_${metric}_${c}.txt \
                        template${suffix}/text_files/design_matrix_${c}.txt \
                        template${suffix}/text_files/${contrast}.txt \
                        template${suffix}/matrix/ \
                        template${suffix}/stats_results/${c}/${metric}/ -force

        # Map the fixels values to the tractogram
        fixel2tsf "template${suffix}/stats_results/${c}/${metric}/${stat}_t1.mif" \
				template${suffix}/tracks_100k_sift.tck \
				"template${suffix}/tsf_files/${c}_${metric}_${stat}_t1.tsf" -force
        fixel2tsf "template${suffix}/stats_results/${c}/${metric}/${stat}_t2.mif" \
				template${suffix}/tracks_100k_sift.tck \
				"template${suffix}/tsf_files/${c}_${metric}_${stat}_t2.tsf" -force

        for atlas in $atlases; do
            # Perform the statistical analysis
            fixelcfestats template${suffix}/${metric}_smooth/ \
                            template${suffix}/text_files/files_${metric}_${c}.txt \
                            template${suffix}/text_files/design_matrix_${c}.txt \
                            template${suffix}/text_files/${contrast}.txt \
                            template${suffix}/matrix/ \
                            template${suffix}/stats_results/${c}/${metric}_${atlas}/ \
                            -mask template${suffix}/fixel_${atlas}/${atlas}_fixel.mif -force
            
            # Map the fixels values to the tractogram
            fixel2tsf "template${suffix}/stats_results/${c}/${metric}${atlas}/${stat}_t1.mif" \
				template${suffix}/tracks_100k_sift.tck \
				"template${suffix}/tsf_files/${c}_${metric}_${stat}${atlas}_t1.tsf" -force
			fixel2tsf "template${suffix}/stats_results/${c}/${metric}${atlas}/${stat}_t2.mif" \
				template${suffix}/tracks_100k_sift.tck \
				"template${suffix}/tsf_files/${c}_${metric}_${stat}${atlas}_t2.tsf" -force
        done
    done
    /strombolihome/amatoso/end_message.sh "acabou metrica ${metric}"
done
