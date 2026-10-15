#!/bin/bash
#This script will run fastqc, then trimmomatic, then fastqc again. Please look at how the data should be organized. This will work for PE reads, if you are using single end, please modify this script. 

# Example file structure for the pipeline:
#
# project_folder/
# ├── data/                  # Input FASTQ files
# │   ├── sample1_R1.fastq.gz
# │   ├── sample1_R2.fastq.gz
# │   ├── sample2_R1.fastq.gz
# │   ├── sample2_R2.fastq.gz
# │   └── ... (more paired-end samples)
# │
# ├── trimmed_reads/         # Output from Trimmomatic (auto-created)
# │   ├── sample1_R1_paired.fq.gz
# │   ├── sample1_R1_unpaired.fq.gz
# │   ├── sample1_R2_paired.fq.gz
# │   ├── sample1_R2_unpaired.fq.gz
# │   └── ... (for other samples)
# │
# ├── fastqc_results/        # FastQC reports (auto-created)
# │   ├── sample1_R1_fastqc.html
# │   ├── sample1_R1_fastqc.zip
# │   ├── sample1_R2_fastqc.html
# │   ├── sample1_R2_fastqc.zip
# │   └── ... (for other samples)
# │
# └── run_pipeline.sh        # The bash script itself: 


#load the trim_qc_env from M2P3
module load miniconda3

source activate trim_qc_env


# Directory containing FASTQ files
RAW_DIR="data"
TRIMMED_DIR="results/trimmed_reads"
FASTQC_DIR="results/fastqc_results"
TRIMMED_FASTQC_DIR="results/fastqc_trimmed_results"

# Create output directories if they don't exist
mkdir -p $TRIMMED_DIR
mkdir -p $FASTQC_DIR

# Trimmomatic settings
ADAPTERS="/path/to/adapters/TruSeq3-PE.fa"  # Update this path to your adapters
ILLUMINACLIP="ILLUMINACLIP:${ADAPTERS}:2:30:10"
LEADING=3
TRAILING=3
SLIDINGWINDOW="SLIDINGWINDOW:4:15"
MINLEN=36

# Step 1: Run FastQC on raw reads
echo "Running FastQC on raw reads..."
fastqc -o $FASTQC_DIR $RAW_DIR/*.fastq.gz

# Step 2: Run Trimmomatic on all paired-end files
echo "Running Trimmomatic..."
for R1 in $RAW_DIR/*_R1*.fastq.gz; do
    R2="${R1/_R1/_R2}"  # paired read
    BASENAME=$(basename $R1 _R1.fastq.gz)
    
    TRIM_R1="$TRIMMED_DIR/${BASENAME}_R1_paired.fq.gz"
    TRIM_R2="$TRIMMED_DIR/${BASENAME}_R2_paired.fq.gz"
    UNPAIR_R1="$TRIMMED_DIR/${BASENAME}_R1_unpaired.fq.gz"
    UNPAIR_R2="$TRIMMED_DIR/${BASENAME}_R2_unpaired.fq.gz"
    
    trimmomatic PE -threads 4 $R1 $R2 \
        $TRIM_R1 $UNPAIR_R1 \
        $TRIM_R2 $UNPAIR_R2 \
        $ILLUMINACLIP LEADING:$LEADING TRAILING:$TRAILING $SLIDINGWINDOW MINLEN:$MINLEN
done

# Step 3: Run FastQC on trimmed reads
echo "Running FastQC on trimmed reads..."
fastqc -o $FASTQC_DIR $TRIMMED_FASTQC_DIR/*.fq.gz

echo "Pipeline complete!"
