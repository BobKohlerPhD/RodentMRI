#!/usr/bin/env bash
set -euo pipefail # terminates script if any error 

# Docker image 
DOCKER_IMG="gabdesgreg/rabies:0.5.0"

# Directories 
INPUT_DIR="${PWD}/confound_correction_outputs"
OUTPUT_DIR="${PWD}/analysis_outputs"
TEMPLATE_DIR="${PWD}/rat_templates"

mkdir -p "$OUTPUT_DIR/tmp"
chown -R $(id -u):$(id -g) "$OUTPUT_DIR"


docker run -it --rm \
  --shm-size=2g \
  --user $(id -u):$(id -g) \
  -e HOME=/home/rabies/tmp \
  -e NIPYPE_OUTPUT_DIR=/home/rabies/tmp \
  -e NIPYPE_CRASHFILE_DIR=/home/rabies/tmp \
  -e MPLCONFIGDIR=/home/rabies/tmp \
  -v "${TEMPLATE_DIR}:/rat_templates:ro" \
  -v $PWD/input_bids:/input_BIDS:ro \
  -v $PWD/preprocess_outputs:/preprocess_outputs/ \
  -v "${INPUT_DIR}:/confound_correction_outputs:ro" \
  -v "${OUTPUT_DIR}:/analysis_outputs" \
  "${DOCKER_IMG}" -p MultiProc \
    --scale_min_memory 3 \
    --local_threads 4 \
  analysis /confound_correction_outputs/ /analysis_outputs/ \
     --FC_matrix
