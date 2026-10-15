#!/bin/bash
#===============================================================================
# STAR RNA-seq Pipeline - Script 1
# Data Download, Quality Control, Alignment, and Quantification
# Description: Downloads SRA data, runs fastp QC/trimming, performs STAR
#              genome alignment, generates gene counts with featureCounts
#===============================================================================

set -e
set -u
set -o pipefail

#===============================================================================
# Configuration
#===============================================================================
PROJECT_DIR="star_rnaseq"
RAW_DIR="${PROJECT_DIR}/data/raw"
TRIMMED_DIR="${PROJECT_DIR}/data/trimmed"
ALIGN_DIR="${PROJECT_DIR}/results/alignment"
BAM_DIR="${ALIGN_DIR}/bam"
COUNTS_DIR="${PROJECT_DIR}/results/counts"
QC_DIR="${PROJECT_DIR}/results/qc"
TRACKS_DIR="${PROJECT_DIR}/results/tracks"
REF_DIR="${PROJECT_DIR}/references"
LOG_DIR="${PROJECT_DIR}/logs"
SAMPLE_SHEET="${PROJECT_DIR}/samples.csv"

ENV_NAME="module_5_STAR"
N_THREADS=16  # STAR is memory-intensive, adjust for your cluster

# Reference files (YOU MUST SET THESE)
GENOME_FASTA="${REF_DIR}/genome/genome.fa"
ANNOTATION_GTF="${REF_DIR}/annotation/annotation.gtf"
STAR_INDEX="${REF_DIR}/star_index"

# Create log file
LOGFILE="${LOG_DIR}/pipeline_1_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "${LOGFILE}")
exec 2>&1

echo "=========================================="
echo "STAR RNA-seq Pipeline - Part 1"
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
REQUIRED_TOOLS=(fasterq-dump fastp STAR samtools featureCounts pigz)
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "ERROR: $tool not found"
        exit 1
    fi
    echo "  $tool found"
done

# Check for sample sheet
if [[ ! -f "${SAMPLE_SHEET}" ]]; then
    echo "ERROR: Sample sheet not found: ${SAMPLE_SHEET}"
    echo "Please create samples.csv with SRR accessions"
    exit 1
fi

N_SAMPLES=$(tail -n +2 ${SAMPLE_SHEET} | wc -l)
echo "  Found ${N_SAMPLES} samples in ${SAMPLE_SHEET}"

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
    if [[ -f "${RAW_DIR}/${sample_id}_1.fastq.gz" ]] || [[ -f "${RAW_DIR}/${sample_id}.fastq.gz" ]]; then
        echo "  ${sample_id} already downloaded, skipping"
        continue
    fi
    
    # Download with fasterq-dump
    echo "  Downloading ${srr}..."
    cd ${RAW_DIR}
    
    fasterq-dump ${srr} \
        --outdir ${RAW_DIR} \
        --split-files \
        --threads ${N_THREADS} \
        --progress
    
    # Compress FASTQ files
    echo "  Compressing FASTQ files..."
    
    # Check if paired-end or single-end
    if [[ -f "${RAW_DIR}/${srr}_2.fastq" ]]; then
        # Paired-end
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}_1.fastq
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}_2.fastq
        
        # Rename to sample IDs
        mv ${RAW_DIR}/${srr}_1.fastq.gz ${RAW_DIR}/${sample_id}_1.fastq.gz
        mv ${RAW_DIR}/${srr}_2.fastq.gz ${RAW_DIR}/${sample_id}_2.fastq.gz
        
        echo "  Downloaded paired-end: ${sample_id}_1.fastq.gz, ${sample_id}_2.fastq.gz"
    else
        # Single-end
        pigz -p ${N_THREADS} ${RAW_DIR}/${srr}.fastq
        mv ${RAW_DIR}/${srr}.fastq.gz ${RAW_DIR}/${sample_id}.fastq.gz
        
        echo "  Downloaded single-end: ${sample_id}.fastq.gz"
    fi
    
    cd -
done

echo ""
echo "All samples downloaded"

#===============================================================================
# STEP 2: Quality Control and Trimming with fastp
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 2] Quality control and trimming"
echo "=========================================="

mkdir -p ${QC_DIR}/fastp

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
        echo "  Running fastp (paired-end)..."
        
        fastp \
            --in1 ${R1} \
            --in2 ${R2} \
            --out1 ${TRIMMED_DIR}/${sample_id}_1.trim.fastq.gz \
            --out2 ${TRIMMED_DIR}/${sample_id}_2.trim.fastq.gz \
            --json ${QC_DIR}/fastp/${sample_id}_fastp.json \
            --html ${QC_DIR}/fastp/${sample_id}_fastp.html \
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
        
        echo "  Trimmed: ${sample_id}_1.trim.fastq.gz, ${sample_id}_2.trim.fastq.gz"
        
    elif [[ -f "${SE}" ]]; then
        # Single-end
        echo "  Running fastp (single-end)..."
        
        fastp \
            --in1 ${SE} \
            --out1 ${TRIMMED_DIR}/${sample_id}.trim.fastq.gz \
            --json ${QC_DIR}/fastp/${sample_id}_fastp.json \
            --html ${QC_DIR}/fastp/${sample_id}_fastp.html \
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
        
        echo "  Trimmed: ${sample_id}.trim.fastq.gz"
    else
        echo "  WARNING: No raw FASTQ found for ${sample_id}, skipping"
    fi
done

echo ""
echo "Quality control complete"

#===============================================================================
# STEP 3: Build STAR Genome Index (one-time)
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 3] Building STAR genome index"
echo "=========================================="

# Check if genome and annotation exist
if [[ ! -f "${GENOME_FASTA}" ]]; then
    echo ""
    echo "ERROR: Genome file not found: ${GENOME_FASTA}"
    echo ""
    echo "Please download a reference genome and place it at:"
    echo "  ${GENOME_FASTA}"
    echo ""
    echo "Download sources:"
    echo "  Ensembl: http://ftp.ensembl.org/"
    echo "  GENCODE: https://www.gencodegenes.org/"
    echo "  NCBI: https://ftp.ncbi.nlm.nih.gov/genomes/"
    echo ""
    exit 1
fi

if [[ ! -f "${ANNOTATION_GTF}" ]]; then
    echo ""
    echo "ERROR: Annotation file not found: ${ANNOTATION_GTF}"
    echo ""
    echo "Please download a GTF annotation and place it at:"
    echo "  ${ANNOTATION_GTF}"
    echo ""
    echo "Note: Should match the same version as your genome"
    echo ""
    exit 1
fi

# Check if index already exists
if [[ -d "${STAR_INDEX}" && -f "${STAR_INDEX}/SA" ]]; then
    echo "  STAR index already exists: ${STAR_INDEX}"
else
    echo "  Building STAR index (this may take 30-60 minutes)..."
    echo "  This requires approximately 30-40 GB of RAM"
    
    # Determine optimal sjdbOverhang (read length - 1)
    # Common value: 100 for 100bp reads, 150 for 150bp reads
    # Using 100 as a safe default
    SJDB_OVERHANG=100
    
    STAR \
        --runMode genomeGenerate \
        --runThreadN ${N_THREADS} \
        --genomeDir ${STAR_INDEX} \
        --genomeFastaFiles ${GENOME_FASTA} \
        --sjdbGTFfile ${ANNOTATION_GTF} \
        --sjdbOverhang ${SJDB_OVERHANG}
    
    echo "  STAR index built successfully"
fi

#===============================================================================
# STEP 4: STAR Alignment
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 4] STAR genome alignment"
echo "=========================================="

# Process each sample
tail -n +2 ${SAMPLE_SHEET} | while IFS=',' read -r sample_id condition replicate srr; do
    
    echo ""
    echo "Aligning: ${sample_id}"
    
    OUTPUT_PREFIX="${BAM_DIR}/${sample_id}_"
    
    # Check if already aligned
    if [[ -f "${BAM_DIR}/${sample_id}_Aligned.sortedByCoord.out.bam" ]]; then
        echo "  ${sample_id} already aligned, skipping"
        continue
    fi
    
    R1="${TRIMMED_DIR}/${sample_id}_1.trim.fastq.gz"
    R2="${TRIMMED_DIR}/${sample_id}_2.trim.fastq.gz"
    SE="${TRIMMED_DIR}/${sample_id}.trim.fastq.gz"
    
    # Run STAR alignment
    if [[ -f "${R1}" && -f "${R2}" ]]; then
        # Paired-end
        echo "  Running STAR (paired-end)..."
        
        STAR \
            --runThreadN ${N_THREADS} \
            --genomeDir ${STAR_INDEX} \
            --readFilesIn ${R1} ${R2} \
            --readFilesCommand zcat \
            --outFileNamePrefix ${OUTPUT_PREFIX} \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMunmapped Within \
            --outSAMattributes Standard \
            --quantMode GeneCounts \
            --twopassMode Basic
        
    elif [[ -f "${SE}" ]]; then
        # Single-end
        echo "  Running STAR (single-end)..."
        
        STAR \
            --runThreadN ${N_THREADS} \
            --genomeDir ${STAR_INDEX} \
            --readFilesIn ${SE} \
            --readFilesCommand zcat \
            --outFileNamePrefix ${OUTPUT_PREFIX} \
            --outSAMtype BAM SortedByCoordinate \
            --outSAMunmapped Within \
            --outSAMattributes Standard \
            --quantMode GeneCounts \
            --twopassMode Basic
    else
        echo "  WARNING: No trimmed FASTQ found for ${sample_id}, skipping"
        continue
    fi
    
    # Index BAM file
    echo "  Indexing BAM file..."
    samtools index -@ ${N_THREADS} ${BAM_DIR}/${sample_id}_Aligned.sortedByCoord.out.bam
    
    # Extract mapping statistics
    UNIQUE_MAPPED=$(grep "Uniquely mapped reads number" ${BAM_DIR}/${sample_id}_Log.final.out | awk '{print $NF}')
    TOTAL_READS=$(grep "Number of input reads" ${BAM_DIR}/${sample_id}_Log.final.out | awk '{print $NF}')
    PERCENT_MAPPED=$(grep "Uniquely mapped reads %" ${BAM_DIR}/${sample_id}_Log.final.out | awk '{print $NF}')
    
    echo "  Aligned: ${sample_id} (${PERCENT_MAPPED} uniquely mapped)"
done

echo ""
echo "All samples aligned"

#===============================================================================
# STEP 5: Gene-Level Quantification with featureCounts
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 5] Gene quantification with featureCounts"
echo "=========================================="

# Collect all BAM files
BAM_FILES=$(ls ${BAM_DIR}/*_Aligned.sortedByCoord.out.bam 2>/dev/null | tr '\n' ' ')

if [[ -z "${BAM_FILES}" ]]; then
    echo "ERROR: No BAM files found for quantification"
    exit 1
fi

echo "  Running featureCounts on all samples..."

# Run featureCounts
# For paired-end data, add -p flag
# For strand-specific data, adjust -s flag (0=unstranded, 1=stranded, 2=reverse-stranded)
featureCounts \
    -T ${N_THREADS} \
    -a ${ANNOTATION_GTF} \
    -o ${COUNTS_DIR}/gene_counts.txt \
    -g gene_id \
    -t exon \
    -s 0 \
    --primary \
    --verbose \
    ${BAM_FILES}

echo "  Gene counts saved: ${COUNTS_DIR}/gene_counts.txt"

# Create a clean counts matrix (remove extra columns)
cut -f1,7- ${COUNTS_DIR}/gene_counts.txt > ${COUNTS_DIR}/gene_counts_matrix.txt

echo "  Clean matrix saved: ${COUNTS_DIR}/gene_counts_matrix.txt"

#===============================================================================
# STEP 6: Generate Coverage Tracks for Genome Browser
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 6] Generating genome browser tracks"
echo "=========================================="

# Process each BAM file
for BAM in ${BAM_DIR}/*_Aligned.sortedByCoord.out.bam; do
    SAMPLE=$(basename ${BAM} _Aligned.sortedByCoord.out.bam)
    
    echo "  Creating BigWig for ${SAMPLE}..."
    
    # Generate normalized BigWig (RPKM)
    bamCoverage \
        --bam ${BAM} \
        --outFileName ${TRACKS_DIR}/${SAMPLE}.bw \
        --binSize 10 \
        --normalizeUsing RPKM \
        --numberOfProcessors ${N_THREADS}
    
    echo "    ${SAMPLE}.bw created"
done

echo "  All BigWig tracks generated"

#===============================================================================
# STEP 7: Quality Control with MultiQC
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 7] Generating MultiQC report"
echo "=========================================="

# Run MultiQC on all outputs
multiqc ${QC_DIR}/fastp ${BAM_DIR} ${COUNTS_DIR} \
    --outdir ${QC_DIR}/multiqc \
    --filename star_rnaseq_multiqc_report \
    --force \
    --verbose

echo "  MultiQC report generated: ${QC_DIR}/multiqc/star_rnaseq_multiqc_report.html"

#===============================================================================
# STEP 8: Generate Summary Statistics
#===============================================================================
echo ""
echo "=========================================="
echo "[STEP 8] Generating summary statistics"
echo "=========================================="

SUMMARY="${ALIGN_DIR}/alignment_summary.txt"
echo -e "Sample\tTotal_Reads\tUniquely_Mapped\tPercent_Mapped\tMulti_Mapped" > ${SUMMARY}

for LOG in ${BAM_DIR}/*_Log.final.out; do
    SAMPLE=$(basename ${LOG} _Log.final.out)
    
    TOTAL=$(grep "Number of input reads" ${LOG} | awk '{print $NF}')
    UNIQUE=$(grep "Uniquely mapped reads number" ${LOG} | awk '{print $NF}')
    PERCENT=$(grep "Uniquely mapped reads %" ${LOG} | awk '{print $NF}')
    MULTI=$(grep "Number of reads mapped to multiple loci" ${LOG} | awk '{print $NF}')
    
    echo -e "${SAMPLE}\t${TOTAL}\t${UNIQUE}\t${PERCENT}\t${MULTI}" >> ${SUMMARY}
done

echo ""
echo "Alignment Summary:"
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
echo "  BAM files:     ${BAM_DIR}/"
echo "  Gene counts:   ${COUNTS_DIR}/gene_counts_matrix.txt"
echo "  BigWig tracks: ${TRACKS_DIR}/"
echo "  MultiQC:       ${QC_DIR}/multiqc/star_rnaseq_multiqc_report.html"
echo "  Summary:       ${SUMMARY}"
echo ""
echo "Next step:"
echo "  Use gene_counts_matrix.txt for differential expression with DESeq2"
echo ""
echo "Log saved to: ${LOGFILE}"