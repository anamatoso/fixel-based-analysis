#!/bin/bash
set -e

# Reduce the whole-brain template tractogram to a sensible number of streamlines so mrview can handle it
tckedit template/tracks_2_million_sift.tck -num 200000 template/tracks_200k_sift.tck

read -p 'Choose metric [fd|log_fc|fdc]: ' metric

# Map fixel values to streamline points
fixel2tsf "template/stats_${metric}/fwe_1mpvalue.mif" tracks_200k_sift.tck "${metric}fwe_1mpvalue.tsf"
#fixel2tsf "template/stats_${metric}/abs_effect_size.mif" tracks_200k_sift.tck "${metric}_abs_effect_size.tsf"
#fixel2tsf "template/stats_${metric}/tvalue.mif" tracks_200k_sift.tck "${metric}tvalue.tsf"
#fixel2tsf "template/stats_${metric}/uncorrected_pvalue.mif" tracks_200k_sift.tck "${metric}uncorrected_pvalue.tsf"
#fixel2tsf "template/stats_${metric}/Zstat.mif" tracks_200k_sift.tck "${metric}Zstat.tsf"
