#!/bin/bash
set -e

# Perform whole-brain fibre tractography on the FOD template
cd template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image template_mask.mif -mask template_mask.mif -select 10000000 -cutoff 0.06 tracks_10_million.tck -force

# Reduce biases in tractogram densities
tcksift tracks_10_million.tck wmfod_template.mif tracks_1_million_sift.tck -term_number 1000000 -force

# Generate fixel-fixel connectivity matrix
rm -rf matrix
fixelconnectivity fixel_mask/ tracks_1_million_sift.tck matrix/ -force

# Smooth fixel data using fixel-fixel connectivity
rm -r fd_smooth log_fc_smooth fdc_smooth
fixelfilter fd smooth fd_smooth -matrix matrix/ -force
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/ -force
fixelfilter fdc smooth fdc_smooth -matrix matrix/ -force

# Reduce the whole-brain template tractogram to a sensible number of streamlines so mrview can handle it when displaying the results
tckedit tracks_1_million_sift.tck -num 100000 tracks_100k_sift.tck -force

cd ..
