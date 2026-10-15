#!/bin/bash
#===============================================================================
# Salmon RNA-seq Pipeline - Script 1
# Data Download, Quality Control, and Salmon Quantification
# Description: Downloads SRA data, runs fastp QC/trimming, performs Salmon
#              pseudo-alignment and quantification
#===============================================================================

set -e
set -u
set -o pipefail

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="salmon_rnaseq"
RAW_DIR="${PROJECT_DIR}/data/raw"
TRIMMED_DIR="${PROJECT_DIR}/data/trimmed"
SALMON_DIR="${PROJECT_DIR}/results/salmon"
REF_DIR="${PROJECT_DIR}/references"
LOG_DIR="${PROJECT_DIR}/logs"
SAMPLE_SHEET="${PROJECT_DIR}/samples.csv"

ENV_NAME="Salmon_Pipeline"
N_THREADS=8  # Adjust based on available cores

# Reference files (YOU MUST SET THESE!)
TRANSCRIPTOME="${REF_DIR}/transcriptome.fa"  # or transcripts.fa.gz
SALMON_INDEX="${REF_DIR}/salmon_index"

# Create log file
LOGFILE="${LOG_DIR}/pipeline_1_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "${LOGFILE}")
exec 2>&1

echo "=========================================="
echo "Salmon RNA-seq Pipeline - Part 1"
echo "Started: $(date)"
echo "Threads: ${N_THREADS}"
echo "=========================================="

#===============================================================================
# Environment Check
#===============================================================================
echo ""
echo "[STEP 0] Checking environment..."

# Load mamba/conda
module load mamba 2>/dev/null || true

# Activate environment
source activate ${ENV_NAME} || conda activate ${ENV_NAME}

# Verify required tools
REQUIRED_TOOLS=(fasterq-dump fastp salmon pigz)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: $tool not found"
        exit 1
    fi
    echo "   $tool"
done

# Check for sample sheet
if [[ ! -f "${SAMPLE_SHEET}" ]]; then
    echo "ERROR: Sample sheet not found: ${SAMPLE_SHEET}"
    echo "Please create samples.csv with SRR accessions"
    exit 1
fi

N_SAMPLES=$(tail -n +2 ${SAMPLE_SHEET} | wc -l)
echo "   Found ${N_SAMPLES} samples in ${SAMPLE_SHEET}"

#===============================================================================
# STEP 1: Download Raw Data from SRA
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 1] Downloading RNA-seq data from SRA"
echo "=========================================="

# Read sample sheet (skip header)
tail -n +2 ${SAMPLE_SHEET} | while IFS=',' read -r sample_id condition replicate srr; do
    
    echo ""
    echo "Processing: ${sample_id} (${srr})"
    
    # Check if already downloaded
    if [[ -f "${RAW_DIR}/${sample_id}_1.fastq.gz" ]]; then
        echo "   ${sample_id} already downloaded, skipping"
        continue
    fi
    
    # Download with fasterq-dump (paired-end aware)
    echo "  → Downloading ${srr}..."
    cd ${RAW_DIR}
    
    fasterq-dump ${srr} \
        --outdir ${RAW_DIR} \
        --split-files \
        --threads ${N_THREADS} \
        --progress
    
    # Compress FASTQ files
    echo "  → Compressing FASTQ files..."
    
    # Check if paired-end or single-end
    if [[ -f "${RAW_DIR}/${srr}_2.fastq" ]]; then
        # Paired-end
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}_1.fastq
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}_2.fastq
        
        # Rename to sample IDs
        mv ${RAW_DIR}/${srr}_1.fastq.gz ${RAW_DIR}/${sample_id}_1.fastq.gz
        mv ${RAW_DIR}/${srr}_2.fastq.gz ${RAW_DIR}/${sample_id}_2.fastq.gz
        
        echo "   Downloaded paired-end: ${sample_id}_1.fastq.gz, ${sample_id}_2.fastq.gz"
    else
        # Single-end
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}.fastq
        mv ${RAW_DIR}/${srr}.fastq.gz ${RAW_DIR}/${sample_id}.fastq.gz
        
        echo "   Downloaded single-end: ${sample_id}.fastq.gz"
    fi
    
    cd -
done

echo ""
echo " All samples downloaded"

#===============================================================================
# STEP 2: Quality Control and Trimming with fastp
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 2] Quality control and trimming"
echo "=========================================="

# Process each sample
tail -n +2 ${SAMPLE_SHEET} | while IFS=',' read -r sample_id condition replicate srr; do
    
    echo ""
    echo "Processing: ${sample_id}"
    
    R1="${RAW_DIR}/${sample_id}_1.fastq.gz"
    R2="${RAW_DIR}/${sample_id}_2.fastq.gz"
    SE="${RAW_DIR}/${sample_id}.fastq.gz"
    
    # Check if paired-end or single-end
    if [[ -f "${R1}" && -f "${R2}" ]]; then
        # Paired-end
        echo "  → Running fastp (paired-end)..."
        
        fastp \
            --in1 ${R1} \
            --in2 ${R2} \
            --out1 ${TRIMMED_DIR}/${sample_id}_1.trim.fastq.gz \
            --out2 ${TRIMMED_DIR}/${sample_id}_2.trim.fastq.gz \
            --json ${TRIMMED_DIR}/${sample_id}_fastp.json \
            --html ${TRIMMED_DIR}/${sample_id}_fastp.html \
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
            --compression 6
        
        echo "   Trimmed: ${sample_id}_1.trim.fastq.gz, ${sample_id}_2.trim.fastq.gz"
        
    elif [[ -f "${SE}" ]]; then
        # Single-end
        echo "  → Running fastp (single-end)..."
        
        fastp \
            --in1 ${SE} \
            --out1 ${TRIMMED_DIR}/${sample_id}.trim.fastq.gz \
            --json ${TRIMMED_DIR}/${sample_id}_fastp.json \
            --html ${TRIMMED_DIR}/${sample_id}_fastp.html \
            --thread ${N_THREADS} \
            --cut_front \
            --cut_tail \
            --cut_window_size 4 \
            --cut_mean_quality 20 \
            --qualified_quality_phred 20 \
            --unqualified_percent_limit 30 \
            --n_base_limit 5 \
            --length_required 36 \
            --compression 6
        
        echo "   Trimmed: ${sample_id}.trim.fastq.gz"
    else
        echo "   WARNING: No raw FASTQ found for ${sample_id}, skipping"
    fi
done

echo ""
echo " Quality control complete"

#===============================================================================
# STEP 3: Build Salmon Index (one-time)
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 3] Building Salmon transcriptome index"
echo "=========================================="

# Check if transcriptome exists
if [[ ! -f "${TRANSCRIPTOME}" ]]; then
    echo ""
    echo "ERROR: Transcriptome file not found: ${TRANSCRIPTOME}"
    echo ""
    echo "Please download a reference transcriptome and place it at:"
    echo "  ${TRANSCRIPTOME}"
    echo ""
    echo "Download sources:"
    echo "  Ensembl: http://ftp.ensembl.org/"
    echo "  GENCODE: https://www.gencodegenes.org/"
    echo "   RefSeq: https://ftp.ncbi.nlm.nih.gov/"
    echo ""
    echo "Example for Arabidopsis:"
    echo "  wget ftp://ftp.ensemblgenomes.org/pub/plants/release-51/fasta/arabidopsis_thaliana/cdna/Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz"
    echo "  gunzip -c Arabidopsis_thaliana.TAIR10.cdna.all.fa.gz > ${TRANSCRIPTOME}"
    echo ""
    exit 1
fi

# Check if index already exists
if [[ -d "${SALMON_INDEX}" && -f "${SALMON_INDEX}/info.json" ]]; then
    echo "   Salmon index already exists: ${SALMON_INDEX}"
else
    echo "  → Building Salmon index (this may take 10-20 minutes)..."
    
    salmon index \
        -t ${TRANSCRIPTOME} \
        -i ${SALMON_INDEX} \
        -k 31 \
        --threads ${N_THREADS}
    
    echo "   Salmon index built successfully"
fi

#===============================================================================
# STEP 4: Salmon Quantification
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 4] Salmon pseudo-alignment and quantification"
echo "=========================================="

# Process each sample
tail -n +2 ${SAMPLE_SHEET} | while IFS=',' read -r sample_id condition replicate srr; do
    
    echo ""
    echo "Quantifying: ${sample_id}"
    
    OUTPUT_DIR="${SALMON_DIR}/${sample_id}"
    
    # Check if already quantified
    if [[ -f "${OUTPUT_DIR}/quant.sf" ]]; then
        echo "   ${sample_id} already quantified, skipping"
        continue
    fi
    
    R1="${TRIMMED_DIR}/${sample_id}_1.trim.fastq.gz"
    R2="${TRIMMED_DIR}/${sample_id}_2.trim.fastq.gz"
    SE="${TRIMMED_DIR}/${sample_id}.trim.fastq.gz"
    
    # Detect library type and run Salmon
    if [[ -f "${R1}" && -f "${R2}" ]]; then
        # Paired-end
        echo "  → Running Salmon (paired-end)..."
        
        salmon quant \
            -i ${SALMON_INDEX} \
            -l A \
            -1 ${R1} \
            -2 ${R2} \
            -o ${OUTPUT_DIR} \
            --threads ${N_THREADS} \
            --validateMappings \
            --gcBias \
            --seqBias \
            --numBootstraps 30
        
    elif [[ -f "${SE}" ]]; then
        # Single-end
        echo "  → Running Salmon (single-end)..."
        
        salmon quant \
            -i ${SALMON_INDEX} \
            -l A \
            -r ${SE} \
            -o ${OUTPUT_DIR} \
            --threads ${N_THREADS} \
            --validateMappings \
            --gcBias \
            --seqBias \
            --numBootstraps 30
    else
        echo "   WARNING: No trimmed FASTQ found for ${sample_id}, skipping"
        continue
    fi
    
    # Extract key statistics
    if [[ -f "${OUTPUT_DIR}/aux_info/meta_info.json" ]]; then
        MAPPING_RATE=$(grep "percent_mapped" ${OUTPUT_DIR}/aux_info/meta_info.json | grep -oP '\d+\.\d+')
        echo "   Quantified: ${sample_id} (${MAPPING_RATE}% mapped)"
    else
        echo "   Quantified: ${sample_id}"
    fi
done

#===============================================================================
# STEP 5: Generate Summary Statistics
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 5] Generating summary statistics"
echo "=========================================="

SUMMARY="${SALMON_DIR}/quantification_summary.txt"
echo -e "Sample\tMapped_Reads\tMapping_Rate\tNum_Transcripts" > ${SUMMARY}

tail -n +2 ${SAMPLE_SHEET} | while IFS=',' read -r sample_id condition replicate srr; do
    
    QUANT_FILE="${SALMON_DIR}/${sample_id}/quant.sf"
    META_FILE="${SALMON_DIR}/${sample_id}/aux_info/meta_info.json"
    
    if [[ -f "${QUANT_FILE}" && -f "${META_FILE}" ]]; then
        NUM_MAPPED=$(grep "num_mapped" ${META_FILE} | grep -oP '\d+')
        PERCENT_MAPPED=$(grep "percent_mapped" ${META_FILE} | grep -oP '\d+\.\d+')
        NUM_TRANSCRIPTS=$(tail -n +2 ${QUANT_FILE} | awk '$5 > 0' | wc -l)
        
        echo -e "${sample_id}\t${NUM_MAPPED}\t${PERCENT_MAPPED}%\t${NUM_TRANSCRIPTS}" >> ${SUMMARY}
    fi
done

echo ""
echo "Quantification Summary:"
column -t ${SUMMARY}

#===============================================================================
# Summary
#===============================================================================
echo ""
echo "=========================================="
echo "Pipeline Part 1 Complete!"
echo "Finished: $(date)"
echo "=========================================="
echo ""
echo "Output files:"
echo "  Raw data:      ${RAW_DIR}/"
echo "  Trimmed data:  ${TRIMMED_DIR}/"
echo "  Salmon quants: ${SALMON_DIR}/"
echo "  Summary:       ${SUMMARY}"
echo ""
echo "Next step:"
echo "  Run: ./2_deseq2_analysis.sh"
echo ""
echo "Log saved to: ${LOGFILE}"