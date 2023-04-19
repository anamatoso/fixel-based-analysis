#!/bin/bash

set -e

# Fibre Orientation Distribution estimation (multi-tissue spherical deconvolution)
for_each subjects/* : dwi2fod msmt_csd IN/dwi_upsampled.mif group_average_response_wm.txt IN/wmfod.mif group_average_response_gm.txt IN/gm.mif group_average_response_csf.txt IN/csf.mif -mask IN/mask_upsampled.mif

# Joint bias field correction and intensity normalisation
for_each subjects/* : mtnormalise IN/wmfod.mif IN/wmfod_norm.mif IN/gm.mif IN/gm_norm.mif IN/csf.mif IN/csf_norm.mif -mask IN/mask_upsampled.mif

# Generate a study-specific unbiased FOD template
mkdir -p template/fod_input
mkdir template/mask_input

for_each subjects/* : ln -sr IN/wmfod_norm.mif template/fod_input/PRE.mif
for_each subjects/* : ln -sr IN/mask_upsampled.mif template/mask_input/PRE.mif

# If we wanted to select only a sample of the data
#for_each `ls -d *patient | sort -R | tail -20` : ln -sr IN/wmfod_norm.mif ../template/fod_input/PRE.mif ";" ln -sr IN/dwi_mask_upsampled.mif ../template/mask_input/PRE.mif
#for_each `ls -d *control | sort -R | tail -20` : ln -sr IN/wmfod_norm.mif ../template/fod_input/PRE.mif ";" ln -sr IN/dwi_mask_upsampled.mif ../template/mask_input/PRE.mif

population_template template/fod_input -mask_dir template/mask_input template/wmfod_template.mif -voxel_size 1.25

# Register all subject FOD images to the FOD template
for_each subjects/* : mrregister IN/wmfod_norm.mif -mask1 IN/dwi_mask_upsampled.mif template/wmfod_template.mif -nl_warp IN/subject2template_warp.mif IN/template2subject_warp.mif

# Compute the template mask (intersection of all subject masks in template space)
for_each subjects/* : mrtransform IN/dwi_mask_upsampled.mif -warp IN/subject2template_warp.mif -interp nearest -datatype bit IN/dwi_mask_in_template_space.mif
mrmath subjects/*/dwi_mask_in_template_space.mif min template/template_mask.mif -datatype bit

# check at this stage that the resulting template mask includes all regions of the brain that are intended to be analysed
