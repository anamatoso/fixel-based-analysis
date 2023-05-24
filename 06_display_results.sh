#!/bin/bash
set -e

# Set variables for vizualization
read -p 'Choose metric [fd | log_fc | fdc]: ' metric
read -p 'Choose statistic [fwe_1mpvalue | uncorrected_pvalue | tvalue | Zstat]: ' stat
read -p 'Choose comparison [midinter| midpre | preict | interpre]: ' comp
read -p 'Choose contrast [sup | inf]: ' contrast
read -p 'Choose Suffix: ' arg

if ! [ "${arg}" == "" ]; then 
    suffix="_${arg}"
else
    echo "This will procede without a suffix and the template directory will be overwritten. You have 3s to cancel."
    sleep 3
    suffix=""
fi

mkdir -p template${suffix}/tsf_files
# Map streamlines to the statistic and then visualize with mrview
if [ $contrast == "sup" ]; then
    fixel2tsf "template${suffix}/stats_${metric}_${comp}/${stat}_t1.mif" template${suffix}/tracks_100k_sift.tck "template${suffix}/tsf_files/${metric}_${comp}_${stat}_t1.tsf" -force
    mrview -load template${suffix}/wmfod_template.mif -tractography.load template${suffix}/tracks_100k_sift.tck -tractography.tsf_load "template${suffix}/tsf_files/${metric}_${comp}_${stat}_t1.tsf" -mode 4 -plane 2 -fullscreen 
else
    fixel2tsf "template${suffix}/stats_${metric}_${comp}/${stat}_t2.mif" template${suffix}/tracks_100k_sift.tck "template${suffix}/tsf_files/${metric}_${comp}_${stat}_t2.tsf" -force
    mrview -load template${suffix}/wmfod_template.mif -tractography.load template${suffix}/tracks_100k_sift.tck -tractography.tsf_load "template${suffix}/tsf_files/${metric}_${comp}_${stat}_t2.tsf" -tractography.tsf_thresh 0.95,1 -tractography.tsf_range 0.95,1 -tractography.tsf_colourmap 2 -mode 4 -plane 2 -fullscreen 
fi