#!/bin/bash
#===============================================================================
# Download DAP-seq Reads 
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Download DAP-Seq reads from GSE60143 for ARF5 samples using fasterq-dump
#===============================================================================

set -e
set -u

PROJECT_DIR="m7_project"
RAW_DIR="${PROJECT_DIR}/data/raw"
N_JOBS=8

ml mamba

source activate module_7_dapseq

declare -A SAMPLES=(
    ["SRR2926068"]="GSM1924998_control_beads"
    ["SRR2926896"]="GSM1925826_ARF5_rep1"
    ["SRR2926208"]="GSM1925138_ARF2"
    ["SRR2926207"]="GSM1925137_ARF16"
)

echo "=========================================="
echo "DAP-seq Download (R1 only)"
echo "Samples: ${#SAMPLES[@]} | Jobs: ${N_JOBS}"
echo "=========================================="

export RAW_DIR

download_sample() {
    local SRR=$1
    local NAME=$2
    
    [[ -f "${RAW_DIR}/${NAME}.fastq.gz" ]] && return 0
    
    fasterq-dump ${SRR} --outdir ${RAW_DIR} --split-files --threads 2
    
    # Use only R1, discard R2
    if [[ -f "${RAW_DIR}/${SRR}_1.fastq" ]]; then
        pigz -p 2 ${RAW_DIR}/${SRR}_1.fastq
        mv ${RAW_DIR}/${SRR}_1.fastq.gz ${RAW_DIR}/${NAME}.fastq.gz
        rm -f ${RAW_DIR}/${SRR}_2.fastq ${RAW_DIR}/${SRR}.fastq
    elif [[ -f "${RAW_DIR}/${SRR}.fastq" ]]; then
        pigz -p 2 ${RAW_DIR}/${SRR}.fastq
        mv ${RAW_DIR}/${SRR}.fastq.gz ${RAW_DIR}/${NAME}.fastq.gz
    fi
}

export -f download_sample

for SRR in "${!SAMPLES[@]}"; do
    echo "${SRR} ${SAMPLES[$SRR]}"
done | parallel --colsep ' ' -j ${N_JOBS} download_sample {1} {2}

echo ""
echo " Complete!"
ls -lh ${RAW_DIR}/*.fastq.gz 2>/dev/null | awk '{print $9, $5}'