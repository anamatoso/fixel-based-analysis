#!/bin/bash
set -e

# Get suffix of the template directory
read -p 'Choose Suffix: ' arg
if ! [ "${arg}" == "" ]; then 
    suffix="_${arg}"
else
    echo "This will procede without a suffix and the template directory will be overwritten. You have 10s to cancel."
    sleep 10
    suffix=""
fi

read -p 'Name of atlas: ' atlas

# Perform whole-brain fibre tractography on the FOD template
cd template${suffix}
tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 wmfod_template.mif -seed_image template_mask.mif -mask template_mask.mif -select 10000000 -cutoff 0.06 tracks_10_million.tck -force

# Reduce biases in tractogram densities
tcksift tracks_10_million.tck wmfod_template.mif tracks_1_million_sift.tck -term_number 1000000 -force
rm tracks_10_million.tck

# Creating the connectome 
tck2connectome -symmetric -zero_diagonal -scale_invnodevol tracks_1_million_sift.tck ${atlas}_template.mif "con_matrix${suffix}_${atlas}.csv" -force

# Generate fixel-fixel connectivity matrix
rm -rf matrix
fixelconnectivity fixel_mask/ tracks_1_million_sift.tck matrix/ -force

# Smooth fixel data using fixel-fixel connectivity
rm -r fd_smooth log_fc_smooth fdc_smooth
fixelfilter fd smooth fd_smooth -matrix matrix/ -force
fixelfilter log_fc smooth log_fc_smooth -matrix matrix/ -force
fixelfilter fdc smooth fdc_smooth -matrix matrix/ -force
rm fd log_fc fdc

# Reduce the whole-brain template tractogram to a sensible number of streamlines so mrview can handle it when displaying the results
tckedit tracks_1_million_sift.tck -num 100000 tracks_100k_sift.tck -force
rm tracks_1_million_sift.tck

cd ..
