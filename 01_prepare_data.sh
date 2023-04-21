#!/bin/bash
set -e

# Computing (average) tissue response functions
for_each subjects/* : dwi2response dhollander IN/dwi.mif IN/response_wm.txt IN/response_gm.txt IN/response_csf.txt

# Get mean for each of the typees of tissues
responsemean subjects/*/response_wm.txt group_average_response_wm.txt
responsemean subjects/*/response_gm.txt group_average_response_gm.txt
responsemean subjects/*/response_csf.txt group_average_response_csf.txt

# Upsampling DW images 
for_each subjects/* : mrgrid IN/dwi.mif regrid -vox 1.25 IN/dwi_upsampled.mif
for_each subjects/* : rm IN/dwi.mif

# Compute upsampled brain mask images
# If I didn’t have the mask: for_each * : dwi2mask IN/dwi_denoised_unringed_preproc_unbiased_upsampled.mif IN/dwi_mask_upsampled.mif
for_each subjects/* : mrgrid IN/mask.mif regrid -vox 1.25 IN/mask_upsampled.mif
for_each subjects/* : rm IN/mask.mif
# check at this stage that all individual subject masks include all regions of the brain that are intended to be analysed