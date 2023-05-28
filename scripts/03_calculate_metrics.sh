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

# Compute a white matter template analysis fixel mask
fod2fixel -mask template${suffix}/template_mask.mif -fmls_peak_value 0.06 template${suffix}/wmfod_template.mif template${suffix}/fixel_mask -force

# Warp FOD images to template space
rm -rf template${suffix}/fod_in_template_space_NOT_REORIENTED
for_each subjects/* : mrtransform IN/wmfod_norm.mif -warp IN/subject2template_warp${suffix}.mif -reorient_fod no IN/fod_in_template_space_NOT_REORIENTED${suffix}.mif -force

# Segment FOD images to estimate fixels and their apparent fibre density (FD)
for_each subjects/* : fod2fixel -mask template${suffix}/template_mask.mif IN/fod_in_template_space_NOT_REORIENTED${suffix}.mif IN/fixel_in_template_space_NOT_REORIENTED${suffix} -afd fd.mif -force
for_each subjects/* : rm -f IN/fod_in_template_space_NOT_REORIENTED${suffix}.mif

# Reorient fixels
for_each subjects/* : rm -rf IN/fixel_in_template_space${suffix}
for_each subjects/* : fixelreorient IN/fixel_in_template_space_NOT_REORIENTED${suffix} IN/subject2template_warp${suffix}.mif IN/fixel_in_template_space${suffix} -force

# Remove fixel_in_template_space_NOT_REORIENTED folders 
for_each subjects/* : rm -rf IN/fixel_in_template_space_NOT_REORIENTED${suffix}

# Assign subject fixels to template fixels
rm -rf template${suffix}/fd
for_each subjects/* : fixelcorrespondence IN/fixel_in_template_space${suffix}/fd.mif template${suffix}/fixel_mask template${suffix}/fd PRE.mif -force

# Compute the fibre cross-section (FC) metric and log(FC)
rm -rf template${suffix}/fc
for_each subjects/* : warp2metric IN/subject2template_warp${suffix}.mif -fc template${suffix}/fixel_mask template${suffix}/fc PRE.mif -force

rm -rf template${suffix}/log_fc
mkdir -p template${suffix}/log_fc
cp template${suffix}/fc/index.mif template${suffix}/fc/directions.mif template${suffix}/log_fc
for_each subjects/* : mrcalc template${suffix}/fc/PRE.mif -log template${suffix}/log_fc/PRE.mif -force

# Compute a combined measure of fibre density and cross-section (FDC)
rm -rf template${suffix}/fdc
mkdir -p template${suffix}/fdc
cp template${suffix}/fc/index.mif template${suffix}/fdc
cp template${suffix}/fc/directions.mif template${suffix}/fdc
for_each subjects/* : mrcalc template${suffix}/fd/PRE.mif template${suffix}/fc/PRE.mif -mult template${suffix}/fdc/PRE.mif -force
rm template${suffix}/fc
