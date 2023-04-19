#!/bin/bash
set -e

#  Compute a white matter template analysis fixel mask
fod2fixel -mask template/template_mask.mif -fmls_peak_value 0.06 template/wmfod_template.mif template/fixel_mask

# TO DO alterar diretorias daqui para baixo

# Warp FOD images to template space
for_each subjects/* : mrtransform IN/wmfod_norm.mif -warp IN/subject2template_warp.mif -reorient_fod no IN/fod_in_template_space_NOT_REORIENTED.mif

# Segment FOD images to estimate fixels and their apparent fibre density (FD)
for_each subjects/* : fod2fixel -mask template/template_mask.mif IN/fod_in_template_space_NOT_REORIENTED.mif IN/fixel_in_template_space_NOT_REORIENTED -afd fd.mif

# Reorient fixels
for_each subjects/* : fixelreorient IN/fixel_in_template_space_NOT_REORIENTED IN/subject2template_warp.mif IN/fixel_in_template_space

# Remove fixel_in_template_space_NOT_REORIENTED folders 
# for_each subjects/* : rm -r IN/fixel_in_template_space_NOT_REORIENTED

# Assign subject fixels to template fixels
for_each subjects/* : fixelcorrespondence IN/fixel_in_template_space/fd.mif template/fixel_mask template/fd PRE.mif

# Compute the fibre cross-section (FC) metric and log(FC)
for_each subjects/* : warp2metric IN/subject2template_warp.mif -fc template/fixel_mask template/fc IN.mif

mkdir template/log_fc
cp template/fc/index.mif template/fc/directions.mif template/log_fc
for_each subjects/* : mrcalc template/fc/IN.mif -log template/log_fc/IN.mif

# Compute a combined measure of fibre density and cross-section (FDC)
mkdir template/fdc
cp template/fc/index.mif template/fdc
cp template/fc/directions.mif template/fdc
for_each subjects/* : mrcalc template/fd/IN.mif template/fc/IN.mif -mult template/fdc/IN.mif




