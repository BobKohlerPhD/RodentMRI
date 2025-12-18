# RABIES MRI Processing Pipeline Implementation for Rats

This repository implements the **RABIES** (Rodent Automated Bold Improvement of EPI Sequences) MRI image processing pipeline for rats using Docker and Singularity.

## References
* **Official Documentation:** [RABIES](https://rabies.readthedocs.io/en/latest/)
* **Source Code:** [CoBrALab/RABIES GitHub](https://github.com/CoBrALab/RABIES)

## Current Structure

```text
├── RABIES-Rat
│   ├── input_bids
│   ├── MainScripts
│   │   ├── analysis_funcmatrix_singularity.sh
│   │   ├── analysis_functionalmatrix.sh
│   │   ├── confoundcorrection.sh
│   │   ├── preprocessing_singularity.sh
│   │   └── preprocessing.sh
│   ├── preprocess_outputs
│   ├── QualityControl
│   │   ├── Summarize_Motion.R
│   │   └── Summary_FuncMatrix.R
│   └── rat_templates
│       └── SIGMA_Rat_Anatomical_Imaging # Download and place atlases here
├── README.md
└── UtilityScripts
    ├── bin_mask.R
    └── NeuroCombat.R
```
