#!/bin/bash
set -e

#  Compute a white matter template analysis fixel mask
rm -rf template/fixel_mask
fod2fixel -mask template/template_mask.mif -fmls_peak_value 0.06 template/wmfod_template.mif template/fixel_mask -force

# Warp FOD images to template space
rm -rf template/fod_in_template_space_NOT_REORIENTED
for_each subjects/* : mrtransform IN/wmfod_norm.mif -warp IN/subject2template_warp.mif -reorient_fod no IN/fod_in_template_space_NOT_REORIENTED.mif -force

# Segment FOD images to estimate fixels and their apparent fibre density (FD)
for_each subjects/* : fod2fixel -mask template/template_mask.mif IN/fod_in_template_space_NOT_REORIENTED.mif IN/fixel_in_template_space_NOT_REORIENTED -afd fd.mif -force
for_each subjects/* : rm -f IN/fod_in_template_space_NOT_REORIENTED.mif

# Reorient fixels
for_each subjects/* : rm -rf IN/fixel_in_template_space
for_each subjects/* : fixelreorient IN/fixel_in_template_space_NOT_REORIENTED IN/subject2template_warp.mif IN/fixel_in_template_space -force

# Remove fixel_in_template_space_NOT_REORIENTED folders 
for_each subjects/* : rm -rf IN/fixel_in_template_space_NOT_REORIENTED

# Assign subject fixels to template fixels
rm -rf template/fd
for_each subjects/* : fixelcorrespondence IN/fixel_in_template_space/fd.mif template/fixel_mask template/fd PRE.mif -force

# Compute the fibre cross-section (FC) metric and log(FC)
rm -rf template/fc
for_each subjects/* : warp2metric IN/subject2template_warp.mif -fc template/fixel_mask template/fc PRE.mif -force

rm -rf template/log_fc
mkdir -p template/log_fc
cp template/fc/index.mif template/fc/directions.mif template/log_fc
for_each subjects/* : mrcalc template/fc/PRE.mif -log template/log_fc/PRE.mif -force

# Compute a combined measure of fibre density and cross-section (FDC)
rm -rf template/fdc
mkdir -p template/fdc
cp template/fc/index.mif template/fdc
cp template/fc/directions.mif template/fdc
for_each subjects/* : mrcalc template/fd/PRE.mif template/fc/PRE.mif -mult template/fdc/PRE.mif -force
