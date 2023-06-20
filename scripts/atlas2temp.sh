#!/bin/bash
set -e

# Get atlas file (in nii.gz format with same voxel size as the rest of the images)
ATLAS_IN=$1
ATLAS=${ATLAS_IN%%.*}

# Get directories' variables
read -p 'Write path to data of thesis: ' MAINDIR

# Choose template
read -p 'Choose Suffix [ "" | _ictals | _controls ]: ' suffix

# Define subject directories
IN="$(pwd)/subjects/sub-control019_ses-midcycle"
SUB="sub-control019"
ANATDIR="${MAINDIR}/${SUB}" #example name: sub-control019
ANAT="${ANATDIR}/${SUB}_restored-MPRAGE_brain.nii.gz"

# Coregister atlas to structural space and convert to mrtrix format. Remove unneeded files to save memory
applywarp -i ${ATLAS}.nii.gz -r $ANAT --out="${ATLAS}_2struct" --warp="${ANATDIR}/reg_nonlinear_invwarp_T1tostandard_2mm.nii.gz"
mrconvert "${ATLAS}_2struct.nii.gz" "${ATLAS}_2struct.mif" -force
rm "${ATLAS}_2struct.nii.gz"

# Coregister atlas from structural to diffusion space. Remove unneeded files to save memory
mrtransform "${ATLAS}_2struct.mif" -linear ${MAINDIR}/sub-control019_ses-midcycle/mrtrix_outputs_bvals2/diff2struct_mrtrix.txt -inverse "${ATLAS}_2diff.mif" -interp nearest -force
rm "${ATLAS}_2struct.mif"

# Coregister atlas from diffusion to template space. Remove unneeded files to save memory
if [ ! -f "${IN}/subject2template${suffix}_warp.mif" ]; then # Check if the transformation was already calculated and calculate it if it is not
    mrregister ${IN}/wmfod_norm.mif -mask1 ${IN}/mask_upsampled.mif template${suffix}/wmfod_template.mif -nl_warp ${IN}/subject2template${suffix}_warp.mif ${IN}/template${suffix}2subject_warp.mif -force
fi
mrtransform "${ATLAS}_2diff.mif" -warp ${IN}/subject2template${suffix}_warp.mif -interp nearest - -force | mrcalc - -round "${ATLAS}_template.mif" -force
rm "${ATLAS}_2diff.mif"

# Move file to template folder
rm -f template${suffix}/${ATLAS}_template.mif
mv "${ATLAS}_template.mif" template${suffix}

# Map the scalar value in each voxel to all fixels within that voxel
voxel2fixel "template${suffix}/${ATLAS}_template.mif" template${suffix}/fixel_mask template${suffix}/fixel_${ATLAS} ${ATLAS}_fixel.mif -force
