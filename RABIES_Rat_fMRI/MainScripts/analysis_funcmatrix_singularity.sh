{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 #!/bin/bash\
#SBATCH --job-name=rabies_preproc\
#SBATCH --output=logs/rabies_preproc_%j.out\
#SBATCH --error=logs/rabies_preproc_%j.err\
#SBATCH --ntasks=1\
#SBATCH --cpus-per-task=8\
#SBATCH --mem=24G\
#SBATCH --time=12:00:00\
#SBATCH --partition=standard  # <-- Change this if your cluster uses a different partition\
#SBATCH --mail-type=FAIL,END\
#SBATCH --mail-user=your_email@example.com  # <-- Set your email address\
\
# Load Singularity \
module load singularity\
\
\
# Define paths\
\
BASE_DIR=$PWD/RABIES\
TEMPLATE_DIR=$BASE_DIR/SIGMA/SIGMA_Rat_Anatomical_Imaging/SIGMA_Rat_Anatomical_InVivo_Template\
BIDS_DIR=$BASE_DIR/input_BIDS\
PREPROCESS_DIR=$BASE_DIR/preprocess_outputs\
CONFOUND_DIR=$BASE_DIR/confound_correction_outputs\
ANALYSIS_DIR=$BASE_DIR/analysis_outputs\
\
# Location of the Singularity image (ensure this exists or build it beforehand)\
SIMG_PATH=$PWD/rabies_0.5.0.sif\
\
# Use SLURM-provided scratch directory or create your own\
export TMPDIR=$SLURM_TMPDIR\
mkdir -p $TMPDIR\
\
# Optional logging\
echo "TMPDIR is $TMPDIR"\
echo "Running on $(hostname)"\
echo "Start time: $(date)"\
\
\
# Run the RABIES with Singularity\
\
singularity run \\\
  --cleanenv \\\
  --bind $BIDS_DIR:/input_BIDS:ro \\\
  --bind $PREPROCESS_DIR:/preprocess_outputs \\\
  --bind $CONFOUND_DIR:/confound_correction_outputs \\\
  --bind $ANALYSIS_DIR:/analysis_outputs \\\
  --bind $TEMPLATE_DIR:/rat_templates:ro \\\
  --env HOME=$TMPDIR \\\
  --env NIPYPE_OUTPUT_DIR=$TMPDIR \\\
  --env NIPYPE_CRASHFILE_DIR=$TMPDIR \\\
  --env MPLCONFIGDIR=$TMPDIR \\\
  "$SIMG_PATH" \\\
  -p MultiProc \\\
  --scale_min_memory 3 \\\
  --local_threads 8 \\\
  --min_proc 1 \\\
  analysis /confound_correction_outputs /analysis_outputs \\\
  --FC_matrix\
\
\
# Done\
\
echo "End time: $(date)"\
}