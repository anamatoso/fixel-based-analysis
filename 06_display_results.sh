#!/bin/bash
set -e

read -p 'Choose metric [fd|log_fc|fdc]: ' metric

# Map fixel values to streamline points
fixel2tsf "template/stats_${metric}/fwe_1mpvalue.mif" template/tracks_100k_sift.tck "template/${metric}_fwe_1mpvalue.tsf"
#fixel2tsf "template/stats_${metric}/abs_effect_size.mif" tracks_100k_sift.tck "${metric}_abs_effect_size.tsf"
#fixel2tsf "template/stats_${metric}/tvalue.mif" tracks_100k_sift.tck "${metric}tvalue.tsf"
#fixel2tsf "template/stats_${metric}/uncorrected_pvalue.mif" tracks_100k_sift.tck "${metric}uncorrected_pvalue.tsf"
#fixel2tsf "template/stats_${metric}/Zstat.mif" tracks_100k_sift.tck "${metric}Zstat.tsf"

# Visualise track scalar files using the tractogram tool in MRview. First load the streamlines (tracks_100k_sift.tck). Then right click and select ‘colour by (track) scalar file’. For example you might load the abs_effect_size.tsf file. Then to dynamically threshold (remove) streamline points by p-value select the “Thresholds” dropdown and select “Separate Scalar file” to load fwe_pvalue.tsf.

mrview -load template/wmfod_template.mif -tractography.load template/tracks_100k_sift.tck -tractography.tsf_load tsf "template/${metric}_fwe_1mpvalue.tsf" -tractography.tsf_thresh 0.95,1