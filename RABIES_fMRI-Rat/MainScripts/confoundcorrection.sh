#!/usr/bin/env bash
set -euo pipefail

# Docker image 
DOCKER_IMG="gabdesgreg/rabies:0.5.0"

# Directories 
BIDS_DIR="${PWD}/input_bids"
INPUT_DIR="${PWD}/preprocess_outputs"
OUTPUT_DIR="${PWD}/confound_correction_outputs"
TEMPLATE_DIR="${PWD}/rat_templates"


docker run -it --rm \
  --shm-size=2g \
  --user $(id -u):$(id -g) \
  -e HOME=/home/rabies/tmp \
  -e NIPYPE_OUTPUT_DIR=/home/rabies/tmp \
  -e NIPYPE_CRASHFILE_DIR=/home/rabies/tmp \
  -e MPLCONFIGDIR=/home/rabies/tmp \
  -v "${BIDS_DIR}:/input_BIDS:ro" \
  -v "${INPUT_DIR}:/preprocess_outputs:ro" \
  -v "${OUTPUT_DIR}:/confound_correction_outputs" \
  -v "${TEMPLATE_DIR}:/rat_templates:ro" \
  "${DOCKER_IMG}" -p MultiProc \
    --scale_min_memory 3 \
    --local_threads 8 \
    --min_proc 1 \
  confound_correction /preprocess_outputs/ /confound_correction_outputs/ \
    --detrending_order linear \
    --ica_aroma apply=true,dim=0,random_seed=1 \
    --conf_list WM_signal CSF_signal global_signal mot_6 \
    --smoothing_filter 0.4 \
    --highpass 0.01 \
    --lowpass 0.1 

