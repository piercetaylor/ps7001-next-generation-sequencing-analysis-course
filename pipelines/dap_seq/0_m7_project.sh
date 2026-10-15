#!/bin/bash
#===============================================================================
# Main bash script for M7 DAP-seq Project Setup
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Sets up directory structure, creates conda environment, and
#              prepares Hellbender HPC for DAP-seq analysis
#===============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="m7_project"
ENV_NAME="module_7_dapseq"
ENV_FILE="${PROJECT_DIR}/scripts/dapseq_environment.yml"

echo "=========================================="
echo "DAP-seq Analysis Environment Setup"
echo "Project: ${PROJECT_DIR}"
echo "Environment: ${ENV_NAME}"
echo "Date: $(date)"
echo "=========================================="

#===============================================================================
# Step 1: Create Project Directory Structure
#===============================================================================
echo ""
echo "[1/4] Creating project directory structure..."

mkdir -p ${PROJECT_DIR}/{data/{raw,trimmed,sra},results/{alignment,peaks,motifs,qc,bigwig},scripts,references/{genome,annotation,bowtie2_index},logs}

echo "  ✓ Created main directories:"
echo "    - ${PROJECT_DIR}/data/raw          (for downloaded FASTQ files)"
echo "    - ${PROJECT_DIR}/data/trimmed      (for quality-trimmed reads)"
echo "    - ${PROJECT_DIR}/results/alignment (for BAM files)"
echo "    - ${PROJECT_DIR}/results/peaks     (for MACS2 peak calls)"
echo "    - ${PROJECT_DIR}/results/motifs    (for MEME/HOMER output)"
echo "    - ${PROJECT_DIR}/results/qc        (for FastQC/MultiQC reports)"
echo "    - ${PROJECT_DIR}/results/bigwig    (for genome browser tracks)"
echo "    - ${PROJECT_DIR}/references/genome (for TAIR10 FASTA)"
echo "    - ${PROJECT_DIR}/references/bowtie2_index (for Bowtie2 index)"
echo "    - ${PROJECT_DIR}/logs              (for job logs)"

#===============================================================================
# Step 2: Create Conda Environment YAML File
#===============================================================================
echo ""
echo "[2/4] Creating conda environment specification..."

cat > ${ENV_FILE} << 'EOF'
name: module_7_dapseq
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  # Data acquisition
  - sra-tools
  - entrez-direct
  
  # QC and preprocessing
  - fastqc
  - fastp
  - multiqc
  
  # Alignment (CRITICAL for DAP-seq)
  - bowtie2
  
  # BAM processing
  - samtools
  - bamtools
  - picard
  - htslib
  - tabix
  
  # Peak analysis
  - bedtools
  - bedops
  - macs2
  
  # Visualization
  - deeptools
  - ucsc-bedgraphtobigwig
  - igv
  
  # Motif analysis
  - meme
  - homer
  
  # Utilities
  - pigz
  - parallel
EOF

echo "Environment file created: ${ENV_FILE}"

#===============================================================================
# Step 3: Load Mamba Module (Hellbender HPC)
#===============================================================================
echo ""
echo "[3/4] Loading mamba module via Lmod..."

module load mamba

#===============================================================================
# Step 4: Create Conda Environment
#===============================================================================
echo ""
echo "[4/4] Creating conda environment with mamba..."


echo "  → Creating new environment (this may take 5-10 minutes)..."

mamba env create -f ${ENV_FILE}

echo "Environment created successfully"

#===============================================================================
# Summary and Next Steps
#===============================================================================
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Project structure created in: ${PROJECT_DIR}/"
echo "Conda environment: ${ENV_NAME}"
echo ""
echo "To activate the environment:"
echo "  $ conda activate ${ENV_NAME}"
echo ""
echo "To deactivate:"
echo "  $ conda deactivate"
echo ""
echo "Next steps:"
echo "Run the 6 bash scripts within the Module_7 folder in order 1 - 6"
echo "See the DAP-seq analysis Jupyter notebook for detailed commands."
echo "=========================================="