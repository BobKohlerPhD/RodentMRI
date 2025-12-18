library(oro.nifti)

# Load .nii mask file to binarize
nii_mask_nonbin  <- readNIfTI("/Users/bobkohler/rodent_mri/rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_csf.nii.gz",
                               ,reorient = FALSE)

# Create new name for array and use original array to do binning 
nii_mask_bin       <- nii_mask_nonbin
nii_mask_bin@.Data <- ifelse(nii_mask_nonbin@.Data > 0.5, 1, 0)

# Save new .nii
writeNIfTI(nii_mask_bin, filename = "SIGMA_InVivo_Anatomical_Brain_csf_bin")
