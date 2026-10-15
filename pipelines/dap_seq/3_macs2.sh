#!/bin/bash
#===============================================================================
# DAP-seq Peak Calling with MACS2
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Mark duplicates and call peaks using beads-only control
#              Following O'Malley et al. (2016) methodology
#===============================================================================

set -e
set -u
set -o pipefail

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="m7_project"
ALIGN_DIR="${PROJECT_DIR}/results/alignment"
BAM_DIR="${ALIGN_DIR}/bam"
PEAKS_DIR="${PROJECT_DIR}/results/peaks"
LOG_DIR="${PROJECT_DIR}/logs"

ENV_NAME="module_7_dapseq"
N_THREADS=8

# Control sample (beads-only background)
CONTROL_BAM="${BAM_DIR}/GSM1924998_control_beads.bam"

# Treatment samples (ARF transcription factors)
declare -a TREATMENTS=(
    "GSM1925826_ARF5_rep1"
    "GSM1925138_ARF2"
    "GSM1925137_ARF16"
)

# Create log file
LOGFILE="${LOG_DIR}/macs2_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "${LOGFILE}")
exec 2>&1

echo "=========================================="
echo "MACS2 Peak Calling Pipeline"
echo "Started: $(date)"
echo "Control: GSM1924998_control_beads"
echo "Treatments: ${#TREATMENTS[@]} samples"
echo "=========================================="

#===============================================================================
# Environment Check
#===============================================================================
echo ""
echo "[STEP 0] Checking environment..."

ml mamba

source activate module_7_dapseq

# Verify required tools
REQUIRED_TOOLS=(samtools picard macs2 bedtools)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: $tool not found"
        exit 1
    fi
    echo "   $tool"
done

# Check for BAM files
if [[ ! -f "${CONTROL_BAM}" ]]; then
    echo "ERROR: Control BAM not found: ${CONTROL_BAM}"
    echo "Please run alignment script first"
    exit 1
fi

echo "   Control BAM exists"

# Create output directories
mkdir -p ${PEAKS_DIR}/{markdup,macs2,summits,bedgraph}

#===============================================================================
# STEP 1: Mark Duplicates with Picard
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 1] Marking duplicates with Picard"
echo "=========================================="

# Mark duplicates in control
echo ""
echo "Processing control: GSM1924998_control_beads"
picard MarkDuplicates \
    I=${CONTROL_BAM} \
    O=${PEAKS_DIR}/markdup/GSM1924998_control_beads.markdup.bam \
    M=${PEAKS_DIR}/markdup/GSM1924998_control_beads.metrics.txt \
    REMOVE_DUPLICATES=false \
    ASSUME_SORTED=true \
    VALIDATION_STRINGENCY=LENIENT

# Index marked control
samtools index -@ ${N_THREADS} \
    ${PEAKS_DIR}/markdup/GSM1924998_control_beads.markdup.bam

echo "   Control marked and indexed"

# Mark duplicates in treatment samples
for SAMPLE in "${TREATMENTS[@]}"; do
    echo ""
    echo "Processing treatment: ${SAMPLE}"
    
    INPUT_BAM="${BAM_DIR}/${SAMPLE}.bam"
    OUTPUT_BAM="${PEAKS_DIR}/markdup/${SAMPLE}.markdup.bam"
    METRICS="${PEAKS_DIR}/markdup/${SAMPLE}.metrics.txt"
    
    if [[ ! -f "${INPUT_BAM}" ]]; then
        echo "   WARNING: ${INPUT_BAM} not found, skipping..."
        continue
    fi
    
    picard MarkDuplicates \
        I=${INPUT_BAM} \
        O=${OUTPUT_BAM} \
        M=${METRICS} \
        REMOVE_DUPLICATES=false \
        ASSUME_SORTED=true \
        VALIDATION_STRINGENCY=LENIENT
    
    # Index
    samtools index -@ ${N_THREADS} ${OUTPUT_BAM}
    
    # Extract duplication rate
    DUP_RATE=$(grep -A1 "LIBRARY" ${METRICS} | tail -1 | awk '{print $9}')
    echo "   ${SAMPLE} marked (dup rate: ${DUP_RATE})"
done

echo ""
echo " All samples marked for duplicates"

#===============================================================================
# STEP 2: Generate Duplication Summary
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 2] Duplication statistics"
echo "=========================================="

SUMMARY="${PEAKS_DIR}/markdup/duplication_summary.txt"
echo -e "Sample\tTotal_Reads\tDuplicate_Reads\tDuplication_Rate\tEstimated_Library_Size" > ${SUMMARY}

for METRICS in ${PEAKS_DIR}/markdup/*.metrics.txt; do
    SAMPLE=$(basename ${METRICS} .metrics.txt)
    
    # Extract key metrics (line after LIBRARY header)
    STATS=$(grep -A1 "LIBRARY" ${METRICS} | tail -1)
    TOTAL=$(echo ${STATS} | awk '{print $3}')
    DUPS=$(echo ${STATS} | awk '{print $7}')
    DUP_RATE=$(echo ${STATS} | awk '{print $9}')
    LIB_SIZE=$(echo ${STATS} | awk '{print $10}')
    
    echo -e "${SAMPLE}\t${TOTAL}\t${DUPS}\t${DUP_RATE}\t${LIB_SIZE}" >> ${SUMMARY}
done

echo ""
echo "Duplication Summary:"
column -t ${SUMMARY}

#===============================================================================
# STEP 3: Call Peaks with MACS2
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 3] Calling peaks with MACS2"
echo "=========================================="

CONTROL_MARKDUP="${PEAKS_DIR}/markdup/GSM1924998_control_beads.markdup.bam"

for SAMPLE in "${TREATMENTS[@]}"; do
    echo ""
    echo "Calling peaks: ${SAMPLE}"
    
    TREATMENT_BAM="${PEAKS_DIR}/markdup/${SAMPLE}.markdup.bam"
    OUTPUT_PREFIX="${PEAKS_DIR}/macs2/${SAMPLE}"
    
    if [[ ! -f "${TREATMENT_BAM}" ]]; then
        echo "   WARNING: ${TREATMENT_BAM} not found, skipping..."
        continue
    fi
    
    # MACS2 parameters optimized for DAP-seq
    # Following O'Malley et al. (2016) methods
    macs2 callpeak \
        -t ${TREATMENT_BAM} \
        -c ${CONTROL_MARKDUP} \
        -f BAM \
        -g 1.35e8 \
        -n ${SAMPLE} \
        --outdir ${PEAKS_DIR}/macs2 \
        -q 0.05 \
        --keep-dup all \
        --nomodel \
        --extsize 200 \
        --shift -100 \
        -B \
        --SPMR \
        2>&1 | tee ${LOG_DIR}/${SAMPLE}_macs2.log
    
    # Check if peak calling succeeded
    if [[ -f "${OUTPUT_PREFIX}_peaks.narrowPeak" ]]; then
        N_PEAKS=$(wc -l < "${OUTPUT_PREFIX}_peaks.narrowPeak")
        echo "   ${SAMPLE}: ${N_PEAKS} peaks called"
        
        # Copy summit file for easier access
        cp "${OUTPUT_PREFIX}_summits.bed" ${PEAKS_DIR}/summits/
        
        # Convert bedGraph to BigWig for visualization (optional)
        # Requires chromosome sizes file
        # bedGraphToBigWig ${OUTPUT_PREFIX}_treat_pileup.bdg TAIR10.chrom.sizes ${PEAKS_DIR}/bigwig/${SAMPLE}.bw
        
    else
        echo "   WARNING: Peak calling failed for ${SAMPLE}"
    fi
done

echo ""
echo " Peak calling complete"

#===============================================================================
# STEP 4: Peak Statistics and Quality Control
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 4] Peak statistics"
echo "=========================================="

PEAK_SUMMARY="${PEAKS_DIR}/peak_summary.txt"
echo -e "Sample\tTotal_Peaks\tStrong_Peaks\tMean_FoldEnrich\tMean_qValue\tFRiP" > ${PEAK_SUMMARY}

for SAMPLE in "${TREATMENTS[@]}"; do
    PEAK_FILE="${PEAKS_DIR}/macs2/${SAMPLE}_peaks.narrowPeak"
    
    if [[ ! -f "${PEAK_FILE}" ]]; then
        continue
    fi
    
    # Count peaks
    TOTAL_PEAKS=$(wc -l < ${PEAK_FILE})
    
    # Count strong peaks (fold enrichment > 10, q-value < 1e-10)
    STRONG_PEAKS=$(awk '$7 > 10 && $9 > 10' ${PEAK_FILE} | wc -l)
    
    # Calculate mean fold enrichment
    MEAN_FOLD=$(awk '{sum+=$7; count++} END {printf "%.2f", sum/count}' ${PEAK_FILE})
    
    # Calculate mean q-value
    MEAN_QVAL=$(awk '{sum+=$9; count++} END {printf "%.2f", sum/count}' ${PEAK_FILE})
    
    # Calculate FRiP (Fraction of Reads in Peaks)
    TREATMENT_BAM="${PEAKS_DIR}/markdup/${SAMPLE}.markdup.bam"
    TOTAL_READS=$(samtools view -c -F 260 ${TREATMENT_BAM})
    READS_IN_PEAKS=$(bedtools intersect -a ${TREATMENT_BAM} -b ${PEAK_FILE} -u -f 0.5 | samtools view -c)
    
    if [[ ${TOTAL_READS} -gt 0 ]]; then
        FRIP=$(awk "BEGIN {printf \"%.4f\", ${READS_IN_PEAKS}/${TOTAL_READS}}")
    else
        FRIP="0.0000"
    fi
    
    echo -e "${SAMPLE}\t${TOTAL_PEAKS}\t${STRONG_PEAKS}\t${MEAN_FOLD}\t${MEAN_QVAL}\t${FRIP}" >> ${PEAK_SUMMARY}
    
    echo "${SAMPLE}:"
    echo "  Total peaks: ${TOTAL_PEAKS}"
    echo "  Strong peaks (>10-fold, q<1e-10): ${STRONG_PEAKS}"
    echo "  Mean fold enrichment: ${MEAN_FOLD}×"
    echo "  FRiP: ${FRIP} ($(awk "BEGIN {printf \"%.1f\", ${FRIP}*100}")%)"
    echo ""
done

echo "Peak Summary Table:"
column -t ${PEAK_SUMMARY}

#===============================================================================
# STEP 5: Compare ARF5 Replicates
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 5] ARF5 Replicate Comparison"
echo "=========================================="

REP1="${PEAKS_DIR}/macs2/GSM1925826_ARF5_rep1_peaks.narrowPeak"
REP2="${PEAKS_DIR}/macs2/GSM1925827_ARF5_rep2_peaks.narrowPeak"

if [[ -f "${REP1}" ]] && [[ -f "${REP2}" ]]; then
    echo "Comparing ARF5 replicates..."
    
    # Find overlapping peaks (50% reciprocal overlap)
    OVERLAP="${PEAKS_DIR}/ARF5_replicate_overlap.bed"
    bedtools intersect -a ${REP1} -b ${REP2} -f 0.5 -r > ${OVERLAP}
    
    N_REP1=$(wc -l < ${REP1})
    N_REP2=$(wc -l < ${REP2})
    N_OVERLAP=$(wc -l < ${OVERLAP})
    
    OVERLAP_PERCENT=$(awk "BEGIN {printf \"%.1f\", (${N_OVERLAP}/${N_REP1})*100}")
    
    echo "  Rep1 peaks: ${N_REP1}"
    echo "  Rep2 peaks: ${N_REP2}"
    echo "  Overlapping peaks: ${N_OVERLAP} (${OVERLAP_PERCENT}%)"
    
    # Calculate correlation between replicates using bedtools coverage
    echo ""
    echo "  Computing signal correlation..."
    
    # Create union peak set
    cat ${REP1} ${REP2} | sort -k1,1 -k2,2n | bedtools merge > ${PEAKS_DIR}/ARF5_union_peaks.bed
    
    # Get read counts in union peaks for each replicate
    REP1_BAM="${PEAKS_DIR}/markdup/GSM1925826_ARF5_rep1.markdup.bam"
    REP2_BAM="${PEAKS_DIR}/markdup/GSM1925827_ARF5_rep2.markdup.bam"
    
    bedtools coverage -a ${PEAKS_DIR}/ARF5_union_peaks.bed -b ${REP1_BAM} -counts > ${PEAKS_DIR}/ARF5_rep1_counts.bed
    bedtools coverage -a ${PEAKS_DIR}/ARF5_union_peaks.bed -b ${REP2_BAM} -counts > ${PEAKS_DIR}/ARF5_rep2_counts.bed
    
    # Calculate Pearson correlation (requires R or Python, simplified here)
    echo "  Signal correlation files generated:"
    echo "    ${PEAKS_DIR}/ARF5_rep1_counts.bed"
    echo "    ${PEAKS_DIR}/ARF5_rep2_counts.bed"
    echo "  (Use R or Python to calculate Pearson r)"
    
else
    echo "One or both ARF5 replicates not found, skipping comparison"
fi

#===============================================================================
# STEP 6: Generate IGV-compatible files
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 6] Preparing files for IGV"
echo "=========================================="

echo "Sorting and indexing peak files for IGV..."

for PEAK_FILE in ${PEAKS_DIR}/macs2/*_peaks.narrowPeak; do
    SAMPLE=$(basename ${PEAK_FILE} _peaks.narrowPeak)
    
    # Sort and compress
    sort -k1,1 -k2,2n ${PEAK_FILE} | bgzip -c > ${PEAKS_DIR}/macs2/${SAMPLE}_peaks.narrowPeak.gz
    
    # Index with tabix
    tabix -p bed ${PEAKS_DIR}/macs2/${SAMPLE}_peaks.narrowPeak.gz
    
    echo "   ${SAMPLE}"
done

echo ""
echo " Peak files ready for IGV"

#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "MACS2 Pipeline Complete!"
echo "Finished: $(date)"
echo "=========================================="
echo ""
echo "Output files:"
echo "  Marked BAMs:     ${PEAKS_DIR}/markdup/"
echo "  Peak files:      ${PEAKS_DIR}/macs2/"
echo "  Peak summits:    ${PEAKS_DIR}/summits/"
echo "  Statistics:      ${PEAKS_DIR}/peak_summary.txt"
echo "  Duplication:     ${PEAKS_DIR}/markdup/duplication_summary.txt"
echo ""
echo "Key results:"
cat ${PEAK_SUMMARY}
echo ""
echo "Log saved to: ${LOGFILE}"