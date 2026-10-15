#!/bin/bash
#===============================================================================
# DAP-seq QC, Trimming, and Alignment Pipeline
# Author: Pierce Taylor
# Date: December 8, 2025
# Description: Quality control, adapter trimming, and Bowtie2 alignment
#              Following O'Malley et al. (2016) pipeline
#===============================================================================

set -e
set -u
set -o pipefail

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="m7_project"
RAW_DIR="${PROJECT_DIR}/data/raw"
TRIMMED_DIR="${PROJECT_DIR}/data/trimmed"
QC_DIR="${PROJECT_DIR}/results/qc"
ALIGN_DIR="${PROJECT_DIR}/results/alignment"
LOG_DIR="${PROJECT_DIR}/logs"
REF_DIR="${PROJECT_DIR}/references"
GENOME_DIR="${REF_DIR}/genome"
INDEX_DIR="${REF_DIR}/bowtie2_index"

ENV_NAME="module_7_dapseq"
GENOME_NAME="TAIR10"
N_THREADS=8  # Adjust based on available CPU cores

# Create log file
LOGFILE="${LOG_DIR}/pipeline_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "${LOGFILE}")
exec 2>&1

echo "=========================================="
echo "DAP-seq Analysis Pipeline"
echo "Started: $(date)"
echo "Threads: ${N_THREADS}"
echo "=========================================="

#===============================================================================
# Environment Check
#===============================================================================
echo ""
echo "[STEP 0] Checking environment..."

ml mamba

source activate module_7_dapseq

# Verify required tools
REQUIRED_TOOLS=(fastqc fastp bowtie2 samtools multiqc pigz)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: $tool not found"
        exit 1
    fi
    echo "   $tool"
done

# Check for raw data
if ! ls ${RAW_DIR}/*.fastq.gz 1> /dev/null 2>&1; then
    echo "ERROR: No FASTQ files found in ${RAW_DIR}"
    echo "Please run download script first"
    exit 1
fi

N_SAMPLES=$(ls -1 ${RAW_DIR}/*.fastq.gz | wc -l)
echo "   Found ${N_SAMPLES} FASTQ files"

#===============================================================================
# STEP 1: Initial Quality Control with FastQC
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 1] Running FastQC on raw reads"
echo "=========================================="

mkdir -p ${QC_DIR}/fastqc_raw

echo "Running FastQC on ${N_SAMPLES} samples..."
fastqc ${RAW_DIR}/*.fastq.gz \
    --outdir ${QC_DIR}/fastqc_raw \
    --threads ${N_THREADS} \
    --quiet

echo " FastQC complete for raw reads"

#===============================================================================
# STEP 2: Adapter Trimming and Quality Filtering with fastp
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 2] Trimming adapters with fastp"
echo "=========================================="

mkdir -p ${QC_DIR}/fastp

# Process each sample
for FASTQ in ${RAW_DIR}/*.fastq.gz; do
    SAMPLE=$(basename ${FASTQ} .fastq.gz)
    
    echo ""
    echo "Processing: ${SAMPLE}"
    
    fastp \
        --in1 ${FASTQ} \
        --out1 ${TRIMMED_DIR}/${SAMPLE}.trimmed.fastq.gz \
        --json ${QC_DIR}/fastp/${SAMPLE}.json \
        --html ${QC_DIR}/fastp/${SAMPLE}.html \
        --thread ${N_THREADS} \
        --detect_adapter_for_pe \
        --cut_front \
        --cut_tail \
        --cut_window_size 4 \
        --cut_mean_quality 20 \
        --qualified_quality_phred 20 \
        --unqualified_percent_limit 30 \
        --n_base_limit 5 \
        --length_required 36 \
        --compression 6 \
        2>&1 | grep -E "^(Read1|Filtering|duplication)"
    
    echo "   ${SAMPLE} trimmed"
done

echo ""
echo " All samples trimmed"

#===============================================================================
# STEP 3: Post-trimming Quality Control
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 3] Running FastQC on trimmed reads"
echo "=========================================="

mkdir -p ${QC_DIR}/fastqc_trimmed

fastqc ${TRIMMED_DIR}/*.trimmed.fastq.gz \
    --outdir ${QC_DIR}/fastqc_trimmed \
    --threads ${N_THREADS} \
    --quiet

echo " FastQC complete for trimmed reads"

#===============================================================================
# STEP 4: Check/Build Bowtie2 Index
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 4] Checking Bowtie2 index"
echo "=========================================="

INDEX_BASE="${INDEX_DIR}/${GENOME_NAME}"

# Check if index exists
if [[ -f "${INDEX_BASE}.1.bt2" ]]; then
    echo " Bowtie2 index found: ${INDEX_BASE}"
else
    echo "Building Bowtie2 index..."
    
    wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-62/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz -O m7_project/references/genome/TAIR10.fa.gz

    gunzip $GENOME_DIR/TAIR10.fa.gz
    
    # Check for genome FASTA
    GENOME_FA="${GENOME_DIR}/${GENOME_NAME}.fa"
    if [[ ! -f "${GENOME_FA}" ]]; then
        echo "ERROR: Genome FASTA not found: ${GENOME_FA}"
        echo ""
        echo "Please download TAIR10 genome:"
        echo "  wget https://ftp.ensemblgenomes.ebi.ac.uk/pub/plants/release-62/fasta/arabidopsis_thaliana/dna/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa.gz -O ${GENOME_FA}"
        exit 1
    fi
    
    echo "Building index from ${GENOME_FA}..."
    bowtie2-build \
        --threads ${N_THREADS} \
        ${GENOME_FA} \
        ${INDEX_BASE}
    
    echo " Bowtie2 index built"
fi

#===============================================================================
# STEP 5: Alignment with Bowtie2
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 5] Aligning reads with Bowtie2"
echo "=========================================="

mkdir -p ${ALIGN_DIR}/bam
mkdir -p ${ALIGN_DIR}/stats

# Process each trimmed sample
for FASTQ in ${TRIMMED_DIR}/*.trimmed.fastq.gz; do
    SAMPLE=$(basename ${FASTQ} .trimmed.fastq.gz)
    BAM="${ALIGN_DIR}/bam/${SAMPLE}.bam"
    
    echo ""
    echo "Aligning: ${SAMPLE}"
    
    # Run Bowtie2 alignment
    # Parameters optimized for DAP-seq (single-end, genomic DNA)
    bowtie2 \
        -x ${INDEX_BASE} \
        -U ${FASTQ} \
        --threads ${N_THREADS} \
        --very-sensitive \
        --no-unal \
        -k 1 \
        --no-mixed \
        --no-discordant \
        2> ${ALIGN_DIR}/stats/${SAMPLE}.bowtie2.log \
    | samtools view -bS -@ 4 - \
    | samtools sort -@ 4 -o ${BAM} -
    
    # Index BAM
    samtools index -@ 4 ${BAM}
    
    # Generate flagstat
    samtools flagstat -@ 4 ${BAM} > ${ALIGN_DIR}/stats/${SAMPLE}.flagstat.txt
    
    # Get alignment rate from log
    ALIGN_RATE=$(grep "overall alignment rate" ${ALIGN_DIR}/stats/${SAMPLE}.bowtie2.log || echo "N/A")
    echo "  ${ALIGN_RATE}"
    echo "   ${SAMPLE} aligned and sorted"
done

echo ""
echo " All samples aligned"

#===============================================================================
# STEP 6: Generate Alignment Statistics
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 6] Generating alignment statistics"
echo "=========================================="

# Create summary table
SUMMARY="${ALIGN_DIR}/alignment_summary.txt"
echo -e "Sample\tTotal_Reads\tMapped_Reads\tMapped_Percent\tDuplication_Rate" > ${SUMMARY}

for BAM in ${ALIGN_DIR}/bam/*.bam; do
    SAMPLE=$(basename ${BAM} .bam)
    
    # Extract stats from flagstat
    TOTAL=$(grep "in total" ${ALIGN_DIR}/stats/${SAMPLE}.flagstat.txt | awk '{print $1}')
    MAPPED=$(grep "mapped (" ${ALIGN_DIR}/stats/${SAMPLE}.flagstat.txt | head -1 | awk '{print $1}')
    
    # Calculate percentage
    if [[ ${TOTAL} -gt 0 ]]; then
        PERCENT=$(awk "BEGIN {printf \"%.2f\", (${MAPPED}/${TOTAL})*100}")
    else
        PERCENT="0.00"
    fi
    
    # Get duplication rate from fastp
    DUP_RATE=$(grep "duplication rate" ${QC_DIR}/fastp/${SAMPLE}.json | grep -oP '\d+\.\d+' | head -1 || echo "N/A")
    
    echo -e "${SAMPLE}\t${TOTAL}\t${MAPPED}\t${PERCENT}\t${DUP_RATE}" >> ${SUMMARY}
done

echo ""
echo "Alignment Summary:"
column -t ${SUMMARY}

#===============================================================================
# STEP 7: MultiQC Report
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 7] Generating MultiQC report"
echo "=========================================="

multiqc ${QC_DIR} ${ALIGN_DIR}/stats \
    --outdir ${QC_DIR}/multiqc \
    --filename dapseq_multiqc_report \
    --force \
    --quiet

echo " MultiQC report generated: ${QC_DIR}/multiqc/dapseq_multiqc_report.html"

#===============================================================================
# STEP 8: Clean up temporary files (optional)
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 8] Cleanup"
echo "=========================================="

# Calculate disk usage
echo "Disk usage summary:"
echo "  Raw reads:     $(du -sh ${RAW_DIR} | cut -f1)"
echo "  Trimmed reads: $(du -sh ${TRIMMED_DIR} | cut -f1)"
echo "  BAM files:     $(du -sh ${ALIGN_DIR}/bam | cut -f1)"
echo "  Total:         $(du -sh ${PROJECT_DIR} | cut -f1)"

# Optional: remove trimmed FASTQs after alignment (uncomment to enable)
# echo ""
# read -p "Remove trimmed FASTQ files to save space? (y/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     rm ${TRIMMED_DIR}/*.trimmed.fastq.gz
#     echo " Trimmed FASTQ files removed"
# fi

#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "Pipeline Complete!"
echo "Finished: $(date)"
echo "=========================================="
echo ""
echo "Output files:"
echo "  Raw QC:       ${QC_DIR}/fastqc_raw/"
echo "  Trimmed QC:   ${QC_DIR}/fastqc_trimmed/"
echo "  Fastp stats:  ${QC_DIR}/fastp/"
echo "  BAM files:    ${ALIGN_DIR}/bam/"
echo "  Stats:        ${ALIGN_DIR}/stats/"
echo "  MultiQC:      ${QC_DIR}/multiqc/dapseq_multiqc_report.html"
echo "  Summary:      ${ALIGN_DIR}/alignment_summary.txt"
echo ""
echo "Log saved to: ${LOGFILE}"