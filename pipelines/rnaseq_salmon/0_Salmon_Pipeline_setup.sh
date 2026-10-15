#!/bin/bash
#===============================================================================
# Setup Script for Salmon RNA-seq Pipeline
# Script 0: Project Setup and Environment Creation
# Description: Creates project directory structure and conda environment
#              for complete RNA-seq analysis using Salmon pseudo-alignment
#===============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="salmon_rnaseq"
ENV_NAME="Salmon_Pipeline"
ENV_FILE="${PROJECT_DIR}/salmon_pipeline.yml"

echo "=========================================="
echo "Salmon RNA-seq Pipeline Setup"
echo "Project: ${PROJECT_DIR}"
echo "Environment: ${ENV_NAME}"
echo "Date: $(date)"
echo "=========================================="

#===============================================================================
# Step 1: Create Project Directory Structure
#===============================================================================
echo ""
echo "[1/3] Creating project directory structure..."

mkdir -p ${PROJECT_DIR}/{data/{raw,trimmed},results/{salmon,deseq2,figures,enrichment},references,scripts,logs}

echo "   Created main directories:"
echo "    - ${PROJECT_DIR}/data/raw           (for downloaded FASTQ files)"
echo "    - ${PROJECT_DIR}/data/trimmed       (for quality-trimmed reads)"
echo "    - ${PROJECT_DIR}/results/salmon     (for Salmon quantifications)"
echo "    - ${PROJECT_DIR}/results/deseq2     (for DE analysis)"
echo "    - ${PROJECT_DIR}/results/figures    (for plots)"
echo "    - ${PROJECT_DIR}/results/enrichment (for GO/KEGG)"
echo "    - ${PROJECT_DIR}/references         (for transcriptome/annotation)"
echo "    - ${PROJECT_DIR}/scripts            (for R scripts)"
echo "    - ${PROJECT_DIR}/logs               (for job logs)"

#===============================================================================
# Step 2: Create Conda Environment YAML File
#===============================================================================
echo ""
echo "[2/3] Creating conda environment specification..."

cat > ${ENV_FILE} << 'EOF'
name: Salmon_Pipeline
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  # Core environments
  - python
  - bash_kernel
  - r-base=4.3
  - r-irkernel
  - r-devtools
  - r-biocmanager
  
  # R data manipulation and visualization
  - r-tidyverse
  - r-tidyr
  - r-readr
  - r-dplyr
  - r-data.table
  - r-ggplot2
  - r-cowplot
  - r-pheatmap
  - r-upsetr
  - r-ggrepel
  - r-reshape2
  - r-stringi
  - r-shiny
  - r-plotly
  
  # Sequencing tools
  - fastp
  - salmon
  - sra-tools
  - bedtools
  - samtools
  - seqkit
  - seqtk
  - igv
  - pigz
  
  # Bioconductor packages
  - bioconductor-deseq2
  - bioconductor-tximport
  - bioconductor-apeglm
  - bioconductor-annotationdbi
  - bioconductor-clusterprofiler
  - bioconductor-enrichplot
  - bioconductor-goseq
  - bioconductor-pathview
  - bioconductor-gseabase
  - bioconductor-geoquery
  - bioconductor-complexheatmap
  - bioconductor-genomicfeatures
  - bioconductor-genomicranges
  - bioconductor-summarizedexperiment
  - bioconductor-tximeta
EOF

echo "   Environment file created: ${ENV_FILE}"

#===============================================================================
# Step 3: Create Conda Environment
#===============================================================================
echo ""
echo "[3/3] Creating conda environment with mamba..."

# Load mamba module (adjust for your cluster)
module load mamba 2>/dev/null || echo "  ⚠ mamba module not found, trying direct mamba..."

# Check if environment already exists
if conda env list | grep -q "^${ENV_NAME} "; then
    echo "  ⚠ Environment ${ENV_NAME} already exists"
    read -p "  Remove and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Removing existing environment..."
        conda env remove -n ${ENV_NAME} -y
    else
        echo "   Keeping existing environment"
        exit 0
    fi
fi

echo "   Creating new environment (this may take 10-15 minutes)..."
mamba env create -f ${ENV_FILE}

echo "   Environment created successfully"

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

echo "   Template created: ${PROJECT_DIR}/samples.csv"
echo "  ⚠ IMPORTANT: Edit this file with your actual SRR accessions!"

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
echo "2. Download reference transcriptome to ${PROJECT_DIR}/references/"
echo "3. Activate environment: conda activate ${ENV_NAME}"
echo "4. Run: ./1_download_and_qc.sh"
echo ""
echo "To activate the environment:"
echo "  $ conda activate ${ENV_NAME}"
echo ""
echo "To deactivate:"
echo "  $ conda deactivate"
echo ""
echo "=========================================="