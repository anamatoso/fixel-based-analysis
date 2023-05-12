#!/bin/bash
set -e

# Set variables for vizualization
read -p 'Choose metric [fd | log_fc | fdc]: ' metric
read -p 'Choose statistic [fwe_1mpvalue | uncorrected_pvalue | tvalue | Zstat]: ' stat
read -p 'Choose comparison [midinter| midpre | preict | interpre]: ' comp
read -p 'Choose contrast [sup | inf]: ' contrast

# Map streamlines to the statistic and then visualize with mrview
if [ $contrast == "sup" ]; then
    fixel2tsf "template/stats_${metric}_${comp}/${stat}_t1.mif" template/tracks_100k_sift.tck "template/tsf_files/${metric}_${comp}_${stat}_t1.tsf" -force
    mrview -load template/wmfod_template.mif -tractography.load template/tracks_100k_sift.tck -tractography.tsf_load "template/${metric}_${comp}_${stat}_t1.tsf" -tractography.tsf_thresh 0.95,1 -tractography.tsf_range 0.95,1 -mode 4 -plane 2 
else
    fixel2tsf "template/stats_${metric}_${comp}/${stat}_t2.mif" template/tracks_100k_sift.tck "template/tsf_files/${metric}_${comp}_${stat}_t2.tsf" -force
    mrview -load template/wmfod_template.mif -tractography.load template/tracks_100k_sift.tck -tractography.tsf_load "template/${metric}_${comp}_${stat}_t2.tsf" -tractography.tsf_thresh 0.95,1 -tractography.tsf_range 0.95,1 -tractography.tsf_colourmap 2 -mode 4 -plane 2 
fi