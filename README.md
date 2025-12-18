# Generating Functional Connectivity Matrices for Rats using the RABIES Pipeline

This repository implements the **RABIES** (Rodent Automated Bold Improvement of EPI Sequences) MRI image processing pipeline for rats using Docker and Singularity.

## References
* **Official Documentation:** [RABIES](https://rabies.readthedocs.io/en/latest/)
* **Source Code:** [CoBrALab/RABIES GitHub](https://github.com/CoBrALab/RABIES)

## Current Structure

```text
├── RABIES-Rat
│   ├── input_bids                                    # Place BIDS formatted subject data here
│   ├── MainScripts
│   │   ├── analysis_funcmatrix_singularity.sh
│   │   ├── analysis_functionalmatrix.sh
│   │   ├── confoundcorrection.sh
│   │   ├── preprocessing_singularity.sh
│   │   └── preprocessing.sh
│   ├── preprocess_outputs                            # Folder for output 
│   ├── QualityControl
│   │   ├── Motion-Summary.R
│   │   └── FunctionalMatrix-Summary.R
│   └── rat_templates
│       └── SIGMA_Rat_Anatomical_Imaging              # Download and place atlases here
└── UtilityScripts
    ├── bin_mask.R
    └── NeuroCombat.R
```
## MainScripts
Contains preproessing -> confound correction ->  functional matrix analysis scripts for docker version of RABIES. 

Scripts with singularity in the name (all but confound correction available) were created for use in an HPC. Might need some adjusted to work. 

## QualityControl 
`Motion-Summary.R` parses preprocessed data for a`utobox_FD.csv` files and counts the number of times a motion spike > 0.05 occurs. A bar plot is generated to show summary of motion. Motion value can be changed in script. 

`FunctionalMatrix-Summary.R` reads functional connectivity matrices generated during the analysis step and generates a heatmap of the correlation values within each rodent matrix. 


## UtilityScripts
The CSF atlases was not binarized and thus would result in an error when used in the pipeline. The `binarize_mask.R` script will binarize a .nii mask file. 

The `NeuroCombat.R` script is older code that was originally used for processed beta weights derived from human fMRI. Left in this repo as it could be useful if adjusted for certain purposes. Will likely place in a different repo at some point. 
