#!/bin/bash
#===============================================================================
# DAP-seq Motif Discovery 
# Author: Pierce Taylor
# Date: December 8, 2025
#===============================================================================

set -e
set -u

PROJECT_DIR="m7_project"
PEAKS_DIR="${PROJECT_DIR}/results/peaks/macs2"
MOTIF_DIR="${PROJECT_DIR}/results/motifs"
REF_DIR="${PROJECT_DIR}/references/genome"

# Your 3 samples
SAMPLES=(
    "GSM1925826_ARF5_rep1"
    "GSM1925138_ARF2"
    "GSM1925137_ARF16"
)

ml mamba

source activate module_7_dapseq

mkdir -p ${MOTIF_DIR}/{meme,homer,sequences}

echo "=========================================="
echo "Motif Discovery"
echo "Samples: ${#SAMPLES[@]}"
echo "=========================================="

# Find genome
GENOME_FA=$(find ${REF_DIR} -name "*.fa" | head -1)
echo "Genome: ${GENOME_FA}"

#===============================================================================
# STEP 1: Extract sequences (top 500 peaks)
#===============================================================================
echo ""
echo "[1/3] Extracting sequences..."

for SAMPLE in "${SAMPLES[@]}"; do
    PEAK_FILE="${PEAKS_DIR}/${SAMPLE}_peaks.narrowPeak"
    
    [[ ! -f "${PEAK_FILE}" ]] && continue
    
    echo "  ${SAMPLE}"
    
    # Get summit ±100bp for top 500 peaks
    awk 'BEGIN{OFS="\t"} {
        summit=$2+$10
        start=summit-100
        end=summit+100
        if(start<0) start=0
        print $1,start,end,$4,$5
    }' ${PEAK_FILE} | \
    sort -k5,5nr | \
    head -500 > ${MOTIF_DIR}/sequences/${SAMPLE}_summits.bed
    
    # Extract FASTA
    bedtools getfasta \
        -fi ${GENOME_FA} \
        -bed ${MOTIF_DIR}/sequences/${SAMPLE}_summits.bed \
        > ${MOTIF_DIR}/sequences/${SAMPLE}.fa
    
    echo "    $(grep -c '^>' ${MOTIF_DIR}/sequences/${SAMPLE}.fa) sequences"
done

#===============================================================================
# STEP 2: HOMER motif discovery
#===============================================================================
echo ""
echo "[2/3] Running HOMER..."

for SAMPLE in "${SAMPLES[@]}"; do
    PEAK_FILE="${PEAKS_DIR}/${SAMPLE}_peaks.narrowPeak"
    
    [[ ! -f "${PEAK_FILE}" ]] && continue
    
    echo "  ${SAMPLE}"
    
    findMotifsGenome.pl \
        ${PEAK_FILE} \
        ${GENOME_FA} \
        ${MOTIF_DIR}/homer/${SAMPLE} \
        -size 200 \
        -mask \
        -p 4
    
    echo "    Done: ${MOTIF_DIR}/homer/${SAMPLE}/homerResults.html"
done

#===============================================================================
# STEP 3: MEME-ChIP
#===============================================================================
echo ""
echo "[3/3] Running MEME-ChIP..."

for SAMPLE in "${SAMPLES[@]}"; do
    FASTA="${MOTIF_DIR}/sequences/${SAMPLE}.fa"
    
    [[ ! -f "${FASTA}" ]] && continue
    
    echo "  ${SAMPLE}"
    
    meme-chip \
        -oc ${MOTIF_DIR}/meme/${SAMPLE} \
        -meme-mod zoops \
        -meme-minw 6 \
        -meme-maxw 15 \
        -meme-nmotifs 3 \
        -dreme-m 3 \
        ${FASTA}
    
    echo "    Done: ${MOTIF_DIR}/meme/${SAMPLE}/meme-chip.html"
done

#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "Complete!"
echo "=========================================="
echo ""
echo "View results:"
for SAMPLE in "${SAMPLES[@]}"; do
    if [[ -f "${MOTIF_DIR}/meme/${SAMPLE}/meme-chip.html" ]]; then
        echo "  ${SAMPLE}:"
        echo "    MEME: ${MOTIF_DIR}/meme/${SAMPLE}/meme-chip.html"
        echo "    HOMER: ${MOTIF_DIR}/homer/${SAMPLE}/homerResults.html"
    fi
done
echo ""
echo "Expected ARF motif: TGTCGG"