#!/bin/bash
# ============================================================
# Script: download_SRA_samples.sh
# Purpose: Retrieve Arabidopsis root RNA-seq samples from SRA
# Description:
#   Downloads six GEO samples using prefetch and fastq-dump from the McInturf sample set for analyzing cadmium treated vs untreated A. Thaliana in roots via RNA-Seq processing
#   Converts to compressed FASTQ files (.fastq.gz)
# ============================================================

# -----------------------
# 1. Setup directories
# -----------------------
PROJECT_DIR=~/projects/Ath_root_RNAseq
RAW_DIR=$PROJECT_DIR/data/raw
LOG_DIR=$PROJECT_DIR/logs

mkdir -p $RAW_DIR $LOG_DIR

# -----------------------
# 2. Define GSM accessions
# -----------------------
SAMPLES=(
  GSM2090459  # CRN1-1
  GSM2090462  # CRN2-1
  GSM2090465  # CRN3-1
  GSM2090477  # ORN1-1
  GSM2090480  # ORN2-1
  GSM2090483  # ORN3-1
)

# -----------------------
# 3. Retrieve SRA files
# -----------------------
cd $RAW_DIR

echo "Starting SRA data retrieval on $(date)" | tee -a $LOG_DIR/sra_download.log

for GSM in "${SAMPLES[@]}"; do
    echo "---------------------------------------------" | tee -a $LOG_DIR/sra_download.log
    echo "Processing $GSM..." | tee -a $LOG_DIR/sra_download.log

    # Download the SRA file
    prefetch $GSM 2>&1 | tee -a $LOG_DIR/sra_download.log

    # Convert SRA to paired FASTQ files and compress
    fastq-dump --split-files --gzip $GSM 2>&1 | tee -a $LOG_DIR/sra_download.log

    echo "$GSM download and conversion completed." | tee -a $LOG_DIR/sra_download.log
done

echo "All downloads completed on $(date)" | tee -a $LOG_DIR/sra_download.log
echo "FASTQ files saved to: $RAW_DIR"

# -----------------------
# 4. Verify results
# -----------------------
ls -lh $RAW_DIR/*.fastq.gz | tee -a $LOG_DIR/sra_download.log