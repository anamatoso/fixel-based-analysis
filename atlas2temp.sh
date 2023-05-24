#!/bin/bash
set -e


# Get directories' variables
read -p 'Write path to data of thesis: ' MAINDIR
ATLAS_IN=$1
ATLAS=${ATLAS_IN%%.*}
IN="$(pwd)/subjects/sub-control019_ses-midcycle"
read -p 'Choose Suffix: ' suffix

SUB="sub-control019"
ANATDIR="${MAINDIR}/${SUB}" #example name: sub-control019
ANAT="${ANATDIR}/${SUB}_restored-MPRAGE_brain.nii.gz"

# Note: the atlas file needs to be in mif format (use mrconvert with -fslgrad option to convert it from nii.gz to mif)

# Regrid atlas to 2mm resolution and convert it to nii.gz format
mrgrid ${ATLAS}.mif regrid - -vox 2 | mrconvert - ${ATLAS}.nii.gz -force

# Coregister atlas to struct space and convert to mrtrix format
applywarp -i ${ATLAS}.nii.gz -r $ANAT --out="${ATLAS}_2struct" --warp="${ANATDIR}/reg_nonlinear_invwarp_T1tostandard_2mm.nii.gz"
mrconvert "${ATLAS}_2struct.nii.gz" "${ATLAS}_2struct.mif" -force
rm "${ATLAS}_2struct.nii.gz"

# Coregister atlas from struct to diff space
mrtransform "${ATLAS}_2struct.mif" -linear ${MAINDIR}/sub-control019_ses-midcycle/mrtrix_outputs_bvals2/diff2struct_mrtrix.txt -inverse "${ATLAS}_2diff.mif" -force
rm "${ATLAS}_2struct.mif"

# Coregister atlas from diff to template space
mrregister ${IN}/wmfod_norm.mif -mask1 ${IN}/mask_upsampled.mif template${suffix}/wmfod_template.mif -nl_warp ${IN}/subject2template_warp.mif ${IN}/template2subject_warp.mif -force
mrtransform "${ATLAS}_2diff.mif" -warp ${IN}/subject2template_warp.mif -interp nearest "${ATLAS}_template.mif" -force
rm "${ATLAS}_2diff.mif"

mv "${ATLAS}_template.mif" template${suffix}

voxel2fixel "template${suffix}/${ATLAS}_template.mif" template${suffix}/fixel_mask template${suffix}/fixel_${ATLAS} ${ATLAS}_fixel