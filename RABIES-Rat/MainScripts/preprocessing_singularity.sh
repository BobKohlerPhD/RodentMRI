#!/usr/bin/env bash
#SBATCH --job-name=rabies_preproc
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=12:00:00
#SBATCH --partition=day
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=
#SBATCH --output=/rabies_preproc_%j.out
#SBATCH --error=/rabies_preproc_%j.err

set -euo pipefail

# Apptainer or Singularity module load
module purge
module load apptainer 2>/dev/null || module load singularity 2>/dev/null || true
if ! command -v singularity >/dev/null 2>&1 && command -v apptainer >/dev/null 2>&1; then
  shopt -s expand_aliases
  alias singularity='apptainer'
fi

# Paths
BASE_DIR="${SLURM_SUBMIT_DIR}"

# Paths relative to the repo root
INPUT_DIR="${BASE_DIR}/input_bids"
OUTPUT_DIR="${BASE_DIR}/preprocess_outputs"
TEMPLATE_DIR="${BASE_DIR}/rat_templates"
CONTAINER_DIR="${BASE_DIR}/containers"
IMAGE_SIF="${CONTAINER_DIR}/rabies_0.5.0.sif"
DOCKER_URI="docker://gabdesgreg/rabies:0.5.0"

# Create directories if not made already
mkdir -p "${CONTAINER_DIR}" "${OUTPUT_DIR}/logs" "${OUTPUT_DIR}/tmp"

# Prefer node-local scratch for cache
NODE_TMP="${SLURM_TMPDIR:-${OUTPUT_DIR}/tmp}"
mkdir -p "${NODE_TMP}"

# Keep container cache local to your job space
export SINGULARITY_CACHEDIR="${CONTAINER_DIR}"
export SINGULARITY_TMPDIR="${NODE_TMP}"

# Pull once on login or first run
if [[ ! -f "${IMAGE_SIF}" ]]; then
  echo "[INFO] Pulling RABIES container to ${IMAGE_SIF}..."
  ( cd "${CONTAINER_DIR}" && singularity pull "$(basename "${IMAGE_SIF}")" "${DOCKER_URI}" )
fi

# Threads for multiproc
LOCAL_THREADS="${SLURM_CPUS_PER_TASK:-4}"

# Container-side env
export SINGULARITYENV_HOME=/home/rabies/tmp
export SINGULARITYENV_NIPYPE_OUTPUT_DIR=/home/rabies/tmp
export SINGULARITYENV_NIPYPE_CRASHFILE_DIR=/home/rabies/tmp
export SINGULARITYENV_MPLCONFIGDIR=/home/rabies/tmp
export SINGULARITYENV_OMP_NUM_THREADS="${LOCAL_THREADS}"
export SINGULARITYENV_MKL_NUM_THREADS="1"
export SINGULARITYENV_OPENBLAS_NUM_THREADS="1"
export SINGULARITYENV_NUMEXPR_NUM_THREADS="1"

# Bind mounts
BINDINGS=(
  "${INPUT_DIR}:/input_BIDS:ro"
  "${OUTPUT_DIR}:/preprocess_outputs"
  "${OUTPUT_DIR}/tmp:/home/rabies/tmp"
  "${TEMPLATE_DIR}:/rat_templates:ro"
)

BIND_CSV="$(IFS=, ; echo "${BINDINGS[*]}")"

echo "[INFO] Running RABIES preprocess with ${LOCAL_THREADS} threads..."
singularity run --cleanenv -B "${BIND_CSV}" "${IMAGE_SIF}" \
  -p MultiProc \
  --scale_min_memory 3 \
  --local_threads "${LOCAL_THREADS}" \
  --min_proc 1 \
  preprocess /input_BIDS/ /preprocess_outputs/ \
    --anat_template  /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_template.nii.gz \
    --brain_mask     /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_mask.nii.gz \
    --WM_mask        /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_wm_bin.nii.gz \
    --CSF_mask       /rat_templates/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template/anatomy/SIGMA_InVivo_Anatomical_Brain_csf_bin.nii.gz \
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

echo "[INFO] Done."
