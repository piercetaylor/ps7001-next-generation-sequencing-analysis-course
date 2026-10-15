#!/bin/bash
#===============================================================================
# Setup Script for STAR RNA-seq Alignment Pipeline
# Script 0: Project Setup and Environment Creation
# Description: Creates project directory structure and conda environment
#              for complete RNA-seq analysis using STAR genome alignment
#===============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="star_rnaseq"
ENV_NAME="module_5_STAR"
ENV_FILE="${PROJECT_DIR}/star_pipeline.yml"

echo "=========================================="
echo "STAR RNA-seq Pipeline Setup"
echo "Project: ${PROJECT_DIR}"
echo "Environment: ${ENV_NAME}"
echo "Date: $(date)"
echo "=========================================="

#===============================================================================
# Step 1: Create Project Directory Structure
#===============================================================================
echo ""
echo "[1/3] Creating project directory structure..."

mkdir -p ${PROJECT_DIR}/{data/{raw,trimmed},results/{alignment/bam,counts,qc/{fastqc,multiqc,qualimap},tracks},references/{genome,annotation,star_index},scripts,logs}

echo "  Created main directories:"
echo "    - ${PROJECT_DIR}/data/raw               (for downloaded FASTQ files)"
echo "    - ${PROJECT_DIR}/data/trimmed           (for quality-trimmed reads)"
echo "    - ${PROJECT_DIR}/results/alignment/bam  (for BAM files)"
echo "    - ${PROJECT_DIR}/results/counts         (for gene counts)"
echo "    - ${PROJECT_DIR}/results/qc             (for QC reports)"
echo "    - ${PROJECT_DIR}/results/tracks         (for genome browser tracks)"
echo "    - ${PROJECT_DIR}/references/genome      (for genome FASTA)"
echo "    - ${PROJECT_DIR}/references/annotation  (for GTF/GFF files)"
echo "    - ${PROJECT_DIR}/references/star_index  (for STAR index)"
echo "    - ${PROJECT_DIR}/scripts                (for analysis scripts)"
echo "    - ${PROJECT_DIR}/logs                   (for job logs)"

#===============================================================================
# Step 2: Create Conda Environment YAML File
#===============================================================================
echo ""
echo "[2/3] Creating conda environment specification..."

cat > ${ENV_FILE} << 'EOF'
name: module_5_STAR
channels:
  - bioconda
  - conda-forge
  - defaults
dependencies:
  # Quality control and preprocessing
  - fastp                # Fast all-in-one preprocessing (adapter trimming, QC)
  - multiqc              # Aggregate QC reports from multiple tools
  
  # Alignment
  - star                 # Spliced Transcripts Alignment to a Reference
  - samtools             # SAM/BAM file manipulation and statistics
  
  # Quantification
  - subread              # featureCounts for gene-level quantification
  - salmon               # Optional: pseudo-alignment quantification
  
  # Visualization and tracks
  - deeptools            # Coverage tracks, heatmaps, fingerprints
  - ucsc-wigtobigwig     # Convert bedGraph to BigWig format
  - qualimap             # BAM quality control with detailed stats
  
  # File manipulation
  - bedtools             # Genome arithmetic operations
  - gffread              # GTF/GFF manipulation and format conversion
  
  # Data acquisition
  - sra-tools            # Download from NCBI SRA
  - entrez-direct        # NCBI E-utilities for metadata
  
  # Utilities
  - pigz                 # Parallel gzip compression
EOF

echo "  Environment file created: ${ENV_FILE}"

#===============================================================================
# Step 3: Create Conda Environment
#===============================================================================
echo ""
echo "[3/3] Creating conda environment with mamba..."

# Load mamba module (adjust for your cluster)
module load mamba 2>/dev/null || echo "  mamba module not found, trying direct mamba..."

# Check if environment already exists
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "  Environment ${ENV_NAME} already exists"
    read -p "  Remove and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "  Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "  Keeping existing environment"
        exit 0
    fi
fi

echo "  Creating new environment (this may take 5-10 minutes)..."
mamba env create -f ${ENV_FILE}

echo "  Environment created successfully"

#===============================================================================
# Step 4: Create Sample Sheet Template
#===============================================================================
echo ""
echo "[4/4] Creating sample sheet template..."

cat > ${PROJECT_DIR}/samples.csv << 'EOF'
sample_id,condition,replicate,srr_accession
control_rep1,control,1,SRR000001
control_rep2,control,2,SRR000002
control_rep3,control,3,SRR000003
treated_rep1,treated,1,SRR000004
treated_rep2,treated,2,SRR000005
treated_rep3,treated,3,SRR000006
EOF

echo "  Template created: ${PROJECT_DIR}/samples.csv"
echo "  IMPORTANT: Edit this file with your actual SRR accessions"

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
echo "Next steps:"
echo "1. Edit ${PROJECT_DIR}/samples.csv with your SRR accessions"
echo "2. Download reference genome and annotation to ${PROJECT_DIR}/references/"
echo "3. Activate environment: conda activate ${ENV_NAME}"
echo "4. Run: ./1_download_and_align.sh"
echo ""
echo "To activate the environment:"
echo "  conda activate ${ENV_NAME}"
echo ""
echo "To deactivate:"
echo "  conda deactivate"
echo ""
echo "=========================================="