# RABIES MRI Processing Pipeline Implementation for Rats

This repository implements the **RABIES** (Rodent Automated Bold Improvement of EPI Sequences) MRI image processing pipeline for rats using Docker and Singularity.

## References
* **Official Documentation:** [RABIES](https://rabies.readthedocs.io/en/latest/)
* **Source Code:** [CoBrALab/RABIES GitHub](https://github.com/CoBrALab/RABIES)

## Current Structure

```text
.
├── MainScripts
│   ├── analysis_funcmatrix_singularity.sh
│   ├── analysis_functionalmatrix.sh
│   ├── confoundcorrection.sh
│   ├── preprocessing_singularity.sh
│   └── preprocessing.sh
└── QualityControl
    ├── Summarize_Motion.R
    └── Summary_FuncMatrix.R

