#!/bin/bash
#===============================================================================
# DAP-seq Peak Annotation
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Annotate peaks to nearest genes using bedtools
#===============================================================================

set -e
set -u

PROJECT_DIR="m7_project"
PEAKS_DIR="${PROJECT_DIR}/results/peaks/macs2"
ANNOT_DIR="${PROJECT_DIR}/results/annotation"
REF_DIR="${PROJECT_DIR}/references"

# Your 3 samples
SAMPLES=(
    "GSM1925826_ARF5_rep1"
    "GSM1925138_ARF2"
    "GSM1925137_ARF16"
)

ml mamba

source activate module_7_dapseq

mkdir -p ${ANNOT_DIR}

echo "=========================================="
echo "Peak Annotation"
echo "Samples: ${#SAMPLES[@]}"
echo "=========================================="

#===============================================================================
# STEP 1: Get TAIR10 annotation
#===============================================================================
echo ""
echo "[1/3] Downloading TAIR10 annotation..."

ANNOTATION="${REF_DIR}/annotation/TAIR10_GFF3_genes.gff"

if [[ ! -f "${ANNOTATION}" ]]; then
    mkdir -p ${REF_DIR}/annotation
    
    echo "  Downloading from NCBI..."
    wget -O ${REF_DIR}/annotation/TAIR10.gff.gz \
         ftp://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.51.gff3.gz
    
    gunzip ${REF_DIR}/annotation/TAIR10.gff.gz
    
 #Extract only gene features and sort properly
    echo "  Extracting and sorting gene features..."
    grep -P "\tgene\t" ${REF_DIR}/annotation/TAIR10.gff | \
        sort -k1,1 -k4,4n > ${ANNOTATION}
    
    echo "   Annotation downloaded"
else
    echo "   Annotation exists"
fi

N_GENES=$(wc -l < ${ANNOTATION})
echo "  Total genes: ${N_GENES}"

#===============================================================================
# STEP 2: Annotate peaks to nearest genes
#===============================================================================
echo ""
echo "[2/3] Annotating peaks to genes..."

for SAMPLE in "${SAMPLES[@]}"; do
    PEAK_FILE="${PEAKS_DIR}/${SAMPLE}_peaks.narrowPeak"
    
    [[ ! -f "${PEAK_FILE}" ]] && continue
    
    echo ""
    echo "  ${SAMPLE}"
    
    N_PEAKS=$(wc -l < ${PEAK_FILE})
    echo "    Total peaks: ${N_PEAKS}"
    
    # Find closest gene for each peak
    OUTPUT="${ANNOT_DIR}/${SAMPLE}_annotated.txt"
    
    bedtools closest \
        -a ${PEAK_FILE} \
        -b ${ANNOTATION} \
        -d > ${OUTPUT}
    
    # Count peaks in different genomic regions
    PROMOTER=$(awk '$NF <= 2000 && $NF >= 0' ${OUTPUT} | wc -l)
    GENIC=$(awk '$NF == 0' ${OUTPUT} | wc -l)
    INTERGENIC=$(awk '$NF > 2000' ${OUTPUT} | wc -l)
    
    echo "    Promoter (≤2kb): ${PROMOTER} ($(awk "BEGIN {printf \"%.1f\", (${PROMOTER}/${N_PEAKS})*100}")%)"
    echo "    Genic (overlap): ${GENIC} ($(awk "BEGIN {printf \"%.1f\", (${GENIC}/${N_PEAKS})*100}")%)"
    echo "    Intergenic (>2kb): ${INTERGENIC} ($(awk "BEGIN {printf \"%.1f\", (${INTERGENIC}/${N_PEAKS})*100}")%)"
    
    # Extract gene list
    GENE_LIST="${ANNOT_DIR}/${SAMPLE}_target_genes.txt"

    awk '$NF <= 2000' ${OUTPUT} | \
        grep -oP 'gene_id=\K[^;]+' | \
        sort -u > ${GENE_LIST}
    N_GENES=$(wc -l < ${GENE_LIST})
    echo "    Target genes (≤2kb): ${N_GENES}"
done

#===============================================================================
# STEP 3: Create summary report
#===============================================================================
echo ""
echo "[3/3] Creating summary report..."

SUMMARY="${ANNOT_DIR}/annotation_summary.txt"

echo -e "Sample\tTotal_Peaks\tPromoter\tGenic\tIntergenic\tTarget_Genes" > ${SUMMARY}

for SAMPLE in "${SAMPLES[@]}"; do
    ANNOT="${ANNOT_DIR}/${SAMPLE}_annotated.txt"
    GENES="${ANNOT_DIR}/${SAMPLE}_target_genes.txt"
    
    [[ ! -f "${ANNOT}" ]] && continue
    
    TOTAL=$(wc -l < ${ANNOT})
    PROMOTER=$(awk '$NF <= 2000 && $NF >= 0' ${ANNOT} | wc -l)
    GENIC=$(awk '$NF == 0' ${ANNOT} | wc -l)
    INTERGENIC=$(awk '$NF > 2000' ${ANNOT} | wc -l)
    N_GENES=$(wc -l < ${GENES})
    
    echo -e "${SAMPLE}\t${TOTAL}\t${PROMOTER}\t${GENIC}\t${INTERGENIC}\t${N_GENES}" >> ${SUMMARY}
done

echo ""
echo "Annotation Summary:"
column -t ${SUMMARY}

#===============================================================================
# STEP 4: Compare target genes
#===============================================================================
echo ""
echo "[4/4] Comparing target genes..."

# Find common targets between ARF5 and other ARFs
ARF5_GENES="${ANNOT_DIR}/GSM1925826_ARF5_rep1_target_genes.txt"

if [[ -f "${ARF5_GENES}" ]]; then
    for SAMPLE in GSM1925138_ARF2 GSM1925137_ARF16; do
        SAMPLE_GENES="${ANNOT_DIR}/${SAMPLE}_target_genes.txt"
        
        [[ ! -f "${SAMPLE_GENES}" ]] && continue
        
        COMMON=$(comm -12 <(sort ${ARF5_GENES}) <(sort ${SAMPLE_GENES}) | wc -l)
        ARF5_TOTAL=$(wc -l < ${ARF5_GENES})
        SAMPLE_TOTAL=$(wc -l < ${SAMPLE_GENES})

        if [[ ${ARF5_TOTAL} -gt 0 ]]; then
            PERCENT=$(awk "BEGIN {printf \"%.1f\", (${COMMON}/${ARF5_TOTAL})*100}")
            echo "  ARF5 vs ${SAMPLE}: ${COMMON} common genes (${PERCENT}% of ARF5 targets)"
        else
            echo "  ARF5 vs ${SAMPLE}: No ARF5 target genes found (annotation may have failed)"
        fi
        
        # Save overlap
        comm -12 <(sort ${ARF5_GENES}) <(sort ${SAMPLE_GENES}) > \
            ${ANNOT_DIR}/ARF5_vs_${SAMPLE}_common.txt
    done
fi

#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "Complete!"
echo "=========================================="
echo ""
echo "Output files:"
echo "  Annotated peaks: ${ANNOT_DIR}/*_annotated.txt"
echo "  Target genes:    ${ANNOT_DIR}/*_target_genes.txt"
echo "  Summary:         ${ANNOT_DIR}/annotation_summary.txt"
echo ""
echo "Top 20 target genes (ARF5):"
if [[ -f "${ARF5_GENES}" ]]; then
    head -20 ${ARF5_GENES}
fi
echo ""
