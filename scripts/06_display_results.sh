#!/bin/bash
set -e

# Set variables for vizualization
read -p 'Choose metric [fd | log_fc | fdc]: ' metric
read -p 'Choose statistic [fwe_1mpvalue | uncorrected_pvalue | tvalue | Zstat]: ' stat
read -p 'Choose comparison [midinter| midpre | premict | interpre]: ' comp
read -p 'Choose contrast [sup | inf]: ' contrast
read -p 'Choose Suffix of template (use underscore if needed): ' suffix
read -p 'Choose Atlas (use underscore if needed): ' atlas

if [ ${stat} == "uncorrected_pvalue" ]; then 
        limit1=0
        limit2=0.05
    else
        limit1=0.95
        limit2=1
    fi

# Create output directory
mkdir -p template${suffix}/tsf_files

# Map streamlines to the statistic and then visualize with mrview
if [ $contrast == "sup" ]; then
    if [ ! -f "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t1.tsf" ]; then # If tsf file was not created yet
        fixel2tsf "template${suffix}/stats_results/${comp}/${metric}${atlas}/${stat}_t1.mif" \
        template${suffix}/tracks_100k_sift.tck \
        "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t1.tsf" -force
    fi
    mrview -load template${suffix}/wmfod_template.mif \
    -tractography.load template${suffix}/tracks_100k_sift.tck \
    -tractography.tsf_load "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t1.tsf" \
    -tractography.tsf_thresh ${limit1},${limit2} \
    -tractography.tsf_range ${limit1},${limit2} \
    -mode 4 -plane 2 -fullscreen 
else
    if [ ! -f "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t2.tsf" ]; then # If tsf file was not created yet
        fixel2tsf "template${suffix}/stats_results/${comp}/${metric}${atlas}/${stat}_t2.mif" \
        template${suffix}/tracks_100k_sift.tck \
        "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t2.tsf" -force
    fi
    mrview -load template${suffix}/wmfod_template.mif \
    -tractography.load template${suffix}/tracks_100k_sift.tck \
    -tractography.tsf_load "template${suffix}/tsf_files/${comp}_${metric}_${stat}${atlas}_t2.tsf" \
    -tractography.tsf_thresh ${limit1},${limit2} \
    -tractography.tsf_range ${limit1},${limit2} \
    -tractography.tsf_colourmap 2 -mode 4 -plane 2 -fullscreen 
fi