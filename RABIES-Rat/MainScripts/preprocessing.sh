#!/usr/bin/env bash
set -euo pipefail # terminates script if any error 

# Docker image 
DOCKER_IMG="gabdesgreg/rabies:0.5.0"

# Directories 
INPUT_DIR="${PWD}/input_bids"
OUTPUT_DIR="${PWD}/preprocess_outputs"
TEMPLATE_DIR="${PWD}/rat_templates"


docker run -it --rm \
  --shm-size=2g \
  --user $(id -u):$(id -g) \
  -e HOME=/home/rabies/tmp \
  -e NIPYPE_OUTPUT_DIR=/home/rabies/tmp \
  -e NIPYPE_CRASHFILE_DIR=/home/rabies/tmp \
  -e MPLCONFIGDIR=/home/rabies/tmp \
  -v "${INPUT_DIR}:/input_BIDS:ro" \
  -v "${OUTPUT_DIR}:/preprocess_outputs" \
  -v "${OUTPUT_DIR}/tmp:/home/rabies/tmp" \
  -v "${TEMPLATE_DIR}:/rat_templates:ro" \
  "${DOCKER_IMG}" -p MultiProc \
    --scale_min_memory 3 \
    --local_threads 4 \
    --min_proc 1 \
  preprocess /input_BIDS/ /preprocess_outputs/ \
    --anat_template  /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_template.nii.gz \
    --brain_mask     /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_mask.nii.gz \
    --WM_mask        /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_wm_bin.nii.gz \
    --CSF_mask       /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_csf_bin.nii.gz \
    --vascular_mask  /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_csf_bin.nii.gz \
    --labels         /rat_templates/SIGMA_Rat_Brain_Atlases/SIGMA_Anatomical_Atlas/InVivo_Atlas/SIGMA_InVivo_Anatomical_Brain_Atlas.nii.gz \
    --anat_autobox \
    --TR 1.5s \
    --bold_autobox \
    --apply_despiking \
    --detect_dummy \
    --anat_inho_cor method=Affine,otsu_thresh=2,multiotsu=true \
    --anat_robust_inho_cor apply=true,masking=true,brain_extraction=true,template_registration=Affine \
    --bold_robust_inho_cor apply=true,masking=true,brain_extraction=true,template_registration=Affine \
    --bold2anat_coreg masking=true,brain_extraction=true,registration=Affine \
    --HMC_option 1
