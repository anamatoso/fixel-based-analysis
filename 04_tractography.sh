#!/bin/bash
set -e

# Perform whole-brain fibre tractography on the FOD template
cd template
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image template_mask.mif -mask template_mask.mif -select 10000000 -cutoff 0.06 tracks_10_million.tck

# Reduce biases in tractogram densities
tcksift tracks_10_million.tck wmfod_template.mif tracks_1_million_sift.tck -term_number 1000000

# Generate fixel-fixel connectivity matrix
fixelconnectivity fixel_mask/ tracks_1_million_sift.tck matrix/

# Smooth fixel data using fixel-fixel connectivity
fixelfilter fd smooth fd_smooth -matrix matrix/
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/
fixelfilter fdc smooth fdc_smooth -matrix matrix/

cd ..
