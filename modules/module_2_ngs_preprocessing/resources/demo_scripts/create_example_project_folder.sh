#!/usr/bin/env bash
# ==============================================================
# Script Name: create_ngs_project_structure.sh
# Description: Sets up standardized folder structure for NGS projects
# ==============================================================

# Exit if any command fails
set -e

# ---[ 1. Get project name or use default ]---
PROJECT_NAME=${1:-NGS_Project}
BASE_DIR=${2:-"$HOME/projects"}        # default base path under ~/projects
PROJECT_ROOT="$BASE_DIR/$PROJECT_NAME"

echo "Creating project structure at: $PROJECT_ROOT"
echo "----------------------------------------------------"

# ---[ 2. Define subfolders ]---
declare -a DIRS=(
    # Data folders
    "data/raw"
    "data/trimmed"
    "data/aligned"
    "data/counts"

    # References
    "references/genome"
    "references/indices"
    "references/other"

    # Results
    "results/qc"
    "results/differential_expression"
    "results/visualization"
    "results/reports"

    # Scripts
    "scripts/preprocessing"
    "scripts/alignment"
    "scripts/analysis"
    "scripts/notebooks"
)

# ---[ 3. Create the directory structure ]---
for dir in "${DIRS[@]}"; do
    mkdir -p "$PROJECT_ROOT/$dir"
    echo "Created: $PROJECT_ROOT/$dir"
done

# ---[ 4. Create base README.md ]---
cat <<EOF > "$PROJECT_ROOT/README.md"
# Project: $PROJECT_NAME
Created on: $(date +"%Y-%m-%d")

## Folder Overview
- **data/**: Raw and processed NGS reads (FASTQ, BAM, count tables)
- **references/**: Genome, annotation (GTF/GFF), and indices
- **results/**: QC, differential expression, and visualizations
- **scripts/**: All preprocessing, alignment, and analysis scripts

## Notes
Keep raw FASTQ files immutable.
Store analysis environment files here (e.g. environment.yml).
EOF

echo "Created README.md"
